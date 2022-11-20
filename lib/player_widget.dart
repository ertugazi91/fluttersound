// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatefulWidget {
  final String url;
  const PlayerWidget({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> with TickerProviderStateMixin {
  late AudioPlayer player;
  late bool initialized;
  late AnimationController _animationController;
  Duration? duration;
  Duration position = Duration.zero;
  @override
  void initState() {
    super.initState();
    initialized = false;
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    init();
  }

  Future setDuration() async {
    duration = await player.getDuration();
  }

  Future<void> init() async {
    player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    await player.setSourceDeviceFile(widget.url);
    await setDuration();
    player.onPositionChanged.listen((event) {
      position = event;
      print(position);
      setState(() {});
    });
    Future.microtask(() {
      initialized = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? Row(
            children: [
              IconButton(
                  onPressed: () {
                    setState(() async {
                      if (player.state == PlayerState.playing) {
                        await player.pause();
                        _animationController.reverse();
                      } else if (player.state == PlayerState.completed || player.state == PlayerState.stopped) {
                        await player.play(DeviceFileSource(widget.url));
                        // await player.play(BytesSource(File(widget.url).readAsBytesSync()));
                        // await player.seek(Duration(seconds: 1));
                        _animationController.forward();
                      } else {
                        await player.resume();
                        _animationController.forward();
                      }
                    });
                  },
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: _animationController,
                  )),
              if (duration != null)
                Expanded(
                  child: Slider(
                    value: position.inSeconds / duration!.inSeconds,
                    onChanged: (value) {
                      player.seek(Duration(seconds: value.toInt()));
                    },
                    max: duration!.inSeconds.toDouble(),
                    min: 0,
                  ),
                ),
            ],
          )
        : Container();
  }
}
