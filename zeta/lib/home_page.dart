import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:zeta/color_pallete.dart';
import 'package:zeta/feature_box.dart';
import 'package:zeta/gemini_vision.dart';
import 'package:zeta/speech.dart';


import 'Gemini_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
final speechToText = SpeechToText();
final flutterTts = FlutterTts();

String lastWords = '';
  @override
  void initState(){
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async{
    await flutterTts.setSharedInstance(true);
    setState(() {

    });
  }

  Future<void> initSpeechToText() async {
  await speechToText.initialize();
  setState(() {

  });
  }

Future<void> startListening() async {
  await speechToText.listen(onResult: onSpeechResult);
  setState(() {});
}

Future<void> stopListening() async {
  await speechToText.stop();
  setState(() {});
}

void onSpeechResult(SpeechRecognitionResult result) {
  setState(() {
    lastWords = result.recognizedWords;
  });
}

Future<void> systemSpeak(String content) async{
    await flutterTts.speak(content);
}

@override
void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
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
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              height: 5,
            ),
            Stack(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 24, right: 8),
                    height: 150,
                    width: 150,
                    decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle),
                  ),
                ),
                Center(
                    child: Image.asset(
                  'assets/images/bot.png',
                  width: 165,
                )),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16)),
                  border: Border.all(
                    color: Pallete.borderColor,
                  )),
              child: const Text(
                "Good Morning, what task can I do for you?",
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    wordSpacing: 2.5,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Pallete.mainFontColor),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 28, bottom: 5, top: 10),
              child: const Text(
                'Here are a few features :',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    wordSpacing: 2.5,
                    letterSpacing: 1.5,
                    color: Pallete.mainFontColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => const GeminiChatPage()));
                  },
                  child: const featureBox(
                      clr: Pallete.firstSuggestionBoxColor,
                      txt1: 'Gemini',
                      txt2:
                          'A smarter way to stay organized and informed with Gemini AI'),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => const GeminiVisionPage()));
                  },
                  child: const featureBox(
                      clr: Pallete.secondSuggestionBoxColor,
                      txt1: 'Gemini Vision',
                      txt2:
                          'Stay creative with your personal assistant powered by Gemini AI'),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => speechText()));
                  },
                  child: const featureBox(
                      clr: Pallete.thirdSuggestionBoxColor,
                      txt1: 'Smart Voice Assistant',
                      txt2:
                          'Get the best with a voice assistant powered by Gemini AI'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        if(await speechToText.hasPermission && speechToText.isNotListening){
          await startListening();
        }
        else if(speechToText.isListening){
          await stopListening();
        }
        else{
          initSpeechToText();
        }

      },
        child: const Icon(Icons.mic, size: 30, color: Colors.black,),
        backgroundColor: Pallete.firstSuggestionBoxColor,
      ),
    );
  }
}
