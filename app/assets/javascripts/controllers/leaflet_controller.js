
//= require leaflet

//= require './m_3_u_infobox'

var M3ULeaflet = {
  load: function (params) {
    let map = this.initMap(params.mapAreaId);
    let bounds = this.loadMarkers(map, params.meetupEvents, params.railsEnv);
    this.showMap(map, bounds);
  },

  initMap: function (mapAreaId) {
    mapAreaId = mapAreaId || 'map';

    let upper = $(`#${mapAreaId}`).parent();
    $(`#${mapAreaId}`).remove();
    upper.append(`<div id="${mapAreaId}"></div>`);

    let map = L.map(mapAreaId);

    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);

    return map;
  },

  loadMarkers: function (map, meetupEvents, railsEnv) {
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
        .bindPopup(M3UInfobox.format(meetupEvent.events, markerInput));

      markers.push(marker);
    }

    return bounds;
  },

  showMap: function (map, bounds) {
    if (bounds.length === 0) {
      // https://stackoverflow.com/questions/12735303/how-to-change-the-map-center-in-leaflet
      // Downtown LA
      map.setView(new L.LatLng(34.0522300, -118.2436800), 12);
    } else {
      map.fitBounds(L.latLngBounds(bounds));
    }
  },
};

Paloma.controller('MeetupEvents', {
  leaflet: function () {
    M3ULeaflet.load(this.params);
  },
});
