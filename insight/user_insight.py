import datetime

import date_time
from common import mongo_db_crud as _mongo_db_crud
# import lodash
import mongo_db
from user_follow_up import user_follow_up as _user_follow_up

def Save(userInsight, skipIfExistsKeys: list = ['firstEventSignUpAt', 'firstNeighborhoodJoinAt']):
    # userInsight = lodash.extend_object({
    #     'lastActiveAt': '',
    #     'firstEventSignUpAt': '',
    #     'firstNeighborhoodJoinAt': ''
    # }, userInsight)
    item = mongo_db.find_one('userInsight', { 'userId': userInsight['userId'] })['item']
    if item is not None:
        userInsight['_id'] = item['_id']
        for key in skipIfExistsKeys:
            if key in item and key in userInsight:
                del userInsight[key]
    else:
        if 'ambassadorSignUpStepsAt' not in userInsight:
            userInsight['ambassadorSignUpStepsAt'] = {}
        if 'ambassadorNetworkStepsAt' not in userInsight:
            userInsight['ambassadorNetworkStepsAt'] = {}
        if 'username' not in userInsight:
            user = mongo_db.find_one('user', { '_id': userInsight['userId'] })['item']
            userInsight['username'] = user['username']
    return _mongo_db_crud.Save('userInsight', userInsight)

def SetActionAt(userId: str, field: str, now = None):
    now = now if now is not None else date_time.now()
    ret = { "valid": 1, "message": "" }
    item = mongo_db.find_one('userInsight', { 'userId': userId })['item']
    if item is None:
        Save({ 'userId': userId })
    query = { 'userId': userId }
    mutation = { '$set': {} }
    mutation['$set'][field] = date_time.string(now)
    retOne = mongo_db.update_one('userInsight', query, mutation, validate = 0)
    if retOne['modified_count'] < 1:
        ret['valid'] = 0
    else:
        # Clear out follow ups.
        if field == 'ambassadorSignUpStepsAt.resources':
            userInsight = mongo_db.find_one('userInsight', { 'userId': userId })['item']
            _user_follow_up.RemoveFollowUps(userInsight['username'], 'ambassadorSignUp')

    return ret

def GetAmbassadorInsights(now = None, withUsers: int = 1, activeDaysPast: int = 4):
    now = now if now is not None else date_time.now()
    ret = { 'valid': 1, 'message': '', 'ambassadorsSignUpCompleteUsernames': [], 'userInsights': [],
        'onTrackAmbassadorUsernames': [], 'userNeighborhoodWeeklyUpdatesBehindByUser': {},
        'userNeighborhoodsNotStarted': [], }
    lastMonth = date_time.string(now - datetime.timedelta(days = 30))
    fields = { 'userId': 1, 'ambassadorSignUpStepsAt': 1, 'username': 1 }
    # First see who has completed all of the ambassador sign up steps.
    query = { 'ambassadorSignUpStepsAt.userNeighborhoodSave': { '$gte': lastMonth },
        'ambassadorSignUpStepsAt.resources': { '$exists': 1 } }
    userInsights = mongo_db.find('userInsight', query, fields = fields)['items']
    userIds = []
    for userInsight in userInsights:
        ret['ambassadorsSignUpCompleteUsernames'].append(userInsight['username'])
        userIds.append(userInsight['userId'])
    query = { 'ambassadorSignUpStepsAt.userNeighborhoodSave': { '$gte': lastMonth }, 'userId': { '$nin': userIds } }
    ret['userInsights'] = mongo_db.find('userInsight', query, fields = fields)['items']
    if withUsers > 0:
        userObjectIds = []
        userIdMap = {}
        for index, userInsight in enumerate(ret['userInsights']):
            userObjectIds.append(mongo_db.to_object_id(userInsight['userId']))
            userIdMap[userInsight['userId']] = index
        query = { '_id': { '$in': userObjectIds } }
        fields = { 'firstName': 1, 'lastName': 1, 'username': 1, 'email': 1 }
        users = mongo_db.find('user', query, fields = fields)['items']
        for user in users:
            ret['userInsights'][userIdMap[user['_id']]]['user'] = user

    # See which ambassadors who have been active this month, are up to date
    lastWeek = date_time.string(now - datetime.timedelta(days = activeDaysPast))
    # Start with users who have made an update in the past week.
    query = { 'end': { '$gte': lastWeek }, 'inviteCount': { '$gt': 0 } }
    # query = { 'end': { '$gte': lastWeek }, 'actionsComplete.6': { '$exists': 1 } }
    userNeighborhoodWeeklyUpdates = mongo_db.find('userNeighborhoodWeeklyUpdate', query)['items']
    userIdsDone = []
    for userNeighborhoodWeeklyUpdate in userNeighborhoodWeeklyUpdates:
        if userNeighborhoodWeeklyUpdate['userId'] not in userIdsDone:
            userIdsDone.append(userNeighborhoodWeeklyUpdate['userId'])
            ret['onTrackAmbassadorUsernames'].append(userNeighborhoodWeeklyUpdate['username'])

    # Find the rest who have been active this month but not this week.
    query = { 'start': { '$gte': lastMonth }, 'userId': { '$nin': userIdsDone } }
    userNeighborhoodWeeklyUpdates = mongo_db.find('userNeighborhoodWeeklyUpdate', query, sort_obj = { 'start': -1 })['items']
    # Group by user.
    for userNeighborhoodWeeklyUpdate in userNeighborhoodWeeklyUpdates:
        username = userNeighborhoodWeeklyUpdate['username']
        if username not in ret['userNeighborhoodWeeklyUpdatesBehindByUser']:
            ret['userNeighborhoodWeeklyUpdatesBehindByUser'][username] = []
            userIdsDone.append(userNeighborhoodWeeklyUpdate['userId'])
        ret['userNeighborhoodWeeklyUpdatesBehindByUser'][username].append(userNeighborhoodWeeklyUpdate)

    # Find all ambassadors, not started at all.
    query = { 'userId': { '$nin': userIdsDone }, 'roles': 'ambassador' }
    ret['userNeighborhoodsNotStarted'] = mongo_db.find('userNeighborhood', query)['items']

    return ret

def UnsetAmbassadorSignUpSteps(username: str):
    ret = { "valid": 1, "message": "" }
    query = { 'username': username }
    mutation = { '$unset': { 'ambassadorSignUpStepsAt': 1 } }
    mongo_db.update_one('userInsight', query, mutation)
    return ret
