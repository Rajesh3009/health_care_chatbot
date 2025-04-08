import 'package:uuid/uuid.dart';

enum MessageRole { user, assistant }

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  
  Message({
    String? id,
    required this.content,
    required this.role,
    DateTime? timestamp,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();
  
  // Conversion methods for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'role': role.toString(),
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    content: json['content'],
    role: json['role'] == 'MessageRole.assistant' 
        ? MessageRole.assistant 
        : MessageRole.user,
    timestamp: DateTime.parse(json['timestamp']),
  );
}
