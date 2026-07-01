import { useState, useEffect, useCallback } from 'react';
import { supabase } from './supabase';
import { getProducts as getMockProducts, getLocations as getMockLocations, getMovements as getMockMovements, getCustomers as getMockCustomers, users as mockUsers, seedSurveys, statusOf, money } from '../data/products';

function enrichProduct(p) {
  const st = statusOf(p.qty, p.min_qty ?? p.min, p.max_qty ?? p.max);
  const price = Number(p.price);
  const qty = p.qty;
  const max = p.max_qty ?? p.max;
  return {
    sku: p.sku, name: p.name, cat: p.category ?? p.cat, unit: p.unit,
    qty, min: p.min_qty ?? p.min, max, loc: p.location ?? p.loc,
    price, value: qty * price, valueText: money(qty * price), priceText: money(price),
    st, fillPct: Math.min(100, Math.round(qty / max * 100)) + '%'
  };
}

function enrichMovement(r) {
  const isIn = r.direction === 'in' || r.dir === 'in';
  return {
    ref: r.ref, dir: r.direction || r.dir, time: r.time_label || r.time,
    sku: r.sku, name: r.product_name || r.name, qty: r.qty,
    loc: r.location || r.loc, by: r.created_by || r.by, doc: r.doc,
    isIn, qtyText: (isIn ? '+' : '−') + r.qty,
    fg: isIn ? '#16a34a' : '#ef4444', bg: isIn ? '#dcfce7' : '#fee2e2',
    typeLabel: isIn ? 'รับเข้า' : 'จ่ายออก'
  };
}

function enrichCustomerRows(rows) {
  const stMap = {
    done: { label: 'ปิดงาน', fg: '#15803d', bg: '#dcfce7' },
    issue: { label: 'มีปัญหา', fg: '#b91c1c', bg: '#fee2e2' },
    progress: { label: 'กำลังดำเนินการ', fg: '#b45309', bg: '#fef3c7' }
  };
  return rows.map((c, i) => {
    const st = stMap[c.status] || stMap.progress;
    const isCash = (c.payment_type || c.type) === 'เงินสด';
    const outstanding = Number(c.outstanding) || 0;
    const amount = Number(c.amount) || 0;
    const downPay = Number(c.down_payment ?? c.downPay) || 0;
    const creditAmt = Number(c.credit_amount ?? c.creditAmt) || 0;
    return {
      idx: i + 1, name: c.name, amount, amountText: money(amount),
      type: c.payment_type || c.type, isCash, downPay, downText: money(downPay),
      creditAmt, creditText: creditAmt ? money(creditAmt) : '—',
      outstanding, outstandingText: outstanding ? money(outstanding) : '—',
      outColor: outstanding > 0 ? '#d97706' : '#9aabbf',
      payDate: c.pay_date || c.payDate || '—', owner: c.owner, st,
      note: c.note || '', hasNote: !!(c.note),
      typeStyle: { fontSize: '11px', fontWeight: 600, padding: '3px 10px', borderRadius: '7px', color: '#fff', background: isCash ? '#16a34a' : '#b91c1c' },
      ownerStyle: { fontSize: '11px', fontWeight: 600, padding: '3px 10px', borderRadius: '7px', color: '#fff', background: c.owner === 'พี่เบญ' ? '#7c2d12' : '#92400e' },
      statusStyle: { fontSize: '11.5px', fontWeight: 600, padding: '4px 12px', borderRadius: '20px', color: st.fg, background: st.bg, whiteSpace: 'nowrap' }
    };
  });
}

export function useSupabaseData() {
  const [products, setProducts] = useState([]);
  const [locations, setLocations] = useState([]);
  const [movements, setMovements] = useState([]);
  const [customerGroups, setCustomerGroups] = useState([]);
  const [users, setUsers] = useState(mockUsers);
  const [surveys, setSurveys] = useState(seedSurveys);
  const [loading, setLoading] = useState(true);
  const [dbConnected, setDbConnected] = useState(false);

  const loadAll = useCallback(async () => {
    try {
      const [pRes, lRes, mRes, cRes, sRes] = await Promise.all([
        supabase.from('products').select('*').order('sku'),
        supabase.from('locations').select('*').order('code'),
        supabase.from('movements').select('*').order('id', { ascending: false }),
        supabase.from('customers').select('*').order('id'),
        supabase.from('surveys').select('*').order('created_at', { ascending: false }),
      ]);

      if (pRes.error || !pRes.data?.length) throw new Error('No DB data');

      setProducts(pRes.data.map(enrichProduct));
      setLocations(lRes.data || []);
      setMovements(mRes.data.map(enrichMovement));

      // Group customers by month
      const grouped = {};
      (cRes.data || []).forEach(c => {
        const key = c.month_group;
        if (!grouped[key]) grouped[key] = { month: c.month_group, label: c.month_label, rows: [] };
        grouped[key].rows.push(c);
      });
      setCustomerGroups(Object.values(grouped).map(g => ({
        ...g, rows: enrichCustomerRows(g.rows)
      })));

      // รายชื่อผู้ใช้/รหัสเข้าระบบ ใช้จากในโค้ด (mockUsers) เสมอ ไม่ดึงจาก DB
      // เพื่อให้ควบคุมบัญชีพนักงานได้จากโค้ดโดยตรง

      if (sRes.data?.length) setSurveys(sRes.data.map(s => ({
        id: s.id, customer: s.customer, surveyor: s.surveyor, date: s.survey_date,
        roof: s.roof, azimuth: s.azimuth, sizeKw: Number(s.size_kw), panels: s.panels,
        done: s.done, total: s.total, status: s.status
      })));

      setDbConnected(true);
    } catch {
      setProducts(getMockProducts());
      setLocations(getMockLocations());
      setMovements(getMockMovements());
      setCustomerGroups(getMockCustomers());
      setUsers(mockUsers);
      setSurveys(seedSurveys);
      setDbConnected(false);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { loadAll(); }, [loadAll]);

  const addMovement = useCallback(async (movement) => {
    if (dbConnected) {
      const { error } = await supabase.from('movements').insert({
        ref: movement.ref, direction: movement.dir, time_label: movement.time,
        sku: movement.sku, product_name: movement.name, qty: movement.qty,
        location: movement.loc, created_by: movement.by, doc: movement.doc || '—'
      });
      if (!error) {
        const qtyChange = movement.dir === 'in' ? movement.qty : -movement.qty;
        await supabase.from('products').update({
          qty: (products.find(p => p.sku === movement.sku)?.qty || 0) + qtyChange,
          updated_at: new Date().toISOString()
        }).eq('sku', movement.sku);
        await loadAll();
      }
    }
    return enrichMovement(movement);
  }, [dbConnected, products, loadAll]);

  const addSurvey = useCallback(async (survey) => {
    if (dbConnected) {
      await supabase.from('surveys').insert({
        id: survey.id, customer: survey.customer, surveyor: survey.surveyor,
        survey_date: survey.date, roof: survey.roof || '', azimuth: survey.azimuth || '',
        size_kw: survey.sizeKw || 0, panels: survey.panels || 0,
        done: survey.done, total: survey.total, status: survey.status,
        notes: survey.notes || {}, checks: survey.checks || {}
      });
      await loadAll();
    }
    return survey;
  }, [dbConnected, loadAll]);

  const updateProduct = useCallback(async (sku, updates) => {
    if (dbConnected) {
      await supabase.from('products').update({
        ...updates, updated_at: new Date().toISOString()
      }).eq('sku', sku);
      await loadAll();
    }
  }, [dbConnected, loadAll]);

  return {
    products, locations, movements, customerGroups, users, surveys,
    loading, dbConnected, loadAll,
    addMovement, addSurvey, updateProduct, setSurveys
  };
}
