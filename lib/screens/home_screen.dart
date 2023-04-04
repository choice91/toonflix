import 'package:flutter/material.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/widgets/webtoon_widget.dart';

import '../models/webtoon_model.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final Future<List<WebtoonModel>> webtoons = ApiService.getTodaysToons();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        title: Text(
          '오늘의 웹툰',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 1, // 명암
      ),
      body: FutureBuilder(
        future: webtoons,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    // ListView.builder가 아이템을 build 할 때 호출하는 함수
                    itemBuilder: (context, index) {
                      var webtoon = snapshot.data![index];
                      return Webtoon(
                        title: webtoon.title,
                        thumb: webtoon.thumb,
                        id: webtoon.id,
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 40),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
