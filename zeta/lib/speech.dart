import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:zeta/color_pallete.dart';
import 'package:zeta/repos/gemini_api.dart';

import 'models/chat_message_model.dart';

class speechText extends StatefulWidget {
  const speechText({super.key});

  @override
  State<speechText> createState() => _speechToTextState();
}

class _speechToTextState extends State<speechText> {
  final speechToText = SpeechToText();
  bool isSpeechEnabled = false;
  bool enableSpeak = true;
  String wordsSpoken = '';
  FlutterTts flutterTts = FlutterTts();
  Map? currentVoice;
  List<ChatModel> chatList = [];

  @override
  void initState() {
    super.initState();
    initSpeech();
    initTts();
  }

  void initSpeech() async {
    isSpeechEnabled = await speechToText.initialize();
    setState(() {});
  }

  void startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      wordsSpoken = result.recognizedWords;
    });
  }

  void onSendMessage() async {
    ChatModel model = ChatModel(isMe: true, message: wordsSpoken);

    chatList.insert(0, model);
    setState(() {
      wordsSpoken = '';
    });
    final geminiModel = await sendRequestToGemini(model);

    setState(() {
      chatList.insert(0, geminiModel);
      stopListening();
    });
  }

  void initTts() {
    flutterTts.getVoices.then((data) {
      try{
        List<Map> voices = List<Map>.from(data);
        voices = voices.where((voice) => voice["name"].contains("en")).toList();
        setState(() {
          currentVoice = voices.elementAt(11);
          setVoice(currentVoice!);
        });
      }
      catch(e){
        print(e);
      }
    });
  }
  void setVoice(Map voice) {
    flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});

  }

  void stopVoice(){
    flutterTts.stop();
  }

  Future<ChatModel> sendRequestToGemini(ChatModel model) async {
    final url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${GeminiAPIKey.api_key}";
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
              flex: 9,
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
                      trailing: chatList[index].isMe? null : InkWell(
                        onTap: () {
                          setState(() {
                            enableSpeak? flutterTts.speak(chatList[index].message) : stopVoice() ;
                            enableSpeak = !enableSpeak;
                          });
                        },
                          child: Image.asset('assets/images/bot1.png'),),
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
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  speechToText.isListening
                      ? '$wordsSpoken'
                      : isSpeechEnabled
                      ? 'Tap the microphone to start listening...'
                      : 'Speech not available',
                style: TextStyle(
                  fontSize: 19
                ),),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SizedBox(width: double.infinity, height: 55),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(left: 37),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed :
              speechToText.isNotListening ? startListening : onSendMessage,
              tooltip: 'Listen',
              backgroundColor: Pallete.assistantCircleColor,
              child: Icon(speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                color: Pallete.borderColor,
                size: 27
              ),
            ),
          ),
        )
    );
  }
}
