
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

var M3UInfobox = {
  format: function (events, marker) {
    let infoBoxClass = 'infobox';

    let titles = events.map(function (event, ix) {
      let num = '';
      if (events.length > 1) {
        num = ix + 1 + '. ';
      }

      let date = new Date();
      date.setTime(event.time);
      return `<p><a href="${event.link}" target="_blank">${event.name}</a><br>${date}<br></p>`;
    }).join('');

    return `
      <div class="${infoBoxClass}">
        ${titles}
        ${marker.name}<br>
        ${marker.address}<br>
        ${marker.city}, ${marker.state}
      </div>
    `;
  },
};
