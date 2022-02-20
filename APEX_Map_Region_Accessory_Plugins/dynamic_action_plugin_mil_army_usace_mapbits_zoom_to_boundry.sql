prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.04.15'
,p_release=>'21.1.7'
,p_default_workspace_id=>9502877444580501
,p_default_application_id=>101
,p_default_id_offset=>0
,p_default_owner=>'MTG'
);
end;
/
 
prompt APPLICATION 101 - Mapbits Demo
--
-- Application Export:
--   Application:     101
--   Name:            Mapbits Demo
--   Date and Time:   19:14 Wednesday February 9, 2022
--   Exported By:     GREP5
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 55513445365151299
--   Manifest End
--   Version:         21.1.7
--   Instance ID:     9502674331986296
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/mil_army_usace_mapbits_zoom_to_boundry
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(55513445365151299)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MIL.ARMY.USACE.MAPBITS.ZOOM_TO_BOUNDRY'
,p_display_name=>'Mapbits Zoom to Boundary USACE'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP'
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
'begin',
'   --begin',
'     begin',
'       dist_div_code := apex_application.g_x01;      ',
'       select SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 1) , SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 2) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo,1) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo, 2) into xmax,ymax,xmin,ymin fr'
||'om usace_districts',
'         inner join user_sdo_geom_metadata m on m.table_name = ''USACE_DISTRICTS'' ',
'         where usace_district_code = dist_div_code;',
'       htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'     exception when NO_DATA_FOUND then',
'       begin',
'         select SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 1) , SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 2) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo,1) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo, 2) into xmax,ymax,xmin,ymin '
||'from usace_divisions',
'           inner join user_sdo_geom_metadata m on m.table_name = ''USACE_DIVISIONS'' where usace_division_code = dist_div_code;',
'         htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'       exception when NO_DATA_FOUND then',
'	       begin',
'           select SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 1) , SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 2) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo,1) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo, 2)into xmax,ymax,xmin,ymin'
||'   from COUNTY_BDRY_SIMPLE         ',
'		         inner join user_sdo_geom_metadata m on m.table_name = ''COUNTY_BDRY_SIMPLE'' where STCTFIPS = dist_div_code;',
'		       htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'		     exception when NO_DATA_FOUND then',
'		       begin',
'		         select SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 1) , SDO_GEOM.SDO_MAX_MBR_ORDINATE(shape, m.diminfo, 2) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo,1) , SDO_GEOM.SDO_MIN_MBR_ORDINATE(shape, m.diminfo, 2) into xmax,ymax,xmin,ymi'
||'n   from STATE_BDRY_SIMPLE          ',
'		           inner join user_sdo_geom_metadata m on m.table_name = ''STATE_BDRY_SIMPLE'' where STFIPS = dist_div_code;',
'                 htp.prn(''['' || xmin || '','' || ymin || '','' || xmax || '','' || ymax || '']'');',
'	           exception when NO_DATA_FOUND then',
'                 if dist_div_code = ''ALL_DISTRICTS'' or dist_div_code = ''ALL_DIVISIONS'' then',
'                   htp.prn(''[-124.7844079,24.7433195,-66.9513812,49.3457868]'');',
'                 else',
'                   htp.prn(''{"error" : "Error: Input code ['' || dist_div_code || ''] not found among USACE Districts, USACE Divisions, Counties/Parishes, or States"}'');',
'                end if;',
'		       end;',
'		     end;',
'       end;',
'     end;',
'   --exception when OTHERS then',
'   --  --htp.prn(''[null,null,null,null]'');',
'   --  htp.prn(''{"error" : "Error: Missing table for one of the following: USACE Districts, USACE Divisions, Counties/Parishes, States " }'');',
'   --  --raise_application_error(-20001,  SQLERRM || '' '' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);',
'   --end;',
'   return rt;',
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
'  --l_active_extent := ''map.'' || v(''APP_ID'') || ''.'' || V(''APP_PAGE_ID'') || ''.'' || l_region_id || ''.lngState'';',
'  rt.javascript_function := ''function () {mapbits_zoomtoboundary("'' || p_dynamic_action.id || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", $v("'' || l_extent_code || ''"));}'';',
'  return rt;',
'end;'))
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
,p_version_identifier=>'4.0.$Revision: 17061 $'
,p_files_version=>3
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(55929438828272565)
,p_plugin_id=>wwv_flow_api.id(55513445365151299)
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
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F7A6F6F6D746F626F756E6461727928705F616374696F6E5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F657874656E745F636F646529207B0D0A20202F2F20';
wwv_flow_api.g_varchar2_table(2) := '72616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D6573736167652C206D73672C20616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D';
wwv_flow_api.g_varchar2_table(3) := '736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C65727428705F616374696F6E5F6964202B20222022202B206D7367293B636F6E736F6C652E6C6F6728705F616374696F6E5F69';
wwv_flow_api.g_varchar2_table(4) := '64202B20222022202B206D7367293B7D293B0D0A20207D0D0A20200D0A2020766172206D6170203D20617065782E726567696F6E28705F726567696F6E5F6964292E63616C6C28226765744D61704F626A65637422293B0D0A20200D0A20202F2F206361';
wwv_flow_api.g_varchar2_table(5) := '6C6C206261636B2074686520617065782073657276657220746F206765742074686520626F756E647320636F72726573706F6E64696E6720746F0D0A20202F2F2074686520657874656E7420636F64652E204966207375636365737366756C2C20746865';
wwv_flow_api.g_varchar2_table(6) := '206173736F636961746564206D617020726567696F6E2028705F726567696F6E5F6964290D0A20202F2F2077696C6C2070616E20616E64207A6F6F6D20746F2074686F736520626F756E64732E204F74686572776973652C2073686F7720746865206572';
wwv_flow_api.g_varchar2_table(7) := '726F72206D6573736167650D0A20202F2F20696E2061206A61766173637269707420616C6572742E0D0A20206D61702E67657443616E76617328292E7374796C652E637572736F72203D20276E6F742D616C6C6F776564273B0D0A2020617065782E7365';
wwv_flow_api.g_varchar2_table(8) := '727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B7830313A20705F657874656E745F636F64657D2C207B0D0A20202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A2020202020206966202822';
wwv_flow_api.g_varchar2_table(9) := '6572726F722220696E20704461746129207B0D0A2020202020202020617065785F616C65727428657272293B0D0A2020202020207D20656C7365207B0D0A20202020202020206D61702E666974426F756E64732870446174612C207B70616464696E673A';
wwv_flow_api.g_varchar2_table(10) := '20357D293B0D0A2020202020207D0D0A2020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D2027706F696E746572273B0D0A202020207D2C0D0A202020206572726F723A2066756E6374696F6E20286A717868722C';
wwv_flow_api.g_varchar2_table(11) := '207374617475732C2065727229207B0D0A202020202020617065785F616C65727428657272293B0D0A2020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D2027706F696E746572273B0D0A202020207D0D0A20207D';
wwv_flow_api.g_varchar2_table(12) := '293B0D0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(56575178903884563)
,p_plugin_id=>wwv_flow_api.id(55513445365151299)
,p_file_name=>'mapbits-zoomtoboundary.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
