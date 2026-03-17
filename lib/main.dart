import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ffi/ffi.dart';

void main() {
  runApp(const MemoryInspectorApp());
}

class MemoryInspectorApp extends StatelessWidget {
  const MemoryInspectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF0D0221), // Deep space blue
      ),
      home: const NativeInspectorHome(),
    );
  }
}

class NativeInspectorHome extends StatefulWidget {
  const NativeInspectorHome({super.key});

  @override
  State<NativeInspectorHome> createState() => _NativeInspectorHomeState();
}

class _NativeInspectorHomeState extends State<NativeInspectorHome> {
  final TextEditingController _valController = TextEditingController(text: "123");
  final TextEditingController _sizeController = TextEditingController(text: "12"); // Default 12 bytes

  Pointer<Uint8>? _currentPtr;
  int _address = 0;
  List<int> _bytes = [];
  String _selectedType = 'Int32';

  @override
  void dispose() {
    if (_currentPtr != null) malloc.free(_currentPtr!);
    super.dispose();
  }

  void _runInspection() {
    // 1. Free previous memory to prevent leaks
    if (_currentPtr != null) {
      malloc.free(_currentPtr!);
    }

    // 2. Parse User Inputs
    final String valText = _valController.text;
    final int customSize = int.tryParse(_sizeController.text) ?? 4;

    // 3. Allocate the exact number of bytes requested (Simulating a Struct size)
    _currentPtr = malloc<Uint8>(customSize);

    // 4. "Inject" value based on type if space allows
    try {
      if (_selectedType == 'Int32' && customSize >= 4) {
        _currentPtr!.cast<Int32>().value = int.tryParse(valText) ?? 0;
      } else if (_selectedType == 'Double' && customSize >= 8) {
        _currentPtr!.cast<Double>().value = double.tryParse(valText) ?? 0.0;
      }
    } catch (e) {
      // Handle edge cases where pointer cast might fail
    }

    // 5. "Peek" at the raw memory bytes
    final List<int> fetchedBytes = [];
    for (int i = 0; i < customSize; i++) {
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
      appBar: AppBar(
        title: const Text("Native Memory Inspector"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildControlPanel(),
            const SizedBox(height: 20),
            _buildAddressDisplay(),
            const SizedBox(height: 20),
            Expanded(child: _buildMemoryGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Column(
            children: [
        Row(
        children: [
        Expanded(
        child: TextField(
            controller: _valController,
            decoration: const InputDecoration(labelText: "Value to Store"),
        ),
        ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _sizeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Struct Size (Bytes)"),
            ),
          ),
        ],
        ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _selectedType,
                    items: ['Int32', 'Double'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  ElevatedButton.icon(
                    onPressed: _runInspection,
                    icon: const Icon(Icons.search),
                    label: const Text("PEEK RAM"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  ),
                ],
              ),
            ],
        ),
    );
  }

  Widget _buildAddressDisplay() {
    return Column(
      children: [
        Text(
          "Base Address: 0x${_address.toRadixString(16).toUpperCase()}",
          style: const TextStyle(fontSize: 18, color: Colors.purpleAccent, fontWeight: FontWeight.bold),
        ),
        const Text("Status: Memory Allocated & Interpreted", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildMemoryGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _bytes.length,
      itemBuilder: (context, index) {
        final byte = _bytes[index];
        return Container(
          decoration: BoxDecoration(
            color: byte == 0 ? Colors.white.withOpacity(0.02) : Colors.purple.withOpacity(0.2),
            border: Border.all(color: byte == 0 ? Colors.grey.withOpacity(0.2) : Colors.purpleAccent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Byte $index", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(
                byte.toRadixString(16).padLeft(2, '0').toUpperCase(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text("$byte", style: const TextStyle(fontSize: 10, color: Colors.purpleAccent)),
            ],
          ),
        );
      },
    );
  }
}