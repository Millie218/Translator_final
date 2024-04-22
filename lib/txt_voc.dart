import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:translator/translator.dart';
import 'package:translatorapp/edit_profile.dart';
import 'package:speech_to_text/speech_to_text.dart';


class Translator extends StatefulWidget {
  const Translator({super.key});

  @override
  State<Translator> createState() => _TranslatorState();
}

class _TranslatorState extends State<Translator> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  String _selectedInputLanguage = 'en'; // Default input language is English
  String _selectedOutputLanguage = 'es'; // Default output language is Spanish

  final Map<String, String> _languageMap = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'ur': 'Urdu',
    'pa': 'Punjabi',
    'pa-PK': 'Punjabi (Pakistan)',
    'ps': 'Pashto',
    'ar' : 'Arabic',
    'de' : 'German',
    'zh-TW' : 'Chinese',
  };

   final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _textController.text = result.recognizedWords;
    });
  }


  void _translateText() async {
    String textToTranslate = _textController.text;

    GoogleTranslator translator = GoogleTranslator();
    Translation translation = await translator.translate(
      textToTranslate,
      from: _selectedInputLanguage,
      to: _selectedOutputLanguage,
    );

    setState(() {
      _translatedText = translation.text;
    });
  }

  void _swapLanguages() {
    setState(() {
      String temp = _selectedInputLanguage;
      _selectedInputLanguage = _selectedOutputLanguage;
      _selectedOutputLanguage = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade900,
        ),
        drawer: Drawer(
          // backgroundColor: Colors.blueGrey.shade800,
          child: ListView(
            children: [
              ListTile (),
              ListTile(
                leading: const Icon(Icons.person),
                title: TextButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const EditProfile()));
                },child: const Text('Edit Profile',style: TextStyle(color: Colors.white),),)
              ),
              ListTile(
                  leading: const Icon(Icons.logout),
                  title: TextButton(onPressed: () {
                    Navigator.pop(context);
                  },child: const Text('Logout',style: TextStyle(color: Colors.white)),)
              ),

            ],
          ),
        ),
        // backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: _selectedInputLanguage,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedInputLanguage = newValue!;
                          });
                        },
                        icon: const SizedBox(), // Hide the default dropdown icon

                        items: _languageMap.entries
                            .map<DropdownMenuItem<String>>(
                                (MapEntry<String, String> entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                      ),
                      SizedBox(width: 20,),
                      IconButton(
                        onPressed: _swapLanguages,
                        icon: const Icon(Icons.swap_horiz),
                      ),
                      const SizedBox(width: 20),
                      DropdownButton<String>(
                        value: _selectedOutputLanguage,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedOutputLanguage = newValue!;
                          });
                        },
                        icon: const SizedBox(), // Hide the default dropdown icon

                        items: _languageMap.entries
                            .map<DropdownMenuItem<String>>(
                                (MapEntry<String, String> entry) {
                              return DropdownMenuItem<String>(

                                value: entry.key,
                                child: Text(entry.value,style: TextStyle(color: Colors.white),),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    maxLines: null,
                    minLines: 5,
                    controller: _textController,
                    style: const TextStyle(fontSize: 25),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Text',
                      hintStyle: TextStyle(fontSize: 30),
                      // fillColor: Colors.black87,
                      // filled: true,

                      // enabledBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(10),
                      //   borderSide: const BorderSide(width: 2),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(10),
                      //   borderSide: BorderSide(width: 0),
                      // ),
                    ),
                  ),
                ),




                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _translateText,
                        child:  Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 40,
                            width: 200,
                            child: const Center(
                                child: Text(
                                  'Translate',
                                  style: TextStyle(color: Colors.white),
                                ))),
                      ),
                      SizedBox(width: 100,),
                      IconButton(
                        onPressed:_speechToText.isNotListening ? _startListening : _stopListening,
                        icon:  Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic,size: 30,),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(_translatedText,style: const TextStyle(color: Colors.white,fontSize: 20),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
