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
--   Date and Time:   16:38 Tuesday November 7, 2023
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 1199681036131993718
--   Manifest End
--   Version:         22.2.8
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/mil_army_usace_mapbits_zoom_to
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(1199681036131993718)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MIL.ARMY.USACE.MAPBITS.ZOOM_TO'
,p_display_name=>'Mapbits Zoom To'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-zoomto.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function mapbits_zoom_ajax (',
'    p_dynamic_action in apex_plugin.t_dynamic_action,',
'    p_plugin         in apex_plugin.t_plugin )',
'    return apex_plugin.t_dynamic_action_ajax_result is',
'  l_query p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;   ',
'  dist_div_code   varchar2(25);',
'  xmin number;',
'  ymin number;',
'  xmax number;',
'  ymax number;',
'  rt apex_plugin.t_dynamic_action_ajax_result;',
'  l_column_value_list   apex_plugin_util.t_column_value_list;',
'  i integer;',
'  l_shape sdo_geometry;',
'  l_dim sdo_dim_array;',
'begin',
'  l_column_value_list :=',
'    apex_plugin_util.get_data (',
'      p_sql_statement    => l_query,',
'      p_min_columns      => 1,',
'      p_max_columns      => 1,',
'      p_component_name   => p_plugin.name',
'  );',
'           ',
'  if l_column_value_list(1).count > 0 then',
'    if l_column_value_list(1)(1) is null then',
'      raise_application_error(-20981, ''Could not create geometry. One reason for this could be the size of the GeoJSON data, which is limited to 32767 characters. Consider using the function SDO_GEOM.SDO_MBR return a smaller geometry.'');',
'    end if;',
'    l_shape := sdo_util.from_geojson(l_column_value_list(1)(1));',
'    select SDO_GEOM.SDO_MIN_MBR_ORDINATE(l_shape,  1), SDO_GEOM.SDO_MIN_MBR_ORDINATE(l_shape,  2),',
'    SDO_GEOM.SDO_MAX_MBR_ORDINATE(l_shape,  1), SDO_GEOM.SDO_MAX_MBR_ORDINATE(l_shape, 2) ',
'      into xmin,ymin,xmax,ymax   from dual;',
'    htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'  else',
'    -- No data found',
'    raise_application_error(-20520, ''ERROR: Map Layer Zoom To - No data found from query results.'');',
'  end if;',
'  return rt;',
'end;',
'',
'function mapbits_zoom (',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin )',
'  return apex_plugin.t_dynamic_action_render_result is',
'    l_region_id varchar2(4000);',
'    l_error varchar2(4000);',
'    rt apex_plugin.t_dynamic_action_render_result;',
'    l_pits p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_pitss p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'begin',
'  begin',
'   select nvl(r.static_id, ''R''||da.affected_region_id) into l_region_id',
'    from apex_application_page_da_acts da, apex_application_page_regions r',
'    where da.affected_region_id = r.region_id',
'    and da.application_id = v(''APP_ID'') and da.page_id = v(''APP_PAGE_ID'')',
'    and da.action_id = p_dynamic_action.id',
'    and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then',
'      apex_debug.message(',
'        p_message => ''ERROR: Map Layer Zoom to Boundary DA [%s] is not associated with a Map region.'',',
'        p0      => p_dynamic_action.id,',
'        p_level   => apex_debug.c_log_level_error',
'      );',
'      l_error := l_error || ''Configuration ERROR: Map Layer Zoom to Boundary DA is not associated with a Map region.'';',
'  end;',
'  rt.javascript_function := ''function () {'' ||',
'    ''mapbits_zoom("'' || p_dynamic_action.id || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", "'' || l_pits || ''", "'' || l_pitss || ''");}'';',
'',
'  return rt;',
'end;'))
,p_api_version=>2
,p_render_function=>'mapbits_zoom'
,p_ajax_function=>'mapbits_zoom_ajax'
,p_standard_attributes=>'REGION:REQUIRED:ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits Zoom To plugin is a dynamic action that zooms and recenters the map viewport based on the extent of a GeoJSON format feature in a page item.'
,p_version_identifier=>'4.6.20231107'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Zoom To',
'Location : $Id: dynamic_action_plugin_mil_army_usace_mapbits_zoom_to.sql 18694 2023-11-07 22:47:20Z b2eddjw9 $',
'Date     : $Date: 2023-11-07 16:47:20 -0600 (Tue, 07 Nov 2023) $',
'Revision : $Revision: 18694 $',
'Requires : Application Express >= 21.1',
'',
'Version 4.6 Updates:',
'11/07/2023 Created a new attribute to allow multiple "Page Items To Submit". The old attribute that only supported one item is deprecated.',
'',
'Version 4.5 Updates:',
'7/13/2023 Using setInterval to iterate calls to getMapObject until a ready map is returned. This was intended to fix cases where the dynamic action is used on page load events.',
'',
'Version 4.4 Updates:',
'03/28/2023 Removed requirement to have a ''Page Item to Submit'' attribute. ',
'',
'Version 4.3 Updates:',
'08/13/2022 Test with maplibre. No changes. Bumping version.',
'03/24/2022 Added error message if geometry is too large. Edited help text to encourage use of MBR.',
'12/07/2022 Break out of javascript function if the region is null to avoid javascript errors breaking the rest of page. This is common for ''load'' dynamic actions. '))
,p_files_version=>48
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1199681197155993721)
,p_plugin_id=>wwv_flow_imp.id(1199681036131993718)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>50
,p_prompt=>'Page Item to Submit (Deprecated)'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Use ''Page Items To Submit'' (plural) instead.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1199684727549747727)
,p_plugin_id=>wwv_flow_imp.id(1199681036131993718)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Query Returning Extent Geometry'
,p_attribute_type=>'SQL'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'select sdo_util.to_geojson(sdo_geom.sdo_mbr(shape)) from mb4_usace_districts where rownum = 1'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Query Returning Extent Geometry. This query should consists of one row and one column where the value is in GeoJSON format. There is a 32,767 character limit on the size of the GeoJSON text. It is strongly advised to use the ',
'sdo_geom.sdo_mbr function.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(82269193422691128)
,p_plugin_id=>wwv_flow_imp.id(1199681036131993718)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Page Items To Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If the ''Query Returning Extent Geometry'' is',
'',
'select sdo_util.to_geojson(shape) from mb4_usace_districts where usace_district_id = :P13_SEL_DISTRICT',
'',
'Then the ''Page Item to Submit'' would be',
'',
'P13_SEL_DISTRICT'))
,p_help_text=>'Page item to submit prior to running the query in ''Query Returning Extent Geometry''. This page item is usually referenced in the where clause of the Zoom To query attribute.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D286E2C652C6F2C742C72297B66756E6374696F6E20732865297B617065782E6A5175657279282866756E6374696F6E28297B636F6E736F6C652E6C6F67286E2B2220222B65297D29297D7661722069';
wwv_flow_imp.g_varchar2_table(2) := '3D617065782E726567696F6E286F293B6966286E756C6C3D3D692972657475726E20766F696420636F6E736F6C652E6C6F6728226D6170626974735F7A6F6F6D20222B6E2B22203A20526567696F6E205B222B6F2B225D2069732068696464656E206F72';
wwv_flow_imp.g_varchar2_table(3) := '206D697373696E672E22293B636F6E7374206C3D736574496E74657276616C282866756E6374696F6E28297B636F6E7374206E3D692E63616C6C28226765744D61704F626A65637422293B696628766F696420303D3D3D6E7C7C6E756C6C3D3D6E297265';
wwv_flow_imp.g_varchar2_table(4) := '7475726E3B636C656172496E74657276616C286C293B636F6E7374206F3D5B742C2E2E2E722E73706C697428222C22295D2E66696C74657228286E3D3E6E29293B6E2E67657443616E76617328292E7374796C652E637572736F723D226E6F742D616C6C';
wwv_flow_imp.g_varchar2_table(5) := '6F776564222C617065782E7365727665722E706C7567696E28652C7B706167654974656D733A6F7D2C7B737563636573733A66756E6374696F6E2865297B226572726F7222696E20653F7328657272293A6E2E666974426F756E647328652C7B70616464';
wwv_flow_imp.g_varchar2_table(6) := '696E673A357D292C6E2E67657443616E76617328292E7374796C652E637572736F723D22706F696E746572227D2C6572726F723A66756E6374696F6E28652C6F2C74297B732874292C6E2E67657443616E76617328292E7374796C652E637572736F723D';
wwv_flow_imp.g_varchar2_table(7) := '22706F696E746572227D7D297D292C313030297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(82280968652749661)
,p_plugin_id=>wwv_flow_imp.id(1199681036131993718)
,p_file_name=>'mapbits-zoomto.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D28705F616374696F6E5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F6974656D5F746F5F7375626D69742C20705F6974656D735F746F5F7375626D';
wwv_flow_imp.g_varchar2_table(2) := '697429207B0D0A20202F2F2072616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D6573736167652C206D73672C20616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(3) := '617065785F616C657274286D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B636F6E736F6C652E6C6F6728705F616374696F6E5F6964202B20222022202B206D7367293B7D293B0D0A20207D0D0A20200D0A20202F';
wwv_flow_imp.g_varchar2_table(4) := '2F206765742074686520726567696F6E206F626A6563742E20425265616B206F7574206966206974206973206E6F742072656E64657265642E0D0A202076617220726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D';
wwv_flow_imp.g_varchar2_table(5) := '0A202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020636F6E736F6C652E6C6F6728276D6170626974735F7A6F6F6D2027202B20705F616374696F6E5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F69';
wwv_flow_imp.g_varchar2_table(6) := '64202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A20202F2F2049746572617465206F7665722063616C6C7320746F20276765744D61704F626A6563742720756E74696C';
wwv_flow_imp.g_varchar2_table(7) := '2077652067657420746865206D61702E200D0A2020636F6E737420696E74657276616C203D20736574496E74657276616C2866756E6374696F6E2829207B0D0A20202020636F6E7374206D6170203D20726567696F6E2E63616C6C28226765744D61704F';
wwv_flow_imp.g_varchar2_table(8) := '626A65637422293B0D0A2020202069662028747970656F66206D6170203D3D3D2027756E646566696E656427207C7C206D6170203D3D206E756C6C29207B2020200D0A20202020202072657475726E3B20200D0A202020207D0D0A20202020636C656172';
wwv_flow_imp.g_varchar2_table(9) := '496E74657276616C28696E74657276616C293B0D0A0D0A202020202F2F2063616C6C206261636B2074686520617065782073657276657220746F206765742074686520626F756E647320636F72726573706F6E64696E6720746F0D0A202020202F2F2074';
wwv_flow_imp.g_varchar2_table(10) := '686520657874656E7420636F64652E204966207375636365737366756C2C20746865206173736F636961746564206D617020726567696F6E2028705F726567696F6E5F6964290D0A202020202F2F2077696C6C2070616E20616E64207A6F6F6D20746F20';
wwv_flow_imp.g_varchar2_table(11) := '74686F736520626F756E64732E204F74686572776973652C2073686F7720746865206572726F72206D6573736167650D0A202020202F2F20696E2061206A61766173637269707420616C6572742E0D0A20202020636F6E737420706167654974656D7320';
wwv_flow_imp.g_varchar2_table(12) := '3D205B705F6974656D5F746F5F7375626D69742C202E2E2E705F6974656D735F746F5F7375626D69742E73706C697428222C22295D2E66696C7465722878203D3E2078293B0D0A202020206D61702E67657443616E76617328292E7374796C652E637572';
wwv_flow_imp.g_varchar2_table(13) := '736F72203D20276E6F742D616C6C6F776564273B0D0A20202020617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B706167654974656D737D2C207B0D0A202020202020737563636573733A2066756E6374';
wwv_flow_imp.g_varchar2_table(14) := '696F6E2028704461746129207B0D0A202020202020202069662028226572726F722220696E20704461746129207B0D0A20202020202020202020617065785F616C65727428657272293B0D0A20202020202020207D20656C7365207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(15) := '202020206D61702E666974426F756E64732870446174612C207B70616464696E673A20357D293B0D0A20202020202020207D0D0A20202020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D2027706F696E74657227';
wwv_flow_imp.g_varchar2_table(16) := '3B0D0A2020202020207D2C0D0A2020202020206572726F723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A2020202020202020617065785F616C65727428657272293B0D0A20202020202020206D61702E676574';
wwv_flow_imp.g_varchar2_table(17) := '43616E76617328292E7374796C652E637572736F72203D2027706F696E746572273B0D0A2020202020207D0D0A202020207D293B0D0A20207D2C313030293B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(1281321861385554865)
,p_plugin_id=>wwv_flow_imp.id(1199681036131993718)
,p_file_name=>'mapbits-zoomto.js'
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
