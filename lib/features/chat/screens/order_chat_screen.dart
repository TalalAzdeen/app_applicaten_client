import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chat_model.dart';

class OrderChatScreen extends StatefulWidget {
  final String orderId;
  final String referenceNumber;
  final String technicianName;

  const OrderChatScreen({
    super.key,
    required this.orderId,
    required this.referenceNumber,
    required this.technicianName,
  });

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      senderName: 'النظام',
      message: 'مرحباً بك! تم فتح المحادثة المباشرة الخاصة بالطلب. المحادثة محمية ومخصصة لتنسيق تنفيذ الخدمة.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isFromCustomer: false,
    ),
    ChatMessage(
      id: 'm2',
      senderName: 'الفني',
      message: 'السلام عليكم، أنا في الطريق إليك حالياً وسأصل خلال 10 دقائق بإذن الله.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isFromCustomer: false,
    ),
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          senderName: 'أنت',
          message: text,
          timestamp: DateTime.now(),
          isFromCustomer: true,
        ),
      );
    });

    _msgController.clear();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'm_reply_${DateTime.now().millisecondsSinceEpoch}',
            senderName: widget.technicianName,
            message: 'تم استلام رسالتك، شكراً لك.',
            timestamp: DateTime.now(),
            isFromCustomer: false,
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('محادثة الطلب ${widget.referenceNumber}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('الفني: ${widget.technicianName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: Colors.amber[100],
            child: Row(
              children: const [
                Icon(Icons.lock_outline, size: 16, color: Colors.black87),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'هذه المحادثة مشفرة ومحمية بخصوصية الطلب وفق سياسة صلّح SALLIH',
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isFromCustomer ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isFromCustomer ? AppTheme.primaryTeal : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: msg.isFromCustomer ? const Radius.circular(12) : Radius.zero,
                        bottomRight: msg.isFromCustomer ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.message,
                          style: TextStyle(
                            color: msg.isFromCustomer ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 10,
                              color: msg.isFromCustomer ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: AppTheme.primaryTeal),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم اختيار صورة لإرسالها بالمحادثة')),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك للفني...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryTeal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
