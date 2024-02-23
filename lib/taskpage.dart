import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:taskly/models/task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  String? _newTaskContent;

  Box? _box;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        backgroundColor: Colors.red,
        title: const Text('Taskly!',
            style: TextStyle(fontSize: 25, color: Colors.white)),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (BuildContext _context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            _box = snapshot.data;
            return _tasksList(); // Add this line for the case when there is no error
          }
        } else {
          return Center(child: const CircularProgressIndicator());
        }
      },
    );
  }

  Widget _tasksList() {
    List tasks = _box!.values.toList();

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext _context, int _index) {
        var task = Task.fromMap(tasks[_index]);
        return ListTile(
          trailing:  Icon(task.done ? Icons.check_box_outlined : Icons.check_box_outline_blank, color: Colors.red),
          title:  Text(
            task.content,
            style:  TextStyle(decoration: task.done ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(task.timeStamp.toString()),
          onTap: () {
            task.done = !task.done;
              _box!.putAt(_index, task.toMap());
            setState(() {
              
            });
          },
          onLongPress: (){
            _box!.deleteAt(_index);
            setState(() {
              
            });
          
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopUp,
      child: const Icon(
        Icons.add,
      ),
    );
  }

  void _displayTaskPopUp() {
    showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: const Text("Add New Task"),
            content: TextField(
              onSubmitted: (_value) {
                if(_newTaskContent != null) {
                  var task = Task(content: _newTaskContent!, timeStamp: DateTime.now(), done: false);
                  _box!.add(task.toMap());
                  setState(() {
                    _newTaskContent = null;
                  Navigator.pop(_context);
                  });
                }
              },
              onChanged: (_value) {
                setState(() {
                  _newTaskContent = _value;
                });
              },
            ),
          );
        });
  }
}
