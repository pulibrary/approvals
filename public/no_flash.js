// Modified from code found: https://petrey.co/2017/05/the-most-effective-way-to-avoid-the-fouc/
// This file can't be served via vite/esmodules, since those are
// only executed after the browser has finished loading the page.
var page_ready = false;
function show_dom(H){ return H.className=H.className.replace(/\bno-js\b/,'js'); }

window.addEventListener('load', function(event) {
  if (page_ready) show_dom(document.documentElement);
  page_ready = true;
});

window.addEventListener('DOMContentLoaded', function(event) {
  if (page_ready) show_dom(document.documentElement);
  page_ready = true;
});
