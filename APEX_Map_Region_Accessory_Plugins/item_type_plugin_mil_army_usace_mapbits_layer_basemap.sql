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
--   Date and Time:   14:50 Friday December 29, 2023
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 669819273995554433
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
 p_id=>wwv_flow_imp.id(669819273995554433)
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
'    l_attribution p_item.attribute_15%type := p_item.attribute_15;',
'    l_source_type p_item.attribute_04%type := p_item.attribute_04;',
'    l_js_config p_item.attribute_06%type := p_item.attribute_06;',
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
'      raise_application_error(-20391, ''Configuration ERROR:  Mapbits Basemap Item ['' || p_item.name || ''] is not associated with a Map region.'');',
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
'    apex_javascript.add_onload_code(p_code => ''',
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
'        || apex_javascript.add_attribute(''attribution'', l_attribution)',
'        || apex_javascript.add_attribute(''sourceType'', l_source_type)',
'        || apex_javascript.add_attribute(''pluginFiles'', p_plugin.file_prefix)',
'        || ''jsConfig: '' || nvl(l_js_config, ''null'') || '',''',
'        || ''});'',',
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
,p_version_identifier=>'4.6.20231201'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 Layer - Basemap',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_basemap.sql 18808 2023-12-29 20:58:50Z b2eddjw9 $',
'Date     : $Date: 2023-12-29 14:58:50 -0600 (Fri, 29 Dec 2023) $',
'Revision : $Revision: 18808 $',
'Requires : Application Express >= 22.2',
'',
'Version 4.6 Updates:',
'12/14/2023 - Fix issue with Basemap plugin that prevented loading static application files from APEX.',
'12/11/2023 - Fix crash when showing attribution logo.',
'12/08/2023 - Added Basemap Source Type option to allow TileJSON URLs. Added JavaScript Configuration option. Added Attribution option. Added attribution logo for Mapbox maps. Changed default tile size to 256 (this can be changed back with JavaScript)'
||'.',
'12/01/2023 - Fixed "undefined" tooltip in switcher. Don''t show errors in a dialog, since they can be triggered by navigation (which cancels network requests). Raise an application error if this plugin item is not associated with a Map region.',
'11/08/2023 - Fixed the text color of the basemap switcher in dark mode. Made the plugin compatible with the Dark Matter default basemap.',
'11/07/2023 - Fixed the cookie that remembers which basemap you chose in the case of multiple maps per application. The cookie is now stored per map region. Improved error handling when the item is not placed in a map region.',
'',
'Version 4.5 Updates:',
'10/27/2023 - Moved default basemap configuration to the Component Settings. Added space between icon and title. Added documentation. ',
'10/25/2023 - Initial Implementation. Includes attributes basemap title, icon, and tooltip in the basemap toolbar for both the plugin''s defined basemap and the default basemap. Support for multiple simultaneous basemaps.  '))
,p_files_version=>151
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(670285182777879005)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
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
 p_id=>wwv_flow_imp.id(670289078023962460)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
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
 p_id=>wwv_flow_imp.id(670290190765969844)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
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
 p_id=>wwv_flow_imp.id(669820900614565130)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>70
,p_prompt=>'URL'
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
 p_id=>wwv_flow_imp.id(669821630686578734)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>10
,p_prompt=>'Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'Imagery'
,p_is_translatable=>false
,p_help_text=>'Name of layer to be displayed in the toggle section under the map used to turn layers on and off.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(178969824498345697)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>60
,p_prompt=>'Basemap Source Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'tile_url'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(178971523107348490)
,p_plugin_attribute_id=>wwv_flow_imp.id(178969824498345697)
,p_display_sequence=>10
,p_display_value=>'Tile URL'
,p_return_value=>'tile_url'
,p_help_text=>'A URL to a tile server, with {z} {x} and {y} placeholders for the tile coordinates or a {bbox-epsg-3857} placeholder for the BBOX parameter of a WMS server.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(178971933676350668)
,p_plugin_attribute_id=>wwv_flow_imp.id(178969824498345697)
,p_display_sequence=>20
,p_display_value=>'TileJSON URL'
,p_return_value=>'tile_json_url'
,p_help_text=>'A URL to a TileJSON file containing the details of the tile server. If the basemap source provides a TileJSON file, this is the easiest method.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(178912638899099087)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>100
,p_prompt=>'JavaScript Customization'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'JavaScript code to customize the data source before it is passed to map.addSource() <https://maplibre.org/maplibre-gl-js/docs/API/classes/maplibregl.Map/#addsource>.',
'',
'This code may be an expression that evaluates to an object, or a function which returns an object. Either way, the object is merged with the original options.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(670342015179500842)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>80
,p_prompt=>'Max Scale'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'16'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(178969824498345697)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'tile_json_url'
,p_lov_type=>'STATIC'
,p_help_text=>'The maximum zoom level to fetch tiles. Beyond this level, the imagery will be scaled. If you experience errors rendering at large scales, the basemap may not support that zoom level. You can reduce this value to avoid the issue.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670344398428503863)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>10
,p_display_value=>'0 - The Earth'
,p_return_value=>'0'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670344811224505148)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>20
,p_display_value=>'1'
,p_return_value=>'1'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670345206482505636)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>30
,p_display_value=>'2'
,p_return_value=>'2'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670345576812507091)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>40
,p_display_value=>'3 - A Continent'
,p_return_value=>'3'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670345934133508647)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>50
,p_display_value=>'4 - Large Islands'
,p_return_value=>'4'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670346322939509132)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>60
,p_display_value=>'5'
,p_return_value=>'5'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670346809453510431)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>70
,p_display_value=>'6 - Large Rivers'
,p_return_value=>'6'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670348699160511587)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>80
,p_display_value=>'7'
,p_return_value=>'7'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670349086469511987)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>90
,p_display_value=>'8'
,p_return_value=>'8'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670349428250512372)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>100
,p_display_value=>'9'
,p_return_value=>'9'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670349881797514838)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>110
,p_display_value=>'10 - Large Roads'
,p_return_value=>'10'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670350388279515268)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>120
,p_display_value=>'11'
,p_return_value=>'11'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670350789985515619)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>130
,p_display_value=>'12'
,p_return_value=>'12'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670351210300516016)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>140
,p_display_value=>'13'
,p_return_value=>'13'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670352500825516407)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>150
,p_display_value=>'14'
,p_return_value=>'14'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670353445369517208)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>160
,p_display_value=>'15 - Buildings'
,p_return_value=>'15'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670353893781517661)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>170
,p_display_value=>'16'
,p_return_value=>'16'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670354306094518179)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>180
,p_display_value=>'17'
,p_return_value=>'17'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670354688301518622)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>190
,p_display_value=>'18'
,p_return_value=>'18'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670355052667519071)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>200
,p_display_value=>'19'
,p_return_value=>'19'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670355476586519541)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>210
,p_display_value=>'20'
,p_return_value=>'20'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670355906920519889)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>220
,p_display_value=>'21'
,p_return_value=>'21'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(670356293846520396)
,p_plugin_attribute_id=>wwv_flow_imp.id(670342015179500842)
,p_display_sequence=>230
,p_display_value=>'22'
,p_return_value=>'22'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(669826433234849099)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>50
,p_prompt=>'Show Vector Overlay'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Show place names, streets, and roads over the basemap. Disable if the base map already contains these things.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(669826780381851499)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>20
,p_prompt=>'Icon'
,p_attribute_type=>'ICON'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Icon of layer to be displayed in the toggle section under the map used to turn layers on and off.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(669827119311854655)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>30
,p_prompt=>'Tooltip'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Tooltip to be displayed when a user hovers over the layer''s button in the basemap toggle section.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(669830175133868117)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>40
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
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(178852086763348409)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>90
,p_prompt=>'Attribution'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(178969824498345697)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'tile_json_url'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Attribution text to show in the bottom right corner when this basemap layer is visible.',
'',
'Use the special value `%mapbox` to show the correct logo and attribution for Mapbox tilesets as required by their TOS.'))
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574662D38223F3E3C7376672076657273696F6E3D22312E31222069643D224C617965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F';
wwv_flow_imp.g_varchar2_table(2) := '7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22307078222076696577426F783D223020302038302E34372032302E303222207374796C653D22656E61';
wwv_flow_imp.g_varchar2_table(3) := '626C652D6261636B67726F756E643A6E6577203020302038302E34372032302E30323B2220786D6C3A73706163653D227072657365727665223E3C7374796C6520747970653D22746578742F637373223E2E7374307B6F7061636974793A302E363B6669';
wwv_flow_imp.g_varchar2_table(4) := '6C6C3A234646464646463B656E61626C652D6261636B67726F756E643A6E6577202020203B7D2E7374317B6F7061636974793A302E363B656E61626C652D6261636B67726F756E643A6E6577202020203B7D3C2F7374796C653E3C673E3C706174682063';
wwv_flow_imp.g_varchar2_table(5) := '6C6173733D227374302220643D224D37392E32392C31332E363163302C302E31312D302E30392C302E322D302E322C302E32682D312E3533632D302E31322C302D302E32332D302E30362D302E32392D302E31366C2D312E33372D322E32386C2D312E33';
wwv_flow_imp.g_varchar2_table(6) := '372C322E3238632D302E30362C302E312D302E31372C302E31362D302E32392C302E3136682D312E3533632D302E30342C302D302E30382D302E30312D302E31312D302E3033632D302E30392D302E30362D302E31322D302E31382D302E30362D302E32';
wwv_flow_imp.g_varchar2_table(7) := '3763302C302C302C302C302C306C322E33312D332E356C2D322E32382D332E3437632D302E30322D302E30332D302E30332D302E30372D302E30332D302E313163302D302E31312C302E30392D302E322C302E322D302E3268312E353363302E31322C30';
wwv_flow_imp.g_varchar2_table(8) := '2C302E32332C302E30362C302E32392C302E31366C312E33342C322E32356C312E33332D322E323463302E30362D302E312C302E31372D302E31362C302E32392D302E313668312E353363302E30342C302C302E30382C302E30312C302E31312C302E30';
wwv_flow_imp.g_varchar2_table(9) := '3363302E30392C302E30362C302E31322C302E31382C302E30362C302E323763302C302C302C302C302C304C37362E39362C31306C322E33312C332E354337392E32382C31332E35332C37392E32392C31332E35372C37392E32392C31332E36317A222F';
wwv_flow_imp.g_varchar2_table(10) := '3E3C7061746820636C6173733D227374302220643D224D36332E30392C392E3136632D302E33372D312E37392D312E38372D332E31322D332E36362D332E3132632D302E39382C302D312E39332C302E342D322E362C312E313256332E333763302D302E';
wwv_flow_imp.g_varchar2_table(11) := '31322D302E312D302E32322D302E32322D302E3232682D312E3333632D302E31322C302D302E32322C302E312D302E32322C302E32327631302E323163302C302E31322C302E312C302E32322C302E32322C302E323268312E333363302E31322C302C30';
wwv_flow_imp.g_varchar2_table(12) := '2E32322D302E312C302E32322D302E3232762D302E3763302E36382C302E37312C312E36322C312E31322C322E362C312E313263312E37392C302C332E32392D312E33342C332E36362D332E31334336332E32312C31302E332C36332E32312C392E3732';
wwv_flow_imp.g_varchar2_table(13) := '2C36332E30392C392E31364C36332E30392C392E31367A204D35392E31322C31322E3431632D312E32362C302D322E32382D312E30362D322E332D322E333656392E393963302E30322D312E33312C312E30342D322E33362C322E332D322E333673322E';
wwv_flow_imp.g_varchar2_table(14) := '332C312E30372C322E332C322E33395336302E33392C31322E34312C35392E31322C31322E34317A222F3E3C7061746820636C6173733D227374302220643D224D36382E32362C362E3034632D312E38392D302E30312D332E35342C312E32392D332E39';
wwv_flow_imp.g_varchar2_table(15) := '362C332E3133632D302E31322C302E35362D302E31322C312E31332C302C312E363963302E34322C312E38352C322E30372C332E31362C332E39372C332E313463322E32342C302C342E30362D312E37382C342E30362D332E39395337302E35312C362E';
wwv_flow_imp.g_varchar2_table(16) := '30342C36382E32362C362E30347A204D36382E32342C31322E3432632D312E32372C302D322E332D312E30372D322E332D322E333973312E30332D322E342C322E332D322E3473322E332C312E30372C322E332C322E33395336392E35312C31322E3431';
wwv_flow_imp.g_varchar2_table(17) := '2C36382E32342C31322E34324C36382E32342C31322E34327A222F3E3C7061746820636C6173733D227374312220643D224D35392E31322C372E3633632D312E32362C302D322E32382C312E30362D322E332C322E333676302E303663302E30322C312E';
wwv_flow_imp.g_varchar2_table(18) := '33312C312E30342C322E33362C322E332C322E333673322E332D312E30372C322E332D322E33395336302E33392C372E36332C35392E31322C372E36337A204D35392E31322C31312E3233632D302E362C302D312E30392D302E35332D312E31312D312E';
wwv_flow_imp.g_varchar2_table(19) := '313956313063302E30312D302E36362C302E35312D312E31392C312E31312D312E313973312E31312C302E35342C312E31312C312E32315335392E37342C31312E32332C35392E31322C31312E32337A222F3E3C7061746820636C6173733D2273743122';
wwv_flow_imp.g_varchar2_table(20) := '20643D224D36382E32342C372E3633632D312E32372C302D322E332C312E30372D322E332C322E333973312E30332C322E33392C322E332C322E333973322E332D312E30372C322E332D322E33395336392E35312C372E36332C36382E32342C372E3633';
wwv_flow_imp.g_varchar2_table(21) := '7A204D36382E32342C31312E3233632D302E36312C302D312E31312D302E35342D312E31312D312E323173302E352D312E322C312E31312D312E3273312E31312C302E35342C312E31312C312E32315336382E38352C31312E32332C36382E32342C3131';
wwv_flow_imp.g_varchar2_table(22) := '2E32337A222F3E3C7061746820636C6173733D227374302220643D224D34332E35362C362E3234682D312E3333632D302E31322C302D302E32322C302E312D302E32322C302E323276302E37632D302E36382D302E37312D312E36322D312E31322D322E';
wwv_flow_imp.g_varchar2_table(23) := '362D312E3132632D322E30372C302D332E37352C312E37382D332E37352C332E393973312E36392C332E39392C332E37352C332E393963302E39392C302C312E39332D302E34312C322E362D312E313376302E3763302C302E31322C302E312C302E3232';
wwv_flow_imp.g_varchar2_table(24) := '2C302E32322C302E323268312E333363302E31322C302C302E32322D302E312C302E32322D302E323256362E343463302D302E31312D302E30392D302E32312D302E32312D302E32314334332E35372C362E32342C34332E35372C362E32342C34332E35';
wwv_flow_imp.g_varchar2_table(25) := '362C362E32347A204D34322E30322C31302E3035632D302E30312C312E33312D312E30342C322E33362D322E332C322E3336732D322E332D312E30372D322E332D322E333973312E30332D322E342C322E32392D322E3463312E32372C302C322E32382C';
wwv_flow_imp.g_varchar2_table(26) := '312E30362C322E332C322E33364C34322E30322C31302E30357A222F3E3C7061746820636C6173733D227374312220643D224D33392E37322C372E3633632D312E32372C302D322E332C312E30372D322E332C322E333973312E30332C322E33392C322E';
wwv_flow_imp.g_varchar2_table(27) := '332C322E333973322E32382D312E30362C322E332D322E333656392E39394334322C382E36382C34302E39382C372E36332C33392E37322C372E36337A204D33382E36322C31302E303263302D302E36372C302E352D312E32312C312E31312D312E3231';
wwv_flow_imp.g_varchar2_table(28) := '63302E36312C302C312E30392C302E35332C312E31312C312E313976302E3034632D302E30312C302E36352D302E352C312E31382D312E31312C312E31385333382E36322C31302E36382C33382E36322C31302E30327A222F3E3C7061746820636C6173';
wwv_flow_imp.g_varchar2_table(29) := '733D227374302220643D224D34392E39312C362E3034632D302E39382C302D312E39332C302E342D322E362C312E313256362E343563302D302E31322D302E312D302E32322D302E32322D302E3232682D312E3333632D302E31322C302D302E32322C30';
wwv_flow_imp.g_varchar2_table(30) := '2E312D302E32322C302E32327631302E323163302C302E31322C302E312C302E32322C302E32322C302E323268312E333363302E31322C302C302E32322D302E312C302E32322D302E3232762D332E373863302E36382C302E37312C312E36322C312E31';
wwv_flow_imp.g_varchar2_table(31) := '322C322E36312C312E313263322E30372C302C332E37352D312E37382C332E37352D332E39395335312E39382C362E30342C34392E39312C362E30347A204D34392E362C31322E3432632D312E32362C302D322E32382D312E30362D322E332D322E3336';
wwv_flow_imp.g_varchar2_table(32) := '56392E393963302E30322D312E33312C312E30342D322E33372C322E32392D322E333763312E32362C302C322E332C312E30372C322E332C322E33395335302E38362C31322E34312C34392E362C31322E34324C34392E362C31322E34327A222F3E3C70';
wwv_flow_imp.g_varchar2_table(33) := '61746820636C6173733D227374312220643D224D34392E362C372E3633632D312E32362C302D322E32382C312E30362D322E332C322E333676302E303663302E30322C312E33312C312E30342C322E33362C322E332C322E333673322E332D312E30372C';
wwv_flow_imp.g_varchar2_table(34) := '322E332D322E33395335302E38362C372E36332C34392E362C372E36337A204D34392E362C31312E3233632D302E362C302D312E30392D302E35332D312E31312D312E31395631304334382E352C392E33342C34392C382E38312C34392E362C382E3831';
wwv_flow_imp.g_varchar2_table(35) := '63302E362C302C312E31312C302E35352C312E31312C312E32315335302E32312C31312E32332C34392E362C31312E32337A222F3E3C7061746820636C6173733D227374302220643D224D33342E33362C31332E353963302C302E31322D302E312C302E';
wwv_flow_imp.g_varchar2_table(36) := '32322D302E32322C302E3232682D312E3334632D302E31322C302D302E32322D302E312D302E32322D302E323256392E323463302D302E39332D302E372D312E36332D312E35342D312E3633632D302E37362C302D312E33392C302E36372D312E35312C';
wwv_flow_imp.g_varchar2_table(37) := '312E35346C302E30312C342E343463302C302E31322D302E312C302E32322D302E32322C302E3232682D312E3334632D302E31322C302D302E32322D302E312D302E32322D302E323256392E323463302D302E39332D302E372D312E36332D312E35342D';
wwv_flow_imp.g_varchar2_table(38) := '312E3633632D302E38312C302D312E34372C302E37352D312E35322C312E373176342E323763302C302E31322D302E312C302E32322D302E32322C302E3232682D312E3333632D302E31322C302D302E32322D302E312D302E32322D302E323256362E34';
wwv_flow_imp.g_varchar2_table(39) := '3463302E30312D302E31322C302E312D302E32312C302E32322D302E323168312E333363302E31322C302C302E32312C302E312C302E32322C302E323176302E363363302E34382D302E36352C312E32342D312E30342C322E30362D312E303568302E30';
wwv_flow_imp.g_varchar2_table(40) := '3363312E30342C302C312E39392C302E35372C322E34382C312E343863302E34332D302E392C312E33332D312E34382C322E33322D312E343963312E35342C302C322E37392C312E31392C322E37362C322E36354C33342E33362C31332E35397A222F3E';
wwv_flow_imp.g_varchar2_table(41) := '3C7061746820636C6173733D227374312220643D224D38302E33322C31322E39376C2D302E30372D302E31324C37382E33382C31306C312E38352D322E383163302E34322D302E36342C302E32352D312E34392D302E33392D312E3932632D302E30312D';
wwv_flow_imp.g_varchar2_table(42) := '302E30312D302E30322D302E30312D302E30332D302E3032632D302E32322D302E31342D302E34382D302E32312D302E37342D302E3231682D312E3533632D302E35332C302D312E30332C302E32382D312E332C302E37346C2D302E33322C302E35336C';
wwv_flow_imp.g_varchar2_table(43) := '2D302E33322D302E3533632D302E32382D302E34362D302E37372D302E37342D312E33312D302E3734682D312E3533632D302E35372C302D312E30382C302E33352D312E32392C302E3838632D322E30392D312E35382D352E30332D312E342D362E3931';
wwv_flow_imp.g_varchar2_table(44) := '2C302E3433632D302E33332C302E33322D302E36322C302E36392D302E38352C312E3039632D302E38352D312E35352D322E34352D322E362D342E32382D322E36632D302E34382C302D302E39362C302E30372D312E34312C302E323256332E33376330';
wwv_flow_imp.g_varchar2_table(45) := '2D302E37382D302E36332D312E34312D312E342D312E3431682D312E3333632D302E37372C302D312E342C302E36332D312E342C312E3476332E3537632D302E392D312E332D322E33382D322E30382D332E39372D322E3039632D302E372C302D312E33';
wwv_flow_imp.g_varchar2_table(46) := '392C302E31352D322E30322C302E3435632D302E32332D302E31362D302E35312D302E32352D302E382D302E3235682D312E3333632D302E34332C302D302E38332C302E322D312E312C302E3533632D302E30322D302E30332D302E30342D302E30352D';
wwv_flow_imp.g_varchar2_table(47) := '302E30372D302E3038632D302E32372D302E32392D302E36352D302E34352D312E30342D302E3435682D312E3332632D302E32392C302D302E35372C302E30392D302E382C302E32354334302E382C352C34302E31322C342E38352C33392E34322C342E';
wwv_flow_imp.g_varchar2_table(48) := '3835632D312E37342C302D332E32372C302E39352D342E31362C322E3338632D302E31392D302E34342D302E34362D302E38352D302E37392D312E3139632D302E37362D302E37372D312E382D312E31392D322E38382D312E3139682D302E3031632D30';
wwv_flow_imp.g_varchar2_table(49) := '2E38352C302E30312D312E36372C302E33312D322E33342C302E3834632D302E372D302E35342D312E35362D302E38342D322E34352D302E3834682D302E3033632D302E32382C302D302E35352C302E30332D302E38322C302E31632D302E32372C302E';
wwv_flow_imp.g_varchar2_table(50) := '30362D302E35332C302E31352D302E37382C302E3237632D302E322D302E31312D302E34332D302E31372D302E36372D302E3137682D312E3333632D302E37382C302D312E342C302E36332D312E342C312E3476372E313463302C302E37382C302E3633';
wwv_flow_imp.g_varchar2_table(51) := '2C312E342C312E342C312E3468312E333363302E37382C302C312E34312D302E36332C312E34312D312E343163302C302C302C302C302C3056392E333563302E30332D302E33342C302E32322D302E35362C302E33342D302E353663302E31372C302C30';
wwv_flow_imp.g_varchar2_table(52) := '2E33362C302E31372C302E33362C302E343576342E333563302C302E37382C302E36332C312E342C312E342C312E3468312E333463302E37382C302C312E342D302E36332C312E342D312E346C2D302E30312D342E333563302E30362D302E332C302E32';
wwv_flow_imp.g_varchar2_table(53) := '342D302E34352C302E33332D302E343563302E31372C302C302E33362C302E31372C302E33362C302E343576342E333563302C302E37382C302E36332C312E342C312E342C312E3468312E333463302E37382C302C312E342D302E36332C312E342D312E';
wwv_flow_imp.g_varchar2_table(54) := '34762D302E333663302E39312C312E32332C322E33342C312E39362C332E38372C312E393663302E372C302C312E33392D302E31352C322E30322D302E343563302E32332C302E31362C302E35312C302E32352C302E382C302E323568312E333263302E';
wwv_flow_imp.g_varchar2_table(55) := '32392C302C302E35372D302E30392C302E382D302E323576312E393163302C302E37382C302E36332C312E342C312E342C312E3468312E333363302E37382C302C312E342D302E36332C312E342D312E34762D312E363963302E34362C302E31342C302E';
wwv_flow_imp.g_varchar2_table(56) := '39342C302E32322C312E34322C302E323163312E36322C302C332E30372D302E38332C332E39372D322E3176302E3563302C302E37382C302E36332C312E342C312E342C312E3468312E333363302E32392C302C302E35372D302E30392C302E382D302E';
wwv_flow_imp.g_varchar2_table(57) := '323563302E36332C302E332C312E33322C302E34352C322E30322C302E343563312E38332C302C332E34332D312E30352C342E32382D322E3663312E34372C322E35322C342E37312C332E33362C372E32322C312E383963302E31372D302E312C302E33';
wwv_flow_imp.g_varchar2_table(58) := '342D302E32312C302E352D302E333463302E32312C302E35322C302E37322C302E38372C312E32392C302E383668312E353363302E35332C302C312E30332D302E32382C312E332D302E37346C302E33352D302E35386C302E33352C302E353863302E32';
wwv_flow_imp.g_varchar2_table(59) := '382C302E34362C302E37372C302E37342C312E33312C302E373468312E353263302E37372C302C312E33392D302E36332C312E33382D312E33394338302E34372C31332E33382C38302E34322C31332E31372C38302E33322C31322E39374C38302E3332';
wwv_flow_imp.g_varchar2_table(60) := '2C31322E39377A204D33342E31352C31332E3831682D312E3334632D302E31322C302D302E32322D302E312D302E32322D302E323256392E323463302D302E39332D302E372D312E36332D312E35342D312E3633632D302E37362C302D312E33392C302E';
wwv_flow_imp.g_varchar2_table(61) := '36372D312E35312C312E35346C302E30312C342E343463302C302E31322D302E312C302E32322D302E32322C302E3232682D312E3334632D302E31322C302D302E32322D302E312D302E32322D302E323256392E323463302D302E39332D302E372D312E';
wwv_flow_imp.g_varchar2_table(62) := '36332D312E35342D312E3633632D302E38312C302D312E34372C302E37352D312E35322C312E373176342E323763302C302E31322D302E312C302E32322D302E32322C302E3232682D312E3333632D302E31322C302D302E32322D302E312D302E32322D';
wwv_flow_imp.g_varchar2_table(63) := '302E323256362E343463302E30312D302E31322C302E312D302E32312C302E32322D302E323168312E333363302E31322C302C302E32312C302E312C302E32322C302E323176302E363363302E34382D302E36352C312E32342D312E30342C322E30362D';
wwv_flow_imp.g_varchar2_table(64) := '312E303568302E303363312E30342C302C312E39392C302E35372C322E34382C312E343863302E34332D302E392C312E33332D312E34382C322E33322D312E343963312E35342C302C322E37392C312E31392C322E37362C322E36356C302E30312C342E';
wwv_flow_imp.g_varchar2_table(65) := '39314333342E33372C31332E372C33342E32372C31332E382C33342E31352C31332E38314333342E31352C31332E38312C33342E31352C31332E38312C33342E31352C31332E38317A204D34332E37382C31332E353963302C302E31322D302E312C302E';
wwv_flow_imp.g_varchar2_table(66) := '32322D302E32322C302E3232682D312E3333632D302E31322C302D302E32322D302E312D302E32322D302E3232762D302E37314334312E33342C31332E362C34302E342C31342C33392E34322C3134632D322E30372C302D332E37352D312E37382D332E';
wwv_flow_imp.g_varchar2_table(67) := '37352D332E393973312E36392D332E39392C332E37352D332E393963302E39382C302C312E39322C302E34312C322E362C312E3132762D302E3763302D302E31322C302E312D302E32322C302E32322D302E323268312E333363302E31312D302E30312C';
wwv_flow_imp.g_varchar2_table(68) := '302E32312C302E30382C302E32322C302E3263302C302E30312C302C302E30312C302C302E30325631332E35397A204D34392E39312C3134632D302E39382C302D312E39322D302E34312D322E362D312E313276332E373863302C302E31322D302E312C';
wwv_flow_imp.g_varchar2_table(69) := '302E32322D302E32322C302E3232682D312E3333632D302E31322C302D302E32322D302E312D302E32322D302E323256362E343563302D302E31322C302E312D302E32312C302E32322D302E323168312E333363302E31322C302C302E32322C302E312C';
wwv_flow_imp.g_varchar2_table(70) := '302E32322C302E323276302E3763302E36382D302E37322C312E36322D312E31322C322E362D312E313263322E30372C302C332E37352C312E37372C332E37352C332E39385335312E39382C31342C34392E39312C31347A204D36332E30392C31302E38';
wwv_flow_imp.g_varchar2_table(71) := '374336322E37322C31322E36352C36312E32322C31342C35392E34332C3134632D302E39382C302D312E39322D302E34312D322E362D312E313276302E3763302C302E31322D302E312C302E32322D302E32322C302E3232682D312E3333632D302E3132';
wwv_flow_imp.g_varchar2_table(72) := '2C302D302E32322D302E312D302E32322D302E323256332E333763302D302E31322C302E312D302E32322C302E32322D302E323268312E333363302E31322C302C302E32322C302E312C302E32322C302E323276332E373863302E36382D302E37312C31';
wwv_flow_imp.g_varchar2_table(73) := '2E36322D312E31322C322E362D312E313163312E37392C302C332E32392C312E33332C332E36362C332E31324336332E32312C392E37332C36332E32312C31302E33312C36332E30392C31302E38374C36332E30392C31302E38374C36332E30392C3130';
wwv_flow_imp.g_varchar2_table(74) := '2E38377A204D36382E32362C31342E3031632D312E392C302E30312D332E35352D312E32392D332E39372D332E3134632D302E31322D302E35362D302E31322D312E31332C302D312E363963302E34322D312E38352C322E30372D332E31352C332E3937';
wwv_flow_imp.g_varchar2_table(75) := '2D332E313463322E32352C302C342E30362C312E37382C342E30362C332E39395337302E352C31342E30312C36382E32362C31342E30314C36382E32362C31342E30317A204D37392E30392C31332E3831682D312E3533632D302E31322C302D302E3233';
wwv_flow_imp.g_varchar2_table(76) := '2D302E30362D302E32392D302E31366C2D312E33372D322E32386C2D312E33372C322E3238632D302E30362C302E312D302E31372C302E31362D302E32392C302E3136682D312E3533632D302E30342C302D302E30382D302E30312D302E31312D302E30';
wwv_flow_imp.g_varchar2_table(77) := '33632D302E30392D302E30362D302E31322D302E31382D302E30362D302E323763302C302C302C302C302C306C322E33312D332E356C2D322E32382D332E3437632D302E30322D302E30332D302E30332D302E30372D302E30332D302E313163302D302E';
wwv_flow_imp.g_varchar2_table(78) := '31312C302E30392D302E322C302E322D302E3268312E353363302E31322C302C302E32332C302E30362C302E32392C302E31366C312E33342C322E32356C312E33342D322E323563302E30362D302E312C302E31372D302E31362C302E32392D302E3136';
wwv_flow_imp.g_varchar2_table(79) := '68312E353363302E30342C302C302E30382C302E30312C302E31312C302E303363302E30392C302E30362C302E31322C302E31382C302E30362C302E323763302C302C302C302C302C304C37362E39362C31306C322E33312C332E3563302E30322C302E';
wwv_flow_imp.g_varchar2_table(80) := '30332C302E30332C302E30372C302E30332C302E31314337392E32392C31332E37322C37392E322C31332E38312C37392E30392C31332E38314337392E30392C31332E38312C37392E30392C31332E38312C37392E30392C31332E38314C37392E30392C';
wwv_flow_imp.g_varchar2_table(81) := '31332E38317A222F3E3C7061746820636C6173733D227374302220643D224D31302C312E3231632D342E38372C302D382E38312C332E39352D382E38312C382E383173332E39352C382E38312C382E38312C382E383173382E38312D332E39352C382E38';
wwv_flow_imp.g_varchar2_table(82) := '312D382E38314331382E38312C352E31352C31342E38372C312E32312C31302C312E32317A204D31342E31382C31322E3139632D312E38342C312E38342D342E35352C322E322D362E33382C322E32632D302E36372C302D312E33342D302E30352D322D';
wwv_flow_imp.g_varchar2_table(83) := '302E313563302C302D302E39372D352E33372C322E30342D382E333963302E37392D302E37392C312E38362D312E32322C322E39382D312E323263312E32312C302C322E33372C302E34392C332E32332C312E33354331352E382C372E37332C31352E38';
wwv_flow_imp.g_varchar2_table(84) := '352C31302E352C31342E31382C31322E31397A222F3E3C7061746820636C6173733D227374312220643D224D31302C302E3032632D352E35322C302D31302C342E34382D31302C313073342E34382C31302C31302C31307331302D342E34382C31302D31';
wwv_flow_imp.g_varchar2_table(85) := '304331392E39392C342E352C31352E35322C302E30322C31302C302E30327A204D31302C31382E3833632D342E38372C302D382E38312D332E39352D382E38312D382E383153352E31332C312E322C31302C312E3273382E38312C332E39352C382E3831';
wwv_flow_imp.g_varchar2_table(86) := '2C382E38314331382E38312C31342E38392C31342E38372C31382E38332C31302C31382E38337A222F3E3C7061746820636C6173733D227374312220643D224D31342E30342C352E3938632D312E37352D312E37352D342E35332D312E38312D362E322D';
wwv_flow_imp.g_varchar2_table(87) := '302E313443342E38332C382E38362C352E382C31342E32332C352E382C31342E323373352E33372C302E39372C382E33392D322E30344331352E38352C31302E352C31352E382C372E37332C31342E30342C352E39387A204D31312E38382C392E38376C';
wwv_flow_imp.g_varchar2_table(88) := '2D302E38372C312E37386C2D302E38362D312E37384C382E33382C392E30316C312E37372D302E38366C302E38362D312E37386C302E38372C312E37386C312E37372C302E38364C31312E38382C392E38377A222F3E3C706F6C79676F6E20636C617373';
wwv_flow_imp.g_varchar2_table(89) := '3D227374302220706F696E74733D2231332E36352C392E30312031312E38382C392E38372031312E30312C31312E36352031302E31352C392E383720382E33382C392E30312031302E31352C382E31352031312E30312C362E33372031312E38382C382E';
wwv_flow_imp.g_varchar2_table(90) := '313520222F3E3C2F673E3C2F7376673E';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(178989814895527776)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_file_name=>'mapbox-attribution-logo.svg'
,p_mime_type=>'image/svg+xml'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F424153454D41505F53594D424F4C3D53796D626F6C28293B66756E6374696F6E206D6170626974735F626173656D61705F6572726F72287B6572726F723A657D297B617065782E6D6573736167652E73686F77457272';
wwv_flow_imp.g_varchar2_table(2) := '6F7273285B7B747970653A226572726F72222C6C6F636174696F6E3A2270616765222C6D6573736167653A657D5D297D66756E6374696F6E206D6170626974735F626173656D6170287B6974656D49643A652C726567696F6E49643A742C7469746C653A';
wwv_flow_imp.g_varchar2_table(3) := '612C69636F6E3A6F2C746F6F6C7469703A6E2C64656661756C745469746C653A692C64656661756C7449636F6E3A722C64656661756C74546F6F6C7469703A732C75726C3A6C2C6D61787A6F6F6D3A632C6572726F723A702C73686F77566563746F723A';
wwv_flow_imp.g_varchar2_table(4) := '642C696E697469616C6C7956697369626C653A6D2C6174747269627574696F6E3A5F2C736F75726365547970653A752C6A73436F6E6669673A792C706C7567696E46696C65733A687D297B636F6E737420673D224D6170626974735F426173656D61705F';
wwv_flow_imp.g_varchar2_table(5) := '222B743B696628702972657475726E20623D702C766F696420617065782E6A5175657279282866756E6374696F6E28297B617065782E6D6573736167652E616C6572742862292C636F6E736F6C652E6C6F672862297D29293B76617220622C773D617065';
wwv_flow_imp.g_varchar2_table(6) := '782E726567696F6E2874293B6E756C6C213D773F772E656C656D656E742E6F6E28227370617469616C6D6170696E697469616C697A6564222C2828293D3E7B2166756E6374696F6E28297B76617220703D617065782E726567696F6E2874292E63616C6C';
wwv_flow_imp.g_varchar2_table(7) := '28226765744D61704F626A65637422293B6966282266756E6374696F6E223D3D747970656F6620702E7365745472616E73666F726D52657175657374297B636F6E737420533D702E5F726571756573744D616E616765723F2E5F7472616E73666F726D52';
wwv_flow_imp.g_varchar2_table(8) := '657175657374466E3B702E7365745472616E73666F726D52657175657374282828652C74293D3E6E65772055524C28646F63756D656E742E62617365555249292E6F726967696E3D3D3D6E65772055524C28652C646F63756D656E742E62617365555249';
wwv_flow_imp.g_varchar2_table(9) := '292E6F726967696E3F7B75726C3A657D3A22656C6F636174696F6E2E6F7261636C652E636F6D22213D3D6E65772055524C2865292E686F73746E616D653F7B75726C3A652C63726564656E7469616C733A226F6D6974227D3A2266756E6374696F6E223D';
wwv_flow_imp.g_varchar2_table(10) := '3D747970656F6620533F5328652C74293A7B75726C3A657D29297D76617220623D617065782E73746F726167652E676574436F6F6B69652867293B696628702E6F6E636528226572726F72222C2866756E6374696F6E2874297B742E736F757263654964';
wwv_flow_imp.g_varchar2_table(11) := '3D3D652B222D736F75726365222626617065782E64656275672E6572726F7228742E6572726F722E6D657373616765297D29292C21705B4D4150424954535F424153454D41505F53594D424F4C5D297B636C61737320667B6F6E4164642865297B726574';
wwv_flow_imp.g_varchar2_table(12) := '75726E20746869732E5F6D61703D652C746869732E5F636F6E7461696E65723D2428223C6469763E22292E637373287B646973706C61793A226E6F6E65222C22666C65782D646972656374696F6E223A22726F77222C226A7573746966792D636F6E7465';
wwv_flow_imp.g_varchar2_table(13) := '6E74223A22666C65782D656E64222C70616464696E673A2232707820357078227D292E617070656E64282428223C6469763E22292E637373287B77696474683A2236357078222C6865696768743A2232307078222C6F766572666C6F773A226869646465';
wwv_flow_imp.g_varchar2_table(14) := '6E222C226261636B67726F756E642D696D616765223A6075726C28247B687D6D6170626F782D6174747269627574696F6E2D6C6F676F2E73766729602C226261636B67726F756E642D726570656174223A226E6F2D726570656174222C226261636B6772';
wwv_flow_imp.g_varchar2_table(15) := '6F756E642D706F736974696F6E223A22302030222C226261636B67726F756E642D73697A65223A22363570782032307078227D29292C746869732E5F636F6E7461696E65725B305D7D6F6E52656D6F766528297B746869732E5F636F6E7461696E65722E';
wwv_flow_imp.g_varchar2_table(16) := '706172656E744E6F64652E72656D6F76654368696C6428746869732E6D5F636F6E7461696E6572292C746869732E5F6D61703D766F696420307D7365744174747269627574696F6E2865297B22256D6170626F78223D3D3D653F28746869732E5F636F6E';
wwv_flow_imp.g_varchar2_table(17) := '7461696E65722E6373732822646973706C6179222C22666C657822292C705B4D4150424954535F424153454D41505F53594D424F4C5D2E6174747269627574696F6E4C6F676F3D7B75726C3A60247B687D6D6170626F782D6174747269627574696F6E2D';
wwv_flow_imp.g_varchar2_table(18) := '6C6F676F2E737667602C77696474683A36352C6865696768743A32307D293A28746869732E5F636F6E7461696E65722E6373732822646973706C6179222C226E6F6E6522292C705B4D4150424954535F424153454D41505F53594D424F4C5D2E61747472';
wwv_flow_imp.g_varchar2_table(19) := '69627574696F6E4C6F676F3D6E756C6C297D7D636F6E7374204D3D6E657720663B702E616464436F6E74726F6C284D2C22626F74746F6D2D726967687422293B636F6E737420423D5B7B69643A22626F756E64617279222C747970653A226C696E65222C';
wwv_flow_imp.g_varchar2_table(20) := '736F757263653A226F70656E6D617074696C6573222C22736F757263652D6C61796572223A22626F756E64617279222C7061696E743A7B226C696E652D636F6C6F72223A2223636363222C226C696E652D7769647468223A312C226C696E652D64617368';
wwv_flow_imp.g_varchar2_table(21) := '6172726179223A5B352C355D7D7D2C7B69643A22686967687761792D6C696E65222C747970653A226C696E65222C736F757263653A226F70656E6D617074696C6573222C22736F757263652D6C61796572223A227472616E73706F72746174696F6E222C';
wwv_flow_imp.g_varchar2_table(22) := '6D696E7A6F6F6D3A31322C7061696E743A7B226C696E652D636F6C6F72223A2223343434222C226C696E652D7769647468223A5B226D61746368222C5B22676574222C22636C617373225D2C226D6F746F72776179222C312C2E355D7D7D2C7B69643A22';
wwv_flow_imp.g_varchar2_table(23) := '706C616365222C747970653A2273796D626F6C222C736F757263653A226F70656E6D617074696C6573222C22736F757263652D6C61796572223A22706C616365222C66696C7465723A5B22213D222C5B22676574222C22636C617373225D2C22636F6E74';
wwv_flow_imp.g_varchar2_table(24) := '696E656E74225D2C6C61796F75743A7B22746578742D6669656C64223A5B22636F616C65736365222C5B22676574222C226E616D655F656E225D2C5B22676574222C226E616D65225D5D2C22746578742D666F6E74223A5B224D6574726F706F6C697320';
wwv_flow_imp.g_varchar2_table(25) := '426F6C64222C224E6F746F2053616E7320426F6C64225D2C22746578742D7472616E73666F726D223A5B226D61746368222C5B22676574222C22636C617373225D2C5B22636F756E747279222C227374617465225D2C22757070657263617365222C226E';
wwv_flow_imp.g_varchar2_table(26) := '6F6E65225D2C22746578742D73697A65223A5B22696E746572706F6C617465222C5B226C696E656172225D2C5B227A6F6F6D225D2C362C5B226D61746368222C5B22676574222C22636C617373225D2C22636F756E747279222C31322C22737461746522';
wwv_flow_imp.g_varchar2_table(27) := '2C31302C2263697479222C31302C385D2C31302C5B226D61746368222C5B22676574222C22636C617373225D2C22636F756E747279222C31342C227374617465222C31342C2263697479222C31312C31305D2C31322C5B226D61746368222C5B22676574';
wwv_flow_imp.g_varchar2_table(28) := '222C22636C617373225D2C22636F756E747279222C31362C227374617465222C31342C2263697479222C31342C31305D2C31342C5B226D61746368222C5B22676574222C22636C617373225D2C22636F756E747279222C31362C227374617465222C3134';
wwv_flow_imp.g_varchar2_table(29) := '2C2263697479222C31362C31325D5D7D2C7061696E743A7B22746578742D636F6C6F72223A22626C61636B222C22746578742D68616C6F2D636F6C6F72223A2223646464222C22746578742D68616C6F2D7769647468223A312E357D7D2C7B69643A2277';
wwv_flow_imp.g_varchar2_table(30) := '617465722D6E616D652D706F696E74222C747970653A2273796D626F6C222C736F757263653A226F70656E6D617074696C6573222C22736F757263652D6C61796572223A2277617465725F6E616D65222C66696C7465723A5B223D3D222C222474797065';
wwv_flow_imp.g_varchar2_table(31) := '222C22506F696E74225D2C6C61796F75743A7B22746578742D6669656C64223A5B22636F616C65736365222C5B22676574222C226E616D655F656E225D2C5B22676574222C226E616D65225D5D2C22746578742D666F6E74223A5B224D6574726F706F6C';
wwv_flow_imp.g_varchar2_table(32) := '697320426F6C64222C224E6F746F2053616E7320426F6C64225D2C22746578742D73697A65223A31327D2C7061696E743A7B22746578742D636F6C6F72223A2223313134222C22746578742D68616C6F2D636F6C6F72223A2223646464222C2274657874';
wwv_flow_imp.g_varchar2_table(33) := '2D68616C6F2D7769647468223A312E357D7D2C7B69643A2277617465722D6E616D652D6C696E65222C747970653A2273796D626F6C222C736F757263653A226F70656E6D617074696C6573222C22736F757263652D6C61796572223A2277617465727761';
wwv_flow_imp.g_varchar2_table(34) := '79222C66696C7465723A5B223D3D222C222474797065222C224C696E65537472696E67225D2C6C61796F75743A7B2273796D626F6C2D706C6163656D656E74223A226C696E65222C22746578742D6669656C64223A5B22636F616C65736365222C5B2267';
wwv_flow_imp.g_varchar2_table(35) := '6574222C226E616D655F656E225D2C5B22676574222C226E616D65225D5D2C22746578742D666F6E74223A5B224D6574726F706F6C697320426F6C64222C224E6F746F2053616E7320426F6C64225D2C22746578742D73697A65223A31327D2C7061696E';
wwv_flow_imp.g_varchar2_table(36) := '743A7B22746578742D636F6C6F72223A22626C61636B222C22746578742D68616C6F2D636F6C6F72223A2223636366222C22746578742D68616C6F2D7769647468223A312E357D7D2C7B69643A2268696768776179222C747970653A2273796D626F6C22';
wwv_flow_imp.g_varchar2_table(37) := '2C736F757263653A226F70656E6D617074696C6573222C22736F757263652D6C61796572223A227472616E73706F72746174696F6E5F6E616D65222C66696C7465723A5B223D3D222C222474797065222C224C696E65537472696E67225D2C6D696E7A6F';
wwv_flow_imp.g_varchar2_table(38) := '6F6D3A31322C6C61796F75743A7B2273796D626F6C2D706C6163656D656E74223A226C696E65222C22746578742D6669656C64223A5B22636F616C65736365222C5B22676574222C226E616D655F656E225D2C5B22676574222C226E616D65225D5D2C22';
wwv_flow_imp.g_varchar2_table(39) := '746578742D666F6E74223A5B224D6574726F706F6C697320426F6C64222C224E6F746F2053616E7320426F6C64225D2C22746578742D73697A65223A31307D2C7061696E743A7B22746578742D636F6C6F72223A2223333333222C22746578742D68616C';
wwv_flow_imp.g_varchar2_table(40) := '6F2D636F6C6F72223A2223636363222C22746578742D68616C6F2D7769647468223A312E357D7D5D3B66756E6374696F6E20772865297B6520696E20705B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F';
wwv_flow_imp.g_varchar2_table(41) := '6E7374727563746F7273262628705B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F72735B655D28292C64656C65746520705B4D4150424954535F424153454D41505F53594D424F4C';
wwv_flow_imp.g_varchar2_table(42) := '5D2E70656E64696E674C61796572436F6E7374727563746F72735B655D293B636F6E737420743D6E756C6C213D3D65262621286520696E20705B4D4150424954535F424153454D41505F53594D424F4C5D2E736B6970566563746F72293B666F7228636F';
wwv_flow_imp.g_varchar2_table(43) := '6E73742065206F66204229702E7365744C61796F757450726F706572747928652E69642C227669736962696C697479222C743F2276697369626C65223A226E6F6E6522293B666F7228636F6E73742074206F6620705B4D4150424954535F424153454D41';
wwv_flow_imp.g_varchar2_table(44) := '505F53594D424F4C5D2E6C617965727329702E6765744C6179657228742B222D6261636B67726F756E6422292626702E7365744C61796F757450726F706572747928742B222D6261636B67726F756E64222C227669736962696C697479222C743D3D3D65';
wwv_flow_imp.g_varchar2_table(45) := '3F2276697369626C65223A226E6F6E6522293B666F7228636F6E73742074206F66204129702E6765744C617965722874292626702E7365744C61796F757450726F706572747928742C227669736962696C697479222C6E756C6C3D3D3D653F2276697369';
wwv_flow_imp.g_varchar2_table(46) := '626C65223A226E6F6E6522293B4D2E7365744174747269627574696F6E28705B4D4150424954535F424153454D41505F53594D424F4C5D2E7370656369616C4174747269627574696F6E5B655D297D666F7228636F6E73742050206F66204229502E6C61';
wwv_flow_imp.g_varchar2_table(47) := '796F75747C7C28502E6C61796F75743D7B7D292C502E6C61796F75742E7669736962696C6974793D226E6F6E65222C502E69643D226D6170626974732D626173656D61702D222B502E69642C702E6164644C6179657228502C226261636B67726F756E64';
wwv_flow_imp.g_varchar2_table(48) := '22293B636F6E737420413D5B226261636B67726F756E64222C227061726B222C227761746572222C226C616E64636F7665725F6963655F7368656C66222C226C616E64636F7665725F676C6163696572222C226C616E647573655F7265736964656E7469';
wwv_flow_imp.g_varchar2_table(49) := '616C222C226C616E64636F7665725F776F6F64222C227761746572776179222C2277617465725F6E616D65222C226275696C64696E67222C2274756E6E656C5F6D6F746F727761795F636173696E67222C2274756E6E656C5F6D6F746F727761795F696E';
wwv_flow_imp.g_varchar2_table(50) := '6E6572222C226165726F7761792D74617869776179222C226165726F7761792D72756E7761792D636173696E67222C226165726F7761792D61726561222C226165726F7761792D72756E776179222C22726F61645F617265615F70696572222C22726F61';
wwv_flow_imp.g_varchar2_table(51) := '645F70696572222C22686967687761795F70617468222C22686967687761795F6D696E6F72222C22686967687761795F6D616A6F725F636173696E67222C22686967687761795F6D616A6F725F696E6E6572222C22686967687761795F6D616A6F725F73';
wwv_flow_imp.g_varchar2_table(52) := '7562746C65222C22686967687761795F6D6F746F727761795F636173696E67222C22686967687761795F6D6F746F727761795F696E6E6572222C22686967687761795F6D6F746F727761795F737562746C65222C227261696C7761795F7472616E736974';
wwv_flow_imp.g_varchar2_table(53) := '222C227261696C7761795F7472616E7369745F646173686C696E65222C227261696C7761795F73657276696365222C227261696C7761795F736572766963655F646173686C696E65222C227261696C776179222C227261696C7761795F646173686C696E';
wwv_flow_imp.g_varchar2_table(54) := '65222C22686967687761795F6D6F746F727761795F6272696467655F636173696E67222C22686967687761795F6D6F746F727761795F6272696467655F696E6E6572222C22686967687761795F6E616D655F6F74686572222C22686967687761795F6E61';
wwv_flow_imp.g_varchar2_table(55) := '6D655F6D6F746F72776179222C22626F756E646172795F7374617465222C22626F756E646172795F636F756E7472795F7A302D34222C22626F756E646172795F636F756E7472795F7A352D222C22706C6163655F6F74686572222C22706C6163655F7375';
wwv_flow_imp.g_varchar2_table(56) := '62757262222C22706C6163655F76696C6C616765222C22706C6163655F746F776E222C22706C6163655F63697479222C22706C6163655F6361706974616C222C22706C6163655F636974795F6C61726765222C22706C6163655F7374617465222C22706C';
wwv_flow_imp.g_varchar2_table(57) := '6163655F636F756E7472795F6F74686572222C22706C6163655F636F756E7472795F6D696E6F72222C22706C6163655F636F756E7472795F6D616A6F72222C226C616E647573655F7061726B222C22726F61645F6F6E65776179222C22726F61645F6F6E';
wwv_flow_imp.g_varchar2_table(58) := '657761795F6F70706F73697465222C227261696C7761795F6D696E6F72222C227261696C7761795F6D696E6F725F646173686C696E65225D3B636C61737320787B636F6E7374727563746F7228297B7D6F6E4164642865297B72657475726E2074686973';
wwv_flow_imp.g_varchar2_table(59) := '2E6D5F6D61703D652C746869732E6D5F636F6E7461696E65723D646F63756D656E742E637265617465456C656D656E74282264697622292C746869732E6D5F636F6E7461696E65722E636C6173734E616D653D226D61706C69627265676C2D6374726C20';
wwv_flow_imp.g_varchar2_table(60) := '6D61706C69627265676C2D6374726C2D67726F7570206D6170626974732D626173656D61702D6374726C222C746869732E6D5F636F6E7461696E65727D6F6E52656D6F766528297B746869732E6D5F636F6E7461696E65722E706172656E744E6F64652E';
wwv_flow_imp.g_varchar2_table(61) := '72656D6F76654368696C6428746869732E6D5F636F6E7461696E6572292C746869732E6D5F6D61703D766F696420307D6164645374796C6528652C612C6F2C6E297B636F6E737420693D646F63756D656E742E637265617465456C656D656E7428226C61';
wwv_flow_imp.g_varchar2_table(62) := '62656C22293B692E636C6173734E616D653D226D6170626974732D626173656D61702D746F67676C65222C692E7469746C653D6E3F3F22223B636F6E737420723D646F63756D656E742E637265617465456C656D656E742822696E70757422293B722E74';
wwv_flow_imp.g_varchar2_table(63) := '7970653D22726164696F222C722E6E616D653D226D6170626974732D626173656D61702D73776974636865722D222B742C692E617070656E644368696C642872293B636F6E737420733D646F63756D656E742E637265617465456C656D656E7428226469';
wwv_flow_imp.g_varchar2_table(64) := '7622293B6966286F297B636F6E737420653D646F63756D656E742E637265617465456C656D656E7428226922293B652E636C6173734E616D653D60666120247B6F7D602C732E617070656E644368696C642865297D69662861297B636F6E737420653D64';
wwv_flow_imp.g_varchar2_table(65) := '6F63756D656E742E637265617465456C656D656E7428227370616E22293B652E696E6E657248544D4C3D6F3F22266E6273703B223A22222C652E696E6E657248544D4C2B3D612C732E617070656E644368696C642865297D692E617070656E644368696C';
wwv_flow_imp.g_varchar2_table(66) := '642873292C746869732E6D5F636F6E7461696E65722E617070656E644368696C642869292C28623D3D3D657C7C226E756C6C223D3D3D6226266E756C6C3D3D3D657C7C216226262259223D3D3D6D29262628722E636865636B65643D21302C7728652929';
wwv_flow_imp.g_varchar2_table(67) := '2C692E6164644576656E744C697374656E657228226368616E6765222C2828293D3E7B722E636865636B6564262628772865292C617065782E73746F726167652E736574436F6F6B696528672C6529297D29297D7D636F6E7374204C3D6E657720783B70';
wwv_flow_imp.g_varchar2_table(68) := '2E616464436F6E74726F6C284C2C22746F702D6C65667422292C705B4D4150424954535F424153454D41505F53594D424F4C5D3D7B6C61796572733A5B5D2C636F6E74726F6C3A4C2C70656E64696E674C61796572436F6E7374727563746F72733A7B7D';
wwv_flow_imp.g_varchar2_table(69) := '2C736B6970566563746F723A7B7D2C7370656369616C4174747269627574696F6E3A7B7D7D2C4C2E6164645374796C65286E756C6C2C692C722C73297D225922213D64262628705B4D4150424954535F424153454D41505F53594D424F4C5D2E736B6970';
wwv_flow_imp.g_varchar2_table(70) := '566563746F725B655D3D2130292C705B4D4150424954535F424153454D41505F53594D424F4C5D2E6C61796572732E707573682865292C705B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E73747275';
wwv_flow_imp.g_varchar2_table(71) := '63746F72735B655D3D28293D3E7B6C657420743D7B747970653A22726173746572222C74696C6553697A653A3235367D3B636F6E737420613D28293D3E7B705B4D4150424954535F424153454D41505F53594D424F4C5D2E7370656369616C4174747269';
wwv_flow_imp.g_varchar2_table(72) := '627574696F6E5B655D3D22256D6170626F78222C742E6174747269627574696F6E3D27C2A9203C6120687265663D2268747470733A2F2F7777772E6D6170626F782E636F6D2F61626F75742F6D6170732F223E4D6170626F783C2F613E20C2A9203C6120';
wwv_flow_imp.g_varchar2_table(73) := '687265663D22687474703A2F2F7777772E6F70656E7374726565746D61702E6F72672F636F70797269676874223E4F70656E5374726565744D61703C2F613E203C7374726F6E673E3C6120687265663D2268747470733A2F2F7777772E6D6170626F782E';
wwv_flow_imp.g_varchar2_table(74) := '636F6D2F6D61702D666565646261636B2F22207461726765743D225F626C616E6B223E496D70726F76652074686973206D61703C2F613E3C2F7374726F6E673E277D3B7377697463682875297B636173652274696C655F75726C223A743D7B2E2E2E742C';
wwv_flow_imp.g_varchar2_table(75) := '74696C65733A5B6C5D2C6D61787A6F6F6D3A637D2C766F69642030213D3D5F26262822256D6170626F78223D3D3D5F3F6128293A742E6174747269627574696F6E3D5F293B627265616B3B636173652274696C655F6A736F6E5F75726C223A742E75726C';
wwv_flow_imp.g_varchar2_table(76) := '3D6C2C226170692E6D6170626F782E636F6D223D3D3D6E65772055524C286C292E686F73746E616D6526266128293B627265616B3B64656661756C743A636F6E736F6C652E6C6F6728226D6170626974735F626173656D617020222B652B22203A20496E';
wwv_flow_imp.g_varchar2_table(77) := '76616C696420736F757263655479706520222B752B222E22297D6C6574206F3B6F3D2266756E6374696F6E223D3D747970656F6620793F7928293A792C743D7B2E2E2E742C2E2E2E6F7D2C702E616464536F7572636528652B222D736F75726365222C74';
wwv_flow_imp.g_varchar2_table(78) := '293B636F6E7374206E3D7B69643A652B222D6261636B67726F756E64222C747970653A22726173746572222C736F757263653A652B222D736F75726365227D3B702E6164644C61796572286E2C702E6765745374796C6528292E6C61796572735B305D2E';
wwv_flow_imp.g_varchar2_table(79) := '6964297D2C705B4D4150424954535F424153454D41505F53594D424F4C5D2E636F6E74726F6C2E6164645374796C6528652C612C6F2C6E297D28297D29293A636F6E736F6C652E6C6F6728226D6170626974735F626173656D617020222B652B22203A20';
wwv_flow_imp.g_varchar2_table(80) := '526567696F6E205B222B742B225D2069732068696464656E206F72206D697373696E672E22297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(197389492653927642)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_file_name=>'mapbits-basemap.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D6170626974732D626173656D61702D6374726C7B646973706C61793A666C65783B636F6C6F723A2330303021696D706F7274616E747D2E6D6170626974732D626173656D61702D746F67676C657B706F736974696F6E3A72656C61746976653B6469';
wwv_flow_imp.g_varchar2_table(2) := '73706C61793A696E6C696E652D626C6F636B3B6865696768743A333270783B637572736F723A706F696E7465727D2E6D6170626974732D626173656D61702D746F67676C6520696E7075747B77696474683A303B6865696768743A303B6F706163697479';
wwv_flow_imp.g_varchar2_table(3) := '3A303B706F736974696F6E3A6162736F6C7574657D2E6D6170626974732D626173656D61702D746F67676C65206469767B746F703A303B6C6566743A303B77696474683A313030253B6865696768743A313030253B70616464696E672D72696768743A31';
wwv_flow_imp.g_varchar2_table(4) := '3270783B70616464696E672D6C6566743A313270783B646973706C61793A666C65783B666C65782D646972656374696F6E3A726F773B616C69676E2D6974656D733A63656E7465727D2E6D6170626974732D626173656D61702D746F67676C6520696E70';
wwv_flow_imp.g_varchar2_table(5) := '75743A636865636B65642B6469767B626F726465722D7261646975733A3470783B6261636B67726F756E642D636F6C6F723A72676228302C302C302C2E32297D2E6D6170626974732D626173656D61702D746F67676C6520692E66612B7370616E7B6D61';
wwv_flow_imp.g_varchar2_table(6) := '7267696E2D72696768743A3270787D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(281752723810090126)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
,p_file_name=>'mapbits-basemap.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D6170626974732D626173656D61702D6374726C207B0D0A2020646973706C61793A20666C65783B0D0A2020636F6C6F723A20626C61636B2021696D706F7274616E743B0D0A7D0D0A0D0A2E6D6170626974732D626173656D61702D746F67676C6520';
wwv_flow_imp.g_varchar2_table(2) := '7B0D0A2020706F736974696F6E3A2072656C61746976653B0D0A2020646973706C61793A20696E6C696E652D626C6F636B3B0D0A20206865696768743A20333270783B0D0A2020637572736F723A20706F696E7465723B0D0A7D0D0A0D0A2E6D61706269';
wwv_flow_imp.g_varchar2_table(3) := '74732D626173656D61702D746F67676C6520696E707574207B0D0A202077696474683A20303B0D0A20206865696768743A20303B0D0A20206F7061636974793A20303B0D0A2020706F736974696F6E3A206162736F6C7574653B0D0A7D0D0A0D0A2E6D61';
wwv_flow_imp.g_varchar2_table(4) := '70626974732D626173656D61702D746F67676C6520646976207B0D0A2020746F703A20303B0D0A20206C6566743A20303B0D0A202077696474683A20313030253B0D0A20206865696768743A20313030253B0D0A7D0D0A0D0A2E6D6170626974732D6261';
wwv_flow_imp.g_varchar2_table(5) := '73656D61702D746F67676C6520646976207B0D0A202070616464696E672D72696768743A20313270783B0D0A202070616464696E672D6C6566743A20313270783B0D0A2020646973706C61793A20666C65783B0D0A2020666C65782D646972656374696F';
wwv_flow_imp.g_varchar2_table(6) := '6E3A20726F773B0D0A2020616C69676E2D6974656D733A2063656E7465723B0D0A7D0D0A0D0A2E6D6170626974732D626173656D61702D746F67676C6520696E7075743A636865636B65642B646976207B0D0A2020626F726465722D7261646975733A20';
wwv_flow_imp.g_varchar2_table(7) := '3470783B0D0A20206261636B67726F756E642D636F6C6F723A2072676228302C20302C20302C20302E32293B0D0A7D0D0A0D0A2E6D6170626974732D626173656D61702D746F67676C6520692E66612B7370616E207B0D0A20206D617267696E2D726967';
wwv_flow_imp.g_varchar2_table(8) := '68743A203270783B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(669836325178211662)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
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
wwv_flow_imp.g_varchar2_table(5) := '616C6C7956697369626C652C0D0A20206174747269627574696F6E2C0D0A2020736F75726365547970652C0D0A20206A73436F6E6669672C0D0A2020706C7567696E46696C65732C0D0A7D29207B0D0A2020636F6E737420636F6F6B69654E616D65203D';
wwv_flow_imp.g_varchar2_table(6) := '20274D6170626974735F426173656D61705F27202B20726567696F6E49643B0D0A0D0A20202F2F2072616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D65737361676520616E6420777269746520746F';
wwv_flow_imp.g_varchar2_table(7) := '20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C657274286D7367293B636F6E736F6C652E';
wwv_flow_imp.g_varchar2_table(8) := '6C6F67286D7367293B7D293B0D0A20207D0D0A202020200D0A20202F2F20696620616E206572726F72206F636375727320696E2074686520706C7567696E20706C73716C20616E642069732070617373656420696E746F20746865206A61766173637269';
wwv_flow_imp.g_varchar2_table(9) := '70742066756E6374696F6E2C200D0A20202F2F20726169736520616E20616C65727420776974682074686174206D6573736167652E0D0A2020696620286572726F7229207B0D0A20202020617065785F616C657274286572726F72293B0D0A2020202072';
wwv_flow_imp.g_varchar2_table(10) := '657475726E3B0D0A20207D0D0A0D0A202076617220726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0D0A202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020636F6E736F6C652E6C6F6728276D617062';
wwv_flow_imp.g_varchar2_table(11) := '6974735F626173656D61702027202B206974656D4964202B2027203A20526567696F6E205B27202B20726567696F6E4964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D';
wwv_flow_imp.g_varchar2_table(12) := '0A202066756E6374696F6E206F6E5374796C654C6F616465642829207B0D0A202020202F2F2067657420746865206D617020686F6F6B0D0A20202020766172206D6170203D20617065782E726567696F6E28726567696F6E4964292E63616C6C28226765';
wwv_flow_imp.g_varchar2_table(13) := '744D61704F626A65637422293B0D0A0D0A202020202F2A205772617020746865207472616E73666F726D526571756573742066756E6374696F6E20746F206164642063726564656E7469616C733A20226F6D69742220746F20616C6C2072657175657374';
wwv_flow_imp.g_varchar2_table(14) := '73200D0A20202020202074686174206172656E277420746F204F7261636C6527732073657276696365206F7220746F20415045582E204F74686572776973652C2077652077696C6C2067657420434F5253206572726F72732E202A2F0D0A202020206966';
wwv_flow_imp.g_varchar2_table(15) := '2028747970656F66206D61702E7365745472616E73666F726D52657175657374203D3D3D202266756E6374696F6E2229207B0D0A2020202020202F2A20544F444F3A20476574204D61704C6962726520746F206D616B6520616E2041504920666F722074';
wwv_flow_imp.g_varchar2_table(16) := '6869732C20726174686572207468616E20646570656E64696E67206F6E20696E7465726E616C73202A2F0D0A202020202020636F6E7374206F6C645472616E73666F726D52657175657374203D206D61702E5F726571756573744D616E616765723F2E5F';
wwv_flow_imp.g_varchar2_table(17) := '7472616E73666F726D52657175657374466E3B0D0A2020202020206D61702E7365745472616E73666F726D526571756573742828752C207265736F757263655479706529203D3E207B0D0A2020202020202020696620286E65772055524C28646F63756D';
wwv_flow_imp.g_varchar2_table(18) := '656E742E62617365555249292E6F726967696E203D3D3D206E65772055524C28752C20646F63756D656E742E62617365555249292E6F726967696E29207B0D0A2020202020202020202072657475726E207B75726C3A20757D3B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(19) := '7D20656C736520696620286E65772055524C2875292E686F73746E616D6520213D3D2027656C6F636174696F6E2E6F7261636C652E636F6D2729207B0D0A2020202020202020202072657475726E207B75726C3A20752C2063726564656E7469616C733A';
wwv_flow_imp.g_varchar2_table(20) := '20226F6D6974227D3B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202069662028747970656F66206F6C645472616E73666F726D52657175657374203D3D3D202266756E6374696F6E2229207B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(21) := '2072657475726E206F6C645472616E73666F726D5265717565737428752C207265736F7572636554797065293B0D0A202020202020202020207D20656C7365207B0D0A20202020202020202020202072657475726E207B75726C3A20757D3B0D0A202020';
wwv_flow_imp.g_varchar2_table(22) := '202020202020207D0D0A20202020202020207D0D0A2020202020207D293B0D0A202020207D0D0A0D0A20202020766172206C436F6F6B6965203D20617065782E73746F726167652E676574436F6F6B696528636F6F6B69654E616D65293B0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(23) := '20202F2F206F6E2061206D6170206572726F722C2063726561746520616E20616C6572742E0D0A202020206D61702E6F6E636528276572726F72272C2066756E6374696F6E286529207B0D0A20202020202069662028652E736F757263654964203D3D20';
wwv_flow_imp.g_varchar2_table(24) := '6974656D4964202B20222D736F757263652229207B0D0A2020202020202020617065782E64656275672E6572726F7228652E6572726F722E6D657373616765293B0D0A2020202020207D0D0A202020207D293B0D0A0D0A2020202069662028216D61705B';
wwv_flow_imp.g_varchar2_table(25) := '4D4150424954535F424153454D41505F53594D424F4C5D29207B0D0A202020202020636C617373204174747269627574696F6E4C6F676F207B0D0A20202020202020206F6E416464286D617029207B0D0A20202020202020202020746869732E5F6D6170';
wwv_flow_imp.g_varchar2_table(26) := '203D206D61703B0D0A202020202020202020202F2A20536565203C68747470733A2F2F646F63732E6D6170626F782E636F6D2F68656C702F67657474696E672D737461727465642F6174747269627574696F6E2F236F746865722D6D617070696E672D66';
wwv_flow_imp.g_varchar2_table(27) := '72616D65776F726B733E202A2F0D0A20202020202020202020746869732E5F636F6E7461696E6572203D202428273C6469763E27290D0A2020202020202020202020202E637373287B0D0A2020202020202020202020202020646973706C61793A20276E';
wwv_flow_imp.g_varchar2_table(28) := '6F6E65272C0D0A202020202020202020202020202027666C65782D646972656374696F6E273A2027726F77272C0D0A2020202020202020202020202020276A7573746966792D636F6E74656E74273A2027666C65782D656E64272C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(29) := '202020202020202770616464696E67273A202732707820357078272C0D0A2020202020202020202020207D290D0A2020202020202020202020202E617070656E64280D0A20202020202020202020202020202428273C6469763E27290D0A202020202020';
wwv_flow_imp.g_varchar2_table(30) := '202020202020202020202E637373287B0D0A20202020202020202020202020202020202077696474683A202736357078272C0D0A2020202020202020202020202020202020206865696768743A202732307078272C0D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(31) := '20202020206F766572666C6F773A202768696464656E272C0D0A202020202020202020202020202020202020276261636B67726F756E642D696D616765273A206075726C28247B706C7567696E46696C65737D6D6170626F782D6174747269627574696F';
wwv_flow_imp.g_varchar2_table(32) := '6E2D6C6F676F2E73766729602C0D0A202020202020202020202020202020202020276261636B67726F756E642D726570656174273A20276E6F2D726570656174272C0D0A202020202020202020202020202020202020276261636B67726F756E642D706F';
wwv_flow_imp.g_varchar2_table(33) := '736974696F6E273A2027302030272C0D0A202020202020202020202020202020202020276261636B67726F756E642D73697A65273A2027363570782032307078272C0D0A202020202020202020202020202020207D290D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(34) := '293B0D0A2020202020202020202072657475726E20746869732E5F636F6E7461696E65725B305D3B0D0A20202020202020207D0D0A0D0A20202020202020206F6E52656D6F76652829207B0D0A20202020202020202020746869732E5F636F6E7461696E';
wwv_flow_imp.g_varchar2_table(35) := '65722E706172656E744E6F64652E72656D6F76654368696C6428746869732E6D5F636F6E7461696E6572293B0D0A20202020202020202020746869732E5F6D6170203D20756E646566696E65643B0D0A20202020202020207D0D0A0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(36) := '207365744174747269627574696F6E286174747269627574696F6E29207B0D0A2020202020202020202073776974636820286174747269627574696F6E29207B0D0A202020202020202020202020636173652027256D6170626F78273A0D0A2020202020';
wwv_flow_imp.g_varchar2_table(37) := '202020202020202020746869732E5F636F6E7461696E65722E6373732827646973706C6179272C2027666C657827293B0D0A20202020202020202020202020202F2A20466F7220746865204578706F727420746F20496D61676520706C7567696E202A2F';
wwv_flow_imp.g_varchar2_table(38) := '0D0A20202020202020202020202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E6174747269627574696F6E4C6F676F203D207B0D0A2020202020202020202020202020202075726C3A2060247B706C7567696E46696C6573';
wwv_flow_imp.g_varchar2_table(39) := '7D6D6170626F782D6174747269627574696F6E2D6C6F676F2E737667602C0D0A2020202020202020202020202020202077696474683A2036352C0D0A202020202020202020202020202020206865696768743A2032302C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(40) := '2020207D3B0D0A2020202020202020202020202020627265616B3B0D0A20202020202020202020202064656661756C743A0D0A2020202020202020202020202020746869732E5F636F6E7461696E65722E6373732827646973706C6179272C20276E6F6E';
wwv_flow_imp.g_varchar2_table(41) := '6527293B0D0A20202020202020202020202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E6174747269627574696F6E4C6F676F203D206E756C6C3B0D0A202020202020202020207D0D0A20202020202020207D0D0A202020';
wwv_flow_imp.g_varchar2_table(42) := '2020207D0D0A0D0A202020202020636F6E7374206174747269627574696F6E4C6F676F203D206E6577204174747269627574696F6E4C6F676F28293B0D0A2020202020206D61702E616464436F6E74726F6C286174747269627574696F6E4C6F676F2C20';
wwv_flow_imp.g_varchar2_table(43) := '27626F74746F6D2D726967687427293B0D0A0D0A202020202020636F6E7374206C6179657244656673203D205B0D0A20202020202020207B0D0A20202020202020202020226964223A2022626F756E64617279222C0D0A20202020202020202020227479';
wwv_flow_imp.g_varchar2_table(44) := '7065223A20226C696E65222C0D0A2020202020202020202022736F75726365223A20226F70656E6D617074696C6573222C0D0A2020202020202020202022736F757263652D6C61796572223A2022626F756E64617279222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(45) := '227061696E74223A207B0D0A202020202020202020202020226C696E652D636F6C6F72223A202223636363222C0D0A202020202020202020202020226C696E652D7769647468223A20312C0D0A202020202020202020202020226C696E652D6461736861';
wwv_flow_imp.g_varchar2_table(46) := '72726179223A205B352C20355D0D0A202020202020202020207D2C0D0A20202020202020207D2C0D0A20202020202020207B0D0A20202020202020202020226964223A2022686967687761792D6C696E65222C0D0A202020202020202020202274797065';
wwv_flow_imp.g_varchar2_table(47) := '223A20226C696E65222C0D0A2020202020202020202022736F75726365223A20226F70656E6D617074696C6573222C0D0A2020202020202020202022736F757263652D6C61796572223A20227472616E73706F72746174696F6E222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(48) := '20202020226D696E7A6F6F6D223A2031322C0D0A20202020202020202020227061696E74223A207B0D0A202020202020202020202020226C696E652D636F6C6F72223A202223343434222C0D0A202020202020202020202020226C696E652D7769647468';
wwv_flow_imp.g_varchar2_table(49) := '223A205B0D0A2020202020202020202020202020226D61746368222C0D0A20202020202020202020202020205B22676574222C2022636C617373225D2C0D0A2020202020202020202020202020226D6F746F72776179222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(50) := '20202020312C0D0A2020202020202020202020202020302E350D0A2020202020202020202020205D2C0D0A202020202020202020207D2C0D0A20202020202020207D2C0D0A20202020202020207B0D0A20202020202020202020226964223A2022706C61';
wwv_flow_imp.g_varchar2_table(51) := '6365222C0D0A202020202020202020202274797065223A202273796D626F6C222C0D0A2020202020202020202022736F75726365223A20226F70656E6D617074696C6573222C0D0A2020202020202020202022736F757263652D6C61796572223A202270';
wwv_flow_imp.g_varchar2_table(52) := '6C616365222C0D0A202020202020202020202266696C746572223A205B22213D222C205B22676574222C2022636C617373225D2C2022636F6E74696E656E74225D2C0D0A20202020202020202020226C61796F7574223A207B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(53) := '20202022746578742D6669656C64223A205B22636F616C65736365222C205B22676574222C20226E616D655F656E225D2C205B22676574222C20226E616D65225D5D2C0D0A20202020202020202020202022746578742D666F6E74223A205B224D657472';
wwv_flow_imp.g_varchar2_table(54) := '6F706F6C697320426F6C64222C20224E6F746F2053616E7320426F6C64225D2C0D0A20202020202020202020202022746578742D7472616E73666F726D223A205B0D0A2020202020202020202020202020226D61746368222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(55) := '20202020205B22676574222C2022636C617373225D2C0D0A20202020202020202020202020205B22636F756E747279222C20227374617465225D2C0D0A202020202020202020202020202022757070657263617365222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(56) := '202020226E6F6E65220D0A2020202020202020202020205D2C0D0A20202020202020202020202022746578742D73697A65223A205B0D0A202020202020202020202020202022696E746572706F6C617465222C0D0A20202020202020202020202020205B';
wwv_flow_imp.g_varchar2_table(57) := '226C696E656172225D2C0D0A20202020202020202020202020205B227A6F6F6D225D2C0D0A2020202020202020202020202020362C20205B226D61746368222C205B22676574222C2022636C617373225D2C2022636F756E747279222C2031322C202273';
wwv_flow_imp.g_varchar2_table(58) := '74617465222C2031302C202263697479222C2031302C2020385D2C0D0A202020202020202020202020202031302C205B226D61746368222C205B22676574222C2022636C617373225D2C2022636F756E747279222C2031342C20227374617465222C2031';
wwv_flow_imp.g_varchar2_table(59) := '342C202263697479222C2031312C2031305D2C0D0A202020202020202020202020202031322C205B226D61746368222C205B22676574222C2022636C617373225D2C2022636F756E747279222C2031362C20227374617465222C2031342C202263697479';
wwv_flow_imp.g_varchar2_table(60) := '222C2031342C2031305D2C0D0A202020202020202020202020202031342C205B226D61746368222C205B22676574222C2022636C617373225D2C2022636F756E747279222C2031362C20227374617465222C2031342C202263697479222C2031362C2031';
wwv_flow_imp.g_varchar2_table(61) := '325D2C0D0A2020202020202020202020205D2C0D0A202020202020202020207D2C0D0A20202020202020202020227061696E74223A207B0D0A20202020202020202020202022746578742D636F6C6F72223A2022626C61636B222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(62) := '202020202022746578742D68616C6F2D636F6C6F72223A202223646464222C0D0A20202020202020202020202022746578742D68616C6F2D7769647468223A20312E350D0A202020202020202020207D0D0A20202020202020207D2C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(63) := '20207B0D0A20202020202020202020226964223A202277617465722D6E616D652D706F696E74222C0D0A202020202020202020202274797065223A202273796D626F6C222C0D0A2020202020202020202022736F75726365223A20226F70656E6D617074';
wwv_flow_imp.g_varchar2_table(64) := '696C6573222C0D0A2020202020202020202022736F757263652D6C61796572223A202277617465725F6E616D65222C0D0A202020202020202020202266696C746572223A205B223D3D222C20222474797065222C2022506F696E74225D2C0D0A20202020';
wwv_flow_imp.g_varchar2_table(65) := '202020202020226C61796F7574223A207B0D0A20202020202020202020202022746578742D6669656C64223A205B22636F616C65736365222C205B22676574222C20226E616D655F656E225D2C205B22676574222C20226E616D65225D5D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(66) := '20202020202020202022746578742D666F6E74223A205B224D6574726F706F6C697320426F6C64222C20224E6F746F2053616E7320426F6C64225D2C0D0A20202020202020202020202022746578742D73697A65223A2031322C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(67) := '20207D2C0D0A20202020202020202020227061696E74223A207B0D0A20202020202020202020202022746578742D636F6C6F72223A202223313134222C0D0A20202020202020202020202022746578742D68616C6F2D636F6C6F72223A20222364646422';
wwv_flow_imp.g_varchar2_table(68) := '2C0D0A20202020202020202020202022746578742D68616C6F2D7769647468223A20312E350D0A202020202020202020207D0D0A20202020202020207D2C0D0A20202020202020207B0D0A20202020202020202020226964223A202277617465722D6E61';
wwv_flow_imp.g_varchar2_table(69) := '6D652D6C696E65222C0D0A202020202020202020202274797065223A202273796D626F6C222C0D0A2020202020202020202022736F75726365223A20226F70656E6D617074696C6573222C0D0A2020202020202020202022736F757263652D6C61796572';
wwv_flow_imp.g_varchar2_table(70) := '223A20227761746572776179222C0D0A202020202020202020202266696C746572223A205B223D3D222C20222474797065222C20224C696E65537472696E67225D2C0D0A20202020202020202020226C61796F7574223A207B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(71) := '2020202273796D626F6C2D706C6163656D656E74223A20226C696E65222C0D0A20202020202020202020202022746578742D6669656C64223A205B22636F616C65736365222C205B22676574222C20226E616D655F656E225D2C205B22676574222C2022';
wwv_flow_imp.g_varchar2_table(72) := '6E616D65225D5D2C0D0A20202020202020202020202022746578742D666F6E74223A205B224D6574726F706F6C697320426F6C64222C20224E6F746F2053616E7320426F6C64225D2C0D0A20202020202020202020202022746578742D73697A65223A20';
wwv_flow_imp.g_varchar2_table(73) := '31322C0D0A202020202020202020207D2C0D0A20202020202020202020227061696E74223A207B0D0A20202020202020202020202022746578742D636F6C6F72223A2022626C61636B222C0D0A20202020202020202020202022746578742D68616C6F2D';
wwv_flow_imp.g_varchar2_table(74) := '636F6C6F72223A202223636366222C0D0A20202020202020202020202022746578742D68616C6F2D7769647468223A20312E350D0A202020202020202020207D0D0A20202020202020207D2C0D0A20202020202020207B0D0A2020202020202020202022';
wwv_flow_imp.g_varchar2_table(75) := '6964223A202268696768776179222C0D0A202020202020202020202274797065223A202273796D626F6C222C0D0A2020202020202020202022736F75726365223A20226F70656E6D617074696C6573222C0D0A2020202020202020202022736F75726365';
wwv_flow_imp.g_varchar2_table(76) := '2D6C61796572223A20227472616E73706F72746174696F6E5F6E616D65222C0D0A202020202020202020202266696C746572223A205B223D3D222C20222474797065222C20224C696E65537472696E67225D2C0D0A20202020202020202020226D696E7A';
wwv_flow_imp.g_varchar2_table(77) := '6F6F6D223A2031322C0D0A20202020202020202020226C61796F7574223A207B0D0A2020202020202020202020202273796D626F6C2D706C6163656D656E74223A20226C696E65222C0D0A20202020202020202020202022746578742D6669656C64223A';
wwv_flow_imp.g_varchar2_table(78) := '205B22636F616C65736365222C205B22676574222C20226E616D655F656E225D2C205B22676574222C20226E616D65225D5D2C0D0A20202020202020202020202022746578742D666F6E74223A205B224D6574726F706F6C697320426F6C64222C20224E';
wwv_flow_imp.g_varchar2_table(79) := '6F746F2053616E7320426F6C64225D2C0D0A20202020202020202020202022746578742D73697A65223A2031302C0D0A202020202020202020207D2C0D0A20202020202020202020227061696E74223A207B0D0A20202020202020202020202022746578';
wwv_flow_imp.g_varchar2_table(80) := '742D636F6C6F72223A202223333333222C0D0A20202020202020202020202022746578742D68616C6F2D636F6C6F72223A202223636363222C0D0A20202020202020202020202022746578742D68616C6F2D7769647468223A20312E350D0A2020202020';
wwv_flow_imp.g_varchar2_table(81) := '20202020207D0D0A20202020202020207D0D0A2020202020205D3B0D0A0D0A20202020202066756E6374696F6E20746F67676C655374796C65287374796C65494429207B0D0A2020202020202020696620287374796C65494420696E206D61705B4D4150';
wwv_flow_imp.g_varchar2_table(82) := '424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F727329207B0D0A202020202020202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572';
wwv_flow_imp.g_varchar2_table(83) := '436F6E7374727563746F72735B7374796C6549445D28293B0D0A2020202020202020202064656C657465206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E70656E64696E674C61796572436F6E7374727563746F72735B7374796C';
wwv_flow_imp.g_varchar2_table(84) := '6549445D3B0D0A20202020202020207D0D0A2020202020202020636F6E73742073686F77566563746F724F7665726C6179203D207374796C65494420213D3D206E756C6C2026262021287374796C65494420696E206D61705B4D4150424954535F424153';
wwv_flow_imp.g_varchar2_table(85) := '454D41505F53594D424F4C5D2E736B6970566563746F72293B0D0A2020202020202020666F722028636F6E7374206C206F66206C617965724465667329207B0D0A202020202020202020206D61702E7365744C61796F757450726F7065727479286C2E69';
wwv_flow_imp.g_varchar2_table(86) := '642C20277669736962696C697479272C2073686F77566563746F724F7665726C6179203F202776697369626C6527203A20276E6F6E6527293B0D0A20202020202020207D0D0A2020202020202020666F722028636F6E7374206C206F66206D61705B4D41';
wwv_flow_imp.g_varchar2_table(87) := '50424954535F424153454D41505F53594D424F4C5D2E6C617965727329207B0D0A20202020202020202020696620286D61702E6765744C61796572286C202B20272D6261636B67726F756E64272929207B0D0A2020202020202020202020206D61702E73';
wwv_flow_imp.g_varchar2_table(88) := '65744C61796F757450726F7065727479286C202B20272D6261636B67726F756E64272C20277669736962696C697479272C206C203D3D3D207374796C654944203F202776697369626C6527203A20276E6F6E6527293B0D0A202020202020202020207D0D';
wwv_flow_imp.g_varchar2_table(89) := '0A20202020202020207D0D0A2020202020202020666F722028636F6E7374206C206F6620706F736974726F6E4C617965727329207B0D0A20202020202020202020696620286D61702E6765744C61796572286C2929207B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(90) := '206D61702E7365744C61796F757450726F7065727479286C2C20277669736962696C697479272C207374796C654944203D3D3D206E756C6C203F202776697369626C6527203A20276E6F6E6527293B0D0A202020202020202020207D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(91) := '20207D0D0A0D0A20202020202020206174747269627574696F6E4C6F676F2E7365744174747269627574696F6E286D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E7370656369616C4174747269627574696F6E5B7374796C654944';
wwv_flow_imp.g_varchar2_table(92) := '5D293B0D0A2020202020207D0D0A0D0A2020202020202F2A20416464206F757220766563746F72206C617965727320626568696E64207468652064656661756C74207374796C652773206261636B67726F756E64202A2F0D0A202020202020666F722028';
wwv_flow_imp.g_varchar2_table(93) := '636F6E7374206C61796572206F66206C617965724465667329207B0D0A202020202020202069662028216C617965722E6C61796F757429207B0D0A202020202020202020206C617965722E6C61796F7574203D207B7D3B0D0A20202020202020207D0D0A';
wwv_flow_imp.g_varchar2_table(94) := '20202020202020206C617965722E6C61796F75742E7669736962696C697479203D20226E6F6E65223B0D0A20202020202020206C617965722E6964203D20226D6170626974732D626173656D61702D22202B206C617965722E69643B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(95) := '20206D61702E6164644C61796572286C617965722C20226261636B67726F756E6422293B0D0A2020202020207D0D0A0D0A2020202020202F2A20546869732069732061206C697374206F6620616C6C20746865206C6179657273207765206E6565642074';
wwv_flow_imp.g_varchar2_table(96) := '6F20686964652066726F6D2074686520506F736974726F6E206F72204461726B204D6174746572207374796C650D0A20202020202020207768656E2077652073776974636820746F206F757220626173656D6170202A2F0D0A202020202020636F6E7374';
wwv_flow_imp.g_varchar2_table(97) := '20706F736974726F6E4C6179657273203D205B0D0A2020202020202020226261636B67726F756E64222C20227061726B222C20227761746572222C20226C616E64636F7665725F6963655F7368656C66222C20226C616E64636F7665725F676C61636965';
wwv_flow_imp.g_varchar2_table(98) := '72222C20226C616E647573655F7265736964656E7469616C222C20226C616E64636F7665725F776F6F64222C20227761746572776179222C0D0A20202020202020202277617465725F6E616D65222C20226275696C64696E67222C202274756E6E656C5F';
wwv_flow_imp.g_varchar2_table(99) := '6D6F746F727761795F636173696E67222C202274756E6E656C5F6D6F746F727761795F696E6E6572222C20226165726F7761792D74617869776179222C20226165726F7761792D72756E7761792D636173696E67222C20226165726F7761792D61726561';
wwv_flow_imp.g_varchar2_table(100) := '222C0D0A2020202020202020226165726F7761792D72756E776179222C2022726F61645F617265615F70696572222C2022726F61645F70696572222C2022686967687761795F70617468222C2022686967687761795F6D696E6F72222C20226869676877';
wwv_flow_imp.g_varchar2_table(101) := '61795F6D616A6F725F636173696E67222C2022686967687761795F6D616A6F725F696E6E6572222C0D0A202020202020202022686967687761795F6D616A6F725F737562746C65222C2022686967687761795F6D6F746F727761795F636173696E67222C';
wwv_flow_imp.g_varchar2_table(102) := '2022686967687761795F6D6F746F727761795F696E6E6572222C2022686967687761795F6D6F746F727761795F737562746C65222C20227261696C7761795F7472616E736974222C0D0A2020202020202020227261696C7761795F7472616E7369745F64';
wwv_flow_imp.g_varchar2_table(103) := '6173686C696E65222C20227261696C7761795F73657276696365222C20227261696C7761795F736572766963655F646173686C696E65222C20227261696C776179222C20227261696C7761795F646173686C696E65222C2022686967687761795F6D6F74';
wwv_flow_imp.g_varchar2_table(104) := '6F727761795F6272696467655F636173696E67222C0D0A202020202020202022686967687761795F6D6F746F727761795F6272696467655F696E6E6572222C2022686967687761795F6E616D655F6F74686572222C2022686967687761795F6E616D655F';
wwv_flow_imp.g_varchar2_table(105) := '6D6F746F72776179222C2022626F756E646172795F7374617465222C2022626F756E646172795F636F756E7472795F7A302D34222C2022626F756E646172795F636F756E7472795F7A352D222C0D0A202020202020202022706C6163655F6F7468657222';
wwv_flow_imp.g_varchar2_table(106) := '2C2022706C6163655F737562757262222C2022706C6163655F76696C6C616765222C2022706C6163655F746F776E222C2022706C6163655F63697479222C2022706C6163655F6361706974616C222C2022706C6163655F636974795F6C61726765222C20';
wwv_flow_imp.g_varchar2_table(107) := '22706C6163655F7374617465222C2022706C6163655F636F756E7472795F6F74686572222C0D0A202020202020202022706C6163655F636F756E7472795F6D696E6F72222C2022706C6163655F636F756E7472795F6D616A6F72222C20226C616E647573';
wwv_flow_imp.g_varchar2_table(108) := '655F7061726B222C2022726F61645F6F6E65776179222C2022726F61645F6F6E657761795F6F70706F73697465222C20227261696C7761795F6D696E6F72222C20227261696C7761795F6D696E6F725F646173686C696E65222C0D0A2020202020205D3B';
wwv_flow_imp.g_varchar2_table(109) := '0D0A0D0A202020202020636C617373205374796C655377697463686572207B0D0A2020202020202020636F6E7374727563746F722829207B7D0D0A0D0A20202020202020206F6E416464286D617029207B0D0A20202020202020202020746869732E6D5F';
wwv_flow_imp.g_varchar2_table(110) := '6D6170203D206D61703B0D0A20202020202020202020746869732E6D5F636F6E7461696E6572203D20646F63756D656E742E637265617465456C656D656E74282764697627293B0D0A20202020202020202020746869732E6D5F636F6E7461696E65722E';
wwv_flow_imp.g_varchar2_table(111) := '636C6173734E616D65203D20276D61706C69627265676C2D6374726C206D61706C69627265676C2D6374726C2D67726F7570206D6170626974732D626173656D61702D6374726C273B0D0A2020202020202020202072657475726E20746869732E6D5F63';
wwv_flow_imp.g_varchar2_table(112) := '6F6E7461696E65723B0D0A20202020202020207D0D0A0D0A20202020202020206F6E52656D6F76652829207B0D0A20202020202020202020746869732E6D5F636F6E7461696E65722E706172656E744E6F64652E72656D6F76654368696C642874686973';
wwv_flow_imp.g_varchar2_table(113) := '2E6D5F636F6E7461696E6572293B0D0A20202020202020202020746869732E6D5F6D6170203D20756E646566696E65643B0D0A20202020202020207D0D0A0D0A20202020202020206164645374796C652869642C207469746C652C2069636F6E2C20746F';
wwv_flow_imp.g_varchar2_table(114) := '6F6C74697029207B0D0A20202020202020202020636F6E7374206374726C203D20646F63756D656E742E637265617465456C656D656E7428276C6162656C27293B0D0A202020202020202020206374726C2E636C6173734E616D65203D20276D61706269';
wwv_flow_imp.g_varchar2_table(115) := '74732D626173656D61702D746F67676C65273B0D0A202020202020202020206374726C2E7469746C65203D20746F6F6C746970203F3F2027273B0D0A20202020202020202020636F6E737420696E707574203D20646F63756D656E742E63726561746545';
wwv_flow_imp.g_varchar2_table(116) := '6C656D656E742827696E70757427293B0D0A20202020202020202020696E7075742E74797065203D2027726164696F273B0D0A20202020202020202020696E7075742E6E616D65203D20276D6170626974732D626173656D61702D73776974636865722D';
wwv_flow_imp.g_varchar2_table(117) := '27202B20726567696F6E49643B0D0A202020202020202020206374726C2E617070656E644368696C6428696E707574293B0D0A20202020202020202020636F6E737420646976203D20646F63756D656E742E637265617465456C656D656E742827646976';
wwv_flow_imp.g_varchar2_table(118) := '27293B0D0A0D0A202020202020202020206966202869636F6E29207B0D0A202020202020202020202020636F6E73742069203D20646F63756D656E742E637265617465456C656D656E7428276927293B0D0A202020202020202020202020692E636C6173';
wwv_flow_imp.g_varchar2_table(119) := '734E616D65203D2060666120247B69636F6E7D603B0D0A2020202020202020202020206469762E617070656E644368696C642869293B0D0A202020202020202020207D0D0A0D0A20202020202020202020696620287469746C6529207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(120) := '20202020202020636F6E7374207370616E203D20646F63756D656E742E637265617465456C656D656E7428277370616E27293B0D0A2020202020202020202020206966202869636F6E29207B0D0A20202020202020202020202020207370616E2E696E6E';
wwv_flow_imp.g_varchar2_table(121) := '657248544D4C203D2027266E6273703B273B0D0A2020202020202020202020207D20656C7365207B0D0A20202020202020202020202020207370616E2E696E6E657248544D4C203D2027273B0D0A2020202020202020202020207D202020200D0A202020';
wwv_flow_imp.g_varchar2_table(122) := '2020202020202020207370616E2E696E6E657248544D4C202B3D207469746C653B0D0A2020202020202020202020206469762E617070656E644368696C64287370616E293B0D0A202020202020202020207D0D0A0D0A202020202020202020206374726C';
wwv_flow_imp.g_varchar2_table(123) := '2E617070656E644368696C6428646976293B0D0A20202020202020202020746869732E6D5F636F6E7461696E65722E617070656E644368696C64286374726C293B0D0A0D0A20202020202020202020696620286C436F6F6B6965203D3D3D206964207C7C';
wwv_flow_imp.g_varchar2_table(124) := '20286C436F6F6B6965203D3D3D20226E756C6C22202626206964203D3D3D206E756C6C29207C7C2028216C436F6F6B696520262620696E697469616C6C7956697369626C65203D3D3D202759272929207B0D0A202020202020202020202020696E707574';
wwv_flow_imp.g_varchar2_table(125) := '2E636865636B6564203D20747275653B0D0A202020202020202020202020746F67676C655374796C65286964293B0D0A202020202020202020207D0D0A0D0A202020202020202020206374726C2E6164644576656E744C697374656E657228276368616E';
wwv_flow_imp.g_varchar2_table(126) := '6765272C202829203D3E207B0D0A202020202020202020202020636F6E737420636865636B6564203D20696E7075742E636865636B65643B0D0A0D0A20202020202020202020202069662028636865636B656429207B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(127) := '2020746F67676C655374796C65286964293B0D0A2020202020202020202020202020617065782E73746F726167652E736574436F6F6B696528636F6F6B69654E616D652C206964293B0D0A2020202020202020202020207D0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(128) := '7D293B0D0A20202020202020207D0D0A2020202020207D0D0A202020202020636F6E7374207374796C655377697463686572203D206E6577205374796C65537769746368657228293B0D0A2020202020206D61702E616464436F6E74726F6C287374796C';
wwv_flow_imp.g_varchar2_table(129) := '6553776974636865722C2027746F702D6C65667427293B0D0A0D0A2020202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D203D207B0D0A20202020202020206C61796572733A205B5D2C0D0A2020202020202020636F6E7472';
wwv_flow_imp.g_varchar2_table(130) := '6F6C3A207374796C6553776974636865722C0D0A202020202020202070656E64696E674C61796572436F6E7374727563746F72733A207B7D2C0D0A2020202020202020736B6970566563746F723A207B7D2C0D0A20202020202020207370656369616C41';
wwv_flow_imp.g_varchar2_table(131) := '74747269627574696F6E3A207B7D2C0D0A2020202020207D3B0D0A2020202020207374796C6553776974636865722E6164645374796C65286E756C6C2C2064656661756C745469746C652C2064656661756C7449636F6E2C2064656661756C74546F6F6C';
wwv_flow_imp.g_varchar2_table(132) := '746970293B0D0A202020207D0D0A0D0A202020206966202873686F77566563746F7220213D2027592729207B0D0A2020202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E736B6970566563746F725B6974656D49645D203D';
wwv_flow_imp.g_varchar2_table(133) := '20747275653B0D0A202020207D0D0A202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E6C61796572732E70757368286974656D4964293B0D0A202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D';
wwv_flow_imp.g_varchar2_table(134) := '2E70656E64696E674C61796572436F6E7374727563746F72735B6974656D49645D203D202829203D3E207B0D0A2020202020206C6574206F707473203D207B0D0A2020202020202020747970653A2027726173746572272C0D0A20202020202020207469';
wwv_flow_imp.g_varchar2_table(135) := '6C6553697A653A203235362C0D0A2020202020207D3B0D0A0D0A202020202020636F6E7374207365744D6170626F784174747269627574696F6E203D202829203D3E207B0D0A20202020202020206D61705B4D4150424954535F424153454D41505F5359';
wwv_flow_imp.g_varchar2_table(136) := '4D424F4C5D2E7370656369616C4174747269627574696F6E5B6974656D49645D203D2027256D6170626F78273B0D0A20202020202020206F7074732E6174747269627574696F6E203D2060C2A9203C6120687265663D2268747470733A2F2F7777772E6D';
wwv_flow_imp.g_varchar2_table(137) := '6170626F782E636F6D2F61626F75742F6D6170732F223E4D6170626F783C2F613E20C2A9203C6120687265663D22687474703A2F2F7777772E6F70656E7374726565746D61702E6F72672F636F70797269676874223E4F70656E5374726565744D61703C';
wwv_flow_imp.g_varchar2_table(138) := '2F613E203C7374726F6E673E3C6120687265663D2268747470733A2F2F7777772E6D6170626F782E636F6D2F6D61702D666565646261636B2F22207461726765743D225F626C616E6B223E496D70726F76652074686973206D61703C2F613E3C2F737472';
wwv_flow_imp.g_varchar2_table(139) := '6F6E673E603B0D0A2020202020207D3B0D0A0D0A2020202020207377697463682028736F757263655479706529207B0D0A202020202020202063617365202774696C655F75726C273A0D0A202020202020202020206F707473203D207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(140) := '202020202020202E2E2E6F7074732C0D0A20202020202020202020202074696C65733A205B75726C5D2C0D0A2020202020202020202020206D61787A6F6F6D2C0D0A202020202020202020207D3B0D0A2020202020202020202069662028617474726962';
wwv_flow_imp.g_varchar2_table(141) := '7574696F6E20213D3D20756E646566696E656429207B0D0A202020202020202020202020696620286174747269627574696F6E203D3D3D2027256D6170626F782729207B0D0A20202020202020202020202020207365744D6170626F7841747472696275';
wwv_flow_imp.g_varchar2_table(142) := '74696F6E28293B0D0A2020202020202020202020207D20656C7365207B0D0A20202020202020202020202020206F7074732E6174747269627574696F6E203D206174747269627574696F6E3B0D0A2020202020202020202020207D0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(143) := '2020207D0D0A20202020202020202020627265616B3B0D0A0D0A202020202020202063617365202774696C655F6A736F6E5F75726C273A0D0A202020202020202020206F7074732E75726C203D2075726C3B0D0A20202020202020202020696620286E65';
wwv_flow_imp.g_varchar2_table(144) := '772055524C2875726C292E686F73746E616D65203D3D3D20276170692E6D6170626F782E636F6D2729207B0D0A2020202020202020202020207365744D6170626F784174747269627574696F6E28293B0D0A202020202020202020207D0D0A2020202020';
wwv_flow_imp.g_varchar2_table(145) := '2020202020627265616B3B0D0A0D0A202020202020202064656661756C743A0D0A20202020202020202020636F6E736F6C652E6C6F6728276D6170626974735F626173656D61702027202B206974656D4964202B2027203A20496E76616C696420736F75';
wwv_flow_imp.g_varchar2_table(146) := '726365547970652027202B20736F7572636554797065202B20272E27293B0D0A20202020202020202020627265616B3B0D0A2020202020207D0D0A0D0A2020202020206C657420637573746F6D4F7074733B0D0A20202020202069662028747970656F66';
wwv_flow_imp.g_varchar2_table(147) := '206A73436F6E666967203D3D3D202766756E6374696F6E2729207B0D0A2020202020202020637573746F6D4F707473203D206A73436F6E66696728293B0D0A2020202020207D20656C7365207B0D0A2020202020202020637573746F6D4F707473203D20';
wwv_flow_imp.g_varchar2_table(148) := '6A73436F6E6669673B0D0A2020202020207D0D0A2020202020206F707473203D207B0D0A20202020202020202E2E2E6F7074732C0D0A20202020202020202E2E2E637573746F6D4F7074732C0D0A2020202020207D3B0D0A0D0A2020202020206D61702E';
wwv_flow_imp.g_varchar2_table(149) := '616464536F75726365286974656D4964202B20272D736F75726365272C206F707473293B0D0A0D0A202020202020636F6E7374206C61796572203D207B0D0A2020202020202020276964273A206974656D4964202B20272D6261636B67726F756E64272C';
wwv_flow_imp.g_varchar2_table(150) := '0D0A20202020202020202774797065273A2022726173746572222C0D0A202020202020202027736F75726365273A206974656D4964202B20272D736F75726365272C0D0A2020202020207D3B0D0A0D0A2020202020206D61702E6164644C61796572286C';
wwv_flow_imp.g_varchar2_table(151) := '617965722C206D61702E6765745374796C6528292E6C61796572735B305D2E6964293B0D0A202020207D3B0D0A202020206D61705B4D4150424954535F424153454D41505F53594D424F4C5D2E636F6E74726F6C2E6164645374796C65280D0A20202020';
wwv_flow_imp.g_varchar2_table(152) := '20206974656D49642C0D0A2020202020207469746C652C0D0A20202020202069636F6E2C0D0A202020202020746F6F6C7469700D0A20202020293B0D0A20207D0D0A0D0A2020726567696F6E2E656C656D656E742E6F6E28277370617469616C6D617069';
wwv_flow_imp.g_varchar2_table(153) := '6E697469616C697A6564272C202829203D3E207B0D0A202020206F6E5374796C654C6F6164656428293B0D0A20207D293B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(669836721205213132)
,p_plugin_id=>wwv_flow_imp.id(669819273995554433)
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
