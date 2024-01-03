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
--     PLUGIN: 1595698640564333543
--   Manifest End
--   Version:         22.2.8
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_geolocation
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(1595698640564333543)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.GEOLOCATION'
,p_display_name=>'Mapbits Geolocation'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-geolocation.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure map_geolocation_render (',
'    p_item   in            apex_plugin.t_item,',
'    p_plugin in            apex_plugin.t_plugin,',
'    p_param  in            apex_plugin.t_item_render_param,',
'    p_result in out nocopy apex_plugin.t_item_render_result ) is',
'    l_region_id varchar2(400);',
'    l_geometry_modes p_item.attribute_01%type := p_item.attribute_01;',
'    l_geom_collection_name p_item.attribute_02%type := p_item.attribute_02;',
'    l_readonly varchar2(5);',
'    l_geojson clob;',
'    l_show_coords p_item.attribute_04%type := p_item.attribute_04;',
'    l_buffersize number:=80;',
'    l_offset integer;',
'    l_pointZoomLevel p_item.attribute_06%type := nvl(p_item.attribute_06, 12);',
'',
'    l_track varchar2(5);',
'    l_heading varchar2(5);',
'    l_defaultEnabled varchar2(5);',
'begin',
'  if p_item.attribute_01  = ''Y'' then',
'    l_track := ''true'';',
'  else',
'    l_track := ''false'';',
'  end if;',
'  if p_item.attribute_02 = ''Y'' then',
'    l_heading := ''true'';',
'  else',
'    l_heading := ''false'';',
'  end if;',
'  if p_item.attribute_03 = ''Y'' then',
'    l_defaultEnabled := ''true'';',
'  else',
'    l_defaultEnabled := ''false'';',
'  end if;',
'',
'  -- Get the map region id for which this item is associated. If this failed, propagate an error.',
'  begin',
'    select nvl(r.static_id, ''R'' || r.region_id) into l_region_id  ',
'      from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then ',
'      raise_application_error(-20424, ''Configuration ERROR: Geolocation ['' || p_item.name || ''] is not associated with a Map region.'');',
'  end;',
'  htp.p(''<div id="'' || p_item.name || ''" name="'' || p_item.name || ''" style="display: none;"></div>'');',
'',
'  -- Call the javascript',
'  apex_javascript.add_onload_code(p_code => ''apex.jQuery('' || l_region_id || '').on("spatialmapinitialized", function(){',
'    mapbits_geolocation("'' || p_item.name || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id || ''", {"enableDefault" : '' || l_defaultEnabled || '', "trackUserLocation" : '' || l_track || '', "showUserHeading" : ''  || l_heading || ''});',
'    });'', p_key => ''MIL.ARMY.USACE.MAPBITS.GEOLOCATION'');',
'end;'))
,p_api_version=>2
,p_render_function=>'map_geolocation_render'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>If the browser has geolocation enabled, the Mapbits Geolocation plugin can show the user''s location as a pulsing dot.</p>',
'<p>Add the plugin in to the map region in which you wish to show the user''s location. This plugin relays events from Mapbox Geolocation as application express events.</p>'))
,p_version_identifier=>'4.6.20231201'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Geolocation',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_geolocation.sql 18773 2023-12-04 18:42:11Z b2eddjw9 $',
'Date     : $Date: 2023-12-04 12:42:11 -0600 (Mon, 04 Dec 2023) $',
'Revision : $Revision: 18773 $',
'Requires : Application Express >= 21.1',
'',
'Version 4.6 Updates:',
'12/01/2023 Raise an application error if this plugin item is not associated with a Map region.',
'11/20/2023 Hide the JSON text that appeared when geolocation was triggered.',
'',
'Version 4.5 Updates:',
'7/13/2023 Removed use of the ''load'' event to wait for a ready map to activate the control. This does not appear to be necessary since the spatialmapinitialized event is already at the javascript entry point. ',
'',
'Version 4.4 Updates:',
'6/6/2023 Fixed syntax error referencing the region.',
'5/10/2023 Preventing javascript execution if the parent region is hidden.',
'',
'Version 4.3',
'1/27/2023 To work with APEX 22.2, changed event hook to the map region''s spatialmapinitialized event in place of the page''s apexreadyend event.',
'',
'Version 4.2',
'3/10/2022 Added default on option.',
'',
''))
,p_files_version=>53
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1595721576960024679)
,p_plugin_id=>wwv_flow_imp.id(1595698640564333543)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Track User  Location'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'If Yes, move the map with the user, keeping his location in the center of the map.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1595722163607026955)
,p_plugin_id=>wwv_flow_imp.id(1595698640564333543)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Show User Heading'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'If Yes, show the direction in which the user is moving when he is moving.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1588443561335800255)
,p_plugin_id=>wwv_flow_imp.id(1595698640564333543)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Enable by Default'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'If Yes, the Geolocation tool will be enabled when the page renders. Otherwise, the user will have to click a button to start the tool.'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(1595703876565333558)
,p_plugin_id=>wwv_flow_imp.id(1595698640564333543)
,p_name=>'mil_army_usace_mapbits_geolocate'
,p_display_name=>'Geolocate'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(1595719964451833086)
,p_plugin_id=>wwv_flow_imp.id(1595698640564333543)
,p_name=>'mil_army_usace_mapbits_geolocate_error'
,p_display_name=>'Error'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(1595720783136833088)
,p_plugin_id=>wwv_flow_imp.id(1595698640564333543)
,p_name=>'mil_army_usace_mapbits_geolocate_trackend'
,p_display_name=>'Track End'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(1595720325006833088)
,p_plugin_id=>wwv_flow_imp.id(1595698640564333543)
,p_name=>'mil_army_usace_mapbits_geolocate_trackstart'
,p_display_name=>'Track Start'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F67656F6C6F636174696F6E28652C612C6F2C74297B76617220723D6E65772822756E646566696E6564223D3D747970656F66206D61706C69627265676C3F6D6170626F78676C3A6D61706C69627265676C292E';
wwv_flow_imp.g_varchar2_table(2) := '47656F6C6F63617465436F6E74726F6C287B706F736974696F6E4F7074696F6E733A7B656E61626C654869676841636375726163793A21307D2C747261636B557365724C6F636174696F6E3A742E747261636B557365724C6F636174696F6E2C73686F77';
wwv_flow_imp.g_varchar2_table(3) := '5573657248656164696E673A742E73686F775573657248656164696E677D292C693D617065782E726567696F6E286F293B6E756C6C213D693F28692E63616C6C28226765744D61704F626A65637422292E616464436F6E74726F6C2872292C617065782E';
wwv_flow_imp.g_varchar2_table(4) := '6A517565727928222E6D6170626F78676C2D6374726C2D67726F757022292E616464436C61737328226D61706C69627265676C2D6374726C2D67726F757022292C617065782E6A517565727928222E6D6170626F78676C2D6374726C22292E616464436C';
wwv_flow_imp.g_varchar2_table(5) := '61737328226D61706C69627265676C2D6374726C22292C722E6F6E282267656F6C6F63617465222C2866756E6374696F6E2861297B617065782E6974656D2865292E73657456616C756528277B2274797065223A2022506F696E74222C2022636F6F7264';
wwv_flow_imp.g_varchar2_table(6) := '696E61746573223A5B272B612E636F6F7264732E6C6F6E6769747564652B222C20222B612E636F6F7264732E6C617469747564652B225D7D22292C617065782E6576656E742E7472696767657228617065782E6A5175657279282223222B65292C226D69';
wwv_flow_imp.g_varchar2_table(7) := '6C5F61726D795F75736163655F6D6170626974735F67656F6C6F63617465222C61297D29292C722E6F6E28226572726F72222C2866756E6374696F6E2861297B617065782E6576656E742E7472696767657228617065782E6A5175657279282223222B65';
wwv_flow_imp.g_varchar2_table(8) := '292C226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F636174655F6572726F72222C61297D29292C722E6F6E2822747261636B757365726C6F636174696F6E7374617274222C2866756E6374696F6E28297B617065782E6576656E';
wwv_flow_imp.g_varchar2_table(9) := '742E7472696767657228617065782E6A5175657279282223222B65292C226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F636174655F747261636B737461727422297D29292C722E6F6E2822747261636B757365726C6F63617469';
wwv_flow_imp.g_varchar2_table(10) := '6F6E656E64222C2866756E6374696F6E28297B617065782E6576656E742E7472696767657228617065782E6A5175657279282223222B65292C226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F636174655F747261636B656E6422';
wwv_flow_imp.g_varchar2_table(11) := '297D29292C617065782E6A517565727928222E6D6170626F78676C2D6374726C2D67656F6C6F6361746522292E747269676765722822636C69636B2229293A636F6E736F6C652E6C6F6728226D6170626974735F67656F6C6F636174696F6E20222B652B';
wwv_flow_imp.g_varchar2_table(12) := '22203A20526567696F6E205B222B6F2B225D2069732068696464656E206F72206D697373696E672E22297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(1010147978749514259)
,p_plugin_id=>wwv_flow_imp.id(1595698640564333543)
,p_file_name=>'mapbits-geolocation.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F67656F6C6F636174696F6E28705F6974656D5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F6F7074696F6E7329207B0D0A20202F2F204163636F6D6F646174';
wwv_flow_imp.g_varchar2_table(2) := '6520626F7468204D6170626F7820696E204150455820323120616E64204D61706C6962726520696E20415045582032322E0D0A2020766172206D61706C6962203D20747970656F66206D61706C69627265676C203D3D3D2027756E646566696E65642720';
wwv_flow_imp.g_varchar2_table(3) := '3F206D6170626F78676C203A206D61706C69627265676C3B090D0A20200D0A20202F2F2072616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D65737361676520616E6420777269746520746F20636F6E';
wwv_flow_imp.g_varchar2_table(4) := '736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C657274286D7367293B636F6E736F6C652E6C6F6728';
wwv_flow_imp.g_varchar2_table(5) := '6D7367293B7D293B0D0A20207D0D0A20200D0A20207661722067656F6C6F6361746F72203D206E6577206D61706C69622E47656F6C6F63617465436F6E74726F6C287B0D0A20202020706F736974696F6E4F7074696F6E733A207B0D0A20202020202065';
wwv_flow_imp.g_varchar2_table(6) := '6E61626C654869676841636375726163793A20747275650D0A202020207D2C0D0A20202020747261636B557365724C6F636174696F6E3A20705F6F7074696F6E732E747261636B557365724C6F636174696F6E2C0D0A2020202073686F77557365724865';
wwv_flow_imp.g_varchar2_table(7) := '6164696E673A20705F6F7074696F6E732E73686F775573657248656164696E670D0A20207D293B0D0A20200D0A202076617220726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F6964293B0D0A202069662028726567696F6E20';
wwv_flow_imp.g_varchar2_table(8) := '3D3D206E756C6C29207B0D0A20202020636F6E736F6C652E6C6F6728276D6170626974735F67656F6C6F636174696F6E2027202B20705F6974656D5F6964202B2027203A20526567696F6E205B27202B20705F726567696F6E5F6964202B20275D206973';
wwv_flow_imp.g_varchar2_table(9) := '2068696464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A20200D0A2020766172206D6170203D20726567696F6E2E63616C6C28226765744D61704F626A65637422293B0D0A20206D61702E616464436F6E';
wwv_flow_imp.g_varchar2_table(10) := '74726F6C2867656F6C6F6361746F72293B0D0A20200D0A20202F2F204163636F6D6F6461746520626F7468204D6170626F7820696E204150455820323120616E64204D61706C6962726520696E20415045582032322E090D0A2020617065782E6A517565';
wwv_flow_imp.g_varchar2_table(11) := '727928272E6D6170626F78676C2D6374726C2D67726F757027292E616464436C61737328276D61706C69627265676C2D6374726C2D67726F757027293B0D0A2020617065782E6A517565727928272E6D6170626F78676C2D6374726C27292E616464436C';
wwv_flow_imp.g_varchar2_table(12) := '61737328276D61706C69627265676C2D6374726C27293B0D0A20200D0A202067656F6C6F6361746F722E6F6E282767656F6C6F63617465272C2066756E6374696F6E286461746129207B0D0A20202020617065782E6974656D28705F6974656D5F696429';
wwv_flow_imp.g_varchar2_table(13) := '2E73657456616C756528277B2274797065223A2022506F696E74222C2022636F6F7264696E61746573223A5B27202B20646174612E636F6F7264732E6C6F6E676974756465202B20272C2027202B20646174612E636F6F7264732E6C6174697475646520';
wwv_flow_imp.g_varchar2_table(14) := '2B20275D7D27293B0D0A20202020617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F63617465222C2064';
wwv_flow_imp.g_varchar2_table(15) := '617461293B0D0A20207D293B0D0A202067656F6C6F6361746F722E6F6E28276572726F72272C2066756E6374696F6E286461746129207B617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B20705F6974656D5F69';
wwv_flow_imp.g_varchar2_table(16) := '64292C20226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F636174655F6572726F72222C2064617461293B7D293B0D0A202067656F6C6F6361746F722E6F6E2827747261636B757365726C6F636174696F6E7374617274272C2066';
wwv_flow_imp.g_varchar2_table(17) := '756E6374696F6E2829207B617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F636174655F747261636B73';
wwv_flow_imp.g_varchar2_table(18) := '7461727422293B7D293B0D0A202067656F6C6F6361746F722E6F6E2827747261636B757365726C6F636174696F6E656E64272C2066756E6374696F6E2829207B617065782E6576656E742E7472696767657228617065782E6A517565727928222322202B';
wwv_flow_imp.g_varchar2_table(19) := '20705F6974656D5F6964292C20226D696C5F61726D795F75736163655F6D6170626974735F67656F6C6F636174655F747261636B656E6422293B7D293B0D0A2020617065782E6A517565727928272E6D6170626F78676C2D6374726C2D67656F6C6F6361';
wwv_flow_imp.g_varchar2_table(20) := '746527292E747269676765722827636C69636B27293B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(1595707585373404878)
,p_plugin_id=>wwv_flow_imp.id(1595698640564333543)
,p_file_name=>'mapbits-geolocation.js'
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
