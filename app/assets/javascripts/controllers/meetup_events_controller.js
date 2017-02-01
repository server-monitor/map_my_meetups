
//= require lodash
//= require gmap_deps

//= require './m_3_u_infobox'

var M3UGMap = {
  load: function (params) {
    let map = this.initMap(params.mapAreaId);
    let info = this.loadMarkers(map, params.meetupEvents, params.railsEnv);
    this.showMap(map, info.markers, info.bounds);
  },

  initMap: function (mapAreaId) {
    mapAreaId = mapAreaId || 'map';
    return new google.maps.Map(document.getElementById(mapAreaId));
  },

  loadMarkers: function (map, meetupEvents, railsEnv) {
    // ...
    // "Global" infowindow variable. Only one info box visible at a time.
    // Must remove per marker infowindow variable at the bottom if this is active.
    let infowindow = new google.maps.InfoWindow();

    let bounds = new google.maps.LatLngBounds();
    let markers = [];

    let adjVenueCoords = this.adjustVenueCoordsForClustering(meetupEvents);

    let listLength = adjVenueCoords.length;
    for (let i = 0; i < listLength; i++) {
      let meetupEvent = adjVenueCoords[i];

      let markerInput = meetupEvent.venue;
      if (i === (listLength - 1)) markerInput.last = true;

      let marker = this.createMarker(
        map, markerInput, meetupEvent.events, railsEnv, bounds, infowindow
      );

      markers.push(marker);
    }

    return { markers: markers, bounds: bounds };
  },

  adjustVenueCoordsForClustering: function (meetupEvents) {
    let sameCoords = meetupEvents.reduce(function (memo, eventDataGroup) {
      let venue = eventDataGroup.venue;
      let key = venue.latitude.toString() + ':' + venue.longitude.toString();
      let muEvents = memo[key] || [];
      memo[key] = muEvents.concat(eventDataGroup);
      return memo;
    }, {});

    return $.map(sameCoords, (function (eventDataGroups) {
      if (eventDataGroups.length > 1) {
        for (let ix = 1; ix < eventDataGroups.length; ix++) {
          let venue = eventDataGroups[ix].venue;

          // * (Math.random() * (max - min) + min);
          // ... roughly based on https://stackoverflow.com/questions/20490654/more-than-one-marker-on-same-place-markerclusterer
          //     Adjust the divisor to adjust the distance (smaller divisor => bigger distance).
          let newLat = parseFloat(venue.latitude) + (Math.random() - 0.5) / 10000;
          let newLng = parseFloat(venue.longitude) + (Math.random() - 0.5) / 10000;
          eventDataGroups[ix].venue.latitude = newLat;
          eventDataGroups[ix].venue.longitude = newLng;
        }

        return eventDataGroups;
      } else return eventDataGroups;
    }));
  },

  createMarker: function (
    map, markerInput, events, railsEnv, bounds, infowindow
  ) {
    let markerInfo = {
      title: (events.length > 1 ? 'Multiple events' : events[0].name),
      position: {
        lat: parseFloat(markerInput.latitude),
        lng: parseFloat(markerInput.longitude),
      },
      icon: 'https://a248.e.akamai.net/' +
        'secure.meetupstatic.com/s/img/94156887029318281691566697/logo.svg',
      map: map,
    };

    if (markerInput.last) markerInfo.animation = google.maps.Animation.BOUNCE;

    if (railsEnv === 'test') markerInfo.optimized = false;

    let marker = new google.maps.Marker(markerInfo);

    this.attachInfoWindow(
      map, marker, infowindow, M3UInfobox.format(events, markerInput)
    );

    // For the per marker info window setting.
    // attachInfoWindow(
    //   map, marker, M3UInfobox.format(events, markerInput)
    // );

    bounds.extend(marker.getPosition());

    return marker;
  },

  attachInfoWindow: function (map, marker, infowindow, info) {
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

  },

  showMap: function (map, markers, bounds) {
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
  },
};

Paloma.controller('MeetupEvents', {
  map: function () {
    M3UGMap.load(this.params);
  },
});
