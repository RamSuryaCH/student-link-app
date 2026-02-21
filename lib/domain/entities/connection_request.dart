import 'package:equatable/equatable.dart';

enum ConnectionStatus {
  pending,
  accepted,
  rejected,
}

class ConnectionRequest extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final ConnectionStatus status;
  final DateTime createdAt;

  const ConnectionRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ConnectionRequest.fromMap(Map<String, dynamic> map) {
    return ConnectionRequest(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: ConnectionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  ConnectionRequest copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    ConnectionStatus? status,
    DateTime? createdAt,
  }) {
    return ConnectionRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, senderId, receiverId, status, createdAt];
}
