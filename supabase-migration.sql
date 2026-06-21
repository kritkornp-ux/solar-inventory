-- SolarStock Inventory Management - Supabase Migration
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor → New Query)

-- 1. USERS
create table if not exists app_users (
  id text primary key,
  name text not null,
  role text not null,
  dept text not null,
  pin text not null default '1234',
  color text not null default '#2563eb',
  created_at timestamptz default now()
);

-- 2. PRODUCTS
create table if not exists products (
  sku text primary key,
  name text not null,
  category text not null,
  unit text not null,
  qty integer not null default 0,
  min_qty integer not null default 0,
  max_qty integer not null default 0,
  location text not null,
  price numeric not null default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 3. LOCATIONS
create table if not exists locations (
  code text primary key,
  name text not null,
  type text not null,
  capacity integer not null default 0,
  used integer not null default 0,
  items integer not null default 0,
  color text not null default '#3b82f6',
  created_at timestamptz default now()
);

-- 4. MOVEMENTS
create table if not exists movements (
  id serial primary key,
  ref text not null unique,
  direction text not null check (direction in ('in', 'out')),
  time_label text not null,
  sku text references products(sku),
  product_name text not null,
  qty integer not null,
  location text not null,
  created_by text not null,
  doc text default '—',
  created_at timestamptz default now()
);

-- 5. CUSTOMERS
create table if not exists customers (
  id serial primary key,
  month_group text not null,
  month_label text not null,
  name text not null,
  amount numeric not null default 0,
  payment_type text not null,
  down_payment numeric not null default 0,
  credit_amount numeric not null default 0,
  outstanding numeric not null default 0,
  pay_date text default '—',
  owner text not null,
  status text not null default 'progress',
  note text default '',
  created_at timestamptz default now()
);

-- 6. SURVEYS
create table if not exists surveys (
  id text primary key,
  customer text not null,
  surveyor text not null,
  survey_date text not null,
  roof text default '',
  azimuth text default '',
  size_kw numeric default 0,
  panels integer default 0,
  done integer not null default 0,
  total integer not null default 16,
  status text not null default 'pending',
  notes jsonb default '{}',
  checks jsonb default '{}',
  created_at timestamptz default now()
);

-- Enable Row Level Security
alter table app_users enable row level security;
alter table products enable row level security;
alter table locations enable row level security;
alter table movements enable row level security;
alter table customers enable row level security;
alter table surveys enable row level security;

-- Allow public read/write for all tables (adjust for production)
create policy "Allow all on app_users" on app_users for all using (true) with check (true);
create policy "Allow all on products" on products for all using (true) with check (true);
create policy "Allow all on locations" on locations for all using (true) with check (true);
create policy "Allow all on movements" on movements for all using (true) with check (true);
create policy "Allow all on customers" on customers for all using (true) with check (true);
create policy "Allow all on surveys" on surveys for all using (true) with check (true);

-- ===================== SEED DATA =====================

-- Users
insert into app_users (id, name, role, dept, pin, color) values
  ('somchai', 'สมชาย กิจเจริญ', 'หัวหน้าคลัง', 'คลังสินค้า', '1234', '#2563eb'),
  ('wipa', 'วิภา สุขใจ', 'เจ้าหน้าที่จ่ายออก', 'คลังสินค้า', '1234', '#16a34a'),
  ('thana', 'ธนา พงษ์ไพร', 'เจ้าหน้าที่รับเข้า', 'คลังสินค้า', '1234', '#0891b2'),
  ('nattaya', 'ณัฐญา ศรีทอง', 'ฝ่ายขาย', 'การขาย', '1234', '#d97706'),
  ('prasert', 'ประเสริฐ มั่นคง', 'วิศวกรสำรวจหน้างาน', 'วิศวกรรม', '1234', '#7c3aed'),
  ('kanya', 'กัญญา ใจดี', 'ฝ่ายบัญชี', 'บัญชี/การเงิน', '1234', '#db2777'),
  ('wuttichai', 'วุฒิชัย แดงสว่าง', 'ช่างติดตั้ง', 'ติดตั้ง', '1234', '#ea580c'),
  ('siriporn', 'ศิริพร วงศ์ทอง', 'ฝ่ายจัดซื้อ', 'จัดซื้อ', '1234', '#0d9488'),
  ('anan', 'อนันต์ รุ่งเรือง', 'ผู้จัดการคลัง', 'บริหาร', '1234', '#4f46e5'),
  ('admin', 'ผู้ดูแลระบบ', 'Administrator', 'IT', '0000', '#475569')
on conflict (id) do nothing;

-- Products
insert into products (sku, name, category, unit, qty, min_qty, max_qty, location, price) values
  ('PNL-LG650', 'แผงโซล่าร์ Longi 650W', 'แผงโซล่าร์เซลล์', 'แผง', 1056, 200, 1200, 'A1-03', 2976),
  ('BAT-LVT16', 'แบตเตอรี่ LVTOPSUN 314A G4 51.2V (16kWh)', 'แบตเตอรี่', 'ก้อน', 0, 4, 30, 'B1-04', 60000),
  ('INV-HW5K', 'Huawei SUN2000-5KTL-LB0 (5kW)', 'อินเวอร์เตอร์', 'เครื่อง', 5, 3, 20, 'B2-01', 21700),
  ('INV-HW10LC', 'Huawei SUN2000-10K-LC0 (10kW)', 'อินเวอร์เตอร์', 'เครื่อง', 4, 3, 20, 'B2-02', 28800),
  ('INV-HW10MAP', 'Huawei SUN2000-10K-MAP0 (10kW)', 'อินเวอร์เตอร์', 'เครื่อง', 3, 3, 20, 'B2-03', 42800),
  ('INV-HW15K', 'Huawei SUN2000-15K-MB0 (15kW)', 'อินเวอร์เตอร์', 'เครื่อง', 3, 2, 15, 'B2-04', 58400),
  ('INV-HW20K', 'Huawei SUN2000-20K-MB0 (20kW)', 'อินเวอร์เตอร์', 'เครื่อง', 1, 2, 12, 'B2-05', 65300),
  ('INV-SL15K', 'Solis S6-EH3P15K02-NVYD-L (15kW)', 'อินเวอร์เตอร์', 'เครื่อง', 2, 2, 15, 'B2-06', 59000),
  ('INV-SL10K', 'Solis S6-EH1P10K-L-PLUS (10kW)', 'อินเวอร์เตอร์', 'เครื่อง', 3, 3, 20, 'B2-07', 46706),
  ('INV-SL6K', 'Solis S6-EH1P6K-L-PLUS (6kW)', 'อินเวอร์เตอร์', 'เครื่อง', 3, 3, 20, 'B2-08', 27007),
  ('INV-SG20K', 'Sigenergy Inverter 20.0kW', 'อินเวอร์เตอร์', 'เครื่อง', 0, 2, 12, 'B2-09', 92400),
  ('BAT-SG10K', 'แบตเตอรี่ Sigenergy 10kW', 'แบตเตอรี่', 'ก้อน', 0, 2, 20, 'B1-08', 84500),
  ('MTR-HW1P', 'Huawei Smart Meter 1Phase + CT', 'สมาร์ทมิเตอร์', 'ตัว', 0, 3, 30, 'B3-01', 2050),
  ('MTR-HW3P', 'Huawei Smart Meter 3Phase + CT', 'สมาร์ทมิเตอร์', 'ตัว', 0, 3, 30, 'B3-02', 3200),
  ('MTR-HW3PHW', 'Huawei Smart Meter 3Phase HW', 'สมาร์ทมิเตอร์', 'ตัว', 1, 3, 30, 'B3-03', 3150),
  ('MTR-HWDDSU', 'Huawei Power Sensor DDSU666-H 1Ph', 'สมาร์ทมิเตอร์', 'ตัว', 4, 3, 30, 'B3-04', 1900),
  ('MNT-SGBAT', 'ขาตั้งแบตเตอรี่ Sigenergy (Ground)', 'อุปกรณ์ยึด', 'ชุด', 0, 2, 20, 'C1-08', 4600),
  ('BRK-LM125', 'เบรกเกอร์ Lumira 125A 500V', 'เบรกเกอร์', 'ตัว', 5, 5, 50, 'B3-06', 700),
  ('DNG-001', 'Dongle (อุปกรณ์สื่อสาร)', 'Dongle', 'ตัว', 6, 5, 40, 'C2-03', 1883)
on conflict (sku) do nothing;

-- Locations
insert into locations (code, name, type, capacity, used, items, color) values
  ('A1', 'Zone A · แถว 1', 'แผงโซลาร์เซลล์', 600, 492, 2, '#3b82f6'),
  ('A2', 'Zone A · แถว 2', 'แผงโซลาร์เซลล์', 400, 156, 1, '#3b82f6'),
  ('B1', 'Zone B · ชั้นวางแบตเตอรี่', 'แบตเตอรี่', 110, 26, 2, '#22c55e'),
  ('B2', 'Zone B · ชั้นวางอินเวอร์เตอร์', 'อินเวอร์เตอร์', 210, 93, 3, '#22c55e'),
  ('B3', 'Zone B · อุปกรณ์ควบคุม', 'ควบคุม/ป้องกัน', 500, 221, 3, '#22c55e'),
  ('C1', 'Zone C · อุปกรณ์ยึดติดตั้ง', 'อุปกรณ์ยึด', 1000, 628, 2, '#06b6d4'),
  ('C2', 'Zone C · สายไฟ & ขั้วต่อ', 'สายไฟ/ขั้วต่อ', 1200, 121, 3, '#06b6d4')
on conflict (code) do nothing;

-- Movements
insert into movements (ref, direction, time_label, sku, product_name, qty, location, created_by, doc) values
  ('GR-69-0021', 'in', '13 มิ.ย. 10:20', 'DNG-001', 'Dongle (อุปกรณ์สื่อสาร)', 6, 'C2-03', 'ธนา พ.', '—'),
  ('GR-69-0020', 'in', '11 มิ.ย. 09:10', 'BRK-LM125', 'เบรกเกอร์ Lumira 125A 500V', 5, 'B3-06', 'ธนา พ.', 'บ้านพลังงาน'),
  ('GI-69-0019', 'out', '23 พ.ค. 16:30', 'INV-SL6K', 'Solis S6-EH1P6K-L-PLUS (6kW)', 2, 'B2-08', 'ณัฐญา ศ.', 'KT'),
  ('GR-69-0018', 'in', '23 พ.ค. 11:00', 'INV-SL10K', 'Solis S6-EH1P10K-L-PLUS (10kW)', 5, 'B2-07', 'ธนา พ.', 'เคเอสเอ็นฟอร์จูน'),
  ('GI-69-0017', 'out', '23 พ.ค. 11:05', 'INV-SL10K', 'Solis S6-EH1P10K-L-PLUS (10kW)', 2, 'B2-07', 'ณัฐญา ศ.', 'คุณสุภาวดี (ภูเก็ต), KT'),
  ('GI-69-0016', 'out', '21 พ.ค. 15:40', 'INV-SL6K', 'Solis S6-EH1P6K-L-PLUS (6kW)', 3, 'B2-08', 'ณัฐญา ศ.', 'คุณจันจิรา, คุณประภัสสร, คุณนวพัณณ์'),
  ('GI-69-0015', 'out', '15 พ.ค. 14:10', 'INV-SG20K', 'Sigenergy Inverter 20.0kW', 1, 'B2-09', 'ณัฐญา ศ.', 'บจก.เอลีท แอดแวนเทจ'),
  ('GI-69-0014', 'out', '15 พ.ค. 14:10', 'BAT-SG10K', 'แบตเตอรี่ Sigenergy 10kW', 2, 'B1-08', 'วิภา ส.', 'บจก.เอลีท แอดแวนเทจ'),
  ('GR-69-0013', 'in', '15 พ.ค. 09:30', 'INV-SG20K', 'Sigenergy Inverter 20.0kW', 1, 'B2-09', 'ธนา พ.', 'ซิกเน็ก'),
  ('GI-69-0012', 'out', '09 พ.ค. 13:25', 'PNL-LG650', 'แผงโซล่าร์ Longi 650W', 96, 'A1-03', 'วิภา ส.', 'คุณนราชัย, KT'),
  ('GR-69-0011', 'in', '09 พ.ค. 08:45', 'PNL-LG650', 'แผงโซล่าร์ Longi 650W', 720, 'A1-03', 'ธนา พ.', 'ซิกเน็ก'),
  ('GI-69-0010', 'out', '06 พ.ค. 10:50', 'INV-SL15K', 'Solis S6-EH3P15K02-NVYD-L (15kW)', 1, 'B2-06', 'ณัฐญา ศ.', 'คุณนราชัย'),
  ('GR-69-0009', 'in', '06 พ.ค. 09:00', 'INV-SL15K', 'Solis S6-EH3P15K02-NVYD-L (15kW)', 3, 'B2-06', 'ธนา พ.', 'GT'),
  ('GI-69-0008', 'out', '01 พ.ค. 15:00', 'BAT-LVT16', 'แบตเตอรี่ LVTOPSUN 314A (16kWh)', 8, 'B1-04', 'วิภา ส.', 'คุณจันจิรา, แม่มาลี3, KT ฯลฯ'),
  ('GR-69-0007', 'in', '01 พ.ค. 09:15', 'BAT-LVT16', 'แบตเตอรี่ LVTOPSUN 314A (16kWh)', 8, 'B1-04', 'ธนา พ.', 'GT'),
  ('GI-69-0006', 'out', '21 เม.ย. 14:20', 'INV-HW5K', 'Huawei SUN2000-5KTL-LB0 (5kW)', 1, 'B2-01', 'ณัฐญา ศ.', 'คุณประโมทย์'),
  ('GR-69-0005', 'in', '21 เม.ย. 09:30', 'INV-HW5K', 'Huawei SUN2000-5KTL-LB0 (5kW)', 6, 'B2-01', 'ธนา พ.', 'GT'),
  ('GI-69-0004', 'out', '06 เม.ย. 11:40', 'INV-HW15K', 'Huawei SUN2000-15K-MB0 (15kW)', 1, 'B2-04', 'ณัฐญา ศ.', 'หจก.เอสซีเอฟ (ยะลา)'),
  ('GI-69-0003', 'out', '06 เม.ย. 11:30', 'INV-HW10MAP', 'Huawei SUN2000-10K-MAP0 (10kW)', 1, 'B2-03', 'ณัฐญา ศ.', 'ห้างทองไทยเจริญ'),
  ('GR-69-0002', 'in', '06 เม.ย. 09:00', 'INV-HW15K', 'Huawei SUN2000-15K-MB0 (15kW)', 4, 'B2-04', 'ธนา พ.', 'ซิกเน็ก'),
  ('GR-69-0001', 'in', '10 เม.ย. 09:00', 'PNL-LG650', 'แผงโซล่าร์ Longi 650W', 432, 'A1-03', 'ธนา พ.', 'บ้านพลังงาน')
on conflict (ref) do nothing;

-- Customers
insert into customers (month_group, month_label, name, amount, payment_type, down_payment, credit_amount, outstanding, pay_date, owner, status, note) values
  ('มกราคม 2569', 'โซล่าร์เดือนมกราคม', 'คุณสุทธิศักดิ์ ทองขาว', 200000, 'ICBC', 20000, 180000, 0, '26/01/69', 'พี่สีแก้ว', 'done', ''),
  ('มกราคม 2569', 'โซล่าร์เดือนมกราคม', 'คุณสุรชัย พรมจิตร', 230000, 'ICBC', 23000, 207000, 0, '28/01/69', 'พี่เบญ', 'done', ''),
  ('มกราคม 2569', 'โซล่าร์เดือนมกราคม', 'คุณจารีย์ แก้วนก', 280000, 'ICBC', 28000, 252000, 0, '27/01/69', 'พี่สีแก้ว', 'done', ''),
  ('มกราคม 2569', 'โซล่าร์เดือนมกราคม', 'คุณบัฐพงศ์ มีศรี (ท่าศาลา)', 170000, 'เงินสด', 34000, 0, 0, '04/02/69', 'พี่เบญ', 'done', ''),
  ('มกราคม 2569', 'โซล่าร์เดือนมกราคม', 'คุณฤทธิ์ เดชะผล', 260000, 'ICBC', 26000, 234000, 0, '12/02/69', 'พี่สีแก้ว', 'done', ''),
  ('มกราคม 2569', 'โซล่าร์เดือนมกราคม', 'คุณคมอักร หนูสง', 950000, 'ICBC', 100000, 850000, 0, '26/02/69', 'พี่เบญ', 'done', ''),
  ('กุมภาพันธ์ 2569', 'โซล่าร์เดือนกุมภาพันธ์', 'บจก.ออราเคิล (ธ.ค.68)', 260000, 'เงินสด', 52000, 0, 0, '05/04/69', 'พี่สีแก้ว', 'done', ''),
  ('กุมภาพันธ์ 2569', 'โซล่าร์เดือนกุมภาพันธ์', 'คุณวิชัย อิฐสถิตไพศาล (คลินิก)', 424000, 'เงินสด', 42400, 0, 381600, '', 'พี่เบญ', 'issue', 'คลินิกลูกค้ายังทำประตูไม่เสร็จ'),
  ('กุมภาพันธ์ 2569', 'โซล่าร์เดือนกุมภาพันธ์', 'คุณวิชัย อิฐสถิตไพศาล (บ้าน)', 609000, 'เงินสด', 337000, 0, 0, '17/06/69', 'พี่เบญ', 'issue', 'ขอคู่มือการใช้งานและไปนำเสนอส่งมอบงาน พร้อมจ่ายเงินวิศวะ KT กำลังทำแบบให้'),
  ('กุมภาพันธ์ 2569', 'โซล่าร์เดือนกุมภาพันธ์', 'คุณจุฬาลักษณ์ รุ่งเรือง (พ.ย.69)', 712000, 'เงินสด', 69000, 0, 643000, '', 'พี่เบญ', 'issue', 'บ้านลูกค้ายังสร้างไม่เสร็จ'),
  ('กุมภาพันธ์ 2569', 'โซล่าร์เดือนกุมภาพันธ์', 'คุณพจนา พรหมจีน (Oshop88)', 1980000, 'ICBC', 198000, 1782000, 0, '10/04/69', 'พี่เบญ', 'done', ''),
  ('กุมภาพันธ์ 2569', 'โซล่าร์เดือนกุมภาพันธ์', 'คุณสรเชษฐ์ สรภักดิ์ (โรงเหล็กร่อน)', 417300, 'ICBC', 95855, 321445, 0, '18/03/69', 'พี่สีแก้ว', 'done', '');

-- Surveys
insert into surveys (id, customer, surveyor, survey_date, roof, azimuth, size_kw, panels, done, total, status) values
  ('SV-2569-0007', 'คุณวิชัย อิฐสถิตไพศาล', 'พี่เบญ', '17 มิ.ย. 2569', 'เมทัลชีท', 'ทิศใต้', 10.2, 18, 16, 16, 'approved'),
  ('SV-2569-0006', 'คุณสมหญิง รุ่งโรจน์', 'ประเสริฐ', '15 มิ.ย. 2569', 'กระเบื้องลอนคู่', 'ทิศตะวันตก', 5.5, 10, 16, 16, 'approved'),
  ('SV-2569-0005', 'หจก. นาหลวงฟาร์ม', 'พี่เบญ', '12 มิ.ย. 2569', 'เมทัลชีท', 'ทิศใต้', 25.0, 45, 14, 16, 'pending'),
  ('SV-2569-0004', 'คุณอนุชา ตั้งใจ', 'ประเสริฐ', '8 มิ.ย. 2569', 'คอนกรีต/ดาดฟ้า', 'ทิศตะวันออก', 3.3, 6, 16, 16, 'approved'),
  ('SV-2569-0003', 'คุณกิตติ พูลสุข', 'พี่เบญ', '3 มิ.ย. 2569', 'เมทัลชีท', 'ทิศใต้', 8.0, 14, 11, 16, 'rework')
on conflict (id) do nothing;
