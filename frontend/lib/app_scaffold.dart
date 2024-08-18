import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import '../third_party/custom_icon_icons.dart';
import './common/buttons.dart';
import './common/colors_service.dart';
import './common/link_service.dart';
import './common/socket_service.dart';
import './modules/user_auth/current_user_state.dart';
import './modules/neighborhood/neighborhood_state.dart';
import './routes.dart';

_launchURL(url) async {
  //const url = 'https://flutter.dev';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class AppScaffoldComponent extends StatefulWidget {
  Widget? body;
  double width;
  bool listWrapper;
  bool selectableText;
  double paddingLeft;
  double paddingRight;
  double paddingTop;

  AppScaffoldComponent({this.body, this.width = 1200, this.listWrapper = false,
    this.selectableText = true, this.paddingLeft = 10, this.paddingRight = 10, this.paddingTop = 20,});

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffoldComponent> {
  Buttons _buttons = Buttons();
  ColorsService _colors = ColorsService();
  LinkService _linkService = LinkService();
  List<String> _routeIds = [];
  SocketService _socketService = SocketService();

  String _gitSha = '';

  @override
  void initState() {
    super.initState();

    _routeIds.add(_socketService.onRoute('GetGitSha', callback: (String resString) {
      var res = json.decode(resString);
      var data = res['data'];
      if (data['valid'] == 1) {
        setState(() { _gitSha = data['gitSha'].substring(0,7); });
      }
    }));

    _socketService.emit('GetGitSha', {});
  }

  @override
  void dispose() {
    _socketService.offRouteIds(_routeIds);
    super.dispose();
  }

  Widget _buildLinkButton(BuildContext context, String routePath, String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Theme.of(context).primaryColor)),
      ),
      child: ListTile(
        //onPressed: () {
        onTap: () {
          //if (Scaffold.of(context).isEndDrawerOpen) {
          Navigator.of(context).pop();
          //}
          context.go(routePath);
        },
        //child: Text(label),
        title: Text(label, style: TextStyle( color: Theme.of(context).primaryColor )),
      ),
    );
  }

  Widget _buildUserButton(BuildContext context, currentUserState, { double width = 100, double fontSize = 13 }) {
    if (currentUserState.isLoggedIn) {
      return SizedBox.shrink();
    }
    return TextButton(
      onPressed: () {
        context.go(Routes.login);
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: Size.fromWidth(width),
        padding: EdgeInsets.all(0),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            Icon(Icons.person, color: Theme.of(context).primaryColor),
            Text(
              'Log In',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(context, currentUserState) {
    if (currentUserState.isLoggedIn) {
      return _buildLinkButton(context, '/logout', 'Logout (${currentUserState.currentUser.firstName} ${currentUserState.currentUser.lastName})');
    }
    return SizedBox.shrink();
  }

  Widget _buildNavButton(String route, String text, IconData icon, BuildContext context, { double width = 100, double fontSize = 13 }) {
    return TextButton(
      onPressed: () {
        context.go(route);
        _socketService.TrackEvent('NavButton', properties: { 'route': route });
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: Size.fromWidth(width),
        padding: EdgeInsets.all(0),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            Icon(icon, color: Theme.of(context).primaryColor),
            Text(
              text,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context, { double width = 100, double fontSize = 13 }) {
    return Builder(
      builder: (BuildContext context) {
        return TextButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            minimumSize: Size.fromWidth(width),
            padding: EdgeInsets.all(0),
          ),
          child: Container(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              children: <Widget>[
                Icon(Icons.menu, color: Theme.of(context).primaryColor),
                Text(
                  'More',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildDrawer(BuildContext context, var currentUserState) {
    List<Widget> columns = [
      _buildLinkButton(context, '/home', 'Home'),
      _buildLinkButton(context, '/weekly-events', 'Events'),
      _buildLinkButton(context, '/neighborhoods', 'Neighborhoods'),
      _buildLinkButton(context, '/own', 'Shared Items'),
    ];
    if (currentUserState.isLoggedIn) {
      columns += [
        _buildLinkButton(context, '/user-money', 'Funds and Payments'),
        _buildLinkButton(context, '/user', 'User Profile'),
      ];
    }
    if (currentUserState.hasRole('admin')) {
    }
    // columns += [
    //   _buildLinkButton(context, '/about', 'About'),
    // ];
    Color footerColor = Colors.white;

    List<Map<String, dynamic>> links = [
      { 'text': 'About', 'link': '/about', },
      { 'text': 'Blog', 'link': '/blog', },
      { 'text': 'Team', 'link': '/team', },
      { 'text': 'Belonging Survey', 'link': '/belonging-survey', },
      { 'text': 'Neighborhood Journey', 'link': '/neighborhood-journey', },
    ];
    List<TextSpan> spanLinks = [];
    for (var link in links) {
      spanLinks.add(
        TextSpan(
          text: link['text'],
          style: TextStyle(color: footerColor),
          recognizer: TapGestureRecognizer()..onTap = () {
            context.go(link['link']);
          },
        ),
      );
      if (link != links.last) {
        spanLinks.add(TextSpan(text: ' | ', style: TextStyle(color: footerColor),));
      }
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(''),
              ),
              IconButton(
                icon: Icon(Icons.close),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                }
              ),
            ],
          ),
          ...columns,
          _buildLogoutButton(context, currentUserState),
          SizedBox(height: 30),
          // Text('Powered by Collobartive.Earth', style: TextStyle(color: Colors.white)),
          RichText( textAlign: TextAlign.center, text: TextSpan(
            children: [
              ...spanLinks,
            ]
          )),
          SizedBox(height: 10),
          Text('Version ${_gitSha}'),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, var currentUserState) {
    List<Widget> rows = [];
    if (currentUserState.isLoggedIn) {
      var neighborhoodState = Provider.of<NeighborhoodState>(context, listen: false);
      // var neighborhoodState = context.watch<NeighborhoodState>();
      if (neighborhoodState.defaultUserNeighborhood != null) {
        rows += [
          Expanded(
            flex: 1,
            child: _buildNavButton('/n/${neighborhoodState.defaultUserNeighborhood!.neighborhood.uName}', 'Neighborhood', Icons.house, context, width: double.infinity, fontSize: 10),
          ),
        ];
      }
      rows += [
        Expanded(
          flex: 1,
          child: _buildNavButton('/user', 'My Events', Icons.event, context, width: double.infinity, fontSize: 10),
        ),
      ];
    }
    rows += [
      // Expanded(
      //   flex: 1,
      //   child: _buildNavButton('/home', 'Home', Icons.home, context, width: double.infinity, fontSize: 10),
      // ),
      // Expanded(
      //   flex: 1,
      //   child: _buildNavButton('/own', 'Own', Icons.build, context, width: double.infinity, fontSize: 10),
      // ),
      // Expanded(
      //   flex: 1,
      //   child: _buildNavButton('/eat', 'Shared Meals', Icons.event, context, width: double.infinity, fontSize: 10),
      // ),
    ];
    if (!currentUserState.isLoggedIn) {
      rows.add(Expanded(
        flex: 1,
        child: _buildUserButton(context, currentUserState, width: double.infinity, fontSize: 10),
      ));
    }
    rows.add(
      Expanded(
        flex: 1,
        child: _buildDrawerButton(context, width: double.infinity, fontSize: 10),
      ),
    );

    return SafeArea(
      child: Container(
        height: 55,
        child: Row(
          children: <Widget>[
            ...rows,
          ]
        ),
        color: Colors.white,
        // decoration: BoxDecoration(
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.shade300,
        //       spreadRadius: 2,
        //       blurRadius: 4,
        //       offset: Offset(0, 0),
        //     )
        //   ]
        // ),
      )
    );
  }

  Widget _buildBody(BuildContext context, var currentUserState, { bool header = false, String size = 'small' }) {
    List<Widget> colsHeader = [];
    if (header) {
      colsHeader = [
        _buildHeader(context, currentUserState),
        // For drop shadow, otherwise it is cut off.
        // SizedBox(height: 5),
      ];
    }

    List<Widget> colsBelowHeader = [];
    if (currentUserState.appData.containsKey('eventFeedbackSave')) {
      String link = '/event-feedback-save?eventId=' + currentUserState.appData['eventFeedbackSave']['eventId'];
      colsBelowHeader = [
        Container(color: _colors.colors['primary'], height: 50,
          child: Row(
            children: [
              Expanded(flex: 1, child: Text('')),
              _buttons.Link(context, 'Add Your Event Feedback', link, colorBackground: 'white'),
              Expanded(flex: 1, child: Text('')),
            ]
          )
        ),
      ];
    }

    if (widget.listWrapper) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...colsHeader,
          ...colsBelowHeader,
          Expanded(flex: 1,
            child: ListView(
              children: [
                Container(color: Colors.white,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: widget.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(top: widget.paddingTop, left: widget.paddingLeft, right: widget.paddingRight, bottom: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 600),
                      child: widget.body!,
                    ),
                  )
                )),
                Container(color: Colors.white, height: 20),
                BuildFooter(context, size: size),
              ]
            )
          )
        ]
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ...colsHeader,
        ...colsBelowHeader,
        Expanded(flex: 1,
          child: Container(
            color: Colors.white,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: widget.width,
                color: Colors.white,
                child: widget.body!,
              )
            )
          )
        )
      ]
    );
  }

  Widget BuildFooter(BuildContext context, {String size = 'small'}) {
    String email = 'team@tealtowns.org';
    List<Map<String, dynamic>> links = [
      { 'url': '/about', 'text': 'About' },
      { 'url': '/blog', 'text': 'Blog' },
    ];
    Color footerColor = _colors.colors['white'];
    if (size == 'small') {
      return Container(
        color: _colors.colors['primaryDark'],
        child: Column(
          children: [
            SizedBox(height: 30),
            Image.asset('assets/images/logo-white.png', width: 50, height: 50),
            SizedBox(height: 20),
            Text(email, style: TextStyle(color: footerColor)),
            SizedBox(height: 10),
            Divider(color: footerColor, indent: 20, endIndent: 20, thickness: 1,),
            SizedBox(height: 10),
            RichText( textAlign: TextAlign.center, text: TextSpan(
              children: [
                ...links.map((link) => TextSpan(
                  text: ' ${link['text']} ',
                  style: TextStyle(color: footerColor),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    context.go(link['url']);
                  },
                )).toList(),
              ]
            )),
            SizedBox(height: 10),
            Text('2024 TealTowns', style: TextStyle(color: footerColor)),
            // SizedBox(height: 10),
            Text('All Rights Reserved', style: TextStyle(color: footerColor)),
            SizedBox(height: 10),
            IconButton(
              iconSize: 25,
              icon: Icon(CustomIcon.linkedin, color: footerColor),
              onPressed: () {
                _linkService.LaunchURL('https://www.linkedin.com/company/101358571');
              },
            ),
            SizedBox(height: 10),
          ],
        )
      );
    }


    List<Widget> rowsLinks = [];
    for (Map<String, dynamic> link in links) {
      rowsLinks += [
        _buttons.LinkInline(context, link['text'], link['url'], colorText: 'white'),
        SizedBox(width: 20),
      ];
    }
    return Container(
      color: _colors.colors['primaryDark'],
      padding: EdgeInsets.only(top: 20, bottom: 20, left: 50, right: 50),
      child: Row(
        children: [
          Image.asset('assets/images/logo-white.png', width: 30, height: 30),
          SizedBox(width: 20),
          Text(email, style: TextStyle(color: footerColor)),
          Expanded(flex: 1, child: Container()),
          ...rowsLinks,
          SizedBox(width: 20),
          Text('2024 TealTowns', style: TextStyle(color: footerColor)),
          SizedBox(width: 20),
          IconButton(
            iconSize: 25,
            icon: Icon(CustomIcon.linkedin, color: footerColor),
            onPressed: () {
              _linkService.LaunchURL('https://www.linkedin.com/company/101358571');
            },
          ),
        ]
      )
    );
  }

  Widget _buildSmall(BuildContext context, var currentUserState) {
    Widget content = Scaffold(
      endDrawer: _buildDrawer(context, currentUserState),
      body: _buildBody(context, currentUserState, header: true, size: 'small'),
    );
    if (widget.selectableText) {
      return SelectionArea(
        child: content
      );
    }
    return content;
  }

  Widget _buildMedium(BuildContext context, var currentUserState) {
    List<Widget> buttons = [];
    if (currentUserState.isLoggedIn) {
      var neighborhoodState = Provider.of<NeighborhoodState>(context, listen: false);
      // var neighborhoodState = context.watch<NeighborhoodState>();
      if (neighborhoodState.defaultUserNeighborhood != null) {
        buttons += [
          _buildNavButton('/n/${neighborhoodState.defaultUserNeighborhood!.neighborhood.uName}',
            'Neighborhood', Icons.house, context),
        ];
      }
      buttons += [
        _buildNavButton('/user', 'My Events', Icons.event, context),
      ];
    }
    Widget content = Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        // title: Image.asset('assets/images/logo.png', width: 100, height: 50),
        title: InkWell(
          onTap: () {
            context.go('/home');
          },
          child: Image.asset('assets/images/logo.png', width: 100, height: 50),
        ),
        actions: <Widget>[
          // _buildNavButton('/home', 'Home', Icons.home, context),
          // _buildNavButton('/own', 'Own', Icons.build, context),
          ...buttons,
          // _buildNavButton('/eat', 'Shared Meals', Icons.event, context),
          _buildUserButton(context, currentUserState),
          _buildDrawerButton(context),
        ],
      ),
      endDrawer: _buildDrawer(context, currentUserState),
      body: _buildBody(context, currentUserState, size: 'medium'),
    );
    if (widget.selectableText) {
      return SelectionArea(
        child: content,
      );
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    var currentUserState = context.watch<CurrentUserState>();
    String url = currentUserState.GetRouterRedirectUrl();
    if (url.length > 0) {
      Timer(Duration(milliseconds: 200), () {
        context.go(url);
      });
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildMedium(context, currentUserState);
        } else {
          return _buildSmall(context, currentUserState);
        }
      }
    );
  }
}
