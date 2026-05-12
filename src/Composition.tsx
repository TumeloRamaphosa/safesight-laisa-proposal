import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Sequence,
} from "remotion";

/* ──────────────────────────────────────────────
   SafeSight × LAISA — Experiential Proposal
   Obsidian-gold cinematic landing page
   StudEx Group Design System
   ────────────────────────────────────────────── */

const GOLD = "#C9A84C";
const OBSIDIAN = "#0A0A0A";
const DARK_SURFACE = "#111111";
const MID_SURFACE = "#1A1A1A";
const LIGHT_TEXT = "#F5F0E8";
const MUTED_TEXT = "#8A8578";

// ─── Utility hooks ───
function useFadeIn(delay: number, duration: number = 15) {
  const frame = useCurrentFrame();
  return interpolate(frame - delay, [0, duration], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
}

function useSlideUp(delay: number, distance: number = 40) {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const sp = spring({
    frame: Math.max(0, frame - delay),
    fps,
    config: { damping: 22, stiffness: 120, mass: 0.8 },
  });
  const opacity = interpolate(frame - delay, [0, 10], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return {
    opacity,
    transform: `translateY(${interpolate(sp, [0, 1], [distance, 0])}px)`,
  };
}

// ─── Section Components ───

function HeroSection() {
  const frame = useCurrentFrame();
  const titleOpacity = useFadeIn(10);
  const ctaOpacity = useFadeIn(55);
  const lineScale = interpolate(frame, [0, 30], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const subtitleSlide = useSlideUp(30, 30);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: OBSIDIAN,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: "0 10%",
      }}
    >
      {/* Decorative gold line */}
      <div
        style={{
          width: 80,
          height: 1,
          backgroundColor: GOLD,
          transform: `scaleX(${lineScale})`,
          marginBottom: 40,
        }}
      />

      {/* Main title */}
      <div
        style={{
          fontFamily: "'Bebas Neue', Impact, sans-serif",
          fontSize: 72,
          color: GOLD,
          letterSpacing: 8,
          textTransform: "uppercase",
          opacity: titleOpacity,
          textAlign: "center",
          lineHeight: 1.1,
        }}
      >
        SafeSight × LAISA
      </div>

      {/* Subtitle */}
      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 26,
          color: LIGHT_TEXT,
          opacity: subtitleSlide.opacity,
          transform: subtitleSlide.transform,
          marginTop: 20,
          textAlign: "center",
          letterSpacing: 2,
          fontWeight: 300,
        }}
      >
        Digital Transformation Proposal
      </div>

      {/* Tagline */}
      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 18,
          color: MUTED_TEXT,
          opacity: ctaOpacity,
          marginTop: 30,
          textAlign: "center",
          letterSpacing: 1,
        }}
      >
        Powered by StudEx Group — May 2026
      </div>

      {/* Bottom accent */}
      <div
        style={{
          position: "absolute",
          bottom: 60,
          left: "50%",
          transform: `translateX(-50%) translateY(${interpolate(
            frame,
            [50, 80],
            [20, 0],
            { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
          )}px)`,
          opacity: interpolate(frame, [50, 80], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 8,
        }}
      >
        <div
          style={{
            fontFamily: "'Space Mono', monospace",
            fontSize: 10,
            color: MUTED_TEXT,
            letterSpacing: 4,
            textTransform: "uppercase",
          }}
        >
          Scroll to explore
        </div>
        <div
          style={{
            width: 1,
            height: 30,
            background: `linear-gradient(to bottom, ${GOLD}, transparent)`,
          }}
        />
      </div>
    </AbsoluteFill>
  );
}

function ProblemSection() {
  const headingSlide = useSlideUp(5, 50);
  const stat1 = useSlideUp(25, 40);
  const stat2 = useSlideUp(40, 40);
  const stat3 = useSlideUp(55, 40);
  const ctaSlide = useSlideUp(80, 30);

  const stats = [
    { value: "R88,000+", label: "Lost every month to manual processes", slide: stat1 },
    { value: "6.5 hrs", label: "Wasted daily on tasks that should run themselves", slide: stat2 },
    { value: "20%", label: "Patient no-show rate — with zero automated reminders", slide: stat3 },
  ];

  return (
    <AbsoluteFill
      style={{
        backgroundColor: DARK_SURFACE,
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        padding: "8% 10%",
      }}
    >
      <div
        style={{
          fontFamily: "'Space Mono', monospace",
          fontSize: 10,
          color: GOLD,
          letterSpacing: 6,
          textTransform: "uppercase",
          opacity: headingSlide.opacity,
          transform: headingSlide.transform,
          marginBottom: 20,
        }}
      >
        The Problem
      </div>

      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 38,
          color: LIGHT_TEXT,
          lineHeight: 1.3,
          opacity: headingSlide.opacity,
          transform: headingSlide.transform,
          maxWidth: 700,
        }}
      >
        Your team of 14 is carrying the weight of operations that should run themselves.
      </div>

      <div
        style={{
          display: "flex",
          flexDirection: "row",
          gap: 50,
          marginTop: 50,
          flexWrap: "wrap",
        }}
      >
        {stats.map((stat, i) => (
          <div
            key={i}
            style={{
              opacity: stat.slide.opacity,
              transform: stat.slide.transform,
            }}
          >
            <div
              style={{
                fontFamily: "'Bebas Neue', Impact, sans-serif",
                fontSize: 56,
                color: GOLD,
                letterSpacing: 2,
              }}
            >
              {stat.value}
            </div>
            <div
              style={{
                fontFamily: "'Cormorant Garamond', Georgia, serif",
                fontSize: 16,
                color: MUTED_TEXT,
                maxWidth: 200,
                lineHeight: 1.4,
                marginTop: 4,
              }}
            >
              {stat.label}
            </div>
          </div>
        ))}
      </div>

      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 18,
          color: MUTED_TEXT,
          opacity: ctaSlide.opacity,
          transform: ctaSlide.transform,
          marginTop: 50,
          fontStyle: "italic",
          maxWidth: 600,
        }}
      >
        That's over R1,000,000 per year walking out the door — not because your team
        isn't working hard, but because your systems aren't working for you.
      </div>
    </AbsoluteFill>
  );
}

function PhaseCard({
  number,
  title,
  subtitle,
  items,
  delay,
  investment,
}: {
  number: string;
  title: string;
  subtitle: string;
  items: string[];
  delay: number;
  investment: string;
}) {
  const frame = useCurrentFrame();
  const cardSlide = useSlideUp(delay, 40);
  const lineGrow = interpolate(Math.max(0, frame - delay - 10), [0, 20], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        opacity: cardSlide.opacity,
        transform: cardSlide.transform,
        backgroundColor: MID_SURFACE,
        borderLeft: `2px solid ${GOLD}`,
        padding: "30px 35px",
        maxWidth: 380,
      }}
    >
      <div
        style={{
          fontFamily: "'Bebas Neue', Impact, sans-serif",
          fontSize: 14,
          color: GOLD,
          letterSpacing: 4,
          textTransform: "uppercase",
        }}
      >
        {number}
      </div>
      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 26,
          color: LIGHT_TEXT,
          marginTop: 8,
          fontWeight: 600,
        }}
      >
        {title}
      </div>
      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 14,
          color: MUTED_TEXT,
          marginTop: 4,
          fontStyle: "italic",
        }}
      >
        {subtitle}
      </div>

      <div
        style={{
          width: 40,
          height: 1,
          backgroundColor: GOLD,
          marginTop: 16,
          marginBottom: 16,
          transform: `scaleX(${lineGrow})`,
          transformOrigin: "left",
        }}
      />

      {items.map((item, i) => (
        <div
          key={i}
          style={{
            fontFamily: "'Cormorant Garamond', Georgia, serif",
            fontSize: 14,
            color: LIGHT_TEXT,
            lineHeight: 1.6,
            opacity: 0.9,
          }}
        >
          {item}
        </div>
      ))}

      <div
        style={{
          fontFamily: "'Space Mono', monospace",
          fontSize: 12,
          color: GOLD,
          marginTop: 16,
          letterSpacing: 1,
        }}
      >
        {investment}
      </div>
    </div>
  );
}

function TransformationSection() {
  const headingSlide = useSlideUp(5, 50);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: OBSIDIAN,
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        padding: "6% 10%",
      }}
    >
      <div
        style={{
          fontFamily: "'Space Mono', monospace",
          fontSize: 10,
          color: GOLD,
          letterSpacing: 6,
          textTransform: "uppercase",
          opacity: headingSlide.opacity,
          transform: headingSlide.transform,
          marginBottom: 20,
        }}
      >
        The Transformation
      </div>

      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 36,
          color: LIGHT_TEXT,
          lineHeight: 1.3,
          opacity: headingSlide.opacity,
          transform: headingSlide.transform,
          maxWidth: 700,
        }}
      >
        Three phases. Gradual, not disruptive. You see results before committing to the next step.
      </div>

      <div
        style={{
          display: "flex",
          flexDirection: "row",
          gap: 30,
          marginTop: 40,
          flexWrap: "wrap",
        }}
      >
        <PhaseCard
          number="Phase 1"
          title="Digital Foundation"
          subtitle="Weeks 1–8"
          items={[
            "✦ Patient Management System — digital records",
            "✦ WhatsApp AI Booking Bot — 24/7",
            "✦ Automated Reminders — 24h + 2h",
            "✦ Digital Intake Forms — QR + tablet",
            "✦ System Integration — all connected",
          ]}
          delay={20}
          investment="R25,000"
        />
        <PhaseCard
          number="Phase 2"
          title="Smart Operations"
          subtitle="Weeks 5–14"
          items={[
            "✦ Workflow Automation — 10+ workflows",
            "✦ AI Content Engine — 3 posts/day",
            "✦ Medical Aid Verification — automated",
            "✦ Automated Billing — invoice to Sage",
            "✦ Follow-Up Sequences — 100% coverage",
          ]}
          delay={40}
          investment="R35,000"
        />
        <PhaseCard
          number="Phase 3"
          title="Intelligent Practice"
          subtitle="Weeks 10–24"
          items={[
            "✦ AI Chatbot — 70%+ queries handled",
            "✦ Revenue Dashboard — real-time",
            "✦ Doctor Support Tools — AI summaries",
            "✦ Predictive Scheduling — <5% no-show",
            "✦ Strategic Intelligence — monthly reports",
          ]}
          delay={60}
          investment="R40,000"
        />
      </div>
    </AbsoluteFill>
  );
}

function ROISection() {
  const headingSlide = useSlideUp(5, 50);
  const row1 = useSlideUp(30, 30);
  const row2 = useSlideUp(40, 30);
  const row3 = useSlideUp(50, 30);
  const row4 = useSlideUp(60, 30);
  const row5 = useSlideUp(70, 30);
  const ctaSlide = useSlideUp(90, 30);

  const metrics = [
    { before: "15 min/patient", after: "1 min/patient", label: "Booking Time", slide: row1 },
    { before: "~20%", after: "~5%", label: "No-Show Rate", slide: row2 },
    { before: "6.5 hrs/day", after: "<1 hr/day", label: "Admin Hours", slide: row3 },
    { before: "R88K loss/mo", after: "R170K gain/mo", label: "Monthly Impact", slide: row4 },
    { before: "0% automated", after: "85% automated", label: "Automation Level", slide: row5 },
  ];

  return (
    <AbsoluteFill
      style={{
        backgroundColor: DARK_SURFACE,
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        padding: "6% 12%",
      }}
    >
      <div
        style={{
          fontFamily: "'Space Mono', monospace",
          fontSize: 10,
          color: GOLD,
          letterSpacing: 6,
          textTransform: "uppercase",
          opacity: headingSlide.opacity,
          transform: headingSlide.transform,
        }}
      >
        The Numbers
      </div>

      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 34,
          color: LIGHT_TEXT,
          lineHeight: 1.3,
          opacity: headingSlide.opacity,
          transform: headingSlide.transform,
          marginTop: 12,
          maxWidth: 600,
        }}
      >
        Break-even in Month 1. Annual net return: R798,000.
      </div>

      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: 20,
          marginTop: 40,
          maxWidth: 800,
        }}
      >
        {metrics.map((metric, i) => (
          <div
            key={i}
            style={{
              display: "flex",
              flexDirection: "row",
              alignItems: "center",
              gap: 20,
              opacity: metric.slide.opacity,
              transform: metric.slide.transform,
            }}
          >
            <div
              style={{
                fontFamily: "'Cormorant Garamond', Georgia, serif",
                fontSize: 14,
                color: MUTED_TEXT,
                width: 140,
                textAlign: "right",
              }}
            >
              {metric.label}
            </div>
            <div
              style={{
                fontFamily: "'Space Mono', monospace",
                fontSize: 14,
                color: "#C75050",
                width: 130,
              }}
            >
              {metric.before}
            </div>
            <div
              style={{
                fontSize: 16,
                color: GOLD,
              }}
            >
              →
            </div>
            <div
              style={{
                fontFamily: "'Space Mono', monospace",
                fontSize: 14,
                color: GOLD,
                width: 130,
              }}
            >
              {metric.after}
            </div>
          </div>
        ))}
      </div>

      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 20,
          color: GOLD,
          opacity: ctaSlide.opacity,
          transform: ctaSlide.transform,
          marginTop: 40,
          fontStyle: "italic",
          maxWidth: 600,
        }}
      >
        Total investment: R85,000. Monthly impact after Phase 3: R280,000. This is not a cost — it is the most profitable investment your practice can make this year.
      </div>
    </AbsoluteFill>
  );
}

function ClosingSection() {
  const frame = useCurrentFrame();
  const headingSlide = useSlideUp(5, 50);
  const bodySlide = useSlideUp(25, 40);
  const ctaSlide = useSlideUp(50, 30);
  const lineGrow = interpolate(frame, [10, 40], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: OBSIDIAN,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: "0 12%",
      }}
    >
      {/* Gold line */}
      <div
        style={{
          width: 60,
          height: 1,
          backgroundColor: GOLD,
          transform: `scaleX(${lineGrow})`,
          marginBottom: 40,
        }}
      />

      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 36,
          color: LIGHT_TEXT,
          textAlign: "center",
          lineHeight: 1.4,
          opacity: headingSlide.opacity,
          transform: headingSlide.transform,
          maxWidth: 700,
        }}
      >
        The first step is a discovery session.
      </div>

      <div
        style={{
          fontFamily: "'Cormorant Garamond', Georgia, serif",
          fontSize: 20,
          color: MUTED_TEXT,
          textAlign: "center",
          lineHeight: 1.6,
          opacity: bodySlide.opacity,
          transform: bodySlide.transform,
          maxWidth: 600,
          marginTop: 20,
        }}
      >
        We walk your practice. Meet your team. Map your workflows.
        Half a day. No cost. No obligation.
      </div>

      {/* CTA Box */}
      <div
        style={{
          opacity: ctaSlide.opacity,
          transform: ctaSlide.transform,
          marginTop: 50,
          padding: "20px 60px",
          border: `1px solid ${GOLD}`,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <div
          style={{
            fontFamily: "'Bebas Neue', Impact, sans-serif",
            fontSize: 18,
            color: GOLD,
            letterSpacing: 6,
            textTransform: "uppercase",
          }}
        >
          Book Discovery Session
        </div>
      </div>

      {/* Contact info */}
      <div
        style={{
          fontFamily: "'Space Mono', monospace",
          fontSize: 11,
          color: MUTED_TEXT,
          textAlign: "center",
          marginTop: 60,
          letterSpacing: 2,
        }}
      >
        StudEx Group — Johannesburg, South Africa
      </div>

      <div
        style={{
          fontFamily: "'Space Mono', monospace",
          fontSize: 10,
          color: GOLD,
          textAlign: "center",
          marginTop: 8,
          letterSpacing: 3,
          opacity: 0.6,
        }}
      >
        BUILT WITH INTELLIGENCE. OPERATED WITH PRECISION.
      </div>
    </AbsoluteFill>
  );
}

// ─── Main Composition ───

export const SafeSightProposal: React.FC = () => {

  // Timing: each section gets ~5 seconds at 30fps = 150 frames per section
  // Total: 5 sections × 150 frames = 750 frames
  const SECTION_DURATION = 150;

  return (
    <AbsoluteFill style={{ backgroundColor: OBSIDIAN }}>
      <Sequence from={0} durationInFrames={SECTION_DURATION}>
        <HeroSection />
      </Sequence>
      <Sequence from={SECTION_DURATION} durationInFrames={SECTION_DURATION}>
        <ProblemSection />
      </Sequence>
      <Sequence from={SECTION_DURATION * 2} durationInFrames={SECTION_DURATION}>
        <TransformationSection />
      </Sequence>
      <Sequence from={SECTION_DURATION * 3} durationInFrames={SECTION_DURATION}>
        <ROISection />
      </Sequence>
      <Sequence from={SECTION_DURATION * 4} durationInFrames={SECTION_DURATION}>
        <ClosingSection />
      </Sequence>
    </AbsoluteFill>
  );
};

// Also export the original name for compatibility
export const MyComposition = SafeSightProposal;