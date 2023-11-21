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
--   Date and Time:   10:05 Friday November 17, 2023
--   Exported By:     GREP
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 154769149359436325
--   Manifest End
--   Version:         22.2.8
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/mil_army_usace_mapbits_export_to_image
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(154769149359436325)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MIL.ARMY.USACE.MAPBITS.EXPORT_TO_IMAGE'
,p_display_name=>'Mapbits Export to Image'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-export.min.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function mapbits_export_ajax (',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin )',
'return apex_plugin.t_dynamic_action_ajax_result is',
'  l_image_collection_name varchar2(32);',
'  l_imagetxt clob;',
'  l_buffer_clob clob;',
'  l_chunk_no number;',
'  l_format varchar2(200);',
'  rt apex_plugin.t_dynamic_action_ajax_result;',
'begin',
'  if apex_application.g_x10 = ''WRITEBACK'' then',
'    -- Write parts of a base 64-encoded images to the clob column of a collection. (Can''t pass large datasets without splitting them.)',
'    l_image_collection_name := apex_application.g_x01;',
'    if not l_image_collection_name is null then',
'      l_imagetxt := apex_application.g_x02;',
'      l_chunk_no := apex_application.g_x03;',
'      l_format := apex_application.g_x04;',
'',
'      -- If this is the first writeback for the image, then create / truncate apex collection and add a single member. Put the input data into the',
'      -- clob column. Otherwise, update the existing member by appending the input data to existing data in the clob column.',
'      if l_chunk_no is null or l_chunk_no = 0 then',
'        apex_collection.create_or_truncate_collection(p_collection_name => l_image_collection_name);',
'        apex_collection.add_member(p_collection_name => l_image_collection_name,  p_clob001 => l_imagetxt, p_c001 => l_format);',
'      else',
'        dbms_lob.createtemporary(l_buffer_clob, TRUE);',
'        select clob001 into l_buffer_clob from apex_collections where collection_name = l_image_collection_name and seq_id = 1;',
'        l_buffer_clob := l_buffer_clob || l_imagetxt;',
'        apex_collection.update_member(p_collection_name => l_image_collection_name, p_seq =>1, p_clob001 => l_buffer_clob );',
'        dbms_lob.freetemporary(l_buffer_clob);',
'      end if;',
'      htp.p(''{"Status" : "No Error"}'');',
'    else',
'      htp.p(''{"Status" : "[XYZZY] No Imagery Collection Name specified. Nothing happens."}'');',
'    end if;',
'  elsif apex_application.g_x10 = ''WRITEBACK_FINISH'' then',
'    -- On the WRITEBACK_FINISH operation, convert the clob in the apex collection to a blob and store it in the member blob column. ',
'    -- We only create the blob at the end for performance reasons.',
'    l_image_collection_name := apex_application.g_x01;',
'    select clob001 into l_buffer_clob from apex_collections where collection_name = l_image_collection_name;',
'    apex_collection.update_member(p_collection_name => l_image_collection_name, p_seq =>1, p_clob001 => l_buffer_clob, p_blob001 => apex_web_service.clobbase642blob(l_buffer_clob) );',
'    htp.p(''{"Status" : "No Error"}'');',
'  end if; ',
'  return rt;',
'end;',
'',
'function mapbits_export (',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin )',
'return apex_plugin.t_dynamic_action_render_result is',
'  l_region_id varchar2(4000);',
'  l_error varchar2(4000);',
'  rt apex_plugin.t_dynamic_action_render_result;',
'  -- fetch attribute values',
'  l_image_collection_name p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'  l_image_format p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'begin',
'  -- Get the affected region, which must be the map region, to use for the export.',
'  -- If not found or the region is not a map, then return an error. ',
'  begin',
'    select nvl(r.static_id, ''R''||da.affected_region_id) into l_region_id',
'      from apex_application_page_da_acts da, apex_application_page_regions r',
'      where da.affected_region_id = r.region_id',
'      and da.application_id = v(''APP_ID'') and da.page_id = v(''APP_PAGE_ID'')',
'      and da.action_id = p_dynamic_action.id',
'      and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then',
'      apex_debug.message(',
'        p_message => ''ERROR: Mapbits Export to Image DA [%s] is not associated with a Map region.'',',
'        p0      => p_dynamic_action.id,',
'        p_level   => apex_debug.c_log_level_error',
'      );',
'      l_error := l_error || ''Configuration ERROR: Map Layer Zoom to Boundary DA is not associated with a Map region.'';',
'  end;',
'',
'  -- Call the function, pass in the plugin attributes.',
'  rt.javascript_function := ''function () {'' ||',
'    ''mapbits_export("'' || p_dynamic_action.id || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", {'' || ',
'      ''"collection" : "'' || l_image_collection_name || ''", '' || ',
'      ''"format" : "''     || l_image_format || ',
'    ''"});}'';',
'  return rt;',
'end;'))
,p_api_version=>2
,p_render_function=>'mapbits_export'
,p_ajax_function=>'mapbits_export_ajax'
,p_standard_attributes=>'ITEM:REGION:REQUIRED'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The Mapbits Export Image plugin is a dynamic action that exports the canvas of an APEX Map Region to an image and stores the image into an APEX Collection. ',
'Upon execution of the dynamic action:</p>',
'<ul>',
'<li>The C001 column will store the mime type of the map image.</li>',
'<li>The CLOB001 column will store the map image using base64 encoding (without the "data:<format>," prefix).</li>',
'<li>The BLOB001 column will store the map image in binary form.</li>',
'</ul>',
'<p>The collection only uses one member; Multiple executions of the dynamic action will overwrite the same member in the Apex Collection.</p>',
'<p>The export process happens asynchronously. When export is complete, the plugin will trigger a ''Map Export Completed'' event, indicating that the image is completely written into the Collection. If you',
'take additional steps, such as generating a PDF, after exporting a map image, you will need to make a dynamic action responding to this event or else you will find a null or partial image in the Collection.</p>'))
,p_version_identifier=>'4.6.20231116'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Export To Image',
'Location : $Id: dynamic_action_plugin_mil_army_usace_mapbits_export_to_image.sql 18714 2023-11-17 16:08:44Z b2imimcf $',
'Date     : $Date: 2023-11-17 10:08:44 -0600 (Fri, 17 Nov 2023) $',
'Revision : $Revision: 18714 $',
'Requires : Application Express >= 21.1',
'',
'Version 4.6 Updates:',
'11/16/2023 Initial Implementation.'))
,p_files_version=>100
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(154773215029460856)
,p_plugin_id=>wwv_flow_imp.id(154769149359436325)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Export Image Collection Name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_help_text=>'Name of Apex Collection to which the map image is exported.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(154773705589462724)
,p_plugin_id=>wwv_flow_imp.id(154769149359436325)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Image Format'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'image/png'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(154774068462463713)
,p_plugin_attribute_id=>wwv_flow_imp.id(154773705589462724)
,p_display_sequence=>10
,p_display_value=>'PNG (Portable Network Graphics)'
,p_return_value=>'image/png'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(154774464636466453)
,p_plugin_attribute_id=>wwv_flow_imp.id(154773705589462724)
,p_display_sequence=>20
,p_display_value=>'JPEG (Joint Photographic Experts Group)'
,p_return_value=>'image/jpeg'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(154787611803770123)
,p_plugin_id=>wwv_flow_imp.id(154769149359436325)
,p_name=>'mil_army_usace_mapbits_export_create'
,p_display_name=>'Map Export Completed'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F6578706F727428705F616374696F6E5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F6F7074696F6E7329207B200D0A20202F2F2072616973652061206A6176';
wwv_flow_imp.g_varchar2_table(2) := '6173637269707420616C65727420776974682074686520696E707574206D6573736167652C206D73672C20616E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(3) := '617065782E6A51756572792866756E6374696F6E28297B636F6E736F6C652E6C6F6728705F616374696F6E5F6964202B20222022202B206D7367293B7D293B0D0A20207D0D0A0D0A20202F2F204D616B65207661726961626C65732066726F6D20706C75';
wwv_flow_imp.g_varchar2_table(4) := '67696E20617474726962757465730D0A202076617220705F636F6C6C656374696F6E203D20705F6F7074696F6E735B27636F6C6C656374696F6E275D3B0D0A202076617220705F666F726D6174203D20705F6F7074696F6E735B27666F726D6174275D3B';
wwv_flow_imp.g_varchar2_table(5) := '0D0A0D0A20202F2A0D0A2020202A2063616C6C20616A61782073657276696365206F662074686520706C7567696E20776974682074686520696E70757420696D61676520746F207772697465206974206261636B20746F20746865207061676520697465';
wwv_flow_imp.g_varchar2_table(6) := '6D20616E6420696E70757420696D61676520636F6C6C656374696F6E0D0A2020202A206173206261736536342E204C6172676520646174612069732073747265616D65642E0D0A2020202A2F0D0A202066756E6374696F6E207772697465496D61676528';
wwv_flow_imp.g_varchar2_table(7) := '696D61676529207B0D0A202020207661722064656661756C745F637572736F72203D20646F63756D656E742E626F64792E7374796C652E637572736F723B0D0A202020206966202864656661756C745F637572736F72203D3D20226E6F742D616C6C6F77';
wwv_flow_imp.g_varchar2_table(8) := '65642229207B0D0A20202020202064656661756C745F637572736F72203D206E756C6C3B0D0A0920207D0D0A202020206966202821696D61676529207B0D0A202020202020617065782E7365727665722E706C7567696E28705F616A61785F6964656E74';
wwv_flow_imp.g_varchar2_table(9) := '69666965722C207B0D0A20202020202020207831303A202257524954454241434B222C0D0A20202020202020207830313A20705F636F6C6C656374696F6E2C0D0A20202020202020207830323A206E756C6C2C0D0A20202020202020207830333A206E75';
wwv_flow_imp.g_varchar2_table(10) := '6C6C2C0D0A20202020202020207830343A20705F666F726D61740D0A2020202020207D2C207B0D0A2020202020202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A20202020202020202020646F63756D656E742E626F6479';
wwv_flow_imp.g_varchar2_table(11) := '2E7374796C652E637572736F72203D2064656661756C745F637572736F723B0D0A20202020202020207D2C0D0A20202020202020206572726F723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(12) := '202020646F63756D656E742E626F64792E7374796C652E637572736F72203D2064656661756C745F637572736F723B0D0A20202020202020202020617065785F616C65727428657272293B0D0A20202020202020207D0D0A2020202020207D293B0D0A20';
wwv_flow_imp.g_varchar2_table(13) := '2020207D20656C7365207B0D0A2020202020202F2F2074686973206461746120636F756C64206265206269672E204C657427732073747265616D206974206261636B20746F20746865207365727665720D0A2020202020202F2F20696620776520617265';
wwv_flow_imp.g_varchar2_table(14) := '20686F6C64696E6720697420696E206120636F6C6C656374696F6E2074686572652E20646F2074686973207468726F7567680D0A2020202020202F2F20636861696E656420616A61782063616C6C732E207573652074686520637572736F722069636F6E';
wwv_flow_imp.g_varchar2_table(15) := '20746F206C65742075736572206B6E6F770D0A2020202020202F2F20746861742064617461206973206265696E67207472616E736665727265642E0D0A20202020202066756E6374696F6E206368756E6B28646174612C207374617274496E6465782C20';
wwv_flow_imp.g_varchar2_table(16) := '6275666665724C656E2C207375636365737346756E6329207B0D0A2020202020202020696620287374617274496E646578203E3D20646174612E6C656E67746829207B0D0A20202020202020202020617065782E7365727665722E706C7567696E28705F';
wwv_flow_imp.g_varchar2_table(17) := '616A61785F6964656E7469666965722C207B0D0A2020202020202020202020207831303A202257524954454241434B5F46494E495348222C0D0A2020202020202020202020207830313A20705F636F6C6C656374696F6E0D0A202020202020202020207D';
wwv_flow_imp.g_varchar2_table(18) := '2C200D0A202020202020202020207B0D0A202020202020202020202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A20202020202020202020202020207375636365737346756E6328293B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(19) := '7D2C0D0A2020202020202020202020206572726F723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A2020202020202020202020202020617065785F616C6572742827596F75206661696C697427202B2065727229';
wwv_flow_imp.g_varchar2_table(20) := '3B0D0A2020202020202020202020207D0D0A202020202020202020207D293B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B';
wwv_flow_imp.g_varchar2_table(21) := '0D0A2020202020202020202020207831303A202257524954454241434B222C0D0A2020202020202020202020207830313A20705F636F6C6C656374696F6E2C0D0A2020202020202020202020207830323A20646174612E73756273747228737461727449';
wwv_flow_imp.g_varchar2_table(22) := '6E6465782C206275666665724C656E292C0D0A2020202020202020202020207830333A207374617274496E6465782C0D0A2020202020202020202020207830343A20705F666F726D61740D0A202020202020202020207D2C200D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(23) := '207B0D0A202020202020202020202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A20202020202020202020202020206368756E6B28646174612C207374617274496E646578202B206275666665724C656E2C206275666665';
wwv_flow_imp.g_varchar2_table(24) := '724C656E2C207375636365737346756E63293B0D0A2020202020202020202020207D2C0D0A2020202020202020202020206572726F723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(25) := '202020617065785F616C65727428657272293B0D0A2020202020202020202020207D0D0A202020202020202020207D293B0D0A20202020202020207D0D0A2020202020207D0D0A202020202020646F63756D656E742E626F64792E7374796C652E637572';
wwv_flow_imp.g_varchar2_table(26) := '736F72203D20226E6F742D616C6C6F776564223B0D0A2020202020206368756E6B28696D6167652C20302C2033303030302C2066756E6374696F6E202829207B200D0A20202020202020202F2F206F6E63652074686520777269746520697320636F6D70';
wwv_flow_imp.g_varchar2_table(27) := '6C6574652C20726573746F72652074686520637572736F7220616E64207472696767657220616E206576656E7420746F206265207573656420696E20415045582E0D0A2020202020202020646F63756D656E742E626F64792E7374796C652E637572736F';
wwv_flow_imp.g_varchar2_table(28) := '72203D2064656661756C745F637572736F723B200D0A2020202020202020617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B20705F726567696F6E5F6964292C20226D696C5F61726D795F75736163655F6D6170';
wwv_flow_imp.g_varchar2_table(29) := '626974735F6578706F72745F63726561746522293B0D0A2020202020207D293B0D0A202020207D0D0A20207D0D0A20200D0A20202F2F206765742074686520726567696F6E206F626A6563742E20427265616B206F7574206966206974206973206E6F74';
wwv_flow_imp.g_varchar2_table(30) := '2072656E64657265642E0D0A202076617220726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D0A202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020636F6E736F6C652E6C6F6728276D617062';
wwv_flow_imp.g_varchar2_table(31) := '6974735F7A6F6F6D2027202B20705F616374696F6E5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20';
wwv_flow_imp.g_varchar2_table(32) := '207D0D0A0D0A20202F2F2049746572617465206F7665722063616C6C7320746F20276765744D61704F626A6563742720756E74696C2077652067657420746865206D61702E200D0A2020636F6E737420696E74657276616C203D20736574496E74657276';
wwv_flow_imp.g_varchar2_table(33) := '616C2866756E6374696F6E2829207B0D0A20202020636F6E7374206D6170203D20726567696F6E2E63616C6C28226765744D61704F626A65637422293B0D0A2020202069662028747970656F66206D6170203D3D3D2027756E646566696E656427207C7C';
wwv_flow_imp.g_varchar2_table(34) := '206D6170203D3D206E756C6C29207B2020200D0A20202020202072657475726E3B20200D0A202020207D0D0A20202020636C656172496E74657276616C28696E74657276616C293B0D0A202020206D61702E6F6E6365282772656E646572272C2066756E';
wwv_flow_imp.g_varchar2_table(35) := '6374696F6E2829207B0D0A202020202020766172206D6170496D616765203D20646F63756D656E742E676574456C656D656E744279496428705F726567696F6E5F6964292E717565727953656C6563746F7228272E6D61706C69627265676C2D63616E76';
wwv_flow_imp.g_varchar2_table(36) := '617327292E746F4461746155524C28705F666F726D6174293B0D0A2020202020206D6170496D616765203D206D6170496D6167652E737562737472286D6170496D6167652E696E6465784F6628272C2729202B2031293B0D0A2020202020207772697465';
wwv_flow_imp.g_varchar2_table(37) := '496D616765286D6170496D616765293B0D0A202020207D293B0D0A202020206D61702E72656472617728293B0D0A20207D2C313030293B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(154771345242436333)
,p_plugin_id=>wwv_flow_imp.id(154769149359436325)
,p_file_name=>'mapbits-export.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F6578706F727428652C6E2C6F2C72297B66756E6374696F6E2074286E297B617065782E6A5175657279282866756E6374696F6E28297B636F6E736F6C652E6C6F6728652B2220222B6E297D29297D7661722063';
wwv_flow_imp.g_varchar2_table(2) := '3D722E636F6C6C656374696F6E2C753D722E666F726D61743B766172206C3D617065782E726567696F6E286F293B6966286E756C6C3D3D6C2972657475726E20766F696420636F6E736F6C652E6C6F6728226D6170626974735F7A6F6F6D20222B652B22';
wwv_flow_imp.g_varchar2_table(3) := '203A20526567696F6E205B222B6F2B225D2069732068696464656E206F72206D697373696E672E22293B636F6E737420733D736574496E74657276616C282866756E6374696F6E28297B636F6E737420653D6C2E63616C6C28226765744D61704F626A65';
wwv_flow_imp.g_varchar2_table(4) := '637422293B766F69642030213D3D6526266E756C6C213D65262628636C656172496E74657276616C2873292C652E6F6E6365282272656E646572222C2866756E6374696F6E28297B76617220652C722C6C3D646F63756D656E742E676574456C656D656E';
wwv_flow_imp.g_varchar2_table(5) := '7442794964286F292E717565727953656C6563746F7228222E6D61706C69627265676C2D63616E76617322292E746F4461746155524C2875293B6C3D6C2E737562737472286C2E696E6465784F6628222C22292B31292C653D6C2C226E6F742D616C6C6F';
wwv_flow_imp.g_varchar2_table(6) := '776564223D3D28723D646F63756D656E742E626F64792E7374796C652E637572736F7229262628723D6E756C6C292C653F28646F63756D656E742E626F64792E7374796C652E637572736F723D226E6F742D616C6C6F776564222C66756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(7) := '65286F2C722C6C2C73297B723E3D6F2E6C656E6774683F617065782E7365727665722E706C7567696E286E2C7B7831303A2257524954454241434B5F46494E495348222C7830313A637D2C7B737563636573733A66756E6374696F6E2865297B7328297D';
wwv_flow_imp.g_varchar2_table(8) := '2C6572726F723A66756E6374696F6E28652C6E2C6F297B742822596F75206661696C6974222B6F297D7D293A617065782E7365727665722E706C7567696E286E2C7B7831303A2257524954454241434B222C7830313A632C7830323A6F2E737562737472';
wwv_flow_imp.g_varchar2_table(9) := '28722C6C292C7830333A722C7830343A757D2C7B737563636573733A66756E6374696F6E286E297B65286F2C722B6C2C6C2C73297D2C6572726F723A66756E6374696F6E28652C6E2C6F297B74286F297D7D297D28652C302C3365342C2866756E637469';
wwv_flow_imp.g_varchar2_table(10) := '6F6E28297B646F63756D656E742E626F64792E7374796C652E637572736F723D722C617065782E6576656E742E7472696767657228617065782E6A5175657279282223222B6F292C226D696C5F61726D795F75736163655F6D6170626974735F6578706F';
wwv_flow_imp.g_varchar2_table(11) := '72745F63726561746522297D2929293A617065782E7365727665722E706C7567696E286E2C7B7831303A2257524954454241434B222C7830313A632C7830323A6E756C6C2C7830333A6E756C6C2C7830343A757D2C7B737563636573733A66756E637469';
wwv_flow_imp.g_varchar2_table(12) := '6F6E2865297B646F63756D656E742E626F64792E7374796C652E637572736F723D727D2C6572726F723A66756E6374696F6E28652C6E2C6F297B646F63756D656E742E626F64792E7374796C652E637572736F723D722C74286F297D7D297D29292C652E';
wwv_flow_imp.g_varchar2_table(13) := '7265647261772829297D292C313030297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(155417780395440760)
,p_plugin_id=>wwv_flow_imp.id(154769149359436325)
,p_file_name=>'mapbits-export.min.js'
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
