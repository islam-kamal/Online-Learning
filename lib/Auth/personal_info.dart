import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:video_chat/Model/user.dart';

import '../page_navigator.dart';


class Personal_Info extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Personal_Info_State();
  }

}

class _Personal_Info_State extends State<Personal_Info>{
  File sampleImage;
  String _username;
  String url;
  final formKey=new GlobalKey<FormState>();
  User user;

  //methods ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

  Future getImage()async{
    var tempImage= await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage=tempImage;
    });
  }

  bool validateAndSave(){
    final form=formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    else{
      return false;
    }
  }

  void uploadPersonalInfo()async
  {
    if(validateAndSave()){
      final StorageReference postImageRef=FirebaseStorage.instance.ref().child("Post Images");
      var timeKey = new DateTime.now();

      final StorageUploadTask uploadTask=postImageRef.child(timeKey.toString()+".jpg").putFile(sampleImage);
      var ImageUrl=await(await uploadTask.onComplete).ref.getDownloadURL();
      url=ImageUrl.toString();
      print("Image Url : "+url);
      saveToDatabase(url);
      goToHomePage(); // go to home page after save data
    }
  }

  void saveToDatabase(url){
    Firestore _firestore = Firestore.instance;
    _firestore.collection("Users").document(user.uid).setData({
      'username': _username,
      'picture': url,
    });
    user.userName = _username;
    user.picture = url;
    User u = Provider.of<User>(context);
    print('username: ' + u.userName);
    /*
    var dbTimeKey=new DateTime.now();
    var formateDate=new DateFormat('MMM d, yyyy');
    var formateTime=new DateFormat('EEEE, hh:mm aaa');
    String date=formateDate.format(dbTimeKey);
    String time=formateTime.format(dbTimeKey);
//we make random key to store image but we will use userid to store image to unique user
    DatabaseReference ref=FirebaseDatabase.instance.reference();

    var data = {
      "image" : url,
      "description" : _myValue ,
      "date" : date ,
      "time" :time ,
    };
    ref.child("Posts").push().set(data);

     */
  }

  void goToHomePage(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageNavigator(),
      ),
    );
  }





  // design ..........................................

  @override
  Widget build(BuildContext context) {
     user = Provider.of<User>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Upload Photo"),
        centerTitle: true,
      ),
      body: new Center(
        child: sampleImage==null?Text("select an image"):enableUpload(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: "Add Image",
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
  Widget enableUpload(){
    return Container(
      child: new Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            SizedBox(height: 30.0,),
            Image.file(sampleImage,height: 200.0 ,width: 900.0),
            SizedBox(height: 35.0,),
            TextFormField(
              decoration: new InputDecoration(labelText: "Username"),
              validator: (value){
                return value.isEmpty?"Username field is required":null;
              },
              onSaved: (value){
                return _username=value;
              },

            ),
            SizedBox(height: 55.0,),
            RaisedButton(
              elevation: 10.0,
              child: Text("Save Data"),
              color: Colors.pink,
              textColor: Colors.white,
              onPressed: uploadPersonalInfo,

            ),
          ],
        ),
      ),
    );
  }
}