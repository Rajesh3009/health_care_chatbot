
enum MessageRole { user, assistant }

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final String conversationId;

  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.conversationId = '',
  });

  // Conversion methods for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'role': role.toString(),
        'timestamp': timestamp.toIso8601String(),
        'conversationId': conversationId,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        content: json['content'],
        role: json['role'] == 'MessageRole.assistant'
            ? MessageRole.assistant
            : MessageRole.user,
        timestamp: DateTime.parse(json['timestamp']),
        conversationId: json['conversationId'] ?? '',
      );
}
