import 'package:equatable/equatable.dart';

class Motion extends Equatable {
  final int floorsAscended, numberOfSteps, floorsDescended;
  final double distance, averageActivePace, currentPace;
  final DateTime? startDate, endDate;

  const Motion(
      {this.floorsDescended = 0,
      this.endDate,
      this.floorsAscended = 0,
      this.numberOfSteps = 0,
      this.distance = 0,
      this.startDate,
      this.averageActivePace = 0,
      this.currentPace = 0});

  factory Motion.fromJSON(Map<String, dynamic> data) => Motion(
        numberOfSteps: data['numberOfSteps'] ?? 0,
        floorsAscended: data['floorsAscended'] ?? 0,
        floorsDescended: data['floorsDescended'] ?? 0,
        distance: data['distance'] ?? 0,
        startDate: DateTime.fromMillisecondsSinceEpoch(
            ((data['startDate'] as num?) ?? 0.0).toInt()),
        endDate: DateTime.fromMillisecondsSinceEpoch(
            ((data['endDate'] as num?) ?? 0.0).toInt()),
        averageActivePace: data['averageActivePace'] ?? 0,
        currentPace: data['currentPace'] ?? 0,
      );

  Map<String, dynamic> get toJSON => {
        'floorsAscended': floorsAscended,
        'floorsDescended': floorsDescended,
        'startDate': startDate,
        'endDate': endDate,
        'currentPace': currentPace,
        'averageActivePace': averageActivePace,
        'numberOfSteps': numberOfSteps,
        'distance': distance
      };

  @override
  String toString() => toJSON.toString();

  @override
  List<Object?> get props => [
        floorsAscended,
        numberOfSteps,
        distance,
        averageActivePace,
        currentPace,
        startDate
      ];
}
