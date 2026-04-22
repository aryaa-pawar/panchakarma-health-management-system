import { createContext, useContext, useEffect, useState } from "react";
import client from "../api/client";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [token, setToken] = useState(localStorage.getItem("phms_token"));
  const [user, setUser] = useState(JSON.parse(localStorage.getItem("phms_user") || "null"));
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!token) {
      return;
    }

    client
      .get("/auth/me")
      .then(({ data }) => {
        setUser(data);
        localStorage.setItem("phms_user", JSON.stringify(data));
      })
      .catch(() => logout());
  }, [token]);

  const login = async (credentials) => {
    setLoading(true);
    try {
      const { data } = await client.post("/auth/login", credentials);
      setToken(data.token);
      setUser(data.user);
      localStorage.setItem("phms_token", data.token);
      localStorage.setItem("phms_user", JSON.stringify(data.user));
      return { ok: true };
    } catch (error) {
      return {
        ok: false,
        message: error.response?.data?.message || "Login failed"
      };
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem("phms_token");
    localStorage.removeItem("phms_user");
  };

  return (
    <AuthContext.Provider value={{ token, user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
