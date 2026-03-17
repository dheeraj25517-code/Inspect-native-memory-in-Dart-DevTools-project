Native Memory Inspector (Technical Prototype)
A "human-centric" memory exploration tool built for the Dart & Flutter GSoC 2026 project: Inspect Native Memory in Dart DevTools.

This prototype demonstrates how raw memory addresses can be visualized and interpreted dynamically, bridging the gap between low-level pointers and developer-friendly debugging.

Key Features
Dynamic Type Casting: Interpret raw bytes as Int32, Double, and more on the fly.
Memory Safety: Implements manual allocation and explicit freeing of native memory via dart:ffi.
Hex-Dump Visualization: A reactive, color-coded grid that highlights active data vs. null padding.
Endianness Awareness: Visually demonstrates how data is arranged in Little Endian format, which is crucial for systems debugging.

Technical Implementation: How it Works
This prototype simulates the lifecycle of a native pointer to help developers visualize memory layout:
Manual Allocation: Using package:ffi, the app calls malloc<Uint8>(size) to reserve a block of memory outside the Dart Garbage Collector's (GC) reach.
Pointer Manipulation: The tool stores a specific value (e.g., an integer) into that address.
Memory Peeking: The UI "peeks" into the memory by iterating through the byte offsets. It reads each byte individually to build the hex grid.
Cleaning Up: To prevent memory leaks—a common issue in FFI—the app explicitly calls malloc.free(_ptr) whenever the inspection is reset or the app is disposed.

Tech Stack
Flutter: For high-performance, reactive UI rendering.
Dart FFI (dart:ffi): Direct interaction with system-level memory.
package:ffi: For standard native memory management (malloc/free).

This prototype serves as the foundation for my proposal to integrate this view into the official Dart DevTools. Future milestones include:
VM Service Integration: Transitioning from local malloc to fetching memory regions from a remote running Dart process via JSON-RPC.
Safe Dereferencing: Implementing "Safe Peek" logic to verify address boundaries before reading, preventing Segmentation Faults.
Struct Layout Overlays: Automatically mapping complex C-style structs (with proper padding and alignment) onto the hex grid based on Dart FFI definitions.
Leak Detection: Correlating Dart Finalizable objects with native allocations to highlight potential memory leaks in real-time.

Getting Started:
Clone the repo: git clone https://github.com/dheeraj25517-code/Inspect-native-memory-in-Dart-DevTools-project.git
Install dependencies: flutter pub get
Run the app: flutter run

NOTE:
"Safe Dereferencing": Mentioning this shows you know that reading random memory can crash an app (Segmentation Fault). Mentors love safety-conscious students.
"Finalizable": Using this word shows you've researched how Dart handles native cleanup.
"JSON-RPC": This signals you understand how DevTools actually talks to your app.
