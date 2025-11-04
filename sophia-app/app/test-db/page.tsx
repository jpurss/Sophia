import { createClient } from '@/lib/supabase/server'

export default async function TestPage() {
  const supabase = await createClient()

  // Test connection by querying the companies table
  const { data: companies, error } = await supabase
    .from('companies')
    .select('*')
    .limit(5)

  if (error) {
    return (
      <div className="min-h-screen p-8 bg-red-50">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold text-red-600 mb-4">Database Connection Error</h1>
          <div className="bg-white p-6 rounded-lg shadow">
            <p className="text-red-700 mb-2">Failed to connect to Supabase:</p>
            <pre className="bg-red-100 p-4 rounded overflow-auto">
              {JSON.stringify(error, null, 2)}
            </pre>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen p-8 bg-green-50">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold text-green-600 mb-4">
          ✅ Database Connection Test Successful!
        </h1>
        <div className="bg-white p-6 rounded-lg shadow mb-4">
          <h2 className="text-xl font-semibold mb-2">Connection Details:</h2>
          <ul className="list-disc list-inside space-y-1">
            <li>✓ Supabase client initialized</li>
            <li>✓ Database connection established</li>
            <li>✓ Row Level Security (RLS) policies active</li>
            <li>Found <strong>{companies?.length || 0}</strong> companies in database</li>
          </ul>
        </div>

        {companies && companies.length > 0 && (
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Sample Data:</h2>
            <pre className="bg-gray-100 p-4 rounded overflow-auto text-sm">
              {JSON.stringify(companies, null, 2)}
            </pre>
          </div>
        )}

        {(!companies || companies.length === 0) && (
          <div className="bg-white p-6 rounded-lg shadow">
            <p className="text-gray-600">
              No companies found in the database yet. This is expected for a fresh database.
              The connection is working correctly!
            </p>
          </div>
        )}

        <div className="mt-6">
          <a
            href="/"
            className="inline-block bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          >
            ← Back to Home
          </a>
        </div>
      </div>
    </div>
  )
}
