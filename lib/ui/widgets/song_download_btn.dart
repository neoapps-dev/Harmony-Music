import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/downloader.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:hive/hive.dart';

import 'loader.dart';
import 'snackbar.dart';

class SongDownloadButton extends StatelessWidget {
  const SongDownloadButton({super.key});

  @override
  Widget build(BuildContext context) {
    final downloader = Get.find<Downloader>();
    final playerController = Get.find<PlayerController>();
    return Obx(() {
      final song = playerController.currentSong.value;
      if(song==null) return const SizedBox.shrink();
      return (downloader.songQueue.contains(song) &&
                  downloader.currentSong == song &&
                  downloader.songDownloadingProgress.value == 100) ||
              Hive.box("SongDownloads").containsKey(song.id)
          ? Icon(
              Icons.download_done,
              color: Theme.of(context).textTheme.titleMedium!.color,
            )
          : downloader.songQueue.contains(song) &&
                  downloader.isJobRunning.isTrue &&
                  downloader.currentSong == song
              ? Obx(() => Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "${downloader.songDownloadingProgress.value}%",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      LoadingIndicator(
                        dimension: 30,
                        strokeWidth: 4,
                        value: (downloader.songDownloadingProgress.value) / 100,
                      )
                    ],
                  ))
              : downloader.songQueue.contains(song)
                  ? const LoadingIndicator()
                  : IconButton(
                      icon: Icon(
                        Icons.download_rounded,
                        color: Theme.of(context).textTheme.titleMedium!.color,
                      ),
                      onPressed: () {
                        (Hive.openBox("SongsCache").then((box) {
                          if (box.containsKey(song.id)) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                context, "songAlreadyOfflineAlert".tr,
                                size: SanckBarSize.BIG));
                          } else {
                            downloader.download(song);
                          }
                        }));
                      },
                    );
    });
  }
}