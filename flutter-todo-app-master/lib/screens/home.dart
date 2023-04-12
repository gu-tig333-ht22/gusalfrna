import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';
import "./addscreen.dart";

class Task {
  final String id, title;
  final bool done;
  Task(this.id, this.title, this.done);
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _foundToDo = [];
  List<Task> mapedList = [];
  List<String> menuItems = ['All', 'Done', 'undone'];
  String? selectedItem = 'All';

  Future handleToken() async {
    print('in handle token');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs);
    final String? token = prefs.getString('token');
    print('token is $token');
    if (token != null) {
      print('already registered.');
    } else {
      print('new user');
      final url = "https://todoapp-api.apps.k8s.gu.se/register";
      final tokenUri = Uri.parse(url);
      final res = await http.get(tokenUri);
      final tokenString = res.body.toString();
      prefs.setString('token', tokenString);
    }
  }

  Future postTodo(todo) async {
    print('in post $todo');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final url = 'https://todoapp-api.apps.k8s.gu.se/todos?key=$token';
    final tokenUri = Uri.parse(url);
    final res = await http.post(tokenUri,
        body: jsonEncode(todo), headers: {'content-type': 'application/json'});
    print(res.statusCode);
    mapedList = [];
    var newData = jsonDecode(res.body);
    for (var i in newData) {
      // print(i);
      mapedList.add(Task(i['id'], i['title'], i['done']));
    }
    if (res.statusCode == 200) {
      print('res afetr post is ${res.body}');
      // fetchTodo();
      _foundToDo.clear();
      setState(() {
        _foundToDo = mapedList;
      });
    } else {
      print(res.body);
    }
  }

  Future fetchTodo() async {
    print('in fetch todo');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final url = 'https://todoapp-api.apps.k8s.gu.se/todos?key=$token';
    final tokenUri = Uri.parse(url);
    final res = await http.get(tokenUri);
    print(res.statusCode);
    if (res.statusCode == 200) {
      print(res.body);
      mapedList = [];
      var newData = jsonDecode(res.body);
      // print('length is $newData.length');
      for (var i in newData) {
        // print(i);
        mapedList.add(Task(i['id'], i['title'], i['done']));
      }
      setState(() {
        // _foundToDo = [];
        _foundToDo = mapedList;
        // print('after decode is $mapedList');
      });
    } else {
      print(res.body);
    }
  }

  void onChange(var text) {
    print(text);
    if (text == 'All') {
      fetchTodo();
    }
    if (text == 'Done') {
      setState(() {
        _foundToDo = mapedList;
        _foundToDo = _foundToDo.where((todo) => todo.done == true).toList();
      });
    }
    if (text == 'Pending') {
      setState(() {
        _foundToDo = mapedList;
        _foundToDo = _foundToDo.where((todo) => todo.done == false).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    handleToken().whenComplete(() => fetchTodo());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                Container(
                    height: 40,
                    padding: EdgeInsets.only(right: 10, left: 10),
                    // color: Colors.white,
                    decoration: BoxDecoration(
                        border: Border.all(color: tdGrey, width: 1),
                        borderRadius: BorderRadius.circular(15)),
                    child: DropdownButton(
                      hint: Text('Filter'),
                      icon: const Icon(Icons.arrow_downward),
                      isExpanded: true,
                      onChanged: onChange,
                      value: selectedItem,
                      underline: SizedBox(),
                      items: menuItems.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                    )),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: Text(
                          'TIG169',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (var todoo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todoo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                  left: 20,
                ),
                child: ElevatedButton(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  onPressed: () async {
                    var data = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddScreen()),
                    );
                    print('the data is $data');
                    if (data == null) {
                      print('empty data is ${data}');
                      fetchTodo();
                      return;
                    } else {
                      setState(() {
                        _foundToDo = [];
                      });
                      postTodo(data);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: tdBlue,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToDoChange(Task todo) async {
    print('in done ${todo.id}');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final url =
        'https://todoapp-api.apps.k8s.gu.se/todos/${todo.id}?key=${token}';
    final tokenUri = Uri.parse(url);
    final res = await http.put(tokenUri,
        body: jsonEncode({'title': todo.title, 'done': true}),
        headers: {'content-type': 'application/json'});
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('res afetr post is ${res.body}');
      fetchTodo();
    } else {
      print(res.body);
    }
  }

  Future<void> _deleteToDoItem(String id) async {
    print(id);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final url = 'https://todoapp-api.apps.k8s.gu.se/todos/$id?key=$token';
    final tokenUri = Uri.parse(url);
    print(tokenUri);
    var res = await http.delete(tokenUri);
    var decoded = jsonDecode(res.body);
    if (res.statusCode == 200) {
      print('deleted $decoded');
      fetchTodo();
    } else {
      print('Something is wrong');
    }
  }

  void _runFilter(String enteredKeyword) {
    // List<ToDo> results = [];
    // if (enteredKeyword.isEmpty) {
    //   // results = todosList;
    // } else {
    //   results = todosList
    //       .where((item) => item.title!
    //           .toLowerCase()
    //           .contains(enteredKeyword.toLowerCase()))
    //       .toList();
    // }

    // setState(() {
    //   _foundToDo = results;
    // });
  }

  // @override
  // Widget searchBox() {
  // return Container(
  //   padding: EdgeInsets.all(left:10,right:10),
  //   decoration: BoxDecoration(
  //     height:30,
  //     color: tdGrey
  //   ),
  // child: DropdownButtonFormField<String>(
  //   value: selectedItem,
  //   items: menuItems.
  //         map((i) => DropdownMenuItem<String>(
  //         value: i,
  //         child: Text(i,
  //               style: const TextStyle(
  //               fontSize: 14,
  //             ),),
  //       )).
  //   toList(),

  //   onChanged: (v)=> setState(() {
  //     selectedItem = v;
  //   }),
  //   icon: Icon(Icons.arrow_downward),
  //   iconSize: 24,
  //   elevation: 16,
  //   isExpanded: true,
  //   style: TextStyle(color: Colors.deepPurple, fontSize: 20.0),
  //   // underline: Container(
  //   //   height: 2,
  //   //     color: Colors.deepPurpleAccent,
  //   // )

  // ),

  // );
  // return Container(
  //   padding: EdgeInsets.symmetric(horizontal: 15),
  //   decoration: BoxDecoration(
  //     color: Colors.white,
  //     borderRadius: BorderRadius.circular(20),
  //   ),
  //   child: TextField(
  //     onChanged: (value) => _runFilter(value),
  //     decoration: InputDecoration(
  //       contentPadding: EdgeInsets.all(0),
  //       prefixIcon: Icon(
  //         Icons.search,
  //         color: tdBlack,
  //         size: 20,
  //       ),
  //       prefixIconConstraints: BoxConstraints(
  //         maxHeight: 20,
  //         minWidth: 25,
  //       ),
  //       border: InputBorder.none,
  //       hintText: 'Search',
  //       hintStyle: TextStyle(color: tdGrey),
  //     ),
  //   ),
  // );
  // }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
            child: Image.asset('assets/images/avatar.jpeg'),
          ),
        ),
      ]),
    );
  }
}
