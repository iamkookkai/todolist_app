const String TABLE_TODO = 'todo';
const String COLUMN_ID = 'id';
const String COLUMN_TITLE = 'title';
const String COLUMN_DESCRIPTION = 'description';



class Todo {
  int? id;
  String? title;
 
  String? description;
  


 Todo({
  this.id,
  this.title,
  this.description,
 
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_TITLE: title,
      COLUMN_DESCRIPTION: description,
      
    };

    if (id != null) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  Todo.fromMap(Map<String, dynamic> map) {
    id = map[COLUMN_ID];
    title = map[COLUMN_TITLE];
    description = map[COLUMN_DESCRIPTION];
   
  }

  @override
  String toString() => "$id, $title, $description";
}
