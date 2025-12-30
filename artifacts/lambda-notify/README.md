# Lambda Notify Dummy Artifact

通知用Lambda（期限/天気）のダミー実装です。

## Files
- `index.js`: ダミーハンドラ（ログ出力 + 200レスポンス）
- `dummy-notify.zip`: `index.js` をzipしたデプロイ用アーティファクト

## Replace
1. `index.js` を実装に置き換える
2. `zip -j dummy-notify.zip index.js` で更新
3. Terraformの `artifact_path_*` が参照するzipを差し替える
