function mapbits_wmslayer(p_item_id, p_ajax_identifier, p_region_id, p_title, p_url, p_layers, p_sequence, p_checkbox_color, p_initVisibility, p_tileSize, p_error, p) {
  // raise a javascript alert with the input message and write to console.
  function apex_alert(msg) {
    apex.jQuery(function(){apex.message.alert(msg);console.log(msg);});
  }
    
  // if an errror occurs in the plugin plsql and is passed into the javascript function, 
  // raise an alert with that message.
  if (p_error != "") {
    apex_alert(p_error);
    return;
  }
    
  var region = apex.region(p_region_id);
  if (region == null) {
    console.log('mapbits_wmslayer ' + p_item_id + ' : Region [' + p_region_id + '] is hidden or missing.');
    return;
  }
  
  // get the map hook
  var map = region.call("getMapObject");

  // Mapblibre in version 22.2 of APEX runs into 
  // network trouble. The TE header is missing
  // in new versions. Older version don't appear
  // to have setTransformRequest, but they work 
  // anyway.
  if (typeof map.setTransformRequest === "function") { 
    map.setTransformRequest(function(t_url, requestType) {
      return {url: t_url, headers : {'TE' : 'trailers'}};     
    });
  }
  var tileSize = p_tileSize;
  var format = 'image/png';
  var url = p_url + "?bbox={bbox-epsg-3857}&format=" + format + "&service=WMS&version=1.1.1&request=GetMap&srs=EPSG:3857&transparent=true&width=" + tileSize + "&height=" + tileSize + "&styles=&layers=" + p_layers;
  var lCookie = apex.storage.getCookie('Mapbits_WMSLayer_' + p_item_id+ "_" + $v("pInstance"));
  var spinnerImage = "data:image/gif;base64,R0lGODlhEAAQAPMPALu7u5mZmTMzM93d3REREQAAAHd3d1VVVWZmZqqqqoiIiO7u7kRERCIiIgARAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQFBwAPACwAAAAAEAAQAEAEcPDJtyg6dUrFetDTIopMoSyFcxxD1krD8AwCkASDIlPaUDQLR6G1Cy0SgqIkE1IQGMrFAKCcGWSBzwPAnAwarcKQ15MpTMJYd1ZyUDXSDGelBY0qIoBh/ZoYGgELCjoxCRRvIQcGD1kzgSAgAACQDxEAIfkEBQcADwAsAAAAAA8AEAAABF3wyfkMkotOJpscRKJJwtI4Q1MAoxQ0RFBw0xEvhGAVRZZJh4JgMAEQW7TWI4EwGFjKR+CAQECjn8DoN0kwDtvBT8FILAKJgfoo1iAGAPNVY9DGJXNMIHN/HJVqIxEAIfkEBQcADwAsAAAAABAADwAABFrwyfmColgiydpaQiY5x9Ith7hURdIl0wBIhpCAjKIIxaAUPQ0hFQsAC7MJALFSFi4SgC4wyHyuCYNWxH3AuhSEotkNGAALAPqqkigG8MWAjAnM4A8594vPUyIAIfkEBQcADwAsAAAAABAAEAAABF3wySkDvdKsddg+APYIWrcg2DIRQAcU6DJICjIsjBEETLEEBYLqYSDdJoCGiHgZwG4LQCCRECEIBAdoF5hdEIWwgBJqDs7DgcKyRHZl3uUwuhm2AbNNW+LV7yd+FxEAIfkEBQcACAAsAAAAABAADgAABEYQyYmMoVgeWQrP3NYhBCgZBdAFRUkdBIAUguVVo1ZsWFcEGB5GMBkEjiCBL2a5ZAi+m2SAURExwKqPiuCafBkvBSCcmiYRACH5BAUHAA4ALAAAAAAQABAAAARs0MnpAKDYrbSWMp0xZIvBKYrXjNmADOhAKBiQDF5gGcICNAyJTwFYTBaDQ0HAkgwSmAUj0OkMrkZM4HBgKK7YTKDRICAo2clAEIheKc9CISjEVTuEQrJASGcSBQcSUFEUDQUXJBgDBW0Zj34RACH5BAUHAA8ALAAAAAAQABAAAARf8Mn5xqBYgrVC4EEmBcOSfAEjSopJMglmcQlgBYjE5NJgZwjCAbO4YBAJjpIjSiAQh5ayyRAIDKvJIbnIagoFRFdkQDQKC0RBsCIUFAWsT7RwG410R8HiiK0WBwJjFBEAIfkEBQcADgAsAQABAA8ADwAABFrQybEWADXJLUHHAMJxIDAgnrOo2+AOibEMh1LN62gIxphzitRoCDAYNcNN6FBLShao4WzwHDQKvVGhoFAwGgtFgQHENhoB7nCwHRAIC0EyUcC8Zw1ha3NIRgAAIfkEBQcADwAsAAAAABAAEAAABGDwyfnWoljaNYYFV+Zx3hCEGEcuypBtMJBISpClAWLfWODymIFiCJwMDMiZBNAAYFqUAaNQ2E0YBIXGURAMCo1AAsFYBBoIScBJEwgSVcmP0li4FwcHz+FpCCQMPCFINxEAIfkEBQcADgAsAAABABAADwAABFzQyemWXYNqaSXY2vVtw3UNmROM4JQowKKlFOsgRI6ASQ8IhSADFAjAMIMAgSYJtByxyQIhcEoaBcSiwegpDgvAwSBJ0AIHBoCQqIAEi/TCIAABGhLG8MbcKBQgEQAh+QQFBwAPACwAAAEAEAAPAAAEXfDJSd+qeK5RB8fDRRWFspyotAAfQBbfNLCVUSSdKDV89gDAwcFBIBgywMRnkWBgcJUDKSZRIKAPQcGwYByAAYTEEJAAJIGbATEQ+B4ExmK9CDhBd8ThdHw/AmUYEQAh+QQFBwAPACwAAAEADwAPAAAEXvBJQIa8+ILSspdHkXxS9wxF4Q3L2aTBeC0sFjhAtuyLIjAMhYc2GBgaSKGuyNoBDp7czFAgeBIKwC6kWCAMxUSAFjtNCAAFGGF5tCQLAaJnWCTqHoREvQuQJAkyGBEAOw==";
  
  // the 'dataloading' event triggers on start of the layer load and ends on the 'data'
  // event. On start of load, show an animated  'spinner' image. Hide the spinner
  // at the end of load. Use the 'idle' event as a fallback to hide the spinner.
  map.on('dataloading', function(e) {
	if (e.sourceId == p_item_id + "source") {
      apex.jQuery('#' + p_item_id + '_legend_entry_status').attr('src', spinnerImage);
    }
  });
  map.on('data', function(e) {
	if (e.sourceId == p_item_id + "source" && e.isSourceLoaded) {
      apex.jQuery('#' + p_item_id + '_legend_entry_status').attr('src', '');
    }
  });
  map.on('idle', function(e) {
    apex.jQuery('#' + p_item_id + '_legend_entry_status').attr('src', '');
  });

  // on a map error, create an alert.
  map.once('error', function(e) {
    if (e.sourceId == p_item_id + "source") {
      console.log(e);
      apex_error(e.error.message + "\n" + p_url);
    }
  });
   
  map.once('render',  function() {
	map.addSource(p_item_id + 'source', {
      type : 'raster',
      tiles : [url]
    });
    var lyr = {
      'id' : p_item_id,
      'type' : 'raster',
      'source' : p_item_id + 'source',
      'paint' : {},
      'metadata' : {'layer_sequence' : p_sequence},
      'layout' : {'visibility': 'none'}
    };
    
    // add the layer to the map. use the sequence number from the page 
    // item to order the layers. Higher numbers are last and displayed on top.
    var layers = map.getStyle().layers;
    var mapbitslayers = layers.filter(function(val){
      if ('metadata' in val) { 
        return 'layer_sequence' in val.metadata;
      } else {
        return false;
      }
    }).map(function(val) {return [val.metadata.layer_sequence, val.id]});
	if (mapbitslayers.length == 0) {
      map.addLayer(lyr); 
    } else {
      mapbitslayers.sort();
      for(var i=0;i<mapbitslayers.length;i++) {
        if (p_sequence < mapbitslayers[i][0]) {
		  console.log('addlayer');	
          map.addLayer(lyr, mapbitslayers[i][1]); 
          return;
        }
      }
      map.addLayer(lyr);
    }

    // Update APEX legend for mapbox. Wait one second for it to render, first. Add entries for the plugin layer.
    // Use a cookie value to determine if the checkbox value should start on or off.
    setTimeout(function() {
      var legend = apex.jQuery('#' + p_region_id + '_legend');
      apex.jQuery('<div class="a-MapRegion-legendItem a-MapRegion-legendItem--hideable">' + 
      '<input type="checkbox" class="a-MapRegion-legendSelector is-checked" checked="" id="' + p_item_id + '_legend_entry' + '" style="--a-map-legend-selector-color:'+ p_checkbox_color + '">' +
      '<label class="a-MapRegion-legendLabel" layerid="' + p_item_id + '" id="' + p_item_id + '_legend_entry_label' + '" for="' + p_item_id + '_legend_entry' + '">' + p_title + '<img id="' + p_item_id + '_legend_entry_status"/></label>' +
      '</div>').appendTo(legend);
      
      if (lCookie == 'visible') {
        map.setLayoutProperty(p_item_id, 'visibility', 'visible');
        apex.jQuery('#' + p_item_id + '_legend_entry').prop('checked', true);
      } else if (lCookie == 'none') {
        map.setLayoutProperty(p_item_id, 'visibility', 'none');
        apex.jQuery('#' + p_item_id + '_legend_entry').prop('checked', false);
      } else {
        if (p_initVisibility == 'Y') {
          map.setLayoutProperty(p_item_id, 'visibility', 'visible');
          apex.jQuery('#' + p_item_id + '_legend_entry').prop('checked', true);
        } else {
          map.setLayoutProperty(p_item_id, 'visibility', 'none');
          apex.jQuery('#' + p_item_id + '_legend_entry').prop('checked', false);
        }
      }
        
      apex.jQuery('#' + p_item_id + '_legend_entry').change(function(e){
        var cb = apex.jQuery(this);
        var cbid = cb.attr('id');

        if (cb.is(':checked')) {
          map.setLayoutProperty(cbid.substr(0, cbid.length - '_legend_entry'.length), 'visibility', 'visible');
          apex.storage.setCookie('Mapbits_WMSLayer_' + p_item_id+ "_" + $v("pInstance"), 'visible');	  
        } else {
          map.setLayoutProperty(cbid.substr(0, cbid.length - '_legend_entry'.length), 'visibility', 'none');
          apex.storage.setCookie('Mapbits_WMSLayer_' + p_item_id+ "_" + $v("pInstance"), 'none');	  
        }         
      });
    }, 1000);
  });
}