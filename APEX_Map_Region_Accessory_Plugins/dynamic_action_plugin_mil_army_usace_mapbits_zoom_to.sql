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
--   Date and Time:   07:59 Tuesday August 12, 2025
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 95173023119871702
--   Manifest End
--   Version:         23.2.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/mil_army_usace_mapbits_zoom_to
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(95173023119871702)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MIL.ARMY.USACE.MAPBITS.ZOOM_TO'
,p_display_name=>'Mapbits Zoom To'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-zoomto#MIN#.js'
,p_css_file_urls=>'#PLUGIN_FILES#mapbits-zoomto#MIN#.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function mapbits_zoom_ajax (',
'    p_dynamic_action in apex_plugin.t_dynamic_action,',
'    p_plugin         in apex_plugin.t_plugin )',
'    return apex_plugin.t_dynamic_action_ajax_result is',
'  l_query p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'  query_type p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;',
'  dist_div_code   varchar2(25);',
'  xmin number;',
'  ymin number;',
'  xmax number;',
'  ymax number;',
'  rt2 apex_plugin.t_dynamic_action_ajax_result;',
'  i integer;',
'  query_ctx apex_exec.t_context;',
'  n_cols number;',
'  l_shape sdo_geometry;',
'  l_dim sdo_dim_array;',
'  rt varchar2(4000);',
'begin',
'  -- X01 is ''Y'' if there is an initialization conflict, ''N'' otherwise.',
'  -- if there is an initalization conflict with the map, produce the error message for the programmer. ',
'  -- couldn''t do this in the render function for some reason.',
'  if apex_application.g_x01 = ''Y'' then',
'    apex_debug.error(''Configuration ERROR: Mapbits Zoom To DA [%s] conflicts with map region''''s ''''Initial Position and Zoom''''. '' ||',
'      ''If Zoom To DA fires on initalization or if event triggering is ''''Page Load'''' or ''''Spatial Map Initialized'''', then the map''''s ''''Initial Position and Zoom'''''' || ',
'      ''must be set to ''''Static Values'''' (The actual values don''''t matter). Otherwise, the ''''Initial Position and Zoom'''' will be used to setup the initial map view extent.'', p_dynamic_action.id);',
'  end if;',
'',
'  -- run the plugin query for the extent and convert the result to sdo_geometry.',
'  query_ctx := apex_exec.open_query_context(',
'    p_location => apex_exec.c_location_local_db,',
'    p_sql_query => l_query',
'  );',
'  if apex_exec.next_row(query_ctx) then',
'    case query_type',
'      when ''sdo_geometry'' then',
'        l_shape := apex_exec.get_sdo_geometry(query_ctx, 1);',
'      when ''GeoJSON'' then',
'        l_shape := sdo_util.from_geojson(apex_exec.get_clob(query_ctx, 1));',
'      else',
'        rt := ''{"message" : "Map Layer Zoom To - Unexpected query_type ['' || query_type || '']."}'';',
'    end case;',
'  else',
'    -- No data found',
'    rt := ''{"message" : "Map Layer Zoom To - No data found from query results."}'';',
'  end if;',
'',
'  apex_exec.close(query_ctx);',
'',
'  -- Prepare response. If extent shape is null produce error, else produce the extent.',
'  if l_shape is null then',
'    rt := ''{"message" : "Could not create geometry. One reason for this could be the size of the GeoJSON data, which is limited to 32767 characters. Consider using the function SDO_GEOM.SDO_MBR return a smaller geometry. Also, ensure you have the cor'
||'rect query type selected."}'';',
'  else',
'    select SDO_GEOM.SDO_MIN_MBR_ORDINATE(l_shape,  1), SDO_GEOM.SDO_MIN_MBR_ORDINATE(l_shape,  2),',
'      SDO_GEOM.SDO_MAX_MBR_ORDINATE(l_shape,  1), SDO_GEOM.SDO_MAX_MBR_ORDINATE(l_shape, 2) ',
'      into xmin,ymin,xmax,ymax   from dual;',
'    rt := ''{"data" : ['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']}'';',
'  end if;',
'  ',
'  -- write to HTTP',
'  htp.init;',
'  owa_util.mime_header(''application/json'', FALSE);',
'  owa_util.http_header_close;  ',
'  htp.p(rt);',
'  return rt2;',
'end;',
'',
'function mapbits_zoom (',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin )',
'  return apex_plugin.t_dynamic_action_render_result is',
'    l_region_id varchar2(4000);',
'    l_action_name apex_application_page_da.dynamic_action_name%type;',
'    l_region_type apex_application_page_regions.source_type%type;',
'    l_event_name apex_application_page_da.when_event_internal_name%type;',
'    l_exec_init apex_application_page_da_acts.execute_on_page_init%type;',
'    l_initial_pos_type apex_appl_page_maps.initial_pos_type%type;',
'    rt apex_plugin.t_dynamic_action_render_result;',
'    l_pits p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_pitss p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'    l_skip_animation p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;',
'    l_padding p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;',
'    l_maxzoom p_dynamic_action.attribute_07%type := p_dynamic_action.attribute_07;',
'    l_init_conflict boolean;',
'begin',
'  begin',
'    select nvl(r.static_id, ''R''||da.affected_region_id), r.source_type, da.dynamic_action_name, ',
'      decode(d.when_event_internal_name, ''NATIVE_MAP_REGION|REGION TYPE|spatialmapinitialized'', ''spatialmapinitialized'', ''ready'', ''load'', ''other''), ',
'      decode(da.execute_on_page_init, ''Yes'', ''Y'', ''No'', ''N'', ''?''),',
'      m.initial_pos_type',
'      into l_region_id, l_region_type, l_action_name, l_event_name, l_exec_init, l_initial_pos_type',
'      from apex_application_page_da_acts da',
'      inner join apex_application_page_regions r on da.affected_region_id = r.region_id',
'      inner join apex_application_page_da d on d.dynamic_action_id = da.dynamic_action_id',
'      inner join apex_appl_page_maps m on m.region_id = r.region_id',
'      and da.application_id = v(''APP_ID'') and da.page_id = v(''APP_PAGE_ID'')',
'      and da.action_id = p_dynamic_action.id;',
'    if not l_region_type = ''Map'' then',
'      raise_application_error(-20341, ''Configuration ERROR: Mapbits Mapbits Zoom To DA for "'' || l_action_name ||  ''" ['' || p_dynamic_action.id || ''] is associated with the wrong type of region. It must be associated with a Map region. Check the Affe'
||'cted Elements section of the plugin settings.'');',
'    end if;',
'    if not l_initial_pos_type = ''Static Values'' and (l_event_name in (''load'', ''spatialmapinitialized'') or l_exec_init = ''Y'') then',
'      l_init_conflict := true;',
'    else',
'      l_init_conflict := false;',
'    end if;',
'  exception when NO_DATA_FOUND then',
'    raise_application_error(-20361, ''Configuration ERROR: Mapbits Zoom To DA ['' || p_dynamic_action.id || ''] is not associated with a region. It must be associated with a Map region.  Check the Affected Elements section of the plugin settings.'');',
'  end;',
'  rt.javascript_function := ''function () {mapbits_zoom({''',
'    || apex_javascript.add_attribute(''p_action_id'', p_dynamic_action.id)',
'    || apex_javascript.add_attribute(''p_ajax_identifier'', apex_plugin.get_ajax_identifier)',
'    || apex_javascript.add_attribute(''p_region_id'', l_region_id)',
'    || apex_javascript.add_attribute(''p_item_to_submit'', l_pits)',
'    || apex_javascript.add_attribute(''p_items_to_submit'', l_pitss)',
'    || apex_javascript.add_attribute(''p_skip_animation'', l_skip_animation)',
'    || apex_javascript.add_attribute(''p_padding'', l_padding)',
'    || apex_javascript.add_attribute(''p_maxzoom'', l_maxzoom)',
'    || apex_javascript.add_attribute(''p_init_conflict'', l_init_conflict)',
'    || ''p_event: this.browserEvent''',
'    || ''});}'';',
'  return rt;',
'end;'))
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'mapbits_zoom'
,p_ajax_function=>'mapbits_zoom_ajax'
,p_standard_attributes=>'REGION:REQUIRED:ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>false
,p_help_text=>'The Mapbits Zoom To plugin is a dynamic action that zooms and recenters the map viewport based on the extent of a GeoJSON format feature in a page item. If you are running this action when the page first loads, you must set the ''Initial Position and '
||'Zoom'' to ''Static Values.'''
,p_version_identifier=>'4.9.20250506'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Zoom To',
'Location : $Id: dynamic_action_plugin_mil_army_usace_mapbits_zoom_to.sql 20908 2025-08-12 13:01:49Z b2eddjw9 $',
'Date     : $Date: 2025-08-12 08:01:49 -0500 (Tue, 12 Aug 2025) $',
'Revision : $Revision: 20908 $',
'Requires : Application Express >= 23.2',
'',
'09/12/2025 Use APEX_JAVASCRIPT package to pass parameters to Javascript (fixes a bug in locales where commas are used instead of decimal points)',
'09/08/2025 Added Max Zoom attribute',
'',
'Version 4.9 Updates:',
'05/06/2025 Removed the need to poll for the map but handling the ''Page Load'' event by hooking the javascript code to the ''Map Initialized'' event. Added an error message to the APEX logger if',
'the event triggers on ''Page Load'', ''Map Initialized'' or if the action "fires on initialization" and the associated map does not use ''Static Values for the ''Initial Position and Zoom'' setting.',
'This configuration conflict causes the zoom to fail the first time it is executed in a session.',
'01/15/2025 Return error messages from the ajax process instead of raising exception if there is no geometry upon which to base the zoom. Write the error message to the javascript console instead of propagating it to the application. ',
'',
'',
'Version 4.8 Updates:',
'06/04/2024 Added padding attribute.',
'',
'Version 4.6 Updates:',
'12/18/2023 Add option to skip the animation',
'12/01/2023 Raise an application error if this plugin item is not associated with a Map region.',
'11/07/2023 Created a new attribute to allow multiple "Page Items To Submit". The old attribute that only supported one item is deprecated.',
'',
'Version 4.5 Updates:',
'7/13/2023 Using setInterval to iterate calls to getMapObject until a ready map is returned. This was intended to fix cases where the dynamic action is used on page load events.',
'',
'Version 4.4 Updates:',
'03/28/2023 Removed requirement to have a ''Page Item to Submit'' attribute. ',
'',
'Version 4.3 Updates:',
'08/13/2022 Test with maplibre. No changes. Bumping version.',
'03/24/2022 Added error message if geometry is too large. Edited help text to encourage use of MBR.',
'12/07/2022 Break out of javascript function if the region is null to avoid javascript errors breaking the rest of page. This is common for ''load'' dynamic actions. '))
,p_files_version=>188
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(95173313260871704)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>50
,p_prompt=>'Page Item to Submit (Deprecated)'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Use ''Page Items To Submit'' (plural) instead.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(95173753733871706)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Query Returning Extent Geometry'
,p_attribute_type=>'SQL'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'select sdo_util.to_geojson(sdo_geom.sdo_mbr(shape)) from mb4_usace_districts where rownum = 1'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Query Returning Extent Geometry. This query should consists of one row and one column where the value is in GeoJSON format. There is a 32,767 character limit on the size of the GeoJSON text. It is strongly advised to use the ',
'sdo_geom.sdo_mbr function.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(95174149538871707)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Page Items To Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If the ''Query Returning Extent Geometry'' is',
'',
'select sdo_util.to_geojson(shape) from mb4_usace_districts where usace_district_id = :P13_SEL_DISTRICT',
'',
'Then the ''Page Item to Submit'' would be',
'',
'P13_SEL_DISTRICT'))
,p_help_text=>'Page item to submit prior to running the query in ''Query Returning Extent Geometry''. This page item is usually referenced in the where clause of the Zoom To query attribute.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(95174576868871708)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Skip Animation'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(95174945341871708)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>10
,p_prompt=>'Query Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'GeoJSON'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'The data type that the query returns.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(95175314313871709)
,p_plugin_attribute_id=>wwv_flow_imp.id(95174945341871708)
,p_display_sequence=>10
,p_display_value=>'GeoJSON'
,p_return_value=>'GeoJSON'
,p_help_text=>'The query returns a single text column containing GeoJSON.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(95175829135871710)
,p_plugin_attribute_id=>wwv_flow_imp.id(95174945341871708)
,p_display_sequence=>20
,p_display_value=>'SDO_GEOMETRY'
,p_return_value=>'sdo_geometry'
,p_help_text=>'The query returns a single column with type sdo_geometry.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(95176370715871710)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Padding'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'5'
,p_is_translatable=>false
,p_help_text=>'Amount of padding to leave around the geometry, in pixels.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(215177842390201825)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Max Zoom'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'The maximum level to zoom to'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D287B0D0A2020705F616374696F6E5F69642C0D0A2020705F616A61785F6964656E7469666965722C0D0A2020705F726567696F6E5F69642C0D0A2020705F6974656D5F746F5F7375626D69742C0D0A';
wwv_flow_imp.g_varchar2_table(2) := '2020705F6974656D735F746F5F7375626D69742C0D0A2020705F736B69705F616E696D6174696F6E2C0D0A2020705F70616464696E672C0D0A2020705F6D61787A6F6F6D2C0D0A2020705F696E69745F636F6E666C6963742C0D0A2020705F6576656E74';
wwv_flow_imp.g_varchar2_table(3) := '2C0D0A7D29207B0D0A20202F2F2072616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D6573736167652C206D73672C20616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F';
wwv_flow_imp.g_varchar2_table(4) := '6E20617065785F616C657274286D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B636F6E736F6C652E6C6F6728705F616374696F6E5F6964202B20222022202B206D7367293B7D293B0D0A20207D0D0A0D0A20202F';
wwv_flow_imp.g_varchar2_table(5) := '2F206765742074686520726567696F6E206F626A6563742E20425265616B206F7574206966206974206973206E6F742072656E64657265642E0D0A202076617220726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D';
wwv_flow_imp.g_varchar2_table(6) := '0A202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020617065785F616C65727428276D6170626974735F7A6F6F6D2027202B20705F616374696F6E5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964';
wwv_flow_imp.g_varchar2_table(7) := '202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A20200D0A202066756E6374696F6E207A6F6F6D5F746F2829207B0D0A202020202F2F2063616C6C206261636B207468652061';
wwv_flow_imp.g_varchar2_table(8) := '7065782073657276657220746F206765742074686520626F756E647320636F72726573706F6E64696E6720746F0D0A202020202F2F2074686520657874656E7420636F64652E204966207375636365737366756C2C20746865206173736F636961746564';
wwv_flow_imp.g_varchar2_table(9) := '206D617020726567696F6E2028705F726567696F6E5F6964290D0A202020202F2F2077696C6C2070616E20616E64207A6F6F6D20746F2074686F736520626F756E64732E204F74686572776973652C2073686F7720746865206572726F72206D65737361';
wwv_flow_imp.g_varchar2_table(10) := '67650D0A202020202F2F20696E2061206A61766173637269707420616C6572742E0D0A202020202F2F20506173732074686520696E697469616C20636F6E666C69637420666C616720696E207468652078303120617267756D656E7420746F2067656E65';
wwv_flow_imp.g_varchar2_table(11) := '7261746520616E206572726F72206D6573736167650D0A202020202F2F20746F206C6574207468652070726F6772616D6D6572206B6E6F772061626F7574207468652070726F626C656D20776974686F757420627265616B696E67207468652070616765';
wwv_flow_imp.g_varchar2_table(12) := '2E0D0A20202020636F6E7374206D6170203D20726567696F6E2E63616C6C28226765744D61704F626A65637422293B0D0A20202020636F6E737420706167654974656D73203D205B705F6974656D5F746F5F7375626D69742C202E2E2E705F6974656D73';
wwv_flow_imp.g_varchar2_table(13) := '5F746F5F7375626D69742E73706C697428222C22295D2E66696C7465722878203D3E2078293B0D0A202020206D61702E67657443616E76617328292E636C6173734C6973742E61646428276D6170626974732D7A6F6F6D2D61637469766527293B0D0A20';
wwv_flow_imp.g_varchar2_table(14) := '202020617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B783031203A20705F696E69745F636F6E666C696374203F20275927203A20274E272C20706167654974656D737D2C20207B0D0A20202020202064';
wwv_flow_imp.g_varchar2_table(15) := '61746154797065203A20276A736F6E272C0D0A202020202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A20202020202020206966202870446174612E6461746129207B0D0A20202020202020202020636F6E7374206D6170';
wwv_flow_imp.g_varchar2_table(16) := '203D20726567696F6E2E63616C6C28226765744D61704F626A65637422293B0D0A20202020202020202020747279207B0D0A202020202020202020202020636F6E7374206F707473203D207B0D0A202020202020202020202020202070616464696E673A';
wwv_flow_imp.g_varchar2_table(17) := '207061727365496E7428705F70616464696E67207C7C20273527292C0D0A2020202020202020202020202020616E696D6174653A20705F736B69705F616E696D6174696F6E20213D3D202759272C0D0A2020202020202020202020207D3B0D0A20202020';
wwv_flow_imp.g_varchar2_table(18) := '202020202020202069662028705F6D61787A6F6F6D29207B0D0A20202020202020202020202020206F7074732E6D61785A6F6F6D203D207061727365466C6F617428705F6D61787A6F6F6D293B0D0A2020202020202020202020207D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(19) := '2020202020206D61702E666974426F756E64732870446174612E646174612C206F707473293B0D0A202020202020202020207D20636174636820286529207B0D0A2020202020202020202020207468726F77206E6577204572726F7228224572726F7220';
wwv_flow_imp.g_varchar2_table(20) := '66697474696E6720626F756E64732E20436865636B207468617420746865206D617020726567696F6E20616E64205A6F6F6D20546F20706C7567696E206172652070726F7065726C7920636F6E666967757265642E22293B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(21) := '7D0D0A20202020202020207D20656C7365207B0D0A20202020202020202020617065785F616C6572742870446174612E6D657373616765293B0D0A20202020202020207D0D0A20202020202020206D61702E67657443616E76617328292E636C6173734C';
wwv_flow_imp.g_varchar2_table(22) := '6973742E72656D6F766528276D6170626974732D7A6F6F6D2D61637469766527293B0D0A2020202020207D2C0D0A2020202020206572726F723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(23) := '617065785F616C65727428276D6170626974735F7A6F6F6D2027202B20705F616374696F6E5F6964202B20272067656E6572616C206661696C75726527293B0D0A20202020202020206D61702E67657443616E76617328292E636C6173734C6973742E72';
wwv_flow_imp.g_varchar2_table(24) := '656D6F766528276D6170626974732D7A6F6F6D2D61637469766527293B0D0A2020202020207D0D0A202020207D293B0D0A20207D0D0A20200D0A20202F2F20696620746865206576656E7420697320612070616765206C6F6164206576656E742C20686F';
wwv_flow_imp.g_varchar2_table(25) := '6F6B20746865207370617469616C6D6170696E697469616C697A6564206576656E74200D0A20202F2F20746F207A6F6F6D5F746F2066756E6374696F6E2073696E636520746865206D6170206973206E6F742079657420696E697469616C697A65642C20';
wwv_flow_imp.g_varchar2_table(26) := '656C73650D0A20202F2F2072756E207A6F6F6D5F746F2E0D0A202069662028705F6576656E74203D3D20226C6F616422207C7C20705F6576656E742E74797065203D3D20226C6F61642229207B0D0A20202020726567696F6E2E6F6E2827737061746961';
wwv_flow_imp.g_varchar2_table(27) := '6C6D6170696E697469616C697A6564272C207A6F6F6D5F746F293B200D0A20207D20656C7365207B0D0A202020207A6F6F6D5F746F28293B0D0A20207D0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(95176798941871715)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_file_name=>'mapbits-zoomto.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D6170626974732D7A6F6F6D2D616374697665207B0D0A2020637572736F723A206E6F742D616C6C6F7765643B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(96101462051528007)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_file_name=>'mapbits-zoomto.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D6170626974732D7A6F6F6D2D6163746976657B637572736F723A6E6F742D616C6C6F7765647D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(96102938636528681)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_file_name=>'mapbits-zoomto.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D287B705F616374696F6E5F69643A612C705F616A61785F6964656E7469666965723A742C705F726567696F6E5F69643A692C705F6974656D5F746F5F7375626D69743A652C705F6974656D735F746F';
wwv_flow_imp.g_varchar2_table(2) := '5F7375626D69743A6F2C705F736B69705F616E696D6174696F6E3A6E2C705F70616464696E673A732C705F6D61787A6F6F6D3A702C705F696E69745F636F6E666C6963743A722C705F6576656E743A6D7D297B66756E6374696F6E20632874297B617065';
wwv_flow_imp.g_varchar2_table(3) := '782E6A5175657279282866756E6374696F6E28297B636F6E736F6C652E6C6F6728612B2220222B74297D29297D766172206C3D617065782E726567696F6E2869293B66756E6374696F6E205F28297B636F6E737420693D6C2E63616C6C28226765744D61';
wwv_flow_imp.g_varchar2_table(4) := '704F626A65637422292C6D3D5B652C2E2E2E6F2E73706C697428222C22295D2E66696C7465722828613D3E6129293B692E67657443616E76617328292E636C6173734C6973742E61646428226D6170626974732D7A6F6F6D2D61637469766522292C6170';
wwv_flow_imp.g_varchar2_table(5) := '65782E7365727665722E706C7567696E28742C7B7830313A723F2259223A224E222C706167654974656D733A6D7D2C7B64617461547970653A226A736F6E222C737563636573733A66756E6374696F6E2861297B696628612E64617461297B636F6E7374';
wwv_flow_imp.g_varchar2_table(6) := '20743D6C2E63616C6C28226765744D61704F626A65637422293B7472797B636F6E737420693D7B70616464696E673A7061727365496E7428737C7C223522292C616E696D6174653A225922213D3D6E7D3B70262628692E6D61785A6F6F6D3D7061727365';
wwv_flow_imp.g_varchar2_table(7) := '466C6F6174287029292C742E666974426F756E647328612E646174612C69297D63617463682861297B7468726F77206E6577204572726F7228224572726F722066697474696E6720626F756E64732E20436865636B207468617420746865206D61702072';
wwv_flow_imp.g_varchar2_table(8) := '6567696F6E20616E64205A6F6F6D20546F20706C7567696E206172652070726F7065726C7920636F6E666967757265642E22297D7D656C7365206328612E6D657373616765293B692E67657443616E76617328292E636C6173734C6973742E72656D6F76';
wwv_flow_imp.g_varchar2_table(9) := '6528226D6170626974732D7A6F6F6D2D61637469766522297D2C6572726F723A66756E6374696F6E28742C652C6F297B6328226D6170626974735F7A6F6F6D20222B612B222067656E6572616C206661696C75726522292C692E67657443616E76617328';
wwv_flow_imp.g_varchar2_table(10) := '292E636C6173734C6973742E72656D6F766528226D6170626974732D7A6F6F6D2D61637469766522297D7D297D6E756C6C213D6C3F226C6F6164223D3D6D7C7C226C6F6164223D3D6D2E747970653F6C2E6F6E28227370617469616C6D6170696E697469';
wwv_flow_imp.g_varchar2_table(11) := '616C697A6564222C5F293A5F28293A6328226D6170626974735F7A6F6F6D20222B612B22203A20526567696F6E205B222B692B225D2069732068696464656E206F72206D697373696E672E22297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(218949532175746407)
,p_plugin_id=>wwv_flow_imp.id(95173023119871702)
,p_file_name=>'mapbits-zoomto.min.js'
,p_mime_type=>'text/javascript'
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
