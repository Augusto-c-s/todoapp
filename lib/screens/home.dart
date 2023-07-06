import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todoapp/constants/colors.dart';
import 'package:todoapp/widgets/todo_item.dart';

import '../model/data/todo.dart';
import 'boxes.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final box = Boxes.getTodoBox();

  @override
  void initState() {
    _foundToDo = box.values.toList();

    _searchController.addListener(() {
      String searchTerm = _searchController.text;
      _runFilter(searchTerm);
    });

    _loadSavedItems();

    super.initState();
  }

  @override
  void dispose() {
    Hive.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: Column(
                children: [
                  searchBar(),
                  ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: Text(
                          'Todas as Tarefas',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo todos in _foundToDo.reversed)
                        ToDoItem(
                          todo: todos,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                          onEditItem: _editToDoItem,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: 20,
                        right: 20,
                        left: 20,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _todoController,
                        decoration: InputDecoration(
                          hintText: 'Adicione uma nova tarefa',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                    ),
                    child: ElevatedButton(
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),
                      onPressed: () {
                        _addToDoItem(_todoController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tdBlue,
                        minimumSize: Size(60, 60),
                        elevation: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
  setState(() {
      todo.isDone = !todo.isDone;
      box.put(todo.id, todo);
    });
  }

  void _deleteToDoItem(String id) {
  setState(() {
      box.delete(id);
      _foundToDo = box.values.toList();
    });
  }

  void _addToDoItem(String toDo) {
  if (toDo.isNotEmpty) {
    setState(() {
      final newToDo = ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: toDo,
      );
      box.put(newToDo.id, newToDo);
      _foundToDo = box.values.toList();
    });
    _todoController.clear();
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }
}

  void _editToDoItem(ToDo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Tarefa'),
          content: TextField(
            controller: TextEditingController(text: todo.todoText),
            onChanged: (value) {
              todo.todoText = value;
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _updateToDoItem(todo);
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _updateToDoItem(ToDo todo) {
    if (todo.todoText!.isNotEmpty) {
      setState(() {
        box.put(todo.id, todo);
        _foundToDo = box.values.toList();
      });
    }
  }

  void _runFilter(String enteredKeyword) {
  List<ToDo> results = [];
  if (enteredKeyword.isEmpty) {
    results = box.values.toList();
  } else {
    results = box.values
        .where((item) =>
            item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase()))
        .toList();
  }

  setState(() {
    _foundToDo = results;
  });
}

  Widget searchBar() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(
          Icons.search,
          color: Colors.grey,
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Procurar...',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.menu,
            color: tdBlack,
            size: 30,
          ),
          Container(
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/foto.png'),
            ),
          ),
        ],
      ),
    );
  }

  void _loadSavedItems() {
    List<ToDo> savedItems = box.values.toList(); // Recupera os valores do Hive

    setState(() {
      _foundToDo = savedItems;
    });
  }
}