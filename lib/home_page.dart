import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/feature_box.dart';
import 'package:voice_assistant/openai_service.dart';
import 'package:voice_assistant/pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  final flutterTts = FlutterTts();
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    // log(lastWords);
    setState(() {});
  }

  Future<void> callApi(String lastWords) async {
    final speech = await openAIService.isArtPromptAPI(lastWords);
    if (speech.contains('https')) {
      generatedImageUrl = speech;
      generatedContent = null;
      setState(() {});
    } else {
      generatedImageUrl = null;
      generatedContent = speech;
      setState(() {});
    }
    await systemSpeak(generatedContent);
    log(speech);
  }

  Future<void> onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      lastWords = result.recognizedWords;
      if (result.toString().contains('final: true')) {
        callApi(lastWords);
      }
    });
  }

  Future<void> systemSpeak(String? content) async {
    if (content != null) {
      await flutterTts.speak(content);
    }
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
        title: const Text("Assistant"),
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/assistant.png',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Visibility(
              visible: generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40)
                    .copyWith(top: 30),
                decoration: BoxDecoration(
                    border: Border.all(color: Pallete.borderColor),
                    borderRadius: BorderRadius.circular(20)
                        .copyWith(topLeft: Radius.zero)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    generatedContent == null
                        ? "Good Morning, what task can I do for you"
                        : generatedContent!,
                    style: TextStyle(
                      color: Pallete.mainFontColor,
                      fontFamily: 'Cera Pro',
                      fontSize: generatedContent == null ? 20 : 18,
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!)),
              ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(
                  top: 10,
                  left: 22,
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Here are few features',
                  style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: const Column(
                children: [
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: "ChatGpt",
                    descriptionText:
                        "A smarter way to stay organized and informed with ChatGPT",
                  ),
                  FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: "Dall-E",
                    descriptionText:
                        "Get inspired and stay creative with your personal assistant powerd by Dall-E",
                  ),
                  FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: "Smart Voice Assistant",
                    descriptionText:
                        "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT",
                  )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: const Icon(Icons.mic),
      ),
    );
  }
}
