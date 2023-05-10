function mapbits_station(p_item_id, p_ajax_identifier, p_region_id, p_sequence, p_chart_id, p_options) {
  var maplib = typeof maplibregl === 'undefined' ? mapboxgl : maplibregl;	
  
  // raise a javascript alert with the input message and write to console.
  function apex_alert(msg) {
    apex.jQuery(function(){apex.message.alert(msg);console.log(msg);});
  }
  
  var region = apex.region(p_region_id);
  if (region == null) {
    console.log('mapbits_station ' + p_item_id + ' : Region [' + p_region_id + '] is hidden or missing.');
    return;
  }
  
  var map = region.call("getMapObject");
  var markers = [];
  var labelClass = "station_" + p_item_id;
  
  //load the station icon
  map.on('load', function() {
    map.loadImage(p_options.icon, function(error, image) {  
      if (error) {
        apex_alert('Configuration Error: Layer [' + p_item_id + '] Icon  failed to load. ');
        return;
      }
      map.addImage('staticon_' + p_item_id, image, {
        "sdf": "true"
      });
    });
  });
  
  // Configure station labeler. Add a plus sign. Ex. 1000 -> 10+00.
  var StationConverter = {
    format: function(value) {
      var tens = (value - 100 * Math.floor(value / 100)) < 10 ? '0' : '';   
      return Math.floor(value / 100) + "+" + tens  + (value - 100 * Math.floor(value / 100));
    }
  };  
  apex.jQuery('#' + p_chart_id).on('apexafterrefresh', function(){
    apex.region(p_chart_id).widget().ojChart("option","xAxis.tickLabel.converter", StationConverter );  
  });
  
  function station(){
    // I couldn't find an to signal when the chart finishes rendering. Instead, use setInterval until 
    // x axis labels are found.
    var intv1 = setInterval(function(){
      if (apex.jQuery('#' + p_chart_id + ' text').length == 0) {
        return;
      }
      map.getCanvas().style.cursor = 'not-allowed';
      
      // add the stations labeled in the chart region X axis.
      var mapStations = [];
      apex.jQuery.each(apex.jQuery('#' + p_chart_id + ' text'), function(n, item) {
        if (item.innerHTML.indexOf('+') > -1) {
          mapStations.push(parseFloat(item.innerHTML.replace("+", '')));
        }
      });
      if (mapStations.length == 0) {
        return;
      }
      clearInterval(intv1);

      // put station values into a comma-delimited list and callback the APEX to get
      // a geojson dataset with the geometry of the input stations.
      apex.server.plugin(p_ajax_identifier, {x01: mapStations.join(','), x02: ''}, {
        success: function (pData) {
          if ("error" in pData) {
            apex_alert(err);
          } else {
            // delete existing markers
            for (var i=0; i < markers.length; i++) {
              markers[i].remove();
            }
            markers.splice(0,markers.length);
            
            // iterate through the station marker coordinate data from the callback
            // and create markers. The markers are station label strings.
            for (var i=0;i < pData.features.length;i++) {
              var el = document.createElement('div');
              el.innerHTML = '<div style="font-weight:bold" class="' + labelClass + '">' + pData.features[i].properties.station  + '</div>';
              
              var markerLabel = new maplib.Marker({element: el, offset: [10,10]}).setLngLat([pData.features[i].geometry.coordinates[0], pData.features[i].geometry.coordinates[1]]).addTo(map);
              markers.push(markerLabel);      
            }
            
            // remove existing source and layer data
            if (map.getLayer('statlyr_' + p_item_id)) {
              map.removeLayer('statlyr_' + p_item_id);
            }
            if (map.getSource('statsource_' + p_item_id)) {
              map.removeSource('statsource_' + p_item_id);
            }
            
            // create layer with station marker coordinate data from the callback
            map.addSource('statsource_' + p_item_id, {
              'type' : 'geojson',
              'data' : pData
            });

            // add the layer to the map. use the sequence number from the page 
            // item to order the layers. Higher numbers are last and displayed on top.
            var lyr = {'id' : 'statlyr_' + p_item_id, 
                      'type' : 'symbol',
                      'source' : 'statsource_' + p_item_id,
                      layout : {
                        'icon-image' : 'staticon_' + p_item_id,
                        'icon-size' : 1.0
                      }
                    };
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

            // fit view to the station markers
            var bounds = new maplib.LngLatBounds();
            for (var i=0;i < pData.features.length;i++) {
              bounds.extend(pData.features[i].geometry.coordinates); 
            }
            map.fitBounds(bounds, {padding: {top: 20, bottom:20, left: 20, right: 20}});              
            map.getCanvas().style.cursor = 'default';
          }
        }
      });
    }, 200);
  }
  // station on data and viewport change    
  apex.jQuery('#' + p_chart_id).on('ojviewportchange', function() {station();});  
  apex.jQuery('#' + p_chart_id).on('apexafterrefresh', function() {station();});  
  
}