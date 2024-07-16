import datetime

import date_time
import lodash
import mongo_db

def RunAll():
    AddUsernames()
    # AddWeeklyEventUName()
    # UserInsightAmbassadorSignUpStepsAt()
    # UserNeighborhoodVision()
    # UserNeighborhoodToUName()
    # UserNeighborhoodRoles()
    # WeeklyEventLocationAddress()
    # EventFeedbackImageUrls()
    # FeedbackStarsAttended()
    # EventViewsAt()
    # AddTimezoneToNeighborhood()
    # PayQuantityAndStripeIds()
    # AddPositiveVotes()
    # AddNeighborhoodUName()
    # WeeklyEventArchived()
    # TimesToUTC()
    # AddEventEnd()
    # AddUserEventEnd()
    # SharedItemMaxMeters()
    # SharedItemUName()
    # ImportCertificationLevels()
    pass

def AddUsernames():
    collections = ['userNeighborhood', 'userNeighborhoodWeeklyUpdate', 'userInsight', 'userFeedback', 'userEvent']
    for collection in collections:
        limit = 250
        skip = 0
        updatedCounter = 0
        while True:
            query = {'username': { '$exists': 0 } }
            fields = { '_id': 1, 'userId': 1 }
            items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
            skip += len(items)

            print ('AddUsernames', collection, len(items))
            for item in items:
                fields = { 'username': 1 }
                user = mongo_db.find_one('user', {'_id': item['userId']}, fields = fields)['item']
                if user is not None:
                    query = {
                        '_id': mongo_db.to_object_id(item['_id'])
                    }
                    mutation = {
                        '$set': {
                            'username': user['username'],
                        },
                    }

                    # print (query, mutation)
                    mongo_db.update_one(collection, query, mutation)
                    updatedCounter += 1
                else:
                    print('User not found: ' + item['userId'])

            if len(items) < limit:
                print('Updated ' + str(updatedCounter) + ' items')
                break

def AddWeeklyEventUName():
    collections = ['event', 'userWeeklyEvent', 'userEvent']
    for collection in collections:
        limit = 250
        skip = 0
        updatedCounter = 0
        while True:
            query = {'weeklyEventUName': { '$exists': 0 } }
            fields = {}
            items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
            skip += len(items)

            print ('AddWeeklyEventUName', collection, len(items))
            for item in items:
                weeklyEvent = None
                if collection == 'event' and len(item['weeklyEventId']) > 0:
                    weeklyEvent = mongo_db.find_one('weeklyEvent', {'_id': mongo_db.to_object_id(item['weeklyEventId'])})['item']
                elif collection == 'userWeeklyEvent':
                    weeklyEvent = mongo_db.find_one('weeklyEvent', {'_id': mongo_db.to_object_id(item['weeklyEventId'])})['item']
                elif collection == 'userEvent':
                    event = mongo_db.find_one('event', {'_id': mongo_db.to_object_id(item['eventId'])})['item']
                    if event is not None and len(event['weeklyEventId']) > 0:
                        weeklyEvent = mongo_db.find_one('weeklyEvent', {'_id': mongo_db.to_object_id(event['weeklyEventId'])})['item']
                if weeklyEvent is not None:
                    query = {
                        '_id': mongo_db.to_object_id(item['_id'])
                    }
                    mutation = {
                        '$set': {
                            'weeklyEventUName': weeklyEvent['uName'],
                        }
                    }

                    # print (collection, query, mutation)
                    mongo_db.update_one(collection, query, mutation)
                    updatedCounter += 1
                else:
                    print ('WeeklyEvent not found', collection, item['_id'])

            if len(items) < limit:
                print('Updated ' + str(updatedCounter) + ' items')
                break

def UserInsightAmbassadorSignUpStepsAt():
    collection = 'userInsight'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'ambassadorSignUpStepsAt': { '$exists': 0 } }
        fields = { '_id': 1, }
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('UserInsightAmbassadorSignUpStepsAt', collection, len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'ambassadorSignUpStepsAt': {},
                },
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def UserNeighborhoodVision():
    collection = 'userNeighborhood'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'vision': { '$exists': 0 } }
        fields = { '_id': 1, }
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('userNeighborhoodVision', collection, len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'vision': '',
                    'motivations': [],
                },
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def UserNeighborhoodToUName():
    collection = 'userNeighborhood'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'neighborhoodUName': { '$exists': 0 } }
        fields = { '_id': 1, 'neighborhoodId': 1, }
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('userNeighborhoodToUName', collection, len(items))
        for item in items:
            fields = { 'uName': 1, }
            print ('item', item)
            neighborhood = mongo_db.find_one('neighborhood', { '_id': mongo_db.to_object_id(item['neighborhoodId']) }, fields = fields)['item']
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'neighborhoodUName': neighborhood['uName'],
                },
                '$unset': { 'neighborhoodId': 1 },
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def UserNeighborhoodRoles():
    collection = 'userNeighborhood'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'roles': { '$exists': 0 } }
        fields = { '_id': 1, }
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('userNeighborhoodRoles', collection, len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'roles': ['creator', 'ambassador'],
                }
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def WeeklyEventLocationAddress():
    collection = 'weeklyEvent'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'locationAddress': { '$exists': 0 } }
        fields = { '_id': 1, }
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('WeeklyEventLocationAddress', collection, len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'locationAddress': {},
                }
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def EventFeedbackImageUrls():
    collection = 'eventFeedback'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'imageUrls': { '$exists': 0 } }
        fields = { '_id': 1, }
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('EventFeedbackImageUrls', collection, len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'imageUrls': [],
                }
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def FeedbackStarsAttended():
    collection = 'userFeedback'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'stars': { '$exists': 0 } }
        fields = { '_id': 1, }
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('FeedbackStarsAttended', collection, len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'stars': 5,
                    'attended': 'yes',
                }
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def EventViewsAt():
    collection = 'eventInsight'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'viewsAt': { '$exists': 1 } }
        fields = { '_id': 1, 'viewsAt': 1,}
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('EventViewsAt', collection, len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$unset': {
                    'viewsAt': '',
                },
                '$set': {
                    'uniqueViewsAt': {},
                }
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def AddTimezoneToNeighborhood():
    collection = 'neighborhood'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'timezone': { '$exists': 0 } }
        fields = { '_id': 1, 'location': 1,}
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('AddTimezoneToNeighborhood', collection, len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'timezone': date_time.GetTimezoneFromLngLat(item['location']['coordinates']),
                }
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def PayQuantityAndStripeIds():
    collections = ['userPayment', 'userPaymentSubscription']
    for collection in collections:
        limit = 250
        skip = 0
        updatedCounter = 0
        while True:
            query = {'quantity': { '$exists': 0 } }
            fields = {}
            items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
            skip += len(items)

            print ('PayQuantityAndStripeIds', collection, len(items))
            for item in items:
                query = {
                    '_id': mongo_db.to_object_id(item['_id'])
                }
                mutation = {
                    '$set': {
                        'quantity': 1,
                    }
                }
                if collection == 'userPaymentSubscription':
                    mutation['$unset'] = {'stripeId': ''}
                    mutation['$set']['stripeIds'] = { 'checkoutSession': item['stripeId'] }
                    mutation['$set']['credits'] = 0

                # print (collection, query, mutation)
                mongo_db.update_one(collection, query, mutation)
                updatedCounter += 1

            if len(items) < limit:
                print('Updated ' + str(updatedCounter) + ' items')
                break

def AddPositiveVotes():
    collection = 'eventFeedback'
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'positiveVotes': { '$exists': 0 } }
        fields = { '_id': 1,}
        items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('AddPositiveVotes', collection, len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'positiveVotes': [],
                }
            }

            # print (query, mutation)
            mongo_db.update_one(collection, query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def AddNeighborhoodUName():
    collections = ['weeklyEvent', 'event', 'sharedItem']
    for collection in collections:
        limit = 250
        skip = 0
        updatedCounter = 0
        while True:
            query = {'neighborhoodUName': { '$exists': 0 } }
            fields = { '_id': 1, 'uName': 1,}
            items = mongo_db.find(collection, query, limit=limit, skip=skip, fields = fields)['items']
            skip += len(items)

            print ('AddNeighborhoodUName', collection, len(items))
            for item in items:
                neighborhoodUName = 'southsidefw' if 'uName' in item and item['uName'] == 'fma4t' else 'concordpc'
                query = {
                    '_id': mongo_db.to_object_id(item['_id'])
                }
                mutation = {
                    '$set': {
                        'neighborhoodUName': neighborhoodUName,
                    }
                }

                # print (query, mutation)
                mongo_db.update_one(collection, query, mutation)
                updatedCounter += 1

            if len(items) < limit:
                print('Updated ' + str(updatedCounter) + ' items')
                break

def WeeklyEventArchived():
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {'archived': { '$exists': 0 }}
        fields = { 'archived': 1,}
        items = mongo_db.find('weeklyEvent', query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('WeeklyEventArchived weeklyEvent', len(items))
        for item in items:
            query = {
                '_id': mongo_db.to_object_id(item['_id'])
            }
            mutation = {
                '$set': {
                    'archived': 0,
                }
            }

            # print (query, mutation)
            mongo_db.update_one('weeklyEvent', query, mutation)
            updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def TimesToUTC():
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = {}
        fields = { 'start': 1, 'end': 1,}
        items = mongo_db.find('event', query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('TimesToUTC event', len(items))
        for item in items:
            startUTC = date_time.string(date_time.toUTC(date_time.from_string(item['start'])))
            endUTC = date_time.string(date_time.toUTC(date_time.from_string(item['end'])))
            if startUTC != item['start'] or endUTC != item['end']:
                query = {
                    '_id': mongo_db.to_object_id(item['_id'])
                }
                mutation = {
                    '$set': {
                        'start': startUTC,
                        'end': endUTC,
                    }
                }

                # print (query, mutation, item['start'], item['end'])
                mongo_db.update_one('event', query, mutation)
                updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break
    
    skip = 0
    updatedCounter = 0
    while True:
        query = {}
        fields = { 'eventEnd': 1,}
        items = mongo_db.find('userEvent', query, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('TimesToUTC userEvent', len(items))
        for item in items:
            endUTC = date_time.string(date_time.toUTC(date_time.from_string(item['eventEnd'])))
            if endUTC != item['eventEnd']:
                query = {
                    '_id': mongo_db.to_object_id(item['_id'])
                }
                mutation = {
                    '$set': {
                        'eventEnd': endUTC,
                    }
                }

                # print (query, mutation, item['start'], item['end'])
                mongo_db.update_one('userEvent', query, mutation)
                updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def AddEventEnd():
    limit = 250
    skip = 0
    updatedCounter = 0
    while True:
        query = { 'end': { '$exists': 0 } }
        items = mongo_db.find('event', query, limit=limit, skip=skip)['items']
        skip += len(items)

        print ('AddEventEnd', len(items))
        for item in items:
            if len(item['weeklyEventId']) > 0:
                weeklyEvent = mongo_db.find_one('weeklyEvent', {'_id': mongo_db.to_object_id(item['weeklyEventId'])})['item']
                if weeklyEvent is not None:
                    hour = int(weeklyEvent['startTime'][0:2])
                    minute = int(weeklyEvent['startTime'][3:5])
                    hourEnd = int(weeklyEvent['endTime'][0:2])
                    minuteEnd = int(weeklyEvent['endTime'][3:5])
                    durationHours = hourEnd - hour
                    if durationHours < 0:
                        durationHours += 24
                    durationMinutes = minuteEnd - minute
                    duration = durationHours * 60 + durationMinutes
                    end = date_time.from_string(item['start']) + datetime.timedelta(minutes = duration)
                    end = date_time.string(end)

                    query = {
                        '_id': mongo_db.to_object_id(item['_id'])
                    }
                    mutation = {
                        '$set': {
                            'end': end,
                        }
                    }

                    # print (query, mutation, item['start'])
                    mongo_db.update_one('event', query, mutation)
                    updatedCounter += 1
                else:
                    print ('No weeklyEvent', item)
                    query = {
                        '_id': mongo_db.to_object_id(item['_id'])
                    }
                    mongo_db.delete_one('event', query)
            else:
                print ('No weeklyEventId', item)

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def AddUserEventEnd():
    limit = 250
    skip = 0
    updatedCounter = 0

    while True:
        query = { '$or': [ { 'eventEnd': { '$exists': 0 } }, { 'eventEnd': '' } ] }
        items = mongo_db.find('userEvent', query, limit=limit, skip=skip)['items']
        skip += len(items)

        print ('AddUserEventEnd', len(items))
        for item in items:
            event = mongo_db.find_one('event', {'_id': mongo_db.to_object_id(item['eventId'])})['item']
            if event is not None and 'end' in event:
                query = {
                    '_id': mongo_db.to_object_id(item['_id'])
                }
                mutation = {
                    '$set': {
                        'eventEnd': event['end'],
                    }
                }
                # print (query, mutation)
                mongo_db.update_one('userEvent', query, mutation)
                updatedCounter += 1
            else:
                print ('No event, or no end', item['eventId'], 'event', event)
                query = {
                    '_id': mongo_db.to_object_id(item['_id'])
                }
                mongo_db.delete_one('userEvent', query)

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def SharedItemMaxMeters():
    limit = 250
    skip = 0
    updatedCounter = 0

    while True:
        items = mongo_db.find('sharedItem', {}, limit=limit, skip=skip)['items']
        skip += len(items)

        print ('SharedItemMaxMeters', len(items))
        for item in items:
            if 'maxMeters' not in item:
                item['maxMeters'] = 1500
                query = {
                    '_id': mongo_db.to_object_id(item['_id'])
                }
                mutation = {
                    '$set': {
                        'maxMeters': item['maxMeters'],
                    }
                }

                # print (query, mutation)
                mongo_db.update_one('sharedItem', query, mutation)
                updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

def SharedItemUName():
    limit = 250
    skip = 0
    updatedCounter = 0

    while True:
        fields = { '_id': 1, 'title': 1, 'uName': 1, }
        items = mongo_db.find('sharedItem', {}, limit=limit, skip=skip, fields = fields)['items']
        skip += len(items)

        print ('SharedItemUName', len(items))
        for item in items:
            if 'uName' not in item:
                item['uName'] = lodash.CreateUName(item['title'])
                query = {
                    '_id': mongo_db.to_object_id(item['_id'])
                }
                mutation = {
                    '$set': {
                        'uName': item['uName'],
                    }
                }

                # print (query, mutation)
                mongo_db.update_one('sharedItem', query, mutation)
                updatedCounter += 1

        if len(items) < limit:
            print('Updated ' + str(updatedCounter) + ' items')
            break

# def ImportCertificationLevels():
#     from neighborhood import certification_level_import as _certification_level_import
#     items = mongo_db.find('certificationLevel', {})['items']
#     if len(items) == 0:
#         _certification_level_import.ImportToDB()
#         print ('Imported certificationLevels')
