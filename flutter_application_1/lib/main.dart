import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor de Hidratação',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      home: const HydrationTracker(),
      routes: {
        '/history': (context) => const HydrationHistory(),
      },
    );
  }
}

class HydrationTracker extends StatefulWidget {
  const HydrationTracker({super.key});

  @override
  _HydrationTrackerState createState() => _HydrationTrackerState();
}

class _HydrationTrackerState extends State<HydrationTracker> {
  int _currentWaterIntake = 0;
  final int _dailyGoal = 2000; // Meta diária em mL
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
    _loadHistory();
  }

  // Carregar dados de consumo
  Future<void> _loadWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentWaterIntake = prefs.getInt('waterIntake') ?? 0;
    });
  }

  // Carregar histórico de consumo
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('waterHistory') ?? [];
    });
  }

  // Salvar dados de consumo e histórico
  Future<void> _saveWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterIntake', _currentWaterIntake);

    // Adiciona o consumo ao histórico
    _history.insert(0, '$_currentWaterIntake mL');
    await prefs.setStringList('waterHistory', _history);
  }

  // Adicionar água consumida
  void _addWater(int amount) {
    setState(() {
      _currentWaterIntake += amount;
    });
    _saveWaterIntake();
  }

  // Navegar para a tela de histórico
  void _goToHistory() {
    Navigator.pushNamed(context, '/history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Hidratação'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _goToHistory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Meta diária
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Meta diária: $_dailyGoal mL',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            // Consumo atual
            Text(
              'Consumido: $_currentWaterIntake mL',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _currentWaterIntake >= _dailyGoal
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            // Botões para adicionar água
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWaterButton(200, '+200 mL'),
                _buildWaterButton(500, '+500 mL'),
                _buildWaterButton(1000, '+1000 mL'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Botão de água
  ElevatedButton _buildWaterButton(int amount, String label) {
    return ElevatedButton(
      onPressed: () => _addWater(amount),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), backgroundColor: const Color.fromARGB(255, 24, 214, 65),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(label),
    );
  }
}

class HydrationHistory extends StatelessWidget {
  const HydrationHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Hidratação'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<String>>(
        future: _loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum registro encontrado.',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    'Consumo no dia ${index + 1}: ${history[index]} ',
                    style: const TextStyle(fontSize: 16),
                  ),
                  leading: Icon(Icons.local_drink, color: Colors.blueAccent),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Carregar histórico de consumo
  Future<List<String>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('waterHistory') ?? [];
  }
}
