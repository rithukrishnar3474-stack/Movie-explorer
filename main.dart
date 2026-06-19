import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MovieExplorerApp());
}

class MovieExplorerApp extends StatelessWidget {
  const MovieExplorerApp({super.key});

  @override
  Widget build(BuildContext WidgetContext) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Explorer',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141414),
        primaryColor: const Color(0xFFE50914),
      ),
      home: const MovieSearchScreen(),
    );
  }
}

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  // --- Put your OMDB API key here ---
  final String _apiKey = 'OMDb API key';

  final TextEditingController _controller = TextEditingController();

  // Variables to store movie data
  String _title = "";
  String _released = "";
  String _rating = "";
  String _plot = "";
  String _posterUrl = "";

  bool _isLoading = false;
  bool _hasData = false;
  bool _hasError = false;

  // Function to call the API
  Future<void> fetchMovie(String movieName) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final url = Uri.parse(
      'https://www.omdbapi.com/?t=$movieName&apikey=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Response'] == 'True') {
          setState(() {
            _title = data['Title'] ?? 'N/A';
            _released = data['Released'] ?? 'N/A';
            _rating = data['imdbRating'] ?? 'N/A';
            _plot = data['Plot'] ?? 'N/A';
            _posterUrl = data['Poster'] ?? '';
            _hasData = true;
          });
        } else {
          setState(() {
            _hasData = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      setState(() {
        _hasData = false;
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 Movie Explorer'),
        backgroundColor: const Color(0xFF1F1F1F),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search Input Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter movie name...',
                        filled: true,
                        fillColor: const Color(0xFF333333),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        fetchMovie(_controller.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Conditional UI Display
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE50914)),
                )
              else if (_hasError)
                const Text(
                  'Movie not found! Try another one.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                )
              else if (_hasData)
                // The Movie Display Card
                Card(
                  color: const Color(0xFF1F1F1F),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_posterUrl.isNotEmpty && _posterUrl != "N/A")
                        Image.network(
                          _posterUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          height: 300,
                          color: Colors.grey[800],
                          child: const Center(
                            child: Text('No Image Available'),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '📅 Released: $_released',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '⭐ Rating: $_rating',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              '📝 Plot:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _plot,
                              style: TextStyle(
                                color: Colors.grey[300],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
