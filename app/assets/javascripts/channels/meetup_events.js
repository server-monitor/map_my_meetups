
//= require ../controllers

App.meetup_events = App.cable.subscriptions.create(
  'MeetupEventsChannel', {
  received: function (params) {
    if (params.errors) {
      console.log('ERRORS!!!!');
      console.log(params.errors);
      console.log('END ERRORS');
    } else {
      console.log('DEBUG, in channels/meetup_events...');
      console.log(params);
      console.log(document.cookie);

      if (params.referrer === 'leaflet') {
        M3ULeaflet.load(params);
      } else {
        M3UGMap.load(params);
      }
    }
  },
});
