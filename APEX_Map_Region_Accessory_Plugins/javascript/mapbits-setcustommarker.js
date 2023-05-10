function mapbits_setcustommarker(p_action_id, p_region_id, p_geom_item, p_style, p_title, p_title_item, p_error) {
  var maplib = typeof maplibregl === 'undefined' ? mapboxgl : maplibregl;	
  
  // raise a javascript alert with the input message, msg, and write to console.
  function apex_alert(msg) {
    apex.jQuery(function(){apex.message.alert(p_action_id + " " + msg);
    console.log(p_action_id + " " + msg);});
  }
  var p_geom = JSON.parse(apex.item(p_geom_item).getValue());
  
  // if an errror occurs in the plugin plsql and is passed into the javascript function, 
  // raise an alert with that message.
  if (p_error != "") {
    apex_alert(p_error);
    return;
  }
  
  var x = p_geom.coordinates[0];
  var y = p_geom.coordinates[1];
  var p_marker_id = p_action_id;
  
  // if region is hidden, then exit.
  var region = apex.region(p_region_id);
  if (region == null) {
    console.log('mapbits_setcustommarker ' + p_action_id + ' : Region [' + p_region_id + '] is hidden or missing.');
    return;
  }
  var map = region.call("getMapObject");
  
  if (!map.markers) {
    map.markers = {};
  }
  p_style.draggable = false;
  if (p_marker_id in map.markers) {
    map.markers[p_marker_id].setLngLat([x, y]);  
  } else {
    var marker = new maplib.Marker(p_style).setLngLat([x, y]).addTo(map);
     map.markers[p_marker_id] = marker;
  }
  if (!p_title) {
    p_title = $v(p_title_item);
  }
  if (p_title &&  p_title != "") {
    map.markers[p_marker_id].setPopup(new maplib.Popup().setHTML(p_title));
  }
}