# Check if the necessary arguments are provided
param(
    [Parameter(Mandatory=$true)]
    [string]$SupabaseUrl,

    [Parameter(Mandatory=$true)]
    [string]$SupabaseAnonKey
)

# Create or update the .env file
"SUPABASE_URL=$SupabaseUrl" | Out-File -FilePath .env
"SUPABASE_ANON_KEY=$SupabaseAnonKey" | Add-Content -Path .env

Write-Host ".env file has been updated with your Supabase credentials." 