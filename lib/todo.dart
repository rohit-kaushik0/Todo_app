import 'package:flutter/material.dart';

class Todo {
  Todo({required this.name, required this.completed});
  String name;
  bool completed;
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
