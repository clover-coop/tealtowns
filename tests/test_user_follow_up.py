import date_time
from insight import user_insight as _user_insight
import mongo_mock as _mongo_mock
from neighborhood import user_neighborhood_weekly_update as _user_neighborhood_weekly_update
from stubs import stubs_data as _stubs_data
from user_follow_up import user_follow_up as _user_follow_up

def SumCounts(ret):
    countsByKey = {}
    for key in ret['notifyUsernamesByType']:
        for key1 in ret['notifyUsernamesByType'][key]:
            if key not in countsByKey:
                countsByKey[key] = 0
            countsByKey[key] += len(ret['notifyUsernamesByType'][key][key1])
    return countsByKey

def test_CheckAndDoFollowUps():
    _mongo_mock.InitAllCollections()
    users = [
        { 'phoneNumber': '1234567890', 'phoneNumberVerified': 1, 'whatsappNumberVerified': 0, },
        { 'phoneNumber': '0987654321', 'phoneNumberVerified': 1 },
        { 'whatsappNumber': '1234567890', 'whatsappNumberVerified': 1 },
        { 'whatsappNumber': '0987654321', 'whatsappNumberVerified': 1 },
        { 'email': '4HJQ4@example.com', 'emailVerified': 1 },
        { 'email': '4HJQ4@example.com', 'emailVerified': 1 },
    ]
    users = _stubs_data.CreateBulk(objs = users, collectionName = 'user')
    # 2 ambassador sign ups incomplete
    userInsights = [
        { 'userId': users[0]['_id'], 'username': users[0]['username'], 'ambassadorSignUpStepsAt': {
            'userNeighborhoodSave': '2024-05-18 09:00:00+00:00',
        }, },
        { 'userId': users[1]['_id'], 'username': users[1]['username'], 'ambassadorSignUpStepsAt': {
            'userNeighborhoodSave': '2024-05-18 09:00:00+00:00', 'locationSelect': '2024-05-18 09:05:00+00:00',
        }, },
    ]
    userInsights = _stubs_data.CreateBulk(objs = userInsights, collectionName = 'userInsight')

    neighborhoods = [
        { 'timezone': 'UTC' },
        { 'timezone': 'America/New_York' },
    ]
    neighborhoods = _stubs_data.CreateBulk(objs = neighborhoods, collectionName = 'neighborhood')

    # 1 user not started yet
    userNeighborhoods = [
        { 'userId': users[2]['_id'], 'username': users[2]['username'], 'roles': ['ambassador'],
         'neighborhoodUName': neighborhoods[1]['uName'] },
    ]
    userNeighborhoods = _stubs_data.CreateBulk(objs = userNeighborhoods, collectionName = 'userNeighborhood')
    # 2 users with updates but more than a week behind
    userNeighborhoodWeeklyUpdates = [
        { 'userId': users[3]['_id'], 'username': users[3]['username'], 'start': '2024-05-01 09:00:00+00:00',
         'end': '2024-05-08 09:00:00+00:00', 'inviteCount': 5, 'attendedCount': 4, 'neighborhoodUName': neighborhoods[0]['uName'] },
        { 'userId': users[4]['_id'], 'username': users[4]['username'], 'start': '2024-05-05 09:00:00+00:00',
         'end': '2024-05-12 09:00:00+00:00', 'inviteCount': 3, 'attendedCount': 2, 'neighborhoodUName': neighborhoods[1]['uName'] },
    ]
    userNeighborhoodWeeklyUpdates = _stubs_data.CreateBulk(objs = userNeighborhoodWeeklyUpdates,
        collectionName = 'userNeighborhoodWeeklyUpdate')

    nextFollowUpMaxDays = 2
    nextFollowUpMinDays = 2
    nextFollowUpHourMin = 10
    nextFollowUpHourMax = 11
    # First time - all should be notified
    now = date_time.from_string('2024-05-20 09:00:00+00:00')
    ret = _user_follow_up.CheckAndDoFollowUps(now = now, nextFollowUpMinDays = nextFollowUpMinDays,
        nextFollowUpMaxDays = nextFollowUpMaxDays, nextFollowUpHourMin = nextFollowUpHourMin,
        nextFollowUpHourMax = nextFollowUpHourMax)
    countsByKey = SumCounts(ret)
    assert countsByKey['ambassadorSignUp'] == 2
    assert countsByKey['ambassadorUpdate'] == 3

    # Next hour; too soon for new notifications
    now = date_time.from_string('2024-05-20 10:00:00+00:00')
    ret = _user_follow_up.CheckAndDoFollowUps(now = now, nextFollowUpMinDays = nextFollowUpMinDays,
        nextFollowUpMaxDays = nextFollowUpMaxDays, nextFollowUpHourMin = nextFollowUpHourMin,
        nextFollowUpHourMax = nextFollowUpHourMax)
    countsByKey = SumCounts(ret)
    assert countsByKey['ambassadorSignUp'] == 0
    assert countsByKey['ambassadorUpdate'] == 0

    # 2 days from start, attempt 2
    now = date_time.from_string('2024-05-22 15:00:00+00:00')
    ret = _user_follow_up.CheckAndDoFollowUps(now = now, nextFollowUpMinDays = nextFollowUpMinDays,
        nextFollowUpMaxDays = nextFollowUpMaxDays, nextFollowUpHourMin = nextFollowUpHourMin,
        nextFollowUpHourMax = nextFollowUpHourMax)
    countsByKey = SumCounts(ret)
    assert countsByKey['ambassadorSignUp'] == 2
    assert countsByKey['ambassadorUpdate'] == 3

    # user 0 finishes sign up.
    _user_insight.SetActionAt(users[0]['_id'], 'ambassadorSignUpStepsAt.resources')

    # 4 days from start, attempt 3
    now = date_time.from_string('2024-05-24 15:00:00+00:00')
    ret = _user_follow_up.CheckAndDoFollowUps(now = now, nextFollowUpMinDays = nextFollowUpMinDays,
        nextFollowUpMaxDays = nextFollowUpMaxDays, nextFollowUpHourMin = nextFollowUpHourMin,
        nextFollowUpHourMax = nextFollowUpHourMax)
    countsByKey = SumCounts(ret)
    assert countsByKey['ambassadorSignUp'] == 1
    assert countsByKey['ambassadorUpdate'] == 3

    # 6 days from start, attempt 4
    now = date_time.from_string('2024-05-26 15:00:00+00:00')
    ret = _user_follow_up.CheckAndDoFollowUps(now = now, nextFollowUpMinDays = nextFollowUpMinDays,
        nextFollowUpMaxDays = nextFollowUpMaxDays, nextFollowUpHourMin = nextFollowUpHourMin,
        nextFollowUpHourMax = nextFollowUpHourMax)
    countsByKey = SumCounts(ret)
    assert countsByKey['ambassadorSignUp'] == 1
    assert countsByKey['ambassadorUpdate'] == 3

    # user 3 submits a weekly update
    userNeighborhoodWeeklyUpdate = { 'userId': users[3]['_id'], 'username': users[3]['username'], 'start': '2024-05-15 09:00:00+00:00',
     'end': '2024-05-22 09:00:00+00:00', 'inviteCount': 5, 'attendedCount': 4,
     'neighborhoodUName': userNeighborhoodWeeklyUpdates[0]['neighborhoodUName'] }
    _user_neighborhood_weekly_update.Save(userNeighborhoodWeeklyUpdate)

    # 8 days from start, attempt 5
    now = date_time.from_string('2024-05-28 15:00:00+00:00')
    ret = _user_follow_up.CheckAndDoFollowUps(now = now, nextFollowUpMinDays = nextFollowUpMinDays,
        nextFollowUpMaxDays = nextFollowUpMaxDays, nextFollowUpHourMin = nextFollowUpHourMin,
        nextFollowUpHourMax = nextFollowUpHourMax)
    countsByKey = SumCounts(ret)
    assert countsByKey['ambassadorSignUp'] == 1
    assert countsByKey['ambassadorUpdate'] == 2

    # 10 days later, removed (over max attempts)
    now = date_time.from_string('2024-05-30 15:00:00+00:00')
    ret = _user_follow_up.CheckAndDoFollowUps(now = now, nextFollowUpMinDays = nextFollowUpMinDays,
        nextFollowUpMaxDays = nextFollowUpMaxDays, nextFollowUpHourMin = nextFollowUpHourMin,
        nextFollowUpHourMax = nextFollowUpHourMax)
    countsByKey = SumCounts(ret)
    assert countsByKey['ambassadorSignUp'] == 0
    assert countsByKey['ambassadorUpdate'] == 0

    _mongo_mock.CleanUp()
