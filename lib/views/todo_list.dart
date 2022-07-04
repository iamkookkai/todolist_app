import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todolist_app/models/todo.dart';
import 'package:todolist_app/provider/db_provider.dart';


class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  var _refresh = GlobalKey<RefreshIndicatorState>();

  late DBProvider dbProvider;

  @override
  void initState() {
    dbProvider = DBProvider();
    super.initState();
  }

  @override
  void dispose() {
    dbProvider.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
  

   floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.70,
        decoration: BoxDecoration(
          borderRadius:  BorderRadius.circular(20.0),
        ),
        child: FloatingActionButton.extended(
         // backgroundColor: Color(0xFF2980b9),
          onPressed: (){
            createDialog();
          },
          elevation: 0,
          label: Row(
           // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.add),
              SizedBox(width: 10,),
              Text(
                "Add a New Task",
                style: TextStyle(
                  fontSize: 18.0
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    
   
   
    );
  }

  _buildAppBar() => AppBar(
        title: Text("Todo List"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _refresh.currentState!.show();
              dbProvider.deleteAll();
            },
          )
        ],
      );

  _buildContent() {
    return RefreshIndicator(
      key: _refresh,
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 2));
        setState(() {});
      },
      child: FutureBuilder(
        future: dbProvider.getTodolists(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Todo> todolist = snapshot.data as List<Todo>;
            if (todolist.length > 0) {
             
              return _buildListView(todolist.reversed.toList());
            }
            return Center(
              child: Text("NO DATA"),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  _buildListView(List<Todo> todolist) {
    return ListView.builder(
      itemCount: todolist.length,
      itemBuilder: (context, index) => Card(
        elevation: 6,
        //margin: EdgeInsets.all(2),
        child: ListTile(
          onTap: () {
             detailDialog(todolist[index]);
            
          },
          leading: CircleAvatar(
            child:
                Icon(Icons.list_alt_outlined), 
          ),
          title: Text(todolist[index].title.toString()),
          subtitle: Text(todolist[index].description.toString()),
          trailing: Wrap(
             spacing: 12,
           children: [
             IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      editDialog(todolist[index]);
                    },
                  ),
                 
             IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                       _refresh.currentState!.show();
                      dbProvider.deleteTodo(todolist[index].id!);
                      await Future.delayed(Duration(seconds: 2));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Todo deleted"),
                          action: SnackBarAction(
                            label: "UNDO",
                            onPressed: () {
                              _refresh.currentState!.show();
                              dbProvider.insertTodo(todolist[index]).then((value) {
                                print(todolist);
                              });
                            },
                          ),
                        ),
                      ); 
                    },
                  )
           ],
         ),
         ),
      ),
    );
  }

  _buildBody() => FutureBuilder(
        future: dbProvider.initDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildContent();
          }

          return Center(
            child: snapshot.hasError
                ? Text(snapshot.error.toString())
                : CircularProgressIndicator(),
          );
        },
      );

  createDialog() {
    var _formKey = GlobalKey<FormState>();
    Todo todo = Todo();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                   validator: (value) {
                        if (value!.isEmpty) {
                          return 'Title is Required';
                        }
                       
                        return null;
                      },

                  decoration: InputDecoration(hintText: "Title"),
                  onSaved: (value) {
                    todo.title = value;
                  },
                ),
                TextFormField(
                   keyboardType: TextInputType.multiline,
                              maxLines: null,
                  maxLength: 30,
                 
                   validator: (value) {
                        if (value!.isEmpty) {
                          return 'Description is Required';
                        }
                       
                      },
                  decoration: InputDecoration(hintText: "Description"),
                  onSaved: (value) {
                    todo.description = value;
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text("Submit"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _refresh.currentState!.show();
                        Navigator.pop(context);
                        dbProvider.insertTodo(todo).then((value) {
                          print(todo);
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  editDialog(Todo todo) {
    var _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: todo.title,
                  decoration: InputDecoration(hintText: "Title"),
                  onSaved: (value) {
                    todo.title = value;
                  },
                ),
                TextFormField(
                   keyboardType: TextInputType.multiline,
                              maxLines: null,
                 // maxLength: 30,
                  initialValue: todo.description.toString(),
                  decoration: InputDecoration(hintText: "Description"),
                  onSaved: (value) {
                    todo.description = value;
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text("Update"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _refresh.currentState!.show();
                        Navigator.pop(context);
                        dbProvider.updateTodo(todo).then((row) {
                          print(row.toString());
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

detailDialog(Todo todo) {
    var _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                 CircleAvatar(
            child:
                Icon(Icons.list_alt_outlined), 
          ),
          //SizedBox(height: 10,),
               
                TextFormField(
                  enabled: false,
                  initialValue: todo.title,
                  decoration: InputDecoration(hintText: "Tile"),
                  onSaved: (value) {
                    todo.title = value;
                  },
                ),
                TextFormField(
                  enabled: false,
                  initialValue: todo.description.toString(),
                  decoration: InputDecoration(hintText: "Description"),
                  onSaved: (value) {
                    todo.description = value;
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text("Close"),
                    onPressed: () {
                     

                        Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }


}
