import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  home: MemoryInspectorApp(),
  debugShowCheckedModeBanner: false,
));

class MemoryInspectorApp extends StatefulWidget {
  const MemoryInspectorApp({super.key});

  @override
  State<MemoryInspectorApp> createState() => _MemoryInspectorAppState();
}

class _MemoryInspectorAppState extends State<MemoryInspectorApp> {
  final TextEditingController _controller = TextEditingController(text: '42');
  String _selectedType = 'Int32';
  List<int> _bytes = [];
  int? _address;
  Pointer<Uint8>? _currentPtr;

  void _runInspection() {
    if (_currentPtr != null) {
      malloc.free(_currentPtr!);
    }

    final userInput = _controller.text;
    int size = (_selectedType == 'Double') ? 8 : 4;
    _currentPtr = malloc<Uint8>(size);

    if (_selectedType == 'Int32') {
      _currentPtr!.cast<Int32>().value = int.tryParse(userInput) ?? 0;
    } else {
      _currentPtr!.cast<Double>().value = double.tryParse(userInput) ?? 0.0;
    }

    final List<int> fetchedBytes = [];
    for (var i = 0; i < size; i++) {
      fetchedBytes.add(_currentPtr![i]);
    }

    setState(() {
      _address = _currentPtr!.address;
      _bytes = fetchedBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Native Memory Peek',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF161B22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildControlPanel(),
            const SizedBox(height: 30),
            if (_address != null) ...[
              AddressHeader(),
              const SizedBox(height: 20),
              MemoryGrid(),
              const SizedBox(height: 30),
              Explanation(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Inject Value',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent)),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                dropdownColor: const Color(0xFF161B22),
                value: _selectedType,
                style: const TextStyle(color: Colors.purpleAccent),
                items: ['Int32', 'Double'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              ElevatedButton(
                onPressed: _runInspection,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Peek mem', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget AddressHeader() {
    return Text(
      'ADDRESS: 0x${_address!.toRadixString(16).toUpperCase()}',
      style: const TextStyle(color: Colors.purpleAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold),
    );
  }

  Widget MemoryGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(_bytes.length, (index) {
        bool isActive = _bytes[index] != 0;
        return Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.deepPurple.withOpacity(0.3) : Colors.white.withOpacity(0.05),
            border: Border.all(color: isActive ? Colors.purpleAccent : Colors.white10, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _bytes[index].toRadixString(16).padLeft(2, '0').toUpperCase(),
            style: TextStyle(color: isActive ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  Widget Explanation() {
    return Text(
      'The value "${_controller.text}" is stored as a $_selectedType across ${_bytes.length} bytes.',
      style: const TextStyle(color: Colors.grey, fontSize: 13),
    );
  }
}