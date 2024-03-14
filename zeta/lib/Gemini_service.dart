import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zeta/color_pallete.dart';
import 'package:zeta/repos/gemini_api.dart';
import 'models/chat_message_model.dart';
import 'package:http/http.dart' as http;

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({Key? key}) : super(key: key);

  @override
  State<GeminiChatPage> createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  List<ChatModel> chatList = [];
  late TextEditingController controller = TextEditingController(); // Initialize controller

  void onSendMessage() async {
    ChatModel model = ChatModel(isMe: true, message: controller.text);

    chatList.insert(0, model);
    setState(() {
      controller.clear();
    });
    final geminiModel = await sendRequestToGemini(model);

    setState(() {
      chatList.insert(0, geminiModel);
    });
  }

  void selectImage() async {
    // Implement image selection functionality if needed
  }

  Future<ChatModel> sendRequestToGemini(ChatModel model) async {
    const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${GeminiAPIKey.api_key}";
    Uri uri = Uri.parse(url);

    try {
      final result = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": model.message}
              ]
            }
          ]
        }),
      );

      if (result.statusCode == 200) {
        final decodedJson = json.decode(result.body);
        String message =
        decodedJson['candidates'][0]['content']['parts'][0]['text'];

        ChatModel geminiModel = ChatModel(isMe: false, message: message);
        return geminiModel;
      } else {
        print("Error: ${result.statusCode}");
        return ChatModel(isMe: false, message: "Error: ${result.statusCode}");
      }
    } catch (error) {
      // Handle any errors that occur during the HTTP request
      print("Error: $error");
      return ChatModel(isMe: false, message: "Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zeta',
          style: TextStyle(
            fontFamily: 'FasterOne',
            fontSize: 45,
            color: Pallete.borderColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatList.length,
              reverse: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  decoration: BoxDecoration(
                      borderRadius: chatList[index].isMe
                          ? BorderRadius.all(Radius.circular(16))
                          .copyWith(topLeft: Radius.circular(0))
                          : BorderRadius.all(Radius.circular(16))
                          .copyWith(topRight: Radius.circular(0)),
                      border: Border.all(
                          color: chatList[index].isMe
                              ? Colors.pink
                              : Pallete.secondSuggestionBoxColor,
                          width: 2.0
                      )
                  ),
                  child: ListTile(
                    leading: chatList[index].isMe
                        ? Transform.scale(
                          scale: 1.20, // Adjust the scale factor as needed
                          child: Image.asset('assets/images/user.png'),
                    )
                        : null,
                    trailing: chatList[index].isMe? null : Image.asset('assets/images/bot1.png'),
                    title: Align(
                        alignment: chatList[index].isMe? Alignment.centerLeft : Alignment.centerRight,
                        child: Text(chatList[index].isMe ? "Me" : "")),
                    subtitle: chatList[index].base64EncodedImage != null
                        ? Column(
                      children: [
                        Image.memory(
                          base64Decode(
                              chatList[index].base64EncodedImage!),
                          width: double.infinity,
                          height: 300,
                        ),
                        Text(chatList[index].message)
                      ],
                    )
                        : Text(chatList[index].message),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 50, left: 15, right: 15),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: TextField(
                onSubmitted: (_) => onSendMessage(),
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: CupertinoButton(
                child: const Icon(
                  Icons.send,
                  size: 35,
                  color: Pallete.borderColor,
                ),
                onPressed: () {
                  onSendMessage(); // Call the function to send message
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
