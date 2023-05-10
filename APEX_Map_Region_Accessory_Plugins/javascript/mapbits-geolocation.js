function mapbits_geolocation(p_item_id, p_ajax_identifier, p_region_id, p_options) {
  // Accomodate both Mapbox in APEX 21 and Maplibre in APEX 22.
  var maplib = typeof maplibregl === 'undefined' ? mapboxgl : maplibregl;	
  
  // raise a javascript alert with the input message and write to console.
  function apex_alert(msg) {
    apex.jQuery(function(){apex.message.alert(msg);console.log(msg);});
  }
  
  var geolocator = new maplib.GeolocateControl({
    positionOptions: {
      enableHighAccuracy: true
    },
    trackUserLocation: p_options.trackUserLocation,
    showUserHeading: p_options.showUserHeading
  });
  
  var region = apex.region(p_region_id);
  if (region == null) {
    console.log('mapbits_geolocation ' + p_item_id + ' : Region [' + p_region_id + '] is hidden or missing.');
    return;
  }
  
  var map = region(p_region_id).call("getMapObject");
  map.addControl(geolocator);
  
  // Accomodate both Mapbox in APEX 21 and Maplibre in APEX 22.	
  apex.jQuery('.mapboxgl-ctrl-group').addClass('maplibregl-ctrl-group');
  apex.jQuery('.mapboxgl-ctrl').addClass('maplibregl-ctrl');
  
  geolocator.on('geolocate', function(data) {
    apex.item(p_item_id).setValue('{"type": "Point", "coordinates":[' + data.coords.longitude + ', ' + data.coords.latitude + ']}');
    apex.event.trigger(apex.jQuery("#" + p_item_id), "mil_army_usace_mapbits_geolocate", data);
  });
  geolocator.on('error', function(data) {apex.event.trigger(apex.jQuery("#" + p_item_id), "mil_army_usace_mapbits_geolocate_error", data);});
  geolocator.on('trackuserlocationstart', function() {apex.event.trigger(apex.jQuery("#" + p_item_id), "mil_army_usace_mapbits_geolocate_trackstart");});
  geolocator.on('trackuserlocationend', function() {apex.event.trigger(apex.jQuery("#" + p_item_id), "mil_army_usace_mapbits_geolocate_trackend");});
  map.on('load', function() {
    apex.jQuery('.mapboxgl-ctrl-geolocate').trigger('click');
  });
}