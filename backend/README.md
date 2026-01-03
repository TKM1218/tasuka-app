# Tasuka Lambda API (Minimal CRUD)

## 目的
API Gateway + Lambda で最小CRUDを提供する。

## 必要な環境変数
- `LISTS_TABLE`
- `LIST_MEMBERS_TABLE`
- `ITEMS_TABLE`
- `NOTIFICATIONS_TABLE`（現状は未使用）

## 開発・ビルド
```
npm install
npm run build
npm run package
```

## パッケージの出力先
`artifacts/lambda-api/dummy-lambda-api.zip` を上書きします。

## ルーティング
- GET `/health`
- GET `/lists`
- POST `/lists`
- GET `/lists/{listId}/items`
- POST `/lists/{listId}/items`
