prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2023.10.31'
,p_release=>'23.2.0'
,p_default_workspace_id=>2612926235066099
,p_default_application_id=>107981
,p_default_id_offset=>197864740331967674
,p_default_owner=>'MVDGIS'
);
end;
/
 
prompt APPLICATION 107981 - Mapbits Demo
--
-- Application Export:
--   Application:     107981
--   Name:            Mapbits Demo
--   Date and Time:   16:17 Tuesday January 28, 2025
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 2097648210592940579
--   Manifest End
--   Version:         23.2.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_draw
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(2097648210592940579)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.DRAW'
,p_display_name=>'Mapbits Drawing'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#mapbox-gl-draw.js',
'#PLUGIN_FILES#lonlat.js',
'#PLUGIN_FILES#mapbits-draw-style.js',
'#PLUGIN_FILES#mapbits-draw.js'))
,p_css_file_urls=>'#PLUGIN_FILES#mapbox-gl-draw.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure map_drawing_render_ajax (',
'    p_item   in            apex_plugin.t_item,',
'    p_plugin in            apex_plugin.t_plugin,',
'    p_param  in            apex_plugin.t_item_ajax_param,',
'    p_result in out nocopy apex_plugin.t_item_ajax_result ) is',
'    l_geom_collection_name p_item.attribute_02%type;',
'    l_geomtxt clob;',
'    l_buffer_clob clob;',
'    l_chunk_no number;',
'begin',
'  if apex_application.g_x10 = ''WRITEBACK'' then',
'   l_geom_collection_name := p_item.attribute_02;',
'   if not l_geom_collection_name is null then',
'     l_geomtxt := apex_application.g_x02;',
'     l_chunk_no := apex_application.g_x03;',
'',
'     if l_chunk_no is null or l_chunk_no = 0 then',
'       apex_collection.create_or_truncate_collection(p_collection_name => l_geom_collection_name);',
'       apex_collection.add_member(p_collection_name => l_geom_collection_name,  p_clob001 => l_geomtxt);',
'     else',
'       dbms_lob.createtemporary(l_buffer_clob, TRUE);',
'       select clob001 into l_buffer_clob from apex_collections where collection_name = l_geom_collection_name and seq_id = 1;',
'       l_buffer_clob := l_buffer_clob || l_geomtxt;',
'       apex_collection.update_member(p_collection_name => l_geom_collection_name, p_seq =>1, p_clob001 => l_buffer_clob );',
'       dbms_lob.freetemporary(l_buffer_clob);',
'     end if;',
'     htp.p(''{"Status" : "No Error"}'');',
'   else',
'     htp.p(''{"Status" : "[XYZZY] No Geometry Collection Name specified. Nothing happens."}'');',
'   end if;',
' end if; ',
'end;',
'',
'procedure map_drawing_render (',
'    p_item   in            apex_plugin.t_item,',
'    p_plugin in            apex_plugin.t_plugin,',
'    p_param  in            apex_plugin.t_item_render_param,',
'    p_result in out nocopy apex_plugin.t_item_render_result ) is',
'    l_region_id varchar2(400);',
'    l_geometry_modes p_item.attribute_01%type := p_item.attribute_01;',
'    l_geom_collection_name p_item.attribute_02%type := p_item.attribute_02;',
'    l_readonly varchar2(5);',
'    l_geojson clob;',
'    l_show_coords varchar2(5);  ',
'    l_enable_geo varchar2(5);',
'    l_buffersize number:=80;',
'    l_offset integer;',
'    l_pointZoomLevel p_item.attribute_06%type := nvl(p_item.attribute_06, 12);',
'begin',
'  -- Read-only attribute',
'  if not p_item.attribute_05 is null then',
'    if V(p_item.attribute_05)  = ''Y'' then',
'      l_readonly := ''true'';',
'    else',
'      l_readonly := ''false'';',
'    end if;',
'  else',
'    l_readonly := ''false'';',
'  end if;',
'  if l_readonly = ''true'' then',
'    l_geometry_modes := ''NONE'';',
'  end if;',
'',
'  -- Show Coordinates attribute',
'  if not p_item.attribute_04 is null then',
'    if p_item.attribute_04  = ''Y'' then',
'      l_show_coords := ''true'';',
'    else',
'      l_show_coords := ''false'';',
'    end if;',
'  else',
'    l_show_coords := ''false'';',
'  end if;',
'',
'  -- Enable Geolocation attribute',
'  if not p_item.attribute_03 is null then',
'    if p_item.attribute_03  = ''Y'' then',
'      l_enable_geo := ''true'';',
'    else',
'      l_enable_geo := ''false'';',
'    end if;',
'  else',
'    l_enable_geo := ''false'';',
'  end if;',
'',
'  -- Collection name attribute',
'  begin',
'    select clob001  into l_geojson from apex_collections where collection_name = l_geom_collection_name;',
'  exception when NO_DATA_FOUND then',
'      l_geojson := ''null'';',
'  end;',
'  if l_geojson is null then',
'    l_geojson := ''null'';',
'  end if;',
'',
'  -- Get the map region id for which this item is associated. If this failed, propagate an error.',
'  begin',
'    select nvl(r.static_id, ''R'' || r.region_id) into l_region_id  ',
'      from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception when NO_DATA_FOUND then',
'    raise_application_error(-20351, ''Configuration ERROR: Mapbits Drawing Item ['' || p_item.name || ''] is not associated with a Map region.'');',
'  end;',
'  htp.p(''<div id="'' || p_item.name || ''" name="'' || p_item.name || ''"></div>'');',
'  htp.prn(''<script>var l_drawingClob_'' || l_region_id || '' = '');',
'    l_offset := 1;',
'    loop',
'      exit when l_offset >=nvl(dbms_lob.getlength(l_geojson), 0);',
'      htp.prn(dbms_lob.substr(l_geojson, l_buffersize, l_offset));',
'      l_offset := l_offset + l_buffersize;',
'    end loop;  ',
'  htp.prn('';</script>'');',
'',
'  -- Call the javascript. Delay load by a fraction of a second to allow other layers to load. This should',
'  -- prevent other layers from loading on top of the drawing feature.',
'  apex_javascript.add_onload_code(p_code => ''',
'    apex.jQuery('' || l_region_id || '').on("spatialmapinitialized", () => {',
'      mapbits_draw({''',
'        || apex_javascript.add_attribute(''p_item_id'', p_item.name)',
'        || apex_javascript.add_attribute(''p_ajax_identifier'', apex_plugin.get_ajax_identifier)',
'        || apex_javascript.add_attribute(''p_region_id'', l_region_id)',
'        || ''"p_geometry": l_drawingClob_'' || l_region_id || '',''',
'        || apex_javascript.add_attribute(''geometry_modes'', l_geometry_modes)',
'        || apex_javascript.add_attribute(''readonly'', l_readonly = ''true'')',
'        || apex_javascript.add_attribute(''show_coords'', l_show_coords = ''true'')',
'        || apex_javascript.add_attribute(''enable_geolocate'', l_enable_geo = ''true'')',
'        || apex_javascript.add_attribute(''point_zoom_level'', to_number(l_pointZoomLevel))',
'        || apex_javascript.add_attribute(''writeback_enabled'', l_geom_collection_name is not null)',
'      || ''});',
'    });',
'  '');',
'end;',
'',
'procedure map_drawing_validate (',
'    p_item   in            apex_plugin.t_item,',
'    p_plugin in            apex_plugin.t_plugin,',
'    p_param  in            apex_plugin.t_item_validation_param,',
'    p_result in out nocopy apex_plugin.t_item_validation_result ) is',
'    l_geom_collection_name p_item.attribute_02%type;',
'    l_geom sdo_geometry;',
'    rt varchar2(4000);',
'begin',
'  l_geom_collection_name := p_item.attribute_02;',
'  select sdo_util.from_geojson(clob001) into l_geom from apex_collections where collection_name = l_geom_collection_name;',
'  rt := sdo_geom.validate_geometry_with_context(l_geom, 0.001, ''FALSE'', ''TRUE'');',
'  if not rt = ''TRUE'' then',
'    p_result.message := rt;',
'  end if;',
'end;'))
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'map_drawing_render'
,p_ajax_function=>'map_drawing_render_ajax'
,p_validation_function=>'map_drawing_validate'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The Mapbits Drawing Page Item adds point, line, and/or polygon drawing tools to the Application Express native Map Region. Geometry data in geojson format can be loaded into and saved from the Map Region using an APEX Collection. The intended usag'
||'e pattern is to create the apex collection in a pre-rendering process and add the value of an existing geometry (if one exists) to that clob column of the collection in geojson format. Each time the geometry is edited in the Map, it is written back t'
||'o the collection. A plsql process should be written to run on page submission to read from the collection and convert the geometry from a geojson clob to sdo_geometry, writing the geometry to the record begin processed by the page submission.</p>',
'',
'<p>',
'If geolocation is enabled and available in the browser, then the user can click a tool button to create and move point features, add vertices to a new line/polygon, or move selected line/polygon vertices based on geolocation (GPS).',
'</p>',
'',
'<p>Mapbits Drawing is implemented using the mapbox-gl-draw library. For more information, review the map-gl-draw Github site (<a href="https://github.com/mapbox/mapbox-gl-draw">https://github.com/mapbox/mapbox-gl-draw</a>).<p>'))
,p_version_identifier=>'4.8.20250128'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Draw',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_draw.sql 20090 2025-01-28 22:41:13Z b2eddjw9 $',
'Date     : $Date: 2025-01-28 16:41:13 -0600 (Tue, 28 Jan 2025) $',
'Revision : $Revision: 20090 $',
'Requires : Application Express >= 21.1',
'',
'01/27/2024 Fix bug where the point would appear on the map before both lat/lon were entered.',
'01/27/2024 Fix bug where pressing Enter in the lat/lon entry could cause the entry to disappear.',
'06/24/2024 Add item API with setGeometry() method.',
'10/01/2024 Add white outline for read-only points',
'',
'Version 4.6 Updates:',
'03/14/2024 Existing feature geometry was not displaying in map in read-only mode in version 22 and 23. APEX ignores empty values in apex_javascript.add_attribute calls. ',
'Trapping errors from call to the map''s jumpTo. It fails on the first run in version 23. Seems to work for now.',
'02/07/2024 Don''t make writeback requests when the geometry collection is blank.',
'Raise an application error if this plugin item is not associated with a Map region.',
'',
'Version 4.5 Updates:',
'7/14/2023 Moved back code that ensures mapbox and maplibre classes are applied to the control to after the control is added to the map.',
'7/13/2023 Removed use of the ''render'' event to wait for a ready map. This does not appear to be necessary since the spatialmapinitialized event is already at the javascript entry point. Using maplibregl package for Lat/Lon bounds class if mapboxgl do'
||'es not exist, which it will for version 22 and later of APEX.',
'',
'Version 4.4 Updates:',
'6/6/2023 Removed p_key => ''MIL.ARMY.USACE.MAPBITS.DRAW'' argument from call to apex_javascript.add_onload_code. This will separate drawing items for multiple map regions on the same page.',
'5/10/2023 Removed unneeded library, mapbits-restgjslayer.js.',
'4/12/2023 Delay load by a fraction of a second to allow other layers to load. This should prevent other layers from loading on top of the drawing feature. ',
'',
'Version 4.3 Updates:',
'1/27/2023 To work with APEX 22.2, changed event hook to the map region''s spatialmapinitialized event in place of the page''s apexreadyend event.',
'12/19/2022 Added missing getbounds function.',
'8/13/2022 Modified to work with both mapbox and maplibre.',
'8/13/2022 Using mapbox-draw-gl version 1.2.2.',
'',
'Version 4.2 Updates:',
'3/16/2022 Added full geolocation capabilities. Moved the style definition to a separate javascript file.',
'3/10/2022 Added capabilities to set point features and move line/polygon vertices based on geolocation.',
'2/14/2022 Removed unused javascript file.',
'1/31/2022 Replaced zoom and setcenter with easeTo to fix initial render.'))
,p_files_version=>128
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(2097651010000253454)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Available Geometry Types'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'POINT'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Choose whether to add point, line, or polygon tools to the Map region.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(2097651914776254267)
,p_plugin_attribute_id=>wwv_flow_imp.id(2097651010000253454)
,p_display_sequence=>10
,p_display_value=>'Point'
,p_return_value=>'POINT'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(2097652363873254898)
,p_plugin_attribute_id=>wwv_flow_imp.id(2097651010000253454)
,p_display_sequence=>20
,p_display_value=>'Line'
,p_return_value=>'LINE'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(2097652716001255670)
,p_plugin_attribute_id=>wwv_flow_imp.id(2097651010000253454)
,p_display_sequence=>30
,p_display_value=>'Polygon'
,p_return_value=>'POLYGON'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(2085213103264231213)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Geometry Collection Name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'GEOMETRY_COLLECTION',
'',
'where GEOMETRY_COLLECTION is created by',
'',
'apex_collection.create_or_truncate_collection(p_collection_name => ''GEOMETRY_COLLECTION'');',
'apex_collection.add_member(p_collection_name => ''GEOMETRY_COLLECTION'', p_clob001 =>  ''"type": "Point", "coordinates": [-90.112, 30.091]}'');'))
,p_help_text=>'Name of the APEX Collection from which to read and write the drawing geometry. This geometry is stored in the clob001 column in geojson geometry format.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1984169996881699385)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>90
,p_prompt=>'Enable Geolocation'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'If enabled, a geolocation tool button will appear when the draw control is in edit mode or if a line or polygon vertex is selected. Clicking the button will create a point (for draw point mode), add a vertex (in draw line and draw polygon mode) or mo'
||'ve a selected vertex point to the geolocation-determined coordinate.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(2083580831424046589)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Show Coordinates for Point Text Entry'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'If enabled, a region showing the point coordinates as numerical degrees, minutes, and seconds will appear below the map region. This region will only be visible for point drawing geometries. If the draw tool is in line or polygon edit mode, then this'
||' region will be hidden.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(2083587404716443696)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Read Only Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'If the selected Page Item evaluates to ''Y'' then the Drawing Tools are set up and rendered in Read-only mode with no controls or ability to modify the geometry. Otherwise, set up and render the drawing tools as normal.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(2062519992268911047)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Default Point Zoom Level'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'12'
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'0	The Earth',
'3	A continent',
'4	Large islands',
'6	Large rivers',
'10	Large roads',
'15	Buildings'))
,p_help_text=>'If the drawing tools has an initial point geometry, this attribute setting will define how to set the zoom level. This does not apply to initial line or polygon geometries, since the zoom level will be set based on the geometry bounding box in those '
||'cases. The value should be set between 0 and 24. Higher values show more detail in a smaller area, while lower values show a wider area with less detail.'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(2098622823920934182)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_name=>'mil_army_usace_mapbits_drawcreate'
,p_display_name=>'Draw / Create'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F64726177287B705F6974656D5F69643A652C705F616A61785F6964656E7469666965723A742C705F726567696F6E5F69643A6E2C705F67656F6D657472793A6F2C2E2E2E697D297B76617220723D22756E6465';
wwv_flow_imp.g_varchar2_table(2) := '66696E6564223D3D747970656F66206D61706C69627265676C3F6D6170626F78676C3A6D61706C69627265676C3B66756E6374696F6E20612865297B617065782E6A5175657279282866756E6374696F6E28297B617065782E6D6573736167652E616C65';
wwv_flow_imp.g_varchar2_table(3) := '72742865292C636F6E736F6C652E6C6F672822616C65727420222B65297D29297D76617220733D692E67656F6D657472795F6D6F6465732C6C3D692E726561646F6E6C792C643D692E73686F775F636F6F7264732C753D692E706F696E745F7A6F6F6D5F';
wwv_flow_imp.g_varchar2_table(4) := '6C6576656C2C633D692E656E61626C655F67656F6C6F636174653B66756E6374696F6E206728297B7D672E70726F746F747970652E6F6E4164643D66756E6374696F6E2865297B72657475726E20746869732E6D5F6D61703D652C746869732E6D5F636F';
wwv_flow_imp.g_varchar2_table(5) := '6E7461696E65723D646F63756D656E742E637265617465456C656D656E74282264697622292C746869732E67656F6C6F636174655F706F696E745F627574746F6E3D646F63756D656E742E637265617465456C656D656E742822627574746F6E22292C74';
wwv_flow_imp.g_varchar2_table(6) := '6869732E67656F6C6F636174655F706F696E745F627574746F6E2E7374796C653D226C696E652D6865696768743A313670783B77696474683A333270783B6865696768743A333270783B646973706C61793A6E6F6E653B222C746869732E67656F6C6F63';
wwv_flow_imp.g_varchar2_table(7) := '6174655F706F696E745F627574746F6E2E696E6E657248544D4C3D273C6920636C6173733D2266612066612D6C6F636174696F6E2D636972636C65223E3C2F693E272C746869732E67656F6C6F636174655F706F696E745F627574746F6E2E747970653D';
wwv_flow_imp.g_varchar2_table(8) := '22627574746F6E222C746869732E6D5F636F6E7461696E65722E617070656E644368696C6428746869732E67656F6C6F636174655F706F696E745F627574746F6E292C746869732E6D5F636F6E7461696E65722E636C6173734E616D653D226D6170626F';
wwv_flow_imp.g_varchar2_table(9) := '78676C2D6374726C206D61706C69627265676C2D6374726C222C746869732E6D5F636F6E7461696E65727D2C672E70726F746F747970652E6F6E52656D6F76653D66756E6374696F6E28297B746869732E6D5F636F6E7461696E65722E706172656E744E';
wwv_flow_imp.g_varchar2_table(10) := '6F64652E72656D6F76654368696C6428746869732E6D5F636F6E7461696E6572292C746869732E6D5F6D61703D766F696420307D2C672E70726F746F747970652E676574427574746F6E3D66756E6374696F6E28297B72657475726E20746869732E6765';
wwv_flow_imp.g_varchar2_table(11) := '6F6C6F636174655F706F696E745F627574746F6E7D3B766172205F3D6E657720673B66756E6374696F6E207928297B76617220743D6765745F646563696D616C5F6465677265657328617065782E6A5175657279282223222B652B225F6C6F6E67697475';
wwv_flow_imp.g_varchar2_table(12) := '64655F6465677265657322292E76616C28292C617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6D696E7574657322292E76616C28292C617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F7365636F6E';
wwv_flow_imp.g_varchar2_table(13) := '647322292E76616C2829292C6E3D6765745F646563696D616C5F6465677265657328617065782E6A5175657279282223222B652B225F6C617469747564655F6465677265657322292E76616C28292C617065782E6A5175657279282223222B652B225F6C';
wwv_flow_imp.g_varchar2_table(14) := '617469747564655F6D696E7574657322292E76616C28292C617065782E6A5175657279282223222B652B225F6C617469747564655F7365636F6E647322292E76616C2829293B69662869734E614E287429262628743D6765745F646563696D616C5F6465';
wwv_flow_imp.g_varchar2_table(15) := '677265657328617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6465677265657322292E76616C28292C617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6D696E7574657322292E76616C28292C3029';
wwv_flow_imp.g_varchar2_table(16) := '2C69734E614E287429262628743D6765745F646563696D616C5F6465677265657328617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6465677265657322292E76616C28292C302C302929292C69734E614E286E292626286E3D';
wwv_flow_imp.g_varchar2_table(17) := '6765745F646563696D616C5F6465677265657328617065782E6A5175657279282223222B652B225F6C617469747564655F6465677265657322292E76616C28292C617065782E6A5175657279282223222B652B225F6C617469747564655F6D696E757465';
wwv_flow_imp.g_varchar2_table(18) := '7322292E76616C28292C30292C69734E614E286E292626286E3D6765745F646563696D616C5F6465677265657328617065782E6A5175657279282223222B652B225F6C617469747564655F6465677265657322292E76616C28292C302C302929292C2169';
wwv_flow_imp.g_varchar2_table(19) := '734E614E28742926262169734E614E286E29297B766172206F3D622E647261772E676574416C6C28293B303D3D6F2E66656174757265732E6C656E67746826266F2E66656174757265732E70757368287B747970653A2246656174757265222C70726F70';
wwv_flow_imp.g_varchar2_table(20) := '6572746965733A7B7D2C67656F6D657472793A7B636F6F7264696E617465733A5B6E756C6C2C6E756C6C5D7D7D292C6F2E66656174757265735B305D2E67656F6D657472792E747970653D22506F696E74222C6F2E66656174757265735B305D2E67656F';
wwv_flow_imp.g_varchar2_table(21) := '6D657472792E636F6F7264696E617465735B305D3D742C6F2E66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465735B315D3D6E2C622E647261772E736574286F293B76617220693D622E647261772E676574416C6C28292E66';
wwv_flow_imp.g_varchar2_table(22) := '656174757265735B305D2E67656F6D657472793B6A284A534F4E2E737472696E67696679286929292C622E70616E546F28692E636F6F7264696E61746573297D7D66756E6374696F6E206D2874297B6966282128742E636F6F7264696E617465732E6C65';
wwv_flow_imp.g_varchar2_table(23) := '6E6774683C3129262622506F696E74223D3D742E74797065297B766172206E3D742E636F6F7264696E617465735B305D2C6F3D742E636F6F7264696E617465735B315D3B617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6465';
wwv_flow_imp.g_varchar2_table(24) := '677265657322292E76616C286765745F64656772656573286E29292C617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6D696E7574657322292E76616C286765745F6D696E75746573286E29292C617065782E6A517565727928';
wwv_flow_imp.g_varchar2_table(25) := '2223222B652B225F6C6F6E6769747564655F7365636F6E647322292E76616C286765745F7365636F6E6473286E29292C617065782E6A5175657279282223222B652B225F6C617469747564655F6465677265657322292E76616C286765745F6465677265';
wwv_flow_imp.g_varchar2_table(26) := '6573286F29292C617065782E6A5175657279282223222B652B225F6C617469747564655F6D696E7574657322292E76616C286765745F6D696E75746573286F29292C617065782E6A5175657279282223222B652B225F6C617469747564655F7365636F6E';
wwv_flow_imp.g_varchar2_table(27) := '647322292E76616C286765745F7365636F6E6473286F29297D7D76617220623D617065782E726567696F6E286E292E63616C6C28226765744D61704F626A65637422292C663D31302C783D617065782E6A5175657279282223222B6E2B225F6D61705F72';
wwv_flow_imp.g_varchar2_table(28) := '6567696F6E22292E6373732822776964746822292C683D226E6F6E65222C773D22223B6966286C262628773D22726561646F6E6C7922292C64297B6E756C6C213D6F3F22506F696E74223D3D6F2E74797065262628683D22626C6F636B22293A732E696E';
wwv_flow_imp.g_varchar2_table(29) := '6465784F662822504F494E5422293E2D31262628683D22626C6F636B22293B76617220763D273C7374796C653E406D6564696120286D696E2D77696474683A20333572656D29207B2E6D622D6C6F6E3A3A6265666F7265207B636F6E74656E74203A2022';
wwv_flow_imp.g_varchar2_table(30) := '4C6F6E6769747564653A223B7D202E6D622D6C61743A3A6265666F7265207B636F6E74656E74203A20224C617469747564653A223B7D202E6D622D6C6162656C2D6465673A3A6166746572207B636F6E74656E74203A202244656772656573223B7D202E';
wwv_flow_imp.g_varchar2_table(31) := '6D622D6C6162656C2D6D696E3A3A6166746572207B636F6E74656E74203A20224D696E75746573223B7D202E6D622D6C6162656C2D7365633A3A6166746572207B636F6E74656E74203A20225365636F6E6473223B7D7D406D6564696120286D61782D77';
wwv_flow_imp.g_varchar2_table(32) := '696474683A20333572656D29207B2E6D622D737063207B646973706C61793A206E6F6E653B7D202E6D622D6C6F6E3A3A6265666F7265207B636F6E74656E74203A20224C6F6E20223B7D202E6D622D6C61743A3A6265666F7265207B636F6E74656E7420';
wwv_flow_imp.g_varchar2_table(33) := '3A20224C617420223B7D202E6D622D6C6162656C2D6465673A3A6166746572207B636F6E74656E74203A2022C2B0223B7D20202E6D622D6C6162656C2D6D696E3A3A6166746572207B636F6E74656E74203A20225C27223B7D202E6D622D6C6162656C2D';
wwv_flow_imp.g_varchar2_table(34) := '7365633A3A6166746572207B636F6E74656E74203A20225C5C22223B7D7D3C2F7374796C653E3C64697620616C69676E3D226C656674222069643D22272B652B275F636F6F7264732220636C6173733D2275692D7769646765742D68656164657220742D';
wwv_flow_imp.g_varchar2_table(35) := '526567696F6E2D6865616465722075692D636F726E65722D616C6C22207374796C653D22646973706C61793A272B682B223B77696474683A222B782B2770783B2070616464696E673A203470782030707820327078203470783B20666C6F61743A6C6566';
wwv_flow_imp.g_varchar2_table(36) := '743B206D617267696E3A303B223E3C6C6162656C20636C6173733D226D622D6C6F6E223E266E6273703B266E6273703B3C2F6C6162656C3E3C696E70757420272B772B2720747970653D226E756D626572222069643D22272B652B275F6C6F6E67697475';
wwv_flow_imp.g_varchar2_table(37) := '64655F6465677265657322207374796C653D2277696474683A203130252220636C6173733D2275692D746578746669656C64222073697A653D22272B662B27222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D6465672220';
wwv_flow_imp.g_varchar2_table(38) := '666F723D226C6F6E6769747564655F64656772656573223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B3C696E70757420272B772B2720747970653D226E756D626572222069643D22272B652B275F6C6F6E67697475';
wwv_flow_imp.g_varchar2_table(39) := '64655F6D696E7574657322207374796C653D2277696474683A203130252220636C6173733D2275692D746578746669656C64222073697A653D22272B662B27222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D6D696E2220';
wwv_flow_imp.g_varchar2_table(40) := '666F723D226C6F6E6769747564655F6D696E75746573223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B3C696E70757420272B772B2720747970653D226E756D626572222069643D22272B652B275F6C6F6E67697475';
wwv_flow_imp.g_varchar2_table(41) := '64655F7365636F6E647322207374796C653D2277696474683A203135252220636C6173733D2275692D746578746669656C64222073697A653D22272B662B27222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D7365632220';
wwv_flow_imp.g_varchar2_table(42) := '666F723D226C6F6E6769747564655F7365636F6E6473223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B3C62722F3E3C6C6162656C2020636C6173733D226D622D6C6174223E266E6273703B266E6273703B3C737061';
wwv_flow_imp.g_varchar2_table(43) := '6E20636C6173733D226D622D737063223E266E6273703B266E6273703B3C2F7370616E3E267468696E73703B267468696E73703B3C2F6C6162656C3E3C696E70757420272B772B2720747970653D226E756D626572222069643D22272B652B275F6C6174';
wwv_flow_imp.g_varchar2_table(44) := '69747564655F6465677265657322207374796C653D2277696474683A203130252220636C6173733D2275692D746578746669656C64222073697A653D22272B662B27222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D6465';
wwv_flow_imp.g_varchar2_table(45) := '672220666F723D226C617469747564655F64656772656573223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B3C696E70757420272B772B2720747970653D226E756D626572222069643D22272B652B275F6C61746974';
wwv_flow_imp.g_varchar2_table(46) := '7564655F6D696E7574657322207374796C653D2277696474683A20313025222020636C6173733D2275692D746578746669656C64222073697A653D22272B662B27222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D6D696E';
wwv_flow_imp.g_varchar2_table(47) := '2220666F723D226C617469747564655F6D696E75746573223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B3C696E70757420272B772B2720747970653D226E756D626572222069643D22272B652B275F6C6174697475';
wwv_flow_imp.g_varchar2_table(48) := '64655F7365636F6E64732220207374796C653D2277696474683A203135252220636C6173733D2275692D746578746669656C64222073697A653D22272B662B27222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D73656322';
wwv_flow_imp.g_varchar2_table(49) := '20666F723D226C617469747564655F7365636F6E6473223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B3C2F6469763E273B617065782E6A5175657279282223222B6E2B225F6D61705F726567696F6E22292E617070';
wwv_flow_imp.g_varchar2_table(50) := '656E642824287629297D66756E6374696F6E206A286E297B696628692E77726974656261636B5F656E61626C6564297B766172206F3D646F63756D656E742E626F64792E7374796C652E637572736F723B696628226E6F742D616C6C6F776564223D3D6F';
wwv_flow_imp.g_varchar2_table(51) := '2626286F3D6E756C6C292C6E297B646F63756D656E742E626F64792E7374796C652E637572736F723D226E6F742D616C6C6F776564222C66756E6374696F6E2065286E2C6F2C692C72297B6F3E3D6E2E6C656E6774683F7228293A617065782E73657276';
wwv_flow_imp.g_varchar2_table(52) := '65722E706C7567696E28742C7B7831303A2257524954454241434B222C7830323A6E2E737562737472286F2C69292C7830333A6F7D2C7B737563636573733A66756E6374696F6E2874297B65286E2C6F2B692C692C72297D2C6572726F723A66756E6374';
wwv_flow_imp.g_varchar2_table(53) := '696F6E28652C742C6E297B61286E297D7D297D286E2C302C3365342C2866756E6374696F6E28297B646F63756D656E742E626F64792E7374796C652E637572736F723D6F2C617065782E6576656E742E7472696767657228617065782E6A517565727928';
wwv_flow_imp.g_varchar2_table(54) := '2223222B65292C226D696C5F61726D795F75736163655F6D6170626974735F6472617763726561746522297D29297D656C736520617065782E7365727665722E706C7567696E28742C7B7831303A2257524954454241434B222C7830323A6E756C6C2C78';
wwv_flow_imp.g_varchar2_table(55) := '30333A6E756C6C7D2C7B737563636573733A66756E6374696F6E2865297B646F63756D656E742E626F64792E7374796C652E637572736F723D6F7D2C6572726F723A66756E6374696F6E28652C742C6E297B646F63756D656E742E626F64792E7374796C';
wwv_flow_imp.g_varchar2_table(56) := '652E637572736F723D6F2C61286E297D7D297D656C736520617065782E6576656E742E7472696767657228617065782E6A5175657279282223222B65292C226D696C5F61726D795F75736163655F6D6170626974735F6472617763726561746522297D76';
wwv_flow_imp.g_varchar2_table(57) := '617220433D7B6F6E53657475703A66756E6374696F6E28297B72657475726E20746869732E736574416374696F6E61626C65537461746528292C7B7D7D2C746F446973706C617946656174757265733A66756E6374696F6E28652C742C6E297B6E287429';
wwv_flow_imp.g_varchar2_table(58) := '7D7D2C503D4D6170626F78447261772E6D6F6465733B66756E6374696F6E205128652C74297B72657475726E2121652E6C6E674C6174262628652E6C6E674C61742E6C6E673D3D3D745B305D2626652E6C6E674C61742E6C61743D3D3D745B315D297D50';
wwv_flow_imp.g_varchar2_table(59) := '2E7374617469633D432C502E647261775F6C696E655F737472696E672E6F6E4B657955703D66756E6374696F6E28652C74297B69662831333D3D3D742E6B6579436F646529746869732E6368616E67654D6F6465282273696D706C655F73656C65637422';
wwv_flow_imp.g_varchar2_table(60) := '2C7B666561747572654964733A5B652E6C696E652E69645D7D293B656C73652069662832373D3D3D742E6B6579436F646529746869732E64656C65746546656174757265285B652E6C696E652E69645D2C7B73696C656E743A21307D292C746869732E63';
wwv_flow_imp.g_varchar2_table(61) := '68616E67654D6F6465282273696D706C655F73656C65637422293B656C7365206966282260223D3D742E6B6579297B696628652E63757272656E74566572746578506F736974696F6E3E3026265128742C652E6C696E652E636F6F7264696E617465735B';
wwv_flow_imp.g_varchar2_table(62) := '652E63757272656E74566572746578506F736974696F6E2D315D297C7C226261636B7761726473223D3D3D652E646972656374696F6E26265128742C652E6C696E652E636F6F7264696E617465735B652E63757272656E74566572746578506F73697469';
wwv_flow_imp.g_varchar2_table(63) := '6F6E2B315D292972657475726E20746869732E6368616E67654D6F6465282273696D706C655F73656C656374222C7B666561747572654964733A5B652E6C696E652E69645D7D293B746869732E7570646174655549436C6173736573287B6D6F7573653A';
wwv_flow_imp.g_varchar2_table(64) := '22616464227D292C6E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E282866756E6374696F6E2874297B652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E745665727465';
wwv_flow_imp.g_varchar2_table(65) := '78506F736974696F6E2C742E636F6F7264732E6C6F6E6769747564652C742E636F6F7264732E6C61746974756465292C22666F7277617264223D3D3D652E646972656374696F6E3F28652E63757272656E74566572746578506F736974696F6E2B2B2C65';
wwv_flow_imp.g_varchar2_table(66) := '2E6C696E652E757064617465436F6F7264696E61746528652E63757272656E74566572746578506F736974696F6E2C705B305D2C705B315D29293A652E6C696E652E616464436F6F7264696E61746528302C705B305D2C705B315D297D292C2866756E63';
wwv_flow_imp.g_varchar2_table(67) := '74696F6E2874297B766172206E3D5B2E30312A4D6174682E72616E646F6D28292D2E3030352D39302C2E30312A4D6174682E72616E646F6D28292D2E3030352B33305D3B652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E';
wwv_flow_imp.g_varchar2_table(68) := '74566572746578506F736974696F6E2C6E5B305D2C6E5B315D292C22666F7277617264223D3D3D652E646972656374696F6E3F28652E63757272656E74566572746578506F736974696F6E2B2B2C652E6C696E652E757064617465436F6F7264696E6174';
wwv_flow_imp.g_varchar2_table(69) := '6528652E63757272656E74566572746578506F736974696F6E2C6E5B305D2C6E5B315D29293A652E6C696E652E616464436F6F7264696E61746528302C6E5B305D2C6E5B315D297D29297D7D2C502E647261775F706F6C79676F6E2E6F6E4B657955703D';
wwv_flow_imp.g_varchar2_table(70) := '66756E6374696F6E28652C74297B69662832373D3D3D742E6B6579436F646529746869732E64656C65746546656174757265285B652E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F6465282273696D70';
wwv_flow_imp.g_varchar2_table(71) := '6C655F73656C65637422293B656C73652069662831333D3D3D742E6B6579436F646529746869732E6368616E67654D6F6465282273696D706C655F73656C656374222C7B666561747572654964733A5B652E706F6C79676F6E2E69645D7D293B656C7365';
wwv_flow_imp.g_varchar2_table(72) := '206966282260223D3D742E6B6579297B696628652E63757272656E74566572746578506F736974696F6E3E3026265128742C652E706F6C79676F6E2E636F6F7264696E617465735B305D5B652E63757272656E74566572746578506F736974696F6E2D31';
wwv_flow_imp.g_varchar2_table(73) := '5D292972657475726E20746869732E6368616E67654D6F6465282273696D706C655F73656C656374222C7B666561747572654964733A5B652E706F6C79676F6E2E69645D7D293B746869732E7570646174655549436C6173736573287B6D6F7573653A22';
wwv_flow_imp.g_varchar2_table(74) := '616464227D292C6E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E282866756E6374696F6E2874297B652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E6375727265';
wwv_flow_imp.g_varchar2_table(75) := '6E74566572746578506F736974696F6E7D602C742E636F6F7264732E6C6F6E6769747564652C742E636F6F7264732E6C61746974756465292C652E63757272656E74566572746578506F736974696F6E2B2B2C652E706F6C79676F6E2E75706461746543';
wwv_flow_imp.g_varchar2_table(76) := '6F6F7264696E6174652860302E247B652E63757272656E74566572746578506F736974696F6E7D602C742E636F6F7264732E6C6F6E6769747564652C742E636F6F7264732E6C61746974756465297D292C2866756E6374696F6E2874297B766172206E3D';
wwv_flow_imp.g_varchar2_table(77) := '5B2E30312A4D6174682E72616E646F6D28292D2E3030352D39302C2E30312A4D6174682E72616E646F6D28292D2E3030352B33305D3B652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E745665727465';
wwv_flow_imp.g_varchar2_table(78) := '78506F736974696F6E7D602C6E5B305D2C6E5B315D292C652E63757272656E74566572746578506F736974696F6E2B2B2C652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F7369';
wwv_flow_imp.g_varchar2_table(79) := '74696F6E7D602C6E5B305D2C6E5B315D297D29297D7D2C622E647261773D6E6577204D6170626F7844726177287B646973706C6179436F6E74726F6C7344656661756C743A21312C636F6E74726F6C733A7B706F696E743A732E696E6465784F66282250';
wwv_flow_imp.g_varchar2_table(80) := '4F494E5422293E2D312C6C696E655F737472696E673A732E696E6465784F6628224C494E4522293E2D312C706F6C79676F6E3A732E696E6465784F662822504F4C59474F4E22293E2D312C74726173683A216C2C6D6F6465733A507D2C7374796C65733A';
wwv_flow_imp.g_varchar2_table(81) := '4D4150424954535F44454641554C545F445241575F5354594C45537D292C632626622E616464436F6E74726F6C285F293B663D31303B622E616464436F6E74726F6C28622E64726177292C617065782E6A517565727928222E6D6170626F78676C2D6374';
wwv_flow_imp.g_varchar2_table(82) := '726C2D67726F757022292E616464436C61737328226D61706C69627265676C2D6374726C2D67726F757022292C617065782E6A517565727928222E6D6170626F78676C2D6374726C22292E616464436C61737328226D61706C69627265676C2D6374726C';
wwv_flow_imp.g_varchar2_table(83) := '22293B636F6E7374204D3D653D3E7B22456E746572223D3D3D653F2E6B65792626652E70726576656E7444656661756C7428297D3B69662864262628617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6465677265657322292E';
wwv_flow_imp.g_varchar2_table(84) := '6368616E67652879292E6B65797072657373284D292C617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6D696E7574657322292E6368616E67652879292E6B65797072657373284D292C617065782E6A5175657279282223222B';
wwv_flow_imp.g_varchar2_table(85) := '652B225F6C6F6E6769747564655F7365636F6E647322292E6368616E67652879292E6B65797072657373284D292C617065782E6A5175657279282223222B652B225F6C617469747564655F6465677265657322292E6368616E67652879292E6B65797072';
wwv_flow_imp.g_varchar2_table(86) := '657373284D292C617065782E6A5175657279282223222B652B225F6C617469747564655F6D696E7574657322292E6368616E67652879292E6B65797072657373284D292C617065782E6A5175657279282223222B652B225F6C617469747564655F736563';
wwv_flow_imp.g_varchar2_table(87) := '6F6E647322292E6368616E67652879292E6B65797072657373284D29292C6E756C6C213D6F26262222213D6F29696628622E647261772E616464286F292C22506F696E74223D3D6F2E74797065297B6426266D286F293B7472797B622E6A756D70546F28';
wwv_flow_imp.g_varchar2_table(88) := '7B63656E7465723A6F2E636F6F7264696E617465732C7A6F6F6D3A752C6475726174696F6E3A3265337D297D63617463682865297B636F6E736F6C652E6C6F6728225B4D61706269747320447261775D204661696C656420746F206A756D7020746F2069';
wwv_flow_imp.g_varchar2_table(89) := '6E697469616C206C6F636174696F6E2E22297D7D656C73657B766172206B3D66756E6374696F6E2865297B76617220743B696628224C696E65537472696E67223D3D652E7479706529743D652E636F6F7264696E617465733B656C73652069662822506F';
wwv_flow_imp.g_varchar2_table(90) := '6C79676F6E223D3D652E7479706529743D652E636F6F7264696E617465735B305D3B656C736520696628224D756C7469506F6C79676F6E223D3D652E74797065297B743D5B5D3B666F7228766172206E3D303B6E3C652E636F6F7264696E617465732E6C';
wwv_flow_imp.g_varchar2_table(91) := '656E6774683B6E2B2B29743D742E636F6E63617428652E636F6F7264696E617465735B6E5D5B305D297D656C736520696628224D756C74694C696E65537472696E67223D3D652E7479706529666F7228743D5B5D2C6E3D303B6E3C652E636F6F7264696E';
wwv_flow_imp.g_varchar2_table(92) := '617465732E6C656E6774683B6E2B2B29743D742E636F6E63617428652E636F6F7264696E617465735B6E5D293B766172206F3D6E657720722E4C6E674C6174426F756E647328745B305D2C745B305D293B666F72286E3D313B6E3C742E6C656E6774683B';
wwv_flow_imp.g_varchar2_table(93) := '6E2B2B296F2E657874656E6428745B6E5D293B72657475726E206F7D286F293B622E666974426F756E6473286B2C7B70616464696E673A35307D297D66756E6374696F6E204E28652C74297B653D622E647261772E6765744D6F646528292C743D622E64';
wwv_flow_imp.g_varchar2_table(94) := '7261772E67657453656C656374656428292E66656174757265732E6C656E6774683B63262628226469726563745F73656C656374223D3D657C7C22647261775F706F696E74223D3D657C7C22647261775F6C696E655F737472696E67223D3D657C7C2264';
wwv_flow_imp.g_varchar2_table(95) := '7261775F706F6C79676F6E223D3D653F5F2E676574427574746F6E28292E7374796C652E646973706C61793D22626C6F636B223A2273696D706C655F73656C656374223D3D652626285F2E676574427574746F6E28292E7374796C652E646973706C6179';
wwv_flow_imp.g_varchar2_table(96) := '3D743E303F22626C6F636B223A226E6F6E652229297D6C2626622E647261772E6368616E67654D6F6465282273746174696322292C622E6472617776657274696365733D7B69643A373938312C747970653A2246656174757265222C70726F7065727469';
wwv_flow_imp.g_varchar2_table(97) := '65733A7B7D2C67656F6D657472793A7B747970653A224C696E65537472696E67222C636F6F7264696E617465733A5B5D7D7D2C622E6F6E2822647261772E637265617465222C2866756E6374696F6E2865297B666F722876617220743D622E647261772E';
wwv_flow_imp.g_varchar2_table(98) := '676574416C6C28292C6E3D303B6E3C742E66656174757265732E6C656E6774682D313B6E2B2B29652E66656174757265735B305D2E6964213D742E66656174757265735B6E5D2E69642626622E647261772E64656C65746528742E66656174757265735B';
wwv_flow_imp.g_varchar2_table(99) := '6E5D2E6964293B766172206F3D28743D622E647261772E676574416C6C2829292E66656174757265735B305D2E67656F6D657472793B6426266D286F292C6A284A534F4E2E737472696E67696679286F29297D29292C622E6F6E2822647261772E757064';
wwv_flow_imp.g_varchar2_table(100) := '617465222C2866756E6374696F6E2865297B76617220743D622E647261772E676574416C6C28292E66656174757265735B305D2E67656F6D657472793B6426266D2874292C6A284A534F4E2E737472696E67696679287429297D29292C622E6F6E282264';
wwv_flow_imp.g_varchar2_table(101) := '7261772E6D6F64656368616E6765222C2866756E6374696F6E2874297B6426262822647261775F706F696E74223D3D742E6D6F64653F617065782E6A5175657279282223222B652B225F636F6F72647322292E6373732822646973706C6179222C22626C';
wwv_flow_imp.g_varchar2_table(102) := '6F636B22293A22647261775F6C696E655F737472696E6722213D742E6D6F6465262622647261775F706F6C79676F6E22213D742E6D6F64657C7C617065782E6A5175657279282223222B652B225F636F6F72647322292E6373732822646973706C617922';
wwv_flow_imp.g_varchar2_table(103) := '2C226E6F6E652229292C4E28297D29292C622E6F6E2822647261772E73656C656374696F6E6368616E6765222C2866756E6374696F6E2865297B4E28297D29292C632626285F2E676574427574746F6E28292E6F6E636C69636B3D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(104) := '65297B76617220743D622E647261772E6765744D6F646528293B66756E6374696F6E206E2865297B69662822647261775F706F696E74223D3D74297B622E647261772E736574287B747970653A2246656174757265436F6C6C656374696F6E222C666561';
wwv_flow_imp.g_varchar2_table(105) := '74757265733A5B7B747970653A2246656174757265222C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A22506F696E74222C636F6F7264696E617465733A657D7D5D7D293B5F2E676574427574746F6E28292E7374796C652E64';
wwv_flow_imp.g_varchar2_table(106) := '6973706C61793D226E6F6E65227D656C7365206966282273696D706C655F73656C656374223D3D74297B696628622E647261772E67657453656C656374656428292E66656174757265732E6C656E6774683E3029286E3D622E647261772E67657453656C';
wwv_flow_imp.g_varchar2_table(107) := '656374656428292E66656174757265735B305D292E67656F6D657472792E636F6F7264696E617465735B305D3D655B305D2C6E2E67656F6D657472792E636F6F7264696E617465735B315D3D655B315D2C622E647261772E736574287B747970653A2246';
wwv_flow_imp.g_varchar2_table(108) := '656174757265436F6C6C656374696F6E222C66656174757265733A5B6E5D7D297D656C736520696628226469726563745F73656C656374223D3D74297B766172206E3D622E647261772E67657453656C656374656428292E66656174757265735B305D2C';
wwv_flow_imp.g_varchar2_table(109) := '6F3D622E647261772E67657453656C6563746564506F696E747328292E66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465733B66756E6374696F6E20692874297B666F7228766172206E3D303B6E3C742E6C656E6774683B6E';
wwv_flow_imp.g_varchar2_table(110) := '2B2B296F5B305D3D3D745B6E5D5B305D26266F5B315D3D3D745B6E5D5B315D262628745B6E5D5B305D3D655B305D2C745B6E5D5B315D3D655B315D297D696628224C696E65537472696E67223D3D6E2E67656F6D657472792E747970652969286E2E6765';
wwv_flow_imp.g_varchar2_table(111) := '6F6D657472792E636F6F7264696E61746573293B656C73652069662822506F6C79676F6E223D3D6E2E67656F6D657472792E7479706529666F722876617220723D303B723C6E2E67656F6D657472792E636F6F7264696E617465732E6C656E6774683B72';
wwv_flow_imp.g_varchar2_table(112) := '2B2B2969286E2E67656F6D657472792E636F6F7264696E617465735B725D293B622E647261772E736574287B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B6E5D7D297D7D22647261775F706F696E74223D3D74';
wwv_flow_imp.g_varchar2_table(113) := '7C7C226469726563745F73656C656374223D3D747C7C2273696D706C655F73656C656374223D3D743F6E6176696761746F722E67656F6C6F636174696F6E3F6E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974';
wwv_flow_imp.g_varchar2_table(114) := '696F6E282866756E6374696F6E2865297B6E285B652E636F6F7264732E6C6F6E6769747564652C652E636F6F7264732E6C617469747564655D297D292C2866756E6374696F6E2865297B6E285B2E30312A4D6174682E72616E646F6D28292D2E3030352D';
wwv_flow_imp.g_varchar2_table(115) := '39302C2E30312A4D6174682E72616E646F6D28292D2E3030352B33305D297D29293A61282247656F6C6F636174696F6E206E6F7420737570706F727465642E22293A22647261775F6C696E655F737472696E6722213D74262622647261775F706F6C7967';
wwv_flow_imp.g_varchar2_table(116) := '6F6E22213D747C7C622E676574436F6E7461696E657228292E64697370617463684576656E74286E6577204B6579626F6172644576656E7428226B65797570222C7B6B65793A2260227D29297D292C617065782E6974656D2E63726561746528652C7B73';
wwv_flow_imp.g_varchar2_table(117) := '657447656F6D657472793A653D3E7B622E647261772E736574287B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B7B747970653A2246656174757265222C67656F6D657472793A652C70726F706572746965733A';
wwv_flow_imp.g_varchar2_table(118) := '7B7D7D5D7D292C6A284A534F4E2E737472696E67696679286529297D7D297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(37433964363367413)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_file_name=>'mapbits-draw.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '766172204D4150424954535F44454641554C545F445241575F5354594C45533D5B7B69643A22676C2D647261772D706F6C79676F6E2D66696C6C2D696E616374697665222C747970653A2266696C6C222C66696C7465723A5B22616C6C222C5B223D3D22';
wwv_flow_imp.g_varchar2_table(2) := '2C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C7061696E743A7B2266696C6C2D636F6C6F72223A2223336262326430222C2266';
wwv_flow_imp.g_varchar2_table(3) := '696C6C2D6F75746C696E652D636F6C6F72223A2223336262326430222C2266696C6C2D6F706163697479223A2E317D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D66696C6C2D616374697665222C747970653A2266696C6C222C66696C7465';
wwv_flow_imp.g_varchar2_table(4) := '723A5B22616C6C222C5B223D3D222C22616374697665222C2274727565225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C7061696E743A7B2266696C6C2D636F6C6F72223A2223666262303362222C2266696C6C2D6F75746C696E';
wwv_flow_imp.g_varchar2_table(5) := '652D636F6C6F72223A2223666262303362222C2266696C6C2D6F706163697479223A2E317D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D6D6964706F696E74222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B22';
wwv_flow_imp.g_varchar2_table(6) := '3D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C226D6964706F696E74225D5D2C7061696E743A7B22636972636C652D726164697573223A332C22636972636C652D636F6C6F72223A2223666262303362227D7D2C7B';
wwv_flow_imp.g_varchar2_table(7) := '69643A22676C2D647261772D706F6C79676F6E2D7374726F6B652D696E616374697665222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C22247479706522';
wwv_flow_imp.g_varchar2_table(8) := '2C22506F6C79676F6E225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C';
wwv_flow_imp.g_varchar2_table(9) := '6F72223A2223336262326430222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D7374726F6B652D616374697665222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C22';
wwv_flow_imp.g_varchar2_table(10) := '616374697665222C2274727565225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C69';
wwv_flow_imp.g_varchar2_table(11) := '6E652D636F6C6F72223A2223666262303362222C226C696E652D646173686172726179223A5B2E322C325D2C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D6C696E652D696E616374697665222C747970653A226C696E6522';
wwv_flow_imp.g_varchar2_table(12) := '2C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C224C696E65537472696E67225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C6C61796F75743A7B22';
wwv_flow_imp.g_varchar2_table(13) := '6C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223336262326430222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D6C';
wwv_flow_imp.g_varchar2_table(14) := '696E652D616374697665222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C224C696E65537472696E67225D2C5B223D3D222C22616374697665222C2274727565225D5D2C6C61796F75743A7B226C';
wwv_flow_imp.g_varchar2_table(15) := '696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223666262303362222C226C696E652D646173686172726179223A5B2E322C325D2C226C696E652D7769';
wwv_flow_imp.g_varchar2_table(16) := '647468223A327D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D616E642D6C696E652D7665727465782D7374726F6B652D696E616374697665222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D65';
wwv_flow_imp.g_varchar2_table(17) := '7461222C22766572746578225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C7061696E743A7B22636972636C652D726164697573223A352C22636972636C652D636F6C6F7222';
wwv_flow_imp.g_varchar2_table(18) := '3A2223666666227D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D616E642D6C696E652D7665727465782D696E616374697665222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D657461222C2276';
wwv_flow_imp.g_varchar2_table(19) := '6572746578225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C7061696E743A7B22636972636C652D726164697573223A332C22636972636C652D636F6C6F72223A2223666262';
wwv_flow_imp.g_varchar2_table(20) := '303362227D7D2C7B69643A22676C2D647261772D706F696E742D7374726F6B652D696E616374697665222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D22';
wwv_flow_imp.g_varchar2_table(21) := '2C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C2266656174757265225D5D2C7061696E743A7B22636972636C652D726164697573223A31332C22636972636C652D6F706163697479223A312C22636972636C652D636F6C6F';
wwv_flow_imp.g_varchar2_table(22) := '72223A2223666666227D7D2C7B69643A22676C2D647261772D706F696E742D696E616374697665222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C22';
wwv_flow_imp.g_varchar2_table(23) := '2474797065222C22506F696E74225D2C5B223D3D222C226D657461222C2266656174757265225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C7061696E743A7B22636972636C652D726164697573223A31312C22636972636C652D636F';
wwv_flow_imp.g_varchar2_table(24) := '6C6F72223A2223336262326430227D7D2C7B69643A22676C2D647261772D706F696E742D7374726F6B652D616374697665222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E7422';
wwv_flow_imp.g_varchar2_table(25) := '5D2C5B223D3D222C22616374697665222C2274727565225D2C5B22213D222C226D657461222C226D6964706F696E74225D5D2C7061696E743A7B22636972636C652D726164697573223A31322C22636972636C652D636F6C6F72223A2223666666227D7D';
wwv_flow_imp.g_varchar2_table(26) := '2C7B69643A22676C2D647261772D706F696E742D616374697665222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B22213D222C226D657461222C226D6964706F696E';
wwv_flow_imp.g_varchar2_table(27) := '74225D2C5B223D3D222C22616374697665222C2274727565225D5D2C7061696E743A7B22636972636C652D726164697573223A31302C22636972636C652D636F6C6F72223A2223666262303362227D7D2C7B69643A22676C2D647261772D706F6C79676F';
wwv_flow_imp.g_varchar2_table(28) := '6E2D66696C6C2D737461746963222C747970653A2266696C6C222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F6465222C22737461746963225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C7061696E743A7B226669';
wwv_flow_imp.g_varchar2_table(29) := '6C6C2D636F6C6F72223A2223343034303430222C2266696C6C2D6F75746C696E652D636F6C6F72223A2223343034303430222C2266696C6C2D6F706163697479223A2E317D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D7374726F6B652D73';
wwv_flow_imp.g_varchar2_table(30) := '7461746963222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F6465222C22737461746963225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C6C61796F75743A7B226C696E652D63617022';
wwv_flow_imp.g_varchar2_table(31) := '3A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223343034303430222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D6C696E652D7374617469';
wwv_flow_imp.g_varchar2_table(32) := '63222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F6465222C22737461746963225D2C5B223D3D222C222474797065222C224C696E65537472696E67225D5D2C6C61796F75743A7B226C696E652D636170223A';
wwv_flow_imp.g_varchar2_table(33) := '22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223343034303430222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D706F696E742D7374617469';
wwv_flow_imp.g_varchar2_table(34) := '63222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F6465222C22737461746963225D2C5B223D3D222C222474797065222C22506F696E74225D5D2C7061696E743A7B22636972636C652D72616469757322';
wwv_flow_imp.g_varchar2_table(35) := '3A31302C22636972636C652D636F6C6F72223A2223343034303430227D7D5D3B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(555950326800427303)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_file_name=>'mapbits-draw-style.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '766172204D4150424954535F44454641554C545F445241575F5354594C4553203D205B0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D706F6C79676F6E2D66696C6C2D696E616374697665272C0D0A2020202020202774';
wwv_flow_imp.g_varchar2_table(2) := '797065273A202766696C6C272C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A20202020202020205B273D3D272C2027616374697665272C202766616C7365275D2C0D0A20202020202020205B273D3D272C20272474797065272C20';
wwv_flow_imp.g_varchar2_table(3) := '27506F6C79676F6E275D2C0D0A20202020202020205B27213D272C20276D6F6465272C2027737461746963275D0D0A2020202020205D2C0D0A202020202020277061696E74273A207B0D0A20202020202020202766696C6C2D636F6C6F72273A20272333';
wwv_flow_imp.g_varchar2_table(4) := '6262326430272C0D0A20202020202020202766696C6C2D6F75746C696E652D636F6C6F72273A202723336262326430272C0D0A20202020202020202766696C6C2D6F706163697479273A20302E310D0A2020202020207D0D0A2020202020207D2C0D0A20';
wwv_flow_imp.g_varchar2_table(5) := '20202020207B0D0A202020202020276964273A2027676C2D647261772D706F6C79676F6E2D66696C6C2D616374697665272C0D0A2020202020202774797065273A202766696C6C272C0D0A2020202020202766696C746572273A205B27616C6C272C205B';
wwv_flow_imp.g_varchar2_table(6) := '273D3D272C2027616374697665272C202774727565275D2C205B273D3D272C20272474797065272C2027506F6C79676F6E275D5D2C0D0A202020202020277061696E74273A207B0D0A20202020202020202766696C6C2D636F6C6F72273A202723666262';
wwv_flow_imp.g_varchar2_table(7) := '303362272C0D0A20202020202020202766696C6C2D6F75746C696E652D636F6C6F72273A202723666262303362272C0D0A20202020202020202766696C6C2D6F706163697479273A20302E310D0A2020202020207D0D0A2020202020207D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(8) := '2020207B0D0A202020202020276964273A2027676C2D647261772D706F6C79676F6E2D6D6964706F696E74272C0D0A2020202020202774797065273A2027636972636C65272C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A202020';
wwv_flow_imp.g_varchar2_table(9) := '20202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A20202020202020205B273D3D272C20276D657461272C20276D6964706F696E74275D5D2C0D0A202020202020277061696E74273A207B0D0A202020202020202027636972';
wwv_flow_imp.g_varchar2_table(10) := '636C652D726164697573273A20332C0D0A202020202020202027636972636C652D636F6C6F72273A202723666262303362270D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D64726177';
wwv_flow_imp.g_varchar2_table(11) := '2D706F6C79676F6E2D7374726F6B652D696E616374697665272C0D0A2020202020202774797065273A20276C696E65272C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A20202020202020205B273D3D272C2027616374697665272C';
wwv_flow_imp.g_varchar2_table(12) := '202766616C7365275D2C0D0A20202020202020205B273D3D272C20272474797065272C2027506F6C79676F6E275D2C0D0A20202020202020205B27213D272C20276D6F6465272C2027737461746963275D0D0A2020202020205D2C0D0A20202020202027';
wwv_flow_imp.g_varchar2_table(13) := '6C61796F7574273A207B0D0A2020202020202020276C696E652D636170273A2027726F756E64272C0D0A2020202020202020276C696E652D6A6F696E273A2027726F756E64270D0A2020202020207D2C0D0A202020202020277061696E74273A207B0D0A';
wwv_flow_imp.g_varchar2_table(14) := '2020202020202020276C696E652D636F6C6F72273A202723336262326430272C0D0A2020202020202020276C696E652D7769647468273A20320D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027';
wwv_flow_imp.g_varchar2_table(15) := '676C2D647261772D706F6C79676F6E2D7374726F6B652D616374697665272C0D0A2020202020202774797065273A20276C696E65272C0D0A2020202020202766696C746572273A205B27616C6C272C205B273D3D272C2027616374697665272C20277472';
wwv_flow_imp.g_varchar2_table(16) := '7565275D2C205B273D3D272C20272474797065272C2027506F6C79676F6E275D5D2C0D0A202020202020276C61796F7574273A207B0D0A2020202020202020276C696E652D636170273A2027726F756E64272C0D0A2020202020202020276C696E652D6A';
wwv_flow_imp.g_varchar2_table(17) := '6F696E273A2027726F756E64270D0A2020202020207D2C0D0A202020202020277061696E74273A207B0D0A2020202020202020276C696E652D636F6C6F72273A202723666262303362272C0D0A2020202020202020276C696E652D646173686172726179';
wwv_flow_imp.g_varchar2_table(18) := '273A205B302E322C20325D2C0D0A2020202020202020276C696E652D7769647468273A20320D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D6C696E652D696E6163746976';
wwv_flow_imp.g_varchar2_table(19) := '65272C0D0A2020202020202774797065273A20276C696E65272C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A20202020202020205B273D3D272C2027616374697665272C202766616C7365275D2C0D0A20202020202020205B273D';
wwv_flow_imp.g_varchar2_table(20) := '3D272C20272474797065272C20274C696E65537472696E67275D2C0D0A20202020202020205B27213D272C20276D6F6465272C2027737461746963275D0D0A2020202020205D2C0D0A202020202020276C61796F7574273A207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(21) := '276C696E652D636170273A2027726F756E64272C0D0A2020202020202020276C696E652D6A6F696E273A2027726F756E64270D0A2020202020207D2C0D0A202020202020277061696E74273A207B0D0A2020202020202020276C696E652D636F6C6F7227';
wwv_flow_imp.g_varchar2_table(22) := '3A202723336262326430272C0D0A2020202020202020276C696E652D7769647468273A20320D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D6C696E652D61637469766527';
wwv_flow_imp.g_varchar2_table(23) := '2C0D0A2020202020202774797065273A20276C696E65272C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A20202020202020205B273D3D272C20272474797065272C20274C696E65537472696E67275D2C0D0A20202020202020205B';
wwv_flow_imp.g_varchar2_table(24) := '273D3D272C2027616374697665272C202774727565275D0D0A2020202020205D2C0D0A202020202020276C61796F7574273A207B0D0A2020202020202020276C696E652D636170273A2027726F756E64272C0D0A2020202020202020276C696E652D6A6F';
wwv_flow_imp.g_varchar2_table(25) := '696E273A2027726F756E64270D0A2020202020207D2C0D0A202020202020277061696E74273A207B0D0A2020202020202020276C696E652D636F6C6F72273A202723666262303362272C0D0A2020202020202020276C696E652D64617368617272617927';
wwv_flow_imp.g_varchar2_table(26) := '3A205B302E322C20325D2C0D0A2020202020202020276C696E652D7769647468273A20320D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D706F6C79676F6E2D616E642D6C';
wwv_flow_imp.g_varchar2_table(27) := '696E652D7665727465782D7374726F6B652D696E616374697665272C0D0A2020202020202774797065273A2027636972636C65272C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A20202020202020205B273D3D272C20276D657461';
wwv_flow_imp.g_varchar2_table(28) := '272C2027766572746578275D2C0D0A20202020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A20202020202020205B27213D272C20276D6F6465272C2027737461746963275D0D0A2020202020205D2C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(29) := '277061696E74273A207B0D0A202020202020202027636972636C652D726164697573273A20352C0D0A202020202020202027636972636C652D636F6C6F72273A202723666666270D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D';
wwv_flow_imp.g_varchar2_table(30) := '0A202020202020276964273A2027676C2D647261772D706F6C79676F6E2D616E642D6C696E652D7665727465782D696E616374697665272C0D0A2020202020202774797065273A2027636972636C65272C0D0A2020202020202766696C746572273A205B';
wwv_flow_imp.g_varchar2_table(31) := '27616C6C272C0D0A20202020202020205B273D3D272C20276D657461272C2027766572746578275D2C0D0A20202020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A20202020202020205B27213D272C20276D6F6465272C';
wwv_flow_imp.g_varchar2_table(32) := '2027737461746963275D0D0A2020202020205D2C0D0A202020202020277061696E74273A207B0D0A202020202020202027636972636C652D726164697573273A20332C0D0A202020202020202027636972636C652D636F6C6F72273A2027236662623033';
wwv_flow_imp.g_varchar2_table(33) := '62270D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D706F696E742D7374726F6B652D696E616374697665272C0D0A2020202020202774797065273A2027636972636C6527';
wwv_flow_imp.g_varchar2_table(34) := '2C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A20202020202020205B273D3D272C2027616374697665272C202766616C7365275D2C0D0A20202020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A20';
wwv_flow_imp.g_varchar2_table(35) := '202020202020205B273D3D272C20276D657461272C202766656174757265275D0D0A2020202020205D2C0D0A202020202020277061696E74273A207B0D0A202020202020202027636972636C652D726164697573273A2031332C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(36) := '27636972636C652D6F706163697479273A20312C0D0A202020202020202027636972636C652D636F6C6F72273A202723666666270D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D6472';
wwv_flow_imp.g_varchar2_table(37) := '61772D706F696E742D696E616374697665272C0D0A2020202020202774797065273A2027636972636C65272C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A20202020202020205B273D3D272C2027616374697665272C202766616C';
wwv_flow_imp.g_varchar2_table(38) := '7365275D2C0D0A20202020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A20202020202020205B273D3D272C20276D657461272C202766656174757265275D2C0D0A20202020202020205B27213D272C20276D6F6465272C';
wwv_flow_imp.g_varchar2_table(39) := '2027737461746963275D0D0A2020202020205D2C0D0A202020202020277061696E74273A207B0D0A202020202020202027636972636C652D726164697573273A2031312C200D0A202020202020202027636972636C652D636F6C6F72273A202723336262';
wwv_flow_imp.g_varchar2_table(40) := '326430270D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D706F696E742D7374726F6B652D616374697665272C0D0A2020202020202774797065273A2027636972636C6527';
wwv_flow_imp.g_varchar2_table(41) := '2C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A20202020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A20202020202020205B273D3D272C2027616374697665272C202774727565275D2C0D0A2020';
wwv_flow_imp.g_varchar2_table(42) := '2020202020205B27213D272C20276D657461272C20276D6964706F696E74275D0D0A2020202020205D2C0D0A202020202020277061696E74273A207B0D0A202020202020202027636972636C652D726164697573273A2031322C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(43) := '27636972636C652D636F6C6F72273A202723666666270D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D706F696E742D616374697665272C0D0A2020202020202774797065';
wwv_flow_imp.g_varchar2_table(44) := '273A2027636972636C65272C0D0A2020202020202766696C746572273A205B27616C6C272C0D0A20202020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A20202020202020205B27213D272C20276D657461272C20276D69';
wwv_flow_imp.g_varchar2_table(45) := '64706F696E74275D2C0D0A20202020202020205B273D3D272C2027616374697665272C202774727565275D5D2C0D0A202020202020277061696E74273A207B0D0A202020202020202027636972636C652D726164697573273A2031302C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(46) := '20202027636972636C652D636F6C6F72273A202723666262303362270D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D706F6C79676F6E2D66696C6C2D737461746963272C';
wwv_flow_imp.g_varchar2_table(47) := '0D0A2020202020202774797065273A202766696C6C272C0D0A2020202020202766696C746572273A205B27616C6C272C205B273D3D272C20276D6F6465272C2027737461746963275D2C205B273D3D272C20272474797065272C2027506F6C79676F6E27';
wwv_flow_imp.g_varchar2_table(48) := '5D5D2C0D0A202020202020277061696E74273A207B0D0A20202020202020202766696C6C2D636F6C6F72273A202723343034303430272C0D0A20202020202020202766696C6C2D6F75746C696E652D636F6C6F72273A202723343034303430272C0D0A20';
wwv_flow_imp.g_varchar2_table(49) := '202020202020202766696C6C2D6F706163697479273A20302E310D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D706F6C79676F6E2D7374726F6B652D737461746963272C';
wwv_flow_imp.g_varchar2_table(50) := '0D0A2020202020202774797065273A20276C696E65272C0D0A2020202020202766696C746572273A205B27616C6C272C205B273D3D272C20276D6F6465272C2027737461746963275D2C205B273D3D272C20272474797065272C2027506F6C79676F6E27';
wwv_flow_imp.g_varchar2_table(51) := '5D5D2C0D0A202020202020276C61796F7574273A207B0D0A2020202020202020276C696E652D636170273A2027726F756E64272C0D0A2020202020202020276C696E652D6A6F696E273A2027726F756E64270D0A2020202020207D2C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(52) := '277061696E74273A207B0D0A2020202020202020276C696E652D636F6C6F72273A202723343034303430272C0D0A2020202020202020276C696E652D7769647468273A20320D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A20';
wwv_flow_imp.g_varchar2_table(53) := '2020202020276964273A2027676C2D647261772D6C696E652D737461746963272C0D0A2020202020202774797065273A20276C696E65272C0D0A2020202020202766696C746572273A205B27616C6C272C205B273D3D272C20276D6F6465272C20277374';
wwv_flow_imp.g_varchar2_table(54) := '61746963275D2C205B273D3D272C20272474797065272C20274C696E65537472696E67275D5D2C0D0A202020202020276C61796F7574273A207B0D0A2020202020202020276C696E652D636170273A2027726F756E64272C0D0A2020202020202020276C';
wwv_flow_imp.g_varchar2_table(55) := '696E652D6A6F696E273A2027726F756E64270D0A2020202020207D2C0D0A202020202020277061696E74273A207B0D0A2020202020202020276C696E652D636F6C6F72273A202723343034303430272C0D0A2020202020202020276C696E652D77696474';
wwv_flow_imp.g_varchar2_table(56) := '68273A20320D0A2020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020276964273A2027676C2D647261772D706F696E742D737461746963272C0D0A2020202020202774797065273A2027636972636C65272C0D0A202020';
wwv_flow_imp.g_varchar2_table(57) := '2020202766696C746572273A205B27616C6C272C205B273D3D272C20276D6F6465272C2027737461746963275D2C205B273D3D272C20272474797065272C2027506F696E74275D5D2C0D0A202020202020277061696E74273A207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(58) := '2027636972636C652D726164697573273A2031302C0D0A202020202020202027636972636C652D636F6C6F72273A202723343034303430270D0A2020202020207D0D0A0920207D0D0A095D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(1985528631863912574)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_file_name=>'mapbits-draw-style.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F64726177287B705F6974656D5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F67656F6D657472792C202E2E2E705F6F7074696F6E737D29207B0D0A20202F2F';
wwv_flow_imp.g_varchar2_table(2) := '204163636F6D6F6461746520626F7468204D6170626F7820696E204150455820323120616E64204D61706C6962726520696E20415045582032322E090D0A2020766172206D61706C6962203D20747970656F66206D61706C69627265676C203D3D3D2027';
wwv_flow_imp.g_varchar2_table(3) := '756E646566696E656427203F206D6170626F78676C203A206D61706C69627265676C3B090D0A0D0A20202F2A0D0A2020202A202067656E657261746520616E206572726F72206D65737361676520616C6572742C206D73670D0A2020202A2F0D0A202066';
wwv_flow_imp.g_varchar2_table(4) := '756E6374696F6E20617065785F616C657274286D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C657274286D7367293B636F6E736F6C652E6C6F672827616C6572742027202B';
wwv_flow_imp.g_varchar2_table(5) := '206D7367293B7D293B0D0A20207D0D0A20200D0A20202F2A0D0A2020202A2052657475726E2074686520657874656E74206F662074686520696E7075742067656F6D206F626A6563742061732061206D6170626F78676C2E4C6E674C6174426F756E6473';
wwv_flow_imp.g_varchar2_table(6) := '2E0D0A2020202A20496E7075742067656F6D65747279206F626A6563742069732067656F6A736F6E2067656F6D6574727920666F726D617420286E6F742046656174757265292E0D0A2020202A2F0D0A202066756E6374696F6E20676574426F756E6473';
wwv_flow_imp.g_varchar2_table(7) := '2867656F6D29207B0D0A20202020766172207061727261793B0D0A202020206966202867656F6D2E74797065203D3D20224C696E65537472696E672229207B0D0A202020202020706172726179203D2067656F6D2E636F6F7264696E617465733B0D0A20';
wwv_flow_imp.g_varchar2_table(8) := '2020207D20656C7365206966202867656F6D2E74797065203D3D2022506F6C79676F6E2229207B0D0A202020202020706172726179203D2067656F6D2E636F6F7264696E617465735B305D3B0D0A202020207D20656C7365206966202867656F6D2E7479';
wwv_flow_imp.g_varchar2_table(9) := '7065203D3D20224D756C7469506F6C79676F6E2229207B0D0A202020202020706172726179203D205B5D3B0D0A202020202020666F722876617220693D303B693C67656F6D2E636F6F7264696E617465732E6C656E6774683B692B2B29207B0D0A202020';
wwv_flow_imp.g_varchar2_table(10) := '2020202020706172726179203D207061727261792E636F6E6361742867656F6D2E636F6F7264696E617465735B695D5B305D293B0D0A2020202020207D0D0A202020207D20656C7365206966202867656F6D2E74797065203D3D20224D756C74694C696E';
wwv_flow_imp.g_varchar2_table(11) := '65537472696E672229207B0D0A202020202020706172726179203D205B5D3B0D0A202020202020666F722876617220693D303B693C67656F6D2E636F6F7264696E617465732E6C656E6774683B692B2B29207B0D0A202020202020202070617272617920';
wwv_flow_imp.g_varchar2_table(12) := '3D207061727261792E636F6E6361742867656F6D2E636F6F7264696E617465735B695D293B0D0A2020202020207D0D0A202020207D0D0A202020200D0A20202020766172207274203D206E6577206D61706C69622E4C6E674C6174426F756E6473287061';
wwv_flow_imp.g_varchar2_table(13) := '727261795B305D2C207061727261795B305D293B0D0A20202020666F7220287661722069203D20313B2069203C207061727261792E6C656E6774683B692B2B29207B0D0A20202020202072742E657874656E64287061727261795B695D293B0D0A202020';
wwv_flow_imp.g_varchar2_table(14) := '207D0D0A2020202072657475726E2072743B0D0A20207D0D0A20200D0A20202F2F204D616B65207661726961626C65732066726F6D20706C7567696E20617474726962757465730D0A202076617220705F67656F6D657472795F6D6F646573203D20705F';
wwv_flow_imp.g_varchar2_table(15) := '6F7074696F6E735B2767656F6D657472795F6D6F646573275D3B0D0A202076617220705F726561646F6E6C79203D20705F6F7074696F6E735B27726561646F6E6C79275D3B0D0A202076617220705F73686F775F636F6F726473203D20705F6F7074696F';
wwv_flow_imp.g_varchar2_table(16) := '6E735B2773686F775F636F6F726473275D3B0D0A202076617220705F706F696E745F7A6F6F6D5F6C6576656C203D20705F6F7074696F6E735B27706F696E745F7A6F6F6D5F6C6576656C275D3B0D0A202076617220705F656E61626C655F67656F6C6F63';
wwv_flow_imp.g_varchar2_table(17) := '617465203D20705F6F7074696F6E735B27656E61626C655F67656F6C6F63617465275D3B0D0A20200D0A20202F2A200D0A2020202A20436C61737320666F72204D6170626F782047656F6C6F6361746520506F696E7420436F6E74726F6C2C206578706F';
wwv_flow_imp.g_varchar2_table(18) := '73696E672074686520627574746F6E2E0D0A2020202A20417373756D657320636F6E74726F6C20627574746F6E732061726520333278333270782E0D0A2020202A2F0D0A202066756E6374696F6E2047656F6C6F63617465506F696E74427574746F6E28';
wwv_flow_imp.g_varchar2_table(19) := '297B7D0D0A202047656F6C6F63617465506F696E74427574746F6E2E70726F746F747970652E6F6E416464203D2066756E6374696F6E286D617029207B0D0A20202020746869732E6D5F6D6170203D206D61703B0D0A20202020746869732E6D5F636F6E';
wwv_flow_imp.g_varchar2_table(20) := '7461696E6572203D20646F63756D656E742E637265617465456C656D656E74282764697627293B0D0A20202020746869732E67656F6C6F636174655F706F696E745F627574746F6E203D20646F63756D656E742E637265617465456C656D656E74282762';
wwv_flow_imp.g_varchar2_table(21) := '7574746F6E27293B0D0A20202020746869732E67656F6C6F636174655F706F696E745F627574746F6E2E7374796C65203D20226C696E652D6865696768743A313670783B77696474683A333270783B6865696768743A333270783B646973706C61793A6E';
wwv_flow_imp.g_varchar2_table(22) := '6F6E653B223B0D0A20202020746869732E67656F6C6F636174655F706F696E745F627574746F6E2E696E6E657248544D4C203D20273C6920636C6173733D2266612066612D6C6F636174696F6E2D636972636C65223E3C2F693E273B0D0A202020207468';
wwv_flow_imp.g_varchar2_table(23) := '69732E67656F6C6F636174655F706F696E745F627574746F6E2E747970653D22627574746F6E223B202020200D0A20202020746869732E6D5F636F6E7461696E65722E617070656E644368696C6428746869732E67656F6C6F636174655F706F696E745F';
wwv_flow_imp.g_varchar2_table(24) := '627574746F6E293B0D0A20202020746869732E6D5F636F6E7461696E65722E636C6173734E616D65203D20226D6170626F78676C2D6374726C206D61706C69627265676C2D6374726C223B0D0A2020202072657475726E20746869732E6D5F636F6E7461';
wwv_flow_imp.g_varchar2_table(25) := '696E65723B0D0A20207D3B0D0A202047656F6C6F63617465506F696E74427574746F6E2E70726F746F747970652E6F6E52656D6F7665203D2066756E6374696F6E2829207B0D0A20202020746869732E6D5F636F6E7461696E65722E706172656E744E6F';
wwv_flow_imp.g_varchar2_table(26) := '64652E72656D6F76654368696C6428746869732E6D5F636F6E7461696E6572293B0D0A20202020746869732E6D5F6D6170203D20756E646566696E65643B0D0A20207D3B0D0A202047656F6C6F63617465506F696E74427574746F6E2E70726F746F7479';
wwv_flow_imp.g_varchar2_table(27) := '70652E676574427574746F6E203D2066756E6374696F6E2829207B0D0A2020202072657475726E20746869732E67656F6C6F636174655F706F696E745F627574746F6E3B0D0A20207D3B0D0A20207661722067656F6C6F636174655F706F696E745F636F';
wwv_flow_imp.g_varchar2_table(28) := '6E74726F6C203D206E65772047656F6C6F63617465506F696E74427574746F6E28293B0D0A20200D0A20202F2A0D0A2020202A2053657420746865206D6170626974732067656F6D6574727920746F2074686520636F6F7264696E617465732073686F77';
wwv_flow_imp.g_varchar2_table(29) := '6E20696E20746865206C617469747564652F6C6F6E67697475646520646567726573732C206D696E757465732C207365636F6E647320696E7075742074657874206669656C64732E0D0A2020202A2F0D0A202066756E6374696F6E2073796E6347656F6D';
wwv_flow_imp.g_varchar2_table(30) := '6574727946726F6D436F6F7264696E617465732829207B0D0A202020207661722067656F6D78203D206765745F646563696D616C5F6465677265657328617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E67697475';
wwv_flow_imp.g_varchar2_table(31) := '64655F6465677265657322292E76616C28292C200D0A202020202020202020202020202020202020202020202020202020202020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F';
wwv_flow_imp.g_varchar2_table(32) := '6D696E7574657322292E76616C28292C200D0A202020202020202020202020202020202020202020202020202020202020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F736563';
wwv_flow_imp.g_varchar2_table(33) := '6F6E647322292E76616C2829293B0D0A202020207661722067656F6D79203D206765745F646563696D616C5F6465677265657328617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F64656772656573';
wwv_flow_imp.g_varchar2_table(34) := '22292E76616C28292C200D0A202020202020202020202020202020202020202020202020202020202020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F6D696E7574657322292E76';
wwv_flow_imp.g_varchar2_table(35) := '616C28292C200D0A202020202020202020202020202020202020202020202020202020202020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F7365636F6E647322292E76616C2829';
wwv_flow_imp.g_varchar2_table(36) := '293B0D0A202020200D0A092F2F20696620746865206D696E7574657320616E64207365636F6E6473206669656C647320617265206E6F74206E756D6265727320286E756C6C292C207468656E20757365207A65726F20746F2063616C63756C6174652064';
wwv_flow_imp.g_varchar2_table(37) := '6563696D616C20646567726565730D0A202020206966202869734E614E2867656F6D782929207B0D0A20202020202067656F6D78203D206765745F646563696D616C5F6465677265657328617065782E6A517565727928272327202B20705F6974656D5F';
wwv_flow_imp.g_varchar2_table(38) := '6964202B20225F6C6F6E6769747564655F6465677265657322292E76616C28292C20617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F6D696E7574657322292E76616C28292C2030293B20202020';
wwv_flow_imp.g_varchar2_table(39) := '200D0A2020202020206966202869734E614E2867656F6D782929207B0D0A202020202020202067656F6D78203D206765745F646563696D616C5F6465677265657328617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F';
wwv_flow_imp.g_varchar2_table(40) := '6E6769747564655F6465677265657322292E76616C28292C20302C2030293B20202020200D0A2020202020207D0D0A202020207D0D0A202020206966202869734E614E2867656F6D792929207B0D0A20202020202067656F6D79203D206765745F646563';
wwv_flow_imp.g_varchar2_table(41) := '696D616C5F6465677265657328617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F6465677265657322292E76616C28292C20617065782E6A517565727928272327202B20705F6974656D5F6964202B';
wwv_flow_imp.g_varchar2_table(42) := '20225F6C617469747564655F6D696E7574657322292E76616C28292C2030293B0D0A2020202020206966202869734E614E2867656F6D792929207B0D0A202020202020202067656F6D79203D206765745F646563696D616C5F6465677265657328617065';
wwv_flow_imp.g_varchar2_table(43) := '782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F6465677265657322292E76616C28292C20302C2030293B0D0A2020202020207D0D0A202020207D0D0A0D0A202020206966202869734E614E2867656F6D78';
wwv_flow_imp.g_varchar2_table(44) := '29207C7C2069734E614E2867656F6D792929207B0D0A2020202020202F2F20496620612064656772656573206669656C642069736E27742066696C6C6564206F75742C2069742773206E6F742076616C69642C20736F20646F6E27742064726177206120';
wwv_flow_imp.g_varchar2_table(45) := '706F696E74207965742E0D0A20202020202072657475726E3B0D0A202020207D0D0A090D0A202020202F2F206966206E6F2066656174757265732068617665206265656E206372656174652C2063726561746520616E20656D7074792066656174757265';
wwv_flow_imp.g_varchar2_table(46) := '20666F7220746865206472617720746F6F6C2E0D0A20202020766172206663203D206D61702E647261772E676574416C6C28293B0D0A202020206966202866632E66656174757265732E6C656E677468203D3D203029207B0D0A20202020202066632E66';
wwv_flow_imp.g_varchar2_table(47) := '656174757265732E70757368287B747970653A202246656174757265222C2070726F706572746965733A207B7D2C2067656F6D65747279203A207B636F6F7264696E617465733A205B6E756C6C2C206E756C6C5D7D7D293B20200D0A202020207D0D0A20';
wwv_flow_imp.g_varchar2_table(48) := '2020200D0A202020202F2F205365742074686520706F696E742067656F6D6574727920696E20746865206D61702E0D0A2020202066632E66656174757265735B305D2E67656F6D657472792E74797065203D2022506F696E74223B0D0A2020202066632E';
wwv_flow_imp.g_varchar2_table(49) := '66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465735B305D203D2067656F6D783B0D0A2020202066632E66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465735B315D203D2067656F6D793B0D0A20';
wwv_flow_imp.g_varchar2_table(50) := '2020206D61702E647261772E736574286663293B0D0A090D0A202020202F2F205772697465207468652067656F6D65747279206261636B20746F207468652073657276657220616E642070616E20746F207468652067656F6D657472792E0D0A09766172';
wwv_flow_imp.g_varchar2_table(51) := '206665617473203D206D61702E647261772E676574416C6C28293B0D0A202020207661722067656F6D203D2066656174732E66656174757265735B305D2E67656F6D657472793B0D0A20202020777269746547656F6D65747279284A534F4E2E73747269';
wwv_flow_imp.g_varchar2_table(52) := '6E676966792867656F6D29293B0D0A096D61702E70616E546F2867656F6D2E636F6F7264696E61746573293B0D0A20207D0D0A20200D0A20202F2A0D0A2020202A20557064617465206C6174697475646520616E64206C6F6E6769747564652064656772';
wwv_flow_imp.g_varchar2_table(53) := '6565732C206D696E757465732C20616E64207365636F6E6473206669656C647320616E64206D617062697473206974656D2076616C75652066726F6D20746865206D6170626974732067656F6D657472792E0D0A2020202A2F0D0A202066756E6374696F';
wwv_flow_imp.g_varchar2_table(54) := '6E2073796E63436F6F72647346726F6D47656F6D657472792867656F6D6574727929207B0D0A202020206966202867656F6D657472792E636F6F7264696E617465732E6C656E677468203C203129207B0D0A20202020202072657475726E3B0D0A202020';
wwv_flow_imp.g_varchar2_table(55) := '207D0D0A202020206966202867656F6D657472792E74797065203D3D2022506F696E742229207B0D0A2020202020207661722078203D2067656F6D657472792E636F6F7264696E617465735B305D3B0D0A2020202020207661722079203D2067656F6D65';
wwv_flow_imp.g_varchar2_table(56) := '7472792E636F6F7264696E617465735B315D3B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F6465677265657322292E76616C286765745F64656772656573287829293B0D';
wwv_flow_imp.g_varchar2_table(57) := '0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F6D696E7574657322292E76616C286765745F6D696E75746573287829293B0D0A202020202020617065782E6A51756572792827';
wwv_flow_imp.g_varchar2_table(58) := '2327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F7365636F6E647322292E76616C286765745F7365636F6E6473287829293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C';
wwv_flow_imp.g_varchar2_table(59) := '617469747564655F6465677265657322292E76616C286765745F64656772656573287929293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F6D696E7574657322292E76616C';
wwv_flow_imp.g_varchar2_table(60) := '286765745F6D696E75746573287929293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F7365636F6E647322292E76616C286765745F7365636F6E6473287929293B0D0A2020';
wwv_flow_imp.g_varchar2_table(61) := '20207D200D0A20207D0D0A20200D0A20202F2F2067657420746865206D617020696E7374616E63652E2053686F756C6420616C776179732062652072656164792073696E636520277370617469616C6D6170696E697469616C697A656427206576656E74';
wwv_flow_imp.g_varchar2_table(62) := '20697320757365642E0D0A2020766172206D6170203D20617065782E726567696F6E28705F726567696F6E5F6964292E63616C6C28226765744D61704F626A65637422293B0D0A202076617220656E7472795F73697A65203D2031303B0D0A2020766172';
wwv_flow_imp.g_varchar2_table(63) := '2077696474683D617065782E6A517565727928272327202B20705F726567696F6E5F6964202B20275F6D61705F726567696F6E27292E6373732827776964746827293B0D0A0D0A20202F2F2049662074686520446973706C617920436F6F7264696E6174';
wwv_flow_imp.g_varchar2_table(64) := '6573206174747269627574652069732059657320616E642074686520696E697469616C2067656F6D65747279206973206120706F696E74206F72207468657265206973206E6F20696E697469616C2067656F6D657472792C2073686F7720636F6F726469';
wwv_flow_imp.g_varchar2_table(65) := '6E617465206461746120656E747279206669656C64732E0D0A202076617220646973706C61795F636F6F726473203D20226E6F6E65223B0D0A202076617220726561646F6E6C79203D2022223B0D0A202069662028705F726561646F6E6C7929207B0D0A';
wwv_flow_imp.g_varchar2_table(66) := '20202020726561646F6E6C79203D2022726561646F6E6C79223B0D0A20207D0D0A202069662028705F73686F775F636F6F72647329207B0D0A2020202069662028705F67656F6D6574727920213D206E756C6C29207B0D0A20202020202069662028705F';
wwv_flow_imp.g_varchar2_table(67) := '67656F6D657472792E74797065203D3D2022506F696E742229207B0D0A2020202020202020646973706C61795F636F6F726473203D2027626C6F636B273B0D0A2020202020207D0D0A202020207D20656C7365207B0D0A20202020202069662028705F67';
wwv_flow_imp.g_varchar2_table(68) := '656F6D657472795F6D6F6465732E696E6465784F662822504F494E542229203E202D3129207B0D0A2020202020202020646973706C61795F636F6F726473203D2027626C6F636B273B0D0A2020202020207D0D0A202020207D0D0A202020207661722063';
wwv_flow_imp.g_varchar2_table(69) := '6F6F7264666F726D203D20273C7374796C653E406D6564696120286D696E2D77696474683A20333572656D29207B2E6D622D6C6F6E3A3A6265666F7265207B636F6E74656E74203A20224C6F6E6769747564653A223B7D202E6D622D6C61743A3A626566';
wwv_flow_imp.g_varchar2_table(70) := '6F7265207B636F6E74656E74203A20224C617469747564653A223B7D202E6D622D6C6162656C2D6465673A3A6166746572207B636F6E74656E74203A202244656772656573223B7D202E6D622D6C6162656C2D6D696E3A3A6166746572207B636F6E7465';
wwv_flow_imp.g_varchar2_table(71) := '6E74203A20224D696E75746573223B7D202E6D622D6C6162656C2D7365633A3A6166746572207B636F6E74656E74203A20225365636F6E6473223B7D7D27202B200D0A2020202027406D6564696120286D61782D77696474683A20333572656D29207B2E';
wwv_flow_imp.g_varchar2_table(72) := '6D622D737063207B646973706C61793A206E6F6E653B7D202E6D622D6C6F6E3A3A6265666F7265207B636F6E74656E74203A20224C6F6E20223B7D202E6D622D6C61743A3A6265666F7265207B636F6E74656E74203A20224C617420223B7D202E6D622D';
wwv_flow_imp.g_varchar2_table(73) := '6C6162656C2D6465673A3A6166746572207B636F6E74656E74203A2022C2B0223B7D20202E6D622D6C6162656C2D6D696E3A3A6166746572207B636F6E74656E74203A20225C27223B7D202E6D622D6C6162656C2D7365633A3A6166746572207B636F6E';
wwv_flow_imp.g_varchar2_table(74) := '74656E74203A20225C5C22223B7D7D3C2F7374796C653E27202B200D0A20202020273C64697620616C69676E3D226C656674222069643D2227202B20705F6974656D5F6964202B20275F636F6F7264732220636C6173733D2275692D7769646765742D68';
wwv_flow_imp.g_varchar2_table(75) := '656164657220742D526567696F6E2D6865616465722075692D636F726E65722D616C6C22207374796C653D22646973706C61793A27202B20646973706C61795F636F6F726473202B20273B77696474683A27202B207769647468202B202770783B207061';
wwv_flow_imp.g_varchar2_table(76) := '6464696E673A203470782030707820327078203470783B20666C6F61743A6C6566743B206D617267696E3A303B223E27202B0D0A20202020273C6C6162656C20636C6173733D226D622D6C6F6E223E266E6273703B266E6273703B3C2F6C6162656C3E27';
wwv_flow_imp.g_varchar2_table(77) := '202B200D0A20202020273C696E7075742027202B20726561646F6E6C79202B202720747970653D226E756D626572222069643D2227202B20705F6974656D5F6964202B20275F6C6F6E6769747564655F6465677265657322207374796C653D2277696474';
wwv_flow_imp.g_varchar2_table(78) := '683A203130252220636C6173733D2275692D746578746669656C64222073697A653D2227202B20656E7472795F73697A65202B2027222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D6465672220666F723D226C6F6E6769';
wwv_flow_imp.g_varchar2_table(79) := '747564655F64656772656573223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B272B0D0A20202020273C696E7075742027202B20726561646F6E6C79202B202720747970653D226E756D626572222069643D2227202B';
wwv_flow_imp.g_varchar2_table(80) := '20705F6974656D5F6964202B20275F6C6F6E6769747564655F6D696E7574657322207374796C653D2277696474683A203130252220636C6173733D2275692D746578746669656C64222073697A653D2227202B20656E7472795F73697A65202B2027222F';
wwv_flow_imp.g_varchar2_table(81) := '3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D6D696E2220666F723D226C6F6E6769747564655F6D696E75746573223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B272B0D0A2020202027';
wwv_flow_imp.g_varchar2_table(82) := '3C696E7075742027202B20726561646F6E6C79202B202720747970653D226E756D626572222069643D2227202B20705F6974656D5F6964202B20275F6C6F6E6769747564655F7365636F6E647322207374796C653D2277696474683A203135252220636C';
wwv_flow_imp.g_varchar2_table(83) := '6173733D2275692D746578746669656C64222073697A653D2227202B20656E7472795F73697A65202B2027222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D7365632220666F723D226C6F6E6769747564655F7365636F6E';
wwv_flow_imp.g_varchar2_table(84) := '6473223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B272B0D0A20202020273C62722F3E27202B200D0A20202020273C6C6162656C2020636C6173733D226D622D6C6174223E266E6273703B266E6273703B3C737061';
wwv_flow_imp.g_varchar2_table(85) := '6E20636C6173733D226D622D737063223E266E6273703B266E6273703B3C2F7370616E3E267468696E73703B267468696E73703B3C2F6C6162656C3E272B0D0A20202020273C696E7075742027202B20726561646F6E6C79202B202720747970653D226E';
wwv_flow_imp.g_varchar2_table(86) := '756D626572222069643D2227202B20705F6974656D5F6964202B20275F6C617469747564655F6465677265657322207374796C653D2277696474683A203130252220636C6173733D2275692D746578746669656C64222073697A653D2227202B20656E74';
wwv_flow_imp.g_varchar2_table(87) := '72795F73697A65202B2027222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D6465672220666F723D226C617469747564655F64656772656573223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E62';
wwv_flow_imp.g_varchar2_table(88) := '73703B272B0D0A20202020273C696E7075742027202B20726561646F6E6C79202B202720747970653D226E756D626572222069643D2227202B20705F6974656D5F6964202B20275F6C617469747564655F6D696E7574657322207374796C653D22776964';
wwv_flow_imp.g_varchar2_table(89) := '74683A20313025222020636C6173733D2275692D746578746669656C64222073697A653D2227202B20656E7472795F73697A65202B2027222F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D6D696E2220666F723D226C6174';
wwv_flow_imp.g_varchar2_table(90) := '69747564655F6D696E75746573223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B272B0D0A20202020273C696E7075742027202B20726561646F6E6C79202B202720747970653D226E756D626572222069643D222720';
wwv_flow_imp.g_varchar2_table(91) := '2B20705F6974656D5F6964202B20275F6C617469747564655F7365636F6E64732220207374796C653D2277696474683A203135252220636C6173733D2275692D746578746669656C64222073697A653D2227202B20656E7472795F73697A65202B202722';
wwv_flow_imp.g_varchar2_table(92) := '2F3E266E6273703B3C6C6162656C20636C6173733D226D622D6C6162656C2D7365632220666F723D226C617469747564655F7365636F6E6473223E3C2F6C6162656C3E266E6273703B266E6273703B266E6273703B266E6273703B272B0D0A2020202027';
wwv_flow_imp.g_varchar2_table(93) := '3C2F6469763E273B0D0A20202020617065782E6A517565727928272327202B20705F726567696F6E5F6964202B20275F6D61705F726567696F6E27292E617070656E64282428636F6F7264666F726D29293B0D0A20207D0D0A20200D0A20202F2A0D0A20';
wwv_flow_imp.g_varchar2_table(94) := '20202A2063616C6C20616A61782073657276696365206F662074686520706C7567696E20776974682074686520696E7075742067656F6D6574727920746F207772697465206974206261636B20746F207468652070616765206974656D20616E6420696E';
wwv_flow_imp.g_varchar2_table(95) := '7075742067656F6D6574727920636F6C6C656374696F6E0D0A2020202A2061732077656C6C206B6E6F7720746578742E204C6172676520646174612069732073747265616D65642E0D0A2020202A2F0D0A202066756E6374696F6E20777269746547656F';
wwv_flow_imp.g_varchar2_table(96) := '6D657472792867656F6D6574727929207B0D0A202020206966202821705F6F7074696F6E732E77726974656261636B5F656E61626C656429207B0D0A202020202020617065782E6576656E742E7472696767657228617065782E6A517565727928222322';
wwv_flow_imp.g_varchar2_table(97) := '202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F6472617763726561746522293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A202020207661722064656661756C745F637572736F72';
wwv_flow_imp.g_varchar2_table(98) := '203D20646F63756D656E742E626F64792E7374796C652E637572736F723B0D0A202020206966202864656661756C745F637572736F72203D3D20226E6F742D616C6C6F7765642229207B0D0A20202020202064656661756C745F637572736F72203D206E';
wwv_flow_imp.g_varchar2_table(99) := '756C6C3B0D0A0920207D0D0A20202020696620282167656F6D6574727929207B0D0A202020202020617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B0D0A20202020202020207831303A20225752495445';
wwv_flow_imp.g_varchar2_table(100) := '4241434B222C0D0A20202020202020207830323A206E756C6C2C0D0A20202020202020207830333A206E756C6C0D0A2020202020207D2C207B0D0A2020202020202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(101) := '202020202020646F63756D656E742E626F64792E7374796C652E637572736F72203D2064656661756C745F637572736F723B0D0A20202020202020207D2C0D0A20202020202020206572726F723A2066756E6374696F6E20286A717868722C2073746174';
wwv_flow_imp.g_varchar2_table(102) := '75732C2065727229207B0D0A20202020202020202020646F63756D656E742E626F64792E7374796C652E637572736F72203D2064656661756C745F637572736F723B0D0A20202020202020202020617065785F616C65727428657272293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(103) := '202020207D0D0A2020202020207D293B0D0A202020207D20656C7365207B0D0A2020202020202F2F2074686973206461746120636F756C64206265206269672E204C657427732073747265616D206974206261636B20746F20746865207365727665720D';
wwv_flow_imp.g_varchar2_table(104) := '0A2020202020202F2F2069662077652061726520686F6C64696E6720697420696E206120636F6C6C656374696F6E2074686572652E20646F2074686973207468726F7567680D0A2020202020202F2F20636861696E656420616A61782063616C6C732E20';
wwv_flow_imp.g_varchar2_table(105) := '7573652074686520637572736F722069636F6E20746F206C65742075736572206B6E6F770D0A2020202020202F2F20746861742064617461206973206265696E67207472616E736665727265642E0D0A20202020202066756E6374696F6E206368756E6B';
wwv_flow_imp.g_varchar2_table(106) := '28646174612C207374617274496E6465782C206275666665724C656E2C207375636365737346756E6329207B0D0A2020202020202020696620287374617274496E646578203E3D20646174612E6C656E67746829207B0D0A202020202020202020207375';
wwv_flow_imp.g_varchar2_table(107) := '636365737346756E6328293B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B0D0A2020202020202020202020207831303A20';
wwv_flow_imp.g_varchar2_table(108) := '2257524954454241434B222C0D0A2020202020202020202020207830323A20646174612E737562737472287374617274496E6465782C206275666665724C656E292C0D0A2020202020202020202020207830333A207374617274496E6465780D0A202020';
wwv_flow_imp.g_varchar2_table(109) := '202020202020207D2C200D0A202020202020202020207B0D0A202020202020202020202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A20202020202020202020202020206368756E6B28646174612C207374617274496E64';
wwv_flow_imp.g_varchar2_table(110) := '6578202B206275666665724C656E2C206275666665724C656E2C207375636365737346756E63293B0D0A2020202020202020202020207D2C0D0A2020202020202020202020206572726F723A2066756E6374696F6E20286A717868722C20737461747573';
wwv_flow_imp.g_varchar2_table(111) := '2C2065727229207B0D0A2020202020202020202020202020617065785F616C65727428657272293B0D0A2020202020202020202020207D0D0A202020202020202020207D293B0D0A20202020202020207D0D0A2020202020207D0D0A202020202020646F';
wwv_flow_imp.g_varchar2_table(112) := '63756D656E742E626F64792E7374796C652E637572736F72203D20226E6F742D616C6C6F776564223B0D0A2020202020206368756E6B2867656F6D657472792C20302C2033303030302C2066756E6374696F6E202829207B200D0A20202020202020202F';
wwv_flow_imp.g_varchar2_table(113) := '2F206F6E63652074686520777269746520697320636F6D706C6574652C20726573746F72652074686520637572736F7220616E64207472696767657220616E206576656E7420746F206265207573656420696E20415045582E0D0A202020202020202064';
wwv_flow_imp.g_varchar2_table(114) := '6F63756D656E742E626F64792E7374796C652E637572736F72203D2064656661756C745F637572736F723B200D0A2020202020202020617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B20705F6974656D5F6964';
wwv_flow_imp.g_varchar2_table(115) := '292C20226D696C5F61726D795F75736163655F6D6170626974735F6472617763726561746522293B0D0A2020202020207D293B0D0A202020207D0D0A20207D0D0A0D0A20202F2F205374617469634D6F64652069732075736564207768656E2074686520';
wwv_flow_imp.g_varchar2_table(116) := '6974656D2069732073657420746F2072656164206F6E6C792C200D0A20202F2F20746F2073686F7720612070726576696F75736C7920647261776E2067656F6D657472792C20627574206E6F7420746F20656469742069742E0D0A202076617220537461';
wwv_flow_imp.g_varchar2_table(117) := '7469634D6F6465203D207B7D3B0D0A20205374617469634D6F64652E6F6E5365747570203D2066756E6374696F6E2829207B0D0A20202020746869732E736574416374696F6E61626C65537461746528293B202F2F2064656661756C7420616374696F6E';
wwv_flow_imp.g_varchar2_table(118) := '61626C652073746174652069732066616C736520666F7220616C6C20616374696F6E730D0A2020202072657475726E207B7D3B0D0A20207D3B0D0A20205374617469634D6F64652E746F446973706C61794665617475726573203D2066756E6374696F6E';
wwv_flow_imp.g_varchar2_table(119) := '2873746174652C2067656F6A736F6E2C20646973706C617929207B0D0A20202020646973706C61792867656F6A736F6E293B0D0A20207D3B0D0A2020766172206D6F646573203D204D6170626F78447261772E6D6F6465733B0D0A20206D6F6465732E73';
wwv_flow_imp.g_varchar2_table(120) := '7461746963203D205374617469634D6F64653B0D0A20200D0A202066756E6374696F6E2069734576656E744174436F6F7264696E61746573286576656E742C20636F6F7264696E6174657329207B0D0A2020202069662028216576656E742E6C6E674C61';
wwv_flow_imp.g_varchar2_table(121) := '74292072657475726E2066616C73653B0D0A2020202072657475726E206576656E742E6C6E674C61742E6C6E67203D3D3D20636F6F7264696E617465735B305D202626206576656E742E6C6E674C61742E6C6174203D3D3D20636F6F7264696E61746573';
wwv_flow_imp.g_varchar2_table(122) := '5B315D3B0D0A20207D0D0A20200D0A20202F2F204F7665727269646520746865206B657975702066756E6374696F6E206F6E20647261775F6C696E655F737472696E67206D6F6465206F66204D6170626F78206472617720746F20726573706F6E642074';
wwv_flow_imp.g_varchar2_table(123) := '6F207468652067656F6C6F636174696F6E0D0A20202F2F20627574746F6E20636C69636B2E205468652067656F6C6F636174696F6E20627574746F6E2077696C6C20696E697469617465206120286029206B65797570206576656E742E200D0A20206D6F';
wwv_flow_imp.g_varchar2_table(124) := '6465732E647261775F6C696E655F737472696E672E6F6E4B65795570203D2066756E6374696F6E2873746174652C206529207B0D0A2020202069662028652E6B6579436F6465203D3D3D20313329207B0D0A202020202020746869732E6368616E67654D';
wwv_flow_imp.g_varchar2_table(125) := '6F6465282773696D706C655F73656C656374272C207B20666561747572654964733A205B73746174652E6C696E652E69645D207D293B0D0A202020207D20656C73652069662028652E6B6579436F6465203D3D3D20323729207B0D0A2020202020207468';
wwv_flow_imp.g_varchar2_table(126) := '69732E64656C65746546656174757265285B73746174652E6C696E652E69645D2C207B2073696C656E743A2074727565207D293B0D0A202020202020746869732E6368616E67654D6F6465282773696D706C655F73656C65637427293B0D0A202020207D';
wwv_flow_imp.g_varchar2_table(127) := '20656C736520696628652E6B6579203D3D2027602729207B0D0A2020202020206966202873746174652E63757272656E74566572746578506F736974696F6E203E20302026262069734576656E744174436F6F7264696E6174657328652C207374617465';
wwv_flow_imp.g_varchar2_table(128) := '2E6C696E652E636F6F7264696E617465735B73746174652E63757272656E74566572746578506F736974696F6E202D20315D29207C7C0D0A202020202020202073746174652E646972656374696F6E203D3D3D20276261636B7761726473272026262069';
wwv_flow_imp.g_varchar2_table(129) := '734576656E744174436F6F7264696E6174657328652C2073746174652E6C696E652E636F6F7264696E617465735B73746174652E63757272656E74566572746578506F736974696F6E202B20315D2929207B0D0A202020202020202072657475726E2074';
wwv_flow_imp.g_varchar2_table(130) := '6869732E6368616E67654D6F6465282773696D706C655F73656C656374272C207B20666561747572654964733A205B73746174652E6C696E652E69645D207D293B0D0A2020202020207D0D0A202020202020746869732E7570646174655549436C617373';
wwv_flow_imp.g_varchar2_table(131) := '6573287B206D6F7573653A202761646427207D293B0D0A0D0A2020202020206E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E2866756E6374696F6E28706F73297B0D0A202020202020202073746174';
wwv_flow_imp.g_varchar2_table(132) := '652E6C696E652E757064617465436F6F7264696E6174652873746174652E63757272656E74566572746578506F736974696F6E2C20706F732E636F6F7264732E6C6F6E6769747564652C20706F732E636F6F7264732E6C61746974756465293B20202020';
wwv_flow_imp.g_varchar2_table(133) := '20200D0A20202020202020206966202873746174652E646972656374696F6E203D3D3D2027666F72776172642729207B0D0A2020202020202020202073746174652E63757272656E74566572746578506F736974696F6E2B2B3B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(134) := '202073746174652E6C696E652E757064617465436F6F7264696E6174652873746174652E63757272656E74566572746578506F736974696F6E2C20705B305D2C20705B315D293B0D0A20202020202020207D20656C7365207B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(135) := '2073746174652E6C696E652E616464436F6F7264696E61746528302C20705B305D2C20705B315D293B0D0A20202020202020207D0D0A2020202020207D2C2066756E6374696F6E2865727229207B0D0A20202020202020207661722070203D205B2D3930';
wwv_flow_imp.g_varchar2_table(136) := '202B2028302E30312A4D6174682E72616E646F6D2829202D20302E303035292C203330202B2028302E30312A4D6174682E72616E646F6D2829202D20302E303035295D3B0D0A20202020202020202F2F20756E636F6D6D656E74207468697320746F2074';
wwv_flow_imp.g_varchar2_table(137) := '65737420696E204368726F6D652E0D0A202020202020202073746174652E6C696E652E757064617465436F6F7264696E6174652873746174652E63757272656E74566572746578506F736974696F6E2C20705B305D2C20705B315D293B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(138) := '202020202020200D0A20202020202020206966202873746174652E646972656374696F6E203D3D3D2027666F72776172642729207B0D0A2020202020202020202073746174652E63757272656E74566572746578506F736974696F6E2B2B3B0D0A202020';
wwv_flow_imp.g_varchar2_table(139) := '2020202020202073746174652E6C696E652E757064617465436F6F7264696E6174652873746174652E63757272656E74566572746578506F736974696F6E2C20705B305D2C20705B315D293B0D0A20202020202020207D20656C7365207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(140) := '20202020202073746174652E6C696E652E616464436F6F7264696E61746528302C20705B305D2C20705B315D293B0D0A20202020202020207D0D0A2020202020207D293B0D0A202020207D0D0A20207D3B0D0A20200D0A20206D6F6465732E647261775F';
wwv_flow_imp.g_varchar2_table(141) := '706F6C79676F6E2E6F6E4B65795570203D2066756E6374696F6E2873746174652C206529207B0D0A202020202F2F2068616E646C6520656E74657220616E6420657363617065206173206265666F72650D0A2020202069662028652E6B6579436F646520';
wwv_flow_imp.g_varchar2_table(142) := '3D3D3D20323729207B0D0A202020202020746869732E64656C65746546656174757265285B73746174652E706F6C79676F6E2E69645D2C207B2073696C656E743A2074727565207D293B0D0A202020202020746869732E6368616E67654D6F6465282773';
wwv_flow_imp.g_varchar2_table(143) := '696D706C655F73656C65637427293B0D0A202020207D20656C73652069662028652E6B6579436F6465203D3D3D20313329207B0D0A202020202020746869732E6368616E67654D6F6465282773696D706C655F73656C656374272C207B20666561747572';
wwv_flow_imp.g_varchar2_table(144) := '654964733A205B73746174652E706F6C79676F6E2E69645D207D293B0D0A202020207D20656C736520696628652E6B6579203D3D2027602729207B0D0A2020202020206966202873746174652E63757272656E74566572746578506F736974696F6E203E';
wwv_flow_imp.g_varchar2_table(145) := '20302026262069734576656E744174436F6F7264696E6174657328652C2073746174652E706F6C79676F6E2E636F6F7264696E617465735B305D5B73746174652E63757272656E74566572746578506F736974696F6E202D20315D2929207B0D0A202020';
wwv_flow_imp.g_varchar2_table(146) := '202020202072657475726E20746869732E6368616E67654D6F6465282773696D706C655F73656C656374272C207B20666561747572654964733A205B73746174652E706F6C79676F6E2E69645D207D293B0D0A2020202020207D0D0A2020202020207468';
wwv_flow_imp.g_varchar2_table(147) := '69732E7570646174655549436C6173736573287B206D6F7573653A202761646427207D293B0D0A0D0A2020202020206E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E2866756E6374696F6E28706F73';
wwv_flow_imp.g_varchar2_table(148) := '297B0D0A202020202020202073746174652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B73746174652E63757272656E74566572746578506F736974696F6E7D602C20706F732E636F6F7264732E6C6F6E6769747564652C';
wwv_flow_imp.g_varchar2_table(149) := '20706F732E636F6F7264732E6C61746974756465293B2020202020200D0A202020202020202073746174652E63757272656E74566572746578506F736974696F6E2B2B3B0D0A202020202020202073746174652E706F6C79676F6E2E757064617465436F';
wwv_flow_imp.g_varchar2_table(150) := '6F7264696E6174652860302E247B73746174652E63757272656E74566572746578506F736974696F6E7D602C20706F732E636F6F7264732E6C6F6E6769747564652C20706F732E636F6F7264732E6C61746974756465293B0D0A2020202020207D2C2066';
wwv_flow_imp.g_varchar2_table(151) := '756E6374696F6E2865727229207B0D0A20202020202020207661722070203D205B2D3930202B2028302E30312A4D6174682E72616E646F6D2829202D20302E303035292C203330202B2028302E30312A4D6174682E72616E646F6D2829202D20302E3030';
wwv_flow_imp.g_varchar2_table(152) := '35295D3B0D0A20202020202020202F2F20756E636F6D6D656E74207468697320746F207465737420696E204368726F6D652E0D0A202020202020202073746174652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B73746174';
wwv_flow_imp.g_varchar2_table(153) := '652E63757272656E74566572746578506F736974696F6E7D602C20705B305D2C20705B315D293B0D0A202020202020202073746174652E63757272656E74566572746578506F736974696F6E2B2B3B0D0A202020202020202073746174652E706F6C7967';
wwv_flow_imp.g_varchar2_table(154) := '6F6E2E757064617465436F6F7264696E6174652860302E247B73746174652E63757272656E74566572746578506F736974696F6E7D602C20705B305D2C20705B315D293B0D0A2020202020207D293B0D0A202020207D0D0A20207D3B0D0A20200D0A2020';
wwv_flow_imp.g_varchar2_table(155) := '2F2F2043726561746520746865206472617720746F6F6C2E20506F696E742067656F6D657472792077617320746F6F20736D616C6C2C20736F2049206D616465206974206C61726765723B205374796C6520697320636F706965642066726F6D206D6170';
wwv_flow_imp.g_varchar2_table(156) := '626F782D64726177202F6C69622F7468656D652E6A73207769746820696E6372656173656420706F696E742073697A652E200D0A20206D61702E64726177203D206E6577204D6170626F7844726177287B0D0A20202020646973706C6179436F6E74726F';
wwv_flow_imp.g_varchar2_table(157) := '6C7344656661756C743A2066616C73652C0D0A20202020636F6E74726F6C733A207B0D0A202020202020706F696E743A20705F67656F6D657472795F6D6F6465732E696E6465784F662822504F494E542229203E202D312C0D0A2020202020206C696E65';
wwv_flow_imp.g_varchar2_table(158) := '5F737472696E673A20705F67656F6D657472795F6D6F6465732E696E6465784F6628224C494E452229203E202D312C0D0A202020202020706F6C79676F6E3A20705F67656F6D657472795F6D6F6465732E696E6465784F662822504F4C59474F4E222920';
wwv_flow_imp.g_varchar2_table(159) := '3E202D312C0D0A20202020202074726173683A2021705F726561646F6E6C792C0D0A2020202020206D6F6465733A206D6F6465730D0A202020207D2C207374796C6573203A204D4150424954535F44454641554C545F445241575F5354594C45530D0A20';
wwv_flow_imp.g_varchar2_table(160) := '207D293B0D0A202069662028705F656E61626C655F67656F6C6F6361746529207B0D0A202020206D61702E616464436F6E74726F6C2867656F6C6F636174655F706F696E745F636F6E74726F6C293B0D0A20207D0D0A0D0A202076617220656E7472795F';
wwv_flow_imp.g_varchar2_table(161) := '73697A65203D2031303B0D0A20206D61702E616464436F6E74726F6C286D61702E64726177293B090D0A20202F2F204163636F6D6F6461746520626F7468204D6170626F7820696E204150455820323120616E64204D61706C6962726520696E20415045';
wwv_flow_imp.g_varchar2_table(162) := '582032322E090D0A2020617065782E6A517565727928272E6D6170626F78676C2D6374726C2D67726F757027292E616464436C61737328276D61706C69627265676C2D6374726C2D67726F757027293B0D0A2020617065782E6A517565727928272E6D61';
wwv_flow_imp.g_varchar2_table(163) := '70626F78676C2D6374726C27292E616464436C61737328276D61706C69627265676C2D6374726C27293B0D0A0D0A2020636F6E73742073746F70456E746572203D20286576656E7429203D3E207B0D0A202020202F2F206D616B65207375726520707265';
wwv_flow_imp.g_varchar2_table(164) := '7373696E6720656E74657220646F65736E2774207375626D6974207468652070616765206F72207072657373206120627574746F6E0D0A20202020696620286576656E743F2E6B6579203D3D3D2027456E7465722729207B0D0A2020202020206576656E';
wwv_flow_imp.g_varchar2_table(165) := '742E70726576656E7444656661756C7428293B0D0A202020207D0D0A20207D3B0D0A20200D0A20202F2F20696E697469616C697A65206C617469747564652F6C6F6E676974756465206461746120656E747279206669656C64730D0A202069662028705F';
wwv_flow_imp.g_varchar2_table(166) := '73686F775F636F6F72647329207B0D0A20202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6F6E6769747564655F6465677265657327292E6368616E67652873796E6347656F6D6574727946726F6D436F6F7264';
wwv_flow_imp.g_varchar2_table(167) := '696E61746573292E6B657970726573732873746F70456E746572293B0D0A20202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6F6E6769747564655F6D696E7574657327292E6368616E67652873796E6347656F';
wwv_flow_imp.g_varchar2_table(168) := '6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F70456E746572293B0D0A20202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6F6E6769747564655F7365636F6E647327292E';
wwv_flow_imp.g_varchar2_table(169) := '6368616E67652873796E6347656F6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F70456E746572293B0D0A20202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6174697475';
wwv_flow_imp.g_varchar2_table(170) := '64655F6465677265657327292E6368616E67652873796E6347656F6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F70456E746572293B0D0A20202020617065782E6A517565727928272327202B20705F6974656D5F';
wwv_flow_imp.g_varchar2_table(171) := '6964202B20275F6C617469747564655F6D696E7574657327292E6368616E67652873796E6347656F6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F70456E746572293B0D0A20202020617065782E6A517565727928';
wwv_flow_imp.g_varchar2_table(172) := '272327202B20705F6974656D5F6964202B20275F6C617469747564655F7365636F6E647327292E6368616E67652873796E6347656F6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F70456E746572293B0D0A20207D';
wwv_flow_imp.g_varchar2_table(173) := '0D0A0D0A20202F2F20696620746865726520697320616E20696E697469616C2067656F6D657472792C2061646420697420746F20746865206D617020616E642070616E20746F2069742C207A6F6F6D20746F20697420696620697427732061206C696E65';
wwv_flow_imp.g_varchar2_table(174) := '206F7220706F6C79676F6E2E0D0A202069662028705F67656F6D6574727920213D206E756C6C20262620705F67656F6D6574727920213D20222229207B0D0A202020206D61702E647261772E61646428705F67656F6D65747279293B200D0A2020202069';
wwv_flow_imp.g_varchar2_table(175) := '662028705F67656F6D657472792E74797065203D3D2022506F696E742229207B0D0A20202020202069662028705F73686F775F636F6F72647329207B0D0A202020202020202073796E63436F6F72647346726F6D47656F6D6574727928705F67656F6D65';
wwv_flow_imp.g_varchar2_table(176) := '747279293B0D0A2020202020207D202020200D0A2020202020202F2F207265706C61636564206D6F7665746F20616E642073657463656E7465722077697468206A756D70746F20746F206669782070726F626C656D20776974682066697273742072656E';
wwv_flow_imp.g_varchar2_table(177) := '6465722E0D0A202020202020747279207B0D0A20202020202020206D61702E6A756D70546F287B63656E7465723A20705F67656F6D657472792E636F6F7264696E617465732C207A6F6F6D203A20705F706F696E745F7A6F6F6D5F6C6576656C2C206475';
wwv_flow_imp.g_varchar2_table(178) := '726174696F6E3A20323030307D293B0D0A2020202020207D2063617463682028657863707429207B0D0A2020202020202020636F6E736F6C652E6C6F6728275B4D61706269747320447261775D204661696C656420746F206A756D7020746F20696E6974';
wwv_flow_imp.g_varchar2_table(179) := '69616C206C6F636174696F6E2E27293B0D0A2020202020207D0D0A202020207D20656C7365207B0D0A0920207661722062203D20676574426F756E647328705F67656F6D65747279293B0D0A2020202020206D61702E666974426F756E647328622C207B';
wwv_flow_imp.g_varchar2_table(180) := '70616464696E673A2035307D293B0D0A202020207D0D0A2020202020200D0A20207D0D0A202069662028705F726561646F6E6C7929207B0D0A202020206D61702E647261772E6368616E67654D6F6465282773746174696327293B0D0A20207D0D0A2020';
wwv_flow_imp.g_varchar2_table(181) := '0D0A20206D61702E647261777665727469636573203D207B6964203A20373938312C2074797065203A202246656174757265222C2070726F70657274696573203A207B7D2C2067656F6D65747279203A207B747970653A20224C696E65537472696E6722';
wwv_flow_imp.g_varchar2_table(182) := '2C20636F6F7264696E61746573203A205B5D7D7D3B0D0A20200D0A20202F2F2048616E646C6520647261772066696E6973686564206576656E743A2077726974652067656F6D65747279200D0A20202F2F20746F204150455820636F6C6C656374696F6E';
wwv_flow_imp.g_varchar2_table(183) := '207573696E6720616A61782063616C6C6261636B2E0D0A20202F2F2049662074686520636F6F7264696E6174657320656E747279206669656C647320617265207475726E6564206F6E2C0D0A20202F2F20757064617465207468656D2077697468207468';
wwv_flow_imp.g_varchar2_table(184) := '65206E657720636F6F7264696E617465732066726F6D2074686520506F696E74200D0A20202F2F2067656F6D657472792E0D0A20206D61702E6F6E2822647261772E637265617465222C2066756E6374696F6E286529207B0D0A20202020766172206665';
wwv_flow_imp.g_varchar2_table(185) := '617473203D206D61702E647261772E676574416C6C28293B0D0A20202020666F722876617220693D303B693C66656174732E66656174757265732E6C656E6774682D313B692B2B29207B0D0A20202020202069662028652E66656174757265735B305D2E';
wwv_flow_imp.g_varchar2_table(186) := '696420213D2066656174732E66656174757265735B695D2E696429207B0D0A20202020202020206D61702E647261772E64656C6574652866656174732E66656174757265735B695D2E6964293B0D0A2020202020207D0D0A202020207D0D0A2020202066';
wwv_flow_imp.g_varchar2_table(187) := '65617473203D206D61702E647261772E676574416C6C28293B0D0A202020207661722067656F6D203D2066656174732E66656174757265735B305D2E67656F6D657472793B0D0A2020202069662028705F73686F775F636F6F72647329207B0D0A202020';
wwv_flow_imp.g_varchar2_table(188) := '20202073796E63436F6F72647346726F6D47656F6D657472792867656F6D293B0D0A202020207D0D0A20202020777269746547656F6D65747279284A534F4E2E737472696E676966792867656F6D29293B0D0A20207D293B0D0A20200D0A20206D61702E';
wwv_flow_imp.g_varchar2_table(189) := '6F6E2822647261772E757064617465222C2066756E6374696F6E286529207B0D0A20202020766172206665617473203D206D61702E647261772E676574416C6C28293B0D0A202020207661722067656F6D203D2066656174732E66656174757265735B30';
wwv_flow_imp.g_varchar2_table(190) := '5D2E67656F6D657472793B0D0A2020202069662028705F73686F775F636F6F72647329207B0D0A20202020202073796E63436F6F72647346726F6D47656F6D657472792867656F6D293B0D0A202020207D0D0A20202020777269746547656F6D65747279';
wwv_flow_imp.g_varchar2_table(191) := '284A534F4E2E737472696E676966792867656F6D29293B0D0A20207D293B0D0A20200D0A20200D0A202066756E6374696F6E2075706461746547656F6C6F636174696F6E427574746F6E446973706C6179286D6F64652C206E73656C6563746564466561';
wwv_flow_imp.g_varchar2_table(192) := '747572657329207B0D0A20202020766172206D6F6465203D206D61702E647261772E6765744D6F646528293B0D0A20202020766172206E73656C65637465644665617475726573203D206D61702E647261772E67657453656C656374656428292E666561';
wwv_flow_imp.g_varchar2_table(193) := '74757265732E6C656E6774683B0D0A2020202069662028705F656E61626C655F67656F6C6F6361746529207B0D0A202020202020696620286D6F6465203D3D20226469726563745F73656C65637422207C7C206D6F6465203D3D2022647261775F706F69';
wwv_flow_imp.g_varchar2_table(194) := '6E7422207C7C206D6F6465203D3D2022647261775F6C696E655F737472696E6722207C7C206D6F6465203D3D2022647261775F706F6C79676F6E2229207B0D0A202020202020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E67657442';
wwv_flow_imp.g_varchar2_table(195) := '7574746F6E28292E7374796C652E646973706C61793D2027626C6F636B273B0D0A2020202020207D20656C7365207B0D0A2020202020202020696620286D6F6465203D3D202773696D706C655F73656C6563742729207B0D0A2020202020202020202069';
wwv_flow_imp.g_varchar2_table(196) := '66286E73656C65637465644665617475726573203E203029207B0D0A20202020202020202020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E676574427574746F6E28292E7374796C652E646973706C6179203D2027626C6F636B273B';
wwv_flow_imp.g_varchar2_table(197) := '0D0A202020202020202020207D20656C7365207B0D0A20202020202020202020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E676574427574746F6E28292E7374796C652E646973706C6179203D20276E6F6E65273B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(198) := '20202020207D0D0A20202020202020207D0D0A2020202020207D0D0A202020207D0D0A20207D0D0A20200D0A20202F2F2049662074686520636F6F7264696E6174657320656E747279206669656C647320617265207475726E6564206F6E2C2073686F77';
wwv_flow_imp.g_varchar2_table(199) := '207468656D200D0A20202F2F207768656E207468652064726177696E67206D6F646520697320506F696E742E204F74686572776973652C2068696465207468656D2E0D0A20202F2F20456E61626C652047656F6C6F6361746520506F696E7420746F6F6C';
wwv_flow_imp.g_varchar2_table(200) := '20627574746F6E206966207573657220697320696E206472617720706F696E74206D6F6465206F7220696620746865207665727465780D0A20202F2F206F6E2061206E6F6E2D706F696E742067656F6D657472792069732073656C65637465642E0D0A20';
wwv_flow_imp.g_varchar2_table(201) := '206D61702E6F6E2822647261772E6D6F64656368616E6765222C2066756E6374696F6E286529207B0D0A2020202069662028705F73686F775F636F6F72647329207B0D0A20202020202069662028652E6D6F6465203D3D2022647261775F706F696E7422';
wwv_flow_imp.g_varchar2_table(202) := '29207B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F636F6F72647327292E6373732827646973706C6179272C2027626C6F636B27293B0D0A2020202020207D20656C73652069662028652E6D';
wwv_flow_imp.g_varchar2_table(203) := '6F6465203D3D2022647261775F6C696E655F737472696E6722207C7C20652E6D6F6465203D3D2022647261775F706F6C79676F6E2229207B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F636F';
wwv_flow_imp.g_varchar2_table(204) := '6F72647327292E6373732827646973706C6179272C20276E6F6E6527293B0D0A2020202020207D0D0A202020207D0D0A2020202075706461746547656F6C6F636174696F6E427574746F6E446973706C617928293B0D0A20207D293B0D0A20200D0A2020';
wwv_flow_imp.g_varchar2_table(205) := '206D61702E6F6E2822647261772E73656C656374696F6E6368616E6765222C2066756E6374696F6E286529207B0D0A202020202075706461746547656F6C6F636174696F6E427574746F6E446973706C617928293B0D0A2020207D293B0D0A20200D0A20';
wwv_flow_imp.g_varchar2_table(206) := '2069662028705F656E61626C655F67656F6C6F6361746529207B0D0A2020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E676574427574746F6E28292E6F6E636C69636B203D2066756E6374696F6E286529207B202020200D0A202020';
wwv_flow_imp.g_varchar2_table(207) := '202020766172206D6F6465203D206D61702E647261772E6765744D6F646528293B202020200D0A20202020202066756E6374696F6E2075706461746546726F6D47656F6C6F636174696F6E28636F6F7264696E61746529207B0D0A202020202020202069';
wwv_flow_imp.g_varchar2_table(208) := '6620286D6F6465203D3D2027647261775F706F696E742729207B0D0A202020202020202020202F2F206D6F6465206973206472617720706F696E743B207365742074686520706F696E74206C6F636174696F6E2066726F6D207468652067656F6C6F6361';
wwv_flow_imp.g_varchar2_table(209) := '746F722E0D0A20202020202020202020766172207074203D206D61702E647261772E736574287B747970653A202746656174757265436F6C6C656374696F6E272C206665617475726573203A5B7B74797065203A202246656174757265222C2070726F70';
wwv_flow_imp.g_varchar2_table(210) := '657274696573203A207B7D2C2067656F6D65747279203A207B74797065203A2022506F696E74222C20636F6F7264696E61746573203A20636F6F7264696E6174657D7D5D7D293B0D0A202020202020202020200D0A202020202020202020202F2F204E65';
wwv_flow_imp.g_varchar2_table(211) := '656420746F206D6F7665207468697320736F6D65776865726520656C736520696620706F737369626C652E0D0A2020202020202020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E676574427574746F6E28292E7374796C652E646973';
wwv_flow_imp.g_varchar2_table(212) := '706C6179203D20276E6F6E65273B0D0A20202020202020207D20656C736520696620286D6F6465203D3D202773696D706C655F73656C6563742729207B0D0A20202020202020202020696620286D61702E647261772E67657453656C656374656428292E';
wwv_flow_imp.g_varchar2_table(213) := '66656174757265732E6C656E677468203E203029207B0D0A2020202020202020202020207661722073656C656374656446656174757265203D206D61702E647261772E67657453656C656374656428292E66656174757265735B305D3B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(214) := '2020202020202073656C6563746564466561747572652E67656F6D657472792E636F6F7264696E617465735B305D203D20636F6F7264696E6174655B305D3B0D0A20202020202020202020202073656C6563746564466561747572652E67656F6D657472';
wwv_flow_imp.g_varchar2_table(215) := '792E636F6F7264696E617465735B315D203D20636F6F7264696E6174655B315D3B0D0A202020202020202020202020206D61702E647261772E736574287B747970653A202246656174757265436F6C6C656374696F6E222C206665617475726573203A5B';
wwv_flow_imp.g_varchar2_table(216) := '73656C6563746564466561747572655D7D293B0D0A202020202020202020207D0D0A20202020202020207D20656C736520696620286D6F6465203D3D20276469726563745F73656C6563742729207B0D0A202020202020202020202F2F20646972656374';
wwv_flow_imp.g_varchar2_table(217) := '2073656C6563743A206120766572746578206F66206120706F6C79676F6E206F72206C696E65737472696E672069732073656C65637465642E204D6F76650D0A202020202020202020202F2F207468652073656C65637465642076657274657820746F20';
wwv_flow_imp.g_varchar2_table(218) := '7468652067656F6C6F636174696F6E20636F6F7264696E6174652E0D0A202020202020202020207661722073656C656374656446656174757265203D206D61702E647261772E67657453656C656374656428292E66656174757265735B305D3B0D0A2020';
wwv_flow_imp.g_varchar2_table(219) := '20202020202020207661722073656C6563746564436F6F726473203D206D61702E647261772E67657453656C6563746564506F696E747328292E66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465733B0D0A2020202020200D';
wwv_flow_imp.g_varchar2_table(220) := '0A2020202020202020202066756E6374696F6E205F5F736574436F6F726428636F6F7264417272617929207B0D0A202020202020202020202020666F722028766172206A3D303B6A3C636F6F726441727261792E6C656E6774683B6A2B2B29207B0D0A20';
wwv_flow_imp.g_varchar2_table(221) := '202020202020202020202020206966202873656C6563746564436F6F7264735B305D203D3D20636F6F726441727261795B6A5D5B305D2026262073656C6563746564436F6F7264735B315D203D3D20636F6F726441727261795B6A5D5B315D29207B0D0A';
wwv_flow_imp.g_varchar2_table(222) := '20202020202020202020202020202020636F6F726441727261795B6A5D5B305D203D20636F6F7264696E6174655B305D3B0D0A20202020202020202020202020202020636F6F726441727261795B6A5D5B315D203D20636F6F7264696E6174655B315D3B';
wwv_flow_imp.g_varchar2_table(223) := '0D0A20202020202020202020202020207D0D0A2020202020202020202020207D0D0A202020202020202020207D0D0A202020202020202020206966202873656C6563746564466561747572652E67656F6D657472792E74797065203D3D20274C696E6553';
wwv_flow_imp.g_varchar2_table(224) := '7472696E672729207B0D0A2020202020202020202020205F5F736574436F6F72642873656C6563746564466561747572652E67656F6D657472792E636F6F7264696E61746573293B0D0A202020202020202020207D20656C73652069662873656C656374';
wwv_flow_imp.g_varchar2_table(225) := '6564466561747572652E67656F6D657472792E74797065203D3D2027506F6C79676F6E2729207B0D0A202020202020202020202020666F7228766172206B3D303B6B3C73656C6563746564466561747572652E67656F6D657472792E636F6F7264696E61';
wwv_flow_imp.g_varchar2_table(226) := '7465732E6C656E6774683B6B2B2B29207B0D0A20202020202020202020202020205F5F736574436F6F72642873656C6563746564466561747572652E67656F6D657472792E636F6F7264696E617465735B6B5D293B0D0A2020202020202020202020207D';
wwv_flow_imp.g_varchar2_table(227) := '0D0A202020202020202020207D0D0A202020202020202020206D61702E647261772E736574287B747970653A202246656174757265436F6C6C656374696F6E222C206665617475726573203A5B73656C6563746564466561747572655D7D293B0D0A2020';
wwv_flow_imp.g_varchar2_table(228) := '2020202020207D0D0A2020202020207D202F2F656E642066756E6374696F6E0D0A0D0A202020202020696620286D6F6465203D3D2027647261775F706F696E7427207C7C206D6F6465203D3D20276469726563745F73656C65637427207C7C206D6F6465';
wwv_flow_imp.g_varchar2_table(229) := '203D3D202773696D706C655F73656C6563742729207B0D0A2020202020202020696620286E6176696761746F722E67656F6C6F636174696F6E29207B0D0A202020202020202020206E6176696761746F722E67656F6C6F636174696F6E2E676574437572';
wwv_flow_imp.g_varchar2_table(230) := '72656E74506F736974696F6E2866756E6374696F6E28706F73297B0D0A20202020202020202020202075706461746546726F6D47656F6C6F636174696F6E285B706F732E636F6F7264732E6C6F6E6769747564652C20706F732E636F6F7264732E6C6174';
wwv_flow_imp.g_varchar2_table(231) := '69747564655D293B0D0A2020202020202020202020200D0A202020202020202020207D2C2066756E6374696F6E2865727229207B0D0A2020202020202020202020202F2F20756E636F6D6D656E74207468697320746F207465737420696E204368726F6D';
wwv_flow_imp.g_varchar2_table(232) := '652E0D0A20202020202020202020202075706461746546726F6D47656F6C6F636174696F6E285B2D3930202B2028302E30312A4D6174682E72616E646F6D2829202D20302E303035292C203330202B2028302E30312A4D6174682E72616E646F6D282920';
wwv_flow_imp.g_varchar2_table(233) := '2D20302E303035295D293B0D0A202020202020202020207D293B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020617065785F616C657274282747656F6C6F636174696F6E206E6F7420737570706F727465642E27293B0D0A20';
wwv_flow_imp.g_varchar2_table(234) := '202020202020207D0D0A2020202020207D20656C7365206966286D6F6465203D3D2027647261775F6C696E655F737472696E6727207C7C206D6F6465203D3D2027647261775F706F6C79676F6E2729207B0D0A20202020202020206D61702E676574436F';
wwv_flow_imp.g_varchar2_table(235) := '6E7461696E657228292E64697370617463684576656E74286E6577204B6579626F6172644576656E7428276B65797570272C7B276B6579273A202760277D29293B0D0A2020202020207D0D0A202020207D3B0D0A20207D0D0A20200D0A2020617065782E';
wwv_flow_imp.g_varchar2_table(236) := '6974656D2E63726561746528705F6974656D5F69642C207B0D0A2020202073657447656F6D657472793A202867656F6D6574727929203D3E207B0D0A2020202020206D61702E647261772E736574287B0D0A2020202020202020747970653A2027466561';
wwv_flow_imp.g_varchar2_table(237) := '74757265436F6C6C656374696F6E272C0D0A202020202020202066656174757265733A205B7B0D0A20202020202020202020747970653A202746656174757265272C0D0A2020202020202020202067656F6D657472792C0D0A2020202020202020202070';
wwv_flow_imp.g_varchar2_table(238) := '726F706572746965733A207B7D2C0D0A20202020202020207D5D0D0A2020202020207D293B0D0A202020202020777269746547656F6D65747279284A534F4E2E737472696E676966792867656F6D6574727929293B0D0A202020207D0D0A20207D293B0D';
wwv_flow_imp.g_varchar2_table(239) := '0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(2028164921055856238)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_file_name=>'mapbits-draw.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A0D0A202A20676976656E20746865206964206F662061206E756D65726963207061676520656C656D656E742C2072657475726E207468652074657874206F66207468650D0A202A20656C656D656E74206173206120666C6F61742076616C7565206F';
wwv_flow_imp.g_varchar2_table(2) := '722072657475726E2030206966207468652074657874206973206E756C6C2E0D0A202A2F0D0A66756E6374696F6E20666C6F617456616C286E756D5F696429207B0D0A20202F2F6966202824286E756D5F6964292E76616C2829203D3D206E756C6C207C';
wwv_flow_imp.g_varchar2_table(3) := '7C2024286E756D5F6964292E76616C2829203D3D20222229207B0D0A20202F2F202072657475726E20303B0D0A20202F2F7D20656C7365207B0D0A202072657475726E207061727365466C6F6174286E756D5F6964293B0D0A20202F2F7D0D0A7D0D0A0D';
wwv_flow_imp.g_varchar2_table(4) := '0A2F2A0D0A202A2072657475726E20746865206465677265657320636F6D706F6E656E74206F662076616C0D0A202A2F0D0A66756E6374696F6E206765745F646567726565732876616C29207B0D0A20206966202876616C203E203029207B0D0A202020';
wwv_flow_imp.g_varchar2_table(5) := '2072657475726E204D6174682E666C6F6F722876616C293B0D0A20207D20656C7365207B0D0A2020202072657475726E202D4D6174682E666C6F6F72282D76616C293B0D0A20207D0D0A7D0D0A0D0A2F2A0D0A202A2072657475726E20746865206D696E';
wwv_flow_imp.g_varchar2_table(6) := '7574657320636F6D706F6E656E74206F662076616C0D0A202A2F0D0A66756E6374696F6E206765745F6D696E757465732876616C29207B0D0A20206966202876616C203E203029207B0D0A2020202064656772656573203D206765745F64656772656573';
wwv_flow_imp.g_varchar2_table(7) := '2876616C293B0D0A2020202072657475726E204D6174682E666C6F6F7228282876616C202D206465677265657329202A2036302E3029293B0D0A20207D20656C7365207B0D0A2020202064656772656573203D206765745F64656772656573282D76616C';
wwv_flow_imp.g_varchar2_table(8) := '293B0D0A2020202072657475726E204D6174682E666C6F6F722828282D76616C202D206465677265657329202A2036302E3029293B0D0A20207D0D0A20206176616C203D204D6174682E6162732876616C293B0D0A202064656772656573203D204D6174';
wwv_flow_imp.g_varchar2_table(9) := '682E616273286765745F646567726565732876616C29293B0D0A202072657475726E204E756D6265722828286176616C202D206465677265657329202A2036302E30292E746F4669786564283029293B0D0A7D0D0A0D0A2F2A0D0A202A2072657475726E';
wwv_flow_imp.g_varchar2_table(10) := '20746865207365636F6E647320636F6D706F6E656E74206F662076616C0D0A202A2F0D0A66756E6374696F6E206765745F7365636F6E64732876616C29207B0D0A20206176616C203D204D6174682E616273284D6174682E726F756E642876616C202A20';
wwv_flow_imp.g_varchar2_table(11) := '31303030303030303030303029202F203130303030303030303030302E30293B0D0A202064656772656573203D204D6174682E616273286765745F64656772656573286176616C29293B0D0A20206D696E75746573203D206765745F6D696E7574657328';
wwv_flow_imp.g_varchar2_table(12) := '6176616C293B0D0A20207274203D202833363030202A20286176616C202D2064656772656573202D206D696E75746573202F2036302E3029292E746F46697865642834293B0D0A2020696620287274203D3D20363029207B0D0A2020202072657475726E';
wwv_flow_imp.g_varchar2_table(13) := '20303B0D0A20207D20656C7365207B0D0A2020202072657475726E2072743B0D0A20207D0D0A7D0D0A0D0A2F2A0D0A202A2072657475726E20636F6E76657273696F6E206F6620646567726565732C206D696E757465732C20616E64207365636F6E6473';
wwv_flow_imp.g_varchar2_table(14) := '20746F20646563696D616C20646567726565732E0D0A202A2F0D0A66756E6374696F6E206765745F646563696D616C5F6465677265657328646567726565732C206D696E757465732C207365636F6E647329207B0D0A202072657475726E20666C6F6174';
wwv_flow_imp.g_varchar2_table(15) := '56616C286465677265657329203E2030203F20666C6F617456616C286465677265657329202B20666C6F617456616C286D696E7574657329202F2036302E30202B20666C6F617456616C287365636F6E647329202F20333630302E30203A20666C6F6174';
wwv_flow_imp.g_varchar2_table(16) := '56616C286465677265657329202D20666C6F617456616C286D696E7574657329202F2036302E30202D20666C6F617456616C287365636F6E647329202F20333630302E303B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(2084271021526413629)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_file_name=>'lonlat.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2166756E6374696F6E28742C65297B226F626A656374223D3D747970656F66206578706F727473262622756E646566696E656422213D747970656F66206D6F64756C653F6D6F64756C652E6578706F7274733D6528293A2266756E6374696F6E223D3D74';
wwv_flow_imp.g_varchar2_table(2) := '7970656F6620646566696E652626646566696E652E616D643F646566696E652865293A28743D747C7C73656C66292E4D6170626F78447261773D6528297D28746869732C2866756E6374696F6E28297B2275736520737472696374223B76617220743D66';
wwv_flow_imp.g_varchar2_table(3) := '756E6374696F6E28742C65297B766172206E3D7B647261673A5B5D2C636C69636B3A5B5D2C6D6F7573656D6F76653A5B5D2C6D6F757365646F776E3A5B5D2C6D6F75736575703A5B5D2C6D6F7573656F75743A5B5D2C6B6579646F776E3A5B5D2C6B6579';
wwv_flow_imp.g_varchar2_table(4) := '75703A5B5D2C746F75636873746172743A5B5D2C746F7563686D6F76653A5B5D2C746F756368656E643A5B5D2C7461703A5B5D7D2C723D7B6F6E3A66756E6374696F6E28742C652C72297B696628766F696420303D3D3D6E5B745D297468726F77206E65';
wwv_flow_imp.g_varchar2_table(5) := '77204572726F722822496E76616C6964206576656E7420747970653A20222B74293B6E5B745D2E70757368287B73656C6563746F723A652C666E3A727D297D2C72656E6465723A66756E6374696F6E2874297B652E73746F72652E666561747572654368';
wwv_flow_imp.g_varchar2_table(6) := '616E6765642874297D7D2C6F3D66756E6374696F6E28742C6F297B666F722876617220693D6E5B745D2C613D692E6C656E6774683B612D2D3B297B76617220733D695B615D3B696628732E73656C6563746F72286F29297B732E666E2E63616C6C28722C';
wwv_flow_imp.g_varchar2_table(7) := '6F297C7C652E73746F72652E72656E64657228292C652E75692E7570646174654D6170436C617373657328293B627265616B7D7D7D3B72657475726E20742E73746172742E63616C6C2872292C7B72656E6465723A742E72656E6465722C73746F703A66';
wwv_flow_imp.g_varchar2_table(8) := '756E6374696F6E28297B742E73746F702626742E73746F7028297D2C74726173683A66756E6374696F6E28297B742E7472617368262628742E747261736828292C652E73746F72652E72656E6465722829297D2C636F6D62696E6546656174757265733A';
wwv_flow_imp.g_varchar2_table(9) := '66756E6374696F6E28297B742E636F6D62696E6546656174757265732626742E636F6D62696E65466561747572657328297D2C756E636F6D62696E6546656174757265733A66756E6374696F6E28297B742E756E636F6D62696E65466561747572657326';
wwv_flow_imp.g_varchar2_table(10) := '26742E756E636F6D62696E65466561747572657328297D2C647261673A66756E6374696F6E2874297B6F282264726167222C74297D2C636C69636B3A66756E6374696F6E2874297B6F2822636C69636B222C74297D2C6D6F7573656D6F76653A66756E63';
wwv_flow_imp.g_varchar2_table(11) := '74696F6E2874297B6F28226D6F7573656D6F7665222C74297D2C6D6F757365646F776E3A66756E6374696F6E2874297B6F28226D6F757365646F776E222C74297D2C6D6F75736575703A66756E6374696F6E2874297B6F28226D6F7573657570222C7429';
wwv_flow_imp.g_varchar2_table(12) := '7D2C6D6F7573656F75743A66756E6374696F6E2874297B6F28226D6F7573656F7574222C74297D2C6B6579646F776E3A66756E6374696F6E2874297B6F28226B6579646F776E222C74297D2C6B657975703A66756E6374696F6E2874297B6F28226B6579';
wwv_flow_imp.g_varchar2_table(13) := '7570222C74297D2C746F75636873746172743A66756E6374696F6E2874297B6F2822746F7563687374617274222C74297D2C746F7563686D6F76653A66756E6374696F6E2874297B6F2822746F7563686D6F7665222C74297D2C746F756368656E643A66';
wwv_flow_imp.g_varchar2_table(14) := '756E6374696F6E2874297B6F2822746F756368656E64222C74297D2C7461703A66756E6374696F6E2874297B6F2822746170222C74297D7D7D2C653D7B5241444955533A363337383133372C464C415454454E494E473A312F3239382E32353732323335';
wwv_flow_imp.g_varchar2_table(15) := '36332C504F4C41525F5241444955533A363335363735322E333134327D3B66756E6374696F6E206E2874297B76617220653D303B696628742626742E6C656E6774683E30297B652B3D4D6174682E616273287228745B305D29293B666F7228766172206E';
wwv_flow_imp.g_varchar2_table(16) := '3D313B6E3C742E6C656E6774683B6E2B2B29652D3D4D6174682E616273287228745B6E5D29297D72657475726E20657D66756E6374696F6E20722874297B766172206E2C722C692C612C732C752C633D302C6C3D742E6C656E6774683B6966286C3E3229';
wwv_flow_imp.g_varchar2_table(17) := '7B666F7228753D303B753C6C3B752B2B29753D3D3D6C2D323F28693D6C2D322C613D6C2D312C733D30293A753D3D3D6C2D313F28693D6C2D312C613D302C733D31293A28693D752C613D752B312C733D752B32292C6E3D745B695D2C723D745B615D2C63';
wwv_flow_imp.g_varchar2_table(18) := '2B3D286F28745B735D5B305D292D6F286E5B305D29292A4D6174682E73696E286F28725B315D29293B633D632A652E5241444955532A652E5241444955532F327D72657475726E20637D66756E6374696F6E206F2874297B72657475726E20742A4D6174';
wwv_flow_imp.g_varchar2_table(19) := '682E50492F3138307D76617220693D7B67656F6D657472793A66756E6374696F6E20742865297B76617220722C6F3D303B73776974636828652E74797065297B6361736522506F6C79676F6E223A72657475726E206E28652E636F6F7264696E61746573';
wwv_flow_imp.g_varchar2_table(20) := '293B63617365224D756C7469506F6C79676F6E223A666F7228723D303B723C652E636F6F7264696E617465732E6C656E6774683B722B2B296F2B3D6E28652E636F6F7264696E617465735B725D293B72657475726E206F3B6361736522506F696E74223A';
wwv_flow_imp.g_varchar2_table(21) := '63617365224D756C7469506F696E74223A63617365224C696E65537472696E67223A63617365224D756C74694C696E65537472696E67223A72657475726E20303B636173652247656F6D65747279436F6C6C656374696F6E223A666F7228723D303B723C';
wwv_flow_imp.g_varchar2_table(22) := '652E67656F6D6574726965732E6C656E6774683B722B2B296F2B3D7428652E67656F6D6574726965735B725D293B72657475726E206F7D7D2C72696E673A727D2C613D7B434F4E54524F4C5F424153453A226D6170626F78676C2D6374726C222C434F4E';
wwv_flow_imp.g_varchar2_table(23) := '54524F4C5F5052454649583A226D6170626F78676C2D6374726C2D222C434F4E54524F4C5F425554544F4E3A226D6170626F782D676C2D647261775F6374726C2D647261772D62746E222C434F4E54524F4C5F425554544F4E5F4C494E453A226D617062';
wwv_flow_imp.g_varchar2_table(24) := '6F782D676C2D647261775F6C696E65222C434F4E54524F4C5F425554544F4E5F504F4C59474F4E3A226D6170626F782D676C2D647261775F706F6C79676F6E222C434F4E54524F4C5F425554544F4E5F504F494E543A226D6170626F782D676C2D647261';
wwv_flow_imp.g_varchar2_table(25) := '775F706F696E74222C434F4E54524F4C5F425554544F4E5F54524153483A226D6170626F782D676C2D647261775F7472617368222C434F4E54524F4C5F425554544F4E5F434F4D42494E455F46454154555245533A226D6170626F782D676C2D64726177';
wwv_flow_imp.g_varchar2_table(26) := '5F636F6D62696E65222C434F4E54524F4C5F425554544F4E5F554E434F4D42494E455F46454154555245533A226D6170626F782D676C2D647261775F756E636F6D62696E65222C434F4E54524F4C5F47524F55503A226D6170626F78676C2D6374726C2D';
wwv_flow_imp.g_varchar2_table(27) := '67726F7570222C4154545249425554494F4E3A226D6170626F78676C2D6374726C2D617474726962222C4143544956455F425554544F4E3A22616374697665222C424F585F53454C4543543A226D6170626F782D676C2D647261775F626F7873656C6563';
wwv_flow_imp.g_varchar2_table(28) := '74227D2C733D7B484F543A226D6170626F782D676C2D647261772D686F74222C434F4C443A226D6170626F782D676C2D647261772D636F6C64227D2C753D7B4144443A22616464222C4D4F56453A226D6F7665222C445241473A2264726167222C504F49';
wwv_flow_imp.g_varchar2_table(29) := '4E5445523A22706F696E746572222C4E4F4E453A226E6F6E65227D2C633D7B504F4C59474F4E3A22706F6C79676F6E222C4C494E453A226C696E655F737472696E67222C504F494E543A22706F696E74227D2C6C3D7B464541545552453A224665617475';
wwv_flow_imp.g_varchar2_table(30) := '7265222C504F4C59474F4E3A22506F6C79676F6E222C4C494E455F535452494E473A224C696E65537472696E67222C504F494E543A22506F696E74222C464541545552455F434F4C4C454354494F4E3A2246656174757265436F6C6C656374696F6E222C';
wwv_flow_imp.g_varchar2_table(31) := '4D554C54495F5052454649583A224D756C7469222C4D554C54495F504F494E543A224D756C7469506F696E74222C4D554C54495F4C494E455F535452494E473A224D756C74694C696E65537472696E67222C4D554C54495F504F4C59474F4E3A224D756C';
wwv_flow_imp.g_varchar2_table(32) := '7469506F6C79676F6E227D2C683D7B445241575F4C494E455F535452494E473A22647261775F6C696E655F737472696E67222C445241575F504F4C59474F4E3A22647261775F706F6C79676F6E222C445241575F504F494E543A22647261775F706F696E';
wwv_flow_imp.g_varchar2_table(33) := '74222C53494D504C455F53454C4543543A2273696D706C655F73656C656374222C4449524543545F53454C4543543A226469726563745F73656C656374222C5354415449433A22737461746963227D2C703D7B4352454154453A22647261772E63726561';
wwv_flow_imp.g_varchar2_table(34) := '7465222C44454C4554453A22647261772E64656C657465222C5550444154453A22647261772E757064617465222C53454C454354494F4E5F4348414E47453A22647261772E73656C656374696F6E6368616E6765222C4D4F44455F4348414E47453A2264';
wwv_flow_imp.g_varchar2_table(35) := '7261772E6D6F64656368616E6765222C414354494F4E41424C453A22647261772E616374696F6E61626C65222C52454E4445523A22647261772E72656E646572222C434F4D42494E455F46454154555245533A22647261772E636F6D62696E65222C554E';
wwv_flow_imp.g_varchar2_table(36) := '434F4D42494E455F46454154555245533A22647261772E756E636F6D62696E65227D2C643D226D6F7665222C663D226368616E67655F636F6F7264696E61746573222C673D7B464541545552453A2266656174757265222C4D4944504F494E543A226D69';
wwv_flow_imp.g_varchar2_table(37) := '64706F696E74222C5645525445583A22766572746578227D2C793D7B4143544956453A2274727565222C494E4143544956453A2266616C7365227D2C6D3D5B227363726F6C6C5A6F6F6D222C22626F785A6F6F6D222C2264726167526F74617465222C22';
wwv_flow_imp.g_varchar2_table(38) := '6472616750616E222C226B6579626F617264222C22646F75626C65436C69636B5A6F6F6D222C22746F7563685A6F6F6D526F74617465225D2C763D2D38352C5F3D38352C623D7B506F696E743A302C4C696E65537472696E673A312C506F6C79676F6E3A';
wwv_flow_imp.g_varchar2_table(39) := '327D3B66756E6374696F6E204528742C65297B766172206E3D625B742E67656F6D657472792E747970655D2D625B652E67656F6D657472792E747970655D3B72657475726E20303D3D3D6E2626742E67656F6D657472792E747970653D3D3D6C2E504F4C';
wwv_flow_imp.g_varchar2_table(40) := '59474F4E3F742E617265612D652E617265613A6E7D66756E6374696F6E20532874297B696628746869732E5F6974656D733D7B7D2C746869732E5F6E756D733D7B7D2C746869732E5F6C656E6774683D743F742E6C656E6774683A302C7429666F722876';
wwv_flow_imp.g_varchar2_table(41) := '617220653D302C6E3D742E6C656E6774683B653C6E3B652B2B29746869732E61646428745B655D292C766F69642030213D3D745B655D26262822737472696E67223D3D747970656F6620745B655D3F746869732E5F6974656D735B745B655D5D3D653A74';
wwv_flow_imp.g_varchar2_table(42) := '6869732E5F6E756D735B745B655D5D3D65297D532E70726F746F747970652E6164643D66756E6374696F6E2874297B72657475726E20746869732E6861732874293F746869733A28746869732E5F6C656E6774682B2B2C22737472696E67223D3D747970';
wwv_flow_imp.g_varchar2_table(43) := '656F6620743F746869732E5F6974656D735B745D3D746869732E5F6C656E6774683A746869732E5F6E756D735B745D3D746869732E5F6C656E6774682C74686973297D2C532E70726F746F747970652E64656C6574653D66756E6374696F6E2874297B72';
wwv_flow_imp.g_varchar2_table(44) := '657475726E21313D3D3D746869732E6861732874293F746869733A28746869732E5F6C656E6774682D2D2C64656C65746520746869732E5F6974656D735B745D2C64656C65746520746869732E5F6E756D735B745D2C74686973297D2C532E70726F746F';
wwv_flow_imp.g_varchar2_table(45) := '747970652E6861733D66756E6374696F6E2874297B72657475726E2822737472696E67223D3D747970656F6620747C7C226E756D626572223D3D747970656F66207429262628766F69642030213D3D746869732E5F6974656D735B745D7C7C766F696420';
wwv_flow_imp.g_varchar2_table(46) := '30213D3D746869732E5F6E756D735B745D297D2C532E70726F746F747970652E76616C7565733D66756E6374696F6E28297B76617220743D746869732C653D5B5D3B72657475726E204F626A6563742E6B65797328746869732E5F6974656D73292E666F';
wwv_flow_imp.g_varchar2_table(47) := '7245616368282866756E6374696F6E286E297B652E70757368287B6B3A6E2C763A742E5F6974656D735B6E5D7D297D29292C4F626A6563742E6B65797328746869732E5F6E756D73292E666F7245616368282866756E6374696F6E286E297B652E707573';
wwv_flow_imp.g_varchar2_table(48) := '68287B6B3A4A534F4E2E7061727365286E292C763A742E5F6E756D735B6E5D7D297D29292C652E736F7274282866756E6374696F6E28742C65297B72657475726E20742E762D652E767D29292E6D6170282866756E6374696F6E2874297B72657475726E';
wwv_flow_imp.g_varchar2_table(49) := '20742E6B7D29297D2C532E70726F746F747970652E636C6561723D66756E6374696F6E28297B72657475726E20746869732E5F6C656E6774683D302C746869732E5F6974656D733D7B7D2C746869732E5F6E756D733D7B7D2C746869737D3B7661722054';
wwv_flow_imp.g_varchar2_table(50) := '3D5B672E464541545552452C672E4D4944504F494E542C672E5645525445585D2C433D7B636C69636B3A66756E6374696F6E28742C652C6E297B72657475726E204F28742C652C6E2C6E2E6F7074696F6E732E636C69636B427566666572297D2C746F75';
wwv_flow_imp.g_varchar2_table(51) := '63683A66756E6374696F6E28742C652C6E297B72657475726E204F28742C652C6E2C6E2E6F7074696F6E732E746F756368427566666572297D7D3B66756E6374696F6E204F28742C652C6E2C72297B6966286E756C6C3D3D3D6E2E6D6170297265747572';
wwv_flow_imp.g_varchar2_table(52) := '6E5B5D3B766172206F3D743F66756E6374696F6E28742C65297B72657475726E20766F696420303D3D3D65262628653D30292C5B5B742E706F696E742E782D652C742E706F696E742E792D655D2C5B742E706F696E742E782B652C742E706F696E742E79';
wwv_flow_imp.g_varchar2_table(53) := '2B655D5D7D28742C72293A652C613D7B7D3B6E2E6F7074696F6E732E7374796C6573262628612E6C61796572733D6E2E6F7074696F6E732E7374796C65732E6D6170282866756E6374696F6E2874297B72657475726E20742E69647D2929293B76617220';
wwv_flow_imp.g_varchar2_table(54) := '733D6E2E6D61702E717565727952656E64657265644665617475726573286F2C61292E66696C746572282866756E6374696F6E2874297B72657475726E2D31213D3D542E696E6465784F6628742E70726F706572746965732E6D657461297D29292C753D';
wwv_flow_imp.g_varchar2_table(55) := '6E657720532C633D5B5D3B72657475726E20732E666F7245616368282866756E6374696F6E2874297B76617220653D742E70726F706572746965732E69643B752E6861732865297C7C28752E6164642865292C632E70757368287429297D29292C66756E';
wwv_flow_imp.g_varchar2_table(56) := '6374696F6E2874297B72657475726E20742E6D6170282866756E6374696F6E2874297B72657475726E20742E67656F6D657472792E747970653D3D3D6C2E504F4C59474F4E262628742E617265613D692E67656F6D65747279287B747970653A6C2E4645';
wwv_flow_imp.g_varchar2_table(57) := '41545552452C70726F70657274793A7B7D2C67656F6D657472793A742E67656F6D657472797D29292C747D29292E736F72742845292E6D6170282866756E6374696F6E2874297B72657475726E2064656C65746520742E617265612C747D29297D286329';
wwv_flow_imp.g_varchar2_table(58) := '7D66756E6374696F6E204928742C65297B766172206E3D432E636C69636B28742C6E756C6C2C65292C723D7B6D6F7573653A752E4E4F4E457D3B72657475726E206E5B305D262628722E6D6F7573653D6E5B305D2E70726F706572746965732E61637469';
wwv_flow_imp.g_varchar2_table(59) := '76653D3D3D792E4143544956453F752E4D4F56453A752E504F494E5445522C722E666561747572653D6E5B305D2E70726F706572746965732E6D657461292C2D31213D3D652E6576656E74732E63757272656E744D6F64654E616D6528292E696E646578';
wwv_flow_imp.g_varchar2_table(60) := '4F662822647261772229262628722E6D6F7573653D752E414444292C652E75692E71756575654D6170436C61737365732872292C652E75692E7570646174654D6170436C617373657328292C6E5B305D7D66756E6374696F6E207828742C65297B766172';
wwv_flow_imp.g_varchar2_table(61) := '206E3D742E782D652E782C723D742E792D652E793B72657475726E204D6174682E73717274286E2A6E2B722A72297D766172204C3D342C4D3D31322C4E3D3530303B66756E6374696F6E205028742C652C6E297B766F696420303D3D3D6E2626286E3D7B';
wwv_flow_imp.g_varchar2_table(62) := '7D293B76617220723D6E756C6C213D6E2E66696E65546F6C6572616E63653F6E2E66696E65546F6C6572616E63653A4C2C6F3D6E756C6C213D6E2E67726F7373546F6C6572616E63653F6E2E67726F7373546F6C6572616E63653A4D2C693D6E756C6C21';
wwv_flow_imp.g_varchar2_table(63) := '3D6E2E696E74657276616C3F6E2E696E74657276616C3A4E3B742E706F696E743D742E706F696E747C7C652E706F696E742C742E74696D653D742E74696D657C7C652E74696D653B76617220613D7828742E706F696E742C652E706F696E74293B726574';
wwv_flow_imp.g_varchar2_table(64) := '75726E20613C727C7C613C6F2626652E74696D652D742E74696D653C697D76617220773D32352C413D3235303B66756E6374696F6E204628742C652C6E297B766F696420303D3D3D6E2626286E3D7B7D293B76617220723D6E756C6C213D6E2E746F6C65';
wwv_flow_imp.g_varchar2_table(65) := '72616E63653F6E2E746F6C6572616E63653A772C6F3D6E756C6C213D6E2E696E74657276616C3F6E2E696E74657276616C3A413B72657475726E20742E706F696E743D742E706F696E747C7C652E706F696E742C742E74696D653D742E74696D657C7C65';
wwv_flow_imp.g_varchar2_table(66) := '2E74696D652C7828742E706F696E742C652E706F696E74293C722626652E74696D652D742E74696D653C6F7D66756E6374696F6E206B28297B7468726F77206E6577204572726F72282244796E616D696320726571756972657320617265206E6F742063';
wwv_flow_imp.g_varchar2_table(67) := '757272656E746C7920737570706F7274656420627920726F6C6C75702D706C7567696E2D636F6D6D6F6E6A7322297D66756E6374696F6E205228742C65297B72657475726E207428653D7B6578706F7274733A7B7D7D2C652E6578706F727473292C652E';
wwv_flow_imp.g_varchar2_table(68) := '6578706F7274737D76617220553D52282866756E6374696F6E2874297B76617220653D742E6578706F7274733D66756E6374696F6E28742C6E297B6966286E7C7C286E3D3136292C766F696420303D3D3D74262628743D313238292C743C3D3029726574';
wwv_flow_imp.g_varchar2_table(69) := '75726E2230223B666F722876617220723D4D6174682E6C6F67284D6174682E706F7728322C7429292F4D6174682E6C6F67286E292C6F3D323B723D3D3D312F303B6F2A3D3229723D4D6174682E6C6F67284D6174682E706F7728322C742F6F29292F4D61';
wwv_flow_imp.g_varchar2_table(70) := '74682E6C6F67286E292A6F3B76617220693D722D4D6174682E666C6F6F722872292C613D22223B666F72286F3D303B6F3C4D6174682E666C6F6F722872293B6F2B2B297B613D4D6174682E666C6F6F72284D6174682E72616E646F6D28292A6E292E746F';
wwv_flow_imp.g_varchar2_table(71) := '537472696E67286E292B617D69662869297B76617220733D4D6174682E706F77286E2C69293B613D4D6174682E666C6F6F72284D6174682E72616E646F6D28292A73292E746F537472696E67286E292B617D76617220753D7061727365496E7428612C6E';
wwv_flow_imp.g_varchar2_table(72) := '293B72657475726E2075213D3D312F302626753E3D4D6174682E706F7728322C74293F6528742C6E293A617D3B652E7261636B3D66756E6374696F6E28742C6E2C72297B766172206F3D66756E6374696F6E286F297B76617220613D303B646F7B696628';
wwv_flow_imp.g_varchar2_table(73) := '612B2B3E3130297B6966282172297468726F77206E6577204572726F722822746F6F206D616E7920494420636F6C6C6973696F6E732C20757365206D6F7265206269747322293B742B3D727D76617220733D6528742C6E297D7768696C65284F626A6563';
wwv_flow_imp.g_varchar2_table(74) := '742E6861734F776E50726F70657274792E63616C6C28692C7329293B72657475726E20695B735D3D6F2C737D2C693D6F2E686174733D7B7D3B72657475726E206F2E6765743D66756E6374696F6E2874297B72657475726E206F2E686174735B745D7D2C';
wwv_flow_imp.g_varchar2_table(75) := '6F2E7365743D66756E6374696F6E28742C65297B72657475726E206F2E686174735B745D3D652C6F7D2C6F2E626974733D747C7C3132382C6F2E626173653D6E7C7C31362C6F7D7D29292C6A3D66756E6374696F6E28742C65297B746869732E6374783D';
wwv_flow_imp.g_varchar2_table(76) := '742C746869732E70726F706572746965733D652E70726F706572746965737C7C7B7D2C746869732E636F6F7264696E617465733D652E67656F6D657472792E636F6F7264696E617465732C746869732E69643D652E69647C7C5528292C746869732E7479';
wwv_flow_imp.g_varchar2_table(77) := '70653D652E67656F6D657472792E747970657D3B6A2E70726F746F747970652E6368616E6765643D66756E6374696F6E28297B746869732E6374782E73746F72652E666561747572654368616E67656428746869732E6964297D2C6A2E70726F746F7479';
wwv_flow_imp.g_varchar2_table(78) := '70652E696E636F6D696E67436F6F7264733D66756E6374696F6E2874297B746869732E736574436F6F7264696E617465732874297D2C6A2E70726F746F747970652E736574436F6F7264696E617465733D66756E6374696F6E2874297B746869732E636F';
wwv_flow_imp.g_varchar2_table(79) := '6F7264696E617465733D742C746869732E6368616E67656428297D2C6A2E70726F746F747970652E676574436F6F7264696E617465733D66756E6374696F6E28297B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E676966792874';
wwv_flow_imp.g_varchar2_table(80) := '6869732E636F6F7264696E6174657329297D2C6A2E70726F746F747970652E73657450726F70657274793D66756E6374696F6E28742C65297B746869732E70726F706572746965735B745D3D657D2C6A2E70726F746F747970652E746F47656F4A534F4E';
wwv_flow_imp.g_varchar2_table(81) := '3D66756E6374696F6E28297B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E67696679287B69643A746869732E69642C747970653A6C2E464541545552452C70726F706572746965733A746869732E70726F706572746965732C67';
wwv_flow_imp.g_varchar2_table(82) := '656F6D657472793A7B636F6F7264696E617465733A746869732E676574436F6F7264696E6174657328292C747970653A746869732E747970657D7D29297D2C6A2E70726F746F747970652E696E7465726E616C3D66756E6374696F6E2874297B76617220';
wwv_flow_imp.g_varchar2_table(83) := '653D7B69643A746869732E69642C6D6574613A672E464541545552452C226D6574613A74797065223A746869732E747970652C6163746976653A792E494E4143544956452C6D6F64653A747D3B696628746869732E6374782E6F7074696F6E732E757365';
wwv_flow_imp.g_varchar2_table(84) := '7250726F7065727469657329666F7228766172206E20696E20746869732E70726F7065727469657329655B22757365725F222B6E5D3D746869732E70726F706572746965735B6E5D3B72657475726E7B747970653A6C2E464541545552452C70726F7065';
wwv_flow_imp.g_varchar2_table(85) := '72746965733A652C67656F6D657472793A7B636F6F7264696E617465733A746869732E676574436F6F7264696E6174657328292C747970653A746869732E747970657D7D7D3B76617220443D66756E6374696F6E28742C65297B6A2E63616C6C28746869';
wwv_flow_imp.g_varchar2_table(86) := '732C742C65297D3B28442E70726F746F747970653D4F626A6563742E637265617465286A2E70726F746F7479706529292E697356616C69643D66756E6374696F6E28297B72657475726E226E756D626572223D3D747970656F6620746869732E636F6F72';
wwv_flow_imp.g_varchar2_table(87) := '64696E617465735B305D2626226E756D626572223D3D747970656F6620746869732E636F6F7264696E617465735B315D7D2C442E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28742C652C6E297B333D3D3D61';
wwv_flow_imp.g_varchar2_table(88) := '7267756D656E74732E6C656E6774683F746869732E636F6F7264696E617465733D5B652C6E5D3A746869732E636F6F7264696E617465733D5B742C655D2C746869732E6368616E67656428297D2C442E70726F746F747970652E676574436F6F7264696E';
wwv_flow_imp.g_varchar2_table(89) := '6174653D66756E6374696F6E28297B72657475726E20746869732E676574436F6F7264696E6174657328297D3B76617220563D66756E6374696F6E28742C65297B6A2E63616C6C28746869732C742C65297D3B28562E70726F746F747970653D4F626A65';
wwv_flow_imp.g_varchar2_table(90) := '63742E637265617465286A2E70726F746F7479706529292E697356616C69643D66756E6374696F6E28297B72657475726E20746869732E636F6F7264696E617465732E6C656E6774683E317D2C562E70726F746F747970652E616464436F6F7264696E61';
wwv_flow_imp.g_varchar2_table(91) := '74653D66756E6374696F6E28742C652C6E297B746869732E6368616E67656428293B76617220723D7061727365496E7428742C3130293B746869732E636F6F7264696E617465732E73706C69636528722C302C5B652C6E5D297D2C562E70726F746F7479';
wwv_flow_imp.g_varchar2_table(92) := '70652E676574436F6F7264696E6174653D66756E6374696F6E2874297B76617220653D7061727365496E7428742C3130293B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E6769667928746869732E636F6F7264696E617465735B';
wwv_flow_imp.g_varchar2_table(93) := '655D29297D2C562E70726F746F747970652E72656D6F7665436F6F7264696E6174653D66756E6374696F6E2874297B746869732E6368616E67656428292C746869732E636F6F7264696E617465732E73706C696365287061727365496E7428742C313029';
wwv_flow_imp.g_varchar2_table(94) := '2C31297D2C562E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28742C652C6E297B76617220723D7061727365496E7428742C3130293B746869732E636F6F7264696E617465735B725D3D5B652C6E5D2C746869';
wwv_flow_imp.g_varchar2_table(95) := '732E6368616E67656428297D3B76617220423D66756E6374696F6E28742C65297B6A2E63616C6C28746869732C742C65292C746869732E636F6F7264696E617465733D746869732E636F6F7264696E617465732E6D6170282866756E6374696F6E287429';
wwv_flow_imp.g_varchar2_table(96) := '7B72657475726E20742E736C69636528302C2D31297D29297D3B28422E70726F746F747970653D4F626A6563742E637265617465286A2E70726F746F7479706529292E697356616C69643D66756E6374696F6E28297B72657475726E2030213D3D746869';
wwv_flow_imp.g_varchar2_table(97) := '732E636F6F7264696E617465732E6C656E6774682626746869732E636F6F7264696E617465732E6576657279282866756E6374696F6E2874297B72657475726E20742E6C656E6774683E327D29297D2C422E70726F746F747970652E696E636F6D696E67';
wwv_flow_imp.g_varchar2_table(98) := '436F6F7264733D66756E6374696F6E2874297B746869732E636F6F7264696E617465733D742E6D6170282866756E6374696F6E2874297B72657475726E20742E736C69636528302C2D31297D29292C746869732E6368616E67656428297D2C422E70726F';
wwv_flow_imp.g_varchar2_table(99) := '746F747970652E736574436F6F7264696E617465733D66756E6374696F6E2874297B746869732E636F6F7264696E617465733D742C746869732E6368616E67656428297D2C422E70726F746F747970652E616464436F6F7264696E6174653D66756E6374';
wwv_flow_imp.g_varchar2_table(100) := '696F6E28742C652C6E297B746869732E6368616E67656428293B76617220723D742E73706C697428222E22292E6D6170282866756E6374696F6E2874297B72657475726E207061727365496E7428742C3130297D29293B746869732E636F6F7264696E61';
wwv_flow_imp.g_varchar2_table(101) := '7465735B725B305D5D2E73706C69636528725B315D2C302C5B652C6E5D297D2C422E70726F746F747970652E72656D6F7665436F6F7264696E6174653D66756E6374696F6E2874297B746869732E6368616E67656428293B76617220653D742E73706C69';
wwv_flow_imp.g_varchar2_table(102) := '7428222E22292E6D6170282866756E6374696F6E2874297B72657475726E207061727365496E7428742C3130297D29292C6E3D746869732E636F6F7264696E617465735B655B305D5D3B6E2626286E2E73706C69636528655B315D2C31292C6E2E6C656E';
wwv_flow_imp.g_varchar2_table(103) := '6774683C332626746869732E636F6F7264696E617465732E73706C69636528655B305D2C3129297D2C422E70726F746F747970652E676574436F6F7264696E6174653D66756E6374696F6E2874297B76617220653D742E73706C697428222E22292E6D61';
wwv_flow_imp.g_varchar2_table(104) := '70282866756E6374696F6E2874297B72657475726E207061727365496E7428742C3130297D29292C6E3D746869732E636F6F7264696E617465735B655B305D5D3B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E67696679286E5B';
wwv_flow_imp.g_varchar2_table(105) := '655B315D5D29297D2C422E70726F746F747970652E676574436F6F7264696E617465733D66756E6374696F6E28297B72657475726E20746869732E636F6F7264696E617465732E6D6170282866756E6374696F6E2874297B72657475726E20742E636F6E';
wwv_flow_imp.g_varchar2_table(106) := '636174285B745B305D5D297D29297D2C422E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28742C652C6E297B746869732E6368616E67656428293B76617220723D742E73706C697428222E22292C6F3D706172';
wwv_flow_imp.g_varchar2_table(107) := '7365496E7428725B305D2C3130292C693D7061727365496E7428725B315D2C3130293B766F696420303D3D3D746869732E636F6F7264696E617465735B6F5D262628746869732E636F6F7264696E617465735B6F5D3D5B5D292C746869732E636F6F7264';
wwv_flow_imp.g_varchar2_table(108) := '696E617465735B6F5D5B695D3D5B652C6E5D7D3B76617220473D7B4D756C7469506F696E743A442C4D756C74694C696E65537472696E673A562C4D756C7469506F6C79676F6E3A427D2C243D66756E6374696F6E28742C652C6E2C722C6F297B76617220';
wwv_flow_imp.g_varchar2_table(109) := '693D6E2E73706C697428222E22292C613D7061727365496E7428695B305D2C3130292C733D695B315D3F692E736C6963652831292E6A6F696E28222E22293A6E756C6C3B72657475726E20745B615D5B655D28732C722C6F297D2C4A3D66756E6374696F';
wwv_flow_imp.g_varchar2_table(110) := '6E28742C65297B6966286A2E63616C6C28746869732C742C65292C64656C65746520746869732E636F6F7264696E617465732C746869732E6D6F64656C3D475B652E67656F6D657472792E747970655D2C766F696420303D3D3D746869732E6D6F64656C';
wwv_flow_imp.g_varchar2_table(111) := '297468726F77206E657720547970654572726F7228652E67656F6D657472792E747970652B22206973206E6F7420612076616C6964207479706522293B746869732E66656174757265733D746869732E5F636F6F7264696E61746573546F466561747572';
wwv_flow_imp.g_varchar2_table(112) := '657328652E67656F6D657472792E636F6F7264696E61746573297D3B66756E6374696F6E207A2874297B746869732E6D61703D742E6D61702C746869732E64726177436F6E6669673D4A534F4E2E7061727365284A534F4E2E737472696E676966792874';
wwv_flow_imp.g_varchar2_table(113) := '2E6F7074696F6E737C7C7B7D29292C746869732E5F6374783D747D284A2E70726F746F747970653D4F626A6563742E637265617465286A2E70726F746F7479706529292E5F636F6F7264696E61746573546F46656174757265733D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(114) := '74297B76617220653D746869732C6E3D746869732E6D6F64656C2E62696E642874686973293B72657475726E20742E6D6170282866756E6374696F6E2874297B72657475726E206E6577206E28652E6374782C7B69643A5528292C747970653A6C2E4645';
wwv_flow_imp.g_varchar2_table(115) := '41545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B636F6F7264696E617465733A742C747970653A652E747970652E7265706C61636528224D756C7469222C2222297D7D297D29297D2C4A2E70726F746F747970652E697356616C';
wwv_flow_imp.g_varchar2_table(116) := '69643D66756E6374696F6E28297B72657475726E20746869732E66656174757265732E6576657279282866756E6374696F6E2874297B72657475726E20742E697356616C696428297D29297D2C4A2E70726F746F747970652E736574436F6F7264696E61';
wwv_flow_imp.g_varchar2_table(117) := '7465733D66756E6374696F6E2874297B746869732E66656174757265733D746869732E5F636F6F7264696E61746573546F46656174757265732874292C746869732E6368616E67656428297D2C4A2E70726F746F747970652E676574436F6F7264696E61';
wwv_flow_imp.g_varchar2_table(118) := '74653D66756E6374696F6E2874297B72657475726E202428746869732E66656174757265732C22676574436F6F7264696E617465222C74297D2C4A2E70726F746F747970652E676574436F6F7264696E617465733D66756E6374696F6E28297B72657475';
wwv_flow_imp.g_varchar2_table(119) := '726E204A534F4E2E7061727365284A534F4E2E737472696E6769667928746869732E66656174757265732E6D6170282866756E6374696F6E2874297B72657475726E20742E747970653D3D3D6C2E504F4C59474F4E3F742E676574436F6F7264696E6174';
wwv_flow_imp.g_varchar2_table(120) := '657328293A742E636F6F7264696E617465737D292929297D2C4A2E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28742C652C6E297B2428746869732E66656174757265732C22757064617465436F6F7264696E';
wwv_flow_imp.g_varchar2_table(121) := '617465222C742C652C6E292C746869732E6368616E67656428297D2C4A2E70726F746F747970652E616464436F6F7264696E6174653D66756E6374696F6E28742C652C6E297B2428746869732E66656174757265732C22616464436F6F7264696E617465';
wwv_flow_imp.g_varchar2_table(122) := '222C742C652C6E292C746869732E6368616E67656428297D2C4A2E70726F746F747970652E72656D6F7665436F6F7264696E6174653D66756E6374696F6E2874297B2428746869732E66656174757265732C2272656D6F7665436F6F7264696E61746522';
wwv_flow_imp.g_varchar2_table(123) := '2C74292C746869732E6368616E67656428297D2C4A2E70726F746F747970652E67657446656174757265733D66756E6374696F6E28297B72657475726E20746869732E66656174757265737D2C7A2E70726F746F747970652E73657453656C6563746564';
wwv_flow_imp.g_varchar2_table(124) := '3D66756E6374696F6E2874297B72657475726E20746869732E5F6374782E73746F72652E73657453656C65637465642874297D2C7A2E70726F746F747970652E73657453656C6563746564436F6F7264696E617465733D66756E6374696F6E2874297B76';
wwv_flow_imp.g_varchar2_table(125) := '617220653D746869733B746869732E5F6374782E73746F72652E73657453656C6563746564436F6F7264696E617465732874292C742E726564756365282866756E6374696F6E28742C6E297B72657475726E20766F696420303D3D3D745B6E2E66656174';
wwv_flow_imp.g_varchar2_table(126) := '7572655F69645D262628745B6E2E666561747572655F69645D3D21302C652E5F6374782E73746F72652E676574286E2E666561747572655F6964292E6368616E6765642829292C747D292C7B7D297D2C7A2E70726F746F747970652E67657453656C6563';
wwv_flow_imp.g_varchar2_table(127) := '7465643D66756E6374696F6E28297B72657475726E20746869732E5F6374782E73746F72652E67657453656C656374656428297D2C7A2E70726F746F747970652E67657453656C65637465644964733D66756E6374696F6E28297B72657475726E207468';
wwv_flow_imp.g_varchar2_table(128) := '69732E5F6374782E73746F72652E67657453656C656374656449647328297D2C7A2E70726F746F747970652E697353656C65637465643D66756E6374696F6E2874297B72657475726E20746869732E5F6374782E73746F72652E697353656C6563746564';
wwv_flow_imp.g_varchar2_table(129) := '2874297D2C7A2E70726F746F747970652E676574466561747572653D66756E6374696F6E2874297B72657475726E20746869732E5F6374782E73746F72652E6765742874297D2C7A2E70726F746F747970652E73656C6563743D66756E6374696F6E2874';
wwv_flow_imp.g_varchar2_table(130) := '297B72657475726E20746869732E5F6374782E73746F72652E73656C6563742874297D2C7A2E70726F746F747970652E646573656C6563743D66756E6374696F6E2874297B72657475726E20746869732E5F6374782E73746F72652E646573656C656374';
wwv_flow_imp.g_varchar2_table(131) := '2874297D2C7A2E70726F746F747970652E64656C657465466561747572653D66756E6374696F6E28742C65297B72657475726E20766F696420303D3D3D65262628653D7B7D292C746869732E5F6374782E73746F72652E64656C65746528742C65297D2C';
wwv_flow_imp.g_varchar2_table(132) := '7A2E70726F746F747970652E616464466561747572653D66756E6374696F6E2874297B72657475726E20746869732E5F6374782E73746F72652E6164642874297D2C7A2E70726F746F747970652E636C65617253656C656374656446656174757265733D';
wwv_flow_imp.g_varchar2_table(133) := '66756E6374696F6E28297B72657475726E20746869732E5F6374782E73746F72652E636C65617253656C656374656428297D2C7A2E70726F746F747970652E636C65617253656C6563746564436F6F7264696E617465733D66756E6374696F6E28297B72';
wwv_flow_imp.g_varchar2_table(134) := '657475726E20746869732E5F6374782E73746F72652E636C65617253656C6563746564436F6F7264696E6174657328297D2C7A2E70726F746F747970652E736574416374696F6E61626C6553746174653D66756E6374696F6E2874297B766F696420303D';
wwv_flow_imp.g_varchar2_table(135) := '3D3D74262628743D7B7D293B76617220653D7B74726173683A742E74726173687C7C21312C636F6D62696E6546656174757265733A742E636F6D62696E6546656174757265737C7C21312C756E636F6D62696E6546656174757265733A742E756E636F6D';
wwv_flow_imp.g_varchar2_table(136) := '62696E6546656174757265737C7C21317D3B72657475726E20746869732E5F6374782E6576656E74732E616374696F6E61626C652865297D2C7A2E70726F746F747970652E6368616E67654D6F64653D66756E6374696F6E28742C652C6E297B72657475';
wwv_flow_imp.g_varchar2_table(137) := '726E20766F696420303D3D3D65262628653D7B7D292C766F696420303D3D3D6E2626286E3D7B7D292C746869732E5F6374782E6576656E74732E6368616E67654D6F646528742C652C6E297D2C7A2E70726F746F747970652E7570646174655549436C61';
wwv_flow_imp.g_varchar2_table(138) := '737365733D66756E6374696F6E2874297B72657475726E20746869732E5F6374782E75692E71756575654D6170436C61737365732874297D2C7A2E70726F746F747970652E61637469766174655549427574746F6E3D66756E6374696F6E2874297B7265';
wwv_flow_imp.g_varchar2_table(139) := '7475726E20746869732E5F6374782E75692E736574416374697665427574746F6E2874297D2C7A2E70726F746F747970652E666561747572657341743D66756E6374696F6E28742C652C6E297B696628766F696420303D3D3D6E2626286E3D22636C6963';
wwv_flow_imp.g_varchar2_table(140) := '6B22292C22636C69636B22213D3D6E262622746F75636822213D3D6E297468726F77206E6577204572726F722822696E76616C696420627566666572207479706522293B72657475726E20435B6E5D28742C652C746869732E5F637478297D2C7A2E7072';
wwv_flow_imp.g_varchar2_table(141) := '6F746F747970652E6E6577466561747572653D66756E6374696F6E2874297B76617220653D742E67656F6D657472792E747970653B72657475726E20653D3D3D6C2E504F494E543F6E6577204428746869732E5F6374782C74293A653D3D3D6C2E4C494E';
wwv_flow_imp.g_varchar2_table(142) := '455F535452494E473F6E6577205628746869732E5F6374782C74293A653D3D3D6C2E504F4C59474F4E3F6E6577204228746869732E5F6374782C74293A6E6577204A28746869732E5F6374782C74297D2C7A2E70726F746F747970652E6973496E737461';
wwv_flow_imp.g_varchar2_table(143) := '6E63654F663D66756E6374696F6E28742C65297B696628743D3D3D6C2E504F494E542972657475726E206520696E7374616E63656F6620443B696628743D3D3D6C2E4C494E455F535452494E472972657475726E206520696E7374616E63656F6620563B';
wwv_flow_imp.g_varchar2_table(144) := '696628743D3D3D6C2E504F4C59474F4E2972657475726E206520696E7374616E63656F6620423B696628224D756C746946656174757265223D3D3D742972657475726E206520696E7374616E63656F66204A3B7468726F77206E6577204572726F722822';
wwv_flow_imp.g_varchar2_table(145) := '556E6B6E6F776E206665617475726520636C6173733A20222B74297D2C7A2E70726F746F747970652E646F52656E6465723D66756E6374696F6E2874297B72657475726E20746869732E5F6374782E73746F72652E666561747572654368616E67656428';
wwv_flow_imp.g_varchar2_table(146) := '74297D2C7A2E70726F746F747970652E6F6E53657475703D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E447261673D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E436C69636B3D66756E6374696F6E28297B';
wwv_flow_imp.g_varchar2_table(147) := '7D2C7A2E70726F746F747970652E6F6E4D6F7573654D6F76653D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E4D6F757365446F776E3D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E4D6F75736555703D6675';
wwv_flow_imp.g_varchar2_table(148) := '6E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E4D6F7573654F75743D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E4B657955703D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E4B6579446F77';
wwv_flow_imp.g_varchar2_table(149) := '6E3D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E546F75636853746172743D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E546F7563684D6F76653D66756E6374696F6E28297B7D2C7A2E70726F746F747970';
wwv_flow_imp.g_varchar2_table(150) := '652E6F6E546F756368456E643D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E5461703D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E53746F703D66756E6374696F6E28297B7D2C7A2E70726F746F74797065';
wwv_flow_imp.g_varchar2_table(151) := '2E6F6E54726173683D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E436F6D62696E65466561747572653D66756E6374696F6E28297B7D2C7A2E70726F746F747970652E6F6E556E636F6D62696E65466561747572653D66756E6374';
wwv_flow_imp.g_varchar2_table(152) := '696F6E28297B7D2C7A2E70726F746F747970652E746F446973706C617946656174757265733D66756E6374696F6E28297B7468726F77206E6577204572726F722822596F75206D757374206F766572777269746520746F446973706C6179466561747572';
wwv_flow_imp.g_varchar2_table(153) := '657322297D3B76617220593D7B647261673A226F6E44726167222C636C69636B3A226F6E436C69636B222C6D6F7573656D6F76653A226F6E4D6F7573654D6F7665222C6D6F757365646F776E3A226F6E4D6F757365446F776E222C6D6F75736575703A22';
wwv_flow_imp.g_varchar2_table(154) := '6F6E4D6F7573655570222C6D6F7573656F75743A226F6E4D6F7573654F7574222C6B657975703A226F6E4B65795570222C6B6579646F776E3A226F6E4B6579446F776E222C746F75636873746172743A226F6E546F7563685374617274222C746F756368';
wwv_flow_imp.g_varchar2_table(155) := '6D6F76653A226F6E546F7563684D6F7665222C746F756368656E643A226F6E546F756368456E64222C7461703A226F6E546170227D2C713D4F626A6563742E6B6579732859293B66756E6374696F6E20572874297B76617220653D4F626A6563742E6B65';
wwv_flow_imp.g_varchar2_table(156) := '79732874293B72657475726E2066756E6374696F6E286E2C72297B766F696420303D3D3D72262628723D7B7D293B766172206F3D7B7D2C693D652E726564756365282866756E6374696F6E28652C6E297B72657475726E20655B6E5D3D745B6E5D2C657D';
wwv_flow_imp.g_varchar2_table(157) := '292C6E6577207A286E29293B72657475726E7B73746172743A66756E6374696F6E28297B76617220653D746869733B6F3D692E6F6E53657475702872292C712E666F7245616368282866756E6374696F6E286E297B76617220722C613D595B6E5D2C733D';
wwv_flow_imp.g_varchar2_table(158) := '66756E6374696F6E28297B72657475726E21317D3B745B615D262628733D66756E6374696F6E28297B72657475726E21307D292C652E6F6E286E2C732C28723D612C66756E6374696F6E2874297B72657475726E20695B725D286F2C74297D29297D2929';
wwv_flow_imp.g_varchar2_table(159) := '7D2C73746F703A66756E6374696F6E28297B692E6F6E53746F70286F297D2C74726173683A66756E6374696F6E28297B692E6F6E5472617368286F297D2C636F6D62696E6546656174757265733A66756E6374696F6E28297B692E6F6E436F6D62696E65';
wwv_flow_imp.g_varchar2_table(160) := '4665617475726573286F297D2C756E636F6D62696E6546656174757265733A66756E6374696F6E28297B692E6F6E556E636F6D62696E654665617475726573286F297D2C72656E6465723A66756E6374696F6E28742C65297B692E746F446973706C6179';
wwv_flow_imp.g_varchar2_table(161) := '4665617475726573286F2C742C65297D7D7D7D66756E6374696F6E20482874297B72657475726E5B5D2E636F6E6361742874292E66696C746572282866756E6374696F6E2874297B72657475726E20766F69642030213D3D747D29297D66756E6374696F';
wwv_flow_imp.g_varchar2_table(162) := '6E205828297B76617220743D746869733B6966282128742E6374782E6D61702626766F69642030213D3D742E6374782E6D61702E676574536F7572636528732E484F5429292972657475726E206328293B76617220653D742E6374782E6576656E74732E';
wwv_flow_imp.g_varchar2_table(163) := '63757272656E744D6F64654E616D6528293B742E6374782E75692E71756575654D6170436C6173736573287B6D6F64653A657D293B766172206E3D5B5D2C723D5B5D3B742E697344697274793F723D742E676574416C6C49647328293A286E3D742E6765';
wwv_flow_imp.g_varchar2_table(164) := '744368616E67656449647328292E66696C746572282866756E6374696F6E2865297B72657475726E20766F69642030213D3D742E6765742865297D29292C723D742E736F75726365732E686F742E66696C746572282866756E6374696F6E2865297B7265';
wwv_flow_imp.g_varchar2_table(165) := '7475726E20652E70726F706572746965732E696426262D313D3D3D6E2E696E6465784F6628652E70726F706572746965732E6964292626766F69642030213D3D742E67657428652E70726F706572746965732E6964297D29292E6D6170282866756E6374';
wwv_flow_imp.g_varchar2_table(166) := '696F6E2874297B72657475726E20742E70726F706572746965732E69647D2929292C742E736F75726365732E686F743D5B5D3B766172206F3D742E736F75726365732E636F6C642E6C656E6774683B742E736F75726365732E636F6C643D742E69734469';
wwv_flow_imp.g_varchar2_table(167) := '7274793F5B5D3A742E736F75726365732E636F6C642E66696C746572282866756E6374696F6E2874297B76617220653D742E70726F706572746965732E69647C7C742E70726F706572746965732E706172656E743B72657475726E2D313D3D3D6E2E696E';
wwv_flow_imp.g_varchar2_table(168) := '6465784F662865297D29293B76617220693D6F213D3D742E736F75726365732E636F6C642E6C656E6774687C7C722E6C656E6774683E303B66756E6374696F6E2061286E2C72297B766172206F3D742E676574286E292E696E7465726E616C2865293B74';
wwv_flow_imp.g_varchar2_table(169) := '2E6374782E6576656E74732E63757272656E744D6F646552656E646572286F2C2866756E6374696F6E2865297B742E736F75726365735B725D2E707573682865297D29297D6966286E2E666F7245616368282866756E6374696F6E2874297B7265747572';
wwv_flow_imp.g_varchar2_table(170) := '6E206128742C22686F7422297D29292C722E666F7245616368282866756E6374696F6E2874297B72657475726E206128742C22636F6C6422297D29292C692626742E6374782E6D61702E676574536F7572636528732E434F4C44292E7365744461746128';
wwv_flow_imp.g_varchar2_table(171) := '7B747970653A6C2E464541545552455F434F4C4C454354494F4E2C66656174757265733A742E736F75726365732E636F6C647D292C742E6374782E6D61702E676574536F7572636528732E484F54292E73657444617461287B747970653A6C2E46454154';
wwv_flow_imp.g_varchar2_table(172) := '5552455F434F4C4C454354494F4E2C66656174757265733A742E736F75726365732E686F747D292C742E5F656D697453656C656374696F6E4368616E6765262628742E6374782E6D61702E6669726528702E53454C454354494F4E5F4348414E47452C7B';
wwv_flow_imp.g_varchar2_table(173) := '66656174757265733A742E67657453656C656374656428292E6D6170282866756E6374696F6E2874297B72657475726E20742E746F47656F4A534F4E28297D29292C706F696E74733A742E67657453656C6563746564436F6F7264696E6174657328292E';
wwv_flow_imp.g_varchar2_table(174) := '6D6170282866756E6374696F6E2874297B72657475726E7B747970653A6C2E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A6C2E504F494E542C636F6F7264696E617465733A742E636F6F7264696E617465';
wwv_flow_imp.g_varchar2_table(175) := '737D7D7D29297D292C742E5F656D697453656C656374696F6E4368616E67653D2131292C742E5F64656C657465644665617475726573546F456D69742E6C656E677468297B76617220753D742E5F64656C657465644665617475726573546F456D69742E';
wwv_flow_imp.g_varchar2_table(176) := '6D6170282866756E6374696F6E2874297B72657475726E20742E746F47656F4A534F4E28297D29293B742E5F64656C657465644665617475726573546F456D69743D5B5D2C742E6374782E6D61702E6669726528702E44454C4554452C7B666561747572';
wwv_flow_imp.g_varchar2_table(177) := '65733A757D297D66756E6374696F6E206328297B742E697344697274793D21312C742E636C6561724368616E67656449647328297D6328292C742E6374782E6D61702E6669726528702E52454E4445522C7B7D297D66756E6374696F6E205A2874297B76';
wwv_flow_imp.g_varchar2_table(178) := '617220652C6E3D746869733B746869732E5F66656174757265733D7B7D2C746869732E5F666561747572654964733D6E657720532C746869732E5F73656C6563746564466561747572654964733D6E657720532C746869732E5F73656C6563746564436F';
wwv_flow_imp.g_varchar2_table(179) := '6F7264696E617465733D5B5D2C746869732E5F6368616E676564466561747572654964733D6E657720532C746869732E5F64656C657465644665617475726573546F456D69743D5B5D2C746869732E5F656D697453656C656374696F6E4368616E67653D';
wwv_flow_imp.g_varchar2_table(180) := '21312C746869732E5F6D6170496E697469616C436F6E6669673D7B7D2C746869732E6374783D742C746869732E736F75726365733D7B686F743A5B5D2C636F6C643A5B5D7D2C746869732E72656E6465723D66756E6374696F6E28297B657C7C28653D72';
wwv_flow_imp.g_varchar2_table(181) := '657175657374416E696D6174696F6E4672616D65282866756E6374696F6E28297B653D6E756C6C2C582E63616C6C286E297D2929297D2C746869732E697344697274793D21317D66756E6374696F6E204B28742C65297B766172206E3D742E5F73656C65';
wwv_flow_imp.g_varchar2_table(182) := '63746564436F6F7264696E617465732E66696C746572282866756E6374696F6E2865297B72657475726E20742E5F73656C6563746564466561747572654964732E68617328652E666561747572655F6964297D29293B742E5F73656C6563746564436F6F';
wwv_flow_imp.g_varchar2_table(183) := '7264696E617465732E6C656E6774683D3D3D6E2E6C656E6774687C7C652E73696C656E747C7C28742E5F656D697453656C656374696F6E4368616E67653D2130292C742E5F73656C6563746564436F6F7264696E617465733D6E7D5A2E70726F746F7479';
wwv_flow_imp.g_varchar2_table(184) := '70652E63726561746552656E64657242617463683D66756E6374696F6E28297B76617220743D746869732C653D746869732E72656E6465722C6E3D303B72657475726E20746869732E72656E6465723D66756E6374696F6E28297B6E2B2B7D2C66756E63';
wwv_flow_imp.g_varchar2_table(185) := '74696F6E28297B742E72656E6465723D652C6E3E302626742E72656E64657228297D7D2C5A2E70726F746F747970652E73657444697274793D66756E6374696F6E28297B72657475726E20746869732E697344697274793D21302C746869737D2C5A2E70';
wwv_flow_imp.g_varchar2_table(186) := '726F746F747970652E666561747572654368616E6765643D66756E6374696F6E2874297B72657475726E20746869732E5F6368616E676564466561747572654964732E6164642874292C746869737D2C5A2E70726F746F747970652E6765744368616E67';
wwv_flow_imp.g_varchar2_table(187) := '65644964733D66756E6374696F6E28297B72657475726E20746869732E5F6368616E676564466561747572654964732E76616C75657328297D2C5A2E70726F746F747970652E636C6561724368616E6765644964733D66756E6374696F6E28297B726574';
wwv_flow_imp.g_varchar2_table(188) := '75726E20746869732E5F6368616E676564466561747572654964732E636C65617228292C746869737D2C5A2E70726F746F747970652E676574416C6C4964733D66756E6374696F6E28297B72657475726E20746869732E5F666561747572654964732E76';
wwv_flow_imp.g_varchar2_table(189) := '616C75657328297D2C5A2E70726F746F747970652E6164643D66756E6374696F6E2874297B72657475726E20746869732E666561747572654368616E67656428742E6964292C746869732E5F66656174757265735B742E69645D3D742C746869732E5F66';
wwv_flow_imp.g_varchar2_table(190) := '6561747572654964732E61646428742E6964292C746869737D2C5A2E70726F746F747970652E64656C6574653D66756E6374696F6E28742C65297B766172206E3D746869733B72657475726E20766F696420303D3D3D65262628653D7B7D292C48287429';
wwv_flow_imp.g_varchar2_table(191) := '2E666F7245616368282866756E6374696F6E2874297B6E2E5F666561747572654964732E6861732874292626286E2E5F666561747572654964732E64656C6574652874292C6E2E5F73656C6563746564466561747572654964732E64656C657465287429';
wwv_flow_imp.g_varchar2_table(192) := '2C652E73696C656E747C7C2D313D3D3D6E2E5F64656C657465644665617475726573546F456D69742E696E6465784F66286E2E5F66656174757265735B745D2926266E2E5F64656C657465644665617475726573546F456D69742E70757368286E2E5F66';
wwv_flow_imp.g_varchar2_table(193) := '656174757265735B745D292C64656C657465206E2E5F66656174757265735B745D2C6E2E697344697274793D2130297D29292C4B28746869732C65292C746869737D2C5A2E70726F746F747970652E6765743D66756E6374696F6E2874297B7265747572';
wwv_flow_imp.g_varchar2_table(194) := '6E20746869732E5F66656174757265735B745D7D2C5A2E70726F746F747970652E676574416C6C3D66756E6374696F6E28297B76617220743D746869733B72657475726E204F626A6563742E6B65797328746869732E5F6665617475726573292E6D6170';
wwv_flow_imp.g_varchar2_table(195) := '282866756E6374696F6E2865297B72657475726E20742E5F66656174757265735B655D7D29297D2C5A2E70726F746F747970652E73656C6563743D66756E6374696F6E28742C65297B766172206E3D746869733B72657475726E20766F696420303D3D3D';
wwv_flow_imp.g_varchar2_table(196) := '65262628653D7B7D292C482874292E666F7245616368282866756E6374696F6E2874297B6E2E5F73656C6563746564466561747572654964732E6861732874297C7C286E2E5F73656C6563746564466561747572654964732E6164642874292C6E2E5F63';
wwv_flow_imp.g_varchar2_table(197) := '68616E676564466561747572654964732E6164642874292C652E73696C656E747C7C286E2E5F656D697453656C656374696F6E4368616E67653D213029297D29292C746869737D2C5A2E70726F746F747970652E646573656C6563743D66756E6374696F';
wwv_flow_imp.g_varchar2_table(198) := '6E28742C65297B766172206E3D746869733B72657475726E20766F696420303D3D3D65262628653D7B7D292C482874292E666F7245616368282866756E6374696F6E2874297B6E2E5F73656C6563746564466561747572654964732E6861732874292626';
wwv_flow_imp.g_varchar2_table(199) := '286E2E5F73656C6563746564466561747572654964732E64656C6574652874292C6E2E5F6368616E676564466561747572654964732E6164642874292C652E73696C656E747C7C286E2E5F656D697453656C656374696F6E4368616E67653D213029297D';
wwv_flow_imp.g_varchar2_table(200) := '29292C4B28746869732C65292C746869737D2C5A2E70726F746F747970652E636C65617253656C65637465643D66756E6374696F6E2874297B72657475726E20766F696420303D3D3D74262628743D7B7D292C746869732E646573656C65637428746869';
wwv_flow_imp.g_varchar2_table(201) := '732E5F73656C6563746564466561747572654964732E76616C75657328292C7B73696C656E743A742E73696C656E747D292C746869737D2C5A2E70726F746F747970652E73657453656C65637465643D66756E6374696F6E28742C65297B766172206E3D';
wwv_flow_imp.g_varchar2_table(202) := '746869733B72657475726E20766F696420303D3D3D65262628653D7B7D292C743D482874292C746869732E646573656C65637428746869732E5F73656C6563746564466561747572654964732E76616C75657328292E66696C746572282866756E637469';
wwv_flow_imp.g_varchar2_table(203) := '6F6E2865297B72657475726E2D313D3D3D742E696E6465784F662865297D29292C7B73696C656E743A652E73696C656E747D292C746869732E73656C65637428742E66696C746572282866756E6374696F6E2874297B72657475726E216E2E5F73656C65';
wwv_flow_imp.g_varchar2_table(204) := '63746564466561747572654964732E6861732874297D29292C7B73696C656E743A652E73696C656E747D292C746869737D2C5A2E70726F746F747970652E73657453656C6563746564436F6F7264696E617465733D66756E6374696F6E2874297B726574';
wwv_flow_imp.g_varchar2_table(205) := '75726E20746869732E5F73656C6563746564436F6F7264696E617465733D742C746869732E5F656D697453656C656374696F6E4368616E67653D21302C746869737D2C5A2E70726F746F747970652E636C65617253656C6563746564436F6F7264696E61';
wwv_flow_imp.g_varchar2_table(206) := '7465733D66756E6374696F6E28297B72657475726E20746869732E5F73656C6563746564436F6F7264696E617465733D5B5D2C746869732E5F656D697453656C656374696F6E4368616E67653D21302C746869737D2C5A2E70726F746F747970652E6765';
wwv_flow_imp.g_varchar2_table(207) := '7453656C65637465644964733D66756E6374696F6E28297B72657475726E20746869732E5F73656C6563746564466561747572654964732E76616C75657328297D2C5A2E70726F746F747970652E67657453656C65637465643D66756E6374696F6E2829';
wwv_flow_imp.g_varchar2_table(208) := '7B76617220743D746869733B72657475726E20746869732E5F73656C6563746564466561747572654964732E76616C75657328292E6D6170282866756E6374696F6E2865297B72657475726E20742E6765742865297D29297D2C5A2E70726F746F747970';
wwv_flow_imp.g_varchar2_table(209) := '652E67657453656C6563746564436F6F7264696E617465733D66756E6374696F6E28297B76617220743D746869733B72657475726E20746869732E5F73656C6563746564436F6F7264696E617465732E6D6170282866756E6374696F6E2865297B726574';
wwv_flow_imp.g_varchar2_table(210) := '75726E7B636F6F7264696E617465733A742E67657428652E666561747572655F6964292E676574436F6F7264696E61746528652E636F6F72645F70617468297D7D29297D2C5A2E70726F746F747970652E697353656C65637465643D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(211) := '2874297B72657475726E20746869732E5F73656C6563746564466561747572654964732E6861732874297D2C5A2E70726F746F747970652E7365744665617475726550726F70657274793D66756E6374696F6E28742C652C6E297B746869732E67657428';
wwv_flow_imp.g_varchar2_table(212) := '74292E73657450726F706572747928652C6E292C746869732E666561747572654368616E6765642874297D2C5A2E70726F746F747970652E73746F72654D6170436F6E6669673D66756E6374696F6E28297B76617220743D746869733B6D2E666F724561';
wwv_flow_imp.g_varchar2_table(213) := '6368282866756E6374696F6E2865297B742E6374782E6D61705B655D262628742E5F6D6170496E697469616C436F6E6669675B655D3D742E6374782E6D61705B655D2E6973456E61626C65642829297D29297D2C5A2E70726F746F747970652E72657374';
wwv_flow_imp.g_varchar2_table(214) := '6F72654D6170436F6E6669673D66756E6374696F6E28297B76617220743D746869733B4F626A6563742E6B65797328746869732E5F6D6170496E697469616C436F6E666967292E666F7245616368282866756E6374696F6E2865297B742E5F6D6170496E';
wwv_flow_imp.g_varchar2_table(215) := '697469616C436F6E6669675B655D3F742E6374782E6D61705B655D2E656E61626C6528293A742E6374782E6D61705B655D2E64697361626C6528297D29297D2C5A2E70726F746F747970652E676574496E697469616C436F6E66696756616C75653D6675';
wwv_flow_imp.g_varchar2_table(216) := '6E6374696F6E2874297B72657475726E20766F696420303D3D3D746869732E5F6D6170496E697469616C436F6E6669675B745D7C7C746869732E5F6D6170496E697469616C436F6E6669675B745D7D3B76617220513D66756E6374696F6E28297B666F72';
wwv_flow_imp.g_varchar2_table(217) := '2876617220743D617267756D656E74732C653D7B7D2C6E3D303B6E3C617267756D656E74732E6C656E6774683B6E2B2B297B76617220723D745B6E5D3B666F7228766172206F20696E20722974742E63616C6C28722C6F29262628655B6F5D3D725B6F5D';
wwv_flow_imp.g_varchar2_table(218) := '297D72657475726E20657D2C74743D4F626A6563742E70726F746F747970652E6861734F776E50726F70657274793B7661722065743D5B226D6F6465222C2266656174757265222C226D6F757365225D3B66756E6374696F6E206E742865297B76617220';
wwv_flow_imp.g_varchar2_table(219) := '6E3D6E756C6C2C723D6E756C6C2C6F3D7B6F6E52656D6F76653A66756E6374696F6E28297B72657475726E20652E6D61702E6F666628226C6F6164222C6F2E636F6E6E656374292C636C656172496E74657276616C2872292C6F2E72656D6F76654C6179';
wwv_flow_imp.g_varchar2_table(220) := '65727328292C652E73746F72652E726573746F72654D6170436F6E66696728292C652E75692E72656D6F7665427574746F6E7328292C652E6576656E74732E72656D6F76654576656E744C697374656E65727328292C652E75692E636C6561724D617043';
wwv_flow_imp.g_varchar2_table(221) := '6C617373657328292C652E6D61703D6E756C6C2C652E636F6E7461696E65723D6E756C6C2C652E73746F72653D6E756C6C2C6E26266E2E706172656E744E6F646526266E2E706172656E744E6F64652E72656D6F76654368696C64286E292C6E3D6E756C';
wwv_flow_imp.g_varchar2_table(222) := '6C2C746869737D2C636F6E6E6563743A66756E6374696F6E28297B652E6D61702E6F666628226C6F6164222C6F2E636F6E6E656374292C636C656172496E74657276616C2872292C6F2E6164644C617965727328292C652E73746F72652E73746F72654D';
wwv_flow_imp.g_varchar2_table(223) := '6170436F6E66696728292C652E6576656E74732E6164644576656E744C697374656E65727328297D2C6F6E4164643A66756E6374696F6E2869297B76617220733D692E666972653B72657475726E20692E666972653D66756E6374696F6E28742C65297B';
wwv_flow_imp.g_varchar2_table(224) := '766172206E3D617267756D656E74733B72657475726E20313D3D3D732E6C656E677468262631213D3D617267756D656E74732E6C656E6774682626286E3D5B51287B7D2C7B747970653A747D2C65295D292C732E6170706C7928692C6E297D2C652E6D61';
wwv_flow_imp.g_varchar2_table(225) := '703D692C652E6576656E74733D66756E6374696F6E2865297B766172206E3D4F626A6563742E6B65797328652E6F7074696F6E732E6D6F646573292E726564756365282866756E6374696F6E28742C6E297B72657475726E20745B6E5D3D5728652E6F70';
wwv_flow_imp.g_varchar2_table(226) := '74696F6E732E6D6F6465735B6E5D292C747D292C7B7D292C723D7B7D2C6F3D7B7D2C693D7B7D2C613D6E756C6C2C733D6E756C6C3B692E647261673D66756E6374696F6E28742C6E297B6E287B706F696E743A742E706F696E742C74696D653A286E6577';
wwv_flow_imp.g_varchar2_table(227) := '2044617465292E67657454696D6528297D293F28652E75692E71756575654D6170436C6173736573287B6D6F7573653A752E445241477D292C732E64726167287429293A742E6F726967696E616C4576656E742E73746F7050726F7061676174696F6E28';
wwv_flow_imp.g_varchar2_table(228) := '297D2C692E6D6F757365647261673D66756E6374696F6E2874297B692E6472616728742C2866756E6374696F6E2874297B72657475726E215028722C74297D29297D2C692E746F756368647261673D66756E6374696F6E2874297B692E6472616728742C';
wwv_flow_imp.g_varchar2_table(229) := '2866756E6374696F6E2874297B72657475726E2146286F2C74297D29297D2C692E6D6F7573656D6F76653D66756E6374696F6E2874297B696628313D3D3D28766F69642030213D3D742E6F726967696E616C4576656E742E627574746F6E733F742E6F72';
wwv_flow_imp.g_varchar2_table(230) := '6967696E616C4576656E742E627574746F6E733A742E6F726967696E616C4576656E742E7768696368292972657475726E20692E6D6F757365647261672874293B766172206E3D4928742C65293B742E666561747572655461726765743D6E2C732E6D6F';
wwv_flow_imp.g_varchar2_table(231) := '7573656D6F76652874297D2C692E6D6F757365646F776E3D66756E6374696F6E2874297B723D7B74696D653A286E65772044617465292E67657454696D6528292C706F696E743A742E706F696E747D3B766172206E3D4928742C65293B742E6665617475';
wwv_flow_imp.g_varchar2_table(232) := '72655461726765743D6E2C732E6D6F757365646F776E2874297D2C692E6D6F75736575703D66756E6374696F6E2874297B766172206E3D4928742C65293B742E666561747572655461726765743D6E2C5028722C7B706F696E743A742E706F696E742C74';
wwv_flow_imp.g_varchar2_table(233) := '696D653A286E65772044617465292E67657454696D6528297D293F732E636C69636B2874293A732E6D6F75736575702874297D2C692E6D6F7573656F75743D66756E6374696F6E2874297B732E6D6F7573656F75742874297D2C692E746F756368737461';
wwv_flow_imp.g_varchar2_table(234) := '72743D66756E6374696F6E2874297B696628742E6F726967696E616C4576656E742E70726576656E7444656661756C7428292C652E6F7074696F6E732E746F756368456E61626C6564297B6F3D7B74696D653A286E65772044617465292E67657454696D';
wwv_flow_imp.g_varchar2_table(235) := '6528292C706F696E743A742E706F696E747D3B766172206E3D432E746F75636828742C6E756C6C2C65295B305D3B742E666561747572655461726765743D6E2C732E746F75636873746172742874297D7D2C692E746F7563686D6F76653D66756E637469';
wwv_flow_imp.g_varchar2_table(236) := '6F6E2874297B696628742E6F726967696E616C4576656E742E70726576656E7444656661756C7428292C652E6F7074696F6E732E746F756368456E61626C65642972657475726E20732E746F7563686D6F76652874292C692E746F756368647261672874';
wwv_flow_imp.g_varchar2_table(237) := '297D2C692E746F756368656E643D66756E6374696F6E2874297B696628742E6F726967696E616C4576656E742E70726576656E7444656661756C7428292C652E6F7074696F6E732E746F756368456E61626C6564297B766172206E3D432E746F75636828';
wwv_flow_imp.g_varchar2_table(238) := '742C6E756C6C2C65295B305D3B742E666561747572655461726765743D6E2C46286F2C7B74696D653A286E65772044617465292E67657454696D6528292C706F696E743A742E706F696E747D293F732E7461702874293A732E746F756368656E64287429';
wwv_flow_imp.g_varchar2_table(239) := '7D7D3B76617220633D66756E6374696F6E2874297B72657475726E2128383D3D3D747C7C34363D3D3D747C7C743E3D34382626743C3D3537297D3B66756E6374696F6E206C28722C6F2C69297B766F696420303D3D3D69262628693D7B7D292C732E7374';
wwv_flow_imp.g_varchar2_table(240) := '6F7028293B76617220753D6E5B725D3B696628766F696420303D3D3D75297468726F77206E6577204572726F7228722B22206973206E6F742076616C696422293B613D723B76617220633D7528652C6F293B733D7428632C65292C692E73696C656E747C';
wwv_flow_imp.g_varchar2_table(241) := '7C652E6D61702E6669726528702E4D4F44455F4348414E47452C7B6D6F64653A727D292C652E73746F72652E736574446972747928292C652E73746F72652E72656E64657228297D692E6B6579646F776E3D66756E6374696F6E2874297B226D6170626F';
wwv_flow_imp.g_varchar2_table(242) := '78676C2D63616E766173223D3D3D28742E737263456C656D656E747C7C742E746172676574292E636C6173734C6973745B305D26262838213D3D742E6B6579436F646526263436213D3D742E6B6579436F64657C7C21652E6F7074696F6E732E636F6E74';
wwv_flow_imp.g_varchar2_table(243) := '726F6C732E74726173683F6328742E6B6579436F6465293F732E6B6579646F776E2874293A34393D3D3D742E6B6579436F64652626652E6F7074696F6E732E636F6E74726F6C732E706F696E743F6C28682E445241575F504F494E54293A35303D3D3D74';
wwv_flow_imp.g_varchar2_table(244) := '2E6B6579436F64652626652E6F7074696F6E732E636F6E74726F6C732E6C696E655F737472696E673F6C28682E445241575F4C494E455F535452494E47293A35313D3D3D742E6B6579436F64652626652E6F7074696F6E732E636F6E74726F6C732E706F';
wwv_flow_imp.g_varchar2_table(245) := '6C79676F6E26266C28682E445241575F504F4C59474F4E293A28742E70726576656E7444656661756C7428292C732E7472617368282929297D2C692E6B657975703D66756E6374696F6E2874297B6328742E6B6579436F6465292626732E6B6579757028';
wwv_flow_imp.g_varchar2_table(246) := '74297D2C692E7A6F6F6D656E643D66756E6374696F6E28297B652E73746F72652E6368616E67655A6F6F6D28297D2C692E646174613D66756E6374696F6E2874297B696628227374796C65223D3D3D742E6461746154797065297B766172206E3D652E73';
wwv_flow_imp.g_varchar2_table(247) := '657475702C723D652E6D61702C6F3D652E6F7074696F6E732C693D652E73746F72653B6F2E7374796C65732E736F6D65282866756E6374696F6E2874297B72657475726E20722E6765744C6179657228742E6964297D29297C7C286E2E6164644C617965';
wwv_flow_imp.g_varchar2_table(248) := '727328292C692E736574446972747928292C692E72656E6465722829297D7D3B76617220643D7B74726173683A21312C636F6D62696E6546656174757265733A21312C756E636F6D62696E6546656174757265733A21317D3B72657475726E7B73746172';
wwv_flow_imp.g_varchar2_table(249) := '743A66756E6374696F6E28297B613D652E6F7074696F6E732E64656661756C744D6F64652C733D74286E5B615D2865292C65297D2C6368616E67654D6F64653A6C2C616374696F6E61626C653A66756E6374696F6E2874297B766172206E3D21313B4F62';
wwv_flow_imp.g_varchar2_table(250) := '6A6563742E6B6579732874292E666F7245616368282866756E6374696F6E2865297B696628766F696420303D3D3D645B655D297468726F77206E6577204572726F722822496E76616C696420616374696F6E207479706522293B645B655D213D3D745B65';
wwv_flow_imp.g_varchar2_table(251) := '5D2626286E3D2130292C645B655D3D745B655D7D29292C6E2626652E6D61702E6669726528702E414354494F4E41424C452C7B616374696F6E733A647D297D2C63757272656E744D6F64654E616D653A66756E6374696F6E28297B72657475726E20617D';
wwv_flow_imp.g_varchar2_table(252) := '2C63757272656E744D6F646552656E6465723A66756E6374696F6E28742C65297B72657475726E20732E72656E64657228742C65297D2C666972653A66756E6374696F6E28742C65297B695B745D2626695B745D2865297D2C6164644576656E744C6973';
wwv_flow_imp.g_varchar2_table(253) := '74656E6572733A66756E6374696F6E28297B652E6D61702E6F6E28226D6F7573656D6F7665222C692E6D6F7573656D6F7665292C652E6D61702E6F6E28226D6F757365646F776E222C692E6D6F757365646F776E292C652E6D61702E6F6E28226D6F7573';
wwv_flow_imp.g_varchar2_table(254) := '657570222C692E6D6F7573657570292C652E6D61702E6F6E282264617461222C692E64617461292C652E6D61702E6F6E2822746F7563686D6F7665222C692E746F7563686D6F7665292C652E6D61702E6F6E2822746F7563687374617274222C692E746F';
wwv_flow_imp.g_varchar2_table(255) := '7563687374617274292C652E6D61702E6F6E2822746F756368656E64222C692E746F756368656E64292C652E636F6E7461696E65722E6164644576656E744C697374656E657228226D6F7573656F7574222C692E6D6F7573656F7574292C652E6F707469';
wwv_flow_imp.g_varchar2_table(256) := '6F6E732E6B657962696E64696E6773262628652E636F6E7461696E65722E6164644576656E744C697374656E657228226B6579646F776E222C692E6B6579646F776E292C652E636F6E7461696E65722E6164644576656E744C697374656E657228226B65';
wwv_flow_imp.g_varchar2_table(257) := '797570222C692E6B6579757029297D2C72656D6F76654576656E744C697374656E6572733A66756E6374696F6E28297B652E6D61702E6F666628226D6F7573656D6F7665222C692E6D6F7573656D6F7665292C652E6D61702E6F666628226D6F75736564';
wwv_flow_imp.g_varchar2_table(258) := '6F776E222C692E6D6F757365646F776E292C652E6D61702E6F666628226D6F7573657570222C692E6D6F7573657570292C652E6D61702E6F6666282264617461222C692E64617461292C652E6D61702E6F66662822746F7563686D6F7665222C692E746F';
wwv_flow_imp.g_varchar2_table(259) := '7563686D6F7665292C652E6D61702E6F66662822746F7563687374617274222C692E746F7563687374617274292C652E6D61702E6F66662822746F756368656E64222C692E746F756368656E64292C652E636F6E7461696E65722E72656D6F7665457665';
wwv_flow_imp.g_varchar2_table(260) := '6E744C697374656E657228226D6F7573656F7574222C692E6D6F7573656F7574292C652E6F7074696F6E732E6B657962696E64696E6773262628652E636F6E7461696E65722E72656D6F76654576656E744C697374656E657228226B6579646F776E222C';
wwv_flow_imp.g_varchar2_table(261) := '692E6B6579646F776E292C652E636F6E7461696E65722E72656D6F76654576656E744C697374656E657228226B65797570222C692E6B6579757029297D2C74726173683A66756E6374696F6E2874297B732E74726173682874297D2C636F6D62696E6546';
wwv_flow_imp.g_varchar2_table(262) := '656174757265733A66756E6374696F6E28297B732E636F6D62696E65466561747572657328297D2C756E636F6D62696E6546656174757265733A66756E6374696F6E28297B732E756E636F6D62696E65466561747572657328297D2C6765744D6F64653A';
wwv_flow_imp.g_varchar2_table(263) := '66756E6374696F6E28297B72657475726E20617D7D7D2865292C652E75693D66756E6374696F6E2874297B76617220653D7B7D2C6E3D6E756C6C2C723D7B6D6F64653A6E756C6C2C666561747572653A6E756C6C2C6D6F7573653A6E756C6C7D2C6F3D7B';
wwv_flow_imp.g_varchar2_table(264) := '6D6F64653A6E756C6C2C666561747572653A6E756C6C2C6D6F7573653A6E756C6C7D3B66756E6374696F6E20692874297B6F3D51286F2C74297D66756E6374696F6E207328297B76617220652C6E3B696628742E636F6E7461696E6572297B7661722069';
wwv_flow_imp.g_varchar2_table(265) := '3D5B5D2C613D5B5D3B65742E666F7245616368282866756E6374696F6E2874297B6F5B745D213D3D725B745D262628692E7075736828742B222D222B725B745D292C6E756C6C213D3D6F5B745D2626612E7075736828742B222D222B6F5B745D29297D29';
wwv_flow_imp.g_varchar2_table(266) := '292C692E6C656E6774683E30262628653D742E636F6E7461696E65722E636C6173734C697374292E72656D6F76652E6170706C7928652C69292C612E6C656E6774683E302626286E3D742E636F6E7461696E65722E636C6173734C697374292E6164642E';
wwv_flow_imp.g_varchar2_table(267) := '6170706C79286E2C61292C723D5128722C6F297D7D66756E6374696F6E207528742C65297B766F696420303D3D3D65262628653D7B7D293B76617220723D646F63756D656E742E637265617465456C656D656E742822627574746F6E22293B7265747572';
wwv_flow_imp.g_varchar2_table(268) := '6E20722E636C6173734E616D653D612E434F4E54524F4C5F425554544F4E2B2220222B652E636C6173734E616D652C722E73657441747472696275746528227469746C65222C652E7469746C65292C652E636F6E7461696E65722E617070656E64436869';
wwv_flow_imp.g_varchar2_table(269) := '6C642872292C722E6164644576656E744C697374656E65722822636C69636B222C2866756E6374696F6E2872297B696628722E70726576656E7444656661756C7428292C722E73746F7050726F7061676174696F6E28292C722E7461726765743D3D3D6E';
wwv_flow_imp.g_varchar2_table(270) := '2972657475726E206C28292C766F696420652E6F6E4465616374697661746528293B702874292C652E6F6E416374697661746528297D292C2130292C727D66756E6374696F6E206C28297B6E2626286E2E636C6173734C6973742E72656D6F766528612E';
wwv_flow_imp.g_varchar2_table(271) := '4143544956455F425554544F4E292C6E3D6E756C6C297D66756E6374696F6E20702874297B6C28293B76617220723D655B745D3B72262672262622747261736822213D3D74262628722E636C6173734C6973742E61646428612E4143544956455F425554';
wwv_flow_imp.g_varchar2_table(272) := '544F4E292C6E3D72297D72657475726E7B736574416374697665427574746F6E3A702C71756575654D6170436C61737365733A692C7570646174654D6170436C61737365733A732C636C6561724D6170436C61737365733A66756E6374696F6E28297B69';
wwv_flow_imp.g_varchar2_table(273) := '287B6D6F64653A6E756C6C2C666561747572653A6E756C6C2C6D6F7573653A6E756C6C7D292C7328297D2C616464427574746F6E733A66756E6374696F6E28297B766172206E3D742E6F7074696F6E732E636F6E74726F6C732C723D646F63756D656E74';
wwv_flow_imp.g_varchar2_table(274) := '2E637265617465456C656D656E74282264697622293B72657475726E20722E636C6173734E616D653D612E434F4E54524F4C5F47524F55502B2220222B612E434F4E54524F4C5F424153452C6E3F286E5B632E4C494E455D262628655B632E4C494E455D';
wwv_flow_imp.g_varchar2_table(275) := '3D7528632E4C494E452C7B636F6E7461696E65723A722C636C6173734E616D653A612E434F4E54524F4C5F425554544F4E5F4C494E452C7469746C653A224C696E65537472696E6720746F6F6C20222B28742E6F7074696F6E732E6B657962696E64696E';
wwv_flow_imp.g_varchar2_table(276) := '67733F22286C29223A2222292C6F6E41637469766174653A66756E6374696F6E28297B72657475726E20742E6576656E74732E6368616E67654D6F646528682E445241575F4C494E455F535452494E47297D2C6F6E446561637469766174653A66756E63';
wwv_flow_imp.g_varchar2_table(277) := '74696F6E28297B72657475726E20742E6576656E74732E747261736828297D7D29292C6E5B632E504F4C59474F4E5D262628655B632E504F4C59474F4E5D3D7528632E504F4C59474F4E2C7B636F6E7461696E65723A722C636C6173734E616D653A612E';
wwv_flow_imp.g_varchar2_table(278) := '434F4E54524F4C5F425554544F4E5F504F4C59474F4E2C7469746C653A22506F6C79676F6E20746F6F6C20222B28742E6F7074696F6E732E6B657962696E64696E67733F22287029223A2222292C6F6E41637469766174653A66756E6374696F6E28297B';
wwv_flow_imp.g_varchar2_table(279) := '72657475726E20742E6576656E74732E6368616E67654D6F646528682E445241575F504F4C59474F4E297D2C6F6E446561637469766174653A66756E6374696F6E28297B72657475726E20742E6576656E74732E747261736828297D7D29292C6E5B632E';
wwv_flow_imp.g_varchar2_table(280) := '504F494E545D262628655B632E504F494E545D3D7528632E504F494E542C7B636F6E7461696E65723A722C636C6173734E616D653A612E434F4E54524F4C5F425554544F4E5F504F494E542C7469746C653A224D61726B657220746F6F6C20222B28742E';
wwv_flow_imp.g_varchar2_table(281) := '6F7074696F6E732E6B657962696E64696E67733F22286D29223A2222292C6F6E41637469766174653A66756E6374696F6E28297B72657475726E20742E6576656E74732E6368616E67654D6F646528682E445241575F504F494E54297D2C6F6E44656163';
wwv_flow_imp.g_varchar2_table(282) := '7469766174653A66756E6374696F6E28297B72657475726E20742E6576656E74732E747261736828297D7D29292C6E2E7472617368262628652E74726173683D7528227472617368222C7B636F6E7461696E65723A722C636C6173734E616D653A612E43';
wwv_flow_imp.g_varchar2_table(283) := '4F4E54524F4C5F425554544F4E5F54524153482C7469746C653A2244656C657465222C6F6E41637469766174653A66756E6374696F6E28297B742E6576656E74732E747261736828297D7D29292C6E2E636F6D62696E655F666561747572657326262865';
wwv_flow_imp.g_varchar2_table(284) := '2E636F6D62696E655F66656174757265733D752822636F6D62696E654665617475726573222C7B636F6E7461696E65723A722C636C6173734E616D653A612E434F4E54524F4C5F425554544F4E5F434F4D42494E455F46454154555245532C7469746C65';
wwv_flow_imp.g_varchar2_table(285) := '3A22436F6D62696E65222C6F6E41637469766174653A66756E6374696F6E28297B742E6576656E74732E636F6D62696E65466561747572657328297D7D29292C6E2E756E636F6D62696E655F6665617475726573262628652E756E636F6D62696E655F66';
wwv_flow_imp.g_varchar2_table(286) := '656174757265733D752822756E636F6D62696E654665617475726573222C7B636F6E7461696E65723A722C636C6173734E616D653A612E434F4E54524F4C5F425554544F4E5F554E434F4D42494E455F46454154555245532C7469746C653A22556E636F';
wwv_flow_imp.g_varchar2_table(287) := '6D62696E65222C6F6E41637469766174653A66756E6374696F6E28297B742E6576656E74732E756E636F6D62696E65466561747572657328297D7D29292C72293A727D2C72656D6F7665427574746F6E733A66756E6374696F6E28297B4F626A6563742E';
wwv_flow_imp.g_varchar2_table(288) := '6B6579732865292E666F7245616368282866756E6374696F6E2874297B766172206E3D655B745D3B6E2E706172656E744E6F646526266E2E706172656E744E6F64652E72656D6F76654368696C64286E292C64656C65746520655B745D7D29297D7D7D28';
wwv_flow_imp.g_varchar2_table(289) := '65292C652E636F6E7461696E65723D692E676574436F6E7461696E657228292C652E73746F72653D6E6577205A2865292C6E3D652E75692E616464427574746F6E7328292C652E6F7074696F6E732E626F7853656C656374262628692E626F785A6F6F6D';
wwv_flow_imp.g_varchar2_table(290) := '2E64697361626C6528292C692E6472616750616E2E64697361626C6528292C692E6472616750616E2E656E61626C652829292C692E6C6F6164656428293F6F2E636F6E6E65637428293A28692E6F6E28226C6F6164222C6F2E636F6E6E656374292C723D';
wwv_flow_imp.g_varchar2_table(291) := '736574496E74657276616C282866756E6374696F6E28297B692E6C6F61646564282926266F2E636F6E6E65637428297D292C313629292C652E6576656E74732E737461727428292C6E7D2C6164644C61796572733A66756E6374696F6E28297B652E6D61';
wwv_flow_imp.g_varchar2_table(292) := '702E616464536F7572636528732E434F4C442C7B646174613A7B747970653A6C2E464541545552455F434F4C4C454354494F4E2C66656174757265733A5B5D7D2C747970653A2267656F6A736F6E227D292C652E6D61702E616464536F7572636528732E';
wwv_flow_imp.g_varchar2_table(293) := '484F542C7B646174613A7B747970653A6C2E464541545552455F434F4C4C454354494F4E2C66656174757265733A5B5D7D2C747970653A2267656F6A736F6E227D292C652E6F7074696F6E732E7374796C65732E666F7245616368282866756E6374696F';
wwv_flow_imp.g_varchar2_table(294) := '6E2874297B652E6D61702E6164644C617965722874297D29292C652E73746F72652E7365744469727479282130292C652E73746F72652E72656E64657228297D2C72656D6F76654C61796572733A66756E6374696F6E28297B652E6F7074696F6E732E73';
wwv_flow_imp.g_varchar2_table(295) := '74796C65732E666F7245616368282866756E6374696F6E2874297B652E6D61702E6765744C6179657228742E6964292626652E6D61702E72656D6F76654C6179657228742E6964297D29292C652E6D61702E676574536F7572636528732E434F4C442926';
wwv_flow_imp.g_varchar2_table(296) := '26652E6D61702E72656D6F7665536F7572636528732E434F4C44292C652E6D61702E676574536F7572636528732E484F54292626652E6D61702E72656D6F7665536F7572636528732E484F54297D7D3B72657475726E20652E73657475703D6F2C6F7D66';
wwv_flow_imp.g_varchar2_table(297) := '756E6374696F6E2072742874297B72657475726E2066756E6374696F6E2865297B766172206E3D652E666561747572655461726765743B72657475726E21216E26262821216E2E70726F7065727469657326266E2E70726F706572746965732E6D657461';
wwv_flow_imp.g_varchar2_table(298) := '3D3D3D74297D7D66756E6374696F6E206F742874297B72657475726E2121742E666561747572655461726765742626282121742E666561747572655461726765742E70726F70657274696573262628742E666561747572655461726765742E70726F7065';
wwv_flow_imp.g_varchar2_table(299) := '72746965732E6163746976653D3D3D792E4143544956452626742E666561747572655461726765742E70726F706572746965732E6D6574613D3D3D672E4645415455524529297D66756E6374696F6E2069742874297B72657475726E2121742E66656174';
wwv_flow_imp.g_varchar2_table(300) := '7572655461726765742626282121742E666561747572655461726765742E70726F70657274696573262628742E666561747572655461726765742E70726F706572746965732E6163746976653D3D3D792E494E4143544956452626742E66656174757265';
wwv_flow_imp.g_varchar2_table(301) := '5461726765742E70726F706572746965732E6D6574613D3D3D672E4645415455524529297D66756E6374696F6E2061742874297B72657475726E20766F696420303D3D3D742E666561747572655461726765747D66756E6374696F6E2073742874297B76';
wwv_flow_imp.g_varchar2_table(302) := '617220653D742E666561747572655461726765743B72657475726E2121652626282121652E70726F706572746965732626652E70726F706572746965732E6D6574613D3D3D672E564552544558297D66756E6374696F6E2075742874297B72657475726E';
wwv_flow_imp.g_varchar2_table(303) := '2121742E6F726967696E616C4576656E74262621303D3D3D742E6F726967696E616C4576656E742E73686966744B65797D66756E6374696F6E2063742874297B72657475726E2032373D3D3D742E6B6579436F64657D66756E6374696F6E206C74287429';
wwv_flow_imp.g_varchar2_table(304) := '7B72657475726E2031333D3D3D742E6B6579436F64657D7661722068743D70743B66756E6374696F6E20707428742C65297B746869732E783D742C746869732E793D657D66756E6374696F6E20647428742C65297B766172206E3D652E676574426F756E';
wwv_flow_imp.g_varchar2_table(305) := '64696E67436C69656E745265637428293B72657475726E206E657720687428742E636C69656E74582D6E2E6C6566742D28652E636C69656E744C6566747C7C30292C742E636C69656E74592D6E2E746F702D28652E636C69656E74546F707C7C3029297D';
wwv_flow_imp.g_varchar2_table(306) := '66756E6374696F6E20667428742C652C6E2C72297B72657475726E7B747970653A6C2E464541545552452C70726F706572746965733A7B6D6574613A672E5645525445582C706172656E743A742C636F6F72645F706174683A6E2C6163746976653A723F';
wwv_flow_imp.g_varchar2_table(307) := '792E4143544956453A792E494E4143544956457D2C67656F6D657472793A7B747970653A6C2E504F494E542C636F6F7264696E617465733A657D7D7D66756E6374696F6E20677428742C652C6E297B766F696420303D3D3D65262628653D7B7D292C766F';
wwv_flow_imp.g_varchar2_table(308) := '696420303D3D3D6E2626286E3D6E756C6C293B76617220722C6F3D742E67656F6D657472792C693D6F2E747970652C613D6F2E636F6F7264696E617465732C733D742E70726F706572746965732626742E70726F706572746965732E69642C753D5B5D3B';
wwv_flow_imp.g_varchar2_table(309) := '66756E6374696F6E206328742C6E297B76617220723D22222C6F3D6E756C6C3B742E666F7245616368282866756E6374696F6E28742C69297B76617220613D6E756C6C213D6E3F6E2B222E222B693A537472696E672869292C633D667428732C742C612C';
wwv_flow_imp.g_varchar2_table(310) := '68286129293B696628652E6D6964706F696E747326266F297B76617220703D66756E6374696F6E28742C652C6E297B76617220723D652E67656F6D657472792E636F6F7264696E617465732C6F3D6E2E67656F6D657472792E636F6F7264696E61746573';
wwv_flow_imp.g_varchar2_table(311) := '3B696628725B315D3E5F7C7C725B315D3C767C7C6F5B315D3E5F7C7C6F5B315D3C762972657475726E206E756C6C3B76617220693D7B6C6E673A28725B305D2B6F5B305D292F322C6C61743A28725B315D2B6F5B315D292F327D3B72657475726E7B7479';
wwv_flow_imp.g_varchar2_table(312) := '70653A6C2E464541545552452C70726F706572746965733A7B6D6574613A672E4D4944504F494E542C706172656E743A742C6C6E673A692E6C6E672C6C61743A692E6C61742C636F6F72645F706174683A6E2E70726F706572746965732E636F6F72645F';
wwv_flow_imp.g_varchar2_table(313) := '706174687D2C67656F6D657472793A7B747970653A6C2E504F494E542C636F6F7264696E617465733A5B692E6C6E672C692E6C61745D7D7D7D28732C6F2C63293B702626752E707573682870297D6F3D633B76617220643D4A534F4E2E737472696E6769';
wwv_flow_imp.g_varchar2_table(314) := '66792874293B72213D3D642626752E707573682863292C303D3D3D69262628723D64297D29297D66756E6374696F6E20682874297B72657475726E2121652E73656C6563746564506174687326262D31213D3D652E73656C656374656450617468732E69';
wwv_flow_imp.g_varchar2_table(315) := '6E6465784F662874297D72657475726E20693D3D3D6C2E504F494E543F752E7075736828667428732C612C6E2C68286E2929293A693D3D3D6C2E504F4C59474F4E3F612E666F7245616368282866756E6374696F6E28742C65297B6328742C6E756C6C21';
wwv_flow_imp.g_varchar2_table(316) := '3D3D6E3F6E2B222E222B653A537472696E67286529297D29293A693D3D3D6C2E4C494E455F535452494E473F6328612C6E293A303D3D3D692E696E6465784F66286C2E4D554C54495F50524546495829262628723D692E7265706C616365286C2E4D554C';
wwv_flow_imp.g_varchar2_table(317) := '54495F5052454649582C2222292C612E666F7245616368282866756E6374696F6E286E2C6F297B76617220693D7B747970653A6C2E464541545552452C70726F706572746965733A742E70726F706572746965732C67656F6D657472793A7B747970653A';
wwv_flow_imp.g_varchar2_table(318) := '722C636F6F7264696E617465733A6E7D7D3B753D752E636F6E63617428677428692C652C6F29297D2929292C757D70742E70726F746F747970653D7B636C6F6E653A66756E6374696F6E28297B72657475726E206E657720707428746869732E782C7468';
wwv_flow_imp.g_varchar2_table(319) := '69732E79297D2C6164643A66756E6374696F6E2874297B72657475726E20746869732E636C6F6E6528292E5F6164642874297D2C7375623A66756E6374696F6E2874297B72657475726E20746869732E636C6F6E6528292E5F7375622874297D2C6D756C';
wwv_flow_imp.g_varchar2_table(320) := '744279506F696E743A66756E6374696F6E2874297B72657475726E20746869732E636C6F6E6528292E5F6D756C744279506F696E742874297D2C6469764279506F696E743A66756E6374696F6E2874297B72657475726E20746869732E636C6F6E652829';
wwv_flow_imp.g_varchar2_table(321) := '2E5F6469764279506F696E742874297D2C6D756C743A66756E6374696F6E2874297B72657475726E20746869732E636C6F6E6528292E5F6D756C742874297D2C6469763A66756E6374696F6E2874297B72657475726E20746869732E636C6F6E6528292E';
wwv_flow_imp.g_varchar2_table(322) := '5F6469762874297D2C726F746174653A66756E6374696F6E2874297B72657475726E20746869732E636C6F6E6528292E5F726F746174652874297D2C726F7461746541726F756E643A66756E6374696F6E28742C65297B72657475726E20746869732E63';
wwv_flow_imp.g_varchar2_table(323) := '6C6F6E6528292E5F726F7461746541726F756E6428742C65297D2C6D61744D756C743A66756E6374696F6E2874297B72657475726E20746869732E636C6F6E6528292E5F6D61744D756C742874297D2C756E69743A66756E6374696F6E28297B72657475';
wwv_flow_imp.g_varchar2_table(324) := '726E20746869732E636C6F6E6528292E5F756E697428297D2C706572703A66756E6374696F6E28297B72657475726E20746869732E636C6F6E6528292E5F7065727028297D2C726F756E643A66756E6374696F6E28297B72657475726E20746869732E63';
wwv_flow_imp.g_varchar2_table(325) := '6C6F6E6528292E5F726F756E6428297D2C6D61673A66756E6374696F6E28297B72657475726E204D6174682E7371727428746869732E782A746869732E782B746869732E792A746869732E79297D2C657175616C733A66756E6374696F6E2874297B7265';
wwv_flow_imp.g_varchar2_table(326) := '7475726E20746869732E783D3D3D742E782626746869732E793D3D3D742E797D2C646973743A66756E6374696F6E2874297B72657475726E204D6174682E7371727428746869732E64697374537172287429297D2C646973745371723A66756E6374696F';
wwv_flow_imp.g_varchar2_table(327) := '6E2874297B76617220653D742E782D746869732E782C6E3D742E792D746869732E793B72657475726E20652A652B6E2A6E7D2C616E676C653A66756E6374696F6E28297B72657475726E204D6174682E6174616E3228746869732E792C746869732E7829';
wwv_flow_imp.g_varchar2_table(328) := '7D2C616E676C65546F3A66756E6374696F6E2874297B72657475726E204D6174682E6174616E3228746869732E792D742E792C746869732E782D742E78297D2C616E676C65576974683A66756E6374696F6E2874297B72657475726E20746869732E616E';
wwv_flow_imp.g_varchar2_table(329) := '676C655769746853657028742E782C742E79297D2C616E676C65576974685365703A66756E6374696F6E28742C65297B72657475726E204D6174682E6174616E3228746869732E782A652D746869732E792A742C746869732E782A742B746869732E792A';
wwv_flow_imp.g_varchar2_table(330) := '65297D2C5F6D61744D756C743A66756E6374696F6E2874297B76617220653D745B305D2A746869732E782B745B315D2A746869732E792C6E3D745B325D2A746869732E782B745B335D2A746869732E793B72657475726E20746869732E783D652C746869';
wwv_flow_imp.g_varchar2_table(331) := '732E793D6E2C746869737D2C5F6164643A66756E6374696F6E2874297B72657475726E20746869732E782B3D742E782C746869732E792B3D742E792C746869737D2C5F7375623A66756E6374696F6E2874297B72657475726E20746869732E782D3D742E';
wwv_flow_imp.g_varchar2_table(332) := '782C746869732E792D3D742E792C746869737D2C5F6D756C743A66756E6374696F6E2874297B72657475726E20746869732E782A3D742C746869732E792A3D742C746869737D2C5F6469763A66756E6374696F6E2874297B72657475726E20746869732E';
wwv_flow_imp.g_varchar2_table(333) := '782F3D742C746869732E792F3D742C746869737D2C5F6D756C744279506F696E743A66756E6374696F6E2874297B72657475726E20746869732E782A3D742E782C746869732E792A3D742E792C746869737D2C5F6469764279506F696E743A66756E6374';
wwv_flow_imp.g_varchar2_table(334) := '696F6E2874297B72657475726E20746869732E782F3D742E782C746869732E792F3D742E792C746869737D2C5F756E69743A66756E6374696F6E28297B72657475726E20746869732E5F64697628746869732E6D61672829292C746869737D2C5F706572';
wwv_flow_imp.g_varchar2_table(335) := '703A66756E6374696F6E28297B76617220743D746869732E793B72657475726E20746869732E793D746869732E782C746869732E783D2D742C746869737D2C5F726F746174653A66756E6374696F6E2874297B76617220653D4D6174682E636F73287429';
wwv_flow_imp.g_varchar2_table(336) := '2C6E3D4D6174682E73696E2874292C723D652A746869732E782D6E2A746869732E792C6F3D6E2A746869732E782B652A746869732E793B72657475726E20746869732E783D722C746869732E793D6F2C746869737D2C5F726F7461746541726F756E643A';
wwv_flow_imp.g_varchar2_table(337) := '66756E6374696F6E28742C65297B766172206E3D4D6174682E636F732874292C723D4D6174682E73696E2874292C6F3D652E782B6E2A28746869732E782D652E78292D722A28746869732E792D652E79292C693D652E792B722A28746869732E782D652E';
wwv_flow_imp.g_varchar2_table(338) := '78292B6E2A28746869732E792D652E79293B72657475726E20746869732E783D6F2C746869732E793D692C746869737D2C5F726F756E643A66756E6374696F6E28297B72657475726E20746869732E783D4D6174682E726F756E6428746869732E78292C';
wwv_flow_imp.g_varchar2_table(339) := '746869732E793D4D6174682E726F756E6428746869732E79292C746869737D7D2C70742E636F6E766572743D66756E6374696F6E2874297B72657475726E207420696E7374616E63656F662070743F743A41727261792E697341727261792874293F6E65';
wwv_flow_imp.g_varchar2_table(340) := '7720707428745B305D2C745B315D293A747D3B7661722079743D66756E6374696F6E2874297B73657454696D656F7574282866756E6374696F6E28297B742E6D61702626742E6D61702E646F75626C65436C69636B5A6F6F6D2626742E5F637478262674';
wwv_flow_imp.g_varchar2_table(341) := '2E5F6374782E73746F72652626742E5F6374782E73746F72652E676574496E697469616C436F6E66696756616C75652626742E5F6374782E73746F72652E676574496E697469616C436F6E66696756616C75652822646F75626C65436C69636B5A6F6F6D';
wwv_flow_imp.g_varchar2_table(342) := '22292626742E6D61702E646F75626C65436C69636B5A6F6F6D2E656E61626C6528297D292C30297D2C6D743D66756E6374696F6E2874297B73657454696D656F7574282866756E6374696F6E28297B742E6D61702626742E6D61702E646F75626C65436C';
wwv_flow_imp.g_varchar2_table(343) := '69636B5A6F6F6D2626742E6D61702E646F75626C65436C69636B5A6F6F6D2E64697361626C6528297D292C30297D2C76743D66756E6374696F6E2874297B69662821747C7C21742E747970652972657475726E206E756C6C3B76617220653D5F745B742E';
wwv_flow_imp.g_varchar2_table(344) := '747970655D3B69662821652972657475726E206E756C6C3B6966282267656F6D65747279223D3D3D652972657475726E7B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B7B747970653A2246656174757265222C';
wwv_flow_imp.g_varchar2_table(345) := '70726F706572746965733A7B7D2C67656F6D657472793A747D5D7D3B6966282266656174757265223D3D3D652972657475726E7B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B745D7D3B696628226665617475';
wwv_flow_imp.g_varchar2_table(346) := '7265636F6C6C656374696F6E223D3D3D652972657475726E20747D2C5F743D7B506F696E743A2267656F6D65747279222C4D756C7469506F696E743A2267656F6D65747279222C4C696E65537472696E673A2267656F6D65747279222C4D756C74694C69';
wwv_flow_imp.g_varchar2_table(347) := '6E65537472696E673A2267656F6D65747279222C506F6C79676F6E3A2267656F6D65747279222C4D756C7469506F6C79676F6E3A2267656F6D65747279222C47656F6D65747279436F6C6C656374696F6E3A2267656F6D65747279222C46656174757265';
wwv_flow_imp.g_varchar2_table(348) := '3A2266656174757265222C46656174757265436F6C6C656374696F6E3A2266656174757265636F6C6C656374696F6E227D3B7661722062743D66756E6374696F6E2874297B69662821742972657475726E5B5D3B76617220653D66756E6374696F6E2074';
wwv_flow_imp.g_varchar2_table(349) := '2865297B73776974636828652626652E747970657C7C6E756C6C297B636173652246656174757265436F6C6C656374696F6E223A72657475726E20652E66656174757265733D652E66656174757265732E726564756365282866756E6374696F6E28652C';
wwv_flow_imp.g_varchar2_table(350) := '6E297B72657475726E20652E636F6E6361742874286E29297D292C5B5D292C653B636173652246656174757265223A72657475726E20652E67656F6D657472793F7428652E67656F6D65747279292E6D6170282866756E6374696F6E2874297B76617220';
wwv_flow_imp.g_varchar2_table(351) := '6E3D7B747970653A2246656174757265222C70726F706572746965733A4A534F4E2E7061727365284A534F4E2E737472696E6769667928652E70726F7065727469657329292C67656F6D657472793A747D3B72657475726E20766F69642030213D3D652E';
wwv_flow_imp.g_varchar2_table(352) := '69642626286E2E69643D652E6964292C6E7D29293A653B63617365224D756C7469506F696E74223A72657475726E20652E636F6F7264696E617465732E6D6170282866756E6374696F6E2874297B72657475726E7B747970653A22506F696E74222C636F';
wwv_flow_imp.g_varchar2_table(353) := '6F7264696E617465733A747D7D29293B63617365224D756C7469506F6C79676F6E223A72657475726E20652E636F6F7264696E617465732E6D6170282866756E6374696F6E2874297B72657475726E7B747970653A22506F6C79676F6E222C636F6F7264';
wwv_flow_imp.g_varchar2_table(354) := '696E617465733A747D7D29293B63617365224D756C74694C696E65537472696E67223A72657475726E20652E636F6F7264696E617465732E6D6170282866756E6374696F6E2874297B72657475726E7B747970653A224C696E65537472696E67222C636F';
wwv_flow_imp.g_varchar2_table(355) := '6F7264696E617465733A747D7D29293B636173652247656F6D65747279436F6C6C656374696F6E223A72657475726E20652E67656F6D6574726965732E6D61702874292E726564756365282866756E6374696F6E28742C65297B72657475726E20742E63';
wwv_flow_imp.g_varchar2_table(356) := '6F6E6361742865297D292C5B5D293B6361736522506F696E74223A6361736522506F6C79676F6E223A63617365224C696E65537472696E67223A72657475726E5B655D7D7D287674287429292C6E3D5B5D3B72657475726E20652E66656174757265732E';
wwv_flow_imp.g_varchar2_table(357) := '666F7245616368282866756E6374696F6E2874297B742E67656F6D657472792626286E3D6E2E636F6E6361742866756E6374696F6E20742865297B72657475726E2041727261792E697341727261792865292626652E6C656E6774682626226E756D6265';
wwv_flow_imp.g_varchar2_table(358) := '72223D3D747970656F6620655B305D3F5B655D3A652E726564756365282866756E6374696F6E28652C6E297B72657475726E2041727261792E69734172726179286E29262641727261792E69734172726179286E5B305D293F652E636F6E636174287428';
wwv_flow_imp.g_varchar2_table(359) := '6E29293A28652E70757368286E292C65297D292C5B5D297D28742E67656F6D657472792E636F6F7264696E617465732929297D29292C6E7D2C45743D52282866756E6374696F6E2874297B76617220653D742E6578706F7274733D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(360) := '74297B72657475726E206E6577206E2874297D3B66756E6374696F6E206E2874297B746869732E76616C75653D747D66756E6374696F6E207228742C652C6E297B76617220723D5B5D2C613D5B5D2C6C3D21303B72657475726E2066756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(361) := '742868297B76617220703D6E3F6F2868293A682C643D7B7D2C663D21302C673D7B6E6F64653A702C6E6F64655F3A682C706174683A5B5D2E636F6E6361742872292C706172656E743A615B612E6C656E6774682D315D2C706172656E74733A612C6B6579';
wwv_flow_imp.g_varchar2_table(362) := '3A722E736C696365282D31295B305D2C6973526F6F743A303D3D3D722E6C656E6774682C6C6576656C3A722E6C656E6774682C63697263756C61723A6E756C6C2C7570646174653A66756E6374696F6E28742C65297B672E6973526F6F747C7C28672E70';
wwv_flow_imp.g_varchar2_table(363) := '6172656E742E6E6F64655B672E6B65795D3D74292C672E6E6F64653D742C65262628663D2131297D2C64656C6574653A66756E6374696F6E2874297B64656C65746520672E706172656E742E6E6F64655B672E6B65795D2C74262628663D2131297D2C72';
wwv_flow_imp.g_varchar2_table(364) := '656D6F76653A66756E6374696F6E2874297B7328672E706172656E742E6E6F6465293F672E706172656E742E6E6F64652E73706C69636528672E6B65792C31293A64656C65746520672E706172656E742E6E6F64655B672E6B65795D2C74262628663D21';
wwv_flow_imp.g_varchar2_table(365) := '31297D2C6B6579733A6E756C6C2C6265666F72653A66756E6374696F6E2874297B642E6265666F72653D747D2C61667465723A66756E6374696F6E2874297B642E61667465723D747D2C7072653A66756E6374696F6E2874297B642E7072653D747D2C70';
wwv_flow_imp.g_varchar2_table(366) := '6F73743A66756E6374696F6E2874297B642E706F73743D747D2C73746F703A66756E6374696F6E28297B6C3D21317D2C626C6F636B3A66756E6374696F6E28297B663D21317D7D3B696628216C2972657475726E20673B66756E6374696F6E207928297B';
wwv_flow_imp.g_varchar2_table(367) := '696628226F626A656374223D3D747970656F6620672E6E6F646526266E756C6C213D3D672E6E6F6465297B672E6B6579732626672E6E6F64655F3D3D3D672E6E6F64657C7C28672E6B6579733D6928672E6E6F646529292C672E69734C6561663D303D3D';
wwv_flow_imp.g_varchar2_table(368) := '672E6B6579732E6C656E6774683B666F722876617220743D303B743C612E6C656E6774683B742B2B29696628615B745D2E6E6F64655F3D3D3D68297B672E63697263756C61723D615B745D3B627265616B7D7D656C736520672E69734C6561663D21302C';
wwv_flow_imp.g_varchar2_table(369) := '672E6B6579733D6E756C6C3B672E6E6F744C6561663D21672E69734C6561662C672E6E6F74526F6F743D21672E6973526F6F747D7928293B766172206D3D652E63616C6C28672C672E6E6F6465293B72657475726E20766F69642030213D3D6D2626672E';
wwv_flow_imp.g_varchar2_table(370) := '7570646174652626672E757064617465286D292C642E6265666F72652626642E6265666F72652E63616C6C28672C672E6E6F6465292C663F28226F626A65637422213D747970656F6620672E6E6F64657C7C6E756C6C3D3D3D672E6E6F64657C7C672E63';
wwv_flow_imp.g_varchar2_table(371) := '697263756C61727C7C28612E707573682867292C7928292C7528672E6B6579732C2866756E6374696F6E28652C6F297B722E707573682865292C642E7072652626642E7072652E63616C6C28672C672E6E6F64655B655D2C65293B76617220693D742867';
wwv_flow_imp.g_varchar2_table(372) := '2E6E6F64655B655D293B6E2626632E63616C6C28672E6E6F64652C6529262628672E6E6F64655B655D3D692E6E6F6465292C692E69734C6173743D6F3D3D672E6B6579732E6C656E6774682D312C692E697346697273743D303D3D6F2C642E706F737426';
wwv_flow_imp.g_varchar2_table(373) := '26642E706F73742E63616C6C28672C69292C722E706F7028297D29292C612E706F702829292C642E61667465722626642E61667465722E63616C6C28672C672E6E6F6465292C67293A677D2874292E6E6F64657D66756E6374696F6E206F2874297B6966';
wwv_flow_imp.g_varchar2_table(374) := '28226F626A656374223D3D747970656F66207426266E756C6C213D3D74297B76617220653B6966287328742929653D5B5D3B656C736520696628225B6F626A65637420446174655D223D3D3D6128742929653D6E6577204461746528742E67657454696D';
wwv_flow_imp.g_varchar2_table(375) := '653F742E67657454696D6528293A74293B656C73652069662866756E6374696F6E2874297B72657475726E225B6F626A656374205265674578705D223D3D3D612874297D28742929653D6E6577205265674578702874293B656C73652069662866756E63';
wwv_flow_imp.g_varchar2_table(376) := '74696F6E2874297B72657475726E225B6F626A656374204572726F725D223D3D3D612874297D28742929653D7B6D6573736167653A742E6D6573736167657D3B656C73652069662866756E6374696F6E2874297B72657475726E225B6F626A6563742042';
wwv_flow_imp.g_varchar2_table(377) := '6F6F6C65616E5D223D3D3D612874297D28742929653D6E657720426F6F6C65616E2874293B656C73652069662866756E6374696F6E2874297B72657475726E225B6F626A656374204E756D6265725D223D3D3D612874297D28742929653D6E6577204E75';
wwv_flow_imp.g_varchar2_table(378) := '6D6265722874293B656C73652069662866756E6374696F6E2874297B72657475726E225B6F626A65637420537472696E675D223D3D3D612874297D28742929653D6E657720537472696E672874293B656C7365206966284F626A6563742E637265617465';
wwv_flow_imp.g_varchar2_table(379) := '26264F626A6563742E67657450726F746F747970654F6629653D4F626A6563742E637265617465284F626A6563742E67657450726F746F747970654F66287429293B656C736520696628742E636F6E7374727563746F723D3D3D4F626A65637429653D7B';
wwv_flow_imp.g_varchar2_table(380) := '7D3B656C73657B766172206E3D742E636F6E7374727563746F722626742E636F6E7374727563746F722E70726F746F747970657C7C742E5F5F70726F746F5F5F7C7C7B7D2C723D66756E6374696F6E28297B7D3B722E70726F746F747970653D6E2C653D';
wwv_flow_imp.g_varchar2_table(381) := '6E657720727D72657475726E207528692874292C2866756E6374696F6E286E297B655B6E5D3D745B6E5D7D29292C657D72657475726E20747D6E2E70726F746F747970652E6765743D66756E6374696F6E2874297B666F722876617220653D746869732E';
wwv_flow_imp.g_varchar2_table(382) := '76616C75652C6E3D303B6E3C742E6C656E6774683B6E2B2B297B76617220723D745B6E5D3B69662821657C7C21632E63616C6C28652C7229297B653D766F696420303B627265616B7D653D655B725D7D72657475726E20657D2C6E2E70726F746F747970';
wwv_flow_imp.g_varchar2_table(383) := '652E6861733D66756E6374696F6E2874297B666F722876617220653D746869732E76616C75652C6E3D303B6E3C742E6C656E6774683B6E2B2B297B76617220723D745B6E5D3B69662821657C7C21632E63616C6C28652C72292972657475726E21313B65';
wwv_flow_imp.g_varchar2_table(384) := '3D655B725D7D72657475726E21307D2C6E2E70726F746F747970652E7365743D66756E6374696F6E28742C65297B666F7228766172206E3D746869732E76616C75652C723D303B723C742E6C656E6774682D313B722B2B297B766172206F3D745B725D3B';
wwv_flow_imp.g_varchar2_table(385) := '632E63616C6C286E2C6F297C7C286E5B6F5D3D7B7D292C6E3D6E5B6F5D7D72657475726E206E5B745B725D5D3D652C657D2C6E2E70726F746F747970652E6D61703D66756E6374696F6E2874297B72657475726E207228746869732E76616C75652C742C';
wwv_flow_imp.g_varchar2_table(386) := '2130297D2C6E2E70726F746F747970652E666F72456163683D66756E6374696F6E2874297B72657475726E20746869732E76616C75653D7228746869732E76616C75652C742C2131292C746869732E76616C75657D2C6E2E70726F746F747970652E7265';
wwv_flow_imp.g_varchar2_table(387) := '647563653D66756E6374696F6E28742C65297B766172206E3D313D3D3D617267756D656E74732E6C656E6774682C723D6E3F746869732E76616C75653A653B72657475726E20746869732E666F7245616368282866756E6374696F6E2865297B74686973';
wwv_flow_imp.g_varchar2_table(388) := '2E6973526F6F7426266E7C7C28723D742E63616C6C28746869732C722C6529297D29292C727D2C6E2E70726F746F747970652E70617468733D66756E6374696F6E28297B76617220743D5B5D3B72657475726E20746869732E666F724561636828286675';
wwv_flow_imp.g_varchar2_table(389) := '6E6374696F6E2865297B742E7075736828746869732E70617468297D29292C747D2C6E2E70726F746F747970652E6E6F6465733D66756E6374696F6E28297B76617220743D5B5D3B72657475726E20746869732E666F7245616368282866756E6374696F';
wwv_flow_imp.g_varchar2_table(390) := '6E2865297B742E7075736828746869732E6E6F6465297D29292C747D2C6E2E70726F746F747970652E636C6F6E653D66756E6374696F6E28297B76617220743D5B5D2C653D5B5D3B72657475726E2066756E6374696F6E206E2872297B666F7228766172';
wwv_flow_imp.g_varchar2_table(391) := '20613D303B613C742E6C656E6774683B612B2B29696628745B615D3D3D3D722972657475726E20655B615D3B696628226F626A656374223D3D747970656F66207226266E756C6C213D3D72297B76617220733D6F2872293B72657475726E20742E707573';
wwv_flow_imp.g_varchar2_table(392) := '682872292C652E707573682873292C7528692872292C2866756E6374696F6E2874297B735B745D3D6E28725B745D297D29292C742E706F7028292C652E706F7028292C737D72657475726E20727D28746869732E76616C7565297D3B76617220693D4F62';
wwv_flow_imp.g_varchar2_table(393) := '6A6563742E6B6579737C7C66756E6374696F6E2874297B76617220653D5B5D3B666F7228766172206E20696E207429652E70757368286E293B72657475726E20657D3B66756E6374696F6E20612874297B72657475726E204F626A6563742E70726F746F';
wwv_flow_imp.g_varchar2_table(394) := '747970652E746F537472696E672E63616C6C2874297D76617220733D41727261792E697341727261797C7C66756E6374696F6E2874297B72657475726E225B6F626A6563742041727261795D223D3D3D4F626A6563742E70726F746F747970652E746F53';
wwv_flow_imp.g_varchar2_table(395) := '7472696E672E63616C6C2874297D2C753D66756E6374696F6E28742C65297B696628742E666F72456163682972657475726E20742E666F72456163682865293B666F7228766172206E3D303B6E3C742E6C656E6774683B6E2B2B296528745B6E5D2C6E2C';
wwv_flow_imp.g_varchar2_table(396) := '74297D3B752869286E2E70726F746F74797065292C2866756E6374696F6E2874297B655B745D3D66756E6374696F6E2865297B76617220723D5B5D2E736C6963652E63616C6C28617267756D656E74732C31292C6F3D6E6577206E2865293B7265747572';
wwv_flow_imp.g_varchar2_table(397) := '6E206F5B745D2E6170706C79286F2C72297D7D29293B76617220633D4F626A6563742E6861734F776E50726F70657274797C7C66756E6374696F6E28742C65297B72657475726E206520696E20747D7D29292C53743D54743B66756E6374696F6E205474';
wwv_flow_imp.g_varchar2_table(398) := '2874297B69662821287468697320696E7374616E63656F66205474292972657475726E206E65772054742874293B746869732E5F62626F783D747C7C5B312F302C312F302C2D312F302C2D312F305D2C746869732E5F76616C69643D2121747D54742E70';
wwv_flow_imp.g_varchar2_table(399) := '726F746F747970652E696E636C7564653D66756E6374696F6E2874297B72657475726E20746869732E5F76616C69643D21302C746869732E5F62626F785B305D3D4D6174682E6D696E28746869732E5F62626F785B305D2C745B305D292C746869732E5F';
wwv_flow_imp.g_varchar2_table(400) := '62626F785B315D3D4D6174682E6D696E28746869732E5F62626F785B315D2C745B315D292C746869732E5F62626F785B325D3D4D6174682E6D617828746869732E5F62626F785B325D2C745B305D292C746869732E5F62626F785B335D3D4D6174682E6D';
wwv_flow_imp.g_varchar2_table(401) := '617828746869732E5F62626F785B335D2C745B315D292C746869737D2C54742E70726F746F747970652E657175616C733D66756E6374696F6E2874297B76617220653B72657475726E20653D7420696E7374616E63656F662054743F742E62626F782829';
wwv_flow_imp.g_varchar2_table(402) := '3A742C746869732E5F62626F785B305D3D3D655B305D2626746869732E5F62626F785B315D3D3D655B315D2626746869732E5F62626F785B325D3D3D655B325D2626746869732E5F62626F785B335D3D3D655B335D7D2C54742E70726F746F747970652E';
wwv_flow_imp.g_varchar2_table(403) := '63656E7465723D66756E6374696F6E2874297B72657475726E20746869732E5F76616C69643F5B28746869732E5F62626F785B305D2B746869732E5F62626F785B325D292F322C28746869732E5F62626F785B315D2B746869732E5F62626F785B335D29';
wwv_flow_imp.g_varchar2_table(404) := '2F325D3A6E756C6C7D2C54742E70726F746F747970652E756E696F6E3D66756E6374696F6E2874297B76617220653B72657475726E20746869732E5F76616C69643D21302C653D7420696E7374616E63656F662054743F742E62626F7828293A742C7468';
wwv_flow_imp.g_varchar2_table(405) := '69732E5F62626F785B305D3D4D6174682E6D696E28746869732E5F62626F785B305D2C655B305D292C746869732E5F62626F785B315D3D4D6174682E6D696E28746869732E5F62626F785B315D2C655B315D292C746869732E5F62626F785B325D3D4D61';
wwv_flow_imp.g_varchar2_table(406) := '74682E6D617828746869732E5F62626F785B325D2C655B325D292C746869732E5F62626F785B335D3D4D6174682E6D617828746869732E5F62626F785B335D2C655B335D292C746869737D2C54742E70726F746F747970652E62626F783D66756E637469';
wwv_flow_imp.g_varchar2_table(407) := '6F6E28297B72657475726E20746869732E5F76616C69643F746869732E5F62626F783A6E756C6C7D2C54742E70726F746F747970652E636F6E7461696E733D66756E6374696F6E2874297B69662821742972657475726E20746869732E5F66617374436F';
wwv_flow_imp.g_varchar2_table(408) := '6E7461696E7328293B69662821746869732E5F76616C69642972657475726E206E756C6C3B76617220653D745B305D2C6E3D745B315D3B72657475726E20746869732E5F62626F785B305D3C3D652626746869732E5F62626F785B315D3C3D6E26267468';
wwv_flow_imp.g_varchar2_table(409) := '69732E5F62626F785B325D3E3D652626746869732E5F62626F785B335D3E3D6E7D2C54742E70726F746F747970652E696E746572736563743D66756E6374696F6E2874297B72657475726E20746869732E5F76616C69643F28653D7420696E7374616E63';
wwv_flow_imp.g_varchar2_table(410) := '656F662054743F742E62626F7828293A742C2128746869732E5F62626F785B305D3E655B325D7C7C746869732E5F62626F785B325D3C655B305D7C7C746869732E5F62626F785B335D3C655B315D7C7C746869732E5F62626F785B315D3E655B335D2929';
wwv_flow_imp.g_varchar2_table(411) := '3A6E756C6C3B76617220657D2C54742E70726F746F747970652E5F66617374436F6E7461696E733D66756E6374696F6E28297B69662821746869732E5F76616C69642972657475726E206E65772046756E6374696F6E282272657475726E206E756C6C3B';
wwv_flow_imp.g_varchar2_table(412) := '22293B76617220743D2272657475726E20222B746869732E5F62626F785B305D2B223C3D206C6C5B305D202626222B746869732E5F62626F785B315D2B223C3D206C6C5B315D202626222B746869732E5F62626F785B325D2B223E3D206C6C5B305D2026';
wwv_flow_imp.g_varchar2_table(413) := '26222B746869732E5F62626F785B335D2B223E3D206C6C5B315D223B72657475726E206E65772046756E6374696F6E28226C6C222C74297D2C54742E70726F746F747970652E706F6C79676F6E3D66756E6374696F6E28297B72657475726E2074686973';
wwv_flow_imp.g_varchar2_table(414) := '2E5F76616C69643F7B747970653A22506F6C79676F6E222C636F6F7264696E617465733A5B5B5B746869732E5F62626F785B305D2C746869732E5F62626F785B315D5D2C5B746869732E5F62626F785B325D2C746869732E5F62626F785B315D5D2C5B74';
wwv_flow_imp.g_varchar2_table(415) := '6869732E5F62626F785B325D2C746869732E5F62626F785B335D5D2C5B746869732E5F62626F785B305D2C746869732E5F62626F785B335D5D2C5B746869732E5F62626F785B305D2C746869732E5F62626F785B315D5D5D5D7D3A6E756C6C7D3B766172';
wwv_flow_imp.g_varchar2_table(416) := '2043743D7B66656174757265733A5B2246656174757265436F6C6C656374696F6E225D2C636F6F7264696E617465733A5B22506F696E74222C224D756C7469506F696E74222C224C696E65537472696E67222C224D756C74694C696E65537472696E6722';
wwv_flow_imp.g_varchar2_table(417) := '2C22506F6C79676F6E222C224D756C7469506F6C79676F6E225D2C67656F6D657472793A5B2246656174757265225D2C67656F6D6574726965733A5B2247656F6D65747279436F6C6C656374696F6E225D7D2C4F743D4F626A6563742E6B657973284374';
wwv_flow_imp.g_varchar2_table(418) := '292C49743D66756E6374696F6E2874297B72657475726E2078742874292E62626F7828297D3B66756E6374696F6E2078742874297B666F722876617220653D537428292C6E3D62742874292C723D303B723C6E2E6C656E6774683B722B2B29652E696E63';
wwv_flow_imp.g_varchar2_table(419) := '6C756465286E5B725D293B72657475726E20657D49742E706F6C79676F6E3D66756E6374696F6E2874297B72657475726E2078742874292E706F6C79676F6E28297D2C49742E62626F786966793D66756E6374696F6E2874297B72657475726E20457428';
wwv_flow_imp.g_varchar2_table(420) := '74292E6D6170282866756E6374696F6E2874297B742626284F742E736F6D65282866756E6374696F6E2865297B72657475726E2121745B655D26262D31213D3D43745B655D2E696E6465784F6628742E74797065297D2929262628742E62626F783D7874';
wwv_flow_imp.g_varchar2_table(421) := '2874292E62626F7828292C746869732E75706461746528742929297D29297D3B766172204C743D2D39302C4D743D39302C4E743D762C50743D5F2C77743D2D3237302C41743D3237303B66756E6374696F6E20467428742C65297B766172206E3D4C742C';
wwv_flow_imp.g_varchar2_table(422) := '723D4D742C6F3D4C742C693D4D742C613D41742C733D77743B742E666F7245616368282866756E6374696F6E2874297B76617220653D49742874292C753D655B315D2C633D655B335D2C6C3D655B305D2C683D655B325D3B753E6E2626286E3D75292C63';
wwv_flow_imp.g_varchar2_table(423) := '3C72262628723D63292C633E6F2626286F3D63292C753C69262628693D75292C6C3C61262628613D6C292C683E73262628733D68297D29293B76617220753D653B72657475726E206E2B752E6C61743E5074262628752E6C61743D50742D6E292C6F2B75';
wwv_flow_imp.g_varchar2_table(424) := '2E6C61743E4D74262628752E6C61743D4D742D6F292C722B752E6C61743C4E74262628752E6C61743D4E742D72292C692B752E6C61743C4C74262628752E6C61743D4C742D69292C612B752E6C6E673C3D7774262628752E6C6E672B3D3336302A4D6174';
wwv_flow_imp.g_varchar2_table(425) := '682E6365696C284D6174682E61627328752E6C6E67292F33363029292C732B752E6C6E673E3D4174262628752E6C6E672D3D3336302A4D6174682E6365696C284D6174682E61627328752E6C6E67292F33363029292C757D66756E6374696F6E206B7428';
wwv_flow_imp.g_varchar2_table(426) := '742C65297B766172206E3D467428742E6D6170282866756E6374696F6E2874297B72657475726E20742E746F47656F4A534F4E28297D29292C65293B742E666F7245616368282866756E6374696F6E2874297B76617220652C723D742E676574436F6F72';
wwv_flow_imp.g_varchar2_table(427) := '64696E6174657328292C6F3D66756E6374696F6E2874297B76617220653D7B6C6E673A745B305D2B6E2E6C6E672C6C61743A745B315D2B6E2E6C61747D3B72657475726E5B652E6C6E672C652E6C61745D7D2C693D66756E6374696F6E2874297B726574';
wwv_flow_imp.g_varchar2_table(428) := '75726E20742E6D6170282866756E6374696F6E2874297B72657475726E206F2874297D29297D3B742E747970653D3D3D6C2E504F494E543F653D6F2872293A742E747970653D3D3D6C2E4C494E455F535452494E477C7C742E747970653D3D3D6C2E4D55';
wwv_flow_imp.g_varchar2_table(429) := '4C54495F504F494E543F653D722E6D6170286F293A742E747970653D3D3D6C2E504F4C59474F4E7C7C742E747970653D3D3D6C2E4D554C54495F4C494E455F535452494E473F653D722E6D61702869293A742E747970653D3D3D6C2E4D554C54495F504F';
wwv_flow_imp.g_varchar2_table(430) := '4C59474F4E262628653D722E6D6170282866756E6374696F6E2874297B72657475726E20742E6D6170282866756E6374696F6E2874297B72657475726E20692874297D29297D2929292C742E696E636F6D696E67436F6F7264732865297D29297D766172';
wwv_flow_imp.g_varchar2_table(431) := '2052743D7B6F6E53657475703A66756E6374696F6E2874297B76617220653D746869732C6E3D7B647261674D6F76654C6F636174696F6E3A6E756C6C2C626F7853656C65637453746172744C6F636174696F6E3A6E756C6C2C626F7853656C656374456C';
wwv_flow_imp.g_varchar2_table(432) := '656D656E743A766F696420302C626F7853656C656374696E673A21312C63616E426F7853656C6563743A21312C647261674D6F76696E673A21312C63616E447261674D6F76653A21312C696E697469616C6C7953656C6563746564466561747572654964';
wwv_flow_imp.g_varchar2_table(433) := '733A742E666561747572654964737C7C5B5D7D3B72657475726E20746869732E73657453656C6563746564286E2E696E697469616C6C7953656C6563746564466561747572654964732E66696C746572282866756E6374696F6E2874297B72657475726E';
wwv_flow_imp.g_varchar2_table(434) := '20766F69642030213D3D652E676574466561747572652874297D2929292C746869732E66697265416374696F6E61626C6528292C746869732E736574416374696F6E61626C655374617465287B636F6D62696E6546656174757265733A21302C756E636F';
wwv_flow_imp.g_varchar2_table(435) := '6D62696E6546656174757265733A21302C74726173683A21307D292C6E7D2C666972655570646174653A66756E6374696F6E28297B746869732E6D61702E6669726528702E5550444154452C7B616374696F6E3A642C66656174757265733A746869732E';
wwv_flow_imp.g_varchar2_table(436) := '67657453656C656374656428292E6D6170282866756E6374696F6E2874297B72657475726E20742E746F47656F4A534F4E28297D29297D297D2C66697265416374696F6E61626C653A66756E6374696F6E28297B76617220743D746869732C653D746869';
wwv_flow_imp.g_varchar2_table(437) := '732E67657453656C656374656428292C6E3D652E66696C746572282866756E6374696F6E2865297B72657475726E20742E6973496E7374616E63654F6628224D756C746946656174757265222C65297D29292C723D21313B696628652E6C656E6774683E';
wwv_flow_imp.g_varchar2_table(438) := '31297B723D21303B766172206F3D655B305D2E747970652E7265706C61636528224D756C7469222C2222293B652E666F7245616368282866756E6374696F6E2874297B742E747970652E7265706C61636528224D756C7469222C222229213D3D6F262628';
wwv_flow_imp.g_varchar2_table(439) := '723D2131297D29297D76617220693D6E2E6C656E6774683E302C613D652E6C656E6774683E303B746869732E736574416374696F6E61626C655374617465287B636F6D62696E6546656174757265733A722C756E636F6D62696E6546656174757265733A';
wwv_flow_imp.g_varchar2_table(440) := '692C74726173683A617D297D2C676574556E697175654964733A66756E6374696F6E2874297B72657475726E20742E6C656E6774683F742E6D6170282866756E6374696F6E2874297B72657475726E20742E70726F706572746965732E69647D29292E66';
wwv_flow_imp.g_varchar2_table(441) := '696C746572282866756E6374696F6E2874297B72657475726E20766F69642030213D3D747D29292E726564756365282866756E6374696F6E28742C65297B72657475726E20742E6164642865292C747D292C6E65772053292E76616C75657328293A5B5D';
wwv_flow_imp.g_varchar2_table(442) := '7D2C73746F70457874656E646564496E746572616374696F6E733A66756E6374696F6E2874297B742E626F7853656C656374456C656D656E74262628742E626F7853656C656374456C656D656E742E706172656E744E6F64652626742E626F7853656C65';
wwv_flow_imp.g_varchar2_table(443) := '6374456C656D656E742E706172656E744E6F64652E72656D6F76654368696C6428742E626F7853656C656374456C656D656E74292C742E626F7853656C656374456C656D656E743D6E756C6C292C746869732E6D61702E6472616750616E2E656E61626C';
wwv_flow_imp.g_varchar2_table(444) := '6528292C742E626F7853656C656374696E673D21312C742E63616E426F7853656C6563743D21312C742E647261674D6F76696E673D21312C742E63616E447261674D6F76653D21317D2C6F6E53746F703A66756E6374696F6E28297B7974287468697329';
wwv_flow_imp.g_varchar2_table(445) := '7D2C6F6E4D6F7573654D6F76653A66756E6374696F6E2874297B72657475726E20746869732E73746F70457874656E646564496E746572616374696F6E732874292C21307D2C6F6E4D6F7573654F75743A66756E6374696F6E2874297B72657475726E21';
wwv_flow_imp.g_varchar2_table(446) := '742E647261674D6F76696E677C7C746869732E6669726555706461746528297D7D3B52742E6F6E5461703D52742E6F6E436C69636B3D66756E6374696F6E28742C65297B72657475726E2061742865293F746869732E636C69636B416E79776865726528';
wwv_flow_imp.g_varchar2_table(447) := '742C65293A727428672E564552544558292865293F746869732E636C69636B4F6E56657274657828742C65293A66756E6374696F6E2874297B72657475726E2121742E666561747572655461726765742626282121742E66656174757265546172676574';
wwv_flow_imp.g_varchar2_table(448) := '2E70726F706572746965732626742E666561747572655461726765742E70726F706572746965732E6D6574613D3D3D672E46454154555245297D2865293F746869732E636C69636B4F6E4665617475726528742C65293A766F696420307D2C52742E636C';
wwv_flow_imp.g_varchar2_table(449) := '69636B416E7977686572653D66756E6374696F6E2874297B76617220653D746869732C6E3D746869732E67657453656C656374656449647328293B6E2E6C656E677468262628746869732E636C65617253656C6563746564466561747572657328292C6E';
wwv_flow_imp.g_varchar2_table(450) := '2E666F7245616368282866756E6374696F6E2874297B72657475726E20652E646F52656E6465722874297D2929292C79742874686973292C746869732E73746F70457874656E646564496E746572616374696F6E732874297D2C52742E636C69636B4F6E';
wwv_flow_imp.g_varchar2_table(451) := '5665727465783D66756E6374696F6E28742C65297B746869732E6368616E67654D6F646528682E4449524543545F53454C4543542C7B6665617475726549643A652E666561747572655461726765742E70726F706572746965732E706172656E742C636F';
wwv_flow_imp.g_varchar2_table(452) := '6F7264506174683A652E666561747572655461726765742E70726F706572746965732E636F6F72645F706174682C7374617274506F733A652E6C6E674C61747D292C746869732E7570646174655549436C6173736573287B6D6F7573653A752E4D4F5645';
wwv_flow_imp.g_varchar2_table(453) := '7D297D2C52742E73746172744F6E416374697665466561747572653D66756E6374696F6E28742C65297B746869732E73746F70457874656E646564496E746572616374696F6E732874292C746869732E6D61702E6472616750616E2E64697361626C6528';
wwv_flow_imp.g_varchar2_table(454) := '292C746869732E646F52656E64657228652E666561747572655461726765742E70726F706572746965732E6964292C742E63616E447261674D6F76653D21302C742E647261674D6F76654C6F636174696F6E3D652E6C6E674C61747D2C52742E636C6963';
wwv_flow_imp.g_varchar2_table(455) := '6B4F6E466561747572653D66756E6374696F6E28742C65297B766172206E3D746869733B6D742874686973292C746869732E73746F70457874656E646564496E746572616374696F6E732874293B76617220723D75742865292C6F3D746869732E676574';
wwv_flow_imp.g_varchar2_table(456) := '53656C656374656449647328292C693D652E666561747572655461726765742E70726F706572746965732E69642C613D746869732E697353656C65637465642869293B69662821722626612626746869732E676574466561747572652869292E74797065';
wwv_flow_imp.g_varchar2_table(457) := '213D3D6C2E504F494E542972657475726E20746869732E6368616E67654D6F646528682E4449524543545F53454C4543542C7B6665617475726549643A697D293B612626723F28746869732E646573656C6563742869292C746869732E75706461746555';
wwv_flow_imp.g_varchar2_table(458) := '49436C6173736573287B6D6F7573653A752E504F494E5445527D292C313D3D3D6F2E6C656E67746826267974287468697329293A21612626723F28746869732E73656C6563742869292C746869732E7570646174655549436C6173736573287B6D6F7573';
wwv_flow_imp.g_varchar2_table(459) := '653A752E4D4F56457D29293A617C7C727C7C286F2E666F7245616368282866756E6374696F6E2874297B72657475726E206E2E646F52656E6465722874297D29292C746869732E73657453656C65637465642869292C746869732E757064617465554943';
wwv_flow_imp.g_varchar2_table(460) := '6C6173736573287B6D6F7573653A752E4D4F56457D29292C746869732E646F52656E6465722869297D2C52742E6F6E4D6F757365446F776E3D66756E6374696F6E28742C65297B72657475726E206F742865293F746869732E73746172744F6E41637469';
wwv_flow_imp.g_varchar2_table(461) := '76654665617475726528742C65293A746869732E64726177436F6E6669672E626F7853656C656374262666756E6374696F6E2874297B72657475726E2121742E6F726967696E616C4576656E742626282121742E6F726967696E616C4576656E742E7368';
wwv_flow_imp.g_varchar2_table(462) := '6966744B65792626303D3D3D742E6F726967696E616C4576656E742E627574746F6E297D2865293F746869732E7374617274426F7853656C65637428742C65293A766F696420307D2C52742E7374617274426F7853656C6563743D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(463) := '742C65297B746869732E73746F70457874656E646564496E746572616374696F6E732874292C746869732E6D61702E6472616750616E2E64697361626C6528292C742E626F7853656C65637453746172744C6F636174696F6E3D647428652E6F72696769';
wwv_flow_imp.g_varchar2_table(464) := '6E616C4576656E742C746869732E6D61702E676574436F6E7461696E65722829292C742E63616E426F7853656C6563743D21307D2C52742E6F6E546F75636853746172743D66756E6374696F6E28742C65297B6966286F742865292972657475726E2074';
wwv_flow_imp.g_varchar2_table(465) := '6869732E73746172744F6E4163746976654665617475726528742C65297D2C52742E6F6E447261673D66756E6374696F6E28742C65297B72657475726E20742E63616E447261674D6F76653F746869732E647261674D6F766528742C65293A746869732E';
wwv_flow_imp.g_varchar2_table(466) := '64726177436F6E6669672E626F7853656C6563742626742E63616E426F7853656C6563743F746869732E7768696C65426F7853656C65637428742C65293A766F696420307D2C52742E7768696C65426F7853656C6563743D66756E6374696F6E28742C65';
wwv_flow_imp.g_varchar2_table(467) := '297B742E626F7853656C656374696E673D21302C746869732E7570646174655549436C6173736573287B6D6F7573653A752E4144447D292C742E626F7853656C656374456C656D656E747C7C28742E626F7853656C656374456C656D656E743D646F6375';
wwv_flow_imp.g_varchar2_table(468) := '6D656E742E637265617465456C656D656E74282264697622292C742E626F7853656C656374456C656D656E742E636C6173734C6973742E61646428612E424F585F53454C454354292C746869732E6D61702E676574436F6E7461696E657228292E617070';
wwv_flow_imp.g_varchar2_table(469) := '656E644368696C6428742E626F7853656C656374456C656D656E7429293B766172206E3D647428652E6F726967696E616C4576656E742C746869732E6D61702E676574436F6E7461696E65722829292C723D4D6174682E6D696E28742E626F7853656C65';
wwv_flow_imp.g_varchar2_table(470) := '637453746172744C6F636174696F6E2E782C6E2E78292C6F3D4D6174682E6D617828742E626F7853656C65637453746172744C6F636174696F6E2E782C6E2E78292C693D4D6174682E6D696E28742E626F7853656C65637453746172744C6F636174696F';
wwv_flow_imp.g_varchar2_table(471) := '6E2E792C6E2E79292C733D4D6174682E6D617828742E626F7853656C65637453746172744C6F636174696F6E2E792C6E2E79292C633D227472616E736C61746528222B722B2270782C20222B692B22707829223B742E626F7853656C656374456C656D65';
wwv_flow_imp.g_varchar2_table(472) := '6E742E7374796C652E7472616E73666F726D3D632C742E626F7853656C656374456C656D656E742E7374796C652E5765626B69745472616E73666F726D3D632C742E626F7853656C656374456C656D656E742E7374796C652E77696474683D6F2D722B22';
wwv_flow_imp.g_varchar2_table(473) := '7078222C742E626F7853656C656374456C656D656E742E7374796C652E6865696768743D732D692B227078227D2C52742E647261674D6F76653D66756E6374696F6E28742C65297B742E647261674D6F76696E673D21302C652E6F726967696E616C4576';
wwv_flow_imp.g_varchar2_table(474) := '656E742E73746F7050726F7061676174696F6E28293B766172206E3D7B6C6E673A652E6C6E674C61742E6C6E672D742E647261674D6F76654C6F636174696F6E2E6C6E672C6C61743A652E6C6E674C61742E6C61742D742E647261674D6F76654C6F6361';
wwv_flow_imp.g_varchar2_table(475) := '74696F6E2E6C61747D3B6B7428746869732E67657453656C656374656428292C6E292C742E647261674D6F76654C6F636174696F6E3D652E6C6E674C61747D2C52742E6F6E4D6F75736555703D66756E6374696F6E28742C65297B766172206E3D746869';
wwv_flow_imp.g_varchar2_table(476) := '733B696628742E647261674D6F76696E6729746869732E6669726555706461746528293B656C736520696628742E626F7853656C656374696E67297B76617220723D5B742E626F7853656C65637453746172744C6F636174696F6E2C647428652E6F7269';
wwv_flow_imp.g_varchar2_table(477) := '67696E616C4576656E742C746869732E6D61702E676574436F6E7461696E65722829295D2C6F3D746869732E66656174757265734174286E756C6C2C722C22636C69636B22292C693D746869732E676574556E69717565496473286F292E66696C746572';
wwv_flow_imp.g_varchar2_table(478) := '282866756E6374696F6E2874297B72657475726E216E2E697353656C65637465642874297D29293B692E6C656E677468262628746869732E73656C6563742869292C692E666F7245616368282866756E6374696F6E2874297B72657475726E206E2E646F';
wwv_flow_imp.g_varchar2_table(479) := '52656E6465722874297D29292C746869732E7570646174655549436C6173736573287B6D6F7573653A752E4D4F56457D29297D746869732E73746F70457874656E646564496E746572616374696F6E732874297D2C52742E746F446973706C6179466561';
wwv_flow_imp.g_varchar2_table(480) := '74757265733D66756E6374696F6E28742C652C6E297B652E70726F706572746965732E6163746976653D746869732E697353656C656374656428652E70726F706572746965732E6964293F792E4143544956453A792E494E4143544956452C6E2865292C';
wwv_flow_imp.g_varchar2_table(481) := '746869732E66697265416374696F6E61626C6528292C652E70726F706572746965732E6163746976653D3D3D792E4143544956452626652E67656F6D657472792E74797065213D3D6C2E504F494E54262667742865292E666F7245616368286E297D2C52';
wwv_flow_imp.g_varchar2_table(482) := '742E6F6E54726173683D66756E6374696F6E28297B746869732E64656C6574654665617475726528746869732E67657453656C65637465644964732829292C746869732E66697265416374696F6E61626C6528297D2C52742E6F6E436F6D62696E654665';
wwv_flow_imp.g_varchar2_table(483) := '6174757265733D66756E6374696F6E28297B76617220743D746869732E67657453656C656374656428293B6966282128303D3D3D742E6C656E6774687C7C742E6C656E6774683C3229297B666F722876617220653D5B5D2C6E3D5B5D2C723D745B305D2E';
wwv_flow_imp.g_varchar2_table(484) := '747970652E7265706C61636528224D756C7469222C2222292C6F3D303B6F3C742E6C656E6774683B6F2B2B297B76617220693D745B6F5D3B696628692E747970652E7265706C61636528224D756C7469222C222229213D3D722972657475726E3B692E74';
wwv_flow_imp.g_varchar2_table(485) := '7970652E696E636C7564657328224D756C746922293F692E676574436F6F7264696E6174657328292E666F7245616368282866756E6374696F6E2874297B652E707573682874297D29293A652E7075736828692E676574436F6F7264696E617465732829';
wwv_flow_imp.g_varchar2_table(486) := '292C6E2E7075736828692E746F47656F4A534F4E2829297D6966286E2E6C656E6774683E31297B76617220613D746869732E6E657746656174757265287B747970653A6C2E464541545552452C70726F706572746965733A6E5B305D2E70726F70657274';
wwv_flow_imp.g_varchar2_table(487) := '6965732C67656F6D657472793A7B747970653A224D756C7469222B722C636F6F7264696E617465733A657D7D293B746869732E616464466561747572652861292C746869732E64656C6574654665617475726528746869732E67657453656C6563746564';
wwv_flow_imp.g_varchar2_table(488) := '49647328292C7B73696C656E743A21307D292C746869732E73657453656C6563746564285B612E69645D292C746869732E6D61702E6669726528702E434F4D42494E455F46454154555245532C7B6372656174656446656174757265733A5B612E746F47';
wwv_flow_imp.g_varchar2_table(489) := '656F4A534F4E28295D2C64656C6574656446656174757265733A6E7D297D746869732E66697265416374696F6E61626C6528297D7D2C52742E6F6E556E636F6D62696E6546656174757265733D66756E6374696F6E28297B76617220743D746869732C65';
wwv_flow_imp.g_varchar2_table(490) := '3D746869732E67657453656C656374656428293B69662830213D3D652E6C656E677468297B666F7228766172206E3D5B5D2C723D5B5D2C6F3D66756E6374696F6E286F297B76617220693D655B6F5D3B742E6973496E7374616E63654F6628224D756C74';
wwv_flow_imp.g_varchar2_table(491) := '6946656174757265222C6929262628692E676574466561747572657328292E666F7245616368282866756E6374696F6E2865297B742E616464466561747572652865292C652E70726F706572746965733D692E70726F706572746965732C6E2E70757368';
wwv_flow_imp.g_varchar2_table(492) := '28652E746F47656F4A534F4E2829292C742E73656C656374285B652E69645D297D29292C742E64656C6574654665617475726528692E69642C7B73696C656E743A21307D292C722E7075736828692E746F47656F4A534F4E282929297D2C693D303B693C';
wwv_flow_imp.g_varchar2_table(493) := '652E6C656E6774683B692B2B296F2869293B6E2E6C656E6774683E312626746869732E6D61702E6669726528702E554E434F4D42494E455F46454154555245532C7B6372656174656446656174757265733A6E2C64656C6574656446656174757265733A';
wwv_flow_imp.g_varchar2_table(494) := '727D292C746869732E66697265416374696F6E61626C6528297D7D3B7661722055743D727428672E564552544558292C6A743D727428672E4D4944504F494E54292C44743D7B666972655570646174653A66756E6374696F6E28297B746869732E6D6170';
wwv_flow_imp.g_varchar2_table(495) := '2E6669726528702E5550444154452C7B616374696F6E3A662C66656174757265733A746869732E67657453656C656374656428292E6D6170282866756E6374696F6E2874297B72657475726E20742E746F47656F4A534F4E28297D29297D297D2C666972';
wwv_flow_imp.g_varchar2_table(496) := '65416374696F6E61626C653A66756E6374696F6E2874297B746869732E736574416374696F6E61626C655374617465287B636F6D62696E6546656174757265733A21312C756E636F6D62696E6546656174757265733A21312C74726173683A742E73656C';
wwv_flow_imp.g_varchar2_table(497) := '6563746564436F6F726450617468732E6C656E6774683E307D297D2C73746172744472616767696E673A66756E6374696F6E28742C65297B746869732E6D61702E6472616750616E2E64697361626C6528292C742E63616E447261674D6F76653D21302C';
wwv_flow_imp.g_varchar2_table(498) := '742E647261674D6F76654C6F636174696F6E3D652E6C6E674C61747D2C73746F704472616767696E673A66756E6374696F6E2874297B746869732E6D61702E6472616750616E2E656E61626C6528292C742E647261674D6F76696E673D21312C742E6361';
wwv_flow_imp.g_varchar2_table(499) := '6E447261674D6F76653D21312C742E647261674D6F76654C6F636174696F6E3D6E756C6C7D2C6F6E5665727465783A66756E6374696F6E28742C65297B746869732E73746172744472616767696E6728742C65293B766172206E3D652E66656174757265';
wwv_flow_imp.g_varchar2_table(500) := '5461726765742E70726F706572746965732C723D742E73656C6563746564436F6F726450617468732E696E6465784F66286E2E636F6F72645F70617468293B75742865297C7C2D31213D3D723F757428652926262D313D3D3D722626742E73656C656374';
wwv_flow_imp.g_varchar2_table(501) := '6564436F6F726450617468732E70757368286E2E636F6F72645F70617468293A742E73656C6563746564436F6F726450617468733D5B6E2E636F6F72645F706174685D3B766172206F3D746869732E7061746873546F436F6F7264696E6174657328742E';
wwv_flow_imp.g_varchar2_table(502) := '6665617475726549642C742E73656C6563746564436F6F72645061746873293B746869732E73657453656C6563746564436F6F7264696E61746573286F297D2C6F6E4D6964706F696E743A66756E6374696F6E28742C65297B746869732E737461727444';
wwv_flow_imp.g_varchar2_table(503) := '72616767696E6728742C65293B766172206E3D652E666561747572655461726765742E70726F706572746965733B742E666561747572652E616464436F6F7264696E617465286E2E636F6F72645F706174682C6E2E6C6E672C6E2E6C6174292C74686973';
wwv_flow_imp.g_varchar2_table(504) := '2E6669726555706461746528292C742E73656C6563746564436F6F726450617468733D5B6E2E636F6F72645F706174685D7D2C7061746873546F436F6F7264696E617465733A66756E6374696F6E28742C65297B72657475726E20652E6D617028286675';
wwv_flow_imp.g_varchar2_table(505) := '6E6374696F6E2865297B72657475726E7B666561747572655F69643A742C636F6F72645F706174683A657D7D29297D2C6F6E466561747572653A66756E6374696F6E28742C65297B303D3D3D742E73656C6563746564436F6F726450617468732E6C656E';
wwv_flow_imp.g_varchar2_table(506) := '6774683F746869732E73746172744472616767696E6728742C65293A746869732E73746F704472616767696E672874297D2C64726167466561747572653A66756E6374696F6E28742C652C6E297B6B7428746869732E67657453656C656374656428292C';
wwv_flow_imp.g_varchar2_table(507) := '6E292C742E647261674D6F76654C6F636174696F6E3D652E6C6E674C61747D2C647261675665727465783A66756E6374696F6E28742C652C6E297B666F722876617220723D742E73656C6563746564436F6F726450617468732E6D6170282866756E6374';
wwv_flow_imp.g_varchar2_table(508) := '696F6E2865297B72657475726E20742E666561747572652E676574436F6F7264696E6174652865297D29292C6F3D467428722E6D6170282866756E6374696F6E2874297B72657475726E7B747970653A6C2E464541545552452C70726F70657274696573';
wwv_flow_imp.g_varchar2_table(509) := '3A7B7D2C67656F6D657472793A7B747970653A6C2E504F494E542C636F6F7264696E617465733A747D7D7D29292C6E292C693D303B693C722E6C656E6774683B692B2B297B76617220613D725B695D3B742E666561747572652E757064617465436F6F72';
wwv_flow_imp.g_varchar2_table(510) := '64696E61746528742E73656C6563746564436F6F726450617468735B695D2C615B305D2B6F2E6C6E672C615B315D2B6F2E6C6174297D7D2C636C69636B4E6F5461726765743A66756E6374696F6E28297B746869732E6368616E67654D6F646528682E53';
wwv_flow_imp.g_varchar2_table(511) := '494D504C455F53454C454354297D2C636C69636B496E6163746976653A66756E6374696F6E28297B746869732E6368616E67654D6F646528682E53494D504C455F53454C454354297D2C636C69636B416374697665466561747572653A66756E6374696F';
wwv_flow_imp.g_varchar2_table(512) := '6E2874297B742E73656C6563746564436F6F726450617468733D5B5D2C746869732E636C65617253656C6563746564436F6F7264696E6174657328292C742E666561747572652E6368616E67656428297D2C6F6E53657475703A66756E6374696F6E2874';
wwv_flow_imp.g_varchar2_table(513) := '297B76617220653D742E6665617475726549642C6E3D746869732E676574466561747572652865293B696628216E297468726F77206E6577204572726F722822596F75206D7573742070726F7669646520612066656174757265496420746F20656E7465';
wwv_flow_imp.g_varchar2_table(514) := '72206469726563745F73656C656374206D6F646522293B6966286E2E747970653D3D3D6C2E504F494E54297468726F77206E657720547970654572726F7228226469726563745F73656C656374206D6F646520646F65736E27742068616E646C6520706F';
wwv_flow_imp.g_varchar2_table(515) := '696E7420666561747572657322293B76617220723D7B6665617475726549643A652C666561747572653A6E2C647261674D6F76654C6F636174696F6E3A742E7374617274506F737C7C6E756C6C2C647261674D6F76696E673A21312C63616E447261674D';
wwv_flow_imp.g_varchar2_table(516) := '6F76653A21312C73656C6563746564436F6F726450617468733A742E636F6F7264506174683F5B742E636F6F7264506174685D3A5B5D7D3B72657475726E20746869732E73657453656C6563746564436F6F7264696E6174657328746869732E70617468';
wwv_flow_imp.g_varchar2_table(517) := '73546F436F6F7264696E6174657328652C722E73656C6563746564436F6F7264506174687329292C746869732E73657453656C65637465642865292C6D742874686973292C746869732E736574416374696F6E61626C655374617465287B74726173683A';
wwv_flow_imp.g_varchar2_table(518) := '21307D292C727D2C6F6E53746F703A66756E6374696F6E28297B79742874686973292C746869732E636C65617253656C6563746564436F6F7264696E6174657328297D2C746F446973706C617946656174757265733A66756E6374696F6E28742C652C6E';
wwv_flow_imp.g_varchar2_table(519) := '297B742E6665617475726549643D3D3D652E70726F706572746965732E69643F28652E70726F706572746965732E6163746976653D792E4143544956452C6E2865292C677428652C7B6D61703A746869732E6D61702C6D6964706F696E74733A21302C73';
wwv_flow_imp.g_varchar2_table(520) := '656C656374656450617468733A742E73656C6563746564436F6F726450617468737D292E666F7245616368286E29293A28652E70726F706572746965732E6163746976653D792E494E4143544956452C6E286529292C746869732E66697265416374696F';
wwv_flow_imp.g_varchar2_table(521) := '6E61626C652874297D2C6F6E54726173683A66756E6374696F6E2874297B742E73656C6563746564436F6F726450617468732E736F7274282866756E6374696F6E28742C65297B72657475726E20652E6C6F63616C65436F6D7061726528742C22656E22';
wwv_flow_imp.g_varchar2_table(522) := '2C7B6E756D657269633A21307D297D29292E666F7245616368282866756E6374696F6E2865297B72657475726E20742E666561747572652E72656D6F7665436F6F7264696E6174652865297D29292C746869732E6669726555706461746528292C742E73';
wwv_flow_imp.g_varchar2_table(523) := '656C6563746564436F6F726450617468733D5B5D2C746869732E636C65617253656C6563746564436F6F7264696E6174657328292C746869732E66697265416374696F6E61626C652874292C21313D3D3D742E666561747572652E697356616C69642829';
wwv_flow_imp.g_varchar2_table(524) := '262628746869732E64656C65746546656174757265285B742E6665617475726549645D292C746869732E6368616E67654D6F646528682E53494D504C455F53454C4543542C7B7D29297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28742C6529';
wwv_flow_imp.g_varchar2_table(525) := '7B766172206E3D6F742865292C723D55742865292C6F3D303D3D3D742E73656C6563746564436F6F726450617468732E6C656E6774683B72657475726E206E26266F3F746869732E7570646174655549436C6173736573287B6D6F7573653A752E4D4F56';
wwv_flow_imp.g_varchar2_table(526) := '457D293A722626216F3F746869732E7570646174655549436C6173736573287B6D6F7573653A752E4D4F56457D293A746869732E7570646174655549436C6173736573287B6D6F7573653A752E4E4F4E457D292C746869732E73746F704472616767696E';
wwv_flow_imp.g_varchar2_table(527) := '672874292C21307D2C6F6E4D6F7573654F75743A66756E6374696F6E2874297B72657475726E20742E647261674D6F76696E672626746869732E6669726555706461746528292C21307D7D3B44742E6F6E546F75636853746172743D44742E6F6E4D6F75';
wwv_flow_imp.g_varchar2_table(528) := '7365446F776E3D66756E6374696F6E28742C65297B72657475726E2055742865293F746869732E6F6E56657274657828742C65293A6F742865293F746869732E6F6E4665617475726528742C65293A6A742865293F746869732E6F6E4D6964706F696E74';
wwv_flow_imp.g_varchar2_table(529) := '28742C65293A766F696420307D2C44742E6F6E447261673D66756E6374696F6E28742C65297B69662821303D3D3D742E63616E447261674D6F7665297B742E647261674D6F76696E673D21302C652E6F726967696E616C4576656E742E73746F7050726F';
wwv_flow_imp.g_varchar2_table(530) := '7061676174696F6E28293B766172206E3D7B6C6E673A652E6C6E674C61742E6C6E672D742E647261674D6F76654C6F636174696F6E2E6C6E672C6C61743A652E6C6E674C61742E6C61742D742E647261674D6F76654C6F636174696F6E2E6C61747D3B74';
wwv_flow_imp.g_varchar2_table(531) := '2E73656C6563746564436F6F726450617468732E6C656E6774683E303F746869732E6472616756657274657828742C652C6E293A746869732E647261674665617475726528742C652C6E292C742E647261674D6F76654C6F636174696F6E3D652E6C6E67';
wwv_flow_imp.g_varchar2_table(532) := '4C61747D7D2C44742E6F6E436C69636B3D66756E6374696F6E28742C65297B72657475726E2061742865293F746869732E636C69636B4E6F54617267657428742C65293A6F742865293F746869732E636C69636B4163746976654665617475726528742C';
wwv_flow_imp.g_varchar2_table(533) := '65293A69742865293F746869732E636C69636B496E61637469766528742C65293A766F696420746869732E73746F704472616767696E672874297D2C44742E6F6E5461703D66756E6374696F6E28742C65297B72657475726E2061742865293F74686973';
wwv_flow_imp.g_varchar2_table(534) := '2E636C69636B4E6F54617267657428742C65293A6F742865293F746869732E636C69636B4163746976654665617475726528742C65293A69742865293F746869732E636C69636B496E61637469766528742C65293A766F696420307D2C44742E6F6E546F';
wwv_flow_imp.g_varchar2_table(535) := '756368456E643D44742E6F6E4D6F75736555703D66756E6374696F6E2874297B742E647261674D6F76696E672626746869732E6669726555706461746528292C746869732E73746F704472616767696E672874297D3B7661722056743D7B7D3B66756E63';
wwv_flow_imp.g_varchar2_table(536) := '74696F6E20427428742C65297B72657475726E2121742E6C6E674C6174262628742E6C6E674C61742E6C6E673D3D3D655B305D2626742E6C6E674C61742E6C61743D3D3D655B315D297D56742E6F6E53657475703D66756E6374696F6E28297B76617220';
wwv_flow_imp.g_varchar2_table(537) := '743D746869732E6E657746656174757265287B747970653A6C2E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A6C2E504F494E542C636F6F7264696E617465733A5B5D7D7D293B72657475726E2074686973';
wwv_flow_imp.g_varchar2_table(538) := '2E616464466561747572652874292C746869732E636C65617253656C6563746564466561747572657328292C746869732E7570646174655549436C6173736573287B6D6F7573653A752E4144447D292C746869732E61637469766174655549427574746F';
wwv_flow_imp.g_varchar2_table(539) := '6E28632E504F494E54292C746869732E736574416374696F6E61626C655374617465287B74726173683A21307D292C7B706F696E743A747D7D2C56742E73746F7044726177696E67416E6452656D6F76653D66756E6374696F6E2874297B746869732E64';
wwv_flow_imp.g_varchar2_table(540) := '656C65746546656174757265285B742E706F696E742E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528682E53494D504C455F53454C454354297D2C56742E6F6E5461703D56742E6F6E436C69636B3D66756E6374696F';
wwv_flow_imp.g_varchar2_table(541) := '6E28742C65297B746869732E7570646174655549436C6173736573287B6D6F7573653A752E4D4F56457D292C742E706F696E742E757064617465436F6F7264696E6174652822222C652E6C6E674C61742E6C6E672C652E6C6E674C61742E6C6174292C74';
wwv_flow_imp.g_varchar2_table(542) := '6869732E6D61702E6669726528702E4352454154452C7B66656174757265733A5B742E706F696E742E746F47656F4A534F4E28295D7D292C746869732E6368616E67654D6F646528682E53494D504C455F53454C4543542C7B666561747572654964733A';
wwv_flow_imp.g_varchar2_table(543) := '5B742E706F696E742E69645D7D297D2C56742E6F6E53746F703D66756E6374696F6E2874297B746869732E61637469766174655549427574746F6E28292C742E706F696E742E676574436F6F7264696E61746528292E6C656E6774687C7C746869732E64';
wwv_flow_imp.g_varchar2_table(544) := '656C65746546656174757265285B742E706F696E742E69645D2C7B73696C656E743A21307D297D2C56742E746F446973706C617946656174757265733D66756E6374696F6E28742C652C6E297B76617220723D652E70726F706572746965732E69643D3D';
wwv_flow_imp.g_varchar2_table(545) := '3D742E706F696E742E69643B696628652E70726F706572746965732E6163746976653D723F792E4143544956453A792E494E4143544956452C21722972657475726E206E2865297D2C56742E6F6E54726173683D56742E73746F7044726177696E67416E';
wwv_flow_imp.g_varchar2_table(546) := '6452656D6F76652C56742E6F6E4B657955703D66756E6374696F6E28742C65297B69662863742865297C7C6C742865292972657475726E20746869732E73746F7044726177696E67416E6452656D6F766528742C65297D3B7661722047743D7B6F6E5365';
wwv_flow_imp.g_varchar2_table(547) := '7475703A66756E6374696F6E28297B76617220743D746869732E6E657746656174757265287B747970653A6C2E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A6C2E504F4C59474F4E2C636F6F7264696E61';
wwv_flow_imp.g_varchar2_table(548) := '7465733A5B5B5D5D7D7D293B72657475726E20746869732E616464466561747572652874292C746869732E636C65617253656C6563746564466561747572657328292C6D742874686973292C746869732E7570646174655549436C6173736573287B6D6F';
wwv_flow_imp.g_varchar2_table(549) := '7573653A752E4144447D292C746869732E61637469766174655549427574746F6E28632E504F4C59474F4E292C746869732E736574416374696F6E61626C655374617465287B74726173683A21307D292C7B706F6C79676F6E3A742C63757272656E7456';
wwv_flow_imp.g_varchar2_table(550) := '6572746578506F736974696F6E3A307D7D2C636C69636B416E7977686572653A66756E6374696F6E28742C65297B696628742E63757272656E74566572746578506F736974696F6E3E302626427428652C742E706F6C79676F6E2E636F6F7264696E6174';
wwv_flow_imp.g_varchar2_table(551) := '65735B305D5B742E63757272656E74566572746578506F736974696F6E2D315D292972657475726E20746869732E6368616E67654D6F646528682E53494D504C455F53454C4543542C7B666561747572654964733A5B742E706F6C79676F6E2E69645D7D';
wwv_flow_imp.g_varchar2_table(552) := '293B746869732E7570646174655549436C6173736573287B6D6F7573653A752E4144447D292C742E706F6C79676F6E2E757064617465436F6F7264696E6174652822302E222B742E63757272656E74566572746578506F736974696F6E2C652E6C6E674C';
wwv_flow_imp.g_varchar2_table(553) := '61742E6C6E672C652E6C6E674C61742E6C6174292C742E63757272656E74566572746578506F736974696F6E2B2B2C742E706F6C79676F6E2E757064617465436F6F7264696E6174652822302E222B742E63757272656E74566572746578506F73697469';
wwv_flow_imp.g_varchar2_table(554) := '6F6E2C652E6C6E674C61742E6C6E672C652E6C6E674C61742E6C6174297D2C636C69636B4F6E5665727465783A66756E6374696F6E2874297B72657475726E20746869732E6368616E67654D6F646528682E53494D504C455F53454C4543542C7B666561';
wwv_flow_imp.g_varchar2_table(555) := '747572654964733A5B742E706F6C79676F6E2E69645D7D297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28742C65297B742E706F6C79676F6E2E757064617465436F6F7264696E6174652822302E222B742E63757272656E7456657274657850';
wwv_flow_imp.g_varchar2_table(556) := '6F736974696F6E2C652E6C6E674C61742E6C6E672C652E6C6E674C61742E6C6174292C73742865292626746869732E7570646174655549436C6173736573287B6D6F7573653A752E504F494E5445527D297D7D3B47742E6F6E5461703D47742E6F6E436C';
wwv_flow_imp.g_varchar2_table(557) := '69636B3D66756E6374696F6E28742C65297B72657475726E2073742865293F746869732E636C69636B4F6E56657274657828742C65293A746869732E636C69636B416E79776865726528742C65297D2C47742E6F6E4B657955703D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(558) := '742C65297B63742865293F28746869732E64656C65746546656174757265285B742E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528682E53494D504C455F53454C45435429293A6C742865292626';
wwv_flow_imp.g_varchar2_table(559) := '746869732E6368616E67654D6F646528682E53494D504C455F53454C4543542C7B666561747572654964733A5B742E706F6C79676F6E2E69645D7D297D2C47742E6F6E53746F703D66756E6374696F6E2874297B746869732E7570646174655549436C61';
wwv_flow_imp.g_varchar2_table(560) := '73736573287B6D6F7573653A752E4E4F4E457D292C79742874686973292C746869732E61637469766174655549427574746F6E28292C766F69642030213D3D746869732E6765744665617475726528742E706F6C79676F6E2E696429262628742E706F6C';
wwv_flow_imp.g_varchar2_table(561) := '79676F6E2E72656D6F7665436F6F7264696E6174652822302E222B742E63757272656E74566572746578506F736974696F6E292C742E706F6C79676F6E2E697356616C696428293F746869732E6D61702E6669726528702E4352454154452C7B66656174';
wwv_flow_imp.g_varchar2_table(562) := '757265733A5B742E706F6C79676F6E2E746F47656F4A534F4E28295D7D293A28746869732E64656C65746546656174757265285B742E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528682E53494D';
wwv_flow_imp.g_varchar2_table(563) := '504C455F53454C4543542C7B7D2C7B73696C656E743A21307D2929297D2C47742E746F446973706C617946656174757265733D66756E6374696F6E28742C652C6E297B76617220723D652E70726F706572746965732E69643D3D3D742E706F6C79676F6E';
wwv_flow_imp.g_varchar2_table(564) := '2E69643B696628652E70726F706572746965732E6163746976653D723F792E4143544956453A792E494E4143544956452C21722972657475726E206E2865293B69662830213D3D652E67656F6D657472792E636F6F7264696E617465732E6C656E677468';
wwv_flow_imp.g_varchar2_table(565) := '297B766172206F3D652E67656F6D657472792E636F6F7264696E617465735B305D2E6C656E6774683B69662821286F3C3329297B696628652E70726F706572746965732E6D6574613D672E464541545552452C6E28667428742E706F6C79676F6E2E6964';
wwv_flow_imp.g_varchar2_table(566) := '2C652E67656F6D657472792E636F6F7264696E617465735B305D5B305D2C22302E30222C213129292C6F3E33297B76617220693D652E67656F6D657472792E636F6F7264696E617465735B305D2E6C656E6774682D333B6E28667428742E706F6C79676F';
wwv_flow_imp.g_varchar2_table(567) := '6E2E69642C652E67656F6D657472792E636F6F7264696E617465735B305D5B695D2C22302E222B692C213129297D6966286F3C3D34297B76617220613D5B5B652E67656F6D657472792E636F6F7264696E617465735B305D5B305D5B305D2C652E67656F';
wwv_flow_imp.g_varchar2_table(568) := '6D657472792E636F6F7264696E617465735B305D5B305D5B315D5D2C5B652E67656F6D657472792E636F6F7264696E617465735B305D5B315D5B305D2C652E67656F6D657472792E636F6F7264696E617465735B305D5B315D5B315D5D5D3B6966286E28';
wwv_flow_imp.g_varchar2_table(569) := '7B747970653A6C2E464541545552452C70726F706572746965733A652E70726F706572746965732C67656F6D657472793A7B636F6F7264696E617465733A612C747970653A6C2E4C494E455F535452494E477D7D292C333D3D3D6F2972657475726E7D72';
wwv_flow_imp.g_varchar2_table(570) := '657475726E206E2865297D7D7D2C47742E6F6E54726173683D66756E6374696F6E2874297B746869732E64656C65746546656174757265285B742E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528';
wwv_flow_imp.g_varchar2_table(571) := '682E53494D504C455F53454C454354297D3B7661722024743D7B6F6E53657475703A66756E6374696F6E2874297B76617220652C6E2C723D28743D747C7C7B7D292E6665617475726549642C6F3D22666F7277617264223B69662872297B696628212865';
wwv_flow_imp.g_varchar2_table(572) := '3D746869732E6765744665617475726528722929297468726F77206E6577204572726F722822436F756C64206E6F742066696E64206120666561747572652077697468207468652070726F76696465642066656174757265496422293B76617220693D74';
wwv_flow_imp.g_varchar2_table(573) := '2E66726F6D3B6966286926262246656174757265223D3D3D692E747970652626692E67656F6D65747279262622506F696E74223D3D3D692E67656F6D657472792E74797065262628693D692E67656F6D65747279292C69262622506F696E74223D3D3D69';
wwv_flow_imp.g_varchar2_table(574) := '2E747970652626692E636F6F7264696E617465732626323D3D3D692E636F6F7264696E617465732E6C656E677468262628693D692E636F6F7264696E61746573292C21697C7C2141727261792E69734172726179286929297468726F77206E6577204572';
wwv_flow_imp.g_varchar2_table(575) := '726F722822506C656173652075736520746865206066726F6D602070726F706572747920746F20696E64696361746520776869636820706F696E7420746F20636F6E74696E756520746865206C696E652066726F6D22293B76617220613D652E636F6F72';
wwv_flow_imp.g_varchar2_table(576) := '64696E617465732E6C656E6774682D313B696628652E636F6F7264696E617465735B615D5B305D3D3D3D695B305D2626652E636F6F7264696E617465735B615D5B315D3D3D3D695B315D296E3D612B312C652E616464436F6F7264696E6174652E617070';
wwv_flow_imp.g_varchar2_table(577) := '6C7928652C5B6E5D2E636F6E63617428652E636F6F7264696E617465735B615D29293B656C73657B696628652E636F6F7264696E617465735B305D5B305D213D3D695B305D7C7C652E636F6F7264696E617465735B305D5B315D213D3D695B315D297468';
wwv_flow_imp.g_varchar2_table(578) := '726F77206E6577204572726F7228226066726F6D602073686F756C64206D617463682074686520706F696E742061742065697468657220746865207374617274206F722074686520656E64206F66207468652070726F7669646564204C696E6553747269';
wwv_flow_imp.g_varchar2_table(579) := '6E6722293B6F3D226261636B7761726473222C6E3D302C652E616464436F6F7264696E6174652E6170706C7928652C5B6E5D2E636F6E63617428652E636F6F7264696E617465735B305D29297D7D656C736520653D746869732E6E657746656174757265';
wwv_flow_imp.g_varchar2_table(580) := '287B747970653A6C2E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A6C2E4C494E455F535452494E472C636F6F7264696E617465733A5B5D7D7D292C6E3D302C746869732E61646446656174757265286529';
wwv_flow_imp.g_varchar2_table(581) := '3B72657475726E20746869732E636C65617253656C6563746564466561747572657328292C6D742874686973292C746869732E7570646174655549436C6173736573287B6D6F7573653A752E4144447D292C746869732E61637469766174655549427574';
wwv_flow_imp.g_varchar2_table(582) := '746F6E28632E4C494E45292C746869732E736574416374696F6E61626C655374617465287B74726173683A21307D292C7B6C696E653A652C63757272656E74566572746578506F736974696F6E3A6E2C646972656374696F6E3A6F7D7D2C636C69636B41';
wwv_flow_imp.g_varchar2_table(583) := '6E7977686572653A66756E6374696F6E28742C65297B696628742E63757272656E74566572746578506F736974696F6E3E302626427428652C742E6C696E652E636F6F7264696E617465735B742E63757272656E74566572746578506F736974696F6E2D';
wwv_flow_imp.g_varchar2_table(584) := '315D297C7C226261636B7761726473223D3D3D742E646972656374696F6E2626427428652C742E6C696E652E636F6F7264696E617465735B742E63757272656E74566572746578506F736974696F6E2B315D292972657475726E20746869732E6368616E';
wwv_flow_imp.g_varchar2_table(585) := '67654D6F646528682E53494D504C455F53454C4543542C7B666561747572654964733A5B742E6C696E652E69645D7D293B746869732E7570646174655549436C6173736573287B6D6F7573653A752E4144447D292C742E6C696E652E757064617465436F';
wwv_flow_imp.g_varchar2_table(586) := '6F7264696E61746528742E63757272656E74566572746578506F736974696F6E2C652E6C6E674C61742E6C6E672C652E6C6E674C61742E6C6174292C22666F7277617264223D3D3D742E646972656374696F6E3F28742E63757272656E74566572746578';
wwv_flow_imp.g_varchar2_table(587) := '506F736974696F6E2B2B2C742E6C696E652E757064617465436F6F7264696E61746528742E63757272656E74566572746578506F736974696F6E2C652E6C6E674C61742E6C6E672C652E6C6E674C61742E6C617429293A742E6C696E652E616464436F6F';
wwv_flow_imp.g_varchar2_table(588) := '7264696E61746528302C652E6C6E674C61742E6C6E672C652E6C6E674C61742E6C6174297D2C636C69636B4F6E5665727465783A66756E6374696F6E2874297B72657475726E20746869732E6368616E67654D6F646528682E53494D504C455F53454C45';
wwv_flow_imp.g_varchar2_table(589) := '43542C7B666561747572654964733A5B742E6C696E652E69645D7D297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28742C65297B742E6C696E652E757064617465436F6F7264696E61746528742E63757272656E74566572746578506F736974';
wwv_flow_imp.g_varchar2_table(590) := '696F6E2C652E6C6E674C61742E6C6E672C652E6C6E674C61742E6C6174292C73742865292626746869732E7570646174655549436C6173736573287B6D6F7573653A752E504F494E5445527D297D7D3B24742E6F6E5461703D24742E6F6E436C69636B3D';
wwv_flow_imp.g_varchar2_table(591) := '66756E6374696F6E28742C65297B69662873742865292972657475726E20746869732E636C69636B4F6E56657274657828742C65293B746869732E636C69636B416E79776865726528742C65297D2C24742E6F6E4B657955703D66756E6374696F6E2874';
wwv_flow_imp.g_varchar2_table(592) := '2C65297B6C742865293F746869732E6368616E67654D6F646528682E53494D504C455F53454C4543542C7B666561747572654964733A5B742E6C696E652E69645D7D293A6374286529262628746869732E64656C65746546656174757265285B742E6C69';
wwv_flow_imp.g_varchar2_table(593) := '6E652E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528682E53494D504C455F53454C45435429297D2C24742E6F6E53746F703D66756E6374696F6E2874297B79742874686973292C746869732E616374697661746555';
wwv_flow_imp.g_varchar2_table(594) := '49427574746F6E28292C766F69642030213D3D746869732E6765744665617475726528742E6C696E652E696429262628742E6C696E652E72656D6F7665436F6F7264696E6174652822222B742E63757272656E74566572746578506F736974696F6E292C';
wwv_flow_imp.g_varchar2_table(595) := '742E6C696E652E697356616C696428293F746869732E6D61702E6669726528702E4352454154452C7B66656174757265733A5B742E6C696E652E746F47656F4A534F4E28295D7D293A28746869732E64656C65746546656174757265285B742E6C696E65';
wwv_flow_imp.g_varchar2_table(596) := '2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528682E53494D504C455F53454C4543542C7B7D2C7B73696C656E743A21307D2929297D2C24742E6F6E54726173683D66756E6374696F6E2874297B746869732E64656C';
wwv_flow_imp.g_varchar2_table(597) := '65746546656174757265285B742E6C696E652E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528682E53494D504C455F53454C454354297D2C24742E746F446973706C617946656174757265733D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(598) := '742C652C6E297B76617220723D652E70726F706572746965732E69643D3D3D742E6C696E652E69643B696628652E70726F706572746965732E6163746976653D723F792E4143544956453A792E494E4143544956452C21722972657475726E206E286529';
wwv_flow_imp.g_varchar2_table(599) := '3B652E67656F6D657472792E636F6F7264696E617465732E6C656E6774683C327C7C28652E70726F706572746965732E6D6574613D672E464541545552452C6E28667428742E6C696E652E69642C652E67656F6D657472792E636F6F7264696E61746573';
wwv_flow_imp.g_varchar2_table(600) := '5B22666F7277617264223D3D3D742E646972656374696F6E3F652E67656F6D657472792E636F6F7264696E617465732E6C656E6774682D323A315D2C22222B2822666F7277617264223D3D3D742E646972656374696F6E3F652E67656F6D657472792E63';
wwv_flow_imp.g_varchar2_table(601) := '6F6F7264696E617465732E6C656E6774682D323A31292C213129292C6E286529297D3B766172204A743D7B73696D706C655F73656C6563743A52742C6469726563745F73656C6563743A44742C647261775F706F696E743A56742C647261775F706F6C79';
wwv_flow_imp.g_varchar2_table(602) := '676F6E3A47742C647261775F6C696E655F737472696E673A24747D2C7A743D7B64656661756C744D6F64653A682E53494D504C455F53454C4543542C6B657962696E64696E67733A21302C746F756368456E61626C65643A21302C636C69636B42756666';
wwv_flow_imp.g_varchar2_table(603) := '65723A322C746F7563684275666665723A32352C626F7853656C6563743A21302C646973706C6179436F6E74726F6C7344656661756C743A21302C7374796C65733A5B7B69643A22676C2D647261772D706F6C79676F6E2D66696C6C2D696E6163746976';
wwv_flow_imp.g_varchar2_table(604) := '65222C747970653A2266696C6C222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D2C5B22213D222C226D6F6465222C22737461746963225D';
wwv_flow_imp.g_varchar2_table(605) := '5D2C7061696E743A7B2266696C6C2D636F6C6F72223A2223336262326430222C2266696C6C2D6F75746C696E652D636F6C6F72223A2223336262326430222C2266696C6C2D6F706163697479223A2E317D7D2C7B69643A22676C2D647261772D706F6C79';
wwv_flow_imp.g_varchar2_table(606) := '676F6E2D66696C6C2D616374697665222C747970653A2266696C6C222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2274727565225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C7061696E743A7B22';
wwv_flow_imp.g_varchar2_table(607) := '66696C6C2D636F6C6F72223A2223666262303362222C2266696C6C2D6F75746C696E652D636F6C6F72223A2223666262303362222C2266696C6C2D6F706163697479223A2E317D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D6D6964706F69';
wwv_flow_imp.g_varchar2_table(608) := '6E74222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C226D6964706F696E74225D5D2C7061696E743A7B22636972636C652D72616469';
wwv_flow_imp.g_varchar2_table(609) := '7573223A332C22636972636C652D636F6C6F72223A2223666262303362227D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D7374726F6B652D696E616374697665222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D';
wwv_flow_imp.g_varchar2_table(610) := '3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C69';
wwv_flow_imp.g_varchar2_table(611) := '6E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223336262326430222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D7374726F6B652D61637469766522';
wwv_flow_imp.g_varchar2_table(612) := '2C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2274727565225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E';
wwv_flow_imp.g_varchar2_table(613) := '64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223666262303362222C226C696E652D646173686172726179223A5B2E322C325D2C226C696E652D7769647468223A327D7D2C7B69643A22';
wwv_flow_imp.g_varchar2_table(614) := '676C2D647261772D6C696E652D696E616374697665222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C224C696E65537472696E67225D';
wwv_flow_imp.g_varchar2_table(615) := '2C5B22213D222C226D6F6465222C22737461746963225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A22233362623264';
wwv_flow_imp.g_varchar2_table(616) := '30222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D6C696E652D616374697665222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C224C696E65537472696E67225D2C';
wwv_flow_imp.g_varchar2_table(617) := '5B223D3D222C22616374697665222C2274727565225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223666262303362';
wwv_flow_imp.g_varchar2_table(618) := '222C226C696E652D646173686172726179223A5B2E322C325D2C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D616E642D6C696E652D7665727465782D7374726F6B652D696E616374697665222C747970';
wwv_flow_imp.g_varchar2_table(619) := '653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D657461222C22766572746578225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C7061696E74';
wwv_flow_imp.g_varchar2_table(620) := '3A7B22636972636C652D726164697573223A352C22636972636C652D636F6C6F72223A2223666666227D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D616E642D6C696E652D7665727465782D696E616374697665222C747970653A22636972';
wwv_flow_imp.g_varchar2_table(621) := '636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D657461222C22766572746578225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C7061696E743A7B22636972';
wwv_flow_imp.g_varchar2_table(622) := '636C652D726164697573223A332C22636972636C652D636F6C6F72223A2223666262303362227D7D2C7B69643A22676C2D647261772D706F696E742D706F696E742D7374726F6B652D696E616374697665222C747970653A22636972636C65222C66696C';
wwv_flow_imp.g_varchar2_table(623) := '7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C2266656174757265225D2C5B22213D222C226D6F6465222C2273746174';
wwv_flow_imp.g_varchar2_table(624) := '6963225D5D2C7061696E743A7B22636972636C652D726164697573223A352C22636972636C652D6F706163697479223A312C22636972636C652D636F6C6F72223A2223666666227D7D2C7B69643A22676C2D647261772D706F696E742D696E6163746976';
wwv_flow_imp.g_varchar2_table(625) := '65222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C226665617475726522';
wwv_flow_imp.g_varchar2_table(626) := '5D2C5B22213D222C226D6F6465222C22737461746963225D5D2C7061696E743A7B22636972636C652D726164697573223A332C22636972636C652D636F6C6F72223A2223336262326430227D7D2C7B69643A22676C2D647261772D706F696E742D737472';
wwv_flow_imp.g_varchar2_table(627) := '6F6B652D616374697665222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C22616374697665222C2274727565225D2C5B22213D222C226D657461222C22';
wwv_flow_imp.g_varchar2_table(628) := '6D6964706F696E74225D5D2C7061696E743A7B22636972636C652D726164697573223A372C22636972636C652D636F6C6F72223A2223666666227D7D2C7B69643A22676C2D647261772D706F696E742D616374697665222C747970653A22636972636C65';
wwv_flow_imp.g_varchar2_table(629) := '222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B22213D222C226D657461222C226D6964706F696E74225D2C5B223D3D222C22616374697665222C2274727565225D5D2C7061696E743A7B2263697263';
wwv_flow_imp.g_varchar2_table(630) := '6C652D726164697573223A352C22636972636C652D636F6C6F72223A2223666262303362227D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D66696C6C2D737461746963222C747970653A2266696C6C222C66696C7465723A5B22616C6C222C';
wwv_flow_imp.g_varchar2_table(631) := '5B223D3D222C226D6F6465222C22737461746963225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C7061696E743A7B2266696C6C2D636F6C6F72223A2223343034303430222C2266696C6C2D6F75746C696E652D636F6C6F72223A';
wwv_flow_imp.g_varchar2_table(632) := '2223343034303430222C2266696C6C2D6F706163697479223A2E317D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D7374726F6B652D737461746963222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C226D';
wwv_flow_imp.g_varchar2_table(633) := '6F6465222C22737461746963225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E';
wwv_flow_imp.g_varchar2_table(634) := '652D636F6C6F72223A2223343034303430222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D6C696E652D737461746963222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F646522';
wwv_flow_imp.g_varchar2_table(635) := '2C22737461746963225D2C5B223D3D222C222474797065222C224C696E65537472696E67225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E65';
wwv_flow_imp.g_varchar2_table(636) := '2D636F6C6F72223A2223343034303430222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D706F696E742D737461746963222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F64';
wwv_flow_imp.g_varchar2_table(637) := '65222C22737461746963225D2C5B223D3D222C222474797065222C22506F696E74225D5D2C7061696E743A7B22636972636C652D726164697573223A352C22636972636C652D636F6C6F72223A2223343034303430227D7D5D2C6D6F6465733A4A742C63';
wwv_flow_imp.g_varchar2_table(638) := '6F6E74726F6C733A7B7D2C7573657250726F706572746965733A21317D2C59743D7B706F696E743A21302C6C696E655F737472696E673A21302C706F6C79676F6E3A21302C74726173683A21302C636F6D62696E655F66656174757265733A21302C756E';
wwv_flow_imp.g_varchar2_table(639) := '636F6D62696E655F66656174757265733A21307D2C71743D7B706F696E743A21312C6C696E655F737472696E673A21312C706F6C79676F6E3A21312C74726173683A21312C636F6D62696E655F66656174757265733A21312C756E636F6D62696E655F66';
wwv_flow_imp.g_varchar2_table(640) := '656174757265733A21317D3B66756E6374696F6E20577428742C65297B72657475726E20742E6D6170282866756E6374696F6E2874297B72657475726E20742E736F757263653F743A5128742C7B69643A742E69642B222E222B652C736F757263653A22';
wwv_flow_imp.g_varchar2_table(641) := '686F74223D3D3D653F732E484F543A732E434F4C447D297D29297D7661722048743D52282866756E6374696F6E28742C65297B766172206E3D3230302C723D225F5F6C6F646173685F686173685F756E646566696E65645F5F222C6F3D312C693D322C61';
wwv_flow_imp.g_varchar2_table(642) := '3D393030373139393235343734303939312C733D225B6F626A65637420417267756D656E74735D222C753D225B6F626A6563742041727261795D222C633D225B6F626A656374204173796E6346756E6374696F6E5D222C6C3D225B6F626A65637420426F';
wwv_flow_imp.g_varchar2_table(643) := '6F6C65616E5D222C683D225B6F626A65637420446174655D222C703D225B6F626A656374204572726F725D222C643D225B6F626A6563742046756E6374696F6E5D222C663D225B6F626A6563742047656E657261746F7246756E6374696F6E5D222C673D';
wwv_flow_imp.g_varchar2_table(644) := '225B6F626A656374204D61705D222C793D225B6F626A656374204E756D6265725D222C6D3D225B6F626A656374204E756C6C5D222C763D225B6F626A656374204F626A6563745D222C5F3D225B6F626A6563742050726F78795D222C623D225B6F626A65';
wwv_flow_imp.g_varchar2_table(645) := '6374205265674578705D222C453D225B6F626A656374205365745D222C533D225B6F626A65637420537472696E675D222C543D225B6F626A6563742053796D626F6C5D222C433D225B6F626A65637420556E646566696E65645D222C4F3D225B6F626A65';
wwv_flow_imp.g_varchar2_table(646) := '63742041727261794275666665725D222C493D225B6F626A6563742044617461566965775D222C783D2F5E5C5B6F626A656374202E2B3F436F6E7374727563746F725C5D242F2C4C3D2F5E283F3A307C5B312D395D5C642A29242F2C4D3D7B7D3B4D5B22';
wwv_flow_imp.g_varchar2_table(647) := '5B6F626A65637420466C6F6174333241727261795D225D3D4D5B225B6F626A65637420466C6F6174363441727261795D225D3D4D5B225B6F626A65637420496E743841727261795D225D3D4D5B225B6F626A65637420496E74313641727261795D225D3D';
wwv_flow_imp.g_varchar2_table(648) := '4D5B225B6F626A65637420496E74333241727261795D225D3D4D5B225B6F626A6563742055696E743841727261795D225D3D4D5B225B6F626A6563742055696E7438436C616D70656441727261795D225D3D4D5B225B6F626A6563742055696E74313641';
wwv_flow_imp.g_varchar2_table(649) := '727261795D225D3D4D5B225B6F626A6563742055696E74333241727261795D225D3D21302C4D5B735D3D4D5B755D3D4D5B4F5D3D4D5B6C5D3D4D5B495D3D4D5B685D3D4D5B705D3D4D5B645D3D4D5B675D3D4D5B795D3D4D5B765D3D4D5B625D3D4D5B45';
wwv_flow_imp.g_varchar2_table(650) := '5D3D4D5B535D3D4D5B225B6F626A656374205765616B4D61705D225D3D21313B766172204E3D226F626A656374223D3D747970656F6620676C6F62616C2626676C6F62616C2626676C6F62616C2E4F626A6563743D3D3D4F626A6563742626676C6F6261';
wwv_flow_imp.g_varchar2_table(651) := '6C2C503D226F626A656374223D3D747970656F662073656C66262673656C66262673656C662E4F626A6563743D3D3D4F626A656374262673656C662C773D4E7C7C507C7C46756E6374696F6E282272657475726E2074686973222928292C413D65262621';
wwv_flow_imp.g_varchar2_table(652) := '652E6E6F6465547970652626652C463D41262674262621742E6E6F6465547970652626742C6B3D462626462E6578706F7274733D3D3D412C523D6B26264E2E70726F636573732C553D66756E6374696F6E28297B7472797B72657475726E20522626522E';
wwv_flow_imp.g_varchar2_table(653) := '62696E64696E672626522E62696E64696E6728227574696C22297D63617463682874297B7D7D28292C6A3D552626552E6973547970656441727261793B66756E6374696F6E204428742C65297B666F7228766172206E3D2D312C723D6E756C6C3D3D743F';
wwv_flow_imp.g_varchar2_table(654) := '303A742E6C656E6774683B2B2B6E3C723B296966286528745B6E5D2C6E2C74292972657475726E21303B72657475726E21317D66756E6374696F6E20562874297B76617220653D2D312C6E3D417272617928742E73697A65293B72657475726E20742E66';
wwv_flow_imp.g_varchar2_table(655) := '6F7245616368282866756E6374696F6E28742C72297B6E5B2B2B655D3D5B722C745D7D29292C6E7D66756E6374696F6E20422874297B76617220653D2D312C6E3D417272617928742E73697A65293B72657475726E20742E666F7245616368282866756E';
wwv_flow_imp.g_varchar2_table(656) := '6374696F6E2874297B6E5B2B2B655D3D747D29292C6E7D76617220472C242C4A2C7A3D41727261792E70726F746F747970652C593D46756E6374696F6E2E70726F746F747970652C713D4F626A6563742E70726F746F747970652C573D775B225F5F636F';
wwv_flow_imp.g_varchar2_table(657) := '72652D6A735F7368617265645F5F225D2C483D592E746F537472696E672C583D712E6861734F776E50726F70657274792C5A3D28473D2F5B5E2E5D2B242F2E6578656328572626572E6B6579732626572E6B6579732E49455F50524F544F7C7C22222929';
wwv_flow_imp.g_varchar2_table(658) := '3F2253796D626F6C28737263295F312E222B473A22222C4B3D712E746F537472696E672C513D52656745787028225E222B482E63616C6C2858292E7265706C616365282F5B5C5C5E242E2A2B3F28295B5C5D7B7D7C5D2F672C225C5C242622292E726570';
wwv_flow_imp.g_varchar2_table(659) := '6C616365282F6861734F776E50726F70657274797C2866756E6374696F6E292E2A3F283F3D5C5C5C28297C20666F72202E2B3F283F3D5C5C5C5D292F672C2224312E2A3F22292B222422292C74743D6B3F772E4275666665723A766F696420302C65743D';
wwv_flow_imp.g_varchar2_table(660) := '772E53796D626F6C2C6E743D772E55696E743841727261792C72743D712E70726F70657274794973456E756D657261626C652C6F743D7A2E73706C6963652C69743D65743F65742E746F537472696E675461673A766F696420302C61743D4F626A656374';
wwv_flow_imp.g_varchar2_table(661) := '2E6765744F776E50726F706572747953796D626F6C732C73743D74743F74742E69734275666665723A766F696420302C75743D28243D4F626A6563742E6B6579732C4A3D4F626A6563742C66756E6374696F6E2874297B72657475726E2024284A287429';
wwv_flow_imp.g_varchar2_table(662) := '297D292C63743D557428772C22446174615669657722292C6C743D557428772C224D617022292C68743D557428772C2250726F6D69736522292C70743D557428772C2253657422292C64743D557428772C225765616B4D617022292C66743D5574284F62';
wwv_flow_imp.g_varchar2_table(663) := '6A6563742C2263726561746522292C67743D4274286374292C79743D4274286C74292C6D743D4274286874292C76743D4274287074292C5F743D4274286474292C62743D65743F65742E70726F746F747970653A766F696420302C45743D62743F62742E';
wwv_flow_imp.g_varchar2_table(664) := '76616C75654F663A766F696420303B66756E6374696F6E2053742874297B76617220653D2D312C6E3D6E756C6C3D3D743F303A742E6C656E6774683B666F7228746869732E636C65617228293B2B2B653C6E3B297B76617220723D745B655D3B74686973';
wwv_flow_imp.g_varchar2_table(665) := '2E73657428725B305D2C725B315D297D7D66756E6374696F6E2054742874297B76617220653D2D312C6E3D6E756C6C3D3D743F303A742E6C656E6774683B666F7228746869732E636C65617228293B2B2B653C6E3B297B76617220723D745B655D3B7468';
wwv_flow_imp.g_varchar2_table(666) := '69732E73657428725B305D2C725B315D297D7D66756E6374696F6E2043742874297B76617220653D2D312C6E3D6E756C6C3D3D743F303A742E6C656E6774683B666F7228746869732E636C65617228293B2B2B653C6E3B297B76617220723D745B655D3B';
wwv_flow_imp.g_varchar2_table(667) := '746869732E73657428725B305D2C725B315D297D7D66756E6374696F6E204F742874297B76617220653D2D312C6E3D6E756C6C3D3D743F303A742E6C656E6774683B666F7228746869732E5F5F646174615F5F3D6E65772043743B2B2B653C6E3B297468';
wwv_flow_imp.g_varchar2_table(668) := '69732E61646428745B655D297D66756E6374696F6E2049742874297B76617220653D746869732E5F5F646174615F5F3D6E65772054742874293B746869732E73697A653D652E73697A657D66756E6374696F6E20787428742C65297B766172206E3D4A74';
wwv_flow_imp.g_varchar2_table(669) := '2874292C723D216E262624742874292C6F3D216E2626217226267A742874292C693D216E262621722626216F262658742874292C613D6E7C7C727C7C6F7C7C692C733D613F66756E6374696F6E28742C65297B666F7228766172206E3D2D312C723D4172';
wwv_flow_imp.g_varchar2_table(670) := '7261792874293B2B2B6E3C743B29725B6E5D3D65286E293B72657475726E20727D28742E6C656E6774682C537472696E67293A5B5D2C753D732E6C656E6774683B666F7228766172206320696E2074292165262621582E63616C6C28742C63297C7C6126';
wwv_flow_imp.g_varchar2_table(671) := '2628226C656E677468223D3D637C7C6F262628226F6666736574223D3D637C7C22706172656E74223D3D63297C7C6926262822627566666572223D3D637C7C22627974654C656E677468223D3D637C7C22627974654F6666736574223D3D63297C7C5674';
wwv_flow_imp.g_varchar2_table(672) := '28632C7529297C7C732E707573682863293B72657475726E20737D66756E6374696F6E204C7428742C65297B666F7228766172206E3D742E6C656E6774683B6E2D2D3B29696628477428745B6E5D5B305D2C65292972657475726E206E3B72657475726E';
wwv_flow_imp.g_varchar2_table(673) := '2D317D66756E6374696F6E204D742874297B72657475726E206E756C6C3D3D743F766F696420303D3D3D743F433A6D3A69742626697420696E204F626A6563742874293F66756E6374696F6E2874297B76617220653D582E63616C6C28742C6974292C6E';
wwv_flow_imp.g_varchar2_table(674) := '3D745B69745D3B7472797B745B69745D3D766F696420303B76617220723D21307D63617463682874297B7D766172206F3D4B2E63616C6C2874293B72262628653F745B69745D3D6E3A64656C65746520745B69745D293B72657475726E206F7D2874293A';
wwv_flow_imp.g_varchar2_table(675) := '66756E6374696F6E2874297B72657475726E204B2E63616C6C2874297D2874297D66756E6374696F6E204E742874297B72657475726E20487428742926264D742874293D3D737D66756E6374696F6E20507428742C652C6E2C722C61297B72657475726E';
wwv_flow_imp.g_varchar2_table(676) := '20743D3D3D657C7C286E756C6C3D3D747C7C6E756C6C3D3D657C7C21487428742926262148742865293F74213D74262665213D653A66756E6374696F6E28742C652C6E2C722C612C63297B76617220643D4A742874292C663D4A742865292C6D3D643F75';
wwv_flow_imp.g_varchar2_table(677) := '3A44742874292C5F3D663F753A44742865292C433D286D3D6D3D3D733F763A6D293D3D762C783D285F3D5F3D3D733F763A5F293D3D762C4C3D6D3D3D5F3B6966284C26267A74287429297B696628217A742865292972657475726E21313B643D21302C43';
wwv_flow_imp.g_varchar2_table(678) := '3D21317D6966284C262621432972657475726E20637C7C28633D6E6577204974292C647C7C58742874293F467428742C652C6E2C722C612C63293A66756E6374696F6E28742C652C6E2C722C612C732C75297B737769746368286E297B6361736520493A';
wwv_flow_imp.g_varchar2_table(679) := '696628742E627974654C656E677468213D652E627974654C656E6774687C7C742E627974654F6666736574213D652E627974654F66667365742972657475726E21313B743D742E6275666665722C653D652E6275666665723B63617365204F3A72657475';
wwv_flow_imp.g_varchar2_table(680) := '726E2128742E627974654C656E677468213D652E627974654C656E6774687C7C2173286E6577206E742874292C6E6577206E7428652929293B63617365206C3A6361736520683A6361736520793A72657475726E204774282B742C2B65293B6361736520';
wwv_flow_imp.g_varchar2_table(681) := '703A72657475726E20742E6E616D653D3D652E6E616D652626742E6D6573736167653D3D652E6D6573736167653B6361736520623A6361736520533A72657475726E20743D3D652B22223B6361736520673A76617220633D563B6361736520453A766172';
wwv_flow_imp.g_varchar2_table(682) := '20643D72266F3B696628637C7C28633D42292C742E73697A65213D652E73697A65262621642972657475726E21313B76617220663D752E6765742874293B696628662972657475726E20663D3D653B727C3D692C752E73657428742C65293B766172206D';
wwv_flow_imp.g_varchar2_table(683) := '3D467428632874292C632865292C722C612C732C75293B72657475726E20752E64656C6574652874292C6D3B6361736520543A69662845742972657475726E2045742E63616C6C2874293D3D45742E63616C6C2865297D72657475726E21317D28742C65';
wwv_flow_imp.g_varchar2_table(684) := '2C6D2C6E2C722C612C63293B69662821286E266F29297B766172204D3D432626582E63616C6C28742C225F5F777261707065645F5F22292C4E3D782626582E63616C6C28652C225F5F777261707065645F5F22293B6966284D7C7C4E297B76617220503D';
wwv_flow_imp.g_varchar2_table(685) := '4D3F742E76616C756528293A742C773D4E3F652E76616C756528293A653B72657475726E20637C7C28633D6E6577204974292C6128502C772C6E2C722C63297D7D696628214C2972657475726E21313B72657475726E20637C7C28633D6E657720497429';
wwv_flow_imp.g_varchar2_table(686) := '2C66756E6374696F6E28742C652C6E2C722C692C61297B76617220733D6E266F2C753D6B742874292C633D752E6C656E6774682C6C3D6B742865292E6C656E6774683B69662863213D6C262621732972657475726E21313B76617220683D633B666F7228';
wwv_flow_imp.g_varchar2_table(687) := '3B682D2D3B297B76617220703D755B685D3B6966282128733F7020696E20653A582E63616C6C28652C7029292972657475726E21317D76617220643D612E6765742874293B696628642626612E6765742865292972657475726E20643D3D653B76617220';
wwv_flow_imp.g_varchar2_table(688) := '663D21303B612E73657428742C65292C612E73657428652C74293B76617220673D733B666F72283B2B2B683C633B297B703D755B685D3B76617220793D745B705D2C6D3D655B705D3B696628722976617220763D733F72286D2C792C702C652C742C6129';
wwv_flow_imp.g_varchar2_table(689) := '3A7228792C6D2C702C742C652C61293B6966282128766F696420303D3D3D763F793D3D3D6D7C7C6928792C6D2C6E2C722C61293A7629297B663D21313B627265616B7D677C7C28673D22636F6E7374727563746F72223D3D70297D696628662626216729';
wwv_flow_imp.g_varchar2_table(690) := '7B766172205F3D742E636F6E7374727563746F722C623D652E636F6E7374727563746F723B5F213D62262622636F6E7374727563746F7222696E2074262622636F6E7374727563746F7222696E2065262621282266756E6374696F6E223D3D747970656F';
wwv_flow_imp.g_varchar2_table(691) := '66205F26265F20696E7374616E63656F66205F26262266756E6374696F6E223D3D747970656F66206226266220696E7374616E63656F66206229262628663D2131297D72657475726E20612E64656C6574652874292C612E64656C6574652865292C667D';
wwv_flow_imp.g_varchar2_table(692) := '28742C652C6E2C722C612C63297D28742C652C6E2C722C50742C6129297D66756E6374696F6E2077742874297B72657475726E21282157742874297C7C66756E6374696F6E2874297B72657475726E21215A26265A20696E20747D287429292626285974';
wwv_flow_imp.g_varchar2_table(693) := '2874293F513A78292E74657374284274287429297D66756E6374696F6E2041742874297B6966286E3D28653D74292626652E636F6E7374727563746F722C723D2266756E6374696F6E223D3D747970656F66206E26266E2E70726F746F747970657C7C71';
wwv_flow_imp.g_varchar2_table(694) := '2C65213D3D722972657475726E2075742874293B76617220652C6E2C722C6F3D5B5D3B666F7228766172206920696E204F626A65637428742929582E63616C6C28742C6929262622636F6E7374727563746F7222213D6926266F2E707573682869293B72';
wwv_flow_imp.g_varchar2_table(695) := '657475726E206F7D66756E6374696F6E20467428742C652C6E2C722C612C73297B76617220753D6E266F2C633D742E6C656E6774682C6C3D652E6C656E6774683B69662863213D6C262621287526266C3E63292972657475726E21313B76617220683D73';
wwv_flow_imp.g_varchar2_table(696) := '2E6765742874293B696628682626732E6765742865292972657475726E20683D3D653B76617220703D2D312C643D21302C663D6E26693F6E6577204F743A766F696420303B666F7228732E73657428742C65292C732E73657428652C74293B2B2B703C63';
wwv_flow_imp.g_varchar2_table(697) := '3B297B76617220673D745B705D2C793D655B705D3B6966287229766172206D3D753F7228792C672C702C652C742C73293A7228672C792C702C742C652C73293B696628766F69642030213D3D6D297B6966286D29636F6E74696E75653B643D21313B6272';
wwv_flow_imp.g_varchar2_table(698) := '65616B7D69662866297B696628214428652C2866756E6374696F6E28742C65297B6966286F3D652C21662E686173286F29262628673D3D3D747C7C6128672C742C6E2C722C7329292972657475726E20662E707573682865293B766172206F7D2929297B';
wwv_flow_imp.g_varchar2_table(699) := '643D21313B627265616B7D7D656C73652069662867213D3D792626216128672C792C6E2C722C7329297B643D21313B627265616B7D7D72657475726E20732E64656C6574652874292C732E64656C6574652865292C647D66756E6374696F6E206B742874';
wwv_flow_imp.g_varchar2_table(700) := '297B72657475726E2066756E6374696F6E28742C652C6E297B76617220723D652874293B72657475726E204A742874293F723A66756E6374696F6E28742C65297B666F7228766172206E3D2D312C723D652E6C656E6774682C6F3D742E6C656E6774683B';
wwv_flow_imp.g_varchar2_table(701) := '2B2B6E3C723B29745B6F2B6E5D3D655B6E5D3B72657475726E20747D28722C6E287429297D28742C5A742C6A74297D66756E6374696F6E20527428742C65297B766172206E2C722C6F3D742E5F5F646174615F5F3B72657475726E2822737472696E6722';
wwv_flow_imp.g_varchar2_table(702) := '3D3D28723D747970656F66286E3D6529297C7C226E756D626572223D3D727C7C2273796D626F6C223D3D727C7C22626F6F6C65616E223D3D723F225F5F70726F746F5F5F22213D3D6E3A6E756C6C3D3D3D6E293F6F5B22737472696E67223D3D74797065';
wwv_flow_imp.g_varchar2_table(703) := '6F6620653F22737472696E67223A2268617368225D3A6F2E6D61707D66756E6374696F6E20557428742C65297B766172206E3D66756E6374696F6E28742C65297B72657475726E206E756C6C3D3D743F766F696420303A745B655D7D28742C65293B7265';
wwv_flow_imp.g_varchar2_table(704) := '7475726E207774286E293F6E3A766F696420307D53742E70726F746F747970652E636C6561723D66756E6374696F6E28297B746869732E5F5F646174615F5F3D66743F6674286E756C6C293A7B7D2C746869732E73697A653D307D2C53742E70726F746F';
wwv_flow_imp.g_varchar2_table(705) := '747970652E64656C6574653D66756E6374696F6E2874297B76617220653D746869732E686173287429262664656C65746520746869732E5F5F646174615F5F5B745D3B72657475726E20746869732E73697A652D3D653F313A302C657D2C53742E70726F';
wwv_flow_imp.g_varchar2_table(706) := '746F747970652E6765743D66756E6374696F6E2874297B76617220653D746869732E5F5F646174615F5F3B6966286674297B766172206E3D655B745D3B72657475726E206E3D3D3D723F766F696420303A6E7D72657475726E20582E63616C6C28652C74';
wwv_flow_imp.g_varchar2_table(707) := '293F655B745D3A766F696420307D2C53742E70726F746F747970652E6861733D66756E6374696F6E2874297B76617220653D746869732E5F5F646174615F5F3B72657475726E2066743F766F69642030213D3D655B745D3A582E63616C6C28652C74297D';
wwv_flow_imp.g_varchar2_table(708) := '2C53742E70726F746F747970652E7365743D66756E6374696F6E28742C65297B766172206E3D746869732E5F5F646174615F5F3B72657475726E20746869732E73697A652B3D746869732E6861732874293F303A312C6E5B745D3D66742626766F696420';
wwv_flow_imp.g_varchar2_table(709) := '303D3D3D653F723A652C746869737D2C54742E70726F746F747970652E636C6561723D66756E6374696F6E28297B746869732E5F5F646174615F5F3D5B5D2C746869732E73697A653D307D2C54742E70726F746F747970652E64656C6574653D66756E63';
wwv_flow_imp.g_varchar2_table(710) := '74696F6E2874297B76617220653D746869732E5F5F646174615F5F2C6E3D4C7428652C74293B72657475726E21286E3C30292626286E3D3D652E6C656E6774682D313F652E706F7028293A6F742E63616C6C28652C6E2C31292C2D2D746869732E73697A';
wwv_flow_imp.g_varchar2_table(711) := '652C2130297D2C54742E70726F746F747970652E6765743D66756E6374696F6E2874297B76617220653D746869732E5F5F646174615F5F2C6E3D4C7428652C74293B72657475726E206E3C303F766F696420303A655B6E5D5B315D7D2C54742E70726F74';
wwv_flow_imp.g_varchar2_table(712) := '6F747970652E6861733D66756E6374696F6E2874297B72657475726E204C7428746869732E5F5F646174615F5F2C74293E2D317D2C54742E70726F746F747970652E7365743D66756E6374696F6E28742C65297B766172206E3D746869732E5F5F646174';
wwv_flow_imp.g_varchar2_table(713) := '615F5F2C723D4C74286E2C74293B72657475726E20723C303F282B2B746869732E73697A652C6E2E70757368285B742C655D29293A6E5B725D5B315D3D652C746869737D2C43742E70726F746F747970652E636C6561723D66756E6374696F6E28297B74';
wwv_flow_imp.g_varchar2_table(714) := '6869732E73697A653D302C746869732E5F5F646174615F5F3D7B686173683A6E65772053742C6D61703A6E6577286C747C7C5474292C737472696E673A6E65772053747D7D2C43742E70726F746F747970652E64656C6574653D66756E6374696F6E2874';
wwv_flow_imp.g_varchar2_table(715) := '297B76617220653D527428746869732C74292E64656C6574652874293B72657475726E20746869732E73697A652D3D653F313A302C657D2C43742E70726F746F747970652E6765743D66756E6374696F6E2874297B72657475726E20527428746869732C';
wwv_flow_imp.g_varchar2_table(716) := '74292E6765742874297D2C43742E70726F746F747970652E6861733D66756E6374696F6E2874297B72657475726E20527428746869732C74292E6861732874297D2C43742E70726F746F747970652E7365743D66756E6374696F6E28742C65297B766172';
wwv_flow_imp.g_varchar2_table(717) := '206E3D527428746869732C74292C723D6E2E73697A653B72657475726E206E2E73657428742C65292C746869732E73697A652B3D6E2E73697A653D3D723F303A312C746869737D2C4F742E70726F746F747970652E6164643D4F742E70726F746F747970';
wwv_flow_imp.g_varchar2_table(718) := '652E707573683D66756E6374696F6E2874297B72657475726E20746869732E5F5F646174615F5F2E73657428742C72292C746869737D2C4F742E70726F746F747970652E6861733D66756E6374696F6E2874297B72657475726E20746869732E5F5F6461';
wwv_flow_imp.g_varchar2_table(719) := '74615F5F2E6861732874297D2C49742E70726F746F747970652E636C6561723D66756E6374696F6E28297B746869732E5F5F646174615F5F3D6E65772054742C746869732E73697A653D307D2C49742E70726F746F747970652E64656C6574653D66756E';
wwv_flow_imp.g_varchar2_table(720) := '6374696F6E2874297B76617220653D746869732E5F5F646174615F5F2C6E3D652E64656C6574652874293B72657475726E20746869732E73697A653D652E73697A652C6E7D2C49742E70726F746F747970652E6765743D66756E6374696F6E2874297B72';
wwv_flow_imp.g_varchar2_table(721) := '657475726E20746869732E5F5F646174615F5F2E6765742874297D2C49742E70726F746F747970652E6861733D66756E6374696F6E2874297B72657475726E20746869732E5F5F646174615F5F2E6861732874297D2C49742E70726F746F747970652E73';
wwv_flow_imp.g_varchar2_table(722) := '65743D66756E6374696F6E28742C65297B76617220723D746869732E5F5F646174615F5F3B6966287220696E7374616E63656F66205474297B766172206F3D722E5F5F646174615F5F3B696628216C747C7C6F2E6C656E6774683C6E2D31297265747572';
wwv_flow_imp.g_varchar2_table(723) := '6E206F2E70757368285B742C655D292C746869732E73697A653D2B2B722E73697A652C746869733B723D746869732E5F5F646174615F5F3D6E6577204374286F297D72657475726E20722E73657428742C65292C746869732E73697A653D722E73697A65';
wwv_flow_imp.g_varchar2_table(724) := '2C746869737D3B766172206A743D61743F66756E6374696F6E2874297B72657475726E206E756C6C3D3D743F5B5D3A28743D4F626A6563742874292C66756E6374696F6E28742C65297B666F7228766172206E3D2D312C723D6E756C6C3D3D743F303A74';
wwv_flow_imp.g_varchar2_table(725) := '2E6C656E6774682C6F3D302C693D5B5D3B2B2B6E3C723B297B76617220613D745B6E5D3B6528612C6E2C7429262628695B6F2B2B5D3D61297D72657475726E20697D2861742874292C2866756E6374696F6E2865297B72657475726E2072742E63616C6C';
wwv_flow_imp.g_varchar2_table(726) := '28742C65297D2929297D3A66756E6374696F6E28297B72657475726E5B5D7D2C44743D4D743B66756E6374696F6E20567428742C65297B72657475726E212128653D6E756C6C3D3D653F613A6529262628226E756D626572223D3D747970656F6620747C';
wwv_flow_imp.g_varchar2_table(727) := '7C4C2E74657374287429292626743E2D3126267425313D3D302626743C657D66756E6374696F6E2042742874297B6966286E756C6C213D74297B7472797B72657475726E20482E63616C6C2874297D63617463682874297B7D7472797B72657475726E20';
wwv_flow_imp.g_varchar2_table(728) := '742B22227D63617463682874297B7D7D72657475726E22227D66756E6374696F6E20477428742C65297B72657475726E20743D3D3D657C7C74213D74262665213D657D28637426264474286E6577206374286E6577204172726179427566666572283129';
wwv_flow_imp.g_varchar2_table(729) := '2929213D497C7C6C7426264474286E6577206C7429213D677C7C68742626225B6F626A6563742050726F6D6973655D22213D44742868742E7265736F6C76652829297C7C707426264474286E657720707429213D457C7C64742626225B6F626A65637420';
wwv_flow_imp.g_varchar2_table(730) := '5765616B4D61705D22213D4474286E6577206474292926262844743D66756E6374696F6E2874297B76617220653D4D742874292C6E3D653D3D763F742E636F6E7374727563746F723A766F696420302C723D6E3F4274286E293A22223B69662872297377';
wwv_flow_imp.g_varchar2_table(731) := '697463682872297B636173652067743A72657475726E20493B636173652079743A72657475726E20673B63617365206D743A72657475726E225B6F626A6563742050726F6D6973655D223B636173652076743A72657475726E20453B63617365205F743A';
wwv_flow_imp.g_varchar2_table(732) := '72657475726E225B6F626A656374205765616B4D61705D227D72657475726E20657D293B7661722024743D4E742866756E6374696F6E28297B72657475726E20617267756D656E74737D2829293F4E743A66756E6374696F6E2874297B72657475726E20';
wwv_flow_imp.g_varchar2_table(733) := '48742874292626582E63616C6C28742C2263616C6C6565222926262172742E63616C6C28742C2263616C6C656522297D2C4A743D41727261792E697341727261793B766172207A743D73747C7C66756E6374696F6E28297B72657475726E21317D3B6675';
wwv_flow_imp.g_varchar2_table(734) := '6E6374696F6E2059742874297B6966282157742874292972657475726E21313B76617220653D4D742874293B72657475726E20653D3D647C7C653D3D667C7C653D3D637C7C653D3D5F7D66756E6374696F6E2071742874297B72657475726E226E756D62';
wwv_flow_imp.g_varchar2_table(735) := '6572223D3D747970656F6620742626743E2D3126267425313D3D302626743C3D617D66756E6374696F6E2057742874297B76617220653D747970656F6620743B72657475726E206E756C6C213D74262628226F626A656374223D3D657C7C2266756E6374';
wwv_flow_imp.g_varchar2_table(736) := '696F6E223D3D65297D66756E6374696F6E2048742874297B72657475726E206E756C6C213D742626226F626A656374223D3D747970656F6620747D7661722058743D6A3F66756E6374696F6E2874297B72657475726E2066756E6374696F6E2865297B72';
wwv_flow_imp.g_varchar2_table(737) := '657475726E20742865297D7D286A293A66756E6374696F6E2874297B72657475726E2048742874292626717428742E6C656E67746829262621214D5B4D742874295D7D3B66756E6374696F6E205A742874297B72657475726E206E756C6C213D28653D74';
wwv_flow_imp.g_varchar2_table(738) := '292626717428652E6C656E6774682926262159742865293F78742874293A41742874293B76617220657D742E6578706F7274733D66756E6374696F6E28742C65297B72657475726E20507428742C65297D7D29293B7661722058743D7B7D3B66756E6374';
wwv_flow_imp.g_varchar2_table(739) := '696F6E205A7428742C65297B666F7228766172206E3D302C723D742E6C656E6774682D313B723E3D303B722D2D297B766172206F3D745B725D3B222E223D3D3D6F3F742E73706C69636528722C31293A222E2E223D3D3D6F3F28742E73706C6963652872';
wwv_flow_imp.g_varchar2_table(740) := '2C31292C6E2B2B293A6E262628742E73706C69636528722C31292C6E2D2D297D6966286529666F72283B6E2D2D3B6E29742E756E736869667428222E2E22293B72657475726E20747D766172204B743D2F5E285C2F3F7C29285B5C735C535D2A3F292828';
wwv_flow_imp.g_varchar2_table(741) := '3F3A5C2E7B312C327D7C5B5E5C2F5D2B3F7C29285C2E5B5E2E5C2F5D2A7C2929283F3A5B5C2F5D2A29242F2C51743D66756E6374696F6E2874297B72657475726E204B742E657865632874292E736C6963652831297D3B66756E6374696F6E2074652829';
wwv_flow_imp.g_varchar2_table(742) := '7B666F722876617220743D617267756D656E74732C653D22222C6E3D21312C723D617267756D656E74732E6C656E6774682D313B723E3D2D312626216E3B722D2D297B766172206F3D723E3D303F745B725D3A222F223B69662822737472696E6722213D';
wwv_flow_imp.g_varchar2_table(743) := '747970656F66206F297468726F77206E657720547970654572726F722822417267756D656E747320746F20706174682E7265736F6C7665206D75737420626520737472696E677322293B6F262628653D6F2B222F222B652C6E3D222F223D3D3D6F2E6368';
wwv_flow_imp.g_varchar2_table(744) := '61724174283029297D72657475726E286E3F222F223A2222292B28653D5A74286F6528652E73706C697428222F22292C2866756E6374696F6E2874297B72657475726E2121747D29292C216E292E6A6F696E28222F2229297C7C222E227D66756E637469';
wwv_flow_imp.g_varchar2_table(745) := '6F6E2065652874297B76617220653D6E652874292C6E3D222F223D3D3D696528742C2D31293B72657475726E28743D5A74286F6528742E73706C697428222F22292C2866756E6374696F6E2874297B72657475726E2121747D29292C2165292E6A6F696E';
wwv_flow_imp.g_varchar2_table(746) := '28222F2229297C7C657C7C28743D222E22292C7426266E262628742B3D222F22292C28653F222F223A2222292B747D66756E6374696F6E206E652874297B72657475726E222F223D3D3D742E6368617241742830297D7661722072653D7B6578746E616D';
wwv_flow_imp.g_varchar2_table(747) := '653A66756E6374696F6E2874297B72657475726E2051742874295B335D7D2C626173656E616D653A66756E6374696F6E28742C65297B766172206E3D51742874295B325D3B72657475726E206526266E2E737562737472282D312A652E6C656E67746829';
wwv_flow_imp.g_varchar2_table(748) := '3D3D3D652626286E3D6E2E73756273747228302C6E2E6C656E6774682D652E6C656E67746829292C6E7D2C6469726E616D653A66756E6374696F6E2874297B76617220653D51742874292C6E3D655B305D2C723D655B315D3B72657475726E206E7C7C72';
wwv_flow_imp.g_varchar2_table(749) := '3F2872262628723D722E73756273747228302C722E6C656E6774682D3129292C6E2B72293A222E227D2C7365703A222F222C64656C696D697465723A223A222C72656C61746976653A66756E6374696F6E28742C65297B66756E6374696F6E206E287429';
wwv_flow_imp.g_varchar2_table(750) := '7B666F722876617220653D303B653C742E6C656E677468262622223D3D3D745B655D3B652B2B293B666F7228766172206E3D742E6C656E6774682D313B6E3E3D30262622223D3D3D745B6E5D3B6E2D2D293B72657475726E20653E6E3F5B5D3A742E736C';
wwv_flow_imp.g_varchar2_table(751) := '69636528652C6E2D652B31297D743D74652874292E7375627374722831292C653D74652865292E7375627374722831293B666F722876617220723D6E28742E73706C697428222F2229292C6F3D6E28652E73706C697428222F2229292C693D4D6174682E';
wwv_flow_imp.g_varchar2_table(752) := '6D696E28722E6C656E6774682C6F2E6C656E677468292C613D692C733D303B733C693B732B2B29696628725B735D213D3D6F5B735D297B613D733B627265616B7D76617220753D5B5D3B666F7228733D613B733C722E6C656E6774683B732B2B29752E70';
wwv_flow_imp.g_varchar2_table(753) := '75736828222E2E22293B72657475726E28753D752E636F6E636174286F2E736C69636528612929292E6A6F696E28222F22297D2C6A6F696E3A66756E6374696F6E28297B72657475726E206565286F652841727261792E70726F746F747970652E736C69';
wwv_flow_imp.g_varchar2_table(754) := '63652E63616C6C28617267756D656E74732C30292C2866756E6374696F6E28742C65297B69662822737472696E6722213D747970656F662074297468726F77206E657720547970654572726F722822417267756D656E747320746F20706174682E6A6F69';
wwv_flow_imp.g_varchar2_table(755) := '6E206D75737420626520737472696E677322293B72657475726E20747D29292E6A6F696E28222F2229297D2C69734162736F6C7574653A6E652C6E6F726D616C697A653A65652C7265736F6C76653A74657D3B66756E6374696F6E206F6528742C65297B';
wwv_flow_imp.g_varchar2_table(756) := '696628742E66696C7465722972657475726E20742E66696C7465722865293B666F7228766172206E3D5B5D2C723D303B723C742E6C656E6774683B722B2B296528745B725D2C722C742926266E2E7075736828745B725D293B72657475726E206E7D7661';
wwv_flow_imp.g_varchar2_table(757) := '722069653D2262223D3D3D226162222E737562737472282D31293F66756E6374696F6E28742C652C6E297B72657475726E20742E73756273747228652C6E297D3A66756E6374696F6E28742C652C6E297B72657475726E20653C30262628653D742E6C65';
wwv_flow_imp.g_varchar2_table(758) := '6E6774682B65292C742E73756273747228652C6E297D2C61653D52282866756E6374696F6E28742C65297B766172206E3D66756E6374696F6E28297B76617220743D66756E6374696F6E28742C652C6E2C72297B666F72286E3D6E7C7C7B7D2C723D742E';
wwv_flow_imp.g_varchar2_table(759) := '6C656E6774683B722D2D3B6E5B745B725D5D3D65293B72657475726E206E7D2C653D5B312C31325D2C6E3D5B312C31335D2C723D5B312C395D2C6F3D5B312C31305D2C693D5B312C31315D2C613D5B312C31345D2C733D5B312C31355D2C753D5B31342C';
wwv_flow_imp.g_varchar2_table(760) := '31382C32322C32345D2C633D5B31382C32325D2C6C3D5B32322C32345D2C683D7B74726163653A66756E6374696F6E28297B7D2C79793A7B7D2C73796D626F6C735F3A7B6572726F723A322C4A534F4E537472696E673A332C535452494E473A342C4A53';
wwv_flow_imp.g_varchar2_table(761) := '4F4E4E756D6265723A352C4E554D4245523A362C4A534F4E4E756C6C4C69746572616C3A372C4E554C4C3A382C4A534F4E426F6F6C65616E4C69746572616C3A392C545255453A31302C46414C53453A31312C4A534F4E546578743A31322C4A534F4E56';
wwv_flow_imp.g_varchar2_table(762) := '616C75653A31332C454F463A31342C4A534F4E4F626A6563743A31352C4A534F4E41727261793A31362C227B223A31372C227D223A31382C4A534F4E4D656D6265724C6973743A31392C4A534F4E4D656D6265723A32302C223A223A32312C222C223A32';
wwv_flow_imp.g_varchar2_table(763) := '322C225B223A32332C225D223A32342C4A534F4E456C656D656E744C6973743A32352C246163636570743A302C24656E643A317D2C7465726D696E616C735F3A7B323A226572726F72222C343A22535452494E47222C363A224E554D424552222C383A22';
wwv_flow_imp.g_varchar2_table(764) := '4E554C4C222C31303A2254525545222C31313A2246414C5345222C31343A22454F46222C31373A227B222C31383A227D222C32313A223A222C32323A222C222C32333A225B222C32343A225D227D2C70726F64756374696F6E735F3A5B302C5B332C315D';
wwv_flow_imp.g_varchar2_table(765) := '2C5B352C315D2C5B372C315D2C5B392C315D2C5B392C315D2C5B31322C325D2C5B31332C315D2C5B31332C315D2C5B31332C315D2C5B31332C315D2C5B31332C315D2C5B31332C315D2C5B31352C325D2C5B31352C335D2C5B32302C335D2C5B31392C31';
wwv_flow_imp.g_varchar2_table(766) := '5D2C5B31392C335D2C5B31362C325D2C5B31362C335D2C5B32352C315D2C5B32352C335D5D2C706572666F726D416374696F6E3A66756E6374696F6E28742C652C6E2C722C6F2C692C61297B76617220733D692E6C656E6774682D313B73776974636828';
wwv_flow_imp.g_varchar2_table(767) := '6F297B6361736520313A746869732E243D742E7265706C616365282F5C5C285C5C7C22292F672C22243122292E7265706C616365282F5C5C6E2F672C225C6E22292E7265706C616365282F5C5C722F672C225C7222292E7265706C616365282F5C5C742F';
wwv_flow_imp.g_varchar2_table(768) := '672C225C7422292E7265706C616365282F5C5C762F672C225C7622292E7265706C616365282F5C5C662F672C225C6622292E7265706C616365282F5C5C622F672C225C6222293B627265616B3B6361736520323A746869732E243D4E756D626572287429';
wwv_flow_imp.g_varchar2_table(769) := '3B627265616B3B6361736520333A746869732E243D6E756C6C3B627265616B3B6361736520343A746869732E243D21303B627265616B3B6361736520353A746869732E243D21313B627265616B3B6361736520363A72657475726E20746869732E243D69';
wwv_flow_imp.g_varchar2_table(770) := '5B732D315D3B636173652031333A746869732E243D7B7D2C4F626A6563742E646566696E6550726F706572747928746869732E242C225F5F6C696E655F5F222C7B76616C75653A746869732E5F242E66697273745F6C696E652C656E756D657261626C65';
wwv_flow_imp.g_varchar2_table(771) := '3A21317D293B627265616B3B636173652031343A636173652031393A746869732E243D695B732D315D2C4F626A6563742E646566696E6550726F706572747928746869732E242C225F5F6C696E655F5F222C7B76616C75653A746869732E5F242E666972';
wwv_flow_imp.g_varchar2_table(772) := '73745F6C696E652C656E756D657261626C653A21317D293B627265616B3B636173652031353A746869732E243D5B695B732D325D2C695B735D5D3B627265616B3B636173652031363A746869732E243D7B7D2C746869732E245B695B735D5B305D5D3D69';
wwv_flow_imp.g_varchar2_table(773) := '5B735D5B315D3B627265616B3B636173652031373A746869732E243D695B732D325D2C766F69642030213D3D695B732D325D5B695B735D5B305D5D262628746869732E242E5F5F6475706C696361746550726F706572746965735F5F7C7C4F626A656374';
wwv_flow_imp.g_varchar2_table(774) := '2E646566696E6550726F706572747928746869732E242C225F5F6475706C696361746550726F706572746965735F5F222C7B76616C75653A5B5D2C656E756D657261626C653A21317D292C746869732E242E5F5F6475706C696361746550726F70657274';
wwv_flow_imp.g_varchar2_table(775) := '6965735F5F2E7075736828695B735D5B305D29292C695B732D325D5B695B735D5B305D5D3D695B735D5B315D3B627265616B3B636173652031383A746869732E243D5B5D2C4F626A6563742E646566696E6550726F706572747928746869732E242C225F';
wwv_flow_imp.g_varchar2_table(776) := '5F6C696E655F5F222C7B76616C75653A746869732E5F242E66697273745F6C696E652C656E756D657261626C653A21317D293B627265616B3B636173652032303A746869732E243D5B695B735D5D3B627265616B3B636173652032313A746869732E243D';
wwv_flow_imp.g_varchar2_table(777) := '695B732D325D2C695B732D325D2E7075736828695B735D297D7D2C7461626C653A5B7B333A352C343A652C353A362C363A6E2C373A332C383A722C393A342C31303A6F2C31313A692C31323A312C31333A322C31353A372C31363A382C31373A612C3233';
wwv_flow_imp.g_varchar2_table(778) := '3A737D2C7B313A5B335D7D2C7B31343A5B312C31365D7D2C7428752C5B322C375D292C7428752C5B322C385D292C7428752C5B322C395D292C7428752C5B322C31305D292C7428752C5B322C31315D292C7428752C5B322C31325D292C7428752C5B322C';
wwv_flow_imp.g_varchar2_table(779) := '335D292C7428752C5B322C345D292C7428752C5B322C355D292C74285B31342C31382C32312C32322C32345D2C5B322C315D292C7428752C5B322C325D292C7B333A32302C343A652C31383A5B312C31375D2C31393A31382C32303A31397D2C7B333A35';
wwv_flow_imp.g_varchar2_table(780) := '2C343A652C353A362C363A6E2C373A332C383A722C393A342C31303A6F2C31313A692C31333A32332C31353A372C31363A382C31373A612C32333A732C32343A5B312C32315D2C32353A32327D2C7B313A5B322C365D7D2C7428752C5B322C31335D292C';
wwv_flow_imp.g_varchar2_table(781) := '7B31383A5B312C32345D2C32323A5B312C32355D7D2C7428632C5B322C31365D292C7B32313A5B312C32365D7D2C7428752C5B322C31385D292C7B32323A5B312C32385D2C32343A5B312C32375D7D2C74286C2C5B322C32305D292C7428752C5B322C31';
wwv_flow_imp.g_varchar2_table(782) := '345D292C7B333A32302C343A652C32303A32397D2C7B333A352C343A652C353A362C363A6E2C373A332C383A722C393A342C31303A6F2C31313A692C31333A33302C31353A372C31363A382C31373A612C32333A737D2C7428752C5B322C31395D292C7B';
wwv_flow_imp.g_varchar2_table(783) := '333A352C343A652C353A362C363A6E2C373A332C383A722C393A342C31303A6F2C31313A692C31333A33312C31353A372C31363A382C31373A612C32333A737D2C7428632C5B322C31375D292C7428632C5B322C31355D292C74286C2C5B322C32315D29';
wwv_flow_imp.g_varchar2_table(784) := '5D2C64656661756C74416374696F6E733A7B31363A5B322C365D7D2C70617273654572726F723A66756E6374696F6E28742C65297B69662821652E7265636F76657261626C65297B66756E6374696F6E206E28742C65297B746869732E6D657373616765';
wwv_flow_imp.g_varchar2_table(785) := '3D742C746869732E686173683D657D7468726F77206E2E70726F746F747970653D4572726F722C6E6577206E28742C65297D746869732E74726163652874297D2C70617273653A66756E6374696F6E2874297B76617220653D746869732C6E3D5B305D2C';
wwv_flow_imp.g_varchar2_table(786) := '723D5B6E756C6C5D2C6F3D5B5D2C693D746869732E7461626C652C613D22222C733D302C753D302C633D322C6C3D312C683D6F2E736C6963652E63616C6C28617267756D656E74732C31292C703D4F626A6563742E63726561746528746869732E6C6578';
wwv_flow_imp.g_varchar2_table(787) := '6572292C643D7B79793A7B7D7D3B666F7228766172206620696E20746869732E7979294F626A6563742E70726F746F747970652E6861734F776E50726F70657274792E63616C6C28746869732E79792C6629262628642E79795B665D3D746869732E7979';
wwv_flow_imp.g_varchar2_table(788) := '5B665D293B702E736574496E70757428742C642E7979292C642E79792E6C657865723D702C642E79792E7061727365723D746869732C766F696420303D3D3D702E79796C6C6F63262628702E79796C6C6F633D7B7D293B76617220673D702E79796C6C6F';
wwv_flow_imp.g_varchar2_table(789) := '633B6F2E707573682867293B76617220793D702E6F7074696F6E732626702E6F7074696F6E732E72616E6765733B2266756E6374696F6E223D3D747970656F6620642E79792E70617273654572726F723F746869732E70617273654572726F723D642E79';
wwv_flow_imp.g_varchar2_table(790) := '792E70617273654572726F723A746869732E70617273654572726F723D4F626A6563742E67657450726F746F747970654F662874686973292E70617273654572726F723B666F7228766172206D2C762C5F2C622C452C532C542C432C4F2C493D66756E63';
wwv_flow_imp.g_varchar2_table(791) := '74696F6E28297B76617220743B72657475726E226E756D62657222213D747970656F6628743D702E6C657828297C7C6C29262628743D652E73796D626F6C735F5B745D7C7C74292C747D2C783D7B7D3B3B297B6966285F3D6E5B6E2E6C656E6774682D31';
wwv_flow_imp.g_varchar2_table(792) := '5D2C746869732E64656661756C74416374696F6E735B5F5D3F623D746869732E64656661756C74416374696F6E735B5F5D3A286E756C6C3D3D6D2626286D3D492829292C623D695B5F5D2626695B5F5D5B6D5D292C766F696420303D3D3D627C7C21622E';
wwv_flow_imp.g_varchar2_table(793) := '6C656E6774687C7C21625B305D297B766172204C3D22223B666F72285320696E204F3D5B5D2C695B5F5D29746869732E7465726D696E616C735F5B535D2626533E6326264F2E70757368282227222B746869732E7465726D696E616C735F5B535D2B2227';
wwv_flow_imp.g_varchar2_table(794) := '22293B4C3D702E73686F77506F736974696F6E3F225061727365206572726F72206F6E206C696E6520222B28732B31292B223A5C6E222B702E73686F77506F736974696F6E28292B225C6E457870656374696E6720222B4F2E6A6F696E28222C2022292B';
wwv_flow_imp.g_varchar2_table(795) := '222C20676F742027222B28746869732E7465726D696E616C735F5B6D5D7C7C6D292B2227223A225061727365206572726F72206F6E206C696E6520222B28732B31292B223A20556E657870656374656420222B286D3D3D6C3F22656E64206F6620696E70';
wwv_flow_imp.g_varchar2_table(796) := '7574223A2227222B28746869732E7465726D696E616C735F5B6D5D7C7C6D292B222722292C746869732E70617273654572726F72284C2C7B746578743A702E6D617463682C746F6B656E3A746869732E7465726D696E616C735F5B6D5D7C7C6D2C6C696E';
wwv_flow_imp.g_varchar2_table(797) := '653A702E79796C696E656E6F2C6C6F633A672C65787065637465643A4F7D297D696628625B305D696E7374616E63656F662041727261792626622E6C656E6774683E31297468726F77206E6577204572726F7228225061727365204572726F723A206D75';
wwv_flow_imp.g_varchar2_table(798) := '6C7469706C6520616374696F6E7320706F737369626C652061742073746174653A20222B5F2B222C20746F6B656E3A20222B6D293B73776974636828625B305D297B6361736520313A6E2E70757368286D292C722E7075736828702E797974657874292C';
wwv_flow_imp.g_varchar2_table(799) := '6F2E7075736828702E79796C6C6F63292C6E2E7075736828625B315D292C6D3D6E756C6C2C763F286D3D762C763D6E756C6C293A28753D702E79796C656E672C613D702E7979746578742C733D702E79796C696E656E6F2C673D702E79796C6C6F63293B';
wwv_flow_imp.g_varchar2_table(800) := '627265616B3B6361736520323A696628543D746869732E70726F64756374696F6E735F5B625B315D5D5B315D2C782E243D725B722E6C656E6774682D545D2C782E5F243D7B66697273745F6C696E653A6F5B6F2E6C656E6774682D28547C7C31295D2E66';
wwv_flow_imp.g_varchar2_table(801) := '697273745F6C696E652C6C6173745F6C696E653A6F5B6F2E6C656E6774682D315D2E6C6173745F6C696E652C66697273745F636F6C756D6E3A6F5B6F2E6C656E6774682D28547C7C31295D2E66697273745F636F6C756D6E2C6C6173745F636F6C756D6E';
wwv_flow_imp.g_varchar2_table(802) := '3A6F5B6F2E6C656E6774682D315D2E6C6173745F636F6C756D6E7D2C79262628782E5F242E72616E67653D5B6F5B6F2E6C656E6774682D28547C7C31295D2E72616E67655B305D2C6F5B6F2E6C656E6774682D315D2E72616E67655B315D5D292C766F69';
wwv_flow_imp.g_varchar2_table(803) := '642030213D3D28453D746869732E706572666F726D416374696F6E2E6170706C7928782C5B612C752C732C642E79792C625B315D2C722C6F5D2E636F6E63617428682929292972657475726E20453B542626286E3D6E2E736C69636528302C2D312A542A';
wwv_flow_imp.g_varchar2_table(804) := '32292C723D722E736C69636528302C2D312A54292C6F3D6F2E736C69636528302C2D312A5429292C6E2E7075736828746869732E70726F64756374696F6E735F5B625B315D5D5B305D292C722E7075736828782E24292C6F2E7075736828782E5F24292C';
wwv_flow_imp.g_varchar2_table(805) := '433D695B6E5B6E2E6C656E6774682D325D5D5B6E5B6E2E6C656E6774682D315D5D2C6E2E707573682843293B627265616B3B6361736520333A72657475726E21307D7D72657475726E21307D7D2C703D7B454F463A312C70617273654572726F723A6675';
wwv_flow_imp.g_varchar2_table(806) := '6E6374696F6E28742C65297B69662821746869732E79792E706172736572297468726F77206E6577204572726F722874293B746869732E79792E7061727365722E70617273654572726F7228742C65297D2C736574496E7075743A66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(807) := '742C65297B72657475726E20746869732E79793D657C7C746869732E79797C7C7B7D2C746869732E5F696E7075743D742C746869732E5F6D6F72653D746869732E5F6261636B747261636B3D746869732E646F6E653D21312C746869732E79796C696E65';
wwv_flow_imp.g_varchar2_table(808) := '6E6F3D746869732E79796C656E673D302C746869732E7979746578743D746869732E6D6174636865643D746869732E6D617463683D22222C746869732E636F6E646974696F6E537461636B3D5B22494E495449414C225D2C746869732E79796C6C6F633D';
wwv_flow_imp.g_varchar2_table(809) := '7B66697273745F6C696E653A312C66697273745F636F6C756D6E3A302C6C6173745F6C696E653A312C6C6173745F636F6C756D6E3A307D2C746869732E6F7074696F6E732E72616E676573262628746869732E79796C6C6F632E72616E67653D5B302C30';
wwv_flow_imp.g_varchar2_table(810) := '5D292C746869732E6F66667365743D302C746869737D2C696E7075743A66756E6374696F6E28297B76617220743D746869732E5F696E7075745B305D3B72657475726E20746869732E7979746578742B3D742C746869732E79796C656E672B2B2C746869';
wwv_flow_imp.g_varchar2_table(811) := '732E6F66667365742B2B2C746869732E6D617463682B3D742C746869732E6D6174636865642B3D742C742E6D61746368282F283F3A5C725C6E3F7C5C6E292E2A2F67293F28746869732E79796C696E656E6F2B2B2C746869732E79796C6C6F632E6C6173';
wwv_flow_imp.g_varchar2_table(812) := '745F6C696E652B2B293A746869732E79796C6C6F632E6C6173745F636F6C756D6E2B2B2C746869732E6F7074696F6E732E72616E6765732626746869732E79796C6C6F632E72616E67655B315D2B2B2C746869732E5F696E7075743D746869732E5F696E';
wwv_flow_imp.g_varchar2_table(813) := '7075742E736C6963652831292C747D2C756E7075743A66756E6374696F6E2874297B76617220653D742E6C656E6774682C6E3D742E73706C6974282F283F3A5C725C6E3F7C5C6E292F67293B746869732E5F696E7075743D742B746869732E5F696E7075';
wwv_flow_imp.g_varchar2_table(814) := '742C746869732E7979746578743D746869732E7979746578742E73756273747228302C746869732E7979746578742E6C656E6774682D65292C746869732E6F66667365742D3D653B76617220723D746869732E6D617463682E73706C6974282F283F3A5C';
wwv_flow_imp.g_varchar2_table(815) := '725C6E3F7C5C6E292F67293B746869732E6D617463683D746869732E6D617463682E73756273747228302C746869732E6D617463682E6C656E6774682D31292C746869732E6D6174636865643D746869732E6D6174636865642E73756273747228302C74';
wwv_flow_imp.g_varchar2_table(816) := '6869732E6D6174636865642E6C656E6774682D31292C6E2E6C656E6774682D31262628746869732E79796C696E656E6F2D3D6E2E6C656E6774682D31293B766172206F3D746869732E79796C6C6F632E72616E67653B72657475726E20746869732E7979';
wwv_flow_imp.g_varchar2_table(817) := '6C6C6F633D7B66697273745F6C696E653A746869732E79796C6C6F632E66697273745F6C696E652C6C6173745F6C696E653A746869732E79796C696E656E6F2B312C66697273745F636F6C756D6E3A746869732E79796C6C6F632E66697273745F636F6C';
wwv_flow_imp.g_varchar2_table(818) := '756D6E2C6C6173745F636F6C756D6E3A6E3F286E2E6C656E6774683D3D3D722E6C656E6774683F746869732E79796C6C6F632E66697273745F636F6C756D6E3A30292B725B722E6C656E6774682D6E2E6C656E6774685D2E6C656E6774682D6E5B305D2E';
wwv_flow_imp.g_varchar2_table(819) := '6C656E6774683A746869732E79796C6C6F632E66697273745F636F6C756D6E2D657D2C746869732E6F7074696F6E732E72616E676573262628746869732E79796C6C6F632E72616E67653D5B6F5B305D2C6F5B305D2B746869732E79796C656E672D655D';
wwv_flow_imp.g_varchar2_table(820) := '292C746869732E79796C656E673D746869732E7979746578742E6C656E6774682C746869737D2C6D6F72653A66756E6374696F6E28297B72657475726E20746869732E5F6D6F72653D21302C746869737D2C72656A6563743A66756E6374696F6E28297B';
wwv_flow_imp.g_varchar2_table(821) := '72657475726E20746869732E6F7074696F6E732E6261636B747261636B5F6C657865723F28746869732E5F6261636B747261636B3D21302C74686973293A746869732E70617273654572726F7228224C65786963616C206572726F72206F6E206C696E65';
wwv_flow_imp.g_varchar2_table(822) := '20222B28746869732E79796C696E656E6F2B31292B222E20596F752063616E206F6E6C7920696E766F6B652072656A656374282920696E20746865206C65786572207768656E20746865206C65786572206973206F6620746865206261636B747261636B';
wwv_flow_imp.g_varchar2_table(823) := '696E672070657273756173696F6E20286F7074696F6E732E6261636B747261636B5F6C65786572203D2074727565292E5C6E222B746869732E73686F77506F736974696F6E28292C7B746578743A22222C746F6B656E3A6E756C6C2C6C696E653A746869';
wwv_flow_imp.g_varchar2_table(824) := '732E79796C696E656E6F7D297D2C6C6573733A66756E6374696F6E2874297B746869732E756E70757428746869732E6D617463682E736C696365287429297D2C70617374496E7075743A66756E6374696F6E28297B76617220743D746869732E6D617463';
wwv_flow_imp.g_varchar2_table(825) := '6865642E73756273747228302C746869732E6D6174636865642E6C656E6774682D746869732E6D617463682E6C656E677468293B72657475726E28742E6C656E6774683E32303F222E2E2E223A2222292B742E737562737472282D3230292E7265706C61';
wwv_flow_imp.g_varchar2_table(826) := '6365282F5C6E2F672C2222297D2C7570636F6D696E67496E7075743A66756E6374696F6E28297B76617220743D746869732E6D617463683B72657475726E20742E6C656E6774683C3230262628742B3D746869732E5F696E7075742E7375627374722830';
wwv_flow_imp.g_varchar2_table(827) := '2C32302D742E6C656E67746829292C28742E73756273747228302C3230292B28742E6C656E6774683E32303F222E2E2E223A222229292E7265706C616365282F5C6E2F672C2222297D2C73686F77506F736974696F6E3A66756E6374696F6E28297B7661';
wwv_flow_imp.g_varchar2_table(828) := '7220743D746869732E70617374496E70757428292C653D6E657720417272617928742E6C656E6774682B31292E6A6F696E28222D22293B72657475726E20742B746869732E7570636F6D696E67496E70757428292B225C6E222B652B225E227D2C746573';
wwv_flow_imp.g_varchar2_table(829) := '745F6D617463683A66756E6374696F6E28742C65297B766172206E2C722C6F3B696628746869732E6F7074696F6E732E6261636B747261636B5F6C657865722626286F3D7B79796C696E656E6F3A746869732E79796C696E656E6F2C79796C6C6F633A7B';
wwv_flow_imp.g_varchar2_table(830) := '66697273745F6C696E653A746869732E79796C6C6F632E66697273745F6C696E652C6C6173745F6C696E653A746869732E6C6173745F6C696E652C66697273745F636F6C756D6E3A746869732E79796C6C6F632E66697273745F636F6C756D6E2C6C6173';
wwv_flow_imp.g_varchar2_table(831) := '745F636F6C756D6E3A746869732E79796C6C6F632E6C6173745F636F6C756D6E7D2C7979746578743A746869732E7979746578742C6D617463683A746869732E6D617463682C6D6174636865733A746869732E6D6174636865732C6D6174636865643A74';
wwv_flow_imp.g_varchar2_table(832) := '6869732E6D6174636865642C79796C656E673A746869732E79796C656E672C6F66667365743A746869732E6F66667365742C5F6D6F72653A746869732E5F6D6F72652C5F696E7075743A746869732E5F696E7075742C79793A746869732E79792C636F6E';
wwv_flow_imp.g_varchar2_table(833) := '646974696F6E537461636B3A746869732E636F6E646974696F6E537461636B2E736C6963652830292C646F6E653A746869732E646F6E657D2C746869732E6F7074696F6E732E72616E6765732626286F2E79796C6C6F632E72616E67653D746869732E79';
wwv_flow_imp.g_varchar2_table(834) := '796C6C6F632E72616E67652E736C69636528302929292C28723D745B305D2E6D61746368282F283F3A5C725C6E3F7C5C6E292E2A2F672929262628746869732E79796C696E656E6F2B3D722E6C656E677468292C746869732E79796C6C6F633D7B666972';
wwv_flow_imp.g_varchar2_table(835) := '73745F6C696E653A746869732E79796C6C6F632E6C6173745F6C696E652C6C6173745F6C696E653A746869732E79796C696E656E6F2B312C66697273745F636F6C756D6E3A746869732E79796C6C6F632E6C6173745F636F6C756D6E2C6C6173745F636F';
wwv_flow_imp.g_varchar2_table(836) := '6C756D6E3A723F725B722E6C656E6774682D315D2E6C656E6774682D725B722E6C656E6774682D315D2E6D61746368282F5C723F5C6E3F2F295B305D2E6C656E6774683A746869732E79796C6C6F632E6C6173745F636F6C756D6E2B745B305D2E6C656E';
wwv_flow_imp.g_varchar2_table(837) := '6774687D2C746869732E7979746578742B3D745B305D2C746869732E6D617463682B3D745B305D2C746869732E6D6174636865733D742C746869732E79796C656E673D746869732E7979746578742E6C656E6774682C746869732E6F7074696F6E732E72';
wwv_flow_imp.g_varchar2_table(838) := '616E676573262628746869732E79796C6C6F632E72616E67653D5B746869732E6F66667365742C746869732E6F66667365742B3D746869732E79796C656E675D292C746869732E5F6D6F72653D21312C746869732E5F6261636B747261636B3D21312C74';
wwv_flow_imp.g_varchar2_table(839) := '6869732E5F696E7075743D746869732E5F696E7075742E736C69636528745B305D2E6C656E677468292C746869732E6D6174636865642B3D745B305D2C6E3D746869732E706572666F726D416374696F6E2E63616C6C28746869732C746869732E79792C';
wwv_flow_imp.g_varchar2_table(840) := '746869732C652C746869732E636F6E646974696F6E537461636B5B746869732E636F6E646974696F6E537461636B2E6C656E6774682D315D292C746869732E646F6E652626746869732E5F696E707574262628746869732E646F6E653D2131292C6E2972';
wwv_flow_imp.g_varchar2_table(841) := '657475726E206E3B696628746869732E5F6261636B747261636B297B666F7228766172206920696E206F29746869735B695D3D6F5B695D3B72657475726E21317D72657475726E21317D2C6E6578743A66756E6374696F6E28297B696628746869732E64';
wwv_flow_imp.g_varchar2_table(842) := '6F6E652972657475726E20746869732E454F463B76617220742C652C6E2C723B746869732E5F696E7075747C7C28746869732E646F6E653D2130292C746869732E5F6D6F72657C7C28746869732E7979746578743D22222C746869732E6D617463683D22';
wwv_flow_imp.g_varchar2_table(843) := '22293B666F7228766172206F3D746869732E5F63757272656E7452756C657328292C693D303B693C6F2E6C656E6774683B692B2B29696628286E3D746869732E5F696E7075742E6D6174636828746869732E72756C65735B6F5B695D5D29292626282165';
wwv_flow_imp.g_varchar2_table(844) := '7C7C6E5B305D2E6C656E6774683E655B305D2E6C656E67746829297B696628653D6E2C723D692C746869732E6F7074696F6E732E6261636B747261636B5F6C65786572297B6966282131213D3D28743D746869732E746573745F6D61746368286E2C6F5B';
wwv_flow_imp.g_varchar2_table(845) := '695D29292972657475726E20743B696628746869732E5F6261636B747261636B297B653D21313B636F6E74696E75657D72657475726E21317D69662821746869732E6F7074696F6E732E666C657829627265616B7D72657475726E20653F2131213D3D28';
wwv_flow_imp.g_varchar2_table(846) := '743D746869732E746573745F6D6174636828652C6F5B725D29292626743A22223D3D3D746869732E5F696E7075743F746869732E454F463A746869732E70617273654572726F7228224C65786963616C206572726F72206F6E206C696E6520222B287468';
wwv_flow_imp.g_varchar2_table(847) := '69732E79796C696E656E6F2B31292B222E20556E7265636F676E697A656420746578742E5C6E222B746869732E73686F77506F736974696F6E28292C7B746578743A22222C746F6B656E3A6E756C6C2C6C696E653A746869732E79796C696E656E6F7D29';
wwv_flow_imp.g_varchar2_table(848) := '7D2C6C65783A66756E6374696F6E28297B76617220743D746869732E6E65787428293B72657475726E20747C7C746869732E6C657828297D2C626567696E3A66756E6374696F6E2874297B746869732E636F6E646974696F6E537461636B2E7075736828';
wwv_flow_imp.g_varchar2_table(849) := '74297D2C706F7053746174653A66756E6374696F6E28297B72657475726E20746869732E636F6E646974696F6E537461636B2E6C656E6774682D313E303F746869732E636F6E646974696F6E537461636B2E706F7028293A746869732E636F6E64697469';
wwv_flow_imp.g_varchar2_table(850) := '6F6E537461636B5B305D7D2C5F63757272656E7452756C65733A66756E6374696F6E28297B72657475726E20746869732E636F6E646974696F6E537461636B2E6C656E6774682626746869732E636F6E646974696F6E537461636B5B746869732E636F6E';
wwv_flow_imp.g_varchar2_table(851) := '646974696F6E537461636B2E6C656E6774682D315D3F746869732E636F6E646974696F6E735B746869732E636F6E646974696F6E537461636B5B746869732E636F6E646974696F6E537461636B2E6C656E6774682D315D5D2E72756C65733A746869732E';
wwv_flow_imp.g_varchar2_table(852) := '636F6E646974696F6E732E494E495449414C2E72756C65737D2C746F7053746174653A66756E6374696F6E2874297B72657475726E28743D746869732E636F6E646974696F6E537461636B2E6C656E6774682D312D4D6174682E61627328747C7C302929';
wwv_flow_imp.g_varchar2_table(853) := '3E3D303F746869732E636F6E646974696F6E537461636B5B745D3A22494E495449414C227D2C7075736853746174653A66756E6374696F6E2874297B746869732E626567696E2874297D2C7374617465537461636B53697A653A66756E6374696F6E2829';
wwv_flow_imp.g_varchar2_table(854) := '7B72657475726E20746869732E636F6E646974696F6E537461636B2E6C656E6774687D2C6F7074696F6E733A7B7D2C706572666F726D416374696F6E3A66756E6374696F6E28742C652C6E2C72297B737769746368286E297B6361736520303A62726561';
wwv_flow_imp.g_varchar2_table(855) := '6B3B6361736520313A72657475726E20363B6361736520323A72657475726E20652E7979746578743D652E7979746578742E73756273747228312C652E79796C656E672D32292C343B6361736520333A72657475726E2031373B6361736520343A726574';
wwv_flow_imp.g_varchar2_table(856) := '75726E2031383B6361736520353A72657475726E2032333B6361736520363A72657475726E2032343B6361736520373A72657475726E2032323B6361736520383A72657475726E2032313B6361736520393A72657475726E2031303B636173652031303A';
wwv_flow_imp.g_varchar2_table(857) := '72657475726E2031313B636173652031313A72657475726E20383B636173652031323A72657475726E2031343B636173652031333A72657475726E22494E56414C4944227D7D2C72756C65733A5B2F5E283F3A5C732B292F2C2F5E283F3A282D3F285B30';
wwv_flow_imp.g_varchar2_table(858) := '2D395D7C5B312D395D5B302D395D2B2929285C2E5B302D395D2B293F285B65455D5B2D2B5D3F5B302D395D2B293F5C62292F2C2F5E283F3A22283F3A5C5C5B5C5C2262666E72745C2F5D7C5C5C755B612D66412D46302D395D7B347D7C5B5E5C5C5C302D';
wwv_flow_imp.g_varchar2_table(859) := '5C7830395C7830612D5C783166225D292A22292F2C2F5E283F3A5C7B292F2C2F5E283F3A5C7D292F2C2F5E283F3A5C5B292F2C2F5E283F3A5C5D292F2C2F5E283F3A2C292F2C2F5E283F3A3A292F2C2F5E283F3A747275655C62292F2C2F5E283F3A6661';
wwv_flow_imp.g_varchar2_table(860) := '6C73655C62292F2C2F5E283F3A6E756C6C5C62292F2C2F5E283F3A24292F2C2F5E283F3A2E292F5D2C636F6E646974696F6E733A7B494E495449414C3A7B72756C65733A5B302C312C322C332C342C352C362C372C382C392C31302C31312C31322C3133';
wwv_flow_imp.g_varchar2_table(861) := '5D2C696E636C75736976653A21307D7D7D3B66756E6374696F6E206428297B746869732E79793D7B7D7D72657475726E20682E6C657865723D702C642E70726F746F747970653D682C682E5061727365723D642C6E657720647D28293B652E7061727365';
wwv_flow_imp.g_varchar2_table(862) := '723D6E2C652E5061727365723D6E2E5061727365722C652E70617273653D66756E6374696F6E28297B72657475726E206E2E70617273652E6170706C79286E2C617267756D656E7473297D2C652E6D61696E3D66756E6374696F6E2874297B745B315D7C';
wwv_flow_imp.g_varchar2_table(863) := '7C28636F6E736F6C652E6C6F67282255736167653A20222B745B305D2B222046494C4522292C70726F636573732E65786974283129293B766172206E3D58742E7265616446696C6553796E632872652E6E6F726D616C697A6528745B315D292C22757466';
wwv_flow_imp.g_varchar2_table(864) := '3822293B72657475726E20652E7061727365722E7061727365286E297D2C6B2E6D61696E3D3D3D742626652E6D61696E2870726F636573732E617267762E736C696365283129297D29293B61652E7061727365722C61652E5061727365722C61652E7061';
wwv_flow_imp.g_varchar2_table(865) := '7273652C61652E6D61696E3B66756E6374696F6E2073652874297B72657475726E20742A4D6174682E50492F3138307D66756E6374696F6E2075652874297B76617220653D303B696628742E6C656E6774683E3229666F7228766172206E2C722C6F3D30';
wwv_flow_imp.g_varchar2_table(866) := '3B6F3C742E6C656E6774682D313B6F2B2B296E3D745B6F5D2C652B3D73652828723D745B6F2B315D295B305D2D6E5B305D292A28322B4D6174682E73696E287365286E5B315D29292B4D6174682E73696E28736528725B315D2929293B72657475726E20';
wwv_flow_imp.g_varchar2_table(867) := '653E3D307D66756E6374696F6E2063652874297B696628742626742E6C656E6774683E30297B696628756528745B305D292972657475726E21313B69662821742E736C69636528312C742E6C656E677468292E6576657279287565292972657475726E21';
wwv_flow_imp.g_varchar2_table(868) := '317D72657475726E21307D766172206C653D66756E6374696F6E28742C65297B2866756E6374696F6E2874297B72657475726E22506F6C79676F6E223D3D3D742E747970653F636528742E636F6F7264696E61746573293A224D756C7469506F6C79676F';
wwv_flow_imp.g_varchar2_table(869) := '6E223D3D3D742E747970653F742E636F6F7264696E617465732E6576657279286365293A766F696420307D292874297C7C652E70757368287B6D6573736167653A22506F6C79676F6E7320616E64204D756C7469506F6C79676F6E732073686F756C6420';
wwv_flow_imp.g_varchar2_table(870) := '666F6C6C6F77207468652072696768742D68616E642072756C65222C6C6576656C3A226D657373616765222C6C696E653A742E5F5F6C696E655F5F7D297D3B7661722068653D7B68696E743A66756E6374696F6E28742C65297B766172206E3D5B5D2C72';
wwv_flow_imp.g_varchar2_table(871) := '3D302C6F3D31302C693D363B66756E6374696F6E20612874297B69662865262621313D3D3D652E6E6F4475706C69636174654D656D626572737C7C21742E5F5F6475706C696361746550726F706572746965735F5F7C7C6E2E70757368287B6D65737361';
wwv_flow_imp.g_varchar2_table(872) := '67653A22416E206F626A65637420636F6E7461696E6564206475706C6963617465206D656D626572732C206D616B696E672070617273696E6720616D6269676F75733A20222B742E5F5F6475706C696361746550726F706572746965735F5F2E6A6F696E';
wwv_flow_imp.g_varchar2_table(873) := '28222C2022292C6C696E653A742E5F5F6C696E655F5F7D292C217528742C2274797065222C22737472696E67222929696628665B742E747970655D29742626665B742E747970655D2874293B656C73657B76617220723D675B742E747970652E746F4C6F';
wwv_flow_imp.g_varchar2_table(874) := '7765724361736528295D3B766F69642030213D3D723F6E2E70757368287B6D6573736167653A22457870656374656420222B722B222062757420676F7420222B742E747970652B222028636173652073656E73697469766529222C6C696E653A742E5F5F';
wwv_flow_imp.g_varchar2_table(875) := '6C696E655F5F7D293A6E2E70757368287B6D6573736167653A22546865207479706520222B742E747970652B2220697320756E6B6E6F776E222C6C696E653A742E5F5F6C696E655F5F7D297D7D66756E6374696F6E207328742C65297B72657475726E20';
wwv_flow_imp.g_varchar2_table(876) := '742E6576657279282866756E6374696F6E2874297B72657475726E206E756C6C213D3D742626747970656F6620743D3D3D657D29297D66756E6374696F6E207528742C652C72297B696628766F696420303D3D3D745B655D2972657475726E206E2E7075';
wwv_flow_imp.g_varchar2_table(877) := '7368287B6D6573736167653A2722272B652B2722206D656D626572207265717569726564272C6C696E653A742E5F5F6C696E655F5F7D293B696628226172726179223D3D3D72297B6966282141727261792E6973417272617928745B655D292972657475';
wwv_flow_imp.g_varchar2_table(878) := '726E206E2E70757368287B6D6573736167653A2722272B652B2722206D656D6265722073686F756C6420626520616E2061727261792C2062757420697320616E20272B747970656F6620745B655D2B2220696E7374656164222C6C696E653A742E5F5F6C';
wwv_flow_imp.g_varchar2_table(879) := '696E655F5F7D297D656C73657B696628226F626A656374223D3D3D722626745B655D2626745B655D2E636F6E7374727563746F72213D3D4F626A6563742972657475726E206E2E70757368287B6D6573736167653A2722272B652B2722206D656D626572';
wwv_flow_imp.g_varchar2_table(880) := '2073686F756C6420626520272B722B222C2062757420697320616E20222B745B655D2E636F6E7374727563746F722E6E616D652B2220696E7374656164222C6C696E653A742E5F5F6C696E655F5F7D293B696628722626747970656F6620745B655D213D';
wwv_flow_imp.g_varchar2_table(881) := '3D722972657475726E206E2E70757368287B6D6573736167653A2722272B652B2722206D656D6265722073686F756C6420626520272B722B222C2062757420697320616E20222B747970656F6620745B655D2B2220696E7374656164222C6C696E653A74';
wwv_flow_imp.g_varchar2_table(882) := '2E5F5F6C696E655F5F7D297D7D66756E6374696F6E206328742C61297B6966282141727261792E697341727261792874292972657475726E206E2E70757368287B6D6573736167653A22706F736974696F6E2073686F756C6420626520616E2061727261';
wwv_flow_imp.g_varchar2_table(883) := '792C206973206120222B747970656F6620742B2220696E7374656164222C6C696E653A742E5F5F6C696E655F5F7C7C617D293B696628742E6C656E6774683C322972657475726E206E2E70757368287B6D6573736167653A22706F736974696F6E206D75';
wwv_flow_imp.g_varchar2_table(884) := '737420686176652032206F72206D6F726520656C656D656E7473222C6C696E653A742E5F5F6C696E655F5F7C7C617D293B696628742E6C656E6774683E332972657475726E206E2E70757368287B6D6573736167653A22706F736974696F6E2073686F75';
wwv_flow_imp.g_varchar2_table(885) := '6C64206E6F742068617665206D6F7265207468616E203320656C656D656E7473222C6C6576656C3A226D657373616765222C6C696E653A742E5F5F6C696E655F5F7C7C617D293B696628217328742C226E756D62657222292972657475726E206E2E7075';
wwv_flow_imp.g_varchar2_table(886) := '7368287B6D6573736167653A226561636820656C656D656E7420696E206120706F736974696F6E206D7573742062652061206E756D626572222C6C696E653A742E5F5F6C696E655F5F7C7C617D293B696628652626652E707265636973696F6E5761726E';
wwv_flow_imp.g_varchar2_table(887) := '696E67297B696628723D3D3D6F2972657475726E20722B3D312C6E2E70757368287B6D6573736167653A227472756E6361746564207761726E696E67733A20776527766520656E636F756E746572656420636F6F7264696E61746520707265636973696F';
wwv_flow_imp.g_varchar2_table(888) := '6E207761726E696E6720222B6F2B222074696D65732C206E6F206D6F7265207761726E696E67732077696C6C206265207265706F72746564222C6C6576656C3A226D657373616765222C6C696E653A742E5F5F6C696E655F5F7C7C617D293B723C6F2626';
wwv_flow_imp.g_varchar2_table(889) := '742E666F7245616368282866756E6374696F6E2865297B766172206F3D302C733D537472696E672865292E73706C697428222E22295B315D3B696628766F69642030213D3D732626286F3D732E6C656E677468292C6F3E692972657475726E20722B3D31';
wwv_flow_imp.g_varchar2_table(890) := '2C6E2E70757368287B6D6573736167653A22707265636973696F6E206F6620636F6F7264696E617465732073686F756C642062652072656475636564222C6C6576656C3A226D657373616765222C6C696E653A742E5F5F6C696E655F5F7C7C617D297D29';
wwv_flow_imp.g_varchar2_table(891) := '297D7D66756E6374696F6E206C28742C652C722C6F297B696628766F696420303D3D3D6F2626766F69642030213D3D742E5F5F6C696E655F5F2626286F3D742E5F5F6C696E655F5F292C303D3D3D722972657475726E206328742C6F293B696628313D3D';
wwv_flow_imp.g_varchar2_table(892) := '3D7226266529696628224C696E65617252696E67223D3D3D65297B6966282141727261792E6973417272617928745B742E6C656E6774682D315D292972657475726E206E2E70757368287B6D6573736167653A2261206E756D6265722077617320666F75';
wwv_flow_imp.g_varchar2_table(893) := '6E64207768657265206120636F6F7264696E6174652061727261792073686F756C642068617665206265656E20666F756E643A2074686973206E6565647320746F206265206E6573746564206D6F726520646565706C79222C6C696E653A6F7D292C2130';
wwv_flow_imp.g_varchar2_table(894) := '3B696628742E6C656E6774683C3426266E2E70757368287B6D6573736167653A2261204C696E65617252696E67206F6620636F6F7264696E61746573206E6565647320746F206861766520666F7572206F72206D6F726520706F736974696F6E73222C6C';
wwv_flow_imp.g_varchar2_table(895) := '696E653A6F7D292C742E6C656E677468262628745B742E6C656E6774682D315D2E6C656E677468213D3D745B305D2E6C656E6774687C7C21745B742E6C656E6774682D315D2E6576657279282866756E6374696F6E28652C6E297B72657475726E20745B';
wwv_flow_imp.g_varchar2_table(896) := '305D5B6E5D3D3D3D657D2929292972657475726E206E2E70757368287B6D6573736167653A2274686520666972737420616E64206C61737420706F736974696F6E7320696E2061204C696E65617252696E67206F6620636F6F7264696E61746573206D75';
wwv_flow_imp.g_varchar2_table(897) := '7374206265207468652073616D65222C6C696E653A6F7D292C21307D656C736520696628224C696E65223D3D3D652626742E6C656E6774683C322972657475726E206E2E70757368287B6D6573736167653A2261206C696E65206E6565647320746F2068';
wwv_flow_imp.g_varchar2_table(898) := '6176652074776F206F72206D6F726520636F6F7264696E6174657320746F2062652076616C6964222C6C696E653A6F7D293B69662841727261792E697341727261792874292972657475726E20742E6D6170282866756E6374696F6E2874297B72657475';
wwv_flow_imp.g_varchar2_table(899) := '726E206C28742C652C722D312C742E5F5F6C696E655F5F7C7C6F297D29292E736F6D65282866756E6374696F6E2874297B72657475726E20747D29293B6E2E70757368287B6D6573736167653A2261206E756D6265722077617320666F756E6420776865';
wwv_flow_imp.g_varchar2_table(900) := '7265206120636F6F7264696E6174652061727261792073686F756C642068617665206265656E20666F756E643A2074686973206E6565647320746F206265206E6573746564206D6F726520646565706C79222C6C696E653A6F7D297D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(901) := '20682874297B696628742E637273297B226F626A656374223D3D747970656F6620742E6372732626742E6372732E70726F7065727469657326262275726E3A6F67633A6465663A6372733A4F47433A312E333A4352533834223D3D3D742E6372732E7072';
wwv_flow_imp.g_varchar2_table(902) := '6F706572746965732E6E616D653F6E2E70757368287B6D6573736167653A226F6C642D7374796C6520637273206D656D626572206973206E6F74207265636F6D6D656E6465642C2074686973206F626A656374206973206571756976616C656E7420746F';
wwv_flow_imp.g_varchar2_table(903) := '207468652064656661756C7420616E642073686F756C642062652072656D6F766564222C6C696E653A742E5F5F6C696E655F5F7D293A6E2E70757368287B6D6573736167653A226F6C642D7374796C6520637273206D656D626572206973206E6F742072';
wwv_flow_imp.g_varchar2_table(904) := '65636F6D6D656E646564222C6C696E653A742E5F5F6C696E655F5F7D297D7D66756E6374696F6E20702874297B696628742E62626F782972657475726E2041727261792E6973417272617928742E62626F78293F287328742E62626F782C226E756D6265';
wwv_flow_imp.g_varchar2_table(905) := '7222297C7C6E2E70757368287B6D6573736167653A226561636820656C656D656E7420696E20612062626F78206D656D626572206D7573742062652061206E756D626572222C6C696E653A742E62626F782E5F5F6C696E655F5F7D292C34213D3D742E62';
wwv_flow_imp.g_varchar2_table(906) := '626F782E6C656E677468262636213D3D742E62626F782E6C656E67746826266E2E70757368287B6D6573736167653A2262626F78206D75737420636F6E7461696E203420656C656D656E74732028666F7220324429206F72203620656C656D656E747320';
wwv_flow_imp.g_varchar2_table(907) := '28666F7220334429222C6C696E653A742E62626F782E5F5F6C696E655F5F7D292C6E2E6C656E677468293A766F6964206E2E70757368287B6D6573736167653A2262626F78206D656D626572206D75737420626520616E206172726179206F66206E756D';
wwv_flow_imp.g_varchar2_table(908) := '626572732C20627574206973206120222B747970656F6620742E62626F782C6C696E653A742E5F5F6C696E655F5F7D297D66756E6374696F6E20642874297B682874292C702874292C766F69642030213D3D742E6964262622737472696E6722213D7479';
wwv_flow_imp.g_varchar2_table(909) := '70656F6620742E69642626226E756D62657222213D747970656F6620742E696426266E2E70757368287B6D6573736167653A27466561747572652022696422206D656D626572206D7573742068617665206120737472696E67206F72206E756D62657220';
wwv_flow_imp.g_varchar2_table(910) := '76616C7565272C6C696E653A742E5F5F6C696E655F5F7D292C766F69642030213D3D742E666561747572657326266E2E70757368287B6D6573736167653A2746656174757265206F626A6563742063616E6E6F7420636F6E7461696E2061202266656174';
wwv_flow_imp.g_varchar2_table(911) := '7572657322206D656D626572272C6C696E653A742E5F5F6C696E655F5F7D292C766F69642030213D3D742E636F6F7264696E6174657326266E2E70757368287B6D6573736167653A2746656174757265206F626A6563742063616E6E6F7420636F6E7461';
wwv_flow_imp.g_varchar2_table(912) := '696E20612022636F6F7264696E6174657322206D656D626572272C6C696E653A742E5F5F6C696E655F5F7D292C224665617475726522213D3D742E7479706526266E2E70757368287B6D6573736167653A2247656F4A534F4E206665617475726573206D';
wwv_flow_imp.g_varchar2_table(913) := '7573742068617665206120747970653D66656174757265206D656D626572222C6C696E653A742E5F5F6C696E655F5F7D292C7528742C2270726F70657274696573222C226F626A65637422292C7528742C2267656F6D65747279222C226F626A65637422';
wwv_flow_imp.g_varchar2_table(914) := '297C7C742E67656F6D6574727926266128742E67656F6D65747279297D76617220663D7B506F696E743A66756E6374696F6E2874297B76617220653B682874292C702874292C766F69642030213D3D28653D74292E70726F7065727469657326266E2E70';
wwv_flow_imp.g_varchar2_table(915) := '757368287B6D6573736167653A2767656F6D65747279206F626A6563742063616E6E6F7420636F6E7461696E2061202270726F7065727469657322206D656D626572272C6C696E653A652E5F5F6C696E655F5F7D292C766F69642030213D3D652E67656F';
wwv_flow_imp.g_varchar2_table(916) := '6D6574727926266E2E70757368287B6D6573736167653A2767656F6D65747279206F626A6563742063616E6E6F7420636F6E7461696E2061202267656F6D6574727922206D656D626572272C6C696E653A652E5F5F6C696E655F5F7D292C766F69642030';
wwv_flow_imp.g_varchar2_table(917) := '213D3D652E666561747572657326266E2E70757368287B6D6573736167653A2767656F6D65747279206F626A6563742063616E6E6F7420636F6E7461696E20612022666561747572657322206D656D626572272C6C696E653A652E5F5F6C696E655F5F7D';
wwv_flow_imp.g_varchar2_table(918) := '292C7528742C22636F6F7264696E61746573222C22617272617922297C7C6328742E636F6F7264696E61746573297D2C466561747572653A642C4D756C7469506F696E743A66756E6374696F6E2874297B682874292C702874292C7528742C22636F6F72';
wwv_flow_imp.g_varchar2_table(919) := '64696E61746573222C22617272617922297C7C6C28742E636F6F7264696E617465732C22222C31297D2C4C696E65537472696E673A66756E6374696F6E2874297B682874292C702874292C7528742C22636F6F7264696E61746573222C22617272617922';
wwv_flow_imp.g_varchar2_table(920) := '297C7C6C28742E636F6F7264696E617465732C224C696E65222C31297D2C4D756C74694C696E65537472696E673A66756E6374696F6E2874297B682874292C702874292C7528742C22636F6F7264696E61746573222C22617272617922297C7C6C28742E';
wwv_flow_imp.g_varchar2_table(921) := '636F6F7264696E617465732C224C696E65222C32297D2C46656174757265436F6C6C656374696F6E3A66756E6374696F6E2874297B696628682874292C702874292C766F69642030213D3D742E70726F7065727469657326266E2E70757368287B6D6573';
wwv_flow_imp.g_varchar2_table(922) := '736167653A2746656174757265436F6C6C656374696F6E206F626A6563742063616E6E6F7420636F6E7461696E2061202270726F7065727469657322206D656D626572272C6C696E653A742E5F5F6C696E655F5F7D292C766F69642030213D3D742E636F';
wwv_flow_imp.g_varchar2_table(923) := '6F7264696E6174657326266E2E70757368287B6D6573736167653A2746656174757265436F6C6C656374696F6E206F626A6563742063616E6E6F7420636F6E7461696E20612022636F6F7264696E6174657322206D656D626572272C6C696E653A742E5F';
wwv_flow_imp.g_varchar2_table(924) := '5F6C696E655F5F7D292C217528742C226665617475726573222C2261727261792229297B696628217328742E66656174757265732C226F626A65637422292972657475726E206E2E70757368287B6D6573736167653A2245766572792066656174757265';
wwv_flow_imp.g_varchar2_table(925) := '206D75737420626520616E206F626A656374222C6C696E653A742E5F5F6C696E655F5F7D293B742E66656174757265732E666F72456163682864297D7D2C47656F6D65747279436F6C6C656374696F6E3A66756E6374696F6E2874297B682874292C7028';
wwv_flow_imp.g_varchar2_table(926) := '74292C7528742C2267656F6D657472696573222C22617272617922297C7C287328742E67656F6D6574726965732C226F626A65637422297C7C6E2E70757368287B6D6573736167653A225468652067656F6D65747269657320617272617920696E206120';
wwv_flow_imp.g_varchar2_table(927) := '47656F6D65747279436F6C6C656374696F6E206D75737420636F6E7461696E206F6E6C792067656F6D65747279206F626A65637473222C6C696E653A742E5F5F6C696E655F5F7D292C313D3D3D742E67656F6D6574726965732E6C656E67746826266E2E';
wwv_flow_imp.g_varchar2_table(928) := '70757368287B6D6573736167653A2247656F6D65747279436F6C6C656374696F6E207769746820612073696E676C652067656F6D657472792073686F756C642062652061766F6964656420696E206661766F72206F662073696E676C652070617274206F';
wwv_flow_imp.g_varchar2_table(929) := '7220612073696E676C65206F626A656374206F66206D756C74692D706172742074797065222C6C696E653A742E67656F6D6574726965732E5F5F6C696E655F5F7D292C742E67656F6D6574726965732E666F7245616368282866756E6374696F6E286529';
wwv_flow_imp.g_varchar2_table(930) := '7B652626282247656F6D65747279436F6C6C656374696F6E223D3D3D652E7479706526266E2E70757368287B6D6573736167653A2247656F6D65747279436F6C6C656374696F6E2073686F756C642061766F6964206E65737465642067656F6D65747279';
wwv_flow_imp.g_varchar2_table(931) := '20636F6C6C656374696F6E73222C6C696E653A742E67656F6D6574726965732E5F5F6C696E655F5F7D292C61286529297D2929297D2C506F6C79676F6E3A66756E6374696F6E2874297B682874292C702874292C7528742C22636F6F7264696E61746573';
wwv_flow_imp.g_varchar2_table(932) := '222C22617272617922297C7C6C28742E636F6F7264696E617465732C224C696E65617252696E67222C32297C7C6C6528742C6E297D2C4D756C7469506F6C79676F6E3A66756E6374696F6E2874297B682874292C702874292C7528742C22636F6F726469';
wwv_flow_imp.g_varchar2_table(933) := '6E61746573222C22617272617922297C7C6C28742E636F6F7264696E617465732C224C696E65617252696E67222C33297C7C6C6528742C6E297D7D2C673D4F626A6563742E6B6579732866292E726564756365282866756E6374696F6E28742C65297B72';
wwv_flow_imp.g_varchar2_table(934) := '657475726E20745B652E746F4C6F7765724361736528295D3D652C747D292C7B7D293B72657475726E226F626A65637422213D747970656F6620747C7C6E756C6C3D3D743F286E2E70757368287B6D6573736167653A2254686520726F6F74206F662061';
wwv_flow_imp.g_varchar2_table(935) := '2047656F4A534F4E206F626A656374206D75737420626520616E206F626A6563742E222C6C696E653A307D292C6E293A28612874292C6E2E666F7245616368282866756E6374696F6E2874297B287B7D292E6861734F776E50726F70657274792E63616C';
wwv_flow_imp.g_varchar2_table(936) := '6C28742C226C696E6522292626766F696420303D3D3D742E6C696E65262664656C65746520742E6C696E657D29292C6E297D7D3B7661722070653D7B68696E743A66756E6374696F6E28742C65297B766172206E2C723D5B5D3B696628226F626A656374';
wwv_flow_imp.g_varchar2_table(937) := '223D3D747970656F662074296E3D743B656C73657B69662822737472696E6722213D747970656F6620742972657475726E5B7B6D6573736167653A22457870656374656420737472696E67206F72206F626A65637420617320696E707574222C6C696E65';
wwv_flow_imp.g_varchar2_table(938) := '3A307D5D3B7472797B6E3D61652E70617273652874297D63617463682874297B766172206F3D742E6D6573736167652E6D61746368282F6C696E6520285C642B292F293B72657475726E5B7B6C696E653A7061727365496E74286F5B315D2C3130292D31';
wwv_flow_imp.g_varchar2_table(939) := '2C6D6573736167653A742E6D6573736167652C6572726F723A747D5D7D7D72657475726E20723D722E636F6E6361742868652E68696E74286E2C6529297D7D2C64653D7B506F6C79676F6E3A422C4C696E65537472696E673A562C506F696E743A442C4D';
wwv_flow_imp.g_varchar2_table(940) := '756C7469506F6C79676F6E3A4A2C4D756C74694C696E65537472696E673A4A2C4D756C7469506F696E743A4A7D3B66756E6374696F6E20666528742C65297B72657475726E20652E6D6F6465733D682C652E6765744665617475726549647341743D6675';
wwv_flow_imp.g_varchar2_table(941) := '6E6374696F6E2865297B72657475726E20432E636C69636B287B706F696E743A657D2C6E756C6C2C74292E6D6170282866756E6374696F6E2874297B72657475726E20742E70726F706572746965732E69647D29297D2C652E67657453656C6563746564';
wwv_flow_imp.g_varchar2_table(942) := '4964733D66756E6374696F6E28297B72657475726E20742E73746F72652E67657453656C656374656449647328297D2C652E67657453656C65637465643D66756E6374696F6E28297B72657475726E7B747970653A6C2E464541545552455F434F4C4C45';
wwv_flow_imp.g_varchar2_table(943) := '4354494F4E2C66656174757265733A742E73746F72652E67657453656C656374656449647328292E6D6170282866756E6374696F6E2865297B72657475726E20742E73746F72652E6765742865297D29292E6D6170282866756E6374696F6E2874297B72';
wwv_flow_imp.g_varchar2_table(944) := '657475726E20742E746F47656F4A534F4E28297D29297D7D2C652E67657453656C6563746564506F696E74733D66756E6374696F6E28297B72657475726E7B747970653A6C2E464541545552455F434F4C4C454354494F4E2C66656174757265733A742E';
wwv_flow_imp.g_varchar2_table(945) := '73746F72652E67657453656C6563746564436F6F7264696E6174657328292E6D6170282866756E6374696F6E2874297B72657475726E7B747970653A6C2E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A6C';
wwv_flow_imp.g_varchar2_table(946) := '2E504F494E542C636F6F7264696E617465733A742E636F6F7264696E617465737D7D7D29297D7D2C652E7365743D66756E6374696F6E286E297B696628766F696420303D3D3D6E2E747970657C7C6E2E74797065213D3D6C2E464541545552455F434F4C';
wwv_flow_imp.g_varchar2_table(947) := '4C454354494F4E7C7C2141727261792E69734172726179286E2E666561747572657329297468726F77206E6577204572726F722822496E76616C69642046656174757265436F6C6C656374696F6E22293B76617220723D742E73746F72652E6372656174';
wwv_flow_imp.g_varchar2_table(948) := '6552656E646572426174636828292C6F3D742E73746F72652E676574416C6C49647328292E736C69636528292C693D652E616464286E292C613D6E657720532869293B72657475726E286F3D6F2E66696C746572282866756E6374696F6E2874297B7265';
wwv_flow_imp.g_varchar2_table(949) := '7475726E21612E6861732874297D2929292E6C656E6774682626652E64656C657465286F292C7228292C697D2C652E6164643D66756E6374696F6E2865297B766172206E3D70652E68696E7428652C7B707265636973696F6E5761726E696E673A21317D';
wwv_flow_imp.g_varchar2_table(950) := '292E66696C746572282866756E6374696F6E2874297B72657475726E226D65737361676522213D3D742E6C6576656C7D29293B6966286E2E6C656E677468297468726F77206E6577204572726F72286E5B305D2E6D657373616765293B76617220723D4A';
wwv_flow_imp.g_varchar2_table(951) := '534F4E2E7061727365284A534F4E2E737472696E6769667928767428652929292E66656174757265732E6D6170282866756E6374696F6E2865297B696628652E69643D652E69647C7C5528292C6E756C6C3D3D3D652E67656F6D65747279297468726F77';
wwv_flow_imp.g_varchar2_table(952) := '206E6577204572726F722822496E76616C69642067656F6D657472793A206E756C6C22293B696628766F696420303D3D3D742E73746F72652E67657428652E6964297C7C742E73746F72652E67657428652E6964292E74797065213D3D652E67656F6D65';
wwv_flow_imp.g_varchar2_table(953) := '7472792E74797065297B766172206E3D64655B652E67656F6D657472792E747970655D3B696628766F696420303D3D3D6E297468726F77206E6577204572726F722822496E76616C69642067656F6D6574727920747970653A20222B652E67656F6D6574';
wwv_flow_imp.g_varchar2_table(954) := '72792E747970652B222E22293B76617220723D6E6577206E28742C65293B742E73746F72652E6164642872297D656C73657B766172206F3D742E73746F72652E67657428652E6964293B6F2E70726F706572746965733D652E70726F706572746965732C';
wwv_flow_imp.g_varchar2_table(955) := '4874286F2E676574436F6F7264696E6174657328292C652E67656F6D657472792E636F6F7264696E61746573297C7C6F2E696E636F6D696E67436F6F72647328652E67656F6D657472792E636F6F7264696E61746573297D72657475726E20652E69647D';
wwv_flow_imp.g_varchar2_table(956) := '29293B72657475726E20742E73746F72652E72656E64657228292C727D2C652E6765743D66756E6374696F6E2865297B766172206E3D742E73746F72652E6765742865293B6966286E2972657475726E206E2E746F47656F4A534F4E28297D2C652E6765';
wwv_flow_imp.g_varchar2_table(957) := '74416C6C3D66756E6374696F6E28297B72657475726E7B747970653A6C2E464541545552455F434F4C4C454354494F4E2C66656174757265733A742E73746F72652E676574416C6C28292E6D6170282866756E6374696F6E2874297B72657475726E2074';
wwv_flow_imp.g_varchar2_table(958) := '2E746F47656F4A534F4E28297D29297D7D2C652E64656C6574653D66756E6374696F6E286E297B72657475726E20742E73746F72652E64656C657465286E2C7B73696C656E743A21307D292C652E6765744D6F64652829213D3D682E4449524543545F53';
wwv_flow_imp.g_varchar2_table(959) := '454C4543547C7C742E73746F72652E67657453656C656374656449647328292E6C656E6774683F742E73746F72652E72656E64657228293A742E6576656E74732E6368616E67654D6F646528682E53494D504C455F53454C4543542C766F696420302C7B';
wwv_flow_imp.g_varchar2_table(960) := '73696C656E743A21307D292C657D2C652E64656C657465416C6C3D66756E6374696F6E28297B72657475726E20742E73746F72652E64656C65746528742E73746F72652E676574416C6C49647328292C7B73696C656E743A21307D292C652E6765744D6F';
wwv_flow_imp.g_varchar2_table(961) := '646528293D3D3D682E4449524543545F53454C4543543F742E6576656E74732E6368616E67654D6F646528682E53494D504C455F53454C4543542C766F696420302C7B73696C656E743A21307D293A742E73746F72652E72656E64657228292C657D2C65';
wwv_flow_imp.g_varchar2_table(962) := '2E6368616E67654D6F64653D66756E6374696F6E286E2C72297B72657475726E20766F696420303D3D3D72262628723D7B7D292C6E3D3D3D682E53494D504C455F53454C4543542626652E6765744D6F646528293D3D3D682E53494D504C455F53454C45';
wwv_flow_imp.g_varchar2_table(963) := '43543F286F3D722E666561747572654964737C7C5B5D2C693D742E73746F72652E67657453656C656374656449647328292C6F2E6C656E6774683D3D3D692E6C656E67746826264A534F4E2E737472696E67696679286F2E6D6170282866756E6374696F';
wwv_flow_imp.g_varchar2_table(964) := '6E2874297B72657475726E20747D29292E736F72742829293D3D3D4A534F4E2E737472696E6769667928692E6D6170282866756E6374696F6E2874297B72657475726E20747D29292E736F72742829293F653A28742E73746F72652E73657453656C6563';
wwv_flow_imp.g_varchar2_table(965) := '74656428722E666561747572654964732C7B73696C656E743A21307D292C742E73746F72652E72656E64657228292C6529293A6E3D3D3D682E4449524543545F53454C4543542626652E6765744D6F646528293D3D3D682E4449524543545F53454C4543';
wwv_flow_imp.g_varchar2_table(966) := '542626722E6665617475726549643D3D3D742E73746F72652E67657453656C656374656449647328295B305D3F653A28742E6576656E74732E6368616E67654D6F6465286E2C722C7B73696C656E743A21307D292C65293B766172206F2C697D2C652E67';
wwv_flow_imp.g_varchar2_table(967) := '65744D6F64653D66756E6374696F6E28297B72657475726E20742E6576656E74732E6765744D6F646528297D2C652E74726173683D66756E6374696F6E28297B72657475726E20742E6576656E74732E7472617368287B73696C656E743A21307D292C65';
wwv_flow_imp.g_varchar2_table(968) := '7D2C652E636F6D62696E6546656174757265733D66756E6374696F6E28297B72657475726E20742E6576656E74732E636F6D62696E654665617475726573287B73696C656E743A21307D292C657D2C652E756E636F6D62696E6546656174757265733D66';
wwv_flow_imp.g_varchar2_table(969) := '756E6374696F6E28297B72657475726E20742E6576656E74732E756E636F6D62696E654665617475726573287B73696C656E743A21307D292C657D2C652E7365744665617475726550726F70657274793D66756E6374696F6E286E2C722C6F297B726574';
wwv_flow_imp.g_varchar2_table(970) := '75726E20742E73746F72652E7365744665617475726550726F7065727479286E2C722C6F292C657D2C657D7661722067653D66756E6374696F6E28742C65297B766172206E3D7B6F7074696F6E733A743D66756E6374696F6E2874297B766F696420303D';
wwv_flow_imp.g_varchar2_table(971) := '3D3D74262628743D7B7D293B76617220653D512874293B72657475726E20742E636F6E74726F6C737C7C28652E636F6E74726F6C733D7B7D292C21313D3D3D742E646973706C6179436F6E74726F6C7344656661756C743F652E636F6E74726F6C733D51';
wwv_flow_imp.g_varchar2_table(972) := '2871742C742E636F6E74726F6C73293A652E636F6E74726F6C733D512859742C742E636F6E74726F6C73292C28653D51287A742C6529292E7374796C65733D577428652E7374796C65732C22636F6C6422292E636F6E63617428577428652E7374796C65';
wwv_flow_imp.g_varchar2_table(973) := '732C22686F742229292C657D2874297D3B653D6665286E2C65292C6E2E6170693D653B76617220723D6E74286E293B72657475726E20652E6F6E4164643D722E6F6E4164642C652E6F6E52656D6F76653D722E6F6E52656D6F76652C652E74797065733D';
wwv_flow_imp.g_varchar2_table(974) := '632C652E6F7074696F6E733D742C657D3B66756E6374696F6E2079652874297B676528742C74686973297D72657475726E2079652E6D6F6465733D4A742C79657D29293B0A2F2F2320736F757263654D617070696E6755524C3D6D6170626F782D676C2D';
wwv_flow_imp.g_varchar2_table(975) := '647261772E6A732E6D61700A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(2085023356319617001)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_file_name=>'mapbox-gl-draw.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '0A2F2A204F766572726964652064656661756C7420636F6E74726F6C207374796C65202A2F0A2E6D6170626F782D676C2D647261775F6374726C2D626F74746F6D2D6C6566742C0A2E6D6170626F782D676C2D647261775F6374726C2D746F702D6C6566';
wwv_flow_imp.g_varchar2_table(2) := '74207B0A20206D617267696E2D6C6566743A303B0A2020626F726465722D7261646975733A30203470782034707820303B0A7D0A2E6D6170626F782D676C2D647261775F6374726C2D746F702D72696768742C0A2E6D6170626F782D676C2D647261775F';
wwv_flow_imp.g_varchar2_table(3) := '6374726C2D626F74746F6D2D7269676874207B0A20206D617267696E2D72696768743A303B0A2020626F726465722D7261646975733A34707820302030203470783B0A7D0A2E6D6170626F782D676C2D647261775F6374726C2D64726177207B0A202062';
wwv_flow_imp.g_varchar2_table(4) := '61636B67726F756E642D636F6C6F723A7267626128302C302C302C302E3735293B0A2020626F726465722D636F6C6F723A7267626128302C302C302C302E39293B0A7D0A2E6D6170626F782D676C2D647261775F6374726C2D64726177203E2062757474';
wwv_flow_imp.g_varchar2_table(5) := '6F6E207B0A2020626F726465722D636F6C6F723A7267626128302C302C302C302E39293B0A2020636F6C6F723A72676261283235352C3235352C3235352C302E35293B0A202077696474683A333070783B0A20206865696768743A333070783B0A7D0A2E';
wwv_flow_imp.g_varchar2_table(6) := '6D6170626F782D676C2D647261775F6374726C2D64726177203E20627574746F6E3A686F766572207B0A20206261636B67726F756E642D636F6C6F723A7267626128302C302C302C302E3835293B0A2020636F6C6F723A72676261283235352C3235352C';
wwv_flow_imp.g_varchar2_table(7) := '3235352C302E3735293B0A7D0A2E6D6170626F782D676C2D647261775F6374726C2D64726177203E20627574746F6E2E6163746976652C0A2E6D6170626F782D676C2D647261775F6374726C2D64726177203E20627574746F6E2E6163746976653A686F';
wwv_flow_imp.g_varchar2_table(8) := '766572207B0A20206261636B67726F756E642D636F6C6F723A7267626128302C302C302C302E3935293B0A2020636F6C6F723A236666663B0A7D0A2E6D6170626F782D676C2D647261775F6374726C2D647261772D62746E207B0A20206261636B67726F';
wwv_flow_imp.g_varchar2_table(9) := '756E642D7265706561743A206E6F2D7265706561743B0A20206261636B67726F756E642D706F736974696F6E3A2063656E7465723B0A7D0A2E6D6170626F782D676C2D647261775F706F696E74207B0A20206261636B67726F756E642D696D6167653A20';
wwv_flow_imp.g_varchar2_table(10) := '75726C28646174613A696D6167652F7376672B786D6C3B6261736536342C5044393462577767646D567963326C76626A30694D5334774969426C626D4E765A476C755A7A3069565652474C54676949484E305957356B59577876626D5539496D3576496A';
wwv_flow_imp.g_varchar2_table(11) := '382B50484E325A794167494868746247357A4F6D526A50534A6F644852774F6938766348567962433576636D63765A474D765A57786C6257567564484D764D5334784C7949674943423462577875637A706A597A30696148523063446F764C324E795A57';
wwv_flow_imp.g_varchar2_table(12) := '463061585A6C593239746257397563793576636D6376626E4D6A49694167494868746247357A4F6E4A6B5A6A30696148523063446F764C336433647935334D793576636D63764D546B354F5338774D6938794D6931795A47597463336C75644746344C57';
wwv_flow_imp.g_varchar2_table(13) := '357A497949674943423462577875637A707A646D6339496D6830644841364C79393364336375647A4D7562334A6E4C7A49774D44417663335A6E49694167494868746247357A50534A6F644852774F693876643364334C6E637A4C6D39795A7938794D44';
wwv_flow_imp.g_varchar2_table(14) := '41774C334E325A7949674943423462577875637A707A623252706347396B615430696148523063446F764C334E765A476C77623252704C6E4E7664584A6A5A575A76636D646C4C6D356C64433945564551766332396B615842765A476B744D43356B6447';
wwv_flow_imp.g_varchar2_table(15) := '51694943416765473173626E4D366157357263324E6863475539496D6830644841364C793933643363756157357263324E686347557562334A6E4C3235686257567A6347466A5A584D766157357263324E68634755694943416764326C6B64476739496A';
wwv_flow_imp.g_varchar2_table(16) := '4977496941674947686C6157646F644430694D6A416949434167646D6C6C64304A76654430694D43417749444977494449774969416749476C6B50534A7A646D63784F5445324E794967494342325A584A7A61573975505349784C6A4569494341676157';
wwv_flow_imp.g_varchar2_table(17) := '357263324E6863475536646D567963326C76626A30694D4334354D53746B5A585A6C62437476633368745A573531494849784D6A6B784D5349674943427A623252706347396B6154706B62324E755957316C50534A7459584A725A58497563335A6E496A';
wwv_flow_imp.g_varchar2_table(18) := '34674944786B5A575A7A49434167494342705A4430695A47566D637A45354D545935496941765069416750484E765A476C77623252704F6D35686257566B646D6C6C647941674943416761575139496D4A686332556949434167494342775957646C5932';
wwv_flow_imp.g_varchar2_table(19) := '39736233493949694E6D5A6D5A6D5A6D5969494341674943426962334A6B5A584A6A62327876636A3069497A59324E6A59324E6949674943416749474A76636D526C636D397759574E7064486B39496A45754D4349674943416749476C7561334E6A5958';
wwv_flow_imp.g_varchar2_table(20) := '426C4F6E42685A3256766347466A61585235505349774C6A41694943416749434270626D747A593246775A5470775957646C633268685A4739335053497949694167494341676157357263324E6863475536656D3976625430694D545969494341674943';
wwv_flow_imp.g_varchar2_table(21) := '4270626D747A593246775A54706A654430694D5451754D5459304D6A557A49694167494341676157357263324E686347553659336B39496A67754F4467314E7A49694943416749434270626D747A593246775A54706B62324E316257567564433131626D';
wwv_flow_imp.g_varchar2_table(22) := '6C30637A3069634867694943416749434270626D747A593246775A54706A64584A795A5735304C5778686557567950534A7359586C6C636A4569494341674943427A614739335A334A705A4430695A6D4673633255694943416749434231626D6C30637A';
wwv_flow_imp.g_varchar2_table(23) := '3069634867694943416749434270626D747A593246775A5470336157356B6233637464326C6B64476739496A45794F4441694943416749434270626D747A593246775A5470336157356B62336374614756705A326830505349334E544569494341674943';
wwv_flow_imp.g_varchar2_table(24) := '4270626D747A593246775A5470336157356B62336374654430694D6A413449694167494341676157357263324E686347553664326C755A4739334C586B39496A45354D4349674943416749476C7561334E6A5958426C4F6E6470626D5276647931745958';
wwv_flow_imp.g_varchar2_table(25) := '687062576C365A575139496A41694943416749434270626D747A593246775A547076596D706C59335174626D396B5A584D39496E52796457556950694167494341386157357263324E68634755365A334A705A43416749434167494342306558426C5053';
wwv_flow_imp.g_varchar2_table(26) := '4A346557647961575169494341674943416749476C6B50534A6E636D6C6B4D546B334D5455694943382B494341384C334E765A476C77623252704F6D35686257566B646D6C6C647A3467494478745A5852685A474630595341674943416761575139496D';
wwv_flow_imp.g_varchar2_table(27) := '316C6447466B595852684D546B784E7A49695069416749434138636D526D4F6C4A45526A3467494341674943413859324D365632397961794167494341674943416749484A6B5A6A7068596D393164443069496A346749434167494341674944786B597A';
wwv_flow_imp.g_varchar2_table(28) := '706D62334A745958512B615731685A32557663335A6E4B336874624477765A474D365A6D3979625746305069416749434167494341675047526A4F6E52356347556749434167494341674943416749484A6B5A6A70795A584E7664584A6A5A5430696148';
wwv_flow_imp.g_varchar2_table(29) := '523063446F764C334231636D777562334A6E4C32526A4C32526A62576C306558426C4C314E3061577873535731685A3255694943382B4943416749434167494341385A474D3664476C30624755674C7A346749434167494341384C324E6A4F6C6476636D';
wwv_flow_imp.g_varchar2_table(30) := '732B4943416749447776636D526D4F6C4A45526A34674944777662575630595752686447452B494341385A794167494341676157357263324E6863475536624746695A577739496B786865575679494445694943416749434270626D747A593246775A54';
wwv_flow_imp.g_varchar2_table(31) := '706E636D3931634731765A475539496D786865575679496941674943416761575139496D7868655756794D53496749434167494852795957357A5A6D39796254306964484A68626E4E735958526C4B4441734C5445774D7A49754D7A59794D696B695069';
wwv_flow_imp.g_varchar2_table(32) := '4167494341386347463061434167494341674943427A64486C735A5430695932397362334936497A41774D4441774D44746A62476C774C584A3162475536626D3975656D5679627A746B61584E77624746354F6D6C7562476C755A547476646D56795A6D';
wwv_flow_imp.g_varchar2_table(33) := '7876647A703261584E70596D786C4F335A7063326C696157787064486B36646D6C7A61574A735A5474766347466A615852354F6A453761584E7662474630615739754F6D46316447383762576C344C574A735A57356B4C5731765A475536626D39796257';
wwv_flow_imp.g_varchar2_table(34) := '46734F324E76624739794C576C756447567963473973595852706232343663314A48516A746A6232787663693170626E526C636E427662474630615739754C575A706248526C636E4D3662476C755A574679556B64434F334E7662476C6B4C574E766247';
wwv_flow_imp.g_varchar2_table(35) := '39794F694D774D4441774D44413763323973615751746233426859326C3065546F784F325A7062477736497A41774D4441774D44746D615778734C57397759574E7064486B364D54746D615778734C584A31624755365A585A6C626D396B5A44747A6448';
wwv_flow_imp.g_varchar2_table(36) := '4A7661325536626D39755A54747A64484A766132557464326C6B644767364D6A747A64484A766132557462476C755A574E6863447079623356755A44747A64484A766132557462476C755A57707661573436636D3931626D5137633352796232746C4C57';
wwv_flow_imp.g_varchar2_table(37) := '31706447567962476C74615851364E44747A64484A76613255745A47467A61474679636D46354F6D3576626D5537633352796232746C4C575268633268765A6D5A7A5A5851364D44747A64484A76613255746233426859326C3065546F784F323168636D';
wwv_flow_imp.g_varchar2_table(38) := '746C636A70756232356C4F324E76624739794C584A6C626D526C636D6C755A7A7068645852764F326C745957646C4C584A6C626D526C636D6C755A7A7068645852764F334E6F5958426C4C584A6C626D526C636D6C755A7A7068645852764F33526C6548';
wwv_flow_imp.g_varchar2_table(39) := '5174636D56755A4756796157356E4F6D4631644738375A573568596D786C4C574A685932746E636D3931626D513659574E6A64573131624746305A53496749434167494341675A4430696253417A4E6977784D4451774C6A4D324D6A4967597941325A53';
wwv_flow_imp.g_varchar2_table(40) := '30324C444D754D7A41354D7941744E5334354F4467324D5449734D5441674C5455754F5467344E6A45794C444577494441734D4341744E5334354F5467334E7A59734C5459754E6A5934494330324C6A41784D544D304E5377744F5334354E7A63794943';
wwv_flow_imp.g_varchar2_table(41) := '30774C6A41784D6A55334C43307A4C6A4D774F5449674D6934324E5459314E7A59734C5459754D44417A4F5341314C6A6B324E5463354D6977744E6934774D6A493349444D754D7A41354D5467354C4330774C6A41784F5341324C6A41774F4467304C44';
wwv_flow_imp.g_varchar2_table(42) := '49754E6A51314D6941324C6A417A4D7A6B354D6977314C6A6B314E444D69494341674943416749476C6B50534A775958526F4D5449314E6A4569494341674943416749476C7561334E6A5958426C4F6D4E76626D356C593352766369316A64584A325958';
wwv_flow_imp.g_varchar2_table(43) := '5231636D5539496A4169494341674943416749484E765A476C77623252704F6D35765A4756306558426C637A306959324E7A63324D694943382B49434167494478775958526F494341674943416749484E306557786C50534A6A62327876636A6F6A4D44';
wwv_flow_imp.g_varchar2_table(44) := '41774D4441774F324E7361584174636E56735A547075623235365A584A764F3252706333427359586B36615735736157356C4F3239325A584A6D624739334F6E5A7063326C6962475537646D6C7A61574A7062476C306554703261584E70596D786C4F32';
wwv_flow_imp.g_varchar2_table(45) := '397759574E7064486B364D54747063323973595852706232343659585630627A747461586774596D786C626D51746257396B5A54707562334A74595777375932397362334974615735305A584A776232786864476C76626A707A556B64434F324E766247';
wwv_flow_imp.g_varchar2_table(46) := '39794C576C75644756796347397359585270623234745A6D6C7364475679637A70736157356C59584A535230493763323973615751745932397362334936497A41774D4441774D44747A623278705A4331766347466A615852354F6A45375A6D6C736244';
wwv_flow_imp.g_varchar2_table(47) := '6F6A5A6D5A6D5A6D5A6D4F325A70624777746233426859326C3065546F784F325A7062477774636E56735A54706C646D56756232526B4F334E30636D39725A5470756232356C4F334E30636D39725A5331336157523061446F794F334E30636D39725A53';
wwv_flow_imp.g_varchar2_table(48) := '31736157356C593246774F6E4A766457356B4F334E30636D39725A5331736157356C616D3970626A7079623356755A44747A64484A766132557462576C305A584A736157317064446F304F334E30636D39725A53316B59584E6F59584A7959586B36626D';
wwv_flow_imp.g_varchar2_table(49) := '39755A54747A64484A76613255745A47467A6147396D5A6E4E6C64446F774F334E30636D39725A5331766347466A615852354F6A453762574679613256794F6D3576626D55375932397362334974636D56755A4756796157356E4F6D4631644738376157';
wwv_flow_imp.g_varchar2_table(50) := '31685A325574636D56755A4756796157356E4F6D4631644738376332686863475574636D56755A4756796157356E4F6D46316447383764475634644331795A57356B5A584A70626D633659585630627A746C626D466962475574596D466A613264796233';
wwv_flow_imp.g_varchar2_table(51) := '56755A44706859324E31625856735958526C49694167494341674943426B50534A7449444D304C6A41774D4445784E5377784D4451774C6A4D324D6A4967597941744E5755744E6977794C6A49774E6A49674C544D754F546B794E54497A4C4463754D44';
wwv_flow_imp.g_varchar2_table(52) := '41774D5341744D7934354F5449314D6A4D734E7934774D444178494441734D4341744D7934354F546B794F5445734C5451754E7A63344E7941744E4334774D4463324E7A6B734C5459754F5467304F5341744D4334774D4467304C4330794C6A49774E6A';
wwv_flow_imp.g_varchar2_table(53) := '49674D5334334E7A45774F4449734C5451754D4441794E79417A4C6A6B334E7A4D784C4330304C6A41784E544D674D6934794D4459794D5377744D4334774D544D674E4334774D4459774D7A63734D5334334E6A4D31494451754D4449794E7A63334C44';
wwv_flow_imp.g_varchar2_table(54) := '4D754F5459354E794967494341674943416761575139496E4268644767784D6A55324D79496749434167494341676157357263324E686347553659323975626D566A644739794C574E31636E5A68644856795A5430694D43496749434167494341676332';
wwv_flow_imp.g_varchar2_table(55) := '396B615842765A476B36626D396B5A5852356347567A50534A6A59324E7A597949674C7A346749434167504842686447676749434167494341676333523562475539496D4E76624739794F694D774D4441774D44413759327870634331796457786C4F6D';
wwv_flow_imp.g_varchar2_table(56) := '3576626E706C636D38375A476C7A6347786865547070626D7870626D553762335A6C636D5A7362336336646D6C7A61574A735A54743261584E70596D6C73615852354F6E5A7063326C69624755376233426859326C3065546F784F326C7A623278686447';
wwv_flow_imp.g_varchar2_table(57) := '6C76626A7068645852764F32317065433169624756755A4331746232526C4F6D3576636D31686244746A6232787663693170626E526C636E427662474630615739754F6E4E53523049375932397362334974615735305A584A776232786864476C766269';
wwv_flow_imp.g_varchar2_table(58) := '316D615778305A584A7A4F6D7870626D5668636C4A48516A747A623278705A43316A62327876636A6F6A4D4441774D4441774F334E7662476C6B4C57397759574E7064486B364D54746D615778734F694D774D4441774D4441375A6D6C73624331766347';
wwv_flow_imp.g_varchar2_table(59) := '466A615852354F6A45375A6D6C73624331796457786C4F6D56325A5735765A475137633352796232746C4F6D3576626D5537633352796232746C4C5864705A48526F4F6A4937633352796232746C4C577870626D566A59584136636D3931626D51376333';
wwv_flow_imp.g_varchar2_table(60) := '52796232746C4C577870626D567162326C754F6E4A766457356B4F334E30636D39725A5331746158526C636D787062576C304F6A5137633352796232746C4C57526863326868636E4A68655470756232356C4F334E30636D39725A53316B59584E6F6232';
wwv_flow_imp.g_varchar2_table(61) := '5A6D633256304F6A4137633352796232746C4C57397759574E7064486B364D54747459584A725A584936626D39755A54746A62327876636931795A57356B5A584A70626D633659585630627A74706257466E5A5331795A57356B5A584A70626D63365958';
wwv_flow_imp.g_varchar2_table(62) := '5630627A747A614746775A5331795A57356B5A584A70626D633659585630627A74305A5868304C584A6C626D526C636D6C755A7A7068645852764F32567559574A735A53316959574E725A334A766457356B4F6D466A5933567464577868644755694943';
wwv_flow_imp.g_varchar2_table(63) := '41674943416749475139496B30674F5334354E6A59334F5459354C4445774D5451754D7A59794D694244494459754E6A55334E5467774F5377784D4445304C6A4D344D53417A4C6A6B344E7A517A4C4445774D5463754D4463324E4341304C4445774D6A';
wwv_flow_imp.g_varchar2_table(64) := '41754D7A67314E69426A494441754D4445794E5459354C444D754D7A41354D6941324C6A41784D5463784F5377344C6A6B334E6A59674E6934774D5445334D546B734F4334354E7A5932494441734D4341314C6A6B344F4449344E7977744E5334324F54';
wwv_flow_imp.g_varchar2_table(65) := '4133494455754F5467344D6A67784C433035494777674D4377744D4334774E445567597941744D4334774D6A55784E5377744D79347A4D446B78494330794C6A63794E4441784E4377744E5334354E7A5178494330324C6A417A4D7A49774D7A45734C54';
wwv_flow_imp.g_varchar2_table(66) := '55754F5455314D534236494730674D4334774D446B334E79777949474D674D6934794D4459794D4459784C4330774C6A41784D7941304C6A41774E6A59354D7A45734D5334334E6A4932494451754D44497A4E444D7A4D53777A4C6A6B324F4467676243';
wwv_flow_imp.g_varchar2_table(67) := '41774C4441754D444D7849474D674C54566C4C5459734D6934794D4459794943307A4C6A6B354D6A45344F4377324943307A4C6A6B354D6A45344F437732494441734D4341744D7934354F546B304D6A51734C544D754E7A63344D6941744E4334774D44';
wwv_flow_imp.g_varchar2_table(68) := '63344D5449734C5455754F5467304E4341744D4334774D4467304C4330794C6A49774E6A49674D5334334E7A417A4D7A51314C4330304C6A41774D79417A4C6A6B334E6A55324D6A55734C5451754D4445314E6942364969416749434167494342705A44';
wwv_flow_imp.g_varchar2_table(69) := '306963474630614445794E545934496941674943416749434270626D747A593246775A54706A623235755A574E306233497459335679646D463064584A6C5053497749694167494341674943427A623252706347396B615470756232526C64486C775A58';
wwv_flow_imp.g_varchar2_table(70) := '4D39496D4E7A59334E6A59324E6A63324E7A597949674C7A346749434167504842686447676749434167494341676333523562475539496D397759574E7064486B364D54746D615778734F694D774D4441774D4441375A6D6C73624331766347466A6158';
wwv_flow_imp.g_varchar2_table(71) := '52354F6A4537633352796232746C4F6D3576626D5537633352796232746C4C5864705A48526F4F6A4937633352796232746C4C577870626D566A59584136596E56306444747A64484A766132557462476C755A57707661573436596D56325A5777376333';
wwv_flow_imp.g_varchar2_table(72) := '52796232746C4C5731706447567962476C74615851364E44747A64484A76613255745A47467A61474679636D46354F6D3576626D5537633352796232746C4C575268633268765A6D5A7A5A5851364D44747A64484A76613255746233426859326C306554';
wwv_flow_imp.g_varchar2_table(73) := '6F784F323168636D746C636A70756232356C49694167494341674943426B50534A4E4944457749444967517941324C6A59344E6A49354D694179494451674E4334324F44597A494451674F434244494451674D5445754D7A457A4E7941784D4341784E79';
wwv_flow_imp.g_varchar2_table(74) := '41784D4341784E794244494445774944453349444532494445784C6A4D784D7A63674D5459674F43424449444532494451754E6A67324D7941784D79347A4D544D334D4467674D6941784D43417949486F67545341784D43413049454D674D5449754D44';
wwv_flow_imp.g_varchar2_table(75) := '63784D445934494451674D544D754E7A55674E5334324E7A67354944457A4C6A6331494463754E7A5567517941784D7934334E5341354C6A49774E544D794E7A67674D5445754F544D784D5445674D5445754E6A51304D7A6B7A494445774C6A677A4D44';
wwv_flow_imp.g_varchar2_table(76) := '41334F4341784D79424D49446B754D5459354F5449784F5341784D794244494467754D4459344F446B774D7941784D5334324E44517A4F544D674E6934794E5341354C6A49774E544D794E7A67674E6934794E5341334C6A633149454D674E6934794E53';
wwv_flow_imp.g_varchar2_table(77) := '41314C6A59334F446B674E7934354D6A67354D7A49674E4341784D43413049486F67496941674943416749434230636D467563325A76636D3039496E52795957357A624746305A5367774C4445774D7A49754D7A59794D696B6949434167494341674947';
wwv_flow_imp.g_varchar2_table(78) := '6C6B50534A775958526F4D54637A4D4455694943382B494341384C32632B5043397A646D632B293B0A7D0A2E6D6170626F782D676C2D647261775F706F6C79676F6E207B0A20206261636B67726F756E642D696D6167653A2075726C28646174613A696D';
wwv_flow_imp.g_varchar2_table(79) := '6167652F7376672B786D6C3B6261736536342C5044393462577767646D567963326C76626A30694D5334774969426C626D4E765A476C755A7A3069565652474C54676949484E305957356B59577876626D5539496D3576496A382B50484E325A79416749';
wwv_flow_imp.g_varchar2_table(80) := '4868746247357A4F6D526A50534A6F644852774F6938766348567962433576636D63765A474D765A57786C6257567564484D764D5334784C7949674943423462577875637A706A597A30696148523063446F764C324E795A57463061585A6C5932397462';
wwv_flow_imp.g_varchar2_table(81) := '57397563793576636D6376626E4D6A49694167494868746247357A4F6E4A6B5A6A30696148523063446F764C336433647935334D793576636D63764D546B354F5338774D6938794D6931795A47597463336C75644746344C57357A497949674943423462';
wwv_flow_imp.g_varchar2_table(82) := '577875637A707A646D6339496D6830644841364C79393364336375647A4D7562334A6E4C7A49774D44417663335A6E49694167494868746247357A50534A6F644852774F693876643364334C6E637A4C6D39795A7938794D4441774C334E325A79496749';
wwv_flow_imp.g_varchar2_table(83) := '43423462577875637A707A623252706347396B615430696148523063446F764C334E765A476C77623252704C6E4E7664584A6A5A575A76636D646C4C6D356C64433945564551766332396B615842765A476B744D43356B64475169494341676547317362';
wwv_flow_imp.g_varchar2_table(84) := '6E4D366157357263324E6863475539496D6830644841364C793933643363756157357263324E686347557562334A6E4C3235686257567A6347466A5A584D766157357263324E68634755694943416764326C6B64476739496A4977496941674947686C61';
wwv_flow_imp.g_varchar2_table(85) := '57646F644430694D6A416949434167646D6C6C64304A76654430694D43417749444977494449774969416749476C6B50534A7A646D63784F5445324E794967494342325A584A7A61573975505349784C6A4569494341676157357263324E686347553664';
wwv_flow_imp.g_varchar2_table(86) := '6D567963326C76626A30694D4334354D53746B5A585A6C62437476633368745A573531494849784D6A6B784D5349674943427A623252706347396B6154706B62324E755957316C50534A7A63585668636D557563335A6E496A34674944786B5A575A7A49';
wwv_flow_imp.g_varchar2_table(87) := '434167494342705A4430695A47566D637A45354D545935496941765069416750484E765A476C77623252704F6D35686257566B646D6C6C647941674943416761575139496D4A686332556949434167494342775957646C593239736233493949694E6D5A';
wwv_flow_imp.g_varchar2_table(88) := '6D5A6D5A6D5969494341674943426962334A6B5A584A6A62327876636A3069497A59324E6A59324E6949674943416749474A76636D526C636D397759574E7064486B39496A45754D4349674943416749476C7561334E6A5958426C4F6E42685A32567663';
wwv_flow_imp.g_varchar2_table(89) := '47466A61585235505349774C6A41694943416749434270626D747A593246775A5470775957646C633268685A4739335053497949694167494341676157357263324E6863475536656D3976625430694D5445754D7A457A4E7A4134496941674943416761';
wwv_flow_imp.g_varchar2_table(90) := '57357263324E686347553659336739496A45784C6A59344D54597A4E4349674943416749476C7561334E6A5958426C4F6D4E35505349354C6A49344E5463784E444D694943416749434270626D747A593246775A54706B62324E31625756756443313162';
wwv_flow_imp.g_varchar2_table(91) := '6D6C30637A3069634867694943416749434270626D747A593246775A54706A64584A795A5735304C5778686557567950534A7359586C6C636A4569494341674943427A614739335A334A705A44306964484A315A53496749434167494856756158527A50';
wwv_flow_imp.g_varchar2_table(92) := '534A77654349674943416749476C7561334E6A5958426C4F6E6470626D52766479313361575230614430694D5449344D4349674943416749476C7561334E6A5958426C4F6E6470626D52766479316F5A576C6E61485139496A63314D5349674943416749';
wwv_flow_imp.g_varchar2_table(93) := '476C7561334E6A5958426C4F6E6470626D5276647931345053497749694167494341676157357263324E686347553664326C755A4739334C586B39496A497A49694167494341676157357263324E686347553664326C755A4739334C57316865476C7461';
wwv_flow_imp.g_varchar2_table(94) := '58706C5A4430694D4349674943416749476C7561334E6A5958426C4F6D3969616D566A644331756232526C637A306964484A315A53492B4943416749447870626D747A593246775A54706E636D6C6B49434167494341674948523563475539496E68355A';
wwv_flow_imp.g_varchar2_table(95) := '334A705A434967494341674943416761575139496D6479615751784F5463784E5349674C7A3467494477766332396B615842765A476B36626D46745A57523261575633506941675047316C6447466B5958526849434167494342705A4430696257563059';
wwv_flow_imp.g_varchar2_table(96) := '575268644745784F5445334D69492B49434167494478795A475936556B524750694167494341674944786A597A705862334A72494341674943416749434167636D526D4F6D466962335630505349695069416749434167494341675047526A4F6D5A7663';
wwv_flow_imp.g_varchar2_table(97) := '6D3168644435706257466E5A53397A646D6372654731735043396B597A706D62334A745958512B4943416749434167494341385A474D3664486C775A534167494341674943416749434167636D526D4F6E4A6C63323931636D4E6C50534A6F644852774F';
wwv_flow_imp.g_varchar2_table(98) := '6938766348567962433576636D63765A474D765A474E746158523563475576553352706247784A6257466E5A5349674C7A346749434167494341674944786B597A7030615852735A53417650694167494341674944777659324D3656323979617A346749';
wwv_flow_imp.g_varchar2_table(99) := '434167504339795A475936556B524750694167504339745A5852685A474630595434674944786E4943416749434270626D747A593246775A54707359574A6C62443069544746355A5849674D5349674943416749476C7561334E6A5958426C4F6D647962';
wwv_flow_imp.g_varchar2_table(100) := '3356776257396B5A543069624746355A58496949434167494342705A443069624746355A584978496941674943416764484A68626E4E6D62334A7450534A30636D4675633278686447556F4D4377744D54417A4D69347A4E6A49794B53492B4943416749';
wwv_flow_imp.g_varchar2_table(101) := '4478775958526F494341674943416749476C7561334E6A5958426C4F6D4E76626D356C593352766369316A64584A3259585231636D5539496A4169494341674943416749484E306557786C50534A6A62327876636A6F6A4D4441774D4441774F32527063';
wwv_flow_imp.g_varchar2_table(102) := '33427359586B36615735736157356C4F3239325A584A6D624739334F6E5A7063326C6962475537646D6C7A61574A7062476C306554703261584E70596D786C4F325A7062477736497A41774D4441774D44746D615778734C57397759574E7064486B364D';
wwv_flow_imp.g_varchar2_table(103) := '54746D615778734C584A3162475536626D3975656D5679627A747A64484A7661325536626D39755A54747A64484A766132557464326C6B644767364D4334314F323168636D746C636A70756232356C4F32567559574A735A53316959574E725A334A7664';
wwv_flow_imp.g_varchar2_table(104) := '57356B4F6D466A593356746457786864475569494341674943416749475139496D30674E5377784D444D354C6A4D324D6A49674D437732494449734D6941324C4441674D6977744D6941774C433032494330794C433079494330324C4441676569427449';
wwv_flow_imp.g_varchar2_table(105) := '444D734D4341304C4441674D537778494441734E4341744D537778494330304C4441674C5445734C5445674D4377744E4342364969416749434167494342705A443069636D566A644463334F546369494341674943416749484E765A476C77623252704F';
wwv_flow_imp.g_varchar2_table(106) := '6D35765A4756306558426C637A306959324E6A59324E6A59324E6A59324E6A59324E6A59324E6A49694176506941674943413859326C795932786C494341674943416749484E306557786C50534A6A62327876636A6F6A4D4441774D4441774F32527063';
wwv_flow_imp.g_varchar2_table(107) := '33427359586B36615735736157356C4F3239325A584A6D624739334F6E5A7063326C6962475537646D6C7A61574A7062476C306554703261584E70596D786C4F325A7062477736497A41774D4441774D44746D615778734C57397759574E7064486B364D';
wwv_flow_imp.g_varchar2_table(108) := '54746D615778734C584A3162475536626D3975656D5679627A747A64484A7661325536626D39755A54747A64484A766132557464326C6B644767364D5334324D4441774D4441774D6A747459584A725A584936626D39755A54746C626D46696247557459';
wwv_flow_imp.g_varchar2_table(109) := '6D466A61326479623356755A44706859324E31625856735958526C4969416749434167494342705A443069634746306144517A4E6A5169494341674943416749474E345053493249694167494341674943426A655430694D5441304E69347A4E6A497949';
wwv_flow_imp.g_varchar2_table(110) := '69416749434167494342795053497949694176506941674943413859326C795932786C494341674943416749476C6B50534A775958526F4E444D324F43496749434167494341676333523562475539496D4E76624739794F694D774D4441774D4441375A';
wwv_flow_imp.g_varchar2_table(111) := '476C7A6347786865547070626D7870626D553762335A6C636D5A7362336336646D6C7A61574A735A54743261584E70596D6C73615852354F6E5A7063326C69624755375A6D6C7362446F6A4D4441774D4441774F325A70624777746233426859326C3065';
wwv_flow_imp.g_varchar2_table(112) := '546F784F325A7062477774636E56735A547075623235365A584A764F334E30636D39725A5470756232356C4F334E30636D39725A5331336157523061446F784C6A59774D4441774D4441794F323168636D746C636A70756232356C4F32567559574A735A';
wwv_flow_imp.g_varchar2_table(113) := '53316959574E725A334A766457356B4F6D466A593356746457786864475569494341674943416749474E34505349784E434967494341674943416759336B39496A45774E4459754D7A59794D6949674943416749434167636A30694D6949674C7A346749';
wwv_flow_imp.g_varchar2_table(114) := '43416750474E70636D4E735A53416749434167494342705A443069634746306144517A4E7A4169494341674943416749484E306557786C50534A6A62327876636A6F6A4D4441774D4441774F3252706333427359586B36615735736157356C4F3239325A';
wwv_flow_imp.g_varchar2_table(115) := '584A6D624739334F6E5A7063326C6962475537646D6C7A61574A7062476C306554703261584E70596D786C4F325A7062477736497A41774D4441774D44746D615778734C57397759574E7064486B364D54746D615778734C584A3162475536626D397565';
wwv_flow_imp.g_varchar2_table(116) := '6D5679627A747A64484A7661325536626D39755A54747A64484A766132557464326C6B644767364D5334324D4441774D4441774D6A747459584A725A584936626D39755A54746C626D466962475574596D466A61326479623356755A44706859324E3162';
wwv_flow_imp.g_varchar2_table(117) := '5856735958526C49694167494341674943426A654430694E694967494341674943416759336B39496A45774D7A67754D7A59794D6949674943416749434167636A30694D6949674C7A34674943416750474E70636D4E735A534167494341674943427A64';
wwv_flow_imp.g_varchar2_table(118) := '486C735A5430695932397362334936497A41774D4441774D44746B61584E77624746354F6D6C7562476C755A547476646D56795A6D7876647A703261584E70596D786C4F335A7063326C696157787064486B36646D6C7A61574A735A54746D615778734F';
wwv_flow_imp.g_varchar2_table(119) := '694D774D4441774D4441375A6D6C73624331766347466A615852354F6A45375A6D6C73624331796457786C4F6D3576626E706C636D3837633352796232746C4F6D3576626D5537633352796232746C4C5864705A48526F4F6A45754E6A41774D4441774D';
wwv_flow_imp.g_varchar2_table(120) := '44493762574679613256794F6D3576626D55375A573568596D786C4C574A685932746E636D3931626D513659574E6A64573131624746305A534967494341674943416761575139496E4268644767304D7A637949694167494341674943426A654430694D';
wwv_flow_imp.g_varchar2_table(121) := '545169494341674943416749474E35505349784D444D344C6A4D324D6A4969494341674943416749484939496A49694943382B494341384C32632B5043397A646D632B293B0A7D0A2E6D6170626F782D676C2D647261775F6C696E65207B0A2020626163';
wwv_flow_imp.g_varchar2_table(122) := '6B67726F756E642D696D6167653A2075726C28646174613A696D6167652F7376672B786D6C3B6261736536342C5044393462577767646D567963326C76626A30694D5334774969426C626D4E765A476C755A7A3069565652474C54676949484E30595735';
wwv_flow_imp.g_varchar2_table(123) := '6B59577876626D5539496D3576496A382B50484E325A794167494868746247357A4F6D526A50534A6F644852774F6938766348567962433576636D63765A474D765A57786C6257567564484D764D5334784C7949674943423462577875637A706A597A30';
wwv_flow_imp.g_varchar2_table(124) := '696148523063446F764C324E795A57463061585A6C593239746257397563793576636D6376626E4D6A49694167494868746247357A4F6E4A6B5A6A30696148523063446F764C336433647935334D793576636D63764D546B354F5338774D6938794D6931';
wwv_flow_imp.g_varchar2_table(125) := '795A47597463336C75644746344C57357A497949674943423462577875637A707A646D6339496D6830644841364C79393364336375647A4D7562334A6E4C7A49774D44417663335A6E49694167494868746247357A50534A6F644852774F693876643364';
wwv_flow_imp.g_varchar2_table(126) := '334C6E637A4C6D39795A7938794D4441774C334E325A7949674943423462577875637A707A623252706347396B615430696148523063446F764C334E765A476C77623252704C6E4E7664584A6A5A575A76636D646C4C6D356C6443394556455176633239';
wwv_flow_imp.g_varchar2_table(127) := '6B615842765A476B744D43356B644751694943416765473173626E4D366157357263324E6863475539496D6830644841364C793933643363756157357263324E686347557562334A6E4C3235686257567A6347466A5A584D766157357263324E68634755';
wwv_flow_imp.g_varchar2_table(128) := '694943416764326C6B64476739496A4977496941674947686C6157646F644430694D6A416949434167646D6C6C64304A76654430694D43417749444977494449774969416749476C6B50534A7A646D63784F5445324E794967494342325A584A7A615739';
wwv_flow_imp.g_varchar2_table(129) := '75505349784C6A4569494341676157357263324E6863475536646D567963326C76626A30694D4334354D53746B5A585A6C62437476633368745A573531494849784D6A6B784D5349674943427A623252706347396B6154706B62324E755957316C50534A';
wwv_flow_imp.g_varchar2_table(130) := '736157356C4C6E4E325A79492B494341385A47566D637941674943416761575139496D526C5A6E4D784F5445324F5349674C7A34674944787A623252706347396B615470755957316C5A485A705A5863674943416749476C6B50534A6959584E6C496941';
wwv_flow_imp.g_varchar2_table(131) := '67494341676347466E5A574E76624739795053496A5A6D5A6D5A6D5A6D4969416749434167596D39795A475679593239736233493949694D324E6A59324E6A5969494341674943426962334A6B5A584A766347466A61585235505349784C6A4169494341';
wwv_flow_imp.g_varchar2_table(132) := '6749434270626D747A593246775A5470775957646C6233426859326C30655430694D43347749694167494341676157357263324E68634755366347466E5A584E6F59575276647A30694D6949674943416749476C7561334E6A5958426C4F6E7076623230';
wwv_flow_imp.g_varchar2_table(133) := '39496A453249694167494341676157357263324E686347553659336739496A45794C6A67354F4463334E5349674943416749476C7561334E6A5958426C4F6D4E35505349354C6A55344F5441784E5449694943416749434270626D747A593246775A5470';
wwv_flow_imp.g_varchar2_table(134) := '6B62324E316257567564433131626D6C30637A3069634867694943416749434270626D747A593246775A54706A64584A795A5735304C5778686557567950534A7359586C6C636A4569494341674943427A614739335A334A705A44306964484A315A5349';
wwv_flow_imp.g_varchar2_table(135) := '6749434167494856756158527A50534A77654349674943416749476C7561334E6A5958426C4F6E6470626D52766479313361575230614430694D5449344D4349674943416749476C7561334E6A5958426C4F6E6470626D52766479316F5A576C6E614851';
wwv_flow_imp.g_varchar2_table(136) := '39496A63314D5349674943416749476C7561334E6A5958426C4F6E6470626D5276647931345053497749694167494341676157357263324E686347553664326C755A4739334C586B39496A497A49694167494341676157357263324E686347553664326C';
wwv_flow_imp.g_varchar2_table(137) := '755A4739334C57316865476C746158706C5A4430694D4349674943416749476C7561334E6A5958426C4F6D3969616D566A644331756232526C637A306964484A315A53492B4943416749447870626D747A593246775A54706E636D6C6B49434167494341';
wwv_flow_imp.g_varchar2_table(138) := '674948523563475539496E68355A334A705A434967494341674943416761575139496D6479615751784F5463784E5349674C7A3467494477766332396B615842765A476B36626D46745A57523261575633506941675047316C6447466B59585268494341';
wwv_flow_imp.g_varchar2_table(139) := '67494342705A4430696257563059575268644745784F5445334D69492B49434167494478795A475936556B524750694167494341674944786A597A705862334A72494341674943416749434167636D526D4F6D4669623356305053496950694167494341';
wwv_flow_imp.g_varchar2_table(140) := '67494341675047526A4F6D5A76636D3168644435706257466E5A53397A646D6372654731735043396B597A706D62334A745958512B4943416749434167494341385A474D3664486C775A534167494341674943416749434167636D526D4F6E4A6C633239';
wwv_flow_imp.g_varchar2_table(141) := '31636D4E6C50534A6F644852774F6938766348567962433576636D63765A474D765A474E746158523563475576553352706247784A6257466E5A5349674C7A346749434167494341674944786B597A7030615852735A5341765069416749434167494477';
wwv_flow_imp.g_varchar2_table(142) := '7659324D3656323979617A346749434167504339795A475936556B524750694167504339745A5852685A474630595434674944786E4943416749434270626D747A593246775A54707359574A6C62443069544746355A5849674D5349674943416749476C';
wwv_flow_imp.g_varchar2_table(143) := '7561334E6A5958426C4F6D6479623356776257396B5A543069624746355A58496949434167494342705A443069624746355A584978496941674943416764484A68626E4E6D62334A7450534A30636D4675633278686447556F4D4377744D54417A4D6934';
wwv_flow_imp.g_varchar2_table(144) := '7A4E6A49794B53492B49434167494478775958526F494341674943416749484E306557786C50534A6A62327876636A6F6A4D4441774D4441774F3252706333427359586B36615735736157356C4F3239325A584A6D624739334F6E5A7063326C69624755';
wwv_flow_imp.g_varchar2_table(145) := '37646D6C7A61574A7062476C306554703261584E70596D786C4F325A7062477736497A41774D4441774D44746D615778734C57397759574E7064486B364D54746D615778734C584A3162475536626D3975656D5679627A747A64484A7661325536626D39';
wwv_flow_imp.g_varchar2_table(146) := '755A54747A64484A766132557464326C6B644767364D7A747459584A725A584936626D39755A54746C626D466962475574596D466A61326479623356755A44706859324E31625856735958526C49694167494341674943426B50534A744944457A4C6A55';
wwv_flow_imp.g_varchar2_table(147) := '734D54417A4E5334344E6A497949474D674C5445754D7A67774E7A45794C4441674C5449754E5377784C6A45784F544D674C5449754E5377794C6A55674D4377774C6A4D794D4467674D4334774E4459784E4377774C6A59794E4451674D4334784E5459';
wwv_flow_imp.g_varchar2_table(148) := '794E5377774C6A6B774E6A4D67624341744D7934334E53777A4C6A633149474D674C5441754D6A67784F444D324C4330774C6A45784D4449674C5441754E5467314E4449784C4330774C6A45314E6A4D674C5441754F5441324D6A55734C5441754D5455';
wwv_flow_imp.g_varchar2_table(149) := '324D7941744D53347A4F4441334D5449734D4341744D6934314C4445754D5445354D7941744D6934314C4449754E5341774C4445754D7A67774E7941784C6A45784F5449344F4377794C6A55674D6934314C4449754E5341784C6A4D344D4463784D6977';
wwv_flow_imp.g_varchar2_table(150) := '77494449754E5377744D5334784D546B7A494449754E5377744D693431494441734C5441754D7A49774F4341744D4334774E4459784E4377744D4334324D6A5130494330774C6A45314E6A49314C4330774C6A6B774E6A49676243417A4C6A63314C4330';
wwv_flow_imp.g_varchar2_table(151) := '7A4C6A633149474D674D4334794F4445344D7A59734D4334784D544178494441754E5467314E4449784C4441754D5455324D6941774C6A6B774E6A49314C4441754D5455324D6941784C6A4D344D4463784D697777494449754E5377744D5334784D546B';
wwv_flow_imp.g_varchar2_table(152) := '7A494449754E5377744D693431494441734C5445754D7A67774E7941744D5334784D546B794F4467734C5449754E5341744D6934314C4330794C6A556765694967494341674943416761575139496E4A6C593351324E4459334969416749434167494342';
wwv_flow_imp.g_varchar2_table(153) := '70626D747A593246775A54706A623235755A574E306233497459335679646D463064584A6C5053497749694176506941675043396E506A777663335A6E50673D3D293B0A7D0A2E6D6170626F782D676C2D647261775F7472617368207B0A20206261636B';
wwv_flow_imp.g_varchar2_table(154) := '67726F756E642D696D6167653A2075726C28646174613A696D6167652F7376672B786D6C3B6261736536342C5044393462577767646D567963326C76626A30694D5334774969426C626D4E765A476C755A7A3069565652474C54676949484E305957356B';
wwv_flow_imp.g_varchar2_table(155) := '59577876626D5539496D3576496A382B50484E325A794167494868746247357A4F6D526A50534A6F644852774F6938766348567962433576636D63765A474D765A57786C6257567564484D764D5334784C7949674943423462577875637A706A597A3069';
wwv_flow_imp.g_varchar2_table(156) := '6148523063446F764C324E795A57463061585A6C593239746257397563793576636D6376626E4D6A49694167494868746247357A4F6E4A6B5A6A30696148523063446F764C336433647935334D793576636D63764D546B354F5338774D6938794D693179';
wwv_flow_imp.g_varchar2_table(157) := '5A47597463336C75644746344C57357A497949674943423462577875637A707A646D6339496D6830644841364C79393364336375647A4D7562334A6E4C7A49774D44417663335A6E49694167494868746247357A50534A6F644852774F69387664336433';
wwv_flow_imp.g_varchar2_table(158) := '4C6E637A4C6D39795A7938794D4441774C334E325A7949674943423462577875637A707A623252706347396B615430696148523063446F764C334E765A476C77623252704C6E4E7664584A6A5A575A76636D646C4C6D356C64433945564551766332396B';
wwv_flow_imp.g_varchar2_table(159) := '615842765A476B744D43356B644751694943416765473173626E4D366157357263324E6863475539496D6830644841364C793933643363756157357263324E686347557562334A6E4C3235686257567A6347466A5A584D766157357263324E6863475569';
wwv_flow_imp.g_varchar2_table(160) := '4943416764326C6B64476739496A4977496941674947686C6157646F644430694D6A41694943416761575139496E4E325A7A55334D7A676949434167646D567963326C76626A30694D5334784969416749476C7561334E6A5958426C4F6E5A6C636E4E70';
wwv_flow_imp.g_varchar2_table(161) := '62323439496A41754F5445725A4756325A57777262334E3462575675645342794D5449354D544569494341676332396B615842765A476B365A47396A626D46745A54306964484A686332677563335A6E4969416749485A705A58644362336739496A4167';
wwv_flow_imp.g_varchar2_table(162) := '4D4341794D4341794D43492B494341385A47566D637941674943416761575139496D526C5A6E4D314E7A5177496941765069416750484E765A476C77623252704F6D35686257566B646D6C6C647941674943416761575139496D4A686332556949434167';
wwv_flow_imp.g_varchar2_table(163) := '494342775957646C593239736233493949694E6D5A6D5A6D5A6D5969494341674943426962334A6B5A584A6A62327876636A3069497A59324E6A59324E6949674943416749474A76636D526C636D397759574E7064486B39496A45754D43496749434167';
wwv_flow_imp.g_varchar2_table(164) := '49476C7561334E6A5958426C4F6E42685A3256766347466A61585235505349774C6A41694943416749434270626D747A593246775A5470775957646C633268685A4739335053497949694167494341676157357263324E6863475536656D397662543069';
wwv_flow_imp.g_varchar2_table(165) := '4D6A49754E6A49334E44453349694167494341676157357263324E686347553659336739496A45794C6A45794F4445344E4349674943416749476C7561334E6A5958426C4F6D4E35505349344C6A67304E6A457A4D4463694943416749434270626D747A';
wwv_flow_imp.g_varchar2_table(166) := '593246775A54706B62324E316257567564433131626D6C30637A3069634867694943416749434270626D747A593246775A54706A64584A795A5735304C5778686557567950534A7359586C6C636A4569494341674943427A614739335A334A705A443069';
wwv_flow_imp.g_varchar2_table(167) := '64484A315A5349674943416749476C7561334E6A5958426C4F6E6470626D52766479313361575230614430694D54417A4D7949674943416749476C7561334E6A5958426C4F6E6470626D52766479316F5A576C6E61485139496A63314D53496749434167';
wwv_flow_imp.g_varchar2_table(168) := '49476C7561334E6A5958426C4F6E6470626D527664793134505349794D4349674943416749476C7561334E6A5958426C4F6E6470626D527664793135505349794D7949674943416749476C7561334E6A5958426C4F6E6470626D52766479317459586870';
wwv_flow_imp.g_varchar2_table(169) := '62576C365A575139496A41694943416749434270626D747A593246775A54707A626D46774C584E7462323930614331756232526C637A306964484A315A5349674943416749476C7561334E6A5958426C4F6D3969616D566A644331756232526C637A3069';
wwv_flow_imp.g_varchar2_table(170) := '64484A315A53492B4943416749447870626D747A593246775A54706E636D6C6B49434167494341674948523563475539496E68355A334A705A434967494341674943416761575139496D6479615751314E7A513249694167494341674943426C6258427A';
wwv_flow_imp.g_varchar2_table(171) := '6347466A6157356E5053493149694167494341674943423261584E70596D786C50534A30636E566C49694167494341674943426C626D46696247566B50534A30636E566C49694167494341674943427A626D4677646D6C7A61574A735A57647961575273';
wwv_flow_imp.g_varchar2_table(172) := '6157356C6332397562486B39496E5279645755694943382B494341384C334E765A476C77623252704F6D35686257566B646D6C6C647A3467494478745A5852685A474630595341674943416761575139496D316C6447466B595852684E5463304D79492B';
wwv_flow_imp.g_varchar2_table(173) := '49434167494478795A475936556B524750694167494341674944786A597A705862334A72494341674943416749434167636D526D4F6D466962335630505349695069416749434167494341675047526A4F6D5A76636D3168644435706257466E5A53397A';
wwv_flow_imp.g_varchar2_table(174) := '646D6372654731735043396B597A706D62334A745958512B4943416749434167494341385A474D3664486C775A534167494341674943416749434167636D526D4F6E4A6C63323931636D4E6C50534A6F644852774F6938766348567962433576636D6376';
wwv_flow_imp.g_varchar2_table(175) := '5A474D765A474E746158523563475576553352706247784A6257466E5A5349674C7A346749434167494341674944786B597A7030615852735A53417650694167494341674944777659324D3656323979617A346749434167504339795A475936556B5247';
wwv_flow_imp.g_varchar2_table(176) := '50694167504339745A5852685A474630595434674944786E4943416749434270626D747A593246775A54707359574A6C62443069544746355A5849674D5349674943416749476C7561334E6A5958426C4F6D6479623356776257396B5A54306962474635';
wwv_flow_imp.g_varchar2_table(177) := '5A58496949434167494342705A443069624746355A584978496941674943416764484A68626E4E6D62334A7450534A30636D4675633278686447556F4D4377744D54417A4D69347A4E6A49794B53492B49434167494478775958526F4943416749434167';
wwv_flow_imp.g_varchar2_table(178) := '49484E306557786C50534A6A62327876636A6F6A4D4441774D4441774F3252706333427359586B36615735736157356C4F3239325A584A6D624739334F6E5A7063326C6962475537646D6C7A61574A7062476C306554703261584E70596D786C4F325A70';
wwv_flow_imp.g_varchar2_table(179) := '62477736497A41774D4441774D44746D615778734C57397759574E7064486B364D54746D615778734C584A3162475536626D3975656D5679627A747A64484A7661325536626D39755A54747A64484A766132557464326C6B644767364D4334354F546B35';
wwv_flow_imp.g_varchar2_table(180) := '4F546B344D6A747459584A725A584936626D39755A54746C626D466962475574596D466A61326479623356755A44706859324E31625856735958526C49694167494341674943426B50534A74494445774C4445774D7A55754E7A63304D79426A49433077';
wwv_flow_imp.g_varchar2_table(181) := '4C6A63344E446B794E544D734F4755744E4341744D5334304F5459344D7A63324C4441754E4459774E6941744D5334344D6A417A4D5449314C4445754D5463314F4342734943307A4C6A45334F5459344E7A55734D4341744D537778494441734D534178';
wwv_flow_imp.g_varchar2_table(182) := '4D697777494441734C5445674C5445734C5445674C544D754D5463354E6A67344C444167597941744D43347A4D6A4D304E7A55734C5441754E7A45314D6941744D5334774D7A557A4F4463734C5445754D546331494330784C6A67794D444D784D697774';
wwv_flow_imp.g_varchar2_table(183) := '4D5334784E7A553449486F67625341744E5377304C6A55344E7A6B674D43773349474D674D437778494445734D6941794C444967624341324C444167597941784C4441674D6977744D5341794C433079494777674D4377744E7941744D69777749444173';
wwv_flow_imp.g_varchar2_table(184) := '4E533431494330784C6A55734D4341774C4330314C6A55674C544D734D4341774C4455754E5341744D5334314C4441674D4377744E53343149486F69494341674943416749476C6B50534A795A574E304D6A517A4F533033496941674943416749434270';
wwv_flow_imp.g_varchar2_table(185) := '626D747A593246775A54706A623235755A574E306233497459335679646D463064584A6C5053497749694167494341674943427A623252706347396B615470756232526C64486C775A584D39496D4E6A59324E6A59324E6A59324E6A59324E6A59324E6A';
wwv_flow_imp.g_varchar2_table(186) := '59324E6A59324E6A59324D694943382B494341384C32632B5043397A646D632B293B0A7D0A0A2E6D6170626F782D676C2D647261775F756E636F6D62696E65207B0A20206261636B67726F756E642D696D6167653A2075726C28646174613A696D616765';
wwv_flow_imp.g_varchar2_table(187) := '2F7376672B786D6C3B6261736536342C5044393462577767646D567963326C76626A30694D5334774969426C626D4E765A476C755A7A3069565652474C54676949484E305957356B59577876626D5539496D3576496A382B436A77684C53306751334A6C';
wwv_flow_imp.g_varchar2_table(188) := '5958526C5A4342336158526F49456C7561334E6A5958426C4943686F644852774F693876643364334C6D6C7561334E6A5958426C4C6D39795A7938704943307450676F4B50484E325A776F674943423462577875637A706B597A30696148523063446F76';
wwv_flow_imp.g_varchar2_table(189) := '4C334231636D777562334A6E4C32526A4C3256735A57316C626E527A4C7A45754D53386943694167494868746247357A4F6D4E6A50534A6F644852774F69387659334A6C59585270646D566A623231746232357A4C6D39795A79397563794D6943694167';
wwv_flow_imp.g_varchar2_table(190) := '494868746247357A4F6E4A6B5A6A30696148523063446F764C336433647935334D793576636D63764D546B354F5338774D6938794D6931795A47597463336C75644746344C57357A4979494B4943416765473173626E4D3663335A6E50534A6F64485277';
wwv_flow_imp.g_varchar2_table(191) := '4F693876643364334C6E637A4C6D39795A7938794D4441774C334E325A79494B4943416765473173626E4D39496D6830644841364C79393364336375647A4D7562334A6E4C7A49774D44417663335A6E49676F674943423462577875637A703462476C75';
wwv_flow_imp.g_varchar2_table(192) := '617A30696148523063446F764C336433647935334D793576636D63764D546B354F53393462476C756179494B4943416765473173626E4D366332396B615842765A476B39496D6830644841364C79397A623252706347396B6153357A623356795932566D';
wwv_flow_imp.g_varchar2_table(193) := '62334A6E5A5335755A585176524652454C334E765A476C77623252704C5441755A48526B49676F674943423462577875637A7070626D747A593246775A5430696148523063446F764C33643364793570626D747A593246775A533576636D6376626D4674';
wwv_flow_imp.g_varchar2_table(194) := '5A584E7759574E6C63793970626D747A593246775A53494B4943416764326C6B64476739496A497749676F674943426F5A576C6E61485139496A497749676F67494342705A44306963335A6E4E54637A4F43494B49434167646D567963326C76626A3069';
wwv_flow_imp.g_varchar2_table(195) := '4D53347849676F6749434270626D747A593246775A5470325A584A7A61573975505349774C6A6B78494849784D7A63794E53494B494341676332396B615842765A476B365A47396A626D46745A5430696457356A623231696157356C4C6E4E325A79492B';
wwv_flow_imp.g_varchar2_table(196) := '436941675047526C5A6E4D4B49434167494342705A4430695A47566D637A55334E44416950676F674943416750477870626D5668636B6479595752705A573530436941674943416749434270626D747A593246775A54706A623278735A574E3050534A68';
wwv_flow_imp.g_varchar2_table(197) := '6248646865584D6943694167494341674943423462476C75617A706F636D566D5053496A62476C755A57467952334A685A476C6C626E51304D54417A49676F67494341674943416761575139496D7870626D5668636B6479595752705A5735304E444534';
wwv_flow_imp.g_varchar2_table(198) := '4E43494B494341674943416749476479595752705A5735305657357064484D39496E567A5A584A546347466A5A55397556584E6C49676F67494341674943416765444539496A4D774D444D694369416749434167494342354D5430694D54416943694167';
wwv_flow_imp.g_varchar2_table(199) := '49434167494342344D6A30694D7A41784E79494B494341674943416749486B79505349784D43494B494341674943416749476479595752705A57353056484A68626E4E6D62334A7450534A30636D4675633278686447556F4D5377794C6A59784E7A4534';
wwv_flow_imp.g_varchar2_table(200) := '4E7A526C4C5459704969417650676F674943416750477870626D5668636B6479595752705A573530436941674943416749434270626D747A593246775A54706A623278735A574E3050534A686248646865584D694369416749434167494342705A443069';
wwv_flow_imp.g_varchar2_table(201) := '62476C755A57467952334A685A476C6C626E51304D54417A496A344B494341674943416750484E306233414B4943416749434167494341676333523562475539496E4E30623341745932397362334936497A41774D4441774D44747A644739774C573977';
wwv_flow_imp.g_varchar2_table(202) := '59574E7064486B364D5473694369416749434167494341674947396D5A6E4E6C644430694D43494B49434167494341674943416761575139496E4E30623341304D5441314969417650676F6749434167494341386333527663416F674943416749434167';
wwv_flow_imp.g_varchar2_table(203) := '4943427A64486C735A543069633352766343316A62327876636A6F6A4D4441774D4441774F334E30623341746233426859326C3065546F774F79494B49434167494341674943416762325A6D633256305053497849676F67494341674943416749434270';
wwv_flow_imp.g_varchar2_table(204) := '5A44306963335276634451784D4463694943382B43694167494341384C327870626D5668636B6479595752705A57353050676F67494477765A47566D637A344B494341386332396B615842765A476B36626D46745A575232615756334369416749434167';
wwv_flow_imp.g_varchar2_table(205) := '61575139496D4A686332556943694167494341676347466E5A574E76624739795053496A5A6D5A6D5A6D5A6D49676F674943416749474A76636D526C636D4E76624739795053496A4E6A59324E6A593249676F674943416749474A76636D526C636D3977';
wwv_flow_imp.g_varchar2_table(206) := '59574E7064486B39496A45754D43494B4943416749434270626D747A593246775A5470775957646C6233426859326C30655430694D43347749676F674943416749476C7561334E6A5958426C4F6E42685A32567A6147466B62336339496A496943694167';
wwv_flow_imp.g_varchar2_table(207) := '494341676157357263324E6863475536656D3976625430694D5445754D7A457A4E7A413449676F674943416749476C7561334E6A5958426C4F6D4E34505349744D5441754D6A637A4F54513249676F674943416749476C7561334E6A5958426C4F6D4E35';
wwv_flow_imp.g_varchar2_table(208) := '505349324C6A6B7A4D444D304E43494B4943416749434270626D747A593246775A54706B62324E316257567564433131626D6C30637A30696348676943694167494341676157357263324E686347553659335679636D56756443317359586C6C636A3069';
wwv_flow_imp.g_varchar2_table(209) := '624746355A58497849676F674943416749484E6F6233646E636D6C6B50534A6D5957787A5A53494B4943416749434270626D747A593246775A5470336157356B6233637464326C6B64476739496A49774E7A676943694167494341676157357263324E68';
wwv_flow_imp.g_varchar2_table(210) := '6347553664326C755A4739334C57686C6157646F644430694D5441314E43494B4943416749434270626D747A593246775A5470336157356B62336374654430694F54417749676F674943416749476C7561334E6A5958426C4F6E6470626D527664793135';
wwv_flow_imp.g_varchar2_table(211) := '505349794F54596943694167494341676157357263324E686347553664326C755A4739334C57316865476C746158706C5A4430694D43494B494341674943427A614739335A3356705A47567A50534A6D5957787A5A53494B4943416749434270626D747A';
wwv_flow_imp.g_varchar2_table(212) := '593246775A54707A626D46774C574A6962336739496E52796457556943694167494341676157357263324E6863475536596D4A76654331775958526F637A306964484A315A53494B4943416749434270626D747A593246775A547069596D39344C573576';
wwv_flow_imp.g_varchar2_table(213) := '5A47567A50534A30636E566C49676F674943416749476C7561334E6A5958426C4F6D3969616D566A644331775958526F637A306964484A315A53494B4943416749434270626D747A593246775A547076596D706C59335174626D396B5A584D39496E5279';
wwv_flow_imp.g_varchar2_table(214) := '6457556943694167494341676157357263324E6863475536633235686343317A6257397664476774626D396B5A584D39496E52796457556943694167494341676157357263324E686347553663323568634331766447686C636E4D39496D5A6862484E6C';
wwv_flow_imp.g_varchar2_table(215) := '49676F674943416749476C7561334E6A5958426C4F6E4E7559584174626D396B5A584D39496D5A6862484E6C496A344B4943416749447870626D747A593246775A54706E636D6C6B4369416749434167494342306558426C50534A346557647961575169';
wwv_flow_imp.g_varchar2_table(216) := '4369416749434167494342705A4430695A334A705A4455334E44596943694167494341674943426C6258427A6347466A6157356E5053497949676F674943416749434167646D6C7A61574A735A54306964484A315A53494B494341674943416749475675';
wwv_flow_imp.g_varchar2_table(217) := '59574A735A575139496E52796457556943694167494341674943427A626D4677646D6C7A61574A735A576479615752736157356C6332397562486B39496E52796457556943694167494341674943427A6347466A6157356E654430694D43343163486769';
wwv_flow_imp.g_varchar2_table(218) := '43694167494341674943427A6347466A6157356E655430694D4334316348676943694167494341674943426A62327876636A3069497A41774D44426D5A69494B49434167494341674947397759574E7064486B39496A41754D4455344F44497A4E544D69';
wwv_flow_imp.g_varchar2_table(219) := '4943382B436941675043397A623252706347396B615470755957316C5A485A705A58632B436941675047316C6447466B59585268436941674943416761575139496D316C6447466B595852684E5463304D79492B4369416749434138636D526D4F6C4A45';
wwv_flow_imp.g_varchar2_table(220) := '526A344B494341674943416750474E6A4F6C6476636D734B494341674943416749434167636D526D4F6D4669623356305053496950676F6749434167494341674944786B597A706D62334A745958512B615731685A32557663335A6E4B33687462447776';
wwv_flow_imp.g_varchar2_table(221) := '5A474D365A6D39796257463050676F6749434167494341674944786B597A70306558426C43694167494341674943416749434167636D526D4F6E4A6C63323931636D4E6C50534A6F644852774F6938766348567962433576636D63765A474D765A474E74';
wwv_flow_imp.g_varchar2_table(222) := '6158523563475576553352706247784A6257466E5A5349674C7A344B4943416749434167494341385A474D3664476C306247552B5043396B597A7030615852735A54344B49434167494341675043396A597A705862334A7250676F674943416750433979';
wwv_flow_imp.g_varchar2_table(223) := '5A475936556B524750676F674944777662575630595752686447452B436941675047634B4943416749434270626D747A593246775A54707359574A6C62443069544746355A5849674D53494B4943416749434270626D747A593246775A54706E636D3931';
wwv_flow_imp.g_varchar2_table(224) := '634731765A475539496D78686557567949676F674943416749476C6B50534A7359586C6C636A4569436941674943416764484A68626E4E6D62334A7450534A30636D4675633278686447556F4D4377744D54417A4D69347A4E6A49794B53492B43694167';
wwv_flow_imp.g_varchar2_table(225) := '494341386347463061416F6749434167494341676333523562475539496D4E76624739794F694D774D4441774D44413759327870634331796457786C4F6D3576626E706C636D38375A476C7A6347786865547070626D7870626D553762335A6C636D5A73';
wwv_flow_imp.g_varchar2_table(226) := '62336336646D6C7A61574A735A54743261584E70596D6C73615852354F6E5A7063326C69624755376233426859326C3065546F784F326C7A6232786864476C76626A7068645852764F32317065433169624756755A4331746232526C4F6D3576636D3168';
wwv_flow_imp.g_varchar2_table(227) := '6244746A6232787663693170626E526C636E427662474630615739754F6E4E53523049375932397362334974615735305A584A776232786864476C766269316D615778305A584A7A4F6D7870626D5668636C4A48516A747A623278705A43316A62327876';
wwv_flow_imp.g_varchar2_table(228) := '636A6F6A4D4441774D4441774F334E7662476C6B4C57397759574E7064486B364D54746D615778734F694D774D4441774D4441375A6D6C73624331766347466A615852354F6A45375A6D6C73624331796457786C4F6D3576626E706C636D383763335279';
wwv_flow_imp.g_varchar2_table(229) := '6232746C4F6D3576626D5537633352796232746C4C5864705A48526F4F6A4937633352796232746C4C577870626D566A59584136596E56306444747A64484A766132557462476C755A5770766157343662576C305A584937633352796232746C4C573170';
wwv_flow_imp.g_varchar2_table(230) := '6447567962476C74615851364E44747A64484A76613255745A47467A61474679636D46354F6D3576626D5537633352796232746C4C575268633268765A6D5A7A5A5851364D44747A64484A76613255746233426859326C3065546F784F323168636D746C';
wwv_flow_imp.g_varchar2_table(231) := '636A70756232356C4F324E76624739794C584A6C626D526C636D6C755A7A7068645852764F326C745957646C4C584A6C626D526C636D6C755A7A7068645852764F334E6F5958426C4C584A6C626D526C636D6C755A7A7068645852764F33526C65485174';
wwv_flow_imp.g_varchar2_table(232) := '636D56755A4756796157356E4F6D4631644738375A573568596D786C4C574A685932746E636D3931626D513659574E6A64573131624746305A53494B494341674943416749475139496B30674D5449754D4441314F44553549444967517941784D533433';
wwv_flow_imp.g_varchar2_table(233) := '4E54417A4E694179494445784C6A51354E4459774E5341794C6A41354E7A45344E7941784D5334794F5467344D6A67674D6934794F5449354E6A6734494577674D5441754D7A41794E7A4D3049444D754D6A67354D4459794E53424449446B754F544578';
wwv_flow_imp.g_varchar2_table(234) := '4D5467774E43417A4C6A59344D4459794E6941354C6A6B784D5445344D4451674E43347A4D5445314E6A4531494445774C6A4D774D6A637A4E4341304C6A63774D7A45794E53424D494445784C6A4D774D6A637A4E4341314C6A63774D5445334D546B67';
wwv_flow_imp.g_varchar2_table(235) := '517941784D5334324F5451794F4467674E6934774F5449334D7A5530494445794C6A4D794D7A4935494459754D446B794E7A4D314E4341784D6934334D5451344E4451674E5334334D4445784E7A4535494577674D544D754E7A45774F544D3449445175';
wwv_flow_imp.g_varchar2_table(236) := '4E7A41314D4463344D534244494445304C6A45774D6A51354D5341304C6A4D784D7A55784E4459674D5451754D5441794E446B7849444D754E6A67794E5463354D5341784D7934334D5441354D7A67674D7934794F5445774D545532494577674D544975';
wwv_flow_imp.g_varchar2_table(237) := '4E7A45794F446B78494449754D6A6B794F5459344F434244494445794C6A55784E7A45784E4341794C6A41354E7A45344E7941784D6934794E6A457A4E546B674D6941784D6934774D4455344E546B674D694236494530674D5459754D4441784F54557A';
wwv_flow_imp.g_varchar2_table(238) := '494455754F546B304D5451774E694244494445314C6A63304E6A51324D7941314C6A6B354E4445304D4459674D5455754E446B774E6A6B79494459754D446B7A4D6A637A4E5341784E5334794F5451354D6A49674E6934794F446B774E6A493149457767';
wwv_flow_imp.g_varchar2_table(239) := '4D5451754D6A6B344F444934494463754D6A67314D5455324D6942444944457A4C6A6B774E7A49344F5341334C6A59334E6A637A4E4449674D544D754F5441334D6A6735494467754D7A41314E6A67334E7941784E4334794F5467344D6A67674F433432';
wwv_flow_imp.g_varchar2_table(240) := '4F5463794E6A5532494577674D5455754D6A6B324F44633149446B754E6A6B334D6A59314E694244494445314C6A59344F4451784E4341784D4334774F4467344E4451674D5459754D7A45354D7A6B34494445774C6A41344F4467304E4341784E693433';
wwv_flow_imp.g_varchar2_table(241) := '4D5441354D7A67674F5334324F5463794E6A5532494577674D5463754E7A41334D444D78494467754E7A41784D5463784F534244494445344C6A41354F4455334D5341344C6A4D774F5455354D7A6B674D5467754D446B344E546378494463754E6A6334';
wwv_flow_imp.g_varchar2_table(242) := '4E6A67334D7941784E7934334D4463774D7A45674E7934794F4463784D446B30494577674D5459754E7A41344F546730494459754D6A67354D4459794E534244494445324C6A55784D7A49784E5341324C6A41354D7A49334D7A55674D5459754D6A5533';
wwv_flow_imp.g_varchar2_table(243) := '4E44517A494455754F546B304D5451774E6941784E6934774D4445354E544D674E5334354F5451784E44413249486F67545341354944636751794134494463674F434134494467754E5341344C6A5567517941344C6A677A4D7A4D7A4D7941344C6A677A';
wwv_flow_imp.g_varchar2_table(244) := '4D7A4D674F53343149446B754E5341354C6A55674F533431494577674F433431494445774C6A5567517941344C6A55674D5441754E53413449444578494467754E5341784D53343149454D674F5341784D6941354C6A55674D5445754E5341354C6A5567';
wwv_flow_imp.g_varchar2_table(245) := '4D5445754E53424D494445774C6A55674D5441754E53424D494445784C6A55674D5445754E53424449444579494445794944457A494445794944457A49444578494577674D544D674E79424D49446B674E794236494530674E4334774E4467344D6A6778';
wwv_flow_imp.g_varchar2_table(246) := '494445774C6A41774D546B314D79424449444D754E7A6B7A4D7A41344E7941784D4334774D4445354E544D674D7934314D7A63314F446B78494445774C6A41354F5445794F53417A4C6A4D304D5463354E6A6B674D5441754D6A6B304F54497949457767';
wwv_flow_imp.g_varchar2_table(247) := '4D6934794F5467344D6A6778494445784C6A4D7A4E7A67354D534244494445754F5441334D6A517A4E7941784D5334334D6A6B304E7A59674D5334354D4463794E444D33494445794C6A4D324D444D324F4341794C6A49354F4467794F4445674D544975';
wwv_flow_imp.g_varchar2_table(248) := '4E7A55784F54557A494577674E7934794E4467774E445935494445334C6A63774D5445334D694244494463754E6A4D354E6A4D784D7941784F4334774F5449334E5463674F4334794E7A41314D6A55674D5467754D446B794E7A5533494467754E6A5979';
wwv_flow_imp.g_varchar2_table(249) := '4D5441354E4341784E7934334D4445784E7A4967544341354C6A63774E5441334F4445674D5459754E6A55344D6A417A49454D674D5441754D446B324E6A597A494445324C6A49324E6A59784F4341784D4334774F5459324E6A4D674D5455754E6A4D31';
wwv_flow_imp.g_varchar2_table(250) := '4E7A493249446B754E7A41314D4463344D5341784E5334794E4451784E444567544341304C6A63314E5467314F5451674D5441754D6A6B304F54497949454D674E4334314E6A41774E6A6379494445774C6A41354F5445794F5341304C6A4D774E444D30';
wwv_flow_imp.g_varchar2_table(251) := '4E7A55674D5441754D4441784F54557A494451754D4451344F4449344D5341784D4334774D4445354E544D6765694169436941674943416749434230636D467563325A76636D3039496E52795957357A624746305A5367774C4445774D7A49754D7A5979';
wwv_flow_imp.g_varchar2_table(252) := '4D696B694369416749434167494342705A443069636D566A64446B784F5467694943382B436941675043396E50676F384C334E325A7A344B293B0A7D0A2E6D6170626F782D676C2D647261775F636F6D62696E65207B0A20206261636B67726F756E642D';
wwv_flow_imp.g_varchar2_table(253) := '696D6167653A2075726C28646174613A696D6167652F7376672B786D6C3B6261736536342C5044393462577767646D567963326C76626A30694D5334774969426C626D4E765A476C755A7A3069565652474C54676949484E305957356B59577876626D55';
wwv_flow_imp.g_varchar2_table(254) := '39496D3576496A382B436A77684C53306751334A6C5958526C5A4342336158526F49456C7561334E6A5958426C4943686F644852774F693876643364334C6D6C7561334E6A5958426C4C6D39795A7938704943307450676F4B50484E325A776F67494342';
wwv_flow_imp.g_varchar2_table(255) := '3462577875637A706B597A30696148523063446F764C334231636D777562334A6E4C32526A4C3256735A57316C626E527A4C7A45754D53386943694167494868746247357A4F6D4E6A50534A6F644852774F69387659334A6C59585270646D566A623231';
wwv_flow_imp.g_varchar2_table(256) := '746232357A4C6D39795A79397563794D6943694167494868746247357A4F6E4A6B5A6A30696148523063446F764C336433647935334D793576636D63764D546B354F5338774D6938794D6931795A47597463336C75644746344C57357A4979494B494341';
wwv_flow_imp.g_varchar2_table(257) := '6765473173626E4D3663335A6E50534A6F644852774F693876643364334C6E637A4C6D39795A7938794D4441774C334E325A79494B4943416765473173626E4D39496D6830644841364C79393364336375647A4D7562334A6E4C7A49774D44417663335A';
wwv_flow_imp.g_varchar2_table(258) := '6E49676F674943423462577875637A703462476C75617A30696148523063446F764C336433647935334D793576636D63764D546B354F53393462476C756179494B4943416765473173626E4D366332396B615842765A476B39496D6830644841364C7939';
wwv_flow_imp.g_varchar2_table(259) := '7A623252706347396B6153357A623356795932566D62334A6E5A5335755A585176524652454C334E765A476C77623252704C5441755A48526B49676F674943423462577875637A7070626D747A593246775A5430696148523063446F764C336433647935';
wwv_flow_imp.g_varchar2_table(260) := '70626D747A593246775A533576636D6376626D46745A584E7759574E6C63793970626D747A593246775A53494B4943416764326C6B64476739496A497749676F674943426F5A576C6E61485139496A497749676F67494342705A44306963335A6E4E5463';
wwv_flow_imp.g_varchar2_table(261) := '7A4F43494B49434167646D567963326C76626A30694D53347849676F6749434270626D747A593246775A5470325A584A7A61573975505349774C6A6B78494849784D7A63794E53494B494341676332396B615842765A476B365A47396A626D46745A5430';
wwv_flow_imp.g_varchar2_table(262) := '6959323974596D6C755A53357A646D636950676F674944786B5A575A7A436941674943416761575139496D526C5A6E4D314E7A5177496A344B49434167494478736157356C59584A48636D466B6157567564416F6749434167494341676157357263324E';
wwv_flow_imp.g_varchar2_table(263) := '6863475536593239736247566A644430695957783359586C7A49676F67494341674943416765477870626D733661484A6C5A6A306949327870626D5668636B6479595752705A5735304E4445774D79494B494341674943416749476C6B50534A73615735';
wwv_flow_imp.g_varchar2_table(264) := '6C59584A48636D466B61575675644451784F44516943694167494341674943426E636D466B61575675644656756158527A50534A31633256795533426859325650626C567A5A53494B4943416749434167494867785053497A4D44417A49676F67494341';
wwv_flow_imp.g_varchar2_table(265) := '674943416765544539496A457749676F67494341674943416765444939496A4D774D5463694369416749434167494342354D6A30694D54416943694167494341674943426E636D466B61575675644652795957357A5A6D39796254306964484A68626E4E';
wwv_flow_imp.g_varchar2_table(266) := '735958526C4B4445734D6934324D5463784F4463305A5330324B5349674C7A344B49434167494478736157356C59584A48636D466B6157567564416F6749434167494341676157357263324E6863475536593239736247566A644430695957783359586C';
wwv_flow_imp.g_varchar2_table(267) := '7A49676F67494341674943416761575139496D7870626D5668636B6479595752705A5735304E4445774D79492B43694167494341674944787A6447397743694167494341674943416749484E306557786C50534A7A644739774C574E76624739794F694D';
wwv_flow_imp.g_varchar2_table(268) := '774D4441774D44413763335276634331766347466A615852354F6A453749676F674943416749434167494342765A6D5A7A5A585139496A416943694167494341674943416749476C6B50534A7A644739774E4445774E5349674C7A344B49434167494341';
wwv_flow_imp.g_varchar2_table(269) := '6750484E306233414B4943416749434167494341676333523562475539496E4E30623341745932397362334936497A41774D4441774D44747A644739774C57397759574E7064486B364D4473694369416749434167494341674947396D5A6E4E6C644430';
wwv_flow_imp.g_varchar2_table(270) := '694D53494B49434167494341674943416761575139496E4E30623341304D5441334969417650676F6749434167504339736157356C59584A48636D466B615756756444344B494341384C32526C5A6E4D2B4369416750484E765A476C77623252704F6D35';
wwv_flow_imp.g_varchar2_table(271) := '686257566B646D6C6C64776F674943416749476C6B50534A6959584E6C49676F6749434167494842685A32566A62327876636A306949325A6D5A6D5A6D5A69494B494341674943426962334A6B5A584A6A62327876636A3069497A59324E6A59324E6949';
wwv_flow_imp.g_varchar2_table(272) := '4B494341674943426962334A6B5A584A766347466A61585235505349784C6A416943694167494341676157357263324E68634755366347466E5A57397759574E7064486B39496A41754D43494B4943416749434270626D747A593246775A547077595764';
wwv_flow_imp.g_varchar2_table(273) := '6C633268685A4739335053497949676F674943416749476C7561334E6A5958426C4F6E707662323039496A453249676F674943416749476C7561334E6A5958426C4F6D4E34505349794C6A51794D7A41774E69494B4943416749434270626D747A593246';
wwv_flow_imp.g_varchar2_table(274) := '775A54706A655430694D5449754D54637A4D54593149676F674943416749476C7561334E6A5958426C4F6D5276593356745A5735304C5856756158527A50534A776543494B4943416749434270626D747A593246775A54706A64584A795A5735304C5778';
wwv_flow_imp.g_varchar2_table(275) := '686557567950534A7359586C6C636A45694369416749434167633268766432647961575139496D5A6862484E6C49676F674943416749476C7561334E6A5958426C4F6E6470626D52766479313361575230614430694D6A41334F43494B49434167494342';
wwv_flow_imp.g_varchar2_table(276) := '70626D747A593246775A5470336157356B62336374614756705A326830505349784D44553049676F674943416749476C7561334E6A5958426C4F6E6470626D527664793134505349354D44416943694167494341676157357263324E686347553664326C';
wwv_flow_imp.g_varchar2_table(277) := '755A4739334C586B39496A49354E69494B4943416749434270626D747A593246775A5470336157356B623363746257463461573170656D566B5053497749676F674943416749484E6F6233646E64576C6B5A584D39496D5A6862484E6C49676F67494341';
wwv_flow_imp.g_varchar2_table(278) := '6749476C7561334E6A5958426C4F6E4E7559584174596D4A766544306964484A315A53494B4943416749434270626D747A593246775A547069596D39344C5842686447687A50534A30636E566C49676F674943416749476C7561334E6A5958426C4F6D4A';
wwv_flow_imp.g_varchar2_table(279) := '6962336774626D396B5A584D39496E52796457556943694167494341676157357263324E686347553662324A715A574E304C5842686447687A50534A30636E566C49676F674943416749476C7561334E6A5958426C4F6D3969616D566A64433175623252';
wwv_flow_imp.g_varchar2_table(280) := '6C637A306964484A315A53494B4943416749434270626D747A593246775A54707A626D46774C584E7462323930614331756232526C637A306964484A315A53494B4943416749434270626D747A593246775A54707A626D46774C57393061475679637A30';
wwv_flow_imp.g_varchar2_table(281) := '695A6D46736332556943694167494341676157357263324E686347553663323568634331756232526C637A30695A6D46736332556950676F674943416750476C7561334E6A5958426C4F6D64796157514B49434167494341674948523563475539496E68';
wwv_flow_imp.g_varchar2_table(282) := '355A334A705A43494B494341674943416749476C6B50534A6E636D6C6B4E5463304E69494B49434167494341674947567463484E7759574E70626D6339496A496943694167494341674943423261584E70596D786C50534A30636E566C49676F67494341';
wwv_flow_imp.g_varchar2_table(283) := '67494341675A573568596D786C5A44306964484A315A53494B494341674943416749484E755958423261584E70596D786C5A334A705A477870626D567A623235736554306964484A315A53494B494341674943416749484E7759574E70626D6434505349';
wwv_flow_imp.g_varchar2_table(284) := '774C6A56776543494B494341674943416749484E7759574E70626D6435505349774C6A56776543494B494341674943416749474E76624739795053496A4D4441774D475A6D49676F6749434167494341676233426859326C30655430694D4334774E5467';
wwv_flow_imp.g_varchar2_table(285) := '344D6A4D314D7949674C7A344B494341384C334E765A476C77623252704F6D35686257566B646D6C6C647A344B4943413862575630595752686447454B49434167494342705A4430696257563059575268644745314E7A517A496A344B49434167494478';
wwv_flow_imp.g_varchar2_table(286) := '795A475936556B524750676F67494341674943413859324D365632397961776F674943416749434167494342795A47593659574A76645851394969492B4369416749434167494341675047526A4F6D5A76636D3168644435706257466E5A53397A646D63';
wwv_flow_imp.g_varchar2_table(287) := '72654731735043396B597A706D62334A745958512B4369416749434167494341675047526A4F6E52356347554B494341674943416749434167494342795A475936636D567A6233567959325539496D6830644841364C79397764584A734C6D39795A7939';
wwv_flow_imp.g_varchar2_table(288) := '6B5979396B5932317064486C775A53395464476C7362456C745957646C4969417650676F6749434167494341674944786B597A7030615852735A5434384C32526A4F6E52706447786C50676F6749434167494341384C324E6A4F6C6476636D732B436941';
wwv_flow_imp.g_varchar2_table(289) := '67494341384C334A6B5A6A70535245592B43694167504339745A5852685A4746305954344B494341385A776F674943416749476C7561334E6A5958426C4F6D7868596D567350534A4D59586C6C6369417849676F674943416749476C7561334E6A595842';
wwv_flow_imp.g_varchar2_table(290) := '6C4F6D6479623356776257396B5A543069624746355A584969436941674943416761575139496D7868655756794D53494B4943416749434230636D467563325A76636D3039496E52795957357A624746305A5367774C4330784D444D794C6A4D324D6A49';
wwv_flow_imp.g_varchar2_table(291) := '70496A344B49434167494478775958526F43694167494341674943427A64486C735A5430695932397362334936497A41774D4441774D44746A62476C774C584A3162475536626D3975656D5679627A746B61584E77624746354F6D6C7562476C755A5474';
wwv_flow_imp.g_varchar2_table(292) := '76646D56795A6D7876647A703261584E70596D786C4F335A7063326C696157787064486B36646D6C7A61574A735A5474766347466A615852354F6A453761584E7662474630615739754F6D46316447383762576C344C574A735A57356B4C5731765A4755';
wwv_flow_imp.g_varchar2_table(293) := '36626D3979625746734F324E76624739794C576C756447567963473973595852706232343663314A48516A746A6232787663693170626E526C636E427662474630615739754C575A706248526C636E4D3662476C755A574679556B64434F334E7662476C';
wwv_flow_imp.g_varchar2_table(294) := '6B4C574E76624739794F694D774D4441774D44413763323973615751746233426859326C3065546F784F325A7062477736497A41774D4441774D44746D615778734C57397759574E7064486B364D54746D615778734C584A3162475536626D3975656D56';
wwv_flow_imp.g_varchar2_table(295) := '79627A747A64484A7661325536626D39755A54747A64484A766132557464326C6B644767364D6A747A64484A766132557462476C755A574E6863447069645852304F334E30636D39725A5331736157356C616D3970626A70746158526C636A747A64484A';
wwv_flow_imp.g_varchar2_table(296) := '766132557462576C305A584A736157317064446F304F334E30636D39725A53316B59584E6F59584A7959586B36626D39755A54747A64484A76613255745A47467A6147396D5A6E4E6C64446F774F334E30636D39725A5331766347466A615852354F6A45';
wwv_flow_imp.g_varchar2_table(297) := '3762574679613256794F6D3576626D55375932397362334974636D56755A4756796157356E4F6D463164473837615731685A325574636D56755A4756796157356E4F6D4631644738376332686863475574636D56755A4756796157356E4F6D4631644738';
wwv_flow_imp.g_varchar2_table(298) := '3764475634644331795A57356B5A584A70626D633659585630627A746C626D466962475574596D466A61326479623356755A44706859324E31625856735958526C49676F6749434167494341675A443069545341784D6934774E5441334F4445674D6942';
wwv_flow_imp.g_varchar2_table(299) := '44494445784C6A63354E5449324D694179494445784C6A557A4F5455304D6941794C6A41354E7A45334E6A49674D5445754D7A517A4E7A55674D6934794F5449354E6A6734494577674D5441754D6A6B344F44493449444D754D7A4D334F446B774E6942';
wwv_flow_imp.g_varchar2_table(300) := '4449446B754F5441334D6A517A4E79417A4C6A63794F5451334E5463674F5334354D4463794E444D33494451754D7A59774D7A5934494445774C6A49354F4467794F4341304C6A63314D546B314D7A4567544341784E5334794E4467774E4463674F5334';
wwv_flow_imp.g_varchar2_table(301) := '334D4445784E7A453549454D674D5455754E6A4D354E6A4D78494445774C6A41354D6A63314E7941784E6934794E7A41314D6A55674D5441754D446B794E7A5533494445324C6A59324D6A45774F5341354C6A63774D5445334D546B67544341784E7934';
wwv_flow_imp.g_varchar2_table(302) := '334D4463774D7A45674F4334324E5459794E534244494445344C6A41354F4459784E6941344C6A49324E4459324E446B674D5467754D446B344E6A4532494463754E6A4D7A4E7A63794E6941784E7934334D4463774D7A45674E7934794E4449784F4463';
wwv_flow_imp.g_varchar2_table(303) := '31494577674D5449754E7A55334F444579494449754D6A6B794F5459344F434244494445794C6A55324D6A4179494449754D446B334D5463324D6941784D69347A4D44597A4D4445674D6941784D6934774E5441334F4445674D694236494530674F4341';
wwv_flow_imp.g_varchar2_table(304) := '3449454D674E794134494463674F5341334C6A55674F53343149454D674E7934344D7A4D7A4D7A4D674F5334344D7A4D7A494467754E5341784D433431494467754E5341784D433431494577674E793431494445784C6A5567517941334C6A55674D5445';
wwv_flow_imp.g_varchar2_table(305) := '754E53413349444579494463754E5341784D69343149454D674F4341784D7941344C6A55674D5449754E5341344C6A55674D5449754E53424D49446B754E5341784D533431494577674D5441754E5341784D69343149454D674D5445674D544D674D5449';
wwv_flow_imp.g_varchar2_table(306) := '674D544D674D5449674D544967544341784D694134494577674F43413449486F6754534130494445774C6A41774D7A6B774E69424449444D754E7A51304E5445674D5441754D44417A4F54413249444D754E446B774E6A6B784E6941784D4334784D444D';
wwv_flow_imp.g_varchar2_table(307) := '774D7A6B674D7934794F5451354D6A4535494445774C6A49354F4467794F43424D494449754D6A6B344F4449344D5341784D5334794F5451354D6A4967517941784C6A6B774E7A49344F4467674D5445754E6A67324E5341784C6A6B774E7A49344F4467';
wwv_flow_imp.g_varchar2_table(308) := '674D5449754D7A45314E44557A494449754D6A6B344F4449344D5341784D6934334D4463774D7A45675443417A4C6A49354E6A67334E5341784D7934334D4463774D7A45675179417A4C6A59344F4451784E4451674D5451754D446B344E6A4135494451';
wwv_flow_imp.g_varchar2_table(309) := '754D7A45354D7A6B344D5341784E4334774F5467324D446B674E4334334D5441354D7A63314944457A4C6A63774E7A417A4D53424D494455754E7A41334D444D784D6941784D6934334D5441354D7A6767517941324C6A41354F4455334D4459674D5449';
wwv_flow_imp.g_varchar2_table(310) := '754D7A45354D7A59674E6934774F5467314E7A4132494445784C6A59344F4451314D7941314C6A63774E7A417A4D5449674D5445754D6A6B324F446331494577674E4334334D4463774D7A4579494445774C6A49354F4467794F434244494451754E5445';
wwv_flow_imp.g_varchar2_table(311) := '784D6A59784E6941784D4334784D444D774D7A6B674E4334794E5455304F5341784D4334774D444D354D4459674E4341784D4334774D444D354D4459676569424E494463754F546B324D446B7A4F4341784E434244494463754E7A51774E546B304D6941';
wwv_flow_imp.g_varchar2_table(312) := '784E4341334C6A51344E44677A4F5455674D5451754D446B334D546733494463754D6A67354D4459794E5341784E4334794F5449354E6A6B67544341324C6A49354E446B794D546B674D5455754D6A67354D44597949454D674E5334354D444D7A4E6A63';
wwv_flow_imp.g_varchar2_table(313) := '35494445314C6A59344D4459794E6941314C6A6B774D7A4D324E7A6B674D5459754D7A45784E545978494459754D6A6B304F5449784F5341784E6934334D444D784D6A5567544341334C6A49354D6A6B324F4467674D5463754E7A41784D54637949454D';
wwv_flow_imp.g_varchar2_table(314) := '674E7934324F4451314D6A4933494445344C6A41354D6A637A4E5341344C6A4D784D7A55794E4449674D5467754D446B794E7A4D31494467754E7A41314D4463344D5341784E7934334D4445784E7A4967544341354C6A63774D5445334D546B674D5459';
wwv_flow_imp.g_varchar2_table(315) := '754E7A41314D44633449454D674D5441754D446B794E7A4932494445324C6A4D784D7A55784E5341784D4334774F5449334D6A59674D5455754E6A67304E544D7949446B754E7A41784D5463784F5341784E5334794F5449354E6A6B67544341344C6A63';
wwv_flow_imp.g_varchar2_table(316) := '774D7A45794E5341784E4334794F5449354E6A6B67517941344C6A55774E7A4D304F4341784E4334774F5463784F4463674F4334794E5445314F544D7A49444530494463754F546B324D446B7A4F4341784E4342364943494B4943416749434167494852';
wwv_flow_imp.g_varchar2_table(317) := '795957357A5A6D39796254306964484A68626E4E735958526C4B4441734D54417A4D69347A4E6A49794B53494B494341674943416749476C6B50534A795A574E304F5445354F4349674C7A344B494341384C32632B436A777663335A6E50676F3D293B0A';
wwv_flow_imp.g_varchar2_table(318) := '7D0A0A2E6D6170626F78676C2D6D61702E6D6F7573652D706F696E746572202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A20706F696E7465723B0A';
wwv_flow_imp.g_varchar2_table(319) := '7D0A2E6D6170626F78676C2D6D61702E6D6F7573652D6D6F7665202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A206D6F76653B0A7D0A2E6D617062';
wwv_flow_imp.g_varchar2_table(320) := '6F78676C2D6D61702E6D6F7573652D616464202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A2063726F7373686169723B0A7D0A2E6D6170626F7867';
wwv_flow_imp.g_varchar2_table(321) := '6C2D6D61702E6D6F7573652D6D6F76652E6D6F64652D6469726563745F73656C656374202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A2067726162';
wwv_flow_imp.g_varchar2_table(322) := '3B0A2020637572736F723A202D6D6F7A2D677261623B0A2020637572736F723A202D7765626B69742D677261623B0A7D0A2E6D6170626F78676C2D6D61702E6D6F64652D6469726563745F73656C6563742E666561747572652D7665727465782E6D6F75';
wwv_flow_imp.g_varchar2_table(323) := '73652D6D6F7665202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A206D6F76653B0A7D0A2E6D6170626F78676C2D6D61702E6D6F64652D6469726563';
wwv_flow_imp.g_varchar2_table(324) := '745F73656C6563742E666561747572652D6D6964706F696E742E6D6F7573652D706F696E746572202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A20';
wwv_flow_imp.g_varchar2_table(325) := '63656C6C3B0A7D0A2E6D6170626F78676C2D6D61702E6D6F64652D6469726563745F73656C6563742E666561747572652D666561747572652E6D6F7573652D6D6F7665202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F';
wwv_flow_imp.g_varchar2_table(326) := '78676C2D696E746572616374697665207B0A2020637572736F723A206D6F76653B0A7D0A2E6D6170626F78676C2D6D61702E6D6F64652D7374617469632E6D6F7573652D706F696E74657220202E6D6170626F78676C2D63616E7661732D636F6E746169';
wwv_flow_imp.g_varchar2_table(327) := '6E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A20677261623B0A2020637572736F723A202D6D6F7A2D677261623B0A2020637572736F723A202D7765626B69742D677261623B0A7D0A0A2E6D6170626F782D67';
wwv_flow_imp.g_varchar2_table(328) := '6C2D647261775F626F7873656C656374207B0A20202020706F696E7465722D6576656E74733A206E6F6E653B0A20202020706F736974696F6E3A206162736F6C7574653B0A20202020746F703A20303B0A202020206C6566743A20303B0A202020207769';
wwv_flow_imp.g_varchar2_table(329) := '6474683A20303B0A202020206865696768743A20303B0A202020206261636B67726F756E643A207267626128302C302C302C2E31293B0A20202020626F726465723A2032707820646F7474656420236666663B0A202020206F7061636974793A20302E35';
wwv_flow_imp.g_varchar2_table(330) := '3B0A7D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(2085023770439618400)
,p_plugin_id=>wwv_flow_imp.id(2097648210592940579)
,p_file_name=>'mapbox-gl-draw.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
