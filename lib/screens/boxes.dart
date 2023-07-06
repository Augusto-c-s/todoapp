import 'package:hive/hive.dart';

import '../model/data/todo.dart';

class Boxes {
  static Box<ToDo> getTodoBox() =>
    Hive.box<ToDo>('todos'); 
}