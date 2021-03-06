import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treat_yoself/constants/app_routes.dart';
import 'package:treat_yoself/controllers/rewards_controller.dart';
import 'package:treat_yoself/localizations/localizations.dart';
import 'package:treat_yoself/controllers/controllers.dart';
import 'views.dart';
import 'package:get/get.dart';
import 'package:treat_yoself/utils/database/db_utils.dart';
import 'auth/auth.dart';
import 'package:date_format/date_format.dart';


class HomeUI extends StatefulWidget {
  var commentBox = true;
  @override
  _HomeUIState createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  var commentBox = true;
  List<dynamic> results;
  List<dynamic> priceResults;
  final dbConn = DatabaseEngine();
  final RewardsController rewardsController = Get.find();
  final ThemeController theme = Get.find();
  final commentQueryString =
      "SELECT c.*,  s.Name as store, u.fuid as uid FROM Comments c left join Stores s on s.StoreID = c.StoreID left join Users u on u.UserID = c.UserID ORDER BY DateAdded LIMIT ?";
  var priceQueryString =
      "SELECT p.Price, p.DateAdded, p.OnSale, s.Name as store, i.Name as item, b.Name as brand, u.fuid from Prices p left join StoresItems si on si.StoreItemID = p.StoreItemID left join Stores s on si.StoreID = s.StoreID left join BrandsItems bi on bi.BrandItemID = si.BrandItemID left join Items i on bi.ItemID = i.ItemID left join Brands b on b.BrandID = bi.BrandID left join Users u on u.UserID = p.UserID where p.OnSale = 1 group by p.PriceID order by DateAdded desc limit 30;";

  _HomeUIState() {
    dbConn.manualQuery(commentQueryString, [30]).then((res) => setState(() {
          results = res;
        }));
    dbConn.manualQuery(priceQueryString).then((res) => setState(() {
          priceResults = res;
        }));

    //set the user for rewards/points
    rewardsController.setUserReward(rewardsController
        .getUserReward(AuthController.to.firestoreUser.value.uid));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
        init: AuthController(),
        builder: (controller) =>
            controller?.firestoreUser?.value?.uid == null || results == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Scaffold(
                    appBar: TopNavBar(title: "Home"),
                    drawer: SideDrawer(),
                    body: homepageBody(context, results),
                    bottomNavigationBar: BotNavBar(),
                    floatingActionButton: newCommentButton(context),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.endDocked,
                  ));
  }

  Widget homepageBody(BuildContext context, List<dynamic> results) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: TabBar(
              onTap: (int index) {
                setState(() {
                  if (index == 0)
                    widget.commentBox = true;
                  else
                    widget.commentBox = false;
                });
              },
              tabs: [
                Tab(icon: Icon(Icons.chat_bubble)),
                Tab(icon: Icon(Icons.attach_money))
              ],
            ),
            body: TabBarView(
              children: [
                Container(
                    child: Column(children: [
                  Expanded(child: _buildTiles(results, "comments")),
                  //Expanded(child: Container(width: 360, child: MyCustomForm(user)))
                ])),
                Container(
                    child: Column(
                  children: [
                    Expanded(child: _buildTiles(priceResults, "prices"))
                  ],
                ))
              ],
            )));
  }

  Widget newCommentButton(BuildContext context) {
    return FloatingActionButton(
        heroTag: "homepageBtn",
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                if (widget.commentBox == true) {
                  final _formKey = GlobalKey<FormState>();
                  return AlertFormComment(_formKey);
                } else {
                  final _updatePricekey = GlobalKey<FormState>();
                  return AlertFormUpdate(_updatePricekey);
                }
              });
        });
  }

  Widget _buildTiles(var results, String type) {
    if (type == "comments") {
      return ListView.builder(
          itemCount: results.length,
          padding: EdgeInsets.all(16.0),
          itemBuilder: (context, i) {
            return _returnTiles(results[i]);
          });
    } else {
      return ListView.builder(
          itemCount: results.length,
          padding: EdgeInsets.all(16.0),
          itemBuilder: (context, i) {
            return _priceTiles(results[i]);
          });
    }
  }

  Widget _returnTiles(var result) {
    final leftSection = new Container(
        child: ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: GetUserImage(context, result[7]),
    ));
    final middleTile = new Expanded(
        child: Container(
            padding: EdgeInsets.only(left: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children:[Expanded(child:GetUserName(context, result[7])), Expanded(child:StarRating(rating: result[5], color: Colors.yellow,))]),
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: StrutStyle(fontSize: 12.0),
                      text: TextSpan(text: '${result[1]}'),
                    ),
                  ),
                ])));

    final rightSection = new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Text(
            "${convertDateFromString(result[2].toString(), 'shortDate')}",
            style: new TextStyle(color: Colors.lightGreen, fontSize: 12.0),
          ),
          new Text(
            "${convertDateFromString(result[2].toString(), 'time')}",
            style: new TextStyle(color: Colors.lightGreen, fontSize: 12.0),
          ),
        ],
      ),
    );

    return new Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      padding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      height: 70.0,
      child: new Row(
        children: <Widget>[leftSection, middleTile, rightSection],
      ),
    );
  }

  String convertDateFromString(String strDate, String dateOrTime) {
    DateTime todayDate = DateTime.parse(strDate);
    if (dateOrTime == 'date') {
      return formatDate(todayDate, [yyyy, '/', mm, '/', dd]);
    } else if (dateOrTime == 'shortDate') {
      return formatDate(todayDate, [mm, '/', dd]);
    } else {
      return formatDate(todayDate, [h, ':', mm, ' ', am]);
    }
  }

  Widget _priceTiles(List<dynamic> res) {
    AuthController controller = Get.find();

    final leftSection = new Container(
        child: ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: GetUserImage(context, res[6]),
    ));
    final middleTile = new Expanded(
        child: Container(
            padding: EdgeInsets.only(left: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GetUserName(context, res[6]),
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: StrutStyle(fontSize: 12.0),
                      text: TextSpan(text: "${res[3]}"),
                    ),
                  ),
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: StrutStyle(fontSize: 12.0),
                      text: TextSpan(text: "${res[5]} - ${res[4]}"),
                    ),
                  ),
                ])));

    final rightSection = new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Text(
            "${convertDateFromString(res[1].toString(), 'shortDate')}",
            style: new TextStyle(color: Colors.lightGreen, fontSize: 12.0),
          ),
          new Container(
            child: Text(
              "\$${res[0]}",
              style: new TextStyle(color: Colors.white, fontSize: 15.0),
            ),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightGreen),
                color: Colors.lightGreen,
                borderRadius: BorderRadius.all(Radius.circular(10))),
          )
        ],
      ),
    );

    return new Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      padding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      height: 70.0,
      child: new Row(
        children: <Widget>[leftSection, middleTile, rightSection],
      ),
    );
  }

  Widget GetUserImage(BuildContext context, String uid) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            return Image.network(
              data['photoUrl'],
              width: 30.0,
              height: 30.0,
            );
          }
          return LogoGraphicHeader();
        });
  }

  Widget GetUserName(BuildContext context, String uid) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            return Text(
              data['username'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            );
          }
          return Text("Loading",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ));
        });
  }
}
