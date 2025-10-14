import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/fsrs_scheduler_service.dart';
import 'core/services/review_log_service.dart';
import 'data/local/hive_service.dart';
import 'data/remote/supabase_client.dart';
import 'core/providers/flashcard_review_provider.dart';
import 'core/providers/question_review_provider.dart';
import 'core/constants/app_theme.dart';
import 'app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await HiveService().initialize();
  await ReviewLogService().initialize();
  await SupabaseClient().initialize();
  FSRSSchedulerService().initialize();
  
  runApp(const SmartFlashApp());
}

class SmartFlashApp extends StatelessWidget {
  const SmartFlashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlashcardReviewProvider()),
        ChangeNotifierProvider(create: (_) => QuestionReviewProvider()),
      ],
      child: MaterialApp(
        title: 'SmartFlash',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
