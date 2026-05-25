export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const { to, body, channel = 'sms' } = req.body;
  if (!to || !body) {
    res.status(400).json({ error: 'Missing "to" or "body"' });
    return;
  }

  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;
  const fromNumber = process.env.TWILIO_PHONE_NUMBER;

  if (!accountSid || !authToken || !fromNumber) {
    res.status(500).json({ error: 'Twilio credentials not configured' });
    return;
  }

  const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`;
  const form = new URLSearchParams();

  if (channel === 'whatsapp') {
    form.append('From', `whatsapp:${fromNumber}`);
    form.append('To', `whatsapp:${to}`);
  } else {
    form.append('From', fromNumber);
    form.append('To', to);
  }
  form.append('Body', body);

  try {
    const twilioRes = await fetch(twilioUrl, {
      method: 'POST',
      headers: {
        'Authorization': 'Basic ' + Buffer.from(accountSid + ':' + authToken).toString('base64'),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: form.toString(),
    });

    const data = await twilioRes.json();
    if (!twilioRes.ok) {
      res.status(twilioRes.status).json({ error: data.message || 'Twilio error', twilio: data });
      return;
    }

    res.status(200).json({ success: true, sid: data.sid, status: data.status });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}
