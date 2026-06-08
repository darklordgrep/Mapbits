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
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.4'
,p_default_workspace_id=>7300231193299000
,p_default_application_id=>107982
,p_default_id_offset=>0
,p_default_owner=>'MVDGIS'
);
end;
/
 
prompt APPLICATION 107982 - Mapbits 5 Demo
--
-- Application Export:
--   Application:     107982
--   Name:            Mapbits 5 Demo
--   Date and Time:   18:57 Monday March 16, 2026
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 43381211524713251
--   Manifest End
--   Version:         24.2.4
--   Instance ID:     218369902185809
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_draw
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(43381211524713251)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.DRAW'
,p_display_name=>'Mapbits Drawing'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#mapbox-gl-draw.js',
'#PLUGIN_FILES#mapbits-draw-style.js',
'#PLUGIN_FILES#mapbits-draw.js'))
,p_css_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#mapbox-gl-draw.css',
'#PLUGIN_FILES#mapbits-draw#MIN#.css'))
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure map_drawing_render_ajax (',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_ajax_param,',
'  p_result in out nocopy apex_plugin.t_item_ajax_result',
') is',
'  l_geom_collection_name p_item.attribute_02%type;',
'  l_geomtxt clob;',
'begin',
'  if apex_application.g_x10 = ''WRITEBACK'' then',
'    l_geom_collection_name := p_item.attribute_02;',
'    if l_geom_collection_name is not null then',
'      l_geomtxt := apex_json.get_clob(''geometry'');',
'      apex_collection.create_or_truncate_collection(p_collection_name => l_geom_collection_name);',
'      apex_collection.add_member(p_collection_name => l_geom_collection_name,  p_clob001 => l_geomtxt);',
'      htp.p(''{"Status" : "No Error"}'');',
'    else',
'      htp.p(''{"Status" : "[XYZZY] No Geometry Collection Name specified. Nothing happens."}'');',
'    end if;',
'  end if; ',
'end;',
'',
'function get_geojson(p_item apex_plugin.t_item) return clob is',
'  l_geojson clob := null;',
'begin',
'  if p_item.attribute_02 is not null then',
'    begin',
'      select clob001 into l_geojson from apex_collections where collection_name = p_item.attribute_02;',
'    exception when no_data_found then',
'      null;',
'    end;',
'  else',
'    l_geojson := apex_session_state.get_clob(p_item.name);',
'    if l_geojson is not null and (length(l_geojson) = 4000 or length(l_geojson) = 32767) and l_geojson not like ''%}'' then',
'      raise_application_error(-20352, ''ERROR: Mapbits Drawing Item ['' || p_item.name || ''] received truncated GeoJSON. Ensure the Session State -> Data Type attribute is set to CLOB.'');',
'    end if;',
'  end if;',
'',
'  return l_geojson;',
'end;',
'',
'procedure map_drawing_render (',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_render_param,',
'  p_result in out nocopy apex_plugin.t_item_render_result ) is',
'  l_region_id varchar2(400);',
'  l_geometry_modes p_item.attribute_01%type := p_item.attribute_01;',
'  l_geom_collection_name p_item.attribute_02%type := p_item.attribute_02;',
'  l_readonly varchar2(5);',
'  l_geojson clob;',
'  l_show_coords varchar2(5);  ',
'  l_enable_geo varchar2(5);',
'  l_buffersize number:=80;',
'  l_offset integer;',
'  l_pointZoomLevel p_item.attribute_06%type := nvl(p_item.attribute_06, 12);',
'begin',
'  -- Read-only attribute',
'  l_readonly := case when apex_page.is_read_only then ''true'' else ''false'' end;',
'  if l_readonly = ''true'' then',
'    l_geometry_modes := ''NONE'';',
'  end if;',
'  -- Show Coordinates attribute',
'  l_show_coords := case when p_item.attribute_04 = ''Y'' then ''true'' else ''false'' end;',
'  -- Enable Geolocation attribute',
'  l_enable_geo := case when p_item.attribute_03 = ''Y'' then ''true'' else ''false'' end;',
'',
'  -- Collection name attribute',
'  l_geojson := get_geojson(p_item);',
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
'  exception when no_data_found then',
'    raise_application_error(-20351, ''Configuration ERROR: Mapbits Drawing Item ['' || p_item.name || ''] is not associated with a Map region.'');',
'  end;',
'',
'  apex_util.prn(''<input type="hidden" id="'' || p_item.name || ''" name="'' || p_item.name || ''" value="'' || apex_escape.html_attribute_clob(l_geojson) || ''"/>'', false);',
'',
'  apex_javascript.add_onload_code(p_code => ''',
'    mapbits_draw({''',
'      || apex_javascript.add_attribute(''p_item_id'', p_item.name)',
'      || apex_javascript.add_attribute(''p_ajax_identifier'', apex_plugin.get_ajax_identifier)',
'      || apex_javascript.add_attribute(''p_region_id'', l_region_id)',
'      || ''"p_geometry": JSON.parse($v("'' || p_item.name || ''")),''',
'      || apex_javascript.add_attribute(''geometry_modes'', l_geometry_modes)',
'      || apex_javascript.add_attribute(''readonly'', l_readonly = ''true'')',
'      || apex_javascript.add_attribute(''show_coords'', l_show_coords = ''true'')',
'      || apex_javascript.add_attribute(''enable_geolocate'', l_enable_geo = ''true'')',
'      || apex_javascript.add_attribute(''point_zoom_level'', to_number(l_pointZoomLevel))',
'      || apex_javascript.add_attribute(''writeback_enabled'', l_geom_collection_name is not null)',
'      || ''initJs: ('' || nvl(p_item.init_javascript_code, ''null'') || '')''',
'    || ''});',
'  '');',
'end;',
'',
'procedure map_drawing_validate (',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_validation_param,',
'  p_result in out nocopy apex_plugin.t_item_validation_result',
') is',
'  l_geom_clob clob;',
'  l_geom sdo_geometry;',
'  rt varchar2(4000);',
'begin',
'  l_geom_clob := get_geojson(p_item);',
'  if l_geom_clob is not null then',
'    l_geom := sdo_util.from_geojson(l_geom_clob);',
'    rt := sdo_geom.validate_geometry_with_context(l_geom, 0.001, ''FALSE'', ''TRUE'');',
'    if not rt = ''TRUE'' then',
'      p_result.message := rt;',
'    end if;',
'  end if;',
'end;'))
,p_api_version=>2
,p_render_function=>'map_drawing_render'
,p_ajax_function=>'map_drawing_render_ajax'
,p_validation_function=>'map_drawing_validate'
,p_standard_attributes=>'VISIBLE:READONLY:SOURCE:INIT_JAVASCRIPT_CODE:SESSION_STATE_CLOB'
,p_substitute_attributes=>true
,p_version_scn=>475293687
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
,p_version_identifier=>'5.0.20251201'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 5 - Draw',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_draw.sql 21417 2026-03-16 19:04:03Z b2eddjw9 $',
'Date     : $Date: 2026-03-16 14:04:03 -0500 (Mon, 16 Mar 2026) $',
'Revision : $Revision: 21417 $',
'Requires : Application Express >= 24.2',
'',
'03/16/2026 Fixed error when submitting empty geometry. Fixed some JavaScript errors.',
'',
'Version 5 Updates:',
'12/01/2025 Updated mapbox-gl-draw to v1.5.1',
'11/26/2025 Removed Read Only Item attribute and use the standard Read Only attribute',
'11/26/2025 Added crosshair cursor',
'11/26/2025 In point coordinate input, normalize coordinates and prevent from going out of bounds',
'11/25/2025 Store GeoJSON in the page item value as a preferred alternative to collections',
'11/25/2025 Improve upload performance when using collections',
'08/19/2025 Fix bug that sometimes happened when the map region has a static ID',
'07/30/2025 Update point coordinates when calling setGeometry() API',
'',
'--------------------',
'',
'Version 4.8 Updates:',
'01/27/2025 Fix bug where the point would appear on the map before both lat/lon were entered.',
'01/27/2025 Fix bug where pressing Enter in the lat/lon entry could cause the entry to disappear.',
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
,p_files_version=>357
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(183978009143176806)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_title=>'Legacy Storage'
,p_display_sequence=>1
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43381976579713252)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_static_id=>'attribute_01'
,p_prompt=>'Available Geometry Types'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'POINT'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Choose whether to add point, line, or polygon tools to the Map region.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43382364365713252)
,p_plugin_attribute_id=>wwv_flow_imp.id(43381976579713252)
,p_display_sequence=>10
,p_display_value=>'Point'
,p_return_value=>'POINT'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43382876166713252)
,p_plugin_attribute_id=>wwv_flow_imp.id(43381976579713252)
,p_display_sequence=>20
,p_display_value=>'Line'
,p_return_value=>'LINE'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43383351548713252)
,p_plugin_attribute_id=>wwv_flow_imp.id(43381976579713252)
,p_display_sequence=>30
,p_display_value=>'Polygon'
,p_return_value=>'POLYGON'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43383882859713252)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_static_id=>'attribute_02'
,p_prompt=>'Geometry Collection Name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(183978009143176806)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'GEOMETRY_COLLECTION',
'',
'where GEOMETRY_COLLECTION is created by',
'',
'apex_collection.create_or_truncate_collection(p_collection_name => ''GEOMETRY_COLLECTION'');',
'apex_collection.add_member(p_collection_name => ''GEOMETRY_COLLECTION'', p_clob001 =>  ''"type": "Point", "coordinates": [-90.112, 30.091]}'');'))
,p_help_text=>'Name of the APEX Collection from which to read and write the drawing geometry. This geometry is stored in the clob001 column in geojson geometry format. This is a holdover from previous Mapbits versions and is no longer necessary. In new code, use th'
||'e page item value to store and retrieve the GeoJSON.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43384274282713253)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>90
,p_static_id=>'attribute_03'
,p_prompt=>'Enable Geolocation'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'If enabled, a geolocation tool button will appear when the draw control is in edit mode or if a line or polygon vertex is selected. Clicking the button will create a point (for draw point mode), add a vertex (in draw line and draw polygon mode) or mo'
||'ve a selected vertex point to the geolocation-determined coordinate.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43384613468713253)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_static_id=>'attribute_04'
,p_prompt=>'Show Coordinates for Point Text Entry'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'If enabled, a region showing the point coordinates as numerical degrees, minutes, and seconds will appear below the map region. This region will only be visible for point drawing geometries. If the draw tool is in line or polygon edit mode, then this'
||' region will be hidden.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43385080373713253)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_static_id=>'attribute_06'
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
wwv_flow_imp_shared.create_plugin_std_attribute(
 p_id=>wwv_flow_imp.id(44278973106371831)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43385452419713254)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_name=>'mil_army_usace_mapbits_drawcreate'
,p_display_name=>'Draw / Create'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '0D0A202020203C7376672077696474683D22323422206865696768743D223234222076657273696F6E3D22312E31222076696577426F783D2230203020362E333520362E33352220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030';
wwv_flow_imp.g_varchar2_table(2) := '302F737667223E0D0A202020203C67207472616E73666F726D3D227472616E736C61746528312E3035383320312E303538332922207374726F6B653D222366666622207374726F6B652D6C696E656361703D22726F756E6422207374726F6B652D776964';
wwv_flow_imp.g_varchar2_table(3) := '74683D222E3236343538223E0D0A2020202020203C7061746820643D226D312E3731393820302E373933373520302E333936383820302E333936383720302E33393638372D302E3339363837762D312E37313938682D302E37393337357A22207374796C';
wwv_flow_imp.g_varchar2_table(4) := '653D227061696E742D6F726465723A66696C6C206D61726B657273207374726F6B65222F3E0D0A2020202020203C7061746820643D226D302E373933373520322E3531333520302E33393638372D302E33393638382D302E33393638372D302E33393638';
wwv_flow_imp.g_varchar2_table(5) := '37682D312E3731393876302E37393337357A22207374796C653D227061696E742D6F726465723A66696C6C206D61726B657273207374726F6B65222F3E0D0A2020202020203C7061746820643D226D322E3531333520332E343339362D302E3339363838';
wwv_flow_imp.g_varchar2_table(6) := '2D302E33393638382D302E333936383720302E333936383876312E3731393868302E37393337357A22207374796C653D227061696E742D6F726465723A66696C6C206D61726B657273207374726F6B65222F3E0D0A2020202020203C7061746820643D22';
wwv_flow_imp.g_varchar2_table(7) := '6D332E3433393620312E373139382D302E333936383820302E333936383820302E333936383820302E333936383768312E37313938762D302E37393337357A22207374796C653D227061696E742D6F726465723A66696C6C206D61726B65727320737472';
wwv_flow_imp.g_varchar2_table(8) := '6F6B65222F3E0D0A202020203C2F673E0D0A202020203C2F7376673E';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43385785764713254)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'crosshair.svg'
,p_mime_type=>'image/svg+xml'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '766172204D4150424954535F44454641554C545F445241575F5354594C4553203D205B0D0A20207B0D0A20202020276964273A2027676C2D647261772D706F6C79676F6E2D66696C6C2D696E616374697665272C0D0A202020202774797065273A202766';
wwv_flow_imp.g_varchar2_table(2) := '696C6C272C0D0A202020202766696C746572273A205B27616C6C272C0D0A2020202020205B273D3D272C2027616374697665272C202766616C7365275D2C0D0A2020202020205B273D3D272C20272474797065272C2027506F6C79676F6E275D2C0D0A20';
wwv_flow_imp.g_varchar2_table(3) := '20202020205B27213D272C20276D6F6465272C2027737461746963275D0D0A202020205D2C0D0A20202020277061696E74273A207B0D0A2020202020202766696C6C2D636F6C6F72273A202723336262326430272C0D0A2020202020202766696C6C2D6F';
wwv_flow_imp.g_varchar2_table(4) := '75746C696E652D636F6C6F72273A202723336262326430272C0D0A2020202020202766696C6C2D6F706163697479273A20302E310D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D706F6C79676F6E2D66';
wwv_flow_imp.g_varchar2_table(5) := '696C6C2D616374697665272C0D0A202020202774797065273A202766696C6C272C0D0A202020202766696C746572273A205B27616C6C272C205B273D3D272C2027616374697665272C202774727565275D2C205B273D3D272C20272474797065272C2027';
wwv_flow_imp.g_varchar2_table(6) := '506F6C79676F6E275D5D2C0D0A20202020277061696E74273A207B0D0A2020202020202766696C6C2D636F6C6F72273A202723666262303362272C0D0A2020202020202766696C6C2D6F75746C696E652D636F6C6F72273A202723666262303362272C0D';
wwv_flow_imp.g_varchar2_table(7) := '0A2020202020202766696C6C2D6F706163697479273A20302E310D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D706F6C79676F6E2D7374726F6B652D696E616374697665272C0D0A2020202027747970';
wwv_flow_imp.g_varchar2_table(8) := '65273A20276C696E65272C0D0A202020202766696C746572273A205B27616C6C272C0D0A2020202020205B273D3D272C2027616374697665272C202766616C7365275D2C0D0A2020202020205B273D3D272C20272474797065272C2027506F6C79676F6E';
wwv_flow_imp.g_varchar2_table(9) := '275D2C0D0A2020202020205B27213D272C20276D6F6465272C2027737461746963275D0D0A202020205D2C0D0A20202020276C61796F7574273A207B0D0A202020202020276C696E652D636170273A2027726F756E64272C0D0A202020202020276C696E';
wwv_flow_imp.g_varchar2_table(10) := '652D6A6F696E273A2027726F756E64270D0A202020207D2C0D0A20202020277061696E74273A207B0D0A202020202020276C696E652D636F6C6F72273A202723336262326430272C0D0A202020202020276C696E652D7769647468273A20320D0A202020';
wwv_flow_imp.g_varchar2_table(11) := '207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D706F6C79676F6E2D7374726F6B652D616374697665272C0D0A202020202774797065273A20276C696E65272C0D0A202020202766696C746572273A205B27616C6C27';
wwv_flow_imp.g_varchar2_table(12) := '2C205B273D3D272C2027616374697665272C202774727565275D2C205B273D3D272C20272474797065272C2027506F6C79676F6E275D5D2C0D0A20202020276C61796F7574273A207B0D0A202020202020276C696E652D636170273A2027726F756E6427';
wwv_flow_imp.g_varchar2_table(13) := '2C0D0A202020202020276C696E652D6A6F696E273A2027726F756E64270D0A202020207D2C0D0A20202020277061696E74273A207B0D0A202020202020276C696E652D636F6C6F72273A202723666262303362272C0D0A202020202020276C696E652D64';
wwv_flow_imp.g_varchar2_table(14) := '6173686172726179273A205B302E322C20325D2C0D0A202020202020276C696E652D7769647468273A20320D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D6C696E652D696E616374697665272C0D0A20';
wwv_flow_imp.g_varchar2_table(15) := '2020202774797065273A20276C696E65272C0D0A202020202766696C746572273A205B27616C6C272C0D0A2020202020205B273D3D272C2027616374697665272C202766616C7365275D2C0D0A2020202020205B273D3D272C20272474797065272C2027';
wwv_flow_imp.g_varchar2_table(16) := '4C696E65537472696E67275D2C0D0A2020202020205B27213D272C20276D6F6465272C2027737461746963275D0D0A202020205D2C0D0A20202020276C61796F7574273A207B0D0A202020202020276C696E652D636170273A2027726F756E64272C0D0A';
wwv_flow_imp.g_varchar2_table(17) := '202020202020276C696E652D6A6F696E273A2027726F756E64270D0A202020207D2C0D0A20202020277061696E74273A207B0D0A202020202020276C696E652D636F6C6F72273A202723336262326430272C0D0A202020202020276C696E652D77696474';
wwv_flow_imp.g_varchar2_table(18) := '68273A20320D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D6C696E652D616374697665272C0D0A202020202774797065273A20276C696E65272C0D0A202020202766696C746572273A205B27616C6C27';
wwv_flow_imp.g_varchar2_table(19) := '2C0D0A2020202020205B273D3D272C20272474797065272C20274C696E65537472696E67275D2C0D0A2020202020205B273D3D272C2027616374697665272C202774727565275D0D0A202020205D2C0D0A20202020276C61796F7574273A207B0D0A2020';
wwv_flow_imp.g_varchar2_table(20) := '20202020276C696E652D636170273A2027726F756E64272C0D0A202020202020276C696E652D6A6F696E273A2027726F756E64270D0A202020207D2C0D0A20202020277061696E74273A207B0D0A202020202020276C696E652D636F6C6F72273A202723';
wwv_flow_imp.g_varchar2_table(21) := '666262303362272C0D0A202020202020276C696E652D646173686172726179273A205B302E322C20325D2C0D0A202020202020276C696E652D7769647468273A20320D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D';
wwv_flow_imp.g_varchar2_table(22) := '647261772D706F6C79676F6E2D616E642D6C696E652D7665727465782D7374726F6B652D696E616374697665272C0D0A202020202774797065273A2027636972636C65272C0D0A202020202766696C746572273A205B27616C6C272C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(23) := '5B273D3D272C20276D657461272C2027766572746578275D2C0D0A2020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A2020202020205B27213D272C20276D6F6465272C2027737461746963275D0D0A202020205D2C0D0A';
wwv_flow_imp.g_varchar2_table(24) := '20202020277061696E74273A207B0D0A20202020202027636972636C652D726164697573273A20352C0D0A20202020202027636972636C652D636F6C6F72273A202723666666270D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A';
wwv_flow_imp.g_varchar2_table(25) := '2027676C2D647261772D706F6C79676F6E2D616E642D6C696E652D7665727465782D696E616374697665272C0D0A202020202774797065273A2027636972636C65272C0D0A202020202766696C746572273A205B27616C6C272C0D0A2020202020205B27';
wwv_flow_imp.g_varchar2_table(26) := '3D3D272C20276D657461272C2027766572746578275D2C0D0A2020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A2020202020205B27213D272C20276D6F6465272C2027737461746963275D0D0A202020205D2C0D0A2020';
wwv_flow_imp.g_varchar2_table(27) := '2020277061696E74273A207B0D0A20202020202027636972636C652D726164697573273A20332C0D0A20202020202027636972636C652D636F6C6F72273A202723666262303362270D0A202020207D0D0A20207D2C0D0A20207B0D0A2020202027696427';
wwv_flow_imp.g_varchar2_table(28) := '3A2027676C2D647261772D706F696E742D7374726F6B652D696E616374697665272C0D0A202020202774797065273A2027636972636C65272C0D0A202020202766696C746572273A205B27616C6C272C0D0A2020202020205B273D3D272C202761637469';
wwv_flow_imp.g_varchar2_table(29) := '7665272C202766616C7365275D2C0D0A2020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A2020202020205B273D3D272C20276D657461272C202766656174757265275D0D0A202020205D2C0D0A20202020277061696E74';
wwv_flow_imp.g_varchar2_table(30) := '273A207B0D0A20202020202027636972636C652D726164697573273A2031332C0D0A20202020202027636972636C652D6F706163697479273A20312C0D0A20202020202027636972636C652D636F6C6F72273A202723666666270D0A202020207D0D0A20';
wwv_flow_imp.g_varchar2_table(31) := '207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D706F696E742D696E616374697665272C0D0A202020202774797065273A2027636972636C65272C0D0A202020202766696C746572273A205B27616C6C272C0D0A2020202020205B';
wwv_flow_imp.g_varchar2_table(32) := '273D3D272C2027616374697665272C202766616C7365275D2C0D0A2020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A2020202020205B273D3D272C20276D657461272C202766656174757265275D2C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(33) := '5B27213D272C20276D6F6465272C2027737461746963275D0D0A202020205D2C0D0A20202020277061696E74273A207B0D0A20202020202027636972636C652D726164697573273A2031312C200D0A20202020202027636972636C652D636F6C6F72273A';
wwv_flow_imp.g_varchar2_table(34) := '202723336262326430270D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D706F696E742D7374726F6B652D616374697665272C0D0A202020202774797065273A2027636972636C65272C0D0A2020202027';
wwv_flow_imp.g_varchar2_table(35) := '66696C746572273A205B27616C6C272C0D0A2020202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A2020202020205B273D3D272C2027616374697665272C202774727565275D2C0D0A2020202020205B27213D272C20276D65';
wwv_flow_imp.g_varchar2_table(36) := '7461272C20276D6964706F696E74275D0D0A202020205D2C0D0A20202020277061696E74273A207B0D0A20202020202027636972636C652D726164697573273A2031322C0D0A20202020202027636972636C652D636F6C6F72273A202723666666270D0A';
wwv_flow_imp.g_varchar2_table(37) := '202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D706F696E742D616374697665272C0D0A202020202774797065273A2027636972636C65272C0D0A202020202766696C746572273A205B27616C6C272C0D0A20';
wwv_flow_imp.g_varchar2_table(38) := '20202020205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A2020202020205B27213D272C20276D657461272C20276D6964706F696E74275D2C0D0A2020202020205B273D3D272C2027616374697665272C202774727565275D5D2C0D';
wwv_flow_imp.g_varchar2_table(39) := '0A20202020277061696E74273A207B0D0A20202020202027636972636C652D726164697573273A2031302C0D0A20202020202027636972636C652D636F6C6F72273A202723666262303362270D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(40) := '276964273A2027676C2D647261772D706F6C79676F6E2D66696C6C2D737461746963272C0D0A202020202774797065273A202766696C6C272C0D0A202020202766696C746572273A205B27616C6C272C205B273D3D272C20276D6F6465272C2027737461';
wwv_flow_imp.g_varchar2_table(41) := '746963275D2C205B273D3D272C20272474797065272C2027506F6C79676F6E275D5D2C0D0A20202020277061696E74273A207B0D0A2020202020202766696C6C2D636F6C6F72273A202723343034303430272C0D0A2020202020202766696C6C2D6F7574';
wwv_flow_imp.g_varchar2_table(42) := '6C696E652D636F6C6F72273A202723343034303430272C0D0A2020202020202766696C6C2D6F706163697479273A20302E310D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D706F6C79676F6E2D737472';
wwv_flow_imp.g_varchar2_table(43) := '6F6B652D737461746963272C0D0A202020202774797065273A20276C696E65272C0D0A202020202766696C746572273A205B27616C6C272C205B273D3D272C20276D6F6465272C2027737461746963275D2C205B273D3D272C20272474797065272C2027';
wwv_flow_imp.g_varchar2_table(44) := '506F6C79676F6E275D5D2C0D0A20202020276C61796F7574273A207B0D0A202020202020276C696E652D636170273A2027726F756E64272C0D0A202020202020276C696E652D6A6F696E273A2027726F756E64270D0A202020207D2C0D0A202020202770';
wwv_flow_imp.g_varchar2_table(45) := '61696E74273A207B0D0A202020202020276C696E652D636F6C6F72273A202723343034303430272C0D0A202020202020276C696E652D7769647468273A20320D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261';
wwv_flow_imp.g_varchar2_table(46) := '772D6C696E652D737461746963272C0D0A202020202774797065273A20276C696E65272C0D0A202020202766696C746572273A205B27616C6C272C205B273D3D272C20276D6F6465272C2027737461746963275D2C205B273D3D272C2027247479706527';
wwv_flow_imp.g_varchar2_table(47) := '2C20274C696E65537472696E67275D5D2C0D0A20202020276C61796F7574273A207B0D0A202020202020276C696E652D636170273A2027726F756E64272C0D0A202020202020276C696E652D6A6F696E273A2027726F756E64270D0A202020207D2C0D0A';
wwv_flow_imp.g_varchar2_table(48) := '20202020277061696E74273A207B0D0A202020202020276C696E652D636F6C6F72273A202723343034303430272C0D0A202020202020276C696E652D7769647468273A20320D0A202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027';
wwv_flow_imp.g_varchar2_table(49) := '676C2D647261772D706F696E742D737461746963272C0D0A202020202774797065273A2027636972636C65272C0D0A202020202766696C746572273A205B27616C6C272C205B273D3D272C20276D6F6465272C2027737461746963275D2C205B273D3D27';
wwv_flow_imp.g_varchar2_table(50) := '2C20272474797065272C2027506F696E74275D5D2C0D0A20202020277061696E74273A207B0D0A20202020202027636972636C652D726164697573273A2031302C0D0A20202020202027636972636C652D636F6C6F72273A202723343034303430270D0A';
wwv_flow_imp.g_varchar2_table(51) := '202020207D0D0A20207D2C0D0A20207B0D0A20202020276964273A2027676C2D647261772D6D6964706F696E74272C0D0A202020202774797065273A2027636972636C65272C0D0A202020202766696C746572273A205B27616C6C272C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(52) := '205B273D3D272C20272474797065272C2027506F696E74275D2C0D0A2020202020205B273D3D272C20276D657461272C20276D6964706F696E74275D5D2C0D0A20202020277061696E74273A207B0D0A20202020202027636972636C652D726164697573';
wwv_flow_imp.g_varchar2_table(53) := '273A20332C0D0A20202020202027636972636C652D636F6C6F72273A202723666262303362270D0A202020207D0D0A20207D2C0D0A5D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43386155571713254)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbits-draw-style.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D6170626974732D647261772D63726F737368616972207B0D0A2020706F736974696F6E3A206162736F6C7574653B0D0A2020746F703A203530253B0D0A20206C6566743A203530253B0D0A20207472616E73666F726D3A207472616E736C61746528';
wwv_flow_imp.g_varchar2_table(2) := '2D3530252C202D353025293B0D0A7D0D0A0D0A2E6D6170626974732D647261772D63726F7373686169722D637572736F72207B0D0A2020637572736F723A2075726C28646174613A696D6167652F7376672B786D6C3B6261736536342C50484E325A7942';
wwv_flow_imp.g_varchar2_table(3) := '3361575230614430694D6A55694947686C6157646F644430694D6A556949485A705A58644362336739496A41674D4341324C6A59784E5341324C6A59784E53496765473173626E4D39496D6830644841364C79393364336375647A4D7562334A6E4C7A49';
wwv_flow_imp.g_varchar2_table(4) := '774D44417663335A6E496A3438634746306143426B50534A4E4D6934784D5463674D7934784E7A56494C6A49324E5859754D6A5931614445754F445579646930754D6A5931625451754D6A4D7A494442494E4334304F5468324C6A49324E5567324C6A4D';
wwv_flow_imp.g_varchar2_table(5) := '31646930754D6A593154544D754E4451674E69347A4E5659304C6A51354F4767744C6A49324E5659324C6A4D31614334794E6A56744D4330304C6A497A4D3159754D6A5931614330754D6A5931646A45754F445579614334794E6A56744C5334794E6A55';
wwv_flow_imp.g_varchar2_table(6) := '674D5334774E5468324C6A49324E5767754D6A5931646930754D6A5931614330754D6A59314969427A64486C735A54306963474670626E517462334A6B5A58493662574679613256796379427A64484A76613255675A6D6C736243496763335279623274';
wwv_flow_imp.g_varchar2_table(7) := '6C5053496A5A6D5A6D4969427A64484A766132557462476C755A574E68634430696333463159584A6C4969427A64484A766132557464326C6B64476739496934314D6A6B694C7A34384C334E325A7A343D292031322E352031322E352C206175746F2021';
wwv_flow_imp.g_varchar2_table(8) := '696D706F7274616E743B0D0A7D0D0A0D0A2E6D6170626974732D647261772D636F6F7264666F726D207B0D0A2020646973706C61793A207461626C653B0D0A20206D617267696E3A20303B0D0A202070616464696E673A203470783B0D0A7D0D0A0D0A2E';
wwv_flow_imp.g_varchar2_table(9) := '6D6170626974732D647261772D636F6F7264666F726D2D726F77207B0D0A2020646973706C61793A207461626C652D726F773B0D0A7D0D0A0D0A2E6D6170626974732D647261772D636F6F7264666F726D2D726F77203E202A207B0D0A2020646973706C';
wwv_flow_imp.g_varchar2_table(10) := '61793A207461626C652D63656C6C3B0D0A7D0D0A0D0A2E6D6170626974732D647261772D636F6F7264666F726D20696E707574207B0D0A20206D617267696E2D696E6C696E652D73746172743A2031656D3B0D0A20206D617267696E2D696E6C696E652D';
wwv_flow_imp.g_varchar2_table(11) := '656E643A202E33656D3B0D0A202077696474683A2038656D3B0D0A7D0D0A0D0A406D6564696120286D696E2D77696474683A20353072656D29207B0D0A20202E6D622D6C6F6E3A3A6265666F7265207B0D0A20202020636F6E74656E743A20224C6F6E67';
wwv_flow_imp.g_varchar2_table(12) := '69747564653A223B0D0A20207D0D0A20202E6D622D6C61743A3A6265666F7265207B0D0A20202020636F6E74656E743A20224C617469747564653A223B0D0A20207D0D0A20202E6D622D6C6162656C2D6465673A3A6166746572207B0D0A20202020636F';
wwv_flow_imp.g_varchar2_table(13) := '6E74656E743A20222044656772656573223B0D0A20207D0D0A20202E6D622D6C6162656C2D6D696E3A3A6166746572207B0D0A20202020636F6E74656E743A2022204D696E75746573223B0D0A20207D0D0A20202E6D622D6C6162656C2D7365633A3A61';
wwv_flow_imp.g_varchar2_table(14) := '66746572207B0D0A20202020636F6E74656E74203A2022205365636F6E6473223B0D0A20207D0D0A7D0D0A0D0A406D6564696120286D61782D77696474683A20353072656D29207B0D0A20202E6D622D6C6F6E3A3A6265666F7265207B0D0A2020202063';
wwv_flow_imp.g_varchar2_table(15) := '6F6E74656E74203A20224C6F6E20223B0D0A20207D0D0A20202E6D622D6C61743A3A6265666F7265207B0D0A20202020636F6E74656E74203A20224C617420223B0D0A20207D0D0A20202E6D622D6C6162656C2D6465673A3A6166746572207B0D0A2020';
wwv_flow_imp.g_varchar2_table(16) := '2020636F6E74656E74203A2022C2B0223B0D0A20207D0D0A20202E6D622D6C6162656C2D6D696E3A3A6166746572207B0D0A20202020636F6E74656E74203A20225C27223B0D0A20207D0D0A20202E6D622D6C6162656C2D7365633A3A6166746572207B';
wwv_flow_imp.g_varchar2_table(17) := '0D0A20202020636F6E74656E74203A20225C22223B0D0A20207D0D0A7D0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43386972721713255)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbits-draw.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F64726177287B705F6974656D5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F67656F6D657472792C20696E69744A732C202E2E2E705F6F7074696F6E737D29';
wwv_flow_imp.g_varchar2_table(2) := '207B0D0A20202F2A0D0A2020202A2067656E657261746520616E206572726F72206D65737361676520616C6572742C206D73670D0A2020202A2F0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A20202020617065782E6A';
wwv_flow_imp.g_varchar2_table(3) := '51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C657274286D7367293B636F6E736F6C652E6C6F672827616C6572742027202B206D7367293B7D293B0D0A20207D0D0A0D0A20206C6574207374796C6573203D2073747275';
wwv_flow_imp.g_varchar2_table(4) := '637475726564436C6F6E65284D4150424954535F44454641554C545F445241575F5354594C4553293B0D0A0D0A20202F2A0D0A2020202A2052657475726E2074686520657874656E74206F662074686520696E7075742067656F6D206F626A6563742061';
wwv_flow_imp.g_varchar2_table(5) := '732061206D6170626F78676C2E4C6E674C6174426F756E64732E0D0A2020202A20496E7075742067656F6D65747279206F626A6563742069732067656F6A736F6E2067656F6D6574727920666F726D617420286E6F742046656174757265292E0D0A2020';
wwv_flow_imp.g_varchar2_table(6) := '202A2F0D0A2020636F6E737420676574426F756E6473203D202867656F6D29203D3E207B0D0A202020206C6574207061727261793B0D0A20202020737769746368202867656F6D2E7479706529207B0D0A2020202020206361736520274C696E65537472';
wwv_flow_imp.g_varchar2_table(7) := '696E67273A0D0A2020202020202020706172726179203D2067656F6D2E636F6F7264696E617465733B0D0A2020202020202020627265616B3B0D0A202020202020636173652027506F6C79676F6E273A0D0A2020202020202020706172726179203D2067';
wwv_flow_imp.g_varchar2_table(8) := '656F6D2E636F6F7264696E617465735B305D3B0D0A2020202020202020627265616B3B0D0A2020202020206361736520274D756C7469506F6C79676F6E273A0D0A2020202020202020706172726179203D205B5D3B0D0A2020202020202020666F722028';
wwv_flow_imp.g_varchar2_table(9) := '636F6E73742063206F662067656F6D2E636F6F7264696E6174657329207B0D0A20202020202020202020706172726179203D207061727261792E636F6E63617428635B305D293B0D0A20202020202020207D0D0A2020202020202020627265616B3B0D0A';
wwv_flow_imp.g_varchar2_table(10) := '2020202020206361736520274D756C74694C696E65537472696E67273A0D0A2020202020202020706172726179203D205B5D3B0D0A2020202020202020666F722028636F6E73742063206F662067656F6D2E636F6F7264696E6174657329207B0D0A2020';
wwv_flow_imp.g_varchar2_table(11) := '2020202020202020706172726179203D207061727261792E636F6E6361742863293B0D0A20202020202020207D0D0A2020202020202020627265616B3B0D0A202020207D0D0A0D0A20202020766172207274203D206E6577206D61706C69627265676C2E';
wwv_flow_imp.g_varchar2_table(12) := '4C6E674C6174426F756E6473287061727261795B305D2C207061727261795B305D293B0D0A20202020666F722028636F6E73742063206F662070617272617929207B0D0A20202020202072742E657874656E642863293B0D0A202020207D0D0A20202020';
wwv_flow_imp.g_varchar2_table(13) := '72657475726E2072743B0D0A20207D0D0A0D0A20202F2F204D616B65207661726961626C65732066726F6D20706C7567696E20617474726962757465730D0A202076617220705F67656F6D657472795F6D6F646573203D20705F6F7074696F6E732E6765';
wwv_flow_imp.g_varchar2_table(14) := '6F6D657472795F6D6F6465733B0D0A202076617220705F726561646F6E6C79203D20705F6F7074696F6E732E726561646F6E6C793B0D0A202076617220705F73686F775F636F6F726473203D20705F6F7074696F6E732E73686F775F636F6F7264733B0D';
wwv_flow_imp.g_varchar2_table(15) := '0A202076617220705F706F696E745F7A6F6F6D5F6C6576656C203D20705F6F7074696F6E732E706F696E745F7A6F6F6D5F6C6576656C3B0D0A202076617220705F656E61626C655F67656F6C6F63617465203D20705F6F7074696F6E732E656E61626C65';
wwv_flow_imp.g_varchar2_table(16) := '5F67656F6C6F636174653B0D0A0D0A20202F2A0D0A2020202A20436C61737320666F72204D6170626F782047656F6C6F6361746520506F696E7420436F6E74726F6C2C206578706F73696E672074686520627574746F6E2E0D0A2020202A20417373756D';
wwv_flow_imp.g_varchar2_table(17) := '657320636F6E74726F6C20627574746F6E732061726520333278333270782E0D0A2020202A2F0D0A2020636C6173732047656F6C6F63617465506F696E74427574746F6E207B0D0A20202020636F6E7374727563746F722829207B207D0D0A0D0A202020';
wwv_flow_imp.g_varchar2_table(18) := '206F6E416464286D617029207B0D0A202020202020746869732E6D5F6D6170203D206D61703B0D0A202020202020746869732E6D5F636F6E7461696E6572203D20646F63756D656E742E637265617465456C656D656E74282764697627293B0D0A202020';
wwv_flow_imp.g_varchar2_table(19) := '202020746869732E67656F6C6F636174655F706F696E745F627574746F6E203D20646F63756D656E742E637265617465456C656D656E742827627574746F6E27293B0D0A202020202020746869732E67656F6C6F636174655F706F696E745F627574746F';
wwv_flow_imp.g_varchar2_table(20) := '6E2E7374796C65203D20226C696E652D6865696768743A313670783B77696474683A333270783B6865696768743A333270783B646973706C61793A6E6F6E653B223B0D0A202020202020746869732E67656F6C6F636174655F706F696E745F627574746F';
wwv_flow_imp.g_varchar2_table(21) := '6E2E696E6E657248544D4C203D20273C6920636C6173733D2266612066612D6C6F636174696F6E2D636972636C65223E3C2F693E273B0D0A202020202020746869732E67656F6C6F636174655F706F696E745F627574746F6E2E74797065203D20226275';
wwv_flow_imp.g_varchar2_table(22) := '74746F6E223B0D0A202020202020746869732E6D5F636F6E7461696E65722E617070656E644368696C6428746869732E67656F6C6F636174655F706F696E745F627574746F6E293B0D0A202020202020746869732E6D5F636F6E7461696E65722E636C61';
wwv_flow_imp.g_varchar2_table(23) := '73734E616D65203D20226D6170626F78676C2D6374726C206D61706C69627265676C2D6374726C223B0D0A20202020202072657475726E20746869732E6D5F636F6E7461696E65723B0D0A202020207D0D0A0D0A202020206F6E52656D6F76652829207B';
wwv_flow_imp.g_varchar2_table(24) := '0D0A202020202020746869732E6D5F636F6E7461696E65722E706172656E744E6F64652E72656D6F76654368696C6428746869732E6D5F636F6E7461696E6572293B0D0A202020202020746869732E6D5F6D6170203D20756E646566696E65643B0D0A20';
wwv_flow_imp.g_varchar2_table(25) := '2020207D0D0A0D0A20202020676574427574746F6E2829207B0D0A20202020202072657475726E20746869732E67656F6C6F636174655F706F696E745F627574746F6E3B0D0A202020207D0D0A20207D0D0A20207661722067656F6C6F636174655F706F';
wwv_flow_imp.g_varchar2_table(26) := '696E745F636F6E74726F6C203D206E65772047656F6C6F63617465506F696E74427574746F6E28293B0D0A0D0A20202F2A2072657475726E20746865206465677265657320636F6D706F6E656E74206F662076616C202A2F0D0A2020636F6E7374206765';
wwv_flow_imp.g_varchar2_table(27) := '7444656772656573203D202876616C29203D3E2076616C203E2030203F204D6174682E666C6F6F722876616C29203A202D4D6174682E666C6F6F72282D76616C293B0D0A0D0A20202F2A2072657475726E20746865206D696E7574657320636F6D706F6E';
wwv_flow_imp.g_varchar2_table(28) := '656E74206F662076616C202A2F0D0A202066756E6374696F6E206765744D696E757465732876616C29207B0D0A202020206966202876616C203E203029207B0D0A202020202020636F6E73742064656772656573203D2067657444656772656573287661';
wwv_flow_imp.g_varchar2_table(29) := '6C293B0D0A20202020202072657475726E204D6174682E666C6F6F7228282876616C202D206465677265657329202A2036302E3029293B0D0A202020207D20656C7365207B0D0A202020202020636F6E73742064656772656573203D2067657444656772';
wwv_flow_imp.g_varchar2_table(30) := '656573282D76616C293B0D0A20202020202072657475726E204D6174682E666C6F6F722828282D76616C202D206465677265657329202A2036302E3029293B0D0A202020207D0D0A20207D0D0A0D0A20202F2A0D0A20202A2072657475726E2074686520';
wwv_flow_imp.g_varchar2_table(31) := '7365636F6E647320636F6D706F6E656E74206F662076616C0D0A20202A2F0D0A202066756E6374696F6E206765745365636F6E64732876616C29207B0D0A20202020636F6E7374206176616C203D204D6174682E616273284D6174682E726F756E642876';
wwv_flow_imp.g_varchar2_table(32) := '616C202A2031303030303030303030303029202F203130303030303030303030302E30293B0D0A20202020636F6E73742064656772656573203D204D6174682E6162732867657444656772656573286176616C29293B0D0A20202020636F6E7374206D69';
wwv_flow_imp.g_varchar2_table(33) := '6E75746573203D206765744D696E75746573286176616C293B0D0A20202020636F6E7374207274203D202833363030202A20286176616C202D2064656772656573202D206D696E75746573202F2036302E3029292E746F46697865642834293B0D0A2020';
wwv_flow_imp.g_varchar2_table(34) := '2020696620287274203D3D20363029207B0D0A20202020202072657475726E20303B0D0A202020207D20656C7365207B0D0A20202020202072657475726E2072743B0D0A202020207D0D0A20207D0D0A0D0A20202F2A0D0A20202A2072657475726E2063';
wwv_flow_imp.g_varchar2_table(35) := '6F6E76657273696F6E206F6620646567726565732C206D696E757465732C20616E64207365636F6E647320746F20646563696D616C20646567726565732E0D0A20202A2F0D0A2020636F6E737420676574446563696D616C44656772656573203D202864';
wwv_flow_imp.g_varchar2_table(36) := '6567726565732C206D696E757465732C207365636F6E64732C20626F756E6429203D3E207B0D0A2020202064656772656573203D207061727365466C6F61742864656772656573293B0D0A202020206D696E75746573203D207061727365466C6F617428';
wwv_flow_imp.g_varchar2_table(37) := '6D696E75746573293B0D0A202020207365636F6E6473203D207061727365466C6F6174287365636F6E6473293B0D0A0D0A202020202F2F20696620746865206D696E7574657320616E64207365636F6E6473206669656C647320617265206E6F74206E75';
wwv_flow_imp.g_varchar2_table(38) := '6D6265727320286E756C6C292C207468656E20757365207A65726F20746F2063616C63756C61746520646563696D616C20646567726565730D0A202020206966202869734E614E286D696E757465732929207B0D0A2020202020206D696E75746573203D';
wwv_flow_imp.g_varchar2_table(39) := '20303B0D0A202020207D0D0A202020206966202869734E614E287365636F6E64732929207B0D0A2020202020207365636F6E6473203D20303B0D0A202020207D0D0A0D0A2020202072657475726E2064656772656573203E20300D0A2020202020203F20';
wwv_flow_imp.g_varchar2_table(40) := '4D6174682E6D696E28626F756E642C204D6174682E6D6178282D626F756E642C2064656772656573202B206D696E75746573202F2036302E30202B207365636F6E6473202F20333630302E3029290D0A2020202020203A204D6174682E6D696E28626F75';
wwv_flow_imp.g_varchar2_table(41) := '6E642C204D6174682E6D6178282D626F756E642C2064656772656573202D206D696E75746573202F2036302E30202D207365636F6E6473202F20333630302E3029293B0D0A20207D0D0A0D0A20202F2A0D0A2020202A2053657420746865206D61706269';
wwv_flow_imp.g_varchar2_table(42) := '74732067656F6D6574727920746F2074686520636F6F7264696E617465732073686F776E20696E20746865206C617469747564652F6C6F6E67697475646520646567726573732C206D696E757465732C207365636F6E647320696E707574207465787420';
wwv_flow_imp.g_varchar2_table(43) := '6669656C64732E0D0A2020202A2F0D0A2020636F6E73742073796E6347656F6D6574727946726F6D436F6F7264696E61746573203D202829203D3E207B0D0A20202020636F6E7374206C61745F646567203D20617065782E6A517565727928272327202B';
wwv_flow_imp.g_varchar2_table(44) := '20705F6974656D5F6964202B20225F6C617469747564655F6465677265657322292E76616C28293B0D0A20202020636F6E7374206C61745F6D696E203D20617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6174697475';
wwv_flow_imp.g_varchar2_table(45) := '64655F6D696E7574657322292E76616C28293B0D0A20202020636F6E7374206C61745F736563203D20617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F7365636F6E647322292E76616C28293B0D0A';
wwv_flow_imp.g_varchar2_table(46) := '20202020636F6E7374206C6F6E5F646567203D20617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F6465677265657322292E76616C28293B0D0A20202020636F6E7374206C6F6E5F6D696E203D20';
wwv_flow_imp.g_varchar2_table(47) := '617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F6D696E7574657322292E76616C28293B0D0A20202020636F6E7374206C6F6E5F736563203D20617065782E6A517565727928272327202B20705F';
wwv_flow_imp.g_varchar2_table(48) := '6974656D5F6964202B20225F6C6F6E6769747564655F7365636F6E647322292E76616C28293B0D0A0D0A20202020636F6E73742067656F6D78203D20676574446563696D616C44656772656573286C6F6E5F6465672C206C6F6E5F6D696E2C206C6F6E5F';
wwv_flow_imp.g_varchar2_table(49) := '7365632C20313830293B0D0A20202020636F6E73742067656F6D79203D20676574446563696D616C44656772656573286C61745F6465672C206C61745F6D696E2C206C61745F7365632C203930293B0D0A0D0A202020206966202869734E614E2867656F';
wwv_flow_imp.g_varchar2_table(50) := '6D7829207C7C2069734E614E2867656F6D792929207B0D0A2020202020202F2F20496620612064656772656573206669656C642069736E27742066696C6C6564206F75742C2069742773206E6F742076616C69642C20736F20646F6E2774206472617720';
wwv_flow_imp.g_varchar2_table(51) := '6120706F696E74207965742E0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A202020202F2F206966206E6F2066656174757265732068617665206265656E20637265617465642C2063726561746520616E20656D707479206665617475';
wwv_flow_imp.g_varchar2_table(52) := '726520666F7220746865206472617720746F6F6C2E0D0A20202020636F6E7374206663203D20647261772E676574416C6C28293B0D0A202020206966202866632E66656174757265732E6C656E677468203D3D203029207B0D0A20202020202066632E66';
wwv_flow_imp.g_varchar2_table(53) := '656174757265732E70757368287B747970653A202246656174757265222C2070726F706572746965733A207B7D2C2067656F6D65747279203A207B636F6F7264696E617465733A205B6E756C6C2C206E756C6C5D7D7D293B20200D0A202020207D0D0A0D';
wwv_flow_imp.g_varchar2_table(54) := '0A202020202F2F205365742074686520706F696E742067656F6D6574727920696E20746865206D61702E0D0A2020202066632E66656174757265735B305D2E67656F6D657472792E74797065203D2022506F696E74223B0D0A2020202066632E66656174';
wwv_flow_imp.g_varchar2_table(55) := '757265735B305D2E67656F6D657472792E636F6F7264696E617465735B305D203D2067656F6D783B0D0A2020202066632E66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465735B315D203D2067656F6D793B0D0A2020202064';
wwv_flow_imp.g_varchar2_table(56) := '7261772E736574286663293B0D0A0D0A202020202F2F205772697465207468652067656F6D65747279206261636B20746F207468652073657276657220616E642070616E20746F207468652067656F6D657472792E0D0A20202020636F6E737420666561';
wwv_flow_imp.g_varchar2_table(57) := '7473203D20647261772E676574416C6C28293B0D0A20202020636F6E73742067656F6D203D2066656174732E66656174757265735B305D2E67656F6D657472793B0D0A20202020777269746547656F6D65747279284A534F4E2E737472696E6769667928';
wwv_flow_imp.g_varchar2_table(58) := '67656F6D29293B0D0A202020206D61702E70616E546F2867656F6D2E636F6F7264696E61746573293B0D0A0D0A202020202F2F204E6F726D616C697A652074686520696E707574206669656C6473206966206E65636573736172792028652E672E206966';
wwv_flow_imp.g_varchar2_table(59) := '20746865206D696E7574657320777261702061726F756E64292E0D0A2020202069662028676574446567726565732867656F6D782920213D3D206C6F6E5F646567207C7C206765744D696E757465732867656F6D782920213D3D206C6F6E5F6D696E207C';
wwv_flow_imp.g_varchar2_table(60) := '7C206765745365636F6E64732867656F6D782920213D3D206C6F6E5F736563207C7C20676574446567726565732867656F6D792920213D3D206C61745F646567207C7C206765744D696E757465732867656F6D792920213D3D206C61745F6D696E207C7C';
wwv_flow_imp.g_varchar2_table(61) := '206765745365636F6E64732867656F6D792920213D3D206C61745F73656329207B0D0A20202020202073796E63436F6F72647346726F6D47656F6D657472792867656F6D293B0D0A202020207D0D0A20207D3B0D0A0D0A20202F2A0D0A2020202A205570';
wwv_flow_imp.g_varchar2_table(62) := '64617465206C6174697475646520616E64206C6F6E67697475646520646567726565732C206D696E757465732C20616E64207365636F6E6473206669656C647320616E64206D617062697473206974656D2076616C75652066726F6D20746865206D6170';
wwv_flow_imp.g_varchar2_table(63) := '626974732067656F6D657472792E0D0A2020202A2F0D0A2020636F6E73742073796E63436F6F72647346726F6D47656F6D65747279203D202867656F6D6574727929203D3E207B0D0A202020206966202867656F6D657472792E636F6F7264696E617465';
wwv_flow_imp.g_varchar2_table(64) := '732E6C656E677468203C203129207B0D0A20202020202072657475726E3B0D0A202020207D0D0A202020206966202867656F6D657472792E74797065203D3D3D2022506F696E742229207B0D0A202020202020636F6E73742078203D2067656F6D657472';
wwv_flow_imp.g_varchar2_table(65) := '792E636F6F7264696E617465735B305D3B0D0A202020202020636F6E73742079203D2067656F6D657472792E636F6F7264696E617465735B315D3B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C';
wwv_flow_imp.g_varchar2_table(66) := '6F6E6769747564655F6465677265657322292E76616C2867657444656772656573287829293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F6D696E7574657322292E7661';
wwv_flow_imp.g_varchar2_table(67) := '6C286765744D696E75746573287829293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F7365636F6E647322292E76616C286765745365636F6E6473287829293B0D0A2020';
wwv_flow_imp.g_varchar2_table(68) := '20202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F6465677265657322292E76616C2867657444656772656573287929293B0D0A202020202020617065782E6A517565727928272327202B20';
wwv_flow_imp.g_varchar2_table(69) := '705F6974656D5F6964202B20225F6C617469747564655F6D696E7574657322292E76616C286765744D696E75746573287929293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C61746974756465';
wwv_flow_imp.g_varchar2_table(70) := '5F7365636F6E647322292E76616C286765745365636F6E6473287929293B0D0A202020207D200D0A20207D3B0D0A0D0A20206C6574206D61703B0D0A0D0A2020636F6E73742070656E64696E674D6170203D206E65772050726F6D69736528287265736F';
wwv_flow_imp.g_varchar2_table(71) := '6C76652C2072656A65637429203D3E207B0D0A20202020636F6E737420726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D0A2020202069662028726567696F6E203D3D206E756C6C29207B0D0A2020202020206170';
wwv_flow_imp.g_varchar2_table(72) := '65782E64656275672E6572726F7228276D6170626974735F64726177696E6727202B206974656D4964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D2069732068696464656E206F72206D697373696E672E2729';
wwv_flow_imp.g_varchar2_table(73) := '3B0D0A20202020202072656A65637428293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20202020726567696F6E2E656C656D656E742E6F6E28277370617469616C6D6170696E697469616C697A6564272C202829203D3E207B0D0A';
wwv_flow_imp.g_varchar2_table(74) := '2020202020206D6170203D20617065782E726567696F6E28705F726567696F6E5F6964292E63616C6C28276765744D61704F626A65637427293B0D0A2020202020202F2F2044656C6179206C6F61642062792061206672616374696F6E206F6620612073';
wwv_flow_imp.g_varchar2_table(75) := '65636F6E6420746F20616C6C6F77206F74686572206C617965727320746F206C6F61642E20546869732073686F756C642070726576656E74206F74686572206C61796572732066726F6D206C6F6164696E67206F6E20746F70206F662074686520647261';
wwv_flow_imp.g_varchar2_table(76) := '77696E6720666561747572652E0D0A20202020202073657454696D656F7574282829203D3E207265736F6C7665286D6170292C20353030293B0D0A202020207D293B0D0A20207D293B0D0A0D0A20202F2F205374617469634D6F64652069732075736564';
wwv_flow_imp.g_varchar2_table(77) := '207768656E20746865206974656D2069732073657420746F2072656164206F6E6C792C200D0A20202F2F20746F2073686F7720612070726576696F75736C7920647261776E2067656F6D657472792C20627574206E6F7420746F20656469742069742E0D';
wwv_flow_imp.g_varchar2_table(78) := '0A2020636F6E7374205374617469634D6F6465203D207B7D3B0D0A20205374617469634D6F64652E6F6E5365747570203D2066756E6374696F6E2829207B0D0A20202020746869732E736574416374696F6E61626C65537461746528293B202F2F206465';
wwv_flow_imp.g_varchar2_table(79) := '6661756C7420616374696F6E61626C652073746174652069732066616C736520666F7220616C6C20616374696F6E730D0A2020202072657475726E207B7D3B0D0A20207D3B0D0A20205374617469634D6F64652E746F446973706C617946656174757265';
wwv_flow_imp.g_varchar2_table(80) := '73203D2066756E6374696F6E2873746174652C2067656F6A736F6E2C20646973706C617929207B0D0A20202020646973706C61792867656F6A736F6E293B0D0A20207D3B0D0A2020636F6E7374206D6F646573203D204D6170626F78447261772E6D6F64';
wwv_flow_imp.g_varchar2_table(81) := '65733B0D0A20206D6F6465732E737461746963203D205374617469634D6F64653B0D0A0D0A2020636F6E73742069734576656E744174436F6F7264696E61746573203D20286576656E742C20636F6F7264696E6174657329203D3E207B0D0A2020202069';
wwv_flow_imp.g_varchar2_table(82) := '662028216576656E742E6C6E674C617429207B0D0A20202020202072657475726E2066616C73653B0D0A202020207D0D0A2020202072657475726E206576656E742E6C6E674C61742E6C6E67203D3D3D20636F6F7264696E617465735B305D2026262065';
wwv_flow_imp.g_varchar2_table(83) := '76656E742E6C6E674C61742E6C6174203D3D3D20636F6F7264696E617465735B315D3B0D0A20207D3B0D0A0D0A20202F2F204F7665727269646520746865206B657975702066756E6374696F6E206F6E20647261775F6C696E655F737472696E67206D6F';
wwv_flow_imp.g_varchar2_table(84) := '6465206F66204D6170626F78206472617720746F20726573706F6E6420746F207468652067656F6C6F636174696F6E0D0A20202F2F20627574746F6E20636C69636B2E205468652067656F6C6F636174696F6E20627574746F6E2077696C6C20696E6974';
wwv_flow_imp.g_varchar2_table(85) := '69617465206120286029206B65797570206576656E742E200D0A20206D6F6465732E647261775F6C696E655F737472696E672E6F6E4B65795570203D2066756E6374696F6E2873746174652C206529207B0D0A2020202069662028652E6B6579436F6465';
wwv_flow_imp.g_varchar2_table(86) := '203D3D3D20313329207B0D0A202020202020746869732E6368616E67654D6F6465282773696D706C655F73656C656374272C207B20666561747572654964733A205B73746174652E6C696E652E69645D207D293B0D0A202020207D20656C736520696620';
wwv_flow_imp.g_varchar2_table(87) := '28652E6B6579436F6465203D3D3D20323729207B0D0A202020202020746869732E64656C65746546656174757265285B73746174652E6C696E652E69645D2C207B2073696C656E743A2074727565207D293B0D0A202020202020746869732E6368616E67';
wwv_flow_imp.g_varchar2_table(88) := '654D6F6465282773696D706C655F73656C65637427293B0D0A202020207D20656C736520696628652E6B6579203D3D2027602729207B0D0A2020202020206966202873746174652E63757272656E74566572746578506F736974696F6E203E2030202626';
wwv_flow_imp.g_varchar2_table(89) := '2069734576656E744174436F6F7264696E6174657328652C2073746174652E6C696E652E636F6F7264696E617465735B73746174652E63757272656E74566572746578506F736974696F6E202D20315D29207C7C0D0A202020202020202073746174652E';
wwv_flow_imp.g_varchar2_table(90) := '646972656374696F6E203D3D3D20276261636B7761726473272026262069734576656E744174436F6F7264696E6174657328652C2073746174652E6C696E652E636F6F7264696E617465735B73746174652E63757272656E74566572746578506F736974';
wwv_flow_imp.g_varchar2_table(91) := '696F6E202B20315D2929207B0D0A202020202020202072657475726E20746869732E6368616E67654D6F6465282773696D706C655F73656C656374272C207B20666561747572654964733A205B73746174652E6C696E652E69645D207D293B0D0A202020';
wwv_flow_imp.g_varchar2_table(92) := '2020207D0D0A202020202020746869732E7570646174655549436C6173736573287B206D6F7573653A202761646427207D293B0D0A0D0A2020202020206E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F';
wwv_flow_imp.g_varchar2_table(93) := '6E2866756E6374696F6E28706F73297B0D0A202020202020202073746174652E6C696E652E757064617465436F6F7264696E6174652873746174652E63757272656E74566572746578506F736974696F6E2C20706F732E636F6F7264732E6C6F6E676974';
wwv_flow_imp.g_varchar2_table(94) := '7564652C20706F732E636F6F7264732E6C61746974756465293B2020202020200D0A20202020202020206966202873746174652E646972656374696F6E203D3D3D2027666F72776172642729207B0D0A2020202020202020202073746174652E63757272';
wwv_flow_imp.g_varchar2_table(95) := '656E74566572746578506F736974696F6E2B2B3B0D0A2020202020202020202073746174652E6C696E652E757064617465436F6F7264696E6174652873746174652E63757272656E74566572746578506F736974696F6E2C20705B305D2C20705B315D29';
wwv_flow_imp.g_varchar2_table(96) := '3B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202073746174652E6C696E652E616464436F6F7264696E61746528302C20705B305D2C20705B315D293B0D0A20202020202020207D0D0A2020202020207D2C2066756E6374696F';
wwv_flow_imp.g_varchar2_table(97) := '6E2865727229207B0D0A20202020202020207661722070203D205B2D3930202B2028302E30312A4D6174682E72616E646F6D2829202D20302E303035292C203330202B2028302E30312A4D6174682E72616E646F6D2829202D20302E303035295D3B0D0A';
wwv_flow_imp.g_varchar2_table(98) := '20202020202020202F2F20756E636F6D6D656E74207468697320746F207465737420696E204368726F6D652E0D0A202020202020202073746174652E6C696E652E757064617465436F6F7264696E6174652873746174652E63757272656E745665727465';
wwv_flow_imp.g_varchar2_table(99) := '78506F736974696F6E2C20705B305D2C20705B315D293B0D0A0D0A20202020202020206966202873746174652E646972656374696F6E203D3D3D2027666F72776172642729207B0D0A2020202020202020202073746174652E63757272656E7456657274';
wwv_flow_imp.g_varchar2_table(100) := '6578506F736974696F6E2B2B3B0D0A2020202020202020202073746174652E6C696E652E757064617465436F6F7264696E6174652873746174652E63757272656E74566572746578506F736974696F6E2C20705B305D2C20705B315D293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(101) := '202020207D20656C7365207B0D0A2020202020202020202073746174652E6C696E652E616464436F6F7264696E61746528302C20705B305D2C20705B315D293B0D0A20202020202020207D0D0A2020202020207D293B0D0A202020207D0D0A20207D3B0D';
wwv_flow_imp.g_varchar2_table(102) := '0A0D0A20206D6F6465732E647261775F706F6C79676F6E2E6F6E4B65795570203D2066756E6374696F6E2873746174652C206529207B0D0A202020202F2F2068616E646C6520656E74657220616E6420657363617065206173206265666F72650D0A2020';
wwv_flow_imp.g_varchar2_table(103) := '202069662028652E6B6579436F6465203D3D3D20323729207B0D0A202020202020746869732E64656C65746546656174757265285B73746174652E706F6C79676F6E2E69645D2C207B2073696C656E743A2074727565207D293B0D0A2020202020207468';
wwv_flow_imp.g_varchar2_table(104) := '69732E6368616E67654D6F6465282773696D706C655F73656C65637427293B0D0A202020207D20656C73652069662028652E6B6579436F6465203D3D3D20313329207B0D0A202020202020746869732E6368616E67654D6F6465282773696D706C655F73';
wwv_flow_imp.g_varchar2_table(105) := '656C656374272C207B20666561747572654964733A205B73746174652E706F6C79676F6E2E69645D207D293B0D0A202020207D20656C736520696628652E6B6579203D3D2027602729207B0D0A2020202020206966202873746174652E63757272656E74';
wwv_flow_imp.g_varchar2_table(106) := '566572746578506F736974696F6E203E20302026262069734576656E744174436F6F7264696E6174657328652C2073746174652E706F6C79676F6E2E636F6F7264696E617465735B305D5B73746174652E63757272656E74566572746578506F73697469';
wwv_flow_imp.g_varchar2_table(107) := '6F6E202D20315D2929207B0D0A202020202020202072657475726E20746869732E6368616E67654D6F6465282773696D706C655F73656C656374272C207B20666561747572654964733A205B73746174652E706F6C79676F6E2E69645D207D293B0D0A20';
wwv_flow_imp.g_varchar2_table(108) := '20202020207D0D0A202020202020746869732E7570646174655549436C6173736573287B206D6F7573653A202761646427207D293B0D0A0D0A2020202020206E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974';
wwv_flow_imp.g_varchar2_table(109) := '696F6E2866756E6374696F6E28706F73297B0D0A202020202020202073746174652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B73746174652E63757272656E74566572746578506F736974696F6E7D602C20706F732E63';
wwv_flow_imp.g_varchar2_table(110) := '6F6F7264732E6C6F6E6769747564652C20706F732E636F6F7264732E6C61746974756465293B2020202020200D0A202020202020202073746174652E63757272656E74566572746578506F736974696F6E2B2B3B0D0A202020202020202073746174652E';
wwv_flow_imp.g_varchar2_table(111) := '706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B73746174652E63757272656E74566572746578506F736974696F6E7D602C20706F732E636F6F7264732E6C6F6E6769747564652C20706F732E636F6F7264732E6C6174697475';
wwv_flow_imp.g_varchar2_table(112) := '6465293B0D0A2020202020207D2C2066756E6374696F6E2865727229207B0D0A20202020202020207661722070203D205B2D3930202B2028302E30312A4D6174682E72616E646F6D2829202D20302E303035292C203330202B2028302E30312A4D617468';
wwv_flow_imp.g_varchar2_table(113) := '2E72616E646F6D2829202D20302E303035295D3B0D0A20202020202020202F2F20756E636F6D6D656E74207468697320746F207465737420696E204368726F6D652E0D0A202020202020202073746174652E706F6C79676F6E2E757064617465436F6F72';
wwv_flow_imp.g_varchar2_table(114) := '64696E6174652860302E247B73746174652E63757272656E74566572746578506F736974696F6E7D602C20705B305D2C20705B315D293B0D0A202020202020202073746174652E63757272656E74566572746578506F736974696F6E2B2B3B0D0A202020';
wwv_flow_imp.g_varchar2_table(115) := '202020202073746174652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B73746174652E63757272656E74566572746578506F736974696F6E7D602C20705B305D2C20705B315D293B0D0A2020202020207D293B0D0A202020';
wwv_flow_imp.g_varchar2_table(116) := '207D0D0A20207D3B0D0A0D0A20206C657420647261773B0D0A0D0A20202F2A0D0A20202A2063616C6C20616A61782073657276696365206F662074686520706C7567696E20776974682074686520696E7075742067656F6D6574727920746F2077726974';
wwv_flow_imp.g_varchar2_table(117) := '65206974206261636B20746F207468652070616765206974656D20616E6420696E7075742067656F6D6574727920636F6C6C656374696F6E0D0A20202A2061732077656C6C206B6E6F7720746578742E204C617267652064617461206973207374726561';
wwv_flow_imp.g_varchar2_table(118) := '6D65642E0D0A20202A2F0D0A2020636F6E737420777269746547656F6D65747279203D202867656F6D6574727929203D3E207B0D0A20202020617065782E6974656D28705F6974656D5F6964292E73657456616C75652867656F6D65747279293B0D0A0D';
wwv_flow_imp.g_varchar2_table(119) := '0A2020202069662028705F6F7074696F6E732E77726974656261636B5F656E61626C656429207B0D0A2020202020206C65742064656661756C745F637572736F72203D20646F63756D656E742E626F64792E7374796C652E637572736F723B0D0A202020';
wwv_flow_imp.g_varchar2_table(120) := '2020206966202864656661756C745F637572736F72203D3D3D20226E6F742D616C6C6F7765642229207B0D0A202020202020202064656661756C745F637572736F72203D206E756C6C3B0D0A2020202020207D0D0A0D0A202020202020617065782E7365';
wwv_flow_imp.g_varchar2_table(121) := '727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B0D0A20202020202020207831303A202257524954454241434B222C0D0A202020202020202067656F6D657472792C0D0A2020202020207D2C207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(122) := '737563636573733A2066756E6374696F6E2028704461746129207B0D0A20202020202020202020646F63756D656E742E626F64792E7374796C652E637572736F72203D2064656661756C745F637572736F723B0D0A20202020202020207D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(123) := '20202020206572726F723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A20202020202020202020646F63756D656E742E626F64792E7374796C652E637572736F72203D2064656661756C745F637572736F723B0D';
wwv_flow_imp.g_varchar2_table(124) := '0A20202020202020202020617065785F616C65727428657272293B0D0A20202020202020207D0D0A2020202020207D293B0D0A202020207D0D0A0D0A20202020617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B';
wwv_flow_imp.g_varchar2_table(125) := '20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F6472617763726561746522293B0D0A20207D0D0A0D0A2020636F6E73742075706461746547656F6C6F636174696F6E427574746F6E446973706C6179203D20';
wwv_flow_imp.g_varchar2_table(126) := '2829203D3E207B0D0A20202020636F6E7374206D6F6465203D20647261772E6765744D6F646528293B0D0A20202020636F6E7374206E73656C65637465644665617475726573203D20647261772E67657453656C656374656428292E6665617475726573';
wwv_flow_imp.g_varchar2_table(127) := '2E6C656E6774683B0D0A2020202069662028705F656E61626C655F67656F6C6F6361746529207B0D0A202020202020696620285B226469726563745F73656C656374222C2022647261775F706F696E74222C2022647261775F6C696E655F737472696E67';
wwv_flow_imp.g_varchar2_table(128) := '222C2022647261775F706F6C79676F6E225D2E696E636C75646573286D6F64652929207B0D0A202020202020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E676574427574746F6E28292E7374796C652E646973706C6179203D202762';
wwv_flow_imp.g_varchar2_table(129) := '6C6F636B273B0D0A2020202020207D20656C7365207B0D0A2020202020202020696620286D6F6465203D3D3D202773696D706C655F73656C6563742729207B0D0A20202020202020202020696620286E73656C65637465644665617475726573203E2030';
wwv_flow_imp.g_varchar2_table(130) := '29207B0D0A20202020202020202020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E676574427574746F6E28292E7374796C652E646973706C6179203D2027626C6F636B273B0D0A202020202020202020207D20656C7365207B0D0A20';
wwv_flow_imp.g_varchar2_table(131) := '202020202020202020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E676574427574746F6E28292E7374796C652E646973706C6179203D20276E6F6E65273B0D0A202020202020202020207D0D0A20202020202020207D0D0A20202020';
wwv_flow_imp.g_varchar2_table(132) := '20207D0D0A202020207D0D0A20207D3B0D0A0D0A2020636F6E7374206F6E4D6F64654368616E6765203D202829203D3E207B0D0A20202020636F6E7374206D6F6465203D20647261772E6765744D6F646528293B0D0A0D0A2020202069662028705F7368';
wwv_flow_imp.g_varchar2_table(133) := '6F775F636F6F72647329207B0D0A202020202020696620286D6F6465203D3D3D2022647261775F706F696E742229207B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F636F6F72647327292E63';
wwv_flow_imp.g_varchar2_table(134) := '73732827646973706C6179272C2027626C6F636B27293B0D0A2020202020207D20656C736520696620286D6F6465203D3D3D2022647261775F6C696E655F737472696E6722207C7C206D6F6465203D3D3D2022647261775F706F6C79676F6E2229207B0D';
wwv_flow_imp.g_varchar2_table(135) := '0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F636F6F72647327292E6373732827646973706C6179272C20276E6F6E6527293B0D0A2020202020207D20656C7365207B0D0A202020202020202063';
wwv_flow_imp.g_varchar2_table(136) := '6F6E7374206663203D20647261772E676574416C6C28293B0D0A20202020202020206966202866632E66656174757265732E6C656E677468203E20302026262066632E66656174757265735B305D2E67656F6D657472792E7479706520213D3D2027506F';
wwv_flow_imp.g_varchar2_table(137) := '696E742729207B0D0A20202020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F636F6F72647327292E6373732827646973706C6179272C20276E6F6E6527293B0D0A20202020202020207D0D0A20202020';
wwv_flow_imp.g_varchar2_table(138) := '20207D0D0A202020207D0D0A0D0A2020202075706461746547656F6C6F636174696F6E427574746F6E446973706C617928293B0D0A0D0A20202020617065782E6A517565727928272327202B20705F726567696F6E5F6964202B2027202E6D61706C6962';
wwv_flow_imp.g_varchar2_table(139) := '7265676C2D63616E76617327292E746F67676C65436C61737328276D6170626974732D647261772D63726F7373686169722D637572736F72272C205B27647261775F706F696E74272C2027647261775F6C696E655F737472696E67272C2027647261775F';
wwv_flow_imp.g_varchar2_table(140) := '706F6C79676F6E275D2E696E636C75646573286D6F646529293B0D0A20207D3B0D0A0D0A2020617065782E6974656D2E63726561746528705F6974656D5F69642C207B0D0A2020202073657447656F6D657472793A202867656F6D6574727929203D3E20';
wwv_flow_imp.g_varchar2_table(141) := '7B0D0A20202020202070656E64696E674D61702E7468656E282829203D3E207B0D0A2020202020202020647261772E736574287B0D0A20202020202020202020747970653A202746656174757265436F6C6C656374696F6E272C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(142) := '202066656174757265733A205B7B0D0A202020202020202020202020747970653A202746656174757265272C0D0A20202020202020202020202067656F6D657472792C0D0A20202020202020202020202070726F706572746965733A207B7D2C0D0A2020';
wwv_flow_imp.g_varchar2_table(143) := '20202020202020207D5D0D0A20202020202020207D293B0D0A0D0A202020202020202069662028705F73686F775F636F6F72647329207B0D0A2020202020202020202073796E63436F6F72647346726F6D47656F6D657472792867656F6D65747279293B';
wwv_flow_imp.g_varchar2_table(144) := '0D0A20202020202020207D0D0A0D0A2020202020202020777269746547656F6D65747279284A534F4E2E737472696E676966792867656F6D6574727929293B0D0A0D0A2020202020202020647261772E6368616E67654D6F6465282773696D706C655F73';
wwv_flow_imp.g_varchar2_table(145) := '656C65637427293B0D0A20202020202020206F6E4D6F64654368616E676528293B0D0A2020202020207D293B0D0A202020207D2C0D0A0D0A2020202067657447656F6D657472793A202829203D3E207B0D0A202020202020696620286D6170203D3D206E';
wwv_flow_imp.g_varchar2_table(146) := '756C6C29207B0D0A202020202020202072657475726E20705F67656F6D65747279203F3F206E756C6C3B0D0A2020202020207D20656C7365207B0D0A2020202020202020636F6E7374206665617473203D20647261772E676574416C6C28293B0D0A2020';
wwv_flow_imp.g_varchar2_table(147) := '2020202020206966202866656174732E66656174757265732E6C656E677468203D3D3D203029207B0D0A2020202020202020202072657475726E206E756C6C3B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202072657475726E';
wwv_flow_imp.g_varchar2_table(148) := '2066656174732E66656174757265735B305D2E67656F6D657472793B0D0A20202020202020207D0D0A2020202020207D0D0A202020207D2C0D0A0D0A202020206765744D61703A206173796E63202829203D3E207B0D0A20202020202072657475726E20';
wwv_flow_imp.g_varchar2_table(149) := '61776169742070656E64696E674D61703B0D0A202020207D2C0D0A0D0A20202020676574447261773A202829203D3E20647261772C0D0A0D0A202020206765745374796C65733A202829203D3E207374796C65732C0D0A202020207365745374796C6573';
wwv_flow_imp.g_varchar2_table(150) := '3A20286E65775374796C657329203D3E207B0D0A202020202020696620286472617729207B0D0A20202020202020207468726F77206E6577204572726F72282243616E6E6F7420736574207374796C6573206166746572207468652064726177696E6720';
wwv_flow_imp.g_varchar2_table(151) := '706C7567696E20686173206265656E20696E697469616C697A65642E22293B0D0A2020202020207D0D0A2020202020207374796C6573203D206E65775374796C65733B0D0A202020207D2C0D0A20207D293B0D0A20200D0A202069662028747970656F66';
wwv_flow_imp.g_varchar2_table(152) := '20696E69744A73203D3D3D202766756E6374696F6E2729207B0D0A20202020696E69744A7328617065782E6974656D28705F6974656D5F696429293B0D0A20207D0D0A0D0A20202F2F2043726561746520746865206472617720746F6F6C2E20506F696E';
wwv_flow_imp.g_varchar2_table(153) := '742067656F6D657472792077617320746F6F20736D616C6C2C20736F2049206D616465206974206C61726765723B205374796C6520697320636F706965642066726F6D206D6170626F782D64726177202F6C69622F7468656D652E6A7320776974682069';
wwv_flow_imp.g_varchar2_table(154) := '6E6372656173656420706F696E742073697A652E200D0A202064726177203D206E6577204D6170626F7844726177287B0D0A20202020646973706C6179436F6E74726F6C7344656661756C743A2066616C73652C0D0A202020207374796C65732C0D0A20';
wwv_flow_imp.g_varchar2_table(155) := '202020636F6E74726F6C733A207B0D0A202020202020706F696E743A20705F67656F6D657472795F6D6F6465732E696E6465784F662822504F494E542229203E202D312C0D0A2020202020206C696E655F737472696E673A20705F67656F6D657472795F';
wwv_flow_imp.g_varchar2_table(156) := '6D6F6465732E696E6465784F6628224C494E452229203E202D312C0D0A202020202020706F6C79676F6E3A20705F67656F6D657472795F6D6F6465732E696E6465784F662822504F4C59474F4E2229203E202D312C0D0A20202020202074726173683A20';
wwv_flow_imp.g_varchar2_table(157) := '21705F726561646F6E6C792C0D0A2020202020206D6F6465733A206D6F6465730D0A202020207D2C0D0A20207D293B0D0A0D0A202070656E64696E674D61702E7468656E28286D617029203D3E207B0D0A202020202F2F2049662074686520446973706C';
wwv_flow_imp.g_varchar2_table(158) := '617920436F6F7264696E61746573206174747269627574652069732059657320616E642074686520696E697469616C2067656F6D65747279206973206120706F696E74206F72207468657265206973206E6F20696E697469616C2067656F6D657472792C';
wwv_flow_imp.g_varchar2_table(159) := '2073686F7720636F6F7264696E617465206461746120656E747279206669656C64732E0D0A202020206C657420646973706C61795F636F6F726473203D20226E6F6E65223B0D0A2020202069662028705F73686F775F636F6F72647329207B0D0A202020';
wwv_flow_imp.g_varchar2_table(160) := '20202069662028705F67656F6D6574727920213D206E756C6C29207B0D0A202020202020202069662028705F67656F6D657472792E74797065203D3D2022506F696E742229207B0D0A20202020202020202020646973706C61795F636F6F726473203D20';
wwv_flow_imp.g_varchar2_table(161) := '27626C6F636B273B0D0A20202020202020207D0D0A2020202020207D20656C7365207B0D0A202020202020202069662028705F67656F6D657472795F6D6F6465732E696E6465784F662822504F494E542229203E202D3129207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(162) := '2020646973706C61795F636F6F726473203D2027626C6F636B273B0D0A20202020202020207D0D0A2020202020207D0D0A202020202020636F6E737420636F6F7264666F726D203D202428603C64697620616C69676E3D226C6566742220636C6173733D';
wwv_flow_imp.g_varchar2_table(163) := '2275692D7769646765742D68656164657220742D526567696F6E2D6865616465722075692D636F726E65722D616C6C206D6170626974732D647261772D636F6F7264666F726D223E60290D0A20202020202020202E70726F7028276964272C20705F6974';
wwv_flow_imp.g_varchar2_table(164) := '656D5F6964202B20275F636F6F72647327290D0A20202020202020202E637373287B0D0A20202020202020202020646973706C61793A20646973706C61795F636F6F7264732C0D0A20202020202020207D290D0A20202020202020202E617070656E6428';
wwv_flow_imp.g_varchar2_table(165) := '0D0A202020202020202020202428603C64697620636C6173733D226D6170626974732D647261772D636F6F7264666F726D2D726F77223E60290D0A2020202020202020202020202E617070656E64282428603C6C6162656C20636C6173733D226D622D6C';
wwv_flow_imp.g_varchar2_table(166) := '6F6E223E3C2F6C6162656C3E6029290D0A2020202020202020202020202E617070656E64282428603C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E60292E70726F7028276964272C20705F';
wwv_flow_imp.g_varchar2_table(167) := '6974656D5F6964202B20275F6C6F6E6769747564655F6465677265657327292E70726F702827726561646F6E6C79272C20705F726561646F6E6C7929290D0A2020202020202020202020202E617070656E64282428603C6C6162656C20636C6173733D22';
wwv_flow_imp.g_varchar2_table(168) := '6D622D6C6162656C2D646567223E3C2F6C6162656C3E60292E70726F702827666F72272C20705F6974656D5F6964202B20275F6C6F6E6769747564655F646567726565732729290D0A2020202020202020202020202E617070656E64282428603C696E70';
wwv_flow_imp.g_varchar2_table(169) := '757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E60292E70726F7028276964272C20705F6974656D5F6964202B20275F6C6F6E6769747564655F6D696E7574657327292E70726F702827726561646F6E';
wwv_flow_imp.g_varchar2_table(170) := '6C79272C20705F726561646F6E6C7929290D0A2020202020202020202020202E617070656E64282428603C6C6162656C20636C6173733D226D622D6C6162656C2D6D696E223E3C2F6C6162656C3E60292E70726F702827666F72272C20705F6974656D5F';
wwv_flow_imp.g_varchar2_table(171) := '6964202B20275F6C6F6E6769747564655F6D696E757465732729290D0A2020202020202020202020202E617070656E64282428603C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E60292E70';
wwv_flow_imp.g_varchar2_table(172) := '726F7028276964272C20705F6974656D5F6964202B20275F6C6F6E6769747564655F7365636F6E647327292E70726F702827726561646F6E6C79272C20705F726561646F6E6C7929290D0A2020202020202020202020202E617070656E64282428603C6C';
wwv_flow_imp.g_varchar2_table(173) := '6162656C20636C6173733D226D622D6C6162656C2D736563223E3C2F6C6162656C3E60292E70726F702827666F72272C20705F6974656D5F6964202B20275F6C6F6E6769747564655F7365636F6E64732729290D0A2020202020202020290D0A20202020';
wwv_flow_imp.g_varchar2_table(174) := '202020202E617070656E64280D0A202020202020202020202428603C64697620636C6173733D226D6170626974732D647261772D636F6F7264666F726D2D726F77223E60290D0A2020202020202020202020202E617070656E64282428603C6C6162656C';
wwv_flow_imp.g_varchar2_table(175) := '20636C6173733D226D622D6C6174223E3C2F6C6162656C3E6029290D0A2020202020202020202020202E617070656E64282428603C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E60292E70';
wwv_flow_imp.g_varchar2_table(176) := '726F7028276964272C20705F6974656D5F6964202B20275F6C617469747564655F6465677265657327292E70726F702827726561646F6E6C79272C20705F726561646F6E6C7929290D0A2020202020202020202020202E617070656E64282428603C6C61';
wwv_flow_imp.g_varchar2_table(177) := '62656C20636C6173733D226D622D6C6162656C2D646567223E3C2F6C6162656C3E60292E70726F702827666F72272C20705F6974656D5F6964202B20275F6C617469747564655F646567726565732729290D0A2020202020202020202020202E61707065';
wwv_flow_imp.g_varchar2_table(178) := '6E64282428603C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E60292E70726F7028276964272C20705F6974656D5F6964202B20275F6C617469747564655F6D696E7574657327292E70726F';
wwv_flow_imp.g_varchar2_table(179) := '702827726561646F6E6C79272C20705F726561646F6E6C7929290D0A2020202020202020202020202E617070656E64282428603C6C6162656C20636C6173733D226D622D6C6162656C2D6D696E223E3C2F6C6162656C3E60292E70726F702827666F7227';
wwv_flow_imp.g_varchar2_table(180) := '2C20705F6974656D5F6964202B20275F6C617469747564655F6D696E757465732729290D0A2020202020202020202020202E617070656E64282428603C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C64';
wwv_flow_imp.g_varchar2_table(181) := '22202F3E60292E70726F7028276964272C20705F6974656D5F6964202B20275F6C617469747564655F7365636F6E647327292E70726F702827726561646F6E6C79272C20705F726561646F6E6C7929290D0A2020202020202020202020202E617070656E';
wwv_flow_imp.g_varchar2_table(182) := '64282428603C6C6162656C20636C6173733D226D622D6C6162656C2D736563223E3C2F6C6162656C3E60292E70726F702827666F72272C20705F6974656D5F6964202B20275F6C617469747564655F7365636F6E64732729290D0A202020202020202029';
wwv_flow_imp.g_varchar2_table(183) := '3B0D0A202020202020617065782E6A517565727928272327202B20705F726567696F6E5F6964202B20275F6D61705F726567696F6E27292E617070656E6428636F6F7264666F726D293B0D0A202020207D0D0A0D0A202020206D61702E64726177203D20';
wwv_flow_imp.g_varchar2_table(184) := '647261773B0D0A2020202069662028705F656E61626C655F67656F6C6F6361746529207B0D0A2020202020206D61702E616464436F6E74726F6C2867656F6C6F636174655F706F696E745F636F6E74726F6C293B0D0A202020207D0D0A0D0A202020206D';
wwv_flow_imp.g_varchar2_table(185) := '61702E616464436F6E74726F6C2864726177293B0D0A202020202F2F204163636F6D6F6461746520626F7468204D6170626F7820696E204150455820323120616E64204D61706C6962726520696E20415045582032322E0D0A20202020617065782E6A51';
wwv_flow_imp.g_varchar2_table(186) := '7565727928272E6D6170626F78676C2D6374726C2D67726F757027292E616464436C61737328276D61706C69627265676C2D6374726C2D67726F757027293B0D0A20202020617065782E6A517565727928272E6D6170626F78676C2D6374726C27292E61';
wwv_flow_imp.g_varchar2_table(187) := '6464436C61737328276D61706C69627265676C2D6374726C27293B0D0A0D0A20202020636F6E73742073746F70456E746572203D20286576656E7429203D3E207B0D0A2020202020202F2F206D616B652073757265207072657373696E6720656E746572';
wwv_flow_imp.g_varchar2_table(188) := '20646F65736E2774207375626D6974207468652070616765206F72207072657373206120627574746F6E0D0A202020202020696620286576656E743F2E6B6579203D3D3D2027456E7465722729207B0D0A20202020202020206576656E742E7072657665';
wwv_flow_imp.g_varchar2_table(189) := '6E7444656661756C7428293B0D0A2020202020207D0D0A202020207D3B0D0A0D0A202020202F2F20696E697469616C697A65206C617469747564652F6C6F6E676974756465206461746120656E747279206669656C64730D0A2020202069662028705F73';
wwv_flow_imp.g_varchar2_table(190) := '686F775F636F6F72647329207B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6F6E6769747564655F6465677265657327292E6368616E67652873796E6347656F6D6574727946726F6D436F6F72';
wwv_flow_imp.g_varchar2_table(191) := '64696E61746573292E6B657970726573732873746F70456E746572293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6F6E6769747564655F6D696E7574657327292E6368616E67652873796E63';
wwv_flow_imp.g_varchar2_table(192) := '47656F6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F70456E746572293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6F6E6769747564655F7365636F6E';
wwv_flow_imp.g_varchar2_table(193) := '647327292E6368616E67652873796E6347656F6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F70456E746572293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B2027';
wwv_flow_imp.g_varchar2_table(194) := '5F6C617469747564655F6465677265657327292E6368616E67652873796E6347656F6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F70456E746572293B0D0A202020202020617065782E6A51756572792827232720';
wwv_flow_imp.g_varchar2_table(195) := '2B20705F6974656D5F6964202B20275F6C617469747564655F6D696E7574657327292E6368616E67652873796E6347656F6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F70456E746572293B0D0A20202020202061';
wwv_flow_imp.g_varchar2_table(196) := '7065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C617469747564655F7365636F6E647327292E6368616E67652873796E6347656F6D6574727946726F6D436F6F7264696E61746573292E6B657970726573732873746F7045';
wwv_flow_imp.g_varchar2_table(197) := '6E746572293B0D0A202020207D0D0A0D0A202020202F2F20696620746865726520697320616E20696E697469616C2067656F6D657472792C2061646420697420746F20746865206D617020616E642070616E20746F2069742C207A6F6F6D20746F206974';
wwv_flow_imp.g_varchar2_table(198) := '20696620697427732061206C696E65206F7220706F6C79676F6E2E0D0A2020202069662028705F67656F6D6574727920213D206E756C6C20262620705F67656F6D6574727920213D20222229207B0D0A202020202020647261772E61646428705F67656F';
wwv_flow_imp.g_varchar2_table(199) := '6D65747279293B200D0A20202020202069662028705F67656F6D657472792E74797065203D3D2022506F696E742229207B0D0A202020202020202069662028705F73686F775F636F6F72647329207B0D0A2020202020202020202073796E63436F6F7264';
wwv_flow_imp.g_varchar2_table(200) := '7346726F6D47656F6D6574727928705F67656F6D65747279293B0D0A20202020202020207D0D0A20202020202020202F2F207265706C61636564206D6F7665746F20616E642073657463656E7465722077697468206A756D70746F20746F206669782070';
wwv_flow_imp.g_varchar2_table(201) := '726F626C656D20776974682066697273742072656E6465722E0D0A2020202020202020747279207B0D0A202020202020202020206D61702E6A756D70546F287B63656E7465723A20705F67656F6D657472792E636F6F7264696E617465732C207A6F6F6D';
wwv_flow_imp.g_varchar2_table(202) := '203A20705F706F696E745F7A6F6F6D5F6C6576656C2C206475726174696F6E3A20323030307D293B0D0A20202020202020207D2063617463682028657863707429207B0D0A20202020202020202020636F6E736F6C652E6C6F6728275B4D617062697473';
wwv_flow_imp.g_varchar2_table(203) := '20447261775D204661696C656420746F206A756D7020746F20696E697469616C206C6F636174696F6E2E27293B0D0A20202020202020207D0D0A2020202020207D20656C7365207B0D0A20202020202020207661722062203D20676574426F756E647328';
wwv_flow_imp.g_varchar2_table(204) := '705F67656F6D65747279293B0D0A20202020202020206D61702E666974426F756E647328622C207B70616464696E673A2035307D293B0D0A2020202020207D0D0A202020207D0D0A0D0A2020202069662028705F726561646F6E6C7929207B0D0A202020';
wwv_flow_imp.g_varchar2_table(205) := '202020647261772E6368616E67654D6F6465282773746174696327293B0D0A202020207D0D0A0D0A20202020647261777665727469636573203D207B6964203A20373938312C2074797065203A202246656174757265222C2070726F7065727469657320';
wwv_flow_imp.g_varchar2_table(206) := '3A207B7D2C2067656F6D65747279203A207B747970653A20224C696E65537472696E67222C20636F6F7264696E61746573203A205B5D7D7D3B0D0A0D0A202020202F2F2048616E646C6520647261772066696E6973686564206576656E743A2077726974';
wwv_flow_imp.g_varchar2_table(207) := '652067656F6D65747279200D0A202020202F2F20746F204150455820636F6C6C656374696F6E207573696E6720616A61782063616C6C6261636B2E0D0A202020202F2F2049662074686520636F6F7264696E6174657320656E747279206669656C647320';
wwv_flow_imp.g_varchar2_table(208) := '617265207475726E6564206F6E2C0D0A202020202F2F20757064617465207468656D207769746820746865206E657720636F6F7264696E617465732066726F6D2074686520506F696E74200D0A202020202F2F2067656F6D657472792E0D0A202020206D';
wwv_flow_imp.g_varchar2_table(209) := '61702E6F6E2822647261772E637265617465222C2066756E6374696F6E286529207B0D0A2020202020206C6574206665617473203D20647261772E676574416C6C28293B0D0A202020202020666F72286C65742069203D20303B2069203C206665617473';
wwv_flow_imp.g_varchar2_table(210) := '2E66656174757265732E6C656E677468202D20313B2069202B2B29207B0D0A202020202020202069662028652E66656174757265735B305D2E696420213D2066656174732E66656174757265735B695D2E696429207B0D0A202020202020202020206472';
wwv_flow_imp.g_varchar2_table(211) := '61772E64656C6574652866656174732E66656174757265735B695D2E6964293B0D0A20202020202020207D0D0A2020202020207D0D0A2020202020206665617473203D20647261772E676574416C6C28293B0D0A202020202020636F6E73742067656F6D';
wwv_flow_imp.g_varchar2_table(212) := '203D2066656174732E66656174757265735B305D2E67656F6D657472793B0D0A20202020202069662028705F73686F775F636F6F72647329207B0D0A202020202020202073796E63436F6F72647346726F6D47656F6D657472792867656F6D293B0D0A20';
wwv_flow_imp.g_varchar2_table(213) := '20202020207D0D0A202020202020777269746547656F6D65747279284A534F4E2E737472696E676966792867656F6D29293B0D0A202020207D293B0D0A0D0A202020206D61702E6F6E2822647261772E757064617465222C2066756E6374696F6E286529';
wwv_flow_imp.g_varchar2_table(214) := '207B0D0A202020202020636F6E7374206665617473203D20647261772E676574416C6C28293B0D0A202020202020636F6E73742067656F6D203D2066656174732E66656174757265735B305D2E67656F6D657472793B0D0A20202020202069662028705F';
wwv_flow_imp.g_varchar2_table(215) := '73686F775F636F6F72647329207B0D0A202020202020202073796E63436F6F72647346726F6D47656F6D657472792867656F6D293B0D0A2020202020207D0D0A202020202020777269746547656F6D65747279284A534F4E2E737472696E676966792867';
wwv_flow_imp.g_varchar2_table(216) := '656F6D29293B0D0A202020207D293B0D0A0D0A202020206D61702E6F6E2822647261772E64656C657465222C2066756E6374696F6E286529207B0D0A20202020202069662028705F73686F775F636F6F72647329207B0D0A202020202020202061706578';
wwv_flow_imp.g_varchar2_table(217) := '2E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F6465677265657322292E76616C282727293B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F';
wwv_flow_imp.g_varchar2_table(218) := '6E6769747564655F6D696E7574657322292E76616C282727293B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C6F6E6769747564655F7365636F6E647322292E76616C282727293B0D0A2020';
wwv_flow_imp.g_varchar2_table(219) := '202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F6465677265657322292E76616C282727293B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F';
wwv_flow_imp.g_varchar2_table(220) := '6964202B20225F6C617469747564655F6D696E7574657322292E76616C282727293B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20225F6C617469747564655F7365636F6E647322292E76616C2827';
wwv_flow_imp.g_varchar2_table(221) := '27293B0D0A2020202020207D0D0A202020202020777269746547656F6D65747279286E756C6C293B0D0A202020207D293B0D0A0D0A202020202F2F2049662074686520636F6F7264696E6174657320656E747279206669656C647320617265207475726E';
wwv_flow_imp.g_varchar2_table(222) := '6564206F6E2C2073686F77207468656D200D0A202020202F2F207768656E207468652064726177696E67206D6F646520697320506F696E742E204F74686572776973652C2068696465207468656D2E0D0A202020202F2F20456E61626C652047656F6C6F';
wwv_flow_imp.g_varchar2_table(223) := '6361746520506F696E7420746F6F6C20627574746F6E206966207573657220697320696E206472617720706F696E74206D6F6465206F7220696620746865207665727465780D0A202020202F2F206F6E2061206E6F6E2D706F696E742067656F6D657472';
wwv_flow_imp.g_varchar2_table(224) := '792069732073656C65637465642E0D0A202020206D61702E6F6E2822647261772E6D6F64656368616E6765222C206F6E4D6F64654368616E6765293B0D0A0D0A202020206D61702E6F6E2822647261772E73656C656374696F6E6368616E6765222C2066';
wwv_flow_imp.g_varchar2_table(225) := '756E6374696F6E286529207B0D0A20202020202075706461746547656F6C6F636174696F6E427574746F6E446973706C617928293B0D0A202020207D293B0D0A0D0A2020202066756E6374696F6E2075706461746546726F6D436F6F7264696E61746528';
wwv_flow_imp.g_varchar2_table(226) := '636F6F7264696E61746529207B0D0A202020202020696620286D6F6465203D3D3D2027647261775F706F696E742729207B0D0A20202020202020202F2F206D6F6465206973206472617720706F696E743B207365742074686520706F696E74206C6F6361';
wwv_flow_imp.g_varchar2_table(227) := '74696F6E2066726F6D207468652067656F6C6F6361746F722E0D0A2020202020202020647261772E736574287B747970653A202746656174757265436F6C6C656374696F6E272C206665617475726573203A5B7B74797065203A20224665617475726522';
wwv_flow_imp.g_varchar2_table(228) := '2C2070726F70657274696573203A207B7D2C2067656F6D65747279203A207B74797065203A2022506F696E74222C20636F6F7264696E61746573203A20636F6F7264696E6174657D7D5D7D293B0D0A0D0A20202020202020202F2F204E65656420746F20';
wwv_flow_imp.g_varchar2_table(229) := '6D6F7665207468697320736F6D65776865726520656C736520696620706F737369626C652E0D0A202020202020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E676574427574746F6E28292E7374796C652E646973706C6179203D2027';
wwv_flow_imp.g_varchar2_table(230) := '6E6F6E65273B0D0A2020202020207D20656C736520696620286D6F6465203D3D3D202773696D706C655F73656C6563742729207B0D0A202020202020202069662028647261772E67657453656C656374656428292E66656174757265732E6C656E677468';
wwv_flow_imp.g_varchar2_table(231) := '203E203029207B0D0A202020202020202020207661722073656C656374656446656174757265203D20647261772E67657453656C656374656428292E66656174757265735B305D3B0D0A2020202020202020202073656C6563746564466561747572652E';
wwv_flow_imp.g_varchar2_table(232) := '67656F6D657472792E636F6F7264696E617465735B305D203D20636F6F7264696E6174655B305D3B0D0A2020202020202020202073656C6563746564466561747572652E67656F6D657472792E636F6F7264696E617465735B315D203D20636F6F726469';
wwv_flow_imp.g_varchar2_table(233) := '6E6174655B315D3B0D0A202020202020202020202020647261772E736574287B747970653A202246656174757265436F6C6C656374696F6E222C206665617475726573203A5B73656C6563746564466561747572655D7D293B0D0A20202020202020207D';
wwv_flow_imp.g_varchar2_table(234) := '0D0A2020202020207D20656C736520696620286D6F6465203D3D3D20276469726563745F73656C6563742729207B0D0A20202020202020202F2F206469726563742073656C6563743A206120766572746578206F66206120706F6C79676F6E206F72206C';
wwv_flow_imp.g_varchar2_table(235) := '696E65737472696E672069732073656C65637465642E204D6F76650D0A20202020202020202F2F207468652073656C65637465642076657274657820746F207468652067656F6C6F636174696F6E20636F6F7264696E6174652E0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(236) := '7661722073656C656374656446656174757265203D20647261772E67657453656C656374656428292E66656174757265735B305D3B0D0A20202020202020207661722073656C6563746564436F6F726473203D20647261772E67657453656C6563746564';
wwv_flow_imp.g_varchar2_table(237) := '506F696E747328292E66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465733B0D0A0D0A202020202020202066756E6374696F6E205F5F736574436F6F726428636F6F7264417272617929207B0D0A2020202020202020202066';
wwv_flow_imp.g_varchar2_table(238) := '6F722028766172206A3D303B6A3C636F6F726441727261792E6C656E6774683B6A2B2B29207B0D0A2020202020202020202020206966202873656C6563746564436F6F7264735B305D203D3D20636F6F726441727261795B6A5D5B305D2026262073656C';
wwv_flow_imp.g_varchar2_table(239) := '6563746564436F6F7264735B315D203D3D20636F6F726441727261795B6A5D5B315D29207B0D0A2020202020202020202020202020636F6F726441727261795B6A5D5B305D203D20636F6F7264696E6174655B305D3B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(240) := '2020636F6F726441727261795B6A5D5B315D203D20636F6F7264696E6174655B315D3B0D0A2020202020202020202020207D0D0A202020202020202020207D0D0A20202020202020207D0D0A20202020202020206966202873656C656374656446656174';
wwv_flow_imp.g_varchar2_table(241) := '7572652E67656F6D657472792E74797065203D3D3D20274C696E65537472696E672729207B0D0A202020202020202020205F5F736574436F6F72642873656C6563746564466561747572652E67656F6D657472792E636F6F7264696E61746573293B0D0A';
wwv_flow_imp.g_varchar2_table(242) := '20202020202020207D20656C7365206966202873656C6563746564466561747572652E67656F6D657472792E74797065203D3D3D2027506F6C79676F6E2729207B0D0A20202020202020202020666F722028766172206B203D20303B206B203C2073656C';
wwv_flow_imp.g_varchar2_table(243) := '6563746564466561747572652E67656F6D657472792E636F6F7264696E617465732E6C656E6774683B206B202B2B29207B0D0A2020202020202020202020205F5F736574436F6F72642873656C6563746564466561747572652E67656F6D657472792E63';
wwv_flow_imp.g_varchar2_table(244) := '6F6F7264696E617465735B6B5D293B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020202020647261772E736574287B20747970653A202246656174757265436F6C6C656374696F6E222C2066656174757265733A205B7365';
wwv_flow_imp.g_varchar2_table(245) := '6C6563746564466561747572655D207D293B0D0A2020202020207D0D0A202020207D0D0A0D0A2020202069662028705F656E61626C655F67656F6C6F6361746529207B0D0A20202020202067656F6C6F636174655F706F696E745F636F6E74726F6C2E67';
wwv_flow_imp.g_varchar2_table(246) := '6574427574746F6E28292E6F6E636C69636B203D2066756E6374696F6E286529207B0D0A2020202020202020636F6E7374206D6F6465203D20647261772E6765744D6F646528293B0D0A0D0A2020202020202020696620285B27647261775F706F696E74';
wwv_flow_imp.g_varchar2_table(247) := '272C20276469726563745F73656C656374272C202773696D706C655F73656C656374275D2E696E636C75646573286D6F64652929207B0D0A20202020202020202020696620286E6176696761746F722E67656F6C6F636174696F6E29207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(248) := '20202020202020206E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E2866756E6374696F6E28706F73297B0D0A202020202020202020202020202075706461746546726F6D436F6F7264696E61746528';
wwv_flow_imp.g_varchar2_table(249) := '5B706F732E636F6F7264732E6C6F6E6769747564652C20706F732E636F6F7264732E6C617469747564655D293B0D0A20202020202020202020202020200D0A2020202020202020202020207D2C2066756E6374696F6E2865727229207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(250) := '2020202020202020202F2F20756E636F6D6D656E74207468697320746F207465737420696E204368726F6D652E0D0A202020202020202020202020202075706461746546726F6D436F6F7264696E617465285B2D3930202B2028302E30312A4D6174682E';
wwv_flow_imp.g_varchar2_table(251) := '72616E646F6D2829202D20302E303035292C203330202B2028302E30312A4D6174682E72616E646F6D2829202D20302E303035295D293B0D0A2020202020202020202020207D293B0D0A202020202020202020207D20656C7365207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(252) := '202020202020617065785F616C657274282747656F6C6F636174696F6E206E6F7420737570706F727465642E27293B0D0A202020202020202020207D0D0A20202020202020207D20656C736520696620285B27647261775F6C696E655F737472696E6727';
wwv_flow_imp.g_varchar2_table(253) := '2C2027647261775F706F6C79676F6E275D2E696E636C75646573286D6F64652929207B0D0A202020202020202020206D61702E676574436F6E7461696E657228292E64697370617463684576656E74286E6577204B6579626F6172644576656E7428276B';
wwv_flow_imp.g_varchar2_table(254) := '65797570272C207B206B65793A20276027207D29293B0D0A20202020202020207D0D0A2020202020207D3B0D0A202020207D0D0A20207D293B0D0A7D0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43387390325713255)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbits-draw.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D6170626974732D647261772D63726F737368616972207B706F736974696F6E3A206162736F6C7574653B746F703A203530253B6C6566743A203530253B7472616E73666F726D3A207472616E736C617465282D3530252C202D353025293B7D2E6D61';
wwv_flow_imp.g_varchar2_table(2) := '70626974732D647261772D63726F7373686169722D637572736F72207B637572736F723A2075726C28646174613A696D6167652F7376672B786D6C3B6261736536342C50484E325A79423361575230614430694D6A55694947686C6157646F644430694D';
wwv_flow_imp.g_varchar2_table(3) := '6A556949485A705A58644362336739496A41674D4341324C6A59784E5341324C6A59784E53496765473173626E4D39496D6830644841364C79393364336375647A4D7562334A6E4C7A49774D44417663335A6E496A3438634746306143426B50534A4E4D';
wwv_flow_imp.g_varchar2_table(4) := '6934784D5463674D7934784E7A56494C6A49324E5859754D6A5931614445754F445579646930754D6A5931625451754D6A4D7A494442494E4334304F5468324C6A49324E5567324C6A4D31646930754D6A593154544D754E4451674E69347A4E5659304C';
wwv_flow_imp.g_varchar2_table(5) := '6A51354F4767744C6A49324E5659324C6A4D31614334794E6A56744D4330304C6A497A4D3159754D6A5931614330754D6A5931646A45754F445579614334794E6A56744C5334794E6A55674D5334774E5468324C6A49324E5767754D6A5931646930754D';
wwv_flow_imp.g_varchar2_table(6) := '6A5931614330754D6A59314969427A64486C735A54306963474670626E517462334A6B5A58493662574679613256796379427A64484A76613255675A6D6C7362434967633352796232746C5053496A5A6D5A6D4969427A64484A766132557462476C755A';
wwv_flow_imp.g_varchar2_table(7) := '574E68634430696333463159584A6C4969427A64484A766132557464326C6B64476739496934314D6A6B694C7A34384C334E325A7A343D292031322E352031322E352C206175746F2021696D706F7274616E743B7D2E6D6170626974732D647261772D63';
wwv_flow_imp.g_varchar2_table(8) := '6F6F7264666F726D207B646973706C61793A207461626C653B6D617267696E3A20303B70616464696E673A203470783B7D2E6D6170626974732D647261772D636F6F7264666F726D2D726F77207B646973706C61793A207461626C652D726F773B7D2E6D';
wwv_flow_imp.g_varchar2_table(9) := '6170626974732D647261772D636F6F7264666F726D2D726F77203E202A207B646973706C61793A207461626C652D63656C6C3B7D2E6D6170626974732D647261772D636F6F7264666F726D20696E707574207B6D617267696E2D696E6C696E652D737461';
wwv_flow_imp.g_varchar2_table(10) := '72743A2031656D3B6D617267696E2D696E6C696E652D656E643A202E33656D3B77696474683A2038656D3B7D406D6564696120286D696E2D77696474683A20353072656D29207B2E6D622D6C6F6E3A3A6265666F7265207B636F6E74656E743A20224C6F';
wwv_flow_imp.g_varchar2_table(11) := '6E6769747564653A223B7D2E6D622D6C61743A3A6265666F7265207B636F6E74656E743A20224C617469747564653A223B7D2E6D622D6C6162656C2D6465673A3A6166746572207B636F6E74656E743A20222044656772656573223B7D2E6D622D6C6162';
wwv_flow_imp.g_varchar2_table(12) := '656C2D6D696E3A3A6166746572207B636F6E74656E743A2022204D696E75746573223B7D2E6D622D6C6162656C2D7365633A3A6166746572207B636F6E74656E74203A2022205365636F6E6473223B7D7D406D6564696120286D61782D77696474683A20';
wwv_flow_imp.g_varchar2_table(13) := '353072656D29207B2E6D622D6C6F6E3A3A6265666F7265207B636F6E74656E74203A20224C6F6E20223B7D2E6D622D6C61743A3A6265666F7265207B636F6E74656E74203A20224C617420223B7D2E6D622D6C6162656C2D6465673A3A6166746572207B';
wwv_flow_imp.g_varchar2_table(14) := '636F6E74656E74203A2022C2B0223B7D2E6D622D6C6162656C2D6D696E3A3A6166746572207B636F6E74656E74203A20225C27223B7D2E6D622D6C6162656C2D7365633A3A6166746572207B636F6E74656E74203A20225C22223B7D7D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43387730700713255)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbits-draw.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '0A2F2A204F766572726964652064656661756C7420636F6E74726F6C207374796C65202A2F0A2E6D6170626F782D676C2D647261775F6374726C2D626F74746F6D2D6C6566742C0A2E6D6170626F782D676C2D647261775F6374726C2D746F702D6C6566';
wwv_flow_imp.g_varchar2_table(2) := '74207B0A20206D617267696E2D6C6566743A303B0A2020626F726465722D7261646975733A30203470782034707820303B0A7D0A2E6D6170626F782D676C2D647261775F6374726C2D746F702D72696768742C0A2E6D6170626F782D676C2D647261775F';
wwv_flow_imp.g_varchar2_table(3) := '6374726C2D626F74746F6D2D7269676874207B0A20206D617267696E2D72696768743A303B0A2020626F726465722D7261646975733A34707820302030203470783B0A7D0A0A2E6D6170626F782D676C2D647261775F6374726C2D647261772D62746E20';
wwv_flow_imp.g_varchar2_table(4) := '7B0A2020626F726465722D636F6C6F723A7267626128302C302C302C302E39293B0A2020636F6C6F723A72676261283235352C3235352C3235352C302E35293B0A202077696474683A333070783B0A20206865696768743A333070783B0A7D0A0A2E6D61';
wwv_flow_imp.g_varchar2_table(5) := '70626F782D676C2D647261775F6374726C2D647261772D62746E2E6163746976652C0A2E6D6170626F782D676C2D647261775F6374726C2D647261772D62746E2E6163746976653A686F766572207B0A20206261636B67726F756E642D636F6C6F723A72';
wwv_flow_imp.g_varchar2_table(6) := '67622830203020302F3525293B0A7D0A2E6D6170626F782D676C2D647261775F6374726C2D647261772D62746E207B0A20206261636B67726F756E642D7265706561743A206E6F2D7265706561743B0A20206261636B67726F756E642D706F736974696F';
wwv_flow_imp.g_varchar2_table(7) := '6E3A2063656E7465723B0A7D0A0A2E6D6170626F782D676C2D647261775F706F696E74207B0A20206261636B67726F756E642D696D6167653A2075726C2827646174613A696D6167652F7376672B786D6C3B757466382C25334373766720786D6C6E733D';
wwv_flow_imp.g_varchar2_table(8) := '22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D226D31302032632D332E3320302D3620322E372D362036733620392036203920362D352E3720';
wwv_flow_imp.g_varchar2_table(9) := '362D392D322E372D362D362D367A6D30203263322E31203020332E3820312E3720332E3820332E38203020312E352D312E3820332E392D322E3920352E32682D312E37632D312E312D312E342D322E392D332E382D322E392D352E322D2E312D322E3120';
wwv_flow_imp.g_varchar2_table(10) := '312E362D332E3820332E372D332E387A222F3E2533432F7376673E27293B0A7D0A2E6D6170626F782D676C2D647261775F706F6C79676F6E207B0A20206261636B67726F756E642D696D6167653A2075726C2827646174613A696D6167652F7376672B78';
wwv_flow_imp.g_varchar2_table(11) := '6D6C3B757466382C25334373766720786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D226D31352031322E33762D342E36632E36';
wwv_flow_imp.g_varchar2_table(12) := '2D2E3320312D3120312D312E3720302D312E312D2E392D322D322D322D2E3720302D312E342E342D312E372031682D342E36632D2E332D2E362D312D312D312E372D312D312E3120302D32202E392D3220322030202E372E3420312E34203120312E3776';
wwv_flow_imp.g_varchar2_table(13) := '342E36632D2E362E332D3120312D3120312E37203020312E312E39203220322032202E37203020312E342D2E3420312E372D3168342E36632E332E362031203120312E37203120312E31203020322D2E3920322D3220302D2E372D2E342D312E342D312D';
wwv_flow_imp.g_varchar2_table(14) := '312E377A6D2D382D2E33762D346C312D3168346C31203176346C2D312031682D347A222F3E2533432F7376673E27293B0A7D0A2E6D6170626F782D676C2D647261775F6C696E65207B0A20206261636B67726F756E642D696D6167653A2075726C282764';
wwv_flow_imp.g_varchar2_table(15) := '6174613A696D6167652F7376672B786D6C3B757466382C25334373766720786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D226D';
wwv_flow_imp.g_varchar2_table(16) := '31332E3520332E35632D312E3420302D322E3520312E312D322E3520322E352030202E332030202E362E322E396C2D332E3820332E38632D2E332D2E312D2E362D2E322D2E392D2E322D312E3420302D322E3520312E312D322E3520322E3573312E3120';
wwv_flow_imp.g_varchar2_table(17) := '322E3520322E3520322E3520322E352D312E3120322E352D322E3563302D2E3320302D2E362D2E322D2E396C332E382D332E38632E332E312E362E322E392E3220312E34203020322E352D312E3120322E352D322E35732D312E312D322E352D322E352D';
wwv_flow_imp.g_varchar2_table(18) := '322E357A222F3E2533432F7376673E27293B0A7D0A2E6D6170626F782D676C2D647261775F7472617368207B0A20206261636B67726F756E642D696D6167653A2075726C2827646174613A696D6167652F7376672B786D6C3B757466382C253343737667';
wwv_flow_imp.g_varchar2_table(19) := '20786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D224D31302C332E3420632D302E382C302D312E352C302E352D312E382C312E';
wwv_flow_imp.g_varchar2_table(20) := '3248356C2D312C317631683132762D316C2D312D31682D332E324331312E352C332E392C31302E382C332E342C31302C332E347A204D352C38763763302C312C312C322C322C32683663312C302C322D312C322D325638682D3276352E35682D312E3556';
wwv_flow_imp.g_varchar2_table(21) := '38682D332076352E354837563848357A222F3E2533432F7376673E27293B0A7D0A2E6D6170626F782D676C2D647261775F756E636F6D62696E65207B0A20206261636B67726F756E642D696D6167653A2075726C2827646174613A696D6167652F737667';
wwv_flow_imp.g_varchar2_table(22) := '2B786D6C3B757466382C25334373766720786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D226D31322032632D2E3320302D2E35';
wwv_flow_imp.g_varchar2_table(23) := '2E312D2E372E336C2D312031632D2E342E342D2E342031203020312E346C312031632E342E342031202E3420312E3420306C312D31632E342D2E342E342D3120302D312E346C2D312D31632D2E322D2E322D2E342D2E332D2E372D2E337A6D342034632D';
wwv_flow_imp.g_varchar2_table(24) := '2E3320302D2E352E312D2E372E336C2D312031632D2E342E342D2E342031203020312E346C312031632E342E342031202E3420312E3420306C312D31632E342D2E342E342D3120302D312E346C2D312D31632D2E322D2E322D2E342D2E332D2E372D2E33';
wwv_flow_imp.g_varchar2_table(25) := '7A6D2D372031632D3120302D3120312D2E3520312E352E332E3320312031203120316C2D312031732D2E352E352030203120312030203120306C312D3120312031632E352E3520312E352E3520312E352D2E35762D347A6D2D352033632D2E3320302D2E';
wwv_flow_imp.g_varchar2_table(26) := '352E312D2E372E336C2D312031632D2E342E342D2E342031203020312E346C342E3920342E39632E342E342031202E3420312E3420306C312D31632E342D2E342E342D3120302D312E346C2D342E392D342E39632D2E312D2E322D2E342D2E332D2E372D';
wwv_flow_imp.g_varchar2_table(27) := '2E337A222F3E2533432F7376673E27293B0A7D0A2E6D6170626F782D676C2D647261775F636F6D62696E65207B0A20206261636B67726F756E642D696D6167653A2075726C2827646174613A696D6167652F7376672B786D6C3B757466382C2533437376';
wwv_flow_imp.g_varchar2_table(28) := '6720786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D224D31322E312C32632D302E332C302D302E352C302E312D302E372C302E';
wwv_flow_imp.g_varchar2_table(29) := '336C2D312C31632D302E342C302E342D302E342C312C302C312E346C342E392C342E3963302E342C302E342C312C302E342C312E342C306C312D312063302E342D302E342C302E342D312C302D312E346C2D342E392D342E394331322E362C322E312C31';
wwv_flow_imp.g_varchar2_table(30) := '322E332C322C31322E312C327A204D382C3843372C382C372C392C372E352C392E3563302E332C302E332C312C312C312C316C2D312C3163302C302D302E352C302E352C302C3173312C302C312C306C312D316C312C31204331312C31332C31322C3133';
wwv_flow_imp.g_varchar2_table(31) := '2C31322C3132563848387A204D342C3130632D302E332C302D302E352C302E312D302E372C302E336C2D312C31632D302E342C302E342D302E342C312C302C312E346C312C3163302E342C302E342C312C302E342C312E342C306C312D3163302E342D30';
wwv_flow_imp.g_varchar2_table(32) := '2E342C302E342D312C302D312E34206C2D312D3143342E352C31302E312C342E332C31302C342C31307A204D382C3134632D302E332C302D302E352C302E312D302E372C302E336C2D312C31632D302E342C302E342D302E342C312C302C312E346C312C';
wwv_flow_imp.g_varchar2_table(33) := '3163302E342C302E342C312C302E342C312E342C306C312D312063302E342D302E342C302E342D312C302D312E346C2D312D3143382E352C31342E312C382E332C31342C382C31347A222F3E2533432F7376673E27293B0A7D0A0A2E6D6170626F78676C';
wwv_flow_imp.g_varchar2_table(34) := '2D6D61702E6D6F7573652D706F696E746572202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A20706F696E7465723B0A7D0A2E6D6170626F78676C2D';
wwv_flow_imp.g_varchar2_table(35) := '6D61702E6D6F7573652D6D6F7665202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A206D6F76653B0A7D0A2E6D6170626F78676C2D6D61702E6D6F75';
wwv_flow_imp.g_varchar2_table(36) := '73652D616464202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A2063726F7373686169723B0A7D0A2E6D6170626F78676C2D6D61702E6D6F7573652D';
wwv_flow_imp.g_varchar2_table(37) := '6D6F76652E6D6F64652D6469726563745F73656C656374202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A20677261623B0A2020637572736F723A20';
wwv_flow_imp.g_varchar2_table(38) := '2D6D6F7A2D677261623B0A2020637572736F723A202D7765626B69742D677261623B0A7D0A2E6D6170626F78676C2D6D61702E6D6F64652D6469726563745F73656C6563742E666561747572652D7665727465782E6D6F7573652D6D6F7665202E6D6170';
wwv_flow_imp.g_varchar2_table(39) := '626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A206D6F76653B0A7D0A2E6D6170626F78676C2D6D61702E6D6F64652D6469726563745F73656C6563742E666561';
wwv_flow_imp.g_varchar2_table(40) := '747572652D6D6964706F696E742E6D6F7573652D706F696E746572202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B0A2020637572736F723A2063656C6C3B0A7D0A2E6D6170';
wwv_flow_imp.g_varchar2_table(41) := '626F78676C2D6D61702E6D6F64652D6469726563745F73656C6563742E666561747572652D666561747572652E6D6F7573652D6D6F7665202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374';
wwv_flow_imp.g_varchar2_table(42) := '697665207B0A2020637572736F723A206D6F76653B0A7D0A2E6D6170626F78676C2D6D61702E6D6F64652D7374617469632E6D6F7573652D706F696E74657220202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C';
wwv_flow_imp.g_varchar2_table(43) := '2D696E746572616374697665207B0A2020637572736F723A20677261623B0A2020637572736F723A202D6D6F7A2D677261623B0A2020637572736F723A202D7765626B69742D677261623B0A7D0A0A2E6D6170626F782D676C2D647261775F626F787365';
wwv_flow_imp.g_varchar2_table(44) := '6C656374207B0A20202020706F696E7465722D6576656E74733A206E6F6E653B0A20202020706F736974696F6E3A206162736F6C7574653B0A20202020746F703A20303B0A202020206C6566743A20303B0A2020202077696474683A20303B0A20202020';
wwv_flow_imp.g_varchar2_table(45) := '6865696768743A20303B0A202020206261636B67726F756E643A207267626128302C302C302C2E31293B0A20202020626F726465723A2032707820646F7474656420236666663B0A202020206F7061636974793A20302E353B0A7D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43388520355713255)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbox-gl-draw.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '76617220652C743B653D746869732C743D66756E6374696F6E28297B636F6E737420653D7B43414E5641533A226D6170626F78676C2D63616E766173222C434F4E54524F4C5F424153453A226D6170626F78676C2D6374726C222C434F4E54524F4C5F50';
wwv_flow_imp.g_varchar2_table(2) := '52454649583A226D6170626F78676C2D6374726C2D222C434F4E54524F4C5F425554544F4E3A226D6170626F782D676C2D647261775F6374726C2D647261772D62746E222C434F4E54524F4C5F425554544F4E5F4C494E453A226D6170626F782D676C2D';
wwv_flow_imp.g_varchar2_table(3) := '647261775F6C696E65222C434F4E54524F4C5F425554544F4E5F504F4C59474F4E3A226D6170626F782D676C2D647261775F706F6C79676F6E222C434F4E54524F4C5F425554544F4E5F504F494E543A226D6170626F782D676C2D647261775F706F696E';
wwv_flow_imp.g_varchar2_table(4) := '74222C434F4E54524F4C5F425554544F4E5F54524153483A226D6170626F782D676C2D647261775F7472617368222C434F4E54524F4C5F425554544F4E5F434F4D42494E455F46454154555245533A226D6170626F782D676C2D647261775F636F6D6269';
wwv_flow_imp.g_varchar2_table(5) := '6E65222C434F4E54524F4C5F425554544F4E5F554E434F4D42494E455F46454154555245533A226D6170626F782D676C2D647261775F756E636F6D62696E65222C434F4E54524F4C5F47524F55503A226D6170626F78676C2D6374726C2D67726F757022';
wwv_flow_imp.g_varchar2_table(6) := '2C4154545249425554494F4E3A226D6170626F78676C2D6374726C2D617474726962222C4143544956455F425554544F4E3A22616374697665222C424F585F53454C4543543A226D6170626F782D676C2D647261775F626F7873656C656374227D2C743D';
wwv_flow_imp.g_varchar2_table(7) := '7B484F543A226D6170626F782D676C2D647261772D686F74222C434F4C443A226D6170626F782D676C2D647261772D636F6C64227D2C6F3D7B4144443A22616464222C4D4F56453A226D6F7665222C445241473A2264726167222C504F494E5445523A22';
wwv_flow_imp.g_varchar2_table(8) := '706F696E746572222C4E4F4E453A226E6F6E65227D2C6E3D7B504F4C59474F4E3A22706F6C79676F6E222C4C494E453A226C696E655F737472696E67222C504F494E543A22706F696E74227D2C723D7B464541545552453A2246656174757265222C504F';
wwv_flow_imp.g_varchar2_table(9) := '4C59474F4E3A22506F6C79676F6E222C4C494E455F535452494E473A224C696E65537472696E67222C504F494E543A22506F696E74222C464541545552455F434F4C4C454354494F4E3A2246656174757265436F6C6C656374696F6E222C4D554C54495F';
wwv_flow_imp.g_varchar2_table(10) := '5052454649583A224D756C7469222C4D554C54495F504F494E543A224D756C7469506F696E74222C4D554C54495F4C494E455F535452494E473A224D756C74694C696E65537472696E67222C4D554C54495F504F4C59474F4E3A224D756C7469506F6C79';
wwv_flow_imp.g_varchar2_table(11) := '676F6E227D2C693D7B445241575F4C494E455F535452494E473A22647261775F6C696E655F737472696E67222C445241575F504F4C59474F4E3A22647261775F706F6C79676F6E222C445241575F504F494E543A22647261775F706F696E74222C53494D';
wwv_flow_imp.g_varchar2_table(12) := '504C455F53454C4543543A2273696D706C655F73656C656374222C4449524543545F53454C4543543A226469726563745F73656C656374227D2C733D7B4352454154453A22647261772E637265617465222C44454C4554453A22647261772E64656C6574';
wwv_flow_imp.g_varchar2_table(13) := '65222C5550444154453A22647261772E757064617465222C53454C454354494F4E5F4348414E47453A22647261772E73656C656374696F6E6368616E6765222C4D4F44455F4348414E47453A22647261772E6D6F64656368616E6765222C414354494F4E';
wwv_flow_imp.g_varchar2_table(14) := '41424C453A22647261772E616374696F6E61626C65222C52454E4445523A22647261772E72656E646572222C434F4D42494E455F46454154555245533A22647261772E636F6D62696E65222C554E434F4D42494E455F46454154555245533A2264726177';
wwv_flow_imp.g_varchar2_table(15) := '2E756E636F6D62696E65227D2C613D7B4D4F56453A226D6F7665222C4348414E47455F50524F504552544945533A226368616E67655F70726F70657274696573222C4348414E47455F434F4F5244494E415445533A226368616E67655F636F6F7264696E';
wwv_flow_imp.g_varchar2_table(16) := '61746573227D2C633D7B464541545552453A2266656174757265222C4D4944504F494E543A226D6964706F696E74222C5645525445583A22766572746578227D2C753D7B4143544956453A2274727565222C494E4143544956453A2266616C7365227D2C';
wwv_flow_imp.g_varchar2_table(17) := '6C3D5B227363726F6C6C5A6F6F6D222C22626F785A6F6F6D222C2264726167526F74617465222C226472616750616E222C226B6579626F617264222C22646F75626C65436C69636B5A6F6F6D222C22746F7563685A6F6F6D526F74617465225D2C643D2D';
wwv_flow_imp.g_varchar2_table(18) := '38352C703D38353B76617220683D4F626A6563742E667265657A65287B5F5F70726F746F5F5F3A6E756C6C2C4C41545F4D41583A39302C4C41545F4D494E3A2D39302C4C41545F52454E44455245445F4D41583A702C4C41545F52454E44455245445F4D';
wwv_flow_imp.g_varchar2_table(19) := '494E3A642C4C4E475F4D41583A3237302C4C4E475F4D494E3A2D3237302C6163746976655374617465733A752C636C61737365733A652C637572736F72733A6F2C6576656E74733A732C67656F6A736F6E54797065733A722C696E746572616374696F6E';
wwv_flow_imp.g_varchar2_table(20) := '733A6C2C6D6574613A632C6D6F6465733A692C736F75726365733A742C74797065733A6E2C757064617465416374696F6E733A617D293B66756E6374696F6E20662865297B72657475726E2066756E6374696F6E2874297B636F6E7374206F3D742E6665';
wwv_flow_imp.g_varchar2_table(21) := '61747572655461726765743B72657475726E21216F262621216F2E70726F7065727469657326266F2E70726F706572746965732E6D6574613D3D3D657D7D66756E6374696F6E20672865297B72657475726E2121652E6F726967696E616C4576656E7426';
wwv_flow_imp.g_varchar2_table(22) := '262121652E6F726967696E616C4576656E742E73686966744B65792626303D3D3D652E6F726967696E616C4576656E742E627574746F6E7D66756E6374696F6E20792865297B72657475726E2121652E6665617475726554617267657426262121652E66';
wwv_flow_imp.g_varchar2_table(23) := '6561747572655461726765742E70726F706572746965732626652E666561747572655461726765742E70726F706572746965732E6163746976653D3D3D752E4143544956452626652E666561747572655461726765742E70726F706572746965732E6D65';
wwv_flow_imp.g_varchar2_table(24) := '74613D3D3D632E464541545552457D66756E6374696F6E206D2865297B72657475726E2121652E6665617475726554617267657426262121652E666561747572655461726765742E70726F706572746965732626652E666561747572655461726765742E';
wwv_flow_imp.g_varchar2_table(25) := '70726F706572746965732E6163746976653D3D3D752E494E4143544956452626652E666561747572655461726765742E70726F706572746965732E6D6574613D3D3D632E464541545552457D66756E6374696F6E20452865297B72657475726E20766F69';
wwv_flow_imp.g_varchar2_table(26) := '6420303D3D3D652E666561747572655461726765747D66756E6374696F6E20432865297B72657475726E2121652E6665617475726554617267657426262121652E666561747572655461726765742E70726F706572746965732626652E66656174757265';
wwv_flow_imp.g_varchar2_table(27) := '5461726765742E70726F706572746965732E6D6574613D3D3D632E464541545552457D66756E6374696F6E20542865297B636F6E737420743D652E666561747572655461726765743B72657475726E21217426262121742E70726F706572746965732626';
wwv_flow_imp.g_varchar2_table(28) := '742E70726F706572746965732E6D6574613D3D3D632E5645525445587D66756E6374696F6E205F2865297B72657475726E2121652E6F726967696E616C4576656E74262621303D3D3D652E6F726967696E616C4576656E742E73686966744B65797D6675';
wwv_flow_imp.g_varchar2_table(29) := '6E6374696F6E20762865297B72657475726E22457363617065223D3D3D652E6B65797C7C32373D3D3D652E6B6579436F64657D66756E6374696F6E20492865297B72657475726E22456E746572223D3D3D652E6B65797C7C31333D3D3D652E6B6579436F';
wwv_flow_imp.g_varchar2_table(30) := '64657D66756E6374696F6E20532865297B72657475726E224261636B7370616365223D3D3D652E6B65797C7C383D3D3D652E6B6579436F64657D66756E6374696F6E204F2865297B72657475726E2244656C657465223D3D3D652E6B65797C7C34363D3D';
wwv_flow_imp.g_varchar2_table(31) := '3D652E6B6579436F64657D66756E6374696F6E204D2865297B72657475726E2231223D3D3D652E6B65797C7C34393D3D3D652E6B6579436F64657D66756E6374696F6E204C2865297B72657475726E2232223D3D3D652E6B65797C7C35303D3D3D652E6B';
wwv_flow_imp.g_varchar2_table(32) := '6579436F64657D66756E6374696F6E204E2865297B72657475726E2233223D3D3D652E6B65797C7C35313D3D3D652E6B6579436F64657D66756E6374696F6E20622865297B636F6E737420743D652E6B65797C7C537472696E672E66726F6D4368617243';
wwv_flow_imp.g_varchar2_table(33) := '6F646528652E6B6579436F6465293B72657475726E20743E3D2230222626743C3D2239227D76617220503D4F626A6563742E667265657A65287B5F5F70726F746F5F5F3A6E756C6C2C6973416374697665466561747572653A792C69734261636B737061';
wwv_flow_imp.g_varchar2_table(34) := '63654B65793A532C697344656C6574654B65793A4F2C69734469676974314B65793A4D2C69734469676974324B65793A4C2C69734469676974334B65793A4E2C697344696769744B65793A622C6973456E7465724B65793A492C69734573636170654B65';
wwv_flow_imp.g_varchar2_table(35) := '793A762C6973466561747572653A432C6973496E616374697665466561747572653A6D2C69734F664D657461547970653A662C69735368696674446F776E3A5F2C697353686966744D6F757365646F776E3A672C6973547275653A66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(36) := '297B72657475726E21307D2C69735665727465783A542C6E6F5461726765743A457D293B66756E6374696F6E20782865297B72657475726E20652626652E5F5F65734D6F64756C6526264F626A6563742E70726F746F747970652E6861734F776E50726F';
wwv_flow_imp.g_varchar2_table(37) := '70657274792E63616C6C28652C2264656661756C7422293F652E64656661756C743A657D76617220412C462C773D7B7D2C523D7B7D3B66756E6374696F6E204428297B72657475726E20417C7C28413D312C522E5241444955533D363337383133372C52';
wwv_flow_imp.g_varchar2_table(38) := '2E464C415454454E494E473D312F3239382E3235373232333536332C522E504F4C41525F5241444955533D363335363735322E33313432292C527D76617220553D66756E6374696F6E28297B696628462972657475726E20773B463D313B76617220653D';
wwv_flow_imp.g_varchar2_table(39) := '4428293B66756E6374696F6E20742865297B76617220743D303B696628652626652E6C656E6774683E30297B742B3D4D6174682E616273286F28655B305D29293B666F7228766172206E3D313B6E3C652E6C656E6774683B6E2B2B29742D3D4D6174682E';
wwv_flow_imp.g_varchar2_table(40) := '616273286F28655B6E5D29297D72657475726E20747D66756E6374696F6E206F2874297B766172206F2C722C692C732C612C632C753D302C6C3D742E6C656E6774683B6966286C3E32297B666F7228633D303B633C6C3B632B2B29633D3D3D6C2D323F28';
wwv_flow_imp.g_varchar2_table(41) := '693D6C2D322C733D6C2D312C613D30293A633D3D3D6C2D313F28693D6C2D312C733D302C613D31293A28693D632C733D632B312C613D632B32292C6F3D745B695D2C723D745B735D2C752B3D286E28745B615D5B305D292D6E286F5B305D29292A4D6174';
wwv_flow_imp.g_varchar2_table(42) := '682E73696E286E28725B315D29293B753D752A652E5241444955532A652E5241444955532F327D72657475726E20757D66756E6374696F6E206E2865297B72657475726E20652A4D6174682E50492F3138307D72657475726E20772E67656F6D65747279';
wwv_flow_imp.g_varchar2_table(43) := '3D66756E6374696F6E2065286F297B766172206E2C723D303B737769746368286F2E74797065297B6361736522506F6C79676F6E223A72657475726E2074286F2E636F6F7264696E61746573293B63617365224D756C7469506F6C79676F6E223A666F72';
wwv_flow_imp.g_varchar2_table(44) := '286E3D303B6E3C6F2E636F6F7264696E617465732E6C656E6774683B6E2B2B29722B3D74286F2E636F6F7264696E617465735B6E5D293B72657475726E20723B6361736522506F696E74223A63617365224D756C7469506F696E74223A63617365224C69';
wwv_flow_imp.g_varchar2_table(45) := '6E65537472696E67223A63617365224D756C74694C696E65537472696E67223A72657475726E20303B636173652247656F6D65747279436F6C6C656374696F6E223A666F72286E3D303B6E3C6F2E67656F6D6574726965732E6C656E6774683B6E2B2B29';
wwv_flow_imp.g_varchar2_table(46) := '722B3D65286F2E67656F6D6574726965735B6E5D293B72657475726E20727D7D2C772E72696E673D6F2C777D28292C6B3D782855293B636F6E737420563D7B506F696E743A302C4C696E65537472696E673A312C4D756C74694C696E65537472696E673A';
wwv_flow_imp.g_varchar2_table(47) := '312C506F6C79676F6E3A327D3B66756E6374696F6E204728652C74297B636F6E7374206F3D565B652E67656F6D657472792E747970655D2D565B742E67656F6D657472792E747970655D3B72657475726E20303D3D3D6F2626652E67656F6D657472792E';
wwv_flow_imp.g_varchar2_table(48) := '747970653D3D3D722E504F4C59474F4E3F652E617265612D742E617265613A6F7D66756E6374696F6E20422865297B72657475726E20652E6D61702828653D3E28652E67656F6D657472792E747970653D3D3D722E504F4C59474F4E262628652E617265';
wwv_flow_imp.g_varchar2_table(49) := '613D6B2E67656F6D65747279287B747970653A722E464541545552452C70726F70657274793A7B7D2C67656F6D657472793A652E67656F6D657472797D29292C652929292E736F72742847292E6D61702828653D3E2864656C65746520652E617265612C';
wwv_flow_imp.g_varchar2_table(50) := '652929297D66756E6374696F6E206A28652C743D30297B72657475726E5B5B652E706F696E742E782D742C652E706F696E742E792D745D2C5B652E706F696E742E782B742C652E706F696E742E792B745D5D7D66756E6374696F6E204A2865297B696628';
wwv_flow_imp.g_varchar2_table(51) := '746869732E5F6974656D733D7B7D2C746869732E5F6E756D733D7B7D2C746869732E5F6C656E6774683D653F652E6C656E6774683A302C6529666F72286C657420743D302C6F3D652E6C656E6774683B743C6F3B742B2B29746869732E61646428655B74';
wwv_flow_imp.g_varchar2_table(52) := '5D292C766F69642030213D3D655B745D26262822737472696E67223D3D747970656F6620655B745D3F746869732E5F6974656D735B655B745D5D3D743A746869732E5F6E756D735B655B745D5D3D74297D4A2E70726F746F747970652E6164643D66756E';
wwv_flow_imp.g_varchar2_table(53) := '6374696F6E2865297B72657475726E20746869732E6861732865297C7C28746869732E5F6C656E6774682B2B2C22737472696E67223D3D747970656F6620653F746869732E5F6974656D735B655D3D746869732E5F6C656E6774683A746869732E5F6E75';
wwv_flow_imp.g_varchar2_table(54) := '6D735B655D3D746869732E5F6C656E677468292C746869737D2C4A2E70726F746F747970652E64656C6574653D66756E6374696F6E2865297B72657475726E21313D3D3D746869732E6861732865297C7C28746869732E5F6C656E6774682D2D2C64656C';
wwv_flow_imp.g_varchar2_table(55) := '65746520746869732E5F6974656D735B655D2C64656C65746520746869732E5F6E756D735B655D292C746869737D2C4A2E70726F746F747970652E6861733D66756E6374696F6E2865297B72657475726E212822737472696E6722213D747970656F6620';
wwv_flow_imp.g_varchar2_table(56) := '652626226E756D62657222213D747970656F6620657C7C766F696420303D3D3D746869732E5F6974656D735B655D2626766F696420303D3D3D746869732E5F6E756D735B655D297D2C4A2E70726F746F747970652E76616C7565733D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(57) := '28297B636F6E737420653D5B5D3B72657475726E204F626A6563742E6B65797328746869732E5F6974656D73292E666F72456163682828743D3E7B652E70757368287B6B3A742C763A746869732E5F6974656D735B745D7D297D29292C4F626A6563742E';
wwv_flow_imp.g_varchar2_table(58) := '6B65797328746869732E5F6E756D73292E666F72456163682828743D3E7B652E70757368287B6B3A4A534F4E2E70617273652874292C763A746869732E5F6E756D735B745D7D297D29292C652E736F7274282828652C74293D3E652E762D742E7629292E';
wwv_flow_imp.g_varchar2_table(59) := '6D61702828653D3E652E6B29297D2C4A2E70726F746F747970652E636C6561723D66756E6374696F6E28297B72657475726E20746869732E5F6C656E6774683D302C746869732E5F6974656D733D7B7D2C746869732E5F6E756D733D7B7D2C746869737D';
wwv_flow_imp.g_varchar2_table(60) := '3B636F6E737420243D5B632E464541545552452C632E4D4944504F494E542C632E5645525445585D3B76617220593D7B636C69636B3A66756E6374696F6E28652C742C6F297B72657475726E204828652C742C6F2C6F2E6F7074696F6E732E636C69636B';
wwv_flow_imp.g_varchar2_table(61) := '427566666572297D2C746F7563683A66756E6374696F6E28652C742C6F297B72657475726E204828652C742C6F2C6F2E6F7074696F6E732E746F756368427566666572297D7D3B66756E6374696F6E204828652C742C6F2C6E297B6966286E756C6C3D3D';
wwv_flow_imp.g_varchar2_table(62) := '3D6F2E6D61702972657475726E5B5D3B636F6E737420723D653F6A28652C6E293A742C693D7B7D3B6F2E6F7074696F6E732E7374796C6573262628692E6C61796572733D6F2E6F7074696F6E732E7374796C65732E6D61702828653D3E652E696429292E';
wwv_flow_imp.g_varchar2_table(63) := '66696C7465722828653D3E6E756C6C213D6F2E6D61702E6765744C617965722865292929293B636F6E737420733D6F2E6D61702E717565727952656E6465726564466561747572657328722C69292E66696C7465722828653D3E2D31213D3D242E696E64';
wwv_flow_imp.g_varchar2_table(64) := '65784F6628652E70726F706572746965732E6D6574612929292C613D6E6577204A2C633D5B5D3B72657475726E20732E666F72456163682828653D3E7B636F6E737420743D652E70726F706572746965732E69643B612E6861732874297C7C28612E6164';
wwv_flow_imp.g_varchar2_table(65) := '642874292C632E70757368286529297D29292C422863297D66756E6374696F6E205828652C74297B636F6E7374206E3D592E636C69636B28652C6E756C6C2C74292C723D7B6D6F7573653A6F2E4E4F4E457D3B72657475726E206E5B305D262628722E6D';
wwv_flow_imp.g_varchar2_table(66) := '6F7573653D6E5B305D2E70726F706572746965732E6163746976653D3D3D752E4143544956453F6F2E4D4F56453A6F2E504F494E5445522C722E666561747572653D6E5B305D2E70726F706572746965732E6D657461292C2D31213D3D742E6576656E74';
wwv_flow_imp.g_varchar2_table(67) := '732E63757272656E744D6F64654E616D6528292E696E6465784F662822647261772229262628722E6D6F7573653D6F2E414444292C742E75692E71756575654D6170436C61737365732872292C742E75692E7570646174654D6170436C61737365732829';
wwv_flow_imp.g_varchar2_table(68) := '2C6E5B305D7D66756E6374696F6E207128652C74297B636F6E7374206F3D652E782D742E782C6E3D652E792D742E793B72657475726E204D6174682E73717274286F2A6F2B6E2A6E297D636F6E7374204B3D342C5A3D31322C573D3530303B66756E6374';
wwv_flow_imp.g_varchar2_table(69) := '696F6E207A28652C742C6F3D7B7D297B636F6E7374206E3D6E756C6C213D6F2E66696E65546F6C6572616E63653F6F2E66696E65546F6C6572616E63653A4B2C723D6E756C6C213D6F2E67726F7373546F6C6572616E63653F6F2E67726F7373546F6C65';
wwv_flow_imp.g_varchar2_table(70) := '72616E63653A5A2C693D6E756C6C213D6F2E696E74657276616C3F6F2E696E74657276616C3A573B652E706F696E743D652E706F696E747C7C742E706F696E742C652E74696D653D652E74696D657C7C742E74696D653B636F6E737420733D7128652E70';
wwv_flow_imp.g_varchar2_table(71) := '6F696E742C742E706F696E74293B72657475726E20733C6E7C7C733C722626742E74696D652D652E74696D653C697D636F6E737420513D32352C65653D3235303B66756E6374696F6E20746528652C742C6F3D7B7D297B636F6E7374206E3D6E756C6C21';
wwv_flow_imp.g_varchar2_table(72) := '3D6F2E746F6C6572616E63653F6F2E746F6C6572616E63653A512C723D6E756C6C213D6F2E696E74657276616C3F6F2E696E74657276616C3A65653B72657475726E20652E706F696E743D652E706F696E747C7C742E706F696E742C652E74696D653D65';
wwv_flow_imp.g_varchar2_table(73) := '2E74696D657C7C742E74696D652C7128652E706F696E742C742E706F696E74293C6E2626742E74696D652D652E74696D653C727D636F6E7374206F653D66756E6374696F6E28652C74297B636F6E7374206F3D7B647261673A5B5D2C636C69636B3A5B5D';
wwv_flow_imp.g_varchar2_table(74) := '2C6D6F7573656D6F76653A5B5D2C6D6F757365646F776E3A5B5D2C6D6F75736575703A5B5D2C6D6F7573656F75743A5B5D2C6B6579646F776E3A5B5D2C6B657975703A5B5D2C746F75636873746172743A5B5D2C746F7563686D6F76653A5B5D2C746F75';
wwv_flow_imp.g_varchar2_table(75) := '6368656E643A5B5D2C7461703A5B5D7D2C6E3D7B6F6E28652C742C6E297B696628766F696420303D3D3D6F5B655D297468726F77206E6577204572726F722860496E76616C6964206576656E7420747970653A20247B657D60293B6F5B655D2E70757368';
wwv_flow_imp.g_varchar2_table(76) := '287B73656C6563746F723A742C666E3A6E7D297D2C72656E6465722865297B742E73746F72652E666561747572654368616E6765642865297D7D2C723D66756E6374696F6E28652C72297B636F6E737420693D6F5B655D3B6C657420733D692E6C656E67';
wwv_flow_imp.g_varchar2_table(77) := '74683B666F72283B732D2D3B297B636F6E737420653D695B735D3B696628652E73656C6563746F72287229297B652E666E2E63616C6C286E2C72297C7C742E73746F72652E72656E64657228292C742E75692E7570646174654D6170436C617373657328';
wwv_flow_imp.g_varchar2_table(78) := '293B627265616B7D7D7D3B72657475726E20652E73746172742E63616C6C286E292C7B72656E6465723A652E72656E6465722C73746F7028297B652E73746F702626652E73746F7028297D2C747261736828297B652E7472617368262628652E74726173';
wwv_flow_imp.g_varchar2_table(79) := '6828292C742E73746F72652E72656E6465722829297D2C636F6D62696E65466561747572657328297B652E636F6D62696E6546656174757265732626652E636F6D62696E65466561747572657328297D2C756E636F6D62696E6546656174757265732829';
wwv_flow_imp.g_varchar2_table(80) := '7B652E756E636F6D62696E6546656174757265732626652E756E636F6D62696E65466561747572657328297D2C647261672865297B72282264726167222C65297D2C636C69636B2865297B722822636C69636B222C65297D2C6D6F7573656D6F76652865';
wwv_flow_imp.g_varchar2_table(81) := '297B7228226D6F7573656D6F7665222C65297D2C6D6F757365646F776E2865297B7228226D6F757365646F776E222C65297D2C6D6F75736575702865297B7228226D6F7573657570222C65297D2C6D6F7573656F75742865297B7228226D6F7573656F75';
wwv_flow_imp.g_varchar2_table(82) := '74222C65297D2C6B6579646F776E2865297B7228226B6579646F776E222C65297D2C6B657975702865297B7228226B65797570222C65297D2C746F75636873746172742865297B722822746F7563687374617274222C65297D2C746F7563686D6F766528';
wwv_flow_imp.g_varchar2_table(83) := '65297B722822746F7563686D6F7665222C65297D2C746F756368656E642865297B722822746F756368656E64222C65297D2C7461702865297B722822746170222C65297D7D7D2C6E653D2828652C743D3231293D3E286F3D74293D3E7B6C6574206E3D22';
wwv_flow_imp.g_varchar2_table(84) := '222C723D307C6F3B666F72283B722D2D3B296E2B3D655B4D6174682E72616E646F6D28292A652E6C656E6774687C305D3B72657475726E206E7D292822303132333435363738394142434445464748494A4B4C4D4E4F505152535455565758595A616263';
wwv_flow_imp.g_varchar2_table(85) := '6465666768696A6B6C6D6E6F707172737475767778797A222C3332293B66756E6374696F6E20726528297B72657475726E206E6528297D636F6E73742069653D66756E6374696F6E28652C74297B746869732E6374783D652C746869732E70726F706572';
wwv_flow_imp.g_varchar2_table(86) := '746965733D742E70726F706572746965737C7C7B7D2C746869732E636F6F7264696E617465733D742E67656F6D657472792E636F6F7264696E617465732C746869732E69643D742E69647C7C726528292C746869732E747970653D742E67656F6D657472';
wwv_flow_imp.g_varchar2_table(87) := '792E747970657D3B69652E70726F746F747970652E6368616E6765643D66756E6374696F6E28297B746869732E6374782E73746F72652E666561747572654368616E67656428746869732E6964297D2C69652E70726F746F747970652E696E636F6D696E';
wwv_flow_imp.g_varchar2_table(88) := '67436F6F7264733D66756E6374696F6E2865297B746869732E736574436F6F7264696E617465732865297D2C69652E70726F746F747970652E736574436F6F7264696E617465733D66756E6374696F6E2865297B746869732E636F6F7264696E61746573';
wwv_flow_imp.g_varchar2_table(89) := '3D652C746869732E6368616E67656428297D2C69652E70726F746F747970652E676574436F6F7264696E617465733D66756E6374696F6E28297B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E6769667928746869732E636F6F72';
wwv_flow_imp.g_varchar2_table(90) := '64696E6174657329297D2C69652E70726F746F747970652E73657450726F70657274793D66756E6374696F6E28652C74297B746869732E70726F706572746965735B655D3D747D2C69652E70726F746F747970652E746F47656F4A534F4E3D66756E6374';
wwv_flow_imp.g_varchar2_table(91) := '696F6E28297B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E67696679287B69643A746869732E69642C747970653A722E464541545552452C70726F706572746965733A746869732E70726F706572746965732C67656F6D657472';
wwv_flow_imp.g_varchar2_table(92) := '793A7B636F6F7264696E617465733A746869732E676574436F6F7264696E6174657328292C747970653A746869732E747970657D7D29297D2C69652E70726F746F747970652E696E7465726E616C3D66756E6374696F6E2865297B636F6E737420743D7B';
wwv_flow_imp.g_varchar2_table(93) := '69643A746869732E69642C6D6574613A632E464541545552452C226D6574613A74797065223A746869732E747970652C6163746976653A752E494E4143544956452C6D6F64653A657D3B696628746869732E6374782E6F7074696F6E732E757365725072';
wwv_flow_imp.g_varchar2_table(94) := '6F7065727469657329666F7228636F6E7374206520696E20746869732E70726F7065727469657329745B60757365725F247B657D605D3D746869732E70726F706572746965735B655D3B72657475726E7B747970653A722E464541545552452C70726F70';
wwv_flow_imp.g_varchar2_table(95) := '6572746965733A742C67656F6D657472793A7B636F6F7264696E617465733A746869732E676574436F6F7264696E6174657328292C747970653A746869732E747970657D7D7D3B636F6E73742073653D66756E6374696F6E28652C74297B69652E63616C';
wwv_flow_imp.g_varchar2_table(96) := '6C28746869732C652C74297D3B2873652E70726F746F747970653D4F626A6563742E6372656174652869652E70726F746F7479706529292E697356616C69643D66756E6374696F6E28297B72657475726E226E756D626572223D3D747970656F66207468';
wwv_flow_imp.g_varchar2_table(97) := '69732E636F6F7264696E617465735B305D2626226E756D626572223D3D747970656F6620746869732E636F6F7264696E617465735B315D7D2C73652E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28652C742C';
wwv_flow_imp.g_varchar2_table(98) := '6F297B746869732E636F6F7264696E617465733D333D3D3D617267756D656E74732E6C656E6774683F5B742C6F5D3A5B652C745D2C746869732E6368616E67656428297D2C73652E70726F746F747970652E676574436F6F7264696E6174653D66756E63';
wwv_flow_imp.g_varchar2_table(99) := '74696F6E28297B72657475726E20746869732E676574436F6F7264696E6174657328297D3B636F6E73742061653D66756E6374696F6E28652C74297B69652E63616C6C28746869732C652C74297D3B2861652E70726F746F747970653D4F626A6563742E';
wwv_flow_imp.g_varchar2_table(100) := '6372656174652869652E70726F746F7479706529292E697356616C69643D66756E6374696F6E28297B72657475726E20746869732E636F6F7264696E617465732E6C656E6774683E317D2C61652E70726F746F747970652E616464436F6F7264696E6174';
wwv_flow_imp.g_varchar2_table(101) := '653D66756E6374696F6E28652C742C6F297B746869732E6368616E67656428293B636F6E7374206E3D7061727365496E7428652C3130293B746869732E636F6F7264696E617465732E73706C696365286E2C302C5B742C6F5D297D2C61652E70726F746F';
wwv_flow_imp.g_varchar2_table(102) := '747970652E676574436F6F7264696E6174653D66756E6374696F6E2865297B636F6E737420743D7061727365496E7428652C3130293B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E6769667928746869732E636F6F7264696E61';
wwv_flow_imp.g_varchar2_table(103) := '7465735B745D29297D2C61652E70726F746F747970652E72656D6F7665436F6F7264696E6174653D66756E6374696F6E2865297B746869732E6368616E67656428292C746869732E636F6F7264696E617465732E73706C696365287061727365496E7428';
wwv_flow_imp.g_varchar2_table(104) := '652C3130292C31297D2C61652E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B636F6E7374206E3D7061727365496E7428652C3130293B746869732E636F6F7264696E617465735B6E5D3D5B';
wwv_flow_imp.g_varchar2_table(105) := '742C6F5D2C746869732E6368616E67656428297D3B636F6E73742063653D66756E6374696F6E28652C74297B69652E63616C6C28746869732C652C74292C746869732E636F6F7264696E617465733D746869732E636F6F7264696E617465732E6D617028';
wwv_flow_imp.g_varchar2_table(106) := '28653D3E652E736C69636528302C2D312929297D3B2863652E70726F746F747970653D4F626A6563742E6372656174652869652E70726F746F7479706529292E697356616C69643D66756E6374696F6E28297B72657475726E2030213D3D746869732E63';
wwv_flow_imp.g_varchar2_table(107) := '6F6F7264696E617465732E6C656E6774682626746869732E636F6F7264696E617465732E65766572792828653D3E652E6C656E6774683E3229297D2C63652E70726F746F747970652E696E636F6D696E67436F6F7264733D66756E6374696F6E2865297B';
wwv_flow_imp.g_varchar2_table(108) := '746869732E636F6F7264696E617465733D652E6D61702828653D3E652E736C69636528302C2D312929292C746869732E6368616E67656428297D2C63652E70726F746F747970652E736574436F6F7264696E617465733D66756E6374696F6E2865297B74';
wwv_flow_imp.g_varchar2_table(109) := '6869732E636F6F7264696E617465733D652C746869732E6368616E67656428297D2C63652E70726F746F747970652E616464436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B746869732E6368616E67656428293B636F6E7374206E3D';
wwv_flow_imp.g_varchar2_table(110) := '652E73706C697428222E22292E6D61702828653D3E7061727365496E7428652C31302929293B746869732E636F6F7264696E617465735B6E5B305D5D2E73706C696365286E5B315D2C302C5B742C6F5D297D2C63652E70726F746F747970652E72656D6F';
wwv_flow_imp.g_varchar2_table(111) := '7665436F6F7264696E6174653D66756E6374696F6E2865297B746869732E6368616E67656428293B636F6E737420743D652E73706C697428222E22292E6D61702828653D3E7061727365496E7428652C31302929292C6F3D746869732E636F6F7264696E';
wwv_flow_imp.g_varchar2_table(112) := '617465735B745B305D5D3B6F2626286F2E73706C69636528745B315D2C31292C6F2E6C656E6774683C332626746869732E636F6F7264696E617465732E73706C69636528745B305D2C3129297D2C63652E70726F746F747970652E676574436F6F726469';
wwv_flow_imp.g_varchar2_table(113) := '6E6174653D66756E6374696F6E2865297B636F6E737420743D652E73706C697428222E22292E6D61702828653D3E7061727365496E7428652C31302929292C6F3D746869732E636F6F7264696E617465735B745B305D5D3B72657475726E204A534F4E2E';
wwv_flow_imp.g_varchar2_table(114) := '7061727365284A534F4E2E737472696E67696679286F5B745B315D5D29297D2C63652E70726F746F747970652E676574436F6F7264696E617465733D66756E6374696F6E28297B72657475726E20746869732E636F6F7264696E617465732E6D61702828';
wwv_flow_imp.g_varchar2_table(115) := '653D3E652E636F6E636174285B655B305D5D2929297D2C63652E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B746869732E6368616E67656428293B636F6E7374206E3D652E73706C697428';
wwv_flow_imp.g_varchar2_table(116) := '222E22292C723D7061727365496E74286E5B305D2C3130292C693D7061727365496E74286E5B315D2C3130293B766F696420303D3D3D746869732E636F6F7264696E617465735B725D262628746869732E636F6F7264696E617465735B725D3D5B5D292C';
wwv_flow_imp.g_varchar2_table(117) := '746869732E636F6F7264696E617465735B725D5B695D3D5B742C6F5D7D3B636F6E73742075653D7B4D756C7469506F696E743A73652C4D756C74694C696E65537472696E673A61652C4D756C7469506F6C79676F6E3A63657D2C6C653D28652C742C6F2C';
wwv_flow_imp.g_varchar2_table(118) := '6E2C72293D3E7B636F6E737420693D6F2E73706C697428222E22292C733D7061727365496E7428695B305D2C3130292C613D695B315D3F692E736C6963652831292E6A6F696E28222E22293A6E756C6C3B72657475726E20655B735D5B745D28612C6E2C';
wwv_flow_imp.g_varchar2_table(119) := '72297D2C64653D66756E6374696F6E28652C74297B69662869652E63616C6C28746869732C652C74292C64656C65746520746869732E636F6F7264696E617465732C746869732E6D6F64656C3D75655B742E67656F6D657472792E747970655D2C766F69';
wwv_flow_imp.g_varchar2_table(120) := '6420303D3D3D746869732E6D6F64656C297468726F77206E657720547970654572726F722860247B742E67656F6D657472792E747970657D206973206E6F7420612076616C6964207479706560293B746869732E66656174757265733D746869732E5F63';
wwv_flow_imp.g_varchar2_table(121) := '6F6F7264696E61746573546F466561747572657328742E67656F6D657472792E636F6F7264696E61746573297D3B66756E6374696F6E2070652865297B746869732E6D61703D652E6D61702C746869732E64726177436F6E6669673D4A534F4E2E706172';
wwv_flow_imp.g_varchar2_table(122) := '7365284A534F4E2E737472696E6769667928652E6F7074696F6E737C7C7B7D29292C746869732E5F6374783D657D2864652E70726F746F747970653D4F626A6563742E6372656174652869652E70726F746F7479706529292E5F636F6F7264696E617465';
wwv_flow_imp.g_varchar2_table(123) := '73546F46656174757265733D66756E6374696F6E2865297B636F6E737420743D746869732E6D6F64656C2E62696E642874686973293B72657475726E20652E6D61702828653D3E6E6577207428746869732E6374782C7B69643A726528292C747970653A';
wwv_flow_imp.g_varchar2_table(124) := '722E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B636F6F7264696E617465733A652C747970653A746869732E747970652E7265706C61636528224D756C7469222C2222297D7D2929297D2C64652E70726F746F747970';
wwv_flow_imp.g_varchar2_table(125) := '652E697356616C69643D66756E6374696F6E28297B72657475726E20746869732E66656174757265732E65766572792828653D3E652E697356616C6964282929297D2C64652E70726F746F747970652E736574436F6F7264696E617465733D66756E6374';
wwv_flow_imp.g_varchar2_table(126) := '696F6E2865297B746869732E66656174757265733D746869732E5F636F6F7264696E61746573546F46656174757265732865292C746869732E6368616E67656428297D2C64652E70726F746F747970652E676574436F6F7264696E6174653D66756E6374';
wwv_flow_imp.g_varchar2_table(127) := '696F6E2865297B72657475726E206C6528746869732E66656174757265732C22676574436F6F7264696E617465222C65297D2C64652E70726F746F747970652E676574436F6F7264696E617465733D66756E6374696F6E28297B72657475726E204A534F';
wwv_flow_imp.g_varchar2_table(128) := '4E2E7061727365284A534F4E2E737472696E6769667928746869732E66656174757265732E6D61702828653D3E652E747970653D3D3D722E504F4C59474F4E3F652E676574436F6F7264696E6174657328293A652E636F6F7264696E6174657329292929';
wwv_flow_imp.g_varchar2_table(129) := '7D2C64652E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B6C6528746869732E66656174757265732C22757064617465436F6F7264696E617465222C652C742C6F292C746869732E6368616E';
wwv_flow_imp.g_varchar2_table(130) := '67656428297D2C64652E70726F746F747970652E616464436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B6C6528746869732E66656174757265732C22616464436F6F7264696E617465222C652C742C6F292C746869732E6368616E67';
wwv_flow_imp.g_varchar2_table(131) := '656428297D2C64652E70726F746F747970652E72656D6F7665436F6F7264696E6174653D66756E6374696F6E2865297B6C6528746869732E66656174757265732C2272656D6F7665436F6F7264696E617465222C65292C746869732E6368616E67656428';
wwv_flow_imp.g_varchar2_table(132) := '297D2C64652E70726F746F747970652E67657446656174757265733D66756E6374696F6E28297B72657475726E20746869732E66656174757265737D2C70652E70726F746F747970652E73657453656C65637465643D66756E6374696F6E2865297B7265';
wwv_flow_imp.g_varchar2_table(133) := '7475726E20746869732E5F6374782E73746F72652E73657453656C65637465642865297D2C70652E70726F746F747970652E73657453656C6563746564436F6F7264696E617465733D66756E6374696F6E2865297B746869732E5F6374782E73746F7265';
wwv_flow_imp.g_varchar2_table(134) := '2E73657453656C6563746564436F6F7264696E617465732865292C652E726564756365282828652C74293D3E28766F696420303D3D3D655B742E666561747572655F69645D262628655B742E666561747572655F69645D3D21302C746869732E5F637478';
wwv_flow_imp.g_varchar2_table(135) := '2E73746F72652E67657428742E666561747572655F6964292E6368616E6765642829292C6529292C7B7D297D2C70652E70726F746F747970652E67657453656C65637465643D66756E6374696F6E28297B72657475726E20746869732E5F6374782E7374';
wwv_flow_imp.g_varchar2_table(136) := '6F72652E67657453656C656374656428297D2C70652E70726F746F747970652E67657453656C65637465644964733D66756E6374696F6E28297B72657475726E20746869732E5F6374782E73746F72652E67657453656C656374656449647328297D2C70';
wwv_flow_imp.g_varchar2_table(137) := '652E70726F746F747970652E697353656C65637465643D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E697353656C65637465642865297D2C70652E70726F746F747970652E676574466561747572653D66756E';
wwv_flow_imp.g_varchar2_table(138) := '6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E6765742865297D2C70652E70726F746F747970652E73656C6563743D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E73656C6563';
wwv_flow_imp.g_varchar2_table(139) := '742865297D2C70652E70726F746F747970652E646573656C6563743D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E646573656C6563742865297D2C70652E70726F746F747970652E64656C6574654665617475';
wwv_flow_imp.g_varchar2_table(140) := '72653D66756E6374696F6E28652C743D7B7D297B72657475726E20746869732E5F6374782E73746F72652E64656C65746528652C74297D2C70652E70726F746F747970652E616464466561747572653D66756E6374696F6E28652C743D7B7D297B726574';
wwv_flow_imp.g_varchar2_table(141) := '75726E20746869732E5F6374782E73746F72652E61646428652C74297D2C70652E70726F746F747970652E636C65617253656C656374656446656174757265733D66756E6374696F6E28297B72657475726E20746869732E5F6374782E73746F72652E63';
wwv_flow_imp.g_varchar2_table(142) := '6C65617253656C656374656428297D2C70652E70726F746F747970652E636C65617253656C6563746564436F6F7264696E617465733D66756E6374696F6E28297B72657475726E20746869732E5F6374782E73746F72652E636C65617253656C65637465';
wwv_flow_imp.g_varchar2_table(143) := '64436F6F7264696E6174657328297D2C70652E70726F746F747970652E736574416374696F6E61626C6553746174653D66756E6374696F6E28653D7B7D297B636F6E737420743D7B74726173683A652E74726173687C7C21312C636F6D62696E65466561';
wwv_flow_imp.g_varchar2_table(144) := '74757265733A652E636F6D62696E6546656174757265737C7C21312C756E636F6D62696E6546656174757265733A652E756E636F6D62696E6546656174757265737C7C21317D3B72657475726E20746869732E5F6374782E6576656E74732E616374696F';
wwv_flow_imp.g_varchar2_table(145) := '6E61626C652874297D2C70652E70726F746F747970652E6368616E67654D6F64653D66756E6374696F6E28652C743D7B7D2C6F3D7B7D297B72657475726E20746869732E5F6374782E6576656E74732E6368616E67654D6F646528652C742C6F297D2C70';
wwv_flow_imp.g_varchar2_table(146) := '652E70726F746F747970652E666972653D66756E6374696F6E28652C74297B72657475726E20746869732E5F6374782E6576656E74732E6669726528652C74297D2C70652E70726F746F747970652E7570646174655549436C61737365733D66756E6374';
wwv_flow_imp.g_varchar2_table(147) := '696F6E2865297B72657475726E20746869732E5F6374782E75692E71756575654D6170436C61737365732865297D2C70652E70726F746F747970652E61637469766174655549427574746F6E3D66756E6374696F6E2865297B72657475726E2074686973';
wwv_flow_imp.g_varchar2_table(148) := '2E5F6374782E75692E736574416374697665427574746F6E2865297D2C70652E70726F746F747970652E666561747572657341743D66756E6374696F6E28652C742C6F3D22636C69636B22297B69662822636C69636B22213D3D6F262622746F75636822';
wwv_flow_imp.g_varchar2_table(149) := '213D3D6F297468726F77206E6577204572726F722822696E76616C696420627566666572207479706522293B72657475726E20595B6F5D28652C742C746869732E5F637478297D2C70652E70726F746F747970652E6E6577466561747572653D66756E63';
wwv_flow_imp.g_varchar2_table(150) := '74696F6E2865297B636F6E737420743D652E67656F6D657472792E747970653B72657475726E20743D3D3D722E504F494E543F6E657720736528746869732E5F6374782C65293A743D3D3D722E4C494E455F535452494E473F6E65772061652874686973';
wwv_flow_imp.g_varchar2_table(151) := '2E5F6374782C65293A743D3D3D722E504F4C59474F4E3F6E657720636528746869732E5F6374782C65293A6E657720646528746869732E5F6374782C65297D2C70652E70726F746F747970652E6973496E7374616E63654F663D66756E6374696F6E2865';
wwv_flow_imp.g_varchar2_table(152) := '2C74297B696628653D3D3D722E504F494E542972657475726E207420696E7374616E63656F662073653B696628653D3D3D722E4C494E455F535452494E472972657475726E207420696E7374616E63656F662061653B696628653D3D3D722E504F4C5947';
wwv_flow_imp.g_varchar2_table(153) := '4F4E2972657475726E207420696E7374616E63656F662063653B696628224D756C746946656174757265223D3D3D652972657475726E207420696E7374616E63656F662064653B7468726F77206E6577204572726F722860556E6B6E6F776E2066656174';
wwv_flow_imp.g_varchar2_table(154) := '75726520636C6173733A20247B657D60297D2C70652E70726F746F747970652E646F52656E6465723D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E666561747572654368616E6765642865297D2C70652E7072';
wwv_flow_imp.g_varchar2_table(155) := '6F746F747970652E6F6E53657475703D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E447261673D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E436C69636B3D66756E6374696F6E28297B7D2C70652E70';
wwv_flow_imp.g_varchar2_table(156) := '726F746F747970652E6F6E4D6F7573654D6F76653D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E4D6F757365446F776E3D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E4D6F75736555703D66756E6374';
wwv_flow_imp.g_varchar2_table(157) := '696F6E28297B7D2C70652E70726F746F747970652E6F6E4D6F7573654F75743D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E4B657955703D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E4B6579446F77';
wwv_flow_imp.g_varchar2_table(158) := '6E3D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E546F75636853746172743D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E546F7563684D6F76653D66756E6374696F6E28297B7D2C70652E70726F746F';
wwv_flow_imp.g_varchar2_table(159) := '747970652E6F6E546F756368456E643D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E5461703D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E53746F703D66756E6374696F6E28297B7D2C70652E70726F';
wwv_flow_imp.g_varchar2_table(160) := '746F747970652E6F6E54726173683D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E436F6D62696E65466561747572653D66756E6374696F6E28297B7D2C70652E70726F746F747970652E6F6E556E636F6D62696E654665617475';
wwv_flow_imp.g_varchar2_table(161) := '72653D66756E6374696F6E28297B7D2C70652E70726F746F747970652E746F446973706C617946656174757265733D66756E6374696F6E28297B7468726F77206E6577204572726F722822596F75206D757374206F766572777269746520746F44697370';
wwv_flow_imp.g_varchar2_table(162) := '6C6179466561747572657322297D3B636F6E73742068653D7B647261673A226F6E44726167222C636C69636B3A226F6E436C69636B222C6D6F7573656D6F76653A226F6E4D6F7573654D6F7665222C6D6F757365646F776E3A226F6E4D6F757365446F77';
wwv_flow_imp.g_varchar2_table(163) := '6E222C6D6F75736575703A226F6E4D6F7573655570222C6D6F7573656F75743A226F6E4D6F7573654F7574222C6B657975703A226F6E4B65795570222C6B6579646F776E3A226F6E4B6579446F776E222C746F75636873746172743A226F6E546F756368';
wwv_flow_imp.g_varchar2_table(164) := '5374617274222C746F7563686D6F76653A226F6E546F7563684D6F7665222C746F756368656E643A226F6E546F756368456E64222C7461703A226F6E546170227D2C66653D4F626A6563742E6B657973286865293B66756E6374696F6E2067652865297B';
wwv_flow_imp.g_varchar2_table(165) := '636F6E737420743D4F626A6563742E6B6579732865293B72657475726E2066756E6374696F6E286F2C6E3D7B7D297B6C657420723D7B7D3B636F6E737420693D742E726564756365282828742C6F293D3E28745B6F5D3D655B6F5D2C7429292C6E657720';
wwv_flow_imp.g_varchar2_table(166) := '7065286F29293B72657475726E7B737461727428297B723D692E6F6E5365747570286E292C66652E666F72456163682828743D3E7B636F6E7374206F3D68655B745D3B6C6574206E3D28293D3E21313B76617220733B655B6F5D2626286E3D28293D3E21';
wwv_flow_imp.g_varchar2_table(167) := '30292C746869732E6F6E28742C6E2C28733D6F2C653D3E695B735D28722C652929297D29297D2C73746F7028297B692E6F6E53746F702872297D2C747261736828297B692E6F6E54726173682872297D2C636F6D62696E65466561747572657328297B69';
wwv_flow_imp.g_varchar2_table(168) := '2E6F6E436F6D62696E6546656174757265732872297D2C756E636F6D62696E65466561747572657328297B692E6F6E556E636F6D62696E6546656174757265732872297D2C72656E64657228652C74297B692E746F446973706C61794665617475726573';
wwv_flow_imp.g_varchar2_table(169) := '28722C652C74297D7D7D7D66756E6374696F6E2079652865297B72657475726E5B5D2E636F6E6361742865292E66696C7465722828653D3E766F69642030213D3D6529297D66756E6374696F6E206D6528297B636F6E737420653D746869733B69662821';
wwv_flow_imp.g_varchar2_table(170) := '652E6374782E6D61707C7C766F696420303D3D3D652E6374782E6D61702E676574536F7572636528742E484F54292972657475726E207528293B636F6E7374206F3D652E6374782E6576656E74732E63757272656E744D6F64654E616D6528293B652E63';
wwv_flow_imp.g_varchar2_table(171) := '74782E75692E71756575654D6170436C6173736573287B6D6F64653A6F7D293B6C6574206E3D5B5D2C693D5B5D3B652E697344697274793F693D652E676574416C6C49647328293A286E3D652E6765744368616E67656449647328292E66696C74657228';
wwv_flow_imp.g_varchar2_table(172) := '28743D3E766F69642030213D3D652E67657428742929292C693D652E736F75726365732E686F742E66696C7465722828743D3E742E70726F706572746965732E696426262D313D3D3D6E2E696E6465784F6628742E70726F706572746965732E69642926';
wwv_flow_imp.g_varchar2_table(173) := '26766F69642030213D3D652E67657428742E70726F706572746965732E69642929292E6D61702828653D3E652E70726F706572746965732E69642929292C652E736F75726365732E686F743D5B5D3B636F6E737420733D652E736F75726365732E636F6C';
wwv_flow_imp.g_varchar2_table(174) := '642E6C656E6774683B652E736F75726365732E636F6C643D652E697344697274793F5B5D3A652E736F75726365732E636F6C642E66696C7465722828653D3E7B636F6E737420743D652E70726F706572746965732E69647C7C652E70726F706572746965';
wwv_flow_imp.g_varchar2_table(175) := '732E706172656E743B72657475726E2D313D3D3D6E2E696E6465784F662874297D29293B636F6E737420613D73213D3D652E736F75726365732E636F6C642E6C656E6774687C7C692E6C656E6774683E303B66756E6374696F6E206328742C6E297B636F';
wwv_flow_imp.g_varchar2_table(176) := '6E737420723D652E6765742874292E696E7465726E616C286F293B652E6374782E6576656E74732E63757272656E744D6F646552656E64657228722C28743D3E7B742E70726F706572746965732E6D6F64653D6F2C652E736F75726365735B6E5D2E7075';
wwv_flow_imp.g_varchar2_table(177) := '73682874297D29297D66756E6374696F6E207528297B652E697344697274793D21312C652E636C6561724368616E67656449647328297D6E2E666F72456163682828653D3E6328652C22686F74222929292C692E666F72456163682828653D3E6328652C';
wwv_flow_imp.g_varchar2_table(178) := '22636F6C64222929292C612626652E6374782E6D61702E676574536F7572636528742E434F4C44292E73657444617461287B747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A652E736F75726365732E636F6C647D';
wwv_flow_imp.g_varchar2_table(179) := '292C652E6374782E6D61702E676574536F7572636528742E484F54292E73657444617461287B747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A652E736F75726365732E686F747D292C7528297D66756E6374696F';
wwv_flow_imp.g_varchar2_table(180) := '6E2045652865297B6C657420743B746869732E5F66656174757265733D7B7D2C746869732E5F666561747572654964733D6E6577204A2C746869732E5F73656C6563746564466561747572654964733D6E6577204A2C746869732E5F73656C6563746564';
wwv_flow_imp.g_varchar2_table(181) := '436F6F7264696E617465733D5B5D2C746869732E5F6368616E676564466561747572654964733D6E6577204A2C746869732E5F656D697453656C656374696F6E4368616E67653D21312C746869732E5F6D6170496E697469616C436F6E6669673D7B7D2C';
wwv_flow_imp.g_varchar2_table(182) := '746869732E6374783D652C746869732E736F75726365733D7B686F743A5B5D2C636F6C643A5B5D7D2C746869732E72656E6465723D28293D3E7B747C7C28743D72657175657374416E696D6174696F6E4672616D65282828293D3E7B743D6E756C6C2C6D';
wwv_flow_imp.g_varchar2_table(183) := '652E63616C6C2874686973292C746869732E5F656D697453656C656374696F6E4368616E6765262628746869732E6374782E6576656E74732E6669726528732E53454C454354494F4E5F4348414E47452C7B66656174757265733A746869732E67657453';
wwv_flow_imp.g_varchar2_table(184) := '656C656374656428292E6D61702828653D3E652E746F47656F4A534F4E282929292C706F696E74733A746869732E67657453656C6563746564436F6F7264696E6174657328292E6D61702828653D3E287B747970653A722E464541545552452C70726F70';
wwv_flow_imp.g_varchar2_table(185) := '6572746965733A7B7D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F7264696E617465733A652E636F6F7264696E617465737D7D2929297D292C746869732E5F656D697453656C656374696F6E4368616E67653D2131292C74686973';
wwv_flow_imp.g_varchar2_table(186) := '2E6374782E6576656E74732E6669726528732E52454E4445522C7B7D297D2929297D2C746869732E697344697274793D21317D66756E6374696F6E20436528652C743D7B7D297B636F6E7374206F3D652E5F73656C6563746564436F6F7264696E617465';
wwv_flow_imp.g_varchar2_table(187) := '732E66696C7465722828743D3E652E5F73656C6563746564466561747572654964732E68617328742E666561747572655F69642929293B652E5F73656C6563746564436F6F7264696E617465732E6C656E6774683D3D3D6F2E6C656E6774687C7C742E73';
wwv_flow_imp.g_varchar2_table(188) := '696C656E747C7C28652E5F656D697453656C656374696F6E4368616E67653D2130292C652E5F73656C6563746564436F6F7264696E617465733D6F7D45652E70726F746F747970652E63726561746552656E64657242617463683D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(189) := '297B636F6E737420653D746869732E72656E6465723B6C657420743D303B72657475726E20746869732E72656E6465723D66756E6374696F6E28297B742B2B7D2C28293D3E7B746869732E72656E6465723D652C743E302626746869732E72656E646572';
wwv_flow_imp.g_varchar2_table(190) := '28297D7D2C45652E70726F746F747970652E73657444697274793D66756E6374696F6E28297B72657475726E20746869732E697344697274793D21302C746869737D2C45652E70726F746F747970652E66656174757265437265617465643D66756E6374';
wwv_flow_imp.g_varchar2_table(191) := '696F6E28652C743D7B7D297B696628746869732E5F6368616E676564466561747572654964732E6164642865292C2130213D3D286E756C6C213D742E73696C656E743F742E73696C656E743A746869732E6374782E6F7074696F6E732E73757070726573';
wwv_flow_imp.g_varchar2_table(192) := '734150494576656E747329297B636F6E737420743D746869732E6765742865293B746869732E6374782E6576656E74732E6669726528732E4352454154452C7B66656174757265733A5B742E746F47656F4A534F4E28295D7D297D72657475726E207468';
wwv_flow_imp.g_varchar2_table(193) := '69737D2C45652E70726F746F747970652E666561747572654368616E6765643D66756E6374696F6E28652C743D7B7D297B72657475726E20746869732E5F6368616E676564466561747572654964732E6164642865292C2130213D3D286E756C6C213D74';
wwv_flow_imp.g_varchar2_table(194) := '2E73696C656E743F742E73696C656E743A746869732E6374782E6F7074696F6E732E73757070726573734150494576656E7473292626746869732E6374782E6576656E74732E6669726528732E5550444154452C7B616374696F6E3A742E616374696F6E';
wwv_flow_imp.g_varchar2_table(195) := '3F742E616374696F6E3A612E4348414E47455F434F4F5244494E415445532C66656174757265733A5B746869732E6765742865292E746F47656F4A534F4E28295D7D292C746869737D2C45652E70726F746F747970652E6765744368616E676564496473';
wwv_flow_imp.g_varchar2_table(196) := '3D66756E6374696F6E28297B72657475726E20746869732E5F6368616E676564466561747572654964732E76616C75657328297D2C45652E70726F746F747970652E636C6561724368616E6765644964733D66756E6374696F6E28297B72657475726E20';
wwv_flow_imp.g_varchar2_table(197) := '746869732E5F6368616E676564466561747572654964732E636C65617228292C746869737D2C45652E70726F746F747970652E676574416C6C4964733D66756E6374696F6E28297B72657475726E20746869732E5F666561747572654964732E76616C75';
wwv_flow_imp.g_varchar2_table(198) := '657328297D2C45652E70726F746F747970652E6164643D66756E6374696F6E28652C743D7B7D297B72657475726E20746869732E5F66656174757265735B652E69645D3D652C746869732E5F666561747572654964732E61646428652E6964292C746869';
wwv_flow_imp.g_varchar2_table(199) := '732E666561747572654372656174656428652E69642C7B73696C656E743A742E73696C656E747D292C746869737D2C45652E70726F746F747970652E64656C6574653D66756E6374696F6E28652C743D7B7D297B636F6E7374206F3D5B5D3B7265747572';
wwv_flow_imp.g_varchar2_table(200) := '6E2079652865292E666F72456163682828653D3E7B746869732E5F666561747572654964732E686173286529262628746869732E5F666561747572654964732E64656C6574652865292C746869732E5F73656C6563746564466561747572654964732E64';
wwv_flow_imp.g_varchar2_table(201) := '656C6574652865292C742E73696C656E747C7C2D313D3D3D6F2E696E6465784F6628746869732E5F66656174757265735B655D2926266F2E7075736828746869732E5F66656174757265735B655D2E746F47656F4A534F4E2829292C64656C6574652074';
wwv_flow_imp.g_varchar2_table(202) := '6869732E5F66656174757265735B655D2C746869732E697344697274793D2130297D29292C6F2E6C656E6774682626746869732E6374782E6576656E74732E6669726528732E44454C4554452C7B66656174757265733A6F7D292C436528746869732C74';
wwv_flow_imp.g_varchar2_table(203) := '292C746869737D2C45652E70726F746F747970652E6765743D66756E6374696F6E2865297B72657475726E20746869732E5F66656174757265735B655D7D2C45652E70726F746F747970652E676574416C6C3D66756E6374696F6E28297B72657475726E';
wwv_flow_imp.g_varchar2_table(204) := '204F626A6563742E6B65797328746869732E5F6665617475726573292E6D61702828653D3E746869732E5F66656174757265735B655D29297D2C45652E70726F746F747970652E73656C6563743D66756E6374696F6E28652C743D7B7D297B7265747572';
wwv_flow_imp.g_varchar2_table(205) := '6E2079652865292E666F72456163682828653D3E7B746869732E5F73656C6563746564466561747572654964732E6861732865297C7C28746869732E5F73656C6563746564466561747572654964732E6164642865292C746869732E5F6368616E676564';
wwv_flow_imp.g_varchar2_table(206) := '466561747572654964732E6164642865292C742E73696C656E747C7C28746869732E5F656D697453656C656374696F6E4368616E67653D213029297D29292C746869737D2C45652E70726F746F747970652E646573656C6563743D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(207) := '652C743D7B7D297B72657475726E2079652865292E666F72456163682828653D3E7B746869732E5F73656C6563746564466561747572654964732E686173286529262628746869732E5F73656C6563746564466561747572654964732E64656C65746528';
wwv_flow_imp.g_varchar2_table(208) := '65292C746869732E5F6368616E676564466561747572654964732E6164642865292C742E73696C656E747C7C28746869732E5F656D697453656C656374696F6E4368616E67653D213029297D29292C436528746869732C74292C746869737D2C45652E70';
wwv_flow_imp.g_varchar2_table(209) := '726F746F747970652E636C65617253656C65637465643D66756E6374696F6E28653D7B7D297B72657475726E20746869732E646573656C65637428746869732E5F73656C6563746564466561747572654964732E76616C75657328292C7B73696C656E74';
wwv_flow_imp.g_varchar2_table(210) := '3A652E73696C656E747D292C746869737D2C45652E70726F746F747970652E73657453656C65637465643D66756E6374696F6E28652C743D7B7D297B72657475726E20653D79652865292C746869732E646573656C65637428746869732E5F73656C6563';
wwv_flow_imp.g_varchar2_table(211) := '746564466561747572654964732E76616C75657328292E66696C7465722828743D3E2D313D3D3D652E696E6465784F6628742929292C7B73696C656E743A742E73696C656E747D292C746869732E73656C65637428652E66696C7465722828653D3E2174';
wwv_flow_imp.g_varchar2_table(212) := '6869732E5F73656C6563746564466561747572654964732E68617328652929292C7B73696C656E743A742E73696C656E747D292C746869737D2C45652E70726F746F747970652E73657453656C6563746564436F6F7264696E617465733D66756E637469';
wwv_flow_imp.g_varchar2_table(213) := '6F6E2865297B72657475726E20746869732E5F73656C6563746564436F6F7264696E617465733D652C746869732E5F656D697453656C656374696F6E4368616E67653D21302C746869737D2C45652E70726F746F747970652E636C65617253656C656374';
wwv_flow_imp.g_varchar2_table(214) := '6564436F6F7264696E617465733D66756E6374696F6E28297B72657475726E20746869732E5F73656C6563746564436F6F7264696E617465733D5B5D2C746869732E5F656D697453656C656374696F6E4368616E67653D21302C746869737D2C45652E70';
wwv_flow_imp.g_varchar2_table(215) := '726F746F747970652E67657453656C65637465644964733D66756E6374696F6E28297B72657475726E20746869732E5F73656C6563746564466561747572654964732E76616C75657328297D2C45652E70726F746F747970652E67657453656C65637465';
wwv_flow_imp.g_varchar2_table(216) := '643D66756E6374696F6E28297B72657475726E20746869732E67657453656C656374656449647328292E6D61702828653D3E746869732E67657428652929297D2C45652E70726F746F747970652E67657453656C6563746564436F6F7264696E61746573';
wwv_flow_imp.g_varchar2_table(217) := '3D66756E6374696F6E28297B72657475726E20746869732E5F73656C6563746564436F6F7264696E617465732E6D61702828653D3E287B636F6F7264696E617465733A746869732E67657428652E666561747572655F6964292E676574436F6F7264696E';
wwv_flow_imp.g_varchar2_table(218) := '61746528652E636F6F72645F70617468297D2929297D2C45652E70726F746F747970652E697353656C65637465643D66756E6374696F6E2865297B72657475726E20746869732E5F73656C6563746564466561747572654964732E6861732865297D2C45';
wwv_flow_imp.g_varchar2_table(219) := '652E70726F746F747970652E7365744665617475726550726F70657274793D66756E6374696F6E28652C742C6F2C6E3D7B7D297B746869732E6765742865292E73657450726F706572747928742C6F292C746869732E666561747572654368616E676564';
wwv_flow_imp.g_varchar2_table(220) := '28652C7B73696C656E743A6E2E73696C656E742C616374696F6E3A612E4348414E47455F50524F504552544945537D297D2C45652E70726F746F747970652E73746F72654D6170436F6E6669673D66756E6374696F6E28297B6C2E666F72456163682828';
wwv_flow_imp.g_varchar2_table(221) := '653D3E7B746869732E6374782E6D61705B655D262628746869732E5F6D6170496E697469616C436F6E6669675B655D3D746869732E6374782E6D61705B655D2E6973456E61626C65642829297D29297D2C45652E70726F746F747970652E726573746F72';
wwv_flow_imp.g_varchar2_table(222) := '654D6170436F6E6669673D66756E6374696F6E28297B4F626A6563742E6B65797328746869732E5F6D6170496E697469616C436F6E666967292E666F72456163682828653D3E7B746869732E5F6D6170496E697469616C436F6E6669675B655D3F746869';
wwv_flow_imp.g_varchar2_table(223) := '732E6374782E6D61705B655D2E656E61626C6528293A746869732E6374782E6D61705B655D2E64697361626C6528297D29297D2C45652E70726F746F747970652E676574496E697469616C436F6E66696756616C75653D66756E6374696F6E2865297B72';
wwv_flow_imp.g_varchar2_table(224) := '657475726E20766F696420303D3D3D746869732E5F6D6170496E697469616C436F6E6669675B655D7C7C746869732E5F6D6170496E697469616C436F6E6669675B655D7D3B636F6E73742054653D5B226D6F6465222C2266656174757265222C226D6F75';
wwv_flow_imp.g_varchar2_table(225) := '7365225D3B66756E6374696F6E205F652861297B6C657420633D6E756C6C2C753D6E756C6C3B636F6E7374206C3D7B6F6E52656D6F766528297B72657475726E20612E6D61702E6F666628226C6F6164222C6C2E636F6E6E656374292C636C656172496E';
wwv_flow_imp.g_varchar2_table(226) := '74657276616C2875292C6C2E72656D6F76654C617965727328292C612E73746F72652E726573746F72654D6170436F6E66696728292C612E75692E72656D6F7665427574746F6E7328292C612E6576656E74732E72656D6F76654576656E744C69737465';
wwv_flow_imp.g_varchar2_table(227) := '6E65727328292C612E75692E636C6561724D6170436C617373657328292C612E626F785A6F6F6D496E697469616C2626612E6D61702E626F785A6F6F6D2E656E61626C6528292C612E6D61703D6E756C6C2C612E636F6E7461696E65723D6E756C6C2C61';
wwv_flow_imp.g_varchar2_table(228) := '2E73746F72653D6E756C6C2C632626632E706172656E744E6F64652626632E706172656E744E6F64652E72656D6F76654368696C642863292C633D6E756C6C2C746869737D2C636F6E6E65637428297B612E6D61702E6F666628226C6F6164222C6C2E63';
wwv_flow_imp.g_varchar2_table(229) := '6F6E6E656374292C636C656172496E74657276616C2875292C6C2E6164644C617965727328292C612E73746F72652E73746F72654D6170436F6E66696728292C612E6576656E74732E6164644576656E744C697374656E65727328297D2C6F6E41646428';
wwv_flow_imp.g_varchar2_table(230) := '74297B696628612E6D61703D742C612E6576656E74733D66756E6374696F6E2874297B636F6E7374206E3D4F626A6563742E6B65797328742E6F7074696F6E732E6D6F646573292E726564756365282828652C6F293D3E28655B6F5D3D676528742E6F70';
wwv_flow_imp.g_varchar2_table(231) := '74696F6E732E6D6F6465735B6F5D292C6529292C7B7D293B6C657420723D7B7D2C613D7B7D3B636F6E737420633D7B7D3B6C657420753D6E756C6C2C6C3D6E756C6C3B632E647261673D66756E6374696F6E28652C6E297B6E287B706F696E743A652E70';
wwv_flow_imp.g_varchar2_table(232) := '6F696E742C74696D653A286E65772044617465292E67657454696D6528297D293F28742E75692E71756575654D6170436C6173736573287B6D6F7573653A6F2E445241477D292C6C2E64726167286529293A652E6F726967696E616C4576656E742E7374';
wwv_flow_imp.g_varchar2_table(233) := '6F7050726F7061676174696F6E28297D2C632E6D6F757365647261673D66756E6374696F6E2865297B632E6472616728652C28653D3E217A28722C652929297D2C632E746F756368647261673D66756E6374696F6E2865297B632E6472616728652C2865';
wwv_flow_imp.g_varchar2_table(234) := '3D3E21746528612C652929297D2C632E6D6F7573656D6F76653D66756E6374696F6E2865297B696628313D3D3D28766F69642030213D3D652E6F726967696E616C4576656E742E627574746F6E733F652E6F726967696E616C4576656E742E627574746F';
wwv_flow_imp.g_varchar2_table(235) := '6E733A652E6F726967696E616C4576656E742E7768696368292972657475726E20632E6D6F757365647261672865293B636F6E7374206F3D5828652C74293B652E666561747572655461726765743D6F2C6C2E6D6F7573656D6F76652865297D2C632E6D';
wwv_flow_imp.g_varchar2_table(236) := '6F757365646F776E3D66756E6374696F6E2865297B723D7B74696D653A286E65772044617465292E67657454696D6528292C706F696E743A652E706F696E747D3B636F6E7374206F3D5828652C74293B652E666561747572655461726765743D6F2C6C2E';
wwv_flow_imp.g_varchar2_table(237) := '6D6F757365646F776E2865297D2C632E6D6F75736575703D66756E6374696F6E2865297B636F6E7374206F3D5828652C74293B652E666561747572655461726765743D6F2C7A28722C7B706F696E743A652E706F696E742C74696D653A286E6577204461';
wwv_flow_imp.g_varchar2_table(238) := '7465292E67657454696D6528297D293F6C2E636C69636B2865293A6C2E6D6F75736575702865297D2C632E6D6F7573656F75743D66756E6374696F6E2865297B6C2E6D6F7573656F75742865297D2C632E746F75636873746172743D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(239) := '2865297B69662821742E6F7074696F6E732E746F756368456E61626C65642972657475726E3B613D7B74696D653A286E65772044617465292E67657454696D6528292C706F696E743A652E706F696E747D3B636F6E7374206F3D592E746F75636828652C';
wwv_flow_imp.g_varchar2_table(240) := '6E756C6C2C74295B305D3B652E666561747572655461726765743D6F2C6C2E746F75636873746172742865297D2C632E746F7563686D6F76653D66756E6374696F6E2865297B696628742E6F7074696F6E732E746F756368456E61626C65642972657475';
wwv_flow_imp.g_varchar2_table(241) := '726E206C2E746F7563686D6F76652865292C632E746F756368647261672865297D2C632E746F756368656E643D66756E6374696F6E2865297B696628652E6F726967696E616C4576656E742E70726576656E7444656661756C7428292C21742E6F707469';
wwv_flow_imp.g_varchar2_table(242) := '6F6E732E746F756368456E61626C65642972657475726E3B636F6E7374206F3D592E746F75636828652C6E756C6C2C74295B305D3B652E666561747572655461726765743D6F2C746528612C7B74696D653A286E65772044617465292E67657454696D65';
wwv_flow_imp.g_varchar2_table(243) := '28292C706F696E743A652E706F696E747D293F6C2E7461702865293A6C2E746F756368656E642865297D3B636F6E737420643D653D3E7B636F6E737420743D532865292C6F3D4F2865292C6E3D622865293B72657475726E2128747C7C6F7C7C6E297D3B';
wwv_flow_imp.g_varchar2_table(244) := '66756E6374696F6E207028652C6F2C723D7B7D297B6C2E73746F7028293B636F6E737420693D6E5B655D3B696628766F696420303D3D3D69297468726F77206E6577204572726F722860247B657D206973206E6F742076616C696460293B753D653B636F';
wwv_flow_imp.g_varchar2_table(245) := '6E737420613D6928742C6F293B6C3D6F6528612C74292C722E73696C656E747C7C742E6D61702E6669726528732E4D4F44455F4348414E47452C7B6D6F64653A657D292C742E73746F72652E736574446972747928292C742E73746F72652E72656E6465';
wwv_flow_imp.g_varchar2_table(246) := '7228297D632E6B6579646F776E3D66756E6374696F6E286F297B286F2E737263456C656D656E747C7C6F2E746172676574292E636C6173734C6973742E636F6E7461696E7328652E43414E564153292626282853286F297C7C4F286F29292626742E6F70';
wwv_flow_imp.g_varchar2_table(247) := '74696F6E732E636F6E74726F6C732E74726173683F286F2E70726576656E7444656661756C7428292C6C2E74726173682829293A64286F293F6C2E6B6579646F776E286F293A4D286F292626742E6F7074696F6E732E636F6E74726F6C732E706F696E74';
wwv_flow_imp.g_varchar2_table(248) := '3F7028692E445241575F504F494E54293A4C286F292626742E6F7074696F6E732E636F6E74726F6C732E6C696E655F737472696E673F7028692E445241575F4C494E455F535452494E47293A4E286F292626742E6F7074696F6E732E636F6E74726F6C73';
wwv_flow_imp.g_varchar2_table(249) := '2E706F6C79676F6E26267028692E445241575F504F4C59474F4E29297D2C632E6B657975703D66756E6374696F6E2865297B6428652926266C2E6B657975702865297D2C632E7A6F6F6D656E643D66756E6374696F6E28297B742E73746F72652E636861';
wwv_flow_imp.g_varchar2_table(250) := '6E67655A6F6F6D28297D2C632E646174613D66756E6374696F6E2865297B696628227374796C65223D3D3D652E6461746154797065297B636F6E73747B73657475703A652C6D61703A6F2C6F7074696F6E733A6E2C73746F72653A727D3D743B6E2E7374';
wwv_flow_imp.g_varchar2_table(251) := '796C65732E736F6D652828653D3E6F2E6765744C6179657228652E69642929297C7C28652E6164644C617965727328292C722E736574446972747928292C722E72656E6465722829297D7D3B636F6E737420683D7B74726173683A21312C636F6D62696E';
wwv_flow_imp.g_varchar2_table(252) := '6546656174757265733A21312C756E636F6D62696E6546656174757265733A21317D3B72657475726E7B737461727428297B753D742E6F7074696F6E732E64656661756C744D6F64652C6C3D6F65286E5B755D2874292C74297D2C6368616E67654D6F64';
wwv_flow_imp.g_varchar2_table(253) := '653A702C616374696F6E61626C653A66756E6374696F6E2865297B6C6574206F3D21313B4F626A6563742E6B6579732865292E666F72456163682828743D3E7B696628766F696420303D3D3D685B745D297468726F77206E6577204572726F722822496E';
wwv_flow_imp.g_varchar2_table(254) := '76616C696420616374696F6E207479706522293B685B745D213D3D655B745D2626286F3D2130292C685B745D3D655B745D7D29292C6F2626742E6D61702E6669726528732E414354494F4E41424C452C7B616374696F6E733A687D297D2C63757272656E';
wwv_flow_imp.g_varchar2_table(255) := '744D6F64654E616D653A28293D3E752C63757272656E744D6F646552656E6465723A28652C74293D3E6C2E72656E64657228652C74292C6669726528652C6F297B742E6D61702626742E6D61702E6669726528652C6F297D2C6164644576656E744C6973';
wwv_flow_imp.g_varchar2_table(256) := '74656E65727328297B742E6D61702E6F6E28226D6F7573656D6F7665222C632E6D6F7573656D6F7665292C742E6D61702E6F6E28226D6F757365646F776E222C632E6D6F757365646F776E292C742E6D61702E6F6E28226D6F7573657570222C632E6D6F';
wwv_flow_imp.g_varchar2_table(257) := '7573657570292C742E6D61702E6F6E282264617461222C632E64617461292C742E6D61702E6F6E2822746F7563686D6F7665222C632E746F7563686D6F7665292C742E6D61702E6F6E2822746F7563687374617274222C632E746F756368737461727429';
wwv_flow_imp.g_varchar2_table(258) := '2C742E6D61702E6F6E2822746F756368656E64222C632E746F756368656E64292C742E636F6E7461696E65722E6164644576656E744C697374656E657228226D6F7573656F7574222C632E6D6F7573656F7574292C742E6F7074696F6E732E6B65796269';
wwv_flow_imp.g_varchar2_table(259) := '6E64696E6773262628742E636F6E7461696E65722E6164644576656E744C697374656E657228226B6579646F776E222C632E6B6579646F776E292C742E636F6E7461696E65722E6164644576656E744C697374656E657228226B65797570222C632E6B65';
wwv_flow_imp.g_varchar2_table(260) := '79757029297D2C72656D6F76654576656E744C697374656E65727328297B742E6D61702E6F666628226D6F7573656D6F7665222C632E6D6F7573656D6F7665292C742E6D61702E6F666628226D6F757365646F776E222C632E6D6F757365646F776E292C';
wwv_flow_imp.g_varchar2_table(261) := '742E6D61702E6F666628226D6F7573657570222C632E6D6F7573657570292C742E6D61702E6F6666282264617461222C632E64617461292C742E6D61702E6F66662822746F7563686D6F7665222C632E746F7563686D6F7665292C742E6D61702E6F6666';
wwv_flow_imp.g_varchar2_table(262) := '2822746F7563687374617274222C632E746F7563687374617274292C742E6D61702E6F66662822746F756368656E64222C632E746F756368656E64292C742E636F6E7461696E65722E72656D6F76654576656E744C697374656E657228226D6F7573656F';
wwv_flow_imp.g_varchar2_table(263) := '7574222C632E6D6F7573656F7574292C742E6F7074696F6E732E6B657962696E64696E6773262628742E636F6E7461696E65722E72656D6F76654576656E744C697374656E657228226B6579646F776E222C632E6B6579646F776E292C742E636F6E7461';
wwv_flow_imp.g_varchar2_table(264) := '696E65722E72656D6F76654576656E744C697374656E657228226B65797570222C632E6B6579757029297D2C74726173682865297B6C2E74726173682865297D2C636F6D62696E65466561747572657328297B6C2E636F6D62696E654665617475726573';
wwv_flow_imp.g_varchar2_table(265) := '28297D2C756E636F6D62696E65466561747572657328297B6C2E756E636F6D62696E65466561747572657328297D2C6765744D6F64653A28293D3E757D7D2861292C612E75693D66756E6374696F6E2874297B636F6E7374206F3D7B7D3B6C657420723D';
wwv_flow_imp.g_varchar2_table(266) := '6E756C6C2C733D7B6D6F64653A6E756C6C2C666561747572653A6E756C6C2C6D6F7573653A6E756C6C7D2C613D7B6D6F64653A6E756C6C2C666561747572653A6E756C6C2C6D6F7573653A6E756C6C7D3B66756E6374696F6E20632865297B613D4F626A';
wwv_flow_imp.g_varchar2_table(267) := '6563742E61737369676E28612C65297D66756E6374696F6E207528297B69662821742E636F6E7461696E65722972657475726E3B636F6E737420653D5B5D2C6F3D5B5D3B54652E666F72456163682828743D3E7B615B745D213D3D735B745D262628652E';
wwv_flow_imp.g_varchar2_table(268) := '707573682860247B747D2D247B735B745D7D60292C6E756C6C213D3D615B745D26266F2E707573682860247B747D2D247B615B745D7D6029297D29292C652E6C656E6774683E302626742E636F6E7461696E65722E636C6173734C6973742E72656D6F76';
wwv_flow_imp.g_varchar2_table(269) := '65282E2E2E65292C6F2E6C656E6774683E302626742E636F6E7461696E65722E636C6173734C6973742E616464282E2E2E6F292C733D4F626A6563742E61737369676E28732C61297D66756E6374696F6E206C28742C6F3D7B7D297B636F6E7374206E3D';
wwv_flow_imp.g_varchar2_table(270) := '646F63756D656E742E637265617465456C656D656E742822627574746F6E22293B72657475726E206E2E636C6173734E616D653D60247B652E434F4E54524F4C5F425554544F4E7D20247B6F2E636C6173734E616D657D602C6E2E736574417474726962';
wwv_flow_imp.g_varchar2_table(271) := '75746528227469746C65222C6F2E7469746C65292C6F2E636F6E7461696E65722E617070656E644368696C64286E292C6E2E6164644576656E744C697374656E65722822636C69636B222C28653D3E7B696628652E70726576656E7444656661756C7428';
wwv_flow_imp.g_varchar2_table(272) := '292C652E73746F7050726F7061676174696F6E28292C652E7461726765743D3D3D722972657475726E206428292C766F6964206F2E6F6E4465616374697661746528293B702874292C6F2E6F6E416374697661746528297D292C2130292C6E7D66756E63';
wwv_flow_imp.g_varchar2_table(273) := '74696F6E206428297B72262628722E636C6173734C6973742E72656D6F766528652E4143544956455F425554544F4E292C723D6E756C6C297D66756E6374696F6E20702874297B6428293B636F6E7374206E3D6F5B745D3B6E26266E2626227472617368';
wwv_flow_imp.g_varchar2_table(274) := '22213D3D742626286E2E636C6173734C6973742E61646428652E4143544956455F425554544F4E292C723D6E297D72657475726E7B736574416374697665427574746F6E3A702C71756575654D6170436C61737365733A632C7570646174654D6170436C';
wwv_flow_imp.g_varchar2_table(275) := '61737365733A752C636C6561724D6170436C61737365733A66756E6374696F6E28297B63287B6D6F64653A6E756C6C2C666561747572653A6E756C6C2C6D6F7573653A6E756C6C7D292C7528297D2C616464427574746F6E733A66756E6374696F6E2829';
wwv_flow_imp.g_varchar2_table(276) := '7B636F6E737420723D742E6F7074696F6E732E636F6E74726F6C732C733D646F63756D656E742E637265617465456C656D656E74282264697622293B72657475726E20732E636C6173734E616D653D60247B652E434F4E54524F4C5F47524F55507D2024';
wwv_flow_imp.g_varchar2_table(277) := '7B652E434F4E54524F4C5F424153457D602C723F28725B6E2E504F494E545D2626286F5B6E2E504F494E545D3D6C286E2E504F494E542C7B636F6E7461696E65723A732C636C6173734E616D653A652E434F4E54524F4C5F425554544F4E5F504F494E54';
wwv_flow_imp.g_varchar2_table(278) := '2C7469746C653A224D61726B657220746F6F6C20222B28742E6F7074696F6E732E6B657962696E64696E67733F22283129223A2222292C6F6E41637469766174653A28293D3E742E6576656E74732E6368616E67654D6F646528692E445241575F504F49';
wwv_flow_imp.g_varchar2_table(279) := '4E54292C6F6E446561637469766174653A28293D3E742E6576656E74732E747261736828297D29292C725B6E2E4C494E455D2626286F5B6E2E4C494E455D3D6C286E2E4C494E452C7B636F6E7461696E65723A732C636C6173734E616D653A652E434F4E';
wwv_flow_imp.g_varchar2_table(280) := '54524F4C5F425554544F4E5F4C494E452C7469746C653A224C696E65537472696E6720746F6F6C20222B28742E6F7074696F6E732E6B657962696E64696E67733F22283229223A2222292C6F6E41637469766174653A28293D3E742E6576656E74732E63';
wwv_flow_imp.g_varchar2_table(281) := '68616E67654D6F646528692E445241575F4C494E455F535452494E47292C6F6E446561637469766174653A28293D3E742E6576656E74732E747261736828297D29292C725B6E2E504F4C59474F4E5D2626286F5B6E2E504F4C59474F4E5D3D6C286E2E50';
wwv_flow_imp.g_varchar2_table(282) := '4F4C59474F4E2C7B636F6E7461696E65723A732C636C6173734E616D653A652E434F4E54524F4C5F425554544F4E5F504F4C59474F4E2C7469746C653A22506F6C79676F6E20746F6F6C20222B28742E6F7074696F6E732E6B657962696E64696E67733F';
wwv_flow_imp.g_varchar2_table(283) := '22283329223A2222292C6F6E41637469766174653A28293D3E742E6576656E74732E6368616E67654D6F646528692E445241575F504F4C59474F4E292C6F6E446561637469766174653A28293D3E742E6576656E74732E747261736828297D29292C722E';
wwv_flow_imp.g_varchar2_table(284) := '74726173682626286F2E74726173683D6C28227472617368222C7B636F6E7461696E65723A732C636C6173734E616D653A652E434F4E54524F4C5F425554544F4E5F54524153482C7469746C653A2244656C657465222C6F6E41637469766174653A2829';
wwv_flow_imp.g_varchar2_table(285) := '3D3E7B742E6576656E74732E747261736828297D7D29292C722E636F6D62696E655F66656174757265732626286F2E636F6D62696E655F66656174757265733D6C2822636F6D62696E654665617475726573222C7B636F6E7461696E65723A732C636C61';
wwv_flow_imp.g_varchar2_table(286) := '73734E616D653A652E434F4E54524F4C5F425554544F4E5F434F4D42494E455F46454154555245532C7469746C653A22436F6D62696E65222C6F6E41637469766174653A28293D3E7B742E6576656E74732E636F6D62696E65466561747572657328297D';
wwv_flow_imp.g_varchar2_table(287) := '7D29292C722E756E636F6D62696E655F66656174757265732626286F2E756E636F6D62696E655F66656174757265733D6C2822756E636F6D62696E654665617475726573222C7B636F6E7461696E65723A732C636C6173734E616D653A652E434F4E5452';
wwv_flow_imp.g_varchar2_table(288) := '4F4C5F425554544F4E5F554E434F4D42494E455F46454154555245532C7469746C653A22556E636F6D62696E65222C6F6E41637469766174653A28293D3E7B742E6576656E74732E756E636F6D62696E65466561747572657328297D7D29292C73293A73';
wwv_flow_imp.g_varchar2_table(289) := '7D2C72656D6F7665427574746F6E733A66756E6374696F6E28297B4F626A6563742E6B657973286F292E666F72456163682828653D3E7B636F6E737420743D6F5B655D3B742E706172656E744E6F64652626742E706172656E744E6F64652E72656D6F76';
wwv_flow_imp.g_varchar2_table(290) := '654368696C642874292C64656C657465206F5B655D7D29297D7D7D2861292C612E636F6E7461696E65723D742E676574436F6E7461696E657228292C612E73746F72653D6E65772045652861292C633D612E75692E616464427574746F6E7328292C612E';
wwv_flow_imp.g_varchar2_table(291) := '6F7074696F6E732E626F7853656C656374297B612E626F785A6F6F6D496E697469616C3D742E626F785A6F6F6D2E6973456E61626C656428292C742E626F785A6F6F6D2E64697361626C6528293B636F6E737420653D742E6472616750616E2E6973456E';
wwv_flow_imp.g_varchar2_table(292) := '61626C656428293B742E6472616750616E2E64697361626C6528292C742E6472616750616E2E656E61626C6528292C657C7C742E6472616750616E2E64697361626C6528297D72657475726E20742E6C6F6164656428293F6C2E636F6E6E65637428293A';
wwv_flow_imp.g_varchar2_table(293) := '28742E6F6E28226C6F6164222C6C2E636F6E6E656374292C753D736574496E74657276616C282828293D3E7B742E6C6F61646564282926266C2E636F6E6E65637428297D292C313629292C612E6576656E74732E737461727428292C637D2C6164644C61';
wwv_flow_imp.g_varchar2_table(294) := '7965727328297B612E6D61702E616464536F7572636528742E434F4C442C7B646174613A7B747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A5B5D7D2C747970653A2267656F6A736F6E227D292C612E6D61702E61';
wwv_flow_imp.g_varchar2_table(295) := '6464536F7572636528742E484F542C7B646174613A7B747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A5B5D7D2C747970653A2267656F6A736F6E227D292C612E6F7074696F6E732E7374796C65732E666F724561';
wwv_flow_imp.g_varchar2_table(296) := '63682828653D3E7B612E6D61702E6164644C617965722865297D29292C612E73746F72652E7365744469727479282130292C612E73746F72652E72656E64657228297D2C72656D6F76654C617965727328297B612E6F7074696F6E732E7374796C65732E';
wwv_flow_imp.g_varchar2_table(297) := '666F72456163682828653D3E7B612E6D61702E6765744C6179657228652E6964292626612E6D61702E72656D6F76654C6179657228652E6964297D29292C612E6D61702E676574536F7572636528742E434F4C44292626612E6D61702E72656D6F766553';
wwv_flow_imp.g_varchar2_table(298) := '6F7572636528742E434F4C44292C612E6D61702E676574536F7572636528742E484F54292626612E6D61702E72656D6F7665536F7572636528742E484F54297D7D3B72657475726E20612E73657475703D6C2C6C7D636F6E73742076653D222333626232';
wwv_flow_imp.g_varchar2_table(299) := '6430222C49653D2223666262303362222C53653D2223666666223B766172204F653D5B7B69643A22676C2D647261772D706F6C79676F6E2D66696C6C222C747970653A2266696C6C222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065';
wwv_flow_imp.g_varchar2_table(300) := '222C22506F6C79676F6E225D5D2C7061696E743A7B2266696C6C2D636F6C6F72223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C49652C76655D2C2266696C6C2D6F706163697479223A2E317D7D2C';
wwv_flow_imp.g_varchar2_table(301) := '7B69643A22676C2D647261772D6C696E6573222C747970653A226C696E65222C66696C7465723A5B22616E79222C5B223D3D222C222474797065222C224C696E65537472696E67225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C';
wwv_flow_imp.g_varchar2_table(302) := '6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C22';
wwv_flow_imp.g_varchar2_table(303) := '74727565225D2C49652C76655D2C226C696E652D646173686172726179223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C5B2E322C325D2C5B322C305D5D2C226C696E652D7769647468223A327D7D';
wwv_flow_imp.g_varchar2_table(304) := '2C7B69643A22676C2D647261772D706F696E742D6F75746572222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C226665617475726522';
wwv_flow_imp.g_varchar2_table(305) := '5D5D2C7061696E743A7B22636972636C652D726164697573223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C372C355D2C22636972636C652D636F6C6F72223A53657D7D2C7B69643A22676C2D6472';
wwv_flow_imp.g_varchar2_table(306) := '61772D706F696E742D696E6E6572222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C2266656174757265225D5D2C7061696E743A7B22';
wwv_flow_imp.g_varchar2_table(307) := '636972636C652D726164697573223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C352C335D2C22636972636C652D636F6C6F72223A5B2263617365222C5B223D3D222C5B22676574222C2261637469';
wwv_flow_imp.g_varchar2_table(308) := '7665225D2C2274727565225D2C49652C76655D7D7D2C7B69643A22676C2D647261772D7665727465782D6F75746572222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C';
wwv_flow_imp.g_varchar2_table(309) := '5B223D3D222C226D657461222C22766572746578225D2C5B22213D222C226D6F6465222C2273696D706C655F73656C656374225D5D2C7061696E743A7B22636972636C652D726164697573223A5B2263617365222C5B223D3D222C5B22676574222C2261';
wwv_flow_imp.g_varchar2_table(310) := '6374697665225D2C2274727565225D2C372C355D2C22636972636C652D636F6C6F72223A53657D7D2C7B69643A22676C2D647261772D7665727465782D696E6E6572222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D';
wwv_flow_imp.g_varchar2_table(311) := '222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C22766572746578225D2C5B22213D222C226D6F6465222C2273696D706C655F73656C656374225D5D2C7061696E743A7B22636972636C652D726164697573223A5B226361';
wwv_flow_imp.g_varchar2_table(312) := '7365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C352C335D2C22636972636C652D636F6C6F72223A49657D7D2C7B69643A22676C2D647261772D6D6964706F696E74222C747970653A22636972636C65222C66696C';
wwv_flow_imp.g_varchar2_table(313) := '7465723A5B22616C6C222C5B223D3D222C226D657461222C226D6964706F696E74225D5D2C7061696E743A7B22636972636C652D726164697573223A332C22636972636C652D636F6C6F72223A49657D7D5D3B66756E6374696F6E204D6528652C74297B';
wwv_flow_imp.g_varchar2_table(314) := '746869732E783D652C746869732E793D747D66756E6374696F6E204C6528652C74297B636F6E7374206F3D742E676574426F756E64696E67436C69656E745265637428293B72657475726E206E6577204D6528652E636C69656E74582D6F2E6C6566742D';
wwv_flow_imp.g_varchar2_table(315) := '28742E636C69656E744C6566747C7C30292C652E636C69656E74592D6F2E746F702D28742E636C69656E74546F707C7C3029297D66756E6374696F6E204E6528652C742C6F2C6E297B72657475726E7B747970653A722E464541545552452C70726F7065';
wwv_flow_imp.g_varchar2_table(316) := '72746965733A7B6D6574613A632E5645525445582C706172656E743A652C636F6F72645F706174683A6F2C6163746976653A6E3F752E4143544956453A752E494E4143544956457D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F72';
wwv_flow_imp.g_varchar2_table(317) := '64696E617465733A747D7D7D66756E6374696F6E20626528652C742C6F297B6966286E756C6C213D3D6529666F7228766172206E2C722C692C732C612C632C752C6C2C643D302C703D302C683D652E747970652C663D2246656174757265436F6C6C6563';
wwv_flow_imp.g_varchar2_table(318) := '74696F6E223D3D3D682C673D2246656174757265223D3D3D682C793D663F652E66656174757265732E6C656E6774683A312C6D3D303B6D3C793B6D2B2B297B613D286C3D212128753D663F652E66656174757265735B6D5D2E67656F6D657472793A673F';
wwv_flow_imp.g_varchar2_table(319) := '652E67656F6D657472793A652926262247656F6D65747279436F6C6C656374696F6E223D3D3D752E74797065293F752E67656F6D6574726965732E6C656E6774683A313B666F722876617220453D303B453C613B452B2B297B76617220433D302C543D30';
wwv_flow_imp.g_varchar2_table(320) := '3B6966286E756C6C213D3D28733D6C3F752E67656F6D6574726965735B455D3A7529297B633D732E636F6F7264696E617465733B766172205F3D732E747970653B73776974636828643D302C5F297B63617365206E756C6C3A627265616B3B6361736522';
wwv_flow_imp.g_varchar2_table(321) := '506F696E74223A69662821313D3D3D7428632C702C6D2C432C54292972657475726E21313B702B2B2C432B2B3B627265616B3B63617365224C696E65537472696E67223A63617365224D756C7469506F696E74223A666F72286E3D303B6E3C632E6C656E';
wwv_flow_imp.g_varchar2_table(322) := '6774683B6E2B2B297B69662821313D3D3D7428635B6E5D2C702C6D2C432C54292972657475726E21313B702B2B2C224D756C7469506F696E74223D3D3D5F2626432B2B7D224C696E65537472696E67223D3D3D5F2626432B2B3B627265616B3B63617365';
wwv_flow_imp.g_varchar2_table(323) := '22506F6C79676F6E223A63617365224D756C74694C696E65537472696E67223A666F72286E3D303B6E3C632E6C656E6774683B6E2B2B297B666F7228723D303B723C635B6E5D2E6C656E6774682D643B722B2B297B69662821313D3D3D7428635B6E5D5B';
wwv_flow_imp.g_varchar2_table(324) := '725D2C702C6D2C432C54292972657475726E21313B702B2B7D224D756C74694C696E65537472696E67223D3D3D5F2626432B2B2C22506F6C79676F6E223D3D3D5F2626542B2B7D22506F6C79676F6E223D3D3D5F2626432B2B3B627265616B3B63617365';
wwv_flow_imp.g_varchar2_table(325) := '224D756C7469506F6C79676F6E223A666F72286E3D303B6E3C632E6C656E6774683B6E2B2B297B666F7228543D302C723D303B723C635B6E5D2E6C656E6774683B722B2B297B666F7228693D303B693C635B6E5D5B725D2E6C656E6774682D643B692B2B';
wwv_flow_imp.g_varchar2_table(326) := '297B69662821313D3D3D7428635B6E5D5B725D5B695D2C702C6D2C432C54292972657475726E21313B702B2B7D542B2B7D432B2B7D627265616B3B636173652247656F6D65747279436F6C6C656374696F6E223A666F72286E3D303B6E3C732E67656F6D';
wwv_flow_imp.g_varchar2_table(327) := '6574726965732E6C656E6774683B6E2B2B2969662821313D3D3D626528732E67656F6D6574726965735B6E5D2C74292972657475726E21313B627265616B3B64656661756C743A7468726F77206E6577204572726F722822556E6B6E6F776E2047656F6D';
wwv_flow_imp.g_varchar2_table(328) := '65747279205479706522297D7D7D7D7D66756E6374696F6E2050652865297B6966282165297468726F77206E6577204572726F72282267656F6A736F6E20697320726571756972656422293B73776974636828652E74797065297B636173652246656174';
wwv_flow_imp.g_varchar2_table(329) := '757265223A72657475726E2078652865293B636173652246656174757265436F6C6C656374696F6E223A72657475726E2066756E6374696F6E2865297B636F6E737420743D7B747970653A2246656174757265436F6C6C656374696F6E227D3B72657475';
wwv_flow_imp.g_varchar2_table(330) := '726E204F626A6563742E6B6579732865292E666F724561636828286F3D3E7B737769746368286F297B636173652274797065223A63617365226665617475726573223A72657475726E3B64656661756C743A745B6F5D3D655B6F5D7D7D29292C742E6665';
wwv_flow_imp.g_varchar2_table(331) := '6174757265733D652E66656174757265732E6D61702828653D3E786528652929292C747D2865293B6361736522506F696E74223A63617365224C696E65537472696E67223A6361736522506F6C79676F6E223A63617365224D756C7469506F696E74223A';
wwv_flow_imp.g_varchar2_table(332) := '63617365224D756C74694C696E65537472696E67223A63617365224D756C7469506F6C79676F6E223A636173652247656F6D65747279436F6C6C656374696F6E223A72657475726E2046652865293B64656661756C743A7468726F77206E657720457272';
wwv_flow_imp.g_varchar2_table(333) := '6F722822756E6B6E6F776E2047656F4A534F4E207479706522297D7D66756E6374696F6E2078652865297B636F6E737420743D7B747970653A2246656174757265227D3B72657475726E204F626A6563742E6B6579732865292E666F724561636828286F';
wwv_flow_imp.g_varchar2_table(334) := '3D3E7B737769746368286F297B636173652274797065223A636173652270726F70657274696573223A636173652267656F6D65747279223A72657475726E3B64656661756C743A745B6F5D3D655B6F5D7D7D29292C742E70726F706572746965733D4165';
wwv_flow_imp.g_varchar2_table(335) := '28652E70726F70657274696573292C6E756C6C3D3D652E67656F6D657472793F742E67656F6D657472793D6E756C6C3A742E67656F6D657472793D466528652E67656F6D65747279292C747D66756E6374696F6E2041652865297B636F6E737420743D7B';
wwv_flow_imp.g_varchar2_table(336) := '7D3B72657475726E20653F284F626A6563742E6B6579732865292E666F724561636828286F3D3E7B636F6E7374206E3D655B6F5D3B226F626A656374223D3D747970656F66206E3F6E756C6C3D3D3D6E3F745B6F5D3D6E756C6C3A41727261792E697341';
wwv_flow_imp.g_varchar2_table(337) := '72726179286E293F745B6F5D3D6E2E6D61702828653D3E6529293A745B6F5D3D4165286E293A745B6F5D3D6E7D29292C74293A747D66756E6374696F6E2046652865297B636F6E737420743D7B747970653A652E747970657D3B72657475726E20652E62';
wwv_flow_imp.g_varchar2_table(338) := '626F78262628742E62626F783D652E62626F78292C2247656F6D65747279436F6C6C656374696F6E223D3D3D652E747970653F28742E67656F6D6574726965733D652E67656F6D6574726965732E6D61702828653D3E466528652929292C74293A28742E';
wwv_flow_imp.g_varchar2_table(339) := '636F6F7264696E617465733D776528652E636F6F7264696E61746573292C74297D66756E6374696F6E2077652865297B636F6E737420743D653B72657475726E226F626A65637422213D747970656F6620745B305D3F742E736C69636528293A742E6D61';
wwv_flow_imp.g_varchar2_table(340) := '702828653D3E776528652929297D66756E6374696F6E20526528652C743D7B7D297B72657475726E20446528652C226D65726361746F72222C74297D66756E6374696F6E20446528652C742C6F3D7B7D297B766172206E2C723D286F3D6F7C7C7B7D292E';
wwv_flow_imp.g_varchar2_table(341) := '6D75746174653B6966282165297468726F77206E6577204572726F72282267656F6A736F6E20697320726571756972656422293B72657475726E2141727261792E697341727261792865297C7C286E3D655B305D2C69734E614E286E297C7C6E756C6C3D';
wwv_flow_imp.g_varchar2_table(342) := '3D3D6E7C7C41727261792E69734172726179286E29293F282130213D3D72262628653D5065286529292C626528652C2866756E6374696F6E2865297B766172206F3D226D65726361746F72223D3D3D743F55652865293A6B652865293B655B305D3D6F5B';
wwv_flow_imp.g_varchar2_table(343) := '305D2C655B315D3D6F5B315D7D2929293A653D226D65726361746F72223D3D3D743F55652865293A6B652865292C657D66756E6374696F6E2055652865297B76617220742C6F3D4D6174682E50492F3138302C6E3D363337383133372C723D3230303337';
wwv_flow_imp.g_varchar2_table(344) := '3530382E3334323738393234342C693D5B6E2A284D6174682E61627328655B305D293C3D3138303F655B305D3A655B305D2D3336302A2828743D655B305D293C303F2D313A743E303F313A3029292A6F2C6E2A4D6174682E6C6F67284D6174682E74616E';
wwv_flow_imp.g_varchar2_table(345) := '282E32352A4D6174682E50492B2E352A655B315D2A6F29295D3B72657475726E20695B305D3E72262628695B305D3D72292C695B305D3C2D72262628695B305D3D2D72292C695B315D3E72262628695B315D3D72292C695B315D3C2D72262628695B315D';
wwv_flow_imp.g_varchar2_table(346) := '3D2D72292C697D66756E6374696F6E206B652865297B76617220743D3138302F4D6174682E50492C6F3D363337383133373B72657475726E5B655B305D2A742F6F2C282E352A4D6174682E50492D322A4D6174682E6174616E284D6174682E657870282D';
wwv_flow_imp.g_varchar2_table(347) := '655B315D2F6F2929292A745D7D66756E6374696F6E20566528652C742C6F297B636F6E7374206E3D742E67656F6D657472792E636F6F7264696E617465732C693D6F2E67656F6D657472792E636F6F7264696E617465733B6966286E5B315D3E707C7C6E';
wwv_flow_imp.g_varchar2_table(348) := '5B315D3C647C7C695B315D3E707C7C695B315D3C642972657475726E206E756C6C3B636F6E737420733D5265286E292C613D52652869292C753D653D3E4E756D62657228652E746F4669786564283829292C6C3D28652C74293D3E28652B74292F322C68';
wwv_flow_imp.g_varchar2_table(349) := '3D66756E6374696F6E28652C743D7B7D297B72657475726E20446528652C227767733834222C74297D285B6C28735B305D2C615B305D292C6C28735B315D2C615B315D295D292C663D5B7528685B305D292C7528685B315D295D3B72657475726E7B7479';
wwv_flow_imp.g_varchar2_table(350) := '70653A722E464541545552452C70726F706572746965733A7B6D6574613A632E4D4944504F494E542C706172656E743A652C6C6E673A665B305D2C6C61743A665B315D2C636F6F72645F706174683A6F2E70726F706572746965732E636F6F72645F7061';
wwv_flow_imp.g_varchar2_table(351) := '74687D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F7264696E617465733A667D7D7D66756E6374696F6E20476528652C743D7B7D2C6F3D6E756C6C297B636F6E73747B747970653A6E2C636F6F7264696E617465733A697D3D652E';
wwv_flow_imp.g_varchar2_table(352) := '67656F6D657472792C733D652E70726F706572746965732626652E70726F706572746965732E69643B6C657420613D5B5D3B66756E6374696F6E206328652C6F297B6C6574206E3D22222C723D6E756C6C3B652E666F7245616368282828652C69293D3E';
wwv_flow_imp.g_varchar2_table(353) := '7B636F6E737420633D6E756C6C213D6F3F60247B6F7D2E247B697D603A537472696E672869292C6C3D4E6528732C652C632C75286329293B696628742E6D6964706F696E7473262672297B636F6E737420653D566528732C722C6C293B652626612E7075';
wwv_flow_imp.g_varchar2_table(354) := '73682865297D723D6C3B636F6E737420643D4A534F4E2E737472696E676966792865293B6E213D3D642626612E70757368286C292C303D3D3D692626286E3D64297D29297D66756E6374696F6E20752865297B72657475726E2121742E73656C65637465';
wwv_flow_imp.g_varchar2_table(355) := '64506174687326262D31213D3D742E73656C656374656450617468732E696E6465784F662865297D72657475726E206E3D3D3D722E504F494E543F612E70757368284E6528732C692C6F2C75286F2929293A6E3D3D3D722E504F4C59474F4E3F692E666F';
wwv_flow_imp.g_varchar2_table(356) := '7245616368282828652C74293D3E7B6328652C6E756C6C213D3D6F3F60247B6F7D2E247B747D603A537472696E67287429297D29293A6E3D3D3D722E4C494E455F535452494E473F6328692C6F293A303D3D3D6E2E696E6465784F6628722E4D554C5449';
wwv_flow_imp.g_varchar2_table(357) := '5F50524546495829262666756E6374696F6E28297B636F6E7374206F3D6E2E7265706C61636528722E4D554C54495F5052454649582C2222293B692E666F72456163682828286E2C69293D3E7B636F6E737420733D7B747970653A722E46454154555245';
wwv_flow_imp.g_varchar2_table(358) := '2C70726F706572746965733A652E70726F706572746965732C67656F6D657472793A7B747970653A6F2C636F6F7264696E617465733A6E7D7D3B613D612E636F6E63617428476528732C742C6929297D29297D28292C617D4D652E70726F746F74797065';
wwv_flow_imp.g_varchar2_table(359) := '3D7B636C6F6E6528297B72657475726E206E6577204D6528746869732E782C746869732E79297D2C6164642865297B72657475726E20746869732E636C6F6E6528292E5F6164642865297D2C7375622865297B72657475726E20746869732E636C6F6E65';
wwv_flow_imp.g_varchar2_table(360) := '28292E5F7375622865297D2C6D756C744279506F696E742865297B72657475726E20746869732E636C6F6E6528292E5F6D756C744279506F696E742865297D2C6469764279506F696E742865297B72657475726E20746869732E636C6F6E6528292E5F64';
wwv_flow_imp.g_varchar2_table(361) := '69764279506F696E742865297D2C6D756C742865297B72657475726E20746869732E636C6F6E6528292E5F6D756C742865297D2C6469762865297B72657475726E20746869732E636C6F6E6528292E5F6469762865297D2C726F746174652865297B7265';
wwv_flow_imp.g_varchar2_table(362) := '7475726E20746869732E636C6F6E6528292E5F726F746174652865297D2C726F7461746541726F756E6428652C74297B72657475726E20746869732E636C6F6E6528292E5F726F7461746541726F756E6428652C74297D2C6D61744D756C742865297B72';
wwv_flow_imp.g_varchar2_table(363) := '657475726E20746869732E636C6F6E6528292E5F6D61744D756C742865297D2C756E697428297B72657475726E20746869732E636C6F6E6528292E5F756E697428297D2C7065727028297B72657475726E20746869732E636C6F6E6528292E5F70657270';
wwv_flow_imp.g_varchar2_table(364) := '28297D2C726F756E6428297B72657475726E20746869732E636C6F6E6528292E5F726F756E6428297D2C6D616728297B72657475726E204D6174682E7371727428746869732E782A746869732E782B746869732E792A746869732E79297D2C657175616C';
wwv_flow_imp.g_varchar2_table(365) := '732865297B72657475726E20746869732E783D3D3D652E782626746869732E793D3D3D652E797D2C646973742865297B72657475726E204D6174682E7371727428746869732E64697374537172286529297D2C646973745371722865297B636F6E737420';
wwv_flow_imp.g_varchar2_table(366) := '743D652E782D746869732E782C6F3D652E792D746869732E793B72657475726E20742A742B6F2A6F7D2C616E676C6528297B72657475726E204D6174682E6174616E3228746869732E792C746869732E78297D2C616E676C65546F2865297B7265747572';
wwv_flow_imp.g_varchar2_table(367) := '6E204D6174682E6174616E3228746869732E792D652E792C746869732E782D652E78297D2C616E676C65576974682865297B72657475726E20746869732E616E676C655769746853657028652E782C652E79297D2C616E676C655769746853657028652C';
wwv_flow_imp.g_varchar2_table(368) := '74297B72657475726E204D6174682E6174616E3228746869732E782A742D746869732E792A652C746869732E782A652B746869732E792A74297D2C5F6D61744D756C742865297B636F6E737420743D655B305D2A746869732E782B655B315D2A74686973';
wwv_flow_imp.g_varchar2_table(369) := '2E792C6F3D655B325D2A746869732E782B655B335D2A746869732E793B72657475726E20746869732E783D742C746869732E793D6F2C746869737D2C5F6164642865297B72657475726E20746869732E782B3D652E782C746869732E792B3D652E792C74';
wwv_flow_imp.g_varchar2_table(370) := '6869737D2C5F7375622865297B72657475726E20746869732E782D3D652E782C746869732E792D3D652E792C746869737D2C5F6D756C742865297B72657475726E20746869732E782A3D652C746869732E792A3D652C746869737D2C5F6469762865297B';
wwv_flow_imp.g_varchar2_table(371) := '72657475726E20746869732E782F3D652C746869732E792F3D652C746869737D2C5F6D756C744279506F696E742865297B72657475726E20746869732E782A3D652E782C746869732E792A3D652E792C746869737D2C5F6469764279506F696E74286529';
wwv_flow_imp.g_varchar2_table(372) := '7B72657475726E20746869732E782F3D652E782C746869732E792F3D652E792C746869737D2C5F756E697428297B72657475726E20746869732E5F64697628746869732E6D61672829292C746869737D2C5F7065727028297B636F6E737420653D746869';
wwv_flow_imp.g_varchar2_table(373) := '732E793B72657475726E20746869732E793D746869732E782C746869732E783D2D652C746869737D2C5F726F746174652865297B636F6E737420743D4D6174682E636F732865292C6F3D4D6174682E73696E2865292C6E3D742A746869732E782D6F2A74';
wwv_flow_imp.g_varchar2_table(374) := '6869732E792C723D6F2A746869732E782B742A746869732E793B72657475726E20746869732E783D6E2C746869732E793D722C746869737D2C5F726F7461746541726F756E6428652C74297B636F6E7374206F3D4D6174682E636F732865292C6E3D4D61';
wwv_flow_imp.g_varchar2_table(375) := '74682E73696E2865292C723D742E782B6F2A28746869732E782D742E78292D6E2A28746869732E792D742E79292C693D742E792B6E2A28746869732E782D742E78292B6F2A28746869732E792D742E79293B72657475726E20746869732E783D722C7468';
wwv_flow_imp.g_varchar2_table(376) := '69732E793D692C746869737D2C5F726F756E6428297B72657475726E20746869732E783D4D6174682E726F756E6428746869732E78292C746869732E793D4D6174682E726F756E6428746869732E79292C746869737D2C636F6E7374727563746F723A4D';
wwv_flow_imp.g_varchar2_table(377) := '657D2C4D652E636F6E766572743D66756E6374696F6E2865297B6966286520696E7374616E63656F66204D652972657475726E20653B69662841727261792E697341727261792865292972657475726E206E6577204D65282B655B305D2C2B655B315D29';
wwv_flow_imp.g_varchar2_table(378) := '3B696628766F69642030213D3D652E782626766F69642030213D3D652E792972657475726E206E6577204D65282B652E782C2B652E79293B7468726F77206E6577204572726F7228224578706563746564205B782C20795D206F72207B782C20797D2070';
wwv_flow_imp.g_varchar2_table(379) := '6F696E7420666F726D617422297D3B7661722042653D7B656E61626C652865297B73657454696D656F7574282828293D3E7B652E6D61702626652E6D61702E646F75626C65436C69636B5A6F6F6D2626652E5F6374782626652E5F6374782E73746F7265';
wwv_flow_imp.g_varchar2_table(380) := '2626652E5F6374782E73746F72652E676574496E697469616C436F6E66696756616C75652626652E5F6374782E73746F72652E676574496E697469616C436F6E66696756616C75652822646F75626C65436C69636B5A6F6F6D22292626652E6D61702E64';
wwv_flow_imp.g_varchar2_table(381) := '6F75626C65436C69636B5A6F6F6D2E656E61626C6528297D292C30297D2C64697361626C652865297B73657454696D656F7574282828293D3E7B652E6D61702626652E6D61702E646F75626C65436C69636B5A6F6F6D2626652E6D61702E646F75626C65';
wwv_flow_imp.g_varchar2_table(382) := '436C69636B5A6F6F6D2E64697361626C6528297D292C30297D7D3B636F6E73747B4C41545F4D494E3A6A652C4C41545F4D41583A4A652C4C41545F52454E44455245445F4D494E3A24652C4C41545F52454E44455245445F4D41583A59652C4C4E475F4D';
wwv_flow_imp.g_varchar2_table(383) := '494E3A48652C4C4E475F4D41583A58657D3D683B66756E6374696F6E20716528652C74297B6C6574206F3D6A652C6E3D4A652C723D6A652C693D4A652C733D58652C613D48653B652E666F72456163682828653D3E7B636F6E737420743D66756E637469';
wwv_flow_imp.g_varchar2_table(384) := '6F6E2865297B636F6E737420743D7B506F696E743A302C4C696E65537472696E673A312C506F6C79676F6E3A322C4D756C7469506F696E743A312C4D756C74694C696E65537472696E673A322C4D756C7469506F6C79676F6E3A337D5B652E67656F6D65';
wwv_flow_imp.g_varchar2_table(385) := '7472792E747970655D2C6F3D5B652E67656F6D657472792E636F6F7264696E617465735D2E666C61742874292C6E3D6F2E6D61702828653D3E655B305D29292C723D6F2E6D61702828653D3E655B315D29292C693D653D3E4D6174682E6D696E2E617070';
wwv_flow_imp.g_varchar2_table(386) := '6C79286E756C6C2C65292C733D653D3E4D6174682E6D61782E6170706C79286E756C6C2C65293B72657475726E5B69286E292C692872292C73286E292C732872295D7D2865292C633D745B315D2C753D745B335D2C6C3D745B305D2C643D745B325D3B63';
wwv_flow_imp.g_varchar2_table(387) := '3E6F2626286F3D63292C753C6E2626286E3D75292C753E72262628723D75292C633C69262628693D63292C6C3C73262628733D6C292C643E61262628613D64297D29293B636F6E737420633D743B72657475726E206F2B632E6C61743E5965262628632E';
wwv_flow_imp.g_varchar2_table(388) := '6C61743D59652D6F292C722B632E6C61743E4A65262628632E6C61743D4A652D72292C6E2B632E6C61743C2465262628632E6C61743D24652D6E292C692B632E6C61743C6A65262628632E6C61743D6A652D69292C732B632E6C6E673C3D486526262863';
wwv_flow_imp.g_varchar2_table(389) := '2E6C6E672B3D3336302A4D6174682E6365696C284D6174682E61627328632E6C6E67292F33363029292C612B632E6C6E673E3D5865262628632E6C6E672D3D3336302A4D6174682E6365696C284D6174682E61627328632E6C6E67292F33363029292C63';
wwv_flow_imp.g_varchar2_table(390) := '7D66756E6374696F6E204B6528652C74297B636F6E7374206F3D716528652E6D61702828653D3E652E746F47656F4A534F4E282929292C74293B652E666F72456163682828653D3E7B636F6E737420743D652E676574436F6F7264696E6174657328292C';
wwv_flow_imp.g_varchar2_table(391) := '6E3D653D3E7B636F6E737420743D7B6C6E673A655B305D2B6F2E6C6E672C6C61743A655B315D2B6F2E6C61747D3B72657475726E5B742E6C6E672C742E6C61745D7D2C693D653D3E652E6D61702828653D3E6E28652929292C733D653D3E652E6D617028';
wwv_flow_imp.g_varchar2_table(392) := '28653D3E6928652929293B6C657420613B652E747970653D3D3D722E504F494E543F613D6E2874293A652E747970653D3D3D722E4C494E455F535452494E477C7C652E747970653D3D3D722E4D554C54495F504F494E543F613D742E6D6170286E293A65';
wwv_flow_imp.g_varchar2_table(393) := '2E747970653D3D3D722E504F4C59474F4E7C7C652E747970653D3D3D722E4D554C54495F4C494E455F535452494E473F613D742E6D61702869293A652E747970653D3D3D722E4D554C54495F504F4C59474F4E262628613D742E6D6170287329292C652E';
wwv_flow_imp.g_varchar2_table(394) := '696E636F6D696E67436F6F7264732861297D29297D636F6E7374205A653D7B6F6E53657475703A66756E6374696F6E2865297B636F6E737420743D7B647261674D6F76654C6F636174696F6E3A6E756C6C2C626F7853656C65637453746172744C6F6361';
wwv_flow_imp.g_varchar2_table(395) := '74696F6E3A6E756C6C2C626F7853656C656374456C656D656E743A766F696420302C626F7853656C656374696E673A21312C63616E426F7853656C6563743A21312C647261674D6F76696E673A21312C63616E447261674D6F76653A21312C696E697469';
wwv_flow_imp.g_varchar2_table(396) := '616C4472616750616E53746174653A746869732E6D61702E6472616750616E2E6973456E61626C656428292C696E697469616C6C7953656C6563746564466561747572654964733A652E666561747572654964737C7C5B5D7D3B72657475726E20746869';
wwv_flow_imp.g_varchar2_table(397) := '732E73657453656C656374656428742E696E697469616C6C7953656C6563746564466561747572654964732E66696C7465722828653D3E766F69642030213D3D746869732E676574466561747572652865292929292C746869732E66697265416374696F';
wwv_flow_imp.g_varchar2_table(398) := '6E61626C6528292C746869732E736574416374696F6E61626C655374617465287B636F6D62696E6546656174757265733A21302C756E636F6D62696E6546656174757265733A21302C74726173683A21307D292C747D2C666972655570646174653A6675';
wwv_flow_imp.g_varchar2_table(399) := '6E6374696F6E28297B746869732E6669726528732E5550444154452C7B616374696F6E3A612E4D4F56452C66656174757265733A746869732E67657453656C656374656428292E6D61702828653D3E652E746F47656F4A534F4E282929297D297D2C6669';
wwv_flow_imp.g_varchar2_table(400) := '7265416374696F6E61626C653A66756E6374696F6E28297B636F6E737420653D746869732E67657453656C656374656428292C743D652E66696C7465722828653D3E746869732E6973496E7374616E63654F6628224D756C746946656174757265222C65';
wwv_flow_imp.g_varchar2_table(401) := '2929293B6C6574206F3D21313B696628652E6C656E6774683E31297B6F3D21303B636F6E737420743D655B305D2E747970652E7265706C61636528224D756C7469222C2222293B652E666F72456163682828653D3E7B652E747970652E7265706C616365';
wwv_flow_imp.g_varchar2_table(402) := '28224D756C7469222C222229213D3D742626286F3D2131297D29297D636F6E7374206E3D742E6C656E6774683E302C723D652E6C656E6774683E303B746869732E736574416374696F6E61626C655374617465287B636F6D62696E654665617475726573';
wwv_flow_imp.g_varchar2_table(403) := '3A6F2C756E636F6D62696E6546656174757265733A6E2C74726173683A727D297D2C676574556E697175654964733A66756E6374696F6E2865297B72657475726E20652E6C656E6774683F652E6D61702828653D3E652E70726F706572746965732E6964';
wwv_flow_imp.g_varchar2_table(404) := '29292E66696C7465722828653D3E766F69642030213D3D6529292E726564756365282828652C74293D3E28652E6164642874292C6529292C6E6577204A292E76616C75657328293A5B5D7D2C73746F70457874656E646564496E746572616374696F6E73';
wwv_flow_imp.g_varchar2_table(405) := '3A66756E6374696F6E2865297B652E626F7853656C656374456C656D656E74262628652E626F7853656C656374456C656D656E742E706172656E744E6F64652626652E626F7853656C656374456C656D656E742E706172656E744E6F64652E72656D6F76';
wwv_flow_imp.g_varchar2_table(406) := '654368696C6428652E626F7853656C656374456C656D656E74292C652E626F7853656C656374456C656D656E743D6E756C6C292C28652E63616E447261674D6F76657C7C652E63616E426F7853656C65637429262621303D3D3D652E696E697469616C44';
wwv_flow_imp.g_varchar2_table(407) := '72616750616E53746174652626746869732E6D61702E6472616750616E2E656E61626C6528292C652E626F7853656C656374696E673D21312C652E63616E426F7853656C6563743D21312C652E647261674D6F76696E673D21312C652E63616E44726167';
wwv_flow_imp.g_varchar2_table(408) := '4D6F76653D21317D2C6F6E53746F703A66756E6374696F6E28297B42652E656E61626C652874686973297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28652C74297B72657475726E20432874292626652E647261674D6F76696E672626746869';
wwv_flow_imp.g_varchar2_table(409) := '732E6669726555706461746528292C746869732E73746F70457874656E646564496E746572616374696F6E732865292C21307D2C6F6E4D6F7573654F75743A66756E6374696F6E2865297B72657475726E21652E647261674D6F76696E677C7C74686973';
wwv_flow_imp.g_varchar2_table(410) := '2E6669726555706461746528297D7D3B5A652E6F6E5461703D5A652E6F6E436C69636B3D66756E6374696F6E28652C74297B72657475726E20452874293F746869732E636C69636B416E79776865726528652C74293A6628632E56455254455829287429';
wwv_flow_imp.g_varchar2_table(411) := '3F746869732E636C69636B4F6E56657274657828652C74293A432874293F746869732E636C69636B4F6E4665617475726528652C74293A766F696420307D2C5A652E636C69636B416E7977686572653D66756E6374696F6E2865297B636F6E737420743D';
wwv_flow_imp.g_varchar2_table(412) := '746869732E67657453656C656374656449647328293B742E6C656E677468262628746869732E636C65617253656C6563746564466561747572657328292C742E666F72456163682828653D3E746869732E646F52656E6465722865292929292C42652E65';
wwv_flow_imp.g_varchar2_table(413) := '6E61626C652874686973292C746869732E73746F70457874656E646564496E746572616374696F6E732865297D2C5A652E636C69636B4F6E5665727465783D66756E6374696F6E28652C74297B746869732E6368616E67654D6F646528692E4449524543';
wwv_flow_imp.g_varchar2_table(414) := '545F53454C4543542C7B6665617475726549643A742E666561747572655461726765742E70726F706572746965732E706172656E742C636F6F7264506174683A742E666561747572655461726765742E70726F706572746965732E636F6F72645F706174';
wwv_flow_imp.g_varchar2_table(415) := '682C7374617274506F733A742E6C6E674C61747D292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D297D2C5A652E73746172744F6E416374697665466561747572653D66756E6374696F6E28652C74297B7468';
wwv_flow_imp.g_varchar2_table(416) := '69732E73746F70457874656E646564496E746572616374696F6E732865292C746869732E6D61702E6472616750616E2E64697361626C6528292C746869732E646F52656E64657228742E666561747572655461726765742E70726F706572746965732E69';
wwv_flow_imp.g_varchar2_table(417) := '64292C652E63616E447261674D6F76653D21302C652E647261674D6F76654C6F636174696F6E3D742E6C6E674C61747D2C5A652E636C69636B4F6E466561747572653D66756E6374696F6E28652C74297B42652E64697361626C652874686973292C7468';
wwv_flow_imp.g_varchar2_table(418) := '69732E73746F70457874656E646564496E746572616374696F6E732865293B636F6E7374206E3D5F2874292C733D746869732E67657453656C656374656449647328292C613D742E666561747572655461726765742E70726F706572746965732E69642C';
wwv_flow_imp.g_varchar2_table(419) := '633D746869732E697353656C65637465642861293B696628216E2626632626746869732E676574466561747572652861292E74797065213D3D722E504F494E542972657475726E20746869732E6368616E67654D6F646528692E4449524543545F53454C';
wwv_flow_imp.g_varchar2_table(420) := '4543542C7B6665617475726549643A617D293B6326266E3F28746869732E646573656C6563742861292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E504F494E5445527D292C313D3D3D732E6C656E677468262642652E65';
wwv_flow_imp.g_varchar2_table(421) := '6E61626C65287468697329293A216326266E3F28746869732E73656C6563742861292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D29293A637C7C6E7C7C28732E666F72456163682828653D3E746869732E64';
wwv_flow_imp.g_varchar2_table(422) := '6F52656E64657228652929292C746869732E73657453656C65637465642861292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D29292C746869732E646F52656E6465722861297D2C5A652E6F6E4D6F75736544';
wwv_flow_imp.g_varchar2_table(423) := '6F776E3D66756E6374696F6E28652C74297B72657475726E20652E696E697469616C4472616750616E53746174653D746869732E6D61702E6472616750616E2E6973456E61626C656428292C792874293F746869732E73746172744F6E41637469766546';
wwv_flow_imp.g_varchar2_table(424) := '65617475726528652C74293A746869732E64726177436F6E6669672E626F7853656C6563742626672874293F746869732E7374617274426F7853656C65637428652C74293A766F696420307D2C5A652E7374617274426F7853656C6563743D66756E6374';
wwv_flow_imp.g_varchar2_table(425) := '696F6E28652C74297B746869732E73746F70457874656E646564496E746572616374696F6E732865292C746869732E6D61702E6472616750616E2E64697361626C6528292C652E626F7853656C65637453746172744C6F636174696F6E3D4C6528742E6F';
wwv_flow_imp.g_varchar2_table(426) := '726967696E616C4576656E742C746869732E6D61702E676574436F6E7461696E65722829292C652E63616E426F7853656C6563743D21307D2C5A652E6F6E546F75636853746172743D66756E6374696F6E28652C74297B69662879287429297265747572';
wwv_flow_imp.g_varchar2_table(427) := '6E20746869732E73746172744F6E4163746976654665617475726528652C74297D2C5A652E6F6E447261673D66756E6374696F6E28652C74297B72657475726E20652E63616E447261674D6F76653F746869732E647261674D6F766528652C74293A7468';
wwv_flow_imp.g_varchar2_table(428) := '69732E64726177436F6E6669672E626F7853656C6563742626652E63616E426F7853656C6563743F746869732E7768696C65426F7853656C65637428652C74293A766F696420307D2C5A652E7768696C65426F7853656C6563743D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(429) := '742C6E297B742E626F7853656C656374696E673D21302C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4144447D292C742E626F7853656C656374456C656D656E747C7C28742E626F7853656C656374456C656D656E743D64';
wwv_flow_imp.g_varchar2_table(430) := '6F63756D656E742E637265617465456C656D656E74282264697622292C742E626F7853656C656374456C656D656E742E636C6173734C6973742E61646428652E424F585F53454C454354292C746869732E6D61702E676574436F6E7461696E657228292E';
wwv_flow_imp.g_varchar2_table(431) := '617070656E644368696C6428742E626F7853656C656374456C656D656E7429293B636F6E737420723D4C65286E2E6F726967696E616C4576656E742C746869732E6D61702E676574436F6E7461696E65722829292C693D4D6174682E6D696E28742E626F';
wwv_flow_imp.g_varchar2_table(432) := '7853656C65637453746172744C6F636174696F6E2E782C722E78292C733D4D6174682E6D617828742E626F7853656C65637453746172744C6F636174696F6E2E782C722E78292C613D4D6174682E6D696E28742E626F7853656C65637453746172744C6F';
wwv_flow_imp.g_varchar2_table(433) := '636174696F6E2E792C722E79292C633D4D6174682E6D617828742E626F7853656C65637453746172744C6F636174696F6E2E792C722E79292C753D607472616E736C61746528247B697D70782C20247B617D707829603B742E626F7853656C656374456C';
wwv_flow_imp.g_varchar2_table(434) := '656D656E742E7374796C652E7472616E73666F726D3D752C742E626F7853656C656374456C656D656E742E7374796C652E5765626B69745472616E73666F726D3D752C742E626F7853656C656374456C656D656E742E7374796C652E77696474683D732D';
wwv_flow_imp.g_varchar2_table(435) := '692B227078222C742E626F7853656C656374456C656D656E742E7374796C652E6865696768743D632D612B227078227D2C5A652E647261674D6F76653D66756E6374696F6E28652C74297B652E647261674D6F76696E673D21302C742E6F726967696E61';
wwv_flow_imp.g_varchar2_table(436) := '6C4576656E742E73746F7050726F7061676174696F6E28293B636F6E7374206F3D7B6C6E673A742E6C6E674C61742E6C6E672D652E647261674D6F76654C6F636174696F6E2E6C6E672C6C61743A742E6C6E674C61742E6C61742D652E647261674D6F76';
wwv_flow_imp.g_varchar2_table(437) := '654C6F636174696F6E2E6C61747D3B4B6528746869732E67657453656C656374656428292C6F292C652E647261674D6F76654C6F636174696F6E3D742E6C6E674C61747D2C5A652E6F6E546F756368456E643D5A652E6F6E4D6F75736555703D66756E63';
wwv_flow_imp.g_varchar2_table(438) := '74696F6E28652C74297B696628652E647261674D6F76696E6729746869732E6669726555706461746528293B656C736520696628652E626F7853656C656374696E67297B636F6E7374206E3D5B652E626F7853656C65637453746172744C6F636174696F';
wwv_flow_imp.g_varchar2_table(439) := '6E2C4C6528742E6F726967696E616C4576656E742C746869732E6D61702E676574436F6E7461696E65722829295D2C723D746869732E66656174757265734174286E756C6C2C6E2C22636C69636B22292C693D746869732E676574556E69717565496473';
wwv_flow_imp.g_varchar2_table(440) := '2872292E66696C7465722828653D3E21746869732E697353656C656374656428652929293B692E6C656E677468262628746869732E73656C6563742869292C692E666F72456163682828653D3E746869732E646F52656E64657228652929292C74686973';
wwv_flow_imp.g_varchar2_table(441) := '2E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D29297D746869732E73746F70457874656E646564496E746572616374696F6E732865297D2C5A652E746F446973706C617946656174757265733D66756E6374696F6E28652C';
wwv_flow_imp.g_varchar2_table(442) := '742C6F297B742E70726F706572746965732E6163746976653D746869732E697353656C656374656428742E70726F706572746965732E6964293F752E4143544956453A752E494E4143544956452C6F2874292C746869732E66697265416374696F6E6162';
wwv_flow_imp.g_varchar2_table(443) := '6C6528292C742E70726F706572746965732E6163746976653D3D3D752E4143544956452626742E67656F6D657472792E74797065213D3D722E504F494E54262647652874292E666F7245616368286F297D2C5A652E6F6E54726173683D66756E6374696F';
wwv_flow_imp.g_varchar2_table(444) := '6E28297B746869732E64656C6574654665617475726528746869732E67657453656C65637465644964732829292C746869732E66697265416374696F6E61626C6528297D2C5A652E6F6E436F6D62696E6546656174757265733D66756E6374696F6E2829';
wwv_flow_imp.g_varchar2_table(445) := '7B636F6E737420653D746869732E67657453656C656374656428293B696628303D3D3D652E6C656E6774687C7C652E6C656E6774683C322972657475726E3B636F6E737420743D5B5D2C6F3D5B5D2C6E3D655B305D2E747970652E7265706C6163652822';
wwv_flow_imp.g_varchar2_table(446) := '4D756C7469222C2222293B666F72286C657420723D303B723C652E6C656E6774683B722B2B297B636F6E737420693D655B725D3B696628692E747970652E7265706C61636528224D756C7469222C222229213D3D6E2972657475726E3B692E747970652E';
wwv_flow_imp.g_varchar2_table(447) := '696E636C7564657328224D756C746922293F692E676574436F6F7264696E6174657328292E666F72456163682828653D3E7B742E707573682865297D29293A742E7075736828692E676574436F6F7264696E617465732829292C6F2E7075736828692E74';
wwv_flow_imp.g_varchar2_table(448) := '6F47656F4A534F4E2829297D6966286F2E6C656E6774683E31297B636F6E737420653D746869732E6E657746656174757265287B747970653A722E464541545552452C70726F706572746965733A6F5B305D2E70726F706572746965732C67656F6D6574';
wwv_flow_imp.g_varchar2_table(449) := '72793A7B747970653A604D756C7469247B6E7D602C636F6F7264696E617465733A747D7D293B746869732E616464466561747572652865292C746869732E64656C6574654665617475726528746869732E67657453656C656374656449647328292C7B73';
wwv_flow_imp.g_varchar2_table(450) := '696C656E743A21307D292C746869732E73657453656C6563746564285B652E69645D292C746869732E6669726528732E434F4D42494E455F46454154555245532C7B6372656174656446656174757265733A5B652E746F47656F4A534F4E28295D2C6465';
wwv_flow_imp.g_varchar2_table(451) := '6C6574656446656174757265733A6F7D297D746869732E66697265416374696F6E61626C6528297D2C5A652E6F6E556E636F6D62696E6546656174757265733D66756E6374696F6E28297B636F6E737420653D746869732E67657453656C656374656428';
wwv_flow_imp.g_varchar2_table(452) := '293B696628303D3D3D652E6C656E6774682972657475726E3B636F6E737420743D5B5D2C6F3D5B5D3B666F72286C6574206E3D303B6E3C652E6C656E6774683B6E2B2B297B636F6E737420723D655B6E5D3B746869732E6973496E7374616E63654F6628';
wwv_flow_imp.g_varchar2_table(453) := '224D756C746946656174757265222C7229262628722E676574466561747572657328292E666F72456163682828653D3E7B746869732E616464466561747572652865292C652E70726F706572746965733D722E70726F706572746965732C742E70757368';
wwv_flow_imp.g_varchar2_table(454) := '28652E746F47656F4A534F4E2829292C746869732E73656C656374285B652E69645D297D29292C746869732E64656C6574654665617475726528722E69642C7B73696C656E743A21307D292C6F2E7075736828722E746F47656F4A534F4E282929297D74';
wwv_flow_imp.g_varchar2_table(455) := '2E6C656E6774683E312626746869732E6669726528732E554E434F4D42494E455F46454154555245532C7B6372656174656446656174757265733A742C64656C6574656446656174757265733A6F7D292C746869732E66697265416374696F6E61626C65';
wwv_flow_imp.g_varchar2_table(456) := '28297D3B636F6E73742057653D6628632E564552544558292C7A653D6628632E4D4944504F494E54292C51653D7B666972655570646174653A66756E6374696F6E28297B746869732E6669726528732E5550444154452C7B616374696F6E3A612E434841';
wwv_flow_imp.g_varchar2_table(457) := '4E47455F434F4F5244494E415445532C66656174757265733A746869732E67657453656C656374656428292E6D61702828653D3E652E746F47656F4A534F4E282929297D297D2C66697265416374696F6E61626C653A66756E6374696F6E2865297B7468';
wwv_flow_imp.g_varchar2_table(458) := '69732E736574416374696F6E61626C655374617465287B636F6D62696E6546656174757265733A21312C756E636F6D62696E6546656174757265733A21312C74726173683A652E73656C6563746564436F6F726450617468732E6C656E6774683E307D29';
wwv_flow_imp.g_varchar2_table(459) := '7D2C73746172744472616767696E673A66756E6374696F6E28652C74297B6E756C6C3D3D652E696E697469616C4472616750616E5374617465262628652E696E697469616C4472616750616E53746174653D746869732E6D61702E6472616750616E2E69';
wwv_flow_imp.g_varchar2_table(460) := '73456E61626C65642829292C746869732E6D61702E6472616750616E2E64697361626C6528292C652E63616E447261674D6F76653D21302C652E647261674D6F76654C6F636174696F6E3D742E6C6E674C61747D2C73746F704472616767696E673A6675';
wwv_flow_imp.g_varchar2_table(461) := '6E6374696F6E2865297B652E63616E447261674D6F7665262621303D3D3D652E696E697469616C4472616750616E53746174652626746869732E6D61702E6472616750616E2E656E61626C6528292C652E696E697469616C4472616750616E5374617465';
wwv_flow_imp.g_varchar2_table(462) := '3D6E756C6C2C652E647261674D6F76696E673D21312C652E63616E447261674D6F76653D21312C652E647261674D6F76654C6F636174696F6E3D6E756C6C7D2C6F6E5665727465783A66756E6374696F6E28652C74297B746869732E7374617274447261';
wwv_flow_imp.g_varchar2_table(463) := '6767696E6728652C74293B636F6E7374206F3D742E666561747572655461726765742E70726F706572746965732C6E3D652E73656C6563746564436F6F726450617468732E696E6465784F66286F2E636F6F72645F70617468293B5F2874297C7C2D3121';
wwv_flow_imp.g_varchar2_table(464) := '3D3D6E3F5F28742926262D313D3D3D6E2626652E73656C6563746564436F6F726450617468732E70757368286F2E636F6F72645F70617468293A652E73656C6563746564436F6F726450617468733D5B6F2E636F6F72645F706174685D3B636F6E737420';
wwv_flow_imp.g_varchar2_table(465) := '723D746869732E7061746873546F436F6F7264696E6174657328652E6665617475726549642C652E73656C6563746564436F6F72645061746873293B746869732E73657453656C6563746564436F6F7264696E617465732872297D2C6F6E4D6964706F69';
wwv_flow_imp.g_varchar2_table(466) := '6E743A66756E6374696F6E28652C74297B746869732E73746172744472616767696E6728652C74293B636F6E7374206F3D742E666561747572655461726765742E70726F706572746965733B652E666561747572652E616464436F6F7264696E61746528';
wwv_flow_imp.g_varchar2_table(467) := '6F2E636F6F72645F706174682C6F2E6C6E672C6F2E6C6174292C746869732E6669726555706461746528292C652E73656C6563746564436F6F726450617468733D5B6F2E636F6F72645F706174685D7D2C7061746873546F436F6F7264696E617465733A';
wwv_flow_imp.g_varchar2_table(468) := '66756E6374696F6E28652C74297B72657475726E20742E6D61702828743D3E287B666561747572655F69643A652C636F6F72645F706174683A747D2929297D2C6F6E466561747572653A66756E6374696F6E28652C74297B303D3D3D652E73656C656374';
wwv_flow_imp.g_varchar2_table(469) := '6564436F6F726450617468732E6C656E6774683F746869732E73746172744472616767696E6728652C74293A746869732E73746F704472616767696E672865297D2C64726167466561747572653A66756E6374696F6E28652C742C6F297B4B6528746869';
wwv_flow_imp.g_varchar2_table(470) := '732E67657453656C656374656428292C6F292C652E647261674D6F76654C6F636174696F6E3D742E6C6E674C61747D2C647261675665727465783A66756E6374696F6E28652C742C6F297B636F6E7374206E3D652E73656C6563746564436F6F72645061';
wwv_flow_imp.g_varchar2_table(471) := '7468732E6D61702828743D3E652E666561747572652E676574436F6F7264696E61746528742929292C693D7165286E2E6D61702828653D3E287B747970653A722E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970';
wwv_flow_imp.g_varchar2_table(472) := '653A722E504F494E542C636F6F7264696E617465733A657D7D2929292C6F293B666F72286C657420743D303B743C6E2E6C656E6774683B742B2B297B636F6E7374206F3D6E5B745D3B652E666561747572652E757064617465436F6F7264696E61746528';
wwv_flow_imp.g_varchar2_table(473) := '652E73656C6563746564436F6F726450617468735B745D2C6F5B305D2B692E6C6E672C6F5B315D2B692E6C6174297D7D2C636C69636B4E6F5461726765743A66756E6374696F6E28297B746869732E6368616E67654D6F646528692E53494D504C455F53';
wwv_flow_imp.g_varchar2_table(474) := '454C454354297D2C636C69636B496E6163746976653A66756E6374696F6E28297B746869732E6368616E67654D6F646528692E53494D504C455F53454C454354297D2C636C69636B416374697665466561747572653A66756E6374696F6E2865297B652E';
wwv_flow_imp.g_varchar2_table(475) := '73656C6563746564436F6F726450617468733D5B5D2C746869732E636C65617253656C6563746564436F6F7264696E6174657328292C652E666561747572652E6368616E67656428297D2C6F6E53657475703A66756E6374696F6E2865297B636F6E7374';
wwv_flow_imp.g_varchar2_table(476) := '20743D652E6665617475726549642C6F3D746869732E676574466561747572652874293B696628216F297468726F77206E6577204572726F722822596F75206D7573742070726F7669646520612066656174757265496420746F20656E74657220646972';
wwv_flow_imp.g_varchar2_table(477) := '6563745F73656C656374206D6F646522293B6966286F2E747970653D3D3D722E504F494E54297468726F77206E657720547970654572726F7228226469726563745F73656C656374206D6F646520646F65736E27742068616E646C6520706F696E742066';
wwv_flow_imp.g_varchar2_table(478) := '6561747572657322293B636F6E7374206E3D7B6665617475726549643A742C666561747572653A6F2C647261674D6F76654C6F636174696F6E3A652E7374617274506F737C7C6E756C6C2C647261674D6F76696E673A21312C63616E447261674D6F7665';
wwv_flow_imp.g_varchar2_table(479) := '3A21312C73656C6563746564436F6F726450617468733A652E636F6F7264506174683F5B652E636F6F7264506174685D3A5B5D7D3B72657475726E20746869732E73657453656C6563746564436F6F7264696E6174657328746869732E7061746873546F';
wwv_flow_imp.g_varchar2_table(480) := '436F6F7264696E6174657328742C6E2E73656C6563746564436F6F7264506174687329292C746869732E73657453656C65637465642874292C42652E64697361626C652874686973292C746869732E736574416374696F6E61626C655374617465287B74';
wwv_flow_imp.g_varchar2_table(481) := '726173683A21307D292C6E7D2C6F6E53746F703A66756E6374696F6E28297B42652E656E61626C652874686973292C746869732E636C65617253656C6563746564436F6F7264696E6174657328297D2C746F446973706C617946656174757265733A6675';
wwv_flow_imp.g_varchar2_table(482) := '6E6374696F6E28652C742C6F297B652E6665617475726549643D3D3D742E70726F706572746965732E69643F28742E70726F706572746965732E6163746976653D752E4143544956452C6F2874292C476528742C7B6D61703A746869732E6D61702C6D69';
wwv_flow_imp.g_varchar2_table(483) := '64706F696E74733A21302C73656C656374656450617468733A652E73656C6563746564436F6F726450617468737D292E666F7245616368286F29293A28742E70726F706572746965732E6163746976653D752E494E4143544956452C6F287429292C7468';
wwv_flow_imp.g_varchar2_table(484) := '69732E66697265416374696F6E61626C652865297D2C6F6E54726173683A66756E6374696F6E2865297B652E73656C6563746564436F6F726450617468732E736F7274282828652C74293D3E742E6C6F63616C65436F6D7061726528652C22656E222C7B';
wwv_flow_imp.g_varchar2_table(485) := '6E756D657269633A21307D2929292E666F72456163682828743D3E652E666561747572652E72656D6F7665436F6F7264696E61746528742929292C746869732E6669726555706461746528292C652E73656C6563746564436F6F726450617468733D5B5D';
wwv_flow_imp.g_varchar2_table(486) := '2C746869732E636C65617253656C6563746564436F6F7264696E6174657328292C746869732E66697265416374696F6E61626C652865292C21313D3D3D652E666561747572652E697356616C69642829262628746869732E64656C657465466561747572';
wwv_flow_imp.g_varchar2_table(487) := '65285B652E6665617475726549645D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B7D29297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28652C74297B636F6E7374206E3D792874292C723D57652874';
wwv_flow_imp.g_varchar2_table(488) := '292C693D7A652874292C733D303D3D3D652E73656C6563746564436F6F726450617468732E6C656E6774683B72657475726E206E2626737C7C72262621733F746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D293A';
wwv_flow_imp.g_varchar2_table(489) := '746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4E4F4E457D292C28727C7C6E7C7C69292626652E647261674D6F76696E672626746869732E6669726555706461746528292C746869732E73746F704472616767696E67286529';
wwv_flow_imp.g_varchar2_table(490) := '2C21307D2C6F6E4D6F7573654F75743A66756E6374696F6E2865297B72657475726E20652E647261674D6F76696E672626746869732E6669726555706461746528292C21307D7D3B51652E6F6E546F75636853746172743D51652E6F6E4D6F757365446F';
wwv_flow_imp.g_varchar2_table(491) := '776E3D66756E6374696F6E28652C74297B72657475726E2057652874293F746869732E6F6E56657274657828652C74293A792874293F746869732E6F6E4665617475726528652C74293A7A652874293F746869732E6F6E4D6964706F696E7428652C7429';
wwv_flow_imp.g_varchar2_table(492) := '3A766F696420307D2C51652E6F6E447261673D66756E6374696F6E28652C74297B6966282130213D3D652E63616E447261674D6F76652972657475726E3B652E647261674D6F76696E673D21302C742E6F726967696E616C4576656E742E73746F705072';
wwv_flow_imp.g_varchar2_table(493) := '6F7061676174696F6E28293B636F6E7374206F3D7B6C6E673A742E6C6E674C61742E6C6E672D652E647261674D6F76654C6F636174696F6E2E6C6E672C6C61743A742E6C6E674C61742E6C61742D652E647261674D6F76654C6F636174696F6E2E6C6174';
wwv_flow_imp.g_varchar2_table(494) := '7D3B652E73656C6563746564436F6F726450617468732E6C656E6774683E303F746869732E6472616756657274657828652C742C6F293A746869732E647261674665617475726528652C742C6F292C652E647261674D6F76654C6F636174696F6E3D742E';
wwv_flow_imp.g_varchar2_table(495) := '6C6E674C61747D2C51652E6F6E436C69636B3D66756E6374696F6E28652C74297B72657475726E20452874293F746869732E636C69636B4E6F54617267657428652C74293A792874293F746869732E636C69636B4163746976654665617475726528652C';
wwv_flow_imp.g_varchar2_table(496) := '74293A6D2874293F746869732E636C69636B496E61637469766528652C74293A766F696420746869732E73746F704472616767696E672865297D2C51652E6F6E5461703D66756E6374696F6E28652C74297B72657475726E20452874293F746869732E63';
wwv_flow_imp.g_varchar2_table(497) := '6C69636B4E6F54617267657428652C74293A792874293F746869732E636C69636B4163746976654665617475726528652C74293A6D2874293F746869732E636C69636B496E61637469766528652C74293A766F696420307D2C51652E6F6E546F75636845';
wwv_flow_imp.g_varchar2_table(498) := '6E643D51652E6F6E4D6F75736555703D66756E6374696F6E2865297B652E647261674D6F76696E672626746869732E6669726555706461746528292C746869732E73746F704472616767696E672865297D3B636F6E73742065743D7B7D3B66756E637469';
wwv_flow_imp.g_varchar2_table(499) := '6F6E20747428652C74297B72657475726E2121652E6C6E674C61742626652E6C6E674C61742E6C6E673D3D3D745B305D2626652E6C6E674C61742E6C61743D3D3D745B315D7D65742E6F6E53657475703D66756E6374696F6E28297B636F6E737420653D';
wwv_flow_imp.g_varchar2_table(500) := '746869732E6E657746656174757265287B747970653A722E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F7264696E617465733A5B5D7D7D293B72657475726E20746869732E61';
wwv_flow_imp.g_varchar2_table(501) := '6464466561747572652865292C746869732E636C65617253656C6563746564466561747572657328292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4144447D292C746869732E61637469766174655549427574746F6E28';
wwv_flow_imp.g_varchar2_table(502) := '6E2E504F494E54292C746869732E736574416374696F6E61626C655374617465287B74726173683A21307D292C7B706F696E743A657D7D2C65742E73746F7044726177696E67416E6452656D6F76653D66756E6374696F6E2865297B746869732E64656C';
wwv_flow_imp.g_varchar2_table(503) := '65746546656174757265285B652E706F696E742E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C454354297D2C65742E6F6E5461703D65742E6F6E436C69636B3D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(504) := '652C74297B746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D292C652E706F696E742E757064617465436F6F7264696E6174652822222C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174292C746869';
wwv_flow_imp.g_varchar2_table(505) := '732E6669726528732E4352454154452C7B66656174757265733A5B652E706F696E742E746F47656F4A534F4E28295D7D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E706F69';
wwv_flow_imp.g_varchar2_table(506) := '6E742E69645D7D297D2C65742E6F6E53746F703D66756E6374696F6E2865297B746869732E61637469766174655549427574746F6E28292C652E706F696E742E676574436F6F7264696E61746528292E6C656E6774687C7C746869732E64656C65746546';
wwv_flow_imp.g_varchar2_table(507) := '656174757265285B652E706F696E742E69645D2C7B73696C656E743A21307D297D2C65742E746F446973706C617946656174757265733D66756E6374696F6E28652C742C6F297B636F6E7374206E3D742E70726F706572746965732E69643D3D3D652E70';
wwv_flow_imp.g_varchar2_table(508) := '6F696E742E69643B696628742E70726F706572746965732E6163746976653D6E3F752E4143544956453A752E494E4143544956452C216E2972657475726E206F2874297D2C65742E6F6E54726173683D65742E73746F7044726177696E67416E6452656D';
wwv_flow_imp.g_varchar2_table(509) := '6F76652C65742E6F6E4B657955703D66756E6374696F6E28652C74297B696628762874297C7C492874292972657475726E20746869732E73746F7044726177696E67416E6452656D6F766528652C74297D3B636F6E7374206F743D7B6F6E53657475703A';
wwv_flow_imp.g_varchar2_table(510) := '66756E6374696F6E28297B636F6E737420653D746869732E6E657746656174757265287B747970653A722E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A722E504F4C59474F4E2C636F6F7264696E617465';
wwv_flow_imp.g_varchar2_table(511) := '733A5B5B5D5D7D7D293B72657475726E20746869732E616464466561747572652865292C746869732E636C65617253656C6563746564466561747572657328292C42652E64697361626C652874686973292C746869732E7570646174655549436C617373';
wwv_flow_imp.g_varchar2_table(512) := '6573287B6D6F7573653A6F2E4144447D292C746869732E61637469766174655549427574746F6E286E2E504F4C59474F4E292C746869732E736574416374696F6E61626C655374617465287B74726173683A21307D292C7B706F6C79676F6E3A652C6375';
wwv_flow_imp.g_varchar2_table(513) := '7272656E74566572746578506F736974696F6E3A307D7D2C636C69636B416E7977686572653A66756E6374696F6E28652C74297B696628652E63757272656E74566572746578506F736974696F6E3E302626747428742C652E706F6C79676F6E2E636F6F';
wwv_flow_imp.g_varchar2_table(514) := '7264696E617465735B305D5B652E63757272656E74566572746578506F736974696F6E2D315D292972657475726E20746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E706F6C79676F';
wwv_flow_imp.g_varchar2_table(515) := '6E2E69645D7D293B746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4144447D292C652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F736974696F6E7D';
wwv_flow_imp.g_varchar2_table(516) := '602C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174292C652E63757272656E74566572746578506F736974696F6E2B2B2C652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E7456657274';
wwv_flow_imp.g_varchar2_table(517) := '6578506F736974696F6E7D602C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174297D2C636C69636B4F6E5665727465783A66756E6374696F6E2865297B72657475726E20746869732E6368616E67654D6F646528692E53494D504C455F53';
wwv_flow_imp.g_varchar2_table(518) := '454C4543542C7B666561747572654964733A5B652E706F6C79676F6E2E69645D7D297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28652C74297B652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272';
wwv_flow_imp.g_varchar2_table(519) := '656E74566572746578506F736974696F6E7D602C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174292C542874292626746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E504F494E5445527D297D7D3B6F742E6F6E';
wwv_flow_imp.g_varchar2_table(520) := '5461703D6F742E6F6E436C69636B3D66756E6374696F6E28652C74297B72657475726E20542874293F746869732E636C69636B4F6E56657274657828652C74293A746869732E636C69636B416E79776865726528652C74297D2C6F742E6F6E4B65795570';
wwv_flow_imp.g_varchar2_table(521) := '3D66756E6374696F6E28652C74297B762874293F28746869732E64656C65746546656174757265285B652E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C45435429';
wwv_flow_imp.g_varchar2_table(522) := '293A492874292626746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E706F6C79676F6E2E69645D7D297D2C6F742E6F6E53746F703D66756E6374696F6E2865297B746869732E757064';
wwv_flow_imp.g_varchar2_table(523) := '6174655549436C6173736573287B6D6F7573653A6F2E4E4F4E457D292C42652E656E61626C652874686973292C746869732E61637469766174655549427574746F6E28292C766F69642030213D3D746869732E6765744665617475726528652E706F6C79';
wwv_flow_imp.g_varchar2_table(524) := '676F6E2E696429262628652E706F6C79676F6E2E72656D6F7665436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F736974696F6E7D60292C652E706F6C79676F6E2E697356616C696428293F746869732E666972652873';
wwv_flow_imp.g_varchar2_table(525) := '2E4352454154452C7B66656174757265733A5B652E706F6C79676F6E2E746F47656F4A534F4E28295D7D293A28746869732E64656C65746546656174757265285B652E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E636861';
wwv_flow_imp.g_varchar2_table(526) := '6E67654D6F646528692E53494D504C455F53454C4543542C7B7D2C7B73696C656E743A21307D2929297D2C6F742E746F446973706C617946656174757265733D66756E6374696F6E28652C742C6F297B636F6E7374206E3D742E70726F70657274696573';
wwv_flow_imp.g_varchar2_table(527) := '2E69643D3D3D652E706F6C79676F6E2E69643B696628742E70726F706572746965732E6163746976653D6E3F752E4143544956453A752E494E4143544956452C216E2972657475726E206F2874293B696628303D3D3D742E67656F6D657472792E636F6F';
wwv_flow_imp.g_varchar2_table(528) := '7264696E617465732E6C656E6774682972657475726E3B636F6E737420693D742E67656F6D657472792E636F6F7264696E617465735B305D2E6C656E6774683B6966282128693C3329297B696628742E70726F706572746965732E6D6574613D632E4645';
wwv_flow_imp.g_varchar2_table(529) := '41545552452C6F284E6528652E706F6C79676F6E2E69642C742E67656F6D657472792E636F6F7264696E617465735B305D5B305D2C22302E30222C213129292C693E33297B636F6E7374206E3D742E67656F6D657472792E636F6F7264696E617465735B';
wwv_flow_imp.g_varchar2_table(530) := '305D2E6C656E6774682D333B6F284E6528652E706F6C79676F6E2E69642C742E67656F6D657472792E636F6F7264696E617465735B305D5B6E5D2C60302E247B6E7D602C213129297D696628693C3D34297B636F6E737420653D5B5B742E67656F6D6574';
wwv_flow_imp.g_varchar2_table(531) := '72792E636F6F7264696E617465735B305D5B305D5B305D2C742E67656F6D657472792E636F6F7264696E617465735B305D5B305D5B315D5D2C5B742E67656F6D657472792E636F6F7264696E617465735B305D5B315D5B305D2C742E67656F6D65747279';
wwv_flow_imp.g_varchar2_table(532) := '2E636F6F7264696E617465735B305D5B315D5B315D5D5D3B6966286F287B747970653A722E464541545552452C70726F706572746965733A742E70726F706572746965732C67656F6D657472793A7B636F6F7264696E617465733A652C747970653A722E';
wwv_flow_imp.g_varchar2_table(533) := '4C494E455F535452494E477D7D292C333D3D3D692972657475726E7D72657475726E206F2874297D7D2C6F742E6F6E54726173683D66756E6374696F6E2865297B746869732E64656C65746546656174757265285B652E706F6C79676F6E2E69645D2C7B';
wwv_flow_imp.g_varchar2_table(534) := '73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C454354297D3B636F6E7374206E743D7B6F6E53657475703A66756E6374696F6E2865297B636F6E737420743D28653D657C7C7B7D292E666561747572';
wwv_flow_imp.g_varchar2_table(535) := '6549643B6C657420692C732C613D22666F7277617264223B69662874297B696628693D746869732E676574466561747572652874292C2169297468726F77206E6577204572726F722822436F756C64206E6F742066696E64206120666561747572652077';
wwv_flow_imp.g_varchar2_table(536) := '697468207468652070726F76696465642066656174757265496422293B6C6574206F3D652E66726F6D3B6966286F26262246656174757265223D3D3D6F2E7479706526266F2E67656F6D65747279262622506F696E74223D3D3D6F2E67656F6D65747279';
wwv_flow_imp.g_varchar2_table(537) := '2E747970652626286F3D6F2E67656F6D65747279292C6F262622506F696E74223D3D3D6F2E7479706526266F2E636F6F7264696E617465732626323D3D3D6F2E636F6F7264696E617465732E6C656E6774682626286F3D6F2E636F6F7264696E61746573';
wwv_flow_imp.g_varchar2_table(538) := '292C216F7C7C2141727261792E69734172726179286F29297468726F77206E6577204572726F722822506C656173652075736520746865206066726F6D602070726F706572747920746F20696E64696361746520776869636820706F696E7420746F2063';
wwv_flow_imp.g_varchar2_table(539) := '6F6E74696E756520746865206C696E652066726F6D22293B636F6E7374206E3D692E636F6F7264696E617465732E6C656E6774682D313B696628692E636F6F7264696E617465735B6E5D5B305D3D3D3D6F5B305D2626692E636F6F7264696E617465735B';
wwv_flow_imp.g_varchar2_table(540) := '6E5D5B315D3D3D3D6F5B315D29733D6E2B312C692E616464436F6F7264696E61746528732C2E2E2E692E636F6F7264696E617465735B6E5D293B656C73657B696628692E636F6F7264696E617465735B305D5B305D213D3D6F5B305D7C7C692E636F6F72';
wwv_flow_imp.g_varchar2_table(541) := '64696E617465735B305D5B315D213D3D6F5B315D297468726F77206E6577204572726F7228226066726F6D602073686F756C64206D617463682074686520706F696E742061742065697468657220746865207374617274206F722074686520656E64206F';
wwv_flow_imp.g_varchar2_table(542) := '66207468652070726F7669646564204C696E65537472696E6722293B613D226261636B7761726473222C733D302C692E616464436F6F7264696E61746528732C2E2E2E692E636F6F7264696E617465735B305D297D7D656C736520693D746869732E6E65';
wwv_flow_imp.g_varchar2_table(543) := '7746656174757265287B747970653A722E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A722E4C494E455F535452494E472C636F6F7264696E617465733A5B5D7D7D292C733D302C746869732E6164644665';
wwv_flow_imp.g_varchar2_table(544) := '61747572652869293B72657475726E20746869732E636C65617253656C6563746564466561747572657328292C42652E64697361626C652874686973292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4144447D292C7468';
wwv_flow_imp.g_varchar2_table(545) := '69732E61637469766174655549427574746F6E286E2E4C494E45292C746869732E736574416374696F6E61626C655374617465287B74726173683A21307D292C7B6C696E653A692C63757272656E74566572746578506F736974696F6E3A732C64697265';
wwv_flow_imp.g_varchar2_table(546) := '6374696F6E3A617D7D2C636C69636B416E7977686572653A66756E6374696F6E28652C74297B696628652E63757272656E74566572746578506F736974696F6E3E302626747428742C652E6C696E652E636F6F7264696E617465735B652E63757272656E';
wwv_flow_imp.g_varchar2_table(547) := '74566572746578506F736974696F6E2D315D297C7C226261636B7761726473223D3D3D652E646972656374696F6E2626747428742C652E6C696E652E636F6F7264696E617465735B652E63757272656E74566572746578506F736974696F6E2B315D2929';
wwv_flow_imp.g_varchar2_table(548) := '72657475726E20746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E6C696E652E69645D7D293B746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4144447D29';
wwv_flow_imp.g_varchar2_table(549) := '2C652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E74566572746578506F736974696F6E2C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174292C22666F7277617264223D3D3D652E646972656374696F6E3F';
wwv_flow_imp.g_varchar2_table(550) := '28652E63757272656E74566572746578506F736974696F6E2B2B2C652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E74566572746578506F736974696F6E2C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174';
wwv_flow_imp.g_varchar2_table(551) := '29293A652E6C696E652E616464436F6F7264696E61746528302C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174297D2C636C69636B4F6E5665727465783A66756E6374696F6E2865297B72657475726E20746869732E6368616E67654D6F';
wwv_flow_imp.g_varchar2_table(552) := '646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E6C696E652E69645D7D297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28652C74297B652E6C696E652E757064617465436F6F7264696E61746528652E6375';
wwv_flow_imp.g_varchar2_table(553) := '7272656E74566572746578506F736974696F6E2C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174292C542874292626746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E504F494E5445527D297D7D3B6E742E6F6E';
wwv_flow_imp.g_varchar2_table(554) := '5461703D6E742E6F6E436C69636B3D66756E6374696F6E28652C74297B696628542874292972657475726E20746869732E636C69636B4F6E56657274657828652C74293B746869732E636C69636B416E79776865726528652C74297D2C6E742E6F6E4B65';
wwv_flow_imp.g_varchar2_table(555) := '7955703D66756E6374696F6E28652C74297B492874293F746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E6C696E652E69645D7D293A76287429262628746869732E64656C65746546';
wwv_flow_imp.g_varchar2_table(556) := '656174757265285B652E6C696E652E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C45435429297D2C6E742E6F6E53746F703D66756E6374696F6E2865297B42652E656E61626C652874';
wwv_flow_imp.g_varchar2_table(557) := '686973292C746869732E61637469766174655549427574746F6E28292C766F69642030213D3D746869732E6765744665617475726528652E6C696E652E696429262628652E6C696E652E72656D6F7665436F6F7264696E6174652860247B652E63757272';
wwv_flow_imp.g_varchar2_table(558) := '656E74566572746578506F736974696F6E7D60292C652E6C696E652E697356616C696428293F746869732E6669726528732E4352454154452C7B66656174757265733A5B652E6C696E652E746F47656F4A534F4E28295D7D293A28746869732E64656C65';
wwv_flow_imp.g_varchar2_table(559) := '746546656174757265285B652E6C696E652E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B7D2C7B73696C656E743A21307D2929297D2C6E742E6F6E54726173683D66756E';
wwv_flow_imp.g_varchar2_table(560) := '6374696F6E2865297B746869732E64656C65746546656174757265285B652E6C696E652E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C454354297D2C6E742E746F446973706C617946';
wwv_flow_imp.g_varchar2_table(561) := '656174757265733D66756E6374696F6E28652C742C6F297B636F6E7374206E3D742E70726F706572746965732E69643D3D3D652E6C696E652E69643B696628742E70726F706572746965732E6163746976653D6E3F752E4143544956453A752E494E4143';
wwv_flow_imp.g_varchar2_table(562) := '544956452C216E2972657475726E206F2874293B742E67656F6D657472792E636F6F7264696E617465732E6C656E6774683C327C7C28742E70726F706572746965732E6D6574613D632E464541545552452C6F284E6528652E6C696E652E69642C742E67';
wwv_flow_imp.g_varchar2_table(563) := '656F6D657472792E636F6F7264696E617465735B22666F7277617264223D3D3D652E646972656374696F6E3F742E67656F6D657472792E636F6F7264696E617465732E6C656E6774682D323A315D2C22222B2822666F7277617264223D3D3D652E646972';
wwv_flow_imp.g_varchar2_table(564) := '656374696F6E3F742E67656F6D657472792E636F6F7264696E617465732E6C656E6774682D323A31292C213129292C6F287429297D3B7661722072743D7B73696D706C655F73656C6563743A5A652C6469726563745F73656C6563743A51652C64726177';
wwv_flow_imp.g_varchar2_table(565) := '5F706F696E743A65742C647261775F706F6C79676F6E3A6F742C647261775F6C696E655F737472696E673A6E747D3B636F6E73742069743D7B64656661756C744D6F64653A692E53494D504C455F53454C4543542C6B657962696E64696E67733A21302C';
wwv_flow_imp.g_varchar2_table(566) := '746F756368456E61626C65643A21302C636C69636B4275666665723A322C746F7563684275666665723A32352C626F7853656C6563743A21302C646973706C6179436F6E74726F6C7344656661756C743A21302C7374796C65733A4F652C6D6F6465733A';
wwv_flow_imp.g_varchar2_table(567) := '72742C636F6E74726F6C733A7B7D2C7573657250726F706572746965733A21312C73757070726573734150494576656E74733A21307D2C73743D7B706F696E743A21302C6C696E655F737472696E673A21302C706F6C79676F6E3A21302C74726173683A';
wwv_flow_imp.g_varchar2_table(568) := '21302C636F6D62696E655F66656174757265733A21302C756E636F6D62696E655F66656174757265733A21307D2C61743D7B706F696E743A21312C6C696E655F737472696E673A21312C706F6C79676F6E3A21312C74726173683A21312C636F6D62696E';
wwv_flow_imp.g_varchar2_table(569) := '655F66656174757265733A21312C756E636F6D62696E655F66656174757265733A21317D3B66756E6374696F6E20637428652C6F297B72657475726E20652E6D61702828653D3E652E736F757263653F653A4F626A6563742E61737369676E287B7D2C65';
wwv_flow_imp.g_varchar2_table(570) := '2C7B69643A60247B652E69647D2E247B6F7D602C736F757263653A22686F74223D3D3D6F3F742E484F543A742E434F4C447D2929297D7661722075742C6C742C64742C70742C68743D78286C743F75743A286C743D312C75743D66756E6374696F6E2065';
wwv_flow_imp.g_varchar2_table(571) := '28742C6F297B696628743D3D3D6F2972657475726E21303B6966287426266F2626226F626A656374223D3D747970656F6620742626226F626A656374223D3D747970656F66206F297B696628742E636F6E7374727563746F72213D3D6F2E636F6E737472';
wwv_flow_imp.g_varchar2_table(572) := '7563746F722972657475726E21313B766172206E2C722C693B69662841727261792E69734172726179287429297B696628286E3D742E6C656E67746829213D6F2E6C656E6774682972657475726E21313B666F7228723D6E3B30213D722D2D3B29696628';
wwv_flow_imp.g_varchar2_table(573) := '216528745B725D2C6F5B725D292972657475726E21313B72657475726E21307D696628742E636F6E7374727563746F723D3D3D5265674578702972657475726E20742E736F757263653D3D3D6F2E736F757263652626742E666C6167733D3D3D6F2E666C';
wwv_flow_imp.g_varchar2_table(574) := '6167733B696628742E76616C75654F66213D3D4F626A6563742E70726F746F747970652E76616C75654F662972657475726E20742E76616C75654F6628293D3D3D6F2E76616C75654F6628293B696628742E746F537472696E67213D3D4F626A6563742E';
wwv_flow_imp.g_varchar2_table(575) := '70726F746F747970652E746F537472696E672972657475726E20742E746F537472696E6728293D3D3D6F2E746F537472696E6728293B696628286E3D28693D4F626A6563742E6B657973287429292E6C656E67746829213D3D4F626A6563742E6B657973';
wwv_flow_imp.g_varchar2_table(576) := '286F292E6C656E6774682972657475726E21313B666F7228723D6E3B30213D722D2D3B29696628214F626A6563742E70726F746F747970652E6861734F776E50726F70657274792E63616C6C286F2C695B725D292972657475726E21313B666F7228723D';
wwv_flow_imp.g_varchar2_table(577) := '6E3B30213D722D2D3B297B76617220733D695B725D3B696628216528745B735D2C6F5B735D292972657475726E21317D72657475726E21307D72657475726E2074213D7426266F213D6F7D29292C66743D66756E6374696F6E28297B6966287074297265';
wwv_flow_imp.g_varchar2_table(578) := '7475726E2064743B70743D312C64743D66756E6374696F6E2874297B69662821747C7C21742E747970652972657475726E206E756C6C3B766172206F3D655B742E747970655D3B72657475726E206F3F2267656F6D65747279223D3D3D6F3F7B74797065';
wwv_flow_imp.g_varchar2_table(579) := '3A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B7B747970653A2246656174757265222C70726F706572746965733A7B7D2C67656F6D657472793A747D5D7D3A2266656174757265223D3D3D6F3F7B747970653A2246656174';
wwv_flow_imp.g_varchar2_table(580) := '757265436F6C6C656374696F6E222C66656174757265733A5B745D7D3A2266656174757265636F6C6C656374696F6E223D3D3D6F3F743A766F696420303A6E756C6C7D3B76617220653D7B506F696E743A2267656F6D65747279222C4D756C7469506F69';
wwv_flow_imp.g_varchar2_table(581) := '6E743A2267656F6D65747279222C4C696E65537472696E673A2267656F6D65747279222C4D756C74694C696E65537472696E673A2267656F6D65747279222C506F6C79676F6E3A2267656F6D65747279222C4D756C7469506F6C79676F6E3A2267656F6D';
wwv_flow_imp.g_varchar2_table(582) := '65747279222C47656F6D65747279436F6C6C656374696F6E3A2267656F6D65747279222C466561747572653A2266656174757265222C46656174757265436F6C6C656374696F6E3A2266656174757265636F6C6C656374696F6E227D3B72657475726E20';
wwv_flow_imp.g_varchar2_table(583) := '64747D28292C67743D78286674293B66756E6374696F6E20797428652C74297B72657475726E20652E6C656E6774683D3D3D742E6C656E67746826264A534F4E2E737472696E6769667928652E6D61702828653D3E6529292E736F72742829293D3D3D4A';
wwv_flow_imp.g_varchar2_table(584) := '534F4E2E737472696E6769667928742E6D61702828653D3E6529292E736F72742829297D636F6E7374206D743D7B506F6C79676F6E3A63652C4C696E65537472696E673A61652C506F696E743A73652C4D756C7469506F6C79676F6E3A64652C4D756C74';
wwv_flow_imp.g_varchar2_table(585) := '694C696E65537472696E673A64652C4D756C7469506F696E743A64657D3B7661722045743D4F626A6563742E667265657A65287B5F5F70726F746F5F5F3A6E756C6C2C436F6D6D6F6E53656C6563746F72733A502C4D6F646548616E646C65723A6F652C';
wwv_flow_imp.g_varchar2_table(586) := '537472696E675365743A4A2C636F6E73747261696E466561747572654D6F76656D656E743A71652C6372656174654D6964506F696E743A56652C637265617465537570706C656D656E74617279506F696E74733A47652C6372656174655665727465783A';
wwv_flow_imp.g_varchar2_table(587) := '4E652C646F75626C65436C69636B5A6F6F6D3A42652C6575636C696465616E44697374616E63653A712C666561747572657341743A592C676574466561747572654174416E64536574437572736F72733A582C6973436C69636B3A7A2C69734576656E74';
wwv_flow_imp.g_varchar2_table(588) := '4174436F6F7264696E617465733A74742C69735461703A74652C6D61704576656E74546F426F756E64696E67426F783A6A2C6D6F766546656174757265733A4B652C736F727446656174757265733A422C737472696E6753657473417265457175616C3A';
wwv_flow_imp.g_varchar2_table(589) := '79742C7468656D653A4F652C746F44656E736541727261793A79657D293B636F6E73742043743D66756E6374696F6E28652C74297B636F6E7374206F3D7B6F7074696F6E733A653D66756E6374696F6E28653D7B7D297B6C657420743D4F626A6563742E';
wwv_flow_imp.g_varchar2_table(590) := '61737369676E287B7D2C65293B72657475726E20652E636F6E74726F6C737C7C28742E636F6E74726F6C733D7B7D292C21313D3D3D652E646973706C6179436F6E74726F6C7344656661756C743F742E636F6E74726F6C733D4F626A6563742E61737369';
wwv_flow_imp.g_varchar2_table(591) := '676E287B7D2C61742C652E636F6E74726F6C73293A742E636F6E74726F6C733D4F626A6563742E61737369676E287B7D2C73742C652E636F6E74726F6C73292C743D4F626A6563742E61737369676E287B7D2C69742C74292C742E7374796C65733D6374';
wwv_flow_imp.g_varchar2_table(592) := '28742E7374796C65732C22636F6C6422292E636F6E63617428637428742E7374796C65732C22686F742229292C747D2865297D3B743D66756E6374696F6E28652C74297B742E6D6F6465733D693B636F6E7374206F3D766F696420303D3D3D652E6F7074';
wwv_flow_imp.g_varchar2_table(593) := '696F6E732E73757070726573734150494576656E74737C7C2121652E6F7074696F6E732E73757070726573734150494576656E74733B72657475726E20742E6765744665617475726549647341743D66756E6374696F6E2874297B72657475726E20592E';
wwv_flow_imp.g_varchar2_table(594) := '636C69636B287B706F696E743A747D2C6E756C6C2C65292E6D61702828653D3E652E70726F706572746965732E696429297D2C742E67657453656C65637465644964733D66756E6374696F6E28297B72657475726E20652E73746F72652E67657453656C';
wwv_flow_imp.g_varchar2_table(595) := '656374656449647328297D2C742E67657453656C65637465643D66756E6374696F6E28297B72657475726E7B747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A652E73746F72652E67657453656C65637465644964';
wwv_flow_imp.g_varchar2_table(596) := '7328292E6D61702828743D3E652E73746F72652E67657428742929292E6D61702828653D3E652E746F47656F4A534F4E282929297D7D2C742E67657453656C6563746564506F696E74733D66756E6374696F6E28297B72657475726E7B747970653A722E';
wwv_flow_imp.g_varchar2_table(597) := '464541545552455F434F4C4C454354494F4E2C66656174757265733A652E73746F72652E67657453656C6563746564436F6F7264696E6174657328292E6D61702828653D3E287B747970653A722E464541545552452C70726F706572746965733A7B7D2C';
wwv_flow_imp.g_varchar2_table(598) := '67656F6D657472793A7B747970653A722E504F494E542C636F6F7264696E617465733A652E636F6F7264696E617465737D7D2929297D7D2C742E7365743D66756E6374696F6E286F297B696628766F696420303D3D3D6F2E747970657C7C6F2E74797065';
wwv_flow_imp.g_varchar2_table(599) := '213D3D722E464541545552455F434F4C4C454354494F4E7C7C2141727261792E69734172726179286F2E666561747572657329297468726F77206E6577204572726F722822496E76616C69642046656174757265436F6C6C656374696F6E22293B636F6E';
wwv_flow_imp.g_varchar2_table(600) := '7374206E3D652E73746F72652E63726561746552656E646572426174636828293B6C657420693D652E73746F72652E676574416C6C49647328292E736C69636528293B636F6E737420733D742E616464286F292C613D6E6577204A2873293B7265747572';
wwv_flow_imp.g_varchar2_table(601) := '6E20693D692E66696C7465722828653D3E21612E68617328652929292C692E6C656E6774682626742E64656C6574652869292C6E28292C737D2C742E6164643D66756E6374696F6E2874297B636F6E7374206E3D4A534F4E2E7061727365284A534F4E2E';
wwv_flow_imp.g_varchar2_table(602) := '737472696E6769667928677428742929292E66656174757265732E6D61702828743D3E7B696628742E69643D742E69647C7C726528292C6E756C6C3D3D3D742E67656F6D65747279297468726F77206E6577204572726F722822496E76616C6964206765';
wwv_flow_imp.g_varchar2_table(603) := '6F6D657472793A206E756C6C22293B696628766F696420303D3D3D652E73746F72652E67657428742E6964297C7C652E73746F72652E67657428742E6964292E74797065213D3D742E67656F6D657472792E74797065297B636F6E7374206E3D6D745B74';
wwv_flow_imp.g_varchar2_table(604) := '2E67656F6D657472792E747970655D3B696628766F696420303D3D3D6E297468726F77206E6577204572726F722860496E76616C69642067656F6D6574727920747970653A20247B742E67656F6D657472792E747970657D2E60293B636F6E737420723D';
wwv_flow_imp.g_varchar2_table(605) := '6E6577206E28652C74293B652E73746F72652E61646428722C7B73696C656E743A6F7D297D656C73657B636F6E7374206E3D652E73746F72652E67657428742E6964292C723D6E2E70726F706572746965733B6E2E70726F706572746965733D742E7072';
wwv_flow_imp.g_varchar2_table(606) := '6F706572746965732C687428722C742E70726F70657274696573297C7C652E73746F72652E666561747572654368616E676564286E2E69642C7B73696C656E743A6F7D292C6874286E2E676574436F6F7264696E6174657328292C742E67656F6D657472';
wwv_flow_imp.g_varchar2_table(607) := '792E636F6F7264696E61746573297C7C6E2E696E636F6D696E67436F6F72647328742E67656F6D657472792E636F6F7264696E61746573297D72657475726E20742E69647D29293B72657475726E20652E73746F72652E72656E64657228292C6E7D2C74';
wwv_flow_imp.g_varchar2_table(608) := '2E6765743D66756E6374696F6E2874297B636F6E7374206F3D652E73746F72652E6765742874293B6966286F2972657475726E206F2E746F47656F4A534F4E28297D2C742E676574416C6C3D66756E6374696F6E28297B72657475726E7B747970653A72';
wwv_flow_imp.g_varchar2_table(609) := '2E464541545552455F434F4C4C454354494F4E2C66656174757265733A652E73746F72652E676574416C6C28292E6D61702828653D3E652E746F47656F4A534F4E282929297D7D2C742E64656C6574653D66756E6374696F6E286E297B72657475726E20';
wwv_flow_imp.g_varchar2_table(610) := '652E73746F72652E64656C657465286E2C7B73696C656E743A6F7D292C742E6765744D6F64652829213D3D692E4449524543545F53454C4543547C7C652E73746F72652E67657453656C656374656449647328292E6C656E6774683F652E73746F72652E';
wwv_flow_imp.g_varchar2_table(611) := '72656E64657228293A652E6576656E74732E6368616E67654D6F646528692E53494D504C455F53454C4543542C766F696420302C7B73696C656E743A6F7D292C747D2C742E64656C657465416C6C3D66756E6374696F6E28297B72657475726E20652E73';
wwv_flow_imp.g_varchar2_table(612) := '746F72652E64656C65746528652E73746F72652E676574416C6C49647328292C7B73696C656E743A6F7D292C742E6765744D6F646528293D3D3D692E4449524543545F53454C4543543F652E6576656E74732E6368616E67654D6F646528692E53494D50';
wwv_flow_imp.g_varchar2_table(613) := '4C455F53454C4543542C766F696420302C7B73696C656E743A6F7D293A652E73746F72652E72656E64657228292C747D2C742E6368616E67654D6F64653D66756E6374696F6E286E2C723D7B7D297B72657475726E206E3D3D3D692E53494D504C455F53';
wwv_flow_imp.g_varchar2_table(614) := '454C4543542626742E6765744D6F646528293D3D3D692E53494D504C455F53454C4543543F28797428722E666561747572654964737C7C5B5D2C652E73746F72652E67657453656C65637465644964732829297C7C28652E73746F72652E73657453656C';
wwv_flow_imp.g_varchar2_table(615) := '656374656428722E666561747572654964732C7B73696C656E743A6F7D292C652E73746F72652E72656E6465722829292C74293A286E3D3D3D692E4449524543545F53454C4543542626742E6765744D6F646528293D3D3D692E4449524543545F53454C';
wwv_flow_imp.g_varchar2_table(616) := '4543542626722E6665617475726549643D3D3D652E73746F72652E67657453656C656374656449647328295B305D7C7C652E6576656E74732E6368616E67654D6F6465286E2C722C7B73696C656E743A6F7D292C74297D2C742E6765744D6F64653D6675';
wwv_flow_imp.g_varchar2_table(617) := '6E6374696F6E28297B72657475726E20652E6576656E74732E6765744D6F646528297D2C742E74726173683D66756E6374696F6E28297B72657475726E20652E6576656E74732E7472617368287B73696C656E743A6F7D292C747D2C742E636F6D62696E';
wwv_flow_imp.g_varchar2_table(618) := '6546656174757265733D66756E6374696F6E28297B72657475726E20652E6576656E74732E636F6D62696E654665617475726573287B73696C656E743A6F7D292C747D2C742E756E636F6D62696E6546656174757265733D66756E6374696F6E28297B72';
wwv_flow_imp.g_varchar2_table(619) := '657475726E20652E6576656E74732E756E636F6D62696E654665617475726573287B73696C656E743A6F7D292C747D2C742E7365744665617475726550726F70657274793D66756E6374696F6E286E2C722C69297B72657475726E20652E73746F72652E';
wwv_flow_imp.g_varchar2_table(620) := '7365744665617475726550726F7065727479286E2C722C692C7B73696C656E743A6F7D292C747D2C747D286F2C74292C6F2E6170693D743B636F6E737420733D5F65286F293B72657475726E20742E6F6E4164643D732E6F6E4164642C742E6F6E52656D';
wwv_flow_imp.g_varchar2_table(621) := '6F76653D732E6F6E52656D6F76652C742E74797065733D6E2C742E6F7074696F6E733D652C747D3B66756E6374696F6E2054742865297B437428652C74686973297D72657475726E2054742E6D6F6465733D72742C54742E636F6E7374616E74733D682C';
wwv_flow_imp.g_varchar2_table(622) := '54742E6C69623D45742C54747D2C226F626A656374223D3D747970656F66206578706F727473262622756E646566696E656422213D747970656F66206D6F64756C653F6D6F64756C652E6578706F7274733D7428293A2266756E6374696F6E223D3D7479';
wwv_flow_imp.g_varchar2_table(623) := '70656F6620646566696E652626646566696E652E616D643F646566696E652874293A28653D22756E646566696E656422213D747970656F6620676C6F62616C546869733F676C6F62616C546869733A657C7C73656C66292E4D6170626F78447261773D74';
wwv_flow_imp.g_varchar2_table(624) := '28293B0A2F2F2320736F757263654D617070696E6755524C3D6D6170626F782D676C2D647261772E6A732E6D61700A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43388906793713256)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbox-gl-draw.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D6170626F782D676C2D647261775F6374726C2D626F74746F6D2D6C6566742C0A2E6D6170626F782D676C2D647261775F6374726C2D746F702D6C656674207B6D617267696E2D6C6566743A303B626F726465722D7261646975733A30203470782034';
wwv_flow_imp.g_varchar2_table(2) := '707820303B7D2E6D6170626F782D676C2D647261775F6374726C2D746F702D72696768742C0A2E6D6170626F782D676C2D647261775F6374726C2D626F74746F6D2D7269676874207B6D617267696E2D72696768743A303B626F726465722D7261646975';
wwv_flow_imp.g_varchar2_table(3) := '733A34707820302030203470783B7D2E6D6170626F782D676C2D647261775F6374726C2D647261772D62746E207B626F726465722D636F6C6F723A7267626128302C302C302C302E39293B636F6C6F723A72676261283235352C3235352C3235352C302E';
wwv_flow_imp.g_varchar2_table(4) := '35293B77696474683A333070783B6865696768743A333070783B7D2E6D6170626F782D676C2D647261775F6374726C2D647261772D62746E2E6163746976652C0A2E6D6170626F782D676C2D647261775F6374726C2D647261772D62746E2E6163746976';
wwv_flow_imp.g_varchar2_table(5) := '653A686F766572207B6261636B67726F756E642D636F6C6F723A7267622830203020302F3525293B7D2E6D6170626F782D676C2D647261775F6374726C2D647261772D62746E207B6261636B67726F756E642D7265706561743A206E6F2D726570656174';
wwv_flow_imp.g_varchar2_table(6) := '3B6261636B67726F756E642D706F736974696F6E3A2063656E7465723B7D2E6D6170626F782D676C2D647261775F706F696E74207B6261636B67726F756E642D696D6167653A2075726C2827646174613A696D6167652F7376672B786D6C3B757466382C';
wwv_flow_imp.g_varchar2_table(7) := '25334373766720786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D226D31302032632D332E3320302D3620322E372D3620367336';
wwv_flow_imp.g_varchar2_table(8) := '20392036203920362D352E3720362D392D322E372D362D362D367A6D30203263322E31203020332E3820312E3720332E3820332E38203020312E352D312E3820332E392D322E3920352E32682D312E37632D312E312D312E342D322E392D332E382D322E';
wwv_flow_imp.g_varchar2_table(9) := '392D352E322D2E312D322E3120312E362D332E3820332E372D332E387A222F3E2533432F7376673E27293B7D2E6D6170626F782D676C2D647261775F706F6C79676F6E207B6261636B67726F756E642D696D6167653A2075726C2827646174613A696D61';
wwv_flow_imp.g_varchar2_table(10) := '67652F7376672B786D6C3B757466382C25334373766720786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D226D31352031322E33';
wwv_flow_imp.g_varchar2_table(11) := '762D342E36632E362D2E3320312D3120312D312E3720302D312E312D2E392D322D322D322D2E3720302D312E342E342D312E372031682D342E36632D2E332D2E362D312D312D312E372D312D312E3120302D32202E392D3220322030202E372E3420312E';
wwv_flow_imp.g_varchar2_table(12) := '34203120312E3776342E36632D2E362E332D3120312D3120312E37203020312E312E39203220322032202E37203020312E342D2E3420312E372D3168342E36632E332E362031203120312E37203120312E31203020322D2E3920322D3220302D2E372D2E';
wwv_flow_imp.g_varchar2_table(13) := '342D312E342D312D312E377A6D2D382D2E33762D346C312D3168346C31203176346C2D312031682D347A222F3E2533432F7376673E27293B7D2E6D6170626F782D676C2D647261775F6C696E65207B6261636B67726F756E642D696D6167653A2075726C';
wwv_flow_imp.g_varchar2_table(14) := '2827646174613A696D6167652F7376672B786D6C3B757466382C25334373766720786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E253343706174682064';
wwv_flow_imp.g_varchar2_table(15) := '3D226D31332E3520332E35632D312E3420302D322E3520312E312D322E3520322E352030202E332030202E362E322E396C2D332E3820332E38632D2E332D2E312D2E362D2E322D2E392D2E322D312E3420302D322E3520312E312D322E3520322E357331';
wwv_flow_imp.g_varchar2_table(16) := '2E3120322E3520322E3520322E3520322E352D312E3120322E352D322E3563302D2E3320302D2E362D2E322D2E396C332E382D332E38632E332E312E362E322E392E3220312E34203020322E352D312E3120322E352D322E35732D312E312D322E352D32';
wwv_flow_imp.g_varchar2_table(17) := '2E352D322E357A222F3E2533432F7376673E27293B7D2E6D6170626F782D676C2D647261775F7472617368207B6261636B67726F756E642D696D6167653A2075726C2827646174613A696D6167652F7376672B786D6C3B757466382C2533437376672078';
wwv_flow_imp.g_varchar2_table(18) := '6D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D224D31302C332E3420632D302E382C302D312E352C302E352D312E382C312E3248';
wwv_flow_imp.g_varchar2_table(19) := '356C2D312C317631683132762D316C2D312D31682D332E324331312E352C332E392C31302E382C332E342C31302C332E347A204D352C38763763302C312C312C322C322C32683663312C302C322D312C322D325638682D3276352E35682D312E35563868';
wwv_flow_imp.g_varchar2_table(20) := '2D332076352E354837563848357A222F3E2533432F7376673E27293B7D2E6D6170626F782D676C2D647261775F756E636F6D62696E65207B6261636B67726F756E642D696D6167653A2075726C2827646174613A696D6167652F7376672B786D6C3B7574';
wwv_flow_imp.g_varchar2_table(21) := '66382C25334373766720786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D226D31322032632D2E3320302D2E352E312D2E372E33';
wwv_flow_imp.g_varchar2_table(22) := '6C2D312031632D2E342E342D2E342031203020312E346C312031632E342E342031202E3420312E3420306C312D31632E342D2E342E342D3120302D312E346C2D312D31632D2E322D2E322D2E342D2E332D2E372D2E337A6D342034632D2E3320302D2E35';
wwv_flow_imp.g_varchar2_table(23) := '2E312D2E372E336C2D312031632D2E342E342D2E342031203020312E346C312031632E342E342031202E3420312E3420306C312D31632E342D2E342E342D3120302D312E346C2D312D31632D2E322D2E322D2E342D2E332D2E372D2E337A6D2D37203163';
wwv_flow_imp.g_varchar2_table(24) := '2D3120302D3120312D2E3520312E352E332E3320312031203120316C2D312031732D2E352E352030203120312030203120306C312D3120312031632E352E3520312E352E3520312E352D2E35762D347A6D2D352033632D2E3320302D2E352E312D2E372E';
wwv_flow_imp.g_varchar2_table(25) := '336C2D312031632D2E342E342D2E342031203020312E346C342E3920342E39632E342E342031202E3420312E3420306C312D31632E342D2E342E342D3120302D312E346C2D342E392D342E39632D2E312D2E322D2E342D2E332D2E372D2E337A222F3E25';
wwv_flow_imp.g_varchar2_table(26) := '33432F7376673E27293B7D2E6D6170626F782D676C2D647261775F636F6D62696E65207B6261636B67726F756E642D696D6167653A2075726C2827646174613A696D6167652F7376672B786D6C3B757466382C25334373766720786D6C6E733D22687474';
wwv_flow_imp.g_varchar2_table(27) := '703A2F2F7777772E77332E6F72672F323030302F737667222077696474683D22323022206865696768743D223230223E2533437061746820643D224D31322E312C32632D302E332C302D302E352C302E312D302E372C302E336C2D312C31632D302E342C';
wwv_flow_imp.g_varchar2_table(28) := '302E342D302E342C312C302C312E346C342E392C342E3963302E342C302E342C312C302E342C312E342C306C312D312063302E342D302E342C302E342D312C302D312E346C2D342E392D342E394331322E362C322E312C31322E332C322C31322E312C32';
wwv_flow_imp.g_varchar2_table(29) := '7A204D382C3843372C382C372C392C372E352C392E3563302E332C302E332C312C312C312C316C2D312C3163302C302D302E352C302E352C302C3173312C302C312C306C312D316C312C31204331312C31332C31322C31332C31322C3132563848387A20';
wwv_flow_imp.g_varchar2_table(30) := '4D342C3130632D302E332C302D302E352C302E312D302E372C302E336C2D312C31632D302E342C302E342D302E342C312C302C312E346C312C3163302E342C302E342C312C302E342C312E342C306C312D3163302E342D302E342C302E342D312C302D31';
wwv_flow_imp.g_varchar2_table(31) := '2E34206C2D312D3143342E352C31302E312C342E332C31302C342C31307A204D382C3134632D302E332C302D302E352C302E312D302E372C302E336C2D312C31632D302E342C302E342D302E342C312C302C312E346C312C3163302E342C302E342C312C';
wwv_flow_imp.g_varchar2_table(32) := '302E342C312E342C306C312D312063302E342D302E342C302E342D312C302D312E346C2D312D3143382E352C31342E312C382E332C31342C382C31347A222F3E2533432F7376673E27293B7D2E6D6170626F78676C2D6D61702E6D6F7573652D706F696E';
wwv_flow_imp.g_varchar2_table(33) := '746572202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B637572736F723A20706F696E7465723B7D2E6D6170626F78676C2D6D61702E6D6F7573652D6D6F7665202E6D617062';
wwv_flow_imp.g_varchar2_table(34) := '6F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B637572736F723A206D6F76653B7D2E6D6170626F78676C2D6D61702E6D6F7573652D616464202E6D6170626F78676C2D63616E7661732D63';
wwv_flow_imp.g_varchar2_table(35) := '6F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B637572736F723A2063726F7373686169723B7D2E6D6170626F78676C2D6D61702E6D6F7573652D6D6F76652E6D6F64652D6469726563745F73656C656374202E6D6170626F';
wwv_flow_imp.g_varchar2_table(36) := '78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B637572736F723A20677261623B637572736F723A202D6D6F7A2D677261623B637572736F723A202D7765626B69742D677261623B7D2E6D6170';
wwv_flow_imp.g_varchar2_table(37) := '626F78676C2D6D61702E6D6F64652D6469726563745F73656C6563742E666561747572652D7665727465782E6D6F7573652D6D6F7665202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E74657261637469';
wwv_flow_imp.g_varchar2_table(38) := '7665207B637572736F723A206D6F76653B7D2E6D6170626F78676C2D6D61702E6D6F64652D6469726563745F73656C6563742E666561747572652D6D6964706F696E742E6D6F7573652D706F696E746572202E6D6170626F78676C2D63616E7661732D63';
wwv_flow_imp.g_varchar2_table(39) := '6F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B637572736F723A2063656C6C3B7D2E6D6170626F78676C2D6D61702E6D6F64652D6469726563745F73656C6563742E666561747572652D666561747572652E6D6F7573652D';
wwv_flow_imp.g_varchar2_table(40) := '6D6F7665202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B637572736F723A206D6F76653B7D2E6D6170626F78676C2D6D61702E6D6F64652D7374617469632E6D6F7573652D';
wwv_flow_imp.g_varchar2_table(41) := '706F696E74657220202E6D6170626F78676C2D63616E7661732D636F6E7461696E65722E6D6170626F78676C2D696E746572616374697665207B637572736F723A20677261623B637572736F723A202D6D6F7A2D677261623B637572736F723A202D7765';
wwv_flow_imp.g_varchar2_table(42) := '626B69742D677261623B7D2E6D6170626F782D676C2D647261775F626F7873656C656374207B706F696E7465722D6576656E74733A206E6F6E653B706F736974696F6E3A206162736F6C7574653B746F703A20303B6C6566743A20303B77696474683A20';
wwv_flow_imp.g_varchar2_table(43) := '303B6865696768743A20303B6261636B67726F756E643A207267626128302C302C302C2E31293B626F726465723A2032707820646F7474656420236666663B6F7061636974793A20302E353B7D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43389369485713256)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbox-gl-draw.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '76617220652C743B653D746869732C743D66756E6374696F6E28297B636F6E737420653D7B43414E5641533A226D6170626F78676C2D63616E766173222C434F4E54524F4C5F424153453A226D6170626F78676C2D6374726C222C434F4E54524F4C5F50';
wwv_flow_imp.g_varchar2_table(2) := '52454649583A226D6170626F78676C2D6374726C2D222C434F4E54524F4C5F425554544F4E3A226D6170626F782D676C2D647261775F6374726C2D647261772D62746E222C434F4E54524F4C5F425554544F4E5F4C494E453A226D6170626F782D676C2D';
wwv_flow_imp.g_varchar2_table(3) := '647261775F6C696E65222C434F4E54524F4C5F425554544F4E5F504F4C59474F4E3A226D6170626F782D676C2D647261775F706F6C79676F6E222C434F4E54524F4C5F425554544F4E5F504F494E543A226D6170626F782D676C2D647261775F706F696E';
wwv_flow_imp.g_varchar2_table(4) := '74222C434F4E54524F4C5F425554544F4E5F54524153483A226D6170626F782D676C2D647261775F7472617368222C434F4E54524F4C5F425554544F4E5F434F4D42494E455F46454154555245533A226D6170626F782D676C2D647261775F636F6D6269';
wwv_flow_imp.g_varchar2_table(5) := '6E65222C434F4E54524F4C5F425554544F4E5F554E434F4D42494E455F46454154555245533A226D6170626F782D676C2D647261775F756E636F6D62696E65222C434F4E54524F4C5F47524F55503A226D6170626F78676C2D6374726C2D67726F757022';
wwv_flow_imp.g_varchar2_table(6) := '2C4154545249425554494F4E3A226D6170626F78676C2D6374726C2D617474726962222C4143544956455F425554544F4E3A22616374697665222C424F585F53454C4543543A226D6170626F782D676C2D647261775F626F7873656C656374227D2C743D';
wwv_flow_imp.g_varchar2_table(7) := '7B484F543A226D6170626F782D676C2D647261772D686F74222C434F4C443A226D6170626F782D676C2D647261772D636F6C64227D2C6F3D7B4144443A22616464222C4D4F56453A226D6F7665222C445241473A2264726167222C504F494E5445523A22';
wwv_flow_imp.g_varchar2_table(8) := '706F696E746572222C4E4F4E453A226E6F6E65227D2C6E3D7B504F4C59474F4E3A22706F6C79676F6E222C4C494E453A226C696E655F737472696E67222C504F494E543A22706F696E74227D2C723D7B464541545552453A2246656174757265222C504F';
wwv_flow_imp.g_varchar2_table(9) := '4C59474F4E3A22506F6C79676F6E222C4C494E455F535452494E473A224C696E65537472696E67222C504F494E543A22506F696E74222C464541545552455F434F4C4C454354494F4E3A2246656174757265436F6C6C656374696F6E222C4D554C54495F';
wwv_flow_imp.g_varchar2_table(10) := '5052454649583A224D756C7469222C4D554C54495F504F494E543A224D756C7469506F696E74222C4D554C54495F4C494E455F535452494E473A224D756C74694C696E65537472696E67222C4D554C54495F504F4C59474F4E3A224D756C7469506F6C79';
wwv_flow_imp.g_varchar2_table(11) := '676F6E227D2C693D7B445241575F4C494E455F535452494E473A22647261775F6C696E655F737472696E67222C445241575F504F4C59474F4E3A22647261775F706F6C79676F6E222C445241575F504F494E543A22647261775F706F696E74222C53494D';
wwv_flow_imp.g_varchar2_table(12) := '504C455F53454C4543543A2273696D706C655F73656C656374222C4449524543545F53454C4543543A226469726563745F73656C656374227D2C733D7B4352454154453A22647261772E637265617465222C44454C4554453A22647261772E64656C6574';
wwv_flow_imp.g_varchar2_table(13) := '65222C5550444154453A22647261772E757064617465222C53454C454354494F4E5F4348414E47453A22647261772E73656C656374696F6E6368616E6765222C4D4F44455F4348414E47453A22647261772E6D6F64656368616E6765222C414354494F4E';
wwv_flow_imp.g_varchar2_table(14) := '41424C453A22647261772E616374696F6E61626C65222C52454E4445523A22647261772E72656E646572222C434F4D42494E455F46454154555245533A22647261772E636F6D62696E65222C554E434F4D42494E455F46454154555245533A2264726177';
wwv_flow_imp.g_varchar2_table(15) := '2E756E636F6D62696E65227D2C613D7B4D4F56453A226D6F7665222C4348414E47455F50524F504552544945533A226368616E67655F70726F70657274696573222C4348414E47455F434F4F5244494E415445533A226368616E67655F636F6F7264696E';
wwv_flow_imp.g_varchar2_table(16) := '61746573227D2C633D7B464541545552453A2266656174757265222C4D4944504F494E543A226D6964706F696E74222C5645525445583A22766572746578227D2C753D7B4143544956453A2274727565222C494E4143544956453A2266616C7365227D2C';
wwv_flow_imp.g_varchar2_table(17) := '6C3D5B227363726F6C6C5A6F6F6D222C22626F785A6F6F6D222C2264726167526F74617465222C226472616750616E222C226B6579626F617264222C22646F75626C65436C69636B5A6F6F6D222C22746F7563685A6F6F6D526F74617465225D2C643D2D';
wwv_flow_imp.g_varchar2_table(18) := '38352C703D38353B76617220683D4F626A6563742E667265657A65287B5F5F70726F746F5F5F3A6E756C6C2C4C41545F4D41583A39302C4C41545F4D494E3A2D39302C4C41545F52454E44455245445F4D41583A702C4C41545F52454E44455245445F4D';
wwv_flow_imp.g_varchar2_table(19) := '494E3A642C4C4E475F4D41583A3237302C4C4E475F4D494E3A2D3237302C6163746976655374617465733A752C636C61737365733A652C637572736F72733A6F2C6576656E74733A732C67656F6A736F6E54797065733A722C696E746572616374696F6E';
wwv_flow_imp.g_varchar2_table(20) := '733A6C2C6D6574613A632C6D6F6465733A692C736F75726365733A742C74797065733A6E2C757064617465416374696F6E733A617D293B66756E6374696F6E20662865297B72657475726E2066756E6374696F6E2874297B636F6E7374206F3D742E6665';
wwv_flow_imp.g_varchar2_table(21) := '61747572655461726765743B72657475726E21216F262621216F2E70726F7065727469657326266F2E70726F706572746965732E6D6574613D3D3D657D7D66756E6374696F6E20672865297B72657475726E2121652E6F726967696E616C4576656E7426';
wwv_flow_imp.g_varchar2_table(22) := '262121652E6F726967696E616C4576656E742E73686966744B65792626303D3D3D652E6F726967696E616C4576656E742E627574746F6E7D66756E6374696F6E20792865297B72657475726E2121652E6665617475726554617267657426262121652E66';
wwv_flow_imp.g_varchar2_table(23) := '6561747572655461726765742E70726F706572746965732626652E666561747572655461726765742E70726F706572746965732E6163746976653D3D3D752E4143544956452626652E666561747572655461726765742E70726F706572746965732E6D65';
wwv_flow_imp.g_varchar2_table(24) := '74613D3D3D632E464541545552457D66756E6374696F6E206D2865297B72657475726E2121652E6665617475726554617267657426262121652E666561747572655461726765742E70726F706572746965732626652E666561747572655461726765742E';
wwv_flow_imp.g_varchar2_table(25) := '70726F706572746965732E6163746976653D3D3D752E494E4143544956452626652E666561747572655461726765742E70726F706572746965732E6D6574613D3D3D632E464541545552457D66756E6374696F6E20452865297B72657475726E20766F69';
wwv_flow_imp.g_varchar2_table(26) := '6420303D3D3D652E666561747572655461726765747D66756E6374696F6E20432865297B72657475726E2121652E6665617475726554617267657426262121652E666561747572655461726765742E70726F706572746965732626652E66656174757265';
wwv_flow_imp.g_varchar2_table(27) := '5461726765742E70726F706572746965732E6D6574613D3D3D632E464541545552457D66756E6374696F6E20542865297B636F6E737420743D652E666561747572655461726765743B72657475726E21217426262121742E70726F706572746965732626';
wwv_flow_imp.g_varchar2_table(28) := '742E70726F706572746965732E6D6574613D3D3D632E5645525445587D66756E6374696F6E205F2865297B72657475726E2121652E6F726967696E616C4576656E74262621303D3D3D652E6F726967696E616C4576656E742E73686966744B65797D6675';
wwv_flow_imp.g_varchar2_table(29) := '6E6374696F6E20762865297B72657475726E22457363617065223D3D3D652E6B65797C7C32373D3D3D652E6B6579436F64657D66756E6374696F6E20492865297B72657475726E22456E746572223D3D3D652E6B65797C7C31333D3D3D652E6B6579436F';
wwv_flow_imp.g_varchar2_table(30) := '64657D66756E6374696F6E20532865297B72657475726E224261636B7370616365223D3D3D652E6B65797C7C383D3D3D652E6B6579436F64657D66756E6374696F6E204F2865297B72657475726E2244656C657465223D3D3D652E6B65797C7C34363D3D';
wwv_flow_imp.g_varchar2_table(31) := '3D652E6B6579436F64657D66756E6374696F6E204D2865297B72657475726E2231223D3D3D652E6B65797C7C34393D3D3D652E6B6579436F64657D66756E6374696F6E204C2865297B72657475726E2232223D3D3D652E6B65797C7C35303D3D3D652E6B';
wwv_flow_imp.g_varchar2_table(32) := '6579436F64657D66756E6374696F6E204E2865297B72657475726E2233223D3D3D652E6B65797C7C35313D3D3D652E6B6579436F64657D66756E6374696F6E20622865297B636F6E737420743D652E6B65797C7C537472696E672E66726F6D4368617243';
wwv_flow_imp.g_varchar2_table(33) := '6F646528652E6B6579436F6465293B72657475726E20743E3D2230222626743C3D2239227D76617220503D4F626A6563742E667265657A65287B5F5F70726F746F5F5F3A6E756C6C2C6973416374697665466561747572653A792C69734261636B737061';
wwv_flow_imp.g_varchar2_table(34) := '63654B65793A532C697344656C6574654B65793A4F2C69734469676974314B65793A4D2C69734469676974324B65793A4C2C69734469676974334B65793A4E2C697344696769744B65793A622C6973456E7465724B65793A492C69734573636170654B65';
wwv_flow_imp.g_varchar2_table(35) := '793A762C6973466561747572653A432C6973496E616374697665466561747572653A6D2C69734F664D657461547970653A662C69735368696674446F776E3A5F2C697353686966744D6F757365646F776E3A672C6973547275653A66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(36) := '297B72657475726E21307D2C69735665727465783A542C6E6F5461726765743A457D293B66756E6374696F6E20782865297B72657475726E20652626652E5F5F65734D6F64756C6526264F626A6563742E70726F746F747970652E6861734F776E50726F';
wwv_flow_imp.g_varchar2_table(37) := '70657274792E63616C6C28652C2264656661756C7422293F652E64656661756C743A657D76617220412C462C773D7B7D2C523D7B7D3B76617220443D66756E6374696F6E28297B696628462972657475726E20773B463D313B76617220653D28417C7C28';
wwv_flow_imp.g_varchar2_table(38) := '413D312C522E5241444955533D363337383133372C522E464C415454454E494E473D312F3239382E3235373232333536332C522E504F4C41525F5241444955533D363335363735322E33313432292C52293B66756E6374696F6E20742865297B76617220';
wwv_flow_imp.g_varchar2_table(39) := '743D303B696628652626652E6C656E6774683E30297B742B3D4D6174682E616273286F28655B305D29293B666F7228766172206E3D313B6E3C652E6C656E6774683B6E2B2B29742D3D4D6174682E616273286F28655B6E5D29297D72657475726E20747D';
wwv_flow_imp.g_varchar2_table(40) := '66756E6374696F6E206F2874297B766172206F2C722C692C732C612C632C753D302C6C3D742E6C656E6774683B6966286C3E32297B666F7228633D303B633C6C3B632B2B29633D3D3D6C2D323F28693D6C2D322C733D6C2D312C613D30293A633D3D3D6C';
wwv_flow_imp.g_varchar2_table(41) := '2D313F28693D6C2D312C733D302C613D31293A28693D632C733D632B312C613D632B32292C6F3D745B695D2C723D745B735D2C752B3D286E28745B615D5B305D292D6E286F5B305D29292A4D6174682E73696E286E28725B315D29293B753D752A652E52';
wwv_flow_imp.g_varchar2_table(42) := '41444955532A652E5241444955532F327D72657475726E20757D66756E6374696F6E206E2865297B72657475726E20652A4D6174682E50492F3138307D72657475726E20772E67656F6D657472793D66756E6374696F6E2065286F297B766172206E2C72';
wwv_flow_imp.g_varchar2_table(43) := '3D303B737769746368286F2E74797065297B6361736522506F6C79676F6E223A72657475726E2074286F2E636F6F7264696E61746573293B63617365224D756C7469506F6C79676F6E223A666F72286E3D303B6E3C6F2E636F6F7264696E617465732E6C';
wwv_flow_imp.g_varchar2_table(44) := '656E6774683B6E2B2B29722B3D74286F2E636F6F7264696E617465735B6E5D293B72657475726E20723B6361736522506F696E74223A63617365224D756C7469506F696E74223A63617365224C696E65537472696E67223A63617365224D756C74694C69';
wwv_flow_imp.g_varchar2_table(45) := '6E65537472696E67223A72657475726E20303B636173652247656F6D65747279436F6C6C656374696F6E223A666F72286E3D303B6E3C6F2E67656F6D6574726965732E6C656E6774683B6E2B2B29722B3D65286F2E67656F6D6574726965735B6E5D293B';
wwv_flow_imp.g_varchar2_table(46) := '72657475726E20727D7D2C772E72696E673D6F2C777D28292C553D782844293B636F6E7374206B3D7B506F696E743A302C4C696E65537472696E673A312C4D756C74694C696E65537472696E673A312C506F6C79676F6E3A327D3B66756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(47) := '5628652C74297B636F6E7374206F3D6B5B652E67656F6D657472792E747970655D2D6B5B742E67656F6D657472792E747970655D3B72657475726E20303D3D3D6F2626652E67656F6D657472792E747970653D3D3D722E504F4C59474F4E3F652E617265';
wwv_flow_imp.g_varchar2_table(48) := '612D742E617265613A6F7D66756E6374696F6E20472865297B72657475726E20652E6D61702828653D3E28652E67656F6D657472792E747970653D3D3D722E504F4C59474F4E262628652E617265613D552E67656F6D65747279287B747970653A722E46';
wwv_flow_imp.g_varchar2_table(49) := '4541545552452C70726F70657274793A7B7D2C67656F6D657472793A652E67656F6D657472797D29292C652929292E736F72742856292E6D61702828653D3E2864656C65746520652E617265612C652929297D66756E6374696F6E204228652C743D3029';
wwv_flow_imp.g_varchar2_table(50) := '7B72657475726E5B5B652E706F696E742E782D742C652E706F696E742E792D745D2C5B652E706F696E742E782B742C652E706F696E742E792B745D5D7D66756E6374696F6E206A2865297B696628746869732E5F6974656D733D7B7D2C746869732E5F6E';
wwv_flow_imp.g_varchar2_table(51) := '756D733D7B7D2C746869732E5F6C656E6774683D653F652E6C656E6774683A302C6529666F72286C657420743D302C6F3D652E6C656E6774683B743C6F3B742B2B29746869732E61646428655B745D292C766F69642030213D3D655B745D262628227374';
wwv_flow_imp.g_varchar2_table(52) := '72696E67223D3D747970656F6620655B745D3F746869732E5F6974656D735B655B745D5D3D743A746869732E5F6E756D735B655B745D5D3D74297D6A2E70726F746F747970652E6164643D66756E6374696F6E2865297B72657475726E20746869732E68';
wwv_flow_imp.g_varchar2_table(53) := '61732865297C7C28746869732E5F6C656E6774682B2B2C22737472696E67223D3D747970656F6620653F746869732E5F6974656D735B655D3D746869732E5F6C656E6774683A746869732E5F6E756D735B655D3D746869732E5F6C656E677468292C7468';
wwv_flow_imp.g_varchar2_table(54) := '69737D2C6A2E70726F746F747970652E64656C6574653D66756E6374696F6E2865297B72657475726E21313D3D3D746869732E6861732865297C7C28746869732E5F6C656E6774682D2D2C64656C65746520746869732E5F6974656D735B655D2C64656C';
wwv_flow_imp.g_varchar2_table(55) := '65746520746869732E5F6E756D735B655D292C746869737D2C6A2E70726F746F747970652E6861733D66756E6374696F6E2865297B72657475726E212822737472696E6722213D747970656F6620652626226E756D62657222213D747970656F6620657C';
wwv_flow_imp.g_varchar2_table(56) := '7C766F696420303D3D3D746869732E5F6974656D735B655D2626766F696420303D3D3D746869732E5F6E756D735B655D297D2C6A2E70726F746F747970652E76616C7565733D66756E6374696F6E28297B636F6E737420653D5B5D3B72657475726E204F';
wwv_flow_imp.g_varchar2_table(57) := '626A6563742E6B65797328746869732E5F6974656D73292E666F72456163682828743D3E7B652E70757368287B6B3A742C763A746869732E5F6974656D735B745D7D297D29292C4F626A6563742E6B65797328746869732E5F6E756D73292E666F724561';
wwv_flow_imp.g_varchar2_table(58) := '63682828743D3E7B652E70757368287B6B3A4A534F4E2E70617273652874292C763A746869732E5F6E756D735B745D7D297D29292C652E736F7274282828652C74293D3E652E762D742E7629292E6D61702828653D3E652E6B29297D2C6A2E70726F746F';
wwv_flow_imp.g_varchar2_table(59) := '747970652E636C6561723D66756E6374696F6E28297B72657475726E20746869732E5F6C656E6774683D302C746869732E5F6974656D733D7B7D2C746869732E5F6E756D733D7B7D2C746869737D3B636F6E7374204A3D5B632E464541545552452C632E';
wwv_flow_imp.g_varchar2_table(60) := '4D4944504F494E542C632E5645525445585D3B76617220243D7B636C69636B3A66756E6374696F6E28652C742C6F297B72657475726E205928652C742C6F2C6F2E6F7074696F6E732E636C69636B427566666572297D2C746F7563683A66756E6374696F';
wwv_flow_imp.g_varchar2_table(61) := '6E28652C742C6F297B72657475726E205928652C742C6F2C6F2E6F7074696F6E732E746F756368427566666572297D7D3B66756E6374696F6E205928652C742C6F2C6E297B6966286E756C6C3D3D3D6F2E6D61702972657475726E5B5D3B636F6E737420';
wwv_flow_imp.g_varchar2_table(62) := '723D653F4228652C6E293A742C693D7B7D3B6F2E6F7074696F6E732E7374796C6573262628692E6C61796572733D6F2E6F7074696F6E732E7374796C65732E6D61702828653D3E652E696429292E66696C7465722828653D3E6E756C6C213D6F2E6D6170';
wwv_flow_imp.g_varchar2_table(63) := '2E6765744C617965722865292929293B636F6E737420733D6F2E6D61702E717565727952656E6465726564466561747572657328722C69292E66696C7465722828653D3E2D31213D3D4A2E696E6465784F6628652E70726F706572746965732E6D657461';
wwv_flow_imp.g_varchar2_table(64) := '2929292C613D6E6577206A2C633D5B5D3B72657475726E20732E666F72456163682828653D3E7B636F6E737420743D652E70726F706572746965732E69643B612E6861732874297C7C28612E6164642874292C632E70757368286529297D29292C472863';
wwv_flow_imp.g_varchar2_table(65) := '297D66756E6374696F6E204828652C74297B636F6E7374206E3D242E636C69636B28652C6E756C6C2C74292C723D7B6D6F7573653A6F2E4E4F4E457D3B72657475726E206E5B305D262628722E6D6F7573653D6E5B305D2E70726F706572746965732E61';
wwv_flow_imp.g_varchar2_table(66) := '63746976653D3D3D752E4143544956453F6F2E4D4F56453A6F2E504F494E5445522C722E666561747572653D6E5B305D2E70726F706572746965732E6D657461292C2D31213D3D742E6576656E74732E63757272656E744D6F64654E616D6528292E696E';
wwv_flow_imp.g_varchar2_table(67) := '6465784F662822647261772229262628722E6D6F7573653D6F2E414444292C742E75692E71756575654D6170436C61737365732872292C742E75692E7570646174654D6170436C617373657328292C6E5B305D7D66756E6374696F6E205828652C74297B';
wwv_flow_imp.g_varchar2_table(68) := '636F6E7374206F3D652E782D742E782C6E3D652E792D742E793B72657475726E204D6174682E73717274286F2A6F2B6E2A6E297D636F6E737420713D342C4B3D31322C5A3D3530303B66756E6374696F6E205728652C742C6F3D7B7D297B636F6E737420';
wwv_flow_imp.g_varchar2_table(69) := '6E3D6E756C6C213D6F2E66696E65546F6C6572616E63653F6F2E66696E65546F6C6572616E63653A712C723D6E756C6C213D6F2E67726F7373546F6C6572616E63653F6F2E67726F7373546F6C6572616E63653A4B2C693D6E756C6C213D6F2E696E7465';
wwv_flow_imp.g_varchar2_table(70) := '7276616C3F6F2E696E74657276616C3A5A3B652E706F696E743D652E706F696E747C7C742E706F696E742C652E74696D653D652E74696D657C7C742E74696D653B636F6E737420733D5828652E706F696E742C742E706F696E74293B72657475726E2073';
wwv_flow_imp.g_varchar2_table(71) := '3C6E7C7C733C722626742E74696D652D652E74696D653C697D636F6E7374207A3D32352C513D3235303B66756E6374696F6E20656528652C742C6F3D7B7D297B636F6E7374206E3D6E756C6C213D6F2E746F6C6572616E63653F6F2E746F6C6572616E63';
wwv_flow_imp.g_varchar2_table(72) := '653A7A2C723D6E756C6C213D6F2E696E74657276616C3F6F2E696E74657276616C3A513B72657475726E20652E706F696E743D652E706F696E747C7C742E706F696E742C652E74696D653D652E74696D657C7C742E74696D652C5828652E706F696E742C';
wwv_flow_imp.g_varchar2_table(73) := '742E706F696E74293C6E2626742E74696D652D652E74696D653C727D636F6E73742074653D66756E6374696F6E28652C74297B636F6E7374206F3D7B647261673A5B5D2C636C69636B3A5B5D2C6D6F7573656D6F76653A5B5D2C6D6F757365646F776E3A';
wwv_flow_imp.g_varchar2_table(74) := '5B5D2C6D6F75736575703A5B5D2C6D6F7573656F75743A5B5D2C6B6579646F776E3A5B5D2C6B657975703A5B5D2C746F75636873746172743A5B5D2C746F7563686D6F76653A5B5D2C746F756368656E643A5B5D2C7461703A5B5D7D2C6E3D7B6F6E2865';
wwv_flow_imp.g_varchar2_table(75) := '2C742C6E297B696628766F696420303D3D3D6F5B655D297468726F77206E6577204572726F722860496E76616C6964206576656E7420747970653A20247B657D60293B6F5B655D2E70757368287B73656C6563746F723A742C666E3A6E7D297D2C72656E';
wwv_flow_imp.g_varchar2_table(76) := '6465722865297B742E73746F72652E666561747572654368616E6765642865297D7D2C723D66756E6374696F6E28652C72297B636F6E737420693D6F5B655D3B6C657420733D692E6C656E6774683B666F72283B732D2D3B297B636F6E737420653D695B';
wwv_flow_imp.g_varchar2_table(77) := '735D3B696628652E73656C6563746F72287229297B652E666E2E63616C6C286E2C72297C7C742E73746F72652E72656E64657228292C742E75692E7570646174654D6170436C617373657328293B627265616B7D7D7D3B72657475726E20652E73746172';
wwv_flow_imp.g_varchar2_table(78) := '742E63616C6C286E292C7B72656E6465723A652E72656E6465722C73746F7028297B652E73746F702626652E73746F7028297D2C747261736828297B652E7472617368262628652E747261736828292C742E73746F72652E72656E6465722829297D2C63';
wwv_flow_imp.g_varchar2_table(79) := '6F6D62696E65466561747572657328297B652E636F6D62696E6546656174757265732626652E636F6D62696E65466561747572657328297D2C756E636F6D62696E65466561747572657328297B652E756E636F6D62696E6546656174757265732626652E';
wwv_flow_imp.g_varchar2_table(80) := '756E636F6D62696E65466561747572657328297D2C647261672865297B72282264726167222C65297D2C636C69636B2865297B722822636C69636B222C65297D2C6D6F7573656D6F76652865297B7228226D6F7573656D6F7665222C65297D2C6D6F7573';
wwv_flow_imp.g_varchar2_table(81) := '65646F776E2865297B7228226D6F757365646F776E222C65297D2C6D6F75736575702865297B7228226D6F7573657570222C65297D2C6D6F7573656F75742865297B7228226D6F7573656F7574222C65297D2C6B6579646F776E2865297B7228226B6579';
wwv_flow_imp.g_varchar2_table(82) := '646F776E222C65297D2C6B657975702865297B7228226B65797570222C65297D2C746F75636873746172742865297B722822746F7563687374617274222C65297D2C746F7563686D6F76652865297B722822746F7563686D6F7665222C65297D2C746F75';
wwv_flow_imp.g_varchar2_table(83) := '6368656E642865297B722822746F756368656E64222C65297D2C7461702865297B722822746170222C65297D7D7D2C6F653D2828652C743D3231293D3E286F3D74293D3E7B6C6574206E3D22222C723D307C6F3B666F72283B722D2D3B296E2B3D655B4D';
wwv_flow_imp.g_varchar2_table(84) := '6174682E72616E646F6D28292A652E6C656E6774687C305D3B72657475726E206E7D292822303132333435363738394142434445464748494A4B4C4D4E4F505152535455565758595A6162636465666768696A6B6C6D6E6F707172737475767778797A22';
wwv_flow_imp.g_varchar2_table(85) := '2C3332293B66756E6374696F6E206E6528297B72657475726E206F6528297D636F6E73742072653D66756E6374696F6E28652C74297B746869732E6374783D652C746869732E70726F706572746965733D742E70726F706572746965737C7C7B7D2C7468';
wwv_flow_imp.g_varchar2_table(86) := '69732E636F6F7264696E617465733D742E67656F6D657472792E636F6F7264696E617465732C746869732E69643D742E69647C7C6E6528292C746869732E747970653D742E67656F6D657472792E747970657D3B72652E70726F746F747970652E636861';
wwv_flow_imp.g_varchar2_table(87) := '6E6765643D66756E6374696F6E28297B746869732E6374782E73746F72652E666561747572654368616E67656428746869732E6964297D2C72652E70726F746F747970652E696E636F6D696E67436F6F7264733D66756E6374696F6E2865297B74686973';
wwv_flow_imp.g_varchar2_table(88) := '2E736574436F6F7264696E617465732865297D2C72652E70726F746F747970652E736574436F6F7264696E617465733D66756E6374696F6E2865297B746869732E636F6F7264696E617465733D652C746869732E6368616E67656428297D2C72652E7072';
wwv_flow_imp.g_varchar2_table(89) := '6F746F747970652E676574436F6F7264696E617465733D66756E6374696F6E28297B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E6769667928746869732E636F6F7264696E6174657329297D2C72652E70726F746F747970652E';
wwv_flow_imp.g_varchar2_table(90) := '73657450726F70657274793D66756E6374696F6E28652C74297B746869732E70726F706572746965735B655D3D747D2C72652E70726F746F747970652E746F47656F4A534F4E3D66756E6374696F6E28297B72657475726E204A534F4E2E706172736528';
wwv_flow_imp.g_varchar2_table(91) := '4A534F4E2E737472696E67696679287B69643A746869732E69642C747970653A722E464541545552452C70726F706572746965733A746869732E70726F706572746965732C67656F6D657472793A7B636F6F7264696E617465733A746869732E67657443';
wwv_flow_imp.g_varchar2_table(92) := '6F6F7264696E6174657328292C747970653A746869732E747970657D7D29297D2C72652E70726F746F747970652E696E7465726E616C3D66756E6374696F6E2865297B636F6E737420743D7B69643A746869732E69642C6D6574613A632E464541545552';
wwv_flow_imp.g_varchar2_table(93) := '452C226D6574613A74797065223A746869732E747970652C6163746976653A752E494E4143544956452C6D6F64653A657D3B696628746869732E6374782E6F7074696F6E732E7573657250726F7065727469657329666F7228636F6E7374206520696E20';
wwv_flow_imp.g_varchar2_table(94) := '746869732E70726F7065727469657329745B60757365725F247B657D605D3D746869732E70726F706572746965735B655D3B72657475726E7B747970653A722E464541545552452C70726F706572746965733A742C67656F6D657472793A7B636F6F7264';
wwv_flow_imp.g_varchar2_table(95) := '696E617465733A746869732E676574436F6F7264696E6174657328292C747970653A746869732E747970657D7D7D3B636F6E73742069653D66756E6374696F6E28652C74297B72652E63616C6C28746869732C652C74297D3B2869652E70726F746F7479';
wwv_flow_imp.g_varchar2_table(96) := '70653D4F626A6563742E6372656174652872652E70726F746F7479706529292E697356616C69643D66756E6374696F6E28297B72657475726E226E756D626572223D3D747970656F6620746869732E636F6F7264696E617465735B305D2626226E756D62';
wwv_flow_imp.g_varchar2_table(97) := '6572223D3D747970656F6620746869732E636F6F7264696E617465735B315D7D2C69652E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B746869732E636F6F7264696E617465733D333D3D3D';
wwv_flow_imp.g_varchar2_table(98) := '617267756D656E74732E6C656E6774683F5B742C6F5D3A5B652C745D2C746869732E6368616E67656428297D2C69652E70726F746F747970652E676574436F6F7264696E6174653D66756E6374696F6E28297B72657475726E20746869732E676574436F';
wwv_flow_imp.g_varchar2_table(99) := '6F7264696E6174657328297D3B636F6E73742073653D66756E6374696F6E28652C74297B72652E63616C6C28746869732C652C74297D3B2873652E70726F746F747970653D4F626A6563742E6372656174652872652E70726F746F7479706529292E6973';
wwv_flow_imp.g_varchar2_table(100) := '56616C69643D66756E6374696F6E28297B72657475726E20746869732E636F6F7264696E617465732E6C656E6774683E317D2C73652E70726F746F747970652E616464436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B746869732E63';
wwv_flow_imp.g_varchar2_table(101) := '68616E67656428293B636F6E7374206E3D7061727365496E7428652C3130293B746869732E636F6F7264696E617465732E73706C696365286E2C302C5B742C6F5D297D2C73652E70726F746F747970652E676574436F6F7264696E6174653D66756E6374';
wwv_flow_imp.g_varchar2_table(102) := '696F6E2865297B636F6E737420743D7061727365496E7428652C3130293B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E6769667928746869732E636F6F7264696E617465735B745D29297D2C73652E70726F746F747970652E72';
wwv_flow_imp.g_varchar2_table(103) := '656D6F7665436F6F7264696E6174653D66756E6374696F6E2865297B746869732E6368616E67656428292C746869732E636F6F7264696E617465732E73706C696365287061727365496E7428652C3130292C31297D2C73652E70726F746F747970652E75';
wwv_flow_imp.g_varchar2_table(104) := '7064617465436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B636F6E7374206E3D7061727365496E7428652C3130293B746869732E636F6F7264696E617465735B6E5D3D5B742C6F5D2C746869732E6368616E67656428297D3B636F6E';
wwv_flow_imp.g_varchar2_table(105) := '73742061653D66756E6374696F6E28652C74297B72652E63616C6C28746869732C652C74292C746869732E636F6F7264696E617465733D746869732E636F6F7264696E617465732E6D61702828653D3E652E736C69636528302C2D312929297D3B286165';
wwv_flow_imp.g_varchar2_table(106) := '2E70726F746F747970653D4F626A6563742E6372656174652872652E70726F746F7479706529292E697356616C69643D66756E6374696F6E28297B72657475726E2030213D3D746869732E636F6F7264696E617465732E6C656E6774682626746869732E';
wwv_flow_imp.g_varchar2_table(107) := '636F6F7264696E617465732E65766572792828653D3E652E6C656E6774683E3229297D2C61652E70726F746F747970652E696E636F6D696E67436F6F7264733D66756E6374696F6E2865297B746869732E636F6F7264696E617465733D652E6D61702828';
wwv_flow_imp.g_varchar2_table(108) := '653D3E652E736C69636528302C2D312929292C746869732E6368616E67656428297D2C61652E70726F746F747970652E736574436F6F7264696E617465733D66756E6374696F6E2865297B746869732E636F6F7264696E617465733D652C746869732E63';
wwv_flow_imp.g_varchar2_table(109) := '68616E67656428297D2C61652E70726F746F747970652E616464436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B746869732E6368616E67656428293B636F6E7374206E3D652E73706C697428222E22292E6D61702828653D3E706172';
wwv_flow_imp.g_varchar2_table(110) := '7365496E7428652C31302929293B746869732E636F6F7264696E617465735B6E5B305D5D2E73706C696365286E5B315D2C302C5B742C6F5D297D2C61652E70726F746F747970652E72656D6F7665436F6F7264696E6174653D66756E6374696F6E286529';
wwv_flow_imp.g_varchar2_table(111) := '7B746869732E6368616E67656428293B636F6E737420743D652E73706C697428222E22292E6D61702828653D3E7061727365496E7428652C31302929292C6F3D746869732E636F6F7264696E617465735B745B305D5D3B6F2626286F2E73706C69636528';
wwv_flow_imp.g_varchar2_table(112) := '745B315D2C31292C6F2E6C656E6774683C332626746869732E636F6F7264696E617465732E73706C69636528745B305D2C3129297D2C61652E70726F746F747970652E676574436F6F7264696E6174653D66756E6374696F6E2865297B636F6E73742074';
wwv_flow_imp.g_varchar2_table(113) := '3D652E73706C697428222E22292E6D61702828653D3E7061727365496E7428652C31302929292C6F3D746869732E636F6F7264696E617465735B745B305D5D3B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E67696679286F5B74';
wwv_flow_imp.g_varchar2_table(114) := '5B315D5D29297D2C61652E70726F746F747970652E676574436F6F7264696E617465733D66756E6374696F6E28297B72657475726E20746869732E636F6F7264696E617465732E6D61702828653D3E652E636F6E636174285B655B305D5D2929297D2C61';
wwv_flow_imp.g_varchar2_table(115) := '652E70726F746F747970652E757064617465436F6F7264696E6174653D66756E6374696F6E28652C742C6F297B746869732E6368616E67656428293B636F6E7374206E3D652E73706C697428222E22292C723D7061727365496E74286E5B305D2C313029';
wwv_flow_imp.g_varchar2_table(116) := '2C693D7061727365496E74286E5B315D2C3130293B766F696420303D3D3D746869732E636F6F7264696E617465735B725D262628746869732E636F6F7264696E617465735B725D3D5B5D292C746869732E636F6F7264696E617465735B725D5B695D3D5B';
wwv_flow_imp.g_varchar2_table(117) := '742C6F5D7D3B636F6E73742063653D7B4D756C7469506F696E743A69652C4D756C74694C696E65537472696E673A73652C4D756C7469506F6C79676F6E3A61657D2C75653D28652C742C6F2C6E2C72293D3E7B636F6E737420693D6F2E73706C69742822';
wwv_flow_imp.g_varchar2_table(118) := '2E22292C733D7061727365496E7428695B305D2C3130292C613D695B315D3F692E736C6963652831292E6A6F696E28222E22293A6E756C6C3B72657475726E20655B735D5B745D28612C6E2C72297D2C6C653D66756E6374696F6E28652C74297B696628';
wwv_flow_imp.g_varchar2_table(119) := '72652E63616C6C28746869732C652C74292C64656C65746520746869732E636F6F7264696E617465732C746869732E6D6F64656C3D63655B742E67656F6D657472792E747970655D2C766F696420303D3D3D746869732E6D6F64656C297468726F77206E';
wwv_flow_imp.g_varchar2_table(120) := '657720547970654572726F722860247B742E67656F6D657472792E747970657D206973206E6F7420612076616C6964207479706560293B746869732E66656174757265733D746869732E5F636F6F7264696E61746573546F466561747572657328742E67';
wwv_flow_imp.g_varchar2_table(121) := '656F6D657472792E636F6F7264696E61746573297D3B66756E6374696F6E2064652865297B746869732E6D61703D652E6D61702C746869732E64726177436F6E6669673D4A534F4E2E7061727365284A534F4E2E737472696E6769667928652E6F707469';
wwv_flow_imp.g_varchar2_table(122) := '6F6E737C7C7B7D29292C746869732E5F6374783D657D286C652E70726F746F747970653D4F626A6563742E6372656174652872652E70726F746F7479706529292E5F636F6F7264696E61746573546F46656174757265733D66756E6374696F6E2865297B';
wwv_flow_imp.g_varchar2_table(123) := '636F6E737420743D746869732E6D6F64656C2E62696E642874686973293B72657475726E20652E6D61702828653D3E6E6577207428746869732E6374782C7B69643A6E6528292C747970653A722E464541545552452C70726F706572746965733A7B7D2C';
wwv_flow_imp.g_varchar2_table(124) := '67656F6D657472793A7B636F6F7264696E617465733A652C747970653A746869732E747970652E7265706C61636528224D756C7469222C2222297D7D2929297D2C6C652E70726F746F747970652E697356616C69643D66756E6374696F6E28297B726574';
wwv_flow_imp.g_varchar2_table(125) := '75726E20746869732E66656174757265732E65766572792828653D3E652E697356616C6964282929297D2C6C652E70726F746F747970652E736574436F6F7264696E617465733D66756E6374696F6E2865297B746869732E66656174757265733D746869';
wwv_flow_imp.g_varchar2_table(126) := '732E5F636F6F7264696E61746573546F46656174757265732865292C746869732E6368616E67656428297D2C6C652E70726F746F747970652E676574436F6F7264696E6174653D66756E6374696F6E2865297B72657475726E20756528746869732E6665';
wwv_flow_imp.g_varchar2_table(127) := '6174757265732C22676574436F6F7264696E617465222C65297D2C6C652E70726F746F747970652E676574436F6F7264696E617465733D66756E6374696F6E28297B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E676966792874';
wwv_flow_imp.g_varchar2_table(128) := '6869732E66656174757265732E6D61702828653D3E652E747970653D3D3D722E504F4C59474F4E3F652E676574436F6F7264696E6174657328293A652E636F6F7264696E61746573292929297D2C6C652E70726F746F747970652E757064617465436F6F';
wwv_flow_imp.g_varchar2_table(129) := '7264696E6174653D66756E6374696F6E28652C742C6F297B756528746869732E66656174757265732C22757064617465436F6F7264696E617465222C652C742C6F292C746869732E6368616E67656428297D2C6C652E70726F746F747970652E61646443';
wwv_flow_imp.g_varchar2_table(130) := '6F6F7264696E6174653D66756E6374696F6E28652C742C6F297B756528746869732E66656174757265732C22616464436F6F7264696E617465222C652C742C6F292C746869732E6368616E67656428297D2C6C652E70726F746F747970652E72656D6F76';
wwv_flow_imp.g_varchar2_table(131) := '65436F6F7264696E6174653D66756E6374696F6E2865297B756528746869732E66656174757265732C2272656D6F7665436F6F7264696E617465222C65292C746869732E6368616E67656428297D2C6C652E70726F746F747970652E6765744665617475';
wwv_flow_imp.g_varchar2_table(132) := '7265733D66756E6374696F6E28297B72657475726E20746869732E66656174757265737D2C64652E70726F746F747970652E73657453656C65637465643D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E736574';
wwv_flow_imp.g_varchar2_table(133) := '53656C65637465642865297D2C64652E70726F746F747970652E73657453656C6563746564436F6F7264696E617465733D66756E6374696F6E2865297B746869732E5F6374782E73746F72652E73657453656C6563746564436F6F7264696E6174657328';
wwv_flow_imp.g_varchar2_table(134) := '65292C652E726564756365282828652C74293D3E28766F696420303D3D3D655B742E666561747572655F69645D262628655B742E666561747572655F69645D3D21302C746869732E5F6374782E73746F72652E67657428742E666561747572655F696429';
wwv_flow_imp.g_varchar2_table(135) := '2E6368616E6765642829292C6529292C7B7D297D2C64652E70726F746F747970652E67657453656C65637465643D66756E6374696F6E28297B72657475726E20746869732E5F6374782E73746F72652E67657453656C656374656428297D2C64652E7072';
wwv_flow_imp.g_varchar2_table(136) := '6F746F747970652E67657453656C65637465644964733D66756E6374696F6E28297B72657475726E20746869732E5F6374782E73746F72652E67657453656C656374656449647328297D2C64652E70726F746F747970652E697353656C65637465643D66';
wwv_flow_imp.g_varchar2_table(137) := '756E6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E697353656C65637465642865297D2C64652E70726F746F747970652E676574466561747572653D66756E6374696F6E2865297B72657475726E20746869732E5F6374';
wwv_flow_imp.g_varchar2_table(138) := '782E73746F72652E6765742865297D2C64652E70726F746F747970652E73656C6563743D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E73656C6563742865297D2C64652E70726F746F747970652E646573656C';
wwv_flow_imp.g_varchar2_table(139) := '6563743D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E646573656C6563742865297D2C64652E70726F746F747970652E64656C657465466561747572653D66756E6374696F6E28652C743D7B7D297B72657475';
wwv_flow_imp.g_varchar2_table(140) := '726E20746869732E5F6374782E73746F72652E64656C65746528652C74297D2C64652E70726F746F747970652E616464466561747572653D66756E6374696F6E28652C743D7B7D297B72657475726E20746869732E5F6374782E73746F72652E61646428';
wwv_flow_imp.g_varchar2_table(141) := '652C74297D2C64652E70726F746F747970652E636C65617253656C656374656446656174757265733D66756E6374696F6E28297B72657475726E20746869732E5F6374782E73746F72652E636C65617253656C656374656428297D2C64652E70726F746F';
wwv_flow_imp.g_varchar2_table(142) := '747970652E636C65617253656C6563746564436F6F7264696E617465733D66756E6374696F6E28297B72657475726E20746869732E5F6374782E73746F72652E636C65617253656C6563746564436F6F7264696E6174657328297D2C64652E70726F746F';
wwv_flow_imp.g_varchar2_table(143) := '747970652E736574416374696F6E61626C6553746174653D66756E6374696F6E28653D7B7D297B636F6E737420743D7B74726173683A652E74726173687C7C21312C636F6D62696E6546656174757265733A652E636F6D62696E6546656174757265737C';
wwv_flow_imp.g_varchar2_table(144) := '7C21312C756E636F6D62696E6546656174757265733A652E756E636F6D62696E6546656174757265737C7C21317D3B72657475726E20746869732E5F6374782E6576656E74732E616374696F6E61626C652874297D2C64652E70726F746F747970652E63';
wwv_flow_imp.g_varchar2_table(145) := '68616E67654D6F64653D66756E6374696F6E28652C743D7B7D2C6F3D7B7D297B72657475726E20746869732E5F6374782E6576656E74732E6368616E67654D6F646528652C742C6F297D2C64652E70726F746F747970652E666972653D66756E6374696F';
wwv_flow_imp.g_varchar2_table(146) := '6E28652C74297B72657475726E20746869732E5F6374782E6576656E74732E6669726528652C74297D2C64652E70726F746F747970652E7570646174655549436C61737365733D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E';
wwv_flow_imp.g_varchar2_table(147) := '75692E71756575654D6170436C61737365732865297D2C64652E70726F746F747970652E61637469766174655549427574746F6E3D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E75692E736574416374697665427574746F6E';
wwv_flow_imp.g_varchar2_table(148) := '2865297D2C64652E70726F746F747970652E666561747572657341743D66756E6374696F6E28652C742C6F3D22636C69636B22297B69662822636C69636B22213D3D6F262622746F75636822213D3D6F297468726F77206E6577204572726F722822696E';
wwv_flow_imp.g_varchar2_table(149) := '76616C696420627566666572207479706522293B72657475726E20245B6F5D28652C742C746869732E5F637478297D2C64652E70726F746F747970652E6E6577466561747572653D66756E6374696F6E2865297B636F6E737420743D652E67656F6D6574';
wwv_flow_imp.g_varchar2_table(150) := '72792E747970653B72657475726E20743D3D3D722E504F494E543F6E657720696528746869732E5F6374782C65293A743D3D3D722E4C494E455F535452494E473F6E657720736528746869732E5F6374782C65293A743D3D3D722E504F4C59474F4E3F6E';
wwv_flow_imp.g_varchar2_table(151) := '657720616528746869732E5F6374782C65293A6E6577206C6528746869732E5F6374782C65297D2C64652E70726F746F747970652E6973496E7374616E63654F663D66756E6374696F6E28652C74297B696628653D3D3D722E504F494E54297265747572';
wwv_flow_imp.g_varchar2_table(152) := '6E207420696E7374616E63656F662069653B696628653D3D3D722E4C494E455F535452494E472972657475726E207420696E7374616E63656F662073653B696628653D3D3D722E504F4C59474F4E2972657475726E207420696E7374616E63656F662061';
wwv_flow_imp.g_varchar2_table(153) := '653B696628224D756C746946656174757265223D3D3D652972657475726E207420696E7374616E63656F66206C653B7468726F77206E6577204572726F722860556E6B6E6F776E206665617475726520636C6173733A20247B657D60297D2C64652E7072';
wwv_flow_imp.g_varchar2_table(154) := '6F746F747970652E646F52656E6465723D66756E6374696F6E2865297B72657475726E20746869732E5F6374782E73746F72652E666561747572654368616E6765642865297D2C64652E70726F746F747970652E6F6E53657475703D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(155) := '28297B7D2C64652E70726F746F747970652E6F6E447261673D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E436C69636B3D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E4D6F7573654D6F76653D66756E';
wwv_flow_imp.g_varchar2_table(156) := '6374696F6E28297B7D2C64652E70726F746F747970652E6F6E4D6F757365446F776E3D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E4D6F75736555703D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E4D';
wwv_flow_imp.g_varchar2_table(157) := '6F7573654F75743D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E4B657955703D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E4B6579446F776E3D66756E6374696F6E28297B7D2C64652E70726F746F74';
wwv_flow_imp.g_varchar2_table(158) := '7970652E6F6E546F75636853746172743D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E546F7563684D6F76653D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E546F756368456E643D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(159) := '28297B7D2C64652E70726F746F747970652E6F6E5461703D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E53746F703D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E54726173683D66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(160) := '297B7D2C64652E70726F746F747970652E6F6E436F6D62696E65466561747572653D66756E6374696F6E28297B7D2C64652E70726F746F747970652E6F6E556E636F6D62696E65466561747572653D66756E6374696F6E28297B7D2C64652E70726F746F';
wwv_flow_imp.g_varchar2_table(161) := '747970652E746F446973706C617946656174757265733D66756E6374696F6E28297B7468726F77206E6577204572726F722822596F75206D757374206F766572777269746520746F446973706C6179466561747572657322297D3B636F6E73742070653D';
wwv_flow_imp.g_varchar2_table(162) := '7B647261673A226F6E44726167222C636C69636B3A226F6E436C69636B222C6D6F7573656D6F76653A226F6E4D6F7573654D6F7665222C6D6F757365646F776E3A226F6E4D6F757365446F776E222C6D6F75736575703A226F6E4D6F7573655570222C6D';
wwv_flow_imp.g_varchar2_table(163) := '6F7573656F75743A226F6E4D6F7573654F7574222C6B657975703A226F6E4B65795570222C6B6579646F776E3A226F6E4B6579446F776E222C746F75636873746172743A226F6E546F7563685374617274222C746F7563686D6F76653A226F6E546F7563';
wwv_flow_imp.g_varchar2_table(164) := '684D6F7665222C746F756368656E643A226F6E546F756368456E64222C7461703A226F6E546170227D2C68653D4F626A6563742E6B657973287065293B66756E6374696F6E2066652865297B72657475726E5B5D2E636F6E6361742865292E66696C7465';
wwv_flow_imp.g_varchar2_table(165) := '722828653D3E766F69642030213D3D6529297D66756E6374696F6E20676528297B636F6E737420653D746869733B69662821652E6374782E6D61707C7C766F696420303D3D3D652E6374782E6D61702E676574536F7572636528742E484F542929726574';
wwv_flow_imp.g_varchar2_table(166) := '75726E207528293B636F6E7374206F3D652E6374782E6576656E74732E63757272656E744D6F64654E616D6528293B652E6374782E75692E71756575654D6170436C6173736573287B6D6F64653A6F7D293B6C6574206E3D5B5D2C693D5B5D3B652E6973';
wwv_flow_imp.g_varchar2_table(167) := '44697274793F693D652E676574416C6C49647328293A286E3D652E6765744368616E67656449647328292E66696C7465722828743D3E766F69642030213D3D652E67657428742929292C693D652E736F75726365732E686F742E66696C7465722828743D';
wwv_flow_imp.g_varchar2_table(168) := '3E742E70726F706572746965732E696426262D313D3D3D6E2E696E6465784F6628742E70726F706572746965732E6964292626766F69642030213D3D652E67657428742E70726F706572746965732E69642929292E6D61702828653D3E652E70726F7065';
wwv_flow_imp.g_varchar2_table(169) := '72746965732E69642929292C652E736F75726365732E686F743D5B5D3B636F6E737420733D652E736F75726365732E636F6C642E6C656E6774683B652E736F75726365732E636F6C643D652E697344697274793F5B5D3A652E736F75726365732E636F6C';
wwv_flow_imp.g_varchar2_table(170) := '642E66696C7465722828653D3E7B636F6E737420743D652E70726F706572746965732E69647C7C652E70726F706572746965732E706172656E743B72657475726E2D313D3D3D6E2E696E6465784F662874297D29293B636F6E737420613D73213D3D652E';
wwv_flow_imp.g_varchar2_table(171) := '736F75726365732E636F6C642E6C656E6774687C7C692E6C656E6774683E303B66756E6374696F6E206328742C6E297B636F6E737420723D652E6765742874292E696E7465726E616C286F293B652E6374782E6576656E74732E63757272656E744D6F64';
wwv_flow_imp.g_varchar2_table(172) := '6552656E64657228722C28743D3E7B742E70726F706572746965732E6D6F64653D6F2C652E736F75726365735B6E5D2E707573682874297D29297D66756E6374696F6E207528297B652E697344697274793D21312C652E636C6561724368616E67656449';
wwv_flow_imp.g_varchar2_table(173) := '647328297D6E2E666F72456163682828653D3E6328652C22686F74222929292C692E666F72456163682828653D3E6328652C22636F6C64222929292C612626652E6374782E6D61702E676574536F7572636528742E434F4C44292E73657444617461287B';
wwv_flow_imp.g_varchar2_table(174) := '747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A652E736F75726365732E636F6C647D292C652E6374782E6D61702E676574536F7572636528742E484F54292E73657444617461287B747970653A722E4645415455';
wwv_flow_imp.g_varchar2_table(175) := '52455F434F4C4C454354494F4E2C66656174757265733A652E736F75726365732E686F747D292C7528297D66756E6374696F6E2079652865297B6C657420743B746869732E5F66656174757265733D7B7D2C746869732E5F666561747572654964733D6E';
wwv_flow_imp.g_varchar2_table(176) := '6577206A2C746869732E5F73656C6563746564466561747572654964733D6E6577206A2C746869732E5F73656C6563746564436F6F7264696E617465733D5B5D2C746869732E5F6368616E676564466561747572654964733D6E6577206A2C746869732E';
wwv_flow_imp.g_varchar2_table(177) := '5F656D697453656C656374696F6E4368616E67653D21312C746869732E5F6D6170496E697469616C436F6E6669673D7B7D2C746869732E6374783D652C746869732E736F75726365733D7B686F743A5B5D2C636F6C643A5B5D7D2C746869732E72656E64';
wwv_flow_imp.g_varchar2_table(178) := '65723D28293D3E7B747C7C28743D72657175657374416E696D6174696F6E4672616D65282828293D3E7B743D6E756C6C2C67652E63616C6C2874686973292C746869732E5F656D697453656C656374696F6E4368616E6765262628746869732E6374782E';
wwv_flow_imp.g_varchar2_table(179) := '6576656E74732E6669726528732E53454C454354494F4E5F4348414E47452C7B66656174757265733A746869732E67657453656C656374656428292E6D61702828653D3E652E746F47656F4A534F4E282929292C706F696E74733A746869732E67657453';
wwv_flow_imp.g_varchar2_table(180) := '656C6563746564436F6F7264696E6174657328292E6D61702828653D3E287B747970653A722E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F7264696E617465733A652E636F6F';
wwv_flow_imp.g_varchar2_table(181) := '7264696E617465737D7D2929297D292C746869732E5F656D697453656C656374696F6E4368616E67653D2131292C746869732E6374782E6576656E74732E6669726528732E52454E4445522C7B7D297D2929297D2C746869732E697344697274793D2131';
wwv_flow_imp.g_varchar2_table(182) := '7D66756E6374696F6E206D6528652C743D7B7D297B636F6E7374206F3D652E5F73656C6563746564436F6F7264696E617465732E66696C7465722828743D3E652E5F73656C6563746564466561747572654964732E68617328742E666561747572655F69';
wwv_flow_imp.g_varchar2_table(183) := '642929293B652E5F73656C6563746564436F6F7264696E617465732E6C656E6774683D3D3D6F2E6C656E6774687C7C742E73696C656E747C7C28652E5F656D697453656C656374696F6E4368616E67653D2130292C652E5F73656C6563746564436F6F72';
wwv_flow_imp.g_varchar2_table(184) := '64696E617465733D6F7D79652E70726F746F747970652E63726561746552656E64657242617463683D66756E6374696F6E28297B636F6E737420653D746869732E72656E6465723B6C657420743D303B72657475726E20746869732E72656E6465723D66';
wwv_flow_imp.g_varchar2_table(185) := '756E6374696F6E28297B742B2B7D2C28293D3E7B746869732E72656E6465723D652C743E302626746869732E72656E64657228297D7D2C79652E70726F746F747970652E73657444697274793D66756E6374696F6E28297B72657475726E20746869732E';
wwv_flow_imp.g_varchar2_table(186) := '697344697274793D21302C746869737D2C79652E70726F746F747970652E66656174757265437265617465643D66756E6374696F6E28652C743D7B7D297B696628746869732E5F6368616E676564466561747572654964732E6164642865292C2130213D';
wwv_flow_imp.g_varchar2_table(187) := '3D286E756C6C213D742E73696C656E743F742E73696C656E743A746869732E6374782E6F7074696F6E732E73757070726573734150494576656E747329297B636F6E737420743D746869732E6765742865293B746869732E6374782E6576656E74732E66';
wwv_flow_imp.g_varchar2_table(188) := '69726528732E4352454154452C7B66656174757265733A5B742E746F47656F4A534F4E28295D7D297D72657475726E20746869737D2C79652E70726F746F747970652E666561747572654368616E6765643D66756E6374696F6E28652C743D7B7D297B72';
wwv_flow_imp.g_varchar2_table(189) := '657475726E20746869732E5F6368616E676564466561747572654964732E6164642865292C2130213D3D286E756C6C213D742E73696C656E743F742E73696C656E743A746869732E6374782E6F7074696F6E732E73757070726573734150494576656E74';
wwv_flow_imp.g_varchar2_table(190) := '73292626746869732E6374782E6576656E74732E6669726528732E5550444154452C7B616374696F6E3A742E616374696F6E3F742E616374696F6E3A612E4348414E47455F434F4F5244494E415445532C66656174757265733A5B746869732E67657428';
wwv_flow_imp.g_varchar2_table(191) := '65292E746F47656F4A534F4E28295D7D292C746869737D2C79652E70726F746F747970652E6765744368616E6765644964733D66756E6374696F6E28297B72657475726E20746869732E5F6368616E676564466561747572654964732E76616C75657328';
wwv_flow_imp.g_varchar2_table(192) := '297D2C79652E70726F746F747970652E636C6561724368616E6765644964733D66756E6374696F6E28297B72657475726E20746869732E5F6368616E676564466561747572654964732E636C65617228292C746869737D2C79652E70726F746F74797065';
wwv_flow_imp.g_varchar2_table(193) := '2E676574416C6C4964733D66756E6374696F6E28297B72657475726E20746869732E5F666561747572654964732E76616C75657328297D2C79652E70726F746F747970652E6164643D66756E6374696F6E28652C743D7B7D297B72657475726E20746869';
wwv_flow_imp.g_varchar2_table(194) := '732E5F66656174757265735B652E69645D3D652C746869732E5F666561747572654964732E61646428652E6964292C746869732E666561747572654372656174656428652E69642C7B73696C656E743A742E73696C656E747D292C746869737D2C79652E';
wwv_flow_imp.g_varchar2_table(195) := '70726F746F747970652E64656C6574653D66756E6374696F6E28652C743D7B7D297B636F6E7374206F3D5B5D3B72657475726E2066652865292E666F72456163682828653D3E7B746869732E5F666561747572654964732E686173286529262628746869';
wwv_flow_imp.g_varchar2_table(196) := '732E5F666561747572654964732E64656C6574652865292C746869732E5F73656C6563746564466561747572654964732E64656C6574652865292C742E73696C656E747C7C2D313D3D3D6F2E696E6465784F6628746869732E5F66656174757265735B65';
wwv_flow_imp.g_varchar2_table(197) := '5D2926266F2E7075736828746869732E5F66656174757265735B655D2E746F47656F4A534F4E2829292C64656C65746520746869732E5F66656174757265735B655D2C746869732E697344697274793D2130297D29292C6F2E6C656E6774682626746869';
wwv_flow_imp.g_varchar2_table(198) := '732E6374782E6576656E74732E6669726528732E44454C4554452C7B66656174757265733A6F7D292C6D6528746869732C74292C746869737D2C79652E70726F746F747970652E6765743D66756E6374696F6E2865297B72657475726E20746869732E5F';
wwv_flow_imp.g_varchar2_table(199) := '66656174757265735B655D7D2C79652E70726F746F747970652E676574416C6C3D66756E6374696F6E28297B72657475726E204F626A6563742E6B65797328746869732E5F6665617475726573292E6D61702828653D3E746869732E5F66656174757265';
wwv_flow_imp.g_varchar2_table(200) := '735B655D29297D2C79652E70726F746F747970652E73656C6563743D66756E6374696F6E28652C743D7B7D297B72657475726E2066652865292E666F72456163682828653D3E7B746869732E5F73656C6563746564466561747572654964732E68617328';
wwv_flow_imp.g_varchar2_table(201) := '65297C7C28746869732E5F73656C6563746564466561747572654964732E6164642865292C746869732E5F6368616E676564466561747572654964732E6164642865292C742E73696C656E747C7C28746869732E5F656D697453656C656374696F6E4368';
wwv_flow_imp.g_varchar2_table(202) := '616E67653D213029297D29292C746869737D2C79652E70726F746F747970652E646573656C6563743D66756E6374696F6E28652C743D7B7D297B72657475726E2066652865292E666F72456163682828653D3E7B746869732E5F73656C65637465644665';
wwv_flow_imp.g_varchar2_table(203) := '61747572654964732E686173286529262628746869732E5F73656C6563746564466561747572654964732E64656C6574652865292C746869732E5F6368616E676564466561747572654964732E6164642865292C742E73696C656E747C7C28746869732E';
wwv_flow_imp.g_varchar2_table(204) := '5F656D697453656C656374696F6E4368616E67653D213029297D29292C6D6528746869732C74292C746869737D2C79652E70726F746F747970652E636C65617253656C65637465643D66756E6374696F6E28653D7B7D297B72657475726E20746869732E';
wwv_flow_imp.g_varchar2_table(205) := '646573656C65637428746869732E5F73656C6563746564466561747572654964732E76616C75657328292C7B73696C656E743A652E73696C656E747D292C746869737D2C79652E70726F746F747970652E73657453656C65637465643D66756E6374696F';
wwv_flow_imp.g_varchar2_table(206) := '6E28652C743D7B7D297B72657475726E20653D66652865292C746869732E646573656C65637428746869732E5F73656C6563746564466561747572654964732E76616C75657328292E66696C7465722828743D3E2D313D3D3D652E696E6465784F662874';
wwv_flow_imp.g_varchar2_table(207) := '2929292C7B73696C656E743A742E73696C656E747D292C746869732E73656C65637428652E66696C7465722828653D3E21746869732E5F73656C6563746564466561747572654964732E68617328652929292C7B73696C656E743A742E73696C656E747D';
wwv_flow_imp.g_varchar2_table(208) := '292C746869737D2C79652E70726F746F747970652E73657453656C6563746564436F6F7264696E617465733D66756E6374696F6E2865297B72657475726E20746869732E5F73656C6563746564436F6F7264696E617465733D652C746869732E5F656D69';
wwv_flow_imp.g_varchar2_table(209) := '7453656C656374696F6E4368616E67653D21302C746869737D2C79652E70726F746F747970652E636C65617253656C6563746564436F6F7264696E617465733D66756E6374696F6E28297B72657475726E20746869732E5F73656C6563746564436F6F72';
wwv_flow_imp.g_varchar2_table(210) := '64696E617465733D5B5D2C746869732E5F656D697453656C656374696F6E4368616E67653D21302C746869737D2C79652E70726F746F747970652E67657453656C65637465644964733D66756E6374696F6E28297B72657475726E20746869732E5F7365';
wwv_flow_imp.g_varchar2_table(211) := '6C6563746564466561747572654964732E76616C75657328297D2C79652E70726F746F747970652E67657453656C65637465643D66756E6374696F6E28297B72657475726E20746869732E67657453656C656374656449647328292E6D61702828653D3E';
wwv_flow_imp.g_varchar2_table(212) := '746869732E67657428652929297D2C79652E70726F746F747970652E67657453656C6563746564436F6F7264696E617465733D66756E6374696F6E28297B72657475726E20746869732E5F73656C6563746564436F6F7264696E617465732E6D61702828';
wwv_flow_imp.g_varchar2_table(213) := '653D3E287B636F6F7264696E617465733A746869732E67657428652E666561747572655F6964292E676574436F6F7264696E61746528652E636F6F72645F70617468297D2929297D2C79652E70726F746F747970652E697353656C65637465643D66756E';
wwv_flow_imp.g_varchar2_table(214) := '6374696F6E2865297B72657475726E20746869732E5F73656C6563746564466561747572654964732E6861732865297D2C79652E70726F746F747970652E7365744665617475726550726F70657274793D66756E6374696F6E28652C742C6F2C6E3D7B7D';
wwv_flow_imp.g_varchar2_table(215) := '297B746869732E6765742865292E73657450726F706572747928742C6F292C746869732E666561747572654368616E67656428652C7B73696C656E743A6E2E73696C656E742C616374696F6E3A612E4348414E47455F50524F504552544945537D297D2C';
wwv_flow_imp.g_varchar2_table(216) := '79652E70726F746F747970652E73746F72654D6170436F6E6669673D66756E6374696F6E28297B6C2E666F72456163682828653D3E7B746869732E6374782E6D61705B655D262628746869732E5F6D6170496E697469616C436F6E6669675B655D3D7468';
wwv_flow_imp.g_varchar2_table(217) := '69732E6374782E6D61705B655D2E6973456E61626C65642829297D29297D2C79652E70726F746F747970652E726573746F72654D6170436F6E6669673D66756E6374696F6E28297B4F626A6563742E6B65797328746869732E5F6D6170496E697469616C';
wwv_flow_imp.g_varchar2_table(218) := '436F6E666967292E666F72456163682828653D3E7B746869732E5F6D6170496E697469616C436F6E6669675B655D3F746869732E6374782E6D61705B655D2E656E61626C6528293A746869732E6374782E6D61705B655D2E64697361626C6528297D2929';
wwv_flow_imp.g_varchar2_table(219) := '7D2C79652E70726F746F747970652E676574496E697469616C436F6E66696756616C75653D66756E6374696F6E2865297B72657475726E20766F696420303D3D3D746869732E5F6D6170496E697469616C436F6E6669675B655D7C7C746869732E5F6D61';
wwv_flow_imp.g_varchar2_table(220) := '70496E697469616C436F6E6669675B655D7D3B636F6E73742045653D5B226D6F6465222C2266656174757265222C226D6F757365225D3B66756E6374696F6E2043652861297B6C657420633D6E756C6C2C753D6E756C6C3B636F6E7374206C3D7B6F6E52';
wwv_flow_imp.g_varchar2_table(221) := '656D6F766528297B72657475726E20612E6D61702E6F666628226C6F6164222C6C2E636F6E6E656374292C636C656172496E74657276616C2875292C6C2E72656D6F76654C617965727328292C612E73746F72652E726573746F72654D6170436F6E6669';
wwv_flow_imp.g_varchar2_table(222) := '6728292C612E75692E72656D6F7665427574746F6E7328292C612E6576656E74732E72656D6F76654576656E744C697374656E65727328292C612E75692E636C6561724D6170436C617373657328292C612E626F785A6F6F6D496E697469616C2626612E';
wwv_flow_imp.g_varchar2_table(223) := '6D61702E626F785A6F6F6D2E656E61626C6528292C612E6D61703D6E756C6C2C612E636F6E7461696E65723D6E756C6C2C612E73746F72653D6E756C6C2C632626632E706172656E744E6F64652626632E706172656E744E6F64652E72656D6F76654368';
wwv_flow_imp.g_varchar2_table(224) := '696C642863292C633D6E756C6C2C746869737D2C636F6E6E65637428297B612E6D61702E6F666628226C6F6164222C6C2E636F6E6E656374292C636C656172496E74657276616C2875292C6C2E6164644C617965727328292C612E73746F72652E73746F';
wwv_flow_imp.g_varchar2_table(225) := '72654D6170436F6E66696728292C612E6576656E74732E6164644576656E744C697374656E65727328297D2C6F6E4164642874297B696628612E6D61703D742C612E6576656E74733D66756E6374696F6E2874297B636F6E7374206E3D4F626A6563742E';
wwv_flow_imp.g_varchar2_table(226) := '6B65797328742E6F7074696F6E732E6D6F646573292E726564756365282828652C6F293D3E28655B6F5D3D66756E6374696F6E2865297B636F6E737420743D4F626A6563742E6B6579732865293B72657475726E2066756E6374696F6E286F2C6E3D7B7D';
wwv_flow_imp.g_varchar2_table(227) := '297B6C657420723D7B7D3B636F6E737420693D742E726564756365282828742C6F293D3E28745B6F5D3D655B6F5D2C7429292C6E6577206465286F29293B72657475726E7B737461727428297B723D692E6F6E5365747570286E292C68652E666F724561';
wwv_flow_imp.g_varchar2_table(228) := '63682828743D3E7B636F6E7374206F3D70655B745D3B6C6574206E3D28293D3E21313B76617220733B655B6F5D2626286E3D28293D3E2130292C746869732E6F6E28742C6E2C28733D6F2C653D3E695B735D28722C652929297D29297D2C73746F702829';
wwv_flow_imp.g_varchar2_table(229) := '7B692E6F6E53746F702872297D2C747261736828297B692E6F6E54726173682872297D2C636F6D62696E65466561747572657328297B692E6F6E436F6D62696E6546656174757265732872297D2C756E636F6D62696E65466561747572657328297B692E';
wwv_flow_imp.g_varchar2_table(230) := '6F6E556E636F6D62696E6546656174757265732872297D2C72656E64657228652C74297B692E746F446973706C6179466561747572657328722C652C74297D7D7D7D28742E6F7074696F6E732E6D6F6465735B6F5D292C6529292C7B7D293B6C65742072';
wwv_flow_imp.g_varchar2_table(231) := '3D7B7D2C613D7B7D3B636F6E737420633D7B7D3B6C657420753D6E756C6C2C6C3D6E756C6C3B632E647261673D66756E6374696F6E28652C6E297B6E287B706F696E743A652E706F696E742C74696D653A286E65772044617465292E67657454696D6528';
wwv_flow_imp.g_varchar2_table(232) := '297D293F28742E75692E71756575654D6170436C6173736573287B6D6F7573653A6F2E445241477D292C6C2E64726167286529293A652E6F726967696E616C4576656E742E73746F7050726F7061676174696F6E28297D2C632E6D6F757365647261673D';
wwv_flow_imp.g_varchar2_table(233) := '66756E6374696F6E2865297B632E6472616728652C28653D3E215728722C652929297D2C632E746F756368647261673D66756E6374696F6E2865297B632E6472616728652C28653D3E21656528612C652929297D2C632E6D6F7573656D6F76653D66756E';
wwv_flow_imp.g_varchar2_table(234) := '6374696F6E2865297B696628313D3D3D28766F69642030213D3D652E6F726967696E616C4576656E742E627574746F6E733F652E6F726967696E616C4576656E742E627574746F6E733A652E6F726967696E616C4576656E742E77686963682929726574';
wwv_flow_imp.g_varchar2_table(235) := '75726E20632E6D6F757365647261672865293B636F6E7374206F3D4828652C74293B652E666561747572655461726765743D6F2C6C2E6D6F7573656D6F76652865297D2C632E6D6F757365646F776E3D66756E6374696F6E2865297B723D7B74696D653A';
wwv_flow_imp.g_varchar2_table(236) := '286E65772044617465292E67657454696D6528292C706F696E743A652E706F696E747D3B636F6E7374206F3D4828652C74293B652E666561747572655461726765743D6F2C6C2E6D6F757365646F776E2865297D2C632E6D6F75736575703D66756E6374';
wwv_flow_imp.g_varchar2_table(237) := '696F6E2865297B636F6E7374206F3D4828652C74293B652E666561747572655461726765743D6F2C5728722C7B706F696E743A652E706F696E742C74696D653A286E65772044617465292E67657454696D6528297D293F6C2E636C69636B2865293A6C2E';
wwv_flow_imp.g_varchar2_table(238) := '6D6F75736575702865297D2C632E6D6F7573656F75743D66756E6374696F6E2865297B6C2E6D6F7573656F75742865297D2C632E746F75636873746172743D66756E6374696F6E2865297B69662821742E6F7074696F6E732E746F756368456E61626C65';
wwv_flow_imp.g_varchar2_table(239) := '642972657475726E3B613D7B74696D653A286E65772044617465292E67657454696D6528292C706F696E743A652E706F696E747D3B636F6E7374206F3D242E746F75636828652C6E756C6C2C74295B305D3B652E666561747572655461726765743D6F2C';
wwv_flow_imp.g_varchar2_table(240) := '6C2E746F75636873746172742865297D2C632E746F7563686D6F76653D66756E6374696F6E2865297B696628742E6F7074696F6E732E746F756368456E61626C65642972657475726E206C2E746F7563686D6F76652865292C632E746F75636864726167';
wwv_flow_imp.g_varchar2_table(241) := '2865297D2C632E746F756368656E643D66756E6374696F6E2865297B696628652E6F726967696E616C4576656E742E70726576656E7444656661756C7428292C21742E6F7074696F6E732E746F756368456E61626C65642972657475726E3B636F6E7374';
wwv_flow_imp.g_varchar2_table(242) := '206F3D242E746F75636828652C6E756C6C2C74295B305D3B652E666561747572655461726765743D6F2C656528612C7B74696D653A286E65772044617465292E67657454696D6528292C706F696E743A652E706F696E747D293F6C2E7461702865293A6C';
wwv_flow_imp.g_varchar2_table(243) := '2E746F756368656E642865297D3B636F6E737420643D653D3E7B636F6E737420743D532865292C6F3D4F2865292C6E3D622865293B72657475726E2128747C7C6F7C7C6E297D3B66756E6374696F6E207028652C6F2C723D7B7D297B6C2E73746F702829';
wwv_flow_imp.g_varchar2_table(244) := '3B636F6E737420693D6E5B655D3B696628766F696420303D3D3D69297468726F77206E6577204572726F722860247B657D206973206E6F742076616C696460293B753D653B636F6E737420613D6928742C6F293B6C3D746528612C74292C722E73696C65';
wwv_flow_imp.g_varchar2_table(245) := '6E747C7C742E6D61702E6669726528732E4D4F44455F4348414E47452C7B6D6F64653A657D292C742E73746F72652E736574446972747928292C742E73746F72652E72656E64657228297D632E6B6579646F776E3D66756E6374696F6E286F297B286F2E';
wwv_flow_imp.g_varchar2_table(246) := '737263456C656D656E747C7C6F2E746172676574292E636C6173734C6973742E636F6E7461696E7328652E43414E564153292626282853286F297C7C4F286F29292626742E6F7074696F6E732E636F6E74726F6C732E74726173683F286F2E7072657665';
wwv_flow_imp.g_varchar2_table(247) := '6E7444656661756C7428292C6C2E74726173682829293A64286F293F6C2E6B6579646F776E286F293A4D286F292626742E6F7074696F6E732E636F6E74726F6C732E706F696E743F7028692E445241575F504F494E54293A4C286F292626742E6F707469';
wwv_flow_imp.g_varchar2_table(248) := '6F6E732E636F6E74726F6C732E6C696E655F737472696E673F7028692E445241575F4C494E455F535452494E47293A4E286F292626742E6F7074696F6E732E636F6E74726F6C732E706F6C79676F6E26267028692E445241575F504F4C59474F4E29297D';
wwv_flow_imp.g_varchar2_table(249) := '2C632E6B657975703D66756E6374696F6E2865297B6428652926266C2E6B657975702865297D2C632E7A6F6F6D656E643D66756E6374696F6E28297B742E73746F72652E6368616E67655A6F6F6D28297D2C632E646174613D66756E6374696F6E286529';
wwv_flow_imp.g_varchar2_table(250) := '7B696628227374796C65223D3D3D652E6461746154797065297B636F6E73747B73657475703A652C6D61703A6F2C6F7074696F6E733A6E2C73746F72653A727D3D743B6E2E7374796C65732E736F6D652828653D3E6F2E6765744C6179657228652E6964';
wwv_flow_imp.g_varchar2_table(251) := '2929297C7C28652E6164644C617965727328292C722E736574446972747928292C722E72656E6465722829297D7D3B636F6E737420683D7B74726173683A21312C636F6D62696E6546656174757265733A21312C756E636F6D62696E6546656174757265';
wwv_flow_imp.g_varchar2_table(252) := '733A21317D3B72657475726E7B737461727428297B753D742E6F7074696F6E732E64656661756C744D6F64652C6C3D7465286E5B755D2874292C74297D2C6368616E67654D6F64653A702C616374696F6E61626C653A66756E6374696F6E2865297B6C65';
wwv_flow_imp.g_varchar2_table(253) := '74206F3D21313B4F626A6563742E6B6579732865292E666F72456163682828743D3E7B696628766F696420303D3D3D685B745D297468726F77206E6577204572726F722822496E76616C696420616374696F6E207479706522293B685B745D213D3D655B';
wwv_flow_imp.g_varchar2_table(254) := '745D2626286F3D2130292C685B745D3D655B745D7D29292C6F2626742E6D61702E6669726528732E414354494F4E41424C452C7B616374696F6E733A687D297D2C63757272656E744D6F64654E616D653A28293D3E752C63757272656E744D6F64655265';
wwv_flow_imp.g_varchar2_table(255) := '6E6465723A28652C74293D3E6C2E72656E64657228652C74292C6669726528652C6F297B742E6D61702626742E6D61702E6669726528652C6F297D2C6164644576656E744C697374656E65727328297B742E6D61702E6F6E28226D6F7573656D6F766522';
wwv_flow_imp.g_varchar2_table(256) := '2C632E6D6F7573656D6F7665292C742E6D61702E6F6E28226D6F757365646F776E222C632E6D6F757365646F776E292C742E6D61702E6F6E28226D6F7573657570222C632E6D6F7573657570292C742E6D61702E6F6E282264617461222C632E64617461';
wwv_flow_imp.g_varchar2_table(257) := '292C742E6D61702E6F6E2822746F7563686D6F7665222C632E746F7563686D6F7665292C742E6D61702E6F6E2822746F7563687374617274222C632E746F7563687374617274292C742E6D61702E6F6E2822746F756368656E64222C632E746F75636865';
wwv_flow_imp.g_varchar2_table(258) := '6E64292C742E636F6E7461696E65722E6164644576656E744C697374656E657228226D6F7573656F7574222C632E6D6F7573656F7574292C742E6F7074696F6E732E6B657962696E64696E6773262628742E636F6E7461696E65722E6164644576656E74';
wwv_flow_imp.g_varchar2_table(259) := '4C697374656E657228226B6579646F776E222C632E6B6579646F776E292C742E636F6E7461696E65722E6164644576656E744C697374656E657228226B65797570222C632E6B6579757029297D2C72656D6F76654576656E744C697374656E6572732829';
wwv_flow_imp.g_varchar2_table(260) := '7B742E6D61702E6F666628226D6F7573656D6F7665222C632E6D6F7573656D6F7665292C742E6D61702E6F666628226D6F757365646F776E222C632E6D6F757365646F776E292C742E6D61702E6F666628226D6F7573657570222C632E6D6F7573657570';
wwv_flow_imp.g_varchar2_table(261) := '292C742E6D61702E6F6666282264617461222C632E64617461292C742E6D61702E6F66662822746F7563686D6F7665222C632E746F7563686D6F7665292C742E6D61702E6F66662822746F7563687374617274222C632E746F7563687374617274292C74';
wwv_flow_imp.g_varchar2_table(262) := '2E6D61702E6F66662822746F756368656E64222C632E746F756368656E64292C742E636F6E7461696E65722E72656D6F76654576656E744C697374656E657228226D6F7573656F7574222C632E6D6F7573656F7574292C742E6F7074696F6E732E6B6579';
wwv_flow_imp.g_varchar2_table(263) := '62696E64696E6773262628742E636F6E7461696E65722E72656D6F76654576656E744C697374656E657228226B6579646F776E222C632E6B6579646F776E292C742E636F6E7461696E65722E72656D6F76654576656E744C697374656E657228226B6579';
wwv_flow_imp.g_varchar2_table(264) := '7570222C632E6B6579757029297D2C74726173682865297B6C2E74726173682865297D2C636F6D62696E65466561747572657328297B6C2E636F6D62696E65466561747572657328297D2C756E636F6D62696E65466561747572657328297B6C2E756E63';
wwv_flow_imp.g_varchar2_table(265) := '6F6D62696E65466561747572657328297D2C6765744D6F64653A28293D3E757D7D2861292C612E75693D66756E6374696F6E2874297B636F6E7374206F3D7B7D3B6C657420723D6E756C6C2C733D7B6D6F64653A6E756C6C2C666561747572653A6E756C';
wwv_flow_imp.g_varchar2_table(266) := '6C2C6D6F7573653A6E756C6C7D2C613D7B6D6F64653A6E756C6C2C666561747572653A6E756C6C2C6D6F7573653A6E756C6C7D3B66756E6374696F6E20632865297B613D4F626A6563742E61737369676E28612C65297D66756E6374696F6E207528297B';
wwv_flow_imp.g_varchar2_table(267) := '69662821742E636F6E7461696E65722972657475726E3B636F6E737420653D5B5D2C6F3D5B5D3B45652E666F72456163682828743D3E7B615B745D213D3D735B745D262628652E707573682860247B747D2D247B735B745D7D60292C6E756C6C213D3D61';
wwv_flow_imp.g_varchar2_table(268) := '5B745D26266F2E707573682860247B747D2D247B615B745D7D6029297D29292C652E6C656E6774683E302626742E636F6E7461696E65722E636C6173734C6973742E72656D6F7665282E2E2E65292C6F2E6C656E6774683E302626742E636F6E7461696E';
wwv_flow_imp.g_varchar2_table(269) := '65722E636C6173734C6973742E616464282E2E2E6F292C733D4F626A6563742E61737369676E28732C61297D66756E6374696F6E206C28742C6F3D7B7D297B636F6E7374206E3D646F63756D656E742E637265617465456C656D656E742822627574746F';
wwv_flow_imp.g_varchar2_table(270) := '6E22293B72657475726E206E2E636C6173734E616D653D60247B652E434F4E54524F4C5F425554544F4E7D20247B6F2E636C6173734E616D657D602C6E2E73657441747472696275746528227469746C65222C6F2E7469746C65292C6F2E636F6E746169';
wwv_flow_imp.g_varchar2_table(271) := '6E65722E617070656E644368696C64286E292C6E2E6164644576656E744C697374656E65722822636C69636B222C28653D3E7B696628652E70726576656E7444656661756C7428292C652E73746F7050726F7061676174696F6E28292C652E7461726765';
wwv_flow_imp.g_varchar2_table(272) := '743D3D3D722972657475726E206428292C766F6964206F2E6F6E4465616374697661746528293B702874292C6F2E6F6E416374697661746528297D292C2130292C6E7D66756E6374696F6E206428297B72262628722E636C6173734C6973742E72656D6F';
wwv_flow_imp.g_varchar2_table(273) := '766528652E4143544956455F425554544F4E292C723D6E756C6C297D66756E6374696F6E20702874297B6428293B636F6E7374206E3D6F5B745D3B6E26266E262622747261736822213D3D742626286E2E636C6173734C6973742E61646428652E414354';
wwv_flow_imp.g_varchar2_table(274) := '4956455F425554544F4E292C723D6E297D72657475726E7B736574416374697665427574746F6E3A702C71756575654D6170436C61737365733A632C7570646174654D6170436C61737365733A752C636C6561724D6170436C61737365733A66756E6374';
wwv_flow_imp.g_varchar2_table(275) := '696F6E28297B63287B6D6F64653A6E756C6C2C666561747572653A6E756C6C2C6D6F7573653A6E756C6C7D292C7528297D2C616464427574746F6E733A66756E6374696F6E28297B636F6E737420723D742E6F7074696F6E732E636F6E74726F6C732C73';
wwv_flow_imp.g_varchar2_table(276) := '3D646F63756D656E742E637265617465456C656D656E74282264697622293B72657475726E20732E636C6173734E616D653D60247B652E434F4E54524F4C5F47524F55507D20247B652E434F4E54524F4C5F424153457D602C723F28725B6E2E504F494E';
wwv_flow_imp.g_varchar2_table(277) := '545D2626286F5B6E2E504F494E545D3D6C286E2E504F494E542C7B636F6E7461696E65723A732C636C6173734E616D653A652E434F4E54524F4C5F425554544F4E5F504F494E542C7469746C653A224D61726B657220746F6F6C20222B28742E6F707469';
wwv_flow_imp.g_varchar2_table(278) := '6F6E732E6B657962696E64696E67733F22283129223A2222292C6F6E41637469766174653A28293D3E742E6576656E74732E6368616E67654D6F646528692E445241575F504F494E54292C6F6E446561637469766174653A28293D3E742E6576656E7473';
wwv_flow_imp.g_varchar2_table(279) := '2E747261736828297D29292C725B6E2E4C494E455D2626286F5B6E2E4C494E455D3D6C286E2E4C494E452C7B636F6E7461696E65723A732C636C6173734E616D653A652E434F4E54524F4C5F425554544F4E5F4C494E452C7469746C653A224C696E6553';
wwv_flow_imp.g_varchar2_table(280) := '7472696E6720746F6F6C20222B28742E6F7074696F6E732E6B657962696E64696E67733F22283229223A2222292C6F6E41637469766174653A28293D3E742E6576656E74732E6368616E67654D6F646528692E445241575F4C494E455F535452494E4729';
wwv_flow_imp.g_varchar2_table(281) := '2C6F6E446561637469766174653A28293D3E742E6576656E74732E747261736828297D29292C725B6E2E504F4C59474F4E5D2626286F5B6E2E504F4C59474F4E5D3D6C286E2E504F4C59474F4E2C7B636F6E7461696E65723A732C636C6173734E616D65';
wwv_flow_imp.g_varchar2_table(282) := '3A652E434F4E54524F4C5F425554544F4E5F504F4C59474F4E2C7469746C653A22506F6C79676F6E20746F6F6C20222B28742E6F7074696F6E732E6B657962696E64696E67733F22283329223A2222292C6F6E41637469766174653A28293D3E742E6576';
wwv_flow_imp.g_varchar2_table(283) := '656E74732E6368616E67654D6F646528692E445241575F504F4C59474F4E292C6F6E446561637469766174653A28293D3E742E6576656E74732E747261736828297D29292C722E74726173682626286F2E74726173683D6C28227472617368222C7B636F';
wwv_flow_imp.g_varchar2_table(284) := '6E7461696E65723A732C636C6173734E616D653A652E434F4E54524F4C5F425554544F4E5F54524153482C7469746C653A2244656C657465222C6F6E41637469766174653A28293D3E7B742E6576656E74732E747261736828297D7D29292C722E636F6D';
wwv_flow_imp.g_varchar2_table(285) := '62696E655F66656174757265732626286F2E636F6D62696E655F66656174757265733D6C2822636F6D62696E654665617475726573222C7B636F6E7461696E65723A732C636C6173734E616D653A652E434F4E54524F4C5F425554544F4E5F434F4D4249';
wwv_flow_imp.g_varchar2_table(286) := '4E455F46454154555245532C7469746C653A22436F6D62696E65222C6F6E41637469766174653A28293D3E7B742E6576656E74732E636F6D62696E65466561747572657328297D7D29292C722E756E636F6D62696E655F66656174757265732626286F2E';
wwv_flow_imp.g_varchar2_table(287) := '756E636F6D62696E655F66656174757265733D6C2822756E636F6D62696E654665617475726573222C7B636F6E7461696E65723A732C636C6173734E616D653A652E434F4E54524F4C5F425554544F4E5F554E434F4D42494E455F46454154555245532C';
wwv_flow_imp.g_varchar2_table(288) := '7469746C653A22556E636F6D62696E65222C6F6E41637469766174653A28293D3E7B742E6576656E74732E756E636F6D62696E65466561747572657328297D7D29292C73293A737D2C72656D6F7665427574746F6E733A66756E6374696F6E28297B4F62';
wwv_flow_imp.g_varchar2_table(289) := '6A6563742E6B657973286F292E666F72456163682828653D3E7B636F6E737420743D6F5B655D3B742E706172656E744E6F64652626742E706172656E744E6F64652E72656D6F76654368696C642874292C64656C657465206F5B655D7D29297D7D7D2861';
wwv_flow_imp.g_varchar2_table(290) := '292C612E636F6E7461696E65723D742E676574436F6E7461696E657228292C612E73746F72653D6E65772079652861292C633D612E75692E616464427574746F6E7328292C612E6F7074696F6E732E626F7853656C656374297B612E626F785A6F6F6D49';
wwv_flow_imp.g_varchar2_table(291) := '6E697469616C3D742E626F785A6F6F6D2E6973456E61626C656428292C742E626F785A6F6F6D2E64697361626C6528293B636F6E737420653D742E6472616750616E2E6973456E61626C656428293B742E6472616750616E2E64697361626C6528292C74';
wwv_flow_imp.g_varchar2_table(292) := '2E6472616750616E2E656E61626C6528292C657C7C742E6472616750616E2E64697361626C6528297D72657475726E20742E6C6F6164656428293F6C2E636F6E6E65637428293A28742E6F6E28226C6F6164222C6C2E636F6E6E656374292C753D736574';
wwv_flow_imp.g_varchar2_table(293) := '496E74657276616C282828293D3E7B742E6C6F61646564282926266C2E636F6E6E65637428297D292C313629292C612E6576656E74732E737461727428292C637D2C6164644C617965727328297B612E6D61702E616464536F7572636528742E434F4C44';
wwv_flow_imp.g_varchar2_table(294) := '2C7B646174613A7B747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A5B5D7D2C747970653A2267656F6A736F6E227D292C612E6D61702E616464536F7572636528742E484F542C7B646174613A7B747970653A722E';
wwv_flow_imp.g_varchar2_table(295) := '464541545552455F434F4C4C454354494F4E2C66656174757265733A5B5D7D2C747970653A2267656F6A736F6E227D292C612E6F7074696F6E732E7374796C65732E666F72456163682828653D3E7B612E6D61702E6164644C617965722865297D29292C';
wwv_flow_imp.g_varchar2_table(296) := '612E73746F72652E7365744469727479282130292C612E73746F72652E72656E64657228297D2C72656D6F76654C617965727328297B612E6F7074696F6E732E7374796C65732E666F72456163682828653D3E7B612E6D61702E6765744C617965722865';
wwv_flow_imp.g_varchar2_table(297) := '2E6964292626612E6D61702E72656D6F76654C6179657228652E6964297D29292C612E6D61702E676574536F7572636528742E434F4C44292626612E6D61702E72656D6F7665536F7572636528742E434F4C44292C612E6D61702E676574536F75726365';
wwv_flow_imp.g_varchar2_table(298) := '28742E484F54292626612E6D61702E72656D6F7665536F7572636528742E484F54297D7D3B72657475726E20612E73657475703D6C2C6C7D636F6E73742054653D2223336262326430222C5F653D2223666262303362222C76653D2223666666223B7661';
wwv_flow_imp.g_varchar2_table(299) := '722049653D5B7B69643A22676C2D647261772D706F6C79676F6E2D66696C6C222C747970653A2266696C6C222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C7061696E743A7B2266696C6C2D636F';
wwv_flow_imp.g_varchar2_table(300) := '6C6F72223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C5F652C54655D2C2266696C6C2D6F706163697479223A2E317D7D2C7B69643A22676C2D647261772D6C696E6573222C747970653A226C696E';
wwv_flow_imp.g_varchar2_table(301) := '65222C66696C7465723A5B22616E79222C5B223D3D222C222474797065222C224C696E65537472696E67225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C';
wwv_flow_imp.g_varchar2_table(302) := '696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C5F652C54655D2C226C696E652D646173686172726179';
wwv_flow_imp.g_varchar2_table(303) := '223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C5B2E322C325D2C5B322C305D5D2C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D706F696E742D6F75746572222C7479';
wwv_flow_imp.g_varchar2_table(304) := '70653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C2266656174757265225D5D2C7061696E743A7B22636972636C652D726164697573223A5B2263';
wwv_flow_imp.g_varchar2_table(305) := '617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C372C355D2C22636972636C652D636F6C6F72223A76657D7D2C7B69643A22676C2D647261772D706F696E742D696E6E6572222C747970653A22636972636C6522';
wwv_flow_imp.g_varchar2_table(306) := '2C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C2266656174757265225D5D2C7061696E743A7B22636972636C652D726164697573223A5B2263617365222C5B223D3D222C';
wwv_flow_imp.g_varchar2_table(307) := '5B22676574222C22616374697665225D2C2274727565225D2C352C335D2C22636972636C652D636F6C6F72223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C5F652C54655D7D7D2C7B69643A22676C';
wwv_flow_imp.g_varchar2_table(308) := '2D647261772D7665727465782D6F75746572222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C22766572746578225D2C5B22213D222C';
wwv_flow_imp.g_varchar2_table(309) := '226D6F6465222C2273696D706C655F73656C656374225D5D2C7061696E743A7B22636972636C652D726164697573223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274727565225D2C372C355D2C22636972636C652D';
wwv_flow_imp.g_varchar2_table(310) := '636F6C6F72223A76657D7D2C7B69643A22676C2D647261772D7665727465782D696E6E6572222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D6574';
wwv_flow_imp.g_varchar2_table(311) := '61222C22766572746578225D2C5B22213D222C226D6F6465222C2273696D706C655F73656C656374225D5D2C7061696E743A7B22636972636C652D726164697573223A5B2263617365222C5B223D3D222C5B22676574222C22616374697665225D2C2274';
wwv_flow_imp.g_varchar2_table(312) := '727565225D2C352C335D2C22636972636C652D636F6C6F72223A5F657D7D2C7B69643A22676C2D647261772D6D6964706F696E74222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D657461222C226D696470';
wwv_flow_imp.g_varchar2_table(313) := '6F696E74225D5D2C7061696E743A7B22636972636C652D726164697573223A332C22636972636C652D636F6C6F72223A5F657D7D5D3B66756E6374696F6E20536528652C74297B746869732E783D652C746869732E793D747D66756E6374696F6E204F65';
wwv_flow_imp.g_varchar2_table(314) := '28652C74297B636F6E7374206F3D742E676574426F756E64696E67436C69656E745265637428293B72657475726E206E657720536528652E636C69656E74582D6F2E6C6566742D28742E636C69656E744C6566747C7C30292C652E636C69656E74592D6F';
wwv_flow_imp.g_varchar2_table(315) := '2E746F702D28742E636C69656E74546F707C7C3029297D66756E6374696F6E204D6528652C742C6F2C6E297B72657475726E7B747970653A722E464541545552452C70726F706572746965733A7B6D6574613A632E5645525445582C706172656E743A65';
wwv_flow_imp.g_varchar2_table(316) := '2C636F6F72645F706174683A6F2C6163746976653A6E3F752E4143544956453A752E494E4143544956457D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F7264696E617465733A747D7D7D66756E6374696F6E204C6528652C742C6F';
wwv_flow_imp.g_varchar2_table(317) := '297B6966286E756C6C213D3D6529666F7228766172206E2C722C692C732C612C632C752C6C2C643D302C703D302C683D652E747970652C663D2246656174757265436F6C6C656374696F6E223D3D3D682C673D2246656174757265223D3D3D682C793D66';
wwv_flow_imp.g_varchar2_table(318) := '3F652E66656174757265732E6C656E6774683A312C6D3D303B6D3C793B6D2B2B297B613D286C3D212128753D663F652E66656174757265735B6D5D2E67656F6D657472793A673F652E67656F6D657472793A652926262247656F6D65747279436F6C6C65';
wwv_flow_imp.g_varchar2_table(319) := '6374696F6E223D3D3D752E74797065293F752E67656F6D6574726965732E6C656E6774683A313B666F722876617220453D303B453C613B452B2B297B76617220433D302C543D303B6966286E756C6C213D3D28733D6C3F752E67656F6D6574726965735B';
wwv_flow_imp.g_varchar2_table(320) := '455D3A7529297B633D732E636F6F7264696E617465733B766172205F3D732E747970653B73776974636828643D302C5F297B63617365206E756C6C3A627265616B3B6361736522506F696E74223A69662821313D3D3D7428632C702C6D2C432C54292972';
wwv_flow_imp.g_varchar2_table(321) := '657475726E21313B702B2B2C432B2B3B627265616B3B63617365224C696E65537472696E67223A63617365224D756C7469506F696E74223A666F72286E3D303B6E3C632E6C656E6774683B6E2B2B297B69662821313D3D3D7428635B6E5D2C702C6D2C43';
wwv_flow_imp.g_varchar2_table(322) := '2C54292972657475726E21313B702B2B2C224D756C7469506F696E74223D3D3D5F2626432B2B7D224C696E65537472696E67223D3D3D5F2626432B2B3B627265616B3B6361736522506F6C79676F6E223A63617365224D756C74694C696E65537472696E';
wwv_flow_imp.g_varchar2_table(323) := '67223A666F72286E3D303B6E3C632E6C656E6774683B6E2B2B297B666F7228723D303B723C635B6E5D2E6C656E6774682D643B722B2B297B69662821313D3D3D7428635B6E5D5B725D2C702C6D2C432C54292972657475726E21313B702B2B7D224D756C';
wwv_flow_imp.g_varchar2_table(324) := '74694C696E65537472696E67223D3D3D5F2626432B2B2C22506F6C79676F6E223D3D3D5F2626542B2B7D22506F6C79676F6E223D3D3D5F2626432B2B3B627265616B3B63617365224D756C7469506F6C79676F6E223A666F72286E3D303B6E3C632E6C65';
wwv_flow_imp.g_varchar2_table(325) := '6E6774683B6E2B2B297B666F7228543D302C723D303B723C635B6E5D2E6C656E6774683B722B2B297B666F7228693D303B693C635B6E5D5B725D2E6C656E6774682D643B692B2B297B69662821313D3D3D7428635B6E5D5B725D5B695D2C702C6D2C432C';
wwv_flow_imp.g_varchar2_table(326) := '54292972657475726E21313B702B2B7D542B2B7D432B2B7D627265616B3B636173652247656F6D65747279436F6C6C656374696F6E223A666F72286E3D303B6E3C732E67656F6D6574726965732E6C656E6774683B6E2B2B2969662821313D3D3D4C6528';
wwv_flow_imp.g_varchar2_table(327) := '732E67656F6D6574726965735B6E5D2C74292972657475726E21313B627265616B3B64656661756C743A7468726F77206E6577204572726F722822556E6B6E6F776E2047656F6D65747279205479706522297D7D7D7D7D66756E6374696F6E204E652865';
wwv_flow_imp.g_varchar2_table(328) := '297B636F6E737420743D7B747970653A2246656174757265227D3B72657475726E204F626A6563742E6B6579732865292E666F724561636828286F3D3E7B737769746368286F297B636173652274797065223A636173652270726F70657274696573223A';
wwv_flow_imp.g_varchar2_table(329) := '636173652267656F6D65747279223A72657475726E3B64656661756C743A745B6F5D3D655B6F5D7D7D29292C742E70726F706572746965733D626528652E70726F70657274696573292C6E756C6C3D3D652E67656F6D657472793F742E67656F6D657472';
wwv_flow_imp.g_varchar2_table(330) := '793D6E756C6C3A742E67656F6D657472793D506528652E67656F6D65747279292C747D66756E6374696F6E2062652865297B636F6E737420743D7B7D3B72657475726E20653F284F626A6563742E6B6579732865292E666F724561636828286F3D3E7B63';
wwv_flow_imp.g_varchar2_table(331) := '6F6E7374206E3D655B6F5D3B226F626A656374223D3D747970656F66206E3F6E756C6C3D3D3D6E3F745B6F5D3D6E756C6C3A41727261792E69734172726179286E293F745B6F5D3D6E2E6D61702828653D3E6529293A745B6F5D3D6265286E293A745B6F';
wwv_flow_imp.g_varchar2_table(332) := '5D3D6E7D29292C74293A747D66756E6374696F6E2050652865297B636F6E737420743D7B747970653A652E747970657D3B72657475726E20652E62626F78262628742E62626F783D652E62626F78292C2247656F6D65747279436F6C6C656374696F6E22';
wwv_flow_imp.g_varchar2_table(333) := '3D3D3D652E747970653F28742E67656F6D6574726965733D652E67656F6D6574726965732E6D61702828653D3E506528652929292C74293A28742E636F6F7264696E617465733D786528652E636F6F7264696E61746573292C74297D66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(334) := '2078652865297B636F6E737420743D653B72657475726E226F626A65637422213D747970656F6620745B305D3F742E736C69636528293A742E6D61702828653D3E786528652929297D66756E6374696F6E20416528652C743D7B7D297B72657475726E20';
wwv_flow_imp.g_varchar2_table(335) := '466528652C226D65726361746F72222C74297D66756E6374696F6E20466528652C742C6F3D7B7D297B766172206E2C723D286F3D6F7C7C7B7D292E6D75746174653B6966282165297468726F77206E6577204572726F72282267656F6A736F6E20697320';
wwv_flow_imp.g_varchar2_table(336) := '726571756972656422293B72657475726E2141727261792E697341727261792865297C7C286E3D655B305D2C69734E614E286E297C7C6E756C6C3D3D3D6E7C7C41727261792E69734172726179286E29293F282130213D3D72262628653D66756E637469';
wwv_flow_imp.g_varchar2_table(337) := '6F6E2865297B6966282165297468726F77206E6577204572726F72282267656F6A736F6E20697320726571756972656422293B73776974636828652E74797065297B636173652246656174757265223A72657475726E204E652865293B63617365224665';
wwv_flow_imp.g_varchar2_table(338) := '6174757265436F6C6C656374696F6E223A72657475726E2066756E6374696F6E2865297B636F6E737420743D7B747970653A2246656174757265436F6C6C656374696F6E227D3B72657475726E204F626A6563742E6B6579732865292E666F7245616368';
wwv_flow_imp.g_varchar2_table(339) := '28286F3D3E7B737769746368286F297B636173652274797065223A63617365226665617475726573223A72657475726E3B64656661756C743A745B6F5D3D655B6F5D7D7D29292C742E66656174757265733D652E66656174757265732E6D61702828653D';
wwv_flow_imp.g_varchar2_table(340) := '3E4E6528652929292C747D2865293B6361736522506F696E74223A63617365224C696E65537472696E67223A6361736522506F6C79676F6E223A63617365224D756C7469506F696E74223A63617365224D756C74694C696E65537472696E67223A636173';
wwv_flow_imp.g_varchar2_table(341) := '65224D756C7469506F6C79676F6E223A636173652247656F6D65747279436F6C6C656374696F6E223A72657475726E2050652865293B64656661756C743A7468726F77206E6577204572726F722822756E6B6E6F776E2047656F4A534F4E207479706522';
wwv_flow_imp.g_varchar2_table(342) := '297D7D286529292C4C6528652C2866756E6374696F6E2865297B766172206F3D226D65726361746F72223D3D3D743F77652865293A52652865293B655B305D3D6F5B305D2C655B315D3D6F5B315D7D2929293A653D226D65726361746F72223D3D3D743F';
wwv_flow_imp.g_varchar2_table(343) := '77652865293A52652865292C657D66756E6374696F6E2077652865297B76617220742C6F3D4D6174682E50492F3138302C6E3D363337383133372C723D32303033373530382E3334323738393234342C693D5B6E2A284D6174682E61627328655B305D29';
wwv_flow_imp.g_varchar2_table(344) := '3C3D3138303F655B305D3A655B305D2D3336302A2828743D655B305D293C303F2D313A743E303F313A3029292A6F2C6E2A4D6174682E6C6F67284D6174682E74616E282E32352A4D6174682E50492B2E352A655B315D2A6F29295D3B72657475726E2069';
wwv_flow_imp.g_varchar2_table(345) := '5B305D3E72262628695B305D3D72292C695B305D3C2D72262628695B305D3D2D72292C695B315D3E72262628695B315D3D72292C695B315D3C2D72262628695B315D3D2D72292C697D66756E6374696F6E2052652865297B76617220743D3138302F4D61';
wwv_flow_imp.g_varchar2_table(346) := '74682E50492C6F3D363337383133373B72657475726E5B655B305D2A742F6F2C282E352A4D6174682E50492D322A4D6174682E6174616E284D6174682E657870282D655B315D2F6F2929292A745D7D66756E6374696F6E20446528652C742C6F297B636F';
wwv_flow_imp.g_varchar2_table(347) := '6E7374206E3D742E67656F6D657472792E636F6F7264696E617465732C693D6F2E67656F6D657472792E636F6F7264696E617465733B6966286E5B315D3E707C7C6E5B315D3C647C7C695B315D3E707C7C695B315D3C642972657475726E206E756C6C3B';
wwv_flow_imp.g_varchar2_table(348) := '636F6E737420733D4165286E292C613D41652869292C753D653D3E4E756D62657228652E746F4669786564283829292C6C3D28652C74293D3E28652B74292F322C683D66756E6374696F6E28652C743D7B7D297B72657475726E20466528652C22776773';
wwv_flow_imp.g_varchar2_table(349) := '3834222C74297D285B6C28735B305D2C615B305D292C6C28735B315D2C615B315D295D292C663D5B7528685B305D292C7528685B315D295D3B72657475726E7B747970653A722E464541545552452C70726F706572746965733A7B6D6574613A632E4D49';
wwv_flow_imp.g_varchar2_table(350) := '44504F494E542C706172656E743A652C6C6E673A665B305D2C6C61743A665B315D2C636F6F72645F706174683A6F2E70726F706572746965732E636F6F72645F706174687D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F7264696E';
wwv_flow_imp.g_varchar2_table(351) := '617465733A667D7D7D66756E6374696F6E20556528652C743D7B7D2C6F3D6E756C6C297B636F6E73747B747970653A6E2C636F6F7264696E617465733A697D3D652E67656F6D657472792C733D652E70726F706572746965732626652E70726F70657274';
wwv_flow_imp.g_varchar2_table(352) := '6965732E69643B6C657420613D5B5D3B66756E6374696F6E206328652C6F297B6C6574206E3D22222C723D6E756C6C3B652E666F7245616368282828652C69293D3E7B636F6E737420633D6E756C6C213D6F3F60247B6F7D2E247B697D603A537472696E';
wwv_flow_imp.g_varchar2_table(353) := '672869292C6C3D4D6528732C652C632C75286329293B696628742E6D6964706F696E7473262672297B636F6E737420653D446528732C722C6C293B652626612E707573682865297D723D6C3B636F6E737420643D4A534F4E2E737472696E676966792865';
wwv_flow_imp.g_varchar2_table(354) := '293B6E213D3D642626612E70757368286C292C303D3D3D692626286E3D64297D29297D66756E6374696F6E20752865297B72657475726E2121742E73656C6563746564506174687326262D31213D3D742E73656C656374656450617468732E696E646578';
wwv_flow_imp.g_varchar2_table(355) := '4F662865297D72657475726E206E3D3D3D722E504F494E543F612E70757368284D6528732C692C6F2C75286F2929293A6E3D3D3D722E504F4C59474F4E3F692E666F7245616368282828652C74293D3E7B6328652C6E756C6C213D3D6F3F60247B6F7D2E';
wwv_flow_imp.g_varchar2_table(356) := '247B747D603A537472696E67287429297D29293A6E3D3D3D722E4C494E455F535452494E473F6328692C6F293A303D3D3D6E2E696E6465784F6628722E4D554C54495F50524546495829262666756E6374696F6E28297B636F6E7374206F3D6E2E726570';
wwv_flow_imp.g_varchar2_table(357) := '6C61636528722E4D554C54495F5052454649582C2222293B692E666F72456163682828286E2C69293D3E7B636F6E737420733D7B747970653A722E464541545552452C70726F706572746965733A652E70726F706572746965732C67656F6D657472793A';
wwv_flow_imp.g_varchar2_table(358) := '7B747970653A6F2C636F6F7264696E617465733A6E7D7D3B613D612E636F6E63617428556528732C742C6929297D29297D28292C617D53652E70726F746F747970653D7B636C6F6E6528297B72657475726E206E657720536528746869732E782C746869';
wwv_flow_imp.g_varchar2_table(359) := '732E79297D2C6164642865297B72657475726E20746869732E636C6F6E6528292E5F6164642865297D2C7375622865297B72657475726E20746869732E636C6F6E6528292E5F7375622865297D2C6D756C744279506F696E742865297B72657475726E20';
wwv_flow_imp.g_varchar2_table(360) := '746869732E636C6F6E6528292E5F6D756C744279506F696E742865297D2C6469764279506F696E742865297B72657475726E20746869732E636C6F6E6528292E5F6469764279506F696E742865297D2C6D756C742865297B72657475726E20746869732E';
wwv_flow_imp.g_varchar2_table(361) := '636C6F6E6528292E5F6D756C742865297D2C6469762865297B72657475726E20746869732E636C6F6E6528292E5F6469762865297D2C726F746174652865297B72657475726E20746869732E636C6F6E6528292E5F726F746174652865297D2C726F7461';
wwv_flow_imp.g_varchar2_table(362) := '746541726F756E6428652C74297B72657475726E20746869732E636C6F6E6528292E5F726F7461746541726F756E6428652C74297D2C6D61744D756C742865297B72657475726E20746869732E636C6F6E6528292E5F6D61744D756C742865297D2C756E';
wwv_flow_imp.g_varchar2_table(363) := '697428297B72657475726E20746869732E636C6F6E6528292E5F756E697428297D2C7065727028297B72657475726E20746869732E636C6F6E6528292E5F7065727028297D2C726F756E6428297B72657475726E20746869732E636C6F6E6528292E5F72';
wwv_flow_imp.g_varchar2_table(364) := '6F756E6428297D2C6D616728297B72657475726E204D6174682E7371727428746869732E782A746869732E782B746869732E792A746869732E79297D2C657175616C732865297B72657475726E20746869732E783D3D3D652E782626746869732E793D3D';
wwv_flow_imp.g_varchar2_table(365) := '3D652E797D2C646973742865297B72657475726E204D6174682E7371727428746869732E64697374537172286529297D2C646973745371722865297B636F6E737420743D652E782D746869732E782C6F3D652E792D746869732E793B72657475726E2074';
wwv_flow_imp.g_varchar2_table(366) := '2A742B6F2A6F7D2C616E676C6528297B72657475726E204D6174682E6174616E3228746869732E792C746869732E78297D2C616E676C65546F2865297B72657475726E204D6174682E6174616E3228746869732E792D652E792C746869732E782D652E78';
wwv_flow_imp.g_varchar2_table(367) := '297D2C616E676C65576974682865297B72657475726E20746869732E616E676C655769746853657028652E782C652E79297D2C616E676C655769746853657028652C74297B72657475726E204D6174682E6174616E3228746869732E782A742D74686973';
wwv_flow_imp.g_varchar2_table(368) := '2E792A652C746869732E782A652B746869732E792A74297D2C5F6D61744D756C742865297B636F6E737420743D655B305D2A746869732E782B655B315D2A746869732E792C6F3D655B325D2A746869732E782B655B335D2A746869732E793B7265747572';
wwv_flow_imp.g_varchar2_table(369) := '6E20746869732E783D742C746869732E793D6F2C746869737D2C5F6164642865297B72657475726E20746869732E782B3D652E782C746869732E792B3D652E792C746869737D2C5F7375622865297B72657475726E20746869732E782D3D652E782C7468';
wwv_flow_imp.g_varchar2_table(370) := '69732E792D3D652E792C746869737D2C5F6D756C742865297B72657475726E20746869732E782A3D652C746869732E792A3D652C746869737D2C5F6469762865297B72657475726E20746869732E782F3D652C746869732E792F3D652C746869737D2C5F';
wwv_flow_imp.g_varchar2_table(371) := '6D756C744279506F696E742865297B72657475726E20746869732E782A3D652E782C746869732E792A3D652E792C746869737D2C5F6469764279506F696E742865297B72657475726E20746869732E782F3D652E782C746869732E792F3D652E792C7468';
wwv_flow_imp.g_varchar2_table(372) := '69737D2C5F756E697428297B72657475726E20746869732E5F64697628746869732E6D61672829292C746869737D2C5F7065727028297B636F6E737420653D746869732E793B72657475726E20746869732E793D746869732E782C746869732E783D2D65';
wwv_flow_imp.g_varchar2_table(373) := '2C746869737D2C5F726F746174652865297B636F6E737420743D4D6174682E636F732865292C6F3D4D6174682E73696E2865292C6E3D742A746869732E782D6F2A746869732E792C723D6F2A746869732E782B742A746869732E793B72657475726E2074';
wwv_flow_imp.g_varchar2_table(374) := '6869732E783D6E2C746869732E793D722C746869737D2C5F726F7461746541726F756E6428652C74297B636F6E7374206F3D4D6174682E636F732865292C6E3D4D6174682E73696E2865292C723D742E782B6F2A28746869732E782D742E78292D6E2A28';
wwv_flow_imp.g_varchar2_table(375) := '746869732E792D742E79292C693D742E792B6E2A28746869732E782D742E78292B6F2A28746869732E792D742E79293B72657475726E20746869732E783D722C746869732E793D692C746869737D2C5F726F756E6428297B72657475726E20746869732E';
wwv_flow_imp.g_varchar2_table(376) := '783D4D6174682E726F756E6428746869732E78292C746869732E793D4D6174682E726F756E6428746869732E79292C746869737D2C636F6E7374727563746F723A53657D2C53652E636F6E766572743D66756E6374696F6E2865297B6966286520696E73';
wwv_flow_imp.g_varchar2_table(377) := '74616E63656F662053652972657475726E20653B69662841727261792E697341727261792865292972657475726E206E6577205365282B655B305D2C2B655B315D293B696628766F69642030213D3D652E782626766F69642030213D3D652E7929726574';
wwv_flow_imp.g_varchar2_table(378) := '75726E206E6577205365282B652E782C2B652E79293B7468726F77206E6577204572726F7228224578706563746564205B782C20795D206F72207B782C20797D20706F696E7420666F726D617422297D3B766172206B653D7B656E61626C652865297B73';
wwv_flow_imp.g_varchar2_table(379) := '657454696D656F7574282828293D3E7B652E6D61702626652E6D61702E646F75626C65436C69636B5A6F6F6D2626652E5F6374782626652E5F6374782E73746F72652626652E5F6374782E73746F72652E676574496E697469616C436F6E66696756616C';
wwv_flow_imp.g_varchar2_table(380) := '75652626652E5F6374782E73746F72652E676574496E697469616C436F6E66696756616C75652822646F75626C65436C69636B5A6F6F6D22292626652E6D61702E646F75626C65436C69636B5A6F6F6D2E656E61626C6528297D292C30297D2C64697361';
wwv_flow_imp.g_varchar2_table(381) := '626C652865297B73657454696D656F7574282828293D3E7B652E6D61702626652E6D61702E646F75626C65436C69636B5A6F6F6D2626652E6D61702E646F75626C65436C69636B5A6F6F6D2E64697361626C6528297D292C30297D7D3B636F6E73747B4C';
wwv_flow_imp.g_varchar2_table(382) := '41545F4D494E3A56652C4C41545F4D41583A47652C4C41545F52454E44455245445F4D494E3A42652C4C41545F52454E44455245445F4D41583A6A652C4C4E475F4D494E3A4A652C4C4E475F4D41583A24657D3D683B66756E6374696F6E20596528652C';
wwv_flow_imp.g_varchar2_table(383) := '74297B6C6574206F3D56652C6E3D47652C723D56652C693D47652C733D24652C613D4A653B652E666F72456163682828653D3E7B636F6E737420743D66756E6374696F6E2865297B636F6E737420743D7B506F696E743A302C4C696E65537472696E673A';
wwv_flow_imp.g_varchar2_table(384) := '312C506F6C79676F6E3A322C4D756C7469506F696E743A312C4D756C74694C696E65537472696E673A322C4D756C7469506F6C79676F6E3A337D5B652E67656F6D657472792E747970655D2C6F3D5B652E67656F6D657472792E636F6F7264696E617465';
wwv_flow_imp.g_varchar2_table(385) := '735D2E666C61742874292C6E3D6F2E6D61702828653D3E655B305D29292C723D6F2E6D61702828653D3E655B315D29292C693D653D3E4D6174682E6D696E2E6170706C79286E756C6C2C65292C733D653D3E4D6174682E6D61782E6170706C79286E756C';
wwv_flow_imp.g_varchar2_table(386) := '6C2C65293B72657475726E5B69286E292C692872292C73286E292C732872295D7D2865292C633D745B315D2C753D745B335D2C6C3D745B305D2C643D745B325D3B633E6F2626286F3D63292C753C6E2626286E3D75292C753E72262628723D75292C633C';
wwv_flow_imp.g_varchar2_table(387) := '69262628693D63292C6C3C73262628733D6C292C643E61262628613D64297D29293B636F6E737420633D743B72657475726E206F2B632E6C61743E6A65262628632E6C61743D6A652D6F292C722B632E6C61743E4765262628632E6C61743D47652D7229';
wwv_flow_imp.g_varchar2_table(388) := '2C6E2B632E6C61743C4265262628632E6C61743D42652D6E292C692B632E6C61743C5665262628632E6C61743D56652D69292C732B632E6C6E673C3D4A65262628632E6C6E672B3D3336302A4D6174682E6365696C284D6174682E61627328632E6C6E67';
wwv_flow_imp.g_varchar2_table(389) := '292F33363029292C612B632E6C6E673E3D2465262628632E6C6E672D3D3336302A4D6174682E6365696C284D6174682E61627328632E6C6E67292F33363029292C637D66756E6374696F6E20486528652C74297B636F6E7374206F3D596528652E6D6170';
wwv_flow_imp.g_varchar2_table(390) := '2828653D3E652E746F47656F4A534F4E282929292C74293B652E666F72456163682828653D3E7B636F6E737420743D652E676574436F6F7264696E6174657328292C6E3D653D3E7B636F6E737420743D7B6C6E673A655B305D2B6F2E6C6E672C6C61743A';
wwv_flow_imp.g_varchar2_table(391) := '655B315D2B6F2E6C61747D3B72657475726E5B742E6C6E672C742E6C61745D7D2C693D653D3E652E6D61702828653D3E6E28652929293B6C657420733B652E747970653D3D3D722E504F494E543F733D6E2874293A652E747970653D3D3D722E4C494E45';
wwv_flow_imp.g_varchar2_table(392) := '5F535452494E477C7C652E747970653D3D3D722E4D554C54495F504F494E543F733D742E6D6170286E293A652E747970653D3D3D722E504F4C59474F4E7C7C652E747970653D3D3D722E4D554C54495F4C494E455F535452494E473F733D742E6D617028';
wwv_flow_imp.g_varchar2_table(393) := '69293A652E747970653D3D3D722E4D554C54495F504F4C59474F4E262628733D742E6D61702828653D3E652E6D61702828653D3E6928652929292929292C652E696E636F6D696E67436F6F7264732873297D29297D636F6E73742058653D7B6F6E536574';
wwv_flow_imp.g_varchar2_table(394) := '75703A66756E6374696F6E2865297B636F6E737420743D7B647261674D6F76654C6F636174696F6E3A6E756C6C2C626F7853656C65637453746172744C6F636174696F6E3A6E756C6C2C626F7853656C656374456C656D656E743A766F696420302C626F';
wwv_flow_imp.g_varchar2_table(395) := '7853656C656374696E673A21312C63616E426F7853656C6563743A21312C647261674D6F76696E673A21312C63616E447261674D6F76653A21312C696E697469616C4472616750616E53746174653A746869732E6D61702E6472616750616E2E6973456E';
wwv_flow_imp.g_varchar2_table(396) := '61626C656428292C696E697469616C6C7953656C6563746564466561747572654964733A652E666561747572654964737C7C5B5D7D3B72657475726E20746869732E73657453656C656374656428742E696E697469616C6C7953656C6563746564466561';
wwv_flow_imp.g_varchar2_table(397) := '747572654964732E66696C7465722828653D3E766F69642030213D3D746869732E676574466561747572652865292929292C746869732E66697265416374696F6E61626C6528292C746869732E736574416374696F6E61626C655374617465287B636F6D';
wwv_flow_imp.g_varchar2_table(398) := '62696E6546656174757265733A21302C756E636F6D62696E6546656174757265733A21302C74726173683A21307D292C747D2C666972655570646174653A66756E6374696F6E28297B746869732E6669726528732E5550444154452C7B616374696F6E3A';
wwv_flow_imp.g_varchar2_table(399) := '612E4D4F56452C66656174757265733A746869732E67657453656C656374656428292E6D61702828653D3E652E746F47656F4A534F4E282929297D297D2C66697265416374696F6E61626C653A66756E6374696F6E28297B636F6E737420653D74686973';
wwv_flow_imp.g_varchar2_table(400) := '2E67657453656C656374656428292C743D652E66696C7465722828653D3E746869732E6973496E7374616E63654F6628224D756C746946656174757265222C652929293B6C6574206F3D21313B696628652E6C656E6774683E31297B6F3D21303B636F6E';
wwv_flow_imp.g_varchar2_table(401) := '737420743D655B305D2E747970652E7265706C61636528224D756C7469222C2222293B652E666F72456163682828653D3E7B652E747970652E7265706C61636528224D756C7469222C222229213D3D742626286F3D2131297D29297D636F6E7374206E3D';
wwv_flow_imp.g_varchar2_table(402) := '742E6C656E6774683E302C723D652E6C656E6774683E303B746869732E736574416374696F6E61626C655374617465287B636F6D62696E6546656174757265733A6F2C756E636F6D62696E6546656174757265733A6E2C74726173683A727D297D2C6765';
wwv_flow_imp.g_varchar2_table(403) := '74556E697175654964733A66756E6374696F6E2865297B72657475726E20652E6C656E6774683F652E6D61702828653D3E652E70726F706572746965732E696429292E66696C7465722828653D3E766F69642030213D3D6529292E726564756365282828';
wwv_flow_imp.g_varchar2_table(404) := '652C74293D3E28652E6164642874292C6529292C6E6577206A292E76616C75657328293A5B5D7D2C73746F70457874656E646564496E746572616374696F6E733A66756E6374696F6E2865297B652E626F7853656C656374456C656D656E74262628652E';
wwv_flow_imp.g_varchar2_table(405) := '626F7853656C656374456C656D656E742E706172656E744E6F64652626652E626F7853656C656374456C656D656E742E706172656E744E6F64652E72656D6F76654368696C6428652E626F7853656C656374456C656D656E74292C652E626F7853656C65';
wwv_flow_imp.g_varchar2_table(406) := '6374456C656D656E743D6E756C6C292C28652E63616E447261674D6F76657C7C652E63616E426F7853656C65637429262621303D3D3D652E696E697469616C4472616750616E53746174652626746869732E6D61702E6472616750616E2E656E61626C65';
wwv_flow_imp.g_varchar2_table(407) := '28292C652E626F7853656C656374696E673D21312C652E63616E426F7853656C6563743D21312C652E647261674D6F76696E673D21312C652E63616E447261674D6F76653D21317D2C6F6E53746F703A66756E6374696F6E28297B6B652E656E61626C65';
wwv_flow_imp.g_varchar2_table(408) := '2874686973297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28652C74297B72657475726E20432874292626652E647261674D6F76696E672626746869732E6669726555706461746528292C746869732E73746F70457874656E646564496E7465';
wwv_flow_imp.g_varchar2_table(409) := '72616374696F6E732865292C21307D2C6F6E4D6F7573654F75743A66756E6374696F6E2865297B72657475726E21652E647261674D6F76696E677C7C746869732E6669726555706461746528297D7D3B58652E6F6E5461703D58652E6F6E436C69636B3D';
wwv_flow_imp.g_varchar2_table(410) := '66756E6374696F6E28652C74297B72657475726E20452874293F746869732E636C69636B416E79776865726528652C74293A6628632E564552544558292874293F746869732E636C69636B4F6E56657274657828652C74293A432874293F746869732E63';
wwv_flow_imp.g_varchar2_table(411) := '6C69636B4F6E4665617475726528652C74293A766F696420307D2C58652E636C69636B416E7977686572653D66756E6374696F6E2865297B636F6E737420743D746869732E67657453656C656374656449647328293B742E6C656E677468262628746869';
wwv_flow_imp.g_varchar2_table(412) := '732E636C65617253656C6563746564466561747572657328292C742E666F72456163682828653D3E746869732E646F52656E6465722865292929292C6B652E656E61626C652874686973292C746869732E73746F70457874656E646564496E7465726163';
wwv_flow_imp.g_varchar2_table(413) := '74696F6E732865297D2C58652E636C69636B4F6E5665727465783D66756E6374696F6E28652C74297B746869732E6368616E67654D6F646528692E4449524543545F53454C4543542C7B6665617475726549643A742E666561747572655461726765742E';
wwv_flow_imp.g_varchar2_table(414) := '70726F706572746965732E706172656E742C636F6F7264506174683A742E666561747572655461726765742E70726F706572746965732E636F6F72645F706174682C7374617274506F733A742E6C6E674C61747D292C746869732E757064617465554943';
wwv_flow_imp.g_varchar2_table(415) := '6C6173736573287B6D6F7573653A6F2E4D4F56457D297D2C58652E73746172744F6E416374697665466561747572653D66756E6374696F6E28652C74297B746869732E73746F70457874656E646564496E746572616374696F6E732865292C746869732E';
wwv_flow_imp.g_varchar2_table(416) := '6D61702E6472616750616E2E64697361626C6528292C746869732E646F52656E64657228742E666561747572655461726765742E70726F706572746965732E6964292C652E63616E447261674D6F76653D21302C652E647261674D6F76654C6F63617469';
wwv_flow_imp.g_varchar2_table(417) := '6F6E3D742E6C6E674C61747D2C58652E636C69636B4F6E466561747572653D66756E6374696F6E28652C74297B6B652E64697361626C652874686973292C746869732E73746F70457874656E646564496E746572616374696F6E732865293B636F6E7374';
wwv_flow_imp.g_varchar2_table(418) := '206E3D5F2874292C733D746869732E67657453656C656374656449647328292C613D742E666561747572655461726765742E70726F706572746965732E69642C633D746869732E697353656C65637465642861293B696628216E2626632626746869732E';
wwv_flow_imp.g_varchar2_table(419) := '676574466561747572652861292E74797065213D3D722E504F494E542972657475726E20746869732E6368616E67654D6F646528692E4449524543545F53454C4543542C7B6665617475726549643A617D293B6326266E3F28746869732E646573656C65';
wwv_flow_imp.g_varchar2_table(420) := '63742861292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E504F494E5445527D292C313D3D3D732E6C656E67746826266B652E656E61626C65287468697329293A216326266E3F28746869732E73656C6563742861292C74';
wwv_flow_imp.g_varchar2_table(421) := '6869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D29293A637C7C6E7C7C28732E666F72456163682828653D3E746869732E646F52656E64657228652929292C746869732E73657453656C65637465642861292C746869';
wwv_flow_imp.g_varchar2_table(422) := '732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D29292C746869732E646F52656E6465722861297D2C58652E6F6E4D6F757365446F776E3D66756E6374696F6E28652C74297B72657475726E20652E696E697469616C4472';
wwv_flow_imp.g_varchar2_table(423) := '616750616E53746174653D746869732E6D61702E6472616750616E2E6973456E61626C656428292C792874293F746869732E73746172744F6E4163746976654665617475726528652C74293A746869732E64726177436F6E6669672E626F7853656C6563';
wwv_flow_imp.g_varchar2_table(424) := '742626672874293F746869732E7374617274426F7853656C65637428652C74293A766F696420307D2C58652E7374617274426F7853656C6563743D66756E6374696F6E28652C74297B746869732E73746F70457874656E646564496E746572616374696F';
wwv_flow_imp.g_varchar2_table(425) := '6E732865292C746869732E6D61702E6472616750616E2E64697361626C6528292C652E626F7853656C65637453746172744C6F636174696F6E3D4F6528742E6F726967696E616C4576656E742C746869732E6D61702E676574436F6E7461696E65722829';
wwv_flow_imp.g_varchar2_table(426) := '292C652E63616E426F7853656C6563743D21307D2C58652E6F6E546F75636853746172743D66756E6374696F6E28652C74297B696628792874292972657475726E20746869732E73746172744F6E4163746976654665617475726528652C74297D2C5865';
wwv_flow_imp.g_varchar2_table(427) := '2E6F6E447261673D66756E6374696F6E28652C74297B72657475726E20652E63616E447261674D6F76653F746869732E647261674D6F766528652C74293A746869732E64726177436F6E6669672E626F7853656C6563742626652E63616E426F7853656C';
wwv_flow_imp.g_varchar2_table(428) := '6563743F746869732E7768696C65426F7853656C65637428652C74293A766F696420307D2C58652E7768696C65426F7853656C6563743D66756E6374696F6E28742C6E297B742E626F7853656C656374696E673D21302C746869732E7570646174655549';
wwv_flow_imp.g_varchar2_table(429) := '436C6173736573287B6D6F7573653A6F2E4144447D292C742E626F7853656C656374456C656D656E747C7C28742E626F7853656C656374456C656D656E743D646F63756D656E742E637265617465456C656D656E74282264697622292C742E626F785365';
wwv_flow_imp.g_varchar2_table(430) := '6C656374456C656D656E742E636C6173734C6973742E61646428652E424F585F53454C454354292C746869732E6D61702E676574436F6E7461696E657228292E617070656E644368696C6428742E626F7853656C656374456C656D656E7429293B636F6E';
wwv_flow_imp.g_varchar2_table(431) := '737420723D4F65286E2E6F726967696E616C4576656E742C746869732E6D61702E676574436F6E7461696E65722829292C693D4D6174682E6D696E28742E626F7853656C65637453746172744C6F636174696F6E2E782C722E78292C733D4D6174682E6D';
wwv_flow_imp.g_varchar2_table(432) := '617828742E626F7853656C65637453746172744C6F636174696F6E2E782C722E78292C613D4D6174682E6D696E28742E626F7853656C65637453746172744C6F636174696F6E2E792C722E79292C633D4D6174682E6D617828742E626F7853656C656374';
wwv_flow_imp.g_varchar2_table(433) := '53746172744C6F636174696F6E2E792C722E79292C753D607472616E736C61746528247B697D70782C20247B617D707829603B742E626F7853656C656374456C656D656E742E7374796C652E7472616E73666F726D3D752C742E626F7853656C65637445';
wwv_flow_imp.g_varchar2_table(434) := '6C656D656E742E7374796C652E5765626B69745472616E73666F726D3D752C742E626F7853656C656374456C656D656E742E7374796C652E77696474683D732D692B227078222C742E626F7853656C656374456C656D656E742E7374796C652E68656967';
wwv_flow_imp.g_varchar2_table(435) := '68743D632D612B227078227D2C58652E647261674D6F76653D66756E6374696F6E28652C74297B652E647261674D6F76696E673D21302C742E6F726967696E616C4576656E742E73746F7050726F7061676174696F6E28293B636F6E7374206F3D7B6C6E';
wwv_flow_imp.g_varchar2_table(436) := '673A742E6C6E674C61742E6C6E672D652E647261674D6F76654C6F636174696F6E2E6C6E672C6C61743A742E6C6E674C61742E6C61742D652E647261674D6F76654C6F636174696F6E2E6C61747D3B486528746869732E67657453656C65637465642829';
wwv_flow_imp.g_varchar2_table(437) := '2C6F292C652E647261674D6F76654C6F636174696F6E3D742E6C6E674C61747D2C58652E6F6E546F756368456E643D58652E6F6E4D6F75736555703D66756E6374696F6E28652C74297B696628652E647261674D6F76696E6729746869732E6669726555';
wwv_flow_imp.g_varchar2_table(438) := '706461746528293B656C736520696628652E626F7853656C656374696E67297B636F6E7374206E3D5B652E626F7853656C65637453746172744C6F636174696F6E2C4F6528742E6F726967696E616C4576656E742C746869732E6D61702E676574436F6E';
wwv_flow_imp.g_varchar2_table(439) := '7461696E65722829295D2C723D746869732E66656174757265734174286E756C6C2C6E2C22636C69636B22292C693D746869732E676574556E697175654964732872292E66696C7465722828653D3E21746869732E697353656C65637465642865292929';
wwv_flow_imp.g_varchar2_table(440) := '3B692E6C656E677468262628746869732E73656C6563742869292C692E666F72456163682828653D3E746869732E646F52656E64657228652929292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D29297D7468';
wwv_flow_imp.g_varchar2_table(441) := '69732E73746F70457874656E646564496E746572616374696F6E732865297D2C58652E746F446973706C617946656174757265733D66756E6374696F6E28652C742C6F297B742E70726F706572746965732E6163746976653D746869732E697353656C65';
wwv_flow_imp.g_varchar2_table(442) := '6374656428742E70726F706572746965732E6964293F752E4143544956453A752E494E4143544956452C6F2874292C746869732E66697265416374696F6E61626C6528292C742E70726F706572746965732E6163746976653D3D3D752E41435449564526';
wwv_flow_imp.g_varchar2_table(443) := '26742E67656F6D657472792E74797065213D3D722E504F494E54262655652874292E666F7245616368286F297D2C58652E6F6E54726173683D66756E6374696F6E28297B746869732E64656C6574654665617475726528746869732E67657453656C6563';
wwv_flow_imp.g_varchar2_table(444) := '7465644964732829292C746869732E66697265416374696F6E61626C6528297D2C58652E6F6E436F6D62696E6546656174757265733D66756E6374696F6E28297B636F6E737420653D746869732E67657453656C656374656428293B696628303D3D3D65';
wwv_flow_imp.g_varchar2_table(445) := '2E6C656E6774687C7C652E6C656E6774683C322972657475726E3B636F6E737420743D5B5D2C6F3D5B5D2C6E3D655B305D2E747970652E7265706C61636528224D756C7469222C2222293B666F72286C657420723D303B723C652E6C656E6774683B722B';
wwv_flow_imp.g_varchar2_table(446) := '2B297B636F6E737420693D655B725D3B696628692E747970652E7265706C61636528224D756C7469222C222229213D3D6E2972657475726E3B692E747970652E696E636C7564657328224D756C746922293F692E676574436F6F7264696E617465732829';
wwv_flow_imp.g_varchar2_table(447) := '2E666F72456163682828653D3E7B742E707573682865297D29293A742E7075736828692E676574436F6F7264696E617465732829292C6F2E7075736828692E746F47656F4A534F4E2829297D6966286F2E6C656E6774683E31297B636F6E737420653D74';
wwv_flow_imp.g_varchar2_table(448) := '6869732E6E657746656174757265287B747970653A722E464541545552452C70726F706572746965733A6F5B305D2E70726F706572746965732C67656F6D657472793A7B747970653A604D756C7469247B6E7D602C636F6F7264696E617465733A747D7D';
wwv_flow_imp.g_varchar2_table(449) := '293B746869732E616464466561747572652865292C746869732E64656C6574654665617475726528746869732E67657453656C656374656449647328292C7B73696C656E743A21307D292C746869732E73657453656C6563746564285B652E69645D292C';
wwv_flow_imp.g_varchar2_table(450) := '746869732E6669726528732E434F4D42494E455F46454154555245532C7B6372656174656446656174757265733A5B652E746F47656F4A534F4E28295D2C64656C6574656446656174757265733A6F7D297D746869732E66697265416374696F6E61626C';
wwv_flow_imp.g_varchar2_table(451) := '6528297D2C58652E6F6E556E636F6D62696E6546656174757265733D66756E6374696F6E28297B636F6E737420653D746869732E67657453656C656374656428293B696628303D3D3D652E6C656E6774682972657475726E3B636F6E737420743D5B5D2C';
wwv_flow_imp.g_varchar2_table(452) := '6F3D5B5D3B666F72286C6574206E3D303B6E3C652E6C656E6774683B6E2B2B297B636F6E737420723D655B6E5D3B746869732E6973496E7374616E63654F6628224D756C746946656174757265222C7229262628722E676574466561747572657328292E';
wwv_flow_imp.g_varchar2_table(453) := '666F72456163682828653D3E7B746869732E616464466561747572652865292C652E70726F706572746965733D722E70726F706572746965732C742E7075736828652E746F47656F4A534F4E2829292C746869732E73656C656374285B652E69645D297D';
wwv_flow_imp.g_varchar2_table(454) := '29292C746869732E64656C6574654665617475726528722E69642C7B73696C656E743A21307D292C6F2E7075736828722E746F47656F4A534F4E282929297D742E6C656E6774683E312626746869732E6669726528732E554E434F4D42494E455F464541';
wwv_flow_imp.g_varchar2_table(455) := '54555245532C7B6372656174656446656174757265733A742C64656C6574656446656174757265733A6F7D292C746869732E66697265416374696F6E61626C6528297D3B636F6E73742071653D6628632E564552544558292C4B653D6628632E4D494450';
wwv_flow_imp.g_varchar2_table(456) := '4F494E54292C5A653D7B666972655570646174653A66756E6374696F6E28297B746869732E6669726528732E5550444154452C7B616374696F6E3A612E4348414E47455F434F4F5244494E415445532C66656174757265733A746869732E67657453656C';
wwv_flow_imp.g_varchar2_table(457) := '656374656428292E6D61702828653D3E652E746F47656F4A534F4E282929297D297D2C66697265416374696F6E61626C653A66756E6374696F6E2865297B746869732E736574416374696F6E61626C655374617465287B636F6D62696E65466561747572';
wwv_flow_imp.g_varchar2_table(458) := '65733A21312C756E636F6D62696E6546656174757265733A21312C74726173683A652E73656C6563746564436F6F726450617468732E6C656E6774683E307D297D2C73746172744472616767696E673A66756E6374696F6E28652C74297B6E756C6C3D3D';
wwv_flow_imp.g_varchar2_table(459) := '652E696E697469616C4472616750616E5374617465262628652E696E697469616C4472616750616E53746174653D746869732E6D61702E6472616750616E2E6973456E61626C65642829292C746869732E6D61702E6472616750616E2E64697361626C65';
wwv_flow_imp.g_varchar2_table(460) := '28292C652E63616E447261674D6F76653D21302C652E647261674D6F76654C6F636174696F6E3D742E6C6E674C61747D2C73746F704472616767696E673A66756E6374696F6E2865297B652E63616E447261674D6F7665262621303D3D3D652E696E6974';
wwv_flow_imp.g_varchar2_table(461) := '69616C4472616750616E53746174652626746869732E6D61702E6472616750616E2E656E61626C6528292C652E696E697469616C4472616750616E53746174653D6E756C6C2C652E647261674D6F76696E673D21312C652E63616E447261674D6F76653D';
wwv_flow_imp.g_varchar2_table(462) := '21312C652E647261674D6F76654C6F636174696F6E3D6E756C6C7D2C6F6E5665727465783A66756E6374696F6E28652C74297B746869732E73746172744472616767696E6728652C74293B636F6E7374206F3D742E666561747572655461726765742E70';
wwv_flow_imp.g_varchar2_table(463) := '726F706572746965732C6E3D652E73656C6563746564436F6F726450617468732E696E6465784F66286F2E636F6F72645F70617468293B5F2874297C7C2D31213D3D6E3F5F28742926262D313D3D3D6E2626652E73656C6563746564436F6F7264506174';
wwv_flow_imp.g_varchar2_table(464) := '68732E70757368286F2E636F6F72645F70617468293A652E73656C6563746564436F6F726450617468733D5B6F2E636F6F72645F706174685D3B636F6E737420723D746869732E7061746873546F436F6F7264696E6174657328652E6665617475726549';
wwv_flow_imp.g_varchar2_table(465) := '642C652E73656C6563746564436F6F72645061746873293B746869732E73657453656C6563746564436F6F7264696E617465732872297D2C6F6E4D6964706F696E743A66756E6374696F6E28652C74297B746869732E73746172744472616767696E6728';
wwv_flow_imp.g_varchar2_table(466) := '652C74293B636F6E7374206F3D742E666561747572655461726765742E70726F706572746965733B652E666561747572652E616464436F6F7264696E617465286F2E636F6F72645F706174682C6F2E6C6E672C6F2E6C6174292C746869732E6669726555';
wwv_flow_imp.g_varchar2_table(467) := '706461746528292C652E73656C6563746564436F6F726450617468733D5B6F2E636F6F72645F706174685D7D2C7061746873546F436F6F7264696E617465733A66756E6374696F6E28652C74297B72657475726E20742E6D61702828743D3E287B666561';
wwv_flow_imp.g_varchar2_table(468) := '747572655F69643A652C636F6F72645F706174683A747D2929297D2C6F6E466561747572653A66756E6374696F6E28652C74297B303D3D3D652E73656C6563746564436F6F726450617468732E6C656E6774683F746869732E7374617274447261676769';
wwv_flow_imp.g_varchar2_table(469) := '6E6728652C74293A746869732E73746F704472616767696E672865297D2C64726167466561747572653A66756E6374696F6E28652C742C6F297B486528746869732E67657453656C656374656428292C6F292C652E647261674D6F76654C6F636174696F';
wwv_flow_imp.g_varchar2_table(470) := '6E3D742E6C6E674C61747D2C647261675665727465783A66756E6374696F6E28652C742C6F297B636F6E7374206E3D652E73656C6563746564436F6F726450617468732E6D61702828743D3E652E666561747572652E676574436F6F7264696E61746528';
wwv_flow_imp.g_varchar2_table(471) := '742929292C693D5965286E2E6D61702828653D3E287B747970653A722E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F7264696E617465733A657D7D2929292C6F293B666F7228';
wwv_flow_imp.g_varchar2_table(472) := '6C657420743D303B743C6E2E6C656E6774683B742B2B297B636F6E7374206F3D6E5B745D3B652E666561747572652E757064617465436F6F7264696E61746528652E73656C6563746564436F6F726450617468735B745D2C6F5B305D2B692E6C6E672C6F';
wwv_flow_imp.g_varchar2_table(473) := '5B315D2B692E6C6174297D7D2C636C69636B4E6F5461726765743A66756E6374696F6E28297B746869732E6368616E67654D6F646528692E53494D504C455F53454C454354297D2C636C69636B496E6163746976653A66756E6374696F6E28297B746869';
wwv_flow_imp.g_varchar2_table(474) := '732E6368616E67654D6F646528692E53494D504C455F53454C454354297D2C636C69636B416374697665466561747572653A66756E6374696F6E2865297B652E73656C6563746564436F6F726450617468733D5B5D2C746869732E636C65617253656C65';
wwv_flow_imp.g_varchar2_table(475) := '63746564436F6F7264696E6174657328292C652E666561747572652E6368616E67656428297D2C6F6E53657475703A66756E6374696F6E2865297B636F6E737420743D652E6665617475726549642C6F3D746869732E676574466561747572652874293B';
wwv_flow_imp.g_varchar2_table(476) := '696628216F297468726F77206E6577204572726F722822596F75206D7573742070726F7669646520612066656174757265496420746F20656E746572206469726563745F73656C656374206D6F646522293B6966286F2E747970653D3D3D722E504F494E';
wwv_flow_imp.g_varchar2_table(477) := '54297468726F77206E657720547970654572726F7228226469726563745F73656C656374206D6F646520646F65736E27742068616E646C6520706F696E7420666561747572657322293B636F6E7374206E3D7B6665617475726549643A742C6665617475';
wwv_flow_imp.g_varchar2_table(478) := '72653A6F2C647261674D6F76654C6F636174696F6E3A652E7374617274506F737C7C6E756C6C2C647261674D6F76696E673A21312C63616E447261674D6F76653A21312C73656C6563746564436F6F726450617468733A652E636F6F7264506174683F5B';
wwv_flow_imp.g_varchar2_table(479) := '652E636F6F7264506174685D3A5B5D7D3B72657475726E20746869732E73657453656C6563746564436F6F7264696E6174657328746869732E7061746873546F436F6F7264696E6174657328742C6E2E73656C6563746564436F6F726450617468732929';
wwv_flow_imp.g_varchar2_table(480) := '2C746869732E73657453656C65637465642874292C6B652E64697361626C652874686973292C746869732E736574416374696F6E61626C655374617465287B74726173683A21307D292C6E7D2C6F6E53746F703A66756E6374696F6E28297B6B652E656E';
wwv_flow_imp.g_varchar2_table(481) := '61626C652874686973292C746869732E636C65617253656C6563746564436F6F7264696E6174657328297D2C746F446973706C617946656174757265733A66756E6374696F6E28652C742C6F297B652E6665617475726549643D3D3D742E70726F706572';
wwv_flow_imp.g_varchar2_table(482) := '746965732E69643F28742E70726F706572746965732E6163746976653D752E4143544956452C6F2874292C556528742C7B6D61703A746869732E6D61702C6D6964706F696E74733A21302C73656C656374656450617468733A652E73656C656374656443';
wwv_flow_imp.g_varchar2_table(483) := '6F6F726450617468737D292E666F7245616368286F29293A28742E70726F706572746965732E6163746976653D752E494E4143544956452C6F287429292C746869732E66697265416374696F6E61626C652865297D2C6F6E54726173683A66756E637469';
wwv_flow_imp.g_varchar2_table(484) := '6F6E2865297B652E73656C6563746564436F6F726450617468732E736F7274282828652C74293D3E742E6C6F63616C65436F6D7061726528652C22656E222C7B6E756D657269633A21307D2929292E666F72456163682828743D3E652E66656174757265';
wwv_flow_imp.g_varchar2_table(485) := '2E72656D6F7665436F6F7264696E61746528742929292C746869732E6669726555706461746528292C652E73656C6563746564436F6F726450617468733D5B5D2C746869732E636C65617253656C6563746564436F6F7264696E6174657328292C746869';
wwv_flow_imp.g_varchar2_table(486) := '732E66697265416374696F6E61626C652865292C21313D3D3D652E666561747572652E697356616C69642829262628746869732E64656C65746546656174757265285B652E6665617475726549645D292C746869732E6368616E67654D6F646528692E53';
wwv_flow_imp.g_varchar2_table(487) := '494D504C455F53454C4543542C7B7D29297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28652C74297B636F6E7374206E3D792874292C723D71652874292C693D4B652874292C733D303D3D3D652E73656C6563746564436F6F72645061746873';
wwv_flow_imp.g_varchar2_table(488) := '2E6C656E6774683B72657475726E206E2626737C7C72262621733F746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D4F56457D293A746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4E4F4E457D29';
wwv_flow_imp.g_varchar2_table(489) := '2C28727C7C6E7C7C69292626652E647261674D6F76696E672626746869732E6669726555706461746528292C746869732E73746F704472616767696E672865292C21307D2C6F6E4D6F7573654F75743A66756E6374696F6E2865297B72657475726E2065';
wwv_flow_imp.g_varchar2_table(490) := '2E647261674D6F76696E672626746869732E6669726555706461746528292C21307D7D3B5A652E6F6E546F75636853746172743D5A652E6F6E4D6F757365446F776E3D66756E6374696F6E28652C74297B72657475726E2071652874293F746869732E6F';
wwv_flow_imp.g_varchar2_table(491) := '6E56657274657828652C74293A792874293F746869732E6F6E4665617475726528652C74293A4B652874293F746869732E6F6E4D6964706F696E7428652C74293A766F696420307D2C5A652E6F6E447261673D66756E6374696F6E28652C74297B696628';
wwv_flow_imp.g_varchar2_table(492) := '2130213D3D652E63616E447261674D6F76652972657475726E3B652E647261674D6F76696E673D21302C742E6F726967696E616C4576656E742E73746F7050726F7061676174696F6E28293B636F6E7374206F3D7B6C6E673A742E6C6E674C61742E6C6E';
wwv_flow_imp.g_varchar2_table(493) := '672D652E647261674D6F76654C6F636174696F6E2E6C6E672C6C61743A742E6C6E674C61742E6C61742D652E647261674D6F76654C6F636174696F6E2E6C61747D3B652E73656C6563746564436F6F726450617468732E6C656E6774683E303F74686973';
wwv_flow_imp.g_varchar2_table(494) := '2E6472616756657274657828652C742C6F293A746869732E647261674665617475726528652C742C6F292C652E647261674D6F76654C6F636174696F6E3D742E6C6E674C61747D2C5A652E6F6E436C69636B3D66756E6374696F6E28652C74297B726574';
wwv_flow_imp.g_varchar2_table(495) := '75726E20452874293F746869732E636C69636B4E6F54617267657428652C74293A792874293F746869732E636C69636B4163746976654665617475726528652C74293A6D2874293F746869732E636C69636B496E61637469766528652C74293A766F6964';
wwv_flow_imp.g_varchar2_table(496) := '20746869732E73746F704472616767696E672865297D2C5A652E6F6E5461703D66756E6374696F6E28652C74297B72657475726E20452874293F746869732E636C69636B4E6F54617267657428652C74293A792874293F746869732E636C69636B416374';
wwv_flow_imp.g_varchar2_table(497) := '6976654665617475726528652C74293A6D2874293F746869732E636C69636B496E61637469766528652C74293A766F696420307D2C5A652E6F6E546F756368456E643D5A652E6F6E4D6F75736555703D66756E6374696F6E2865297B652E647261674D6F';
wwv_flow_imp.g_varchar2_table(498) := '76696E672626746869732E6669726555706461746528292C746869732E73746F704472616767696E672865297D3B636F6E73742057653D7B7D3B66756E6374696F6E207A6528652C74297B72657475726E2121652E6C6E674C61742626652E6C6E674C61';
wwv_flow_imp.g_varchar2_table(499) := '742E6C6E673D3D3D745B305D2626652E6C6E674C61742E6C61743D3D3D745B315D7D57652E6F6E53657475703D66756E6374696F6E28297B636F6E737420653D746869732E6E657746656174757265287B747970653A722E464541545552452C70726F70';
wwv_flow_imp.g_varchar2_table(500) := '6572746965733A7B7D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F7264696E617465733A5B5D7D7D293B72657475726E20746869732E616464466561747572652865292C746869732E636C65617253656C65637465644665617475';
wwv_flow_imp.g_varchar2_table(501) := '72657328292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4144447D292C746869732E61637469766174655549427574746F6E286E2E504F494E54292C746869732E736574416374696F6E61626C655374617465287B7472';
wwv_flow_imp.g_varchar2_table(502) := '6173683A21307D292C7B706F696E743A657D7D2C57652E73746F7044726177696E67416E6452656D6F76653D66756E6374696F6E2865297B746869732E64656C65746546656174757265285B652E706F696E742E69645D2C7B73696C656E743A21307D29';
wwv_flow_imp.g_varchar2_table(503) := '2C746869732E6368616E67654D6F646528692E53494D504C455F53454C454354297D2C57652E6F6E5461703D57652E6F6E436C69636B3D66756E6374696F6E28652C74297B746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4D';
wwv_flow_imp.g_varchar2_table(504) := '4F56457D292C652E706F696E742E757064617465436F6F7264696E6174652822222C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174292C746869732E6669726528732E4352454154452C7B66656174757265733A5B652E706F696E742E74';
wwv_flow_imp.g_varchar2_table(505) := '6F47656F4A534F4E28295D7D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E706F696E742E69645D7D297D2C57652E6F6E53746F703D66756E6374696F6E2865297B74686973';
wwv_flow_imp.g_varchar2_table(506) := '2E61637469766174655549427574746F6E28292C652E706F696E742E676574436F6F7264696E61746528292E6C656E6774687C7C746869732E64656C65746546656174757265285B652E706F696E742E69645D2C7B73696C656E743A21307D297D2C5765';
wwv_flow_imp.g_varchar2_table(507) := '2E746F446973706C617946656174757265733D66756E6374696F6E28652C742C6F297B636F6E7374206E3D742E70726F706572746965732E69643D3D3D652E706F696E742E69643B696628742E70726F706572746965732E6163746976653D6E3F752E41';
wwv_flow_imp.g_varchar2_table(508) := '43544956453A752E494E4143544956452C216E2972657475726E206F2874297D2C57652E6F6E54726173683D57652E73746F7044726177696E67416E6452656D6F76652C57652E6F6E4B657955703D66756E6374696F6E28652C74297B69662876287429';
wwv_flow_imp.g_varchar2_table(509) := '7C7C492874292972657475726E20746869732E73746F7044726177696E67416E6452656D6F766528652C74297D3B636F6E73742051653D7B6F6E53657475703A66756E6374696F6E28297B636F6E737420653D746869732E6E657746656174757265287B';
wwv_flow_imp.g_varchar2_table(510) := '747970653A722E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A722E504F4C59474F4E2C636F6F7264696E617465733A5B5B5D5D7D7D293B72657475726E20746869732E616464466561747572652865292C';
wwv_flow_imp.g_varchar2_table(511) := '746869732E636C65617253656C6563746564466561747572657328292C6B652E64697361626C652874686973292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4144447D292C746869732E61637469766174655549427574';
wwv_flow_imp.g_varchar2_table(512) := '746F6E286E2E504F4C59474F4E292C746869732E736574416374696F6E61626C655374617465287B74726173683A21307D292C7B706F6C79676F6E3A652C63757272656E74566572746578506F736974696F6E3A307D7D2C636C69636B416E7977686572';
wwv_flow_imp.g_varchar2_table(513) := '653A66756E6374696F6E28652C74297B696628652E63757272656E74566572746578506F736974696F6E3E3026267A6528742C652E706F6C79676F6E2E636F6F7264696E617465735B305D5B652E63757272656E74566572746578506F736974696F6E2D';
wwv_flow_imp.g_varchar2_table(514) := '315D292972657475726E20746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E706F6C79676F6E2E69645D7D293B746869732E7570646174655549436C6173736573287B6D6F7573653A';
wwv_flow_imp.g_varchar2_table(515) := '6F2E4144447D292C652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F736974696F6E7D602C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174292C652E6375727265';
wwv_flow_imp.g_varchar2_table(516) := '6E74566572746578506F736974696F6E2B2B2C652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F736974696F6E7D602C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C';
wwv_flow_imp.g_varchar2_table(517) := '6174297D2C636C69636B4F6E5665727465783A66756E6374696F6E2865297B72657475726E20746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E706F6C79676F6E2E69645D7D297D2C';
wwv_flow_imp.g_varchar2_table(518) := '6F6E4D6F7573654D6F76653A66756E6374696F6E28652C74297B652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F736974696F6E7D602C742E6C6E674C61742E6C6E672C742E6C';
wwv_flow_imp.g_varchar2_table(519) := '6E674C61742E6C6174292C542874292626746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E504F494E5445527D297D7D3B51652E6F6E5461703D51652E6F6E436C69636B3D66756E6374696F6E28652C74297B72657475726E20';
wwv_flow_imp.g_varchar2_table(520) := '542874293F746869732E636C69636B4F6E56657274657828652C74293A746869732E636C69636B416E79776865726528652C74297D2C51652E6F6E4B657955703D66756E6374696F6E28652C74297B762874293F28746869732E64656C65746546656174';
wwv_flow_imp.g_varchar2_table(521) := '757265285B652E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C45435429293A492874292626746869732E6368616E67654D6F646528692E53494D504C455F53454C';
wwv_flow_imp.g_varchar2_table(522) := '4543542C7B666561747572654964733A5B652E706F6C79676F6E2E69645D7D297D2C51652E6F6E53746F703D66756E6374696F6E2865297B746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4E4F4E457D292C6B652E656E6162';
wwv_flow_imp.g_varchar2_table(523) := '6C652874686973292C746869732E61637469766174655549427574746F6E28292C766F69642030213D3D746869732E6765744665617475726528652E706F6C79676F6E2E696429262628652E706F6C79676F6E2E72656D6F7665436F6F7264696E617465';
wwv_flow_imp.g_varchar2_table(524) := '2860302E247B652E63757272656E74566572746578506F736974696F6E7D60292C652E706F6C79676F6E2E697356616C696428293F746869732E6669726528732E4352454154452C7B66656174757265733A5B652E706F6C79676F6E2E746F47656F4A53';
wwv_flow_imp.g_varchar2_table(525) := '4F4E28295D7D293A28746869732E64656C65746546656174757265285B652E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B7D2C7B73696C656E743A21';
wwv_flow_imp.g_varchar2_table(526) := '307D2929297D2C51652E746F446973706C617946656174757265733D66756E6374696F6E28652C742C6F297B636F6E7374206E3D742E70726F706572746965732E69643D3D3D652E706F6C79676F6E2E69643B696628742E70726F706572746965732E61';
wwv_flow_imp.g_varchar2_table(527) := '63746976653D6E3F752E4143544956453A752E494E4143544956452C216E2972657475726E206F2874293B696628303D3D3D742E67656F6D657472792E636F6F7264696E617465732E6C656E6774682972657475726E3B636F6E737420693D742E67656F';
wwv_flow_imp.g_varchar2_table(528) := '6D657472792E636F6F7264696E617465735B305D2E6C656E6774683B6966282128693C3329297B696628742E70726F706572746965732E6D6574613D632E464541545552452C6F284D6528652E706F6C79676F6E2E69642C742E67656F6D657472792E63';
wwv_flow_imp.g_varchar2_table(529) := '6F6F7264696E617465735B305D5B305D2C22302E30222C213129292C693E33297B636F6E7374206E3D742E67656F6D657472792E636F6F7264696E617465735B305D2E6C656E6774682D333B6F284D6528652E706F6C79676F6E2E69642C742E67656F6D';
wwv_flow_imp.g_varchar2_table(530) := '657472792E636F6F7264696E617465735B305D5B6E5D2C60302E247B6E7D602C213129297D696628693C3D34297B636F6E737420653D5B5B742E67656F6D657472792E636F6F7264696E617465735B305D5B305D5B305D2C742E67656F6D657472792E63';
wwv_flow_imp.g_varchar2_table(531) := '6F6F7264696E617465735B305D5B305D5B315D5D2C5B742E67656F6D657472792E636F6F7264696E617465735B305D5B315D5B305D2C742E67656F6D657472792E636F6F7264696E617465735B305D5B315D5B315D5D5D3B6966286F287B747970653A72';
wwv_flow_imp.g_varchar2_table(532) := '2E464541545552452C70726F706572746965733A742E70726F706572746965732C67656F6D657472793A7B636F6F7264696E617465733A652C747970653A722E4C494E455F535452494E477D7D292C333D3D3D692972657475726E7D72657475726E206F';
wwv_flow_imp.g_varchar2_table(533) := '2874297D7D2C51652E6F6E54726173683D66756E6374696F6E2865297B746869732E64656C65746546656174757265285B652E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C45';
wwv_flow_imp.g_varchar2_table(534) := '5F53454C454354297D3B636F6E73742065743D7B6F6E53657475703A66756E6374696F6E2865297B636F6E737420743D28653D657C7C7B7D292E6665617475726549643B6C657420692C732C613D22666F7277617264223B69662874297B696628693D74';
wwv_flow_imp.g_varchar2_table(535) := '6869732E676574466561747572652874292C2169297468726F77206E6577204572726F722822436F756C64206E6F742066696E64206120666561747572652077697468207468652070726F76696465642066656174757265496422293B6C6574206F3D65';
wwv_flow_imp.g_varchar2_table(536) := '2E66726F6D3B6966286F26262246656174757265223D3D3D6F2E7479706526266F2E67656F6D65747279262622506F696E74223D3D3D6F2E67656F6D657472792E747970652626286F3D6F2E67656F6D65747279292C6F262622506F696E74223D3D3D6F';
wwv_flow_imp.g_varchar2_table(537) := '2E7479706526266F2E636F6F7264696E617465732626323D3D3D6F2E636F6F7264696E617465732E6C656E6774682626286F3D6F2E636F6F7264696E61746573292C216F7C7C2141727261792E69734172726179286F29297468726F77206E6577204572';
wwv_flow_imp.g_varchar2_table(538) := '726F722822506C656173652075736520746865206066726F6D602070726F706572747920746F20696E64696361746520776869636820706F696E7420746F20636F6E74696E756520746865206C696E652066726F6D22293B636F6E7374206E3D692E636F';
wwv_flow_imp.g_varchar2_table(539) := '6F7264696E617465732E6C656E6774682D313B696628692E636F6F7264696E617465735B6E5D5B305D3D3D3D6F5B305D2626692E636F6F7264696E617465735B6E5D5B315D3D3D3D6F5B315D29733D6E2B312C692E616464436F6F7264696E6174652873';
wwv_flow_imp.g_varchar2_table(540) := '2C2E2E2E692E636F6F7264696E617465735B6E5D293B656C73657B696628692E636F6F7264696E617465735B305D5B305D213D3D6F5B305D7C7C692E636F6F7264696E617465735B305D5B315D213D3D6F5B315D297468726F77206E6577204572726F72';
wwv_flow_imp.g_varchar2_table(541) := '28226066726F6D602073686F756C64206D617463682074686520706F696E742061742065697468657220746865207374617274206F722074686520656E64206F66207468652070726F7669646564204C696E65537472696E6722293B613D226261636B77';
wwv_flow_imp.g_varchar2_table(542) := '61726473222C733D302C692E616464436F6F7264696E61746528732C2E2E2E692E636F6F7264696E617465735B305D297D7D656C736520693D746869732E6E657746656174757265287B747970653A722E464541545552452C70726F706572746965733A';
wwv_flow_imp.g_varchar2_table(543) := '7B7D2C67656F6D657472793A7B747970653A722E4C494E455F535452494E472C636F6F7264696E617465733A5B5D7D7D292C733D302C746869732E616464466561747572652869293B72657475726E20746869732E636C65617253656C65637465644665';
wwv_flow_imp.g_varchar2_table(544) := '61747572657328292C6B652E64697361626C652874686973292C746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4144447D292C746869732E61637469766174655549427574746F6E286E2E4C494E45292C746869732E736574';
wwv_flow_imp.g_varchar2_table(545) := '416374696F6E61626C655374617465287B74726173683A21307D292C7B6C696E653A692C63757272656E74566572746578506F736974696F6E3A732C646972656374696F6E3A617D7D2C636C69636B416E7977686572653A66756E6374696F6E28652C74';
wwv_flow_imp.g_varchar2_table(546) := '297B696628652E63757272656E74566572746578506F736974696F6E3E3026267A6528742C652E6C696E652E636F6F7264696E617465735B652E63757272656E74566572746578506F736974696F6E2D315D297C7C226261636B7761726473223D3D3D65';
wwv_flow_imp.g_varchar2_table(547) := '2E646972656374696F6E26267A6528742C652E6C696E652E636F6F7264696E617465735B652E63757272656E74566572746578506F736974696F6E2B315D292972657475726E20746869732E6368616E67654D6F646528692E53494D504C455F53454C45';
wwv_flow_imp.g_varchar2_table(548) := '43542C7B666561747572654964733A5B652E6C696E652E69645D7D293B746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E4144447D292C652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E745665';
wwv_flow_imp.g_varchar2_table(549) := '72746578506F736974696F6E2C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C6174292C22666F7277617264223D3D3D652E646972656374696F6E3F28652E63757272656E74566572746578506F736974696F6E2B2B2C652E6C696E652E7570';
wwv_flow_imp.g_varchar2_table(550) := '64617465436F6F7264696E61746528652E63757272656E74566572746578506F736974696F6E2C742E6C6E674C61742E6C6E672C742E6C6E674C61742E6C617429293A652E6C696E652E616464436F6F7264696E61746528302C742E6C6E674C61742E6C';
wwv_flow_imp.g_varchar2_table(551) := '6E672C742E6C6E674C61742E6C6174297D2C636C69636B4F6E5665727465783A66756E6374696F6E2865297B72657475726E20746869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E6C69';
wwv_flow_imp.g_varchar2_table(552) := '6E652E69645D7D297D2C6F6E4D6F7573654D6F76653A66756E6374696F6E28652C74297B652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E74566572746578506F736974696F6E2C742E6C6E674C61742E6C6E672C742E6C';
wwv_flow_imp.g_varchar2_table(553) := '6E674C61742E6C6174292C542874292626746869732E7570646174655549436C6173736573287B6D6F7573653A6F2E504F494E5445527D297D7D3B65742E6F6E5461703D65742E6F6E436C69636B3D66756E6374696F6E28652C74297B69662854287429';
wwv_flow_imp.g_varchar2_table(554) := '2972657475726E20746869732E636C69636B4F6E56657274657828652C74293B746869732E636C69636B416E79776865726528652C74297D2C65742E6F6E4B657955703D66756E6374696F6E28652C74297B492874293F746869732E6368616E67654D6F';
wwv_flow_imp.g_varchar2_table(555) := '646528692E53494D504C455F53454C4543542C7B666561747572654964733A5B652E6C696E652E69645D7D293A76287429262628746869732E64656C65746546656174757265285B652E6C696E652E69645D2C7B73696C656E743A21307D292C74686973';
wwv_flow_imp.g_varchar2_table(556) := '2E6368616E67654D6F646528692E53494D504C455F53454C45435429297D2C65742E6F6E53746F703D66756E6374696F6E2865297B6B652E656E61626C652874686973292C746869732E61637469766174655549427574746F6E28292C766F6964203021';
wwv_flow_imp.g_varchar2_table(557) := '3D3D746869732E6765744665617475726528652E6C696E652E696429262628652E6C696E652E72656D6F7665436F6F7264696E6174652860247B652E63757272656E74566572746578506F736974696F6E7D60292C652E6C696E652E697356616C696428';
wwv_flow_imp.g_varchar2_table(558) := '293F746869732E6669726528732E4352454154452C7B66656174757265733A5B652E6C696E652E746F47656F4A534F4E28295D7D293A28746869732E64656C65746546656174757265285B652E6C696E652E69645D2C7B73696C656E743A21307D292C74';
wwv_flow_imp.g_varchar2_table(559) := '6869732E6368616E67654D6F646528692E53494D504C455F53454C4543542C7B7D2C7B73696C656E743A21307D2929297D2C65742E6F6E54726173683D66756E6374696F6E2865297B746869732E64656C65746546656174757265285B652E6C696E652E';
wwv_flow_imp.g_varchar2_table(560) := '69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F646528692E53494D504C455F53454C454354297D2C65742E746F446973706C617946656174757265733D66756E6374696F6E28652C742C6F297B636F6E7374206E3D742E7072';
wwv_flow_imp.g_varchar2_table(561) := '6F706572746965732E69643D3D3D652E6C696E652E69643B696628742E70726F706572746965732E6163746976653D6E3F752E4143544956453A752E494E4143544956452C216E2972657475726E206F2874293B742E67656F6D657472792E636F6F7264';
wwv_flow_imp.g_varchar2_table(562) := '696E617465732E6C656E6774683C327C7C28742E70726F706572746965732E6D6574613D632E464541545552452C6F284D6528652E6C696E652E69642C742E67656F6D657472792E636F6F7264696E617465735B22666F7277617264223D3D3D652E6469';
wwv_flow_imp.g_varchar2_table(563) := '72656374696F6E3F742E67656F6D657472792E636F6F7264696E617465732E6C656E6774682D323A315D2C22222B2822666F7277617264223D3D3D652E646972656374696F6E3F742E67656F6D657472792E636F6F7264696E617465732E6C656E677468';
wwv_flow_imp.g_varchar2_table(564) := '2D323A31292C213129292C6F287429297D3B7661722074743D7B73696D706C655F73656C6563743A58652C6469726563745F73656C6563743A5A652C647261775F706F696E743A57652C647261775F706F6C79676F6E3A51652C647261775F6C696E655F';
wwv_flow_imp.g_varchar2_table(565) := '737472696E673A65747D3B636F6E7374206F743D7B64656661756C744D6F64653A692E53494D504C455F53454C4543542C6B657962696E64696E67733A21302C746F756368456E61626C65643A21302C636C69636B4275666665723A322C746F75636842';
wwv_flow_imp.g_varchar2_table(566) := '75666665723A32352C626F7853656C6563743A21302C646973706C6179436F6E74726F6C7344656661756C743A21302C7374796C65733A49652C6D6F6465733A74742C636F6E74726F6C733A7B7D2C7573657250726F706572746965733A21312C737570';
wwv_flow_imp.g_varchar2_table(567) := '70726573734150494576656E74733A21307D2C6E743D7B706F696E743A21302C6C696E655F737472696E673A21302C706F6C79676F6E3A21302C74726173683A21302C636F6D62696E655F66656174757265733A21302C756E636F6D62696E655F666561';
wwv_flow_imp.g_varchar2_table(568) := '74757265733A21307D2C72743D7B706F696E743A21312C6C696E655F737472696E673A21312C706F6C79676F6E3A21312C74726173683A21312C636F6D62696E655F66656174757265733A21312C756E636F6D62696E655F66656174757265733A21317D';
wwv_flow_imp.g_varchar2_table(569) := '3B66756E6374696F6E20697428652C6F297B72657475726E20652E6D61702828653D3E652E736F757263653F653A4F626A6563742E61737369676E287B7D2C652C7B69643A60247B652E69647D2E247B6F7D602C736F757263653A22686F74223D3D3D6F';
wwv_flow_imp.g_varchar2_table(570) := '3F742E484F543A742E434F4C447D2929297D7661722073742C61742C63742C75742C6C743D782861743F73743A2861743D312C73743D66756E6374696F6E206528742C6F297B696628743D3D3D6F2972657475726E21303B6966287426266F2626226F62';
wwv_flow_imp.g_varchar2_table(571) := '6A656374223D3D747970656F6620742626226F626A656374223D3D747970656F66206F297B696628742E636F6E7374727563746F72213D3D6F2E636F6E7374727563746F722972657475726E21313B766172206E2C722C693B69662841727261792E6973';
wwv_flow_imp.g_varchar2_table(572) := '4172726179287429297B696628286E3D742E6C656E67746829213D6F2E6C656E6774682972657475726E21313B666F7228723D6E3B30213D722D2D3B29696628216528745B725D2C6F5B725D292972657475726E21313B72657475726E21307D69662874';
wwv_flow_imp.g_varchar2_table(573) := '2E636F6E7374727563746F723D3D3D5265674578702972657475726E20742E736F757263653D3D3D6F2E736F757263652626742E666C6167733D3D3D6F2E666C6167733B696628742E76616C75654F66213D3D4F626A6563742E70726F746F747970652E';
wwv_flow_imp.g_varchar2_table(574) := '76616C75654F662972657475726E20742E76616C75654F6628293D3D3D6F2E76616C75654F6628293B696628742E746F537472696E67213D3D4F626A6563742E70726F746F747970652E746F537472696E672972657475726E20742E746F537472696E67';
wwv_flow_imp.g_varchar2_table(575) := '28293D3D3D6F2E746F537472696E6728293B696628286E3D28693D4F626A6563742E6B657973287429292E6C656E67746829213D3D4F626A6563742E6B657973286F292E6C656E6774682972657475726E21313B666F7228723D6E3B30213D722D2D3B29';
wwv_flow_imp.g_varchar2_table(576) := '696628214F626A6563742E70726F746F747970652E6861734F776E50726F70657274792E63616C6C286F2C695B725D292972657475726E21313B666F7228723D6E3B30213D722D2D3B297B76617220733D695B725D3B696628216528745B735D2C6F5B73';
wwv_flow_imp.g_varchar2_table(577) := '5D292972657475726E21317D72657475726E21307D72657475726E2074213D7426266F213D6F7D29292C64743D66756E6374696F6E28297B69662875742972657475726E2063743B75743D312C63743D66756E6374696F6E2874297B69662821747C7C21';
wwv_flow_imp.g_varchar2_table(578) := '742E747970652972657475726E206E756C6C3B766172206F3D655B742E747970655D3B72657475726E206F3F2267656F6D65747279223D3D3D6F3F7B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B7B74797065';
wwv_flow_imp.g_varchar2_table(579) := '3A2246656174757265222C70726F706572746965733A7B7D2C67656F6D657472793A747D5D7D3A2266656174757265223D3D3D6F3F7B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B745D7D3A22666561747572';
wwv_flow_imp.g_varchar2_table(580) := '65636F6C6C656374696F6E223D3D3D6F3F743A766F696420303A6E756C6C7D3B76617220653D7B506F696E743A2267656F6D65747279222C4D756C7469506F696E743A2267656F6D65747279222C4C696E65537472696E673A2267656F6D65747279222C';
wwv_flow_imp.g_varchar2_table(581) := '4D756C74694C696E65537472696E673A2267656F6D65747279222C506F6C79676F6E3A2267656F6D65747279222C4D756C7469506F6C79676F6E3A2267656F6D65747279222C47656F6D65747279436F6C6C656374696F6E3A2267656F6D65747279222C';
wwv_flow_imp.g_varchar2_table(582) := '466561747572653A2266656174757265222C46656174757265436F6C6C656374696F6E3A2266656174757265636F6C6C656374696F6E227D3B72657475726E2063747D28292C70743D78286474293B66756E6374696F6E20687428652C74297B72657475';
wwv_flow_imp.g_varchar2_table(583) := '726E20652E6C656E6774683D3D3D742E6C656E67746826264A534F4E2E737472696E6769667928652E6D61702828653D3E6529292E736F72742829293D3D3D4A534F4E2E737472696E6769667928742E6D61702828653D3E6529292E736F72742829297D';
wwv_flow_imp.g_varchar2_table(584) := '636F6E73742066743D7B506F6C79676F6E3A61652C4C696E65537472696E673A73652C506F696E743A69652C4D756C7469506F6C79676F6E3A6C652C4D756C74694C696E65537472696E673A6C652C4D756C7469506F696E743A6C657D3B766172206774';
wwv_flow_imp.g_varchar2_table(585) := '3D4F626A6563742E667265657A65287B5F5F70726F746F5F5F3A6E756C6C2C436F6D6D6F6E53656C6563746F72733A502C4D6F646548616E646C65723A74652C537472696E675365743A6A2C636F6E73747261696E466561747572654D6F76656D656E74';
wwv_flow_imp.g_varchar2_table(586) := '3A59652C6372656174654D6964506F696E743A44652C637265617465537570706C656D656E74617279506F696E74733A55652C6372656174655665727465783A4D652C646F75626C65436C69636B5A6F6F6D3A6B652C6575636C696465616E4469737461';
wwv_flow_imp.g_varchar2_table(587) := '6E63653A582C666561747572657341743A242C676574466561747572654174416E64536574437572736F72733A482C6973436C69636B3A572C69734576656E744174436F6F7264696E617465733A7A652C69735461703A65652C6D61704576656E74546F';
wwv_flow_imp.g_varchar2_table(588) := '426F756E64696E67426F783A422C6D6F766546656174757265733A48652C736F727446656174757265733A472C737472696E6753657473417265457175616C3A68742C7468656D653A49652C746F44656E736541727261793A66657D293B66756E637469';
wwv_flow_imp.g_varchar2_table(589) := '6F6E2079742865297B2166756E6374696F6E28652C74297B636F6E7374206F3D7B6F7074696F6E733A653D66756E6374696F6E28653D7B7D297B6C657420743D4F626A6563742E61737369676E287B7D2C65293B72657475726E20652E636F6E74726F6C';
wwv_flow_imp.g_varchar2_table(590) := '737C7C28742E636F6E74726F6C733D7B7D292C21313D3D3D652E646973706C6179436F6E74726F6C7344656661756C743F742E636F6E74726F6C733D4F626A6563742E61737369676E287B7D2C72742C652E636F6E74726F6C73293A742E636F6E74726F';
wwv_flow_imp.g_varchar2_table(591) := '6C733D4F626A6563742E61737369676E287B7D2C6E742C652E636F6E74726F6C73292C743D4F626A6563742E61737369676E287B7D2C6F742C74292C742E7374796C65733D697428742E7374796C65732C22636F6C6422292E636F6E6361742869742874';
wwv_flow_imp.g_varchar2_table(592) := '2E7374796C65732C22686F742229292C747D2865297D3B743D66756E6374696F6E28652C74297B742E6D6F6465733D693B636F6E7374206F3D766F696420303D3D3D652E6F7074696F6E732E73757070726573734150494576656E74737C7C2121652E6F';
wwv_flow_imp.g_varchar2_table(593) := '7074696F6E732E73757070726573734150494576656E74733B72657475726E20742E6765744665617475726549647341743D66756E6374696F6E2874297B72657475726E20242E636C69636B287B706F696E743A747D2C6E756C6C2C65292E6D61702828';
wwv_flow_imp.g_varchar2_table(594) := '653D3E652E70726F706572746965732E696429297D2C742E67657453656C65637465644964733D66756E6374696F6E28297B72657475726E20652E73746F72652E67657453656C656374656449647328297D2C742E67657453656C65637465643D66756E';
wwv_flow_imp.g_varchar2_table(595) := '6374696F6E28297B72657475726E7B747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A652E73746F72652E67657453656C656374656449647328292E6D61702828743D3E652E73746F72652E67657428742929292E';
wwv_flow_imp.g_varchar2_table(596) := '6D61702828653D3E652E746F47656F4A534F4E282929297D7D2C742E67657453656C6563746564506F696E74733D66756E6374696F6E28297B72657475726E7B747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A65';
wwv_flow_imp.g_varchar2_table(597) := '2E73746F72652E67657453656C6563746564436F6F7264696E6174657328292E6D61702828653D3E287B747970653A722E464541545552452C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A722E504F494E542C636F6F726469';
wwv_flow_imp.g_varchar2_table(598) := '6E617465733A652E636F6F7264696E617465737D7D2929297D7D2C742E7365743D66756E6374696F6E286F297B696628766F696420303D3D3D6F2E747970657C7C6F2E74797065213D3D722E464541545552455F434F4C4C454354494F4E7C7C21417272';
wwv_flow_imp.g_varchar2_table(599) := '61792E69734172726179286F2E666561747572657329297468726F77206E6577204572726F722822496E76616C69642046656174757265436F6C6C656374696F6E22293B636F6E7374206E3D652E73746F72652E63726561746552656E64657242617463';
wwv_flow_imp.g_varchar2_table(600) := '6828293B6C657420693D652E73746F72652E676574416C6C49647328292E736C69636528293B636F6E737420733D742E616464286F292C613D6E6577206A2873293B72657475726E20693D692E66696C7465722828653D3E21612E68617328652929292C';
wwv_flow_imp.g_varchar2_table(601) := '692E6C656E6774682626742E64656C6574652869292C6E28292C737D2C742E6164643D66756E6374696F6E2874297B636F6E7374206E3D4A534F4E2E7061727365284A534F4E2E737472696E6769667928707428742929292E66656174757265732E6D61';
wwv_flow_imp.g_varchar2_table(602) := '702828743D3E7B696628742E69643D742E69647C7C6E6528292C6E756C6C3D3D3D742E67656F6D65747279297468726F77206E6577204572726F722822496E76616C69642067656F6D657472793A206E756C6C22293B696628766F696420303D3D3D652E';
wwv_flow_imp.g_varchar2_table(603) := '73746F72652E67657428742E6964297C7C652E73746F72652E67657428742E6964292E74797065213D3D742E67656F6D657472792E74797065297B636F6E7374206E3D66745B742E67656F6D657472792E747970655D3B696628766F696420303D3D3D6E';
wwv_flow_imp.g_varchar2_table(604) := '297468726F77206E6577204572726F722860496E76616C69642067656F6D6574727920747970653A20247B742E67656F6D657472792E747970657D2E60293B636F6E737420723D6E6577206E28652C74293B652E73746F72652E61646428722C7B73696C';
wwv_flow_imp.g_varchar2_table(605) := '656E743A6F7D297D656C73657B636F6E7374206E3D652E73746F72652E67657428742E6964292C723D6E2E70726F706572746965733B6E2E70726F706572746965733D742E70726F706572746965732C6C7428722C742E70726F70657274696573297C7C';
wwv_flow_imp.g_varchar2_table(606) := '652E73746F72652E666561747572654368616E676564286E2E69642C7B73696C656E743A6F7D292C6C74286E2E676574436F6F7264696E6174657328292C742E67656F6D657472792E636F6F7264696E61746573297C7C6E2E696E636F6D696E67436F6F';
wwv_flow_imp.g_varchar2_table(607) := '72647328742E67656F6D657472792E636F6F7264696E61746573297D72657475726E20742E69647D29293B72657475726E20652E73746F72652E72656E64657228292C6E7D2C742E6765743D66756E6374696F6E2874297B636F6E7374206F3D652E7374';
wwv_flow_imp.g_varchar2_table(608) := '6F72652E6765742874293B6966286F2972657475726E206F2E746F47656F4A534F4E28297D2C742E676574416C6C3D66756E6374696F6E28297B72657475726E7B747970653A722E464541545552455F434F4C4C454354494F4E2C66656174757265733A';
wwv_flow_imp.g_varchar2_table(609) := '652E73746F72652E676574416C6C28292E6D61702828653D3E652E746F47656F4A534F4E282929297D7D2C742E64656C6574653D66756E6374696F6E286E297B72657475726E20652E73746F72652E64656C657465286E2C7B73696C656E743A6F7D292C';
wwv_flow_imp.g_varchar2_table(610) := '742E6765744D6F64652829213D3D692E4449524543545F53454C4543547C7C652E73746F72652E67657453656C656374656449647328292E6C656E6774683F652E73746F72652E72656E64657228293A652E6576656E74732E6368616E67654D6F646528';
wwv_flow_imp.g_varchar2_table(611) := '692E53494D504C455F53454C4543542C766F696420302C7B73696C656E743A6F7D292C747D2C742E64656C657465416C6C3D66756E6374696F6E28297B72657475726E20652E73746F72652E64656C65746528652E73746F72652E676574416C6C496473';
wwv_flow_imp.g_varchar2_table(612) := '28292C7B73696C656E743A6F7D292C742E6765744D6F646528293D3D3D692E4449524543545F53454C4543543F652E6576656E74732E6368616E67654D6F646528692E53494D504C455F53454C4543542C766F696420302C7B73696C656E743A6F7D293A';
wwv_flow_imp.g_varchar2_table(613) := '652E73746F72652E72656E64657228292C747D2C742E6368616E67654D6F64653D66756E6374696F6E286E2C723D7B7D297B72657475726E206E3D3D3D692E53494D504C455F53454C4543542626742E6765744D6F646528293D3D3D692E53494D504C45';
wwv_flow_imp.g_varchar2_table(614) := '5F53454C4543543F28687428722E666561747572654964737C7C5B5D2C652E73746F72652E67657453656C65637465644964732829297C7C28652E73746F72652E73657453656C656374656428722E666561747572654964732C7B73696C656E743A6F7D';
wwv_flow_imp.g_varchar2_table(615) := '292C652E73746F72652E72656E6465722829292C74293A286E3D3D3D692E4449524543545F53454C4543542626742E6765744D6F646528293D3D3D692E4449524543545F53454C4543542626722E6665617475726549643D3D3D652E73746F72652E6765';
wwv_flow_imp.g_varchar2_table(616) := '7453656C656374656449647328295B305D7C7C652E6576656E74732E6368616E67654D6F6465286E2C722C7B73696C656E743A6F7D292C74297D2C742E6765744D6F64653D66756E6374696F6E28297B72657475726E20652E6576656E74732E6765744D';
wwv_flow_imp.g_varchar2_table(617) := '6F646528297D2C742E74726173683D66756E6374696F6E28297B72657475726E20652E6576656E74732E7472617368287B73696C656E743A6F7D292C747D2C742E636F6D62696E6546656174757265733D66756E6374696F6E28297B72657475726E2065';
wwv_flow_imp.g_varchar2_table(618) := '2E6576656E74732E636F6D62696E654665617475726573287B73696C656E743A6F7D292C747D2C742E756E636F6D62696E6546656174757265733D66756E6374696F6E28297B72657475726E20652E6576656E74732E756E636F6D62696E654665617475';
wwv_flow_imp.g_varchar2_table(619) := '726573287B73696C656E743A6F7D292C747D2C742E7365744665617475726550726F70657274793D66756E6374696F6E286E2C722C69297B72657475726E20652E73746F72652E7365744665617475726550726F7065727479286E2C722C692C7B73696C';
wwv_flow_imp.g_varchar2_table(620) := '656E743A6F7D292C747D2C747D286F2C74292C6F2E6170693D743B636F6E737420733D4365286F293B742E6F6E4164643D732E6F6E4164642C742E6F6E52656D6F76653D732E6F6E52656D6F76652C742E74797065733D6E2C742E6F7074696F6E733D65';
wwv_flow_imp.g_varchar2_table(621) := '7D28652C74686973297D72657475726E2079742E6D6F6465733D74742C79742E636F6E7374616E74733D682C79742E6C69623D67742C79747D2C226F626A656374223D3D747970656F66206578706F727473262622756E646566696E656422213D747970';
wwv_flow_imp.g_varchar2_table(622) := '656F66206D6F64756C653F6D6F64756C652E6578706F7274733D7428293A2266756E6374696F6E223D3D747970656F6620646566696E652626646566696E652E616D643F646566696E652874293A28653D22756E646566696E656422213D747970656F66';
wwv_flow_imp.g_varchar2_table(623) := '20676C6F62616C546869733F676C6F62616C546869733A657C7C73656C66292E4D6170626F78447261773D7428293B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43389744536713256)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbox-gl-draw.min.js'
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
wwv_flow_imp.g_varchar2_table(5) := '652D636F6C6F72223A2223666262303362222C2266696C6C2D6F706163697479223A2E317D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D7374726F6B652D696E616374697665222C747970653A226C696E65222C66696C7465723A5B22616C';
wwv_flow_imp.g_varchar2_table(6) := '6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E';
wwv_flow_imp.g_varchar2_table(7) := '64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223336262326430222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D7374726F6B652D61';
wwv_flow_imp.g_varchar2_table(8) := '6374697665222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2274727565225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C6C61796F75743A7B226C696E652D63617022';
wwv_flow_imp.g_varchar2_table(9) := '3A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223666262303362222C226C696E652D646173686172726179223A5B2E322C325D2C226C696E652D7769647468223A327D7D';
wwv_flow_imp.g_varchar2_table(10) := '2C7B69643A22676C2D647261772D6C696E652D696E616374697665222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C224C696E655374';
wwv_flow_imp.g_varchar2_table(11) := '72696E67225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A22';
wwv_flow_imp.g_varchar2_table(12) := '23336262326430222C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D6C696E652D616374697665222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C224C696E65537472';
wwv_flow_imp.g_varchar2_table(13) := '696E67225D2C5B223D3D222C22616374697665222C2274727565225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223';
wwv_flow_imp.g_varchar2_table(14) := '666262303362222C226C696E652D646173686172726179223A5B2E322C325D2C226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D616E642D6C696E652D7665727465782D7374726F6B652D696E6163746976';
wwv_flow_imp.g_varchar2_table(15) := '65222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D657461222C22766572746578225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B22213D222C226D6F6465222C22737461746963225D5D';
wwv_flow_imp.g_varchar2_table(16) := '2C7061696E743A7B22636972636C652D726164697573223A352C22636972636C652D636F6C6F72223A2223666666227D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D616E642D6C696E652D7665727465782D696E616374697665222C747970';
wwv_flow_imp.g_varchar2_table(17) := '653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D657461222C22766572746578225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B22213D222C226D6F6465222C22737461746963225D5D2C7061696E74';
wwv_flow_imp.g_varchar2_table(18) := '3A7B22636972636C652D726164697573223A332C22636972636C652D636F6C6F72223A2223666262303362227D7D2C7B69643A22676C2D647261772D706F696E742D7374726F6B652D696E616374697665222C747970653A22636972636C65222C66696C';
wwv_flow_imp.g_varchar2_table(19) := '7465723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C2266656174757265225D5D2C7061696E743A7B22636972636C652D7261';
wwv_flow_imp.g_varchar2_table(20) := '64697573223A31332C22636972636C652D6F706163697479223A312C22636972636C652D636F6C6F72223A2223666666227D7D2C7B69643A22676C2D647261772D706F696E742D696E616374697665222C747970653A22636972636C65222C66696C7465';
wwv_flow_imp.g_varchar2_table(21) := '723A5B22616C6C222C5B223D3D222C22616374697665222C2266616C7365225D2C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C2266656174757265225D2C5B22213D222C226D6F6465222C22737461746963';
wwv_flow_imp.g_varchar2_table(22) := '225D5D2C7061696E743A7B22636972636C652D726164697573223A31312C22636972636C652D636F6C6F72223A2223336262326430227D7D2C7B69643A22676C2D647261772D706F696E742D7374726F6B652D616374697665222C747970653A22636972';
wwv_flow_imp.g_varchar2_table(23) := '636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C22616374697665222C2274727565225D2C5B22213D222C226D657461222C226D6964706F696E74225D5D2C7061696E743A7B2263';
wwv_flow_imp.g_varchar2_table(24) := '6972636C652D726164697573223A31322C22636972636C652D636F6C6F72223A2223666666227D7D2C7B69643A22676C2D647261772D706F696E742D616374697665222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D';
wwv_flow_imp.g_varchar2_table(25) := '222C222474797065222C22506F696E74225D2C5B22213D222C226D657461222C226D6964706F696E74225D2C5B223D3D222C22616374697665222C2274727565225D5D2C7061696E743A7B22636972636C652D726164697573223A31302C22636972636C';
wwv_flow_imp.g_varchar2_table(26) := '652D636F6C6F72223A2223666262303362227D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D66696C6C2D737461746963222C747970653A2266696C6C222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F6465222C227374617469';
wwv_flow_imp.g_varchar2_table(27) := '63225D2C5B223D3D222C222474797065222C22506F6C79676F6E225D5D2C7061696E743A7B2266696C6C2D636F6C6F72223A2223343034303430222C2266696C6C2D6F75746C696E652D636F6C6F72223A2223343034303430222C2266696C6C2D6F7061';
wwv_flow_imp.g_varchar2_table(28) := '63697479223A2E317D7D2C7B69643A22676C2D647261772D706F6C79676F6E2D7374726F6B652D737461746963222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F6465222C22737461746963225D2C5B223D3D';
wwv_flow_imp.g_varchar2_table(29) := '222C222474797065222C22506F6C79676F6E225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223343034303430222C';
wwv_flow_imp.g_varchar2_table(30) := '226C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D6C696E652D737461746963222C747970653A226C696E65222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F6465222C22737461746963225D2C5B223D3D222C2224';
wwv_flow_imp.g_varchar2_table(31) := '74797065222C224C696E65537472696E67225D5D2C6C61796F75743A7B226C696E652D636170223A22726F756E64222C226C696E652D6A6F696E223A22726F756E64227D2C7061696E743A7B226C696E652D636F6C6F72223A2223343034303430222C22';
wwv_flow_imp.g_varchar2_table(32) := '6C696E652D7769647468223A327D7D2C7B69643A22676C2D647261772D706F696E742D737461746963222C747970653A22636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C226D6F6465222C22737461746963225D2C5B223D3D222C';
wwv_flow_imp.g_varchar2_table(33) := '222474797065222C22506F696E74225D5D2C7061696E743A7B22636972636C652D726164697573223A31302C22636972636C652D636F6C6F72223A2223343034303430227D7D2C7B69643A22676C2D647261772D6D6964706F696E74222C747970653A22';
wwv_flow_imp.g_varchar2_table(34) := '636972636C65222C66696C7465723A5B22616C6C222C5B223D3D222C222474797065222C22506F696E74225D2C5B223D3D222C226D657461222C226D6964706F696E74225D5D2C7061696E743A7B22636972636C652D726164697573223A332C22636972';
wwv_flow_imp.g_varchar2_table(35) := '636C652D636F6C6F72223A2223666262303362227D7D5D3B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(44290539083652466)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbits-draw-style.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F64726177287B705F6974656D5F69643A652C705F616A61785F6964656E7469666965723A742C705F726567696F6E5F69643A6F2C705F67656F6D657472793A6E2C696E69744A733A722C2E2E2E617D297B6675';
wwv_flow_imp.g_varchar2_table(2) := '6E6374696F6E20692865297B617065782E6A5175657279282866756E6374696F6E28297B617065782E6D6573736167652E616C6572742865292C636F6E736F6C652E6C6F672822616C65727420222B65297D29297D6C657420733D737472756374757265';
wwv_flow_imp.g_varchar2_table(3) := '64436C6F6E65284D4150424954535F44454641554C545F445241575F5354594C4553293B766172206C3D612E67656F6D657472795F6D6F6465732C643D612E726561646F6E6C792C753D612E73686F775F636F6F7264732C633D612E706F696E745F7A6F';
wwv_flow_imp.g_varchar2_table(4) := '6F6D5F6C6576656C2C673D612E656E61626C655F67656F6C6F636174653B76617220793D6E657720636C6173737B636F6E7374727563746F7228297B7D6F6E4164642865297B72657475726E20746869732E6D5F6D61703D652C746869732E6D5F636F6E';
wwv_flow_imp.g_varchar2_table(5) := '7461696E65723D646F63756D656E742E637265617465456C656D656E74282264697622292C746869732E67656F6C6F636174655F706F696E745F627574746F6E3D646F63756D656E742E637265617465456C656D656E742822627574746F6E22292C7468';
wwv_flow_imp.g_varchar2_table(6) := '69732E67656F6C6F636174655F706F696E745F627574746F6E2E7374796C653D226C696E652D6865696768743A313670783B77696474683A333270783B6865696768743A333270783B646973706C61793A6E6F6E653B222C746869732E67656F6C6F6361';
wwv_flow_imp.g_varchar2_table(7) := '74655F706F696E745F627574746F6E2E696E6E657248544D4C3D273C6920636C6173733D2266612066612D6C6F636174696F6E2D636972636C65223E3C2F693E272C746869732E67656F6C6F636174655F706F696E745F627574746F6E2E747970653D22';
wwv_flow_imp.g_varchar2_table(8) := '627574746F6E222C746869732E6D5F636F6E7461696E65722E617070656E644368696C6428746869732E67656F6C6F636174655F706F696E745F627574746F6E292C746869732E6D5F636F6E7461696E65722E636C6173734E616D653D226D6170626F78';
wwv_flow_imp.g_varchar2_table(9) := '676C2D6374726C206D61706C69627265676C2D6374726C222C746869732E6D5F636F6E7461696E65727D6F6E52656D6F766528297B746869732E6D5F636F6E7461696E65722E706172656E744E6F64652E72656D6F76654368696C6428746869732E6D5F';
wwv_flow_imp.g_varchar2_table(10) := '636F6E7461696E6572292C746869732E6D5F6D61703D766F696420307D676574427574746F6E28297B72657475726E20746869732E67656F6C6F636174655F706F696E745F627574746F6E7D7D3B636F6E7374205F3D653D3E653E303F4D6174682E666C';
wwv_flow_imp.g_varchar2_table(11) := '6F6F722865293A2D4D6174682E666C6F6F72282D65293B66756E6374696F6E206D2865297B696628653E30297B636F6E737420743D5F2865293B72657475726E204D6174682E666C6F6F722836302A28652D7429297D7B636F6E737420743D5F282D6529';
wwv_flow_imp.g_varchar2_table(12) := '3B72657475726E204D6174682E666C6F6F722836302A282D652D7429297D7D66756E6374696F6E20662865297B636F6E737420743D4D6174682E616273284D6174682E726F756E6428316531312A65292F31653131292C6F3D28333630302A28742D4D61';
wwv_flow_imp.g_varchar2_table(13) := '74682E616273285F287429292D6D2874292F363029292E746F46697865642834293B72657475726E2036303D3D6F3F303A6F7D636F6E737420683D28652C742C6F2C6E293D3E28653D7061727365466C6F61742865292C743D7061727365466C6F617428';
wwv_flow_imp.g_varchar2_table(14) := '74292C6F3D7061727365466C6F6174286F292C69734E614E287429262628743D30292C69734E614E286F292626286F3D30292C653E303F4D6174682E6D696E286E2C4D6174682E6D6178282D6E2C652B742F36302B6F2F3336303029293A4D6174682E6D';
wwv_flow_imp.g_varchar2_table(15) := '696E286E2C4D6174682E6D6178282D6E2C652D742F36302D6F2F333630302929292C623D28293D3E7B636F6E737420743D617065782E6A5175657279282223222B652B225F6C617469747564655F6465677265657322292E76616C28292C6F3D61706578';
wwv_flow_imp.g_varchar2_table(16) := '2E6A5175657279282223222B652B225F6C617469747564655F6D696E7574657322292E76616C28292C6E3D617065782E6A5175657279282223222B652B225F6C617469747564655F7365636F6E647322292E76616C28292C723D617065782E6A51756572';
wwv_flow_imp.g_varchar2_table(17) := '79282223222B652B225F6C6F6E6769747564655F6465677265657322292E76616C28292C613D617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6D696E7574657322292E76616C28292C693D617065782E6A5175657279282223';
wwv_flow_imp.g_varchar2_table(18) := '222B652B225F6C6F6E6769747564655F7365636F6E647322292E76616C28292C733D6828722C612C692C313830292C6C3D6828742C6F2C6E2C3930293B69662869734E614E2873297C7C69734E614E286C292972657475726E3B636F6E737420643D502E';
wwv_flow_imp.g_varchar2_table(19) := '676574416C6C28293B303D3D642E66656174757265732E6C656E6774682626642E66656174757265732E70757368287B747970653A2246656174757265222C70726F706572746965733A7B7D2C67656F6D657472793A7B636F6F7264696E617465733A5B';
wwv_flow_imp.g_varchar2_table(20) := '6E756C6C2C6E756C6C5D7D7D292C642E66656174757265735B305D2E67656F6D657472792E747970653D22506F696E74222C642E66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465735B305D3D732C642E6665617475726573';
wwv_flow_imp.g_varchar2_table(21) := '5B305D2E67656F6D657472792E636F6F7264696E617465735B315D3D6C2C502E7365742864293B636F6E737420753D502E676574416C6C28292E66656174757265735B305D2E67656F6D657472793B51284A534F4E2E737472696E67696679287529292C';
wwv_flow_imp.g_varchar2_table(22) := '772E70616E546F28752E636F6F7264696E61746573292C5F2873293D3D3D7226266D2873293D3D3D612626662873293D3D3D6926265F286C293D3D3D7426266D286C293D3D3D6F262666286C293D3D3D6E7C7C782875297D2C783D743D3E7B6966282128';
wwv_flow_imp.g_varchar2_table(23) := '742E636F6F7264696E617465732E6C656E6774683C3129262622506F696E74223D3D3D742E74797065297B636F6E7374206F3D742E636F6F7264696E617465735B305D2C6E3D742E636F6F7264696E617465735B315D3B617065782E6A51756572792822';
wwv_flow_imp.g_varchar2_table(24) := '23222B652B225F6C6F6E6769747564655F6465677265657322292E76616C285F286F29292C617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6D696E7574657322292E76616C286D286F29292C617065782E6A51756572792822';
wwv_flow_imp.g_varchar2_table(25) := '23222B652B225F6C6F6E6769747564655F7365636F6E647322292E76616C2866286F29292C617065782E6A5175657279282223222B652B225F6C617469747564655F6465677265657322292E76616C285F286E29292C617065782E6A5175657279282223';
wwv_flow_imp.g_varchar2_table(26) := '222B652B225F6C617469747564655F6D696E7574657322292E76616C286D286E29292C617065782E6A5175657279282223222B652B225F6C617469747564655F7365636F6E647322292E76616C2866286E29297D7D3B6C657420773B636F6E737420763D';
wwv_flow_imp.g_varchar2_table(27) := '6E65772050726F6D697365282828652C74293D3E7B636F6E7374206E3D617065782E726567696F6E286F293B6966286E756C6C3D3D6E2972657475726E20617065782E64656275672E6572726F7228226D6170626974735F64726177696E67222B697465';
wwv_flow_imp.g_varchar2_table(28) := '6D49642B22203A20526567696F6E205B222B6F2B225D2069732068696464656E206F72206D697373696E672E22292C766F6964207428293B6E2E656C656D656E742E6F6E28227370617469616C6D6170696E697469616C697A6564222C2828293D3E7B77';
wwv_flow_imp.g_varchar2_table(29) := '3D617065782E726567696F6E286F292E63616C6C28226765744D61704F626A65637422292C73657454696D656F7574282828293D3E65287729292C353030297D29297D29292C6A3D7B6F6E53657475703A66756E6374696F6E28297B72657475726E2074';
wwv_flow_imp.g_varchar2_table(30) := '6869732E736574416374696F6E61626C65537461746528292C7B7D7D2C746F446973706C617946656174757265733A66756E6374696F6E28652C742C6F297B6F2874297D7D2C4D3D4D6170626F78447261772E6D6F6465733B4D2E7374617469633D6A3B';
wwv_flow_imp.g_varchar2_table(31) := '636F6E737420433D28652C74293D3E2121652E6C6E674C6174262628652E6C6E674C61742E6C6E673D3D3D745B305D2626652E6C6E674C61742E6C61743D3D3D745B315D293B6C657420503B4D2E647261775F6C696E655F737472696E672E6F6E4B6579';
wwv_flow_imp.g_varchar2_table(32) := '55703D66756E6374696F6E28652C74297B69662831333D3D3D742E6B6579436F646529746869732E6368616E67654D6F6465282273696D706C655F73656C656374222C7B666561747572654964733A5B652E6C696E652E69645D7D293B656C7365206966';
wwv_flow_imp.g_varchar2_table(33) := '2832373D3D3D742E6B6579436F646529746869732E64656C65746546656174757265285B652E6C696E652E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F6465282273696D706C655F73656C65637422293B656C7365206966';
wwv_flow_imp.g_varchar2_table(34) := '282260223D3D742E6B6579297B696628652E63757272656E74566572746578506F736974696F6E3E3026264328742C652E6C696E652E636F6F7264696E617465735B652E63757272656E74566572746578506F736974696F6E2D315D297C7C226261636B';
wwv_flow_imp.g_varchar2_table(35) := '7761726473223D3D3D652E646972656374696F6E26264328742C652E6C696E652E636F6F7264696E617465735B652E63757272656E74566572746578506F736974696F6E2B315D292972657475726E20746869732E6368616E67654D6F6465282273696D';
wwv_flow_imp.g_varchar2_table(36) := '706C655F73656C656374222C7B666561747572654964733A5B652E6C696E652E69645D7D293B746869732E7570646174655549436C6173736573287B6D6F7573653A22616464227D292C6E6176696761746F722E67656F6C6F636174696F6E2E67657443';
wwv_flow_imp.g_varchar2_table(37) := '757272656E74506F736974696F6E282866756E6374696F6E2874297B652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E74566572746578506F736974696F6E2C742E636F6F7264732E6C6F6E6769747564652C742E636F6F';
wwv_flow_imp.g_varchar2_table(38) := '7264732E6C61746974756465292C22666F7277617264223D3D3D652E646972656374696F6E3F28652E63757272656E74566572746578506F736974696F6E2B2B2C652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E745665';
wwv_flow_imp.g_varchar2_table(39) := '72746578506F736974696F6E2C705B305D2C705B315D29293A652E6C696E652E616464436F6F7264696E61746528302C705B305D2C705B315D297D292C2866756E6374696F6E2874297B766172206F3D5B2E30312A4D6174682E72616E646F6D28292D2E';
wwv_flow_imp.g_varchar2_table(40) := '3030352D39302C2E30312A4D6174682E72616E646F6D28292D2E3030352B33305D3B652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E74566572746578506F736974696F6E2C6F5B305D2C6F5B315D292C22666F72776172';
wwv_flow_imp.g_varchar2_table(41) := '64223D3D3D652E646972656374696F6E3F28652E63757272656E74566572746578506F736974696F6E2B2B2C652E6C696E652E757064617465436F6F7264696E61746528652E63757272656E74566572746578506F736974696F6E2C6F5B305D2C6F5B31';
wwv_flow_imp.g_varchar2_table(42) := '5D29293A652E6C696E652E616464436F6F7264696E61746528302C6F5B305D2C6F5B315D297D29297D7D2C4D2E647261775F706F6C79676F6E2E6F6E4B657955703D66756E6374696F6E28652C74297B69662832373D3D3D742E6B6579436F6465297468';
wwv_flow_imp.g_varchar2_table(43) := '69732E64656C65746546656174757265285B652E706F6C79676F6E2E69645D2C7B73696C656E743A21307D292C746869732E6368616E67654D6F6465282273696D706C655F73656C65637422293B656C73652069662831333D3D3D742E6B6579436F6465';
wwv_flow_imp.g_varchar2_table(44) := '29746869732E6368616E67654D6F6465282273696D706C655F73656C656374222C7B666561747572654964733A5B652E706F6C79676F6E2E69645D7D293B656C7365206966282260223D3D742E6B6579297B696628652E63757272656E74566572746578';
wwv_flow_imp.g_varchar2_table(45) := '506F736974696F6E3E3026264328742C652E706F6C79676F6E2E636F6F7264696E617465735B305D5B652E63757272656E74566572746578506F736974696F6E2D315D292972657475726E20746869732E6368616E67654D6F6465282273696D706C655F';
wwv_flow_imp.g_varchar2_table(46) := '73656C656374222C7B666561747572654964733A5B652E706F6C79676F6E2E69645D7D293B746869732E7570646174655549436C6173736573287B6D6F7573653A22616464227D292C6E6176696761746F722E67656F6C6F636174696F6E2E6765744375';
wwv_flow_imp.g_varchar2_table(47) := '7272656E74506F736974696F6E282866756E6374696F6E2874297B652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F736974696F6E7D602C742E636F6F7264732E6C6F6E676974';
wwv_flow_imp.g_varchar2_table(48) := '7564652C742E636F6F7264732E6C61746974756465292C652E63757272656E74566572746578506F736974696F6E2B2B2C652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F7369';
wwv_flow_imp.g_varchar2_table(49) := '74696F6E7D602C742E636F6F7264732E6C6F6E6769747564652C742E636F6F7264732E6C61746974756465297D292C2866756E6374696F6E2874297B766172206F3D5B2E30312A4D6174682E72616E646F6D28292D2E3030352D39302C2E30312A4D6174';
wwv_flow_imp.g_varchar2_table(50) := '682E72616E646F6D28292D2E3030352B33305D3B652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F736974696F6E7D602C6F5B305D2C6F5B315D292C652E63757272656E745665';
wwv_flow_imp.g_varchar2_table(51) := '72746578506F736974696F6E2B2B2C652E706F6C79676F6E2E757064617465436F6F7264696E6174652860302E247B652E63757272656E74566572746578506F736974696F6E7D602C6F5B305D2C6F5B315D297D29297D7D3B636F6E737420513D6F3D3E';
wwv_flow_imp.g_varchar2_table(52) := '7B696628617065782E6974656D2865292E73657456616C7565286F292C612E77726974656261636B5F656E61626C6564297B6C657420653D646F63756D656E742E626F64792E7374796C652E637572736F723B226E6F742D616C6C6F776564223D3D3D65';
wwv_flow_imp.g_varchar2_table(53) := '262628653D6E756C6C292C617065782E7365727665722E706C7567696E28742C7B7831303A2257524954454241434B222C67656F6D657472793A6F7D2C7B737563636573733A66756E6374696F6E2874297B646F63756D656E742E626F64792E7374796C';
wwv_flow_imp.g_varchar2_table(54) := '652E637572736F723D657D2C6572726F723A66756E6374696F6E28742C6F2C6E297B646F63756D656E742E626F64792E7374796C652E637572736F723D652C69286E297D7D297D617065782E6576656E742E7472696767657228617065782E6A51756572';
wwv_flow_imp.g_varchar2_table(55) := '79282223222B65292C226D696C5F61726D795F75736163655F6D6170626974735F6472617763726561746522297D2C6B3D28293D3E7B636F6E737420653D502E6765744D6F646528292C743D502E67657453656C656374656428292E6665617475726573';
wwv_flow_imp.g_varchar2_table(56) := '2E6C656E6774683B672626285B226469726563745F73656C656374222C22647261775F706F696E74222C22647261775F6C696E655F737472696E67222C22647261775F706F6C79676F6E225D2E696E636C756465732865293F792E676574427574746F6E';
wwv_flow_imp.g_varchar2_table(57) := '28292E7374796C652E646973706C61793D22626C6F636B223A2273696D706C655F73656C656374223D3D3D65262628792E676574427574746F6E28292E7374796C652E646973706C61793D743E303F22626C6F636B223A226E6F6E652229297D2C533D28';
wwv_flow_imp.g_varchar2_table(58) := '293D3E7B636F6E737420743D502E6765744D6F646528293B696628752969662822647261775F706F696E74223D3D3D7429617065782E6A5175657279282223222B652B225F636F6F72647322292E6373732822646973706C6179222C22626C6F636B2229';
wwv_flow_imp.g_varchar2_table(59) := '3B656C73652069662822647261775F6C696E655F737472696E67223D3D3D747C7C22647261775F706F6C79676F6E223D3D3D7429617065782E6A5175657279282223222B652B225F636F6F72647322292E6373732822646973706C6179222C226E6F6E65';
wwv_flow_imp.g_varchar2_table(60) := '22293B656C73657B636F6E737420743D502E676574416C6C28293B742E66656174757265732E6C656E6774683E30262622506F696E7422213D3D742E66656174757265735B305D2E67656F6D657472792E747970652626617065782E6A51756572792822';
wwv_flow_imp.g_varchar2_table(61) := '23222B652B225F636F6F72647322292E6373732822646973706C6179222C226E6F6E6522297D6B28292C617065782E6A5175657279282223222B6F2B22202E6D61706C69627265676C2D63616E76617322292E746F67676C65436C61737328226D617062';
wwv_flow_imp.g_varchar2_table(62) := '6974732D647261772D63726F7373686169722D637572736F72222C5B22647261775F706F696E74222C22647261775F6C696E655F737472696E67222C22647261775F706F6C79676F6E225D2E696E636C75646573287429297D3B617065782E6974656D2E';
wwv_flow_imp.g_varchar2_table(63) := '63726561746528652C7B73657447656F6D657472793A653D3E7B762E7468656E282828293D3E7B502E736574287B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B7B747970653A2246656174757265222C67656F';
wwv_flow_imp.g_varchar2_table(64) := '6D657472793A652C70726F706572746965733A7B7D7D5D7D292C752626782865292C51284A534F4E2E737472696E67696679286529292C502E6368616E67654D6F6465282273696D706C655F73656C65637422292C5328297D29297D2C67657447656F6D';
wwv_flow_imp.g_varchar2_table(65) := '657472793A28293D3E7B6966286E756C6C3D3D772972657475726E206E3F3F6E756C6C3B7B636F6E737420653D502E676574416C6C28293B72657475726E20303D3D3D652E66656174757265732E6C656E6774683F6E756C6C3A652E6665617475726573';
wwv_flow_imp.g_varchar2_table(66) := '5B305D2E67656F6D657472797D7D2C6765744D61703A6173796E6328293D3E617761697420762C676574447261773A28293D3E502C6765745374796C65733A28293D3E732C7365745374796C65733A653D3E7B69662850297468726F77206E6577204572';
wwv_flow_imp.g_varchar2_table(67) := '726F72282243616E6E6F7420736574207374796C6573206166746572207468652064726177696E6720706C7567696E20686173206265656E20696E697469616C697A65642E22293B733D657D7D292C2266756E6374696F6E223D3D747970656F66207226';
wwv_flow_imp.g_varchar2_table(68) := '267228617065782E6974656D286529292C503D6E6577204D6170626F7844726177287B646973706C6179436F6E74726F6C7344656661756C743A21312C7374796C65733A732C636F6E74726F6C733A7B706F696E743A6C2E696E6465784F662822504F49';
wwv_flow_imp.g_varchar2_table(69) := '4E5422293E2D312C6C696E655F737472696E673A6C2E696E6465784F6628224C494E4522293E2D312C706F6C79676F6E3A6C2E696E6465784F662822504F4C59474F4E22293E2D312C74726173683A21642C6D6F6465733A4D7D7D292C762E7468656E28';
wwv_flow_imp.g_varchar2_table(70) := '28743D3E7B6C657420723D226E6F6E65223B69662875297B6E756C6C213D6E3F22506F696E74223D3D6E2E74797065262628723D22626C6F636B22293A6C2E696E6465784F662822504F494E5422293E2D31262628723D22626C6F636B22293B636F6E73';
wwv_flow_imp.g_varchar2_table(71) := '7420743D2428273C64697620616C69676E3D226C6566742220636C6173733D2275692D7769646765742D68656164657220742D526567696F6E2D6865616465722075692D636F726E65722D616C6C206D6170626974732D647261772D636F6F7264666F72';
wwv_flow_imp.g_varchar2_table(72) := '6D223E27292E70726F7028226964222C652B225F636F6F72647322292E637373287B646973706C61793A727D292E617070656E64282428273C64697620636C6173733D226D6170626974732D647261772D636F6F7264666F726D2D726F77223E27292E61';
wwv_flow_imp.g_varchar2_table(73) := '7070656E64282428273C6C6162656C20636C6173733D226D622D6C6F6E223E3C2F6C6162656C3E2729292E617070656E64282428273C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E27292E';
wwv_flow_imp.g_varchar2_table(74) := '70726F7028226964222C652B225F6C6F6E6769747564655F6465677265657322292E70726F702822726561646F6E6C79222C6429292E617070656E64282428273C6C6162656C20636C6173733D226D622D6C6162656C2D646567223E3C2F6C6162656C3E';
wwv_flow_imp.g_varchar2_table(75) := '27292E70726F702822666F72222C652B225F6C6F6E6769747564655F646567726565732229292E617070656E64282428273C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E27292E70726F70';
wwv_flow_imp.g_varchar2_table(76) := '28226964222C652B225F6C6F6E6769747564655F6D696E7574657322292E70726F702822726561646F6E6C79222C6429292E617070656E64282428273C6C6162656C20636C6173733D226D622D6C6162656C2D6D696E223E3C2F6C6162656C3E27292E70';
wwv_flow_imp.g_varchar2_table(77) := '726F702822666F72222C652B225F6C6F6E6769747564655F6D696E757465732229292E617070656E64282428273C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E27292E70726F7028226964';
wwv_flow_imp.g_varchar2_table(78) := '222C652B225F6C6F6E6769747564655F7365636F6E647322292E70726F702822726561646F6E6C79222C6429292E617070656E64282428273C6C6162656C20636C6173733D226D622D6C6162656C2D736563223E3C2F6C6162656C3E27292E70726F7028';
wwv_flow_imp.g_varchar2_table(79) := '22666F72222C652B225F6C6F6E6769747564655F7365636F6E6473222929292E617070656E64282428273C64697620636C6173733D226D6170626974732D647261772D636F6F7264666F726D2D726F77223E27292E617070656E64282428273C6C616265';
wwv_flow_imp.g_varchar2_table(80) := '6C20636C6173733D226D622D6C6174223E3C2F6C6162656C3E2729292E617070656E64282428273C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E27292E70726F7028226964222C652B225F';
wwv_flow_imp.g_varchar2_table(81) := '6C617469747564655F6465677265657322292E70726F702822726561646F6E6C79222C6429292E617070656E64282428273C6C6162656C20636C6173733D226D622D6C6162656C2D646567223E3C2F6C6162656C3E27292E70726F702822666F72222C65';
wwv_flow_imp.g_varchar2_table(82) := '2B225F6C617469747564655F646567726565732229292E617070656E64282428273C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E27292E70726F7028226964222C652B225F6C6174697475';
wwv_flow_imp.g_varchar2_table(83) := '64655F6D696E7574657322292E70726F702822726561646F6E6C79222C6429292E617070656E64282428273C6C6162656C20636C6173733D226D622D6C6162656C2D6D696E223E3C2F6C6162656C3E27292E70726F702822666F72222C652B225F6C6174';
wwv_flow_imp.g_varchar2_table(84) := '69747564655F6D696E757465732229292E617070656E64282428273C696E70757420747970653D226E756D6265722220636C6173733D2275692D746578746669656C6422202F3E27292E70726F7028226964222C652B225F6C617469747564655F736563';
wwv_flow_imp.g_varchar2_table(85) := '6F6E647322292E70726F702822726561646F6E6C79222C6429292E617070656E64282428273C6C6162656C20636C6173733D226D622D6C6162656C2D736563223E3C2F6C6162656C3E27292E70726F702822666F72222C652B225F6C617469747564655F';
wwv_flow_imp.g_varchar2_table(86) := '7365636F6E6473222929293B617065782E6A5175657279282223222B6F2B225F6D61705F726567696F6E22292E617070656E642874297D742E647261773D502C672626742E616464436F6E74726F6C2879292C742E616464436F6E74726F6C2850292C61';
wwv_flow_imp.g_varchar2_table(87) := '7065782E6A517565727928222E6D6170626F78676C2D6374726C2D67726F757022292E616464436C61737328226D61706C69627265676C2D6374726C2D67726F757022292C617065782E6A517565727928222E6D6170626F78676C2D6374726C22292E61';
wwv_flow_imp.g_varchar2_table(88) := '6464436C61737328226D61706C69627265676C2D6374726C22293B636F6E737420613D653D3E7B22456E746572223D3D3D653F2E6B65792626652E70726576656E7444656661756C7428297D3B69662875262628617065782E6A5175657279282223222B';
wwv_flow_imp.g_varchar2_table(89) := '652B225F6C6F6E6769747564655F6465677265657322292E6368616E67652862292E6B657970726573732861292C617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6D696E7574657322292E6368616E67652862292E6B657970';
wwv_flow_imp.g_varchar2_table(90) := '726573732861292C617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F7365636F6E647322292E6368616E67652862292E6B657970726573732861292C617065782E6A5175657279282223222B652B225F6C617469747564655F64';
wwv_flow_imp.g_varchar2_table(91) := '65677265657322292E6368616E67652862292E6B657970726573732861292C617065782E6A5175657279282223222B652B225F6C617469747564655F6D696E7574657322292E6368616E67652862292E6B657970726573732861292C617065782E6A5175';
wwv_flow_imp.g_varchar2_table(92) := '657279282223222B652B225F6C617469747564655F7365636F6E647322292E6368616E67652862292E6B65797072657373286129292C6E756C6C213D6E26262222213D6E29696628502E616464286E292C22506F696E74223D3D6E2E74797065297B7526';
wwv_flow_imp.g_varchar2_table(93) := '2678286E293B7472797B742E6A756D70546F287B63656E7465723A6E2E636F6F7264696E617465732C7A6F6F6D3A632C6475726174696F6E3A3265337D297D63617463682865297B636F6E736F6C652E6C6F6728225B4D61706269747320447261775D20';
wwv_flow_imp.g_varchar2_table(94) := '4661696C656420746F206A756D7020746F20696E697469616C206C6F636174696F6E2E22297D7D656C73657B76617220733D28653D3E7B6C657420743B73776974636828652E74797065297B63617365224C696E65537472696E67223A743D652E636F6F';
wwv_flow_imp.g_varchar2_table(95) := '7264696E617465733B627265616B3B6361736522506F6C79676F6E223A743D652E636F6F7264696E617465735B305D3B627265616B3B63617365224D756C7469506F6C79676F6E223A743D5B5D3B666F7228636F6E7374206F206F6620652E636F6F7264';
wwv_flow_imp.g_varchar2_table(96) := '696E6174657329743D742E636F6E636174286F5B305D293B627265616B3B63617365224D756C74694C696E65537472696E67223A743D5B5D3B666F7228636F6E7374206F206F6620652E636F6F7264696E6174657329743D742E636F6E636174286F297D';
wwv_flow_imp.g_varchar2_table(97) := '766172206F3D6E6577206D61706C69627265676C2E4C6E674C6174426F756E647328745B305D2C745B305D293B666F7228636F6E73742065206F662074296F2E657874656E642865293B72657475726E206F7D29286E293B742E666974426F756E647328';
wwv_flow_imp.g_varchar2_table(98) := '732C7B70616464696E673A35307D297D66756E6374696F6E20702865297B69662822647261775F706F696E74223D3D3D6D6F646529502E736574287B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B7B74797065';
wwv_flow_imp.g_varchar2_table(99) := '3A2246656174757265222C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A22506F696E74222C636F6F7264696E617465733A657D7D5D7D292C792E676574427574746F6E28292E7374796C652E646973706C61793D226E6F6E65';
wwv_flow_imp.g_varchar2_table(100) := '223B656C7365206966282273696D706C655F73656C656374223D3D3D6D6F6465297B696628502E67657453656C656374656428292E66656174757265732E6C656E6774683E302928743D502E67657453656C656374656428292E66656174757265735B30';
wwv_flow_imp.g_varchar2_table(101) := '5D292E67656F6D657472792E636F6F7264696E617465735B305D3D655B305D2C742E67656F6D657472792E636F6F7264696E617465735B315D3D655B315D2C502E736574287B747970653A2246656174757265436F6C6C656374696F6E222C6665617475';
wwv_flow_imp.g_varchar2_table(102) := '7265733A5B745D7D297D656C736520696628226469726563745F73656C656374223D3D3D6D6F6465297B76617220743D502E67657453656C656374656428292E66656174757265735B305D2C6F3D502E67657453656C6563746564506F696E747328292E';
wwv_flow_imp.g_varchar2_table(103) := '66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465733B66756E6374696F6E206E2874297B666F7228766172206E3D303B6E3C742E6C656E6774683B6E2B2B296F5B305D3D3D745B6E5D5B305D26266F5B315D3D3D745B6E5D5B';
wwv_flow_imp.g_varchar2_table(104) := '315D262628745B6E5D5B305D3D655B305D2C745B6E5D5B315D3D655B315D297D696628224C696E65537472696E67223D3D3D742E67656F6D657472792E74797065296E28742E67656F6D657472792E636F6F7264696E61746573293B656C736520696628';
wwv_flow_imp.g_varchar2_table(105) := '22506F6C79676F6E223D3D3D742E67656F6D657472792E7479706529666F722876617220723D303B723C742E67656F6D657472792E636F6F7264696E617465732E6C656E6774683B722B2B296E28742E67656F6D657472792E636F6F7264696E61746573';
wwv_flow_imp.g_varchar2_table(106) := '5B725D293B502E736574287B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A5B745D7D297D7D642626502E6368616E67654D6F6465282273746174696322292C6472617776657274696365733D7B69643A37393831';
wwv_flow_imp.g_varchar2_table(107) := '2C747970653A2246656174757265222C70726F706572746965733A7B7D2C67656F6D657472793A7B747970653A224C696E65537472696E67222C636F6F7264696E617465733A5B5D7D7D2C742E6F6E2822647261772E637265617465222C2866756E6374';
wwv_flow_imp.g_varchar2_table(108) := '696F6E2865297B6C657420743D502E676574416C6C28293B666F72286C6574206F3D303B6F3C742E66656174757265732E6C656E6774682D313B6F2B2B29652E66656174757265735B305D2E6964213D742E66656174757265735B6F5D2E69642626502E';
wwv_flow_imp.g_varchar2_table(109) := '64656C65746528742E66656174757265735B6F5D2E6964293B743D502E676574416C6C28293B636F6E7374206F3D742E66656174757265735B305D2E67656F6D657472793B75262678286F292C51284A534F4E2E737472696E67696679286F29297D2929';
wwv_flow_imp.g_varchar2_table(110) := '2C742E6F6E2822647261772E757064617465222C2866756E6374696F6E2865297B636F6E737420743D502E676574416C6C28292E66656174757265735B305D2E67656F6D657472793B752626782874292C51284A534F4E2E737472696E67696679287429';
wwv_flow_imp.g_varchar2_table(111) := '297D29292C742E6F6E2822647261772E64656C657465222C2866756E6374696F6E2874297B75262628617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F6465677265657322292E76616C282222292C617065782E6A5175657279';
wwv_flow_imp.g_varchar2_table(112) := '282223222B652B225F6C6F6E6769747564655F6D696E7574657322292E76616C282222292C617065782E6A5175657279282223222B652B225F6C6F6E6769747564655F7365636F6E647322292E76616C282222292C617065782E6A517565727928222322';
wwv_flow_imp.g_varchar2_table(113) := '2B652B225F6C617469747564655F6465677265657322292E76616C282222292C617065782E6A5175657279282223222B652B225F6C617469747564655F6D696E7574657322292E76616C282222292C617065782E6A5175657279282223222B652B225F6C';
wwv_flow_imp.g_varchar2_table(114) := '617469747564655F7365636F6E647322292E76616C28222229292C51286E756C6C297D29292C742E6F6E2822647261772E6D6F64656368616E6765222C53292C742E6F6E2822647261772E73656C656374696F6E6368616E6765222C2866756E6374696F';
wwv_flow_imp.g_varchar2_table(115) := '6E2865297B6B28297D29292C67262628792E676574427574746F6E28292E6F6E636C69636B3D66756E6374696F6E2865297B636F6E7374206F3D502E6765744D6F646528293B5B22647261775F706F696E74222C226469726563745F73656C656374222C';
wwv_flow_imp.g_varchar2_table(116) := '2273696D706C655F73656C656374225D2E696E636C75646573286F293F6E6176696761746F722E67656F6C6F636174696F6E3F6E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E282866756E6374696F';
wwv_flow_imp.g_varchar2_table(117) := '6E2865297B70285B652E636F6F7264732E6C6F6E6769747564652C652E636F6F7264732E6C617469747564655D297D292C2866756E6374696F6E2865297B70285B2E30312A4D6174682E72616E646F6D28292D2E3030352D39302C2E30312A4D6174682E';
wwv_flow_imp.g_varchar2_table(118) := '72616E646F6D28292D2E3030352B33305D297D29293A69282247656F6C6F636174696F6E206E6F7420737570706F727465642E22293A5B22647261775F6C696E655F737472696E67222C22647261775F706F6C79676F6E225D2E696E636C75646573286F';
wwv_flow_imp.g_varchar2_table(119) := '292626742E676574436F6E7461696E657228292E64697370617463684576656E74286E6577204B6579626F6172644576656E7428226B65797570222C7B6B65793A2260227D29297D297D29297D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(86809812789784632)
,p_plugin_id=>wwv_flow_imp.id(43381211524713251)
,p_file_name=>'mapbits-draw.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
