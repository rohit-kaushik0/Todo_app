import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // for json encoding and decoding

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoList(title: 'HRK Todo Manager'),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key, required this.title});

  final String title;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Todo> _todos = <Todo>[];
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString('todos');
    if (todosString != null) {
      final List<dynamic> todosJson = jsonDecode(todosString);
      setState(() {
        _todos.addAll(todosJson.map((json) => Todo.fromJson(json)).toList());
      });
    }
  }

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosString =
        jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    prefs.setString('todos', todosString);
  }

  void _addTodoItem(String name) {
    setState(() {
      _todos.add(Todo(name: name, completed: false));
      _saveTodos();
    });
    _textFieldController.clear();
  }

  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.completed = !todo.completed;
      _saveTodos();
    });
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.removeWhere((element) => element.name == todo.name);
      _saveTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 247, 203, 7),
        title: Text(widget.title),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 239, 166),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _todos.map((Todo todo) {
          return TodoItem(
              todo: todo,
              onTodoChanged: _handleTodoChange,
              removeTodo: _deleteTodo);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 247, 203, 7),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        onPressed: () => _displayDialog(),
        tooltip: 'Add a Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 239, 166),
          title: const Text(
            'ADD UR TODO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type your todo'),
            autofocus: true,
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color.fromARGB(255, 247, 203, 7),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class Todo {
  Todo({required this.name, required this.completed});
  String name;
  bool completed;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      name: json['name'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'completed': completed,
    };
  }
}

class TodoItem extends StatelessWidget {
  TodoItem(
      {required this.todo,
      required this.onTodoChanged,
      required this.removeTodo})
      : super(key: ObjectKey(todo));

  final Todo todo;
  final void Function(Todo todo) onTodoChanged;
  final void Function(Todo todo) removeTodo;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 211, 15),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
            ),
          ],
        ),
        child: ListTile(
          onTap: () {
            onTodoChanged(todo);
          },
          leading: Checkbox(
            checkColor: Colors.greenAccent,
            activeColor: Colors.red,
            value: todo.completed,
            onChanged: (value) {
              onTodoChanged(todo);
            },
          ),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  todo.name,
                  style: _getTextStyle(todo.completed),
                ),
              ),
              IconButton(
                iconSize: 30,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                alignment: Alignment.centerRight,
                onPressed: () {
                  removeTodo(todo);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
