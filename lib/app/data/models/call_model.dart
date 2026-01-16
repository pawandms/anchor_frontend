import 'user_model.dart';

class CallModel {
  final String id;
  final UserModel caller;
  final List<UserModel> participants;
  final CallType type;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final bool isIncoming;

  CallModel({
    required this.id,
    required this.caller,
    required this.participants,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.duration,
    this.isIncoming = false,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] ?? '',
      caller: UserModel.fromJson(json['caller']),
      participants: (json['participants'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList(),
      type: CallType.values.firstWhere(
        (e) => e.toString() == 'CallType.${json['type']}',
        orElse: () => CallType.voice,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.toString() == 'CallStatus.${json['status']}',
        orElse: () => CallStatus.ended,
      ),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration']) 
          : null,
      isIncoming: json['isIncoming'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caller': caller.toJson(),
      'participants': participants.map((e) => e.toJson()).toList(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration?.inSeconds,
      'isIncoming': isIncoming,
    };
  }

  String get durationString {
    if (duration == null) return '00:00';
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

enum CallType {
  voice,
  video,
}

enum CallStatus {
  ringing,
  ongoing,
  ended,
  missed,
  declined,
}
