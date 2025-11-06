import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/todo.dart';
import '../widgets/todo_item.dart';

enum TodoFilter { all, active, completed }

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final _todos = <Todo>[];
  final _uuid = const Uuid();
  TodoFilter _filter = TodoFilter.all;

  List<Todo> get _visibleTodos {
    switch (_filter) {
      case TodoFilter.active:
        return _todos.where((todo) => !todo.isCompleted).toList();
      case TodoFilter.completed:
        return _todos.where((todo) => todo.isCompleted).toList();
      case TodoFilter.all:
      default:
        return _todos;
    }
  }

  void _addTodo(String title, String? description) {
    setState(() {
      _todos.add(
        Todo(
          id: _uuid.v4(),
          title: title,
          description: description?.trim().isEmpty == true
              ? null
              : description?.trim(),
        ),
      );
    });
  }

  void _updateTodo(Todo todo, {String? title, String? description}) {
    final index = _todos.indexWhere((element) => element.id == todo.id);
    if (index == -1) return;

    setState(() {
      _todos[index] = _todos[index].copyWith(
        title: title,
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
      );
    });
  }

  void _toggleTodo(Todo todo, bool isCompleted) {
    final index = _todos.indexWhere((element) => element.id == todo.id);
    if (index == -1) return;

    setState(() {
      _todos[index] = _todos[index].copyWith(isCompleted: isCompleted);
    });
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.removeWhere((element) => element.id == todo.id);
    });
  }

  void _setFilter(TodoFilter filter) {
    setState(() {
      _filter = filter;
    });
  }

  void _showTodoForm({Todo? todo}) {
    final titleController = TextEditingController(text: todo?.title ?? '');
    final descriptionController =
        TextEditingController(text: todo?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    todo == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Titel',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte gib einen Titel ein';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Beschreibung (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        if (todo == null) {
                          _addTodo(titleController.text, descriptionController.text);
                        } else {
                          _updateTodo(
                            todo,
                            title: titleController.text,
                            description: descriptionController.text,
                          );
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(todo == null ? 'Speichern' : 'Aktualisieren'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      descriptionController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Aufgaben'),
        actions: [
          PopupMenuButton<TodoFilter>(
            initialValue: _filter,
            onSelected: _setFilter,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: TodoFilter.all,
                child: Text('Alle'),
              ),
              PopupMenuItem(
                value: TodoFilter.active,
                child: Text('Aktiv'),
              ),
              PopupMenuItem(
                value: TodoFilter.completed,
                child: Text('Erledigt'),
              ),
            ],
          ),
        ],
      ),
      body: _visibleTodos.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final todo = _visibleTodos[index];
                return TodoItem(
                  todo: todo,
                  onToggleCompleted: (value) =>
                      _toggleTodo(todo, value ?? !todo.isCompleted),
                  onEdit: () => _showTodoForm(todo: todo),
                  onDelete: () => _deleteTodo(todo),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: _visibleTodos.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTodoForm(),
        icon: const Icon(Icons.add_task),
        label: const Text('Aufgabe hinzufügen'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Lehn dich zurück!\nNoch keine Aufgaben.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Tippe auf „Aufgabe hinzufügen“, um loszulegen.'),
        ],
      ),
    );
  }
}
