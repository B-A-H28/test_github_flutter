import 'package:flutter/material.dart';
import 'database.dart';
import 'todo_dao.dart';
import 'todo_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 8 DB List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Shopping List DB'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _counter = 0.0;
  double myFontSize = 30.0;
  late TextStyle _myFontStyle = TextStyle(fontSize: myFontSize);

  AppDatabase? _database;
  ToDoDao? _toDoDao;
  List<ToDoItem> myList = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _toDoDao = _database!.toDoDao;
    _refreshList();
  }

  Future<void> _refreshList() async {
    if (_toDoDao != null) {
      final items = await _toDoDao!.findAllToDos();
      setState(() {
        myList = items;
      });
    }
  }

  void _addItem(String name) async {
    if (name.isEmpty || _toDoDao == null) return;
    final newItem = ToDoItem(DateTime.now().millisecondsSinceEpoch, name);
    await _toDoDao!.insertToDo(newItem);
    _textController.clear();
    _refreshList();
  }

  void _deleteItem(ToDoItem item) async {
    if (_toDoDao == null) return;
    await _toDoDao!.deleteToDo(item);
    _refreshList();
  }

  void _showDeleteDialog(ToDoItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item"),
        content: Text("Are you sure you want to remove '${item.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _deleteItem(item);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _setNewValue(double newValue) {
    setState(() {
      myFontSize = newValue;
      _myFontStyle = TextStyle(fontSize: myFontSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(hintText: "Enter shopping item"),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _addItem(_textController.text),
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
          Text('Counter: $_counter', style: _myFontStyle),
          Slider(
            min: 10.0,
            max: 100.0,
            value: myFontSize,
            onChanged: (value) => _setNewValue(value),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: myList.length,
              itemBuilder: (context, index) {
                final item = myList[index];
                return ListTile(
                  title: Text(item.name, style: _myFontStyle),
                  onLongPress: () => _showDeleteDialog(item),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}