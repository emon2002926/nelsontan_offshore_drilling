import 'package:flutter/material.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/text/app_text.dart';

import '../../../core/util/screen_size.dart';
import '../../video_player/models/video_source.dart';
import '../../video_player/widgets/app_video_player.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});
  final assetsIcon = AppAssertImage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              topHeader(context,assetsIcon.topHeaderIcon,assetsIcon.topHeaderNotificationIcon),
              AppVideoPlayer(
                // For assets (current)
                videoSource: VideoSource.asset('assets/videos/demo.mp4'),

                // For API (later)
                // videoSource: VideoSource.network('https://api.example.com/video.mp4'),

                width: MediaQuery.of(context).size.width * 0.9,
                height: 250,
                borderRadius: 16,
                autoPlay: false,
              ),
            ],
          ),
        ),
      ),
    );
  }




  Widget topHeader(BuildContext context,String headerSaveIcon,String headerNotificationIcon){
    return Container(
      width: MediaQuery.of(context).size.width,
      height:  context.heightPercentage(5),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              headerSaveIcon
            ),
          ),
          AppText(data: "Hello",fontSize: 20,fontWeight: FontWeight.w600,),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
                headerNotificationIcon
            ),
          ),

        ],
      ) ,
    );
  }
}
