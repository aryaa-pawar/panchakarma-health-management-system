import { Activity, CalendarDays, FlaskConical, HandCoins, ShieldCheck, Users } from "lucide-react";
import { Link } from "react-router-dom";

const featureCards = [
  {
    title: "Clinical Workflow",
    text: "Treatment plans, consultation notes, therapy compliance, and progress snapshots live in one traceable timeline.",
    icon: Activity
  },
  {
    title: "Scheduling Control",
    text: "Package bookings, recurring sessions, waitlists, and buffer-aware calendars help front desk teams move quickly.",
    icon: CalendarDays
  },
  {
    title: "Inventory Intelligence",
    text: "Track oils, herbs, expiry risk, and session-linked usage before low stock affects patient care.",
    icon: FlaskConical
  },
  {
    title: "Revenue Visibility",
    text: "Generate invoices, accept partial payments, and monitor receivables, taxes, and package profitability.",
    icon: HandCoins
  }
];

export default function LandingPage() {
  return (
    <main>
      <section className="mx-auto grid max-w-7xl gap-8 px-6 py-16 lg:grid-cols-[1.2fr,0.8fr]">
        <div className="space-y-6">
          <span className="inline-flex rounded-full bg-brand-forest px-4 py-2 text-sm text-white">
            Panchakarma clinic operations, built for non-technical teams
          </span>
          <h1 className="font-display text-5xl leading-tight text-brand-ink md:text-6xl">
            A calm, connected system for patients, doctors, therapists, and revenue.
          </h1>
          <p className="max-w-2xl text-lg text-slate-700">
            Manage Panchakarma consultations, therapy packages, inventory, billing, and patient progress from one secure platform.
          </p>
          <div className="flex flex-wrap gap-4">
            <Link to="/login" className="rounded-full bg-brand-clay px-6 py-3 text-white shadow-glow">
              Open Role Dashboard
            </Link>
            <a href="#modules" className="rounded-full border border-brand-forest px-6 py-3 text-brand-forest">
              Explore Modules
            </a>
          </div>
        </div>
        <div className="rounded-[2rem] bg-brand-ink p-8 text-white shadow-glow">
          <div className="mb-6 flex items-center gap-3">
            <Users size={22} />
            <h2 className="text-2xl font-semibold">Included workflows</h2>
          </div>
          <ul className="space-y-4 text-brand-sand">
            <li>Admin analytics, staff performance, low-stock alerts, and audit views</li>
            <li>Doctor-led treatment plans, prescriptions, and follow-up scheduling</li>
            <li>Therapist session execution with comfort scoring and notes</li>
            <li>Receptionist booking tools with patient intake and payment capture</li>
            <li>Patient-facing portal for appointments, bills, and progress tracking</li>
          </ul>
        </div>
      </section>

      <section id="modules" className="mx-auto max-w-7xl px-6 pb-16">
        <div className="grid gap-6 md:grid-cols-2 xl:grid-cols-4">
          {featureCards.map(({ title, text, icon: Icon }) => (
            <article key={title} className="rounded-3xl border border-black/5 bg-white/75 p-6 shadow-glow">
              <div className="mb-4 inline-flex rounded-2xl bg-brand-leaf/20 p-3 text-brand-forest">
                <Icon size={22} />
              </div>
              <h3 className="mb-2 text-xl font-semibold">{title}</h3>
              <p className="text-slate-600">{text}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="bg-brand-forest py-16 text-white">
        <div className="mx-auto max-w-7xl px-6">
          <h2 className="font-display text-4xl">Production-focused clinic platform</h2>
          <div className="mt-8 grid gap-6 md:grid-cols-3">
            <div className="rounded-3xl bg-white/10 p-6 text-brand-sand">
              <ShieldCheck className="mb-4" />
              Role-based access and audit-backed workflows for front desk, doctors, therapists, and patients.
            </div>
            <div className="rounded-3xl bg-white/10 p-6 text-brand-sand">
              <Activity className="mb-4" />
              Real-time patient, appointment, treatment, billing, and session updates through the web interface.
            </div>
            <div className="rounded-3xl bg-white/10 p-6 text-brand-sand">
              <FlaskConical className="mb-4" />
              MySQL constraints, views, procedures, and triggers keep the clinic data accurate and consistent.
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
