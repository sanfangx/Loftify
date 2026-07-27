import 'package:flutter/material.dart';
import 'package:loftify/Models/grain_response.dart';
import 'package:loftify/Models/post_detail_response.dart';
import 'package:loftify/Models/recommend_response.dart';
import 'package:loftify/Models/search_response.dart';
import 'package:loftify/Widgets/PostItem/general_post_item_builder.dart';
class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({
    super.key,
    this.postItem,
    this.postDetailData,
    this.favoritePostDetailData,
    this.meta,
    this.searchPost,
    this.grainPostItem,
    this.generalPostItem,
  });
  final PostListItem? postItem;
  final PostDetailData? postDetailData;
  final FavoritePostDetailData? favoritePostDetailData;
  final Map<String, dynamic>? meta;
  final SearchPost? searchPost;
  final GrainPostItem? grainPostItem;
  final GeneralPostItem? generalPostItem;
  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}
class _VideoDetailScreenState extends State<VideoDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Video plugin stripped for testing")));
  }
}
