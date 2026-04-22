export default function ActionCard({ title, description, children }) {
  return (
    <section className="rounded-3xl border border-black/5 bg-white/90 p-5 shadow-glow">
      <div className="mb-4">
        <h3 className="font-display text-2xl text-brand-forest">{title}</h3>
        {description ? <p className="mt-1 text-sm text-slate-600">{description}</p> : null}
      </div>
      {children}
    </section>
  );
}
