import React from 'react';

export function Icon({ path, color = 'currentColor', size = 19 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
      dangerouslySetInnerHTML={{ __html: (path || '').replace(/CUR/g, color) }} />
  );
}

export const navIcons = {
  dashboard: '<rect x="3" y="3" width="7" height="9" rx="2" stroke="CUR" stroke-width="2"/><rect x="14" y="3" width="7" height="5" rx="2" stroke="CUR" stroke-width="2"/><rect x="14" y="12" width="7" height="9" rx="2" stroke="CUR" stroke-width="2"/><rect x="3" y="16" width="7" height="5" rx="2" stroke="CUR" stroke-width="2"/>',
  receiving: '<path d="M12 3v10m0 0l-4-4m4 4l4-4" stroke="CUR" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M4 15v4a2 2 0 002 2h12a2 2 0 002-2v-4" stroke="CUR" stroke-width="2" stroke-linecap="round"/>',
  issue: '<path d="M12 13V3m0 0l-4 4m4-4l4 4" stroke="CUR" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" transform="rotate(180 12 8)"/><path d="M4 15v4a2 2 0 002 2h12a2 2 0 002-2v-4" stroke="CUR" stroke-width="2" stroke-linecap="round"/>',
  items: '<rect x="3" y="3" width="18" height="18" rx="2" stroke="CUR" stroke-width="2"/><path d="M3 9h18M9 9v12" stroke="CUR" stroke-width="2"/>',
  locations: '<path d="M12 21s-7-5.5-7-11a7 7 0 1114 0c0 5.5-7 11-7 11z" stroke="CUR" stroke-width="2" stroke-linejoin="round"/><circle cx="12" cy="10" r="2.5" stroke="CUR" stroke-width="2"/>',
  stockreport: '<path d="M5 21V8m7 13V3m7 18v-9" stroke="CUR" stroke-width="2" stroke-linecap="round"/>',
  movereport: '<path d="M4 18L9 12l4 4 7-9" stroke="CUR" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M20 7v5h-5" stroke="CUR" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>',
  sales: '<path d="M3 4h2l2.5 12.5a1.5 1.5 0 001.5 1.2h8a1.5 1.5 0 001.5-1.2L21 8H6" stroke="CUR" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="10" cy="20.5" r="1.3" fill="CUR"/><circle cx="18" cy="20.5" r="1.3" fill="CUR"/>',
  checklist: '<rect x="4" y="3" width="16" height="18" rx="2" stroke="CUR" stroke-width="2"/><path d="M8.5 8.5l1.3 1.3 2.2-2.4M8.5 14.5l1.3 1.3 2.2-2.4" stroke="CUR" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M14.5 9h2.5M14.5 15h2.5" stroke="CUR" stroke-width="1.8" stroke-linecap="round"/>',
  surveyreport: '<path d="M9 3h6l1 3H8l1-3z" stroke="CUR" stroke-width="1.8" stroke-linejoin="round"/><rect x="4" y="6" width="16" height="15" rx="2" stroke="CUR" stroke-width="2"/><path d="M8 11h8M8 15h5" stroke="CUR" stroke-width="1.8" stroke-linecap="round"/>',
  customers: '<circle cx="12" cy="8" r="4" stroke="CUR" stroke-width="2"/><path d="M20 21a8 8 0 00-16 0" stroke="CUR" stroke-width="2" stroke-linecap="round"/>',
  roi: '<circle cx="12" cy="12" r="9" stroke="CUR" stroke-width="2"/><path d="M8.5 15.5l7-7" stroke="CUR" stroke-width="2" stroke-linecap="round"/><circle cx="9.5" cy="9.5" r="1.3" fill="CUR"/><circle cx="14.5" cy="14.5" r="1.3" fill="CUR"/>',
};

export const arrowUpHtml = '<svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M12 5v9m0 0l-3.5-3.5M12 14l3.5-3.5" stroke="#16a34a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
export const arrowDownHtml = '<svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M12 14V5m0 9l-3.5-3.5M12 14l3.5-3.5" stroke="#ef4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" transform="rotate(180 12 9.5)"/></svg>';
