class ChatMessage {
  final String id;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromCustomer;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromCustomer,
  });
}
