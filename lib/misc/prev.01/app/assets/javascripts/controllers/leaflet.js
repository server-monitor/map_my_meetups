
//= require leaflet

function formatInfoWindowLeaflet(muEvent, marker) {
  let infoBoxClass = 'dummy';
  return `
    <div class="${infoBoxClass}">
      <a href="${muEvent.link}">${muEvent.name}</a><br>
      ${muEvent.venue.name}<br>
      ${marker.address}<br>
      ${marker.city}, ${marker.state}
    </div>
  `;
}

function initLeaflet(params) {
  let meetupEvents = params.meetupEvents;

  let mapAreaId = params.mapAreaId || 'map';
  let railsEnv = params.railsEnv;

  let map = L.map('map');

  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
  }).addTo(map);

  let bounds = [];
  let listLength = meetupEvents.length;

  let markers = [];

  for (let i = 0; i < listLength; i++) {
    let meetupEvent = meetupEvents[i];
    let markerInput = meetupEvent.venue;

    let latLong = L.latLng(markerInput.latitude, markerInput.longitude);
    bounds.push(latLong);

    let iconProp = {
      iconUrl: 'https://a248.e.akamai.net/' +
        'secure.meetupstatic.com/s/img/94156887029318281691566697/logo.svg',
    };

    if (i === (listLength - 1)) {
      iconProp.className = 'animated_marker';
    }

    let marker = L.marker([markerInput.latitude, markerInput.longitude], {
      icon: L.icon(iconProp), riseOnHover: true,
    }).addTo(map)
      .bindPopup(formatInfoWindowLeaflet(meetupEvent, markerInput));

    markers.push(marker);
  }

  if (bounds.length === 0) {
    // https://stackoverflow.com/questions/12735303/how-to-change-the-map-center-in-leaflet
    // Downtown LA
    map.setView(new L.LatLng(34.0522300, -118.2436800), 12);
  } else {
    map.fitBounds(L.latLngBounds(bounds));
  }
}

Paloma.controller('MeetupEvents', {
  leaflet: function () {
    initLeaflet(this.params);
  },
});
