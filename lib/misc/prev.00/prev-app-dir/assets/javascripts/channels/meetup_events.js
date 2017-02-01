
//= require ../controllers
//= require ../helpers/cookies
//= require ../helpers/error

// App.meetup_events = App.cable.subscriptions.create({
//   channel: 'MeetupEventsChannel', room: 'fkme',
// }, {
//   received: function (params) {
//     console.log('DEBUG, channels/meetup_events...');
//     console.log(params);
//     console.log(document.cookie);

//     // initMeetupEvent(params);
//   },
// });

App.meetup_events = App.cable.subscriptions.create(
  'MeetupEventsChannel', {
  received: function (params) {
    if (params.errors) {
      Error.show(params.errors);
    } else {
      Cookies.setMeetupEventIDs(params);

      console.log('DEBUG, in channels/meetup_events...');
      console.log(params);
      console.log(document.cookie);

      initMeetupEvents(params);
    }
  },
});
