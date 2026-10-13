(() => {
  'use strict';

  const config = window.FOC_ADMIN_CONFIG;
  const $ = (id) => document.getElementById(id);
  const notice = $('notice');
  const authPanel = $('auth-panel');
  const adminPanel = $('admin-panel');
  const pageSize = 100;
  const sessionKey = 'foc-fast-admin-session';
  let session = null;
  let scores = [];
  let editingId = null;
  let hasMore = false;

  function message(text, error = false) {
    notice.textContent = text;
    notice.classList.toggle('error', error);
  }

  if (!config?.url || !config?.publishableKey) {
    message('This editor has not been configured for Supabase.', true);
    $('auth-form').hidden = true;
    return;
  }
  const base = config.url.replace(/\/+$/, '');

  function saveSession(value) {
    session = value;
    if (value) sessionStorage.setItem(sessionKey, JSON.stringify(value));
    else sessionStorage.removeItem(sessionKey);
  }

  async function request(path, options = {}, retry = true) {
    const headers = { apikey: config.publishableKey };
    if (options.body !== undefined) headers['Content-Type'] = 'application/json';
    if (options.auth) {
      if (!session?.access_token) throw new Error('Please sign in again.');
      headers.Authorization = `Bearer ${session.access_token}`;
    }
    if (options.prefer) headers.Prefer = options.prefer;
    const response = await fetch(`${base}${path}`, {
      method: options.method || 'GET',
      headers,
      body: options.body === undefined ? undefined : JSON.stringify(options.body),
      cache: 'no-store',
    });
    if (response.status === 401 && options.auth && retry && session?.refresh_token) {
      await refreshSession();
      return request(path, options, false);
    }
    const text = await response.text();
    let data = null;
    if (text) {
      try { data = JSON.parse(text); } catch { data = text; }
    }
    if (!response.ok) {
      throw new Error(data?.msg || data?.message || data?.error_description || data?.error || `Request failed (${response.status}).`);
    }
    return data;
  }

  async function refreshSession() {
    const refreshed = await request('/auth/v1/token?grant_type=refresh_token', {
      method: 'POST', body: { refresh_token: session.refresh_token },
    });
    saveSession(refreshed);
  }

  async function enterEditor() {
    const allowed = await request('/rest/v1/rpc/leaderboard_admin_status', {
      method: 'POST', body: {}, auth: true,
    });
    if (allowed !== true) {
      saveSession(null);
      throw new Error('This account is not yet authorized. Confirm its email, then sign in again.');
    }
    $('signed-in-email').textContent = session.user?.email || $('email').value;
    authPanel.hidden = true;
    adminPanel.hidden = false;
    message('Administrator access verified.');
    await loadScores(false);
  }

  $('auth-form').addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = $('sign-in');
    button.disabled = true;
    message('Signing in…');
    try {
      const signedIn = await request('/auth/v1/token?grant_type=password', {
        method: 'POST',
        body: { email: $('email').value, password: $('password').value },
      });
      saveSession(signedIn);
      $('password').value = '';
      await enterEditor();
    } catch (error) { message(error.message, true); }
    finally { button.disabled = false; }
  });

  $('sign-up').addEventListener('click', async () => {
    if (!$('auth-form').reportValidity()) return;
    const button = $('sign-up');
    button.disabled = true;
    message('Creating your account…');
    try {
      await request('/auth/v1/signup', {
        method: 'POST',
        body: { email: $('email').value, password: $('password').value },
      });
      $('password').value = '';
      message('Check your university inbox for the confirmation email. Confirm it, then return here and sign in.');
    } catch (error) { message(error.message, true); }
    finally { button.disabled = false; }
  });

  $('sign-out').addEventListener('click', async () => {
    try { await request('/auth/v1/logout', { method: 'POST', auth: true }); } catch { /* Clear this tab even if the network is down. */ }
    saveSession(null);
    scores = [];
    adminPanel.hidden = true;
    authPanel.hidden = false;
    message('Signed out.');
  });

  async function loadScores(more) {
    const offset = more ? scores.length : 0;
    message('Loading scores…');
    try {
      const page = await request(`/rest/v1/torque_chase_scores?select=id,nickname,max_rpm,created_at,hidden&order=created_at.desc&limit=${pageSize}&offset=${offset}`, { auth: true });
      scores = more ? scores.concat(page) : page;
      hasMore = page.length === pageSize;
      renderScores();
      message(`Loaded ${scores.length} ${scores.length === 1 ? 'entry' : 'entries'}.`);
    } catch (error) { message(error.message, true); }
  }

  function action(label, className, handler) {
    const button = document.createElement('button');
    button.type = 'button';
    button.textContent = label;
    if (className) button.className = className;
    button.addEventListener('click', handler);
    return button;
  }

  function renderScores() {
    const body = $('scores-body');
    body.replaceChildren();
    for (const score of scores) {
      const row = document.createElement('tr');
      for (const value of [score.nickname, String(score.max_rpm), new Date(score.created_at).toLocaleString()]) {
        const cell = document.createElement('td');
        cell.textContent = value;
        row.append(cell);
      }
      const status = document.createElement('td');
      const badge = document.createElement('span');
      badge.className = score.hidden ? 'badge hidden' : 'badge';
      badge.textContent = score.hidden ? 'Hidden' : 'Visible';
      status.append(badge);
      row.append(status);
      const controls = document.createElement('td');
      controls.className = 'actions-cell';
      controls.append(
        action('Edit', '', () => beginEdit(score)),
        action(score.hidden ? 'Restore' : 'Hide', '', () => toggleHidden(score)),
        action('Delete', 'danger', () => deleteScore(score)),
      );
      row.append(controls);
      body.append(row);
    }
    $('total-count').textContent = scores.length;
    $('hidden-count').textContent = scores.filter((score) => score.hidden).length;
    $('visible-count').textContent = scores.filter((score) => !score.hidden).length;
    $('empty-state').hidden = scores.length !== 0;
    $('load-more').hidden = !hasMore;
  }

  function resetForm() {
    editingId = null;
    $('score-form').reset();
    $('form-title').textContent = 'Add a score';
    $('save-score').textContent = 'Add score';
    $('cancel-edit').hidden = true;
  }

  function beginEdit(score) {
    editingId = score.id;
    $('nickname').value = score.nickname;
    $('rpm').value = score.max_rpm;
    $('hidden').checked = score.hidden;
    $('form-title').textContent = `Edit ${score.nickname}`;
    $('save-score').textContent = 'Save changes';
    $('cancel-edit').hidden = false;
    $('score-form').scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  $('cancel-edit').addEventListener('click', resetForm);
  $('score-form').addEventListener('submit', async (event) => {
    event.preventDefault();
    const nickname = $('nickname').value.trim();
    const rpm = Number($('rpm').value);
    if (!/^[A-Za-z0-9 _-]{2,16}$/.test(nickname) || !Number.isInteger(rpm) || rpm < 0 || rpm > 10000) {
      message('Check the nickname and whole-number RPM value.', true);
      return;
    }
    const id = editingId;
    const button = $('save-score');
    button.disabled = true;
    try {
      const rows = await request(id === null
        ? '/rest/v1/torque_chase_scores'
        : `/rest/v1/torque_chase_scores?id=eq.${encodeURIComponent(id)}`, {
        method: id === null ? 'POST' : 'PATCH', auth: true,
        prefer: 'return=representation',
        body: { nickname, max_rpm: rpm, hidden: $('hidden').checked },
      });
      if (!rows?.length) throw new Error('No entry was changed. Refresh and try again.');
      resetForm();
      await loadScores(false);
      message(id === null ? 'Score added.' : 'Score updated.');
    } catch (error) { message(error.message, true); }
    finally { button.disabled = false; }
  });

  async function toggleHidden(score) {
    try {
      const rows = await request(`/rest/v1/torque_chase_scores?id=eq.${encodeURIComponent(score.id)}`, {
        method: 'PATCH', auth: true, prefer: 'return=representation',
        body: { hidden: !score.hidden },
      });
      if (!rows?.length) throw new Error('No entry was changed. Refresh and try again.');
      score.hidden = !score.hidden;
      renderScores();
      message(score.hidden ? 'Entry hidden from public leaderboards.' : 'Entry restored to public leaderboards.');
    } catch (error) { message(error.message, true); }
  }

  async function deleteScore(score) {
    if (!window.confirm(`Permanently delete ${score.nickname}'s ${score.max_rpm} RPM score?`)) return;
    try {
      const rows = await request(`/rest/v1/torque_chase_scores?id=eq.${encodeURIComponent(score.id)}`, {
        method: 'DELETE', auth: true, prefer: 'return=representation',
      });
      if (!rows?.length) throw new Error('No entry was deleted. Refresh and try again.');
      scores = scores.filter((entry) => entry.id !== score.id);
      renderScores();
      message('Entry deleted.');
    } catch (error) { message(error.message, true); }
  }

  $('refresh').addEventListener('click', () => loadScores(false));
  $('load-more').addEventListener('click', () => loadScores(true));

  try { session = JSON.parse(sessionStorage.getItem(sessionKey)); } catch { saveSession(null); }
  if (session?.access_token) enterEditor().catch((error) => {
    saveSession(null);
    authPanel.hidden = false;
    adminPanel.hidden = true;
    message(error.message, true);
  });
})();
