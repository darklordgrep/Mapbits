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
--   Date and Time:   19:59 Tuesday February 10, 2026
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 43409750273713273
--   Manifest End
--   Version:         24.2.4
--   Instance ID:     218369902185809
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_layer_htmlmarker
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(43409750273713273)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LAYER.HTMLMARKER'
,p_display_name=>'Mapbits HTML Marker Layer'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-htmlmarker.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure mapbits_htmlmarker',
'(',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_render_param,',
'  p_result in out nocopy apex_plugin.t_item_render_result',
')',
'is',
'  l_region_id varchar2(4000);',
'  l_numeric_region_id number;',
'  l_sequence_no   number;',
'  l_title varchar2(400) := p_item.attribute_01;',
'  l_submit_items varchar2(4000) := p_item.attribute_14;',
'  l_source_type varchar2(100) := p_item.attribute_08;',
'  l_legend_color varchar2(100) := p_item.attribute_09;',
'  l_html_content p_item.attribute_15%type := p_item.attribute_15;',
'  l_init_javascript_code p_item.init_javascript_code%type := p_item.init_javascript_code;',
'  l_zoom_range varchar2(100) := p_item.attribute_18;',
'  layer_def clob;',
'  l_da_count number;',
'begin',
'  begin',
'    select nvl(r.static_id, ''R'' || r.region_id), r.region_id, i.display_sequence into l_region_id, l_numeric_region_id, l_sequence_no  ',
'      from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then',
'      raise_application_error(-20391, ''Configuration ERROR:  Mapbits HTML Marker Item ['' || p_item.name || ''] is not associated with a Map region.'');',
'  end;',
'',
'  htp.p(''<div id="'' || p_item.name || ''" name="'' || p_item.name || ''"></div>'');',
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
'  select count(*)',
'    into l_da_count',
'    from apex_application_page_da',
'    where',
'      application_id = :APP_ID',
'      and page_id = :APP_PAGE_ID',
'      and ('','' || when_element || '','') like (''%,'' || p_item.name || '',%'')',
'      and when_event_internal_name = ''PLUGIN_MIL.ARMY.USACE.MAPBITS.LAYER.HTMLMARKER|ITEM TYPE|click'';',
'',
'  apex_javascript.add_onload_code(',
'    p_code => ''mapbits_htmlmarker({''',
'    || apex_javascript.add_attribute(''itemId'', p_item.name)',
'    || apex_javascript.add_attribute(''idColumn'', p_item.attribute_17)',
'    || apex_javascript.add_attribute(''ajaxIdentifier'', apex_plugin.get_ajax_identifier)',
'    || apex_javascript.add_attribute(''regionId'', l_region_id)',
'    || apex_javascript.add_attribute(''sequenceNumber'', nvl(l_sequence_no, 0))',
'    || apex_javascript.add_attribute(''title'', l_title)',
'    || apex_javascript.add_attribute(''submitItems'', l_submit_items)',
'    || apex_javascript.add_attribute(''sourceType'', l_source_type)',
'    || apex_javascript.add_attribute(''legendColor'', l_legend_color)',
'    || apex_javascript.add_attribute(''htmlContent'', l_html_content)',
'    || apex_javascript.add_attribute(''zoomRange'', l_zoom_range)',
'    || apex_javascript.add_attribute(''clickable'', case when l_da_count > 0 then true else false end)',
'    || ''initCode: ('' || nvl(l_init_javascript_code, ''null'') || '')''',
'    || ''});'',',
'    p_key => ''MIL.ARMY.USACE.MAPBITS.LAYER.HTMLMARKER'' || p_item.name);',
'end;',
'',
'procedure mapbits_htmlmarker_ajax (',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_ajax_param,',
'  p_result in out nocopy apex_plugin.t_item_ajax_result',
')',
'is',
'  source_type varchar2(100) := p_item.attribute_08;',
'  source_query clob;',
'  geometry_column varchar2(4000) := p_item.attribute_03;',
'  l_source_filter varchar2(4000) := p_item.attribute_16;',
'  l_id_column varchar2(4000) := p_item.attribute_17;',
'',
'  is_first_feature boolean := true;',
'  n_cols integer;',
'  feature json_object_t;',
'  feature_props json_object_t;',
'  geometry sdo_geometry;',
'  query_ctx apex_exec.t_context;',
'  column_list apex_exec.t_columns;',
'  geometry_col number := 0;',
'  l_id_col number := 0;',
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
'    elsif lower(column_list(i).name) = lower(l_id_column) then',
'      l_id_col := i;',
'    end if;',
'  end loop;',
'',
'  if geometry_col = 0 then',
'    htp.prn(''{"error": "The geometry column ('' || geometry_column || '') is not present in the query."}'');',
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
'      elsif i = l_id_col then',
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
,p_api_version=>2
,p_render_function=>'mapbits_htmlmarker'
,p_ajax_function=>'mapbits_htmlmarker_ajax'
,p_standard_attributes=>'INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>true
,p_version_scn=>454922634
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits Lodestar Layer plugin provides an alternative map layer to Apex''s built-in layers. It includes advanced configuration options that expose the full power of MapLibre styling and labeling capability.'
,p_version_identifier=>'5.0.20251126'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 5 - HTML Marker Layer',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_htmlmarker.sql 21386 2026-02-10 20:05:51Z b2eddjw9 $',
'Date     : $Date: 2026-02-10 14:05:51 -0600 (Tue, 10 Feb 2026) $',
'Revision : $Revision: 21386 $',
'Requires : Application Express >= 24.2',
'',
'Version 5 Updates:',
'11/26/2025 Fixed a bug where toggling visibility did not work properly',
'',
'--------------------',
'',
'Version 4.9 Updates:',
'05/27/2025 Fix click event and add pointer cursor when there is a click DA. Fix AJAX item submission for Region Source sources.',
'05/21/2025 Added Where Clause attribute for Region Source layers',
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
,p_files_version=>894
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(319870259985045453)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_title=>'Source'
,p_display_sequence=>1
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(319870629802045453)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_title=>'Columns'
,p_display_sequence=>2
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(319871067070045453)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_title=>'Display'
,p_display_sequence=>3
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43411049000713274)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
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
 p_id=>wwv_flow_imp.id(43411498981713274)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_static_id=>'attribute_02'
,p_prompt=>'Source Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43412233365713274)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'query'
,p_attribute_group_id=>wwv_flow_imp.id(319870259985045453)
,p_examples=>'select shape, usace_district_id from mb4_usace_districts'
,p_help_text=>'Source query used to define the layer. At a minimum this must include an SDOGeometry column. Additional attributes should include a unique identifier column if labeling features or interaction with features is required. Any additional attributes that'
||' are included in the query can be used for constructing labels or other MapLibre attribute operations.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43411823349713274)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_static_id=>'attribute_03'
,p_prompt=>'Geometry Column'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43412233365713274)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'javascript'
,p_attribute_group_id=>wwv_flow_imp.id(319870629802045453)
,p_help_text=>'Column from the source query that represents the geometry as SDOGeometry objects.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43412233365713274)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
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
,p_attribute_group_id=>wwv_flow_imp.id(319870259985045453)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43412635640713274)
,p_plugin_attribute_id=>wwv_flow_imp.id(43412233365713274)
,p_display_sequence=>10
,p_display_value=>'SQL Query'
,p_return_value=>'query'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43413117457713275)
,p_plugin_attribute_id=>wwv_flow_imp.id(43412233365713274)
,p_display_sequence=>20
,p_display_value=>'Region Source'
,p_return_value=>'region_source'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43413672519713275)
,p_plugin_attribute_id=>wwv_flow_imp.id(43412233365713274)
,p_display_sequence=>30
,p_display_value=>'JavaScript'
,p_return_value=>'javascript'
,p_help_text=>'The data is provided by JavaScript code in the Initialization JavaScript Function attribute (in the Advanced section). The initialization function must return an object with a ''dataSource'' property, which is either a GeoJSON object or an async functi'
||'on that returns one.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43414106942713275)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_static_id=>'attribute_09'
,p_prompt=>'Legend Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'The color of the marker layer''s entry in the legend.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43414592658713275)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>21
,p_static_id=>'attribute_14'
,p_prompt=>'Page Items To Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43412233365713274)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'javascript,region_source'
,p_attribute_group_id=>wwv_flow_imp.id(319870259985045453)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43414919419713275)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_static_id=>'attribute_15'
,p_prompt=>'Marker Content'
,p_attribute_type=>'HTML'
,p_is_required=>true
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(319871067070045453)
,p_help_text=>'The HTML content of the marker. Use substitutions to include columns from the query.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43415336627713275)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>160
,p_static_id=>'attribute_16'
,p_prompt=>'Where Clause'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43412233365713274)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'region_source'
,p_attribute_group_id=>wwv_flow_imp.id(319870259985045453)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43415789237713275)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>170
,p_static_id=>'attribute_17'
,p_prompt=>'ID Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(319870629802045453)
,p_help_text=>'The column to get the feature ID from.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43416189747713276)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>180
,p_static_id=>'attribute_18'
,p_prompt=>'Min/Max Zoom'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(319871067070045453)
,p_examples=>'0-12'
,p_help_text=>'The minimum and maximum zoom levels to show this layer at.'
);
wwv_flow_imp_shared.create_plugin_std_attribute(
 p_id=>wwv_flow_imp.id(43417781956713278)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43418188338713278)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_name=>'click'
,p_display_name=>'Feature Clicked'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43418533522713278)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_name=>'load_end'
,p_display_name=>'Loading Finished'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43418969063713278)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_name=>'load_start'
,p_display_name=>'Loading Started'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(43419319455713278)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_name=>'visibility_toggled'
,p_display_name=>'Visibility Toggled'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F48544D4C5F4D41524B45525F57414954494E47203D207B7D3B0D0A0D0A2F2A2A0D0A202A20416E206173796E6368726F6E6F75732066756E6374696F6E20746861742072657475726E73207468652048544D4C204D61';
wwv_flow_imp.g_varchar2_table(2) := '726B6572206974656D206F6E6365206974206861730D0A202A20696E697469616C697A65642E0D0A202A2F0D0A66756E6374696F6E206D6170626974735F68746D6C6D61726B65725F776169745F666F725F696E6974286974656D496429207B0D0A2020';
wwv_flow_imp.g_varchar2_table(3) := '72657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020206966202821286974656D496420696E204D4150424954535F48544D4C5F4D41524B45525F57414954494E472929207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(4) := '20204D4150424954535F48544D4C5F4D41524B45525F57414954494E475B6974656D49645D203D205B5D3B0D0A202020207D0D0A0D0A20202020696620284D4150424954535F48544D4C5F4D41524B45525F57414954494E475B6974656D49645D203D3D';
wwv_flow_imp.g_varchar2_table(5) := '3D206E756C6C29207B0D0A2020202020207265736F6C766528617065782E6974656D286974656D496429293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A202020204D4150424954535F48544D4C5F4D41524B45525F57414954494E';
wwv_flow_imp.g_varchar2_table(6) := '475B6974656D49645D2E7075736828286974656D29203D3E207B0D0A2020202020207265736F6C7665286974656D293B0D0A202020207D293B0D0A20207D290D0A7D0D0A0D0A0D0A66756E6374696F6E206D6170626974735F68746D6C6D61726B657228';
wwv_flow_imp.g_varchar2_table(7) := '7B0D0A20206974656D49642C20616A61784964656E7469666965722C20726567696F6E49642C2073657175656E63654E756D6265722C207469746C652C207375626D69744974656D732C2068746D6C436F6E74656E742C20696E6974436F64652C20736F';
wwv_flow_imp.g_varchar2_table(8) := '75726365547970652C206C6567656E64436F6C6F722C20636C69636B61626C652C207A6F6F6D52616E67652C206964436F6C756D6E2C0D0A7D29207B0D0A20206966202821726567696F6E496429207B0D0A20202020617065782E64656275672E657272';
wwv_flow_imp.g_varchar2_table(9) := '6F7228276D6170626974735F68746D6C6D61726B65722027202B206974656D4964202B2027203A204974656D206973206E6F7420696E206120726567696F6E2E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A20202F2F204C697374206F';
wwv_flow_imp.g_varchar2_table(10) := '662066756E6374696F6E7320746F2062652063616C6C6564207768656E20746865206974656D20697320646F6E65206C6F6164696E670D0A20206C65742077616974466F724C6F6164203D205B5D3B0D0A0D0A20202F2F2054686520636F6E6669677572';
wwv_flow_imp.g_varchar2_table(11) := '6174696F6E206F626A6563742072657475726E65642066726F6D2074686520496E697469616C697A6174696F6E204A6176615363726970742046756E6374696F6E0D0A2020636F6E737420636F6E666967203D20696E6974436F6465203F20696E697443';
wwv_flow_imp.g_varchar2_table(12) := '6F64652829203A207B7D3B0D0A0D0A20206C6574206C61796572735669736962696C697479203D20617065782E73746F726167652E676574436F6F6B696528274D6170626974735F48544D4C4D61726B65725F27202B206974656D4964202B20275F2720';
wwv_flow_imp.g_varchar2_table(13) := '2B202476282770496E7374616E63652729293B0D0A0D0A20206C65742073656C65637465644665617475726573203D206E756C6C3B0D0A0D0A20206C6574207365744C61796572735669736962696C697479203D20287669736962696C69747929203D3E';
wwv_flow_imp.g_varchar2_table(14) := '207B0D0A202020206C61796572735669736962696C697479203D207669736962696C6974793B0D0A20207D3B0D0A0D0A2020636F6E73742070617273655A6F6F6D52616E6765203D202872616E676529203D3E207B0D0A202020202F2F20676574207468';
wwv_flow_imp.g_varchar2_table(15) := '65207A6F6F6D2072616E67652C20646F206E6F7420646973706C6179206C61796572206F757473696465206F6620746869732072616E67652E0D0A202020206C6574206D61746368203D2072616E67652E6D61746368282F5E285B302D395D2B293F5B2D';
wwv_flow_imp.g_varchar2_table(16) := '2C3A5D285B302D395D2B293F242F293B0D0A20202020696620286D6174636829207B0D0A202020202020636F6E7374207A6D696E203D204D6174682E6D617828302C204D6174682E6D696E287061727365496E74286D617463685B315D203F3F20273027';
wwv_flow_imp.g_varchar2_table(17) := '292C20323429293B0D0A202020202020636F6E7374207A6D6178203D204D6174682E6D617828302C204D6174682E6D696E287061727365496E74286D617463685B325D203F3F2027323427292C20323429293B0D0A20202020202072657475726E205B7A';
wwv_flow_imp.g_varchar2_table(18) := '6D696E2C207A6D61785D3B0D0A202020207D20656C7365207B0D0A202020202020636F6E736F6C652E7761726E2860436F6E66696775726174696F6E204572726F723A204D6170626974732048544D4C204D61726B6572204C61796572205B247B697465';
wwv_flow_imp.g_varchar2_table(19) := '6D49647D5D3A20436F756C64206E6F74207061727365207A6F6F6D2072616E6765205B247B72616E67657D5D60293B0D0A20202020202072657475726E205B302C2032345D3B0D0A202020207D0D0A20207D3B0D0A0D0A2020636F6E7374205B6D696E5A';
wwv_flow_imp.g_varchar2_table(20) := '6F6F6D2C206D61785A6F6F6D5D203D2070617273655A6F6F6D52616E6765287A6F6F6D52616E6765203F3F2027302D31303027293B0D0A20206C6574206D61726B65727356697369626C65203D20747275653B0D0A0D0A20202F2F20412070726F6D6973';
wwv_flow_imp.g_varchar2_table(21) := '652074686174207265736F6C76657320746F20746865206173736F636961746564204D617020526567696F6E206F6E636520697420697320696E697469616C697A65642E0D0A2020636F6E73742070656E64696E674D6170203D206E65772050726F6D69';
wwv_flow_imp.g_varchar2_table(22) := '736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020636F6E737420726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0D0A2020202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(23) := '2020617065782E64656275672E6572726F7228276D6170626974735F68746D6C6D61726B65722027202B206974656D4964202B2027203A20526567696F6E205B27202B20726567696F6E4964202B20275D2069732068696464656E206F72206D69737369';
wwv_flow_imp.g_varchar2_table(24) := '6E672E27293B0D0A20202020202072656A65637428293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20202020726567696F6E2E656C656D656E742E6F6E28277370617469616C6D6170696E697469616C697A6564272C202829203D';
wwv_flow_imp.g_varchar2_table(25) := '3E207B0D0A202020202020636F6E7374206D6170203D20617065782E726567696F6E28726567696F6E4964292E63616C6C28276765744D61704F626A65637427293B0D0A2020202020207265736F6C7665286D6170293B0D0A202020207D293B0D0A2020';
wwv_flow_imp.g_varchar2_table(26) := '7D292E7468656E28286D617029203D3E207B0D0A202020206D61702E6F6E28277A6F6F6D272C20286576656E7429203D3E207B0D0A202020202020636F6E7374206D61726B6572734E6F7756697369626C65203D2073686F756C644D61726B6572734265';
wwv_flow_imp.g_varchar2_table(27) := '56697369626C65286D6170293B0D0A202020202020696620286D61726B6572734E6F7756697369626C6520213D3D206D61726B65727356697369626C6529207B0D0A2020202020202020666F722028636F6E7374206D61726B6572206F66206D61726B65';
wwv_flow_imp.g_varchar2_table(28) := '727329207B0D0A20202020202020202020696620286D61726B6572734E6F7756697369626C6529207B0D0A2020202020202020202020206D61726B65722E616464546F286D6170293B0D0A202020202020202020207D20656C7365207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(29) := '202020202020206D61726B65722E72656D6F766528293B0D0A202020202020202020207D0D0A20202020202020207D0D0A20202020202020206D61726B65727356697369626C65203D206D61726B6572734E6F7756697369626C653B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(30) := '7D0D0A202020207D293B0D0A0D0A20202020636F6E7374206C6567656E64203D202428272327202B20726567696F6E4964202B20275F6C6567656E6427293B0D0A202020202428603C64697620636C6173733D22612D4D6170526567696F6E2D6C656765';
wwv_flow_imp.g_varchar2_table(31) := '6E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E60290D0A2020202020202E617070656E64280D0A20202020202020202428603C696E70757420747970653D22636865636B626F782220636C617373';
wwv_flow_imp.g_varchar2_table(32) := '3D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22223E60290D0A202020202020202020202E70726F70287B0D0A202020202020202020202020276964273A206974656D496420';
wwv_flow_imp.g_varchar2_table(33) := '2B20275F6C6567656E645F656E747279272C0D0A20202020202020202020202027636865636B6564273A206C61796572735669736962696C69747920213D3D20276E6F6E65272C0D0A202020202020202020207D290D0A202020202020202020202E6373';
wwv_flow_imp.g_varchar2_table(34) := '73287B20272D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F72273A206C6567656E64436F6C6F72207D292C0D0A20202020202020202428603C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162';
wwv_flow_imp.g_varchar2_table(35) := '656C223E60290D0A202020202020202020202E70726F70287B0D0A202020202020202020202020276964273A206974656D4964202B20275F6C6567656E645F656E7472795F6C6162656C272C0D0A20202020202020202020202027666F72273A20697465';
wwv_flow_imp.g_varchar2_table(36) := '6D4964202B20275F6C6567656E645F656E747279270D0A202020202020202020207D290D0A202020202020202020202E617070656E64280D0A202020202020202020202020287469746C65207C7C206974656D4964292C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(37) := '202428603C7370616E20636C6173733D2266612066612D636972636C652D372D382066612D616E696D2D7370696E22207374796C653D22646973706C61793A206E6F6E653B206D617267696E2D6C6566743A202E35656D3B223E60292E70726F70282769';
wwv_flow_imp.g_varchar2_table(38) := '64272C206974656D4964202B20275F6C6567656E645F656E7472795F73746174757327290D0A20202020202020202020290D0A202020202020290D0A2020202020202E617070656E64546F286C6567656E64293B0D0A0D0A2020202072657475726E206D';
wwv_flow_imp.g_varchar2_table(39) := '61703B0D0A20207D293B0D0A0D0A20202F2F205768657468657220746865206974656D20686173206C6F6164656420666F72207468652066697273742074696D652E205468697320656E737572657320736F6D652066697273742D74696D652073657475';
wwv_flow_imp.g_varchar2_table(40) := '70206973206F6E6C792072756E206F6E63652E0D0A20206C65742061646465644C61796572203D2066616C73653B0D0A0D0A20202F2F20412047656F4A534F4E206F626A65637420636F6E7461696E696E672074686520666561747572657320746F2064';
wwv_flow_imp.g_varchar2_table(41) := '6973706C6179206D61726B65727320666F722E0D0A20206C6574207175657279526573756C743B0D0A20202F2F20546865204D61704C69627265206D61726B6572206F626A656374730D0A2020636F6E7374206D61726B657273203D205B5D3B0D0A2020';
wwv_flow_imp.g_varchar2_table(42) := '2F2F2041206C697374206F662066756E6374696F6E7320746F2063616C6C207768656E2064657374726F79696E6720746865206D61726B6572730D0A2020636F6E7374206D61726B657244657374726F79203D205B5D3B0D0A0D0A2020636F6E73742073';
wwv_flow_imp.g_varchar2_table(43) := '686F756C644D61726B657273426556697369626C65203D20286D617029203D3E206C61796572735669736962696C69747920213D3D20276E6F6E6527202626206D61702E6765745A6F6F6D2829203E3D206D696E5A6F6F6D202626206D61702E6765745A';
wwv_flow_imp.g_varchar2_table(44) := '6F6F6D2829203C3D206D61785A6F6F6D3B0D0A0D0A2020636F6E73742072656372656174654D61726B657273203D206173796E63202829203D3E207B0D0A20202020666F722028636F6E7374206D61726B6572206F66206D61726B65727329207B0D0A20';
wwv_flow_imp.g_varchar2_table(45) := '20202020206D61726B65722E72656D6F766528293B0D0A202020207D0D0A202020206D61726B6572732E6C656E677468203D20303B0D0A20202020666F722028636F6E73742064657374726F79206F66206D61726B657244657374726F7929207B0D0A20';
wwv_flow_imp.g_varchar2_table(46) := '202020202064657374726F7928293B0D0A202020207D0D0A202020206D61726B657244657374726F792E6C656E677468203D20303B0D0A0D0A20202020636F6E7374206D6170203D2061776169742070656E64696E674D61703B0D0A0D0A20202020636F';
wwv_flow_imp.g_varchar2_table(47) := '6E7374206D616B6556697369626C65203D2073686F756C644D61726B657273426556697369626C65286D6170293B0D0A20202020666F722028636F6E73742066656174757265206F66207175657279526573756C742E666561747572657329207B0D0A20';
wwv_flow_imp.g_varchar2_table(48) := '202020202069662028666561747572652E67656F6D657472792E7479706520213D3D2022506F696E742229207B0D0A2020202020202020617065782E64656275672E6572726F7228274D6170626974732048544D4C204D61726B65723A20466561747572';
wwv_flow_imp.g_varchar2_table(49) := '652067656F6D65747279206973206E6F74206120706F696E7427293B0D0A2020202020202020636F6E74696E75653B0D0A2020202020207D0D0A0D0A202020202020636F6E73742070726F7073203D207B0D0A20202020202020202E2E2E666561747572';
wwv_flow_imp.g_varchar2_table(50) := '652E70726F706572746965732C0D0A2020202020202020274D4150424954535F53454C4543544544273A202873656C656374656446656174757265732026262028747970656F6620666561747572652E696420213D3D2027756E646566696E6564272920';
wwv_flow_imp.g_varchar2_table(51) := '262620666561747572652E696420213D3D206E756C6C2026262073656C656374656446656174757265732E68617328666561747572652E69642E746F537472696E6728292929203F20277472756527203A2027270D0A2020202020207D3B0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(52) := '202020202F2F204170706C79207468652074656D706C61746520616E642063726561746520616E2048544D4C20656C656D656E740D0A202020202020636F6E737420656C656D656E74203D202428273C6469763E27292E68746D6C280D0A202020202020';
wwv_flow_imp.g_varchar2_table(53) := '2020617065782E7574696C2E6170706C7954656D706C6174652868746D6C436F6E74656E742C207B0D0A20202020202020202020706C616365686F6C646572733A2070726F70732C0D0A20202020202020207D290D0A202020202020293B0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(54) := '2020202069662028636C69636B61626C6529207B0D0A2020202020202020656C656D656E742E6373732827637572736F72272C2027706F696E74657227293B0D0A2020202020207D0D0A202020202020656C656D656E742E6F6E2827636C69636B272C20';
wwv_flow_imp.g_varchar2_table(55) := '2829203D3E207B0D0A2020202020202020617065782E6576656E742E7472696767657228272327202B206974656D49642C2027636C69636B272C207B20666561747572652C206973546F706D6F73744C617965723A2074727565207D293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(56) := '20207D293B0D0A0D0A202020202020636F6E737420616E63686F72203D20747970656F6620636F6E6669672E6D61726B6572416E63686F72203D3D3D2027737472696E67270D0A20202020202020203F20636F6E6669672E6D61726B6572416E63686F72';
wwv_flow_imp.g_varchar2_table(57) := '0D0A20202020202020203A20747970656F6620636F6E6669672E6D61726B6572416E63686F72203D3D3D202766756E6374696F6E270D0A20202020202020203F20636F6E6669672E6D61726B6572416E63686F722870726F7073290D0A20202020202020';
wwv_flow_imp.g_varchar2_table(58) := '203A20756E646566696E65643B0D0A0D0A2020202020202F2F2043726561746520746865204D61704C69627265206D61726B65720D0A202020202020636F6E7374206D61726B6572203D206E6577206D61706C69627265676C2E4D61726B6572287B0D0A';
wwv_flow_imp.g_varchar2_table(59) := '2020202020202020656C656D656E743A20656C656D656E742E6765742830292C0D0A2020202020202020616E63686F722C0D0A2020202020207D290D0A20202020202020202E7365744C6E674C617428666561747572652E67656F6D657472792E636F6F';
wwv_flow_imp.g_varchar2_table(60) := '7264696E61746573293B0D0A0D0A2020202020202F2F2049662061206D61726B6572496E69742066756E6374696F6E207761732070726F76696465642C2063616C6C206974207769746820746865206D61726B6572206F626A6563740D0A202020202020';
wwv_flow_imp.g_varchar2_table(61) := '2F2F20616E64207468652070726F706572746965730D0A20202020202069662028747970656F6620636F6E6669672E6D61726B6572496E6974203D3D3D202266756E6374696F6E2229207B0D0A2020202020202020636F6E73742064657374726F79203D';
wwv_flow_imp.g_varchar2_table(62) := '20636F6E6669672E6D61726B6572496E6974286D61726B65722C2070726F7073293B0D0A202020202020202069662028747970656F662064657374726F79203D3D3D202266756E6374696F6E2229207B0D0A202020202020202020206D61726B65724465';
wwv_flow_imp.g_varchar2_table(63) := '7374726F792E707573682864657374726F79293B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A202020202020696620286D616B6556697369626C6529207B0D0A20202020202020206D61726B65722E616464546F286D6170293B0D0A2020';
wwv_flow_imp.g_varchar2_table(64) := '202020207D0D0A2020202020206D61726B6572732E70757368286D61726B6572293B0D0A202020207D0D0A20207D3B0D0A0D0A20202F2F20285265296C6F616420746865206461746120616E6420726563726561746520616C6C20746865206D61726B65';
wwv_flow_imp.g_varchar2_table(65) := '72730D0A20206173796E632066756E6374696F6E206C6F6164446174612829207B0D0A202020202428272327202B206974656D4964202B20275F6C6567656E645F656E7472795F73746174757327292E6373732827646973706C6179272C2027696E6C69';
wwv_flow_imp.g_varchar2_table(66) := '6E6527293B0D0A20202020617065782E6576656E742E7472696767657228272327202B206974656D49642C20276C6F61645F737461727427293B0D0A20202020747279207B0D0A20202020202069662028736F7572636554797065203D3D3D20276A6176';
wwv_flow_imp.g_varchar2_table(67) := '617363726970742729207B0D0A202020202020202069662028747970656F6620636F6E6669673F2E64617461536F75726365203D3D3D202766756E6374696F6E2729207B0D0A202020202020202020207175657279526573756C74203D20617761697420';
wwv_flow_imp.g_varchar2_table(68) := '636F6E6669672E64617461536F7572636528293B0D0A20202020202020207D20656C73652069662028747970656F6620636F6E6669673F2E64617461536F75726365203D3D3D20276F626A6563742729207B0D0A20202020202020202020717565727952';
wwv_flow_imp.g_varchar2_table(69) := '6573756C74203D20636F6E6669672E64617461536F757263653B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020617065782E64656275672E6572726F722827636F6E6669672E64617461536F7572636520776173206E6F7420';
wwv_flow_imp.g_varchar2_table(70) := '70726F766964656427290D0A20202020202020207D0D0A2020202020207D20656C7365207B0D0A202020202020207175657279526573756C74203D20617761697420617065782E7365727665722E706C7567696E28616A61784964656E7469666965722C';
wwv_flow_imp.g_varchar2_table(71) := '207B706167654974656D733A207375626D69744974656D73203F207375626D69744974656D732E73706C697428222C22292E66696C7465722878203D3E2021217829203A20756E646566696E65647D293B0D0A2020202020207D0D0A202020207D206669';
wwv_flow_imp.g_varchar2_table(72) := '6E616C6C79207B0D0A202020202020617065782E6576656E742E7472696767657228272327202B206974656D49642C20276C6F61645F656E6427293B0D0A2020202020202428272327202B206974656D4964202B20275F6C6567656E645F656E7472795F';
wwv_flow_imp.g_varchar2_table(73) := '73746174757327292E6373732827646973706C6179272C20276E6F6E6527293B0D0A202020207D0D0A0D0A2020202061776169742072656372656174654D61726B65727328293B0D0A0D0A202020202F2F2046697273742D74696D652073657475700D0A';
wwv_flow_imp.g_varchar2_table(74) := '20202020696620282161646465644C6179657229207B0D0A20202020202061646465644C61796572203D20747275653B0D0A0D0A202020202020636F6E7374206D6170203D2061776169742070656E64696E674D61703B0D0A0D0A2020202020202F2F20';
wwv_flow_imp.g_varchar2_table(75) := '536574207468652066756E6374696F6E20746F2073686F772F6869646520746865206D61726B6572730D0A2020202020207365744C61796572735669736962696C697479203D20287669736962696C69747929203D3E207B0D0A20202020202020206170';
wwv_flow_imp.g_varchar2_table(76) := '65782E73746F726167652E736574436F6F6B696528274D6170626974735F48544D4C4D61726B65724C617965725F27202B206974656D4964202B20275F27202B202476282770496E7374616E636527292C207669736962696C697479293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(77) := '202020206C61796572735669736962696C697479203D207669736962696C6974793B0D0A0D0A2020202020202020636F6E73742076697369626C65203D2073686F756C644D61726B657273426556697369626C65286D6170293B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(78) := '666F722028636F6E7374206D61726B6572206F66206D61726B65727329207B0D0A202020202020202020206966202876697369626C6529207B0D0A2020202020202020202020206D61726B65722E616464546F286D6170293B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(79) := '207D20656C7365207B0D0A2020202020202020202020206D61726B65722E72656D6F766528293B0D0A202020202020202020207D0D0A20202020202020207D0D0A0D0A2020202020202020617065782E6A517565727928272327202B206974656D496420';
wwv_flow_imp.g_varchar2_table(80) := '2B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C207669736962696C697479203D3D3D202776697369626C6527293B0D0A0D0A2020202020202020617065782E6576656E742E7472696767657228272327202B206974';
wwv_flow_imp.g_varchar2_table(81) := '656D49642C20277669736962696C6974795F746F67676C6564272C207B0D0A2020202020202020202076697369626C653A207669736962696C697479203D3D3D202776697369626C65272C0D0A20202020202020207D293B0D0A2020202020207D0D0A0D';
wwv_flow_imp.g_varchar2_table(82) := '0A2020202020202F2F204D616B65207375726520746865206D61726B6572207669736962696C69747920697320636F72726563746C7920736574206261736564206F6E207468652073746F7265642076616C756520696E2074686520636F6F6B69650D0A';
wwv_flow_imp.g_varchar2_table(83) := '202020202020696620286C61796572735669736962696C697479203D3D20276E6F6E652729207B0D0A20202020202020207365744C61796572735669736962696C69747928276E6F6E6527293B0D0A2020202020202020617065782E6A51756572792827';
wwv_flow_imp.g_varchar2_table(84) := '2327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A2020202020207D20656C7365207B0D0A20202020202020207365744C61796572735669736962696C69747928';
wwv_flow_imp.g_varchar2_table(85) := '2776697369626C6527293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2074727565293B0D0A2020202020207D0D0A0D0A';
wwv_flow_imp.g_varchar2_table(86) := '2020202020202F2F20557064617465206D61726B6572207669736962696C697479207768656E20746865206C6567656E6420636865636B626F7820697320636C69636B65640D0A202020202020617065782E6A517565727928272327202B206974656D49';
wwv_flow_imp.g_varchar2_table(87) := '64202B20275F6C6567656E645F656E74727927292E6368616E67652866756E6374696F6E2865297B0D0A20202020202020206C6574206362203D20617065782E6A51756572792874686973293B0D0A20202020202020207365744C617965727356697369';
wwv_flow_imp.g_varchar2_table(88) := '62696C6974792863622E697328273A636865636B65642729203F202776697369626C6527203A20276E6F6E6527293B0D0A2020202020207D293B0D0A0D0A2020202020202F2F2043616C6C20616E792066756E6374696F6E732074686174206172652077';
wwv_flow_imp.g_varchar2_table(89) := '616974696E6720666F7220746865206974656D20746F206C6F61642E20546869732077696C6C2063617573650D0A2020202020202F2F20616E792063616C6C7320746F206D6170626974735F68746D6C6D61726B65725F776169745F666F725F696E6974';
wwv_flow_imp.g_varchar2_table(90) := '20746F2072657475726E2E0D0A202020202020666F722028636F6E73742066756E63206F662077616974466F724C6F616429207B0D0A202020202020202066756E6328293B0D0A2020202020207D0D0A20202020202077616974466F724C6F6164203D20';
wwv_flow_imp.g_varchar2_table(91) := '6E756C6C3B0D0A202020207D0D0A20207D3B0D0A0D0A20202F2F2053746172742074686520696E697469616C2064617461206C6F61642E204E6F7465207468617420746F207370656564207468696E67732075702C207765207374617274207468697320';
wwv_flow_imp.g_varchar2_table(92) := '696D6D6564696174656C7920616E640D0A20202F2F206F6E6C79207761697420666F72207370617469616C6D6170696E697469616C697A6564206A757374206265666F726520616464696E6720746865206D61726B6572732E0D0A20206C6F6164446174';
wwv_flow_imp.g_varchar2_table(93) := '6128293B0D0A0D0A20206C657420666972737452656672657368203D20747275653B0D0A2020617065782E6A51756572792827626F647927292E6F6E2827617065786265666F726572656672657368272C206173796E632028657629203D3E207B0D0A20';
wwv_flow_imp.g_varchar2_table(94) := '2020206966202865762E746172676574203D3D3D20617065782E726567696F6E28726567696F6E4964292E656C656D656E745B305D29207B0D0A2020202020202F2A20536B69702074686520666972737420617065786265666F72657265667265736820';
wwv_flow_imp.g_varchar2_table(95) := '6576656E742C2073696E6365207468617420636F72726573706F6E647320746F207468652070616765206C6F6164696E672C0D0A20202020202020202062757420776520616C72656164792063616C6C6564206C6F61644461746128292061626F766520';
wwv_flow_imp.g_varchar2_table(96) := '776974686F75742077616974696E6720666F7220746865206D617020746F206C6F61642E202A2F0D0A202020202020696620282166697273745265667265736829207B0D0A20202020202020206177616974206C6F61644461746128293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(97) := '20207D20656C7365207B0D0A2020202020202020666972737452656672657368203D2066616C73653B0D0A2020202020207D0D0A202020207D0D0A20207D293B0D0A0D0A2020617065782E6974656D2E637265617465280D0A202020206974656D49642C';
wwv_flow_imp.g_varchar2_table(98) := '0D0A202020207B0D0A202020202020726566726573683A206173796E63202829203D3E207B0D0A20202020202020206177616974206C6F61644461746128293B0D0A2020202020207D2C0D0A20202020202073686F773A202829203D3E207B0D0A202020';
wwv_flow_imp.g_varchar2_table(99) := '20202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020207D2C0D0A202020202020686964653A202829203D3E207B0D0A20202020202020207365744C61796572735669736962696C69747928276E6F';
wwv_flow_imp.g_varchar2_table(100) := '6E6527293B0D0A2020202020207D2C0D0A202020202020697356697369626C653A202829203D3E207B0D0A202020202020202072657475726E206C61796572735669736962696C69747920213D3D20276E6F6E65273B0D0A2020202020207D2C0D0A2020';
wwv_flow_imp.g_varchar2_table(101) := '202020202F2A2053657420746865206C697374206F66206665617475726573207468617420686176652061202273656C65637465642220617070656172616E63652E20606665617475726573602069732061206C6973740D0A2020202020202020206F66';
wwv_flow_imp.g_varchar2_table(102) := '2066656174757265204944732E202A2F0D0A20202020202073657453656C656374656446656174757265733A202866656174757265732C20616374696F6E29203D3E207B0D0A202020202020202069662028216964436F6C756D6E29207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(103) := '2020202020207468726F77206E6577204572726F722860247B6974656D49647D3A20416E20494420636F6C756D6E20697320726571756972656420696E206F7264657220746F2073656C6563742066656174757265732E60293B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(104) := '7D0D0A0D0A20202020202020206665617475726573203D206665617475726573203F3F205B5D3B0D0A20202020202020207377697463682028616374696F6E29207B0D0A20202020202020202020636173652027736574273A0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(105) := '20202073656C65637465644665617475726573203D206E6577205365742866656174757265732E6D61702866203D3E20662E746F537472696E67282929293B0D0A202020202020202020202020627265616B3B0D0A202020202020202020206361736520';
wwv_flow_imp.g_varchar2_table(106) := '27616464273A0D0A20202020202020202020202073656C65637465644665617475726573203F3F3D206E65772053657428293B0D0A202020202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(107) := '202020202020202073656C656374656446656174757265732E61646428662E746F537472696E672829293B0D0A2020202020202020202020207D0D0A202020202020202020202020627265616B3B0D0A2020202020202020202063617365202772656D6F';
wwv_flow_imp.g_varchar2_table(108) := '7665273A0D0A2020202020202020202020206966202873656C6563746564466561747572657329207B0D0A2020202020202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(109) := '202073656C656374656446656174757265732E64656C65746528662E746F537472696E672829293B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D0D0A202020202020202020202020627265616B3B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(110) := '20207D0D0A202020202020202072656372656174654D61726B65727328293B0D0A2020202020207D2C0D0A2020202020202F2A2053656C6563747320616C6C2066656174757265732063757272656E746C7920696E20746865206C617965722074686174';
wwv_flow_imp.g_varchar2_table(111) := '206861766520616E2049442E202A2F0D0A20202020202073656C656374416C6C46656174757265733A202829203D3E207B0D0A202020202020202069662028216964436F6C756D6E29207B0D0A202020202020202020207468726F77206E657720457272';
wwv_flow_imp.g_varchar2_table(112) := '6F722860247B6974656D49647D3A20416E20494420636F6C756D6E20697320726571756972656420696E206F7264657220746F2073656C6563742066656174757265732E60293B0D0A20202020202020207D0D0A20202020202020206966202871756572';
wwv_flow_imp.g_varchar2_table(113) := '79526573756C7429207B0D0A2020202020202020202073656C65637465644665617475726573203D206E657720536574287175657279526573756C742E66656174757265732E6D61702866203D3E20662E69643F2E746F537472696E672829292E66696C';
wwv_flow_imp.g_varchar2_table(114) := '7465722866203D3E2021216629293B0D0A2020202020202020202072656372656174654D61726B65727328293B0D0A20202020202020207D0D0A2020202020207D2C0D0A202020202020636C65617253656C656374696F6E3A202829203D3E207B0D0A20';
wwv_flow_imp.g_varchar2_table(115) := '2020202020202073656C65637465644665617475726573203D206E756C6C3B0D0A202020202020202072656372656174654D61726B65727328293B0D0A2020202020207D2C0D0A202020202020676574536F75726365446174613A202829203D3E207B0D';
wwv_flow_imp.g_varchar2_table(116) := '0A202020202020202072657475726E207175657279526573756C743B0D0A2020202020207D2C0D0A20202020202077616974466F724C6F61643A202829203D3E207B0D0A202020202020202072657475726E206E65772050726F6D69736528287265736F';
wwv_flow_imp.g_varchar2_table(117) := '6C76652C2072656A65637429203D3E207B0D0A202020202020202020206966202877616974466F724C6F6164203D3D3D206E756C6C29207B0D0A2020202020202020202020207265736F6C766528293B0D0A202020202020202020207D20656C7365207B';
wwv_flow_imp.g_varchar2_table(118) := '0D0A20202020202020202020202077616974466F724C6F61642E70757368287265736F6C7665293B0D0A202020202020202020207D0D0A20202020202020207D293B0D0A2020202020207D2C0D0A2020202020206765744D61703A206173796E63202829';
wwv_flow_imp.g_varchar2_table(119) := '203D3E2061776169742070656E64696E674D61702C0D0A202020207D0D0A2020293B0D0A0D0A2020696620286974656D496420696E204D4150424954535F48544D4C5F4D41524B45525F57414954494E4729207B0D0A20202020636F6E7374206974656D';
wwv_flow_imp.g_varchar2_table(120) := '203D20617065782E6974656D286974656D4964293B0D0A202020204D4150424954535F48544D4C5F4D41524B45525F57414954494E475B6974656D49645D2E666F724561636828287829203D3E2078286974656D29293B0D0A20207D0D0A20204D415042';
wwv_flow_imp.g_varchar2_table(121) := '4954535F48544D4C5F4D41524B45525F57414954494E475B6974656D49645D203D206E756C6C3B0D0A7D0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43419734442713278)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_file_name=>'mapbits-htmlmarker.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F48544D4C5F4D41524B45525F57414954494E473D7B7D3B66756E6374696F6E206D6170626974735F68746D6C6D61726B65725F776169745F666F725F696E69742865297B72657475726E206E65772050726F6D697365';
wwv_flow_imp.g_varchar2_table(2) := '282828742C6E293D3E7B6520696E204D4150424954535F48544D4C5F4D41524B45525F57414954494E477C7C284D4150424954535F48544D4C5F4D41524B45525F57414954494E475B655D3D5B5D292C6E756C6C213D3D4D4150424954535F48544D4C5F';
wwv_flow_imp.g_varchar2_table(3) := '4D41524B45525F57414954494E475B655D3F4D4150424954535F48544D4C5F4D41524B45525F57414954494E475B655D2E707573682828653D3E7B742865297D29293A7428617065782E6974656D286529297D29297D66756E6374696F6E206D61706269';
wwv_flow_imp.g_varchar2_table(4) := '74735F68746D6C6D61726B6572287B6974656D49643A652C616A61784964656E7469666965723A742C726567696F6E49643A6E2C73657175656E63654E756D6265723A722C7469746C653A6F2C7375626D69744974656D733A612C68746D6C436F6E7465';
wwv_flow_imp.g_varchar2_table(5) := '6E743A692C696E6974436F64653A732C736F75726365547970653A6C2C6C6567656E64436F6C6F723A632C636C69636B61626C653A702C7A6F6F6D52616E67653A642C6964436F6C756D6E3A677D297B696628216E2972657475726E20766F6964206170';
wwv_flow_imp.g_varchar2_table(6) := '65782E64656275672E6572726F7228226D6170626974735F68746D6C6D61726B657220222B652B22203A204974656D206973206E6F7420696E206120726567696F6E2E22293B6C657420753D5B5D3B636F6E7374206D3D733F7328293A7B7D3B6C657420';
wwv_flow_imp.g_varchar2_table(7) := '5F3D617065782E73746F726167652E676574436F6F6B696528224D6170626974735F48544D4C4D61726B65725F222B652B225F222B2476282270496E7374616E63652229292C663D6E756C6C2C4D3D653D3E7B5F3D657D3B636F6E73745B682C795D3D28';
wwv_flow_imp.g_varchar2_table(8) := '743D3E7B6C6574206E3D742E6D61746368282F5E285B302D395D2B293F5B2D2C3A5D285B302D395D2B293F242F293B6966286E297B72657475726E5B4D6174682E6D617828302C4D6174682E6D696E287061727365496E74286E5B315D3F3F223022292C';
wwv_flow_imp.g_varchar2_table(9) := '323429292C4D6174682E6D617828302C4D6174682E6D696E287061727365496E74286E5B325D3F3F22323422292C323429295D7D72657475726E20636F6E736F6C652E7761726E2860436F6E66696775726174696F6E204572726F723A204D6170626974';
wwv_flow_imp.g_varchar2_table(10) := '732048544D4C204D61726B6572204C61796572205B247B657D5D3A20436F756C64206E6F74207061727365207A6F6F6D2072616E6765205B247B747D5D60292C5B302C32345D7D2928643F3F22302D31303022293B6C657420493D21303B636F6E737420';
wwv_flow_imp.g_varchar2_table(11) := '543D6E65772050726F6D697365282828742C72293D3E7B636F6E7374206F3D617065782E726567696F6E286E293B6966286E756C6C3D3D6F2972657475726E20617065782E64656275672E6572726F7228226D6170626974735F68746D6C6D61726B6572';
wwv_flow_imp.g_varchar2_table(12) := '20222B652B22203A20526567696F6E205B222B6E2B225D2069732068696464656E206F72206D697373696E672E22292C766F6964207228293B6F2E656C656D656E742E6F6E28227370617469616C6D6170696E697469616C697A6564222C2828293D3E7B';
wwv_flow_imp.g_varchar2_table(13) := '636F6E737420653D617065782E726567696F6E286E292E63616C6C28226765744D61704F626A65637422293B742865297D29297D29292E7468656E2828743D3E7B742E6F6E28227A6F6F6D222C28653D3E7B636F6E7374206E3D762874293B6966286E21';
wwv_flow_imp.g_varchar2_table(14) := '3D3D49297B666F7228636F6E73742065206F66206B296E3F652E616464546F2874293A652E72656D6F766528293B493D6E7D7D29293B636F6E737420723D24282223222B6E2B225F6C6567656E6422293B72657475726E202428273C64697620636C6173';
wwv_flow_imp.g_varchar2_table(15) := '733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E27292E617070656E64282428273C696E70757420747970653D22636865636B626F782220636C6173';
wwv_flow_imp.g_varchar2_table(16) := '733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22223E27292E70726F70287B69643A652B225F6C6567656E645F656E747279222C636865636B65643A226E6F6E6522213D3D';
wwv_flow_imp.g_varchar2_table(17) := '5F7D292E637373287B222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F72223A637D292C2428273C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C223E27292E70726F70287B69643A65';
wwv_flow_imp.g_varchar2_table(18) := '2B225F6C6567656E645F656E7472795F6C6162656C222C666F723A652B225F6C6567656E645F656E747279227D292E617070656E64286F7C7C652C2428273C7370616E20636C6173733D2266612066612D636972636C652D372D382066612D616E696D2D';
wwv_flow_imp.g_varchar2_table(19) := '7370696E22207374796C653D22646973706C61793A206E6F6E653B206D617267696E2D6C6566743A202E35656D3B223E27292E70726F7028226964222C652B225F6C6567656E645F656E7472795F737461747573222929292E617070656E64546F287229';
wwv_flow_imp.g_varchar2_table(20) := '2C747D29293B6C657420622C413D21313B636F6E7374206B3D5B5D2C783D5B5D2C763D653D3E226E6F6E6522213D3D5F2626652E6765745A6F6F6D28293E3D682626652E6765745A6F6F6D28293C3D792C533D6173796E6328293D3E7B666F7228636F6E';
wwv_flow_imp.g_varchar2_table(21) := '73742065206F66206B29652E72656D6F766528293B6B2E6C656E6774683D303B666F7228636F6E73742065206F662078296528293B782E6C656E6774683D303B636F6E737420743D617761697420542C6E3D762874293B666F7228636F6E73742072206F';
wwv_flow_imp.g_varchar2_table(22) := '6620622E6665617475726573297B69662822506F696E7422213D3D722E67656F6D657472792E74797065297B617065782E64656275672E6572726F7228224D6170626974732048544D4C204D61726B65723A20466561747572652067656F6D6574727920';
wwv_flow_imp.g_varchar2_table(23) := '6973206E6F74206120706F696E7422293B636F6E74696E75657D636F6E7374206F3D7B2E2E2E722E70726F706572746965732C4D4150424954535F53454C45435445443A662626766F69642030213D3D722E696426266E756C6C213D3D722E6964262666';
wwv_flow_imp.g_varchar2_table(24) := '2E68617328722E69642E746F537472696E672829293F2274727565223A22227D2C613D2428223C6469763E22292E68746D6C28617065782E7574696C2E6170706C7954656D706C61746528692C7B706C616365686F6C646572733A6F7D29293B70262661';
wwv_flow_imp.g_varchar2_table(25) := '2E6373732822637572736F72222C22706F696E74657222292C612E6F6E2822636C69636B222C2828293D3E7B617065782E6576656E742E74726967676572282223222B652C22636C69636B222C7B666561747572653A722C6973546F706D6F73744C6179';
wwv_flow_imp.g_varchar2_table(26) := '65723A21307D297D29293B636F6E737420733D22737472696E67223D3D747970656F66206D2E6D61726B6572416E63686F723F6D2E6D61726B6572416E63686F723A2266756E6374696F6E223D3D747970656F66206D2E6D61726B6572416E63686F723F';
wwv_flow_imp.g_varchar2_table(27) := '6D2E6D61726B6572416E63686F72286F293A766F696420302C6C3D6E6577206D61706C69627265676C2E4D61726B6572287B656C656D656E743A612E6765742830292C616E63686F723A737D292E7365744C6E674C617428722E67656F6D657472792E63';
wwv_flow_imp.g_varchar2_table(28) := '6F6F7264696E61746573293B6966282266756E6374696F6E223D3D747970656F66206D2E6D61726B6572496E6974297B636F6E737420653D6D2E6D61726B6572496E6974286C2C6F293B2266756E6374696F6E223D3D747970656F6620652626782E7075';
wwv_flow_imp.g_varchar2_table(29) := '73682865297D6E26266C2E616464546F2874292C6B2E70757368286C297D7D3B6173796E632066756E6374696F6E207728297B24282223222B652B225F6C6567656E645F656E7472795F73746174757322292E6373732822646973706C6179222C22696E';
wwv_flow_imp.g_varchar2_table(30) := '6C696E6522292C617065782E6576656E742E74726967676572282223222B652C226C6F61645F737461727422293B7472797B226A617661736372697074223D3D3D6C3F2266756E6374696F6E223D3D747970656F66206D3F2E64617461536F757263653F';
wwv_flow_imp.g_varchar2_table(31) := '623D6177616974206D2E64617461536F7572636528293A226F626A656374223D3D747970656F66206D3F2E64617461536F757263653F623D6D2E64617461536F757263653A617065782E64656275672E6572726F722822636F6E6669672E64617461536F';
wwv_flow_imp.g_varchar2_table(32) := '7572636520776173206E6F742070726F766964656422293A623D617761697420617065782E7365727665722E706C7567696E28742C7B706167654974656D733A613F612E73706C697428222C22292E66696C7465722828653D3E21216529293A766F6964';
wwv_flow_imp.g_varchar2_table(33) := '20307D297D66696E616C6C797B617065782E6576656E742E74726967676572282223222B652C226C6F61645F656E6422292C24282223222B652B225F6C6567656E645F656E7472795F73746174757322292E6373732822646973706C6179222C226E6F6E';
wwv_flow_imp.g_varchar2_table(34) := '6522297D6966286177616974205328292C2141297B413D21303B636F6E737420743D617761697420543B4D3D6E3D3E7B617065782E73746F726167652E736574436F6F6B696528224D6170626974735F48544D4C4D61726B65724C617965725F222B652B';
wwv_flow_imp.g_varchar2_table(35) := '225F222B2476282270496E7374616E636522292C6E292C5F3D6E3B636F6E737420723D762874293B666F7228636F6E73742065206F66206B29723F652E616464546F2874293A652E72656D6F766528293B617065782E6A5175657279282223222B652B22';
wwv_flow_imp.g_varchar2_table(36) := '5F6C6567656E645F656E74727922292E70726F702822636865636B6564222C2276697369626C65223D3D3D6E292C617065782E6576656E742E74726967676572282223222B652C227669736962696C6974795F746F67676C6564222C7B76697369626C65';
wwv_flow_imp.g_varchar2_table(37) := '3A2276697369626C65223D3D3D6E7D297D2C226E6F6E65223D3D5F3F284D28226E6F6E6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213129293A284D28227669';
wwv_flow_imp.g_varchar2_table(38) := '7369626C6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213029292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E6368';
wwv_flow_imp.g_varchar2_table(39) := '616E6765282866756E6374696F6E2865297B6C657420743D617065782E6A51756572792874686973293B4D28742E697328223A636865636B656422293F2276697369626C65223A226E6F6E6522297D29293B666F7228636F6E73742065206F6620752965';
wwv_flow_imp.g_varchar2_table(40) := '28293B753D6E756C6C7D7D7728293B6C657420523D21303B696628617065782E6A51756572792822626F647922292E6F6E2822617065786265666F726572656672657368222C286173796E6320653D3E7B652E7461726765743D3D3D617065782E726567';
wwv_flow_imp.g_varchar2_table(41) := '696F6E286E292E656C656D656E745B305D262628523F523D21313A617761697420772829297D29292C617065782E6974656D2E63726561746528652C7B726566726573683A6173796E6328293D3E7B6177616974207728297D2C73686F773A28293D3E7B';
wwv_flow_imp.g_varchar2_table(42) := '4D282276697369626C6522297D2C686964653A28293D3E7B4D28226E6F6E6522297D2C697356697369626C653A28293D3E226E6F6E6522213D3D5F2C73657453656C656374656446656174757265733A28742C6E293D3E7B6966282167297468726F7720';
wwv_flow_imp.g_varchar2_table(43) := '6E6577204572726F722860247B657D3A20416E20494420636F6C756D6E20697320726571756972656420696E206F7264657220746F2073656C6563742066656174757265732E60293B73776974636828743D743F3F5B5D2C6E297B636173652273657422';
wwv_flow_imp.g_varchar2_table(44) := '3A663D6E65772053657428742E6D61702828653D3E652E746F537472696E6728292929293B627265616B3B6361736522616464223A663F3F3D6E6577205365743B666F7228636F6E73742065206F66207429662E61646428652E746F537472696E672829';
wwv_flow_imp.g_varchar2_table(45) := '293B627265616B3B636173652272656D6F7665223A6966286629666F7228636F6E73742065206F66207429662E64656C65746528652E746F537472696E672829297D5328297D2C73656C656374416C6C46656174757265733A28293D3E7B696628216729';
wwv_flow_imp.g_varchar2_table(46) := '7468726F77206E6577204572726F722860247B657D3A20416E20494420636F6C756D6E20697320726571756972656420696E206F7264657220746F2073656C6563742066656174757265732E60293B62262628663D6E65772053657428622E6665617475';
wwv_flow_imp.g_varchar2_table(47) := '7265732E6D61702828653D3E652E69643F2E746F537472696E67282929292E66696C7465722828653D3E2121652929292C532829297D2C636C65617253656C656374696F6E3A28293D3E7B663D6E756C6C2C5328297D2C676574536F7572636544617461';
wwv_flow_imp.g_varchar2_table(48) := '3A28293D3E622C77616974466F724C6F61643A28293D3E6E65772050726F6D697365282828652C74293D3E7B6E756C6C3D3D3D753F6528293A752E707573682865297D29292C6765744D61703A6173796E6328293D3E617761697420547D292C6520696E';
wwv_flow_imp.g_varchar2_table(49) := '204D4150424954535F48544D4C5F4D41524B45525F57414954494E47297B636F6E737420743D617065782E6974656D2865293B4D4150424954535F48544D4C5F4D41524B45525F57414954494E475B655D2E666F72456163682828653D3E652874292929';
wwv_flow_imp.g_varchar2_table(50) := '7D4D4150424954535F48544D4C5F4D41524B45525F57414954494E475B655D3D6E756C6C7D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(45433121897852241)
,p_plugin_id=>wwv_flow_imp.id(43409750273713273)
,p_file_name=>'mapbits-htmlmarker.min.js'
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
