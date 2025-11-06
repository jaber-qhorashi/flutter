import 'package:flutter/foundation.dart';

/// Simple data model representing a todo item.
@immutable
class Todo {
  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Unique identifier for the todo item.
  final String id;

  /// Short title describing what should be done.
  final String title;

  /// Additional optional details about the task.
  final String? description;

  /// Whether the todo item has been completed.
  final bool isCompleted;

  /// Timestamp indicating when the todo item was created.
  final DateTime createdAt;

  /// Returns a new todo instance with modified properties.
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
