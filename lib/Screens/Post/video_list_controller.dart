import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loftify/Models/recommend_response.dart';
class CustomVideoController {
  final PostListItem? videoInfo;
  CustomVideoController({this.videoInfo, required builder, afterInit});
  bool get prepared => false;
  Future<void> dispose() async {}
  Future<void> init({afterInit}) async {}
  Future<void> pause({bool showPauseIcon = false}) async {}
  Future<void> play() async {}
  ValueNotifier<bool> get showPauseIcon => ValueNotifier<bool>(false);
}
typedef LoadMoreVideo = Future<List<CustomVideoController>> Function(int index, List<CustomVideoController> list);
class VideoListController extends ChangeNotifier {
  VideoListController({this.loadMoreCount = 1, this.preloadCount = 2, this.disposeCount = 0});
  final int loadMoreCount;
  final int preloadCount;
  final int disposeCount;
  ValueNotifier<int> index = ValueNotifier<int>(0);
  List<CustomVideoController> playerList = [];
  CustomVideoController get currentPlayer => playerList.isNotEmpty ? playerList[index.value] : CustomVideoController(builder:(){});
  init({required BuildContext context, required PageController pageController, required List<CustomVideoController> initialList, required LoadMoreVideo videoProvider, bool loop = false}) async {}
  CustomVideoController? playerOfIndex(int index) => null;
}
