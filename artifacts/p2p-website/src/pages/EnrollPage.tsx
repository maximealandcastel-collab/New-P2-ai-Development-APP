import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Crown, Dumbbell, Check, Lock, ShieldCheck, Loader2, Sparkles,
  ChevronRight, ArrowLeft, Star, Zap, Tag, AlertCircle, Users, FlaskConical,
  Copy, CheckCheck,
} from "lucide-react";
import { useLocation } from "wouter";

const API = import.meta.env.BASE_URL?.replace(/\/p2p-website\/?$/, "") || "";

type Plan = "three_months" | "annual" | "affiliate" | "trial_access" | "enterprise_core" | "enterprise_elite";

const PLANS = [
  {
    id: "enterprise_core" as Plan,
    label: "Enterprise Starter",
    price: "$49.99",
    priceRaw: "$49.99/mo",
    period: "per month",
    sub: "Launch your gym on P2P FitTech AI",
    icon: Users,
    benefits: [
      "Gym listing and ownership verification",
      "Gym administrator access",
      "Member and trainer onboarding",
      "P2P team setup support",
    ],
    cta: "Start Enterprise Starter →",
    highlight: false,
  },
  {
    id: "enterprise_elite" as Plan,
    label: "Enterprise Pro",
    price: "$305.99",
    priceRaw: "$305.99/mo",
    period: "per month",
    sub: "The full personalized white-label gym experience",
    icon: Crown,
    benefits: [
      "Everything in Enterprise Starter",
      "Custom gym branding and theme",
      "Full member, trainer, and admin dashboards",
      "Personalized activation with the P2P team",
    ],
    cta: "Start Enterprise Pro →",
    highlight: true,
    badge: "FULL WHITE-LABEL",
  },
  {
    id: "trial_access" as Plan,
    label: "7-Day Trial",
    price: "$4.99",
    priceRaw: "$4.99",
    period: "one-time · 7 days full access",
    sub: "Try before you commit — build your workout split today",
    icon: FlaskConical,
    benefits: [
      "AI workout split builder powered by Claude",
      "Live trainer video call preview session",
      "Unlock the app with this same login after trial",
      "No subscription — just $4.99 once",
    ],
    cta: "Start 7-Day Trial →",
    highlight: false,
    badge: "TRY FIRST",
  },
  {
    id: "three_months" as Plan,
    label: "3-Month Access",
    price: "$19.99",
    priceRaw: "$19.99",
    period: "3 months",
    sub: "Start training with AI — no long commitment",
    icon: Dumbbell,
    benefits: [
      "Personalized AI coaching every day",
      "Stay accountable and track your transformation",
      "Adaptive workouts that evolve with you",
      "AI chatbot available 24/7",
    ],
    cta: "Start My Transformation →",
    highlight: false,
  },
  {
    id: "annual" as Plan,
    label: "Founding Member",
    price: "$120",
    priceRaw: "$120/yr",
    period: "per year — just $10/mo",
    sub: "Lock in the founding price before it's gone",
    icon: Crown,
    benefits: [
      "Full year of elite AI coaching — never restart",
      "Memory Training — AI remembers your history",
      "Private Discord Community access",
      "Priority access to every new feature",
      "Founding price locked forever",
    ],
    cta: "Become a Founding Member →",
    highlight: true,
    badge: "MOST POPULAR",
  },
];

// ── Main Page ─────────────────────────────────────────────────────────────────
export default function EnrollPage({ defaultPlan }: { defaultPlan?: Plan }) {
  const [, navigate] = useLocation();
  const [step, setStep] = useState<1 | 2 | 3 | 4>(defaultPlan ? 2 : 1);
  const [plan, setPlan] = useState<Plan | null>(defaultPlan ?? null);
  const [form, setForm] = useState({ firstName: "", lastName: "", email: "", phone: "" });
  const [formError, setFormError] = useState("");
  const [submitLoading, setSubmitLoading] = useState(false);

  const [affiliateInput, setAffiliateInput] = useState("");
  const [affiliateLoading, setAffiliateLoading] = useState(false);
  const [affiliateError, setAffiliateError] = useState("");
  const [affiliateUnlocked, setAffiliateUnlocked] = useState<{ code: string; name: string } | null>(null);
  const [showAffiliateField, setShowAffiliateField] = useState(false);

  // ── Clover card payment ────────────────────────────────────────────────────
  const [cloverReady, setCloverReady]     = useState(false);
  const [cloverLoading, setCloverLoading] = useState(false);
  const [cloverError, setCloverError]     = useState("");
  const [promoCode, setPromoCode]         = useState<string | null>(null);
  const [promoDurationLabel, setPromoDurationLabel] = useState<string | null>(null);
  const [codeCopied, setCodeCopied]       = useState(false);
  const cloverRef     = useRef<any>(null);
  // Track per-field validity from Clover change events
  const fieldValidity = useRef<Record<string, boolean>>({
    CARD_NUMBER: false, CARD_DATE: false, CARD_CVV: false, CARD_POSTAL_CODE: false,
  });

  const selectedPlan = plan === "affiliate"
    ? { id: "affiliate" as Plan, label: "Affiliate Access", price: "$10", priceRaw: "$10", period: "6 months", sub: "Exclusive affiliate rate", benefits: ["6 months full access", "AI Personal Trainer", "AI Chatbot", "Goal-based workouts", "Real-time progress tracking"], cta: "Unlock My AI Coach →", highlight: false }
    : (plan ? PLANS.find(p => p.id === plan) ?? null : null);

  const isTrialPlan = plan === "trial_access";
  const isEnterprisePlan = plan === "enterprise_core" || plan === "enterprise_elite";

  // ── Load Clover iframe SDK when user reaches Step 3 ───────────────────────
  const [cloverInitKey, setCloverInitKey] = useState(0); // bump to retry
  const [promoInput, setPromoInput]       = useState("");
  const [promoOpen, setPromoOpen]         = useState(false);

  useEffect(() => {
    if (step !== 3) return;
    setCloverReady(false);
    setCloverError("");
    cloverRef.current = null;

    async function initClover() {
      // 1. Poll until Clover iframe containers are actually in the DOM.
      //    AnimatePresence mode="wait" holds Step 3 back until Step 2's exit
      //    animation finishes, so a fixed RAF delay isn't reliable here.
      await new Promise<void>((resolve, reject) => {
        const deadline = Date.now() + 4000;
        function check() {
          if (document.querySelector("#clover-card-number")) { resolve(); return; }
          if (Date.now() > deadline) { reject(new Error("Payment form took too long to load. Please refresh.")); return; }
          requestAnimationFrame(check);
        }
        requestAnimationFrame(check);
      });

      // 2. Fetch public config first — it tells us which SDK environment to load
      const cfg = await fetch(`${API}/api/clover/config`).then(r => r.json()) as { publishableKey: string; merchantId: string; env?: string };
      if (!cfg.publishableKey) throw new Error("Payment configuration is missing. Please contact support.");

      // 3. Pick the correct SDK URL based on the environment the backend reports
      const CLOVER_SDK = cfg.env === "sandbox"
        ? "https://checkout.sandbox.clover.com/sdk.js"
        : "https://checkout.clover.com/sdk.js";

      // 4. Ensure SDK script is loaded (remove stale tag on env change so browser re-fetches)
      const existingTag = document.querySelector("script[data-clover-sdk]");
      if (!(window as any).Clover || (existingTag && existingTag.getAttribute("src") !== CLOVER_SDK)) {
        if (existingTag) { existingTag.remove(); delete (window as any).Clover; }
        await new Promise<void>((resolve, reject) => {
          const s = document.createElement("script");
          s.src = CLOVER_SDK;
          s.setAttribute("data-clover-sdk", "1");
          s.onload  = () => resolve();
          s.onerror = () => reject(new Error("Could not load the Clover payment SDK. Check your network and try again."));
          document.head.appendChild(s);
        });
      }

      // 4. Verify the Clover global is available
      const CloverSDK = (window as any).Clover;
      if (typeof CloverSDK !== "function") throw new Error("Clover SDK failed to initialise (window.Clover not found).");

      // 5. Create Clover instance — pass only the publishable key (merchantId via options
      //    is optional and some SDK versions reject it)
      const clover   = new CloverSDK(cfg.publishableKey);
      const elements = clover.elements();

      // Reset field validity for this session
      fieldValidity.current = {
        CARD_NUMBER: false, CARD_DATE: false, CARD_CVV: false, CARD_POSTAL_CODE: false,
      };

      // Pass height + line-height so the input fills the full container and text is vertically centred
      const iframeStyle = {
        body:  {
          margin: "0",
          padding: "0",
          height: "100%",
          overflow: "hidden",
          background: "#f9fafb",
        },
        input: {
          "font-size":   "16px",
          "font-family": "inherit",
          "font-weight": "500",
          color:         "#111827",
          "background-color": "#f9fafb",
          border:        "none",
          outline:       "none",
          "border-radius": "0",
          height:        "52px",
          "line-height": "52px",
          padding:       "0 16px",
          width:         "100%",
          "box-sizing":  "border-box",
        },
      };

      const FIELDS: Array<[string, string]> = [
        ["CARD_NUMBER",      "#clover-card-number"],
        ["CARD_DATE",        "#clover-card-date"],
        ["CARD_CVV",         "#clover-card-cvv"],
        ["CARD_POSTAL_CODE", "#clover-card-postal-code"],
      ];

      for (const [type, selector] of FIELDS) {
        const container = document.querySelector(selector);
        if (!container) throw new Error(`Payment form element not found (${selector}). Please refresh.`);
        const el = elements.create(type, { styles: iframeStyle });
        el.mount(selector);
        el.addEventListener("change", (ev: any) => {
          fieldValidity.current[type] = !!ev?.complete;
          setCloverError("");
        });
      }

      cloverRef.current = clover;
      setCloverReady(true);
    }

    initClover().catch(err => {
      console.error("[Clover] init error:", err);
      setCloverError(err?.message || "Failed to load payment form. Please try again.");
    });
  }, [step, cloverInitKey]);

  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setForm(prev => ({ ...prev, [k]: e.target.value }));

  async function validateAffiliate() {
    const code = affiliateInput.trim().toUpperCase();
    if (!code) { setAffiliateError("Enter your affiliate code"); return; }
    setAffiliateError(""); setAffiliateLoading(true);
    try {
      const res = await fetch(`${API}/api/affiliates/validate-referral-code`, {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ code }),
      });
      const data = await res.json();
      if (data.valid) {
        setAffiliateUnlocked({ code: data.code, name: data.name });
        setPlan("affiliate"); setAffiliateError(""); setShowAffiliateField(false);
      } else { setAffiliateError(data.error || "Invalid affiliate code"); setAffiliateUnlocked(null); }
    } catch { setAffiliateError("Could not validate code. Try again."); }
    finally { setAffiliateLoading(false); }
  }

  // Step 2 → Step 3: validate info then show card payment
  function goToPayment() {
    const emailOk = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email.trim());
    if (!form.firstName.trim()) { setFormError("Please enter your first name."); return; }
    if (!form.email.trim() || !emailOk) { setFormError("Please enter a valid email address (e.g. you@gmail.com)."); return; }
    setFormError("");
    setStep(3);
  }

  // Step 3: tokenize card via Clover iframe, then charge backend
  async function payWithClover() {
    if (!cloverRef.current || !cloverReady || cloverLoading) return;

    setCloverLoading(true);
    setCloverError("");
    try {
      const result = await cloverRef.current.createToken();


      // Clover SDK returns errors as an object keyed by field name,
      // values can be strings OR { message: "..." } objects
      const hasErrors = result.errors && Object.keys(result.errors).length > 0;
      if (hasErrors) {
        const msgs = Object.values(result.errors)
          .map((e: any) => (typeof e === "string" ? e : e?.message ?? String(e)))
          .filter(Boolean)
          .join(" · ");
        setCloverError(msgs || "Please check your card details and try again.");
        return;
      }

      const cardToken = result.token;
      if (!cardToken) {
        // Surface whatever Clover actually returned so we can debug

        setCloverError("Card tokenization failed — please double-check your card details and try again.");
        return;
      }

      const applicationId = new URLSearchParams(window.location.search).get("applicationId");
      const attemptStorageKey = `p2p-checkout:${plan}:${form.email.trim().toLowerCase()}:${applicationId || ""}`;
      let idempotencyKey = sessionStorage.getItem(attemptStorageKey);
      if (!idempotencyKey) {
        idempotencyKey = crypto.randomUUID();
        sessionStorage.setItem(attemptStorageKey, idempotencyKey);
      }
      const res = await fetch(`${API}/api/clover/checkout`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          token: cardToken,
          idempotencyKey,
          applicationId,
          plan,
          email: form.email.trim(),
          name: `${form.firstName.trim()} ${form.lastName.trim()}`.trim(),
          phone: form.phone.trim() || undefined,
          promoCode: promoInput.trim() || undefined,
        }),
      });
      const data = await res.json();
      if (!res.ok || !data.success) { setCloverError(data.error || "Payment failed. Please try again."); return; }
      if (data.deliveryPending) {
        setCloverError("Payment received. Access confirmation is pending. Retry here using this same checkout; you will not be charged again.");
        return;
      }
      setPromoCode(data.promoCode ?? null);
      setPromoDurationLabel(data.durationLabel ?? null);
      setStep(4);
    } catch {
      setCloverError("Connection error. Please check your connection and try again.");
    } finally {
      setCloverLoading(false);
    }
  }

  const inputClass = "w-full rounded-2xl px-4 text-[16px] text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#FF6B00]/30 transition font-medium";
  const inputStyle: React.CSSProperties = { background: "#f9fafb", border: "1.5px solid #e5e7eb", height: 52, display: "flex", alignItems: "center" };
  const hostedFieldStyle: React.CSSProperties = { ...inputStyle, borderRadius: 16, overflow: "hidden", padding: 0 };
  const labelClass = "block text-xs font-black text-gray-500 uppercase tracking-widest mb-2";

  return (
    <div className="min-h-screen bg-white">
      {/* ── Top nav ── */}
      <div className="sticky top-0 z-50 bg-white/95 backdrop-blur border-b border-gray-100">
        <div className="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
          <button
            onClick={() => step > 1 ? setStep(s => (s - 1) as 1 | 2 | 3 | 4) : navigate("/")}
            className="flex items-center gap-2 text-gray-400 hover:text-gray-700 font-bold text-sm transition"
          >
            <ArrowLeft className="w-4 h-4" />
            {step === 1 ? "Back to home" : "Back"}
          </button>

          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-lg bg-[#FF6B00] flex items-center justify-center">
              <Zap className="w-4 h-4 text-white" fill="currentColor" />
            </div>
            <span className="font-black text-gray-900 text-sm">P2P FitTech AI</span>
          </div>

          {/* Step indicator */}
          <div className="flex items-center gap-2">
            {[1, 2, 3].map(n => (
              <div key={n} className="flex items-center gap-2">
                <div
                  className="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-black transition-all"
                  style={{
                    background: step > n ? "#FF6B00" : step === n ? "#FF6B00" : "#f1f5f9",
                    color: step >= n ? "#fff" : "#9ca3af",
                  }}
                >
                  {step > n ? <Check className="w-3 h-3" strokeWidth={3} /> : n}
                </div>
                {n < 3 && <div className="w-6 h-px" style={{ background: step > n ? "#FF6B00" : "#e5e7eb" }} />}
              </div>
            ))}
          </div>
        </div>
      </div>

      <AnimatePresence mode="wait">

        {/* ────────────────────────────────────────────────────────────────
            STEP 1 — Plan Selection
        ──────────────────────────────────────────────────────────────── */}
        {step === 1 && (
          <motion.div key="step1" initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -20 }}>

            {/* Hero */}
            <div className="text-center pt-20 pb-16 px-6">
              <div className="inline-flex items-center gap-2 bg-[#fff7ed] text-[#FF6B00] px-4 py-2 rounded-full text-xs font-black tracking-widest uppercase mb-6 border border-[#fed7aa]">
                <Star className="w-3 h-3" fill="currentColor" /> Early Access · Founding Pricing
              </div>
              <h1 className="text-5xl md:text-6xl font-black text-gray-900 leading-tight mb-4 tracking-tight">
                Choose your<br />
                <span style={{ color: "#FF6B00" }}>transformation</span>
              </h1>
              <p className="text-lg text-gray-500 max-w-xl mx-auto leading-relaxed">
                AI-powered personal training built around your goals.<br />No trainers. No gyms. Just results.
              </p>

              {/* Social proof */}
              <div className="flex items-center justify-center gap-3 mt-8">
                <div className="flex -space-x-2">
                  {["#FF6B00", "#f97316", "#fb923c", "#fdba74"].map((c, i) => (
                    <div key={i} className="w-8 h-8 rounded-full border-2 border-white flex items-center justify-center text-white text-[9px] font-black" style={{ background: c }}>P</div>
                  ))}
                </div>
                <div className="text-left">
                  <div className="flex gap-0.5 mb-0.5">
                    {[1, 2, 3, 4, 5].map(i => <Star key={i} className="w-3 h-3 text-[#FF6B00]" fill="currentColor" />)}
                  </div>
                  <p className="text-xs font-bold text-gray-600">Trusted by members building real transformations</p>
                </div>
              </div>
            </div>

            {/* Plan cards */}
            <div className="max-w-4xl mx-auto px-6 pb-24">
              <div className="grid md:grid-cols-2 gap-6">
                {PLANS.map(p => {
                  const Icon = p.icon;
                  return (
                    <motion.div
                      key={p.id}
                      whileHover={{ y: -4 }}
                      className="relative rounded-3xl p-8 flex flex-col cursor-pointer transition-all"
                      style={{
                        border: p.highlight ? "2px solid #FF6B00" : "2px solid #e5e7eb",
                        background: p.highlight ? "linear-gradient(135deg,#fff 0%,#fff7ed 100%)" : "#fff",
                        boxShadow: p.highlight ? "0 16px 48px rgba(255,107,0,0.12)" : "0 4px 16px rgba(0,0,0,0.04)",
                      }}
                      onClick={() => { setPlan(p.id); setStep(2); }}
                    >
                      {p.badge && (
                        <div className="absolute -top-3.5 left-1/2 -translate-x-1/2 px-4 py-1.5 rounded-full text-white text-[10px] font-black tracking-widest uppercase shadow-lg" style={{ background: "#FF6B00" }}>
                          ⭐ {p.badge}
                        </div>
                      )}

                      <div className="flex items-center gap-3 mb-6">
                        <div className="w-12 h-12 rounded-2xl flex items-center justify-center shadow-sm" style={{ background: p.highlight ? "#FF6B00" : "#f3f4f6" }}>
                          <Icon className="w-6 h-6" style={{ color: p.highlight ? "#fff" : "#6b7280" }} />
                        </div>
                        <div>
                          <div className="font-black text-gray-900 text-lg leading-tight">{p.label}</div>
                          <div className="text-sm text-gray-400 mt-0.5">{p.sub}</div>
                        </div>
                      </div>

                      {/* Price — dominant */}
                      <div className="mb-8">
                        <div className="text-6xl font-black text-gray-900 leading-none mb-1">{p.price}</div>
                        <div className="text-sm text-gray-400 font-medium">{p.period}</div>
                        {p.highlight && <div className="text-sm font-black text-[#FF6B00] mt-1">Save 67% vs monthly</div>}
                      </div>

                      {/* Benefits */}
                      <ul className="space-y-3 mb-8 flex-1">
                        {p.benefits.map(b => (
                          <li key={b} className="flex items-start gap-3 text-[15px] text-gray-700">
                            <div className="w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5" style={{ background: p.highlight ? "rgba(255,107,0,0.12)" : "#f3f4f6" }}>
                              <Check className="w-3 h-3" style={{ color: "#FF6B00" }} strokeWidth={3} />
                            </div>
                            <span className="leading-snug">{b}</span>
                          </li>
                        ))}
                      </ul>

                      {p.highlight && (
                        <div className="rounded-2xl px-4 py-3 mb-6 flex items-center gap-2" style={{ background: "rgba(255,107,0,0.08)", border: "1px solid rgba(255,107,0,0.2)" }}>
                          <Crown className="w-4 h-4 text-[#FF6B00] flex-shrink-0" />
                          <p className="text-[#FF6B00] text-xs font-black">🏆 FOUNDING MEMBER — Price locked before public rollout</p>
                        </div>
                      )}

                      <button
                        className="w-full font-black py-4 rounded-2xl text-base transition-all flex items-center justify-center gap-2 shadow-lg"
                        style={{
                          background: p.highlight ? "linear-gradient(135deg,#FF6B00,#e55f00)" : "#fff",
                          color: p.highlight ? "#fff" : "#FF6B00",
                          border: p.highlight ? "none" : "2px solid #FF6B00",
                          boxShadow: p.highlight ? "0 8px 24px rgba(255,107,0,0.25)" : "none",
                        }}
                      >
                        {p.cta}
                      </button>
                    </motion.div>
                  );
                })}
              </div>

              {/* Affiliate code link */}
              <div className="text-center mt-8">
                <button
                  onClick={() => setShowAffiliateField(v => !v)}
                  className="text-gray-400 hover:text-gray-600 text-sm font-bold transition flex items-center gap-1.5 mx-auto"
                >
                  <Tag className="w-4 h-4 text-[#FF6B00]" /> Have an affiliate code?
                </button>
                <AnimatePresence>
                  {showAffiliateField && (
                    <motion.div initial={{ opacity: 0, y: -8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} className="mt-4 max-w-sm mx-auto">
                      {!affiliateUnlocked ? (
                        <div className="flex gap-2">
                          <input
                            value={affiliateInput}
                            onChange={e => { setAffiliateInput(e.target.value.toUpperCase()); setAffiliateError(""); }}
                            placeholder="ENTER CODE"
                            className="flex-1 rounded-2xl px-4 py-3 text-sm font-black text-gray-900 placeholder-gray-400 focus:outline-none uppercase tracking-widest border border-gray-200 bg-gray-50"
                            onKeyDown={e => e.key === "Enter" && validateAffiliate()}
                          />
                          <button onClick={validateAffiliate} disabled={affiliateLoading} className="px-5 py-3 text-white text-sm font-black rounded-2xl disabled:opacity-50" style={{ background: "#FF6B00" }}>
                            {affiliateLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : "Apply"}
                          </button>
                        </div>
                      ) : (
                        <div className="rounded-2xl px-4 py-3 flex items-center justify-between" style={{ background: "#f0fdf4", border: "1.5px solid #bbf7d0" }}>
                          <div className="flex items-center gap-2">
                            <Check className="w-4 h-4 text-green-500" strokeWidth={3} />
                            <div className="text-left">
                              <p className="text-green-700 font-black text-sm">Code applied ✓</p>
                              <p className="text-green-600 text-xs">$10 for 6 months · {affiliateUnlocked.name}</p>
                            </div>
                          </div>
                          <button onClick={() => { setAffiliateUnlocked(null); setAffiliateInput(""); if (plan === "affiliate") setPlan(null); }} className="text-gray-400 text-xs font-bold">Remove</button>
                        </div>
                      )}
                      {affiliateError && <p className="text-red-500 text-xs mt-2 flex items-center gap-1"><AlertCircle className="w-3 h-3" /> {affiliateError}</p>}
                      {affiliateUnlocked && (
                        <button onClick={() => { setPlan("affiliate"); setStep(2); }} className="mt-4 w-full py-4 rounded-2xl text-white font-black text-base transition-all" style={{ background: "linear-gradient(135deg,#FF6B00,#e55f00)" }}>
                          Unlock My AI Coach →
                        </button>
                      )}
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>

              <p className="text-center text-xs text-gray-400 mt-8">
                ★★★★★ P2P FitTech AI Members · Transformations · Accountability · AI Coaching
              </p>
            </div>
          </motion.div>
        )}

        {/* ────────────────────────────────────────────────────────────────
            STEP 2 — Info + Plan Summary
        ──────────────────────────────────────────────────────────────── */}
        {step === 2 && selectedPlan && (
          <motion.div key="step2" initial={{ opacity: 0, x: 40 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -40 }}>
            <div className="max-w-5xl mx-auto px-6 pt-16 pb-24">
              <div className="grid lg:grid-cols-2 gap-16 items-start">

                {/* Left — Plan info */}
                <div>
                  {selectedPlan.id === "annual" && (
                    <div className="inline-flex items-center gap-2 bg-[#fff7ed] text-[#FF6B00] px-4 py-2 rounded-full text-xs font-black tracking-widest uppercase mb-6 border border-[#fed7aa]">
                      🏆 FOUNDING MEMBER
                    </div>
                  )}

                  <h1 className="text-4xl md:text-5xl font-black text-gray-900 leading-tight mb-4 tracking-tight">
                    {isEnterprisePlan
                      ? <>Activate your<br /><span style={{ color: "#FF6B00" }}>gym</span></>
                      : selectedPlan.id === "annual"
                        ? <>Become a<br /><span style={{ color: "#FF6B00" }}>Founding Member</span></>
                        : <>Start your<br /><span style={{ color: "#FF6B00" }}>transformation</span></>}
                  </h1>
                  <p className="text-gray-500 text-lg leading-relaxed mb-8">
                    {isEnterprisePlan
                      ? "Complete your secure Clover payment, then claim your facility and begin Gym ownership verification."
                      : selectedPlan.id === "annual"
                        ? "Transform your body with AI-powered fitness coaching. Join early members building the future of fitness."
                        : "Get personalized AI training that adapts to your goals and keeps you accountable every single day."}
                  </p>

                  {/* Price block */}
                  <div className="rounded-3xl p-6 mb-8" style={{ background: "linear-gradient(135deg,#fff7ed,#fff)", border: "2px solid #fed7aa" }}>
                    <div className="text-6xl font-black text-gray-900 leading-none mb-1">{selectedPlan.price}</div>
                    <div className="text-gray-500 text-base">{selectedPlan.period}</div>
                    {selectedPlan.id === "annual" && <div className="text-[#FF6B00] font-black text-sm mt-1">Founding price — locked forever</div>}
                  </div>

                  {/* Trust indicators */}
                  <ul className="space-y-4">
                    {selectedPlan.benefits.map(b => (
                      <li key={b} className="flex items-start gap-3 text-base text-gray-700">
                        <div className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5" style={{ background: "rgba(255,107,0,0.12)" }}>
                          <Check className="w-3.5 h-3.5 text-[#FF6B00]" strokeWidth={3} />
                        </div>
                        {b}
                      </li>
                    ))}
                  </ul>
                </div>

                {/* Right — Form */}
                <div className="rounded-3xl p-5 sm:p-8 border border-gray-100" style={{ boxShadow: "0 8px 48px rgba(0,0,0,0.06)" }}>
                  <h2 className="text-xl font-black text-gray-900 mb-5">Your information</h2>

                  <div className="space-y-3">
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className={labelClass}>First Name</label>
                        <input value={form.firstName} onChange={set("firstName")} placeholder="First name" className={inputClass} style={inputStyle} />
                      </div>
                      <div>
                        <label className={labelClass}>Last Name</label>
                        <input value={form.lastName} onChange={set("lastName")} placeholder="Last name" className={inputClass} style={inputStyle} />
                      </div>
                    </div>
                    <div>
                      <label className={labelClass}>{isEnterprisePlan ? "Business Email" : "Email"}</label>
                      <input value={form.email} onChange={set("email")} type="email" placeholder={isEnterprisePlan ? "you@yourgym.com" : "you@email.com"} className={inputClass} style={inputStyle} />
                      <div className="flex items-start gap-2.5 mt-2.5 px-4 py-3 rounded-xl" style={{ background: "rgba(255,107,0,0.07)", border: "1px solid rgba(255,107,0,0.2)" }}>
                        <span className="text-base shrink-0">{isEnterprisePlan ? "✓" : "📱"}</span>
                        <p className="text-xs font-bold leading-relaxed" style={{ color: "#c2500a" }}>
                          {isEnterprisePlan
                            ? <><span className="font-black">Used for your Clover receipt and Gym activation.</span> This is not an email-sales request.</>
                            : <><span className="font-black">This email is your app login.</span> Once you download the P2P FitTech AI app, sign in with this same email — no new account needed.</>}
                        </p>
                      </div>
                    </div>
                    <div>
                      <label className={labelClass}>Phone <span className="normal-case font-normal text-gray-400">(optional)</span></label>
                      <input value={form.phone} onChange={set("phone")} type="tel" placeholder="+1 (555) 000-0000" className={inputClass} style={inputStyle} />
                    </div>
                  </div>

                  {formError && (
                    <p className="text-red-500 text-sm flex items-center gap-1.5 mt-4">
                      <AlertCircle className="w-4 h-4" /> {formError}
                    </p>
                  )}
                  <button
                    onClick={goToPayment}
                    disabled={submitLoading}
                    className="w-full text-white font-black py-5 rounded-2xl text-lg mt-6 transition-all disabled:opacity-50 flex items-center justify-center gap-2 shadow-xl"
                    style={{ background: "linear-gradient(135deg,#FF6B00,#e55f00)", boxShadow: "0 8px 32px rgba(255,107,0,0.3)" }}
                  >
                    {submitLoading
                      ? <><Loader2 className="w-5 h-5 animate-spin" /> Opening Clover checkout…</>
                      : <>{isEnterprisePlan ? "Continue to Clover Checkout" : "Reserve My Spot"} <ChevronRight className="w-5 h-5" /></>}
                  </button>

                  <div className="flex items-center justify-center gap-4 mt-4">
                    {[{ icon: Lock, label: "Secure" }, { icon: ShieldCheck, label: "Cancel anytime" }].map(({ icon: Icon, label }) => (
                      <div key={label} className="flex items-center gap-1.5 text-gray-400 text-xs">
                        <Icon className="w-3 h-3" /> {label}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {/* ────────────────────────────────────────────────────────────────
            STEP 3 — Clover Card Payment
        ──────────────────────────────────────────────────────────────── */}
        {step === 3 && selectedPlan && (
          <motion.div key="step3" initial={{ opacity: 0, x: 40 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -40 }}>
            <div className="max-w-lg mx-auto px-6 pt-16 pb-24">

              {/* Header */}
              <div className="mb-8">
                <div className="inline-flex items-center gap-2 bg-[#fff7ed] text-[#FF6B00] px-4 py-2 rounded-full text-xs font-black tracking-widest uppercase mb-4 border border-[#fed7aa]">
                  <Lock className="w-3 h-3" /> Secure Payment
                </div>
                <h1 className="text-4xl font-black text-gray-900 leading-tight mb-2">
                  Complete your <span style={{ color: "#FF6B00" }}>order</span>
                </h1>
                <p className="text-gray-400 text-base">
                  {selectedPlan.label} · <span className="font-black text-gray-700">{selectedPlan.price}</span> · {selectedPlan.period}
                </p>
              </div>

              {/* Card form */}
              <div className="rounded-3xl p-5 sm:p-8 border border-gray-100" style={{ boxShadow: "0 8px 48px rgba(0,0,0,0.06)" }}>

                {!cloverReady && !cloverError && (
                  <div className="flex items-center gap-3 text-gray-400 text-sm mb-6">
                    <Loader2 className="w-4 h-4 animate-spin text-[#FF6B00]" />
                    Loading secure payment form…
                  </div>
                )}

                {/* Clover iframe containers — always in DOM at full natural size so SDK can
                    measure + inject iframes. Use visibility:hidden (not display:none / h-0)
                    while loading so Clover can still read element dimensions. */}
                <div style={{ visibility: cloverReady || cloverError ? "visible" : "hidden" }}>
                  <div className="space-y-3">
                    {/* Card number */}
                    <div>
                      <label className={labelClass}>Card Number</label>
                      <div
                        id="clover-card-number"
                        style={hostedFieldStyle}
                      />
                    </div>

                    {/* Expiry + CVV */}
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className={labelClass}>Expiry</label>
                        <div
                          id="clover-card-date"
                            style={hostedFieldStyle}
                        />
                      </div>
                      <div>
                        <label className={labelClass}>CVV</label>
                        <div
                          id="clover-card-cvv"
                            style={hostedFieldStyle}
                        />
                      </div>
                    </div>

                    {/* Postal code */}
                    <div>
                      <label className={labelClass}>Zip / Postal Code</label>
                      <div
                        id="clover-card-postal-code"
                        style={hostedFieldStyle}
                      />
                    </div>
                  </div>

                  {/* Error */}
                  {cloverError && (
                    <p className="text-red-500 text-sm flex items-center gap-1.5 mt-4">
                      <AlertCircle className="w-4 h-4 shrink-0" /> {cloverError}
                    </p>
                  )}

                  {/* Promo code */}
                  <div className="mt-5">
                    <button
                      type="button"
                      onClick={() => setPromoOpen(o => !o)}
                      className="text-xs font-bold text-gray-400 hover:text-[#FF6B00] transition flex items-center gap-1.5"
                    >
                      <span>{promoOpen ? "▲" : "▼"}</span> Have a promo code?
                    </button>
                    {promoOpen && (
                      <div className="mt-2 flex gap-2">
                        <input
                          value={promoInput}
                          onChange={e => setPromoInput(e.target.value.toUpperCase())}
                          placeholder="Enter code"
                          maxLength={24}
                          className="flex-1 rounded-xl px-4 py-3 text-sm font-bold tracking-widest text-gray-800 placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-[#FF6B00]/30 transition"
                          style={{ background: "#f9fafb", border: "1.5px solid #e5e7eb" }}
                        />
                      </div>
                    )}
                  </div>

                  {/* Pay button */}
                  <button
                    onClick={payWithClover}
                    disabled={cloverLoading || !cloverReady}
                    className="w-full text-white font-black py-5 rounded-2xl text-lg mt-6 transition-all disabled:opacity-50 flex items-center justify-center gap-2 shadow-xl"
                    style={{ background: "linear-gradient(135deg,#FF6B00,#e55f00)", boxShadow: "0 8px 32px rgba(255,107,0,0.3)" }}
                  >
                    {cloverLoading
                      ? <><Loader2 className="w-5 h-5 animate-spin" /> Processing…</>
                      : <><Lock className="w-4 h-4" /> Pay {selectedPlan.price}</>}
                  </button>

                  {/* Trust row */}
                  <div className="flex items-center justify-center gap-6 mt-4">
                    {[{ icon: Lock, label: "SSL Encrypted" }, { icon: ShieldCheck, label: "Secure Checkout" }].map(({ icon: Icon, label }) => (
                      <div key={label} className="flex items-center gap-1.5 text-gray-400 text-xs">
                        <Icon className="w-3 h-3" /> {label}
                      </div>
                    ))}
                  </div>
                </div>

                {/* Clover load error + retry */}
                {cloverError && !cloverReady && (
                  <div className="mt-4">
                    <p className="text-red-500 text-sm flex items-start gap-1.5 mb-3">
                      <AlertCircle className="w-4 h-4 shrink-0 mt-0.5" /> {cloverError}
                    </p>
                    <button
                      onClick={() => setCloverInitKey(k => k + 1)}
                      className="text-sm font-black text-[#FF6B00] underline underline-offset-2"
                    >
                      Try again
                    </button>
                  </div>
                )}
              </div>

              {/* Order summary */}
              <div className="mt-6 rounded-2xl px-5 py-4 border border-gray-100 flex items-center justify-between text-sm" style={{ background: "#fafafa" }}>
                <div className="flex items-center gap-2 text-gray-500">
                  <ShieldCheck className="w-4 h-4 text-[#FF6B00]" />
                  <span>{selectedPlan.label}</span>
                </div>
                <span className="font-black text-gray-900">{selectedPlan.price}</span>
              </div>
            </div>
          </motion.div>
        )}

        {/* ────────────────────────────────────────────────────────────────
            STEP 4 — Welcome / Success
        ──────────────────────────────────────────────────────────────── */}
        {step === 4 && selectedPlan && (
          <motion.div key="step4" initial={{ opacity: 0, scale: 0.97 }} animate={{ opacity: 1, scale: 1 }} className="min-h-[80vh] flex items-center justify-center px-6 py-24">
            <div className="text-center max-w-lg mx-auto">
              <motion.div
                initial={{ scale: 0 }} animate={{ scale: 1 }}
                transition={{ type: "spring", damping: 14, stiffness: 200, delay: 0.1 }}
                className="w-24 h-24 rounded-full mx-auto mb-8 flex items-center justify-center shadow-2xl"
                style={{ background: "linear-gradient(135deg,#FF6B00,#e55f00)", boxShadow: "0 16px 48px rgba(255,107,0,0.35)" }}
              >
                <Sparkles className="w-11 h-11 text-white" />
              </motion.div>

              <h1 className="text-5xl font-black text-gray-900 mb-3 tracking-tight">
                You're in{form.firstName ? `, ${form.firstName}` : ""}! 🎉
              </h1>
              <p className="text-gray-500 text-lg mb-2">
                Your <span className="font-black text-gray-900">{selectedPlan.label}</span> is confirmed.
              </p>
              <p className="text-gray-400 text-base mb-10">
                {isEnterprisePlan
                  ? "Your Clover payment is confirmed. Continue with the Gym claim and ownership-verification process."
                  : <>Check <span className="font-black text-gray-700">{form.email}</span> — your access details are on the way.</>}
              </p>

              {/* Promo code block — shown for any plan that received a code */}
              {promoCode && (
                <div className="rounded-3xl px-6 py-5 mb-4 text-left" style={{ background: "#0d0d0d", border: "2px solid #FF6B00" }}>
                  <p className="text-xs font-black uppercase tracking-widest mb-3" style={{ color: "#FF6B00" }}>Your App Promo Code</p>
                  <div className="rounded-xl px-4 py-4 mb-3 flex items-center justify-between gap-3" style={{ background: "rgba(255,107,0,0.10)" }}>
                    <span className="font-black text-white text-lg tracking-widest">{promoCode}</span>
                    <button
                      onClick={() => {
                        navigator.clipboard.writeText(promoCode);
                        setCodeCopied(true);
                        setTimeout(() => setCodeCopied(false), 2000);
                      }}
                      className="flex items-center gap-1.5 text-xs font-black px-3 py-1.5 rounded-lg border transition-all shrink-0"
                      style={{ color: "#FF6B00", borderColor: "#FF6B00" }}
                    >
                      {codeCopied ? <><CheckCheck className="w-3 h-3" /> Copied!</> : <><Copy className="w-3 h-3" /> Copy</>}
                    </button>
                  </div>
                  <p className="text-xs leading-relaxed" style={{ color: "#999" }}>
                    Open the app → tap <strong style={{ color: "#fff" }}>"Have a promo code?"</strong> on the paywall → enter this code → {promoDurationLabel || selectedPlan.period} unlocks instantly.
                  </p>
                </div>
              )}

              {/* App login callout — bold and prominent */}
              {!isEnterprisePlan && <div className="rounded-3xl px-6 py-5 mb-4 text-left" style={{ background: "linear-gradient(135deg,#fff7ed,#fff)", border: "2px solid #FF6B00" }}>
                <div className="flex items-center gap-2 mb-3">
                  <span className="text-xl">📱</span>
                  <p className="font-black text-gray-900 text-base">Use this to log into the app</p>
                </div>
                <div className="rounded-xl px-4 py-3 mb-2" style={{ background: "rgba(255,107,0,0.08)" }}>
                  <p className="text-xs font-black text-gray-500 uppercase tracking-widest mb-0.5">Your App Login Email</p>
                  <p className="font-black text-gray-900 text-sm break-all">{form.email || "your email"}</p>
                </div>
                <p className="text-xs text-gray-500 leading-relaxed">
                  When you download the <span className="font-black text-gray-700">P2P FitTech AI app</span>, sign in with this exact email — your account, workouts, and progress are all connected to it automatically. <span className="font-black text-[#FF6B00]">No new signup needed.</span>
                </p>
              </div>}

              {isEnterprisePlan && (
                <div className="rounded-3xl px-6 py-5 mb-4 text-left" style={{ background: "linear-gradient(135deg,#fff7ed,#fff)", border: "2px solid #FF6B00" }}>
                  <p className="font-black text-gray-900 text-base mb-3">Next: claim and activate your gym</p>
                  <ol className="list-decimal space-y-2 pl-5 text-sm text-gray-600">
                    <li>Download and open the P2P FitTech AI app.</li>
                    <li>Select <strong>Gym</strong> on the login page.</li>
                    <li>Tap <strong>Claim Your Gym</strong>.</li>
                    <li>Search for your gym or submit it if it is not listed.</li>
                    <li>Complete the five-step onboarding and ownership verification.</li>
                  </ol>
                </div>
              )}

              <div className="rounded-3xl px-6 py-5 mb-10 flex items-start gap-4 text-left" style={{ background: "#f0fdf4", border: "2px solid #bbf7d0" }}>
                <ShieldCheck className="w-6 h-6 text-green-500 shrink-0 mt-0.5" />
                <div>
                  <p className="text-gray-900 font-black">Access confirmed ✓</p>
                  <p className="text-gray-500 text-sm mt-0.5">{selectedPlan.label} · {selectedPlan.price} · {selectedPlan.period}</p>
                </div>
              </div>

              {/* Trust row */}
              <div className="grid grid-cols-3 gap-4 mb-10">
                {[
                  { label: "AI Coaching", sub: "Starts immediately" },
                  { label: "Founding Price", sub: "Locked forever" },
                  { label: "Support", sub: "Available 24/7" },
                ].map(({ label, sub }) => (
                  <div key={label} className="rounded-2xl py-4 px-3 border border-gray-100 text-center" style={{ boxShadow: "0 2px 8px rgba(0,0,0,0.04)" }}>
                    <p className="font-black text-gray-900 text-sm">{label}</p>
                    <p className="text-gray-400 text-xs mt-0.5">{sub}</p>
                  </div>
                ))}
              </div>

              <button
                onClick={() => navigate("/")}
                className="text-[#FF6B00] font-black text-sm border-2 border-[#FF6B00] px-8 py-3 rounded-2xl hover:bg-[#FF6B00] hover:text-white transition-all"
              >
                Back to Home
              </button>
            </div>
          </motion.div>
        )}

      </AnimatePresence>
    </div>
  );
}
