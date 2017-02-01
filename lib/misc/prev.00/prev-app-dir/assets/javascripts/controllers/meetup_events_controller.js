
//= require lodash
//= require gmap_deps

function formatInfoWindowFixMe(muEvent, marker) {
  let infoBoxClass = 'dummy';
  return `
    <div class="${infoBoxClass}">
      <a href="${muEvent.link}">${muEvent.name}</a><br>
      ${muEvent.venue_name}<br>
      ${marker.address}<br>
      ${marker.city}, ${marker.state}
    </div>
  `;
}

// InfoBox, 2 choices:
// 1. Make only one info box visible at a time (close the open
//      info box when you open another one).
//    This can be done by setting a "global" info box variable.
//    https://stackoverflow.com/questions/1875596/have-just-one-infowindow-open-in-google-maps-api-v3
//    https://stackoverflow.com/questions/24951991/open-only-one-infowindow-at-a-time-google-maps

// 2. Make multiple info boxes visible.
//      Create one info box variable per marker
// Important thing to keep in mind is to "attach" the info box info
//   in a callback instead of setting it inside the main loop.

function initMeetupEvents(params) {
  let meetupEvents = params.meetupEvents;

  let mapAreaId = params.mapAreaId || 'map';
  let railsEnv = params.railsEnv;

  let map = new google.maps.Map(document.getElementById(mapAreaId));

  // "Global" infowindow variable. Only one info box visible at a time.
  // Must remove per marker infowindow variable at the bottom if this is active.
  let infowindow = new google.maps.InfoWindow();

  // ...
  let bounds = new google.maps.LatLngBounds();
  let markers = [];

  let listLength = meetupEvents.length;
  for (let i = 0; i < listLength; i++) {
    let meetupEvent = meetupEvents[i];
    let markerInput = meetupEvent.venue;

    let markerInfo = {
      title: meetupEvent.name,
      position: {
        lat: parseFloat(markerInput.latitude),
        lng: parseFloat(markerInput.longitude),
      },
      icon: 'https://a248.e.akamai.net/' +
        'secure.meetupstatic.com/s/img/94156887029318281691566697/logo.svg',
      map: map,
    };

    if (i === (listLength - 1)) {
      markerInfo.animation = google.maps.Animation.BOUNCE;
    }

    if (railsEnv === 'test') {
      markerInfo.optimized = false;
    }

    let marker = new google.maps.Marker(markerInfo);

    markers.push(marker);

    attachInfoWindowFixMe(
      map, marker, infowindow, formatInfoWindowFixMe(meetupEvent, markerInput)
    );

    // For the per marker info window setting.
    // attachInfoWindowFixMe(
    //   map, marker, formatInfoWindowFixMe(meetupEvent, markerInput)
    // );

    bounds.extend(marker.getPosition());
  }

  // https://stackoverflow.com/questions/11454229/how-to-set-zoom-level-in-google-map
  if (markers.length === 0) {
    // Downtown LA
    map.setCenter({ lat: 34.0522300, lng: -118.2436800 });
    map.setZoom(12);
  } else if (markers.length === 1) {
    map.setCenter(markers[0].position);
    map.setZoom(16);

    // gridSize = 30;
  } else {
    map.fitBounds(bounds);
  }

  let mcOptions = {
    // maxZoom: 3,
    gridSize: 10, // 40 ..., // 60 default obtained from *.getGridSize()
  };

  let markerCluster = new MarkerClusterer(map, markers, mcOptions);
}

function attachInfoWindowFixMe(map, marker, infowindow, info) {
  // Allow multiple info boxes open at a time. The per marker infowindow variable.
  // Must remove "global" infowindow variable at the top if you should desire this behavior.
  // let infowindow = new google.maps.InfoWindow();

  google.maps.event.addListener(marker, 'click', function () {
    infowindow.setContent(info);
    infowindow.open(map, marker);
  });

  google.maps.event.addListener(map, 'click', function () {
    infowindow.close();
  });

  // google.maps.event.addListener(marker, 'mouseover', function () {
  //   infowindow.setContent(info);
  //   infowindow.open(map, marker);
  // });

  // // ... we want to hide the infowindow when user mouses-out.
  // google.maps.event.addListener(marker, 'mouseout', function () {
  //   infowindow.close();
  // });
}

Paloma.controller('MeetupEvents', {
  map: function () {
    console.log('DEBUG, in controllers/meetup_events_controllers...');
    console.log(document.cookie);

    initMeetupEvents(this.params);
  },
});
