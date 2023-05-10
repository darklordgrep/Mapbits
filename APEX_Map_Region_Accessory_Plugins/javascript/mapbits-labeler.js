function mapbits_labeler(p_item_id, p_ajax_identifier, p_region_id, p_options) {	
  var maplib = typeof maplibregl === 'undefined' ? mapboxgl : maplibregl;	
  
  // raise a javascript alert with the input message and write to console.
  function apex_alert(msg) {
    apex.jQuery(function(){apex.message.alert(msg);console.log(msg);});
  }
  
  // get the centroid of a GeoJSON geometry. return a LngLatBounds object.
  function getCentroid(geom) {
    if (geom.type == 'MultiPolygon') {
      var rt = new maplib.LngLatBounds();
      for (var i = 0;i<geom.coordinates.length;i++) {
        for (var j = 0;j<geom.coordinates[i].length;j++) {
          for (var k = 0;k<geom.coordinates[i][j].length;k++) {
            rt.extend(new maplib.LngLat(geom.coordinates[i][j][k][0], geom.coordinates[i][j][k][1]));
          }
        }
      }
      return [(rt.getWest() + rt.getEast()) / 2.0,(rt.getNorth() + rt.getSouth()) / 2.0];
    }
    if (geom.type == 'Polygon' || geom.type == 'MultiLineString') {
      var rt = new maplib.LngLatBounds();
      for (var i = 0;i<geom.coordinates.length;i++) {
          for (var j = 0;j<geom.coordinates[i].length;j++) {
            rt.extend(new maplib.LngLat(geom.coordinates[i][j][0], geom.coordinates[i][j][1]));
          }
        }
      return [(rt.getWest() + rt.getEast()) / 2.0,(rt.getNorth() + rt.getSouth()) / 2.0];
    }
    if (geom.type == 'LineString') {
      var rt = new maplib.LngLatBounds();
      for (var i = 0;i<geom.coordinates.length;i++) {
        rt.extend(new maplib.LngLat(geom.coordinates[i][0], geom.coordinates[i][1]));
      }
      return [(rt.getWest() + rt.getEast()) / 2.0,(rt.getNorth() + rt.getSouth()) / 2.0];
    }
    if (geom.type == 'Point') {
      return [geom.coordinates[0], geom.coordinates[1]];
    }
  }
  
  const p_layer_name = p_options['p_layer_name'];
  const p_info_source = p_options['p_info_source'];
  const p_zoom_range = p_options['p_zoom_range'];
  const p_offset = p_options['p_offset'];
  const p_anchor = p_options['p_anchor'];
  const p_suppress_info_window = p_options['p_suppress_info_window'];  
  
  
  var region = apex.region(p_region_id);
  if (region == null) {
    console.log('mapbits_labeler ' + p_item_id + ' : Region [' + p_region_id + '] is hidden or missing.');
    return;
  }
  
  var map = region.call('getMapObject');
  var layerId = region.call('getLayerIdByName', p_layer_name);
  if (!layerId) {
    apex_alert('Configuration Error: Invalid Layer Name [' + p_layer_name + ']');
    return;    
  }
  var labelClass = 'maplabel_' + p_item_id;
  var zoomRange = [0,24];
  var labelArray = {};
  
  // get the visibility zoom level range.
  if (new RegExp('^[0-9]+,[0-9]+$').test(p_zoom_range)) {
    const tok = p_zoom_range.split(",");
    const zmin = parseInt(tok[0]);
    const zmax = parseInt(tok[1]);
    
    if (zmin >= 0 && zmax <= 24) {
      zoomRange[0] = zmin;
      zoomRange[1] = zmax;
    } else {
      apex_alert('Configuration Error: Could not set range of [' + p_layer_name + '] using out of range zoom limits [' + p_zoom_range + "]. Min is 0 and max is 24.");
    }
  } else {
    apex_alert('Configuration Error: Could not set range of [' + p_layer_name + '] using zoom limits [' + p_zoom_range + "]");
  }
  
  // when data is loaded into the map, iterate through the features in the layer
  // and create the labels.
  function labelData(e) {
    // remove all existing labels.
    for (var lfid in labelArray) {
      var lfeat = labelArray[lfid];
      lfeat.remove(); 
    }
    labelArray = []

    // If the map's extents is within the zoom level range, then create labels.
    if (map.getZoom() >= zoomRange[0] && map.getZoom() <= zoomRange[1]) {
      // hide the infowindow if labeling using infowindow content and suppress window option set to true.
      // need to figure out how to isloate the labeled layer infowindows.
      if (p_suppress_info_window && p_info_source == 'infoWindow') {  
        apex.jQuery('div.mapboxgl-popup.mapboxgl-popup-anchor-top').css('display', 'none');
      }
      
      // get the all rendered features (filter by layer name does not appear to work - check layer id manually).
      // for each feature, create a Marker.
      const feats = map.queryRenderedFeatures();
      var renderedFeatIds = [];      
      for (const feat of feats) {
        if (feat.layer.id == layerId) {
          // store each feature id in an array to delete previous labels on next render.
          renderedFeatIds.push(feat.id);
          
          // from the feature, get the centroid and parse the label content as JSON. 
          var cent= getCentroid(feat.geometry);      
          var props = JSON.parse(feat.properties[p_info_source]);
          
          // if there is a template, replace template placeholders with their real values,
          // otherwise, just display the body or content.
          if (props.content.template) {
            s = props.content.template;
            for(var k in props.columns) {
              s = s.replace('&' + k + '.', props.columns[k]);
            }
          } else if (props.content.body)  {
            s = props.content.body;
          } else{
            s = props.content;
          }  
          
          // create the HTML element and marker.
          var el = document.createElement('div');
          el.innerHTML = '<div class="' + labelClass + '">' + s + '</div>';

          if (labelArray[feat.id] !== undefined) {
             labelArray[feat.id].remove();
          }
          labelArray[feat.id] = new maplib.Marker({element: el, offset: p_offset, anchor: p_anchor}).setLngLat(cent).addTo(map);
        }
      }
    }
  }
  map.on('idle', labelData); 
}

