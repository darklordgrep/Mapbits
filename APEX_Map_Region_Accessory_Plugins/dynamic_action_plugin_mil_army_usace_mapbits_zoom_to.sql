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
--   Date and Time:   08:41 Friday July 14, 2023
--   Exported By:     GREP
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 606086815136090696
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
 p_id=>wwv_flow_imp.id(606086815136090696)
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
'  l_pits p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
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
'  if not l_pits is null then ',
'    APEX_UTIL.SET_SESSION_STATE(l_pits, apex_application.g_x01);',
'  end if;',
'',
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
'    l_vpits p_dynamic_action.attribute_01%type;',
'begin',
'  begin',
'   select nvl(r.static_id, ''R''||da.affected_region_id) into l_region_id',
'    from apex_application_page_da_acts da, apex_application_page_regions r',
'    where da.affected_region_id = r.region_id',
'    and da.application_id = v(''APP_ID'') and da.page_id = v(''APP_PAGE_ID'')',
'    and da.action_id = p_dynamic_action.id',
'    and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then ',
'      apex_debug.message(',
'        p_message => ''ERROR: Map Layer Zoom to Boundary DA [%s] is not associated with a Map region.'',',
'        p0      => p_dynamic_action.id,',
'        p_level   => apex_debug.c_log_level_error',
'      );',
'      l_error := l_error || ''Configuration ERROR: Map Layer Zoom to Boundary DA is not associated with a Map region.'';',
'  end;',
'  select decode(p_dynamic_action.attribute_01, null, ''""'', ''$v("'' || p_dynamic_action.attribute_01 || ''")'') into l_vpits from dual;',
'  rt.javascript_function := ''function () {'' ||',
'    ''mapbits_zoom("'' || p_dynamic_action.id || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", '' || l_vpits || '');}'';',
'    ',
'  return rt;',
'end;'))
,p_api_version=>2
,p_render_function=>'mapbits_zoom'
,p_ajax_function=>'mapbits_zoom_ajax'
,p_standard_attributes=>'REGION:REQUIRED:ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits Zoom To plugin is a dynamic action that zooms and recenters the map viewport based on the extent of a GeoJSON format feature in a page item.'
,p_version_identifier=>'4.5.20230713'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Zoom To',
'Location : $Id: dynamic_action_plugin_mil_army_usace_mapbits_zoom_to.sql 18328 2023-07-14 13:43:03Z b2imimcf $',
'Date     : $Date: 2023-07-14 08:43:03 -0500 (Fri, 14 Jul 2023) $',
'Revision : $Revision: 18328 $',
'Requires : Application Express >= 21.1',
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
,p_files_version=>40
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(606086976160090699)
,p_plugin_id=>wwv_flow_imp.id(606086815136090696)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>50
,p_prompt=>'Page Item to Submit'
,p_attribute_type=>'PAGE ITEM'
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
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(606090506553844705)
,p_plugin_id=>wwv_flow_imp.id(606086815136090696)
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
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D286E2C6F2C652C72297B66756E6374696F6E2074286F297B617065782E6A5175657279282866756E6374696F6E28297B636F6E736F6C652E6C6F67286E2B2220222B6F297D29297D76617220733D61';
wwv_flow_imp.g_varchar2_table(2) := '7065782E726567696F6E2865293B6966286E756C6C3D3D732972657475726E20766F696420636F6E736F6C652E6C6F6728226D6170626974735F7A6F6F6D20222B6E2B22203A20526567696F6E205B222B652B225D2069732068696464656E206F72206D';
wwv_flow_imp.g_varchar2_table(3) := '697373696E672E22293B636F6E737420693D736574496E74657276616C282866756E6374696F6E28297B636F6E7374206E3D732E63616C6C28226765744D61704F626A65637422293B766F69642030213D3D6E26266E756C6C213D6E262628636C656172';
wwv_flow_imp.g_varchar2_table(4) := '496E74657276616C2869292C6E2E67657443616E76617328292E7374796C652E637572736F723D226E6F742D616C6C6F776564222C617065782E7365727665722E706C7567696E286F2C7B7830313A727D2C7B737563636573733A66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(5) := '6F297B226572726F7222696E206F3F7428657272293A6E2E666974426F756E6473286F2C7B70616464696E673A357D292C6E2E67657443616E76617328292E7374796C652E637572736F723D22706F696E746572227D2C6572726F723A66756E6374696F';
wwv_flow_imp.g_varchar2_table(6) := '6E286F2C652C72297B742872292C6E2E67657443616E76617328292E7374796C652E637572736F723D22706F696E746572227D7D29297D292C313030297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(20794325898188733)
,p_plugin_id=>wwv_flow_imp.id(606086815136090696)
,p_file_name=>'mapbits-zoomto.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D28705F616374696F6E5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F657874656E745F6974656D29207B0D0A20202F2F2072616973652061206A61';
wwv_flow_imp.g_varchar2_table(2) := '766173637269707420616C65727420776974682074686520696E707574206D6573736167652C206D73672C20616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A202020';
wwv_flow_imp.g_varchar2_table(3) := '20617065782E6A51756572792866756E6374696F6E28297B636F6E736F6C652E6C6F6728705F616374696F6E5F6964202B20222022202B206D7367293B7D293B0D0A20207D0D0A20200D0A20202F2F206765742074686520726567696F6E206F626A6563';
wwv_flow_imp.g_varchar2_table(4) := '742E20425265616B206F7574206966206974206973206E6F742072656E64657265642E0D0A202076617220726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D0A202069662028726567696F6E203D3D206E756C6C29';
wwv_flow_imp.g_varchar2_table(5) := '207B0D0A20202020636F6E736F6C652E6C6F6728276D6170626974735F7A6F6F6D2027202B20705F616374696F6E5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D2069732068696464656E206F72206D69';
wwv_flow_imp.g_varchar2_table(6) := '7373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A20202F2F2049746572617465206F7665722063616C6C7320746F20276765744D61704F626A6563742720756E74696C2077652067657420746865206D61702E200D0A202063';
wwv_flow_imp.g_varchar2_table(7) := '6F6E737420696E74657276616C203D20736574496E74657276616C2866756E6374696F6E2829207B0D0A20202020636F6E7374206D6170203D20726567696F6E2E63616C6C28226765744D61704F626A65637422293B0D0A202020206966202874797065';
wwv_flow_imp.g_varchar2_table(8) := '6F66206D6170203D3D3D2027756E646566696E656427207C7C206D6170203D3D206E756C6C29207B2020200D0A20202020202072657475726E3B20200D0A202020207D0D0A20202020636C656172496E74657276616C28696E74657276616C293B0D0A0D';
wwv_flow_imp.g_varchar2_table(9) := '0A202020202F2F2063616C6C206261636B2074686520617065782073657276657220746F206765742074686520626F756E647320636F72726573706F6E64696E6720746F0D0A202020202F2F2074686520657874656E7420636F64652E20496620737563';
wwv_flow_imp.g_varchar2_table(10) := '6365737366756C2C20746865206173736F636961746564206D617020726567696F6E2028705F726567696F6E5F6964290D0A202020202F2F2077696C6C2070616E20616E64207A6F6F6D20746F2074686F736520626F756E64732E204F74686572776973';
wwv_flow_imp.g_varchar2_table(11) := '652C2073686F7720746865206572726F72206D6573736167650D0A202020202F2F20696E2061206A61766173637269707420616C6572742E0D0A202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D20276E6F742D616C';
wwv_flow_imp.g_varchar2_table(12) := '6C6F776564273B0D0A20202020617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B7830313A20705F657874656E745F6974656D7D2C207B0D0A202020202020737563636573733A2066756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(13) := '28704461746129207B0D0A202020202020202069662028226572726F722220696E20704461746129207B0D0A20202020202020202020617065785F616C65727428657272293B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(14) := '6D61702E666974426F756E64732870446174612C207B70616464696E673A20357D293B0D0A20202020202020207D0D0A20202020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D2027706F696E746572273B0D0A20';
wwv_flow_imp.g_varchar2_table(15) := '20202020207D2C0D0A2020202020206572726F723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A2020202020202020617065785F616C65727428657272293B0D0A20202020202020206D61702E67657443616E76';
wwv_flow_imp.g_varchar2_table(16) := '617328292E7374796C652E637572736F72203D2027706F696E746572273B0D0A2020202020207D0D0A202020207D293B0D0A20207D2C313030293B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(687727640389651843)
,p_plugin_id=>wwv_flow_imp.id(606086815136090696)
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
