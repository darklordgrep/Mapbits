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
--     PLUGIN: 1991139997459864414
--   Manifest End
--   Version:         23.2.0
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
 p_id=>wwv_flow_imp.id(1991139997459864414)
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
'  l_query p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'  query_type p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;',
'  dist_div_code   varchar2(25);',
'  xmin number;',
'  ymin number;',
'  xmax number;',
'  ymax number;',
'  rt apex_plugin.t_dynamic_action_ajax_result;',
'  i integer;',
'  query_ctx apex_exec.t_context;',
'  n_cols number;',
'  l_shape sdo_geometry;',
'  l_dim sdo_dim_array;',
'begin',
'  query_ctx := apex_exec.open_query_context(',
'    p_location => apex_exec.c_location_local_db,',
'    p_sql_query => l_query',
'  );',
'',
'  if apex_exec.next_row(query_ctx) then',
'    case query_type',
'      when ''sdo_geometry'' then',
'        l_shape := apex_exec.get_sdo_geometry(query_ctx, 1);',
'      when ''GeoJSON'' then',
'        l_shape := sdo_util.from_geojson(apex_exec.get_clob(query_ctx, 1));',
'      else',
'        raise_application_error(-20981, ''ERROR: Map Layer Zoom To - Unexpected query_type "'' || query_type || ''".'');',
'    end case;',
'  else',
'    -- No data found',
'    raise_application_error(-20520, ''ERROR: Map Layer Zoom To - No data found from query results.'');',
'  end if;',
'',
'  apex_exec.close(query_ctx);',
'',
'  if l_shape is null then',
'    raise_application_error(-20981, ''Could not create geometry. One reason for this could be the size of the GeoJSON data, which is limited to 32767 characters. Consider using the function SDO_GEOM.SDO_MBR return a smaller geometry.'');',
'  end if;',
'  ',
'  select SDO_GEOM.SDO_MIN_MBR_ORDINATE(l_shape,  1), SDO_GEOM.SDO_MIN_MBR_ORDINATE(l_shape,  2),',
'  SDO_GEOM.SDO_MAX_MBR_ORDINATE(l_shape,  1), SDO_GEOM.SDO_MAX_MBR_ORDINATE(l_shape, 2) ',
'    into xmin,ymin,xmax,ymax   from dual;',
'  htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'  ',
'  return rt;',
'end;',
'',
'function mapbits_zoom (',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin )',
'  return apex_plugin.t_dynamic_action_render_result is',
'    l_region_id varchar2(4000);',
'    l_action_name varchar2(40);',
'    l_region_type varchar2(40);',
'    rt apex_plugin.t_dynamic_action_render_result;',
'    l_pits p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_pitss p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'    l_skip_animation p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;',
'    l_padding p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;',
'begin',
'  begin',
'    select nvl(r.static_id, ''R''||da.affected_region_id), r.source_type, da.dynamic_action_name into l_region_id, l_region_type, l_action_name',
'      from apex_application_page_da_acts da, apex_application_page_regions r',
'      where da.affected_region_id = r.region_id',
'      and da.application_id = v(''APP_ID'') and da.page_id = v(''APP_PAGE_ID'')',
'      and da.action_id = p_dynamic_action.id;',
'    if not l_region_type = ''Map'' then',
'      raise_application_error(-20341, ''Configuration ERROR: Mapbits Mapbits Zoom To DA for "'' || l_action_name ||  ''" ['' || p_dynamic_action.id || ''] is associated with the wrong type of region. It must be associated with a Map region. Check the Affe'
||'cted Elements section of the plugin settings.'');',
'    end if;',
'  exception when NO_DATA_FOUND then',
'    raise_application_error(-20361, ''Configuration ERROR: Mapbits Zoom To DA ['' || p_dynamic_action.id || ''] is not associated with a region. It must be associated with a Map region.  Check the Affected Elements section of the plugin settings.'');',
'  end;',
'  rt.javascript_function := ''function () {'' ||',
'    ''mapbits_zoom("'' || p_dynamic_action.id || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", "'' || l_pits || ''", "'' || l_pitss || ''", "'' || l_skip_animation || ''", '' || l_padding || '');}'';',
'',
'  return rt;',
'end;'))
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'mapbits_zoom'
,p_ajax_function=>'mapbits_zoom_ajax'
,p_standard_attributes=>'REGION:REQUIRED:ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits Zoom To plugin is a dynamic action that zooms and recenters the map viewport based on the extent of a GeoJSON format feature in a page item.'
,p_version_identifier=>'4.8.20240604'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Zoom To',
'Location : $Id: dynamic_action_plugin_mil_army_usace_mapbits_zoom_to.sql 20090 2025-01-28 22:41:13Z b2eddjw9 $',
'Date     : $Date: 2025-01-28 16:41:13 -0600 (Tue, 28 Jan 2025) $',
'Revision : $Revision: 20090 $',
'Requires : Application Express >= 23.2',
'',
'Version 4.8 Updates:',
'06/04/2024 Added padding attribute.',
'',
'Version 4.6 Updates:',
'12/18/2023 Add option to skip the animation',
'12/01/2023 Raise an application error if this plugin item is not associated with a Map region.',
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
,p_files_version=>58
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1991140158483864417)
,p_plugin_id=>wwv_flow_imp.id(1991139997459864414)
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
 p_id=>wwv_flow_imp.id(1991143688877618423)
,p_plugin_id=>wwv_flow_imp.id(1991139997459864414)
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
 p_id=>wwv_flow_imp.id(873728154750561824)
,p_plugin_id=>wwv_flow_imp.id(1991139997459864414)
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
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(587689214689084026)
,p_plugin_id=>wwv_flow_imp.id(1991139997459864414)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Skip Animation'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(593250376681113777)
,p_plugin_id=>wwv_flow_imp.id(1991139997459864414)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>10
,p_prompt=>'Query Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'GeoJSON'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'The data type that the query returns.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(593251420104114702)
,p_plugin_attribute_id=>wwv_flow_imp.id(593250376681113777)
,p_display_sequence=>10
,p_display_value=>'GeoJSON'
,p_return_value=>'GeoJSON'
,p_help_text=>'The query returns a single text column containing GeoJSON.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(593251874719116498)
,p_plugin_attribute_id=>wwv_flow_imp.id(593250376681113777)
,p_display_sequence=>20
,p_display_value=>'SDO_GEOMETRY'
,p_return_value=>'sdo_geometry'
,p_help_text=>'The query returns a single column with type sdo_geometry.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(477497936578866022)
,p_plugin_id=>wwv_flow_imp.id(1991139997459864414)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Padding'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'5'
,p_is_translatable=>false
,p_help_text=>'Amount of padding to leave around the geometry, in pixels.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D286E2C652C6F2C742C722C692C73297B66756E6374696F6E20612865297B617065782E6A5175657279282866756E6374696F6E28297B636F6E736F6C652E6C6F67286E2B2220222B65297D29297D76';
wwv_flow_imp.g_varchar2_table(2) := '6172206C3D617065782E726567696F6E286F293B6966286E756C6C3D3D6C2972657475726E20766F696420636F6E736F6C652E6C6F6728226D6170626974735F7A6F6F6D20222B6E2B22203A20526567696F6E205B222B6F2B225D206973206869646465';
wwv_flow_imp.g_varchar2_table(3) := '6E206F72206D697373696E672E22293B636F6E737420633D736574496E74657276616C282866756E6374696F6E28297B636F6E7374206E3D6C2E63616C6C28226765744D61704F626A65637422293B696628766F696420303D3D3D6E7C7C6E756C6C3D3D';
wwv_flow_imp.g_varchar2_table(4) := '6E2972657475726E3B636C656172496E74657276616C2863293B636F6E7374206F3D5B742C2E2E2E722E73706C697428222C22295D2E66696C74657228286E3D3E6E29293B6E2E67657443616E76617328292E7374796C652E637572736F723D226E6F74';
wwv_flow_imp.g_varchar2_table(5) := '2D616C6C6F776564222C617065782E7365727665722E706C7567696E28652C7B706167654974656D733A6F7D2C7B737563636573733A66756E6374696F6E2865297B226572726F7222696E20653F6128657272293A6E2E666974426F756E647328652C7B';
wwv_flow_imp.g_varchar2_table(6) := '70616464696E673A733F3F352C616E696D6174653A225922213D3D697D292C6E2E67657443616E76617328292E7374796C652E637572736F723D22706F696E746572227D2C6572726F723A66756E6374696F6E28652C6F2C74297B612874292C6E2E6765';
wwv_flow_imp.g_varchar2_table(7) := '7443616E76617328292E7374796C652E637572736F723D22706F696E746572227D7D297D292C313030297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(477499745577867558)
,p_plugin_id=>wwv_flow_imp.id(1991139997459864414)
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
wwv_flow_imp.g_varchar2_table(2) := '69742C20705F736B69705F616E696D6174696F6E2C20705F70616464696E6729207B0D0A20202F2F2072616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D6573736167652C206D73672C20616E642077';
wwv_flow_imp.g_varchar2_table(3) := '7269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B636F6E736F6C652E6C6F6728705F616374696F6E5F6964202B';
wwv_flow_imp.g_varchar2_table(4) := '20222022202B206D7367293B7D293B0D0A20207D0D0A20200D0A20202F2F206765742074686520726567696F6E206F626A6563742E20425265616B206F7574206966206974206973206E6F742072656E64657265642E0D0A202076617220726567696F6E';
wwv_flow_imp.g_varchar2_table(5) := '203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D0A202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020636F6E736F6C652E6C6F6728276D6170626974735F7A6F6F6D2027202B20705F616374696F6E5F6964';
wwv_flow_imp.g_varchar2_table(6) := '202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A20202F2F2049746572617465206F76657220';
wwv_flow_imp.g_varchar2_table(7) := '63616C6C7320746F20276765744D61704F626A6563742720756E74696C2077652067657420746865206D61702E200D0A2020636F6E737420696E74657276616C203D20736574496E74657276616C2866756E6374696F6E2829207B0D0A20202020636F6E';
wwv_flow_imp.g_varchar2_table(8) := '7374206D6170203D20726567696F6E2E63616C6C28226765744D61704F626A65637422293B0D0A2020202069662028747970656F66206D6170203D3D3D2027756E646566696E656427207C7C206D6170203D3D206E756C6C29207B2020200D0A20202020';
wwv_flow_imp.g_varchar2_table(9) := '202072657475726E3B20200D0A202020207D0D0A20202020636C656172496E74657276616C28696E74657276616C293B0D0A0D0A202020202F2F2063616C6C206261636B2074686520617065782073657276657220746F206765742074686520626F756E';
wwv_flow_imp.g_varchar2_table(10) := '647320636F72726573706F6E64696E6720746F0D0A202020202F2F2074686520657874656E7420636F64652E204966207375636365737366756C2C20746865206173736F636961746564206D617020726567696F6E2028705F726567696F6E5F6964290D';
wwv_flow_imp.g_varchar2_table(11) := '0A202020202F2F2077696C6C2070616E20616E64207A6F6F6D20746F2074686F736520626F756E64732E204F74686572776973652C2073686F7720746865206572726F72206D6573736167650D0A202020202F2F20696E2061206A617661736372697074';
wwv_flow_imp.g_varchar2_table(12) := '20616C6572742E0D0A20202020636F6E737420706167654974656D73203D205B705F6974656D5F746F5F7375626D69742C202E2E2E705F6974656D735F746F5F7375626D69742E73706C697428222C22295D2E66696C7465722878203D3E2078293B0D0A';
wwv_flow_imp.g_varchar2_table(13) := '202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D20276E6F742D616C6C6F776564273B0D0A20202020617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B706167654974';
wwv_flow_imp.g_varchar2_table(14) := '656D737D2C207B0D0A202020202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A202020202020202069662028226572726F722220696E20704461746129207B0D0A20202020202020202020617065785F616C657274286572';
wwv_flow_imp.g_varchar2_table(15) := '72293B0D0A20202020202020207D20656C7365207B0D0A202020202020202020206D61702E666974426F756E64732870446174612C207B70616464696E673A20705F70616464696E67203F3F20352C20616E696D6174653A20705F736B69705F616E696D';
wwv_flow_imp.g_varchar2_table(16) := '6174696F6E20213D3D202759277D293B0D0A20202020202020207D0D0A20202020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D2027706F696E746572273B0D0A2020202020207D2C0D0A2020202020206572726F';
wwv_flow_imp.g_varchar2_table(17) := '723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A2020202020202020617065785F616C65727428657272293B0D0A20202020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D';
wwv_flow_imp.g_varchar2_table(18) := '2027706F696E746572273B0D0A2020202020207D0D0A202020207D293B0D0A20207D2C313030293B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(2072780822713425561)
,p_plugin_id=>wwv_flow_imp.id(1991139997459864414)
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
