import 'package:floor/floor.dart';
import 'todo_item.dart';

@dao
abstract class ToDoDao {
  @Query('SELECT * FROM ToDoItem')
  Future<List<ToDoItem>> findAllToDos();

  @insert
  Future<void> insertToDo(ToDoItem toDo);

  @delete
  Future<void> deleteToDo(ToDoItem toDo);
}