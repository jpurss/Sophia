import Link from "next/link";

export default function Home() {
  return (
    <main className="min-h-screen">
      {/* Hero Section */}
      <div className="flex flex-col items-center justify-center px-8 py-32 text-center">
        <h1 className="text-7xl font-bold tracking-tight text-white mb-6 max-w-4xl">
          AI Research Assistant for Sales Reps
        </h1>
        <p className="text-xl text-light-gray mb-12 max-w-2xl">
          Stop wrestling with ChatGPT. Get instant company research, prospect
          insights, and call analysis with one click.
        </p>
        <Link
          href="/signup"
          className="inline-flex items-center justify-center px-8 py-4 text-lg font-semibold text-white bg-pink rounded-lg hover:opacity-90 transition-opacity"
        >
          Get Started
        </Link>
      </div>

      {/* Features Section */}
      <div className="max-w-6xl mx-auto px-8 pb-32">
        <div className="grid grid-cols-3 gap-8">
          {/* Feature 1 */}
          <div className="bg-prussian rounded-xl p-8">
            <h3 className="text-2xl font-semibold text-white mb-4">
              Company Research
            </h3>
            <p className="text-light-gray leading-relaxed">
              Deep dive on any company in 60 seconds. Get comprehensive
              insights, products, recent news, and pain points automatically.
            </p>
          </div>

          {/* Feature 2 */}
          <div className="bg-prussian rounded-xl p-8">
            <h3 className="text-2xl font-semibold text-white mb-4">
              Prospect Intel
            </h3>
            <p className="text-light-gray leading-relaxed">
              Understand who you're talking to. Uncover background, career
              highlights, priorities, and perfect talking points.
            </p>
          </div>

          {/* Feature 3 */}
          <div className="bg-prussian rounded-xl p-8">
            <h3 className="text-2xl font-semibold text-white mb-4">
              Call Analysis
            </h3>
            <p className="text-light-gray leading-relaxed">
              Turn transcripts into action items. Extract key points,
              objections, commitments, and next steps instantly.
            </p>
          </div>
        </div>
      </div>
    </main>
  );
}
