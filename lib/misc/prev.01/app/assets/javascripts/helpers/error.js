
var Error = {
  show: function (errors) {
    console.log('ERRORS');
    $('.col-sm-12').prepend(
      '<div class="alert fade in alert-danger">' +
      errors +
      '</div>'
    );
  },
};
