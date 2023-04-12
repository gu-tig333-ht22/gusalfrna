import 'dart:convert';
import 'dart:html';
import 'package:flutter_todo_app/model/todo.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AddScreen extends StatefulWidget {
  
const AddScreen({Key? key}) : super(key: key);

@override
// ignore: library_private_types_in_public_api
_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<AddScreen> {
  TextEditingController taskController = TextEditingController();
@override
Widget build(BuildContext context) {
	return Scaffold(
    appBar: AppBar(
      title: Text("Add Task"),
      backgroundColor: tdBlue,
    ),
    body: (
      Align(alignment: Alignment.topRight,
      child: Row(children: [
        Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    top: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: tdBGColor,
                    boxShadow: const [
                      BoxShadow(
                        color:tdBlue,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  child: Text(
                    'Add +',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  onPressed: (){
                    final item = {
                      'title':taskController.text,
                      'done': false
                    };
                    
                    Navigator.pop(context,item);
                    
                  },
                  style: ElevatedButton.styleFrom(
                    // primary: tdBlue,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                    backgroundColor: tdBlue
                  ),
                ),
              ),
      ]),)
    ),
  );
}

}
