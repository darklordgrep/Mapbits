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
--   Date and Time:   17:08 Thursday February 29, 2024
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 887188518588519005
--   Manifest End
--   Version:         22.2.8
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/region_type/mil_army_usace_mapbits_legend
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(887188518588519005)
,p_plugin_type=>'REGION TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LEGEND'
,p_display_name=>'Mapbits Legend'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-legend#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function polysvg(fill_color in varchar2, stroke_color in varchar2, fill_opacity in number) return varchar2 is',
'begin',
'  return '' <svg width="20" height="20" viewbox = "0 0 120 90" style="display: inline-block;vertical-align: middle;"><path',
'                d="M 30.795756,19.814323 L 91.909814,24.827586 L 100.26525,63.501326 L 21.007958,70.66313 L 30.795756,19.814323 z "',
'                style="fill:'' || fill_color || '';fill-opacity:'' || fill_opacity || '';fill-rule:evenodd;stroke:'' || stroke_color || '';stroke-width:2.20000005;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-op'
||'acity:1"/></svg> '';',
'end;',
'',
'-- given a json array of Oracle SVG representation for symbols, return a real XML SVG representation.',
'function jeltosvg(els in json_array_t) return varchar2 is ',
'  rt varchar2(4000);',
'  keys json_key_list;',
'  el json_object_t;',
'  val varchar2(4000);',
'  sub json_array_t;',
'  i integer;',
'begin',
'  for i in 0..els.get_size() - 1 loop',
'    el := treat(els.get(i) as json_object_t);',
'    sub := null;',
'    rt := rt || ''<'' || el.get_string(''type'');',
'    keys := el.get_keys();',
'    for j in 1..keys.count loop',
'      val := el.get_string(keys(j));',
'      if lower(keys(j)) = ''type'' then',
'        null;',
'      elsif lower(keys(j)) = ''elements'' then',
'        sub := treat(el.get(keys(j)) as json_array_t);',
'      else ',
'        rt := rt || '' '' || keys(j) || ''="'' || val || ''"''; ',
'      end if;',
'    end loop;',
'    if not sub is null then',
'      rt := rt || ''>'' || jeltosvg(sub) || ''</'' || el.get_string(''type'') || ''>'';',
'    else',
'      rt := rt ||  ''/>''; -- ''</'' || el.get_string(''type'') || ''>'';',
'    end if;',
'  end loop;',
'  return rt;',
'end;',
'',
'procedure map_legend_render_entry',
'(',
'  p_region_id varchar2,',
'  p_name varchar2,',
'  p_icon_type varchar2,',
'  p_javascript_config in out clob,',
'  p_color varchar2 default null,',
'  p_outline_color varchar2 default null,',
'  p_opacity number default null,',
'  p_icon_class varchar2 default null,',
'  p_icon_url varchar2 default null,',
'  p_help_text clob default null,',
'  p_inline_help_text clob default null,',
'  p_options varchar2 default null,',
'  p_entry_item_name varchar2 default null,',
'  p_lodestar_item_name varchar2 default null',
')',
'is',
'  l_id varchar2(110);',
'begin',
'  l_id := nvl(p_entry_item_name, p_lodestar_item_name);',
'',
'  p_javascript_config := p_javascript_config || ''{''',
'    || apex_javascript.add_attribute(''itemId'', l_id)',
'    || apex_javascript.add_attribute(''title'', apex_plugin_util.replace_substitutions(p_name, false))',
'    || apex_javascript.add_attribute(''helpText'', apex_plugin_util.replace_substitutions(p_help_text, false))',
'    || apex_javascript.add_attribute(''inlineHelpText'', apex_plugin_util.replace_substitutions(p_inline_help_text, false))',
'    || apex_javascript.add_attribute(''color'', apex_plugin_util.replace_substitutions(p_color, false))',
'    || apex_javascript.add_attribute(''outlineColor'', apex_plugin_util.replace_substitutions(p_outline_color, false))',
'    || apex_javascript.add_attribute(''opacity'', apex_plugin_util.replace_substitutions(p_opacity, false))',
'    || apex_javascript.add_attribute(''iconClass'', apex_plugin_util.replace_substitutions(p_icon_class, false))',
'    || apex_javascript.add_attribute(''iconUrl'', apex_plugin_util.replace_substitutions(p_icon_url, false))',
'    || apex_javascript.add_attribute(''iconType'', apex_plugin_util.replace_substitutions(p_icon_type, false))',
'    || apex_javascript.add_attribute(''options'', apex_plugin_util.replace_substitutions(p_options, false))',
'    || apex_javascript.add_attribute(''entryItemName'', p_entry_item_name)',
'    || apex_javascript.add_attribute(''lodestarItemName'', p_lodestar_item_name)',
'    || ''},'';',
'',
'  htp.prn(''<li id="'' || l_id || ''_mapbits_legend_entry"></li>'');',
'end;',
'',
'function map_legend_render (p_region in apex_plugin.t_region, p_plugin in apex_plugin.t_plugin, p_is_printer_friendly in boolean) return apex_plugin.t_region_render_result is',
'  parse_exception exception;',
'  pragma exception_init(parse_exception, -6533);',
'  rt apex_plugin.t_region_render_result;',
'  type t_string_list is table of varchar2(2000) index by varchar2(32);',
'  l_paths t_string_list;',
'  l_symbol varchar2(3000);',
'  l_default_stroke_color varchar2(7) := ''#000000'';',
'  l_default_symbol_color varchar2(7) := ''#309fdb'';',
'  l_default_fill_color varchar2(7) := ''#13b6cf'';',
'  cursor c is select l.*,',
'    nvl(fill_color, l_default_fill_color) fill_color_d, ',
'    nvl(stroke_color, decode(l_default_symbol_color, ''SVG'', l_default_symbol_color, l_default_stroke_color)) stroke_color_d, ',
'    nvl(point_svg_shape_scale, 1) point_svg_shape_scale_d,',
'    nvl(fill_opacity, 1) fill_opacity_d',
'    from apex_appl_page_map_layers l ',
'    inner join apex_application_page_regions r on l.region_id = r.region_id',
'    where l.application_id = :APP_ID and l.page_id = :APP_PAGE_ID and (p_region.attribute_02 is null or r.static_id = p_region.attribute_02) and l.display_in_legend = ''Yes''',
'    order by l.display_sequence desc;',
'  citem c%rowtype;',
'  l_colormaps clob;',
'  l_colorj json_object_t;',
'  l_cstyles varchar2(4000);',
'  l_cstylej json_array_t;',
'  l_cstyleobj json_object_t;',
'  l_colors json_array_t;',
'  i pls_integer;',
'  l_src_query varchar2(4000);',
'  l_map_region apex_application_page_regions%rowtype;',
'  l_column_value_list   apex_plugin_util.t_column_value_list;',
'  l_fill_symbols varchar2(4000) := '''';',
'  l_label_column varchar2(32);',
'  l_label_cols apex_t_varchar2 := apex_string.split(p_region.attribute_01, '','');',
'  l_label_item apex_t_varchar2;',
'  l_label_map t_string_list;',
'  l_viewbox_map t_string_list;',
'  l_key varchar2(100);',
'  l_keys json_key_list;',
'  l_colors_custom apex_t_varchar2;',
'  l_javascript_config clob;',
'begin',
'  -- parse the label column(s). Check first if it is a single label column name for all layers',
'  -- otherwise, try to parse a dictionary mapping layer names to column names as follows:',
'  -- layer1;column1,layer2;column2;layer3;column3;',
'  if instr(p_region.attribute_01, '','') = 0 and instr(p_region.attribute_01, '';'') = 0 then',
'    l_label_column  := p_region.attribute_01;',
'  else',
'    begin',
'      for i in 1..l_label_cols.count loop',
'        l_label_item := apex_string.split(l_label_cols(i), '';'');',
'        l_label_map(l_label_item(1)) := l_label_item(2);',
'      end loop;',
'    exception when parse_exception then',
'      raise_application_error(-20653, ''Invalid Column Label List'');',
'    end;',
'  end if;',
'  ',
'  -- load and parse the colormaps',
'  select apex_util.blob_to_clob(file_content) into l_colormaps from apex_appl_plugin_files where application_id = :APP_ID and plugin_name = ''MIL.ARMY.USACE.MAPBITS.LEGEND'' and file_name = ''cartocolors.json'';',
'  l_colorj := json_object_t.parse(l_colormaps);',
'',
'  -- create a dictionary of names to styles.',
'  -- add built-in styles',
'  l_paths(''Default'') := ''<path d="M10 2C6.7 2 4 4.7 4 8c0 4.6 5.4 9.7 5.7 9.9.2.2.5.2.7 0 .2-.2 5.6-5.3 5.6-9.9 0-3.3-2.7-6-6-6zm0 7.9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2z"></path>'';',
'  l_paths(''Camera'') := ''<path d="M15 4h-1.2l-.9-1.2c-.4-.5-1-.8-1.6-.8H8.8c-.7 0-1.3.3-1.6.8L6.2 4H5c-1.1 0-2 .9-2 2v5c0 1.1.9 2 2 2h2.2l2.4 4.7c.1.2.4.3.7.2.1 0 .2-.1.2-.2l2.4-4.7H15c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm-5 7c-1.4 0-2.5-1.1-2.5-2.5S8.6 6'
||' 10 6s2.5 1.1 2.5 2.5S11.4 11 10 11z"></path>'';',
'  l_paths(''Circle'') := ''<path d="M10 2C6.7 2 4 4.7 4 8c0 2.5 1.6 4.7 3.9 5.6l1.6 4.1c.1.3.4.4.7.3l.3-.3 1.6-4.1c3.1-1.2 4.7-4.6 3.5-7.7C14.7 3.6 12.5 2 10 2zm0 8c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2z"></path>'';',
'  l_paths(''Circle Alternative'') := ''<path d="M10 2C6.7 2 4 4.7 4 8v9.5c0 .2.1.4.3.5h.2c.1 0 .3-.1.4-.2l3.7-4c3.2.8 6.5-1.2 7.3-4.4.8-3.2-1.2-6.5-4.4-7.3-.5 0-1-.1-1.5-.1zm0 8c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2z"></path>'';',
'  l_paths(''Face Frown'') := ''<path d="M10 2C6.7 2 4 4.7 4 8c0 3.7 5.4 9.6 5.6 9.8.2.2.5.2.7 0 .3-.2 5.7-6.1 5.7-9.8 0-3.3-2.7-6-6-6zM7.2 7c0-.4.3-.8.8-.8.4 0 .8.3.8.8s-.4.8-.8.8-.8-.4-.8-.8zm5 3.8c-.2.1-.4.1-.5-.1-.7-.9-2-1.1-3-.4-.2.1-.3.3-.4.4-.1.2-'
||'.4.2-.5.1-.2-.1-.2-.4-.1-.5 1-1.3 2.8-1.5 4-.6l.6.6c.1.1.1.4-.1.5zm-.2-3c-.4 0-.8-.3-.8-.8s.3-.8.8-.8.8.3.8.8-.4.8-.8.8z"></path>'';',
'  l_paths(''Face Meh'') := ''<path d="M10 2C6.7 2 4 4.7 4 8c0 3.7 5.4 9.6 5.6 9.8.2.2.5.2.7 0 .3-.2 5.7-6.1 5.7-9.8 0-3.3-2.7-6-6-6zM7.2 7c0-.4.3-.8.8-.8.4 0 .8.3.8.8s-.4.8-.8.8-.8-.4-.8-.8zm4.3 3.9h-3c-.2 0-.4-.2-.4-.4s.2-.4.4-.4h3c.2 0 .4.2.4.4s-.2.4-'
||'.4.4zm.5-3.1c-.4 0-.8-.3-.8-.8s.3-.8.8-.8.8.3.8.8-.4.8-.8.8z"></path>'';',
'  l_paths(''Face Smile'') := ''<path d="M10 2C6.7 2 4 4.7 4 8c0 3.7 5.4 9.6 5.6 9.8.2.2.5.2.7 0 .3-.2 5.7-6.1 5.7-9.8 0-3.3-2.7-6-6-6zM7.2 7c0-.4.3-.8.8-.8.4 0 .8.3.8.8s-.4.8-.8.8-.8-.4-.8-.8zm5.1 2.7c-1 1.3-2.8 1.5-4 .6l-.6-.6c-.1-.1-.1-.4.1-.5.2-.1.4-'
||'.1.5.1.7.9 2 1.1 3 .4.2-.1.3-.3.4-.4.1-.2.4-.2.5-.1s.2.4.1.5zM12 7.8c-.4 0-.8-.3-.8-.8s.3-.8.8-.8.8.3.8.8-.4.8-.8.8z"></path>'';',
'  l_paths(''Square'') := ''<path d="M14 2H6c-1.1 0-2 .9-2 2v8c0 1.1.9 2 2 2h2.1l1.5 3.7c.1.3.4.4.7.3l.3-.3 1.5-3.7H14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-4 8c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2z"></path>'';',
'  l_paths(''Square Alternative'') := ''<path d="M14 2H6c-1.1 0-2 .9-2 2v13.5c0 .2.1.4.3.5h.2c.1 0 .3-.1.4-.2L8.4 14H14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-4 8c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2z"></path>'';',
'  l_paths(''Pin Circle'') := ''<path d="M10 2C7.2 2 5 4.2 5 7c0 2.6 1.9 4.7 4.5 5v5.6c0 .3.2.5.5.5s.5-.2.5-.5V12c2.7-.3 4.7-2.7 4.5-5.4-.3-2.7-2.4-4.6-5-4.6z'';',
'  l_paths(''Pin Square'') := ''<path d="M13 2H7c-1.1 0-2 .9-2 2v6c0 1.1.9 2 2 2h2.5v5.5c0 .3.2.5.5.5s.5-.2.5-.5V12H13c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"></path>'';',
'  l_paths(''Heart'') := ''<path d="M16 5c0-.8-.3-1.6-.9-2.1-1.2-1.2-3.1-1.2-4.3 0l-.8.8-.8-.8C8 1.7 6.1 1.7 4.9 2.9c-1.2 1.1-1.2 3 0 4.2l4.6 4.6v5.8c0 .3.2.5.5.5s.5-.2.5-.5v-5.8l4.6-4.6c.6-.5.9-1.3.9-2.1z"></path>'';',
'  l_paths(''Pentagon'') := ''<path d="M15 5.5l-4.7-3.4c-.2-.1-.4-.1-.6 0L5 5.5c-.2.2-.3.4-.2.6l1.8 5.6c.1.2.3.3.5.3h2.4v5.5c0 .3.2.5.5.5s.5-.2.5-.5V12h2.4c.2 0 .4-.1.5-.3l1.8-5.6c.1-.2 0-.4-.2-.6z"></path>'';',
'  l_paths(''Triangle'') := ''<path d="M15.9 11.2l-5.5-9c-.1-.2-.5-.3-.7-.1-.1 0-.1.1-.1.1l-5.5 9c-.1.2-.1.5.2.7 0 .1.1.1.2.1h5v5.5c0 .3.2.5.5.5s.5-.2.5-.5V12h5c.3 0 .5-.2.5-.5 0-.1 0-.2-.1-.3z"></path>'';',
'  l_paths(''Check'') := ''<path d="M10 2C6.7 2 4 4.7 4 8c0 3.7 5.4 9.6 5.6 9.8.2.2.5.2.7 0 .3-.2 5.7-6.1 5.7-9.8 0-3.3-2.7-6-6-6zm2.9 4.9l-3 3c-.2.1-.6.1-.8 0L7.6 8.4c-.2-.2-.2-.5 0-.7s.5-.2.7 0l1.1 1.1L12 6.2c.2-.2.5-.2.7 0s.3.5.2.7z"></path>'';',
'  l_paths(''Home'') := ''<path d="M17.8 7.6l-7.5-5.5c-.2-.1-.4-.1-.6 0L2.2 7.5c-.2.2-.3.5-.1.7.2.2.5.3.7.1L4 7.5v6c0 .3.2.5.5.5h3.2l1.9 3.7c.1.2.4.3.7.2.1 0 .2-.1.2-.2l1.9-3.7h3.2c.3 0 .5-.2.5-.5v-6l1.2.9c.2.2.5.1.7-.1.1-.3 0-.6-.2-.7z"></path><path d="'
||'M8.5 8.5v2c0 .3.2.5.5.5h2c.3 0 .5-.2.5-.5v-2c0-.3-.2-.5-.5-.5H9c-.3 0-.5.2-.5.5z" fill="#fff"></path>'';',
'  l_paths(''Slash'') := ''<path d="M17.9 2.1c-.2-.2-.5-.2-.7 0l-2.3 2.3C13 1.7 9.2 1.1 6.5 3.1 4.9 4.3 4 6.1 4 8c.1 1.9.8 3.8 1.9 5.4l-3.8 3.8c-.2.2-.2.5 0 .7s.5.2.7 0l15-15c.2-.2.2-.6.1-.8zM9.5 9.8c-1.1-.3-1.7-1.4-1.4-2.4S9.5 5.7 10.5 6c.7.2 1.2.7 1.4 '
||'1.4L9.5 9.8zM7.1 15c.8 1 1.6 2 2.6 2.8.2.2.5.2.7 0 .2-.1 5.6-5.2 5.6-9.8 0-.6-.1-1.1-.2-1.6L7.1 15z"></path>'';',
'  l_paths(''Shine'') := ''<path d="M10 7c-2.2 0-4 1.8-4 4 0 2.3 3.2 6.4 3.6 6.8.2.2.5.2.7.1l.1-.1c.4-.5 3.6-4.5 3.6-6.8 0-2.2-1.8-4-4-4zm0 5c-.6 0-1-.4-1-1s.4-1 1-1 1 .4 1 1-.4 1-1 1zM3.6 4.9c-.2-.1-.5-.1-.7.1-.2.3-.1.6.1.7l1.9 1.4c0 .1.1.1.3.1.3 0 .5-.'
||'2.5-.5 0-.2-.1-.3-.2-.4L3.6 4.9zm4 .1c.1.2.3.3.5.3h.2c.3-.1.4-.4.3-.6l-.9-2.4c0-.2-.3-.4-.6-.3-.3.1-.4.4-.3.6L7.6 5zm9.5 0c-.2-.2-.5-.3-.7-.1l-1.9 1.4c-.2.2-.3.5-.1.7.1.1.2.2.4.2.1 0 .2 0 .3-.1L17 5.7c.2-.1.3-.4.1-.7zm-5.3.3h.2c.2 0 .4-.1.5-.3l.8-2.3'
||'c.1-.3 0-.5-.3-.6-.3-.1-.5 0-.6.3l-.8 2.3c-.2.2-.1.5.2.6z"></path>'';',
'  l_paths(''Street View'') := ''<path d="M14.7 11.6c-.3-.1-.5.1-.6.3s.1.5.3.6c1.6.5 2.6 1.2 2.6 1.9 0 1.2-2.9 2.5-7 2.5s-7-1.3-7-2.5c0-.7 1-1.4 2.6-1.9.3 0 .4-.3.3-.5-.1-.3-.4-.4-.6-.3-2.1.6-3.3 1.6-3.3 2.8 0 2 3.4 3.5 8 3.5s8-1.5 8-3.5c0-1.2-1.2-2.2-3.'
||'3-2.9z"></path><path d="M7.7 10.9c.2.2.3.5.3.7V14c0 .6.4 1 1 1h2c.6 0 1-.4 1-1v-2.4c0-.3.1-.5.3-.7l.1-.1c.4-.4.6-.9.6-1.4V7.8c0-.7-.3-1.3-.9-1.6-1.2 1.2-3.1 1.2-4.2 0-.6.3-.9.9-.9 1.6v1.6c0 .5.2 1 .6 1.4l.1.1z"></path>'';',
'  l_paths(''StreetView'') := ''<path d="M14.7 11.6c-.3-.1-.5.1-.6.3s.1.5.3.6c1.6.5 2.6 1.2 2.6 1.9 0 1.2-2.9 2.5-7 2.5s-7-1.3-7-2.5c0-.7 1-1.4 2.6-1.9.3 0 .4-.3.3-.5-.1-.3-.4-.4-.6-.3-2.1.6-3.3 1.6-3.3 2.8 0 2 3.4 3.5 8 3.5s8-1.5 8-3.5c0-1.2-1.2-2.2-3.3'
||'-2.9z"></path><path d="M7.7 10.9c.2.2.3.5.3.7V14c0 .6.4 1 1 1h2c.6 0 1-.4 1-1v-2.4c0-.3.1-.5.3-.7l.1-.1c.4-.4.6-.9.6-1.4V7.8c0-.7-.3-1.3-.9-1.6-1.2 1.2-3.1 1.2-4.2 0-.6.3-.9.9-.9 1.6v1.6c0 .5.2 1 .6 1.4l.1.1z"></path><circle cx="10" cy="4" r="2"></ci'
||'rcle>'';',
'  l_paths(''Flag Pennant'') := ''<path d="M16.7 6.5L3.7 2c-.3-.1-.6.1-.7.3v15.2c0 .3.2.5.5.5s.5-.2.5-.5v-5.6l12.7-4.4c.3-.1.4-.4.3-.6-.1-.2-.2-.3-.3-.4z"></path>'';',
'  l_paths(''Flag Swallowtail'') := ''<path d="M13.2 7l3.7-4.2c.2-.2.2-.5 0-.7-.2-.1-.3-.1-.4-.1h-13c-.3 0-.5.2-.5.5v15c0 .3.2.5.5.5s.5-.2.5-.5V12h12.5c.3 0 .5-.2.5-.5 0-.1 0-.2-.1-.3L13.2 7z"></path>'';',
'  ',
'  -- add custom styles',
'  begin',
'    select nvl(custom_svg_styles, ''[]'') into l_cstyles from APEX_APPL_PAGE_MAPS m inner join apex_application_page_regions r on m.region_id = r.region_id where m.page_id = :APP_PAGE_ID and m.application_id = :APP_ID and (p_region.attribute_02 is null'
||' or p_region.attribute_02 = r.static_id);',
'  exception',
'    when NO_DATA_FOUND then',
'      raise_application_error(-20653, ''Could not find region "'' || p_region.attribute_02 || ''"'');',
'  end;',
'  ',
'  l_cstylej := json_array_t.parse(l_cstyles);',
'  for i in 0..l_cstylej.get_size() - 1 loop',
'    l_cstyleobj := treat(l_cstylej.get(i) AS JSON_OBJECT_T);',
'    l_key := l_cstyleobj.get_string(''name'');',
'    l_viewbox_map(l_key) := l_cstyleobj.get_string(''viewBox''); --|| l_cstyleobj.get_array(''elements'');',
'    l_paths(l_key) := jeltosvg(l_cstyleobj.get_array(''elements''));',
'    ',
'    apex_debug.info (',
'      p_message => ''Adding style ['' || l_key || ''] --> ''  || l_paths(l_key) ,',
'      p0 => citem.name,',
'      p1 => citem.point_display_type',
'    );',
'  end loop;',
' ',
'  -- create the legend as HTML list. Iterate through layers to create the list items.',
'  htp.p(''<ul data-role="listview" class="a-ListView">'');',
'',
'  for entry in (',
'    select',
'        nvl(entry.attribute_02, nvl(lodestar.attribute_01, nvl(entry.item_name, lodestar.item_name))) title,',
'        nvl(entry.attribute_06, lodestar.attribute_05) icon_class,',
'        entry.attribute_07 icon_url,',
'        nvl(entry.attribute_03, lodestar.attribute_06) color,',
'        lodestar.attribute_12 opacity,',
'        lodestar.attribute_13 outline_color,',
'        nvl(entry.attribute_05, lodestar.attribute_10) icon_type,',
'        nvl(entry.item_help_text, lodestar.item_help_text) help_text,',
'        nvl(entry.inline_help_text, lodestar.inline_help_text) inline_help_text,',
'        entry.attribute_04 options,',
'',
'        entry.item_name entry_item_name,',
'        entry.build_option_id entry_build_option_id,',
'        entry.authorization_scheme_id entry_authorization_scheme_id,',
'        entry.condition_type_code entry_condition_type,',
'        entry.condition_expression1 entry_condition_expr1,',
'        entry.condition_expression2 entry_condition_expr2,',
'',
'        lodestar.item_name lodestar_item_name,',
'        lodestar.build_option_id lodestar_build_option_id,',
'        lodestar.authorization_scheme_id lodestar_authorization_scheme_id,',
'        lodestar.condition_type_code lodestar_condition_type,',
'        lodestar.condition_expression1 lodestar_condition_expr1,',
'        lodestar.condition_expression2 lodestar_condition_expr2',
'      from (',
'        select * from apex_application_page_items where',
'          application_id = :APP_ID',
'          and page_id = :APP_PAGE_ID',
'          and region_id = p_region.id',
'          and display_as_code = ''PLUGIN_MIL.ARMY.USACE.MAPBITS.LEGEND_ENTRY''',
'      ) entry',
'        full outer join (',
'          select p.* from apex_application_page_items p',
'            inner join apex_application_page_regions r on p.region_id = r.region_id',
'            where',
'              p.application_id = :APP_ID',
'              and p.page_id = :APP_PAGE_ID',
'              and (p_region.attribute_02 is null or r.static_id = p_region.attribute_02)',
'              and p.display_as_code = ''PLUGIN_MIL.ARMY.USACE.MAPBITS.LAYER.LODESTAR''',
'        ) lodestar on entry.attribute_01 = lodestar.item_name',
'      order by nvl(entry.display_sequence, lodestar.display_sequence)',
'  ) loop',
'    if not apex_plugin_util.is_component_used(',
'      entry.entry_build_option_id,',
'      entry.entry_authorization_scheme_id,',
'      entry.entry_condition_type,',
'      entry.entry_condition_expr1,',
'      entry.entry_condition_expr2,',
'      null',
'    ) then',
'      continue;',
'    end if;',
'',
'    if not apex_plugin_util.is_component_used(',
'      entry.lodestar_build_option_id,',
'      entry.lodestar_authorization_scheme_id,',
'      entry.lodestar_condition_type,',
'      entry.lodestar_condition_expr1,',
'      entry.lodestar_condition_expr2,',
'      null',
'    ) then',
'      continue;',
'    end if;',
'',
'    map_legend_render_entry(',
'      p_region.id,',
'      entry.title,',
'      entry.icon_type,',
'      l_javascript_config,',
'      p_color => entry.color,',
'      p_outline_color => entry.outline_color,',
'      p_opacity => entry.opacity,',
'      p_icon_class => entry.icon_class,',
'      p_icon_url => entry.icon_url,',
'      p_help_text => entry.help_text,',
'      p_inline_help_text => entry.inline_help_text,',
'      p_options => entry.options,',
'      p_entry_item_name => entry.entry_item_name,',
'      p_lodestar_item_name => entry.lodestar_item_name',
'    );',
'  end loop;',
'',
'  if l_javascript_config is not null then',
'    declare',
'      l_chunk varchar2(4000);',
'      l_offset number;',
'    begin',
'      htp.prn(''<script type="text/javascript">const R'' || p_region.id || ''_mapbits_legend_entry = ['');',
'      while apex_string.next_chunk(l_javascript_config, l_chunk, l_offset, 4000) loop',
'        htp.prn(l_chunk);',
'      end loop;',
'      htp.prn('']</script>'');',
'      apex_javascript.add_onload_code(''mapbits_legend_build_entries(R'' || p_region.id || ''_mapbits_legend_entry)'', null);',
'    end;',
'  end if;',
'',
'  for citem in c loop',
'    -- check if layer is rendered in the map region. If not, it doesn''t need a legend entry.',
'    if not APEX_PLUGIN_UTIL.IS_COMPONENT_USED(citem.build_option_id, citem.authorization_scheme_id, citem.condition_type, citem.condition_expr1, citem.condition_expr2, null) then',
'      continue;',
'    end if;',
'',
'    l_fill_symbols := '''';',
'    l_symbol := '''';',
'    l_label_column := '''';',
'    case when citem.layer_type_code = ''POINT'' then',
'      if citem.point_display_type_code = ''SVG'' then',
'        -- Layer Type : Point, Style : SVG ',
'        l_symbol := ''<svg width="20px" height="20px" paint-order="stroke" viewBox="'' || ',
'          case when l_viewbox_map.exists(citem.point_svg_shape) then l_viewbox_map(citem.point_svg_shape) else ''0 0 20 20'' end || ',
'          ''" style="stroke:'' || citem.stroke_color_d || '';fill:'' || citem.fill_color_d || '';display: inline-block;vertical-align: middle;"><g transform-origin="50% 50%" transform="scale('' || citem.point_svg_shape_scale_d || '','' || citem.point_svg_sha'
||'pe_scale_d || '')">'' || l_paths(citem.point_svg_shape) || ''</g></svg>'';',
'      elsif citem.point_display_type_code = ''ICON'' then',
'        if citem.point_icon_source_type_code = ''STATIC_CLASS'' then',
'          -- Layer Type : Point, Style : Icon, Icon Source : Icon Class',
'          l_symbol := ''<span style="color:'' || citem.fill_color_d || '';margin:0;padding-right:20px;display: inline-block;vertical-align: middle;" class="fa '' || citem.point_icon_css_classes || ''"></span>'';',
'        elsif citem.point_icon_source_type_code = ''URL'' then',
'          -- Layer Type : Point, Style : Icon, Icon Source : Image URL',
'          l_symbol := ''<img style="width:20px;height:20px;display: inline-block;vertical-align: middle;" src="'' || apex_plugin_util.replace_substitutions (citem.point_icon_image_url) || ''"/>'';',
'        elsif citem.point_icon_source_type_code = ''DYNAMIC_CLASS'' then',
'          -- Layer Type : Point, Style : Icon, Icon Source : Icon Class Column',
'          if l_label_column is null then',
'            l_label_column := l_label_map(citem.name);',
'          end if;',
'          -- Icon Class Column requires this plugin to query the layer source to the the subtype label name and the icon class. First, determine the source and build the query.                    ',
'          if citem.location_code = ''REGION_SOURCE'' then ',
'            select region_source, query_type_code, table_name, where_clause into l_map_region.region_source, l_map_region.query_type_code, l_map_region.table_name, l_map_region.where_clause from apex_application_page_regions where page_id = :APP_PAGE'
||'_ID and application_id = :APP_ID and source_type_code = ''NATIVE_MAP_REGION''; ',
'            if l_map_region.query_type_code = ''TABLE'' then',
'              l_src_query := ''select distinct '' || nvl(l_label_column, citem.point_icon_class_column)  || '' category, '' || citem.point_icon_class_column || '' from '' || l_map_region.table_name || case when not l_map_region.where_clause is null then '' '
||'where '' || l_map_region.where_clause else '''' end || '' order by ''|| citem.point_icon_class_column;',
'            elsif l_map_region.query_type_code = ''SQL'' then',
'              l_src_query := ''select distinct '' || nvl(l_label_column, citem.point_icon_class_column) || '' category, '' || citem.point_icon_class_column || '' from '' || ''('' ||  l_map_region.region_source || '') order by ''|| citem.point_icon_class_column'
||';',
'            else',
'              apex_debug.error (',
'                p_message => ''Layer [%0]: For Fill Color calculation, Region Source query type [%1] not implemented.'',',
'                p0 => citem.name,',
'                p1 => citem.point_display_type',
'              );',
'            end if;',
'          else',
'            if citem.query_type_code = ''TABLE'' then',
'              l_src_query := ''select distinct '' || nvl(l_label_column, citem.point_icon_class_column) || '' category, '' || citem.point_icon_class_column || '' from '' || citem.table_name || case when not citem.where_clause is null then '' where '' || cite'
||'m.where_clause else '''' end || '' order by ''|| citem.point_icon_class_column;',
'            elsif citem.query_type_code = ''SQL'' then',
'              l_src_query := ''select distinct '' || nvl(l_label_column, citem.point_icon_class_column) || '' category, '' || citem.point_icon_class_column || '' from '' || ''('' || citem.layer_source || '') order by ''|| citem.point_icon_class_column;',
'            else',
'              apex_debug.error (',
'                p_message => ''Layer [%0]: For Symbol Class calculation, Layer Source query type [%1] not implemented.'',',
'                p0 => citem.name,',
'                p1 => citem.point_display_type',
'              );',
'            end if;',
'          end if;',
'',
'          -- Run the layer source query ',
'          if not l_src_query is null then',
'            l_column_value_list := apex_plugin_util.get_data (',
'              p_sql_statement    => l_src_query, ',
'              p_min_columns      => 2,',
'              p_max_columns      => 2,',
'              p_component_name   => p_region.name',
'            );',
'          end if;',
'          for i in 1..l_column_value_list(1).count loop ',
'             l_fill_symbols := l_fill_symbols || '' <br/><span style="margin:0;padding-right:20px;display: inline-block;vertical-align: middle;" class="fa '' || l_column_value_list(2)(i) || ''"></span>'' || l_column_value_list(1)(i);',
'          end loop;',
'        else',
'          apex_debug.error (',
'            p_message => ''Layer [%0]: Point Geometry, Icon Source type [%1] not implemented.'',',
'            p0 => citem.name,',
'            p1 => citem.point_icon_source_type',
'          ); ',
'        end if; ',
'      else',
'        apex_debug.error (',
'          p_message => ''Layer [%0]: Point Geometry, Display type [%1] not implemented.'',',
'          p0 => citem.name,',
'          p1 => citem.point_display_type',
'        );',
'      end if;  ',
'    when citem.layer_type_code = ''LINE'' then',
'      -- Layer Type : Line',
'      l_symbol := ''<svg width="20" height="20"  style="stroke:'' || citem.stroke_color_d || '';stroke-width:2.2;display: inline-block;vertical-align: middle;"><path d="M 18,14 2,6"/></svg>'';',
'    when citem.layer_type_code = ''POLYGON'' then',
'      if citem.fill_color_is_spectrum = ''Yes''	then',
'        -- Layer Type : Polygon, Use Color Scheme : Yes',
'        if l_label_column is null then',
'          begin',
'            l_label_column := l_label_map(citem.name);',
'          exception when others then',
'            apex_debug.error (',
'              p_message => ''Layer [%0]: For Fill Color calculation, could not find label column for .'',',
'              p0 => citem.name,',
'              p1 => citem.point_display_type',
'            );',
'          end;',
'        end if;',
'        if citem.location_code = ''REGION_SOURCE'' then ',
'          -- Polygon type using a Color Scheme requires this plugin to query the layer source to the the subtype label name and the icon class. First, determine the source and build the query.                              ',
'          select region_source, query_type_code, table_name, where_clause into l_map_region.region_source, l_map_region.query_type_code, l_map_region.table_name, l_map_region.where_clause from apex_application_page_regions where page_id = :APP_PAGE_I'
||'D and application_id = :APP_ID and source_type_code = ''NATIVE_MAP_REGION''; ',
'          if l_map_region.query_type_code = ''TABLE'' then',
'            l_src_query := ''select distinct '' || nvl(l_label_column, citem.fill_value_column)  || '' category, '' || citem.fill_value_column || '' from '' || l_map_region.table_name || case when not l_map_region.where_clause is null then '' where '' || l_m'
||'ap_region.where_clause else '''' end || '' order by ''|| citem.fill_value_column;',
'          elsif l_map_region.query_type_code = ''SQL'' then',
'            l_src_query := ''select distinct '' || nvl(l_label_column, citem.fill_value_column) || '' category, '' || citem.fill_value_column || '' from '' || ''('' ||  l_map_region.region_source || '') order by ''|| citem.fill_value_column;',
'          else',
'            apex_debug.error (',
'              p_message => ''Layer [%0]: For Fill Color calculation, Region Source query type [%1] not implemented.'',',
'              p0 => citem.name,',
'              p1 => citem.point_display_type',
'            );',
'          end if;',
'        else',
'          if citem.query_type_code = ''TABLE'' then',
'            l_src_query := ''select distinct '' || nvl(l_label_column, citem.fill_value_column) || '' category, '' || citem.fill_value_column || '' from '' || citem.table_name || case when not citem.where_clause is null then '' where '' || citem.where_clause'
||' else '''' end || '' order by ''|| citem.fill_value_column;',
'          elsif citem.query_type_code = ''SQL'' then',
'            l_src_query := ''select distinct '' || nvl(l_label_column, citem.fill_value_column) || '' category, '' || citem.fill_value_column || '' from '' || ''('' || citem.layer_source || '') order by ''|| citem.fill_value_column;',
'          else',
'            apex_debug.error (',
'              p_message => ''Layer [%0]: For Fill Color calculation, Layer Source query type [%1] not implemented.'',',
'              p0 => citem.name,',
'              p1 => citem.point_display_type',
'            );',
'          end if;',
'        end if;',
'        ',
'        if not l_src_query is null then',
'          l_column_value_list := apex_plugin_util.get_data (',
'            p_sql_statement    => l_src_query, ',
'            p_min_columns      => 2,',
'            p_max_columns      => 2,',
'            p_component_name   => p_region.name',
'          );',
'        end if;',
'',
'        l_symbol := '''';',
'        if citem.fill_color_spectrum_name is null then',
'          l_colors_custom := apex_string.split(citem.fill_color, '','');',
'',
'          for i in 1..l_column_value_list(1).count loop',
'            if i <= l_colors_custom.count then',
'              if i > 1 then',
'                 l_fill_symbols := l_fill_symbols || ''<br/>'';',
'              end if;',
'              l_fill_symbols := l_fill_symbols || polysvg(l_colors_custom(i), citem.stroke_color_d, citem.fill_opacity_d) || l_column_value_list(1)(i);',
'            end if;',
'          end loop;',
'        else',
'          -- Layer Type : Line, Use Color Scheme : No',
'          l_colors := l_colorj.get_object(citem.fill_color_spectrum_name).get_array(''7''); -- hmmm',
'',
'          for i in 1..l_column_value_list(1).count loop',
'             if i > 1 then',
'               l_fill_symbols := l_fill_symbols || ''<br/>'';',
'             end if;',
'            if i < l_colors.get_size() then',
'               l_fill_symbols := l_fill_symbols || polysvg(l_colors.get_string(i), citem.stroke_color_d, citem.fill_opacity_d) || l_column_value_list(1)(i);',
'            end if;',
'          end loop;',
'        end if;',
'      else',
'        -- Layer Type : Polygon, Use Color Scheme : Yes',
'        l_symbol := polysvg(citem.fill_color_d, citem.stroke_color_d, citem.fill_opacity_d );',
'      end if;',
'    else ',
'      l_symbol := '''';',
'    end case;',
'    if l_fill_symbols is not null then',
'      l_fill_symbols := ''<br/>'' || l_fill_symbols;',
'    end if;',
'    htp.p(''<li class="a-ListView-item ui-body-inherit">'' || l_symbol || '' '' || citem.label || l_fill_symbols || ''</li>'');',
'  end loop;',
'',
'  htp.p(''</ul>'');',
'  return rt;',
'end;'))
,p_api_version=>2
,p_render_function=>'map_legend_render'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Mapbits Legend is a Region that displays symbology and names for the layers shown in an associated Map Region. ',
'If there are more than one Map Regions on the page, use the ''Map Region'' attribute setting to pick the static id of the specfic Region to use for the Legend.',
'</p>',
'<p>',
'Use the Label Columns attribute to set the specific labeling column to use for layers that have multiple symbols.',
'</p>',
'<p>',
'This Legend will only show layers from the Map Region and not the underlying vector tiles.',
'The Legend does not currently support Mapbits Page Items that behave as layers, with the exception of Lodestar layers. However, you can add a Legend Entry page item to the Legend region and customize its appearance to represent those layers.',
'</p>',
'<p>',
'Cartocolors configuration taken from https://github.com/CartoDB/CartoColor/tree/master on 7/5/2023. (Converted from javascript to json data file.)',
'</p>',
'<p>',
'Optionally, Mapbits Legend Entry Plugin Items can be added to a Legend Region to provide additional functionality and configuration such as added user-controlled visibility toggles for Lodestar layer and spacing',
'control. See the Mapbits Legend Entry Plugin for more information.',
'</p>'))
,p_version_identifier=>'4.6.20240226'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Legend',
'Location : $Id: mapbits_demo_apex_application.sql 18714 2023-11-17 16:08:44Z b2imimcf $',
'Date     : $Date: 2023-11-17 10:08:44 -0600 (Fri, 17 Nov 2023) $',
'Revision : $Revision: 18714 $',
'Requires : Application Express >= 22.2',
'',
'Version 4.6 Updates:',
'02/26/2024 Implement support for Legend Entry items.',
'11/14/2023 Show icons for Lodestar custom layers',
'11/07/2023 Removed entries for layers that are not shown in the built-in legend. Added fill outline for Lodestar layers. Fixed a bug where all page items, not just Lodestar layer items, appeared in the legend.',
'11/03/2023 Added support for Lodestar Layers. Removed extra space before single-symbol polygon layer legend items.',
'',
'Version 4.5 Updates:',
'7/9/2023 Added color for Icon (Class), Refactored polygon svg creation into function. Fixed to use application and page id for the source of the legend layer (also correctly using the static id if multiple map regions on the same page).',
'SVG icons now use the layer scale and color. Using the SVG Icon view box now so that they fix in the legend entries. Polygons now use the layer fill opacity. ',
'7/7/2023 Removed entries in legend for layers that are not rendered in the map region (based on server-side condition, etc.)',
'7/6/2023 Initially added Legend Plugin'))
,p_files_version=>136
);
end;
/
begin
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(888805969167248450)
,p_plugin_id=>wwv_flow_imp.id(887188518588519005)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Label Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Set the column name to be use to look up labels to use in the Legend for layers with multiple symbols. If you set a single string value, it will be used for all layers.',
'Otherwise you can use '','' and '';'' delimiters to map layer names to labeling columns as such:',
'',
'layer1;label_column1,layer2;label_column2,layer3,label_column3',
'',
'If you do not use a label column, then the numeric column used to divide the layer into different symbols will be used.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(888939894395519703)
,p_plugin_id=>wwv_flow_imp.id(887188518588519005)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Map Region'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Static Id of the Map Region to use for the Legend. Only required to be used if there are more than one Map Regions on the page.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '6173796E632066756E6374696F6E206D6170626974735F6C6567656E645F6275696C645F656E747269657328656E747269657329207B0D0A2020666F722028636F6E737420656E747279206F6620656E747269657329207B0D0A20202020636F6E737420';
wwv_flow_imp.g_varchar2_table(2) := '7B0D0A2020202020206974656D49642C0D0A2020202020207469746C652C0D0A20202020202068656C70546578742C0D0A202020202020696E6C696E6548656C70546578742C0D0A20202020202069636F6E547970652C0D0A20202020202069636F6E43';
wwv_flow_imp.g_varchar2_table(3) := '6C6173732C0D0A20202020202069636F6E55726C2C0D0A202020202020636F6C6F722C0D0A2020202020206F75746C696E65436F6C6F722C0D0A2020202020206F7061636974792C0D0A2020202020206F7074696F6E732C0D0A2020202020206C6F6465';
wwv_flow_imp.g_varchar2_table(4) := '737461724974656D4E616D652C0D0A202020202020656E7472794974656D4E616D652C0D0A202020207D203D20656E7472793B0D0A0D0A202020206C657420636F6C6C6170736564203D2066616C73653B0D0A0D0A202020202F2A2054686520456E7472';
wwv_flow_imp.g_varchar2_table(5) := '792070616765206974656D206D69676874206265206265666F726520746865206173736F636961746564204C6F6465737461722070616765206974656D2C20736F207765206E65656420746F207761697420666F7220697420746F20696E697469616C69';
wwv_flow_imp.g_varchar2_table(6) := '7A652066697273742E202A2F0D0A20202020636F6E7374206C6F6465737461724974656D203D206C6F6465737461724974656D4E616D65203F206177616974206D6170626974735F6C6F6465737461726C617965725F776169745F666F725F696E697428';
wwv_flow_imp.g_varchar2_table(7) := '6C6F6465737461724974656D4E616D6529203A206E756C6C3B0D0A0D0A20202020636F6E737420706F6C79737667203D202866696C6C436F6C6F722C207374726F6B65436F6C6F722C2066696C6C4F70616369747929203D3E207B0D0A20202020202072';
wwv_flow_imp.g_varchar2_table(8) := '657475726E20603C7376672077696474683D22323022206865696768743D223230222076696577626F78203D20223020302031323020393022207374796C653D22646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C6967';
wwv_flow_imp.g_varchar2_table(9) := '6E3A206D6964646C653B223E3C706174680D0A2020202020202020202020202020202020202020643D224D2033302E3739353735362C31392E383134333233204C2039312E3930393831342C32342E383237353836204C203130302E32363532352C3633';
wwv_flow_imp.g_varchar2_table(10) := '2E353031333236204C2032312E3030373935382C37302E3636333133204C2033302E3739353735362C31392E383134333233207A20220D0A20202020202020202020202020202020202020207374796C653D2266696C6C3A247B66696C6C436F6C6F727D';
wwv_flow_imp.g_varchar2_table(11) := '3B66696C6C2D6F7061636974793A247B66696C6C4F7061636974797D3B66696C6C2D72756C653A6576656E6F64643B7374726F6B653A247B7374726F6B65436F6C6F727D3B7374726F6B652D77696474683A322E32303030303030353B7374726F6B652D';
wwv_flow_imp.g_varchar2_table(12) := '6C696E656361703A627574743B7374726F6B652D6C696E656A6F696E3A6D697465723B7374726F6B652D6D697465726C696D69743A343B7374726F6B652D6461736861727261793A6E6F6E653B7374726F6B652D6F7061636974793A31222F3E3C2F7376';
wwv_flow_imp.g_varchar2_table(13) := '673E603B0D0A202020207D3B0D0A0D0A20202020636F6E7374206861734F7074696F6E203D20286F70742C206F70744469637429203D3E2028273A27202B20286F707444696374203F3F206F7074696F6E7329202B20273A27292E696E636C7564657328';
wwv_flow_imp.g_varchar2_table(14) := '273A27202B206F7074202B20273A27293B0D0A0D0A202020206C65742073796D626F6C48746D6C2C206974656D436C6173732C20627574746F6E732C20696E6C696E6548656C7048746D6C2C20636F6C6C617073657248746D6C3B0D0A0D0A2020202073';
wwv_flow_imp.g_varchar2_table(15) := '7769746368202869636F6E5479706529207B0D0A2020202020206361736520276E6F6E65273A0D0A202020202020202073796D626F6C48746D6C203D206E756C6C3B0D0A2020202020202020627265616B3B0D0A202020202020636173652027626C616E';
wwv_flow_imp.g_varchar2_table(16) := '6B273A0D0A202020202020202073796D626F6C48746D6C203D202428273C7370616E207374796C653D2277696474683A20323070783B20646973706C61793A20696E6C696E652D626C6F636B3B20766572746963616C2D616C69676E3A206D6964646C65';
wwv_flow_imp.g_varchar2_table(17) := '3B223E27293B0D0A2020202020202020627265616B3B0D0A20202020202063617365202775726C273A0D0A202020202020202073796D626F6C48746D6C203D202428273C696D67207374796C653D2277696474683A323070783B6865696768743A323070';
wwv_flow_imp.g_varchar2_table(18) := '783B646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B223E27290D0A202020202020202020202E70726F702827737263272C2069636F6E55726C293B0D0A2020202020202020627265616B';
wwv_flow_imp.g_varchar2_table(19) := '3B0D0A20202020202063617365202773796D626F6C273A0D0A20202020202063617365202769636F6E5F636C617373273A0D0A202020202020202073796D626F6C48746D6C203D202428603C7370616E207374796C653D226D617267696E3A303B646973';
wwv_flow_imp.g_varchar2_table(20) := '706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B2220636C6173733D226661223E3C2F7370616E3E60290D0A202020202020202020202E637373287B0D0A202020202020202020202020636F6C6F';
wwv_flow_imp.g_varchar2_table(21) := '722C0D0A2020202020202020202020206F7061636974793A206F706163697479203F3F20312C0D0A202020202020202020207D290D0A202020202020202020202E616464436C6173732869636F6E436C617373293B0D0A2020202020202020627265616B';
wwv_flow_imp.g_varchar2_table(22) := '3B0D0A2020202020206361736520276C696E65273A0D0A202020202020202073796D626F6C48746D6C203D202428603C7376672077696474683D22323022206865696768743D2232302220207374796C653D227374726F6B652D77696474683A322E323B';
wwv_flow_imp.g_varchar2_table(23) := '646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B223E3C7061746820643D224D2031382C313420322C36222F3E3C2F7376673E60290D0A202020202020202020202E637373287B0D0A2020';
wwv_flow_imp.g_varchar2_table(24) := '202020202020202020207374726F6B653A20636F6C6F722C0D0A2020202020202020202020206F7061636974793A206F706163697479203F3F20310D0A202020202020202020207D293B0D0A2020202020202020627265616B3B0D0A2020202020206361';
wwv_flow_imp.g_varchar2_table(25) := '736520276C696E655F646F74746564273A0D0A202020202020202073796D626F6C48746D6C203D202428603C7376672077696474683D22323022206865696768743D2232302220207374796C653D227374726F6B652D6461736861727261793A20333B73';
wwv_flow_imp.g_varchar2_table(26) := '74726F6B652D77696474683A322E323B646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B223E3C7061746820643D224D2031382C313420322C36222F3E3C2F7376673E60290D0A20202020';
wwv_flow_imp.g_varchar2_table(27) := '2020202020202E637373287B0D0A2020202020202020202020207374726F6B653A20636F6C6F722C0D0A2020202020202020202020206F7061636974793A206F706163697479203F3F20310D0A202020202020202020207D293B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(28) := '627265616B3B0D0A20202020202063617365202766696C6C273A0D0A202020202020636173652027706F6C79676F6E273A0D0A202020202020202073796D626F6C48746D6C203D20706F6C7973766728636F6C6F722C206F75746C696E65436F6C6F722C';
wwv_flow_imp.g_varchar2_table(29) := '206F706163697479203F3F2031293B0D0A2020202020202020627265616B3B0D0A202020202020636173652027636972636C65273A0D0A202020202020202073796D626F6C48746D6C203D202428603C7376672077696474683D22323022206865696768';
wwv_flow_imp.g_varchar2_table(30) := '743D22323022207374796C653D22646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B207374726F6B652D77696474683A20303B223E3C636972636C652063783D223130222063793D223130';
wwv_flow_imp.g_varchar2_table(31) := '2220723D223722202F3E3C2F7376673E60290D0A202020202020202020202E637373287B0D0A20202020202020202020202066696C6C3A20636F6C6F722C0D0A2020202020202020202020206F7061636974793A206F706163697479203F3F20310D0A20';
wwv_flow_imp.g_varchar2_table(32) := '2020202020202020207D293B0D0A2020202020202020627265616B3B0D0A202020202020636173652027636972636C655F736D616C6C273A0D0A202020202020202073796D626F6C48746D6C203D202428603C7376672077696474683D22323022206865';
wwv_flow_imp.g_varchar2_table(33) := '696768743D22323022207374796C653D22646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B207374726F6B652D77696474683A20303B223E3C636972636C652063783D223130222063793D';
wwv_flow_imp.g_varchar2_table(34) := '2231302220723D223422202F3E3C2F7376673E60290D0A202020202020202020202E637373287B0D0A20202020202020202020202066696C6C3A20636F6C6F722C0D0A2020202020202020202020206F7061636974793A206F706163697479203F3F2031';
wwv_flow_imp.g_varchar2_table(35) := '0D0A202020202020202020207D293B0D0A2020202020202020627265616B3B0D0A20202020202064656661756C743A0D0A20202020202020206966202869636F6E436C61737329207B0D0A2020202020202020202073796D626F6C48746D6C203D202428';
wwv_flow_imp.g_varchar2_table(36) := '603C7370616E207374796C653D226D617267696E3A303B70616464696E672D72696768743A323070783B646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B2220636C6173733D226661223E';
wwv_flow_imp.g_varchar2_table(37) := '3C2F7370616E3E60290D0A2020202020202020202020202E637373287B0D0A2020202020202020202020202020636F6C6F722C0D0A20202020202020202020202020206F7061636974790D0A2020202020202020202020207D290D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(38) := '202020202E616464436C6173732869636F6E436C617373293B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202073796D626F6C48746D6C203D202428603C7370616E207374796C653D226D617267696E3A303B70616464696E67';
wwv_flow_imp.g_varchar2_table(39) := '2D72696768743A323070783B646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B2220636C6173733D2266612066612D686561742D6D6170223E3C2F7370616E3E60290D0A20202020202020';
wwv_flow_imp.g_varchar2_table(40) := '207D0D0A202020207D0D0A0D0A20202020627574746F6E73203D202428603C646976207374796C653D226D617267696E2D746F703A202D3170783B206D617267696E2D626F74746F6D3A202D3170783B223E60293B0D0A0D0A20202020696620286C6F64';
wwv_flow_imp.g_varchar2_table(41) := '65737461724974656D202626206861734F7074696F6E2827746F67676C6561626C65272929207B0D0A202020202020636F6E73742069636F6E203D202428603C7370616E20636C6173733D2266612066612D65796522207374796C653D226D617267696E';
wwv_flow_imp.g_varchar2_table(42) := '3A20303B2220617269612D68696464656E3D2274727565223E3C2F7370616E3E60293B0D0A202020202020627574746F6E732E617070656E64280D0A20202020202020202428603C627574746F6E20636C6173733D22742D466F726D2D68656C70427574';
wwv_flow_imp.g_varchar2_table(43) := '746F6E2220747970653D22627574746F6E22207469746C653D2253686F772F48696465204C61796572223E60290D0A202020202020202020202E617070656E642869636F6E290D0A202020202020202020202E6F6E2827636C69636B272C202865762920';
wwv_flow_imp.g_varchar2_table(44) := '3D3E207B0D0A20202020202020202020202065762E73746F7050726F7061676174696F6E28293B0D0A202020202020202020202020696620286C6F6465737461724974656D2E697356697369626C65282929207B0D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(45) := '6C6F6465737461724974656D2E6869646528293B0D0A2020202020202020202020207D20656C7365207B0D0A20202020202020202020202020206C6F6465737461724974656D2E73686F7728293B0D0A2020202020202020202020207D0D0A2020202020';
wwv_flow_imp.g_varchar2_table(46) := '20202020207D290D0A202020202020202020202E6F6E28276B65797570272C2028657629203D3E207B0D0A20202020202020202020202065762E73746F7050726F7061676174696F6E28293B0D0A202020202020202020207D290D0A202020202020293B';
wwv_flow_imp.g_varchar2_table(47) := '0D0A2020202020206C6F6465737461724974656D2E656C656D656E742E6F6E28277669736962696C6974795F746F67676C6564272C202829203D3E207B0D0A2020202020202020636F6E73742076697369626C65203D206C6F6465737461724974656D2E';
wwv_flow_imp.g_varchar2_table(48) := '697356697369626C6528293B0D0A202020202020202069636F6E2E746F67676C65436C617373282766612D657965272C2076697369626C65292E746F67676C65436C617373282766612D6579652D736C617368272C202176697369626C65293B0D0A2020';
wwv_flow_imp.g_varchar2_table(49) := '202020207D290D0A202020207D0D0A0D0A202020206966202868656C705465787420262620216861734F7074696F6E2827686964655F68656C70272929207B0D0A202020202020627574746F6E732E617070656E64280D0A20202020202020202428273C';
wwv_flow_imp.g_varchar2_table(50) := '627574746F6E20636C6173733D22742D466F726D2D68656C70427574746F6E206A732D6974656D48656C702220747970653D22627574746F6E22207469746C653D2248656C70223E27290D0A202020202020202020202E6F6E2827636C69636B272C2028';
wwv_flow_imp.g_varchar2_table(51) := '657629203D3E207B0D0A20202020202020202020202065762E73746F7050726F7061676174696F6E28293B0D0A202020202020202020202020617065782E7468656D652E706F7075704669656C6448656C70287B0D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(52) := '7469746C652C0D0A202020202020202020202020202068656C70546578742C0D0A2020202020202020202020207D290D0A202020202020202020207D290D0A202020202020202020202E6F6E28276B65797570272C2028657629203D3E207B0D0A202020';
wwv_flow_imp.g_varchar2_table(53) := '20202020202020202065762E73746F7050726F7061676174696F6E28293B0D0A202020202020202020207D290D0A202020202020202020202E617070656E64282428273C7370616E20636C6173733D2266612066612D7175657374696F6E2D636972636C';
wwv_flow_imp.g_varchar2_table(54) := '652D6F22207374796C653D226D617267696E3A20303B2220617269612D68696464656E3D2274727565223E3C2F7370616E3E2729290D0A202020202020293B0D0A202020207D0D0A0D0A20202020696620286861734F7074696F6E282768656164696E67';
wwv_flow_imp.g_varchar2_table(55) := '272929207B0D0A2020202020206974656D436C617373203D2027612D4C697374566965772D646976696465722075692D6261722D696E6865726974273B0D0A202020207D20656C7365207B0D0A2020202020206974656D436C617373203D2027612D4C69';
wwv_flow_imp.g_varchar2_table(56) := '7374566965772D6974656D2075692D626F64792D696E6865726974273B0D0A202020207D0D0A0D0A2020202069662028696E6C696E6548656C705465787420262620216861734F7074696F6E2827686964655F696E6C696E655F68656C70272929207B0D';
wwv_flow_imp.g_varchar2_table(57) := '0A202020202020696E6C696E6548656C7048746D6C203D202428603C7370616E20636C6173733D22742D466F726D2D696E6C696E6548656C70223E60290D0A20202020202020202E7465787428696E6C696E6548656C7054657874293B0D0A202020207D';
wwv_flow_imp.g_varchar2_table(58) := '0D0A0D0A20202020696620286861734F7074696F6E2827636F6C6C61707369626C652729202626206861734F7074696F6E282768656164696E67272929207B0D0A202020202020636F6E737420636F6C6C6170736549636F6E203D202428603C7370616E';
wwv_flow_imp.g_varchar2_table(59) := '20636C6173733D2266612066612D63686576726F6E2D646F776E22207374796C653D226D617267696E3A20303B2220617269612D68696464656E3D2274727565223E3C2F7370616E3E60293B0D0A202020202020636F6C6C617073657248746D6C203D20';
wwv_flow_imp.g_varchar2_table(60) := '2428603C627574746F6E20636C6173733D22742D466F726D2D68656C70427574746F6E2220747970653D22627574746F6E22207469746C653D22436F6C6C617073652F457870616E642053656374696F6E22207374796C653D226D617267696E2D746F70';
wwv_flow_imp.g_varchar2_table(61) := '3A202D3170783B206D617267696E2D626F74746F6D3A202D3170783B20766572746963616C2D616C69676E3A206D6964646C653B223E60290D0A20202020202020202E6F6E2827636C69636B272C2028657629203D3E207B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(62) := '65762E73746F7050726F7061676174696F6E28293B0D0A20202020202020202020636F6C6C6170736564203D2021636F6C6C61707365643B0D0A20202020202020202020666F7220286C65742069203D20656E74726965732E696E6465784F6628656E74';
wwv_flow_imp.g_varchar2_table(63) := '727929202B20313B2069203C20656E74726965732E6C656E6774683B2069202B2B29207B0D0A202020202020202020202020696620286861734F7074696F6E282768656164696E67272C20656E74726965735B695D2E6F7074696F6E73203F3F207B7D29';
wwv_flow_imp.g_varchar2_table(64) := '29207B0D0A2020202020202020202020202020627265616B3B0D0A2020202020202020202020207D0D0A20202020202020202020202024286023247B656E74726965735B695D2E6974656D49647D5F6D6170626974735F6C6567656E645F656E74727960';
wwv_flow_imp.g_varchar2_table(65) := '292E746F67676C652821636F6C6C6170736564293B0D0A202020202020202020202020636F6C6C6170736549636F6E2E746F67676C65436C617373282766612D63686576726F6E2D7269676874272C20636F6C6C6170736564292E746F67676C65436C61';
wwv_flow_imp.g_varchar2_table(66) := '7373282766612D63686576726F6E2D646F776E272C2021636F6C6C6170736564293B0D0A202020202020202020207D0D0A20202020202020207D290D0A20202020202020202E617070656E6428636F6C6C6170736549636F6E293B0D0A202020207D0D0A';
wwv_flow_imp.g_varchar2_table(67) := '0D0A20202020636F6E7374206C69203D2024286023247B6974656D49647D5F6D6170626974735F6C6567656E645F656E74727960293B0D0A202020206C690D0A2020202020202E616464436C617373286974656D436C617373290D0A2020202020202E63';
wwv_flow_imp.g_varchar2_table(68) := '7373287B0D0A2020202020202020646973706C61793A2027666C6578272C0D0A2020202020202020666C6578446972656374696F6E3A2027636F6C756D6E272C0D0A2020202020207D290D0A2020202020202E6F6E2827636C69636B272C202829203D3E';
wwv_flow_imp.g_varchar2_table(69) := '207B0D0A2020202020202020617065782E6576656E742E7472696767657228617065782E6974656D286974656D4964292E656C656D656E742C2027636C69636B27293B0D0A2020202020207D290D0A2020202020202E6F6E28276B65797570272C202865';
wwv_flow_imp.g_varchar2_table(70) := '7629203D3E207B0D0A20202020202020206966202865762E636F6465203D3D3D2027537061636527207C7C2065762E636F6465203D3D3D2027456E7465722729207B0D0A20202020202020202020617065782E6576656E742E7472696767657228617065';
wwv_flow_imp.g_varchar2_table(71) := '782E6974656D286974656D4964292E656C656D656E742C2027636C69636B27293B0D0A20202020202020207D0D0A2020202020207D290D0A2020202020202E617070656E64280D0A20202020202020202428603C646976207374796C653D22646973706C';
wwv_flow_imp.g_varchar2_table(72) := '61793A20666C65783B20666C65782D646972656374696F6E3A20726F773B206A7573746966792D636F6E74656E743A2073706163652D6265747765656E3B223E60290D0A202020202020202020202E617070656E64280D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(73) := '2428603C6469763E60290D0A20202020202020202020202020202E617070656E6428636F6C6C617073657248746D6C290D0A20202020202020202020202020202E617070656E642873796D626F6C48746D6C290D0A20202020202020202020202020202E';
wwv_flow_imp.g_varchar2_table(74) := '617070656E6428272027290D0A20202020202020202020202020202E617070656E64287469746C65290D0A20202020202020202020290D0A202020202020202020202E617070656E6428627574746F6E73290D0A202020202020290D0A2020202020202E';
wwv_flow_imp.g_varchar2_table(75) := '617070656E6428696E6C696E6548656C7048746D6C293B0D0A0D0A202020202F2A20496620746865206974656D2068617320616E7920636C69636B2068616E646C6572732C2067697665206974206120636C69636B61626C6520617070656172616E6365';
wwv_flow_imp.g_varchar2_table(76) := '20616E64206265686176696F722E202A2F0D0A2020202069662028656E7472794974656D4E616D6520262620617065782E64612E674576656E744C6973743F2E736F6D652878203D3E20782E74726967676572696E67456C656D656E7454797065203D3D';
wwv_flow_imp.g_varchar2_table(77) := '3D20274954454D2720262620782E74726967676572696E67456C656D656E74203D3D3D20656E7472794974656D4E616D6520262620782E62696E644576656E7454797065203D3D3D2027636C69636B272929207B0D0A2020202020206C690D0A20202020';
wwv_flow_imp.g_varchar2_table(78) := '202020202E70726F702827746162696E646578272C2030290D0A20202020202020202E6373732827637572736F72272C2027706F696E74657227293B0D0A202020207D0D0A20207D0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(226713348195760311)
,p_plugin_id=>wwv_flow_imp.id(887188518588519005)
,p_file_name=>'mapbits-legend.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '6173796E632066756E6374696F6E206D6170626974735F6C6567656E645F6275696C645F656E74726965732865297B666F7228636F6E73742069206F662065297B636F6E73747B6974656D49643A742C7469746C653A6C2C68656C70546578743A612C69';
wwv_flow_imp.g_varchar2_table(2) := '6E6C696E6548656C70546578743A732C69636F6E547970653A6E2C69636F6E436C6173733A6F2C69636F6E55726C3A702C636F6C6F723A632C6F75746C696E65436F6C6F723A642C6F7061636974793A722C6F7074696F6E733A672C6C6F646573746172';
wwv_flow_imp.g_varchar2_table(3) := '4974656D4E616D653A792C656E7472794974656D4E616D653A687D3D693B6C6574206D3D21313B636F6E737420623D793F6177616974206D6170626974735F6C6F6465737461726C617965725F776169745F666F725F696E69742879293A6E756C6C2C6B';
wwv_flow_imp.g_varchar2_table(4) := '3D28652C692C74293D3E603C7376672077696474683D22323022206865696768743D223230222076696577626F78203D20223020302031323020393022207374796C653D22646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D';
wwv_flow_imp.g_varchar2_table(5) := '616C69676E3A206D6964646C653B223E3C706174685C6E2020202020202020202020202020202020202020643D224D2033302E3739353735362C31392E383134333233204C2039312E3930393831342C32342E383237353836204C203130302E32363532';
wwv_flow_imp.g_varchar2_table(6) := '352C36332E353031333236204C2032312E3030373935382C37302E3636333133204C2033302E3739353735362C31392E383134333233207A20225C6E20202020202020202020202020202020202020207374796C653D2266696C6C3A247B657D3B66696C';
wwv_flow_imp.g_varchar2_table(7) := '6C2D6F7061636974793A247B747D3B66696C6C2D72756C653A6576656E6F64643B7374726F6B653A247B697D3B7374726F6B652D77696474683A322E32303030303030353B7374726F6B652D6C696E656361703A627574743B7374726F6B652D6C696E65';
wwv_flow_imp.g_varchar2_table(8) := '6A6F696E3A6D697465723B7374726F6B652D6D697465726C696D69743A343B7374726F6B652D6461736861727261793A6E6F6E653B7374726F6B652D6F7061636974793A31222F3E3C2F7376673E602C763D28652C69293D3E28223A222B28693F3F6729';
wwv_flow_imp.g_varchar2_table(9) := '2B223A22292E696E636C7564657328223A222B652B223A22293B6C657420662C752C782C772C5F3B737769746368286E297B63617365226E6F6E65223A663D6E756C6C3B627265616B3B6361736522626C616E6B223A663D2428273C7370616E20737479';
wwv_flow_imp.g_varchar2_table(10) := '6C653D2277696474683A20323070783B20646973706C61793A20696E6C696E652D626C6F636B3B20766572746963616C2D616C69676E3A206D6964646C653B223E27293B627265616B3B636173652275726C223A663D2428273C696D67207374796C653D';
wwv_flow_imp.g_varchar2_table(11) := '2277696474683A323070783B6865696768743A323070783B646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B223E27292E70726F702822737263222C70293B627265616B3B636173652273';
wwv_flow_imp.g_varchar2_table(12) := '796D626F6C223A636173652269636F6E5F636C617373223A663D2428273C7370616E207374796C653D226D617267696E3A303B646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B2220636C';
wwv_flow_imp.g_varchar2_table(13) := '6173733D226661223E3C2F7370616E3E27292E637373287B636F6C6F723A632C6F7061636974793A723F3F317D292E616464436C617373286F293B627265616B3B63617365226C696E65223A663D2428273C7376672077696474683D2232302220686569';
wwv_flow_imp.g_varchar2_table(14) := '6768743D2232302220207374796C653D227374726F6B652D77696474683A322E323B646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B223E3C7061746820643D224D2031382C313420322C';
wwv_flow_imp.g_varchar2_table(15) := '36222F3E3C2F7376673E27292E637373287B7374726F6B653A632C6F7061636974793A723F3F317D293B627265616B3B63617365226C696E655F646F74746564223A663D2428273C7376672077696474683D22323022206865696768743D223230222020';
wwv_flow_imp.g_varchar2_table(16) := '7374796C653D227374726F6B652D6461736861727261793A20333B7374726F6B652D77696474683A322E323B646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B223E3C7061746820643D22';
wwv_flow_imp.g_varchar2_table(17) := '4D2031382C313420322C36222F3E3C2F7376673E27292E637373287B7374726F6B653A632C6F7061636974793A723F3F317D293B627265616B3B636173652266696C6C223A6361736522706F6C79676F6E223A663D6B28632C642C723F3F31293B627265';
wwv_flow_imp.g_varchar2_table(18) := '616B3B6361736522636972636C65223A663D2428273C7376672077696474683D22323022206865696768743D22323022207374796C653D22646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C65';
wwv_flow_imp.g_varchar2_table(19) := '3B207374726F6B652D77696474683A20303B223E3C636972636C652063783D223130222063793D2231302220723D223722202F3E3C2F7376673E27292E637373287B66696C6C3A632C6F7061636974793A723F3F317D293B627265616B3B636173652263';
wwv_flow_imp.g_varchar2_table(20) := '6972636C655F736D616C6C223A663D2428273C7376672077696474683D22323022206865696768743D22323022207374796C653D22646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B2073';
wwv_flow_imp.g_varchar2_table(21) := '74726F6B652D77696474683A20303B223E3C636972636C652063783D223130222063793D2231302220723D223422202F3E3C2F7376673E27292E637373287B66696C6C3A632C6F7061636974793A723F3F317D293B627265616B3B64656661756C743A66';
wwv_flow_imp.g_varchar2_table(22) := '3D6F3F2428273C7370616E207374796C653D226D617267696E3A303B70616464696E672D72696768743A323070783B646973706C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B2220636C6173733D';
wwv_flow_imp.g_varchar2_table(23) := '226661223E3C2F7370616E3E27292E637373287B636F6C6F723A632C6F7061636974793A727D292E616464436C617373286F293A2428273C7370616E207374796C653D226D617267696E3A303B70616464696E672D72696768743A323070783B64697370';
wwv_flow_imp.g_varchar2_table(24) := '6C61793A20696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A206D6964646C653B2220636C6173733D2266612066612D686561742D6D6170223E3C2F7370616E3E27297D696628783D2428273C646976207374796C653D226D617267';
wwv_flow_imp.g_varchar2_table(25) := '696E2D746F703A202D3170783B206D617267696E2D626F74746F6D3A202D3170783B223E27292C622626762822746F67676C6561626C652229297B636F6E737420653D2428273C7370616E20636C6173733D2266612066612D65796522207374796C653D';
wwv_flow_imp.g_varchar2_table(26) := '226D617267696E3A20303B2220617269612D68696464656E3D2274727565223E3C2F7370616E3E27293B782E617070656E64282428273C627574746F6E20636C6173733D22742D466F726D2D68656C70427574746F6E2220747970653D22627574746F6E';
wwv_flow_imp.g_varchar2_table(27) := '22207469746C653D2253686F772F48696465204C61796572223E27292E617070656E642865292E6F6E2822636C69636B222C28653D3E7B652E73746F7050726F7061676174696F6E28292C622E697356697369626C6528293F622E6869646528293A622E';
wwv_flow_imp.g_varchar2_table(28) := '73686F7728297D29292E6F6E28226B65797570222C28653D3E7B652E73746F7050726F7061676174696F6E28297D2929292C622E656C656D656E742E6F6E28227669736962696C6974795F746F67676C6564222C2828293D3E7B636F6E737420693D622E';
wwv_flow_imp.g_varchar2_table(29) := '697356697369626C6528293B652E746F67676C65436C617373282266612D657965222C69292E746F67676C65436C617373282266612D6579652D736C617368222C2169297D29297D69662861262621762822686964655F68656C7022292626782E617070';
wwv_flow_imp.g_varchar2_table(30) := '656E64282428273C627574746F6E20636C6173733D22742D466F726D2D68656C70427574746F6E206A732D6974656D48656C702220747970653D22627574746F6E22207469746C653D2248656C70223E27292E6F6E2822636C69636B222C28653D3E7B65';
wwv_flow_imp.g_varchar2_table(31) := '2E73746F7050726F7061676174696F6E28292C617065782E7468656D652E706F7075704669656C6448656C70287B7469746C653A6C2C68656C70546578743A617D297D29292E6F6E28226B65797570222C28653D3E7B652E73746F7050726F7061676174';
wwv_flow_imp.g_varchar2_table(32) := '696F6E28297D29292E617070656E64282428273C7370616E20636C6173733D2266612066612D7175657374696F6E2D636972636C652D6F22207374796C653D226D617267696E3A20303B2220617269612D68696464656E3D2274727565223E3C2F737061';
wwv_flow_imp.g_varchar2_table(33) := '6E3E272929292C753D76282268656164696E6722293F22612D4C697374566965772D646976696465722075692D6261722D696E6865726974223A22612D4C697374566965772D6974656D2075692D626F64792D696E6865726974222C7326262176282268';
wwv_flow_imp.g_varchar2_table(34) := '6964655F696E6C696E655F68656C702229262628773D2428273C7370616E20636C6173733D22742D466F726D2D696E6C696E6548656C70223E27292E74657874287329292C762822636F6C6C61707369626C652229262676282268656164696E67222929';
wwv_flow_imp.g_varchar2_table(35) := '7B636F6E737420743D2428273C7370616E20636C6173733D2266612066612D63686576726F6E2D646F776E22207374796C653D226D617267696E3A20303B2220617269612D68696464656E3D2274727565223E3C2F7370616E3E27293B5F3D2428273C62';
wwv_flow_imp.g_varchar2_table(36) := '7574746F6E20636C6173733D22742D466F726D2D68656C70427574746F6E2220747970653D22627574746F6E22207469746C653D22436F6C6C617073652F457870616E642053656374696F6E22207374796C653D226D617267696E2D746F703A202D3170';
wwv_flow_imp.g_varchar2_table(37) := '783B206D617267696E2D626F74746F6D3A202D3170783B20766572746963616C2D616C69676E3A206D6964646C653B223E27292E6F6E2822636C69636B222C286C3D3E7B6C2E73746F7050726F7061676174696F6E28292C6D3D216D3B666F72286C6574';
wwv_flow_imp.g_varchar2_table(38) := '206C3D652E696E6465784F662869292B313B6C3C652E6C656E67746826262176282268656164696E67222C655B6C5D2E6F7074696F6E733F3F7B7D293B6C2B2B2924286023247B655B6C5D2E6974656D49647D5F6D6170626974735F6C6567656E645F65';
wwv_flow_imp.g_varchar2_table(39) := '6E74727960292E746F67676C6528216D292C742E746F67676C65436C617373282266612D63686576726F6E2D7269676874222C6D292E746F67676C65436C617373282266612D63686576726F6E2D646F776E222C216D297D29292E617070656E64287429';
wwv_flow_imp.g_varchar2_table(40) := '7D636F6E737420433D24286023247B747D5F6D6170626974735F6C6567656E645F656E74727960293B432E616464436C6173732875292E637373287B646973706C61793A22666C6578222C666C6578446972656374696F6E3A22636F6C756D6E227D292E';
wwv_flow_imp.g_varchar2_table(41) := '6F6E2822636C69636B222C2828293D3E7B617065782E6576656E742E7472696767657228617065782E6974656D2874292E656C656D656E742C22636C69636B22297D29292E6F6E28226B65797570222C28653D3E7B22537061636522213D3D652E636F64';
wwv_flow_imp.g_varchar2_table(42) := '65262622456E74657222213D3D652E636F64657C7C617065782E6576656E742E7472696767657228617065782E6974656D2874292E656C656D656E742C22636C69636B22297D29292E617070656E64282428273C646976207374796C653D22646973706C';
wwv_flow_imp.g_varchar2_table(43) := '61793A20666C65783B20666C65782D646972656374696F6E3A20726F773B206A7573746966792D636F6E74656E743A2073706163652D6265747765656E3B223E27292E617070656E64282428223C6469763E22292E617070656E64285F292E617070656E';
wwv_flow_imp.g_varchar2_table(44) := '642866292E617070656E6428222022292E617070656E64286C29292E617070656E64287829292E617070656E642877292C682626617065782E64612E674576656E744C6973743F2E736F6D652828653D3E224954454D223D3D3D652E7472696767657269';
wwv_flow_imp.g_varchar2_table(45) := '6E67456C656D656E74547970652626652E74726967676572696E67456C656D656E743D3D3D68262622636C69636B223D3D3D652E62696E644576656E745479706529292626432E70726F702822746162696E646578222C30292E6373732822637572736F';
wwv_flow_imp.g_varchar2_table(46) := '72222C22706F696E74657222297D7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(228016680358310620)
,p_plugin_id=>wwv_flow_imp.id(887188518588519005)
,p_file_name=>'mapbits-legend.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '7B0D0A202020202242757267223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223666663366334222C0D0A2020202020202020202020202223363732303434220D0A20202020202020205D2C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(2) := '202233223A205B0D0A2020202020202020202020202223666663366334222C0D0A2020202020202020202020202223636336303764222C0D0A2020202020202020202020202223363732303434220D0A20202020202020205D2C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(3) := '2234223A205B0D0A2020202020202020202020202223666663366334222C0D0A2020202020202020202020202223653338313931222C0D0A2020202020202020202020202223616434363663222C0D0A2020202020202020202020202223363732303434';
wwv_flow_imp.g_varchar2_table(4) := '220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223666663366334222C0D0A2020202020202020202020202223656539313962222C0D0A202020202020202020202020222363633630376422';
wwv_flow_imp.g_varchar2_table(5) := '2C0D0A2020202020202020202020202223396533393633222C0D0A2020202020202020202020202223363732303434220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223666663366334222C';
wwv_flow_imp.g_varchar2_table(6) := '0D0A2020202020202020202020202223663239636133222C0D0A2020202020202020202020202223646137343839222C0D0A2020202020202020202020202223623935303733222C0D0A2020202020202020202020202223393333343564222C0D0A2020';
wwv_flow_imp.g_varchar2_table(7) := '202020202020202020202223363732303434220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223666663366334222C0D0A2020202020202020202020202223663461336138222C0D0A202020';
wwv_flow_imp.g_varchar2_table(8) := '2020202020202020202223653338313931222C0D0A2020202020202020202020202223636336303764222C0D0A2020202020202020202020202223616434363663222C0D0A2020202020202020202020202223386233303538222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(9) := '20202020202223363732303434220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A202020202242';
wwv_flow_imp.g_varchar2_table(10) := '757267596C223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223666265366335222C0D0A2020202020202020202020202223373032383461220D0A20202020202020205D2C0D0A20202020202020202233223A205B';
wwv_flow_imp.g_varchar2_table(11) := '0D0A2020202020202020202020202223666265366335222C0D0A2020202020202020202020202223646337313736222C0D0A2020202020202020202020202223373032383461220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D';
wwv_flow_imp.g_varchar2_table(12) := '0A2020202020202020202020202223666265366335222C0D0A2020202020202020202020202223656538613832222C0D0A2020202020202020202020202223633835383663222C0D0A2020202020202020202020202223373032383461220D0A20202020';
wwv_flow_imp.g_varchar2_table(13) := '202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223666265366335222C0D0A2020202020202020202020202223663261323861222C0D0A2020202020202020202020202223646337313736222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(14) := '20202020202020202223623234623635222C0D0A2020202020202020202020202223373032383461220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223666265366335222C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(15) := '202020202020202223663462313931222C0D0A2020202020202020202020202223653738303764222C0D0A2020202020202020202020202223643036323730222C0D0A2020202020202020202020202223613434333630222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(16) := '2020202223373032383461220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223666265366335222C0D0A2020202020202020202020202223663562613938222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(17) := '20202223656538613832222C0D0A2020202020202020202020202223646337313736222C0D0A2020202020202020202020202223633835383663222C0D0A2020202020202020202020202223396333663564222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(18) := '373032383461220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A20202020225265644F72223A20';
wwv_flow_imp.g_varchar2_table(19) := '7B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223663664326139222C0D0A2020202020202020202020202223623133663634220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(20) := '2020202020202223663664326139222C0D0A2020202020202020202020202223656138313731222C0D0A2020202020202020202020202223623133663634220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(21) := '20202020202223663664326139222C0D0A2020202020202020202020202223663139633763222C0D0A2020202020202020202020202223646436383663222C0D0A2020202020202020202020202223623133663634220D0A20202020202020205D2C0D0A';
wwv_flow_imp.g_varchar2_table(22) := '20202020202020202235223A205B0D0A2020202020202020202020202223663664326139222C0D0A2020202020202020202020202223663361613834222C0D0A2020202020202020202020202223656138313731222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(23) := '2223643535643661222C0D0A2020202020202020202020202223623133663634220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223663664326139222C0D0A20202020202020202020202022';
wwv_flow_imp.g_varchar2_table(24) := '23663462323861222C0D0A2020202020202020202020202223656639313737222C0D0A2020202020202020202020202223653337323664222C0D0A2020202020202020202020202223636635363639222C0D0A2020202020202020202020202223623133';
wwv_flow_imp.g_varchar2_table(25) := '663634220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223663664326139222C0D0A2020202020202020202020202223663562373865222C0D0A202020202020202020202020222366313963';
wwv_flow_imp.g_varchar2_table(26) := '3763222C0D0A2020202020202020202020202223656138313731222C0D0A2020202020202020202020202223646436383663222C0D0A2020202020202020202020202223636135323638222C0D0A2020202020202020202020202223623133663634220D';
wwv_flow_imp.g_varchar2_table(27) := '0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A20202020224F7259656C223A207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(28) := '2020202232223A205B0D0A2020202020202020202020202223656364613961222C0D0A2020202020202020202020202223656534643561220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(29) := '656364613961222C0D0A2020202020202020202020202223663739343564222C0D0A2020202020202020202020202223656534643561220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A202020202020202020202020222365';
wwv_flow_imp.g_varchar2_table(30) := '6364613961222C0D0A2020202020202020202020202223663361643661222C0D0A2020202020202020202020202223663937623537222C0D0A2020202020202020202020202223656534643561220D0A20202020202020205D2C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(31) := '2235223A205B0D0A2020202020202020202020202223656364613961222C0D0A2020202020202020202020202223663162393733222C0D0A2020202020202020202020202223663739343564222C0D0A2020202020202020202020202223663836663536';
wwv_flow_imp.g_varchar2_table(32) := '222C0D0A2020202020202020202020202223656534643561220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223656364613961222C0D0A202020202020202020202020222366306330373922';
wwv_flow_imp.g_varchar2_table(33) := '2C0D0A2020202020202020202020202223663561333633222C0D0A2020202020202020202020202223663938353538222C0D0A2020202020202020202020202223663736383536222C0D0A2020202020202020202020202223656534643561220D0A2020';
wwv_flow_imp.g_varchar2_table(34) := '2020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223656364613961222C0D0A2020202020202020202020202223656663343765222C0D0A2020202020202020202020202223663361643661222C0D0A2020';
wwv_flow_imp.g_varchar2_table(35) := '202020202020202020202223663739343564222C0D0A2020202020202020202020202223663937623537222C0D0A2020202020202020202020202223663636333536222C0D0A2020202020202020202020202223656534643561220D0A20202020202020';
wwv_flow_imp.g_varchar2_table(36) := '205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A20202020225065616368223A207B0D0A20202020202020202232223A20';
wwv_flow_imp.g_varchar2_table(37) := '5B0D0A2020202020202020202020202223666465306335222C0D0A2020202020202020202020202223656234613430220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223666465306335222C';
wwv_flow_imp.g_varchar2_table(38) := '0D0A2020202020202020202020202223663539653732222C0D0A2020202020202020202020202223656234613430220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223666465306335222C0D';
wwv_flow_imp.g_varchar2_table(39) := '0A2020202020202020202020202223663862353862222C0D0A2020202020202020202020202223663238353564222C0D0A2020202020202020202020202223656234613430220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A';
wwv_flow_imp.g_varchar2_table(40) := '2020202020202020202020202223666465306335222C0D0A2020202020202020202020202223663963303938222C0D0A2020202020202020202020202223663539653732222C0D0A2020202020202020202020202223663137383534222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(41) := '20202020202020202223656234613430220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223666465306335222C0D0A2020202020202020202020202223666163376131222C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(42) := '202020202020202223663761633830222C0D0A2020202020202020202020202223663338663635222C0D0A2020202020202020202020202223663037303466222C0D0A2020202020202020202020202223656234613430220D0A20202020202020205D2C';
wwv_flow_imp.g_varchar2_table(43) := '0D0A20202020202020202237223A205B0D0A2020202020202020202020202223666465306335222C0D0A2020202020202020202020202223666163626136222C0D0A2020202020202020202020202223663862353862222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(44) := '20202223663539653732222C0D0A2020202020202020202020202223663238353564222C0D0A2020202020202020202020202223656636613463222C0D0A2020202020202020202020202223656234613430220D0A20202020202020205D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(45) := '20202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A202020202250696E6B596C223A207B0D0A20202020202020202232223A205B0D0A20202020';
wwv_flow_imp.g_varchar2_table(46) := '20202020202020202223666566366235222C0D0A2020202020202020202020202223653135333833220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223666566366235222C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(47) := '202020202020202223666661363739222C0D0A2020202020202020202020202223653135333833220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223666566366235222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(48) := '2020202020202223666663323835222C0D0A2020202020202020202020202223666138613736222C0D0A2020202020202020202020202223653135333833220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(49) := '20202020202223666566366235222C0D0A2020202020202020202020202223666664303865222C0D0A2020202020202020202020202223666661363739222C0D0A2020202020202020202020202223663637623737222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(50) := '202223653135333833220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223666566366235222C0D0A2020202020202020202020202223666664373935222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(51) := '2223666662373766222C0D0A2020202020202020202020202223666439353736222C0D0A2020202020202020202020202223663337333738222C0D0A2020202020202020202020202223653135333833220D0A20202020202020205D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(52) := '2020202237223A205B0D0A2020202020202020202020202223666566366235222C0D0A2020202020202020202020202223666664643961222C0D0A2020202020202020202020202223666663323835222C0D0A2020202020202020202020202223666661';
wwv_flow_imp.g_varchar2_table(53) := '363739222C0D0A2020202020202020202020202223666138613736222C0D0A2020202020202020202020202223663136643761222C0D0A2020202020202020202020202223653135333833220D0A20202020202020205D2C0D0A20202020202020202274';
wwv_flow_imp.g_varchar2_table(54) := '616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A20202020224D696E74223A207B0D0A20202020202020202232223A205B0D0A20202020202020202020202022';
wwv_flow_imp.g_varchar2_table(55) := '23653466316531222C0D0A2020202020202020202020202223306435383566220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223653466316531222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(56) := '363361366130222C0D0A2020202020202020202020202223306435383566220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223653466316531222C0D0A202020202020202020202020222338';
wwv_flow_imp.g_varchar2_table(57) := '3963306236222C0D0A2020202020202020202020202223343438633861222C0D0A2020202020202020202020202223306435383566220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A20202020202020202020202022234534';
wwv_flow_imp.g_varchar2_table(58) := '46314531222C0D0A2020202020202020202020202223394343444331222C0D0A2020202020202020202020202223363341364130222C0D0A2020202020202020202020202223333337463746222C0D0A2020202020202020202020202223304435383546';
wwv_flow_imp.g_varchar2_table(59) := '220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223653466316531222C0D0A2020202020202020202020202223616264346337222C0D0A202020202020202020202020222337616235616422';
wwv_flow_imp.g_varchar2_table(60) := '2C0D0A2020202020202020202020202223353039363933222C0D0A2020202020202020202020202223326337373738222C0D0A2020202020202020202020202223306435383566220D0A20202020202020205D2C0D0A20202020202020202237223A205B';
wwv_flow_imp.g_varchar2_table(61) := '0D0A2020202020202020202020202223653466316531222C0D0A2020202020202020202020202223623464396363222C0D0A2020202020202020202020202223383963306236222C0D0A2020202020202020202020202223363361366130222C0D0A2020';
wwv_flow_imp.g_varchar2_table(62) := '202020202020202020202223343438633861222C0D0A2020202020202020202020202223323837323734222C0D0A2020202020202020202020202223306435383566220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A';
wwv_flow_imp.g_varchar2_table(63) := '202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A2020202022426C7547726E223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223633465366333';
wwv_flow_imp.g_varchar2_table(64) := '222C0D0A2020202020202020202020202223316434663630220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223633465366333222C0D0A202020202020202020202020222334646132383422';
wwv_flow_imp.g_varchar2_table(65) := '2C0D0A2020202020202020202020202223316434663630220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223633465366333222C0D0A2020202020202020202020202223366462633930222C';
wwv_flow_imp.g_varchar2_table(66) := '0D0A2020202020202020202020202223333638373761222C0D0A2020202020202020202020202223316434663630220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223633465366333222C0D';
wwv_flow_imp.g_varchar2_table(67) := '0A2020202020202020202020202223383063373939222C0D0A2020202020202020202020202223346461323834222C0D0A2020202020202020202020202223326437393734222C0D0A2020202020202020202020202223316434663630220D0A20202020';
wwv_flow_imp.g_varchar2_table(68) := '202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223633465366333222C0D0A2020202020202020202020202223386463653966222C0D0A2020202020202020202020202223356662323862222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(69) := '20202020202020202223336539323765222C0D0A2020202020202020202020202223323937303731222C0D0A2020202020202020202020202223316434663630220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(70) := '202020202020202223633465366333222C0D0A2020202020202020202020202223393664326134222C0D0A2020202020202020202020202223366462633930222C0D0A2020202020202020202020202223346461323834222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(71) := '2020202223333638373761222C0D0A2020202020202020202020202223323636623665222C0D0A2020202020202020202020202223316434663630220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(72) := '2020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A20202020224461726B4D696E74223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223643266626434222C0D0A20';
wwv_flow_imp.g_varchar2_table(73) := '20202020202020202020202223313233663561220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223643266626434222C0D0A2020202020202020202020202223353539633965222C0D0A2020';
wwv_flow_imp.g_varchar2_table(74) := '202020202020202020202223313233663561220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223643266626434222C0D0A2020202020202020202020202223376262636230222C0D0A202020';
wwv_flow_imp.g_varchar2_table(75) := '2020202020202020202223336137633839222C0D0A2020202020202020202020202223313233663561220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223643266626434222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(76) := '20202020202020202223386563636239222C0D0A2020202020202020202020202223353539633965222C0D0A2020202020202020202020202223326236633766222C0D0A2020202020202020202020202223313233663561220D0A20202020202020205D';
wwv_flow_imp.g_varchar2_table(77) := '2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223643266626434222C0D0A2020202020202020202020202223396364356265222C0D0A2020202020202020202020202223366361666139222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(78) := '2020202223343538383932222C0D0A2020202020202020202020202223323636333737222C0D0A2020202020202020202020202223313233663561220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(79) := '20202223643266626434222C0D0A2020202020202020202020202223613564626332222C0D0A2020202020202020202020202223376262636230222C0D0A2020202020202020202020202223353539633965222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(80) := '336137633839222C0D0A2020202020202020202020202223323335643732222C0D0A2020202020202020202020202223313233663561220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(81) := '227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A2020202022456D726C64223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223643366326133222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(82) := '2020202223303734303530220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223643366326133222C0D0A2020202020202020202020202223346339623832222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(83) := '20202223303734303530220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223643366326133222C0D0A2020202020202020202020202223366363303862222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(84) := '202223323137613739222C0D0A2020202020202020202020202223303734303530220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223643366326133222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(85) := '2223383264303931222C0D0A2020202020202020202020202223346339623832222C0D0A2020202020202020202020202223313936393666222C0D0A2020202020202020202020202223303734303530220D0A20202020202020205D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(86) := '2020202236223A205B0D0A2020202020202020202020202223643366326133222C0D0A2020202020202020202020202223386664613934222C0D0A2020202020202020202020202223363062313837222C0D0A2020202020202020202020202223333538';
wwv_flow_imp.g_varchar2_table(87) := '373764222C0D0A2020202020202020202020202223313435663639222C0D0A2020202020202020202020202223303734303530220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A202020202020202020202020222364336632';
wwv_flow_imp.g_varchar2_table(88) := '6133222C0D0A2020202020202020202020202223393765313936222C0D0A2020202020202020202020202223366363303862222C0D0A2020202020202020202020202223346339623832222C0D0A2020202020202020202020202223323137613739222C';
wwv_flow_imp.g_varchar2_table(89) := '0D0A2020202020202020202020202223313035393635222C0D0A2020202020202020202020202223303734303530220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E746974';
wwv_flow_imp.g_varchar2_table(90) := '6174697665220D0A20202020202020205D0D0A202020207D2C0D0A202020202261675F47726E596C223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223323435363638222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(91) := '454445463544220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223323435363638222C0D0A2020202020202020202020202223333941423745222C0D0A202020202020202020202020222345';
wwv_flow_imp.g_varchar2_table(92) := '4445463544220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223323435363638222C0D0A2020202020202020202020202223304438463831222C0D0A20202020202020202020202022233645';
wwv_flow_imp.g_varchar2_table(93) := '43353734222C0D0A2020202020202020202020202223454445463544220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223323435363638222C0D0A2020202020202020202020202223303438';
wwv_flow_imp.g_varchar2_table(94) := '313745222C0D0A2020202020202020202020202223333941423745222C0D0A2020202020202020202020202223384244313644222C0D0A2020202020202020202020202223454445463544220D0A20202020202020205D2C0D0A20202020202020202236';
wwv_flow_imp.g_varchar2_table(95) := '223A205B0D0A2020202020202020202020202223323435363638222C0D0A2020202020202020202020202223303937383743222C0D0A2020202020202020202020202223314439413831222C0D0A2020202020202020202020202223353842423739222C';
wwv_flow_imp.g_varchar2_table(96) := '0D0A2020202020202020202020202223394444383639222C0D0A2020202020202020202020202223454445463544220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223323435363638222C0D';
wwv_flow_imp.g_varchar2_table(97) := '0A2020202020202020202020202223304637323739222C0D0A2020202020202020202020202223304438463831222C0D0A2020202020202020202020202223333941423745222C0D0A2020202020202020202020202223364543353734222C0D0A202020';
wwv_flow_imp.g_varchar2_table(98) := '2020202020202020202223413944433637222C0D0A2020202020202020202020202223454445463544220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020226167677265676174696F6E22';
wwv_flow_imp.g_varchar2_table(99) := '0D0A20202020202020205D0D0A202020207D2C0D0A2020202022426C75596C223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223663766656165222C0D0A2020202020202020202020202223303435323735220D0A';
wwv_flow_imp.g_varchar2_table(100) := '20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223663766656165222C0D0A2020202020202020202020202223343661656130222C0D0A2020202020202020202020202223303435323735220D0A20';
wwv_flow_imp.g_varchar2_table(101) := '202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223663766656165222C0D0A2020202020202020202020202223376363626132222C0D0A2020202020202020202020202223303839303939222C0D0A20';
wwv_flow_imp.g_varchar2_table(102) := '20202020202020202020202223303435323735220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223663766656165222C0D0A2020202020202020202020202223396264386134222C0D0A2020';
wwv_flow_imp.g_varchar2_table(103) := '202020202020202020202223343661656130222C0D0A2020202020202020202020202223303538303932222C0D0A2020202020202020202020202223303435323735220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A202020';
wwv_flow_imp.g_varchar2_table(104) := '2020202020202020202223663766656165222C0D0A2020202020202020202020202223616365316134222C0D0A2020202020202020202020202223363862666131222C0D0A2020202020202020202020202223326139633963222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(105) := '20202020202223303237373865222C0D0A2020202020202020202020202223303435323735220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223663766656165222C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(106) := '202020202223623765366135222C0D0A2020202020202020202020202223376363626132222C0D0A2020202020202020202020202223343661656130222C0D0A2020202020202020202020202223303839303939222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(107) := '2223303037313862222C0D0A2020202020202020202020202223303435323735220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A202020202020';
wwv_flow_imp.g_varchar2_table(108) := '20205D0D0A202020207D2C0D0A20202020225465616C223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223643165656561222C0D0A2020202020202020202020202223326135363734220D0A20202020202020205D';
wwv_flow_imp.g_varchar2_table(109) := '2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223643165656561222C0D0A2020202020202020202020202223363861626238222C0D0A2020202020202020202020202223326135363734220D0A20202020202020205D2C';
wwv_flow_imp.g_varchar2_table(110) := '0D0A20202020202020202234223A205B0D0A2020202020202020202020202223643165656561222C0D0A2020202020202020202020202223383563346339222C0D0A2020202020202020202020202223346639306136222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(111) := '20202223326135363734220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223643165656561222C0D0A2020202020202020202020202223393664306431222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(112) := '202223363861626238222C0D0A2020202020202020202020202223343538323962222C0D0A2020202020202020202020202223326135363734220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(113) := '2223643165656561222C0D0A2020202020202020202020202223613164376436222C0D0A2020202020202020202020202223373962626333222C0D0A2020202020202020202020202223353939626165222C0D0A20202020202020202020202022233366';
wwv_flow_imp.g_varchar2_table(114) := '37393934222C0D0A2020202020202020202020202223326135363734220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223643165656561222C0D0A2020202020202020202020202223613864';
wwv_flow_imp.g_varchar2_table(115) := '626439222C0D0A2020202020202020202020202223383563346339222C0D0A2020202020202020202020202223363861626238222C0D0A2020202020202020202020202223346639306136222C0D0A202020202020202020202020222333623733386622';
wwv_flow_imp.g_varchar2_table(116) := '2C0D0A2020202020202020202020202223326135363734220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A20202020';
wwv_flow_imp.g_varchar2_table(117) := '7D2C0D0A20202020225465616C47726E223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223623066326263222C0D0A2020202020202020202020202223323537643938220D0A20202020202020205D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(118) := '20202020202233223A205B0D0A2020202020202020202020202223623066326263222C0D0A2020202020202020202020202223346363386133222C0D0A2020202020202020202020202223323537643938220D0A20202020202020205D2C0D0A20202020';
wwv_flow_imp.g_varchar2_table(119) := '202020202234223A205B0D0A2020202020202020202020202223623066326263222C0D0A2020202020202020202020202223363764626135222C0D0A2020202020202020202020202223333862326133222C0D0A20202020202020202020202022233235';
wwv_flow_imp.g_varchar2_table(120) := '37643938220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223623066326263222C0D0A2020202020202020202020202223373765326138222C0D0A2020202020202020202020202223346363';
wwv_flow_imp.g_varchar2_table(121) := '386133222C0D0A2020202020202020202020202223333161366132222C0D0A2020202020202020202020202223323537643938220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A202020202020202020202020222362306632';
wwv_flow_imp.g_varchar2_table(122) := '6263222C0D0A2020202020202020202020202223383265366161222C0D0A2020202020202020202020202223356264346134222C0D0A2020202020202020202020202223336662626133222C0D0A2020202020202020202020202223326539656131222C';
wwv_flow_imp.g_varchar2_table(123) := '0D0A2020202020202020202020202223323537643938220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223623066326263222C0D0A2020202020202020202020202223383965386163222C0D';
wwv_flow_imp.g_varchar2_table(124) := '0A2020202020202020202020202223363764626135222C0D0A2020202020202020202020202223346363386133222C0D0A2020202020202020202020202223333862326133222C0D0A2020202020202020202020202223326339386130222C0D0A202020';
wwv_flow_imp.g_varchar2_table(125) := '2020202020202020202223323537643938220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A2020';
wwv_flow_imp.g_varchar2_table(126) := '20202250757270223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223663365306637222C0D0A2020202020202020202020202223363335383966220D0A20202020202020205D2C0D0A20202020202020202233223A';
wwv_flow_imp.g_varchar2_table(127) := '205B0D0A2020202020202020202020202223663365306637222C0D0A2020202020202020202020202223623939386464222C0D0A2020202020202020202020202223363335383966220D0A20202020202020205D2C0D0A20202020202020202234223A20';
wwv_flow_imp.g_varchar2_table(128) := '5B0D0A2020202020202020202020202223663365306637222C0D0A2020202020202020202020202223643161666538222C0D0A2020202020202020202020202223396638326365222C0D0A2020202020202020202020202223363335383966220D0A2020';
wwv_flow_imp.g_varchar2_table(129) := '2020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223663365306637222C0D0A2020202020202020202020202223646262616564222C0D0A2020202020202020202020202223623939386464222C0D0A2020';
wwv_flow_imp.g_varchar2_table(130) := '202020202020202020202223393137386334222C0D0A2020202020202020202020202223363335383966220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223663365306637222C0D0A202020';
wwv_flow_imp.g_varchar2_table(131) := '2020202020202020202223653063326566222C0D0A2020202020202020202020202223633861356534222C0D0A2020202020202020202020202223616138626434222C0D0A2020202020202020202020202223383837316265222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(132) := '20202020202223363335383966220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223663365306637222C0D0A2020202020202020202020202223653463376631222C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(133) := '202020202223643161666538222C0D0A2020202020202020202020202223623939386464222C0D0A2020202020202020202020202223396638326365222C0D0A2020202020202020202020202223383236646261222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(134) := '2223363335383966220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A2020202022507572704F72';
wwv_flow_imp.g_varchar2_table(135) := '223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223663964646461222C0D0A2020202020202020202020202223353733623838220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A202020';
wwv_flow_imp.g_varchar2_table(136) := '2020202020202020202223663964646461222C0D0A2020202020202020202020202223636537386233222C0D0A2020202020202020202020202223353733623838220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A20202020';
wwv_flow_imp.g_varchar2_table(137) := '20202020202020202223663964646461222C0D0A2020202020202020202020202223653539376239222C0D0A2020202020202020202020202223616435666164222C0D0A2020202020202020202020202223353733623838220D0A20202020202020205D';
wwv_flow_imp.g_varchar2_table(138) := '2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223663964646461222C0D0A2020202020202020202020202223656461386264222C0D0A2020202020202020202020202223636537386233222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(139) := '2020202223393935356138222C0D0A2020202020202020202020202223353733623838220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223663964646461222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(140) := '20202223663062326331222C0D0A2020202020202020202020202223646438616236222C0D0A2020202020202020202020202223626236396230222C0D0A2020202020202020202020202223386334666134222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(141) := '353733623838220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223663964646461222C0D0A2020202020202020202020202223663262396334222C0D0A202020202020202020202020222365';
wwv_flow_imp.g_varchar2_table(142) := '3539376239222C0D0A2020202020202020202020202223636537386233222C0D0A2020202020202020202020202223616435666164222C0D0A2020202020202020202020202223383334626130222C0D0A20202020202020202020202022233537336238';
wwv_flow_imp.g_varchar2_table(143) := '38220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A202020202253756E736574223A207B0D0A20';
wwv_flow_imp.g_varchar2_table(144) := '202020202020202232223A205B0D0A2020202020202020202020202223663365373962222C0D0A2020202020202020202020202223356335336135220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(145) := '20202223663365373962222C0D0A2020202020202020202020202223656237663836222C0D0A2020202020202020202020202223356335336135220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(146) := '202223663365373962222C0D0A2020202020202020202020202223663861303765222C0D0A2020202020202020202020202223636536363933222C0D0A2020202020202020202020202223356335336135220D0A20202020202020205D2C0D0A20202020';
wwv_flow_imp.g_varchar2_table(147) := '202020202235223A205B0D0A2020202020202020202020202223663365373962222C0D0A2020202020202020202020202223666162323766222C0D0A2020202020202020202020202223656237663836222C0D0A20202020202020202020202022236239';
wwv_flow_imp.g_varchar2_table(148) := '35653961222C0D0A2020202020202020202020202223356335336135220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223663365373962222C0D0A2020202020202020202020202223666162';
wwv_flow_imp.g_varchar2_table(149) := '633832222C0D0A2020202020202020202020202223663539323830222C0D0A2020202020202020202020202223646336663865222C0D0A2020202020202020202020202223616235623965222C0D0A202020202020202020202020222335633533613522';
wwv_flow_imp.g_varchar2_table(150) := '0D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223663365373962222C0D0A2020202020202020202020202223666163343834222C0D0A2020202020202020202020202223663861303765222C';
wwv_flow_imp.g_varchar2_table(151) := '0D0A2020202020202020202020202223656237663836222C0D0A2020202020202020202020202223636536363933222C0D0A2020202020202020202020202223613035396130222C0D0A2020202020202020202020202223356335336135220D0A202020';
wwv_flow_imp.g_varchar2_table(152) := '20202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A20202020224D6167656E7461223A207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(153) := '202232223A205B0D0A2020202020202020202020202223663363626433222C0D0A2020202020202020202020202223366332313637220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A20202020202020202020202022236633';
wwv_flow_imp.g_varchar2_table(154) := '63626433222C0D0A2020202020202020202020202223636136393964222C0D0A2020202020202020202020202223366332313637220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223663363';
wwv_flow_imp.g_varchar2_table(155) := '626433222C0D0A2020202020202020202020202223646438386163222C0D0A2020202020202020202020202223623134643865222C0D0A2020202020202020202020202223366332313637220D0A20202020202020205D2C0D0A20202020202020202235';
wwv_flow_imp.g_varchar2_table(156) := '223A205B0D0A2020202020202020202020202223663363626433222C0D0A2020202020202020202020202223653439386234222C0D0A2020202020202020202020202223636136393964222C0D0A2020202020202020202020202223613234313836222C';
wwv_flow_imp.g_varchar2_table(157) := '0D0A2020202020202020202020202223366332313637220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223663363626433222C0D0A2020202020202020202020202223653761326239222C0D';
wwv_flow_imp.g_varchar2_table(158) := '0A2020202020202020202020202223643637626135222C0D0A2020202020202020202020202223626335383934222C0D0A2020202020202020202020202223393833613831222C0D0A2020202020202020202020202223366332313637220D0A20202020';
wwv_flow_imp.g_varchar2_table(159) := '202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223663363626433222C0D0A2020202020202020202020202223656161396264222C0D0A2020202020202020202020202223646438386163222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(160) := '20202020202020202223636136393964222C0D0A2020202020202020202020202223623134643865222C0D0A2020202020202020202020202223393133353764222C0D0A2020202020202020202020202223366332313637220D0A20202020202020205D';
wwv_flow_imp.g_varchar2_table(161) := '2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A202020202253756E7365744461726B223A207B0D0A20202020202020202232';
wwv_flow_imp.g_varchar2_table(162) := '223A205B0D0A2020202020202020202020202223666364653963222C0D0A2020202020202020202020202223376331643666220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A20202020202020202020202022236663646539';
wwv_flow_imp.g_varchar2_table(163) := '63222C0D0A2020202020202020202020202223653334663666222C0D0A2020202020202020202020202223376331643666220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223666364653963';
wwv_flow_imp.g_varchar2_table(164) := '222C0D0A2020202020202020202020202223663037343665222C0D0A2020202020202020202020202223646333393737222C0D0A2020202020202020202020202223376331643666220D0A20202020202020205D2C0D0A20202020202020202235223A20';
wwv_flow_imp.g_varchar2_table(165) := '5B0D0A2020202020202020202020202223666364653963222C0D0A2020202020202020202020202223663538363730222C0D0A2020202020202020202020202223653334663666222C0D0A2020202020202020202020202223643732643763222C0D0A20';
wwv_flow_imp.g_varchar2_table(166) := '20202020202020202020202223376331643666220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223666364653963222C0D0A2020202020202020202020202223663839383732222C0D0A2020';
wwv_flow_imp.g_varchar2_table(167) := '202020202020202020202223656336363664222C0D0A2020202020202020202020202223646634323733222C0D0A2020202020202020202020202223633532383762222C0D0A2020202020202020202020202223376331643666220D0A20202020202020';
wwv_flow_imp.g_varchar2_table(168) := '205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223666364653963222C0D0A2020202020202020202020202223666161343736222C0D0A2020202020202020202020202223663037343665222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(169) := '20202020202223653334663666222C0D0A2020202020202020202020202223646333393737222C0D0A2020202020202020202020202223623932353761222C0D0A2020202020202020202020202223376331643666220D0A20202020202020205D2C0D0A';
wwv_flow_imp.g_varchar2_table(170) := '20202020202020202274616773223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A202020202261675F53756E736574223A207B0D0A20202020202020202232223A205B';
wwv_flow_imp.g_varchar2_table(171) := '0D0A2020202020202020202020202223346232393931222C0D0A2020202020202020202020202223656464396133220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223346232393931222C0D';
wwv_flow_imp.g_varchar2_table(172) := '0A2020202020202020202020202223656134663838222C0D0A2020202020202020202020202223656464396133220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223346232393931222C0D0A';
wwv_flow_imp.g_varchar2_table(173) := '2020202020202020202020202223633033363964222C0D0A2020202020202020202020202223666137383736222C0D0A2020202020202020202020202223656464396133220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A20';
wwv_flow_imp.g_varchar2_table(174) := '20202020202020202020202223346232393931222C0D0A2020202020202020202020202223613532666132222C0D0A2020202020202020202020202223656134663838222C0D0A2020202020202020202020202223666139303734222C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(175) := '202020202020202223656464396133220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223346232393931222C0D0A2020202020202020202020202223393332646133222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(176) := '2020202020202223643433663936222C0D0A2020202020202020202020202223663736363763222C0D0A2020202020202020202020202223663839663737222C0D0A2020202020202020202020202223656464396133220D0A20202020202020205D2C0D';
wwv_flow_imp.g_varchar2_table(177) := '0A20202020202020202237223A205B0D0A2020202020202020202020202223346232393931222C0D0A2020202020202020202020202223383732636132222C0D0A2020202020202020202020202223633033363964222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(178) := '202223656134663838222C0D0A2020202020202020202020202223666137383736222C0D0A2020202020202020202020202223663661393761222C0D0A2020202020202020202020202223656464396133220D0A20202020202020205D2C0D0A20202020';
wwv_flow_imp.g_varchar2_table(179) := '202020202274616773223A205B0D0A202020202020202020202020226167677265676174696F6E220D0A20202020202020205D0D0A202020207D2C0D0A20202020224272776E596C223A207B0D0A20202020202020202232223A205B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(180) := '2020202020202223656465356366222C0D0A2020202020202020202020202223353431663366220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223656465356366222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(181) := '20202020202223633137363666222C0D0A2020202020202020202020202223353431663366220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223656465356366222C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(182) := '202020202223643339633833222C0D0A2020202020202020202020202223613635343631222C0D0A2020202020202020202020202223353431663366220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(183) := '2020202223656465356366222C0D0A2020202020202020202020202223646161663931222C0D0A2020202020202020202020202223633137363666222C0D0A2020202020202020202020202223393534353561222C0D0A20202020202020202020202022';
wwv_flow_imp.g_varchar2_table(184) := '23353431663366220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223656465356366222C0D0A2020202020202020202020202223646462613962222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(185) := '636438633761222C0D0A2020202020202020202020202223623236313636222C0D0A2020202020202020202020202223386133633536222C0D0A2020202020202020202020202223353431663366220D0A20202020202020205D2C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(186) := '202237223A205B0D0A2020202020202020202020202223656465356366222C0D0A2020202020202020202020202223653063326132222C0D0A2020202020202020202020202223643339633833222C0D0A20202020202020202020202022236331373636';
wwv_flow_imp.g_varchar2_table(187) := '66222C0D0A2020202020202020202020202223613635343631222C0D0A2020202020202020202020202223383133373533222C0D0A2020202020202020202020202223353431663366220D0A20202020202020205D2C0D0A202020202020202022746167';
wwv_flow_imp.g_varchar2_table(188) := '73223A205B0D0A202020202020202020202020227175616E7469746174697665220D0A20202020202020205D0D0A202020207D2C0D0A202020202241726D79526F7365223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(189) := '202223393239623466222C0D0A2020202020202020202020202223646238313935220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223613361643632222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(190) := '2223666466626534222C0D0A2020202020202020202020202223646639316133220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223393239623466222C0D0A20202020202020202020202022';
wwv_flow_imp.g_varchar2_table(191) := '23643964626166222C0D0A2020202020202020202020202223663364316361222C0D0A2020202020202020202020202223646238313935220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(192) := '383739303433222C0D0A2020202020202020202020202223633163363863222C0D0A2020202020202020202020202223666466626534222C0D0A2020202020202020202020202223656262346238222C0D0A202020202020202020202020222364383735';
wwv_flow_imp.g_varchar2_table(193) := '3862220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223376638383362222C0D0A2020202020202020202020202223623062383734222C0D0A20202020202020202020202022236533653462';
wwv_flow_imp.g_varchar2_table(194) := '65222C0D0A2020202020202020202020202223663664646431222C0D0A2020202020202020202020202223653461306163222C0D0A2020202020202020202020202223643636643835220D0A20202020202020205D2C0D0A20202020202020202237223A';
wwv_flow_imp.g_varchar2_table(195) := '205B0D0A2020202020202020202020202223373938323334222C0D0A2020202020202020202020202223613361643632222C0D0A2020202020202020202020202223643064336132222C0D0A2020202020202020202020202223666466626534222C0D0A';
wwv_flow_imp.g_varchar2_table(196) := '2020202020202020202020202223663063366333222C0D0A2020202020202020202020202223646639316133222C0D0A2020202020202020202020202223643436373830220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B';
wwv_flow_imp.g_varchar2_table(197) := '0D0A20202020202020202020202022646976657267696E67220D0A20202020202020205D0D0A202020207D2C0D0A202020202246616C6C223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223336435393431222C0D';
wwv_flow_imp.g_varchar2_table(198) := '0A2020202020202020202020202223636135363263220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223336435393431222C0D0A2020202020202020202020202223663665646264222C0D0A';
wwv_flow_imp.g_varchar2_table(199) := '2020202020202020202020202223636135363263220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223336435393431222C0D0A2020202020202020202020202223623562393931222C0D0A20';
wwv_flow_imp.g_varchar2_table(200) := '20202020202020202020202223656462623861222C0D0A2020202020202020202020202223636135363263220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223336435393431222C0D0A2020';
wwv_flow_imp.g_varchar2_table(201) := '202020202020202020202223393661303763222C0D0A2020202020202020202020202223663665646264222C0D0A2020202020202020202020202223653661323732222C0D0A2020202020202020202020202223636135363263220D0A20202020202020';
wwv_flow_imp.g_varchar2_table(202) := '205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223336435393431222C0D0A2020202020202020202020202223383339313730222C0D0A2020202020202020202020202223636563656132222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(203) := '20202020202223663163663965222C0D0A2020202020202020202020202223653139343634222C0D0A2020202020202020202020202223636135363263220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(204) := '202020202223336435393431222C0D0A2020202020202020202020202223373738383638222C0D0A2020202020202020202020202223623562393931222C0D0A2020202020202020202020202223663665646264222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(205) := '2223656462623861222C0D0A2020202020202020202020202223646538613561222C0D0A2020202020202020202020202223636135363263220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(206) := '202022646976657267696E67220D0A20202020202020205D0D0A202020207D2C0D0A2020202022476579736572223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223303038303830222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(207) := '2020202223636135363263220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223303038303830222C0D0A2020202020202020202020202223663665646264222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(208) := '20202223636135363263220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223303038303830222C0D0A2020202020202020202020202223623463386138222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(209) := '202223656462623861222C0D0A2020202020202020202020202223636135363263220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223303038303830222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(210) := '2223393262363965222C0D0A2020202020202020202020202223663665646264222C0D0A2020202020202020202020202223653661323732222C0D0A2020202020202020202020202223636135363263220D0A20202020202020205D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(211) := '2020202236223A205B0D0A2020202020202020202020202223303038303830222C0D0A2020202020202020202020202223376561623938222C0D0A2020202020202020202020202223636564376231222C0D0A2020202020202020202020202223663163';
wwv_flow_imp.g_varchar2_table(212) := '663965222C0D0A2020202020202020202020202223653139343634222C0D0A2020202020202020202020202223636135363263220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A202020202020202020202020222330303830';
wwv_flow_imp.g_varchar2_table(213) := '3830222C0D0A2020202020202020202020202223373061343934222C0D0A2020202020202020202020202223623463386138222C0D0A2020202020202020202020202223663665646264222C0D0A2020202020202020202020202223656462623861222C';
wwv_flow_imp.g_varchar2_table(214) := '0D0A2020202020202020202020202223646538613561222C0D0A2020202020202020202020202223636135363263220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A2020202020202020202020202264697665726769';
wwv_flow_imp.g_varchar2_table(215) := '6E67220D0A20202020202020205D0D0A202020207D2C0D0A202020202254656D7073223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223303039333932222C0D0A2020202020202020202020202223636635393765';
wwv_flow_imp.g_varchar2_table(216) := '220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223303039333932222C0D0A2020202020202020202020202223653965323963222C0D0A202020202020202020202020222363663539376522';
wwv_flow_imp.g_varchar2_table(217) := '0D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223303039333932222C0D0A2020202020202020202020202223396363623836222C0D0A2020202020202020202020202223656562343739222C';
wwv_flow_imp.g_varchar2_table(218) := '0D0A2020202020202020202020202223636635393765220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223303039333932222C0D0A2020202020202020202020202223373162653833222C0D';
wwv_flow_imp.g_varchar2_table(219) := '0A2020202020202020202020202223653965323963222C0D0A2020202020202020202020202223656439633732222C0D0A2020202020202020202020202223636635393765220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A';
wwv_flow_imp.g_varchar2_table(220) := '2020202020202020202020202223303039333932222C0D0A2020202020202020202020202223353262363834222C0D0A2020202020202020202020202223626364343863222C0D0A2020202020202020202020202223656463373833222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(221) := '20202020202020202223656238643731222C0D0A2020202020202020202020202223636635393765220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223303039333932222C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(222) := '202020202020202223333962313835222C0D0A2020202020202020202020202223396363623836222C0D0A2020202020202020202020202223653965323963222C0D0A2020202020202020202020202223656562343739222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(223) := '2020202223653838343731222C0D0A2020202020202020202020202223636635393765220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A20202020202020202020202022646976657267696E67220D0A202020202020';
wwv_flow_imp.g_varchar2_table(224) := '20205D0D0A202020207D2C0D0A20202020225465616C526F7365223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223303039333932222C0D0A2020202020202020202020202223643035383765220D0A2020202020';
wwv_flow_imp.g_varchar2_table(225) := '2020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223303039333932222C0D0A2020202020202020202020202223663165616338222C0D0A2020202020202020202020202223643035383765220D0A202020202020';
wwv_flow_imp.g_varchar2_table(226) := '20205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223303039333932222C0D0A2020202020202020202020202223393162386161222C0D0A2020202020202020202020202223663165616338222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(227) := '2020202020202223646661306130222C0D0A2020202020202020202020202223643035383765220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223303039333932222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(228) := '20202020202223393162386161222C0D0A2020202020202020202020202223663165616338222C0D0A2020202020202020202020202223646661306130222C0D0A2020202020202020202020202223643035383765220D0A20202020202020205D2C0D0A';
wwv_flow_imp.g_varchar2_table(229) := '20202020202020202236223A205B0D0A2020202020202020202020202223303039333932222C0D0A2020202020202020202020202223373261616131222C0D0A2020202020202020202020202223623163376233222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(230) := '2223653562396164222C0D0A2020202020202020202020202223643938393934222C0D0A2020202020202020202020202223643035383765220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A20202020202020202020202022';
wwv_flow_imp.g_varchar2_table(231) := '23303039333932222C0D0A2020202020202020202020202223373261616131222C0D0A2020202020202020202020202223623163376233222C0D0A2020202020202020202020202223663165616338222C0D0A2020202020202020202020202223653562';
wwv_flow_imp.g_varchar2_table(232) := '396164222C0D0A2020202020202020202020202223643938393934222C0D0A2020202020202020202020202223643035383765220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020226469';
wwv_flow_imp.g_varchar2_table(233) := '76657267696E67220D0A20202020202020205D0D0A202020207D2C0D0A202020202254726F706963223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223303039423945222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(234) := '433735444142220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223303039423945222C0D0A2020202020202020202020202223463146314631222C0D0A202020202020202020202020222343';
wwv_flow_imp.g_varchar2_table(235) := '3735444142220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223303039423945222C0D0A2020202020202020202020202223413744334434222C0D0A20202020202020202020202022234534';
wwv_flow_imp.g_varchar2_table(236) := '43314439222C0D0A2020202020202020202020202223433735444142220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223303039423945222C0D0A2020202020202020202020202223374343';
wwv_flow_imp.g_varchar2_table(237) := '354336222C0D0A2020202020202020202020202223463146314631222C0D0A2020202020202020202020202223444441394344222C0D0A2020202020202020202020202223433735444142220D0A20202020202020205D2C0D0A20202020202020202236';
wwv_flow_imp.g_varchar2_table(238) := '223A205B0D0A2020202020202020202020202223303039423945222C0D0A2020202020202020202020202223354442434245222C0D0A2020202020202020202020202223433644464446222C0D0A2020202020202020202020202223453944344532222C';
wwv_flow_imp.g_varchar2_table(239) := '0D0A2020202020202020202020202223443939424336222C0D0A2020202020202020202020202223433735444142220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223303039423945222C0D';
wwv_flow_imp.g_varchar2_table(240) := '0A2020202020202020202020202223343242374239222C0D0A2020202020202020202020202223413744334434222C0D0A2020202020202020202020202223463146314631222C0D0A2020202020202020202020202223453443314439222C0D0A202020';
wwv_flow_imp.g_varchar2_table(241) := '2020202020202020202223443639314331222C0D0A2020202020202020202020202223433735444142220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A20202020202020202020202022646976657267696E67220D0A';
wwv_flow_imp.g_varchar2_table(242) := '20202020202020205D0D0A202020207D2C0D0A20202020224561727468223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223413136393238222C0D0A2020202020202020202020202223323838376131220D0A2020';
wwv_flow_imp.g_varchar2_table(243) := '2020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223413136393238222C0D0A2020202020202020202020202223656465616332222C0D0A2020202020202020202020202223323838376131220D0A202020';
wwv_flow_imp.g_varchar2_table(244) := '20202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223413136393238222C0D0A2020202020202020202020202223643662643864222C0D0A2020202020202020202020202223623563386238222C0D0A202020';
wwv_flow_imp.g_varchar2_table(245) := '2020202020202020202223323838376131220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223413136393238222C0D0A2020202020202020202020202223636161383733222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(246) := '20202020202020202223656465616332222C0D0A2020202020202020202020202223393862376232222C0D0A2020202020202020202020202223323838376131220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(247) := '202020202020202223413136393238222C0D0A2020202020202020202020202223633239623634222C0D0A2020202020202020202020202223653063666132222C0D0A2020202020202020202020202223636264356263222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(248) := '2020202223383561646166222C0D0A2020202020202020202020202223323838376131220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223413136393238222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(249) := '20202223626439323561222C0D0A2020202020202020202020202223643662643864222C0D0A2020202020202020202020202223656465616332222C0D0A2020202020202020202020202223623563386238222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(250) := '373961376163222C0D0A2020202020202020202020202223323838376131220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A20202020202020202020202022646976657267696E67220D0A20202020202020205D0D0A';
wwv_flow_imp.g_varchar2_table(251) := '202020207D2C0D0A2020202022416E7469717565223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223383535433735222C0D0A2020202020202020202020202223443941463642222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(252) := '20202223374337433743220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223383535433735222C0D0A2020202020202020202020202223443941463642222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(253) := '202223414636343538222C0D0A2020202020202020202020202223374337433743220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223383535433735222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(254) := '2223443941463642222C0D0A2020202020202020202020202223414636343538222C0D0A2020202020202020202020202223373336463443222C0D0A2020202020202020202020202223374337433743220D0A20202020202020205D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(255) := '2020202235223A205B0D0A2020202020202020202020202223383535433735222C0D0A2020202020202020202020202223443941463642222C0D0A2020202020202020202020202223414636343538222C0D0A2020202020202020202020202223373336';
wwv_flow_imp.g_varchar2_table(256) := '463443222C0D0A2020202020202020202020202223353236413833222C0D0A2020202020202020202020202223374337433743220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A202020202020202020202020222338353543';
wwv_flow_imp.g_varchar2_table(257) := '3735222C0D0A2020202020202020202020202223443941463642222C0D0A2020202020202020202020202223414636343538222C0D0A2020202020202020202020202223373336463443222C0D0A2020202020202020202020202223353236413833222C';
wwv_flow_imp.g_varchar2_table(258) := '0D0A2020202020202020202020202223363235333737222C0D0A2020202020202020202020202223374337433743220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223383535433735222C0D';
wwv_flow_imp.g_varchar2_table(259) := '0A2020202020202020202020202223443941463642222C0D0A2020202020202020202020202223414636343538222C0D0A2020202020202020202020202223373336463443222C0D0A2020202020202020202020202223353236413833222C0D0A202020';
wwv_flow_imp.g_varchar2_table(260) := '2020202020202020202223363235333737222C0D0A2020202020202020202020202223363838353543222C0D0A2020202020202020202020202223374337433743220D0A20202020202020205D2C0D0A20202020202020202238223A205B0D0A20202020';
wwv_flow_imp.g_varchar2_table(261) := '20202020202020202223383535433735222C0D0A2020202020202020202020202223443941463642222C0D0A2020202020202020202020202223414636343538222C0D0A2020202020202020202020202223373336463443222C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(262) := '202020202223353236413833222C0D0A2020202020202020202020202223363235333737222C0D0A2020202020202020202020202223363838353543222C0D0A2020202020202020202020202223394339433545222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(263) := '2223374337433743220D0A20202020202020205D2C0D0A20202020202020202239223A205B0D0A2020202020202020202020202223383535433735222C0D0A2020202020202020202020202223443941463642222C0D0A20202020202020202020202022';
wwv_flow_imp.g_varchar2_table(264) := '23414636343538222C0D0A2020202020202020202020202223373336463443222C0D0A2020202020202020202020202223353236413833222C0D0A2020202020202020202020202223363235333737222C0D0A2020202020202020202020202223363838';
wwv_flow_imp.g_varchar2_table(265) := '353543222C0D0A2020202020202020202020202223394339433545222C0D0A2020202020202020202020202223413036313737222C0D0A2020202020202020202020202223374337433743220D0A20202020202020205D2C0D0A20202020202020202231';
wwv_flow_imp.g_varchar2_table(266) := '30223A205B0D0A2020202020202020202020202223383535433735222C0D0A2020202020202020202020202223443941463642222C0D0A2020202020202020202020202223414636343538222C0D0A202020202020202020202020222337333646344322';
wwv_flow_imp.g_varchar2_table(267) := '2C0D0A2020202020202020202020202223353236413833222C0D0A2020202020202020202020202223363235333737222C0D0A2020202020202020202020202223363838353543222C0D0A2020202020202020202020202223394339433545222C0D0A20';
wwv_flow_imp.g_varchar2_table(268) := '20202020202020202020202223413036313737222C0D0A2020202020202020202020202223384337383544222C0D0A2020202020202020202020202223374337433743220D0A20202020202020205D2C0D0A2020202020202020223131223A205B0D0A20';
wwv_flow_imp.g_varchar2_table(269) := '20202020202020202020202223383535433735222C0D0A2020202020202020202020202223443941463642222C0D0A2020202020202020202020202223414636343538222C0D0A2020202020202020202020202223373336463443222C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(270) := '202020202020202223353236413833222C0D0A2020202020202020202020202223363235333737222C0D0A2020202020202020202020202223363838353543222C0D0A2020202020202020202020202223394339433545222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(271) := '2020202223413036313737222C0D0A2020202020202020202020202223384337383544222C0D0A2020202020202020202020202223343637333738222C0D0A2020202020202020202020202223374337433743220D0A20202020202020205D2C0D0A2020';
wwv_flow_imp.g_varchar2_table(272) := '2020202020202274616773223A205B0D0A202020202020202020202020227175616C69746174697665220D0A20202020202020205D0D0A202020207D2C0D0A2020202022426F6C64223A207B0D0A20202020202020202232223A205B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(273) := '2020202020202223374633433844222C0D0A2020202020202020202020202223313141353739222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(274) := '20202020202223374633433844222C0D0A2020202020202020202020202223313141353739222C0D0A2020202020202020202020202223333936394143222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A';
wwv_flow_imp.g_varchar2_table(275) := '20202020202020202234223A205B0D0A2020202020202020202020202223374633433844222C0D0A2020202020202020202020202223313141353739222C0D0A2020202020202020202020202223333936394143222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(276) := '2223463242373031222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223374633433844222C0D0A20202020202020202020202022';
wwv_flow_imp.g_varchar2_table(277) := '23313141353739222C0D0A2020202020202020202020202223333936394143222C0D0A2020202020202020202020202223463242373031222C0D0A2020202020202020202020202223453733463734222C0D0A2020202020202020202020202223413541';
wwv_flow_imp.g_varchar2_table(278) := '413939220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223374633433844222C0D0A2020202020202020202020202223313141353739222C0D0A202020202020202020202020222333393639';
wwv_flow_imp.g_varchar2_table(279) := '4143222C0D0A2020202020202020202020202223463242373031222C0D0A2020202020202020202020202223453733463734222C0D0A2020202020202020202020202223383042413541222C0D0A2020202020202020202020202223413541413939220D';
wwv_flow_imp.g_varchar2_table(280) := '0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223374633433844222C0D0A2020202020202020202020202223313141353739222C0D0A2020202020202020202020202223333936394143222C0D';
wwv_flow_imp.g_varchar2_table(281) := '0A2020202020202020202020202223463242373031222C0D0A2020202020202020202020202223453733463734222C0D0A2020202020202020202020202223383042413541222C0D0A2020202020202020202020202223453638333130222C0D0A202020';
wwv_flow_imp.g_varchar2_table(282) := '2020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202238223A205B0D0A2020202020202020202020202223374633433844222C0D0A2020202020202020202020202223313141353739222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(283) := '20202020202020202223333936394143222C0D0A2020202020202020202020202223463242373031222C0D0A2020202020202020202020202223453733463734222C0D0A2020202020202020202020202223383042413541222C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(284) := '202020202223453638333130222C0D0A2020202020202020202020202223303038363935222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202239223A205B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(285) := '2020202223374633433844222C0D0A2020202020202020202020202223313141353739222C0D0A2020202020202020202020202223333936394143222C0D0A2020202020202020202020202223463242373031222C0D0A20202020202020202020202022';
wwv_flow_imp.g_varchar2_table(286) := '23453733463734222C0D0A2020202020202020202020202223383042413541222C0D0A2020202020202020202020202223453638333130222C0D0A2020202020202020202020202223303038363935222C0D0A2020202020202020202020202223434631';
wwv_flow_imp.g_varchar2_table(287) := '433930222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A2020202020202020223130223A205B0D0A2020202020202020202020202223374633433844222C0D0A2020202020202020202020202223313141';
wwv_flow_imp.g_varchar2_table(288) := '353739222C0D0A2020202020202020202020202223333936394143222C0D0A2020202020202020202020202223463242373031222C0D0A2020202020202020202020202223453733463734222C0D0A202020202020202020202020222338304241354122';
wwv_flow_imp.g_varchar2_table(289) := '2C0D0A2020202020202020202020202223453638333130222C0D0A2020202020202020202020202223303038363935222C0D0A2020202020202020202020202223434631433930222C0D0A2020202020202020202020202223663937623732222C0D0A20';
wwv_flow_imp.g_varchar2_table(290) := '20202020202020202020202223413541413939220D0A20202020202020205D2C0D0A2020202020202020223131223A205B0D0A2020202020202020202020202223374633433844222C0D0A2020202020202020202020202223313141353739222C0D0A20';
wwv_flow_imp.g_varchar2_table(291) := '20202020202020202020202223333936394143222C0D0A2020202020202020202020202223463242373031222C0D0A2020202020202020202020202223453733463734222C0D0A2020202020202020202020202223383042413541222C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(292) := '202020202020202223453638333130222C0D0A2020202020202020202020202223303038363935222C0D0A2020202020202020202020202223434631433930222C0D0A2020202020202020202020202223663937623732222C0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(293) := '2020202223346234623866222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616C69746174697665220D0A20202020';
wwv_flow_imp.g_varchar2_table(294) := '202020205D0D0A202020207D2C0D0A202020202250617374656C223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223363643354343222C0D0A2020202020202020202020202223463643463731222C0D0A20202020';
wwv_flow_imp.g_varchar2_table(295) := '20202020202020202223423342334233220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223363643354343222C0D0A2020202020202020202020202223463643463731222C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(296) := '202020202020202223463839433734222C0D0A2020202020202020202020202223423342334233220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223363643354343222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(297) := '2020202020202223463643463731222C0D0A2020202020202020202020202223463839433734222C0D0A2020202020202020202020202223444342304632222C0D0A2020202020202020202020202223423342334233220D0A20202020202020205D2C0D';
wwv_flow_imp.g_varchar2_table(298) := '0A20202020202020202235223A205B0D0A2020202020202020202020202223363643354343222C0D0A2020202020202020202020202223463643463731222C0D0A2020202020202020202020202223463839433734222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(299) := '202223444342304632222C0D0A2020202020202020202020202223383743353546222C0D0A2020202020202020202020202223423342334233220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(300) := '2223363643354343222C0D0A2020202020202020202020202223463643463731222C0D0A2020202020202020202020202223463839433734222C0D0A2020202020202020202020202223444342304632222C0D0A20202020202020202020202022233837';
wwv_flow_imp.g_varchar2_table(301) := '43353546222C0D0A2020202020202020202020202223394542394633222C0D0A2020202020202020202020202223423342334233220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223363643';
wwv_flow_imp.g_varchar2_table(302) := '354343222C0D0A2020202020202020202020202223463643463731222C0D0A2020202020202020202020202223463839433734222C0D0A2020202020202020202020202223444342304632222C0D0A202020202020202020202020222338374335354622';
wwv_flow_imp.g_varchar2_table(303) := '2C0D0A2020202020202020202020202223394542394633222C0D0A2020202020202020202020202223464538384231222C0D0A2020202020202020202020202223423342334233220D0A20202020202020205D2C0D0A20202020202020202238223A205B';
wwv_flow_imp.g_varchar2_table(304) := '0D0A2020202020202020202020202223363643354343222C0D0A2020202020202020202020202223463643463731222C0D0A2020202020202020202020202223463839433734222C0D0A2020202020202020202020202223444342304632222C0D0A2020';
wwv_flow_imp.g_varchar2_table(305) := '202020202020202020202223383743353546222C0D0A2020202020202020202020202223394542394633222C0D0A2020202020202020202020202223464538384231222C0D0A2020202020202020202020202223433944423734222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(306) := '2020202020202223423342334233220D0A20202020202020205D2C0D0A20202020202020202239223A205B0D0A2020202020202020202020202223363643354343222C0D0A2020202020202020202020202223463643463731222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(307) := '20202020202223463839433734222C0D0A2020202020202020202020202223444342304632222C0D0A2020202020202020202020202223383743353546222C0D0A2020202020202020202020202223394542394633222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(308) := '202223464538384231222C0D0A2020202020202020202020202223433944423734222C0D0A2020202020202020202020202223384245304134222C0D0A2020202020202020202020202223423342334233220D0A20202020202020205D2C0D0A20202020';
wwv_flow_imp.g_varchar2_table(309) := '20202020223130223A205B0D0A2020202020202020202020202223363643354343222C0D0A2020202020202020202020202223463643463731222C0D0A2020202020202020202020202223463839433734222C0D0A202020202020202020202020222344';
wwv_flow_imp.g_varchar2_table(310) := '4342304632222C0D0A2020202020202020202020202223383743353546222C0D0A2020202020202020202020202223394542394633222C0D0A2020202020202020202020202223464538384231222C0D0A20202020202020202020202022234339444237';
wwv_flow_imp.g_varchar2_table(311) := '34222C0D0A2020202020202020202020202223384245304134222C0D0A2020202020202020202020202223423439374537222C0D0A2020202020202020202020202223423342334233220D0A20202020202020205D2C0D0A202020202020202022313122';
wwv_flow_imp.g_varchar2_table(312) := '3A205B0D0A2020202020202020202020202223363643354343222C0D0A2020202020202020202020202223463643463731222C0D0A2020202020202020202020202223463839433734222C0D0A2020202020202020202020202223444342304632222C0D';
wwv_flow_imp.g_varchar2_table(313) := '0A2020202020202020202020202223383743353546222C0D0A2020202020202020202020202223394542394633222C0D0A2020202020202020202020202223464538384231222C0D0A2020202020202020202020202223433944423734222C0D0A202020';
wwv_flow_imp.g_varchar2_table(314) := '2020202020202020202223384245304134222C0D0A2020202020202020202020202223423439374537222C0D0A2020202020202020202020202223443342343834222C0D0A2020202020202020202020202223423342334233220D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(315) := '5D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616C69746174697665220D0A20202020202020205D0D0A202020207D2C0D0A2020202022507269736D223A207B0D0A20202020202020202232223A205B0D';
wwv_flow_imp.g_varchar2_table(316) := '0A2020202020202020202020202223354634363930222C0D0A2020202020202020202020202223314436393936222C0D0A2020202020202020202020202223363636363636220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A';
wwv_flow_imp.g_varchar2_table(317) := '2020202020202020202020202223354634363930222C0D0A2020202020202020202020202223314436393936222C0D0A2020202020202020202020202223333841364135222C0D0A2020202020202020202020202223363636363636220D0A2020202020';
wwv_flow_imp.g_varchar2_table(318) := '2020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223354634363930222C0D0A2020202020202020202020202223314436393936222C0D0A2020202020202020202020202223333841364135222C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(319) := '202020202020202223304638353534222C0D0A2020202020202020202020202223363636363636220D0A20202020202020205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223354634363930222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(320) := '2020202020202223314436393936222C0D0A2020202020202020202020202223333841364135222C0D0A2020202020202020202020202223304638353534222C0D0A2020202020202020202020202223373341463438222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(321) := '20202223363636363636220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223354634363930222C0D0A2020202020202020202020202223314436393936222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(322) := '202223333841364135222C0D0A2020202020202020202020202223304638353534222C0D0A2020202020202020202020202223373341463438222C0D0A2020202020202020202020202223454441443038222C0D0A202020202020202020202020222336';
wwv_flow_imp.g_varchar2_table(323) := '3636363636220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223354634363930222C0D0A2020202020202020202020202223314436393936222C0D0A20202020202020202020202022233338';
wwv_flow_imp.g_varchar2_table(324) := '41364135222C0D0A2020202020202020202020202223304638353534222C0D0A2020202020202020202020202223373341463438222C0D0A2020202020202020202020202223454441443038222C0D0A2020202020202020202020202223453137433035';
wwv_flow_imp.g_varchar2_table(325) := '222C0D0A2020202020202020202020202223363636363636220D0A20202020202020205D2C0D0A20202020202020202238223A205B0D0A2020202020202020202020202223354634363930222C0D0A202020202020202020202020222331443639393622';
wwv_flow_imp.g_varchar2_table(326) := '2C0D0A2020202020202020202020202223333841364135222C0D0A2020202020202020202020202223304638353534222C0D0A2020202020202020202020202223373341463438222C0D0A2020202020202020202020202223454441443038222C0D0A20';
wwv_flow_imp.g_varchar2_table(327) := '20202020202020202020202223453137433035222C0D0A2020202020202020202020202223434335303345222C0D0A2020202020202020202020202223363636363636220D0A20202020202020205D2C0D0A20202020202020202239223A205B0D0A2020';
wwv_flow_imp.g_varchar2_table(328) := '202020202020202020202223354634363930222C0D0A2020202020202020202020202223314436393936222C0D0A2020202020202020202020202223333841364135222C0D0A2020202020202020202020202223304638353534222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(329) := '2020202020202223373341463438222C0D0A2020202020202020202020202223454441443038222C0D0A2020202020202020202020202223453137433035222C0D0A2020202020202020202020202223434335303345222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(330) := '20202223393433343645222C0D0A2020202020202020202020202223363636363636220D0A20202020202020205D2C0D0A2020202020202020223130223A205B0D0A2020202020202020202020202223354634363930222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(331) := '20202223314436393936222C0D0A2020202020202020202020202223333841364135222C0D0A2020202020202020202020202223304638353534222C0D0A2020202020202020202020202223373341463438222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(332) := '454441443038222C0D0A2020202020202020202020202223453137433035222C0D0A2020202020202020202020202223434335303345222C0D0A2020202020202020202020202223393433343645222C0D0A202020202020202020202020222336463430';
wwv_flow_imp.g_varchar2_table(333) := '3730222C0D0A2020202020202020202020202223363636363636220D0A20202020202020205D2C0D0A2020202020202020223131223A205B0D0A2020202020202020202020202223354634363930222C0D0A202020202020202020202020222331443639';
wwv_flow_imp.g_varchar2_table(334) := '3936222C0D0A2020202020202020202020202223333841364135222C0D0A2020202020202020202020202223304638353534222C0D0A2020202020202020202020202223373341463438222C0D0A2020202020202020202020202223454441443038222C';
wwv_flow_imp.g_varchar2_table(335) := '0D0A2020202020202020202020202223453137433035222C0D0A2020202020202020202020202223434335303345222C0D0A2020202020202020202020202223393433343645222C0D0A2020202020202020202020202223364634303730222C0D0A2020';
wwv_flow_imp.g_varchar2_table(336) := '202020202020202020202223393934453935222C0D0A2020202020202020202020202223363636363636220D0A20202020202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616C69746174697665';
wwv_flow_imp.g_varchar2_table(337) := '220D0A20202020202020205D0D0A202020207D2C0D0A202020202253616665223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223383843434545222C0D0A2020202020202020202020202223434336363737222C0D';
wwv_flow_imp.g_varchar2_table(338) := '0A2020202020202020202020202223383838383838220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223383843434545222C0D0A2020202020202020202020202223434336363737222C0D0A';
wwv_flow_imp.g_varchar2_table(339) := '2020202020202020202020202223444443433737222C0D0A2020202020202020202020202223383838383838220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223383843434545222C0D0A20';
wwv_flow_imp.g_varchar2_table(340) := '20202020202020202020202223434336363737222C0D0A2020202020202020202020202223444443433737222C0D0A2020202020202020202020202223313137373333222C0D0A2020202020202020202020202223383838383838220D0A202020202020';
wwv_flow_imp.g_varchar2_table(341) := '20205D2C0D0A20202020202020202235223A205B0D0A2020202020202020202020202223383843434545222C0D0A2020202020202020202020202223434336363737222C0D0A2020202020202020202020202223444443433737222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(342) := '2020202020202223313137373333222C0D0A2020202020202020202020202223333332323838222C0D0A2020202020202020202020202223383838383838220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(343) := '20202020202223383843434545222C0D0A2020202020202020202020202223434336363737222C0D0A2020202020202020202020202223444443433737222C0D0A2020202020202020202020202223313137373333222C0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(344) := '202223333332323838222C0D0A2020202020202020202020202223414134343939222C0D0A2020202020202020202020202223383838383838220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(345) := '2223383843434545222C0D0A2020202020202020202020202223434336363737222C0D0A2020202020202020202020202223444443433737222C0D0A2020202020202020202020202223313137373333222C0D0A20202020202020202020202022233333';
wwv_flow_imp.g_varchar2_table(346) := '32323838222C0D0A2020202020202020202020202223414134343939222C0D0A2020202020202020202020202223343441413939222C0D0A2020202020202020202020202223383838383838220D0A20202020202020205D2C0D0A202020202020202022';
wwv_flow_imp.g_varchar2_table(347) := '38223A205B0D0A2020202020202020202020202223383843434545222C0D0A2020202020202020202020202223434336363737222C0D0A2020202020202020202020202223444443433737222C0D0A202020202020202020202020222331313737333322';
wwv_flow_imp.g_varchar2_table(348) := '2C0D0A2020202020202020202020202223333332323838222C0D0A2020202020202020202020202223414134343939222C0D0A2020202020202020202020202223343441413939222C0D0A2020202020202020202020202223393939393333222C0D0A20';
wwv_flow_imp.g_varchar2_table(349) := '20202020202020202020202223383838383838220D0A20202020202020205D2C0D0A20202020202020202239223A205B0D0A2020202020202020202020202223383843434545222C0D0A2020202020202020202020202223434336363737222C0D0A2020';
wwv_flow_imp.g_varchar2_table(350) := '202020202020202020202223444443433737222C0D0A2020202020202020202020202223313137373333222C0D0A2020202020202020202020202223333332323838222C0D0A2020202020202020202020202223414134343939222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(351) := '2020202020202223343441413939222C0D0A2020202020202020202020202223393939393333222C0D0A2020202020202020202020202223383832323535222C0D0A2020202020202020202020202223383838383838220D0A20202020202020205D2C0D';
wwv_flow_imp.g_varchar2_table(352) := '0A2020202020202020223130223A205B0D0A2020202020202020202020202223383843434545222C0D0A2020202020202020202020202223434336363737222C0D0A2020202020202020202020202223444443433737222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(353) := '20202223313137373333222C0D0A2020202020202020202020202223333332323838222C0D0A2020202020202020202020202223414134343939222C0D0A2020202020202020202020202223343441413939222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(354) := '393939393333222C0D0A2020202020202020202020202223383832323535222C0D0A2020202020202020202020202223363631313030222C0D0A2020202020202020202020202223383838383838220D0A20202020202020205D2C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(355) := '20223131223A205B0D0A2020202020202020202020202223383843434545222C0D0A2020202020202020202020202223434336363737222C0D0A2020202020202020202020202223444443433737222C0D0A202020202020202020202020222331313737';
wwv_flow_imp.g_varchar2_table(356) := '3333222C0D0A2020202020202020202020202223333332323838222C0D0A2020202020202020202020202223414134343939222C0D0A2020202020202020202020202223343441413939222C0D0A2020202020202020202020202223393939393333222C';
wwv_flow_imp.g_varchar2_table(357) := '0D0A2020202020202020202020202223383832323535222C0D0A2020202020202020202020202223363631313030222C0D0A2020202020202020202020202223363639394343222C0D0A2020202020202020202020202223383838383838220D0A202020';
wwv_flow_imp.g_varchar2_table(358) := '20202020205D2C0D0A20202020202020202274616773223A205B0D0A202020202020202020202020227175616C69746174697665222C0D0A20202020202020202020202022636F6C6F72626C696E64220D0A20202020202020205D0D0A202020207D2C0D';
wwv_flow_imp.g_varchar2_table(359) := '0A20202020225669766964223A207B0D0A20202020202020202232223A205B0D0A2020202020202020202020202223453538363036222C0D0A2020202020202020202020202223354436394231222C0D0A20202020202020202020202022234135414139';
wwv_flow_imp.g_varchar2_table(360) := '39220D0A20202020202020205D2C0D0A20202020202020202233223A205B0D0A2020202020202020202020202223453538363036222C0D0A2020202020202020202020202223354436394231222C0D0A2020202020202020202020202223353242434133';
wwv_flow_imp.g_varchar2_table(361) := '222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202234223A205B0D0A2020202020202020202020202223453538363036222C0D0A202020202020202020202020222335443639423122';
wwv_flow_imp.g_varchar2_table(362) := '2C0D0A2020202020202020202020202223353242434133222C0D0A2020202020202020202020202223393943393435222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202235223A205B';
wwv_flow_imp.g_varchar2_table(363) := '0D0A2020202020202020202020202223453538363036222C0D0A2020202020202020202020202223354436394231222C0D0A2020202020202020202020202223353242434133222C0D0A2020202020202020202020202223393943393435222C0D0A2020';
wwv_flow_imp.g_varchar2_table(364) := '202020202020202020202223434336314230222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202236223A205B0D0A2020202020202020202020202223453538363036222C0D0A202020';
wwv_flow_imp.g_varchar2_table(365) := '2020202020202020202223354436394231222C0D0A2020202020202020202020202223353242434133222C0D0A2020202020202020202020202223393943393435222C0D0A2020202020202020202020202223434336314230222C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(366) := '20202020202223323437393643222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202237223A205B0D0A2020202020202020202020202223453538363036222C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(367) := '202020202223354436394231222C0D0A2020202020202020202020202223353242434133222C0D0A2020202020202020202020202223393943393435222C0D0A2020202020202020202020202223434336314230222C0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(368) := '2223323437393643222C0D0A2020202020202020202020202223444141353142222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A20202020202020202238223A205B0D0A20202020202020202020202022';
wwv_flow_imp.g_varchar2_table(369) := '23453538363036222C0D0A2020202020202020202020202223354436394231222C0D0A2020202020202020202020202223353242434133222C0D0A2020202020202020202020202223393943393435222C0D0A2020202020202020202020202223434336';
wwv_flow_imp.g_varchar2_table(370) := '314230222C0D0A2020202020202020202020202223323437393643222C0D0A2020202020202020202020202223444141353142222C0D0A2020202020202020202020202223324638414334222C0D0A202020202020202020202020222341354141393922';
wwv_flow_imp.g_varchar2_table(371) := '0D0A20202020202020205D2C0D0A20202020202020202239223A205B0D0A2020202020202020202020202223453538363036222C0D0A2020202020202020202020202223354436394231222C0D0A2020202020202020202020202223353242434133222C';
wwv_flow_imp.g_varchar2_table(372) := '0D0A2020202020202020202020202223393943393435222C0D0A2020202020202020202020202223434336314230222C0D0A2020202020202020202020202223323437393643222C0D0A2020202020202020202020202223444141353142222C0D0A2020';
wwv_flow_imp.g_varchar2_table(373) := '202020202020202020202223324638414334222C0D0A2020202020202020202020202223373634453946222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A2020202020202020223130223A205B0D0A2020';
wwv_flow_imp.g_varchar2_table(374) := '202020202020202020202223453538363036222C0D0A2020202020202020202020202223354436394231222C0D0A2020202020202020202020202223353242434133222C0D0A2020202020202020202020202223393943393435222C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(375) := '2020202020202223434336314230222C0D0A2020202020202020202020202223323437393643222C0D0A2020202020202020202020202223444141353142222C0D0A2020202020202020202020202223324638414334222C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(376) := '20202223373634453946222C0D0A2020202020202020202020202223454436343541222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A2020202020202020223131223A205B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(377) := '20202223453538363036222C0D0A2020202020202020202020202223354436394231222C0D0A2020202020202020202020202223353242434133222C0D0A2020202020202020202020202223393943393435222C0D0A2020202020202020202020202223';
wwv_flow_imp.g_varchar2_table(378) := '434336314230222C0D0A2020202020202020202020202223323437393643222C0D0A2020202020202020202020202223444141353142222C0D0A2020202020202020202020202223324638414334222C0D0A202020202020202020202020222337363445';
wwv_flow_imp.g_varchar2_table(379) := '3946222C0D0A2020202020202020202020202223454436343541222C0D0A2020202020202020202020202223434333413845222C0D0A2020202020202020202020202223413541413939220D0A20202020202020205D2C0D0A2020202020202020227461';
wwv_flow_imp.g_varchar2_table(380) := '6773223A205B0D0A202020202020202020202020227175616C69746174697665220D0A20202020202020205D0D0A202020207D0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(887252224392740136)
,p_plugin_id=>wwv_flow_imp.id(887188518588519005)
,p_file_name=>'cartocolors.json'
,p_mime_type=>'application/octet-stream'
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
