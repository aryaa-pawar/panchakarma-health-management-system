import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function LoginPage() {
  const navigate = useNavigate();
  const { login, loading } = useAuth();
  const [form, setForm] = useState({
    email: "",
    password: ""
  });
  const [error, setError] = useState("");

  const handleSubmit = async (event) => {
    event.preventDefault();
    const result = await login(form);
    if (!result.ok) {
      setError(result.message);
      return;
    }
    navigate("/dashboard");
  };

  return (
    <main className="mx-auto grid min-h-[80vh] max-w-7xl items-center gap-10 px-6 py-12 lg:grid-cols-2">
      <section>
        <p className="text-sm uppercase tracking-[0.3em] text-brand-clay">Secure sign in</p>
        <h1 className="mt-3 font-display text-5xl text-brand-ink">Secure login for authorized clinic staff and patients.</h1>
        <p className="mt-4 max-w-xl text-lg text-slate-600">
          Access patient records, appointments, treatment plans, billing, and session workflows from a single protected interface.
        </p>
      </section>
      <form onSubmit={handleSubmit} className="rounded-[2rem] border border-black/5 bg-white/85 p-8 shadow-glow">
        <label className="mb-4 block">
          <span className="mb-2 block text-sm text-slate-600">Email</span>
          <input
            type="email"
            required
            className="w-full rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-brand-forest"
            value={form.email}
            onChange={(e) => setForm({ ...form, email: e.target.value })}
          />
        </label>
        <label className="mb-4 block">
          <span className="mb-2 block text-sm text-slate-600">Password</span>
          <input
            type="password"
            required
            minLength={8}
            className="w-full rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-brand-forest"
            value={form.password}
            onChange={(e) => setForm({ ...form, password: e.target.value })}
          />
        </label>
        {error ? <p className="mb-4 text-sm text-red-600">{error}</p> : null}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded-2xl bg-brand-forest px-4 py-3 font-medium text-white disabled:opacity-60"
        >
          {loading ? "Signing in..." : "Sign In to Dashboard"}
        </button>
        <p className="mt-4 text-sm text-slate-500">Demo mode is available for project review with seeded clinic accounts.</p>
      </form>
    </main>
  );
}
