import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() => runApp(HotNewsApp());

class HotNewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HotNews',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red[800],
        scaffoldBackgroundColor: Color(0xFF232326),
        appBarTheme: AppBarTheme(
          color: Colors.red[900],
          foregroundColor: Colors.white,
        ),
      ),
      home: NewsHomePage(),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  List<dynamic> news = [];
  bool loading = true;
  String lang = 'en';

  final Map<String, String> languages = {
    'en': 'English',
    'th': 'ไทย',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'ru': 'Русский',
    'ar': 'العربية',
    'hi': 'हिन्दी',
    'id': 'Bahasa',
    'vi': 'Tiếng Việt',
    'pt': 'Português',
    // เพิ่มภาษาได้ตามต้องการ
  };

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() => loading = true);
    final url = Uri.parse(
        'https://newsdata.io/api/1/news?apikey=demo&language=$lang&category=top');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        news = data['results'] ?? [];
        loading = false;
      });
    } else {
      setState(() {
        news = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HotNews'),
        actions: [
          DropdownButton<String>(
            value: lang,
            dropdownColor: Colors.grey[900],
            items: languages.keys
                .map((code) => DropdownMenuItem(
                      child: Text(languages[code]!),
                      value: code,
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                lang = val!;
                fetchNews();
              });
            },
            underline: SizedBox(),
            iconEnabledColor: Colors.white,
          )
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : news.isEmpty
              ? Center(child: Text('No news found.'))
              : ListView.builder(
                  itemCount: news.length,
                  itemBuilder: (c, i) => Card(
                    color: Colors.grey[850],
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: ListTile(
                      title: Text(
                        news[i]['title'] ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        news[i]['description'] ?? '',
                        style: TextStyle(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.launch, color: Colors.red[300]),
                      onTap: () async {
                        final url = news[i]['link'];
                        if (url != null) await launchUrl(Uri.parse(url));
                      },
                    ),
                  ),
                ),
    );
  }
}
