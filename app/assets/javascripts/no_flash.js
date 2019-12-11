// Modified from code found: https://petrey.co/2017/05/the-most-effective-way-to-avoid-the-fouc/
var page_ready = false;
const show_dom = (H) => H.className=H.className.replace(/\bno-js\b/,'js');

window.addEventListener('load', (event) => {
  if (page_ready) show_dom(document.documentElement); 
  page_ready = true;
});

window.addEventListener('DOMContentLoaded', (event) => {
  if (page_ready) show_dom(document.documentElement);
  page_ready = true;
});

