prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.04.15'
,p_release=>'21.1.7'
,p_default_workspace_id=>9502877444580501
,p_default_application_id=>101
,p_default_id_offset=>0
,p_default_owner=>'MTG'
);
end;
/
 
prompt APPLICATION 101 - Mapbits Demo
--
-- Application Export:
--   Application:     101
--   Name:            Mapbits Demo
--   Date and Time:   13:35 Sunday February 20, 2022
--   Exported By:     GREP5
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 12780717908592151
--   Manifest End
--   Version:         21.1.7
--   Instance ID:     9502674331986296
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_geolocation
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(12780717908592151)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.GEOLOCATION'
,p_display_name=>'Mapbits Geolocation'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-geolocation.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure map_geolocation_render (',
'    p_item   in            apex_plugin.t_item,',
'    p_plugin in            apex_plugin.t_plugin,',
'    p_param  in            apex_plugin.t_item_render_param,',
'    p_result in out nocopy apex_plugin.t_item_render_result ) is',
'    l_region_id varchar2(400);',
'    l_geometry_modes p_item.attribute_01%type := p_item.attribute_01;',
'    l_geom_collection_name p_item.attribute_02%type := p_item.attribute_02;',
'    l_readonly varchar2(5);',
'    l_geojson clob;',
'    l_error varchar2(4000) := '''';',
'    l_show_coords p_item.attribute_04%type := p_item.attribute_04;',
'    l_buffersize number:=80;',
'    l_offset integer;',
'    l_pointZoomLevel p_item.attribute_06%type := nvl(p_item.attribute_06, 12);',
'',
'    l_track varchar2(5);',
'    l_heading varchar2(5);',
'begin',
'  if p_item.attribute_01  = ''Y'' then',
'    l_track := ''true'';',
'  else',
'    l_track := ''false'';',
'  end if;',
'  if p_item.attribute_02 = ''Y'' then',
'    l_heading := ''true'';',
'  else',
'    l_heading := ''false'';',
'  end if;',
'',
'  -- Get the map region id for which this item is associated. If this failed, propagate an error.',
'  begin',
'    select nvl(r.static_id, ''R'' || r.region_id) into l_region_id  ',
'      from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then ',
'      apex_debug.message(',
'        p_message => ''ERROR: Geolocation [%s] is not associated with a Map region.'',',
'        p0      => p_item.name,',
'        p_level   => apex_debug.c_log_level_error',
'      );',
'      l_error := l_error || ''Configuration ERROR: Geolocation ['' || p_item.name || ''] is not associated with a Map region.'';',
'  end;',
'  htp.p(''<div id="'' || p_item.name || ''" name="'' || p_item.name || ''"></div>'');',
'',
'  -- Call the javascript',
'  apex_javascript.add_onload_code(p_code => ''apex.jQuery(apex.gPageContext$).on("apexreadyend", function(){',
'    mapbits_geolocation("'' || p_item.name || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", {"trackUserLocation" : '' || l_track || '', "showUserHeading" : ''  || l_heading || ''});',
'    });'', p_key => ''MIL.ARMY.USACE.MAPBITS.GEOLOCATION'');',
'end;'))
,p_api_version=>2
,p_render_function=>'map_geolocation_render'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>If the browser has geolocation enabled, the Mapbits Geolocation plugin can show the user''s location as a pulsing dot.</p>',
'<p>Add the plugin in to the map region in which you wish to show the user''s location.</p>'))
,p_version_identifier=>'4.2.20220216'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Geolocation',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_geolocation.sql 17076 2022-02-20 13:46:02Z b2imimcf $',
'Date     : $Date: 2022-02-20 07:46:02 -0600 (Sun, 20 Feb 2022) $',
'Revision : $Revision: 17076 $',
'Requires : Application Express >= 21.1',
'',
'',
'',
''))
,p_files_version=>36
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(12803654304283287)
,p_plugin_id=>wwv_flow_api.id(12780717908592151)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Track User  Location'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(12804240951285563)
,p_plugin_id=>wwv_flow_api.id(12780717908592151)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Show User Heading'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(12785953909592166)
,p_plugin_id=>wwv_flow_api.id(12780717908592151)
,p_name=>'mil_army_usace_mapbits_geolocate'
,p_display_name=>'Geolocate'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(12802041796091694)
,p_plugin_id=>wwv_flow_api.id(12780717908592151)
,p_name=>'mil_army_usace_mapbits_geolocate_error'
,p_display_name=>'Error'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(12802860481091696)
,p_plugin_id=>wwv_flow_api.id(12780717908592151)
,p_name=>'mil_army_usace_mapbits_geolocate_trackend'
,p_display_name=>'Track End'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(12802402351091696)
,p_plugin_id=>wwv_flow_api.id(12780717908592151)
,p_name=>'mil_army_usace_mapbits_geolocate_trackstart'
,p_display_name=>'Track Start'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F67656F6C6F636174696F6E28705F6974656D5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F6F7074696F6E7329207B0D0A20202F2F2072616973652061206A';
wwv_flow_api.g_varchar2_table(2) := '61766173637269707420616C65727420776974682074686520696E707574206D65737361676520616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A2020202061706578';
wwv_flow_api.g_varchar2_table(3) := '2E6A51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C657274286D7367293B636F6E736F6C652E6C6F67286D7367293B7D293B0D0A20207D0D0A20200D0A20207661722067656F6C6F6361746F72203D206E6577206D6170';
wwv_flow_api.g_varchar2_table(4) := '626F78676C2E47656F6C6F63617465436F6E74726F6C287B0D0A20202020706F736974696F6E4F7074696F6E733A207B0D0A202020202020656E61626C654869676841636375726163793A20747275650D0A202020207D2C0D0A20202020747261636B55';
wwv_flow_api.g_varchar2_table(5) := '7365724C6F636174696F6E3A20705F6F7074696F6E732E747261636B557365724C6F636174696F6E2C0D0A2020202073686F775573657248656164696E673A20705F6F7074696F6E732E73686F775573657248656164696E670D0A20207D293B0D0A2020';
wwv_flow_api.g_varchar2_table(6) := '0D0A2020766172206D6170203D20617065782E726567696F6E28705F726567696F6E5F6964292E63616C6C28226765744D61704F626A65637422293B0D0A20206D61702E616464436F6E74726F6C2867656F6C6F6361746F72293B0D0A20200D0A202067';
wwv_flow_api.g_varchar2_table(7) := '656F6C6F6361746F722E6F6E282767656F6C6F63617465272C2066756E6374696F6E286461746129207B0D0A20202020617065782E6974656D28705F6974656D5F6964292E73657456616C756528277B2274797065223A2022506F696E74222C2022636F';
wwv_flow_api.g_varchar2_table(8) := '6F7264696E61746573223A5B27202B20646174612E636F6F7264732E6C6F6E676974756465202B20272C2027202B20646174612E636F6F7264732E6C61746974756465202B20275D7D27293B0D0A20202020617065782E6576656E742E74726967676572';
wwv_flow_api.g_varchar2_table(9) := '28617065782E6A517565727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F63617465222C2064617461293B0D0A20207D293B0D0A202067656F6C6F6361746F722E6F6E282765';
wwv_flow_api.g_varchar2_table(10) := '72726F72272C2066756E6374696F6E286461746129207B617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F67656F6C';
wwv_flow_api.g_varchar2_table(11) := '6F636174655F6572726F72222C2064617461293B7D293B0D0A202067656F6C6F6361746F722E6F6E2827747261636B757365726C6F636174696F6E7374617274272C2066756E6374696F6E2829207B617065782E6576656E742E74726967676572286170';
wwv_flow_api.g_varchar2_table(12) := '65782E6A517565727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F636174655F747261636B737461727422293B7D293B0D0A202067656F6C6F6361746F722E6F6E2827747261';
wwv_flow_api.g_varchar2_table(13) := '636B757365726C6F636174696F6E656E64272C2066756E6374696F6E2829207B617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170';
wwv_flow_api.g_varchar2_table(14) := '626974735F67656F6C6F636174655F747261636B656E6422293B7D293B0D0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(12789662717663486)
,p_plugin_id=>wwv_flow_api.id(12780717908592151)
,p_file_name=>'mapbits-geolocation.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
