import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgpt/const.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final openAI = OpenAI.instance.build(
      token: OPENAI_API_KEY,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);
  final ChatUser currentUser =
      ChatUser(id: "1", firstName: "Nimra", lastName: "Amjad");
  final ChatUser gptUser =
      ChatUser(id: "2", firstName: "Bilal", lastName: "Amjad");

  List<ChatMessage> messages = <ChatMessage>[];
  List<ChatUser> typingUser = <ChatUser>[];

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      messages.insert(0, m);
      typingUser.add(gptUser);
    });
    List<Messages> messagesHistory = messages.reversed.map((m) {
      if (m.user == currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(
        model: GptTurbo0301ChatModel(),
        messages: messagesHistory,
        maxToken: 200);
    final response = await openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          messages.insert(
              0,
              ChatMessage(
                  user: gptUser,
                  createdAt: DateTime.now(),
                  text: element.message!.content));
        });
      }
    }
    setState(() {
      typingUser.remove(gptUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 166, 126, 1),
        title: const Text(
          "GPT Chat",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: DashChat(
          typingUsers: typingUser,
          messageOptions: const MessageOptions(
              currentUserContainerColor: Colors.black,
              containerColor: Color.fromRGBO(0, 166, 126, 1),
              textColor: Colors.white),
          currentUser: currentUser,
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: messages),
    );
  }
}
