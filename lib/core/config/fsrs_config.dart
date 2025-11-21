/// FSRS Configuration
/// Contains default FSRS parameters and configuration options
class FSRSConfig {
  /// Default FSRS v4 parameters (17 parameters)
  /// These are the optimized default parameters for FSRS v4
  static const List<double> defaultParameters = [
    0.4, // w[0] - initial stability for again
    1.6, // w[1] - initial stability for hard
    4.4, // w[2] - initial stability for good
    10.0, // w[3] - initial stability for easy
    0.94, // w[4] - request retention
    0.86, // w[5] - maximum interval factor
    0.01, // w[6] - easy bonus
    1.49, // w[7] - hard interval factor
    0.14, // w[8] - stability increase for hard
    0.94, // w[9] - stability increase for good
    2.18, // w[10] - stability increase for easy
    0.05, // w[11] - stability decrease for again
    0.32, // w[12] - difficulty increase for again
    1.4, // w[13] - difficulty increase for hard
    0.94, // w[14] - difficulty decrease for good
    0.86, // w[15] - difficulty decrease for easy
    0.01, // w[16] - difficulty weight
  ];

  /// Requested retention rate (0.0 to 1.0)
  /// Higher values mean more frequent reviews but better retention
  static const double defaultRequestRetention = 0.9;

  /// Maximum interval in days
  static const int maxInterval = 36500; // ~100 years

  /// Minimum interval in days
  static const int minInterval = 1;

  /// Learning steps (in minutes) for new cards
  static const List<Duration> learningSteps = [
    Duration(minutes: 1),
    Duration(minutes: 10),
  ];

  /// Relearning steps (in minutes) for forgotten cards
  static const List<Duration> relearningSteps = [Duration(minutes: 10)];

  /// Graduating interval (in days) - when a card graduates from learning
  static const int graduatingInterval = 1;

  /// Easy interval (in days) - when a card is rated easy in learning
  static const int easyInterval = 4;

  /// Get FSRS parameters (can be customized per user in the future)
  static List<double> getParameters({String? userId}) {
    // TODO: Load user-specific parameters from database/preferences
    // For now, return default parameters
    return List.from(defaultParameters);
  }

  /// Get requested retention (can be customized per user in the future)
  static double getRequestRetention({String? userId}) {
    // TODO: Load user-specific retention from database/preferences
    // For now, return default retention
    return defaultRequestRetention;
  }
}
