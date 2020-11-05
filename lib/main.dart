import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
//      home: MyHomePage(),
      home: FacePage(),
    );
  }
}

class FacePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _FacePageState();
}


class ImagesAndFaces extends StatelessWidget{
  ImagesAndFaces({this.imageFile, this.faces});
  final File imageFile;
  final List<Face> faces;

  @override
  Widget build(BuildContext context) {
    print('imageFile');
    print(imageFile);

    if (imageFile == null) return Container();

   return Column(children: <Widget>[
     Flexible(
         flex: 2,
         child: Container(
           constraints: BoxConstraints.expand(),
           child: Image.file(
             imageFile,
             fit:BoxFit.cover,
           ),
         ),),
     Flexible(
       flex: 1,
       child: ListView(
         children: faces.map<Widget>((f) => FaceCoordinates(f)).toList(),
       ),
     )

   ],);
  }

}

class FaceCoordinates extends StatelessWidget{
  FaceCoordinates(this.face);
  final Face face;

  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(
      title: Text('(${pos.top}, ${pos.left}),(${pos.bottom}, ${pos.right})'),
    );
  }
}

class FacePainter extends CustomPainter{
  FacePainter(this.image, this.faces);
  final ui.Image image;
  final List<Face> faces;
//  ui.Image img;

  @override
  void paint(Canvas canvas, Size size) {

//    r() async {
//    img = image.readAsBytes().then((value) => ui.instantiateImageCodec(value).then((codec) => codec.getNextFrame().then((fi) => fi.image.then((value)=>value))));
//      image.readAsBytes().then((value) => ui.instantiateImageCodec(value).then((coder) => coder.getNextFrame().then((nf) => img = nf.image)));

//    }
    print('img');
    print(image);
    if(image == null) return;

    canvas.drawImage(image, Offset.zero, Paint());
    for(var i=0; i< faces.length; i++){
      canvas.drawRect(faces[i].boundingBox, Paint());
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }

}

class _FacePageState extends State<FacePage> {
  File _imageFile;
  List<Face> _faces;
  final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(mode: FaceDetectorMode.accurate,
          enableLandmarks: true)
  );
  ui.Image _img;


  @override
  Widget build(BuildContext context) {
    var paintFace;


    if(_imageFile == null)
      paintFace =  Container();
    else
      paintFace =
          FittedBox(child: SizedBox(
            width: _img.width.toDouble(),
                  height: _img.height.toDouble(),
                  child: CustomPaint(
                    painter: FacePainter(_img, _faces),
                    child: Container()
//                    Image.file(
//                      _imageFile,
//                      fit:BoxFit.cover,
//                    )
                    ,
    )));


    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detector'),
      ),
      body:paintFace,
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: 'Pick an image',
        child: Icon(Icons.add_a_photo),
      ),
    );

  }

  void _getImageAndDetectFaces() async{
    var img;


    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery,
    );

    imageFile.readAsBytes().then((value) => ui.instantiateImageCodec(value).then((coder) => coder.getNextFrame().then((nf) => img = nf.image)));

    final image = FirebaseVisionImage.fromFile(imageFile);


    final faces = await faceDetector.processImage(image);
    setState(() {
      _imageFile = imageFile;
      _faces = faces;
      _img = img;
//      print('faces:');
//      print(faces);
    });

  }
}
//
//class MyHomePage extends StatefulWidget {
//  @override
//  _MyHomePageState createState() {
//    return _MyHomePageState();
//  }
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(title: Text('Baby Name Votes')),
//      body: _buildBody(context),
//    );
//  }
//
//  Widget _buildBody(BuildContext context) {
//    // TODO: get actual snapshot from Cloud Firestore
////    return _buildList(context, dummySnapshot);
//  return StreamBuilder<QuerySnapshot>(
//    stream: Firestore.instance.collection('baby').snapshots(),
//    builder: (context, snapshot){
//      if(!snapshot.hasData) return LinearProgressIndicator();
//
//      return _buildList(context, snapshot.data.documents);
//    },
//  );
//  }
//
//  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
//    return ListView(
//      padding: const EdgeInsets.only(top: 20.0),
//      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
//    );
//  }
//
//  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
//    final record = Record.fromSnapshot(data);
//
//    return Padding(
//      key: ValueKey(record.name),
//      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//      child: Container(
//        decoration: BoxDecoration(
//          border: Border.all(color: Colors.grey),
//          borderRadius: BorderRadius.circular(5.0),
//        ),
//        child: ListTile(
//          title: Text(record.name),
//          trailing: Text(record.votes.toString()),
//          onTap: () => Firestore.instance.runTransaction((transaction) async{
//            final freshSnapshot = await transaction.get(record.reference);
//            final fresh = Record.fromSnapshot(freshSnapshot);
//            await transaction.update(record.reference, {'votes': fresh.votes+1});
//          })
////              record.reference.updateData({'votes':FieldValue.increment(1)})
////            print(record), // TODO:change this step
//        ),
//      ),
//    );
//  }
//}
//
//class Record {
//  final String name;
//  final int votes;
//  final DocumentReference reference;
//
//  Record.fromMap(Map<String, dynamic> map, {this.reference})
//      : assert(map['name'] != null),
//        assert(map['votes'] != null),
//        name = map['name'],
//        votes = map['votes'];
//
//  Record.fromSnapshot(DocumentSnapshot snapshot)
//      : this.fromMap(snapshot.data, reference: snapshot.reference);
//
//  @override
//  String toString() => "Record<$name:$votes>";
//}