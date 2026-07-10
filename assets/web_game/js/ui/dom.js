// أدوات DOM بسيطة مشتركة بين وحدات الواجهة
export const $ = (id) => document.getElementById(id);
export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

export function el(tag, className, attrs) {
  const e = document.createElement(tag);
  if (className) e.className = className;
  if (attrs) for (const k in attrs) e.setAttribute(k, attrs[k]);
  return e;
}
