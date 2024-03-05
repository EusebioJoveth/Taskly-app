import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double deviceHeight, deviceWidth;

  String? newTaskContent;

  Box? box;

  _HomePageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.height;
    //print("Imput Value: $newTaskContent");
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: deviceHeight * 0.15,
        title: const Text(
          'Tarefa!',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox('Tarefas'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          box = snapshot.data;
          return _tasksList();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _tasksList() {
    List tasks = box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
                decoration: task.done ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(
            task.timestamp.toString(),
          ),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
          onTap: () {
            task.done = !task.done;
            box!.putAt(
              index,
              task.toMap(),
            );
            setState(() {});
          },
          onLongPress: () {
            box!.deleteAt(index);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      backgroundColor: Colors.red, // Define a cor do botão como vermelho
      child: const Icon(Icons.add, color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      mini:
          true, // Define o botão como mini (pequeno) // Torna o botão circular
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nova Tarefa"),
          content: TextField(
            onSubmitted: (value) {
              if (newTaskContent != null) {
                var task = Task(
                    content: newTaskContent!,
                    timestamp: DateTime.now(),
                    done: false);
                box!.add(task.toMap());
                setState(() {
                  newTaskContent = null;
                  Navigator.pop(context);
                });
              }
            },
            onChanged: (novoValor) {
              setState(() {
                newTaskContent = novoValor;
              });
            },
          ),
        );
      },
    );
  }
}
