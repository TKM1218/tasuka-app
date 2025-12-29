# Dummy Lambda API Artifact

このディレクトリは、検証用に「ダミーLambda zip」を固定パスで置いておくためのものです。

## 目的
- `artifacts/lambda-api/dummy-lambda-api.zip` を Terraform から参照する
- 先にインフラだけ apply 可能にする
- 後で実装済みのzipに置き換える

## ダミーの仕様
- handler: `index.handler`
- GET /health の想定で常に 200 と `{"ok":true,"dummy":true}` を返す
- 依存なし（node_modules不要）

## zip の生成方法
リポジトリルートで以下を実行:

```
cd artifacts/lambda-api
zip -j dummy-lambda-api.zip index.js
```

## 差し替え手順
本実装のzipを用意し、`dummy-lambda-api.zip` を置き換える。
Terraform 側の `artifact_path` は同じパスのままでOK。
