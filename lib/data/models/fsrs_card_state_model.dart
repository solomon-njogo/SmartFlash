import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fsrs_card_state_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class FSRSCardState {
  @HiveField(0)
  final DateTime due;

  @HiveField(1)
  final double stability;

  @HiveField(2)
  final double difficulty;

  @HiveField(3)
  final int elapsedDays;

  @HiveField(4)
  final int scheduledDays;

  @HiveField(5)
  final int reps;

  @HiveField(6)
  final int lapses;

  @HiveField(7)
  final int state;

  @HiveField(8)
  final DateTime lastReview;

  const FSRSCardState({
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.scheduledDays,
    required this.reps,
    required this.lapses,
    required this.state,
    required this.lastReview,
  });

  factory FSRSCardState.initial() {
    final now = DateTime.now();
    return FSRSCardState(
      due: now,
      stability: 2.5,
      difficulty: 5.0,
      elapsedDays: 0,
      scheduledDays: 0,
      reps: 0,
      lapses: 0,
      state: 0, // New state
      lastReview: now,
    );
  }

  factory FSRSCardState.fromJson(Map<String, dynamic> json) =>
      _$FSRSCardStateFromJson(json);

  Map<String, dynamic> toJson() => _$FSRSCardStateToJson(this);

  FSRSCardState copyWith({
    DateTime? due,
    double? stability,
    double? difficulty,
    int? elapsedDays,
    int? scheduledDays,
    int? reps,
    int? lapses,
    int? state,
    DateTime? lastReview,
  }) {
    return FSRSCardState(
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  bool get isDueForReview {
    return DateTime.now().isAfter(due) || DateTime.now().isAtSameMomentAs(due);
  }

  @override
  String toString() {
    return 'FSRSCardState(due: $due, stability: $stability, difficulty: $difficulty, elapsedDays: $elapsedDays, scheduledDays: $scheduledDays, reps: $reps, lapses: $lapses, state: $state, lastReview: $lastReview)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FSRSCardState &&
        other.due == due &&
        other.stability == stability &&
        other.difficulty == difficulty &&
        other.elapsedDays == elapsedDays &&
        other.scheduledDays == scheduledDays &&
        other.reps == reps &&
        other.lapses == lapses &&
        other.state == state &&
        other.lastReview == lastReview;
  }

  @override
  int get hashCode {
    return due.hashCode ^
        stability.hashCode ^
        difficulty.hashCode ^
        elapsedDays.hashCode ^
        scheduledDays.hashCode ^
        reps.hashCode ^
        lapses.hashCode ^
        state.hashCode ^
        lastReview.hashCode;
  }
}