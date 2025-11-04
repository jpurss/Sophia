-- Check if RLS is enabled on all tables
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename IN ('companies', 'prospects', 'calls', 'call_prospects')
ORDER BY tablename;

-- List all policies for our tables
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename IN ('companies', 'prospects', 'calls', 'call_prospects')
ORDER BY tablename, cmd, policyname;
