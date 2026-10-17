import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoPage(),
    );
  }
}

/// A colorful CRUD To-Do list page.
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  final List<TodoItem> _items = [];
  Priority _selectedPriority = Priority.medium;

  // ── CREATE ──
  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(TodoItem(title: text, priority: _selectedPriority));
      _controller.clear();
      _selectedPriority = Priority.medium;
    });
  }

  // ── UPDATE (toggle done) ──
  void _toggleDone(int index) {
    setState(() => _items[index].done = !_items[index].done);
  }

  // ── UPDATE (edit title via dialog) ──
  void _editTodo(int index) {
    final editController = TextEditingController(text: _items[index].title);
    Priority editPriority = _items[index].priority;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task title',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  const Text('Priority: '),
                  ...Priority.values.map((p) {
                    return FilterChip(
                      label: Text(p.label),
                      selected: editPriority == p,
                      onSelected: (_) =>
                          setDialogState(() => editPriority = p),
                    );
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = editController.text.trim();
                if (text.isEmpty) return;
                setState(() {
                  _items[index].title = text;
                  _items[index].priority = editPriority;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ── DELETE ──
  void _deleteTodo(int index) {
    final removed = _items[index];
    setState(() => _items.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${removed.title}"'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => setState(() => _items.insert(index, removed)),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _items.where((t) => !t.done).length;
    final done = _items.length - remaining;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigoAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Color(0xFFE8EAF6)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // ── Input card ──
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Add a new task...',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _addTodo(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: _addTodo,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Priority selector
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          const Text('Priority: '),
                          ...Priority.values.map((p) {
                            return FilterChip(
                              label: Text(p.label),
                              selected: _selectedPriority == p,
                              onSelected: (_) =>
                                  setState(() => _selectedPriority = p),
                              backgroundColor: p.color.withValues(alpha: 0.2),
                              selectedColor: p.color,
                              labelStyle: TextStyle(
                                color: _selectedPriority == p
                                    ? Colors.white
                                    : p.color,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Stats row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statChip('Total', _items.length, Colors.deepPurple),
                  _statChip('Active', remaining, Colors.orange),
                  _statChip('Done', done, Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── Task list ──
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.purpleAccent),
                          SizedBox(height: 12),
                          Text(
                            'No tasks yet. Add one above!',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _todoCard(index, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──
  Widget _statChip(String label, int count, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          count.toString(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  Widget _todoCard(int index, TodoItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.priority.color.withValues(alpha: item.done ? 0.2 : 0.5),
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Checkbox(
          value: item.done,
          onChanged: (_) => _toggleDone(index),
          activeColor: item.priority.color,
        ),
        title: GestureDetector(
          onTap: () => _editTodo(index),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.priority.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.priority.label,
                  style: TextStyle(
                    color: item.priority.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    decoration:
                        item.done ? TextDecoration.lineThrough : null,
                    color: item.done ? Colors.grey : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
              tooltip: 'Edit',
              onPressed: () => _editTodo(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete',
              onPressed: () => _deleteTodo(index),
            ),
          ],
        ),
      ),
    );
  }
}

/// Priority levels with colors.
enum Priority {
  low('Low', Colors.green),
  medium('Medium', Colors.orange),
  high('High', Colors.redAccent);

  const Priority(this.label, this.color);
  final String label;
  final Color color;
}

/// Simple data model for a to-do item.
class TodoItem {
  TodoItem({
    required this.title,
    this.done = false,
    this.priority = Priority.medium,
  });
  String title;
  bool done;
  Priority priority;
}
