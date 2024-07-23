import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:unyo/screens/video_screen.dart';
import 'package:unyo/util/utils.dart';
import 'package:unyo/widgets/widgets.dart';
import 'package:unyo/screens/screens.dart';

class VideoProgressSlider extends StatelessWidget {
  VideoProgressSlider({
    super.key,
    required this.position,
    required this.duration,
    required this.mixedController,
    required this.source,
    required this.onTap,
  });

  final Duration position;
  final Duration duration;
  final MixedController mixedController;
  final int source;
  final void Function() onTap;

  final TextEditingController textFieldcontroller = TextEditingController();

  String getUtf8Text(String text) {
    List<int> bytes = text.codeUnits;
    return utf8.decode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.clamp(0, max).toDouble();
    return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: lightBorderColor),
        useMaterial3: true,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 24,
              ),
              ValueListenableBuilder(
                builder: (context, value, child) {
                  return Text(
                    mixedController.videoController.value.position
                        .toString()
                        .substring(0, 7),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  );
                },
                valueListenable: mixedController.videoController,
              ),
              Expanded(
                child: Slider(
                  min: 0,
                  max: max,
                  value: value,
                  onChanged: (value) {
                    // controller.seekTo(Duration(milliseconds: value.toInt()));
                    mixedController
                        .seekTo(Duration(microseconds: (value * 1000).toInt()));
                    mixedController.mqqtController.sendOrder("seekTo:$value");
                  },
                  // onChangeEnd: (value) {
                  // mixedController.mqqtController.sendOrder("seekTo:$value");
                  // },
                ),
              ),
              Text(
                !(prefs.getBool("display_video_duration") ?? false)
                    ? mixedController.videoController.value.duration
                        .toString()
                        .substring(0, 7)
                    : Duration(
                            milliseconds: mixedController.videoController.value
                                    .duration.inMilliseconds -
                                mixedController.videoController.value.position
                                    .inMilliseconds)
                        .toString()
                        .substring(0, 7),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(
                width: 24,
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 12,
              ),
              Tooltip(
                message: "Previous Episode",
                child: IconButton(
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
              Tooltip(
                message: mixedController.isPlaying ? "Pause" : "Play",
                child: IconButton(
                  icon: !mixedController.isPlaying
                      ? const Icon(
                          Icons.play_arrow_rounded,
                          size: 28,
                        )
                      : const Icon(Icons.pause_rounded, size: 28),
                  color: Colors.white,
                  // style: const ButtonStyle(iconSize: MaterialStatePropertyAll(35)),
                  onPressed: () {
                    if (!mixedController.isPlaying) {
                      onTap();
                      mixedController.play(sendCommand: true);
                    } else {
                      onTap();
                      mixedController.pause(sendCommand: true);
                    }
                  },
                ),
              ),
              Tooltip(
                message: "Next Episode",
                child: IconButton(
                  icon:
                      const Icon(Icons.skip_next_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton<TrackData>(
                      tooltip: "Change Audiotrack",
                      color: const Color.fromARGB(255, 34, 33, 34),
                      icon: const Icon(
                        Icons.audiotrack,
                        color: Colors.white,
                      ),
                      onSelected: (newSubTrack) {
                        int newPos = mixedController.streamData.tracks![source]
                            .indexOf(newSubTrack);
                        mixedController.changeSubTrack(newPos);
                      },
                      itemBuilder: (BuildContext context) {
                        return mixedController.streamData.tracks != null
                            ? mixedController.streamData.tracks![source]
                                .map((trackData) => PopupMenuItem<TrackData>(
                                      value: trackData,
                                      child: SizedBox(
                                        width: 200,
                                        child: Text(
                                          getUtf8Text(trackData.lang),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ))
                                .toList()
                            : [];
                      },
                    ),
                    PopupMenuButton<CaptionData>(
                      tooltip: "Change Subtitles",
                      color: const Color.fromARGB(255, 34, 33, 34),
                      icon: const Icon(
                        Icons.subtitles,
                        color: Colors.white,
                      ),
                      onSelected: (newCaptionData) {
                        int newPos = mixedController
                            .streamData.captions![source]
                            .indexOf(newCaptionData);
                        mixedController.changeCaption(newPos);
                      },
                      itemBuilder: (BuildContext context) {
                        return mixedController.streamData.captions != null
                            ? mixedController.streamData.captions![source]
                                .map(
                                    (captionData) => PopupMenuItem<CaptionData>(
                                          value: captionData,
                                          child: SizedBox(
                                            width: 200,
                                            child: Text(
                                              getUtf8Text(captionData.lang),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ))
                                .toList()
                            : [];
                      },
                    ),
                    Tooltip(
                      message: "Unyo2gether",
                      child: IconButton(
                        icon: const Icon(
                          Icons.people,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                    "Unyo2gether(${mixedController.mqqtController.connected ? "Connected" : "Not Connected"})",
                                    style:
                                        const TextStyle(color: Colors.white)),
                                backgroundColor:
                                    const Color.fromARGB(255, 44, 44, 44),
                                content: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                          "Your Id:\n${mixedController.mqqtController.topic.substring(mixedController.mqqtController.topic.indexOf("-") + 1)}",
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text(
                                          "Please paste your buddys peerId, or all of you come up with a new one!",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextField(
                                        controller: textFieldcontroller,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  style: const ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                      Color.fromARGB(
                                                          255, 37, 37, 37),
                                                    ),
                                                    foregroundColor:
                                                        MaterialStatePropertyAll(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    mixedController
                                                        .mqqtController
                                                        .connectToPeer(
                                                            textFieldcontroller
                                                                .text);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Confirm",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                const SizedBox(
                                                  width: 50,
                                                ),
                                                ElevatedButton(
                                                  style: const ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                      Color.fromARGB(
                                                          255, 37, 37, 37),
                                                    ),
                                                    foregroundColor:
                                                        MaterialStatePropertyAll(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Cancel",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    MouseRegion(
                      onEnter: (_) {
                        if (onEnterSound == null) return;
                        onEnterSound!();
                      },
                      onExit: (_) {
                        if (onExitSound == null) return;
                        onExitSound!();
                      },
                      child: IconButton(
                        icon: const Icon(Icons.volume_up_rounded,
                            color: Colors.white),
                        onPressed: () {
                          //TODO mute / unmute
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Tooltip(
                        message: !fullScreen
                            ? "Enter Fullscreen"
                            : "Exit Fullscreen",
                        child: IconButton(
                          onPressed: () {
                            fullScreen = !fullScreen;
                            if (fullScreen) {
                              Window.enterFullscreen();
                            } else {
                              Window.exitFullscreen();
                            }
                          },
                          icon: Icon(fullScreen
                              ? Icons.fullscreen
                              : Icons.fullscreen_exit),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
