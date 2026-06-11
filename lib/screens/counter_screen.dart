import 'package:flutter/material.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contador'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 80,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Toca los botones',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Text(
                '$_counter',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: _decrementCounter,
                  heroTag: 'decrement',
                  backgroundColor: Colors.red.shade400,
                  icon: const Icon(Icons.remove),
                  label: const Text('Restar'),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  onPressed: _resetCounter,
                  heroTag: 'reset',
                  backgroundColor: Colors.grey.shade600,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  onPressed: _incrementCounter,
                  heroTag: 'increment',
                  backgroundColor: Colors.green.shade400,
                  icon: const Icon(Icons.add),
                  label: const Text('Sumar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
