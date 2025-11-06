import 'package:flutter/material.dart';

import '../models/todo.dart';

/// A list tile representation of a [Todo] item.
class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  final Todo todo;
  final ValueChanged<bool?> onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onEdit,
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: onToggleCompleted,
        ),
        title: Text(
          todo.title,
          style: todo.isCompleted
              ? theme.textTheme.titleMedium
                  ?.copyWith(decoration: TextDecoration.lineThrough)
              : theme.textTheme.titleMedium,
        ),
        subtitle: todo.description?.isNotEmpty == true
            ? Text(
                todo.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
