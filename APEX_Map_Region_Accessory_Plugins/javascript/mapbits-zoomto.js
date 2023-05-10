function mapbits_zoom(p_action_id, p_ajax_identifier, p_region_id, p_extent_item) {
  // raise a javascript alert with the input message, msg, and write to console.
  function apex_alert(msg) {
    apex.jQuery(function(){console.log(p_action_id + " " + msg);});
  }
  
  var region = apex.region(p_region_id);
  if (region == null) {
    console.log('mapbits_zoom ' + p_action_id + ' : Region [' + p_region_id + '] is hidden or missing.');
    return;
  }
  var map = region.call("getMapObject");
  
  // call back the apex server to get the bounds corresponding to
  // the extent code. If successful, the associated map region (p_region_id)
  // will pan and zoom to those bounds. Otherwise, show the error message
  // in a javascript alert.
  map.getCanvas().style.cursor = 'not-allowed';
  apex.server.plugin(p_ajax_identifier, {x01: p_extent_item}, {
    success: function (pData) {
      console.log('success - fit bounds');
      if ("error" in pData) {
        apex_alert(err);
      } else {
        map.fitBounds(pData, {padding: 5});
      }
      map.getCanvas().style.cursor = 'pointer';
    },
    error: function (jqxhr, status, err) {
      apex_alert(err);
      map.getCanvas().style.cursor = 'pointer';
    }
  });
}