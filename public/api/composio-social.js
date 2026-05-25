export default async function handler(req, res) {
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const apiKey = process.env.COMPOSIO_API_KEY;
  if (!apiKey) {
    res.status(500).json({ error: 'COMPOSIO_API_KEY not configured' });
    return;
  }

  try {
    // Fetch Instagram metrics via Composio
    const igRes = await fetch('https://backend.composio.dev/api/v2/actions/INSTAGRAM_BUSINESS_ACCOUNT_GET?show_all=true', {
      headers: { 'x-api-key': apiKey, 'Content-Type': 'application/json' },
    });

    const fbRes = await fetch('https://backend.composio.dev/api/v2/actions/FACEBOOK_GET_USER_PROFILE?show_all=true', {
      headers: { 'x-api-key': apiKey, 'Content-Type': 'application/json' },
    });

    const igData = igRes.ok ? await igRes.json() : null;
    const fbData = fbRes.ok ? await fbRes.json() : null;

    res.status(200).json({
      instagram: igData,
      facebook: fbData,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}
