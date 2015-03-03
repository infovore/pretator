// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  $("html").on("touchmove", false);

  $("#deets").hide();

  $(".about-toggle").click(function() {
    $("#about").fadeToggle('fast');
    return false;
  });

  $(".details-link a").click(function() {
    $("#full-info").fadeToggle('fast');
    return false;
  });

  $(".close").click(function() {
    $("#about").fadeOut('fast');
    $("#full-info").fadeOut('fast');
    return false;
  });

  if(navigator.geolocation) {
    postLocation()

    setInterval(postLocation,1000);

    window.addEventListener('deviceorientation', function(e) {
      // get the arc value from north we computed and stored earlier
      if(e.webkitCompassHeading) {
        window.compassHeading = e.webkitCompassHeading + window.orientation;
        $('#rose').css('-webkit-transform','rotate(-' + window.compassHeading + 'deg)');		
        // get position and
        navigator.geolocation.getCurrentPosition(function(position) {
          updateCompass(position);
        });
      }
    });
  }
});

function postLocation() {
  navigator.geolocation.getCurrentPosition(function(position) {
    var postData;
    var params = urlParams();
    postData = {lat: position.coords.latitude,
                lon: position.coords.longitude}

    if('name' in params) {
      if(window.compassHeading) {
        postData.heading = window.compassHeading;
      }
      postData.name = params.name;
      console.log("I'd log my data for user " + params.name);
      console.log(postData);
    }

    $.post('/prets/nearest', postData, function(data) {
      console.log(data);
      window.pret = data;
      updateDisplay(data, position);
    });

  });
}

function updateDisplay(data, position) {
  // TODO: update
  $("#deets .inner .info").text(data.name);
  $("#deets").fadeIn();

  var fields = ['address', 'directions', 'seating'];

  $("#full-info h1").text(data.name);
  $("#full-info dl").html('');

  $.each(fields, function(i, field) {
    $("#full-info dl").append("<dt>" + field + "</dt><dd>" + data[field] + "</dd>");
  });

  var opening_hours = "";
  var days = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];

  $.each(days, function(i, day) {
    opening_hours = opening_hours + day + ": " + data.opening_hours[day] + "<br/>";
  });
  $("#full-info dl").append("<dt>Opening hours</dt><dd>" + opening_hours + "</dd>");

  updateCompass(data, position);
}

function updateCompass(data, position) {
  pointCompassAtPret(data, position);
}

function distanceStringFromKm(km) {
  var distanceInK = km.toFixed(3);
  var string = "";
  if(distanceInK >= 1) {
    string = distanceInK + "km";
  } else if(distanceInK >= 0.01) {
    distanceInM = distanceInK * 1000;
    string = distanceInM + "m";
  } else {
    string = "here!";
  }
  return string;
}

function distanceStringFromM(m) {
  var km = m / 1000;
  var distanceInK = km.toFixed(3);
  var string = "";
  if(distanceInK >= 1) {
    string = distanceInK + "km";
  } else if(distanceInK >= 0.01) {
    distanceInM = distanceInK * 1000;
    string = distanceInM + "m";
  } else {
    string = "here!";
  }
  return string;
}

function distanceBetween(lat1,lon1,lat2,lon2){
  var R = 6371; // km
  var dLat = (lat2-lat1) * Math.PI / 180;
  var dLon = (lon2-lon1) * Math.PI / 180;
  var lat1 = (lat1) * Math.PI / 180;
  var lat2 = (lat2) * Math.PI / 180;

  var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  var d = R * c;

  var y = Math.sin(dLon) * Math.cos(lat2);
  var x = Math.cos(lat1)*Math.sin(lat2) -
          Math.sin(lat1)*Math.cos(lat2)*Math.cos(dLon);
  var brng = Math.atan2(y, x).toDeg();

  return [d,brng]
}

function pointCompassAtPret(data, currentPos) {
  console.log("CurrentPos is " + currentPos);
  console.log("Data is " + data);
  //var distance = data.distance

  var distanceAndArc = distanceBetween(currentPos.coords.latitude, currentPos.coords.longitude, data.lat, data.lon);
  var distance = distanceAndArc[0];
  var arc = distanceAndArc[1];

  // work out heading
  $('#arrow').css('-webkit-transform','rotate(' + arc + 'deg)');		

  var distanceInM = distance * 1000;
  setArrowDistance(distanceInM);
  setDistanceDescription(distanceStringFromM(distanceInM));
}

/** Converts numeric degrees to radians */
if (typeof Number.prototype.toRad == 'undefined') {
  Number.prototype.toRad = function() {
    return this * Math.PI / 180;
  }
}

/** Converts radians to numeric (signed) degrees */
if (typeof Number.prototype.toDeg == 'undefined') {
  Number.prototype.toDeg = function() {
    return this * 180 / Math.PI;
  }
}

function urlParams() {
  var match,
      pl     = /\+/g,  // Regex for replacing addition symbol with a space
      search = /([^&=]+)=?([^&]*)/g,
      decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
      query  = window.location.search.substring(1);

    params = {};
    while (match = search.exec(query))
       params[decode(match[1])] = decode(match[2]);

    return params;
}

function setArrowDistance(distance) {
  if(distance <= 100) {
    $("#arrow").attr('class', '');
  } else if(distance <= 500) {
    $("#arrow").attr('class', 'middle');
  } else {
    $("#arrow").attr('class', 'far');
  }
}

function setDistanceDescription(distanceString) {
  if(window.pret) {
    $("#deets .inner h2").text(distanceString);
  }
}

