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
--   Date and Time:   16:13 Friday May 30, 2025
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 531563995518728589
--   Manifest End
--   Version:         23.2.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_layer_htmlmarker
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(531563995518728589)
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
'    p_key => ''MIL.ARMY.USACE.MAPBITS.LAYER.LODESTAR'' || p_item.name);',
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
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'mapbits_htmlmarker'
,p_ajax_function=>'mapbits_htmlmarker_ajax'
,p_standard_attributes=>'INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits Lodestar Layer plugin provides an alternative map layer to Apex''s built-in layers. It includes advanced configuration options that expose the full power of MapLibre styling and labeling capability.'
,p_version_identifier=>'4.9.20250128'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Lodestar Layer',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_htmlmarker.sql 20685 2025-05-30 21:18:24Z b2eddjw9 $',
'Date     : $Date: 2025-05-30 16:18:24 -0500 (Fri, 30 May 2025) $',
'Revision : $Revision: 20685 $',
'Requires : Application Express >= 22.2',
'',
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
,p_files_version=>852
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(136699382383670016)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_title=>'Source'
,p_display_sequence=>1
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(136699752200670016)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_title=>'Columns'
,p_display_sequence=>2
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(136700189468670016)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_title=>'Display'
,p_display_sequence=>3
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(531564169703728597)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
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
 p_id=>wwv_flow_imp.id(531564639091728600)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Source Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(531567026507728603)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'query'
,p_attribute_group_id=>wwv_flow_imp.id(136699382383670016)
,p_examples=>'select shape, usace_district_id from mb4_usace_districts'
,p_help_text=>'Source query used to define the layer. At a minimum this must include an SDOGeometry column. Additional attributes should include a unique identifier column if labeling features or interaction with features is required. Any additional attributes that'
||' are included in the query can be used for constructing labels or other MapLibre attribute operations.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(531565030795728600)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Geometry Column'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(531567026507728603)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'javascript'
,p_attribute_group_id=>wwv_flow_imp.id(136699752200670016)
,p_help_text=>'Column from the source query that represents the geometry as SDOGeometry objects.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(531567026507728603)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>15
,p_prompt=>'Source Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'query'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(136699382383670016)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(531567407994728603)
,p_plugin_attribute_id=>wwv_flow_imp.id(531567026507728603)
,p_display_sequence=>10
,p_display_value=>'SQL Query'
,p_return_value=>'query'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(531567864408728605)
,p_plugin_attribute_id=>wwv_flow_imp.id(531567026507728603)
,p_display_sequence=>20
,p_display_value=>'Region Source'
,p_return_value=>'region_source'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(531568428764728605)
,p_plugin_attribute_id=>wwv_flow_imp.id(531567026507728603)
,p_display_sequence=>30
,p_display_value=>'JavaScript'
,p_return_value=>'javascript'
,p_help_text=>'The data is provided by JavaScript code in the Initialization JavaScript Function attribute (in the Advanced section). The initialization function must return an object with a ''dataSource'' property, which is either a GeoJSON object or an async functi'
||'on that returns one.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(531612836561045937)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Legend Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'The color of the marker layer''s entry in the legend.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(531572755426728610)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>21
,p_prompt=>'Page Items To Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(531567026507728603)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'javascript,region_source'
,p_attribute_group_id=>wwv_flow_imp.id(136699382383670016)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(531585869435747390)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Marker Content'
,p_attribute_type=>'HTML'
,p_is_required=>true
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(136700189468670016)
,p_help_text=>'The HTML content of the marker. Use substitutions to include columns from the query.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(136662671145462823)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>160
,p_prompt=>'Where Clause'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(531567026507728603)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'region_source'
,p_attribute_group_id=>wwv_flow_imp.id(136699382383670016)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(136698650397667836)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>170
,p_prompt=>'ID Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(136699752200670016)
,p_help_text=>'The column to get the feature ID from.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(142399490781521933)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>180
,p_prompt=>'Min/Max Zoom'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(136700189468670016)
,p_examples=>'0-12'
,p_help_text=>'The minimum and maximum zoom levels to show this layer at.'
);
wwv_flow_imp_shared.create_plugin_std_attribute(
 p_id=>wwv_flow_imp.id(531586279645749458)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(531579197467728633)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_name=>'click'
,p_display_name=>'Feature Clicked'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(531579634396728634)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_name=>'load_end'
,p_display_name=>'Loading Finished'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(531580022546728634)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_name=>'load_start'
,p_display_name=>'Loading Started'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(531580396423728635)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_name=>'visibility_toggled'
,p_display_name=>'Visibility Toggled'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F48544D4C5F4D41524B45525F57414954494E473D7B7D3B66756E6374696F6E206D6170626974735F68746D6C6D61726B65725F776169745F666F725F696E69742865297B72657475726E206E65772050726F6D697365';
wwv_flow_imp.g_varchar2_table(2) := '282828412C74293D3E7B6520696E204D4150424954535F48544D4C5F4D41524B45525F57414954494E477C7C284D4150424954535F48544D4C5F4D41524B45525F57414954494E475B655D3D5B5D292C6E756C6C213D3D4D4150424954535F48544D4C5F';
wwv_flow_imp.g_varchar2_table(3) := '4D41524B45525F57414954494E475B655D3F4D4150424954535F48544D4C5F4D41524B45525F57414954494E475B655D2E707573682828653D3E7B412865297D29293A4128617065782E6974656D286529297D29297D66756E6374696F6E206D61706269';
wwv_flow_imp.g_varchar2_table(4) := '74735F68746D6C6D61726B6572287B6974656D49643A652C616A61784964656E7469666965723A412C726567696F6E49643A742C73657175656E63654E756D6265723A6F2C7469746C653A6E2C7375626D69744974656D733A722C68746D6C436F6E7465';
wwv_flow_imp.g_varchar2_table(5) := '6E743A612C696E6974436F64653A692C736F75726365547970653A732C6C6567656E64436F6C6F723A632C636C69636B61626C653A6C2C7A6F6F6D52616E67653A677D297B69662821742972657475726E20766F696420617065782E64656275672E6572';
wwv_flow_imp.g_varchar2_table(6) := '726F7228226D6170626974735F68746D6C6D61726B657220222B652B22203A204974656D206973206E6F7420696E206120726567696F6E2E22293B6C657420643D5B5D3B636F6E737420703D693F6928293A7B7D3B6C657420493D617065782E73746F72';
wwv_flow_imp.g_varchar2_table(7) := '6167652E676574436F6F6B696528224D6170626974735F48544D4C4D61726B65725F222B652B225F222B2476282270496E7374616E63652229293B76617220423D6E756C6C3B6C657420753D653D3E7B493D657D3B636F6E73745B452C6D5D3D28413D3E';
wwv_flow_imp.g_varchar2_table(8) := '7B6966282F5E5B302D395D2B5B2D2C3A5D5B302D395D2B242F2E74657374284129297B636F6E737420743D412E73706C6974282F5B2D2C3A5D2F292C6F3D7061727365496E7428745B305D292C6E3D7061727365496E7428745B315D293B6966286F3E3D';
wwv_flow_imp.g_varchar2_table(9) := '3026266E3C3D32342972657475726E5B6F2C6E5D3B636F6E736F6C652E7761726E2822436F6E66696775726174696F6E204572726F723A20436F756C64206E6F74207365742072616E6765206F66205B222B652B225D207573696E67206F7574206F6620';
wwv_flow_imp.g_varchar2_table(10) := '72616E6765207A6F6F6D206C696D697473205B222B412B225D2E204D696E206973203020616E64206D61782069732032342E22297D656C736520636F6E736F6C652E7761726E2822436F6E66696775726174696F6E204572726F723A20436F756C64206E';
wwv_flow_imp.g_varchar2_table(11) := '6F74207365742072616E6765206F66205B222B652B225D207573696E67207A6F6F6D206C696D697473205B222B412B225D22293B72657475726E5B302C32345D7D2928673F3F22302D31303022293B6C657420663D21303B636F6E737420773D6E657720';
wwv_flow_imp.g_varchar2_table(12) := '50726F6D697365282828412C6F293D3E7B636F6E7374206E3D617065782E726567696F6E2874293B6966286E756C6C3D3D6E2972657475726E20617065782E64656275672E6572726F7228226D6170626974735F68746D6C6D61726B657220222B652B22';
wwv_flow_imp.g_varchar2_table(13) := '203A20526567696F6E205B222B742B225D2069732068696464656E206F72206D697373696E672E22292C766F6964206F28293B6E2E656C656D656E742E6F6E28227370617469616C6D6170696E697469616C697A6564222C2828293D3E7B636F6E737420';
wwv_flow_imp.g_varchar2_table(14) := '653D617065782E726567696F6E2874292E63616C6C28226765744D61704F626A65637422293B412865297D29297D29292E7468656E2828413D3E28412E6F6E28227A6F6F6D222C28653D3E7B636F6E737420743D432841293B69662874213D3D66297B66';
wwv_flow_imp.g_varchar2_table(15) := '6F7228636F6E73742065206F66205129743F652E616464546F2841293A652E72656D6F766528293B663D747D7D29292C6E65772050726F6D6973652828286F2C72293D3E7B76617220613D736574496E74657276616C282866756E6374696F6E28297B63';
wwv_flow_imp.g_varchar2_table(16) := '6F6E737420723D617065782E6A5175657279282223222B742B225F6C6567656E6422293B72262628636C656172496E74657276616C2861292C617065782E6A517565727928273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E64';
wwv_flow_imp.g_varchar2_table(17) := '4974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E3C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D63';
wwv_flow_imp.g_varchar2_table(18) := '6865636B65642220636865636B65643D22222069643D22272B652B275F6C6567656E645F656E74727922207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B28633F3F22626C756522292B27223E3C6C61';
wwv_flow_imp.g_varchar2_table(19) := '62656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C222069643D22272B652B275F6C6567656E645F656E7472795F6C6162656C2220666F723D22272B652B275F6C6567656E645F656E747279223E272B286E7C7C65292B';
wwv_flow_imp.g_varchar2_table(20) := '273C696D672069643D22272B652B275F6C6567656E645F656E7472795F737461747573222F3E3C2F6C6162656C3E3C2F6469763E27292E617070656E64546F2872292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922';
wwv_flow_imp.g_varchar2_table(21) := '292E70726F702822636865636B6564222C226E6F6E6522213D3D49292C6F284129297D292C353030297D29292929293B766172204D2C793D21313B636F6E737420513D5B5D2C683D5B5D2C433D653D3E226E6F6E6522213D3D492626652E6765745A6F6F';
wwv_flow_imp.g_varchar2_table(22) := '6D28293E3D452626652E6765745A6F6F6D28293C3D6D2C533D6173796E6328293D3E7B666F7228636F6E73742065206F66205129652E72656D6F766528293B512E6C656E6774683D303B666F7228636F6E73742065206F662068296528293B682E6C656E';
wwv_flow_imp.g_varchar2_table(23) := '6774683D303B636F6E737420413D617761697420772C743D432841293B666F7228636F6E7374206F206F66204D2E6665617475726573297B69662822506F696E7422213D3D6F2E67656F6D657472792E74797065297B617065782E64656275672E657272';
wwv_flow_imp.g_varchar2_table(24) := '6F7228224D6170626974732048544D4C204D61726B65723A20466561747572652067656F6D65747279206973206E6F74206120706F696E7422293B636F6E74696E75657D636F6E7374206E3D7B2E2E2E6F2E70726F706572746965732C4D415042495453';
wwv_flow_imp.g_varchar2_table(25) := '5F53454C45435445443A422626766F69642030213D3D6F2E696426266E756C6C213D3D6F2E69642626422E686173286F2E69642E746F537472696E672829293F2274727565223A22227D2C723D2428223C6469763E22292E68746D6C28617065782E7574';
wwv_flow_imp.g_varchar2_table(26) := '696C2E6170706C7954656D706C61746528612C7B706C616365686F6C646572733A6E7D29293B6C2626722E6373732822637572736F72222C22706F696E74657222292C722E6F6E2822636C69636B222C2828293D3E7B617065782E6576656E742E747269';
wwv_flow_imp.g_varchar2_table(27) := '67676572282223222B652C22636C69636B222C7B666561747572653A6F7D297D29293B636F6E737420693D22737472696E67223D3D747970656F6620702E6D61726B6572416E63686F723F702E6D61726B6572416E63686F723A2266756E6374696F6E22';
wwv_flow_imp.g_varchar2_table(28) := '3D3D747970656F6620702E6D61726B6572416E63686F723F702E6D61726B6572416E63686F72286E293A766F696420302C733D6E6577206D61706C69627265676C2E4D61726B6572287B656C656D656E743A722E6765742830292C616E63686F723A697D';
wwv_flow_imp.g_varchar2_table(29) := '292E7365744C6E674C6174286F2E67656F6D657472792E636F6F7264696E61746573293B6966282266756E6374696F6E223D3D747970656F6620702E6D61726B6572496E6974297B636F6E737420653D702E6D61726B6572496E697428732C6E293B2266';
wwv_flow_imp.g_varchar2_table(30) := '756E6374696F6E223D3D747970656F6620652626682E707573682865297D742626732E616464546F2841292C512E707573682873297D7D3B6173796E632066756E6374696F6E205F28297B24282223222B652B225F6C6567656E645F656E7472795F7374';
wwv_flow_imp.g_varchar2_table(31) := '6174757322292E617474722822737263222C22646174613A696D6167652F6769663B6261736536342C52306C474F446C684541415141504D50414C753775356D5A6D544D7A4D3933643352455245514141414864336431565656575A6D5A717171716F69';
wwv_flow_imp.g_varchar2_table(32) := '49694F3775376B52455243496949674152414141414143482F4330354656464E44515642464D69347741774541414141682B51514642774150414377414141414145414151414541456350444A747967366455724665744454496F704D6F537946637878';
wwv_flow_imp.g_varchar2_table(33) := '44316B7244384177436B415344496C50615544514C52364731437930536771496B45314951474D7246414B4363475753427A7750416E41776172634B5131354D70544D4A5964315A79554458534447656C42593071496F42682F5A6F594767454C436A6F';
wwv_flow_imp.g_varchar2_table(34) := '78435252764951634744316B7A67534167414143514478454149666B4542516341447741734141414141413841454141414246337779666B4D6B6F744F4A707363524B4A4A7774493451314D416F785130524642773078457668474156525A5A4A68344A';
wwv_flow_imp.g_varchar2_table(35) := '674D414551573754574934457747466A4B522B43415145436A6E38446F4E306B7744747642543846494C414B4A67666F6F3169414741504E56593944474A584E4D49484E2F484A56714978454149666B4542516341447741734141414141424141447741';
wwv_flow_imp.g_varchar2_table(36) := '414246727779666D436F6C6769796470615169593578394974683768555264496C30774249687043416A4B494978614155505130684651734143374D4A414C465346693453674334777948797543594E5778483341756853456F746B4E4741414C415071';
wwv_flow_imp.g_varchar2_table(37) := '716B696747384D57416A416E4D34413835393476505579494149666B4542516341447741734141414141424141454141414246337779536B4476644B736464672B4150594957726367324449525141635536444A49436A49736A424545544C454542594C';
wwv_flow_imp.g_varchar2_table(38) := '71595344644A6F43476948675A7747344C51434352454345494241646F463568644549577767424A714473374467634B7952485A6C3375557775686D3241624E4E572B4C563779642B4678454149666B4542516341434141734141414141424141446741';
wwv_flow_imp.g_varchar2_table(39) := '414245595179596D4D6F56676557517250334E59684243675A4264414652556B6442494155677556566F315A7357466345474235474D426B456A6943424C3261355A41692B6D32534155524578774B71506975436166426B76425343636D695952414348';
wwv_flow_imp.g_varchar2_table(40) := '3542415548414134414C414141414141514142414141415273304D6E70414B4459726253574D7030785A4976424B5972586A4E6D41444F68414B42695144463567476349434E41794A5477465954426144513048416B6777536D41556A304F6B4D726B5A';
wwv_flow_imp.g_varchar2_table(41) := '4D344842674B4B3759544B44524943416F32636C41454968654B63394349536A455654754551724A41534763534251635355464555445155584A4267444257305A6A3334524143483542415548414138414C414141414141514142414141415266384D6E';
wwv_flow_imp.g_varchar2_table(42) := '3578714259677256433445456D42634F536641456A536F704A4D676C6D63516C6742596A45354E4A675A776A4341624F345942414A6A70496A536941516835617979524149444B764A49626E4961676F465246646B5144514B4330524273434955464157';
wwv_flow_imp.g_varchar2_table(43) := '73543752774734313052384869694B305742774A6A4642454149666B45425163414467417341514142414138414477414142467251796245574144584A4C554848414D4A78494441676E724F6F322B414F6962454D68314C4E363267497870687A697452';
wwv_flow_imp.g_varchar2_table(44) := '6F434441594E634E4E3646424C5368616F34577A774844514B765647686F46417747677446675148454E686F42376E43774852414943304579556343385A77316861334E495267414149666B454251634144774173414141414142414145414141424744';
wwv_flow_imp.g_varchar2_table(45) := '7779666E576F6C6A614E595946562B5A783368434547456375797042744D4A42495370436C41574C66574F44796D494669434A774D444D695A424E41415946715541614E5132453059424958475552414D436F31414173465942426F495363424A457767';
wwv_flow_imp.g_varchar2_table(46) := '5356636D50306C6934467763487A2B46704343514D504346494E78454149666B45425163414467417341414142414241414477414142467A5179656D5758594E7161535859327656747733554E6D524F4D344A516F774B4B6C464F736752493641535138';
wwv_flow_imp.g_varchar2_table(47) := '496853414446416A414D494D416753594A744279787951496863456F614263536977656770446776417753424A30414948426F435171494145692F54434941414247684C47384D62634B425167455141682B515146427741504143774141414541454141';
wwv_flow_imp.g_varchar2_table(48) := '50414141455866444A53642B71654B355242386644525257467370796F74414166514262664E4C4356555353644B445638396744417763464249426779774D526E6B574267634A55444B535A52494B4150516347775942794141595445454A41414A4947';
wwv_flow_imp.g_varchar2_table(49) := '62415445512B423445786D4B3943446842643854686448772F416D5559455141682B51514642774150414377414141454144774150414141455876424A514961382B494C53737064486B587853397778463451334C3261544265433073466A6841747579';
wwv_flow_imp.g_varchar2_table(50) := '4C496A414D6859633247426761534B4775794E6F42447037637A4641676542494B7743366B5743414D78555341466A744E43414146474746357443514C41614A6E57435471486F5245765175514A416B79474245414F773D3D22292C617065782E657665';
wwv_flow_imp.g_varchar2_table(51) := '6E742E74726967676572282223222B652C226C6F61645F737461727422293B7472797B226A617661736372697074223D3D3D733F2266756E6374696F6E223D3D747970656F6620703F2E64617461536F757263653F4D3D617761697420702E6461746153';
wwv_flow_imp.g_varchar2_table(52) := '6F7572636528293A226F626A656374223D3D747970656F6620703F2E64617461536F757263653F4D3D702E64617461536F757263653A617065782E64656275672E6572726F722822636F6E6669672E64617461536F7572636520776173206E6F74207072';
wwv_flow_imp.g_varchar2_table(53) := '6F766964656422293A4D3D617761697420617065782E7365727665722E706C7567696E28412C7B706167654974656D733A723F722E73706C697428222C22292E66696C7465722828653D3E21216529293A766F696420307D297D66696E616C6C797B6170';
wwv_flow_imp.g_varchar2_table(54) := '65782E6576656E742E74726967676572282223222B652C226C6F61645F656E6422292C24282223222B652B225F6C6567656E645F656E7472795F73746174757322292E617474722822737263222C2222297D6966286177616974205328292C2179297B79';
wwv_flow_imp.g_varchar2_table(55) := '3D21303B636F6E737420413D617761697420773B753D743D3E7B636F6E7374206F3D432841293B666F7228636F6E73742065206F662051296F3F652E616464546F2841293A652E72656D6F766528293B617065782E73746F726167652E736574436F6F6B';
wwv_flow_imp.g_varchar2_table(56) := '696528224D6170626974735F4C6F6465737461724C617965725F222B652B225F222B2476282270496E7374616E636522292C74292C493D742C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F7028226368';
wwv_flow_imp.g_varchar2_table(57) := '65636B6564222C2276697369626C65223D3D3D74292C617065782E6576656E742E74726967676572282223222B652C227669736962696C6974795F746F67676C6564222C7B76697369626C653A2276697369626C65223D3D3D747D297D2C226E6F6E6522';
wwv_flow_imp.g_varchar2_table(58) := '3D3D493F287528226E6F6E6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213129293A2875282276697369626C6522292C617065782E6A5175657279282223222B';
wwv_flow_imp.g_varchar2_table(59) := '652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213029292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E6368616E6765282866756E6374696F6E2865297B76617220413D';
wwv_flow_imp.g_varchar2_table(60) := '617065782E6A51756572792874686973293B7528412E697328223A636865636B656422293F2276697369626C65223A226E6F6E6522297D29293B666F7228636F6E73742065206F662064296528293B643D6E756C6C7D7D5F28293B6C657420523D21303B';
wwv_flow_imp.g_varchar2_table(61) := '696628617065782E6A51756572792822626F647922292E6F6E2822617065786265666F726572656672657368222C286173796E6320653D3E7B652E7461726765743D3D3D617065782E726567696F6E2874292E656C656D656E745B305D262628523F523D';
wwv_flow_imp.g_varchar2_table(62) := '21313A6177616974205F2829297D29292C617065782E6974656D2E63726561746528652C7B726566726573683A6173796E6328293D3E7B6177616974205F28297D2C73686F773A28293D3E7B75282276697369626C6522297D2C686964653A28293D3E7B';
wwv_flow_imp.g_varchar2_table(63) := '7528226E6F6E6522297D2C697356697369626C653A28293D3E226E6F6E6522213D3D492C73657453656C656374656446656174757265733A28652C41293D3E7B73776974636828653D653F3F5B5D2C41297B6361736522736574223A423D6E6577205365';
wwv_flow_imp.g_varchar2_table(64) := '7428652E6D61702828653D3E652E746F537472696E6728292929293B627265616B3B6361736522616464223A423F3F3D6E6577205365743B666F7228636F6E73742041206F66206529422E61646428412E746F537472696E672829293B627265616B3B63';
wwv_flow_imp.g_varchar2_table(65) := '6173652272656D6F7665223A6966284229666F7228636F6E73742041206F66206529422E64656C65746528412E746F537472696E672829297D5328297D2C73656C656374416C6C46656174757265733A28293D3E7B7265736F6C766564536F757263654F';
wwv_flow_imp.g_varchar2_table(66) := '7074696F6E73262628423D6E657720536574287265736F6C766564536F757263654F7074696F6E732E646174612E66656174757265732E6D61702828653D3E652E69642E746F537472696E6728292929292C532829297D2C676574536F75726365446174';
wwv_flow_imp.g_varchar2_table(67) := '613A28293D3E7265736F6C766564536F757263654F7074696F6E733F2E646174612C77616974466F724C6F61643A28293D3E6E65772050726F6D697365282828652C41293D3E7B6E756C6C3D3D3D643F6528293A642E707573682865297D29292C676574';
wwv_flow_imp.g_varchar2_table(68) := '4D61703A6173796E6328293D3E617761697420777D292C6520696E204D4150424954535F48544D4C5F4D41524B45525F57414954494E47297B636F6E737420413D617065782E6974656D2865293B4D4150424954535F48544D4C5F4D41524B45525F5741';
wwv_flow_imp.g_varchar2_table(69) := '4954494E475B655D2E666F72456163682828653D3E6528412929297D4D4150424954535F48544D4C5F4D41524B45525F57414954494E475B655D3D6E756C6C7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(144257076659439132)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_file_name=>'mapbits-htmlmarker.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
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
wwv_flow_imp.g_varchar2_table(8) := '75726365547970652C206C6567656E64436F6C6F722C20636C69636B61626C652C207A6F6F6D52616E67652C0D0A7D29207B0D0A20206966202821726567696F6E496429207B0D0A20202020617065782E64656275672E6572726F7228276D6170626974';
wwv_flow_imp.g_varchar2_table(9) := '735F68746D6C6D61726B65722027202B206974656D4964202B2027203A204974656D206973206E6F7420696E206120726567696F6E2E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A20202F2F204C697374206F662066756E6374696F6E';
wwv_flow_imp.g_varchar2_table(10) := '7320746F2062652063616C6C6564207768656E20746865206974656D20697320646F6E65206C6F6164696E670D0A20206C65742077616974466F724C6F6164203D205B5D3B0D0A0D0A20202F2F2054686520636F6E66696775726174696F6E206F626A65';
wwv_flow_imp.g_varchar2_table(11) := '63742072657475726E65642066726F6D2074686520496E697469616C697A6174696F6E204A6176615363726970742046756E6374696F6E0D0A2020636F6E737420636F6E666967203D20696E6974436F6465203F20696E6974436F64652829203A207B7D';
wwv_flow_imp.g_varchar2_table(12) := '3B0D0A0D0A20206C6574206C61796572735669736962696C697479203D20617065782E73746F726167652E676574436F6F6B696528274D6170626974735F48544D4C4D61726B65725F27202B206974656D4964202B20275F27202B202476282770496E73';
wwv_flow_imp.g_varchar2_table(13) := '74616E63652729293B0D0A0D0A20207661722073656C65637465644665617475726573203D206E756C6C3B0D0A0D0A20206C6574207365744C61796572735669736962696C697479203D20287669736962696C69747929203D3E207B0D0A202020206C61';
wwv_flow_imp.g_varchar2_table(14) := '796572735669736962696C697479203D207669736962696C6974793B0D0A20207D3B0D0A0D0A2020636F6E73742070617273655A6F6F6D52616E6765203D202872616E676529203D3E207B0D0A202020202F2F2067657420746865207A6F6F6D2072616E';
wwv_flow_imp.g_varchar2_table(15) := '67652C20646F206E6F7420646973706C6179206C61796572206F757473696465206F6620746869732072616E67652E0D0A20202020696620282F5E5B302D395D2B5B2D2C3A5D5B302D395D2B242F2E746573742872616E67652929207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(16) := '20636F6E737420746F6B203D2072616E67652E73706C6974282F5B2D2C3A5D2F293B0D0A202020202020636F6E7374207A6D696E203D207061727365496E7428746F6B5B305D293B0D0A202020202020636F6E7374207A6D6178203D207061727365496E';
wwv_flow_imp.g_varchar2_table(17) := '7428746F6B5B315D293B0D0A2020202020200D0A202020202020696620287A6D696E203E3D2030202626207A6D6178203C3D20323429207B0D0A202020202020202072657475726E205B7A6D696E2C207A6D61785D3B0D0A2020202020207D20656C7365';
wwv_flow_imp.g_varchar2_table(18) := '207B0D0A2020202020202020636F6E736F6C652E7761726E2827436F6E66696775726174696F6E204572726F723A20436F756C64206E6F74207365742072616E6765206F66205B27202B206974656D4964202B20275D207573696E67206F7574206F6620';
wwv_flow_imp.g_varchar2_table(19) := '72616E6765207A6F6F6D206C696D697473205B27202B2072616E6765202B20225D2E204D696E206973203020616E64206D61782069732032342E22293B0D0A2020202020207D0D0A202020207D20656C7365207B0D0A202020202020636F6E736F6C652E';
wwv_flow_imp.g_varchar2_table(20) := '7761726E2827436F6E66696775726174696F6E204572726F723A20436F756C64206E6F74207365742072616E6765206F66205B27202B206974656D4964202B20275D207573696E67207A6F6F6D206C696D697473205B27202B2072616E6765202B20225D';
wwv_flow_imp.g_varchar2_table(21) := '22293B0D0A202020207D0D0A0D0A2020202072657475726E205B302C2032345D3B0D0A20207D3B0D0A0D0A2020636F6E7374205B6D696E5A6F6F6D2C206D61785A6F6F6D5D203D2070617273655A6F6F6D52616E6765287A6F6F6D52616E6765203F3F20';
wwv_flow_imp.g_varchar2_table(22) := '27302D31303027293B0D0A20206C6574206D61726B65727356697369626C65203D20747275653B0D0A0D0A20202F2F20412070726F6D6973652074686174207265736F6C76657320746F20746865206173736F636961746564204D617020526567696F6E';
wwv_flow_imp.g_varchar2_table(23) := '206F6E636520697420697320696E697469616C697A65642E0D0A2020636F6E73742070656E64696E674D6170203D206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020636F6E737420726567696F6E203D';
wwv_flow_imp.g_varchar2_table(24) := '20617065782E726567696F6E28726567696F6E4964293B0D0A2020202069662028726567696F6E203D3D206E756C6C29207B0D0A202020202020617065782E64656275672E6572726F7228276D6170626974735F68746D6C6D61726B65722027202B2069';
wwv_flow_imp.g_varchar2_table(25) := '74656D4964202B2027203A20526567696F6E205B27202B20726567696F6E4964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A20202020202072656A65637428293B0D0A20202020202072657475726E3B0D0A20202020';
wwv_flow_imp.g_varchar2_table(26) := '7D0D0A0D0A20202020726567696F6E2E656C656D656E742E6F6E28277370617469616C6D6170696E697469616C697A6564272C202829203D3E207B0D0A202020202020636F6E7374206D6170203D20617065782E726567696F6E28726567696F6E496429';
wwv_flow_imp.g_varchar2_table(27) := '2E63616C6C28276765744D61704F626A65637427293B0D0A2020202020207265736F6C7665286D6170293B0D0A202020207D293B0D0A20207D292E7468656E28286D617029203D3E207B0D0A202020206D61702E6F6E28277A6F6F6D272C20286576656E';
wwv_flow_imp.g_varchar2_table(28) := '7429203D3E207B0D0A202020202020636F6E7374206D61726B6572734E6F7756697369626C65203D2073686F756C644D61726B657273426556697369626C65286D6170293B0D0A202020202020696620286D61726B6572734E6F7756697369626C652021';
wwv_flow_imp.g_varchar2_table(29) := '3D3D206D61726B65727356697369626C6529207B0D0A2020202020202020666F722028636F6E7374206D61726B6572206F66206D61726B65727329207B0D0A20202020202020202020696620286D61726B6572734E6F7756697369626C6529207B0D0A20';
wwv_flow_imp.g_varchar2_table(30) := '20202020202020202020206D61726B65722E616464546F286D6170293B0D0A202020202020202020207D20656C7365207B0D0A2020202020202020202020206D61726B65722E72656D6F766528293B0D0A202020202020202020207D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(31) := '20207D0D0A20202020202020206D61726B65727356697369626C65203D206D61726B6572734E6F7756697369626C653B0D0A2020202020207D0D0A202020207D293B0D0A0D0A202020202F2F205761697420666F7220746865206C6567656E6420746F20';
wwv_flow_imp.g_varchar2_table(32) := '6C6F61640D0A2020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A20202020202076617220696E74657276616C203D20736574496E74657276616C2866756E6374696F6E2829207B0D0A';
wwv_flow_imp.g_varchar2_table(33) := '2020202020202020636F6E7374206C6567656E64203D20617065782E6A517565727928272327202B20726567696F6E4964202B20275F6C6567656E6427293B0D0A202020202020202069662028216C6567656E6429207B0D0A2020202020202020202072';
wwv_flow_imp.g_varchar2_table(34) := '657475726E3B0D0A20202020202020207D0D0A0D0A2020202020202020636C656172496E74657276616C28696E74657276616C293B0D0A0D0A2020202020202020617065782E6A517565727928273C64697620636C6173733D22612D4D6170526567696F';
wwv_flow_imp.g_varchar2_table(35) := '6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E27202B200D0A20202020202020202020273C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D617052';
wwv_flow_imp.g_varchar2_table(36) := '6567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069643D2227202B206974656D4964202B20275F6C6567656E645F656E74727927202B202722207374796C653D222D2D612D6D61702D6C6567';
wwv_flow_imp.g_varchar2_table(37) := '656E642D73656C6563746F722D636F6C6F723A27202B20286C6567656E64436F6C6F72203F3F2027626C75652729202B2027223E27202B0D0A20202020202020202020273C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E64';
wwv_flow_imp.g_varchar2_table(38) := '4C6162656C222069643D2227202B206974656D4964202B20275F6C6567656E645F656E7472795F6C6162656C27202B20272220666F723D2227202B206974656D4964202B20275F6C6567656E645F656E74727927202B2027223E27202B20287469746C65';
wwv_flow_imp.g_varchar2_table(39) := '207C7C206974656D496429202B20273C696D672069643D2227202B206974656D4964202B20275F6C6567656E645F656E7472795F737461747573222F3E3C2F6C6162656C3E27202B0D0A20202020202020202020273C2F6469763E27292E617070656E64';
wwv_flow_imp.g_varchar2_table(40) := '546F286C6567656E64293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C206C61796572735669736962696C69747920213D';
wwv_flow_imp.g_varchar2_table(41) := '3D20276E6F6E6527293B0D0A0D0A20202020202020207265736F6C7665286D6170293B0D0A2020202020207D2C20353030293B0D0A202020207D290D0A20207D293B0D0A0D0A2020636F6E7374207370696E6E6572496D616765203D2022646174613A69';
wwv_flow_imp.g_varchar2_table(42) := '6D6167652F6769663B6261736536342C52306C474F446C684541415141504D50414C753775356D5A6D544D7A4D3933643352455245514141414864336431565656575A6D5A717171716F6949694F3775376B52455243496949674152414141414143482F';
wwv_flow_imp.g_varchar2_table(43) := '4330354656464E44515642464D69347741774541414141682B51514642774150414377414141414145414151414541456350444A747967366455724665744454496F704D6F53794663787844316B7244384177436B415344496C50615544514C52364731';
wwv_flow_imp.g_varchar2_table(44) := '437930536771496B45314951474D7246414B4363475753427A7750416E41776172634B5131354D70544D4A5964315A79554458534447656C42593071496F42682F5A6F594767454C436A6F78435252764951634744316B7A675341674141435144784541';
wwv_flow_imp.g_varchar2_table(45) := '49666B4542516341447741734141414141413841454141414246337779666B4D6B6F744F4A707363524B4A4A7774493451314D416F785130524642773078457668474156525A5A4A68344A674D414551573754574934457747466A4B522B43415145436A';
wwv_flow_imp.g_varchar2_table(46) := '6E38446F4E306B7744747642543846494C414B4A67666F6F3169414741504E56593944474A584E4D49484E2F484A56714978454149666B4542516341447741734141414141424141447741414246727779666D436F6C6769796470615169593578394974';
wwv_flow_imp.g_varchar2_table(47) := '683768555264496C30774249687043416A4B494978614155505130684651734143374D4A414C465346693453674334777948797543594E5778483341756853456F746B4E4741414C415071716B696747384D57416A416E4D344138353934765055794941';
wwv_flow_imp.g_varchar2_table(48) := '49666B4542516341447741734141414141424141454141414246337779536B4476644B736464672B4150594957726367324449525141635536444A49436A49736A424545544C454542594C71595344644A6F43476948675A7747344C5143435245434549';
wwv_flow_imp.g_varchar2_table(49) := '4241646F463568644549577767424A714473374467634B7952485A6C3375557775686D3241624E4E572B4C563779642B4678454149666B4542516341434141734141414141424141446741414245595179596D4D6F56676557517250334E59684243675A';
wwv_flow_imp.g_varchar2_table(50) := '4264414652556B6442494155677556566F315A7357466345474235474D426B456A6943424C3261355A41692B6D32534155524578774B71506975436166426B76425343636D6959524143483542415548414134414C414141414141514142414141415273';
wwv_flow_imp.g_varchar2_table(51) := '304D6E70414B4459726253574D7030785A4976424B5972586A4E6D41444F68414B42695144463567476349434E41794A5477465954426144513048416B6777536D41556A304F6B4D726B5A4D344842674B4B3759544B44524943416F32636C4145496865';
wwv_flow_imp.g_varchar2_table(52) := '4B63394349536A455654754551724A41534763534251635355464555445155584A4267444257305A6A3334524143483542415548414138414C414141414141514142414141415266384D6E3578714259677256433445456D42634F536641456A536F704A';
wwv_flow_imp.g_varchar2_table(53) := '4D676C6D63516C6742596A45354E4A675A776A4341624F345942414A6A70496A536941516835617979524149444B764A49626E4961676F465246646B5144514B433052427343495546415773543752774734313052384869694B305742774A6A46424541';
wwv_flow_imp.g_varchar2_table(54) := '49666B45425163414467417341514142414138414477414142467251796245574144584A4C554848414D4A78494441676E724F6F322B414F6962454D68314C4E363267497870687A6974526F434441594E634E4E3646424C5368616F34577A774844514B';
wwv_flow_imp.g_varchar2_table(55) := '765647686F46417747677446675148454E686F42376E43774852414943304579556343385A77316861334E495267414149666B4542516341447741734141414141424141454141414247447779666E576F6C6A614E595946562B5A783368434547456375';
wwv_flow_imp.g_varchar2_table(56) := '797042744D4A42495370436C41574C66574F44796D494669434A774D444D695A424E41415946715541614E5132453059424958475552414D436F31414173465942426F495363424A4577675356636D50306C6934467763487A2B46704343514D50434649';
wwv_flow_imp.g_varchar2_table(57) := '4E78454149666B45425163414467417341414142414241414477414142467A5179656D5758594E7161535859327656747733554E6D524F4D344A516F774B4B6C464F736752493641535138496853414446416A414D494D416753594A7442797879514968';
wwv_flow_imp.g_varchar2_table(58) := '63456F614263536977656770446776417753424A30414948426F435171494145692F54434941414247684C47384D62634B425167455141682B51514642774150414377414141454145414150414141455866444A53642B71654B35524238664452525746';
wwv_flow_imp.g_varchar2_table(59) := '7370796F74414166514262664E4C4356555353644B445638396744417763464249426779774D526E6B574267634A55444B535A52494B4150516347775942794141595445454A41414A494762415445512B423445786D4B3943446842643854686448772F';
wwv_flow_imp.g_varchar2_table(60) := '416D5559455141682B51514642774150414377414141454144774150414141455876424A514961382B494C53737064486B587853397778463451334C3261544265433073466A68417475794C496A414D6859633247426761534B4775794E6F4244703763';
wwv_flow_imp.g_varchar2_table(61) := '7A4641676542494B7743366B5743414D78555341466A744E43414146474746357443514C41614A6E57435471486F5245765175514A416B79474245414F773D3D223B0D0A0D0A20202F2F205768657468657220746865206974656D20686173206C6F6164';
wwv_flow_imp.g_varchar2_table(62) := '656420666F72207468652066697273742074696D652E205468697320656E737572657320736F6D652066697273742D74696D65207365747570206973206F6E6C792072756E206F6E63652E0D0A20207661722061646465644C61796572203D2066616C73';
wwv_flow_imp.g_varchar2_table(63) := '653B0D0A0D0A20202F2F20412047656F4A534F4E206F626A65637420636F6E7461696E696E672074686520666561747572657320746F20646973706C6179206D61726B65727320666F722E0D0A2020766172207175657279526573756C743B0D0A20202F';
wwv_flow_imp.g_varchar2_table(64) := '2F20546865204D61704C69627265206D61726B6572206F626A656374730D0A2020636F6E7374206D61726B657273203D205B5D3B0D0A20202F2F2041206C697374206F662066756E6374696F6E7320746F2063616C6C207768656E2064657374726F7969';
wwv_flow_imp.g_varchar2_table(65) := '6E6720746865206D61726B6572730D0A2020636F6E7374206D61726B657244657374726F79203D205B5D3B0D0A0D0A2020636F6E73742073686F756C644D61726B657273426556697369626C65203D20286D617029203D3E206C61796572735669736962';
wwv_flow_imp.g_varchar2_table(66) := '696C69747920213D3D20276E6F6E6527202626206D61702E6765745A6F6F6D2829203E3D206D696E5A6F6F6D202626206D61702E6765745A6F6F6D2829203C3D206D61785A6F6F6D3B0D0A0D0A2020636F6E73742072656372656174654D61726B657273';
wwv_flow_imp.g_varchar2_table(67) := '203D206173796E63202829203D3E207B0D0A20202020666F722028636F6E7374206D61726B6572206F66206D61726B65727329207B0D0A2020202020206D61726B65722E72656D6F766528293B0D0A202020207D0D0A202020206D61726B6572732E6C65';
wwv_flow_imp.g_varchar2_table(68) := '6E677468203D20303B0D0A20202020666F722028636F6E73742064657374726F79206F66206D61726B657244657374726F7929207B0D0A20202020202064657374726F7928293B0D0A202020207D0D0A202020206D61726B657244657374726F792E6C65';
wwv_flow_imp.g_varchar2_table(69) := '6E677468203D20303B0D0A0D0A20202020636F6E7374206D6170203D2061776169742070656E64696E674D61703B0D0A0D0A20202020636F6E7374206D616B6556697369626C65203D2073686F756C644D61726B657273426556697369626C65286D6170';
wwv_flow_imp.g_varchar2_table(70) := '293B0D0A20202020666F722028636F6E73742066656174757265206F66207175657279526573756C742E666561747572657329207B0D0A20202020202069662028666561747572652E67656F6D657472792E7479706520213D3D2022506F696E74222920';
wwv_flow_imp.g_varchar2_table(71) := '7B0D0A2020202020202020617065782E64656275672E6572726F7228274D6170626974732048544D4C204D61726B65723A20466561747572652067656F6D65747279206973206E6F74206120706F696E7427293B0D0A2020202020202020636F6E74696E';
wwv_flow_imp.g_varchar2_table(72) := '75653B0D0A2020202020207D0D0A0D0A202020202020636F6E73742070726F7073203D207B0D0A20202020202020202E2E2E666561747572652E70726F706572746965732C0D0A2020202020202020274D4150424954535F53454C4543544544273A2028';
wwv_flow_imp.g_varchar2_table(73) := '73656C656374656446656174757265732026262028747970656F6620666561747572652E696420213D3D2027756E646566696E6564272920262620666561747572652E696420213D3D206E756C6C2026262073656C656374656446656174757265732E68';
wwv_flow_imp.g_varchar2_table(74) := '617328666561747572652E69642E746F537472696E6728292929203F20277472756527203A2027270D0A2020202020207D3B0D0A0D0A2020202020202F2F204170706C79207468652074656D706C61746520616E642063726561746520616E2048544D4C';
wwv_flow_imp.g_varchar2_table(75) := '20656C656D656E740D0A202020202020636F6E737420656C656D656E74203D202428273C6469763E27292E68746D6C280D0A2020202020202020617065782E7574696C2E6170706C7954656D706C6174652868746D6C436F6E74656E742C207B0D0A2020';
wwv_flow_imp.g_varchar2_table(76) := '2020202020202020706C616365686F6C646572733A2070726F70732C0D0A20202020202020207D290D0A202020202020293B0D0A0D0A20202020202069662028636C69636B61626C6529207B0D0A2020202020202020656C656D656E742E637373282763';
wwv_flow_imp.g_varchar2_table(77) := '7572736F72272C2027706F696E74657227293B0D0A2020202020207D0D0A202020202020656C656D656E742E6F6E2827636C69636B272C202829203D3E207B0D0A2020202020202020617065782E6576656E742E7472696767657228272327202B206974';
wwv_flow_imp.g_varchar2_table(78) := '656D49642C2027636C69636B272C207B2066656174757265207D293B0D0A2020202020207D293B0D0A0D0A202020202020636F6E737420616E63686F72203D20747970656F6620636F6E6669672E6D61726B6572416E63686F72203D3D3D202773747269';
wwv_flow_imp.g_varchar2_table(79) := '6E67270D0A20202020202020203F20636F6E6669672E6D61726B6572416E63686F720D0A20202020202020203A20747970656F6620636F6E6669672E6D61726B6572416E63686F72203D3D3D202766756E6374696F6E270D0A20202020202020203F2063';
wwv_flow_imp.g_varchar2_table(80) := '6F6E6669672E6D61726B6572416E63686F722870726F7073290D0A20202020202020203A20756E646566696E65643B0D0A0D0A2020202020202F2F2043726561746520746865204D61704C69627265206D61726B65720D0A202020202020636F6E737420';
wwv_flow_imp.g_varchar2_table(81) := '6D61726B6572203D206E6577206D61706C69627265676C2E4D61726B6572287B0D0A2020202020202020656C656D656E743A20656C656D656E742E6765742830292C0D0A2020202020202020616E63686F722C0D0A2020202020207D290D0A2020202020';
wwv_flow_imp.g_varchar2_table(82) := '2020202E7365744C6E674C617428666561747572652E67656F6D657472792E636F6F7264696E61746573293B0D0A0D0A2020202020202F2F2049662061206D61726B6572496E69742066756E6374696F6E207761732070726F76696465642C2063616C6C';
wwv_flow_imp.g_varchar2_table(83) := '206974207769746820746865206D61726B6572206F626A6563740D0A2020202020202F2F20616E64207468652070726F706572746965730D0A20202020202069662028747970656F6620636F6E6669672E6D61726B6572496E6974203D3D3D202266756E';
wwv_flow_imp.g_varchar2_table(84) := '6374696F6E2229207B0D0A2020202020202020636F6E73742064657374726F79203D20636F6E6669672E6D61726B6572496E6974286D61726B65722C2070726F7073293B0D0A202020202020202069662028747970656F662064657374726F79203D3D3D';
wwv_flow_imp.g_varchar2_table(85) := '202266756E6374696F6E2229207B0D0A202020202020202020206D61726B657244657374726F792E707573682864657374726F79293B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A202020202020696620286D616B6556697369626C6529';
wwv_flow_imp.g_varchar2_table(86) := '207B0D0A20202020202020206D61726B65722E616464546F286D6170293B0D0A2020202020207D0D0A2020202020206D61726B6572732E70757368286D61726B6572293B0D0A202020207D0D0A20207D3B0D0A0D0A20202F2F20285265296C6F61642074';
wwv_flow_imp.g_varchar2_table(87) := '6865206461746120616E6420726563726561746520616C6C20746865206D61726B6572730D0A20206173796E632066756E6374696F6E206C6F6164446174612829207B0D0A202020202428272327202B206974656D4964202B20275F6C6567656E645F65';
wwv_flow_imp.g_varchar2_table(88) := '6E7472795F73746174757327292E617474722827737263272C207370696E6E6572496D616765293B0D0A20202020617065782E6576656E742E7472696767657228272327202B206974656D49642C20276C6F61645F737461727427293B0D0A2020202074';
wwv_flow_imp.g_varchar2_table(89) := '7279207B0D0A20202020202069662028736F7572636554797065203D3D3D20276A6176617363726970742729207B0D0A202020202020202069662028747970656F6620636F6E6669673F2E64617461536F75726365203D3D3D202766756E6374696F6E27';
wwv_flow_imp.g_varchar2_table(90) := '29207B0D0A202020202020202020207175657279526573756C74203D20617761697420636F6E6669672E64617461536F7572636528293B0D0A20202020202020207D20656C73652069662028747970656F6620636F6E6669673F2E64617461536F757263';
wwv_flow_imp.g_varchar2_table(91) := '65203D3D3D20276F626A6563742729207B0D0A202020202020202020207175657279526573756C74203D20636F6E6669672E64617461536F757263653B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020617065782E64656275';
wwv_flow_imp.g_varchar2_table(92) := '672E6572726F722827636F6E6669672E64617461536F7572636520776173206E6F742070726F766964656427290D0A20202020202020207D0D0A2020202020207D20656C7365207B0D0A202020202020207175657279526573756C74203D206177616974';
wwv_flow_imp.g_varchar2_table(93) := '20617065782E7365727665722E706C7567696E28616A61784964656E7469666965722C207B706167654974656D733A207375626D69744974656D73203F207375626D69744974656D732E73706C697428222C22292E66696C7465722878203D3E20212178';
wwv_flow_imp.g_varchar2_table(94) := '29203A20756E646566696E65647D293B0D0A2020202020207D0D0A202020207D2066696E616C6C79207B0D0A202020202020617065782E6576656E742E7472696767657228272327202B206974656D49642C20276C6F61645F656E6427293B0D0A202020';
wwv_flow_imp.g_varchar2_table(95) := '2020202428272327202B206974656D4964202B20275F6C6567656E645F656E7472795F73746174757327292E617474722827737263272C202727293B0D0A202020207D0D0A0D0A2020202061776169742072656372656174654D61726B65727328293B0D';
wwv_flow_imp.g_varchar2_table(96) := '0A0D0A202020202F2F2046697273742D74696D652073657475700D0A20202020696620282161646465644C6179657229207B0D0A20202020202061646465644C61796572203D20747275653B0D0A0D0A202020202020636F6E7374206D6170203D206177';
wwv_flow_imp.g_varchar2_table(97) := '6169742070656E64696E674D61703B0D0A0D0A2020202020202F2F20536574207468652066756E6374696F6E20746F2073686F772F6869646520746865206D61726B6572730D0A2020202020207365744C61796572735669736962696C697479203D2028';
wwv_flow_imp.g_varchar2_table(98) := '7669736962696C69747929203D3E207B0D0A2020202020202020636F6E73742076697369626C65203D2073686F756C644D61726B657273426556697369626C65286D6170293B0D0A2020202020202020666F722028636F6E7374206D61726B6572206F66';
wwv_flow_imp.g_varchar2_table(99) := '206D61726B65727329207B0D0A202020202020202020206966202876697369626C6529207B0D0A2020202020202020202020206D61726B65722E616464546F286D6170293B0D0A202020202020202020207D20656C7365207B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(100) := '2020206D61726B65722E72656D6F766528293B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020202020617065782E73746F726167652E736574436F6F6B696528274D6170626974735F4C6F6465737461724C617965725F27';
wwv_flow_imp.g_varchar2_table(101) := '202B206974656D4964202B20275F27202B202476282770496E7374616E636527292C207669736962696C697479293B0D0A20202020202020206C61796572735669736962696C697479203D207669736962696C6974793B0D0A0D0A202020202020202061';
wwv_flow_imp.g_varchar2_table(102) := '7065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C207669736962696C697479203D3D3D202776697369626C6527293B0D0A0D0A2020202020202020617065';
wwv_flow_imp.g_varchar2_table(103) := '782E6576656E742E7472696767657228272327202B206974656D49642C20277669736962696C6974795F746F67676C6564272C207B0D0A2020202020202020202076697369626C653A207669736962696C697479203D3D3D202776697369626C65272C0D';
wwv_flow_imp.g_varchar2_table(104) := '0A20202020202020207D293B0D0A2020202020207D0D0A0D0A2020202020202F2F204D616B65207375726520746865206D61726B6572207669736962696C69747920697320636F72726563746C7920736574206261736564206F6E207468652073746F72';
wwv_flow_imp.g_varchar2_table(105) := '65642076616C756520696E2074686520636F6F6B69650D0A202020202020696620286C61796572735669736962696C697479203D3D20276E6F6E652729207B0D0A20202020202020207365744C61796572735669736962696C69747928276E6F6E652729';
wwv_flow_imp.g_varchar2_table(106) := '3B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A2020202020207D20656C7365207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(107) := '202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B';
wwv_flow_imp.g_varchar2_table(108) := '6564272C2074727565293B0D0A2020202020207D0D0A0D0A2020202020202F2F20557064617465206D61726B6572207669736962696C697479207768656E20746865206C6567656E6420636865636B626F7820697320636C69636B65640D0A2020202020';
wwv_flow_imp.g_varchar2_table(109) := '20617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E6368616E67652866756E6374696F6E2865297B0D0A2020202020202020766172206362203D20617065782E6A5175657279287468697329';
wwv_flow_imp.g_varchar2_table(110) := '3B0D0A20202020202020207365744C61796572735669736962696C6974792863622E697328273A636865636B65642729203F202776697369626C6527203A20276E6F6E6527293B0D0A2020202020207D293B0D0A0D0A2020202020202F2F2043616C6C20';
wwv_flow_imp.g_varchar2_table(111) := '616E792066756E6374696F6E732074686174206172652077616974696E6720666F7220746865206974656D20746F206C6F61642E20546869732077696C6C2063617573650D0A2020202020202F2F20616E792063616C6C7320746F206D6170626974735F';
wwv_flow_imp.g_varchar2_table(112) := '68746D6C6D61726B65725F776169745F666F725F696E697420746F2072657475726E2E0D0A202020202020666F722028636F6E73742066756E63206F662077616974466F724C6F616429207B0D0A202020202020202066756E6328293B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(113) := '207D0D0A20202020202077616974466F724C6F6164203D206E756C6C3B0D0A202020207D0D0A20207D3B0D0A0D0A20202F2F2053746172742074686520696E697469616C2064617461206C6F61642E204E6F7465207468617420746F2073706565642074';
wwv_flow_imp.g_varchar2_table(114) := '68696E67732075702C207765207374617274207468697320696D6D6564696174656C7920616E640D0A20202F2F206F6E6C79207761697420666F72207370617469616C6D6170696E697469616C697A6564206A757374206265666F726520616464696E67';
wwv_flow_imp.g_varchar2_table(115) := '20746865206D61726B6572732E0D0A20206C6F61644461746128293B0D0A0D0A20206C657420666972737452656672657368203D20747275653B0D0A2020617065782E6A51756572792827626F647927292E6F6E2827617065786265666F726572656672';
wwv_flow_imp.g_varchar2_table(116) := '657368272C206173796E632028657629203D3E207B0D0A202020206966202865762E746172676574203D3D3D20617065782E726567696F6E28726567696F6E4964292E656C656D656E745B305D29207B0D0A2020202020202F2A20536B69702074686520';
wwv_flow_imp.g_varchar2_table(117) := '666972737420617065786265666F726572656672657368206576656E742C2073696E6365207468617420636F72726573706F6E647320746F207468652070616765206C6F6164696E672C0D0A20202020202020202062757420776520616C726561647920';
wwv_flow_imp.g_varchar2_table(118) := '63616C6C6564206C6F61644461746128292061626F766520776974686F75742077616974696E6720666F7220746865206D617020746F206C6F61642E202A2F0D0A202020202020696620282166697273745265667265736829207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(119) := '206177616974206C6F61644461746128293B0D0A2020202020207D20656C7365207B0D0A2020202020202020666972737452656672657368203D2066616C73653B0D0A2020202020207D0D0A202020207D0D0A20207D293B0D0A0D0A2020617065782E69';
wwv_flow_imp.g_varchar2_table(120) := '74656D2E637265617465280D0A202020206974656D49642C0D0A202020207B0D0A202020202020726566726573683A206173796E63202829203D3E207B0D0A20202020202020206177616974206C6F61644461746128293B0D0A2020202020207D2C0D0A';
wwv_flow_imp.g_varchar2_table(121) := '20202020202073686F773A202829203D3E207B0D0A20202020202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020207D2C0D0A202020202020686964653A202829203D3E207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(122) := '207365744C61796572735669736962696C69747928276E6F6E6527293B0D0A2020202020207D2C0D0A202020202020697356697369626C653A202829203D3E207B0D0A202020202020202072657475726E206C61796572735669736962696C6974792021';
wwv_flow_imp.g_varchar2_table(123) := '3D3D20276E6F6E65273B0D0A2020202020207D2C0D0A2020202020202F2A2053657420746865206C697374206F66206665617475726573207468617420686176652061202273656C65637465642220617070656172616E63652E20606665617475726573';
wwv_flow_imp.g_varchar2_table(124) := '602069732061206C6973740D0A2020202020202020206F662066656174757265204944732E202A2F0D0A20202020202073657453656C656374656446656174757265733A202866656174757265732C20616374696F6E29203D3E207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(125) := '20206665617475726573203D206665617475726573203F3F205B5D3B0D0A20202020202020207377697463682028616374696F6E29207B0D0A20202020202020202020636173652027736574273A0D0A20202020202020202020202073656C6563746564';
wwv_flow_imp.g_varchar2_table(126) := '4665617475726573203D206E6577205365742866656174757265732E6D61702866203D3E20662E746F537472696E67282929293B0D0A202020202020202020202020627265616B3B0D0A20202020202020202020636173652027616464273A0D0A202020';
wwv_flow_imp.g_varchar2_table(127) := '20202020202020202073656C65637465644665617475726573203F3F3D206E65772053657428293B0D0A202020202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A202020202020202020202020202073656C';
wwv_flow_imp.g_varchar2_table(128) := '656374656446656174757265732E61646428662E746F537472696E672829293B0D0A2020202020202020202020207D0D0A202020202020202020202020627265616B3B0D0A2020202020202020202063617365202772656D6F7665273A0D0A2020202020';
wwv_flow_imp.g_varchar2_table(129) := '202020202020206966202873656C6563746564466561747572657329207B0D0A2020202020202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A2020202020202020202020202020202073656C656374656446';
wwv_flow_imp.g_varchar2_table(130) := '656174757265732E64656C65746528662E746F537472696E672829293B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D0D0A202020202020202020202020627265616B3B0D0A20202020202020207D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(131) := '202072656372656174654D61726B65727328293B0D0A2020202020207D2C0D0A2020202020202F2A2053656C6563747320616C6C2066656174757265732063757272656E746C7920696E20746865206C617965722074686174206861766520616E204944';
wwv_flow_imp.g_varchar2_table(132) := '2E202A2F0D0A20202020202073656C656374416C6C46656174757265733A202829203D3E207B0D0A2020202020202020696620287265736F6C766564536F757263654F7074696F6E7329207B0D0A2020202020202020202073656C656374656446656174';
wwv_flow_imp.g_varchar2_table(133) := '75726573203D206E657720536574287265736F6C766564536F757263654F7074696F6E732E646174612E66656174757265732E6D61702866203D3E20662E69642E746F537472696E67282929293B0D0A2020202020202020202072656372656174654D61';
wwv_flow_imp.g_varchar2_table(134) := '726B65727328293B0D0A20202020202020207D0D0A2020202020207D2C0D0A202020202020676574536F75726365446174613A202829203D3E207B0D0A202020202020202072657475726E207265736F6C766564536F757263654F7074696F6E733F2E64';
wwv_flow_imp.g_varchar2_table(135) := '6174613B0D0A2020202020207D2C0D0A20202020202077616974466F724C6F61643A202829203D3E207B0D0A202020202020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(136) := '20202020206966202877616974466F724C6F6164203D3D3D206E756C6C29207B0D0A2020202020202020202020207265736F6C766528293B0D0A202020202020202020207D20656C7365207B0D0A20202020202020202020202077616974466F724C6F61';
wwv_flow_imp.g_varchar2_table(137) := '642E70757368287265736F6C7665293B0D0A202020202020202020207D0D0A20202020202020207D293B0D0A2020202020207D2C0D0A2020202020206765744D61703A206173796E63202829203D3E2061776169742070656E64696E674D61702C0D0A20';
wwv_flow_imp.g_varchar2_table(138) := '2020207D0D0A2020293B0D0A0D0A2020696620286974656D496420696E204D4150424954535F48544D4C5F4D41524B45525F57414954494E4729207B0D0A20202020636F6E7374206974656D203D20617065782E6974656D286974656D4964293B0D0A20';
wwv_flow_imp.g_varchar2_table(139) := '2020204D4150424954535F48544D4C5F4D41524B45525F57414954494E475B6974656D49645D2E666F724561636828287829203D3E2078286974656D29293B0D0A20207D0D0A20204D4150424954535F48544D4C5F4D41524B45525F57414954494E475B';
wwv_flow_imp.g_varchar2_table(140) := '6974656D49645D203D206E756C6C3B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(531580823036728638)
,p_plugin_id=>wwv_flow_imp.id(531563995518728589)
,p_file_name=>'mapbits-htmlmarker.js'
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
