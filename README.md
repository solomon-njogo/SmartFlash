# SmartFlash - AI-Powered Study App

SmartFlash is an AI-powered study app designed to enhance learning through spaced repetition and customizable content management for students worldwide. The app implements the FSRS (Free Spaced Repetition Scheduler) algorithm for optimal learning intervals.

## Features

- **FSRS Algorithm Integration**: Advanced spaced repetition scheduling for optimal learning
- **Flashcard System**: Create and review flashcards with intelligent scheduling
- **Quiz System**: Take quizzes with automatic FSRS integration
- **Local Storage**: Offline-first approach with Hive database
- **Cloud Sync**: Supabase integration for cross-device synchronization
- **Responsive UI**: Beautiful, modern interface that adapts to different screen sizes
- **Progress Tracking**: Detailed statistics and progress monitoring

## Architecture

The app follows a clean architecture pattern with the following layers:

- **Data Layer**: Models, local storage (Hive), and remote storage (Supabase)
- **Core Layer**: Services, providers, and business logic
- **App Layer**: UI screens and widgets

## Project Structure

```
lib/
├── app/
│   ├── screens/          # UI screens
│   └── widgets/          # Reusable UI components
├── core/
│   ├── constants/        # App constants, colors, themes, text styles
│   ├── providers/        # State management providers
│   └── services/         # Business logic services
└── data/
    ├── models/           # Data models with JSON serialization
    ├── local/            # Hive database and adapters
    └── remote/           # Supabase client and API calls
```

## Setup Instructions

### Prerequisites

1. **Flutter SDK**: Install Flutter 3.7.2 or later
2. **Dart SDK**: Included with Flutter
3. **Supabase Account**: For cloud synchronization (optional)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smartflash
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure Supabase (Optional)**
   - Create a new Supabase project
   - Update `lib/core/constants/app_constants.dart` with your Supabase URL and anon key
   - Set up the database schema (see Database Schema section)

### Database Schema

Create the following tables in your Supabase database:

```sql
-- Flashcards table
CREATE TABLE flashcards (
  id TEXT PRIMARY KEY,
  front TEXT NOT NULL,
  back TEXT NOT NULL,
  deck_id TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
  fsrs_state JSONB,
  user_id TEXT,
  tags TEXT[],
  difficulty INTEGER DEFAULT 3
);

-- Questions table
CREATE TABLE questions (
  id TEXT PRIMARY KEY,
  question TEXT NOT NULL,
  options TEXT[] NOT NULL,
  correct_answer_index INTEGER NOT NULL,
  explanation TEXT NOT NULL,
  quiz_id TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
  fsrs_state JSONB,
  user_id TEXT,
  tags TEXT[],
  difficulty INTEGER DEFAULT 3
);

-- Review logs table
CREATE TABLE review_logs (
  id TEXT PRIMARY KEY,
  card_id TEXT NOT NULL,
  rating INTEGER NOT NULL,
  review_date_time TIMESTAMP WITH TIME ZONE NOT NULL,
  scheduled_days INTEGER NOT NULL,
  elapsed_days INTEGER NOT NULL,
  state INTEGER NOT NULL,
  card_state JSONB NOT NULL,
  review_type TEXT NOT NULL,
  user_id TEXT
);

-- Enable Row Level Security
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_logs ENABLE ROW LEVEL SECURITY;

-- Create policies (adjust based on your authentication system)
CREATE POLICY "Users can view their own flashcards" ON flashcards
  FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert their own flashcards" ON flashcards
  FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update their own flashcards" ON flashcards
  FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can delete their own flashcards" ON flashcards
  FOR DELETE USING (auth.uid()::text = user_id);

-- Similar policies for questions and review_logs tables
```

### Running the App

1. **Start the app**
   ```bash
   flutter run
   ```

2. **Run tests**
   ```bash
   flutter test
   ```

3. **Build for production**
   ```bash
   flutter build apk  # For Android
   flutter build ios  # For iOS
   ```

## FSRS Algorithm

The app implements the FSRS (Free Spaced Repetition Scheduler) algorithm, which is a modern, open-source alternative to the traditional SM-2 algorithm. Key features:

- **4-Point Rating System**: Again (1), Hard (2), Good (3), Easy (4)
- **Adaptive Scheduling**: Adjusts intervals based on performance
- **Retrievability Calculation**: Predicts memory strength
- **Configurable Parameters**: Customizable retention rates and intervals

### Rating System

**Flashcards:**
- **Again (1)**: Forgot completely
- **Hard (2)**: Remembered with difficulty
- **Good (3)**: Remembered with hesitation
- **Easy (4)**: Remembered easily

**Quiz Questions:**
- **Incorrect Answer**: Automatically converted to Rating.Again (1)
- **Correct Answer**: Automatically converted to Rating.Good (3)

## Key Components

### Models
- `FSRSCardState`: Stores FSRS algorithm state for each card
- `ReviewLog`: Tracks review history and performance
- `FlashcardModel`: Flashcard data with FSRS integration
- `QuestionModel`: Quiz question data with FSRS integration

### Services
- `FSRSSchedulerService`: Core FSRS algorithm implementation
- `ReviewLogService`: Manages review history and statistics
- `HiveService`: Local database operations
- `SupabaseClient`: Cloud synchronization

### Providers
- `FlashcardReviewProvider`: Manages flashcard review sessions
- `QuestionReviewProvider`: Manages quiz sessions

### UI Screens
- `HomeScreen`: Main dashboard with quick actions
- `StudySessionScreen`: Flashcard review interface
- `QuizScreen`: Quiz taking interface

## Customization

### Themes
The app uses a comprehensive theming system with:
- `AppColors`: Color palette and gradients
- `AppTextStyles`: Typography system
- `AppTheme`: Material Design 3 theme configuration

### Constants
Modify `app_constants.dart` to adjust:
- FSRS algorithm parameters
- UI spacing and sizing
- Database configuration
- Review session limits

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the code comments

## Roadmap

- [ ] User authentication system
- [ ] Deck and quiz management
- [ ] Advanced statistics and analytics
- [ ] Import/export functionality
- [ ] Offline mode improvements
- [ ] Performance optimizations
- [ ] Accessibility improvements
- [ ] Multi-language support