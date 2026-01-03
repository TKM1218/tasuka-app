"use client";

import { useEffect, useMemo, useState } from "react";

type HealthResult = {
  ok?: boolean;
  raw?: string;
  error?: string;
};

const tokenKey = "tasuka:cognito_token";

export default function HomePage() {
  const [token, setToken] = useState<string | null>(null);
  const [health, setHealth] = useState<HealthResult | null>(null);
  const [loading, setLoading] = useState(false);

  const env = useMemo(() => {
    return {
      domain: process.env.NEXT_PUBLIC_COGNITO_DOMAIN ?? "",
      clientId: process.env.NEXT_PUBLIC_COGNITO_CLIENT_ID ?? "",
      redirectUri: process.env.NEXT_PUBLIC_COGNITO_REDIRECT_URI ?? "",
      apiBaseUrl: process.env.NEXT_PUBLIC_API_BASE_URL ?? "",
    };
  }, []);

  useEffect(() => {
    if (typeof window === "undefined") {
      return;
    }

    const hash = window.location.hash.replace(/^#/, "");
    if (hash) {
      const params = new URLSearchParams(hash);
      const accessToken = params.get("access_token");
      const idToken = params.get("id_token");
      const resolved = accessToken || idToken;
      if (resolved) {
        localStorage.setItem(tokenKey, resolved);
        setToken(resolved);
      }
      window.history.replaceState({}, "", window.location.pathname);
      return;
    }

    const stored = localStorage.getItem(tokenKey);
    if (stored) {
      setToken(stored);
    }
  }, []);

  const loginUrl = useMemo(() => {
    if (!env.domain || !env.clientId || !env.redirectUri) {
      return "";
    }
    const query = new URLSearchParams({
      response_type: "token",
      client_id: env.clientId,
      redirect_uri: env.redirectUri,
      scope: "openid email",
    });
    return `https://${env.domain}/oauth2/authorize?${query.toString()}`;
  }, [env]);

  const logoutUrl = useMemo(() => {
    if (!env.domain || !env.clientId || !env.redirectUri) {
      return "";
    }
    const query = new URLSearchParams({
      client_id: env.clientId,
      logout_uri: env.redirectUri,
    });
    return `https://${env.domain}/logout?${query.toString()}`;
  }, [env]);

  const handleLogout = () => {
    localStorage.removeItem(tokenKey);
    setToken(null);
    setHealth(null);
  };

  const callHealth = async () => {
    if (!token || !env.apiBaseUrl) {
      return;
    }
    setLoading(true);
    setHealth(null);
    try {
      const res = await fetch(`${env.apiBaseUrl}/health`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const text = await res.text();
      setHealth({ ok: res.ok, raw: text });
    } catch (err) {
      setHealth({ error: err instanceof Error ? err.message : "Unknown error" });
    } finally {
      setLoading(false);
    }
  };

  const missingEnv =
    !env.domain || !env.clientId || !env.redirectUri || !env.apiBaseUrl;

  return (
    <div className="card">
      <h1>Tasuka Minimal UI</h1>
      <p>Cognito ログイン後に API Gateway の /health を叩く最小UIです。</p>

      {missingEnv && (
        <p style={{ color: "#b42318" }}>
          環境変数が不足しています。.env.local を確認してください。
        </p>
      )}

      {!token && (
        <div>
          <a className="button" href={loginUrl}>
            Login with Cognito
          </a>
        </div>
      )}

      {token && (
        <div>
          <p>ログイン済み</p>
          <button className="button" onClick={callHealth} disabled={loading}>
            {loading ? "Calling..." : "Call /health"}
          </button>
          <button
            className="button"
            onClick={handleLogout}
            style={{ marginLeft: "12px", background: "#ffffff", color: "#1f1f1f" }}
          >
            Logout (local)
          </button>
          {logoutUrl && (
            <a
              className="button"
              href={logoutUrl}
              style={{ marginLeft: "12px", background: "#ffffff", color: "#1f1f1f" }}
            >
              Logout (Cognito)
            </a>
          )}
        </div>
      )}

      {health && (
        <pre style={{ marginTop: "16px", whiteSpace: "pre-wrap" }}>
{JSON.stringify(health, null, 2)}
        </pre>
      )}
    </div>
  );
}
