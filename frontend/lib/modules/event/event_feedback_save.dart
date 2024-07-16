import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/date_time_service.dart';
import '../../common/form_input/image_save.dart';
import '../../common/form_input/input_fields.dart';
import '../../common/link_service.dart';
import '../../common/parse_service.dart';
import '../../common/socket_service.dart';
import './user_event_class.dart';
import './event_class.dart';
import './weekly_event_class.dart';
import '../user_auth/current_user_state.dart';

class EventFeedbackSave extends StatefulWidget {
  String eventId;
  EventFeedbackSave({this.eventId = '',});

  @override
  _EventFeedbackSaveState createState() => _EventFeedbackSaveState();
}

class _EventFeedbackSaveState extends State<EventFeedbackSave> {
  DateTimeService _dateTime = DateTimeService();
  List<String> _routeIds = [];
  SocketService _socketService = SocketService();
  InputFields _inputFields = InputFields();
  LinkService _linkService = LinkService();
  ParseService _parseService = ParseService();

  Map<String, dynamic> _eventFeedback = {};
  Map<String, dynamic> _formValsEventFeedback = {
    'feedbackVoteIds': [''],
    'feedback': '',
    'positiveVoteIds': [''],
    'positiveFeedback': '',
    'imageUrls': [],
  };
  String _userFeedbackId = '';
  Map<String, dynamic> _formValsUserFeedback = {
    // 'forType': 'event',
    'attended': '',
    'stars': 0,
    'willJoinNextWeek': '',
    'willInvite': '',
    'invitesString': '',
  };
  List<Map<String, dynamic>> _optsFeedbackVotes = [];
  List<Map<String, dynamic>> _optsPositiveVotes = [];
  List<Map<String, dynamic>> _optsWillJoinNextWeek = [
    {'value': 'yes', 'label': 'Yes'},
    {'value': 'no', 'label': 'No'},
    {'value': 'futureWeek', 'label': 'Not next week, but will join a future week'},
  ];
  List<Map<String, dynamic>> _optsWillInvite = [
    {'value': 'no', 'label': 'No one this week'},
    {'value': 'willMeetNewNeighbor', 'label': 'I will meet a new neighbor and invite them!'},
  ];
  List<Map<String, dynamic>> _optsAttended = [
    {'value': 'yes', 'label': 'Yes'},
    {'value': 'no', 'label': 'No'},
  ];
  List<Map<String, dynamic>> _optsStars = [
    {'value': 1, 'label': '1 Star'},
    {'value': 2, 'label': '2 Stars'},
    {'value': 3, 'label': '3 Stars'},
    {'value': 4, 'label': '4 Stars'},
    {'value': 5, 'label': '5 Stars'},
  ];
  EventClass _event = EventClass.fromJson({});
  WeeklyEventClass _weeklyEvent = WeeklyEventClass.fromJson({});
  String _socketGroupName = '';
  String _userId = '';
  bool _loadingSubmit = false;
  String _message = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _socketGroupName = 'eventFeedback_' + widget.eventId;
    _formValsUserFeedback['eventId'] = widget.eventId;

    _routeIds.add(_socketService.onRoute('GetEventFeedbackByEvent', callback: (String resString) {
      var res = json.decode(resString);
      var data = res['data'];
      if (data['valid'] == 1) {
        setState(() { _eventFeedback = data['eventFeedback']; });
        SetFeedbackOpts(_eventFeedback);
      }
    }));

    _routeIds.add(_socketService.onRoute('GetEventWithWeekly', callback: (String resString) {
      var res = json.decode(resString);
      var data = res['data'];
      if (data['valid'] == 1) {
        _event = EventClass.fromJson(data['event']);
        _weeklyEvent = WeeklyEventClass.fromJson({});
        if (data.containsKey('weeklyEvent') && data['weeklyEvent'].containsKey('_id')) {
          _weeklyEvent = WeeklyEventClass.fromJson(data['weeklyEvent']);
        }
        setState(() { _event = _event; _weeklyEvent = _weeklyEvent; });
      }
    }));

    _routeIds.add(_socketService.onRoute('AddEventFeedbackVote', callback: (String resString) {
      var res = json.decode(resString);
      var data = res['data'];
      if (data['valid'] == 1) {
        _formValsEventFeedback['feedback'] = '';
        setState(() { _formValsEventFeedback = _formValsEventFeedback; });
        if (data.containsKey('eventFeedback')) {
          setState(() { _eventFeedback = data['eventFeedback']; });
          SetFeedbackOpts(_eventFeedback);
        }
      }
    }));

    _routeIds.add(_socketService.onRoute('AddEventPositiveVote', callback: (String resString) {
      var res = json.decode(resString);
      var data = res['data'];
      if (data['valid'] == 1) {
        _formValsEventFeedback['feedback'] = '';
        setState(() { _formValsEventFeedback = _formValsEventFeedback; });
        if (data.containsKey('eventFeedback')) {
          setState(() { _eventFeedback = data['eventFeedback']; });
          SetFeedbackOpts(_eventFeedback);
        }
      }
    }));

    _routeIds.add(_socketService.onRoute('OnEventFeedback', callback: (String resString) {
      var res = json.decode(resString);
      var data = res['data'];
      if (data['valid'] == 1 && data['eventFeedback']['eventId'] == widget.eventId) {
        setState(() { _eventFeedback = data['eventFeedback']; });
        SetFeedbackOpts(_eventFeedback);
      }
    }));

    _routeIds.add(_socketService.onRoute('GetUserFeedback', callback: (String resString) {
      var res = json.decode(resString);
      var data = res['data'];
      if (data['valid'] == 1 && data['userFeedback'].containsKey('_id')) {
        _userFeedbackId = data['userFeedback']['_id'];
        _formValsUserFeedback['attended'] = data['userFeedback']['attended'];
        _formValsUserFeedback['stars'] = data['userFeedback']['stars'];
        _formValsUserFeedback['willJoinNextWeek'] = data['userFeedback']['willJoinNextWeek'];
        _formValsUserFeedback['willInvite'] = data['userFeedback']['willInvite'];
        setState(() { _formValsUserFeedback = _formValsUserFeedback; _userFeedbackId = _userFeedbackId; _loading = false; });
      } else {
        setState(() { _loading = false; });
      }
    }));

    _routeIds.add(_socketService.onRoute('SaveUserFeedback', callback: (String resString) {
      var res = json.decode(resString);
      var data = res['data'];
      if (data['valid'] == 1) {
        if (data.containsKey('missingFeedbackEventIds')) {
          var currentUserState = Provider.of<CurrentUserState>(context, listen: false);
          currentUserState.SetAppData({'eventFeedbackMissingIds': data['missingFeedbackEventIds']});
        }
        String route = '/home';
        int isAlreadyAmbassador = data.containsKey('isAlreadyAmbassador') ? _parseService.toIntNoNull(data['isAlreadyAmbassador']) : 0;
        int stars = _parseService.toIntNoNull(data['userFeedback']['stars']);
        if (isAlreadyAmbassador < 1 && stars >= 4) {
          String neighborhoodUName = data['neighborhoodUName'];
          route = '/user-neighborhood-save?neighborhoodUName=${neighborhoodUName}';
        } else if (_weeklyEvent.uName.length > 0) {
          route = '/we/' + _weeklyEvent.uName;
        }
        context.go(route);
      }
    }));

    var currentUserState = Provider.of<CurrentUserState>(context, listen: false);
    if (currentUserState.isLoggedIn) {
      _userId = currentUserState.currentUser.id;
      if (widget.eventId.length > 0) {
        var data = { 'groupName': _socketGroupName, 'userIds': [ _userId ] };
        _socketService.emit('AddSocketGroupUsers', data);
        _socketService.emit('GetEventFeedbackByEvent', { 'eventId': widget.eventId });
        _socketService.emit('GetEventWithWeekly', { 'eventId': widget.eventId });
        _socketService.emit('GetUserFeedback', { 'forType': 'event', 'forId': widget.eventId, 'userId': _userId });
      }
    }
  }

  @override
  void dispose() {
    if (_userId.length > 0) {
      var data = { 'groupName': _socketGroupName, 'userIds': [ _userId ] };
      _socketService.emit('RemoveSocketGroupUsers', data);
    }
    _socketService.offRouteIds(_routeIds);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentUserState = Provider.of<CurrentUserState>(context, listen: false);
    if (!currentUserState.isLoggedIn) {
      Timer(Duration(milliseconds: 500), () {
        _linkService.Go('', context, currentUserState: currentUserState);
      });
      return Text('Logging in..');
    }
    if (widget.eventId.length < 1) {
      return Text('No event id');
    }
    if (!_eventFeedback.containsKey('_id') || _event.id.length < 1 || _event.start.length < 1 || _loading) {
      return Column(children: [ LinearProgressIndicator() ]);
    }

    List<Widget> colsFeedback = [];
    if (_optsFeedbackVotes.length > 0) {
      colsFeedback = [
        _inputFields.inputMultiSelectButtons(_optsFeedbackVotes, _formValsEventFeedback, 'feedbackVoteIds',),
        SizedBox(height: 10,),
      ];
    }
    List<Widget> colsPositiveFeedback = [];
    if (_optsPositiveVotes.length > 0) {
      colsPositiveFeedback = [
        _inputFields.inputMultiSelectButtons(_optsPositiveVotes, _formValsEventFeedback, 'positiveVoteIds',),
        SizedBox(height: 10,),
      ];
    }

    List<Widget> colsSubmit = [];
    if (_loadingSubmit) {
      colsSubmit = [
        SizedBox(height: 10),
        LinearProgressIndicator(),
        SizedBox(height: 10),
      ];
    } else {
      colsSubmit = [
        SizedBox(height: 50),
        ElevatedButton(child: Text('Submit'), onPressed: () {
          Save();
        },),
        SizedBox(height: 10,),
        Text(_message),
        SizedBox(height: 50,),
      ];
    }

    List<Widget> colsNextEvent = [];
    if (_weeklyEvent.id.length > 0) {
      colsNextEvent = [
        _inputFields.inputSelectButtons(_optsWillJoinNextWeek, _formValsUserFeedback, 'willJoinNextWeek',
          label: 'Will you be joining next week?',),
        SizedBox(height: 10,),
        _inputFields.inputText(_formValsUserFeedback, 'invitesString',
          label: 'Who would you like invite to next week\'s event (comma separated list of name, phone or email)?',
          hint: 'Sally M, 1-555-123-4567, joe@email.com',),
        // SizedBox(height: 10,),
        _inputFields.inputSelectButtons(_optsWillInvite, _formValsUserFeedback, 'willInvite',),
        SizedBox(height: 10,),
      ];
    }

    String eventStart = _dateTime.Format(_event.start, 'EEEE M/d/y');
    List<Widget> colsAttended = [];
    if (_formValsUserFeedback['attended'] == 'yes') {
      colsAttended = [
        _inputFields.inputSelectButtons(_optsStars, _formValsUserFeedback, 'stars', label: 'How would you rate this event?'),
        SizedBox(height: 30,),
        Text('What is 1 improvement that would make this event better?'),
        // SizedBox(height: 10,),
        ...colsFeedback,
        _inputFields.inputText(_formValsEventFeedback, 'feedback', label: 'Write your feedback',),
        SizedBox(height: 10,),
        TextButton(child: Text('Add Feedback'), onPressed: () {
          if (_formValsEventFeedback['feedback'].length > 2) {
            var feedbackVote = {
              'feedback': _formValsEventFeedback['feedback'],
              'userIds': [ Provider.of<CurrentUserState>(context, listen: false).currentUser.id ]
            };
            var data = { 'eventFeedbackId': _eventFeedback['_id'], 'feedbackVote': feedbackVote };
            _socketService.emit('AddEventFeedbackVote', data);
          }
        },),
        SizedBox(height: 30,),
        Text('What did you gain or enjoy?'),
        // SizedBox(height: 10,),
        ...colsPositiveFeedback,
        _inputFields.inputText(_formValsEventFeedback, 'positiveFeedback', label: 'Write what you enjoyed or gained',),
        SizedBox(height: 10,),
        TextButton(child: Text('Add Positive Feedback'), onPressed: () {
          if (_formValsEventFeedback['positiveFeedback'].length > 2) {
            var positiveVote = {
              'feedback': _formValsEventFeedback['positiveFeedback'],
              'userIds': [ Provider.of<CurrentUserState>(context, listen: false).currentUser.id ]
            };
            var data = { 'eventFeedbackId': _eventFeedback['_id'], 'positiveVote': positiveVote };
            _socketService.emit('AddEventPositiveVote', data);
          }
        },),
        SizedBox(height: 10,),
        ImageSaveComponent(formVals: _formValsEventFeedback, formValsKey: 'imageUrls', multiple: true,
          label: 'Have any event photos?', imageUploadSimple: true,),
        SizedBox(height: 10,),
      ];
    }

    String label = 'Did you attend ${_weeklyEvent.title}, ${eventStart}?';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputFields.inputSelectButtons(_optsAttended, _formValsUserFeedback, 'attended', label: label, onChanged: (String val) {
          _formValsUserFeedback['attended'] = val;
          setState(() { _formValsUserFeedback = _formValsUserFeedback; });
        }),
        SizedBox(height: 10,),
        ...colsAttended,
        ...colsNextEvent,
        ...colsSubmit,
        SizedBox(height: 50,),
      ],
    );
  }

  void SetFeedbackOpts(Map<String, dynamic> eventFeedback) {
    _optsFeedbackVotes = [];
    for (var i = 0; i < eventFeedback['feedbackVotes'].length; i++) {
      String label = '(${eventFeedback['feedbackVotes'][i]['userIds'].length}) ${eventFeedback['feedbackVotes'][i]['feedback']}';
      _optsFeedbackVotes.add({'value': eventFeedback['feedbackVotes'][i]['id'], 'label': label });
      if (_userId.length > 0 && eventFeedback['feedbackVotes'][i]['userIds'].contains(_userId) &&
        !_formValsEventFeedback['feedbackVoteIds'].contains(eventFeedback['feedbackVotes'][i]['id'])) {
        _formValsEventFeedback['feedbackVoteIds'].add(eventFeedback['feedbackVotes'][i]['id']);
      }
    }
    _optsPositiveVotes = [];
    for (var i = 0; i < eventFeedback['positiveVotes'].length; i++) {
      String label = '(${eventFeedback['positiveVotes'][i]['userIds'].length}) ${eventFeedback['positiveVotes'][i]['feedback']}';
      _optsPositiveVotes.add({'value': eventFeedback['positiveVotes'][i]['id'], 'label': label });
      if (_userId.length > 0 && eventFeedback['positiveVotes'][i]['userIds'].contains(_userId) &&
        !_formValsEventFeedback['positiveVoteIds'].contains(eventFeedback['positiveVotes'][i]['id'])) {
        _formValsEventFeedback['positiveVoteIds'].add(eventFeedback['positiveVotes'][i]['id']);
      }
    }
    setState(() { _optsFeedbackVotes = _optsFeedbackVotes; _optsPositiveVotes = _optsPositiveVotes; });
  }

  void Save() {
    var userId = Provider.of<CurrentUserState>(context, listen: false).currentUser.id;
    var data = {};
    if (_formValsEventFeedback['feedbackVoteIds'].length > 0 ||
      _formValsEventFeedback['positiveVoteIds'].length > 0) {
      data = {
        'eventFeedbackId': _eventFeedback['_id'],
        'feedbackVoteIds': _formValsEventFeedback['feedbackVoteIds'],
        'positiveVoteIds': _formValsEventFeedback['positiveVoteIds'],
        'userId': userId,
      };
      _socketService.emit('AddEventFeedbackUserVotes', data);
    }
    if (_formValsEventFeedback['imageUrls'].length > 0) {
      data = {
        'eventFeedbackId': _eventFeedback['_id'],
        'imageUrls': _formValsEventFeedback['imageUrls'],
      };
      _socketService.emit('AddEventFeedbackImages', data);
    }

    List<String> invites = [];
    if (_formValsUserFeedback['invitesString'].trim().length > 0) {
      invites = _formValsUserFeedback['invitesString'].trim().split(',');
      for (var i = 0; i < invites.length; i++) {
        invites[i] = invites[i].trim();
      }
    }
    data = {
      'userFeedback': {
        'userId': userId,
        'forType': 'event',
        'forId': widget.eventId,
        'attended': _formValsUserFeedback['attended'],
        'stars': _formValsUserFeedback['stars'],
        'willJoinNextWeek': _formValsUserFeedback['willJoinNextWeek'],
        'willInvite': _formValsUserFeedback['willInvite'],
        'invites': invites,
      },
      'withCheckAskForFeedback': 1,
      'withCheckNeighborhoodAmbassador': 1,
      'neighborhoodUName': _weeklyEvent.neighborhoodUName,
    };
    if (_userFeedbackId.length > 0) {
      data['userFeedback']['_id'] = _userFeedbackId;
    }
    _socketService.emit('SaveUserFeedback', data);

    setState(() { _loadingSubmit = true; });
  }
}