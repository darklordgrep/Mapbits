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
--   Date and Time:   14:43 Monday May 12, 2025
--   Exported By:     GREP
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 2016851460205759717
--   Manifest End
--   Version:         23.2.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/mil_army_usace_mapbits_custommarker
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(2016851460205759717)
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
'      apex_javascript.add_value(l_text_item, false) || '', '' ||  -- case when l_text_item is null then l_text else ''$v("'' || l_text_item || ''")'' end, false) || '', '' ||',
'      apex_javascript.add_value(l_error, false) ||',
'    '');',
'  }'';',
'  return l_result;',
'end; '))
,p_default_escape_mode=>'HTML'
,p_api_version=>1
,p_render_function=>'render_mapbits_setcustmarker'
,p_standard_attributes=>'REGION:REQUIRED'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'This dynamic action adds a marker to its associated map region based on the value of a page item or updates an existing marker if it already exists. The source geometry page item value must be in geojson format.'
,p_version_identifier=>'4.9.20250211'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Set Custom Marker',
'Location : $Id: dynamic_action_plugin_mil_army_usace_mapbits_custommarker.sql 20611 2025-05-12 20:01:03Z b2imimcf $',
'Date     : $Date: 2025-05-12 15:01:03 -0500 (Mon, 12 May 2025) $',
'Revision : $Revision: 20611 $',
'Requires : Application Express >= 21.1',
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
,p_files_version=>21
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(2016853901002759732)
,p_plugin_id=>wwv_flow_imp.id(2016851460205759717)
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
 p_id=>wwv_flow_imp.id(2016854310667759732)
,p_plugin_attribute_id=>wwv_flow_imp.id(2016853901002759732)
,p_display_sequence=>10
,p_display_value=>'Gray'
,p_return_value=>'gray'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(2016854755605759733)
,p_plugin_attribute_id=>wwv_flow_imp.id(2016853901002759732)
,p_display_sequence=>20
,p_display_value=>'Blue'
,p_return_value=>'blue'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(2016855242732759733)
,p_plugin_attribute_id=>wwv_flow_imp.id(2016853901002759732)
,p_display_sequence=>30
,p_display_value=>'Red'
,p_return_value=>'red'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(2016855774883759733)
,p_plugin_attribute_id=>wwv_flow_imp.id(2016853901002759732)
,p_display_sequence=>40
,p_display_value=>'Green'
,p_return_value=>'green'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(2016856269982759734)
,p_plugin_attribute_id=>wwv_flow_imp.id(2016853901002759732)
,p_display_sequence=>50
,p_display_value=>'Purple'
,p_return_value=>'purple'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(2016856815798759734)
,p_plugin_attribute_id=>wwv_flow_imp.id(2016853901002759732)
,p_display_sequence=>60
,p_display_value=>'Yellow'
,p_return_value=>'yellow'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(2016941978746798391)
,p_plugin_attribute_id=>wwv_flow_imp.id(2016853901002759732)
,p_display_sequence=>70
,p_display_value=>'Define with Custom Javascript'
,p_return_value=>'javascript'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1992490139026079715)
,p_plugin_id=>wwv_flow_imp.id(2016851460205759717)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>30
,p_prompt=>'Marker Title'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>false
,p_display_length=>15
,p_max_length=>400
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(1992468470874166613)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'N'
,p_help_text=>'Text to display when marker is selected.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(2016940805667720622)
,p_plugin_id=>wwv_flow_imp.id(2016851460205759717)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Custom Style Javascript'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(2016853901002759732)
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
 p_id=>wwv_flow_imp.id(2020676601269906047)
,p_plugin_id=>wwv_flow_imp.id(2016851460205759717)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>35
,p_prompt=>'Marker Title Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(1992468470874166613)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'N'
,p_help_text=>'Page item to use for marker popup text.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1992339699927588238)
,p_plugin_id=>wwv_flow_imp.id(2016851460205759717)
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
'}'))
,p_help_text=>'Page item containing a geojson point geometry.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1992468470874166613)
,p_plugin_id=>wwv_flow_imp.id(2016851460205759717)
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
 p_id=>wwv_flow_imp.id(1992469123819167731)
,p_plugin_attribute_id=>wwv_flow_imp.id(1992468470874166613)
,p_display_sequence=>10
,p_display_value=>'Yes'
,p_return_value=>'Y'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(1992469506512168242)
,p_plugin_attribute_id=>wwv_flow_imp.id(1992468470874166613)
,p_display_sequence=>20
,p_display_value=>'No'
,p_return_value=>'N'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F736574637573746F6D6D61726B657228652C612C722C732C742C6C2C6E297B76617220693D22756E646566696E6564223D3D747970656F66206D61706C69627265676C3F6D6170626F78676C3A6D61706C6962';
wwv_flow_imp.g_varchar2_table(2) := '7265676C3B766172206F2C6D2C702C673D6E756C6C3B6966282222213D617065782E6974656D2872292E67657456616C75652829262628673D4A534F4E2E706172736528617065782E6974656D2872292E67657456616C75652829292C6F3D672E636F6F';
wwv_flow_imp.g_varchar2_table(3) := '7264696E617465735B305D2C6D3D672E636F6F7264696E617465735B315D292C2222213D6E2972657475726E20703D6E2C766F696420617065782E6A5175657279282866756E6374696F6E28297B617065782E6D6573736167652E616C65727428652B22';
wwv_flow_imp.g_varchar2_table(4) := '20222B70292C636F6E736F6C652E6C6F6728652B2220222B70297D29293B76617220753D652C633D617065782E726567696F6E2861293B6966286E756C6C213D632976617220643D736574496E74657276616C282866756E6374696F6E28297B76617220';
wwv_flow_imp.g_varchar2_table(5) := '653D632E63616C6C28226765744D61704F626A65637422293B696628766F69642030213D3D6526266E756C6C213D6529696628636C656172496E74657276616C2864292C652E6D61726B6572737C7C28652E6D61726B6572733D7B7D292C6E756C6C213D';
wwv_flow_imp.g_varchar2_table(6) := '67297B696628732E647261676761626C653D21312C7520696E20652E6D61726B65727329652E6D61726B6572735B755D2E7365744C6E674C6174285B6F2C6D5D293B656C73657B76617220613D6E657720692E4D61726B65722873292E7365744C6E674C';
wwv_flow_imp.g_varchar2_table(7) := '6174285B6F2C6D5D292E616464546F2865293B652E6D61726B6572735B755D3D617D6C26262222213D6C262628743D617065782E6974656D286C292E67657456616C75652829292C7426262222213D742626652E6D61726B6572735B755D2E736574506F';
wwv_flow_imp.g_varchar2_table(8) := '70757028286E657720692E506F707570292E73657448544D4C287429297D656C7365207520696E20652E6D61726B657273262628652E6D61726B6572735B755D2E72656D6F766528292C64656C65746520652E6D61726B6572735B755D297D292C313030';
wwv_flow_imp.g_varchar2_table(9) := '293B656C736520636F6E736F6C652E6C6F6728226D6170626974735F736574637573746F6D6D61726B657220222B652B22203A20526567696F6E205B222B612B225D2069732068696464656E206F72206D697373696E672E22297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(51944574446124255)
,p_plugin_id=>wwv_flow_imp.id(2016851460205759717)
,p_file_name=>'mapbits-setcustommarker.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F736574637573746F6D6D61726B657228705F616374696F6E5F69642C20705F726567696F6E5F69642C20705F67656F6D5F6974656D2C20705F7374796C652C20705F7469746C652C20705F7469746C655F6974';
wwv_flow_imp.g_varchar2_table(2) := '656D2C20705F6572726F7229207B0D0A2020766172206D61706C6962203D20747970656F66206D61706C69627265676C203D3D3D2027756E646566696E656427203F206D6170626F78676C203A206D61706C69627265676C3B090D0A20200D0A20202F2F';
wwv_flow_imp.g_varchar2_table(3) := '2072616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D6573736167652C206D73672C20616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C65727428';
wwv_flow_imp.g_varchar2_table(4) := '6D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C65727428705F616374696F6E5F6964202B20222022202B206D7367293B0D0A20202020636F6E736F6C652E6C6F6728705F61';
wwv_flow_imp.g_varchar2_table(5) := '6374696F6E5F6964202B20222022202B206D7367293B7D293B0D0A20207D0D0A202076617220705F67656F6D203D206E756C6C3B0D0A202076617220782C793B0D0A202069662028617065782E6974656D28705F67656F6D5F6974656D292E6765745661';
wwv_flow_imp.g_varchar2_table(6) := '6C7565282920213D20272729207B0D0A20202020705F67656F6D203D204A534F4E2E706172736528617065782E6974656D28705F67656F6D5F6974656D292E67657456616C75652829293B0D0A2020202078203D20705F67656F6D2E636F6F7264696E61';
wwv_flow_imp.g_varchar2_table(7) := '7465735B305D3B0D0A2020202079203D20705F67656F6D2E636F6F7264696E617465735B315D3B202020200D0A20207D0D0A0D0A0D0A20202F2F20696620616E20657272726F72206F636375727320696E2074686520706C7567696E20706C73716C2061';
wwv_flow_imp.g_varchar2_table(8) := '6E642069732070617373656420696E746F20746865206A6176617363726970742066756E6374696F6E2C200D0A20202F2F20726169736520616E20616C65727420776974682074686174206D6573736167652E0D0A202069662028705F6572726F722021';
wwv_flow_imp.g_varchar2_table(9) := '3D20222229207B0D0A20202020617065785F616C65727428705F6572726F72293B0D0A2020202072657475726E3B0D0A20207D0D0A202076617220705F6D61726B65725F6964203D20705F616374696F6E5F69643B0D0A0D0A20202F2F20696620726567';
wwv_flow_imp.g_varchar2_table(10) := '696F6E2069732068696464656E2C207468656E20657869742E0D0A202076617220726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D0A202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020636F';
wwv_flow_imp.g_varchar2_table(11) := '6E736F6C652E6C6F6728276D6170626974735F736574637573746F6D6D61726B65722027202B20705F616374696F6E5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D2069732068696464656E206F72206D';
wwv_flow_imp.g_varchar2_table(12) := '697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A202076617220696E74657276616C203D20736574496E74657276616C2866756E6374696F6E2829207B0D0A20202020766172206D6170203D20726567696F6E2E63616C6C2822';
wwv_flow_imp.g_varchar2_table(13) := '6765744D61704F626A65637422293B0D0A2020202069662028747970656F66206D6170203D3D3D2027756E646566696E656427207C7C206D6170203D3D206E756C6C29207B0D0A20202020202072657475726E3B20200D0A202020207D200D0A20202020';
wwv_flow_imp.g_varchar2_table(14) := '636C656172496E74657276616C28696E74657276616C293B202020200D0A2020202069662028216D61702E6D61726B65727329207B0D0A2020202020206D61702E6D61726B657273203D207B7D3B0D0A202020207D0D0A2020202069662028705F67656F';
wwv_flow_imp.g_varchar2_table(15) := '6D203D3D206E756C6C29207B0D0A20202020202069662028705F6D61726B65725F696420696E206D61702E6D61726B65727329207B0D0A20202020202020206D61702E6D61726B6572735B705F6D61726B65725F69645D2E72656D6F766528293B0D0A20';
wwv_flow_imp.g_varchar2_table(16) := '2020202020202064656C657465206D61702E6D61726B6572735B705F6D61726B65725F69645D3B0D0A2020202020207D0D0A20202020202072657475726E3B0D0A202020207D0D0A20202020705F7374796C652E647261676761626C65203D2066616C73';
wwv_flow_imp.g_varchar2_table(17) := '653B0D0A2020202069662028705F6D61726B65725F696420696E206D61702E6D61726B65727329207B0D0A2020202020206D61702E6D61726B6572735B705F6D61726B65725F69645D2E7365744C6E674C6174285B782C20795D293B20200D0A20202020';
wwv_flow_imp.g_varchar2_table(18) := '7D20656C7365207B0D0A202020202020766172206D61726B6572203D206E6577206D61706C69622E4D61726B657228705F7374796C65292E7365744C6E674C6174285B782C20795D292E616464546F286D6170293B0D0A2020202020206D61702E6D6172';
wwv_flow_imp.g_varchar2_table(19) := '6B6572735B705F6D61726B65725F69645D203D206D61726B65723B0D0A202020207D0D0A2020202069662028705F7469746C655F6974656D20262620705F7469746C655F6974656D20213D2022222029207B0D0A202020202020705F7469746C65203D20';
wwv_flow_imp.g_varchar2_table(20) := '617065782E6974656D28705F7469746C655F6974656D292E67657456616C756528293B0D0A202020207D0D0A2020202069662028705F7469746C652026262020705F7469746C6520213D20222229207B0D0A2020202020206D61702E6D61726B6572735B';
wwv_flow_imp.g_varchar2_table(21) := '705F6D61726B65725F69645D2E736574506F707570286E6577206D61706C69622E506F70757028292E73657448544D4C28705F7469746C6529293B0D0A202020207D0D0A20207D2C313030293B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(2072783495977477411)
,p_plugin_id=>wwv_flow_imp.id(2016851460205759717)
,p_file_name=>'mapbits-setcustommarker.js'
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
