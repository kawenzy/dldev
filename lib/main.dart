import 'package:connectivity_watcher/connectivity_watcher.dart';
import 'package:flutter/material.dart';
import 'package:youtube_downloader/youtube_downloader.dart';
import 'package:facebook_video_download/facebook_video_download.dart';
import 'package:flutter_reels_downloader/flutter_reels_downloader.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController _url = TextEditingController();

  bool chek = false;
  String? s;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> chekUrl() async {
    String linkurl = _url.text;
    final provider = <String>["youtu", "instagram", "facebook"];
    if (linkurl.contains(provider[0])) {
      final VideoInfo? data =
          await YoutubeDownloader().downloadYoutubeVideo(linkurl, "mp3");
      return {"urls": data?.downloadUrl};
    }
    if (linkurl.contains(provider[1])) {
      final String igurl = await ReelDownloader().downloadReels(linkurl);
      return {"urls": igurl};
    }
    if (linkurl.contains(provider[2])) {
      final FacebookPost data = await FacebookData.postFromUrl(linkurl);
      return {"urls": data.videoHdUrl};
    } else {
      return {"urls": null};
    }
  }

  Future<void> download() async {
    final Map<String, dynamic> post = await chekUrl();
    final dynamic ck = post['urls'];
    debugPrint(ck);
    bool listen = await ConnectivityWatcher().hideNoInternet();
    if (!listen) {
      setState(() {
        s = "No Internet";
      });
    }
    if (ck == null) {
      setState(() {
        s = "Only Facebook, Instagram, Youtube Platforms";
      });
    }
    await MediaDownload().downloadMedia(context, '$ck');
    setState(() {
      s = "Downloaded";
      chek = true;
    });
    await FileDownloader.downloadFile(url: ck.toString() ,subPath: 'sdcard/download',notificationType: NotificationType.all);
  }

  @override
  Widget build(BuildContext context) {
  var responsive = getDeviceType(MediaQuery.of(context).size);
  double sizeButton = 0;
  switch(responsive) {
    case DeviceScreenType.desktop:
      sizeButton = 25;
      break;
    case DeviceScreenType.tablet:
      sizeButton = 20;
      break;
    case DeviceScreenType.mobile:
      sizeButton = 16;
      break;
    default:
      sizeButton = 10; 
  } 
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
            child: SingleChildScrollView(
              child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade100,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: TextField(
                      controller: _url,
                      autocorrect: false,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "paste your url",
                          hintStyle: GoogleFonts.ubuntu(
                              color: Colors.black54, fontWeight: FontWeight.w500),
                          prefixIcon: const Icon(
                            Icons.paste,
                            color: Colors.black87,
                            size: 26,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12)),
                      keyboardType: TextInputType.url,
                      style: GoogleFonts.ubuntu(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: download,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.blue.shade500,
                            borderRadius: BorderRadius.circular(4.0)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Text("Download", style: GoogleFonts.ubuntu(color: Colors.black87, fontSize: sizeButton, fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ]),
                      ),
            )),
      ),
    );
  }
}
