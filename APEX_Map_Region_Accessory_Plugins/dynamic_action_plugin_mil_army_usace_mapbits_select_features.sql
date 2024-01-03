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
--   Date and Time:   12:36 Monday December 4, 2023
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 515173877986891639
--   Manifest End
--   Version:         22.2.8
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/mil_army_usace_mapbits_select_features
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(515173877986891639)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MIL.ARMY.USACE.MAPBITS.SELECT_FEATURES'
,p_display_name=>'Mapbits Lodestar Select Features'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-select-features.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function mapbits_select_features (',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin )',
'return apex_plugin.t_dynamic_action_render_result',
'is',
'  affected_page_items varchar2(4000);',
'  l_error varchar2(4000);',
'  l_nlayers integer;',
'  l_action_name varchar2(40);',
'  rt apex_plugin.t_dynamic_action_render_result;',
'  action_type varchar2(100) := p_dynamic_action.attribute_03;',
'begin',
'  ',
'  select affected_elements, dynamic_action_name',
'    into affected_page_items, l_action_name',
'    from apex_application_page_da_acts',
'  where',
'    application_id = v(''APP_ID'')',
'    and page_id = v(''APP_PAGE_ID'')',
'    and action_id = p_dynamic_action.id;',
'  select count(*) into l_nlayers from (select column_value from table(apex_string.split(affected_page_items, '',''))) ai',
'    inner join  apex_application_page_items i on ai.column_value = i.item_name and  i.application_id = v(''APP_ID'') and i.page_id = v(''APP_PAGE_ID'')',
'    and i.display_as_code = ''PLUGIN_MIL.ARMY.USACE.MAPBITS.LAYER.LODESTAR'';    ',
'  if l_nlayers = 0 then',
'    raise_application_error(-20431, ''Configuration ERROR: Mapbits Lodestar Select Feature DA for "'' || l_action_name ||  ''" ['' || p_dynamic_action.id || ''] is not assoicated with a valid Lodestar Layer.'');    ',
'  end if;',
'  rt.javascript_function := ''function () {'' ||',
'    ''mapbits_select_features({''',
'      || apex_javascript.add_attribute(''id'', p_dynamic_action.id)',
'      || apex_javascript.add_attribute(''ajaxIdentifier'', apex_plugin.get_ajax_identifier)',
'      || apex_javascript.add_attribute(''layerId'', affected_page_items)',
'      || apex_javascript.add_attribute(''submitItems'', p_dynamic_action.attribute_01)',
'      || apex_javascript.add_attribute(''actionType'', action_type)',
'      || ''});}'';',
'  return rt;',
'end;',
'',
'function mapbits_select_features_ajax',
'(',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin',
')',
'return apex_plugin.t_dynamic_action_ajax_result',
'is',
'  l_query p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'',
'  results apex_plugin_util.t_column_value_list;',
'',
'  json_obj json_object_t;',
'  json_ids json_array_t;',
'',
'  rt apex_plugin.t_dynamic_action_ajax_result;',
'begin',
'  results := apex_plugin_util.get_data(',
'      p_sql_statement => l_query,',
'      p_min_columns => 1,',
'      p_max_columns => 1,',
'      p_component_name => p_plugin.name',
'  );',
'',
'  json_obj := new json_object_t;',
'  json_ids := new json_array_t;',
'  for i in 1..results(1).count loop',
'    json_ids.append(results(1)(i));',
'  end loop;',
'  json_obj.put(''ids'', json_ids);',
'',
'  declare',
'    output_clob clob;',
'    l_offset pls_integer := 1;',
'    l_chunk pls_integer := 2048;',
'  begin',
'    output_clob := json_obj.to_clob();',
'    loop',
'      exit when l_offset > length(output_clob);',
'      htp.prn(substr(output_clob, l_offset, l_chunk));',
'      l_offset := l_offset + l_chunk;',
'    end loop;',
'  end;',
'',
'  return rt;',
'end;',
''))
,p_api_version=>2
,p_render_function=>'mapbits_select_features'
,p_ajax_function=>'mapbits_select_features_ajax'
,p_standard_attributes=>'ITEM:REQUIRED:ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Lodestar Select Features plugin is a dynamic action used to modify the symbology of a subset Mapbits Lodestar Layer features to appear "selected". The selected feature subset is based on a sql query that returns ''ids'' from the Lodestar Layer.'
,p_version_identifier=>'4.6.20231204'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Lodestar Select Features',
'Location : $Id: dynamic_action_plugin_mil_army_usace_mapbits_select_features.sql 18773 2023-12-04 18:42:11Z b2eddjw9 $',
'Date     : $Date: 2023-12-04 12:42:11 -0600 (Mon, 04 Dec 2023) $',
'Revision : $Revision: 18773 $',
'Requires : Application Express >= 22.2',
'',
'Version 4.6 Updates:',
'12/04/2023 Raise an application error if this plugin item is not associated with at least one Lodestar layer item.',
'11/07/2023 Made the plugin work when multiple affected page items are given.',
'11/03/2023 Initial Implementation',
'',
''))
,p_files_version=>51
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(477995173360520299)
,p_plugin_id=>wwv_flow_imp.id(515173877986891639)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Page Items To Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(515249316861064051)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'set,add,remove'
,p_help_text=>'If the IDs query includes any page items that may need to be passed to the database for the query to work properly, specify them here as a comma-separated list.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(515174564008900414)
,p_plugin_id=>wwv_flow_imp.id(515173877986891639)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>5
,p_prompt=>'Query Returning Feature IDs'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(515249316861064051)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'set,add,remove'
,p_help_text=>'SQL query returning a single column of ids from the affected layer, corresponding to the column specified in the ''Id Column'' attribute of the Lodestar Layer.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(515249316861064051)
,p_plugin_id=>wwv_flow_imp.id(515173877986891639)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>4
,p_prompt=>'Action'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'set'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Action to take when dynamic action is triggered. ''Set Selection'' will select features from the affected layer based on the plugin''s query, while ''Add To Selection'' will add selected features to an existing selection based on the plugin''s query. ''Remo'
||'ve From Selection'' will remove features returned by the query from the existing selection. ''Select All'' and ''Deselect All'' do not use the query, but rather select all features and deselect all features from the affected layer, respectively.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(515250661445067708)
,p_plugin_attribute_id=>wwv_flow_imp.id(515249316861064051)
,p_display_sequence=>10
,p_display_value=>'Set Selection'
,p_return_value=>'set'
,p_is_quick_pick=>true
,p_help_text=>'Select the specified features, and unselect all other features.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(515251009767069886)
,p_plugin_attribute_id=>wwv_flow_imp.id(515249316861064051)
,p_display_sequence=>20
,p_display_value=>'Add To Selection'
,p_return_value=>'add'
,p_is_quick_pick=>true
,p_help_text=>'Adds the specified features to the layer''s selection.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(515251400966074065)
,p_plugin_attribute_id=>wwv_flow_imp.id(515249316861064051)
,p_display_sequence=>30
,p_display_value=>'Remove From Selection'
,p_return_value=>'remove'
,p_is_quick_pick=>true
,p_help_text=>'Deselect the specified features.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(515251797029076363)
,p_plugin_attribute_id=>wwv_flow_imp.id(515249316861064051)
,p_display_sequence=>40
,p_display_value=>'Select All'
,p_return_value=>'select_all'
,p_is_quick_pick=>true
,p_help_text=>'Select all features in the layer.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(515252199002078199)
,p_plugin_attribute_id=>wwv_flow_imp.id(515249316861064051)
,p_display_sequence=>50
,p_display_value=>'Deselect All'
,p_return_value=>'deselect_all'
,p_is_quick_pick=>true
,p_help_text=>'Clear the layer''s selection.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F73656C6563745F6665617475726573287B69643A652C616A61784964656E7469666965723A742C6C6179657249643A732C7375626D69744974656D733A612C616374696F6E547970653A727D297B6966282173';
wwv_flow_imp.g_varchar2_table(2) := '2972657475726E20766F696420617065782E64656275672E6572726F7228226D6170626974735F73656C6563745F666561747572657320222B652B22203A204E6F206166666563746564206974656D207370656369666965642E22293B636F6E73742069';
wwv_flow_imp.g_varchar2_table(3) := '3D732E73706C697428222C22292E6D61702828743D3E7B636F6E737420733D617065782E6974656D2874293B69662873296966282266756E6374696F6E223D3D747970656F6620732E73657453656C65637465644665617475726573297B696628732E68';
wwv_flow_imp.g_varchar2_table(4) := '61734944436F6C756D6E28292972657475726E20733B617065782E64656275672E6572726F7228606D6170626974735F73656C6563745F666561747572657320247B657D203A204974656D20247B747D20686173206E6F20494420636F6C756D6E2C2073';
wwv_flow_imp.g_varchar2_table(5) := '6F207468652053656C6563742046656174757265732064796E616D696320616374696F6E2077696C6C206E6F7420776F726B2E60297D656C736520617065782E64656275672E6572726F7228226D6170626974735F73656C6563745F6665617475726573';
wwv_flow_imp.g_varchar2_table(6) := '20222B652B22203A204974656D205B222B742B225D206973206E6F742061204D617062697473204C6F646573746172204C61796572206974656D2E22293B656C736520617065782E64656275672E6572726F7228226D6170626974735F73656C6563745F';
wwv_flow_imp.g_varchar2_table(7) := '666561747572657320222B652B22203A204974656D205B222B742B225D2069732068696464656E206F72206D697373696E672E22297D29292E66696C7465722828653D3E6529293B7377697463682872297B636173652273656C6563745F616C6C223A66';
wwv_flow_imp.g_varchar2_table(8) := '6F7228636F6E73742065206F66206929652E73656C656374416C6C466561747572657328293B627265616B3B6361736522646573656C6563745F616C6C223A666F7228636F6E73742065206F66206929652E73657453656C656374656446656174757265';
wwv_flow_imp.g_varchar2_table(9) := '73285B5D2C2273657422293B627265616B3B64656661756C743A617065782E7365727665722E706C7567696E28742C7B706167654974656D733A613F612E73706C697428222C22293A766F696420307D2C7B737563636573733A66756E6374696F6E2865';
wwv_flow_imp.g_varchar2_table(10) := '297B666F7228636F6E73742074206F66206929742E73657453656C6563746564466561747572657328652E6964732C72297D7D297D7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(478462454675287661)
,p_plugin_id=>wwv_flow_imp.id(515173877986891639)
,p_file_name=>'mapbits-select-features.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F73656C6563745F6665617475726573287B0D0A202069642C0D0A2020616A61784964656E7469666965722C0D0A20206C6179657249642C0D0A20207375626D69744974656D732C0D0A2020616374696F6E5479';
wwv_flow_imp.g_varchar2_table(2) := '70650D0A7D29207B0D0A202069662028216C61796572496429207B0D0A20202020617065782E64656275672E6572726F7228276D6170626974735F73656C6563745F66656174757265732027202B206964202B2027203A204E6F20616666656374656420';
wwv_flow_imp.g_varchar2_table(3) := '6974656D207370656369666965642E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A2020636F6E7374206C6179657273203D206C6179657249642E73706C697428272C27292E6D6170286C203D3E207B0D0A20202020636F6E7374206C61';
wwv_flow_imp.g_varchar2_table(4) := '7965724974656D203D20617065782E6974656D286C293B0D0A2020202069662028216C617965724974656D29207B0D0A202020202020617065782E64656275672E6572726F7228276D6170626974735F73656C6563745F66656174757265732027202B20';
wwv_flow_imp.g_varchar2_table(5) := '6964202B2027203A204974656D205B27202B206C202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A20202020202072657475726E3B0D0A202020207D20656C73652069662028747970656F66206C617965724974656D2E73';
wwv_flow_imp.g_varchar2_table(6) := '657453656C6563746564466561747572657320213D3D202266756E6374696F6E2229207B0D0A202020202020617065782E64656275672E6572726F7228276D6170626974735F73656C6563745F66656174757265732027202B206964202B2027203A2049';
wwv_flow_imp.g_varchar2_table(7) := '74656D205B27202B206C202B20275D206973206E6F742061204D617062697473204C6F646573746172204C61796572206974656D2E27293B0D0A20202020202072657475726E3B0D0A202020207D20656C73652069662028216C617965724974656D2E68';
wwv_flow_imp.g_varchar2_table(8) := '61734944436F6C756D6E282929207B0D0A202020202020617065782E64656275672E6572726F7228606D6170626974735F73656C6563745F666561747572657320247B69647D203A204974656D20247B6C7D20686173206E6F20494420636F6C756D6E2C';
wwv_flow_imp.g_varchar2_table(9) := '20736F207468652053656C6563742046656174757265732064796E616D696320616374696F6E2077696C6C206E6F7420776F726B2E60293B0D0A20202020202072657475726E3B0D0A202020207D0D0A2020202072657475726E206C617965724974656D';
wwv_flow_imp.g_varchar2_table(10) := '3B0D0A20207D292E66696C7465722878203D3E2078293B0D0A0D0A20207377697463682028616374696F6E5479706529207B0D0A2020202063617365202773656C6563745F616C6C273A0D0A202020202020666F722028636F6E7374206C617965724974';
wwv_flow_imp.g_varchar2_table(11) := '656D206F66206C617965727329207B0D0A20202020202020206C617965724974656D2E73656C656374416C6C466561747572657328293B0D0A2020202020207D0D0A202020202020627265616B3B0D0A20202020636173652027646573656C6563745F61';
wwv_flow_imp.g_varchar2_table(12) := '6C6C273A0D0A202020202020666F722028636F6E7374206C617965724974656D206F66206C617965727329207B0D0A20202020202020206C617965724974656D2E73657453656C65637465644665617475726573285B5D2C202773657427293B0D0A2020';
wwv_flow_imp.g_varchar2_table(13) := '202020207D0D0A202020202020627265616B3B0D0A2020202064656661756C743A0D0A202020202020617065782E7365727665722E706C7567696E28616A61784964656E7469666965722C207B706167654974656D733A207375626D69744974656D7320';
wwv_flow_imp.g_varchar2_table(14) := '3F207375626D69744974656D732E73706C697428222C2229203A20756E646566696E65647D2C207B0D0A2020202020202020737563636573733A2066756E6374696F6E2028704461746129207B20200D0A20202020202020202020666F722028636F6E73';
wwv_flow_imp.g_varchar2_table(15) := '74206C617965724974656D206F66206C617965727329207B0D0A2020202020202020202020206C617965724974656D2E73657453656C656374656446656174757265732870446174612E6964732C20616374696F6E54797065293B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(16) := '2020207D0D0A20202020202020207D2C0D0A2020202020207D293B0D0A20207D0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(515175495685054644)
,p_plugin_id=>wwv_flow_imp.id(515173877986891639)
,p_file_name=>'mapbits-select-features.js'
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
