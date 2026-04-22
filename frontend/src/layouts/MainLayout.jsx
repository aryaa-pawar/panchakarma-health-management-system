import { Link, Outlet } from "react-router-dom";
import { HeartPulse, ShieldCheck } from "lucide-react";
import { useAuth } from "../context/AuthContext";

export default function MainLayout() {
  const { user, logout } = useAuth();

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top,#f4e3ca_0%,#ece2d0_30%,#f8fafc_60%,#e6efe9_100%)] text-brand-ink">
      <header className="sticky top-0 z-10 border-b border-black/5 bg-white/70 backdrop-blur">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <Link to="/" className="flex items-center gap-3 text-lg font-semibold">
            <span className="rounded-full bg-brand-forest p-2 text-white">
              <HeartPulse size={18} />
            </span>
            PrakritiOPD
          </Link>
          <nav className="flex items-center gap-4 text-sm">
            <Link to="/" className="hover:text-brand-clay">Home</Link>
            <Link to="/dashboard" className="hover:text-brand-clay">Dashboard</Link>
            {user ? (
              <button onClick={logout} className="rounded-full bg-brand-forest px-4 py-2 text-white">
                Logout
              </button>
            ) : (
              <Link to="/login" className="rounded-full bg-brand-forest px-4 py-2 text-white">
                Login
              </Link>
            )}
          </nav>
        </div>
      </header>
      <Outlet />
      <footer className="border-t border-black/5 bg-brand-ink py-6 text-sm text-white">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6">
          <p>Secure patient data management for daily clinic operations.</p>
          <div className="flex items-center gap-2 text-brand-sand">
            <ShieldCheck size={16} />
            Reliable, compliant care workflows
          </div>
        </div>
      </footer>
    </div>
  );
}
