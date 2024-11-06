import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// A [StatelessWidget] that builds the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock<IconData>(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A dock widget for reorderable items.
class Dock<T extends IconData> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// List of items to display in the dock.
  final List<T> items;

  /// Function to build the provided item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State class for [Dock] to manage item states.
class _DockState<T extends IconData> extends State<Dock<T>> {
  late List<T> _items; // List of items in the dock
  late List<GlobalKey> _keys; // Track keys for each item to get their positions
  T? _currentDraggedItem; // Track the currently dragged item
  int? _currentDraggedItemIndex; // Track the index of the dragged item
  double _draggedItemOffsetX = 0; // Track the X offset of the dragged item
  double _draggedItemOffsetY = 0; // Track the Y offset of the dragged item
  bool _isDragging = false; // Track if dragging is occurring

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items); // Initialize the items list
    _keys = List.generate(widget.items.length, (index) => GlobalKey()); // Initialize keys
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      height: 70, // Fixed height for the dock
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          int index = entry.key;
          T item = entry.value;

          return DragTarget<T>(
            onAccept: (data) {
              setState(() {
                // Move the dragged item to its new position
                if (_currentDraggedItemIndex != null && _currentDraggedItemIndex != index) {
                  _items.remove(data);
                  _items.insert(index, data);
                }
                _currentDraggedItem = null; // Reset dragged item
                _currentDraggedItemIndex = null; // Reset dragged index
                _isDragging = false; // Reset dragging state
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<T>(
                data: item,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 48),
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child: Center(child: Icon(item, color: Colors.white)),
                  ),
                ),
                childWhenDragging: Container(), // Hide the item while dragging
                onDragStarted: () {
                  setState(() {
                    _currentDraggedItem = item; // Set the item being dragged
                    _currentDraggedItemIndex = index; // Store the dragged item's index
                    _draggedItemOffsetX = 0; // Initialize dragged item offset
                    _draggedItemOffsetY = 0;
                    _isDragging = true; // Start dragging
                  });
                },
                onDraggableCanceled: (_, __) {
                  setState(() {
                    _draggedItemOffsetX = 0; // Reset offset on cancel
                    _draggedItemOffsetY = 0;
                    _isDragging = false; // End dragging
                  });
                },
                child: AnimatedPositioned(
                  key: _keys[index],
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isDragging && _currentDraggedItemIndex == index
                      ? _draggedItemOffsetX // Apply the dragged offset for smooth return
                      : 0.0,
                  top: _isDragging && _currentDraggedItemIndex == index
                      ? -10 // Slightly offset the dragged item while moving
                      : 0.0,
                  child: AnimatedScale(
                    scale: _isDragging && _currentDraggedItemIndex == index ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      height: 48,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: (_currentDraggedItem == item)
                            ? Colors.blue[100]
                            : Colors.primaries[item.hashCode % Colors.primaries.length],
                      ),
                      child: Center(
                        child: Icon(item, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
