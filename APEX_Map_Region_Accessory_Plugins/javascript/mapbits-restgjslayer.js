function mapbits_restgjslayer(p_item_id, p_ajax_identifier, p_region_id, p_icon_url, p_title, p_url, p_token, p_sequence, p_checkbox_color, p_style, p_error) {
  // Accomodate both Mapbox in APEX 21 and Maplibre in APEX 22.
  var maplib = typeof maplibregl === 'undefined' ? mapboxgl : maplibregl;		
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
    console.log('mapbits_restgjslayer ' + p_item_id + ' : Region [' + p_region_id + '] is hidden or missing.');
    return;
  }
  
  var map = region.call("getMapObject");
  var lCookie = apex.storage.getCookie('Mapbits_RestGJSLayer_' + p_item_id+ "_" + $v("pInstance"));
  var layoutFunc = null;
  var paintFunc = null;
  var infotextFunc = null;
  var filterExpr = null;
  var zoomRange = [0,24];
  var spinnerImage = "data:image/gif;base64,R0lGODlhEAAQAPMPALu7u5mZmTMzM93d3REREQAAAHd3d1VVVWZmZqqqqoiIiO7u7kRERCIiIgARAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQFBwAPACwAAAAAEAAQAEAEcPDJtyg6dUrFetDTIopMoSyFcxxD1krD8AwCkASDIlPaUDQLR6G1Cy0SgqIkE1IQGMrFAKCcGWSBzwPAnAwarcKQ15MpTMJYd1ZyUDXSDGelBY0qIoBh/ZoYGgELCjoxCRRvIQcGD1kzgSAgAACQDxEAIfkEBQcADwAsAAAAAA8AEAAABF3wyfkMkotOJpscRKJJwtI4Q1MAoxQ0RFBw0xEvhGAVRZZJh4JgMAEQW7TWI4EwGFjKR+CAQECjn8DoN0kwDtvBT8FILAKJgfoo1iAGAPNVY9DGJXNMIHN/HJVqIxEAIfkEBQcADwAsAAAAABAADwAABFrwyfmColgiydpaQiY5x9Ith7hURdIl0wBIhpCAjKIIxaAUPQ0hFQsAC7MJALFSFi4SgC4wyHyuCYNWxH3AuhSEotkNGAALAPqqkigG8MWAjAnM4A8594vPUyIAIfkEBQcADwAsAAAAABAAEAAABF3wySkDvdKsddg+APYIWrcg2DIRQAcU6DJICjIsjBEETLEEBYLqYSDdJoCGiHgZwG4LQCCRECEIBAdoF5hdEIWwgBJqDs7DgcKyRHZl3uUwuhm2AbNNW+LV7yd+FxEAIfkEBQcACAAsAAAAABAADgAABEYQyYmMoVgeWQrP3NYhBCgZBdAFRUkdBIAUguVVo1ZsWFcEGB5GMBkEjiCBL2a5ZAi+m2SAURExwKqPiuCafBkvBSCcmiYRACH5BAUHAA4ALAAAAAAQABAAAARs0MnpAKDYrbSWMp0xZIvBKYrXjNmADOhAKBiQDF5gGcICNAyJTwFYTBaDQ0HAkgwSmAUj0OkMrkZM4HBgKK7YTKDRICAo2clAEIheKc9CISjEVTuEQrJASGcSBQcSUFEUDQUXJBgDBW0Zj34RACH5BAUHAA8ALAAAAAAQABAAAARf8Mn5xqBYgrVC4EEmBcOSfAEjSopJMglmcQlgBYjE5NJgZwjCAbO4YBAJjpIjSiAQh5ayyRAIDKvJIbnIagoFRFdkQDQKC0RBsCIUFAWsT7RwG410R8HiiK0WBwJjFBEAIfkEBQcADgAsAQABAA8ADwAABFrQybEWADXJLUHHAMJxIDAgnrOo2+AOibEMh1LN62gIxphzitRoCDAYNcNN6FBLShao4WzwHDQKvVGhoFAwGgtFgQHENhoB7nCwHRAIC0EyUcC8Zw1ha3NIRgAAIfkEBQcADwAsAAAAABAAEAAABGDwyfnWoljaNYYFV+Zx3hCEGEcuypBtMJBISpClAWLfWODymIFiCJwMDMiZBNAAYFqUAaNQ2E0YBIXGURAMCo1AAsFYBBoIScBJEwgSVcmP0li4FwcHz+FpCCQMPCFINxEAIfkEBQcADgAsAAABABAADwAABFzQyemWXYNqaSXY2vVtw3UNmROM4JQowKKlFOsgRI6ASQ8IhSADFAjAMIMAgSYJtByxyQIhcEoaBcSiwegpDgvAwSBJ0AIHBoCQqIAEi/TCIAABGhLG8MbcKBQgEQAh+QQFBwAPACwAAAEAEAAPAAAEXfDJSd+qeK5RB8fDRRWFspyotAAfQBbfNLCVUSSdKDV89gDAwcFBIBgywMRnkWBgcJUDKSZRIKAPQcGwYByAAYTEEJAAJIGbATEQ+B4ExmK9CDhBd8ThdHw/AmUYEQAh+QQFBwAPACwAAAEADwAPAAAEXvBJQIa8+ILSspdHkXxS9wxF4Q3L2aTBeC0sFjhAtuyLIjAMhYc2GBgaSKGuyNoBDp7czFAgeBIKwC6kWCAMxUSAFjtNCAAFGGF5tCQLAaJnWCTqHoREvQuQJAkyGBEAOw==";
  
  // get user-defined functions for paint, layout, info text, and the array for filtering.
  if(p_style.configFunc) {
    if ('layout' in p_style.configFunc) {
      layoutFunc = p_style.configFunc.layout;
    }
    if ('paint' in p_style.configFunc) {
      paintFunc = p_style.configFunc.paint;
    }
    if ('infotext' in p_style.configFunc) {
      infotextFunc = p_style.configFunc.infotext;
    }
    if ('filter' in p_style.configFunc) {
      filterExpr = p_style.filter;
    }    
  }
  
  // get the zoom range, do not display layer outside of this range.
  if (new RegExp('^[0-9]+,[0-9]+$').test(p_style.zoomRange)) {
    var tok = p_style.zoomRange.split(",");
    var zmin = parseInt(tok[0]);
    var zmax = parseInt(tok[1]);
    
    if (zmin >= 0 && zmax <= 24) {
      zoomRange[0] = zmin;
      zoomRange[1] = zmax;
    } else {
      apex_alert('Configuration Error: Could not set range of [' + p_title + '] using out of range zoom limits [' + p_style.zoomRange + "]. Min is 0 and max is 24.");
    }
  } else {
    apex_alert('Configuration Error: Could not set range of [' + p_title + '] using zoom limits [' + p_style.zoomRange + "]");
  }
  
  // the 'dataloading' event triggers on start of the layer load and ends on the 'data'
  // event. On start of load, show an animated  'spinner' image. Hide the spinner
  // at the end of load.
  map.on('dataloading', function(e) {
    if (e.sourceId == p_item_id + "source") {
      $('#' + p_item_id + '_legend_entry_status').attr('src', spinnerImage);
    }
  });
  map.on('data', function(e) {
    if (e.sourceId == p_item_id + "source") { // && e.isSourceLoaded) {  //isSourceLoaded doesn't work. Just spins forever.
      $('#' + p_item_id + '_legend_entry_status').attr('src', '');
    }
  });
  
  // handle error by displaying it in an apex.message.alert dialog. 
  function errorfunc(data) {
    if (data.sourceId == p_item_id + 'source') {
      // turn off spinner if it was on.
      $('#' + p_item_id + '_legend_entry_status').attr('src', '');
      apex_alert('Configuration Error: Could not load data source [' + p_title + '] using service url [' + p_url + "] " + data.error.message);
    }
  }
  map.on('error',errorfunc);

  function getTolerance() {
	  return map.getBounds().getNorthWest().distanceTo(new maplib.LngLat(map.getBounds().getEast(), map.getBounds().getNorth())) / map.getCanvas().width;  
  }
  // Set up map after it is loaded. This this the code that is run regardless
  // of whether or not an image is to be loaded.
  function setupMap() {
	var bounds = map.getBounds();
	var envelope = "" + bounds.getWest() + "," + bounds.getSouth() + "," + bounds.getEast() + "," + bounds.getNorth();  
    var url = p_url + "/query?f=geojson&where=1>0&token=" + p_token + "&outFields=*" + "&geometryType=esriGeometryEnvelope&geometry=" + envelope;
      
    // add the data source and set up the layer array.
    map.addSource(p_item_id + 'source', {
      type : 'geojson',
      data : url       
    });

    // when map view changes, if the zoom level is in the min/max zoom range, then update layer from source
    // and remove the strikethrough from the legend label. Otherwise, add a strikethrough from the legend label.     
    function onextentchange() {
      if (map.getZoom() >= zoomRange[0] && map.getZoom() <= zoomRange[1]) {
        var bounds = map.getBounds();	
        var envelope = "" + bounds.getWest() + "," + bounds.getSouth() + "," + bounds.getEast() + "," + bounds.getNorth();
        
		map.getSource(p_item_id + 'source').setData(p_url + "/query?f=geojson&where=1>0&token=" + p_token + "&outFields=*" + "&geometryType=esriGeometryEnvelope&geometry=" + envelope);
        if ($('#' + p_item_id + '_legend_entry_label').length) {
          $('#' + p_item_id + '_legend_entry_label').css('text-decoration', 'none');
        }
      } else {
        if ($('#' + p_item_id + '_legend_entry_label').length) {
          $('#' + p_item_id + '_legend_entry_label').css('text-decoration', 'line-through');
        }
      }
    }
    map.on('zoomend', onextentchange);
    map.on('dragend', onextentchange);
    map.on('resize', onextentchange);

    var lyr = {
      'id' : p_item_id,
      'type' : p_style.type,
      'maxzoom' : zoomRange[1],
      'minzoom' : zoomRange[0],
      'source': p_item_id + 'source',
      'paint' : {},
      'layout' : {},
      'metadata' : {'layer_sequence' : p_sequence}
    };
    
    // set filter from user configuration array
    if (filterExpr != null) {
      lyr.filter = filterExpr;
    }
    
    // set layout function from user configuration.
    if (layoutFunc != null ) {
      lyr.layout = layoutFunc(); 
    }
    
    // set symbol from user configuration. 
    // This will overwrite the icon-image and icon-size attributes of layout.
    if (p_style.type == 'symbol') {
      lyr.layout["icon-image"] = p_item_id + "_icon";
      lyr.layout["icon-size"] = 1.0;
    } 
    
    //set paint function from user configuration.
    if (paintFunc != null) {
      lyr.paint = paintFunc(); 
    } else {
    //overwrite pain attributes for line width, line color, opactity, and fill color.
    if (p_style.type == "fill") {
      lyr.paint["fill-color"] = p_style.fillColor;
      lyr.paint["fill-outline-color"] = p_style.strokeColor;
      lyr.paint["fill-opacity"] = p_style.fillOpacity;
    } else if (p_style.type == "line")  {
      lyr.paint["line-width"] = p_style.strokeWidth;
      lyr.paint["line-color"] = p_style.strokeColor;
    }
	}
    
    // set the layer to be invisible by default.
    lyr.layout.visibility = 'none';

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
          map.addLayer(lyr, mapbitslayers[i][1]); 
          return;
        }
      }
      map.addLayer(lyr);
    }
  }
  
  map.once('render', function() {
    // Mapbox is finished loading. Get to work.
    // if the style type is 'symbol', load the 
    // image first, the continue the map setup.
    if (p_style.type == "symbol") {
      var icon;
      if (p_style.iconImage.indexOf('/') > -1) {
        icon = p_style.iconImage;
      } else {
        icon = p_icon_url + p_style.iconImage + ".png";
      }
      map.loadImage(icon, function(error, image) {  
        if (error) {
          apex_alert('Configuration Error: Layer [' + p_title + '] Icon [' + p_style.iconImage + ']  failed to load. Fix Image Icon setting');return;
        }
        map.addImage(p_item_id + "_icon", image, {
                "sdf": "true"
            });
        setupMap();
      });
    } else {
      setupMap();
    }
    
    // Update APEX legend for mapbox. Wait one second for it to render, first. Add entries for the plugin layer.
    // Use a cookie value to determine if the checkbox value should start on or off.
    setTimeout(function() {
      var legend = apex.jQuery('#' + p_region_id + '_legend');
      $('<div class="a-MapRegion-legendItem a-MapRegion-legendItem--hideable">' + 
        '<input type="checkbox" class="a-MapRegion-legendSelector is-checked" checked="" id="' + p_item_id + '_legend_entry' + '" style="--a-map-legend-selector-color:'+ p_checkbox_color + '">' +
        '<label class="a-MapRegion-legendLabel" layerid="' + p_item_id + '" id="' + p_item_id + '_legend_entry_label' + '" for="' + p_item_id + '_legend_entry' + '">' + p_title + '<img id="' + p_item_id + '_legend_entry_status"/></label>' +
        '</div>').appendTo(legend);
      
      if (map.getZoom() < zoomRange[0] || map.getZoom() > zoomRange[1]) {
        $('#' + p_item_id + '_legend_entry_label').css('text-decoration', 'line-through');
      }

      if (lCookie == 'visible') {
        map.setLayoutProperty(p_item_id, 'visibility', 'visible');
        apex.jQuery('#' + p_item_id + '_legend_entry').prop('checked', true);
      } else if (lCookie == 'none') {
        map.setLayoutProperty(p_item_id, 'visibility', 'none');
        apex.jQuery('#' + p_item_id + '_legend_entry').prop('checked', false);
      } else {
        if (p_style.initVisibility == 'Y') {
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
          apex.storage.setCookie('Mapbits_RestGJSLayer_' + p_item_id+ "_" + $v("pInstance"), 'visible');	  
        } else {
          map.setLayoutProperty(cbid.substr(0, cbid.length - '_legend_entry'.length), 'visibility', 'none');
          apex.storage.setCookie('Mapbits_RestGJSLayer_' + p_item_id+ "_" + $v("pInstance"), 'none');	  
        }  
      });
    }, 1000);
    
    // Change the cursor to a pointer when the mouse is over the places layer.
    map.on('mouseenter', p_item_id, function () {
      map.getCanvas().style.cursor = 'pointer';
    });
   
    // Change it back to a pointer when it leaves.
    map.on('mouseleave', p_item_id, function () {
      map.getCanvas().style.cursor = '';
    });
    
    // when a feature is clicked, show info box popup.
    // if user provided an infotext function, transform the text
    // using that function, otherwise display the info using <dl>.
    map.on('click', p_item_id, function(e) {
      var coordinates = e.features[0].geometry.coordinates.slice();
      var description = e.features[0].properties.LABEL;
      var txt;
      if (infotextFunc != null) {
        txt = infotextFunc(e.features[0]);
      } else {
        txt = '<dl style="padding: 5px;">';
        for (var key in e.features[0].properties) {
          txt = txt + "<dt><strong>" + key + "</strong></dt><dd>" +  e.features[0].properties[key] + "</dd>";
        }
        txt = txt + "</dl>";
      } 

      // set the popup coordinates to clicked feature's first point. Flatten array in case of lines or multigeometry.
	  const coordinatesflt = coordinates.flat(3);
      new maplib.Popup().setLngLat([coordinatesflt[0], coordinatesflt[1]]).setHTML(txt).addTo(map);
    });
  });
}