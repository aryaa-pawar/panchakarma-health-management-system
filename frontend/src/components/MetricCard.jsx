export default function MetricCard({ label, value, accent }) {
  return (
    <div className="rounded-3xl border border-white/50 bg-white/75 p-5 shadow-glow">
      <p className="text-sm uppercase tracking-[0.2em] text-slate-500">{label}</p>
      <p className={`mt-3 text-3xl font-semibold ${accent || "text-brand-forest"}`}>{value}</p>
    </div>
  );
}
