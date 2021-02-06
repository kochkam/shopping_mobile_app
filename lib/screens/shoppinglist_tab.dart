import 'package:flutter/material.dart';
import '../components/drawer.dart';
import 'package:treat_yoself/screens/search_results_tab.dart';
import './search_results_tab.dart';
import 'const_lists.dart';
import './list_tiles.dart';
import '../components/top_nav_bar.dart';
import '../components/bot_nav_bar.dart';

class ShoppingList extends StatefulWidget {
  static String routeName = '/shopping_list';

  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  @override
  Widget build(BuildContext context) {
    //build a news feed list
    return Scaffold(
      appBar: Top_Nav_Bar(),
      drawer: SideDrawer(),
      body: _buildLists(),
      bottomNavigationBar: Bot_Nav_Bar(),
    );
  }

  _buildLists() {
    return Container(child: Column(children: [Expanded(child: ListTiles())]));
  }

  void _pushRoute() {
    Navigator.pushReplacementNamed(context, '/landing_page');
  }
}

class Items {
  final String name;
  final String price;
  final String brand;

  Items(this.name, this.price, this.brand);

  buildItem() {
    return Card(
        child: Material(
      color: getRandomColors(),
      child: InkWell(
        onTap: () => null,
        splashColor: Colors.white,
        child: ListTile(
          title: Text(name),
          subtitle: Text(price),
          trailing: Text(brand),
          tileColor: getRandomColors(),
        ),
      ),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
    ));
  }
}

final topRow = new Expanded(
    child: Container(
        padding: EdgeInsets.only(left: 8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Text(
                "Add New Item",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ])));

_addNewRow() {
  return Row(children: [
    Container(
        padding: EdgeInsets.only(left: 8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Text(
                "Item Added",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ]))
  ]);
}
