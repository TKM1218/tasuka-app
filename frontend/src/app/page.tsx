"use client";

import { useEffect, useMemo, useState } from "react";

type HealthResult = {
  ok?: boolean;
  raw?: string;
  error?: string;
};

type ListItem = {
  listId: string;
  name: string;
};

type Item = {
  listId: string;
  itemId: string;
  type: "shopping" | "todo";
  title: string;
  name?: string;
  memo?: string | null;
  quantity?: number | null;
  dueDate?: string | null;
};

const tokenKey = "tasuka:cognito_token";

export default function HomePage() {
  const [token, setToken] = useState<string | null>(null);
  const [health, setHealth] = useState<HealthResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [lists, setLists] = useState<ListItem[]>([]);
  const [listsLoading, setListsLoading] = useState(false);
  const [listsError, setListsError] = useState<string | null>(null);
  const [newListName, setNewListName] = useState("");
  const [selectedListId, setSelectedListId] = useState<string | null>(null);

  const [items, setItems] = useState<Item[]>([]);
  const [itemsLoading, setItemsLoading] = useState(false);
  const [itemsError, setItemsError] = useState<string | null>(null);
  const [newItemTitle, setNewItemTitle] = useState("");
  const [newItemType, setNewItemType] = useState<"shopping" | "todo">("shopping");

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
      // JWT authorizer の audience 対応のため id_token を優先する
      const resolved = idToken || accessToken;
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
    setLists([]);
    setItems([]);
    setSelectedListId(null);
  };

  const apiFetch = async (path: string, init?: RequestInit) => {
    if (!token || !env.apiBaseUrl) {
      throw new Error("Missing auth or API base URL");
    }
    const res = await fetch(`${env.apiBaseUrl}${path}`, {
      ...init,
      headers: {
        Authorization: `Bearer ${token}`,
        ...(init?.headers ?? {}),
      },
    });
    return res;
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

  const loadLists = async () => {
    setListsLoading(true);
    setListsError(null);
    try {
      const res = await apiFetch("/lists");
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data?.message ?? "Failed to load lists");
      }
      setLists(data.items ?? []);
    } catch (err) {
      setListsError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setListsLoading(false);
    }
  };

  const createList = async () => {
    if (!newListName.trim()) {
      setListsError("リスト名を入力してください。");
      return;
    }
    setListsLoading(true);
    setListsError(null);
    try {
      const res = await apiFetch("/lists", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ name: newListName.trim() }),
      });
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data?.message ?? "Failed to create list");
      }
      setNewListName("");
      await loadLists();
      setSelectedListId(data.listId);
    } catch (err) {
      setListsError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setListsLoading(false);
    }
  };

  const loadItems = async (listId: string) => {
    setItemsLoading(true);
    setItemsError(null);
    try {
      const res = await apiFetch(`/lists/${listId}/items`);
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data?.message ?? "Failed to load items");
      }
      setItems(data.items ?? []);
    } catch (err) {
      setItemsError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setItemsLoading(false);
    }
  };

  const createItem = async () => {
    if (!selectedListId) {
      setItemsError("リストを選択してください。");
      return;
    }
    if (!newItemTitle.trim()) {
      setItemsError("アイテム名を入力してください。");
      return;
    }
    setItemsLoading(true);
    setItemsError(null);
    try {
      const res = await apiFetch(`/lists/${selectedListId}/items`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          type: newItemType,
          title: newItemTitle.trim(),
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data?.message ?? "Failed to create item");
      }
      setNewItemTitle("");
      await loadItems(selectedListId);
    } catch (err) {
      setItemsError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setItemsLoading(false);
    }
  };

  useEffect(() => {
    if (token) {
      loadLists();
    }
  }, [token]);

  useEffect(() => {
    if (token && selectedListId) {
      loadItems(selectedListId);
    }
  }, [token, selectedListId]);

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

      {token && (
        <div style={{ marginTop: "24px" }}>
          <h2>Lists</h2>
          <div className="field">
            <input
              value={newListName}
              onChange={(event) => setNewListName(event.target.value)}
              placeholder="新しいリスト名"
            />
            <button
              className="button"
              onClick={createList}
              disabled={listsLoading}
              style={{ marginTop: "8px" }}
            >
              {listsLoading ? "Creating..." : "Create List"}
            </button>
          </div>
          {listsError && <p style={{ color: "#b42318" }}>{listsError}</p>}
          {listsLoading && <p>Loading lists...</p>}
          <ul className="list">
            {lists.map((list) => (
              <li key={list.listId}>
                <button onClick={() => setSelectedListId(list.listId)}>
                  {list.name}
                </button>
              </li>
            ))}
          </ul>
        </div>
      )}

      {token && selectedListId && (
        <div style={{ marginTop: "24px" }}>
          <h2>Items</h2>
          <div className="field">
            <input
              value={newItemTitle}
              onChange={(event) => setNewItemTitle(event.target.value)}
              placeholder="アイテム名"
            />
            <div style={{ marginTop: "8px" }}>
              <label>
                <input
                  type="radio"
                  checked={newItemType === "shopping"}
                  onChange={() => setNewItemType("shopping")}
                />
                Shopping
              </label>
              <label style={{ marginLeft: "12px" }}>
                <input
                  type="radio"
                  checked={newItemType === "todo"}
                  onChange={() => setNewItemType("todo")}
                />
                Todo
              </label>
            </div>
            <button
              className="button"
              onClick={createItem}
              disabled={itemsLoading}
              style={{ marginTop: "8px" }}
            >
              {itemsLoading ? "Creating..." : "Add Item"}
            </button>
          </div>
          {itemsError && <p style={{ color: "#b42318" }}>{itemsError}</p>}
          {itemsLoading && <p>Loading items...</p>}
          <ul className="list">
            {items.map((item) => (
              <li key={item.itemId}>
                {item.title} <span>({item.type})</span>
              </li>
            ))}
          </ul>
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
