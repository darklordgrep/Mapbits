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
--   Date and Time:   09:58 Thursday May 9, 2024
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 421848514324861404
--   Manifest End
--   Version:         22.2.8
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
 p_id=>wwv_flow_imp.id(421848514324861404)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LEGEND_ENTRY'
,p_display_name=>'Mapbits Legend Entry'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
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
'end;'))
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
,p_version_identifier=>'4.7.20240509'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Legend Entry',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_legend_entry.sql 19115 2024-05-09 15:00:25Z b2eddjw9 $',
'Date     : $Date: 2024-05-09 10:00:25 -0500 (Thu, 09 May 2024) $',
'Revision : $Revision: 19115 $',
'Requires : Application Express >= 22.2',
'',
'Version 4.7 Updates:',
'04/24/2024 - Allow WMS and ArcGIS REST items in the Mapbits Layer Item attribute. Show spinner when a layer is loading. Gray out entries when the layer is invisible due to its zoom range. Add Outline Color attribute.',
'',
'Version 4.6 Updates:',
'02/28/2024 - Add more standard icons (dotted line, large/small circle).',
'02/27/2024 - Add Collapsible attribute for headings. Implement click event support.',
'02/26/2024 - Added Legend Entry item.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(426218253353943228)
,p_plugin_id=>wwv_flow_imp.id(421848514324861404)
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
 p_id=>wwv_flow_imp.id(423073605915714548)
,p_plugin_id=>wwv_flow_imp.id(421848514324861404)
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
 p_id=>wwv_flow_imp.id(423075298477736263)
,p_plugin_id=>wwv_flow_imp.id(421848514324861404)
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
 p_id=>wwv_flow_imp.id(425868502837256869)
,p_plugin_id=>wwv_flow_imp.id(421848514324861404)
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
 p_id=>wwv_flow_imp.id(425872547655259456)
,p_plugin_attribute_id=>wwv_flow_imp.id(425868502837256869)
,p_display_sequence=>10
,p_display_value=>'Toggleable'
,p_return_value=>'toggleable'
,p_help_text=>'Include a button to show/hide the layer. Requires "Lodestar Layer Item" to be set.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(425872961936260465)
,p_plugin_attribute_id=>wwv_flow_imp.id(425868502837256869)
,p_display_sequence=>20
,p_display_value=>'Is Heading'
,p_return_value=>'heading'
,p_help_text=>'The item appears as a heading for other items.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(425873406960261804)
,p_plugin_attribute_id=>wwv_flow_imp.id(425868502837256869)
,p_display_sequence=>30
,p_display_value=>'Show Help Button'
,p_return_value=>'show_help'
,p_help_text=>'Show the the help button if the Legend Entry or Lodestar Layer has help text.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(425873822945264505)
,p_plugin_attribute_id=>wwv_flow_imp.id(425868502837256869)
,p_display_sequence=>40
,p_display_value=>'Show Inline Help'
,p_return_value=>'show_inline_help'
,p_help_text=>'Show inline help below the title if the Legend Entry or Lodestar Layer has inline help text.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(425874160180266191)
,p_plugin_attribute_id=>wwv_flow_imp.id(425868502837256869)
,p_display_sequence=>50
,p_display_value=>'Collapsible'
,p_return_value=>'collapsible'
,p_help_text=>'Whether the heading is collapsible. If so, collapsing it will hide all entries until the next header (or the end of the list).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(424410213246475505)
,p_plugin_id=>wwv_flow_imp.id(421848514324861404)
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
 p_id=>wwv_flow_imp.id(424413917986489843)
,p_plugin_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_display_sequence=>5
,p_display_value=>'No Icon'
,p_return_value=>'none'
,p_help_text=>'The layer has no icon'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(424619441289222088)
,p_plugin_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_display_sequence=>7
,p_display_value=>'No icon, but leave space'
,p_return_value=>'blank'
,p_help_text=>'Don''t show an icon, but leave the space where it would be so the text lines up.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(424411100468477485)
,p_plugin_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_display_sequence=>10
,p_display_value=>'Icon Class'
,p_return_value=>'icon_class'
,p_help_text=>'The icon is defined by a Font APEX class.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(424413090268480676)
,p_plugin_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_display_sequence=>20
,p_display_value=>'Line'
,p_return_value=>'line'
,p_help_text=>'A standard icon for line layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(425602425558607803)
,p_plugin_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_display_sequence=>21
,p_display_value=>'Line (Dotted)'
,p_return_value=>'line_dotted'
,p_help_text=>'A standard icon for dotted line layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(424413500883481782)
,p_plugin_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_display_sequence=>30
,p_display_value=>'Polygon'
,p_return_value=>'polygon'
,p_help_text=>'A standard icon for polygon layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(425610185093625148)
,p_plugin_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_display_sequence=>40
,p_display_value=>'Circle'
,p_return_value=>'circle'
,p_help_text=>'A standard icon for circle layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(425643913311658114)
,p_plugin_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_display_sequence=>41
,p_display_value=>'Circle (Small)'
,p_return_value=>'circle_small'
,p_help_text=>'A smaller standard icon for circle layers.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(424415566849493263)
,p_plugin_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_display_sequence=>50
,p_display_value=>'Icon URL'
,p_return_value=>'url'
,p_help_text=>'The icon is defined by a URL (e.g. a static application file).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(424419396375564186)
,p_plugin_id=>wwv_flow_imp.id(421848514324861404)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Icon Class'
,p_attribute_type=>'ICON'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'icon_class'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(424420623720566407)
,p_plugin_id=>wwv_flow_imp.id(421848514324861404)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Icon URL'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(424410213246475505)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'url'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(258208349210501102)
,p_plugin_id=>wwv_flow_imp.id(421848514324861404)
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
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
