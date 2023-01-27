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
,p_release=>'21.1.0'
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
--   Date and Time:   12:48 Friday January 27, 2023
--   Exported By:     GREP
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 210645458240559825
--   Manifest End
--   Version:         21.1.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_geolocation
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(210645458240559825)
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
'    l_defaultEnabled varchar2(5);',
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
'  if p_item.attribute_03 = ''Y'' then',
'    l_defaultEnabled := ''true'';',
'  else',
'    l_defaultEnabled := ''false'';',
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
'  apex_javascript.add_onload_code(p_code => ''apex.jQuery('' || l_region_id || '').on("spatialmapinitialized", function(){',
'    mapbits_geolocation("'' || p_item.name || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", {"enableDefault" : '' || l_defaultEnabled || '', "trackUserLocation" : '' || l_track || '', "showUserHeading" : ''  || l_heading || ''});',
'    });'', p_key => ''MIL.ARMY.USACE.MAPBITS.GEOLOCATION'');',
'end;'))
,p_api_version=>2
,p_render_function=>'map_geolocation_render'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>If the browser has geolocation enabled, the Mapbits Geolocation plugin can show the user''s location as a pulsing dot.</p>',
'<p>Add the plugin in to the map region in which you wish to show the user''s location. This plugin relays events from Mapbox Geolocation as application express events.</p>'))
,p_version_identifier=>'4.3.20230127'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Geolocation',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_geolocation.sql 17828 2023-01-27 19:10:20Z b2imimcf $',
'Date     : $Date: 2023-01-27 13:10:20 -0600 (Fri, 27 Jan 2023) $',
'Revision : $Revision: 17828 $',
'Requires : Application Express >= 21.1',
'',
'Version 4.3',
'1/27/2023 To work with APEX 22.2, changed event hook to the map region''s spatialmapinitialized event in place of the page''s apexreadyend event.',
'',
'Version 4.2',
'3/10/2022 Added default on option.',
'',
''))
,p_files_version=>48
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(210668394636250961)
,p_plugin_id=>wwv_flow_api.id(210645458240559825)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Track User  Location'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'If Yes, move the map with the user, keeping his location in the center of the map.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(210668981283253237)
,p_plugin_id=>wwv_flow_api.id(210645458240559825)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Show User Heading'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'If Yes, show the direction in which the user is moving when he is moving.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(203390379012026537)
,p_plugin_id=>wwv_flow_api.id(210645458240559825)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Enable by Default'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'If Yes, the Geolocation tool will be enabled when the page renders. Otherwise, the user will have to click a button to start the tool.'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(210650694241559840)
,p_plugin_id=>wwv_flow_api.id(210645458240559825)
,p_name=>'mil_army_usace_mapbits_geolocate'
,p_display_name=>'Geolocate'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(210666782128059368)
,p_plugin_id=>wwv_flow_api.id(210645458240559825)
,p_name=>'mil_army_usace_mapbits_geolocate_error'
,p_display_name=>'Error'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(210667600813059370)
,p_plugin_id=>wwv_flow_api.id(210645458240559825)
,p_name=>'mil_army_usace_mapbits_geolocate_trackend'
,p_display_name=>'Track End'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(210667142683059370)
,p_plugin_id=>wwv_flow_api.id(210645458240559825)
,p_name=>'mil_army_usace_mapbits_geolocate_trackstart'
,p_display_name=>'Track Start'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F67656F6C6F636174696F6E28705F6974656D5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F6F7074696F6E7329207B0D0A20202F2F204163636F6D6F646174';
wwv_flow_api.g_varchar2_table(2) := '6520626F7468204D6170626F7820696E204150455820323120616E64204D61706C6962726520696E20415045582032322E0D0A2020766172206D61706C6962203D20747970656F66206D61706C69627265676C203D3D3D2027756E646566696E65642720';
wwv_flow_api.g_varchar2_table(3) := '3F206D6170626F78676C203A206D61706C69627265676C3B090D0A20200D0A20202F2F2072616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D65737361676520616E6420777269746520746F20636F6E';
wwv_flow_api.g_varchar2_table(4) := '736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C657274286D7367293B636F6E736F6C652E6C6F6728';
wwv_flow_api.g_varchar2_table(5) := '6D7367293B7D293B0D0A20207D0D0A20200D0A20207661722067656F6C6F6361746F72203D206E6577206D61706C69622E47656F6C6F63617465436F6E74726F6C287B0D0A20202020706F736974696F6E4F7074696F6E733A207B0D0A20202020202065';
wwv_flow_api.g_varchar2_table(6) := '6E61626C654869676841636375726163793A20747275650D0A202020207D2C0D0A20202020747261636B557365724C6F636174696F6E3A20705F6F7074696F6E732E747261636B557365724C6F636174696F6E2C0D0A2020202073686F77557365724865';
wwv_flow_api.g_varchar2_table(7) := '6164696E673A20705F6F7074696F6E732E73686F775573657248656164696E670D0A20207D293B0D0A20200D0A2020766172206D6170203D20617065782E726567696F6E28705F726567696F6E5F6964292E63616C6C28226765744D61704F626A656374';
wwv_flow_api.g_varchar2_table(8) := '22293B0D0A20206D61702E616464436F6E74726F6C2867656F6C6F6361746F72293B0D0A20200D0A20202F2F204163636F6D6F6461746520626F7468204D6170626F7820696E204150455820323120616E64204D61706C6962726520696E204150455820';
wwv_flow_api.g_varchar2_table(9) := '32322E090D0A2020617065782E6A517565727928272E6D6170626F78676C2D6374726C2D67726F757027292E616464436C61737328276D61706C69627265676C2D6374726C2D67726F757027293B0D0A2020617065782E6A517565727928272E6D617062';
wwv_flow_api.g_varchar2_table(10) := '6F78676C2D6374726C27292E616464436C61737328276D61706C69627265676C2D6374726C27293B0D0A20200D0A202067656F6C6F6361746F722E6F6E282767656F6C6F63617465272C2066756E6374696F6E286461746129207B0D0A20202020617065';
wwv_flow_api.g_varchar2_table(11) := '782E6974656D28705F6974656D5F6964292E73657456616C756528277B2274797065223A2022506F696E74222C2022636F6F7264696E61746573223A5B27202B20646174612E636F6F7264732E6C6F6E676974756465202B20272C2027202B2064617461';
wwv_flow_api.g_varchar2_table(12) := '2E636F6F7264732E6C61746974756465202B20275D7D27293B0D0A20202020617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D617062';
wwv_flow_api.g_varchar2_table(13) := '6974735F67656F6C6F63617465222C2064617461293B0D0A20207D293B0D0A202067656F6C6F6361746F722E6F6E28276572726F72272C2066756E6374696F6E286461746129207B617065782E6576656E742E7472696767657228617065782E6A517565';
wwv_flow_api.g_varchar2_table(14) := '727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F636174655F6572726F72222C2064617461293B7D293B0D0A202067656F6C6F6361746F722E6F6E2827747261636B75736572';
wwv_flow_api.g_varchar2_table(15) := '6C6F636174696F6E7374617274272C2066756E6374696F6E2829207B617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D617062697473';
wwv_flow_api.g_varchar2_table(16) := '5F67656F6C6F636174655F747261636B737461727422293B7D293B0D0A202067656F6C6F6361746F722E6F6E2827747261636B757365726C6F636174696F6E656E64272C2066756E6374696F6E2829207B617065782E6576656E742E7472696767657228';
wwv_flow_api.g_varchar2_table(17) := '617065782E6A517565727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F636174655F747261636B656E6422293B7D293B0D0A20206D61702E6F6E28276C6F6164272C2066756E';
wwv_flow_api.g_varchar2_table(18) := '6374696F6E2829207B0D0A20202020617065782E6A517565727928272E6D6170626F78676C2D6374726C2D67656F6C6F6361746527292E747269676765722827636C69636B27293B0D0A20207D293B0D0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(210654403049631160)
,p_plugin_id=>wwv_flow_api.id(210645458240559825)
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
