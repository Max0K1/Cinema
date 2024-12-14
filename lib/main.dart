import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Кінотеатр',
      home: MovieSelection(),
    );
  }
}

class MovieSelection extends StatelessWidget {
  final List<Map<String, String>> movies = [
    {'title': 'Інтерстеллар', 'icon': 'https://upload.wikimedia.org/wikipedia/uk/2/29/Interstellar_film_poster2.jpg'},
    {'title': 'Тенет', 'icon': 'https://upload.wikimedia.org/wikipedia/en/1/14/Tenet_movie_poster.jpg'},
    {'title': 'Дюна', 'icon': 'https://upload.wikimedia.org/wikipedia/uk/7/71/%D0%94%D1%8E%D0%BD%D0%B0_%282021%29_%D0%BF%D0%BE%D1%81%D1%82%D0%B5%D1%80.jpg'},
     {'title': 'Дюна 2', 'icon': 'https://upload.wikimedia.org/wikipedia/uk/3/39/%D0%94%D1%8E%D0%BD%D0%B0_%D0%A7%D0%B0%D1%81%D1%82%D0%B8%D0%BD%D0%B0_%D0%B4%D1%80%D1%83%D0%B3%D0%B0.jpg'},
     {'title': 'Западня', 'icon': 'https://upload.wikimedia.org/wikipedia/uk/1/18/%D0%97%D0%B0%D0%BF%D0%B0%D0%B4%D0%BD%D1%8F_%D0%9F%D0%BE%D1%81%D1%82%D0%B5%D1%80.jpg'},
    {'title': 'Аватар 2', 'icon': 'https://upload.wikimedia.org/wikipedia/en/5/54/Avatar_The_Way_of_Water_poster.jpg'},
   ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вибір фільму')),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionSelection(movie: movies[index]['title']!),
                ),
              );
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(movies[index]['icon']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                padding: EdgeInsets.all(8.0),
                child: Text(
                  movies[index]['title']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SessionSelection extends StatelessWidget {
  final String movie;
  final List<String> sessions = [
    '10:00',
    '14:00',
    '18:00',
    '22:00',
  ];

  SessionSelection({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Сеанси: $movie')),
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Сеанс ${sessions[index]}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeatingChart(movie: movie, session: sessions[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SeatingChart extends StatefulWidget {
  final String movie;
  final String session;

  SeatingChart({required this.movie, required this.session});

  @override
  _SeatingChartState createState() => _SeatingChartState();
}

class _SeatingChartState extends State<SeatingChart> {
  final int rows = 8;
  final int seatsPerRow = 30;
  late List<List<bool>> _seats;
  late List<List<bool>> _occupiedSeats;

  @override
  void initState() {
    super.initState();
    _initializeSeats();
  }

  Future<void> _initializeSeats() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSeats = prefs.getStringList(_getSeatKey());
    if (savedSeats != null) {
      setState(() {
        _seats = savedSeats
            .map((row) => row.split(',').map((seat) => seat == '1').toList())
            .toList();
      });
    } else {
      _generateRandomSeats();
    }
    _generateRandomOccupiedSeats();
  }

  void _generateRandomSeats() {
    setState(() {
      _seats = List.generate(
        rows,
        (_) => List.generate(seatsPerRow, (_) => false),
      );
    });
  }

  void _generateRandomOccupiedSeats() {
    final random = Random();
    setState(() {
      _occupiedSeats = List.generate(
        rows,
        (row) => List.generate(
          seatsPerRow,
          (seat) => !_seats[row][seat] && random.nextDouble() < 0.2,
        ),
      );
    });
  }

  Future<void> _saveSeats() async {
    final prefs = await SharedPreferences.getInstance();
    final seatData = _seats
        .map((row) => row.map((seat) => seat ? '1' : '0').join(','))
        .toList();
    await prefs.setStringList(_getSeatKey(), seatData);
  }

  String _getSeatKey() => '${widget.movie}_${widget.session}_seats';

  void _toggleSeat(int row, int seat) {
    if (_occupiedSeats[row][seat]) return; // Заблоковане місце не можна обрати
    setState(() {
      _seats[row][seat] = !_seats[row][seat];
    });
    _saveSeats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Місця: ${widget.movie} (${widget.session})'),
      ),
      body: Column(
        children: [
          for (int row = 0; row < rows; row++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int seat = 0; seat < seatsPerRow; seat++)
                  GestureDetector(
                    onTap: () => _toggleSeat(row, seat),
                    child: Container(
                      margin: EdgeInsets.all(4.0),
                      width: 30,
                      height: 30,
                      color: _occupiedSeats[row][seat]
                          ? Colors.red
                          : (_seats[row][seat] ? Colors.green : Colors.grey),
                      child: Center(
                        child: Text(
                          '${row + 1}-${seat + 1}',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          final selectedSeats = _seats
              .asMap()
              .entries
              .expand((entry) => entry.value.asMap().entries.where((e) => e.value).map((e) => 'Ряд ${entry.key + 1}, Місце ${e.key + 1}'))
              .toList();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Обрані місця'),
              content: Text(selectedSeats.isNotEmpty
                  ? selectedSeats.join('\n')
                  : 'Ви не обрали жодного місця!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
