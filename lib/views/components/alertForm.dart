import 'package:flutter/material.dart';
import 'package:treat_yoself/controllers/controllers.dart';
import 'package:get/get.dart';
import 'package:treat_yoself/utils/database/db_utils.dart';

class AlertFormComment extends StatelessWidget {
  final _formKey;
  final fieldText = TextEditingController();
  final othertext = TextEditingController();
  var list = []; 
  //final int user;

 // MyCustomFormState(this.user);

  void clearText() {
    fieldText.clear();
    othertext.clear();
  }


  void insertComment() async {
    var database = DatabaseEngine();
    var now = DateTime.now();
    var date = DateTime(now.year,now.month,now.day).toString();
    var selectstoreid = "Select Stores.StoreID from Stores Where Stores.Name = ? and Stores.ZipCode = ?";
    var insertComment = "Insert into Comments (Description,DateAdded,StoreID,UserID) Values(?,?,?,?);";
    final AuthController controller = Get.find(); 
    var currentzip= controller.firestoreUser.value.zipcode; 
    final uid = controller.firestoreUser.value.uid; 
    var newuid = await database.manualQuery("Select UserID from Users Where fuid = ?",[uid]);
    var storeid= await database.manualQuery(selectstoreid,[list[0],currentzip]);
    await database.manualQuery(insertComment,[list[1],date,storeid[0].values[0],newuid[0].values[0]]); 

  }

  AlertFormComment(this._formKey);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Stack(overflow: Overflow.visible, children: <Widget>[
      Positioned(
        right: -40.0,
        top: -40.0,
        child: InkResponse(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: CircleAvatar(
            child: Icon(Icons.close),
            backgroundColor: Colors.red,
          ),
        ),
      ),
      Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Tell us about your Trip!"),
              TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    list.add(value);
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Enter Store Name',
                      labelStyle: TextStyle(color: Colors.green)),
                  controller: fieldText),
              TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    list.add(value);
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter your comment here',
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  controller: othertext),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  FloatingActionButton.extended(
                    label: Text('Submit'),
                    icon: Icon(Icons.add),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        
                            SnackBar(content: Text('Processing Data'));
                        insertComment(); 
                        clearText();
                        Navigator.pop(context);
                      }
                      else{list =[];}

                    },
                  )
                ],
              )
            ],
          ))
    ]));
  }
}

class AlertFormUpdate extends StatefulWidget {
  final _formKey;

  AlertFormUpdate(this._formKey);

  @override
  _AlertFormUpdateState createState() => _AlertFormUpdateState();
}

class _AlertFormUpdateState extends State<AlertFormUpdate> {
  var checkboxval = false; 

  final fieldText = TextEditingController();

  final othertext = TextEditingController();

  final brandtext = TextEditingController();

  final itemText = TextEditingController();

  final pricetext = TextEditingController();

  var list = []; 

 Future updatePrice() async {
  var database = DatabaseEngine();
  var now = DateTime.now();
  var date = DateTime(now.year,now.month,now.day).toString();
  final AuthController controller = Get.find(); 
  var currentzip= controller.firestoreUser.value.zipcode; 
  final uid = controller.firestoreUser.value.uid; 
  var newprice = double.parse(list[3]);
  var box; 
  if(list[3]== false){box = "0";} else{box = "1";}
  var selectbrandid = "Select BrandID from Brands Where Brands.Name = ?;";
  var selectitemID = "Select ItemID from Items Where Items.Name = ?;";
  var selectbrandsitems = "Select BrandItemID from BrandsItems Where BrandsItems.BrandID = ? and BrandsItems.ItemID = ?;";
  var selectstoreid = "Select Stores.StoreID from Stores Where Stores.Name = ? and Stores.ZipCode = ?";
  var selectstoreitemid = "Select StoreItemID from StoresItems Where StoresItems.BrandItemID = ? and StoresItems.StoreID = ?;";
  var updatePrice = "Update Prices Set Price = ?, DateAdded = ?, UserID = ?, OnSale = ? WHERE StoreItemID = ?";
  var newuid = await database.manualQuery("Select UserID from Users Where fuid = ?",[uid]);
  var brandID = await database.manualQuery(selectbrandid, [list[2]]);
  var itemID = await database.manualQuery(selectitemID, [list[0]]);
  if(brandID.length == 0 ||itemID.length == 0 || newuid.length == 0  ){
    return false;
  }
  var branditemid = await database.manualQuery(selectbrandsitems,[brandID[0].values[0],itemID[0].values[0]]);
    if(branditemid.length == 0){
    return false; 
  }
  var storeID= await database.manualQuery(selectstoreid,[list[1],currentzip]);
  if(storeID.length == 0){
    return false; 
  }
  var storeitemID = await database.manualQuery(selectstoreitemid,[branditemid[0].values[0],storeID[0].values[0]]);
  
  await database.manualQuery(updatePrice,[newprice,date,newuid[0].values[0],box,storeitemID[0].values[0]]); 

  if (storeitemID.length == 0) {
    return false;
  }


  else return true; 



 }

  void clearText() {
    fieldText.clear();
    othertext.clear();
    brandtext.clear(); 
    itemText.clear(); 
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Stack(overflow: Overflow.visible, children: <Widget>[
      Positioned(
        right: -40.0,
        top: -40.0,
        child: InkResponse(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: CircleAvatar(
            child: Icon(Icons.close),
            backgroundColor: Colors.red,
          ),
        ),
      ),
      Form(
          key: widget._formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text("Update Item Price!"),
               TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    list.add(value);
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter your Item here',
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  controller: othertext),
              TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    list.add(value);
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Enter Store Name',
                      labelStyle: TextStyle(color: Colors.green)),
                  controller: fieldText),
              TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    list.add(value);
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter your Brand here',
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  controller: brandtext),
              TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    list.add(value);
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter your Price here',
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  controller: pricetext),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:[
                    Text("Item On Sale?",style: TextStyle(color: Colors.green),),
                    Checkbox(
                        value: checkboxval,
                        onChanged: (value){
                          setState(() {
                            checkboxval = value;
                          });
                        },
                      ),
            ])),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  FloatingActionButton.extended(
                    label: Text('Submit'),
                    icon: Icon(Icons.add),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    onPressed: ()  async {
                      if (widget._formKey.currentState.validate()) {
                        list.add(checkboxval);
                        var done = await updatePrice(); 
                        
                        if (done == true) {
                          clearText();
                          Navigator.pop(context); 
                        }
                        else{
                          list = [];
                          return showDialog(context: context, builder:(BuildContext context ) { return AlertDialog(title:Text("Update Faild: Item may not exist"),actions:[
                            TextButton( child: Text("Ok"),onPressed: (){Navigator.of(context).pop();})
                          ]);});
                        }
                      }
                    },
                  )
                ],
              )
            ]))]));
  }
}