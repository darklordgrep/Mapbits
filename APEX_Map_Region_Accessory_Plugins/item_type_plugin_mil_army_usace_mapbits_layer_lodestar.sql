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
--   Date and Time:   20:00 Tuesday February 10, 2026
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 43432504464713289
--   Manifest End
--   Version:         24.2.4
--   Instance ID:     218369902185809
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_layer_lodestar
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(43432504464713289)
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
'  l_info_window_behavior varchar2(100) := p_item.attributes.get_varchar2(''info_window_behavior'');',
'  l_info_sidebar_behavior varchar2(100) := p_item.attributes.get_varchar2(''info_sidebar_behavior'');',
'  layer_def clob;',
'  l_clickable varchar2(5);',
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
'  select case when',
'    l_info_window_behavior in (''click'', ''hover'')',
'    or l_info_sidebar_behavior in (''click'', ''hover'')',
'    or exists (',
'      select 1 from apex_application_page_da where',
'        application_id = :APP_ID',
'        and page_id = :APP_PAGE_ID',
'        and ('','' || when_element || '','') like (''%,'' || p_item.name || '',%'')',
'        and when_event_internal_name = ''PLUGIN_MIL.ARMY.USACE.MAPBITS.LAYER.LODESTAR|ITEM TYPE|click''',
'    )',
'    or exists (',
'      select 1 from apex_application_page_items where',
'        application_id = :APP_ID',
'        and page_id = :APP_PAGE_ID',
'        and display_as_code = ''PLUGIN_MIL.ARMY.USACE.MAPBITS.LODESTAR_INFOWIN''',
'        and attribute_01 = p_item.name',
'    )',
'    then ''true'' else ''false'' end into l_clickable from dual;',
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
'    || apex_javascript.add_attribute(''title'', apex_plugin_util.replace_substitutions(l_title))',
'    || apex_javascript.add_attribute(''color'', l_color)',
'    || apex_javascript.add_attribute(''outlineColor'', l_outline_color)',
'    || apex_javascript.add_attribute(''opacity'', nvl(l_opacity, ''1''))',
'    || apex_javascript.add_attribute(''lineWidth'', p_item.attribute_16)',
'    || apex_javascript.add_attribute(''lineDashArray'', p_item.attribute_17)',
'    || apex_javascript.add_attribute(''fontSize'', p_item.attribute_18)',
'    || apex_javascript.add_attribute(''icon'', l_icon)',
'    || apex_javascript.add_attribute(''labelColumn'', l_label_column)',
'    || apex_javascript.add_attribute(''idColumn'', l_id_column)',
'    || apex_javascript.add_attribute(''submitItems'', l_submit_items)',
'    || apex_javascript.add_attribute(''sourceType'', l_source_type)',
'    || ''"clickable":'' || l_clickable || '',''',
'    || apex_javascript.add_attribute(''enableClustering'', p_item.attributes.get_varchar2(''enable_clustering'') = ''Y'')',
'    || apex_javascript.add_attribute(''clusterRadius'', p_item.attributes.get_number(''cluster_radius''))',
'    || apex_javascript.add_attribute(''clusterMaxZoom'', p_item.attributes.get_number(''cluster_max_zoom''))',
'    || apex_javascript.add_attribute(''clusterMinPoints'', p_item.attributes.get_number(''cluster_min_points''))',
'    || apex_javascript.add_attribute(''radius'', p_item.attributes.get_varchar2(''radius''))',
'    || apex_javascript.add_attribute(''fontStyle'', p_item.attributes.get_varchar2(''font_style''))',
'    || apex_javascript.add_attribute(''selectionColor'', p_item.attributes.get_varchar2(''selection_color''))',
'    || apex_javascript.add_attribute(''clickSelect'', p_item.attributes.get_varchar2(''click_select'') = ''Y'')',
'    || apex_javascript.add_attribute(''clickMultiSelect'', p_item.attributes.get_varchar2(''click_multi_select'') = ''Y'')',
'    || apex_javascript.add_attribute(''clickOrderBy'', p_item.attributes.get_varchar2(''click_order_by''))',
'    || apex_javascript.add_attribute(''clickPartitionBy'', p_item.attributes.get_varchar2(''click_partition_by''))',
'    || apex_javascript.add_attribute(''rectangleSelect'', p_item.attributes.get_varchar2(''rectangle_select'') = ''Y'')',
'    || apex_javascript.add_attribute(''infoWinBehavior'', l_info_window_behavior)',
'    || apex_javascript.add_attribute(''infoWinExpr'', p_item.attributes.get_varchar2(''html_expression''))',
'    || apex_javascript.add_attribute(''infoWinClickExpr'', p_item.attributes.get_varchar2(''click_info_win''))',
'    || apex_javascript.add_attribute(''sidebarBehavior'', l_info_sidebar_behavior)',
'    || apex_javascript.add_attribute(''sidebarExpr'', p_item.attributes.get_varchar2(''sidebar_html_expression''))',
'    || apex_javascript.add_attribute(''sidebarClickExpr'', p_item.attributes.get_varchar2(''click_sidebar''))',
'    || apex_javascript.add_attribute(''minzoom'', apex_plugin_util.replace_substitutions(p_item.attributes.get_number(''minzoom'')))',
'    || apex_javascript.add_attribute(''maxzoom'', apex_plugin_util.replace_substitutions(p_item.attributes.get_number(''maxzoom'')))',
'    || apex_javascript.add_attribute(''blur'', p_item.attributes.get_varchar2(''blur''))',
'    || apex_javascript.add_attribute(''initvisible'', p_item.attributes.get_varchar2(''initvisible'') = ''Y'')',
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
'  l_id_column varchar2(4000) := p_item.attribute_09;',
'  l_geometry_column varchar2(4000) := p_item.attribute_03;',
'  l_source_filter varchar2(4000) := p_item.attribute_15;',
'  l_centroid boolean := p_item.attributes.get_varchar2(''centroid'') = ''Y'';',
'',
'  l_geojson clob;',
'',
'  l_sql_query clob;',
'  l_columns apex_exec.t_columns;',
'  l_query_ctx apex_exec.t_context;',
'  ',
'  l_col_defs clob;',
'',
'  function build_sql_query(p_original_query clob, p_columns apex_exec.t_columns) return clob is',
'    l_query clob;',
'    l_n_cols number;',
'    l_id_col_idx number;',
'    l_geometry_col_idx number;',
'    l_props clob;',
'    l_column apex_exec.t_column;',
'    l_geom_query varchar2(1000);',
'    l_first_prop_col boolean := true;',
'  begin',
'    for l_idx in 1..p_columns.count loop',
'      l_column := p_columns(l_idx);',
'      if lower(l_column.name) = lower(l_geometry_column) then',
'        l_geometry_col_idx := l_idx;',
'',
'        case l_column.data_type',
'          when apex_exec.c_data_type_sdo_geometry then',
'            if l_centroid then',
'              l_geom_query := ''case when ('' || l_column.name || '').sdo_gtype in (2002, 3002, 2006, 3006) then ''',
'                -- line midpoint',
'                || ''sdo_lrs.convert_to_std_geom(sdo_lrs.locate_pt(sdo_lrs.convert_to_lrs_geom('' || l_column.name || ''), sdo_geom.sdo_length('' || l_column.name || '') / 2)) ''',
'                || ''else sdo_geom.sdo_centroid('' || l_column.name || '', cast(null as number)) end'';',
'            else',
'              l_geom_query := l_column.name;',
'            end if;',
'            l_geom_query := ''sdo_util.to_geojson(sdo_cs.transform('' || l_geom_query || '', 4326))'';',
'          when apex_exec.c_data_type_clob then',
'            l_geom_query := l_column.name;',
'          else',
'            raise_application_error(-20001, ''Wrong geometry column type. Expected sdo_geometry or clob.'');',
'        end case;',
'      elsif lower(l_column.name) = lower(l_id_column) then',
'        l_id_col_idx := l_idx;',
'      else',
'        l_props := l_props || (case when l_first_prop_col then '''' else '','' end) || l_column.name;',
'        l_col_defs := l_col_defs || (case when l_first_prop_col then '''' else '','' end) || ''{"name":"'' || apex_escape.json(l_column.name) || ''"}'';',
'        l_first_prop_col := false;',
'      end if;',
'    end loop;',
'',
'    if l_geometry_col_idx is null then',
'      raise_application_error(-20001, ''The geometry column ('' || l_geometry_column || '') is not present in the query.'');',
'    elsif l_id_col_idx is null and l_id_column is not null then',
'      raise_application_error(-20001, ''The ID column ('' || l_id_column || '') is not present in the query.'');',
'    end if;',
'',
'    l_query := ''with q as (',
'      '' || p_original_query || ''',
'      ) select json_arrayagg(',
'        json_object(',
'          '' || (case when l_id_col_idx is null then '''' else ''''''id'''' value '' || l_id_column || '','' end) || ''',
'          ''''type'''' value ''''Feature'''',',
'          ''''geometry'''' value ('' || l_geom_query || '') format json,',
'          ''''properties'''' value (json_object( '' || l_props || '' returning clob))',
'          returning clob',
'        )',
'        returning clob',
'      ) from q'';',
'',
'    return l_query;',
'  end;',
'begin',
'  if source_type = ''region_source'' then',
'    l_sql_query := (case when l_source_filter is not null then ''select * from ('' || apex_exec.c_data_source_table_name || '') where '' || l_source_filter else null end);',
'    l_query_ctx := apex_region.open_query_context(',
'      p_page_id => :APP_PAGE_ID,',
'      p_region_id => p_item.region_id,',
'      p_outer_sql => l_sql_query',
'    );',
'    for l_idx in 1..apex_exec.get_column_count(l_query_ctx) loop',
'      l_columns(l_idx) := apex_exec.get_column(l_query_ctx, l_idx);',
'    end loop;',
'    l_sql_query := build_sql_query(nvl(l_sql_query, apex_exec.c_data_source_table_name), l_columns);',
'    l_query_ctx := apex_region.open_query_context(',
'      p_page_id => :APP_PAGE_ID,',
'      p_region_id => p_item.region_id,',
'      p_outer_sql => l_sql_query',
'    );',
'  else',
'    l_columns := apex_exec.describe_query(',
'      p_location => apex_exec.c_location_local_db,',
'      p_sql_query => p_item.attribute_02',
'    );',
'    l_sql_query := build_sql_query(p_item.attribute_02, l_columns);',
'    l_query_ctx := apex_exec.open_query_context(',
'      p_location => apex_exec.c_location_local_db,',
'      p_sql_query => l_sql_query',
'    );',
'  end if;',
'',
'  htp.prn(''{"type":"FeatureCollection","columns":['');',
'  apex_util.prn(l_col_defs, false);',
'',
'  htp.p(''],"features":'');',
'',
'  if apex_exec.next_row(l_query_ctx) then',
'    l_geojson := apex_exec.get_clob(l_query_ctx, 1);',
'    apex_util.prn(nvl(l_geojson, ''[]''), false);',
'  end if;',
'  htp.prn(''}'');',
'end;',
''))
,p_api_version=>2
,p_render_function=>'mapbits_lodestarlayer'
,p_ajax_function=>'mapbits_lodestarlayer_ajax'
,p_standard_attributes=>'INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>false
,p_version_scn=>455282541
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits Lodestar Layer plugin provides an alternative map layer to Apex''s built-in layers. It includes advanced configuration options that expose the full power of MapLibre styling and labeling capability.'
,p_version_identifier=>'5.0.20260108'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 5 - Lodestar Layer',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_lodestar.sql 21386 2026-02-10 20:05:51Z b2eddjw9 $',
'Date     : $Date: 2026-02-10 14:05:51 -0600 (Tue, 10 Feb 2026) $',
'Revision : $Revision: 21386 $',
'Requires : Application Express >= 24.2',
'',
'Version 5 Updates:',
'12/23/2025 Significantly improve performance using dynamic SQL',
'12/01/2025 Allow column substitutions in most display attributes',
'11/26/2025 Added heatmap and circle layer types',
'11/26/2025 Added info window attributes, replacing the separate Info Window item plugin',
'11/26/2025 Added font style attribute',
'11/26/2025 Added clustering attributes (previously only configurable using JavaScript)',
'11/26/2025 Added selection attributes (previously only configurable using JavaScript)',
'11/06/2025 Added zoomToFeature() method',
'06/10/2025 Added rectangle select feature',
'05/30/2025 Added line width, dashes, and font size attributes',
'05/27/2025 Fixed AJAX item submission for Region Source sources',
'05/21/2025 Added Where Clause attribute for Region Source layers',
'',
'--------------------',
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
,p_files_version=>1240
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(314007179699449999)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_title=>'Source'
,p_display_sequence=>1
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(314054721588532702)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_title=>'Columns'
,p_display_sequence=>2
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(314007649250450000)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_title=>'Display'
,p_display_sequence=>3
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(327659813100926502)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_title=>'Label'
,p_display_sequence=>4
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(183228136923690794)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_title=>'Clustering'
,p_display_sequence=>5
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(183354500494455643)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_title=>'Selection'
,p_display_sequence=>6
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(183427139577413377)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_title=>'Info Window'
,p_display_sequence=>7
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(58813138194686451)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_title=>'Info Sidebar'
,p_display_sequence=>8
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43435073505713290)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_static_id=>'attribute_01'
,p_prompt=>'Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Name of the layer to display in the legend.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43435462958713290)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_static_id=>'attribute_02'
,p_prompt=>'Source Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43437897643713291)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'query'
,p_attribute_group_id=>wwv_flow_imp.id(314007179699449999)
,p_examples=>'select shape, usace_district_id from mb4_usace_districts'
,p_help_text=>'Source query used to define the layer. At a minimum this must include an sdo_geometry column or a clob column containing GeoJSON. Additional attributes should include a unique identifier column if labeling features or interaction with features is req'
||'uired. Any additional attributes that are included in the query can be used for constructing labels or other MapLibre attribute operations.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43435885555713290)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_static_id=>'attribute_03'
,p_prompt=>'Geometry Column'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43437897643713291)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'javascript'
,p_attribute_group_id=>wwv_flow_imp.id(314054721588532702)
,p_help_text=>'Column from the source query that represents the geometry as sdo_geometry objects or as clobs containing GeoJSON.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43436288807713291)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_static_id=>'attribute_04'
,p_prompt=>'MapLibre Layer Definition'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'custom'
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_help_text=>'A MapLibre layer definition. Can either be a JavaScript expression or a function that takes no arguments and returns the layer definition. See https://maplibre.org/maplibre-style-spec/layers/ for documentation.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43436665562713291)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_static_id=>'attribute_05'
,p_prompt=>'Icon'
,p_attribute_type=>'ICON'
,p_is_required=>false
,p_default_value=>'fa-map-marker'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'symbol,custom'
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'fa-circle',
'#APP_FILES#icon.png'))
,p_help_text=>'Icon used to symbolize features for a ''Symbol'' layer type. For a ''Custom'' layer type, this icon is only shown in the Legend. This can be a Font APEX icon or a path to an image in #APP_FILES#.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43437021788713291)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>45
,p_static_id=>'attribute_06'
,p_prompt=>'Color'
,p_attribute_type=>'COLOR'
,p_is_required=>true
,p_default_value=>'#0000FF'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'heatmap'
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_help_text=>'Color of features and of the checkbox in the legend. Custom layers can override this property.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43437467329713291)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_static_id=>'attribute_07'
,p_prompt=>'MapLibre Source Options'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(314007179699449999)
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
 p_id=>wwv_flow_imp.id(43437897643713291)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>15
,p_static_id=>'attribute_08'
,p_prompt=>'Source Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'query'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(314007179699449999)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43438221475713292)
,p_plugin_attribute_id=>wwv_flow_imp.id(43437897643713291)
,p_display_sequence=>10
,p_display_value=>'SQL Query'
,p_return_value=>'query'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43438732091713292)
,p_plugin_attribute_id=>wwv_flow_imp.id(43437897643713291)
,p_display_sequence=>20
,p_display_value=>'Region Source'
,p_return_value=>'region_source'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43439235503713292)
,p_plugin_attribute_id=>wwv_flow_imp.id(43437897643713291)
,p_display_sequence=>30
,p_display_value=>'JavaScript'
,p_return_value=>'javascript'
,p_help_text=>'The data is provided by JavaScript code in the Source Options attribute through the returned data property.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43439780386713292)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>25
,p_static_id=>'attribute_09'
,p_prompt=>'ID Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43437897643713291)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'javascript'
,p_attribute_group_id=>wwv_flow_imp.id(314054721588532702)
,p_help_text=>'Column from the source query that uniquely identifies the rows in the query. This is usually the primary key column.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43440139254713292)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>5
,p_static_id=>'attribute_10'
,p_prompt=>'Layer Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'symbol'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_help_text=>'Defines the layer type. ''Symbol'' is used for point features, ''Line'' for line features, and ''Fill'' for polygon features. Layer type selection toggles on the appropriate attributes for that layer types and toggles off the unrelated attributes. If more '
||'advanced configuration is needed, select the ''Custom Layer'' type to define the layer attributes with javascript.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43440558057713292)
,p_plugin_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_display_sequence=>10
,p_display_value=>'Symbol'
,p_return_value=>'symbol'
,p_is_quick_pick=>true
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43441099244713292)
,p_plugin_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_display_sequence=>20
,p_display_value=>'Line'
,p_return_value=>'line'
,p_is_quick_pick=>true
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43441506226713293)
,p_plugin_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_display_sequence=>30
,p_display_value=>'Fill'
,p_return_value=>'fill'
,p_is_quick_pick=>true
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43442012933713293)
,p_plugin_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_display_sequence=>40
,p_display_value=>'Circle'
,p_return_value=>'circle'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43442566377713293)
,p_plugin_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_display_sequence=>50
,p_display_value=>'Heatmap'
,p_return_value=>'heatmap'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43443040430713293)
,p_plugin_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_display_sequence=>60
,p_display_value=>'Custom'
,p_return_value=>'custom'
,p_is_quick_pick=>true
,p_help_text=>'Define a layer using a raw MapLibre layer definition. Mapbits will still provide some default settings.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43443561346713293)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_static_id=>'attribute_11'
,p_prompt=>'Label Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'symbol,line,circle'
,p_attribute_group_id=>wwv_flow_imp.id(327659813100926502)
,p_help_text=>'Column used to label features.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43443965704713294)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>47
,p_static_id=>'attribute_12'
,p_prompt=>'Opacity'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'1'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'custom'
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_help_text=>'A number between 0.0 and 1.0 that defines the opacity of the features, where 0.0 is completely transparent and 1.0 is completely opaque. Note that opacity is applied to individual features, not the layer as a whole.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43444338112713294)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>48
,p_static_id=>'attribute_13'
,p_prompt=>'Outline Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#000000'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_help_text=>'The outline color of the polygon, or the halo color of the symbol.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43444770723713294)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>21
,p_static_id=>'attribute_14'
,p_prompt=>'Page Items To Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43437897643713291)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'javascript,region_source'
,p_attribute_group_id=>wwv_flow_imp.id(314007179699449999)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43445186269713294)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_static_id=>'attribute_15'
,p_prompt=>'Where Clause'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43437897643713291)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'region_source'
,p_attribute_group_id=>wwv_flow_imp.id(314007179699449999)
,p_help_text=>'A SQL where clause to filter the region source.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43445564864713294)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>160
,p_static_id=>'attribute_16'
,p_prompt=>'Line Width'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'line'
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_help_text=>'The width of the line.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43445903085713294)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>170
,p_static_id=>'attribute_17'
,p_prompt=>'Dashes'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'line'
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_help_text=>'Create dashed lines by entering the lengths of dashes and gaps. Enter the numbers separated by spaces.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43446349706713294)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>180
,p_static_id=>'attribute_18'
,p_prompt=>'Font Size'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'symbol,circle,custom'
,p_attribute_group_id=>wwv_flow_imp.id(327659813100926502)
,p_help_text=>'The size of the font to use for the label.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43446733602713295)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>19
,p_display_sequence=>190
,p_static_id=>'enable_clustering'
,p_prompt=>'Enable Clustering'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(183228136923690794)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43447190920713295)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>20
,p_display_sequence=>200
,p_static_id=>'cluster_radius'
,p_prompt=>'Cluster Radius'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43446733602713295)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(183228136923690794)
,p_help_text=>'The radius of each cluster. A value of 512 indicates a radius equal to the width of a tile.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43447577425713295)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>21
,p_display_sequence=>210
,p_static_id=>'cluster_max_zoom'
,p_prompt=>'Max Zoom'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43446733602713295)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(183228136923690794)
,p_help_text=>'The maximum zoom level at which to cluster features. Above this zoom level, all features are displayed individually.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43447906774713295)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>22
,p_display_sequence=>220
,p_static_id=>'cluster_min_points'
,p_prompt=>'Minimum Points'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43446733602713295)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(183228136923690794)
,p_help_text=>'The minimum number of points to cluster together. If a cluster would contain fewer than this many features, they will be left as separate features.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43448335263713295)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>23
,p_display_sequence=>230
,p_static_id=>'radius'
,p_prompt=>'Radius'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'circle,heatmap'
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_help_text=>'The radius of a circle, or the radius of influence of a point in a heatmap.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43448701998713295)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>24
,p_display_sequence=>240
,p_static_id=>'font_style'
,p_prompt=>'Font Style'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'regular'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(327659813100926502)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43449184185713295)
,p_plugin_attribute_id=>wwv_flow_imp.id(43448701998713295)
,p_display_sequence=>10
,p_display_value=>'Regular'
,p_return_value=>'regular'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43449666168713296)
,p_plugin_attribute_id=>wwv_flow_imp.id(43448701998713295)
,p_display_sequence=>20
,p_display_value=>'Bold'
,p_return_value=>'bold'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43450190608713296)
,p_plugin_attribute_id=>wwv_flow_imp.id(43448701998713295)
,p_display_sequence=>30
,p_display_value=>'Italic'
,p_return_value=>'italic'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43450687154713296)
,p_plugin_attribute_id=>wwv_flow_imp.id(43448701998713295)
,p_display_sequence=>40
,p_display_value=>'Bold Italic'
,p_return_value=>'bold_italic'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43451178476713296)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>25
,p_display_sequence=>250
,p_static_id=>'click_select'
,p_prompt=>'Click to Select'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(183354500494455643)
,p_help_text=>'Whether selecting features by clicking is enabled.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43451570686713296)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>26
,p_display_sequence=>260
,p_static_id=>'click_multi_select'
,p_prompt=>'Multi-Select'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43451178476713296)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(183354500494455643)
,p_help_text=>'Whether multiple features can be selected using Ctrl and/or Shift keys while clicking.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43451973590713296)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>27
,p_display_sequence=>270
,p_static_id=>'click_order_by'
,p_prompt=>'Order By Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43451570686713296)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(183354500494455643)
,p_help_text=>'A column to order features by for the purposes of multi-select. If given, multiple features can be selected by holding Shift while clicking, and the features from the existing selection to the clicked one--in the order specified by this column--will '
||'all be selected.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43452362132713296)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>28
,p_display_sequence=>280
,p_static_id=>'click_partition_by'
,p_prompt=>'Partition By Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43451570686713296)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(183354500494455643)
,p_help_text=>'A column to partition features by when selecting multiple features by holding Shift. Only features with the same partition value as the previously clicked feature will be added to the selection.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43452768689713297)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>29
,p_display_sequence=>0
,p_static_id=>'selection_color'
,p_prompt=>'Selection Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#05fadd'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(183354500494455643)
,p_help_text=>'The color to outline selected features.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43453102180713297)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>30
,p_display_sequence=>300
,p_static_id=>'rectangle_select'
,p_prompt=>'Rectangle Select'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(183354500494455643)
,p_help_text=>'Whether to enable the Rectangle Select control, which allows you to select multiple features by drawing a rectangle over the map.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43453526443713297)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>31
,p_display_sequence=>310
,p_static_id=>'html_expression'
,p_prompt=>'HTML Expression'
,p_attribute_type=>'HTML'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43453931697713297)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_NULL'
,p_attribute_group_id=>wwv_flow_imp.id(183427139577413377)
,p_help_text=>'HTML template to display an info window when you hover or click the feature.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43453931697713297)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>32
,p_display_sequence=>0
,p_static_id=>'info_window_behavior'
,p_prompt=>'Behavior'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(183427139577413377)
,p_null_text=>'No Info Window'
,p_help_text=>'The behavior of the layer''s info window.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43454393651713297)
,p_plugin_attribute_id=>wwv_flow_imp.id(43453931697713297)
,p_display_sequence=>10
,p_display_value=>'On Hover & Click'
,p_return_value=>'hover'
,p_help_text=>'The popup appears when you hover over the feature, and stays in place if you click the feature.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43454897752713297)
,p_plugin_attribute_id=>wwv_flow_imp.id(43453931697713297)
,p_display_sequence=>20
,p_display_value=>'On Click'
,p_return_value=>'click'
,p_help_text=>'The popup appears when you click on the feature and stays until you click away from it.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43455343012713298)
,p_plugin_attribute_id=>wwv_flow_imp.id(43453931697713297)
,p_display_sequence=>30
,p_display_value=>'On Hover'
,p_return_value=>'hover_only'
,p_help_text=>'The popup appears while the cursor is over the feature.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43455823260713298)
,p_plugin_attribute_id=>wwv_flow_imp.id(43453931697713297)
,p_display_sequence=>40
,p_display_value=>'Separate Hover & Click'
,p_return_value=>'separate'
,p_help_text=>'Use two different templates when the feature is hovered vs. clicked.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43456306547713298)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>33
,p_display_sequence=>330
,p_static_id=>'click_info_win'
,p_prompt=>'Click HTML Expression'
,p_attribute_type=>'HTML'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43453931697713297)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'separate'
,p_attribute_group_id=>wwv_flow_imp.id(183427139577413377)
,p_help_text=>'The HTML template to use in the popup when the feature is clicked.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43456742543713298)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>34
,p_display_sequence=>340
,p_static_id=>'minzoom'
,p_prompt=>'Min Zoom'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'The minimum zoom level to display the layer at'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43457172824713298)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>35
,p_display_sequence=>350
,p_static_id=>'maxzoom'
,p_prompt=>'Max Zoom'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'The maximum zoom level the layer is visible at'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43457521532713298)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>36
,p_display_sequence=>360
,p_static_id=>'centroid'
,p_prompt=>'Convert to Point'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(314007179699449999)
,p_help_text=>'Convert the geometries to points, suitable for labelling. For points and polygons, the centroid is used. For lines, the midpoint is used.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43457960256713298)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>38
,p_display_sequence=>380
,p_static_id=>'initvisible'
,p_prompt=>'Initially Visible'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Whether the layer is shown by default.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43458394526713299)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>39
,p_display_sequence=>390
,p_static_id=>'blur'
,p_prompt=>'Blur'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43440139254713292)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'circle'
,p_attribute_group_id=>wwv_flow_imp.id(314007649250450000)
,p_help_text=>'The amount of blur applied to the circle. 0 is no blur, and 1 means only the center is full opacity.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(58813641394690377)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>40
,p_display_sequence=>400
,p_static_id=>'info_sidebar_behavior'
,p_prompt=>'Behavior'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(58813138194686451)
,p_null_text=>'No Sidebar'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(58837037319703979)
,p_plugin_attribute_id=>wwv_flow_imp.id(58813641394690377)
,p_display_sequence=>10
,p_display_value=>'On Hover & Click'
,p_return_value=>'hover'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(58837403912704606)
,p_plugin_attribute_id=>wwv_flow_imp.id(58813641394690377)
,p_display_sequence=>20
,p_display_value=>'On Click'
,p_return_value=>'click'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(58837861130705197)
,p_plugin_attribute_id=>wwv_flow_imp.id(58813641394690377)
,p_display_sequence=>30
,p_display_value=>'On Hover'
,p_return_value=>'hover_only'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(58838291692705985)
,p_plugin_attribute_id=>wwv_flow_imp.id(58813641394690377)
,p_display_sequence=>40
,p_display_value=>'Separate Hover & Click'
,p_return_value=>'separate'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(58817589478693722)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>41
,p_display_sequence=>410
,p_static_id=>'sidebar_html_expression'
,p_prompt=>'HTML Expression'
,p_attribute_type=>'HTML'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(58813641394690377)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_NULL'
,p_attribute_group_id=>wwv_flow_imp.id(58813138194686451)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(58821474113696746)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>42
,p_display_sequence=>420
,p_static_id=>'click_sidebar'
,p_prompt=>'Click HTML Expression'
,p_attribute_type=>'HTML'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(58813641394690377)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'separate'
,p_attribute_group_id=>wwv_flow_imp.id(58813138194686451)
);
wwv_flow_imp_shared.create_plugin_std_attribute(
 p_id=>wwv_flow_imp.id(43465668237713303)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43466016262713303)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_name=>'click'
,p_display_name=>'Feature Clicked'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43466449507713303)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_name=>'load_end'
,p_display_name=>'Loading Finished'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43466893223713303)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_name=>'load_start'
,p_display_name=>'Loading Started'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43467273685713304)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_name=>'selection_changed'
,p_display_name=>'Selection Changed'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43467613040713304)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
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
wwv_flow_imp.g_varchar2_table(4) := '6374697665202E6D61706C69627265676C2D63616E7661732D636F6E7461696E6572207B0D0A2020637572736F723A2063726F7373686169723B0D0A7D0D0A0D0A2E6D6170626974732D686F7665722D706F707570202E6D61706C69627265676C2D706F';
wwv_flow_imp.g_varchar2_table(5) := '7075702D636F6E74656E74207B0D0A20202F2A204D616B6520737572652074686520686F76657220706F7075702069732022696E76697369626C652220746F206D6F757365206576656E74732E204F74686572776973652C206966207468652063757273';
wwv_flow_imp.g_varchar2_table(6) := '6F720D0A2020202020736C697073207768696C65207363726F6C6C696E6720616E6420676F6573206F7665722074686520706F7075702C2069742077696C6C207363726F6C6C2074686520706167652E202A2F0D0A2020706F696E7465722D6576656E74';
wwv_flow_imp.g_varchar2_table(7) := '733A206E6F6E653B0D0A7D0D0A0D0A2E6D6170626974732D73696465626172207B0D0A2020706F736974696F6E3A206162736F6C7574653B0D0A2020746F703A20766172282D2D6D6170626974732D736964656261722D746F702C20307078293B0D0A20';
wwv_flow_imp.g_varchar2_table(8) := '20626F74746F6D3A20766172282D2D6D6170626974732D736964656261722D626F74746F6D2C20307078293B0D0A20206D617267696E2D746F703A20766172282D2D6D672D746F702D6C6566742D6374726C2D6D617267696E2D792C2031327078293B0D';
wwv_flow_imp.g_varchar2_table(9) := '0A20206D617267696E2D626F74746F6D3A20766172282D2D6D672D746F702D6C6566742D6374726C2D6D617267696E2D792C2031327078293B0D0A20206D617267696E2D6C6566743A20766172282D2D6D672D746F702D6C6566742D6374726C2D6D6172';
wwv_flow_imp.g_varchar2_table(10) := '67696E2D782C2031327078293B0D0A20206D617267696E2D72696768743A20766172282D2D6D672D746F702D6C6566742D6374726C2D6D617267696E2D782C2031327078293B0D0A2020706F696E7465722D6576656E74733A206E6F6E653B0D0A7D0D0A';
wwv_flow_imp.g_varchar2_table(11) := '0D0A2E6D6170626974732D736964656261722D70616E656C207B0D0A2020706F696E7465722D6576656E74733A206175746F3B0D0A20206261636B67726F756E642D636F6C6F723A2077686974653B0D0A2020626F726465723A2031707820736F6C6964';
wwv_flow_imp.g_varchar2_table(12) := '207267626128302C20302C20302C20302E31293B0D0A2020626F726465722D7261646975733A203870783B0D0A20206F766572666C6F773A2068696464656E3B0D0A2020646973706C61793A20666C65783B0D0A20206D61782D6865696768743A203130';
wwv_flow_imp.g_varchar2_table(13) := '30253B0D0A7D0D0A0D0A2E6D6170626974732D73696465626172202E6D6170626974732D696E666F2D636F6E74656E74207B0D0A20206F766572666C6F773A206175746F3B0D0A20206D61782D6865696768743A20313030253B0D0A202070616464696E';
wwv_flow_imp.g_varchar2_table(14) := '673A20302E3572656D3B0D0A202077696474683A20313030253B0D0A7D0D0A0D0A2E6D6170626974732D736964656261722E6D6170626974732D736964656261722D636C6F736561626C65202E6D6170626974732D736964656261722D636C6F7365207B';
wwv_flow_imp.g_varchar2_table(15) := '0D0A2020646973706C61793A20626C6F636B3B0D0A7D0D0A0D0A2E6D6170626974732D73696465626172202E6D6170626974732D736964656261722D636C6F7365207B0D0A2020646973706C61793A206E6F6E653B0D0A2020706F696E7465722D657665';
wwv_flow_imp.g_varchar2_table(16) := '6E74733A206175746F3B0D0A2020637572736F723A20706F696E7465723B0D0A20206261636B67726F756E643A2072676261283235352C203235352C203235352C20302E3735293B0D0A2020626F726465723A2031707820736F6C696420726762612830';
wwv_flow_imp.g_varchar2_table(17) := '2C20302C20302C20302E31293B0D0A2020626F726465722D7261646975733A203470783B0D0A2020706F736974696F6E3A206162736F6C7574653B0D0A2020746F703A20303B0D0A202072696768743A202D3470783B0D0A20207472616E736C6174653A';
wwv_flow_imp.g_varchar2_table(18) := '2063616C6328313030252920303B0D0A7D0D0A0D0A2E6D6170626974732D696E666F2D636F6E74656E74207461626C65207468207B0D0A2020746578742D616C69676E3A2072696768743B0D0A202070616464696E672D72696768743A202E35656D3B0D';
wwv_flow_imp.g_varchar2_table(19) := '0A7D0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43468000758713304)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_file_name=>'mapbits-lodestarlayer.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F4C4F4445535441525F4C415945525F57414954494E47203D207B7D3B0D0A0D0A66756E6374696F6E206D6170626974735F6C6F6465737461726C617965725F776169745F666F725F696E6974286974656D496429207B';
wwv_flow_imp.g_varchar2_table(2) := '0D0A202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020206966202821286974656D496420696E204D4150424954535F4C4F4445535441525F4C415945525F57414954494E47292920';
wwv_flow_imp.g_varchar2_table(3) := '7B0D0A2020202020204D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B6974656D49645D203D205B5D3B0D0A202020207D0D0A0D0A20202020696620284D4150424954535F4C4F4445535441525F4C415945525F5741495449';
wwv_flow_imp.g_varchar2_table(4) := '4E475B6974656D49645D203D3D3D206E756C6C29207B0D0A2020202020207265736F6C766528617065782E6974656D286974656D496429293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A202020204D4150424954535F4C4F444553';
wwv_flow_imp.g_varchar2_table(5) := '5441525F4C415945525F57414954494E475B6974656D49645D2E7075736828286974656D29203D3E207B0D0A2020202020207265736F6C7665286974656D293B0D0A202020207D293B0D0A20207D290D0A7D0D0A0D0A0D0A66756E6374696F6E206D6170';
wwv_flow_imp.g_varchar2_table(6) := '626974735F6C6F6465737461726C61796572287B0D0A20206974656D49642C20616A61784964656E7469666965722C20726567696F6E49642C206C61796572547970652C206C6162656C436F6C756D6E2C206C61796572446566696E6974696F6E2C2073';
wwv_flow_imp.g_varchar2_table(7) := '657175656E63654E756D6265722C207469746C652C20636F6C6F722C206F7061636974792C206F75746C696E65436F6C6F722C2069636F6E2C0D0A2020736F757263654F7074696F6E732C206964436F6C756D6E2C20636C69636B61626C652C20737562';
wwv_flow_imp.g_varchar2_table(8) := '6D69744974656D732C20736F75726365547970652C20696E69744A732C206C696E6557696474682C206C696E654461736841727261792C20666F6E7453697A652C0D0A2020656E61626C65436C7573746572696E672C20636C7573746572526164697573';
wwv_flow_imp.g_varchar2_table(9) := '2C20636C75737465724D61785A6F6F6D2C20636C75737465724D696E506F696E74732C207261646975732C20666F6E745374796C652C2073656C656374696F6E436F6C6F722C20636C69636B53656C6563742C20636C69636B4D756C746953656C656374';
wwv_flow_imp.g_varchar2_table(10) := '2C0D0A2020636C69636B4F7264657242792C20636C69636B506172746974696F6E42792C2072656374616E676C6553656C6563742C206C696E6B2C20696E666F57696E4265686176696F722C20696E666F57696E457870722C20696E666F57696E436C69';
wwv_flow_imp.g_varchar2_table(11) := '636B457870722C20736964656261724265686176696F722C2073696465626172457870722C2073696465626172436C69636B457870722C206D696E7A6F6F6D2C206D61787A6F6F6D2C20626C75722C20696E697476697369626C652C0D0A7D29207B0D0A';
wwv_flow_imp.g_varchar2_table(12) := '20206966202821726567696F6E496429207B0D0A20202020617065782E64656275672E6572726F7228276D6170626974735F6C6F6465737461726C617965722027202B206974656D4964202B2027203A204974656D206973206E6F7420696E2061207265';
wwv_flow_imp.g_varchar2_table(13) := '67696F6E2E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A2020636F6E73742073746F72616765203D20617065782E73746F726167652E67657453636F7065644C6F63616C53746F72616765287B2075736541707049643A20747275652C';
wwv_flow_imp.g_varchar2_table(14) := '207573655061676549643A20747275652C20726567696F6E4964207D293B0D0A0D0A20206C65742077616974466F724C6F6164203D205B5D3B0D0A0D0A2020636F6E737420736F757263654E616D65203D206974656D4964202B20272D736F7572636527';
wwv_flow_imp.g_varchar2_table(15) := '3B0D0A0D0A20206C6574206C61796572735669736962696C697479203D2073746F726167652E6765744974656D28274D6170626974735F4C6F6465737461724C617965725F27202B206974656D4964202B20275F7669736962696C6974792729203F3F20';
wwv_flow_imp.g_varchar2_table(16) := '28696E697476697369626C65203F202776697369626C6527203A20276E6F6E6527293B0D0A0D0A20206C6574207265736F6C766564536F757263654F7074696F6E733B0D0A20206C65742073656C65637465644665617475726573203D206E756C6C3B0D';
wwv_flow_imp.g_varchar2_table(17) := '0A0D0A20206C6574207365744C61796572735669736962696C697479203D20287669736962696C69747929203D3E207B0D0A202020206C61796572735669736962696C697479203D207669736962696C6974793B0D0A20207D3B0D0A0D0A20206C657420';
wwv_flow_imp.g_varchar2_table(18) := '6C61796572494473203D206E756C6C3B0D0A0D0A20206C6574206665617475726573203D205B5D3B0D0A2020636F6E73742066656174757265734D6170203D206E6577204D617028293B0D0A2020636F6E7374206564697473203D206E6577204D617028';
wwv_flow_imp.g_varchar2_table(19) := '293B0D0A20202F2A204D6170206F66207468652077686F6C65206E756D62657220494473207765207061737320746F204D61706C696272652C20746F20746865206F726967696E616C20736F75726365204944732E202A2F0D0A2020636F6E7374206964';
wwv_flow_imp.g_varchar2_table(20) := '4D6170203D206E6577204D617028293B0D0A2020636F6E73742069644D6170526576203D206E6577204D617028293B0D0A0D0A20206966202828636C69636B53656C656374207C7C2072656374616E676C6553656C6563742920262620216964436F6C75';
wwv_flow_imp.g_varchar2_table(21) := '6D6E29207B0D0A20202020636F6E736F6C652E7761726E28605B247B6974656D49647D5D205761726E696E673A2053656C656374696F6E2077696C6C206E6F7420776F726B20776974686F757420616E20494420636F6C756D6E21205468652049442069';
wwv_flow_imp.g_varchar2_table(22) := '73206E656564656420746F20747261636B207768696368206665617475726573206172652073656C65637465642E60293B0D0A20207D0D0A0D0A2020636F6E73742067657453656C6563746564466561747572657346696C746572203D202829203D3E20';
wwv_flow_imp.g_varchar2_table(23) := '7B0D0A20202020696620282173656C6563746564466561747572657329207B0D0A20202020202072657475726E2066616C73653B0D0A202020207D0D0A0D0A20202020636F6E73742066656174757265496473203D2041727261792E66726F6D2873656C';
wwv_flow_imp.g_varchar2_table(24) := '65637465644665617475726573292E6D61702878203D3E2069644D61705265762E676574287829292E66696C7465722878203D3E20747970656F66207820213D3D2027756E646566696E656427293B0D0A20202020636F6E73742073696E676C6546696C';
wwv_flow_imp.g_varchar2_table(25) := '746572203D205B27696E272C205B276964275D2C205B276C69746572616C272C20666561747572654964735D5D3B0D0A2020202072657475726E2073696E676C6546696C7465723B0D0A20207D3B0D0A0D0A20206C65742073656C656374696F6E537479';
wwv_flow_imp.g_varchar2_table(26) := '6C65203D206E756C6C3B0D0A2020636F6E73742067657453656C656374696F6E5374796C65203D202829203D3E207B0D0A20202020696620282173656C656374696F6E5374796C6529207B0D0A20202020202073656C656374696F6E5374796C65203D20';
wwv_flow_imp.g_varchar2_table(27) := '276175746F273B0D0A202020207D0D0A2020202072657475726E2073656C656374696F6E5374796C653B0D0A20207D3B0D0A20206C65742073656C656374696F6E5374796C654F707473203D207B7D3B0D0A20206C65742075706461746553656C656374';
wwv_flow_imp.g_varchar2_table(28) := '696F6E4C6179657273203D206E756C6C3B0D0A0D0A2020636F6E7374206973436C69636B61626C65203D202829203D3E20636C69636B61626C65207C7C20636C69636B53656C656374207C7C206C696E6B207C7C205B27636C69636B272C2027686F7665';
wwv_flow_imp.g_varchar2_table(29) := '72272C20277365706172617465275D2E696E636C7564657328696E666F57696E4265686176696F72293B0D0A0D0A2020636F6E73742070656E64696E674D6170203D206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E20';
wwv_flow_imp.g_varchar2_table(30) := '7B0D0A20202020636F6E737420726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0D0A2020202069662028726567696F6E203D3D206E756C6C29207B0D0A202020202020617065782E64656275672E6572726F7228276D6170';
wwv_flow_imp.g_varchar2_table(31) := '626974735F6C6F6465737461726C617965722027202B206974656D4964202B2027203A20526567696F6E205B27202B20726567696F6E4964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A20202020202072656A656374';
wwv_flow_imp.g_varchar2_table(32) := '28293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20202020726567696F6E2E656C656D656E742E6F6E28277370617469616C6D6170696E697469616C697A6564272C202829203D3E207B0D0A202020202020636F6E7374206D6170';
wwv_flow_imp.g_varchar2_table(33) := '203D20617065782E726567696F6E28726567696F6E4964292E63616C6C28276765744D61704F626A65637427293B0D0A2020202020207265736F6C7665286D6170293B0D0A202020207D293B0D0A20207D292E7468656E28286D617029203D3E207B0D0A';
wwv_flow_imp.g_varchar2_table(34) := '202020206D61702E5F5F6D6170626974735F6C617965725F637572736F7273203F3F3D206E6577204D617028293B0D0A0D0A2020202069662028216D61702E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F616464656429207B';
wwv_flow_imp.g_varchar2_table(35) := '0D0A2020202020206D61702E6F6E28277374796C65696D6167656D697373696E67272C2028657629203D3E207B0D0A20202020202020206D6170626974735F6C6F6465737461725F696D6167655F68616E646C6572286576293B0D0A2020202020207D29';
wwv_flow_imp.g_varchar2_table(36) := '3B0D0A0D0A2020202020202F2A204C697374656E20666F72206572726F727320696E20746865206D617020287768696368206D6179206265206173796E6368726F6E6F75732C20736F206E6F742061207468726F776E2F63617567687420657863657074';
wwv_flow_imp.g_varchar2_table(37) := '696F6E292E0D0A2020202020202020204F6E6C7920646F2074686973206F6E636520706572206D61702C206576656E206966206D756C7469706C65204D61706269747320706C7567696E732061726520757365642E202A2F0D0A20202020202069662028';
wwv_flow_imp.g_varchar2_table(38) := '216D61702E5F5F6D6170626974735F6572726F725F68616E646C65725F616464656429207B0D0A20202020202020206D61702E6F6E28276572726F72272C2028657629203D3E207B0D0A20202020202020202020617065782E64656275672E6572726F72';
wwv_flow_imp.g_varchar2_table(39) := '28604D6170206572726F7220696E20726567696F6E20247B726567696F6E49647D3A20602C2065762E6572726F72293B0D0A20202020202020207D293B0D0A20202020202020206D61702E5F5F6D6170626974735F6572726F725F68616E646C65725F61';
wwv_flow_imp.g_varchar2_table(40) := '64646564203D20747275653B0D0A2020202020207D0D0A0D0A2020202020206D61702E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F6164646564203D20747275653B0D0A202020207D0D0A0D0A20202020636F6E7374206C65';
wwv_flow_imp.g_varchar2_table(41) := '67656E64203D202428272327202B20726567696F6E4964202B20275F6C6567656E6427293B0D0A202020202428603C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E6449';
wwv_flow_imp.g_varchar2_table(42) := '74656D2D2D6869646561626C65223E60290D0A2020202020202E617070656E64280D0A20202020202020202428603C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C656374';
wwv_flow_imp.g_varchar2_table(43) := '6F722069732D636865636B65642220636865636B65643D22223E60290D0A202020202020202020202E70726F70287B0D0A202020202020202020202020276964273A206974656D4964202B20275F6C6567656E645F656E747279272C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(44) := '20202020202027636865636B6564273A206C61796572735669736962696C69747920213D3D20276E6F6E65272C0D0A202020202020202020207D290D0A202020202020202020202E637373287B20272D2D612D6D61702D6C6567656E642D73656C656374';
wwv_flow_imp.g_varchar2_table(45) := '6F722D636F6C6F72273A20636F6C6F72207D292C0D0A20202020202020202428603C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C223E60290D0A202020202020202020202E70726F70287B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(46) := '20202020202020276964273A206974656D4964202B20275F6C6567656E645F656E7472795F6C6162656C272C0D0A20202020202020202020202027666F72273A206974656D4964202B20275F6C6567656E645F656E747279270D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(47) := '207D290D0A202020202020202020202E617070656E64280D0A202020202020202020202020287469746C65207C7C206974656D4964292C0D0A2020202020202020202020202428603C7370616E20636C6173733D2266612066612D636972636C652D372D';
wwv_flow_imp.g_varchar2_table(48) := '382066612D616E696D2D7370696E22207374796C653D22646973706C61793A206E6F6E653B206D617267696E2D6C6566743A202E35656D3B223E60292E70726F7028276964272C206974656D4964202B20275F6C6567656E645F656E7472795F73746174';
wwv_flow_imp.g_varchar2_table(49) := '757327290D0A20202020202020202020290D0A202020202020290D0A2020202020202E617070656E64546F286C6567656E64293B0D0A0D0A2020202072657475726E206D61703B0D0A20207D293B0D0A0D0A20206173796E632066756E6374696F6E2072';
wwv_flow_imp.g_varchar2_table(50) := '656C6F6164536F75726365446174612829207B0D0A2020202069662028217265736F6C766564536F757263654F7074696F6E7329207B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20202020636F6E737420736F7572636546656174';
wwv_flow_imp.g_varchar2_table(51) := '75726573203D207265736F6C766564536F757263654F7074696F6E733F2E646174612E66656174757265730D0A2020202020202E6D61702866656174203D3E207B0D0A2020202020202020636F6E73742065646974203D2065646974732E676574286665';
wwv_flow_imp.g_varchar2_table(52) := '61742E6964293B0D0A0D0A202020202020202069662028656469743F2E616374696F6E203D3D3D202764656C6574652729207B0D0A2020202020202020202072657475726E206E756C6C3B0D0A20202020202020207D0D0A0D0A20202020202020207265';
wwv_flow_imp.g_varchar2_table(53) := '7475726E207B0D0A20202020202020202020747970653A202746656174757265272C0D0A2020202020202020202069643A20666561742E69642C0D0A2020202020202020202070726F706572746965733A2065646974203F20656469742E666561747572';
wwv_flow_imp.g_varchar2_table(54) := '652E70726F70657274696573203A20666561742E70726F706572746965732C0D0A2020202020202020202067656F6D657472793A2065646974203F20656469742E666561747572652E67656F6D65747279203A20666561742E67656F6D657472792C0D0A';
wwv_flow_imp.g_varchar2_table(55) := '20202020202020207D3B0D0A2020202020207D290D0A2020202020202E66696C7465722878203D3E207820213D3D206E756C6C290D0A2020202020203F3F205B5D3B0D0A0D0A20202020636F6E737420656469744665617475726573203D204172726179';
wwv_flow_imp.g_varchar2_table(56) := '2E66726F6D2865646974732E76616C7565732829290D0A2020202020202E66696C7465722865646974203D3E20656469742E616374696F6E203D3D3D202763726561746527290D0A2020202020202E6D61702865646974203D3E20287B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(57) := '202020747970653A202746656174757265272C0D0A202020202020202069643A20656469742E666561747572652E69642C0D0A202020202020202070726F706572746965733A20656469742E666561747572652E70726F706572746965732C0D0A202020';
wwv_flow_imp.g_varchar2_table(58) := '202020202067656F6D657472793A20656469742E666561747572652E67656F6D657472792C0D0A2020202020207D29293B0D0A0D0A202020206665617475726573203D205B2E2E2E736F7572636546656174757265732C202E2E2E656469744665617475';
wwv_flow_imp.g_varchar2_table(59) := '7265735D3B0D0A2020202066656174757265734D61702E636C65617228293B0D0A20202020666F722028636F6E73742066656174206F6620666561747572657329207B0D0A20202020202069662028747970656F6620666561742E696420213D3D202775';
wwv_flow_imp.g_varchar2_table(60) := '6E646566696E65642729207B0D0A202020202020202066656174757265734D61702E73657428666561742E69642C2066656174293B0D0A2020202020207D0D0A202020207D0D0A0D0A2020202069644D61702E636C65617228293B0D0A2020202069644D';
wwv_flow_imp.g_varchar2_table(61) := '61705265762E636C65617228293B0D0A202020206C6574206E6578744964203D20303B0D0A20202020636F6E737420616C6C6F634964203D20286F726967696E616C29203D3E207B0D0A202020202020636F6E7374206964203D202B2B6E65787449643B';
wwv_flow_imp.g_varchar2_table(62) := '0D0A20202020202069662028747970656F66206F726967696E616C20213D3D2027756E646566696E65642729207B0D0A202020202020202069644D61702E7365742869642C206F726967696E616C293B0D0A202020202020202069644D61705265762E73';
wwv_flow_imp.g_varchar2_table(63) := '6574286F726967696E616C2C206964293B0D0A202020202020202069644D61705265762E736574286F726967696E616C2E746F537472696E6728292C206964293B0D0A2020202020207D0D0A20202020202072657475726E2069643B0D0A202020207D0D';
wwv_flow_imp.g_varchar2_table(64) := '0A0D0A20202020636F6E7374207265616C44617461203D207B0D0A2020202020202E2E2E7265736F6C766564536F757263654F7074696F6E732E646174612C0D0A20202020202066656174757265733A2066656174757265732E6D617028286665617475';
wwv_flow_imp.g_varchar2_table(65) := '726529203D3E207B0D0A2020202020202020636F6E73742066656174203D207B0D0A20202020202020202020747970653A202746656174757265272C0D0A2020202020202020202069643A20616C6C6F63496428666561747572652E6964292C0D0A2020';
wwv_flow_imp.g_varchar2_table(66) := '202020202020202067656F6D657472793A20666561747572652E67656F6D657472792C0D0A2020202020202020202070726F706572746965733A207B0D0A2020202020202020202020202E2E2E666561747572652E70726F706572746965732C0D0A2020';
wwv_flow_imp.g_varchar2_table(67) := '20202020202020207D2C0D0A20202020202020207D3B0D0A0D0A20202020202020206966202867657453656C656374696F6E5374796C652829203D3D3D202770726F70657274792729207B0D0A20202020202020202020666561742E70726F7065727469';
wwv_flow_imp.g_varchar2_table(68) := '65735B276D6170626974732D73656C6563746564275D203D20280D0A20202020202020202020202073656C656374656446656174757265730D0A20202020202020202020202026262028747970656F6620666561747572652E696420213D3D2027756E64';
wwv_flow_imp.g_varchar2_table(69) := '6566696E656427290D0A202020202020202020202020262620666561747572652E696420213D3D206E756C6C0D0A2020202020202020202020202626202873656C656374656446656174757265732E68617328666561747572652E696429207C7C207365';
wwv_flow_imp.g_varchar2_table(70) := '6C656374656446656174757265732E68617328666561747572652E69642E746F537472696E67282929290D0A20202020202020202020293B0D0A20202020202020207D0D0A20202020202020200D0A202020202020202072657475726E20666561743B0D';
wwv_flow_imp.g_varchar2_table(71) := '0A2020202020207D292C0D0A202020207D3B0D0A0D0A20202020636F6E7374206D6170203D2061776169742070656E64696E674D61703B0D0A0D0A20202020696620286D61702E676574536F7572636528736F757263654E616D652929207B0D0A202020';
wwv_flow_imp.g_varchar2_table(72) := '2020206D61702E676574536F7572636528736F757263654E616D65292E73657444617461287265616C44617461293B0D0A202020207D20656C7365207B0D0A2020202020206C657420736F757263654F707473203D207B0D0A20202020202020202E2E2E';
wwv_flow_imp.g_varchar2_table(73) := '7265736F6C766564536F757263654F7074696F6E732C0D0A2020202020202020646174613A207265616C446174612C0D0A2020202020207D3B0D0A0D0A20202020202069662028216964436F6C756D6E2026262021282767656E65726174654964272069';
wwv_flow_imp.g_varchar2_table(74) := '6E20736F757263654F7074732929207B0D0A2020202020202020736F757263654F7074732E67656E65726174654964203D20747275653B0D0A2020202020207D0D0A0D0A20202020202069662028736F757263654F7074732E636C757374657220262620';
wwv_flow_imp.g_varchar2_table(75) := '67657453656C656374696F6E5374796C652829203D3D3D202770726F70657274792729207B0D0A2020202020202020736F757263654F707473203D207B0D0A202020202020202020202E2E2E736F757263654F7074732C0D0A2020202020202020202063';
wwv_flow_imp.g_varchar2_table(76) := '6C757374657250726F706572746965733A207B0D0A202020202020202020202020276D6170626974732D73656C6563746564273A205B27616E79272C205B27676574272C20276D6170626974732D73656C6563746564275D5D2C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(77) := '202020202E2E2E736F757263654F7074732E636C757374657250726F706572746965732C0D0A202020202020202020207D0D0A20202020202020207D3B0D0A2020202020207D0D0A0D0A202020202020747279207B0D0A20202020202020206D61702E61';
wwv_flow_imp.g_varchar2_table(78) := '6464536F7572636528736F757263654E616D652C20736F757263654F707473293B0D0A2020202020207D2063617463682028657863657074696F6E29207B0D0A2020202020202020617065782E64656275672E6572726F7228606D6170626974735F6C6F';
wwv_flow_imp.g_varchar2_table(79) := '6465737461726C6179657220247B6974656D49647D203A204661696C656420746F206164642047656F4A534F4E20736F75726365602C20657863657074696F6E293B0D0A2020202020207D0D0A202020207D0D0A20207D3B0D0A0D0A2020636C61737320';
wwv_flow_imp.g_varchar2_table(80) := '53696465626172436F6E74726F6C207B0D0A20202020697353696465626172203D20747275653B0D0A0D0A20202020636F6E7374727563746F72286D617029207B0D0A202020202020746869732E6D6170203D206D61703B0D0A0D0A2020202020207468';
wwv_flow_imp.g_varchar2_table(81) := '69732E636F6E74656E74203D202428603C64697620636C6173733D226D6170626974732D696E666F2D636F6E74656E74223E60293B0D0A202020202020746869732E70616E656C203D202428603C64697620636C6173733D226D6170626974732D736964';
wwv_flow_imp.g_varchar2_table(82) := '656261722D70616E656C223E60292E617070656E6428746869732E636F6E74656E74293B0D0A202020202020746869732E636C6F7365427574746F6E203D202428603C627574746F6E20747970653D22627574746F6E2220636C6173733D226D61706269';
wwv_flow_imp.g_varchar2_table(83) := '74732D736964656261722D636C6F73652220617269612D6C6162656C3D22436C6F73652053696465626172223E3C7370616E20636C6173733D2266612066612D72656D6F7665223E3C2F7370616E3E3C2F627574746F6E3E60292E6F6E2827636C69636B';
wwv_flow_imp.g_varchar2_table(84) := '272C202829203D3E207B0D0A2020202020202020746869732E6869646528293B0D0A2020202020207D293B0D0A202020202020746869732E636F6E7461696E6572203D202428603C64697620636C6173733D226D6170626974732D736964656261722220';
wwv_flow_imp.g_varchar2_table(85) := '7374796C653D22646973706C61793A206E6F6E653B223E60290D0A20202020202020202E617070656E6428746869732E70616E656C290D0A20202020202020202E617070656E6428746869732E636C6F7365427574746F6E293B0D0A0D0A202020202020';
wwv_flow_imp.g_varchar2_table(86) := '2428746869732E6D61702E676574436F6E7461696E65722829292E617070656E6428746869732E636F6E7461696E6572293B0D0A2020202020200D0A202020202020746869732E746F704C65667453697A65203D206E657720526573697A654F62736572';
wwv_flow_imp.g_varchar2_table(87) := '7665722828656E747269657329203D3E207B0D0A2020202020202020746869732E636F6E7461696E65722E63737328272D2D6D6170626974732D736964656261722D746F70272C20656E74726965735B305D2E636F6E74656E74526563742E6865696768';
wwv_flow_imp.g_varchar2_table(88) := '74202B2027707827293B0D0A2020202020207D293B0D0A202020202020746869732E746F704C65667453697A652E6F627365727665286D61702E676574436F6E7461696E657228292E717565727953656C6563746F7228272E6D61706C69627265676C2D';
wwv_flow_imp.g_varchar2_table(89) := '6374726C2D746F702D6C6566742729293B0D0A202020202020746869732E626F74746F6D4C65667453697A65203D206E657720526573697A654F627365727665722828656E747269657329203D3E207B0D0A2020202020202020746869732E636F6E7461';
wwv_flow_imp.g_varchar2_table(90) := '696E65722E63737328272D2D6D6170626974732D736964656261722D626F74746F6D272C20656E74726965735B305D2E636F6E74656E74526563742E686569676874202B2027707827293B0D0A2020202020207D293B0D0A202020202020746869732E62';
wwv_flow_imp.g_varchar2_table(91) := '6F74746F6D4C65667453697A652E6F627365727665286D61702E676574436F6E7461696E657228292E717565727953656C6563746F7228272E6D61706C69627265676C2D6374726C2D626F74746F6D2D6C6566742729293B0D0A202020207D0D0A0D0A20';
wwv_flow_imp.g_varchar2_table(92) := '2020206F6E52656D6F76652829207B0D0A202020202020746869732E636F6E7461696E65722E72656D6F766528293B0D0A202020202020746869732E746F704C65667453697A652E646973636F6E6E65637428293B0D0A202020202020746869732E626F';
wwv_flow_imp.g_varchar2_table(93) := '74746F6D4C65667453697A652E646973636F6E6E65637428293B0D0A202020207D0D0A0D0A20202020686964652829207B0D0A202020202020746869732E636F6E7461696E65722E6869646528293B0D0A202020202020746869732E636C6F73653F2E28';
wwv_flow_imp.g_varchar2_table(94) := '293B0D0A202020207D0D0A0D0A2020202073686F7728636F6E74656E742C20636C6F736529207B0D0A202020202020746869732E636F6E74656E742E68746D6C28636F6E74656E74293B0D0A202020202020746869732E636C6F7365203D20636C6F7365';
wwv_flow_imp.g_varchar2_table(95) := '3B0D0A202020202020746869732E636F6E7461696E65722E746F67676C65436C61737328276D6170626974732D736964656261722D636C6F736561626C65272C202121746869732E636C6F7365293B0D0A202020202020746869732E636F6E7461696E65';
wwv_flow_imp.g_varchar2_table(96) := '722E73686F7728293B0D0A202020207D0D0A20207D0D0A0D0A2020636F6E737420757064617465506F707570537461636B203D202865762C206265686176696F72732C20706F7075702C206D617029203D3E207B0D0A20202020636F6E73742073746163';
wwv_flow_imp.g_varchar2_table(97) := '6B203D205B5D3B0D0A20202020636F6E7374206E657754656D706C6174654F757470757473203D207B7D3B0D0A20202020636F6E7374206C6F636174696F6E203D20706F7075702E697353696465626172203F20277369646562617227203A2027706F70';
wwv_flow_imp.g_varchar2_table(98) := '7570273B0D0A0D0A20202020636F6E73742064617461203D206D61702E5F5F6D6170626974735F5F696E666F5F77696E646F775F646174613B0D0A0D0A20202020666F722028636F6E73742066656174757265206F66206D61702E717565727952656E64';
wwv_flow_imp.g_varchar2_table(99) := '6572656446656174757265732865762E706F696E742929207B0D0A202020202020636F6E737420696E666F57696E646F7773203D20646174612E696E666F57696E646F77735B666561747572652E6C617965722E69645D3B0D0A0D0A2020202020206966';
wwv_flow_imp.g_varchar2_table(100) := '202821696E666F57696E646F77732920636F6E74696E75653B0D0A0D0A202020202020666F722028636F6E737420696E666F57696E646F77206F6620696E666F57696E646F777329207B0D0A20202020202020202F2A20446F6E27742073686F7720636C';
wwv_flow_imp.g_varchar2_table(101) := '69636B206C617965727320696E2074686520686F76657220706F7075702C206F7220686F7665725F6F6E6C79206C617965727320696E0D0A202020202020202020202074686520636C69636B20706F707570202A2F0D0A20202020202020206966202821';
wwv_flow_imp.g_varchar2_table(102) := '6265686176696F72732E696E636C7564657328696E666F57696E646F772E6265686176696F722929207B0D0A20202020202020202020636F6E74696E75653B0D0A20202020202020207D0D0A0D0A202020202020202069662028696E666F57696E646F77';
wwv_flow_imp.g_varchar2_table(103) := '2E6C6F636174696F6E20213D3D206C6F636174696F6E29207B0D0A20202020202020202020636F6E74696E75653B0D0A20202020202020207D0D0A0D0A2020202020202020636F6E7374206B6579203D2060247B696E666F57696E646F772E6974656D4E';
wwv_flow_imp.g_varchar2_table(104) := '616D657D20247B696E666F57696E646F772E6265686176696F727D20247B666561747572652E69647D603B0D0A0D0A20202020202020202F2A20496620746865726520617265206D756C7469706C65207374796C65206C617965727320696E2074686520';
wwv_flow_imp.g_varchar2_table(105) := '73616D65204C6F646573746172206C617965722C206D616B6520737572650D0A202020202020202020202074686520696E666F2077696E646F77206973206F6E6C79206164646564206F6E63652E0D0A20202020202020202020204E6F74653A20546865';
wwv_flow_imp.g_varchar2_table(106) := '72652773206120627567207768657265207468697320736F6D6574696D657320646F65736E27742064656475706C696361746520706F7075707320666F72206C6162656C73206F6E206C696E65732C0D0A2020202020202020202020776869636820796F';
wwv_flow_imp.g_varchar2_table(107) := '752063616E2073656520696E2077617465727761797320696E20746865204C6F64657374617220496E666F2057696E646F772064656D6F2E0D0A202020202020202020202049207468696E6B20697427732062656361757365204D61704C69627265206D';
wwv_flow_imp.g_varchar2_table(108) := '65726765732073796D626F6C732077697468207468652073616D652074657874206163726F73732066656174757265732C20616E64207069636B73206F6E65206F662074686520736F757263650D0A202020202020202020202066656174757265732061';
wwv_flow_imp.g_varchar2_table(109) := '72626974726172696C7920666F72207468652049442E0D0A2020202020202020202020202A2F0D0A2020202020202020696620286B657920696E206E657754656D706C6174654F75747075747329207B0D0A20202020202020202020636F6E74696E7565';
wwv_flow_imp.g_varchar2_table(110) := '3B0D0A20202020202020207D0D0A0D0A20202020202020202F2A20446F6E277420696E636C75646520636C7573746572656420706F696E74732C2062656361757365207468657920646F6E27742068617665207468652070726F706572746965730D0A20';
wwv_flow_imp.g_varchar2_table(111) := '202020202020202020206F6620616E2061637475616C2066656174757265206F6620746865206C617965722E20536F2074686520737562737469747574696F6E7320776F6E277420776F726B2E202A2F0D0A202020202020202069662028666561747572';
wwv_flow_imp.g_varchar2_table(112) := '652E70726F706572746965732E636C757374657229207B0D0A20202020202020202020636F6E74696E75653B0D0A20202020202020207D0D0A0D0A20202020202020206C6574206665617475726550726F7073203D207B7D3B0D0A202020202020202066';
wwv_flow_imp.g_varchar2_table(113) := '6F722028636F6E7374206B206F66204F626A6563742E6B65797328666561747572652E70726F706572746965732929207B0D0A202020202020202020206665617475726550726F70735B6B5D203D2028666561747572652E70726F706572746965735B6B';
wwv_flow_imp.g_varchar2_table(114) := '5D203F3F202727292E746F537472696E6728293B0D0A20202020202020207D0D0A0D0A2020202020202020636F6E737420737461636B4974656D203D20646174612E74656D706C6174654F7574707574735B6B65795D203F3F207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(115) := '202020656C656D656E743A20242E706172736548544D4C280D0A202020202020202020202020617065782E7574696C2E6170706C7954656D706C61746528696E666F57696E646F772E68746D6C45787072657373696F6E203F3F2027272C207B0D0A2020';
wwv_flow_imp.g_varchar2_table(116) := '202020202020202020202020706C616365686F6C646572733A206665617475726550726F70732C0D0A20202020202020202020202020206578747261537562737469747574696F6E733A206665617475726550726F70732C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(117) := '20207D290D0A20202020202020202020292C0D0A202020202020202020207365713A20696E666F57696E646F772E73657175656E63654E756D6265722C0D0A20202020202020207D3B0D0A0D0A2020202020202020737461636B2E707573682873746163';
wwv_flow_imp.g_varchar2_table(118) := '6B4974656D293B0D0A20202020202020206E657754656D706C6174654F7574707574735B6B65795D203D20737461636B4974656D3B0D0A2020202020207D0D0A202020207D0D0A0D0A202020202F2A20536F72742074686520706F70757020656E747269';
wwv_flow_imp.g_varchar2_table(119) := '6573206279207468652073657175656E6365206E756D62657273206F662074686520496E666F2057696E646F77206974656D73202A2F0D0A20202020737461636B2E736F72742828612C206229203D3E20612E736571202D20622E736571293B0D0A0D0A';
wwv_flow_imp.g_varchar2_table(120) := '20202020646174612E74656D706C6174654F757470757473203D206E657754656D706C6174654F7574707574733B0D0A0D0A2020202069662028737461636B2E6C656E677468203E203029207B0D0A202020202020636F6E737420646976203D20242860';
wwv_flow_imp.g_varchar2_table(121) := '3C64697620636C6173733D226D6170626974732D696E666F2D77696E646F77223E60293B0D0A2020202020206C6574206669727374203D20747275653B0D0A202020202020666F722028636F6E7374206974656D206F6620737461636B29207B0D0A2020';
wwv_flow_imp.g_varchar2_table(122) := '2020202020206966202821666972737429207B0D0A202020202020202020206469762E617070656E64282428603C68722F3E6029293B0D0A20202020202020207D0D0A20202020202020206669727374203D2066616C73653B0D0A202020202020202064';
wwv_flow_imp.g_varchar2_table(123) := '69762E617070656E64286974656D2E656C656D656E74293B0D0A2020202020207D0D0A0D0A20202020202069662028706F7075702E69735369646562617229207B0D0A2020202020202020706F7075702E73686F77286469762E6765742830292C206461';
wwv_flow_imp.g_varchar2_table(124) := '74612E736964656261724D61726B6572203F202829203D3E207B0D0A20202020202020202020646174612E736964656261724D61726B65723F2E72656D6F766528293B0D0A20202020202020202020646174612E736964656261724D61726B6572203D20';
wwv_flow_imp.g_varchar2_table(125) := '6E756C6C3B0D0A20202020202020207D203A206E756C6C293B0D0A2020202020207D20656C7365207B0D0A2020202020202020706F7075702E7365744C6E674C61742865762E6C6E674C6174293B0D0A2020202020202020706F7075702E736574444F4D';
wwv_flow_imp.g_varchar2_table(126) := '436F6E74656E74286469762E676574283029293B0D0A2020202020202020706F7075702E616464546F286D6170293B0D0A2020202020207D0D0A202020207D20656C7365207B0D0A20202020202069662028706F7075702E69735369646562617229207B';
wwv_flow_imp.g_varchar2_table(127) := '0D0A2020202020202020706F7075702E6869646528293B0D0A2020202020207D20656C7365207B0D0A2020202020202020706F7075702E72656D6F766528293B0D0A2020202020207D0D0A202020207D0D0A20207D3B0D0A0D0A20206C65742061646465';
wwv_flow_imp.g_varchar2_table(128) := '644C61796572203D2066616C73653B0D0A20206C6574206F726967696E616C4C61796572733B0D0A20206C657420636F6C756D6E4E616D6573203D206E65772053657428293B0D0A20206C657420636F6C756D6E44656673203D206E756C6C3B0D0A0D0A';
wwv_flow_imp.g_varchar2_table(129) := '20206173796E632066756E6374696F6E206C6F6164446174612829207B0D0A202020202428272327202B206974656D4964202B20275F6C6567656E645F656E7472795F73746174757327292E6373732827646973706C6179272C2027696E6C696E652729';
wwv_flow_imp.g_varchar2_table(130) := '3B0D0A20202020617065782E6576656E742E7472696767657228272327202B206974656D49642C20276C6F61645F737461727427293B0D0A20202020747279207B0D0A2020202020206C6574207265616C536F757263654F7074696F6E73203D20747970';
wwv_flow_imp.g_varchar2_table(131) := '656F6620736F757263654F7074696F6E73203D3D3D202766756E6374696F6E27203F20617761697420736F757263654F7074696F6E732829203A20736F757263654F7074696F6E733B0D0A2020202020207265616C536F757263654F7074696F6E73203F';
wwv_flow_imp.g_varchar2_table(132) := '3F3D207B7D3B0D0A0D0A20202020202069662028656E61626C65436C7573746572696E6729207B0D0A20202020202020207265616C536F757263654F7074696F6E732E636C7573746572203F3F3D20747275653B0D0A2020202020202020696620287479';
wwv_flow_imp.g_varchar2_table(133) := '70656F6620636C757374657252616469757320213D3D2027756E646566696E65642729207B0D0A202020202020202020207265616C536F757263654F7074696F6E732E636C7573746572526164697573203F3F3D20636C75737465725261646975733B0D';
wwv_flow_imp.g_varchar2_table(134) := '0A20202020202020207D0D0A202020202020202069662028747970656F6620636C75737465724D61785A6F6F6D20213D3D2027756E646566696E65642729207B0D0A202020202020202020207265616C536F757263654F7074696F6E732E636C75737465';
wwv_flow_imp.g_varchar2_table(135) := '724D61785A6F6F6D203F3F3D20636C75737465724D61785A6F6F6D3B0D0A20202020202020207D0D0A202020202020202069662028747970656F6620636C75737465724D696E506F696E747320213D3D2027756E646566696E65642729207B0D0A202020';
wwv_flow_imp.g_varchar2_table(136) := '202020202020207265616C536F757263654F7074696F6E732E636C75737465724D696E506F696E7473203F3F3D20636C75737465724D696E506F696E74733B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A202020202020636F6E73742064';
wwv_flow_imp.g_varchar2_table(137) := '6574656374436F6C756D6E73203D20286461746129203D3E207B0D0A2020202020202020636F6E737420636F6C73203D206E6577204D617028293B0D0A2020202020202020666F722028636F6E73742066656174206F6620646174613F2E666561747572';
wwv_flow_imp.g_varchar2_table(138) := '6573203F3F205B5D29207B0D0A20202020202020202020666F722028636F6E7374206B6579206F66204F626A6563742E6765744F776E50726F70657274794E616D657328666561742E70726F70657274696573203F3F207B7D2929207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(139) := '2020202020202069662028636F6C732E686173286B65792929207B0D0A2020202020202020202020202020636F6C732E736574286B65792C207B206E616D653A206B6579207D293B0D0A2020202020202020202020207D0D0A202020202020202020207D';
wwv_flow_imp.g_varchar2_table(140) := '0D0A20202020202020207D0D0A0D0A202020202020202072657475726E205B2E2E2E636F6C732E76616C75657328295D3B0D0A2020202020207D3B0D0A0D0A20202020202069662028736F7572636554797065203D3D3D20226A61766173637269707422';
wwv_flow_imp.g_varchar2_table(141) := '29207B0D0A20202020202020207265736F6C766564536F757263654F7074696F6E73203D207B0D0A202020202020202020202E2E2E7265616C536F757263654F7074696F6E732C0D0A20202020202020202020747970653A202767656F6A736F6E272C0D';
wwv_flow_imp.g_varchar2_table(142) := '0A20202020202020207D3B0D0A2020202020202020636F6E7374206E6577436F6C44656673203D20646574656374436F6C756D6E73287265616C536F757263654F7074696F6E732E64617461293B0D0A2020202020202020696620286E6577436F6C4465';
wwv_flow_imp.g_varchar2_table(143) := '667329207B0D0A20202020202020202020636F6C756D6E44656673203D206E6577436F6C446566733B0D0A20202020202020207D0D0A2020202020207D20656C7365207B0D0A2020202020202020636F6E737420726573706F6E7365203D206177616974';
wwv_flow_imp.g_varchar2_table(144) := '20617065782E7365727665722E706C7567696E28616A61784964656E7469666965722C207B706167654974656D733A207375626D69744974656D73203F207375626D69744974656D732E73706C697428222C22292E66696C7465722878203D3E20212178';
wwv_flow_imp.g_varchar2_table(145) := '29203A20756E646566696E65647D293B0D0A20202020202020207265736F6C766564536F757263654F7074696F6E73203D207B0D0A202020202020202020202E2E2E7265616C536F757263654F7074696F6E732C0D0A2020202020202020202074797065';
wwv_flow_imp.g_varchar2_table(146) := '3A202767656F6A736F6E272C0D0A20202020202020202020646174613A207B0D0A202020202020202020202020747970653A202746656174757265436F6C6C656374696F6E272C0D0A20202020202020202020202066656174757265733A20726573706F';
wwv_flow_imp.g_varchar2_table(147) := '6E73652E66656174757265732C0D0A202020202020202020207D2C0D0A20202020202020207D3B0D0A2020202020202020636F6C756D6E44656673203D20726573706F6E73652E636F6C756D6E733B0D0A2020202020207D0D0A202020202020636F6C75';
wwv_flow_imp.g_varchar2_table(148) := '6D6E4E616D6573203D206E65772053657428636F6C756D6E446566732E6D61702878203D3E20782E6E616D6529293B0D0A20202020202061776169742072656C6F6164536F757263654461746128293B0D0A202020207D2066696E616C6C79207B0D0A20';
wwv_flow_imp.g_varchar2_table(149) := '2020202020617065782E6576656E742E7472696767657228272327202B206974656D49642C20276C6F61645F656E6427293B0D0A2020202020202428272327202B206974656D4964202B20275F6C6567656E645F656E7472795F73746174757327292E63';
wwv_flow_imp.g_varchar2_table(150) := '73732827646973706C6179272C20276E6F6E6527293B0D0A202020207D0D0A0D0A20202020636F6E7374206D6170203D2061776169742070656E64696E674D61703B0D0A0D0A2020202073656C656374696F6E436F6C6F72203F3F3D2027233035666164';
wwv_flow_imp.g_varchar2_table(151) := '64273B0D0A0D0A20202020696620282161646465644C6179657229207B0D0A20202020202061646465644C61796572203D20747275653B0D0A0D0A2020202020206966202872656374616E676C6553656C65637429207B0D0A2020202020202020696620';
wwv_flow_imp.g_varchar2_table(152) := '28216D61702E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C29207B0D0A202020202020202020206D61702E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C203D206E657720';
wwv_flow_imp.g_varchar2_table(153) := '52656374616E676C6553656C656374436F6E74726F6C28293B0D0A202020202020202020206D61702E616464436F6E74726F6C286D61702E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(154) := '20207D0D0A20202020202020206D61702E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C2E6164644C61796572286974656D4964293B0D0A2020202020207D0D0A0D0A202020202020636F6E737420637265617465';
wwv_flow_imp.g_varchar2_table(155) := '45787072203D2028696E7075742C2074797065203D202878203D3E20782929203D3E207B0D0A202020202020202069662028747970656F6620696E707574203D3D3D2027737472696E672729207B0D0A20202020202020202020636F6E7374206D203D20';
wwv_flow_imp.g_varchar2_table(156) := '696E7075742E6D61746368282F5E26285B412D5A612D7A5C645F5D2B295C2E242F293B0D0A20202020202020202020696620286D29207B0D0A20202020202020202020202069662028636F6C756D6E4E616D65732E686173286D5B315D2929207B0D0A20';
wwv_flow_imp.g_varchar2_table(157) := '2020202020202020202020202072657475726E205B27676574272C206D5B315D5D3B0D0A2020202020202020202020207D20656C7365207B0D0A202020202020202020202020202072657475726E207479706528617065782E7574696C2E6170706C7954';
wwv_flow_imp.g_varchar2_table(158) := '656D706C61746528696E70757429293B0D0A2020202020202020202020207D0D0A202020202020202020207D0D0A20202020202020207D0D0A0D0A20202020202020206966202821696E70757429207B0D0A2020202020202020202072657475726E206E';
wwv_flow_imp.g_varchar2_table(159) := '756C6C3B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202072657475726E207479706528696E707574293B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A20202020202073776974636820286C6179657254797065';
wwv_flow_imp.g_varchar2_table(160) := '29207B0D0A202020202020202063617365202773796D626F6C273A0D0A202020202020202020206F726967696E616C4C6179657273203D207B0D0A202020202020202020202020747970653A202773796D626F6C272C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(161) := '6C61796F75743A207B7D0D0A202020202020202020207D3B0D0A20202020202020202020696620286C6162656C436F6C756D6E2920207B0D0A2020202020202020202020206F726967696E616C4C61796572732E6C61796F75745B27746578742D666965';
wwv_flow_imp.g_varchar2_table(162) := '6C64275D203D205B0D0A20202020202020202020202020202763617365272C0D0A20202020202020202020202020205B27686173272C2027706F696E745F636F756E74275D2C0D0A20202020202020202020202020205B27636F6E636174272C205B2767';
wwv_flow_imp.g_varchar2_table(163) := '6574272C2027706F696E745F636F756E74275D2C2027206665617475726573275D2C0D0A20202020202020202020202020205B27676574272C206C6162656C436F6C756D6E5D0D0A2020202020202020202020205D3B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(164) := '6F726967696E616C4C61796572732E6C61796F75745B27746578742D73697A65275D203D206372656174654578707228666F6E7453697A6529203F3F2031323B0D0A202020202020202020207D0D0A202020202020202020206966202869636F6E29207B';
wwv_flow_imp.g_varchar2_table(165) := '0D0A2020202020202020202020206F726967696E616C4C61796572732E6C61796F75745B2769636F6E2D696D616765275D203D20637265617465457870722869636F6E293B0D0A202020202020202020207D0D0A20202020202020202020627265616B3B';
wwv_flow_imp.g_varchar2_table(166) := '0D0A0D0A20202020202020206361736520276C696E65273A207B0D0A202020202020202020206F726967696E616C4C6179657273203D205B5D3B0D0A0D0A202020202020202020206966202867657453656C656374696F6E5374796C652829203D3D3D20';
wwv_flow_imp.g_varchar2_table(167) := '2770726F70657274792729207B0D0A2020202020202020202020206F726967696E616C4C61796572732E70757368287B0D0A202020202020202020202020202069643A202773656C656374696F6E272C0D0A202020202020202020202020202074797065';
wwv_flow_imp.g_varchar2_table(168) := '3A20276C696E65272C0D0A202020202020202020202020202066696C7465723A206F75746C696E65436F6C6F72203F2074727565203A205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A20';
wwv_flow_imp.g_varchar2_table(169) := '202020202020202020202020206C61796F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B0D0A20202020202020202020202020202020276C696E652D7769647468273A205B272B272C20322C206372656174654578707228';
wwv_flow_imp.g_varchar2_table(170) := '6C696E6557696474682C207061727365466C6F617429203F3F20315D2C0D0A20202020202020202020202020202020276C696E652D636F6C6F72273A206F75746C696E65436F6C6F72203F205B2763617365272C205B273D3D272C205B27676574272C20';
wwv_flow_imp.g_varchar2_table(171) := '276D6170626974732D73656C6563746564275D2C20747275655D2C2073656C656374696F6E436F6C6F722C2063726561746545787072286F75746C696E65436F6C6F72295D203A2073656C656374696F6E436F6C6F722C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(172) := '2020207D2C0D0A2020202020202020202020207D293B0D0A202020202020202020207D0D0A0D0A20202020202020202020636F6E7374206C696E654C61796572203D207B0D0A202020202020202020202020747970653A20276C696E65272C0D0A202020';
wwv_flow_imp.g_varchar2_table(173) := '2020202020202020206C61796F75743A207B7D2C0D0A2020202020202020202020207061696E743A207B0D0A2020202020202020202020202020276C696E652D7769647468273A2063726561746545787072286C696E6557696474682C20706172736546';
wwv_flow_imp.g_varchar2_table(174) := '6C6F617429203F3F20312C0D0A2020202020202020202020207D2C0D0A202020202020202020207D3B0D0A0D0A20202020202020202020696620286C696E6544617368417272617929207B0D0A2020202020202020202020206C696E654C617965722E70';
wwv_flow_imp.g_varchar2_table(175) := '61696E745B276C696E652D646173686172726179275D203D206C696E654461736841727261792E73706C697428272027292E6D61702878203D3E207061727365466C6F6174287829293B0D0A202020202020202020207D0D0A0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(176) := '206F726967696E616C4C61796572732E70757368286C696E654C61796572293B0D0A0D0A20202020202020202020696620286C6162656C436F6C756D6E29207B0D0A2020202020202020202020206F726967696E616C4C61796572732E70757368287B0D';
wwv_flow_imp.g_varchar2_table(177) := '0A202020202020202020202020202069643A20276C6162656C272C0D0A2020202020202020202020202020747970653A202773796D626F6C272C0D0A20202020202020202020202020206C61796F75743A207B0D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(178) := '2027746578742D6669656C64273A205B27676574272C206C6162656C436F6C756D6E5D2C0D0A2020202020202020202020202020202027746578742D73697A65273A206372656174654578707228666F6E7453697A6529203F3F2031322C0D0A20202020';
wwv_flow_imp.g_varchar2_table(179) := '2020202020202020202020202773796D626F6C2D706C6163656D656E74273A20276C696E65272C0D0A20202020202020202020202020207D2C0D0A2020202020202020202020207D293B0D0A202020202020202020207D0D0A0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(180) := '20627265616B3B0D0A20202020202020207D0D0A0D0A202020202020202063617365202766696C6C273A0D0A202020202020202020206F726967696E616C4C6179657273203D205B0D0A2020202020202020202020207B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(181) := '202020747970653A202766696C6C272C0D0A20202020202020202020202020206C61796F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B7D2C0D0A2020202020202020202020207D2C0D0A202020202020202020205D3B0D';
wwv_flow_imp.g_varchar2_table(182) := '0A0D0A202020202020202020206966202867657453656C656374696F6E5374796C652829203D3D3D202770726F70657274792729207B0D0A2020202020202020202020206F726967696E616C4C61796572732E70757368287B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(183) := '202020202069643A202773656C656374696F6E272C0D0A2020202020202020202020202020747970653A20276C696E65272C0D0A202020202020202020202020202066696C7465723A205B273D3D272C205B27676574272C20276D6170626974732D7365';
wwv_flow_imp.g_varchar2_table(184) := '6C6563746564275D2C20747275655D2C0D0A20202020202020202020202020206C61796F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B0D0A20202020202020202020202020202020276C696E652D7769647468273A2033';
wwv_flow_imp.g_varchar2_table(185) := '2C0D0A20202020202020202020202020202020276C696E652D636F6C6F72273A2073656C656374696F6E436F6C6F722C0D0A20202020202020202020202020207D2C0D0A2020202020202020202020207D293B0D0A202020202020202020207D0D0A2020';
wwv_flow_imp.g_varchar2_table(186) := '2020202020202020627265616B3B0D0A0D0A2020202020202020636173652027636972636C65273A0D0A202020202020202020206F726967696E616C4C6179657273203D205B0D0A2020202020202020202020207B0D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(187) := '20747970653A2027636972636C65272C0D0A20202020202020202020202020206C61796F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B0D0A2020202020202020202020202020202027636972636C652D72616469757327';
wwv_flow_imp.g_varchar2_table(188) := '3A2063726561746545787072287261646975732C207061727365466C6F617429203F3F20352C0D0A2020202020202020202020202020202027636972636C652D626C7572273A206372656174654578707228626C757229203F3F20302C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(189) := '2020202020202020207D2C0D0A2020202020202020202020207D0D0A202020202020202020205D3B0D0A20202020202020202020696620286C6162656C436F6C756D6E2920207B0D0A2020202020202020202020206F726967696E616C4C61796572732E';
wwv_flow_imp.g_varchar2_table(190) := '70757368287B0D0A202020202020202020202020202069643A20276C6162656C272C0D0A2020202020202020202020202020747970653A202773796D626F6C272C0D0A20202020202020202020202020206C61796F75743A207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(191) := '202020202020202027746578742D6669656C64273A205B0D0A2020202020202020202020202020202020202763617365272C0D0A2020202020202020202020202020202020205B27686173272C2027706F696E745F636F756E74275D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(192) := '202020202020202020202020205B27636F6E636174272C205B27676574272C2027706F696E745F636F756E74275D2C2027206665617475726573275D2C0D0A2020202020202020202020202020202020205B27676574272C206C6162656C436F6C756D6E';
wwv_flow_imp.g_varchar2_table(193) := '5D0D0A202020202020202020202020202020205D2C0D0A2020202020202020202020202020202027746578742D73697A65273A206372656174654578707228666F6E7453697A6529203F3F2031322C0D0A20202020202020202020202020207D2C0D0A20';
wwv_flow_imp.g_varchar2_table(194) := '20202020202020202020207D293B0D0A202020202020202020207D0D0A20202020202020202020627265616B3B0D0A0D0A2020202020202020636173652027686561746D6170273A0D0A202020202020202020206F726967696E616C4C6179657273203D';
wwv_flow_imp.g_varchar2_table(195) := '205B0D0A2020202020202020202020207B0D0A2020202020202020202020202020747970653A2027686561746D6170272C0D0A20202020202020202020202020206C61796F75743A207B7D2C0D0A20202020202020202020202020207061696E743A207B';
wwv_flow_imp.g_varchar2_table(196) := '0D0A2020202020202020202020202020202027686561746D61702D726164697573273A20637265617465457870722872616469757329203F3F2033302C0D0A2020202020202020202020202020202027686561746D61702D776569676874273A205B2767';
wwv_flow_imp.g_varchar2_table(197) := '6574272C2027706F696E745F636F756E74275D2C0D0A20202020202020202020202020207D2C0D0A2020202020202020202020207D0D0A202020202020202020205D3B0D0A20202020202020202020627265616B3B0D0A0D0A2020202020202020646566';
wwv_flow_imp.g_varchar2_table(198) := '61756C743A0D0A202020202020202020206F726967696E616C4C6179657273203D206C61796572446566696E6974696F6E3B0D0A2020202020207D0D0A0D0A202020202020696620286F726967696E616C4C6179657273203D3D3D206E756C6C29207B0D';
wwv_flow_imp.g_varchar2_table(199) := '0A20202020202020206F726967696E616C4C6179657273203D207B7D3B0D0A2020202020207D0D0A20202020202069662028747970656F66206F726967696E616C4C6179657273203D3D3D202766756E6374696F6E2729207B0D0A20202020202020206F';
wwv_flow_imp.g_varchar2_table(200) := '726967696E616C4C6179657273203D206F726967696E616C4C617965727328293B0D0A2020202020207D0D0A202020202020696620282141727261792E69734172726179286F726967696E616C4C61796572732929207B0D0A20202020202020206F7269';
wwv_flow_imp.g_varchar2_table(201) := '67696E616C4C6179657273203D205B6F726967696E616C4C61796572735D3B0D0A2020202020207D0D0A0D0A202020202020636F6E7374206C6179657273203D206F726967696E616C4C61796572732E6D617028286F726967696E616C4C617965722C20';
wwv_flow_imp.g_varchar2_table(202) := '6929203D3E207B0D0A2020202020202020636F6E7374206C61796572203D207B0D0A202020202020202020202E2E2E6F726967696E616C4C617965722C0D0A2020202020202020202069643A206F726967696E616C4C617965722E6964203F206974656D';
wwv_flow_imp.g_varchar2_table(203) := '4964202B20272D27202B206F726967696E616C4C617965722E6964203A206974656D4964202B20272D27202B20692C0D0A20202020202020202020736F757263653A20736F757263654E616D652C0D0A202020202020202020206C61796F75743A207B0D';
wwv_flow_imp.g_varchar2_table(204) := '0A2020202020202020202020202E2E2E6F726967696E616C4C617965722E6C61796F75742C0D0A202020202020202020207D2C0D0A202020202020202020207061696E743A207B0D0A2020202020202020202020202E2E2E6F726967696E616C4C617965';
wwv_flow_imp.g_varchar2_table(205) := '722E7061696E742C0D0A202020202020202020207D2C0D0A202020202020202020206D657461646174613A207B0D0A2020202020202020202020206C617965725F73657175656E63653A2073657175656E63654E756D6265722C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(206) := '202020206974656D5F69643A206974656D49642C0D0A2020202020202020202020202E2E2E6F726967696E616C4C617965722E6D657461646174612C0D0A202020202020202020207D0D0A20202020202020207D3B0D0A0D0A2020202020202020696620';
wwv_flow_imp.g_varchar2_table(207) := '28747970656F66206C617965722E6D696E7A6F6F6D203D3D3D2027756E646566696E656427202626206D696E7A6F6F6D29207B0D0A202020202020202020206C617965722E6D696E7A6F6F6D203D206D696E7A6F6F6D3B0D0A20202020202020207D0D0A';
wwv_flow_imp.g_varchar2_table(208) := '202020202020202069662028747970656F66206C617965722E6D61787A6F6F6D203D3D3D2027756E646566696E656427202626206D61787A6F6F6D29207B0D0A202020202020202020206C617965722E6D61787A6F6F6D203D206D61787A6F6F6D3B0D0A';
wwv_flow_imp.g_varchar2_table(209) := '20202020202020207D0D0A0D0A2020202020202020636F6E737420666F6E7473203D207B0D0A2020202020202020202027726567756C6172273A205B274D6574726F706F6C697320526567756C6172272C20274E6F746F2053616E7320526567756C6172';
wwv_flow_imp.g_varchar2_table(210) := '275D2C0D0A20202020202020202020276974616C6963273A205B274D6574726F706F6C697320526567756C6172204974616C6963272C20274E6F746F2053616E73204974616C6963275D2C0D0A2020202020202020202027626F6C645F6974616C696327';
wwv_flow_imp.g_varchar2_table(211) := '3A205B274D6574726F706F6C697320426F6C64204974616C6963275D2C0D0A2020202020202020202027626F6C64273A205B274D6574726F706F6C697320426F6C64272C20274E6F746F2053616E7320426F6C64275D2C0D0A20202020202020207D3B0D';
wwv_flow_imp.g_varchar2_table(212) := '0A0D0A2020202020202020636F6E73742074657874466F6E74203D20666F6E74735B666F6E745374796C655D203F3F20666F6E74732E726567756C61723B0D0A0D0A2020202020202020636F6E73742063726561746553656C6563745374796C65203D20';
wwv_flow_imp.g_varchar2_table(213) := '2873656C65637465642C20756E73656C656374656429203D3E207B0D0A202020202020202020206966202867657453656C656374696F6E5374796C652829203D3D3D202770726F70657274792729207B0D0A20202020202020202020202072657475726E';
wwv_flow_imp.g_varchar2_table(214) := '205B0D0A20202020202020202020202020202763617365272C0D0A20202020202020202020202020205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A202020202020202020202020202073';
wwv_flow_imp.g_varchar2_table(215) := '656C65637465642C0D0A2020202020202020202020202020756E73656C65637465642C0D0A2020202020202020202020205D3B0D0A202020202020202020207D20656C7365207B0D0A20202020202020202020202072657475726E20756E73656C656374';
wwv_flow_imp.g_varchar2_table(216) := '65643B0D0A202020202020202020207D0D0A20202020202020207D0D0A0D0A202020202020202073776974636820286C617965722E7479706529207B0D0A2020202020202020202063617365202773796D626F6C273A0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(217) := '696620286C617965722E6C61796F75745B27746578742D6669656C64275D29207B0D0A20202020202020202020202020206C617965722E7061696E745B27746578742D636F6C6F72275D203F3F3D206372656174654578707228636F6C6F72293B0D0A20';
wwv_flow_imp.g_varchar2_table(218) := '202020202020202020202020206C617965722E7061696E745B27746578742D6F706163697479275D203F3F3D2063726561746545787072286F706163697479293B0D0A20202020202020202020202020206C617965722E6C61796F75745B27746578742D';
wwv_flow_imp.g_varchar2_table(219) := '666F6E74275D203F3F3D2074657874466F6E743B0D0A20202020202020202020202020206C617965722E6C61796F75745B27746578742D73697A65275D203F3F3D2031323B0D0A20202020202020202020202020206C617965722E7061696E745B277465';
wwv_flow_imp.g_varchar2_table(220) := '78742D68616C6F2D7769647468275D203F3F3D20312E353B0D0A20202020202020202020202020206C617965722E7061696E745B27746578742D68616C6F2D636F6C6F72275D203F3F3D2063726561746553656C6563745374796C652873656C65637469';
wwv_flow_imp.g_varchar2_table(221) := '6F6E436F6C6F722C2063726561746545787072286F75746C696E65436F6C6F7229207C7C20272363636327293B0D0A20202020202020202020202020206C617965722E6C61796F75745B27746578742D6A757374696679275D203F3F3D20276175746F27';
wwv_flow_imp.g_varchar2_table(222) := '3B0D0A0D0A2020202020202020202020202020696620286C617965722E6C61796F75745B2769636F6E2D696D616765275D29207B0D0A202020202020202020202020202020206C617965722E6C61796F75745B27746578742D6F6666736574275D203F3F';
wwv_flow_imp.g_varchar2_table(223) := '3D205B302C20302E355D3B0D0A2020202020202020202020202020202069662028216C617965722E6C61796F75745B27746578742D616E63686F72275D20262620216C617965722E6C61796F75745B27746578742D7661726961626C652D616E63686F72';
wwv_flow_imp.g_varchar2_table(224) := '275D29207B0D0A2020202020202020202020202020202020206C617965722E6C61796F75745B27746578742D7661726961626C652D616E63686F72275D203D205B27746F70272C20276C656674272C2027746F702D6C656674275D3B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(225) := '202020202020202020207D0D0A20202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A202020202020202020202020696620286C617965722E6C61796F75745B2769636F6E2D696D616765275D29207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(226) := '20202020202020206C617965722E6C61796F75745B2769636F6E2D616C6C6F772D6F7665726C6170275D203F3F3D20747275653B0D0A20202020202020202020202020206C617965722E6C61796F75745B27746578742D6F7074696F6E616C275D203F3F';
wwv_flow_imp.g_varchar2_table(227) := '3D20747275653B0D0A20202020202020202020202020206C617965722E7061696E745B2769636F6E2D636F6C6F72275D203F3F3D206372656174654578707228636F6C6F72293B0D0A20202020202020202020202020206C617965722E7061696E745B27';
wwv_flow_imp.g_varchar2_table(228) := '69636F6E2D6F706163697479275D203F3F3D2063726561746545787072286F706163697479293B0D0A20202020202020202020202020206C617965722E7061696E745B2769636F6E2D68616C6F2D7769647468275D203F3F3D2063726561746553656C65';
wwv_flow_imp.g_varchar2_table(229) := '63745374796C6528322C2063726561746545787072286F75746C696E65436F6C6F7229203F2031203A2030293B0D0A20202020202020202020202020206C617965722E7061696E745B2769636F6E2D68616C6F2D636F6C6F72275D203F3F3D2063726561';
wwv_flow_imp.g_varchar2_table(230) := '746553656C6563745374796C652873656C656374696F6E436F6C6F722C2063726561746545787072286F75746C696E65436F6C6F7229203F3F20277472616E73706172656E7427293B0D0A2020202020202020202020207D20656C7365207B0D0A202020';
wwv_flow_imp.g_varchar2_table(231) := '20202020202020202020206C617965722E6C61796F75745B27746578742D616C6C6F772D6F7665726C6170275D203F3F3D20747275653B0D0A2020202020202020202020207D0D0A202020202020202020202020627265616B3B0D0A0D0A202020202020';
wwv_flow_imp.g_varchar2_table(232) := '202020206361736520276C696E65273A0D0A2020202020202020202020206C617965722E7061696E745B276C696E652D636F6C6F72275D203F3F3D206372656174654578707228636F6C6F72293B0D0A2020202020202020202020206C617965722E7061';
wwv_flow_imp.g_varchar2_table(233) := '696E745B276C696E652D6F706163697479275D203F3F3D2063726561746545787072286F706163697479293B0D0A202020202020202020202020627265616B3B0D0A0D0A2020202020202020202063617365202766696C6C273A0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(234) := '202020206C617965722E7061696E745B2766696C6C2D636F6C6F72275D203F3F3D206372656174654578707228636F6C6F72293B0D0A2020202020202020202020206C617965722E7061696E745B2766696C6C2D6F706163697479275D203F3F3D206372';
wwv_flow_imp.g_varchar2_table(235) := '6561746545787072286F706163697479293B0D0A2020202020202020202020206C617965722E7061696E745B2766696C6C2D6F75746C696E652D636F6C6F72275D203F3F3D2063726561746545787072286F75746C696E65436F6C6F7229207C7C202762';
wwv_flow_imp.g_varchar2_table(236) := '6C61636B273B0D0A202020202020202020202020627265616B3B0D0A0D0A20202020202020202020636173652027636972636C65273A0D0A2020202020202020202020206C617965722E7061696E745B27636972636C652D6F706163697479275D203F3F';
wwv_flow_imp.g_varchar2_table(237) := '3D2063726561746545787072286F706163697479293B0D0A2020202020202020202020206C617965722E7061696E745B27636972636C652D636F6C6F72275D203F3F3D206372656174654578707228636F6C6F72293B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(238) := '696620286F75746C696E65436F6C6F7229207B0D0A20202020202020202020202020206C617965722E7061696E745B27636972636C652D7374726F6B652D636F6C6F72275D203F3F3D2063726561746545787072286F75746C696E65436F6C6F72293B0D';
wwv_flow_imp.g_varchar2_table(239) := '0A20202020202020202020202020206C617965722E7061696E745B27636972636C652D7374726F6B652D7769647468275D203F3F3D20313B0D0A2020202020202020202020207D0D0A202020202020202020202020627265616B3B0D0A0D0A2020202020';
wwv_flow_imp.g_varchar2_table(240) := '2020202020636173652027686561746D6170273A0D0A202020202020202020202020627265616B3B0D0A20202020202020207D0D0A0D0A202020202020202072657475726E206C617965723B0D0A2020202020207D293B0D0A0D0A202020202020696620';
wwv_flow_imp.g_varchar2_table(241) := '2867657453656C656374696F6E5374796C65282920213D3D202770726F70657274792729207B0D0A2020202020202020636F6E73742073656C656374696F6E4C6179657273203D205B5D3B0D0A202020202020202073656C656374696F6E4C6179657273';
wwv_flow_imp.g_varchar2_table(242) := '2E70757368287B0D0A2020202020202020202069643A20276C696E65272C0D0A20202020202020202020747970653A20276C696E65272C0D0A2020202020202020202066696C7465723A205B27696E272C205B2767656F6D657472792D74797065275D2C';
wwv_flow_imp.g_varchar2_table(243) := '205B276C69746572616C272C205B274C696E65537472696E67272C20274D756C74694C696E65537472696E67275D5D5D2C0D0A202020202020202020206C61796F75743A207B0D0A202020202020202020202020276C696E652D636170273A2073656C65';
wwv_flow_imp.g_varchar2_table(244) := '6374696F6E5374796C654F7074735B276C696E652D636170275D203F3F2027726F756E64272C0D0A202020202020202020207D2C0D0A202020202020202020207061696E743A207B0D0A202020202020202020202020276C696E652D6761702D77696474';
wwv_flow_imp.g_varchar2_table(245) := '68273A2073656C656374696F6E5374796C654F7074735B276C696E652D6761702D7769647468275D203F3F20332C0D0A202020202020202020202020276C696E652D7769647468273A2073656C656374696F6E5374796C654F7074735B276C696E652D77';
wwv_flow_imp.g_varchar2_table(246) := '69647468275D203F3F20322C0D0A202020202020202020202020276C696E652D636F6C6F72273A2073656C656374696F6E5374796C654F7074735B276C696E652D636F6C6F72275D203F3F2073656C656374696F6E436F6C6F722C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(247) := '2020207D2C0D0A20202020202020207D293B0D0A0D0A202020202020202073656C656374696F6E4C61796572732E70757368287B0D0A2020202020202020202069643A202766696C6C272C0D0A20202020202020202020747970653A202766696C6C272C';
wwv_flow_imp.g_varchar2_table(248) := '0D0A2020202020202020202066696C7465723A205B27696E272C205B2767656F6D657472792D74797065275D2C205B276C69746572616C272C205B27506F6C79676F6E272C20274D756C7469506F6C79676F6E275D5D5D2C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(249) := '6C61796F75743A207B7D2C0D0A202020202020202020207061696E743A207B0D0A2020202020202020202020202766696C6C2D636F6C6F72273A2073656C656374696F6E5374796C654F7074735B2766696C6C2D636F6C6F72275D203F3F2073656C6563';
wwv_flow_imp.g_varchar2_table(250) := '74696F6E436F6C6F722C0D0A2020202020202020202020202766696C6C2D6F706163697479273A2073656C656374696F6E5374796C654F7074735B2766696C6C2D6F706163697479275D203F3F20302E352C0D0A202020202020202020207D2C0D0A2020';
wwv_flow_imp.g_varchar2_table(251) := '2020202020207D293B0D0A0D0A202020202020202073656C656374696F6E4C61796572732E70757368287B0D0A2020202020202020202069643A202766696C6C2D6F75746C696E65272C0D0A20202020202020202020747970653A20276C696E65272C0D';
wwv_flow_imp.g_varchar2_table(252) := '0A2020202020202020202066696C7465723A205B27696E272C205B2767656F6D657472792D74797065275D2C205B276C69746572616C272C205B27506F6C79676F6E272C20274D756C7469506F6C79676F6E275D5D5D2C0D0A202020202020202020206C';
wwv_flow_imp.g_varchar2_table(253) := '61796F75743A207B7D2C0D0A202020202020202020207061696E743A207B0D0A202020202020202020202020276C696E652D636F6C6F72273A2073656C656374696F6E5374796C654F7074735B276C696E652D636F6C6F72275D203F3F2073656C656374';
wwv_flow_imp.g_varchar2_table(254) := '696F6E436F6C6F722C0D0A202020202020202020202020276C696E652D7769647468273A2073656C656374696F6E5374796C654F7074735B276C696E652D7769647468275D203F3F20322C0D0A202020202020202020207D2C0D0A20202020202020207D';
wwv_flow_imp.g_varchar2_table(255) := '293B0D0A0D0A202020202020202073656C656374696F6E4C61796572732E70757368287B0D0A2020202020202020202069643A2027706F696E74272C0D0A20202020202020202020747970653A2027636972636C65272C0D0A2020202020202020202066';
wwv_flow_imp.g_varchar2_table(256) := '696C7465723A205B27696E272C205B2767656F6D657472792D74797065275D2C205B276C69746572616C272C205B27506F696E74272C20274D756C7469506F696E74275D5D5D2C0D0A202020202020202020207061696E743A207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(257) := '202020202027636972636C652D726164697573273A2073656C656374696F6E5374796C654F7074735B27636972636C652D726164697573275D203F3F2063726561746545787072287261646975732C207061727365466C6F617429203F3F20352C0D0A20';
wwv_flow_imp.g_varchar2_table(258) := '202020202020202020202027636972636C652D636F6C6F72273A2073656C656374696F6E5374796C654F7074735B27636972636C652D636F6C6F72275D203F3F20277472616E73706172656E74272C0D0A20202020202020202020202027636972636C65';
wwv_flow_imp.g_varchar2_table(259) := '2D7374726F6B652D636F6C6F72273A2073656C656374696F6E5374796C654F7074735B27636972636C652D7374726F6B652D636F6C6F72275D203F3F2073656C656374696F6E436F6C6F722C0D0A20202020202020202020202027636972636C652D7374';
wwv_flow_imp.g_varchar2_table(260) := '726F6B652D7769647468273A2073656C656374696F6E5374796C654F7074735B27636972636C652D7374726F6B652D7769647468275D203F3F20322C0D0A202020202020202020207D2C0D0A20202020202020207D293B0D0A0D0A202020202020202063';
wwv_flow_imp.g_varchar2_table(261) := '6F6E73742066696C746572203D2067657453656C6563746564466561747572657346696C74657228293B0D0A2020202020202020666F722028636F6E7374206C206F662073656C656374696F6E4C617965727329207B0D0A202020202020202020206C61';
wwv_flow_imp.g_varchar2_table(262) := '796572732E70757368287B0D0A2020202020202020202020202E2E2E6C2C0D0A20202020202020202020202069643A206974656D4964202B20272D2D73656C656374696F6E2D27202B206C2E69642C0D0A202020202020202020202020736F757263653A';
wwv_flow_imp.g_varchar2_table(263) := '20736F757263654E616D652C0D0A2020202020202020202020206D657461646174613A207B0D0A20202020202020202020202020206C617965725F73657175656E63653A2073657175656E63654E756D6265722C0D0A2020202020202020202020207D2C';
wwv_flow_imp.g_varchar2_table(264) := '0D0A20202020202020202020202066696C7465723A206C2E66696C746572203F205B27616C6C272C206C2E66696C7465722C2066696C7465725D203A2066696C7465722C0D0A202020202020202020207D293B0D0A20202020202020207D0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(265) := '20202020202075706461746553656C656374696F6E4C6179657273203D206173796E63202829203D3E207B0D0A20202020202020202020636F6E7374206D6170203D2061776169742070656E64696E674D61703B0D0A20202020202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(266) := '742066696C746572203D2067657453656C6563746564466561747572657346696C74657228293B0D0A20202020202020202020666F722028636F6E7374206C206F662073656C656374696F6E4C617965727329207B0D0A2020202020202020202020206D';
wwv_flow_imp.g_varchar2_table(267) := '61702E73657446696C746572286974656D4964202B20272D2D73656C656374696F6E2D27202B206C2E69642C206C2E66696C746572203F205B27616C6C272C206C2E66696C7465722C2066696C7465725D203A2066696C746572293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(268) := '202020207D0D0A20202020202020207D3B0D0A2020202020207D0D0A0D0A202020202020636F6E7374206D6170626974736C6179657273203D206D61702E6765745374796C6528292E6C61796572732E66696C746572282876616C29203D3E207B0D0A20';
wwv_flow_imp.g_varchar2_table(269) := '2020202020202069662028276D657461646174612720696E2076616C29207B200D0A2020202020202020202072657475726E20276C617965725F73657175656E63652720696E2076616C2E6D657461646174613B0D0A20202020202020207D20656C7365';
wwv_flow_imp.g_varchar2_table(270) := '207B0D0A2020202020202020202072657475726E2066616C73653B0D0A20202020202020207D0D0A2020202020207D292E6D61702866756E6374696F6E2876616C29207B72657475726E205B76616C2E6D657461646174612E6C617965725F7365717565';
wwv_flow_imp.g_varchar2_table(271) := '6E63652C2076616C2E69645D7D293B0D0A2020202020206C6574206265666F72654C617965723B0D0A202020202020696620286D6170626974736C61796572732E6C656E67746820213D3D203029207B0D0A20202020202020206D6170626974736C6179';
wwv_flow_imp.g_varchar2_table(272) := '6572732E736F72742828612C206229203D3E20615B305D202D20625B305D293B0D0A2020202020202020666F72286C65742069203D20303B2069203C206D6170626974736C61796572732E6C656E6774683B20692B2B29207B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(273) := '206966202873657175656E63654E756D626572203C206D6170626974736C61796572735B695D5B305D29207B0D0A2020202020202020202020206265666F72654C61796572203D206D6170626974736C61796572735B695D5B315D3B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(274) := '202020202020627265616B3B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D0D0A0D0A2020202020206C6574206C61737453656C656374656446656174757265203D206E756C6C3B0D0A0D0A202020202020666F7220';
wwv_flow_imp.g_varchar2_table(275) := '28636F6E7374206C206F66206C617965727329207B0D0A2020202020202020747279207B0D0A202020202020202020206D61702E6164644C61796572286C2C206265666F72654C61796572293B0D0A0D0A2020202020202020202069662028696E666F57';
wwv_flow_imp.g_varchar2_table(276) := '696E4265686176696F72207C7C20736964656261724265686176696F7229207B0D0A202020202020202020202020636F6E737420616464496E666F57696E203D202877696E29203D3E207B0D0A202020202020202020202020202069662028216D61702E';
wwv_flow_imp.g_varchar2_table(277) := '5F5F6D6170626974735F5F696E666F5F77696E646F775F6461746129207B0D0A20202020202020202020202020202020636F6E73742073696465626172203D206E65772053696465626172436F6E74726F6C286D6170293B0D0A0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(278) := '20202020202020206D61702E5F5F6D6170626974735F5F696E666F5F77696E646F775F64617461203D207B0D0A202020202020202020202020202020202020686F766572506F7075703A206E6577206D61706C69627265676C2E506F707570287B0D0A20';
wwv_flow_imp.g_varchar2_table(279) := '20202020202020202020202020202020202020636C6F7365427574746F6E3A2066616C73652C0D0A2020202020202020202020202020202020202020636C6F73654F6E436C69636B3A2066616C73652C0D0A202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(280) := '2020636C6173734E616D653A20276D6170626974732D686F7665722D706F707570206D6170626974732D696E666F2D636F6E74656E74272C0D0A2020202020202020202020202020202020207D292E747261636B506F696E74657228292C0D0A20202020';
wwv_flow_imp.g_varchar2_table(281) := '2020202020202020202020202020636C69636B506F7075703A206E756C6C2C0D0A202020202020202020202020202020202020736964656261722C0D0A202020202020202020202020202020202020736964656261724D61726B65723A206E756C6C2C0D';
wwv_flow_imp.g_varchar2_table(282) := '0A202020202020202020202020202020202020696E666F57696E646F77733A207B7D2C0D0A20202020202020202020202020202020202074656D706C6174654F7574707574733A207B7D2C0D0A202020202020202020202020202020207D3B0D0A202020';
wwv_flow_imp.g_varchar2_table(283) := '20202020202020202020207D0D0A0D0A2020202020202020202020202020636F6E73742064617461203D206D61702E5F5F6D6170626974735F5F696E666F5F77696E646F775F646174613B0D0A202020202020202020202020202069662028646174612E';
wwv_flow_imp.g_varchar2_table(284) := '696E666F57696E646F77735B6C2E69645D29207B0D0A20202020202020202020202020202020646174612E696E666F57696E646F77735B6C2E69645D2E707573682877696E293B0D0A20202020202020202020202020207D20656C7365207B0D0A202020';
wwv_flow_imp.g_varchar2_table(285) := '20202020202020202020202020646174612E696E666F57696E646F77735B6C2E69645D203D205B77696E5D3B0D0A20202020202020202020202020207D0D0A0D0A20202020202020202020202020206966202877696E2E6C6F636174696F6E203D3D3D20';
wwv_flow_imp.g_varchar2_table(286) := '27736964656261722729207B0D0A20202020202020202020202020202020696620285B27686F766572272C2027686F7665725F6F6E6C79275D2E696E636C756465732877696E2E6265686176696F722929207B0D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(287) := '202020636F6E737420757064617465486F76657253696465626172203D2028657629203D3E207B0D0A202020202020202020202020202020202020202069662028646174612E736964656261724D61726B6572203D3D3D206E756C6C29207B0D0A202020';
wwv_flow_imp.g_varchar2_table(288) := '202020202020202020202020202020202020202F2A20446F6E27742073686F772074686520686F76657220636F6E74656E742069662074686572652773206120636C69636B20616374697665202A2F0D0A20202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(289) := '202020757064617465506F707570537461636B2865762C205B27686F766572272C2027686F7665725F6F6E6C79275D2C20646174612E736964656261722C206D6170293B0D0A20202020202020202020202020202020202020207D0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(290) := '20202020202020202020207D3B0D0A0D0A2020202020202020202020202020202020206D61702E6F6E28276D6F757365656E746572272C206C2E69642C20757064617465486F76657253696465626172293B0D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(291) := '20206D61702E6F6E28276D6F7573656D6F7665272C206C2E69642C20757064617465486F76657253696465626172293B0D0A2020202020202020202020202020202020206D61702E6F6E28276D6F7573656C65617665272C206C2E69642C207570646174';
wwv_flow_imp.g_varchar2_table(292) := '65486F76657253696465626172293B0D0A2020202020202020202020202020202020206D61702E676574436F6E7461696E657228292E6164644576656E744C697374656E657228276D6F7573656C65617665272C202829203D3E207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(293) := '20202020202020202020202020206966202821646174612E736964656261724D61726B657229207B0D0A20202020202020202020202020202020202020202020646174612E736964656261722E6869646528293B0D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(294) := '2020202020207D0D0A2020202020202020202020202020202020207D293B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020696620285B27636C69636B272C2027686F766572275D2E696E636C75646573';
wwv_flow_imp.g_varchar2_table(295) := '2877696E2E6265686176696F722929207B0D0A2020202020202020202020202020202020206D61702E6F6E2827636C69636B272C206C2E69642C2028657629203D3E207B0D0A202020202020202020202020202020202020202069662028646174612E73';
wwv_flow_imp.g_varchar2_table(296) := '6964656261724D61726B657229207B0D0A20202020202020202020202020202020202020202020646174612E736964656261724D61726B65722E72656D6F766528293B0D0A20202020202020202020202020202020202020207D0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(297) := '202020202020202020202020646174612E736964656261724D61726B6572203D206E6577206D61706C69627265676C2E4D61726B657228292E7365744C6E674C61742865762E6C6E674C6174292E616464546F286D6170293B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(298) := '2020202020202020202020757064617465506F707570537461636B2865762C205B27636C69636B272C2027686F766572275D2C20646174612E736964656261722C206D6170293B0D0A2020202020202020202020202020202020207D293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(299) := '2020202020202020202020207D0D0A20202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020696620285B27686F766572272C2027686F7665725F6F6E6C79275D2E696E636C756465732877696E2E62656861';
wwv_flow_imp.g_varchar2_table(300) := '76696F722929207B0D0A202020202020202020202020202020202020636F6E737420757064617465486F766572506F707570203D2028657629203D3E207B0D0A202020202020202020202020202020202020202069662028646174612E636C69636B506F';
wwv_flow_imp.g_varchar2_table(301) := '707570203D3D3D206E756C6C29207B0D0A202020202020202020202020202020202020202020202F2A20446F6E27742073686F772074686520686F76657220706F7075702069662074686572652773206120636C69636B20706F70757020616374697665';
wwv_flow_imp.g_varchar2_table(302) := '202A2F0D0A20202020202020202020202020202020202020202020757064617465506F707570537461636B2865762C205B27686F766572272C2027686F7665725F6F6E6C79275D2C20646174612E686F766572506F7075702C206D6170293B0D0A202020';
wwv_flow_imp.g_varchar2_table(303) := '20202020202020202020202020202020207D0D0A2020202020202020202020202020202020207D3B0D0A0D0A2020202020202020202020202020202020206D61702E6F6E28276D6F757365656E746572272C206C2E69642C20757064617465486F766572';
wwv_flow_imp.g_varchar2_table(304) := '506F707570293B0D0A2020202020202020202020202020202020206D61702E6F6E28276D6F7573656D6F7665272C206C2E69642C20757064617465486F766572506F707570293B0D0A2020202020202020202020202020202020206D61702E6F6E28276D';
wwv_flow_imp.g_varchar2_table(305) := '6F7573656C65617665272C206C2E69642C20757064617465486F766572506F707570293B0D0A2020202020202020202020202020202020206D61702E676574436F6E7461696E657228292E6164644576656E744C697374656E657228276D6F7573656C65';
wwv_flow_imp.g_varchar2_table(306) := '617665272C202829203D3E207B0D0A2020202020202020202020202020202020202020646174612E686F766572506F7075702E72656D6F766528293B0D0A2020202020202020202020202020202020207D293B0D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(307) := '207D0D0A0D0A20202020202020202020202020202020696620285B27636C69636B272C2027686F766572275D2E696E636C756465732877696E2E6265686176696F722929207B0D0A2020202020202020202020202020202020206D61702E6F6E2827636C';
wwv_flow_imp.g_varchar2_table(308) := '69636B272C206C2E69642C2028657629203D3E207B0D0A202020202020202020202020202020202020202069662028646174612E636C69636B506F70757020213D3D206E756C6C29207B0D0A202020202020202020202020202020202020202020207265';
wwv_flow_imp.g_varchar2_table(309) := '7475726E3B0D0A20202020202020202020202020202020202020207D0D0A0D0A2020202020202020202020202020202020202020636F6E737420706F707570203D206E6577206D61706C69627265676C2E506F707570287B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(310) := '202020202020202020202020636C6173734E616D653A20276D6170626974732D636C69636B2D706F707570206D6170626974732D696E666F2D636F6E74656E74272C0D0A20202020202020202020202020202020202020207D293B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(311) := '20202020202020202020202020757064617465506F707570537461636B2865762C205B27636C69636B272C2027686F766572275D2C20706F7075702C206D6170293B0D0A20202020202020202020202020202020202020202F2A20496620796F7520636C';
wwv_flow_imp.g_varchar2_table(312) := '69636B206120636C7573746572656420706F696E742C207468657265206D69676874206E6F742061637475616C6C79206265206120706F707570202A2F0D0A202020202020202020202020202020202020202069662028706F7075702E69734F70656E28';
wwv_flow_imp.g_varchar2_table(313) := '2929207B0D0A20202020202020202020202020202020202020202020646174612E636C69636B506F707570203D20706F7075703B0D0A20202020202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020202020202064';
wwv_flow_imp.g_varchar2_table(314) := '6174612E686F766572506F7075702E72656D6F766528293B0D0A2020202020202020202020202020202020202020706F7075702E6F6E2827636C6F7365272C202829203D3E207B0D0A20202020202020202020202020202020202020202020646174612E';
wwv_flow_imp.g_varchar2_table(315) := '636C69636B506F707570203D206E756C6C3B0D0A20202020202020202020202020202020202020207D293B0D0A2020202020202020202020202020202020207D293B0D0A202020202020202020202020202020207D0D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(316) := '207D0D0A2020202020202020202020207D3B0D0A0D0A202020202020202020202020636F6E737420616464496E666F57696E646F7773203D20286265686176696F722C20657870722C20636C69636B457870722C206C6F636174696F6E29203D3E207B0D';
wwv_flow_imp.g_varchar2_table(317) := '0A2020202020202020202020202020696620286265686176696F72203D3D3D202773657061726174652729207B0D0A20202020202020202020202020202020616464496E666F57696E287B0D0A20202020202020202020202020202020202068746D6C45';
wwv_flow_imp.g_varchar2_table(318) := '787072657373696F6E3A20657870722C0D0A2020202020202020202020202020202020206974656D4E616D653A206974656D49642C0D0A2020202020202020202020202020202020206265686176696F723A2027686F7665725F6F6E6C79272C0D0A2020';
wwv_flow_imp.g_varchar2_table(319) := '2020202020202020202020202020202073657175656E63654E756D6265722C0D0A2020202020202020202020202020202020206C6F636174696F6E2C0D0A202020202020202020202020202020207D293B0D0A2020202020202020202020202020202061';
wwv_flow_imp.g_varchar2_table(320) := '6464496E666F57696E287B0D0A20202020202020202020202020202020202068746D6C45787072657373696F6E3A20636C69636B457870722C0D0A2020202020202020202020202020202020206974656D4E616D653A206974656D49642C0D0A20202020';
wwv_flow_imp.g_varchar2_table(321) := '20202020202020202020202020206265686176696F723A2027636C69636B272C0D0A20202020202020202020202020202020202073657175656E63654E756D6265722C0D0A2020202020202020202020202020202020206C6F636174696F6E2C0D0A2020';
wwv_flow_imp.g_varchar2_table(322) := '20202020202020202020202020207D293B0D0A20202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020616464496E666F57696E287B0D0A20202020202020202020202020202020202068746D6C4578707265';
wwv_flow_imp.g_varchar2_table(323) := '7373696F6E3A20657870722C0D0A2020202020202020202020202020202020206974656D4E616D653A206974656D49642C0D0A2020202020202020202020202020202020206265686176696F723A206265686176696F722C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(324) := '202020202020202073657175656E63654E756D6265722C0D0A2020202020202020202020202020202020206C6F636174696F6E2C0D0A202020202020202020202020202020207D293B0D0A20202020202020202020202020207D0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(325) := '202020207D3B0D0A0D0A202020202020202020202020616464496E666F57696E646F777328696E666F57696E4265686176696F722C20696E666F57696E457870722C20696E666F57696E436C69636B457870722C2027706F70757027293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(326) := '2020202020202020616464496E666F57696E646F777328736964656261724265686176696F722C2073696465626172457870722C2073696465626172436C69636B457870722C20277369646562617227293B0D0A202020202020202020207D0D0A0D0A20';
wwv_flow_imp.g_varchar2_table(327) := '202020202020202020696620286973436C69636B61626C65282929207B0D0A2020202020202020202020206D61702E5F5F6D6170626974735F6C617965725F637572736F72732E736574286C2E69642C2027706F696E74657227293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(328) := '202020202020636F6E737420736574506F696E746572203D2028657629203D3E207B0D0A2020202020202020202020202020666F722028636F6E73742066656174206F66206D61702E717565727952656E646572656446656174757265732865762E706F';
wwv_flow_imp.g_varchar2_table(329) := '696E742929207B0D0A20202020202020202020202020202020696620286D61702E5F5F6D6170626974735F6C617965725F637572736F72732E68617328666561742E6C617965723F2E69642929207B0D0A2020202020202020202020202020202020206D';
wwv_flow_imp.g_varchar2_table(330) := '61702E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F72203D206D61702E5F5F6D6170626974735F6C617965725F637572736F72732E67657428666561742E6C617965722E6964293B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(331) := '20202020202072657475726E3B0D0A202020202020202020202020202020207D0D0A20202020202020202020202020207D0D0A20202020202020202020202020206D61702E67657443616E766173436F6E7461696E657228292E7374796C652E72656D6F';
wwv_flow_imp.g_varchar2_table(332) := '766550726F70657274792827637572736F7227293B0D0A2020202020202020202020207D3B0D0A2020202020202020202020206D61702E6F6E28276D6F757365656E746572272C206C2E69642C20736574506F696E746572293B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(333) := '202020206D61702E6F6E28276D6F7573656C65617665272C206C2E69642C20736574506F696E746572293B0D0A0D0A2020202020202020202020202F2A2044697361626C6520626F78207A6F6F6D207768656E20636C69636B696E6720612073656C6563';
wwv_flow_imp.g_varchar2_table(334) := '7461626C65206C617965722C2073696E636520697420696E7465726665726573207769746820736869667420636C69636B696E67202A2F0D0A202020202020202020202020696628636C69636B53656C65637420262620636C69636B4F72646572427929';
wwv_flow_imp.g_varchar2_table(335) := '207B0D0A20202020202020202020202020206C657420626F785A6F6F6D576173456E61626C6564203D2066616C73653B0D0A0D0A20202020202020202020202020206D61702E6F6E28276D6F757365646F776E272C206C2E69642C2028657629203D3E20';
wwv_flow_imp.g_varchar2_table(336) := '7B0D0A202020202020202020202020202020206966202865762E6F726967696E616C4576656E742E73686966744B657929207B0D0A202020202020202020202020202020202020636F6E7374206973546F706D6F73744C61796572203D206D61702E7175';
wwv_flow_imp.g_varchar2_table(337) := '65727952656E646572656446656174757265732865762E706F696E74295B305D2E6C617965722E6964203D3D3D2065762E66656174757265735B305D2E6C617965722E69643B0D0A202020202020202020202020202020202020696620286973546F706D';
wwv_flow_imp.g_varchar2_table(338) := '6F73744C6179657229207B0D0A2020202020202020202020202020202020202020626F785A6F6F6D576173456E61626C6564203D206D61702E626F785A6F6F6D2E6973456E61626C656428293B0D0A20202020202020202020202020202020202020206D';
wwv_flow_imp.g_varchar2_table(339) := '61702E626F785A6F6F6D2E64697361626C6528293B0D0A2020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A20202020202020202020202020207D293B0D0A0D0A20202020202020202020202020206D61';
wwv_flow_imp.g_varchar2_table(340) := '702E6F6E28276D6F7573657570272C206C2E69642C202829203D3E207B0D0A2020202020202020202020202020202069662028626F785A6F6F6D576173456E61626C656429207B0D0A2020202020202020202020202020202020206D61702E626F785A6F';
wwv_flow_imp.g_varchar2_table(341) := '6F6D2E656E61626C6528293B0D0A202020202020202020202020202020207D0D0A20202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020206D61702E6F6E2827636C69636B272C206C2E69';
wwv_flow_imp.g_varchar2_table(342) := '642C2028657629203D3E207B0D0A2020202020202020202020202020636F6E7374206973546F706D6F73744C61796572203D206D61702E717565727952656E646572656446656174757265732865762E706F696E74295B305D2E6C617965722E6964203D';
wwv_flow_imp.g_varchar2_table(343) := '3D3D2065762E66656174757265735B305D2E6C617965722E69643B0D0A2020202020202020202020202020636F6E7374206964203D2069644D61702E6765742865762E66656174757265735B305D2E6964293B0D0A0D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(344) := '20617065782E6576656E742E7472696767657228272327202B206974656D49642C2027636C69636B272C207B0D0A20202020202020202020202020202020666561747572653A207B0D0A202020202020202020202020202020202020747970653A202746';
wwv_flow_imp.g_varchar2_table(345) := '656174757265272C0D0A20202020202020202020202020202020202069642C0D0A20202020202020202020202020202020202070726F706572746965733A2065762E66656174757265735B305D2E70726F706572746965732C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(346) := '20202020202020202067656F6D657472793A2065762E66656174757265735B305D2E67656F6D657472792C0D0A202020202020202020202020202020207D2C0D0A202020202020202020202020202020206973546F706D6F73744C617965722C0D0A2020';
wwv_flow_imp.g_varchar2_table(347) := '2020202020202020202020202020706F696E743A2065762E706F696E742C0D0A20202020202020202020202020207D293B0D0A0D0A202020202020202020202020202069662028636C69636B53656C656374202626206973546F706D6F73744C61796572';
wwv_flow_imp.g_varchar2_table(348) := '29207B0D0A202020202020202020202020202020206966202865762E6F726967696E616C4576656E742E6374726C4B657920262620636C69636B4D756C746953656C65637429207B0D0A20202020202020202020202020202020202073657453656C6563';
wwv_flow_imp.g_varchar2_table(349) := '7465644665617475726573285B69645D2C2027746F67676C6527293B0D0A202020202020202020202020202020207D20656C736520696620280D0A20202020202020202020202020202020202065762E6F726967696E616C4576656E742E73686966744B';
wwv_flow_imp.g_varchar2_table(350) := '65790D0A202020202020202020202020202020202020262620636C69636B4F7264657242790D0A202020202020202020202020202020202020262620636C69636B4D756C746953656C6563740D0A2020202020202020202020202020202020202626206C';
wwv_flow_imp.g_varchar2_table(351) := '61737453656C6563746564466561747572650D0A2020202020202020202020202020202029207B0D0A202020202020202020202020202020202020636F6E7374206F726465724279203D2065762E66656174757265735B305D2E70726F70657274696573';
wwv_flow_imp.g_varchar2_table(352) := '5B636C69636B4F7264657242795D3B0D0A202020202020202020202020202020202020636F6E737420706172746974696F6E4279203D2065762E66656174757265735B305D2E70726F706572746965735B636C69636B506172746974696F6E42795D3B0D';
wwv_flow_imp.g_varchar2_table(353) := '0A202020202020202020202020202020202020636F6E737420616464203D205B5D3B0D0A0D0A20202020202020202020202020202020202069662028636C69636B506172746974696F6E427920262620706172746974696F6E427920213D3D206C617374';
wwv_flow_imp.g_varchar2_table(354) := '53656C6563746564466561747572652E70726F706572746965735B636C69636B506172746974696F6E42795D29207B0D0A20202020202020202020202020202020202020202F2A20546865206C6173742073656C6563746564206665617475726520616E';
wwv_flow_imp.g_varchar2_table(355) := '642074686520636C69636B656420666561747572652061726520696E20646966666572656E7420706172746974696F6E732E20416464206A7573742074686520636C69636B656420666561747572652E202A2F0D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(356) := '20202020206164642E70757368286964293B0D0A2020202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020666F722028636F6E73742066656174206F6620666561747572657329207B0D0A';
wwv_flow_imp.g_varchar2_table(357) := '202020202020202020202020202020202020202020206966202821636C69636B506172746974696F6E4279207C7C20706172746974696F6E4279203D3D3D20666561742E70726F706572746965735B636C69636B506172746974696F6E42795D29207B0D';
wwv_flow_imp.g_varchar2_table(358) := '0A202020202020202020202020202020202020202020202020636F6E7374206F203D20666561742E70726F706572746965735B636C69636B4F7264657242795D3B0D0A202020202020202020202020202020202020202020202020636F6E7374206C6173';
wwv_flow_imp.g_varchar2_table(359) := '744F203D206C61737453656C6563746564466561747572652E70726F706572746965735B636C69636B4F7264657242795D3B0D0A20202020202020202020202020202020202020202020202069662028286F726465724279203E206C6173744F20262620';
wwv_flow_imp.g_varchar2_table(360) := '6F726465724279203E3D206F202626206F203E3D206C6173744F29207C7C20286F726465724279203C3D206C6173744F202626206F726465724279203C3D206F202626206F203C3D206C6173744F2929207B0D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(361) := '202020202020202020206164642E7075736828666561742E6964293B0D0A2020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(362) := '20207D0D0A2020202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020202073657453656C65637465644665617475726573286164642C202761646427293B0D0A202020202020202020202020202020207D20656C';
wwv_flow_imp.g_varchar2_table(363) := '7365207B0D0A20202020202020202020202020202020202073657453656C65637465644665617475726573285B69645D2C202773657427293B0D0A202020202020202020202020202020207D0D0A0D0A202020202020202020202020202020206C617374';
wwv_flow_imp.g_varchar2_table(364) := '53656C656374656446656174757265203D2065762E66656174757265735B305D3B0D0A20202020202020202020202020207D0D0A0D0A2020202020202020202020202020696620286C696E6B202626206973546F706D6F73744C6179657229207B0D0A20';
wwv_flow_imp.g_varchar2_table(365) := '202020202020202020202020202020617065782E6E617669676174696F6E2E7265646972656374286C696E6B293B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D293B0D0A202020202020202020207D0D0A2020202020';
wwv_flow_imp.g_varchar2_table(366) := '2020207D2063617463682028657863657074696F6E29207B0D0A20202020202020202020617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B6974656D49647D203A204661696C656420746F206164';
wwv_flow_imp.g_varchar2_table(367) := '64206C6179657220247B6C2E69647D602C20657863657074696F6E293B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A2020202020206C61796572494473203D206C61796572732E6D6170286C203D3E206C2E6964293B0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(368) := '20207365744C61796572735669736962696C697479203D20287669736962696C69747929203D3E207B0D0A2020202020202020666F722028636F6E7374206C61796572206F66206C617965727329207B0D0A202020202020202020206D61702E7365744C';
wwv_flow_imp.g_varchar2_table(369) := '61796F757450726F7065727479286C617965722E69642C20277669736962696C697479272C207669736962696C697479293B0D0A20202020202020207D0D0A202020202020202073746F726167652E7365744974656D28274D6170626974735F4C6F6465';
wwv_flow_imp.g_varchar2_table(370) := '737461724C617965725F27202B206974656D4964202B20275F7669736962696C697479272C207669736962696C697479293B0D0A20202020202020206C61796572735669736962696C697479203D207669736962696C6974793B0D0A0D0A202020202020';
wwv_flow_imp.g_varchar2_table(371) := '2020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C207669736962696C697479203D3D3D202776697369626C6527293B0D0A0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(372) := '617065782E6576656E742E7472696767657228272327202B206974656D49642C20277669736962696C6974795F746F67676C6564272C207B0D0A2020202020202020202076697369626C653A207669736962696C697479203D3D3D202776697369626C65';
wwv_flow_imp.g_varchar2_table(373) := '272C0D0A20202020202020207D293B0D0A2020202020207D0D0A0D0A202020202020696620286C61796572735669736962696C697479203D3D20276E6F6E652729207B0D0A20202020202020207365744C61796572735669736962696C69747928276E6F';
wwv_flow_imp.g_varchar2_table(374) := '6E6527293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A2020202020207D20656C7365207B0D0A';
wwv_flow_imp.g_varchar2_table(375) := '20202020202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F70282763';
wwv_flow_imp.g_varchar2_table(376) := '6865636B6564272C2074727565293B0D0A2020202020207D0D0A0D0A202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E6368616E67652866756E6374696F6E2865297B0D0A20';
wwv_flow_imp.g_varchar2_table(377) := '202020202020206C6574206362203D20617065782E6A51756572792874686973293B0D0A20202020202020207365744C61796572735669736962696C6974792863622E697328273A636865636B65642729203F202776697369626C6527203A20276E6F6E';
wwv_flow_imp.g_varchar2_table(378) := '6527293B0D0A2020202020207D293B0D0A0D0A202020202020666F722028636F6E73742066756E63206F662077616974466F724C6F616429207B0D0A202020202020202066756E6328293B0D0A2020202020207D0D0A20202020202077616974466F724C';
wwv_flow_imp.g_varchar2_table(379) := '6F6164203D206E756C6C3B0D0A202020207D20656C7365207B0D0A2020202020202F2A20546865206C6179657273206861766520616C7265616479206265656E2061646465642C20627574206D6179206E65656420746F2062652075706461746564202A';
wwv_flow_imp.g_varchar2_table(380) := '2F0D0A20202020202075706461746553656C656374696F6E4C61796572733F2E28293B0D0A202020207D0D0A20207D3B0D0A0D0A2020636F6E73742073657453656C65637465644665617475726573203D202866656174757265732C20616374696F6E29';
wwv_flow_imp.g_varchar2_table(381) := '203D3E207B0D0A202020206665617475726573203D206665617475726573203F3F205B5D3B0D0A202020206F6C6453656C656374696F6E203D2073656C656374656446656174757265733B0D0A202020207377697463682028616374696F6E203F3F2027';
wwv_flow_imp.g_varchar2_table(382) := '7365742729207B0D0A202020202020636173652027736574273A0D0A202020202020202073656C65637465644665617475726573203D206E657720536574286665617475726573293B0D0A2020202020202020627265616B3B0D0A202020202020636173';
wwv_flow_imp.g_varchar2_table(383) := '652027616464273A0D0A20202020202020206966202873656C6563746564466561747572657329207B0D0A20202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A20202020202020202020202073656C656374';
wwv_flow_imp.g_varchar2_table(384) := '656446656174757265732E6164642866293B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020202020627265616B3B0D0A20202020202063617365202772656D6F7665273A0D0A20202020202020206966202873656C656374';
wwv_flow_imp.g_varchar2_table(385) := '6564466561747572657329207B0D0A20202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A20202020202020202020202073656C656374656446656174757265732E64656C6574652866293B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(386) := '20202020207D0D0A20202020202020207D0D0A2020202020202020627265616B3B0D0A202020202020636173652027746F67676C65273A0D0A20202020202020206966202873656C6563746564466561747572657329207B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(387) := '666F722028636F6E73742066206F6620666561747572657329207B0D0A2020202020202020202020206966202873656C656374656446656174757265732E68617328662929207B0D0A202020202020202020202020202073656C65637465644665617475';
wwv_flow_imp.g_varchar2_table(388) := '7265732E64656C6574652866293B0D0A2020202020202020202020207D20656C7365207B0D0A202020202020202020202020202073656C656374656446656174757265732E6164642866293B0D0A2020202020202020202020207D0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(389) := '2020207D0D0A20202020202020207D0D0A2020202020202020627265616B3B0D0A202020207D0D0A0D0A202020206966202867657453656C656374696F6E5374796C652829203D3D3D202770726F70657274792729207B0D0A20202020202072656C6F61';
wwv_flow_imp.g_varchar2_table(390) := '64536F757263654461746128293B0D0A202020207D20656C7365206966202875706461746553656C656374696F6E4C617965727329207B0D0A20202020202075706461746553656C656374696F6E4C617965727328293B0D0A202020207D0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(391) := '2020617065782E6576656E742E7472696767657228272327202B206974656D49642C202773656C656374696F6E5F6368616E67656427293B0D0A20207D3B0D0A0D0A2020636C6173732052656374616E676C6553656C656374436F6E74726F6C207B0D0A';
wwv_flow_imp.g_varchar2_table(392) := '20202020636F6E7374727563746F722829207B0D0A202020202020746869732E6C6179657273203D205B5D3B0D0A202020202020746869732E616374697665203D2066616C73653B0D0A202020207D0D0A0D0A202020206164644C61796572286C617965';
wwv_flow_imp.g_varchar2_table(393) := '7229207B0D0A202020202020746869732E6C61796572732E70757368286C61796572293B0D0A202020207D0D0A0D0A202020206F6E416464286D617029207B0D0A2020202020202F2A20746865203C6469763E207468617420666F726D73207468652073';
wwv_flow_imp.g_varchar2_table(394) := '656C656374696F6E20626F78202A2F0D0A2020202020206C657420626F7853656C656374203D206E756C6C3B0D0A2020202020202F2A2074686520737461727420706F736974696F6E206F66207468652072656374616E676C652C20696E20706978656C';
wwv_flow_imp.g_varchar2_table(395) := '20636F6F7264696E61746573202A2F0D0A2020202020206C6574207374617274506F73203D206E756C6C3B0D0A2020202020202F2A2057652064697361626C652070616E6E696E6720746865206D6170207768696C6520796F752772652073656C656374';
wwv_flow_imp.g_varchar2_table(396) := '696E672E205468697320736176657320746865207072696F722073746174650D0A20202020202020206F66207768657468657220796F7520636F756C642070616E20746865206D617020736F2077652063616E20726573746F726520697420636F727265';
wwv_flow_imp.g_varchar2_table(397) := '63746C792E202A2F0D0A2020202020206C6574206472616750616E456E61626C6564203D2066616C73653B0D0A0D0A202020202020636F6E737420736574416374697665203D202861637469766529203D3E207B0D0A2020202020202020746869732E61';
wwv_flow_imp.g_varchar2_table(398) := '6374697665203D206163746976653B0D0A2020202020202020627574746F6E2E70726F702827617269612D70726573736564272C20746869732E616374697665293B0D0A2020202020202020627574746F6E2E746F67676C65436C61737328276D617062';
wwv_flow_imp.g_varchar2_table(399) := '6974732D726563742D73656C6563742D627574746F6E2D746F67676C6564272C20746869732E616374697665293B0D0A20202020202020206D61702E676574436F6E7461696E657228292E636C6173734C6973742E746F67676C6528276D617062697473';
wwv_flow_imp.g_varchar2_table(400) := '2D726563742D73656C6563742D616374697665272C20746869732E616374697665293B0D0A20202020202020200D0A2020202020202020696620286472616750616E456E61626C656429207B0D0A202020202020202020206D61702E6472616750616E2E';
wwv_flow_imp.g_varchar2_table(401) := '656E61626C6528293B0D0A20202020202020207D0D0A2020202020207D3B0D0A0D0A202020202020636F6E737420627574746F6E203D202428603C627574746F6E20747970653D22627574746F6E22207374796C653D226C696E652D6865696768743A31';
wwv_flow_imp.g_varchar2_table(402) := '3670783B77696474683A333270783B6865696768743A333270783B223E3C6920636C6173733D2266612066612D6F626A6563742D67726F7570223E3C2F693E3C2F627574746F6E3E60290D0A20202020202020202E70726F7028277469746C65272C2027';
wwv_flow_imp.g_varchar2_table(403) := '52656374616E676C652053656C65637427290D0A20202020202020202E70726F702827617269612D70726573736564272C20746869732E616374697665290D0A20202020202020202E6F6E2827636C69636B272C202829203D3E207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(404) := '202020207365744163746976652821746869732E616374697665293B0D0A20202020202020207D293B0D0A0D0A202020202020636F6E7374206D6F757365646F776E203D20286529203D3E207B0D0A20202020202020206966202821746869732E616374';
wwv_flow_imp.g_varchar2_table(405) := '697665292072657475726E3B0D0A202020202020202069662028626F7853656C65637420213D3D206E756C6C292072657475726E3B0D0A0D0A20202020202020207374617274506F73203D20652E706F696E743B0D0A0D0A2020202020202020626F7853';
wwv_flow_imp.g_varchar2_table(406) := '656C656374203D202428603C64697620636C6173733D226D6170626974732D726563742D73656C6563742D626F78223E60293B0D0A20202020202020206D61702E676574436F6E7461696E657228292E617070656E644368696C6428626F7853656C6563';
wwv_flow_imp.g_varchar2_table(407) := '745B305D293B0D0A0D0A20202020202020206472616750616E456E61626C6564203D206D61702E6472616750616E2E6973456E61626C656428293B0D0A2020202020202020696620286472616750616E456E61626C656429207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(408) := '20206D61702E6472616750616E2E64697361626C6528293B0D0A20202020202020207D0D0A2020202020207D3B0D0A0D0A202020202020636F6E7374206D6F7573656D6F7665203D20286529203D3E207B0D0A202020202020202069662028626F785365';
wwv_flow_imp.g_varchar2_table(409) := '6C656374203D3D3D206E756C6C292072657475726E3B0D0A20202020202020206966202821746869732E616374697665292072657475726E3B0D0A0D0A2020202020202020652E6F726967696E616C4576656E742E73746F7050726F7061676174696F6E';
wwv_flow_imp.g_varchar2_table(410) := '28293B0D0A0D0A2020202020202020636F6E7374206D696E58203D204D6174682E6D696E28652E706F696E742E782C207374617274506F732E78293B0D0A2020202020202020636F6E7374206D617858203D204D6174682E6D617828652E706F696E742E';
wwv_flow_imp.g_varchar2_table(411) := '782C207374617274506F732E78293B0D0A2020202020202020636F6E7374206D696E59203D204D6174682E6D696E28652E706F696E742E792C207374617274506F732E79293B0D0A2020202020202020636F6E7374206D617859203D204D6174682E6D61';
wwv_flow_imp.g_varchar2_table(412) := '7828652E706F696E742E792C207374617274506F732E79293B0D0A2020202020202020626F7853656C6563742E63737328277472616E73666F726D272C20607472616E736C61746528247B6D696E587D70782C20247B6D696E597D70782960293B0D0A20';
wwv_flow_imp.g_varchar2_table(413) := '20202020202020626F7853656C6563742E7769647468286D617858202D206D696E58293B0D0A2020202020202020626F7853656C6563742E686569676874286D617859202D206D696E59293B0D0A2020202020207D3B0D0A0D0A202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(414) := '74206D6F7573657570203D20286529203D3E207B0D0A20202020202020206966202821746869732E616374697665292072657475726E3B0D0A0D0A202020202020202069662028626F7853656C65637420213D3D206E756C6C29207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(415) := '20202020626F7853656C6563745B305D2E706172656E744E6F64652E72656D6F76654368696C6428626F7853656C6563745B305D293B0D0A20202020202020202020626F7853656C656374203D206E756C6C3B0D0A20202020202020207D0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(416) := '202020202020636F6E7374206665617475726573203D206D61702E717565727952656E64657265644665617475726573285B652E706F696E742C207374617274506F735D293B0D0A2020202020202020636F6E737420696473203D206E65772053657428';
wwv_flow_imp.g_varchar2_table(417) := '293B0D0A2020202020202020666F722028636F6E73742066656174757265206F6620666561747572657329207B0D0A20202020202020202020696620286C617965724944732E696E636C7564657328666561747572652E6C617965722E69642929207B0D';
wwv_flow_imp.g_varchar2_table(418) := '0A2020202020202020202020206964732E61646428666561747572652E6964293B0D0A202020202020202020207D0D0A20202020202020207D0D0A202020202020202073657453656C656374656446656174757265732841727261792E66726F6D286964';
wwv_flow_imp.g_varchar2_table(419) := '73292E6D61702878203D3E2069644D61702E676574287829292C20652E6F726967696E616C4576656E742E73686966744B6579203F202761646427203A202773657427293B0D0A0D0A20202020202020207365744163746976652866616C7365293B0D0A';
wwv_flow_imp.g_varchar2_table(420) := '2020202020207D3B0D0A0D0A2020202020206D61702E6F6E28276D6F757365646F776E272C206D6F757365646F776E293B0D0A2020202020206D61702E6F6E28276D6F7573656D6F7665272C206D6F7573656D6F7665293B0D0A2020202020206D61702E';
wwv_flow_imp.g_varchar2_table(421) := '6F6E28276D6F7573657570272C206D6F7573657570293B0D0A0D0A202020202020746869732E5F636C65616E7570203D202829203D3E207B0D0A20202020202020206D61702E6F666628276D6F757365646F776E272C206D6F757365646F776E293B0D0A';
wwv_flow_imp.g_varchar2_table(422) := '20202020202020206D61702E6F666628276D6F7573656D6F7665272C206D6F7573656D6F7665293B0D0A20202020202020206D61702E6F666628276D6F7573657570272C206D6F7573657570293B0D0A202020202020202069662028626F7853656C6563';
wwv_flow_imp.g_varchar2_table(423) := '7420213D3D206E756C6C29207B0D0A20202020202020202020626F7853656C6563745B305D2E706172656E744E6F64652E72656D6F76654368696C6428626F7853656C6563745B305D293B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A20';
wwv_flow_imp.g_varchar2_table(424) := '2020202020746869732E636F6E7461696E6572203D202428603C64697620636C6173733D226D61706C69627265676C2D6374726C206D61706C69627265676C2D6374726C2D67726F7570223E60290D0A20202020202020202E617070656E642862757474';
wwv_flow_imp.g_varchar2_table(425) := '6F6E290D0A20202020202020202E6765742830293B0D0A0D0A20202020202072657475726E20746869732E636F6E7461696E65723B0D0A202020207D0D0A0D0A202020206F6E52656D6F76652829207B0D0A202020202020746869732E5F636C65616E75';
wwv_flow_imp.g_varchar2_table(426) := '7028293B0D0A202020202020746869732E636F6E7461696E65722E706172656E744E6F64652E72656D6F76654368696C6428746869732E636F6E7461696E6572293B0D0A202020207D0D0A20207D0D0A0D0A2020636F6E73742067656F6A736F6E426F75';
wwv_flow_imp.g_varchar2_table(427) := '6E6473203D202867656F6A736F6E29203D3E207B0D0A202020206C657420636F6F726473203D205B5D3B0D0A20202020737769746368202867656F6A736F6E2E7479706529207B0D0A2020202020206361736520274D756C7469506F6C79676F6E273A0D';
wwv_flow_imp.g_varchar2_table(428) := '0A2020202020202020636F6F726473203D2067656F6A736F6E2E636F6F7264696E617465732E666C61744D617028706F6C79203D3E20706F6C792E666C61744D61702872696E67203D3E2072696E6729293B0D0A2020202020202020627265616B3B0D0A';
wwv_flow_imp.g_varchar2_table(429) := '202020202020636173652027506F6C79676F6E273A0D0A2020202020206361736520274D756C74694C696E65537472696E67273A0D0A2020202020202020636F6F726473203D2067656F6A736F6E2E636F6F7264696E617465732E666C61744D61702872';
wwv_flow_imp.g_varchar2_table(430) := '696E67203D3E2072696E67293B0D0A2020202020202020627265616B3B0D0A2020202020206361736520274C696E65537472696E67273A0D0A2020202020206361736520274D756C7469506F696E74273A0D0A2020202020202020636F6F726473203D20';
wwv_flow_imp.g_varchar2_table(431) := '67656F6A736F6E2E636F6F7264696E617465733B0D0A2020202020202020627265616B3B0D0A202020202020636173652027506F696E74273A0D0A2020202020202020636F6F726473203D205B67656F6A736F6E2E636F6F7264696E617465735D3B0D0A';
wwv_flow_imp.g_varchar2_table(432) := '2020202020202020627265616B3B0D0A202020207D0D0A0D0A202020206C6574206D696E59203D204D6174682E6D696E282E2E2E28636F6F7264732E6D6170287879203D3E2078795B315D2929293B0D0A202020206C6574206D696E58203D204D617468';
wwv_flow_imp.g_varchar2_table(433) := '2E6D696E282E2E2E28636F6F7264732E6D6170287879203D3E2078795B305D2929293B0D0A202020206C6574206D617859203D204D6174682E6D6178282E2E2E28636F6F7264732E6D6170287879203D3E2078795B315D2929293B0D0A202020206C6574';
wwv_flow_imp.g_varchar2_table(434) := '206D617858203D204D6174682E6D6178282E2E2E28636F6F7264732E6D6170287879203D3E2078795B305D2929293B0D0A0D0A2020202072657475726E205B5B6D696E582C206D696E595D2C205B6D6178582C206D6178595D5D3B0D0A20207D3B0D0A0D';
wwv_flow_imp.g_varchar2_table(435) := '0A2020617065782E6974656D2E637265617465280D0A202020206974656D49642C0D0A202020207B0D0A202020202020726566726573683A206173796E63202829203D3E207B0D0A20202020202020206177616974206C6F61644461746128293B0D0A20';
wwv_flow_imp.g_varchar2_table(436) := '20202020207D2C0D0A20202020202073686F773A202829203D3E207B0D0A20202020202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020207D2C0D0A202020202020686964653A202829203D3E207B';
wwv_flow_imp.g_varchar2_table(437) := '0D0A20202020202020207365744C61796572735669736962696C69747928276E6F6E6527293B0D0A2020202020207D2C0D0A202020202020697356697369626C653A202829203D3E207B0D0A202020202020202072657475726E206C6179657273566973';
wwv_flow_imp.g_varchar2_table(438) := '6962696C69747920213D3D20276E6F6E65273B0D0A2020202020207D2C0D0A2020202020206861734944436F6C756D6E3A202829203D3E207B0D0A202020202020202072657475726E2021216964436F6C756D6E3B0D0A2020202020207D2C0D0A0D0A20';
wwv_flow_imp.g_varchar2_table(439) := '20202020202F2A2A0D0A202020202020202A2052657475726E73207472756520696620616E792065646974732068617665206265656E206D61646520746F20746865206C6179657220646174612E0D0A202020202020202A2F0D0A202020202020697343';
wwv_flow_imp.g_varchar2_table(440) := '68616E6765643A202829203D3E2065646974732E73697A65203E20302C0D0A0D0A2020202020202F2A20476574732074686520494473206F66207468652073656C65637465642066656174757265732E202A2F0D0A20202020202067657453656C656374';
wwv_flow_imp.g_varchar2_table(441) := '656446656174757265733A202829203D3E2073656C65637465644665617475726573203F2041727261792E66726F6D2873656C6563746564466561747572657329203A205B5D2C0D0A2020202020202F2A2053657420746865206C697374206F66206665';
wwv_flow_imp.g_varchar2_table(442) := '617475726573207468617420686176652061202273656C65637465642220617070656172616E63652E20606665617475726573602069732061206C6973740D0A2020202020202020206F662066656174757265204944732E202A2F0D0A20202020202073';
wwv_flow_imp.g_varchar2_table(443) := '657453656C656374656446656174757265732C0D0A2020202020202F2A2053656C6563747320616C6C2066656174757265732063757272656E746C7920696E20746865206C617965722074686174206861766520616E2049442E202A2F0D0A2020202020';
wwv_flow_imp.g_varchar2_table(444) := '2073656C656374416C6C46656174757265733A202829203D3E207B0D0A2020202020202020696620287265736F6C766564536F757263654F7074696F6E7329207B0D0A2020202020202020202073657453656C6563746564466561747572657328726573';
wwv_flow_imp.g_varchar2_table(445) := '6F6C766564536F757263654F7074696F6E732E646174612E66656174757265732E6D61702866203D3E20662E6964292C202773657427293B0D0A20202020202020207D0D0A2020202020207D2C0D0A202020202020636C65617253656C656374696F6E3A';
wwv_flow_imp.g_varchar2_table(446) := '202829203D3E207B0D0A202020202020202073657453656C65637465644665617475726573285B5D2C202773657427293B0D0A2020202020207D2C0D0A0D0A20202020202073657453656C656374696F6E5374796C653A20287374796C652C206F707473';
wwv_flow_imp.g_varchar2_table(447) := '29203D3E207B0D0A20202020202020206966202873656C656374696F6E5374796C6529207B0D0A20202020202020202020636F6E736F6C652E6572726F72282743616E6E6F7420736574207468652073656C656374696F6E207374796C65206166746572';
wwv_flow_imp.g_varchar2_table(448) := '20746865206D617020686173206265656E20696E697469616C697A656427293B0D0A2020202020202020202072657475726E3B0D0A20202020202020207D0D0A0D0A20202020202020202F2F20416C6C6F77207468652066756E6374696F6E20746F2062';
wwv_flow_imp.g_varchar2_table(449) := '652063616C6C65642077697468206F6E6C7920746865206F70747320706172616D657465720D0A202020202020202069662028747970656F66206F707473203D3D3D2027756E646566696E65642720262620747970656F66207374796C65203D3D20276F';
wwv_flow_imp.g_varchar2_table(450) := '626A6563742729207B0D0A202020202020202020206F707473203D207374796C653B0D0A202020202020202020207374796C65203D206E756C6C3B0D0A20202020202020207D0D0A0D0A202020202020202073656C656374696F6E5374796C65203D2073';
wwv_flow_imp.g_varchar2_table(451) := '74796C653B0D0A20202020202020206F707473203D206F707473203F3F207B7D3B0D0A202020202020202073656C656374696F6E5374796C654F707473203D206F7074733B0D0A20202020202020206966202827656E61626C65436C69636B2720696E20';
wwv_flow_imp.g_varchar2_table(452) := '6F70747329207B0D0A20202020202020202020636C69636B53656C656374203D206F7074732E656E61626C65436C69636B3B0D0A20202020202020207D0D0A2020202020202020696620282772656374616E676C6553656C6563742720696E206F707473';
wwv_flow_imp.g_varchar2_table(453) := '29207B0D0A2020202020202020202072656374616E676C6553656C656374203D206F7074732E72656374616E676C6553656C6563743B0D0A20202020202020207D0D0A20202020202020206966202827636C69636B53696E676C6553656C656374272069';
wwv_flow_imp.g_varchar2_table(454) := '6E206F70747329207B0D0A20202020202020202020636C69636B4D756C746953656C656374203D20216F7074732E636C69636B53696E676C6553656C6563743B0D0A20202020202020207D0D0A202020202020202069662028276F726465724279272069';
wwv_flow_imp.g_varchar2_table(455) := '6E206F70747329207B0D0A20202020202020202020636C69636B4F726465724279203D206F7074732E6F7264657242793B0D0A20202020202020207D0D0A20202020202020206966202827706172746974696F6E42792720696E206F70747329207B0D0A';
wwv_flow_imp.g_varchar2_table(456) := '20202020202020202020636C69636B506172746974696F6E4279203D206F7074732E636C69636B506172746974696F6E42793B0D0A20202020202020207D0D0A20202020202020206966202827636F6C6F722720696E206F70747329207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(457) := '20202020202073656C656374696F6E436F6C6F72203D206F7074732E636F6C6F723B0D0A20202020202020207D0D0A0D0A2020202020202020666F722028636F6E7374206C61796572206F66206C61796572494473203F3F205B5D29207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(458) := '202020202020696620286973436C69636B61626C65282929207B0D0A2020202020202020202020206D61702E5F5F6D6170626974735F6C617965725F637572736F72732E736574286C617965722C2027706F696E74657227293B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(459) := '20207D20656C7365207B0D0A2020202020202020202020206D61702E5F5F6D6170626974735F6C617965725F637572736F72732E64656C657465286C61796572293B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D2C';
wwv_flow_imp.g_varchar2_table(460) := '0D0A0D0A2020202020202F2A2A0D0A202020202020202A204D6F76657320746865206D617020626F756E64696E6720626F7820746F206669742074686520676976656E20666561747572652E0D0A202020202020202A2F0D0A2020202020207A6F6F6D54';
wwv_flow_imp.g_varchar2_table(461) := '6F466561747572653A206173796E6320286665617475726549642C206F70747329203D3E207B0D0A2020202020202020636F6E73742066656174757265203D2066656174757265734D61702E67657428666561747572654964293B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(462) := '20696620286665617475726529207B0D0A202020202020202020202861776169742070656E64696E674D6170292E666974426F756E64732867656F6A736F6E426F756E647328666561747572652E67656F6D65747279292C206F707473293B0D0A202020';
wwv_flow_imp.g_varchar2_table(463) := '20202020207D0D0A2020202020207D2C0D0A0D0A2020202020202F2A2A0D0A202020202020202A204765747320746865206C617965722064617461206173207265747269657665642066726F6D2074686520736F7572636520286E6F7420696E636C7564';
wwv_flow_imp.g_varchar2_table(464) := '696E67206564697473292E0D0A202020202020202A2F0D0A202020202020676574536F75726365446174613A202829203D3E207B0D0A202020202020202072657475726E207265736F6C766564536F757263654F7074696F6E733F2E646174613B0D0A20';
wwv_flow_imp.g_varchar2_table(465) := '20202020207D2C0D0A2020202020202F2A2A0D0A202020202020202A204765747320746865204944206F662074686520736F7572636520746861742077617320616464656420746F20746865204D61702E0D0A202020202020202A2F0D0A202020202020';
wwv_flow_imp.g_varchar2_table(466) := '676574536F757263654E616D653A202829203D3E20736F757263654E616D652C0D0A2020202020202F2A2A0D0A202020202020202A2052657475726E7320612050726F6D6973652074686174207265736F6C766573207768656E20746865206C61796572';
wwv_flow_imp.g_varchar2_table(467) := '20686173206C6F616465642E0D0A202020202020202A2F0D0A20202020202077616974466F724C6F61643A202829203D3E207B0D0A202020202020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E';
wwv_flow_imp.g_varchar2_table(468) := '207B0D0A202020202020202020206966202877616974466F724C6F6164203D3D3D206E756C6C29207B0D0A2020202020202020202020207265736F6C766528293B0D0A202020202020202020207D20656C7365207B0D0A20202020202020202020202077';
wwv_flow_imp.g_varchar2_table(469) := '616974466F724C6F61642E70757368287265736F6C7665293B0D0A202020202020202020207D0D0A20202020202020207D293B0D0A2020202020207D2C0D0A2020202020202F2A2A0D0A202020202020202A20476574732061206C697374206F66207374';
wwv_flow_imp.g_varchar2_table(470) := '796C65206C617965722049447320616464656420746F20746865206D61702062792074686973204C6F646573746172206C617965722E0D0A202020202020202A2F0D0A2020202020206765744C617965724944733A202829203D3E207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(471) := '20202072657475726E206C617965724944733B0D0A2020202020207D2C0D0A0D0A2020202020202F2A2A0D0A202020202020202A204765747320746865204D61704C6962726520474C204A53204D6170206F626A65637420666F7220746865206C617965';
wwv_flow_imp.g_varchar2_table(472) := '722773206173736F63696174656420726567696F6E2E0D0A202020202020202A20546865206D6170206D6179206E6F742068617665206C6F61646564207965742C20736F20746869732066756E6374696F6E2072657475726E7320612050726F6D697365';
wwv_flow_imp.g_varchar2_table(473) := '2E0D0A202020202020202A2F0D0A2020202020206765744D61703A206173796E63202829203D3E2061776169742070656E64696E674D61702C0D0A0D0A2020202020202F2A2A0D0A202020202020202A204170706C69657320616E206564697420746F20';
wwv_flow_imp.g_varchar2_table(474) := '6120666561747572652E2060616374696F6E60206973206F6E65206F662027637265617465272C2027757064617465272C206F72202764656C657465272C20616E640D0A202020202020202A2060666561747572656020697320746865206E6577206F72';
wwv_flow_imp.g_varchar2_table(475) := '2065646974656420666561747572652E204966207468652066656174757265206973206265696E672064656C657465642C207468656E206F6E6C79206974730D0A202020202020202A20276964272070726F7065727479206973206E65656465642E0D0A';
wwv_flow_imp.g_varchar2_table(476) := '202020202020202A2F0D0A20202020202065646974466561747572653A206173796E632028616374696F6E2C206665617475726529203D3E207B0D0A202020202020202069662028616374696F6E203D3D3D202763726561746527202626202166656174';
wwv_flow_imp.g_varchar2_table(477) := '7572652E696429207B0D0A202020202020202020202F2F206175746F2D61737369676E20612055554944206966207468652065646974206665617475726520686173206E6F2049440D0A20202020202020202020666561747572652E6964203D20637279';
wwv_flow_imp.g_varchar2_table(478) := '70746F2E72616E646F6D5555494428293B0D0A20202020202020207D0D0A0D0A2020202020202020636F6E7374206578697374696E67203D2065646974732E67657428666561747572652E6964293B0D0A2020202020202020696620286578697374696E';
wwv_flow_imp.g_varchar2_table(479) := '67202626206578697374696E672E616374696F6E203D3D3D20276372656174652729207B0D0A20202020202020202020696620286578697374696E672E616374696F6E203D3D3D20276372656174652720262620616374696F6E203D3D3D202775706461';
wwv_flow_imp.g_varchar2_table(480) := '74652729207B0D0A2020202020202020202020202F2F2065646974696E672061206E65772066656174757265207374696C6C20726573756C747320696E2061206E657720666561747572650D0A202020202020202020202020616374696F6E203D202763';
wwv_flow_imp.g_varchar2_table(481) := '7265617465273B0D0A202020202020202020207D20656C736520696620286578697374696E672E616374696F6E203D3D3D20276372656174652720262620616374696F6E203D3D3D202764656C6574652729207B0D0A2020202020202020202020202F2F';
wwv_flow_imp.g_varchar2_table(482) := '2064656C6574696E672061206E6577206665617475726520726573756C747320696E206E6F206368616E67650D0A20202020202020202020202065646974732E64656C65746528666561747572652E6964293B0D0A202020202020202020202020617761';
wwv_flow_imp.g_varchar2_table(483) := '69742072656C6F6164536F757263654461746128293B0D0A20202020202020202020202072657475726E3B0D0A202020202020202020207D0D0A20202020202020207D0D0A0D0A202020202020202065646974732E73657428666561747572652E69642C';
wwv_flow_imp.g_varchar2_table(484) := '207B20616374696F6E2C2066656174757265207D293B0D0A202020202020202061776169742072656C6F6164536F757263654461746128293B0D0A2020202020207D2C0D0A2020202020202F2A2A0D0A202020202020202A204765747320616E20617272';
wwv_flow_imp.g_varchar2_table(485) := '6179206F6620616C6C20656469747320746861742068617665206265656E206D6164652E0D0A202020202020202A2F0D0A20202020202067657445646974733A202829203D3E2041727261792E66726F6D2865646974732E76616C7565732829292C0D0A';
wwv_flow_imp.g_varchar2_table(486) := '2020202020202F2A2A0D0A202020202020202A204765747320746865206C6179657220646174612C2077697468206564697473206170706C6965642E0D0A202020202020202A2F0D0A202020202020676574456469746564446174613A202829203D3E20';
wwv_flow_imp.g_varchar2_table(487) := '287B0D0A2020202020202020747970653A202746656174757265436F6C6C656374696F6E272C0D0A202020202020202066656174757265732C0D0A2020202020207D292C0D0A0D0A2020202020202F2A2A0D0A202020202020202A20496E7465726E616C';
wwv_flow_imp.g_varchar2_table(488) := '6C792C204D617062697473207061737365732073657175656E7469616C2049447320746F204D61704C6962726520696E7374656164206F66207468652049447320696E2074686520736F7572636520646174612E20546869732069732062656361757365';
wwv_flow_imp.g_varchar2_table(489) := '0D0A202020202020202A204D61704C69627265206F6E6C7920737570706F72747320706F73697469766520696E7465676572204944732C206275742047656F4A534F4E20616C736F20737570706F72747320737472696E67732E204D6170626974732041';
wwv_flow_imp.g_varchar2_table(490) := '5049732072657475726E20746865206F726967696E616C0D0A202020202020202A20736F75726365204944732C2062757420696620796F752067657420612066656174757265204944206469726563746C792066726F6D204D61704C696272652028652E';
wwv_flow_imp.g_varchar2_table(491) := '672E207769746820717565727952656E64657265644665617475726573292C207468656E20796F75206E65656420746F0D0A202020202020202A2075736520746869732066756E6374696F6E20746F206765742074686520736F757263652049442E0D0A';
wwv_flow_imp.g_varchar2_table(492) := '202020202020202A2F0D0A202020202020636F6E7665727449443A2028696429203D3E2069644D61702E676574286964292C0D0A0D0A2020202020202F2A2A0D0A202020202020202A2047657473206120666561747572652062792049442C20696E636C';
wwv_flow_imp.g_varchar2_table(493) := '7564696E6720616E792065646974732E0D0A202020202020202A2F0D0A202020202020676574466561747572653A2028696429203D3E2066656174757265734D61702E676574286964292C0D0A2020202020202F2A2A0D0A202020202020202A20476574';
wwv_flow_imp.g_varchar2_table(494) := '7320746865206564697420616374696F6E202827637265617465272C2027757064617465272C202764656C657465272C206F7220276E6F6E65272920666F722074686520676976656E20666561747572652049442E0D0A202020202020202A2F0D0A2020';
wwv_flow_imp.g_varchar2_table(495) := '202020206765744665617475726545646974416374696F6E3A2028696429203D3E2065646974732E676574286964293F2E616374696F6E203F3F202866656174757265734D61702E67657428696429203F20276E6F6E6527203A206E756C6C292C0D0A0D';
wwv_flow_imp.g_varchar2_table(496) := '0A202020202020636C65617245646974733A206173796E63202829203D3E207B0D0A202020202020202065646974732E636C65617228293B0D0A202020202020202061776169742072656C6F6164536F757263654461746128293B0D0A2020202020207D';
wwv_flow_imp.g_varchar2_table(497) := '2C0D0A0D0A202020202020636C6561724564697473416E64526566726573683A206173796E63202829203D3E207B0D0A202020202020202065646974732E636C65617228293B0D0A20202020202020206177616974206C6F61644461746128293B0D0A20';
wwv_flow_imp.g_varchar2_table(498) := '20202020207D2C0D0A202020207D0D0A2020293B0D0A0D0A20206C6F61644461746128293B0D0A0D0A20206C657420666972737452656672657368203D20747275653B0D0A2020617065782E6A51756572792827626F647927292E6F6E28276170657862';
wwv_flow_imp.g_varchar2_table(499) := '65666F726572656672657368272C206173796E632028657629203D3E207B0D0A202020206966202865762E746172676574203D3D3D20617065782E726567696F6E28726567696F6E4964292E656C656D656E745B305D29207B0D0A2020202020202F2A20';
wwv_flow_imp.g_varchar2_table(500) := '536B69702074686520666972737420617065786265666F726572656672657368206576656E742C2073696E6365207468617420636F72726573706F6E647320746F207468652070616765206C6F6164696E672C0D0A202020202020202020627574207765';
wwv_flow_imp.g_varchar2_table(501) := '20616C72656164792063616C6C6564206C6F61644461746128292061626F766520776974686F75742077616974696E6720666F7220746865206D617020746F206C6F61642E202A2F0D0A202020202020696620282166697273745265667265736829207B';
wwv_flow_imp.g_varchar2_table(502) := '0D0A20202020202020206177616974206C6F61644461746128293B0D0A2020202020207D20656C7365207B0D0A2020202020202020666972737452656672657368203D2066616C73653B0D0A2020202020207D0D0A202020207D0D0A20207D293B0D0A0D';
wwv_flow_imp.g_varchar2_table(503) := '0A202069662028747970656F6620696E69744A73203D3D3D202766756E6374696F6E2729207B0D0A20202020696E69744A7328617065782E6974656D286974656D496429293B0D0A20207D0D0A0D0A2020696620286974656D496420696E204D41504249';
wwv_flow_imp.g_varchar2_table(504) := '54535F4C4F4445535441525F4C415945525F57414954494E4729207B0D0A20202020636F6E7374206974656D203D20617065782E6974656D286974656D4964293B0D0A202020204D4150424954535F4C4F4445535441525F4C415945525F57414954494E';
wwv_flow_imp.g_varchar2_table(505) := '475B6974656D49645D2E666F724561636828287829203D3E2078286974656D29293B0D0A20207D0D0A20204D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B6974656D49645D203D206E756C6C3B0D0A7D0D0A0D0A0D0A636F';
wwv_flow_imp.g_varchar2_table(506) := '6E7374206D6170626974735F6C6F6465737461725F74696E79736466203D206E6577206D6170626974735F74696E79736466287B0D0A2020666F6E7453697A653A2031362C0D0A2020666F6E7446616D696C793A2027466F6E74204150455820536D616C';
wwv_flow_imp.g_varchar2_table(507) := '6C272C0D0A7D293B0D0A0D0A66756E6374696F6E206D6170626974735F6C6F6465737461725F696D6167655F68616E646C657228657629207B0D0A2020636F6E7374206D6C76657273696F6E203D20286D61706C69627265676C2E67657456657273696F';
wwv_flow_imp.g_varchar2_table(508) := '6E3F2E2829203F3F206D61706C69627265676C2E76657273696F6E292E73706C697428272E27292E6D61702878203D3E207061727365496E74287829293B0D0A0D0A202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A';
wwv_flow_imp.g_varchar2_table(509) := '65637429203D3E207B0D0A20202020636F6E7374206D6170203D2065762E7461726765743B0D0A20202020696620286D61702E686173496D6167652865762E69642929207B0D0A2020202020207265736F6C766528293B0D0A2020202020207265747572';
wwv_flow_imp.g_varchar2_table(510) := '6E3B0D0A202020207D0D0A0D0A202020206966202865762E69642E73746172747357697468282766612D272929207B0D0A2020202020202F2A20466967757265206F757420776861742063686172616374657220746869732069636F6E2075736573202A';
wwv_flow_imp.g_varchar2_table(511) := '2F0D0A202020202020636F6E7374207370616E203D20646F63756D656E742E637265617465456C656D656E7428277370616E27293B0D0A2020202020207370616E2E7374796C652E646973706C6179203D20276E6F6E65273B0D0A202020202020737061';
wwv_flow_imp.g_varchar2_table(512) := '6E2E636C6173734C6973742E6164642827666127293B0D0A2020202020207370616E2E636C6173734C6973742E6164642865762E6964293B0D0A2020202020202F2A2041646420746865207370616E20746F2074686520444F4D20736F20697473207374';
wwv_flow_imp.g_varchar2_table(513) := '796C65732063616E20626520636F6D7075746564202A2F0D0A2020202020206D61702E676574436F6E7461696E657228292E617070656E644368696C64287370616E293B0D0A2020202020202F2A20476574207468652069636F6E206368617261637465';
wwv_flow_imp.g_varchar2_table(514) := '72202A2F0D0A202020202020636F6E737420636F6D70757465645374796C65203D2077696E646F772E676574436F6D70757465645374796C65287370616E2C20273A6265666F726527293B0D0A202020202020636F6E73742069636F6E43686172203D20';
wwv_flow_imp.g_varchar2_table(515) := '636F6D70757465645374796C652E636F6E74656E742E737562737472696E6728312C2032293B0D0A2020202020207370616E2E72656D6F766528293B0D0A0D0A202020202020636F6E737420676C797068203D206D6170626974735F6C6F646573746172';
wwv_flow_imp.g_varchar2_table(516) := '5F74696E797364662E647261772869636F6E43686172293B0D0A2020202020202F2A2041646420524742206368616E6E656C73202A2F0D0A202020202020636F6E7374207267626144617461203D206E65772055696E7438417272617928676C7970682E';
wwv_flow_imp.g_varchar2_table(517) := '7769647468202A20676C7970682E686569676874202A2034293B0D0A202020202020666F7220286C65742069203D20303B2069203C20676C7970682E646174612E6C656E6774683B2069202B2B29207B0D0A202020202020202072676261446174615B69';
wwv_flow_imp.g_varchar2_table(518) := '202A2034202B20335D203D20676C7970682E646174615B695D3B0D0A2020202020207D0D0A2020202020206D61702E616464496D6167652865762E69642C207B20646174613A2072676261446174612C2077696474683A20676C7970682E77696474682C';
wwv_flow_imp.g_varchar2_table(519) := '206865696768743A20676C7970682E686569676874207D2C207B7364663A20747275657D293B0D0A2020202020207265736F6C766528293B0D0A202020207D20656C7365206966202865762E69642E7374617274735769746828617065782E656E762E41';
wwv_flow_imp.g_varchar2_table(520) := '50505F46494C45532929207B0D0A202020202020696620286D6C76657273696F6E5B305D203E3D203429207B0D0A20202020202020206D61702E6C6F6164496D6167652865762E6964292E7468656E2828696D6729203D3E207B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(521) := '202069662028216D61702E686173496D6167652865762E69642929207B0D0A2020202020202020202020206D61702E616464496D6167652865762E69642C20696D672E64617461293B0D0A202020202020202020207D0D0A202020202020202020207265';
wwv_flow_imp.g_varchar2_table(522) := '736F6C766528293B0D0A20202020202020207D293B0D0A2020202020207D20656C7365207B0D0A20202020202020206D61702E6C6F6164496D6167652865762E69642C20285F2C20696D6729203D3E207B0D0A2020202020202020202069662028216D61';
wwv_flow_imp.g_varchar2_table(523) := '702E686173496D6167652865762E69642929207B0D0A2020202020202020202020206D61702E616464496D6167652865762E69642C20696D67293B0D0A202020202020202020207D0D0A202020202020202020207265736F6C766528293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(524) := '202020207D293B0D0A2020202020207D0D0A202020207D0D0A20207D293B0D0A7D3B0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43468483923713304)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
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
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43469607346713305)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
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
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43470099721713305)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_file_name=>'tiny-sdf.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D61706C69627265676C2D6374726C2D67726F757020627574746F6E2E6D6170626974732D726563742D73656C6563742D627574746F6E2D746F67676C6564207B6261636B67726F756E642D636F6C6F723A2072676228302C20302C20302C20302E32';
wwv_flow_imp.g_varchar2_table(2) := '293B7D2E6D6170626974732D726563742D73656C6563742D626F78207B706F736974696F6E3A206162736F6C7574653B6261636B67726F756E642D636F6C6F723A2072676228302C20302C20302C20302E32293B626F726465723A2032707820646F7474';
wwv_flow_imp.g_varchar2_table(3) := '656420626C61636B3B706F696E7465722D6576656E74733A206E6F6E653B7D2E6D61706C69627265676C2D6D61702E6D6170626974732D726563742D73656C6563742D616374697665202E6D61706C69627265676C2D63616E7661732D636F6E7461696E';
wwv_flow_imp.g_varchar2_table(4) := '6572207B637572736F723A2063726F7373686169723B7D2E6D6170626974732D686F7665722D706F707570202E6D61706C69627265676C2D706F7075702D636F6E74656E74207B706F696E7465722D6576656E74733A206E6F6E653B7D2E6D6170626974';
wwv_flow_imp.g_varchar2_table(5) := '732D73696465626172207B706F736974696F6E3A206162736F6C7574653B746F703A20766172282D2D6D6170626974732D736964656261722D746F702C20307078293B626F74746F6D3A20766172282D2D6D6170626974732D736964656261722D626F74';
wwv_flow_imp.g_varchar2_table(6) := '746F6D2C20307078293B6D617267696E2D746F703A20766172282D2D6D672D746F702D6C6566742D6374726C2D6D617267696E2D792C2031327078293B6D617267696E2D626F74746F6D3A20766172282D2D6D672D746F702D6C6566742D6374726C2D6D';
wwv_flow_imp.g_varchar2_table(7) := '617267696E2D792C2031327078293B6D617267696E2D6C6566743A20766172282D2D6D672D746F702D6C6566742D6374726C2D6D617267696E2D782C2031327078293B6D617267696E2D72696768743A20766172282D2D6D672D746F702D6C6566742D63';
wwv_flow_imp.g_varchar2_table(8) := '74726C2D6D617267696E2D782C2031327078293B706F696E7465722D6576656E74733A206E6F6E653B7D2E6D6170626974732D736964656261722D70616E656C207B706F696E7465722D6576656E74733A206175746F3B6261636B67726F756E642D636F';
wwv_flow_imp.g_varchar2_table(9) := '6C6F723A2077686974653B626F726465723A2031707820736F6C6964207267626128302C20302C20302C20302E31293B626F726465722D7261646975733A203870783B6F766572666C6F773A2068696464656E3B646973706C61793A20666C65783B6D61';
wwv_flow_imp.g_varchar2_table(10) := '782D6865696768743A20313030253B7D2E6D6170626974732D73696465626172202E6D6170626974732D696E666F2D636F6E74656E74207B6F766572666C6F773A206175746F3B6D61782D6865696768743A20313030253B70616464696E673A20302E35';
wwv_flow_imp.g_varchar2_table(11) := '72656D3B77696474683A20313030253B7D2E6D6170626974732D736964656261722E6D6170626974732D736964656261722D636C6F736561626C65202E6D6170626974732D736964656261722D636C6F7365207B646973706C61793A20626C6F636B3B7D';
wwv_flow_imp.g_varchar2_table(12) := '2E6D6170626974732D73696465626172202E6D6170626974732D736964656261722D636C6F7365207B646973706C61793A206E6F6E653B706F696E7465722D6576656E74733A206175746F3B637572736F723A20706F696E7465723B6261636B67726F75';
wwv_flow_imp.g_varchar2_table(13) := '6E643A2072676261283235352C203235352C203235352C20302E3735293B626F726465723A2031707820736F6C6964207267626128302C20302C20302C20302E31293B626F726465722D7261646975733A203470783B706F736974696F6E3A206162736F';
wwv_flow_imp.g_varchar2_table(14) := '6C7574653B746F703A20303B72696768743A202D3470783B7472616E736C6174653A2063616C6328313030252920303B7D2E6D6170626974732D696E666F2D636F6E74656E74207461626C65207468207B746578742D616C69676E3A2072696768743B70';
wwv_flow_imp.g_varchar2_table(15) := '616464696E672D72696768743A202E35656D3B7D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(59958161882265956)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_file_name=>'mapbits-lodestarlayer.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F4C4F4445535441525F4C415945525F57414954494E473D7B7D3B66756E6374696F6E206D6170626974735F6C6F6465737461726C617965725F776169745F666F725F696E69742865297B72657475726E206E65772050';
wwv_flow_imp.g_varchar2_table(2) := '726F6D697365282828742C69293D3E7B6520696E204D4150424954535F4C4F4445535441525F4C415945525F57414954494E477C7C284D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D3D5B5D292C6E756C6C213D3D4D';
wwv_flow_imp.g_varchar2_table(3) := '4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D3F4D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D2E707573682828653D3E7B742865297D29293A7428617065782E6974656D28652929';
wwv_flow_imp.g_varchar2_table(4) := '7D29297D66756E6374696F6E206D6170626974735F6C6F6465737461726C61796572287B6974656D49643A652C616A61784964656E7469666965723A742C726567696F6E49643A692C6C61796572547970653A612C6C6162656C436F6C756D6E3A6F2C6C';
wwv_flow_imp.g_varchar2_table(5) := '61796572446566696E6974696F6E3A722C73657175656E63654E756D6265723A6E2C7469746C653A732C636F6C6F723A6C2C6F7061636974793A632C6F75746C696E65436F6C6F723A702C69636F6E3A642C736F757263654F7074696F6E733A752C6964';
wwv_flow_imp.g_varchar2_table(6) := '436F6C756D6E3A6D2C636C69636B61626C653A792C7375626D69744974656D733A662C736F75726365547970653A672C696E69744A733A682C6C696E6557696474683A622C6C696E654461736841727261793A5F2C666F6E7453697A653A762C656E6162';
wwv_flow_imp.g_varchar2_table(7) := '6C65436C7573746572696E673A772C636C75737465725261646975733A782C636C75737465724D61785A6F6F6D3A532C636C75737465724D696E506F696E74733A6B2C7261646975733A4D2C666F6E745374796C653A492C73656C656374696F6E436F6C';
wwv_flow_imp.g_varchar2_table(8) := '6F723A4C2C636C69636B53656C6563743A502C636C69636B4D756C746953656C6563743A412C636C69636B4F7264657242793A452C636C69636B506172746974696F6E42793A522C72656374616E676C6553656C6563743A432C6C696E6B3A542C696E66';
wwv_flow_imp.g_varchar2_table(9) := '6F57696E4265686176696F723A462C696E666F57696E457870723A4E2C696E666F57696E436C69636B457870723A7A2C736964656261724265686176696F723A422C73696465626172457870723A4F2C73696465626172436C69636B457870723A442C6D';
wwv_flow_imp.g_varchar2_table(10) := '696E7A6F6F6D3A572C6D61787A6F6F6D3A712C626C75723A6A2C696E697476697369626C653A477D297B69662821692972657475726E20766F696420617065782E64656275672E6572726F7228226D6170626974735F6C6F6465737461726C6179657220';
wwv_flow_imp.g_varchar2_table(11) := '222B652B22203A204974656D206973206E6F7420696E206120726567696F6E2E22293B636F6E737420593D617065782E73746F726167652E67657453636F7065644C6F63616C53746F72616765287B75736541707049643A21302C757365506167654964';
wwv_flow_imp.g_varchar2_table(12) := '3A21302C726567696F6E49643A697D293B6C657420513D5B5D3B636F6E7374205A3D652B222D736F75726365223B6C6574204B2C553D592E6765744974656D28224D6170626974735F4C6F6465737461724C617965725F222B652B225F7669736962696C';
wwv_flow_imp.g_varchar2_table(13) := '69747922293F3F28473F2276697369626C65223A226E6F6E6522292C4A3D6E756C6C2C563D653D3E7B553D657D2C483D6E756C6C2C583D5B5D3B636F6E73742065653D6E6577204D61702C74653D6E6577204D61702C69653D6E6577204D61702C61653D';
wwv_flow_imp.g_varchar2_table(14) := '6E6577204D61703B2150262621437C7C6D7C7C636F6E736F6C652E7761726E28605B247B657D5D205761726E696E673A2053656C656374696F6E2077696C6C206E6F7420776F726B20776974686F757420616E20494420636F6C756D6E21205468652049';
wwv_flow_imp.g_varchar2_table(15) := '44206973206E656564656420746F20747261636B207768696368206665617475726573206172652073656C65637465642E60293B636F6E7374206F653D28293D3E7B696628214A2972657475726E21313B72657475726E5B22696E222C5B226964225D2C';
wwv_flow_imp.g_varchar2_table(16) := '5B226C69746572616C222C41727261792E66726F6D284A292E6D61702828653D3E61652E67657428652929292E66696C7465722828653D3E766F69642030213D3D6529295D5D7D3B6C65742072653D6E756C6C3B636F6E7374206E653D28293D3E287265';
wwv_flow_imp.g_varchar2_table(17) := '7C7C2872653D226175746F22292C7265293B6C65742073653D7B7D2C6C653D6E756C6C3B636F6E73742063653D28293D3E797C7C507C7C547C7C5B22636C69636B222C22686F766572222C227365706172617465225D2E696E636C756465732846292C70';
wwv_flow_imp.g_varchar2_table(18) := '653D6E65772050726F6D697365282828742C61293D3E7B636F6E7374206F3D617065782E726567696F6E2869293B6966286E756C6C3D3D6F2972657475726E20617065782E64656275672E6572726F7228226D6170626974735F6C6F6465737461726C61';
wwv_flow_imp.g_varchar2_table(19) := '79657220222B652B22203A20526567696F6E205B222B692B225D2069732068696464656E206F72206D697373696E672E22292C766F6964206128293B6F2E656C656D656E742E6F6E28227370617469616C6D6170696E697469616C697A6564222C282829';
wwv_flow_imp.g_varchar2_table(20) := '3D3E7B636F6E737420653D617065782E726567696F6E2869292E63616C6C28226765744D61704F626A65637422293B742865297D29297D29292E7468656E2828743D3E7B742E5F5F6D6170626974735F6C617965725F637572736F72733F3F3D6E657720';
wwv_flow_imp.g_varchar2_table(21) := '4D61702C742E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F61646465647C7C28742E6F6E28227374796C65696D6167656D697373696E67222C28653D3E7B6D6170626974735F6C6F6465737461725F696D6167655F68616E64';
wwv_flow_imp.g_varchar2_table(22) := '6C65722865297D29292C742E5F5F6D6170626974735F6572726F725F68616E646C65725F61646465647C7C28742E6F6E28226572726F72222C28653D3E7B617065782E64656275672E6572726F7228604D6170206572726F7220696E20726567696F6E20';
wwv_flow_imp.g_varchar2_table(23) := '247B697D3A20602C652E6572726F72297D29292C742E5F5F6D6170626974735F6572726F725F68616E646C65725F61646465643D2130292C742E5F5F6D6170626974735F5F7374796C65696D6167656D697373696E675F61646465643D2130293B636F6E';
wwv_flow_imp.g_varchar2_table(24) := '737420613D24282223222B692B225F6C6567656E6422293B72657475726E202428273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C';
wwv_flow_imp.g_varchar2_table(25) := '65223E27292E617070656E64282428273C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22223E27292E70';
wwv_flow_imp.g_varchar2_table(26) := '726F70287B69643A652B225F6C6567656E645F656E747279222C636865636B65643A226E6F6E6522213D3D557D292E637373287B222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F72223A6C7D292C2428273C6C6162656C20636C';
wwv_flow_imp.g_varchar2_table(27) := '6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C223E27292E70726F70287B69643A652B225F6C6567656E645F656E7472795F6C6162656C222C666F723A652B225F6C6567656E645F656E747279227D292E617070656E6428737C7C';
wwv_flow_imp.g_varchar2_table(28) := '652C2428273C7370616E20636C6173733D2266612066612D636972636C652D372D382066612D616E696D2D7370696E22207374796C653D22646973706C61793A206E6F6E653B206D617267696E2D6C6566743A202E35656D3B223E27292E70726F702822';
wwv_flow_imp.g_varchar2_table(29) := '6964222C652B225F6C6567656E645F656E7472795F737461747573222929292E617070656E64546F2861292C747D29293B6173796E632066756E6374696F6E20646528297B696628214B2972657475726E3B636F6E737420743D4B3F2E646174612E6665';
wwv_flow_imp.g_varchar2_table(30) := '6174757265732E6D61702828653D3E7B636F6E737420743D74652E67657428652E6964293B72657475726E2264656C657465223D3D3D743F2E616374696F6E3F6E756C6C3A7B747970653A2246656174757265222C69643A652E69642C70726F70657274';
wwv_flow_imp.g_varchar2_table(31) := '6965733A743F742E666561747572652E70726F706572746965733A652E70726F706572746965732C67656F6D657472793A743F742E666561747572652E67656F6D657472793A652E67656F6D657472797D7D29292E66696C7465722828653D3E6E756C6C';
wwv_flow_imp.g_varchar2_table(32) := '213D3D6529293F3F5B5D2C693D41727261792E66726F6D2874652E76616C7565732829292E66696C7465722828653D3E22637265617465223D3D3D652E616374696F6E29292E6D61702828653D3E287B747970653A2246656174757265222C69643A652E';
wwv_flow_imp.g_varchar2_table(33) := '666561747572652E69642C70726F706572746965733A652E666561747572652E70726F706572746965732C67656F6D657472793A652E666561747572652E67656F6D657472797D2929293B583D5B2E2E2E742C2E2E2E695D2C65652E636C65617228293B';
wwv_flow_imp.g_varchar2_table(34) := '666F7228636F6E73742065206F66205829766F69642030213D3D652E6964262665652E73657428652E69642C65293B69652E636C65617228292C61652E636C65617228293B6C657420613D303B636F6E7374206F3D653D3E7B636F6E737420743D2B2B61';
wwv_flow_imp.g_varchar2_table(35) := '3B72657475726E20766F69642030213D3D6526262869652E73657428742C65292C61652E73657428652C74292C61652E73657428652E746F537472696E6728292C7429292C747D2C723D7B2E2E2E4B2E646174612C66656174757265733A582E6D617028';
wwv_flow_imp.g_varchar2_table(36) := '28653D3E7B636F6E737420743D7B747970653A2246656174757265222C69643A6F28652E6964292C67656F6D657472793A652E67656F6D657472792C70726F706572746965733A7B2E2E2E652E70726F706572746965737D7D3B72657475726E2270726F';
wwv_flow_imp.g_varchar2_table(37) := '7065727479223D3D3D6E652829262628742E70726F706572746965735B226D6170626974732D73656C6563746564225D3D4A2626766F69642030213D3D652E696426266E756C6C213D3D652E69642626284A2E68617328652E6964297C7C4A2E68617328';
wwv_flow_imp.g_varchar2_table(38) := '652E69642E746F537472696E6728292929292C747D29297D2C6E3D61776169742070653B6966286E2E676574536F75726365285A29296E2E676574536F75726365285A292E736574446174612872293B656C73657B6C657420743D7B2E2E2E4B2C646174';
wwv_flow_imp.g_varchar2_table(39) := '613A727D3B6D7C7C2267656E6572617465496422696E20747C7C28742E67656E657261746549643D2130292C742E636C757374657226262270726F7065727479223D3D3D6E652829262628743D7B2E2E2E742C636C757374657250726F70657274696573';
wwv_flow_imp.g_varchar2_table(40) := '3A7B226D6170626974732D73656C6563746564223A5B22616E79222C5B22676574222C226D6170626974732D73656C6563746564225D5D2C2E2E2E742E636C757374657250726F706572746965737D7D293B7472797B6E2E616464536F75726365285A2C';
wwv_flow_imp.g_varchar2_table(41) := '74297D63617463682874297B617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B657D203A204661696C656420746F206164642047656F4A534F4E20736F75726365602C74297D7D7D636C61737320';
wwv_flow_imp.g_varchar2_table(42) := '75657B6973536964656261723D21303B636F6E7374727563746F722865297B746869732E6D61703D652C746869732E636F6E74656E743D2428273C64697620636C6173733D226D6170626974732D696E666F2D636F6E74656E74223E27292C746869732E';
wwv_flow_imp.g_varchar2_table(43) := '70616E656C3D2428273C64697620636C6173733D226D6170626974732D736964656261722D70616E656C223E27292E617070656E6428746869732E636F6E74656E74292C746869732E636C6F7365427574746F6E3D2428273C627574746F6E2074797065';
wwv_flow_imp.g_varchar2_table(44) := '3D22627574746F6E2220636C6173733D226D6170626974732D736964656261722D636C6F73652220617269612D6C6162656C3D22436C6F73652053696465626172223E3C7370616E20636C6173733D2266612066612D72656D6F7665223E3C2F7370616E';
wwv_flow_imp.g_varchar2_table(45) := '3E3C2F627574746F6E3E27292E6F6E2822636C69636B222C2828293D3E7B746869732E6869646528297D29292C746869732E636F6E7461696E65723D2428273C64697620636C6173733D226D6170626974732D7369646562617222207374796C653D2264';
wwv_flow_imp.g_varchar2_table(46) := '6973706C61793A206E6F6E653B223E27292E617070656E6428746869732E70616E656C292E617070656E6428746869732E636C6F7365427574746F6E292C2428746869732E6D61702E676574436F6E7461696E65722829292E617070656E642874686973';
wwv_flow_imp.g_varchar2_table(47) := '2E636F6E7461696E6572292C746869732E746F704C65667453697A653D6E657720526573697A654F627365727665722828653D3E7B746869732E636F6E7461696E65722E63737328222D2D6D6170626974732D736964656261722D746F70222C655B305D';
wwv_flow_imp.g_varchar2_table(48) := '2E636F6E74656E74526563742E6865696768742B22707822297D29292C746869732E746F704C65667453697A652E6F62736572766528652E676574436F6E7461696E657228292E717565727953656C6563746F7228222E6D61706C69627265676C2D6374';
wwv_flow_imp.g_varchar2_table(49) := '726C2D746F702D6C6566742229292C746869732E626F74746F6D4C65667453697A653D6E657720526573697A654F627365727665722828653D3E7B746869732E636F6E7461696E65722E63737328222D2D6D6170626974732D736964656261722D626F74';
wwv_flow_imp.g_varchar2_table(50) := '746F6D222C655B305D2E636F6E74656E74526563742E6865696768742B22707822297D29292C746869732E626F74746F6D4C65667453697A652E6F62736572766528652E676574436F6E7461696E657228292E717565727953656C6563746F7228222E6D';
wwv_flow_imp.g_varchar2_table(51) := '61706C69627265676C2D6374726C2D626F74746F6D2D6C6566742229297D6F6E52656D6F766528297B746869732E636F6E7461696E65722E72656D6F766528292C746869732E746F704C65667453697A652E646973636F6E6E65637428292C746869732E';
wwv_flow_imp.g_varchar2_table(52) := '626F74746F6D4C65667453697A652E646973636F6E6E65637428297D6869646528297B746869732E636F6E7461696E65722E6869646528292C746869732E636C6F73653F2E28297D73686F7728652C74297B746869732E636F6E74656E742E68746D6C28';
wwv_flow_imp.g_varchar2_table(53) := '65292C746869732E636C6F73653D742C746869732E636F6E7461696E65722E746F67676C65436C61737328226D6170626974732D736964656261722D636C6F736561626C65222C2121746869732E636C6F7365292C746869732E636F6E7461696E65722E';
wwv_flow_imp.g_varchar2_table(54) := '73686F7728297D7D636F6E7374206D653D28652C742C692C61293D3E7B636F6E7374206F3D5B5D2C723D7B7D2C6E3D692E6973536964656261723F2273696465626172223A22706F707570222C733D612E5F5F6D6170626974735F5F696E666F5F77696E';
wwv_flow_imp.g_varchar2_table(55) := '646F775F646174613B666F7228636F6E73742069206F6620612E717565727952656E6465726564466561747572657328652E706F696E7429297B636F6E737420653D732E696E666F57696E646F77735B692E6C617965722E69645D3B6966286529666F72';
wwv_flow_imp.g_varchar2_table(56) := '28636F6E73742061206F662065297B69662821742E696E636C7564657328612E6265686176696F722929636F6E74696E75653B696628612E6C6F636174696F6E213D3D6E29636F6E74696E75653B636F6E737420653D60247B612E6974656D4E616D657D';
wwv_flow_imp.g_varchar2_table(57) := '20247B612E6265686176696F727D20247B692E69647D603B6966286520696E207229636F6E74696E75653B696628692E70726F706572746965732E636C757374657229636F6E74696E75653B6C6574206C3D7B7D3B666F7228636F6E73742065206F6620';
wwv_flow_imp.g_varchar2_table(58) := '4F626A6563742E6B65797328692E70726F7065727469657329296C5B655D3D28692E70726F706572746965735B655D3F3F2222292E746F537472696E6728293B636F6E737420633D732E74656D706C6174654F7574707574735B655D3F3F7B656C656D65';
wwv_flow_imp.g_varchar2_table(59) := '6E743A242E706172736548544D4C28617065782E7574696C2E6170706C7954656D706C61746528612E68746D6C45787072657373696F6E3F3F22222C7B706C616365686F6C646572733A6C2C6578747261537562737469747574696F6E733A6C7D29292C';
wwv_flow_imp.g_varchar2_table(60) := '7365713A612E73657175656E63654E756D6265727D3B6F2E707573682863292C725B655D3D637D7D6966286F2E736F7274282828652C74293D3E652E7365712D742E73657129292C732E74656D706C6174654F7574707574733D722C6F2E6C656E677468';
wwv_flow_imp.g_varchar2_table(61) := '3E30297B636F6E737420743D2428273C64697620636C6173733D226D6170626974732D696E666F2D77696E646F77223E27293B6C657420723D21303B666F7228636F6E73742065206F66206F29727C7C742E617070656E64282428223C68722F3E222929';
wwv_flow_imp.g_varchar2_table(62) := '2C723D21312C742E617070656E6428652E656C656D656E74293B692E6973536964656261723F692E73686F7728742E6765742830292C732E736964656261724D61726B65723F28293D3E7B732E736964656261724D61726B65723F2E72656D6F76652829';
wwv_flow_imp.g_varchar2_table(63) := '2C732E736964656261724D61726B65723D6E756C6C7D3A6E756C6C293A28692E7365744C6E674C617428652E6C6E674C6174292C692E736574444F4D436F6E74656E7428742E676574283029292C692E616464546F286129297D656C736520692E697353';
wwv_flow_imp.g_varchar2_table(64) := '6964656261723F692E6869646528293A692E72656D6F766528297D3B6C65742079652C66653D21312C67653D6E6577205365742C68653D6E756C6C3B6173796E632066756E6374696F6E20626528297B24282223222B652B225F6C6567656E645F656E74';
wwv_flow_imp.g_varchar2_table(65) := '72795F73746174757322292E6373732822646973706C6179222C22696E6C696E6522292C617065782E6576656E742E74726967676572282223222B652C226C6F61645F737461727422293B7472797B6C657420653D2266756E6374696F6E223D3D747970';
wwv_flow_imp.g_varchar2_table(66) := '656F6620753F6177616974207528293A753B653F3F3D7B7D2C77262628652E636C75737465723F3F3D21302C766F69642030213D3D78262628652E636C75737465725261646975733F3F3D78292C766F69642030213D3D53262628652E636C7573746572';
wwv_flow_imp.g_varchar2_table(67) := '4D61785A6F6F6D3F3F3D53292C766F69642030213D3D6B262628652E636C75737465724D696E506F696E74733F3F3D6B29293B636F6E737420693D653D3E7B636F6E737420743D6E6577204D61703B666F7228636F6E73742069206F6620653F2E666561';
wwv_flow_imp.g_varchar2_table(68) := '74757265733F3F5B5D29666F7228636F6E73742065206F66204F626A6563742E6765744F776E50726F70657274794E616D657328692E70726F706572746965733F3F7B7D2929742E6861732865292626742E73657428652C7B6E616D653A657D293B7265';
wwv_flow_imp.g_varchar2_table(69) := '7475726E5B2E2E2E742E76616C75657328295D7D3B696628226A617661736372697074223D3D3D67297B4B3D7B2E2E2E652C747970653A2267656F6A736F6E227D3B636F6E737420743D6928652E64617461293B7426262868653D74297D656C73657B63';
wwv_flow_imp.g_varchar2_table(70) := '6F6E737420693D617761697420617065782E7365727665722E706C7567696E28742C7B706167654974656D733A663F662E73706C697428222C22292E66696C7465722828653D3E21216529293A766F696420307D293B4B3D7B2E2E2E652C747970653A22';
wwv_flow_imp.g_varchar2_table(71) := '67656F6A736F6E222C646174613A7B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A692E66656174757265737D7D2C68653D692E636F6C756D6E737D67653D6E6577205365742868652E6D61702828653D3E652E6E';
wwv_flow_imp.g_varchar2_table(72) := '616D652929292C617761697420646528297D66696E616C6C797B617065782E6576656E742E74726967676572282223222B652C226C6F61645F656E6422292C24282223222B652B225F6C6567656E645F656E7472795F73746174757322292E6373732822';
wwv_flow_imp.g_varchar2_table(73) := '646973706C6179222C226E6F6E6522297D636F6E737420693D61776169742070653B6966284C3F3F3D2223303566616464222C6665296C653F2E28293B656C73657B66653D21302C43262628692E5F5F6D6170626974735F72656374616E676C655F7365';
wwv_flow_imp.g_varchar2_table(74) := '6C6563745F636F6E74726F6C7C7C28692E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C3D6E65772076652C692E616464436F6E74726F6C28692E5F5F6D6170626974735F72656374616E676C655F73656C656374';
wwv_flow_imp.g_varchar2_table(75) := '5F636F6E74726F6C29292C692E5F5F6D6170626974735F72656374616E676C655F73656C6563745F636F6E74726F6C2E6164644C61796572286529293B636F6E737420743D28652C743D653D3E65293D3E7B69662822737472696E67223D3D747970656F';
wwv_flow_imp.g_varchar2_table(76) := '662065297B636F6E737420693D652E6D61746368282F5E26285B412D5A612D7A5C645F5D2B295C2E242F293B696628692972657475726E2067652E68617328695B315D293F5B22676574222C695B315D5D3A7428617065782E7574696C2E6170706C7954';
wwv_flow_imp.g_varchar2_table(77) := '656D706C617465286529297D72657475726E20653F742865293A6E756C6C7D3B7377697463682861297B636173652273796D626F6C223A79653D7B747970653A2273796D626F6C222C6C61796F75743A7B7D7D2C6F26262879652E6C61796F75745B2274';
wwv_flow_imp.g_varchar2_table(78) := '6578742D6669656C64225D3D5B2263617365222C5B22686173222C22706F696E745F636F756E74225D2C5B22636F6E636174222C5B22676574222C22706F696E745F636F756E74225D2C22206665617475726573225D2C5B22676574222C6F5D5D2C7965';
wwv_flow_imp.g_varchar2_table(79) := '2E6C61796F75745B22746578742D73697A65225D3D742876293F3F3132292C6426262879652E6C61796F75745B2269636F6E2D696D616765225D3D74286429293B627265616B3B63617365226C696E65223A7B79653D5B5D2C2270726F7065727479223D';
wwv_flow_imp.g_varchar2_table(80) := '3D3D6E652829262679652E70757368287B69643A2273656C656374696F6E222C747970653A226C696E65222C66696C7465723A2121707C7C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C6C61796F75743A';
wwv_flow_imp.g_varchar2_table(81) := '7B7D2C7061696E743A7B226C696E652D7769647468223A5B222B222C322C7428622C7061727365466C6F6174293F3F315D2C226C696E652D636F6C6F72223A703F5B2263617365222C5B223D3D222C5B22676574222C226D6170626974732D73656C6563';
wwv_flow_imp.g_varchar2_table(82) := '746564225D2C21305D2C4C2C742870295D3A4C7D7D293B636F6E737420653D7B747970653A226C696E65222C6C61796F75743A7B7D2C7061696E743A7B226C696E652D7769647468223A7428622C7061727365466C6F6174293F3F317D7D3B5F26262865';
wwv_flow_imp.g_varchar2_table(83) := '2E7061696E745B226C696E652D646173686172726179225D3D5F2E73706C697428222022292E6D61702828653D3E7061727365466C6F61742865292929292C79652E707573682865292C6F262679652E70757368287B69643A226C6162656C222C747970';
wwv_flow_imp.g_varchar2_table(84) := '653A2273796D626F6C222C6C61796F75743A7B22746578742D6669656C64223A5B22676574222C6F5D2C22746578742D73697A65223A742876293F3F31322C2273796D626F6C2D706C6163656D656E74223A226C696E65227D7D293B627265616B7D6361';
wwv_flow_imp.g_varchar2_table(85) := '73652266696C6C223A79653D5B7B747970653A2266696C6C222C6C61796F75743A7B7D2C7061696E743A7B7D7D5D2C2270726F7065727479223D3D3D6E652829262679652E70757368287B69643A2273656C656374696F6E222C747970653A226C696E65';
wwv_flow_imp.g_varchar2_table(86) := '222C66696C7465723A5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C6C61796F75743A7B7D2C7061696E743A7B226C696E652D7769647468223A332C226C696E652D636F6C6F72223A4C7D7D293B62726561';
wwv_flow_imp.g_varchar2_table(87) := '6B3B6361736522636972636C65223A79653D5B7B747970653A22636972636C65222C6C61796F75743A7B7D2C7061696E743A7B22636972636C652D726164697573223A74284D2C7061727365466C6F6174293F3F352C22636972636C652D626C7572223A';
wwv_flow_imp.g_varchar2_table(88) := '74286A293F3F307D7D5D2C6F262679652E70757368287B69643A226C6162656C222C747970653A2273796D626F6C222C6C61796F75743A7B22746578742D6669656C64223A5B2263617365222C5B22686173222C22706F696E745F636F756E74225D2C5B';
wwv_flow_imp.g_varchar2_table(89) := '22636F6E636174222C5B22676574222C22706F696E745F636F756E74225D2C22206665617475726573225D2C5B22676574222C6F5D5D2C22746578742D73697A65223A742876293F3F31327D7D293B627265616B3B6361736522686561746D6170223A79';
wwv_flow_imp.g_varchar2_table(90) := '653D5B7B747970653A22686561746D6170222C6C61796F75743A7B7D2C7061696E743A7B22686561746D61702D726164697573223A74284D293F3F33302C22686561746D61702D776569676874223A5B22676574222C22706F696E745F636F756E74225D';
wwv_flow_imp.g_varchar2_table(91) := '7D7D5D3B627265616B3B64656661756C743A79653D727D6E756C6C3D3D3D796526262879653D7B7D292C2266756E6374696F6E223D3D747970656F6620796526262879653D79652829292C41727261792E69734172726179287965297C7C2879653D5B79';
wwv_flow_imp.g_varchar2_table(92) := '655D293B636F6E737420733D79652E6D6170282828692C61293D3E7B636F6E7374206F3D7B2E2E2E692C69643A692E69643F652B222D222B692E69643A652B222D222B612C736F757263653A5A2C6C61796F75743A7B2E2E2E692E6C61796F75747D2C70';
wwv_flow_imp.g_varchar2_table(93) := '61696E743A7B2E2E2E692E7061696E747D2C6D657461646174613A7B6C617965725F73657175656E63653A6E2C6974656D5F69643A652C2E2E2E692E6D657461646174617D7D3B766F696420303D3D3D6F2E6D696E7A6F6F6D2626572626286F2E6D696E';
wwv_flow_imp.g_varchar2_table(94) := '7A6F6F6D3D57292C766F696420303D3D3D6F2E6D61787A6F6F6D2626712626286F2E6D61787A6F6F6D3D71293B636F6E737420723D7B726567756C61723A5B224D6574726F706F6C697320526567756C6172222C224E6F746F2053616E7320526567756C';
wwv_flow_imp.g_varchar2_table(95) := '6172225D2C6974616C69633A5B224D6574726F706F6C697320526567756C6172204974616C6963222C224E6F746F2053616E73204974616C6963225D2C626F6C645F6974616C69633A5B224D6574726F706F6C697320426F6C64204974616C6963225D2C';
wwv_flow_imp.g_varchar2_table(96) := '626F6C643A5B224D6574726F706F6C697320426F6C64222C224E6F746F2053616E7320426F6C64225D7D2C733D725B495D3F3F722E726567756C61722C643D28652C74293D3E2270726F7065727479223D3D3D6E6528293F5B2263617365222C5B223D3D';
wwv_flow_imp.g_varchar2_table(97) := '222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C652C745D3A743B737769746368286F2E74797065297B636173652273796D626F6C223A6F2E6C61796F75745B22746578742D6669656C64225D2626286F2E7061696E74';
wwv_flow_imp.g_varchar2_table(98) := '5B22746578742D636F6C6F72225D3F3F3D74286C292C6F2E7061696E745B22746578742D6F706163697479225D3F3F3D742863292C6F2E6C61796F75745B22746578742D666F6E74225D3F3F3D732C6F2E6C61796F75745B22746578742D73697A65225D';
wwv_flow_imp.g_varchar2_table(99) := '3F3F3D31322C6F2E7061696E745B22746578742D68616C6F2D7769647468225D3F3F3D312E352C6F2E7061696E745B22746578742D68616C6F2D636F6C6F72225D3F3F3D64284C2C742870297C7C222363636322292C6F2E6C61796F75745B2274657874';
wwv_flow_imp.g_varchar2_table(100) := '2D6A757374696679225D3F3F3D226175746F222C6F2E6C61796F75745B2269636F6E2D696D616765225D2626286F2E6C61796F75745B22746578742D6F6666736574225D3F3F3D5B302C2E355D2C6F2E6C61796F75745B22746578742D616E63686F7222';
wwv_flow_imp.g_varchar2_table(101) := '5D7C7C6F2E6C61796F75745B22746578742D7661726961626C652D616E63686F72225D7C7C286F2E6C61796F75745B22746578742D7661726961626C652D616E63686F72225D3D5B22746F70222C226C656674222C22746F702D6C656674225D2929292C';
wwv_flow_imp.g_varchar2_table(102) := '6F2E6C61796F75745B2269636F6E2D696D616765225D3F286F2E6C61796F75745B2269636F6E2D616C6C6F772D6F7665726C6170225D3F3F3D21302C6F2E6C61796F75745B22746578742D6F7074696F6E616C225D3F3F3D21302C6F2E7061696E745B22';
wwv_flow_imp.g_varchar2_table(103) := '69636F6E2D636F6C6F72225D3F3F3D74286C292C6F2E7061696E745B2269636F6E2D6F706163697479225D3F3F3D742863292C6F2E7061696E745B2269636F6E2D68616C6F2D7769647468225D3F3F3D6428322C742870293F313A30292C6F2E7061696E';
wwv_flow_imp.g_varchar2_table(104) := '745B2269636F6E2D68616C6F2D636F6C6F72225D3F3F3D64284C2C742870293F3F227472616E73706172656E742229293A6F2E6C61796F75745B22746578742D616C6C6F772D6F7665726C6170225D3F3F3D21303B627265616B3B63617365226C696E65';
wwv_flow_imp.g_varchar2_table(105) := '223A6F2E7061696E745B226C696E652D636F6C6F72225D3F3F3D74286C292C6F2E7061696E745B226C696E652D6F706163697479225D3F3F3D742863293B627265616B3B636173652266696C6C223A6F2E7061696E745B2266696C6C2D636F6C6F72225D';
wwv_flow_imp.g_varchar2_table(106) := '3F3F3D74286C292C6F2E7061696E745B2266696C6C2D6F706163697479225D3F3F3D742863292C6F2E7061696E745B2266696C6C2D6F75746C696E652D636F6C6F72225D3F3F3D742870297C7C22626C61636B223B627265616B3B636173652263697263';
wwv_flow_imp.g_varchar2_table(107) := '6C65223A6F2E7061696E745B22636972636C652D6F706163697479225D3F3F3D742863292C6F2E7061696E745B22636972636C652D636F6C6F72225D3F3F3D74286C292C702626286F2E7061696E745B22636972636C652D7374726F6B652D636F6C6F72';
wwv_flow_imp.g_varchar2_table(108) := '225D3F3F3D742870292C6F2E7061696E745B22636972636C652D7374726F6B652D7769647468225D3F3F3D31297D72657475726E206F7D29293B6966282270726F706572747922213D3D6E652829297B636F6E737420693D5B5D3B692E70757368287B69';
wwv_flow_imp.g_varchar2_table(109) := '643A226C696E65222C747970653A226C696E65222C66696C7465723A5B22696E222C5B2267656F6D657472792D74797065225D2C5B226C69746572616C222C5B224C696E65537472696E67222C224D756C74694C696E65537472696E67225D5D5D2C6C61';
wwv_flow_imp.g_varchar2_table(110) := '796F75743A7B226C696E652D636170223A73655B226C696E652D636170225D3F3F22726F756E64227D2C7061696E743A7B226C696E652D6761702D7769647468223A73655B226C696E652D6761702D7769647468225D3F3F332C226C696E652D77696474';
wwv_flow_imp.g_varchar2_table(111) := '68223A73655B226C696E652D7769647468225D3F3F322C226C696E652D636F6C6F72223A73655B226C696E652D636F6C6F72225D3F3F4C7D7D292C692E70757368287B69643A2266696C6C222C747970653A2266696C6C222C66696C7465723A5B22696E';
wwv_flow_imp.g_varchar2_table(112) := '222C5B2267656F6D657472792D74797065225D2C5B226C69746572616C222C5B22506F6C79676F6E222C224D756C7469506F6C79676F6E225D5D5D2C6C61796F75743A7B7D2C7061696E743A7B2266696C6C2D636F6C6F72223A73655B2266696C6C2D63';
wwv_flow_imp.g_varchar2_table(113) := '6F6C6F72225D3F3F4C2C2266696C6C2D6F706163697479223A73655B2266696C6C2D6F706163697479225D3F3F2E357D7D292C692E70757368287B69643A2266696C6C2D6F75746C696E65222C747970653A226C696E65222C66696C7465723A5B22696E';
wwv_flow_imp.g_varchar2_table(114) := '222C5B2267656F6D657472792D74797065225D2C5B226C69746572616C222C5B22506F6C79676F6E222C224D756C7469506F6C79676F6E225D5D5D2C6C61796F75743A7B7D2C7061696E743A7B226C696E652D636F6C6F72223A73655B226C696E652D63';
wwv_flow_imp.g_varchar2_table(115) := '6F6C6F72225D3F3F4C2C226C696E652D7769647468223A73655B226C696E652D7769647468225D3F3F327D7D292C692E70757368287B69643A22706F696E74222C747970653A22636972636C65222C66696C7465723A5B22696E222C5B2267656F6D6574';
wwv_flow_imp.g_varchar2_table(116) := '72792D74797065225D2C5B226C69746572616C222C5B22506F696E74222C224D756C7469506F696E74225D5D5D2C7061696E743A7B22636972636C652D726164697573223A73655B22636972636C652D726164697573225D3F3F74284D2C706172736546';
wwv_flow_imp.g_varchar2_table(117) := '6C6F6174293F3F352C22636972636C652D636F6C6F72223A73655B22636972636C652D636F6C6F72225D3F3F227472616E73706172656E74222C22636972636C652D7374726F6B652D636F6C6F72223A73655B22636972636C652D7374726F6B652D636F';
wwv_flow_imp.g_varchar2_table(118) := '6C6F72225D3F3F4C2C22636972636C652D7374726F6B652D7769647468223A73655B22636972636C652D7374726F6B652D7769647468225D3F3F327D7D293B636F6E737420613D6F6528293B666F7228636F6E73742074206F66206929732E7075736828';
wwv_flow_imp.g_varchar2_table(119) := '7B2E2E2E742C69643A652B222D2D73656C656374696F6E2D222B742E69642C736F757263653A5A2C6D657461646174613A7B6C617965725F73657175656E63653A6E7D2C66696C7465723A742E66696C7465723F5B22616C6C222C742E66696C7465722C';
wwv_flow_imp.g_varchar2_table(120) := '615D3A617D293B6C653D6173796E6328293D3E7B636F6E737420743D61776169742070652C613D6F6528293B666F7228636F6E7374206F206F66206929742E73657446696C74657228652B222D2D73656C656374696F6E2D222B6F2E69642C6F2E66696C';
wwv_flow_imp.g_varchar2_table(121) := '7465723F5B22616C6C222C6F2E66696C7465722C615D3A61297D7D636F6E737420753D692E6765745374796C6528292E6C61796572732E66696C7465722828653D3E226D6574616461746122696E20652626226C617965725F73657175656E636522696E';
wwv_flow_imp.g_varchar2_table(122) := '20652E6D6574616461746129292E6D6170282866756E6374696F6E2865297B72657475726E5B652E6D657461646174612E6C617965725F73657175656E63652C652E69645D7D29293B6C6574206D3B69662830213D3D752E6C656E677468297B752E736F';
wwv_flow_imp.g_varchar2_table(123) := '7274282828652C74293D3E655B305D2D745B305D29293B666F72286C657420653D303B653C752E6C656E6774683B652B2B296966286E3C755B655D5B305D297B6D3D755B655D5B315D3B627265616B7D7D6C657420793D6E756C6C3B666F7228636F6E73';
wwv_flow_imp.g_varchar2_table(124) := '742074206F662073297472797B696628692E6164644C6179657228742C6D292C467C7C42297B636F6E737420613D653D3E7B69662821692E5F5F6D6170626974735F5F696E666F5F77696E646F775F64617461297B636F6E737420653D6E657720756528';
wwv_flow_imp.g_varchar2_table(125) := '69293B692E5F5F6D6170626974735F5F696E666F5F77696E646F775F646174613D7B686F766572506F7075703A6E6577206D61706C69627265676C2E506F707570287B636C6F7365427574746F6E3A21312C636C6F73654F6E436C69636B3A21312C636C';
wwv_flow_imp.g_varchar2_table(126) := '6173734E616D653A226D6170626974732D686F7665722D706F707570206D6170626974732D696E666F2D636F6E74656E74227D292E747261636B506F696E74657228292C636C69636B506F7075703A6E756C6C2C736964656261723A652C736964656261';
wwv_flow_imp.g_varchar2_table(127) := '724D61726B65723A6E756C6C2C696E666F57696E646F77733A7B7D2C74656D706C6174654F7574707574733A7B7D7D7D636F6E737420613D692E5F5F6D6170626974735F5F696E666F5F77696E646F775F646174613B696628612E696E666F57696E646F';
wwv_flow_imp.g_varchar2_table(128) := '77735B742E69645D3F612E696E666F57696E646F77735B742E69645D2E707573682865293A612E696E666F57696E646F77735B742E69645D3D5B655D2C2273696465626172223D3D3D652E6C6F636174696F6E297B6966285B22686F766572222C22686F';
wwv_flow_imp.g_varchar2_table(129) := '7665725F6F6E6C79225D2E696E636C7564657328652E6265686176696F7229297B636F6E737420653D653D3E7B6E756C6C3D3D3D612E736964656261724D61726B657226266D6528652C5B22686F766572222C22686F7665725F6F6E6C79225D2C612E73';
wwv_flow_imp.g_varchar2_table(130) := '6964656261722C69297D3B692E6F6E28226D6F757365656E746572222C742E69642C65292C692E6F6E28226D6F7573656D6F7665222C742E69642C65292C692E6F6E28226D6F7573656C65617665222C742E69642C65292C692E676574436F6E7461696E';
wwv_flow_imp.g_varchar2_table(131) := '657228292E6164644576656E744C697374656E657228226D6F7573656C65617665222C2828293D3E7B612E736964656261724D61726B65727C7C612E736964656261722E6869646528297D29297D5B22636C69636B222C22686F766572225D2E696E636C';
wwv_flow_imp.g_varchar2_table(132) := '7564657328652E6265686176696F72292626692E6F6E2822636C69636B222C742E69642C28653D3E7B612E736964656261724D61726B65722626612E736964656261724D61726B65722E72656D6F766528292C612E736964656261724D61726B65723D28';
wwv_flow_imp.g_varchar2_table(133) := '6E6577206D61706C69627265676C2E4D61726B6572292E7365744C6E674C617428652E6C6E674C6174292E616464546F2869292C6D6528652C5B22636C69636B222C22686F766572225D2C612E736964656261722C69297D29297D656C73657B6966285B';
wwv_flow_imp.g_varchar2_table(134) := '22686F766572222C22686F7665725F6F6E6C79225D2E696E636C7564657328652E6265686176696F7229297B636F6E737420653D653D3E7B6E756C6C3D3D3D612E636C69636B506F70757026266D6528652C5B22686F766572222C22686F7665725F6F6E';
wwv_flow_imp.g_varchar2_table(135) := '6C79225D2C612E686F766572506F7075702C69297D3B692E6F6E28226D6F757365656E746572222C742E69642C65292C692E6F6E28226D6F7573656D6F7665222C742E69642C65292C692E6F6E28226D6F7573656C65617665222C742E69642C65292C69';
wwv_flow_imp.g_varchar2_table(136) := '2E676574436F6E7461696E657228292E6164644576656E744C697374656E657228226D6F7573656C65617665222C2828293D3E7B612E686F766572506F7075702E72656D6F766528297D29297D5B22636C69636B222C22686F766572225D2E696E636C75';
wwv_flow_imp.g_varchar2_table(137) := '64657328652E6265686176696F72292626692E6F6E2822636C69636B222C742E69642C28653D3E7B6966286E756C6C213D3D612E636C69636B506F7075702972657475726E3B636F6E737420743D6E6577206D61706C69627265676C2E506F707570287B';
wwv_flow_imp.g_varchar2_table(138) := '636C6173734E616D653A226D6170626974732D636C69636B2D706F707570206D6170626974732D696E666F2D636F6E74656E74227D293B6D6528652C5B22636C69636B222C22686F766572225D2C742C69292C742E69734F70656E2829262628612E636C';
wwv_flow_imp.g_varchar2_table(139) := '69636B506F7075703D74292C612E686F766572506F7075702E72656D6F766528292C742E6F6E2822636C6F7365222C2828293D3E7B612E636C69636B506F7075703D6E756C6C7D29297D29297D7D2C6F3D28742C692C6F2C72293D3E7B22736570617261';
wwv_flow_imp.g_varchar2_table(140) := '7465223D3D3D743F2861287B68746D6C45787072657373696F6E3A692C6974656D4E616D653A652C6265686176696F723A22686F7665725F6F6E6C79222C73657175656E63654E756D6265723A6E2C6C6F636174696F6E3A727D292C61287B68746D6C45';
wwv_flow_imp.g_varchar2_table(141) := '787072657373696F6E3A6F2C6974656D4E616D653A652C6265686176696F723A22636C69636B222C73657175656E63654E756D6265723A6E2C6C6F636174696F6E3A727D29293A61287B68746D6C45787072657373696F6E3A692C6974656D4E616D653A';
wwv_flow_imp.g_varchar2_table(142) := '652C6265686176696F723A742C73657175656E63654E756D6265723A6E2C6C6F636174696F6E3A727D297D3B6F28462C4E2C7A2C22706F70757022292C6F28422C4F2C442C227369646562617222297D69662863652829297B692E5F5F6D617062697473';
wwv_flow_imp.g_varchar2_table(143) := '5F6C617965725F637572736F72732E73657428742E69642C22706F696E74657222293B636F6E737420613D653D3E7B666F7228636F6E73742074206F6620692E717565727952656E6465726564466561747572657328652E706F696E742929696628692E';
wwv_flow_imp.g_varchar2_table(144) := '5F5F6D6170626974735F6C617965725F637572736F72732E68617328742E6C617965723F2E6964292972657475726E20766F696428692E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F723D692E5F5F6D617062697473';
wwv_flow_imp.g_varchar2_table(145) := '5F6C617965725F637572736F72732E67657428742E6C617965722E696429293B692E67657443616E766173436F6E7461696E657228292E7374796C652E72656D6F766550726F70657274792822637572736F7222297D3B696628692E6F6E28226D6F7573';
wwv_flow_imp.g_varchar2_table(146) := '65656E746572222C742E69642C61292C692E6F6E28226D6F7573656C65617665222C742E69642C61292C50262645297B6C657420653D21313B692E6F6E28226D6F757365646F776E222C742E69642C28743D3E7B696628742E6F726967696E616C457665';
wwv_flow_imp.g_varchar2_table(147) := '6E742E73686966744B6579297B692E717565727952656E6465726564466561747572657328742E706F696E74295B305D2E6C617965722E69643D3D3D742E66656174757265735B305D2E6C617965722E6964262628653D692E626F785A6F6F6D2E697345';
wwv_flow_imp.g_varchar2_table(148) := '6E61626C656428292C692E626F785A6F6F6D2E64697361626C652829297D7D29292C692E6F6E28226D6F7573657570222C742E69642C2828293D3E7B652626692E626F785A6F6F6D2E656E61626C6528297D29297D692E6F6E2822636C69636B222C742E';
wwv_flow_imp.g_varchar2_table(149) := '69642C28743D3E7B636F6E737420613D692E717565727952656E6465726564466561747572657328742E706F696E74295B305D2E6C617965722E69643D3D3D742E66656174757265735B305D2E6C617965722E69642C6F3D69652E67657428742E666561';
wwv_flow_imp.g_varchar2_table(150) := '74757265735B305D2E6964293B696628617065782E6576656E742E74726967676572282223222B652C22636C69636B222C7B666561747572653A7B747970653A2246656174757265222C69643A6F2C70726F706572746965733A742E6665617475726573';
wwv_flow_imp.g_varchar2_table(151) := '5B305D2E70726F706572746965732C67656F6D657472793A742E66656174757265735B305D2E67656F6D657472797D2C6973546F706D6F73744C617965723A612C706F696E743A742E706F696E747D292C50262661297B696628742E6F726967696E616C';
wwv_flow_imp.g_varchar2_table(152) := '4576656E742E6374726C4B6579262641295F65285B6F5D2C22746F67676C6522293B656C736520696628742E6F726967696E616C4576656E742E73686966744B6579262645262641262679297B636F6E737420653D742E66656174757265735B305D2E70';
wwv_flow_imp.g_varchar2_table(153) := '726F706572746965735B455D2C693D742E66656174757265735B305D2E70726F706572746965735B525D2C613D5B5D3B69662852262669213D3D792E70726F706572746965735B525D29612E70757368286F293B656C736520666F7228636F6E73742074';
wwv_flow_imp.g_varchar2_table(154) := '206F6620582969662821527C7C693D3D3D742E70726F706572746965735B525D297B636F6E737420693D742E70726F706572746965735B455D2C6F3D792E70726F706572746965735B455D3B28653E6F2626653E3D692626693E3D6F7C7C653C3D6F2626';
wwv_flow_imp.g_varchar2_table(155) := '653C3D692626693C3D6F292626612E7075736828742E6964297D5F6528612C2261646422297D656C7365205F65285B6F5D2C2273657422293B793D742E66656174757265735B305D7D542626612626617065782E6E617669676174696F6E2E7265646972';
wwv_flow_imp.g_varchar2_table(156) := '6563742854297D29297D7D63617463682869297B617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B657D203A204661696C656420746F20616464206C6179657220247B742E69647D602C69297D48';
wwv_flow_imp.g_varchar2_table(157) := '3D732E6D61702828653D3E652E696429292C563D743D3E7B666F7228636F6E73742065206F66207329692E7365744C61796F757450726F706572747928652E69642C227669736962696C697479222C74293B592E7365744974656D28224D617062697473';
wwv_flow_imp.g_varchar2_table(158) := '5F4C6F6465737461724C617965725F222B652B225F7669736962696C697479222C74292C553D742C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C2276697369626C65223D';
wwv_flow_imp.g_varchar2_table(159) := '3D3D74292C617065782E6576656E742E74726967676572282223222B652C227669736962696C6974795F746F67676C6564222C7B76697369626C653A2276697369626C65223D3D3D747D297D2C226E6F6E65223D3D553F285628226E6F6E6522292C6170';
wwv_flow_imp.g_varchar2_table(160) := '65782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213129293A2856282276697369626C6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922';
wwv_flow_imp.g_varchar2_table(161) := '292E70726F702822636865636B6564222C213029292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E6368616E6765282866756E6374696F6E2865297B6C657420743D617065782E6A5175657279287468697329';
wwv_flow_imp.g_varchar2_table(162) := '3B5628742E697328223A636865636B656422293F2276697369626C65223A226E6F6E6522297D29293B666F7228636F6E73742065206F662051296528293B513D6E756C6C7D7D636F6E7374205F653D28742C69293D3E7B73776974636828743D743F3F5B';
wwv_flow_imp.g_varchar2_table(163) := '5D2C6F6C6453656C656374696F6E3D4A2C693F3F2273657422297B6361736522736574223A4A3D6E6577205365742874293B627265616B3B6361736522616464223A6966284A29666F7228636F6E73742065206F662074294A2E6164642865293B627265';
wwv_flow_imp.g_varchar2_table(164) := '616B3B636173652272656D6F7665223A6966284A29666F7228636F6E73742065206F662074294A2E64656C6574652865293B627265616B3B6361736522746F67676C65223A6966284A29666F7228636F6E73742065206F662074294A2E6861732865293F';
wwv_flow_imp.g_varchar2_table(165) := '4A2E64656C6574652865293A4A2E6164642865297D2270726F7065727479223D3D3D6E6528293F646528293A6C6526266C6528292C617065782E6576656E742E74726967676572282223222B652C2273656C656374696F6E5F6368616E67656422297D3B';
wwv_flow_imp.g_varchar2_table(166) := '636C6173732076657B636F6E7374727563746F7228297B746869732E6C61796572733D5B5D2C746869732E6163746976653D21317D6164644C617965722865297B746869732E6C61796572732E707573682865297D6F6E4164642865297B6C657420743D';
wwv_flow_imp.g_varchar2_table(167) := '6E756C6C2C693D6E756C6C2C613D21313B636F6E7374206F3D743D3E7B746869732E6163746976653D742C722E70726F702822617269612D70726573736564222C746869732E616374697665292C722E746F67676C65436C61737328226D617062697473';
wwv_flow_imp.g_varchar2_table(168) := '2D726563742D73656C6563742D627574746F6E2D746F67676C6564222C746869732E616374697665292C652E676574436F6E7461696E657228292E636C6173734C6973742E746F67676C6528226D6170626974732D726563742D73656C6563742D616374';
wwv_flow_imp.g_varchar2_table(169) := '697665222C746869732E616374697665292C612626652E6472616750616E2E656E61626C6528297D2C723D2428273C627574746F6E20747970653D22627574746F6E22207374796C653D226C696E652D6865696768743A313670783B77696474683A3332';
wwv_flow_imp.g_varchar2_table(170) := '70783B6865696768743A333270783B223E3C6920636C6173733D2266612066612D6F626A6563742D67726F7570223E3C2F693E3C2F627574746F6E3E27292E70726F7028227469746C65222C2252656374616E676C652053656C65637422292E70726F70';
wwv_flow_imp.g_varchar2_table(171) := '2822617269612D70726573736564222C746869732E616374697665292E6F6E2822636C69636B222C2828293D3E7B6F2821746869732E616374697665297D29292C6E3D6F3D3E7B746869732E61637469766526266E756C6C3D3D3D74262628693D6F2E70';
wwv_flow_imp.g_varchar2_table(172) := '6F696E742C743D2428273C64697620636C6173733D226D6170626974732D726563742D73656C6563742D626F78223E27292C652E676574436F6E7461696E657228292E617070656E644368696C6428745B305D292C613D652E6472616750616E2E697345';
wwv_flow_imp.g_varchar2_table(173) := '6E61626C656428292C612626652E6472616750616E2E64697361626C652829297D2C733D653D3E7B6966286E756C6C3D3D3D742972657475726E3B69662821746869732E6163746976652972657475726E3B652E6F726967696E616C4576656E742E7374';
wwv_flow_imp.g_varchar2_table(174) := '6F7050726F7061676174696F6E28293B636F6E737420613D4D6174682E6D696E28652E706F696E742E782C692E78292C6F3D4D6174682E6D617828652E706F696E742E782C692E78292C723D4D6174682E6D696E28652E706F696E742E792C692E79292C';
wwv_flow_imp.g_varchar2_table(175) := '6E3D4D6174682E6D617828652E706F696E742E792C692E79293B742E63737328227472616E73666F726D222C607472616E736C61746528247B617D70782C20247B727D70782960292C742E7769647468286F2D61292C742E686569676874286E2D72297D';
wwv_flow_imp.g_varchar2_table(176) := '2C6C3D613D3E7B69662821746869732E6163746976652972657475726E3B6E756C6C213D3D74262628745B305D2E706172656E744E6F64652E72656D6F76654368696C6428745B305D292C743D6E756C6C293B636F6E737420723D652E71756572795265';
wwv_flow_imp.g_varchar2_table(177) := '6E64657265644665617475726573285B612E706F696E742C695D292C6E3D6E6577205365743B666F7228636F6E73742065206F66207229482E696E636C7564657328652E6C617965722E69642926266E2E61646428652E6964293B5F652841727261792E';
wwv_flow_imp.g_varchar2_table(178) := '66726F6D286E292E6D61702828653D3E69652E67657428652929292C612E6F726967696E616C4576656E742E73686966744B65793F22616464223A2273657422292C6F282131297D3B72657475726E20652E6F6E28226D6F757365646F776E222C6E292C';
wwv_flow_imp.g_varchar2_table(179) := '652E6F6E28226D6F7573656D6F7665222C73292C652E6F6E28226D6F7573657570222C6C292C746869732E5F636C65616E75703D28293D3E7B652E6F666628226D6F757365646F776E222C6E292C652E6F666628226D6F7573656D6F7665222C73292C65';
wwv_flow_imp.g_varchar2_table(180) := '2E6F666628226D6F7573657570222C6C292C6E756C6C213D3D742626745B305D2E706172656E744E6F64652E72656D6F76654368696C6428745B305D297D2C746869732E636F6E7461696E65723D2428273C64697620636C6173733D226D61706C696272';
wwv_flow_imp.g_varchar2_table(181) := '65676C2D6374726C206D61706C69627265676C2D6374726C2D67726F7570223E27292E617070656E642872292E6765742830292C746869732E636F6E7461696E65727D6F6E52656D6F766528297B746869732E5F636C65616E757028292C746869732E63';
wwv_flow_imp.g_varchar2_table(182) := '6F6E7461696E65722E706172656E744E6F64652E72656D6F76654368696C6428746869732E636F6E7461696E6572297D7D617065782E6974656D2E63726561746528652C7B726566726573683A6173796E6328293D3E7B617761697420626528297D2C73';
wwv_flow_imp.g_varchar2_table(183) := '686F773A28293D3E7B56282276697369626C6522297D2C686964653A28293D3E7B5628226E6F6E6522297D2C697356697369626C653A28293D3E226E6F6E6522213D3D552C6861734944436F6C756D6E3A28293D3E21216D2C69734368616E6765643A28';
wwv_flow_imp.g_varchar2_table(184) := '293D3E74652E73697A653E302C67657453656C656374656446656174757265733A28293D3E4A3F41727261792E66726F6D284A293A5B5D2C73657453656C656374656446656174757265733A5F652C73656C656374416C6C46656174757265733A28293D';
wwv_flow_imp.g_varchar2_table(185) := '3E7B4B26265F65284B2E646174612E66656174757265732E6D61702828653D3E652E696429292C2273657422297D2C636C65617253656C656374696F6E3A28293D3E7B5F65285B5D2C2273657422297D2C73657453656C656374696F6E5374796C653A28';
wwv_flow_imp.g_varchar2_table(186) := '652C74293D3E7B696628726529636F6E736F6C652E6572726F72282243616E6E6F7420736574207468652073656C656374696F6E207374796C6520616674657220746865206D617020686173206265656E20696E697469616C697A656422293B656C7365';
wwv_flow_imp.g_varchar2_table(187) := '7B766F696420303D3D3D742626226F626A656374223D3D747970656F662065262628743D652C653D6E756C6C292C72653D652C73653D743D743F3F7B7D2C22656E61626C65436C69636B22696E2074262628503D742E656E61626C65436C69636B292C22';
wwv_flow_imp.g_varchar2_table(188) := '72656374616E676C6553656C65637422696E2074262628433D742E72656374616E676C6553656C656374292C22636C69636B53696E676C6553656C65637422696E2074262628413D21742E636C69636B53696E676C6553656C656374292C226F72646572';
wwv_flow_imp.g_varchar2_table(189) := '427922696E2074262628453D742E6F726465724279292C22706172746974696F6E427922696E2074262628523D742E636C69636B506172746974696F6E4279292C22636F6C6F7222696E20742626284C3D742E636F6C6F72293B666F7228636F6E737420';
wwv_flow_imp.g_varchar2_table(190) := '65206F6620483F3F5B5D29636528293F6D61702E5F5F6D6170626974735F6C617965725F637572736F72732E73657428652C22706F696E74657222293A6D61702E5F5F6D6170626974735F6C617965725F637572736F72732E64656C6574652865297D7D';
wwv_flow_imp.g_varchar2_table(191) := '2C7A6F6F6D546F466561747572653A6173796E6328652C74293D3E7B636F6E737420693D65652E6765742865293B692626286177616974207065292E666974426F756E64732828653D3E7B6C657420743D5B5D3B73776974636828652E74797065297B63';
wwv_flow_imp.g_varchar2_table(192) := '617365224D756C7469506F6C79676F6E223A743D652E636F6F7264696E617465732E666C61744D61702828653D3E652E666C61744D61702828653D3E65292929293B627265616B3B6361736522506F6C79676F6E223A63617365224D756C74694C696E65';
wwv_flow_imp.g_varchar2_table(193) := '537472696E67223A743D652E636F6F7264696E617465732E666C61744D61702828653D3E6529293B627265616B3B63617365224C696E65537472696E67223A63617365224D756C7469506F696E74223A743D652E636F6F7264696E617465733B62726561';
wwv_flow_imp.g_varchar2_table(194) := '6B3B6361736522506F696E74223A743D5B652E636F6F7264696E617465735D7D6C657420693D4D6174682E6D696E282E2E2E742E6D61702828653D3E655B315D2929292C613D4D6174682E6D696E282E2E2E742E6D61702828653D3E655B305D2929292C';
wwv_flow_imp.g_varchar2_table(195) := '6F3D4D6174682E6D6178282E2E2E742E6D61702828653D3E655B315D2929293B72657475726E5B5B612C695D2C5B4D6174682E6D6178282E2E2E742E6D61702828653D3E655B305D2929292C6F5D5D7D2928692E67656F6D65747279292C74297D2C6765';
wwv_flow_imp.g_varchar2_table(196) := '74536F75726365446174613A28293D3E4B3F2E646174612C676574536F757263654E616D653A28293D3E5A2C77616974466F724C6F61643A28293D3E6E65772050726F6D697365282828652C74293D3E7B6E756C6C3D3D3D513F6528293A512E70757368';
wwv_flow_imp.g_varchar2_table(197) := '2865297D29292C6765744C617965724944733A28293D3E482C6765744D61703A6173796E6328293D3E61776169742070652C65646974466561747572653A6173796E6328652C74293D3E7B2263726561746522213D3D657C7C742E69647C7C28742E6964';
wwv_flow_imp.g_varchar2_table(198) := '3D63727970746F2E72616E646F6D555549442829293B636F6E737420693D74652E67657428742E6964293B69662869262622637265617465223D3D3D692E616374696F6E2969662822637265617465223D3D3D692E616374696F6E262622757064617465';
wwv_flow_imp.g_varchar2_table(199) := '223D3D3D6529653D22637265617465223B656C73652069662822637265617465223D3D3D692E616374696F6E26262264656C657465223D3D3D652972657475726E2074652E64656C65746528742E6964292C766F696420617761697420646528293B7465';
wwv_flow_imp.g_varchar2_table(200) := '2E73657428742E69642C7B616374696F6E3A652C666561747572653A747D292C617761697420646528297D2C67657445646974733A28293D3E41727261792E66726F6D2874652E76616C7565732829292C676574456469746564446174613A28293D3E28';
wwv_flow_imp.g_varchar2_table(201) := '7B747970653A2246656174757265436F6C6C656374696F6E222C66656174757265733A587D292C636F6E7665727449443A653D3E69652E6765742865292C676574466561747572653A653D3E65652E6765742865292C6765744665617475726545646974';
wwv_flow_imp.g_varchar2_table(202) := '416374696F6E3A653D3E74652E6765742865293F2E616374696F6E3F3F2865652E6765742865293F226E6F6E65223A6E756C6C292C636C65617245646974733A6173796E6328293D3E7B74652E636C65617228292C617761697420646528297D2C636C65';
wwv_flow_imp.g_varchar2_table(203) := '61724564697473416E64526566726573683A6173796E6328293D3E7B74652E636C65617228292C617761697420626528297D7D292C626528293B6C65742077653D21303B696628617065782E6A51756572792822626F647922292E6F6E28226170657862';
wwv_flow_imp.g_varchar2_table(204) := '65666F726572656672657368222C286173796E6320653D3E7B652E7461726765743D3D3D617065782E726567696F6E2869292E656C656D656E745B305D26262877653F77653D21313A61776169742062652829297D29292C2266756E6374696F6E223D3D';
wwv_flow_imp.g_varchar2_table(205) := '747970656F66206826266828617065782E6974656D286529292C6520696E204D4150424954535F4C4F4445535441525F4C415945525F57414954494E47297B636F6E737420743D617065782E6974656D2865293B4D4150424954535F4C4F444553544152';
wwv_flow_imp.g_varchar2_table(206) := '5F4C415945525F57414954494E475B655D2E666F72456163682828653D3E6528742929297D4D4150424954535F4C4F4445535441525F4C415945525F57414954494E475B655D3D6E756C6C7D636F6E7374206D6170626974735F6C6F6465737461725F74';
wwv_flow_imp.g_varchar2_table(207) := '696E797364663D6E6577206D6170626974735F74696E79736466287B666F6E7453697A653A31362C666F6E7446616D696C793A22466F6E74204150455820536D616C6C227D293B66756E6374696F6E206D6170626974735F6C6F6465737461725F696D61';
wwv_flow_imp.g_varchar2_table(208) := '67655F68616E646C65722865297B636F6E737420743D286D61706C69627265676C2E67657456657273696F6E3F2E28293F3F6D61706C69627265676C2E76657273696F6E292E73706C697428222E22292E6D61702828653D3E7061727365496E74286529';
wwv_flow_imp.g_varchar2_table(209) := '29293B72657475726E206E65772050726F6D697365282828692C61293D3E7B636F6E7374206F3D652E7461726765743B6966286F2E686173496D61676528652E696429296928293B656C736520696628652E69642E73746172747357697468282266612D';
wwv_flow_imp.g_varchar2_table(210) := '2229297B636F6E737420743D646F63756D656E742E637265617465456C656D656E7428227370616E22293B742E7374796C652E646973706C61793D226E6F6E65222C742E636C6173734C6973742E6164642822666122292C742E636C6173734C6973742E';
wwv_flow_imp.g_varchar2_table(211) := '61646428652E6964292C6F2E676574436F6E7461696E657228292E617070656E644368696C642874293B636F6E737420613D77696E646F772E676574436F6D70757465645374796C6528742C223A6265666F726522292E636F6E74656E742E7375627374';
wwv_flow_imp.g_varchar2_table(212) := '72696E6728312C32293B742E72656D6F766528293B636F6E737420723D6D6170626974735F6C6F6465737461725F74696E797364662E647261772861292C6E3D6E65772055696E7438417272617928722E77696474682A722E6865696768742A34293B66';
wwv_flow_imp.g_varchar2_table(213) := '6F72286C657420653D303B653C722E646174612E6C656E6774683B652B2B296E5B342A652B335D3D722E646174615B655D3B6F2E616464496D61676528652E69642C7B646174613A6E2C77696474683A722E77696474682C6865696768743A722E686569';
wwv_flow_imp.g_varchar2_table(214) := '6768747D2C7B7364663A21307D292C6928297D656C736520652E69642E7374617274735769746828617065782E656E762E4150505F46494C455329262628745B305D3E3D343F6F2E6C6F6164496D61676528652E6964292E7468656E2828743D3E7B6F2E';
wwv_flow_imp.g_varchar2_table(215) := '686173496D61676528652E6964297C7C6F2E616464496D61676528652E69642C742E64617461292C6928297D29293A6F2E6C6F6164496D61676528652E69642C2828742C61293D3E7B6F2E686173496D61676528652E6964297C7C6F2E616464496D6167';
wwv_flow_imp.g_varchar2_table(216) := '6528652E69642C61292C6928297D2929297D29297D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(72352523467871351)
,p_plugin_id=>wwv_flow_imp.id(43432504464713289)
,p_file_name=>'mapbits-lodestarlayer.min.js'
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
