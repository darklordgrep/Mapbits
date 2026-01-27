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
--   Date and Time:   15:23 Friday November 7, 2025
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
,p_css_file_urls=>'#PLUGIN_FILES#mapbits-lodestarlayer#MIN#.css'
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
'  l_numeric_region_id number;',
'  l_sequence_no number;',
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
'    select nvl(r.static_id, ''R'' || r.region_id), r.region_id, i.display_sequence into l_region_id, l_numeric_region_id, l_sequence_no',
'      from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception',
'    when no_data_found then',
'      raise_application_error(-20391, ''Configuration ERROR:  Mapbits Lodestar Layer Item ['' || p_item.name || ''] is not associated with a Map region.'');',
'  end;',
'',
'  if l_source_type = ''region_source'' then',
'    select l_submit_items || '','' || listagg(f.item_name, '','')',
'      into l_submit_items',
'      from apex_appl_page_filters f',
'        left join apex_application_page_regions r on r.region_id = f.region_id',
'      where r.filtered_region_id = l_numeric_region_id;',
'    select l_submit_items || '','' || r.ajax_items_to_submit',
'      into l_submit_items',
'      from apex_application_page_regions r',
'      where r.region_id = l_numeric_region_id;',
'  end if;',
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
'  htp.p(''<input type="hidden" id="'' || p_item.name || ''" name="'' || p_item.name || ''"/>'');',
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
'    || apex_javascript.add_attribute(''lineWidth'', cast(p_item.attribute_16 as number))',
'    || apex_javascript.add_attribute(''lineDashArray'', p_item.attribute_17)',
'    || apex_javascript.add_attribute(''fontSize'', cast(p_item.attribute_18 as number))',
'    || apex_javascript.add_attribute(''icon'', l_icon)',
'    || apex_javascript.add_attribute(''labelColumn'', l_label_column)',
'    || apex_javascript.add_attribute(''idColumn'', l_id_column)',
'    || apex_javascript.add_attribute(''submitItems'', l_submit_items)',
'    || apex_javascript.add_attribute(''sourceType'', l_source_type)',
'    || apex_javascript.add_attribute(''clickable'', case when l_da_count + l_infowin_count > 0 then true else false end)',
'    || ''layerDefinition: '' || nvl(l_layer_definition, ''null'') || '',''',
'    || ''sourceOptions: '' || nvl(l_source_options, ''null'') || '',''',
'    || ''initJs: ('' || nvl(p_item.init_javascript_code, ''null'') || '')''',
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
'  l_source_filter varchar2(4000) := p_item.attribute_15;',
'',
'  is_first_feature boolean := true;',
'  n_cols integer;',
'  feature json_object_t;',
'  feature_props json_object_t;',
'  geometry sdo_geometry;',
'  l_geojson clob;',
'  query_ctx apex_exec.t_context;',
'  column_list apex_exec.t_columns;',
'  id_col number := 0;',
'  geometry_col number := 0;',
'begin',
'  if source_type = ''region_source'' then',
'    query_ctx := apex_region.open_query_context(',
'      p_page_id => :APP_PAGE_ID,',
'      p_region_id => p_item.region_id,',
'      p_outer_sql => (case when l_source_filter is not null then ''select * from ('' || apex_exec.c_data_source_table_name || '') where '' || l_source_filter else null end)',
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
'        case column_list(i).data_type',
'          when apex_exec.c_data_type_sdo_geometry then',
'            geometry := apex_exec.get_sdo_geometry(query_ctx, i);',
'            if geometry is null then',
'              feature.put_null(''geometry'');',
'            else',
'              feature.put(''geometry'', json_element_t.parse(sdo_util.to_geojson(geometry)));',
'            end if;',
'          when apex_exec.c_data_type_clob then',
'            l_geojson := apex_exec.get_clob(query_ctx, i);',
'            if l_geojson is null then',
'              feature.put_null(''geometry'');',
'            else',
'              feature.put(''geometry'', json_element_t.parse(l_geojson));',
'            end if;',
'          else',
'            raise_application_error(-20001, ''Wrong geometry column type. Expected sdo_geometry or clob.'');',
'        end case;',
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
,p_standard_attributes=>'INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits Lodestar Layer plugin provides an alternative map layer to Apex''s built-in layers. It includes advanced configuration options that expose the full power of MapLibre styling and labeling capability.'
,p_version_identifier=>'4.9.20250410'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Lodestar Layer',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_lodestar.sql 21190 2025-11-07 21:29:10Z b2eddjw9 $',
'Date     : $Date: 2025-11-07 15:29:10 -0600 (Fri, 07 Nov 2025) $',
'Revision : $Revision: 21190 $',
'Requires : Application Express >= 22.2',
'',
'11/06/2025 Added zoomToFeature() method',
'06/10/2025 Added rectangle select feature',
'05/30/2025 Added line width, dashes, and font size attributes',
'05/27/2025 Fixed AJAX item submission for Region Source sources',
'05/21/2025 Added Where Clause attribute for Region Source layers',
'',
'Version 4.9 Updates:',
'04/24/2025 Use localStorage instead of cookies to persist visibility and persist settings between sessions',
'04/02/2025 Add edit API. Add more options for selections. Add Initialization Javascript attribute.',
'03/26/2025 Fix bug where clickable layers removed the Drawing plugin''s crosshair cursor',
'',
'Version 4.8 Updates:',
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
,p_files_version=>882
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(144466158183551049)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_title=>'Label'
,p_display_sequence=>4
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(130813524782074546)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_title=>'Source'
,p_display_sequence=>1
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(130813994333074547)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_title=>'Display'
,p_display_sequence=>3
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(130861066671157249)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_title=>'Columns'
,p_display_sequence=>2
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
,p_depending_on_attribute_id=>wwv_flow_imp.id(72639147778939905)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'query'
,p_attribute_group_id=>wwv_flow_imp.id(130813524782074546)
,p_examples=>'select shape, usace_district_id from mb4_usace_districts'
,p_help_text=>'Source query used to define the layer. At a minimum this must include an sdo_geometry column or a clob column containing GeoJSON. Additional attributes should include a unique identifier column if labeling features or interaction with features is req'
||'uired. Any additional attributes that are included in the query can be used for constructing labels or other MapLibre attribute operations.'
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
,p_depending_on_attribute_id=>wwv_flow_imp.id(72639147778939905)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'javascript'
,p_attribute_group_id=>wwv_flow_imp.id(130861066671157249)
,p_help_text=>'Column from the source query that represents the geometry as sdo_geometry objects or as clobs containing GeoJSON.'
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
,p_attribute_group_id=>wwv_flow_imp.id(130813994333074547)
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
,p_attribute_group_id=>wwv_flow_imp.id(130813994333074547)
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
,p_attribute_group_id=>wwv_flow_imp.id(130813994333074547)
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
,p_attribute_group_id=>wwv_flow_imp.id(130813524782074546)
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
 p_id=>wwv_flow_imp.id(72639147778939905)
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
,p_attribute_group_id=>wwv_flow_imp.id(130813524782074546)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(72646553813941325)
,p_plugin_attribute_id=>wwv_flow_imp.id(72639147778939905)
,p_display_sequence=>10
,p_display_value=>'SQL Query'
,p_return_value=>'query'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(72646986619942104)
,p_plugin_attribute_id=>wwv_flow_imp.id(72639147778939905)
,p_display_sequence=>20
,p_display_value=>'Region Source'
,p_return_value=>'region_source'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(72647327619942742)
,p_plugin_attribute_id=>wwv_flow_imp.id(72639147778939905)
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
,p_depending_on_attribute_id=>wwv_flow_imp.id(72639147778939905)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'javascript'
,p_attribute_group_id=>wwv_flow_imp.id(130861066671157249)
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
,p_attribute_group_id=>wwv_flow_imp.id(130813994333074547)
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
,p_attribute_group_id=>wwv_flow_imp.id(144466158183551049)
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
,p_attribute_group_id=>wwv_flow_imp.id(130813994333074547)
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
,p_attribute_group_id=>wwv_flow_imp.id(130813994333074547)
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
,p_depending_on_attribute_id=>wwv_flow_imp.id(72639147778939905)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'javascript,region_source'
,p_attribute_group_id=>wwv_flow_imp.id(130813524782074546)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(130809190075064694)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Where Clause'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(72639147778939905)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'region_source'
,p_attribute_group_id=>wwv_flow_imp.id(130813524782074546)
,p_help_text=>'A SQL where clause to filter the region source.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(144431187250463025)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>160
,p_prompt=>'Line Width'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'line'
,p_attribute_group_id=>wwv_flow_imp.id(130813994333074547)
,p_help_text=>'The width of the line.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(144446568991522472)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>170
,p_prompt=>'Dashes'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(910915729958609763)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'line'
,p_attribute_group_id=>wwv_flow_imp.id(130813994333074547)
,p_help_text=>'Create dashed lines by entering the lengths of dashes and gaps. Enter the numbers separated by spaces.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(144470574183556197)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>180
,p_prompt=>'Font Size'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(144466158183551049)
,p_help_text=>'The size of the font to use for the label.'
);
wwv_flow_imp_shared.create_plugin_std_attribute(
 p_id=>wwv_flow_imp.id(90715343351711980)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
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
 p_id=>wwv_flow_imp.id(90714663525698226)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_name=>'selection_changed'
,p_display_name=>'Selection Changed'
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
wwv_flow_imp.g_varchar2_table(1) := '2E6D61706C69627265676C2D6374726C2D67726F757020627574746F6E2E6D6170626974732D726563742D73656C6563742D627574746F6E2D746F67676C6564207B0D0A20206261636B67726F756E642D636F6C6F723A2072676228302C20302C20302C';
wwv_flow_imp.g_varchar2_table(2) := '20302E32293B0D0A7D0D0A0D0A2E6D6170626974732D726563742D73656C6563742D626F78207B0D0A2020706F736974696F6E3A206162736F6C7574653B0D0A20206261636B67726F756E642D636F6C6F723A2072676228302C20302C20302C20302E32';
wwv_flow_imp.g_varchar2_table(3) := '293B0D0A2020626F726465723A2032707820646F7474656420626C61636B3B0D0A2020706F696E7465722D6576656E74733A206E6F6E653B0D0A7D0D0A0D0A2E6D61706C69627265676C2D6D61702E6D6170626974732D726563742D73656C6563742D61';
wwv_flow_imp.g_varchar2_table(4) := '6374697665202E6D61706C69627265676C2D63616E7661732D636F6E7461696E6572207B0D0A2020637572736F723A2063726F7373686169723B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(153849873548121877)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_file_name=>'mapbits-lodestarlayer.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D6170626974732D726563742D73656C6563742D626F782C2E6D61706C69627265676C2D6374726C2D67726F757020627574746F6E2E6D6170626974732D726563742D73656C6563742D627574746F6E2D746F67676C65647B6261636B67726F756E64';
wwv_flow_imp.g_varchar2_table(2) := '2D636F6C6F723A72676228302C302C302C2E32297D2E6D6170626974732D726563742D73656C6563742D626F787B706F736974696F6E3A6162736F6C7574653B626F726465723A32707820646F7474656420233030303B706F696E7465722D6576656E74';
wwv_flow_imp.g_varchar2_table(3) := '733A6E6F6E657D2E6D61706C69627265676C2D6D61702E6D6170626974732D726563742D73656C6563742D616374697665202E6D61706C69627265676C2D63616E7661732D636F6E7461696E65727B637572736F723A63726F7373686169727D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(153858857537157849)
,p_plugin_id=>wwv_flow_imp.id(908325001813202010)
,p_file_name=>'mapbits-lodestarlayer.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
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
wwv_flow_imp.g_varchar2_table(6) := '4964656E7469666965723A742C726567696F6E49643A612C6C61796572547970653A692C6C6162656C436F6C756D6E3A722C6C61796572446566696E6974696F6E3A6F2C73657175656E63654E756D6265723A6E2C7469746C653A732C636F6C6F723A6C';
wwv_flow_imp.g_varchar2_table(7) := '2C6F7061636974793A632C6F75746C696E65436F6C6F723A642C69636F6E3A702C736F757263654F7074696F6E733A412C6964436F6C756D6E3A792C636C69636B61626C653A672C7375626D69744974656D733A752C736F75726365547970653A6D2C69';
wwv_flow_imp.g_varchar2_table(8) := '6E69744A733A662C6C696E6557696474683A5F2C6C696E654461736841727261793A682C666F6E7453697A653A627D297B69662821612972657475726E20766F696420617065782E64656275672E6572726F7228226D6170626974735F6C6F6465737461';
wwv_flow_imp.g_varchar2_table(9) := '726C6179657220222B652B22203A204974656D206973206E6F7420696E206120726567696F6E2E22293B636F6E737420493D617065782E73746F726167652E67657453636F7065644C6F63616C53746F72616765287B75736541707049643A21302C7573';
wwv_flow_imp.g_varchar2_table(10) := '655061676549643A21302C726567696F6E49643A617D293B6C657420773D5B5D3B636F6E737420453D652B222D736F75726365223B6C657420423D492E6765744974656D28224D6170626974735F4C6F6465737461724C617965725F222B652B225F7669';
wwv_flow_imp.g_varchar2_table(11) := '736962696C69747922293B76617220782C533D6E756C6C3B6C657420763D653D3E7B423D657D2C443D6E756C6C2C433D5B5D3B636F6E7374204D3D6E6577204D61702C463D6E6577204D61702C513D6E6577204D61702C523D6E6577204D61702C6B3D28';
wwv_flow_imp.g_varchar2_table(12) := '293D3E21215326265B22696E222C5B226964225D2C5B226C69746572616C222C41727261792E66726F6D2853292E6D61702828653D3E522E67657428652929292E66696C7465722828653D3E766F69642030213D3D6529295D5D3B6C6574204C3D6E756C';
wwv_flow_imp.g_varchar2_table(13) := '6C3B636F6E737420503D28293D3E284C7C7C284C3D2270726F706572747922292C4C293B6C657420473D7B7D2C4E3D6E756C6C3B636F6E737420543D28293D3E677C7C472E656E61626C65436C69636B2C593D6E65772050726F6D697365282828742C69';
wwv_flow_imp.g_varchar2_table(14) := '293D3E7B636F6E737420723D617065782E726567696F6E2861293B6966286E756C6C3D3D722972657475726E20617065782E64656275672E6572726F7228226D6170626974735F6C6F6465737461726C6179657220222B652B22203A20526567696F6E20';
wwv_flow_imp.g_varchar2_table(15) := '5B222B612B225D2069732068696464656E206F72206D697373696E672E22292C766F6964206928293B722E656C656D656E742E6F6E28227370617469616C6D6170696E697469616C697A6564222C2828293D3E7B636F6E737420653D617065782E726567';
wwv_flow_imp.g_varchar2_table(16) := '696F6E2861292E63616C6C28226765744D61704F626A65637422293B742865297D29297D29292E7468656E2828743D3E28742E5F5F6D6170626974735F6C617965725F637572736F72733F3F3D6E6577204D61702C745B494D4147455F48414E444C4552';
wwv_flow_imp.g_varchar2_table(17) := '5F41444445445D7C7C742E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F61646465647C7C28742E6F6E28227374796C65696D6167656D697373696E67222C28653D3E7B6D6170626974735F6C6F6465737461725F696D616765';
wwv_flow_imp.g_varchar2_table(18) := '5F68616E646C65722865297D29292C742E5F5F6D6170626974735F6572726F725F68616E646C65725F61646465647C7C28742E6F6E28226572726F72222C28653D3E7B617065782E64656275672E6572726F7228604D6170206572726F7220696E207265';
wwv_flow_imp.g_varchar2_table(19) := '67696F6E20247B617D3A20602C652E6572726F72297D29292C742E5F5F6D6170626974735F6572726F725F68616E646C65725F61646465643D2130292C745B494D4147455F48414E444C45525F41444445445D3D21302C742E5F5F6D6170626974735F5F';
wwv_flow_imp.g_varchar2_table(20) := '7374796C65696D6167656D697373696E675F61646465643D2130292C6E65772050726F6D697365282828692C72293D3E7B766172206F3D736574496E74657276616C282866756E6374696F6E28297B636F6E737420723D617065782E6A51756572792822';
wwv_flow_imp.g_varchar2_table(21) := '23222B612B225F6C6567656E6422293B72262628636C656172496E74657276616C286F292C617065782E6A517565727928273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567';
wwv_flow_imp.g_varchar2_table(22) := '656E644974656D2D2D6869646561626C65223E3C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069';
wwv_flow_imp.g_varchar2_table(23) := '643D22272B652B275F6C6567656E645F656E74727922207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B6C2B27223E3C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C';
wwv_flow_imp.g_varchar2_table(24) := '6162656C222069643D22272B652B275F6C6567656E645F656E7472795F6C6162656C2220666F723D22272B652B275F6C6567656E645F656E747279223E272B28737C7C65292B273C696D672069643D22272B652B275F6C6567656E645F656E7472795F73';
wwv_flow_imp.g_varchar2_table(25) := '7461747573222F3E3C2F6C6162656C3E3C2F6469763E27292E617070656E64546F2872292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C226E6F6E6522213D3D42292C69';
wwv_flow_imp.g_varchar2_table(26) := '287429297D292C353030297D29292929293B6173796E632066756E6374696F6E206A28297B69662821782972657475726E3B636F6E737420743D783F2E646174612E66656174757265732E6D61702828653D3E7B636F6E737420743D462E67657428652E';
wwv_flow_imp.g_varchar2_table(27) := '6964293B72657475726E2264656C657465223D3D3D743F2E616374696F6E3F6E756C6C3A7B747970653A2246656174757265222C69643A652E69642C70726F706572746965733A743F742E666561747572652E70726F706572746965733A652E70726F70';
wwv_flow_imp.g_varchar2_table(28) := '6572746965732C67656F6D657472793A743F742E666561747572652E67656F6D657472793A652E67656F6D657472797D7D29292E66696C7465722828653D3E6E756C6C213D3D6529293F3F5B5D2C613D41727261792E66726F6D28462E76616C75657328';
wwv_flow_imp.g_varchar2_table(29) := '29292E66696C7465722828653D3E22637265617465223D3D3D652E616374696F6E29292E6D61702828653D3E287B747970653A2246656174757265222C69643A652E666561747572652E69642C70726F706572746965733A652E666561747572652E7072';
wwv_flow_imp.g_varchar2_table(30) := '6F706572746965732C67656F6D657472793A652E666561747572652E67656F6D657472797D2929293B433D5B2E2E2E742C2E2E2E615D2C4D2E636C65617228293B666F7228636F6E73742065206F66204329766F69642030213D3D652E696426264D2E73';
wwv_flow_imp.g_varchar2_table(31) := '657428652E69642C65293B512E636C65617228292C522E636C65617228293B6C657420693D303B636F6E737420723D653D3E7B636F6E737420743D2B2B693B72657475726E20766F69642030213D3D65262628512E73657428742C65292C522E73657428';
wwv_flow_imp.g_varchar2_table(32) := '652C7429292C747D2C6F3D7B2E2E2E782E646174612C66656174757265733A432E6D61702828653D3E7B636F6E737420743D7B747970653A2246656174757265222C69643A7228652E6964292C67656F6D657472793A652E67656F6D657472792C70726F';
wwv_flow_imp.g_varchar2_table(33) := '706572746965733A7B2E2E2E652E70726F706572746965737D7D3B72657475726E2270726F7065727479223D3D3D502829262628742E70726F706572746965735B226D6170626974732D73656C6563746564225D3D532626766F69642030213D3D652E69';
wwv_flow_imp.g_varchar2_table(34) := '6426266E756C6C213D3D652E6964262628532E68617328652E6964297C7C532E68617328652E69642E746F537472696E6728292929292C747D29297D2C6E3D617761697420593B6966286E2E676574536F75726365284529296E2E676574536F75726365';
wwv_flow_imp.g_varchar2_table(35) := '2845292E73657444617461286F293B656C73657B6C657420743D7B2E2E2E782C646174613A6F7D3B797C7C2267656E6572617465496422696E20747C7C28742E67656E657261746549643D2130292C742E636C7573746572262628743D7B2E2E2E742C63';
wwv_flow_imp.g_varchar2_table(36) := '6C757374657250726F706572746965733A7B226D6170626974732D73656C6563746564223A5B22616E79222C5B22676574222C226D6170626974732D73656C6563746564225D5D2C2E2E2E742E636C757374657250726F706572746965737D7D293B7472';
wwv_flow_imp.g_varchar2_table(37) := '797B6E2E616464536F7572636528452C74297D63617463682874297B617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B657D203A204661696C656420746F206164642047656F4A534F4E20736F75';
wwv_flow_imp.g_varchar2_table(38) := '726365602C74297D7D7D766172204A3D21313B6C657420573B6173796E632066756E6374696F6E204B28297B24282223222B652B225F6C6567656E645F656E7472795F73746174757322292E617474722822737263222C22646174613A696D6167652F67';
wwv_flow_imp.g_varchar2_table(39) := '69663B6261736536342C52306C474F446C684541415141504D50414C753775356D5A6D544D7A4D3933643352455245514141414864336431565656575A6D5A717171716F6949694F3775376B52455243496949674152414141414143482F433035465646';
wwv_flow_imp.g_varchar2_table(40) := '4E44515642464D69347741774541414141682B51514642774150414377414141414145414151414541456350444A747967366455724665744454496F704D6F53794663787844316B7244384177436B415344496C50615544514C52364731437930536771';
wwv_flow_imp.g_varchar2_table(41) := '496B45314951474D7246414B4363475753427A7750416E41776172634B5131354D70544D4A5964315A79554458534447656C42593071496F42682F5A6F594767454C436A6F78435252764951634744316B7A67534167414143514478454149666B454251';
wwv_flow_imp.g_varchar2_table(42) := '6341447741734141414141413841454141414246337779666B4D6B6F744F4A707363524B4A4A7774493451314D416F785130524642773078457668474156525A5A4A68344A674D414551573754574934457747466A4B522B43415145436A6E38446F4E30';
wwv_flow_imp.g_varchar2_table(43) := '6B7744747642543846494C414B4A67666F6F3169414741504E56593944474A584E4D49484E2F484A56714978454149666B4542516341447741734141414141424141447741414246727779666D436F6C6769796470615169593578394974683768555264';
wwv_flow_imp.g_varchar2_table(44) := '496C30774249687043416A4B494978614155505130684651734143374D4A414C465346693453674334777948797543594E5778483341756853456F746B4E4741414C415071716B696747384D57416A416E4D34413835393476505579494149666B454251';
wwv_flow_imp.g_varchar2_table(45) := '6341447741734141414141424141454141414246337779536B4476644B736464672B4150594957726367324449525141635536444A49436A49736A424545544C454542594C71595344644A6F43476948675A7747344C51434352454345494241646F4635';
wwv_flow_imp.g_varchar2_table(46) := '68644549577767424A714473374467634B7952485A6C3375557775686D3241624E4E572B4C563779642B4678454149666B4542516341434141734141414141424141446741414245595179596D4D6F56676557517250334E59684243675A426441465255';
wwv_flow_imp.g_varchar2_table(47) := '6B6442494155677556566F315A7357466345474235474D426B456A6943424C3261355A41692B6D32534155524578774B71506975436166426B76425343636D6959524143483542415548414134414C414141414141514142414141415273304D6E70414B';
wwv_flow_imp.g_varchar2_table(48) := '4459726253574D7030785A4976424B5972586A4E6D41444F68414B42695144463567476349434E41794A5477465954426144513048416B6777536D41556A304F6B4D726B5A4D344842674B4B3759544B44524943416F32636C41454968654B6339434953';
wwv_flow_imp.g_varchar2_table(49) := '6A455654754551724A41534763534251635355464555445155584A4267444257305A6A3334524143483542415548414138414C414141414141514142414141415266384D6E3578714259677256433445456D42634F536641456A536F704A4D676C6D6351';
wwv_flow_imp.g_varchar2_table(50) := '6C6742596A45354E4A675A776A4341624F345942414A6A70496A536941516835617979524149444B764A49626E4961676F465246646B5144514B433052427343495546415773543752774734313052384869694B305742774A6A4642454149666B454251';
wwv_flow_imp.g_varchar2_table(51) := '63414467417341514142414138414477414142467251796245574144584A4C554848414D4A78494441676E724F6F322B414F6962454D68314C4E363267497870687A6974526F434441594E634E4E3646424C5368616F34577A774844514B765647686F46';
wwv_flow_imp.g_varchar2_table(52) := '417747677446675148454E686F42376E43774852414943304579556343385A77316861334E495267414149666B4542516341447741734141414141424141454141414247447779666E576F6C6A614E595946562B5A783368434547456375797042744D4A';
wwv_flow_imp.g_varchar2_table(53) := '42495370436C41574C66574F44796D494669434A774D444D695A424E41415946715541614E5132453059424958475552414D436F31414173465942426F495363424A4577675356636D50306C6934467763487A2B46704343514D504346494E7845414966';
wwv_flow_imp.g_varchar2_table(54) := '6B45425163414467417341414142414241414477414142467A5179656D5758594E7161535859327656747733554E6D524F4D344A516F774B4B6C464F736752493641535138496853414446416A414D494D416753594A744279787951496863456F614263';
wwv_flow_imp.g_varchar2_table(55) := '536977656770446776417753424A30414948426F435171494145692F54434941414247684C47384D62634B425167455141682B51514642774150414377414141454145414150414141455866444A53642B71654B355242386644525257467370796F7441';
wwv_flow_imp.g_varchar2_table(56) := '4166514262664E4C4356555353644B445638396744417763464249426779774D526E6B574267634A55444B535A52494B4150516347775942794141595445454A41414A494762415445512B423445786D4B3943446842643854686448772F416D55594551';
wwv_flow_imp.g_varchar2_table(57) := '41682B51514642774150414377414141454144774150414141455876424A514961382B494C53737064486B587853397778463451334C3261544265433073466A68417475794C496A414D6859633247426761534B4775794E6F42447037637A4641676542';
wwv_flow_imp.g_varchar2_table(58) := '494B7743366B5743414D78555341466A744E43414146474746357443514C41614A6E57435471486F5245765175514A416B79474245414F773D3D22292C617065782E6576656E742E74726967676572282223222B652C226C6F61645F737461727422293B';
wwv_flow_imp.g_varchar2_table(59) := '7472797B636F6E737420653D2266756E6374696F6E223D3D747970656F6620413F6177616974204128293A413B696628226A617661736372697074223D3D3D6D29783D7B2E2E2E652C747970653A2267656F6A736F6E227D3B656C73657B636F6E737420';
wwv_flow_imp.g_varchar2_table(60) := '613D617761697420617065782E7365727665722E706C7567696E28742C7B706167654974656D733A753F752E73706C697428222C22292E66696C7465722828653D3E21216529293A766F696420307D293B783D7B2E2E2E652C747970653A2267656F6A73';
wwv_flow_imp.g_varchar2_table(61) := '6F6E222C646174613A617D7D6177616974206A28297D66696E616C6C797B617065782E6576656E742E74726967676572282223222B652C226C6F61645F656E6422292C24282223222B652B225F6C6567656E645F656E7472795F73746174757322292E61';
wwv_flow_imp.g_varchar2_table(62) := '7474722822737263222C2222297D636F6E737420613D617761697420592C733D472E636F6C6F723F3F2223303566616464223B6966284A294E2626612E73657446696C746572284E2C6B2829293B656C73657B737769746368284A3D21302C472E726563';
wwv_flow_imp.g_varchar2_table(63) := '74616E676C6553656C656374262628612E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C7C7C28612E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C3D6E657720712C612E61';
wwv_flow_imp.g_varchar2_table(64) := '6464436F6E74726F6C28612E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C29292C612E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C2E6164644C61796572286529292C69';
wwv_flow_imp.g_varchar2_table(65) := '297B636173652273796D626F6C223A573D7B747970653A2273796D626F6C222C6C61796F75743A7B7D7D2C72262628572E6C61796F75745B22746578742D6669656C64225D3D5B2263617365222C5B22686173222C22706F696E745F636F756E74225D2C';
wwv_flow_imp.g_varchar2_table(66) := '5B22636F6E636174222C5B22676574222C22706F696E745F636F756E74225D2C22206665617475726573225D2C5B22676574222C725D5D2C572E6C61796F75745B22746578742D73697A65225D3D623F3F3132292C70262628572E6C61796F75745B2269';
wwv_flow_imp.g_varchar2_table(67) := '636F6E2D696D616765225D3D70293B627265616B3B63617365226C696E65223A7B636F6E737420653D7B747970653A226C696E65222C6C61796F75743A7B7D2C7061696E743A7B226C696E652D7769647468223A5F3F3F317D7D3B68262628652E706169';
wwv_flow_imp.g_varchar2_table(68) := '6E745B226C696E652D646173686172726179225D3D682E73706C697428222022292E6D61702828653D3E7061727365466C6F61742865292929292C573D5B7B69643A2273656C656374696F6E222C747970653A226C696E65222C66696C7465723A212164';
wwv_flow_imp.g_varchar2_table(69) := '7C7C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C6C61796F75743A7B7D2C7061696E743A7B226C696E652D7769647468223A332C226C696E652D636F6C6F72223A643F5B2263617365222C5B223D3D222C';
wwv_flow_imp.g_varchar2_table(70) := '5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C732C645D3A737D7D2C655D2C722626572E70757368287B69643A226C6162656C222C747970653A2273796D626F6C222C6C61796F75743A7B22746578742D6669656C64223A';
wwv_flow_imp.g_varchar2_table(71) := '5B22676574222C725D2C22746578742D73697A65223A623F3F31322C2273796D626F6C2D706C6163656D656E74223A226C696E65227D7D293B627265616B7D636173652266696C6C223A573D5B7B747970653A2266696C6C222C6C61796F75743A7B7D2C';
wwv_flow_imp.g_varchar2_table(72) := '7061696E743A7B7D7D2C7B69643A2273656C656374696F6E222C747970653A226C696E65222C66696C7465723A5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C6C61796F75743A7B7D2C7061696E743A7B22';
wwv_flow_imp.g_varchar2_table(73) := '6C696E652D7769647468223A332C226C696E652D636F6C6F72223A737D7D5D3B627265616B3B64656661756C743A573D6F7D6E756C6C3D3D3D57262628573D7B7D292C2266756E6374696F6E223D3D747970656F662057262628573D572829292C417272';
wwv_flow_imp.g_varchar2_table(74) := '61792E697341727261792857297C7C28573D5B575D293B636F6E737420743D572E6D6170282828742C61293D3E7B636F6E737420693D7B2E2E2E742C69643A742E69643F652B222D222B742E69643A652B222D222B612C736F757263653A452C6C61796F';
wwv_flow_imp.g_varchar2_table(75) := '75743A7B2E2E2E742E6C61796F75747D2C7061696E743A7B2E2E2E742E7061696E747D2C6D657461646174613A7B6C617965725F73657175656E63653A6E2C6974656D5F69643A652C2E2E2E742E6D657461646174617D7D3B72657475726E2273796D62';
wwv_flow_imp.g_varchar2_table(76) := '6F6C223D3D3D692E747970653F28692E6C61796F75745B22746578742D6669656C64225D262628692E7061696E745B22746578742D636F6C6F72225D3F3F3D6C2C692E7061696E745B22746578742D6F706163697479225D3F3F3D632C692E6C61796F75';
wwv_flow_imp.g_varchar2_table(77) := '745B22746578742D666F6E74225D3F3F3D5B224D6574726F706F6C697320526567756C6172222C224E6F746F2053616E7320526567756C6172225D2C692E6C61796F75745B22746578742D73697A65225D3F3F3D31322C692E7061696E745B2274657874';
wwv_flow_imp.g_varchar2_table(78) := '2D68616C6F2D7769647468225D3F3F3D312E352C692E7061696E745B22746578742D68616C6F2D636F6C6F72225D3F3F3D5B2263617365222C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C732C643F3F22';
wwv_flow_imp.g_varchar2_table(79) := '23636363225D2C692E6C61796F75745B22746578742D6A757374696679225D3F3F3D226175746F222C692E6C61796F75745B2269636F6E2D696D616765225D262628692E6C61796F75745B22746578742D6F6666736574225D3F3F3D5B302C2E355D2C69';
wwv_flow_imp.g_varchar2_table(80) := '2E6C61796F75745B22746578742D616E63686F72225D7C7C692E6C61796F75745B22746578742D7661726961626C652D616E63686F72225D7C7C28692E6C61796F75745B22746578742D7661726961626C652D616E63686F72225D3D5B22746F70222C22';
wwv_flow_imp.g_varchar2_table(81) := '6C656674222C22746F702D6C656674225D2929292C692E6C61796F75745B2269636F6E2D696D616765225D3F28692E6C61796F75745B2269636F6E2D616C6C6F772D6F7665726C6170225D3F3F3D21302C692E6C61796F75745B22746578742D6F707469';
wwv_flow_imp.g_varchar2_table(82) := '6F6E616C225D3F3F3D21302C692E7061696E745B2269636F6E2D636F6C6F72225D3F3F3D6C2C692E7061696E745B2269636F6E2D6F706163697479225D3F3F3D632C692E7061696E745B2269636F6E2D68616C6F2D7769647468225D3F3F3D5B22636173';
wwv_flow_imp.g_varchar2_table(83) := '65222C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C322C643F313A305D2C692E7061696E745B2269636F6E2D68616C6F2D636F6C6F72225D3F3F3D5B2263617365222C5B223D3D222C5B22676574222C22';
wwv_flow_imp.g_varchar2_table(84) := '6D6170626974732D73656C6563746564225D2C21305D2C732C643F3F227472616E73706172656E74225D293A692E6C61796F75745B22746578742D616C6C6F772D6F7665726C6170225D3F3F3D2130293A226C696E65223D3D3D692E747970653F28692E';
wwv_flow_imp.g_varchar2_table(85) := '7061696E745B226C696E652D636F6C6F72225D3F3F3D6C2C692E7061696E745B226C696E652D6F706163697479225D3F3F3D63293A2266696C6C223D3D3D692E74797065262628692E7061696E745B2266696C6C2D636F6C6F72225D3F3F3D6C2C692E70';
wwv_flow_imp.g_varchar2_table(86) := '61696E745B2266696C6C2D6F706163697479225D3F3F3D632C692E7061696E745B2266696C6C2D6F75746C696E652D636F6C6F72225D3F3F3D647C7C22626C61636B22292C697D29293B73776974636828502829297B63617365226C696E65223A4E3D65';
wwv_flow_imp.g_varchar2_table(87) := '2B222D2D73656C656374696F6E2D6C696E65222C742E70757368287B69643A4E2C747970653A226C696E65222C736F757263653A452C66696C7465723A6B28292C6C61796F75743A7B226C696E652D636170223A475B226C696E652D636170225D3F3F22';
wwv_flow_imp.g_varchar2_table(88) := '726F756E64227D2C7061696E743A7B226C696E652D6761702D7769647468223A475B226C696E652D6761702D7769647468225D3F3F332C226C696E652D7769647468223A475B226C696E652D7769647468225D3F3F322C226C696E652D636F6C6F72223A';
wwv_flow_imp.g_varchar2_table(89) := '475B226C696E652D636F6C6F72225D3F3F737D2C6D657461646174613A7B6C617965725F73657175656E63653A6E7D7D293B627265616B3B6361736522636972636C65223A4E3D652B222D2D73656C656374696F6E2D636972636C65222C742E70757368';
wwv_flow_imp.g_varchar2_table(90) := '287B69643A4E2C747970653A22636972636C65222C736F757263653A452C66696C7465723A6B28292C7061696E743A7B22636972636C652D726164697573223A475B22636972636C652D726164697573225D3F3F352C22636972636C652D636F6C6F7222';
wwv_flow_imp.g_varchar2_table(91) := '3A475B22636972636C652D636F6C6F72225D3F3F227472616E73706172656E74222C22636972636C652D7374726F6B652D636F6C6F72223A475B22636972636C652D7374726F6B652D636F6C6F72225D3F3F732C22636972636C652D7374726F6B652D77';
wwv_flow_imp.g_varchar2_table(92) := '69647468223A475B22636972636C652D7374726F6B652D7769647468225D3F3F327D2C6D657461646174613A7B6C617965725F73657175656E63653A6E7D7D297D636F6E737420413D612E6765745374796C6528292E6C61796572732E66696C74657228';
wwv_flow_imp.g_varchar2_table(93) := '28653D3E226D6574616461746122696E20652626226C617965725F73657175656E636522696E20652E6D6574616461746129292E6D6170282866756E6374696F6E2865297B72657475726E5B652E6D657461646174612E6C617965725F73657175656E63';
wwv_flow_imp.g_varchar2_table(94) := '652C652E69645D7D29293B76617220793B69662830213D3D412E6C656E677468297B412E736F7274282828652C74293D3E655B305D2D745B305D29293B666F722876617220673D303B673C412E6C656E6774683B672B2B296966286E3C415B675D5B305D';
wwv_flow_imp.g_varchar2_table(95) := '297B793D415B675D5B315D3B627265616B7D7D6C657420753D6E756C6C3B666F7228636F6E73742069206F662074297472797B696628612E6164644C6179657228692C79292C542829297B612E5F5F6D6170626974735F6C617965725F637572736F7273';
wwv_flow_imp.g_varchar2_table(96) := '2E73657428692E69642C22706F696E74657222293B636F6E737420743D653D3E7B666F7228636F6E73742074206F6620612E717565727952656E6465726564466561747572657328652E706F696E742929696628612E5F5F6D6170626974735F6C617965';
wwv_flow_imp.g_varchar2_table(97) := '725F637572736F72732E68617328742E6C617965723F2E6964292972657475726E20766F696428612E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F723D612E5F5F6D6170626974735F6C617965725F637572736F7273';
wwv_flow_imp.g_varchar2_table(98) := '2E67657428742E6C617965722E696429293B612E67657443616E766173436F6E7461696E657228292E7374796C652E72656D6F766550726F70657274792822637572736F7222297D3B696628612E6F6E28226D6F757365656E746572222C692E69642C74';
wwv_flow_imp.g_varchar2_table(99) := '292C612E6F6E28226D6F7573656C65617665222C692E69642C74292C472E656E61626C65436C69636B2626472E6F726465724279297B6C657420653D21313B612E6F6E28226D6F757365646F776E222C692E69642C28743D3E7B696628742E6F72696769';
wwv_flow_imp.g_varchar2_table(100) := '6E616C4576656E742E73686966744B6579297B612E717565727952656E6465726564466561747572657328742E706F696E74295B305D2E6C617965722E69643D3D3D742E66656174757265735B305D2E6C617965722E6964262628653D612E626F785A6F';
wwv_flow_imp.g_varchar2_table(101) := '6F6D2E6973456E61626C656428292C612E626F785A6F6F6D2E64697361626C652829297D7D29292C612E6F6E28226D6F7573657570222C692E69642C2828293D3E7B652626612E626F785A6F6F6D2E656E61626C6528297D29297D612E6F6E2822636C69';
wwv_flow_imp.g_varchar2_table(102) := '636B222C692E69642C28743D3E7B636F6E737420693D612E717565727952656E6465726564466561747572657328742E706F696E74295B305D2E6C617965722E69643D3D3D742E66656174757265735B305D2E6C617965722E69642C723D512E67657428';
wwv_flow_imp.g_varchar2_table(103) := '742E66656174757265735B305D2E6964293B696628617065782E6576656E742E74726967676572282223222B652C22636C69636B222C7B666561747572653A7B747970653A2246656174757265222C69643A722C70726F706572746965733A742E666561';
wwv_flow_imp.g_varchar2_table(104) := '74757265735B305D2E70726F706572746965732C67656F6D657472793A742E66656174757265735B305D2E67656F6D657472797D2C6973546F706D6F73744C617965723A692C706F696E743A742E706F696E747D292C472E656E61626C65436C69636B26';
wwv_flow_imp.g_varchar2_table(105) := '2669297B696628742E6F726967696E616C4576656E742E6374726C4B6579262621472E636C69636B53696E676C6553656C6563742955285B725D2C22746F67676C6522293B656C736520696628742E6F726967696E616C4576656E742E73686966744B65';
wwv_flow_imp.g_varchar2_table(106) := '792626472E6F726465724279262621472E636C69636B53696E676C6553656C656374262675297B636F6E737420653D742E66656174757265735B305D2E70726F706572746965735B472E6F7264657242795D2C613D742E66656174757265735B305D2E70';
wwv_flow_imp.g_varchar2_table(107) := '726F706572746965735B472E706172746974696F6E42795D2C693D5B5D3B696628472E706172746974696F6E4279262661213D3D752E70726F706572746965735B472E706172746974696F6E42795D29692E707573682872293B656C736520666F722863';
wwv_flow_imp.g_varchar2_table(108) := '6F6E73742074206F6620432969662821472E706172746974696F6E42797C7C613D3D3D742E70726F706572746965735B472E706172746974696F6E42795D297B636F6E737420613D742E70726F706572746965735B472E6F7264657242795D2C723D752E';
wwv_flow_imp.g_varchar2_table(109) := '70726F706572746965735B472E6F7264657242795D3B28653E722626653E3D612626613E3D727C7C653C3D722626653C3D612626613C3D72292626692E7075736828742E6964297D5528692C2261646422297D656C73652055285B725D2C227365742229';
wwv_flow_imp.g_varchar2_table(110) := '3B753D742E66656174757265735B305D7D7D29297D7D63617463682874297B617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B657D203A204661696C656420746F20616464206C6179657220247B';
wwv_flow_imp.g_varchar2_table(111) := '692E69647D602C74297D443D742E6D61702828653D3E652E696429292C763D693D3E7B666F7228636F6E73742065206F66207429612E7365744C61796F757450726F706572747928652E69642C227669736962696C697479222C69293B492E7365744974';
wwv_flow_imp.g_varchar2_table(112) := '656D28224D6170626974735F4C6F6465737461724C617965725F222B652B225F7669736962696C697479222C69292C423D692C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B656422';
wwv_flow_imp.g_varchar2_table(113) := '2C2276697369626C65223D3D3D69292C617065782E6576656E742E74726967676572282223222B652C227669736962696C6974795F746F67676C6564222C7B76697369626C653A2276697369626C65223D3D3D697D297D2C226E6F6E65223D3D423F2876';
wwv_flow_imp.g_varchar2_table(114) := '28226E6F6E6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213129293A2876282276697369626C6522292C617065782E6A5175657279282223222B652B225F6C65';
wwv_flow_imp.g_varchar2_table(115) := '67656E645F656E74727922292E70726F702822636865636B6564222C213029292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E6368616E6765282866756E6374696F6E2865297B76617220743D617065782E6A';
wwv_flow_imp.g_varchar2_table(116) := '51756572792874686973293B7628742E697328223A636865636B656422293F2276697369626C65223A226E6F6E6522297D29293B666F7228636F6E73742065206F662077296528293B773D6E756C6C7D7D636F6E737420553D28742C61293D3E7B737769';
wwv_flow_imp.g_varchar2_table(117) := '74636828743D743F3F5B5D2C6F6C6453656C656374696F6E3D532C61297B6361736522736574223A533D6E6577205365742874293B627265616B3B6361736522616464223A6966285329666F7228636F6E73742065206F66207429532E6164642865293B';
wwv_flow_imp.g_varchar2_table(118) := '627265616B3B636173652272656D6F7665223A6966285329666F7228636F6E73742065206F66207429532E64656C6574652865293B627265616B3B6361736522746F67676C65223A6966285329666F7228636F6E73742065206F66207429532E68617328';
wwv_flow_imp.g_varchar2_table(119) := '65293F532E64656C6574652865293A532E6164642865297D2270726F7065727479223D3D3D5028293F6A28293A4E2626592E7468656E2828653D3E7B652E73657446696C746572284E2C6B2829297D29292C617065782E6576656E742E74726967676572';
wwv_flow_imp.g_varchar2_table(120) := '282223222B652C2273656C656374696F6E5F6368616E67656422297D3B636C61737320717B636F6E7374727563746F7228297B746869732E6C61796572733D5B5D2C746869732E6163746976653D21317D6164644C617965722865297B746869732E6C61';
wwv_flow_imp.g_varchar2_table(121) := '796572732E707573682865297D6F6E4164642865297B6C657420743D6E756C6C2C613D6E756C6C2C693D21313B636F6E737420723D743D3E7B746869732E6163746976653D742C6F2E70726F702822617269612D70726573736564222C746869732E6163';
wwv_flow_imp.g_varchar2_table(122) := '74697665292C6F2E746F67676C65436C61737328226D6170626974732D726563742D73656C6563742D627574746F6E2D746F67676C6564222C746869732E616374697665292C652E676574436F6E7461696E657228292E636C6173734C6973742E746F67';
wwv_flow_imp.g_varchar2_table(123) := '676C6528226D6170626974732D726563742D73656C6563742D616374697665222C746869732E616374697665292C692626652E6472616750616E2E656E61626C6528297D2C6F3D2428273C627574746F6E20747970653D22627574746F6E22207374796C';
wwv_flow_imp.g_varchar2_table(124) := '653D226C696E652D6865696768743A313670783B77696474683A333270783B6865696768743A333270783B223E3C6920636C6173733D2266612066612D6F626A6563742D67726F7570223E3C2F693E3C2F627574746F6E3E27292E70726F702822746974';
wwv_flow_imp.g_varchar2_table(125) := '6C65222C2252656374616E676C652053656C65637422292E70726F702822617269612D70726573736564222C746869732E616374697665292E6F6E2822636C69636B222C2828293D3E7B722821746869732E616374697665297D29292C6E3D723D3E7B74';
wwv_flow_imp.g_varchar2_table(126) := '6869732E61637469766526266E756C6C3D3D3D74262628613D722E706F696E742C743D2428273C64697620636C6173733D226D6170626974732D726563742D73656C6563742D626F78223E27292C652E676574436F6E7461696E657228292E617070656E';
wwv_flow_imp.g_varchar2_table(127) := '644368696C6428745B305D292C693D652E6472616750616E2E6973456E61626C656428292C692626652E6472616750616E2E64697361626C652829297D2C733D653D3E7B6966286E756C6C3D3D3D742972657475726E3B69662821746869732E61637469';
wwv_flow_imp.g_varchar2_table(128) := '76652972657475726E3B652E6F726967696E616C4576656E742E73746F7050726F7061676174696F6E28293B636F6E737420693D4D6174682E6D696E28652E706F696E742E782C612E78292C723D4D6174682E6D617828652E706F696E742E782C612E78';
wwv_flow_imp.g_varchar2_table(129) := '292C6F3D4D6174682E6D696E28652E706F696E742E792C612E79292C6E3D4D6174682E6D617828652E706F696E742E792C612E79293B742E63737328227472616E73666F726D222C607472616E736C61746528247B697D70782C20247B6F7D7078296029';
wwv_flow_imp.g_varchar2_table(130) := '2C742E776964746828722D69292C742E686569676874286E2D6F297D2C6C3D693D3E7B69662821746869732E6163746976652972657475726E3B6E756C6C213D3D74262628745B305D2E706172656E744E6F64652E72656D6F76654368696C6428745B30';
wwv_flow_imp.g_varchar2_table(131) := '5D292C743D6E756C6C293B636F6E7374206F3D652E717565727952656E64657265644665617475726573285B692E706F696E742C615D292C6E3D6E6577205365743B666F7228636F6E73742065206F66206F29442E696E636C7564657328652E6C617965';
wwv_flow_imp.g_varchar2_table(132) := '722E69642926266E2E61646428652E6964293B552841727261792E66726F6D286E292E6D61702828653D3E512E67657428652929292C692E6F726967696E616C4576656E742E73686966744B65793F22616464223A2273657422292C72282131297D3B72';
wwv_flow_imp.g_varchar2_table(133) := '657475726E20652E6F6E28226D6F757365646F776E222C6E292C652E6F6E28226D6F7573656D6F7665222C73292C652E6F6E28226D6F7573657570222C6C292C746869732E5F636C65616E75703D28293D3E7B652E6F666628226D6F757365646F776E22';
wwv_flow_imp.g_varchar2_table(134) := '2C6E292C652E6F666628226D6F7573656D6F7665222C73292C652E6F666628226D6F7573657570222C6C292C6E756C6C213D3D742626745B305D2E706172656E744E6F64652E72656D6F76654368696C6428745B305D297D2C746869732E636F6E746169';
wwv_flow_imp.g_varchar2_table(135) := '6E65723D2428273C64697620636C6173733D226D61706C69627265676C2D6374726C206D61706C69627265676C2D6374726C2D67726F7570223E27292E617070656E64286F292E6765742830292C746869732E636F6E7461696E65727D6F6E52656D6F76';
wwv_flow_imp.g_varchar2_table(136) := '6528297B746869732E5F636C65616E757028292C746869732E636F6E7461696E65722E706172656E744E6F64652E72656D6F76654368696C6428746869732E636F6E7461696E6572297D7D617065782E6974656D2E63726561746528652C7B7265667265';
wwv_flow_imp.g_varchar2_table(137) := '73683A6173796E6328293D3E7B6177616974204B28297D2C73686F773A28293D3E7B76282276697369626C6522297D2C686964653A28293D3E7B7628226E6F6E6522297D2C697356697369626C653A28293D3E226E6F6E6522213D3D422C686173494443';
wwv_flow_imp.g_varchar2_table(138) := '6F6C756D6E3A28293D3E2121792C69734368616E6765643A28293D3E462E73697A653E302C67657453656C656374656446656174757265733A28293D3E533F41727261792E66726F6D2853293A5B5D2C73657453656C656374656446656174757265733A';
wwv_flow_imp.g_varchar2_table(139) := '552C73656C656374416C6C46656174757265733A28293D3E7B7826265528782E646174612E66656174757265732E6D61702828653D3E652E696429292C2273657422297D2C636C65617253656C656374696F6E3A28293D3E7B55285B5D2C227365742229';
wwv_flow_imp.g_varchar2_table(140) := '7D2C73657453656C656374696F6E5374796C653A28652C74293D3E7B6966284C29636F6E736F6C652E6572726F72282243616E6E6F7420736574207468652073656C656374696F6E207374796C6520616674657220746865206D61702068617320626565';
wwv_flow_imp.g_varchar2_table(141) := '6E20696E697469616C697A656422293B656C73657B4C3D652C473D743F3F7B7D3B666F7228636F6E73742065206F6620443F3F5B5D295428293F6D61702E5F5F6D6170626974735F6C617965725F637572736F72732E73657428652C22706F696E746572';
wwv_flow_imp.g_varchar2_table(142) := '22293A6D61702E5F5F6D6170626974735F6C617965725F637572736F72732E64656C6574652865297D7D2C7A6F6F6D546F466561747572653A6173796E6328652C74293D3E7B636F6E737420613D4D2E6765742865293B6126262861776169742059292E';
wwv_flow_imp.g_varchar2_table(143) := '666974426F756E64732828653D3E7B6C657420743D5B5D3B73776974636828652E74797065297B63617365224D756C7469506F6C79676F6E223A743D652E636F6F7264696E617465732E666C61744D61702828653D3E652E666C61744D61702828653D3E';
wwv_flow_imp.g_varchar2_table(144) := '65292929293B627265616B3B6361736522506F6C79676F6E223A63617365224D756C74694C696E65537472696E67223A743D652E636F6F7264696E617465732E666C61744D61702828653D3E6529293B627265616B3B63617365224C696E65537472696E';
wwv_flow_imp.g_varchar2_table(145) := '67223A63617365224D756C7469506F696E74223A743D652E636F6F7264696E617465733B627265616B3B6361736522506F696E74223A743D5B652E636F6F7264696E617465735D7D6C657420613D4D6174682E6D696E282E2E2E742E6D61702828653D3E';
wwv_flow_imp.g_varchar2_table(146) := '655B315D2929292C693D4D6174682E6D696E282E2E2E742E6D61702828653D3E655B305D2929292C723D4D6174682E6D6178282E2E2E742E6D61702828653D3E655B315D2929293B72657475726E5B5B692C615D2C5B4D6174682E6D6178282E2E2E742E';
wwv_flow_imp.g_varchar2_table(147) := '6D61702828653D3E655B305D2929292C725D5D7D2928612E67656F6D65747279292C74297D2C676574536F75726365446174613A28293D3E783F2E646174612C676574536F757263654E616D653A28293D3E452C77616974466F724C6F61643A28293D3E';
wwv_flow_imp.g_varchar2_table(148) := '6E65772050726F6D697365282828652C74293D3E7B6E756C6C3D3D3D773F6528293A772E707573682865297D29292C6765744C617965724944733A28293D3E442C6765744D61703A6173796E6328293D3E617761697420592C6564697446656174757265';
wwv_flow_imp.g_varchar2_table(149) := '3A6173796E6328652C74293D3E7B2263726561746522213D3D657C7C742E69647C7C28742E69643D63727970746F2E72616E646F6D555549442829293B636F6E737420613D462E67657428742E6964293B69662861262622637265617465223D3D3D612E';
wwv_flow_imp.g_varchar2_table(150) := '616374696F6E2969662822637265617465223D3D3D612E616374696F6E262622757064617465223D3D3D6529653D22637265617465223B656C73652069662822637265617465223D3D3D612E616374696F6E26262264656C657465223D3D3D6529726574';
wwv_flow_imp.g_varchar2_table(151) := '75726E20462E64656C65746528742E6964292C766F6964206177616974206A28293B462E73657428742E69642C7B616374696F6E3A652C666561747572653A747D292C6177616974206A28297D2C67657445646974733A28293D3E41727261792E66726F';
wwv_flow_imp.g_varchar2_table(152) := '6D28462E76616C7565732829292C676574456469746564446174613A28293D3E287B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A437D292C636F6E7665727449443A653D3E512E6765742865292C676574466561';
wwv_flow_imp.g_varchar2_table(153) := '747572653A653D3E4D2E6765742865292C6765744665617475726545646974416374696F6E3A653D3E462E6765742865293F2E616374696F6E3F3F284D2E6765742865293F226E6F6E65223A6E756C6C292C636C65617245646974733A6173796E632829';
wwv_flow_imp.g_varchar2_table(154) := '3D3E7B462E636C65617228292C6177616974206A28297D2C636C6561724564697473416E64526566726573683A6173796E6328293D3E7B462E636C65617228292C6177616974204B28297D7D292C4B28293B6C657420483D21303B696628617065782E6A';
wwv_flow_imp.g_varchar2_table(155) := '51756572792822626F647922292E6F6E2822617065786265666F726572656672657368222C286173796E6320653D3E7B652E7461726765743D3D3D617065782E726567696F6E2861292E656C656D656E745B305D262628483F483D21313A617761697420';
wwv_flow_imp.g_varchar2_table(156) := '4B2829297D29292C2266756E6374696F6E223D3D747970656F66206626266628617065782E6974656D286529292C6520696E204D4150424954535F4C4F4445535441525F4C415945525F57414954494E47297B636F6E737420743D617065782E6974656D';
wwv_flow_imp.g_varchar2_table(157) := '2865293B4D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D2E666F72456163682828653D3E6528742929297D4D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D3D6E756C6C7D636F6E73';
wwv_flow_imp.g_varchar2_table(158) := '74206D6170626974735F6C6F6465737461725F74696E797364663D6E6577206D6170626974735F74696E79736466287B666F6E7453697A653A31362C666F6E7446616D696C793A22466F6E74204150455820536D616C6C227D293B66756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(159) := '6D6170626974735F6C6F6465737461725F696D6167655F68616E646C65722865297B636F6E737420743D286D61706C69627265676C2E67657456657273696F6E3F2E28293F3F6D61706C69627265676C2E76657273696F6E292E73706C697428222E2229';
wwv_flow_imp.g_varchar2_table(160) := '2E6D61702828653D3E7061727365496E7428652929293B72657475726E206E65772050726F6D697365282828612C69293D3E7B636F6E737420723D652E7461726765743B696628722E686173496D61676528652E696429296128293B656C736520696628';
wwv_flow_imp.g_varchar2_table(161) := '652E69642E73746172747357697468282266612D2229297B636F6E737420743D646F63756D656E742E637265617465456C656D656E7428227370616E22293B742E7374796C652E646973706C61793D226E6F6E65222C742E636C6173734C6973742E6164';
wwv_flow_imp.g_varchar2_table(162) := '642822666122292C742E636C6173734C6973742E61646428652E6964292C722E676574436F6E7461696E657228292E617070656E644368696C642874293B636F6E737420693D77696E646F772E676574436F6D70757465645374796C6528742C223A6265';
wwv_flow_imp.g_varchar2_table(163) := '666F726522292E636F6E74656E742E737562737472696E6728312C32293B742E72656D6F766528293B636F6E7374206F3D6D6170626974735F6C6F6465737461725F74696E797364662E647261772869292C6E3D6E65772055696E74384172726179286F';
wwv_flow_imp.g_varchar2_table(164) := '2E77696474682A6F2E6865696768742A34293B666F72286C657420653D303B653C6F2E646174612E6C656E6774683B652B2B296E5B342A652B335D3D6F2E646174615B655D3B722E616464496D61676528652E69642C7B646174613A6E2C77696474683A';
wwv_flow_imp.g_varchar2_table(165) := '6F2E77696474682C6865696768743A6F2E6865696768747D2C7B7364663A21307D292C6128297D656C736520652E69642E7374617274735769746828617065782E656E762E4150505F46494C455329262628743E3D5B345D3F722E6C6F6164496D616765';
wwv_flow_imp.g_varchar2_table(166) := '28652E6964292E7468656E2828743D3E7B722E686173496D61676528652E6964297C7C722E616464496D61676528652E69642C742E64617461292C6128297D29293A722E6C6F6164496D61676528652E69642C2828742C69293D3E7B722E686173496D61';
wwv_flow_imp.g_varchar2_table(167) := '676528652E6964297C7C722E616464496D61676528652E69642C69292C6128297D2929297D29297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(283590117217419341)
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
wwv_flow_imp.g_varchar2_table(10) := '2C20636C69636B61626C652C207375626D69744974656D732C20736F75726365547970652C20696E69744A732C206C696E6557696474682C206C696E654461736841727261792C20666F6E7453697A652C0D0A7D29207B0D0A2020696620282172656769';
wwv_flow_imp.g_varchar2_table(11) := '6F6E496429207B0D0A20202020617065782E64656275672E6572726F7228276D6170626974735F6C6F6465737461726C617965722027202B206974656D4964202B2027203A204974656D206973206E6F7420696E206120726567696F6E2E27293B0D0A20';
wwv_flow_imp.g_varchar2_table(12) := '20202072657475726E3B0D0A20207D0D0A0D0A2020636F6E73742073746F72616765203D20617065782E73746F726167652E67657453636F7065644C6F63616C53746F72616765287B2075736541707049643A20747275652C207573655061676549643A';
wwv_flow_imp.g_varchar2_table(13) := '20747275652C20726567696F6E4964207D293B0D0A0D0A20206C65742077616974466F724C6F6164203D205B5D3B0D0A0D0A2020636F6E737420736F757263654E616D65203D206974656D4964202B20272D736F75726365273B0D0A0D0A20206C657420';
wwv_flow_imp.g_varchar2_table(14) := '6C61796572735669736962696C697479203D2073746F726167652E6765744974656D28274D6170626974735F4C6F6465737461724C617965725F27202B206974656D4964202B20275F7669736962696C69747927293B0D0A0D0A2020766172207265736F';
wwv_flow_imp.g_varchar2_table(15) := '6C766564536F757263654F7074696F6E733B0D0A20207661722073656C65637465644665617475726573203D206E756C6C3B0D0A0D0A20206C6574207365744C61796572735669736962696C697479203D20287669736962696C69747929203D3E207B0D';
wwv_flow_imp.g_varchar2_table(16) := '0A202020206C61796572735669736962696C697479203D207669736962696C6974793B0D0A20207D3B0D0A0D0A20206C6574206C61796572494473203D206E756C6C3B0D0A0D0A20206C6574206665617475726573203D205B5D3B0D0A2020636F6E7374';
wwv_flow_imp.g_varchar2_table(17) := '2066656174757265734D6170203D206E6577204D617028293B0D0A2020636F6E7374206564697473203D206E6577204D617028293B0D0A20202F2A204D6170206F66207468652077686F6C65206E756D62657220494473207765207061737320746F204D';
wwv_flow_imp.g_varchar2_table(18) := '61706C696272652C20746F20746865206F726967696E616C20736F75726365204944732E202A2F0D0A2020636F6E73742069644D6170203D206E6577204D617028293B0D0A2020636F6E73742069644D6170526576203D206E6577204D617028293B0D0A';
wwv_flow_imp.g_varchar2_table(19) := '0D0A2020636F6E73742067657453656C6563746564466561747572657346696C746572203D202829203D3E2073656C65637465644665617475726573203F205B27696E272C205B276964275D2C205B276C69746572616C272C2041727261792E66726F6D';
wwv_flow_imp.g_varchar2_table(20) := '2873656C65637465644665617475726573292E6D61702878203D3E2069644D61705265762E676574287829292E66696C7465722878203D3E20747970656F66207820213D3D2027756E646566696E656427295D5D203A2066616C73653B0D0A0D0A20206C';
wwv_flow_imp.g_varchar2_table(21) := '65742073656C656374696F6E5374796C65203D206E756C6C3B0D0A2020636F6E73742067657453656C656374696F6E5374796C65203D202829203D3E207B0D0A20202020696620282173656C656374696F6E5374796C6529207B0D0A2020202020207365';
wwv_flow_imp.g_varchar2_table(22) := '6C656374696F6E5374796C65203D202770726F7065727479273B0D0A202020207D0D0A2020202072657475726E2073656C656374696F6E5374796C653B0D0A20207D3B0D0A20206C65742073656C656374696F6E5374796C654F707473203D207B7D3B0D';
wwv_flow_imp.g_varchar2_table(23) := '0A20206C65742073656C656374696F6E4C617965724964203D206E756C6C3B0D0A0D0A2020636F6E7374206973436C69636B61626C65203D202829203D3E20636C69636B61626C65207C7C2073656C656374696F6E5374796C654F7074732E656E61626C';
wwv_flow_imp.g_varchar2_table(24) := '65436C69636B3B0D0A0D0A2020636F6E73742070656E64696E674D6170203D206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020636F6E737420726567696F6E203D20617065782E726567696F6E287265';
wwv_flow_imp.g_varchar2_table(25) := '67696F6E4964293B0D0A2020202069662028726567696F6E203D3D206E756C6C29207B0D0A202020202020617065782E64656275672E6572726F7228276D6170626974735F6C6F6465737461726C617965722027202B206974656D4964202B2027203A20';
wwv_flow_imp.g_varchar2_table(26) := '526567696F6E205B27202B20726567696F6E4964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A20202020202072656A65637428293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20202020726567';
wwv_flow_imp.g_varchar2_table(27) := '696F6E2E656C656D656E742E6F6E28277370617469616C6D6170696E697469616C697A6564272C202829203D3E207B0D0A202020202020636F6E7374206D6170203D20617065782E726567696F6E28726567696F6E4964292E63616C6C28276765744D61';
wwv_flow_imp.g_varchar2_table(28) := '704F626A65637427293B0D0A2020202020207265736F6C7665286D6170293B0D0A202020207D293B0D0A20207D292E7468656E28286D617029203D3E207B0D0A202020206D61702E5F5F6D6170626974735F6C617965725F637572736F7273203F3F3D20';
wwv_flow_imp.g_varchar2_table(29) := '6E6577204D617028293B0D0A0D0A2020202069662028216D61705B494D4147455F48414E444C45525F41444445445D20262620216D61702E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F616464656429207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(30) := '206D61702E6F6E28277374796C65696D6167656D697373696E67272C2028657629203D3E207B0D0A20202020202020206D6170626974735F6C6F6465737461725F696D6167655F68616E646C6572286576293B0D0A2020202020207D293B0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(31) := '202020202F2A204C697374656E20666F72206572726F727320696E20746865206D617020287768696368206D6179206265206173796E6368726F6E6F75732C20736F206E6F742061207468726F776E2F63617567687420657863657074696F6E292E0D0A';
wwv_flow_imp.g_varchar2_table(32) := '2020202020202020204F6E6C7920646F2074686973206F6E636520706572206D61702C206576656E206966206D756C7469706C65204D61706269747320706C7567696E732061726520757365642E202A2F0D0A20202020202069662028216D61702E5F5F';
wwv_flow_imp.g_varchar2_table(33) := '6D6170626974735F6572726F725F68616E646C65725F616464656429207B0D0A20202020202020206D61702E6F6E28276572726F72272C2028657629203D3E207B0D0A20202020202020202020617065782E64656275672E6572726F7228604D61702065';
wwv_flow_imp.g_varchar2_table(34) := '72726F7220696E20726567696F6E20247B726567696F6E49647D3A20602C2065762E6572726F72293B0D0A20202020202020207D293B0D0A20202020202020206D61702E5F5F6D6170626974735F6572726F725F68616E646C65725F6164646564203D20';
wwv_flow_imp.g_varchar2_table(35) := '747275653B0D0A2020202020207D0D0A0D0A2020202020206D61705B494D4147455F48414E444C45525F41444445445D203D20747275653B0D0A2020202020206D61702E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F616464';
wwv_flow_imp.g_varchar2_table(36) := '6564203D20747275653B0D0A202020207D0D0A0D0A202020202F2F205761697420666F7220746865206C6567656E6420746F206C6F61640D0A2020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E';
wwv_flow_imp.g_varchar2_table(37) := '207B0D0A20202020202076617220696E74657276616C203D20736574496E74657276616C2866756E6374696F6E2829207B0D0A2020202020202020636F6E7374206C6567656E64203D20617065782E6A517565727928272327202B20726567696F6E4964';
wwv_flow_imp.g_varchar2_table(38) := '202B20275F6C6567656E6427293B0D0A202020202020202069662028216C6567656E6429207B0D0A2020202020202020202072657475726E3B0D0A20202020202020207D0D0A0D0A2020202020202020636C656172496E74657276616C28696E74657276';
wwv_flow_imp.g_varchar2_table(39) := '616C293B0D0A0D0A2020202020202020617065782E6A517565727928273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E2720';
wwv_flow_imp.g_varchar2_table(40) := '2B200D0A20202020202020202020273C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069643D2227';
wwv_flow_imp.g_varchar2_table(41) := '202B206974656D4964202B20275F6C6567656E645F656E74727927202B202722207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B20636F6C6F72202B2027223E27202B0D0A2020202020202020202027';
wwv_flow_imp.g_varchar2_table(42) := '3C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C222069643D2227202B206974656D4964202B20275F6C6567656E645F656E7472795F6C6162656C27202B20272220666F723D2227202B206974656D4964202B';
wwv_flow_imp.g_varchar2_table(43) := '20275F6C6567656E645F656E74727927202B2027223E27202B20287469746C65207C7C206974656D496429202B20273C696D672069643D2227202B206974656D4964202B20275F6C6567656E645F656E7472795F737461747573222F3E3C2F6C6162656C';
wwv_flow_imp.g_varchar2_table(44) := '3E27202B0D0A20202020202020202020273C2F6469763E27292E617070656E64546F286C6567656E64293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F';
wwv_flow_imp.g_varchar2_table(45) := '702827636865636B6564272C206C61796572735669736962696C69747920213D3D20276E6F6E6527293B0D0A0D0A20202020202020207265736F6C7665286D6170293B0D0A2020202020207D2C20353030293B0D0A202020207D290D0A20207D293B0D0A';
wwv_flow_imp.g_varchar2_table(46) := '0D0A20206173796E632066756E6374696F6E2072656C6F6164536F75726365446174612829207B0D0A2020202069662028217265736F6C766564536F757263654F7074696F6E7329207B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A';
wwv_flow_imp.g_varchar2_table(47) := '20202020636F6E737420736F757263654665617475726573203D207265736F6C766564536F757263654F7074696F6E733F2E646174612E66656174757265730D0A2020202020202E6D61702866656174203D3E207B0D0A2020202020202020636F6E7374';
wwv_flow_imp.g_varchar2_table(48) := '2065646974203D2065646974732E67657428666561742E6964293B0D0A0D0A202020202020202069662028656469743F2E616374696F6E203D3D3D202764656C6574652729207B0D0A2020202020202020202072657475726E206E756C6C3B0D0A202020';
wwv_flow_imp.g_varchar2_table(49) := '20202020207D0D0A0D0A202020202020202072657475726E207B0D0A20202020202020202020747970653A202746656174757265272C0D0A2020202020202020202069643A20666561742E69642C0D0A2020202020202020202070726F70657274696573';
wwv_flow_imp.g_varchar2_table(50) := '3A2065646974203F20656469742E666561747572652E70726F70657274696573203A20666561742E70726F706572746965732C0D0A2020202020202020202067656F6D657472793A2065646974203F20656469742E666561747572652E67656F6D657472';
wwv_flow_imp.g_varchar2_table(51) := '79203A20666561742E67656F6D657472792C0D0A20202020202020207D3B0D0A2020202020207D290D0A2020202020202E66696C7465722878203D3E207820213D3D206E756C6C290D0A2020202020203F3F205B5D3B0D0A0D0A20202020636F6E737420';
wwv_flow_imp.g_varchar2_table(52) := '656469744665617475726573203D2041727261792E66726F6D2865646974732E76616C7565732829290D0A2020202020202E66696C7465722865646974203D3E20656469742E616374696F6E203D3D3D202763726561746527290D0A2020202020202E6D';
wwv_flow_imp.g_varchar2_table(53) := '61702865646974203D3E20287B0D0A2020202020202020747970653A202746656174757265272C0D0A202020202020202069643A20656469742E666561747572652E69642C0D0A202020202020202070726F706572746965733A20656469742E66656174';
wwv_flow_imp.g_varchar2_table(54) := '7572652E70726F706572746965732C0D0A202020202020202067656F6D657472793A20656469742E666561747572652E67656F6D657472792C0D0A2020202020207D29293B0D0A0D0A202020206665617475726573203D205B2E2E2E736F757263654665';
wwv_flow_imp.g_varchar2_table(55) := '6174757265732C202E2E2E6564697446656174757265735D3B0D0A2020202066656174757265734D61702E636C65617228293B0D0A20202020666F722028636F6E73742066656174206F6620666561747572657329207B0D0A2020202020206966202874';
wwv_flow_imp.g_varchar2_table(56) := '7970656F6620666561742E696420213D3D2027756E646566696E65642729207B0D0A202020202020202066656174757265734D61702E73657428666561742E69642C2066656174293B0D0A2020202020207D0D0A202020207D0D0A0D0A2020202069644D';
wwv_flow_imp.g_varchar2_table(57) := '61702E636C65617228293B0D0A2020202069644D61705265762E636C65617228293B0D0A202020206C6574206E6578744964203D20303B0D0A20202020636F6E737420616C6C6F634964203D20286F726967696E616C29203D3E207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(58) := '636F6E7374206964203D202B2B6E65787449643B0D0A20202020202069662028747970656F66206F726967696E616C20213D3D2027756E646566696E65642729207B0D0A202020202020202069644D61702E7365742869642C206F726967696E616C293B';
wwv_flow_imp.g_varchar2_table(59) := '0D0A202020202020202069644D61705265762E736574286F726967696E616C2C206964293B0D0A2020202020207D0D0A20202020202072657475726E2069643B0D0A202020207D0D0A0D0A20202020636F6E7374207265616C44617461203D207B0D0A20';
wwv_flow_imp.g_varchar2_table(60) := '20202020202E2E2E7265736F6C766564536F757263654F7074696F6E732E646174612C0D0A20202020202066656174757265733A2066656174757265732E6D617028286665617475726529203D3E207B0D0A2020202020202020636F6E73742066656174';
wwv_flow_imp.g_varchar2_table(61) := '203D207B0D0A20202020202020202020747970653A202746656174757265272C0D0A2020202020202020202069643A20616C6C6F63496428666561747572652E6964292C0D0A2020202020202020202067656F6D657472793A20666561747572652E6765';
wwv_flow_imp.g_varchar2_table(62) := '6F6D657472792C0D0A2020202020202020202070726F706572746965733A207B0D0A2020202020202020202020202E2E2E666561747572652E70726F706572746965732C0D0A202020202020202020207D2C0D0A20202020202020207D3B0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(63) := '2020202020206966202867657453656C656374696F6E5374796C652829203D3D3D202770726F70657274792729207B0D0A20202020202020202020666561742E70726F706572746965735B276D6170626974732D73656C6563746564275D203D20280D0A';
wwv_flow_imp.g_varchar2_table(64) := '20202020202020202020202073656C656374656446656174757265730D0A20202020202020202020202026262028747970656F6620666561747572652E696420213D3D2027756E646566696E656427290D0A202020202020202020202020262620666561';
wwv_flow_imp.g_varchar2_table(65) := '747572652E696420213D3D206E756C6C0D0A2020202020202020202020202626202873656C656374656446656174757265732E68617328666561747572652E696429207C7C2073656C656374656446656174757265732E68617328666561747572652E69';
wwv_flow_imp.g_varchar2_table(66) := '642E746F537472696E67282929290D0A20202020202020202020293B0D0A20202020202020207D0D0A20202020202020200D0A202020202020202072657475726E20666561743B0D0A2020202020207D292C0D0A202020207D3B0D0A0D0A20202020636F';
wwv_flow_imp.g_varchar2_table(67) := '6E7374206D6170203D2061776169742070656E64696E674D61703B0D0A0D0A20202020696620286D61702E676574536F7572636528736F757263654E616D652929207B0D0A2020202020206D61702E676574536F7572636528736F757263654E616D6529';
wwv_flow_imp.g_varchar2_table(68) := '2E73657444617461287265616C44617461293B0D0A202020207D20656C7365207B0D0A2020202020206C657420736F757263654F707473203D207B0D0A20202020202020202E2E2E7265736F6C766564536F757263654F7074696F6E732C0D0A20202020';
wwv_flow_imp.g_varchar2_table(69) := '20202020646174613A207265616C446174612C0D0A2020202020207D3B0D0A0D0A20202020202069662028216964436F6C756D6E2026262021282767656E657261746549642720696E20736F757263654F7074732929207B0D0A2020202020202020736F';
wwv_flow_imp.g_varchar2_table(70) := '757263654F7074732E67656E65726174654964203D20747275653B0D0A2020202020207D0D0A0D0A20202020202069662028736F757263654F7074732E636C757374657229207B0D0A2020202020202020736F757263654F707473203D207B0D0A202020';
wwv_flow_imp.g_varchar2_table(71) := '202020202020202E2E2E736F757263654F7074732C0D0A20202020202020202020636C757374657250726F706572746965733A207B0D0A2020202020202020202020205B276D6170626974732D73656C6563746564275D3A205B27616E79272C205B2767';
wwv_flow_imp.g_varchar2_table(72) := '6574272C20276D6170626974732D73656C6563746564275D5D2C0D0A2020202020202020202020202E2E2E736F757263654F7074732E636C757374657250726F706572746965732C0D0A202020202020202020207D0D0A20202020202020207D3B0D0A20';
wwv_flow_imp.g_varchar2_table(73) := '20202020207D0D0A0D0A202020202020747279207B0D0A20202020202020206D61702E616464536F7572636528736F757263654E616D652C20736F757263654F707473293B0D0A2020202020207D2063617463682028657863657074696F6E29207B0D0A';
wwv_flow_imp.g_varchar2_table(74) := '2020202020202020617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B6974656D49647D203A204661696C656420746F206164642047656F4A534F4E20736F75726365602C20657863657074696F6E';
wwv_flow_imp.g_varchar2_table(75) := '293B0D0A2020202020207D0D0A202020207D0D0A20207D3B0D0A0D0A2020636F6E7374207370696E6E6572496D616765203D2022646174613A696D6167652F6769663B6261736536342C52306C474F446C684541415141504D50414C753775356D5A6D54';
wwv_flow_imp.g_varchar2_table(76) := '4D7A4D3933643352455245514141414864336431565656575A6D5A717171716F6949694F3775376B52455243496949674152414141414143482F4330354656464E44515642464D69347741774541414141682B5151464277415041437741414141414541';
wwv_flow_imp.g_varchar2_table(77) := '4151414541456350444A747967366455724665744454496F704D6F53794663787844316B7244384177436B415344496C50615544514C52364731437930536771496B45314951474D7246414B4363475753427A7750416E41776172634B5131354D70544D';
wwv_flow_imp.g_varchar2_table(78) := '4A5964315A79554458534447656C42593071496F42682F5A6F594767454C436A6F78435252764951634744316B7A67534167414143514478454149666B4542516341447741734141414141413841454141414246337779666B4D6B6F744F4A707363524B';
wwv_flow_imp.g_varchar2_table(79) := '4A4A7774493451314D416F785130524642773078457668474156525A5A4A68344A674D414551573754574934457747466A4B522B43415145436A6E38446F4E306B7744747642543846494C414B4A67666F6F3169414741504E56593944474A584E4D4948';
wwv_flow_imp.g_varchar2_table(80) := '4E2F484A56714978454149666B4542516341447741734141414141424141447741414246727779666D436F6C6769796470615169593578394974683768555264496C30774249687043416A4B494978614155505130684651734143374D4A414C46534669';
wwv_flow_imp.g_varchar2_table(81) := '3453674334777948797543594E5778483341756853456F746B4E4741414C415071716B696747384D57416A416E4D34413835393476505579494149666B4542516341447741734141414141424141454141414246337779536B4476644B736464672B4150';
wwv_flow_imp.g_varchar2_table(82) := '594957726367324449525141635536444A49436A49736A424545544C454542594C71595344644A6F43476948675A7747344C51434352454345494241646F463568644549577767424A714473374467634B7952485A6C3375557775686D3241624E4E572B';
wwv_flow_imp.g_varchar2_table(83) := '4C563779642B4678454149666B4542516341434141734141414141424141446741414245595179596D4D6F56676557517250334E59684243675A4264414652556B6442494155677556566F315A7357466345474235474D426B456A6943424C3261355A41';
wwv_flow_imp.g_varchar2_table(84) := '692B6D32534155524578774B71506975436166426B76425343636D6959524143483542415548414134414C414141414141514142414141415273304D6E70414B4459726253574D7030785A4976424B5972586A4E6D41444F68414B426951444635674763';
wwv_flow_imp.g_varchar2_table(85) := '49434E41794A5477465954426144513048416B6777536D41556A304F6B4D726B5A4D344842674B4B3759544B44524943416F32636C41454968654B63394349536A455654754551724A41534763534251635355464555445155584A4267444257305A6A33';
wwv_flow_imp.g_varchar2_table(86) := '34524143483542415548414138414C414141414141514142414141415266384D6E3578714259677256433445456D42634F536641456A536F704A4D676C6D63516C6742596A45354E4A675A776A4341624F345942414A6A70496A53694151683561797952';
wwv_flow_imp.g_varchar2_table(87) := '4149444B764A49626E4961676F465246646B5144514B433052427343495546415773543752774734313052384869694B305742774A6A4642454149666B45425163414467417341514142414138414477414142467251796245574144584A4C554848414D';
wwv_flow_imp.g_varchar2_table(88) := '4A78494441676E724F6F322B414F6962454D68314C4E363267497870687A6974526F434441594E634E4E3646424C5368616F34577A774844514B765647686F46417747677446675148454E686F42376E43774852414943304579556343385A7731686133';
wwv_flow_imp.g_varchar2_table(89) := '4E495267414149666B4542516341447741734141414141424141454141414247447779666E576F6C6A614E595946562B5A783368434547456375797042744D4A42495370436C41574C66574F44796D494669434A774D444D695A424E4141594671554161';
wwv_flow_imp.g_varchar2_table(90) := '4E5132453059424958475552414D436F31414173465942426F495363424A4577675356636D50306C6934467763487A2B46704343514D504346494E78454149666B45425163414467417341414142414241414477414142467A5179656D5758594E716153';
wwv_flow_imp.g_varchar2_table(91) := '5859327656747733554E6D524F4D344A516F774B4B6C464F736752493641535138496853414446416A414D494D416753594A744279787951496863456F614263536977656770446776417753424A30414948426F435171494145692F5443494141424768';
wwv_flow_imp.g_varchar2_table(92) := '4C47384D62634B425167455141682B51514642774150414377414141454145414150414141455866444A53642B71654B355242386644525257467370796F74414166514262664E4C4356555353644B445638396744417763464249426779774D526E6B57';
wwv_flow_imp.g_varchar2_table(93) := '4267634A55444B535A52494B4150516347775942794141595445454A41414A494762415445512B423445786D4B3943446842643854686448772F416D5559455141682B51514642774150414377414141454144774150414141455876424A514961382B49';
wwv_flow_imp.g_varchar2_table(94) := '4C53737064486B587853397778463451334C3261544265433073466A68417475794C496A414D6859633247426761534B4775794E6F42447037637A4641676542494B7743366B5743414D78555341466A744E43414146474746357443514C41614A6E5743';
wwv_flow_imp.g_varchar2_table(95) := '5471486F5245765175514A416B79474245414F773D3D223B0D0A0D0A20207661722061646465644C61796572203D2066616C73653B0D0A20206C6574206F726967696E616C4C61796572733B0D0A0D0A20206173796E632066756E6374696F6E206C6F61';
wwv_flow_imp.g_varchar2_table(96) := '64446174612829207B0D0A202020202428272327202B206974656D4964202B20275F6C6567656E645F656E7472795F73746174757327292E617474722827737263272C207370696E6E6572496D616765293B0D0A20202020617065782E6576656E742E74';
wwv_flow_imp.g_varchar2_table(97) := '72696767657228272327202B206974656D49642C20276C6F61645F737461727427293B0D0A20202020747279207B0D0A202020202020636F6E7374207265616C536F757263654F7074696F6E73203D20747970656F6620736F757263654F7074696F6E73';
wwv_flow_imp.g_varchar2_table(98) := '203D3D3D202766756E6374696F6E27203F20617761697420736F757263654F7074696F6E732829203A20736F757263654F7074696F6E733B0D0A20202020202069662028736F7572636554797065203D3D3D20226A6176617363726970742229207B0D0A';
wwv_flow_imp.g_varchar2_table(99) := '20202020202020207265736F6C766564536F757263654F7074696F6E73203D207B0D0A202020202020202020202E2E2E7265616C536F757263654F7074696F6E732C0D0A20202020202020202020747970653A202767656F6A736F6E272C0D0A20202020';
wwv_flow_imp.g_varchar2_table(100) := '202020207D3B0D0A2020202020207D20656C7365207B0D0A2020202020202020636F6E737420726573706F6E7365203D20617761697420617065782E7365727665722E706C7567696E28616A61784964656E7469666965722C207B706167654974656D73';
wwv_flow_imp.g_varchar2_table(101) := '3A207375626D69744974656D73203F207375626D69744974656D732E73706C697428222C22292E66696C7465722878203D3E2021217829203A20756E646566696E65647D293B0D0A20202020202020207265736F6C766564536F757263654F7074696F6E';
wwv_flow_imp.g_varchar2_table(102) := '73203D207B0D0A202020202020202020202E2E2E7265616C536F757263654F7074696F6E732C0D0A20202020202020202020747970653A202767656F6A736F6E272C0D0A20202020202020202020646174613A20726573706F6E73652C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(103) := '2020207D3B0D0A2020202020207D0D0A20202020202061776169742072656C6F6164536F757263654461746128293B0D0A202020207D2066696E616C6C79207B0D0A202020202020617065782E6576656E742E7472696767657228272327202B20697465';
wwv_flow_imp.g_varchar2_table(104) := '6D49642C20276C6F61645F656E6427293B0D0A2020202020202428272327202B206974656D4964202B20275F6C6567656E645F656E7472795F73746174757327292E617474722827737263272C202727293B0D0A202020207D0D0A0D0A20202020636F6E';
wwv_flow_imp.g_varchar2_table(105) := '7374206D6170203D2061776169742070656E64696E674D61703B0D0A0D0A20202020636F6E73742073656C656374696F6E436F6C6F72203D2073656C656374696F6E5374796C654F7074732E636F6C6F72203F3F202723303566616464273B0D0A0D0A20';
wwv_flow_imp.g_varchar2_table(106) := '202020696620282161646465644C6179657229207B0D0A20202020202061646465644C61796572203D20747275653B0D0A0D0A2020202020206966202873656C656374696F6E5374796C654F7074732E72656374616E676C6553656C65637429207B0D0A';
wwv_flow_imp.g_varchar2_table(107) := '202020202020202069662028216D61702E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C29207B0D0A202020202020202020206D61702E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E';
wwv_flow_imp.g_varchar2_table(108) := '74726F6C203D206E65772052656374616E676C6553656C656374436F6E74726F6C28293B0D0A202020202020202020206D61702E616464436F6E74726F6C286D61702E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F';
wwv_flow_imp.g_varchar2_table(109) := '6C293B0D0A20202020202020207D0D0A20202020202020206D61702E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C2E6164644C61796572286974656D4964293B0D0A2020202020207D0D0A2020202020200D0A20';
wwv_flow_imp.g_varchar2_table(110) := '202020202073776974636820286C617965725479706529207B0D0A202020202020202063617365202773796D626F6C273A0D0A202020202020202020206F726967696E616C4C6179657273203D207B0D0A202020202020202020202020747970653A2027';
wwv_flow_imp.g_varchar2_table(111) := '73796D626F6C272C0D0A2020202020202020202020206C61796F75743A207B7D0D0A202020202020202020207D3B0D0A20202020202020202020696620286C6162656C436F6C756D6E2920207B0D0A2020202020202020202020206F726967696E616C4C';
wwv_flow_imp.g_varchar2_table(112) := '61796572732E6C61796F75745B27746578742D6669656C64275D203D205B0D0A20202020202020202020202020202763617365272C0D0A20202020202020202020202020205B27686173272C2027706F696E745F636F756E74275D2C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(113) := '20202020202020205B27636F6E636174272C205B27676574272C2027706F696E745F636F756E74275D2C2027206665617475726573275D2C0D0A20202020202020202020202020205B27676574272C206C6162656C436F6C756D6E5D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(114) := '2020202020205D3B0D0A2020202020202020202020206F726967696E616C4C61796572732E6C61796F75745B27746578742D73697A65275D203D20666F6E7453697A65203F3F2031323B0D0A202020202020202020207D0D0A2020202020202020202069';
wwv_flow_imp.g_varchar2_table(115) := '66202869636F6E29207B0D0A2020202020202020202020206F726967696E616C4C61796572732E6C61796F75745B2769636F6E2D696D616765275D203D2069636F6E3B0D0A202020202020202020207D0D0A20202020202020202020627265616B3B0D0A';
wwv_flow_imp.g_varchar2_table(116) := '0D0A20202020202020206361736520276C696E65273A207B0D0A20202020202020202020636F6E7374206C696E654C61796572203D207B0D0A202020202020202020202020747970653A20276C696E65272C0D0A2020202020202020202020206C61796F';
wwv_flow_imp.g_varchar2_table(117) := '75743A207B7D2C0D0A2020202020202020202020207061696E743A207B0D0A2020202020202020202020202020276C696E652D7769647468273A206C696E655769647468203F3F20312C0D0A2020202020202020202020207D2C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(118) := '20207D3B0D0A0D0A20202020202020202020696620286C696E6544617368417272617929207B0D0A2020202020202020202020206C696E654C617965722E7061696E745B276C696E652D646173686172726179275D203D206C696E654461736841727261';
wwv_flow_imp.g_varchar2_table(119) := '792E73706C697428272027292E6D61702878203D3E207061727365466C6F6174287829293B0D0A202020202020202020207D0D0A0D0A202020202020202020206F726967696E616C4C6179657273203D205B0D0A2020202020202020202020207B0D0A20';
wwv_flow_imp.g_varchar2_table(120) := '2020202020202020202020202069643A202773656C656374696F6E272C0D0A2020202020202020202020202020747970653A20276C696E65272C0D0A202020202020202020202020202066696C7465723A206F75746C696E65436F6C6F72203F20747275';
wwv_flow_imp.g_varchar2_table(121) := '65203A205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A20202020202020202020202020206C61796F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B0D0A20';
wwv_flow_imp.g_varchar2_table(122) := '202020202020202020202020202020276C696E652D7769647468273A20332C0D0A20202020202020202020202020202020276C696E652D636F6C6F72273A206F75746C696E65436F6C6F72203F205B2763617365272C205B273D3D272C205B2767657427';
wwv_flow_imp.g_varchar2_table(123) := '2C20276D6170626974732D73656C6563746564275D2C20747275655D2C2073656C656374696F6E436F6C6F722C206F75746C696E65436F6C6F725D203A2073656C656374696F6E436F6C6F722C0D0A20202020202020202020202020207D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(124) := '2020202020202020207D2C0D0A2020202020202020202020206C696E654C617965722C0D0A202020202020202020205D3B0D0A0D0A20202020202020202020696620286C6162656C436F6C756D6E29207B0D0A2020202020202020202020206F72696769';
wwv_flow_imp.g_varchar2_table(125) := '6E616C4C61796572732E70757368287B0D0A202020202020202020202020202069643A20276C6162656C272C0D0A2020202020202020202020202020747970653A202773796D626F6C272C0D0A20202020202020202020202020206C61796F75743A207B';
wwv_flow_imp.g_varchar2_table(126) := '0D0A2020202020202020202020202020202027746578742D6669656C64273A205B27676574272C206C6162656C436F6C756D6E5D2C0D0A2020202020202020202020202020202027746578742D73697A65273A20666F6E7453697A65203F3F2031322C0D';
wwv_flow_imp.g_varchar2_table(127) := '0A202020202020202020202020202020202773796D626F6C2D706C6163656D656E74273A20276C696E65272C0D0A20202020202020202020202020207D2C0D0A2020202020202020202020207D293B0D0A202020202020202020207D0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(128) := '202020202020627265616B3B0D0A20202020202020207D0D0A0D0A202020202020202063617365202766696C6C273A0D0A202020202020202020206F726967696E616C4C6179657273203D205B0D0A2020202020202020202020207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(129) := '2020202020202020747970653A202766696C6C272C0D0A20202020202020202020202020206C61796F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B7D2C0D0A2020202020202020202020207D2C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(130) := '202020207B0D0A202020202020202020202020202069643A202773656C656374696F6E272C0D0A2020202020202020202020202020747970653A20276C696E65272C0D0A202020202020202020202020202066696C7465723A205B273D3D272C205B2767';
wwv_flow_imp.g_varchar2_table(131) := '6574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A20202020202020202020202020206C61796F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B0D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(132) := '20276C696E652D7769647468273A20332C0D0A20202020202020202020202020202020276C696E652D636F6C6F72273A2073656C656374696F6E436F6C6F722C0D0A20202020202020202020202020207D2C0D0A2020202020202020202020207D2C0D0A';
wwv_flow_imp.g_varchar2_table(133) := '202020202020202020205D3B0D0A20202020202020202020627265616B3B0D0A0D0A202020202020202064656661756C743A0D0A202020202020202020206F726967696E616C4C6179657273203D206C61796572446566696E6974696F6E3B0D0A202020';
wwv_flow_imp.g_varchar2_table(134) := '2020207D0D0A0D0A202020202020696620286F726967696E616C4C6179657273203D3D3D206E756C6C29207B0D0A20202020202020206F726967696E616C4C6179657273203D207B7D3B0D0A2020202020207D0D0A20202020202069662028747970656F';
wwv_flow_imp.g_varchar2_table(135) := '66206F726967696E616C4C6179657273203D3D3D202766756E6374696F6E2729207B0D0A20202020202020206F726967696E616C4C6179657273203D206F726967696E616C4C617965727328293B0D0A2020202020207D0D0A2020202020206966202821';
wwv_flow_imp.g_varchar2_table(136) := '41727261792E69734172726179286F726967696E616C4C61796572732929207B0D0A20202020202020206F726967696E616C4C6179657273203D205B6F726967696E616C4C61796572735D3B0D0A2020202020207D0D0A0D0A202020202020636F6E7374';
wwv_flow_imp.g_varchar2_table(137) := '206C6179657273203D206F726967696E616C4C61796572732E6D617028286F726967696E616C4C617965722C206929203D3E207B0D0A2020202020202020636F6E7374206C61796572203D207B0D0A202020202020202020202E2E2E6F726967696E616C';
wwv_flow_imp.g_varchar2_table(138) := '4C617965722C0D0A2020202020202020202069643A206F726967696E616C4C617965722E6964203F206974656D4964202B20272D27202B206F726967696E616C4C617965722E6964203A206974656D4964202B20272D27202B20692C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(139) := '20202020736F757263653A20736F757263654E616D652C0D0A202020202020202020206C61796F75743A207B0D0A2020202020202020202020202E2E2E6F726967696E616C4C617965722E6C61796F75742C0D0A202020202020202020207D2C0D0A2020';
wwv_flow_imp.g_varchar2_table(140) := '20202020202020207061696E743A207B0D0A2020202020202020202020202E2E2E6F726967696E616C4C617965722E7061696E742C0D0A202020202020202020207D2C0D0A202020202020202020206D657461646174613A207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(141) := '202020206C617965725F73657175656E63653A2073657175656E63654E756D6265722C0D0A2020202020202020202020206974656D5F69643A206974656D49642C0D0A2020202020202020202020202E2E2E6F726967696E616C4C617965722E6D657461';
wwv_flow_imp.g_varchar2_table(142) := '646174612C0D0A202020202020202020207D0D0A20202020202020207D3B0D0A0D0A2020202020202020696620286C617965722E74797065203D3D3D202773796D626F6C2729207B0D0A20202020202020202020696620286C617965722E6C61796F7574';
wwv_flow_imp.g_varchar2_table(143) := '5B27746578742D6669656C64275D29207B0D0A2020202020202020202020206C617965722E7061696E745B27746578742D636F6C6F72275D203F3F3D20636F6C6F723B0D0A2020202020202020202020206C617965722E7061696E745B27746578742D6F';
wwv_flow_imp.g_varchar2_table(144) := '706163697479275D203F3F3D206F7061636974793B0D0A2020202020202020202020206C617965722E6C61796F75745B27746578742D666F6E74275D203F3F3D205B274D6574726F706F6C697320526567756C6172272C20274E6F746F2053616E732052';
wwv_flow_imp.g_varchar2_table(145) := '6567756C6172275D3B0D0A2020202020202020202020206C617965722E6C61796F75745B27746578742D73697A65275D203F3F3D2031323B0D0A2020202020202020202020206C617965722E7061696E745B27746578742D68616C6F2D7769647468275D';
wwv_flow_imp.g_varchar2_table(146) := '203F3F3D20312E353B0D0A2020202020202020202020206C617965722E7061696E745B27746578742D68616C6F2D636F6C6F72275D203F3F3D205B0D0A20202020202020202020202020202763617365272C0D0A20202020202020202020202020205B27';
wwv_flow_imp.g_varchar2_table(147) := '3D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A202020202020202020202020202073656C656374696F6E436F6C6F722C0D0A20202020202020202020202020206F75746C696E65436F6C6F7220';
wwv_flow_imp.g_varchar2_table(148) := '3F3F202723636363270D0A2020202020202020202020205D3B0D0A2020202020202020202020206C617965722E6C61796F75745B27746578742D6A757374696679275D203F3F3D20276175746F273B0D0A0D0A202020202020202020202020696620286C';
wwv_flow_imp.g_varchar2_table(149) := '617965722E6C61796F75745B2769636F6E2D696D616765275D29207B0D0A20202020202020202020202020206C617965722E6C61796F75745B27746578742D6F6666736574275D203F3F3D205B302C20302E355D3B0D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(150) := '2069662028216C617965722E6C61796F75745B27746578742D616E63686F72275D20262620216C617965722E6C61796F75745B27746578742D7661726961626C652D616E63686F72275D29207B0D0A202020202020202020202020202020206C61796572';
wwv_flow_imp.g_varchar2_table(151) := '2E6C61796F75745B27746578742D7661726961626C652D616E63686F72275D203D205B27746F70272C20276C656674272C2027746F702D6C656674275D3B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D0D0A20202020';
wwv_flow_imp.g_varchar2_table(152) := '2020202020207D0D0A0D0A20202020202020202020696620286C617965722E6C61796F75745B2769636F6E2D696D616765275D29207B0D0A2020202020202020202020206C617965722E6C61796F75745B2769636F6E2D616C6C6F772D6F7665726C6170';
wwv_flow_imp.g_varchar2_table(153) := '275D203F3F3D20747275653B0D0A2020202020202020202020206C617965722E6C61796F75745B27746578742D6F7074696F6E616C275D203F3F3D20747275653B0D0A2020202020202020202020206C617965722E7061696E745B2769636F6E2D636F6C';
wwv_flow_imp.g_varchar2_table(154) := '6F72275D203F3F3D20636F6C6F723B0D0A2020202020202020202020206C617965722E7061696E745B2769636F6E2D6F706163697479275D203F3F3D206F7061636974793B0D0A2020202020202020202020206C617965722E7061696E745B2769636F6E';
wwv_flow_imp.g_varchar2_table(155) := '2D68616C6F2D7769647468275D203F3F3D205B0D0A20202020202020202020202020202763617365272C0D0A20202020202020202020202020205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C';
wwv_flow_imp.g_varchar2_table(156) := '0D0A2020202020202020202020202020322C0D0A20202020202020202020202020206F75746C696E65436F6C6F72203F2031203A20300D0A2020202020202020202020205D3B0D0A2020202020202020202020206C617965722E7061696E745B2769636F';
wwv_flow_imp.g_varchar2_table(157) := '6E2D68616C6F2D636F6C6F72275D203F3F3D205B0D0A20202020202020202020202020202763617365272C0D0A20202020202020202020202020205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D';
wwv_flow_imp.g_varchar2_table(158) := '2C0D0A202020202020202020202020202073656C656374696F6E436F6C6F722C0D0A20202020202020202020202020206F75746C696E65436F6C6F72203F3F20277472616E73706172656E74270D0A2020202020202020202020205D3B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(159) := '20202020207D20656C7365207B0D0A2020202020202020202020206C617965722E6C61796F75745B27746578742D616C6C6F772D6F7665726C6170275D203F3F3D20747275653B0D0A202020202020202020207D0D0A20202020202020207D20656C7365';
wwv_flow_imp.g_varchar2_table(160) := '20696620286C617965722E74797065203D3D3D20276C696E652729207B0D0A202020202020202020206C617965722E7061696E745B276C696E652D636F6C6F72275D203F3F3D20636F6C6F723B0D0A202020202020202020206C617965722E7061696E74';
wwv_flow_imp.g_varchar2_table(161) := '5B276C696E652D6F706163697479275D203F3F3D206F7061636974793B0D0A20202020202020207D20656C736520696620286C617965722E74797065203D3D3D202766696C6C2729207B0D0A202020202020202020206C617965722E7061696E745B2766';
wwv_flow_imp.g_varchar2_table(162) := '696C6C2D636F6C6F72275D203F3F3D20636F6C6F723B0D0A202020202020202020206C617965722E7061696E745B2766696C6C2D6F706163697479275D203F3F3D206F7061636974793B0D0A202020202020202020206C617965722E7061696E745B2766';
wwv_flow_imp.g_varchar2_table(163) := '696C6C2D6F75746C696E652D636F6C6F72275D203F3F3D206F75746C696E65436F6C6F72207C7C2027626C61636B273B0D0A20202020202020207D0D0A0D0A202020202020202072657475726E206C617965723B0D0A2020202020207D293B0D0A0D0A20';
wwv_flow_imp.g_varchar2_table(164) := '2020202020737769746368202867657453656C656374696F6E5374796C65282929207B0D0A20202020202020206361736520276C696E65273A0D0A2020202020202020202073656C656374696F6E4C617965724964203D206974656D4964202B20272D2D';
wwv_flow_imp.g_varchar2_table(165) := '73656C656374696F6E2D6C696E65273B0D0A202020202020202020206C61796572732E70757368287B0D0A20202020202020202020202069643A2073656C656374696F6E4C6179657249642C0D0A202020202020202020202020747970653A20276C696E';
wwv_flow_imp.g_varchar2_table(166) := '65272C0D0A202020202020202020202020736F757263653A20736F757263654E616D652C0D0A20202020202020202020202066696C7465723A2067657453656C6563746564466561747572657346696C74657228292C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(167) := '6C61796F75743A207B0D0A2020202020202020202020202020276C696E652D636170273A2073656C656374696F6E5374796C654F7074735B276C696E652D636170275D203F3F2027726F756E64272C0D0A2020202020202020202020207D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(168) := '2020202020202020207061696E743A207B0D0A2020202020202020202020202020276C696E652D6761702D7769647468273A2073656C656374696F6E5374796C654F7074735B276C696E652D6761702D7769647468275D203F3F20332C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(169) := '202020202020202020276C696E652D7769647468273A2073656C656374696F6E5374796C654F7074735B276C696E652D7769647468275D203F3F20322C0D0A2020202020202020202020202020276C696E652D636F6C6F72273A2073656C656374696F6E';
wwv_flow_imp.g_varchar2_table(170) := '5374796C654F7074735B276C696E652D636F6C6F72275D203F3F2073656C656374696F6E436F6C6F722C0D0A2020202020202020202020207D2C0D0A2020202020202020202020206D657461646174613A207B0D0A20202020202020202020202020206C';
wwv_flow_imp.g_varchar2_table(171) := '617965725F73657175656E63653A2073657175656E63654E756D6265722C0D0A2020202020202020202020207D2C0D0A202020202020202020207D293B0D0A20202020202020202020627265616B3B0D0A0D0A2020202020202020636173652027636972';
wwv_flow_imp.g_varchar2_table(172) := '636C65273A0D0A2020202020202020202073656C656374696F6E4C617965724964203D206974656D4964202B20272D2D73656C656374696F6E2D636972636C65273B0D0A202020202020202020206C61796572732E70757368287B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(173) := '202020202069643A2073656C656374696F6E4C6179657249642C0D0A202020202020202020202020747970653A2027636972636C65272C0D0A202020202020202020202020736F757263653A20736F757263654E616D652C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(174) := '202066696C7465723A2067657453656C6563746564466561747572657346696C74657228292C0D0A2020202020202020202020207061696E743A207B0D0A202020202020202020202020202027636972636C652D726164697573273A2073656C65637469';
wwv_flow_imp.g_varchar2_table(175) := '6F6E5374796C654F7074735B27636972636C652D726164697573275D203F3F20352C0D0A202020202020202020202020202027636972636C652D636F6C6F72273A2073656C656374696F6E5374796C654F7074735B27636972636C652D636F6C6F72275D';
wwv_flow_imp.g_varchar2_table(176) := '203F3F20277472616E73706172656E74272C0D0A202020202020202020202020202027636972636C652D7374726F6B652D636F6C6F72273A2073656C656374696F6E5374796C654F7074735B27636972636C652D7374726F6B652D636F6C6F72275D203F';
wwv_flow_imp.g_varchar2_table(177) := '3F2073656C656374696F6E436F6C6F722C0D0A202020202020202020202020202027636972636C652D7374726F6B652D7769647468273A2073656C656374696F6E5374796C654F7074735B27636972636C652D7374726F6B652D7769647468275D203F3F';
wwv_flow_imp.g_varchar2_table(178) := '20322C0D0A2020202020202020202020207D2C0D0A2020202020202020202020206D657461646174613A207B0D0A20202020202020202020202020206C617965725F73657175656E63653A2073657175656E63654E756D6265722C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(179) := '20202020207D2C0D0A202020202020202020207D293B0D0A20202020202020202020627265616B3B0D0A2020202020207D0D0A0D0A202020202020636F6E7374206D6170626974736C6179657273203D206D61702E6765745374796C6528292E6C617965';
wwv_flow_imp.g_varchar2_table(180) := '72732E66696C746572282876616C29203D3E207B0D0A202020202020202069662028276D657461646174612720696E2076616C29207B200D0A2020202020202020202072657475726E20276C617965725F73657175656E63652720696E2076616C2E6D65';
wwv_flow_imp.g_varchar2_table(181) := '7461646174613B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202072657475726E2066616C73653B0D0A20202020202020207D0D0A2020202020207D292E6D61702866756E6374696F6E2876616C29207B72657475726E205B76';
wwv_flow_imp.g_varchar2_table(182) := '616C2E6D657461646174612E6C617965725F73657175656E63652C2076616C2E69645D7D293B0D0A202020202020766172206265666F72654C617965723B0D0A202020202020696620286D6170626974736C61796572732E6C656E67746820213D3D2030';
wwv_flow_imp.g_varchar2_table(183) := '29207B0D0A20202020202020206D6170626974736C61796572732E736F72742828612C206229203D3E20615B305D202D20625B305D293B0D0A2020202020202020666F722876617220693D303B693C6D6170626974736C61796572732E6C656E6774683B';
wwv_flow_imp.g_varchar2_table(184) := '692B2B29207B0D0A202020202020202020206966202873657175656E63654E756D626572203C206D6170626974736C61796572735B695D5B305D29207B0D0A2020202020202020202020206265666F72654C61796572203D206D6170626974736C617965';
wwv_flow_imp.g_varchar2_table(185) := '72735B695D5B315D3B0D0A202020202020202020202020627265616B3B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D0D0A0D0A2020202020206C6574206C61737453656C656374656446656174757265203D206E75';
wwv_flow_imp.g_varchar2_table(186) := '6C6C3B0D0A0D0A202020202020666F722028636F6E7374206C206F66206C617965727329207B0D0A2020202020202020747279207B0D0A202020202020202020206D61702E6164644C61796572286C2C206265666F72654C61796572293B0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(187) := '2020202020202020696620286973436C69636B61626C65282929207B0D0A2020202020202020202020206D61702E5F5F6D6170626974735F6C617965725F637572736F72732E736574286C2E69642C2027706F696E74657227293B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(188) := '2020202020636F6E737420736574506F696E746572203D2028657629203D3E207B0D0A2020202020202020202020202020666F722028636F6E73742066656174206F66206D61702E717565727952656E646572656446656174757265732865762E706F69';
wwv_flow_imp.g_varchar2_table(189) := '6E742929207B0D0A20202020202020202020202020202020696620286D61702E5F5F6D6170626974735F6C617965725F637572736F72732E68617328666561742E6C617965723F2E69642929207B0D0A2020202020202020202020202020202020206D61';
wwv_flow_imp.g_varchar2_table(190) := '702E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F72203D206D61702E5F5F6D6170626974735F6C617965725F637572736F72732E67657428666561742E6C617965722E6964293B0D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(191) := '202020202072657475726E3B0D0A202020202020202020202020202020207D0D0A20202020202020202020202020207D0D0A20202020202020202020202020206D61702E67657443616E766173436F6E7461696E657228292E7374796C652E72656D6F76';
wwv_flow_imp.g_varchar2_table(192) := '6550726F70657274792827637572736F7227293B0D0A2020202020202020202020207D3B0D0A2020202020202020202020206D61702E6F6E28276D6F757365656E746572272C206C2E69642C20736574506F696E746572293B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(193) := '2020206D61702E6F6E28276D6F7573656C65617665272C206C2E69642C20736574506F696E746572293B0D0A0D0A2020202020202020202020202F2A2044697361626C6520626F78207A6F6F6D207768656E20636C69636B696E6720612073656C656374';
wwv_flow_imp.g_varchar2_table(194) := '61626C65206C617965722C2073696E636520697420696E7465726665726573207769746820736869667420636C69636B696E67202A2F0D0A20202020202020202020202069662873656C656374696F6E5374796C654F7074732E656E61626C65436C6963';
wwv_flow_imp.g_varchar2_table(195) := '6B2026262073656C656374696F6E5374796C654F7074732E6F72646572427929207B0D0A20202020202020202020202020206C657420626F785A6F6F6D576173456E61626C6564203D2066616C73653B0D0A0D0A20202020202020202020202020206D61';
wwv_flow_imp.g_varchar2_table(196) := '702E6F6E28276D6F757365646F776E272C206C2E69642C2028657629203D3E207B0D0A202020202020202020202020202020206966202865762E6F726967696E616C4576656E742E73686966744B657929207B0D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(197) := '202020636F6E7374206973546F706D6F73744C61796572203D206D61702E717565727952656E646572656446656174757265732865762E706F696E74295B305D2E6C617965722E6964203D3D3D2065762E66656174757265735B305D2E6C617965722E69';
wwv_flow_imp.g_varchar2_table(198) := '643B0D0A202020202020202020202020202020202020696620286973546F706D6F73744C6179657229207B0D0A2020202020202020202020202020202020202020626F785A6F6F6D576173456E61626C6564203D206D61702E626F785A6F6F6D2E697345';
wwv_flow_imp.g_varchar2_table(199) := '6E61626C656428293B0D0A20202020202020202020202020202020202020206D61702E626F785A6F6F6D2E64697361626C6528293B0D0A2020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A2020202020';
wwv_flow_imp.g_varchar2_table(200) := '2020202020202020207D293B0D0A0D0A20202020202020202020202020206D61702E6F6E28276D6F7573657570272C206C2E69642C202829203D3E207B0D0A2020202020202020202020202020202069662028626F785A6F6F6D576173456E61626C6564';
wwv_flow_imp.g_varchar2_table(201) := '29207B0D0A2020202020202020202020202020202020206D61702E626F785A6F6F6D2E656E61626C6528293B0D0A202020202020202020202020202020207D0D0A20202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A0D';
wwv_flow_imp.g_varchar2_table(202) := '0A2020202020202020202020206D61702E6F6E2827636C69636B272C206C2E69642C2028657629203D3E207B0D0A2020202020202020202020202020636F6E7374206973546F706D6F73744C61796572203D206D61702E717565727952656E6465726564';
wwv_flow_imp.g_varchar2_table(203) := '46656174757265732865762E706F696E74295B305D2E6C617965722E6964203D3D3D2065762E66656174757265735B305D2E6C617965722E69643B0D0A2020202020202020202020202020636F6E7374206964203D2069644D61702E6765742865762E66';
wwv_flow_imp.g_varchar2_table(204) := '656174757265735B305D2E6964293B0D0A0D0A2020202020202020202020202020617065782E6576656E742E7472696767657228272327202B206974656D49642C2027636C69636B272C207B0D0A20202020202020202020202020202020666561747572';
wwv_flow_imp.g_varchar2_table(205) := '653A207B0D0A202020202020202020202020202020202020747970653A202746656174757265272C0D0A20202020202020202020202020202020202069642C0D0A20202020202020202020202020202020202070726F706572746965733A2065762E6665';
wwv_flow_imp.g_varchar2_table(206) := '6174757265735B305D2E70726F706572746965732C0D0A20202020202020202020202020202020202067656F6D657472793A2065762E66656174757265735B305D2E67656F6D657472792C0D0A202020202020202020202020202020207D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(207) := '202020202020202020202020206973546F706D6F73744C617965722C0D0A20202020202020202020202020202020706F696E743A2065762E706F696E742C0D0A20202020202020202020202020207D293B0D0A0D0A202020202020202020202020202069';
wwv_flow_imp.g_varchar2_table(208) := '66202873656C656374696F6E5374796C654F7074732E656E61626C65436C69636B202626206973546F706D6F73744C6179657229207B0D0A202020202020202020202020202020206966202865762E6F726967696E616C4576656E742E6374726C4B6579';
wwv_flow_imp.g_varchar2_table(209) := '202626202173656C656374696F6E5374796C654F7074732E636C69636B53696E676C6553656C65637429207B0D0A20202020202020202020202020202020202073657453656C65637465644665617475726573285B69645D2C2027746F67676C6527293B';
wwv_flow_imp.g_varchar2_table(210) := '0D0A202020202020202020202020202020207D20656C736520696620280D0A20202020202020202020202020202020202065762E6F726967696E616C4576656E742E73686966744B65790D0A20202020202020202020202020202020202026262073656C';
wwv_flow_imp.g_varchar2_table(211) := '656374696F6E5374796C654F7074732E6F7264657242790D0A2020202020202020202020202020202020202626202173656C656374696F6E5374796C654F7074732E636C69636B53696E676C6553656C6563740D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(212) := '2020202626206C61737453656C6563746564466561747572650D0A2020202020202020202020202020202029207B0D0A202020202020202020202020202020202020636F6E7374206F726465724279203D2065762E66656174757265735B305D2E70726F';
wwv_flow_imp.g_varchar2_table(213) := '706572746965735B73656C656374696F6E5374796C654F7074732E6F7264657242795D3B0D0A202020202020202020202020202020202020636F6E737420706172746974696F6E4279203D2065762E66656174757265735B305D2E70726F706572746965';
wwv_flow_imp.g_varchar2_table(214) := '735B73656C656374696F6E5374796C654F7074732E706172746974696F6E42795D3B0D0A202020202020202020202020202020202020636F6E737420616464203D205B5D3B0D0A0D0A2020202020202020202020202020202020206966202873656C6563';
wwv_flow_imp.g_varchar2_table(215) := '74696F6E5374796C654F7074732E706172746974696F6E427920262620706172746974696F6E427920213D3D206C61737453656C6563746564466561747572652E70726F706572746965735B73656C656374696F6E5374796C654F7074732E7061727469';
wwv_flow_imp.g_varchar2_table(216) := '74696F6E42795D29207B0D0A20202020202020202020202020202020202020202F2A20546865206C6173742073656C6563746564206665617475726520616E642074686520636C69636B656420666561747572652061726520696E20646966666572656E';
wwv_flow_imp.g_varchar2_table(217) := '7420706172746974696F6E732E20416464206A7573742074686520636C69636B656420666561747572652E202A2F0D0A20202020202020202020202020202020202020206164642E70757368286964293B0D0A2020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(218) := '207D20656C7365207B0D0A2020202020202020202020202020202020202020666F722028636F6E73742066656174206F6620666561747572657329207B0D0A20202020202020202020202020202020202020202020696620282173656C656374696F6E53';
wwv_flow_imp.g_varchar2_table(219) := '74796C654F7074732E706172746974696F6E4279207C7C20706172746974696F6E4279203D3D3D20666561742E70726F706572746965735B73656C656374696F6E5374796C654F7074732E706172746974696F6E42795D29207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(220) := '20202020202020202020202020202020636F6E7374206F203D20666561742E70726F706572746965735B73656C656374696F6E5374796C654F7074732E6F7264657242795D3B0D0A202020202020202020202020202020202020202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(221) := '74206C6173744F203D206C61737453656C6563746564466561747572652E70726F706572746965735B73656C656374696F6E5374796C654F7074732E6F7264657242795D3B0D0A2020202020202020202020202020202020202020202020206966202828';
wwv_flow_imp.g_varchar2_table(222) := '6F726465724279203E206C6173744F202626206F726465724279203E3D206F202626206F203E3D206C6173744F29207C7C20286F726465724279203C3D206C6173744F202626206F726465724279203C3D206F202626206F203C3D206C6173744F292920';
wwv_flow_imp.g_varchar2_table(223) := '7B0D0A20202020202020202020202020202020202020202020202020206164642E7075736828666561742E6964293B0D0A2020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020207D0D';
wwv_flow_imp.g_varchar2_table(224) := '0A20202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020207D0D0A0D0A0D0A20202020202020202020202020202020202073657453656C65637465644665617475726573286164642C202761646427293B0D';
wwv_flow_imp.g_varchar2_table(225) := '0A202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202073657453656C65637465644665617475726573285B69645D2C202773657427293B0D0A202020202020202020202020202020207D0D0A0D';
wwv_flow_imp.g_varchar2_table(226) := '0A202020202020202020202020202020206C61737453656C656374656446656174757265203D2065762E66656174757265735B305D3B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D293B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(227) := '7D0D0A20202020202020207D2063617463682028657863657074696F6E29207B0D0A20202020202020202020617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B6974656D49647D203A204661696C';
wwv_flow_imp.g_varchar2_table(228) := '656420746F20616464206C6179657220247B6C2E69647D602C20657863657074696F6E293B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A2020202020206C61796572494473203D206C61796572732E6D6170286C203D3E206C2E6964293B';
wwv_flow_imp.g_varchar2_table(229) := '0D0A0D0A2020202020207365744C61796572735669736962696C697479203D20287669736962696C69747929203D3E207B0D0A2020202020202020666F722028636F6E7374206C61796572206F66206C617965727329207B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(230) := '6D61702E7365744C61796F757450726F7065727479286C617965722E69642C20277669736962696C697479272C207669736962696C697479293B0D0A20202020202020207D0D0A202020202020202073746F726167652E7365744974656D28274D617062';
wwv_flow_imp.g_varchar2_table(231) := '6974735F4C6F6465737461724C617965725F27202B206974656D4964202B20275F7669736962696C697479272C207669736962696C697479293B0D0A20202020202020206C61796572735669736962696C697479203D207669736962696C6974793B0D0A';
wwv_flow_imp.g_varchar2_table(232) := '0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C207669736962696C697479203D3D3D202776697369626C6527293B0D0A0D0A';
wwv_flow_imp.g_varchar2_table(233) := '2020202020202020617065782E6576656E742E7472696767657228272327202B206974656D49642C20277669736962696C6974795F746F67676C6564272C207B0D0A2020202020202020202076697369626C653A207669736962696C697479203D3D3D20';
wwv_flow_imp.g_varchar2_table(234) := '2776697369626C65272C0D0A20202020202020207D293B0D0A2020202020207D0D0A0D0A202020202020696620286C61796572735669736962696C697479203D3D20276E6F6E652729207B0D0A20202020202020207365744C6179657273566973696269';
wwv_flow_imp.g_varchar2_table(235) := '6C69747928276E6F6E6527293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A2020202020207D20';
wwv_flow_imp.g_varchar2_table(236) := '656C7365207B0D0A20202020202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E7472792729';
wwv_flow_imp.g_varchar2_table(237) := '2E70726F702827636865636B6564272C2074727565293B0D0A2020202020207D0D0A0D0A202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E6368616E67652866756E6374696F';
wwv_flow_imp.g_varchar2_table(238) := '6E2865297B0D0A2020202020202020766172206362203D20617065782E6A51756572792874686973293B0D0A20202020202020207365744C61796572735669736962696C6974792863622E697328273A636865636B65642729203F202776697369626C65';
wwv_flow_imp.g_varchar2_table(239) := '27203A20276E6F6E6527293B0D0A2020202020207D293B0D0A0D0A202020202020666F722028636F6E73742066756E63206F662077616974466F724C6F616429207B0D0A202020202020202066756E6328293B0D0A2020202020207D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(240) := '77616974466F724C6F6164203D206E756C6C3B0D0A202020207D20656C7365207B0D0A2020202020202F2A20546865206C6179657273206861766520616C7265616479206265656E2061646465642C20627574206D6179206E65656420746F2062652075';
wwv_flow_imp.g_varchar2_table(241) := '706461746564202A2F0D0A2020202020206966202873656C656374696F6E4C61796572496429207B0D0A20202020202020202F2A207570646174652073656C656374696F6E2066696C746572202A2F0D0A20202020202020206D61702E73657446696C74';
wwv_flow_imp.g_varchar2_table(242) := '65722873656C656374696F6E4C6179657249642C2067657453656C6563746564466561747572657346696C7465722829293B0D0A2020202020207D0D0A202020207D0D0A20207D3B0D0A0D0A2020636F6E73742073657453656C65637465644665617475';
wwv_flow_imp.g_varchar2_table(243) := '726573203D202866656174757265732C20616374696F6E29203D3E207B0D0A202020206665617475726573203D206665617475726573203F3F205B5D3B0D0A202020206F6C6453656C656374696F6E203D2073656C656374656446656174757265733B0D';
wwv_flow_imp.g_varchar2_table(244) := '0A202020207377697463682028616374696F6E29207B0D0A202020202020636173652027736574273A0D0A202020202020202073656C65637465644665617475726573203D206E657720536574286665617475726573293B0D0A20202020202020206272';
wwv_flow_imp.g_varchar2_table(245) := '65616B3B0D0A202020202020636173652027616464273A0D0A20202020202020206966202873656C6563746564466561747572657329207B0D0A20202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A202020';
wwv_flow_imp.g_varchar2_table(246) := '20202020202020202073656C656374656446656174757265732E6164642866293B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020202020627265616B3B0D0A20202020202063617365202772656D6F7665273A0D0A202020';
wwv_flow_imp.g_varchar2_table(247) := '20202020206966202873656C6563746564466561747572657329207B0D0A20202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A20202020202020202020202073656C656374656446656174757265732E6465';
wwv_flow_imp.g_varchar2_table(248) := '6C6574652866293B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020202020627265616B3B0D0A202020202020636173652027746F67676C65273A0D0A20202020202020206966202873656C65637465644665617475726573';
wwv_flow_imp.g_varchar2_table(249) := '29207B0D0A20202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A2020202020202020202020206966202873656C656374656446656174757265732E68617328662929207B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(250) := '202073656C656374656446656174757265732E64656C6574652866293B0D0A2020202020202020202020207D20656C7365207B0D0A202020202020202020202020202073656C656374656446656174757265732E6164642866293B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(251) := '20202020207D0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020202020627265616B3B0D0A202020207D0D0A0D0A202020206966202867657453656C656374696F6E5374796C652829203D3D3D202770726F70657274792729';
wwv_flow_imp.g_varchar2_table(252) := '207B0D0A20202020202072656C6F6164536F757263654461746128293B0D0A202020207D20656C7365206966202873656C656374696F6E4C61796572496429207B0D0A20202020202070656E64696E674D61702E7468656E28286D617029203D3E207B0D';
wwv_flow_imp.g_varchar2_table(253) := '0A20202020202020206D61702E73657446696C7465722873656C656374696F6E4C6179657249642C2067657453656C6563746564466561747572657346696C7465722829293B0D0A2020202020207D293B0D0A202020207D0D0A0D0A2020202061706578';
wwv_flow_imp.g_varchar2_table(254) := '2E6576656E742E7472696767657228272327202B206974656D49642C202773656C656374696F6E5F6368616E67656427293B0D0A20207D3B0D0A0D0A2020636C6173732052656374616E676C6553656C656374436F6E74726F6C207B0D0A20202020636F';
wwv_flow_imp.g_varchar2_table(255) := '6E7374727563746F722829207B0D0A202020202020746869732E6C6179657273203D205B5D3B0D0A202020202020746869732E616374697665203D2066616C73653B0D0A202020207D0D0A0D0A202020206164644C61796572286C6179657229207B0D0A';
wwv_flow_imp.g_varchar2_table(256) := '202020202020746869732E6C61796572732E70757368286C61796572293B0D0A202020207D0D0A0D0A202020206F6E416464286D617029207B0D0A2020202020202F2A20746865203C6469763E207468617420666F726D73207468652073656C65637469';
wwv_flow_imp.g_varchar2_table(257) := '6F6E20626F78202A2F0D0A2020202020206C657420626F7853656C656374203D206E756C6C3B0D0A2020202020202F2A2074686520737461727420706F736974696F6E206F66207468652072656374616E676C652C20696E20706978656C20636F6F7264';
wwv_flow_imp.g_varchar2_table(258) := '696E61746573202A2F0D0A2020202020206C6574207374617274506F73203D206E756C6C3B0D0A2020202020202F2A2057652064697361626C652070616E6E696E6720746865206D6170207768696C6520796F752772652073656C656374696E672E2054';
wwv_flow_imp.g_varchar2_table(259) := '68697320736176657320746865207072696F722073746174650D0A20202020202020206F66207768657468657220796F7520636F756C642070616E20746865206D617020736F2077652063616E20726573746F726520697420636F72726563746C792E20';
wwv_flow_imp.g_varchar2_table(260) := '2A2F0D0A2020202020206C6574206472616750616E456E61626C6564203D2066616C73653B0D0A0D0A202020202020636F6E737420736574416374697665203D202861637469766529203D3E207B0D0A2020202020202020746869732E61637469766520';
wwv_flow_imp.g_varchar2_table(261) := '3D206163746976653B0D0A2020202020202020627574746F6E2E70726F702827617269612D70726573736564272C20746869732E616374697665293B0D0A2020202020202020627574746F6E2E746F67676C65436C61737328276D6170626974732D7265';
wwv_flow_imp.g_varchar2_table(262) := '63742D73656C6563742D627574746F6E2D746F67676C6564272C20746869732E616374697665293B0D0A20202020202020206D61702E676574436F6E7461696E657228292E636C6173734C6973742E746F67676C6528276D6170626974732D726563742D';
wwv_flow_imp.g_varchar2_table(263) := '73656C6563742D616374697665272C20746869732E616374697665293B0D0A20202020202020200D0A2020202020202020696620286472616750616E456E61626C656429207B0D0A202020202020202020206D61702E6472616750616E2E656E61626C65';
wwv_flow_imp.g_varchar2_table(264) := '28293B0D0A20202020202020207D0D0A2020202020207D3B0D0A0D0A202020202020636F6E737420627574746F6E203D202428603C627574746F6E20747970653D22627574746F6E22207374796C653D226C696E652D6865696768743A313670783B7769';
wwv_flow_imp.g_varchar2_table(265) := '6474683A333270783B6865696768743A333270783B223E3C6920636C6173733D2266612066612D6F626A6563742D67726F7570223E3C2F693E3C2F627574746F6E3E60290D0A20202020202020202E70726F7028277469746C65272C202752656374616E';
wwv_flow_imp.g_varchar2_table(266) := '676C652053656C65637427290D0A20202020202020202E70726F702827617269612D70726573736564272C20746869732E616374697665290D0A20202020202020202E6F6E2827636C69636B272C202829203D3E207B0D0A202020202020202020207365';
wwv_flow_imp.g_varchar2_table(267) := '744163746976652821746869732E616374697665293B0D0A20202020202020207D293B0D0A0D0A202020202020636F6E7374206D6F757365646F776E203D20286529203D3E207B0D0A20202020202020206966202821746869732E616374697665292072';
wwv_flow_imp.g_varchar2_table(268) := '657475726E3B0D0A202020202020202069662028626F7853656C65637420213D3D206E756C6C292072657475726E3B0D0A0D0A20202020202020207374617274506F73203D20652E706F696E743B0D0A0D0A2020202020202020626F7853656C65637420';
wwv_flow_imp.g_varchar2_table(269) := '3D202428603C64697620636C6173733D226D6170626974732D726563742D73656C6563742D626F78223E60293B0D0A20202020202020206D61702E676574436F6E7461696E657228292E617070656E644368696C6428626F7853656C6563745B305D293B';
wwv_flow_imp.g_varchar2_table(270) := '0D0A0D0A20202020202020206472616750616E456E61626C6564203D206D61702E6472616750616E2E6973456E61626C656428293B0D0A2020202020202020696620286472616750616E456E61626C656429207B0D0A202020202020202020206D61702E';
wwv_flow_imp.g_varchar2_table(271) := '6472616750616E2E64697361626C6528293B0D0A20202020202020207D0D0A2020202020207D3B0D0A0D0A202020202020636F6E7374206D6F7573656D6F7665203D20286529203D3E207B0D0A202020202020202069662028626F7853656C656374203D';
wwv_flow_imp.g_varchar2_table(272) := '3D3D206E756C6C292072657475726E3B0D0A20202020202020206966202821746869732E616374697665292072657475726E3B0D0A0D0A2020202020202020652E6F726967696E616C4576656E742E73746F7050726F7061676174696F6E28293B0D0A0D';
wwv_flow_imp.g_varchar2_table(273) := '0A2020202020202020636F6E7374206D696E58203D204D6174682E6D696E28652E706F696E742E782C207374617274506F732E78293B0D0A2020202020202020636F6E7374206D617858203D204D6174682E6D617828652E706F696E742E782C20737461';
wwv_flow_imp.g_varchar2_table(274) := '7274506F732E78293B0D0A2020202020202020636F6E7374206D696E59203D204D6174682E6D696E28652E706F696E742E792C207374617274506F732E79293B0D0A2020202020202020636F6E7374206D617859203D204D6174682E6D617828652E706F';
wwv_flow_imp.g_varchar2_table(275) := '696E742E792C207374617274506F732E79293B0D0A2020202020202020626F7853656C6563742E63737328277472616E73666F726D272C20607472616E736C61746528247B6D696E587D70782C20247B6D696E597D70782960293B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(276) := '20626F7853656C6563742E7769647468286D617858202D206D696E58293B0D0A2020202020202020626F7853656C6563742E686569676874286D617859202D206D696E59293B0D0A2020202020207D3B0D0A0D0A202020202020636F6E7374206D6F7573';
wwv_flow_imp.g_varchar2_table(277) := '657570203D20286529203D3E207B0D0A20202020202020206966202821746869732E616374697665292072657475726E3B0D0A0D0A202020202020202069662028626F7853656C65637420213D3D206E756C6C29207B0D0A20202020202020202020626F';
wwv_flow_imp.g_varchar2_table(278) := '7853656C6563745B305D2E706172656E744E6F64652E72656D6F76654368696C6428626F7853656C6563745B305D293B0D0A20202020202020202020626F7853656C656374203D206E756C6C3B0D0A20202020202020207D0D0A0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(279) := '636F6E7374206665617475726573203D206D61702E717565727952656E64657265644665617475726573285B652E706F696E742C207374617274506F735D293B0D0A2020202020202020636F6E737420696473203D206E65772053657428293B0D0A2020';
wwv_flow_imp.g_varchar2_table(280) := '202020202020666F722028636F6E73742066656174757265206F6620666561747572657329207B0D0A20202020202020202020696620286C617965724944732E696E636C7564657328666561747572652E6C617965722E69642929207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(281) := '202020202020206964732E61646428666561747572652E6964293B0D0A202020202020202020207D0D0A20202020202020207D0D0A202020202020202073657453656C656374656446656174757265732841727261792E66726F6D28696473292E6D6170';
wwv_flow_imp.g_varchar2_table(282) := '2878203D3E2069644D61702E676574287829292C20652E6F726967696E616C4576656E742E73686966744B6579203F202761646427203A202773657427293B0D0A0D0A20202020202020207365744163746976652866616C7365293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(283) := '7D3B0D0A0D0A2020202020206D61702E6F6E28276D6F757365646F776E272C206D6F757365646F776E293B0D0A2020202020206D61702E6F6E28276D6F7573656D6F7665272C206D6F7573656D6F7665293B0D0A2020202020206D61702E6F6E28276D6F';
wwv_flow_imp.g_varchar2_table(284) := '7573657570272C206D6F7573657570293B0D0A0D0A202020202020746869732E5F636C65616E7570203D202829203D3E207B0D0A20202020202020206D61702E6F666628276D6F757365646F776E272C206D6F757365646F776E293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(285) := '20206D61702E6F666628276D6F7573656D6F7665272C206D6F7573656D6F7665293B0D0A20202020202020206D61702E6F666628276D6F7573657570272C206D6F7573657570293B0D0A202020202020202069662028626F7853656C65637420213D3D20';
wwv_flow_imp.g_varchar2_table(286) := '6E756C6C29207B0D0A20202020202020202020626F7853656C6563745B305D2E706172656E744E6F64652E72656D6F76654368696C6428626F7853656C6563745B305D293B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A20202020202074';
wwv_flow_imp.g_varchar2_table(287) := '6869732E636F6E7461696E6572203D202428603C64697620636C6173733D226D61706C69627265676C2D6374726C206D61706C69627265676C2D6374726C2D67726F7570223E60290D0A20202020202020202E617070656E6428627574746F6E290D0A20';
wwv_flow_imp.g_varchar2_table(288) := '202020202020202E6765742830293B0D0A0D0A20202020202072657475726E20746869732E636F6E7461696E65723B0D0A202020207D0D0A0D0A202020206F6E52656D6F76652829207B0D0A202020202020746869732E5F636C65616E757028293B0D0A';
wwv_flow_imp.g_varchar2_table(289) := '202020202020746869732E636F6E7461696E65722E706172656E744E6F64652E72656D6F76654368696C6428746869732E636F6E7461696E6572293B0D0A202020207D0D0A20207D0D0A0D0A2020636F6E73742067656F6A736F6E426F756E6473203D20';
wwv_flow_imp.g_varchar2_table(290) := '2867656F6A736F6E29203D3E207B0D0A202020206C657420636F6F726473203D205B5D3B0D0A20202020737769746368202867656F6A736F6E2E7479706529207B0D0A2020202020206361736520274D756C7469506F6C79676F6E273A0D0A2020202020';
wwv_flow_imp.g_varchar2_table(291) := '202020636F6F726473203D2067656F6A736F6E2E636F6F7264696E617465732E666C61744D617028706F6C79203D3E20706F6C792E666C61744D61702872696E67203D3E2072696E6729293B0D0A2020202020202020627265616B3B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(292) := '636173652027506F6C79676F6E273A0D0A2020202020206361736520274D756C74694C696E65537472696E67273A0D0A2020202020202020636F6F726473203D2067656F6A736F6E2E636F6F7264696E617465732E666C61744D61702872696E67203D3E';
wwv_flow_imp.g_varchar2_table(293) := '2072696E67293B0D0A2020202020202020627265616B3B0D0A2020202020206361736520274C696E65537472696E67273A0D0A2020202020206361736520274D756C7469506F696E74273A0D0A2020202020202020636F6F726473203D2067656F6A736F';
wwv_flow_imp.g_varchar2_table(294) := '6E2E636F6F7264696E617465733B0D0A2020202020202020627265616B3B0D0A202020202020636173652027506F696E74273A0D0A2020202020202020636F6F726473203D205B67656F6A736F6E2E636F6F7264696E617465735D3B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(295) := '2020627265616B3B0D0A202020207D0D0A0D0A202020206C6574206D696E58203D204D6174682E6D696E282E2E2E28636F6F7264732E6D6170287879203D3E2078795B315D2929293B0D0A202020206C6574206D696E59203D204D6174682E6D696E282E';
wwv_flow_imp.g_varchar2_table(296) := '2E2E28636F6F7264732E6D6170287879203D3E2078795B305D2929293B0D0A202020206C6574206D617858203D204D6174682E6D6178282E2E2E28636F6F7264732E6D6170287879203D3E2078795B315D2929293B0D0A202020206C6574206D61785920';
wwv_flow_imp.g_varchar2_table(297) := '3D204D6174682E6D6178282E2E2E28636F6F7264732E6D6170287879203D3E2078795B305D2929293B0D0A0D0A2020202072657475726E205B5B6D696E592C206D696E585D2C205B6D6178592C206D6178585D5D3B0D0A20207D3B0D0A0D0A2020617065';
wwv_flow_imp.g_varchar2_table(298) := '782E6974656D2E637265617465280D0A202020206974656D49642C0D0A202020207B0D0A202020202020726566726573683A206173796E63202829203D3E207B0D0A20202020202020206177616974206C6F61644461746128293B0D0A2020202020207D';
wwv_flow_imp.g_varchar2_table(299) := '2C0D0A20202020202073686F773A202829203D3E207B0D0A20202020202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020207D2C0D0A202020202020686964653A202829203D3E207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(300) := '202020207365744C61796572735669736962696C69747928276E6F6E6527293B0D0A2020202020207D2C0D0A202020202020697356697369626C653A202829203D3E207B0D0A202020202020202072657475726E206C61796572735669736962696C6974';
wwv_flow_imp.g_varchar2_table(301) := '7920213D3D20276E6F6E65273B0D0A2020202020207D2C0D0A2020202020206861734944436F6C756D6E3A202829203D3E207B0D0A202020202020202072657475726E2021216964436F6C756D6E3B0D0A2020202020207D2C0D0A0D0A2020202020202F';
wwv_flow_imp.g_varchar2_table(302) := '2A2A0D0A202020202020202A2052657475726E73207472756520696620616E792065646974732068617665206265656E206D61646520746F20746865206C6179657220646174612E0D0A202020202020202A2F0D0A20202020202069734368616E676564';
wwv_flow_imp.g_varchar2_table(303) := '3A202829203D3E2065646974732E73697A65203E20302C0D0A0D0A2020202020202F2A20476574732074686520494473206F66207468652073656C65637465642066656174757265732E202A2F0D0A20202020202067657453656C656374656446656174';
wwv_flow_imp.g_varchar2_table(304) := '757265733A202829203D3E2073656C65637465644665617475726573203F2041727261792E66726F6D2873656C6563746564466561747572657329203A205B5D2C0D0A2020202020202F2A2053657420746865206C697374206F66206665617475726573';
wwv_flow_imp.g_varchar2_table(305) := '207468617420686176652061202273656C65637465642220617070656172616E63652E20606665617475726573602069732061206C6973740D0A2020202020202020206F662066656174757265204944732E202A2F0D0A20202020202073657453656C65';
wwv_flow_imp.g_varchar2_table(306) := '6374656446656174757265732C0D0A2020202020202F2A2053656C6563747320616C6C2066656174757265732063757272656E746C7920696E20746865206C617965722074686174206861766520616E2049442E202A2F0D0A20202020202073656C6563';
wwv_flow_imp.g_varchar2_table(307) := '74416C6C46656174757265733A202829203D3E207B0D0A2020202020202020696620287265736F6C766564536F757263654F7074696F6E7329207B0D0A2020202020202020202073657453656C65637465644665617475726573287265736F6C76656453';
wwv_flow_imp.g_varchar2_table(308) := '6F757263654F7074696F6E732E646174612E66656174757265732E6D61702866203D3E20662E6964292C202773657427293B0D0A20202020202020207D0D0A2020202020207D2C0D0A202020202020636C65617253656C656374696F6E3A202829203D3E';
wwv_flow_imp.g_varchar2_table(309) := '207B0D0A202020202020202073657453656C65637465644665617475726573285B5D2C202773657427293B0D0A2020202020207D2C0D0A0D0A20202020202073657453656C656374696F6E5374796C653A20287374796C652C206F70747329203D3E207B';
wwv_flow_imp.g_varchar2_table(310) := '0D0A20202020202020206966202873656C656374696F6E5374796C6529207B0D0A20202020202020202020636F6E736F6C652E6572726F72282743616E6E6F7420736574207468652073656C656374696F6E207374796C6520616674657220746865206D';
wwv_flow_imp.g_varchar2_table(311) := '617020686173206265656E20696E697469616C697A656427293B0D0A2020202020202020202072657475726E3B0D0A20202020202020207D0D0A202020202020202073656C656374696F6E5374796C65203D207374796C653B0D0A202020202020202073';
wwv_flow_imp.g_varchar2_table(312) := '656C656374696F6E5374796C654F707473203D206F707473203F3F207B7D3B0D0A0D0A2020202020202020666F722028636F6E7374206C61796572206F66206C61796572494473203F3F205B5D29207B0D0A20202020202020202020696620286973436C';
wwv_flow_imp.g_varchar2_table(313) := '69636B61626C65282929207B0D0A2020202020202020202020206D61702E5F5F6D6170626974735F6C617965725F637572736F72732E736574286C617965722C2027706F696E74657227293B0D0A202020202020202020207D20656C7365207B0D0A2020';
wwv_flow_imp.g_varchar2_table(314) := '202020202020202020206D61702E5F5F6D6170626974735F6C617965725F637572736F72732E64656C657465286C61796572293B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D2C0D0A0D0A2020202020202F2A2A0D';
wwv_flow_imp.g_varchar2_table(315) := '0A202020202020202A204D6F76657320746865206D617020626F756E64696E6720626F7820746F206669742074686520676976656E20666561747572652E0D0A202020202020202A2F0D0A2020202020207A6F6F6D546F466561747572653A206173796E';
wwv_flow_imp.g_varchar2_table(316) := '6320286665617475726549642C206F70747329203D3E207B0D0A2020202020202020636F6E73742066656174757265203D2066656174757265734D61702E67657428666561747572654964293B0D0A202020202020202069662028666561747572652920';
wwv_flow_imp.g_varchar2_table(317) := '7B0D0A202020202020202020202861776169742070656E64696E674D6170292E666974426F756E64732867656F6A736F6E426F756E647328666561747572652E67656F6D65747279292C206F707473293B0D0A20202020202020207D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(318) := '7D2C0D0A0D0A2020202020202F2A2A0D0A202020202020202A204765747320746865206C617965722064617461206173207265747269657665642066726F6D2074686520736F7572636520286E6F7420696E636C7564696E67206564697473292E0D0A20';
wwv_flow_imp.g_varchar2_table(319) := '2020202020202A2F0D0A202020202020676574536F75726365446174613A202829203D3E207B0D0A202020202020202072657475726E207265736F6C766564536F757263654F7074696F6E733F2E646174613B0D0A2020202020207D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(320) := '202F2A2A0D0A202020202020202A204765747320746865204944206F662074686520736F7572636520746861742077617320616464656420746F20746865204D61702E0D0A202020202020202A2F0D0A202020202020676574536F757263654E616D653A';
wwv_flow_imp.g_varchar2_table(321) := '202829203D3E20736F757263654E616D652C0D0A2020202020202F2A2A0D0A202020202020202A2052657475726E7320612050726F6D6973652074686174207265736F6C766573207768656E20746865206C6179657220686173206C6F616465642E0D0A';
wwv_flow_imp.g_varchar2_table(322) := '202020202020202A2F0D0A20202020202077616974466F724C6F61643A202829203D3E207B0D0A202020202020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(323) := '6966202877616974466F724C6F6164203D3D3D206E756C6C29207B0D0A2020202020202020202020207265736F6C766528293B0D0A202020202020202020207D20656C7365207B0D0A20202020202020202020202077616974466F724C6F61642E707573';
wwv_flow_imp.g_varchar2_table(324) := '68287265736F6C7665293B0D0A202020202020202020207D0D0A20202020202020207D293B0D0A2020202020207D2C0D0A2020202020202F2A2A0D0A202020202020202A20476574732061206C697374206F66207374796C65206C617965722049447320';
wwv_flow_imp.g_varchar2_table(325) := '616464656420746F20746865206D61702062792074686973204C6F646573746172206C617965722E0D0A202020202020202A2F0D0A2020202020206765744C617965724944733A202829203D3E207B0D0A202020202020202072657475726E206C617965';
wwv_flow_imp.g_varchar2_table(326) := '724944733B0D0A2020202020207D2C0D0A0D0A2020202020202F2A2A0D0A202020202020202A204765747320746865204D61704C6962726520474C204A53204D6170206F626A65637420666F7220746865206C617965722773206173736F636961746564';
wwv_flow_imp.g_varchar2_table(327) := '20726567696F6E2E0D0A202020202020202A20546865206D6170206D6179206E6F742068617665206C6F61646564207965742C20736F20746869732066756E6374696F6E2072657475726E7320612050726F6D6973652E0D0A202020202020202A2F0D0A';
wwv_flow_imp.g_varchar2_table(328) := '2020202020206765744D61703A206173796E63202829203D3E2061776169742070656E64696E674D61702C0D0A0D0A2020202020202F2A2A0D0A202020202020202A204170706C69657320616E206564697420746F206120666561747572652E20606163';
wwv_flow_imp.g_varchar2_table(329) := '74696F6E60206973206F6E65206F662027637265617465272C2027757064617465272C206F72202764656C657465272C20616E640D0A202020202020202A2060666561747572656020697320746865206E6577206F722065646974656420666561747572';
wwv_flow_imp.g_varchar2_table(330) := '652E204966207468652066656174757265206973206265696E672064656C657465642C207468656E206F6E6C79206974730D0A202020202020202A20276964272070726F7065727479206973206E65656465642E0D0A202020202020202A2F0D0A202020';
wwv_flow_imp.g_varchar2_table(331) := '20202065646974466561747572653A206173796E632028616374696F6E2C206665617475726529203D3E207B0D0A202020202020202069662028616374696F6E203D3D3D2027637265617465272026262021666561747572652E696429207B0D0A202020';
wwv_flow_imp.g_varchar2_table(332) := '202020202020202F2F206175746F2D61737369676E20612055554944206966207468652065646974206665617475726520686173206E6F2049440D0A20202020202020202020666561747572652E6964203D2063727970746F2E72616E646F6D55554944';
wwv_flow_imp.g_varchar2_table(333) := '28293B0D0A20202020202020207D0D0A0D0A2020202020202020636F6E7374206578697374696E67203D2065646974732E67657428666561747572652E6964293B0D0A2020202020202020696620286578697374696E67202626206578697374696E672E';
wwv_flow_imp.g_varchar2_table(334) := '616374696F6E203D3D3D20276372656174652729207B0D0A20202020202020202020696620286578697374696E672E616374696F6E203D3D3D20276372656174652720262620616374696F6E203D3D3D20277570646174652729207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(335) := '2020202020202F2F2065646974696E672061206E65772066656174757265207374696C6C20726573756C747320696E2061206E657720666561747572650D0A202020202020202020202020616374696F6E203D2027637265617465273B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(336) := '20202020207D20656C736520696620286578697374696E672E616374696F6E203D3D3D20276372656174652720262620616374696F6E203D3D3D202764656C6574652729207B0D0A2020202020202020202020202F2F2064656C6574696E672061206E65';
wwv_flow_imp.g_varchar2_table(337) := '77206665617475726520726573756C747320696E206E6F206368616E67650D0A20202020202020202020202065646974732E64656C65746528666561747572652E6964293B0D0A20202020202020202020202061776169742072656C6F6164536F757263';
wwv_flow_imp.g_varchar2_table(338) := '654461746128293B0D0A20202020202020202020202072657475726E3B0D0A202020202020202020207D0D0A20202020202020207D0D0A0D0A202020202020202065646974732E73657428666561747572652E69642C207B20616374696F6E2C20666561';
wwv_flow_imp.g_varchar2_table(339) := '74757265207D293B0D0A202020202020202061776169742072656C6F6164536F757263654461746128293B0D0A2020202020207D2C0D0A2020202020202F2A2A0D0A202020202020202A204765747320616E206172726179206F6620616C6C2065646974';
wwv_flow_imp.g_varchar2_table(340) := '7320746861742068617665206265656E206D6164652E0D0A202020202020202A2F0D0A20202020202067657445646974733A202829203D3E2041727261792E66726F6D2865646974732E76616C7565732829292C0D0A2020202020202F2A2A0D0A202020';
wwv_flow_imp.g_varchar2_table(341) := '202020202A204765747320746865206C6179657220646174612C2077697468206564697473206170706C6965642E0D0A202020202020202A2F0D0A202020202020676574456469746564446174613A202829203D3E20287B0D0A20202020202020207479';
wwv_flow_imp.g_varchar2_table(342) := '70653A202746656174757265436F6C6C656374696F6E272C0D0A202020202020202066656174757265732C0D0A2020202020207D292C0D0A0D0A2020202020202F2A2A0D0A202020202020202A20496E7465726E616C6C792C204D617062697473207061';
wwv_flow_imp.g_varchar2_table(343) := '737365732073657175656E7469616C2049447320746F204D61704C6962726520696E7374656164206F66207468652049447320696E2074686520736F7572636520646174612E205468697320697320626563617573650D0A202020202020202A204D6170';
wwv_flow_imp.g_varchar2_table(344) := '4C69627265206F6E6C7920737570706F72747320706F73697469766520696E7465676572204944732C206275742047656F4A534F4E20616C736F20737570706F72747320737472696E67732E204D61706269747320415049732072657475726E20746865';
wwv_flow_imp.g_varchar2_table(345) := '206F726967696E616C0D0A202020202020202A20736F75726365204944732C2062757420696620796F752067657420612066656174757265204944206469726563746C792066726F6D204D61704C696272652028652E672E207769746820717565727952';
wwv_flow_imp.g_varchar2_table(346) := '656E64657265644665617475726573292C207468656E20796F75206E65656420746F0D0A202020202020202A2075736520746869732066756E6374696F6E20746F206765742074686520736F757263652049442E0D0A202020202020202A2F0D0A202020';
wwv_flow_imp.g_varchar2_table(347) := '202020636F6E7665727449443A2028696429203D3E2069644D61702E676574286964292C0D0A0D0A2020202020202F2A2A0D0A202020202020202A2047657473206120666561747572652062792049442C20696E636C7564696E6720616E792065646974';
wwv_flow_imp.g_varchar2_table(348) := '732E0D0A202020202020202A2F0D0A202020202020676574466561747572653A2028696429203D3E2066656174757265734D61702E676574286964292C0D0A2020202020202F2A2A0D0A202020202020202A204765747320746865206564697420616374';
wwv_flow_imp.g_varchar2_table(349) := '696F6E202827637265617465272C2027757064617465272C202764656C657465272C206F7220276E6F6E65272920666F722074686520676976656E20666561747572652049442E0D0A202020202020202A2F0D0A20202020202067657446656174757265';
wwv_flow_imp.g_varchar2_table(350) := '45646974416374696F6E3A2028696429203D3E2065646974732E676574286964293F2E616374696F6E203F3F202866656174757265734D61702E67657428696429203F20276E6F6E6527203A206E756C6C292C0D0A0D0A202020202020636C6561724564';
wwv_flow_imp.g_varchar2_table(351) := '6974733A206173796E63202829203D3E207B0D0A202020202020202065646974732E636C65617228293B0D0A202020202020202061776169742072656C6F6164536F757263654461746128293B0D0A2020202020207D2C0D0A0D0A202020202020636C65';
wwv_flow_imp.g_varchar2_table(352) := '61724564697473416E64526566726573683A206173796E63202829203D3E207B0D0A202020202020202065646974732E636C65617228293B0D0A20202020202020206177616974206C6F61644461746128293B0D0A2020202020207D2C0D0A202020207D';
wwv_flow_imp.g_varchar2_table(353) := '0D0A2020293B0D0A0D0A20206C6F61644461746128293B0D0A0D0A20206C657420666972737452656672657368203D20747275653B0D0A2020617065782E6A51756572792827626F647927292E6F6E2827617065786265666F726572656672657368272C';
wwv_flow_imp.g_varchar2_table(354) := '206173796E632028657629203D3E207B0D0A202020206966202865762E746172676574203D3D3D20617065782E726567696F6E28726567696F6E4964292E656C656D656E745B305D29207B0D0A2020202020202F2A20536B697020746865206669727374';
wwv_flow_imp.g_varchar2_table(355) := '20617065786265666F726572656672657368206576656E742C2073696E6365207468617420636F72726573706F6E647320746F207468652070616765206C6F6164696E672C0D0A20202020202020202062757420776520616C72656164792063616C6C65';
wwv_flow_imp.g_varchar2_table(356) := '64206C6F61644461746128292061626F766520776974686F75742077616974696E6720666F7220746865206D617020746F206C6F61642E202A2F0D0A202020202020696620282166697273745265667265736829207B0D0A202020202020202061776169';
wwv_flow_imp.g_varchar2_table(357) := '74206C6F61644461746128293B0D0A2020202020207D20656C7365207B0D0A2020202020202020666972737452656672657368203D2066616C73653B0D0A2020202020207D0D0A202020207D0D0A20207D293B0D0A0D0A202069662028747970656F6620';
wwv_flow_imp.g_varchar2_table(358) := '696E69744A73203D3D3D202766756E6374696F6E2729207B0D0A20202020696E69744A7328617065782E6974656D286974656D496429293B0D0A20207D0D0A0D0A2020696620286974656D496420696E204D4150424954535F4C4F4445535441525F4C41';
wwv_flow_imp.g_varchar2_table(359) := '5945525F57414954494E4729207B0D0A20202020636F6E7374206974656D203D20617065782E6974656D286974656D4964293B0D0A202020204D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B6974656D49645D2E666F7245';
wwv_flow_imp.g_varchar2_table(360) := '61636828287829203D3E2078286974656D29293B0D0A20207D0D0A20204D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B6974656D49645D203D206E756C6C3B0D0A7D0D0A0D0A0D0A636F6E7374206D6170626974735F6C6F';
wwv_flow_imp.g_varchar2_table(361) := '6465737461725F74696E79736466203D206E6577206D6170626974735F74696E79736466287B0D0A2020666F6E7453697A653A2031362C0D0A2020666F6E7446616D696C793A2027466F6E74204150455820536D616C6C272C0D0A7D293B0D0A0D0A6675';
wwv_flow_imp.g_varchar2_table(362) := '6E6374696F6E206D6170626974735F6C6F6465737461725F696D6167655F68616E646C657228657629207B0D0A2020636F6E7374206D6C76657273696F6E203D20286D61706C69627265676C2E67657456657273696F6E3F2E2829203F3F206D61706C69';
wwv_flow_imp.g_varchar2_table(363) := '627265676C2E76657273696F6E292E73706C697428272E27292E6D61702878203D3E207061727365496E74287829293B0D0A0D0A202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020';
wwv_flow_imp.g_varchar2_table(364) := '20636F6E7374206D6170203D2065762E7461726765743B0D0A20202020696620286D61702E686173496D6167652865762E69642929207B0D0A2020202020207265736F6C766528293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20';
wwv_flow_imp.g_varchar2_table(365) := '2020206966202865762E69642E73746172747357697468282766612D272929207B0D0A2020202020202F2A20466967757265206F757420776861742063686172616374657220746869732069636F6E2075736573202A2F0D0A202020202020636F6E7374';
wwv_flow_imp.g_varchar2_table(366) := '207370616E203D20646F63756D656E742E637265617465456C656D656E7428277370616E27293B0D0A2020202020207370616E2E7374796C652E646973706C6179203D20276E6F6E65273B0D0A2020202020207370616E2E636C6173734C6973742E6164';
wwv_flow_imp.g_varchar2_table(367) := '642827666127293B0D0A2020202020207370616E2E636C6173734C6973742E6164642865762E6964293B0D0A2020202020202F2A2041646420746865207370616E20746F2074686520444F4D20736F20697473207374796C65732063616E20626520636F';
wwv_flow_imp.g_varchar2_table(368) := '6D7075746564202A2F0D0A2020202020206D61702E676574436F6E7461696E657228292E617070656E644368696C64287370616E293B0D0A2020202020202F2A20476574207468652069636F6E20636861726163746572202A2F0D0A202020202020636F';
wwv_flow_imp.g_varchar2_table(369) := '6E737420636F6D70757465645374796C65203D2077696E646F772E676574436F6D70757465645374796C65287370616E2C20273A6265666F726527293B0D0A202020202020636F6E73742069636F6E43686172203D20636F6D70757465645374796C652E';
wwv_flow_imp.g_varchar2_table(370) := '636F6E74656E742E737562737472696E6728312C2032293B0D0A2020202020207370616E2E72656D6F766528293B0D0A0D0A202020202020636F6E737420676C797068203D206D6170626974735F6C6F6465737461725F74696E797364662E6472617728';
wwv_flow_imp.g_varchar2_table(371) := '69636F6E43686172293B0D0A2020202020202F2A2041646420524742206368616E6E656C73202A2F0D0A202020202020636F6E7374207267626144617461203D206E65772055696E7438417272617928676C7970682E7769647468202A20676C7970682E';
wwv_flow_imp.g_varchar2_table(372) := '686569676874202A2034293B0D0A202020202020666F7220286C65742069203D20303B2069203C20676C7970682E646174612E6C656E6774683B2069202B2B29207B0D0A202020202020202072676261446174615B69202A2034202B20335D203D20676C';
wwv_flow_imp.g_varchar2_table(373) := '7970682E646174615B695D3B0D0A2020202020207D0D0A2020202020206D61702E616464496D6167652865762E69642C207B20646174613A2072676261446174612C2077696474683A20676C7970682E77696474682C206865696768743A20676C797068';
wwv_flow_imp.g_varchar2_table(374) := '2E686569676874207D2C207B7364663A20747275657D293B0D0A2020202020207265736F6C766528293B0D0A202020207D20656C7365206966202865762E69642E7374617274735769746828617065782E656E762E4150505F46494C45532929207B0D0A';
wwv_flow_imp.g_varchar2_table(375) := '202020202020696620286D6C76657273696F6E203E3D205B345D29207B0D0A20202020202020206D61702E6C6F6164496D6167652865762E6964292E7468656E2828696D6729203D3E207B0D0A2020202020202020202069662028216D61702E68617349';
wwv_flow_imp.g_varchar2_table(376) := '6D6167652865762E69642929207B0D0A2020202020202020202020206D61702E616464496D6167652865762E69642C20696D672E64617461293B0D0A202020202020202020207D0D0A202020202020202020207265736F6C766528293B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(377) := '2020207D293B0D0A2020202020207D20656C7365207B0D0A20202020202020206D61702E6C6F6164496D6167652865762E69642C20285F2C20696D6729203D3E207B0D0A2020202020202020202069662028216D61702E686173496D6167652865762E69';
wwv_flow_imp.g_varchar2_table(378) := '642929207B0D0A2020202020202020202020206D61702E616464496D6167652865762E69642C20696D67293B0D0A202020202020202020207D0D0A202020202020202020207265736F6C766528293B0D0A20202020202020207D293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(379) := '7D0D0A202020207D0D0A20207D293B0D0A7D3B0D0A';
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
