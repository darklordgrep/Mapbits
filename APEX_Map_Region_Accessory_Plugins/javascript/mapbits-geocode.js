function mapbits_geocode(p_action_id, p_ajax_identifier, p_region_id, p_street, p_city, p_state, p_zip, p_collection_name, p_draw_item) {	
  // raise a javascript alert with the input message, msg, and write to console.
  function apex_alert(msg) {
    apex.jQuery(function(){apex.message.alert(msg);console.log(p_action_id + " " + msg);});
  }
  /*
   * Update latitude and longitude degrees, minutes, and seconds fields and mapbits item value from the mapbits geometry.
   */
  function syncCoordsFromGeometry(geometry) {
    if (geometry.coordinates.length < 1) {
      return;
    }
    if (geometry.type == "Point") {
      var x = geometry.coordinates[0];
      var y = geometry.coordinates[1];
      apex.jQuery('#' + p_draw_item + "_longitude_degrees").val(get_degrees(x));
      apex.jQuery('#' + p_draw_item + "_longitude_minutes").val(get_minutes(x));
      apex.jQuery('#' + p_draw_item + "_longitude_seconds").val(get_seconds(x));
      apex.jQuery('#' + p_draw_item + "_latitude_degrees").val(get_degrees(y));
      apex.jQuery('#' + p_draw_item + "_latitude_minutes").val(get_minutes(y));
      apex.jQuery('#' + p_draw_item + "_latitude_seconds").val(get_seconds(y));
    } 
  }
  
  // if the region is hidden, then exit.
  var region = apex.region(p_region_id);
  if (region == null) {
    console.log('mapbits_geocode ' + p_action_id + ' : Region [' + p_region_id + '] is hidden or missing.');
    return;
  }
  var map = region.call("getMapObject");
  
  map.getCanvas().style.cursor = 'not-allowed';
  
  // Call back to the server with the city, street, state, zipcode values from the page items.
  // When the server returns the results, render those to the map and recenter.
  apex.server.plugin(p_ajax_identifier, {x01: p_street, x02: p_city, x03: p_state, x04: p_zip, x05: p_collection_name}, {
    success: function (pData) {
      if ("error" in pData) {
        apex_alert(err);
      } else {
		    setTimeout(function() {
          var feats = map.draw.getAll();
          for(var i=0;i<feats.features.length-1;i++) {
            map.draw.delete(feats.features[i].id);
          }
	        feats = map.draw.getAll();
          var geom = feats.features[0].geometry;
          syncCoordsFromGeometry(geom);
		    }, 100);
        map.draw.add(pData);
		    map.setCenter(pData.coordinates);
        map.getCanvas().style.cursor = 'pointer';
      }
	  },
    error: function (jqxhr, status, err) {
      apex_alert(err);
      map.getCanvas().style.cursor = 'pointer';
    }
  });
}