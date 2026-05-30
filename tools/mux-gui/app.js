import { XtermAdapter } from './terminal-adapter.ts';

const token = new URLSearchParams(location.search).get('token') || '';
const treeEl = document.querySelector('#tree');
const termEl = document.querySelector('#term');
const enc = new TextEncoder();
let term;
let ws;
let activeTarget;

function api(path) {
  const url = new URL(path, location.origin);
  if (token) url.searchParams.set('token', token);
  return url;
}

function showError(err) {
  treeEl.innerHTML = `<div class="error">${String(err.message || err)}</div>`;
}

async function loadTree() {
  const res = await fetch(api('/api/tree'));
  if (!res.ok) throw new Error(`tree ${res.status}`);
  renderTree(await res.json());
}

function renderTree(nodes) {
  treeEl.textContent = '';
  for (const node of nodes) {
    const el = document.createElement('div');
    el.className = `node ${node.type}`;
    if (node.type === 'session') {
      el.textContent = node.sessionName;
    } else {
      const target = `${node.sessionName}:${node.idx}`;
      el.textContent = `${node.idx}: ${node.title || ''}`;
      el.onclick = () => selectWindow(target, el);
    }
    treeEl.append(el);
  }
}

async function selectWindow(target, nodeEl) {
  activeTarget = target;
  document.querySelectorAll('.node.active').forEach(el => el.classList.remove('active'));
  nodeEl.classList.add('active');
  if (ws) ws.close();
  if (term) term.dispose();
  termEl.textContent = '';
  term = new XtermAdapter();
  term.attach(termEl);
  term.onInput(data => sendInput(data));
  const cap = api('/api/capture');
  cap.searchParams.set('target', target);
  cap.searchParams.set('lines', '80');
  const res = await fetch(cap);
  if (!res.ok) throw new Error(`capture ${res.status}`);
  term.write(enc.encode(await res.text()));
  openStream(target);
}

function openStream(target) {
  const url = api('/api/stream');
  url.protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
  url.searchParams.set('target', target);
  ws = new WebSocket(url);
  ws.onmessage = ev => term?.write(Uint8Array.from(atob(ev.data), c => c.charCodeAt(0)));
  ws.onclose = () => { if (activeTarget === target) setTimeout(() => openStream(target), 1000); };
}

async function sendInput(data) {
  if (!activeTarget) return;
  await fetch(api('/api/send'), {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ target: activeTarget, data, enter: false })
  });
}

addEventListener('resize', () => term?.attach(termEl));
loadTree().catch(showError);
