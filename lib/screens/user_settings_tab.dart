import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../components/drawer.dart';
import '../components/top_nav_bar.dart';
import '../components/bot_nav_bar.dart';
import 'package:treat_yoself/routes.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({Key key, @required this.user}) : super(key: key);
  final int user;
  static String routeName = '/user_settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Top_Nav_Bar(user: user),
      drawer: SideDrawer(user: user),
      body: Center(
        child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 50),
                Text('Place to Change User Settings'),
                SizedBox(height: 50),
                RaisedButton(
                    child: Text('Go back to landing page'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LandingPageLogged(
                              user: user,
                            ),
                          ));
                    }),
              ],
            )),
      ),
      bottomNavigationBar: Bot_Nav_Bar(user: user),
    );
  }
}
