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
--   Date and Time:   16:18 Tuesday January 28, 2025
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 908325001813202010
--   Manifest End
--   Version:         23.2.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_layer_lodestar
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(908325001813202010)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LAYER.LODESTAR'
,p_display_name=>'Mapbits Lodestar Layer'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#tiny-sdf.js',
'#PLUGIN_FILES#mapbits-lodestarlayer.js'))
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure mapbits_lodestarlayer',
'(',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_render_param,',
'  p_result in out nocopy apex_plugin.t_item_render_result',
')',
'is',
'  l_region_id varchar2(4000);',
'  l_sequence_no   number;',
'  l_title varchar2(400) := p_item.attribute_01;',
'  l_layer_definition clob := p_item.attribute_04;',
'  l_icon varchar2(400) := p_item.attribute_05;',
'  l_color varchar2(400) := p_item.attribute_06;',
'  l_opacity number := p_item.attribute_12;',
'  l_outline_color varchar2(400) := p_item.attribute_13;',
'  l_source_options clob := p_item.attribute_07;',
'  l_layer_type varchar2(100) := p_item.attribute_10;',
'  l_label_column varchar2(4000) := p_item.attribute_11;',
'  l_id_column varchar2(4000) := p_item.attribute_09;',
'  l_submit_items varchar2(4000) := p_item.attribute_14;',
'  l_source_type varchar2(100) := p_item.attribute_08;',
'  layer_def clob;',
'  l_da_count number;',
'  l_infowin_count number;',
'begin',
'  begin',
'    select nvl(r.static_id, ''R'' || r.region_id), i.display_sequence into l_region_id, l_sequence_no  ',
'      from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then',
'      raise_application_error(-20391, ''Configuration ERROR:  Mapbits Lodestar Layer Item ['' || p_item.name || ''] is not associated with a Map region.'');',
'  end;',
'',
'  -- If there are any dynamic actions attached to the click event, the client needs to know so',
'  -- it can set the cursor for the layer.',
'  select count(*)',
'    into l_da_count',
'    from apex_application_page_da',
'    where',
'      application_id = :APP_ID',
'      and page_id = :APP_PAGE_ID',
'      and ('','' || when_element || '','') like (''%,'' || p_item.name || '',%'')',
'      and when_event_internal_name = ''PLUGIN_MIL.ARMY.USACE.MAPBITS.LAYER.LODESTAR|ITEM TYPE|click'';',
'',
'  select count(*) into l_infowin_count from apex_application_page_items',
'    where',
'      application_id = :APP_ID',
'      and page_id = :APP_PAGE_ID',
'      and display_as_code = ''PLUGIN_MIL.ARMY.USACE.MAPBITS.LODESTAR_INFOWIN''',
'      and attribute_01 = p_item.name;',
'',
'  htp.p(''<div id="'' || p_item.name || ''" name="'' || p_item.name || ''"></div>'');',
'',
'  apex_javascript.add_onload_code(',
'    p_code => ''mapbits_lodestarlayer({''',
'    || apex_javascript.add_attribute(''itemId'', p_item.name)',
'    || apex_javascript.add_attribute(''ajaxIdentifier'', apex_plugin.get_ajax_identifier)',
'    || apex_javascript.add_attribute(''regionId'', l_region_id)',
'    || apex_javascript.add_attribute(''layerType'', l_layer_type)',
'    || apex_javascript.add_attribute(''sequenceNumber'', nvl(l_sequence_no, 0))',
'    || apex_javascript.add_attribute(''title'', l_title)',
'    || apex_javascript.add_attribute(''color'', l_color)',
'    || apex_javascript.add_attribute(''outlineColor'', l_outline_color)',
'    || apex_javascript.add_attribute(''opacity'', nvl(l_opacity, ''1''))',
'    || apex_javascript.add_attribute(''icon'', l_icon)',
'    || apex_javascript.add_attribute(''labelColumn'', l_label_column)',
'    || apex_javascript.add_attribute(''idColumn'', l_id_column)',
'    || apex_javascript.add_attribute(''submitItems'', l_submit_items)',
'    || apex_javascript.add_attribute(''sourceType'', l_source_type)',
'    || apex_javascript.add_attribute(''clickable'', case when l_da_count + l_infowin_count > 0 then true else false end)',
'    || ''layerDefinition: '' || nvl(l_layer_definition, ''null'') || '',''',
'    || ''sourceOptions: '' || nvl(l_source_options, ''null'') || '',''',
'    || ''});'',',
'    p_key => ''MIL.ARMY.USACE.MAPBITS.LAYER.LODESTAR'' || p_item.name);',
'end;',
'',
'procedure mapbits_lodestarlayer_ajax (',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_ajax_param,',
'  p_result in out nocopy apex_plugin.t_item_ajax_result',
')',
'is',
'  source_type varchar2(100) := p_item.attribute_08;',
'  source_query clob;',
'  id_column varchar2(4000) := p_item.attribute_09;',
'  geometry_column varchar2(4000) := p_item.attribute_03;',
'',
'  is_first_feature boolean := true;',
'  n_cols integer;',
'  feature json_object_t;',
'  feature_props json_object_t;',
'  geometry sdo_geometry;',
'  query_ctx apex_exec.t_context;',
'  column_list apex_exec.t_columns;',
'  id_col number := 0;',
'  geometry_col number := 0;',
'begin',
'  if source_type = ''region_source'' then',
'    query_ctx := apex_region.open_query_context(',
'      p_page_id => :APP_PAGE_ID,',
'      p_region_id => p_item.region_id',
'    );',
'  else',
'    query_ctx := apex_exec.open_query_context(',
'      p_location => apex_exec.c_location_local_db,',
'      p_sql_query => p_item.attribute_02',
'    );',
'  end if;',
'  n_cols := apex_exec.get_column_count(query_ctx);',
'  for i in 1..n_cols loop',
'    column_list(i) := apex_exec.get_column(query_ctx, i);',
'    if lower(column_list(i).name) = lower(geometry_column) then',
'      geometry_col := i;',
'    elsif lower(column_list(i).name) = lower(id_column) then',
'      id_col := i;',
'    end if;',
'  end loop;',
'',
'  if geometry_col = 0 then',
'    htp.prn(''{"error": "The geometry column ('' || geometry_column || '') is not present in the query."}'');',
'    return;',
'  elsif id_col = 0 and id_column is not null then',
'    htp.prn(''{"error": "The ID column ('' || id_column || '') is not present in the query."}'');',
'    return;',
'  end if;',
'',
'  htp.prn(''{',
'    "type": "FeatureCollection",',
'    "features": [',
'      '');',
'',
'  while apex_exec.next_row(query_ctx) loop',
'    feature := new json_object_t;',
'    feature.put(''type'', ''Feature'');',
'    feature_props := new json_object_t;',
'',
'    for i in 1..n_cols loop',
'      if i = geometry_col then',
'        geometry := apex_exec.get_sdo_geometry(query_ctx, i);',
'        if geometry is null then',
'          feature.put_null(''geometry'');',
'        else',
'          feature.put(''geometry'', json_element_t.parse(sdo_util.to_geojson(geometry)));',
'        end if;',
'      elsif i = id_col then',
'        case column_list(i).data_type',
'          when apex_exec.c_data_type_varchar2 then',
'            feature.put(''id'', apex_exec.get_varchar2(query_ctx, i));',
'          when apex_exec.c_data_type_number then',
'            feature.put(''id'', apex_exec.get_number(query_ctx, i));',
'          when apex_exec.c_data_type_date then',
'            feature.put(''id'', apex_exec.get_date(query_ctx, i));',
'          when apex_exec.c_data_type_timestamp then',
'            feature.put(''id'', apex_exec.get_timestamp(query_ctx, i));',
'          when apex_exec.c_data_type_clob then',
'            feature.put(''id'', apex_exec.get_clob(query_ctx, i));',
'        end case;',
'      else',
'        case column_list(i).data_type',
'          when apex_exec.c_data_type_varchar2 then',
'            feature_props.put(column_list(i).name, apex_exec.get_varchar2(query_ctx, i));',
'          when apex_exec.c_data_type_number then',
'            feature_props.put(column_list(i).name, apex_exec.get_number(query_ctx, i));',
'          when apex_exec.c_data_type_date then',
'            feature_props.put(column_list(i).name, apex_exec.get_date(query_ctx, i));',
'          when apex_exec.c_data_type_timestamp then',
'            feature_props.put(column_list(i).name, apex_exec.get_timestamp(query_ctx, i));',
'          when apex_exec.c_data_type_clob then',
'            feature_props.put(column_list(i).name, apex_exec.get_clob(query_ctx, i));',
'          else',
'            null;',
'        end case;',
'      end if;',
'    end loop;',
'    feature.put(''properties'', feature_props);',
'',
'    if not is_first_feature then',
'      htp.prn('','');',
'    end if;',
'    is_first_feature := false;',
'    ',
'    declare',
'      output_clob clob;',
'      offset pls_integer;',
'      chunk varchar2(4000);',
'    begin',
'      output_clob := feature.to_clob();',
'      while apex_string.next_chunk(output_clob, chunk, offset, 4000) loop',
'        htp.prn(chunk);',
'      end loop;',
'    end;',
'',
'  end loop;',
'  htp.prn('']}'');',
'end;',
''))
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'mapbits_lodestarlayer'
,p_ajax_function=>'mapbits_lodestarlayer_ajax'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits Lodestar Layer plugin provides an alternative map layer to Apex''s built-in layers. It includes advanced configuration options that expose the full power of MapLibre styling and labeling capability.'
,p_version_identifier=>'4.8.20250128'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Lodestar Layer',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_lodestar.sql 20090 2025-01-28 22:41:13Z b2eddjw9 $',
'Date     : $Date: 2025-01-28 16:41:13 -0600 (Tue, 28 Jan 2025) $',
'Revision : $Revision: 20090 $',
'Requires : Application Express >= 22.2',
'',
'07/31/2024 Add getSourceName()',
'07/29/2024 Fix bug where features with ID 0 were not selectable',
'06/14/2024 Add loading spinner to the native APEX legend. When hiding the layer on page load, make sure the checkbox changes immediately.',
'05/17/2024 In Lodestar Layer, if the specified icon is a file in #APP_FILES#, load it from its URL. Add load_start and load_end events.',
'',
'Version 4.7 Updates:',
'04/23/2024 Add waitForLoad, getLayerIDs, and getMap methods to item API. Set generateId: true in the source options when no ID column is configured and the custom JS doesn''t override it. Expand Outline Color attribute to all layer types. Add pointer '
||'cursor when a layer has an associated info window.',
'',
'Version 4.6 Updates:',
'02/29/2024 Add visibility_toggled event.',
'02/28/2024 Fix error when a layer contains a feature with null geometry.',
'02/20/2024 Fix crash when clustering is enabled.',
'02/12/2024 Hide attributes that don''t apply to JavaScript-sourced layers. Add "point" property to click events.',
'02/07/2024 Allow "MapLibre Source Options" to be an async function. Add "JavaScript" source option, where the MapLibre Source Options code provides data for the layer.',
'01/22/2024 Add getSourceData() function to Lodestar Layer item',
'12/18/2023 Fix bug where Feature Clicked event would not fire when the DA has multiple items',
'12/08/2023 Improve performance by fixing a duplicate request bug, using apexbeforerefresh instead of apexafterrefresh, and not waiting for spatialmapinitialized before starting AJAX calls.',
'12/06/2023 Implement hide(), show(), and isVisible(). Add `isTopmostLayer` to click event data.',
'12/04/2023 Raise an application error if this plugin item is not associated with a Map region.',
'12/01/2023 Fixed a bug where layers would sometimes not appear in the correct order. Allow layer definitions to override the sequence number.',
'11/14/2023 Added "Icon" attribute to custom layers so it can be used in the legend. Added Page Items To Submit attribute. Implemented refresh. Changed the AJAX PL/SQL code to stream the result, reducing memory consumption.',
'11/09/2023 Expanded "Label Column" to also work on line layers. Fixed a race condition that caused layers to sometimes not hide when unchecked.',
'11/07/2023 Added fill outline color. Added errors when a specified ID or shape column is not present in the query. Improved error handling. Added a ''click'' event. If any dynamic actions are registered for the ''click'' event, the feature will have a "p'
||'ointer" cursor.',
'11/03/2023 Initial Implementation.',
'',
''))
,p_files_version=>766
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(908325245026202011)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Name of the layer to display in the legend.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(908358615240584886)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Source Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910132959485474915)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'query'
,p_examples=>'select shape, usace_district_id from mb4_usace_districts'
,p_help_text=>'Source query used to define the layer. At a minimum this must include an SDOGeometry column. Additional attributes should include a unique identifier column if labeling features or interaction with features is required. Any additional attributes that'
||' are included in the query can be used for constructing labels or other MapLibre attribute operations.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(908339311272293205)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Geometry Column'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910132959485474915)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'javascript'
,p_help_text=>'Column from the source query that represents the geometry as SDOGeometry objects.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(908354416367487095)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'MapLibre Layer Definition'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'custom'
,p_help_text=>'A MapLibre layer definition. Can either be a JavaScript expression or a function that takes no arguments and returns the layer definition. See https://maplibre.org/maplibre-style-spec/layers/ for documentation.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(910871523361251569)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Icon'
,p_attribute_type=>'ICON'
,p_is_required=>false
,p_default_value=>'fa-map-marker'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'symbol,custom'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'fa-circle',
'#APP_FILES#icon.png'))
,p_help_text=>'Icon used to symbolize features for a ''Symbol'' layer type. For a ''Custom'' layer type, this icon is only shown in the Legend. This can be a Font APEX icon or a path to an image in #APP_FILES#.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(908630340669759693)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>45
,p_prompt=>'Color'
,p_attribute_type=>'COLOR'
,p_is_required=>true
,p_default_value=>'#0000FF'
,p_is_translatable=>false
,p_help_text=>'Color of features and of the checkbox in the legend. Custom layers can override this property.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(909585620752946860)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'MapLibre Source Options'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Control point feature clustering:',
'',
'{',
'  cluster: true,',
'  clusterMinPoints: 5,',
'  clusterMaxZoom: 13,',
'  clusterProperties: {',
'    totalVolume: [''+'', [''get'', ''volume'']]',
'  }',
'}',
'',
'Provide data, when the JavaScript source type is chosen:',
'',
'async function() {',
'  return {',
'    data: {',
'      type: ''FeatureCollection'',',
'      features: [/* ... */],',
'    }',
'  };',
'}'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Additional options for the GeoJSON source in MapLibre.',
'',
'See <https://maplibre.org/maplibre-style-spec/sources/#geojson> for a full list of accepted attributes.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(910132959485474915)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>15
,p_prompt=>'Source Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'query'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(910133507679475712)
,p_plugin_attribute_id=>wwv_flow_imp.id(910132959485474915)
,p_display_sequence=>10
,p_display_value=>'SQL Query'
,p_return_value=>'query'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(910133976578476823)
,p_plugin_attribute_id=>wwv_flow_imp.id(910132959485474915)
,p_display_sequence=>20
,p_display_value=>'Region Source'
,p_return_value=>'region_source'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(612473764070852266)
,p_plugin_attribute_id=>wwv_flow_imp.id(910132959485474915)
,p_display_sequence=>30
,p_display_value=>'JavaScript'
,p_return_value=>'javascript'
,p_help_text=>'The data is provided by JavaScript code in the Source Options attribute through the returned data property.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(910800028520886703)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>25
,p_prompt=>'Id Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910132959485474915)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'javascript'
,p_help_text=>'Column from the source query that uniquely identifies the rows in the query. This is usually the primary key column.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(910915729958609763)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>5
,p_prompt=>'Layer Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'symbol'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Defines the layer type. ''Symbol'' is used for point features, ''Line'' for line features, and ''Fill'' for polygon features. Layer type selection toggles on the appropriate attributes for that layer types and toggles off the unrelated attributes. If more '
||'advanced configuration is needed, select the ''Custom Layer'' type to define the layer attributes with javascript.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(910916829296612585)
,p_plugin_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_display_sequence=>10
,p_display_value=>'Symbol'
,p_return_value=>'symbol'
,p_is_quick_pick=>true
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(910918163135619515)
,p_plugin_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_display_sequence=>20
,p_display_value=>'Line'
,p_return_value=>'line'
,p_is_quick_pick=>true
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(910918538898620134)
,p_plugin_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_display_sequence=>30
,p_display_value=>'Fill'
,p_return_value=>'fill'
,p_is_quick_pick=>true
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(910919213077626696)
,p_plugin_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_display_sequence=>40
,p_display_value=>'Custom'
,p_return_value=>'custom'
,p_is_quick_pick=>true
,p_help_text=>'Define a layer using a raw MapLibre layer definition. Mapbits will still provide some default settings.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(910922399313657492)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Label Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'symbol,line'
,p_help_text=>'Column used to label features.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(914701149705673059)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>47
,p_prompt=>'Opacity'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'1'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'custom'
,p_help_text=>'A number between 0.0 and 1.0 that defines the opacity of the features, where 0.0 is completely transparent and 1.0 is completely opaque. Note that opacity is applied to individual features, not the layer as a whole.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(873689773901665930)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>48
,p_prompt=>'Outline Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#000000'
,p_is_translatable=>false
,p_help_text=>'The outline color of the polygon, or the halo color of the symbol.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(723687681881964620)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>21
,p_prompt=>'Page Items To Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910132959485474915)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'javascript'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(873791521496399839)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_name=>'click'
,p_display_name=>'Feature Clicked'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(467043078161569658)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_name=>'load_end'
,p_display_name=>'Loading Finished'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(467042747058569658)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_name=>'load_start'
,p_display_name=>'Loading Started'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(624078281391902193)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_name=>'visibility_toggled'
,p_display_name=>'Visibility Toggled'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E737420494D4147455F48414E444C45525F41444445443D53796D626F6C28293B66756E6374696F6E206D6170626974735F6C6F6465737461726C617965725F6572726F72287B6572726F723A657D297B617065782E6D6573736167652E73686F77';
wwv_flow_imp.g_varchar2_table(2) := '4572726F7273285B7B747970653A226572726F72222C6C6F636174696F6E3A2270616765222C6D6573736167653A657D5D297D636F6E7374204D4150424954535F4C4F4445535441525F4C415945525F57414954494E473D7B7D3B66756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(3) := '6D6170626974735F6C6F6465737461726C617965725F776169745F666F725F696E69742865297B72657475726E206E65772050726F6D697365282828742C61293D3E7B6520696E204D4150424954535F4C4F4445535441525F4C415945525F5741495449';
wwv_flow_imp.g_varchar2_table(4) := '4E477C7C284D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D3D5B5D292C6E756C6C213D3D4D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D3F4D4150424954535F4C4F444553544152';
wwv_flow_imp.g_varchar2_table(5) := '5F4C415945525F57414954494E475B655D2E707573682828653D3E7B742865297D29293A7428617065782E6974656D286529297D29297D66756E6374696F6E206D6170626974735F6C6F6465737461726C61796572287B6974656D49643A652C616A6178';
wwv_flow_imp.g_varchar2_table(6) := '4964656E7469666965723A742C726567696F6E49643A612C6C61796572547970653A692C6C6162656C436F6C756D6E3A6F2C6C61796572446566696E6974696F6E3A412C73657175656E63654E756D6265723A722C7469746C653A6E2C636F6C6F723A6C';
wwv_flow_imp.g_varchar2_table(7) := '2C6F7061636974793A732C6F75746C696E65436F6C6F723A642C69636F6E3A632C736F757263654F7074696F6E733A702C6964436F6C756D6E3A792C636C69636B61626C653A672C7375626D69744974656D733A752C736F75726365547970653A6D7D29';
wwv_flow_imp.g_varchar2_table(8) := '7B69662821612972657475726E20766F696420617065782E64656275672E6572726F7228226D6170626974735F6C6F6465737461726C6179657220222B652B22203A204974656D206973206E6F7420696E206120726567696F6E2E22293B6C657420493D';
wwv_flow_imp.g_varchar2_table(9) := '5B5D3B636F6E7374205F3D652B222D736F75726365223B6C657420663D617065782E73746F726167652E676574436F6F6B696528224D6170626974735F4C6F6465737461724C617965725F222B652B225F222B2476282270496E7374616E63652229293B';
wwv_flow_imp.g_varchar2_table(10) := '76617220452C423D6E756C6C3B6C657420683D653D3E7B663D657D2C773D6E756C6C3B636F6E737420623D6E65772050726F6D697365282828742C69293D3E7B636F6E7374206F3D617065782E726567696F6E2861293B6966286E756C6C3D3D6F297265';
wwv_flow_imp.g_varchar2_table(11) := '7475726E20617065782E64656275672E6572726F7228226D6170626974735F6C6F6465737461726C6179657220222B652B22203A20526567696F6E205B222B612B225D2069732068696464656E206F72206D697373696E672E22292C766F696420692829';
wwv_flow_imp.g_varchar2_table(12) := '3B6F2E656C656D656E742E6F6E28227370617469616C6D6170696E697469616C697A6564222C2828293D3E7B636F6E737420653D617065782E726567696F6E2861292E63616C6C28226765744D61704F626A65637422293B742865297D29297D29292E74';
wwv_flow_imp.g_varchar2_table(13) := '68656E2828743D3E28745B494D4147455F48414E444C45525F41444445445D7C7C742E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F61646465647C7C28742E6F6E28227374796C65696D6167656D697373696E67222C28653D';
wwv_flow_imp.g_varchar2_table(14) := '3E7B6D6170626974735F6C6F6465737461725F696D6167655F68616E646C65722865297D29292C742E5F5F6D6170626974735F6572726F725F68616E646C65725F61646465647C7C28742E6F6E28226572726F72222C28653D3E7B617065782E64656275';
wwv_flow_imp.g_varchar2_table(15) := '672E6572726F7228604D6170206572726F7220696E20726567696F6E20247B617D3A20602C652E6572726F72297D29292C742E5F5F6D6170626974735F6572726F725F68616E646C65725F61646465643D2130292C745B494D4147455F48414E444C4552';
wwv_flow_imp.g_varchar2_table(16) := '5F41444445445D3D21302C742E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F61646465643D2130292C6E65772050726F6D697365282828692C6F293D3E7B76617220413D736574496E74657276616C282866756E6374696F6E';
wwv_flow_imp.g_varchar2_table(17) := '28297B636F6E7374206F3D617065782E6A5175657279282223222B612B225F6C6567656E6422293B6F262628636C656172496E74657276616C2841292C617065782E6A517565727928273C64697620636C6173733D22612D4D6170526567696F6E2D6C65';
wwv_flow_imp.g_varchar2_table(18) := '67656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E3C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F7220';
wwv_flow_imp.g_varchar2_table(19) := '69732D636865636B65642220636865636B65643D22222069643D22272B652B275F6C6567656E645F656E74727922207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B6C2B27223E3C6C6162656C20636C';
wwv_flow_imp.g_varchar2_table(20) := '6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C222069643D22272B652B275F6C6567656E645F656E7472795F6C6162656C2220666F723D22272B652B275F6C6567656E645F656E747279223E272B286E7C7C65292B273C696D6720';
wwv_flow_imp.g_varchar2_table(21) := '69643D22272B652B275F6C6567656E645F656E7472795F737461747573222F3E3C2F6C6162656C3E3C2F6469763E27292E617070656E64546F286F292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F70';
wwv_flow_imp.g_varchar2_table(22) := '2822636865636B6564222C226E6F6E6522213D3D66292C69287429297D292C353030297D29292929293B6173796E632066756E6374696F6E204428297B69662821452972657475726E3B636F6E737420743D617761697420622C613D7B2E2E2E452E6461';
wwv_flow_imp.g_varchar2_table(23) := '74612C66656174757265733A452E646174612E66656174757265732E6D61702828653D3E287B2E2E2E652C70726F706572746965733A7B2E2E2E652E70726F706572746965732C226D6170626974732D73656C6563746564223A422626766F6964203021';
wwv_flow_imp.g_varchar2_table(24) := '3D3D652E696426266E756C6C213D3D652E69642626422E68617328652E69642E746F537472696E672829297D7D2929297D3B696628742E676574536F75726365285F2929742E676574536F75726365285F292E736574446174612861293B656C73657B6C';
wwv_flow_imp.g_varchar2_table(25) := '657420693D7B2E2E2E452C646174613A617D3B797C7C2267656E6572617465496422696E20697C7C28692E67656E657261746549643D2130292C692E636C7573746572262628693D7B2E2E2E692C636C757374657250726F706572746965733A7B226D61';
wwv_flow_imp.g_varchar2_table(26) := '70626974732D73656C6563746564223A5B22616E79222C5B22676574222C226D6170626974732D73656C6563746564225D5D2C2E2E2E692E636C757374657250726F706572746965737D7D293B7472797B742E616464536F75726365285F2C69297D6361';
wwv_flow_imp.g_varchar2_table(27) := '7463682874297B617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B657D203A204661696C656420746F206164642047656F4A534F4E20736F75726365602C74297D7D7D76617220533D21313B6173';
wwv_flow_imp.g_varchar2_table(28) := '796E632066756E6374696F6E205128297B24282223222B652B225F6C6567656E645F656E7472795F73746174757322292E617474722822737263222C22646174613A696D6167652F6769663B6261736536342C52306C474F446C684541415141504D5041';
wwv_flow_imp.g_varchar2_table(29) := '4C753775356D5A6D544D7A4D3933643352455245514141414864336431565656575A6D5A717171716F6949694F3775376B52455243496949674152414141414143482F4330354656464E44515642464D69347741774541414141682B5151464277415041';
wwv_flow_imp.g_varchar2_table(30) := '4377414141414145414151414541456350444A747967366455724665744454496F704D6F53794663787844316B7244384177436B415344496C50615544514C52364731437930536771496B45314951474D7246414B4363475753427A7750416E41776172';
wwv_flow_imp.g_varchar2_table(31) := '634B5131354D70544D4A5964315A79554458534447656C42593071496F42682F5A6F594767454C436A6F78435252764951634744316B7A67534167414143514478454149666B4542516341447741734141414141413841454141414246337779666B4D6B';
wwv_flow_imp.g_varchar2_table(32) := '6F744F4A707363524B4A4A7774493451314D416F785130524642773078457668474156525A5A4A68344A674D414551573754574934457747466A4B522B43415145436A6E38446F4E306B7744747642543846494C414B4A67666F6F3169414741504E5659';
wwv_flow_imp.g_varchar2_table(33) := '3944474A584E4D49484E2F484A56714978454149666B4542516341447741734141414141424141447741414246727779666D436F6C6769796470615169593578394974683768555264496C30774249687043416A4B494978614155505130684651734143';
wwv_flow_imp.g_varchar2_table(34) := '374D4A414C465346693453674334777948797543594E5778483341756853456F746B4E4741414C415071716B696747384D57416A416E4D34413835393476505579494149666B4542516341447741734141414141424141454141414246337779536B4476';
wwv_flow_imp.g_varchar2_table(35) := '644B736464672B4150594957726367324449525141635536444A49436A49736A424545544C454542594C71595344644A6F43476948675A7747344C51434352454345494241646F463568644549577767424A714473374467634B7952485A6C3375557775';
wwv_flow_imp.g_varchar2_table(36) := '686D3241624E4E572B4C563779642B4678454149666B4542516341434141734141414141424141446741414245595179596D4D6F56676557517250334E59684243675A4264414652556B6442494155677556566F315A7357466345474235474D426B456A';
wwv_flow_imp.g_varchar2_table(37) := '6943424C3261355A41692B6D32534155524578774B71506975436166426B76425343636D6959524143483542415548414134414C414141414141514142414141415273304D6E70414B4459726253574D7030785A4976424B5972586A4E6D41444F68414B';
wwv_flow_imp.g_varchar2_table(38) := '42695144463567476349434E41794A5477465954426144513048416B6777536D41556A304F6B4D726B5A4D344842674B4B3759544B44524943416F32636C41454968654B63394349536A455654754551724A41534763534251635355464555445155584A';
wwv_flow_imp.g_varchar2_table(39) := '4267444257305A6A3334524143483542415548414138414C414141414141514142414141415266384D6E3578714259677256433445456D42634F536641456A536F704A4D676C6D63516C6742596A45354E4A675A776A4341624F345942414A6A70496A53';
wwv_flow_imp.g_varchar2_table(40) := '6941516835617979524149444B764A49626E4961676F465246646B5144514B433052427343495546415773543752774734313052384869694B305742774A6A4642454149666B454251634144674173415141424141384144774141424672517962455741';
wwv_flow_imp.g_varchar2_table(41) := '44584A4C554848414D4A78494441676E724F6F322B414F6962454D68314C4E363267497870687A6974526F434441594E634E4E3646424C5368616F34577A774844514B765647686F46417747677446675148454E686F42376E4377485241494330457955';
wwv_flow_imp.g_varchar2_table(42) := '6343385A77316861334E495267414149666B4542516341447741734141414141424141454141414247447779666E576F6C6A614E595946562B5A783368434547456375797042744D4A42495370436C41574C66574F44796D494669434A774D444D695A42';
wwv_flow_imp.g_varchar2_table(43) := '4E41415946715541614E5132453059424958475552414D436F31414173465942426F495363424A4577675356636D50306C6934467763487A2B46704343514D504346494E78454149666B45425163414467417341414142414241414477414142467A5179';
wwv_flow_imp.g_varchar2_table(44) := '656D5758594E7161535859327656747733554E6D524F4D344A516F774B4B6C464F736752493641535138496853414446416A414D494D416753594A744279787951496863456F614263536977656770446776417753424A30414948426F43517149414569';
wwv_flow_imp.g_varchar2_table(45) := '2F54434941414247684C47384D62634B425167455141682B51514642774150414377414141454145414150414141455866444A53642B71654B355242386644525257467370796F74414166514262664E4C4356555353644B445638396744417763464249';
wwv_flow_imp.g_varchar2_table(46) := '426779774D526E6B574267634A55444B535A52494B4150516347775942794141595445454A41414A494762415445512B423445786D4B3943446842643854686448772F416D5559455141682B515146427741504143774141414541447741504141414558';
wwv_flow_imp.g_varchar2_table(47) := '76424A514961382B494C53737064486B587853397778463451334C3261544265433073466A68417475794C496A414D6859633247426761534B4775794E6F42447037637A4641676542494B7743366B5743414D78555341466A744E434141464747463574';
wwv_flow_imp.g_varchar2_table(48) := '43514C41614A6E57435471486F5245765175514A416B79474245414F773D3D22292C617065782E6576656E742E74726967676572282223222B652C226C6F61645F737461727422293B7472797B636F6E737420613D2266756E6374696F6E223D3D747970';
wwv_flow_imp.g_varchar2_table(49) := '656F6620703F6177616974207028293A703B696628226A617661736372697074223D3D3D6D29453D7B2E2E2E612C747970653A2267656F6A736F6E227D3B656C73657B636F6E737420653D617761697420617065782E7365727665722E706C7567696E28';
wwv_flow_imp.g_varchar2_table(50) := '742C7B706167654974656D733A753F752E73706C697428222C22293A766F696420307D293B453D7B2E2E2E612C747970653A2267656F6A736F6E222C646174613A657D7D6177616974204428297D66696E616C6C797B617065782E6576656E742E747269';
wwv_flow_imp.g_varchar2_table(51) := '67676572282223222B652C226C6F61645F656E6422292C24282223222B652B225F6C6567656E645F656E7472795F73746174757322292E617474722822737263222C2222297D6966282153297B76617220613B73776974636828533D21302C69297B6361';
wwv_flow_imp.g_varchar2_table(52) := '73652273796D626F6C223A613D7B747970653A2273796D626F6C222C6C61796F75743A7B7D7D2C6F262628612E6C61796F75745B22746578742D6669656C64225D3D5B2263617365222C5B22686173222C22706F696E745F636F756E74225D2C5B22636F';
wwv_flow_imp.g_varchar2_table(53) := '6E636174222C5B22676574222C22706F696E745F636F756E74225D2C22206665617475726573225D2C5B22676574222C6F5D5D292C63262628612E6C61796F75745B2269636F6E2D696D616765225D3D63293B627265616B3B63617365226C696E65223A';
wwv_flow_imp.g_varchar2_table(54) := '613D5B7B69643A2273656C656374696F6E222C747970653A226C696E65222C66696C7465723A2121647C7C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C6C61796F75743A7B7D2C7061696E743A7B226C69';
wwv_flow_imp.g_varchar2_table(55) := '6E652D7769647468223A332C226C696E652D636F6C6F72223A643F5B2263617365222C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C2223303566616464222C645D3A2223303566616464227D7D2C7B7479';
wwv_flow_imp.g_varchar2_table(56) := '70653A226C696E65222C6C61796F75743A7B7D2C7061696E743A7B7D7D5D2C6F2626612E70757368287B69643A226C6162656C222C747970653A2273796D626F6C222C6C61796F75743A7B22746578742D6669656C64223A5B22676574222C6F5D2C2273';
wwv_flow_imp.g_varchar2_table(57) := '796D626F6C2D706C6163656D656E74223A226C696E65227D7D293B627265616B3B636173652266696C6C223A613D5B7B747970653A2266696C6C222C6C61796F75743A7B7D2C7061696E743A7B7D7D2C7B69643A2273656C656374696F6E222C74797065';
wwv_flow_imp.g_varchar2_table(58) := '3A226C696E65222C66696C7465723A5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C6C61796F75743A7B7D2C7061696E743A7B226C696E652D7769647468223A332C226C696E652D636F6C6F72223A222330';
wwv_flow_imp.g_varchar2_table(59) := '3566616464227D7D5D3B627265616B3B64656661756C743A613D417D6E756C6C3D3D3D61262628613D7B7D292C2266756E6374696F6E223D3D747970656F662061262628613D612829292C41727261792E697341727261792861297C7C28613D5B615D29';
wwv_flow_imp.g_varchar2_table(60) := '3B636F6E737420743D612E6D6170282828742C61293D3E7B636F6E737420693D7B2E2E2E742C69643A742E69643F652B222D222B742E69643A652B222D222B612C736F757263653A5F2C6C61796F75743A7B2E2E2E742E6C61796F75747D2C7061696E74';
wwv_flow_imp.g_varchar2_table(61) := '3A7B2E2E2E742E7061696E747D2C6D657461646174613A7B6C617965725F73657175656E63653A722C637572736F723A673F22706F696E746572223A766F696420302C2E2E2E742E6D657461646174617D7D3B72657475726E2273796D626F6C223D3D3D';
wwv_flow_imp.g_varchar2_table(62) := '692E747970653F28692E6C61796F75745B22746578742D6669656C64225D262628692E7061696E745B22746578742D636F6C6F72225D3F3F3D6C2C692E7061696E745B22746578742D6F706163697479225D3F3F3D732C692E6C61796F75745B22746578';
wwv_flow_imp.g_varchar2_table(63) := '742D666F6E74225D3F3F3D5B224D6574726F706F6C697320526567756C6172222C224E6F746F2053616E7320526567756C6172225D2C692E6C61796F75745B22746578742D73697A65225D3F3F3D31322C692E7061696E745B22746578742D68616C6F2D';
wwv_flow_imp.g_varchar2_table(64) := '7769647468225D3F3F3D312E352C692E7061696E745B22746578742D68616C6F2D636F6C6F72225D3F3F3D5B2263617365222C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C2223303566616464222C643F';
wwv_flow_imp.g_varchar2_table(65) := '3F2223636363225D2C692E6C61796F75745B22746578742D6A757374696679225D3F3F3D226175746F222C692E6C61796F75745B2269636F6E2D696D616765225D262628692E6C61796F75745B22746578742D6F6666736574225D3F3F3D5B302C2E355D';
wwv_flow_imp.g_varchar2_table(66) := '2C692E6C61796F75745B22746578742D616E63686F72225D7C7C692E6C61796F75745B22746578742D7661726961626C652D616E63686F72225D7C7C28692E6C61796F75745B22746578742D7661726961626C652D616E63686F72225D3D5B22746F7022';
wwv_flow_imp.g_varchar2_table(67) := '2C226C656674222C22746F702D6C656674225D2929292C692E6C61796F75745B2269636F6E2D696D616765225D3F28692E6C61796F75745B2269636F6E2D616C6C6F772D6F7665726C6170225D3F3F3D21302C692E6C61796F75745B22746578742D6F70';
wwv_flow_imp.g_varchar2_table(68) := '74696F6E616C225D3F3F3D21302C692E7061696E745B2269636F6E2D636F6C6F72225D3F3F3D6C2C692E7061696E745B2269636F6E2D6F706163697479225D3F3F3D732C692E7061696E745B2269636F6E2D68616C6F2D7769647468225D3F3F3D5B2263';
wwv_flow_imp.g_varchar2_table(69) := '617365222C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C322C643F313A305D2C692E7061696E745B2269636F6E2D68616C6F2D636F6C6F72225D3F3F3D5B2263617365222C5B223D3D222C5B2267657422';
wwv_flow_imp.g_varchar2_table(70) := '2C226D6170626974732D73656C6563746564225D2C21305D2C2223303566616464222C643F3F227472616E73706172656E74225D293A692E6C61796F75745B22746578742D616C6C6F772D6F7665726C6170225D3F3F3D2130293A226C696E65223D3D3D';
wwv_flow_imp.g_varchar2_table(71) := '692E747970653F28692E7061696E745B226C696E652D636F6C6F72225D3F3F3D6C2C692E7061696E745B226C696E652D6F706163697479225D3F3F3D73293A2266696C6C223D3D3D692E74797065262628692E7061696E745B2266696C6C2D636F6C6F72';
wwv_flow_imp.g_varchar2_table(72) := '225D3F3F3D6C2C692E7061696E745B2266696C6C2D6F706163697479225D3F3F3D732C692E7061696E745B2266696C6C2D6F75746C696E652D636F6C6F72225D3F3F3D647C7C22626C61636B22292C697D29292C703D617761697420622C753D702E6765';
wwv_flow_imp.g_varchar2_table(73) := '745374796C6528292E6C61796572732E66696C7465722828653D3E226D6574616461746122696E20652626226C617965725F73657175656E636522696E20652E6D6574616461746129292E6D6170282866756E6374696F6E2865297B72657475726E5B65';
wwv_flow_imp.g_varchar2_table(74) := '2E6D657461646174612E6C617965725F73657175656E63652C652E69645D7D29293B766172206E3B69662830213D3D752E6C656E677468297B752E736F7274282828652C74293D3E655B305D2D745B305D29293B666F722876617220793D303B793C752E';
wwv_flow_imp.g_varchar2_table(75) := '6C656E6774683B792B2B29696628723C755B795D5B305D297B6E3D755B795D5B315D3B627265616B7D7D666F7228636F6E73742061206F662074297472797B696628702E6164644C6179657228612C6E292C67297B636F6E737420743D653D3E7B666F72';
wwv_flow_imp.g_varchar2_table(76) := '28636F6E73742074206F6620702E717565727952656E6465726564466561747572657328652E706F696E742929696628742E6C617965723F2E6D657461646174613F2E637572736F722972657475726E20766F696428702E67657443616E766173436F6E';
wwv_flow_imp.g_varchar2_table(77) := '7461696E657228292E7374796C652E637572736F723D742E6C617965722E6D657461646174612E637572736F72293B702E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F723D2267726162227D3B702E6F6E28226D6F75';
wwv_flow_imp.g_varchar2_table(78) := '7365656E746572222C612E69642C74292C702E6F6E28226D6F7573656C65617665222C612E69642C74292C702E6F6E2822636C69636B222C612E69642C28743D3E7B617065782E6576656E742E74726967676572282223222B652C22636C69636B222C7B';
wwv_flow_imp.g_varchar2_table(79) := '666561747572653A742E66656174757265735B305D2C6973546F706D6F73744C617965723A702E717565727952656E6465726564466561747572657328742E706F696E74295B305D2E6C617965722E69643D3D3D742E66656174757265735B305D2E6C61';
wwv_flow_imp.g_varchar2_table(80) := '7965722E69642C706F696E743A742E706F696E747D297D29297D7D63617463682874297B617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B657D203A204661696C656420746F20616464206C6179';
wwv_flow_imp.g_varchar2_table(81) := '657220247B612E69647D602C74297D773D742E6D61702828653D3E652E696429292C683D613D3E7B666F7228636F6E73742065206F66207429702E7365744C61796F757450726F706572747928652E69642C227669736962696C697479222C61293B6170';
wwv_flow_imp.g_varchar2_table(82) := '65782E73746F726167652E736574436F6F6B696528224D6170626974735F4C6F6465737461724C617965725F222B652B225F222B2476282270496E7374616E636522292C61292C663D612C617065782E6A5175657279282223222B652B225F6C6567656E';
wwv_flow_imp.g_varchar2_table(83) := '645F656E74727922292E70726F702822636865636B6564222C2276697369626C65223D3D3D61292C617065782E6576656E742E74726967676572282223222B652C227669736962696C6974795F746F67676C6564222C7B76697369626C653A2276697369';
wwv_flow_imp.g_varchar2_table(84) := '626C65223D3D3D617D297D2C226E6F6E65223D3D663F286828226E6F6E6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213129293A2868282276697369626C6522';
wwv_flow_imp.g_varchar2_table(85) := '292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213029292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E6368616E67652828';
wwv_flow_imp.g_varchar2_table(86) := '66756E6374696F6E2865297B76617220743D617065782E6A51756572792874686973293B6828742E697328223A636865636B656422293F2276697369626C65223A226E6F6E6522297D29293B666F7228636F6E73742065206F662049296528293B493D6E';
wwv_flow_imp.g_varchar2_table(87) := '756C6C7D7D5128293B6C657420433D21303B696628617065782E6A51756572792822626F647922292E6F6E2822617065786265666F726572656672657368222C286173796E6320653D3E7B652E7461726765743D3D3D617065782E726567696F6E286129';
wwv_flow_imp.g_varchar2_table(88) := '2E656C656D656E745B305D262628433F433D21313A617761697420512829297D29292C617065782E6974656D2E63726561746528652C7B726566726573683A6173796E6328293D3E7B6177616974205128297D2C73686F773A28293D3E7B682822766973';
wwv_flow_imp.g_varchar2_table(89) := '69626C6522297D2C686964653A28293D3E7B6828226E6F6E6522297D2C697356697369626C653A28293D3E226E6F6E6522213D3D662C6861734944436F6C756D6E3A28293D3E2121792C73657453656C656374656446656174757265733A28652C74293D';
wwv_flow_imp.g_varchar2_table(90) := '3E7B73776974636828653D653F3F5B5D2C74297B6361736522736574223A423D6E6577205365742865293B627265616B3B6361736522616464223A423F3F3D6E6577205365743B666F7228636F6E73742074206F66206529422E6164642874293B627265';
wwv_flow_imp.g_varchar2_table(91) := '616B3B636173652272656D6F7665223A6966284229666F7228636F6E73742074206F66206529422E64656C6574652874297D4428297D2C73656C656374416C6C46656174757265733A28293D3E7B45262628423D6E65772053657428452E646174612E66';
wwv_flow_imp.g_varchar2_table(92) := '656174757265732E6D61702828653D3E652E69642E746F537472696E6728292929292C442829297D2C676574536F75726365446174613A28293D3E453F2E646174612C676574536F757263654E616D653A28293D3E5F2C77616974466F724C6F61643A28';
wwv_flow_imp.g_varchar2_table(93) := '293D3E6E65772050726F6D697365282828652C74293D3E7B6E756C6C3D3D3D493F6528293A492E707573682865297D29292C6765744C617965724944733A28293D3E772C6765744D61703A6173796E6328293D3E617761697420627D292C6520696E204D';
wwv_flow_imp.g_varchar2_table(94) := '4150424954535F4C4F4445535441525F4C415945525F57414954494E47297B636F6E737420743D617065782E6974656D2865293B4D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D2E666F72456163682828653D3E6528';
wwv_flow_imp.g_varchar2_table(95) := '742929297D4D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D3D6E756C6C7D636F6E7374206D6170626974735F6C6F6465737461725F74696E797364663D6E6577206D6170626974735F74696E79736466287B666F6E74';
wwv_flow_imp.g_varchar2_table(96) := '53697A653A31362C666F6E7446616D696C793A22466F6E74204150455820536D616C6C227D293B66756E6374696F6E206D6170626974735F6C6F6465737461725F696D6167655F68616E646C65722865297B72657475726E206E65772050726F6D697365';
wwv_flow_imp.g_varchar2_table(97) := '282828742C61293D3E7B636F6E737420693D652E7461726765743B696628692E686173496D61676528652E696429297428293B656C736520696628652E69642E73746172747357697468282266612D2229297B636F6E737420613D646F63756D656E742E';
wwv_flow_imp.g_varchar2_table(98) := '637265617465456C656D656E7428227370616E22293B612E7374796C652E646973706C61793D226E6F6E65222C612E636C6173734C6973742E6164642822666122292C612E636C6173734C6973742E61646428652E6964292C692E676574436F6E746169';
wwv_flow_imp.g_varchar2_table(99) := '6E657228292E617070656E644368696C642861293B636F6E7374206F3D77696E646F772E676574436F6D70757465645374796C6528612C223A6265666F726522292E636F6E74656E742E737562737472696E6728312C32293B612E72656D6F766528293B';
wwv_flow_imp.g_varchar2_table(100) := '636F6E737420413D6D6170626974735F6C6F6465737461725F74696E797364662E64726177286F292C723D6E65772055696E7438417272617928412E77696474682A412E6865696768742A34293B666F72286C657420653D303B653C412E646174612E6C';
wwv_flow_imp.g_varchar2_table(101) := '656E6774683B652B2B29725B342A652B335D3D412E646174615B655D3B692E616464496D61676528652E69642C7B646174613A722C77696474683A412E77696474682C6865696768743A412E6865696768747D2C7B7364663A21307D292C7428297D656C';
wwv_flow_imp.g_varchar2_table(102) := '736520652E69642E7374617274735769746828617065782E656E762E4150505F46494C4553292626692E6C6F6164496D61676528652E69642C2828612C6F293D3E7B692E686173496D61676528652E6964297C7C692E616464496D61676528652E69642C';
wwv_flow_imp.g_varchar2_table(103) := '6F292C7428297D29297D29297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(588054868348630392)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_file_name=>'mapbits-lodestarlayer.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E737420494D4147455F48414E444C45525F4144444544203D2053796D626F6C28293B0D0A0D0A66756E6374696F6E206D6170626974735F6C6F6465737461726C617965725F6572726F72287B206572726F72207D29207B0D0A2020617065782E6D';
wwv_flow_imp.g_varchar2_table(2) := '6573736167652E73686F774572726F7273285B0D0A202020207B0D0A202020202020747970653A20276572726F72272C0D0A2020202020206C6F636174696F6E3A202770616765272C0D0A2020202020206D6573736167653A206572726F720D0A202020';
wwv_flow_imp.g_varchar2_table(3) := '207D0D0A20205D293B0D0A7D0D0A0D0A636F6E7374204D4150424954535F4C4F4445535441525F4C415945525F57414954494E47203D207B7D3B0D0A0D0A66756E6374696F6E206D6170626974735F6C6F6465737461726C617965725F776169745F666F';
wwv_flow_imp.g_varchar2_table(4) := '725F696E6974286974656D496429207B0D0A202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020206966202821286974656D496420696E204D4150424954535F4C4F4445535441525F';
wwv_flow_imp.g_varchar2_table(5) := '4C415945525F57414954494E472929207B0D0A2020202020204D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B6974656D49645D203D205B5D3B0D0A202020207D0D0A0D0A20202020696620284D4150424954535F4C4F4445';
wwv_flow_imp.g_varchar2_table(6) := '535441525F4C415945525F57414954494E475B6974656D49645D203D3D3D206E756C6C29207B0D0A2020202020207265736F6C766528617065782E6974656D286974656D496429293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20';
wwv_flow_imp.g_varchar2_table(7) := '2020204D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B6974656D49645D2E7075736828286974656D29203D3E207B0D0A2020202020207265736F6C7665286974656D293B0D0A202020207D293B0D0A20207D290D0A7D0D0A';
wwv_flow_imp.g_varchar2_table(8) := '0D0A0D0A66756E6374696F6E206D6170626974735F6C6F6465737461726C61796572287B0D0A20206974656D49642C20616A61784964656E7469666965722C20726567696F6E49642C206C61796572547970652C206C6162656C436F6C756D6E2C206C61';
wwv_flow_imp.g_varchar2_table(9) := '796572446566696E6974696F6E2C2073657175656E63654E756D6265722C207469746C652C20636F6C6F722C206F7061636974792C206F75746C696E65436F6C6F722C2069636F6E2C0D0A2020736F757263654F7074696F6E732C206964436F6C756D6E';
wwv_flow_imp.g_varchar2_table(10) := '2C20636C69636B61626C652C207375626D69744974656D732C20736F75726365547970650D0A7D29207B0D0A20206966202821726567696F6E496429207B0D0A20202020617065782E64656275672E6572726F7228276D6170626974735F6C6F64657374';
wwv_flow_imp.g_varchar2_table(11) := '61726C617965722027202B206974656D4964202B2027203A204974656D206973206E6F7420696E206120726567696F6E2E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A20206C65742077616974466F724C6F6164203D205B5D3B0D0A0D';
wwv_flow_imp.g_varchar2_table(12) := '0A2020636F6E737420736F757263654E616D65203D206974656D4964202B20272D736F75726365273B0D0A0D0A20206C6574206C61796572735669736962696C697479203D20617065782E73746F726167652E676574436F6F6B696528274D6170626974';
wwv_flow_imp.g_varchar2_table(13) := '735F4C6F6465737461724C617965725F27202B206974656D4964202B20275F27202B202476282770496E7374616E63652729293B0D0A0D0A2020766172207265736F6C766564536F757263654F7074696F6E733B0D0A20207661722073656C6563746564';
wwv_flow_imp.g_varchar2_table(14) := '4665617475726573203D206E756C6C3B0D0A0D0A20206C6574207365744C61796572735669736962696C697479203D20287669736962696C69747929203D3E207B0D0A202020206C61796572735669736962696C697479203D207669736962696C697479';
wwv_flow_imp.g_varchar2_table(15) := '3B0D0A20207D3B0D0A0D0A20206C6574206C61796572494473203D206E756C6C3B0D0A0D0A2020636F6E73742070656E64696E674D6170203D206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020636F6E';
wwv_flow_imp.g_varchar2_table(16) := '737420726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0D0A2020202069662028726567696F6E203D3D206E756C6C29207B0D0A202020202020617065782E64656275672E6572726F7228276D6170626974735F6C6F646573';
wwv_flow_imp.g_varchar2_table(17) := '7461726C617965722027202B206974656D4964202B2027203A20526567696F6E205B27202B20726567696F6E4964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A20202020202072656A65637428293B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(18) := '2072657475726E3B0D0A202020207D0D0A0D0A20202020726567696F6E2E656C656D656E742E6F6E28277370617469616C6D6170696E697469616C697A6564272C202829203D3E207B0D0A202020202020636F6E7374206D6170203D20617065782E7265';
wwv_flow_imp.g_varchar2_table(19) := '67696F6E28726567696F6E4964292E63616C6C28276765744D61704F626A65637427293B0D0A2020202020207265736F6C7665286D6170293B0D0A202020207D293B0D0A20207D292E7468656E28286D617029203D3E207B0D0A2020202069662028216D';
wwv_flow_imp.g_varchar2_table(20) := '61705B494D4147455F48414E444C45525F41444445445D20262620216D61702E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F616464656429207B0D0A2020202020206D61702E6F6E28277374796C65696D6167656D69737369';
wwv_flow_imp.g_varchar2_table(21) := '6E67272C2028657629203D3E207B0D0A20202020202020206D6170626974735F6C6F6465737461725F696D6167655F68616E646C6572286576293B0D0A2020202020207D293B0D0A0D0A2020202020202F2A204C697374656E20666F72206572726F7273';
wwv_flow_imp.g_varchar2_table(22) := '20696E20746865206D617020287768696368206D6179206265206173796E6368726F6E6F75732C20736F206E6F742061207468726F776E2F63617567687420657863657074696F6E292E0D0A2020202020202020204F6E6C7920646F2074686973206F6E';
wwv_flow_imp.g_varchar2_table(23) := '636520706572206D61702C206576656E206966206D756C7469706C65204D61706269747320706C7567696E732061726520757365642E202A2F0D0A20202020202069662028216D61702E5F5F6D6170626974735F6572726F725F68616E646C65725F6164';
wwv_flow_imp.g_varchar2_table(24) := '64656429207B0D0A20202020202020206D61702E6F6E28276572726F72272C2028657629203D3E207B0D0A20202020202020202020617065782E64656275672E6572726F7228604D6170206572726F7220696E20726567696F6E20247B726567696F6E49';
wwv_flow_imp.g_varchar2_table(25) := '647D3A20602C2065762E6572726F72293B0D0A20202020202020207D293B0D0A20202020202020206D61702E5F5F6D6170626974735F6572726F725F68616E646C65725F6164646564203D20747275653B0D0A2020202020207D0D0A0D0A202020202020';
wwv_flow_imp.g_varchar2_table(26) := '6D61705B494D4147455F48414E444C45525F41444445445D203D20747275653B0D0A2020202020206D61702E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F6164646564203D20747275653B0D0A202020207D0D0A0D0A202020';
wwv_flow_imp.g_varchar2_table(27) := '202F2F205761697420666F7220746865206C6567656E6420746F206C6F61640D0A2020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A20202020202076617220696E74657276616C203D';
wwv_flow_imp.g_varchar2_table(28) := '20736574496E74657276616C2866756E6374696F6E2829207B0D0A2020202020202020636F6E7374206C6567656E64203D20617065782E6A517565727928272327202B20726567696F6E4964202B20275F6C6567656E6427293B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(29) := '69662028216C6567656E6429207B0D0A2020202020202020202072657475726E3B0D0A20202020202020207D0D0A0D0A2020202020202F2F205468697320636F64652077617320737570706F73656420746F20656E7375726520746865204C6F64657374';
wwv_flow_imp.g_varchar2_table(30) := '6172206C617965727320616C77617973206170706561722061626F766520746865204F7261636C65206F6E65732C0D0A2020202020202F2F206275742069742063617573656420746865204C6F646573746172206C617965727320746F206E6576657220';
wwv_flow_imp.g_varchar2_table(31) := '6C6F616420696620746865204F7261636C65206F6E65732061726520656D7074792E0D0A2020202020202F2F202020636F6E737420726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0D0A2020202020202F2F202020666F72';
wwv_flow_imp.g_varchar2_table(32) := '2028636F6E7374206275696C74696E4C61796572206F6620726567696F6E2E6765744C6179657273282929207B0D0A2020202020202F2F202020202069662028216D61702E6765744C61796572286275696C74696E4C617965722E6964202B2027272929';
wwv_flow_imp.g_varchar2_table(33) := '207B0D0A2020202020202F2F20202020202020636F6E736F6C652E6C6F6728604275696C742D696E206C6179657273206E6F74206C6F61646564207965742C207374696C6C206D697373696E6720247B6275696C74696E4C617965722E69647D2E2E2E60';
wwv_flow_imp.g_varchar2_table(34) := '293B0D0A2020202020202F2F2020202020202072657475726E3B0D0A2020202020202F2F20202020207D0D0A2020202020202F2F2020207D0D0A0D0A2020202020202020636C656172496E74657276616C28696E74657276616C293B0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(35) := '20202020617065782E6A517565727928273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E27202B200D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(36) := '2020273C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069643D2227202B206974656D4964202B20';
wwv_flow_imp.g_varchar2_table(37) := '275F6C6567656E645F656E74727927202B202722207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B20636F6C6F72202B2027223E27202B0D0A20202020202020202020273C6C6162656C20636C617373';
wwv_flow_imp.g_varchar2_table(38) := '3D22612D4D6170526567696F6E2D6C6567656E644C6162656C222069643D2227202B206974656D4964202B20275F6C6567656E645F656E7472795F6C6162656C27202B20272220666F723D2227202B206974656D4964202B20275F6C6567656E645F656E';
wwv_flow_imp.g_varchar2_table(39) := '74727927202B2027223E27202B20287469746C65207C7C206974656D496429202B20273C696D672069643D2227202B206974656D4964202B20275F6C6567656E645F656E7472795F737461747573222F3E3C2F6C6162656C3E27202B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(40) := '20202020273C2F6469763E27292E617070656E64546F286C6567656E64293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C';
wwv_flow_imp.g_varchar2_table(41) := '206C61796572735669736962696C69747920213D3D20276E6F6E6527293B0D0A0D0A20202020202020207265736F6C7665286D6170293B0D0A2020202020207D2C20353030293B0D0A202020207D290D0A20207D293B0D0A0D0A20206173796E63206675';
wwv_flow_imp.g_varchar2_table(42) := '6E6374696F6E2072656C6F6164536F75726365446174612829207B0D0A2020202069662028217265736F6C766564536F757263654F7074696F6E7329207B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20202020636F6E7374206D61';
wwv_flow_imp.g_varchar2_table(43) := '70203D2061776169742070656E64696E674D61703B0D0A0D0A20202020636F6E7374207265616C44617461203D207B0D0A2020202020202E2E2E7265736F6C766564536F757263654F7074696F6E732E646174612C0D0A20202020202066656174757265';
wwv_flow_imp.g_varchar2_table(44) := '733A207265736F6C766564536F757263654F7074696F6E732E646174612E66656174757265732E6D617028286665617475726529203D3E20287B0D0A20202020202020202E2E2E666561747572652C0D0A202020202020202070726F706572746965733A';
wwv_flow_imp.g_varchar2_table(45) := '207B0D0A202020202020202020202E2E2E666561747572652E70726F706572746965732C0D0A20202020202020202020276D6170626974732D73656C6563746564273A2073656C656374656446656174757265732026262028747970656F662066656174';
wwv_flow_imp.g_varchar2_table(46) := '7572652E696420213D3D2027756E646566696E6564272920262620666561747572652E696420213D3D206E756C6C2026262073656C656374656446656174757265732E68617328666561747572652E69642E746F537472696E672829290D0A2020202020';
wwv_flow_imp.g_varchar2_table(47) := '2020207D0D0A2020202020207D29290D0A202020207D3B0D0A0D0A20202020696620286D61702E676574536F7572636528736F757263654E616D652929207B0D0A2020202020206D61702E676574536F7572636528736F757263654E616D65292E736574';
wwv_flow_imp.g_varchar2_table(48) := '44617461287265616C44617461293B0D0A202020207D20656C7365207B0D0A2020202020206C657420736F757263654F707473203D207B0D0A20202020202020202E2E2E7265736F6C766564536F757263654F7074696F6E732C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(49) := '646174613A207265616C446174612C0D0A2020202020207D3B0D0A0D0A20202020202069662028216964436F6C756D6E2026262021282767656E657261746549642720696E20736F757263654F7074732929207B0D0A2020202020202020736F75726365';
wwv_flow_imp.g_varchar2_table(50) := '4F7074732E67656E65726174654964203D20747275653B0D0A2020202020207D0D0A0D0A20202020202069662028736F757263654F7074732E636C757374657229207B0D0A2020202020202020736F757263654F707473203D207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(51) := '2020202E2E2E736F757263654F7074732C0D0A20202020202020202020636C757374657250726F706572746965733A207B0D0A2020202020202020202020205B276D6170626974732D73656C6563746564275D3A205B27616E79272C205B27676574272C';
wwv_flow_imp.g_varchar2_table(52) := '20276D6170626974732D73656C6563746564275D5D2C0D0A2020202020202020202020202E2E2E736F757263654F7074732E636C757374657250726F706572746965732C0D0A202020202020202020207D0D0A20202020202020207D3B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(53) := '207D0D0A0D0A202020202020747279207B0D0A20202020202020206D61702E616464536F7572636528736F757263654E616D652C20736F757263654F707473293B0D0A2020202020207D2063617463682028657863657074696F6E29207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(54) := '20202020617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B6974656D49647D203A204661696C656420746F206164642047656F4A534F4E20736F75726365602C20657863657074696F6E293B0D0A';
wwv_flow_imp.g_varchar2_table(55) := '2020202020207D0D0A202020207D0D0A20207D3B0D0A0D0A2020636F6E7374207370696E6E6572496D616765203D2022646174613A696D6167652F6769663B6261736536342C52306C474F446C684541415141504D50414C753775356D5A6D544D7A4D39';
wwv_flow_imp.g_varchar2_table(56) := '33643352455245514141414864336431565656575A6D5A717171716F6949694F3775376B52455243496949674152414141414143482F4330354656464E44515642464D69347741774541414141682B515146427741504143774141414141454141514145';
wwv_flow_imp.g_varchar2_table(57) := '41456350444A747967366455724665744454496F704D6F53794663787844316B7244384177436B415344496C50615544514C52364731437930536771496B45314951474D7246414B4363475753427A7750416E41776172634B5131354D70544D4A596431';
wwv_flow_imp.g_varchar2_table(58) := '5A79554458534447656C42593071496F42682F5A6F594767454C436A6F78435252764951634744316B7A67534167414143514478454149666B4542516341447741734141414141413841454141414246337779666B4D6B6F744F4A707363524B4A4A7774';
wwv_flow_imp.g_varchar2_table(59) := '493451314D416F785130524642773078457668474156525A5A4A68344A674D414551573754574934457747466A4B522B43415145436A6E38446F4E306B7744747642543846494C414B4A67666F6F3169414741504E56593944474A584E4D49484E2F484A';
wwv_flow_imp.g_varchar2_table(60) := '56714978454149666B4542516341447741734141414141424141447741414246727779666D436F6C6769796470615169593578394974683768555264496C30774249687043416A4B494978614155505130684651734143374D4A414C4653466934536743';
wwv_flow_imp.g_varchar2_table(61) := '34777948797543594E5778483341756853456F746B4E4741414C415071716B696747384D57416A416E4D34413835393476505579494149666B4542516341447741734141414141424141454141414246337779536B4476644B736464672B415059495772';
wwv_flow_imp.g_varchar2_table(62) := '6367324449525141635536444A49436A49736A424545544C454542594C71595344644A6F43476948675A7747344C51434352454345494241646F463568644549577767424A714473374467634B7952485A6C3375557775686D3241624E4E572B4C563779';
wwv_flow_imp.g_varchar2_table(63) := '642B4678454149666B4542516341434141734141414141424141446741414245595179596D4D6F56676557517250334E59684243675A4264414652556B6442494155677556566F315A7357466345474235474D426B456A6943424C3261355A41692B6D32';
wwv_flow_imp.g_varchar2_table(64) := '534155524578774B71506975436166426B76425343636D6959524143483542415548414134414C414141414141514142414141415273304D6E70414B4459726253574D7030785A4976424B5972586A4E6D41444F68414B42695144463567476349434E41';
wwv_flow_imp.g_varchar2_table(65) := '794A5477465954426144513048416B6777536D41556A304F6B4D726B5A4D344842674B4B3759544B44524943416F32636C41454968654B63394349536A455654754551724A41534763534251635355464555445155584A4267444257305A6A3334524143';
wwv_flow_imp.g_varchar2_table(66) := '483542415548414138414C414141414141514142414141415266384D6E3578714259677256433445456D42634F536641456A536F704A4D676C6D63516C6742596A45354E4A675A776A4341624F345942414A6A70496A536941516835617979524149444B';
wwv_flow_imp.g_varchar2_table(67) := '764A49626E4961676F465246646B5144514B433052427343495546415773543752774734313052384869694B305742774A6A4642454149666B45425163414467417341514142414138414477414142467251796245574144584A4C554848414D4A784944';
wwv_flow_imp.g_varchar2_table(68) := '41676E724F6F322B414F6962454D68314C4E363267497870687A6974526F434441594E634E4E3646424C5368616F34577A774844514B765647686F46417747677446675148454E686F42376E43774852414943304579556343385A77316861334E495267';
wwv_flow_imp.g_varchar2_table(69) := '414149666B4542516341447741734141414141424141454141414247447779666E576F6C6A614E595946562B5A783368434547456375797042744D4A42495370436C41574C66574F44796D494669434A774D444D695A424E41415946715541614E513245';
wwv_flow_imp.g_varchar2_table(70) := '3059424958475552414D436F31414173465942426F495363424A4577675356636D50306C6934467763487A2B46704343514D504346494E78454149666B45425163414467417341414142414241414477414142467A5179656D5758594E71615358593276';
wwv_flow_imp.g_varchar2_table(71) := '56747733554E6D524F4D344A516F774B4B6C464F736752493641535138496853414446416A414D494D416753594A744279787951496863456F614263536977656770446776417753424A30414948426F435171494145692F54434941414247684C47384D';
wwv_flow_imp.g_varchar2_table(72) := '62634B425167455141682B51514642774150414377414141454145414150414141455866444A53642B71654B355242386644525257467370796F74414166514262664E4C4356555353644B445638396744417763464249426779774D526E6B574267634A';
wwv_flow_imp.g_varchar2_table(73) := '55444B535A52494B4150516347775942794141595445454A41414A494762415445512B423445786D4B3943446842643854686448772F416D5559455141682B51514642774150414377414141454144774150414141455876424A514961382B494C537370';
wwv_flow_imp.g_varchar2_table(74) := '64486B587853397778463451334C3261544265433073466A68417475794C496A414D6859633247426761534B4775794E6F42447037637A4641676542494B7743366B5743414D78555341466A744E43414146474746357443514C41614A6E57435471486F';
wwv_flow_imp.g_varchar2_table(75) := '5245765175514A416B79474245414F773D3D223B0D0A0D0A20207661722061646465644C61796572203D2066616C73653B0D0A0D0A20206173796E632066756E6374696F6E206C6F6164446174612829207B0D0A202020202428272327202B206974656D';
wwv_flow_imp.g_varchar2_table(76) := '4964202B20275F6C6567656E645F656E7472795F73746174757327292E617474722827737263272C207370696E6E6572496D616765293B0D0A20202020617065782E6576656E742E7472696767657228272327202B206974656D49642C20276C6F61645F';
wwv_flow_imp.g_varchar2_table(77) := '737461727427293B0D0A20202020747279207B0D0A202020202020636F6E7374207265616C536F757263654F7074696F6E73203D20747970656F6620736F757263654F7074696F6E73203D3D3D202766756E6374696F6E27203F20617761697420736F75';
wwv_flow_imp.g_varchar2_table(78) := '7263654F7074696F6E732829203A20736F757263654F7074696F6E733B0D0A20202020202069662028736F7572636554797065203D3D3D20226A6176617363726970742229207B0D0A20202020202020207265736F6C766564536F757263654F7074696F';
wwv_flow_imp.g_varchar2_table(79) := '6E73203D207B0D0A202020202020202020202E2E2E7265616C536F757263654F7074696F6E732C0D0A20202020202020202020747970653A202767656F6A736F6E272C0D0A20202020202020207D3B0D0A2020202020207D20656C7365207B0D0A202020';
wwv_flow_imp.g_varchar2_table(80) := '2020202020636F6E737420726573706F6E7365203D20617761697420617065782E7365727665722E706C7567696E28616A61784964656E7469666965722C207B706167654974656D733A207375626D69744974656D73203F207375626D69744974656D73';
wwv_flow_imp.g_varchar2_table(81) := '2E73706C697428222C2229203A20756E646566696E65647D293B0D0A20202020202020207265736F6C766564536F757263654F7074696F6E73203D207B0D0A202020202020202020202E2E2E7265616C536F757263654F7074696F6E732C0D0A20202020';
wwv_flow_imp.g_varchar2_table(82) := '202020202020747970653A202767656F6A736F6E272C0D0A20202020202020202020646174613A20726573706F6E73652C0D0A20202020202020207D3B0D0A2020202020207D0D0A20202020202061776169742072656C6F6164536F7572636544617461';
wwv_flow_imp.g_varchar2_table(83) := '28293B0D0A202020207D2066696E616C6C79207B0D0A202020202020617065782E6576656E742E7472696767657228272327202B206974656D49642C20276C6F61645F656E6427293B0D0A2020202020202428272327202B206974656D4964202B20275F';
wwv_flow_imp.g_varchar2_table(84) := '6C6567656E645F656E7472795F73746174757327292E617474722827737263272C202727293B0D0A202020207D0D0A0D0A20202020696620282161646465644C6179657229207B0D0A20202020202061646465644C61796572203D20747275653B0D0A0D';
wwv_flow_imp.g_varchar2_table(85) := '0A202020202020766172206F726967696E616C4C61796572733B0D0A0D0A20202020202073776974636820286C617965725479706529207B0D0A202020202020202063617365202773796D626F6C273A0D0A202020202020202020206F726967696E616C';
wwv_flow_imp.g_varchar2_table(86) := '4C6179657273203D207B0D0A202020202020202020202020747970653A202773796D626F6C272C0D0A2020202020202020202020206C61796F75743A207B7D0D0A202020202020202020207D3B0D0A20202020202020202020696620286C6162656C436F';
wwv_flow_imp.g_varchar2_table(87) := '6C756D6E2920207B0D0A2020202020202020202020206F726967696E616C4C61796572732E6C61796F75745B27746578742D6669656C64275D203D205B0D0A20202020202020202020202020202763617365272C0D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(88) := '5B27686173272C2027706F696E745F636F756E74275D2C0D0A20202020202020202020202020205B27636F6E636174272C205B27676574272C2027706F696E745F636F756E74275D2C2027206665617475726573275D2C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(89) := '2020205B27676574272C206C6162656C436F6C756D6E5D0D0A2020202020202020202020205D3B0D0A202020202020202020207D0D0A202020202020202020206966202869636F6E29207B0D0A2020202020202020202020206F726967696E616C4C6179';
wwv_flow_imp.g_varchar2_table(90) := '6572732E6C61796F75745B2769636F6E2D696D616765275D203D2069636F6E3B0D0A202020202020202020207D0D0A20202020202020202020627265616B3B0D0A0D0A20202020202020206361736520276C696E65273A0D0A202020202020202020206F';
wwv_flow_imp.g_varchar2_table(91) := '726967696E616C4C6179657273203D205B0D0A2020202020202020202020207B0D0A202020202020202020202020202069643A202773656C656374696F6E272C0D0A2020202020202020202020202020747970653A20276C696E65272C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(92) := '20202020202020202066696C7465723A206F75746C696E65436F6C6F72203F2074727565203A205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A20202020202020202020202020206C6179';
wwv_flow_imp.g_varchar2_table(93) := '6F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B0D0A20202020202020202020202020202020276C696E652D7769647468273A20332C0D0A20202020202020202020202020202020276C696E652D636F6C6F72273A206F75';
wwv_flow_imp.g_varchar2_table(94) := '746C696E65436F6C6F72203F205B2763617365272C205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C202723303566616464272C206F75746C696E65436F6C6F725D203A202723303566616464';
wwv_flow_imp.g_varchar2_table(95) := '272C0D0A20202020202020202020202020207D2C0D0A2020202020202020202020207D2C0D0A2020202020202020202020207B0D0A2020202020202020202020202020747970653A20276C696E65272C0D0A20202020202020202020202020206C61796F';
wwv_flow_imp.g_varchar2_table(96) := '75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B7D2C0D0A2020202020202020202020207D2C0D0A202020202020202020205D3B0D0A0D0A20202020202020202020696620286C6162656C436F6C756D6E29207B0D0A202020';
wwv_flow_imp.g_varchar2_table(97) := '2020202020202020206F726967696E616C4C61796572732E70757368287B0D0A202020202020202020202020202069643A20276C6162656C272C0D0A2020202020202020202020202020747970653A202773796D626F6C272C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(98) := '20202020206C61796F75743A207B0D0A2020202020202020202020202020202027746578742D6669656C64273A205B27676574272C206C6162656C436F6C756D6E5D2C0D0A202020202020202020202020202020202773796D626F6C2D706C6163656D65';
wwv_flow_imp.g_varchar2_table(99) := '6E74273A20276C696E65272C0D0A20202020202020202020202020207D2C0D0A2020202020202020202020207D293B0D0A202020202020202020207D0D0A0D0A20202020202020202020627265616B3B0D0A0D0A20202020202020206361736520276669';
wwv_flow_imp.g_varchar2_table(100) := '6C6C273A0D0A202020202020202020206F726967696E616C4C6179657273203D205B0D0A2020202020202020202020207B0D0A2020202020202020202020202020747970653A202766696C6C272C0D0A20202020202020202020202020206C61796F7574';
wwv_flow_imp.g_varchar2_table(101) := '3A207B7D2C0D0A20202020202020202020202020207061696E743A207B7D2C0D0A2020202020202020202020207D2C0D0A2020202020202020202020207B0D0A202020202020202020202020202069643A202773656C656374696F6E272C0D0A20202020';
wwv_flow_imp.g_varchar2_table(102) := '20202020202020202020747970653A20276C696E65272C0D0A202020202020202020202020202066696C7465723A205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(103) := '20202020206C61796F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B0D0A20202020202020202020202020202020276C696E652D7769647468273A20332C0D0A20202020202020202020202020202020276C696E652D636F';
wwv_flow_imp.g_varchar2_table(104) := '6C6F72273A202723303566616464272C0D0A20202020202020202020202020207D2C0D0A2020202020202020202020207D2C0D0A202020202020202020205D3B0D0A20202020202020202020627265616B3B0D0A0D0A202020202020202064656661756C';
wwv_flow_imp.g_varchar2_table(105) := '743A0D0A202020202020202020206F726967696E616C4C6179657273203D206C61796572446566696E6974696F6E3B0D0A2020202020207D0D0A0D0A202020202020696620286F726967696E616C4C6179657273203D3D3D206E756C6C29207B0D0A2020';
wwv_flow_imp.g_varchar2_table(106) := '2020202020206F726967696E616C4C6179657273203D207B7D3B0D0A2020202020207D0D0A20202020202069662028747970656F66206F726967696E616C4C6179657273203D3D3D202766756E6374696F6E2729207B0D0A20202020202020206F726967';
wwv_flow_imp.g_varchar2_table(107) := '696E616C4C6179657273203D206F726967696E616C4C617965727328293B0D0A2020202020207D0D0A202020202020696620282141727261792E69734172726179286F726967696E616C4C61796572732929207B0D0A20202020202020206F726967696E';
wwv_flow_imp.g_varchar2_table(108) := '616C4C6179657273203D205B6F726967696E616C4C61796572735D3B0D0A2020202020207D0D0A0D0A202020202020636F6E7374206C6179657273203D206F726967696E616C4C61796572732E6D617028286F726967696E616C4C617965722C20692920';
wwv_flow_imp.g_varchar2_table(109) := '3D3E207B0D0A2020202020202020636F6E7374206C61796572203D207B0D0A202020202020202020202E2E2E6F726967696E616C4C617965722C0D0A2020202020202020202069643A206F726967696E616C4C617965722E6964203F206974656D496420';
wwv_flow_imp.g_varchar2_table(110) := '2B20272D27202B206F726967696E616C4C617965722E6964203A206974656D4964202B20272D27202B20692C0D0A20202020202020202020736F757263653A20736F757263654E616D652C0D0A202020202020202020206C61796F75743A207B0D0A2020';
wwv_flow_imp.g_varchar2_table(111) := '202020202020202020202E2E2E6F726967696E616C4C617965722E6C61796F75742C0D0A202020202020202020207D2C0D0A202020202020202020207061696E743A207B0D0A2020202020202020202020202E2E2E6F726967696E616C4C617965722E70';
wwv_flow_imp.g_varchar2_table(112) := '61696E742C0D0A202020202020202020207D2C0D0A202020202020202020206D657461646174613A207B0D0A2020202020202020202020206C617965725F73657175656E63653A2073657175656E63654E756D6265722C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(113) := '20637572736F723A20636C69636B61626C65203F2027706F696E74657227203A20756E646566696E65642C0D0A2020202020202020202020202E2E2E6F726967696E616C4C617965722E6D657461646174612C0D0A202020202020202020207D0D0A2020';
wwv_flow_imp.g_varchar2_table(114) := '2020202020207D3B0D0A0D0A2020202020202020696620286C617965722E74797065203D3D3D202773796D626F6C2729207B0D0A20202020202020202020696620286C617965722E6C61796F75745B27746578742D6669656C64275D29207B0D0A202020';
wwv_flow_imp.g_varchar2_table(115) := '2020202020202020206C617965722E7061696E745B27746578742D636F6C6F72275D203F3F3D20636F6C6F723B0D0A2020202020202020202020206C617965722E7061696E745B27746578742D6F706163697479275D203F3F3D206F7061636974793B0D';
wwv_flow_imp.g_varchar2_table(116) := '0A2020202020202020202020206C617965722E6C61796F75745B27746578742D666F6E74275D203F3F3D205B274D6574726F706F6C697320526567756C6172272C20274E6F746F2053616E7320526567756C6172275D3B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(117) := '206C617965722E6C61796F75745B27746578742D73697A65275D203F3F3D2031323B0D0A2020202020202020202020206C617965722E7061696E745B27746578742D68616C6F2D7769647468275D203F3F3D20312E353B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(118) := '206C617965722E7061696E745B27746578742D68616C6F2D636F6C6F72275D203F3F3D205B0D0A20202020202020202020202020202763617365272C0D0A20202020202020202020202020205B273D3D272C205B27676574272C20276D6170626974732D';
wwv_flow_imp.g_varchar2_table(119) := '73656C6563746564275D2C20747275655D2C0D0A20202020202020202020202020202723303566616464272C0D0A20202020202020202020202020206F75746C696E65436F6C6F72203F3F202723636363270D0A2020202020202020202020205D3B0D0A';
wwv_flow_imp.g_varchar2_table(120) := '2020202020202020202020206C617965722E6C61796F75745B27746578742D6A757374696679275D203F3F3D20276175746F273B0D0A0D0A202020202020202020202020696620286C617965722E6C61796F75745B2769636F6E2D696D616765275D2920';
wwv_flow_imp.g_varchar2_table(121) := '7B0D0A20202020202020202020202020206C617965722E6C61796F75745B27746578742D6F6666736574275D203F3F3D205B302C20302E355D3B0D0A202020202020202020202020202069662028216C617965722E6C61796F75745B27746578742D616E';
wwv_flow_imp.g_varchar2_table(122) := '63686F72275D20262620216C617965722E6C61796F75745B27746578742D7661726961626C652D616E63686F72275D29207B0D0A202020202020202020202020202020206C617965722E6C61796F75745B27746578742D7661726961626C652D616E6368';
wwv_flow_imp.g_varchar2_table(123) := '6F72275D203D205B27746F70272C20276C656674272C2027746F702D6C656674275D3B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D0D0A202020202020202020207D0D0A0D0A20202020202020202020696620286C61';
wwv_flow_imp.g_varchar2_table(124) := '7965722E6C61796F75745B2769636F6E2D696D616765275D29207B0D0A2020202020202020202020206C617965722E6C61796F75745B2769636F6E2D616C6C6F772D6F7665726C6170275D203F3F3D20747275653B0D0A2020202020202020202020206C';
wwv_flow_imp.g_varchar2_table(125) := '617965722E6C61796F75745B27746578742D6F7074696F6E616C275D203F3F3D20747275653B0D0A2020202020202020202020206C617965722E7061696E745B2769636F6E2D636F6C6F72275D203F3F3D20636F6C6F723B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(126) := '20206C617965722E7061696E745B2769636F6E2D6F706163697479275D203F3F3D206F7061636974793B0D0A2020202020202020202020206C617965722E7061696E745B2769636F6E2D68616C6F2D7769647468275D203F3F3D205B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(127) := '20202020202020202763617365272C0D0A20202020202020202020202020205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A2020202020202020202020202020322C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(128) := '202020202020206F75746C696E65436F6C6F72203F2031203A20300D0A2020202020202020202020205D3B0D0A2020202020202020202020206C617965722E7061696E745B2769636F6E2D68616C6F2D636F6C6F72275D203F3F3D205B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(129) := '2020202020202020202763617365272C0D0A20202020202020202020202020205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A20202020202020202020202020202723303566616464272C';
wwv_flow_imp.g_varchar2_table(130) := '0D0A20202020202020202020202020206F75746C696E65436F6C6F72203F3F20277472616E73706172656E74270D0A2020202020202020202020205D3B0D0A202020202020202020207D20656C7365207B0D0A2020202020202020202020206C61796572';
wwv_flow_imp.g_varchar2_table(131) := '2E6C61796F75745B27746578742D616C6C6F772D6F7665726C6170275D203F3F3D20747275653B0D0A202020202020202020207D0D0A20202020202020207D20656C736520696620286C617965722E74797065203D3D3D20276C696E652729207B0D0A20';
wwv_flow_imp.g_varchar2_table(132) := '2020202020202020206C617965722E7061696E745B276C696E652D636F6C6F72275D203F3F3D20636F6C6F723B0D0A202020202020202020206C617965722E7061696E745B276C696E652D6F706163697479275D203F3F3D206F7061636974793B0D0A20';
wwv_flow_imp.g_varchar2_table(133) := '202020202020207D20656C736520696620286C617965722E74797065203D3D3D202766696C6C2729207B0D0A202020202020202020206C617965722E7061696E745B2766696C6C2D636F6C6F72275D203F3F3D20636F6C6F723B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(134) := '20206C617965722E7061696E745B2766696C6C2D6F706163697479275D203F3F3D206F7061636974793B0D0A202020202020202020206C617965722E7061696E745B2766696C6C2D6F75746C696E652D636F6C6F72275D203F3F3D206F75746C696E6543';
wwv_flow_imp.g_varchar2_table(135) := '6F6C6F72207C7C2027626C61636B273B0D0A20202020202020207D0D0A0D0A202020202020202072657475726E206C617965723B0D0A2020202020207D293B0D0A0D0A202020202020636F6E7374206D6170203D2061776169742070656E64696E674D61';
wwv_flow_imp.g_varchar2_table(136) := '703B0D0A0D0A202020202020636F6E7374206D6170626974736C6179657273203D206D61702E6765745374796C6528292E6C61796572732E66696C746572282876616C29203D3E207B0D0A202020202020202069662028276D657461646174612720696E';
wwv_flow_imp.g_varchar2_table(137) := '2076616C29207B200D0A2020202020202020202072657475726E20276C617965725F73657175656E63652720696E2076616C2E6D657461646174613B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202072657475726E2066616C';
wwv_flow_imp.g_varchar2_table(138) := '73653B0D0A20202020202020207D0D0A2020202020207D292E6D61702866756E6374696F6E2876616C29207B72657475726E205B76616C2E6D657461646174612E6C617965725F73657175656E63652C2076616C2E69645D7D293B0D0A20202020202076';
wwv_flow_imp.g_varchar2_table(139) := '6172206265666F72654C617965723B0D0A202020202020696620286D6170626974736C61796572732E6C656E67746820213D3D203029207B0D0A20202020202020206D6170626974736C61796572732E736F72742828612C206229203D3E20615B305D20';
wwv_flow_imp.g_varchar2_table(140) := '2D20625B305D293B0D0A2020202020202020666F722876617220693D303B693C6D6170626974736C61796572732E6C656E6774683B692B2B29207B0D0A202020202020202020206966202873657175656E63654E756D626572203C206D6170626974736C';
wwv_flow_imp.g_varchar2_table(141) := '61796572735B695D5B305D29207B0D0A2020202020202020202020206265666F72654C61796572203D206D6170626974736C61796572735B695D5B315D3B0D0A202020202020202020202020627265616B3B0D0A202020202020202020207D0D0A202020';
wwv_flow_imp.g_varchar2_table(142) := '20202020207D0D0A2020202020207D0D0A202020202020666F722028636F6E7374206C206F66206C617965727329207B0D0A2020202020202020747279207B0D0A202020202020202020206D61702E6164644C61796572286C2C206265666F72654C6179';
wwv_flow_imp.g_varchar2_table(143) := '6572293B0D0A0D0A2020202020202020202069662028636C69636B61626C6529207B0D0A202020202020202020202020636F6E737420736574506F696E746572203D2028657629203D3E207B0D0A2020202020202020202020202020666F722028636F6E';
wwv_flow_imp.g_varchar2_table(144) := '73742066656174206F66206D61702E717565727952656E646572656446656174757265732865762E706F696E742929207B0D0A2020202020202020202020202020202069662028666561742E6C617965723F2E6D657461646174613F2E637572736F7229';
wwv_flow_imp.g_varchar2_table(145) := '207B0D0A2020202020202020202020202020202020206D61702E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F72203D20666561742E6C617965722E6D657461646174612E637572736F723B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(146) := '20202020202020202072657475726E3B0D0A202020202020202020202020202020207D0D0A20202020202020202020202020207D0D0A20202020202020202020202020206D61702E67657443616E766173436F6E7461696E657228292E7374796C652E63';
wwv_flow_imp.g_varchar2_table(147) := '7572736F72203D202767726162273B0D0A2020202020202020202020207D3B0D0A2020202020202020202020206D61702E6F6E28276D6F757365656E746572272C206C2E69642C20736574506F696E746572293B0D0A2020202020202020202020206D61';
wwv_flow_imp.g_varchar2_table(148) := '702E6F6E28276D6F7573656C65617665272C206C2E69642C20736574506F696E746572293B0D0A2020202020202020202020206D61702E6F6E2827636C69636B272C206C2E69642C2028657629203D3E207B0D0A20202020202020202020202020206170';
wwv_flow_imp.g_varchar2_table(149) := '65782E6576656E742E7472696767657228272327202B206974656D49642C2027636C69636B272C207B0D0A20202020202020202020202020202020666561747572653A2065762E66656174757265735B305D2C0D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(150) := '206973546F706D6F73744C617965723A206D61702E717565727952656E646572656446656174757265732865762E706F696E74295B305D2E6C617965722E6964203D3D3D2065762E66656174757265735B305D2E6C617965722E69642C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(151) := '2020202020202020202020706F696E743A2065762E706F696E742C0D0A20202020202020202020202020207D293B0D0A2020202020202020202020207D293B0D0A202020202020202020207D0D0A20202020202020207D20636174636820286578636570';
wwv_flow_imp.g_varchar2_table(152) := '74696F6E29207B0D0A20202020202020202020617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B6974656D49647D203A204661696C656420746F20616464206C6179657220247B6C2E69647D602C';
wwv_flow_imp.g_varchar2_table(153) := '20657863657074696F6E293B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A2020202020206C61796572494473203D206C61796572732E6D6170286C203D3E206C2E6964293B0D0A0D0A2020202020207365744C6179657273566973696269';
wwv_flow_imp.g_varchar2_table(154) := '6C697479203D20287669736962696C69747929203D3E207B0D0A2020202020202020666F722028636F6E7374206C61796572206F66206C617965727329207B0D0A202020202020202020206D61702E7365744C61796F757450726F7065727479286C6179';
wwv_flow_imp.g_varchar2_table(155) := '65722E69642C20277669736962696C697479272C207669736962696C697479293B0D0A20202020202020207D0D0A2020202020202020617065782E73746F726167652E736574436F6F6B696528274D6170626974735F4C6F6465737461724C617965725F';
wwv_flow_imp.g_varchar2_table(156) := '27202B206974656D4964202B20275F27202B202476282770496E7374616E636527292C207669736962696C697479293B0D0A20202020202020206C61796572735669736962696C697479203D207669736962696C6974793B0D0A0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(157) := '617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C207669736962696C697479203D3D3D202776697369626C6527293B0D0A0D0A20202020202020206170';
wwv_flow_imp.g_varchar2_table(158) := '65782E6576656E742E7472696767657228272327202B206974656D49642C20277669736962696C6974795F746F67676C6564272C207B0D0A2020202020202020202076697369626C653A207669736962696C697479203D3D3D202776697369626C65272C';
wwv_flow_imp.g_varchar2_table(159) := '0D0A20202020202020207D293B0D0A2020202020207D0D0A0D0A202020202020696620286C61796572735669736962696C697479203D3D20276E6F6E652729207B0D0A20202020202020207365744C61796572735669736962696C69747928276E6F6E65';
wwv_flow_imp.g_varchar2_table(160) := '27293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A2020202020207D20656C7365207B0D0A2020';
wwv_flow_imp.g_varchar2_table(161) := '2020202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865';
wwv_flow_imp.g_varchar2_table(162) := '636B6564272C2074727565293B0D0A2020202020207D0D0A0D0A202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E6368616E67652866756E6374696F6E2865297B0D0A202020';
wwv_flow_imp.g_varchar2_table(163) := '2020202020766172206362203D20617065782E6A51756572792874686973293B0D0A20202020202020207365744C61796572735669736962696C6974792863622E697328273A636865636B65642729203F202776697369626C6527203A20276E6F6E6527';
wwv_flow_imp.g_varchar2_table(164) := '293B0D0A2020202020207D293B0D0A0D0A202020202020666F722028636F6E73742066756E63206F662077616974466F724C6F616429207B0D0A202020202020202066756E6328293B0D0A2020202020207D0D0A20202020202077616974466F724C6F61';
wwv_flow_imp.g_varchar2_table(165) := '64203D206E756C6C3B0D0A202020207D0D0A20207D3B0D0A0D0A20206C6F61644461746128293B0D0A0D0A20206C657420666972737452656672657368203D20747275653B0D0A2020617065782E6A51756572792827626F647927292E6F6E2827617065';
wwv_flow_imp.g_varchar2_table(166) := '786265666F726572656672657368272C206173796E632028657629203D3E207B0D0A202020206966202865762E746172676574203D3D3D20617065782E726567696F6E28726567696F6E4964292E656C656D656E745B305D29207B0D0A2020202020202F';
wwv_flow_imp.g_varchar2_table(167) := '2A20536B69702074686520666972737420617065786265666F726572656672657368206576656E742C2073696E6365207468617420636F72726573706F6E647320746F207468652070616765206C6F6164696E672C0D0A20202020202020202062757420';
wwv_flow_imp.g_varchar2_table(168) := '776520616C72656164792063616C6C6564206C6F61644461746128292061626F766520776974686F75742077616974696E6720666F7220746865206D617020746F206C6F61642E202A2F0D0A202020202020696620282166697273745265667265736829';
wwv_flow_imp.g_varchar2_table(169) := '207B0D0A20202020202020206177616974206C6F61644461746128293B0D0A2020202020207D20656C7365207B0D0A2020202020202020666972737452656672657368203D2066616C73653B0D0A2020202020207D0D0A202020207D0D0A20207D293B0D';
wwv_flow_imp.g_varchar2_table(170) := '0A0D0A2020617065782E6974656D2E637265617465280D0A202020206974656D49642C0D0A202020207B0D0A202020202020726566726573683A206173796E63202829203D3E207B0D0A20202020202020206177616974206C6F61644461746128293B0D';
wwv_flow_imp.g_varchar2_table(171) := '0A2020202020207D2C0D0A20202020202073686F773A202829203D3E207B0D0A20202020202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020207D2C0D0A202020202020686964653A202829203D3E';
wwv_flow_imp.g_varchar2_table(172) := '207B0D0A20202020202020207365744C61796572735669736962696C69747928276E6F6E6527293B0D0A2020202020207D2C0D0A202020202020697356697369626C653A202829203D3E207B0D0A202020202020202072657475726E206C617965727356';
wwv_flow_imp.g_varchar2_table(173) := '69736962696C69747920213D3D20276E6F6E65273B0D0A2020202020207D2C0D0A2020202020206861734944436F6C756D6E3A202829203D3E207B0D0A202020202020202072657475726E2021216964436F6C756D6E3B0D0A2020202020207D2C0D0A20';
wwv_flow_imp.g_varchar2_table(174) := '20202020202F2A2053657420746865206C697374206F66206665617475726573207468617420686176652061202273656C65637465642220617070656172616E63652E20606665617475726573602069732061206C6973740D0A2020202020202020206F';
wwv_flow_imp.g_varchar2_table(175) := '662066656174757265204944732E202A2F0D0A20202020202073657453656C656374656446656174757265733A202866656174757265732C20616374696F6E29203D3E207B0D0A20202020202020206665617475726573203D206665617475726573203F';
wwv_flow_imp.g_varchar2_table(176) := '3F205B5D3B0D0A20202020202020207377697463682028616374696F6E29207B0D0A20202020202020202020636173652027736574273A0D0A20202020202020202020202073656C65637465644665617475726573203D206E6577205365742866656174';
wwv_flow_imp.g_varchar2_table(177) := '75726573293B0D0A202020202020202020202020627265616B3B0D0A20202020202020202020636173652027616464273A0D0A20202020202020202020202073656C65637465644665617475726573203F3F3D206E65772053657428293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(178) := '2020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A202020202020202020202020202073656C656374656446656174757265732E6164642866293B0D0A2020202020202020202020207D0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(179) := '20202020627265616B3B0D0A2020202020202020202063617365202772656D6F7665273A0D0A2020202020202020202020206966202873656C6563746564466561747572657329207B0D0A2020202020202020202020202020666F722028636F6E737420';
wwv_flow_imp.g_varchar2_table(180) := '66206F6620666561747572657329207B0D0A2020202020202020202020202020202073656C656374656446656174757265732E64656C6574652866293B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D0D0A2020202020';
wwv_flow_imp.g_varchar2_table(181) := '20202020202020627265616B3B0D0A20202020202020207D0D0A202020202020202072656C6F6164536F757263654461746128293B0D0A2020202020207D2C0D0A2020202020202F2A2053656C6563747320616C6C206665617475726573206375727265';
wwv_flow_imp.g_varchar2_table(182) := '6E746C7920696E20746865206C617965722074686174206861766520616E2049442E202A2F0D0A20202020202073656C656374416C6C46656174757265733A202829203D3E207B0D0A2020202020202020696620287265736F6C766564536F757263654F';
wwv_flow_imp.g_varchar2_table(183) := '7074696F6E7329207B0D0A2020202020202020202073656C65637465644665617475726573203D206E657720536574287265736F6C766564536F757263654F7074696F6E732E646174612E66656174757265732E6D61702866203D3E20662E69642E746F';
wwv_flow_imp.g_varchar2_table(184) := '537472696E67282929293B0D0A2020202020202020202072656C6F6164536F757263654461746128293B0D0A20202020202020207D0D0A2020202020207D2C0D0A202020202020676574536F75726365446174613A202829203D3E207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(185) := '20202072657475726E207265736F6C766564536F757263654F7074696F6E733F2E646174613B0D0A2020202020207D2C0D0A202020202020676574536F757263654E616D653A202829203D3E20736F757263654E616D652C0D0A20202020202077616974';
wwv_flow_imp.g_varchar2_table(186) := '466F724C6F61643A202829203D3E207B0D0A202020202020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020202020202020206966202877616974466F724C6F6164203D3D3D206E';
wwv_flow_imp.g_varchar2_table(187) := '756C6C29207B0D0A2020202020202020202020207265736F6C766528293B0D0A202020202020202020207D20656C7365207B0D0A20202020202020202020202077616974466F724C6F61642E70757368287265736F6C7665293B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(188) := '20207D0D0A20202020202020207D293B0D0A2020202020207D2C0D0A2020202020206765744C617965724944733A202829203D3E207B0D0A202020202020202072657475726E206C617965724944733B0D0A2020202020207D2C0D0A2020202020206765';
wwv_flow_imp.g_varchar2_table(189) := '744D61703A206173796E63202829203D3E2061776169742070656E64696E674D61702C0D0A202020207D0D0A2020293B0D0A0D0A2020696620286974656D496420696E204D4150424954535F4C4F4445535441525F4C415945525F57414954494E472920';
wwv_flow_imp.g_varchar2_table(190) := '7B0D0A20202020636F6E7374206974656D203D20617065782E6974656D286974656D4964293B0D0A202020204D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B6974656D49645D2E666F724561636828287829203D3E207828';
wwv_flow_imp.g_varchar2_table(191) := '6974656D29293B0D0A20207D0D0A20204D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B6974656D49645D203D206E756C6C3B0D0A7D0D0A0D0A0D0A636F6E7374206D6170626974735F6C6F6465737461725F74696E797364';
wwv_flow_imp.g_varchar2_table(192) := '66203D206E6577206D6170626974735F74696E79736466287B0D0A2020666F6E7453697A653A2031362C0D0A2020666F6E7446616D696C793A2027466F6E74204150455820536D616C6C272C0D0A7D293B0D0A0D0A66756E6374696F6E206D6170626974';
wwv_flow_imp.g_varchar2_table(193) := '735F6C6F6465737461725F696D6167655F68616E646C657228657629207B0D0A202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A20202020636F6E7374206D6170203D2065762E74617267';
wwv_flow_imp.g_varchar2_table(194) := '65743B0D0A20202020696620286D61702E686173496D6167652865762E69642929207B0D0A2020202020207265736F6C766528293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A202020206966202865762E69642E73746172747357';
wwv_flow_imp.g_varchar2_table(195) := '697468282766612D272929207B0D0A2020202020202F2A20466967757265206F757420776861742063686172616374657220746869732069636F6E2075736573202A2F0D0A202020202020636F6E7374207370616E203D20646F63756D656E742E637265';
wwv_flow_imp.g_varchar2_table(196) := '617465456C656D656E7428277370616E27293B0D0A2020202020207370616E2E7374796C652E646973706C6179203D20276E6F6E65273B0D0A2020202020207370616E2E636C6173734C6973742E6164642827666127293B0D0A2020202020207370616E';
wwv_flow_imp.g_varchar2_table(197) := '2E636C6173734C6973742E6164642865762E6964293B0D0A2020202020202F2A2041646420746865207370616E20746F2074686520444F4D20736F20697473207374796C65732063616E20626520636F6D7075746564202A2F0D0A2020202020206D6170';
wwv_flow_imp.g_varchar2_table(198) := '2E676574436F6E7461696E657228292E617070656E644368696C64287370616E293B0D0A2020202020202F2A20476574207468652069636F6E20636861726163746572202A2F0D0A202020202020636F6E737420636F6D70757465645374796C65203D20';
wwv_flow_imp.g_varchar2_table(199) := '77696E646F772E676574436F6D70757465645374796C65287370616E2C20273A6265666F726527293B0D0A202020202020636F6E73742069636F6E43686172203D20636F6D70757465645374796C652E636F6E74656E742E737562737472696E6728312C';
wwv_flow_imp.g_varchar2_table(200) := '2032293B0D0A2020202020207370616E2E72656D6F766528293B0D0A0D0A202020202020636F6E737420676C797068203D206D6170626974735F6C6F6465737461725F74696E797364662E647261772869636F6E43686172293B0D0A2020202020202F2A';
wwv_flow_imp.g_varchar2_table(201) := '2041646420524742206368616E6E656C73202A2F0D0A202020202020636F6E7374207267626144617461203D206E65772055696E7438417272617928676C7970682E7769647468202A20676C7970682E686569676874202A2034293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(202) := '666F7220286C65742069203D20303B2069203C20676C7970682E646174612E6C656E6774683B2069202B2B29207B0D0A202020202020202072676261446174615B69202A2034202B20335D203D20676C7970682E646174615B695D3B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(203) := '7D0D0A2020202020206D61702E616464496D6167652865762E69642C207B20646174613A2072676261446174612C2077696474683A20676C7970682E77696474682C206865696768743A20676C7970682E686569676874207D2C207B7364663A20747275';
wwv_flow_imp.g_varchar2_table(204) := '657D293B0D0A2020202020207265736F6C766528293B0D0A202020207D20656C7365206966202865762E69642E7374617274735769746828617065782E656E762E4150505F46494C45532929207B0D0A2020202020206D61702E6C6F6164496D61676528';
wwv_flow_imp.g_varchar2_table(205) := '65762E69642C20285F2C20696D6729203D3E207B0D0A202020202020202069662028216D61702E686173496D6167652865762E69642929207B0D0A202020202020202020206D61702E616464496D6167652865762E69642C20696D67293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(206) := '202020207D0D0A20202020202020207265736F6C766528293B0D0A2020202020207D293B0D0A202020207D0D0A20207D293B0D0A7D3B0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(908334346325202017)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_file_name=>'mapbits-lodestarlayer.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A2046726F6D203C68747470733A2F2F6769746875622E636F6D2F6D6170626F782F74696E792D7364662F626C6F622F356264313330323034663334316163666439373430383161373931626539333937666231306333392F696E6465782E6A733E2E';
wwv_flow_imp.g_varchar2_table(2) := '0D0A20202042534420322D636C61757365206C6963656E73652E0D0A2020204164617074656420746F206E6F7420757365204553206D6F64756C65732E202A2F0D0A0D0A636F6E7374206D6170626974735F74696E79736466203D20282829203D3E207B';
wwv_flow_imp.g_varchar2_table(3) := '0D0A2020636F6E737420494E46203D20316532303B0D0A0D0A2020636C6173732054696E79534446207B0D0A202020202020636F6E7374727563746F72287B0D0A20202020202020202020666F6E7453697A65203D2032342C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(4) := '20627566666572203D20332C0D0A20202020202020202020726164697573203D20382C0D0A202020202020202020206375746F6666203D20302E32352C0D0A20202020202020202020666F6E7446616D696C79203D202773616E732D7365726966272C0D';
wwv_flow_imp.g_varchar2_table(5) := '0A20202020202020202020666F6E74576569676874203D20276E6F726D616C272C0D0A20202020202020202020666F6E745374796C65203D20276E6F726D616C270D0A2020202020207D203D207B7D29207B0D0A20202020202020202020746869732E62';
wwv_flow_imp.g_varchar2_table(6) := '7566666572203D206275666665723B0D0A20202020202020202020746869732E6375746F6666203D206375746F66663B0D0A20202020202020202020746869732E726164697573203D207261646975733B0D0A0D0A202020202020202020202F2F206D61';
wwv_flow_imp.g_varchar2_table(7) := '6B65207468652063616E7661732073697A652062696720656E6F75676820746F20626F746820686176652074686520737065636966696564206275666665722061726F756E642074686520676C7970680D0A202020202020202020202F2F20666F722022';
wwv_flow_imp.g_varchar2_table(8) := '68616C6F222C20616E64206163636F756E7420666F7220736F6D6520676C7970687320706F737369626C79206265696E67206C6172676572207468616E20746865697220666F6E742073697A650D0A20202020202020202020636F6E73742073697A6520';
wwv_flow_imp.g_varchar2_table(9) := '3D20746869732E73697A65203D20666F6E7453697A65202B20627566666572202A20343B0D0A0D0A20202020202020202020636F6E73742063616E766173203D20746869732E5F63726561746543616E7661732873697A65293B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(10) := '2020636F6E737420637478203D20746869732E637478203D2063616E7661732E676574436F6E7465787428273264272C207B77696C6C526561644672657175656E746C793A20747275657D293B0D0A202020202020202020206374782E666F6E74203D20';
wwv_flow_imp.g_varchar2_table(11) := '60247B666F6E745374796C657D20247B666F6E745765696768747D20247B666F6E7453697A657D707820247B666F6E7446616D696C797D603B0D0A0D0A202020202020202020206374782E74657874426173656C696E65203D2027616C70686162657469';
wwv_flow_imp.g_varchar2_table(12) := '63273B0D0A202020202020202020206374782E74657874416C69676E203D20276C656674273B202F2F204E656365737361727920736F20746861742052544C207465787420646F65736E2774206861766520646966666572656E7420616C69676E6D656E';
wwv_flow_imp.g_varchar2_table(13) := '740D0A202020202020202020206374782E66696C6C5374796C65203D2027626C61636B273B0D0A0D0A202020202020202020202F2F2074656D706F726172792061727261797320666F72207468652064697374616E6365207472616E73666F726D0D0A20';
wwv_flow_imp.g_varchar2_table(14) := '202020202020202020746869732E677269644F75746572203D206E657720466C6F6174363441727261792873697A65202A2073697A65293B0D0A20202020202020202020746869732E67726964496E6E6572203D206E657720466C6F6174363441727261';
wwv_flow_imp.g_varchar2_table(15) := '792873697A65202A2073697A65293B0D0A20202020202020202020746869732E66203D206E657720466C6F6174363441727261792873697A65293B0D0A20202020202020202020746869732E7A203D206E657720466C6F6174363441727261792873697A';
wwv_flow_imp.g_varchar2_table(16) := '65202B2031293B0D0A20202020202020202020746869732E76203D206E65772055696E74313641727261792873697A65293B0D0A2020202020207D0D0A0D0A2020202020205F63726561746543616E7661732873697A6529207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(17) := '2020636F6E73742063616E766173203D20646F63756D656E742E637265617465456C656D656E74282763616E76617327293B0D0A2020202020202020202063616E7661732E7769647468203D2063616E7661732E686569676874203D2073697A653B0D0A';
wwv_flow_imp.g_varchar2_table(18) := '2020202020202020202072657475726E2063616E7661733B0D0A2020202020207D0D0A0D0A20202020202064726177286368617229207B0D0A20202020202020202020636F6E7374207B0D0A202020202020202020202020202077696474683A20676C79';
wwv_flow_imp.g_varchar2_table(19) := '7068416476616E63652C0D0A202020202020202020202020202061637475616C426F756E64696E67426F78417363656E742C0D0A202020202020202020202020202061637475616C426F756E64696E67426F7844657363656E742C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(20) := '2020202020202061637475616C426F756E64696E67426F784C6566742C0D0A202020202020202020202020202061637475616C426F756E64696E67426F7852696768740D0A202020202020202020207D203D20746869732E6374782E6D65617375726554';
wwv_flow_imp.g_varchar2_table(21) := '6578742863686172293B0D0A0D0A202020202020202020202F2F2054686520696E74656765722F706978656C2070617274206F662074686520746F7020616C69676E6D656E7420697320656E636F64656420696E206D6574726963732E676C797068546F';
wwv_flow_imp.g_varchar2_table(22) := '700D0A202020202020202020202F2F205468652072656D61696E64657220697320696D706C696369746C7920656E636F64656420696E2074686520726173746572697A6174696F6E0D0A20202020202020202020636F6E737420676C797068546F70203D';
wwv_flow_imp.g_varchar2_table(23) := '204D6174682E6365696C2861637475616C426F756E64696E67426F78417363656E74293B0D0A20202020202020202020636F6E737420676C7970684C656674203D20303B0D0A0D0A202020202020202020202F2F2049662074686520676C797068206F76';
wwv_flow_imp.g_varchar2_table(24) := '6572666C6F7773207468652063616E7661732073697A652C2069742077696C6C20626520636C69707065642061742074686520626F74746F6D2F72696768740D0A20202020202020202020636F6E737420676C7970685769647468203D204D6174682E6D';
wwv_flow_imp.g_varchar2_table(25) := '617828302C204D6174682E6D696E28746869732E73697A65202D20746869732E6275666665722C204D6174682E6365696C2861637475616C426F756E64696E67426F785269676874202D2061637475616C426F756E64696E67426F784C6566742929293B';
wwv_flow_imp.g_varchar2_table(26) := '0D0A20202020202020202020636F6E737420676C797068486569676874203D204D6174682E6D696E28746869732E73697A65202D20746869732E6275666665722C20676C797068546F70202B204D6174682E6365696C2861637475616C426F756E64696E';
wwv_flow_imp.g_varchar2_table(27) := '67426F7844657363656E7429293B0D0A0D0A20202020202020202020636F6E7374207769647468203D20676C7970685769647468202B2032202A20746869732E6275666665723B0D0A20202020202020202020636F6E737420686569676874203D20676C';
wwv_flow_imp.g_varchar2_table(28) := '797068486569676874202B2032202A20746869732E6275666665723B0D0A0D0A20202020202020202020636F6E7374206C656E203D204D6174682E6D6178287769647468202A206865696768742C2030293B0D0A20202020202020202020636F6E737420';
wwv_flow_imp.g_varchar2_table(29) := '64617461203D206E65772055696E7438436C616D7065644172726179286C656E293B0D0A20202020202020202020636F6E737420676C797068203D207B646174612C2077696474682C206865696768742C20676C79706857696474682C20676C79706848';
wwv_flow_imp.g_varchar2_table(30) := '65696768742C20676C797068546F702C20676C7970684C6566742C20676C797068416476616E63657D3B0D0A2020202020202020202069662028676C7970685769647468203D3D3D2030207C7C20676C797068486569676874203D3D3D20302920726574';
wwv_flow_imp.g_varchar2_table(31) := '75726E20676C7970683B0D0A0D0A20202020202020202020636F6E7374207B6374782C206275666665722C2067726964496E6E65722C20677269644F757465727D203D20746869733B0D0A202020202020202020206374782E636C656172526563742862';
wwv_flow_imp.g_varchar2_table(32) := '75666665722C206275666665722C20676C79706857696474682C20676C797068486569676874293B0D0A202020202020202020206374782E66696C6C5465787428636861722C206275666665722C20627566666572202B20676C797068546F70293B0D0A';
wwv_flow_imp.g_varchar2_table(33) := '20202020202020202020636F6E737420696D6744617461203D206374782E676574496D61676544617461286275666665722C206275666665722C20676C79706857696474682C20676C797068486569676874293B0D0A0D0A202020202020202020202F2F';
wwv_flow_imp.g_varchar2_table(34) := '20496E697469616C697A65206772696473206F7574736964652074686520676C7970682072616E676520746F20616C70686120300D0A20202020202020202020677269644F757465722E66696C6C28494E462C20302C206C656E293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(35) := '2020202067726964496E6E65722E66696C6C28302C20302C206C656E293B0D0A0D0A20202020202020202020666F7220286C65742079203D20303B2079203C20676C7970684865696768743B20792B2B29207B0D0A202020202020202020202020202066';
wwv_flow_imp.g_varchar2_table(36) := '6F7220286C65742078203D20303B2078203C20676C79706857696474683B20782B2B29207B0D0A202020202020202020202020202020202020636F6E73742061203D20696D67446174612E646174615B34202A202879202A20676C797068576964746820';
wwv_flow_imp.g_varchar2_table(37) := '2B207829202B20335D202F203235353B202F2F20616C7068612076616C75650D0A2020202020202020202020202020202020206966202861203D3D3D20302920636F6E74696E75653B202F2F20656D70747920706978656C730D0A0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(38) := '2020202020202020202020636F6E7374206A203D202879202B2062756666657229202A207769647468202B2078202B206275666665723B0D0A0D0A2020202020202020202020202020202020206966202861203D3D3D203129207B202F2F2066756C6C79';
wwv_flow_imp.g_varchar2_table(39) := '20647261776E20706978656C730D0A20202020202020202020202020202020202020202020677269644F757465725B6A5D203D20303B0D0A2020202020202020202020202020202020202020202067726964496E6E65725B6A5D203D20494E463B0D0A0D';
wwv_flow_imp.g_varchar2_table(40) := '0A2020202020202020202020202020202020207D20656C7365207B202F2F20616C696173656420706978656C730D0A20202020202020202020202020202020202020202020636F6E73742064203D20302E35202D20613B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(41) := '2020202020202020202020677269644F757465725B6A5D203D2064203E2030203F2064202A2064203A20303B0D0A2020202020202020202020202020202020202020202067726964496E6E65725B6A5D203D2064203C2030203F2064202A2064203A2030';
wwv_flow_imp.g_varchar2_table(42) := '3B0D0A2020202020202020202020202020202020207D0D0A20202020202020202020202020207D0D0A202020202020202020207D0D0A0D0A2020202020202020202065647428677269644F757465722C20302C20302C2077696474682C20686569676874';
wwv_flow_imp.g_varchar2_table(43) := '2C2077696474682C20746869732E662C20746869732E762C20746869732E7A293B0D0A202020202020202020206564742867726964496E6E65722C206275666665722C206275666665722C20676C79706857696474682C20676C7970684865696768742C';
wwv_flow_imp.g_varchar2_table(44) := '2077696474682C20746869732E662C20746869732E762C20746869732E7A293B0D0A0D0A20202020202020202020666F7220286C65742069203D20303B2069203C206C656E3B20692B2B29207B0D0A2020202020202020202020202020636F6E73742064';
wwv_flow_imp.g_varchar2_table(45) := '203D204D6174682E7371727428677269644F757465725B695D29202D204D6174682E737172742867726964496E6E65725B695D293B0D0A2020202020202020202020202020646174615B695D203D204D6174682E726F756E6428323535202D2032353520';
wwv_flow_imp.g_varchar2_table(46) := '2A202864202F20746869732E726164697573202B20746869732E6375746F666629293B0D0A202020202020202020207D0D0A0D0A2020202020202020202072657475726E20676C7970683B0D0A2020202020207D0D0A20207D0D0A0D0A20202F2F203244';
wwv_flow_imp.g_varchar2_table(47) := '204575636C696465616E20737175617265642064697374616E6365207472616E73666F726D2062792046656C7A656E737A77616C6220262048757474656E6C6F636865722068747470733A2F2F63732E62726F776E2E6564752F7E7066662F7061706572';
wwv_flow_imp.g_varchar2_table(48) := '732F64742D66696E616C2E7064660D0A202066756E6374696F6E2065647428646174612C2078302C2079302C2077696474682C206865696768742C206772696453697A652C20662C20762C207A29207B0D0A202020202020666F7220286C65742078203D';
wwv_flow_imp.g_varchar2_table(49) := '2078303B2078203C207830202B2077696474683B20782B2B2920656474316428646174612C207930202A206772696453697A65202B20782C206772696453697A652C206865696768742C20662C20762C207A293B0D0A202020202020666F7220286C6574';
wwv_flow_imp.g_varchar2_table(50) := '2079203D2079303B2079203C207930202B206865696768743B20792B2B2920656474316428646174612C2079202A206772696453697A65202B2078302C20312C2077696474682C20662C20762C207A293B0D0A20207D0D0A0D0A20202F2F203144207371';
wwv_flow_imp.g_varchar2_table(51) := '75617265642064697374616E6365207472616E73666F726D0D0A202066756E6374696F6E20656474316428677269642C206F66667365742C207374726964652C206C656E6774682C20662C20762C207A29207B0D0A202020202020765B305D203D20303B';
wwv_flow_imp.g_varchar2_table(52) := '0D0A2020202020207A5B305D203D202D494E463B0D0A2020202020207A5B315D203D20494E463B0D0A202020202020665B305D203D20677269645B6F66667365745D3B0D0A0D0A202020202020666F7220286C65742071203D20312C206B203D20302C20';
wwv_flow_imp.g_varchar2_table(53) := '73203D20303B2071203C206C656E6774683B20712B2B29207B0D0A20202020202020202020665B715D203D20677269645B6F6666736574202B2071202A207374726964655D3B0D0A20202020202020202020636F6E7374207132203D2071202A20713B0D';
wwv_flow_imp.g_varchar2_table(54) := '0A20202020202020202020646F207B0D0A2020202020202020202020202020636F6E73742072203D20765B6B5D3B0D0A202020202020202020202020202073203D2028665B715D202D20665B725D202B207132202D2072202A207229202F202871202D20';
wwv_flow_imp.g_varchar2_table(55) := '7229202F20323B0D0A202020202020202020207D207768696C65202873203C3D207A5B6B5D202626202D2D6B203E202D31293B0D0A0D0A202020202020202020206B2B2B3B0D0A20202020202020202020765B6B5D203D20713B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(56) := '20207A5B6B5D203D20733B0D0A202020202020202020207A5B6B202B20315D203D20494E463B0D0A2020202020207D0D0A0D0A202020202020666F7220286C65742071203D20302C206B203D20303B2071203C206C656E6774683B20712B2B29207B0D0A';
wwv_flow_imp.g_varchar2_table(57) := '202020202020202020207768696C6520287A5B6B202B20315D203C207129206B2B2B3B0D0A20202020202020202020636F6E73742072203D20765B6B5D3B0D0A20202020202020202020636F6E7374207172203D2071202D20723B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(58) := '202020677269645B6F6666736574202B2071202A207374726964655D203D20665B725D202B207172202A2071723B0D0A2020202020207D0D0A20207D0D0A0D0A202072657475726E2054696E795344463B0D0A7D2928293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(910779990266561755)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_file_name=>'tiny-sdf.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374206D6170626974735F74696E797364663D2828293D3E7B636F6E737420743D316532303B66756E6374696F6E206528742C652C6E2C612C732C722C682C6F2C66297B666F72286C6574206C3D653B6C3C652B613B6C2B2B296928742C6E2A72';
wwv_flow_imp.g_varchar2_table(2) := '2B6C2C722C732C682C6F2C66293B666F72286C6574206C3D6E3B6C3C6E2B733B6C2B2B296928742C6C2A722B652C312C612C682C6F2C66297D66756E6374696F6E206928652C692C6E2C612C732C722C68297B725B305D3D302C685B305D3D2D742C685B';
wwv_flow_imp.g_varchar2_table(3) := '315D3D742C735B305D3D655B695D3B666F72286C6574206F3D312C663D302C6C3D303B6F3C613B6F2B2B297B735B6F5D3D655B692B6F2A6E5D3B636F6E737420613D6F2A6F3B646F7B636F6E737420743D725B665D3B6C3D28735B6F5D2D735B745D2B61';
wwv_flow_imp.g_varchar2_table(4) := '2D742A74292F286F2D74292F327D7768696C65286C3C3D685B665D26262D2D663E2D31293B662B2B2C725B665D3D6F2C685B665D3D6C2C685B662B315D3D747D666F72286C657420743D302C6F3D303B743C613B742B2B297B666F72283B685B6F2B315D';
wwv_flow_imp.g_varchar2_table(5) := '3C743B296F2B2B3B636F6E737420613D725B6F5D2C663D742D613B655B692B742A6E5D3D735B615D2B662A667D7D72657475726E20636C6173737B636F6E7374727563746F72287B666F6E7453697A653A743D32342C6275666665723A653D332C726164';
wwv_flow_imp.g_varchar2_table(6) := '6975733A693D382C6375746F66663A6E3D2E32352C666F6E7446616D696C793A613D2273616E732D7365726966222C666F6E745765696768743A733D226E6F726D616C222C666F6E745374796C653A723D226E6F726D616C227D3D7B7D297B746869732E';
wwv_flow_imp.g_varchar2_table(7) := '6275666665723D652C746869732E6375746F66663D6E2C746869732E7261646975733D693B636F6E737420683D746869732E73697A653D742B342A652C6F3D746869732E5F63726561746543616E7661732868292C663D746869732E6374783D6F2E6765';
wwv_flow_imp.g_varchar2_table(8) := '74436F6E7465787428223264222C7B77696C6C526561644672657175656E746C793A21307D293B662E666F6E743D60247B727D20247B737D20247B747D707820247B617D602C662E74657874426173656C696E653D22616C7068616265746963222C662E';
wwv_flow_imp.g_varchar2_table(9) := '74657874416C69676E3D226C656674222C662E66696C6C5374796C653D22626C61636B222C746869732E677269644F757465723D6E657720466C6F61743634417272617928682A68292C746869732E67726964496E6E65723D6E657720466C6F61743634';
wwv_flow_imp.g_varchar2_table(10) := '417272617928682A68292C746869732E663D6E657720466C6F6174363441727261792868292C746869732E7A3D6E657720466C6F61743634417272617928682B31292C746869732E763D6E65772055696E74313641727261792868297D5F637265617465';
wwv_flow_imp.g_varchar2_table(11) := '43616E7661732874297B636F6E737420653D646F63756D656E742E637265617465456C656D656E74282263616E76617322293B72657475726E20652E77696474683D652E6865696768743D742C657D647261772869297B636F6E73747B77696474683A6E';
wwv_flow_imp.g_varchar2_table(12) := '2C61637475616C426F756E64696E67426F78417363656E743A612C61637475616C426F756E64696E67426F7844657363656E743A732C61637475616C426F756E64696E67426F784C6566743A722C61637475616C426F756E64696E67426F785269676874';
wwv_flow_imp.g_varchar2_table(13) := '3A687D3D746869732E6374782E6D656173757265546578742869292C6F3D4D6174682E6365696C2861292C663D4D6174682E6D617828302C4D6174682E6D696E28746869732E73697A652D746869732E6275666665722C4D6174682E6365696C28682D72';
wwv_flow_imp.g_varchar2_table(14) := '2929292C6C3D4D6174682E6D696E28746869732E73697A652D746869732E6275666665722C6F2B4D6174682E6365696C287329292C633D662B322A746869732E6275666665722C753D6C2B322A746869732E6275666665722C643D4D6174682E6D617828';
wwv_flow_imp.g_varchar2_table(15) := '632A752C30292C673D6E65772055696E7438436C616D70656441727261792864292C793D7B646174613A672C77696474683A632C6865696768743A752C676C79706857696474683A662C676C7970684865696768743A6C2C676C797068546F703A6F2C67';
wwv_flow_imp.g_varchar2_table(16) := '6C7970684C6566743A302C676C797068416476616E63653A6E7D3B696628303D3D3D667C7C303D3D3D6C2972657475726E20793B636F6E73747B6374783A782C6275666665723A6D2C67726964496E6E65723A772C677269644F757465723A627D3D7468';
wwv_flow_imp.g_varchar2_table(17) := '69733B782E636C65617252656374286D2C6D2C662C6C292C782E66696C6C5465787428692C6D2C6D2B6F293B636F6E737420703D782E676574496D61676544617461286D2C6D2C662C6C293B622E66696C6C28742C302C64292C772E66696C6C28302C30';
wwv_flow_imp.g_varchar2_table(18) := '2C64293B666F72286C657420653D303B653C6C3B652B2B29666F72286C657420693D303B693C663B692B2B297B636F6E7374206E3D702E646174615B342A28652A662B69292B335D2F3235353B696628303D3D3D6E29636F6E74696E75653B636F6E7374';
wwv_flow_imp.g_varchar2_table(19) := '20613D28652B6D292A632B692B6D3B696628313D3D3D6E29625B615D3D302C775B615D3D743B656C73657B636F6E737420743D2E352D6E3B625B615D3D743E303F742A743A302C775B615D3D743C303F742A743A307D7D6528622C302C302C632C752C63';
wwv_flow_imp.g_varchar2_table(20) := '2C746869732E662C746869732E762C746869732E7A292C6528772C6D2C6D2C662C6C2C632C746869732E662C746869732E762C746869732E7A293B666F72286C657420743D303B743C643B742B2B297B636F6E737420653D4D6174682E7371727428625B';
wwv_flow_imp.g_varchar2_table(21) := '745D292D4D6174682E7371727428775B745D293B675B745D3D4D6174682E726F756E64283235352D3235352A28652F746869732E7261646975732B746869732E6375746F666629297D72657475726E20797D7D7D2928293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(915296630157304202)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_file_name=>'tiny-sdf.min.js'
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
