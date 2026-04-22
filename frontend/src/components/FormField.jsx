export function FormField({ label, ...props }) {
  return (
    <label className="block">
      <span className="mb-2 block text-sm text-slate-600">{label}</span>
      <input
        {...props}
        className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none focus:border-brand-forest"
      />
    </label>
  );
}

export function SelectField({ label, children, ...props }) {
  return (
    <label className="block">
      <span className="mb-2 block text-sm text-slate-600">{label}</span>
      <select
        {...props}
        className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none focus:border-brand-forest"
      >
        {children}
      </select>
    </label>
  );
}

export function TextAreaField({ label, ...props }) {
  return (
    <label className="block">
      <span className="mb-2 block text-sm text-slate-600">{label}</span>
      <textarea
        {...props}
        className="min-h-28 w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none focus:border-brand-forest"
      />
    </label>
  );
}
