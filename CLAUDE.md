# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sophia is a sales research assistant MVP that runs AI workflows for company research, prospect research, and call analysis. The application uses N8n for AI orchestration (via Claude API) and Supabase for data storage and authentication.

**Tech Stack:**
- Frontend: Next.js 16 (App Router) + shadcn/ui + Tailwind CSS v4
- Backend: Next.js API routes + N8n webhooks
- Database: Supabase (PostgreSQL + Auth + Row Level Security)
- AI: Claude API (accessed via N8n workflows)
- Hosting: Vercel (frontend) + Supabase Cloud (backend/database)
- Dev Server: Turbopack (Next.js 16 default)

## Database Architecture

### Schema Design

The database consists of 4 main tables with a multi-tenant architecture enforced by Row Level Security (RLS):

1. **companies** - Stores company research results
   - Contains: company name, research_data (JSONB), user_id
   - Research includes: overview, products, recent_news, pain_points, market_position

2. **prospects** - Stores prospect/contact research results
   - Linked to: companies table via company_id
   - Contains: name, title, research_data (JSONB), user_id
   - Research includes: background, career_highlights, education, likely_priorities, talking_points

3. **calls** - Stores call transcripts and AI analysis
   - Linked to: companies table via company_id
   - Contains: title, transcript, analysis_data (JSONB), call_date, user_id
   - Analysis includes: summary, key_points, pain_points, objections, commitments, next_steps, sentiment, follow_up_suggestions

4. **call_prospects** - Many-to-many join table linking calls to prospects
   - Composite primary key: (call_id, prospect_id)
   - No user_id column; RLS enforced via subquery checking call ownership

### Row Level Security (RLS)

All tables have RLS enabled with policies that enforce data isolation by user:
- Companies, prospects, calls: Direct policies using `auth.uid() = user_id`
- Call_prospects: Indirect policies using subquery to verify call ownership

**Migration location:** `supabase/migrations/20251104054058_create_sales_research_schema.sql`

## Supabase CLI Commands

**Check migration status:**
```bash
supabase migration list
```

**Create new migration:**
```bash
supabase migration new <migration_name>
```

**Apply migrations to remote:**
```bash
supabase db push
```

**Pull remote schema:**
```bash
supabase db pull
```

**Link to project:**
```bash
supabase link --project-ref <project_ref>
```

**View linked projects:**
```bash
supabase projects list
```

**Get project API keys:**
```bash
supabase projects api-keys --project-ref <project_ref>
```

## Next.js Development Commands

**Start development server:**
```bash
cd sophia-app
npm run dev
```

**Build for production:**
```bash
npm run build
```

**Start production server:**
```bash
npm start
```

**Run linter:**
```bash
npm run lint
```

**Add shadcn/ui components:**
```bash
npx shadcn@latest add <component-name>
```

## N8n Workflow Integration

The application uses three main N8n workflows accessed via webhooks:

1. **Company Research Workflow**
   - Input: { company_name, user_id }
   - Process: Google Search → Jina Reader scraping → Claude analysis
   - Output: Structured JSON with company insights
   - Environment variable: `N8N_COMPANY_RESEARCH_WEBHOOK`

2. **Prospect Research Workflow**
   - Input: { prospect_name, company_id, user_id }
   - Process: Google/LinkedIn search → scraping → Claude analysis
   - Output: Structured JSON with prospect background and talking points
   - Environment variable: `N8N_PROSPECT_RESEARCH_WEBHOOK`

3. **Call Analysis Workflow**
   - Input: { transcript, company_id, prospect_ids[], user_id }
   - Process: Claude analysis of transcript
   - Output: Structured JSON with summary, action items, sentiment, next steps
   - Environment variable: `N8N_CALL_ANALYSIS_WEBHOOK`

### Workflow Pattern

All three workflows follow this pattern:
- Triggered by Next.js API routes via webhook POST request
- Process takes 30-60 seconds (long-running)
- Return structured JSON that gets saved to Supabase
- API routes handle user authentication and data persistence

## Application Structure

### Current Project Structure

```
Sophia/
├── supabase/                       # Supabase backend configuration
│   ├── migrations/
│   │   └── 20251104054058_create_sales_research_schema.sql
│   └── config.toml
│
├── sophia-app/                     # Next.js frontend application
│   ├── app/                        # Next.js App Router
│   │   ├── test-db/               # Database connection test page
│   │   │   └── page.tsx
│   │   ├── layout.tsx             # Root layout
│   │   ├── page.tsx               # Landing page (to be built)
│   │   ├── globals.css            # Global styles with Tailwind v4
│   │   └── favicon.ico
│   │
│   ├── lib/                       # Utility libraries
│   │   ├── supabase/              # Supabase client utilities
│   │   │   ├── client.ts          # Browser client (for Client Components)
│   │   │   ├── server.ts          # Server client (for Server Components/API)
│   │   │   └── middleware.ts      # Session refresh helper
│   │   └── utils.ts               # shadcn/ui utilities
│   │
│   ├── components/                # React components (empty - to be built)
│   │   └── ui/                    # shadcn/ui components
│   │
│   ├── middleware.ts              # Next.js middleware for auth
│   ├── .env.local                 # Environment variables (not in git)
│   ├── .env.local.template        # Template for env vars
│   ├── package.json
│   ├── tsconfig.json
│   ├── tailwind.config.ts         # Tailwind v4 configuration
│   ├── components.json            # shadcn/ui configuration
│   └── next.config.ts
│
├── CLAUDE.md                      # This file
└── sophia-mvp-build-guide.md      # MVP build instructions
```

### Planned Routes (To Be Built)

```
app/
  login/page.tsx                    # Login form
  signup/page.tsx                   # Signup form
  dashboard/
    layout.tsx                      # Dashboard layout with nav
    page.tsx                        # Main dashboard (3 workflow buttons + stats)
    companies/
      page.tsx                      # Companies list
      [id]/page.tsx                 # Company detail page
    prospects/
      page.tsx                      # Prospects list
      [id]/page.tsx                 # Prospect detail page
    calls/
      page.tsx                      # Calls list
      [id]/page.tsx                 # Call detail page
  api/
    research/
      company/route.ts              # Company research API endpoint
      prospect/route.ts             # Prospect research API endpoint
      call/route.ts                 # Call analysis API endpoint
```

## Development Philosophy

**Golden Rules (from build guide):**
1. Build one complete feature end-to-end before starting the next
2. Don't jump around - finish what you start
3. "Good enough" beats "perfect" - polish later
4. If stuck for 2+ hours, ask for help

**MVP Feature Priority:**
1. Company Research (complete this first)
2. Prospect Research (complete this second)
3. Call Analysis (complete this third)
4. Polish & cross-linking (only after all three workflows work)

**What's NOT in MVP (do not build):**
- Chat interface with RAG
- Email generation
- CRM integrations
- Automatic call recording/transcription
- Team collaboration
- Mobile app or responsive mobile design
- Export to PDF
- Browser extension
- Slack/Teams integration

## Environment Variables

Required environment variables:

```
# Supabase
NEXT_PUBLIC_SUPABASE_URL=<project_url>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon_key>
SUPABASE_SERVICE_ROLE_KEY=<service_role_key>

# N8n Webhooks
N8N_COMPANY_RESEARCH_WEBHOOK=<webhook_url>
N8N_PROSPECT_RESEARCH_WEBHOOK=<webhook_url>
N8N_CALL_ANALYSIS_WEBHOOK=<webhook_url>
```

## Key Implementation Details

### Supabase Client Utilities

The project uses `@supabase/ssr` for Next.js integration with three client types:

**1. Browser Client (`lib/supabase/client.ts`)**
- Used in Client Components
- Import: `import { createClient } from '@/lib/supabase/client'`
- Usage: `const supabase = createClient()`

**2. Server Client (`lib/supabase/server.ts`)**
- Used in Server Components, Server Actions, and API Routes
- Import: `import { createClient } from '@/lib/supabase/server'`
- Usage: `const supabase = await createClient()`
- Handles cookies for authentication

**3. Middleware Client (`lib/supabase/middleware.ts`)**
- Used in Next.js middleware for session refresh
- Automatically refreshes auth tokens
- Configured in root `middleware.ts`

**Important:** Always use the appropriate client for your context. Server Components and API Routes must use the server client (async). Client Components use the browser client (sync).

### Tailwind CSS v4 Configuration

**Key Changes from v3:**
- Uses CSS-first configuration with `@theme` directive
- Custom theme values defined in `globals.css` instead of `tailwind.config.ts`
- No more `@screen` directive (use responsive variants or `@media`)
- Line height numeric values parsed as `em` units

**Example Custom Theming:**
```css
/* In globals.css */
@theme {
  --breakpoint-sm: 40rem;
  --breakpoint-md: 48rem;
  --color-primary: #3b82f6;
}
```

**shadcn/ui Compatibility:**
- Fully compatible with Tailwind v4
- Uses CSS variables for theming
- Component configuration in `components.json`

### Authentication Flow
- Email/password auth via Supabase Auth
- Middleware automatically refreshes sessions on all routes
- Protected routes check authentication status and redirect to /login if unauthenticated
- User ID from `auth.uid()` is used for RLS enforcement

### Data Relationships
- Company → has many Prospects (one-to-many)
- Company → has many Calls (one-to-many)
- Call ↔ Prospect (many-to-many via call_prospects)
- All relationships cascade delete

### API Route Pattern
Each research API route follows this pattern:
1. Authenticate user (get user_id from session)
2. Validate input
3. Call N8n webhook with data + user_id
4. Wait for response (30-60 seconds)
5. Save response to Supabase with user_id
6. Return success + record ID

### Frontend Workflow Pattern
Each research workflow follows this UX pattern:
1. User clicks button → modal opens
2. User fills form (company name, prospect details, or call transcript)
3. Submit → show loading state with progress messages
4. Success → redirect to detail page for new record
5. Error → show error message with "Try Again" button

## Security Considerations

- All database access is protected by RLS policies
- User can only access their own data (enforced at database level)
- API routes must validate user authentication before calling N8n
- N8n webhooks should validate requests (implementation detail)
- Service role key should NEVER be exposed to frontend

## Current Project Status

### ✅ Completed (Steps 1-6 from Build Guide)
- Supabase project created and configured
- Database schema with RLS policies implemented and deployed
- Next.js 16 app created with TypeScript and App Router
- Tailwind CSS v4 installed and configured
- shadcn/ui initialized
- Supabase client utilities created (browser, server, middleware)
- Authentication middleware configured
- Database connection tested and verified

### 🚧 Next Steps (Step 7 onwards)
- Build landing page (Step 7)
- Create authentication pages (login/signup) (Steps 8-12)
- Build dashboard shell (Steps 13-14)
- Implement Company Research workflow (Steps 15-23)
- Implement Prospect Research workflow (Steps 24-34)
- Implement Call Analysis workflow (Steps 35-42)
- Polish and deploy (Steps 43+)

### 📝 Quick Start for Development

To continue development:
```bash
cd sophia-app
npm run dev
```

Visit http://localhost:3000 (or 3001 if 3000 is in use) to see the app.
Test database connection at http://localhost:3000/test-db

## Important Notes & Troubleshooting

### Supabase Project Details
- **Project ID:** kdrvscdbwurfdiuqdcrr
- **Project URL:** https://kdrvscdbwurfdiuqdcrr.supabase.co
- **Region:** us-east-2
- **Database Version:** PostgreSQL 17

### Common Issues

**Port already in use:**
- If port 3000 is in use, Next.js will automatically use 3001
- Check which port the dev server is using in the terminal output

**Environment variables not loading:**
- Ensure `.env.local` exists in `sophia-app/` directory
- Restart dev server after changing environment variables
- Never commit `.env.local` to git

**Supabase RLS errors:**
- Ensure user is authenticated before querying protected tables
- All tables have RLS enabled - anonymous requests will fail
- Check policies in Supabase dashboard if data isn't visible

**TypeScript errors in Supabase queries:**
- Supabase generates types from your schema
- Run `supabase gen types typescript --local` if using local dev
- For remote: `supabase gen types typescript --project-id <project-id>`

**Middleware warnings in Next.js 16:**
- You may see deprecation warnings about middleware → proxy
- This is expected and safe to ignore for now
- The current middleware setup works correctly

### Working with Multiple Lockfiles
- There are package-lock.json files in both root and sophia-app/
- Always run npm commands from within `sophia-app/` directory
- You may see Turbopack warnings about multiple lockfiles - safe to ignore

## Success Metrics

The MVP is designed for 10 initial users. Track:
- Number of workflows completed per user per week
- Which workflow is used most (company/prospect/call)
- User retention (how many come back daily/weekly)
- Time to complete each workflow (should be ~60 seconds)
