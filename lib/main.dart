import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  File _image;
  bool _loading = false;
  List _output;

  void _takeAPicture() async {
    var image = await picker.getImage(source: ImageSource.camera);

    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
  }

  void _pickImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      // _loading = false;
      _output = output;
    });

    print('output: ${_output.toString()}');
  }

  @override
  void initState() {
    super.initState();
    // _loading = true;
    loadModel().then((value) {
      // setState(() {});
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: () {
                    _takeAPicture();
                  },
                  child: Text('Take a picture'),
                ),
                SizedBox(
                  width: 16,
                ),
                RaisedButton(
                  onPressed: () {
                    _pickImage();
                  },
                  child: Text('Pick from gallery'),
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            _image != null ? Image.file(_image) : Container(),
            SizedBox(
              height: 16,
            ),
            _image != null
                ? RaisedButton(
                    onPressed: () {
                      classifyImage(_image);
                    },
                    child: Text('Classify'),
                  )
                : Container(),
            SizedBox(
              height: 16,
            ),
            _output != null
                ? Text(
                    'It\'s a ${_output[0]['label']}!\nConfidence: ${_output[0]['confidence']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  )
                : Container()
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _takeAPicture,
      //   tooltip: 'Pick Image',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
