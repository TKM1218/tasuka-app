import "./globals.css";

export const metadata = {
  title: "Tasuka Minimal UI",
  description: "Cognito login + API health check",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ja">
      <body>
        <main>{children}</main>
      </body>
    </html>
  );
}
