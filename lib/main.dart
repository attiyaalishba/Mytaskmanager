import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class Task {
  String title;
  String description;
  DateTime date;
  String priority;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    this.isCompleted = false,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Tasks',

      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TaskHomeScreen(),
    );
  }
}

class TaskHomeScreen extends StatefulWidget {
  @override
  _TaskHomeScreenState createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  List<Task> tasks = [];

  void _addOrUpdateTask(Task task, [int? index]) {
    setState(() {
      if (index == null) {
        tasks.add(task);
      } else {
        tasks[index] = task;
      }
    });
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Task"),
        content: Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() => tasks.removeAt(index));
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _toggleComplete(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  void _openTaskForm({Task? task, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          existingTask: task,
          onSave: (newTask) => _addOrUpdateTask(newTask, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Tasks')),
      body: tasks.isEmpty
          ? Center(child: Text('No tasks yet. Tap + to add.'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                  '${task.description}\nDue: ${task.date.toLocal().toString().split(' ')[0]} • Priority: ${task.priority}'),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: Icon(task.isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
                    onPressed: () => _toggleComplete(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _openTaskForm(task: task, index: index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;
  final Function(Task) onSave;

  TaskFormScreen({this.existingTask, required this.onSave});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _priority;
  DateTime _date = DateTime.now();

  final List<String> _priorities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _title = task?.title ?? '';
    _description = task?.description ?? '';
    _priority = task?.priority ?? 'Medium';
    _date = task?.date ?? DateTime.now();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSave(Task(
        title: _title,
        description: _description,
        date: _date,
        priority: _priority,
        isCompleted: widget.existingTask?.isCompleted ?? false,
      ));
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (val) => _title = val!,
                validator: (val) =>
                val == null || val.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (val) => _description = val ?? '',
              ),
              ListTile(
                title: Text("Date: ${_date.toLocal().toString().split(' ')[0]}"),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              DropdownButtonFormField(
                value: _priority,
                items: _priorities
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val.toString()),
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
