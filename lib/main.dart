import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox("lessons");

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_){
    runApp(MyApp());
    }
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        backgroundColor: Colors.grey[200],
      ),
      home: MyHomePage(title: 'Noten'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Box lessons;
  bool _add = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      lessons = Hive.box('lessons');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          addlesson(context),
          ListView.builder(
              itemBuilder: (BuildContext context, index) {
                return Card(
                  child: Row(
                    children: [
                      Text('${lessons.keys.toList()[index]}'),
                      getmean(lessons.getAt(index)),
                    ],
                  ),
                );
              },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _add = true;
          });
        },
        tooltip: 'Fach hinzufügen',
        child: Icon(Icons.add),
      ),
    );
  }
  addlesson(context) {
    final _formKey = GlobalKey<FormState>();
    return _add == true ? showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Fach hinzufügen'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              keyboardType: TextInputType.text,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Fach',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if(value!.isEmpty) {
                  return 'Gib bitte das Fach an';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  _formKey.currentState!.reset();
                  Navigator.of(context).pop();
                },
                child: Text('Abbrechen')
            ),
            TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    lessons.put('${_formKey.currentState.toString()}', {});
                  } else {
                    _formKey.currentState!.validate();
                  }
                }, 
                child: Text('OK'),
            )
          ],
        );
      },
    ) : null;
  }
  Text getmean(Map lesson) {
    if(lesson.isEmpty) {
      return Text('');
    } else {
      return Text('1');
    }
  }
}
