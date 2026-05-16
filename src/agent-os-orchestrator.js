/**
 * Agentic OS Orchestrator
 * Powers the simulated live environment for SafeSight & LAISA Dashboards
 */

const AgentOrchestrator = {
  agents: [
    { id: 'denchclaw', name: 'DenchClaw', role: 'Patient Support', status: 'Active', task: 'Monitoring WhatsApp', model: 'Claude Haiku' },
    { id: 'cashclaw', name: 'CashClaw', role: 'Revenue & Billing', status: 'Idle', task: 'Sage Sync Pending', model: 'Claude Haiku' },
    { id: 'naledi', name: 'Naledi', role: 'Content Engine', status: 'Active', task: 'Generating IG Post', model: 'Claude Sonnet' },
    { id: 'charlie', name: 'Charlie', role: 'Voice Agent', status: 'Active', task: 'Reminder Call: J. Smith', model: 'ElevenLabs' },
    { id: 'robusca', name: 'Robusca', role: 'Clinic Coordinator', status: 'Active', task: 'Updating Daily Schedule', model: 'Claude Sonnet' },
    { id: 'general', name: 'General', role: 'Orchestrator', status: 'Active', task: 'Mission Dispatch', model: 'Claude Opus' }
  ],

  stats: {
    revenue: 45200,
    patientVolume: 24,
    socialEngagement: 1240,
    systemUptime: '99.98%'
  },

  init() {
    console.log('Agentic OS Orchestrator Initialized');
    this.startLiveFeed();
    this.updateStats();
    this.setupEventListeners();
  },

  setupEventListeners() {
    window.addEventListener('agentos:action', (e) => {
      console.log('Agent Action Requested:', e.detail);
      // Simulate action response
      setTimeout(() => {
        this.broadcast('activity', { 
          message: `System: Action '${e.detail.action}' executed successfully by ${e.detail.agent || 'Orchestrator'}`, 
          time: new Date().toLocaleTimeString() 
        });
      }, 1000);
    });
  },

  startLiveFeed() {
    const activities = [
      "DenchClaw: Confirmed booking for Sarah Jenkins (LASIK)",
      "CashClaw: Medical aid verified for Peter Marais",
      "Naledi: Scheduled '3 Tips for Post-Op Care' for 14:00",
      "Charlie: Call completed - Amahle Dlamini confirmed",
      "Robusca: Daily schedule synced to Obsidian",
      "CTO: Orgo VM health check passed",
      "SkunkWorks: Deployment of n8n v2.4 successful",
      "CashClaw: Generated payment link for invoice #8892",
      "DenchClaw: FAQ answered - 'Recovery time for Cataracts'",
      "Naledi: Content ingested from Higgsfield AI pipeline"
    ];

    setInterval(() => {
      const activity = activities[Math.floor(Math.random() * activities.length)];
      this.broadcast('activity', { message: activity, time: new Date().toLocaleTimeString() });
      
      // Randomly change agent status
      const agent = this.agents[Math.floor(Math.random() * this.agents.length)];
      agent.status = Math.random() > 0.2 ? 'Active' : 'Thinking';
      this.broadcast('agentUpdate', agent);
    }, 4000);
  },

  updateStats() {
    setInterval(() => {
      this.stats.revenue += Math.floor(Math.random() * 500);
      this.stats.patientVolume += Math.random() > 0.8 ? 1 : 0;
      this.stats.socialEngagement += Math.floor(Math.random() * 10);
      this.broadcast('statsUpdate', this.stats);
    }, 8000);
  },

  broadcast(type, data) {
    const event = new CustomEvent('agentos:' + type, { detail: data });
    window.dispatchEvent(event);
  }
};

// Start the orchestrator when the DOM is ready
document.addEventListener('DOMContentLoaded', () => AgentOrchestrator.init());
