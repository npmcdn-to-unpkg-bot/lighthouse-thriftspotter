// This example requires the Places library. Include the libraries=places
// parameter when you first load the API. For example:
// <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places">
var map;
var infowindow;
var pos;

function initMap() {
  if (navigator.geolocation) { //GEO LOCATION, FINDS USERS LOCATION
      navigator.geolocation.getCurrentPosition(function(position) {

        map = new google.maps.Map(document.getElementById('map'), {
          center: myLocation,
          zoom: 13
        });

        items = document.getElementsByClassName('item');

        for (var i=0, item; item = items[i]; i++) {
          if (typeof item.dataset.placeid !== 'undefined'){
            pos = {
              lat: Number(item.dataset.lat),
              lng: Number(item.dataset.long)
            }


            var marker = new google.maps.Marker({
              position: pos,
              map: map,
              icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + item.dataset.index +'|FF0000|000000' 
            });
          }
        }

        var input = /** @type {!HTMLInputElement} */(
                   document.getElementById('pac-input'));


        map.setCenter(pos);
        var myLocation = pos; //Sets variable to geo location long and lat co-ordinates.
        var types = document.getElementById('type-selector');
        map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);
        map.controls[google.maps.ControlPosition.TOP_LEFT].push(types);

        var autocomplete = new google.maps.places.Autocomplete(input);
        autocomplete.bindTo('bounds', map);

        var infowindow = new google.maps.InfoWindow();
        var marker = new google.maps.Marker({
          map: map,
          anchorPoint: new google.maps.Point(0, -29)
        });

        autocomplete.addListener('place_changed', function() {
          infowindow.close();
          marker.setVisible(false);
          var place = autocomplete.getPlace();
          if (!place.geometry) {
            window.alert("Autocomplete's returned place contains no geometry");
            return;
          }
        });

      })
    };

}
