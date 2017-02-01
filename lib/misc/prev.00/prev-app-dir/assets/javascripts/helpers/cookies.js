
// Refactor TODO/DEBUG...
var Cookies = {
  setMeetupEventIDs: function (params) {
    let meetupEventIdsCookie = 'meetup_event_ids=' +
      encodeURIComponent(JSON.stringify(params.idsInCookieJar)) +
      ';'
    ;

    // https://developers.livechatinc.com/blog/setting-cookies-to-subdomains-in-javascript/
    let date = new Date();
    date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
    let expires = ' expires=' + date.toGMTString() + ';';

    let host = location.host;
    if (host.split('.').length === 1) {
      // // no "." in a domain - it's localhost or something similar
      document.cookie = meetupEventIdsCookie + expires + 'path=/; ';
    } else {
      // Remember the cookie on all subdomains.
      //
      // Start with trying to set cookie to the top domain.
      // (example: if user is on foo.com, try to set
      //  cookie to domain ".com")
      //
      // If the cookie will not be set, it means ".com"
      // is a top level domain and we need to
      // set the cookie to ".foo.com"
      let domainParts = host.split('.');
      domainParts.shift();
      domain = '.' + domainParts.join('.');

      document.cookie = meetupEventIdsCookie + expires + 'path=/; ' + `domain=${domain}; `;

      // document.cookie = name+"="+value+expires+"; path=/; domain="+domain;

      // I don't know.
      // // check if cookie was successfuly set to the given domain
      // // (otherwise it was a Top-Level Domain)
      // if (Cookie.get(name) == null || Cookie.get(name) != value)
      // {
      //   // append "." to current domain
      //   domain = '.' + host;
      //   document.cookie = name+"="+value+expires+"; path=/; domain="+domain;
      // }
    }
  },
};
