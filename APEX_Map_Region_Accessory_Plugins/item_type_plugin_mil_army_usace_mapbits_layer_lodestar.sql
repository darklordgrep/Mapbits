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
--   Date and Time:   14:27 Monday December 18, 2023
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 512595521149266662
--   Manifest End
--   Version:         22.2.8
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
 p_id=>wwv_flow_imp.id(512595521149266662)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LAYER.LODESTAR'
,p_display_name=>'Mapbits Lodestar Layer'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#mapbits-lodestarlayer.js',
'#PLUGIN_FILES#tiny-sdf.js'))
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
'  layer_def clob;',
'  l_da_count number;',
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
'    || apex_javascript.add_attribute(''clickable'', case when l_da_count > 0 then true else false end)',
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
'        feature.put(''geometry'', json_element_t.parse(sdo_util.to_geojson(geometry)));',
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
,p_api_version=>2
,p_render_function=>'mapbits_lodestarlayer'
,p_ajax_function=>'mapbits_lodestarlayer_ajax'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits Lodestar Layer plugin provides an alternative map layer to Apex''s built-in layers. It includes advanced configuration options that expose the full power of MapLibre styling and labeling capability.'
,p_version_identifier=>'4.6.20231204'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Lodestar Layer',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_lodestar.sql 18797 2023-12-18 20:39:33Z b2eddjw9 $',
'Date     : $Date: 2023-12-18 14:39:33 -0600 (Mon, 18 Dec 2023) $',
'Revision : $Revision: 18797 $',
'Requires : Application Express >= 22.2',
'',
'Version 4.6 Updates:',
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
,p_files_version=>664
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(512595764362266663)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
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
 p_id=>wwv_flow_imp.id(512629134576649538)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Source Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(514403478821539567)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'query'
,p_examples=>'select shape, usace_district_id from mb4_usace_districts'
,p_help_text=>'Source query used to define the layer. At a minimum this must include an SDOGeometry column. Additional attributes should include a unique identifier column if labeling features or interaction with features is required. Any additional attributes that'
||' are included in the query can be used for constructing labels or other MapLibre attribute operations.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(512609830608357857)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Geometry Column'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_help_text=>'Column from the source query that represents the geometry as SDOGeometry objects.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(512624935703551747)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'MapLibre Layer Definition'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(515186249294674415)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'custom'
,p_help_text=>'A MapLibre layer definition. Can either be a JavaScript expression or a function that takes no arguments and returns the layer definition. See https://maplibre.org/maplibre-style-spec/layers/ for documentation.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(515142042697316221)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Icon'
,p_attribute_type=>'ICON'
,p_is_required=>false
,p_default_value=>'fa-map-marker'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(515186249294674415)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'symbol,custom'
,p_examples=>'fa-circle'
,p_help_text=>'Font-Apex icon used to symbolize features for a ''Symbol'' layer type. For a ''Custom'' layer type, this icon is only shown in the Legend.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(512900860005824345)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
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
 p_id=>wwv_flow_imp.id(513856140089011512)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
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
'}'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Additional options for the GeoJSON source in MapLibre.',
'',
'See <https://maplibre.org/maplibre-style-spec/sources/#geojson> for a full list of accepted attributes.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(514403478821539567)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
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
 p_id=>wwv_flow_imp.id(514404027015540364)
,p_plugin_attribute_id=>wwv_flow_imp.id(514403478821539567)
,p_display_sequence=>10
,p_display_value=>'SQL Query'
,p_return_value=>'query'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(514404495914541475)
,p_plugin_attribute_id=>wwv_flow_imp.id(514403478821539567)
,p_display_sequence=>20
,p_display_value=>'Region Source'
,p_return_value=>'region_source'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(515070547856951355)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>25
,p_prompt=>'Id Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Column from the source query that uniquely identifies the rows in the query. This is usually the primary key column.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(515186249294674415)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
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
 p_id=>wwv_flow_imp.id(515187348632677237)
,p_plugin_attribute_id=>wwv_flow_imp.id(515186249294674415)
,p_display_sequence=>10
,p_display_value=>'Symbol'
,p_return_value=>'symbol'
,p_is_quick_pick=>true
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(515188682471684167)
,p_plugin_attribute_id=>wwv_flow_imp.id(515186249294674415)
,p_display_sequence=>20
,p_display_value=>'Line'
,p_return_value=>'line'
,p_is_quick_pick=>true
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(515189058234684786)
,p_plugin_attribute_id=>wwv_flow_imp.id(515186249294674415)
,p_display_sequence=>30
,p_display_value=>'Fill'
,p_return_value=>'fill'
,p_is_quick_pick=>true
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(515189732413691348)
,p_plugin_attribute_id=>wwv_flow_imp.id(515186249294674415)
,p_display_sequence=>40
,p_display_value=>'Custom'
,p_return_value=>'custom'
,p_is_quick_pick=>true
,p_help_text=>'Define a layer using a raw MapLibre layer definition. Mapbits will still provide some default settings.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(515192918649722144)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Label Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(515186249294674415)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'symbol,line'
,p_help_text=>'Column used to label features.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(518971669041737711)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>47
,p_prompt=>'Opacity'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'1'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(515186249294674415)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'custom'
,p_help_text=>'A number between 0.0 and 1.0 that defines the opacity of the features, where 0.0 is completely transparent and 1.0 is completely opaque. Note that opacity is applied to individual features, not the layer as a whole.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(477960293237730582)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>48
,p_prompt=>'Outline Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#000000'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(515186249294674415)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'fill'
,p_help_text=>'The outline color of the polygons.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(327958201218029272)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>21
,p_prompt=>'Page Items To Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(478062040832464491)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
,p_name=>'click'
,p_display_name=>'Feature Clicked'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E737420494D4147455F48414E444C45525F41444445443D53796D626F6C28293B66756E6374696F6E206D6170626974735F6C6F6465737461726C617965725F6572726F72287B6572726F723A657D297B617065782E6D6573736167652E73686F77';
wwv_flow_imp.g_varchar2_table(2) := '4572726F7273285B7B747970653A226572726F72222C6C6F636174696F6E3A2270616765222C6D6573736167653A657D5D297D66756E6374696F6E206D6170626974735F6C6F6465737461726C61796572287B6974656D49643A652C616A61784964656E';
wwv_flow_imp.g_varchar2_table(3) := '7469666965723A742C726567696F6E49643A612C6C61796572547970653A6F2C6C6162656C436F6C756D6E3A692C6C61796572446566696E6974696F6E3A6E2C73657175656E63654E756D6265723A722C7469746C653A6C2C636F6C6F723A732C6F7061';
wwv_flow_imp.g_varchar2_table(4) := '636974793A632C6F75746C696E65436F6C6F723A642C69636F6E3A702C736F757263654F7074696F6E733A792C6964436F6C756D6E3A752C636C69636B61626C653A672C7375626D69744974656D733A667D297B69662821612972657475726E20766F69';
wwv_flow_imp.g_varchar2_table(5) := '6420617065782E64656275672E6572726F7228226D6170626974735F6C6F6465737461726C6179657220222B652B22203A204974656D206973206E6F7420696E206120726567696F6E2E22293B636F6E7374206D3D652B222D736F75726365223B6C6574';
wwv_flow_imp.g_varchar2_table(6) := '20623D617065782E73746F726167652E676574436F6F6B696528224D6170626974735F4C6F6465737461724C617965725F222B652B225F222B2476282270496E7374616E63652229293B76617220682C5F3D6E756C6C3B6C657420783D653D3E7B623D65';
wwv_flow_imp.g_varchar2_table(7) := '7D3B636F6E737420763D6E6577206D6170626974735F74696E79736466287B666F6E7453697A653A31362C666F6E7446616D696C793A22466F6E74204150455820536D616C6C227D292C773D6E65772050726F6D697365282828742C6F293D3E7B636F6E';
wwv_flow_imp.g_varchar2_table(8) := '737420693D617065782E726567696F6E2861293B6966286E756C6C3D3D692972657475726E20617065782E64656275672E6572726F7228226D6170626974735F6C6F6465737461726C6179657220222B652B22203A20526567696F6E205B222B612B225D';
wwv_flow_imp.g_varchar2_table(9) := '2069732068696464656E206F72206D697373696E672E22292C766F6964206F28293B692E656C656D656E742E6F6E28227370617469616C6D6170696E697469616C697A6564222C2828293D3E7B636F6E737420653D617065782E726567696F6E2861292E';
wwv_flow_imp.g_varchar2_table(10) := '63616C6C28226765744D61704F626A65637422293B742865297D29297D29292E7468656E2828743D3E28745B494D4147455F48414E444C45525F41444445445D7C7C28742E6F6E28227374796C65696D6167656D697373696E67222C28653D3E7B696628';
wwv_flow_imp.g_varchar2_table(11) := '21742E686173496D61676528652E6964292626652E69642E73746172747357697468282266612D2229297B636F6E737420613D646F63756D656E742E637265617465456C656D656E7428227370616E22293B612E7374796C652E646973706C61793D226E';
wwv_flow_imp.g_varchar2_table(12) := '6F6E65222C612E636C6173734C6973742E6164642822666122292C612E636C6173734C6973742E61646428652E6964292C742E676574436F6E7461696E657228292E617070656E644368696C642861293B636F6E7374206F3D77696E646F772E67657443';
wwv_flow_imp.g_varchar2_table(13) := '6F6D70757465645374796C6528612C223A6265666F726522292E636F6E74656E742E737562737472696E6728312C32293B612E72656D6F766528293B636F6E737420693D762E64726177286F292C6E3D6E65772055696E7438417272617928692E776964';
wwv_flow_imp.g_varchar2_table(14) := '74682A692E6865696768742A34293B666F72286C657420653D303B653C692E646174612E6C656E6774683B652B2B296E5B342A652B335D3D692E646174615B655D3B742E616464496D61676528652E69642C7B646174613A6E2C77696474683A692E7769';
wwv_flow_imp.g_varchar2_table(15) := '6474682C6865696768743A692E6865696768747D2C7B7364663A21307D297D7D29292C742E6F6E28226572726F72222C28653D3E7B617065782E64656275672E6572726F7228604D6170206572726F7220696E20726567696F6E20247B617D3A20602C65';
wwv_flow_imp.g_varchar2_table(16) := '2E6572726F72297D29292C745B494D4147455F48414E444C45525F41444445445D3D2130292C6E65772050726F6D6973652828286F2C69293D3E7B766172206E3D736574496E74657276616C282866756E6374696F6E28297B636F6E737420693D617065';
wwv_flow_imp.g_varchar2_table(17) := '782E6A5175657279282223222B612B225F6C6567656E6422293B69262628636C656172496E74657276616C286E292C617065782E6A517565727928273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170';
wwv_flow_imp.g_varchar2_table(18) := '526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E3C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B656422206368';
wwv_flow_imp.g_varchar2_table(19) := '65636B65643D22222069643D22272B652B275F6C6567656E645F656E74727922207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B732B27223E3C6C6162656C20636C6173733D22612D4D617052656769';
wwv_flow_imp.g_varchar2_table(20) := '6F6E2D6C6567656E644C6162656C222069643D22272B652B275F6C6567656E645F656E7472795F6C6162656C2220666F723D22272B652B275F6C6567656E645F656E747279223E272B286C7C7C65292B273C696D672069643D22272B652B275F6C656765';
wwv_flow_imp.g_varchar2_table(21) := '6E645F656E7472795F737461747573222F3E3C2F6C6162656C3E3C2F6469763E27292E617070656E64546F2869292C6F287429297D292C353030297D29292929293B6173796E632066756E6374696F6E206B28297B69662821682972657475726E3B636F';
wwv_flow_imp.g_varchar2_table(22) := '6E737420743D617761697420772C613D7B2E2E2E682C66656174757265733A682E66656174757265732E6D61702828653D3E287B2E2E2E652C70726F706572746965733A7B2E2E2E652E70726F706572746965732C226D6170626974732D73656C656374';
wwv_flow_imp.g_varchar2_table(23) := '6564223A5F2626652E696426265F2E68617328652E69642E746F537472696E672829297D7D2929297D3B696628742E676574536F75726365286D2929742E676574536F75726365286D292E736574446174612861293B656C73657B636F6E7374206F3D7B';
wwv_flow_imp.g_varchar2_table(24) := '2E2E2E792C747970653A2267656F6A736F6E222C646174613A617D3B6F2E636C75737465722626286F2E636C757374657250726F706572746965733D7B226D6170626974732D73656C6563746564223A5B22616E79222C5B22676574222C226D61706269';
wwv_flow_imp.g_varchar2_table(25) := '74732D73656C6563746564225D5D2C2E2E2E6F2E636C757374657250726F706572746965737D293B7472797B742E616464536F75726365286D2C6F297D63617463682874297B617065782E64656275672E6572726F7228606D6170626974735F6C6F6465';
wwv_flow_imp.g_varchar2_table(26) := '737461726C6179657220247B657D203A204661696C656420746F206164642047656F4A534F4E20736F75726365602C74297D7D7D76617220493D21313B6173796E632066756E6374696F6E205328297B617761697420617065782E7365727665722E706C';
wwv_flow_imp.g_varchar2_table(27) := '7567696E28742C7B706167654974656D733A663F662E73706C697428222C22293A766F696420307D2C7B737563636573733A6173796E6320743D3E7B636F6E737420613D617761697420773B696628683D742C6177616974206B28292C2149297B766172';
wwv_flow_imp.g_varchar2_table(28) := '206C3B73776974636828493D21302C6F297B636173652273796D626F6C223A6C3D7B747970653A2273796D626F6C222C6C61796F75743A7B7D7D2C692626286C2E6C61796F75745B22746578742D6669656C64225D3D5B2263617365222C5B2268617322';
wwv_flow_imp.g_varchar2_table(29) := '2C22706F696E745F636F756E74225D2C5B22636F6E636174222C5B22676574222C22706F696E745F636F756E74225D2C22206665617475726573225D2C5B22676574222C695D5D292C702626286C2E6C61796F75745B2269636F6E2D696D616765225D3D';
wwv_flow_imp.g_varchar2_table(30) := '70293B627265616B3B63617365226C696E65223A6C3D5B7B69643A2273656C656374696F6E222C747970653A226C696E65222C66696C7465723A5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C6C61796F75';
wwv_flow_imp.g_varchar2_table(31) := '743A7B7D2C7061696E743A7B226C696E652D7769647468223A332C226C696E652D636F6C6F72223A2223303566616464227D7D2C7B747970653A226C696E65222C6C61796F75743A7B7D2C7061696E743A7B7D7D5D2C6926266C2E70757368287B69643A';
wwv_flow_imp.g_varchar2_table(32) := '226C6162656C222C747970653A2273796D626F6C222C6C61796F75743A7B22746578742D6669656C64223A5B22676574222C695D2C2273796D626F6C2D706C6163656D656E74223A226C696E65227D7D293B627265616B3B636173652266696C6C223A6C';
wwv_flow_imp.g_varchar2_table(33) := '3D5B7B747970653A2266696C6C222C6C61796F75743A7B7D2C7061696E743A7B7D7D2C7B69643A2273656C656374696F6E222C747970653A226C696E65222C66696C7465723A5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564';
wwv_flow_imp.g_varchar2_table(34) := '225D2C21305D2C6C61796F75743A7B7D2C7061696E743A7B226C696E652D7769647468223A332C226C696E652D636F6C6F72223A2223303566616464227D7D5D3B627265616B3B64656661756C743A6C3D6E7D6E756C6C3D3D3D6C2626286C3D7B7D292C';
wwv_flow_imp.g_varchar2_table(35) := '2266756E6374696F6E223D3D747970656F66206C2626286C3D6C2829292C41727261792E69734172726179286C297C7C286C3D5B6C5D293B636F6E737420743D6C2E6D6170282828742C61293D3E7B636F6E7374206F3D7B2E2E2E742C69643A742E6964';
wwv_flow_imp.g_varchar2_table(36) := '3F652B222D222B742E69643A652B222D222B612C736F757263653A6D2C6C61796F75743A7B2E2E2E742E6C61796F75747D2C7061696E743A7B2E2E2E742E7061696E747D2C6D657461646174613A7B6C617965725F73657175656E63653A722C2E2E2E74';
wwv_flow_imp.g_varchar2_table(37) := '2E6D657461646174617D7D3B72657475726E2273796D626F6C223D3D3D6F2E747970653F286F2E6C61796F75745B22746578742D6669656C64225D2626286F2E7061696E745B22746578742D636F6C6F72225D3F3F3D732C6F2E7061696E745B22746578';
wwv_flow_imp.g_varchar2_table(38) := '742D6F706163697479225D3F3F3D632C6F2E6C61796F75745B22746578742D666F6E74225D3F3F3D5B224D6574726F706F6C697320526567756C6172222C224E6F746F2053616E7320526567756C6172225D2C6F2E6C61796F75745B22746578742D7369';
wwv_flow_imp.g_varchar2_table(39) := '7A65225D3F3F3D31322C6F2E7061696E745B22746578742D68616C6F2D7769647468225D3F3F3D312E352C6F2E7061696E745B22746578742D68616C6F2D636F6C6F72225D3F3F3D5B2263617365222C5B223D3D222C5B22676574222C226D6170626974';
wwv_flow_imp.g_varchar2_table(40) := '732D73656C6563746564225D2C21305D2C2223303566616464222C2223636363225D2C6F2E6C61796F75745B22746578742D6A757374696679225D3F3F3D226175746F222C6F2E6C61796F75745B2269636F6E2D696D616765225D2626286F2E6C61796F';
wwv_flow_imp.g_varchar2_table(41) := '75745B22746578742D6F6666736574225D3F3F3D5B302C2E355D2C6F2E6C61796F75745B22746578742D616E63686F72225D7C7C6F2E6C61796F75745B22746578742D7661726961626C652D616E63686F72225D7C7C286F2E6C61796F75745B22746578';
wwv_flow_imp.g_varchar2_table(42) := '742D7661726961626C652D616E63686F72225D3D5B22746F70222C226C656674222C22746F702D6C656674225D2929292C6F2E6C61796F75745B2269636F6E2D696D616765225D3F286F2E6C61796F75745B2269636F6E2D616C6C6F772D6F7665726C61';
wwv_flow_imp.g_varchar2_table(43) := '70225D3F3F3D21302C6F2E6C61796F75745B22746578742D6F7074696F6E616C225D3F3F3D21302C6F2E7061696E745B2269636F6E2D636F6C6F72225D3F3F3D732C6F2E7061696E745B2269636F6E2D6F706163697479225D3F3F3D632C6F2E7061696E';
wwv_flow_imp.g_varchar2_table(44) := '745B2269636F6E2D68616C6F2D7769647468225D3F3F3D5B2263617365222C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C322C305D2C6F2E7061696E745B2269636F6E2D68616C6F2D636F6C6F72225D3F';
wwv_flow_imp.g_varchar2_table(45) := '3F3D5B2263617365222C5B223D3D222C5B22676574222C226D6170626974732D73656C6563746564225D2C21305D2C2223303566616464222C227472616E73706172656E74225D293A6F2E6C61796F75745B22746578742D616C6C6F772D6F7665726C61';
wwv_flow_imp.g_varchar2_table(46) := '70225D3F3F3D2130293A226C696E65223D3D3D6F2E747970653F286F2E7061696E745B226C696E652D636F6C6F72225D3F3F3D732C6F2E7061696E745B226C696E652D6F706163697479225D3F3F3D63293A2266696C6C223D3D3D6F2E74797065262628';
wwv_flow_imp.g_varchar2_table(47) := '6F2E7061696E745B2266696C6C2D636F6C6F72225D3F3F3D732C6F2E7061696E745B2266696C6C2D6F706163697479225D3F3F3D632C6F2E7061696E745B2266696C6C2D6F75746C696E652D636F6C6F72225D3F3F3D647C7C22626C61636B22292C6F7D';
wwv_flow_imp.g_varchar2_table(48) := '29292C663D612E6765745374796C6528292E6C61796572732E66696C7465722828653D3E226D6574616461746122696E20652626226C617965725F73657175656E636522696E20652E6D6574616461746129292E6D6170282866756E6374696F6E286529';
wwv_flow_imp.g_varchar2_table(49) := '7B72657475726E5B652E6D657461646174612E6C617965725F73657175656E63652C652E69645D7D29293B76617220793B69662830213D3D662E6C656E677468297B662E736F7274282828652C74293D3E655B305D2D745B305D29293B666F7228766172';
wwv_flow_imp.g_varchar2_table(50) := '20753D303B753C662E6C656E6774683B752B2B29696628723C665B755D5B305D297B793D665B755D5B315D3B627265616B7D7D666F7228636F6E7374206F206F662074297472797B612E6164644C61796572286F2C79292C67262628612E6F6E28226D6F';
wwv_flow_imp.g_varchar2_table(51) := '757365656E746572222C6F2E69642C2828293D3E7B612E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F723D22706F696E746572227D29292C612E6F6E28226D6F7573656C65617665222C6F2E69642C2828293D3E7B61';
wwv_flow_imp.g_varchar2_table(52) := '2E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F723D2267726162227D29292C612E6F6E2822636C69636B222C6F2E69642C28743D3E7B617065782E6576656E742E74726967676572282223222B652C22636C69636B22';
wwv_flow_imp.g_varchar2_table(53) := '2C7B666561747572653A742E66656174757265735B305D2C6973546F706D6F73744C617965723A612E717565727952656E6465726564466561747572657328742E706F696E74295B305D2E6C617965722E69643D3D3D742E66656174757265735B305D2E';
wwv_flow_imp.g_varchar2_table(54) := '6C617965722E69647D297D2929297D63617463682874297B617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B657D203A204661696C656420746F20616464206C6179657220247B6F2E69647D602C';
wwv_flow_imp.g_varchar2_table(55) := '74297D783D6F3D3E7B666F7228636F6E73742065206F66207429612E7365744C61796F757450726F706572747928652E69642C227669736962696C697479222C6F293B617065782E73746F726167652E736574436F6F6B696528224D6170626974735F4C';
wwv_flow_imp.g_varchar2_table(56) := '6F6465737461724C617965725F222B652B225F222B2476282270496E7374616E636522292C6F292C623D6F7D2C226E6F6E65223D3D623F287828226E6F6E6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E7472792229';
wwv_flow_imp.g_varchar2_table(57) := '2E70726F702822636865636B6564222C213129293A2878282276697369626C6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213029292C617065782E6A51756572';
wwv_flow_imp.g_varchar2_table(58) := '79282223222B652B225F6C6567656E645F656E74727922292E6368616E6765282866756E6374696F6E2865297B76617220743D617065782E6A51756572792874686973293B7828742E697328223A636865636B656422293F2276697369626C65223A226E';
wwv_flow_imp.g_varchar2_table(59) := '6F6E6522297D29297D7D7D297D5328293B6C657420443D21303B617065782E6A51756572792822626F647922292E6F6E2822617065786265666F726572656672657368222C286173796E6320653D3E7B652E7461726765743D3D3D617065782E72656769';
wwv_flow_imp.g_varchar2_table(60) := '6F6E2861292E656C656D656E745B305D262628443F443D21313A617761697420532829297D29292C617065782E6974656D2E63726561746528652C7B726566726573683A6173796E6328293D3E7B6177616974205328297D2C73686F773A28293D3E7B78';
wwv_flow_imp.g_varchar2_table(61) := '282276697369626C6522297D2C686964653A28293D3E7B7828226E6F6E6522297D2C697356697369626C653A28293D3E226E6F6E6522213D3D622C6861734944436F6C756D6E3A28293D3E2121752C73657453656C656374656446656174757265733A28';
wwv_flow_imp.g_varchar2_table(62) := '652C74293D3E7B73776974636828653D653F3F5B5D2C74297B6361736522736574223A5F3D6E6577205365742865293B627265616B3B6361736522616464223A5F3F3F3D6E6577205365743B666F7228636F6E73742074206F662065295F2E6164642874';
wwv_flow_imp.g_varchar2_table(63) := '293B627265616B3B636173652272656D6F7665223A6966285F29666F7228636F6E73742074206F662065295F2E64656C6574652874297D6B28297D2C73656C656374416C6C46656174757265733A28293D3E7B682626285F3D6E65772053657428682E66';
wwv_flow_imp.g_varchar2_table(64) := '656174757265732E6D61702828653D3E652E69642E746F537472696E6728292929292C6B2829297D7D297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(178761423441618411)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
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
wwv_flow_imp.g_varchar2_table(3) := '207D0D0A20205D293B0D0A7D0D0A0D0A0D0A66756E6374696F6E206D6170626974735F6C6F6465737461726C61796572287B0D0A20206974656D49642C20616A61784964656E7469666965722C20726567696F6E49642C206C61796572547970652C206C';
wwv_flow_imp.g_varchar2_table(4) := '6162656C436F6C756D6E2C206C61796572446566696E6974696F6E2C2073657175656E63654E756D6265722C207469746C652C20636F6C6F722C206F7061636974792C206F75746C696E65436F6C6F722C2069636F6E2C0D0A2020736F757263654F7074';
wwv_flow_imp.g_varchar2_table(5) := '696F6E732C206964436F6C756D6E2C20636C69636B61626C652C207375626D69744974656D730D0A7D29207B0D0A20206966202821726567696F6E496429207B0D0A20202020617065782E64656275672E6572726F7228276D6170626974735F6C6F6465';
wwv_flow_imp.g_varchar2_table(6) := '737461726C617965722027202B206974656D4964202B2027203A204974656D206973206E6F7420696E206120726567696F6E2E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A2020636F6E737420736F757263654E616D65203D20697465';
wwv_flow_imp.g_varchar2_table(7) := '6D4964202B20272D736F75726365273B0D0A0D0A20206C6574206C61796572735669736962696C697479203D20617065782E73746F726167652E676574436F6F6B696528274D6170626974735F4C6F6465737461724C617965725F27202B206974656D49';
wwv_flow_imp.g_varchar2_table(8) := '64202B20275F27202B202476282770496E7374616E63652729293B0D0A0D0A20207661722067656F6A736F6E446174613B0D0A20207661722073656C65637465644665617475726573203D206E756C6C3B0D0A0D0A20206C6574207365744C6179657273';
wwv_flow_imp.g_varchar2_table(9) := '5669736962696C697479203D20287669736962696C69747929203D3E207B0D0A202020206C61796572735669736962696C697479203D207669736962696C6974793B0D0A20207D3B0D0A0D0A2020636F6E73742074696E79736466203D206E6577206D61';
wwv_flow_imp.g_varchar2_table(10) := '70626974735F74696E79736466287B0D0A20202020666F6E7453697A653A2031362C0D0A20202020666F6E7446616D696C793A2027466F6E74204150455820536D616C6C272C0D0A20207D293B0D0A0D0A2020636F6E73742070656E64696E674D617020';
wwv_flow_imp.g_varchar2_table(11) := '3D206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020636F6E737420726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0D0A2020202069662028726567696F6E203D3D206E75';
wwv_flow_imp.g_varchar2_table(12) := '6C6C29207B0D0A202020202020617065782E64656275672E6572726F7228276D6170626974735F6C6F6465737461726C617965722027202B206974656D4964202B2027203A20526567696F6E205B27202B20726567696F6E4964202B20275D2069732068';
wwv_flow_imp.g_varchar2_table(13) := '696464656E206F72206D697373696E672E27293B0D0A20202020202072656A65637428293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20202020726567696F6E2E656C656D656E742E6F6E28277370617469616C6D6170696E6974';
wwv_flow_imp.g_varchar2_table(14) := '69616C697A6564272C202829203D3E207B0D0A202020202020636F6E7374206D6170203D20617065782E726567696F6E28726567696F6E4964292E63616C6C28276765744D61704F626A65637427293B0D0A2020202020207265736F6C7665286D617029';
wwv_flow_imp.g_varchar2_table(15) := '3B0D0A202020207D293B0D0A20207D292E7468656E28286D617029203D3E207B0D0A2020202069662028216D61705B494D4147455F48414E444C45525F41444445445D29207B0D0A2020202020206D61702E6F6E28277374796C65696D6167656D697373';
wwv_flow_imp.g_varchar2_table(16) := '696E67272C2028657629203D3E207B0D0A2020202020202020696620286D61702E686173496D6167652865762E69642929207B0D0A2020202020202020202072657475726E3B0D0A20202020202020207D0D0A0D0A20202020202020206966202865762E';
wwv_flow_imp.g_varchar2_table(17) := '69642E73746172747357697468282766612D272929207B0D0A202020202020202020202F2A20466967757265206F757420776861742063686172616374657220746869732069636F6E2075736573202A2F0D0A20202020202020202020636F6E73742073';
wwv_flow_imp.g_varchar2_table(18) := '70616E203D20646F63756D656E742E637265617465456C656D656E7428277370616E27293B0D0A202020202020202020207370616E2E7374796C652E646973706C6179203D20276E6F6E65273B0D0A202020202020202020207370616E2E636C6173734C';
wwv_flow_imp.g_varchar2_table(19) := '6973742E6164642827666127293B0D0A202020202020202020207370616E2E636C6173734C6973742E6164642865762E6964293B0D0A202020202020202020202F2A2041646420746865207370616E20746F2074686520444F4D20736F20697473207374';
wwv_flow_imp.g_varchar2_table(20) := '796C65732063616E20626520636F6D7075746564202A2F0D0A202020202020202020206D61702E676574436F6E7461696E657228292E617070656E644368696C64287370616E293B0D0A202020202020202020202F2A20476574207468652069636F6E20';
wwv_flow_imp.g_varchar2_table(21) := '636861726163746572202A2F0D0A20202020202020202020636F6E737420636F6D70757465645374796C65203D2077696E646F772E676574436F6D70757465645374796C65287370616E2C20273A6265666F726527293B0D0A2020202020202020202063';
wwv_flow_imp.g_varchar2_table(22) := '6F6E73742069636F6E43686172203D20636F6D70757465645374796C652E636F6E74656E742E737562737472696E6728312C2032293B0D0A202020202020202020207370616E2E72656D6F766528293B0D0A0D0A20202020202020202020636F6E737420';
wwv_flow_imp.g_varchar2_table(23) := '676C797068203D2074696E797364662E647261772869636F6E43686172293B0D0A202020202020202020202F2A2041646420524742206368616E6E656C73202A2F0D0A20202020202020202020636F6E7374207267626144617461203D206E6577205569';
wwv_flow_imp.g_varchar2_table(24) := '6E7438417272617928676C7970682E7769647468202A20676C7970682E686569676874202A2034293B0D0A20202020202020202020666F7220286C65742069203D20303B2069203C20676C7970682E646174612E6C656E6774683B2069202B2B29207B0D';
wwv_flow_imp.g_varchar2_table(25) := '0A20202020202020202020202072676261446174615B69202A2034202B20335D203D20676C7970682E646174615B695D3B0D0A202020202020202020207D0D0A202020202020202020206D61702E616464496D6167652865762E69642C207B2064617461';
wwv_flow_imp.g_varchar2_table(26) := '3A2072676261446174612C2077696474683A20676C7970682E77696474682C206865696768743A20676C7970682E686569676874207D2C207B7364663A20747275657D293B0D0A20202020202020207D0D0A2020202020207D293B0D0A0D0A2020202020';
wwv_flow_imp.g_varchar2_table(27) := '206D61702E6F6E28276572726F72272C2028657629203D3E207B0D0A2020202020202020617065782E64656275672E6572726F7228604D6170206572726F7220696E20726567696F6E20247B726567696F6E49647D3A20602C2065762E6572726F72293B';
wwv_flow_imp.g_varchar2_table(28) := '0D0A2020202020207D293B0D0A0D0A2020202020206D61705B494D4147455F48414E444C45525F41444445445D203D20747275653B0D0A202020207D0D0A0D0A202020202F2F205761697420666F7220746865206C6567656E6420746F206C6F61640D0A';
wwv_flow_imp.g_varchar2_table(29) := '2020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A20202020202076617220696E74657276616C203D20736574496E74657276616C2866756E6374696F6E2829207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(30) := '2020636F6E7374206C6567656E64203D20617065782E6A517565727928272327202B20726567696F6E4964202B20275F6C6567656E6427293B0D0A202020202020202069662028216C6567656E6429207B0D0A2020202020202020202072657475726E3B';
wwv_flow_imp.g_varchar2_table(31) := '0D0A20202020202020207D0D0A0D0A2020202020202F2F205468697320636F64652077617320737570706F73656420746F20656E7375726520746865204C6F646573746172206C617965727320616C77617973206170706561722061626F766520746865';
wwv_flow_imp.g_varchar2_table(32) := '204F7261636C65206F6E65732C0D0A2020202020202F2F206275742069742063617573656420746865204C6F646573746172206C617965727320746F206E65766572206C6F616420696620746865204F7261636C65206F6E65732061726520656D707479';
wwv_flow_imp.g_varchar2_table(33) := '2E0D0A2020202020202F2F202020636F6E737420726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0D0A2020202020202F2F202020666F722028636F6E7374206275696C74696E4C61796572206F6620726567696F6E2E6765';
wwv_flow_imp.g_varchar2_table(34) := '744C6179657273282929207B0D0A2020202020202F2F202020202069662028216D61702E6765744C61796572286275696C74696E4C617965722E6964202B2027272929207B0D0A2020202020202F2F20202020202020636F6E736F6C652E6C6F67286042';
wwv_flow_imp.g_varchar2_table(35) := '75696C742D696E206C6179657273206E6F74206C6F61646564207965742C207374696C6C206D697373696E6720247B6275696C74696E4C617965722E69647D2E2E2E60293B0D0A2020202020202F2F2020202020202072657475726E3B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(36) := '202F2F20202020207D0D0A2020202020202F2F2020207D0D0A0D0A2020202020202020636C656172496E74657276616C28696E74657276616C293B0D0A0D0A2020202020202020617065782E6A517565727928273C64697620636C6173733D22612D4D61';
wwv_flow_imp.g_varchar2_table(37) := '70526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E27202B200D0A20202020202020202020273C696E70757420747970653D22636865636B626F782220636C6173733D22';
wwv_flow_imp.g_varchar2_table(38) := '612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069643D2227202B206974656D4964202B20275F6C6567656E645F656E74727927202B202722207374796C653D222D2D612D6D';
wwv_flow_imp.g_varchar2_table(39) := '61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B20636F6C6F72202B2027223E27202B0D0A20202020202020202020273C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C222069643D222720';
wwv_flow_imp.g_varchar2_table(40) := '2B206974656D4964202B20275F6C6567656E645F656E7472795F6C6162656C27202B20272220666F723D2227202B206974656D4964202B20275F6C6567656E645F656E74727927202B2027223E27202B20287469746C65207C7C206974656D496429202B';
wwv_flow_imp.g_varchar2_table(41) := '20273C696D672069643D2227202B206974656D4964202B20275F6C6567656E645F656E7472795F737461747573222F3E3C2F6C6162656C3E27202B0D0A20202020202020202020273C2F6469763E27292E617070656E64546F286C6567656E64293B0D0A';
wwv_flow_imp.g_varchar2_table(42) := '0D0A20202020202020207265736F6C7665286D6170293B0D0A2020202020207D2C20353030293B0D0A202020207D290D0A20207D293B0D0A0D0A20206173796E632066756E6374696F6E2072656C6F6164536F75726365446174612829207B0D0A202020';
wwv_flow_imp.g_varchar2_table(43) := '20696620282167656F6A736F6E4461746129207B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A20202020636F6E7374206D6170203D2061776169742070656E64696E674D61703B0D0A0D0A20202020636F6E7374207265616C446174';
wwv_flow_imp.g_varchar2_table(44) := '61203D207B0D0A2020202020202E2E2E67656F6A736F6E446174612C0D0A20202020202066656174757265733A2067656F6A736F6E446174612E66656174757265732E6D617028286665617475726529203D3E20287B0D0A20202020202020202E2E2E66';
wwv_flow_imp.g_varchar2_table(45) := '6561747572652C0D0A202020202020202070726F706572746965733A207B0D0A202020202020202020202E2E2E666561747572652E70726F706572746965732C0D0A20202020202020202020276D6170626974732D73656C6563746564273A2073656C65';
wwv_flow_imp.g_varchar2_table(46) := '63746564466561747572657320262620666561747572652E69642026262073656C656374656446656174757265732E68617328666561747572652E69642E746F537472696E672829290D0A20202020202020207D0D0A2020202020207D29290D0A202020';
wwv_flow_imp.g_varchar2_table(47) := '207D3B0D0A0D0A20202020696620286D61702E676574536F7572636528736F757263654E616D652929207B0D0A2020202020206D61702E676574536F7572636528736F757263654E616D65292E73657444617461287265616C44617461293B0D0A202020';
wwv_flow_imp.g_varchar2_table(48) := '207D20656C7365207B0D0A202020202020636F6E737420736F757263654F707473203D207B0D0A20202020202020202E2E2E736F757263654F7074696F6E732C0D0A20202020202020202774797065273A202767656F6A736F6E272C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(49) := '20202764617461273A207265616C446174612C0D0A2020202020207D3B0D0A0D0A20202020202069662028736F757263654F7074732E636C757374657229207B0D0A2020202020202020736F757263654F7074732E636C757374657250726F7065727469';
wwv_flow_imp.g_varchar2_table(50) := '6573203D207B0D0A202020202020202020205B276D6170626974732D73656C6563746564275D3A205B27616E79272C205B27676574272C20276D6170626974732D73656C6563746564275D5D2C0D0A202020202020202020202E2E2E736F757263654F70';
wwv_flow_imp.g_varchar2_table(51) := '74732E636C757374657250726F706572746965732C0D0A20202020202020207D0D0A2020202020207D0D0A0D0A202020202020747279207B0D0A20202020202020206D61702E616464536F7572636528736F757263654E616D652C20736F757263654F70';
wwv_flow_imp.g_varchar2_table(52) := '7473293B0D0A2020202020207D2063617463682028657863657074696F6E29207B0D0A2020202020202020617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B6974656D49647D203A204661696C65';
wwv_flow_imp.g_varchar2_table(53) := '6420746F206164642047656F4A534F4E20736F75726365602C20657863657074696F6E293B0D0A2020202020207D0D0A202020207D0D0A20207D3B0D0A0D0A20207661722061646465644C61796572203D2066616C73653B0D0A0D0A20206173796E6320';
wwv_flow_imp.g_varchar2_table(54) := '66756E6374696F6E206C6F6164446174612829207B0D0A20202020617761697420617065782E7365727665722E706C7567696E28616A61784964656E7469666965722C207B706167654974656D733A207375626D69744974656D73203F207375626D6974';
wwv_flow_imp.g_varchar2_table(55) := '4974656D732E73706C697428222C2229203A20756E646566696E65647D2C207B0D0A202020202020737563636573733A206173796E632028726573706F6E736529203D3E207B0D0A2020202020202020636F6E7374206D6170203D206177616974207065';
wwv_flow_imp.g_varchar2_table(56) := '6E64696E674D61703B0D0A0D0A202020202020202067656F6A736F6E44617461203D20726573706F6E73653B0D0A202020202020202061776169742072656C6F6164536F757263654461746128293B0D0A0D0A2020202020202020696620282161646465';
wwv_flow_imp.g_varchar2_table(57) := '644C6179657229207B0D0A2020202020202020202061646465644C61796572203D20747275653B0D0A0D0A20202020202020202020766172206F726967696E616C4C61796572733B0D0A0D0A2020202020202020202073776974636820286C6179657254';
wwv_flow_imp.g_varchar2_table(58) := '79706529207B0D0A20202020202020202020202063617365202773796D626F6C273A0D0A20202020202020202020202020206F726967696E616C4C6179657273203D207B0D0A20202020202020202020202020202020747970653A202773796D626F6C27';
wwv_flow_imp.g_varchar2_table(59) := '2C0D0A202020202020202020202020202020206C61796F75743A207B7D0D0A20202020202020202020202020207D3B0D0A2020202020202020202020202020696620286C6162656C436F6C756D6E2920207B0D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(60) := '6F726967696E616C4C61796572732E6C61796F75745B27746578742D6669656C64275D203D205B0D0A2020202020202020202020202020202020202763617365272C0D0A2020202020202020202020202020202020205B27686173272C2027706F696E74';
wwv_flow_imp.g_varchar2_table(61) := '5F636F756E74275D2C0D0A2020202020202020202020202020202020205B27636F6E636174272C205B27676574272C2027706F696E745F636F756E74275D2C2027206665617475726573275D2C0D0A2020202020202020202020202020202020205B2767';
wwv_flow_imp.g_varchar2_table(62) := '6574272C206C6162656C436F6C756D6E5D0D0A202020202020202020202020202020205D3B0D0A20202020202020202020202020207D0D0A20202020202020202020202020206966202869636F6E29207B0D0A202020202020202020202020202020206F';
wwv_flow_imp.g_varchar2_table(63) := '726967696E616C4C61796572732E6C61796F75745B2769636F6E2D696D616765275D203D2069636F6E3B0D0A20202020202020202020202020207D0D0A2020202020202020202020202020627265616B3B0D0A0D0A202020202020202020202020636173';
wwv_flow_imp.g_varchar2_table(64) := '6520276C696E65273A0D0A20202020202020202020202020206F726967696E616C4C6179657273203D205B0D0A202020202020202020202020202020207B0D0A20202020202020202020202020202020202069643A202773656C656374696F6E272C0D0A';
wwv_flow_imp.g_varchar2_table(65) := '202020202020202020202020202020202020747970653A20276C696E65272C0D0A20202020202020202020202020202020202066696C7465723A205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D';
wwv_flow_imp.g_varchar2_table(66) := '2C0D0A2020202020202020202020202020202020206C61796F75743A207B7D2C0D0A2020202020202020202020202020202020207061696E743A207B0D0A2020202020202020202020202020202020202020276C696E652D7769647468273A20332C0D0A';
wwv_flow_imp.g_varchar2_table(67) := '2020202020202020202020202020202020202020276C696E652D636F6C6F72273A202723303566616464272C0D0A2020202020202020202020202020202020207D2C0D0A202020202020202020202020202020207D2C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(68) := '202020207B0D0A202020202020202020202020202020202020747970653A20276C696E65272C0D0A2020202020202020202020202020202020206C61796F75743A207B7D2C0D0A2020202020202020202020202020202020207061696E743A207B7D2C0D';
wwv_flow_imp.g_varchar2_table(69) := '0A202020202020202020202020202020207D2C0D0A20202020202020202020202020205D3B0D0A0D0A2020202020202020202020202020696620286C6162656C436F6C756D6E29207B0D0A202020202020202020202020202020206F726967696E616C4C';
wwv_flow_imp.g_varchar2_table(70) := '61796572732E70757368287B0D0A20202020202020202020202020202020202069643A20276C6162656C272C0D0A202020202020202020202020202020202020747970653A202773796D626F6C272C0D0A2020202020202020202020202020202020206C';
wwv_flow_imp.g_varchar2_table(71) := '61796F75743A207B0D0A202020202020202020202020202020202020202027746578742D6669656C64273A205B27676574272C206C6162656C436F6C756D6E5D2C0D0A20202020202020202020202020202020202020202773796D626F6C2D706C616365';
wwv_flow_imp.g_varchar2_table(72) := '6D656E74273A20276C696E65272C0D0A2020202020202020202020202020202020207D2C0D0A202020202020202020202020202020207D293B0D0A20202020202020202020202020207D0D0A0D0A2020202020202020202020202020627265616B3B0D0A';
wwv_flow_imp.g_varchar2_table(73) := '0D0A20202020202020202020202063617365202766696C6C273A0D0A20202020202020202020202020206F726967696E616C4C6179657273203D205B0D0A202020202020202020202020202020207B0D0A20202020202020202020202020202020202074';
wwv_flow_imp.g_varchar2_table(74) := '7970653A202766696C6C272C0D0A2020202020202020202020202020202020206C61796F75743A207B7D2C0D0A2020202020202020202020202020202020207061696E743A207B7D2C0D0A202020202020202020202020202020207D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(75) := '20202020202020202020207B0D0A20202020202020202020202020202020202069643A202773656C656374696F6E272C0D0A202020202020202020202020202020202020747970653A20276C696E65272C0D0A2020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(76) := '2066696C7465723A205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A2020202020202020202020202020202020206C61796F75743A207B7D2C0D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(77) := '20207061696E743A207B0D0A2020202020202020202020202020202020202020276C696E652D7769647468273A20332C0D0A2020202020202020202020202020202020202020276C696E652D636F6C6F72273A202723303566616464272C0D0A20202020';
wwv_flow_imp.g_varchar2_table(78) := '20202020202020202020202020207D2C0D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020205D3B0D0A2020202020202020202020202020627265616B3B0D0A0D0A20202020202020202020202064656661756C743A';
wwv_flow_imp.g_varchar2_table(79) := '0D0A20202020202020202020202020206F726967696E616C4C6179657273203D206C61796572446566696E6974696F6E3B0D0A202020202020202020207D0D0A0D0A20202020202020202020696620286F726967696E616C4C6179657273203D3D3D206E';
wwv_flow_imp.g_varchar2_table(80) := '756C6C29207B0D0A2020202020202020202020206F726967696E616C4C6179657273203D207B7D3B0D0A202020202020202020207D0D0A2020202020202020202069662028747970656F66206F726967696E616C4C6179657273203D3D3D202766756E63';
wwv_flow_imp.g_varchar2_table(81) := '74696F6E2729207B0D0A2020202020202020202020206F726967696E616C4C6179657273203D206F726967696E616C4C617965727328293B0D0A202020202020202020207D0D0A20202020202020202020696620282141727261792E6973417272617928';
wwv_flow_imp.g_varchar2_table(82) := '6F726967696E616C4C61796572732929207B0D0A2020202020202020202020206F726967696E616C4C6179657273203D205B6F726967696E616C4C61796572735D3B0D0A202020202020202020207D0D0A0D0A20202020202020202020636F6E7374206C';
wwv_flow_imp.g_varchar2_table(83) := '6179657273203D206F726967696E616C4C61796572732E6D617028286F726967696E616C4C617965722C206929203D3E207B0D0A202020202020202020202020636F6E7374206C61796572203D207B0D0A20202020202020202020202020202E2E2E6F72';
wwv_flow_imp.g_varchar2_table(84) := '6967696E616C4C617965722C0D0A202020202020202020202020202069643A206F726967696E616C4C617965722E6964203F206974656D4964202B20272D27202B206F726967696E616C4C617965722E6964203A206974656D4964202B20272D27202B20';
wwv_flow_imp.g_varchar2_table(85) := '692C0D0A2020202020202020202020202020736F757263653A20736F757263654E616D652C0D0A20202020202020202020202020206C61796F75743A207B0D0A202020202020202020202020202020202E2E2E6F726967696E616C4C617965722E6C6179';
wwv_flow_imp.g_varchar2_table(86) := '6F75742C0D0A20202020202020202020202020207D2C0D0A20202020202020202020202020207061696E743A207B0D0A202020202020202020202020202020202E2E2E6F726967696E616C4C617965722E7061696E742C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(87) := '2020207D2C0D0A20202020202020202020202020206D657461646174613A207B0D0A202020202020202020202020202020206C617965725F73657175656E63653A2073657175656E63654E756D6265722C0D0A202020202020202020202020202020202E';
wwv_flow_imp.g_varchar2_table(88) := '2E2E6F726967696E616C4C617965722E6D657461646174612C0D0A20202020202020202020202020207D0D0A2020202020202020202020207D3B0D0A0D0A202020202020202020202020696620286C617965722E74797065203D3D3D202773796D626F6C';
wwv_flow_imp.g_varchar2_table(89) := '2729207B0D0A2020202020202020202020202020696620286C617965722E6C61796F75745B27746578742D6669656C64275D29207B0D0A202020202020202020202020202020206C617965722E7061696E745B27746578742D636F6C6F72275D203F3F3D';
wwv_flow_imp.g_varchar2_table(90) := '20636F6C6F723B0D0A202020202020202020202020202020206C617965722E7061696E745B27746578742D6F706163697479275D203F3F3D206F7061636974793B0D0A202020202020202020202020202020206C617965722E6C61796F75745B27746578';
wwv_flow_imp.g_varchar2_table(91) := '742D666F6E74275D203F3F3D205B274D6574726F706F6C697320526567756C6172272C20274E6F746F2053616E7320526567756C6172275D3B0D0A202020202020202020202020202020206C617965722E6C61796F75745B27746578742D73697A65275D';
wwv_flow_imp.g_varchar2_table(92) := '203F3F3D2031323B0D0A202020202020202020202020202020206C617965722E7061696E745B27746578742D68616C6F2D7769647468275D203F3F3D20312E353B0D0A202020202020202020202020202020206C617965722E7061696E745B2774657874';
wwv_flow_imp.g_varchar2_table(93) := '2D68616C6F2D636F6C6F72275D203F3F3D205B0D0A2020202020202020202020202020202020202763617365272C0D0A2020202020202020202020202020202020205B273D3D272C205B27676574272C20276D6170626974732D73656C6563746564275D';
wwv_flow_imp.g_varchar2_table(94) := '2C20747275655D2C0D0A2020202020202020202020202020202020202723303566616464272C0D0A2020202020202020202020202020202020202723636363270D0A202020202020202020202020202020205D3B0D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(95) := '20206C617965722E6C61796F75745B27746578742D6A757374696679275D203F3F3D20276175746F273B0D0A0D0A20202020202020202020202020202020696620286C617965722E6C61796F75745B2769636F6E2D696D616765275D29207B0D0A202020';
wwv_flow_imp.g_varchar2_table(96) := '2020202020202020202020202020206C617965722E6C61796F75745B27746578742D6F6666736574275D203F3F3D205B302C20302E355D3B0D0A20202020202020202020202020202020202069662028216C617965722E6C61796F75745B27746578742D';
wwv_flow_imp.g_varchar2_table(97) := '616E63686F72275D20262620216C617965722E6C61796F75745B27746578742D7661726961626C652D616E63686F72275D29207B0D0A20202020202020202020202020202020202020206C617965722E6C61796F75745B27746578742D7661726961626C';
wwv_flow_imp.g_varchar2_table(98) := '652D616E63686F72275D203D205B27746F70272C20276C656674272C2027746F702D6C656674275D3B0D0A2020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A20202020202020202020202020207D0D0A';
wwv_flow_imp.g_varchar2_table(99) := '0D0A2020202020202020202020202020696620286C617965722E6C61796F75745B2769636F6E2D696D616765275D29207B0D0A202020202020202020202020202020206C617965722E6C61796F75745B2769636F6E2D616C6C6F772D6F7665726C617027';
wwv_flow_imp.g_varchar2_table(100) := '5D203F3F3D20747275653B0D0A202020202020202020202020202020206C617965722E6C61796F75745B27746578742D6F7074696F6E616C275D203F3F3D20747275653B0D0A202020202020202020202020202020206C617965722E7061696E745B2769';
wwv_flow_imp.g_varchar2_table(101) := '636F6E2D636F6C6F72275D203F3F3D20636F6C6F723B0D0A202020202020202020202020202020206C617965722E7061696E745B2769636F6E2D6F706163697479275D203F3F3D206F7061636974793B0D0A202020202020202020202020202020206C61';
wwv_flow_imp.g_varchar2_table(102) := '7965722E7061696E745B2769636F6E2D68616C6F2D7769647468275D203F3F3D205B0D0A2020202020202020202020202020202020202763617365272C0D0A2020202020202020202020202020202020205B273D3D272C205B27676574272C20276D6170';
wwv_flow_imp.g_varchar2_table(103) := '626974732D73656C6563746564275D2C20747275655D2C0D0A202020202020202020202020202020202020322C0D0A202020202020202020202020202020202020300D0A202020202020202020202020202020205D3B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(104) := '202020206C617965722E7061696E745B2769636F6E2D68616C6F2D636F6C6F72275D203F3F3D205B0D0A2020202020202020202020202020202020202763617365272C0D0A2020202020202020202020202020202020205B273D3D272C205B2767657427';
wwv_flow_imp.g_varchar2_table(105) := '2C20276D6170626974732D73656C6563746564275D2C20747275655D2C0D0A2020202020202020202020202020202020202723303566616464272C0D0A202020202020202020202020202020202020277472616E73706172656E74270D0A202020202020';
wwv_flow_imp.g_varchar2_table(106) := '202020202020202020205D3B0D0A20202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020206C617965722E6C61796F75745B27746578742D616C6C6F772D6F7665726C6170275D203F3F3D20747275653B0D0A';
wwv_flow_imp.g_varchar2_table(107) := '20202020202020202020202020207D0D0A2020202020202020202020207D20656C736520696620286C617965722E74797065203D3D3D20276C696E652729207B0D0A20202020202020202020202020206C617965722E7061696E745B276C696E652D636F';
wwv_flow_imp.g_varchar2_table(108) := '6C6F72275D203F3F3D20636F6C6F723B0D0A20202020202020202020202020206C617965722E7061696E745B276C696E652D6F706163697479275D203F3F3D206F7061636974793B0D0A2020202020202020202020207D20656C736520696620286C6179';
wwv_flow_imp.g_varchar2_table(109) := '65722E74797065203D3D3D202766696C6C2729207B0D0A20202020202020202020202020206C617965722E7061696E745B2766696C6C2D636F6C6F72275D203F3F3D20636F6C6F723B0D0A20202020202020202020202020206C617965722E7061696E74';
wwv_flow_imp.g_varchar2_table(110) := '5B2766696C6C2D6F706163697479275D203F3F3D206F7061636974793B0D0A20202020202020202020202020206C617965722E7061696E745B2766696C6C2D6F75746C696E652D636F6C6F72275D203F3F3D206F75746C696E65436F6C6F72207C7C2022';
wwv_flow_imp.g_varchar2_table(111) := '626C61636B223B0D0A2020202020202020202020207D0D0A0D0A20202020202020202020202072657475726E206C617965723B0D0A202020202020202020207D293B0D0A0D0A20202020202020202020636F6E7374206D6170626974736C617965727320';
wwv_flow_imp.g_varchar2_table(112) := '3D206D61702E6765745374796C6528292E6C61796572732E66696C746572282876616C29203D3E207B0D0A20202020202020202020202069662028276D657461646174612720696E2076616C29207B200D0A202020202020202020202020202072657475';
wwv_flow_imp.g_varchar2_table(113) := '726E20276C617965725F73657175656E63652720696E2076616C2E6D657461646174613B0D0A2020202020202020202020207D20656C7365207B0D0A202020202020202020202020202072657475726E2066616C73653B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(114) := '207D0D0A202020202020202020207D292E6D61702866756E6374696F6E2876616C29207B72657475726E205B76616C2E6D657461646174612E6C617965725F73657175656E63652C2076616C2E69645D7D293B0D0A202020202020202020207661722062';
wwv_flow_imp.g_varchar2_table(115) := '65666F72654C617965723B0D0A20202020202020202020696620286D6170626974736C61796572732E6C656E67746820213D3D203029207B0D0A2020202020202020202020206D6170626974736C61796572732E736F72742828612C206229203D3E2061';
wwv_flow_imp.g_varchar2_table(116) := '5B305D202D20625B305D293B0D0A202020202020202020202020666F722876617220693D303B693C6D6170626974736C61796572732E6C656E6774683B692B2B29207B0D0A20202020202020202020202020206966202873657175656E63654E756D6265';
wwv_flow_imp.g_varchar2_table(117) := '72203C206D6170626974736C61796572735B695D5B305D29207B0D0A202020202020202020202020202020206265666F72654C61796572203D206D6170626974736C61796572735B695D5B315D3B0D0A2020202020202020202020202020202062726561';
wwv_flow_imp.g_varchar2_table(118) := '6B3B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D0D0A202020202020202020207D0D0A20202020202020202020666F722028636F6E7374206C206F66206C617965727329207B0D0A2020202020202020202020207472';
wwv_flow_imp.g_varchar2_table(119) := '79207B0D0A20202020202020202020202020206D61702E6164644C61796572286C2C206265666F72654C61796572293B0D0A0D0A202020202020202020202020202069662028636C69636B61626C6529207B0D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(120) := '6D61702E6F6E28276D6F757365656E746572272C206C2E69642C202829203D3E207B0D0A2020202020202020202020202020202020206D61702E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F72203D2027706F696E74';
wwv_flow_imp.g_varchar2_table(121) := '6572273B0D0A202020202020202020202020202020207D293B0D0A202020202020202020202020202020206D61702E6F6E28276D6F7573656C65617665272C206C2E69642C202829203D3E207B0D0A2020202020202020202020202020202020206D6170';
wwv_flow_imp.g_varchar2_table(122) := '2E67657443616E766173436F6E7461696E657228292E7374796C652E637572736F72203D202767726162273B0D0A202020202020202020202020202020207D293B0D0A202020202020202020202020202020206D61702E6F6E2827636C69636B272C206C';
wwv_flow_imp.g_varchar2_table(123) := '2E69642C2028657629203D3E207B0D0A202020202020202020202020202020202020617065782E6576656E742E7472696767657228272327202B206974656D49642C2027636C69636B272C207B0D0A202020202020202020202020202020202020202066';
wwv_flow_imp.g_varchar2_table(124) := '6561747572653A2065762E66656174757265735B305D2C0D0A20202020202020202020202020202020202020206973546F706D6F73744C617965723A206D61702E717565727952656E646572656446656174757265732865762E706F696E74295B305D2E';
wwv_flow_imp.g_varchar2_table(125) := '6C617965722E6964203D3D3D2065762E66656174757265735B305D2E6C617965722E69640D0A2020202020202020202020202020202020207D293B0D0A202020202020202020202020202020207D293B0D0A20202020202020202020202020207D0D0A20';
wwv_flow_imp.g_varchar2_table(126) := '20202020202020202020207D2063617463682028657863657074696F6E29207B0D0A2020202020202020202020202020617065782E64656275672E6572726F7228606D6170626974735F6C6F6465737461726C6179657220247B6974656D49647D203A20';
wwv_flow_imp.g_varchar2_table(127) := '4661696C656420746F20616464206C6179657220247B6C2E69647D602C20657863657074696F6E293B0D0A2020202020202020202020207D0D0A202020202020202020207D0D0A0D0A202020202020202020207365744C61796572735669736962696C69';
wwv_flow_imp.g_varchar2_table(128) := '7479203D20287669736962696C69747929203D3E207B0D0A202020202020202020202020666F722028636F6E7374206C61796572206F66206C617965727329207B0D0A20202020202020202020202020206D61702E7365744C61796F757450726F706572';
wwv_flow_imp.g_varchar2_table(129) := '7479286C617965722E69642C20277669736962696C697479272C207669736962696C697479293B0D0A2020202020202020202020207D0D0A202020202020202020202020617065782E73746F726167652E736574436F6F6B696528274D6170626974735F';
wwv_flow_imp.g_varchar2_table(130) := '4C6F6465737461724C617965725F27202B206974656D4964202B20275F27202B202476282770496E7374616E636527292C207669736962696C697479293B0D0A2020202020202020202020206C61796572735669736962696C697479203D207669736962';
wwv_flow_imp.g_varchar2_table(131) := '696C6974793B0D0A202020202020202020207D0D0A0D0A20202020202020202020696620286C61796572735669736962696C697479203D3D20276E6F6E652729207B0D0A2020202020202020202020207365744C61796572735669736962696C69747928';
wwv_flow_imp.g_varchar2_table(132) := '276E6F6E6527293B0D0A202020202020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(133) := '207D20656C7365207B0D0A2020202020202020202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A202020202020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567';
wwv_flow_imp.g_varchar2_table(134) := '656E645F656E74727927292E70726F702827636865636B6564272C2074727565293B0D0A202020202020202020207D0D0A0D0A20202020202020202020617065782E6A517565727928272327202B206974656D4964202B20275F6C6567656E645F656E74';
wwv_flow_imp.g_varchar2_table(135) := '727927292E6368616E67652866756E6374696F6E2865297B0D0A202020202020202020202020766172206362203D20617065782E6A51756572792874686973293B0D0A2020202020202020202020207365744C61796572735669736962696C6974792863';
wwv_flow_imp.g_varchar2_table(136) := '622E697328273A636865636B65642729203F202776697369626C6527203A20276E6F6E6527293B0D0A202020202020202020207D293B0D0A20202020202020207D0D0A2020202020207D0D0A202020207D293B0D0A20207D3B0D0A0D0A20206C6F616444';
wwv_flow_imp.g_varchar2_table(137) := '61746128293B0D0A0D0A20206C657420666972737452656672657368203D20747275653B0D0A2020617065782E6A51756572792827626F647927292E6F6E2827617065786265666F726572656672657368272C206173796E632028657629203D3E207B0D';
wwv_flow_imp.g_varchar2_table(138) := '0A202020206966202865762E746172676574203D3D3D20617065782E726567696F6E28726567696F6E4964292E656C656D656E745B305D29207B0D0A2020202020202F2A20536B69702074686520666972737420617065786265666F7265726566726573';
wwv_flow_imp.g_varchar2_table(139) := '68206576656E742C2073696E6365207468617420636F72726573706F6E647320746F207468652070616765206C6F6164696E672C0D0A20202020202020202062757420776520616C72656164792063616C6C6564206C6F61644461746128292061626F76';
wwv_flow_imp.g_varchar2_table(140) := '6520776974686F75742077616974696E6720666F7220746865206D617020746F206C6F61642E202A2F0D0A202020202020696620282166697273745265667265736829207B0D0A20202020202020206177616974206C6F61644461746128293B0D0A2020';
wwv_flow_imp.g_varchar2_table(141) := '202020207D20656C7365207B0D0A2020202020202020666972737452656672657368203D2066616C73653B0D0A2020202020207D0D0A202020207D0D0A20207D293B0D0A0D0A2020617065782E6974656D2E637265617465280D0A202020206974656D49';
wwv_flow_imp.g_varchar2_table(142) := '642C0D0A202020207B0D0A202020202020726566726573683A206173796E63202829203D3E207B0D0A20202020202020206177616974206C6F61644461746128293B0D0A2020202020207D2C0D0A20202020202073686F773A202829203D3E207B0D0A20';
wwv_flow_imp.g_varchar2_table(143) := '202020202020207365744C61796572735669736962696C697479282776697369626C6527293B0D0A2020202020207D2C0D0A202020202020686964653A202829203D3E207B0D0A20202020202020207365744C61796572735669736962696C6974792827';
wwv_flow_imp.g_varchar2_table(144) := '6E6F6E6527293B0D0A2020202020207D2C0D0A202020202020697356697369626C653A202829203D3E207B0D0A202020202020202072657475726E206C61796572735669736962696C69747920213D3D20276E6F6E65273B0D0A2020202020207D2C0D0A';
wwv_flow_imp.g_varchar2_table(145) := '2020202020206861734944436F6C756D6E3A202829203D3E207B0D0A202020202020202072657475726E2021216964436F6C756D6E3B0D0A2020202020207D2C0D0A2020202020202F2A2053657420746865206C697374206F6620666561747572657320';
wwv_flow_imp.g_varchar2_table(146) := '7468617420686176652061202273656C65637465642220617070656172616E63652E20606665617475726573602069732061206C6973740D0A2020202020202020206F662066656174757265204944732E202A2F0D0A20202020202073657453656C6563';
wwv_flow_imp.g_varchar2_table(147) := '74656446656174757265733A202866656174757265732C20616374696F6E29203D3E207B0D0A20202020202020206665617475726573203D206665617475726573203F3F205B5D3B0D0A20202020202020207377697463682028616374696F6E29207B0D';
wwv_flow_imp.g_varchar2_table(148) := '0A20202020202020202020636173652027736574273A0D0A20202020202020202020202073656C65637465644665617475726573203D206E657720536574286665617475726573293B0D0A202020202020202020202020627265616B3B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(149) := '2020202020636173652027616464273A0D0A20202020202020202020202073656C65637465644665617475726573203F3F3D206E65772053657428293B0D0A202020202020202020202020666F722028636F6E73742066206F6620666561747572657329';
wwv_flow_imp.g_varchar2_table(150) := '207B0D0A202020202020202020202020202073656C656374656446656174757265732E6164642866293B0D0A2020202020202020202020207D0D0A202020202020202020202020627265616B3B0D0A2020202020202020202063617365202772656D6F76';
wwv_flow_imp.g_varchar2_table(151) := '65273A0D0A2020202020202020202020206966202873656C6563746564466561747572657329207B0D0A2020202020202020202020202020666F722028636F6E73742066206F6620666561747572657329207B0D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(152) := '2073656C656374656446656174757265732E64656C6574652866293B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D0D0A202020202020202020202020627265616B3B0D0A20202020202020207D0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(153) := '2072656C6F6164536F757263654461746128293B0D0A2020202020207D2C0D0A2020202020202F2A2053656C6563747320616C6C2066656174757265732063757272656E746C7920696E20746865206C617965722074686174206861766520616E204944';
wwv_flow_imp.g_varchar2_table(154) := '2E202A2F0D0A20202020202073656C656374416C6C46656174757265733A202829203D3E207B0D0A20202020202020206966202867656F6A736F6E4461746129207B0D0A2020202020202020202073656C65637465644665617475726573203D206E6577';
wwv_flow_imp.g_varchar2_table(155) := '205365742867656F6A736F6E446174612E66656174757265732E6D61702866203D3E20662E69642E746F537472696E67282929293B0D0A2020202020202020202072656C6F6164536F757263654461746128293B0D0A20202020202020207D0D0A202020';
wwv_flow_imp.g_varchar2_table(156) := '2020207D0D0A202020207D0D0A2020290D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(512604865661266669)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
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
 p_id=>wwv_flow_imp.id(515050509602626407)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
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
 p_id=>wwv_flow_imp.id(519567149493368854)
,p_plugin_id=>wwv_flow_imp.id(512595521149266662)
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
