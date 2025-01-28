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
--   Date and Time:   16:17 Tuesday January 28, 2025
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 619713254656829078
--   Manifest End
--   Version:         23.2.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_legend_entry
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(619713254656829078)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LEGEND_ENTRY'
,p_display_name=>'Mapbits Legend Entry'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-legend-entry#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure mapbits_legendentry',
'(',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_render_param,',
'  p_result in out nocopy apex_plugin.t_item_render_result',
') is',
'begin',
'  htp.p(''<div id="'' || p_item.name || ''"></div>'');',
'  apex_javascript.add_onload_code(',
'    p_code => ''mapbits_legend_entry({''',
'    || apex_javascript.add_attribute(''p_item_id'', p_item.name)',
'    || ''});'');',
'end;'))
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'mapbits_legendentry'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'A Mapbits Legend Entry Page Item can be added to a Mapbits Legend Region to add customization options to the legend. If the legend entry is associated with a Lodestar layer, it can be used for effects such as displaying a layer''s symbology, toggling '
||'a layer visibility, and others. Additionally a Mapbits Legend Entry Page Item can be used without a Lodestar layer association add spacing and grouping effects to the Legend. For more information see the help on the inidividual attributes of the Mapb'
||'its Legend Entry Page Item.',
'',
'A Mapbits Legend Entry Page Item added to a Region that is not a Mapbits Legend will have no effect. A Mapbits Legend Entry Page Item can not be associated with a non-Lodestar layer.'))
,p_version_identifier=>'4.8.20250128'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Legend Entry',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_legend_entry.sql 20090 2025-01-28 22:41:13Z b2eddjw9 $',
'Date     : $Date: 2025-01-28 16:41:13 -0600 (Tue, 28 Jan 2025) $',
'Revision : $Revision: 20090 $',
'Requires : Application Express >= 22.2',
'',
'07/29/2024 - Add item API with hide() and show() methods, and setCollapsed() for the Legend region to use',
'',
'Version 4.7 Updates:',
'04/24/2024 - Allow WMS and ArcGIS REST items in the Mapbits Layer Item attribute. Show spinner when a layer is loading. Gray out entries when the layer is invisible due to its zoom range. Add Outline Color attribute.',
'',
'Version 4.6 Updates:',
'02/28/2024 - Add more standard icons (dotted line, large/small circle).',
'02/27/2024 - Add Collapsible attribute for headings. Implement click event support.',
'02/26/2024 - Added Legend Entry item.'))
,p_files_version=>13
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(624082993685910902)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Mapbits Layer Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'A Lodestar, ArcGIS REST, or WMS item to associate with this entry. If set, the entry''s default appearance will derive from the layer''s settings, and features like toggling the layer will be available.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(620938346247682222)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'The title to show in the legend for the entry.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(620940038809703937)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#fffacd',
'red',
'rgb(255, 99, 71)'))
,p_help_text=>'The color of the icon.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(623733243169224543)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Options'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'show_help:show_inline_help'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(623737287987227130)
,p_plugin_attribute_id=>wwv_flow_imp.id(623733243169224543)
,p_display_sequence=>10
,p_display_value=>'Toggleable'
,p_return_value=>'toggleable'
,p_help_text=>'Include a button to show/hide the layer. Requires "Lodestar Layer Item" to be set.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(623737702268228139)
,p_plugin_attribute_id=>wwv_flow_imp.id(623733243169224543)
,p_display_sequence=>20
,p_display_value=>'Is Heading'
,p_return_value=>'heading'
,p_help_text=>'The item appears as a heading for other items.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(623738147292229478)
,p_plugin_attribute_id=>wwv_flow_imp.id(623733243169224543)
,p_display_sequence=>30
,p_display_value=>'Show Help Button'
,p_return_value=>'show_help'
,p_help_text=>'Show the the help button if the Legend Entry or Lodestar Layer has help text.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(623738563277232179)
,p_plugin_attribute_id=>wwv_flow_imp.id(623733243169224543)
,p_display_sequence=>40
,p_display_value=>'Show Inline Help'
,p_return_value=>'show_inline_help'
,p_help_text=>'Show inline help below the title if the Legend Entry or Lodestar Layer has inline help text.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(623738900512233865)
,p_plugin_attribute_id=>wwv_flow_imp.id(623733243169224543)
,p_display_sequence=>50
,p_display_value=>'Collapsible'
,p_return_value=>'collapsible'
,p_help_text=>'Whether the heading is collapsible. If so, collapsing it will hide all entries until the next header (or the end of the list).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(622274953578443179)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Icon Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(622278658318457517)
,p_plugin_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_display_sequence=>5
,p_display_value=>'No Icon'
,p_return_value=>'none'
,p_help_text=>'The layer has no icon'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(622484181621189762)
,p_plugin_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_display_sequence=>7
,p_display_value=>'No icon, but leave space'
,p_return_value=>'blank'
,p_help_text=>'Don''t show an icon, but leave the space where it would be so the text lines up.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(622275840800445159)
,p_plugin_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_display_sequence=>10
,p_display_value=>'Icon Class'
,p_return_value=>'icon_class'
,p_help_text=>'The icon is defined by a Font APEX class.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(622277830600448350)
,p_plugin_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_display_sequence=>20
,p_display_value=>'Line'
,p_return_value=>'line'
,p_help_text=>'A standard icon for line layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(623467165890575477)
,p_plugin_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_display_sequence=>21
,p_display_value=>'Line (Dotted)'
,p_return_value=>'line_dotted'
,p_help_text=>'A standard icon for dotted line layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(622278241215449456)
,p_plugin_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_display_sequence=>30
,p_display_value=>'Polygon'
,p_return_value=>'polygon'
,p_help_text=>'A standard icon for polygon layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(623474925425592822)
,p_plugin_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_display_sequence=>40
,p_display_value=>'Circle'
,p_return_value=>'circle'
,p_help_text=>'A standard icon for circle layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(623508653643625788)
,p_plugin_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_display_sequence=>41
,p_display_value=>'Circle (Small)'
,p_return_value=>'circle_small'
,p_help_text=>'A smaller standard icon for circle layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(622280307181460937)
,p_plugin_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_display_sequence=>50
,p_display_value=>'Icon URL'
,p_return_value=>'url'
,p_help_text=>'The icon is defined by a URL (e.g. a static application file).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(622284136707531860)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Icon Class'
,p_attribute_type=>'ICON'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'icon_class'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(622285364052534081)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Icon URL'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(622274953578443179)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'url'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(456073089542468776)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>35
,p_prompt=>'Outline Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'The color of the icon''s outline.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F6C6567656E645F656E747279287B705F6974656D5F69647D29207B0D0A20202F2F20546869732048544D4C20656C656D656E74206973206372656174656420766961204A61766153637269707420696E207468';
wwv_flow_imp.g_varchar2_table(2) := '65204C6567656E6420726567696F6E20636F64652E0D0A2020636F6E73742068746D6C5F6964203D20705F6974656D5F6964202B20275F6D6170626974735F6C6567656E645F656E747279273B0D0A0D0A20206C657420697348696464656E203D206661';
wwv_flow_imp.g_varchar2_table(3) := '6C73653B0D0A20206C6574206973436F6C6C6170736564203D2066616C73653B0D0A0D0A2020636F6E7374207570646174655669736962696C697479203D202829203D3E207B0D0A202020202428272327202B2068746D6C5F6964292E746F67676C6528';
wwv_flow_imp.g_varchar2_table(4) := '21697348696464656E20262620216973436F6C6C6170736564293B0D0A20207D3B0D0A0D0A2020617065782E6974656D2E63726561746528705F6974656D5F69642C207B0D0A20202020686964653A202829203D3E207B0D0A2020202020206973486964';
wwv_flow_imp.g_varchar2_table(5) := '64656E203D20747275653B0D0A2020202020207570646174655669736962696C69747928293B0D0A202020207D2C0D0A2020202073686F773A202829203D3E207B0D0A202020202020697348696464656E203D2066616C73653B0D0A2020202020207570';
wwv_flow_imp.g_varchar2_table(6) := '646174655669736962696C69747928293B0D0A202020207D2C0D0A20202020736574436F6C6C61707365643A2028636F6C6C617073656429203D3E207B0D0A2020202020206973436F6C6C6170736564203D20636F6C6C61707365643B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(7) := '207570646174655669736962696C69747928293B0D0A202020207D2C0D0A20207D290D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(521138700418229859)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_file_name=>'mapbits-legend-entry.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F6C6567656E645F656E747279287B705F6974656D5F69643A657D297B636F6E737420743D652B225F6D6170626974735F6C6567656E645F656E747279223B6C6574206E3D21312C693D21313B636F6E73742073';
wwv_flow_imp.g_varchar2_table(2) := '3D28293D3E7B24282223222B74292E746F67676C6528216E26262169297D3B617065782E6974656D2E63726561746528652C7B686964653A28293D3E7B6E3D21302C7328297D2C73686F773A28293D3E7B6E3D21312C7328297D2C736574436F6C6C6170';
wwv_flow_imp.g_varchar2_table(3) := '7365643A653D3E7B693D652C7328297D7D297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(521195189585363473)
,p_plugin_id=>wwv_flow_imp.id(619713254656829078)
,p_file_name=>'mapbits-legend-entry.min.js'
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
