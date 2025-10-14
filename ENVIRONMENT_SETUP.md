# Environment Configuration

This app uses environment variables to securely store sensitive configuration data like Supabase credentials.

## Setup Instructions

### 1. Create Environment File

Create a `.env` file in the root directory of your project with the following content:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Optional: Other environment variables
APP_ENV=development
DEBUG_MODE=true
```

### 2. Get Supabase Credentials

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to Settings → API
4. Copy the following values:
   - **Project URL** → Use as `SUPABASE_URL`
   - **anon public** key → Use as `SUPABASE_ANON_KEY`

### 3. Example .env File

```env
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY0NjQzOTIwMCwiZXhwIjoxOTYyMDE1MjAwfQ.example-signature
```

### 4. Security Notes

- **Never commit `.env` files to version control**
- The `.env` file is already included in `.gitignore`
- Use `.env.example` as a template for other developers
- For production, use your platform's environment variable system

### 5. Alternative Configuration

If you prefer not to use environment variables, you can directly modify the values in `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'https://your-project-id.supabase.co',
  anonKey: 'your-anon-key-here',
);
```

## Troubleshooting

### Common Issues

1. **"Environment variable not found"**
   - Ensure `.env` file exists in the project root
   - Check that the variable names match exactly
   - Verify the file is included in `pubspec.yaml` assets

2. **"Invalid Supabase URL"**
   - Verify the URL format: `https://project-id.supabase.co`
   - Ensure no trailing slashes

3. **"Invalid API key"**
   - Double-check the anon key from Supabase dashboard
   - Ensure no extra spaces or characters

### File Structure

```
smartflash/
├── .env                 # Environment variables (not committed)
├── .env.example         # Template file (committed)
├── lib/
│   └── main.dart        # Loads environment variables
└── pubspec.yaml         # Includes .env in assets
```
