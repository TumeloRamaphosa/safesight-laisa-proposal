/**
 * composio-social-bridge.js
 *
 * Browser-side module that:
 * 1. Polls /social-metrics.json for real social data
 * 2. Emits CustomEvents the dashboard already listens for
 * 3. Replaces the simulated social stats from agent-os-orchestrator.js
 *
 * Include in laisa-agent-os.html: <script src="src/composio-social-bridge.js"></script>
 */

(function () {
  const POLL_INTERVAL_MS = 15000; // 15 seconds
  const JSON_URL = './social-metrics.json';

  let lastData = null;

  async function fetchMetrics() {
    try {
      const res = await fetch(`${JSON_URL}?t=${Date.now()}`, {
        cache: 'no-store'
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      return data;
    } catch (err) {
      console.warn('[ComposioBridge] Fetch failed:', err.message);
      return null;
    }
  }

  function emitStatsUpdate(data) {
    if (!data) return;

    // Map raw metrics to dashboard stat keys
    const followers = data.instagram?.instagramFollowers ?? 0;
    const engagement7d = data.instagram?.instagramEngagement7d ?? 0;
    const waMessages = data.whatsapp?.waMessages24h ?? 0;

    const mappedStats = {
      revenue: window.AgentOrchestrator?.stats?.revenue ?? 45200,
      patientVolume: window.AgentOrchestrator?.stats?.patientVolume ?? 24,
      socialEngagement: followers, // statSocial uses this
      whatsappMessages: waMessages,
      instagramEngagementDelta: engagement7d,
      _source: data.mode || 'unknown',
      _timestamp: data.timestamp
    };

    // Emit using the same event name the dashboard already subscribes to
    const event = new CustomEvent('agentos:statsUpdate', { detail: mappedStats });
    window.dispatchEvent(event);

    // Also emit a dedicated social-metrics event for future panels
    const socialEvent = new CustomEvent('composio:socialMetrics', { detail: data });
    window.dispatchEvent(socialEvent);
  }

  function enrichFeed(data) {
    if (!data || data.mode === lastData?.mode && data.timestamp === lastData?.timestamp) return;
    lastData = data;

    const messages = [];

    if (data.instagram?.instagramRecentMedia?.length) {
      const top = data.instagram.instagramRecentMedia[0];
      messages.push({
        time: new Date().toLocaleTimeString(),
        message: `Naledi: Instagram "${top.caption?.substring(0, 40)}..." — ${top.like_count} likes, ${top.comments_count} comments`
      });
    }

    if (data.googleAnalytics?.gaSessions7d) {
      messages.push({
        time: new Date().toLocaleTimeString(),
        message: `Analytics: ${data.googleAnalytics.gaSessions7d} sessions, ${data.googleAnalytics.gaPageViews7d} page views (7d)`
      });
    }

    if (data.whatsapp?.waMessages24h) {
      messages.push({
        time: new Date().toLocaleTimeString(),
        message: `DenchClaw: ${data.whatsapp.waMessages24h} WhatsApp messages handled in last 24h`
      });
    }

    messages.forEach(m => {
      const event = new CustomEvent('agentos:activity', { detail: m });
      window.dispatchEvent(event);
    });
  }

  async function tick() {
    const data = await fetchMetrics();
    if (data) {
      emitStatsUpdate(data);
      enrichFeed(data);
    }
  }

  function init() {
    console.log('[ComposioBridge] Initializing...');
    tick();
    setInterval(tick, POLL_INTERVAL_MS);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
