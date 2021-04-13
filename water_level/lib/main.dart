import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


//last thing added was firebase on void main


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Level App',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double initial = 50.0;
  double percentage = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent[700],
        elevation: 0.0,
        centerTitle: true,
        title: Text('Water Level App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Select Water Level',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold
              ),
            ),
            GestureDetector(
              onPanStart: (DragStartDetails details) {
                initial = details.globalPosition.dx;
              },
              onPanUpdate: (DragUpdateDetails details) {
                double distance = details.globalPosition.dx - initial;
                double percentageAddition = distance / 350;

               // print('distance ' + distance.toString());
                setState(() {
          // print('percentage ' +(percentage + percentageAddition).clamp(0.0, 100.0).toString());
                  percentage = (percentage + percentageAddition).clamp(0.0, 100.0);
                });
              },
              onPanEnd: (DragEndDetails details) {
                initial = 0.0;
              },
              child: PercentSlider(
                percentage: this.percentage,
              ),
            ),

            new Text(
              percentage.round().toString() + ' %',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold
              ),
            ),


            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent[700])),
              child: Text("Next Page"),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WaterCup(
                    percentage: percentage,
                    // percentage: FirebaseFirestore.instance.collection('data').
                    // doc('waterlevel').set({'percentage': percentage.round()});
                    )
                  )
                );//onPressed
              },
            ),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent[700])),
              child: Text("PUSH TO FIRESTORE"),
              onPressed: () {
                FirebaseFirestore.instance.collection('data').doc('waterlevel').set({'percentage': percentage.round()});
              })
          ],

        ),
      ),
    );
  }
}

class PercentSlider extends StatelessWidget {
  double totalWidth = 350.0;
  double percentage;

  PercentSlider({
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    // print((percentage / 100) * totalWidth);
    // print((1 - percentage / 100) * totalWidth);
    return Stack(

      children: <Widget>[

//outer container
        Container(
          height: 50,
        ),

//the actual slider
        Positioned(
          left: 20,
          top: 10,
          child: Container(
            width: totalWidth + 10,
            height: 30.0,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  color: Colors.indigoAccent[100],
                  width: (percentage / 100) * totalWidth,
                ),
              ],
            ),
          ),
        ),

        //Bar slider
        Positioned(
          top: 2.5,
          left: (percentage / 100) * totalWidth + 20,
          child:  Container(
            width: 7,
            height: 50,
            decoration: BoxDecoration(color: Colors.deepPurple),
          ),
        ),

      ],
    );
  }
}


//Next Page
class WaterCup extends StatelessWidget {
  final percentage;
  WaterCup({
    this.percentage,
  });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent[700],
        title: Text("Water Level App"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
     body: StreamBuilder (
     stream: FirebaseFirestore.instance.collection('data').doc('waterlevel').snapshots(),
     builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
          child: CircularProgressIndicator(),
          );
        }

          return Center(
            child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Stack(
                    children: <Widget>[
                    Container(
                      height: 200,
                      width:200,
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent[100],
                      ),
                    ),

                    Container(
                      height: 200 - (snapshot.data['percentage']*2).toDouble(),
                      width:200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                    ),

                    CustomPaint(
                      size: Size(200, 200),
                      painter: DrawGlass(painter: Paint()
                        ..color = Colors.black
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3),
                    ),

                      CustomPaint(
                        size: Size(200, 200),
                        painter: LeftGlass(painter: Paint()
                          ..color = Colors.white
                          ..style = PaintingStyle.fill
                          ..strokeWidth = 3),
                      ),

                      CustomPaint(
                        size: Size(200, 200),
                        painter: RightGlass(painter: Paint()
                          ..color = Colors.white
                          ..style = PaintingStyle.fill
                          ..strokeWidth = 3),
                      ),

                    ],

                  ),
                  new Text(
                    snapshot.data['percentage'].toString() + ' %',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  ElevatedButton(
                    child: Text("Prev Page"),
                    onPressed: (){
                      Navigator.pop(context);
                    },//onPressed
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent[700])),
                  ),

                ]
              ),

          );
      },
     )
    );
  }
}

class DrawGlass extends CustomPainter{
  Paint painter;

  DrawGlass({
    this.painter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    var path = Path();

    path.moveTo(2, 0);
    path.lineTo(size.width-2, 0);
    path.lineTo(size.width*.75-2, size.height);
    path.lineTo(size.height*.25, size.height);
    path.close();

    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class LeftGlass extends CustomPainter {
  Paint painter;

  LeftGlass({
    this.painter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.height * .25 -2, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
    return false;
  }

}


class RightGlass extends CustomPainter {
  Paint painter;

  RightGlass({
    this.painter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.height * .75, size.height);
    path.close();

    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}




