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
--     PLUGIN: 1932066236039978950
--   Manifest End
--   Version:         23.2.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/mil_army_usace_mapbits_zoom_to_boundry
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(1932066236039978950)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MIL.ARMY.USACE.MAPBITS.ZOOM_TO_BOUNDRY'
,p_display_name=>'Mapbits Zoom to Boundary USACE'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-zoomtoboundary.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function mapbits_zoomTo_ajax (',
'    p_dynamic_action in apex_plugin.t_dynamic_action,',
'    p_plugin         in apex_plugin.t_plugin )',
'    return apex_plugin.t_dynamic_action_ajax_result is',
'     ',
'  dist_div_code   varchar2(25);',
'  xmin number;',
'  ymin number;',
'  xmax number;',
'  ymax number;',
'  rt apex_plugin.t_dynamic_action_ajax_result;',
'  l_extent_code p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'begin',
'  begin',
'    if apex_application.g_x01 = '''' or apex_application.g_x01 is null then',
'      dist_div_code := APEX_UTIL.GET_SESSION_STATE(l_extent_code);',
'    else',
'      dist_div_code := l_extent_code;',
'    end if;',
'    ',
'    select SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 1) , SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 2) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo,1) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo, 2) into xmax,ymax,xmin,ymin from '
||'usace_districts',
'         inner join user_sdo_geom_metadata m on m.table_name = ''USACE_DISTRICTS'' ',
'         where usace_district_code = dist_div_code;',
'    htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'  exception when NO_DATA_FOUND then',
'    begin',
'      select SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 1) , SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 2) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo,1) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo, 2) into xmax,ymax,xmin,ymin fro'
||'m usace_divisions',
'        inner join user_sdo_geom_metadata m on m.table_name = ''USACE_DIVISIONS'' where usace_division_code = dist_div_code;',
'      htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'    exception when NO_DATA_FOUND then',
'	  begin',
'        select SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 1) , SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 2) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo,1) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo, 2)into xmax,ymax,xmin,ymin   '
||'from COUNTY_BDRY_SIMPLE         ',
'		    inner join user_sdo_geom_metadata m on m.table_name = ''COUNTY_BDRY_SIMPLE'' where STCTFIPS = dist_div_code;',
'		htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'      exception when NO_DATA_FOUND then',
'	    begin',
'          select SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 1) , SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 2) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo,1) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo, 2) into xmax,ymax,xmin,ymin'
||'   from STATE_BDRY_SIMPLE          ',
'		    inner join user_sdo_geom_metadata m on m.table_name = ''STATE_BDRY_SIMPLE'' where STFIPS = dist_div_code;',
'          htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'	    exception when NO_DATA_FOUND then',
'          if dist_div_code = ''ALL_DISTRICTS'' or dist_div_code = ''ALL_DIVISIONS'' then',
'            htp.prn(''[-124.7844079,24.7433195,-66.9513812,49.3457868]'');',
'          else',
'            htp.prn(''{"error" : "Error: Input code ['' || dist_div_code || ''] not found among USACE Districts, USACE Divisions, Counties/Parishes, or States"}'');',
'          end if;',
'		end;',
'      end;',
'    end;',
'  end;',
'  return rt;',
'end;',
'',
'function mapbits_zoomTo (',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin )',
'  return apex_plugin.t_dynamic_action_render_result is',
'    l_region_id varchar2(4000); --apex_application_page_regions.region_id%type;',
'    l_error varchar2(4000);',
'    rt apex_plugin.t_dynamic_action_render_result;',
'    l_extent_code p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_cached p_dynamic_action.attribute_02%type;',
'    l_active_extent varchar2(400);',
'begin',
'   select decode(p_dynamic_action.attribute_02, ''Y'', ''true'', ''N'', ''false'') into l_cached from dual;',
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
'  rt.javascript_function := ''function () {mapbits_zoomtoboundary("'' || p_dynamic_action.id || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", $v("'' || l_extent_code || ''"));}'';',
'  return rt;',
'end;'))
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'mapbits_zoomTo'
,p_ajax_function=>'mapbits_zoomTo_ajax'
,p_standard_attributes=>'REGION:REQUIRED'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Mapbits Zoom to Boundary is a dynamic action plugin that zooms and re-centers an APEX map to the bounds of USACE District, USACE Division, Parish/County, or State',
'based on an five letter USACE code or a FIPS code in the Item Containing the Location Code. Examples of the codes are CEMVN for New Orleans USACE District, CEMVD for Mississippi Valley USACE Division, 22055 for Lafayette parish, and 22 for Louisiana '
||'State.'))
,p_version_identifier=>'4.8.20230720'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'07/20/2023 - If the extent code page item has no value when passed to the ajax callback, then get the extent code value from the session state in the ajax callback.',
'07/13/2023 - Modified to match Zoom to plugin.'))
,p_files_version=>9
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1932482229503100216)
,p_plugin_id=>wwv_flow_imp.id(1932066236039978950)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Item Containing Location Code'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'CEMVN',
'CEMVD',
'22055',
'22'))
,p_help_text=>'USACE District or USACE Division five-letter code or the Parish/County or State FIPS code.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D746F626F756E64617279286E2C6F2C652C72297B66756E6374696F6E2074286F297B617065782E6A5175657279282866756E6374696F6E28297B636F6E736F6C652E6C6F67286E2B2220222B6F297D';
wwv_flow_imp.g_varchar2_table(2) := '29297D76617220733D617065782E726567696F6E2865293B6966286E756C6C3D3D732972657475726E20766F696420636F6E736F6C652E6C6F6728226D6170626974735F7A6F6F6D20222B6E2B22203A20526567696F6E205B222B652B225D2069732068';
wwv_flow_imp.g_varchar2_table(3) := '696464656E206F72206D697373696E672E22293B636F6E737420693D736574496E74657276616C282866756E6374696F6E28297B636F6E7374206E3D732E63616C6C28226765744D61704F626A65637422293B766F69642030213D3D6E262628636C6561';
wwv_flow_imp.g_varchar2_table(4) := '72496E74657276616C2869292C6E2E67657443616E76617328292E7374796C652E637572736F723D226E6F742D616C6C6F776564222C617065782E7365727665722E706C7567696E286F2C7B7830313A727D2C7B737563636573733A66756E6374696F6E';
wwv_flow_imp.g_varchar2_table(5) := '286F297B226572726F7222696E206F3F7428657272293A6E2E666974426F756E6473286F2C7B70616464696E673A357D292C6E2E67657443616E76617328292E7374796C652E637572736F723D22706F696E746572227D2C6572726F723A66756E637469';
wwv_flow_imp.g_varchar2_table(6) := '6F6E286F2C652C72297B742872292C6E2E67657443616E76617328292E7374796C652E637572736F723D22706F696E746572227D7D29297D292C313030297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(1239906922730608178)
,p_plugin_id=>wwv_flow_imp.id(1932066236039978950)
,p_file_name=>'mapbits-zoomtoboundary.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D746F626F756E6461727928705F616374696F6E5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F657874656E745F636F646529207B0D0A20202F2F20';
wwv_flow_imp.g_varchar2_table(2) := '72616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D6573736167652C206D73672C20616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D';
wwv_flow_imp.g_varchar2_table(3) := '736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B636F6E736F6C652E6C6F6728705F616374696F6E5F6964202B20222022202B206D7367293B7D293B0D0A20207D0D0A20200D0A20202F2F2067657420746865207265';
wwv_flow_imp.g_varchar2_table(4) := '67696F6E206F626A6563742E20427265616B206F7574206966206974206973206E6F742072656E64657265642E0D0A202076617220726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D0A202069662028726567696F';
wwv_flow_imp.g_varchar2_table(5) := '6E203D3D206E756C6C29207B0D0A20202020636F6E736F6C652E6C6F6728276D6170626974735F7A6F6F6D2027202B20705F616374696F6E5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D206973206869';
wwv_flow_imp.g_varchar2_table(6) := '6464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A20202F2F2049746572617465206F7665722063616C6C7320746F20276765744D61704F626A6563742720756E74696C207765206765742074686520';
wwv_flow_imp.g_varchar2_table(7) := '6D61702E200D0A2020636F6E737420696E74657276616C203D20736574496E74657276616C2866756E6374696F6E2829207B0D0A20202020636F6E7374206D6170203D20726567696F6E2E63616C6C28226765744D61704F626A65637422293B0D0A2020';
wwv_flow_imp.g_varchar2_table(8) := '202069662028747970656F66206D6170203D3D3D2027756E646566696E65642729207B2020200D0A20202020202072657475726E3B20200D0A202020207D0D0A20202020636C656172496E74657276616C28696E74657276616C293B0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(9) := '2F2F2063616C6C206261636B2074686520617065782073657276657220746F206765742074686520626F756E647320636F72726573706F6E64696E6720746F0D0A202020202F2F2074686520657874656E7420636F64652E204966207375636365737366';
wwv_flow_imp.g_varchar2_table(10) := '756C2C20746865206173736F636961746564206D617020726567696F6E2028705F726567696F6E5F6964290D0A202020202F2F2077696C6C2070616E20616E64207A6F6F6D20746F2074686F736520626F756E64732E204F74686572776973652C207368';
wwv_flow_imp.g_varchar2_table(11) := '6F7720746865206572726F72206D6573736167650D0A202020202F2F20696E2061206A61766173637269707420616C6572742E0D0A202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D20276E6F742D616C6C6F776564';
wwv_flow_imp.g_varchar2_table(12) := '273B0D0A20202020617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B7830313A20705F657874656E745F636F64657D2C207B0D0A202020202020737563636573733A2066756E6374696F6E202870446174';
wwv_flow_imp.g_varchar2_table(13) := '6129207B0D0A202020202020202069662028226572726F722220696E20704461746129207B0D0A20202020202020202020617065785F616C65727428657272293B0D0A20202020202020207D20656C7365207B0D0A202020202020202020206D61702E66';
wwv_flow_imp.g_varchar2_table(14) := '6974426F756E64732870446174612C207B70616464696E673A20357D293B0D0A20202020202020207D0D0A20202020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D2027706F696E746572273B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(15) := '7D2C0D0A2020202020206572726F723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A2020202020202020617065785F616C65727428657272293B0D0A20202020202020206D61702E67657443616E76617328292E';
wwv_flow_imp.g_varchar2_table(16) := '7374796C652E637572736F72203D2027706F696E746572273B0D0A2020202020207D0D0A202020207D293B0D0A20207D2C313030293B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(1933127969578712214)
,p_plugin_id=>wwv_flow_imp.id(1932066236039978950)
,p_file_name=>'mapbits-zoomtoboundary.js'
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
