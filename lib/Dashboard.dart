// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _PlayVideoFromNetworkState();
}

class _PlayVideoFromNetworkState extends State<Dashboard> {
  late final PodPlayerController controller;
  late final Timer periodicTimer;
  var playVideo = false;
  late var arr = [];
  var index = 0;
  late var mediaType = null;
  late var imageUrl = "";
  late var videoUrl = "";
  late var htmlUrl = "";
  var hasVideo = false;
  var loading = false;
  //late final WebViewController _controller;

  _getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var screenCode = prefs.getString('screen_code');
    print(screenCode);
    Map data = {'screen_code': screenCode};
    setState(() {
      loading = true;
    });
    final response = await http.post(
      Uri.parse('http://143.110.181.88/api/sequence_result'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: data,
    );
    // ignore: prefer_typing_uninitialized_variables, deprecated_member_use
    //List<dynamic> values = <dynamic>[];
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
      });
      var values = json.decode(response.body) as Map<String, dynamic>;
      print(values['data']);
      print("-------------------------");
      var estateSelected = values["data"].firstWhere(
          (dropdown) => dropdown['media_type'] == "videos",
          orElse: () => null);
      // print(estateSelected);
      // print("+++++++++++++++++++++________________________");
      // print(estateSelected["media_fullurl"]);
      if (estateSelected != null) {
        controller = PodPlayerController(
            playVideoFrom:
                PlayVideoFrom.network(estateSelected["media_fullurl"]),
            podPlayerConfig: const PodPlayerConfig(
                autoPlay: true, isLooping: false, initialVideoQuality: 360))
          ..initialise();
        setState(() {
          hasVideo = true;
        });
      } else {
        setState(() {
          hasVideo = false;
        });
      }

      setState(() {
        arr = values["data"];
      });
      print(arr);

      //setMediaTimer(arr[index].template_duration_min * 60);
      var item = arr[index] as Map<String, dynamic>;
      setState(() {
        mediaType = item["media_type"];
      });
      if (mediaType == "html") {
        setState(() {
          htmlUrl = item["html_fileurl"];
        });
        if (hasVideo) {
          controller.pause();
          controller.videoSeekTo(Duration(seconds: 0));
        }

        print(mediaType);
        print(htmlUrl);
      }
      if (mediaType == "images") {
        setState(() {
          imageUrl = item["media_fullurl"];
        });
      }
      if (mediaType == "videos") {
        setState(() {
          videoUrl = item["media_fullurl"];
        });

        controller.play();
      }
      setMediaTimer(item["template_duration_min"] * 60);
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  setMediaTimer(interval) {
    // if (interval) {
    print(interval);
    Timer.periodic(Duration(seconds: interval), (timer) {
      var currIndex = index = (index + 1) % arr.length;
      setState(() {
        index = currIndex;
      });
      timer.cancel();
      var item = arr[index] as Map<String, dynamic>;
      //var item = arr[index] as Map<String, dynamic>;
      setState(() {
        mediaType = item["media_type"];
      });
      if (mediaType == "html") {
        setState(() {
          htmlUrl = item["html_fileurl"];
        });
        if (hasVideo) {
          controller.pause();
          controller.videoSeekTo(Duration(seconds: 0));
        }
        print(mediaType);
        print(htmlUrl);
      }
      if (mediaType == "images") {
        setState(() {
          imageUrl = item["media_fullurl"];
        });
        if (hasVideo) {
          controller.pause();
          controller.videoSeekTo(Duration(seconds: 0));
        }
      }
      if (mediaType == "videos") {
        setState(() {
          videoUrl = item["media_fullurl"];
        });
        if (hasVideo) {
          controller.play();
        }
      }
      setMediaTimer(item["template_duration_min"] * 60);
    });
    //}
  }

  @override
  void initState() {
    _getData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //print("WidgetsBinding");
      // periodicTimer = Timer.periodic(
      //   const Duration(seconds: 30),
      //   (timer) {
      //     var currIndex = index = (index + 1) % arr.length;
      //     var layVideo = !playVideo;
      //     setState(() {
      //       playVideo = layVideo;
      //     });
      //     setState(() {
      //       index = currIndex;
      //     });

      //     if (currIndex == 1) {
      //       controller.play();
      //     } else {
      //       controller.pause();
      //       controller.videoSeekTo(Duration(seconds: 0));
      //     }
      //     // Update user about remaining time
      //   },
      // );
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // _loadHtmlFromAssets() async {
  //   String fileText =
  //       await rootBundle.loadString('assets/1656681373template-tile.html');
  //   _controller.loadUrl(Uri.dataFromString(fileText,
  //           mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
  //       .toString());
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255)),
      home: SafeArea(
          child: loading
              ? SizedBox(
                  height: 100,
                  width: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : arr.length > 0
                  ? Scaffold(
                      body: mediaType == 'html'
                          ? WebView(
                              initialUrl: htmlUrl,
                            )
                          : mediaType == 'videos'
                              ? Container(
                                  // padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  width: double.infinity,
                                  alignment: Alignment.topCenter,
                                  child: PodVideoPlayer(controller: controller),
                                )
                              : Container(
                                  // padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.network(imageUrl,
                                      fit: BoxFit.fitHeight),
                                ))
                  : Scaffold(
                      body: Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Text("No Data Found")))),
    );
  }
}
