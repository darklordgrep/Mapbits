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
--   Date and Time:   11:24 Wednesday May 10, 2023
--   Exported By:     GREP
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 225569669771101768
--   Manifest End
--   Version:         21.1.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_layer_rest_gjs
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(225569669771101768)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LAYER.REST.GJS'
,p_display_name=>'Mapbits Layer ArcGIS REST GeoJSON'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-restgjslayer.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure mapbits_restgjslayer (',
'    p_item   in            apex_plugin.t_item,',
'    p_plugin in            apex_plugin.t_plugin,',
'    p_param  in            apex_plugin.t_item_render_param,',
'    p_result in out nocopy apex_plugin.t_item_render_result ) is',
'    l_region_id varchar2(4000); --apex_application_page_regions.region_id%type;',
'    l_url p_item.attribute_01%type := p_item.attribute_01;',
'    l_portal_url p_item.attribute_02%type := p_item.attribute_02;',
'    l_title p_item.attribute_03%type := p_item.attribute_03;',
'    l_sequence_no apex_application_page_items.display_sequence%type := 0;',
'    l_style_type p_item.attribute_04%type := p_item.attribute_04;',
'    l_client_id p_item.attribute_05%type := p_item.attribute_05;',
'    l_checkbox_color p_item.attribute_06%type := p_item.attribute_06;',
'    l_client_secret p_item.attribute_10%type := p_item.attribute_10;',
'    l_style_advanced p_item.attribute_07%type := nvl(p_item.attribute_07, ''null'');',
'    l_style_zoom_range p_item.attribute_08%type := nvl(p_item.attribute_08, ''0,24'');',
'    l_init_visible p_item.attribute_09%type := p_item.attribute_09;',
'    l_icon_image p_item.attribute_11%type := p_item.attribute_11;',
'    l_style_stroke_width p_item.attribute_12%type := nvl(p_item.attribute_12, 1);',
'    l_style_stroke_color p_item.attribute_13%type := p_item.attribute_13;',
'    l_style_fill_opacity p_item.attribute_14%type := nvl(p_item.attribute_14, 1.0);',
'    l_style_fill_color p_item.attribute_15%type := p_item.attribute_15;',
'    l_error varchar2(2000);',
'    l_token varchar2(2000);',
'    rt clob;',
'begin',
'  begin',
'    select nvl(r.static_id, ''R'' || r.region_id), i.display_sequence into l_region_id, l_sequence_no  ',
'      from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then ',
'      apex_debug.message(',
'        p_message => ''ERROR: Map Layer REST GeoJSON Item [%s] is not associated with a Map region.'',',
'        p0      => p_item.id,',
'        p_level   => apex_debug.c_log_level_error',
'      );',
'      l_error := l_error || ''Configuration ERROR: Map Layer REST GeoJSON Item ['' || l_title || ''] is not associated with a Map region.'';',
'  end;',
'  ',
'  if not l_client_id is null and not l_client_secret is null and not l_portal_url is null then',
'    begin',
'      apex_web_service.g_request_headers(1).name := ''Content-Type'';',
'      apex_web_service.g_request_headers(1).value := ''application/x-www-form-urlencoded'';',
'      rt := apex_web_service.make_rest_request(',
'        p_url => l_portal_url || ''/sharing/oauth2/token?grant_type=client_credentials&client_id=''|| l_client_id ||''&client_secret=''|| l_client_secret ,',
'        p_http_method => ''GET''',
'      );',
'      select json_value(rt, ''$.access_token'' ERROR ON ERROR) into l_token from dual;',
'      if l_token is null then',
'        apex_debug.message(',
'        p_message => ''ERROR:Token generation fail ['' ||rt || '']'' ,',
'        p0      => p_item.id,',
'        p_level   => apex_debug.c_log_level_error',
'      );',
'      end if;',
'    exception when others then',
'      apex_debug.message(',
'        p_message => ''ERROR: Could not retrieve token. ['' || l_portal_url || ''/sharing/oauth2/token?grant_type=client_credentials&client_id=''|| l_client_id ||''&client_secret=''|| l_client_secret || '']'' ,',
'        p0      => p_item.id,',
'        p_level   => apex_debug.c_log_level_error',
'      );',
'      l_error := l_error || ''Configuration Error : Could not obtain token for layer ['' || l_title || ''] using portal url ['' || l_portal_url || '']. Check Portal URL, Client ID, and Client Secret Settings.'';',
'    end;',
'  end if;',
'',
'  htp.p(''<div id="'' || p_item.name || ''" name="'' || p_item.name || ''"></div>'');',
'  apex_javascript.add_onload_code(p_code => ''apex.jQuery('' || l_region_id || '').on("spatialmapinitialized", function(){',
'    mapbits_restgjslayer("'' || p_item.name || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", "'' || p_plugin.file_prefix || ''icons/15/'' || ''", "'' ||  l_title || ''", "'' || l_url || ''", "'' || l_token || ''", '' || l_sequence_no '
||'||',
'    '', "'' || l_checkbox_color || ''", {"type" : "'' || l_style_type || ''", "zoomRange" : "'' || l_style_zoom_range || ''", "initVisibility" : "'' || l_init_visible || ''", "configFunc" : '' || l_style_advanced || ',
'    '', "strokeWidth" : '' || l_style_stroke_width || '', "strokeColor" : "'' || l_style_stroke_color || ''", "iconImage" : "'' || l_icon_image || ''", "fillOpacity" : '' || l_style_fill_opacity || '', "fillColor" : "'' || l_style_fill_color || ',
'    ''", "infobox" : '' || ''null'' || ''}, "'' || l_error || ''"'' || ',
'    '');',
'    });'', p_key => ''MIL.ARMY.USACE.MAPBITS.LAYER.REST.GJS'' || p_item.name);',
'end;'))
,p_api_version=>2
,p_render_function=>'mapbits_restgjslayer'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The Mapbits Layer ArcGIS Rest GeoJSON plugin adds support for ArcGIS Rest vector layers to APEX Map regions. The layer shall appear in the map as defined by the plugin attributes and shall be togglable using the APEX Map built-in layer selector.',
'Add the plugin as an item under an APEX Map region and set the Service URL to point to your layer. This url should take the following form: http://host/{content_id}/arcgis/rest/services/{web_feature_layer}/FeatureServer/{layer_id}. If your layer',
'requires token access, set the Portal URL, Client Id, and Client Secret attributes appropriately.',
'Configure the basic appearance of your layer with the Style Type, Image Icon, Stoke Width, Stroke Color, Fill Opacity, and Fill Color attributes. If more intricate appearance is needed, define your symbology as javascript using the Advanced Configura'
||'tion attribute.'))
,p_version_identifier=>'4.4.20230510'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 Layer - ArcGIS Rest API Vector',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_rest_gjs.sql 18134 2023-05-10 16:29:39Z b2imimcf $',
'Date     : $Date: 2023-05-10 11:29:39 -0500 (Wed, 10 May 2023) $',
'Revision : $Revision: 18134 $',
'Requires : Application Express >= 21.1',
'',
'Version 4.4 Updates:',
'5/10/2023 Preventing javascript execution if the parent region is hidden.',
'',
'Version 4.3 Updates:',
'1/27/2023 To work with APEX 22.2, changed event hook to the map region''s spatialmapinitialized event in place of the page''s apexreadyend event.',
'Using render (once) event instead of the load event to load the raster. ',
'8/13/2022 Modified to work with both mapbox and maplibre.',
'Don''t use isSourceLoaded. It doesn''t work.',
'',
'',
'Version 4.2 Updates: ',
'(3/18/2022) - Fixed initial load query and multigeometry getinfo.',
'(2/7/2022) - Showing a spinner while data is loading.',
'(2/6/2022) - Fixed missing stroke and color APEX options for polygon outlines.',
'Version 4.1 Updates:',
'(1/13/2022) - Added error handling.',
'',
''))
,p_files_version=>476
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(225569865740101820)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>35
,p_prompt=>'Service URL'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'https://services9.arcgis.com/RHVPKKiFTONKtxq3/arcgis/rest/services/Active_Hurricanes_v1/FeatureServer/1'
,p_help_text=>'URL of the ArcGIS Rest service. This url should take the following form: http://host/{content_id}/arcgis/rest/services/{web_feature_layer}/FeatureServer/{layer_id}. Where host is the dns name of the arcgis server, content_id is the unique identifier '
||'used in ArcGIS portal to distinguish content items, web_feature_layer is the name of the web feature layer containing the data of interest, and layer_id is the numeric layer id of the layer you want to display.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(227468820527234055)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>890
,p_prompt=>'Portal URL'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'https://www.arcgis.com'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If the service you are using is non-public and requires a token to access it, this is the base URL used to retrieve the token. You will also need to set the Client Id and Client Secret attributes.',
'For more details, view the <a href="https://developers.arcgis.com/rest/users-groups-and-items/authentication.htm">ArcGIS Rest Authentication</a> page. Be aware that the token will be retrieved by the database HTTP client, so secret',
'information is not exposed in the javascript text.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(225570726062101824)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Name of layer to be displayed in the toggle section under the map used to turn layers on and off.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(226997492559127345)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Style Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'symbol'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Type of symbology to use to represent the layer''s features in the map. </p>',
'',
'<dl>  ',
'  <dt>fill</dt><dd>A filled polygon with an optional stroked border.</dd>',
'  <dt>line</dt><dd>A stroked line.</dd>',
'  <dt>symbol</dt><dd>An icon or a text label.</dd>',
'  <dt>circle</dt><dd>A filled circle.</dd>',
'  <dt>heatmap</dt><dd>A heatmap.</dd>',
'</dl>',
'',
'<p> For more information on style types, view the <a href="https://docs.mapbox.com/mapbox-gl-js/style-spec/layers/#layer-properties">Mapbox Style Specification Layers</a> page.'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(226998135701128354)
,p_plugin_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_display_sequence=>10
,p_display_value=>'Symbol (Point)'
,p_return_value=>'symbol'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(226998523481129251)
,p_plugin_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_display_sequence=>20
,p_display_value=>'Line'
,p_return_value=>'line'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(226998919423129961)
,p_plugin_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_display_sequence=>30
,p_display_value=>'Fill (Polygon)'
,p_return_value=>'fill'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(226999285987131400)
,p_plugin_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_display_sequence=>40
,p_display_value=>'Circle  (Point)'
,p_return_value=>'circle'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(227000927427145701)
,p_plugin_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_display_sequence=>50
,p_display_value=>'Heatmap  (Point)'
,p_return_value=>'heatmap'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(227471646128333335)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>900
,p_prompt=>'Client ID'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If the service you are using is non-public and requires a token to access it, this attribute is the client Id used to retrieve the token. You will also need to set the Portal URL and Client Secret attributes.',
'For more details, view the <a href="https://developers.arcgis.com/rest/users-groups-and-items/authentication.htm">ArcGIS Rest Authentication</a> page. Be aware that the token will be retrieved by the database HTTP client, so secret',
'information is not exposed in the javascript text.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(227797735939478942)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Checkbox Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#000000'
,p_is_translatable=>false
,p_help_text=>'Color of the checkbox to be displayed for this layer in the toggle section under the map used to turn layers on and off.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(227006106903185754)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Advanced Configuration'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'{',
'  "layout" : function() {return{};},',
'  "paint" : function() {return{};},',
'  "infotext" : function(feature) {return ''Hello'';},',
'  "filter" : []',
'}'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Mapbox layers have more configuration options than APEX has plug attribute slots (15). If you need to make use of these configuration options, as documented in the <a href="https://docs.mapbox.com/mapbox-gl-js/style-spec/layers/">',
'Mapbox Layers page</a>, then use this attribute to define that configuration. The value of this attribute must be a javascript associative array with one or more of the following elements:</p>',
'',
'<ul>',
'<li><strong>layout</strong> - maps to a function with no parameters that returns an associative array of layout properties such as line-cap or icon-anchor.</li>',
'<li><strong>paint</strong> - maps to a function with no parameters that returns an associative array of paint properties such as circle-translate or line-pattern.</li>',
'<li><strong>infotext</strong> - maps to a function with one parameter that returns an html string used do display when a user clicks a feature in a layer. The parameter is the first selected feature.</li>',
'<li><strong>filter</strong> - maps to an array representing a Mapbox filter.</li>',
'</ul>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(228517947133212428)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Min / Max Zoom Levels'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(228524053364417348)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Initially Visible?'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'If ''Y'', then this layer will be turned on the first time a user visits this page, otherwise it will be off. After the initial page visit, the layer visibility will be persisted.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(227472159786334463)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>910
,p_prompt=>'Client Secret'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>40
,p_max_length=>40
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If the service you are using is non-public and requires a token to access it, this attribute is the client secret value used to retrieve the token. You will also need to set the Portal URL and Client Id attributes.',
'For more details, view the <a href="https://developers.arcgis.com/rest/users-groups-and-items/authentication.htm">ArcGIS Rest Authentication</a> page. Be aware that the token will be retrieved by the database HTTP client, so secret',
'information is not exposed in the javascript text.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(226985742721901035)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Image Icon'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'star'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'symbol'
,p_examples=>'star, corps, airfield, http://devgis.mvn.usace.army.mil/pan.png'
,p_help_text=>'URL or name of icon to display icons if style type is ''symbol. The names of icons are the png files in this plugin without the path prefix and without the extension.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(226986320918910117)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Stroke Width'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'line,fill'
,p_help_text=>'Width of the line in pixels if the Style Type is line. This value will override the line-width property if it is set in the Advanced Configuration.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(226986916537911465)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_prompt=>'Stroke Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'line,fill'
,p_help_text=>'Color of the line if the Style Type is line or the color of the polygon outline if the Style Type is fill (polygon). This value will override the fill-outline-color and line-color properties if those are set in the Advanced Configuration.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(226987496628914501)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>140
,p_prompt=>'Fill Opacity'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'fill'
,p_help_text=>'Opacity of the polygon fill color if the Style Type is fill (polygon). This value must a number between 0 and 1 inclusive, where 0 is completely transparent and 1 is fully opaque. This value will override the fill-opacity property if it is set in the'
||' Advanced Configuration.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(226988126608915887)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Fill Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(226997492559127345)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'fill'
,p_help_text=>'Color of the polygon if the Style Type is fill (polygon). This value will override the fill-color property if it is set in the Advanced Configuration.'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832230471C7B00000007B4944415418D39DCE310AC2501045D1F3639A542E4021B1B716D790F559B89F682B8860FDED449760110B3106E19BE09DE6';
wwv_flow_api.g_varchar2_table(3) := 'C163E64ED027B3743231572915B639723395D2C24AED66EA2A8A8E049C152EA2E86E63EDE02141EBCBF6930C7B6D377AB979B9DBE472C8DFA1737FD238F7FFF5C06B238EEF125D6388272C9D2090386277C60000002574455874646174653A6372656174';
wwv_flow_api.g_varchar2_table(4) := '6500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33352D30353A3030EBC87B5F00000076744558747376673A626173652D757269';
wwv_flow_api.g_varchar2_table(5) := '0066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F61657269616C77';
wwv_flow_api.g_varchar2_table(6) := '61792E737667C810435A0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228313686836289697)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/aerialway.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832230471C7B0000000804944415418D3AD8F310E82401045DF5A527008ECF060DA61472B1D67E10C86CA3D821C81ED48A0D1EEDB2C0164D7CA974C';
wwv_flow_api.g_varchar2_table(3) := '31FF6566323073A1C1222C0D6782B4883B51DE88D73A301BADEFCCF828C2017EEB23576CC074549CE626A3E08110E2C98D3CB46B428CF1DBCE5744F7BEFE34BD90503220266AD2BD76FE2DA1E5C00779B629A18B242D9F0000002574455874646174653A';
wwv_flow_api.g_varchar2_table(4) := '63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33352D30353A3030EBC87B5F00000075744558747376673A626173';
wwv_flow_api.g_varchar2_table(5) := '652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6169';
wwv_flow_api.g_varchar2_table(6) := '726669656C642E737667DF2E8A640000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228314037674289703)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/airfield.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832230471C7B0000000AF4944415418D39DD0216FC20010C5F15F0941804392050728C4C804024582219B06B11114A682CFB24F33BFA08706330358';
wwv_flow_api.g_varchar2_table(3) := '148A84225AA00DD4F02ECFBCFF5D7277A4D5B5D54D07850CEEABE9E7E352E21C7CA7346E78C3D0BB62B6A96A66E1244A6AE75B3B469F7E1CAFE05627BFA681081CACADBCE859D86869AAC4D3A181BA00CC45E620503710667798887CE51FB64FFC0C2E1B';
wwv_flow_api.g_varchar2_table(4) := '61ACFCE8411FFE939336269730B8E29D3F4B6B4DAF3A6A717806DE00312081564C870000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469';
wwv_flow_api.g_varchar2_table(5) := '667900323032312D30372D30395430383A35303A33352D30353A3030EBC87B5F00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B69';
wwv_flow_api.g_varchar2_table(6) := '2D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F616972706F72742E7376675142E5160000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228314409284289710)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/airport.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832230471C7B0000000A84944415418D385903D0AC24010853F444CC47806AF611FB5146CF50CB98BF639409060A785AD67104310D153F853642C7C';
wwv_flow_api.g_varchar2_table(3) := 'AB62127CCBCE63E61B58DEC24B114644AD728CBC3C6EC853DD4AB5D8631CF0AAF11CC33016EA4D07800985DA82B1F0A7727A6F1BC73236CE84741870D1E88187CFDDE1506F0E8553D66C583A1C087785DB2424F82E775FD8F9958C8C9BC331430246C4BF';
wwv_flow_api.g_varchar2_table(4) := '899B00F4D8D6FFF7EE2BD80A80198631E59F9ECA563FF2DF2B08540000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F646966790032303231';
wwv_flow_api.g_varchar2_table(5) := '2D30372D30395430383A35303A33352D30353A3030EBC87B5F00000079744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E30';
wwv_flow_api.g_varchar2_table(6) := '2D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F616C636F686F6C2D73686F702E737667C1573DD40000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228314780403289717)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/alcohol-shop.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A1552130000006C4944415418D36360A00B306158C8709FE13BC34386650CD6A8524C0C9D0C7F19FEC3E13F86C90CCC08E969485230381F26';
wwv_flow_api.g_varchar2_table(3) := '19CFF09FE13F832A06990491BEC3F09FE13F9A4BFE33FC67B8835F77223EBBE720BBBC03CDE5FDC82E87F87B01C33D86EF0C0F18963058D225A401DDB3455526847ED70000002574455874646174653A63726561746500323032312D30362D3232543039';
wwv_flow_api.g_varchar2_table(4) := '3A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C20000007E744558747376673A626173652D7572690066696C653A2F2F2F433A2F557365';
wwv_flow_api.g_varchar2_table(5) := '72732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F616D65726963616E2D666F6F7462616C6C2E73766774';
wwv_flow_api.g_varchar2_table(6) := 'E5EF6E0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228315160546289724)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/american-football.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000D34944415418D38DD0314E026110C5F19FF235AB8D0907B1B0D118933D0109A5675AE848B6658D51F402949CC0C23B000113';
wwv_flow_api.g_varchar2_table(3) := '626D62188BFD00B1F24D31C53F99F7E6B1D39D89852F73CF6E1D29A98595B1278DB530920EB8162A054A1406C2E8703654FA52C6495F257616132B85A42F29F32EAC3DB578619C13343E35D9B53127A12B5C819E0B3D9760ABDBE2A5136F48A6EE4DBDFB';
wwv_flow_api.g_varchar2_table(4) := 'C6A9657BFCD17AEF1D7BEF0F0F2DBEB135C8C923271FDABADEBD36146A67199FAB85C1A1968E4AD878115E6D844AE777ADA5389AF2B8F5D91F3CF31FFD0097AF4DE8C423C33D0000002574455874646174653A63726561746500323032312D30362D3232';
wwv_flow_api.g_varchar2_table(5) := '5430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C20000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F';
wwv_flow_api.g_varchar2_table(6) := '55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F616D7573656D656E742D7061726B2E7376674C';
wwv_flow_api.g_varchar2_table(7) := 'D54E360000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228315571419289731)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/amusement-park.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000CD4944415418D37DD1AF4B830110C6F1CF4018A689631AC6E2B4AC2B2B22D82C76C164B28AC1EEBFE13F611061433641C4E0';
wwv_flow_api.g_varchar2_table(3) := '8FA20645650E9B0B82BAE459E6BBED7D6177E9EEFB70C773C7C4C88D55F3B6ACAB2AEABB73EA7088671CD8961F54576EBCE9FEC3454F22C9FBF115751F23301C839235A8A6607850B0ABE79A299742C3A6664A14DED91142097319FCC9B31056B09AB4FB';
wwv_flow_api.g_varchar2_table(4) := 'CEFD0AAF9C09E14BDB77821BA839D162412F33F468E068166A5E52B8A33CEA7BDA7E46D2D5B2373C6ACEB20D4B2AF8F1E856D3C5E487F9032EE274A20FF223020000002574455874646174653A63726561746500323032312D30362D32325430393A3333';
wwv_flow_api.g_varchar2_table(5) := '3A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C200000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F';
wwv_flow_api.g_varchar2_table(6) := '42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F617175617269756D2E737667821EAF710000000049454E44AE';
wwv_flow_api.g_varchar2_table(7) := '426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228316029965289739)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/aquarium.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000624944415418D36360A02E38C2709A410CB7F41986FF0C97712B1063B8CAF09FE13A83242E05D20C77600A18198419121998';
wwv_flow_api.g_varchar2_table(3) := 'D114C833643230305C617064602862F88F1316323208316431F060E88E80E9C66DB7043E97639524E8EFC3F8438D140000181B2630A880937B0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A';
wwv_flow_api.g_varchar2_table(4) := '303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C200000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43';
wwv_flow_api.g_varchar2_table(5) := '462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6172726F772E737667E62479130000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228316302498289747)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/arrow.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000744944415418D395914B0A85300C450FE2B214837B72EECE3210D72138F3A15B300E0C156D44DEED209493CF6D037F489869';
wwv_flow_api.g_varchar2_table(3) := 'DEE18F8E058960CD420B541E93362C3CEB89ED659841912E23439E71E13D75E9B32637FFE6DEED8E0501144323AC28E2AEE5894F3039D6BC3A7858E9DF1269FBDCD10168C836F1C9A5B1220000002574455874646174653A63726561746500323032312D';
wwv_flow_api.g_varchar2_table(4) := '30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C200000078744558747376673A626173652D7572690066696C653A2F';
wwv_flow_api.g_varchar2_table(5) := '2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6172742D67616C6C6572792E7376';
wwv_flow_api.g_varchar2_table(6) := '67F8DB12960000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228316731585289756)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/art-gallery.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000834944415418D3AD90B10D833010459FD242C30C30056EA8B30DCC80102B243BA0CCE18C10A566065C7D0ADB9241A6E35F75';
wwv_flow_api.g_varchar2_table(3) := 'F74E5FFF0EEED20721C492835D804274299871098AE5983C763C11C2D252D062C3C2E6B16F562A1A061A2AD6304BF00BF8237EC03BE2C7219E729953F39EFA6C1E735B0C2586EF31DA7471D878DBC3F3DA01DAFE512B4472DB0800000025744558746461';
wwv_flow_api.g_varchar2_table(4) := '74653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C200000077744558747376673A';
wwv_flow_api.g_varchar2_table(5) := '626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E73';
wwv_flow_api.g_varchar2_table(6) := '2F61747472616374696F6E2E737667020923F10000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228317130770289765)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/attraction.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000954944415418D3BDD0B109C2501405D0633095606F974A1B052DD259C4191CC561B2832B68A1E00082A58A0121030404B5F9';
wwv_flow_api.g_varchar2_table(3) := '16F96063ED2DEF793C1E8F3F65E1E8E1A8F8CD6B4110ACBF5512E1AD748FDD5DE9DD0EB59C4B4D5D235FCCA4F296470A3B4CDC2257C6D8290C131B2B7BF4E226123DECAD6C096A99A031F6123C4D34824C2D747156E980A5B983937EBC61F0AF9FFECA07';
wwv_flow_api.g_varchar2_table(4) := 'D33C28B6BE6201D60000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A';
wwv_flow_api.g_varchar2_table(5) := '3030DA2061C200000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D';
wwv_flow_api.g_varchar2_table(6) := '6D616B692D666664646431312F69636F6E732F62616B6572792E7376678AF97AC40000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228317550655289774)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bakery.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000804944415418D3B5D02112827010C5E14F020720EB40315B217A0E837812C79319C4439819C76AA4ADE5AF42D0C66ED9F75E';
wwv_flow_api.g_varchar2_table(3) := 'D8DF2EB3D655FCEC8E50A98530D82BB40621D42A41A4301C653632A7A46BB1109F356B85ADB3A7DBDBCA4614773972FDD71AC74B251E56D3B849F34E8FD22EE9862979AB709892777FEEBECCFAF117986642AD0760755E0000002574455874646174653A';
wwv_flow_api.g_varchar2_table(4) := '63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C200000071744558747376673A626173';
wwv_flow_api.g_varchar2_table(5) := '652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6261';
wwv_flow_api.g_varchar2_table(6) := '6E6B2E737667D4C4AEE20000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228317894004289783)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bank.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000944944415418D38DD13B0AC2001084E14FD1EB880FB0D1AB588885780B4B7B3D51D003982B082236E98C88B016064C8284CC';
wwv_flow_api.g_varchar2_table(3) := '56FF0ECCC22C2DD435D6ADF0A4CC1B615FB2F7C2FA8723B9B02C6829E486E5F885F034C5D84358D5EF1F84AB914BED50A1BE447809897EDD4C4565D2EFBA57D83B03CCCD9C1CA9DB6F1972E432BC9BC3CFFFDADB0ADB6A9D65DD716BEEBED3E649853E38';
wwv_flow_api.g_varchar2_table(4) := 'EE36BF425228600000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A30';
wwv_flow_api.g_varchar2_table(5) := '30DA2061C200000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D';
wwv_flow_api.g_varchar2_table(6) := '616B692D666664646431312F69636F6E732F62616E6B2D4A502E737667BFAE37AF0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228318279967289792)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bank-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000944944415418D3A5D03D0E01011005E00F898450E8257B02850338C26EA1D26844A3A1D210955BB9844BA8E89644E16735C8';
wwv_flow_api.g_varchar2_table(3) := 'AE9F8DC49B66266F32F3DE2317052CB535D5D554D4ED1D1DEC6DAC2D20148B041AAAA86A084462E1E346D74992A9B35EFA49DF25455E0D5F550C5C9FE4E893CCF19D9E7EF3319798E5194DB263313F96FFE852AA6F99E828DBD9BE2FAE52B1ACFC861BF2';
wwv_flow_api.g_varchar2_table(4) := 'C231A40E9EDAE10000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A30';
wwv_flow_api.g_varchar2_table(5) := '30DA2061C200000070744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D';
wwv_flow_api.g_varchar2_table(6) := '616B692D666664646431312F69636F6E732F6261722E7376670A8DCBFA0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228318725345289801)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bar.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000644944415418D3B5903D0A80300C46DFE039A47849D78E9ECBE22504299E241D8C91D61427BF0C21BC8FFCC1CFDA1037D285';
wwv_flow_api.g_varchar2_table(3) := '859993899183052CCB8D219209043211341B0EAEC170760D52CFA6D9E135BBEEA038750E5B9FDBA5F985D643D75069FFA87D157F4C43CC00ADE6B50000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30';
wwv_flow_api.g_varchar2_table(4) := '353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C200000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F4232454453';
wwv_flow_api.g_varchar2_table(5) := '4D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F626172726965722E7376676B1136270000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228319098775289811)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/barrier.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000994944415418D395CD310E01011085E12FD6099C41422B710221516AD41A850348544A0EA07001891B48147AA2D0B9815622';
wwv_flow_api.g_varchar2_table(3) := '68B690D12896EC16FE69DECB3F9921CBD20FA54CEE3A2924B196987B9AE5E9A12E1EC23DEF78D3160B4F0BFF73169FB9A9142D6D84302AD255A9B02F7EB213423D5F4E84AB30CF93032F630DA98BE457F6A486602AB4BF65CB5DFF93CB0E56DFFAA49369';
wwv_flow_api.g_varchar2_table(4) := '35477803C5D829D58E7D51EC0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A3336';
wwv_flow_api.g_varchar2_table(5) := '2D30353A3030DA2061C200000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170';
wwv_flow_api.g_varchar2_table(6) := '626F782D6D616B692D666664646431312F69636F6E732F6261736562616C6C2E7376675D699DAE0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228319534218289821)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/baseball.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000BB4944415418D3ADCF3D4B82711486F19FD966F0E89C438388BB433809226DF661DC72EE033888836E6E0EB9F8026E41DFE0';
wwv_flow_api.g_varchar2_table(3) := '710A424445680C1C837F83450FD6E0E039DB7D1D0ED7CD7926A76DA960A92D770CAFEC04415110EC640EF105C88B6C13C71B59D7BFB8A5619AC053F71EE012DC095E12F85555FD44E758F87763D2F8F026E3D9CCBB9291B1B54F034F163F1F2AFA52E61A';
wwv_flow_api.g_varchar2_table(4) := 'E6527A2A8738FD8DB79AD8EB29B851F3786CB0129BB835115BFD15EC88940D9545BA2796FA028A2E36B8BEF08C4E0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574';
wwv_flow_api.g_varchar2_table(5) := '455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C200000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F616473';
wwv_flow_api.g_varchar2_table(6) := '2F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6261736B657462616C6C2E737667C246D8E50000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228319944581289831)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/basketball.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000A54944415418D38DD03D8A02710CC6E107616DC44A101595C50B7891B1F70CB65EC20BEC11ACAC442B19FCB8C376960B2282';
wwv_flow_api.g_varchar2_table(3) := '08823062B1167E307FB59837A4487E79430899543378CB94061F06B26BEB3F88CDAD9DBBE3C9CBF8342C2BD629EF5AE5757DC958E2E26CA4F468E69E78AFAAEB4B4FC13E7436C40E12DFC8FBD30E716C21B234077DC3101F45E83881A29D56E85EEA58A5';
wwv_flow_api.g_varchar2_table(4) := '6EFF49E3BA999358F35E97FD667AE615BF923632D4FA96BD0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D3037';
wwv_flow_api.g_varchar2_table(5) := '2D30395430383A35303A33362D30353A3030DA2061C200000070744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D';
wwv_flow_api.g_varchar2_table(6) := '67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6262712E737667CBB9C3840000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228320288849289841)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bbq.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000B54944415418D3A5D0314B02011407F05F961C18E154106E6A1074CE4ECE6D72EDED4DAE36D69C9F22680EDAA20FD0078803';
wwv_flow_api.g_varchar2_table(3) := '15FC065D0EA2635CC3DD858ADCE2FF0DEFFDFFFFC7E3BD47290EFFAB0397DE9C1BE989CDB7DB5E3D4A2D0CA5BE85995CC9ED811B7022F4A9EA21938F72FB16A47E04EE4D249BC3C79E45BA5ED476AD789AE73BD76597B43DADD3CA963DD32AB3499CED7A';
wwv_flow_api.g_varchar2_table(4) := '4B81634D71418AC3AAAE5C6808D4757C99FA2D5A22EF96D28D58F9D0B727FE00459525785220EC9D0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174';
wwv_flow_api.g_varchar2_table(5) := '653A6D6F6469667900323032312D30372D30395430383A35303A33362D30353A3030DA2061C200000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F62656163682E7376676A933B9F0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228320629819289852)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/beach.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E507090832249A155213000000A54944415418D38DCD310AC2401085E17F433A11B6D6CA54E9D4CE03D8E418B1CBB9720D3B51ECAC94344614B40A4190EDC4';
wwv_flow_api.g_varchar2_table(3) := '582459B2130B679B99F70D3BF05745A464147C28C848895CAE8809D1802624A692FC73F66DB062CF83279A110B79BBA4725E59C75EC3B9583FBBBC112CE699F87C2AAF9F3A786C43CFF2B6B3BAEBB32141A15024983E075C9BEE46D086CAF2859C036F7C';
wwv_flow_api.g_varchar2_table(4) := 'E6044C240F59326680E1CE9A571D7E0160EE376446909E830000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D3037';
wwv_flow_api.g_varchar2_table(5) := '2D30395430383A35303A33362D30353A3030DA2061C200000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D';
wwv_flow_api.g_varchar2_table(6) := '67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F626565722E73766727BC8FC10000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228320956653289863)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/beer.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000AE4944415418D3ADCE2B6E02011485E1AF8EF030E3D8061B68024C13A00A645780C3D5743798EE0081C032D38440425DCBA3';
wwv_flow_api.g_varchar2_table(3) := '0285A240AA980A1024338A70D4FDEF9F931CEE9985C436FBFD75B993ACDEBB2EE8480469DD1079F0666DA4772D9EC58EE64E06C6CA5EFD3988B5CE72A9A6E0C5C9504EDBC6B750DD4A930F5554FCE89B60E6514F1F75113B454CB515ECB19717F844C98E';
wwv_flow_api.g_varchar2_table(4) := '58EDB221144971CB4AA8E8C95A439A35457E8DCF90C137E71F75A239E3C8D4C0750000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F646966';
wwv_flow_api.g_varchar2_table(5) := '7900323032312D30372D30395430383A35303A33372D30353A30307C576A7600000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D';
wwv_flow_api.g_varchar2_table(6) := '76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F62696379636C652E737667CFA879A30000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228321417143289874)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bicycle.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED1262850000008A4944415418D39DCF310E01511485E10FC934966066053A6BB100BBF1944A51E92C40C602C4127494A3504CA9F43433893C';
wwv_flow_api.g_varchar2_table(3) := 'AFE15437FF9F9B7B2E3FE7ECD48FC38C7E89F9BD81B5D6342F4776A2A78B714EEF450F331BD1F55B6F45F3141656EE1A4161A14D88E060A2540B8812D22841A5E9F40749FFBEA5B7835AA972B4CC9142D0F445BAB229F9336F689A2E6A9B982774000000';
wwv_flow_api.g_varchar2_table(4) := '2574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A760000007A74';
wwv_flow_api.g_varchar2_table(5) := '4558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431';
wwv_flow_api.g_varchar2_table(6) := '312F69636F6E732F62696379636C652D73686172652E73766782A37D920000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228321777614289885)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bicycle-share.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000884944415418D36360A01EE06058C6C0895B7A1AC37F86A9B824BD19FE31FC67F8CF10804D529AE10DC37F86FF0CFF19DE31';
wwv_flow_api.g_varchar2_table(3) := 'C8A14B3231EC854AFE67F8CF70888119553A0D2AC100A55351A5CFA3499F4395FEC6F01F89F79FE12BCC4E087805D507235FA14A2F4373EA72542E37C32924979F62E046F71A174313C31D869F0C77189A18B8888C04003BC435DCCA36BFCE0000002574';
wwv_flow_api.g_varchar2_table(4) := '455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A7600000077744558';
wwv_flow_api.g_varchar2_table(5) := '747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F';
wwv_flow_api.g_varchar2_table(6) := '69636F6E732F626C6F6F642D62616E6B2E737667F27A8A6C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228322238155289897)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/blood-bank.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000C44944415418D39DD1CD2A847114C7F14F92C72C94DD9498AD32852C5859091BB91B4B6EC0354CAE631A1B6567E10E2C4892';
wwv_flow_api.g_varchar2_table(3) := '97D8FC87D4732C9E33C6829253BF3A9DEF79EDF00FEBB8D581891F7165CED4EFB84E7DE11D038F9EF46DA18BA571F6A15084102E7022F4467057286632E1C0B457E145D5E053A1288917ED679FBD66F69AA1B6A26DA8766539BBAE30895ACB7DEACE87F9';
wwv_flow_api.g_varchar2_table(4) := 'C40B4DF5255AA90AEF89DF1A7CFCEDE259959BF4AF47C1A35C26844D1BE9AD8FABB6F53D7836B08A73E1EC0FBFF90447744218536049960000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A3030';
wwv_flow_api.g_varchar2_table(5) := '26A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A760000007A744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F';
wwv_flow_api.g_varchar2_table(6) := '446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F626F776C696E672D616C6C65792E737667AF5DB04E0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228322649237289909)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bowling-alley.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED1262850000008A4944415418D3CDCFCD0A01711405F0DF301BD694DD50565EC1AB78083B5B3559B1F11616761694EC94BC803C817C3CC4DF';
wwv_flow_api.g_varchar2_table(3) := 'C24C1969B274EA763BB7DBF9E06F1165BB61A0EBAE6FAFE760E992BF540D2DB48CC9A6E96824A6A2666EE3ECFAA6F9B0B632558FA552B72FB627339348288B56015B89B65D762BB020484047F8642FF1BC5E28942DB5FD054FF7B921CFF5A22BDD000000';
wwv_flow_api.g_varchar2_table(4) := '2574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A760000007374';
wwv_flow_api.g_varchar2_table(5) := '4558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431';
wwv_flow_api.g_varchar2_table(6) := '312F69636F6E732F6272696467652E7376670DEDE1120000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228323049710289922)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bridge.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000254944415418D36360A0043042E9FFD865988833E53F769A806E02760F62C35930F453110000CD9B0D060DC11B0B00000025';
wwv_flow_api.g_varchar2_table(3) := '74455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A76000000757445';
wwv_flow_api.g_varchar2_table(4) := '58747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D66666464643131';
wwv_flow_api.g_varchar2_table(5) := '2F69636F6E732F6275696C64696E672E73766710F15A670000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228323367850289936)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/building.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000484944415418D36360201A7033B83074305CC525FD9BE13FC37F86FFB8A4215228D24C5895BD8331195184191818A1BA1971';
wwv_flow_api.g_varchar2_table(3) := 'EB2660F8D0906661606060602887F3CB91E84E0642000004F60E926482247C0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900';
wwv_flow_api.g_varchar2_table(4) := '323032312D30372D30395430383A35303A33372D30353A30307C576A760000007A744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D7637';
wwv_flow_api.g_varchar2_table(5) := '2E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6275696C64696E672D616C74312E737667D613B4AF0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228323693188289950)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/building-alt1.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED1262850000007E4944415418D38DD0BB11C2301045D1230F313334411160320AA00D2A227703544064EA2180042211588241B219BFCDEEEE';
wwv_flow_api.g_varchar2_table(3) := 'DB1FAC746EE24FBCF4D6049C1D707297B574C4C51E9E8533C763A88D5AB536624E8F2BD2F8AB59E9B1D92DC36171D21C6635DFDA153C91261585CAF621FDC4D7FAEF03CAF51259806BB553226FBC99344E975653E80000002574455874646174653A6372';
wwv_flow_api.g_varchar2_table(4) := '6561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A7600000070744558747376673A626173652D';
wwv_flow_api.g_varchar2_table(5) := '7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6275732E';
wwv_flow_api.g_varchar2_table(6) := '737667AFAAA2C70000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228324122080289964)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/bus.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000644944415418D36360A021606460606060F88F559481818109BF6EECD2FF19FE333C66F044E62243060606061B864730DD9F';
wwv_flow_api.g_varchar2_table(3) := '51F4BE43B59F81612D86FEFF0C8F183C60D2AA0CAFE1C2AF1814301D23C9B098E135C30B86250CF22407CE2D145B6F512BCC01EE492B0E4F1C71650000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30';
wwv_flow_api.g_varchar2_table(4) := '353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A7600000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F4232454453';
wwv_flow_api.g_varchar2_table(5) := '4D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636166652E7376674B0D92700000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228324461665289977)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/cafe.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000A74944415418D395D1BD4A82011805E047D1723790688DBC0387C0D521AFC1B5A1ADA0AE25C84170B2B54B68151C5CFCE81A';
wwv_flow_api.g_varchar2_table(3) := '0271A9E5EBB458F4F7159DEDF0C019DE977FA4ED4EBB9AC7E2A60A7B4AF1E2F8276C588888A5E677BE10A533A538FF8AFBD6E21A13B171F0996FC5A33D74ACC5EC230E449C6EDB95889337DCB51273F56DDF5188072D1A8646BA285CBEAF158E1C9A98D6';
wwv_flow_api.g_varchar2_table(4) := '3C69559EE9B9EED7D40CF52BF5FE8F1FBD0211D32DAE945AAE290000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D';
wwv_flow_api.g_varchar2_table(5) := '30372D30395430383A35303A33372D30353A30307C576A7600000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D';
wwv_flow_api.g_varchar2_table(6) := '302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F63616D70736974652E7376677897FAF10000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228324902910289991)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/campsite.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED1262850000006B4944415418D3BD90C10980301004273620D13E52830DE5991A52561A0AC17710CF87448F80F8D2DBCFED0D2CECC10FE3A9';
wwv_flow_api.g_varchar2_table(3) := 'C8A58AD770A4B028BFB0626F1B495D5A22B635B0ABE0A69D70E28D098757C8E398D94E2C58C02ADC3C0690C73E6678EF9C114A772B08F9E35F1F73162EF195BAFE310000002574455874646174653A63726561746500323032312D30362D32325430393A';
wwv_flow_api.g_varchar2_table(4) := '33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A7600000070744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572';
wwv_flow_api.g_varchar2_table(5) := '732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6361722E737667ACFAC04E0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228325338699290005)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/car.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000874944415418D38D90410A84300C459F5E403A9E61B69EC10B75E9BE3B8FA520731B29AE45CC2C4231D882FE40E8EFA30DF9';
wwv_flow_api.g_varchar2_table(3) := '50D20F4158D504A4505F44B120CCA66B917020989EBDCEB5D8D92FE4D9CDDC1D6F6143A437BE67C35D7664BAFD3631A6E3C059D8FB64507CF0A1C31BE4E96839522C0E7006274F75A55350553FEFBC22C4DB5DD4D4FE1DC554FDAA0E06A4000000257445';
wwv_flow_api.g_varchar2_table(4) := '5874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A760000007774455874';
wwv_flow_api.g_varchar2_table(5) := '7376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69';
wwv_flow_api.g_varchar2_table(6) := '636F6E732F6361722D72656E74616C2E7376675A0FDF0B0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228325675680290020)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/car-rental.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED1262850000009A4944415418D38DCF3D0E016110C6F11FD1CBE21C5A8590BD8323A8B7D4EBDC45947A8952CB31369B6D6DC4ABD86CBC1661';
wwv_flow_api.g_varchar2_table(3) := 'A69967FEF39107E62E2A3B7D6FD1C5C4DEC94229BCE4F139B66EA13AF5B034327D3FDC6CCF9C5D6D3FFDFE333255F4B392C5B0AF90463A554A9E72E3D0BA76B069CA95FB075377AB1ADF0C8C6511CA8C0DDD6A1C244822DC681D84AF7E3ADDDF9E7341D1';
wwv_flow_api.g_varchar2_table(4) := 'EA15829C0721424B1DE9F78E150000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33';
wwv_flow_api.g_varchar2_table(5) := '372D30353A30307C576A7600000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D61';
wwv_flow_api.g_varchar2_table(6) := '70626F782D6D616B692D666664646431312F69636F6E732F6361722D7265706169722E737667355BE4F50000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228326117759290035)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/car-repair.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED1262850000008C4944415418D395D1BD09C2601000D08728A9D32A6827648F4CA3EB68EF0E82E20FB64E60932102A29DC5D904FC4822E8C1';
wwv_flow_api.g_varchar2_table(3) := '35F7AEB81FFE88DC56FE0D874EC2C9B09FD74208AB3E5C3618C2A28DA557C22F658A73758221D4E61FBEB43084F3879F3DFC8001B8366DB726D31A668EEE76C6C2C4DEDDC1B4BB5C2664FD4719296C848DC2A8CB553256F5E38FDE2EC546F629C2907700';
wwv_flow_api.g_varchar2_table(4) := '00002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A76000000';
wwv_flow_api.g_varchar2_table(5) := '73744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D66666464';
wwv_flow_api.g_varchar2_table(6) := '6431312F69636F6E732F636173696E6F2E7376679671F1D20000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228326398693290059)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/casino.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000834944415418D395D0B10DC2400C85E12F14D050C006A4841960319824F3842C712B6402684C914BC8059A3C4B96ECDF4F96';
wwv_flow_api.g_varchar2_table(3) := 'CDA0844E3BE5A450208A0CAA192E55C12617CF056CAD5327A6F8F11E673084C3D01E77D78BF17A153E81BBBDC7BFF146085BEC84D094EE0B78E305CEA5BBCFCF94DFDACFE12D9FF3C5E13AC2B4B8798CC40756B13D23CEE19D4200000025744558746461';
wwv_flow_api.g_varchar2_table(4) := '74653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A7600000073744558747376673A';
wwv_flow_api.g_varchar2_table(5) := '626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E73';
wwv_flow_api.g_varchar2_table(6) := '2F636173746C652E7376679700B5760000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228326830649290075)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/castle.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED126285000000824944415418D3A58F310A834010459F9BDC26AC85902EED9E2A60E945BC8095CDE60439443A412FE158CCB0E81244F1C3C0';
wwv_flow_api.g_varchar2_table(3) := '9FF71686852B29526B78A6FEE59DEB79D36FB916200010379C929E8820E9A110E9F1BAD60882309A9E6CAFC1A1D312A84C57045AE577433F3EE9D8C0C04BABDBFFF7013DDBACB3629E8E47A6FFB1D35900DF3021F0177C99530000002574455874646174';
wwv_flow_api.g_varchar2_table(4) := '653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33372D30353A30307C576A7600000076744558747376673A62';
wwv_flow_api.g_varchar2_table(5) := '6173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F';
wwv_flow_api.g_varchar2_table(6) := '636173746C652D4A502E737667708BEAF30000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228327184696290092)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/castle-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED1262850000009C4944415418D3758EB10AC24010441F0941D488955A2BF82536A6B715626161719588FF28043BB151100958696DB5162EC7';
wwv_flow_api.g_varchar2_table(3) := '9E5E66D9626778EC8055C1939206A59C101E74E2F1124110B671F6AC71945F6918E5332E08036068F944E39209D0D71DB109D92B8230070AFBFF4BAF190330D50DF81677534B7EFB3B6FEDE8B20FFBB7A9BD91033DCBA73816BEE29B0AC74CAF9C1786FD';
wwv_flow_api.g_varchar2_table(4) := '9F5BC291661D3E65D952B76A5245DD0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A3530';
wwv_flow_api.g_varchar2_table(5) := '3A33372D30353A30307C576A7600000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F';
wwv_flow_api.g_varchar2_table(6) := '6D6170626F782D6D616B692D666664646431312F69636F6E732F63617574696F6E2E7376670C1AD44C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228327616405290109)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/caution.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F0000007A4944415418D36360201A38329C66F8CA7086C1059BA418C33786FF0CFF19FE33FC609041977C019582C117106126A8F457';
wwv_flow_api.g_varchar2_table(3) := '34E55F50A5EF30343230C26123C36D54D553D10C9F84AE1B15DC2649FA367669186063F88364F32F065654DDBF181E2329BECFF01B55F76B3497BF86083342A5FF630432230361000031EC37720A4408B50000002574455874646174653A637265617465';
wwv_flow_api.g_varchar2_table(4) := '00323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F00000075744558747376673A626173652D75726900';
wwv_flow_api.g_varchar2_table(5) := '66696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F63656D6574657279';
wwv_flow_api.g_varchar2_table(6) := '2E737667903574BE0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228328038357290124)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/cemetery.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083225ED1262850000003E4944415418D3636020018831943088E296AE62F8CF50852CC08422CD06C538A431C0D09586001F861F0CFF51E00F066F84';
wwv_flow_api.g_varchar2_table(3) := 'EEFF181A1819588831173F000074280D35F4DCEEA60000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D3039';
wwv_flow_api.g_varchar2_table(4) := '5430383A35303A33372D30353A30307C576A7600000078744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D676666';
wwv_flow_api.g_varchar2_table(5) := '64646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F63656D65746572792D4A502E7376676B650F200000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228328378104290141)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/cemetery-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F0000008A4944415418D38591BD0D833010853FA7A54C9F2E5BB00B222D43A4813D98859F8A4C9001580090A0BA14C0619F8878D79C';
wwv_flow_api.g_varchar2_table(3) := 'DE67DF937D70A916F1AAB6584CADFA0238506397DB2E39B8A939F132C76A1F673C02D8101FD925F009B23554E8890088E8CFB0207440B9F50B85C56F121D7E67B63865F4B2C5E2F05B169ECCFF71C140BE3FDF87D5F592543FF2C259D49D2EBEF7000000';
wwv_flow_api.g_varchar2_table(4) := '2574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F0000007D74';
wwv_flow_api.g_varchar2_table(5) := '4558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431';
wwv_flow_api.g_varchar2_table(6) := '312F69636F6E732F6368617267696E672D73746174696F6E2E737667FA69CB5D0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228328681447290173)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/charging-station.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F0000007E4944415418D3BDCF3D0E82501045E1EF51636DA3B20FE30224EE8515E942FC8B2D6BD00E2CA5017B2C8CD16742673CD3CD';
wwv_flow_api.g_varchar2_table(3) := 'CDC9CCE577640EEEF666AF450256AE6AB98DA3B193756CD5E6162A9D14236D6C93082815528532B673B5CA5266A7B37DDF7ED2E8A3B961E24C00FD4093900C05A62EC376F8FCBCF90A1BFFE001555722227A5FC3400000002574455874646174653A6372';
wwv_flow_api.g_varchar2_table(4) := '6561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F00000073744558747376673A626173652D';
wwv_flow_api.g_varchar2_table(5) := '7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F63696E65';
wwv_flow_api.g_varchar2_table(6) := '6D612E7376673413D18B0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228329069541290208)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/cinema.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000784944415418D38DD1CB0D83300C80E15F5586AA1AE892286202028CD1AE9270A2033417C2C195202DAEB00F397C96FC089C';
wwv_flow_api.g_varchar2_table(3) := '8C9A818944A4A72AC9D0928B74988DBF510A3E713FC04CC60A8F0A7BE149E1289C147EC3057829ABCEC24F851FF25C59FE4D0EEE009BFDD5DC0F9AB293C51348043A6E27FF690576046DBD8B5434890000002574455874646174653A6372656174650032';
wwv_flow_api.g_varchar2_table(4) := '3032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F00000073744558747376673A626173652D757269006669';
wwv_flow_api.g_varchar2_table(5) := '6C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636972636C652E737667';
wwv_flow_api.g_varchar2_table(6) := '420BB5B00000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228329486224290223)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/circle.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000BE4944415418D375D14B4E02511085E12F770502D1B1F486244E78EC4721ACA68135480F78EC824EC0B080EEDCE43A684154';
wwv_flow_api.g_varchar2_table(3) := 'FA9F55FECAA9E4140DC1C44AA9565A1A0B6EC8EC25950FB9B54AB293FDC893E8DDC3F7DC31151DF59BD8BDE8C56F06A2ADC044F2E63F33C98895EA1A7B4B576D4169ED3E8543D0F3D9A24F7AC1D9638B7E7266A9D269B99D33964CEFE8B96448B0130DFE';
wwv_flow_api.g_varchar2_table(4) := 'C857D1A6A9367314CD74AFB173D1D1F365B76F2BA91572855AB2692ABD108C2C1C540E72C3CBC7BE007659427F5BBA05FF0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000';
wwv_flow_api.g_varchar2_table(5) := '002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F0000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F';
wwv_flow_api.g_varchar2_table(6) := '6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636972636C652D7374726F6B65642E737667144956330000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228329949001290238)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/circle-stroked.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000564944415418D38D90C10E80300843DFF6FF9FEA558EE2658E2A432D21A1831632F80DC3B1516FB9ED383E6B00BA28A155A6';
wwv_flow_api.g_varchar2_table(3) := '11C1F7305AE57199EBA3F2D16E92CABFD48954BBE3E242FD7AF96A900EF39F8D3B9E3CE3043A474162747BF94A0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380000000257445';
wwv_flow_api.g_varchar2_table(4) := '5874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F00000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F';
wwv_flow_api.g_varchar2_table(5) := '6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636974792E73766793EC05040000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228330220538290255)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/city.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F0000006F4944415418D3B5CEB10DC2501083E1EFD2670096A06108BA28536405C6C88CA4A047A2CB4347911051A00712C257FDB6CE';
wwv_flow_api.g_varchar2_table(3) := '325F68EF2CF52BF5D2C5E1191E5DA53469D19AA474D3C16096EB8D18372A4E36588C41797542D64635F5CD8D10766F921062F9BED7CBCB4FF19FCA3FE80195D92E6F569D45C50000002574455874646174653A63726561746500323032312D30362D3232';
wwv_flow_api.g_varchar2_table(4) := '5430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F0000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F';
wwv_flow_api.g_varchar2_table(5) := '55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636C6F7468696E672D73746F72652E737667AE';
wwv_flow_api.g_varchar2_table(6) := '7A19B80000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228330647088290272)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/clothing-store.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000C04944415418D38DD1BD4A82711407E027FA9AA44DA4A69A5A24A8E1BD820607AFA14B688AD66C5168F2061A5EA71AF306BC';
wwv_flow_api.g_varchar2_table(3) := '8F6A50A92588A00F88D4D3506FFF4C02CF6F7C381F7098BBCA4EF4B56DCCD296B637218477B9ED443B721FDF5464AC2B8323933F94720C556134D37D69AF181F36FFDF7D2A3450D132D052B1683FF183F06AD58115941CBA7597B8219CA90943E79E84F8';
wwv_flow_api.g_varchar2_table(4) := 'CD9990B9983AED267147E8A84F71B3C0052FC2B3F51F9AC82D7FE192D05577E5DEAECC9A473DD7737EE913EAA467523A67C5B60000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380';
wwv_flow_api.g_varchar2_table(5) := '0000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E';
wwv_flow_api.g_varchar2_table(6) := '6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636F6C6C6567652E737667E1CDE3430000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228331031590290290)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/college.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000A74944415418D395D13152C2601005E02F7469E8A04AA9751A69F00014E015F42A7A08ADF502B18013380E0C1D07C199D8A5';
wwv_flow_api.g_varchar2_table(3) := 'D0AC0514FC26CCE86EB3F3DEBE7DBBB3FC23163ECD4F8141425F199A74358DE864637E50C719AB13FC59B83FD60FC24BDA792DEC8D30F6214C7F8F5A09954C252CBB4E855A580BB5A26F95992FE1DB4DFFDD1732642EBBCADC93D07AD50A8FF294DE0A8D';
wwv_flow_api.g_varchar2_table(4) := '5BDC69844D4ABFDB298F7569E7ED4F3FFA01DCB735531DA660680000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D';
wwv_flow_api.g_varchar2_table(5) := '30372D30395430383A35303A33382D30353A30308A1F1A9F00000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D';
wwv_flow_api.g_varchar2_table(6) := '302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636F6C6C6567652D4A502E7376675B1F89210000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228331452230290308)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/college-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000424944415418D36360A031D063F88F15EA30303031303044E0D0160991B6C7216D07A1DEE030FC3541673142E9FF386550A4';
wwv_flow_api.g_varchar2_table(3) := 'D16826FC86B360E84701047413902600009C601E55ACD7024E0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30';
wwv_flow_api.g_varchar2_table(4) := '372D30395430383A35303A33382D30353A30308A1F1A9F00000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D30';
wwv_flow_api.g_varchar2_table(5) := '2D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636F6D6D65726369616C2E73766798F2E52F0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228331757664290326)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/commercial.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000D54944415418D37DCF3D4A03611485E16732430A0523085A5A08922A888C1341B7E0264CB0504B317B48696D23D696E21AEC';
wwv_flow_api.g_varchar2_table(3) := 'FC01C125C49F480A192CC658CC073362F014B778CF39DC7B818686DF8AC428873D2DB96F0548B4ACDBF124B452B70E25DACE6D683A76AF5326A140ECD3819E484F1C58B02314E69DD93234A7082CEC5EB0EC5A6E6CD595C883D4C47375E71A122FA65E35';
wwv_flow_api.g_varchar2_table(4) := 'D12EDB756D7AC49DB442F57FBB72035FB6CDD4853EF65D5628A9D9990F032BBAB3BA8B266244C696FEB6336F4EC0BBCC4DDD3E15D9350AC191231D0C4DFDAF1F1A3F2C894784D1CC0000002574455874646174653A63726561746500323032312D30362D';
wwv_flow_api.g_varchar2_table(5) := '32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F00000081744558747376673A626173652D7572690066696C653A2F2F2F43';
wwv_flow_api.g_varchar2_table(6) := '3A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636F6D6D756E69636174696F6E732D746F';
wwv_flow_api.g_varchar2_table(7) := '7765722E737667BAC3372C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228332219912290345)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/communications-tower.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000854944415418D3ADD0B10EC17014C5E18FD8245E47CCD83A60F532FA02DE40E2593462A183C46668780121E6BFA1DA94269D';
wwv_flow_api.g_varchar2_table(3) := '7AC6FB3BB9E79E4BFBDA4B9A7010EA8685B3B79348280CBD0A5CDBCADC6DCA1D15A5A6883171A8E73DF5B1C2C0A318764B7C31440723D7DF1AF92999B1A5D8CDAC8A932F8E1CBDA4E6FFB9B9A141895DFBCFFF00471C29804652ACAC0000002574455874';
wwv_flow_api.g_varchar2_table(4) := '646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F0000007A744558747376';
wwv_flow_api.g_varchar2_table(5) := '673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F';
wwv_flow_api.g_varchar2_table(6) := '6E732F636F6E66656374696F6E6572792E7376676D203FAC0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228332489223290364)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/confectionery.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000764944415418D39591CB0980301044DFA600FB9078525BC951CBB1150BB01DB10441F028C48BC62426883397FD30EFB00B3F';
wwv_flow_api.g_varchar2_table(3) := 'A4D9D0FE4005EB9E822E9F9EB12C483ADD7220ECD4E9B56102464C1E6D63FC83B6CECD1B6E1810046148E167AAAB2ADF781FEDE1954387F2FA354ADE5EE3A386B29F3F3A01210C2CEFB970349A0000002574455874646174653A63726561746500323032';
wwv_flow_api.g_varchar2_table(4) := '312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F00000079744558747376673A626173652D7572690066696C65';
wwv_flow_api.g_varchar2_table(5) := '3A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636F6E737472756374696F6E';
wwv_flow_api.g_varchar2_table(6) := '2E7376671C346DFC0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228332890218290382)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/construction.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000A34944415418D38D8F3D0AC24010853FED72015329689113885EC25B4441F06682A211EBD8B9B944042DCC09D6E004B45843';
wwv_flow_api.g_varchar2_table(3) := 'D6012533CD836F7EDE83BFD5F1F491108082991EDBF1FAEAAD0F4372357EA307D005608A51D8306EF0844CE1CCE1166594ADBACFEEB8FDB1F6A8C595354B9E8CB00C11166C5C16672D25604F454EC905E14040EAE3883BE5E796A520E2D47C1920CC1156';
wwv_flow_api.g_varchar2_table(4) := '0831424C45DFB79128D749ABCC6FF2CE4208D485845C0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30';
wwv_flow_api.g_varchar2_table(5) := '395430383A35303A33382D30353A30308A1F1A9F00000078744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D6766';
wwv_flow_api.g_varchar2_table(6) := '6664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F636F6E76656E69656E63652E737667D18692A10000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228333314334290401)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/convenience.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F08060000003BD6954A000007077A5458745261772070726F66696C6520747970652065786966000078DAED586972EB3C0EFC8F53CC11488220C8E370ADFA6E30C79F06252F719CBC173B5553';
wwv_flow_api.g_varchar2_table(2) := '3535766C490CD504BBB1C934FFFDCFA27FE1C5123245D19C4A4A0EAF5862091527D91DAFE3E85DDCDFC76B9D47FF719CAEFF0818621CF9B84CF39C5F312EB71B349EE3EDE338693F71F209E4AFC0FBC5B6B29D8FD3C81388C331EECF6B2AE70D35DD6DE7';
wwv_flow_api.g_varchar2_table(3) := 'FC847EC29EE08FD75141C610E071A030D9B3DBDFE15889EDE3B9E2A8FB1B6BE19A711E58F677F8CC1F5DA97B42E0F5EC813F77B18C6F741C40976DA5079ECE712F0FE37C5D267CB0C887EBCAE1DEA2BA5C77F7AF3BFED61A79AD79ECAEC644A02B9D9BBA';
wwv_flow_api.g_varchar2_table(4) := '6C659F6162039DBC6F4B782B3E8273DDEF827776D575A836B05C23D770517C00E3CB473F7CF5CBCF7DECBEC3C41866501C43E8D0C0C6326B28A1B34910EDED5750E2C2833394E8508E311CAEB6F8BD6EB1F5B058C6CAC36366F000F3A6DDFD9B1E075E7D';
wwv_flow_api.g_varchar2_table(5) := '7F005ACBB8F5DEE52B57B02B98D7C00C53CEBE310B82F875722A9B5F4FC7C13DBE4C588682B269CED86075ED8068E26FBEC55B677642981ADD112F5EC709008AB0B6C018CF50C025CFE293771A827A0F1E33F4A9B03C700C0D0A782109035686C89C204E';
wwv_flow_api.g_varchar2_table(6) := '0EB636EE51BFE70609C730D20B84104E089B0C812AC48A516242BC65B850256189229244254B919A38C52429254D96A7AAB246154DAA9AB568CD9C63969CB2E69C4BAE2514461A132AA968C9A5945AB1688D155815F32B065A68DC6293969AB6DC4AAB1D';
wwv_flow_api.g_varchar2_table(7) := 'EED363979EBAF6DC4BAF230C1E480134D2D091471975FA09579A71CA4C53679E65D6055F5BBCE2929596AEBCCAAA57D54E553FAAF6A8DCF7AAF953B5B085B2797A530DC3AA17086FE9444C332816A287E26A0AC0A18369E6B28F319872A6992B81895102';
wwv_flow_api.g_varchar2_table(8) := '60A59838C39B6250304E1F64F9AB7637E5BED48DC0EE4F750BCF942393EE37942393EE4EB9CFBA3D516DD49D6E790B6451084E912119E187493564FC212DBE7624F726C07F1F0814229F2391CB68CBE374E664290A95B6A9FD639AC80BF976AC9CF70892';
wwv_flow_api.g_varchar2_table(9) := '2DA641D46657CBB70ADA37D600AFD36B82A3B3FDAFFAAC642721D6B127E7819CB25C6B3A839D5881D8534B90B467F4345B8715D06D996957C3A0DA611BF43C8C7B346D1B86598769CBFA9067A6111634CBD63ACCB2DD1F66B9AB6187598751B6E0835107';
wwv_flow_api.g_varchar2_table(10) := '5F744FD82B7C4D4C40182E4240771178F4F2452602A8212EE0BB732414BC3193C4D5300545B3C782EA86F0AD3025F12A435B17EDDD630665B32422C961B7DD4B509837726D13C160ED97A9FECDB10165B240FE1897471B19B523E29173AA9FB5AD84302D';
wwv_flow_api.g_varchar2_table(11) := '1C574424F3EC28E6A52887880CD75B4571F6512736827B173B9DC313080E0253F7DE9B93B839A99C040B4E53F1EA30DF8A427FABCA9F44A157BCF89913D32B5EFCCC89E9152F7EC617FDB517FFC113E83AB0925BA374F8513417006872107A3398E0B310';
wwv_flow_api.g_varchar2_table(12) := '769CCEF7CCF7E827CE376DADCAED58AB6C9BB15AB623C1D97BBB5B2EAA1ECB6D5B6C416FB28F92C0534745F86215FA93195F1C6767049FE609F3E0DDE64709A192B0D7B920641929A3384DD1B2A6240EB0A5A1B041C456724FDC86D6ED479DE3D035623D';
wwv_flow_api.g_varchar2_table(13) := '5C46088DE31C881A3CE6E0A1490F87BC9F5550D26D93C3A2E7F1F6DBDDF4DEEDB7BBE9BDDB6F93E8BDDB6F77D39E85C0F17E7595C3CBA173E4B42AD8470F3232F7D222DA88853C6633ACB1514DC3BA85B6068292918F6ACBEB174A2DB95FAAD9FF07FA9F';
wwv_flow_api.g_varchar2_table(14) := '076A090FAC9ACC57CBCABD456EAEF5BC3A321AB53A6218D3A3A2A2B16F68CF110A1DCF93C51787525BED260B20145B455F7C94A42354003A112479CAFE91054F03A2089D1D1E35363CDC208E5C437D28DCF4283B8A442B79F9244850B394C961289EBB3B';
wwv_flow_api.g_varchar2_table(15) := '905084D22015D732AA541C3DCE11050D4740178E661BC568587EF5F36FB226BD9066BF049A086F578E66A2F3CE00C90B2AC21ABE36EBF95118A29FA00C152FEBF4D5E6345747DD8541EA6A84BA603F826480A99E60B15DC0EA061B3730D4A2032CC8056C';
wwv_flow_api.g_varchar2_table(16) := 'EC968AD2EE5EE6DBBBA31F56A193058C5C78385980437E26C23A92938A930883D8543C307102820B5A27151BF0818C13D0E8B891F10517F41BD27F07F4572E110AB68F5AE2876F8486A5C6548BBA16382204B43938796E68A925D7CA390597221E92BB5B';
wwv_flow_api.g_varchar2_table(17) := '82321F0186728407DCA3CDC868C6105374F66A790EAB5A4EBEF79654971E9D63CA73393D5A4656E9FBE9E8D2192E0F85CA4055432F1DB9F685E609012D618C142507EC28258426AEEC470851B5DF38BB0F8CCE9F67B5D00C6FFA24FD4EC8BE080449D15E';
wwv_flow_api.g_varchar2_table(18) := 'C175ADB51DE834C136ADE95ADD7DF50C69778339E281C9DAE8182A9E9520449865BB672E1767FC0C4550EE57A0C8CCFA0D283A76F83E145DC87A178A6EBCBF0745F712BE03451FBDE175287A74AC57A1E8B38FBE0645CFDCFD15287A1E393F87A2E791F3';
wwv_flow_api.g_varchar2_table(19) := '7328FA2A087F0A455FC7F3CFA0E8BBD4F013283AC9DA35F49D1449EFD74694BA82ADFD07A30A3ED56F224BBF00000185694343504943432070726F66696C650000789C7D913D48C3401CC55F53A52A950E7610E990A18A8305511147A962112C94B642AB';
wwv_flow_api.g_varchar2_table(20) := '0E26977E084D1A92141747C1B5E0E0C762D5C1C5595707574110FC0071737352749112FF97145AC47870DC8F77F71E77EF00A15161AAD9350EA89A65A4137131975F1103AF08A017218C222231534F6616B2F01C5FF7F0F1F52EC6B3BCCFFD39FA9582C9';
wwv_flow_api.g_varchar2_table(21) := '009F483CCB74C3225E279EDEB474CEFBC461569614E273E231832E48FCC875D9E537CE2587059E1936B2E939E230B158EA60B98359D95089A788A38AAA51BE907359E1BCC559ADD458EB9EFC85C182B69CE13ACD081258441229889051C3062AB010A355';
wwv_flow_api.g_varchar2_table(22) := '23C5449AF6E31EFE21C79F22974CAE0D3072CCA30A1592E307FF83DFDD9AC5C90937291807BA5F6CFB631808EC02CDBA6D7F1FDB76F304F03F03575ADB5F6D00339FA4D7DB5AF408086D0317D76D4DDE032E7780C1275D322447F2D3148A45E0FD8CBE29';
wwv_flow_api.g_varchar2_table(23) := '0F0CDC027DAB6E6FAD7D9C3E0059EA6AE906383804464A94BDE6F1EE9ECEDEFE3DD3EAEF07840872AE8E8C74E000000006624B4744000000000000F943BB7F000000097048597300002E2300002E230178A53F760000000774494D4507E50709121918D2';
wwv_flow_api.g_varchar2_table(24) := 'BBF55B000001194944415428CFA5D34D2B45511406E0675F47F2353340462652264ACC9481810C4C8C95DFA48CFC151353C5442232F135A044E1BA5796C952A7E38E78EBECB5CE5EEF591FEFDEA74484BFA2E51F2858C415BA98C65944BCFF2296328A65';
wwv_flow_api.g_varchar2_table(25) := '1CA10F4BF08C6DACE3127311A1F9601637D8C4163E0B02E7597932B357E9EF63050F78C5011EB3E359F8CA048127AC6217C798C721F632C9638D1B7279C07DFA7739CA07AED1C60B6EB3D07DF2A34A3D2EB2AD714CD4749A4A3B80D1F44F3084B19FA31A';
wwv_flow_api.g_varchar2_table(26) := 'C24843E053EC24B98E110CFFBC448AD5A9CDD2C646AABC86B75AAC93FC68E54685FE5AF68F9C516AD0AEC5FA93AF95B2F7C257C3FE42952D95C6ADEB62A1943288197C66F5685ECFE51ED5233F888C55BD3A2CFFF9ABBE011E4D6875DFF2453000000000';
wwv_flow_api.g_varchar2_table(27) := '49454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228333709116290420)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/corps.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F0000009C4944415418D36360408036862F0CAD0C38C16786FF0C9F50859890D89318BE304C62A03A6062B8C5F01F0ADF33D8A14BCB';
wwv_flow_api.g_varchar2_table(3) := '42A5DC1918187C185E3338A24ADB31FC67F8CF700FEA505B86B3A8D2F10CFF19FE312C84F305503DA6C8C0C090C1E0C0E00315AD42D5BD90E123031B8316C37B28FF27033384C102D5BD9DE117C335B8A110C92484E19BB078979D810DC2B801D5778B01';
wwv_flow_api.g_varchar2_table(4) := 'C6676220060000FFD124ECF3B2931A0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A3530';
wwv_flow_api.g_varchar2_table(5) := '3A33382D30353A30308A1F1A9F00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F';
wwv_flow_api.g_varchar2_table(6) := '6D6170626F782D6D616B692D666664646431312F69636F6E732F637269636B65742E737667E05DDA9C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228334149290290439)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/cricket.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000944944415418D385904B0E83300C44DF094AA27E966CB8FF0D90A84055819266D1CB2075E12E4C500D51EB959D79B632037F';
wwv_flow_api.g_varchar2_table(3) := 'EBC615BF79F33474DAD608C1009E80D0EA70E08E10392EA26344889C12FD0DA8F85C6103548C08C18A00053DC21B61C0E51C94CC0833654E740CCB764F911723150F84C9E690ACE8CF270BF88D150D6505DADDB9332F845A878E6697F9859042FD511F20';
wwv_flow_api.g_varchar2_table(4) := 'AB3E02F292B8890000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30';
wwv_flow_api.g_varchar2_table(5) := '308A1F1A9F00000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D';
wwv_flow_api.g_varchar2_table(6) := '616B692D666664646431312F69636F6E732F63726F73732E7376674F4FC8BB0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228334418319290459)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/cross.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000934944415418D385D1B10A010118C0F15F32186EB2106F814D5236BB9D67909710EF61521E42992E3228D94C2EA764319EC5';
wwv_flow_api.g_varchar2_table(3) := '7074CE377DF5ABFF377CFC9D9BA77A36155056D2FBCDD0FD1D4F244EF99CB8DA69683BB81BAB5A5AA77964E8E26CA0612B3615A4799E1F0FF339B1D7D271F43051B3B2F9E485C8495F4B283613504C55CE2AEFAD9915DF64DF8EDF1CFD7FCFD7BC00A652';
wwv_flow_api.g_varchar2_table(4) := '3B157D7A5C000000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A3030';
wwv_flow_api.g_varchar2_table(5) := '8A1F1A9F00000070744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D61';
wwv_flow_api.g_varchar2_table(6) := '6B692D666664646431312F69636F6E732F64616D2E7376678BEDFE930000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228334798937290479)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/dam.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083226741B333F000000CF4944415418D36DCF3D4A036110C6F15F92C5F8D16BA36093428B1C20043D414A5B4BC1CACED503440CE400E952A5501BAB';
wwv_flow_api.g_varchar2_table(3) := '34A227105C11C1466D34A7505E8BDD98EC4BFEC334F3CC3C3CC394C4B917C1B3338988C483F05FF7F1423A2706C16959CEB4B40BA9A5ED291F570B794755C57456B15BBEEE47E6BD38DC85605474D7028246D10BB9F52BF87113A71E68826DC7B640D340';
wwv_flow_api.g_varchar2_table(4) := '96CBEB521F1E1D59C1920377BE5CDA9C39D4748C4D0C4D8C75D4CA7FE7D4ADAA23CCC7DB90FAF4E6C41A961DCA7CCFCCDF5DD98BBED877ED953F2A2E45835838CC880000002574455874646174653A63726561746500323032312D30362D32325430393A';
wwv_flow_api.g_varchar2_table(5) := '33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33382D30353A30308A1F1A9F00000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572';
wwv_flow_api.g_varchar2_table(6) := '732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F64616E6765722E737667319B16FC0000000049454E44AE';
wwv_flow_api.g_varchar2_table(7) := '426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228335184304290499)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/danger.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000C14944415418D38DD13F4A03511007E0AF5021E402B68BA44D4894D4769E604B6F60BC85606DE151A217087B031BB385209B';
wwv_flow_api.g_varchar2_table(3) := '80B8290443FC37161BC3461476A679EF7D530CBF47831A997A76A3838E5BA57BA31F3C17EB2EF4149BDB59C58F9B87F06269B93E3F54BCAA71481DFB14C26BC5590D0BBB765C096152712A97CBAD840B07AEB56572E9F6FE5D73894B5F4EB6A165ECCEA1';
wwv_flow_api.g_varchar2_table(4) := '7D7BE6C287B1567D2031533A722A8499E47734030BEFDE8485C15FD9F53D09A5E17FE176657A4D7EA1597D03BA1052E8D69576C70000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943';
wwv_flow_api.g_varchar2_table(5) := '800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B0000007A744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F77';
wwv_flow_api.g_varchar2_table(6) := '6E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F646566696272696C6C61746F722E737667A005FDBE0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228335610254290520)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/defibrillator.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000AC4944415418D38DCF3D6A42411406D08398525C805576903DA4B31117E10E2CB20121A5FB08C4C6C6CA42B408B66A0ADB40';
wwv_flow_api.g_varchar2_table(3) := '0A158282F80363E1C8F8CC13FCA6F9E69E81CB7049D1DDBCFAB5F3166F0D6B2BF5C4634110B4943463FF4EBC89A3EB7380029CEB4DB6891739BC4C3CCDE179AAD59CDDB5EBB75D413051311204DDF3B8107908DA7EBC8341963738E8A0678DBFFFDCB7C0';
wwv_flow_api.g_varchar2_table(4) := '4E0FC72CAFF019FB07F6D96F3C9B29C7FEE4CB8B47720220B7424B1786A1DB0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900';
wwv_flow_api.g_varchar2_table(5) := '323032312D30372D30395430383A35303A33392D30353A30302C68112B00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D7637';
wwv_flow_api.g_varchar2_table(6) := '2E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F64656E746973742E7376675C1BF0DA0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228335995826290540)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/dentist.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000924944415418D395D1310AC2500CC6F17FDD4428285610845EC0C1ADA3142F65EFD4A18B2770F1041D3A38140AEA20382B7C';
wwv_flow_api.g_varchar2_table(3) := '2E0F0CB11D9A31BF242FE4C188C879900FE19627E2C5AE0F37B408213A528F0BEA8042342416A79C0D0A7161F6E3D2A11025C00480B86717935BD1B9DE1B6B5BBBE76DF0C3C10F2B0C1FFFDF8AA8029EC2462EE65C112DCBA1B366DCC946FCD1178CE042';
wwv_flow_api.g_varchar2_table(4) := '72ECC629200000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C';
wwv_flow_api.g_varchar2_table(5) := '68112B00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B';
wwv_flow_api.g_varchar2_table(6) := '692D666664646431312F69636F6E732F6469616D6F6E642E737667461246780000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228336256357290560)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/diamond.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000B04944415418D38DD03F4E02611087E1071220446201F7D09A860E0AB4A5818E3F47D14B0815058D5470094A2DA485339010';
wwv_flow_api.g_varchar2_table(3) := '16086BB3AC986F4D9CEA377927336F867FD4AB48173D91971047AA49AA398438FE23CB83B362D2979C43BCD648FA86AF7079C7465345CB4647D9DCDEBBF2CFC0C045EC628891857B4BFDEB7226C67833C6510EB9DF071EC51E40C1546CA6748B0B2277A9';
wwv_flow_api.g_varchar2_table(4) := 'FFE1D61C4E3ED553FF8FD0FF39F5DF6A67FDFEC9CACE2A1B66D4370D45299F792009820000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F64';
wwv_flow_api.g_varchar2_table(5) := '69667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B';
wwv_flow_api.g_varchar2_table(6) := '692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F646F63746F722E73766795F17D8A0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228336727725290582)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/doctor.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000CD4944415418D38DD1A14A047110C7F18F770772C964134CA7C168B45E10F3FA02623089C564B1CA15411FC026821A2C960D';
wwv_flow_api.g_varchar2_table(3) := 'BE80E94C06917B02453C44971D83FBDFF52EDD6FD2F0FDCDFC068619342F7368A9EA365D4EE22BA1B05D75E7C2BE5E83BF9CFE33E74218EBD3AA96BF4DC5BDEABAB63607422EAFC09D910B191826DCE8C38E1B7B967DBA87B698A8D240BBF1AF4CE11016';
wwv_flow_api.g_varchar2_table(4) := 'FF50C796A3CA7602D6F5F19D66C74A2F8A3A7F4308DD84C3311E6BDCF12E52764B29C3039E40E116C3E4DDB58A333FF5A9079E2DCCF22ABF55BF43E1C68088460000002574455874646174653A63726561746500323032312D30362D32325430393A3333';
wwv_flow_api.g_varchar2_table(5) := '3A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F';
wwv_flow_api.g_varchar2_table(6) := '42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F646F672D7061726B2E7376671E4F1A680000000049454E44AE';
wwv_flow_api.g_varchar2_table(7) := '426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228337138242290604)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/dog-park.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000744944415418D36360201278333C61F88F0691C0630CC9FF0C0C8C70E9FF584C44C842D50BE192FF8FAE9E8181818109CE7A';
wwv_flow_api.g_varchar2_table(3) := '0BC5A483D748AE7D8569F81D06570646064606460657863B98D2FB191CA17C7B86039886BB2219EE8E29CDC5F0132AF99B81179BE38E40A58F61F7F71628BD1D551A003099358A92F330C30000002574455874646174653A63726561746500323032312D';
wwv_flow_api.g_varchar2_table(4) := '30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B0000007B744558747376673A626173652D7572690066696C653A2F';
wwv_flow_api.g_varchar2_table(5) := '2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6472696E6B696E672D7761746572';
wwv_flow_api.g_varchar2_table(6) := '2E737667D5C103970000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228337478354290625)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/drinking-water.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A90000007B4944415418D36360200A1C65F88F020FA34AC384EFC35958A43F302830BC43966642513481E101C3246C7643F40A323030';
wwv_flow_api.g_varchar2_table(3) := 'F043F53330303030B02029B9CD90C6C0C0C0C07097C10426C408D78D0E18D1755F61D8CAC0C0C0C0E0CDA043A4DDC82EE767C8676060286410C4EE722CFE2632D40EA385F921A2620A00C5AF46F37C7F5B460000002574455874646174653A6372656174';
wwv_flow_api.g_varchar2_table(4) := '6500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00000075744558747376673A626173652D757269';
wwv_flow_api.g_varchar2_table(5) := '0066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F656C657661746F';
wwv_flow_api.g_varchar2_table(6) := '722E737667BFB559FA0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228337949380290647)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/elevator.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A90000007A4944415418D3B5CDB109C2601086E1E717C1C20552B98913E804F66E60E91069C5AD14EC040B2B2DD401CC5918F213082A';
wwv_flow_api.g_varchar2_table(3) := '01DF6BEEEE3DBEE32B730FB36E3540200C956EF696C60A6B977CB4C046D455790A010984A4AAFB4C7A873743F7EF0FB4F5CEB5E9EF791D389A6264E5E46C6BD2D63F84FF451FF4E3054FC51C587E84915A0000002574455874646174653A637265617465';
wwv_flow_api.g_varchar2_table(4) := '00323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00000074744558747376673A626173652D75726900';
wwv_flow_api.g_varchar2_table(5) := '66696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F656D62617373792E';
wwv_flow_api.g_varchar2_table(6) := '7376676713A4840000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228338182501290670)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/embassy.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000944944415418D36360A006686298C4C00CE7FD479612615063E06138C450895D7A13C373064D061E0627A8140C42C16F86FF';
wwv_flow_api.g_varchar2_table(3) := '0CCF19849034C0A598A07815C33B5CCE3AC0F09FE12283302E690586870CFF192EE056A0C8F090E13FC379B8026B866A06165C0A7819B818F630CCC666C205866E86270CEA0C5C0C6DD8ADF8CFF09FE119833A76471E60F8CBF087610B833851510100B0';
wwv_flow_api.g_varchar2_table(4) := '992C4B3A86F1D30000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30';
wwv_flow_api.g_varchar2_table(5) := '302C68112B0000007C744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D';
wwv_flow_api.g_varchar2_table(6) := '616B692D666664646431312F69636F6E732F656D657267656E63792D70686F6E652E737667BD832A080000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228338566427290693)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/emergency-phone.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A90000006D4944415418D3AD90310A80300C451FEAE22DBCA62058103C98B5A770E801DCA5201807ABD4DA6E26CB278FFC1F027F9541';
wwv_flow_api.g_varchar2_table(3) := 'C7A322D00712E332D02B334BDEDCE100E8D811248E122CA010DFD31B5B1A0F07AAAFF90D553AFB827D0AD58CB94DF31C93B4D508C246FBCBEF833A010C0129F6FECABC6B0000002574455874646174653A63726561746500323032312D30362D32325430';
wwv_flow_api.g_varchar2_table(4) := '393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F5573';
wwv_flow_api.g_varchar2_table(5) := '6572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F656E7472616E63652E73766714F513880000000049';
wwv_flow_api.g_varchar2_table(6) := '454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228339044348290714)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/entrance.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000664944415418D36360201ADC62F88F040FE3532ACCF01FBF59FF191818189850842C187450D5A04AF333EC6630C067A437C3';
wwv_flow_api.g_varchar2_table(3) := '0B061384E1982EFECF700D551A190431BC6430C625EDC9F08C411FD9E5A8C08C410BD56324F91B39D4D08022C34F14F71F62200C00F82D262C3EBF358F0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A3436';
wwv_flow_api.g_varchar2_table(4) := '2D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B0000007A744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F423245';
wwv_flow_api.g_varchar2_table(5) := '44534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F656E7472616E63652D616C74312E737667F9EE9ECE0000000049454E';
wwv_flow_api.g_varchar2_table(6) := '44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228339434572290737)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/entrance-alt1.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000674944415418D3B58EBB1180300C435F3856A0611A966005368161681920FB50505140259A9C133E390A0E55B69FA513FCA1';
wwv_flow_api.g_varchar2_table(3) := '81953E8F77C4062E8305802BC25A3132513FFFB6CC08B1D0995B2181C646219A2BF627EC53ECAC4654BC59B58CCAC4C13DE9C5FD4D07E0E4220685E7DDA60000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34';
wwv_flow_api.g_varchar2_table(4) := '362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F4232';
wwv_flow_api.g_varchar2_table(5) := '4544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6661726D2E737667ABDA97580000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228339696993290759)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/farm.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000624944415418D3A591D109C0200C449FFD70B7B68BB94747295DA4EA1AA61FB158C582E0DD47208F3B028179ED04A4B2672D';
wwv_flow_api.g_varchar2_table(3) := 'D823085B463AEF825BA4133019F764860EBB9AB35E9FB000E9272643E5103BD501B41C8E4EE4B3B3B8AA21E2B0F3CF7800207E3EE342202D210000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A';
wwv_flow_api.g_varchar2_table(4) := '303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43';
wwv_flow_api.g_varchar2_table(5) := '462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F666173742D666F6F642E737667FA96A7D40000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228340099372290782)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/fast-food.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A90000002A4944415418D36360A039C8C781A1E03F0ECCC084DF58260606865B38F4DEA286E134B6FB360E4C2100003BEC2715042834';
wwv_flow_api.g_varchar2_table(3) := '3F0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00';
wwv_flow_api.g_varchar2_table(4) := '000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D6666';
wwv_flow_api.g_varchar2_table(5) := '64646431312F69636F6E732F66656E63652E73766739A7DECB0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228340456723290806)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/fence.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000B84944415418D38DCE2D4F42711407E06737E2DC085098C5CD666154706376027326BB7E0A0B4433DF8064D569B03837A562';
wwv_flow_api.g_varchar2_table(3) := '30EBD4E6AC8E1BD82120E37FC70DFC4E3A7B765E58E74508E1D94686F27F0C21372872AE9A7455B32207D871A692F409674E7D08DFCE659BFC9ADC9EA45C779DD0AA6E3496DC2DC110BAABF9C7127C58AF3F2EE1A3F4B5A704E6C27DF1F3A6A65D3DB73A';
wwv_flow_api.g_varchar2_table(4) := '32FB0E6C9B2F270E4DE4466AAECC4CB5F47D2EB9E7DD8F0B7BEEFC196BB8F4EB4D9B0521D6624CAA5324B00000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874';
wwv_flow_api.g_varchar2_table(5) := '646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D61';
wwv_flow_api.g_varchar2_table(6) := '70626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F66657272792E737667F44383CC0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228340868244290830)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/ferry.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083227031C03A9000000744944415418D3ADCDB10D82001086D18791826168ED5846776002DD451B9D406BE306CC801B50FC9606046DFCAACBBD5C8E';
wwv_flow_api.g_varchar2_table(3) := '77A58BB3D2420711FB79DC18F47A83CD1CDFC4D64E5C3FB1119D42A113CD944FA205AD384EF9296A508B7ECA1115A844E678665EF9DA0F5E8F1E2C5E3F46DBBBBFF40204B72420A9A7A4410000002574455874646174653A63726561746500323032312D';
wwv_flow_api.g_varchar2_table(4) := '30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A33392D30353A30302C68112B00000075744558747376673A626173652D7572690066696C653A2F';
wwv_flow_api.g_varchar2_table(5) := '2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F66657272792D4A502E737667DE8B';
wwv_flow_api.g_varchar2_table(6) := '10090000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228341270280290854)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/ferry-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000C54944415418D37DD0AF4A045114C0E16FC2C2862DDAC42CF8074110CD8B6012340AA6019BF82AFB0E621B106C1AB78B4141';
wwv_flow_api.g_varchar2_table(3) := '7C0265C30635A9658E61CEC8ACA8E7A6EFFCE072B9CCCEB27F66C99B95DFC23A0A6361AC487FCF8677BB4A2184D2D087CD36F6DC0B13D3CC5313E14EAFC9C7B9FE79CA263FFE911F60B1B378B5EFA5E305D63A3CC05EC7ABCCAB1397F9D48B746D0E6E93';
wwv_flow_api.g_varchar2_table(4) := 'DB99B7D2370D8F9283CC83F461C322AF3BC97C2A844AD17E4CDFB950BB32722D8433FDD95FDF5179F6E94965D82EBF00E8AF6EEAC7E1FDA00000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A30';
wwv_flow_api.g_varchar2_table(5) := '3026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE100000079744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D4346';
wwv_flow_api.g_varchar2_table(6) := '2F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F666972652D73746174696F6E2E737667BD5A4CBB0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228341601321290878)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/fire-station.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000814944415418D3ADD13D0AC2000C40E18F16FC398BD4492FA0F44C7A8582CEBD86DE43DDA578084571332E055BB5933EC890';
wwv_flow_api.g_varchar2_table(3) := 'BC4012C2EF8C6D65DDF9525835F45A5840022AE4D25AA6721C5FDD7D27A134C05029547ACDE97337E16CE7225CCDDED79B3A0821EC4DBE5F500845B390B4F4BD8E0EFD415B3FEAE820B331FAC3176A9E505C208C13D74CD1000000257445587464617465';
wwv_flow_api.g_varchar2_table(4) := '3A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE10000007C744558747376673A6261';
wwv_flow_api.g_varchar2_table(5) := '73652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F66';
wwv_flow_api.g_varchar2_table(6) := '6972652D73746174696F6E2D4A502E737667A73C0DD40000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228341992867290903)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/fire-station-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E380000002B4944415418D363601868D0C0F01F4DE43F4303B224A6F47F8606060626620CC6051B28359CA0CB070A0000BAE41DECE61D';
wwv_flow_api.g_varchar2_table(3) := '4F790000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE1';
wwv_flow_api.g_varchar2_table(4) := '0000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D66';
wwv_flow_api.g_varchar2_table(5) := '6664646431312F69636F6E732F6669746E6573732D63656E7472652E737667694697480000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228342384724290927)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/fitness-centre.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000F14944415418D365D12D4B836114C6F19F0EB66706A726C306BA22D8FC0A829F416C5370CB43C120A2496183BD04835AD67C';
wwv_flow_api.g_varchar2_table(3) := '29FB06065F8ADD220816B10C4DDAE4366CCF9EA9FF76EEEB5C87EB9C9B984509396BA2B8C86ACB3B50D0969552722238B21A37B4DC7874A78965C1AB860FC1425F2E0B826013139E6DA1E1C1583CBEEB535734703FD9F696B847C9D871213855359E3C1F';
wwv_flow_api.g_varchar2_table(4) := '0E325730AB6AD2AF55F691736C5AB2D1908AA5113163434B3B16EB3AA6469C57825B7952283A3763CEAE79152BAE9D897C497B879A2078D1511E04BA14DC2BF403F404C1B7FA3049DABAA61694043D35C57F1788604F29F99DBFFC00202C3EECF863895F';
wwv_flow_api.g_varchar2_table(5) := '0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE10000';
wwv_flow_api.g_varchar2_table(6) := '0074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664';
wwv_flow_api.g_varchar2_table(7) := '646431312F69636F6E732F666C6F726973742E73766729767F150000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228342774185290951)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/florist.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E380000006A4944415418D38591CB1180200C441F962035D8A934266313B6E145B8C4036350E4B37B0959B2CC061862475EF4A52C0513';
wwv_flow_api.g_varchar2_table(3) := '8E2CCF7AD5AA2C94C5E7A4CFD465FF5482AD988380F94DA75E92CD54092A045C2F98E5EA9B0BA6650E105908EDAD394ED69C30731B7F92E206DE51432A29B329950000002574455874646174653A63726561746500323032312D30362D32325430393A33';
wwv_flow_api.g_varchar2_table(4) := '333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE100000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F5573657273';
wwv_flow_api.g_varchar2_table(5) := '2F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6675656C2E7376671BF834160000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228343152394290978)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/fuel.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000714944415418D38D8FC10980300C451F1DA5AEA1E2068243F6D025BC3885AE50275088074B69530B2687903C1EFCC0CF1AB8';
wwv_flow_api.g_varchar2_table(3) := '91D817A3C66B8282B095B02FA0204C6D57F9B51B7D03C0F219766EFF21EF30EA7C1200385A96E46B6E5B1C008EAEF62C21650E588D7DF194D7782F70239AAA074F64474BFF41710B0000002574455874646174653A63726561746500323032312D30362D';
wwv_flow_api.g_varchar2_table(4) := '32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE100000076744558747376673A626173652D7572690066696C653A2F2F2F43';
wwv_flow_api.g_varchar2_table(5) := '3A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6675726E69747572652E737667F8EC209E';
wwv_flow_api.g_varchar2_table(6) := '0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228343473456291004)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/furniture.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000A14944415418D3ADD1B16AC2001006E0CFCE2664ACAB4AE6161CEAEA283E445E21BBF8084287BE4ED1C70844E8DA499D441C';
wwv_flow_api.g_varchar2_table(3) := 'CE2131D452BAB477C3F1DF7FF7733FC77FC6DA4508F5CFF459FADB76DCC307B0500921686B657E1B193859EA5BB554180A278F0D5D0809D28E6424148DF8134A89B255DB19A9DB3EB69DE87D6EE8612F43EDBD3B78668CA30C3E8483FC8B9FDC41F86CC0';
wwv_flow_api.g_varchar2_table(4) := 'B357936FFE5FBC99FEF50557CB1B389E9332B0730000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D303954';
wwv_flow_api.g_varchar2_table(5) := '30383A35303A34302D30353A3030B3355DE100000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664';
wwv_flow_api.g_varchar2_table(6) := '646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F67616D696E672E737667C6DB39700000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228343894426291031)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/gaming.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000A84944415418D39590B10DC23010455FD801D18501B203A18645106320CA548802DA8C91291005054A4152A4800A2A1229FA';
wwv_flow_api.g_varchar2_table(3) := '1458D8B1DCF0A5D3F9EEDD59DF863F14D31087404902E4881C482887585C99D1237A522EC8C7E28D9C3C506B907E23008C0CCEE89CE18E2CECDDBBF4BB5D51B070BA4B0A6EB63C23C48E0811B1478893C55B636885589BF3C6E2090F84684C883B63D7C3';
wwv_flow_api.g_varchar2_table(4) := '9C97F3AC27A9EF79CA919A968A43F8DF03FA00839C4B29DAC84A000000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F646966790032303231';
wwv_flow_api.g_varchar2_table(5) := '2D30372D30395430383A35303A34302D30353A3030B3355DE100000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E30';
wwv_flow_api.g_varchar2_table(6) := '2D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F67617264656E2E7376676540E9850000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228344301496291057)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/garden.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000814944415418D3ADD1BB0DC2401084E14F0490404C0612127DB8160AA0225C09B678B5000D38730C041741606C4EA70B3D9B';
wwv_flow_api.g_varchar2_table(3) := 'ACF69F996419476B9597A3557C9C0C5BA9B67472C8A783296642AE36F80C9394976A8B24F250F4EBD39C247DF6EE0D957D820BAD8B7B87371ABB0817DA7F356C35114E606788D319DD7EF03AD217F005131A3A6C1F9B203B000000257445587464617465';
wwv_flow_api.g_varchar2_table(4) := '3A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE10000007A744558747376673A6261';
wwv_flow_api.g_varchar2_table(5) := '73652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F67';
wwv_flow_api.g_varchar2_table(6) := '617264656E2D63656E7472652E737667A5BA092F0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228344598676291084)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/garden-centre.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000834944415418D3A5CF3B0AC2601045E18F2008412DEC04D7A3D6EA226CDC4316905D889D58F8588660DC499A80011F85A051';
wwv_flow_api.g_varchar2_table(3) := '94FCE09D6ECEDC0303C4B60A47030C650A1BB16766F6DAA67213B9B1969D393440C7D5C5CAC8D2C25A53A4FB6AF71CDCDEE6A42F24D54E82A4BA89821461FA4FB91AF9FFB8FCC1CE0F9C7E3D28A5B54FDD01E081359ACEFF4E0F00000025744558746461';
wwv_flow_api.g_varchar2_table(4) := '74653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE100000071744558747376673A';
wwv_flow_api.g_varchar2_table(5) := '626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E73';
wwv_flow_api.g_varchar2_table(6) := '2F676966742E737667A1286CDF0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228345050497291111)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/gift.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000C44944415418D38DD0314B827114C5E187105C12215B1CC29C8290BE42BBBE536B2D7E07E75CB359701325F013182D413ABE';
wwv_flow_api.g_varchar2_table(3) := 'B6D41A94818BD5144AEBBFC5D0170D3C7087CB39F772EF8F2D94D597DD64EC809657DF222373239564A4606A57E4CD99B167E365208553F7E6EAAA864EF0E1D2EDD2CE9BE0C8B1A18107CC56979FEBE0D18F1288C4AB76D1545A2408829A77E5E471371A';
wwv_flow_api.g_varchar2_table(4) := 'A888CDC4CA24DFDCF3E45A7AD16534DD25E7F7B57DEABAD2F3A527B78EE8C085A0EAF07FBC6113D43FBD2C6A5BFD0229D830F5F81699010000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A3030';
wwv_flow_api.g_varchar2_table(5) := '26A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE100000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F';
wwv_flow_api.g_varchar2_table(6) := '446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F676C6F62652E7376675CB809B20000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228345394585291138)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/globe.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000B04944415418D38DCF314A036110C5F19F1B4FA085217642BC8527082421606B975BD82C16698247B01131459060EB157282';
wwv_flow_api.g_varchar2_table(3) := '1090146E11B070772B413E8B04B2FBE182AF1998FFCCBC37EC34F0AAA725D2F1BE5E2A95263E3DCA0EF8281A3F73A3EBCD8B9F3AB8534841C7DA6D6C930BBE30B4B5701AE354EEDE83D258839E04F36A23A9E10DFADA4DDBE7BE856AACFA63894C4BE1E2';
wwv_flow_api.g_varchar2_table(4) := 'EFED2BC15468F2BEB6B46A8A961879AE9FABE213CC7C78F75FFD02810E260BC6BD79C20000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F64';
wwv_flow_api.g_varchar2_table(5) := '69667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE100000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B';
wwv_flow_api.g_varchar2_table(6) := '692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F676F6C662E7376677943BE610000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228345709441291165)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/golf.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000844944415418D36360C00B987188AB33C431C8315CC52EA9CAF085E13FC3455C66E632FC67D082719633FCC7021918181818';
wwv_flow_api.g_varchar2_table(3) := '98181818B6E3779E28C35F5CBA21E0243EC31918B6E0375E98E128C33FDC86A38314866F10060B03030303831B832192243F431CC31E64D5EB508CFDC6B0894112D5B8E90CCF1944D058709733203906C55900AF704128031570AA000000257445587464';
wwv_flow_api.g_varchar2_table(4) := '6174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE10000007474455874737667';
wwv_flow_api.g_varchar2_table(5) := '3A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E';
wwv_flow_api.g_varchar2_table(6) := '732F67726F636572792E73766795E25D5B0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228346084295291193)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/grocery.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E380000009C4944415418D3A5D13F8E41611405F09FC4484422A195D051A80D4B60FA492C41C2022C4058935801AD7E8AF74D45220A53';
wwv_flow_api.g_varchar2_table(3) := '7F53082FBC9728DCF29E9C7BFE5CDE9B2F4130CAEC4B5AEA043D7DC90354347774322682A87207DBB6A2B5069C455174B252553071F167A6901EFBD0B570F16B23DAE9E499FCF6636AAFFC0CDCD821CB4EB59779DA2F9C079F0639B90FD7DC2389C430A7';
wwv_flow_api.g_varchar2_table(4) := 'B5A6DA7B0FF90729A935B205147B340000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A3530';
wwv_flow_api.g_varchar2_table(5) := '3A34302D30353A3030B3355DE100000078744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F';
wwv_flow_api.g_varchar2_table(6) := '6D6170626F782D6D616B692D666664646431312F69636F6E732F68616972647265737365722E73766718F07C670000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228346543680291221)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/hairdresser.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E38000000D24944415418D36DD0414A427110C7F10FCF6506891444ABF034058954507710AC6DADBC8677D04D418B56054110EF04BD5D';
wwv_flow_api.g_varchar2_table(3) := '94D9FE2184C8B4F9A70F756631C37C8799DF0C4BEBC895721D1BEC442CFC741DE7C28D2DB742BE8E4BA18E6DA1FC2F660B5CA0A7AE87F7AAA0768AF3B4799EC49D3B63EA570DB4154291DA6B66A6FC08BB69525FE8A77C4FF8CE8CD1DA70680BE3CC338E';
wwv_flow_api.g_varchar2_table(4) := '36E0633C6586E86AACC0A62E8699178F9A46762AB061A4E1C12B1CF814BE5C190803D7C6C287FDA58CBCF2F110DE1C5677D55CBA37313371E7227DC21FFD0C49A92D53E84C0000002574455874646174653A63726561746500323032312D30362D323254';
wwv_flow_api.g_varchar2_table(5) := '30393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE100000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55';
wwv_flow_api.g_varchar2_table(6) := '736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F686172626F722E737667F310DED7000000004945';
wwv_flow_api.g_varchar2_table(7) := '4E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228346927697291249)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/harbor.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E380000007D4944415418D395D1310AC2500C06E0CFD9C1CB0982E0EAE2A46710D1C1D623B45772D7555C6D67E3F2145A9F4293297CFC';
wwv_flow_api.g_varchar2_table(3) := '811006D6D25598E67125844D1E476E4295A6599F2742A8C1DAE33BDD0877B54A38F7B9109F7E9A77B14CD00A178BEEDA371E31EEAFDD272C72E79C1296B96B77BF93D0FE430E1ADBA1AF012FFF5C35D04D56340E0000002574455874646174653A637265';
wwv_flow_api.g_varchar2_table(4) := '61746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34302D30353A3030B3355DE100000075744558747376673A626173652D75';
wwv_flow_api.g_varchar2_table(5) := '72690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6861726477';
wwv_flow_api.g_varchar2_table(6) := '6172652E7376674F7034670000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228347250449291280)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/hardware.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322893A31E380000009E4944415418D385913D0AC2401484BFACBD51D45AF107CC6D042F215E49110F61211E4148A385A59A6411924A2FB016BBAE';
wwv_flow_api.g_varchar2_table(3) := 'BBC198996A187833C3835AB4585320D9D001BA6C91E4AC08011AC428C3133DCE561D1130B752A1B8796A2688BCA0BEA7A682FB9F560984BCBC835F3E75B96585BDD027020E3FCC3DC127A3E9CCD1BCD0764B8C908E99312CB79C901AF3511A6B30E05A6D';
wwv_flow_api.g_varchar2_table(4) := 'EA881DE3FA2759BC01DAE65D68655457EE0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A';
wwv_flow_api.g_varchar2_table(5) := '35303A34302D30353A3030B3355DE100000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431';
wwv_flow_api.g_varchar2_table(6) := '312F6D6170626F782D6D616B692D666664646431312F69636F6E732F68656172742E73766792271ABC0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228347624175291311)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/heart.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE0000009C4944415418D36360A006E862F88F01BB181818193818A219181996327C872AFCCFC088AC6F2DC366862D0CABA1BC5C86FF';
wwv_flow_api.g_varchar2_table(3) := '0CB9C8D29F19F818F8D18C7DC55002916461D8C9B01CD538065B862F0CEB1978181A18181818D819921852197620E9656060605060B80F9186003186A770691BB88212840247863F185E7BC70C977EC0F083C1152D34389991384719EE32C831883020C4';
wwv_flow_api.g_varchar2_table(4) := '8E5025C871010064113C6D3E28D1F00000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A3530';
wwv_flow_api.g_varchar2_table(5) := '3A34312D30353A30301542565500000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F';
wwv_flow_api.g_varchar2_table(6) := '6D6170626F782D6D616B692D666664646431312F69636F6E732F68656C69706F72742E73766730FBDD9F0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228348054747291339)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/heliport.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE000000764944415418D39590CD0D406010441F5183A8403F4E6AA0050E3A51848B567C374E1235302E7E8215B173D9E4CD2493819F';
wwv_flow_api.g_varchar2_table(3) := 'E75153E3BDE112210A1B26CC08B1905A78409B7A0B878C08311159B59A23DD3EEBE5071422BBE3EE823BBB7D45B5BF3EE036B77B3A03200664EFE47FAFEC2E854EB9CFE40AFE8039FF24BEF9960000002574455874646174653A63726561746500323032';
wwv_flow_api.g_varchar2_table(4) := '312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A3030154256550000007E744558747376673A626173652D7572690066696C65';
wwv_flow_api.g_varchar2_table(5) := '3A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F686967687761792D72657374';
wwv_flow_api.g_varchar2_table(6) := '2D617265612E73766754452B900000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228348290753291367)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/highway-rest-area.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE0000006D4944415418D395CFB10DC2400C05D097902262A46C918E3110A364127A241AC40699055D1399822B4874CAC177774FF6D9';
wwv_flow_api.g_varchar2_table(3) := 'FC91C16C004F8F2D8E5E42724288355E2C42088BF39A0FA64CDF9573742D60E83F7C2F62B8554F6960BB657E6B69F7BB2BDCED7FF5D3F05490A49E373DCF35EB70B53A6D0000002574455874646174653A63726561746500323032312D30362D32325430';
wwv_flow_api.g_varchar2_table(4) := '393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A30301542565500000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F5573';
wwv_flow_api.g_varchar2_table(5) := '6572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F686F6D652E7376672C9F05B80000000049454E44AE';
wwv_flow_api.g_varchar2_table(6) := '426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228348695571291396)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/home.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE000000AA4944415418D39DD12D6E82511085E127A40EC71EB02D0A8DC2E15904ECA10BA842A048BE5554A0493104040141F04D4D03';
wwv_flow_api.g_varchar2_table(3) := '021484A9E042F9F8A9E8193373DFCCB927F772A90F83DCAC909B0EC2FFB5B2FA0BC7D9FC59FF31AE5B0BADFBB86D6FE7D35E83371B3D0B21648A5E85D041D388AD8AAE483547F8563A194E481BC72A0BEDDFFBAA57380C3DE5236532A196E2BD5C277E57';
wwv_flow_api.g_varchar2_table(4) := '344EFDD7ED9B8F6C2DD3C9F416AF313BFFDA857E0092074143F72924A70000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F64696679003230';
wwv_flow_api.g_varchar2_table(5) := '32312D30372D30395430383A35303A34312D30353A30301542565500000079744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E30';
wwv_flow_api.g_varchar2_table(6) := '2E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F686F7273652D726964696E672E737667BB5672690000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228349152045291425)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/horse-riding.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE0000003D4944415418D3636020019C62F8CF700259801145FA3FBA18137EE328973EC5F01F0A612E80C0131067FCC7A99911A21B3B';
wwv_flow_api.g_varchar2_table(3) := '3831F01E4380531007110D00BBDE1255A9F0373E0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D303954';
wwv_flow_api.g_varchar2_table(4) := '30383A35303A34312D30353A30301542565500000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664';
wwv_flow_api.g_varchar2_table(5) := '646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F686F73706974616C2E737667D76DE5160000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228349534510291455)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/hospital.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE0000009B4944415418D3A5D0BD11016110C6F19F776840A080CB253239815001247AD083500B77150848888D44267E5B500083C039';
wwv_flow_api.g_varchar2_table(3) := 'AF8FEC76839DDDFF3ECFEC2C75A281AE85D60FB9983B3531362A475194C9CAEEE014102A4561A8A8BA90A2682726F5B5912873E4A9C31B6706B2A456F80E26B6A698DA9AF09C076C9CBF1CE06CFDF2685BBABA577993EB7CBEA1675FC2A3FEBF0F06332B';
wwv_flow_api.g_varchar2_table(4) := 'B3E4DC9AF1009419296CA6D2D01B0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A';
wwv_flow_api.g_varchar2_table(5) := '34312D30353A30301542565500000078744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D';
wwv_flow_api.g_varchar2_table(6) := '6170626F782D6D616B692D666664646431312F69636F6E732F686F73706974616C2D4A502E737667B1E461220000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228349770344291485)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/hospital-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE000000AC4944415418D395D0214B037118C0E1871593630B6230ECAE596C2B826EB030BFD060DFC232301C221866D568B6C9186BCE';
wwv_flow_api.g_varchar2_table(3) := '24BBE63896BC1D8C2B963F722782ECD79E37BCF0BEEC5564F0D778E8026752271587C6D60EF1E2B1E65026015B773587960A3DBC2A752B0E5D2ABCE15CE9B9E29F6E7D820779CDA02533024F6635837EB836B6725AF1AFFA3AFB7D1173D7DAA6BE4CB425';
wwv_flow_api.g_varchar2_table(4) := '72F78EDC58D0C050536A27C28703B18D77C7AEFE5DFC0D4D5C2FD2A8362CFD0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900';
wwv_flow_api.g_varchar2_table(5) := '323032312D30372D30395430383A35303A34312D30353A30301542565500000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D7637';
wwv_flow_api.g_varchar2_table(6) := '2E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F686F742D737072696E672E737667A2E27B180000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228350164494291516)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/hot-spring.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE0000009E4944415418D38DCE316A42611045E10F45AC442D042B6BB1B07311423A11D2BB876CC015B805F7A058889B10AD04B14A27';
wwv_flow_api.g_varchar2_table(3) := '58D82490B1C88FFAE43DF03477660E178607752B577315B97C09218C1EA7D27D6AE9A769A0F6DAEC3AA76E0827AD6CFB5313FC828E8FACDE81304BF9BF2B27BDF7ED626A96729DF77BC3585501133FC2D5305FF784F0A75DD43F08DBE74329A397D814EB';
wwv_flow_api.g_varchar2_table(4) := 'C5ABCE5275D4F03E3731552872068245F30000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A';
wwv_flow_api.g_varchar2_table(5) := '35303A34312D30353A30301542565500000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431';
wwv_flow_api.g_varchar2_table(6) := '312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6963652D637265616D2E7376674F54F47F0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228350649262291546)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/ice-cream.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE000000594944415418D3AD90310E40501044DF8A938892DEFD6F212151E99C617E337E044130CD4BF64DB1BBF03242505C77FED11D';
wwv_flow_api.g_varchar2_table(3) := 'A3391C4B0D0B025A33AF06503123446DEE748F106232373A200FD68435C4CDE6E5E9BF9EDEFD2D09C7271F24F4D82F0C0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380000000';
wwv_flow_api.g_varchar2_table(4) := '2574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A30301542565500000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F61';
wwv_flow_api.g_varchar2_table(5) := '64732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F696E6475737472792E737667C29AEC430000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228350930529291578)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/industry.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE000000544944415418D36360200134337C6668C42DFD89E13FC34764016614690E0623867E8603A4580805FFA1701F766949867550';
wwv_flow_api.g_varchar2_table(3) := '05388028A634239A0568624CF81D842C2D8A46E370DA3A06494CBB515DCCC840050000FCA518B19C07E6D60000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874';
wwv_flow_api.g_varchar2_table(4) := '646174653A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A30301542565500000078744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D61';
wwv_flow_api.g_varchar2_table(5) := '70626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F696E666F726D6174696F6E2E73766742B23CC30000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228351342076291611)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/information.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE000000984944415418D39DCF3B0A83401485E11F9B284C65ED02623A2D5C460A37621F02C61569F0D18B8C5B48C032640D926A52C4';
wwv_flow_api.g_varchar2_table(3) := 'C08C4E1172AA397CCCE55EF839290A8522B5B35C58DAD9A743D1E1DBD02523E04840C66E8D1E0315211072A5C735F94C89B3BC1D2A4E26DF89B41673337946684D307F077DF264AFF18187F9BBA0D65A4BBEDE7CA4214190D022F1B6A75D987831916FF1';
wwv_flow_api.g_varchar2_table(4) := 'BFBC0122FF21A6FDCA63060000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34312D';
wwv_flow_api.g_varchar2_table(5) := '30353A3030154256550000007A744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D617062';
wwv_flow_api.g_varchar2_table(6) := '6F782D6D616B692D666664646431312F69636F6E732F6A6577656C72792D73746F72652E7376675C56544B0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228351676842291643)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/jewelry-store.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE0000008B4944415418D3ADCF310E017114C4E18F159C003771196710A582623B3A94EB00C4059C4050AB340AAA2DB42AC95F6123B1';
wwv_flow_api.g_varchar2_table(3) := 'BB1DF39A97FCDE4CE6F14F4562176743D5323C15B21995E1FB07DF508888856CABE771C5C4D1203BD87CFB2A164E525D7D0F89661E1EB4EC2588F2CEB954DBD64AADD8772C08AED679F8AED6013B3DCFB26F1B966665B1BFE9055D6E244338ABD7BA0000';
wwv_flow_api.g_varchar2_table(4) := '002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A30301542565500000074';
wwv_flow_api.g_varchar2_table(5) := '744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D6666646464';
wwv_flow_api.g_varchar2_table(6) := '31312F69636F6E732F6B6172616F6B652E737667697221B20000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228352042102291676)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/karaoke.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE000000504944415418D3BD8FC109803000030F27EB44BA5F777185FC0B4A7CD956AA855230817C2E040243DA7B70C3ACDFF0C41C6D';
wwv_flow_api.g_varchar2_table(3) := '212212CE4E885870A8D0EDF05C7093C0D23FF20B16609C5375492FC7C4B42E40D22DF59633E48D0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380000000257445587464617465';
wwv_flow_api.g_varchar2_table(4) := '3A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A30301542565500000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F78';
wwv_flow_api.g_varchar2_table(5) := '2D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6C616E646D61726B2E73766723AFFDFC0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228352414110291709)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/landmark.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE0000005C4944415418D3A58FB10D80300C044F21CC43C806B00563B0352320A7086512631788EFCE6F4B67F89369A0CCC1CD65AF66';
wwv_flow_api.g_varchar2_table(3) := '0A1521B551E8EA8D08CCECF6F58A501116CF2471FAA56BAE8D07D6C61D07C358B1367E7DA08DBF7EE0E401C0971F5BE57C9E770000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380';
wwv_flow_api.g_varchar2_table(4) := '0000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A30301542565500000078744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E';
wwv_flow_api.g_varchar2_table(5) := '6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6C616E646D61726B2D4A502E737667E2E00F650000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228352769840291741)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/landmark-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE0000007D4944415418D395CEBD0DC2400C86E12774CC934128E85824124CC14EAC40C31EC812454C412E770A8904B62CCB7EFDF3F1';
wwv_flow_api.g_varchar2_table(3) := 'A3F56EFA2D78F494C2690D9E8D524AA34B0B3A90BE7B60B7F12C442D3E876B7E495907622A4ACEF2B25B3D5DB474F098020E0DCE3A9BD8BBCEA0A8401AA4C17D6E2DB65BB7541E0D0CFFD81B026345864B0C42830000002574455874646174653A637265';
wwv_flow_api.g_varchar2_table(4) := '61746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A30301542565500000074744558747376673A626173652D75';
wwv_flow_api.g_varchar2_table(5) := '72690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6C616E6475';
wwv_flow_api.g_varchar2_table(6) := '73652E7376676E76C8460000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228353122056291773)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/landuse.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE0000006B4944415418D3958FB11580200C443FD6360CC1142CE74C3A023432082D23C4060195A77269925C2EB9C010162487EB9306';
wwv_flow_api.g_varchar2_table(3) := '300852DBAE68DA0014403BD940C1F46EA5A50396194BB80F094244E74A13CFDB55BD927296D89ECBD5D5D4AFE59516F6626DEC6FDF213DDF3800A8B43092DFE65E320000002574455874646174653A63726561746500323032312D30362D32325430393A';
wwv_flow_api.g_varchar2_table(4) := '33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A30301542565500000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572';
wwv_flow_api.g_varchar2_table(5) := '732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6C61756E6472792E7376677EC6367E0000000049454E44';
wwv_flow_api.g_varchar2_table(6) := 'AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228353505168291806)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/laundry.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E50709083229E4A42EAE000000B64944415418D3A5D1A16A427114C7F18F62D0E81DDE15F350D0B43B1F4356048D3E802CD9F7024BBE83C1E2300D315B6610';
wwv_flow_api.g_varchar2_table(3) := '41DC130873616D0B86BBF0BF4687E0493FF89E737EFCCEE19ACA81485BCDD1C8416CA0E0C3CC7768E9F9954AA5DEB1CAF48F0E79B414B35D09EE335DF21070E58CF16DC0F1191C5F842BFFE34F434D91AA3EFAAA224D435FA7DC89B6C4DE8B9DBA27655B';
wwv_flow_api.g_varchar2_table(4) := 'AF36617A6AAC68E1CED2B3A586B5C8CC24783CCA67B79B5B7B73030ABA57FD037FC0DA25CF6EEA9C410000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A9438000000025744558746461';
wwv_flow_api.g_varchar2_table(5) := '74653A6D6F6469667900323032312D30372D30395430383A35303A34312D30353A30301542565500000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D617062';
wwv_flow_api.g_varchar2_table(6) := '6F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6C6962726172792E737667DC9C52F10000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228353929057291838)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/library.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000AC4944415418D38DD0314E024114C6F1DF6E83D810AC2C28B5918EC240B3816AC3256C380057F04E1EC0C4989858505AE821';
wwv_flow_api.g_varchar2_table(3) := 'A081483514B0CBCC54FBBD66DEFBBEF9CFCBD0E8CE8B37FF3EADDDCBD4B713DADABA698C95B1B28D85F6541A5B1546669EF0E11D4181850A3FBEF24742DA9EB103B569349DAA0DA0F08AAD6F1BC716DE33F16C18731EA3CD1F52382CA3E8B2A37DFD967D';
wwv_flow_api.g_varchar2_table(4) := '043FB84D6FCF9BC1255CA5768ECBFABF081D04BFBAE8043A423066D1AA73C40000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900';
wwv_flow_api.g_varchar2_table(5) := '323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D7637';
wwv_flow_api.g_varchar2_table(6) := '2E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6C69676874686F7573652E737667B0BECA0A0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228354194174291870)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/lighthouse.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000CD4944415418D395D02B4E036114C5F1DF37348328E000D549103C14B22414C974116C81608A6A133C9E0D90542051083630';
wwv_flow_api.g_varchar2_table(3) := 'E91220690DAEC1812BA41F62A6E923981E736FCE3FF791C35A1AFD6706075517AB9AA99500B6BDEB3AD596089E0CF4357DCCE75B267A526CEAF99197F646856FBCB877E9DAAF47A92D83C5EB6F5217A6A2A9965D456927188912134D01C1994F27A2E1E2';
wwv_flow_api.g_varchar2_table(4) := 'F48E63DFA22F871ACBABB9F380CC9586E0596719B7457D47EACEBD8AB3CF67218CE56E15A242476E6C6F8E6BB295D4F6ABC05634B48EFE003F6D2EF3D28706C00000002574455874646174653A63726561746500323032312D30362D32325430393A3333';
wwv_flow_api.g_varchar2_table(5) := '3A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC80000007A744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F';
wwv_flow_api.g_varchar2_table(6) := '42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6C69676874686F7573652D4A502E737667A91E805200000000';
wwv_flow_api.g_varchar2_table(7) := '49454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228354603398291903)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/lighthouse-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F140000005E4944415418D3A5CFB10980301046E16766B17227F7B04C70326B4790ACA0184B85B33811217811FC5FF971C5C1BFB5360B';
wwv_flow_api.g_varchar2_table(3) := 'D0B311DE3921ACD44CC8DDC140A31C4878BA076AA3B2CE67BC2BCF195CB9D263626165F2625F8B231A6CD9879DE6A43A40224C8B9B0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A9';
wwv_flow_api.g_varchar2_table(4) := '43800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F';
wwv_flow_api.g_varchar2_table(5) := '776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6C6F6467696E672E7376670EE8C1170000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228355050445291935)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/lodging.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F140000008B4944415418D395D03D0E01011086E187A8362AADB07A77A0700A5A277003D7D0B88166A9D94EA256FA39010EA0180D092B';
wwv_flow_api.g_varchar2_table(3) := '2BF195DF3BEF4C32FC4CA5A45F6ABA19544B6062A25E666EF4E5B2BF61F60BAEACF5E416EFE545D86B193D61C10CCC1CB4A572CBE2CAC054384A0DBF2FDE759D8570967EA21AB67692F22F761C85702ABAAFE986B13077F55F1E9E382AF9B24CFB2F0000';
wwv_flow_api.g_varchar2_table(4) := '002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000074';
wwv_flow_api.g_varchar2_table(5) := '744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D6666646464';
wwv_flow_api.g_varchar2_table(6) := '31312F69636F6E732F6C6F6767696E672E7376673765FDD20000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228355321627291967)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/logging.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000974944415418D375D0310AC23014C6F13F0E5605F104D24D10EBD43B747116E79EA9938B832E420FA34728D82B582885A44B';
wwv_flow_api.g_varchar2_table(3) := 'F53D5FE39725E4175E3E029FECB951E3A8B9B2C3E4448BFFAE96A3C69846A1C7F3660D300120676EA62DC88553C64985A7018E841F017ECA36C1996A8E44DF2D0D97BFA336740A3BB6F6ADB3E2625C65C56BC08A65A02A87A154C69F5CC283E52BEFCCF4';
wwv_flow_api.g_varchar2_table(4) := '410F013A426277812B130000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30';
wwv_flow_api.g_varchar2_table(5) := '353A303024AA4CC800000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D666664646431312F69636F6E732F6D61726B65722E737667213A73260000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228355663704292002)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/marker.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000C24944415418D375D0B14A82611487F11F1A82BA24B53804CD2A850E4934B94B937B9B8B5D4177D0D01DD4100D817501E2D6';
wwv_flow_api.g_varchar2_table(3) := 'DA525BD060CB077E41DD8160439FFAF66ACF74FEE7399C038705871E7C99FB74AF2EA267AAAF821D03A96E28F74DD582DC94AA421E5C78360C74AAAAE1891C38328E8E8DB559E89C59A467B656FAD549A48FBDAC42DBFBEF7446C144239C1E390BD2B9C7';
wwv_flow_api.g_varchar2_table(4) := 'BFCB5A264A59BD2D71103FE6CE6556DDBAB2C6AE4413A73E946DA0E7CD9E44C73F5CFB5E9ED840D18D42D8F801D44324952B754B170000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A9';
wwv_flow_api.g_varchar2_table(5) := '43800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC80000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F';
wwv_flow_api.g_varchar2_table(6) := '776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6D61726B65722D7374726F6B65642E73766743DF98610000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228356079499292034)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/marker-stroked.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000484944415418D363602019DCC2267894E13F1C1EC694FECF2004650933FCC7268D85CD84DF19C8D2C268340303032356C3E1';
wwv_flow_api.g_varchar2_table(3) := 'E24C68428C285A06543742FA08C37FA8195803152B0000D21413417F9341330000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900';
wwv_flow_api.g_varchar2_table(4) := '323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000079744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D7637';
wwv_flow_api.g_varchar2_table(5) := '2E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6D6F62696C652D70686F6E652E737667DE04CB2E0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228356401133292067)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/mobile-phone.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000514944415418D3636040064C0C5319981870827486FF0C69B8A5DF30FC6778832CC08822FD1F5D0C8F4D032DCD82C2EBC4A5';
wwv_flow_api.g_varchar2_table(3) := '4C8EE12EC37F387CC8A0842A7D1F49F23FC37F86FBA8C1F21FC33C46CA5D0E00E6C4178A8B7EAEFC0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174';
wwv_flow_api.g_varchar2_table(4) := '653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F';
wwv_flow_api.g_varchar2_table(5) := '782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6D6F6E756D656E742E737667332C2A070000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228356789614292104)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/monument.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F140000005A4944415418D3CDD0310A80301044D18F55FA1CCC52BC4BCEA68D1030779134691D0B514222924670B619785B2C0B8D1908';
wwv_flow_api.g_varchar2_table(3) := '24129EBEC611DDB3D70B2BC261B138C452724418000C622B59E8A977EFF7FE85AFB79C7DCA79E6831C93781DDC666738F50000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000';
wwv_flow_api.g_varchar2_table(4) := '002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000078744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F';
wwv_flow_api.g_varchar2_table(5) := '6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6D6F6E756D656E742D4A502E737667E1B912060000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228357162871292149)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/monument-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000914944415418D3ADD1B10A41011406E08F78010965B3CB24360383C790CD6631F31C66C5EE113C80CD24A34129A50C946B71';
wwv_flow_api.g_varchar2_table(3) := 'B9B826CE594EE7ABD35F87FF55D95623BA48BCCC0B5957159770958C70574E4D4A3FEE70C64E0B6D47C54F1E9BDCA7B9D93BD6EDE555515572D28C62CA52CFC859C7D9C8D04AFAC97DC1470F422C38C4F023E0340603411870F385D7BF3EE1062537416F';
wwv_flow_api.g_varchar2_table(4) := 'C0593E810000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA';
wwv_flow_api.g_varchar2_table(5) := '4CC800000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B69';
wwv_flow_api.g_varchar2_table(6) := '2D666664646431312F69636F6E732F6D6F756E7461696E2E73766762193D3C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228357488923292192)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/mountain.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F140000006D4944415418D3A58EB109803010455F546C5CCB5E9B4C20B8821B39496AC1CACE22388670163118A2C122EFC3BFE21DC795';
wwv_flow_api.g_varchar2_table(3) := '3CD40CCC342C9C4414687604413818A942D9B2DECA6743A39C3491F231FCE10E48CA15D162D884FA937CDD275CE7864510A6575BF7A3246F2BB2B800FD9D2BEF39D655590000002574455874646174653A63726561746500323032312D30362D32325430';
wwv_flow_api.g_varchar2_table(4) := '393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F5573';
wwv_flow_api.g_varchar2_table(5) := '6572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6D757365756D2E737667ADE519500000000049454E';
wwv_flow_api.g_varchar2_table(6) := '44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228357862442292227)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/museum.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000984944415418D3958D3112C15014454F8699A8D56C000BD09BC9672C418515682C2A439FAC40F6A04B544A697457E1E7CF0B';
wwv_flow_api.g_varchar2_table(3) := 'C670ABF7EE79F73EF8AAE8A33BC1913066D0C67D66381C377272321BDE73E24ACA96A1776493624AC7CF237664C8FE16912F4FA8DFCBF57B79C05DB31661EAB1E2CEEB6DD011A1C65972E1DCC235424DBEB2B7001C1022B5B8343866C39AF8B92CA82899';
wwv_flow_api.g_varchar2_table(4) := 'F3BF1E018E34D2952616EB0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D';
wwv_flow_api.g_varchar2_table(5) := '30353A303024AA4CC800000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D617062';
wwv_flow_api.g_varchar2_table(6) := '6F782D6D616B692D666664646431312F69636F6E732F6D757369632E737667EF9B5AF50000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228358322825292273)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/music.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000AC4944415418D395D03B6A42511006E0CF58D878D12558DB8849638210DC43700B76B6762A248595904D5CB008689D22E905';
wwv_flow_api.g_varchar2_table(3) := 'B76070218ECD410E3E8AFCD5CCFC8F61864B34DC41E159D35ED38BE29A7EB0B315B60EAAB7FC3321848FDBF15D211C752E89BA95029FC2F2DA570A252A7A2A18E7E430ED7C4BFDC0DE6B2E980B8B73B7D1F28574C0BB29FAEABE3150B3D6C61F4C527408';
wwv_flow_api.g_varchar2_table(4) := '13FCA4FA378F0E618EA74CFC08A36C30BAF7F1F07F9C00D1903A33A5A2530F0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900';
wwv_flow_api.g_varchar2_table(5) := '323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D7637';
wwv_flow_api.g_varchar2_table(6) := '2E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6E61747572616C2E737667394C77B20000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228358566338292304)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/natural.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000AE4944415418D385CFBD6D024114C4F11F1F255C620182D0B21C9039B9D0944015480EE142323762174025071676E6068848';
wwv_flow_api.g_varchar2_table(3) := '0820790E38D07260319BCC9BFFCED32EA9326F32FFAA108A5B6068662B84B035333CC6ED0AE726DECF97277696697B64934C1BAF97CB7BD5E2D3E95EE286AF04AE34AE9F17E6988BB495E2ABB4798E5EB0505854BEA64FE1098FC2471D3ED85B57FEDB41';
wwv_flow_api.g_varchar2_table(4) := 'E7685B606CEAD9AF4C2E37D037107E4EDDB2F6EB104AF7F50718023920953B5F400000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F646966';
wwv_flow_api.g_varchar2_table(5) := '7900323032312D30372D30395430383A35303A34322D30353A303024AA4CC80000007E744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D';
wwv_flow_api.g_varchar2_table(6) := '76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6F62736572766174696F6E2D746F7765722E737667CC0E707D0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228359031383292333)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/observation-tower.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000534944415418D3CDC7B10D40001000C04BA85844CC62064A22F6D3E918C2084AA150BD4E221670DDF16B8D4D08BB169D5D08';
wwv_flow_api.g_varchar2_table(3) := '9B1A56A104A5C3E8781656B8242075A95E038B5E2637983F4361723A4D8ACFFEEB06701620D071F80BFA0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380000000257445587464';
wwv_flow_api.g_varchar2_table(4) := '6174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170';
wwv_flow_api.g_varchar2_table(5) := '626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F6F7074696369616E2E737667914D61610000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228359348368292366)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/optician.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F140000006F4944415418D3858FBB0D803010439F227AC40630044D60201A949692299801B1022D2593046586A34A11C8C7EEEEC9B20F';
wwv_flow_api.g_varchar2_table(3) := '8A7248C4B3C712F5C994C317020A70D1CABDB449A04AA01A0D7FDC31A01969B959BE1983E5C0D0FB58986ED858D3632C36BF55C283CAFF16763FDF74412F04E532D6B48A212B0000002574455874646174653A63726561746500323032312D30362D3232';
wwv_flow_api.g_varchar2_table(4) := '5430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F';
wwv_flow_api.g_varchar2_table(5) := '55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7061696E742E737667468E78A8000000004945';
wwv_flow_api.g_varchar2_table(6) := '4E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228359676626292403)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/paint.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000A34944415418D395CF216E02011005D01740F6043D432D4172022EB069EA8A45D6908003C5093055ADEC11908443100C2405';
wwv_flow_api.g_varchar2_table(3) := '41022108960E6AE99205D2CE98C97F3362F8577D9A79BA4EEF664258D8A85D52DF4EE43AF591E7ED0586F0E335C38EB4C0E13BE3752E3C9CA7116550515772B0F2A06BACA62C55B5CFEEDF2CB52542135F8E06C5D712A1A5E759E9DAE78930F1F81B14B7';
wwv_flow_api.g_varchar2_table(4) := '8616F7F866354C85B9973F5F9C00B399473F985DFD3B0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30';
wwv_flow_api.g_varchar2_table(5) := '395430383A35303A34322D30353A303024AA4CC800000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D6766';
wwv_flow_api.g_varchar2_table(6) := '6664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7061726B2E7376679E4E5A540000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228360124927292440)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/park.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322A7DAD7F14000000744944415418D395D1B10980400C85E11F74010770091B0BDD47C1012CB57401D1252CAD9C49CE0D6213E4F072A069BFBCF0';
wwv_flow_api.g_varchar2_table(3) := '20F0633236B21826EC0807A9CD0382200CB1FC8CB0C6B0D7F46461A32808ADB55029D616169CCA17E51B739C77DC9187F945D1EC3E7AE9A07BE761B43BC897D73C7303279135F7726A1E2F0000002574455874646174653A63726561746500323032312D';
wwv_flow_api.g_varchar2_table(4) := '30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34322D30353A303024AA4CC800000076744558747376673A626173652D7572690066696C653A2F';
wwv_flow_api.g_varchar2_table(5) := '2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7061726B2D616C74312E7376675B';
wwv_flow_api.g_varchar2_table(6) := '907A110000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228360433760292480)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/park-alt1.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F820000007E4944415418D3ADCF3B0AC2601045E1CFD792EC6C8414820B72092EC02E2B71011666055A6A2D064110A2C2D8A408497EB4';
wwv_flow_api.g_varchar2_table(3) := 'F04E337086E15C7E4A34E6616B96C621BCCDDBF8289359CA85B06BE3A2DE070E4205C35E8F1B2629BC30C5B9FDFCA554BAD772ABB479656304E3C6C9C91A4F577B976EEFA2ABD1A7F637FC251F2AD53AA2484607E00000002574455874646174653A6372';
wwv_flow_api.g_varchar2_table(4) := '6561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000074744558747376673A626173652D';
wwv_flow_api.g_varchar2_table(5) := '7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7061726B';
wwv_flow_api.g_varchar2_table(6) := '696E672E7376673CB8891C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228360782336292518)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/parking.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F82000000BA4944415418D385CFB14AC27114C5F18F1A5860108DE2D664823E40810FD0F0A74710A4D557E8055AFFA3383BB438894E0E';
wwv_flow_api.g_varchar2_table(3) := '0D4D8D22381444100EE26290F07348C97FFEC9EF76EF39E71E6ECE2E250DEF1652A8E898E99A692B27A56B5D1FEE9DE354CB9B9EAB1FA9E6C9C49DE31D7B5ED3D84899AA5BD994B2ACC8E5EF180B82E0CBB3FA76799448F4BD2ABAF1E8C23C792C16441B';
wwv_flow_api.g_varchar2_table(4) := '53D8E6F75B33CEF0FD771D0B5E0C4C04532769DD052B9F861E2CD3D2D1FE77FF72403EC01AAD4F2ABCEB1952B60000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380000000257445';
wwv_flow_api.g_varchar2_table(5) := '5874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C0000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F';
wwv_flow_api.g_varchar2_table(6) := '6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7061726B696E672D6761726167652E73766700B19B7D0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228361187969292576)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/parking-garage.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F820000007E4944415418D36360C004360C5F18D633E0004C0CEB19FE33BCC0253D95E13FC34A067DEC92ED0CFF19AE307030100718A1';
wwv_flow_api.g_varchar2_table(3) := 'F47FEC324C50CE4934C9DB307742C06434D3B6A3AA666578C2F09FE13F0303C37F86FF0CFF193CD0ED9A8DC4FECF20842AC9C6F01C9B6E98DD610C1228CA3D51759F84EA82C15B44F99B000000C68E25988BCCC3660000002574455874646174653A6372';
wwv_flow_api.g_varchar2_table(4) := '6561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000075744558747376673A626173652D';
wwv_flow_api.g_varchar2_table(5) := '7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F70686172';
wwv_flow_api.g_varchar2_table(6) := '6D6163792E737667AD8B16AE0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228361552734292618)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/pharmacy.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F820000007B4944415418D36360A00338CAF01F051E81083341A5FFA329FF8F69C21D862D0C0C0C5B19EE6133DE80E13F431203034332';
wwv_flow_api.g_varchar2_table(3) := 'C37F060364091F861F6836FF67F8CFF083C11B62F77F06EC00495C8DE13F430E949DCBF09F411D556515C33F0659285B9AE11F4305AAF419866348BCE30CA7D0FD3D1B497A1675C21A00034129EADA4C91BB0000002574455874646174653A6372656174';
wwv_flow_api.g_varchar2_table(4) := '6500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000078744558747376673A626173652D757269';
wwv_flow_api.g_varchar2_table(5) := '0066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7069636E69632D';
wwv_flow_api.g_varchar2_table(6) := '736974652E7376672C59A8200000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228361888515292656)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/picnic-site.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F820000007B4944415418D395D0B10902511084E10FAB30B0021B303130B50143DB307DD5588289C1056209229CA10D588163201C87F7';
wwv_flow_api.g_varchar2_table(3) := '9473A2657F76761846EAEC345C4EBAE929639DAA5A3A8AB8D8997EC22222D616F6EE7DD48A281A71F86EBF1231AF257F63D8D46F8B87ADC6B58E63D63D8876887FB456551FDFFE2EF205B31C20A7CC12EB7A0000002574455874646174653A6372656174';
wwv_flow_api.g_varchar2_table(4) := '6500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000072744558747376673A626173652D757269';
wwv_flow_api.g_varchar2_table(5) := '0066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F70697463682E73';
wwv_flow_api.g_varchar2_table(6) := '76678AECF74E0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228362221270292694)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/pitch.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F820000006E4944415418D3B5CEBB0D02510C44D1634440152FD87AB60602AA2024A4A1CDE9031120D1036426E023231E22405C2796EF';
wwv_flow_api.g_varchar2_table(3) := '8C642ACDCEE003CD413AD6C0ACE89501CDB2AF3BCCCBBEB706A75E70239FB3ADED519A9CEFDD07A334052E58C81719B76B20116F3A115F3EFFABFE8D2BAFFE18BD8D7444730000002574455874646174653A63726561746500323032312D30362D323254';
wwv_flow_api.g_varchar2_table(4) := '30393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C0000007D744558747376673A626173652D7572690066696C653A2F2F2F433A2F55';
wwv_flow_api.g_varchar2_table(5) := '736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F706C6163652D6F662D776F72736869702E737667';
wwv_flow_api.g_varchar2_table(6) := '14C6CE9A0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228362639932292733)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/place-of-worship.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F82000000C54944415418D38DD0BF4A42011886F15F624D0DAE6108DA525B218144844BD0D8D80584D0DC1D044D5D814B5711B436B41E';
wwv_flow_api.g_varchar2_table(3) := '4327C788902070100E1127FD1A3B9D13E4BB3E3CEFF707B8F1EE127494523517267FE10ABEF465FA9648C15E01BB8E6CAA6B6899D9293A33219C3B746AB5389B57F0E2D19BAC8C1F40176B3A2EECFF2E3F13C2C4C0A710A66A79BC61218430373414AEF2';
wwv_flow_api.g_varchar2_table(4) := '9BD3D33432D270AF65EC43D3B47CF731B815AEF3F6BA3D6D6D0732DBB68CA56A3FF8592A91483C4971A2EAEEDF1F7F03F79B3873540230740000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A30';
wwv_flow_api.g_varchar2_table(5) := '3026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D4346';
wwv_flow_api.g_varchar2_table(6) := '2F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F706C617967726F756E642E73766716CCA0420000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228362863620292773)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/playground.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F820000009B4944415418D36360201A3830FC8743078810238A827238AB139BF43F28FF3F03134480898181E124C371A8F47D341AAAF6';
wwv_flow_api.g_varchar2_table(3) := '3F94950FB5391F26C5C8C0C0F01FC912570603860B0CBBD17547314C6438C1F013AABB9E8107551A19AE641066388B903ECCF0926103433954F204031FC37EB86BD02C79C020CE3013C9B128D29F18F4182AA0A660803F0CBE0C410C7F7149E73098307C';
wwv_flow_api.g_varchar2_table(4) := '853B90180000E68445051100E0A10000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A';
wwv_flow_api.g_varchar2_table(5) := '34332D30353A303082DD477C00000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D';
wwv_flow_api.g_varchar2_table(6) := '6170626F782D6D616B692D666664646431312F69636F6E732F706F6C6963652E737667C19F38530000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228363292559292813)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/police.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F82000000B44944415418D38DD1414EC2601086E187860D9CA4BD02A0D7936A020B53B98082DEC3B8EC250A77B0D1765CFC3558A30933';
wwv_flow_api.g_varchar2_table(3) := '8BC997772633F9860BE3CAB393D6D1C16A8CA676629495E919EF844E2937932B7542F50DAF854ED80C7A33E865922FC2DA8DB065A8B7C23EE19390632BD443532E1C136E8519266AA136C15C78FF7FBA109A840F42693DDA7D273C26BCFAF3F2DE820CAF';
wwv_flow_api.g_varchar2_table(4) := '1E647A1F0A73854FBD4CE5EDEC5AF5CBB5FB9FAEC1D25EA3D578B2B8F04F5FCA515DBDD9DC14C30000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380000000257445587464617465';
wwv_flow_api.g_varchar2_table(5) := '3A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F78';
wwv_flow_api.g_varchar2_table(6) := '2D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F706F6C6963652D4A502E737667A090067D0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228363727597292851)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/police-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F82000000834944415418D3B5D0310AC2401005D0973D8742B013BC8E4D0A4B0F2082D70A682988A857B0B0142DB510ACC72209A68836';
wwv_flow_api.g_varchar2_table(3) := 'E29F6AE7CD4CB1FC3927D159E78A07D61D78306CF63313B7163D2DA406AFE6929E658D2B7DC9CCA5E210B672148E0AE43642BC393C4CEB6B63F7BAD7E2104A2365EB2DA399EA48967C4DC2FE83ED7EFDEF17B8AA44630341839A00000025744558746461';
wwv_flow_api.g_varchar2_table(4) := '74653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000071744558747376673A';
wwv_flow_api.g_varchar2_table(5) := '626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E73';
wwv_flow_api.g_varchar2_table(6) := '2F706F73742E737667E79DF2FF0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228364020120292895)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/post.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F820000006C4944415418D3ADD1BB1182001084E14F3472C828473BD02628412AA012467B81447B217008489C33E5E12380FFB2DBD9BD';
wwv_flow_api.g_varchar2_table(3) := '9B599672D68BD9F44E24882FB6F81BBC4126B79D292F95168A0F9743B8B0C3D55E0A8E0E1A35E8DCA681A5500E17C9EFD7D6941F9EEE4B0A18F306E3962535DCE23DDC0000002574455874646174653A63726561746500323032312D30362D3232543039';
wwv_flow_api.g_varchar2_table(4) := '3A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F557365';
wwv_flow_api.g_varchar2_table(5) := '72732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F706F73742D4A502E737667AFE9FCB70000000049454E';
wwv_flow_api.g_varchar2_table(6) := '44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228364394104292941)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/post-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F82000000724944415418D38DD0B111C2300C05D0E71C136404AAB4D40C96161AEE52668D0CC50A6E53C5542690F3D9911A495FD2FF12';
wwv_flow_api.g_varchar2_table(3) := 'A7EC211D1C74DF86498FDEE429E4E20EAF22A2F5776957E72CC177630E2F0578106BCA17B7AC7C87675749F02A1F16BD412A1F96F3ADA63CFCB336A61B3F6FD807C5312BAD7580BF520000002574455874646174653A63726561746500323032312D3036';
wwv_flow_api.g_varchar2_table(4) := '2D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000073744558747376673A626173652D7572690066696C653A2F2F2F';
wwv_flow_api.g_varchar2_table(5) := '433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F707269736F6E2E737667174CA1FB0000';
wwv_flow_api.g_varchar2_table(6) := '000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228364725063292988)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/prison.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F82000000D64944415418D38DD12F4B43011405F09FF3CF10B5E81B0AF685F740D12AD80C468BCD34143FC1EA50EB3E8069554483C1A2';
wwv_flow_api.g_varchar2_table(3) := 'A0556120189C3811C6923683280BBE6770F21E63C84E39700FF79E73EF65208C69F42BE7BA5C346DC578AF3CD2E5C89DBC9AB623C3421DF79ED2EE50DDB58EB26D33D61DBBCD0E0FED3897F876E2528076D6A42191289877A66EC1A2C36CEE4F91925593';
wwv_flow_api.g_varchar2_table(4) := '625F72F20ED268452D0FA6DCB8B066D49B57D5548EC4F62DE1DD950D81401386C01E2A26EC5AF622366BCE968F3FEF539BFF9DF451D45FF8DD3BF63CD86B7AF00306062FE5D5C4F7BB0000002574455874646174653A63726561746500323032312D3036';
wwv_flow_api.g_varchar2_table(5) := '2D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C00000076744558747376673A626173652D7572690066696C653A2F2F2F';
wwv_flow_api.g_varchar2_table(6) := '433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72616365747261636B2E7376676B1FA1';
wwv_flow_api.g_varchar2_table(7) := '8E0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228365056922293026)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/racetrack.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F82000000C54944415418D3ADCF314B42711405F05F45860EAD41D62208B908AD2DB6F6011A5D0C1C1217415C9B1B6AF32B343404D15A';
wwv_flow_api.g_varchar2_table(3) := '0911418B6F319A0B696C6DD1BF83FA7CBE8696EE5DCEB9E79EC3BDFC573D7B4A8F5613782CA4E595186D0BBE405FA46BACAEB7587C34F2A2634FC55010FCD89A8B87C2AF3E4B7AD3E2ADB5A954D113BC3955901509462EACCF9DC7DE35637AA4A12023BF';
wwv_flow_api.g_varchar2_table(4) := 'F4954D35D5196EFB3634509ED20D2D9FAE7CD8C7B9073B38508492C8B55D5CBA71E75E2E19FB1A8766B59C2C8EFAB326E4A53D2E199E0F600000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A30';
wwv_flow_api.g_varchar2_table(5) := '3026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C0000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D4346';
wwv_flow_api.g_varchar2_table(6) := '2F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72616365747261636B2D626F61742E737667B168845F0000000049454E44AE4260';
wwv_flow_api.g_varchar2_table(7) := '82';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228365523228293066)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/racetrack-boat.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F82000000AE4944415418D39DCF2172C2501485E10FE8C421A22183ACC7D5BD1DB0806AF6814BB30A3412138DE8E0DA2554309366AA4B';
wwv_flow_api.g_varchar2_table(3) := '1C330F416821C5D02BFF7FEE3DE772E72C4451F4E191C11FBDD11390DAD97665500916E7EDAE6CEC7D09B7529F34F682E05B143DF370A10F1A6B1B0C7F61A250ABE412136F965744D13E12E5987B552865464A39F58FAEA46A53B50C8C557DF1227D66E5';
wwv_flow_api.g_varchar2_table(4) := '5D6C590FF2ABE32752CA64A7E389179FE7226DD92EF9E71C019F544367F88D99370000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F646966';
wwv_flow_api.g_varchar2_table(5) := '7900323032312D30372D30395430383A35303A34332D30353A303082DD477C0000007E744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D';
wwv_flow_api.g_varchar2_table(6) := '76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72616365747261636B2D6379636C696E672E73766797CD27C90000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228365782575293108)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/racetrack-cycling.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322B0AAA4F82000000BD4944415418D395D1B14A82711405F01F262E4145E0D8D060EFD01438B704E1EC2434363505BE42A1E024F8124E2E51114D';
wwv_flow_api.g_varchar2_table(3) := '2D220D214214D8E6E02088B7213EFAF3F12DDEBB9C7B0FF7700E97ADEBC963064B057414DDEC5B0A61E1A458B42B84F0AAACEE255B1F6A3942D5C246C79B076BE1026E0DF5BD5B0A1FCE9C9B0BDFA6E6AA99C297106A7A36C2CA29EE5CFDBB4DBB9506DB';
wwv_flow_api.g_varchar2_table(4) := '758DAE634D0333FCA48E1B462E93B9EDD35E1AA8928B78E3FE0FECA06C92A39F1D186FFF8D7CFD02017037E98986D4300000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380000000';
wwv_flow_api.g_varchar2_table(5) := '2574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34332D30353A303082DD477C0000007C744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F61';
wwv_flow_api.g_varchar2_table(6) := '64732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72616365747261636B2D686F7273652E73766767FA5C3E0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228366212696293149)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/racetrack-horse.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000764944415418D38D8F310E404010459F3D0205C91E424FF4EE26711D3D2B5129546EB30AECCE121B7F9A37F9993F33105502';
wwv_flow_api.g_varchar2_table(3) := 'C04C056C0C00B49480A1B96D1B19052CA9A353991CB15FA4E2A72917162A93EB3F4FF3E135CD8B84ADDC239E2E4DD8578DFC578111DD4E1EDAFD23BA0BED152D3ACD72C201EEED236C535561510000002574455874646174653A63726561746500323032';
wwv_flow_api.g_varchar2_table(4) := '312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F200000071744558747376673A626173652D7572690066696C65';
wwv_flow_api.g_varchar2_table(5) := '3A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7261696C2E737667075A7361';
wwv_flow_api.g_varchar2_table(6) := '0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228366545373293193)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/rail.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA210000008E4944415418D39590B11183301004578EC91866DC8F9D11D10125A819624AA014A882400410939C037E2C094CE08DEEB57A';
wwv_flow_api.g_varchar2_table(3) := 'FD8F20B22184D8E2D123D101073802B7282F6377C38C0031D35CFB02132D4F5AA65FCF8B97A5F779C4A14B4B65D4EE6629775E6D05A04E72466F9F22447FD5051D0B62A1A3E03F2A76BC65CF4E956B9F4C16FA5E354686A41A188FF0013EB83067177B28';
wwv_flow_api.g_varchar2_table(4) := '440000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F200';
wwv_flow_api.g_varchar2_table(5) := '000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D6666';
wwv_flow_api.g_varchar2_table(6) := '64646431312F69636F6E732F7261696C2D6C696768742E737667042EE4930000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228366895126293236)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/rail-light.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000A94944415418D395903112823010455F180B2B3B66183D83149488AD3771B44CE74DBC06B5B64041C1700C0EA052D0AC051B';
wwv_flow_api.g_varchar2_table(3) := '2474BE346FF767763601C7910F8220BC39B8E66A8ACFACB9F362C3950B151E868E52BDA4C38C1A682B269AE28A88BD1F9F805ABDD67AC61361A7BE4578F8718FB881C408BD5B69445862E6859092D170A3212573D77FEF0E3024246A0B0AFD31770AFE21';
wwv_flow_api.g_varchar2_table(4) := '64C0AA5B06423FB68BE1D68F5BF25995D38EF205C49C353095FA61000000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032';
wwv_flow_api.g_varchar2_table(5) := '312D30372D30395430383A35303A34342D30353A3030477A79F200000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E';
wwv_flow_api.g_varchar2_table(6) := '302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7261696C2D6D6574726F2E737667A7B1E4A20000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228367172263293277)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/rail-metro.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA210000006A4944415418D3A58EBB0D80300C052F4091AD6858212B3041064C16A0A3A462904713447E520ACE852D9D7F50B3B2A6DC21';
wwv_flow_api.g_varchar2_table(3) := '2044202000536965B581A9998FC4943BA8B85F60F1088F6D95C1712184B8D99973B97124F5C689FB3E173DBA9F172C757FB96B30FD4F0F7800DABE1D739759BD460000002574455874646174653A63726561746500323032312D30362D32325430393A33';
wwv_flow_api.g_varchar2_table(4) := '333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F20000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F5573657273';
wwv_flow_api.g_varchar2_table(5) := '2F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72616E6765722D73746174696F6E2E73766757DB5D840000';
wwv_flow_api.g_varchar2_table(6) := '000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228367620309293320)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/ranger-station.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000BD4944415418D38DD1BF4A420114C7F1CF4DA3082F04A221C5C55D04A7087C8C7488E668927A81208468D5CDA93D71727068';
wwv_flow_api.g_varchar2_table(3) := '6FA837881A746969089ADA6E83D7AEA489E72C87EFEF70FEB2B66DBBF36E6477B97CA92E706B98A2602129EBC983B293146D38D74AE2D0BDD8782670E4594F3E91F764C4C2548E4473C5DF341C7A4CC1BE0F6D17FF2DD471B3841667C3BD2ACCE11D55B0';
wwv_flow_api.g_varchar2_table(4) := 'A93FEDFDE5E077CD532F8EB1E5CCF71456F45D83AE38F14F03A5BFFD024D1357AB2E9F535BFB4B3F8C8B21B57F761EA00000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380000000';
wwv_flow_api.g_varchar2_table(5) := '2574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F200000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F61';
wwv_flow_api.g_varchar2_table(6) := '64732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72656379636C696E672E737667BE9A478E0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228368007606293365)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/recycling.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000BB4944415418D395D13D4E02511486E107312C810909B1B4305197C06DA525A16639DA0DBA0A56405883DA4032A336B6DE86';
wwv_flow_api.g_varchar2_table(3) := '40853124D702CD4D26347CA73B5FDEF3CB49FA38966CEB2B3CAA25B5A9C2857338033DAF9676C618FBB6F4AC97ED3D985B61650E7E72F127F78228488268E04199ED37D708B692AD016E5479DA7434EA26BD916C844CB7C1A52B7B33231377665E8C7C5A';
wwv_flow_api.g_varchar2_table(4) := 'FCD385280A4808A22F5D1C96D74132B4C6ADA1A4A5D3BC5AA992544A5DFDBFB60DBD9FF4A15FD930421E0DA93C310000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574';
wwv_flow_api.g_varchar2_table(5) := '455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F20000007F744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F616473';
wwv_flow_api.g_varchar2_table(6) := '2F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72656C6967696F75732D62756464686973742E7376675F7CA3530000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228368348048293410)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/religious-buddhist.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA210000002C4944415418D363604006C719FE331C4116604491FE8F2EC6C4801710908619F41FBB0C750CA789CB07B1340066AA05A456';
wwv_flow_api.g_varchar2_table(3) := 'D93F140000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79';
wwv_flow_api.g_varchar2_table(4) := 'F200000080744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D';
wwv_flow_api.g_varchar2_table(5) := '666664646431312F69636F6E732F72656C6967696F75732D63687269737469616E2E737667626D11070000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228368707002293452)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/religious-christian.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000764944415418D3636040051319981870821086FF0C89B82459196E31FC6778C9C08F5D3A97E13FC37F86FF0CDDC8822BA182';
wwv_flow_api.g_varchar2_table(3) := 'D8E05A06066186E738243F324833303030F8E2904E8359B0188BE441064606A82F1919F0003F7C868BE0771A018F214012BA8BD1C10286FF0CCB713B929B61150337B2000066B36817D5BAD7200000002574455874646174653A63726561746500323032';
wwv_flow_api.g_varchar2_table(4) := '312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F20000007D744558747376673A626173652D7572690066696C65';
wwv_flow_api.g_varchar2_table(5) := '3A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72656C6967696F75732D6A65';
wwv_flow_api.g_varchar2_table(6) := '776973682E737667BE15D4AE0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228368961726293501)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/religious-jewish.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000DB4944415418D38DCE2F4BC36114C5F18F3F44C4BD083159D6B6BD81C13018CC26DB4F04C1E8EB30A8CC66B0EC1D980C6299';
wwv_flow_api.g_varchar2_table(3) := '209A4406068BC12108631306DE85E7D91FC1E049F7DE2FE79C4BD2A6533D235F9E9CA8FAA56363213C3B50D770645F318721842B2B3343616D1A9B9C0F0BB0A6361DCFB27767A1ACAD9D86652D30760D9A1AD8C52BEE1909E17DD659EA0BA1AF54F02984';
wwv_flow_api.g_varchar2_table(4) := 'E1FC531D2174D2729BBB1B19560C74750D54E030E3CB8C9B4A8542A909AB7A42F8B1ED4F557DE4FE3D4BF9564FD169DD706E0BF4DC09DF2E3CCE71CA685937F4E6C68BFF6902E7CB4C813D0EC3390000002574455874646174653A637265617465003230';
wwv_flow_api.g_varchar2_table(5) := '32312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F20000007D744558747376673A626173652D7572690066696C';
wwv_flow_api.g_varchar2_table(6) := '653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72656C6967696F75732D6D';
wwv_flow_api.g_varchar2_table(7) := '75736C696D2E7376674CD602760000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228369432910293548)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/religious-muslim.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000614944415418D3A58FC10D80300C03AF8815CA7C0C01DFBE3B06FB741476C03C80422102893A52A22889ED400D1CD0D1E31E';
wwv_flow_api.g_varchar2_table(3) := '938589196044660CDB9E27204424E62C02FEA412DAEBB5CB9A325DD1BC3B6FEFFB25D7C775DDF8D04E85F7647CF2032B196621C1EF2ACB0E0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A30';
wwv_flow_api.g_varchar2_table(4) := '3026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F20000007D744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D4346';
wwv_flow_api.g_varchar2_table(5) := '2F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72656C6967696F75732D7368696E746F2E737667975268E40000000049454E44AE';
wwv_flow_api.g_varchar2_table(6) := '426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228369742266293593)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/religious-shinto.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA210000005A4944415418D3B590310AC0300C03CF210FCAEF32874E7D42B3F4915E0BEE50124C2034502A0FB6103248F00502800DBC23';
wwv_flow_api.g_varchar2_table(3) := 'ACFCB06177C499F09F7B43295E6EF34031D40713C465AE5C9C73371C4BB544203BDEEE4406F6973A6FAFFD1CCDD5B9A7E00000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000';
wwv_flow_api.g_varchar2_table(4) := '002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F200000082744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F';
wwv_flow_api.g_varchar2_table(5) := '6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7265736964656E7469616C2D636F6D6D756E6974792E73766711151C880000000049454E44AE4260';
wwv_flow_api.g_varchar2_table(6) := '82';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228370101352293641)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/residential-community.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000AC4944415418D3ADCE3D8A025110C4F19FE2E207328189260E68220B8BC99EC0C81B7803BD8E8199E04DBC8182D186467B05';
wwv_flow_api.g_varchar2_table(3) := 'A35D8667F09E333AB11555F7BF8B2EA2B69696B6695AFB8DA69516B90C3958D9A76DC20D6319C61A828D524D3055C8640A537C5638A6E7BEF531337735A8E3890F5F60848E9A7A0E8260A78D2008F593B34B72B70A374B5CF84B6EE1F8DA3C3EE8267772';
wwv_flow_api.g_varchar2_table(4) := '7DAD1671F56FF81E5CE9BFAC16BBD7D2A7A7F4CFE3F40E5AAE25036F361CF00000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900';
wwv_flow_api.g_varchar2_table(5) := '323032312D30372D30395430383A35303A34352D30353A3030E10D724600000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D7637';
wwv_flow_api.g_varchar2_table(6) := '2E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72657374617572616E742E737667263046480000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228370451334293686)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/restaurant.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000DF4944415418D36DCE312F437114C6E1A73717B94DD486419BB44C626165163135E22388CD5C2C8C265D8C1689D1B7502221';
wwv_flow_api.g_varchar2_table(3) := '52E9DA1825C42E8AFE0DEEAD5EF12EE73DE7E4FCCE0B34AD5AD334AC238841C584824A6EDDC06E8482B27125651158F7ECC139E66254F595443ED5742DBA909874E6F80753D7D3D1D1B381962078B794FDAE1AB100A6CD5B06FBEEB31045A782E0C4982D';
wwv_flow_api.g_varchar2_table(4) := '41F094A618E8561BEC0982AB6C1CA7F54B00AF6056A48F01A4A8085A60CA761EDEF598BACBE1E4D9752249DD8E378C5AF90F4EDBA617776A1A663278CF47FE9BE0E0B7B976F3677D08DF84EC3782D1BEAE4B0000002574455874646174653A6372656174';
wwv_flow_api.g_varchar2_table(5) := '6500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F20000007B744558747376673A626173652D757269';
wwv_flow_api.g_varchar2_table(6) := '0066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72657374617572';
wwv_flow_api.g_varchar2_table(7) := '616E742D6262712E73766782907B0B0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228370808790293730)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/restaurant-bbq.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000974944415418D38DCF310E01011085E16F2D11349B08A59E42832BB88A23B884029D4B28342AB5A8741A4AAD46949B50EC12';
wwv_flow_api.g_varchar2_table(3) := 'B136D937CD64FE372F33E4AB4290194606468686EEFA092E3919DBD98A042E69DD12FFD442AC25CEE697F15045CFD14C474553A4A1EDAA9B98C27F9B0514E0994F4B58E6C0B9F4ADB567A636C2B7AF66FF030FEADF412DE72F78D12E7CF95BAB4F3729F8';
wwv_flow_api.g_varchar2_table(4) := 'F70BD4012E0F209FF3E90000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30';
wwv_flow_api.g_varchar2_table(5) := '353A3030477A79F20000007E744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D666664646431312F69636F6E732F72657374617572616E742D6E6F6F646C652E7376676231BDD60000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228371217618293776)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/restaurant-noodle.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000C14944415418D395D1AF4B83711007E047270C54B02D0C1604F38AC5A8302C825D1005EBDAFE008505BB601A2C2C2E68984D';
wwv_flow_api.g_varchar2_table(3) := 'C56A591CF6172D16CB7EBC68D819E70B5F11AF3E7707F739FE5125279E95D358F7220CD552786CEAD5A17567299C7B5271EA5DD82EE29E4F0F567584F0E1E027AE7933B2A12B8470599C6D9BDBD1127203B94C4B63C1E7AE558D855BDC08E1B1B8A12113';
wwv_flow_api.g_varchar2_table(4) := '66FA66BEDCCB6D161B561C190A6180BE76EAFA5D77267AC632CBE9F4B65C990AFB2CFD927E4513177FFCE81B04C13AE0ABCDFF910000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943';
wwv_flow_api.g_varchar2_table(5) := '800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F20000007D744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F77';
wwv_flow_api.g_varchar2_table(6) := '6E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72657374617572616E742D70697A7A612E7376678ABB4B220000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228371535148293823)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/restaurant-pizza.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322C94CEDA21000000D04944415418D38DD1BD4A03611085E167D72A60212818050D42440CA4B7B2F2020449C07B90285E848D45C0CACE8BB0B1B3';
wwv_flow_api.g_varchar2_table(3) := 'D242112D221A916095C6804116DBCFE223CB46823A53CD79E7C0FCF08F98F94D4BB527E0B684140D8BA8E7205143C576C4FB9ED0283877F0E8201699269E0BEE07EC1AC6F25610740AEEAE20B8660A97CAE69CBACAF1926517F67C8C840D7D2D1D997B2D';
wwv_flow_api.g_varchar2_table(4) := 'EF567F6EF92AE479677A3446EA46625D69AC3DD335B49580135F3E1D9A0503C7AADE1CC5CE4D67604D4FF0A20ACED5225E313FE1A8150B7FFEEA1B24AC314D038954450000002574455874646174653A63726561746500323032312D30362D3232543039';
wwv_flow_api.g_varchar2_table(5) := '3A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34342D30353A3030477A79F20000007F744558747376673A626173652D7572690066696C653A2F2F2F433A2F557365';
wwv_flow_api.g_varchar2_table(6) := '72732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F72657374617572616E742D736561666F6F642E737667';
wwv_flow_api.g_varchar2_table(7) := '78E4D7570000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228371879367293868)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/restaurant-seafood.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000974944415418D3B5D03B8A02011084E16F40C458F408B2287801C150D0500F602CA8137A1243834D3D85C7D0C46452511616';
wwv_flow_api.g_varchar2_table(3) := '4456B00D1C1FB0A656D1D1DF505DCD0795A0A1A38499B2BD9195FD73A1EF4FE426845FD327DE3CE01D873054D454E5F0169F9C8525DF6F71D819AB32105A162FB8A6EDC7C551CA562BBF22F2E14BA66E2E2D284AFED5AD606D023DD94BE2CD99EE279F9D';
wwv_flow_api.g_varchar2_table(4) := 'EB0A02114B6C96128CB60000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30';
wwv_flow_api.g_varchar2_table(5) := '353A3030E10D72460000007D744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D666664646431312F69636F6E732F72657374617572616E742D73757368692E73766773D4FE010000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228372248917293914)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/restaurant-sushi.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000B74944415418D395CF316A026110C5F19F128B1421AC7B014FE00584B06D48914368A56C69E5013C8007B0CE29C453D8B917';
wwv_flow_api.g_varchar2_table(3) := 'D025D8B98A9F85AE7E0812F21E03F3E6CF0C0C901A8242508091D455035B9537CC0573A40EB60634B1D2D2926179AD4F2F5EADEBFD9E9D193A820E7EEC7D89F4A11FA5896FFF51AE126EAEE4317C57CAA29CF995DCE3D4E2E1DAC2B46EC74ED1E1DA27E3';
wwv_flow_api.g_varchar2_table(4) := '0B3E6AEBCA2394EB4A1D2F38489044B8CE1A084FFF6934FFFE7923281F66A560C319B9C743CD247CB4300000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A94380000000257445587464';
wwv_flow_api.g_varchar2_table(5) := '6174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30353A3030E10D72460000007A744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170';
wwv_flow_api.g_varchar2_table(6) := '626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F726F61642D6163636964656E742E737667BD3594690000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228372619630293959)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/road-accident.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000914944415418D37D913B0EC2400C449F8CC439C8165C89900B711428F91C239F5B6C5010F484662856810476332E9F672CDB';
wwv_flow_api.g_varchar2_table(3) := '1064145C6879D172668B3192A34193AA715F78FB8142746421B68940212A0C8A0414225FB0634D4A4BB82214414278E867F0D37890D6DDA83EBDD302288DFD8CFB00469D58AB0CA77574D1ABAD86908CEACF998DA71839273C3D9E239BE1636F6483726C';
wwv_flow_api.g_varchar2_table(4) := 'F2D1F1E10000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30353A3030E10D';
wwv_flow_api.g_varchar2_table(5) := '724600000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B69';
wwv_flow_api.g_varchar2_table(6) := '2D666664646431312F69636F6E732F726F6164626C6F636B2E737667D354C3D00000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228372889785294005)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/roadblock.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000944944415418D395D1310E82401085E1BFC7162A0A136D8C37207008C3616C3D831A4D68B908952730106BC219948667216B';
wwv_flow_api.g_varchar2_table(3) := '76172D785B7E33BB991D989D2D176A7A34A50505034288DEC798C74842DC5D8C68102221458893819CCEEA4AC910039B0FAE795968CED5F4963FB021705FDE3B184F873A7C397421A46269157839222A0084687DBE711E2F144F76FFFFBB6435633B6F5F';
wwv_flow_api.g_varchar2_table(4) := '794CEE033EA8DB0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30353A30';
wwv_flow_api.g_varchar2_table(5) := '30E10D724600000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D';
wwv_flow_api.g_varchar2_table(6) := '616B692D666664646431312F69636F6E732F726F636B65742E737667000CB6C40000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228373332673294050)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/rocket.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB70000004D4944415418D3BD8E310EC0200C032F55175ECC5831F6D566C84080C256BC59D6D986AD0C0005A798DD5B8C6B11CB5BBEE2';
wwv_flow_api.g_varchar2_table(3) := '8261CEFFBA7DE079CF8501A733423CDDB6B56B2F092843C7DC3CAA021FDC112E7122735D0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F';
wwv_flow_api.g_varchar2_table(4) := '6469667900323032312D30372D30395430383A35303A34352D30353A3030E10D724600000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D61';
wwv_flow_api.g_varchar2_table(5) := '6B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7363686F6F6C2E73766751D4E98E0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228373604004294095)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/school.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000A74944415418D395D13152C2601005E02F7469E8A04AA9751A69F00014E015F42A7A08ADF502B18013380E0C1D07C199D8A5';
wwv_flow_api.g_varchar2_table(3) := 'D0AC0514FC26CCE86EB3F3DEBE7DBBB3FC23163ECD4F8141425F199A74358DE864637E50C719AB13FC59B83FD60FC24BDA792DEC8D30F6214C7F8F5A09954C252CBB4E855A580BB5A26F95992FE1DB4DFFDD1732642EBBCADC93D07AD50A8FF294DE0A8D';
wwv_flow_api.g_varchar2_table(4) := '5BDC69844D4ABFDB298F7569E7ED4F3FFA01DCB735531DA660680000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D';
wwv_flow_api.g_varchar2_table(5) := '30372D30395430383A35303A34352D30353A3030E10D724600000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D';
wwv_flow_api.g_varchar2_table(6) := '302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7363686F6F6C2D4A502E7376675CECCCC80000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228374036334294144)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/school-JP.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000984944415418D385CFCF0A015114C7F1CFC85AB2F41C5EC0E378026B295958519E435EC6525988923F0D22E95A8C19A3CC38';
wwv_flow_api.g_varchar2_table(3) := '77737FF77B7FE79C1FA515FD78EBA8E16954660CE6E51855B074B5B6B6302CFA1B7EB92B05AD9B3824D7BEBB20D865B06DF3E97713DE2789DAF5C8E90C06D4CD32B54F661F73EBAC6CB54422914671EA81582F151741FC8563C1290D367537FDC2636713';
wwv_flow_api.g_varchar2_table(4) := 'FFEA05BE1C395D3F053A4B0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D';
wwv_flow_api.g_varchar2_table(5) := '30353A3030E10D724600000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D617062';
wwv_flow_api.g_varchar2_table(6) := '6F782D6D616B692D666664646431312F69636F6E732F73636F6F7465722E737667BCA481C30000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228374285443294190)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/scooter.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB70000007A4944415418D39DD0310E01011005D09755D069F4A276055750EE155C41BBE55EC115B40A97D0EA254A854AA2205FB9C1B2';
wwv_flow_api.g_varchar2_table(3) := 'E24FF932939FE1AF0C2DECDAA030B3721179A5B1CA41C4DD56D9405F69E326E2A8366968AA761271B536D77B3E19117B4BA3B632E7B61A4D06DFD9672EBE7FE767CEDB549DDB1D7900EF072A82C35199740000002574455874646174653A637265617465';
wwv_flow_api.g_varchar2_table(4) := '00323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30353A3030E10D724600000074744558747376673A626173652D75726900';
wwv_flow_api.g_varchar2_table(5) := '66696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7368656C7465722E';
wwv_flow_api.g_varchar2_table(6) := '7376675FE5F7490000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228374690218294237)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/shelter.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000684944415418D36360A01378CC608B4DF82DC33C0626060686FF0CCF182430A5FF23C1FD0C2CF8A4FF336C6710C727FD9FE1';
wwv_flow_api.g_varchar2_table(3) := '33C302066F06365CD210F888210CDD1A56066386D90CAFA10ABEA1EB7ECBB094C18A811555CF1BA8E41B0651863C868B0CBFE07CDA0200012840C1E98276C20000002574455874646174653A63726561746500323032312D30362D32325430393A33333A';
wwv_flow_api.g_varchar2_table(4) := '34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30353A3030E10D724600000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42';
wwv_flow_api.g_varchar2_table(5) := '324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F73686F652E7376678521B7400000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228374997552294285)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/shoe.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB70000008A4944415418D36360A00EF061B8CAF087E13FC31F86AB0C3EE8927C0CCF192C199819181898192C189E31F0A14A3B301C46';
wwv_flow_api.g_varchar2_table(3) := 'E21D66B0873098A002DA0CD790A4AF31682338BB19FE63853B21BA2FE170EC4508E58843B71D449A85E13D16C9770C2C10C3FF30ECC462F476863F30976FC1228D2426CCF007CDE8DF0C42C86ADB197E2149FE6268262A2200289A45E3703D0AE9000000';
wwv_flow_api.g_varchar2_table(4) := '2574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30353A3030E10D72460000007174';
wwv_flow_api.g_varchar2_table(5) := '4558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431';
wwv_flow_api.g_varchar2_table(6) := '312F69636F6E732F73686F702E7376672D21AFB20000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228375432969294333)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/shop.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000344944415418D3636018DAE031830D9A882DC32304C793E131C37F14F888C18304E38F321CC6C663820AFC63F88F248DCA1B';
wwv_flow_api.g_varchar2_table(3) := '200000F297129AC84315F20000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D';
wwv_flow_api.g_varchar2_table(4) := '30353A3030E10D724600000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D617062';
wwv_flow_api.g_varchar2_table(5) := '6F782D6D616B692D666664646431312F69636F6E732F736B617465626F6172642E73766793FA26B70000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228375731069294380)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/skateboard.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000974944415418D395D1BD09C20010C5F19F7181D4828560EF0476A2A67006577084345AAA64132B7B2B3BDD202344348D20C4';
wwv_flow_api.g_varchar2_table(3) := 'C2201ABFF00E8E83F71EFCB9E38F0A8D859FE54C21137FB21465C798C94DABF24E56CA27856350C9AFB4CA2D914B683C80DD72B709026D0B03A158EA600F3ACF70918DF39D38969A54A97B9646DFCFD2B3F86589CCF551D7A4F6D632D475B1B6FDE723AF';
wwv_flow_api.g_varchar2_table(4) := '7505735A26E8AF16802F0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30';
wwv_flow_api.g_varchar2_table(5) := '353A3030E10D724600000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D666664646431312F69636F6E732F736B69696E672E737667F9FA9C860000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228376106613294435)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/skiing.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000904944415418D3CDCDBD0A41011887F19FD329655156E50E942B31D92C4C7677711617E012ECAE40226590B2E80C1259CF26';
wwv_flow_api.g_varchar2_table(3) := '8663F075E4D8FDDFE97D9EF783FF4B435799504947682F11A8A89959681B68496024CDAD449382B3E28F07A96141FA435EC52E720F8FDF53C72F19AB3E65686B6922123D485FCFE1BD3D57C729D36712D85963F522F1A7BE8BE98B6CB2FA0657E33C5857';
wwv_flow_api.g_varchar2_table(4) := '183D5A0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30353A3030E10D72';
wwv_flow_api.g_varchar2_table(5) := '460000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D';
wwv_flow_api.g_varchar2_table(6) := '666664646431312F69636F6E732F736C61756768746572686F7573652E737667634885FD0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228376370462294486)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/slaughterhouse.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB7000000974944415418D3B5D03B0E81611085E147940A9D960695FC76620F620B1496600B5A0A61031AD1DB834B1412D11011143ECD';
wwv_flow_api.g_varchar2_table(3) := '4FDC128538D34C72DE99C919FEA8E4BDCBEA2B1ABD2363357923B9CF1B96828B9EC2677B2008828BA1CAC3B95825EB18088285A60CEA5A3720ADAA6DE21023475D272D122F390A2265914847E36BEE0436B6A6F75A59098FF65EEA696467616EA6EEFCDB';
wwv_flow_api.g_varchar2_table(4) := 'CFAF184E2FAA513F70140000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30';
wwv_flow_api.g_varchar2_table(5) := '353A3030E10D724600000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D666664646431312F69636F6E732F736C69707761792E7376674687E9D90000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228376814767294540)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/slipway.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB70000007A4944415418D3BDD0210AC2001406E08F8167302CCCC30CAF63B219B47807C1B864DB1544984D3089C10B18168C0B6F65C8';
wwv_flow_api.g_varchar2_table(3) := '84CDA6EFB5FFE3FDE1F1A7C93CBE7129C6287510C33CB1F012637CEA288435A6E6960A5737A87ADCDFD22C416EAF1968AD3DB9D8CABA20B1F9B83F93DAA98570072BCD9B8F3FFD730B3BF236E1AEE184C90000002574455874646174653A637265617465';
wwv_flow_api.g_varchar2_table(4) := '00323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30353A3030E10D724600000077744558747376673A626173652D75726900';
wwv_flow_api.g_varchar2_table(5) := '66696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F736E6F776D6F6269';
wwv_flow_api.g_varchar2_table(6) := '6C652E737667B0C896F50000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228377131226294591)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/snowmobile.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322DE3C9EAB70000008F4944415418D395D03D0E41611085E127621114220A120B50D9000BA3955C851B8BD0A8D462137A0AA5FF285C854FC2FD2E';
wwv_flow_api.g_varchar2_table(3) := '8933D59C77CE4C32E4357434F0550799FDAB2945387194F84F6BD95B1DF4E2918A53C00BDB786014E04D43C7E213569D039E165D1FBF6523D55C7F6527E6E81667D9696116B22BCBA75D0EB8EEA2A9AF0DEEB278432AFDF5B98D7ADE7A0089AA34F2382A';
wwv_flow_api.g_varchar2_table(4) := '538C0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34352D30353A3030E10D7246';
wwv_flow_api.g_varchar2_table(5) := '00000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D66';
wwv_flow_api.g_varchar2_table(6) := '6664646431312F69636F6E732F736F636365722E7376675361663D0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228377549085294640)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/soccer.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D0000002B4944415418D3636020088E32FCC70A0F333030323030FCC7A9919109BFC1A3D238A58FE0903BCC4008000050BA0F1CD378';
wwv_flow_api.g_varchar2_table(3) := '5C240000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30353A3030D0E568DB';
wwv_flow_api.g_varchar2_table(4) := '00000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D66';
wwv_flow_api.g_varchar2_table(5) := '6664646431312F69636F6E732F7371756172652E737667D63BAFEA0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228377796972294690)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/square.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000474944415418D3636020088E32FCC70A0F333030323030FC67E864388BA1C998A19C819105AA7F3386F40F0606060626FCF6';
wwv_flow_api.g_varchar2_table(3) := '0E5B6948B058337060C818C318877184F92106420000E19A1EF7B451E0220000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F646966790032';
wwv_flow_api.g_varchar2_table(4) := '3032312D30372D30395430383A35303A34362D30353A3030D0E568DB0000007B744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E';
wwv_flow_api.g_varchar2_table(5) := '302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7371756172652D7374726F6B65642E73766733FDFCC00000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228378162013294749)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/square-stroked.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000974944415418D38DCE3D0E01711005F01F3A42547A9770035A15375073A44D3885C409E87C251A854A250AA2F2D72CBB9615';
wwv_flow_api.g_varchar2_table(3) := '6F32C59B37F3E6F113A50C5FB8D9B8E7AD07C1C1205FDE19AAE4CB85CF6151DFC4DA4970B236D6534CE499F05153C456E1EBA3829745578473DC91EE7BA0B4478A3DAFAB19E35A9A5C6D0C0575D405235B9744EE5865722FB593E4D0D4D250767534B7F7';
wwv_flow_api.g_varchar2_table(4) := '0F1E3C0537BDB29C246F0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30';
wwv_flow_api.g_varchar2_table(5) := '353A3030D0E568DB00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D666664646431312F69636F6E732F7374616469756D2E7376670B1123500000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228378537899294799)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/stadium.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000A64944415418D37D90310AC24010455FCC6A25D88B186C14B5F120B1D45210C4D6EB587A82401A41B0B34A9346C43A780441';
wwv_flow_api.g_varchar2_table(3) := 'B01A0B139859A2B3D5FEB7FFCFCC82AD2D7FAAC79BBE161A066F68B1FEE50D29101E84F5788E2008B116BBE4A5EC9FEB778E36C71A78A6532538F61E3CD0D42D0212051302BB9830528FC7889D7AEA854FAC7B01C0891929004BEBBEF16257765CF1E46E';
wwv_flow_api.g_varchar2_table(4) := 'A33386EA3EE052C5034438EF071D11C007724441618171229A0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30';
wwv_flow_api.g_varchar2_table(5) := '372D30395430383A35303A34362D30353A3030D0E568DB00000071744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D30';
wwv_flow_api.g_varchar2_table(6) := '2D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F737461722E737667CD956B180000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228378945223294848)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/star.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000DC4944415418D37DD0BB4A03611404E04FB73146108B4082A258D8A6DD32452AC1150B0BAB74BE84B59D8588E003A49294FA';
wwv_flow_api.g_varchar2_table(3) := '0A0A6A2529448285784110355EB6B05B8B6CE45FBC4C35E70C3373381451F30F22C7A2BFE54466295C8C14E443633E25BF7B673C98F264367457B5F28CD8A50DBBA69D824C3B925AB02DD2F76CCFBB2B734A9A5AF61D0D329AEE2D0735AB1E2D86BD75D7';
wwv_flow_api.g_varchar2_table(4) := 'D672BEEE467D4047F355D7D937CF9CE816AF2E7B31A9664B55C59BF2F04F03ACA8E83BF061D3B979AF2E4277C7AD9E18B19E3B9D501C976A9BC8A7921DE9301E1A3F1E9968C017978B308F328359730000002574455874646174653A6372656174650032';
wwv_flow_api.g_varchar2_table(5) := '3032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000079744558747376673A626173652D757269006669';
wwv_flow_api.g_varchar2_table(6) := '6C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F737461722D7374726F6B';
wwv_flow_api.g_varchar2_table(7) := '65642E73766782C782620000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228379218197294900)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/star-stroked.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000494944415418D3CD8EB10DC03008048FACE50CC76E90B97093202862454AE3A3417F08808F3891654F28A9830B07E064943C';
wwv_flow_api.g_varchar2_table(3) := 'B5DE9D125558591BFD84409F6DC8B1FE7773ED2FCEF9C904EB951B945DF4C2C20000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F64696679';
wwv_flow_api.g_varchar2_table(4) := '00323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76';
wwv_flow_api.g_varchar2_table(5) := '372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F73756974636173652E7376676CF61EC60000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228379615453294961)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/suitcase.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000AC4944415418D3ADD1314AC37018C6E1475C4427E90992D923140A52DCBD40A18B6B1C1D3D45A14BD1A1CE35BDC07FB01DE2';
wwv_flow_api.g_varchar2_table(3) := 'AA8278884C26937C5DC414A953FDA61F3CF02E1FFF7BE7928FDDD49784D6CD2E3CF52594F2BF8617C2183D6BB5ABDF3C163E9DB91642BD4D436B2184379742587538114263AE11EE5D28F43A3E3653CA907974DBC181917785C3AD3A32F5640895D68356';
wwv_flow_api.g_varchar2_table(4) := 'F55D8D672F5E2521B19423B7FCA9D29D130CA4FD1EB00135623B02FFDB909B0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900';
wwv_flow_api.g_varchar2_table(5) := '323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D7637';
wwv_flow_api.g_varchar2_table(6) := '2E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7377696D6D696E672E737667D7144D5D0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228379918958295014)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/swimming.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000974944415418D395D1310AC2500CC6F13FBCDE4070D7418F51A42088AB8B630F2474101174542707EF635D0A3AEB685B8C93';
wwv_flow_api.g_varchar2_table(3) := '2F2F2D0E4DC6DF47080974A8840B0F0AF60C9B14B1457CBF482C67010AC29381629FAAC1C24ED9716AF12D1CDE0E148A1346388E86CFCA33EE8C4DE0436CF7B681B5E28237E203074A56443F4CA9112A364C8901472FDC3947A859FEBBF49C2B6997D7F8';
wwv_flow_api.g_varchar2_table(4) := 'FA02360C540C5590183E0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30';
wwv_flow_api.g_varchar2_table(5) := '353A3030D0E568DB00000079744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D666664646431312F69636F6E732F7461626C652D74656E6E69732E737667D5CD68260000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228380321750295071)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/table-tennis.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000694944415418D36360200968E3975ECAA0814BCA8681814183E134433976E914860C0606062D868BD8A559183A181818EC18';
wwv_flow_api.g_varchar2_table(3) := '7449732E03030303C37386FF70F80C26C80497BE80A4F43CA6F44124E9039886AB2219AE8ECDF672A8643D42881145C17F743126064A000068D61986AEBEE2D60000002574455874646174653A63726561746500323032312D30362D32325430393A3333';
wwv_flow_api.g_varchar2_table(4) := '3A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000075744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F';
wwv_flow_api.g_varchar2_table(5) := '42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F746561686F7573652E7376672B856F810000000049454E44AE';
wwv_flow_api.g_varchar2_table(6) := '426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228380611853295120)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/teahouse.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000814944415418D3ADD1210A02511405D0035A86014114AC5A645C82D95D4DB10956CD6EC260B1383B70966090BF081DBE5174';
wwv_flow_api.g_varchar2_table(3) := 'E607C15B4FB8EF71F967A62A8D87A3711B676EA2280AE6DD58DB091672EB365E8D3094ABECBB11564ABDF7419FF8958BA84E218D689BFEF629BA1BA4F824286496DD3C51C89C95E9828D83FE8F13BC0039D1254618CFD924000000257445587464617465';
wwv_flow_api.g_varchar2_table(4) := '3A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000076744558747376673A6261';
wwv_flow_api.g_varchar2_table(5) := '73652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F74';
wwv_flow_api.g_varchar2_table(6) := '656C6570686F6E652E737667B8021BE70000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228380982055295173)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/telephone.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000B24944415418D395D13D4E02511486E1C7E632C934D0B80363EC801DD018DD802D736B6A1B1740C14F494982A13396864A5A';
wwv_flow_api.g_varchar2_table(3) := '88894861E9422C2F0D516608055FFB9E7392EF3D9C995B2F36B6466A55144C6CB445C19371154FCD3544B928F82AC38EB54C57432157F82CE35737E2DF40D3A28C97A25C21D355F7E1FE10E6BE85FDD9CCDCACBC7B25791014AEAD3C576BF524C98FB537';
wwv_flow_api.g_varchar2_table(4) := '77D54A43BF1EB55CBA383635960C4E69EC4BC786FEF3AE7FEE63F6D901CFD52556A44A04C30000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D';
wwv_flow_api.g_varchar2_table(5) := '6F6469667900323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D';
wwv_flow_api.g_varchar2_table(6) := '616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F74656E6E69732E73766794E36A000000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228381336324295225)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/tennis.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000B84944415418D385D1316A02611005E06F553C808DE02DD2261E207B0621957802499BDAD6221E20757286C86EE90DA29568';
wwv_flow_api.g_varchar2_table(3) := 'B1B085C5062C964DB3AC7F56C17F60E60D8F9937BC9FBB2FB1F36A64646E2B09A908558D7FBDEB9A18FE9FAE3C1AABBC80414875EA1CE14B62671ACA84CBA30635D2BD1A1C7D82271DC9A5F67076F2200B642E153F3ECC6C50B502BC35CD4DBA6F61AF44';
wwv_flow_api.g_varchar2_table(4) := '6ED59CB592B7FD5BCB6A538632DF6D3A563A585A3A2A3D5FFB1F4B150AA9F8FE67F9039353407CBEE9DDAE0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874';
wwv_flow_api.g_varchar2_table(5) := '646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D61';
wwv_flow_api.g_varchar2_table(6) := '70626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F746865617472652E73766721C88EAA0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228381713350295282)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/theatre.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D0000009A4944415418D38DCC318E81511406D0E3156F01945328C496446F03B38991686D42E1C71E3412B5686C6134A83D858B1F33';
wwv_flow_api.g_varchar2_table(3) := '93F9929B97F3EECDC73543275F1E79F15171F0E6141C3B19D7D6AFFE3D59A5288A850CF6E1EF24ABB4E3F04325A3196E2553C52C38773679AEFE94ADA36C2D1B102A0A749CEFEC525F27F435EE5D3DB0C3285E9B5AD936CE4ACCCFBC39F933FF5C2FB1AA';
wwv_flow_api.g_varchar2_table(4) := 'FDEFAE73011ABF4520CC1DDFE40000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34';
wwv_flow_api.g_varchar2_table(5) := '362D30353A3030D0E568DB00000073744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D61';
wwv_flow_api.g_varchar2_table(6) := '70626F782D6D616B692D666664646431312F69636F6E732F746F696C65742E7376675975E4C50000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228382014394295335)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/toilet.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D0000007B4944415418D38DCE3D0AC2500C00E0AFE2500F21E8353ABA780957DD3D8FDE4770F020827B1F62E3D276E87BFE242404BE';
wwv_flow_api.g_varchar2_table(3) := '10C2DFB1FA861BC9F6132EDD858775096B5721849B45CEE71E4338E51C63BD1C4B3CE40E8D8BA6CCEC252139948ED3F58B1DCC260B54AAB18F5C7A74C2553ECD41ABF644DBD7D07FC51BA8183428108EDD890000002574455874646174653A6372656174';
wwv_flow_api.g_varchar2_table(4) := '6500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000071744558747376673A626173652D757269';
wwv_flow_api.g_varchar2_table(5) := '0066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F746F776E2E7376';
wwv_flow_api.g_varchar2_table(6) := '67D21631300000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228382283118295390)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/town.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000664944415418D363664006A10CEB197E319C65C001BE32CC64F8C38013DC60106778862CC08822FD1F5D8C898181A181E13F';
wwv_flow_api.g_varchar2_table(3) := '14C21441600744E57F9C963132E0078C48766291634253C8886A2813035E408474180EB95008F58AE13FC37F86720CF215A5FE0600B932201B88FA2AD70000002574455874646174653A63726561746500323032312D30362D32325430393A33333A3436';
wwv_flow_api.g_varchar2_table(4) := '2D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F423245';
wwv_flow_api.g_varchar2_table(5) := '44534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F746F776E2D68616C6C2E737667B4F855F80000000049454E44AE4260';
wwv_flow_api.g_varchar2_table(6) := '82';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228382752132295443)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/town-hall.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D0000007A4944415418D3ADD1210E82500087F1CF011720390B0730B359B9892760044F4325C1213C02C18DEA66C32681C8FE04603E';
wwv_flow_api.g_varchar2_table(3) := '9E8F245FFDC50FF6EB4CCB650B0FDC110F7C375F1142A42E0C79CFDC71FAE57C46210A1B6306834562A247BD42D1107C39B35088DB82473E0EEE89262E1D284435F16B839FFF4E1801957F50E125E3FF800000002574455874646174653A637265617465';
wwv_flow_api.g_varchar2_table(4) := '00323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30353A3030D0E568DB00000075744558747376673A626173652D75726900';
wwv_flow_api.g_varchar2_table(5) := '66696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F747269616E676C65';
wwv_flow_api.g_varchar2_table(6) := '2E737667DD5775510000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228383037265295496)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/triangle.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322E7AC0BB0D000000974944415418D395D13D0E01011006D097D846825A569C40A190380477D05A51D329B883CECF3D144E21D16B44BF54D66A88';
wwv_flow_api.g_varchar2_table(3) := 'C52A4C37795F263319FEA8A2A1E26F9E494D7F614DEC2656CBE7B544CFD52A0F9B120B2C255ADFBC71514728B6FDC46E66A99954278B053B2795475772B417BC7820D5CFC423A9E8D9943FD3AF6901C6AA0EE66FBB9C358C4C0284686B7FDD52FDE71F79';
wwv_flow_api.g_varchar2_table(4) := '7507E36D2388AE7ACD770000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34362D30';
wwv_flow_api.g_varchar2_table(5) := '353A3030D0E568DB0000007D744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D666664646431312F69636F6E732F747269616E676C652D7374726F6B65642E737667BF34940A0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228383412075295548)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/triangle-stroked.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000C54944415418D38DD1BD4A035110C5F11F0ADA6543CA04B4F6155C10D2278262AB5D5E27C4B461C96B48D037D02AA0D8087E';
wwv_flow_api.g_varchar2_table(3) := 'F4215D4891B1D85DDD6C9A0C5C98B9FF73CE5CB8EC593D23099A46FABBF841B8C758989597077FF80D67C579ADFA52998E86A11EFA861A3A32698E1F85696D55263CE5E19F3841D7DCCA5C17A7F8CA956D13A9C452086129716EA25D8DBB2B6008B7F597';
wwv_flow_api.g_varchar2_table(4) := 'B75C55A4D75AB6C645C51BC2C2CD3FFEA9C15C705886AF0AD9DAB775D16F6C4AF785672F068E706CE0DD87CB3DFEE91794FE421EFCAE8F410000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A30';
wwv_flow_api.g_varchar2_table(5) := '3026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000077744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D4346';
wwv_flow_api.g_varchar2_table(6) := '2F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7665746572696E6172792E7376670581926C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228383735618295602)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/veterinary.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000B04944415418D3A5D1316A02511485E12FFAC61D089204B3034963E30AB4D322211B48699D5A881002012B7109D3CC02B474';
wwv_flow_api.g_varchar2_table(3) := '0FA6B1952058662CE3B390843160A3A7BA9CFF16F7DCC3252AFF4D0D7D550B4F9EADAD8B4B091E44134C448F08BFF0DEA71BC1CA14335F12350BCD034E4573C1C0124B03C15C941EF095173FDE5DDBAAD8BAF561E7AD70978E8DAE4C4BA667A3FD3FC39D';
wwv_flow_api.g_varchar2_table(4) := 'B104C158FDAC2F0CE55E4FE35CF45D344A47782437BAA88523ED01E6B02855C3049D740000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F64';
wwv_flow_api.g_varchar2_table(5) := '69667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B';
wwv_flow_api.g_varchar2_table(6) := '692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F76696577706F696E742E737667B1D70E6C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228384122150295655)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/viewpoint.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B0000006F4944415418D3CDCDBB0DC2401084E1EF100812225AA2186A70444805E426A7055A2275362477B625F34859691FDA7F6697';
wwv_flow_api.g_varchar2_table(3) := 'FF884EF7199E455CBEC188A383BBBDE73BD8DB78889B34781A616C5DC719A54A8222CAE45258CDFE675A37DB1CCF2F6589B3105AD73ED861A8D9EAAF780164CF27E61B27236C0000002574455874646174653A63726561746500323032312D30362D3232';
wwv_flow_api.g_varchar2_table(4) := '5430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F';
wwv_flow_api.g_varchar2_table(5) := '55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F76696C6C6167652E737667C73DDF9E00000000';
wwv_flow_api.g_varchar2_table(6) := '49454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228384444988295711)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/village.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000884944415418D395CF310E01011005D0177A95B88128145A22A2D43880689C4DE306228ADD0BB88248D40A543AA3B076B15B';
wwv_flow_api.g_varchar2_table(3) := 'F07FF75F33C38F99A8A1675FCD3B4B2D07A1615AE6AE9BB310AE36AFB19EF3C945D34C4762E1FEEB4D59C652CC911A973911086D21F9C681C8F8D9D1276F85B0CA79FB8EFD7C2E3A2C785DC1EB828F157CF8F3F38A3C00328E4343C49FA81A0000002574';
wwv_flow_api.g_varchar2_table(4) := '455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000074744558';
wwv_flow_api.g_varchar2_table(5) := '747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F';
wwv_flow_api.g_varchar2_table(6) := '69636F6E732F766F6C63616E6F2E7376677EBCF41C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228384773828295766)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/volcano.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000EE4944415418D38DD1BD2BC4711C07F0D7EFDC1142068309CB3946AB946431B0D924B663B679B64A9743994CFE0065903F40';
wwv_flow_api.g_varchar2_table(3) := '5D593CDCA84E8992483278B8FA1A7EAE2B96FBACAFF7F0EEFDA1C6EB308743E776F5FFE769A7381304656BA22A65915740AB3E13F6BD59AE60AF120EBC4AE837A907EDB6A463DEF121B22118D1A52C28184563CCD7828C31C13AE61D79126CAB8BF951B0';
wwv_flow_api.g_varchar2_table(4) := '20E5448B146830A56433E6A2E0564A42A79217C3929A35598939AF684652B72BC11E56DD19AA34AF47CABC679F9645C67D0BDEB5550283EEDDC84963D6872058ACCE12FD561A702C08BE2CFD1D3521EBD2830B39991AFFF403459B432E6CA29F72000000';
wwv_flow_api.g_varchar2_table(5) := '2574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F0000007774';
wwv_flow_api.g_varchar2_table(6) := '4558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431';
wwv_flow_api.g_varchar2_table(7) := '312F69636F6E732F766F6C6C657962616C6C2E737667E146E77B0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228385111787295820)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/volleyball.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000714944415418D363604005CC0C38812CC344860F0C8B189410424C505A8E6122C33986EF0C7A0C57194E302C625046289167';
wwv_flow_api.g_varchar2_table(3) := '98C8F086A1834108CA1762686078CDB0884115C2BDC8D0C12082669118432FC333062E06FC8011CEFA0FE5FF471667C2AF9B80345176A3DB0BB79FA6761300004A6513F0DE1B9BFA0000002574455874646174653A63726561746500323032312D30362D';
wwv_flow_api.g_varchar2_table(4) := '32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000076744558747376673A626173652D7572690066696C653A2F2F2F43';
wwv_flow_api.g_varchar2_table(5) := '3A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F77617265686F7573652E7376679B75982E';
wwv_flow_api.g_varchar2_table(6) := '0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228385531209295876)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/warehouse.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000614944415418D3B5903B0EC03008439F7A840CEDC172F674C815D2CF929D0C4D158A18B2140623191B0B98AE1341100E9F16';
wwv_flow_api.g_varchar2_table(3) := '83C002404610E8EA07F3F4D5D875BAE330BF1DC935C6CD51AF7AB718B2E8E4B01BEBF4A5D31FF45B81AA8255C2D4BF1AA90E3AAB49672A4F0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A30';
wwv_flow_api.g_varchar2_table(4) := '3026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000079744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D4346';
wwv_flow_api.g_varchar2_table(5) := '2F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F77617374652D6261736B65742E737667EE84C3EC0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228385833510295931)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/waste-basket.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000884944415418D38DD0CD0D82501004E04F2F60946E84622C45A34D010D282D78901AE0ECF179F0457E3491B96C32B333BB19';
wwv_flow_api.g_varchar2_table(3) := '16A31704413750AB911CBED9F5874A478B9B7970A251CA6DE52A8D642A5F94A00595D3546EED47F70BF7A9FC94814E7090093127E211DD7EBBCFF1F61BB5E3FCF39B4A61A750BBCE3F278D9D0561E860716BF4B3F91F2F548024B16EE6DA9D0000002574';
wwv_flow_api.g_varchar2_table(4) := '455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000072744558';
wwv_flow_api.g_varchar2_table(5) := '747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F';
wwv_flow_api.g_varchar2_table(6) := '69636F6E732F77617463682E7376673D6881320000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228386193158295988)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/watch.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000994944415418D375CD310E01511485E19F8884641016205A998DD880655069C5121412851D885881C21E46A2A45028D493A0';
wwv_flow_api.g_varchar2_table(3) := '389A27EFBD3B33A7BBF73BB917C224EC6951911A47C4B68A670821266598923B7ED0B3D8207328C4DAF23C40F16614E28057C46217F2CAA0F8D0F77C29B09802D401E24F2E43CFB7127E7A3E14F0CBC90F5DEEE6F3266E8FA3C299B63DD7614946CE9505';
wwv_flow_api.g_varchar2_table(4) := 'CDFFF20703334D4CE1072AA40000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A3437';
wwv_flow_api.g_varchar2_table(5) := '2D30353A30307692636F00000072744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170';
wwv_flow_api.g_varchar2_table(6) := '626F782D6D616B692D666664646431312F69636F6E732F77617465722E737667C161ED0C0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228386498588296043)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/water.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000B54944415418D38DD0B14B427114C5F14F4108B5D41082202D41D0D62046E31BDCC4D1FFA3AD214168F39F707030101C5CC4';
wwv_flow_api.g_varchar2_table(3) := '17FE13AE6D826E4F8A078DAFE1BDF40DBFA27BE170395F38072EFF983B63892CB0B8F71544055E04ECA9CB9FE850ECEDA1391389F6A0A129532BE35C7390DF015CD6EBBFF0C846E777CC83D415D40BEBBDA4F0EA896343CF50B41D3AD7CEE15335F0E613';
wwv_flow_api.g_varchar2_table(4) := '2B6D88F55D78F1E84C4FAAABE2C6C49BA3BC3B965858DA996999FBB035700ADF12EF5CA238C3C09D0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174';
wwv_flow_api.g_varchar2_table(5) := '653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F';
wwv_flow_api.g_varchar2_table(6) := '782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F776174657266616C6C2E7376673960EB4B0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228386757727296103)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/waterfall.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000C24944415418D3ADCF314A03511485E18F6120A4CE0E2C9346096317B0156235951B48E70A2C343B7009A96C8599598095E0';
wwv_flow_api.g_varchar2_table(3) := '08424A3129DC4014524C02C2B3D017C9B47A6E73E0BF877B2EFFA1438F8E745D59D85A98EAFEC2B1B560ED5925732A5379880B173E054150C9A54EA47295EB980E3F9349CDBC9B491D7B6DE391A1956065686443B2577063AEF0A130B7F5D64EEFDFBE8C';
wwv_flow_api.g_varchar2_table(4) := '7869ECCC5270839E0377EE7522EE2B9506CEF5153B577EC35CA3566BDC6A3CED5C1DFF9E4824265E5AEE8FFA0247D249EF2C339C9B0000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A9';
wwv_flow_api.g_varchar2_table(5) := '43800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000076744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F';
wwv_flow_api.g_varchar2_table(6) := '776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F77617465726D696C6C2E73766757E5B97A0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228387248010296170)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/watermill.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000C74944415418D395D1214B43711486F19F97812CBB0B32FB06DE39FC0A6273C960D1B42AF635A38B168B55D06A134C968561';
wwv_flow_api.g_varchar2_table(3) := '19083A311926823886632816FF16EFC68617F1B49707CE735E0EFF9CAA8E817A16BE116C64C158F0328911965C7973600E09EE6715F3AE059BD8151C4F1411F8748A75547027B6E2D5458AB9FD59BC8CAE04DDD49DE24A367ED65790888DF4C607CA8D3B';
wwv_flow_api.g_varchar2_table(4) := '1CC95BF5E54CB0AFEFF2B7DE8BD331B2E3514D59DB48D38743EF5A4AB63CD986351D030D0B4E0C9D2BDAD3F3A0F6E77FBE012B7F3819F7BFAE070000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D3035';
wwv_flow_api.g_varchar2_table(5) := '3A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000074744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D';
wwv_flow_api.g_varchar2_table(6) := '43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7765746C616E642E73766711F878C10000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228387476787296225)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/wetland.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000E84944415418D375D03F4B827114C5F14F8FD9508D254110399953D4D0A88B9373450411F42ADAA3680E5A7A0141506D0D2D';
wwv_flow_api.g_varchar2_table(3) := '42D416B53DB53407A614684488F66BF04F8879A6CBFD1EEEE15C0675E0D3BEA1AA0B6AED31D159E5DDF9F208262D3952FAF3E795EDB87765E6BF732539243DA8D8189639E75B10E406D1B814E65D7B37D58F16DD68099E158DD9525090EAC205354DE78E';
wwv_flow_api.g_varchar2_table(4) := '95B514A5350471B7D3856015CC2A8BB16257B0D9C6152FBD9813C13422B12709224913BDE7A4040DFCD893B50E678243A3466C6BBAED1823B15844DA9BA0EA5550B7DC0B5A136420EDD487AA4BD9BEC2197E0154DE4287FE6BC7A3000000257445587464';
wwv_flow_api.g_varchar2_table(5) := '6174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F0000007774455874737667';
wwv_flow_api.g_varchar2_table(6) := '3A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E';
wwv_flow_api.g_varchar2_table(7) := '732F776865656C63686169722E7376673CF843FC0000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228387906727296280)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/wheelchair.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B000000754944415418D38DCEB10DC3300C44D1874CA22673C85BA58CCA6CE1553287536814BA91002166E1AFE6A02379C7A4926AB0';
wwv_flow_api.g_varchar2_table(3) := '096DE8266CFF032FE133CCB78426D4E5CA852AAEB9B7B667E6EC90342FBE4ADEBC2ABAD0953C7F1742D8F36A7DD83D338B109E4228F3F3B19483DFA2178E7178BEC31D4ECEC1334658C709640000002574455874646174653A6372656174650032303231';
wwv_flow_api.g_varchar2_table(4) := '2D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A35303A34372D30353A30307692636F00000075744558747376673A626173652D7572690066696C653A';
wwv_flow_api.g_varchar2_table(5) := '2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431312F6D6170626F782D6D616B692D666664646431312F69636F6E732F77696E646D696C6C2E7376675C';
wwv_flow_api.g_varchar2_table(6) := 'F5A4D70000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228388250364296339)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/windmill.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000000F0000000F080400000091DF5DC10000000467414D410000B18F0BFC6105000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000002624B47';
wwv_flow_api.g_varchar2_table(2) := '440000AA8D233200000009704859730000005A0000005A007023B87D0000000774494D4507E5070908322F0DC78B9B0000009E4944415418D3A5D0316A02011085E1CF90C2524827825EC04A5BD3E809BC817D6E15B5F004A2A5AD4D48C44A1252582601';
wwv_flow_api.g_varchar2_table(3) := '8916AE8CC58A2EB885E07BDDFF33C330DC93420EABEBD81ADAE40D74ED85F0AE722D5BFEC4A92BD5143E19D99DF1A59F50B6C85121ACA99A1AE7A8AF74F15CCD4008137DDF0E42587A4EF54CD1BF57A1095E84C85EDBF4AB24F108DA59FD80F023F1A101';
wwv_flow_api.g_varchar2_table(4) := 'DE6CD0BBEBD9B7E50864454B88427BCDF80000002574455874646174653A63726561746500323032312D30362D32325430393A33333A34362D30353A303026A943800000002574455874646174653A6D6F6469667900323032312D30372D30395430383A';
wwv_flow_api.g_varchar2_table(5) := '35303A34372D30353A30307692636F00000070744558747376673A626173652D7572690066696C653A2F2F2F433A2F55736572732F42324544534D43462F446F776E6C6F6164732F6D6170626F782D6D616B692D76372E302E302D302D67666664646431';
wwv_flow_api.g_varchar2_table(6) := '312F6D6170626F782D6D616B692D666664646431312F69636F6E732F7A6F6F2E737667FCC62B100000000049454E44AE426082';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(228388478080296395)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'icons/15/zoo.png'
,p_mime_type=>'image/png'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F72657374676A736C6179657228705F6974656D5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F69636F6E5F75726C2C20705F7469746C652C20705F75726C2C';
wwv_flow_api.g_varchar2_table(2) := '20705F746F6B656E2C20705F73657175656E63652C20705F636865636B626F785F636F6C6F722C20705F7374796C652C20705F6572726F7229207B0D0A20202F2F204163636F6D6F6461746520626F7468204D6170626F7820696E204150455820323120';
wwv_flow_api.g_varchar2_table(3) := '616E64204D61706C6962726520696E20415045582032322E0D0A2020766172206D61706C6962203D20747970656F66206D61706C69627265676C203D3D3D2027756E646566696E656427203F206D6170626F78676C203A206D61706C69627265676C3B09';
wwv_flow_api.g_varchar2_table(4) := '090D0A20202F2F2072616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D65737361676520616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274';
wwv_flow_api.g_varchar2_table(5) := '286D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C657274286D7367293B636F6E736F6C652E6C6F67286D7367293B7D293B0D0A20207D0D0A202020200D0A20202F2F206966';
wwv_flow_api.g_varchar2_table(6) := '20616E20657272726F72206F636375727320696E2074686520706C7567696E20706C73716C20616E642069732070617373656420696E746F20746865206A6176617363726970742066756E6374696F6E2C200D0A20202F2F20726169736520616E20616C';
wwv_flow_api.g_varchar2_table(7) := '65727420776974682074686174206D6573736167652E0D0A202069662028705F6572726F7220213D20222229207B0D0A20202020617065785F616C65727428705F6572726F72293B0D0A2020202072657475726E3B0D0A20207D0D0A20200D0A20207661';
wwv_flow_api.g_varchar2_table(8) := '7220726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D0A202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020636F6E736F6C652E6C6F6728276D6170626974735F72657374676A736C61796572';
wwv_flow_api.g_varchar2_table(9) := '2027202B20705F6974656D5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A20200D0A2020';
wwv_flow_api.g_varchar2_table(10) := '766172206D6170203D20726567696F6E2E63616C6C28226765744D61704F626A65637422293B0D0A2020766172206C436F6F6B6965203D20617065782E73746F726167652E676574436F6F6B696528274D6170626974735F52657374474A534C61796572';
wwv_flow_api.g_varchar2_table(11) := '5F27202B20705F6974656D5F69642B20225F22202B202476282270496E7374616E63652229293B0D0A2020766172206C61796F757446756E63203D206E756C6C3B0D0A2020766172207061696E7446756E63203D206E756C6C3B0D0A202076617220696E';
wwv_flow_api.g_varchar2_table(12) := '666F7465787446756E63203D206E756C6C3B0D0A20207661722066696C74657245787072203D206E756C6C3B0D0A2020766172207A6F6F6D52616E6765203D205B302C32345D3B0D0A2020766172207370696E6E6572496D616765203D2022646174613A';
wwv_flow_api.g_varchar2_table(13) := '696D6167652F6769663B6261736536342C52306C474F446C684541415141504D50414C753775356D5A6D544D7A4D3933643352455245514141414864336431565656575A6D5A717171716F6949694F3775376B5245524349694967415241414141414348';
wwv_flow_api.g_varchar2_table(14) := '2F4330354656464E44515642464D69347741774541414141682B51514642774150414377414141414145414151414541456350444A747967366455724665744454496F704D6F53794663787844316B7244384177436B415344496C50615544514C523647';
wwv_flow_api.g_varchar2_table(15) := '31437930536771496B45314951474D7246414B4363475753427A7750416E41776172634B5131354D70544D4A5964315A79554458534447656C42593071496F42682F5A6F594767454C436A6F78435252764951634744316B7A6753416741414351447845';
wwv_flow_api.g_varchar2_table(16) := '4149666B4542516341447741734141414141413841454141414246337779666B4D6B6F744F4A707363524B4A4A7774493451314D416F785130524642773078457668474156525A5A4A68344A674D414551573754574934457747466A4B522B4341514543';
wwv_flow_api.g_varchar2_table(17) := '6A6E38446F4E306B7744747642543846494C414B4A67666F6F3169414741504E56593944474A584E4D49484E2F484A56714978454149666B4542516341447741734141414141424141447741414246727779666D436F6C67697964706151695935783949';
wwv_flow_api.g_varchar2_table(18) := '74683768555264496C30774249687043416A4B494978614155505130684651734143374D4A414C465346693453674334777948797543594E5778483341756853456F746B4E4741414C415071716B696747384D57416A416E4D3441383539347650557949';
wwv_flow_api.g_varchar2_table(19) := '4149666B4542516341447741734141414141424141454141414246337779536B4476644B736464672B4150594957726367324449525141635536444A49436A49736A424545544C454542594C71595344644A6F43476948675A7747344C51434352454345';
wwv_flow_api.g_varchar2_table(20) := '494241646F463568644549577767424A714473374467634B7952485A6C3375557775686D3241624E4E572B4C563779642B4678454149666B4542516341434141734141414141424141446741414245595179596D4D6F56676557517250334E5968424367';
wwv_flow_api.g_varchar2_table(21) := '5A4264414652556B6442494155677556566F315A7357466345474235474D426B456A6943424C3261355A41692B6D32534155524578774B71506975436166426B76425343636D6959524143483542415548414134414C4141414141415141424141414152';
wwv_flow_api.g_varchar2_table(22) := '73304D6E70414B4459726253574D7030785A4976424B5972586A4E6D41444F68414B42695144463567476349434E41794A5477465954426144513048416B6777536D41556A304F6B4D726B5A4D344842674B4B3759544B44524943416F32636C41454968';
wwv_flow_api.g_varchar2_table(23) := '654B63394349536A455654754551724A41534763534251635355464555445155584A4267444257305A6A3334524143483542415548414138414C414141414141514142414141415266384D6E3578714259677256433445456D42634F536641456A536F70';
wwv_flow_api.g_varchar2_table(24) := '4A4D676C6D63516C6742596A45354E4A675A776A4341624F345942414A6A70496A536941516835617979524149444B764A49626E4961676F465246646B5144514B433052427343495546415773543752774734313052384869694B305742774A6A464245';
wwv_flow_api.g_varchar2_table(25) := '4149666B45425163414467417341514142414138414477414142467251796245574144584A4C554848414D4A78494441676E724F6F322B414F6962454D68314C4E363267497870687A6974526F434441594E634E4E3646424C5368616F34577A77484451';
wwv_flow_api.g_varchar2_table(26) := '4B765647686F46417747677446675148454E686F42376E43774852414943304579556343385A77316861334E495267414149666B4542516341447741734141414141424141454141414247447779666E576F6C6A614E595946562B5A7833684345474563';
wwv_flow_api.g_varchar2_table(27) := '75797042744D4A42495370436C41574C66574F44796D494669434A774D444D695A424E41415946715541614E5132453059424958475552414D436F31414173465942426F495363424A4577675356636D50306C6934467763487A2B46704343514D504346';
wwv_flow_api.g_varchar2_table(28) := '494E78454149666B45425163414467417341414142414241414477414142467A5179656D5758594E7161535859327656747733554E6D524F4D344A516F774B4B6C464F736752493641535138496853414446416A414D494D416753594A74427978795149';
wwv_flow_api.g_varchar2_table(29) := '6863456F614263536977656770446776417753424A30414948426F435171494145692F54434941414247684C47384D62634B425167455141682B51514642774150414377414141454145414150414141455866444A53642B71654B355242386644525257';
wwv_flow_api.g_varchar2_table(30) := '467370796F74414166514262664E4C4356555353644B445638396744417763464249426779774D526E6B574267634A55444B535A52494B4150516347775942794141595445454A41414A494762415445512B423445786D4B394344684264385468644877';
wwv_flow_api.g_varchar2_table(31) := '2F416D5559455141682B51514642774150414377414141454144774150414141455876424A514961382B494C53737064486B587853397778463451334C3261544265433073466A68417475794C496A414D6859633247426761534B4775794E6F42447037';
wwv_flow_api.g_varchar2_table(32) := '637A4641676542494B7743366B5743414D78555341466A744E43414146474746357443514C41614A6E57435471486F5245765175514A416B79474245414F773D3D223B0D0A20200D0A20202F2F2067657420757365722D646566696E65642066756E6374';
wwv_flow_api.g_varchar2_table(33) := '696F6E7320666F72207061696E742C206C61796F75742C20696E666F20746578742C20616E642074686520617272617920666F722066696C746572696E672E0D0A2020696628705F7374796C652E636F6E66696746756E6329207B0D0A20202020696620';
wwv_flow_api.g_varchar2_table(34) := '28276C61796F75742720696E20705F7374796C652E636F6E66696746756E6329207B0D0A2020202020206C61796F757446756E63203D20705F7374796C652E636F6E66696746756E632E6C61796F75743B0D0A202020207D0D0A20202020696620282770';
wwv_flow_api.g_varchar2_table(35) := '61696E742720696E20705F7374796C652E636F6E66696746756E6329207B0D0A2020202020207061696E7446756E63203D20705F7374796C652E636F6E66696746756E632E7061696E743B0D0A202020207D0D0A202020206966202827696E666F746578';
wwv_flow_api.g_varchar2_table(36) := '742720696E20705F7374796C652E636F6E66696746756E6329207B0D0A202020202020696E666F7465787446756E63203D20705F7374796C652E636F6E66696746756E632E696E666F746578743B0D0A202020207D0D0A20202020696620282766696C74';
wwv_flow_api.g_varchar2_table(37) := '65722720696E20705F7374796C652E636F6E66696746756E6329207B0D0A20202020202066696C74657245787072203D20705F7374796C652E66696C7465723B0D0A202020207D202020200D0A20207D0D0A20200D0A20202F2F2067657420746865207A';
wwv_flow_api.g_varchar2_table(38) := '6F6F6D2072616E67652C20646F206E6F7420646973706C6179206C61796572206F757473696465206F6620746869732072616E67652E0D0A2020696620286E65772052656745787028275E5B302D395D2B2C5B302D395D2B2427292E7465737428705F73';
wwv_flow_api.g_varchar2_table(39) := '74796C652E7A6F6F6D52616E67652929207B0D0A2020202076617220746F6B203D20705F7374796C652E7A6F6F6D52616E67652E73706C697428222C22293B0D0A20202020766172207A6D696E203D207061727365496E7428746F6B5B305D293B0D0A20';
wwv_flow_api.g_varchar2_table(40) := '202020766172207A6D6178203D207061727365496E7428746F6B5B315D293B0D0A202020200D0A20202020696620287A6D696E203E3D2030202626207A6D6178203C3D20323429207B0D0A2020202020207A6F6F6D52616E67655B305D203D207A6D696E';
wwv_flow_api.g_varchar2_table(41) := '3B0D0A2020202020207A6F6F6D52616E67655B315D203D207A6D61783B0D0A202020207D20656C7365207B0D0A202020202020617065785F616C6572742827436F6E66696775726174696F6E204572726F723A20436F756C64206E6F7420736574207261';
wwv_flow_api.g_varchar2_table(42) := '6E6765206F66205B27202B20705F7469746C65202B20275D207573696E67206F7574206F662072616E6765207A6F6F6D206C696D697473205B27202B20705F7374796C652E7A6F6F6D52616E6765202B20225D2E204D696E206973203020616E64206D61';
wwv_flow_api.g_varchar2_table(43) := '782069732032342E22293B0D0A202020207D0D0A20207D20656C7365207B0D0A20202020617065785F616C6572742827436F6E66696775726174696F6E204572726F723A20436F756C64206E6F74207365742072616E6765206F66205B27202B20705F74';
wwv_flow_api.g_varchar2_table(44) := '69746C65202B20275D207573696E67207A6F6F6D206C696D697473205B27202B20705F7374796C652E7A6F6F6D52616E6765202B20225D22293B0D0A20207D0D0A20200D0A20202F2F207468652027646174616C6F6164696E6727206576656E74207472';
wwv_flow_api.g_varchar2_table(45) := '696767657273206F6E207374617274206F6620746865206C61796572206C6F616420616E6420656E6473206F6E20746865202764617461270D0A20202F2F206576656E742E204F6E207374617274206F66206C6F61642C2073686F7720616E20616E696D';
wwv_flow_api.g_varchar2_table(46) := '617465642020277370696E6E65722720696D6167652E204869646520746865207370696E6E65720D0A20202F2F2061742074686520656E64206F66206C6F61642E0D0A20206D61702E6F6E2827646174616C6F6164696E67272C2066756E6374696F6E28';
wwv_flow_api.g_varchar2_table(47) := '6529207B0D0A2020202069662028652E736F757263654964203D3D20705F6974656D5F6964202B2022736F757263652229207B0D0A2020202020202428272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E7472795F737461747573';
wwv_flow_api.g_varchar2_table(48) := '27292E617474722827737263272C207370696E6E6572496D616765293B0D0A202020207D0D0A20207D293B0D0A20206D61702E6F6E282764617461272C2066756E6374696F6E286529207B0D0A2020202069662028652E736F757263654964203D3D2070';
wwv_flow_api.g_varchar2_table(49) := '5F6974656D5F6964202B2022736F757263652229207B202F2F20262620652E6973536F757263654C6F6164656429207B20202F2F6973536F757263654C6F6164656420646F65736E277420776F726B2E204A757374207370696E7320666F72657665722E';
wwv_flow_api.g_varchar2_table(50) := '0D0A2020202020202428272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E7472795F73746174757327292E617474722827737263272C202727293B0D0A202020207D0D0A20207D293B0D0A20200D0A20202F2F2068616E646C6520';
wwv_flow_api.g_varchar2_table(51) := '6572726F7220627920646973706C6179696E6720697420696E20616E20617065782E6D6573736167652E616C657274206469616C6F672E200D0A202066756E6374696F6E206572726F7266756E63286461746129207B0D0A202020206966202864617461';
wwv_flow_api.g_varchar2_table(52) := '2E736F757263654964203D3D20705F6974656D5F6964202B2027736F757263652729207B0D0A2020202020202F2F207475726E206F6666207370696E6E657220696620697420776173206F6E2E0D0A2020202020202428272327202B20705F6974656D5F';
wwv_flow_api.g_varchar2_table(53) := '6964202B20275F6C6567656E645F656E7472795F73746174757327292E617474722827737263272C202727293B0D0A202020202020617065785F616C6572742827436F6E66696775726174696F6E204572726F723A20436F756C64206E6F74206C6F6164';
wwv_flow_api.g_varchar2_table(54) := '206461746120736F75726365205B27202B20705F7469746C65202B20275D207573696E6720736572766963652075726C205B27202B20705F75726C202B20225D2022202B20646174612E6572726F722E6D657373616765293B0D0A202020207D0D0A2020';
wwv_flow_api.g_varchar2_table(55) := '7D0D0A20206D61702E6F6E28276572726F72272C6572726F7266756E63293B0D0A0D0A202066756E6374696F6E20676574546F6C6572616E63652829207B0D0A09202072657475726E206D61702E676574426F756E647328292E6765744E6F7274685765';
wwv_flow_api.g_varchar2_table(56) := '737428292E64697374616E6365546F286E6577206D61706C69622E4C6E674C6174286D61702E676574426F756E647328292E6765744561737428292C206D61702E676574426F756E647328292E6765744E6F72746828292929202F206D61702E67657443';
wwv_flow_api.g_varchar2_table(57) := '616E76617328292E77696474683B20200D0A20207D0D0A20202F2F20536574207570206D6170206166746572206974206973206C6F616465642E205468697320746869732074686520636F646520746861742069732072756E207265676172646C657373';
wwv_flow_api.g_varchar2_table(58) := '0D0A20202F2F206F662077686574686572206F72206E6F7420616E20696D61676520697320746F206265206C6F616465642E0D0A202066756E6374696F6E2073657475704D61702829207B0D0A0976617220626F756E6473203D206D61702E676574426F';
wwv_flow_api.g_varchar2_table(59) := '756E647328293B0D0A0976617220656E76656C6F7065203D202222202B20626F756E64732E676574576573742829202B20222C22202B20626F756E64732E676574536F7574682829202B20222C22202B20626F756E64732E676574456173742829202B20';
wwv_flow_api.g_varchar2_table(60) := '222C22202B20626F756E64732E6765744E6F72746828293B20200D0A202020207661722075726C203D20705F75726C202B20222F71756572793F663D67656F6A736F6E2677686572653D313E3026746F6B656E3D22202B20705F746F6B656E202B202226';
wwv_flow_api.g_varchar2_table(61) := '6F75744669656C64733D2A22202B20222667656F6D65747279547970653D6573726947656F6D65747279456E76656C6F70652667656F6D657472793D22202B20656E76656C6F70653B0D0A2020202020200D0A202020202F2F2061646420746865206461';
wwv_flow_api.g_varchar2_table(62) := '746120736F7572636520616E642073657420757020746865206C617965722061727261792E0D0A202020206D61702E616464536F7572636528705F6974656D5F6964202B2027736F75726365272C207B0D0A20202020202074797065203A202767656F6A';
wwv_flow_api.g_varchar2_table(63) := '736F6E272C0D0A20202020202064617461203A2075726C202020202020200D0A202020207D293B0D0A0D0A202020202F2F207768656E206D61702076696577206368616E6765732C20696620746865207A6F6F6D206C6576656C20697320696E20746865';
wwv_flow_api.g_varchar2_table(64) := '206D696E2F6D6178207A6F6F6D2072616E67652C207468656E20757064617465206C617965722066726F6D20736F757263650D0A202020202F2F20616E642072656D6F76652074686520737472696B657468726F7567682066726F6D20746865206C6567';
wwv_flow_api.g_varchar2_table(65) := '656E64206C6162656C2E204F74686572776973652C20616464206120737472696B657468726F7567682066726F6D20746865206C6567656E64206C6162656C2E20202020200D0A2020202066756E6374696F6E206F6E657874656E746368616E67652829';
wwv_flow_api.g_varchar2_table(66) := '207B0D0A202020202020696620286D61702E6765745A6F6F6D2829203E3D207A6F6F6D52616E67655B305D202626206D61702E6765745A6F6F6D2829203C3D207A6F6F6D52616E67655B315D29207B0D0A202020202020202076617220626F756E647320';
wwv_flow_api.g_varchar2_table(67) := '3D206D61702E676574426F756E647328293B090D0A202020202020202076617220656E76656C6F7065203D202222202B20626F756E64732E676574576573742829202B20222C22202B20626F756E64732E676574536F7574682829202B20222C22202B20';
wwv_flow_api.g_varchar2_table(68) := '626F756E64732E676574456173742829202B20222C22202B20626F756E64732E6765744E6F72746828293B0D0A20202020202020200D0A09096D61702E676574536F7572636528705F6974656D5F6964202B2027736F7572636527292E73657444617461';
wwv_flow_api.g_varchar2_table(69) := '28705F75726C202B20222F71756572793F663D67656F6A736F6E2677686572653D313E3026746F6B656E3D22202B20705F746F6B656E202B2022266F75744669656C64733D2A22202B20222667656F6D65747279547970653D6573726947656F6D657472';
wwv_flow_api.g_varchar2_table(70) := '79456E76656C6F70652667656F6D657472793D22202B20656E76656C6F7065293B0D0A2020202020202020696620282428272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E7472795F6C6162656C27292E6C656E67746829207B0D';
wwv_flow_api.g_varchar2_table(71) := '0A202020202020202020202428272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E7472795F6C6162656C27292E6373732827746578742D6465636F726174696F6E272C20276E6F6E6527293B0D0A20202020202020207D0D0A2020';
wwv_flow_api.g_varchar2_table(72) := '202020207D20656C7365207B0D0A2020202020202020696620282428272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E7472795F6C6162656C27292E6C656E67746829207B0D0A202020202020202020202428272327202B20705F';
wwv_flow_api.g_varchar2_table(73) := '6974656D5F6964202B20275F6C6567656E645F656E7472795F6C6162656C27292E6373732827746578742D6465636F726174696F6E272C20276C696E652D7468726F75676827293B0D0A20202020202020207D0D0A2020202020207D0D0A202020207D0D';
wwv_flow_api.g_varchar2_table(74) := '0A202020206D61702E6F6E28277A6F6F6D656E64272C206F6E657874656E746368616E6765293B0D0A202020206D61702E6F6E282764726167656E64272C206F6E657874656E746368616E6765293B0D0A202020206D61702E6F6E2827726573697A6527';
wwv_flow_api.g_varchar2_table(75) := '2C206F6E657874656E746368616E6765293B0D0A0D0A20202020766172206C7972203D207B0D0A20202020202027696427203A20705F6974656D5F69642C0D0A202020202020277479706527203A20705F7374796C652E747970652C0D0A202020202020';
wwv_flow_api.g_varchar2_table(76) := '276D61787A6F6F6D27203A207A6F6F6D52616E67655B315D2C0D0A202020202020276D696E7A6F6F6D27203A207A6F6F6D52616E67655B305D2C0D0A20202020202027736F75726365273A20705F6974656D5F6964202B2027736F75726365272C0D0A20';
wwv_flow_api.g_varchar2_table(77) := '2020202020277061696E7427203A207B7D2C0D0A202020202020276C61796F757427203A207B7D2C0D0A202020202020276D6574616461746127203A207B276C617965725F73657175656E636527203A20705F73657175656E63657D0D0A202020207D3B';
wwv_flow_api.g_varchar2_table(78) := '0D0A202020200D0A202020202F2F207365742066696C7465722066726F6D207573657220636F6E66696775726174696F6E2061727261790D0A202020206966202866696C7465724578707220213D206E756C6C29207B0D0A2020202020206C79722E6669';
wwv_flow_api.g_varchar2_table(79) := '6C746572203D2066696C746572457870723B0D0A202020207D0D0A202020200D0A202020202F2F20736574206C61796F75742066756E6374696F6E2066726F6D207573657220636F6E66696775726174696F6E2E0D0A20202020696620286C61796F7574';
wwv_flow_api.g_varchar2_table(80) := '46756E6320213D206E756C6C2029207B0D0A2020202020206C79722E6C61796F7574203D206C61796F757446756E6328293B200D0A202020207D0D0A202020200D0A202020202F2F207365742073796D626F6C2066726F6D207573657220636F6E666967';
wwv_flow_api.g_varchar2_table(81) := '75726174696F6E2E200D0A202020202F2F20546869732077696C6C206F7665727772697465207468652069636F6E2D696D61676520616E642069636F6E2D73697A652061747472696275746573206F66206C61796F75742E0D0A2020202069662028705F';
wwv_flow_api.g_varchar2_table(82) := '7374796C652E74797065203D3D202773796D626F6C2729207B0D0A2020202020206C79722E6C61796F75745B2269636F6E2D696D616765225D203D20705F6974656D5F6964202B20225F69636F6E223B0D0A2020202020206C79722E6C61796F75745B22';
wwv_flow_api.g_varchar2_table(83) := '69636F6E2D73697A65225D203D20312E303B0D0A202020207D200D0A202020200D0A202020202F2F736574207061696E742066756E6374696F6E2066726F6D207573657220636F6E66696775726174696F6E2E0D0A20202020696620287061696E744675';
wwv_flow_api.g_varchar2_table(84) := '6E6320213D206E756C6C29207B0D0A2020202020206C79722E7061696E74203D207061696E7446756E6328293B200D0A202020207D20656C7365207B0D0A202020202F2F6F7665727772697465207061696E206174747269627574657320666F72206C69';
wwv_flow_api.g_varchar2_table(85) := '6E652077696474682C206C696E6520636F6C6F722C206F706163746974792C20616E642066696C6C20636F6C6F722E0D0A2020202069662028705F7374796C652E74797065203D3D202266696C6C2229207B0D0A2020202020206C79722E7061696E745B';
wwv_flow_api.g_varchar2_table(86) := '2266696C6C2D636F6C6F72225D203D20705F7374796C652E66696C6C436F6C6F723B0D0A2020202020206C79722E7061696E745B2266696C6C2D6F75746C696E652D636F6C6F72225D203D20705F7374796C652E7374726F6B65436F6C6F723B0D0A2020';
wwv_flow_api.g_varchar2_table(87) := '202020206C79722E7061696E745B2266696C6C2D6F706163697479225D203D20705F7374796C652E66696C6C4F7061636974793B0D0A202020207D20656C73652069662028705F7374796C652E74797065203D3D20226C696E65222920207B0D0A202020';
wwv_flow_api.g_varchar2_table(88) := '2020206C79722E7061696E745B226C696E652D7769647468225D203D20705F7374796C652E7374726F6B6557696474683B0D0A2020202020206C79722E7061696E745B226C696E652D636F6C6F72225D203D20705F7374796C652E7374726F6B65436F6C';
wwv_flow_api.g_varchar2_table(89) := '6F723B0D0A202020207D0D0A097D0D0A202020200D0A202020202F2F2073657420746865206C6179657220746F20626520696E76697369626C652062792064656661756C742E0D0A202020206C79722E6C61796F75742E7669736962696C697479203D20';
wwv_flow_api.g_varchar2_table(90) := '276E6F6E65273B0D0A0D0A202020202F2F2061646420746865206C6179657220746F20746865206D61702E20757365207468652073657175656E6365206E756D6265722066726F6D207468652070616765200D0A202020202F2F206974656D20746F206F';
wwv_flow_api.g_varchar2_table(91) := '7264657220746865206C61796572732E20486967686572206E756D6265727320617265206C61737420616E6420646973706C61796564206F6E20746F702E0D0A20202020766172206C6179657273203D206D61702E6765745374796C6528292E6C617965';
wwv_flow_api.g_varchar2_table(92) := '72733B0D0A20202020766172206D6170626974736C6179657273203D206C61796572732E66696C7465722866756E6374696F6E2876616C297B0D0A20202020202069662028276D657461646174612720696E2076616C29207B200D0A2020202020202020';
wwv_flow_api.g_varchar2_table(93) := '72657475726E20276C617965725F73657175656E63652720696E2076616C2E6D657461646174613B0D0A2020202020207D20656C7365207B0D0A202020202020202072657475726E2066616C73653B0D0A2020202020207D0D0A202020207D292E6D6170';
wwv_flow_api.g_varchar2_table(94) := '2866756E6374696F6E2876616C29207B72657475726E205B76616C2E6D657461646174612E6C617965725F73657175656E63652C2076616C2E69645D7D293B0D0A20202020696620286D6170626974736C61796572732E6C656E677468203D3D20302920';
wwv_flow_api.g_varchar2_table(95) := '7B0D0A2020202020206D61702E6164644C61796572286C7972293B200D0A202020207D20656C7365207B0D0A2020202020206D6170626974736C61796572732E736F727428293B0D0A202020202020666F722876617220693D303B693C6D617062697473';
wwv_flow_api.g_varchar2_table(96) := '6C61796572732E6C656E6774683B692B2B29207B0D0A202020202020202069662028705F73657175656E6365203C206D6170626974736C61796572735B695D5B305D29207B0D0A202020202020202020206D61702E6164644C61796572286C79722C206D';
wwv_flow_api.g_varchar2_table(97) := '6170626974736C61796572735B695D5B315D293B200D0A2020202020202020202072657475726E3B0D0A20202020202020207D0D0A2020202020207D0D0A2020202020206D61702E6164644C61796572286C7972293B0D0A202020207D0D0A20207D0D0A';
wwv_flow_api.g_varchar2_table(98) := '20200D0A20206D61702E6F6E6365282772656E646572272C2066756E6374696F6E2829207B0D0A202020202F2F204D6170626F782069732066696E6973686564206C6F6164696E672E2047657420746F20776F726B2E0D0A202020202F2F206966207468';
wwv_flow_api.g_varchar2_table(99) := '65207374796C652074797065206973202773796D626F6C272C206C6F616420746865200D0A202020202F2F20696D6167652066697273742C2074686520636F6E74696E756520746865206D61702073657475702E0D0A2020202069662028705F7374796C';
wwv_flow_api.g_varchar2_table(100) := '652E74797065203D3D202273796D626F6C2229207B0D0A2020202020207661722069636F6E3B0D0A20202020202069662028705F7374796C652E69636F6E496D6167652E696E6465784F6628272F2729203E202D3129207B0D0A20202020202020206963';
wwv_flow_api.g_varchar2_table(101) := '6F6E203D20705F7374796C652E69636F6E496D6167653B0D0A2020202020207D20656C7365207B0D0A202020202020202069636F6E203D20705F69636F6E5F75726C202B20705F7374796C652E69636F6E496D616765202B20222E706E67223B0D0A2020';
wwv_flow_api.g_varchar2_table(102) := '202020207D0D0A2020202020206D61702E6C6F6164496D6167652869636F6E2C2066756E6374696F6E286572726F722C20696D61676529207B20200D0A2020202020202020696620286572726F7229207B0D0A20202020202020202020617065785F616C';
wwv_flow_api.g_varchar2_table(103) := '6572742827436F6E66696775726174696F6E204572726F723A204C61796572205B27202B20705F7469746C65202B20275D2049636F6E205B27202B20705F7374796C652E69636F6E496D616765202B20275D20206661696C656420746F206C6F61642E20';
wwv_flow_api.g_varchar2_table(104) := '46697820496D6167652049636F6E2073657474696E6727293B72657475726E3B0D0A20202020202020207D0D0A20202020202020206D61702E616464496D61676528705F6974656D5F6964202B20225F69636F6E222C20696D6167652C207B0D0A202020';
wwv_flow_api.g_varchar2_table(105) := '2020202020202020202020202022736466223A202274727565220D0A2020202020202020202020207D293B0D0A202020202020202073657475704D617028293B0D0A2020202020207D293B0D0A202020207D20656C7365207B0D0A202020202020736574';
wwv_flow_api.g_varchar2_table(106) := '75704D617028293B0D0A202020207D0D0A202020200D0A202020202F2F205570646174652041504558206C6567656E6420666F72206D6170626F782E2057616974206F6E65207365636F6E6420666F7220697420746F2072656E6465722C206669727374';
wwv_flow_api.g_varchar2_table(107) := '2E2041646420656E747269657320666F722074686520706C7567696E206C617965722E0D0A202020202F2F20557365206120636F6F6B69652076616C756520746F2064657465726D696E652069662074686520636865636B626F782076616C7565207368';
wwv_flow_api.g_varchar2_table(108) := '6F756C64207374617274206F6E206F72206F66662E0D0A2020202073657454696D656F75742866756E6374696F6E2829207B0D0A202020202020766172206C6567656E64203D20617065782E6A517565727928272327202B20705F726567696F6E5F6964';
wwv_flow_api.g_varchar2_table(109) := '202B20275F6C6567656E6427293B0D0A2020202020202428273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E27202B200D0A';
wwv_flow_api.g_varchar2_table(110) := '2020202020202020273C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069643D2227202B20705F69';
wwv_flow_api.g_varchar2_table(111) := '74656D5F6964202B20275F6C6567656E645F656E74727927202B202722207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B20705F636865636B626F785F636F6C6F72202B2027223E27202B0D0A202020';
wwv_flow_api.g_varchar2_table(112) := '2020202020273C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C22206C6179657269643D2227202B20705F6974656D5F6964202B2027222069643D2227202B20705F6974656D5F6964202B20275F6C6567656E';
wwv_flow_api.g_varchar2_table(113) := '645F656E7472795F6C6162656C27202B20272220666F723D2227202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927202B2027223E27202B20705F7469746C65202B20273C696D672069643D2227202B20705F6974656D5F696420';
wwv_flow_api.g_varchar2_table(114) := '2B20275F6C6567656E645F656E7472795F737461747573222F3E3C2F6C6162656C3E27202B0D0A2020202020202020273C2F6469763E27292E617070656E64546F286C6567656E64293B0D0A2020202020200D0A202020202020696620286D61702E6765';
wwv_flow_api.g_varchar2_table(115) := '745A6F6F6D2829203C207A6F6F6D52616E67655B305D207C7C206D61702E6765745A6F6F6D2829203E207A6F6F6D52616E67655B315D29207B0D0A20202020202020202428272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E7472';
wwv_flow_api.g_varchar2_table(116) := '795F6C6162656C27292E6373732827746578742D6465636F726174696F6E272C20276C696E652D7468726F75676827293B0D0A2020202020207D0D0A0D0A202020202020696620286C436F6F6B6965203D3D202776697369626C652729207B0D0A202020';
wwv_flow_api.g_varchar2_table(117) := '20202020206D61702E7365744C61796F757450726F706572747928705F6974656D5F69642C20277669736962696C697479272C202776697369626C6527293B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964';
wwv_flow_api.g_varchar2_table(118) := '202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2074727565293B0D0A2020202020207D20656C736520696620286C436F6F6B6965203D3D20276E6F6E652729207B0D0A20202020202020206D61702E7365744C61';
wwv_flow_api.g_varchar2_table(119) := '796F757450726F706572747928705F6974656D5F69642C20277669736962696C697479272C20276E6F6E6527293B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E747279';
wwv_flow_api.g_varchar2_table(120) := '27292E70726F702827636865636B6564272C2066616C7365293B0D0A2020202020207D20656C7365207B0D0A202020202020202069662028705F7374796C652E696E69745669736962696C697479203D3D2027592729207B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(121) := '6D61702E7365744C61796F757450726F706572747928705F6974656D5F69642C20277669736962696C697479272C202776697369626C6527293B0D0A20202020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20';
wwv_flow_api.g_varchar2_table(122) := '275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2074727565293B0D0A20202020202020207D20656C7365207B0D0A202020202020202020206D61702E7365744C61796F757450726F706572747928705F6974656D5F6964';
wwv_flow_api.g_varchar2_table(123) := '2C20277669736962696C697479272C20276E6F6E6527293B0D0A20202020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2066';
wwv_flow_api.g_varchar2_table(124) := '616C7365293B0D0A20202020202020207D0D0A2020202020207D0D0A202020200D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E6368616E67652866756E637469';
wwv_flow_api.g_varchar2_table(125) := '6F6E2865297B0D0A2020202020202020766172206362203D20617065782E6A51756572792874686973293B0D0A20202020202020207661722063626964203D2063622E617474722827696427293B0D0A202020200D0A2020202020202020696620286362';
wwv_flow_api.g_varchar2_table(126) := '2E697328273A636865636B6564272929207B0D0A202020202020202020206D61702E7365744C61796F757450726F706572747928636269642E73756273747228302C20636269642E6C656E677468202D20275F6C6567656E645F656E747279272E6C656E';
wwv_flow_api.g_varchar2_table(127) := '677468292C20277669736962696C697479272C202776697369626C6527293B0D0A20202020202020202020617065782E73746F726167652E736574436F6F6B696528274D6170626974735F52657374474A534C617965725F27202B20705F6974656D5F69';
wwv_flow_api.g_varchar2_table(128) := '642B20225F22202B202476282270496E7374616E636522292C202776697369626C6527293B0920200D0A20202020202020207D20656C7365207B0D0A202020202020202020206D61702E7365744C61796F757450726F706572747928636269642E737562';
wwv_flow_api.g_varchar2_table(129) := '73747228302C20636269642E6C656E677468202D20275F6C6567656E645F656E747279272E6C656E677468292C20277669736962696C697479272C20276E6F6E6527293B0D0A20202020202020202020617065782E73746F726167652E736574436F6F6B';
wwv_flow_api.g_varchar2_table(130) := '696528274D6170626974735F52657374474A534C617965725F27202B20705F6974656D5F69642B20225F22202B202476282270496E7374616E636522292C20276E6F6E6527293B0920200D0A20202020202020207D20200D0A2020202020207D293B0D0A';
wwv_flow_api.g_varchar2_table(131) := '202020207D2C2031303030293B0D0A202020200D0A202020202F2F204368616E67652074686520637572736F7220746F206120706F696E746572207768656E20746865206D6F757365206973206F7665722074686520706C61636573206C617965722E0D';
wwv_flow_api.g_varchar2_table(132) := '0A202020206D61702E6F6E28276D6F757365656E746572272C20705F6974656D5F69642C2066756E6374696F6E202829207B0D0A2020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D2027706F696E746572273B0D';
wwv_flow_api.g_varchar2_table(133) := '0A202020207D293B0D0A2020200D0A202020202F2F204368616E6765206974206261636B20746F206120706F696E746572207768656E206974206C65617665732E0D0A202020206D61702E6F6E28276D6F7573656C65617665272C20705F6974656D5F69';
wwv_flow_api.g_varchar2_table(134) := '642C2066756E6374696F6E202829207B0D0A2020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D2027273B0D0A202020207D293B0D0A202020200D0A202020202F2F207768656E2061206665617475726520697320';
wwv_flow_api.g_varchar2_table(135) := '636C69636B65642C2073686F7720696E666F20626F7820706F7075702E0D0A202020202F2F20696620757365722070726F766964656420616E20696E666F746578742066756E6374696F6E2C207472616E73666F726D2074686520746578740D0A202020';
wwv_flow_api.g_varchar2_table(136) := '202F2F207573696E6720746861742066756E6374696F6E2C206F746865727769736520646973706C61792074686520696E666F207573696E67203C646C3E2E0D0A202020206D61702E6F6E2827636C69636B272C20705F6974656D5F69642C2066756E63';
wwv_flow_api.g_varchar2_table(137) := '74696F6E286529207B0D0A20202020202076617220636F6F7264696E61746573203D20652E66656174757265735B305D2E67656F6D657472792E636F6F7264696E617465732E736C69636528293B0D0A202020202020766172206465736372697074696F';
wwv_flow_api.g_varchar2_table(138) := '6E203D20652E66656174757265735B305D2E70726F706572746965732E4C4142454C3B0D0A202020202020766172207478743B0D0A20202020202069662028696E666F7465787446756E6320213D206E756C6C29207B0D0A202020202020202074787420';
wwv_flow_api.g_varchar2_table(139) := '3D20696E666F7465787446756E6328652E66656174757265735B305D293B0D0A2020202020207D20656C7365207B0D0A2020202020202020747874203D20273C646C207374796C653D2270616464696E673A203570783B223E273B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(140) := '20666F722028766172206B657920696E20652E66656174757265735B305D2E70726F7065727469657329207B0D0A20202020202020202020747874203D20747874202B20223C64743E3C7374726F6E673E22202B206B6579202B20223C2F7374726F6E67';
wwv_flow_api.g_varchar2_table(141) := '3E3C2F64743E3C64643E22202B2020652E66656174757265735B305D2E70726F706572746965735B6B65795D202B20223C2F64643E223B0D0A20202020202020207D0D0A2020202020202020747874203D20747874202B20223C2F646C3E223B0D0A2020';
wwv_flow_api.g_varchar2_table(142) := '202020207D200D0A0D0A2020202020202F2F207365742074686520706F70757020636F6F7264696E6174657320746F20636C69636B65642066656174757265277320666972737420706F696E742E20466C617474656E20617272617920696E2063617365';
wwv_flow_api.g_varchar2_table(143) := '206F66206C696E6573206F72206D756C746967656F6D657472792E0D0A092020636F6E737420636F6F7264696E61746573666C74203D20636F6F7264696E617465732E666C61742833293B0D0A2020202020206E6577206D61706C69622E506F70757028';
wwv_flow_api.g_varchar2_table(144) := '292E7365744C6E674C6174285B636F6F7264696E61746573666C745B305D2C20636F6F7264696E61746573666C745B315D5D292E73657448544D4C28747874292E616464546F286D6170293B0D0A202020207D293B0D0A20207D293B0D0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(329367396370067936)
,p_plugin_id=>wwv_flow_api.id(225569669771101768)
,p_file_name=>'mapbits-restgjslayer.js'
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
