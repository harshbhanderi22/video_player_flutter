import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_storage_path/flutter_storage_path.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player_flutter/Screens/video_play_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<File> _videos = [];
  final List<File> _thumbnails = [];
  final List<String> _links=[];



  // Future<Uint8List?> _generateThumbnail(File videoFile) async {
  //   final uint8list = await VideoThumbnail.thumbnailData(
  //     video: videoFile.path,
  //     imageFormat: ImageFormat.JPEG,
  //     maxWidth: 128, // specify the width of the thumbnail, in this case, 128
  //     quality:
  //         25, // specify the quality of the thumbnail image, in this case, 25%
  //   );
  //   return uint8list;
  // }
 
 

  @override
  void initState() {
    getVideoPath();
    super.initState();
     
  }
  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
  Future<void> getVideoPath() async {
    String? videoPath = "";
    try {
      videoPath = await StoragePath.videoPath;
      List<dynamic> response = jsonDecode(videoPath!);
      print("length is ${response.length}");
      for(int i=0;i<response.length;i++){
        List linkList = response[i]["files"];
        if(linkList.length>1){
          for(int i=0;i<linkList.length;i++){
            String link = linkList[i]["path"];
            if(link.substring(link.length-3)=="mkv"){
              continue;
            }
            else{
              final File file = File(link);
              _links.add(link);

              setState(() {
                _videos.add(file);
              });
            }
          }
        }
        else{
          String link = linkList[0]["path"];
          if(link.substring(link.length-3)=="mkv"){
            continue;
          }
          else{
            final File file = File(link);
            _links.add(link);
            setState(() {
              _videos.add(file);
            });

          }
        }
      }

    } on PlatformException {
      videoPath = 'Failed to get path';
    }
    print("Length of video is ${_videos.length}");
  }


  Future<String> _getImage(videoPathUrl) async {
     final thumb = await VideoThumbnail.thumbnailFile(
        video: videoPathUrl,
            imageFormat: ImageFormat.PNG,
      thumbnailPath: (await getTemporaryDirectory()).path,

    );
    print(thumb);

    return thumb!;
  }

  @override
  Widget build(BuildContext context) {


    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text("Video Player"),
        centerTitle: true,
      ),
      body: _videos.length>0 ? Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: GridView.builder(
          itemCount: _videos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerWidget(
                    _videos[index],
                  ),
                ),
              ),
              child: Container(

                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(color: Colors.white,width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10
                      )
                    ]
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        // Where the linear gradient begins and ends
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        stops: [0.1, 0.3, 0.5, 0.7, 0.9],
                        colors: [
                          Color(0xffb7d8cf),
                          Color(0xffb7d8cf),
                          Color(0xffb7d8cf),
                          Color(0xffb7d8cf),
                          Color(0xffb7d8cf),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(15))),
                          child: _videos==null ? CircularProgressIndicator() : FutureBuilder<String?>(
                              future: _getImage(_links[index]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    return Stack(
                                      children: [
                                        Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          child: Hero(
                                            tag: _videos[index],
                                            child: snapshot.data!.length==0 ? CircularProgressIndicator() :
                                            Image.file(
                                              File(snapshot.data!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: Colors.black.withOpacity(0.4),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.play_circle_outline,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                        )
                                      ],
                                    );
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                } else {
                                  return Hero(
                                    tag: _videos[index],
                                    child: SizedBox(
                                      height: 280.0,
                                      child: Lottie.asset('assests/json/load.json'),
                                    ),
                                  );
                                }
                              }),
                        ),

                      ],
                    ),

                  ),
                ),
              ),
            );
          },
        ),
      ): Text("No VIdeo Found"),
    ));
  }
}
