function mapbits_draw(p_item_id, p_ajax_identifier, p_region_id, p_geometry, p_options, p_error) {
  /*
   *  generate an error message alert, msg
   */
  function apex_alert(msg) {
    apex.jQuery(function(){apex.message.alert(msg);console.log('alert ' + msg);});
  }
  
  /*
   * Return the extent of the input geom object as a mapboxgl.LngLatBounds.
   * Input geometry object is geojson geometry format (not Feature).
   */
  function getBounds(geom) {
    var parray;
    if (geom.type == "LineString") {
      parray = geom.coordinates;
    } else if (geom.type == "Polygon") {
      parray = geom.coordinates[0];
    } else if (geom.type == "MultiPolygon") {
      parray = [];
      for(var i=0;i<geom.coordinates.length;i++) {
        parray = parray.concat(geom.coordinates[i][0]);
      }
    } else if (geom.type == "MultiLineString") {
      parray = [];
      for(var i=0;i<geom.coordinates.length;i++) {
        parray = parray.concat(geom.coordinates[i]);
      }
    }
    
    var rt = new mapboxgl.LngLatBounds(parray[0], parray[0]);
    for (var i = 1; i < parray.length;i++) {
      rt.extend(parray[i]);
    }
    return rt;
  }
  
  // Make variables from plugin attributes
  var p_geometry_modes = p_options['geometry_modes'];
  var p_readonly = p_options['readonly'];
  var p_show_coords = p_options['show_coords'];
  var p_point_zoom_level = p_options['point_zoom_level'];
  var p_enable_geolocate = p_options['enable_geolocate'];
  
  /* Class for Mapbox Geolocate Point Control, exposing the button.
   * Assumes control buttons are 32x32px.
   */
  function GeolocatePointButton(){}
  GeolocatePointButton.prototype.onAdd = function(map) {
    this.m_map = map;
    this.m_container = document.createElement('div');
    this.geolocate_point_button = document.createElement('button');
    this.geolocate_point_button.style = "line-height:16px;width:32px;height:32px;display:none;";
    this.geolocate_point_button.innerHTML = '<i class="fa fa-location-circle"></i>';
    this.geolocate_point_button.type="button";    
    this.m_container.appendChild(this.geolocate_point_button);
    this.m_container.className = "mapboxgl-ctrl maplibregl-ctrl";
    return this.m_container;
  };
  GeolocatePointButton.prototype.onRemove = function() {
    this.m_container.parentNode.removeChild(this.m_container);
    this.m_map = undefined;
  };
  GeolocatePointButton.prototype.getButton = function() {
    return this.geolocate_point_button;
  };
  var geolocate_point_control = new GeolocatePointButton();
  
  /*
   * Set the mapbits geometry to the coordinates shown in the latitude/longitude degress, minutes, seconds input text fields.
   */
  function syncGeometryFromCoordinates() {
    var geomx = get_decimal_degrees(apex.jQuery('#' + p_item_id + "_longitude_degrees").val(), 
                                    apex.jQuery('#' + p_item_id + "_longitude_minutes").val(), 
                                    apex.jQuery('#' + p_item_id + "_longitude_seconds").val());
    var geomy = get_decimal_degrees(apex.jQuery('#' + p_item_id + "_latitude_degrees").val(), 
                                    apex.jQuery('#' + p_item_id + "_latitude_minutes").val(), 
                                    apex.jQuery('#' + p_item_id + "_latitude_seconds").val());
    
	  // if the minutes and seconds fields are not numbers (null), then use zero to calculate decimal degrees
    if (isNaN(geomx)) {
      geomx = get_decimal_degrees(apex.jQuery('#' + p_item_id + "_longitude_degrees").val(), apex.jQuery('#' + p_item_id + "_longitude_minutes").val(), 0);     
      if (isNaN(geomx)) {
        geomx = get_decimal_degrees(apex.jQuery('#' + p_item_id + "_longitude_degrees").val(), 0, 0);     
      }
    }
    if (isNaN(geomy)) {
      geomy = get_decimal_degrees(apex.jQuery('#' + p_item_id + "_latitude_degrees").val(), apex.jQuery('#' + p_item_id + "_latitude_minutes").val(), 0);
      if (isNaN(geomy)) {
        geomy = get_decimal_degrees(apex.jQuery('#' + p_item_id + "_latitude_degrees").val(), 0, 0);
      }
    }
	
    // if no features have been create, create an empty feature for the draw tool.
    var fc = map.draw.getAll();
    if (fc.features.length == 0) {
      fc.features.push({type: "Feature", properties: {}, geometry : {coordinates: [null, null]}});  
    }
    
    // Set the point geometry in the map.
    fc.features[0].geometry.type = "Point";
    fc.features[0].geometry.coordinates[0] = geomx;
    fc.features[0].geometry.coordinates[1] = geomy;
    map.draw.set(fc);
	
    // Write the geometry back to the server and pan to the geometry.
	  var feats = map.draw.getAll();
    var geom = feats.features[0].geometry;
    writeGeometry(JSON.stringify(geom));
	  map.panTo(geom.coordinates);
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
      apex.jQuery('#' + p_item_id + "_longitude_degrees").val(get_degrees(x));
      apex.jQuery('#' + p_item_id + "_longitude_minutes").val(get_minutes(x));
      apex.jQuery('#' + p_item_id + "_longitude_seconds").val(get_seconds(x));
      apex.jQuery('#' + p_item_id + "_latitude_degrees").val(get_degrees(y));
      apex.jQuery('#' + p_item_id + "_latitude_minutes").val(get_minutes(y));
      apex.jQuery('#' + p_item_id + "_latitude_seconds").val(get_seconds(y));
    } 
  }
  
  // if an errror occurs in the plugin plsql and is passed into the javascript function, 
  // raise an alert with that message.
  if (p_error != "") {
    apex_alert(p_error);
    return;
  }
  
  var map = apex.region(p_region_id).call("getMapObject");
  var entry_size = 10;
  var width=apex.jQuery('#' + p_region_id + '_map_region').css('width');

  // If the Display Coordinates attribute is Yes and the initial geometry is a point or there is no initial geometry, show coordinate data entry fields.
  var display_coords = "none";
  var readonly = "";
  if (p_readonly) {
    readonly = "readonly";
  }
  
  if (p_show_coords) {
  
    if (p_geometry != null) {
      if (p_geometry.type == "Point") {
        display_coords = 'block';
      }
    } else {
      if (p_geometry_modes.indexOf("POINT") > -1) {
        display_coords = 'block';
      }
    }
    var coordform = '<div align="left" id="' + p_item_id + '_coords" class="ui-widget-header t-Region-header ui-corner-all" style="display:' + display_coords + ';width:' + width + 'px; padding: 4px 0px 2px 4px; float:left; margin:0;">' +
    '<label>Longitude:&nbsp;&nbsp;</label>' + 
    '<input ' + readonly + ' type="text" id="' + p_item_id + '_longitude_degrees" style="width: 10%" class="ui-textfield" size="' + entry_size + '"/>&nbsp;<label for="longitude_degrees">Degrees</label>&nbsp;&nbsp;&nbsp;&nbsp;'+
    '<input ' + readonly + ' type="number" id="' + p_item_id + '_longitude_minutes" style="width: 10%" class="ui-textfield" size="' + entry_size + '"/>&nbsp;<label for="longitude_minutes">Minutes</label>&nbsp;&nbsp;&nbsp;&nbsp;'+
    '<input ' + readonly + ' type="number" id="' + p_item_id + '_longitude_seconds" style="width: 15%" class="ui-textfield" size="' + entry_size + '"/>&nbsp;<label for="longitude_seconds">Seconds</label>&nbsp;&nbsp;&nbsp;&nbsp;'+
    '<br/>' + 
    '<label>Latitude:&nbsp;&nbsp;&nbsp;&nbsp;&thinsp;&thinsp;</label>'+
    '<input ' + readonly + ' type="number" id="' + p_item_id + '_latitude_degrees" style="width: 10%" class="ui-textfield" size="' + entry_size + '"/>&nbsp;<label for="latitude_degrees">Degrees</label>&nbsp;&nbsp;&nbsp;&nbsp;'+
    '<input ' + readonly + ' type="number" id="' + p_item_id + '_latitude_minutes" style="width: 10%"  class="ui-textfield" size="' + entry_size + '"/>&nbsp;<label for="latitude_minutes">Minutes</label>&nbsp;&nbsp;&nbsp;&nbsp;'+
    '<input ' + readonly + ' type="number" id="' + p_item_id + '_latitude_seconds"  style="width: 15%" class="ui-textfield" size="' + entry_size + '"/>&nbsp;<label for="latitude_seconds">Seconds</label>&nbsp;&nbsp;&nbsp;&nbsp;'+
   '</div>';
    apex.jQuery('#' + p_region_id + '_map_region').append($(coordform));
  }
  
  /*
   * call ajax service of the plugin with the input geometry to write it back to the page item and input geometry collection
   * as well know text. Large data is streamed.
   */
  function writeGeometry(geometry) {
    var default_cursor = document.body.style.cursor;
    if (default_cursor == "not-allowed") {
      default_cursor = null;
	  }
    if (!geometry) {
      apex.server.plugin(p_ajax_identifier, {
        x10: "WRITEBACK",
        x02: null,
        x03: null
      }, {
        success: function (pData) {
          document.body.style.cursor = default_cursor;
        },
        error: function (jqxhr, status, err) {
          document.body.style.cursor = default_cursor;
          apex_alert(err);
        }
      });
    } else {
      // this data could be big. Let's stream it back to the server
      // if we are holding it in a collection there. do this through
      // chained ajax calls. use the cursor icon to let user know
      // that data is being transferred.
      function chunk(data, startIndex, bufferLen, successFunc) {
        if (startIndex >= data.length) {
          successFunc();
        } else {
          apex.server.plugin(p_ajax_identifier, {
            x10: "WRITEBACK",
            x02: data.substr(startIndex, bufferLen),
            x03: startIndex
          }, 
          {
            success: function (pData) {
              chunk(data, startIndex + bufferLen, bufferLen, successFunc);
            },
            error: function (jqxhr, status, err) {
              apex_alert(err);
            }
          });
        }
      }
      document.body.style.cursor = "not-allowed";
      chunk(geometry, 0, 30000, function () { 
        // once the write is complete, restore the cursor and trigger an event to be used in APEX.
        document.body.style.cursor = default_cursor; 
        apex.event.trigger(apex.jQuery("#" + p_item_id), "mil_army_usace_mapbits_drawcreate");
      });
    }
  }

  // StaticMode is used when the item is set to read only, 
  // to show a previously drawn geometry, but not to edit it.
  var StaticMode = {};
  StaticMode.onSetup = function() {
    this.setActionableState(); // default actionable state is false for all actions
    return {};
  };
  StaticMode.toDisplayFeatures = function(state, geojson, display) {
    display(geojson);
  };
  var modes = MapboxDraw.modes;
  modes.static = StaticMode;
  
  function isEventAtCoordinates(event, coordinates) {
    if (!event.lngLat) return false;
    return event.lngLat.lng === coordinates[0] && event.lngLat.lat === coordinates[1];
  }
  
  // Override the keyup function on draw_line_string mode of Mapbox draw to respond to the geolocation
  // button click. The geolocation button will initiate a (`) keyup event. 
  modes.draw_line_string.onKeyUp = function(state, e) {
    if (e.keyCode === 13) {
      this.changeMode('simple_select', { featureIds: [state.line.id] });
    } else if (e.keyCode === 27) {
      this.deleteFeature([state.line.id], { silent: true });
      this.changeMode('simple_select');
    } else if(e.key == '`') {
      if (state.currentVertexPosition > 0 && isEventAtCoordinates(e, state.line.coordinates[state.currentVertexPosition - 1]) ||
        state.direction === 'backwards' && isEventAtCoordinates(e, state.line.coordinates[state.currentVertexPosition + 1])) {
        return this.changeMode('simple_select', { featureIds: [state.line.id] });
      }
      this.updateUIClasses({ mouse: 'add' });

      navigator.geolocation.getCurrentPosition(function(pos){
        state.line.updateCoordinate(state.currentVertexPosition, pos.coords.longitude, pos.coords.latitude);      
        if (state.direction === 'forward') {
          state.currentVertexPosition++;
          state.line.updateCoordinate(state.currentVertexPosition, p[0], p[1]);
        } else {
          state.line.addCoordinate(0, p[0], p[1]);
        }
      }, function(err) {
        var p = [-90 + (0.01*Math.random() - 0.005), 30 + (0.01*Math.random() - 0.005)];
        // uncomment this to test in Chrome.
        state.line.updateCoordinate(state.currentVertexPosition, p[0], p[1]);
            
        if (state.direction === 'forward') {
          state.currentVertexPosition++;
          state.line.updateCoordinate(state.currentVertexPosition, p[0], p[1]);
        } else {
          state.line.addCoordinate(0, p[0], p[1]);
        }
      });
    }
  };
  
  modes.draw_polygon.onKeyUp = function(state, e) {
    // handle enter and escape as before
    if (e.keyCode === 27) {
      this.deleteFeature([state.polygon.id], { silent: true });
      this.changeMode('simple_select');
    } else if (e.keyCode === 13) {
      this.changeMode('simple_select', { featureIds: [state.polygon.id] });
    } else if(e.key == '`') {
      if (state.currentVertexPosition > 0 && isEventAtCoordinates(e, state.polygon.coordinates[0][state.currentVertexPosition - 1])) {
        return this.changeMode('simple_select', { featureIds: [state.polygon.id] });
      }
      this.updateUIClasses({ mouse: 'add' });

      navigator.geolocation.getCurrentPosition(function(pos){
        state.polygon.updateCoordinate(`0.${state.currentVertexPosition}`, pos.coords.longitude, pos.coords.latitude);      
        state.currentVertexPosition++;
        state.polygon.updateCoordinate(`0.${state.currentVertexPosition}`, pos.coords.longitude, pos.coords.latitude);
      }, function(err) {
        var p = [-90 + (0.01*Math.random() - 0.005), 30 + (0.01*Math.random() - 0.005)];
        // uncomment this to test in Chrome.
        state.polygon.updateCoordinate(`0.${state.currentVertexPosition}`, p[0], p[1]);
        state.currentVertexPosition++;
        state.polygon.updateCoordinate(`0.${state.currentVertexPosition}`, p[0], p[1]);
      });
    }
  };
  
  //create the draw tool. Point geometry was too small, so I made it larger; Style is copied from mapbox-draw /lib/theme.js with increased point size. 
  map.draw = new MapboxDraw({
    displayControlsDefault: false,
    controls: {
      point: p_geometry_modes.indexOf("POINT") > -1,
      line_string: p_geometry_modes.indexOf("LINE") > -1,
      polygon: p_geometry_modes.indexOf("POLYGON") > -1,
      trash: !p_readonly,
      modes: modes
    }, styles : MAPBITS_DEFAULT_DRAW_STYLES
  });
  if (p_enable_geolocate) {
    map.addControl(geolocate_point_control);
  }
  // load event did not reliably fire. Use first render event instead.
  map.once('render', function() {
  //map.on('load', function() {
    var entry_size = 10;
	  	
    // initialize latitude/longitude data entry fields
    if (p_show_coords) {
      apex.jQuery('#' + p_item_id + '_longitude_degrees').change(syncGeometryFromCoordinates);
      apex.jQuery('#' + p_item_id + '_longitude_minutes').change(syncGeometryFromCoordinates);
      apex.jQuery('#' + p_item_id + '_longitude_seconds').change(syncGeometryFromCoordinates);
      apex.jQuery('#' + p_item_id + '_latitude_degrees').change(syncGeometryFromCoordinates);
      apex.jQuery('#' + p_item_id + '_latitude_minutes').change(syncGeometryFromCoordinates);
      apex.jQuery('#' + p_item_id + '_latitude_seconds').change(syncGeometryFromCoordinates);
    }

    // if there is an initial geometry, add it to the map and pan to it, zoom to it if it's a line or polygon.
    if (p_geometry != null && p_geometry != "") {
      map.draw.add(p_geometry); 
      if (p_geometry.type == "Point") {
        if (p_show_coords) {
          syncCoordsFromGeometry(p_geometry);
        }
		    
        //replaced moveto and setcenter with jumpto to fix problem with first render.
        map.jumpTo({center: p_geometry.coordinates, zoom : p_point_zoom_level, duration: 2000});

      } else {
		    var b = getBounds(p_geometry);
        map.fitBounds(b, {padding: 50});
      }
      
    }
    if (p_readonly) {
      map.draw.changeMode('static');
    }
  });
  map.addControl(map.draw);
  
  // Accomodate both Mapbox in APEX 21 and Maplibre in APEX 22.	
  apex.jQuery('.mapboxgl-ctrl-group').addClass('maplibregl-ctrl-group');
  apex.jQuery('.mapboxgl-ctrl').addClass('maplibregl-ctrl');
  
  map.drawvertices = {id : 7981, type : "Feature", properties : {}, geometry : {type: "LineString", coordinates : []}};
  
  // Handle draw finished event: write geometry 
  // to APEX collection using ajax callback.
  // If the coordinates entry fields are turned on,
  // update them with the new coordinates from the Point 
  // geometry.
  map.on("draw.create", function(e) {
    var feats = map.draw.getAll();
    for(var i=0;i<feats.features.length-1;i++) {
      if (e.features[0].id != feats.features[i].id) {
        map.draw.delete(feats.features[i].id);
      }
    }
    feats = map.draw.getAll();
    var geom = feats.features[0].geometry;
    if (p_show_coords) {
      syncCoordsFromGeometry(geom);
    }
    writeGeometry(JSON.stringify(geom));
  });
  
  map.on("draw.update", function(e) {
    var feats = map.draw.getAll();
    var geom = feats.features[0].geometry;
    if (p_show_coords) {
      syncCoordsFromGeometry(geom);
    }
    writeGeometry(JSON.stringify(geom));
  });
  
  
  function updateGeolocationButtonDisplay(mode, nselectedFeatures) {
    var mode = map.draw.getMode();
    var nselectedFeatures = map.draw.getSelected().features.length;
    if (p_enable_geolocate) {
      if (mode == "direct_select" || mode == "draw_point" || mode == "draw_line_string" || mode == "draw_polygon") {
        geolocate_point_control.getButton().style.display= 'block';
      } else {
        if (mode == 'simple_select') {
          if(nselectedFeatures > 0) {
            geolocate_point_control.getButton().style.display = 'block';
          } else {
            geolocate_point_control.getButton().style.display = 'none';
          }
        }
      }
    }
  }
  
  // If the coordinates entry fields are turned on, show them 
  // when the drawing mode is Point. Otherwise, hide them.
  // Enable Geolocate Point tool button if user is in draw point mode or if the vertex
  // on a non-point geometry is selected.
  map.on("draw.modechange", function(e) {
    if (p_show_coords) {
      if (e.mode == "draw_point") {
        apex.jQuery('#' + p_item_id + '_coords').css('display', 'block');
      } else if (e.mode == "draw_line_string" || e.mode == "draw_polygon") {
        apex.jQuery('#' + p_item_id + '_coords').css('display', 'none');
      }
    }
    updateGeolocationButtonDisplay();
  });
  
   map.on("draw.selectionchange", function(e) {
     updateGeolocationButtonDisplay();
   });
  
  if (p_enable_geolocate) {
    geolocate_point_control.getButton().onclick = function(e) {    
      var mode = map.draw.getMode();    
      function updateFromGeolocation(coordinate) {
        if (mode == 'draw_point') {
          // mode is draw point; set the point location from the geolocator.
          var pt = map.draw.set({type: 'FeatureCollection', features :[{type : "Feature", properties : {}, geometry : {type : "Point", coordinates : coordinate}}]});
          
          // Need to move this somewhere else if possible.
          geolocate_point_control.getButton().style.display = 'none';
        } else if (mode == 'simple_select') {
          if (map.draw.getSelected().features.length > 0) {
            var selectedFeature = map.draw.getSelected().features[0];
            selectedFeature.geometry.coordinates[0] = coordinate[0];
            selectedFeature.geometry.coordinates[1] = coordinate[1];
             map.draw.set({type: "FeatureCollection", features :[selectedFeature]});
          }
        } else if (mode == 'direct_select') {
          // direct select: a vertex of a polygon or linestring is selected. Move
          // the selected vertex to the geolocation coordinate.
          var selectedFeature = map.draw.getSelected().features[0];
          var selectedCoords = map.draw.getSelectedPoints().features[0].geometry.coordinates;
      
          function __setCoord(coordArray) {
            for (var j=0;j<coordArray.length;j++) {
              if (selectedCoords[0] == coordArray[j][0] && selectedCoords[1] == coordArray[j][1]) {
                coordArray[j][0] = coordinate[0];
                coordArray[j][1] = coordinate[1];
              }
            }
          }
          if (selectedFeature.geometry.type == 'LineString') {
            __setCoord(selectedFeature.geometry.coordinates);
          } else if(selectedFeature.geometry.type == 'Polygon') {
            for(var k=0;k<selectedFeature.geometry.coordinates.length;k++) {
              __setCoord(selectedFeature.geometry.coordinates[k]);
            }
          }
          map.draw.set({type: "FeatureCollection", features :[selectedFeature]});
        }
      } //end function

      if (mode == 'draw_point' || mode == 'direct_select' || mode == 'simple_select') {
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(function(pos){
            updateFromGeolocation([pos.coords.longitude, pos.coords.latitude]);
            
          }, function(err) {
            // uncomment this to test in Chrome.
            updateFromGeolocation([-90 + (0.01*Math.random() - 0.005), 30 + (0.01*Math.random() - 0.005)]);
          });
        } else {
          apex_alert('Geolocation not supported.');
        }
      } else if(mode == 'draw_line_string' || mode == 'draw_polygon') {
        map.getContainer().dispatchEvent(new KeyboardEvent('keyup',{'key': '`'}));
      }
    };
  }
  
}