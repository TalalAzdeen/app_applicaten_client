export function supabaseAuthenticator({ url, publicKey, fetcher = fetch }) {
  const base = new URL(url);
  if (base.protocol !== 'https:') throw new Error('Authentication requires HTTPS');
  return async authorization => {
    if (!/^Bearer [A-Za-z0-9._~-]+$/.test(authorization ?? '')) return null;
    const response = await fetcher(new URL('/auth/v1/user', base), {
      headers: { Authorization: authorization, apikey: publicKey }, signal: AbortSignal.timeout(10000) });
    if (response.status === 401 || response.status === 403) return null;
    if (!response.ok) throw new Error('Authentication service unavailable');
    const user = await response.json();
    return typeof user.id === 'string' && user.id ? user.id : null;
  };
}
