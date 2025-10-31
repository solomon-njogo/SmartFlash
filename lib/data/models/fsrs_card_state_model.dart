import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:fsrs/fsrs.dart';
import 'dart:math';

part 'fsrs_card_state_model.g.dart';

/// FSRS Card State model for storing FSRS algorithm state
@HiveType(typeId: 30)
@JsonSerializable()
class FSRSCardState extends HiveObject {
  @HiveField(0)
  final int cardId;

  @HiveField(1)
  final State state;

  @HiveField(2)
  final int step;

  @HiveField(3)
  final double? stability;

  @HiveField(4)
  final double? difficulty;

  @HiveField(5)
  final DateTime due;

  @HiveField(6)
  final DateTime? lastReview;

  FSRSCardState({
    required this.cardId,
    required this.state,
    required this.step,
    this.stability,
    this.difficulty,
    required this.due,
    this.lastReview,
  });

  /// Create FSRSCardState from JSON
  factory FSRSCardState.fromJson(Map<String, dynamic> json) =>
      _$FSRSCardStateFromJson(json);

  /// Convert FSRSCardState to JSON
  Map<String, dynamic> toJson() => _$FSRSCardStateToJson(this);

  /// Create a copy of FSRSCardState with updated fields
  FSRSCardState copyWith({
    int? cardId,
    State? state,
    int? step,
    double? stability,
    double? difficulty,
    DateTime? due,
    DateTime? lastReview,
  }) {
    return FSRSCardState(
      cardId: cardId ?? this.cardId,
      state: state ?? this.state,
      step: step ?? this.step,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  /// Check if card is due for review
  bool get isDueForReview {
    return DateTime.now().isAfter(due);
  }

  /// Get retrievability (probability of successful recall)
  double getRetrievability(DateTime now) {
    if (stability == null || lastReview == null) return 0.0;
    final daysSinceLastReview = now.difference(lastReview!).inDays;
    return pow(
      1 + (daysSinceLastReview / 9) * (1 / stability! - 1),
      -1,
    ).toDouble();
  }

  /// Create FSRSCardState from FSRS Card object
  factory FSRSCardState.fromFSRSCard(Card card) {
    return FSRSCardState(
      cardId: card.cardId,
      state: card.state,
      step: card.step ?? 0,
      stability: card.stability,
      difficulty: card.difficulty,
      due: card.due,
      lastReview: card.lastReview,
    );
  }

  /// Convert to FSRS Card object
  Card toFSRSCard() {
    return Card(
      cardId: cardId,
      state: state,
      step: step,
      stability: stability,
      difficulty: difficulty,
      due: due,
      lastReview: lastReview,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FSRSCardState &&
        other.cardId == cardId &&
        other.state == state &&
        other.step == step &&
        other.stability == stability &&
        other.difficulty == difficulty &&
        other.due == due &&
        other.lastReview == lastReview;
  }

  @override
  int get hashCode {
    return Object.hash(
      cardId,
      state,
      step,
      stability,
      difficulty,
      due,
      lastReview,
    );
  }

  @override
  String toString() {
    return 'FSRSCardState(cardId: $cardId, state: $state, step: $step, stability: $stability, difficulty: $difficulty, due: $due)';
  }
}
