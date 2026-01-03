# Tasuka Frontend (Minimal)

## 起動方法
1. `cd frontend`
2. `npm install`
3. `npm run dev`
4. http://localhost:3000 にアクセス

## 環境変数例（.env.local）
```
NEXT_PUBLIC_COGNITO_DOMAIN=your-domain.auth.ap-northeast-1.amazoncognito.com
NEXT_PUBLIC_COGNITO_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxx
NEXT_PUBLIC_COGNITO_REDIRECT_URI=http://localhost:3000
NEXT_PUBLIC_API_BASE_URL=https://xxxx.execute-api.ap-northeast-1.amazonaws.com
```

## ログイン → /health 実行の流れ
1. 画面の「Login with Cognito」ボタンを押す
2. Hosted UI でログイン
3. リダイレクト後、トークンを取得して画面に表示
4. 「Call /health」ボタンで API Gateway の `GET /health` を呼び出す
