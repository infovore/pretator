
 //Place all the behaviors and hooks related to the matching controller here.
 //All this logic will automatically be available in application.js.

$(document).ready(function(){
  var fullWidth = $(".container").width();
  $("#pret_map").css("width", fullWidth+"px");
  $("#pret_map").css("height", '300px');

  window.pret_map = L.map('pret_map', {minZoom: 3}).setView([51.5075256, -0.127949565075256], 11);
  window.pret_map.attributionControl.setPrefix(false);

  var mapquestUrl = 'http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png',
      subDomains = ['otile1','otile2','otile3','otile4'],
      mapquestAttrib = 'Data, imagery and map information provided by <a href="http://open.mapquest.co.uk" target="_blank">MapQuest</a>, <a href="http://www.openstreetmap.org/" target="_blank">OpenStreetMap</a> and contributors.'

  var mapquest = new L.TileLayer(mapquestUrl, {maxZoom: 14, attribution: mapquestAttrib, subdomains: subDomains});

  mapquest.addTo(window.pret_map)

  doMapMarkers();

  setInterval(doMapMarkers,60*1000);
});


function doMapMarkers() {
  console.log('getting map markers');

  $.get('/prets.json', function(data){
    window.newMarkers = L.geoJson(data, {
      pointToLayer: function(feature,latlng) {
        var m = L.marker(latlng);
        // force cursors for IE8
        m.on("mouseover", function(e) {
          $("body").css("cursor", "pointer");
        });
        m.on("mouseout", function(e) {
          $("body").css("cursor", "default");
        });
        return m
      },
      onEachFeature: function(feature,layer) {
        if (feature.properties && feature.properties.name) {
          bindPopupOfFeatureToLayer(feature,layer);
          }
        }
    });
    
    if(window.markers) {
      window.pret_map.removeLayer(window.markers);
    }

    window.newMarkers.addTo(window.pret_map);

    window.markers = window.newMarkers;

    window.pret_map.fitBounds(window.markers.getBounds());
  });

}

function bindPopupOfFeatureToLayer(feature,layer) {
  var name = feature.properties.name;

  var description = feature.properties.description || "";
  var submitted_by = feature.properties.submitted_by || "";

  layer.bindPopup('<h4 style="margin: 0 0 10px;font-size: 120%">'+ name +'</h4><dl><dt>Name</dt><dd>' + feature.properties.name + '</dd><dt>Address</dt><dd>' + feature.properties.address + '</dd><dt>Directions</dt><dd>' + feature.properties.directions + '</dd></dl>');
}


