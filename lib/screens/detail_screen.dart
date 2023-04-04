import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/services/api_service.dart';

import '../models/webtoon_detail_model.dart';
import '../models/webtoon_episode_model.dart';
import '../widgets/episode_widget.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen({
    Key? key,
    required this.title,
    required this.thumb,
    required this.id,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences prefs;
  bool isLiked = false;

  Future initPref() async {
    prefs = await SharedPreferences.getInstance();
    final likeToons = prefs.getStringList('likedToons');

    if (likeToons != null) {
      if (likeToons.contains(widget.id) == true) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      await prefs.setStringList('likedToons', []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodes(widget.id);
    initPref();
  }

  void onHeartTap() async {
    final likedToons = prefs.getStringList('likedToons');

    if (likedToons != null) {
      if (isLiked) {
        likedToons.remove(widget.id);
      } else {
        likedToons.add(widget.id);
      }

      await prefs.setStringList('likedToons', likedToons);

      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: onHeartTap,
            icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_outline_outlined),
          ),
        ],
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 1, // 명암
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: widget.id,
                    child: Container(
                      width: 250,
                      clipBehavior: Clip.hardEdge, // 자식이 부모 영역 침범을 제어하는 방법
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 15, // 그림자가 얼마나 멀리까지 드리울지를 정함
                            offset: Offset(10, 10), // 그림자의 위치를 정함
                            color: Colors.black.withOpacity(0.5), // 색상
                          ),
                        ],
                      ),
                      child: Image.network(
                        widget.thumb,
                        headers: const {
                          "User-Agent":
                              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              FutureBuilder(
                future: webtoon,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.about,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '${snapshot.data!.genre} / ${snapshot.data!.age}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: const [
                      SizedBox(height: 15),
                      Text('...'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 50),
              FutureBuilder(
                future: episodes,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        for (var episode in snapshot.data!)
                          Episode(episode: episode, webtoonId: widget.id),
                      ],
                    );
                  }

                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
