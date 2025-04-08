import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

// Provider for chat history
final historyProvider = StateNotifierProvider<HistoryNotifier, List<List<Message>>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<List<Message>>> {
  HistoryNotifier() : super([]) {
    _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('chat_history') ?? [];
      
      final loadedHistory = historyJson.map((chatJson) {
        final List<dynamic> chatData = jsonDecode(chatJson);
        return chatData.map((msgJson) => Message.fromJson(msgJson)).toList();
      }).toList();
      
      state = loadedHistory;
    } catch (e) {
      // If there's an error loading history, just start with empty state
      state = [];
    }
  }
  
  Future<void> saveChat(List<Message> chat) async {
    if (chat.isEmpty) return;
    
    // Add to state
    state = [...state, chat];
    
    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = state.map((chat) {
        final chatJson = chat.map((msg) => msg.toJson()).toList();
        return jsonEncode(chatJson);
      }).toList();
      
      await prefs.setStringList('chat_history', historyJson);
    } catch (e) {
      // Handle error silently
      print('Error saving chat history: $e');
    }
  }
  
  Future<void> clearHistory() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_history');
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }
}
