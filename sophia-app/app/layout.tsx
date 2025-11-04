import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: "Sophia - AI Research Assistant for Sales Reps",
  description:
    "Get instant company research, prospect insights, and call analysis with one click.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        {/* Simple Navigation */}
        <nav className="border-b border-dark-gray bg-dark-navy">
          <div className="max-w-7xl mx-auto px-8 py-4 flex items-center justify-between">
            <Link href="/" className="text-2xl font-bold text-white">
              Sophia
            </Link>
            <div className="flex items-center gap-6">
              <Link
                href="/login"
                className="text-white hover:text-light-gray transition-colors"
              >
                Sign In
              </Link>
              <Link
                href="/signup"
                className="inline-flex items-center justify-center px-6 py-2 text-sm font-semibold text-white bg-pink rounded-lg hover:opacity-90 transition-opacity"
              >
                Get Started
              </Link>
            </div>
          </div>
        </nav>

        {children}
      </body>
    </html>
  );
}
