#!/usr/bin/env node
/**
 * fetch-social-metrics.js
 *
 * Fetches real social / analytics metrics via Composio SDK and writes
 * a JSON file consumed by the LAISA dashboard.
 *
 * PHASE 1 (NOW): Simulated data — realistic shapes, no API keys needed.
 * PHASE 2 (AFTER AUTH): Flip `mode` to "live" in composio-config.json.
 *
 * Usage:
 *   node scripts/fetch-social-metrics.js
 *
 * Requires (live mode):
 *   npm install @composio/core
 *   composio login
 *   composio link instagram
 *   composio link google-analytics
 *   composio link whatsapp
 */

const fs = require('fs');
const path = require('path');

const CONFIG_PATH = path.join(__dirname, 'composio-config.json');
const config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));

// ─── SIMULATED DATA GENERATOR ───
function generateSimulatedData() {
  const baseFollowers = 3847;
  const drift = Math.floor(Math.random() * 40) - 15; // -15 to +24
  const followers = baseFollowers + drift;

  const profileViews = 1240 + Math.floor(Math.random() * 200);
  const engagement = Math.floor(profileViews * (0.08 + Math.random() * 0.06));

  return {
    timestamp: new Date().toISOString(),
    mode: 'simulated',
    instagram: {
      instagramFollowers: followers,
      instagramProfileViews7d: profileViews,
      instagramEngagement7d: engagement,
      instagramRecentMedia: [
        {
          id: 'sim_001',
          caption: 'The Art of Aging Gracefully — Behind the scenes at LAISA',
          media_type: 'VIDEO',
          thumbnail_url: '',
          permalink: 'https://instagram.com/p/sim_001',
          like_count: 142,
          comments_count: 18,
          timestamp: new Date(Date.now() - 3600e3 * 2).toISOString()
        },
        {
          id: 'sim_002',
          caption: 'Skin Longevity: 3 non-negotiables every patient should know',
          media_type: 'IMAGE',
          thumbnail_url: '',
          permalink: 'https://instagram.com/p/sim_002',
          like_count: 89,
          comments_count: 7,
          timestamp: new Date(Date.now() - 3600e3 * 26).toISOString()
        },
        {
          id: 'sim_003',
          caption: 'Dr. Laisa on the science of collagen remodelling',
          media_type: 'REEL',
          thumbnail_url: '',
          permalink: 'https://instagram.com/p/sim_003',
          like_count: 210,
          comments_count: 31,
          timestamp: new Date(Date.now() - 3600e3 * 50).toISOString()
        }
      ]
    },
    googleAnalytics: {
      gaSessions7d: 412 + Math.floor(Math.random() * 60),
      gaPageViews7d: 1380 + Math.floor(Math.random() * 200),
      gaTopPages: [
        { path: '/', views: 342 },
        { path: '/services/facial-rejuvenation', views: 128 },
        { path: '/book-consultation', views: 97 },
        { path: '/about-dr-laisa', views: 84 },
        { path: '/pricing', views: 61 }
      ]
    },
    whatsapp: {
      waMessages24h: 12 + Math.floor(Math.random() * 8),
      waConversations24h: 4 + Math.floor(Math.random() * 3)
    }
  };
}

// ─── LIVE DATA FETCHER (Composio SDK) ───
async function fetchLiveData() {
  // Lazy-load SDK so simulated mode has zero dependencies
  const { Composio } = await import('@composio/core');
  const composio = new Composio();

  const results = {
    timestamp: new Date().toISOString(),
    mode: 'live'
  };

  for (const [sourceKey, sourceConfig] of Object.entries(config.accounts)) {
    const { toolkit, connectedAccountId, version, metrics } = sourceConfig;

    if (!connectedAccountId || !version) {
      console.warn(`[${sourceKey}] Skipped — no connectedAccountId or version configured.`);
      continue;
    }

    results[sourceKey] = {};

    for (const metric of metrics) {
      try {
        const response = await composio.tools.execute(metric.tool, {
          userId: connectedAccountId,
          arguments: resolveParams(metric.params, sourceConfig),
          version
        });

        if (response.successful) {
          results[sourceKey][metric.dashboardKey] = response.data;
          console.log(`[${sourceKey}] ${metric.dashboardKey}: OK`);
        } else {
          console.error(`[${sourceKey}] ${metric.dashboardKey}: ${response.error}`);
          results[sourceKey][metric.dashboardKey] = null;
        }
      } catch (err) {
        console.error(`[${sourceKey}] ${metric.dashboardKey}: ${err.message}`);
        results[sourceKey][metric.dashboardKey] = null;
      }
    }
  }

  return results;
}

// Resolve template params like {propertyId}
function resolveParams(params, sourceConfig) {
  return JSON.parse(
    JSON.stringify(params)
      .replace(/\{propertyId\}/g, sourceConfig.propertyId || '')
  );
}

// ─── MAIN ───
async function main() {
  const outPath = path.resolve(__dirname, '..', config.outputPath);

  let data;
  if (config.mode === 'live') {
    data = await fetchLiveData();
  } else {
    data = generateSimulatedData();
  }

  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, JSON.stringify(data, null, 2));

  console.log(`Wrote ${config.mode} social metrics to ${outPath}`);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
