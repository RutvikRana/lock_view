import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lock_view/lock_view.dart';

void main() => runApp(MyApp());

// ------ Root Widget ---------
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MusicSlider Example",
      theme: ThemeData(
          primarySwatch: Colors.green,
          canvasColor: Colors.blue.shade100,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          platform: TargetPlatform.android),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool unlock = false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("MusicSlider Example"),),
      body: Center(
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Padding(padding: EdgeInsets.only(bottom: 30),child: SizedBox(height: 50,child: FittedBox(child: Text(unlock?"UnLocked":"Locked")))),
            LockView(height: 300,width: 300,password: [0,1,2,4,6,7,8],onEndPattern: (didUnlocked) {
              setState(() {
                //unlock = didUnlocked;
              });
              if(didUnlocked){
              Navigator.push(context, MaterialPageRoute(builder: (c)=>Scaffold(
                appBar: AppBar(title: Text("Unlocked Content"),),
                body: Center(child: Text("Unlocked",style: TextStyle(fontSize: 30),),),)));
              }
            },)],
          )
      )
    );
  }
}