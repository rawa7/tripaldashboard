#!/bin/bash

# Check if the necessary arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <supabase_url> <supabase_anon_key>"
    exit 1
fi

SUPABASE_URL=$1
SUPABASE_ANON_KEY=$2

# Create or update the .env file
echo "SUPABASE_URL=$SUPABASE_URL" > .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env

echo ".env file has been updated with your Supabase credentials." 