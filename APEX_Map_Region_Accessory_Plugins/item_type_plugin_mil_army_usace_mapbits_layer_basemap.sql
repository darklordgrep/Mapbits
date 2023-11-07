prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run the script connected to SQL*Plus as the owner (parsing schema)
-- of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2022.10.07'
,p_release=>'22.2.8'
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
--   Date and Time:   16:34 Tuesday November 7, 2023
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 274089793331619085
--   Manifest End
--   Version:         22.2.8
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_layer_basemap
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(274089793331619085)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LAYER.BASEMAP'
,p_display_name=>'Mapbits Basemap'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-basemap.js'
,p_css_file_urls=>'#PLUGIN_FILES#mapbits-basemap.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure mapbits_basemap (',
'    p_item   in            apex_plugin.t_item,',
'    p_plugin in            apex_plugin.t_plugin,',
'    p_param  in            apex_plugin.t_item_render_param,',
'    p_result in out nocopy apex_plugin.t_item_render_result ) is',
'    l_region_id varchar2(4000); ',
'    l_url varchar2(4000) := p_item.attribute_01;',
'    l_title varchar2(4000) := p_item.attribute_03;',
'    l_icon varchar2(100) := p_item.attribute_09;',
'    l_tooltip varchar2(4000) := p_item.attribute_10;',
'    l_default_title varchar2(4000) := p_plugin.attribute_11;',
'    l_default_icon varchar2(100) := p_plugin.attribute_12;',
'    l_default_tooltip varchar2(4000) := p_plugin.attribute_13;',
'    l_show_vector varchar2(5) := p_item.attribute_08;',
'    l_initially_visible varchar2(5) := p_item.attribute_14;',
'    l_maxzoom p_item.attribute_07%type := p_item.attribute_07;',
'    l_error varchar2(4000) := '''';',
'    l_startingBasemap varchar2(800);',
'    l_sequence_no   number;',
'begin',
'  begin',
'    select nvl(r.static_id, ''R'' || r.region_id), i.display_sequence into l_region_id, l_sequence_no',
'      from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then',
'      l_error := l_error || ''ERROR:  Mapbits Basemap Item ['' || p_item.name || ''] is not associated with a Map region.'';',
'  end;',
'  htp.p(''<div id="'' || p_item.name || ''" name="'' || p_item.name || ''"></div>'');',
'',
'  if l_error is not null then',
'    apex_javascript.add_onload_code(',
'      p_code => ''mapbits_basemap_error({''',
'        || apex_javascript.add_attribute(''error'', l_error)',
'        || ''});'',',
'      p_key => ''MIL.ARMY.USACE.MAPBITS.LAYER.BASEMAP'' || p_item.name);',
'  else',
'    apex_javascript.add_onload_code(p_code => ''apex.jQuery("#'' || l_region_id || ''").on("spatialmapinitialized", function(){',
'      mapbits_basemap({''',
'        || apex_javascript.add_attribute(''itemId'', p_item.name)',
'        || apex_javascript.add_attribute(''regionId'', l_region_id)',
'        || apex_javascript.add_attribute(''sequenceNumber'', l_sequence_no)',
'        || apex_javascript.add_attribute(''title'', l_title)',
'        || apex_javascript.add_attribute(''icon'', l_icon)',
'        || apex_javascript.add_attribute(''tooltip'', l_tooltip)',
'        || apex_javascript.add_attribute(''defaultTitle'', l_default_title)',
'        || apex_javascript.add_attribute(''defaultIcon'', l_default_icon)',
'        || apex_javascript.add_attribute(''defaultTooltip'', l_default_tooltip)',
'        || apex_javascript.add_attribute(''url'', l_url)',
'        || apex_javascript.add_attribute(''maxzoom'', to_number(l_maxzoom))',
'        || apex_javascript.add_attribute(''showVector'', l_show_vector)',
'        || apex_javascript.add_attribute(''initiallyVisible'', l_initially_visible)',
'        || ''});});'',',
'      p_key => ''MIL.ARMY.USACE.MAPBITS.LAYER.BASEMAP'' || p_item.name);',
'  end if;',
'end;'))
,p_api_version=>2
,p_render_function=>'mapbits_basemap'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The Mapbits Basemap plugin adds support for switching the default basemap with an alternative background. To use this plugin, add it as an item under an APEX Map region. The resulting layer will always be rendered behind everything else, regardless o'
||'f the item''s position.',
'',
'When a Basemap is added to a Map region, a toggle will appear on the map allowing a user to switch between the existing default Map region basemap and the basemap defined in the plugin item. This plugin includes attributes for the icon, title, and to'
||'oltip for plugin item-defined basemap. The Map region default basemap icon, title, and tooltip can be configured in the Mapbits Basemap Component Settings. Multiple Basemaps can be added to the same Map region. The last basemap toggle choice is prese'
||'rved in a cookie and that last basemap is rendered the next time the page is next loaded.'))
,p_version_identifier=>'4.6.20231107'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 Layer - Basemap',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_basemap.sql 18694 2023-11-07 22:47:20Z b2eddjw9 $',
'Date     : $Date: 2023-11-07 16:47:20 -0600 (Tue, 07 Nov 2023) $',
'Revision : $Revision: 18694 $',
'Requires : Application Express >= 22.2',
'',
'Version 4.6 Updates:',
'11/07/2023 - Fixed the cookie that remembers which basemap you chose in the case of multiple maps per application. The cookie is now stored per map region. Improved error handling when the item is not placed in a map region.',
'',
'Version 4.5 Updates:',
'10/27/2023 - Moved default basemap configuration to the Component Settings. Added space between icon and title. Added documentation. ',
'10/25/2023 - Initial Implementation. Includes attributes basemap title, icon, and tooltip in the basemap toolbar for both the plugin''s defined basemap and the default basemap. Support for multiple simultaneous basemaps.  '))
,p_files_version=>49
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274555702113943657)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Default Basemap Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Name of default Map region basemap layer to be displayed in the toggle section under the map used to turn layers on and off.',
'',
'The default Map region basemap is the basemap the Map region would use if there were no Basemap plugin. In the light version of APEX 22, this basemap is OSM Positron.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274559597360027112)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Default Basemap Icon'
,p_attribute_type=>'ICON'
,p_is_required=>false
,p_default_value=>'fa-line-map'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Icon of default Map Region basemap layer to be displayed in the toggle section under the map used to turn layers on and off.',
'',
'The default Map region basemap is the basemap the Map region would use if there were no Basemap plugin. In the light version of APEX 22, this basemap is OSM Positron.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274560710102034496)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_prompt=>'Default Basemap Tooltip'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'Default Basemap'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Tooltip of the default Map Region basemap layer to be displayed when a user hovers over the layer''s button in the basemap toggle section.',
'',
'The default Map region basemap is the basemap the Map region would use if there were no Basemap plugin. In the light version of APEX 22, this basemap is OSM Positron.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274091419950629782)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Tile URL'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'https://basemap.nationalmap.gov/arcgis/services/USGSImageryOnly/MapServer/WMSServer?bbox={bbox-epsg-3857}&format=image/png&service=WMS&version=1.1.1&request=GetMap&srs=EPSG:3857&transparent=true&width=256&height=256&styles=&layers=0'
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Tile servers must include {z} {y}, and {x} replacement tokens:',
'',
'<pre>https://tile.openstreetmap.org/{z}/{x}/{y}.png</pre>',
'',
'If the URL corresponds to a WMS server, it must support EPSG:3857 (or EPSG:900913). The server URL should contain a "{bbox-epsg-3857}" replacement token to supply the bbox parameter.',
'',
'<pre>',
'https://basemap.nationalmap.gov/arcgis/services/USGSTNMBlank/MapServer/WMSServer?bbox={bbox-epsg-3857}&format=image/png&service=WMS&version=1.1.1&request=GetMap&srs=EPSG:3857&transparent=true&width=256&height=256&styles=&layers=0',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'URL of the tile or web map service to use as the source for the basemap. ',
'',
'A raster source is created using the url as the "tiles" argument. For more information on how to define this url, refer to the Maplibre Style Spec Sources (https://maplibre.org/maplibre-style-spec/sources/).'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274092150022643386)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'Imagery'
,p_is_translatable=>false
,p_help_text=>'Name of layer to be displayed in the toggle section under the map used to turn layers on and off.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274612534515565494)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Max Scale'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'16'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'The maximum zoom level to fetch tiles. Beyond this level, the imagery will be scaled. If you experience errors rendering at large scales, the basemap may not support that zoom level. You can reduce this value to avoid the issue.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274614917764568515)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>10
,p_display_value=>'0 - The Earth'
,p_return_value=>'0'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274615330560569800)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>20
,p_display_value=>'1'
,p_return_value=>'1'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274615725818570288)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>30
,p_display_value=>'2'
,p_return_value=>'2'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274616096148571743)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>40
,p_display_value=>'3 - A Continent'
,p_return_value=>'3'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274616453469573299)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>50
,p_display_value=>'4 - Large Islands'
,p_return_value=>'4'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274616842275573784)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>60
,p_display_value=>'5'
,p_return_value=>'5'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274617328789575083)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>70
,p_display_value=>'6 - Large Rivers'
,p_return_value=>'6'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274619218496576239)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>80
,p_display_value=>'7'
,p_return_value=>'7'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274619605805576639)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>90
,p_display_value=>'8'
,p_return_value=>'8'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274619947586577024)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>100
,p_display_value=>'9'
,p_return_value=>'9'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274620401133579490)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>110
,p_display_value=>'10 - Large Roads'
,p_return_value=>'10'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274620907615579920)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>120
,p_display_value=>'11'
,p_return_value=>'11'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274621309321580271)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>130
,p_display_value=>'12'
,p_return_value=>'12'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274621729636580668)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>140
,p_display_value=>'13'
,p_return_value=>'13'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274623020161581059)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>150
,p_display_value=>'14'
,p_return_value=>'14'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274623964705581860)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>160
,p_display_value=>'15 - Buildings'
,p_return_value=>'15'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274624413117582313)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>170
,p_display_value=>'16'
,p_return_value=>'16'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274624825430582831)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>180
,p_display_value=>'17'
,p_return_value=>'17'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274625207637583274)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>190
,p_display_value=>'18'
,p_return_value=>'18'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274625572003583723)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>200
,p_display_value=>'19'
,p_return_value=>'19'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274625995922584193)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>210
,p_display_value=>'20'
,p_return_value=>'20'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274626426256584541)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>220
,p_display_value=>'21'
,p_return_value=>'21'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(274626813182585048)
,p_plugin_attribute_id=>wwv_flow_imp.id(274612534515565494)
,p_display_sequence=>230
,p_display_value=>'22'
,p_return_value=>'22'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274096952570913751)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Show Vector Overlay'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Show place names, streets, and roads over the basemap. Disable if the base map already contains these things.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274097299717916151)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>33
,p_prompt=>'Icon'
,p_attribute_type=>'ICON'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Icon of layer to be displayed in the toggle section under the map used to turn layers on and off.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274097638647919307)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>36
,p_prompt=>'Tooltip'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Tooltip to be displayed when a user hovers over the layer''s button in the basemap toggle section.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(274100694469932769)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>100
,p_prompt=>'Initially Visible?'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If Y, display the basemap defined by this plugin item instead of the default basemap by default. If N, display the Map region default basemap by default.',
'',
'If multiple Basemap items are defined for a Map region, then the Basemap plugin item with the lowest sequence id in the region and the ''Initially Visible?'' attribute set to ''Y'' shall be displayed by default. If no Basemap has this attribute set to Y,'
||' then the Map region default basemap is used by default.',
'',
'The default Map region basemap is the basemap the Map region would use if there were no Basemap plugin. In the light version of APEX 22, this basemap is OSM Positron.'))
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F424153454D41505F53594D424F4C3D53796D626F6C28293B66756E6374696F6E206D6170626974735F626173656D61705F6572726F72287B6572726F723A657D297B617065782E6D6573736167652E73686F77457272';
wwv_flow_imp.g_varchar2_table(2) := '6F7273285B7B747970653A226572726F72222C6C6F636174696F6E3A2270616765222C6D6573736167653A657D5D297D66756E6374696F6E206D6170626974735F626173656D6170287B6974656D49643A652C726567696F6E49643A742C7469746C653A';
wwv_flow_imp.g_varchar2_table(3) := '612C69636F6E3A6F2C746F6F6C7469703A6E2C64656661756C745469746C653A722C64656661756C7449636F6E3A692C64656661756C74546F6F6C7469703A6C2C75726C3A732C6D61787A6F6F6D3A632C6572726F723A702C73686F77566563746F723A';
wwv_flow_imp.g_varchar2_table(4) := '792C696E697469616C6C7956697369626C653A647D297B636F6E7374206D3D224D6170626974735F426173656D61705F222B743B66756E6374696F6E205F2865297B617065782E6A5175657279282866756E6374696F6E28297B617065782E6D65737361';
wwv_flow_imp.g_varchar2_table(5) := '67652E616C6572742865292C636F6E736F6C652E6C6F672865297D29297D69662870295F2870293B656C73657B76617220753D617065782E726567696F6E2874293B6966286E756C6C213D75297B76617220673D752E63616C6C28226765744D61704F62';
wwv_flow_imp.g_varchar2_table(6) := '6A65637422293B6966282266756E6374696F6E223D3D747970656F6620672E7365745472616E73666F726D52657175657374297B636F6E737420623D6E65772052656745787028225E222B732E7265706C616365282F5B5C2D5C5C5E242A2B3F2E28297C';
wwv_flow_imp.g_varchar2_table(7) := '5B5C5D5D2F672C225C5C242622292E7265706C616365282F7B2E2A3F7D2F672C222E2A22292B222422292C533D672E5F726571756573744D616E616765723F2E5F7472616E73666F726D52657175657374466E3B672E7365745472616E73666F726D5265';
wwv_flow_imp.g_varchar2_table(8) := '7175657374282828652C74293D3E622E746573742865293F7B75726C3A652C63726564656E7469616C733A226F6D6974227D3A2266756E6374696F6E223D3D747970656F6620533F5328652C74293A7B75726C3A657D29297D76617220683D617065782E';
wwv_flow_imp.g_varchar2_table(9) := '73746F726167652E676574436F6F6B6965286D293B696628672E6F6E636528226572726F72222C2866756E6374696F6E2874297B742E736F7572636549643D3D652B222D736F757263652226265F28742E6572726F722E6D6573736167652B225C6E222B';
wwv_flow_imp.g_varchar2_table(10) := '73297D29292C21675B4D4150424954535F424153454D41505F53594D424F4C5D297B636F6E737420663D5B7B69643A22626F756E64617279222C747970653A226C696E65222C736F757263653A226F70656E6D617074696C6573222C22736F757263652D';
wwv_flow_imp.g_varchar2_table(11) := '6C61796572223A22626F756E64617279222C7061696E743A7B226C696E652D636F6C6F72223A2223636363222C226C696E652D7769647468223A312C226C696E652D646173686172726179223A5B352C355D7D7D2C7B69643A22686967687761792D6C69';
wwv_flow_imp.g_varchar2_table(12) := '6E65222C747970653A226C696E65222C736F757263653A226F70656E6D617074696C6573222C22736F757263652D6C61796572223A227472616E73706F72746174696F6E222C6D696E7A6F6F6D3A31322C7061696E743A7B226C696E652D636F6C6F7222';
wwv_flow_imp.g_varchar2_table(13) := '3A2223343434222C226C696E652D7769647468223A5B226D61746368222C5B22676574222C22636C617373225D2C226D6F746F72776179222C312C2E355D7D7D2C7B69643A22706C616365222C747970653A2273796D626F6C222C736F757263653A226F';
wwv_flow_imp.g_varchar2_table(14) := '70656E6D617074696C6573222C22736F757263652D6C61796572223A22706C616365222C66696C7465723A5B22213D222C5B22676574222C22636C617373225D2C22636F6E74696E656E74225D2C6C61796F75743A7B22746578742D6669656C64223A5B';
wwv_flow_imp.g_varchar2_table(15) := '22636F616C65736365222C5B22676574222C226E616D655F656E225D2C5B22676574222C226E616D65225D5D2C22746578742D666F6E74223A5B224D6574726F706F6C697320426F6C64222C224E6F746F2053616E7320426F6C64225D2C22746578742D';
wwv_flow_imp.g_varchar2_table(16) := '7472616E73666F726D223A5B226D61746368222C5B22676574222C22636C617373225D2C5B22636F756E747279222C227374617465225D2C22757070657263617365222C226E6F6E65225D2C22746578742D73697A65223A5B22696E746572706F6C6174';
wwv_flow_imp.g_varchar2_table(17) := '65222C5B226C696E656172225D2C5B227A6F6F6D225D2C362C5B226D61746368222C5B22676574222C22636C617373225D2C22636F756E747279222C31322C227374617465222C31302C2263697479222C31302C385D2C31302C5B226D61746368222C5B';
wwv_flow_imp.g_varchar2_table(18) := '22676574222C22636C617373225D2C22636F756E747279222C31342C227374617465222C31342C2263697479222C31312C31305D2C31322C5B226D61746368222C5B22676574222C22636C617373225D2C22636F756E747279222C31362C227374617465';
wwv_flow_imp.g_varchar2_table(19) := '222C31342C2263697479222C31342C31305D2C31342C5B226D61746368222C5B22676574222C22636C617373225D2C22636F756E747279222C31362C227374617465222C31342C2263697479222C31362C31325D5D7D2C7061696E743A7B22746578742D';
wwv_flow_imp.g_varchar2_table(20) := '636F6C6F72223A22626C61636B222C22746578742D68616C6F2D636F6C6F72223A2223646464222C22746578742D68616C6F2D7769647468223A312E357D7D2C7B69643A2277617465722D6E616D652D706F696E74222C747970653A2273796D626F6C22';
wwv_flow_imp.g_varchar2_table(21) := '2C736F757263653A226F70656E6D617074696C6573222C22736F757263652D6C61796572223A2277617465725F6E616D65222C66696C7465723A5B223D3D222C222474797065222C22506F696E74225D2C6C61796F75743A7B22746578742D6669656C64';
wwv_flow_imp.g_varchar2_table(22) := '223A5B22636F616C65736365222C5B22676574222C226E616D655F656E225D2C5B22676574222C226E616D65225D5D2C22746578742D666F6E74223A5B224D6574726F706F6C697320426F6C64222C224E6F746F2053616E7320426F6C64225D2C227465';
wwv_flow_imp.g_varchar2_table(23) := '78742D73697A65223A31327D2C7061696E743A7B22746578742D636F6C6F72223A2223313134222C22746578742D68616C6F2D636F6C6F72223A2223646464222C22746578742D68616C6F2D7769647468223A312E357D7D2C7B69643A2277617465722D';
wwv_flow_imp.g_varchar2_table(24) := '6E616D652D6C696E65222C747970653A2273796D626F6C222C736F757263653A226F70656E6D617074696C6573222C22736F757263652D6C61796572223A227761746572776179222C66696C7465723A5B223D3D222C222474797065222C224C696E6553';
wwv_flow_imp.g_varchar2_table(25) := '7472696E67225D2C6C61796F75743A7B2273796D626F6C2D706C6163656D656E74223A226C696E65222C22746578742D6669656C64223A5B22636F616C65736365222C5B22676574222C226E616D655F656E225D2C5B22676574222C226E616D65225D5D';
wwv_flow_imp.g_varchar2_table(26) := '2C22746578742D666F6E74223A5B224D6574726F706F6C697320426F6C64222C224E6F746F2053616E7320426F6C64225D2C22746578742D73697A65223A31327D2C7061696E743A7B22746578742D636F6C6F72223A22626C61636B222C22746578742D';
wwv_flow_imp.g_varchar2_table(27) := '68616C6F2D636F6C6F72223A2223636366222C22746578742D68616C6F2D7769647468223A312E357D7D2C7B69643A2268696768776179222C747970653A2273796D626F6C222C736F757263653A226F70656E6D617074696C6573222C22736F75726365';
wwv_flow_imp.g_varchar2_table(28) := '2D6C61796572223A227472616E73706F72746174696F6E5F6E616D65222C66696C7465723A5B223D3D222C222474797065222C224C696E65537472696E67225D2C6D696E7A6F6F6D3A31322C6C61796F75743A7B2273796D626F6C2D706C6163656D656E';
wwv_flow_imp.g_varchar2_table(29) := '74223A226C696E65222C22746578742D6669656C64223A5B22636F616C65736365222C5B22676574222C226E616D655F656E225D2C5B22676574222C226E616D65225D5D2C22746578742D666F6E74223A5B224D6574726F706F6C697320426F6C64222C';
wwv_flow_imp.g_varchar2_table(30) := '224E6F746F2053616E7320426F6C64225D2C22746578742D73697A65223A31307D2C7061696E743A7B22746578742D636F6C6F72223A2223333333222C22746578742D68616C6F2D636F6C6F72223A2223636363222C22746578742D68616C6F2D776964';
wwv_flow_imp.g_varchar2_table(31) := '7468223A312E357D7D5D3B66756E6374696F6E20772865297B6520696E20675B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F7273262628675B4D4150424954535F424153454D4150';
wwv_flow_imp.g_varchar2_table(32) := '5F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F72735B655D28292C64656C65746520675B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F72735B655D29';
wwv_flow_imp.g_varchar2_table(33) := '3B636F6E737420743D6E756C6C213D3D65262621286520696E20675B4D4150424954535F424153454D41505F53594D424F4C5D2E736B6970566563746F72293B666F7228636F6E73742065206F66206629672E7365744C61796F757450726F7065727479';
wwv_flow_imp.g_varchar2_table(34) := '28652E69642C227669736962696C697479222C743F2276697369626C65223A226E6F6E6522293B666F7228636F6E73742074206F6620675B4D4150424954535F424153454D41505F53594D424F4C5D2E6C617965727329672E6765744C6179657228742B';
wwv_flow_imp.g_varchar2_table(35) := '222D6261636B67726F756E6422292626672E7365744C61796F757450726F706572747928742B222D6261636B67726F756E64222C227669736962696C697479222C743D3D3D653F2276697369626C65223A226E6F6E6522293B666F7228636F6E73742074';
wwv_flow_imp.g_varchar2_table(36) := '206F66204229672E7365744C61796F757450726F706572747928742C227669736962696C697479222C6E756C6C3D3D3D653F2276697369626C65223A226E6F6E6522297D666F7228636F6E73742078206F66206629782E6C61796F75747C7C28782E6C61';
wwv_flow_imp.g_varchar2_table(37) := '796F75743D7B7D292C782E6C61796F75742E7669736962696C6974793D226E6F6E65222C782E69643D226D6170626974732D626173656D61702D222B782E69642C672E6164644C6179657228782C226261636B67726F756E6422293B636F6E737420423D';
wwv_flow_imp.g_varchar2_table(38) := '5B226261636B67726F756E64222C227061726B222C227761746572222C226C616E64636F7665725F6963655F7368656C66222C226C616E64636F7665725F676C6163696572222C226C616E647573655F7265736964656E7469616C222C226C616E64636F';
wwv_flow_imp.g_varchar2_table(39) := '7665725F776F6F64222C227761746572776179222C2277617465725F6E616D65222C226275696C64696E67222C2274756E6E656C5F6D6F746F727761795F636173696E67222C2274756E6E656C5F6D6F746F727761795F696E6E6572222C226165726F77';
wwv_flow_imp.g_varchar2_table(40) := '61792D74617869776179222C226165726F7761792D72756E7761792D636173696E67222C226165726F7761792D61726561222C226165726F7761792D72756E776179222C22726F61645F617265615F70696572222C22726F61645F70696572222C226869';
wwv_flow_imp.g_varchar2_table(41) := '67687761795F70617468222C22686967687761795F6D696E6F72222C22686967687761795F6D616A6F725F636173696E67222C22686967687761795F6D616A6F725F696E6E6572222C22686967687761795F6D616A6F725F737562746C65222C22686967';
wwv_flow_imp.g_varchar2_table(42) := '687761795F6D6F746F727761795F636173696E67222C22686967687761795F6D6F746F727761795F696E6E6572222C22686967687761795F6D6F746F727761795F737562746C65222C227261696C7761795F7472616E736974222C227261696C7761795F';
wwv_flow_imp.g_varchar2_table(43) := '7472616E7369745F646173686C696E65222C227261696C7761795F73657276696365222C227261696C7761795F736572766963655F646173686C696E65222C227261696C776179222C227261696C7761795F646173686C696E65222C2268696768776179';
wwv_flow_imp.g_varchar2_table(44) := '5F6D6F746F727761795F6272696467655F636173696E67222C22686967687761795F6D6F746F727761795F6272696467655F696E6E6572222C22686967687761795F6E616D655F6F74686572222C22686967687761795F6E616D655F6D6F746F72776179';
wwv_flow_imp.g_varchar2_table(45) := '222C22626F756E646172795F7374617465222C22626F756E646172795F636F756E7472795F7A302D34222C22626F756E646172795F636F756E7472795F7A352D222C22706C6163655F6F74686572222C22706C6163655F737562757262222C22706C6163';
wwv_flow_imp.g_varchar2_table(46) := '655F76696C6C616765222C22706C6163655F746F776E222C22706C6163655F63697479222C22706C6163655F6361706974616C222C22706C6163655F636974795F6C61726765222C22706C6163655F7374617465222C22706C6163655F636F756E747279';
wwv_flow_imp.g_varchar2_table(47) := '5F6F74686572222C22706C6163655F636F756E7472795F6D696E6F72222C22706C6163655F636F756E7472795F6D616A6F72225D3B636C617373204D7B636F6E7374727563746F7228297B7D6F6E4164642865297B72657475726E20746869732E6D5F6D';
wwv_flow_imp.g_varchar2_table(48) := '61703D652C746869732E6D5F636F6E7461696E65723D646F63756D656E742E637265617465456C656D656E74282264697622292C746869732E6D5F636F6E7461696E65722E636C6173734E616D653D226D61706C69627265676C2D6374726C206D61706C';
wwv_flow_imp.g_varchar2_table(49) := '69627265676C2D6374726C2D67726F7570206D6170626974732D626173656D61702D6374726C222C746869732E6D5F636F6E7461696E65727D6F6E52656D6F766528297B746869732E6D5F636F6E7461696E65722E706172656E744E6F64652E72656D6F';
wwv_flow_imp.g_varchar2_table(50) := '76654368696C6428746869732E6D5F636F6E7461696E6572292C746869732E6D5F6D61703D766F696420307D6164645374796C6528652C612C6F2C6E297B636F6E737420723D646F63756D656E742E637265617465456C656D656E7428226C6162656C22';
wwv_flow_imp.g_varchar2_table(51) := '293B722E636C6173734E616D653D226D6170626974732D626173656D61702D746F67676C65222C722E7469746C653D6E3B636F6E737420693D646F63756D656E742E637265617465456C656D656E742822696E70757422293B692E747970653D22726164';
wwv_flow_imp.g_varchar2_table(52) := '696F222C692E6E616D653D226D6170626974732D626173656D61702D73776974636865722D222B742C722E617070656E644368696C642869293B636F6E7374206C3D646F63756D656E742E637265617465456C656D656E74282264697622293B6966286F';
wwv_flow_imp.g_varchar2_table(53) := '297B636F6E737420653D646F63756D656E742E637265617465456C656D656E7428226922293B652E636C6173734E616D653D60666120247B6F7D602C6C2E617070656E644368696C642865297D69662861297B636F6E737420653D646F63756D656E742E';
wwv_flow_imp.g_varchar2_table(54) := '637265617465456C656D656E7428227370616E22293B652E696E6E657248544D4C3D6F3F22266E6273703B223A22222C652E696E6E657248544D4C2B3D612C6C2E617070656E644368696C642865297D722E617070656E644368696C64286C292C746869';
wwv_flow_imp.g_varchar2_table(55) := '732E6D5F636F6E7461696E65722E617070656E644368696C642872292C28683D3D3D657C7C226E756C6C223D3D3D6826266E756C6C3D3D3D657C7C216826262259223D3D3D6429262628692E636865636B65643D21302C77286529292C722E6164644576';
wwv_flow_imp.g_varchar2_table(56) := '656E744C697374656E657228226368616E6765222C2828293D3E7B692E636865636B6564262628772865292C617065782E73746F726167652E736574436F6F6B6965286D2C6529297D29297D7D636F6E737420413D6E6577204D3B672E616464436F6E74';
wwv_flow_imp.g_varchar2_table(57) := '726F6C28412C22746F702D6C65667422292C675B4D4150424954535F424153454D41505F53594D424F4C5D3D7B6C61796572733A5B5D2C636F6E74726F6C3A412C70656E64696E674C61796572436F6E7374727563746F72733A7B7D2C736B6970566563';
wwv_flow_imp.g_varchar2_table(58) := '746F723A7B7D7D2C412E6164645374796C65286E756C6C2C722C692C6C297D225922213D79262628675B4D4150424954535F424153454D41505F53594D424F4C5D2E736B6970566563746F725B655D3D2130292C675B4D4150424954535F424153454D41';
wwv_flow_imp.g_varchar2_table(59) := '505F53594D424F4C5D2E6C61796572732E707573682865292C675B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F72735B655D3D28293D3E7B672E616464536F7572636528652B222D';
wwv_flow_imp.g_varchar2_table(60) := '736F75726365222C7B747970653A22726173746572222C74696C65733A5B735D2C6D61787A6F6F6D3A637D293B636F6E737420743D7B69643A652B222D6261636B67726F756E64222C747970653A22726173746572222C736F757263653A652B222D736F';
wwv_flow_imp.g_varchar2_table(61) := '75726365227D3B672E6164644C6179657228742C672E6765745374796C6528292E6C61796572735B305D2E6964297D2C675B4D4150424954535F424153454D41505F53594D424F4C5D2E636F6E74726F6C2E6164645374796C6528652C612C6F2C6E297D';
wwv_flow_imp.g_varchar2_table(62) := '656C736520636F6E736F6C652E6C6F6728226D6170626974735F626173656D617020222B652B22203A20526567696F6E205B222B742B225D2069732068696464656E206F72206D697373696E672E22297D7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(82829110384715876)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_file_name=>'mapbits-basemap.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D6170626974732D626173656D61702D6374726C207B0D0A2020646973706C61793A20666C65783B0D0A7D0D0A0D0A2E6D6170626974732D626173656D61702D746F67676C65207B0D0A2020706F736974696F6E3A2072656C61746976653B0D0A2020';
wwv_flow_imp.g_varchar2_table(2) := '646973706C61793A20696E6C696E652D626C6F636B3B0D0A20206865696768743A20333270783B0D0A2020637572736F723A20706F696E7465723B0D0A7D0D0A0D0A2E6D6170626974732D626173656D61702D746F67676C6520696E707574207B0D0A20';
wwv_flow_imp.g_varchar2_table(3) := '2077696474683A20303B0D0A20206865696768743A20303B0D0A20206F7061636974793A20303B0D0A2020706F736974696F6E3A206162736F6C7574653B0D0A7D0D0A0D0A2E6D6170626974732D626173656D61702D746F67676C6520646976207B0D0A';
wwv_flow_imp.g_varchar2_table(4) := '2020746F703A20303B0D0A20206C6566743A20303B0D0A202077696474683A20313030253B0D0A20206865696768743A20313030253B0D0A7D0D0A0D0A2E6D6170626974732D626173656D61702D746F67676C6520646976207B0D0A202070616464696E';
wwv_flow_imp.g_varchar2_table(5) := '672D72696768743A20313270783B0D0A202070616464696E672D6C6566743A20313270783B0D0A2020646973706C61793A20666C65783B0D0A2020666C65782D646972656374696F6E3A20726F773B0D0A2020616C69676E2D6974656D733A2063656E74';
wwv_flow_imp.g_varchar2_table(6) := '65723B0D0A7D0D0A0D0A2E6D6170626974732D626173656D61702D746F67676C6520696E7075743A636865636B65642B646976207B0D0A2020626F726465722D7261646975733A203470783B0D0A20206261636B67726F756E642D636F6C6F723A207267';
wwv_flow_imp.g_varchar2_table(7) := '6228302C20302C20302C20302E32293B0D0A7D0D0A0D0A2E6D6170626974732D626173656D61702D746F67676C6520692E66612B7370616E207B0D0A20206D617267696E2D72696768743A203270783B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(274106844514276314)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_file_name=>'mapbits-basemap.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F424153454D41505F53594D424F4C203D2053796D626F6C28293B0D0A0D0A66756E6374696F6E206D6170626974735F626173656D61705F6572726F72287B206572726F72207D29207B0D0A2020617065782E6D657373';
wwv_flow_imp.g_varchar2_table(2) := '6167652E73686F774572726F7273285B0D0A202020207B0D0A202020202020747970653A20276572726F72272C0D0A2020202020206C6F636174696F6E3A202770616765272C0D0A2020202020206D6573736167653A206572726F720D0A202020207D0D';
wwv_flow_imp.g_varchar2_table(3) := '0A20205D293B0D0A7D0D0A0D0A66756E6374696F6E206D6170626974735F626173656D6170287B0D0A20206974656D49642C0D0A2020726567696F6E49642C0D0A20207469746C652C0D0A202069636F6E2C0D0A2020746F6F6C7469702C0D0A20206465';
wwv_flow_imp.g_varchar2_table(4) := '6661756C745469746C652C0D0A202064656661756C7449636F6E2C0D0A202064656661756C74546F6F6C7469702C0D0A202075726C2C0D0A20206D61787A6F6F6D2C0D0A20206572726F722C0D0A202073686F77566563746F722C0D0A2020696E697469';
wwv_flow_imp.g_varchar2_table(5) := '616C6C7956697369626C652C0D0A7D29207B0D0A2020636F6E737420636F6F6B69654E616D65203D20274D6170626974735F426173656D61705F27202B20726567696F6E49643B0D0A0D0A20202F2F2072616973652061206A6176617363726970742061';
wwv_flow_imp.g_varchar2_table(6) := '6C65727420776974682074686520696E707574206D65737361676520616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A20202020617065782E6A51756572792866756E';
wwv_flow_imp.g_varchar2_table(7) := '6374696F6E28297B617065782E6D6573736167652E616C657274286D7367293B636F6E736F6C652E6C6F67286D7367293B7D293B0D0A20207D0D0A202020200D0A20202F2F20696620616E206572726F72206F636375727320696E2074686520706C7567';
wwv_flow_imp.g_varchar2_table(8) := '696E20706C73716C20616E642069732070617373656420696E746F20746865206A6176617363726970742066756E6374696F6E2C200D0A20202F2F20726169736520616E20616C65727420776974682074686174206D6573736167652E0D0A2020696620';
wwv_flow_imp.g_varchar2_table(9) := '286572726F7229207B0D0A20202020617065785F616C657274286572726F72293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A202076617220726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0D0A202069662028';
wwv_flow_imp.g_varchar2_table(10) := '726567696F6E203D3D206E756C6C29207B0D0A20202020636F6E736F6C652E6C6F6728276D6170626974735F626173656D61702027202B206974656D4964202B2027203A20526567696F6E205B27202B20726567696F6E4964202B20275D206973206869';
wwv_flow_imp.g_varchar2_table(11) := '6464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A20202F2F2067657420746865206D617020686F6F6B0D0A2020766172206D6170203D20726567696F6E2E63616C6C28226765744D61704F626A6563';
wwv_flow_imp.g_varchar2_table(12) := '7422293B0D0A0D0A20202F2A205772617020746865207472616E73666F726D526571756573742066756E6374696F6E20746F206164642063726564656E7469616C733A20226F6D69742220746F20616C6C207265717565737473200D0A20202020746F20';
wwv_flow_imp.g_varchar2_table(13) := '7468652072617374657220736F757263652E204F74686572776973652C2077652077696C6C2067657420434F5253206572726F72732E202A2F0D0A202069662028747970656F66206D61702E7365745472616E73666F726D52657175657374203D3D3D20';
wwv_flow_imp.g_varchar2_table(14) := '2266756E6374696F6E2229207B0D0A20202020636F6E73742075726C5265676578203D206E65772052656745787028225E22202B2075726C2E7265706C616365282F5B5C2D5C5C5E242A2B3F2E28297C5B5C5D5D2F672C20275C5C242627292E7265706C';
wwv_flow_imp.g_varchar2_table(15) := '616365282F7B2E2A3F7D2F672C20272E2A2729202B20222422293B0D0A0D0A202020202F2A20544F444F3A20476574204D61704C6962726520746F206D616B6520616E2041504920666F7220746869732C20726174686572207468616E20646570656E64';
wwv_flow_imp.g_varchar2_table(16) := '696E67206F6E20696E7465726E616C73202A2F0D0A20202020636F6E7374206F6C645472616E73666F726D52657175657374203D206D61702E5F726571756573744D616E616765723F2E5F7472616E73666F726D52657175657374466E3B0D0A20202020';
wwv_flow_imp.g_varchar2_table(17) := '6D61702E7365745472616E73666F726D526571756573742828752C207265736F757263655479706529203D3E207B0D0A2020202020206966202875726C52656765782E7465737428752929207B0D0A202020202020202072657475726E207B75726C3A20';
wwv_flow_imp.g_varchar2_table(18) := '752C2063726564656E7469616C733A20226F6D6974227D3B0D0A2020202020207D20656C7365207B0D0A202020202020202069662028747970656F66206F6C645472616E73666F726D52657175657374203D3D3D202266756E6374696F6E2229207B0D0A';
wwv_flow_imp.g_varchar2_table(19) := '2020202020202020202072657475726E206F6C645472616E73666F726D5265717565737428752C207265736F7572636554797065293B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202072657475726E207B75726C3A20757D3B';
wwv_flow_imp.g_varchar2_table(20) := '0D0A20202020202020207D0D0A2020202020207D0D0A202020207D293B0D0A20207D0D0A0D0A2020766172206C436F6F6B6965203D20617065782E73746F726167652E676574436F6F6B696528636F6F6B69654E616D65293B0D0A0D0A20202F2F206F6E';
wwv_flow_imp.g_varchar2_table(21) := '2061206D6170206572726F722C2063726561746520616E20616C6572742E0D0A20206D61702E6F6E636528276572726F72272C2066756E6374696F6E286529207B0D0A2020202069662028652E736F757263654964203D3D206974656D4964202B20222D';
wwv_flow_imp.g_varchar2_table(22) := '736F757263652229207B0D0A202020202020617065785F616C65727428652E6572726F722E6D657373616765202B20225C6E22202B2075726C293B0D0A202020207D0D0A20207D293B0D0A0D0A202069662028216D61705B4D4150424954535F42415345';
wwv_flow_imp.g_varchar2_table(23) := '4D41505F53594D424F4C5D29207B0D0A20202020636F6E7374206C6179657244656673203D205B0D0A2020202020207B0D0A2020202020202020226964223A2022626F756E64617279222C0D0A20202020202020202274797065223A20226C696E65222C';
wwv_flow_imp.g_varchar2_table(24) := '0D0A202020202020202022736F75726365223A20226F70656E6D617074696C6573222C0D0A202020202020202022736F757263652D6C61796572223A2022626F756E64617279222C0D0A2020202020202020227061696E74223A207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(25) := '20202020226C696E652D636F6C6F72223A202223636363222C0D0A20202020202020202020226C696E652D7769647468223A20312C0D0A20202020202020202020226C696E652D646173686172726179223A205B352C20355D0D0A20202020202020207D';
wwv_flow_imp.g_varchar2_table(26) := '2C0D0A2020202020207D2C0D0A2020202020207B0D0A2020202020202020226964223A2022686967687761792D6C696E65222C0D0A20202020202020202274797065223A20226C696E65222C0D0A202020202020202022736F75726365223A20226F7065';
wwv_flow_imp.g_varchar2_table(27) := '6E6D617074696C6573222C0D0A202020202020202022736F757263652D6C61796572223A20227472616E73706F72746174696F6E222C0D0A2020202020202020226D696E7A6F6F6D223A2031322C0D0A2020202020202020227061696E74223A207B0D0A';
wwv_flow_imp.g_varchar2_table(28) := '20202020202020202020226C696E652D636F6C6F72223A202223343434222C0D0A20202020202020202020226C696E652D7769647468223A205B0D0A202020202020202020202020226D61746368222C0D0A2020202020202020202020205B2267657422';
wwv_flow_imp.g_varchar2_table(29) := '2C2022636C617373225D2C0D0A202020202020202020202020226D6F746F72776179222C0D0A202020202020202020202020312C0D0A202020202020202020202020302E350D0A202020202020202020205D2C0D0A20202020202020207D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(30) := '2020207D2C0D0A2020202020207B0D0A2020202020202020226964223A2022706C616365222C0D0A20202020202020202274797065223A202273796D626F6C222C0D0A202020202020202022736F75726365223A20226F70656E6D617074696C6573222C';
wwv_flow_imp.g_varchar2_table(31) := '0D0A202020202020202022736F757263652D6C61796572223A2022706C616365222C0D0A20202020202020202266696C746572223A205B22213D222C205B22676574222C2022636C617373225D2C2022636F6E74696E656E74225D2C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(32) := '2020226C61796F7574223A207B0D0A2020202020202020202022746578742D6669656C64223A205B22636F616C65736365222C205B22676574222C20226E616D655F656E225D2C205B22676574222C20226E616D65225D5D2C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(33) := '2022746578742D666F6E74223A205B224D6574726F706F6C697320426F6C64222C20224E6F746F2053616E7320426F6C64225D2C0D0A2020202020202020202022746578742D7472616E73666F726D223A205B0D0A202020202020202020202020226D61';
wwv_flow_imp.g_varchar2_table(34) := '746368222C0D0A2020202020202020202020205B22676574222C2022636C617373225D2C0D0A2020202020202020202020205B22636F756E747279222C20227374617465225D2C0D0A20202020202020202020202022757070657263617365222C0D0A20';
wwv_flow_imp.g_varchar2_table(35) := '2020202020202020202020226E6F6E65220D0A202020202020202020205D2C0D0A2020202020202020202022746578742D73697A65223A205B0D0A20202020202020202020202022696E746572706F6C617465222C0D0A2020202020202020202020205B';
wwv_flow_imp.g_varchar2_table(36) := '226C696E656172225D2C0D0A2020202020202020202020205B227A6F6F6D225D2C0D0A202020202020202020202020362C20205B226D61746368222C205B22676574222C2022636C617373225D2C2022636F756E747279222C2031322C20227374617465';
wwv_flow_imp.g_varchar2_table(37) := '222C2031302C202263697479222C2031302C2020385D2C0D0A20202020202020202020202031302C205B226D61746368222C205B22676574222C2022636C617373225D2C2022636F756E747279222C2031342C20227374617465222C2031342C20226369';
wwv_flow_imp.g_varchar2_table(38) := '7479222C2031312C2031305D2C0D0A20202020202020202020202031322C205B226D61746368222C205B22676574222C2022636C617373225D2C2022636F756E747279222C2031362C20227374617465222C2031342C202263697479222C2031342C2031';
wwv_flow_imp.g_varchar2_table(39) := '305D2C0D0A20202020202020202020202031342C205B226D61746368222C205B22676574222C2022636C617373225D2C2022636F756E747279222C2031362C20227374617465222C2031342C202263697479222C2031362C2031325D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(40) := '20202020205D2C0D0A20202020202020207D2C0D0A2020202020202020227061696E74223A207B0D0A2020202020202020202022746578742D636F6C6F72223A2022626C61636B222C0D0A2020202020202020202022746578742D68616C6F2D636F6C6F';
wwv_flow_imp.g_varchar2_table(41) := '72223A202223646464222C0D0A2020202020202020202022746578742D68616C6F2D7769647468223A20312E350D0A20202020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A2020202020202020226964223A202277617465722D6E61';
wwv_flow_imp.g_varchar2_table(42) := '6D652D706F696E74222C0D0A20202020202020202274797065223A202273796D626F6C222C0D0A202020202020202022736F75726365223A20226F70656E6D617074696C6573222C0D0A202020202020202022736F757263652D6C61796572223A202277';
wwv_flow_imp.g_varchar2_table(43) := '617465725F6E616D65222C0D0A20202020202020202266696C746572223A205B223D3D222C20222474797065222C2022506F696E74225D2C0D0A2020202020202020226C61796F7574223A207B0D0A2020202020202020202022746578742D6669656C64';
wwv_flow_imp.g_varchar2_table(44) := '223A205B22636F616C65736365222C205B22676574222C20226E616D655F656E225D2C205B22676574222C20226E616D65225D5D2C0D0A2020202020202020202022746578742D666F6E74223A205B224D6574726F706F6C697320426F6C64222C20224E';
wwv_flow_imp.g_varchar2_table(45) := '6F746F2053616E7320426F6C64225D2C0D0A2020202020202020202022746578742D73697A65223A2031322C0D0A20202020202020207D2C0D0A2020202020202020227061696E74223A207B0D0A2020202020202020202022746578742D636F6C6F7222';
wwv_flow_imp.g_varchar2_table(46) := '3A202223313134222C0D0A2020202020202020202022746578742D68616C6F2D636F6C6F72223A202223646464222C0D0A2020202020202020202022746578742D68616C6F2D7769647468223A20312E350D0A20202020202020207D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(47) := '7D2C0D0A2020202020207B0D0A2020202020202020226964223A202277617465722D6E616D652D6C696E65222C0D0A20202020202020202274797065223A202273796D626F6C222C0D0A202020202020202022736F75726365223A20226F70656E6D6170';
wwv_flow_imp.g_varchar2_table(48) := '74696C6573222C0D0A202020202020202022736F757263652D6C61796572223A20227761746572776179222C0D0A20202020202020202266696C746572223A205B223D3D222C20222474797065222C20224C696E65537472696E67225D2C0D0A20202020';
wwv_flow_imp.g_varchar2_table(49) := '20202020226C61796F7574223A207B0D0A202020202020202020202273796D626F6C2D706C6163656D656E74223A20226C696E65222C0D0A2020202020202020202022746578742D6669656C64223A205B22636F616C65736365222C205B22676574222C';
wwv_flow_imp.g_varchar2_table(50) := '20226E616D655F656E225D2C205B22676574222C20226E616D65225D5D2C0D0A2020202020202020202022746578742D666F6E74223A205B224D6574726F706F6C697320426F6C64222C20224E6F746F2053616E7320426F6C64225D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(51) := '202020202022746578742D73697A65223A2031322C0D0A20202020202020207D2C0D0A2020202020202020227061696E74223A207B0D0A2020202020202020202022746578742D636F6C6F72223A2022626C61636B222C0D0A2020202020202020202022';
wwv_flow_imp.g_varchar2_table(52) := '746578742D68616C6F2D636F6C6F72223A202223636366222C0D0A2020202020202020202022746578742D68616C6F2D7769647468223A20312E350D0A20202020202020207D0D0A2020202020207D2C0D0A2020202020207B0D0A202020202020202022';
wwv_flow_imp.g_varchar2_table(53) := '6964223A202268696768776179222C0D0A20202020202020202274797065223A202273796D626F6C222C0D0A202020202020202022736F75726365223A20226F70656E6D617074696C6573222C0D0A202020202020202022736F757263652D6C61796572';
wwv_flow_imp.g_varchar2_table(54) := '223A20227472616E73706F72746174696F6E5F6E616D65222C0D0A20202020202020202266696C746572223A205B223D3D222C20222474797065222C20224C696E65537472696E67225D2C0D0A2020202020202020226D696E7A6F6F6D223A2031322C0D';
wwv_flow_imp.g_varchar2_table(55) := '0A2020202020202020226C61796F7574223A207B0D0A202020202020202020202273796D626F6C2D706C6163656D656E74223A20226C696E65222C0D0A2020202020202020202022746578742D6669656C64223A205B22636F616C65736365222C205B22';
wwv_flow_imp.g_varchar2_table(56) := '676574222C20226E616D655F656E225D2C205B22676574222C20226E616D65225D5D2C0D0A2020202020202020202022746578742D666F6E74223A205B224D6574726F706F6C697320426F6C64222C20224E6F746F2053616E7320426F6C64225D2C0D0A';
wwv_flow_imp.g_varchar2_table(57) := '2020202020202020202022746578742D73697A65223A2031302C0D0A20202020202020207D2C0D0A2020202020202020227061696E74223A207B0D0A2020202020202020202022746578742D636F6C6F72223A202223333333222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(58) := '20202022746578742D68616C6F2D636F6C6F72223A202223636363222C0D0A2020202020202020202022746578742D68616C6F2D7769647468223A20312E350D0A20202020202020207D0D0A2020202020207D0D0A202020205D3B0D0A0D0A2020202066';
wwv_flow_imp.g_varchar2_table(59) := '756E6374696F6E20746F67676C655374796C65287374796C65494429207B0D0A202020202020696620287374796C65494420696E206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E73747275';
wwv_flow_imp.g_varchar2_table(60) := '63746F727329207B0D0A20202020202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F72735B7374796C6549445D28293B0D0A202020202020202064656C657465206D';
wwv_flow_imp.g_varchar2_table(61) := '61705B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F72735B7374796C6549445D3B0D0A2020202020207D0D0A202020202020636F6E73742073686F77566563746F724F7665726C61';
wwv_flow_imp.g_varchar2_table(62) := '79203D207374796C65494420213D3D206E756C6C2026262021287374796C65494420696E206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E736B6970566563746F72293B0D0A202020202020666F722028636F6E7374206C206F66';
wwv_flow_imp.g_varchar2_table(63) := '206C617965724465667329207B0D0A20202020202020206D61702E7365744C61796F757450726F7065727479286C2E69642C20277669736962696C697479272C2073686F77566563746F724F7665726C6179203F202776697369626C6527203A20276E6F';
wwv_flow_imp.g_varchar2_table(64) := '6E6527293B0D0A2020202020207D0D0A202020202020666F722028636F6E7374206C206F66206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E6C617965727329207B0D0A2020202020202020696620286D61702E6765744C617965';
wwv_flow_imp.g_varchar2_table(65) := '72286C202B20272D6261636B67726F756E64272929207B0D0A202020202020202020206D61702E7365744C61796F757450726F7065727479286C202B20272D6261636B67726F756E64272C20277669736962696C697479272C206C203D3D3D207374796C';
wwv_flow_imp.g_varchar2_table(66) := '654944203F202776697369626C6527203A20276E6F6E6527293B0D0A20202020202020207D0D0A2020202020207D0D0A202020202020666F722028636F6E7374206C206F6620706F736974726F6E4C617965727329207B0D0A20202020202020206D6170';
wwv_flow_imp.g_varchar2_table(67) := '2E7365744C61796F757450726F7065727479286C2C20277669736962696C697479272C207374796C654944203D3D3D206E756C6C203F202776697369626C6527203A20276E6F6E6527293B0D0A2020202020207D0D0A202020207D0D0A0D0A202020202F';
wwv_flow_imp.g_varchar2_table(68) := '2A20416464206F757220766563746F72206C617965727320626568696E64207468652064656661756C74207374796C652773206261636B67726F756E64202A2F0D0A20202020666F722028636F6E7374206C61796572206F66206C617965724465667329';
wwv_flow_imp.g_varchar2_table(69) := '207B0D0A20202020202069662028216C617965722E6C61796F757429207B0D0A20202020202020206C617965722E6C61796F7574203D207B7D3B0D0A2020202020207D0D0A2020202020206C617965722E6C61796F75742E7669736962696C697479203D';
wwv_flow_imp.g_varchar2_table(70) := '20226E6F6E65223B0D0A2020202020206C617965722E6964203D20226D6170626974732D626173656D61702D22202B206C617965722E69643B0D0A2020202020206D61702E6164644C61796572286C617965722C20226261636B67726F756E6422293B0D';
wwv_flow_imp.g_varchar2_table(71) := '0A202020207D0D0A0D0A202020202F2A20546869732069732061206C697374206F6620616C6C20746865206C6179657273207765206E65656420746F20686964652066726F6D2074686520506F736974726F6E207374796C650D0A202020202020776865';
wwv_flow_imp.g_varchar2_table(72) := '6E2077652073776974636820746F206F757220626173656D6170202A2F0D0A20202020636F6E737420706F736974726F6E4C6179657273203D205B0D0A202020202020226261636B67726F756E64222C20227061726B222C20227761746572222C20226C';
wwv_flow_imp.g_varchar2_table(73) := '616E64636F7665725F6963655F7368656C66222C20226C616E64636F7665725F676C6163696572222C20226C616E647573655F7265736964656E7469616C222C20226C616E64636F7665725F776F6F64222C20227761746572776179222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(74) := '20202277617465725F6E616D65222C20226275696C64696E67222C202274756E6E656C5F6D6F746F727761795F636173696E67222C202274756E6E656C5F6D6F746F727761795F696E6E6572222C20226165726F7761792D74617869776179222C202261';
wwv_flow_imp.g_varchar2_table(75) := '65726F7761792D72756E7761792D636173696E67222C20226165726F7761792D61726561222C0D0A202020202020226165726F7761792D72756E776179222C2022726F61645F617265615F70696572222C2022726F61645F70696572222C202268696768';
wwv_flow_imp.g_varchar2_table(76) := '7761795F70617468222C2022686967687761795F6D696E6F72222C2022686967687761795F6D616A6F725F636173696E67222C2022686967687761795F6D616A6F725F696E6E6572222C0D0A20202020202022686967687761795F6D616A6F725F737562';
wwv_flow_imp.g_varchar2_table(77) := '746C65222C2022686967687761795F6D6F746F727761795F636173696E67222C2022686967687761795F6D6F746F727761795F696E6E6572222C2022686967687761795F6D6F746F727761795F737562746C65222C20227261696C7761795F7472616E73';
wwv_flow_imp.g_varchar2_table(78) := '6974222C0D0A202020202020227261696C7761795F7472616E7369745F646173686C696E65222C20227261696C7761795F73657276696365222C20227261696C7761795F736572766963655F646173686C696E65222C20227261696C776179222C202272';
wwv_flow_imp.g_varchar2_table(79) := '61696C7761795F646173686C696E65222C2022686967687761795F6D6F746F727761795F6272696467655F636173696E67222C0D0A20202020202022686967687761795F6D6F746F727761795F6272696467655F696E6E6572222C202268696768776179';
wwv_flow_imp.g_varchar2_table(80) := '5F6E616D655F6F74686572222C2022686967687761795F6E616D655F6D6F746F72776179222C2022626F756E646172795F7374617465222C2022626F756E646172795F636F756E7472795F7A302D34222C2022626F756E646172795F636F756E7472795F';
wwv_flow_imp.g_varchar2_table(81) := '7A352D222C0D0A20202020202022706C6163655F6F74686572222C2022706C6163655F737562757262222C2022706C6163655F76696C6C616765222C2022706C6163655F746F776E222C2022706C6163655F63697479222C2022706C6163655F63617069';
wwv_flow_imp.g_varchar2_table(82) := '74616C222C2022706C6163655F636974795F6C61726765222C2022706C6163655F7374617465222C2022706C6163655F636F756E7472795F6F74686572222C0D0A20202020202022706C6163655F636F756E7472795F6D696E6F72222C2022706C616365';
wwv_flow_imp.g_varchar2_table(83) := '5F636F756E7472795F6D616A6F72222C0D0A202020205D3B0D0A0D0A20202020636C617373205374796C655377697463686572207B0D0A202020202020636F6E7374727563746F722829207B7D0D0A0D0A2020202020206F6E416464286D617029207B0D';
wwv_flow_imp.g_varchar2_table(84) := '0A2020202020202020746869732E6D5F6D6170203D206D61703B0D0A2020202020202020746869732E6D5F636F6E7461696E6572203D20646F63756D656E742E637265617465456C656D656E74282764697627293B0D0A2020202020202020746869732E';
wwv_flow_imp.g_varchar2_table(85) := '6D5F636F6E7461696E65722E636C6173734E616D65203D20276D61706C69627265676C2D6374726C206D61706C69627265676C2D6374726C2D67726F7570206D6170626974732D626173656D61702D6374726C273B0D0A20202020202020207265747572';
wwv_flow_imp.g_varchar2_table(86) := '6E20746869732E6D5F636F6E7461696E65723B0D0A2020202020207D0D0A0D0A2020202020206F6E52656D6F76652829207B0D0A2020202020202020746869732E6D5F636F6E7461696E65722E706172656E744E6F64652E72656D6F76654368696C6428';
wwv_flow_imp.g_varchar2_table(87) := '746869732E6D5F636F6E7461696E6572293B0D0A2020202020202020746869732E6D5F6D6170203D20756E646566696E65643B0D0A2020202020207D0D0A0D0A2020202020206164645374796C652869642C207469746C652C2069636F6E2C20746F6F6C';
wwv_flow_imp.g_varchar2_table(88) := '74697029207B0D0A2020202020202020636F6E7374206374726C203D20646F63756D656E742E637265617465456C656D656E7428276C6162656C27293B0D0A20202020202020206374726C2E636C6173734E616D65203D20276D6170626974732D626173';
wwv_flow_imp.g_varchar2_table(89) := '656D61702D746F67676C65273B0D0A20202020202020206374726C2E7469746C65203D20746F6F6C7469703B0D0A2020202020202020636F6E737420696E707574203D20646F63756D656E742E637265617465456C656D656E742827696E70757427293B';
wwv_flow_imp.g_varchar2_table(90) := '0D0A2020202020202020696E7075742E74797065203D2027726164696F273B0D0A2020202020202020696E7075742E6E616D65203D20276D6170626974732D626173656D61702D73776974636865722D27202B20726567696F6E49643B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(91) := '2020206374726C2E617070656E644368696C6428696E707574293B0D0A2020202020202020636F6E737420646976203D20646F63756D656E742E637265617465456C656D656E74282764697627293B0D0A0D0A20202020202020206966202869636F6E29';
wwv_flow_imp.g_varchar2_table(92) := '207B0D0A20202020202020202020636F6E73742069203D20646F63756D656E742E637265617465456C656D656E7428276927293B0D0A20202020202020202020692E636C6173734E616D65203D2060666120247B69636F6E7D603B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(93) := '2020206469762E617070656E644368696C642869293B0D0A20202020202020207D0D0A0D0A2020202020202020696620287469746C6529207B0D0A20202020202020202020636F6E7374207370616E203D20646F63756D656E742E637265617465456C65';
wwv_flow_imp.g_varchar2_table(94) := '6D656E7428277370616E27293B0D0A202020202020202020206966202869636F6E29207B0D0A2020202020202020202020207370616E2E696E6E657248544D4C203D2027266E6273703B273B0D0A202020202020202020207D20656C7365207B0D0A2020';
wwv_flow_imp.g_varchar2_table(95) := '202020202020202020207370616E2E696E6E657248544D4C203D2027273B0D0A202020202020202020207D202020200D0A202020202020202020207370616E2E696E6E657248544D4C202B3D207469746C653B0D0A202020202020202020206469762E61';
wwv_flow_imp.g_varchar2_table(96) := '7070656E644368696C64287370616E293B0D0A20202020202020207D0D0A0D0A20202020202020206374726C2E617070656E644368696C6428646976293B0D0A2020202020202020746869732E6D5F636F6E7461696E65722E617070656E644368696C64';
wwv_flow_imp.g_varchar2_table(97) := '286374726C293B0D0A0D0A2020202020202020696620286C436F6F6B6965203D3D3D206964207C7C20286C436F6F6B6965203D3D3D20226E756C6C22202626206964203D3D3D206E756C6C29207C7C2028216C436F6F6B696520262620696E697469616C';
wwv_flow_imp.g_varchar2_table(98) := '6C7956697369626C65203D3D3D202759272929207B0D0A20202020202020202020696E7075742E636865636B6564203D20747275653B0D0A20202020202020202020746F67676C655374796C65286964293B0D0A20202020202020207D0D0A0D0A202020';
wwv_flow_imp.g_varchar2_table(99) := '20202020206374726C2E6164644576656E744C697374656E657228276368616E6765272C202829203D3E207B0D0A20202020202020202020636F6E737420636865636B6564203D20696E7075742E636865636B65643B0D0A0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(100) := '69662028636865636B656429207B0D0A202020202020202020202020746F67676C655374796C65286964293B0D0A202020202020202020202020617065782E73746F726167652E736574436F6F6B696528636F6F6B69654E616D652C206964293B0D0A20';
wwv_flow_imp.g_varchar2_table(101) := '2020202020202020207D0D0A20202020202020207D293B0D0A2020202020207D0D0A202020207D0D0A20202020636F6E7374207374796C655377697463686572203D206E6577205374796C65537769746368657228293B0D0A202020206D61702E616464';
wwv_flow_imp.g_varchar2_table(102) := '436F6E74726F6C287374796C6553776974636865722C2027746F702D6C65667427293B0D0A0D0A202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D203D207B0D0A2020202020206C61796572733A205B5D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(103) := '20636F6E74726F6C3A207374796C6553776974636865722C0D0A20202020202070656E64696E674C61796572436F6E7374727563746F72733A207B7D2C0D0A202020202020736B6970566563746F723A207B7D2C0D0A202020207D3B0D0A202020207374';
wwv_flow_imp.g_varchar2_table(104) := '796C6553776974636865722E6164645374796C65286E756C6C2C2064656661756C745469746C652C2064656661756C7449636F6E2C2064656661756C74546F6F6C746970293B0D0A20207D0D0A0D0A20206966202873686F77566563746F7220213D2027';
wwv_flow_imp.g_varchar2_table(105) := '592729207B0D0A202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E736B6970566563746F725B6974656D49645D203D20747275653B0D0A20207D0D0A20206D61705B4D4150424954535F424153454D41505F53594D424F4C';
wwv_flow_imp.g_varchar2_table(106) := '5D2E6C61796572732E70757368286974656D4964293B0D0A20206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F72735B6974656D49645D203D202829203D3E207B0D0A2020';
wwv_flow_imp.g_varchar2_table(107) := '20206D61702E616464536F75726365286974656D4964202B20272D736F75726365272C207B0D0A20202020202074797065203A2027726173746572272C0D0A20202020202074696C6573203A205B75726C5D2C0D0A2020202020206D61787A6F6F6D203A';
wwv_flow_imp.g_varchar2_table(108) := '206D61787A6F6F6D2C0D0A202020207D293B0D0A20202020636F6E7374206C61796572203D207B0D0A202020202020276964273A206974656D4964202B20272D6261636B67726F756E64272C0D0A2020202020202774797065273A202272617374657222';
wwv_flow_imp.g_varchar2_table(109) := '2C0D0A20202020202027736F75726365273A206974656D4964202B20272D736F75726365272C0D0A202020207D3B0D0A0D0A202020206D61702E6164644C61796572286C617965722C206D61702E6765745374796C6528292E6C61796572735B305D2E69';
wwv_flow_imp.g_varchar2_table(110) := '64293B0D0A20207D3B0D0A20206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E636F6E74726F6C2E6164645374796C65280D0A202020206974656D49642C0D0A202020207469746C652C0D0A2020202069636F6E2C0D0A20202020';
wwv_flow_imp.g_varchar2_table(111) := '746F6F6C7469700D0A2020293B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(274107240541277784)
,p_plugin_id=>wwv_flow_imp.id(274089793331619085)
,p_file_name=>'mapbits-basemap.js'
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
