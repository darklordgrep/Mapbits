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
--   Date and Time:   17:33 Tuesday January 27, 2026
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 43250835356713192
--   Manifest End
--   Version:         24.2.4
--   Instance ID:     218369902185809
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/mil_army_usace_mapbits_custommarker
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(43250835356713192)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MIL.ARMY.USACE.MAPBITS.CUSTOMMARKER'
,p_display_name=>'Mapbits Set Custom Marker'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-setcustommarker.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function render_mapbits_setcustmarker(',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin in apex_plugin.t_plugin )',
'return apex_plugin.t_dynamic_action_render_result is',
'  l_style varchar2(10)   := upper(p_dynamic_action.attribute_04);',
'  l_text varchar2(400)  := upper(p_dynamic_action.attribute_05);',
'  l_styleJS p_dynamic_action.attribute_09%type := p_dynamic_action.attribute_09;',
'  l_text_item p_dynamic_action.attribute_10%type := upper(p_dynamic_action.attribute_10);',
'  l_geojson varchar2(4000) := p_dynamic_action.attribute_12;',
'  l_region_id apex_application_page_da_acts.affected_elements%type;',
'  l_region_type apex_application_page_regions.source_type%type;',
'  l_action_name apex_application_page_da_acts.dynamic_action_name%type;',
'  l_result apex_plugin.t_dynamic_action_render_result;       ',
'  l_error varchar2(4000) := '''';',
'begin',
'  begin',
'    select nvl(r.static_id, ''R''||da.affected_region_id), r.source_type, da.dynamic_action_name into l_region_id, l_region_type, l_action_name',
'      from apex_application_page_da_acts da, apex_application_page_regions r',
'      where da.affected_region_id = r.region_id',
'      and da.application_id = v(''APP_ID'') and da.page_id = v(''APP_PAGE_ID'')',
'      and da.action_id = p_dynamic_action.id;',
'    if not l_region_type = ''Map'' then',
'      raise_application_error(-20341, ''Configuration ERROR: Mapbits Set Marker DA for "'' || l_action_name ||  ''" ['' || p_dynamic_action.id || ''] is associated with the wrong type of region. It must be associated with a Map region. Check the Affected '
||'Elements section of the plugin settings.'');',
'    end if;',
'  exception when NO_DATA_FOUND then',
'    raise_application_error(-20361, ''Configuration ERROR: Mapbits Set Marker DA ['' || p_dynamic_action.id || ''] is not associated with a region. It must be associated with a Map region.  Check the Affected Elements section of the plugin settings.'');',
'  end;',
'',
'  l_result.javascript_function := ''function () {',
'    mapbits_setcustommarker(''||',
'      apex_javascript.add_value(p_dynamic_action.id, false) || '','' ||',
'      apex_javascript.add_value(l_region_id, false) || '', '' ||',
'      apex_javascript.add_value(l_geojson, false)  || '', '' ||',
'      case l_style when ''JAVASCRIPT'' then l_styleJS || '', ''  else ''{"color" : "'' || l_style || ''"}, '' end ||',
'      apex_javascript.add_value(l_text, false) || '', '' ||',
'      apex_javascript.add_value(l_text_item, false) || '', '' ||  ',
'      apex_javascript.add_value(l_error, false) ||',
'    '');',
'  }'';',
'  return l_result;',
'end; '))
,p_api_version=>1
,p_render_function=>'render_mapbits_setcustmarker'
,p_standard_attributes=>'REGION:REQUIRED'
,p_substitute_attributes=>true
,p_version_scn=>449822107
,p_subscribe_plugin_settings=>true
,p_help_text=>'This dynamic action adds a marker to its associated map region based on the value of a page item or updates an existing marker if it already exists. The source geometry page item value must be in GeoJSON format.'
,p_version_identifier=>'5.0.20251201'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 5 - Set Custom Marker',
'Location : $Id: dynamic_action_plugin_mil_army_usace_mapbits_custommarker.sql 21366 2026-01-27 17:48:16Z b2eddjw9 $',
'Date     : $Date: 2026-01-27 11:48:16 -0600 (Tue, 27 Jan 2026) $',
'Revision : $Revision: 21366 $',
'Requires : Application Express >= 24.2',
'',
'Version 5.0 Updates:',
'12/01/2025 Allow the source geometry item to be either a GeoJSON geometry or a GeoJSON Feature (which includes geometry and attrs.)',
'If the marker style content changes, recreate the marker (instead of just moving the existing marker).',
'',
'--------------------',
'',
'Version 4.9 Updates:',
'2/11/2025 Clear the marker if the source geometry item is set to null',
'',
'Version 4.8 Updates:',
'01/29/2025 Fixed case where no title or title item is used for the popup, which was resulting in a spurious error message.',
'',
'Version 4.6 Updates:',
'12/01/2023 Raise an application error if this plugin item is not associated with a Map region.',
'',
'Version 4.5 Updates',
'7/13/2023 Using setInterval to iterate calls to getMapObject until a ready map is returned. This was intended to fix cases where the dynamic action is used on page load events.',
'',
'Version 4.4 Updates',
'5/10/2023 Preventing javascript execution if the parent region is hidden.',
'',
'Version 4.3 Updates',
'8/13/2022 - Modified to work with both mapbox and maplibre.',
'12/07/2022 - Break out of javascript function if the region is null to avoid javascript errors breaking the rest of page. This is common for ''load'' dynamic actions. ',
'',
'Version 4.2 Updates',
'2/19/2022 - Removed marker id. (Using the action id instead, so  one less attribute to deal with).',
'Removed X,Y attributes and XY attributes and replaced them with all with a single geojson geometry page item attribute. '))
,p_files_version=>39
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43251263702713192)
,p_plugin_id=>wwv_flow_imp.id(43250835356713192)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>60
,p_prompt=>'Marker Style'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'gray'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'The style attribute defines the color of the marker. If set to ''Define with Custom Javascript'', the marker can be customized with a Mapbox style definition.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43251608839713192)
,p_plugin_attribute_id=>wwv_flow_imp.id(43251263702713192)
,p_display_sequence=>10
,p_display_value=>'Gray'
,p_return_value=>'gray'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43252118375713193)
,p_plugin_attribute_id=>wwv_flow_imp.id(43251263702713192)
,p_display_sequence=>20
,p_display_value=>'Blue'
,p_return_value=>'blue'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43252693536713193)
,p_plugin_attribute_id=>wwv_flow_imp.id(43251263702713192)
,p_display_sequence=>30
,p_display_value=>'Red'
,p_return_value=>'red'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43253154211713193)
,p_plugin_attribute_id=>wwv_flow_imp.id(43251263702713192)
,p_display_sequence=>40
,p_display_value=>'Green'
,p_return_value=>'green'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43253697310713193)
,p_plugin_attribute_id=>wwv_flow_imp.id(43251263702713192)
,p_display_sequence=>50
,p_display_value=>'Purple'
,p_return_value=>'purple'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43254162208713193)
,p_plugin_attribute_id=>wwv_flow_imp.id(43251263702713192)
,p_display_sequence=>60
,p_display_value=>'Yellow'
,p_return_value=>'yellow'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43254681749713193)
,p_plugin_attribute_id=>wwv_flow_imp.id(43251263702713192)
,p_display_sequence=>70
,p_display_value=>'Define with Custom Javascript'
,p_return_value=>'javascript'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43255155572713194)
,p_plugin_id=>wwv_flow_imp.id(43250835356713192)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>30
,p_prompt=>'Marker Title'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>false
,p_display_length=>15
,p_max_length=>400
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43256790446713195)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'N'
,p_help_text=>'Text to display when marker is selected.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43255588723713194)
,p_plugin_id=>wwv_flow_imp.id(43250835356713192)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Custom Style Javascript'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43251263702713192)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'javascript'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'{anchor : ''top-left'', element : function(){',
'  var s = document.createElement(''span'');',
'  s.setAttribute(''aria-hidden'', ''true'');',
'  s.classList.add(''fa'');',
'  s.classList.add(''fa-check'');',
'  s.style.fontWeight = "bold";',
'  s.style.fontSize = "18pt";',
'  s.innerHTML="";',
'  return s;}()}'))
,p_help_text=>'Custom style based on the Mapbox layer style specification (https://docs.mapbox.com/mapbox-gl-js/style-spec/layers/).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43255914604713194)
,p_plugin_id=>wwv_flow_imp.id(43250835356713192)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>35
,p_prompt=>'Marker Title Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43256790446713195)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'N'
,p_help_text=>'Page item to use for marker popup text.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43256312935713194)
,p_plugin_id=>wwv_flow_imp.id(43250835356713192)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>10
,p_prompt=>'Source Geometry Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Item containing a string like the following:',
'',
'{',
'  "type": "Point",',
'  "coordinates": [-105.96968528790408, 35.26776244240228]',
'}',
'',
'or ',
'',
'{',
'  "type": "Feature",',
'  "geometry": {',
'    "type": "Point",',
'    "coordinates": [-105.96968528790408, 35.26776244240228]',
'  },',
'  "properties" : {',
'    "name" : "Zorro"',
'  }',
'}'))
,p_help_text=>'Page item containing a geojson point geometry.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43256790446713195)
,p_plugin_id=>wwv_flow_imp.id(43250835356713192)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>20
,p_prompt=>'Use Title Page Item'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Set to Yes if you are using a page item to set the Title, No if you are using a static value.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43257181140713195)
,p_plugin_attribute_id=>wwv_flow_imp.id(43256790446713195)
,p_display_sequence=>10
,p_display_value=>'Yes'
,p_return_value=>'Y'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43257612168713195)
,p_plugin_attribute_id=>wwv_flow_imp.id(43256790446713195)
,p_display_sequence=>20
,p_display_value=>'No'
,p_return_value=>'N'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F736574637573746F6D6D61726B657228705F616374696F6E5F69642C20705F726567696F6E5F69642C20705F67656F6D5F6974656D2C20705F7374796C652C20705F7469746C652C20705F7469746C655F6974';
wwv_flow_imp.g_varchar2_table(2) := '656D2C20705F6572726F7229207B0D0A2020766172206D61706C6962203D20747970656F66206D61706C69627265676C203D3D3D2027756E646566696E656427203F206D6170626F78676C203A206D61706C69627265676C3B090D0A202076617220705F';
wwv_flow_imp.g_varchar2_table(3) := '67656F6D203D206E756C6C3B0D0A202076617220782C793B0D0A0D0A20202F2F2069662074686520696E70757420736F75726365206973206E6F7420612047656F4A534F4E2067656F6D657472792C20636865636B206966206974277320612047656F4A';
wwv_flow_imp.g_varchar2_table(4) := '534F4E20666561747572650D0A20202F2F20616E6420757365207468652067656F6D657472792066726F6D20746865206665617475726520696E73746561642E0D0A202069662028617065782E6974656D28705F67656F6D5F6974656D292E6765745661';
wwv_flow_imp.g_varchar2_table(5) := '6C7565282920213D20272729207B0D0A20202020705F67656F6D203D204A534F4E2E706172736528617065782E6974656D28705F67656F6D5F6974656D292E67657456616C75652829293B0D0A2020202069662028705F67656F6D2E74797065203D3D20';
wwv_flow_imp.g_varchar2_table(6) := '22466561747572652229207B0D0A20202020202078203D20705F67656F6D2E67656F6D657472792E636F6F7264696E617465735B305D3B0D0A20202020202079203D20705F67656F6D2E67656F6D657472792E636F6F7264696E617465735B315D3B0D0A';
wwv_flow_imp.g_varchar2_table(7) := '202020207D20656C7365207B20200D0A20202020202078203D20705F67656F6D2E636F6F7264696E617465735B305D3B0D0A20202020202079203D20705F67656F6D2E636F6F7264696E617465735B315D3B202020200D0A202020207D0D0A20207D0D0A';
wwv_flow_imp.g_varchar2_table(8) := '0D0A20202F2F20696620616E20657272726F72206F636375727320696E2074686520706C7567696E20706C73716C20616E642069732070617373656420696E746F20746865206A6176617363726970742066756E6374696F6E2C200D0A20202F2F207261';
wwv_flow_imp.g_varchar2_table(9) := '69736520616E20616C65727420776974682074686174206D6573736167652E0D0A202069662028705F6572726F7220213D20222229207B0D0A20202020617065782E6D6573736167652E616C65727428705F6572726F72293B0D0A202020207265747572';
wwv_flow_imp.g_varchar2_table(10) := '6E3B0D0A20207D0D0A202076617220705F6D61726B65725F6964203D20705F616374696F6E5F69643B0D0A0D0A20202F2F20696620726567696F6E2069732068696464656E2C207468656E20657869742E0D0A202076617220726567696F6E203D206170';
wwv_flow_imp.g_varchar2_table(11) := '65782E726567696F6E28705F726567696F6E5F6964293B0D0A202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020617065782E64656275672E696E666F28276D6170626974735F736574637573746F6D6D61726B65722027202B2070';
wwv_flow_imp.g_varchar2_table(12) := '5F616374696F6E5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A0D0A20202F2F20637265';
wwv_flow_imp.g_varchar2_table(13) := '61746520612070726F6D69736520746F206163717569726520746865206D61702068616E646C65207768656E207370617469616C6D6170696E697469616C697A6564206576656E7420686974732E204D6170206973206E6F7420696D6D6564696174656C';
wwv_flow_imp.g_varchar2_table(14) := '7920617661696C61626C652E0D0A2020636F6E73742070656E64696E674D6170203D206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A2020202076617220726567696F6E203D20617065782E726567696F6E28';
wwv_flow_imp.g_varchar2_table(15) := '705F726567696F6E5F6964293B0D0A2020202069662028726567696F6E203D3D206E756C6C29207B0D0A202020202020617065782E64656275672E6572726F7228276D6170626974735F736574637573746F6D6D61726B65722027202B20705F61637469';
wwv_flow_imp.g_varchar2_table(16) := '6F6E5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A20202020202072656A65637428293B0D0A20202020202072657475726E3B0D0A20';
wwv_flow_imp.g_varchar2_table(17) := '2020207D0D0A20202020636F6E7374206D6170203D20726567696F6E2E63616C6C28276765744D61704F626A65637427293B0D0A20202020696620286D617029207B0D0A2020202020207265736F6C7665286D6170293B0D0A202020207D20656C736520';
wwv_flow_imp.g_varchar2_table(18) := '7B0D0A202020202020726567696F6E2E656C656D656E742E6F6E28277370617469616C6D6170696E697469616C697A6564272C202829203D3E207B0D0A2020202020202020636F6E7374206D6170203D20726567696F6E2E63616C6C28276765744D6170';
wwv_flow_imp.g_varchar2_table(19) := '4F626A65637427293B0D0A20202020202020207265736F6C7665286D6170293B0D0A2020202020207D293B0D0A202020207D0D0A20207D293B0D0A0D0A202070656E64696E674D61702E7468656E28286D617029203D3E207B0D0A202020202F2F20696E';
wwv_flow_imp.g_varchar2_table(20) := '697469616C697A6520746865206D6170206D61726B657220636F6C6C656374696F6E20696620697420646F65736E27742065786973742E200D0A202020202F2F20746865206D6170206D61726B657273206973206120736861726564206173736F636961';
wwv_flow_imp.g_varchar2_table(21) := '74697665206172726179206D617070696E6720616C6C206D61726B657220706C7567696E7320616374696F6E2069647320666F722074686973206D617020746F20746865206D61726B657220696E7374616E6365732E0D0A2020202069662028216D6170';
wwv_flow_imp.g_varchar2_table(22) := '2E6D61726B65727329207B0D0A2020202020206D61702E6D61726B657273203D207B7D3B0D0A202020207D0D0A0D0A202020202F2F20636C65617220746865206578697374696E67206D61726B65722069662074686520696E7075742067656F6D657472';
wwv_flow_imp.g_varchar2_table(23) := '79206973206E756C6C0D0A2020202069662028705F67656F6D203D3D206E756C6C29207B0D0A20202020202069662028705F6D61726B65725F696420696E206D61702E6D61726B65727329207B0D0A20202020202020206D61702E6D61726B6572735B70';
wwv_flow_imp.g_varchar2_table(24) := '5F6D61726B65725F69645D2E72656D6F766528293B0D0A202020202020202064656C657465206D61702E6D61726B6572735B705F6D61726B65725F69645D3B0D0A2020202020207D0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(25) := '20202F2F2070726576656E74207573657220696E746572616374696F6E0D0A20202020705F7374796C652E647261676761626C65203D2066616C73653B0D0A0D0A202020202F2F20757064617465206D61726B657220696620697420616C726561647920';
wwv_flow_imp.g_varchar2_table(26) := '6578697374730D0A2020202069662028705F6D61726B65725F696420696E206D61702E6D61726B65727329207B0D0A202020202020636F6E737420707265766D61726B6572203D206D61702E6D61726B6572735B705F6D61726B65725F69645D3B0D0A0D';
wwv_flow_imp.g_varchar2_table(27) := '0A2020202020202F2F206966206D61726B657220616C72656164792065786973747320616E6420697473207374796C6520656C656D656E74206973207468652073616D6520617320746865206E6577206D61726B65722C206A757374206D6F7665207468';
wwv_flow_imp.g_varchar2_table(28) := '65206D61726B65722E0D0A2020202020202F2F206F74686572776973652C2072656D6F766520697420736F2069742063616E2062652072652D61646465642E0D0A20202020202069662028705F7374796C652E656C656D656E74203D3D20707265766D61';
wwv_flow_imp.g_varchar2_table(29) := '726B65722E676574456C656D656E74282929207B0D0A2020202020202020707265766D61726B65722E7365744C6E674C6174285B782C20795D293B0D0A2020202020207D20656C7365207B0D0A2020202020202020707265766D61726B65722E72656D6F';
wwv_flow_imp.g_varchar2_table(30) := '766528293B0D0A202020202020202064656C657465206D61702E6D61726B6572735B705F6D61726B65725F69645D3B0D0A2020202020207D0D0A202020207D200D0A202020200D0A202020202F2F20696620746865206D61726B657220646F65736E2774';
wwv_flow_imp.g_varchar2_table(31) := '20657869737420286F7220686173206265656E2072656D6F76656420666F7220636F6E74656E74206368616E6765292C207468656E2063726561746520616E642061646420697420746F20746865206D61702E0D0A20202020696620282128705F6D6172';
wwv_flow_imp.g_varchar2_table(32) := '6B65725F696420696E206D61702E6D61726B6572732929207B0D0A202020202020766172206D61726B6572203D206E6577206D61706C69622E4D61726B657228705F7374796C65292E7365744C6E674C6174285B782C20795D292E616464546F286D6170';
wwv_flow_imp.g_varchar2_table(33) := '293B0D0A2020202020206D61702E6D61726B6572735B705F6D61726B65725F69645D203D206D61726B65723B0D0A202020207D0D0A0D0A202020202F2F20696620746865206D61726B6572206861732061207469746C652C2075736520697420666F7220';
wwv_flow_imp.g_varchar2_table(34) := '74686520636F6E74656E7420696E73696465206F6620746865206D61726B657220706F7075702E200D0A2020202069662028705F7469746C655F6974656D20262620705F7469746C655F6974656D20213D2022222029207B0D0A202020202020705F7469';
wwv_flow_imp.g_varchar2_table(35) := '746C65203D20617065782E6974656D28705F7469746C655F6974656D292E67657456616C756528293B0D0A202020207D0D0A2020202069662028705F7469746C652026262020705F7469746C6520213D20222229207B0D0A2020202020206D61702E6D61';
wwv_flow_imp.g_varchar2_table(36) := '726B6572735B705F6D61726B65725F69645D2E736574506F707570286E6577206D61706C69622E506F70757028292E73657448544D4C28705F7469746C6529293B0D0A202020207D0D0A20207D293B0D0A7D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43259020200713196)
,p_plugin_id=>wwv_flow_imp.id(43250835356713192)
,p_file_name=>'mapbits-setcustommarker.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F736574637573746F6D6D61726B657228652C722C612C742C692C732C6E297B766172206D2C6F2C6C3D22756E646566696E6564223D3D747970656F66206D61706C69627265676C3F6D6170626F78676C3A6D61';
wwv_flow_imp.g_varchar2_table(2) := '706C69627265676C2C703D6E756C6C3B6966282222213D617065782E6974656D2861292E67657456616C756528292626282246656174757265223D3D28703D4A534F4E2E706172736528617065782E6974656D2861292E67657456616C7565282929292E';
wwv_flow_imp.g_varchar2_table(3) := '747970653F286D3D702E67656F6D657472792E636F6F7264696E617465735B305D2C6F3D702E67656F6D657472792E636F6F7264696E617465735B315D293A286D3D702E636F6F7264696E617465735B305D2C6F3D702E636F6F7264696E617465735B31';
wwv_flow_imp.g_varchar2_table(4) := '5D29292C2222213D6E2972657475726E20766F696420617065782E6D6573736167652E616C657274286E293B76617220673D653B6966286E756C6C3D3D617065782E726567696F6E2872292972657475726E20766F696420617065782E64656275672E69';
wwv_flow_imp.g_varchar2_table(5) := '6E666F28226D6170626974735F736574637573746F6D6D61726B657220222B652B22203A20526567696F6E205B222B722B225D2069732068696464656E206F72206D697373696E672E22293B636F6E737420643D6E65772050726F6D697365282828612C';
wwv_flow_imp.g_varchar2_table(6) := '74293D3E7B76617220693D617065782E726567696F6E2872293B6966286E756C6C3D3D692972657475726E20617065782E64656275672E6572726F7228226D6170626974735F736574637573746F6D6D61726B657220222B652B22203A20526567696F6E';
wwv_flow_imp.g_varchar2_table(7) := '205B222B722B225D2069732068696464656E206F72206D697373696E672E22292C766F6964207428293B636F6E737420733D692E63616C6C28226765744D61704F626A65637422293B733F612873293A692E656C656D656E742E6F6E2822737061746961';
wwv_flow_imp.g_varchar2_table(8) := '6C6D6170696E697469616C697A6564222C2828293D3E7B636F6E737420653D692E63616C6C28226765744D61704F626A65637422293B612865297D29297D29293B642E7468656E2828653D3E7B696628652E6D61726B6572737C7C28652E6D61726B6572';
wwv_flow_imp.g_varchar2_table(9) := '733D7B7D292C6E756C6C213D70297B696628742E647261676761626C653D21312C6720696E20652E6D61726B657273297B636F6E737420723D652E6D61726B6572735B675D3B742E656C656D656E743D3D722E676574456C656D656E7428293F722E7365';
wwv_flow_imp.g_varchar2_table(10) := '744C6E674C6174285B6D2C6F5D293A28722E72656D6F766528292C64656C65746520652E6D61726B6572735B675D297D69662821286720696E20652E6D61726B65727329297B76617220723D6E6577206C2E4D61726B65722874292E7365744C6E674C61';
wwv_flow_imp.g_varchar2_table(11) := '74285B6D2C6F5D292E616464546F2865293B652E6D61726B6572735B675D3D727D7326262222213D73262628693D617065782E6974656D2873292E67657456616C75652829292C6926262222213D692626652E6D61726B6572735B675D2E736574506F70';
wwv_flow_imp.g_varchar2_table(12) := '757028286E6577206C2E506F707570292E73657448544D4C286929297D656C7365206720696E20652E6D61726B657273262628652E6D61726B6572735B675D2E72656D6F766528292C64656C65746520652E6D61726B6572735B675D297D29297D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43259436304713196)
,p_plugin_id=>wwv_flow_imp.id(43250835356713192)
,p_file_name=>'mapbits-setcustommarker.min.js'
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
