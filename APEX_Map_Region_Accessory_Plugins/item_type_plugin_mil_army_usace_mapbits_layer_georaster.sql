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
--   Date and Time:   19:59 Tuesday February 10, 2026
--   Exported By:     LESS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 43394131106713264
--   Manifest End
--   Version:         24.2.4
--   Instance ID:     218369902185809
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_layer_georaster
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(43394131106713264)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LAYER.GEORASTER'
,p_display_name=>'Mapbits GeoRaster Layer'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#maplibre-contour.min.js',
'#PLUGIN_FILES#mapbits_georaster#MIN#.js'))
,p_css_file_urls=>'#PLUGIN_FILES#mapbits_georaster#MIN#.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- Parse and run query returning the sdo_georaster',
'procedure georas(p_sql in varchar2, p_items in varchar2, g out sdo_georaster) is',
'  c pls_integer;',
'  n integer;',
'  id integer;',
'  i integer;',
'  l_items apex_t_varchar2;',
'begin',
'  -- set up cursor and define georaster column.',
'  c := dbms_sql.open_cursor;',
'  dbms_sql.parse(c, p_sql, dbms_sql.native);',
'  dbms_sql.define_column(c, 1, g);',
'',
'  -- if any of the ''page item to submit'' are in the query, bind them.',
'  l_items := apex_string.split(p_items, '','');',
'  for i in 1..l_items.count loop',
'    if instr(lower(p_sql), '':'' || lower(l_items(i))) > 0 then',
'      dbms_sql.bind_variable(c, l_items(i), v(l_items(i))); ',
'    end if;',
'  end loop;',
'',
'  -- execute, fetch, and close',
'  n := dbms_sql.execute(c);',
'  n := dbms_sql.fetch_rows(c);',
'  dbms_sql.column_value(c, 1, g);',
'  dbms_sql.close_cursor(c);',
'end;',
'',
'-- HTTP service handler to get information about the ',
'-- raster (band count, dimensions, extent, cell depth)',
'procedure map_georaster_info_svc(p_geor in out sdo_georaster, p_item_id in varchar2, p_terrain_features in varchar2) is',
'  l_geom sdo_geometry;',
'  l_csid integer;',
'  l_pyramid_level integer;',
'  l_dims sdo_number_array;',
'  l_nbands integer;',
'  l_celldepth integer;',
'  l_p1 sdo_geometry;',
'  l_p2 sdo_geometry;',
'  l_window sdo_geometry;',
'  l_stats sdo_number_array;',
'begin',
'  htp.init;',
'  owa_util.mime_header(''application/json'', FALSE);',
'  owa_util.http_header_close;',
'',
'  l_dims := sdo_geor.getSpatialDimSizes(p_geor);',
'  if l_dims is null then',
'    htp.p(''{"error" : "['' || p_item_id || ''] Invalid Raster"}'');',
'  else',
'    l_pyramid_level := sdo_geor.getPyramidMaxLevel(p_geor);',
'    l_csid := sdo_geor.getModelSRID(p_geor);',
'    l_nbands := sdo_geor.getBandDimSize(p_geor);',
'    l_celldepth := sdo_geor.getCellDepth(p_geor);',
'    l_p1 := sdo_cs.transform(sdo_geor.getModelCoordinate(p_geor, 0, sdo_number_array(0, 0)), 4326);',
'    l_p2 := sdo_cs.transform(sdo_geor.getModelCoordinate(p_geor, 0, sdo_number_array(l_dims(1), l_dims(2))), 4326);',
'',
'    apex_json.open_object();',
'    apex_json.write(''itemid'', p_item_id);',
'    apex_json.write(''maxpyramidlevel'', l_pyramid_level);',
'    apex_json.write(''bandcount'', l_nbands);',
'    apex_json.write(''celldepth'', l_cellDepth);',
'    apex_json.write(''height'', l_dims(2));',
'    apex_json.write(''width'', l_dims(1));',
'',
'    -- if we are rendering color-relief for a DEM, we need to get a range of values, excluding ''NoData''',
'    if ('':'' || p_terrain_features || '':'') like ''%:color-relief:%'' then',
'      sdo_geor.addNodata(p_geor, 0, sdo_range_array(sdo_range(-340282346638529000000000000000000000000, -37000)));',
'      l_stats := sdo_geor.generateStatistics(p_geor, case when l_pyramid_level >= 1 then 1 else 0 end, ''samplingFactor=10'', l_window, null, ''TRUE'');',
'      apex_json.open_array(''range'');',
'      apex_json.write(l_stats(1));',
'      apex_json.write(l_stats(2));',
'      apex_json.close_array();',
'      apex_json.write(''mean'', l_stats(3));',
'      apex_json.write(''median'', l_stats(4));',
'      apex_json.write(''stdev'', l_stats(6));',
'    end if;',
'',
'    apex_json.open_array(''extent'');',
'    apex_json.write(sdo_util.getfirstvertex(l_p1).x);',
'    apex_json.write(sdo_util.getfirstvertex(l_p1).y);',
'    apex_json.write(sdo_util.getfirstvertex(l_p2).x);',
'    apex_json.write(sdo_util.getfirstvertex(l_p2).y);',
'    apex_json.close_array();',
'    apex_json.close_object();',
'  end if;',
'end;',
'',
'-- HTTP service handler to fetch the raster data encoded as base 64.',
'procedure map_georaster_data_svc(p_geor in sdo_georaster,',
'  p_x1 in number,',
'  p_y1 number,',
'  p_x2 number,',
'  p_y2 number,',
'  p_bg varchar2',
') is',
'  l_geom sdo_geometry;',
'  l_geom_latlon sdo_geometry;',
'  l_geom_3857 sdo_geometry;',
'  l_max_res_x number;',
'  l_max_res_y number;',
'  l_csid integer;',
'  l_min_tile_size constant integer := 256;',
'  l_pyramid_level integer;',
'  l_dims sdo_number_array;',
'  l_width integer := 0;',
'  l_height integer := 0;',
'  l_outarea sdo_geometry;',
'  l_pos pls_integer;',
'  l_len pls_integer;',
'  l_nbands integer;',
'  l_resample varchar2(12);',
'  l_layers varchar2(10);',
'  l_celldepth integer;',
'  rt blob;',
'  l_result clob;',
'  l_pyr_res_x number;',
'  l_pyr_res_y number;',
'  l_res_x number;',
'  l_res_y number;',
'  l_bgtoks apex_t_varchar2;',
'  l_bgvalues sdo_number_array := null;',
'begin',
'  dbms_lob.createTemporary(rt, TRUE, dbms_lob.session);',
'  l_dims := sdo_number_array(0, 0, 0, 0);',
'  l_csid := sdo_geor.getModelSRID(p_geor);',
'  l_nbands := sdo_geor.getBandDimSize(p_geor);',
'  l_celldepth := sdo_geor.getCellDepth(p_geor);',
'  if l_nbands >= 3 then ',
'    l_layers := ''1,2,3'';',
'  else',
'    l_layers := ''1'';',
'  end if;',
'  -- create query window geometry in lon/lat',
'  l_geom_latlon := sdo_geometry(2003, 4326, null, sdo_elem_info_array(1, 1003, 1), sdo_ordinate_array(p_x1, p_y1, p_x2, p_y1, p_x2, p_y2, p_x1, p_y2, p_x1, p_y1));',
'  l_geom := sdo_cs.transform(l_geom_latlon, l_csid);',
'  l_geom_3857 := sdo_cs.transform(l_geom_latlon, 3857);',
'',
'  if p_geor.spatialExtent is not null and sdo_geom.relate(l_geom, ''ANYINTERACT'', p_geor.spatialExtent) != ''TRUE'' then',
'    htp.p(''{"noRaster":true}'');',
'    return;',
'  end if;',
'',
'  -- choose the pyramid layer based on the query window and ''minimum number of pixels in return raster''',
'  declare',
'    l_width number;',
'    l_height number;',
'    l_res sdo_number_array;',
'  begin',
'    l_width := sdo_geom.sdo_max_mbr_ordinate(l_geom, 1) - sdo_geom.sdo_min_mbr_ordinate(l_geom, 1);',
'    l_height := sdo_geom.sdo_max_mbr_ordinate(l_geom, 2) - sdo_geom.sdo_min_mbr_ordinate(l_geom, 2);',
'    l_res := sdo_geor.generateSpatialResolutions(p_geor, 0);',
'    l_max_res_x := l_res(1);',
'    l_max_res_y := l_res(2);',
'',
'    select layer, res_x, res_y into l_pyramid_level, l_pyr_res_x, l_pyr_res_y',
'      from (',
'        select layer, res_x, res_y, row_number() over (order by l_width / res_x) r',
'          from (',
'            select res_x, res_y, layer2 layer',
'              from',
'                (',
'                  select level - 1 layer',
'                    from dual',
'                    connect by level < sdo_geor.getpyramidmaxlevel(p_geor) + 2',
'                ) pyl',
'                cross apply (',
'                  select * from (',
'                    select rownum rn, column_value, pyl.layer layer2 from sdo_geor.generateSpatialResolutions(p_geor, pyl.layer)',
'                  )',
'                  pivot (',
'                    max(column_value)',
'                    for rn in (1 as res_x, 2 as res_y)',
'                  )',
'                )',
'          ) a',
'          where least(l_width / res_x, l_height / res_y) >= l_min_tile_size',
'      )',
'      where r = 1;',
'  exception when no_data_found then',
'    l_pyramid_level := 0;',
'    l_pyr_res_x := l_max_res_x;',
'    l_pyr_res_y := l_max_res_y;',
'  end;',
'',
'  if l_cellDepth = 8 then',
'    l_resample := ''NN'';',
'  else',
'    l_resample := ''BILINEAR'';',
'  end if;',
'',
'  -- query source raster, reproject it to lon/lat, clip to query window geometry,',
'  -- and convert it to base 64.',
'  begin',
'    -- Spatial resolution of the output (in other words, the size of a single',
'    -- pixel in the Web Mercator coordinate system). This is the size of the',
'    -- tile in that space divided by the size in pixels.',
'    l_res_x := (sdo_geom.sdo_max_mbr_ordinate(l_geom_3857, 1) - sdo_geom.sdo_min_mbr_ordinate(l_geom_3857, 1)) / 256;',
'    l_res_y := (sdo_geom.sdo_max_mbr_ordinate(l_geom_3857, 2) - sdo_geom.sdo_min_mbr_ordinate(l_geom_3857, 2)) / 256;',
'',
'    if l_celldepth = 8 and l_nbands = 3 and p_bg is not null then',
'      l_bgtoks := apex_string.split(p_bg, '','');',
'      l_bgvalues := sdo_number_array(l_bgtoks(1), l_bgtoks(2), l_bgtoks(3));',
'    elsif l_celldepth > 8 then',
'      l_bgvalues := sdo_number_array(-99999);',
'    end if;',
'',
'    -- Perform the reprojection',
'    sdo_geor.warp(',
'      inGeoRaster => p_geor,',
'      pyramidLevel => l_pyramid_level,',
'      -- Specify the georeferencing parameters of the output',
'      outSRS => sdo_geor_srs(',
'        isReferenced => ''TRUE'',',
'        isRectified => ''TRUE'',',
'        srid => 3857,',
'        spatialResolution => sdo_number_array(l_res_x, l_res_y),',
'        -- These are the polynomials that define the position of the raster',
'        rowNumerator => sdo_number_array(',
'          1, 2, 1, 3,',
'          -- The location of the top-left corner of the raster, *after* scaling',
'          -- (hence dividing by the resolution)',
'          sdo_geom.sdo_max_mbr_ordinate(l_geom_3857, 2) / l_res_y, 0,',
'          -- The scale, which is the reciprocal of the spatial resolution.',
'          -- Negative because in Web Mercator, the Y axis is flipped compared',
'          -- to raster coordinates.',
'          -1 / l_res_y',
'         ),',
'        rowDenominator => sdo_number_array(1, 0, 0, 1, 1),',
'        columnNumerator => sdo_number_array(1, 2, 1, 3, -sdo_geom.sdo_min_mbr_ordinate(l_geom_3857, 1) / l_res_x, 1 / l_res_x, 0),',
'        columnDenominator => sdo_number_array(1, 0, 0, 1, 1),',
'',
'        isOrthoRectified => null,',
'        spatialTolerance => null, coordLocation => 0, rowOff => 0, columnOff => 0, xOff => 0, yOff => 0, zOff => 0, rowScale => 1,',
'        columnScale => 1, xScale => 1, yScale => 1, zScale => 1, rowRMS => null, columnRMS => null, totalRMS => null',
'      ),',
'      cropArea => l_geom_3857,',
'      dimensionSize => sdo_number_array(round(256 * l_pyr_res_x / l_max_res_x), round(256 * l_pyr_res_y / l_max_res_y)),',
'      layerNumbers => l_layers,',
'      elevationParam => '''',',
'      resampleParam => ''nodata=TRUE,resampling='' || l_resample,',
'      storageParam => ''bitmapmask=TRUE'',',
'      rasterBlob => rt,',
'      outArea => l_outArea,',
'      outWindow => l_dims,',
'      bgValues => l_bgvalues',
'    );',
'',
'    l_result := apex_web_service.blob2clobbase64(rt, p_newlines => ''N'');',
'    l_len := dbms_lob.getlength(l_result);',
'    l_height := l_dims(3) - l_dims(1) + 1;',
'    l_width := l_dims(4) - l_dims(2) + 1;',
'    l_outArea := sdo_cs.transform(l_outArea, 4326);',
'    dbms_lob.freetemporary(rt);',
'  end;',
'',
'  -- output to http as json',
'  htp.init;',
'  owa_util.mime_header(''application/json'', FALSE);',
'  owa_util.http_header_close;',
'',
'  select json_object(',
'    ''pyramidlevel'' value l_pyramid_level,',
'    ''bandcount'' value l_nbands,',
'    ''celldepth'' value l_celldepth,',
'    ''height'' value l_height,',
'    ''width'' value l_width,',
'    ''request_extent'' value json_array(p_x1, p_y2, p_x2, p_y1),',
'    ''extent'' value json_array(',
'      sdo_geom.sdo_min_mbr_ordinate(l_outArea, 1),',
'      sdo_geom.sdo_min_mbr_ordinate(l_outArea, 2),',
'      sdo_geom.sdo_max_mbr_ordinate(l_outArea, 1),',
'      sdo_geom.sdo_max_mbr_ordinate(l_outArea, 2)',
'    ),',
'    ''celldata'' value ''"'' || l_result || ''"'' format json',
'    returning clob',
'  )',
'    into l_result',
'    from dual;',
'',
'  apex_util.prn(l_result, false);',
'end;',
'',
'-- Plugin Ajax Handler',
'procedure map_georaster_ajax(',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_ajax_param,',
'  p_result in out nocopy apex_plugin.t_item_ajax_result',
') is',
'  l_source_proc p_item.attribute_01%type := p_item.attribute_01;',
'  l_grid sdo_georaster;',
'  l_submit_items p_item.attribute_06%type := p_item.attribute_06;',
'begin',
'  georas(l_source_proc, l_submit_items, l_grid);',
'',
'  if l_grid is null then',
'    htp.p(''{"noRaster":true}'');',
'    return;',
'  end if;',
'',
'  if apex_application.g_x01 = 0 then -- info request',
'    map_georaster_info_svc(l_grid, p_item.name, p_item.attributes.get_varchar2(''terrain_features''));',
'  elsif apex_application.g_x01 = 1 then -- data request',
'    map_georaster_data_svc(l_grid, apex_application.g_x03, apex_application.g_x04, apex_application.g_x05, apex_application.g_x06, apex_application.g_x02);',
'  end if;',
'end;',
'',
'-- Render function',
'procedure map_georaster_render(',
'  p_item in apex_plugin.t_item, ',
'  p_plugin in apex_plugin.t_plugin, ',
'  p_param  in apex_plugin.t_item_render_param, ',
'  p_result in out nocopy apex_plugin.t_item_render_result ) is',
'  l_region_id varchar2(400);',
'  l_sequence_no apex_application_page_items.display_sequence%type;',
'  l_title p_item.attribute_02%type := p_item.attribute_02;',
'  l_checkbox_color p_item.attribute_03%type := p_item.attribute_03;',
'  l_init_visible p_item.attribute_04%type := p_item.attribute_04;',
'  l_opacity p_item.attribute_05%type := p_item.attribute_05;',
'  l_submit_items p_item.attribute_06%type := p_item.attribute_06;',
'  l_layer_type varchar2(100) := p_item.attributes.get_varchar2(''layer_type'');',
'  l_color_ramp p_item.attribute_08%type := p_item.attribute_08;',
'  l_exaggeration p_item.attribute_09%type := p_item.attribute_09;',
'  l_bgcolor p_item.attribute_10%type := p_item.attributes.get_varchar2(''bgcolor'');',
'begin',
'  begin',
'  -- fetch associated region, and display sequence number (for ordering layers)',
'  select nvl(r.static_id, ''R'' || r.region_id), i.display_sequence into l_region_id, l_sequence_no  ',
'    from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception',
'    when no_data_found then ',
'      raise_application_error(-20381, ''Configuration ERROR: Mapbits Raster Layer ['' ||p_item.name || ''] is not associated with a Map region.'');',
'  end;',
'  -- Run the javascript on the ''spatialmapinitialized event''',
'  htp.p(''<div id="'' || p_item.name || ''" name="'' || p_item.name || ''"></div>'');',
'  apex_javascript.add_onload_code(p_code => ''',
'    apex.jQuery('' || l_region_id || '').on("spatialmapinitialized", () => {',
'      mapbits_georaster({''',
'        || apex_javascript.add_attribute(''p_item_id'', p_item.name)',
'        || apex_javascript.add_attribute(''p_ajax_identifier'', apex_plugin.get_ajax_identifier)',
'        || apex_javascript.add_attribute(''p_region_id'', l_region_id)',
'        || apex_javascript.add_attribute(''p_sequence'', l_sequence_no)',
'        || apex_javascript.add_attribute(''p_title'', l_title)',
'        || apex_javascript.add_attribute(''p_checkbox_color'',l_checkbox_color)',
'        || apex_javascript.add_attribute(''p_init_visibility'', l_init_visible)',
'        || apex_javascript.add_attribute(''p_opacity'', to_number(l_opacity) / 100)',
'        || apex_javascript.add_attribute(''p_submit_items'', l_submit_items)',
'        || apex_javascript.add_attribute(''p_layer_type'', l_layer_type)',
'        || apex_javascript.add_attribute(''p_exaggeration'', l_exaggeration)',
'        || apex_javascript.add_attribute(''p_bgcolor'', l_bgcolor)',
'        || apex_javascript.add_attribute(''p_terrain_features'', p_item.attributes.get_varchar2(''terrain_features''))',
'        || apex_javascript.add_attribute(''p_color_relief_map'', p_item.attributes.get_varchar2(''color_relief_map''))',
'        || apex_javascript.add_attribute(''p_plugin_files'', p_plugin.file_prefix)',
'        || ''p_color_ramp: ('' || nvl(l_color_ramp, ''null'') || ''),''',
'      || ''});',
'    });',
'  '');',
'end;'))
,p_api_version=>2
,p_render_function=>'map_georaster_render'
,p_ajax_function=>'map_georaster_ajax'
,p_substitute_attributes=>true
,p_version_scn=>455288952
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits GeoRaster Layer plugin adds support for Oracle GeoRasters without the need for middleware services. Add this plugin as an item under an APEX Map region. Define a single-row SQL query that returns a single column of type sdo_georaster and '
||'that raster shall be rendered in the associated Map Region. Currently, only DEM (single band, 32-bit float) and RGB (three band, 8-bit unsigned integer) rasters are supported. No compression is supported at this time. For best results, rasters should'
||' be projected to the Web Mercator coordinate reference system (EPSG:3857). Rasters referenced to other coordinate references system may have some degree of distortion.'
,p_version_identifier=>'5.0.20260127'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 5 - GeoRaster Layer',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_georaster.sql 21386 2026-02-10 20:05:51Z b2eddjw9 $',
'Date     : $Date: 2026-02-10 14:05:51 -0600 (Tue, 10 Feb 2026) $',
'Revision : $Revision: 21386 $',
'Requires : Application Express >= 24.2',
'',
'Version 5 Updates',
'01/27/2026 Change name from Georaster to GeoRaster ',
'01/23/2025 Add Background Color attribute for 3-band color rasters',
'12/19/2025 Use web workers to draw tiles',
'12/03/2025 Change layer type values to Automatic, Color, and DEM. DEM display options are moved to a new section.',
'12/01/2025 Add more built-in color ramps',
'06/11/2025 Implement show/hide and isVisible API',
'',
'-------------------',
'',
'Version 4.9 Updates',
'02/11/2025 Cleared up seams between raster tiles. Added ''Page Items to Submit'' to render georasters based on page item values. Added missing icon for terrain control.',
'',
'Version 4.8 Updates',
'01/28/2025 Added warning for missing pyramids. Resized tile canvas to be square, since DEMs require square tiles. Increased buffer size for blob64 generation.',
''))
,p_files_version=>751
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(155316248555234182)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_title=>'DEM'
,p_display_sequence=>1
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43394846224713264)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_static_id=>'attribute_01'
,p_prompt=>'GeoRaster Source'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'select raster from mb4_georaster where id = 1'
,p_help_text=>'SQL Query returning one row of one column containing data type sdo_georaster.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43395276725713264)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>5
,p_static_id=>'attribute_02'
,p_prompt=>'Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Name of layer to be displayed in the Legend, the toggle section under the map used to turn layers on and off.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43395657417713264)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_static_id=>'attribute_03'
,p_prompt=>'Checkbox Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#000000'
,p_is_translatable=>false
,p_help_text=>'Color of the checkbox to be displayed for this layer in the Legend, the toggle section under the map used to turn layers on and off.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43396052308713264)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_static_id=>'attribute_04'
,p_prompt=>'Initially Visible?'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'If ''Y'', then this layer will be turned on the first time a user visits this page, otherwise it will be off. After the initial page visit, the layer visibility will be persisted.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43396452859713265)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_static_id=>'attribute_05'
,p_prompt=>'Opacity (0-100)'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'100'
,p_is_translatable=>false
,p_help_text=>'Percent opacity of the raster layer. This is a value between 0 and 100. A value of 0 makes the raster completely transparent, while a value of 100 makes the raster completely opaque.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43396847233713265)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>15
,p_static_id=>'attribute_06'
,p_prompt=>'Page Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43397258427713265)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>16
,p_static_id=>'layer_type'
,p_prompt=>'Layer Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'auto'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43397643913713265)
,p_plugin_attribute_id=>wwv_flow_imp.id(43397258427713265)
,p_display_sequence=>10
,p_display_value=>'Automatic'
,p_return_value=>'auto'
,p_help_text=>'Automatically detect the raster type based on the bands.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43398116461713265)
,p_plugin_attribute_id=>wwv_flow_imp.id(43397258427713265)
,p_display_sequence=>20
,p_display_value=>'Color'
,p_return_value=>'color'
,p_help_text=>'The data is 3-band RGB or 4-band RGBA.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43398611577713265)
,p_plugin_attribute_id=>wwv_flow_imp.id(43397258427713265)
,p_display_sequence=>30
,p_display_value=>'DEM'
,p_return_value=>'dem'
,p_help_text=>'The raster is a digital elevation model.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43399177124713266)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>120
,p_static_id=>'attribute_08'
,p_prompt=>'Custom Color Relief Map'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>false
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// stats is an associative array with raster attributes: ''min'', ',
'// ''max'', ''mean'', ''median'', and ''stdev''.',
'// you can also omit the stats and return a list of colors, which will be mapped to the range',
'',
'function(stats, builtin) {',
'  return [',
'    [stats.min, ''red''],',
'    [stats.median, ''white''],',
'    [stats.max, ''blue''],',
'  ];',
'}'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'custom'
,p_attribute_group_id=>wwv_flow_imp.id(155316248555234182)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Javascript function that takes a single input that is an associated array with raster properties: ''min'', ''max'', ''mean'', ''median'', and ''stdev'' and returns one of the following:',
'',
'- An array of colors, which will be mapped to the range of the raster values',
'- An array of two-item arrays. The first item is the raster value and the second is the color it maps to.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43399546733713266)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_static_id=>'attribute_09'
,p_prompt=>'Terrain Exaggeration'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43397258427713265)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'dem'
,p_attribute_group_id=>wwv_flow_imp.id(155316248555234182)
,p_examples=>'0.3048 (if source is in feet)'
,p_help_text=>'The factor to apply to elevation values. IMPORTANT: Elevation values are interpreted in meters. If your source is in feet, set to 0.3048 or the terrain will be exaggerated.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43399952375713266)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_static_id=>'terrain_features'
,p_prompt=>'Terrain Features'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43397258427713265)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'dem'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(155316248555234182)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43400391441713266)
,p_plugin_attribute_id=>wwv_flow_imp.id(43399952375713266)
,p_display_sequence=>10
,p_display_value=>'3D'
,p_return_value=>'3d'
,p_help_text=>'Show a button to enable 3d terrain rendering.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43400805964713266)
,p_plugin_attribute_id=>wwv_flow_imp.id(43399952375713266)
,p_display_sequence=>20
,p_display_value=>'Hillshade'
,p_return_value=>'hillshade'
,p_help_text=>'Shade the map as if the terrain is illuminated by a light source.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43401375569713266)
,p_plugin_attribute_id=>wwv_flow_imp.id(43399952375713266)
,p_display_sequence=>30
,p_display_value=>'Color Relief'
,p_return_value=>'color-relief'
,p_help_text=>'Use a color ramp to indicate the terrain elevation.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43401848488713267)
,p_plugin_attribute_id=>wwv_flow_imp.id(43399952375713266)
,p_display_sequence=>40
,p_display_value=>'Contours'
,p_return_value=>'contours'
,p_help_text=>'Show contour lines on the map.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43402389469713267)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_static_id=>'color_relief_map'
,p_prompt=>'Color Relief Map'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'turbo'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(43397258427713265)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'dem'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(155316248555234182)
,p_help_text=>'The color map that will be used to display the values of the raster. Choose Custom to provide a color map using JavaScript.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43402723964713267)
,p_plugin_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_display_sequence=>10
,p_display_value=>'Turbo'
,p_return_value=>'turbo'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43403251693713267)
,p_plugin_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_display_sequence=>20
,p_display_value=>'Magma'
,p_return_value=>'magma'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43403761266713267)
,p_plugin_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_display_sequence=>30
,p_display_value=>'Viridis'
,p_return_value=>'viridis'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43404299160713267)
,p_plugin_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_display_sequence=>40
,p_display_value=>'Cividis'
,p_return_value=>'cividis'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43404746967713267)
,p_plugin_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_display_sequence=>50
,p_display_value=>'Rocket'
,p_return_value=>'rocket'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43405259637713268)
,p_plugin_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_display_sequence=>60
,p_display_value=>'Mako'
,p_return_value=>'mako'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43405759261713268)
,p_plugin_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_display_sequence=>70
,p_display_value=>'Inferno'
,p_return_value=>'inferno'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43406273340713268)
,p_plugin_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_display_sequence=>80
,p_display_value=>'Plasma'
,p_return_value=>'plasma'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(43406765811713268)
,p_plugin_attribute_id=>wwv_flow_imp.id(43402389469713267)
,p_display_sequence=>999
,p_display_value=>'Custom'
,p_return_value=>'custom'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(66006251138410574)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_static_id=>'bgcolor'
,p_prompt=>'Background Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#000000'
,p_is_translatable=>false
,p_help_text=>'Color value to use for the background of the georaster. If the georaster does not have a fourth (alpha) band for transparency, this value will be used to fill in undefined pixels in the image. The map viewer will render pixels of this value as fully '
||'transparent. If there are pixels of this value in the georaster, this value should be changed to a pixel value not in the georaster.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A2049636F6E7320666F72205465727261696E20436F6E74726F6C20427574746F6E202A2F0D0A2E6D61706C69627265676C2D6374726C20627574746F6E2E6D61706C69627265676C2D6374726C2D7465727261696E202E6D61706C69627265676C2D';
wwv_flow_imp.g_varchar2_table(2) := '6374726C2D69636F6E207B0D0A20206261636B67726F756E642D696D6167653A2075726C2822646174613A696D6167652F7376672B786D6C3B636861727365743D7574662D382C25334373766720786D6C6E733D27687474703A2F2F7777772E77332E6F';
wwv_flow_imp.g_varchar2_table(3) := '72672F323030302F737667272077696474683D27323227206865696768743D273232272066696C6C3D27253233333333272076696577426F783D27302030203232203232272533452533437061746820643D276D312E3735342031332E34303620342E34';
wwv_flow_imp.g_varchar2_table(4) := '35332D342E38353120332E303920332E303920332E32383120332E3237372E3936392D2E3936392D332E3330392D332E33313220332E3834342D342E31323120362E31343820362E38383668312E303832762D2E3835356C2D372E3230372D382E30372D';
wwv_flow_imp.g_varchar2_table(5) := '342E383420352E3138374C362E31363920362E35376C2D352E343820352E393635762E3837315A4D2E3638382031362E3834346832302E36323576312E333735482E3638385A6D302030272F2533452533432F73766725334522293B0D0A20206261636B';
wwv_flow_imp.g_varchar2_table(6) := '67726F756E642D706F736974696F6E3A203530253B0D0A20206261636B67726F756E642D7265706561743A206E6F2D7265706561743B0D0A2020646973706C61793A20626C6F636B3B0D0A20206865696768743A203530253B0D0A202077696474683A20';
wwv_flow_imp.g_varchar2_table(7) := '3530253B0D0A20206D617267696E3A206175746F3B0D0A7D0D0A0D0A2E6D61706C69627265676C2D6374726C20627574746F6E2E6D61706C69627265676C2D6374726C2D7465727261696E2D656E61626C6564202E6D61706C69627265676C2D6374726C';
wwv_flow_imp.g_varchar2_table(8) := '2D69636F6E207B0D0A20206261636B67726F756E642D696D6167653A2075726C2822646174613A696D6167652F7376672B786D6C3B636861727365743D7574662D382C25334373766720786D6C6E733D27687474703A2F2F7777772E77332E6F72672F32';
wwv_flow_imp.g_varchar2_table(9) := '3030302F737667272077696474683D27323227206865696768743D273232272066696C6C3D27253233333362356535272076696577426F783D27302030203232203232272533452533437061746820643D276D312E3735342031332E34303620342E3435';
wwv_flow_imp.g_varchar2_table(10) := '332D342E38353120332E303920332E303920332E32383120332E3237372E3936392D2E3936392D332E3330392D332E33313220332E3834342D342E31323120362E31343820362E38383668312E303832762D2E3835356C2D372E3230372D382E30372D34';
wwv_flow_imp.g_varchar2_table(11) := '2E383420352E3138374C362E31363920362E35376C2D352E343820352E393635762E3837315A4D2E3638382031362E3834346832302E36323576312E333735482E3638385A6D302030272F2533452533432F73766725334522293B0D0A20206261636B67';
wwv_flow_imp.g_varchar2_table(12) := '726F756E642D706F736974696F6E3A203530253B0D0A20206261636B67726F756E642D7265706561743A206E6F2D7265706561743B0D0A2020646973706C61793A20626C6F636B3B0D0A20206865696768743A203530253B0D0A202077696474683A2035';
wwv_flow_imp.g_varchar2_table(13) := '30253B0D0A20206D617267696E3A206175746F3B0D0A7D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43408187660713270)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_file_name=>'mapbits_georaster.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F47454F5241535445525F57414954494E47203D207B7D3B0D0A0D0A66756E6374696F6E206D6170626974735F67656F7261737465725F776169745F666F725F696E6974286974656D496429207B0D0A20207265747572';
wwv_flow_imp.g_varchar2_table(2) := '6E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A202020206966202821286974656D496420696E204D4150424954535F47454F5241535445525F57414954494E472929207B0D0A2020202020204D41504249';
wwv_flow_imp.g_varchar2_table(3) := '54535F47454F5241535445525F57414954494E475B6974656D49645D203D205B5D3B0D0A202020207D0D0A0D0A20202020696620284D4150424954535F47454F5241535445525F57414954494E475B6974656D49645D203D3D3D206E756C6C29207B0D0A';
wwv_flow_imp.g_varchar2_table(4) := '2020202020207265736F6C766528617065782E6974656D286974656D496429293B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A202020204D4150424954535F47454F5241535445525F57414954494E475B6974656D49645D2E707573';
wwv_flow_imp.g_varchar2_table(5) := '6828286974656D29203D3E207B0D0A2020202020207265736F6C7665286974656D293B0D0A202020207D293B0D0A20207D290D0A7D0D0A0D0A6173796E632066756E6374696F6E206D6170626974735F67656F726173746572287B0D0A2020705F697465';
wwv_flow_imp.g_varchar2_table(6) := '6D5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F73657175656E63652C20705F7469746C652C20705F636865636B626F785F636F6C6F722C20705F696E69745F7669736962696C6974792C20705F6F70';
wwv_flow_imp.g_varchar2_table(7) := '61636974792C0D0A2020705F7375626D69745F6974656D732C20705F6C617965725F747970652C20705F636F6C6F725F72616D702C20705F657861676765726174696F6E2C20705F7465727261696E5F66656174757265732C20705F636F6C6F725F7265';
wwv_flow_imp.g_varchar2_table(8) := '6C6965665F6D61702C20705F706C7567696E5F66696C65732C0D0A2020705F6267636F6C6F722C0D0A7D29207B0D0A20202F2F20536F757263653A2068747470733A2F2F77696B692E6F70656E7374726565746D61702E6F72672F77696B692F536C6970';
wwv_flow_imp.g_varchar2_table(9) := '70795F6D61705F74696C656E616D65730D0A20202F2F20436F6E766572742074696C6520636F6F7264696E6174657320287B5A7D7B587D7B597D2920746F2067656F6772617068696320636F6F7264696E617465732E0D0A2020636F6E73742064656732';
wwv_flow_imp.g_varchar2_table(10) := '726164203D202864656729203D3E204D6174682E5049202A20646567202F203138303B0D0A202066756E6374696F6E2074696C65326C6F6E6728782C207A29207B0D0A2020202072657475726E202878202F204D6174682E706F7728322C207A29202A20';
wwv_flow_imp.g_varchar2_table(11) := '333630202D20313830293B0D0A20207D0D0A202066756E6374696F6E2074696C65326C617428792C207A29207B0D0A20202020636F6E7374206E203D204D6174682E5049202D2032202A204D6174682E5049202A2079202F204D6174682E706F7728322C';
wwv_flow_imp.g_varchar2_table(12) := '207A293B0D0A2020202072657475726E2028313830202F204D6174682E5049202A204D6174682E6174616E28302E35202A20284D6174682E657870286E29202D204D6174682E657870282D6E292929293B0D0A20207D0D0A202066756E6374696F6E206C';
wwv_flow_imp.g_varchar2_table(13) := '61743274696C65287A2C206C617429207B0D0A20202020636F6E7374206E203D204D6174682E706F7728322C207A293B0D0A20202020636F6E7374206C6174526164203D2064656732726164286C6174293B0D0A2020202072657475726E206E202A2028';
wwv_flow_imp.g_varchar2_table(14) := '31202D20284D6174682E6C6F67284D6174682E74616E286C617452616429202B202831202F204D6174682E636F73286C6174526164292929202F204D6174682E50492929202F20323B0D0A20207D0D0A202066756E6374696F6E206C6F6E3274696C6528';
wwv_flow_imp.g_varchar2_table(15) := '7A2C206C6F6E29207B0D0A20202020636F6E7374206E203D204D6174682E706F7728322C207A293B0D0A2020202072657475726E206E202A2028286C6F6E202B2031383029202F20333630293B0D0A20207D0D0A0D0A2020636F6E7374206D61706C6962';
wwv_flow_imp.g_varchar2_table(16) := '76657273696F6E203D20286D61706C69627265676C2E67657456657273696F6E203F206D61706C69627265676C2E67657456657273696F6E2829203A206D61706C69627265676C2E76657273696F6E292E73706C697428272E27292E6D61702878203D3E';
wwv_flow_imp.g_varchar2_table(17) := '207061727365496E74287829293B0D0A2020636F6E73742068617356657273696F6E203D20286D616A6F722C206D696E6F72203D20302C207061746368203D203029203D3E207B0D0A20202020696620286D61706C696276657273696F6E5B305D20213D';
wwv_flow_imp.g_varchar2_table(18) := '3D206D616A6F7229207B0D0A20202020202072657475726E206D61706C696276657273696F6E5B305D203E206D616A6F723B0D0A202020207D0D0A20202020696620286D61706C696276657273696F6E5B315D20213D3D206D696E6F7229207B0D0A2020';
wwv_flow_imp.g_varchar2_table(19) := '2020202072657475726E206D61706C696276657273696F6E5B315D203E206D696E6F723B0D0A202020207D0D0A2020202072657475726E206D61706C696276657273696F6E5B325D203E3D2070617463683B0D0A20207D3B0D0A2020636F6E7374207072';
wwv_flow_imp.g_varchar2_table(20) := '6F746F43616C6C6261636B203D202168617356657273696F6E2834293B0D0A2020636F6E7374206D6C436F6C6F7252656C696566203D2068617356657273696F6E28352C2036293B0D0A2020636F6E7374206D6C437573746F6D456E636F64696E67203D';
wwv_flow_imp.g_varchar2_table(21) := '2068617356657273696F6E28332C2034293B0D0A0D0A2020705F7465727261696E5F6665617475726573203D2028705F7465727261696E5F6665617475726573207C7C202727292E73706C697428273A27292E66696C7465722878203D3E20212178293B';
wwv_flow_imp.g_varchar2_table(22) := '0D0A0D0A20202F2F2047657420746865206D61706C69627265206D6170206F626A65637420616E642067656F72617374657220696E7374616E636520636F6F6B69652E0D0A2020636F6E7374206D6170203D20617065782E726567696F6E28705F726567';
wwv_flow_imp.g_varchar2_table(23) := '696F6E5F6964292E63616C6C28226765744D61704F626A65637422293B0D0A20206C6574206C436F6F6B6965203D20617065782E73746F726167652E676574436F6F6B696528274D6170626974735F47656F5261737465724C617965725F27202B20705F';
wwv_flow_imp.g_varchar2_table(24) := '6974656D5F6964202B20225F22202B202476282270496E7374616E6365222929207C7C2028705F696E69745F7669736962696C697479203D3D3D20275927203F202776697369626C6527203A20276E6F6E6527293B0D0A20206C65742068696465526173';
wwv_flow_imp.g_varchar2_table(25) := '7465724C61796572203D2066616C73652C206869646548696C6C73686164654C61796572203D2066616C73652C2068696465436F6E746F75724C61796572203D2066616C73653B0D0A0D0A20202F2A2A0D0A2020202A20546F2067656E65726174653A0D';
wwv_flow_imp.g_varchar2_table(26) := '0A2020202A202D20676F20746F68747470733A2F2F7777772E77332E6F72672F54522F6373732D636F6C6F722D342F236E616D65642D636F6C6F72730D0A2020202A202D2072756E20696E2074686520636F6E736F6C653A0D0A2020202A20636F707928';
wwv_flow_imp.g_varchar2_table(27) := '607B5C6E247B5B2E2E2E646F63756D656E742E717565727953656C6563746F7228272E6E616D65642D636F6C6F722D7461626C652074626F647927292E6368696C6472656E5D2E6D61702828747229203D3E2060247B74722E63656C6C735B325D2E7465';
wwv_flow_imp.g_varchar2_table(28) := '7874436F6E74656E742E7472696D28297D3A205B247B74722E63656C6C735B345D2E74657874436F6E74656E742E7472696D28292E73706C6974282F5C732B2F292E6A6F696E28272C2027297D5D2C60292E6A6F696E28272027297D5C6E7D60293B0D0A';
wwv_flow_imp.g_varchar2_table(29) := '2020202A2F0D0A2020636F6E7374204E414D45445F434F4C4F5253203D207B20616C696365626C75653A205B3234302C203234382C203235355D2C20616E746971756577686974653A205B3235302C203233352C203231355D2C20617175613A205B302C';
wwv_flow_imp.g_varchar2_table(30) := '203235352C203235355D2C20617175616D6172696E653A205B3132372C203235352C203231325D2C20617A7572653A205B3234302C203235352C203235355D2C2062656967653A205B3234352C203234352C203232305D2C206269737175653A205B3235';
wwv_flow_imp.g_varchar2_table(31) := '352C203232382C203139365D2C20626C61636B3A205B302C20302C20305D2C20626C616E63686564616C6D6F6E643A205B3235352C203233352C203230355D2C20626C75653A205B302C20302C203235355D2C20626C756576696F6C65743A205B313338';
wwv_flow_imp.g_varchar2_table(32) := '2C2034332C203232365D2C2062726F776E3A205B3136352C2034322C2034325D2C206275726C79776F6F643A205B3232322C203138342C203133355D2C206361646574626C75653A205B39352C203135382C203136305D2C20636861727472657573653A';
wwv_flow_imp.g_varchar2_table(33) := '205B3132372C203235352C20305D2C2063686F636F6C6174653A205B3231302C203130352C2033305D2C20636F72616C3A205B3235352C203132372C2038305D2C20636F726E666C6F776572626C75653A205B3130302C203134392C203233375D2C2063';
wwv_flow_imp.g_varchar2_table(34) := '6F726E73696C6B3A205B3235352C203234382C203232305D2C206372696D736F6E3A205B3232302C2032302C2036305D2C206379616E3A205B302C203235352C203235355D2C206461726B626C75653A205B302C20302C203133395D2C206461726B6379';
wwv_flow_imp.g_varchar2_table(35) := '616E3A205B302C203133392C203133395D2C206461726B676F6C64656E726F643A205B3138342C203133342C2031315D2C206461726B677261793A205B3136392C203136392C203136395D2C206461726B677265656E3A205B302C203130302C20305D2C';
wwv_flow_imp.g_varchar2_table(36) := '206461726B677265793A205B3136392C203136392C203136395D2C206461726B6B68616B693A205B3138392C203138332C203130375D2C206461726B6D6167656E74613A205B3133392C20302C203133395D2C206461726B6F6C697665677265656E3A20';
wwv_flow_imp.g_varchar2_table(37) := '5B38352C203130372C2034375D2C206461726B6F72616E67653A205B3235352C203134302C20305D2C206461726B6F72636869643A205B3135332C2035302C203230345D2C206461726B7265643A205B3133392C20302C20305D2C206461726B73616C6D';
wwv_flow_imp.g_varchar2_table(38) := '6F6E3A205B3233332C203135302C203132325D2C206461726B736561677265656E3A205B3134332C203138382C203134335D2C206461726B736C617465626C75653A205B37322C2036312C203133395D2C206461726B736C617465677261793A205B3437';
wwv_flow_imp.g_varchar2_table(39) := '2C2037392C2037395D2C206461726B736C617465677265793A205B34372C2037392C2037395D2C206461726B74757271756F6973653A205B302C203230362C203230395D2C206461726B76696F6C65743A205B3134382C20302C203231315D2C20646565';
wwv_flow_imp.g_varchar2_table(40) := '7070696E6B3A205B3235352C2032302C203134375D2C2064656570736B79626C75653A205B302C203139312C203235355D2C2064696D677261793A205B3130352C203130352C203130355D2C2064696D677265793A205B3130352C203130352C20313035';
wwv_flow_imp.g_varchar2_table(41) := '5D2C20646F64676572626C75653A205B33302C203134342C203235355D2C2066697265627269636B3A205B3137382C2033342C2033345D2C20666C6F72616C77686974653A205B3235352C203235302C203234305D2C20666F72657374677265656E3A20';
wwv_flow_imp.g_varchar2_table(42) := '5B33342C203133392C2033345D2C20667563687369613A205B3235352C20302C203235355D2C206761696E73626F726F3A205B3232302C203232302C203232305D2C2067686F737477686974653A205B3234382C203234382C203235355D2C20676F6C64';
wwv_flow_imp.g_varchar2_table(43) := '3A205B3235352C203231352C20305D2C20676F6C64656E726F643A205B3231382C203136352C2033325D2C20677261793A205B3132382C203132382C203132385D2C20677265656E3A205B302C203132382C20305D2C20677265656E79656C6C6F773A20';
wwv_flow_imp.g_varchar2_table(44) := '5B3137332C203235352C2034375D2C20677265793A205B3132382C203132382C203132385D2C20686F6E65796465773A205B3234302C203235352C203234305D2C20686F7470696E6B3A205B3235352C203130352C203138305D2C20696E6469616E7265';
wwv_flow_imp.g_varchar2_table(45) := '643A205B3230352C2039322C2039325D2C20696E6469676F3A205B37352C20302C203133305D2C2069766F72793A205B3235352C203235352C203234305D2C206B68616B693A205B3234302C203233302C203134305D2C206C6176656E6465723A205B32';
wwv_flow_imp.g_varchar2_table(46) := '33302C203233302C203235305D2C206C6176656E646572626C7573683A205B3235352C203234302C203234355D2C206C61776E677265656E3A205B3132342C203235322C20305D2C206C656D6F6E63686966666F6E3A205B3235352C203235302C203230';
wwv_flow_imp.g_varchar2_table(47) := '355D2C206C69676874626C75653A205B3137332C203231362C203233305D2C206C69676874636F72616C3A205B3234302C203132382C203132385D2C206C696768746379616E3A205B3232342C203235352C203235355D2C206C69676874676F6C64656E';
wwv_flow_imp.g_varchar2_table(48) := '726F6479656C6C6F773A205B3235302C203235302C203231305D2C206C69676874677261793A205B3231312C203231312C203231315D2C206C69676874677265656E3A205B3134342C203233382C203134345D2C206C69676874677265793A205B323131';
wwv_flow_imp.g_varchar2_table(49) := '2C203231312C203231315D2C206C6967687470696E6B3A205B3235352C203138322C203139335D2C206C6967687473616C6D6F6E3A205B3235352C203136302C203132325D2C206C69676874736561677265656E3A205B33322C203137382C203137305D';
wwv_flow_imp.g_varchar2_table(50) := '2C206C69676874736B79626C75653A205B3133352C203230362C203235305D2C206C69676874736C617465677261793A205B3131392C203133362C203135335D2C206C69676874736C617465677265793A205B3131392C203133362C203135335D2C206C';
wwv_flow_imp.g_varchar2_table(51) := '69676874737465656C626C75653A205B3137362C203139362C203232325D2C206C6967687479656C6C6F773A205B3235352C203235352C203232345D2C206C696D653A205B302C203235352C20305D2C206C696D65677265656E3A205B35302C20323035';
wwv_flow_imp.g_varchar2_table(52) := '2C2035305D2C206C696E656E3A205B3235302C203234302C203233305D2C206D6167656E74613A205B3235352C20302C203235355D2C206D61726F6F6E3A205B3132382C20302C20305D2C206D656469756D617175616D6172696E653A205B3130322C20';
wwv_flow_imp.g_varchar2_table(53) := '3230352C203137305D2C206D656469756D626C75653A205B302C20302C203230355D2C206D656469756D6F72636869643A205B3138362C2038352C203231315D2C206D656469756D707572706C653A205B3134372C203131322C203231395D2C206D6564';
wwv_flow_imp.g_varchar2_table(54) := '69756D736561677265656E3A205B36302C203137392C203131335D2C206D656469756D736C617465626C75653A205B3132332C203130342C203233385D2C206D656469756D737072696E67677265656E3A205B302C203235302C203135345D2C206D6564';
wwv_flow_imp.g_varchar2_table(55) := '69756D74757271756F6973653A205B37322C203230392C203230345D2C206D656469756D76696F6C65747265643A205B3139392C2032312C203133335D2C206D69646E69676874626C75653A205B32352C2032352C203131325D2C206D696E7463726561';
wwv_flow_imp.g_varchar2_table(56) := '6D3A205B3234352C203235352C203235305D2C206D69737479726F73653A205B3235352C203232382C203232355D2C206D6F63636173696E3A205B3235352C203232382C203138315D2C206E6176616A6F77686974653A205B3235352C203232322C2031';
wwv_flow_imp.g_varchar2_table(57) := '37335D2C206E6176793A205B302C20302C203132385D2C206F6C646C6163653A205B3235332C203234352C203233305D2C206F6C6976653A205B3132382C203132382C20305D2C206F6C697665647261623A205B3130372C203134322C2033355D2C206F';
wwv_flow_imp.g_varchar2_table(58) := '72616E67653A205B3235352C203136352C20305D2C206F72616E67657265643A205B3235352C2036392C20305D2C206F72636869643A205B3231382C203131322C203231345D2C2070616C65676F6C64656E726F643A205B3233382C203233322C203137';
wwv_flow_imp.g_varchar2_table(59) := '305D2C2070616C65677265656E3A205B3135322C203235312C203135325D2C2070616C6574757271756F6973653A205B3137352C203233382C203233385D2C2070616C6576696F6C65747265643A205B3231392C203131322C203134375D2C2070617061';
wwv_flow_imp.g_varchar2_table(60) := '7961776869703A205B3235352C203233392C203231335D2C207065616368707566663A205B3235352C203231382C203138355D2C20706572753A205B3230352C203133332C2036335D2C2070696E6B3A205B3235352C203139322C203230335D2C20706C';
wwv_flow_imp.g_varchar2_table(61) := '756D3A205B3232312C203136302C203232315D2C20706F77646572626C75653A205B3137362C203232342C203233305D2C20707572706C653A205B3132382C20302C203132385D2C2072656265636361707572706C653A205B3130322C2035312C203135';
wwv_flow_imp.g_varchar2_table(62) := '335D2C207265643A205B3235352C20302C20305D2C20726F737962726F776E3A205B3138382C203134332C203134335D2C20726F79616C626C75653A205B36352C203130352C203232355D2C20736164646C6562726F776E3A205B3133392C2036392C20';
wwv_flow_imp.g_varchar2_table(63) := '31395D2C2073616C6D6F6E3A205B3235302C203132382C203131345D2C2073616E647962726F776E3A205B3234342C203136342C2039365D2C20736561677265656E3A205B34362C203133392C2038375D2C207365617368656C6C3A205B3235352C2032';
wwv_flow_imp.g_varchar2_table(64) := '34352C203233385D2C207369656E6E613A205B3136302C2038322C2034355D2C2073696C7665723A205B3139322C203139322C203139325D2C20736B79626C75653A205B3133352C203230362C203233355D2C20736C617465626C75653A205B3130362C';
wwv_flow_imp.g_varchar2_table(65) := '2039302C203230355D2C20736C617465677261793A205B3131322C203132382C203134345D2C20736C617465677265793A205B3131322C203132382C203134345D2C20736E6F773A205B3235352C203235302C203235305D2C20737072696E6767726565';
wwv_flow_imp.g_varchar2_table(66) := '6E3A205B302C203235352C203132375D2C20737465656C626C75653A205B37302C203133302C203138305D2C2074616E3A205B3231302C203138302C203134305D2C207465616C3A205B302C203132382C203132385D2C2074686973746C653A205B3231';
wwv_flow_imp.g_varchar2_table(67) := '362C203139312C203231365D2C20746F6D61746F3A205B3235352C2039392C2037315D2C2074757271756F6973653A205B36342C203232342C203230385D2C2076696F6C65743A205B3233382C203133302C203233385D2C2077686561743A205B323435';
wwv_flow_imp.g_varchar2_table(68) := '2C203232322C203137395D2C2077686974653A205B3235352C203235352C203235355D2C207768697465736D6F6B653A205B3234352C203234352C203234355D2C2079656C6C6F773A205B3235352C203235352C20305D2C2079656C6C6F77677265656E';
wwv_flow_imp.g_varchar2_table(69) := '3A205B3135342C203230352C2035305D207D3B0D0A0D0A2020636F6E7374207061727365436F6C6F72203D20286329203D3E207B0D0A20202020696620286320696E204E414D45445F434F4C4F525329207B0D0A20202020202072657475726E205B2E2E';
wwv_flow_imp.g_varchar2_table(70) := '2E4E414D45445F434F4C4F52535B635D2C203235355D3B0D0A202020207D0D0A0D0A202020206C6574206D617463683B0D0A202020206966202841727261792E6973417272617928632920262620632E6C656E677468203D3D3D203329207B0D0A202020';
wwv_flow_imp.g_varchar2_table(71) := '20202072657475726E205B2E2E2E632C203235355D3B0D0A202020207D20656C7365206966202841727261792E6973417272617928632920262620632E6C656E677468203D3D3D203429207B0D0A20202020202072657475726E20633B0D0A202020207D';
wwv_flow_imp.g_varchar2_table(72) := '20656C73652069662028286D61746368203D20632E6D61746368282F5E23285B412D46612D66302D395D7B367D29242F292929207B0D0A2020202020202F2F20726567756C61722068657820666F726D61740D0A20202020202072657475726E205B0D0A';
wwv_flow_imp.g_varchar2_table(73) := '20202020202020207061727365496E74286D617463685B315D2E73756273747228302C2032292C203136292C0D0A20202020202020207061727365496E74286D617463685B315D2E73756273747228322C2032292C203136292C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(74) := '7061727365496E74286D617463685B315D2E73756273747228342C2032292C203136292C0D0A20202020202020203235352C0D0A2020202020205D3B0D0A202020207D20656C73652069662028286D61746368203D20632E6D61746368282F5E23285B41';
wwv_flow_imp.g_varchar2_table(75) := '2D46612D66302D395D7B337D29242F292929207B0D0A2020202020202F2F2073686F727465722068657820666F726D61740D0A20202020202072657475726E205B0D0A20202020202020207061727365496E74286D617463685B315D5B305D2C20313629';
wwv_flow_imp.g_varchar2_table(76) := '202A20307831312C0D0A20202020202020207061727365496E74286D617463685B315D5B315D2C20313629202A20307831312C0D0A20202020202020207061727365496E74286D617463685B315D5B325D2C20313629202A20307831312C0D0A20202020';
wwv_flow_imp.g_varchar2_table(77) := '202020203235352C0D0A2020202020205D3B0D0A202020207D20656C73652069662028286D61746368203D20632E6D61746368282F5E23285B412D46612D66302D395D7B387D29242F292929207B0D0A2020202020202F2F20726567756C617220686578';
wwv_flow_imp.g_varchar2_table(78) := '20666F726D6174207769746820616C7068610D0A20202020202072657475726E205B0D0A20202020202020207061727365496E74286D617463685B315D2E73756273747228302C2032292C203136292C0D0A20202020202020207061727365496E74286D';
wwv_flow_imp.g_varchar2_table(79) := '617463685B315D2E73756273747228322C2032292C203136292C0D0A20202020202020207061727365496E74286D617463685B315D2E73756273747228342C2032292C203136292C0D0A20202020202020207061727365496E74286D617463685B315D2E';
wwv_flow_imp.g_varchar2_table(80) := '73756273747228362C2032292C203136292C0D0A2020202020205D3B0D0A202020207D20656C73652069662028286D61746368203D20632E6D61746368282F5E23285B412D46612D66302D395D7B347D29242F292929207B0D0A2020202020202F2F2073';
wwv_flow_imp.g_varchar2_table(81) := '686F727465722068657820666F726D6174207769746820616C7068610D0A20202020202072657475726E205B0D0A20202020202020207061727365496E74286D617463685B315D5B305D2C20313629202A20307831312C0D0A2020202020202020706172';
wwv_flow_imp.g_varchar2_table(82) := '7365496E74286D617463685B315D5B315D2C20313629202A20307831312C0D0A20202020202020207061727365496E74286D617463685B315D5B325D2C20313629202A20307831312C0D0A20202020202020207061727365496E74286D617463685B315D';
wwv_flow_imp.g_varchar2_table(83) := '5B335D2C20313629202A20307831312C0D0A2020202020205D3B0D0A202020207D20656C7365207B0D0A20202020202072657475726E206E756C6C3B0D0A202020207D0D0A20207D3B0D0A0D0A2020636F6E7374206261636B67726F756E64436F6C6F72';
wwv_flow_imp.g_varchar2_table(84) := '203D20705F6267636F6C6F72203F207061727365436F6C6F7228705F6267636F6C6F7229203A206E756C6C3B0D0A0D0A20206C657420636F6C6F7252616D703B0D0A2020636F6E73742072656672657368436F6C6F7252616D70203D202829203D3E207B';
wwv_flow_imp.g_varchar2_table(85) := '0D0A202020206966202821705F7465727261696E5F66656174757265732E696E636C756465732827636F6C6F722D72656C6965662729207C7C20726173746572696E666F2E6E6F52617374657229207B0D0A20202020202072657475726E3B0D0A202020';
wwv_flow_imp.g_varchar2_table(86) := '207D0D0A0D0A20202020636F6E7374206275696C74696E203D207B0D0A2020202020202F2F2046726F6D203C68747470733A2F2F6769746875622E636F6D2F736A6D6761726E6965722F766972696469734C6974653E2E204D49542E0D0A202020202020';
wwv_flow_imp.g_varchar2_table(87) := '6D61676D613A205B5B302C302C345D2C5B312C302C355D2C5B312C312C365D2C5B312C312C385D2C5B322C312C395D2C5B322C322C31315D2C5B322C322C31335D2C5B332C332C31355D2C5B332C332C31385D2C5B342C342C32305D2C5B352C342C3232';
wwv_flow_imp.g_varchar2_table(88) := '5D2C5B362C352C32345D2C5B362C352C32365D2C5B372C362C32385D2C5B382C372C33305D2C5B392C372C33325D2C5B31302C382C33345D2C5B31312C392C33365D2C5B31322C392C33385D2C5B31332C31302C34315D2C5B31342C31312C34335D2C5B';
wwv_flow_imp.g_varchar2_table(89) := '31362C31312C34355D2C5B31372C31322C34375D2C5B31382C31332C34395D2C5B31392C31332C35325D2C5B32302C31342C35345D2C5B32312C31342C35365D2C5B32322C31352C35395D2C5B32342C31352C36315D2C5B32352C31362C36335D2C5B32';
wwv_flow_imp.g_varchar2_table(90) := '362C31362C36365D2C5B32382C31362C36385D2C5B32392C31372C37315D2C5B33302C31372C37335D2C5B33322C31372C37355D2C5B33332C31372C37385D2C5B33342C31372C38305D2C5B33362C31382C38335D2C5B33372C31382C38355D2C5B3339';
wwv_flow_imp.g_varchar2_table(91) := '2C31382C38385D2C5B34312C31372C39305D2C5B34322C31372C39325D2C5B34342C31372C39355D2C5B34352C31372C39375D2C5B34372C31372C39395D2C5B34392C31372C3130315D2C5B35312C31362C3130335D2C5B35322C31362C3130355D2C5B';
wwv_flow_imp.g_varchar2_table(92) := '35342C31362C3130375D2C5B35362C31362C3130385D2C5B35372C31352C3131305D2C5B35392C31352C3131325D2C5B36312C31352C3131335D2C5B36332C31352C3131345D2C5B36342C31352C3131365D2C5B36362C31352C3131375D2C5B36382C31';
wwv_flow_imp.g_varchar2_table(93) := '352C3131385D2C5B36392C31362C3131395D2C5B37312C31362C3132305D2C5B37332C31362C3132305D2C5B37342C31362C3132315D2C5B37362C31372C3132325D2C5B37382C31372C3132335D2C5B37392C31382C3132335D2C5B38312C31382C3132';
wwv_flow_imp.g_varchar2_table(94) := '345D2C5B38322C31392C3132345D2C5B38342C31392C3132355D2C5B38362C32302C3132355D2C5B38372C32312C3132365D2C5B38392C32312C3132365D2C5B39302C32322C3132365D2C5B39322C32322C3132375D2C5B39332C32332C3132375D2C5B';
wwv_flow_imp.g_varchar2_table(95) := '39352C32342C3132375D2C5B39362C32342C3132385D2C5B39382C32352C3132385D2C5B3130302C32362C3132385D2C5B3130312C32362C3132385D2C5B3130332C32372C3132385D2C5B3130342C32382C3132395D2C5B3130362C32382C3132395D2C';
wwv_flow_imp.g_varchar2_table(96) := '5B3130372C32392C3132395D2C5B3130392C32392C3132395D2C5B3131302C33302C3132395D2C5B3131322C33312C3132395D2C5B3131342C33312C3132395D2C5B3131352C33322C3132395D2C5B3131372C33332C3132395D2C5B3131382C33332C31';
wwv_flow_imp.g_varchar2_table(97) := '32395D2C5B3132302C33342C3132395D2C5B3132312C33342C3133305D2C5B3132332C33352C3133305D2C5B3132342C33352C3133305D2C5B3132362C33362C3133305D2C5B3132382C33372C3133305D2C5B3132392C33372C3132395D2C5B3133312C';
wwv_flow_imp.g_varchar2_table(98) := '33382C3132395D2C5B3133322C33382C3132395D2C5B3133342C33392C3132395D2C5B3133362C33392C3132395D2C5B3133372C34302C3132395D2C5B3133392C34312C3132395D2C5B3134302C34312C3132395D2C5B3134322C34322C3132395D2C5B';
wwv_flow_imp.g_varchar2_table(99) := '3134342C34322C3132395D2C5B3134352C34332C3132395D2C5B3134372C34332C3132385D2C5B3134382C34342C3132385D2C5B3135302C34342C3132385D2C5B3135322C34352C3132385D2C5B3135332C34352C3132385D2C5B3135352C34362C3132';
wwv_flow_imp.g_varchar2_table(100) := '375D2C5B3135362C34362C3132375D2C5B3135382C34372C3132375D2C5B3136302C34372C3132375D2C5B3136312C34382C3132365D2C5B3136332C34382C3132365D2C5B3136352C34392C3132365D2C5B3136362C34392C3132355D2C5B3136382C35';
wwv_flow_imp.g_varchar2_table(101) := '302C3132355D2C5B3137302C35312C3132355D2C5B3137312C35312C3132345D2C5B3137332C35322C3132345D2C5B3137342C35322C3132335D2C5B3137362C35332C3132335D2C5B3137382C35332C3132335D2C5B3137392C35342C3132325D2C5B31';
wwv_flow_imp.g_varchar2_table(102) := '38312C35342C3132325D2C5B3138332C35352C3132315D2C5B3138342C35352C3132315D2C5B3138362C35362C3132305D2C5B3138382C35372C3132305D2C5B3138392C35372C3131395D2C5B3139312C35382C3131395D2C5B3139322C35382C313138';
wwv_flow_imp.g_varchar2_table(103) := '5D2C5B3139342C35392C3131375D2C5B3139362C36302C3131375D2C5B3139372C36302C3131365D2C5B3139392C36312C3131355D2C5B3230302C36322C3131355D2C5B3230322C36322C3131345D2C5B3230342C36332C3131335D2C5B3230352C3634';
wwv_flow_imp.g_varchar2_table(104) := '2C3131335D2C5B3230372C36342C3131325D2C5B3230382C36352C3131315D2C5B3231302C36362C3131315D2C5B3231312C36372C3131305D2C5B3231332C36382C3130395D2C5B3231342C36392C3130385D2C5B3231362C36392C3130385D2C5B3231';
wwv_flow_imp.g_varchar2_table(105) := '372C37302C3130375D2C5B3231392C37312C3130365D2C5B3232302C37322C3130355D2C5B3232322C37332C3130345D2C5B3232332C37342C3130345D2C5B3232342C37362C3130335D2C5B3232362C37372C3130325D2C5B3232372C37382C3130315D';
wwv_flow_imp.g_varchar2_table(106) := '2C5B3232382C37392C3130305D2C5B3232392C38302C3130305D2C5B3233312C38322C39395D2C5B3233322C38332C39385D2C5B3233332C38342C39385D2C5B3233342C38362C39375D2C5B3233352C38372C39365D2C5B3233362C38382C39365D2C5B';
wwv_flow_imp.g_varchar2_table(107) := '3233372C39302C39355D2C5B3233382C39312C39345D2C5B3233392C39332C39345D2C5B3234302C39352C39345D2C5B3234312C39362C39335D2C5B3234322C39382C39335D2C5B3234322C3130302C39325D2C5B3234332C3130312C39325D2C5B3234';
wwv_flow_imp.g_varchar2_table(108) := '342C3130332C39325D2C5B3234342C3130352C39325D2C5B3234352C3130372C39325D2C5B3234362C3130382C39325D2C5B3234362C3131302C39325D2C5B3234372C3131322C39325D2C5B3234372C3131342C39325D2C5B3234382C3131362C39325D';
wwv_flow_imp.g_varchar2_table(109) := '2C5B3234382C3131382C39325D2C5B3234392C3132302C39335D2C5B3234392C3132312C39335D2C5B3234392C3132332C39335D2C5B3235302C3132352C39345D2C5B3235302C3132372C39345D2C5B3235302C3132392C39355D2C5B3235312C313331';
wwv_flow_imp.g_varchar2_table(110) := '2C39355D2C5B3235312C3133332C39365D2C5B3235312C3133352C39375D2C5B3235322C3133372C39375D2C5B3235322C3133382C39385D2C5B3235322C3134302C39395D2C5B3235322C3134322C3130305D2C5B3235322C3134342C3130315D2C5B32';
wwv_flow_imp.g_varchar2_table(111) := '35332C3134362C3130325D2C5B3235332C3134382C3130335D2C5B3235332C3135302C3130345D2C5B3235332C3135322C3130355D2C5B3235332C3135342C3130365D2C5B3235332C3135352C3130375D2C5B3235342C3135372C3130385D2C5B323534';
wwv_flow_imp.g_varchar2_table(112) := '2C3135392C3130395D2C5B3235342C3136312C3131305D2C5B3235342C3136332C3131315D2C5B3235342C3136352C3131335D2C5B3235342C3136372C3131345D2C5B3235342C3136392C3131355D2C5B3235342C3137302C3131365D2C5B3235342C31';
wwv_flow_imp.g_varchar2_table(113) := '37322C3131385D2C5B3235342C3137342C3131395D2C5B3235342C3137362C3132305D2C5B3235342C3137382C3132325D2C5B3235342C3138302C3132335D2C5B3235342C3138322C3132345D2C5B3235342C3138332C3132365D2C5B3235342C313835';
wwv_flow_imp.g_varchar2_table(114) := '2C3132375D2C5B3235342C3138372C3132395D2C5B3235342C3138392C3133305D2C5B3235342C3139312C3133325D2C5B3235342C3139332C3133335D2C5B3235342C3139342C3133355D2C5B3235342C3139362C3133365D2C5B3235342C3139382C31';
wwv_flow_imp.g_varchar2_table(115) := '33385D2C5B3235342C3230302C3134305D2C5B3235342C3230322C3134315D2C5B3235342C3230342C3134335D2C5B3235342C3230352C3134345D2C5B3235342C3230372C3134365D2C5B3235342C3230392C3134385D2C5B3235342C3231312C313439';
wwv_flow_imp.g_varchar2_table(116) := '5D2C5B3235342C3231332C3135315D2C5B3235342C3231352C3135335D2C5B3235342C3231362C3135345D2C5B3235332C3231382C3135365D2C5B3235332C3232302C3135385D2C5B3235332C3232322C3136305D2C5B3235332C3232342C3136315D2C';
wwv_flow_imp.g_varchar2_table(117) := '5B3235332C3232362C3136335D2C5B3235332C3232372C3136355D2C5B3235332C3232392C3136375D2C5B3235332C3233312C3136395D2C5B3235332C3233332C3137305D2C5B3235332C3233352C3137325D2C5B3235322C3233362C3137345D2C5B32';
wwv_flow_imp.g_varchar2_table(118) := '35322C3233382C3137365D2C5B3235322C3234302C3137385D2C5B3235322C3234322C3138305D2C5B3235322C3234342C3138325D2C5B3235322C3234362C3138345D2C5B3235322C3234372C3138355D2C5B3235322C3234392C3138375D2C5B323532';
wwv_flow_imp.g_varchar2_table(119) := '2C3235312C3138395D2C5B3235322C3235332C3139315D2C5D2C0D0A202020202020696E6665726E6F3A205B5B302C302C345D2C5B312C302C355D2C5B312C312C365D2C5B312C312C385D2C5B322C312C31305D2C5B322C322C31325D2C5B322C322C31';
wwv_flow_imp.g_varchar2_table(120) := '345D2C5B332C322C31365D2C5B342C332C31385D2C5B342C332C32305D2C5B352C342C32335D2C5B362C342C32355D2C5B372C352C32375D2C5B382C352C32395D2C5B392C362C33315D2C5B31302C372C33345D2C5B31312C372C33365D2C5B31322C38';
wwv_flow_imp.g_varchar2_table(121) := '2C33385D2C5B31332C382C34315D2C5B31342C392C34335D2C5B31362C392C34355D2C5B31372C31302C34385D2C5B31382C31302C35305D2C5B32302C31312C35325D2C5B32312C31312C35355D2C5B32322C31312C35375D2C5B32342C31322C36305D';
wwv_flow_imp.g_varchar2_table(122) := '2C5B32352C31322C36325D2C5B32372C31322C36355D2C5B32382C31322C36375D2C5B33302C31322C36395D2C5B33312C31322C37325D2C5B33332C31322C37345D2C5B33352C31322C37365D2C5B33362C31322C37395D2C5B33382C31322C38315D2C';
wwv_flow_imp.g_varchar2_table(123) := '5B34302C31312C38335D2C5B34312C31312C38355D2C5B34332C31312C38375D2C5B34352C31312C38395D2C5B34372C31302C39315D2C5B34392C31302C39325D2C5B35302C31302C39345D2C5B35322C31302C39355D2C5B35342C392C39375D2C5B35';
wwv_flow_imp.g_varchar2_table(124) := '362C392C39385D2C5B35372C392C39395D2C5B35392C392C3130305D2C5B36312C392C3130315D2C5B36322C392C3130325D2C5B36342C31302C3130335D2C5B36362C31302C3130345D2C5B36382C31302C3130345D2C5B36392C31302C3130355D2C5B';
wwv_flow_imp.g_varchar2_table(125) := '37312C31312C3130365D2C5B37332C31312C3130365D2C5B37342C31322C3130375D2C5B37362C31322C3130375D2C5B37372C31332C3130385D2C5B37392C31332C3130385D2C5B38312C31342C3130385D2C5B38322C31342C3130395D2C5B38342C31';
wwv_flow_imp.g_varchar2_table(126) := '352C3130395D2C5B38352C31352C3130395D2C5B38372C31362C3131305D2C5B38392C31362C3131305D2C5B39302C31372C3131305D2C5B39322C31382C3131305D2C5B39332C31382C3131305D2C5B39352C31392C3131305D2C5B39372C31392C3131';
wwv_flow_imp.g_varchar2_table(127) := '305D2C5B39382C32302C3131305D2C5B3130302C32312C3131305D2C5B3130312C32312C3131305D2C5B3130332C32322C3131305D2C5B3130352C32322C3131305D2C5B3130362C32332C3131305D2C5B3130382C32342C3131305D2C5B3130392C3234';
wwv_flow_imp.g_varchar2_table(128) := '2C3131305D2C5B3131312C32352C3131305D2C5B3131332C32352C3131305D2C5B3131342C32362C3131305D2C5B3131362C32362C3131305D2C5B3131372C32372C3131305D2C5B3131392C32382C3130395D2C5B3132302C32382C3130395D2C5B3132';
wwv_flow_imp.g_varchar2_table(129) := '322C32392C3130395D2C5B3132342C32392C3130395D2C5B3132352C33302C3130395D2C5B3132372C33302C3130385D2C5B3132382C33312C3130385D2C5B3133302C33322C3130385D2C5B3133322C33322C3130375D2C5B3133332C33332C3130375D';
wwv_flow_imp.g_varchar2_table(130) := '2C5B3133352C33332C3130375D2C5B3133362C33342C3130365D2C5B3133382C33342C3130365D2C5B3134302C33352C3130355D2C5B3134312C33352C3130355D2C5B3134332C33362C3130355D2C5B3134342C33372C3130345D2C5B3134362C33372C';
wwv_flow_imp.g_varchar2_table(131) := '3130345D2C5B3134372C33382C3130335D2C5B3134392C33382C3130335D2C5B3135312C33392C3130325D2C5B3135322C33392C3130325D2C5B3135342C34302C3130315D2C5B3135352C34312C3130305D2C5B3135372C34312C3130305D2C5B313539';
wwv_flow_imp.g_varchar2_table(132) := '2C34322C39395D2C5B3136302C34322C39395D2C5B3136322C34332C39385D2C5B3136332C34342C39375D2C5B3136352C34342C39365D2C5B3136362C34352C39365D2C5B3136382C34362C39355D2C5B3136392C34362C39345D2C5B3137312C34372C';
wwv_flow_imp.g_varchar2_table(133) := '39345D2C5B3137332C34382C39335D2C5B3137342C34382C39325D2C5B3137362C34392C39315D2C5B3137372C35302C39305D2C5B3137392C35302C39305D2C5B3138302C35312C38395D2C5B3138322C35322C38385D2C5B3138332C35332C38375D2C';
wwv_flow_imp.g_varchar2_table(134) := '5B3138352C35332C38365D2C5B3138362C35342C38355D2C5B3138382C35352C38345D2C5B3138392C35362C38335D2C5B3139312C35372C38325D2C5B3139322C35382C38315D2C5B3139332C35382C38305D2C5B3139352C35392C37395D2C5B313936';
wwv_flow_imp.g_varchar2_table(135) := '2C36302C37385D2C5B3139382C36312C37375D2C5B3139392C36322C37365D2C5B3230302C36332C37355D2C5B3230322C36342C37345D2C5B3230332C36352C37335D2C5B3230342C36362C37325D2C5B3230362C36372C37315D2C5B3230372C36382C';
wwv_flow_imp.g_varchar2_table(136) := '37305D2C5B3230382C36392C36395D2C5B3231302C37302C36385D2C5B3231312C37312C36375D2C5B3231322C37322C36365D2C5B3231332C37342C36355D2C5B3231352C37352C36335D2C5B3231362C37362C36325D2C5B3231372C37372C36315D2C';
wwv_flow_imp.g_varchar2_table(137) := '5B3231382C37382C36305D2C5B3231392C38302C35395D2C5B3232312C38312C35385D2C5B3232322C38322C35365D2C5B3232332C38332C35355D2C5B3232342C38352C35345D2C5B3232352C38362C35335D2C5B3232362C38372C35325D2C5B323237';
wwv_flow_imp.g_varchar2_table(138) := '2C38392C35315D2C5B3232382C39302C34395D2C5B3232392C39322C34385D2C5B3233302C39332C34375D2C5B3233312C39342C34365D2C5B3233322C39362C34355D2C5B3233332C39372C34335D2C5B3233342C39392C34325D2C5B3233352C313030';
wwv_flow_imp.g_varchar2_table(139) := '2C34315D2C5B3233352C3130322C34305D2C5B3233362C3130332C33385D2C5B3233372C3130352C33375D2C5B3233382C3130362C33365D2C5B3233392C3130382C33355D2C5B3233392C3131302C33335D2C5B3234302C3131312C33325D2C5B323431';
wwv_flow_imp.g_varchar2_table(140) := '2C3131332C33315D2C5B3234312C3131352C32395D2C5B3234322C3131362C32385D2C5B3234332C3131382C32375D2C5B3234332C3132302C32355D2C5B3234342C3132312C32345D2C5B3234352C3132332C32335D2C5B3234352C3132352C32315D2C';
wwv_flow_imp.g_varchar2_table(141) := '5B3234362C3132362C32305D2C5B3234362C3132382C31395D2C5B3234372C3133302C31385D2C5B3234372C3133322C31365D2C5B3234382C3133332C31355D2C5B3234382C3133352C31345D2C5B3234382C3133372C31325D2C5B3234392C3133392C';
wwv_flow_imp.g_varchar2_table(142) := '31315D2C5B3234392C3134302C31305D2C5B3234392C3134322C395D2C5B3235302C3134342C385D2C5B3235302C3134362C375D2C5B3235302C3134382C375D2C5B3235312C3135302C365D2C5B3235312C3135312C365D2C5B3235312C3135332C365D';
wwv_flow_imp.g_varchar2_table(143) := '2C5B3235312C3135352C365D2C5B3235312C3135372C375D2C5B3235322C3135392C375D2C5B3235322C3136312C385D2C5B3235322C3136332C395D2C5B3235322C3136352C31305D2C5B3235322C3136362C31325D2C5B3235322C3136382C31335D2C';
wwv_flow_imp.g_varchar2_table(144) := '5B3235322C3137302C31355D2C5B3235322C3137322C31375D2C5B3235322C3137342C31385D2C5B3235322C3137362C32305D2C5B3235322C3137382C32325D2C5B3235322C3138302C32345D2C5B3235312C3138322C32365D2C5B3235312C3138342C';
wwv_flow_imp.g_varchar2_table(145) := '32395D2C5B3235312C3138362C33315D2C5B3235312C3138382C33335D2C5B3235312C3139302C33355D2C5B3235302C3139322C33385D2C5B3235302C3139342C34305D2C5B3235302C3139362C34325D2C5B3235302C3139382C34355D2C5B3234392C';
wwv_flow_imp.g_varchar2_table(146) := '3139392C34375D2C5B3234392C3230312C35305D2C5B3234392C3230332C35335D2C5B3234382C3230352C35355D2C5B3234382C3230372C35385D2C5B3234372C3230392C36315D2C5B3234372C3231312C36345D2C5B3234362C3231332C36375D2C5B';
wwv_flow_imp.g_varchar2_table(147) := '3234362C3231352C37305D2C5B3234352C3231372C37335D2C5B3234352C3231392C37365D2C5B3234342C3232312C37395D2C5B3234342C3232332C38335D2C5B3234342C3232352C38365D2C5B3234332C3232372C39305D2C5B3234332C3232392C39';
wwv_flow_imp.g_varchar2_table(148) := '335D2C5B3234322C3233302C39375D2C5B3234322C3233322C3130315D2C5B3234322C3233342C3130355D2C5B3234312C3233362C3130395D2C5B3234312C3233372C3131335D2C5B3234312C3233392C3131375D2C5B3234312C3234312C3132315D2C';
wwv_flow_imp.g_varchar2_table(149) := '5B3234322C3234322C3132355D2C5B3234322C3234342C3133305D2C5B3234332C3234352C3133345D2C5B3234332C3234362C3133385D2C5B3234342C3234382C3134325D2C5B3234352C3234392C3134365D2C5B3234362C3235302C3135305D2C5B32';
wwv_flow_imp.g_varchar2_table(150) := '34382C3235312C3135345D2C5B3234392C3235322C3135375D2C5B3235302C3235332C3136315D2C5B3235322C3235352C3136345D2C5D2C0D0A202020202020706C61736D613A205B5B31332C382C3133355D2C5B31362C372C3133365D2C5B31392C37';
wwv_flow_imp.g_varchar2_table(151) := '2C3133375D2C5B32322C372C3133385D2C5B32352C362C3134305D2C5B32372C362C3134315D2C5B32392C362C3134325D2C5B33322C362C3134335D2C5B33342C362C3134345D2C5B33362C362C3134355D2C5B33382C352C3134355D2C5B34302C352C';
wwv_flow_imp.g_varchar2_table(152) := '3134365D2C5B34322C352C3134375D2C5B34342C352C3134385D2C5B34362C352C3134395D2C5B34372C352C3135305D2C5B34392C352C3135315D2C5B35312C352C3135315D2C5B35332C342C3135325D2C5B35352C342C3135335D2C5B35362C342C31';
wwv_flow_imp.g_varchar2_table(153) := '35345D2C5B35382C342C3135345D2C5B36302C342C3135355D2C5B36322C342C3135365D2C5B36332C342C3135365D2C5B36352C342C3135375D2C5B36372C332C3135385D2C5B36382C332C3135385D2C5B37302C332C3135395D2C5B37322C332C3135';
wwv_flow_imp.g_varchar2_table(154) := '395D2C5B37332C332C3136305D2C5B37352C332C3136315D2C5B37362C322C3136315D2C5B37382C322C3136325D2C5B38302C322C3136325D2C5B38312C322C3136335D2C5B38332C322C3136335D2C5B38352C322C3136345D2C5B38362C312C313634';
wwv_flow_imp.g_varchar2_table(155) := '5D2C5B38382C312C3136345D2C5B38392C312C3136355D2C5B39312C312C3136355D2C5B39322C312C3136365D2C5B39342C312C3136365D2C5B39362C312C3136365D2C5B39372C302C3136375D2C5B39392C302C3136375D2C5B3130302C302C313637';
wwv_flow_imp.g_varchar2_table(156) := '5D2C5B3130322C302C3136375D2C5B3130332C302C3136385D2C5B3130352C302C3136385D2C5B3130362C302C3136385D2C5B3130382C302C3136385D2C5B3131302C302C3136385D2C5B3131312C302C3136385D2C5B3131332C302C3136385D2C5B31';
wwv_flow_imp.g_varchar2_table(157) := '31342C312C3136385D2C5B3131362C312C3136385D2C5B3131372C312C3136385D2C5B3131392C312C3136385D2C5B3132302C312C3136385D2C5B3132322C322C3136385D2C5B3132332C322C3136385D2C5B3132352C332C3136385D2C5B3132362C33';
wwv_flow_imp.g_varchar2_table(158) := '2C3136385D2C5B3132382C342C3136385D2C5B3132392C342C3136375D2C5B3133312C352C3136375D2C5B3133322C352C3136375D2C5B3133342C362C3136365D2C5B3133352C372C3136365D2C5B3133362C382C3136365D2C5B3133382C392C313635';
wwv_flow_imp.g_varchar2_table(159) := '5D2C5B3133392C31302C3136355D2C5B3134312C31312C3136355D2C5B3134322C31322C3136345D2C5B3134332C31332C3136345D2C5B3134352C31342C3136335D2C5B3134362C31352C3136335D2C5B3134382C31362C3136325D2C5B3134392C3137';
wwv_flow_imp.g_varchar2_table(160) := '2C3136315D2C5B3135302C31392C3136315D2C5B3135322C32302C3136305D2C5B3135332C32312C3135395D2C5B3135342C32322C3135395D2C5B3135362C32332C3135385D2C5B3135372C32342C3135375D2C5B3135382C32352C3135375D2C5B3136';
wwv_flow_imp.g_varchar2_table(161) := '302C32362C3135365D2C5B3136312C32372C3135355D2C5B3136322C32392C3135345D2C5B3136332C33302C3135345D2C5B3136352C33312C3135335D2C5B3136362C33322C3135325D2C5B3136372C33332C3135315D2C5B3136382C33342C3135305D';
wwv_flow_imp.g_varchar2_table(162) := '2C5B3137302C33352C3134395D2C5B3137312C33362C3134385D2C5B3137322C33382C3134385D2C5B3137332C33392C3134375D2C5B3137342C34302C3134365D2C5B3137362C34312C3134355D2C5B3137372C34322C3134345D2C5B3137382C34332C';
wwv_flow_imp.g_varchar2_table(163) := '3134335D2C5B3137392C34342C3134325D2C5B3138302C34362C3134315D2C5B3138312C34372C3134305D2C5B3138322C34382C3133395D2C5B3138332C34392C3133385D2C5B3138342C35302C3133375D2C5B3138362C35312C3133365D2C5B313837';
wwv_flow_imp.g_varchar2_table(164) := '2C35322C3133365D2C5B3138382C35332C3133355D2C5B3138392C35352C3133345D2C5B3139302C35362C3133335D2C5B3139312C35372C3133325D2C5B3139322C35382C3133315D2C5B3139332C35392C3133305D2C5B3139342C36302C3132395D2C';
wwv_flow_imp.g_varchar2_table(165) := '5B3139352C36312C3132385D2C5B3139362C36322C3132375D2C5B3139372C36342C3132365D2C5B3139382C36352C3132355D2C5B3139392C36362C3132345D2C5B3230302C36372C3132335D2C5B3230312C36382C3132325D2C5B3230322C36392C31';
wwv_flow_imp.g_varchar2_table(166) := '32325D2C5B3230332C37302C3132315D2C5B3230342C37312C3132305D2C5B3230342C37332C3131395D2C5B3230352C37342C3131385D2C5B3230362C37352C3131375D2C5B3230372C37362C3131365D2C5B3230382C37372C3131355D2C5B3230392C';
wwv_flow_imp.g_varchar2_table(167) := '37382C3131345D2C5B3231302C37392C3131335D2C5B3231312C38312C3131335D2C5B3231322C38322C3131325D2C5B3231332C38332C3131315D2C5B3231332C38342C3131305D2C5B3231342C38352C3130395D2C5B3231352C38362C3130385D2C5B';
wwv_flow_imp.g_varchar2_table(168) := '3231362C38372C3130375D2C5B3231372C38382C3130365D2C5B3231382C39302C3130365D2C5B3231382C39312C3130355D2C5B3231392C39322C3130345D2C5B3232302C39332C3130335D2C5B3232312C39342C3130325D2C5B3232322C39352C3130';
wwv_flow_imp.g_varchar2_table(169) := '315D2C5B3232322C39372C3130305D2C5B3232332C39382C39395D2C5B3232342C39392C39395D2C5B3232352C3130302C39385D2C5B3232362C3130312C39375D2C5B3232362C3130322C39365D2C5B3232372C3130342C39355D2C5B3232382C313035';
wwv_flow_imp.g_varchar2_table(170) := '2C39345D2C5B3232392C3130362C39335D2C5B3232392C3130372C39335D2C5B3233302C3130382C39325D2C5B3233312C3131302C39315D2C5B3233312C3131312C39305D2C5B3233322C3131322C38395D2C5B3233332C3131332C38385D2C5B323333';
wwv_flow_imp.g_varchar2_table(171) := '2C3131342C38375D2C5B3233342C3131362C38375D2C5B3233352C3131372C38365D2C5B3233352C3131382C38355D2C5B3233362C3131392C38345D2C5B3233372C3132312C38335D2C5B3233372C3132322C38325D2C5B3233382C3132332C38315D2C';
wwv_flow_imp.g_varchar2_table(172) := '5B3233392C3132342C38315D2C5B3233392C3132362C38305D2C5B3234302C3132372C37395D2C5B3234302C3132382C37385D2C5B3234312C3132392C37375D2C5B3234312C3133312C37365D2C5B3234322C3133322C37355D2C5B3234332C3133332C';
wwv_flow_imp.g_varchar2_table(173) := '37355D2C5B3234332C3133352C37345D2C5B3234342C3133362C37335D2C5B3234342C3133372C37325D2C5B3234352C3133392C37315D2C5B3234352C3134302C37305D2C5B3234362C3134312C36395D2C5B3234362C3134332C36385D2C5B3234372C';
wwv_flow_imp.g_varchar2_table(174) := '3134342C36385D2C5B3234372C3134352C36375D2C5B3234372C3134372C36365D2C5B3234382C3134382C36355D2C5B3234382C3134392C36345D2C5B3234392C3135312C36335D2C5B3234392C3135322C36325D2C5B3234392C3135342C36325D2C5B';
wwv_flow_imp.g_varchar2_table(175) := '3235302C3135352C36315D2C5B3235302C3135362C36305D2C5B3235302C3135382C35395D2C5B3235312C3135392C35385D2C5B3235312C3136312C35375D2C5B3235312C3136322C35365D2C5B3235322C3136332C35365D2C5B3235322C3136352C35';
wwv_flow_imp.g_varchar2_table(176) := '355D2C5B3235322C3136362C35345D2C5B3235322C3136382C35335D2C5B3235322C3136392C35325D2C5B3235332C3137312C35315D2C5B3235332C3137322C35315D2C5B3235332C3137342C35305D2C5B3235332C3137352C34395D2C5B3235332C31';
wwv_flow_imp.g_varchar2_table(177) := '37372C34385D2C5B3235332C3137382C34375D2C5B3235332C3138302C34375D2C5B3235332C3138312C34365D2C5B3235342C3138332C34355D2C5B3235342C3138342C34345D2C5B3235342C3138362C34345D2C5B3235342C3138372C34335D2C5B32';
wwv_flow_imp.g_varchar2_table(178) := '35342C3138392C34325D2C5B3235342C3139302C34325D2C5B3235342C3139322C34315D2C5B3235332C3139342C34315D2C5B3235332C3139352C34305D2C5B3235332C3139372C33395D2C5B3235332C3139382C33395D2C5B3235332C3230302C3339';
wwv_flow_imp.g_varchar2_table(179) := '5D2C5B3235332C3230322C33385D2C5B3235332C3230332C33385D2C5B3235322C3230352C33375D2C5B3235322C3230362C33375D2C5B3235322C3230382C33375D2C5B3235322C3231302C33375D2C5B3235312C3231312C33365D2C5B3235312C3231';
wwv_flow_imp.g_varchar2_table(180) := '332C33365D2C5B3235312C3231352C33365D2C5B3235302C3231362C33365D2C5B3235302C3231382C33365D2C5B3234392C3232302C33365D2C5B3234392C3232312C33375D2C5B3234382C3232332C33375D2C5B3234382C3232352C33375D2C5B3234';
wwv_flow_imp.g_varchar2_table(181) := '372C3232362C33375D2C5B3234372C3232382C33375D2C5B3234362C3233302C33385D2C5B3234362C3233322C33385D2C5B3234352C3233332C33385D2C5B3234352C3233352C33395D2C5B3234342C3233372C33395D2C5B3234332C3233382C33395D';
wwv_flow_imp.g_varchar2_table(182) := '2C5B3234332C3234302C33395D2C5B3234322C3234322C33395D2C5B3234312C3234342C33385D2C5B3234312C3234352C33375D2C5B3234302C3234372C33365D2C5B3234302C3234392C33335D2C5D2C0D0A202020202020766972696469733A205B5B';
wwv_flow_imp.g_varchar2_table(183) := '36382C312C38345D2C5B36382C322C38365D2C5B36392C342C38375D2C5B36392C352C38395D2C5B37302C372C39305D2C5B37302C382C39325D2C5B37302C31302C39335D2C5B37302C31312C39345D2C5B37312C31332C39365D2C5B37312C31342C39';
wwv_flow_imp.g_varchar2_table(184) := '375D2C5B37312C31362C39395D2C5B37312C31372C3130305D2C5B37312C31392C3130315D2C5B37322C32302C3130335D2C5B37322C32322C3130345D2C5B37322C32332C3130355D2C5B37322C32342C3130365D2C5B37322C32362C3130385D2C5B37';
wwv_flow_imp.g_varchar2_table(185) := '322C32372C3130395D2C5B37322C32382C3131305D2C5B37322C32392C3131315D2C5B37322C33312C3131325D2C5B37322C33322C3131335D2C5B37322C33332C3131355D2C5B37322C33352C3131365D2C5B37322C33362C3131375D2C5B37322C3337';
wwv_flow_imp.g_varchar2_table(186) := '2C3131385D2C5B37322C33382C3131395D2C5B37322C34302C3132305D2C5B37322C34312C3132315D2C5B37312C34322C3132325D2C5B37312C34342C3132325D2C5B37312C34352C3132335D2C5B37312C34362C3132345D2C5B37312C34372C313235';
wwv_flow_imp.g_varchar2_table(187) := '5D2C5B37302C34382C3132365D2C5B37302C35302C3132365D2C5B37302C35312C3132375D2C5B37302C35322C3132385D2C5B36392C35332C3132395D2C5B36392C35352C3132395D2C5B36392C35362C3133305D2C5B36382C35372C3133315D2C5B36';
wwv_flow_imp.g_varchar2_table(188) := '382C35382C3133315D2C5B36382C35392C3133325D2C5B36372C36312C3133325D2C5B36372C36322C3133335D2C5B36362C36332C3133335D2C5B36362C36342C3133345D2C5B36362C36352C3133345D2C5B36352C36362C3133355D2C5B36352C3638';
wwv_flow_imp.g_varchar2_table(189) := '2C3133355D2C5B36342C36392C3133365D2C5B36342C37302C3133365D2C5B36332C37312C3133365D2C5B36332C37322C3133375D2C5B36322C37332C3133375D2C5B36322C37342C3133375D2C5B36322C37362C3133385D2C5B36312C37372C313338';
wwv_flow_imp.g_varchar2_table(190) := '5D2C5B36312C37382C3133385D2C5B36302C37392C3133385D2C5B36302C38302C3133395D2C5B35392C38312C3133395D2C5B35392C38322C3133395D2C5B35382C38332C3133395D2C5B35382C38342C3134305D2C5B35372C38352C3134305D2C5B35';
wwv_flow_imp.g_varchar2_table(191) := '372C38362C3134305D2C5B35362C38382C3134305D2C5B35362C38392C3134305D2C5B35352C39302C3134305D2C5B35352C39312C3134315D2C5B35342C39322C3134315D2C5B35342C39332C3134315D2C5B35332C39342C3134315D2C5B35332C3935';
wwv_flow_imp.g_varchar2_table(192) := '2C3134315D2C5B35322C39362C3134315D2C5B35322C39372C3134315D2C5B35312C39382C3134315D2C5B35312C39392C3134315D2C5B35302C3130302C3134325D2C5B35302C3130312C3134325D2C5B34392C3130322C3134325D2C5B34392C313033';
wwv_flow_imp.g_varchar2_table(193) := '2C3134325D2C5B34392C3130342C3134325D2C5B34382C3130352C3134325D2C5B34382C3130362C3134325D2C5B34372C3130372C3134325D2C5B34372C3130382C3134325D2C5B34362C3130392C3134325D2C5B34362C3131302C3134325D2C5B3436';
wwv_flow_imp.g_varchar2_table(194) := '2C3131312C3134325D2C5B34352C3131322C3134325D2C5B34352C3131332C3134325D2C5B34342C3131332C3134325D2C5B34342C3131342C3134325D2C5B34342C3131352C3134325D2C5B34332C3131362C3134325D2C5B34332C3131372C3134325D';
wwv_flow_imp.g_varchar2_table(195) := '2C5B34322C3131382C3134325D2C5B34322C3131392C3134325D2C5B34322C3132302C3134325D2C5B34312C3132312C3134325D2C5B34312C3132322C3134325D2C5B34312C3132332C3134325D2C5B34302C3132342C3134325D2C5B34302C3132352C';
wwv_flow_imp.g_varchar2_table(196) := '3134325D2C5B33392C3132362C3134325D2C5B33392C3132372C3134325D2C5B33392C3132382C3134325D2C5B33382C3132392C3134325D2C5B33382C3133302C3134325D2C5B33382C3133302C3134325D2C5B33372C3133312C3134325D2C5B33372C';
wwv_flow_imp.g_varchar2_table(197) := '3133322C3134325D2C5B33372C3133332C3134325D2C5B33362C3133342C3134325D2C5B33362C3133352C3134325D2C5B33352C3133362C3134325D2C5B33352C3133372C3134325D2C5B33352C3133382C3134315D2C5B33342C3133392C3134315D2C';
wwv_flow_imp.g_varchar2_table(198) := '5B33342C3134302C3134315D2C5B33342C3134312C3134315D2C5B33332C3134322C3134315D2C5B33332C3134332C3134315D2C5B33332C3134342C3134315D2C5B33332C3134352C3134305D2C5B33322C3134362C3134305D2C5B33322C3134362C31';
wwv_flow_imp.g_varchar2_table(199) := '34305D2C5B33322C3134372C3134305D2C5B33312C3134382C3134305D2C5B33312C3134392C3133395D2C5B33312C3135302C3133395D2C5B33312C3135312C3133395D2C5B33312C3135322C3133395D2C5B33312C3135332C3133385D2C5B33312C31';
wwv_flow_imp.g_varchar2_table(200) := '35342C3133385D2C5B33302C3135352C3133385D2C5B33302C3135362C3133375D2C5B33302C3135372C3133375D2C5B33312C3135382C3133375D2C5B33312C3135392C3133365D2C5B33312C3136302C3133365D2C5B33312C3136312C3133365D2C5B';
wwv_flow_imp.g_varchar2_table(201) := '33312C3136312C3133355D2C5B33312C3136322C3133355D2C5B33322C3136332C3133345D2C5B33322C3136342C3133345D2C5B33332C3136352C3133335D2C5B33332C3136362C3133335D2C5B33342C3136372C3133335D2C5B33342C3136382C3133';
wwv_flow_imp.g_varchar2_table(202) := '325D2C5B33352C3136392C3133315D2C5B33362C3137302C3133315D2C5B33372C3137312C3133305D2C5B33372C3137322C3133305D2C5B33382C3137332C3132395D2C5B33392C3137332C3132395D2C5B34302C3137342C3132385D2C5B34312C3137';
wwv_flow_imp.g_varchar2_table(203) := '352C3132375D2C5B34322C3137362C3132375D2C5B34342C3137372C3132365D2C5B34352C3137382C3132355D2C5B34362C3137392C3132345D2C5B34372C3138302C3132345D2C5B34392C3138312C3132335D2C5B35302C3138322C3132325D2C5B35';
wwv_flow_imp.g_varchar2_table(204) := '322C3138322C3132315D2C5B35332C3138332C3132315D2C5B35352C3138342C3132305D2C5B35362C3138352C3131395D2C5B35382C3138362C3131385D2C5B35392C3138372C3131375D2C5B36312C3138382C3131365D2C5B36332C3138382C313135';
wwv_flow_imp.g_varchar2_table(205) := '5D2C5B36342C3138392C3131345D2C5B36362C3139302C3131335D2C5B36382C3139312C3131325D2C5B37302C3139322C3131315D2C5B37322C3139332C3131305D2C5B37342C3139332C3130395D2C5B37362C3139342C3130385D2C5B37382C313935';
wwv_flow_imp.g_varchar2_table(206) := '2C3130375D2C5B38302C3139362C3130365D2C5B38322C3139372C3130355D2C5B38342C3139372C3130345D2C5B38362C3139382C3130335D2C5B38382C3139392C3130315D2C5B39302C3230302C3130305D2C5B39322C3230302C39395D2C5B39342C';
wwv_flow_imp.g_varchar2_table(207) := '3230312C39385D2C5B39362C3230322C39365D2C5B39392C3230332C39355D2C5B3130312C3230332C39345D2C5B3130332C3230342C39325D2C5B3130352C3230352C39315D2C5B3130382C3230352C39305D2C5B3131302C3230362C38385D2C5B3131';
wwv_flow_imp.g_varchar2_table(208) := '322C3230372C38375D2C5B3131352C3230382C38365D2C5B3131372C3230382C38345D2C5B3131392C3230392C38335D2C5B3132322C3230392C38315D2C5B3132342C3231302C38305D2C5B3132372C3231312C37385D2C5B3132392C3231312C37375D';
wwv_flow_imp.g_varchar2_table(209) := '2C5B3133322C3231322C37355D2C5B3133342C3231332C37335D2C5B3133372C3231332C37325D2C5B3133392C3231342C37305D2C5B3134322C3231342C36395D2C5B3134342C3231352C36375D2C5B3134372C3231352C36355D2C5B3134392C323136';
wwv_flow_imp.g_varchar2_table(210) := '2C36345D2C5B3135322C3231362C36325D2C5B3135352C3231372C36305D2C5B3135372C3231372C35395D2C5B3136302C3231382C35375D2C5B3136322C3231382C35355D2C5B3136352C3231392C35345D2C5B3136382C3231392C35325D2C5B313730';
wwv_flow_imp.g_varchar2_table(211) := '2C3232302C35305D2C5B3137332C3232302C34385D2C5B3137362C3232312C34375D2C5B3137382C3232312C34355D2C5B3138312C3232322C34335D2C5B3138342C3232322C34315D2C5B3138362C3232322C34305D2C5B3138392C3232332C33385D2C';
wwv_flow_imp.g_varchar2_table(212) := '5B3139322C3232332C33375D2C5B3139342C3232332C33355D2C5B3139372C3232342C33335D2C5B3230302C3232342C33325D2C5B3230322C3232352C33315D2C5B3230352C3232352C32395D2C5B3230382C3232352C32385D2C5B3231302C3232362C';
wwv_flow_imp.g_varchar2_table(213) := '32375D2C5B3231332C3232362C32365D2C5B3231362C3232362C32355D2C5B3231382C3232372C32355D2C5B3232312C3232372C32345D2C5B3232332C3232372C32345D2C5B3232362C3232382C32345D2C5B3232392C3232382C32355D2C5B3233312C';
wwv_flow_imp.g_varchar2_table(214) := '3232382C32355D2C5B3233342C3232392C32365D2C5B3233362C3232392C32375D2C5B3233392C3232392C32385D2C5B3234312C3232392C32395D2C5B3234342C3233302C33305D2C5B3234362C3233302C33325D2C5B3234382C3233302C33335D2C5B';
wwv_flow_imp.g_varchar2_table(215) := '3235312C3233312C33355D2C5B3235332C3233312C33375D2C5D2C0D0A202020202020636976696469733A205B5B302C33322C37375D2C5B302C33332C37385D2C5B302C33342C38305D2C5B302C33342C38325D2C5B302C33352C38335D2C5B302C3336';
wwv_flow_imp.g_varchar2_table(216) := '2C38355D2C5B302C33372C38375D2C5B302C33372C38385D2C5B302C33382C39305D2C5B302C33392C39325D2C5B302C33392C39345D2C5B302C34302C39365D2C5B302C34312C39375D2C5B302C34322C39395D2C5B302C34322C3130315D2C5B302C34';
wwv_flow_imp.g_varchar2_table(217) := '332C3130335D2C5B302C34342C3130355D2C5B302C34342C3130365D2C5B302C34352C3130385D2C5B302C34362C3131305D2C5B302C34362C3131315D2C5B302C34372C3131315D2C5B302C34372C3131315D2C5B302C34382C3131315D2C5B302C3438';
wwv_flow_imp.g_varchar2_table(218) := '2C3131315D2C5B302C34392C3131315D2C5B302C35302C3131315D2C5B302C35312C3131315D2C5B302C35312C3131315D2C5B302C35322C3131315D2C5B302C35332C3131305D2C5B312C35342C3131305D2C5B362C35342C3131305D2C5B31312C3535';
wwv_flow_imp.g_varchar2_table(219) := '2C3131305D2C5B31352C35362C3131305D2C5B31382C35362C3130395D2C5B32312C35372C3130395D2C5B32342C35382C3130395D2C5B32362C35392C3130395D2C5B32392C35392C3130395D2C5B33312C36302C3130395D2C5B33332C36312C313039';
wwv_flow_imp.g_varchar2_table(220) := '5D2C5B33352C36322C3130385D2C5B33362C36322C3130385D2C5B33382C36332C3130385D2C5B34302C36342C3130385D2C5B34322C36342C3130385D2C5B34332C36352C3130385D2C5B34352C36362C3130385D2C5B34362C36372C3130385D2C5B34';
wwv_flow_imp.g_varchar2_table(221) := '382C36372C3130385D2C5B34392C36382C3130375D2C5B35302C36392C3130375D2C5B35322C36392C3130375D2C5B35332C37302C3130375D2C5B35342C37312C3130375D2C5B35362C37322C3130375D2C5B35372C37322C3130375D2C5B35382C3733';
wwv_flow_imp.g_varchar2_table(222) := '2C3130375D2C5B35392C37342C3130375D2C5B36312C37342C3130375D2C5B36322C37352C3130375D2C5B36332C37362C3130375D2C5B36342C37372C3130375D2C5B36352C37372C3130375D2C5B36362C37382C3130375D2C5B36372C37392C313037';
wwv_flow_imp.g_varchar2_table(223) := '5D2C5B36382C37392C3130375D2C5B37302C38302C3130375D2C5B37312C38312C3130375D2C5B37322C38322C3130375D2C5B37332C38322C3130375D2C5B37342C38332C3130375D2C5B37352C38342C3130385D2C5B37362C38342C3130385D2C5B37';
wwv_flow_imp.g_varchar2_table(224) := '372C38352C3130385D2C5B37382C38362C3130385D2C5B37392C38372C3130385D2C5B38302C38372C3130385D2C5B38312C38382C3130385D2C5B38322C38392C3130385D2C5B38332C38392C3130385D2C5B38342C39302C3130385D2C5B38352C3931';
wwv_flow_imp.g_varchar2_table(225) := '2C3130395D2C5B38362C39322C3130395D2C5B38372C39322C3130395D2C5B38382C39332C3130395D2C5B38392C39342C3130395D2C5B38392C39352C3130395D2C5B39302C39352C3130395D2C5B39312C39362C3131305D2C5B39322C39372C313130';
wwv_flow_imp.g_varchar2_table(226) := '5D2C5B39332C39372C3131305D2C5B39342C39382C3131305D2C5B39352C39392C3131305D2C5B39362C3130302C3131315D2C5B39372C3130302C3131315D2C5B39382C3130312C3131315D2C5B39392C3130322C3131315D2C5B3130302C3130322C31';
wwv_flow_imp.g_varchar2_table(227) := '31315D2C5B3130302C3130332C3131325D2C5B3130312C3130342C3131325D2C5B3130322C3130352C3131325D2C5B3130332C3130352C3131325D2C5B3130342C3130362C3131335D2C5B3130352C3130372C3131335D2C5B3130362C3130382C313133';
wwv_flow_imp.g_varchar2_table(228) := '5D2C5B3130372C3130382C3131335D2C5B3130382C3130392C3131345D2C5B3130382C3131302C3131345D2C5B3130392C3131302C3131345D2C5B3131302C3131312C3131355D2C5B3131312C3131322C3131355D2C5B3131322C3131332C3131355D2C';
wwv_flow_imp.g_varchar2_table(229) := '5B3131332C3131332C3131365D2C5B3131342C3131342C3131365D2C5B3131342C3131352C3131365D2C5B3131352C3131362C3131375D2C5B3131362C3131362C3131375D2C5B3131372C3131372C3131375D2C5B3131382C3131382C3131385D2C5B31';
wwv_flow_imp.g_varchar2_table(230) := '31392C3131392C3131385D2C5B3132302C3131392C3131395D2C5B3132302C3132302C3131395D2C5B3132312C3132312C3131395D2C5B3132322C3132322C3132305D2C5B3132332C3132322C3132305D2C5B3132342C3132332C3132305D2C5B313235';
wwv_flow_imp.g_varchar2_table(231) := '2C3132342C3132305D2C5B3132362C3132352C3132305D2C5B3132372C3132352C3132305D2C5B3132382C3132362C3132315D2C5B3132392C3132372C3132315D2C5B3133302C3132382C3132315D2C5B3133312C3132382C3132315D2C5B3133322C31';
wwv_flow_imp.g_varchar2_table(232) := '32392C3132315D2C5B3133322C3133302C3132315D2C5B3133332C3133312C3132315D2C5B3133342C3133312C3132315D2C5B3133352C3133322C3132315D2C5B3133362C3133332C3132315D2C5B3133372C3133342C3132315D2C5B3133382C313335';
wwv_flow_imp.g_varchar2_table(233) := '2C3132315D2C5B3133392C3133352C3132315D2C5B3134302C3133362C3132315D2C5B3134312C3133372C3132315D2C5B3134322C3133382C3132315D2C5B3134332C3133382C3132315D2C5B3134342C3133392C3132315D2C5B3134352C3134302C31';
wwv_flow_imp.g_varchar2_table(234) := '32305D2C5B3134362C3134312C3132305D2C5B3134372C3134322C3132305D2C5B3134382C3134322C3132305D2C5B3134392C3134332C3132305D2C5B3135302C3134342C3132305D2C5B3135312C3134352C3132305D2C5B3135322C3134362C313230';
wwv_flow_imp.g_varchar2_table(235) := '5D2C5B3135332C3134362C3132305D2C5B3135342C3134372C3131395D2C5B3135352C3134382C3131395D2C5B3135362C3134392C3131395D2C5B3135372C3135302C3131395D2C5B3135382C3135302C3131395D2C5B3135392C3135312C3131395D2C';
wwv_flow_imp.g_varchar2_table(236) := '5B3136302C3135322C3131395D2C5B3136312C3135332C3131385D2C5B3136322C3135342C3131385D2C5B3136332C3135342C3131385D2C5B3136342C3135352C3131385D2C5B3136352C3135362C3131385D2C5B3136362C3135372C3131375D2C5B31';
wwv_flow_imp.g_varchar2_table(237) := '36382C3135382C3131375D2C5B3136392C3135392C3131375D2C5B3137302C3135392C3131375D2C5B3137312C3136302C3131365D2C5B3137322C3136312C3131365D2C5B3137332C3136322C3131365D2C5B3137342C3136332C3131365D2C5B313735';
wwv_flow_imp.g_varchar2_table(238) := '2C3136342C3131355D2C5B3137362C3136342C3131355D2C5B3137372C3136352C3131355D2C5B3137382C3136362C3131345D2C5B3137392C3136372C3131345D2C5B3138302C3136382C3131345D2C5B3138312C3136392C3131335D2C5B3138322C31';
wwv_flow_imp.g_varchar2_table(239) := '36392C3131335D2C5B3138332C3137302C3131335D2C5B3138342C3137312C3131325D2C5B3138352C3137322C3131325D2C5B3138362C3137332C3131325D2C5B3138372C3137342C3131315D2C5B3138382C3137352C3131315D2C5B3139302C313735';
wwv_flow_imp.g_varchar2_table(240) := '2C3131315D2C5B3139312C3137362C3131305D2C5B3139322C3137372C3131305D2C5B3139332C3137382C3130395D2C5B3139342C3137392C3130395D2C5B3139352C3138302C3130395D2C5B3139362C3138312C3130385D2C5B3139372C3138312C31';
wwv_flow_imp.g_varchar2_table(241) := '30385D2C5B3139382C3138322C3130375D2C5B3139392C3138332C3130375D2C5B3230302C3138342C3130365D2C5B3230312C3138352C3130365D2C5B3230332C3138362C3130355D2C5B3230342C3138372C3130355D2C5B3230352C3138382C313034';
wwv_flow_imp.g_varchar2_table(242) := '5D2C5B3230362C3138382C3130345D2C5B3230372C3138392C3130335D2C5B3230382C3139302C3130335D2C5B3230392C3139312C3130325D2C5B3231302C3139322C3130325D2C5B3231312C3139332C3130315D2C5B3231322C3139342C3130305D2C';
wwv_flow_imp.g_varchar2_table(243) := '5B3231342C3139352C3130305D2C5B3231352C3139362C39395D2C5B3231362C3139372C39395D2C5B3231372C3139372C39385D2C5B3231382C3139382C39375D2C5B3231392C3139392C39375D2C5B3232302C3230302C39365D2C5B3232312C323031';
wwv_flow_imp.g_varchar2_table(244) := '2C39355D2C5B3232322C3230322C39355D2C5B3232342C3230332C39345D2C5B3232352C3230342C39335D2C5B3232362C3230352C39325D2C5B3232372C3230362C39325D2C5B3232382C3230372C39315D2C5B3232392C3230382C39305D2C5B323330';
wwv_flow_imp.g_varchar2_table(245) := '2C3230392C38395D2C5B3233322C3231302C38395D2C5B3233332C3231312C38385D2C5B3233342C3231312C38375D2C5B3233352C3231322C38365D2C5B3233362C3231332C38355D2C5B3233372C3231342C38345D2C5B3233392C3231352C38335D2C';
wwv_flow_imp.g_varchar2_table(246) := '5B3234302C3231362C38325D2C5B3234312C3231372C38315D2C5B3234322C3231382C38305D2C5B3234332C3231392C37395D2C5B3234342C3232302C37385D2C5B3234362C3232312C37375D2C5B3234372C3232322C37365D2C5B3234382C3232332C';
wwv_flow_imp.g_varchar2_table(247) := '37355D2C5B3234392C3232342C37345D2C5B3235302C3232352C37335D2C5B3235312C3232362C37325D2C5B3235332C3232372C37305D2C5B3235342C3232382C36395D2C5B3235352C3232392C36385D2C5B3235352C3233302C36365D2C5B3235352C';
wwv_flow_imp.g_varchar2_table(248) := '3233312C36365D2C5B3235352C3233322C36375D2C5B3235352C3233332C36385D2C5B3235352C3233342C37305D2C5D2C0D0A202020202020726F636B65743A205B5B332C352C32365D2C5B342C352C32365D2C5B352C362C32375D2C5B362C372C3238';
wwv_flow_imp.g_varchar2_table(249) := '5D2C5B372C372C32395D2C5B382C382C33305D2C5B31302C392C33315D2C5B31312C392C33325D2C5B31332C31302C33335D2C5B31342C31312C33345D2C5B31362C31312C33355D2C5B31372C31322C33365D2C5B31392C31332C33375D2C5B32302C31';
wwv_flow_imp.g_varchar2_table(250) := '342C33385D2C5B32322C31342C33395D2C5B32332C31352C34305D2C5B32342C31352C34315D2C5B32362C31362C34325D2C5B32372C31372C34335D2C5B32392C31372C34345D2C5B33302C31382C34355D2C5B33322C31382C34365D2C5B33332C3139';
wwv_flow_imp.g_varchar2_table(251) := '2C34385D2C5B33342C31392C34395D2C5B33362C32302C35305D2C5B33372C32302C35315D2C5B33392C32312C35325D2C5B34302C32312C35335D2C5B34322C32322C35345D2C5B34332C32322C35355D2C5B34352C32332C35365D2C5B34362C32332C';
wwv_flow_imp.g_varchar2_table(252) := '35375D2C5B34382C32332C35385D2C5B34392C32342C35395D2C5B35312C32342C36305D2C5B35322C32352C36315D2C5B35332C32352C36325D2C5B35352C32352C36335D2C5B35362C32362C36345D2C5B35382C32362C36355D2C5B36302C32362C36';
wwv_flow_imp.g_varchar2_table(253) := '365D2C5B36312C32362C36365D2C5B36332C32372C36375D2C5B36342C32372C36385D2C5B36362C32372C36395D2C5B36372C32382C37305D2C5B36392C32382C37315D2C5B37302C32382C37325D2C5B37322C32382C37325D2C5B37332C32392C3733';
wwv_flow_imp.g_varchar2_table(254) := '5D2C5B37352C32392C37345D2C5B37362C32392C37355D2C5B37382C32392C37355D2C5B38302C32392C37365D2C5B38312C33302C37375D2C5B38332C33302C37375D2C5B38342C33302C37385D2C5B38362C33302C37395D2C5B38382C33302C37395D';
wwv_flow_imp.g_varchar2_table(255) := '2C5B38392C33302C38305D2C5B39312C33302C38315D2C5B39322C33302C38315D2C5B39342C33312C38325D2C5B39362C33312C38325D2C5B39372C33312C38335D2C5B39392C33312C38335D2C5B3130302C33312C38345D2C5B3130322C33312C3834';
wwv_flow_imp.g_varchar2_table(256) := '5D2C5B3130342C33312C38355D2C5B3130352C33312C38355D2C5B3130372C33312C38365D2C5B3130392C33312C38365D2C5B3131302C33312C38375D2C5B3131322C33312C38375D2C5B3131332C33312C38375D2C5B3131352C33312C38385D2C5B31';
wwv_flow_imp.g_varchar2_table(257) := '31372C33312C38385D2C5B3131382C33312C38385D2C5B3132302C33312C38395D2C5B3132322C33312C38395D2C5B3132332C33312C38395D2C5B3132352C33312C39305D2C5B3132372C33302C39305D2C5B3132392C33302C39305D2C5B3133302C33';
wwv_flow_imp.g_varchar2_table(258) := '302C39305D2C5B3133322C33302C39305D2C5B3133342C33302C39315D2C5B3133352C33302C39315D2C5B3133372C33302C39315D2C5B3133392C32392C39315D2C5B3134302C32392C39315D2C5B3134322C32392C39315D2C5B3134342C32392C3931';
wwv_flow_imp.g_varchar2_table(259) := '5D2C5B3134362C32382C39315D2C5B3134372C32382C39315D2C5B3134392C32382C39315D2C5B3135312C32382C39315D2C5B3135322C32372C39315D2C5B3135342C32372C39315D2C5B3135362C32372C39315D2C5B3135382C32362C39315D2C5B31';
wwv_flow_imp.g_varchar2_table(260) := '35392C32362C39315D2C5B3136312C32362C39315D2C5B3136332C32352C39315D2C5B3136342C32352C39315D2C5B3136362C32352C39305D2C5B3136382C32342C39305D2C5B3137302C32342C39305D2C5B3137312C32342C39305D2C5B3137332C32';
wwv_flow_imp.g_varchar2_table(261) := '332C38395D2C5B3137352C32332C38395D2C5B3137362C32332C38395D2C5B3137382C32332C38385D2C5B3138302C32322C38385D2C5B3138312C32322C38375D2C5B3138332C32322C38375D2C5B3138352C32322C38375D2C5B3138362C32322C3836';
wwv_flow_imp.g_varchar2_table(262) := '5D2C5B3138382C32322C38365D2C5B3138392C32322C38355D2C5B3139312C32322C38345D2C5B3139332C32332C38345D2C5B3139342C32332C38335D2C5B3139362C32332C38335D2C5B3139372C32342C38325D2C5B3139392C32352C38315D2C5B32';
wwv_flow_imp.g_varchar2_table(263) := '30302C32352C38315D2C5B3230322C32362C38305D2C5B3230332C32372C37395D2C5B3230352C32382C37385D2C5B3230362C32392C37385D2C5B3230372C33302C37375D2C5B3230392C33312C37365D2C5B3231302C33322C37365D2C5B3231312C33';
wwv_flow_imp.g_varchar2_table(264) := '332C37355D2C5B3231332C33342C37345D2C5B3231342C33362C37335D2C5B3231352C33372C37335D2C5B3231362C33392C37325D2C5B3231372C34302C37315D2C5B3231392C34312C37305D2C5B3232302C34332C37305D2C5B3232312C34342C3639';
wwv_flow_imp.g_varchar2_table(265) := '5D2C5B3232322C34362C36385D2C5B3232332C34372C36385D2C5B3232342C34392C36375D2C5B3232352C35312C36365D2C5B3232362C35322C36365D2C5B3232372C35342C36355D2C5B3232382C35362C36355D2C5B3232392C35372C36345D2C5B32';
wwv_flow_imp.g_varchar2_table(266) := '33302C35392C36345D2C5B3233312C36312C36335D2C5B3233322C36332C36335D2C5B3233322C36342C36325D2C5B3233332C36362C36325D2C5B3233342C36382C36325D2C5B3233352C37302C36325D2C5B3233352C37322C36325D2C5B3233362C37';
wwv_flow_imp.g_varchar2_table(267) := '342C36325D2C5B3233362C37362C36325D2C5B3233372C37382C36325D2C5B3233372C38302C36325D2C5B3233382C38322C36335D2C5B3233382C38342C36335D2C5B3233392C38362C36345D2C5B3233392C38382C36345D2C5B3233392C39302C3635';
wwv_flow_imp.g_varchar2_table(268) := '5D2C5B3234302C39322C36365D2C5B3234302C39342C36365D2C5B3234302C39362C36375D2C5B3234312C39382C36385D2C5B3234312C3130302C36395D2C5B3234312C3130322C37305D2C5B3234322C3130332C37315D2C5B3234322C3130352C3732';
wwv_flow_imp.g_varchar2_table(269) := '5D2C5B3234322C3130372C37335D2C5B3234322C3130392C37355D2C5B3234322C3131312C37365D2C5B3234332C3131332C37375D2C5B3234332C3131352C37385D2C5B3234332C3131362C38305D2C5B3234332C3131382C38315D2C5B3234332C3132';
wwv_flow_imp.g_varchar2_table(270) := '302C38325D2C5B3234342C3132322C38345D2C5B3234342C3132342C38355D2C5B3234342C3132352C38375D2C5B3234342C3132372C38385D2C5B3234342C3132392C39305D2C5B3234342C3133312C39315D2C5B3234342C3133322C39335D2C5B3234';
wwv_flow_imp.g_varchar2_table(271) := '342C3133342C39345D2C5B3234352C3133362C39365D2C5B3234352C3133382C39375D2C5B3234352C3133392C39395D2C5B3234352C3134312C3130305D2C5B3234352C3134332C3130325D2C5B3234352C3134342C3130335D2C5B3234352C3134362C';
wwv_flow_imp.g_varchar2_table(272) := '3130355D2C5B3234352C3134382C3130375D2C5B3234352C3135302C3130385D2C5B3234352C3135312C3131305D2C5B3234352C3135332C3131325D2C5B3234362C3135352C3131335D2C5B3234362C3135362C3131355D2C5B3234362C3135382C3131';
wwv_flow_imp.g_varchar2_table(273) := '375D2C5B3234362C3136302C3131395D2C5B3234362C3136312C3132305D2C5B3234362C3136332C3132325D2C5B3234362C3136342C3132345D2C5B3234362C3136362C3132365D2C5B3234362C3136382C3132385D2C5B3234362C3136392C3132395D';
wwv_flow_imp.g_varchar2_table(274) := '2C5B3234362C3137312C3133315D2C5B3234362C3137332C3133335D2C5B3234362C3137342C3133355D2C5B3234362C3137362C3133375D2C5B3234362C3137372C3133395D2C5B3234362C3137392C3134315D2C5B3234362C3138302C3134335D2C5B';
wwv_flow_imp.g_varchar2_table(275) := '3234362C3138322C3134355D2C5B3234362C3138342C3134375D2C5B3234362C3138352C3134395D2C5B3234362C3138372C3135315D2C5B3234362C3138382C3135335D2C5B3234362C3139302C3135355D2C5B3234362C3139312C3135375D2C5B3234';
wwv_flow_imp.g_varchar2_table(276) := '362C3139332C3135395D2C5B3234372C3139342C3136325D2C5B3234372C3139362C3136345D2C5B3234372C3139382C3136365D2C5B3234372C3139392C3136385D2C5B3234372C3230312C3137305D2C5B3234372C3230322C3137325D2C5B3234372C';
wwv_flow_imp.g_varchar2_table(277) := '3230342C3137355D2C5B3234372C3230352C3137375D2C5B3234372C3230372C3137395D2C5B3234372C3230382C3138315D2C5B3234382C3230392C3138345D2C5B3234382C3231312C3138365D2C5B3234382C3231322C3138385D2C5B3234382C3231';
wwv_flow_imp.g_varchar2_table(278) := '342C3139305D2C5B3234382C3231352C3139325D2C5B3234382C3231372C3139355D2C5B3234382C3231382C3139375D2C5B3234382C3232302C3139395D2C5B3234392C3232312C3230315D2C5B3234392C3232332C3230335D2C5B3234392C3232342C';
wwv_flow_imp.g_varchar2_table(279) := '3230355D2C5B3234392C3232362C3230385D2C5B3234392C3232372C3231305D2C5B3234392C3232392C3231325D2C5B3235302C3233302C3231345D2C5B3235302C3233322C3231365D2C5B3235302C3233332C3231385D2C5B3235302C3233352C3232';
wwv_flow_imp.g_varchar2_table(280) := '315D2C5D2C0D0A2020202020206D616B6F3A205B5B31312C342C355D2C5B31332C342C365D2C5B31342C352C385D2C5B31352C362C395D2C5B31362C362C31305D2C5B31372C372C31325D2C5B31382C382C31335D2C5B31392C392C31355D2C5B32302C';
wwv_flow_imp.g_varchar2_table(281) := '392C31365D2C5B32312C31302C31385D2C5B32322C31312C31395D2C5B32332C31322C32315D2C5B32342C31332C32325D2C5B32352C31342C32345D2C5B32362C31342C32355D2C5B32372C31352C32365D2C5B32382C31362C32385D2C5B32392C3137';
wwv_flow_imp.g_varchar2_table(282) := '2C32395D2C5B33302C31372C33315D2C5B33312C31382C33325D2C5B33322C31392C33345D2C5B33332C32302C33355D2C5B33342C32302C33375D2C5B33352C32312C33385D2C5B33362C32322C34305D2C5B33372C32332C34315D2C5B33382C32332C';
wwv_flow_imp.g_varchar2_table(283) := '34335D2C5B33392C32342C34355D2C5B34302C32352C34365D2C5B34312C32352C34385D2C5B34312C32362C34395D2C5B34322C32372C35315D2C5B34332C32382C35335D2C5B34342C32382C35345D2C5B34352C32392C35365D2C5B34362C33302C35';
wwv_flow_imp.g_varchar2_table(284) := '375D2C5B34362C33302C35395D2C5B34372C33312C36315D2C5B34382C33322C36325D2C5B34392C33332C36345D2C5B34392C33332C36365D2C5B35302C33342C36375D2C5B35312C33352C36395D2C5B35322C33362C37315D2C5B35322C33372C3732';
wwv_flow_imp.g_varchar2_table(285) := '5D2C5B35332C33372C37345D2C5B35332C33382C37365D2C5B35342C33392C37375D2C5B35352C34302C37395D2C5B35352C34302C38315D2C5B35362C34312C38335D2C5B35362C34322C38345D2C5B35372C34332C38365D2C5B35382C34342C38385D';
wwv_flow_imp.g_varchar2_table(286) := '2C5B35382C34342C38395D2C5B35392C34352C39315D2C5B35392C34362C39335D2C5B35392C34372C39355D2C5B36302C34382C39365D2C5B36302C34392C39385D2C5B36312C34392C3130305D2C5B36312C35302C3130325D2C5B36322C35312C3130';
wwv_flow_imp.g_varchar2_table(287) := '335D2C5B36322C35322C3130355D2C5B36322C35332C3130375D2C5B36332C35342C3130395D2C5B36332C35342C3131315D2C5B36332C35352C3131325D2C5B36342C35362C3131345D2C5B36342C35372C3131365D2C5B36342C35382C3131385D2C5B';
wwv_flow_imp.g_varchar2_table(288) := '36342C35392C3132305D2C5B36342C36302C3132315D2C5B36352C36312C3132335D2C5B36352C36322C3132355D2C5B36352C36322C3132375D2C5B36352C36332C3132385D2C5B36352C36342C3133305D2C5B36352C36352C3133325D2C5B36352C36';
wwv_flow_imp.g_varchar2_table(289) := '362C3133335D2C5B36352C36372C3133355D2C5B36352C36382C3133365D2C5B36342C37302C3133385D2C5B36342C37312C3133395D2C5B36342C37322C3134315D2C5B36342C37332C3134325D2C5B36332C37342C3134335D2C5B36332C37352C3134';
wwv_flow_imp.g_varchar2_table(290) := '345D2C5B36332C37362C3134365D2C5B36322C37372C3134375D2C5B36322C37392C3134385D2C5B36322C38302C3134395D2C5B36312C38312C3134395D2C5B36312C38322C3135305D2C5B36302C38332C3135315D2C5B36302C38352C3135325D2C5B';
wwv_flow_imp.g_varchar2_table(291) := '35392C38362C3135325D2C5B35392C38372C3135335D2C5B35392C38382C3135345D2C5B35382C38392C3135345D2C5B35382C39312C3135355D2C5B35382C39322C3135355D2C5B35372C39332C3135365D2C5B35372C39342C3135365D2C5B35362C39';
wwv_flow_imp.g_varchar2_table(292) := '352C3135365D2C5B35362C39372C3135375D2C5B35362C39382C3135375D2C5B35362C39392C3135375D2C5B35352C3130302C3135385D2C5B35352C3130312C3135385D2C5B35352C3130322C3135385D2C5B35352C3130342C3135395D2C5B35342C31';
wwv_flow_imp.g_varchar2_table(293) := '30352C3135395D2C5B35342C3130362C3135395D2C5B35342C3130372C3135395D2C5B35342C3130382C3136305D2C5B35342C3130392C3136305D2C5B35342C3131312C3136305D2C5B35342C3131322C3136305D2C5B35342C3131332C3136305D2C5B';
wwv_flow_imp.g_varchar2_table(294) := '35332C3131342C3136315D2C5B35332C3131352C3136315D2C5B35332C3131362C3136315D2C5B35332C3131372C3136315D2C5B35332C3131382C3136325D2C5B35332C3132302C3136325D2C5B35332C3132312C3136325D2C5B35332C3132322C3136';
wwv_flow_imp.g_varchar2_table(295) := '325D2C5B35332C3132332C3136335D2C5B35332C3132342C3136335D2C5B35332C3132352C3136335D2C5B35332C3132362C3136345D2C5B35322C3132372C3136345D2C5B35322C3132382C3136345D2C5B35322C3133302C3136345D2C5B35322C3133';
wwv_flow_imp.g_varchar2_table(296) := '312C3136355D2C5B35322C3133322C3136355D2C5B35322C3133332C3136355D2C5B35322C3133342C3136355D2C5B35322C3133352C3136365D2C5B35322C3133362C3136365D2C5B35322C3133372C3136365D2C5B35322C3133392C3136365D2C5B35';
wwv_flow_imp.g_varchar2_table(297) := '322C3134302C3136375D2C5B35322C3134312C3136375D2C5B35322C3134322C3136375D2C5B35322C3134332C3136375D2C5B35322C3134342C3136385D2C5B35322C3134352C3136385D2C5B35322C3134362C3136385D2C5B35322C3134372C313638';
wwv_flow_imp.g_varchar2_table(298) := '5D2C5B35322C3134392C3136395D2C5B35322C3135302C3136395D2C5B35322C3135312C3136395D2C5B35322C3135322C3136395D2C5B35322C3135332C3137305D2C5B35322C3135342C3137305D2C5B35332C3135352C3137305D2C5B35332C313536';
wwv_flow_imp.g_varchar2_table(299) := '2C3137305D2C5B35332C3135382C3137305D2C5B35332C3135392C3137315D2C5B35332C3136302C3137315D2C5B35332C3136312C3137315D2C5B35342C3136322C3137315D2C5B35342C3136332C3137315D2C5B35342C3136342C3137315D2C5B3535';
wwv_flow_imp.g_varchar2_table(300) := '2C3136352C3137325D2C5B35352C3136362C3137325D2C5B35352C3136382C3137325D2C5B35362C3136392C3137325D2C5B35362C3137302C3137325D2C5B35372C3137312C3137325D2C5B35372C3137322C3137325D2C5B35382C3137332C3137325D';
wwv_flow_imp.g_varchar2_table(301) := '2C5B35382C3137342C3137335D2C5B35392C3137352C3137335D2C5B36302C3137372C3137335D2C5B36302C3137382C3137335D2C5B36312C3137392C3137335D2C5B36322C3138302C3137335D2C5B36332C3138312C3137335D2C5B36332C3138322C';
wwv_flow_imp.g_varchar2_table(302) := '3137335D2C5B36342C3138332C3137335D2C5B36352C3138342C3137335D2C5B36362C3138352C3137335D2C5B36372C3138362C3137335D2C5B36382C3138382C3137335D2C5B36392C3138392C3137335D2C5B37302C3139302C3137335D2C5B37312C';
wwv_flow_imp.g_varchar2_table(303) := '3139312C3137335D2C5B37322C3139322C3137335D2C5B37332C3139332C3137335D2C5B37352C3139342C3137335D2C5B37362C3139352C3137335D2C5B37372C3139362C3137335D2C5B37392C3139372C3137335D2C5B38302C3139382C3137335D2C';
wwv_flow_imp.g_varchar2_table(304) := '5B38322C3139392C3137335D2C5B38332C3230312C3137335D2C5B38352C3230322C3137335D2C5B38372C3230332C3137335D2C5B38392C3230342C3137335D2C5B39312C3230352C3137335D2C5B39342C3230352C3137335D2C5B39362C3230362C31';
wwv_flow_imp.g_varchar2_table(305) := '37325D2C5B39382C3230372C3137325D2C5B3130312C3230382C3137335D2C5B3130342C3230392C3137335D2C5B3130362C3231302C3137335D2C5B3130392C3231312C3137335D2C5B3131322C3231322C3137335D2C5B3131352C3231322C3137335D';
wwv_flow_imp.g_varchar2_table(306) := '2C5B3131382C3231332C3137345D2C5B3132312C3231342C3137345D2C5B3132342C3231342C3137355D2C5B3132372C3231352C3137355D2C5B3133302C3231362C3137365D2C5B3133332C3231372C3137375D2C5B3133362C3231372C3137375D2C5B';
wwv_flow_imp.g_varchar2_table(307) := '3133392C3231382C3137385D2C5B3134322C3231392C3137395D2C5B3134352C3231392C3138305D2C5B3134382C3232302C3138315D2C5B3135302C3232312C3138315D2C5B3135332C3232312C3138325D2C5B3135362C3232322C3138335D2C5B3135';
wwv_flow_imp.g_varchar2_table(308) := '382C3232332C3138345D2C5B3136312C3232332C3138355D2C5B3136342C3232342C3138375D2C5B3136362C3232352C3138385D2C5B3136392C3232352C3138395D2C5B3137312C3232362C3139305D2C5B3137342C3232372C3139325D2C5B3137362C';
wwv_flow_imp.g_varchar2_table(309) := '3232382C3139335D2C5B3137382C3232382C3139345D2C5B3138312C3232392C3139365D2C5B3138332C3233302C3139375D2C5B3138352C3233302C3139395D2C5B3138372C3233312C3230305D2C5B3139302C3233322C3230325D2C5B3139322C3233';
wwv_flow_imp.g_varchar2_table(310) := '332C3230345D2C5B3139342C3233332C3230355D2C5B3139362C3233342C3230375D2C5B3139382C3233352C3230395D2C5B3230302C3233362C3231305D2C5B3230322C3233372C3231325D2C5B3230342C3233372C3231345D2C5B3230362C3233382C';
wwv_flow_imp.g_varchar2_table(311) := '3231355D2C5B3230382C3233392C3231375D2C5B3231302C3234302C3231395D2C5B3231322C3234312C3232305D2C5B3231342C3234312C3232325D2C5B3231362C3234322C3232345D2C5B3231382C3234332C3232355D2C5B3232302C3234342C3232';
wwv_flow_imp.g_varchar2_table(312) := '375D2C5B3232322C3234352C3232395D2C5D2C0D0A202020202020747572626F3A205B5B34382C31382C35395D2C5B35302C32312C36375D2C5B35312C32342C37345D2C5B35322C32372C38315D2C5B35332C33302C38385D2C5B35342C33332C39355D';
wwv_flow_imp.g_varchar2_table(313) := '2C5B35352C33362C3130325D2C5B35362C33392C3130395D2C5B35372C34322C3131355D2C5B35382C34352C3132315D2C5B35392C34372C3132385D2C5B36302C35302C3133345D2C5B36312C35332C3133395D2C5B36322C35362C3134355D2C5B3633';
wwv_flow_imp.g_varchar2_table(314) := '2C35392C3135315D2C5B36332C36322C3135365D2C5B36342C36342C3136325D2C5B36352C36372C3136375D2C5B36352C37302C3137325D2C5B36362C37332C3137375D2C5B36362C37352C3138315D2C5B36372C37382C3138365D2C5B36382C38312C';
wwv_flow_imp.g_varchar2_table(315) := '3139315D2C5B36382C38342C3139355D2C5B36382C38362C3139395D2C5B36392C38392C3230335D2C5B36392C39322C3230375D2C5B36392C39342C3231315D2C5B37302C39372C3231345D2C5B37302C3130302C3231385D2C5B37302C3130322C3232';
wwv_flow_imp.g_varchar2_table(316) := '315D2C5B37302C3130352C3232345D2C5B37302C3130372C3232375D2C5B37312C3131302C3233305D2C5B37312C3131332C3233335D2C5B37312C3131352C3233355D2C5B37312C3131382C3233385D2C5B37312C3132302C3234305D2C5B37312C3132';
wwv_flow_imp.g_varchar2_table(317) := '332C3234325D2C5B37302C3132352C3234345D2C5B37302C3132382C3234365D2C5B37302C3133302C3234385D2C5B37302C3133332C3235305D2C5B37302C3133352C3235315D2C5B36392C3133382C3235325D2C5B36392C3134302C3235335D2C5B36';
wwv_flow_imp.g_varchar2_table(318) := '382C3134332C3235345D2C5B36372C3134352C3235345D2C5B36362C3134382C3235355D2C5B36352C3135302C3235355D2C5B36342C3135332C3235355D2C5B36322C3135352C3235345D2C5B36312C3135382C3235345D2C5B35392C3136302C323533';
wwv_flow_imp.g_varchar2_table(319) := '5D2C5B35382C3136332C3235325D2C5B35362C3136352C3235315D2C5B35352C3136382C3235305D2C5B35332C3137312C3234385D2C5B35312C3137332C3234375D2C5B34392C3137352C3234355D2C5B34372C3137382C3234345D2C5B34362C313830';
wwv_flow_imp.g_varchar2_table(320) := '2C3234325D2C5B34342C3138332C3234305D2C5B34322C3138352C3233385D2C5B34302C3138382C3233355D2C5B33392C3139302C3233335D2C5B33372C3139322C3233315D2C5B33352C3139352C3232385D2C5B33342C3139372C3232365D2C5B3332';
wwv_flow_imp.g_varchar2_table(321) := '2C3139392C3232335D2C5B33312C3230312C3232315D2C5B33302C3230332C3231385D2C5B32382C3230352C3231365D2C5B32372C3230382C3231335D2C5B32362C3231302C3231305D2C5B32362C3231322C3230385D2C5B32352C3231332C3230355D';
wwv_flow_imp.g_varchar2_table(322) := '2C5B32342C3231352C3230325D2C5B32342C3231372C3230305D2C5B32342C3231392C3139375D2C5B32342C3232312C3139345D2C5B32342C3232322C3139325D2C5B32342C3232342C3138395D2C5B32352C3232362C3138375D2C5B32352C3232372C';
wwv_flow_imp.g_varchar2_table(323) := '3138355D2C5B32362C3232382C3138325D2C5B32382C3233302C3138305D2C5B32392C3233312C3137385D2C5B33312C3233332C3137355D2C5B33322C3233342C3137325D2C5B33342C3233352C3137305D2C5B33372C3233362C3136375D2C5B33392C';
wwv_flow_imp.g_varchar2_table(324) := '3233382C3136345D2C5B34322C3233392C3136315D2C5B34342C3234302C3135385D2C5B34372C3234312C3135355D2C5B35302C3234322C3135325D2C5B35332C3234332C3134385D2C5B35362C3234342C3134355D2C5B36302C3234352C3134325D2C';
wwv_flow_imp.g_varchar2_table(325) := '5B36332C3234362C3133385D2C5B36372C3234372C3133355D2C5B37302C3234382C3133325D2C5B37342C3234382C3132385D2C5B37382C3234392C3132355D2C5B38322C3235302C3132325D2C5B38352C3235302C3131385D2C5B38392C3235312C31';
wwv_flow_imp.g_varchar2_table(326) := '31355D2C5B39332C3235322C3131315D2C5B39372C3235322C3130385D2C5B3130312C3235332C3130355D2C5B3130352C3235332C3130325D2C5B3130392C3235342C39385D2C5B3131332C3235342C39355D2C5B3131372C3235342C39325D2C5B3132';
wwv_flow_imp.g_varchar2_table(327) := '312C3235342C38395D2C5B3132352C3235352C38365D2C5B3132382C3235352C38335D2C5B3133322C3235352C38315D2C5B3133362C3235352C37385D2C5B3133392C3235352C37355D2C5B3134332C3235352C37335D2C5B3134362C3235352C37315D';
wwv_flow_imp.g_varchar2_table(328) := '2C5B3135302C3235342C36385D2C5B3135332C3235342C36365D2C5B3135362C3235342C36345D2C5B3135392C3235332C36335D2C5B3136312C3235332C36315D2C5B3136342C3235322C36305D2C5B3136372C3235322C35385D2C5B3136392C323531';
wwv_flow_imp.g_varchar2_table(329) := '2C35375D2C5B3137322C3235312C35365D2C5B3137352C3235302C35355D2C5B3137372C3234392C35345D2C5B3138302C3234382C35345D2C5B3138332C3234372C35335D2C5B3138352C3234362C35335D2C5B3138382C3234352C35325D2C5B313930';
wwv_flow_imp.g_varchar2_table(330) := '2C3234342C35325D2C5B3139332C3234332C35325D2C5B3139352C3234312C35325D2C5B3139382C3234302C35325D2C5B3230302C3233392C35325D2C5B3230332C3233372C35325D2C5B3230352C3233362C35325D2C5B3230382C3233342C35325D2C';
wwv_flow_imp.g_varchar2_table(331) := '5B3231302C3233332C35335D2C5B3231322C3233312C35335D2C5B3231352C3232392C35335D2C5B3231372C3232382C35345D2C5B3231392C3232362C35345D2C5B3232312C3232342C35355D2C5B3232332C3232332C35355D2C5B3232352C3232312C';
wwv_flow_imp.g_varchar2_table(332) := '35355D2C5B3232372C3231392C35365D2C5B3232392C3231372C35365D2C5B3233312C3231352C35375D2C5B3233332C3231332C35375D2C5B3233352C3231312C35375D2C5B3233362C3230392C35385D2C5B3233382C3230372C35385D2C5B3233392C';
wwv_flow_imp.g_varchar2_table(333) := '3230352C35385D2C5B3234312C3230332C35385D2C5B3234322C3230312C35385D2C5B3234342C3139392C35385D2C5B3234352C3139372C35385D2C5B3234362C3139352C35385D2C5B3234372C3139332C35385D2C5B3234382C3139302C35375D2C5B';
wwv_flow_imp.g_varchar2_table(334) := '3234392C3138382C35375D2C5B3235302C3138362C35375D2C5B3235312C3138342C35365D2C5B3235312C3138322C35355D2C5B3235322C3137392C35345D2C5B3235322C3137372C35345D2C5B3235332C3137342C35335D2C5B3235332C3137322C35';
wwv_flow_imp.g_varchar2_table(335) := '325D2C5B3235342C3136392C35315D2C5B3235342C3136372C35305D2C5B3235342C3136342C34395D2C5B3235342C3136312C34385D2C5B3235342C3135382C34375D2C5B3235342C3135352C34355D2C5B3235342C3135332C34345D2C5B3235342C31';
wwv_flow_imp.g_varchar2_table(336) := '35302C34335D2C5B3235342C3134372C34325D2C5B3235342C3134342C34315D2C5B3235332C3134312C33395D2C5B3235332C3133382C33385D2C5B3235322C3133352C33375D2C5B3235322C3133322C33355D2C5B3235312C3132392C33345D2C5B32';
wwv_flow_imp.g_varchar2_table(337) := '35312C3132362C33335D2C5B3235302C3132332C33315D2C5B3234392C3132302C33305D2C5B3234392C3131372C32395D2C5B3234382C3131342C32385D2C5B3234372C3131312C32365D2C5B3234362C3130382C32355D2C5B3234352C3130352C3234';
wwv_flow_imp.g_varchar2_table(338) := '5D2C5B3234342C3130322C32335D2C5B3234332C39392C32315D2C5B3234322C39362C32305D2C5B3234312C39332C31395D2C5B3234302C39312C31385D2C5B3233392C38382C31375D2C5B3233372C38352C31365D2C5B3233362C38332C31355D2C5B';
wwv_flow_imp.g_varchar2_table(339) := '3233352C38302C31345D2C5B3233342C37382C31335D2C5B3233322C37352C31325D2C5B3233312C37332C31325D2C5B3232392C37312C31315D2C5B3232382C36392C31305D2C5B3232362C36372C31305D2C5B3232352C36352C395D2C5B3232332C36';
wwv_flow_imp.g_varchar2_table(340) := '332C385D2C5B3232312C36312C385D2C5B3232302C35392C375D2C5B3231382C35372C375D2C5B3231362C35352C365D2C5B3231342C35332C365D2C5B3231322C35312C355D2C5B3231302C34392C355D2C5B3230382C34372C355D2C5B3230362C3435';
wwv_flow_imp.g_varchar2_table(341) := '2C345D2C5B3230342C34332C345D2C5B3230322C34322C345D2C5B3230302C34302C335D2C5B3139372C33382C335D2C5B3139352C33372C335D2C5B3139332C33352C325D2C5B3139302C33332C325D2C5B3138382C33322C325D2C5B3138352C33302C';
wwv_flow_imp.g_varchar2_table(342) := '325D2C5B3138332C32392C325D2C5B3138302C32372C315D2C5B3137382C32362C315D2C5B3137352C32342C315D2C5B3137322C32332C315D2C5B3136392C32322C315D2C5B3136372C32302C315D2C5B3136342C31392C315D2C5B3136312C31382C31';
wwv_flow_imp.g_varchar2_table(343) := '5D2C5B3135382C31362C315D2C5B3135352C31352C315D2C5B3135322C31342C315D2C5B3134392C31332C315D2C5B3134362C31312C315D2C5B3134322C31302C315D2C5B3133392C392C325D2C5B3133362C382C325D2C5B3133332C372C325D2C5B31';
wwv_flow_imp.g_varchar2_table(344) := '32392C362C325D2C5B3132362C352C325D2C5B3132322C342C335D2C5D2C0D0A202020207D3B0D0A0D0A20202020636F6C6F7252616D70203D20705F636F6C6F725F72656C6965665F6D6170203D3D2027637573746F6D27203F20705F636F6C6F725F72';
wwv_flow_imp.g_varchar2_table(345) := '616D70203A206275696C74696E5B705F636F6C6F725F72656C6965665F6D61705D3B0D0A0D0A202020206966202821636F6C6F7252616D7029207B0D0A202020202020636F6C6F7252616D70203D205B2723663365373962272C20272366616334383427';
wwv_flow_imp.g_varchar2_table(346) := '2C202723663861303765272C202723656237663836272C202723636536363933272C202723613035396130272C202723356335336135275D3B0D0A202020207D0D0A0D0A2020202069662028747970656F6620636F6C6F7252616D70203D3D3D20276675';
wwv_flow_imp.g_varchar2_table(347) := '6E6374696F6E2729207B0D0A202020202020636F6C6F7252616D70203D20636F6C6F7252616D70287B0D0A20202020202020206D696E3A20726173746572696E666F2E72616E67655B305D2C0D0A20202020202020206D61783A20726173746572696E66';
wwv_flow_imp.g_varchar2_table(348) := '6F2E72616E67655B315D2C0D0A20202020202020206D65616E3A20726173746572696E666F2E6D65616E2C0D0A20202020202020206D656469616E3A20726173746572696E666F2E6D656469616E2C0D0A202020202020202073746465763A2072617374';
wwv_flow_imp.g_varchar2_table(349) := '6572696E666F2E73746465760D0A2020202020207D2C206275696C74696E293B0D0A202020207D0D0A202020206966202841727261792E6973417272617928636F6C6F7252616D702929207B0D0A202020202020636F6C6F7252616D70203D207B207374';
wwv_flow_imp.g_varchar2_table(350) := '6F70733A20636F6C6F7252616D70207D3B0D0A202020207D0D0A20202020636F6C6F7252616D702E74797065207C7C3D202773657175656E7469616C273B0D0A20202020696620282141727261792E6973417272617928636F6C6F7252616D702E73746F';
wwv_flow_imp.g_varchar2_table(351) := '70735B305D29207C7C20636F6C6F7252616D702E73746F70735B305D2E6C656E67746820213D3D203229207B0D0A2020202020202F2A20496620746865206172726179206973206A7573742061206C697374206F6620636F6C6F72732077697468206E6F';
wwv_flow_imp.g_varchar2_table(352) := '20696E7075742076616C7565732C206D617020697420746F0D0A20202020202020207468652072616E67652E202A2F0D0A202020202020636F6C6F7252616D702E73746F7073203D20636F6C6F7252616D702E73746F70732E6D61702828782C20692920';
wwv_flow_imp.g_varchar2_table(353) := '3D3E205B0D0A20202020202020202869202F2028636F6C6F7252616D702E73746F70732E6C656E677468202D20312929202A2028726173746572696E666F2E72616E67655B315D202D20726173746572696E666F2E72616E67655B305D29202B20726173';
wwv_flow_imp.g_varchar2_table(354) := '746572696E666F2E72616E67655B305D2C0D0A2020202020202020780D0A2020202020205D293B0D0A202020207D0D0A20202020666F722028636F6E73742073746F70206F6620636F6C6F7252616D702E73746F707329207B0D0A20202020202073746F';
wwv_flow_imp.g_varchar2_table(355) := '705B315D203D207061727365436F6C6F722873746F705B315D293B0D0A202020207D0D0A20207D3B0D0A0D0A20206C657420726173746572696E666F3B0D0A20206C65742072656672657368436F756E74203D20313B0D0A20202F2F2043616C6C207468';
wwv_flow_imp.g_varchar2_table(356) := '6520706C7567696E207365727669636520746F20676574207468652067656F72617374657220696E666F726D6174696F6E2C2070757420696E207468652027726173746572696E666F27207661726961626C652E0D0A2020636F6E737420726566726573';
wwv_flow_imp.g_varchar2_table(357) := '68526173746572496E666F203D206173796E63202829203D3E207B0D0A20202020726173746572696E666F203D20617761697420617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B0D0A20202020202078';
wwv_flow_imp.g_varchar2_table(358) := '3031203A20302C202F2F206765742072617374657220696E666F206F70636F64650D0A202020202020706167654974656D733A20705F7375626D69745F6974656D73203F20705F7375626D69745F6974656D732E73706C697428222C2229203A20756E64';
wwv_flow_imp.g_varchar2_table(359) := '6566696E65640D0A202020207D293B0D0A2020202072656672657368436F6C6F7252616D7028293B0D0A20207D3B0D0A202061776169742072656672657368526173746572496E666F28293B0D0A0D0A20206C65742064656D536F757263652C2064656D';
wwv_flow_imp.g_varchar2_table(360) := '3364536F757263652C20726173746572536F757263652C20636F6E746F7572536F757263652C207261737465724C617965722C2068696C6C73686164654C617965722C2072656C6965664C617965723B0D0A20206C657420736F757263654E616D657320';
wwv_flow_imp.g_varchar2_table(361) := '3D205B5D2C206C617965724E616D6573203D205B5D3B0D0A20207377697463682028705F6C617965725F7479706529207B0D0A20202020636173652027726173746572273A0D0A202020202020726173746572536F75726365203D20747275653B0D0A20';
wwv_flow_imp.g_varchar2_table(362) := '20202020207261737465724C61796572203D20747275653B0D0A202020202020627265616B3B0D0A0D0A2020202063617365202764656D273A0D0A20202020202069662028705F7465727261696E5F66656174757265732E696E636C7564657328273364';
wwv_flow_imp.g_varchar2_table(363) := '272929207B0D0A202020202020202064656D3364536F75726365203D20747275653B0D0A2020202020207D0D0A0D0A20202020202069662028705F7465727261696E5F66656174757265732E696E636C756465732827636F6C6F722D72656C6965662729';
wwv_flow_imp.g_varchar2_table(364) := '29207B0D0A2020202020202020696620286D6C436F6C6F7252656C69656629207B0D0A2020202020202020202064656D536F75726365203D20747275653B0D0A2020202020202020202072656C6965664C61796572203D20747275653B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(365) := '2020207D20656C7365207B0D0A20202020202020202020726173746572536F75726365203D20747275653B0D0A202020202020202020207261737465724C61796572203D20747275653B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(366) := '2020202069662028705F7465727261696E5F66656174757265732E696E636C75646573282768696C6C7368616465272929207B0D0A202020202020202064656D536F75726365203D20747275653B0D0A202020202020202068696C6C73686164654C6179';
wwv_flow_imp.g_varchar2_table(367) := '6572203D20747275653B0D0A2020202020207D0D0A0D0A20202020202069662028705F7465727261696E5F66656174757265732E696E636C756465732827636F6E746F757273272929207B0D0A2020202020202020636F6E746F7572536F75726365203D';
wwv_flow_imp.g_varchar2_table(368) := '20747275653B0D0A2020202020207D0D0A0D0A202020202020627265616B3B0D0A0D0A2020202064656661756C743A0D0A2020202020202F2A206175746F202A2F0D0A20202020202069662028726173746572696E666F2E63656C6C6465707468203D3D';
wwv_flow_imp.g_varchar2_table(369) := '20333229207B0D0A202020202020202064656D536F75726365203D20747275653B0D0A202020202020202068696C6C73686164654C61796572203D20747275653B0D0A2020202020207D20656C7365207B0D0A2020202020202020726173746572536F75';
wwv_flow_imp.g_varchar2_table(370) := '726365203D20747275653B0D0A20202020202020207261737465724C61796572203D20747275653B0D0A2020202020207D0D0A202020202020627265616B3B0D0A20207D0D0A0D0A2020636F6E7374207465727261696E42617365203D202D3130303030';
wwv_flow_imp.g_varchar2_table(371) := '3B0D0A2020636F6E7374207465727261696E5265736F6C7574696F6E203D20302E313B0D0A0D0A2020636C617373204C5255207B0D0A20202020636F6E7374727563746F722873697A65203D2032353029207B0D0A202020202020746869732E5F636163';
wwv_flow_imp.g_varchar2_table(372) := '6865203D206E6577204D617028293B0D0A202020202020746869732E5F726563656E74203D205B5D3B0D0A202020202020746869732E5F73697A65203D2073697A653B0D0A202020207D0D0A0D0A20202020686173286B657929207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(373) := '72657475726E20746869732E5F63616368652E686173286B6579293B0D0A202020207D0D0A0D0A20202020676574286B657929207B0D0A20202020202069662028746869732E5F63616368652E686173286B65792929207B0D0A2020202020202020636F';
wwv_flow_imp.g_varchar2_table(374) := '6E737420696478203D20746869732E5F726563656E742E696E6465784F66286B6579293B0D0A2020202020202020746869732E5F726563656E742E73706C696365286964782C2031293B0D0A2020202020202020746869732E5F726563656E742E707573';
wwv_flow_imp.g_varchar2_table(375) := '68286B6579293B0D0A202020202020202072657475726E20746869732E5F63616368652E676574286B6579293B0D0A2020202020207D0D0A202020207D0D0A0D0A20202020707574286B65792C2076616C29207B0D0A202020202020636F6E7374206964';
wwv_flow_imp.g_varchar2_table(376) := '78203D20746869732E5F726563656E742E696E6465784F66286B6579293B0D0A20202020202069662028696478203E3D203029207B0D0A2020202020202020746869732E5F726563656E742E73706C696365286964782C2031293B0D0A2020202020207D';
wwv_flow_imp.g_varchar2_table(377) := '20656C7365207B0D0A202020202020202069662028746869732E5F726563656E742E6C656E677468203E3D20746869732E5F73697A6529207B0D0A20202020202020202020746869732E5F63616368652E64656C65746528746869732E5F726563656E74';
wwv_flow_imp.g_varchar2_table(378) := '5B305D293B0D0A20202020202020202020746869732E5F726563656E742E73706C69636528302C2031293B0D0A20202020202020207D0D0A2020202020207D0D0A202020202020746869732E5F726563656E742E70757368286B6579293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(379) := '2020746869732E5F63616368652E736574286B65792C2076616C293B0D0A202020207D0D0A0D0A20202020636C6561722829207B0D0A202020202020746869732E5F63616368652E636C65617228293B0D0A202020202020746869732E5F726563656E74';
wwv_flow_imp.g_varchar2_table(380) := '203D205B5D3B0D0A202020207D0D0A20207D0D0A0D0A20202F2A204D6170206F6620277A2F782F792720737472696E677320746F2074696C6520726573706F6E736573202A2F0D0A2020636F6E73742074696C654361636865203D206E6577204C525528';
wwv_flow_imp.g_varchar2_table(381) := '293B0D0A0D0A2020636F6E73742067657454696C65203D206173796E6320287A2C20782C207929203D3E207B0D0A20202020636F6E7374206B6579203D2060247B7A7D2F247B787D2F247B797D603B0D0A202020206966202874696C6543616368652E68';
wwv_flow_imp.g_varchar2_table(382) := '6173286B65792929207B0D0A20202020202072657475726E2061776169742074696C6543616368652E676574286B6579293B0D0A202020207D0D0A0D0A20202020636F6E7374207831203D2074696C65326C6F6E6728782C207A293B0D0A20202020636F';
wwv_flow_imp.g_varchar2_table(383) := '6E7374207931203D2074696C65326C617428792C207A293B0D0A20202020636F6E7374207832203D2074696C65326C6F6E672878202B20312C207A293B0D0A20202020636F6E7374207932203D2074696C65326C61742879202B20312C207A293B0D0A0D';
wwv_flow_imp.g_varchar2_table(384) := '0A20202020636F6E73742070726F6D697365203D20286173796E63202829203D3E207B0D0A202020202020636F6E737420726573706F6E7365203D20617761697420617065782E7365727665722E706C7567696E28705F616A61785F6964656E74696669';
wwv_flow_imp.g_varchar2_table(385) := '65722C207B0D0A20202020202020207830313A20312C202F2F20676574207261737465722064617461206F70636F64650D0A20202020202020207830323A206261636B67726F756E64436F6C6F72203F206261636B67726F756E64436F6C6F722E6A6F69';
wwv_flow_imp.g_varchar2_table(386) := '6E28272C2729203A206E756C6C2C202F2F206261636B67726F756E6420636F6C6F720D0A20202020202020207830333A2078312C207830343A2079312C207830353A2078322C207830363A2079322C0D0A20202020202020207830373A20222722202B20';
wwv_flow_imp.g_varchar2_table(387) := '7A202B20222C22202B2078202B20222C22202B2079202B202227222C202F2F206E6F7420757365642C206F6E6C7920666F7220646562756767696E6720707572706F7365730D0A20202020202020207830383A20705F6974656D5F69642C0D0A20202020';
wwv_flow_imp.g_varchar2_table(388) := '20202020706167654974656D733A20705F7375626D69745F6974656D73203F20705F7375626D69745F6974656D732E73706C697428222C2229203A20756E646566696E65640D0A2020202020207D293B0D0A0D0A20202020202069662028726573706F6E';
wwv_flow_imp.g_varchar2_table(389) := '73652E63656C6C6461746129207B0D0A2020202020202020636F6E737420626C6F62203D2061746F6228726573706F6E73652E63656C6C64617461293B0D0A2020202020202020636F6E7374206C656E203D20626C6F622E6C656E6774683B0D0A202020';
wwv_flow_imp.g_varchar2_table(390) := '2020202020636F6E7374206279746573203D206E65772055696E74384172726179286C656E293B0D0A0D0A2020202020202020666F7220286C65742069203D20303B2069203C206C656E3B2069202B2B29207B0D0A202020202020202020206279746573';
wwv_flow_imp.g_varchar2_table(391) := '5B695D203D20626C6F622E63686172436F646541742869293B0D0A20202020202020207D0D0A0D0A2020202020202020726573706F6E73652E63656C6C64617461203D2062797465732E6275666665723B0D0A2020202020207D0D0A0D0A202020202020';
wwv_flow_imp.g_varchar2_table(392) := '72657475726E20726573706F6E73653B0D0A202020207D2928293B0D0A0D0A2020202074696C6543616368652E707574286B65792C2070726F6D697365293B0D0A0D0A2020202072657475726E2061776169742070726F6D6973653B0D0A20207D3B0D0A';
wwv_flow_imp.g_varchar2_table(393) := '0D0A2020636C61737320576F726B6572506F6F6C207B0D0A202020202F2A2A0D0A20202020202A2040706172616D207B737472696E677D20776F726B657246696C6520546865207061746820746F2074686520776F726B6572207363726970742E0D0A20';
wwv_flow_imp.g_varchar2_table(394) := '202020202A2F0D0A20202020636F6E7374727563746F7228776F726B657246696C6529207B0D0A202020202020746869732E776F726B657246696C65203D20776F726B657246696C653B0D0A202020202020746869732E6D617853697A65203D206E6176';
wwv_flow_imp.g_varchar2_table(395) := '696761746F722E6861726477617265436F6E63757272656E6379207C7C20343B0D0A202020202020746869732E696E616374697669747954696D656F7574203D2031303030303B0D0A0D0A202020202020746869732E776F726B657273203D205B5D3B0D';
wwv_flow_imp.g_varchar2_table(396) := '0A202020202020746869732E7461736B5175657565203D205B5D3B0D0A0D0A202020202020746869732E636C65616E7570496E74657276616C203D206E756C6C3B0D0A0D0A2020202020202F2F2063726561746520616E20696E697469616C20776F726B';
wwv_flow_imp.g_varchar2_table(397) := '657220746F207072652D6C6F61642074686520776F726B65722066696C650D0A202020202020746869732E6164644E6577576F726B657228293B0D0A202020207D0D0A0D0A202020202F2A2A0D0A20202020202A2052756E732061207461736B206F6E20';
wwv_flow_imp.g_varchar2_table(398) := '616E20617661696C61626C6520776F726B65722E20496620616C6C20776F726B6572732061726520627573792C20746865207461736B206973207175657565642E0D0A20202020202A2040706172616D207B2A7D20646174612054686520646174612074';
wwv_flow_imp.g_varchar2_table(399) := '6F20706F737420746F2074686520776F726B65722E0D0A20202020202A204072657475726E73207B50726F6D6973653C616E793E7D20412070726F6D6973652074686174207265736F6C76657320776974682074686520776F726B657227732072657370';
wwv_flow_imp.g_varchar2_table(400) := '6F6E73652E0D0A20202020202A2F0D0A2020202072756E286461746129207B0D0A20202020202072657475726E206E65772050726F6D69736528287265736F6C76652C2072656A65637429203D3E207B0D0A2020202020202020746869732E7461736B51';
wwv_flow_imp.g_varchar2_table(401) := '756575652E70757368287B20646174612C207265736F6C76652C2072656A656374207D293B0D0A2020202020202020746869732E646973706174636828293B0D0A2020202020207D293B0D0A202020207D0D0A0D0A202020202F2A2A0D0A20202020202A';
wwv_flow_imp.g_varchar2_table(402) := '2044697370617463686573207461736B732066726F6D2074686520717565756520746F20617661696C61626C6520776F726B6572732E0D0A20202020202A2040707269766174650D0A20202020202A2F0D0A2020202064697370617463682829207B0D0A';
wwv_flow_imp.g_varchar2_table(403) := '20202020202069662028746869732E7461736B51756575652E6C656E677468203D3D3D2030292072657475726E3B0D0A0D0A2020202020206C657420617661696C61626C65576F726B657257726170706572203D20746869732E776F726B6572732E6669';
wwv_flow_imp.g_varchar2_table(404) := '6E642877203D3E2021772E697342757379293B0D0A0D0A2020202020206966202821617661696C61626C65576F726B65725772617070657220262620746869732E776F726B6572732E6C656E677468203C20746869732E6D617853697A6529207B0D0A20';
wwv_flow_imp.g_varchar2_table(405) := '20202020202020617661696C61626C65576F726B657257726170706572203D20746869732E6164644E6577576F726B657228293B0D0A2020202020207D0D0A0D0A20202020202069662028617661696C61626C65576F726B65725772617070657229207B';
wwv_flow_imp.g_varchar2_table(406) := '0D0A2020202020202020636F6E7374207461736B203D20746869732E7461736B51756575652E736869667428293B0D0A202020202020202069662028217461736B292072657475726E3B0D0A0D0A2020202020202020617661696C61626C65576F726B65';
wwv_flow_imp.g_varchar2_table(407) := '72577261707065722E697342757379203D20747275653B0D0A2020202020202020617661696C61626C65576F726B6572577261707065722E6C61737455736564203D20446174652E6E6F7728293B0D0A0D0A2020202020202020636F6E7374207B20776F';
wwv_flow_imp.g_varchar2_table(408) := '726B6572207D203D20617661696C61626C65576F726B6572577261707065723B0D0A0D0A2020202020202020636F6E737420636C65616E7570203D202829203D3E207B0D0A20202020202020202020776F726B65722E72656D6F76654576656E744C6973';
wwv_flow_imp.g_varchar2_table(409) := '74656E657228276D657373616765272C206D65737361676548616E646C6572293B0D0A20202020202020202020776F726B65722E72656D6F76654576656E744C697374656E657228276572726F72272C206572726F7248616E646C6572293B0D0A202020';
wwv_flow_imp.g_varchar2_table(410) := '20202020202020617661696C61626C65576F726B6572577261707065722E697342757379203D2066616C73653B0D0A202020202020202020202F2F20436865636B20666F72206D6F7265207461736B7320746F2070726F636573732E0D0A202020202020';
wwv_flow_imp.g_varchar2_table(411) := '20202020746869732E646973706174636828293B0D0A20202020202020207D3B0D0A0D0A2020202020202020636F6E7374206D65737361676548616E646C6572203D20286529203D3E207B0D0A20202020202020202020636C65616E757028293B0D0A20';
wwv_flow_imp.g_varchar2_table(412) := '20202020202020202069662028652E646174612E737461747573203D3D3D2027737563636573732729207B0D0A2020202020202020202020207461736B2E7265736F6C766528652E646174612E64617461293B0D0A202020202020202020207D20656C73';
wwv_flow_imp.g_varchar2_table(413) := '65207B0D0A2020202020202020202020207461736B2E72656A656374286E6577204572726F722827776F726B6572207461736B206661696C65643A2027202B20652E646174612E6D65737361676529293B0D0A202020202020202020207D0D0A20202020';
wwv_flow_imp.g_varchar2_table(414) := '202020207D3B0D0A0D0A2020202020202020636F6E7374206572726F7248616E646C6572203D202865727229203D3E207B0D0A20202020202020202020636C65616E757028293B0D0A202020202020202020207461736B2E72656A65637428657272293B';
wwv_flow_imp.g_varchar2_table(415) := '0D0A20202020202020207D3B0D0A20202020202020200D0A2020202020202020776F726B65722E6164644576656E744C697374656E657228276D657373616765272C206D65737361676548616E646C6572293B0D0A2020202020202020776F726B65722E';
wwv_flow_imp.g_varchar2_table(416) := '6164644576656E744C697374656E657228276572726F72272C206572726F7248616E646C6572293B0D0A2020202020202020776F726B65722E706F73744D657373616765287461736B2E64617461293B0D0A2020202020207D0D0A202020207D0D0A0D0A';
wwv_flow_imp.g_varchar2_table(417) := '202020202F2A2A0D0A20202020202A20437265617465732061206E657720776F726B657220616E64206164647320697420746F2074686520706F6F6C2E0D0A20202020202A2040707269766174650D0A20202020202A2F0D0A202020206164644E657757';
wwv_flow_imp.g_varchar2_table(418) := '6F726B65722829207B0D0A202020202020636F6E737420776F726B6572203D206E657720576F726B657228746869732E776F726B657246696C65293B0D0A202020202020636F6E737420776F726B657257726170706572203D207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(419) := '20776F726B65722C0D0A20202020202020206973427573793A2066616C73652C0D0A20202020202020206C617374557365643A20446174652E6E6F7728292C0D0A2020202020207D3B0D0A202020202020746869732E776F726B6572732E707573682877';
wwv_flow_imp.g_varchar2_table(420) := '6F726B657257726170706572293B0D0A0D0A20202020202069662028746869732E636C65616E7570496E74657276616C203D3D3D206E756C6C29207B0D0A2020202020202020746869732E636C65616E7570496E74657276616C203D20736574496E7465';
wwv_flow_imp.g_varchar2_table(421) := '7276616C282829203D3E20746869732E7465726D696E617465496E616374697665576F726B65727328292C203130303030293B0D0A2020202020207D0D0A0D0A20202020202072657475726E20776F726B6572577261707065723B0D0A202020207D0D0A';
wwv_flow_imp.g_varchar2_table(422) := '0D0A202020202F2A2A0D0A20202020202A205465726D696E6174657320776F726B65727320746861742068617665206265656E2069646C6520666F72206C6F6E676572207468616E2074686520696E61637469766974792074696D656F75742E0D0A2020';
wwv_flow_imp.g_varchar2_table(423) := '2020202A2040707269766174650D0A20202020202A2F0D0A202020207465726D696E617465496E616374697665576F726B6572732829207B0D0A202020202020636F6E7374206E6F77203D20446174652E6E6F7728293B0D0A202020202020746869732E';
wwv_flow_imp.g_varchar2_table(424) := '776F726B6572732E666F72456163682828777261707065722C20696E64657829203D3E207B0D0A20202020202020206966202821777261707065722E69734275737920262620286E6F77202D20777261707065722E6C61737455736564203E2074686973';
wwv_flow_imp.g_varchar2_table(425) := '2E696E616374697669747954696D656F75742929207B0D0A20202020202020202020777261707065722E776F726B65722E7465726D696E61746528293B0D0A20202020202020202020746869732E776F726B6572732E73706C69636528696E6465782C20';
wwv_flow_imp.g_varchar2_table(426) := '31293B0D0A20202020202020207D0D0A2020202020207D293B0D0A20202020202069662028746869732E776F726B6572732E6C656E677468203D3D3D203029207B0D0A2020202020202020636C656172496E74657276616C28746869732E636C65616E75';
wwv_flow_imp.g_varchar2_table(427) := '70496E74657276616C293B0D0A2020202020202020746869732E636C65616E7570496E74657276616C203D206E756C6C3B0D0A2020202020207D0D0A202020207D0D0A20207D0D0A0D0A2020636F6E737420706F6F6C203D206E657720576F726B657250';
wwv_flow_imp.g_varchar2_table(428) := '6F6F6C28705F706C7567696E5F66696C6573202B20276D6170626974735F67656F7261737465725F776F726B65722E6A7327293B0D0A0D0A2020636F6E737420504154485F5245474558203D206E657720526567457870282F3A5C2F5C2F282E2B295C2F';
wwv_flow_imp.g_varchar2_table(429) := '282E2B295C2F285C642B295C2F285C642B295C2F285C642B292F293B0D0A0D0A2020636F6E7374207265616453746174696354696C65203D202862363429203D3E207B0D0A20202020636F6E73742064617461203D2061746F6228623634293B0D0A2020';
wwv_flow_imp.g_varchar2_table(430) := '2020636F6E7374206C656E203D20646174612E6C656E6774683B0D0A20202020636F6E7374206279746573203D206E65772055696E74384172726179286C656E293B0D0A20202020666F7220286C65742069203D20303B2069203C206C656E3B2069202B';
wwv_flow_imp.g_varchar2_table(431) := '2B29207B0D0A20202020202062797465735B695D203D20646174612E63686172436F646541742869293B0D0A202020207D0D0A2020202072657475726E2062797465733B0D0A20207D3B0D0A0D0A2020636F6E7374205445525241494E5F5247425F5A45';
wwv_flow_imp.g_varchar2_table(432) := '524F203D207265616453746174696354696C652827556B6C47526951414141425852554A51566C413454426741414141762F38412F414164517779786F2F774D416976542F50305830502F572F2F77413D27293B0D0A2020636F6E7374205452414E5350';
wwv_flow_imp.g_varchar2_table(433) := '4152454E54203D207265616453746174696354696C652827556B6C47526949414141425852554A51566C413454425541414141762F38412F4541635145524541554B542F2F796D692F366E2F2F51634127293B0D0A0D0A20206173796E632066756E6374';
wwv_flow_imp.g_varchar2_table(434) := '696F6E2067656F7261737465725F70726F746F636F6C28706172616D732C2061626F7274436F6E74726F6C6C657229207B0D0A20202020636F6E7374207274203D20706172616D732E75726C2E6D6174636828504154485F5245474558293B0D0A202020';
wwv_flow_imp.g_varchar2_table(435) := '206966202821727429207B0D0A2020202020207468726F77206E6577204572726F7228274D616C666F726D65642055524C3A205B27202B20706172616D732E75726C202B20225D22293B0D0A202020207D0D0A0D0A20202020636F6E737420666F726D61';
wwv_flow_imp.g_varchar2_table(436) := '74203D2072745B325D3B0D0A20202020636F6E73742074696C657A7879203D205B7061727365496E742872745B335D292C207061727365496E742872745B345D292C207061727365496E742872745B355D295D3B0D0A0D0A20202020636F6E737420626C';
wwv_flow_imp.g_varchar2_table(437) := '616E6B203D20666F726D6174203D3D3D20277261737465722D64656D27203F205445525241494E5F5247425F5A45524F203A205452414E53504152454E543B0D0A2020202069662028726173746572696E666F2E6E6F52617374657229207B0D0A202020';
wwv_flow_imp.g_varchar2_table(438) := '20202072657475726E207B20646174613A20626C616E6B207D3B0D0A202020207D0D0A0D0A2020202069662028726173746572696E666F2E6974656D696420213D20705F6974656D5F696429207B0D0A202020202020616C65727428726173746572696E';
wwv_flow_imp.g_varchar2_table(439) := '666F2E6974656D6964202B202720213D2027202B20705F6974656D5F6964293B0D0A202020207D0D0A2020202069662028726173746572696E666F2E6D6178707972616D69646C6576656C203D3D203029207B0D0A202020202020636F6E736F6C652E77';
wwv_flow_imp.g_varchar2_table(440) := '61726E28274D6170626974732047656F526173746572204C61796572205B27202B20705F6974656D5F6964202B20275D206973206D697373696E6720707972616D6964732E204275696C6420707972616D69647320746F20696D70726F76652070657266';
wwv_flow_imp.g_varchar2_table(441) := '6F726D616E63652E27293B0D0A202020207D0D0A0D0A202020202F2F2043616C6C2074686520706C7567696E207365727669636520746F20676574207468652072617374657220646174612028656E636F64656420617320626173653634292C20707574';
wwv_flow_imp.g_varchar2_table(442) := '20696E20276461746127207661726961626C652E200D0A202020202F2F2078303720616E64207830382061726520666F7220646562756767696E672C20636F6E73696465722072656D6F76696E672074686F736520696E20746865206675747572652E0D';
wwv_flow_imp.g_varchar2_table(443) := '0A20202020636F6E73742064617461203D2061776169742067657454696C652874696C657A78795B305D2C2074696C657A78795B315D2C2074696C657A78795B325D293B0D0A0D0A202020202F2F204966207468657265206973206E6F20646174612C20';
wwv_flow_imp.g_varchar2_table(444) := '7468656E2072657475726E20612064656661756C7420626C616E6B2074696C65206261736564206F6E2074686520666F726D61742E0D0A2020202069662028646174612E7769647468203D3D3D2030207C7C20646174612E686569676874203D3D3D2030';
wwv_flow_imp.g_varchar2_table(445) := '207C7C20646174612E6E6F52617374657229207B0D0A20202020202072657475726E207B20646174613A20626C616E6B207D3B0D0A202020207D0D0A0D0A2020202072657475726E20617761697420706F6F6C2E72756E287B20646174612C20705F7465';
wwv_flow_imp.g_varchar2_table(446) := '727261696E5F66656174757265732C20666F726D61742C20636F6C6F7252616D702C207465727261696E426173652C207465727261696E5265736F6C7574696F6E2C206261636B67726F756E64436F6C6F72207D293B0D0A20207D0D0A0D0A2020636F6E';
wwv_flow_imp.g_varchar2_table(447) := '737420636C656172436F6E746F7572436163686573203D202829203D3E207B0D0A202020202F2A20436C6561722074686520636F6E746F7572206361636865732E2054686973206973206E6565646564207768656E2072656672657368696E6720746F20';
wwv_flow_imp.g_varchar2_table(448) := '656E737572650D0A202020202020206F6C6420646174612069736E2774207365727665642C20616E6420697320616C736F20736F6D6574696D6573206E656564656420746F2061766F696420737472616E67650D0A202020202020206572726F72732E20';
wwv_flow_imp.g_varchar2_table(449) := '2A2F0D0A2020202069662028636F6E746F75724D616E6167657229207B0D0A202020202020636F6E746F75724D616E616765722E6D616E616765722E636F6E746F757243616368652E636C65617228293B0D0A202020202020636F6E746F75724D616E61';
wwv_flow_imp.g_varchar2_table(450) := '6765722E6D616E616765722E70617273656443616368652E636C65617228293B0D0A202020202020636F6E746F75724D616E616765722E6D616E616765722E74696C6543616368652E636C65617228293B0D0A202020207D0D0A20207D3B0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(451) := '636F6E7374207365744C617965725669736962696C69747950726F70203D202829203D3E207B0D0A20202020636C656172436F6E746F757243616368657328293B0D0A20202020636F6E73742073203D20287375626C617965722C2064697361626C6564';
wwv_flow_imp.g_varchar2_table(452) := '29203D3E207B0D0A202020202020636F6E7374206964203D20705F6974656D5F6964202B20272D27202B207375626C617965723B0D0A202020202020696620286D61702E6765744C617965722869642929207B0D0A20202020202020206D61702E736574';
wwv_flow_imp.g_varchar2_table(453) := '4C61796F757450726F70657274792869642C20277669736962696C697479272C20286C436F6F6B6965203D3D3D202776697369626C6527202626202164697361626C656429203F202776697369626C6527203A20276E6F6E6527293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(454) := '7D0D0A202020207D3B0D0A2020202073282772656C696566272C20686964655261737465724C61796572293B0D0A2020202073282768696C6C7368616465272C206869646548696C6C73686164654C61796572293B0D0A20202020732827636F6E746F75';
wwv_flow_imp.g_varchar2_table(455) := '722D6C696E6573272C2068696465436F6E746F75724C61796572293B0D0A20202020732827636F6E746F75722D6C6162656C73272C2068696465436F6E746F75724C61796572293B0D0A20202020732827726173746572272C2068696465526173746572';
wwv_flow_imp.g_varchar2_table(456) := '4C61796572293B0D0A20207D3B0D0A0D0A20202F2F20437265617465206D61706C6962726520736F7572636520616E64206C617965722E0D0A0D0A20206C6574207465727261696E436F6E74726F6C3B0D0A0D0A20206C657420636F6E746F75724D616E';
wwv_flow_imp.g_varchar2_table(457) := '61676572203D206E756C6C3B0D0A202069662028636F6E746F7572536F7572636529207B0D0A20202020636F6E746F75724D616E61676572203D206E6577206D6C636F6E746F75722E44656D536F75726365287B0D0A20202020202069643A202767656F';
wwv_flow_imp.g_varchar2_table(458) := '725F636F6E746F75725F27202B20705F6974656D5F69642C0D0A20202020202075726C3A206067656F7261737465725F247B705F6974656D5F69647D3A2F2F247B705F6974656D5F69647D2F7261737465722D64656D2F7B7A7D2F7B787D2F7B797D602C';
wwv_flow_imp.g_varchar2_table(459) := '0D0A2020202020206D61787A6F6F6D3A2032322C0D0A202020202020776F726B65723A2066616C73652C0D0A202020202020656E636F64696E673A20276D6170626F78272C0D0A20202020202074696D656F75744D733A20313030303030303030302C0D';
wwv_flow_imp.g_varchar2_table(460) := '0A202020207D293B0D0A20202020636F6E746F75724D616E616765722E6D616E616765722E67657454696C65203D206173796E63202875726C2C2061626F727429203D3E207B0D0A202020202020636F6E737420726573756C74203D2061776169742067';
wwv_flow_imp.g_varchar2_table(461) := '656F7261737465725F70726F746F636F6C287B2075726C207D2C2061626F7274293B0D0A20202020202069662028726573756C742E64617461203D3D3D206E756C6C29207B0D0A2020202020202020726573756C742E64617461203D207A65726F426C6F';
wwv_flow_imp.g_varchar2_table(462) := '623B0D0A2020202020207D20656C7365207B0D0A2020202020202020726573756C742E64617461203D206E657720426C6F62285B726573756C742E646174615D293B0D0A2020202020207D0D0A20202020202072657475726E20726573756C743B0D0A20';
wwv_flow_imp.g_varchar2_table(463) := '2020207D3B0D0A20202020636F6E746F75724D616E616765722E73657475704D61706C69627265286D61706C69627265676C293B0D0A20207D0D0A0D0A2020636F6E7374206164644C61796572203D202829203D3E207B0D0A2020202072656672657368';
wwv_flow_imp.g_varchar2_table(464) := '436F756E74202B2B3B0D0A0D0A20202020736F757263654E616D6573203D205B5D3B0D0A202020206C617965724E616D6573203D205B5D3B0D0A0D0A202020206966202864656D536F75726365207C7C2064656D3364536F7572636529207B0D0A202020';
wwv_flow_imp.g_varchar2_table(465) := '202020636F6E737420737263203D207B0D0A2020202020202020747970653A20277261737465722D64656D272C0D0A202020202020202074696C65733A205B6067656F7261737465725F247B705F6974656D5F69647D3A2F2F247B705F6974656D5F6964';
wwv_flow_imp.g_varchar2_table(466) := '7D2F7261737465722D64656D2F7B7A7D2F7B787D2F7B797D2F72656672657368247B72656672657368436F756E747D605D2C0D0A202020202020202074696C6553697A653A203235362C0D0A2020202020207D3B0D0A0D0A202020202020696620286D6C';
wwv_flow_imp.g_varchar2_table(467) := '437573746F6D456E636F64696E6729207B0D0A20202020202020207372632E656E636F64696E67203D2027637573746F6D273B0D0A20202020202020207372632E626173655368696674203D207465727261696E426173653B0D0A202020202020202073';
wwv_flow_imp.g_varchar2_table(468) := '72632E726564466163746F72203D20323536202A20323536202A207465727261696E5265736F6C7574696F6E3B0D0A20202020202020207372632E677265656E466163746F72203D20323536202A207465727261696E5265736F6C7574696F6E3B0D0A20';
wwv_flow_imp.g_varchar2_table(469) := '202020202020207372632E626C7565466163746F72203D207465727261696E5265736F6C7574696F6E3B0D0A2020202020207D0D0A0D0A2020202020206966202864656D536F7572636529207B0D0A20202020202020206D61702E616464536F75726365';
wwv_flow_imp.g_varchar2_table(470) := '282767656F72617374657244454D536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F69642C20737263293B0D0A2020202020202020736F757263654E616D65732E70757368282767656F72617374657244';
wwv_flow_imp.g_varchar2_table(471) := '454D536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F6964293B0D0A2020202020207D0D0A0D0A2020202020206966202864656D3364536F7572636529207B0D0A20202020202020206D61702E61646453';
wwv_flow_imp.g_varchar2_table(472) := '6F75726365282767656F72617374657244454D3364536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F69642C20737263293B0D0A2020202020202020736F757263654E616D65732E70757368282767656F';
wwv_flow_imp.g_varchar2_table(473) := '72617374657244454D3364536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F6964293B0D0A2020202020207D0D0A202020207D0D0A0D0A2020202069662028726173746572536F7572636529207B0D0A20';
wwv_flow_imp.g_varchar2_table(474) := '2020202020636F6E737420737263203D207B0D0A2020202020202020747970653A2027726173746572272C0D0A202020202020202074696C65733A205B6067656F7261737465725F247B705F6974656D5F69647D3A2F2F247B705F6974656D5F69647D2F';
wwv_flow_imp.g_varchar2_table(475) := '7261737465722F7B7A7D2F7B787D2F7B797D2F72656672657368247B72656672657368436F756E747D605D2C0D0A202020202020202074696C6553697A653A203235362C0D0A2020202020207D3B0D0A0D0A2020202020206D61702E616464536F757263';
wwv_flow_imp.g_varchar2_table(476) := '65282767656F726173746572536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F69642C20737263293B0D0A202020202020736F757263654E616D65732E70757368282767656F726173746572536F757263';
wwv_flow_imp.g_varchar2_table(477) := '655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F6964293B0D0A202020207D0D0A0D0A2020202069662028636F6E746F7572536F7572636529207B0D0A202020202020636F6E737420737263203D207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(478) := '20202020747970653A2027766563746F72272C0D0A202020202020202074696C65733A205B0D0A20202020202020202020636F6E746F75724D616E616765722E636F6E746F757250726F746F636F6C55726C287B0D0A2020202020202020202020207468';
wwv_flow_imp.g_varchar2_table(479) := '726573686F6C64733A207B0D0A202020202020202020202020202031353A205B352C2032352C2035305D2C0D0A202020202020202020202020202031363A205B312C20352C2031305D2C0D0A2020202020202020202020207D2C0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(480) := '20207D292C0D0A20202020202020205D2C0D0A2020202020207D3B0D0A0D0A2020202020206D61702E616464536F75726365282767656F726173746572436F6E746F7572536F757263655F27202B2072656672657368436F756E74202B20275F27202B20';
wwv_flow_imp.g_varchar2_table(481) := '705F6974656D5F69642C20737263293B0D0A202020202020736F757263654E616D65732E70757368282767656F726173746572436F6E746F7572536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F696429';
wwv_flow_imp.g_varchar2_table(482) := '3B0D0A202020207D0D0A0D0A20202020636F6E7374206164644C61796572203D20286C797229203D3E207B0D0A2020202020206C617965724E616D65732E70757368286C79722E6964293B0D0A2020202020202F2F2041646420746865206C6179657220';
wwv_flow_imp.g_varchar2_table(483) := '746F20746865206D61702E20557365207468652073657175656E6365206E756D6265722066726F6D207468652070616765200D0A2020202020202F2F206974656D20746F206F7264657220746865206C61796572732E20486967686572206E756D626572';
wwv_flow_imp.g_varchar2_table(484) := '7320617265206C61737420616E6420646973706C61796564206F6E20746F702E0D0A202020202020636F6E7374206C6179657273203D206D61702E6765745374796C6528292E6C61796572733B0D0A202020202020636F6E7374206D6170626974736C61';
wwv_flow_imp.g_varchar2_table(485) := '79657273203D206C61796572732E66696C7465722866756E6374696F6E2876616C297B0D0A202020202020202069662028276D657461646174612720696E2076616C29207B200D0A2020202020202020202072657475726E20276C617965725F73657175';
wwv_flow_imp.g_varchar2_table(486) := '656E63652720696E2076616C2E6D657461646174613B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202072657475726E2066616C73653B0D0A20202020202020207D0D0A2020202020207D292E6D61702866756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(487) := '76616C29207B72657475726E205B76616C2E6D657461646174612E6C617965725F73657175656E63652C2076616C2E69645D7D293B0D0A0D0A2020202020206C6574206265666F72654C617965723B0D0A202020202020696620286D6170626974736C61';
wwv_flow_imp.g_varchar2_table(488) := '796572732E6C656E67746820213D3D203029207B0D0A20202020202020206D6170626974736C61796572732E736F72742828612C206229203D3E20615B305D202D20625B305D293B0D0A2020202020202020666F72286C65742069203D20303B2069203C';
wwv_flow_imp.g_varchar2_table(489) := '206D6170626974736C61796572732E6C656E6774683B2069202B2B29207B0D0A2020202020202020202069662028705F73657175656E6365203C206D6170626974736C61796572735B695D5B305D29207B0D0A2020202020202020202020206265666F72';
wwv_flow_imp.g_varchar2_table(490) := '654C61796572203D206D6170626974736C61796572735B695D5B315D3B0D0A202020202020202020202020627265616B3B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D0D0A0D0A2020202020206D61702E6164644C';
wwv_flow_imp.g_varchar2_table(491) := '61796572286C79722C206265666F72654C61796572293B0D0A202020207D3B0D0A0D0A20202020696620287261737465724C6179657229207B0D0A2020202020206164644C61796572287B0D0A202020202020202069643A20705F6974656D5F6964202B';
wwv_flow_imp.g_varchar2_table(492) := '20272D726173746572272C0D0A2020202020202020747970653A2027726173746572272C0D0A2020202020202020736F757263653A202767656F726173746572536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974';
wwv_flow_imp.g_varchar2_table(493) := '656D5F69642C0D0A20202020202020206C61796F75743A207B0D0A202020202020202020207669736962696C6974793A20276E6F6E65272C0D0A20202020202020207D2C0D0A20202020202020207061696E743A207B0D0A202020202020202020202772';
wwv_flow_imp.g_varchar2_table(494) := '61737465722D726573616D706C696E67273A20276E656172657374272C0D0A20202020202020207D2C0D0A20202020202020206D65746164617461203A207B0D0A20202020202020202020276C617965725F73657175656E6365273A20705F7365717565';
wwv_flow_imp.g_varchar2_table(495) := '6E63652C0D0A20202020202020207D2C0D0A2020202020207D293B0D0A202020207D0D0A0D0A202020206966202868696C6C73686164654C6179657229207B0D0A2020202020206164644C61796572287B0D0A202020202020202069643A20705F697465';
wwv_flow_imp.g_varchar2_table(496) := '6D5F6964202B20272D68696C6C7368616465272C0D0A2020202020202020747970653A202768696C6C7368616465272C0D0A2020202020202020736F757263653A202767656F72617374657244454D536F757263655F27202B2072656672657368436F75';
wwv_flow_imp.g_varchar2_table(497) := '6E74202B20275F27202B20705F6974656D5F69642C0D0A20202020202020206C61796F75743A207B0D0A202020202020202020207669736962696C6974793A20276E6F6E65272C0D0A20202020202020207D2C0D0A20202020202020207061696E743A20';
wwv_flow_imp.g_varchar2_table(498) := '7B0D0A202020202020202020202768696C6C73686164652D657861676765726174696F6E273A20302E322C0D0A20202020202020207D2C0D0A20202020202020206D657461646174613A207B0D0A20202020202020202020276C617965725F7365717565';
wwv_flow_imp.g_varchar2_table(499) := '6E6365273A20705F73657175656E63652C0D0A20202020202020207D2C0D0A2020202020207D293B0D0A202020207D0D0A0D0A202020206966202872656C6965664C6179657229207B0D0A2020202020206164644C61796572287B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(500) := '2069643A20705F6974656D5F6964202B20272D72656C696566272C0D0A2020202020202020747970653A2027636F6C6F722D72656C696566272C0D0A2020202020202020736F757263653A202767656F72617374657244454D536F757263655F27202B20';
wwv_flow_imp.g_varchar2_table(501) := '72656672657368436F756E74202B20275F27202B20705F6974656D5F69642C0D0A20202020202020206C61796F75743A207B0D0A202020202020202020207669736962696C6974793A20276E6F6E65272C0D0A20202020202020207D2C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(502) := '2020207061696E743A207B0D0A2020202020202020202027636F6C6F722D72656C6965662D6F706163697479273A20705F6F706163697479203F3F20312C0D0A20202020202020207D2C0D0A20202020202020206D657461646174613A207B0D0A202020';
wwv_flow_imp.g_varchar2_table(503) := '20202020202020276C617965725F73657175656E6365273A20705F73657175656E63652C0D0A20202020202020207D2C0D0A2020202020207D293B0D0A202020207D0D0A0D0A2020202069662028636F6E746F7572536F7572636529207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(504) := '20206164644C61796572287B0D0A202020202020202069643A20705F6974656D5F6964202B20272D636F6E746F75722D6C696E6573272C0D0A2020202020202020747970653A20276C696E65272C0D0A2020202020202020736F757263653A202767656F';
wwv_flow_imp.g_varchar2_table(505) := '726173746572436F6E746F7572536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F69642C0D0A202020202020202027736F757263652D6C61796572273A2027636F6E746F757273272C0D0A202020202020';
wwv_flow_imp.g_varchar2_table(506) := '20207061696E743A207B0D0A20202020202020202020276C696E652D636F6C6F72273A205B276D61746368272C205B27676574272C20276C6576656C275D2C20322C2027626C61636B272C202723333333275D2C0D0A20202020202020202020276C696E';
wwv_flow_imp.g_varchar2_table(507) := '652D7769647468273A205B276D61746368272C205B27676574272C20276C6576656C275D2C20322C20312C20312C20312C20302E355D2C0D0A20202020202020207D2C0D0A2020202020207D293B0D0A2020202020206164644C61796572287B0D0A2020';
wwv_flow_imp.g_varchar2_table(508) := '20202020202069643A20705F6974656D5F6964202B20272D636F6E746F75722D6C6162656C73272C0D0A2020202020202020747970653A202773796D626F6C272C0D0A2020202020202020736F757263653A202767656F726173746572436F6E746F7572';
wwv_flow_imp.g_varchar2_table(509) := '536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F69642C0D0A202020202020202027736F757263652D6C61796572273A2027636F6E746F757273272C0D0A202020202020202066696C7465723A205B273D';
wwv_flow_imp.g_varchar2_table(510) := '3D272C205B27676574272C20276C6576656C275D2C20325D2C0D0A20202020202020206C61796F75743A207B0D0A2020202020202020202027746578742D6669656C64273A205B27636F6E636174272C205B276E756D6265722D666F726D6174272C205B';
wwv_flow_imp.g_varchar2_table(511) := '27676574272C2027656C65275D2C207B7D5D2C20275C27275D2C0D0A2020202020202020202027746578742D666F6E74273A205B274E6F746F2053616E7320426F6C64275D2C0D0A2020202020202020202027746578742D73697A65273A2031302C0D0A';
wwv_flow_imp.g_varchar2_table(512) := '202020202020202020202773796D626F6C2D706C6163656D656E74273A20276C696E65272C0D0A202020202020202020202773796D626F6C2D73706163696E67273A203230302C0D0A2020202020202020202027746578742D6D61782D616E676C65273A';
wwv_flow_imp.g_varchar2_table(513) := '203336302C0D0A2020202020202020202027746578742D726F746174696F6E2D616C69676E6D656E74273A202776696577706F7274272C0D0A20202020202020207D2C0D0A20202020202020207061696E743A207B0D0A20202020202020202020277465';
wwv_flow_imp.g_varchar2_table(514) := '78742D636F6C6F72273A2027626C61636B272C0D0A2020202020202020202027746578742D68616C6F2D636F6C6F72273A20277768697465272C0D0A2020202020202020202027746578742D68616C6F2D7769647468273A20312C0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(515) := '207D2C0D0A2020202020207D293B0D0A202020207D0D0A0D0A2020202069662028705F7465727261696E5F66656174757265732E696E636C7564657328273364272929207B0D0A2020202020206966202868617356657273696F6E28352929207B0D0A20';
wwv_flow_imp.g_varchar2_table(516) := '202020202020206D61702E73657443656E746572436C616D706564546F47726F756E642866616C7365293B0D0A2020202020207D0D0A0D0A202020202020696620287465727261696E436F6E74726F6C29207B0D0A20202020202020206D61702E72656D';
wwv_flow_imp.g_varchar2_table(517) := '6F7665436F6E74726F6C287465727261696E436F6E74726F6C293B0D0A2020202020207D0D0A0D0A2020202020207465727261696E436F6E74726F6C203D206E6577206D61706C69627265676C2E5465727261696E436F6E74726F6C287B0D0A20202020';
wwv_flow_imp.g_varchar2_table(518) := '20202020736F757263653A202767656F72617374657244454D3364536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F69642C0D0A2020202020202020657861676765726174696F6E3A207061727365466C';
wwv_flow_imp.g_varchar2_table(519) := '6F617428705F657861676765726174696F6E203F3F2031292C0D0A2020202020207D293B0D0A2020202020206D61702E616464436F6E74726F6C287465727261696E436F6E74726F6C293B0D0A202020207D0D0A0D0A202020207365744C617965725669';
wwv_flow_imp.g_varchar2_table(520) := '736962696C69747950726F7028293B0D0A20207D3B0D0A20206164644C6179657228293B0D0A0D0A20202F2F20696D706C656D656E7420746865206D61706C69627265207261737465722074696C652070726F746F636F6C2E20546869732077696C6C20';
wwv_flow_imp.g_varchar2_table(521) := '62652063616C6C6564206279206D61706C696272650D0A20206966202870726F746F43616C6C6261636B29207B0D0A202020206D61706C69627265676C2E61646450726F746F636F6C282767656F7261737465725F27202B20705F6974656D5F69642C20';
wwv_flow_imp.g_varchar2_table(522) := '28706172616D732C2063616C6C6261636B29203D3E207B0D0A20202020202067656F7261737465725F70726F746F636F6C28706172616D732C206E756C6C290D0A20202020202020202E7468656E2828726573756C7429203D3E207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(523) := '2020202063616C6C6261636B286E756C6C2C20726573756C742E646174612C206E756C6C2C206E756C6C293B0D0A20202020202020207D290D0A20202020202020202E636174636828286572726F7229203D3E207B0D0A2020202020202020202063616C';
wwv_flow_imp.g_varchar2_table(524) := '6C6261636B286572726F72293B0D0A20202020202020207D293B0D0A20202020202072657475726E207B2063616E63656C3A202829203D3E207B207D207D3B0D0A202020207D293B0D0A20207D20656C7365207B0D0A202020206D61706C69627265676C';
wwv_flow_imp.g_varchar2_table(525) := '2E61646450726F746F636F6C282767656F7261737465725F27202B20705F6974656D5F69642C206173796E632028706172616D732C2061626F7274436F6E74726F6C6C657229203D3E207B0D0A20202020202072657475726E2061776169742067656F72';
wwv_flow_imp.g_varchar2_table(526) := '61737465725F70726F746F636F6C28706172616D732C2061626F7274436F6E74726F6C6C6572293B0D0A202020207D293B0D0A20207D0D0A0D0A2020636F6E73742073686F77203D202829203D3E207B0D0A202020206C436F6F6B6965203D2027766973';
wwv_flow_imp.g_varchar2_table(527) := '69626C65273B0D0A202020207365744C617965725669736962696C69747950726F7028293B0D0A20202020617065782E73746F726167652E736574436F6F6B696528274D6170626974735F47656F5261737465724C617965725F27202B20705F6974656D';
wwv_flow_imp.g_varchar2_table(528) := '5F69642B20225F22202B202476282270496E7374616E636522292C202776697369626C6527293B0D0A20202020617065782E6576656E742E7472696767657228272327202B20705F6974656D5F69642C20277669736962696C6974795F746F67676C6564';
wwv_flow_imp.g_varchar2_table(529) := '272C207B0D0A20202020202076697369626C653A20747275652C0D0A202020207D293B0D0A202020206D61702E7472696767657252657061696E7428293B0D0A20207D3B0D0A0D0A2020636F6E73742068696465203D202829203D3E207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(530) := '6C436F6F6B6965203D20276E6F6E65273B0D0A202020207365744C617965725669736962696C69747950726F7028293B0D0A20202020617065782E73746F726167652E736574436F6F6B696528274D6170626974735F47656F5261737465724C61796572';
wwv_flow_imp.g_varchar2_table(531) := '5F27202B20705F6974656D5F69642B20225F22202B202476282270496E7374616E636522292C20276E6F6E6527293B0D0A20202020617065782E6576656E742E7472696767657228272327202B20705F6974656D5F69642C20277669736962696C697479';
wwv_flow_imp.g_varchar2_table(532) := '5F746F67676C6564272C207B0D0A20202020202076697369626C653A2066616C73652C0D0A202020207D293B0D0A20207D3B0D0A0D0A2020636F6E7374206C6567656E64203D202428272327202B20705F726567696F6E5F6964202B20275F6C6567656E';
wwv_flow_imp.g_varchar2_table(533) := '6427293B0D0A20202428603C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E60290D0A202020202E617070656E64280D0A2020';
wwv_flow_imp.g_varchar2_table(534) := '202020202428603C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22223E60290D0A20202020202020202E';
wwv_flow_imp.g_varchar2_table(535) := '70726F70287B0D0A20202020202020202020276964273A20705F6974656D5F6964202B20275F6C6567656E645F656E747279272C0D0A2020202020202020202027636865636B6564273A206C436F6F6B696520213D3D20276E6F6E65272C0D0A20202020';
wwv_flow_imp.g_varchar2_table(536) := '202020207D290D0A20202020202020202E6F6E28276368616E6765272C20286529203D3E207B0D0A20202020202020202020636F6E7374206362203D20617065782E6A517565727928652E746172676574293B0D0A202020202020202020206966202863';
wwv_flow_imp.g_varchar2_table(537) := '622E697328273A636865636B6564272929207B0D0A20202020202020202020202073686F7728293B0D0A202020202020202020207D20656C7365207B0D0A2020202020202020202020206869646528293B0D0A202020202020202020207D0D0A20202020';
wwv_flow_imp.g_varchar2_table(538) := '202020207D290D0A20202020202020202E637373287B20272D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F72273A20705F636865636B626F785F636F6C6F72207D292C0D0A2020202020202428603C6C6162656C20636C6173733D';
wwv_flow_imp.g_varchar2_table(539) := '22612D4D6170526567696F6E2D6C6567656E644C6162656C223E60290D0A20202020202020202E70726F70287B0D0A20202020202020202020276964273A20705F6974656D5F6964202B20275F6C6567656E645F656E7472795F6C6162656C272C0D0A20';
wwv_flow_imp.g_varchar2_table(540) := '20202020202020202027666F72273A20705F6974656D5F6964202B20275F6C6567656E645F656E747279270D0A20202020202020207D290D0A20202020202020202E617070656E64280D0A20202020202020202020705F7469746C652C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(541) := '20202020202428603C7370616E20636C6173733D2266612066612D636972636C652D372D382066612D616E696D2D7370696E22207374796C653D22646973706C61793A206E6F6E653B206D617267696E2D6C6566743A202E35656D3B223E60292E70726F';
wwv_flow_imp.g_varchar2_table(542) := '7028276964272C20705F6974656D5F6964202B20275F6C6567656E645F656E7472795F73746174757327290D0A2020202020202020290D0A20202020290D0A202020202E617070656E64546F286C6567656E64293B0D0A0D0A2020617065782E6974656D';
wwv_flow_imp.g_varchar2_table(543) := '2E63726561746528705F6974656D5F69642C207B0D0A2020202073686F773A202829203D3E207B0D0A20202020202073686F7728293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E64';
wwv_flow_imp.g_varchar2_table(544) := '5F656E74727927292E70726F702827636865636B6564272C2074727565293B0D0A202020207D2C0D0A20202020686964653A202829203D3E207B0D0A2020202020206869646528293B0D0A202020202020617065782E6A517565727928272327202B2070';
wwv_flow_imp.g_varchar2_table(545) := '5F6974656D5F6964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A202020207D2C0D0A20202020697356697369626C653A202829203D3E206C436F6F6B696520213D3D20276E6F6E6527';
wwv_flow_imp.g_varchar2_table(546) := '2C0D0A0D0A20202020726566726573683A206173796E63202829203D3E207B0D0A20202020202061776169742072656672657368526173746572496E666F28293B0D0A0D0A2020202020202F2A20436C656172206361636865732C2073696E6365207468';
wwv_flow_imp.g_varchar2_table(547) := '652064617461206D6967687420626520646966666572656E74206E6F77202A2F0D0A20202020202074696C6543616368652E636C65617228293B0D0A202020202020636C656172436F6E746F757243616368657328293B0D0A0D0A202020202020696620';
wwv_flow_imp.g_varchar2_table(548) := '2868617356657273696F6E28352C20352C20302929207B0D0A2020202020202020666F722028636F6E73742073206F6620736F757263654E616D657329207B0D0A202020202020202020206D61702E7265667265736854696C65732873293B0D0A202020';
wwv_flow_imp.g_varchar2_table(549) := '20202020207D0D0A2020202020207D20656C7365207B0D0A2020202020202020666F722028636F6E7374206C206F66206C617965724E616D657329207B0D0A202020202020202020206D61702E72656D6F76654C61796572286C293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(550) := '20207D0D0A2020202020202020666F722028636F6E73742073206F6620736F757263654E616D657329207B0D0A202020202020202020206D61702E72656D6F7665536F757263652873293B0D0A20202020202020207D0D0A20202020202020206164644C';
wwv_flow_imp.g_varchar2_table(551) := '6179657228293B0D0A2020202020207D0D0A202020207D2C0D0A0D0A20202020746F67676C655261737465724C617965723A2028746F67676C6529203D3E207B0D0A20202020202069662028747970656F6620746F67676C65203D3D3D2027756E646566';
wwv_flow_imp.g_varchar2_table(552) := '696E65642729207B0D0A2020202020202020686964655261737465724C61796572203D2021686964655261737465724C617965723B0D0A2020202020207D20656C7365207B0D0A2020202020202020686964655261737465724C61796572203D2021746F';
wwv_flow_imp.g_varchar2_table(553) := '67676C653B0D0A2020202020207D0D0A2020202020207365744C617965725669736962696C69747950726F7028293B0D0A202020207D2C0D0A0D0A20202020746F67676C6548696C6C73686164654C617965723A2028746F67676C6529203D3E207B0D0A';
wwv_flow_imp.g_varchar2_table(554) := '20202020202069662028747970656F6620746F67676C65203D3D3D2027756E646566696E65642729207B0D0A20202020202020206869646548696C6C73686164654C61796572203D20216869646548696C6C73686164654C617965723B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(555) := '207D20656C7365207B0D0A20202020202020206869646548696C6C73686164654C61796572203D2021746F67676C653B0D0A2020202020207D0D0A2020202020207365744C617965725669736962696C69747950726F7028293B0D0A202020207D2C0D0A';
wwv_flow_imp.g_varchar2_table(556) := '0D0A20202020746F67676C65436F6E746F75724C617965723A2028746F67676C6529203D3E207B0D0A20202020202069662028747970656F6620746F67676C65203D3D3D2027756E646566696E65642729207B0D0A202020202020202068696465436F6E';
wwv_flow_imp.g_varchar2_table(557) := '746F75724C61796572203D202168696465436F6E746F75724C617965723B0D0A2020202020207D20656C7365207B0D0A202020202020202068696465436F6E746F75724C61796572203D2021746F67676C653B0D0A2020202020207D0D0A202020202020';
wwv_flow_imp.g_varchar2_table(558) := '7365744C617965725669736962696C69747950726F7028293B0D0A202020207D2C0D0A0D0A202020202F2A2A0D0A20202020202A205175657269657320746865206E65617265737420736F7572636520706978656C206279206C6F636174696F6E2E0D0A';
wwv_flow_imp.g_varchar2_table(559) := '20202020202A2F0D0A202020207175657279506978656C3A206173796E6320286C61742C206C6F6E2C207A203D20313929203D3E207B0D0A202020202020636F6E73742079203D206C61743274696C65287A2C206C6174293B0D0A202020202020636F6E';
wwv_flow_imp.g_varchar2_table(560) := '73742078203D206C6F6E3274696C65287A2C206C6F6E293B0D0A202020202020636F6E73742074696C65203D2061776169742067657454696C65287A2C204D6174682E666C6F6F722878292C204D6174682E666C6F6F72287929293B0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(561) := '20206966202874696C652E63656C6C6461746129207B0D0A2020202020202020636F6E7374206461746176696577203D206E65772044617461566965772874696C652E63656C6C64617461293B0D0A2020202020202020636F6E73742064657074684279';
wwv_flow_imp.g_varchar2_table(562) := '746573203D2074696C652E63656C6C6465707468202F20383B0D0A2020202020202020636F6E737420706978656C4C656E677468203D2074696C652E62616E64636F756E74202A20646570746842797465733B0D0A2020202020202020636F6E73742072';
wwv_flow_imp.g_varchar2_table(563) := '6573756C74203D205B5D3B0D0A0D0A2020202020202020636F6E7374207078203D204D6174682E666C6F6F722828782025203129202A2074696C652E7769647468293B0D0A2020202020202020636F6E7374207079203D204D6174682E666C6F6F722828';
wwv_flow_imp.g_varchar2_table(564) := '792025203129202A2074696C652E686569676874293B0D0A2020202020202020636F6E7374207069203D20287079202A2074696C652E776964746829202B2070783B0D0A0D0A2020202020202020666F7220286C65742062203D20303B2062203C207469';
wwv_flow_imp.g_varchar2_table(565) := '6C652E62616E64636F756E743B2062202B2B29207B0D0A202020202020202020206966202874696C652E63656C6C6465707468203D3D203829207B0D0A202020202020202020202020726573756C742E707573682864617461766965772E67657455696E';
wwv_flow_imp.g_varchar2_table(566) := '7438287069202A20706978656C4C656E677468202B2062202A206465707468427974657329293B0D0A202020202020202020207D20656C7365206966202874696C652E63656C6C6465707468203D3D20333229207B0D0A20202020202020202020202072';
wwv_flow_imp.g_varchar2_table(567) := '6573756C742E707573682864617461766965772E676574466C6F61743332287069202A20706978656C4C656E677468202B2062202A206465707468427974657329293B0D0A202020202020202020207D0D0A20202020202020207D0D0A0D0A2020202020';
wwv_flow_imp.g_varchar2_table(568) := '20202072657475726E20726573756C743B0D0A2020202020207D20656C7365207B0D0A202020202020202072657475726E206E756C6C3B0D0A2020202020207D0D0A202020207D2C0D0A20207D293B0D0A0D0A202069662028705F6974656D5F69642069';
wwv_flow_imp.g_varchar2_table(569) := '6E204D4150424954535F47454F5241535445525F57414954494E4729207B0D0A20202020636F6E7374206974656D203D20617065782E6974656D28705F6974656D5F6964293B0D0A202020204D4150424954535F47454F5241535445525F57414954494E';
wwv_flow_imp.g_varchar2_table(570) := '475B705F6974656D5F69645D2E666F724561636828287829203D3E2078286974656D29293B0D0A20207D0D0A20204D4150424954535F47454F5241535445525F57414954494E475B705F6974656D5F69645D203D206E756C6C3B0D0A7D0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43408536525713270)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_file_name=>'mapbits_georaster.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6D61706C69627265676C2D6374726C20627574746F6E2E6D61706C69627265676C2D6374726C2D7465727261696E202E6D61706C69627265676C2D6374726C2D69636F6E2C2E6D61706C69627265676C2D6374726C20627574746F6E2E6D61706C6962';
wwv_flow_imp.g_varchar2_table(2) := '7265676C2D6374726C2D7465727261696E2D656E61626C6564202E6D61706C69627265676C2D6374726C2D69636F6E7B6261636B67726F756E642D696D6167653A75726C2822646174613A696D6167652F7376672B786D6C3B636861727365743D757466';
wwv_flow_imp.g_varchar2_table(3) := '2D382C25334373766720786D6C6E733D27687474703A2F2F7777772E77332E6F72672F323030302F737667272077696474683D27323227206865696768743D273232272066696C6C3D27253233333333272076696577426F783D27302030203232203232';
wwv_flow_imp.g_varchar2_table(4) := '272533452533437061746820643D276D312E3735342031332E34303620342E3435332D342E38353120332E303920332E303920332E32383120332E3237372E3936392D2E3936392D332E3330392D332E33313220332E3834342D342E31323120362E3134';
wwv_flow_imp.g_varchar2_table(5) := '3820362E38383668312E303832762D2E3835356C2D372E3230372D382E30372D342E383420352E3138374C362E31363920362E35376C2D352E343820352E393635762E3837315A4D2E3638382031362E3834346832302E36323576312E333735482E3638';
wwv_flow_imp.g_varchar2_table(6) := '385A6D302030272F2533452533432F73766725334522293B6261636B67726F756E642D706F736974696F6E3A3530253B6261636B67726F756E642D7265706561743A6E6F2D7265706561743B646973706C61793A626C6F636B3B6865696768743A353025';
wwv_flow_imp.g_varchar2_table(7) := '3B77696474683A3530253B6D617267696E3A6175746F7D2E6D61706C69627265676C2D6374726C20627574746F6E2E6D61706C69627265676C2D6374726C2D7465727261696E2D656E61626C6564202E6D61706C69627265676C2D6374726C2D69636F6E';
wwv_flow_imp.g_varchar2_table(8) := '7B6261636B67726F756E642D696D6167653A75726C2822646174613A696D6167652F7376672B786D6C3B636861727365743D7574662D382C25334373766720786D6C6E733D27687474703A2F2F7777772E77332E6F72672F323030302F73766727207769';
wwv_flow_imp.g_varchar2_table(9) := '6474683D27323227206865696768743D273232272066696C6C3D27253233333362356535272076696577426F783D27302030203232203232272533452533437061746820643D276D312E3735342031332E34303620342E3435332D342E38353120332E30';
wwv_flow_imp.g_varchar2_table(10) := '3920332E303920332E32383120332E3237372E3936392D2E3936392D332E3330392D332E33313220332E3834342D342E31323120362E31343820362E38383668312E303832762D2E3835356C2D372E3230372D382E30372D342E383420352E3138374C36';
wwv_flow_imp.g_varchar2_table(11) := '2E31363920362E35376C2D352E343820352E393635762E3837315A4D2E3638382031362E3834346832302E36323576312E333735482E3638385A6D302030272F2533452533432F73766725334522297D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(43408991669713270)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_file_name=>'mapbits_georaster.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2166756E6374696F6E28742C65297B226F626A656374223D3D747970656F66206578706F727473262622756E646566696E656422213D747970656F66206D6F64756C653F6D6F64756C652E6578706F7274733D6528293A2266756E6374696F6E223D3D74';
wwv_flow_imp.g_varchar2_table(2) := '7970656F6620646566696E652626646566696E652E616D643F646566696E652865293A28743D22756E646566696E656422213D747970656F6620676C6F62616C546869733F676C6F62616C546869733A747C7C73656C66292E6D6C636F6E746F75723D65';
wwv_flow_imp.g_varchar2_table(3) := '28297D28746869732C2866756E6374696F6E28297B2275736520737472696374223B76617220742C652C693B66756E6374696F6E207228722C73297B696628742969662865297B766172206E3D22766172207368617265644368756E6B203D207B7D3B20';
wwv_flow_imp.g_varchar2_table(4) := '28222B742B2229287368617265644368756E6B293B2028222B652B2229287368617265644368756E6B293B222C6F3D7B7D3B74286F292C693D73286F292C22756E646566696E656422213D747970656F662077696E646F77262628692E776F726B657255';
wwv_flow_imp.g_varchar2_table(5) := '726C3D77696E646F772E55524C2E6372656174654F626A65637455524C286E657720426C6F62285B6E5D2C7B747970653A22746578742F6A617661736372697074227D2929297D656C736520653D733B656C736520743D737D72657475726E207228302C';
wwv_flow_imp.g_varchar2_table(6) := '2866756E6374696F6E2874297B636C61737320657B636F6E7374727563746F7228742C65297B746869732E73746172743D742C746869732E656E643D652C746869732E706F696E74733D5B5D2C746869732E617070656E643D746869732E617070656E64';
wwv_flow_imp.g_varchar2_table(7) := '2E62696E642874686973292C746869732E70726570656E643D746869732E70726570656E642E62696E642874686973297D617070656E6428742C65297B746869732E706F696E74732E70757368284D6174682E726F756E642874292C4D6174682E726F75';
wwv_flow_imp.g_varchar2_table(8) := '6E64286529297D70726570656E6428742C65297B746869732E706F696E74732E73706C69636528302C302C4D6174682E726F756E642874292C4D6174682E726F756E64286529297D6C696E65537472696E6728297B72657475726E20746869732E746F41';
wwv_flow_imp.g_varchar2_table(9) := '7272617928297D6973456D70747928297B72657475726E20746869732E706F696E74732E6C656E6774683C327D617070656E64467261676D656E742874297B746869732E706F696E74732E70757368282E2E2E742E706F696E7473292C746869732E656E';
wwv_flow_imp.g_varchar2_table(10) := '643D742E656E647D746F417272617928297B72657475726E20746869732E706F696E74737D7D636F6E737420693D5B5B5D2C5B5B5B312C325D2C5B302C315D5D5D2C5B5B5B322C315D2C5B312C325D5D5D2C5B5B5B322C315D2C5B302C315D5D5D2C5B5B';
wwv_flow_imp.g_varchar2_table(11) := '5B312C305D2C5B322C315D5D5D2C5B5B5B312C325D2C5B302C315D5D2C5B5B312C305D2C5B322C315D5D5D2C5B5B5B312C305D2C5B312C325D5D5D2C5B5B5B312C305D2C5B302C315D5D5D2C5B5B5B302C315D2C5B312C305D5D5D2C5B5B5B312C325D2C';
wwv_flow_imp.g_varchar2_table(12) := '5B312C305D5D5D2C5B5B5B302C315D2C5B312C305D5D2C5B5B322C315D2C5B312C325D5D5D2C5B5B5B322C315D2C5B312C305D5D5D2C5B5B5B302C315D2C5B322C315D5D5D2C5B5B5B312C325D2C5B322C315D5D5D2C5B5B5B302C315D2C5B312C325D5D';
wwv_flow_imp.g_varchar2_table(13) := '5D2C5B5D5D3B66756E6374696F6E207228742C652C692C72297B72657475726E28653D322A652B725B305D292B28693D322A692B725B315D292A28742B31292A327D66756E6374696F6E207328742C652C69297B72657475726E28652D74292F28692D74';
wwv_flow_imp.g_varchar2_table(14) := '297D66756E6374696F6E206E28742C6E2C6F3D343039362C613D31297B69662821742972657475726E7B7D3B636F6E737420683D6F2F286E2E77696474682D31293B6C6574206C2C632C642C752C662C703B636F6E737420773D7B7D2C673D6E6577204D';
wwv_flow_imp.g_varchar2_table(15) := '61702C6D3D6E6577204D61703B66756E6374696F6E206228742C652C69297B303D3D3D745B305D3F6928682A28702D31292C682A28662D7328642C652C6C2929293A323D3D3D745B305D3F6928682A702C682A28662D7328752C652C632929293A303D3D';
wwv_flow_imp.g_varchar2_table(16) := '3D745B315D3F6928682A28702D7328632C652C6C29292C682A28662D3129293A6928682A28702D7328752C652C6429292C682A66297D666F7228663D312D613B663C6E2E6865696768742B613B662B2B297B633D6E2E67657428302C662D31292C753D6E';
wwv_flow_imp.g_varchar2_table(17) := '2E67657428302C66293B6C657420733D4D6174682E6D696E28632C75292C6F3D4D6174682E6D617828632C75293B666F7228703D312D613B703C6E2E77696474682B613B702B2B297B6C3D632C643D752C633D6E2E67657428702C662D31292C753D6E2E';
wwv_flow_imp.g_varchar2_table(18) := '67657428702C66293B636F6E737420613D732C683D6F3B696628733D4D6174682E6D696E28632C75292C6F3D4D6174682E6D617828632C75292C69734E614E286C297C7C69734E614E2863297C7C69734E614E2875297C7C69734E614E28642929636F6E';
wwv_flow_imp.g_varchar2_table(19) := '74696E75653B636F6E737420793D4D6174682E6D696E28612C73292C763D4D6174682E6D617828682C6F292C503D4D6174682E6365696C28792F74292A742C783D4D6174682E666C6F6F7228762F74292A743B666F72286C657420733D503B733C3D783B';
wwv_flow_imp.g_varchar2_table(20) := '732B3D74297B636F6E737420743D6C3E732C6F3D633E732C613D643E732C683D753E733B666F7228636F6E7374206C206F6620695B28743F383A30297C286F3F343A30297C28683F323A30297C28613F313A30295D297B6C657420743D672E6765742873';
wwv_flow_imp.g_varchar2_table(21) := '293B747C7C672E73657428732C743D6E6577204D6170293B6C657420693D6D2E6765742873293B697C7C6D2E73657428732C693D6E6577204D6170293B636F6E7374206F3D6C5B305D2C613D6C5B315D2C683D72286E2E77696474682C702C662C6F292C';
wwv_flow_imp.g_varchar2_table(22) := '633D72286E2E77696474682C702C662C61293B6C657420642C753B696628643D692E67657428682929696628692E64656C6574652868292C753D742E67657428632929696628742E64656C6574652863292C643D3D3D75297B6966286228612C732C642E';
wwv_flow_imp.g_varchar2_table(23) := '617070656E64292C21642E6973456D7074792829297B6C657420743D775B735D3B747C7C28775B735D3D743D5B5D292C742E7075736828642E6C696E65537472696E672829297D7D656C736520642E617070656E64467261676D656E742875292C692E73';
wwv_flow_imp.g_varchar2_table(24) := '657428642E656E643D752E656E642C64293B656C7365206228612C732C642E617070656E64292C692E73657428642E656E643D632C64293B656C736520696628643D742E67657428632929742E64656C6574652863292C62286F2C732C642E7072657065';
wwv_flow_imp.g_varchar2_table(25) := '6E64292C742E73657428642E73746172743D682C64293B656C73657B636F6E737420723D6E6577206528682C63293B62286F2C732C722E617070656E64292C6228612C732C722E617070656E64292C742E73657428682C72292C692E73657428632C7229';
wwv_flow_imp.g_varchar2_table(26) := '7D7D7D7D7D666F7228636F6E73745B742C655D6F6620672E656E74726965732829297B6C657420693D6E756C6C3B666F7228636F6E73742072206F6620652E76616C756573282929722E6973456D70747928297C7C286E756C6C3D3D69262628693D775B';
wwv_flow_imp.g_varchar2_table(27) := '745D7C7C28775B745D3D5B5D29292C692E7075736828722E6C696E65537472696E67282929297D72657475726E20777D0D0A2F2A21202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_imp.g_varchar2_table(28) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A20202020436F7079726967687420286329204D6963726F736F667420436F72706F726174696F6E2E0D0A0D0A202020205065726D697373696F6E20746F207573652C20';
wwv_flow_imp.g_varchar2_table(29) := '636F70792C206D6F646966792C20616E642F6F722064697374726962757465207468697320736F66747761726520666F7220616E790D0A20202020707572706F73652077697468206F7220776974686F7574206665652069732068657265627920677261';
wwv_flow_imp.g_varchar2_table(30) := '6E7465642E0D0A0D0A2020202054484520534F4654574152452049532050524F5649444544202241532049532220414E442054484520415554484F5220444953434C41494D5320414C4C2057415252414E5449455320574954480D0A2020202052454741';
wwv_flow_imp.g_varchar2_table(31) := '524420544F205448495320534F46545741524520494E434C5544494E4720414C4C20494D504C4945442057415252414E54494553204F46204D45524348414E544142494C4954590D0A20202020414E44204649544E4553532E20494E204E4F204556454E';
wwv_flow_imp.g_varchar2_table(32) := '54205348414C4C2054484520415554484F52204245204C4941424C4520464F5220414E59205350454349414C2C204449524543542C0D0A20202020494E4449524543542C204F5220434F4E53455155454E5449414C2044414D41474553204F5220414E59';
wwv_flow_imp.g_varchar2_table(33) := '2044414D414745532057484154534F4556455220524553554C54494E472046524F4D0D0A202020204C4F5353204F46205553452C2044415441204F522050524F464954532C205748455448455220494E20414E20414354494F4E204F4620434F4E545241';
wwv_flow_imp.g_varchar2_table(34) := '43542C204E45474C4947454E4345204F520D0A202020204F5448455220544F5254494F555320414354494F4E2C2041524953494E47204F5554204F46204F5220494E20434F4E4E454354494F4E20574954482054484520555345204F520D0A2020202050';
wwv_flow_imp.g_varchar2_table(35) := '4552464F524D414E4345204F46205448495320534F4654574152452E0D0A202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_imp.g_varchar2_table(36) := '2A2A2A2A2A2A2A2A2A2A2A202A2F66756E6374696F6E206F28742C65297B76617220693D7B7D3B666F7228766172207220696E2074294F626A6563742E70726F746F747970652E6861734F776E50726F70657274792E63616C6C28742C72292626652E69';
wwv_flow_imp.g_varchar2_table(37) := '6E6465784F662872293C30262628695B725D3D745B725D293B6966286E756C6C213D7426262266756E6374696F6E223D3D747970656F66204F626A6563742E6765744F776E50726F706572747953796D626F6C73297B76617220733D303B666F7228723D';
wwv_flow_imp.g_varchar2_table(38) := '4F626A6563742E6765744F776E50726F706572747953796D626F6C732874293B733C722E6C656E6774683B732B2B29652E696E6465784F6628725B735D293C3026264F626A6563742E70726F746F747970652E70726F70657274794973456E756D657261';
wwv_flow_imp.g_varchar2_table(39) := '626C652E63616C6C28742C725B735D29262628695B725B735D5D3D745B725B735D5D297D72657475726E20697D66756E6374696F6E206128742C652C692C72297B72657475726E206E657728697C7C28693D50726F6D6973652929282866756E6374696F';
wwv_flow_imp.g_varchar2_table(40) := '6E28732C6E297B66756E6374696F6E206F2874297B7472797B6828722E6E657874287429297D63617463682874297B6E2874297D7D66756E6374696F6E20612874297B7472797B6828722E7468726F77287429297D63617463682874297B6E2874297D7D';
wwv_flow_imp.g_varchar2_table(41) := '66756E6374696F6E20682874297B76617220653B742E646F6E653F7328742E76616C7565293A28653D742E76616C75652C6520696E7374616E63656F6620693F653A6E65772069282866756E6374696F6E2874297B742865297D2929292E7468656E286F';
wwv_flow_imp.g_varchar2_table(42) := '2C61297D682828723D722E6170706C7928742C657C7C5B5D29292E6E6578742829297D29297D66756E6374696F6E20682874297B636F6E737420653D4F626A6563742E656E74726965732874293B72657475726E20652E736F72742828285B745D2C5B65';
wwv_flow_imp.g_varchar2_table(43) := '5D293D3E743C653F2D313A743E653F313A3029292C657D66756E6374696F6E206C2874297B72657475726E20682874292E6D61702828285B742C655D293D3E5B742C2E2E2E226E756D626572223D3D747970656F6620653F5B655D3A655D2E6A6F696E28';
wwv_flow_imp.g_varchar2_table(44) := '222A222929292E6A6F696E28227E22297D66756E6374696F6E20632874297B72657475726E20682874292E6D61702828285B742C655D293D3E60247B656E636F6465555249436F6D706F6E656E742874297D3D247B656E636F6465555249436F6D706F6E';
wwv_flow_imp.g_varchar2_table(45) := '656E742865297D6029292E6A6F696E28222C22297D6C657420643D6E756C6C3B66756E6374696F6E207528297B72657475726E206E756C6C3D3D64262628643D22756E646566696E656422213D747970656F66204F666673637265656E43616E76617326';
wwv_flow_imp.g_varchar2_table(46) := '266E6577204F666673637265656E43616E76617328312C31292E676574436F6E7465787428223264222926262266756E6374696F6E223D3D747970656F6620637265617465496D6167654269746D6170292C647C7C21317D6C657420663D6E756C6C3B66';
wwv_flow_imp.g_varchar2_table(47) := '756E6374696F6E207028742C652C69297B6C657420723D28293D3E7B7D3B636F6E737420733D73657454696D656F7574282828293D3E7B72286E6577204572726F72282274696D6564206F75742229292C6E756C6C3D3D697C7C692E61626F727428297D';
wwv_flow_imp.g_varchar2_table(48) := '292C74293B7728692C2828293D3E7B72286E6577204572726F72282261626F727465642229292C636C65617254696D656F75742873297D29293B636F6E7374206E3D6E65772050726F6D697365282828742C65293D3E7B723D657D29293B72657475726E';
wwv_flow_imp.g_varchar2_table(49) := '2050726F6D6973652E72616365285B6E2C652E66696E616C6C79282828293D3E636C65617254696D656F757428732929295D297D66756E6374696F6E207728742C65297B652626286E756C6C3D3D747C7C742E7369676E616C2E6164644576656E744C69';
wwv_flow_imp.g_varchar2_table(50) := '7374656E6572282261626F7274222C6529297D66756E6374696F6E20672874297B76617220653B72657475726E20426F6F6C65616E286E756C6C3D3D3D28653D6E756C6C3D3D743F766F696420303A742E7369676E616C297C7C766F696420303D3D3D65';
wwv_flow_imp.g_varchar2_table(51) := '3F766F696420303A652E61626F72746564297D6C6574206D2C622C792C762C503D303B636C61737320787B636F6E7374727563746F7228743D313030297B746869732E73697A653D28293D3E746869732E6974656D732E73697A652C746869732E676574';
wwv_flow_imp.g_varchar2_table(52) := '3D28742C652C69293D3E7B6C657420723D746869732E6974656D732E6765742874293B6966287229722E6C617374557365643D2B2B502C722E77616974696E672B2B3B656C73657B636F6E737420693D6E65772041626F7274436F6E74726F6C6C65722C';
wwv_flow_imp.g_varchar2_table(53) := '733D6528742C69293B723D7B61626F7274436F6E74726F6C6C65723A692C6974656D3A732C6C617374557365643A2B2B502C77616974696E673A317D2C746869732E6974656D732E73657428742C72292C746869732E7072756E6528297D636F6E737420';
wwv_flow_imp.g_varchar2_table(54) := '733D746869732E6974656D732C6E3D722E6974656D2E7468656E2828743D3E74292C28653D3E28732E64656C6574652874292C50726F6D6973652E72656A6563742865292929293B6C6574206F3D21313B72657475726E207728692C2828293D3E7B7661';
wwv_flow_imp.g_varchar2_table(55) := '7220653B722626722E61626F7274436F6E74726F6C6C65722626216F2626286F3D21302C2D2D722E77616974696E673C3D302626286E756C6C3D3D3D28653D722E61626F7274436F6E74726F6C6C6572297C7C766F696420303D3D3D657C7C652E61626F';
wwv_flow_imp.g_varchar2_table(56) := '727428292C732E64656C65746528742929297D29292C6E7D2C746869732E636C6561723D28293D3E746869732E6974656D732E636C65617228292C746869732E6D617853697A653D742C746869732E6974656D733D6E6577204D61707D7072756E652829';
wwv_flow_imp.g_varchar2_table(57) := '7B696628746869732E6974656D732E73697A653E746869732E6D617853697A65297B6C657420742C653D312F303B746869732E6974656D732E666F7245616368282828692C72293D3E7B692E6C617374557365643C65262628653D692E6C617374557365';
wwv_flow_imp.g_varchar2_table(58) := '642C743D72297D29292C766F69642030213D3D742626746869732E6974656D732E64656C6574652874297D7D7D66756E6374696F6E204628742C65297B72657475726E206D7C7C286D3D6E6577204F666673637265656E43616E76617328742E77696474';
wwv_flow_imp.g_varchar2_table(59) := '682C742E686569676874292C623D6D2E676574436F6E7465787428223264222C7B77696C6C526561644672657175656E746C793A21307D29292C5628742C652C6D2C62297D636F6E7374206B3D66756E6374696F6E28297B6966286E756C6C3D3D662626';
wwv_flow_imp.g_varchar2_table(60) := '28663D21312C752829262622756E646566696E656422213D747970656F6620566964656F4672616D6529297B636F6E737420743D352C653D6E6577204F666673637265656E43616E76617328352C35292E676574436F6E7465787428223264222C7B7769';
wwv_flow_imp.g_varchar2_table(61) := '6C6C526561644672657175656E746C793A21307D293B69662865297B666F72286C657420693D303B693C742A743B692B2B297B636F6E737420723D342A693B652E66696C6C5374796C653D6072676228247B727D2C247B722B317D2C247B722B327D2960';
wwv_flow_imp.g_varchar2_table(62) := '2C652E66696C6C52656374286925742C4D6174682E666C6F6F7228692F74292C312C31297D636F6E737420693D652E676574496D6167654461746128302C302C742C74292E646174613B666F72286C657420653D303B653C742A742A343B652B2B296966';
wwv_flow_imp.g_varchar2_table(63) := '28652534213D332626695B655D213D3D65297B663D21303B627265616B7D7D7D72657475726E20667C7C21317D28293F66756E6374696F6E28742C652C69297B72657475726E206128746869732C766F696420302C766F696420302C2866756E6374696F';
wwv_flow_imp.g_varchar2_table(64) := '6E2A28297B76617220722C732C6E3B636F6E7374206F3D7969656C6420637265617465496D6167654269746D61702874293B696628672869292972657475726E206E756C6C3B636F6E737420613D6E657720566964656F4672616D65286F2C7B74696D65';
wwv_flow_imp.g_varchar2_table(65) := '7374616D703A307D293B7472797B6966282128286E756C6C3D3D3D28723D6E756C6C3D3D613F766F696420303A612E666F726D6174297C7C766F696420303D3D3D723F766F696420303A722E7374617274735769746828224247522229297C7C286E756C';
wwv_flow_imp.g_varchar2_table(66) := '6C3D3D3D28733D6E756C6C3D3D613F766F696420303A612E666F726D6174297C7C766F696420303D3D3D733F766F696420303A732E73746172747357697468282252474222292929297468726F77206E6577204572726F722860556E7265636F676E697A';
wwv_flow_imp.g_varchar2_table(67) := '656420666F726D61743A20247B6E756C6C3D3D613F766F696420303A612E666F726D61747D60293B636F6E737420743D6E756C6C3D3D3D286E3D6E756C6C3D3D613F766F696420303A612E666F726D6174297C7C766F696420303D3D3D6E3F766F696420';
wwv_flow_imp.g_varchar2_table(68) := '303A6E2E73746172747357697468282242475222292C693D612E616C6C6F636174696F6E53697A6528292C683D6E65772055696E7438436C616D70656441727261792869293B6966287969656C6420612E636F7079546F2868292C7429666F72286C6574';
wwv_flow_imp.g_varchar2_table(69) := '20743D303B743C682E6C656E6774683B742B3D34297B636F6E737420653D685B745D3B685B745D3D685B742B325D2C685B742B325D3D657D72657475726E204D286F2E77696474682C6F2E6865696768742C652C68297D63617463682874297B72657475';
wwv_flow_imp.g_varchar2_table(70) := '726E20672869293F6E756C6C3A46286F2C65297D66696E616C6C797B612E636C6F736528297D7D29297D3A7528293F66756E6374696F6E28742C652C69297B72657475726E206128746869732C766F696420302C766F696420302C2866756E6374696F6E';
wwv_flow_imp.g_varchar2_table(71) := '2A28297B636F6E737420723D7969656C6420637265617465496D6167654269746D61702874293B72657475726E20672869293F6E756C6C3A4628722C65297D29297D3A22756E646566696E656422213D747970656F6620576F726B6572476C6F62616C53';
wwv_flow_imp.g_varchar2_table(72) := '636F7065262622756E646566696E656422213D747970656F662073656C66262673656C6620696E7374616E63656F6620576F726B6572476C6F62616C53636F70653F66756E6374696F6E28742C652C69297B72657475726E2073656C662E6163746F722E';
wwv_flow_imp.g_varchar2_table(73) := '73656E6428226465636F6465496D616765222C5B5D2C692C766F696420302C742C65297D3A66756E6374696F6E28742C652C69297B72657475726E206128746869732C766F696420302C766F696420302C2866756E6374696F6E2A28297B797C7C28793D';
wwv_flow_imp.g_varchar2_table(74) := '646F63756D656E742E637265617465456C656D656E74282263616E76617322292C763D792E676574436F6E7465787428223264222C7B77696C6C526561644672657175656E746C793A21307D29293B636F6E737420723D6E657720496D6167653B772869';
wwv_flow_imp.g_varchar2_table(75) := '2C2828293D3E722E7372633D222229293B72657475726E2056287969656C64206E65772050726F6D697365282828652C73293D3E7B722E6F6E6C6F61643D28293D3E7B672869297C7C652872292C55524C2E7265766F6B654F626A65637455524C28722E';
wwv_flow_imp.g_varchar2_table(76) := '737263292C722E6F6E6C6F61643D6E756C6C7D2C722E6F6E6572726F723D28293D3E73286E6577204572726F722822436F756C64206E6F74206C6F616420696D6167652E2229292C722E7372633D742E73697A653F55524C2E6372656174654F626A6563';
wwv_flow_imp.g_varchar2_table(77) := '7455524C2874293A22227D29292C652C792C76297D29297D3B66756E6374696F6E205628742C652C692C72297B696628692E77696474683D742E77696474682C692E6865696768743D742E6865696768742C2172297468726F77206E6577204572726F72';
wwv_flow_imp.g_varchar2_table(78) := '28226661696C656420746F2067657420636F6E7465787422293B722E64726177496D61676528742C302C302C742E77696474682C742E686569676874293B636F6E737420733D722E676574496D6167654461746128302C302C742E77696474682C742E68';
wwv_flow_imp.g_varchar2_table(79) := '6569676874292E646174613B72657475726E204D28742E77696474682C742E6865696768742C652C73297D66756E6374696F6E204D28742C652C692C72297B636F6E737420733D226D6170626F78223D3D3D693F28742C652C69293D3E2E312A28323536';
wwv_flow_imp.g_varchar2_table(80) := '2A742A3235362B3235362A652B69292D3165343A28742C652C69293D3E3235362A742B652B692F3235362D33323736382C6E3D6E657720466C6F61743332417272617928742A65293B666F72286C657420743D303B743C722E6C656E6774683B742B3D34';
wwv_flow_imp.g_varchar2_table(81) := '296E5B742F345D3D7328725B745D2C725B742B315D2C725B742B325D293B72657475726E7B77696474683A742C6865696768743A652C646174613A6E7D7D636C61737320537B636F6E7374727563746F7228742C652C69297B746869732E73706C69743D';
wwv_flow_imp.g_varchar2_table(82) := '28742C652C69293D3E7B696628303D3D3D742972657475726E20746869733B636F6E737420723D313C3C742C733D652A746869732E77696474682F722C6E3D692A746869732E6865696768742F723B72657475726E206E6577205328746869732E776964';
wwv_flow_imp.g_varchar2_table(83) := '74682F722C746869732E6865696768742F722C2828742C65293D3E746869732E67657428742B732C652B6E2929297D2C746869732E73756273616D706C65506978656C43656E746572733D743D3E7B636F6E737420653D28742C652C69293D3E69734E61';
wwv_flow_imp.g_varchar2_table(84) := '4E2874293F653A69734E614E2865293F743A742B28652D74292A693B696628743C3D312972657475726E20746869733B636F6E737420693D2E352D312F28322A74293B72657475726E206E6577205328746869732E77696474682A742C746869732E6865';
wwv_flow_imp.g_varchar2_table(85) := '696768742A742C2828722C73293D3E7B636F6E7374206E3D722F742D692C6F3D732F742D692C613D4D6174682E666C6F6F72286E292C683D4D6174682E666C6F6F72286F292C6C3D746869732E67657428612C68292C633D746869732E67657428612B31';
wwv_flow_imp.g_varchar2_table(86) := '2C68292C643D746869732E67657428612C682B31292C753D746869732E67657428612B312C682B31292C663D6E2D612C703D6F2D682C773D65286C2C632C66292C673D6528642C752C66293B72657475726E206528772C672C70297D29297D2C74686973';
wwv_flow_imp.g_varchar2_table(87) := '2E61766572616765506978656C43656E74657273546F477269643D28743D31293D3E6E6577205328746869732E77696474682B312C746869732E6865696768742B312C2828652C69293D3E7B6C657420723D302C733D302C6E3D303B666F72286C657420';
wwv_flow_imp.g_varchar2_table(88) := '6F3D652D743B6F3C652B743B6F2B2B29666F72286C657420653D692D743B653C692B743B652B2B2969734E614E286E3D746869732E676574286F2C6529297C7C28732B2B2C722B3D6E293B72657475726E20303D3D3D733F4E614E3A722F737D29292C74';
wwv_flow_imp.g_varchar2_table(89) := '6869732E7363616C65456C65766174696F6E3D743D3E313D3D3D743F746869733A6E6577205328746869732E77696474682C746869732E6865696768742C2828652C69293D3E746869732E67657428652C69292A7429292C746869732E6D617465726961';
wwv_flow_imp.g_varchar2_table(90) := '6C697A653D28743D32293D3E7B636F6E737420653D746869732E77696474682B322A742C693D6E657720466C6F61743332417272617928652A28746869732E6865696768742B322A7429293B6C657420723D303B666F72286C657420653D2D743B653C74';
wwv_flow_imp.g_varchar2_table(91) := '6869732E6865696768742B743B652B2B29666F72286C657420733D2D743B733C746869732E77696474682B743B732B2B29695B722B2B5D3D746869732E67657428732C65293B72657475726E206E6577205328746869732E77696474682C746869732E68';
wwv_flow_imp.g_varchar2_table(92) := '65696768742C2828722C73293D3E695B28732B74292A652B722B745D29297D2C746869732E6765743D692C746869732E77696474683D742C746869732E6865696768743D657D7374617469632066726F6D52617744656D2874297B72657475726E206E65';
wwv_flow_imp.g_varchar2_table(93) := '77205328742E77696474682C742E6865696768742C2828652C69293D3E7B636F6E737420723D742E646174615B692A742E77696474682B655D3B72657475726E20733D722C2169734E614E2873292626733E3D2D313265332626733C3D3965333F723A4E';
wwv_flow_imp.g_varchar2_table(94) := '614E3B76617220737D29297D73746174696320636F6D62696E654E65696768626F72732874297B69662839213D3D742E6C656E677468297468726F77206E6577204572726F7228224D75737420696E636C75646520612074696C6520706C75732038206E';
wwv_flow_imp.g_varchar2_table(95) := '65696768626F727322293B636F6E737420653D745B345D3B69662821652972657475726E3B636F6E737420693D652E77696474682C723D652E6865696768743B72657475726E206E6577205328692C722C2828652C73293D3E7B6C6574206E3D303B733C';
wwv_flow_imp.g_varchar2_table(96) := '303F732B3D723A733C723F6E2B3D333A28732D3D722C6E2B3D36292C653C303F652B3D693A653C693F6E2B3D313A28652D3D692C6E2B3D32293B636F6E7374206F3D745B6E5D3B72657475726E206F3F6F2E67657428652C73293A4E614E7D29297D7D63';
wwv_flow_imp.g_varchar2_table(97) := '6F6E737420543D343239343936373239362C4E3D312F542C433D22756E646566696E6564223D3D747970656F6620546578744465636F6465723F6E756C6C3A6E657720546578744465636F64657228227574662D3822293B636C617373204F7B636F6E73';
wwv_flow_imp.g_varchar2_table(98) := '74727563746F7228743D6E65772055696E7438417272617928313629297B746869732E6275663D41727261794275666665722E6973566965772874293F743A6E65772055696E743841727261792874292C746869732E64617461566965773D6E65772044';
wwv_flow_imp.g_varchar2_table(99) := '6174615669657728746869732E6275662E627566666572292C746869732E706F733D302C746869732E747970653D302C746869732E6C656E6774683D746869732E6275662E6C656E6774687D726561644669656C647328742C652C693D746869732E6C65';
wwv_flow_imp.g_varchar2_table(100) := '6E677468297B666F72283B746869732E706F733C693B297B636F6E737420693D746869732E72656164566172696E7428292C723D693E3E332C733D746869732E706F733B746869732E747970653D3726692C7428722C652C74686973292C746869732E70';
wwv_flow_imp.g_varchar2_table(101) := '6F733D3D3D732626746869732E736B69702869297D72657475726E20657D726561644D65737361676528742C65297B72657475726E20746869732E726561644669656C647328742C652C746869732E72656164566172696E7428292B746869732E706F73';
wwv_flow_imp.g_varchar2_table(102) := '297D726561644669786564333228297B636F6E737420743D746869732E64617461566965772E67657455696E74333228746869732E706F732C2130293B72657475726E20746869732E706F732B3D342C747D72656164534669786564333228297B636F6E';
wwv_flow_imp.g_varchar2_table(103) := '737420743D746869732E64617461566965772E676574496E74333228746869732E706F732C2130293B72657475726E20746869732E706F732B3D342C747D726561644669786564363428297B636F6E737420743D746869732E64617461566965772E6765';
wwv_flow_imp.g_varchar2_table(104) := '7455696E74333228746869732E706F732C2130292B746869732E64617461566965772E67657455696E74333228746869732E706F732B342C2130292A543B72657475726E20746869732E706F732B3D382C747D72656164534669786564363428297B636F';
wwv_flow_imp.g_varchar2_table(105) := '6E737420743D746869732E64617461566965772E67657455696E74333228746869732E706F732C2130292B746869732E64617461566965772E676574496E74333228746869732E706F732B342C2130292A543B72657475726E20746869732E706F732B3D';
wwv_flow_imp.g_varchar2_table(106) := '382C747D72656164466C6F617428297B636F6E737420743D746869732E64617461566965772E676574466C6F6174333228746869732E706F732C2130293B72657475726E20746869732E706F732B3D342C747D72656164446F75626C6528297B636F6E73';
wwv_flow_imp.g_varchar2_table(107) := '7420743D746869732E64617461566965772E676574466C6F6174363428746869732E706F732C2130293B72657475726E20746869732E706F732B3D382C747D72656164566172696E742874297B636F6E737420653D746869732E6275663B6C657420692C';
wwv_flow_imp.g_varchar2_table(108) := '723B72657475726E20723D655B746869732E706F732B2B5D2C693D31323726722C723C3132383F693A28723D655B746869732E706F732B2B5D2C697C3D283132372672293C3C372C723C3132383F693A28723D655B746869732E706F732B2B5D2C697C3D';
wwv_flow_imp.g_varchar2_table(109) := '283132372672293C3C31342C723C3132383F693A28723D655B746869732E706F732B2B5D2C697C3D283132372672293C3C32312C723C3132383F693A28723D655B746869732E706F735D2C697C3D2831352672293C3C32382C66756E6374696F6E28742C';
wwv_flow_imp.g_varchar2_table(110) := '652C69297B636F6E737420723D692E6275663B6C657420732C6E3B6966286E3D725B692E706F732B2B5D2C733D28313132266E293E3E342C6E3C3132382972657475726E205528742C732C65293B6966286E3D725B692E706F732B2B5D2C737C3D283132';
wwv_flow_imp.g_varchar2_table(111) := '37266E293C3C332C6E3C3132382972657475726E205528742C732C65293B6966286E3D725B692E706F732B2B5D2C737C3D28313237266E293C3C31302C6E3C3132382972657475726E205528742C732C65293B6966286E3D725B692E706F732B2B5D2C73';
wwv_flow_imp.g_varchar2_table(112) := '7C3D28313237266E293C3C31372C6E3C3132382972657475726E205528742C732C65293B6966286E3D725B692E706F732B2B5D2C737C3D28313237266E293C3C32342C6E3C3132382972657475726E205528742C732C65293B6966286E3D725B692E706F';
wwv_flow_imp.g_varchar2_table(113) := '732B2B5D2C737C3D2831266E293C3C33312C6E3C3132382972657475726E205528742C732C65293B7468726F77206E6577204572726F722822457870656374656420766172696E74206E6F74206D6F7265207468616E20313020627974657322297D2869';
wwv_flow_imp.g_varchar2_table(114) := '2C742C7468697329292929297D72656164566172696E74363428297B72657475726E20746869732E72656164566172696E74282130297D7265616453566172696E7428297B636F6E737420743D746869732E72656164566172696E7428293B7265747572';
wwv_flow_imp.g_varchar2_table(115) := '6E207425323D3D313F28742B31292F2D323A742F327D72656164426F6F6C65616E28297B72657475726E20426F6F6C65616E28746869732E72656164566172696E742829297D72656164537472696E6728297B636F6E737420743D746869732E72656164';
wwv_flow_imp.g_varchar2_table(116) := '566172696E7428292B746869732E706F732C653D746869732E706F733B72657475726E20746869732E706F733D742C742D653E3D31322626433F432E6465636F646528746869732E6275662E737562617272617928652C7429293A66756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(117) := '742C652C69297B6C657420723D22222C733D653B666F72283B733C693B297B636F6E737420653D745B735D3B6C6574206E2C6F2C612C683D6E756C6C2C6C3D653E3233393F343A653E3232333F333A653E3139313F323A313B696628732B6C3E69296272';
wwv_flow_imp.g_varchar2_table(118) := '65616B3B313D3D3D6C3F653C313238262628683D65293A323D3D3D6C3F286E3D745B732B315D2C3132383D3D28313932266E29262628683D2833312665293C3C367C3633266E2C683C3D313237262628683D6E756C6C2929293A333D3D3D6C3F286E3D74';
wwv_flow_imp.g_varchar2_table(119) := '5B732B315D2C6F3D745B732B325D2C3132383D3D28313932266E2926263132383D3D28313932266F29262628683D2831352665293C3C31327C283633266E293C3C367C3633266F2C28683C3D323034377C7C683E3D35353239362626683C3D3537333433';
wwv_flow_imp.g_varchar2_table(120) := '29262628683D6E756C6C2929293A343D3D3D6C2626286E3D745B732B315D2C6F3D745B732B325D2C613D745B732B335D2C3132383D3D28313932266E2926263132383D3D28313932266F2926263132383D3D28313932266129262628683D283135266529';
wwv_flow_imp.g_varchar2_table(121) := '3C3C31387C283633266E293C3C31327C283633266F293C3C367C363326612C28683C3D36353533357C7C683E3D3131313431313229262628683D6E756C6C2929292C6E756C6C3D3D3D683F28683D36353533332C6C3D31293A683E363535333526262868';
wwv_flow_imp.g_varchar2_table(122) := '2D3D36353533362C722B3D537472696E672E66726F6D43686172436F646528683E3E3E313026313032337C3535323936292C683D35363332307C313032332668292C722B3D537472696E672E66726F6D43686172436F64652868292C732B3D6C7D726574';
wwv_flow_imp.g_varchar2_table(123) := '75726E20727D28746869732E6275662C652C74297D72656164427974657328297B636F6E737420743D746869732E72656164566172696E7428292B746869732E706F732C653D746869732E6275662E737562617272617928746869732E706F732C74293B';
wwv_flow_imp.g_varchar2_table(124) := '72657475726E20746869732E706F733D742C657D726561645061636B6564566172696E7428743D5B5D2C65297B636F6E737420693D746869732E726561645061636B6564456E6428293B666F72283B746869732E706F733C693B29742E70757368287468';
wwv_flow_imp.g_varchar2_table(125) := '69732E72656164566172696E74286529293B72657475726E20747D726561645061636B656453566172696E7428743D5B5D297B636F6E737420653D746869732E726561645061636B6564456E6428293B666F72283B746869732E706F733C653B29742E70';
wwv_flow_imp.g_varchar2_table(126) := '75736828746869732E7265616453566172696E742829293B72657475726E20747D726561645061636B6564426F6F6C65616E28743D5B5D297B636F6E737420653D746869732E726561645061636B6564456E6428293B666F72283B746869732E706F733C';
wwv_flow_imp.g_varchar2_table(127) := '653B29742E7075736828746869732E72656164426F6F6C65616E2829293B72657475726E20747D726561645061636B6564466C6F617428743D5B5D297B636F6E737420653D746869732E726561645061636B6564456E6428293B666F72283B746869732E';
wwv_flow_imp.g_varchar2_table(128) := '706F733C653B29742E7075736828746869732E72656164466C6F61742829293B72657475726E20747D726561645061636B6564446F75626C6528743D5B5D297B636F6E737420653D746869732E726561645061636B6564456E6428293B666F72283B7468';
wwv_flow_imp.g_varchar2_table(129) := '69732E706F733C653B29742E7075736828746869732E72656164446F75626C652829293B72657475726E20747D726561645061636B65644669786564333228743D5B5D297B636F6E737420653D746869732E726561645061636B6564456E6428293B666F';
wwv_flow_imp.g_varchar2_table(130) := '72283B746869732E706F733C653B29742E7075736828746869732E72656164466978656433322829293B72657475726E20747D726561645061636B6564534669786564333228743D5B5D297B636F6E737420653D746869732E726561645061636B656445';
wwv_flow_imp.g_varchar2_table(131) := '6E6428293B666F72283B746869732E706F733C653B29742E7075736828746869732E7265616453466978656433322829293B72657475726E20747D726561645061636B65644669786564363428743D5B5D297B636F6E737420653D746869732E72656164';
wwv_flow_imp.g_varchar2_table(132) := '5061636B6564456E6428293B666F72283B746869732E706F733C653B29742E7075736828746869732E72656164466978656436342829293B72657475726E20747D726561645061636B6564534669786564363428743D5B5D297B636F6E737420653D7468';
wwv_flow_imp.g_varchar2_table(133) := '69732E726561645061636B6564456E6428293B666F72283B746869732E706F733C653B29742E7075736828746869732E7265616453466978656436342829293B72657475726E20747D726561645061636B6564456E6428297B72657475726E20323D3D3D';
wwv_flow_imp.g_varchar2_table(134) := '746869732E747970653F746869732E72656164566172696E7428292B746869732E706F733A746869732E706F732B317D736B69702874297B636F6E737420653D3726743B696628303D3D3D6529666F72283B746869732E6275665B746869732E706F732B';
wwv_flow_imp.g_varchar2_table(135) := '2B5D3E3132373B293B656C736520696628323D3D3D6529746869732E706F733D746869732E72656164566172696E7428292B746869732E706F733B656C736520696628353D3D3D6529746869732E706F732B3D343B656C73657B69662831213D3D652974';
wwv_flow_imp.g_varchar2_table(136) := '68726F77206E6577204572726F722860556E696D706C656D656E74656420747970653A20247B657D60293B746869732E706F732B3D387D7D777269746554616728742C65297B746869732E7772697465566172696E7428743C3C337C65297D7265616C6C';
wwv_flow_imp.g_varchar2_table(137) := '6F632874297B6C657420653D746869732E6C656E6774687C7C31363B666F72283B653C746869732E706F732B743B29652A3D323B69662865213D3D746869732E6C656E677468297B636F6E737420743D6E65772055696E743841727261792865293B742E';
wwv_flow_imp.g_varchar2_table(138) := '73657428746869732E627566292C746869732E6275663D742C746869732E64617461566965773D6E657720446174615669657728742E627566666572292C746869732E6C656E6774683D657D7D66696E69736828297B72657475726E20746869732E6C65';
wwv_flow_imp.g_varchar2_table(139) := '6E6774683D746869732E706F732C746869732E706F733D302C746869732E6275662E737562617272617928302C746869732E6C656E677468297D7772697465466978656433322874297B746869732E7265616C6C6F632834292C746869732E6461746156';
wwv_flow_imp.g_varchar2_table(140) := '6965772E736574496E74333228746869732E706F732C742C2130292C746869732E706F732B3D347D777269746553466978656433322874297B746869732E7265616C6C6F632834292C746869732E64617461566965772E736574496E7433322874686973';
wwv_flow_imp.g_varchar2_table(141) := '2E706F732C742C2130292C746869732E706F732B3D347D7772697465466978656436342874297B746869732E7265616C6C6F632838292C746869732E64617461566965772E736574496E74333228746869732E706F732C2D3126742C2130292C74686973';
wwv_flow_imp.g_varchar2_table(142) := '2E64617461566965772E736574496E74333228746869732E706F732B342C4D6174682E666C6F6F7228742A4E292C2130292C746869732E706F732B3D387D777269746553466978656436342874297B746869732E7265616C6C6F632838292C746869732E';
wwv_flow_imp.g_varchar2_table(143) := '64617461566965772E736574496E74333228746869732E706F732C2D3126742C2130292C746869732E64617461566965772E736574496E74333228746869732E706F732B342C4D6174682E666C6F6F7228742A4E292C2130292C746869732E706F732B3D';
wwv_flow_imp.g_varchar2_table(144) := '387D7772697465566172696E742874297B28743D2B747C7C30293E3236383433353435357C7C743C303F66756E6374696F6E28742C65297B6C657420692C723B743E3D303F28693D7425343239343936373239367C302C723D742F343239343936373239';
wwv_flow_imp.g_varchar2_table(145) := '367C30293A28693D7E282D742534323934393637323936292C723D7E282D742F34323934393637323936292C343239343936373239355E693F693D692B317C303A28693D302C723D722B317C3029293B696628743E3D3078313030303030303030303030';
wwv_flow_imp.g_varchar2_table(146) := '30303030307C7C743C2D30783130303030303030303030303030303030297468726F77206E6577204572726F722822476976656E20766172696E7420646F65736E27742066697420696E746F20313020627974657322293B652E7265616C6C6F63283130';
wwv_flow_imp.g_varchar2_table(147) := '292C66756E6374696F6E28742C652C69297B692E6275665B692E706F732B2B5D3D31323726747C3132382C743E3E3E3D372C692E6275665B692E706F732B2B5D3D31323726747C3132382C743E3E3E3D372C692E6275665B692E706F732B2B5D3D313237';
wwv_flow_imp.g_varchar2_table(148) := '26747C3132382C743E3E3E3D372C692E6275665B692E706F732B2B5D3D31323726747C3132382C743E3E3E3D372C692E6275665B692E706F735D3D31323726747D28692C302C65292C66756E6374696F6E28742C65297B636F6E737420693D2837267429';
wwv_flow_imp.g_varchar2_table(149) := '3C3C343B696628652E6275665B652E706F732B2B5D7C3D697C2828743E3E3E3D33293F3132383A30292C21742972657475726E3B696628652E6275665B652E706F732B2B5D3D31323726747C2828743E3E3E3D37293F3132383A30292C21742972657475';
wwv_flow_imp.g_varchar2_table(150) := '726E3B696628652E6275665B652E706F732B2B5D3D31323726747C2828743E3E3E3D37293F3132383A30292C21742972657475726E3B696628652E6275665B652E706F732B2B5D3D31323726747C2828743E3E3E3D37293F3132383A30292C2174297265';
wwv_flow_imp.g_varchar2_table(151) := '7475726E3B696628652E6275665B652E706F732B2B5D3D31323726747C2828743E3E3E3D37293F3132383A30292C21742972657475726E3B652E6275665B652E706F732B2B5D3D31323726747D28722C65297D28742C74686973293A28746869732E7265';
wwv_flow_imp.g_varchar2_table(152) := '616C6C6F632834292C746869732E6275665B746869732E706F732B2B5D3D31323726747C28743E3132373F3132383A30292C743C3D3132377C7C28746869732E6275665B746869732E706F732B2B5D3D3132372628743E3E3E3D37297C28743E3132373F';
wwv_flow_imp.g_varchar2_table(153) := '3132383A30292C743C3D3132377C7C28746869732E6275665B746869732E706F732B2B5D3D3132372628743E3E3E3D37297C28743E3132373F3132383A30292C743C3D3132377C7C28746869732E6275665B746869732E706F732B2B5D3D743E3E3E3726';
wwv_flow_imp.g_varchar2_table(154) := '313237292929297D777269746553566172696E742874297B746869732E7772697465566172696E7428743C303F322A2D742D313A322A74297D7772697465426F6F6C65616E2874297B746869732E7772697465566172696E74282B74297D777269746553';
wwv_flow_imp.g_varchar2_table(155) := '7472696E672874297B743D537472696E672874292C746869732E7265616C6C6F6328342A742E6C656E677468292C746869732E706F732B2B3B636F6E737420653D746869732E706F733B746869732E706F733D66756E6374696F6E28742C652C69297B66';
wwv_flow_imp.g_varchar2_table(156) := '6F72286C657420722C732C6E3D303B6E3C652E6C656E6774683B6E2B2B297B696628723D652E63686172436F64654174286E292C723E35353239352626723C3537333434297B6966282173297B723E35363331397C7C6E2B313D3D3D652E6C656E677468';
wwv_flow_imp.g_varchar2_table(157) := '3F28745B692B2B5D3D3233392C745B692B2B5D3D3139312C745B692B2B5D3D313839293A733D723B636F6E74696E75657D696628723C3536333230297B745B692B2B5D3D3233392C745B692B2B5D3D3139312C745B692B2B5D3D3138392C733D723B636F';
wwv_flow_imp.g_varchar2_table(158) := '6E74696E75657D723D732D35353239363C3C31307C722D35363332307C36353533362C733D6E756C6C7D656C73652073262628745B692B2B5D3D3233392C745B692B2B5D3D3139312C745B692B2B5D3D3138392C733D6E756C6C293B723C3132383F745B';
wwv_flow_imp.g_varchar2_table(159) := '692B2B5D3D723A28723C323034383F745B692B2B5D3D723E3E367C3139323A28723C36353533363F745B692B2B5D3D723E3E31327C3232343A28745B692B2B5D3D723E3E31387C3234302C745B692B2B5D3D723E3E31322636337C313238292C745B692B';
wwv_flow_imp.g_varchar2_table(160) := '2B5D3D723E3E362636337C313238292C745B692B2B5D3D363326727C313238297D72657475726E20697D28746869732E6275662C742C746869732E706F73293B636F6E737420693D746869732E706F732D653B693E3D31323826264928652C692C746869';
wwv_flow_imp.g_varchar2_table(161) := '73292C746869732E706F733D652D312C746869732E7772697465566172696E742869292C746869732E706F732B3D697D7772697465466C6F61742874297B746869732E7265616C6C6F632834292C746869732E64617461566965772E736574466C6F6174';
wwv_flow_imp.g_varchar2_table(162) := '333228746869732E706F732C742C2130292C746869732E706F732B3D347D7772697465446F75626C652874297B746869732E7265616C6C6F632838292C746869732E64617461566965772E736574466C6F6174363428746869732E706F732C742C213029';
wwv_flow_imp.g_varchar2_table(163) := '2C746869732E706F732B3D387D777269746542797465732874297B636F6E737420653D742E6C656E6774683B746869732E7772697465566172696E742865292C746869732E7265616C6C6F632865293B666F72286C657420693D303B693C653B692B2B29';
wwv_flow_imp.g_varchar2_table(164) := '746869732E6275665B746869732E706F732B2B5D3D745B695D7D77726974655261774D65737361676528742C65297B746869732E706F732B2B3B636F6E737420693D746869732E706F733B7428652C74686973293B636F6E737420723D746869732E706F';
wwv_flow_imp.g_varchar2_table(165) := '732D693B723E3D31323826264928692C722C74686973292C746869732E706F733D692D312C746869732E7772697465566172696E742872292C746869732E706F732B3D727D77726974654D65737361676528742C652C69297B746869732E777269746554';
wwv_flow_imp.g_varchar2_table(166) := '616728742C32292C746869732E77726974655261774D65737361676528652C69297D77726974655061636B6564566172696E7428742C65297B652E6C656E6774682626746869732E77726974654D65737361676528742C452C65297D7772697465506163';
wwv_flow_imp.g_varchar2_table(167) := '6B656453566172696E7428742C65297B652E6C656E6774682626746869732E77726974654D65737361676528742C422C65297D77726974655061636B6564426F6F6C65616E28742C65297B652E6C656E6774682626746869732E77726974654D65737361';
wwv_flow_imp.g_varchar2_table(168) := '676528742C6A2C65297D77726974655061636B6564466C6F617428742C65297B652E6C656E6774682626746869732E77726974654D65737361676528742C412C65297D77726974655061636B6564446F75626C6528742C65297B652E6C656E6774682626';
wwv_flow_imp.g_varchar2_table(169) := '746869732E77726974654D65737361676528742C442C65297D77726974655061636B65644669786564333228742C65297B652E6C656E6774682626746869732E77726974654D65737361676528742C7A2C65297D77726974655061636B65645346697865';
wwv_flow_imp.g_varchar2_table(170) := '64333228742C65297B652E6C656E6774682626746869732E77726974654D65737361676528742C522C65297D77726974655061636B65644669786564363428742C65297B652E6C656E6774682626746869732E77726974654D65737361676528742C242C';
wwv_flow_imp.g_varchar2_table(171) := '65297D77726974655061636B6564534669786564363428742C65297B652E6C656E6774682626746869732E77726974654D65737361676528742C4C2C65297D777269746542797465734669656C6428742C65297B746869732E777269746554616728742C';
wwv_flow_imp.g_varchar2_table(172) := '32292C746869732E777269746542797465732865297D7772697465466978656433324669656C6428742C65297B746869732E777269746554616728742C35292C746869732E7772697465466978656433322865297D777269746553466978656433324669';
wwv_flow_imp.g_varchar2_table(173) := '656C6428742C65297B746869732E777269746554616728742C35292C746869732E777269746553466978656433322865297D7772697465466978656436344669656C6428742C65297B746869732E777269746554616728742C31292C746869732E777269';
wwv_flow_imp.g_varchar2_table(174) := '7465466978656436342865297D777269746553466978656436344669656C6428742C65297B746869732E777269746554616728742C31292C746869732E777269746553466978656436342865297D7772697465566172696E744669656C6428742C65297B';
wwv_flow_imp.g_varchar2_table(175) := '746869732E777269746554616728742C30292C746869732E7772697465566172696E742865297D777269746553566172696E744669656C6428742C65297B746869732E777269746554616728742C30292C746869732E777269746553566172696E742865';
wwv_flow_imp.g_varchar2_table(176) := '297D7772697465537472696E674669656C6428742C65297B746869732E777269746554616728742C32292C746869732E7772697465537472696E672865297D7772697465466C6F61744669656C6428742C65297B746869732E777269746554616728742C';
wwv_flow_imp.g_varchar2_table(177) := '35292C746869732E7772697465466C6F61742865297D7772697465446F75626C654669656C6428742C65297B746869732E777269746554616728742C31292C746869732E7772697465446F75626C652865297D7772697465426F6F6C65616E4669656C64';
wwv_flow_imp.g_varchar2_table(178) := '28742C65297B746869732E7772697465566172696E744669656C6428742C2B65297D7D66756E6374696F6E205528742C652C69297B72657475726E20693F343239343936373239362A652B28743E3E3E30293A343239343936373239362A28653E3E3E30';
wwv_flow_imp.g_varchar2_table(179) := '292B28743E3E3E30297D66756E6374696F6E204928742C652C69297B636F6E737420723D653C3D31363338333F313A653C3D323039373135313F323A653C3D3236383433353435353F333A4D6174682E666C6F6F72284D6174682E6C6F672865292F2837';
wwv_flow_imp.g_varchar2_table(180) := '2A4D6174682E4C4E3229293B692E7265616C6C6F632872293B666F72286C657420653D692E706F732D313B653E3D743B652D2D29692E6275665B652B725D3D692E6275665B655D7D66756E6374696F6E204528742C65297B666F72286C657420693D303B';
wwv_flow_imp.g_varchar2_table(181) := '693C742E6C656E6774683B692B2B29652E7772697465566172696E7428745B695D297D66756E6374696F6E204228742C65297B666F72286C657420693D303B693C742E6C656E6774683B692B2B29652E777269746553566172696E7428745B695D297D66';
wwv_flow_imp.g_varchar2_table(182) := '756E6374696F6E204128742C65297B666F72286C657420693D303B693C742E6C656E6774683B692B2B29652E7772697465466C6F617428745B695D297D66756E6374696F6E204428742C65297B666F72286C657420693D303B693C742E6C656E6774683B';
wwv_flow_imp.g_varchar2_table(183) := '692B2B29652E7772697465446F75626C6528745B695D297D66756E6374696F6E206A28742C65297B666F72286C657420693D303B693C742E6C656E6774683B692B2B29652E7772697465426F6F6C65616E28745B695D297D66756E6374696F6E207A2874';
wwv_flow_imp.g_varchar2_table(184) := '2C65297B666F72286C657420693D303B693C742E6C656E6774683B692B2B29652E77726974654669786564333228745B695D297D66756E6374696F6E205228742C65297B666F72286C657420693D303B693C742E6C656E6774683B692B2B29652E777269';
wwv_flow_imp.g_varchar2_table(185) := '7465534669786564333228745B695D297D66756E6374696F6E202428742C65297B666F72286C657420693D303B693C742E6C656E6774683B692B2B29652E77726974654669786564363428745B695D297D66756E6374696F6E204C28742C65297B666F72';
wwv_flow_imp.g_varchar2_table(186) := '286C657420693D303B693C742E6C656E6774683B692B2B29652E7772697465534669786564363428745B695D297D76617220473B66756E6374696F6E205728742C65297B6966282165297468726F77206E6577204572726F72282270626620756E646566';
wwv_flow_imp.g_varchar2_table(187) := '696E656422293B652E7772697465566172696E744669656C642831352C32292C652E7772697465537472696E674669656C6428312C742E69647C7C2222292C652E7772697465566172696E744669656C6428352C742E657874656E747C7C34303936293B';
wwv_flow_imp.g_varchar2_table(188) := '636F6E737420693D7B6B6579733A5B5D2C76616C7565733A5B5D2C6B657963616368653A7B7D2C76616C756563616368653A7B7D7D3B666F7228636F6E73742072206F6620742E666561747572657329692E666561747572653D722C652E77726974654D';
wwv_flow_imp.g_varchar2_table(189) := '65737361676528322C712C69293B666F7228636F6E73742074206F6620692E6B65797329652E7772697465537472696E674669656C6428332C74293B666F7228636F6E73742074206F6620692E76616C75657329652E77726974654D6573736167652834';
wwv_flow_imp.g_varchar2_table(190) := '2C4A2C74297D66756E6374696F6E207128742C65297B636F6E737420693D742E666561747572653B69662821697C7C2165297468726F77206E6577204572726F723B652E77726974654D65737361676528322C4B2C74292C652E7772697465566172696E';
wwv_flow_imp.g_varchar2_table(191) := '744669656C6428332C692E74797065292C652E77726974654D65737361676528342C482C69297D66756E6374696F6E204B28742C65297B636F6E737420693D742E666561747572653B69662821697C7C2165297468726F77206E6577204572726F723B63';
wwv_flow_imp.g_varchar2_table(192) := '6F6E737420723D742E6B6579732C733D742E76616C7565732C6E3D742E6B657963616368652C6F3D742E76616C756563616368653B666F7228636F6E7374207420696E20692E70726F70657274696573297B6C657420613D692E70726F70657274696573';
wwv_flow_imp.g_varchar2_table(193) := '5B745D2C683D6E5B745D3B6966286E756C6C3D3D3D6129636F6E74696E75653B766F696420303D3D3D68262628722E707573682874292C683D722E6C656E6774682D312C6E5B745D3D68292C652E7772697465566172696E742868293B636F6E7374206C';
wwv_flow_imp.g_varchar2_table(194) := '3D747970656F6620613B22737472696E6722213D3D6C262622626F6F6C65616E22213D3D6C2626226E756D62657222213D3D6C262628613D4A534F4E2E737472696E67696679286129293B636F6E737420633D60247B6C7D3A247B617D603B6C65742064';
wwv_flow_imp.g_varchar2_table(195) := '3D6F5B635D3B766F696420303D3D3D64262628732E707573682861292C643D732E6C656E6774682D312C6F5B635D3D64292C652E7772697465566172696E742864297D7D66756E6374696F6E205928742C65297B72657475726E28653C3C33292B283726';
wwv_flow_imp.g_varchar2_table(196) := '74297D66756E6374696F6E205F2874297B72657475726E20743C3C315E743E3E33317D66756E6374696F6E204828742C65297B6966282165297468726F77206E6577204572726F723B636F6E737420693D742E67656F6D657472792C723D742E74797065';
wwv_flow_imp.g_varchar2_table(197) := '3B6C657420733D302C6E3D303B666F7228636F6E73742074206F662069297B6C657420693D313B723D3D3D472E504F494E54262628693D742E6C656E6774682F32292C652E7772697465566172696E74285928312C6929293B636F6E7374206F3D742E6C';
wwv_flow_imp.g_varchar2_table(198) := '656E6774682F322C613D723D3D3D472E504F4C59474F4E3F6F2D313A6F3B666F72286C657420693D303B693C613B692B2B297B313D3D3D69262631213D3D722626652E7772697465566172696E74285928322C612D3129293B636F6E7374206F3D745B32';
wwv_flow_imp.g_varchar2_table(199) := '2A695D2D732C683D745B322A692B315D2D6E3B652E7772697465566172696E74285F286F29292C652E7772697465566172696E74285F286829292C732B3D6F2C6E2B3D687D723D3D3D472E504F4C59474F4E2626652E7772697465566172696E74285928';
wwv_flow_imp.g_varchar2_table(200) := '372C3129297D7D66756E6374696F6E204A28742C65297B6966282165297468726F77206E6577204572726F723B22737472696E67223D3D747970656F6620743F652E7772697465537472696E674669656C6428312C74293A22626F6F6C65616E223D3D74';
wwv_flow_imp.g_varchar2_table(201) := '7970656F6620743F652E7772697465426F6F6C65616E4669656C6428372C74293A226E756D626572223D3D747970656F662074262628742531213D303F652E7772697465446F75626C654669656C6428332C74293A743C303F652E777269746553566172';
wwv_flow_imp.g_varchar2_table(202) := '696E744669656C6428362C74293A652E7772697465566172696E744669656C6428352C7429297D2166756E6374696F6E2874297B745B742E554E4B4E4F574E3D305D3D22554E4B4E4F574E222C745B742E504F494E543D315D3D22504F494E54222C745B';
wwv_flow_imp.g_varchar2_table(203) := '742E4C494E45535452494E473D325D3D224C494E45535452494E47222C745B742E504F4C59474F4E3D335D3D22504F4C59474F4E227D28477C7C28473D7B7D29293B636F6E737420513D22756E646566696E656422213D747970656F6620706572666F72';
wwv_flow_imp.g_varchar2_table(204) := '6D616E63653F706572666F726D616E63653A766F696420302C583D513F512E74696D654F726967696E7C7C286E65772044617465292E67657454696D6528292D512E6E6F7728293A286E65772044617465292E67657454696D6528293B66756E6374696F';
wwv_flow_imp.g_varchar2_table(205) := '6E205A2874297B76617220653B72657475726E204A534F4E2E7061727365284A534F4E2E737472696E6769667928286E756C6C3D3D3D28653D6E756C6C3D3D513F766F696420303A512E676574456E747269657342794E616D65297C7C766F696420303D';
wwv_flow_imp.g_varchar2_table(206) := '3D3D653F766F696420303A652E63616C6C28512C7429297C7C5B5D29297D66756E6374696F6E20747428297B72657475726E20513F512E6E6F7728293A286E65772044617465292E67657454696D6528297D66756E6374696F6E2065742874297B636F6E';
wwv_flow_imp.g_varchar2_table(207) := '737420653D5B5D3B666F7228636F6E73742069206F66207429652E70757368282E2E2E69293B72657475726E20657D636C6173732069747B636F6E7374727563746F722874297B746869732E6D61726B733D7B7D2C746869732E75726C733D5B5D2C7468';
wwv_flow_imp.g_varchar2_table(208) := '69732E666574636865643D5B5D2C746869732E7265736F75726365733D5B5D2C746869732E74696C6573466574636865643D302C746869732E74696D654F726967696E3D582C746869732E66696E6973683D743D3E7B746869732E6D61726B46696E6973';
wwv_flow_imp.g_varchar2_table(209) := '6828293B636F6E737420653D743D3E7B636F6E737420653D746869732E6D61726B735B745D7C7C5B5D2C693D4D6174682E6D6178282E2E2E652E6D61702828743D3E4D6174682E6D6178282E2E2E74292929292C723D4D6174682E6D696E282E2E2E652E';
wwv_flow_imp.g_varchar2_table(210) := '6D61702828743D3E4D6174682E6D696E282E2E2E74292929293B72657475726E204E756D6265722E697346696E6974652869293F692D723A766F696420307D2C693D6528226D61696E22297C7C302C723D652822666574636822292C733D652822646563';
wwv_flow_imp.g_varchar2_table(211) := '6F646522292C6E3D65282269736F6C696E6522293B72657475726E7B75726C3A742C74696C6573557365643A746869732E74696C6573466574636865642C6F726967696E3A746869732E74696D654F726967696E2C6D61726B733A746869732E6D61726B';
wwv_flow_imp.g_varchar2_table(212) := '732C7265736F75726365733A5B2E2E2E746869732E7265736F75726365732C2E2E2E657428746869732E666574636865642E6D6170285A29295D2C6475726174696F6E3A692C66657463683A722C6465636F64653A732C70726F636573733A6E2C776169';
wwv_flow_imp.g_varchar2_table(213) := '743A692D28727C7C30292D28737C7C30292D286E7C7C30297D7D2C746869732E6572726F723D743D3E4F626A6563742E61737369676E284F626A6563742E61737369676E287B7D2C746869732E66696E697368287429292C7B6572726F723A21307D292C';
wwv_flow_imp.g_varchar2_table(214) := '746869732E6D61726B65723D743D3E7B76617220653B746869732E6D61726B735B745D7C7C28746869732E6D61726B735B745D3D5B5D293B636F6E737420693D5B747428295D3B72657475726E206E756C6C3D3D3D28653D746869732E6D61726B735B74';
wwv_flow_imp.g_varchar2_table(215) := '5D297C7C766F696420303D3D3D657C7C652E707573682869292C28293D3E692E707573682874742829297D2C746869732E75736554696C653D743D3E7B746869732E75726C732E696E6465784F662874293C30262628746869732E75726C732E70757368';
wwv_flow_imp.g_varchar2_table(216) := '2874292C746869732E74696C6573466574636865642B2B297D2C746869732E666574636854696C653D743D3E7B746869732E666574636865642E696E6465784F662874293C302626746869732E666574636865642E707573682874297D2C746869732E61';
wwv_flow_imp.g_varchar2_table(217) := '6464416C6C3D743D3E7B76617220653B746869732E74696C6573466574636865642B3D742E74696C6573557365643B636F6E737420693D742E6F726967696E2D746869732E74696D654F726967696E3B666F7228636F6E7374207220696E20742E6D6172';
wwv_flow_imp.g_varchar2_table(218) := '6B73297B636F6E737420733D723B28746869732E6D61726B735B735D7C7C28746869732E6D61726B735B735D3D5B5D29292E70757368282E2E2E286E756C6C3D3D3D28653D742E6D61726B735B735D297C7C766F696420303D3D3D653F766F696420303A';
wwv_flow_imp.g_varchar2_table(219) := '652E6D61702828743D3E742E6D61702828743D3E742B6929292929297C7C5B5D297D746869732E7265736F75726365732E70757368282E2E2E742E7265736F75726365732E6D61702828743D3E66756E6374696F6E28742C65297B636F6E737420693D7B';
wwv_flow_imp.g_varchar2_table(220) := '7D3B666F7228636F6E7374207220696E20742930213D3D745B725D262672742E746573742872293F695B725D3D4E756D62657228745B725D292B653A695B725D3D745B725D3B72657475726E20697D28742C69292929297D2C746869732E6D61726B4669';
wwv_flow_imp.g_varchar2_table(221) := '6E6973683D746869732E6D61726B65722874297D7D636F6E73742072743D2F285374617274247C456E64247C5E73746172747C5E656E64292F3B636F6E73742073743D28742C65293D3E6128766F696420302C766F696420302C766F696420302C286675';
wwv_flow_imp.g_varchar2_table(222) := '6E6374696F6E2A28297B636F6E737420693D7B7369676E616C3A652E7369676E616C7D2C723D7969656C6420666574636828742C69293B69662821722E6F6B297468726F77206E6577204572726F72286042616420726573706F6E73653A20247B722E73';
wwv_flow_imp.g_varchar2_table(223) := '74617475737D20666F7220247B747D60293B72657475726E7B646174613A7969656C6420722E626C6F6228292C657870697265733A722E686561646572732E67657428226578706972657322297C7C766F696420302C6361636865436F6E74726F6C3A72';
wwv_flow_imp.g_varchar2_table(224) := '2E686561646572732E676574282263616368652D636F6E74726F6C22297C7C766F696420307D7D29293B6C6574206E743D303B742E413D636C6173737B636F6E7374727563746F7228742C652C693D326534297B746869732E63616C6C6261636B733D7B';
wwv_flow_imp.g_varchar2_table(225) := '7D2C746869732E63616E63656C733D7B7D2C746869732E646573743D742C746869732E74696D656F75744D733D692C746869732E646573742E6F6E6D6573736167653D743D3E6128746869732C5B745D2C766F696420302C2866756E6374696F6E2A287B';
wwv_flow_imp.g_varchar2_table(226) := '646174613A747D297B636F6E737420693D743B6966282263616E63656C223D3D3D692E74797065297B636F6E737420743D746869732E63616E63656C735B692E69645D3B64656C65746520746869732E63616E63656C735B692E69645D2C6E756C6C3D3D';
wwv_flow_imp.g_varchar2_table(227) := '747C7C742E61626F727428297D656C73652069662822726573706F6E7365223D3D3D692E74797065297B636F6E737420743D746869732E63616C6C6261636B735B692E69645D3B64656C65746520746869732E63616C6C6261636B735B692E69645D2C74';
wwv_flow_imp.g_varchar2_table(228) := '26267428692E6572726F723F6E6577204572726F7228692E6572726F72293A766F696420302C692E726573706F6E73652C692E74696D696E6773297D656C7365206966282272657175657374223D3D3D692E74797065297B636F6E737420743D6E657720';
wwv_flow_imp.g_varchar2_table(229) := '69742822776F726B657222292C723D655B692E6E616D655D2C733D6E65772041626F7274436F6E74726F6C6C65722C6E3D722E6170706C7928722C5B2E2E2E692E617267732C732C745D292C6F3D60247B692E6E616D657D5F247B692E69647D603B6966';
wwv_flow_imp.g_varchar2_table(230) := '28692E696426266E297B746869732E63616E63656C735B692E69645D3D733B7472797B636F6E737420653D7969656C64206E2C723D6E756C6C3D3D653F766F696420303A652E7472616E736665727261626C65733B746869732E706F73744D6573736167';
wwv_flow_imp.g_varchar2_table(231) := '65287B69643A692E69642C747970653A22726573706F6E7365222C726573706F6E73653A652C74696D696E67733A742E66696E697368286F297D2C72297D63617463682865297B746869732E706F73744D657373616765287B69643A692E69642C747970';
wwv_flow_imp.g_varchar2_table(232) := '653A22726573706F6E7365222C6572726F723A286E756C6C3D3D653F766F696420303A652E746F537472696E672829297C7C226572726F72222C74696D696E67733A742E66696E697368286F297D297D64656C65746520746869732E63616E63656C735B';
wwv_flow_imp.g_varchar2_table(233) := '692E69645D7D7D7D29297D706F73744D65737361676528742C65297B746869732E646573742E706F73744D65737361676528742C657C7C5B5D297D73656E6428742C652C692C722C2E2E2E73297B636F6E7374206E3D2B2B6E742C6F3D6E65772050726F';
wwv_flow_imp.g_varchar2_table(234) := '6D697365282828692C6F293D3E7B746869732E706F73744D657373616765287B69643A6E2C747970653A2272657175657374222C6E616D653A742C617267733A737D2C65292C746869732E63616C6C6261636B735B6E5D3D28742C652C73293D3E7B6E75';
wwv_flow_imp.g_varchar2_table(235) := '6C6C3D3D727C7C722E616464416C6C2873292C743F6F2874293A692865297D7D29293B72657475726E207728692C2828293D3E7B64656C65746520746869732E63616C6C6261636B735B6E5D2C746869732E706F73744D657373616765287B69643A6E2C';
wwv_flow_imp.g_varchar2_table(236) := '747970653A2263616E63656C227D297D29292C7028746869732E74696D656F75744D732C6F2C69297D7D2C742E483D532C742E4C3D636C6173737B636F6E7374727563746F722874297B746869732E6C6F616465643D50726F6D6973652E7265736F6C76';
wwv_flow_imp.g_varchar2_table(237) := '6528292C746869732E6665746368416E64506172736554696C653D28742C652C692C722C73293D3E7B636F6E7374206E3D746869732C6F3D746869732E64656D55726C5061747465726E2E7265706C61636528227B7A7D222C742E746F537472696E6728';
wwv_flow_imp.g_varchar2_table(238) := '29292E7265706C61636528227B787D222C652E746F537472696E672829292E7265706C61636528227B797D222C692E746F537472696E672829293B72657475726E206E756C6C3D3D737C7C732E75736554696C65286F292C746869732E70617273656443';
wwv_flow_imp.g_varchar2_table(239) := '616368652E676574286F2C2828722C6F293D3E6128746869732C766F696420302C766F696420302C2866756E6374696F6E2A28297B636F6E737420723D7969656C64206E2E666574636854696C6528742C652C692C6F2C73293B69662867286F29297468';
wwv_flow_imp.g_varchar2_table(240) := '726F77206E6577204572726F72282263616E63656C656422293B636F6E737420613D6E2E6465636F6465496D61676528722E646174612C6E2E656E636F64696E672C6F292C683D6E756C6C3D3D733F766F696420303A732E6D61726B657228226465636F';
wwv_flow_imp.g_varchar2_table(241) := '646522292C6C3D7969656C6420613B72657475726E206E756C6C3D3D687C7C6828292C6C7D2929292C72297D2C746869732E74696C6543616368653D6E6577207828742E636163686553697A65292C746869732E70617273656443616368653D6E657720';
wwv_flow_imp.g_varchar2_table(242) := '7828742E636163686553697A65292C746869732E636F6E746F757243616368653D6E6577207828742E636163686553697A65292C746869732E74696D656F75744D733D742E74696D656F75744D732C746869732E64656D55726C5061747465726E3D742E';
wwv_flow_imp.g_varchar2_table(243) := '64656D55726C5061747465726E2C746869732E656E636F64696E673D742E656E636F64696E672C746869732E6D61787A6F6F6D3D742E6D61787A6F6F6D2C746869732E6465636F6465496D6167653D742E6465636F6465496D6167657C7C6B2C74686973';
wwv_flow_imp.g_varchar2_table(244) := '2E67657454696C653D742E67657454696C657C7C73747D666574636854696C6528742C652C692C722C73297B636F6E7374206E3D746869732E64656D55726C5061747465726E2E7265706C61636528227B7A7D222C742E746F537472696E672829292E72';
wwv_flow_imp.g_varchar2_table(245) := '65706C61636528227B787D222C652E746F537472696E672829292E7265706C61636528227B797D222C692E746F537472696E672829293B72657475726E206E756C6C3D3D737C7C732E75736554696C65286E292C746869732E74696C6543616368652E67';
wwv_flow_imp.g_varchar2_table(246) := '6574286E2C2828742C65293D3E7B6E756C6C3D3D737C7C732E666574636854696C65286E293B636F6E737420693D6E756C6C3D3D733F766F696420303A732E6D61726B65722822666574636822293B72657475726E207028746869732E74696D656F7574';
wwv_flow_imp.g_varchar2_table(247) := '4D732C746869732E67657454696C65286E2C65292E66696E616C6C79282828293D3E6E756C6C3D3D693F766F696420303A69282929292C65297D292C72297D666574636844656D28742C652C692C722C732C6E297B72657475726E206128746869732C76';
wwv_flow_imp.g_varchar2_table(248) := '6F696420302C766F696420302C2866756E6374696F6E2A28297B636F6E7374206F3D4D6174682E6D696E28742D28722E6F7665727A6F6F6D7C7C30292C746869732E6D61787A6F6F6D292C613D742D6F2C683D313C3C612C6C3D4D6174682E666C6F6F72';
wwv_flow_imp.g_varchar2_table(249) := '28652F68292C633D4D6174682E666C6F6F7228692F68292C643D7969656C6420746869732E6665746368416E64506172736554696C65286F2C6C2C632C732C6E293B72657475726E20532E66726F6D52617744656D2864292E73706C697428612C652568';
wwv_flow_imp.g_varchar2_table(250) := '2C692568297D29297D6665746368436F6E746F757254696C6528742C652C692C722C732C6F297B636F6E73747B6C6576656C733A682C6D756C7469706C6965723A6C3D312C6275666665723A643D312C657874656E743A753D343039362C636F6E746F75';
wwv_flow_imp.g_varchar2_table(251) := '724C617965723A663D22636F6E746F757273222C656C65766174696F6E4B65793A703D22656C65222C6C6576656C4B65793A773D226C6576656C222C73756273616D706C6542656C6F773A6D3D3130307D3D723B69662821687C7C303D3D3D682E6C656E';
wwv_flow_imp.g_varchar2_table(252) := '6774682972657475726E2050726F6D6973652E7265736F6C7665287B61727261794275666665723A6E65772041727261794275666665722830297D293B636F6E737420623D5B742C652C692C632872295D2E6A6F696E28222F22293B72657475726E2074';
wwv_flow_imp.g_varchar2_table(253) := '6869732E636F6E746F757243616368652E67657428622C2828732C63293D3E6128746869732C766F696420302C766F696420302C2866756E6374696F6E2A28297B636F6E737420733D313C3C742C613D5B5D3B666F72286C6574206E3D692D313B6E3C3D';
wwv_flow_imp.g_varchar2_table(254) := '692B313B6E2B2B29666F72286C657420693D652D313B693C3D652B313B692B2B29612E70757368286E3C307C7C6E3E3D733F766F696420303A746869732E666574636844656D28742C28692B732925732C6E2C722C632C6F29293B636F6E737420623D79';
wwv_flow_imp.g_varchar2_table(255) := '69656C642050726F6D6973652E616C6C2861293B6C657420793D532E636F6D62696E654E65696768626F72732862293B69662821797C7C672863292972657475726E7B61727261794275666665723A286E65772055696E74384172726179292E62756666';
wwv_flow_imp.g_varchar2_table(256) := '65727D3B636F6E737420763D6E756C6C3D3D6F3F766F696420303A6F2E6D61726B6572282269736F6C696E6522293B696628792E77696474683E3D6D29793D792E6D6174657269616C697A652832293B656C736520666F72283B792E77696474683C6D3B';
wwv_flow_imp.g_varchar2_table(257) := '29793D792E73756273616D706C65506978656C43656E746572732832292E6D6174657269616C697A652832293B793D792E61766572616765506978656C43656E74657273546F4772696428292E7363616C65456C65766174696F6E286C292E6D61746572';
wwv_flow_imp.g_varchar2_table(258) := '69616C697A652831293B636F6E737420503D6E28685B305D2C792C752C64293B6E756C6C3D3D767C7C7628293B636F6E737420783D66756E6374696F6E2874297B636F6E737420653D6E6577204F3B666F7228636F6E7374206920696E20742E6C617965';
wwv_flow_imp.g_varchar2_table(259) := '7273297B636F6E737420723D742E6C61796572735B695D3B722E657874656E747C7C28722E657874656E743D742E657874656E74292C652E77726974654D65737361676528332C572C4F626A6563742E61737369676E284F626A6563742E61737369676E';
wwv_flow_imp.g_varchar2_table(260) := '287B7D2C72292C7B69643A697D29297D72657475726E20652E66696E69736828297D287B657874656E743A752C6C61796572733A7B5B665D3A7B66656174757265733A4F626A6563742E656E74726965732850292E6D61702828285B742C655D293D3E7B';
wwv_flow_imp.g_varchar2_table(261) := '636F6E737420693D4E756D6265722874293B72657475726E7B747970653A472E4C494E45535452494E472C67656F6D657472793A652C70726F706572746965733A7B5B705D3A692C5B775D3A4D6174682E6D6178282E2E2E682E6D6170282828742C6529';
wwv_flow_imp.g_varchar2_table(262) := '3D3E6925743D3D303F653A302929297D7D7D29297D7D7D293B72657475726E206E756C6C3D3D767C7C7628292C7B61727261794275666665723A782E6275666665727D7D2929292C73297D7D2C742E543D69742C742E5F3D612C742E613D66756E637469';
wwv_flow_imp.g_varchar2_table(263) := '6F6E2874297B72657475726E204F626A6563742E66726F6D456E747269657328742E7265706C616365282F5E2E2A5C3F2F2C2222292E73706C697428222622292E6D61702828743D3E7B636F6E737420653D742E73706C697428223D22292E6D61702864';
wwv_flow_imp.g_varchar2_table(264) := '65636F6465555249436F6D706F6E656E74292C693D655B305D3B6C657420723D655B315D3B7377697463682869297B63617365227468726573686F6C6473223A733D722C723D4F626A6563742E66726F6D456E747269657328732E73706C697428227E22';
wwv_flow_imp.g_varchar2_table(265) := '292E6D61702828743D3E742E73706C697428222A22292E6D6170284E756D6265722929292E6D61702828285B742C2E2E2E655D293D3E5B742C655D2929293B627265616B3B6361736522657874656E74223A63617365226D756C7469706C696572223A63';
wwv_flow_imp.g_varchar2_table(266) := '617365226F7665727A6F6F6D223A6361736522627566666572223A723D4E756D6265722872297D76617220733B72657475726E5B692C725D7D2929297D2C742E623D6E2C742E633D4D2C742E643D6B2C742E653D66756E6374696F6E2874297B7661727B';
wwv_flow_imp.g_varchar2_table(267) := '7468726573686F6C64733A657D3D742C693D6F28742C5B227468726573686F6C6473225D293B72657475726E2068284F626A6563742E61737369676E287B7468726573686F6C64733A6C2865297D2C6929292E6D61702828285B742C655D293D3E60247B';
wwv_flow_imp.g_varchar2_table(268) := '656E636F6465555249436F6D706F6E656E742874297D3D247B656E636F6465555249436F6D706F6E656E742865297D6029292E6A6F696E28222622297D2C742E663D66756E6374696F6E2874297B72657475726E20742E7468656E2828287B6172726179';
wwv_flow_imp.g_varchar2_table(269) := '4275666665723A747D293D3E7B636F6E737420653D66756E6374696F6E2874297B636F6E737420653D6E657720417272617942756666657228742E627974654C656E677468293B72657475726E206E65772055696E743841727261792865292E73657428';
wwv_flow_imp.g_varchar2_table(270) := '6E65772055696E74384172726179287429292C657D2874293B72657475726E7B61727261794275666665723A652C7472616E736665727261626C65733A5B655D7D7D29297D2C742E673D66756E6374696F6E28742C65297B636F6E73747B746872657368';
wwv_flow_imp.g_varchar2_table(271) := '6F6C64733A697D3D742C723D6F28742C5B227468726573686F6C6473225D293B6C657420733D5B5D2C6E3D2D312F303B72657475726E204F626A6563742E656E74726965732869292E666F72456163682828285B742C695D293D3E7B636F6E737420723D';
wwv_flow_imp.g_varchar2_table(272) := '4E756D6265722874293B723C3D652626723E6E2626286E3D722C733D226E756D626572223D3D747970656F6620693F5B695D3A69297D29292C4F626A6563742E61737369676E287B6C6576656C733A737D2C72297D2C742E703D66756E6374696F6E2874';
wwv_flow_imp.g_varchar2_table(273) := '2C65297B72657475726E20742E7468656E2828743D3E7B7661727B646174613A697D3D742C723D6F28742C5B2264617461225D293B6C657420733D693B72657475726E2065262628733D6E657720466C6F61743332417272617928692E6C656E67746829';
wwv_flow_imp.g_varchar2_table(274) := '2C732E736574286929292C4F626A6563742E61737369676E284F626A6563742E61737369676E287B7D2C72292C7B646174613A732C7472616E736665727261626C65733A5B732E6275666665725D7D297D29297D7D29292C7228302C2866756E6374696F';
wwv_flow_imp.g_varchar2_table(275) := '6E2874297B636F6E737420653D743D3E50726F6D6973652E72656A656374286E6577204572726F7228604E6F206D616E61676572207265676973746572656420666F7220247B747D6029293B636F6E737420693D22756E646566696E656422213D747970';
wwv_flow_imp.g_varchar2_table(276) := '656F662073656C663F73656C663A22756E646566696E656422213D747970656F662077696E646F773F77696E646F773A676C6F62616C3B692E6163746F723D6E657720742E4128692C6E657720636C6173737B636F6E7374727563746F7228297B746869';
wwv_flow_imp.g_varchar2_table(277) := '732E6D616E61676572733D7B7D2C746869732E696E69743D28652C69293D3E28746869732E6D616E61676572735B652E6D616E6167657249645D3D6E657720742E4C2865292C50726F6D6973652E7265736F6C76652829292C746869732E666574636854';
wwv_flow_imp.g_varchar2_table(278) := '696C653D28742C692C722C732C6E2C6F293D3E7B76617220613B72657475726E286E756C6C3D3D3D28613D746869732E6D616E61676572735B745D297C7C766F696420303D3D3D613F766F696420303A612E666574636854696C6528692C722C732C6E2C';
wwv_flow_imp.g_varchar2_table(279) := '6F29297C7C652874297D2C746869732E6665746368416E64506172736554696C653D28692C722C732C6E2C6F2C61293D3E7B76617220683B72657475726E20742E7028286E756C6C3D3D3D28683D746869732E6D616E61676572735B695D297C7C766F69';
wwv_flow_imp.g_varchar2_table(280) := '6420303D3D3D683F766F696420303A682E6665746368416E64506172736554696C6528722C732C6E2C6F2C6129297C7C652869292C2130297D2C746869732E6665746368436F6E746F757254696C653D28692C722C732C6E2C6F2C612C68293D3E7B7661';
wwv_flow_imp.g_varchar2_table(281) := '72206C3B72657475726E20742E6628286E756C6C3D3D3D286C3D746869732E6D616E61676572735B695D297C7C766F696420303D3D3D6C3F766F696420303A6C2E6665746368436F6E746F757254696C6528722C732C6E2C6F2C612C6829297C7C652869';
wwv_flow_imp.g_varchar2_table(282) := '29297D7D7D297D29292C7228302C2866756E6374696F6E2874297B636F6E737420653D7B776F726B657255726C3A22227D3B6C657420692C723D303B636C61737320737B636F6E7374727563746F7228297B746869732E6465636F6465496D6167653D28';
wwv_flow_imp.g_varchar2_table(283) := '652C692C72293D3E742E7028742E6428652C692C72292C2131297D7D636C617373206E7B636F6E7374727563746F72286E297B746869732E666574636854696C653D28742C652C692C722C73293D3E746869732E6163746F722E73656E64282266657463';
wwv_flow_imp.g_varchar2_table(284) := '6854696C65222C5B5D2C722C732C746869732E6D616E6167657249642C742C652C69292C746869732E6665746368416E64506172736554696C653D28742C652C692C722C73293D3E746869732E6163746F722E73656E6428226665746368416E64506172';
wwv_flow_imp.g_varchar2_table(285) := '736554696C65222C5B5D2C722C732C746869732E6D616E6167657249642C742C652C69292C746869732E6665746368436F6E746F757254696C653D28742C652C692C722C732C6E293D3E746869732E6163746F722E73656E6428226665746368436F6E74';
wwv_flow_imp.g_varchar2_table(286) := '6F757254696C65222C5B5D2C732C6E2C746869732E6D616E6167657249642C742C652C692C72293B636F6E7374206F3D746869732E6D616E6167657249643D2B2B723B746869732E6163746F723D6E2E6163746F727C7C66756E6374696F6E28297B6966';
wwv_flow_imp.g_varchar2_table(287) := '282169297B636F6E737420723D6E657720576F726B657228652E776F726B657255726C292C6E3D6E657720733B693D6E657720742E4128722C6E297D72657475726E20697D28292C746869732E6C6F616465643D746869732E6163746F722E73656E6428';
wwv_flow_imp.g_varchar2_table(288) := '22696E6974222C5B5D2C6E65772041626F7274436F6E74726F6C6C65722C766F696420302C4F626A6563742E61737369676E284F626A6563742E61737369676E287B7D2C6E292C7B6D616E6167657249643A6F7D29297D7D426C6F622E70726F746F7479';
wwv_flow_imp.g_varchar2_table(289) := '70652E61727261794275666665727C7C28426C6F622E70726F746F747970652E61727261794275666665723D66756E6374696F6E28297B72657475726E206E65772050726F6D697365282828742C65293D3E7B636F6E737420693D6E65772046696C6552';
wwv_flow_imp.g_varchar2_table(290) := '65616465723B692E6F6E6C6F61643D653D3E7B76617220693B72657475726E2074286E756C6C3D3D3D28693D652E746172676574297C7C766F696420303D3D3D693F766F696420303A692E726573756C74297D2C692E6F6E6572726F723D652C692E7265';
wwv_flow_imp.g_varchar2_table(291) := '6164417341727261794275666665722874686973297D29297D293B636F6E7374206F3D743D3E28652C69293D3E7B6966286920696E7374616E63656F662041626F7274436F6E74726F6C6C65722972657475726E207428652C69293B7B636F6E73742072';
wwv_flow_imp.g_varchar2_table(292) := '3D6E65772041626F7274436F6E74726F6C6C65723B72657475726E207428652C72292E7468656E2828743D3E6928766F696420302C742E646174612C742E6361636865436F6E74726F6C2C742E6578706972657329292C28743D3E6928742929292E6361';
wwv_flow_imp.g_varchar2_table(293) := '7463682828743D3E6928742929292C7B63616E63656C3A28293D3E722E61626F727428297D7D7D2C613D6E6577205365743B636F6E737420683D7B67656E657261746549736F6C696E65733A742E622C44656D536F757263653A636C6173737B636F6E73';
wwv_flow_imp.g_varchar2_table(294) := '74727563746F72287B75726C3A652C636163686553697A653A693D3130302C69643A723D2264656D222C656E636F64696E673A733D2274657272617269756D222C6D61787A6F6F6D3A683D31322C776F726B65723A6C3D21302C74696D656F75744D733A';
wwv_flow_imp.g_varchar2_table(295) := '633D3165342C6163746F723A647D297B746869732E74696D696E6743616C6C6261636B733D5B5D2C746869732E6F6E54696D696E673D743D3E7B746869732E74696D696E6743616C6C6261636B732E707573682874297D2C746869732E73657475704D61';
wwv_flow_imp.g_varchar2_table(296) := '706C696272653D743D3E7B742E61646450726F746F636F6C28746869732E73686172656444656D50726F746F636F6C49642C746869732E73686172656444656D50726F746F636F6C292C742E61646450726F746F636F6C28746869732E636F6E746F7572';
wwv_flow_imp.g_varchar2_table(297) := '50726F746F636F6C49642C746869732E636F6E746F757250726F746F636F6C297D2C746869732E73686172656444656D50726F746F636F6C56343D28652C69293D3E742E5F28746869732C766F696420302C766F696420302C2866756E6374696F6E2A28';
wwv_flow_imp.g_varchar2_table(298) := '297B636F6E73745B722C732C6E5D3D746869732E706172736555726C28652E75726C292C6F3D6E657720742E5428226D61696E22293B6C657420613B7472797B636F6E737420743D7969656C6420746869732E6D616E616765722E666574636854696C65';
wwv_flow_imp.g_varchar2_table(299) := '28722C732C6E2C692C6F293B613D6F2E66696E69736828652E75726C293B72657475726E7B646174613A7969656C6420742E646174612E617272617942756666657228292C6361636865436F6E74726F6C3A742E6361636865436F6E74726F6C2C657870';
wwv_flow_imp.g_varchar2_table(300) := '697265733A742E657870697265737D7D63617463682874297B7468726F7720613D6F2E6572726F7228652E75726C292C747D66696E616C6C797B746869732E74696D696E6743616C6C6261636B732E666F72456163682828743D3E7428612929297D7D29';
wwv_flow_imp.g_varchar2_table(301) := '292C746869732E636F6E746F757250726F746F636F6C56343D28652C69293D3E742E5F28746869732C766F696420302C766F696420302C2866756E6374696F6E2A28297B636F6E737420723D6E657720742E5428226D61696E22293B6C657420733B7472';
wwv_flow_imp.g_varchar2_table(302) := '797B636F6E73745B6E2C6F2C615D3D746869732E706172736555726C28652E75726C292C683D742E6128652E75726C292C6C3D7969656C6420746869732E6D616E616765722E6665746368436F6E746F757254696C65286E2C6F2C612C742E6728682C6E';
wwv_flow_imp.g_varchar2_table(303) := '292C692C72293B72657475726E20733D722E66696E69736828652E75726C292C7B646174613A6C2E61727261794275666665727D7D63617463682874297B7468726F7720733D722E6572726F7228652E75726C292C747D66696E616C6C797B746869732E';
wwv_flow_imp.g_varchar2_table(304) := '74696D696E6743616C6C6261636B732E666F72456163682828743D3E7428732929297D7D29292C746869732E636F6E746F757250726F746F636F6C3D6F28746869732E636F6E746F757250726F746F636F6C5634292C746869732E73686172656444656D';
wwv_flow_imp.g_varchar2_table(305) := '50726F746F636F6C3D6F28746869732E73686172656444656D50726F746F636F6C5634292C746869732E636F6E746F757250726F746F636F6C55726C3D653D3E60247B746869732E636F6E746F757250726F746F636F6C55726C426173657D3F247B742E';
wwv_flow_imp.g_varchar2_table(306) := '652865297D603B6C657420753D722C663D313B666F72283B612E6861732875293B29753D722B662B2B3B612E6164642875292C746869732E73686172656444656D50726F746F636F6C49643D60247B757D2D736861726564602C746869732E636F6E746F';
wwv_flow_imp.g_varchar2_table(307) := '757250726F746F636F6C49643D60247B757D2D636F6E746F7572602C746869732E73686172656444656D50726F746F636F6C55726C3D60247B746869732E73686172656444656D50726F746F636F6C49647D3A2F2F7B7A7D2F7B787D2F7B797D602C7468';
wwv_flow_imp.g_varchar2_table(308) := '69732E636F6E746F757250726F746F636F6C55726C426173653D60247B746869732E636F6E746F757250726F746F636F6C49647D3A2F2F7B7A7D2F7B787D2F7B797D603B636F6E737420703D6C3F6E3A742E4C3B746869732E6D616E616765723D6E6577';
wwv_flow_imp.g_varchar2_table(309) := '2070287B64656D55726C5061747465726E3A652C636163686553697A653A692C656E636F64696E673A732C6D61787A6F6F6D3A682C74696D656F75744D733A632C6163746F723A647D297D67657444656D54696C6528742C652C692C72297B7265747572';
wwv_flow_imp.g_varchar2_table(310) := '6E20746869732E6D616E616765722E6665746368416E64506172736554696C6528742C652C692C727C7C6E65772041626F7274436F6E74726F6C6C6572297D706172736555726C2874297B636F6E73745B2C652C692C725D3D2F5C2F5C2F285C642B295C';
wwv_flow_imp.g_varchar2_table(311) := '2F285C642B295C2F285C642B292F2E657865632874297C7C5B5D3B72657475726E5B4E756D6265722865292C4E756D6265722869292C4E756D6265722872295D7D7D2C48656967687454696C653A742E482C4C6F63616C44656D4D616E616765723A742E';
wwv_flow_imp.g_varchar2_table(312) := '4C2C6465636F6465506172736564496D6167653A742E632C73657420776F726B657255726C2874297B652E776F726B657255726C3D747D2C67657420776F726B657255726C28297B72657475726E20652E776F726B657255726C7D7D3B72657475726E20';
wwv_flow_imp.g_varchar2_table(313) := '687D29292C697D29293B0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(44304646841356762)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_file_name=>'maplibre-contour.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E737420636F6D7075746552616D70203D2028636F6C6F7252616D702C207465727261696E426173652C2076616C29203D3E207B0D0A20206966202876616C203C207465727261696E4261736529207B0D0A202020202F2F206E6F646174610D0A20';
wwv_flow_imp.g_varchar2_table(2) := '20202072657475726E205B302C20302C20302C20305D3B0D0A20207D20656C7365206966202876616C203C3D20636F6C6F7252616D702E73746F70735B305D5B305D29207B0D0A2020202072657475726E20636F6C6F7252616D702E73746F70735B305D';
wwv_flow_imp.g_varchar2_table(3) := '5B315D3B0D0A20207D20656C7365206966202876616C203E3D20636F6C6F7252616D702E73746F70735B636F6C6F7252616D702E73746F70732E6C656E677468202D20315D5B305D29207B0D0A2020202072657475726E20636F6C6F7252616D702E7374';
wwv_flow_imp.g_varchar2_table(4) := '6F70735B636F6C6F7252616D702E73746F70732E6C656E677468202D20315D5B315D3B0D0A20207D0D0A2020666F7220286C65742069203D20303B2069203C20636F6C6F7252616D702E73746F70732E6C656E6774683B2069202B2B29207B0D0A202020';
wwv_flow_imp.g_varchar2_table(5) := '206966202876616C203C3D20636F6C6F7252616D702E73746F70735B69202B20315D5B305D29207B0D0A20202020202072657475726E20636F6C6F72496E74657270280D0A2020202020202020636F6C6F7252616D702E73746F70735B695D5B315D2C0D';
wwv_flow_imp.g_varchar2_table(6) := '0A2020202020202020636F6C6F7252616D702E73746F70735B69202B20315D5B315D2C0D0A20202020202020202876616C202D20636F6C6F7252616D702E73746F70735B695D5B305D29202F2028636F6C6F7252616D702E73746F70735B69202B20315D';
wwv_flow_imp.g_varchar2_table(7) := '5B305D202D20636F6C6F7252616D702E73746F70735B695D5B305D292C0D0A202020202020293B0D0A202020207D0D0A20207D0D0A7D3B0D0A0D0A636F6E737420636F6C6F72496E74657270203D2028612C20622C207429203D3E207B0D0A20202F2F20';
wwv_flow_imp.g_varchar2_table(8) := '746F646F3A207573652068636C0D0A202072657475726E205B0D0A20202020615B305D202A202831202D207429202B20625B305D202A20742C0D0A20202020615B315D202A202831202D207429202B20625B315D202A20742C0D0A20202020615B325D20';
wwv_flow_imp.g_varchar2_table(9) := '2A202831202D207429202B20625B325D202A20742C0D0A20202020615B335D202A202831202D207429202B20625B335D202A20742C0D0A20205D3B0D0A7D3B0D0A0D0A636F6E73742070726F6365737354696C65203D206173796E6320287B2064617461';
wwv_flow_imp.g_varchar2_table(10) := '2C20705F7465727261696E5F66656174757265732C20666F726D61742C207465727261696E426173652C207465727261696E5265736F6C7574696F6E2C20636F6C6F7252616D702C206261636B67726F756E64436F6C6F72207D29203D3E207B0D0A2020';
wwv_flow_imp.g_varchar2_table(11) := '2F2F20437265617465207468652063616E76617320696E20776869636820746F2072656E6465722074686520696D6167652E0D0A2020636F6E73742063616E766173203D206E6577204F666673637265656E43616E766173283235362C20323536293B0D';
wwv_flow_imp.g_varchar2_table(12) := '0A2020636F6E73742063203D2063616E7661732E676574436F6E7465787428273264272C207B2077696C6C526561644672657175656E746C793A2074727565207D293B20200D0A0D0A20202F2F20436F6E76657274207468652062617365363420646174';
wwv_flow_imp.g_varchar2_table(13) := '6120696E746F20616E20496D61676544617461206F626A6563742E0D0A2020636F6E737420696D61676544617461203D20632E637265617465496D6167654461746128646174612E77696474682C20646174612E686569676874293B200D0A2020636F6E';
wwv_flow_imp.g_varchar2_table(14) := '7374206461746176696577203D206E657720446174615669657728646174612E63656C6C64617461293B0D0A2020636F6E7374206C656E203D2064617461766965772E627974654C656E6774683B0D0A0D0A2020636F6E737420697344454D203D206461';
wwv_flow_imp.g_varchar2_table(15) := '74612E62616E64636F756E74203D3D203120262620646174612E63656C6C6465707468203D3D2033323B0D0A0D0A202069662028666F726D6174203D3D3D20277261737465722729207B0D0A2020202069662028705F7465727261696E5F666561747572';
wwv_flow_imp.g_varchar2_table(16) := '65732E696E636C756465732827636F6C6F722D72656C696566272929207B0D0A2020202020202F2F205072652D72656E646572656420636F6C6F722072656C6965660D0A2020202020206966202821697344454D29207B0D0A2020202020202020746872';
wwv_flow_imp.g_varchar2_table(17) := '6F77206E6577204572726F72286043616E6E6F7420636F6E76657274207468652070726F7669646564207261737465722028247B646174612E62616E64636F756E747D2062616E64732C20247B646174612E63656C6C64657074687D2D62697420706978';
wwv_flow_imp.g_varchar2_table(18) := '656C732920746F20612044454D206C6179657260293B0D0A2020202020207D0D0A0D0A202020202020666F7220286C65742069203D20303B2069203C206C656E3B2069202B3D203429207B0D0A2020202020202020636F6E73742076616C203D20646174';
wwv_flow_imp.g_varchar2_table(19) := '61766965772E676574466C6F6174333228692C2066616C7365293B0D0A2020202020202020636F6E7374205B722C20672C20622C20615D203D20636F6D7075746552616D7028636F6C6F7252616D702C207465727261696E426173652C2076616C293B0D';
wwv_flow_imp.g_varchar2_table(20) := '0A2020202020202020696D616765446174612E646174615B695D203D20723B0D0A2020202020202020696D616765446174612E646174615B69202B20315D203D2020673B0D0A2020202020202020696D616765446174612E646174615B69202B20325D20';
wwv_flow_imp.g_varchar2_table(21) := '3D20623B0D0A2020202020202020696D616765446174612E646174615B69202B20335D203D20613B0D0A2020202020207D0D0A202020207D20656C7365207B0D0A2020202020202F2F20436F6C6F722052474220496D616765202D2033206F7220342062';
wwv_flow_imp.g_varchar2_table(22) := '616E642C20756E7369676E656420386269740D0A20202020202069662028215B332C20345D2E696E636C7564657328646174612E62616E64636F756E7429207C7C20646174612E63656C6C646570746820213D3D203829207B0D0A202020202020202074';
wwv_flow_imp.g_varchar2_table(23) := '68726F77206E6577204572726F72286043616E6E6F7420636F6E76657274207468652070726F7669646564207261737465722028247B646174612E62616E64636F756E747D2062616E64732C20247B646174612E63656C6C64657074687D2D6269742070';
wwv_flow_imp.g_varchar2_table(24) := '6978656C732920746F20616E20524742206C6179657260293B0D0A2020202020207D0D0A0D0A20202020202069662028646174612E62616E64636F756E74203D3D3D203329207B0D0A2020202020202020666F7220286C65742069203D20302C206A203D';
wwv_flow_imp.g_varchar2_table(25) := '20303B2069203C206C656E3B2069202B3D203329207B0D0A20202020202020202020696D616765446174612E646174615B6A5D203D2064617461766965772E67657455696E74382869293B0D0A20202020202020202020696D616765446174612E646174';
wwv_flow_imp.g_varchar2_table(26) := '615B6A202B20315D203D2064617461766965772E67657455696E74382869202B2031293B0D0A20202020202020202020696D616765446174612E646174615B6A202B20325D203D2064617461766965772E67657455696E74382869202B2032293B0D0A20';
wwv_flow_imp.g_varchar2_table(27) := '2020202020202020202020696620280D0A20202020202020202020202020206261636B67726F756E64436F6C6F7220213D3D206E756C6C0D0A2020202020202020202020202020262620696D616765446174612E646174615B6A5D203D3D3D206261636B';
wwv_flow_imp.g_varchar2_table(28) := '67726F756E64436F6C6F725B305D0D0A2020202020202020202020202020262620696D616765446174612E646174615B6A202B20315D203D3D3D206261636B67726F756E64436F6C6F725B315D0D0A2020202020202020202020202020262620696D6167';
wwv_flow_imp.g_varchar2_table(29) := '65446174612E646174615B6A202B20325D203D3D3D206261636B67726F756E64436F6C6F725B325D0D0A20202020202020202020202029207B0D0A2020202020202020202020202020696D616765446174612E646174615B6A202B20335D203D20303B0D';
wwv_flow_imp.g_varchar2_table(30) := '0A2020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020696D616765446174612E646174615B6A202B20335D203D203235353B0D0A2020202020202020202020207D0D0A202020202020202020206A202B3D20343B0D';
wwv_flow_imp.g_varchar2_table(31) := '0A20202020202020207D0D0A2020202020207D20656C7365207B0D0A2020202020202020666F7220286C65742069203D20302C206A203D20303B2069203C206C656E3B2069202B3D203429207B0D0A20202020202020202020696D616765446174612E64';
wwv_flow_imp.g_varchar2_table(32) := '6174615B6A5D203D2064617461766965772E67657455696E74382869293B0D0A20202020202020202020696D616765446174612E646174615B6A202B20315D203D2064617461766965772E67657455696E74382869202B2031293B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(33) := '202020696D616765446174612E646174615B6A202B20325D203D2064617461766965772E67657455696E74382869202B2032293B0D0A20202020202020202020696D616765446174612E646174615B6A202B20335D203D2064617461766965772E676574';
wwv_flow_imp.g_varchar2_table(34) := '55696E74382869202B2033293B0D0A202020202020202020206A202B3D20343B0D0A20202020202020207D0D0A2020202020207D0D0A202020207D0D0A20207D20656C73652069662028666F726D6174203D3D3D20277261737465722D64656D2729207B';
wwv_flow_imp.g_varchar2_table(35) := '0D0A202020202F2F205465727261696E5247420D0A202020206966202821697344454D29207B0D0A2020202020207468726F77206E6577204572726F72286043616E6E6F7420636F6E76657274207468652070726F766964656420726173746572202824';
wwv_flow_imp.g_varchar2_table(36) := '7B646174612E62616E64636F756E747D2062616E64732C20247B646174612E63656C6C64657074687D2D62697420706978656C732920746F20612044454D206C6179657260293B0D0A202020207D0D0A0D0A20202020666F7220286C65742069203D2030';
wwv_flow_imp.g_varchar2_table(37) := '3B2069203C206C656E3B2069202B3D203429207B0D0A202020202020636F6E73742076616C203D2064617461766965772E676574466C6F6174333228692C2066616C7365293B0D0A202020202020636F6E7374206532203D20282876616C203C20746572';
wwv_flow_imp.g_varchar2_table(38) := '7261696E42617365203F2030203A2076616C29202D207465727261696E4261736529202F207465727261696E5265736F6C7574696F6E3B0D0A202020202020636F6E73742072203D204D6174682E666C6F6F72286532202F2028323536202A2032353629';
wwv_flow_imp.g_varchar2_table(39) := '293B0D0A202020202020636F6E73742067203D204D6174682E666C6F6F72286532202F20323536292025203235363B0D0A202020202020636F6E73742062203D204D6174682E666C6F6F72286532292025203235363B0D0A202020202020696D61676544';
wwv_flow_imp.g_varchar2_table(40) := '6174612E646174615B695D203D20723B0D0A202020202020696D616765446174612E646174615B69202B20315D203D2020673B0D0A202020202020696D616765446174612E646174615B69202B20325D203D20623B0D0A202020202020696D6167654461';
wwv_flow_imp.g_varchar2_table(41) := '74612E646174615B69202B20335D203D203235353B0D0A202020207D0D0A20207D0D0A0D0A202069662028646174612E776964746820213D3D20323536207C7C20646174612E68656967687420213D3D2032353629207B0D0A20202020636F6E736F6C65';
wwv_flow_imp.g_varchar2_table(42) := '2E7761726E28607761726E696E673A20756E65787065637465642074696C652073697A6520247B646174612E77696474687D207820247B646174612E6865696768747D60293B0D0A20207D0D0A0D0A2020632E707574496D6167654461746128696D6167';
wwv_flow_imp.g_varchar2_table(43) := '65446174612C20302C20302C20302C20302C203235362C20323536293B0D0A0D0A20202F2F205772697465207468652063616E76617320617320616E20696D61676520696E206163636F7264616E6365207769746820746865205261737465722054696C';
wwv_flow_imp.g_varchar2_table(44) := '652070726F746F636F6C2E0D0A2020636F6E737420726573756C74203D206177616974202861776169742063616E7661732E636F6E76657274546F426C6F622829292E617272617942756666657228293B0D0A0D0A202072657475726E207B2064617461';
wwv_flow_imp.g_varchar2_table(45) := '3A20726573756C74207D3B0D0A7D0D0A0D0A6F6E6D657373616765203D20286576656E7429203D3E207B0D0A202070726F6365737354696C65286576656E742E64617461290D0A202020202E7468656E2864617461203D3E207B0D0A202020202020706F';
wwv_flow_imp.g_varchar2_table(46) := '73744D657373616765287B207374617475733A202773756363657373272C2064617461207D293B0D0A202020207D290D0A202020202E6361746368286572726F72203D3E207B0D0A202020202020706F73744D657373616765287B207374617475733A20';
wwv_flow_imp.g_varchar2_table(47) := '276572726F72272C206D6573736167653A206572726F722E6D657373616765207D293B0D0A202020207D293B0D0A7D3B0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(44308857870838984)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_file_name=>'mapbits_georaster_worker.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E737420636F6D7075746552616D703D28742C652C61293D3E7B696628613C652972657475726E5B302C302C302C305D3B696628613C3D742E73746F70735B305D5B305D2972657475726E20742E73746F70735B305D5B315D3B696628613E3D742E';
wwv_flow_imp.g_varchar2_table(2) := '73746F70735B742E73746F70732E6C656E6774682D315D5B305D2972657475726E20742E73746F70735B742E73746F70732E6C656E6774682D315D5B315D3B666F72286C657420653D303B653C742E73746F70732E6C656E6774683B652B2B2969662861';
wwv_flow_imp.g_varchar2_table(3) := '3C3D742E73746F70735B652B315D5B305D2972657475726E20636F6C6F72496E7465727028742E73746F70735B655D5B315D2C742E73746F70735B652B315D5B315D2C28612D742E73746F70735B655D5B305D292F28742E73746F70735B652B315D5B30';
wwv_flow_imp.g_varchar2_table(4) := '5D2D742E73746F70735B655D5B305D29297D2C636F6C6F72496E746572703D28742C652C61293D3E5B745B305D2A28312D61292B655B305D2A612C745B315D2A28312D61292B655B315D2A612C745B325D2A28312D61292B655B325D2A612C745B335D2A';
wwv_flow_imp.g_varchar2_table(5) := '28312D61292B655B335D2A615D2C70726F6365737354696C653D6173796E63287B646174613A742C705F7465727261696E5F66656174757265733A652C666F726D61743A612C7465727261696E426173653A6F2C7465727261696E5265736F6C7574696F';
wwv_flow_imp.g_varchar2_table(6) := '6E3A722C636F6C6F7252616D703A732C6261636B67726F756E64436F6C6F723A6E7D293D3E7B636F6E737420643D6E6577204F666673637265656E43616E766173283235362C323536292C6C3D642E676574436F6E7465787428223264222C7B77696C6C';
wwv_flow_imp.g_varchar2_table(7) := '526561644672657175656E746C793A21307D292C693D6C2E637265617465496D6167654461746128742E77696474682C742E686569676874292C633D6E657720446174615669657728742E63656C6C64617461292C703D632E627974654C656E6774682C';
wwv_flow_imp.g_varchar2_table(8) := '683D313D3D742E62616E64636F756E74262633323D3D742E63656C6C64657074683B69662822726173746572223D3D3D6129696628652E696E636C756465732822636F6C6F722D72656C6965662229297B6966282168297468726F77206E657720457272';
wwv_flow_imp.g_varchar2_table(9) := '6F72286043616E6E6F7420636F6E76657274207468652070726F7669646564207261737465722028247B742E62616E64636F756E747D2062616E64732C20247B742E63656C6C64657074687D2D62697420706978656C732920746F20612044454D206C61';
wwv_flow_imp.g_varchar2_table(10) := '79657260293B666F72286C657420743D303B743C703B742B3D34297B636F6E737420653D632E676574466C6F6174333228742C2131292C5B612C722C6E2C645D3D636F6D7075746552616D7028732C6F2C65293B692E646174615B745D3D612C692E6461';
wwv_flow_imp.g_varchar2_table(11) := '74615B742B315D3D722C692E646174615B742B325D3D6E2C692E646174615B742B335D3D647D7D656C73657B696628215B332C345D2E696E636C7564657328742E62616E64636F756E74297C7C38213D3D742E63656C6C6465707468297468726F77206E';
wwv_flow_imp.g_varchar2_table(12) := '6577204572726F72286043616E6E6F7420636F6E76657274207468652070726F7669646564207261737465722028247B742E62616E64636F756E747D2062616E64732C20247B742E63656C6C64657074687D2D62697420706978656C732920746F20616E';
wwv_flow_imp.g_varchar2_table(13) := '20524742206C6179657260293B696628333D3D3D742E62616E64636F756E7429666F72286C657420743D302C653D303B743C703B742B3D3329692E646174615B655D3D632E67657455696E74382874292C692E646174615B652B315D3D632E6765745569';
wwv_flow_imp.g_varchar2_table(14) := '6E743828742B31292C692E646174615B652B325D3D632E67657455696E743828742B32292C6E756C6C213D3D6E2626692E646174615B655D3D3D3D6E5B305D2626692E646174615B652B315D3D3D3D6E5B315D2626692E646174615B652B325D3D3D3D6E';
wwv_flow_imp.g_varchar2_table(15) := '5B325D3F692E646174615B652B335D3D303A692E646174615B652B335D3D3235352C652B3D343B656C736520666F72286C657420743D302C653D303B743C703B742B3D3429692E646174615B655D3D632E67657455696E74382874292C692E646174615B';
wwv_flow_imp.g_varchar2_table(16) := '652B315D3D632E67657455696E743828742B31292C692E646174615B652B325D3D632E67657455696E743828742B32292C692E646174615B652B335D3D632E67657455696E743828742B33292C652B3D347D656C736520696628227261737465722D6465';
wwv_flow_imp.g_varchar2_table(17) := '6D223D3D3D61297B6966282168297468726F77206E6577204572726F72286043616E6E6F7420636F6E76657274207468652070726F7669646564207261737465722028247B742E62616E64636F756E747D2062616E64732C20247B742E63656C6C646570';
wwv_flow_imp.g_varchar2_table(18) := '74687D2D62697420706978656C732920746F20612044454D206C6179657260293B666F72286C657420743D303B743C703B742B3D34297B636F6E737420653D632E676574466C6F6174333228742C2131292C613D2828653C6F3F303A65292D6F292F722C';
wwv_flow_imp.g_varchar2_table(19) := '733D4D6174682E666C6F6F7228612F3635353336292C6E3D4D6174682E666C6F6F7228612F32353629253235362C643D4D6174682E666C6F6F72286129253235363B692E646174615B745D3D732C692E646174615B742B315D3D6E2C692E646174615B74';
wwv_flow_imp.g_varchar2_table(20) := '2B325D3D642C692E646174615B742B335D3D3235357D7D3235363D3D3D742E776964746826263235363D3D3D742E6865696768747C7C636F6E736F6C652E7761726E28607761726E696E673A20756E65787065637465642074696C652073697A6520247B';
wwv_flow_imp.g_varchar2_table(21) := '742E77696474687D207820247B742E6865696768747D60292C6C2E707574496D6167654461746128692C302C302C302C302C3235362C323536293B72657475726E7B646174613A617761697428617761697420642E636F6E76657274546F426C6F622829';
wwv_flow_imp.g_varchar2_table(22) := '292E617272617942756666657228297D7D3B6F6E6D6573736167653D743D3E7B70726F6365737354696C6528742E64617461292E7468656E2828743D3E7B706F73744D657373616765287B7374617475733A2273756363657373222C646174613A747D29';
wwv_flow_imp.g_varchar2_table(23) := '7D29292E63617463682828743D3E7B706F73744D657373616765287B7374617475733A226572726F72222C6D6573736167653A742E6D6573736167657D297D29297D3B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(66840024745998109)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_file_name=>'mapbits_georaster_worker.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F47454F5241535445525F57414954494E473D7B7D3B66756E6374696F6E206D6170626974735F67656F7261737465725F776169745F666F725F696E69742865297B72657475726E206E65772050726F6D697365282828';
wwv_flow_imp.g_varchar2_table(2) := '742C72293D3E7B6520696E204D4150424954535F47454F5241535445525F57414954494E477C7C284D4150424954535F47454F5241535445525F57414954494E475B655D3D5B5D292C6E756C6C213D3D4D4150424954535F47454F5241535445525F5741';
wwv_flow_imp.g_varchar2_table(3) := '4954494E475B655D3F4D4150424954535F47454F5241535445525F57414954494E475B655D2E707573682828653D3E7B742865297D29293A7428617065782E6974656D286529297D29297D6173796E632066756E6374696F6E206D6170626974735F6765';
wwv_flow_imp.g_varchar2_table(4) := '6F726173746572287B705F6974656D5F69643A652C705F616A61785F6964656E7469666965723A742C705F726567696F6E5F69643A722C705F73657175656E63653A612C705F7469746C653A732C705F636865636B626F785F636F6C6F723A6E2C705F69';
wwv_flow_imp.g_varchar2_table(5) := '6E69745F7669736962696C6974793A6F2C705F6F7061636974793A692C705F7375626D69745F6974656D733A6C2C705F6C617965725F747970653A632C705F636F6C6F725F72616D703A752C705F657861676765726174696F6E3A642C705F7465727261';
wwv_flow_imp.g_varchar2_table(6) := '696E5F66656174757265733A702C705F636F6C6F725F72656C6965665F6D61703A682C705F706C7567696E5F66696C65733A672C705F6267636F6C6F723A6D7D297B66756E6374696F6E205F28652C74297B72657475726E20652F4D6174682E706F7728';
wwv_flow_imp.g_varchar2_table(7) := '322C74292A3336302D3138307D66756E6374696F6E207928652C74297B636F6E737420723D4D6174682E50492D322A4D6174682E50492A652F4D6174682E706F7728322C74293B72657475726E203138302F4D6174682E50492A4D6174682E6174616E28';
wwv_flow_imp.g_varchar2_table(8) := '2E352A284D6174682E6578702872292D4D6174682E657870282D722929297D66756E6374696F6E206228652C74297B636F6E737420723D4D6174682E706F7728322C65292C613D28733D742C4D6174682E50492A732F313830293B76617220733B726574';
wwv_flow_imp.g_varchar2_table(9) := '75726E20722A28312D4D6174682E6C6F67284D6174682E74616E2861292B312F4D6174682E636F73286129292F4D6174682E5049292F327D636F6E737420663D286D61706C69627265676C2E67657456657273696F6E3F6D61706C69627265676C2E6765';
wwv_flow_imp.g_varchar2_table(10) := '7456657273696F6E28293A6D61706C69627265676C2E76657273696F6E292E73706C697428222E22292E6D61702828653D3E7061727365496E7428652929292C773D28652C743D302C723D30293D3E665B305D213D3D653F665B305D3E653A665B315D21';
wwv_flow_imp.g_varchar2_table(11) := '3D3D743F665B315D3E743A665B325D3E3D722C6B3D21772834292C763D7728352C36292C413D7728332C34293B703D28707C7C2222292E73706C697428223A22292E66696C7465722828653D3E21216529293B636F6E737420493D617065782E72656769';
wwv_flow_imp.g_varchar2_table(12) := '6F6E2872292E63616C6C28226765744D61704F626A65637422293B6C657420783D617065782E73746F726167652E676574436F6F6B696528224D6170626974735F47656F5261737465724C617965725F222B652B225F222B2476282270496E7374616E63';
wwv_flow_imp.g_varchar2_table(13) := '652229297C7C282259223D3D3D6F3F2276697369626C65223A226E6F6E6522292C4D3D21312C533D21312C523D21313B636F6E737420453D7B616C696365626C75653A5B3234302C3234382C3235355D2C616E746971756577686974653A5B3235302C32';
wwv_flow_imp.g_varchar2_table(14) := '33352C3231355D2C617175613A5B302C3235352C3235355D2C617175616D6172696E653A5B3132372C3235352C3231325D2C617A7572653A5B3234302C3235352C3235355D2C62656967653A5B3234352C3234352C3232305D2C6269737175653A5B3235';
wwv_flow_imp.g_varchar2_table(15) := '352C3232382C3139365D2C626C61636B3A5B302C302C305D2C626C616E63686564616C6D6F6E643A5B3235352C3233352C3230355D2C626C75653A5B302C302C3235355D2C626C756576696F6C65743A5B3133382C34332C3232365D2C62726F776E3A5B';
wwv_flow_imp.g_varchar2_table(16) := '3136352C34322C34325D2C6275726C79776F6F643A5B3232322C3138342C3133355D2C6361646574626C75653A5B39352C3135382C3136305D2C636861727472657573653A5B3132372C3235352C305D2C63686F636F6C6174653A5B3231302C3130352C';
wwv_flow_imp.g_varchar2_table(17) := '33305D2C636F72616C3A5B3235352C3132372C38305D2C636F726E666C6F776572626C75653A5B3130302C3134392C3233375D2C636F726E73696C6B3A5B3235352C3234382C3232305D2C6372696D736F6E3A5B3232302C32302C36305D2C6379616E3A';
wwv_flow_imp.g_varchar2_table(18) := '5B302C3235352C3235355D2C6461726B626C75653A5B302C302C3133395D2C6461726B6379616E3A5B302C3133392C3133395D2C6461726B676F6C64656E726F643A5B3138342C3133342C31315D2C6461726B677261793A5B3136392C3136392C313639';
wwv_flow_imp.g_varchar2_table(19) := '5D2C6461726B677265656E3A5B302C3130302C305D2C6461726B677265793A5B3136392C3136392C3136395D2C6461726B6B68616B693A5B3138392C3138332C3130375D2C6461726B6D6167656E74613A5B3133392C302C3133395D2C6461726B6F6C69';
wwv_flow_imp.g_varchar2_table(20) := '7665677265656E3A5B38352C3130372C34375D2C6461726B6F72616E67653A5B3235352C3134302C305D2C6461726B6F72636869643A5B3135332C35302C3230345D2C6461726B7265643A5B3133392C302C305D2C6461726B73616C6D6F6E3A5B323333';
wwv_flow_imp.g_varchar2_table(21) := '2C3135302C3132325D2C6461726B736561677265656E3A5B3134332C3138382C3134335D2C6461726B736C617465626C75653A5B37322C36312C3133395D2C6461726B736C617465677261793A5B34372C37392C37395D2C6461726B736C617465677265';
wwv_flow_imp.g_varchar2_table(22) := '793A5B34372C37392C37395D2C6461726B74757271756F6973653A5B302C3230362C3230395D2C6461726B76696F6C65743A5B3134382C302C3231315D2C6465657070696E6B3A5B3235352C32302C3134375D2C64656570736B79626C75653A5B302C31';
wwv_flow_imp.g_varchar2_table(23) := '39312C3235355D2C64696D677261793A5B3130352C3130352C3130355D2C64696D677265793A5B3130352C3130352C3130355D2C646F64676572626C75653A5B33302C3134342C3235355D2C66697265627269636B3A5B3137382C33342C33345D2C666C';
wwv_flow_imp.g_varchar2_table(24) := '6F72616C77686974653A5B3235352C3235302C3234305D2C666F72657374677265656E3A5B33342C3133392C33345D2C667563687369613A5B3235352C302C3235355D2C6761696E73626F726F3A5B3232302C3232302C3232305D2C67686F7374776869';
wwv_flow_imp.g_varchar2_table(25) := '74653A5B3234382C3234382C3235355D2C676F6C643A5B3235352C3231352C305D2C676F6C64656E726F643A5B3231382C3136352C33325D2C677261793A5B3132382C3132382C3132385D2C677265656E3A5B302C3132382C305D2C677265656E79656C';
wwv_flow_imp.g_varchar2_table(26) := '6C6F773A5B3137332C3235352C34375D2C677265793A5B3132382C3132382C3132385D2C686F6E65796465773A5B3234302C3235352C3234305D2C686F7470696E6B3A5B3235352C3130352C3138305D2C696E6469616E7265643A5B3230352C39322C39';
wwv_flow_imp.g_varchar2_table(27) := '325D2C696E6469676F3A5B37352C302C3133305D2C69766F72793A5B3235352C3235352C3234305D2C6B68616B693A5B3234302C3233302C3134305D2C6C6176656E6465723A5B3233302C3233302C3235305D2C6C6176656E646572626C7573683A5B32';
wwv_flow_imp.g_varchar2_table(28) := '35352C3234302C3234355D2C6C61776E677265656E3A5B3132342C3235322C305D2C6C656D6F6E63686966666F6E3A5B3235352C3235302C3230355D2C6C69676874626C75653A5B3137332C3231362C3233305D2C6C69676874636F72616C3A5B323430';
wwv_flow_imp.g_varchar2_table(29) := '2C3132382C3132385D2C6C696768746379616E3A5B3232342C3235352C3235355D2C6C69676874676F6C64656E726F6479656C6C6F773A5B3235302C3235302C3231305D2C6C69676874677261793A5B3231312C3231312C3231315D2C6C696768746772';
wwv_flow_imp.g_varchar2_table(30) := '65656E3A5B3134342C3233382C3134345D2C6C69676874677265793A5B3231312C3231312C3231315D2C6C6967687470696E6B3A5B3235352C3138322C3139335D2C6C6967687473616C6D6F6E3A5B3235352C3136302C3132325D2C6C69676874736561';
wwv_flow_imp.g_varchar2_table(31) := '677265656E3A5B33322C3137382C3137305D2C6C69676874736B79626C75653A5B3133352C3230362C3235305D2C6C69676874736C617465677261793A5B3131392C3133362C3135335D2C6C69676874736C617465677265793A5B3131392C3133362C31';
wwv_flow_imp.g_varchar2_table(32) := '35335D2C6C69676874737465656C626C75653A5B3137362C3139362C3232325D2C6C6967687479656C6C6F773A5B3235352C3235352C3232345D2C6C696D653A5B302C3235352C305D2C6C696D65677265656E3A5B35302C3230352C35305D2C6C696E65';
wwv_flow_imp.g_varchar2_table(33) := '6E3A5B3235302C3234302C3233305D2C6D6167656E74613A5B3235352C302C3235355D2C6D61726F6F6E3A5B3132382C302C305D2C6D656469756D617175616D6172696E653A5B3130322C3230352C3137305D2C6D656469756D626C75653A5B302C302C';
wwv_flow_imp.g_varchar2_table(34) := '3230355D2C6D656469756D6F72636869643A5B3138362C38352C3231315D2C6D656469756D707572706C653A5B3134372C3131322C3231395D2C6D656469756D736561677265656E3A5B36302C3137392C3131335D2C6D656469756D736C617465626C75';
wwv_flow_imp.g_varchar2_table(35) := '653A5B3132332C3130342C3233385D2C6D656469756D737072696E67677265656E3A5B302C3235302C3135345D2C6D656469756D74757271756F6973653A5B37322C3230392C3230345D2C6D656469756D76696F6C65747265643A5B3139392C32312C31';
wwv_flow_imp.g_varchar2_table(36) := '33335D2C6D69646E69676874626C75653A5B32352C32352C3131325D2C6D696E74637265616D3A5B3234352C3235352C3235305D2C6D69737479726F73653A5B3235352C3232382C3232355D2C6D6F63636173696E3A5B3235352C3232382C3138315D2C';
wwv_flow_imp.g_varchar2_table(37) := '6E6176616A6F77686974653A5B3235352C3232322C3137335D2C6E6176793A5B302C302C3132385D2C6F6C646C6163653A5B3235332C3234352C3233305D2C6F6C6976653A5B3132382C3132382C305D2C6F6C697665647261623A5B3130372C3134322C';
wwv_flow_imp.g_varchar2_table(38) := '33355D2C6F72616E67653A5B3235352C3136352C305D2C6F72616E67657265643A5B3235352C36392C305D2C6F72636869643A5B3231382C3131322C3231345D2C70616C65676F6C64656E726F643A5B3233382C3233322C3137305D2C70616C65677265';
wwv_flow_imp.g_varchar2_table(39) := '656E3A5B3135322C3235312C3135325D2C70616C6574757271756F6973653A5B3137352C3233382C3233385D2C70616C6576696F6C65747265643A5B3231392C3131322C3134375D2C706170617961776869703A5B3235352C3233392C3231335D2C7065';
wwv_flow_imp.g_varchar2_table(40) := '616368707566663A5B3235352C3231382C3138355D2C706572753A5B3230352C3133332C36335D2C70696E6B3A5B3235352C3139322C3230335D2C706C756D3A5B3232312C3136302C3232315D2C706F77646572626C75653A5B3137362C3232342C3233';
wwv_flow_imp.g_varchar2_table(41) := '305D2C707572706C653A5B3132382C302C3132385D2C72656265636361707572706C653A5B3130322C35312C3135335D2C7265643A5B3235352C302C305D2C726F737962726F776E3A5B3138382C3134332C3134335D2C726F79616C626C75653A5B3635';
wwv_flow_imp.g_varchar2_table(42) := '2C3130352C3232355D2C736164646C6562726F776E3A5B3133392C36392C31395D2C73616C6D6F6E3A5B3235302C3132382C3131345D2C73616E647962726F776E3A5B3234342C3136342C39365D2C736561677265656E3A5B34362C3133392C38375D2C';
wwv_flow_imp.g_varchar2_table(43) := '7365617368656C6C3A5B3235352C3234352C3233385D2C7369656E6E613A5B3136302C38322C34355D2C73696C7665723A5B3139322C3139322C3139325D2C736B79626C75653A5B3133352C3230362C3233355D2C736C617465626C75653A5B3130362C';
wwv_flow_imp.g_varchar2_table(44) := '39302C3230355D2C736C617465677261793A5B3131322C3132382C3134345D2C736C617465677265793A5B3131322C3132382C3134345D2C736E6F773A5B3235352C3235302C3235305D2C737072696E67677265656E3A5B302C3235352C3132375D2C73';
wwv_flow_imp.g_varchar2_table(45) := '7465656C626C75653A5B37302C3133302C3138305D2C74616E3A5B3231302C3138302C3134305D2C7465616C3A5B302C3132382C3132385D2C74686973746C653A5B3231362C3139312C3231365D2C746F6D61746F3A5B3235352C39392C37315D2C7475';
wwv_flow_imp.g_varchar2_table(46) := '7271756F6973653A5B36342C3232342C3230385D2C76696F6C65743A5B3233382C3133302C3233385D2C77686561743A5B3234352C3232322C3137395D2C77686974653A5B3235352C3235352C3235355D2C7768697465736D6F6B653A5B3234352C3234';
wwv_flow_imp.g_varchar2_table(47) := '352C3234355D2C79656C6C6F773A5B3235352C3235352C305D2C79656C6C6F77677265656E3A5B3135342C3230352C35305D7D2C543D653D3E7B6966286520696E20452972657475726E5B2E2E2E455B655D2C3235355D3B6C657420743B72657475726E';
wwv_flow_imp.g_varchar2_table(48) := '2041727261792E697341727261792865292626333D3D3D652E6C656E6774683F5B2E2E2E652C3235355D3A41727261792E697341727261792865292626343D3D3D652E6C656E6774683F653A28743D652E6D61746368282F5E23285B412D46612D66302D';
wwv_flow_imp.g_varchar2_table(49) := '395D7B367D29242F29293F5B7061727365496E7428745B315D2E73756273747228302C32292C3136292C7061727365496E7428745B315D2E73756273747228322C32292C3136292C7061727365496E7428745B315D2E73756273747228342C32292C3136';
wwv_flow_imp.g_varchar2_table(50) := '292C3235355D3A28743D652E6D61746368282F5E23285B412D46612D66302D395D7B337D29242F29293F5B31372A7061727365496E7428745B315D5B305D2C3136292C31372A7061727365496E7428745B315D5B315D2C3136292C31372A706172736549';
wwv_flow_imp.g_varchar2_table(51) := '6E7428745B315D5B325D2C3136292C3235355D3A28743D652E6D61746368282F5E23285B412D46612D66302D395D7B387D29242F29293F5B7061727365496E7428745B315D2E73756273747228302C32292C3136292C7061727365496E7428745B315D2E';
wwv_flow_imp.g_varchar2_table(52) := '73756273747228322C32292C3136292C7061727365496E7428745B315D2E73756273747228342C32292C3136292C7061727365496E7428745B315D2E73756273747228362C32292C3136295D3A28743D652E6D61746368282F5E23285B412D46612D6630';
wwv_flow_imp.g_varchar2_table(53) := '2D395D7B347D29242F29293F5B31372A7061727365496E7428745B315D5B305D2C3136292C31372A7061727365496E7428745B315D5B315D2C3136292C31372A7061727365496E7428745B315D5B325D2C3136292C31372A7061727365496E7428745B31';
wwv_flow_imp.g_varchar2_table(54) := '5D5B335D2C3136295D3A6E756C6C7D2C473D6D3F54286D293A6E756C6C3B6C657420423B6C657420502C433D313B636F6E737420713D6173796E6328293D3E7B503D617761697420617065782E7365727665722E706C7567696E28742C7B7830313A302C';
wwv_flow_imp.g_varchar2_table(55) := '706167654974656D733A6C3F6C2E73706C697428222C22293A766F696420307D292C2828293D3E7B69662821702E696E636C756465732822636F6C6F722D72656C69656622297C7C502E6E6F5261737465722972657475726E3B636F6E737420653D7B6D';
wwv_flow_imp.g_varchar2_table(56) := '61676D613A5B5B302C302C345D2C5B312C302C355D2C5B312C312C365D2C5B312C312C385D2C5B322C312C395D2C5B322C322C31315D2C5B322C322C31335D2C5B332C332C31355D2C5B332C332C31385D2C5B342C342C32305D2C5B352C342C32325D2C';
wwv_flow_imp.g_varchar2_table(57) := '5B362C352C32345D2C5B362C352C32365D2C5B372C362C32385D2C5B382C372C33305D2C5B392C372C33325D2C5B31302C382C33345D2C5B31312C392C33365D2C5B31322C392C33385D2C5B31332C31302C34315D2C5B31342C31312C34335D2C5B3136';
wwv_flow_imp.g_varchar2_table(58) := '2C31312C34355D2C5B31372C31322C34375D2C5B31382C31332C34395D2C5B31392C31332C35325D2C5B32302C31342C35345D2C5B32312C31342C35365D2C5B32322C31352C35395D2C5B32342C31352C36315D2C5B32352C31362C36335D2C5B32362C';
wwv_flow_imp.g_varchar2_table(59) := '31362C36365D2C5B32382C31362C36385D2C5B32392C31372C37315D2C5B33302C31372C37335D2C5B33322C31372C37355D2C5B33332C31372C37385D2C5B33342C31372C38305D2C5B33362C31382C38335D2C5B33372C31382C38355D2C5B33392C31';
wwv_flow_imp.g_varchar2_table(60) := '382C38385D2C5B34312C31372C39305D2C5B34322C31372C39325D2C5B34342C31372C39355D2C5B34352C31372C39375D2C5B34372C31372C39395D2C5B34392C31372C3130315D2C5B35312C31362C3130335D2C5B35322C31362C3130355D2C5B3534';
wwv_flow_imp.g_varchar2_table(61) := '2C31362C3130375D2C5B35362C31362C3130385D2C5B35372C31352C3131305D2C5B35392C31352C3131325D2C5B36312C31352C3131335D2C5B36332C31352C3131345D2C5B36342C31352C3131365D2C5B36362C31352C3131375D2C5B36382C31352C';
wwv_flow_imp.g_varchar2_table(62) := '3131385D2C5B36392C31362C3131395D2C5B37312C31362C3132305D2C5B37332C31362C3132305D2C5B37342C31362C3132315D2C5B37362C31372C3132325D2C5B37382C31372C3132335D2C5B37392C31382C3132335D2C5B38312C31382C3132345D';
wwv_flow_imp.g_varchar2_table(63) := '2C5B38322C31392C3132345D2C5B38342C31392C3132355D2C5B38362C32302C3132355D2C5B38372C32312C3132365D2C5B38392C32312C3132365D2C5B39302C32322C3132365D2C5B39322C32322C3132375D2C5B39332C32332C3132375D2C5B3935';
wwv_flow_imp.g_varchar2_table(64) := '2C32342C3132375D2C5B39362C32342C3132385D2C5B39382C32352C3132385D2C5B3130302C32362C3132385D2C5B3130312C32362C3132385D2C5B3130332C32372C3132385D2C5B3130342C32382C3132395D2C5B3130362C32382C3132395D2C5B31';
wwv_flow_imp.g_varchar2_table(65) := '30372C32392C3132395D2C5B3130392C32392C3132395D2C5B3131302C33302C3132395D2C5B3131322C33312C3132395D2C5B3131342C33312C3132395D2C5B3131352C33322C3132395D2C5B3131372C33332C3132395D2C5B3131382C33332C313239';
wwv_flow_imp.g_varchar2_table(66) := '5D2C5B3132302C33342C3132395D2C5B3132312C33342C3133305D2C5B3132332C33352C3133305D2C5B3132342C33352C3133305D2C5B3132362C33362C3133305D2C5B3132382C33372C3133305D2C5B3132392C33372C3132395D2C5B3133312C3338';
wwv_flow_imp.g_varchar2_table(67) := '2C3132395D2C5B3133322C33382C3132395D2C5B3133342C33392C3132395D2C5B3133362C33392C3132395D2C5B3133372C34302C3132395D2C5B3133392C34312C3132395D2C5B3134302C34312C3132395D2C5B3134322C34322C3132395D2C5B3134';
wwv_flow_imp.g_varchar2_table(68) := '342C34322C3132395D2C5B3134352C34332C3132395D2C5B3134372C34332C3132385D2C5B3134382C34342C3132385D2C5B3135302C34342C3132385D2C5B3135322C34352C3132385D2C5B3135332C34352C3132385D2C5B3135352C34362C3132375D';
wwv_flow_imp.g_varchar2_table(69) := '2C5B3135362C34362C3132375D2C5B3135382C34372C3132375D2C5B3136302C34372C3132375D2C5B3136312C34382C3132365D2C5B3136332C34382C3132365D2C5B3136352C34392C3132365D2C5B3136362C34392C3132355D2C5B3136382C35302C';
wwv_flow_imp.g_varchar2_table(70) := '3132355D2C5B3137302C35312C3132355D2C5B3137312C35312C3132345D2C5B3137332C35322C3132345D2C5B3137342C35322C3132335D2C5B3137362C35332C3132335D2C5B3137382C35332C3132335D2C5B3137392C35342C3132325D2C5B313831';
wwv_flow_imp.g_varchar2_table(71) := '2C35342C3132325D2C5B3138332C35352C3132315D2C5B3138342C35352C3132315D2C5B3138362C35362C3132305D2C5B3138382C35372C3132305D2C5B3138392C35372C3131395D2C5B3139312C35382C3131395D2C5B3139322C35382C3131385D2C';
wwv_flow_imp.g_varchar2_table(72) := '5B3139342C35392C3131375D2C5B3139362C36302C3131375D2C5B3139372C36302C3131365D2C5B3139392C36312C3131355D2C5B3230302C36322C3131355D2C5B3230322C36322C3131345D2C5B3230342C36332C3131335D2C5B3230352C36342C31';
wwv_flow_imp.g_varchar2_table(73) := '31335D2C5B3230372C36342C3131325D2C5B3230382C36352C3131315D2C5B3231302C36362C3131315D2C5B3231312C36372C3131305D2C5B3231332C36382C3130395D2C5B3231342C36392C3130385D2C5B3231362C36392C3130385D2C5B3231372C';
wwv_flow_imp.g_varchar2_table(74) := '37302C3130375D2C5B3231392C37312C3130365D2C5B3232302C37322C3130355D2C5B3232322C37332C3130345D2C5B3232332C37342C3130345D2C5B3232342C37362C3130335D2C5B3232362C37372C3130325D2C5B3232372C37382C3130315D2C5B';
wwv_flow_imp.g_varchar2_table(75) := '3232382C37392C3130305D2C5B3232392C38302C3130305D2C5B3233312C38322C39395D2C5B3233322C38332C39385D2C5B3233332C38342C39385D2C5B3233342C38362C39375D2C5B3233352C38372C39365D2C5B3233362C38382C39365D2C5B3233';
wwv_flow_imp.g_varchar2_table(76) := '372C39302C39355D2C5B3233382C39312C39345D2C5B3233392C39332C39345D2C5B3234302C39352C39345D2C5B3234312C39362C39335D2C5B3234322C39382C39335D2C5B3234322C3130302C39325D2C5B3234332C3130312C39325D2C5B3234342C';
wwv_flow_imp.g_varchar2_table(77) := '3130332C39325D2C5B3234342C3130352C39325D2C5B3234352C3130372C39325D2C5B3234362C3130382C39325D2C5B3234362C3131302C39325D2C5B3234372C3131322C39325D2C5B3234372C3131342C39325D2C5B3234382C3131362C39325D2C5B';
wwv_flow_imp.g_varchar2_table(78) := '3234382C3131382C39325D2C5B3234392C3132302C39335D2C5B3234392C3132312C39335D2C5B3234392C3132332C39335D2C5B3235302C3132352C39345D2C5B3235302C3132372C39345D2C5B3235302C3132392C39355D2C5B3235312C3133312C39';
wwv_flow_imp.g_varchar2_table(79) := '355D2C5B3235312C3133332C39365D2C5B3235312C3133352C39375D2C5B3235322C3133372C39375D2C5B3235322C3133382C39385D2C5B3235322C3134302C39395D2C5B3235322C3134322C3130305D2C5B3235322C3134342C3130315D2C5B323533';
wwv_flow_imp.g_varchar2_table(80) := '2C3134362C3130325D2C5B3235332C3134382C3130335D2C5B3235332C3135302C3130345D2C5B3235332C3135322C3130355D2C5B3235332C3135342C3130365D2C5B3235332C3135352C3130375D2C5B3235342C3135372C3130385D2C5B3235342C31';
wwv_flow_imp.g_varchar2_table(81) := '35392C3130395D2C5B3235342C3136312C3131305D2C5B3235342C3136332C3131315D2C5B3235342C3136352C3131335D2C5B3235342C3136372C3131345D2C5B3235342C3136392C3131355D2C5B3235342C3137302C3131365D2C5B3235342C313732';
wwv_flow_imp.g_varchar2_table(82) := '2C3131385D2C5B3235342C3137342C3131395D2C5B3235342C3137362C3132305D2C5B3235342C3137382C3132325D2C5B3235342C3138302C3132335D2C5B3235342C3138322C3132345D2C5B3235342C3138332C3132365D2C5B3235342C3138352C31';
wwv_flow_imp.g_varchar2_table(83) := '32375D2C5B3235342C3138372C3132395D2C5B3235342C3138392C3133305D2C5B3235342C3139312C3133325D2C5B3235342C3139332C3133335D2C5B3235342C3139342C3133355D2C5B3235342C3139362C3133365D2C5B3235342C3139382C313338';
wwv_flow_imp.g_varchar2_table(84) := '5D2C5B3235342C3230302C3134305D2C5B3235342C3230322C3134315D2C5B3235342C3230342C3134335D2C5B3235342C3230352C3134345D2C5B3235342C3230372C3134365D2C5B3235342C3230392C3134385D2C5B3235342C3231312C3134395D2C';
wwv_flow_imp.g_varchar2_table(85) := '5B3235342C3231332C3135315D2C5B3235342C3231352C3135335D2C5B3235342C3231362C3135345D2C5B3235332C3231382C3135365D2C5B3235332C3232302C3135385D2C5B3235332C3232322C3136305D2C5B3235332C3232342C3136315D2C5B32';
wwv_flow_imp.g_varchar2_table(86) := '35332C3232362C3136335D2C5B3235332C3232372C3136355D2C5B3235332C3232392C3136375D2C5B3235332C3233312C3136395D2C5B3235332C3233332C3137305D2C5B3235332C3233352C3137325D2C5B3235322C3233362C3137345D2C5B323532';
wwv_flow_imp.g_varchar2_table(87) := '2C3233382C3137365D2C5B3235322C3234302C3137385D2C5B3235322C3234322C3138305D2C5B3235322C3234342C3138325D2C5B3235322C3234362C3138345D2C5B3235322C3234372C3138355D2C5B3235322C3234392C3138375D2C5B3235322C32';
wwv_flow_imp.g_varchar2_table(88) := '35312C3138395D2C5B3235322C3235332C3139315D5D2C696E6665726E6F3A5B5B302C302C345D2C5B312C302C355D2C5B312C312C365D2C5B312C312C385D2C5B322C312C31305D2C5B322C322C31325D2C5B322C322C31345D2C5B332C322C31365D2C';
wwv_flow_imp.g_varchar2_table(89) := '5B342C332C31385D2C5B342C332C32305D2C5B352C342C32335D2C5B362C342C32355D2C5B372C352C32375D2C5B382C352C32395D2C5B392C362C33315D2C5B31302C372C33345D2C5B31312C372C33365D2C5B31322C382C33385D2C5B31332C382C34';
wwv_flow_imp.g_varchar2_table(90) := '315D2C5B31342C392C34335D2C5B31362C392C34355D2C5B31372C31302C34385D2C5B31382C31302C35305D2C5B32302C31312C35325D2C5B32312C31312C35355D2C5B32322C31312C35375D2C5B32342C31322C36305D2C5B32352C31322C36325D2C';
wwv_flow_imp.g_varchar2_table(91) := '5B32372C31322C36355D2C5B32382C31322C36375D2C5B33302C31322C36395D2C5B33312C31322C37325D2C5B33332C31322C37345D2C5B33352C31322C37365D2C5B33362C31322C37395D2C5B33382C31322C38315D2C5B34302C31312C38335D2C5B';
wwv_flow_imp.g_varchar2_table(92) := '34312C31312C38355D2C5B34332C31312C38375D2C5B34352C31312C38395D2C5B34372C31302C39315D2C5B34392C31302C39325D2C5B35302C31302C39345D2C5B35322C31302C39355D2C5B35342C392C39375D2C5B35362C392C39385D2C5B35372C';
wwv_flow_imp.g_varchar2_table(93) := '392C39395D2C5B35392C392C3130305D2C5B36312C392C3130315D2C5B36322C392C3130325D2C5B36342C31302C3130335D2C5B36362C31302C3130345D2C5B36382C31302C3130345D2C5B36392C31302C3130355D2C5B37312C31312C3130365D2C5B';
wwv_flow_imp.g_varchar2_table(94) := '37332C31312C3130365D2C5B37342C31322C3130375D2C5B37362C31322C3130375D2C5B37372C31332C3130385D2C5B37392C31332C3130385D2C5B38312C31342C3130385D2C5B38322C31342C3130395D2C5B38342C31352C3130395D2C5B38352C31';
wwv_flow_imp.g_varchar2_table(95) := '352C3130395D2C5B38372C31362C3131305D2C5B38392C31362C3131305D2C5B39302C31372C3131305D2C5B39322C31382C3131305D2C5B39332C31382C3131305D2C5B39352C31392C3131305D2C5B39372C31392C3131305D2C5B39382C32302C3131';
wwv_flow_imp.g_varchar2_table(96) := '305D2C5B3130302C32312C3131305D2C5B3130312C32312C3131305D2C5B3130332C32322C3131305D2C5B3130352C32322C3131305D2C5B3130362C32332C3131305D2C5B3130382C32342C3131305D2C5B3130392C32342C3131305D2C5B3131312C32';
wwv_flow_imp.g_varchar2_table(97) := '352C3131305D2C5B3131332C32352C3131305D2C5B3131342C32362C3131305D2C5B3131362C32362C3131305D2C5B3131372C32372C3131305D2C5B3131392C32382C3130395D2C5B3132302C32382C3130395D2C5B3132322C32392C3130395D2C5B31';
wwv_flow_imp.g_varchar2_table(98) := '32342C32392C3130395D2C5B3132352C33302C3130395D2C5B3132372C33302C3130385D2C5B3132382C33312C3130385D2C5B3133302C33322C3130385D2C5B3133322C33322C3130375D2C5B3133332C33332C3130375D2C5B3133352C33332C313037';
wwv_flow_imp.g_varchar2_table(99) := '5D2C5B3133362C33342C3130365D2C5B3133382C33342C3130365D2C5B3134302C33352C3130355D2C5B3134312C33352C3130355D2C5B3134332C33362C3130355D2C5B3134342C33372C3130345D2C5B3134362C33372C3130345D2C5B3134372C3338';
wwv_flow_imp.g_varchar2_table(100) := '2C3130335D2C5B3134392C33382C3130335D2C5B3135312C33392C3130325D2C5B3135322C33392C3130325D2C5B3135342C34302C3130315D2C5B3135352C34312C3130305D2C5B3135372C34312C3130305D2C5B3135392C34322C39395D2C5B313630';
wwv_flow_imp.g_varchar2_table(101) := '2C34322C39395D2C5B3136322C34332C39385D2C5B3136332C34342C39375D2C5B3136352C34342C39365D2C5B3136362C34352C39365D2C5B3136382C34362C39355D2C5B3136392C34362C39345D2C5B3137312C34372C39345D2C5B3137332C34382C';
wwv_flow_imp.g_varchar2_table(102) := '39335D2C5B3137342C34382C39325D2C5B3137362C34392C39315D2C5B3137372C35302C39305D2C5B3137392C35302C39305D2C5B3138302C35312C38395D2C5B3138322C35322C38385D2C5B3138332C35332C38375D2C5B3138352C35332C38365D2C';
wwv_flow_imp.g_varchar2_table(103) := '5B3138362C35342C38355D2C5B3138382C35352C38345D2C5B3138392C35362C38335D2C5B3139312C35372C38325D2C5B3139322C35382C38315D2C5B3139332C35382C38305D2C5B3139352C35392C37395D2C5B3139362C36302C37385D2C5B313938';
wwv_flow_imp.g_varchar2_table(104) := '2C36312C37375D2C5B3139392C36322C37365D2C5B3230302C36332C37355D2C5B3230322C36342C37345D2C5B3230332C36352C37335D2C5B3230342C36362C37325D2C5B3230362C36372C37315D2C5B3230372C36382C37305D2C5B3230382C36392C';
wwv_flow_imp.g_varchar2_table(105) := '36395D2C5B3231302C37302C36385D2C5B3231312C37312C36375D2C5B3231322C37322C36365D2C5B3231332C37342C36355D2C5B3231352C37352C36335D2C5B3231362C37362C36325D2C5B3231372C37372C36315D2C5B3231382C37382C36305D2C';
wwv_flow_imp.g_varchar2_table(106) := '5B3231392C38302C35395D2C5B3232312C38312C35385D2C5B3232322C38322C35365D2C5B3232332C38332C35355D2C5B3232342C38352C35345D2C5B3232352C38362C35335D2C5B3232362C38372C35325D2C5B3232372C38392C35315D2C5B323238';
wwv_flow_imp.g_varchar2_table(107) := '2C39302C34395D2C5B3232392C39322C34385D2C5B3233302C39332C34375D2C5B3233312C39342C34365D2C5B3233322C39362C34355D2C5B3233332C39372C34335D2C5B3233342C39392C34325D2C5B3233352C3130302C34315D2C5B3233352C3130';
wwv_flow_imp.g_varchar2_table(108) := '322C34305D2C5B3233362C3130332C33385D2C5B3233372C3130352C33375D2C5B3233382C3130362C33365D2C5B3233392C3130382C33355D2C5B3233392C3131302C33335D2C5B3234302C3131312C33325D2C5B3234312C3131332C33315D2C5B3234';
wwv_flow_imp.g_varchar2_table(109) := '312C3131352C32395D2C5B3234322C3131362C32385D2C5B3234332C3131382C32375D2C5B3234332C3132302C32355D2C5B3234342C3132312C32345D2C5B3234352C3132332C32335D2C5B3234352C3132352C32315D2C5B3234362C3132362C32305D';
wwv_flow_imp.g_varchar2_table(110) := '2C5B3234362C3132382C31395D2C5B3234372C3133302C31385D2C5B3234372C3133322C31365D2C5B3234382C3133332C31355D2C5B3234382C3133352C31345D2C5B3234382C3133372C31325D2C5B3234392C3133392C31315D2C5B3234392C313430';
wwv_flow_imp.g_varchar2_table(111) := '2C31305D2C5B3234392C3134322C395D2C5B3235302C3134342C385D2C5B3235302C3134362C375D2C5B3235302C3134382C375D2C5B3235312C3135302C365D2C5B3235312C3135312C365D2C5B3235312C3135332C365D2C5B3235312C3135352C365D';
wwv_flow_imp.g_varchar2_table(112) := '2C5B3235312C3135372C375D2C5B3235322C3135392C375D2C5B3235322C3136312C385D2C5B3235322C3136332C395D2C5B3235322C3136352C31305D2C5B3235322C3136362C31325D2C5B3235322C3136382C31335D2C5B3235322C3137302C31355D';
wwv_flow_imp.g_varchar2_table(113) := '2C5B3235322C3137322C31375D2C5B3235322C3137342C31385D2C5B3235322C3137362C32305D2C5B3235322C3137382C32325D2C5B3235322C3138302C32345D2C5B3235312C3138322C32365D2C5B3235312C3138342C32395D2C5B3235312C313836';
wwv_flow_imp.g_varchar2_table(114) := '2C33315D2C5B3235312C3138382C33335D2C5B3235312C3139302C33355D2C5B3235302C3139322C33385D2C5B3235302C3139342C34305D2C5B3235302C3139362C34325D2C5B3235302C3139382C34355D2C5B3234392C3139392C34375D2C5B323439';
wwv_flow_imp.g_varchar2_table(115) := '2C3230312C35305D2C5B3234392C3230332C35335D2C5B3234382C3230352C35355D2C5B3234382C3230372C35385D2C5B3234372C3230392C36315D2C5B3234372C3231312C36345D2C5B3234362C3231332C36375D2C5B3234362C3231352C37305D2C';
wwv_flow_imp.g_varchar2_table(116) := '5B3234352C3231372C37335D2C5B3234352C3231392C37365D2C5B3234342C3232312C37395D2C5B3234342C3232332C38335D2C5B3234342C3232352C38365D2C5B3234332C3232372C39305D2C5B3234332C3232392C39335D2C5B3234322C3233302C';
wwv_flow_imp.g_varchar2_table(117) := '39375D2C5B3234322C3233322C3130315D2C5B3234322C3233342C3130355D2C5B3234312C3233362C3130395D2C5B3234312C3233372C3131335D2C5B3234312C3233392C3131375D2C5B3234312C3234312C3132315D2C5B3234322C3234322C313235';
wwv_flow_imp.g_varchar2_table(118) := '5D2C5B3234322C3234342C3133305D2C5B3234332C3234352C3133345D2C5B3234332C3234362C3133385D2C5B3234342C3234382C3134325D2C5B3234352C3234392C3134365D2C5B3234362C3235302C3135305D2C5B3234382C3235312C3135345D2C';
wwv_flow_imp.g_varchar2_table(119) := '5B3234392C3235322C3135375D2C5B3235302C3235332C3136315D2C5B3235322C3235352C3136345D5D2C706C61736D613A5B5B31332C382C3133355D2C5B31362C372C3133365D2C5B31392C372C3133375D2C5B32322C372C3133385D2C5B32352C36';
wwv_flow_imp.g_varchar2_table(120) := '2C3134305D2C5B32372C362C3134315D2C5B32392C362C3134325D2C5B33322C362C3134335D2C5B33342C362C3134345D2C5B33362C362C3134355D2C5B33382C352C3134355D2C5B34302C352C3134365D2C5B34322C352C3134375D2C5B34342C352C';
wwv_flow_imp.g_varchar2_table(121) := '3134385D2C5B34362C352C3134395D2C5B34372C352C3135305D2C5B34392C352C3135315D2C5B35312C352C3135315D2C5B35332C342C3135325D2C5B35352C342C3135335D2C5B35362C342C3135345D2C5B35382C342C3135345D2C5B36302C342C31';
wwv_flow_imp.g_varchar2_table(122) := '35355D2C5B36322C342C3135365D2C5B36332C342C3135365D2C5B36352C342C3135375D2C5B36372C332C3135385D2C5B36382C332C3135385D2C5B37302C332C3135395D2C5B37322C332C3135395D2C5B37332C332C3136305D2C5B37352C332C3136';
wwv_flow_imp.g_varchar2_table(123) := '315D2C5B37362C322C3136315D2C5B37382C322C3136325D2C5B38302C322C3136325D2C5B38312C322C3136335D2C5B38332C322C3136335D2C5B38352C322C3136345D2C5B38362C312C3136345D2C5B38382C312C3136345D2C5B38392C312C313635';
wwv_flow_imp.g_varchar2_table(124) := '5D2C5B39312C312C3136355D2C5B39322C312C3136365D2C5B39342C312C3136365D2C5B39362C312C3136365D2C5B39372C302C3136375D2C5B39392C302C3136375D2C5B3130302C302C3136375D2C5B3130322C302C3136375D2C5B3130332C302C31';
wwv_flow_imp.g_varchar2_table(125) := '36385D2C5B3130352C302C3136385D2C5B3130362C302C3136385D2C5B3130382C302C3136385D2C5B3131302C302C3136385D2C5B3131312C302C3136385D2C5B3131332C302C3136385D2C5B3131342C312C3136385D2C5B3131362C312C3136385D2C';
wwv_flow_imp.g_varchar2_table(126) := '5B3131372C312C3136385D2C5B3131392C312C3136385D2C5B3132302C312C3136385D2C5B3132322C322C3136385D2C5B3132332C322C3136385D2C5B3132352C332C3136385D2C5B3132362C332C3136385D2C5B3132382C342C3136385D2C5B313239';
wwv_flow_imp.g_varchar2_table(127) := '2C342C3136375D2C5B3133312C352C3136375D2C5B3133322C352C3136375D2C5B3133342C362C3136365D2C5B3133352C372C3136365D2C5B3133362C382C3136365D2C5B3133382C392C3136355D2C5B3133392C31302C3136355D2C5B3134312C3131';
wwv_flow_imp.g_varchar2_table(128) := '2C3136355D2C5B3134322C31322C3136345D2C5B3134332C31332C3136345D2C5B3134352C31342C3136335D2C5B3134362C31352C3136335D2C5B3134382C31362C3136325D2C5B3134392C31372C3136315D2C5B3135302C31392C3136315D2C5B3135';
wwv_flow_imp.g_varchar2_table(129) := '322C32302C3136305D2C5B3135332C32312C3135395D2C5B3135342C32322C3135395D2C5B3135362C32332C3135385D2C5B3135372C32342C3135375D2C5B3135382C32352C3135375D2C5B3136302C32362C3135365D2C5B3136312C32372C3135355D';
wwv_flow_imp.g_varchar2_table(130) := '2C5B3136322C32392C3135345D2C5B3136332C33302C3135345D2C5B3136352C33312C3135335D2C5B3136362C33322C3135325D2C5B3136372C33332C3135315D2C5B3136382C33342C3135305D2C5B3137302C33352C3134395D2C5B3137312C33362C';
wwv_flow_imp.g_varchar2_table(131) := '3134385D2C5B3137322C33382C3134385D2C5B3137332C33392C3134375D2C5B3137342C34302C3134365D2C5B3137362C34312C3134355D2C5B3137372C34322C3134345D2C5B3137382C34332C3134335D2C5B3137392C34342C3134325D2C5B313830';
wwv_flow_imp.g_varchar2_table(132) := '2C34362C3134315D2C5B3138312C34372C3134305D2C5B3138322C34382C3133395D2C5B3138332C34392C3133385D2C5B3138342C35302C3133375D2C5B3138362C35312C3133365D2C5B3138372C35322C3133365D2C5B3138382C35332C3133355D2C';
wwv_flow_imp.g_varchar2_table(133) := '5B3138392C35352C3133345D2C5B3139302C35362C3133335D2C5B3139312C35372C3133325D2C5B3139322C35382C3133315D2C5B3139332C35392C3133305D2C5B3139342C36302C3132395D2C5B3139352C36312C3132385D2C5B3139362C36322C31';
wwv_flow_imp.g_varchar2_table(134) := '32375D2C5B3139372C36342C3132365D2C5B3139382C36352C3132355D2C5B3139392C36362C3132345D2C5B3230302C36372C3132335D2C5B3230312C36382C3132325D2C5B3230322C36392C3132325D2C5B3230332C37302C3132315D2C5B3230342C';
wwv_flow_imp.g_varchar2_table(135) := '37312C3132305D2C5B3230342C37332C3131395D2C5B3230352C37342C3131385D2C5B3230362C37352C3131375D2C5B3230372C37362C3131365D2C5B3230382C37372C3131355D2C5B3230392C37382C3131345D2C5B3231302C37392C3131335D2C5B';
wwv_flow_imp.g_varchar2_table(136) := '3231312C38312C3131335D2C5B3231322C38322C3131325D2C5B3231332C38332C3131315D2C5B3231332C38342C3131305D2C5B3231342C38352C3130395D2C5B3231352C38362C3130385D2C5B3231362C38372C3130375D2C5B3231372C38382C3130';
wwv_flow_imp.g_varchar2_table(137) := '365D2C5B3231382C39302C3130365D2C5B3231382C39312C3130355D2C5B3231392C39322C3130345D2C5B3232302C39332C3130335D2C5B3232312C39342C3130325D2C5B3232322C39352C3130315D2C5B3232322C39372C3130305D2C5B3232332C39';
wwv_flow_imp.g_varchar2_table(138) := '382C39395D2C5B3232342C39392C39395D2C5B3232352C3130302C39385D2C5B3232362C3130312C39375D2C5B3232362C3130322C39365D2C5B3232372C3130342C39355D2C5B3232382C3130352C39345D2C5B3232392C3130362C39335D2C5B323239';
wwv_flow_imp.g_varchar2_table(139) := '2C3130372C39335D2C5B3233302C3130382C39325D2C5B3233312C3131302C39315D2C5B3233312C3131312C39305D2C5B3233322C3131322C38395D2C5B3233332C3131332C38385D2C5B3233332C3131342C38375D2C5B3233342C3131362C38375D2C';
wwv_flow_imp.g_varchar2_table(140) := '5B3233352C3131372C38365D2C5B3233352C3131382C38355D2C5B3233362C3131392C38345D2C5B3233372C3132312C38335D2C5B3233372C3132322C38325D2C5B3233382C3132332C38315D2C5B3233392C3132342C38315D2C5B3233392C3132362C';
wwv_flow_imp.g_varchar2_table(141) := '38305D2C5B3234302C3132372C37395D2C5B3234302C3132382C37385D2C5B3234312C3132392C37375D2C5B3234312C3133312C37365D2C5B3234322C3133322C37355D2C5B3234332C3133332C37355D2C5B3234332C3133352C37345D2C5B3234342C';
wwv_flow_imp.g_varchar2_table(142) := '3133362C37335D2C5B3234342C3133372C37325D2C5B3234352C3133392C37315D2C5B3234352C3134302C37305D2C5B3234362C3134312C36395D2C5B3234362C3134332C36385D2C5B3234372C3134342C36385D2C5B3234372C3134352C36375D2C5B';
wwv_flow_imp.g_varchar2_table(143) := '3234372C3134372C36365D2C5B3234382C3134382C36355D2C5B3234382C3134392C36345D2C5B3234392C3135312C36335D2C5B3234392C3135322C36325D2C5B3234392C3135342C36325D2C5B3235302C3135352C36315D2C5B3235302C3135362C36';
wwv_flow_imp.g_varchar2_table(144) := '305D2C5B3235302C3135382C35395D2C5B3235312C3135392C35385D2C5B3235312C3136312C35375D2C5B3235312C3136322C35365D2C5B3235322C3136332C35365D2C5B3235322C3136352C35355D2C5B3235322C3136362C35345D2C5B3235322C31';
wwv_flow_imp.g_varchar2_table(145) := '36382C35335D2C5B3235322C3136392C35325D2C5B3235332C3137312C35315D2C5B3235332C3137322C35315D2C5B3235332C3137342C35305D2C5B3235332C3137352C34395D2C5B3235332C3137372C34385D2C5B3235332C3137382C34375D2C5B32';
wwv_flow_imp.g_varchar2_table(146) := '35332C3138302C34375D2C5B3235332C3138312C34365D2C5B3235342C3138332C34355D2C5B3235342C3138342C34345D2C5B3235342C3138362C34345D2C5B3235342C3138372C34335D2C5B3235342C3138392C34325D2C5B3235342C3139302C3432';
wwv_flow_imp.g_varchar2_table(147) := '5D2C5B3235342C3139322C34315D2C5B3235332C3139342C34315D2C5B3235332C3139352C34305D2C5B3235332C3139372C33395D2C5B3235332C3139382C33395D2C5B3235332C3230302C33395D2C5B3235332C3230322C33385D2C5B3235332C3230';
wwv_flow_imp.g_varchar2_table(148) := '332C33385D2C5B3235322C3230352C33375D2C5B3235322C3230362C33375D2C5B3235322C3230382C33375D2C5B3235322C3231302C33375D2C5B3235312C3231312C33365D2C5B3235312C3231332C33365D2C5B3235312C3231352C33365D2C5B3235';
wwv_flow_imp.g_varchar2_table(149) := '302C3231362C33365D2C5B3235302C3231382C33365D2C5B3234392C3232302C33365D2C5B3234392C3232312C33375D2C5B3234382C3232332C33375D2C5B3234382C3232352C33375D2C5B3234372C3232362C33375D2C5B3234372C3232382C33375D';
wwv_flow_imp.g_varchar2_table(150) := '2C5B3234362C3233302C33385D2C5B3234362C3233322C33385D2C5B3234352C3233332C33385D2C5B3234352C3233352C33395D2C5B3234342C3233372C33395D2C5B3234332C3233382C33395D2C5B3234332C3234302C33395D2C5B3234322C323432';
wwv_flow_imp.g_varchar2_table(151) := '2C33395D2C5B3234312C3234342C33385D2C5B3234312C3234352C33375D2C5B3234302C3234372C33365D2C5B3234302C3234392C33335D5D2C766972696469733A5B5B36382C312C38345D2C5B36382C322C38365D2C5B36392C342C38375D2C5B3639';
wwv_flow_imp.g_varchar2_table(152) := '2C352C38395D2C5B37302C372C39305D2C5B37302C382C39325D2C5B37302C31302C39335D2C5B37302C31312C39345D2C5B37312C31332C39365D2C5B37312C31342C39375D2C5B37312C31362C39395D2C5B37312C31372C3130305D2C5B37312C3139';
wwv_flow_imp.g_varchar2_table(153) := '2C3130315D2C5B37322C32302C3130335D2C5B37322C32322C3130345D2C5B37322C32332C3130355D2C5B37322C32342C3130365D2C5B37322C32362C3130385D2C5B37322C32372C3130395D2C5B37322C32382C3131305D2C5B37322C32392C313131';
wwv_flow_imp.g_varchar2_table(154) := '5D2C5B37322C33312C3131325D2C5B37322C33322C3131335D2C5B37322C33332C3131355D2C5B37322C33352C3131365D2C5B37322C33362C3131375D2C5B37322C33372C3131385D2C5B37322C33382C3131395D2C5B37322C34302C3132305D2C5B37';
wwv_flow_imp.g_varchar2_table(155) := '322C34312C3132315D2C5B37312C34322C3132325D2C5B37312C34342C3132325D2C5B37312C34352C3132335D2C5B37312C34362C3132345D2C5B37312C34372C3132355D2C5B37302C34382C3132365D2C5B37302C35302C3132365D2C5B37302C3531';
wwv_flow_imp.g_varchar2_table(156) := '2C3132375D2C5B37302C35322C3132385D2C5B36392C35332C3132395D2C5B36392C35352C3132395D2C5B36392C35362C3133305D2C5B36382C35372C3133315D2C5B36382C35382C3133315D2C5B36382C35392C3133325D2C5B36372C36312C313332';
wwv_flow_imp.g_varchar2_table(157) := '5D2C5B36372C36322C3133335D2C5B36362C36332C3133335D2C5B36362C36342C3133345D2C5B36362C36352C3133345D2C5B36352C36362C3133355D2C5B36352C36382C3133355D2C5B36342C36392C3133365D2C5B36342C37302C3133365D2C5B36';
wwv_flow_imp.g_varchar2_table(158) := '332C37312C3133365D2C5B36332C37322C3133375D2C5B36322C37332C3133375D2C5B36322C37342C3133375D2C5B36322C37362C3133385D2C5B36312C37372C3133385D2C5B36312C37382C3133385D2C5B36302C37392C3133385D2C5B36302C3830';
wwv_flow_imp.g_varchar2_table(159) := '2C3133395D2C5B35392C38312C3133395D2C5B35392C38322C3133395D2C5B35382C38332C3133395D2C5B35382C38342C3134305D2C5B35372C38352C3134305D2C5B35372C38362C3134305D2C5B35362C38382C3134305D2C5B35362C38392C313430';
wwv_flow_imp.g_varchar2_table(160) := '5D2C5B35352C39302C3134305D2C5B35352C39312C3134315D2C5B35342C39322C3134315D2C5B35342C39332C3134315D2C5B35332C39342C3134315D2C5B35332C39352C3134315D2C5B35322C39362C3134315D2C5B35322C39372C3134315D2C5B35';
wwv_flow_imp.g_varchar2_table(161) := '312C39382C3134315D2C5B35312C39392C3134315D2C5B35302C3130302C3134325D2C5B35302C3130312C3134325D2C5B34392C3130322C3134325D2C5B34392C3130332C3134325D2C5B34392C3130342C3134325D2C5B34382C3130352C3134325D2C';
wwv_flow_imp.g_varchar2_table(162) := '5B34382C3130362C3134325D2C5B34372C3130372C3134325D2C5B34372C3130382C3134325D2C5B34362C3130392C3134325D2C5B34362C3131302C3134325D2C5B34362C3131312C3134325D2C5B34352C3131322C3134325D2C5B34352C3131332C31';
wwv_flow_imp.g_varchar2_table(163) := '34325D2C5B34342C3131332C3134325D2C5B34342C3131342C3134325D2C5B34342C3131352C3134325D2C5B34332C3131362C3134325D2C5B34332C3131372C3134325D2C5B34322C3131382C3134325D2C5B34322C3131392C3134325D2C5B34322C31';
wwv_flow_imp.g_varchar2_table(164) := '32302C3134325D2C5B34312C3132312C3134325D2C5B34312C3132322C3134325D2C5B34312C3132332C3134325D2C5B34302C3132342C3134325D2C5B34302C3132352C3134325D2C5B33392C3132362C3134325D2C5B33392C3132372C3134325D2C5B';
wwv_flow_imp.g_varchar2_table(165) := '33392C3132382C3134325D2C5B33382C3132392C3134325D2C5B33382C3133302C3134325D2C5B33382C3133302C3134325D2C5B33372C3133312C3134325D2C5B33372C3133322C3134325D2C5B33372C3133332C3134325D2C5B33362C3133342C3134';
wwv_flow_imp.g_varchar2_table(166) := '325D2C5B33362C3133352C3134325D2C5B33352C3133362C3134325D2C5B33352C3133372C3134325D2C5B33352C3133382C3134315D2C5B33342C3133392C3134315D2C5B33342C3134302C3134315D2C5B33342C3134312C3134315D2C5B33332C3134';
wwv_flow_imp.g_varchar2_table(167) := '322C3134315D2C5B33332C3134332C3134315D2C5B33332C3134342C3134315D2C5B33332C3134352C3134305D2C5B33322C3134362C3134305D2C5B33322C3134362C3134305D2C5B33322C3134372C3134305D2C5B33312C3134382C3134305D2C5B33';
wwv_flow_imp.g_varchar2_table(168) := '312C3134392C3133395D2C5B33312C3135302C3133395D2C5B33312C3135312C3133395D2C5B33312C3135322C3133395D2C5B33312C3135332C3133385D2C5B33312C3135342C3133385D2C5B33302C3135352C3133385D2C5B33302C3135362C313337';
wwv_flow_imp.g_varchar2_table(169) := '5D2C5B33302C3135372C3133375D2C5B33312C3135382C3133375D2C5B33312C3135392C3133365D2C5B33312C3136302C3133365D2C5B33312C3136312C3133365D2C5B33312C3136312C3133355D2C5B33312C3136322C3133355D2C5B33322C313633';
wwv_flow_imp.g_varchar2_table(170) := '2C3133345D2C5B33322C3136342C3133345D2C5B33332C3136352C3133335D2C5B33332C3136362C3133335D2C5B33342C3136372C3133335D2C5B33342C3136382C3133325D2C5B33352C3136392C3133315D2C5B33362C3137302C3133315D2C5B3337';
wwv_flow_imp.g_varchar2_table(171) := '2C3137312C3133305D2C5B33372C3137322C3133305D2C5B33382C3137332C3132395D2C5B33392C3137332C3132395D2C5B34302C3137342C3132385D2C5B34312C3137352C3132375D2C5B34322C3137362C3132375D2C5B34342C3137372C3132365D';
wwv_flow_imp.g_varchar2_table(172) := '2C5B34352C3137382C3132355D2C5B34362C3137392C3132345D2C5B34372C3138302C3132345D2C5B34392C3138312C3132335D2C5B35302C3138322C3132325D2C5B35322C3138322C3132315D2C5B35332C3138332C3132315D2C5B35352C3138342C';
wwv_flow_imp.g_varchar2_table(173) := '3132305D2C5B35362C3138352C3131395D2C5B35382C3138362C3131385D2C5B35392C3138372C3131375D2C5B36312C3138382C3131365D2C5B36332C3138382C3131355D2C5B36342C3138392C3131345D2C5B36362C3139302C3131335D2C5B36382C';
wwv_flow_imp.g_varchar2_table(174) := '3139312C3131325D2C5B37302C3139322C3131315D2C5B37322C3139332C3131305D2C5B37342C3139332C3130395D2C5B37362C3139342C3130385D2C5B37382C3139352C3130375D2C5B38302C3139362C3130365D2C5B38322C3139372C3130355D2C';
wwv_flow_imp.g_varchar2_table(175) := '5B38342C3139372C3130345D2C5B38362C3139382C3130335D2C5B38382C3139392C3130315D2C5B39302C3230302C3130305D2C5B39322C3230302C39395D2C5B39342C3230312C39385D2C5B39362C3230322C39365D2C5B39392C3230332C39355D2C';
wwv_flow_imp.g_varchar2_table(176) := '5B3130312C3230332C39345D2C5B3130332C3230342C39325D2C5B3130352C3230352C39315D2C5B3130382C3230352C39305D2C5B3131302C3230362C38385D2C5B3131322C3230372C38375D2C5B3131352C3230382C38365D2C5B3131372C3230382C';
wwv_flow_imp.g_varchar2_table(177) := '38345D2C5B3131392C3230392C38335D2C5B3132322C3230392C38315D2C5B3132342C3231302C38305D2C5B3132372C3231312C37385D2C5B3132392C3231312C37375D2C5B3133322C3231322C37355D2C5B3133342C3231332C37335D2C5B3133372C';
wwv_flow_imp.g_varchar2_table(178) := '3231332C37325D2C5B3133392C3231342C37305D2C5B3134322C3231342C36395D2C5B3134342C3231352C36375D2C5B3134372C3231352C36355D2C5B3134392C3231362C36345D2C5B3135322C3231362C36325D2C5B3135352C3231372C36305D2C5B';
wwv_flow_imp.g_varchar2_table(179) := '3135372C3231372C35395D2C5B3136302C3231382C35375D2C5B3136322C3231382C35355D2C5B3136352C3231392C35345D2C5B3136382C3231392C35325D2C5B3137302C3232302C35305D2C5B3137332C3232302C34385D2C5B3137362C3232312C34';
wwv_flow_imp.g_varchar2_table(180) := '375D2C5B3137382C3232312C34355D2C5B3138312C3232322C34335D2C5B3138342C3232322C34315D2C5B3138362C3232322C34305D2C5B3138392C3232332C33385D2C5B3139322C3232332C33375D2C5B3139342C3232332C33355D2C5B3139372C32';
wwv_flow_imp.g_varchar2_table(181) := '32342C33335D2C5B3230302C3232342C33325D2C5B3230322C3232352C33315D2C5B3230352C3232352C32395D2C5B3230382C3232352C32385D2C5B3231302C3232362C32375D2C5B3231332C3232362C32365D2C5B3231362C3232362C32355D2C5B32';
wwv_flow_imp.g_varchar2_table(182) := '31382C3232372C32355D2C5B3232312C3232372C32345D2C5B3232332C3232372C32345D2C5B3232362C3232382C32345D2C5B3232392C3232382C32355D2C5B3233312C3232382C32355D2C5B3233342C3232392C32365D2C5B3233362C3232392C3237';
wwv_flow_imp.g_varchar2_table(183) := '5D2C5B3233392C3232392C32385D2C5B3234312C3232392C32395D2C5B3234342C3233302C33305D2C5B3234362C3233302C33325D2C5B3234382C3233302C33335D2C5B3235312C3233312C33355D2C5B3235332C3233312C33375D5D2C636976696469';
wwv_flow_imp.g_varchar2_table(184) := '733A5B5B302C33322C37375D2C5B302C33332C37385D2C5B302C33342C38305D2C5B302C33342C38325D2C5B302C33352C38335D2C5B302C33362C38355D2C5B302C33372C38375D2C5B302C33372C38385D2C5B302C33382C39305D2C5B302C33392C39';
wwv_flow_imp.g_varchar2_table(185) := '325D2C5B302C33392C39345D2C5B302C34302C39365D2C5B302C34312C39375D2C5B302C34322C39395D2C5B302C34322C3130315D2C5B302C34332C3130335D2C5B302C34342C3130355D2C5B302C34342C3130365D2C5B302C34352C3130385D2C5B30';
wwv_flow_imp.g_varchar2_table(186) := '2C34362C3131305D2C5B302C34362C3131315D2C5B302C34372C3131315D2C5B302C34372C3131315D2C5B302C34382C3131315D2C5B302C34382C3131315D2C5B302C34392C3131315D2C5B302C35302C3131315D2C5B302C35312C3131315D2C5B302C';
wwv_flow_imp.g_varchar2_table(187) := '35312C3131315D2C5B302C35322C3131315D2C5B302C35332C3131305D2C5B312C35342C3131305D2C5B362C35342C3131305D2C5B31312C35352C3131305D2C5B31352C35362C3131305D2C5B31382C35362C3130395D2C5B32312C35372C3130395D2C';
wwv_flow_imp.g_varchar2_table(188) := '5B32342C35382C3130395D2C5B32362C35392C3130395D2C5B32392C35392C3130395D2C5B33312C36302C3130395D2C5B33332C36312C3130395D2C5B33352C36322C3130385D2C5B33362C36322C3130385D2C5B33382C36332C3130385D2C5B34302C';
wwv_flow_imp.g_varchar2_table(189) := '36342C3130385D2C5B34322C36342C3130385D2C5B34332C36352C3130385D2C5B34352C36362C3130385D2C5B34362C36372C3130385D2C5B34382C36372C3130385D2C5B34392C36382C3130375D2C5B35302C36392C3130375D2C5B35322C36392C31';
wwv_flow_imp.g_varchar2_table(190) := '30375D2C5B35332C37302C3130375D2C5B35342C37312C3130375D2C5B35362C37322C3130375D2C5B35372C37322C3130375D2C5B35382C37332C3130375D2C5B35392C37342C3130375D2C5B36312C37342C3130375D2C5B36322C37352C3130375D2C';
wwv_flow_imp.g_varchar2_table(191) := '5B36332C37362C3130375D2C5B36342C37372C3130375D2C5B36352C37372C3130375D2C5B36362C37382C3130375D2C5B36372C37392C3130375D2C5B36382C37392C3130375D2C5B37302C38302C3130375D2C5B37312C38312C3130375D2C5B37322C';
wwv_flow_imp.g_varchar2_table(192) := '38322C3130375D2C5B37332C38322C3130375D2C5B37342C38332C3130375D2C5B37352C38342C3130385D2C5B37362C38342C3130385D2C5B37372C38352C3130385D2C5B37382C38362C3130385D2C5B37392C38372C3130385D2C5B38302C38372C31';
wwv_flow_imp.g_varchar2_table(193) := '30385D2C5B38312C38382C3130385D2C5B38322C38392C3130385D2C5B38332C38392C3130385D2C5B38342C39302C3130385D2C5B38352C39312C3130395D2C5B38362C39322C3130395D2C5B38372C39322C3130395D2C5B38382C39332C3130395D2C';
wwv_flow_imp.g_varchar2_table(194) := '5B38392C39342C3130395D2C5B38392C39352C3130395D2C5B39302C39352C3130395D2C5B39312C39362C3131305D2C5B39322C39372C3131305D2C5B39332C39372C3131305D2C5B39342C39382C3131305D2C5B39352C39392C3131305D2C5B39362C';
wwv_flow_imp.g_varchar2_table(195) := '3130302C3131315D2C5B39372C3130302C3131315D2C5B39382C3130312C3131315D2C5B39392C3130322C3131315D2C5B3130302C3130322C3131315D2C5B3130302C3130332C3131325D2C5B3130312C3130342C3131325D2C5B3130322C3130352C31';
wwv_flow_imp.g_varchar2_table(196) := '31325D2C5B3130332C3130352C3131325D2C5B3130342C3130362C3131335D2C5B3130352C3130372C3131335D2C5B3130362C3130382C3131335D2C5B3130372C3130382C3131335D2C5B3130382C3130392C3131345D2C5B3130382C3131302C313134';
wwv_flow_imp.g_varchar2_table(197) := '5D2C5B3130392C3131302C3131345D2C5B3131302C3131312C3131355D2C5B3131312C3131322C3131355D2C5B3131322C3131332C3131355D2C5B3131332C3131332C3131365D2C5B3131342C3131342C3131365D2C5B3131342C3131352C3131365D2C';
wwv_flow_imp.g_varchar2_table(198) := '5B3131352C3131362C3131375D2C5B3131362C3131362C3131375D2C5B3131372C3131372C3131375D2C5B3131382C3131382C3131385D2C5B3131392C3131392C3131385D2C5B3132302C3131392C3131395D2C5B3132302C3132302C3131395D2C5B31';
wwv_flow_imp.g_varchar2_table(199) := '32312C3132312C3131395D2C5B3132322C3132322C3132305D2C5B3132332C3132322C3132305D2C5B3132342C3132332C3132305D2C5B3132352C3132342C3132305D2C5B3132362C3132352C3132305D2C5B3132372C3132352C3132305D2C5B313238';
wwv_flow_imp.g_varchar2_table(200) := '2C3132362C3132315D2C5B3132392C3132372C3132315D2C5B3133302C3132382C3132315D2C5B3133312C3132382C3132315D2C5B3133322C3132392C3132315D2C5B3133322C3133302C3132315D2C5B3133332C3133312C3132315D2C5B3133342C31';
wwv_flow_imp.g_varchar2_table(201) := '33312C3132315D2C5B3133352C3133322C3132315D2C5B3133362C3133332C3132315D2C5B3133372C3133342C3132315D2C5B3133382C3133352C3132315D2C5B3133392C3133352C3132315D2C5B3134302C3133362C3132315D2C5B3134312C313337';
wwv_flow_imp.g_varchar2_table(202) := '2C3132315D2C5B3134322C3133382C3132315D2C5B3134332C3133382C3132315D2C5B3134342C3133392C3132315D2C5B3134352C3134302C3132305D2C5B3134362C3134312C3132305D2C5B3134372C3134322C3132305D2C5B3134382C3134322C31';
wwv_flow_imp.g_varchar2_table(203) := '32305D2C5B3134392C3134332C3132305D2C5B3135302C3134342C3132305D2C5B3135312C3134352C3132305D2C5B3135322C3134362C3132305D2C5B3135332C3134362C3132305D2C5B3135342C3134372C3131395D2C5B3135352C3134382C313139';
wwv_flow_imp.g_varchar2_table(204) := '5D2C5B3135362C3134392C3131395D2C5B3135372C3135302C3131395D2C5B3135382C3135302C3131395D2C5B3135392C3135312C3131395D2C5B3136302C3135322C3131395D2C5B3136312C3135332C3131385D2C5B3136322C3135342C3131385D2C';
wwv_flow_imp.g_varchar2_table(205) := '5B3136332C3135342C3131385D2C5B3136342C3135352C3131385D2C5B3136352C3135362C3131385D2C5B3136362C3135372C3131375D2C5B3136382C3135382C3131375D2C5B3136392C3135392C3131375D2C5B3137302C3135392C3131375D2C5B31';
wwv_flow_imp.g_varchar2_table(206) := '37312C3136302C3131365D2C5B3137322C3136312C3131365D2C5B3137332C3136322C3131365D2C5B3137342C3136332C3131365D2C5B3137352C3136342C3131355D2C5B3137362C3136342C3131355D2C5B3137372C3136352C3131355D2C5B313738';
wwv_flow_imp.g_varchar2_table(207) := '2C3136362C3131345D2C5B3137392C3136372C3131345D2C5B3138302C3136382C3131345D2C5B3138312C3136392C3131335D2C5B3138322C3136392C3131335D2C5B3138332C3137302C3131335D2C5B3138342C3137312C3131325D2C5B3138352C31';
wwv_flow_imp.g_varchar2_table(208) := '37322C3131325D2C5B3138362C3137332C3131325D2C5B3138372C3137342C3131315D2C5B3138382C3137352C3131315D2C5B3139302C3137352C3131315D2C5B3139312C3137362C3131305D2C5B3139322C3137372C3131305D2C5B3139332C313738';
wwv_flow_imp.g_varchar2_table(209) := '2C3130395D2C5B3139342C3137392C3130395D2C5B3139352C3138302C3130395D2C5B3139362C3138312C3130385D2C5B3139372C3138312C3130385D2C5B3139382C3138322C3130375D2C5B3139392C3138332C3130375D2C5B3230302C3138342C31';
wwv_flow_imp.g_varchar2_table(210) := '30365D2C5B3230312C3138352C3130365D2C5B3230332C3138362C3130355D2C5B3230342C3138372C3130355D2C5B3230352C3138382C3130345D2C5B3230362C3138382C3130345D2C5B3230372C3138392C3130335D2C5B3230382C3139302C313033';
wwv_flow_imp.g_varchar2_table(211) := '5D2C5B3230392C3139312C3130325D2C5B3231302C3139322C3130325D2C5B3231312C3139332C3130315D2C5B3231322C3139342C3130305D2C5B3231342C3139352C3130305D2C5B3231352C3139362C39395D2C5B3231362C3139372C39395D2C5B32';
wwv_flow_imp.g_varchar2_table(212) := '31372C3139372C39385D2C5B3231382C3139382C39375D2C5B3231392C3139392C39375D2C5B3232302C3230302C39365D2C5B3232312C3230312C39355D2C5B3232322C3230322C39355D2C5B3232342C3230332C39345D2C5B3232352C3230342C3933';
wwv_flow_imp.g_varchar2_table(213) := '5D2C5B3232362C3230352C39325D2C5B3232372C3230362C39325D2C5B3232382C3230372C39315D2C5B3232392C3230382C39305D2C5B3233302C3230392C38395D2C5B3233322C3231302C38395D2C5B3233332C3231312C38385D2C5B3233342C3231';
wwv_flow_imp.g_varchar2_table(214) := '312C38375D2C5B3233352C3231322C38365D2C5B3233362C3231332C38355D2C5B3233372C3231342C38345D2C5B3233392C3231352C38335D2C5B3234302C3231362C38325D2C5B3234312C3231372C38315D2C5B3234322C3231382C38305D2C5B3234';
wwv_flow_imp.g_varchar2_table(215) := '332C3231392C37395D2C5B3234342C3232302C37385D2C5B3234362C3232312C37375D2C5B3234372C3232322C37365D2C5B3234382C3232332C37355D2C5B3234392C3232342C37345D2C5B3235302C3232352C37335D2C5B3235312C3232362C37325D';
wwv_flow_imp.g_varchar2_table(216) := '2C5B3235332C3232372C37305D2C5B3235342C3232382C36395D2C5B3235352C3232392C36385D2C5B3235352C3233302C36365D2C5B3235352C3233312C36365D2C5B3235352C3233322C36375D2C5B3235352C3233332C36385D2C5B3235352C323334';
wwv_flow_imp.g_varchar2_table(217) := '2C37305D5D2C726F636B65743A5B5B332C352C32365D2C5B342C352C32365D2C5B352C362C32375D2C5B362C372C32385D2C5B372C372C32395D2C5B382C382C33305D2C5B31302C392C33315D2C5B31312C392C33325D2C5B31332C31302C33335D2C5B';
wwv_flow_imp.g_varchar2_table(218) := '31342C31312C33345D2C5B31362C31312C33355D2C5B31372C31322C33365D2C5B31392C31332C33375D2C5B32302C31342C33385D2C5B32322C31342C33395D2C5B32332C31352C34305D2C5B32342C31352C34315D2C5B32362C31362C34325D2C5B32';
wwv_flow_imp.g_varchar2_table(219) := '372C31372C34335D2C5B32392C31372C34345D2C5B33302C31382C34355D2C5B33322C31382C34365D2C5B33332C31392C34385D2C5B33342C31392C34395D2C5B33362C32302C35305D2C5B33372C32302C35315D2C5B33392C32312C35325D2C5B3430';
wwv_flow_imp.g_varchar2_table(220) := '2C32312C35335D2C5B34322C32322C35345D2C5B34332C32322C35355D2C5B34352C32332C35365D2C5B34362C32332C35375D2C5B34382C32332C35385D2C5B34392C32342C35395D2C5B35312C32342C36305D2C5B35322C32352C36315D2C5B35332C';
wwv_flow_imp.g_varchar2_table(221) := '32352C36325D2C5B35352C32352C36335D2C5B35362C32362C36345D2C5B35382C32362C36355D2C5B36302C32362C36365D2C5B36312C32362C36365D2C5B36332C32372C36375D2C5B36342C32372C36385D2C5B36362C32372C36395D2C5B36372C32';
wwv_flow_imp.g_varchar2_table(222) := '382C37305D2C5B36392C32382C37315D2C5B37302C32382C37325D2C5B37322C32382C37325D2C5B37332C32392C37335D2C5B37352C32392C37345D2C5B37362C32392C37355D2C5B37382C32392C37355D2C5B38302C32392C37365D2C5B38312C3330';
wwv_flow_imp.g_varchar2_table(223) := '2C37375D2C5B38332C33302C37375D2C5B38342C33302C37385D2C5B38362C33302C37395D2C5B38382C33302C37395D2C5B38392C33302C38305D2C5B39312C33302C38315D2C5B39322C33302C38315D2C5B39342C33312C38325D2C5B39362C33312C';
wwv_flow_imp.g_varchar2_table(224) := '38325D2C5B39372C33312C38335D2C5B39392C33312C38335D2C5B3130302C33312C38345D2C5B3130322C33312C38345D2C5B3130342C33312C38355D2C5B3130352C33312C38355D2C5B3130372C33312C38365D2C5B3130392C33312C38365D2C5B31';
wwv_flow_imp.g_varchar2_table(225) := '31302C33312C38375D2C5B3131322C33312C38375D2C5B3131332C33312C38375D2C5B3131352C33312C38385D2C5B3131372C33312C38385D2C5B3131382C33312C38385D2C5B3132302C33312C38395D2C5B3132322C33312C38395D2C5B3132332C33';
wwv_flow_imp.g_varchar2_table(226) := '312C38395D2C5B3132352C33312C39305D2C5B3132372C33302C39305D2C5B3132392C33302C39305D2C5B3133302C33302C39305D2C5B3133322C33302C39305D2C5B3133342C33302C39315D2C5B3133352C33302C39315D2C5B3133372C33302C3931';
wwv_flow_imp.g_varchar2_table(227) := '5D2C5B3133392C32392C39315D2C5B3134302C32392C39315D2C5B3134322C32392C39315D2C5B3134342C32392C39315D2C5B3134362C32382C39315D2C5B3134372C32382C39315D2C5B3134392C32382C39315D2C5B3135312C32382C39315D2C5B31';
wwv_flow_imp.g_varchar2_table(228) := '35322C32372C39315D2C5B3135342C32372C39315D2C5B3135362C32372C39315D2C5B3135382C32362C39315D2C5B3135392C32362C39315D2C5B3136312C32362C39315D2C5B3136332C32352C39315D2C5B3136342C32352C39315D2C5B3136362C32';
wwv_flow_imp.g_varchar2_table(229) := '352C39305D2C5B3136382C32342C39305D2C5B3137302C32342C39305D2C5B3137312C32342C39305D2C5B3137332C32332C38395D2C5B3137352C32332C38395D2C5B3137362C32332C38395D2C5B3137382C32332C38385D2C5B3138302C32322C3838';
wwv_flow_imp.g_varchar2_table(230) := '5D2C5B3138312C32322C38375D2C5B3138332C32322C38375D2C5B3138352C32322C38375D2C5B3138362C32322C38365D2C5B3138382C32322C38365D2C5B3138392C32322C38355D2C5B3139312C32322C38345D2C5B3139332C32332C38345D2C5B31';
wwv_flow_imp.g_varchar2_table(231) := '39342C32332C38335D2C5B3139362C32332C38335D2C5B3139372C32342C38325D2C5B3139392C32352C38315D2C5B3230302C32352C38315D2C5B3230322C32362C38305D2C5B3230332C32372C37395D2C5B3230352C32382C37385D2C5B3230362C32';
wwv_flow_imp.g_varchar2_table(232) := '392C37385D2C5B3230372C33302C37375D2C5B3230392C33312C37365D2C5B3231302C33322C37365D2C5B3231312C33332C37355D2C5B3231332C33342C37345D2C5B3231342C33362C37335D2C5B3231352C33372C37335D2C5B3231362C33392C3732';
wwv_flow_imp.g_varchar2_table(233) := '5D2C5B3231372C34302C37315D2C5B3231392C34312C37305D2C5B3232302C34332C37305D2C5B3232312C34342C36395D2C5B3232322C34362C36385D2C5B3232332C34372C36385D2C5B3232342C34392C36375D2C5B3232352C35312C36365D2C5B32';
wwv_flow_imp.g_varchar2_table(234) := '32362C35322C36365D2C5B3232372C35342C36355D2C5B3232382C35362C36355D2C5B3232392C35372C36345D2C5B3233302C35392C36345D2C5B3233312C36312C36335D2C5B3233322C36332C36335D2C5B3233322C36342C36325D2C5B3233332C36';
wwv_flow_imp.g_varchar2_table(235) := '362C36325D2C5B3233342C36382C36325D2C5B3233352C37302C36325D2C5B3233352C37322C36325D2C5B3233362C37342C36325D2C5B3233362C37362C36325D2C5B3233372C37382C36325D2C5B3233372C38302C36325D2C5B3233382C38322C3633';
wwv_flow_imp.g_varchar2_table(236) := '5D2C5B3233382C38342C36335D2C5B3233392C38362C36345D2C5B3233392C38382C36345D2C5B3233392C39302C36355D2C5B3234302C39322C36365D2C5B3234302C39342C36365D2C5B3234302C39362C36375D2C5B3234312C39382C36385D2C5B32';
wwv_flow_imp.g_varchar2_table(237) := '34312C3130302C36395D2C5B3234312C3130322C37305D2C5B3234322C3130332C37315D2C5B3234322C3130352C37325D2C5B3234322C3130372C37335D2C5B3234322C3130392C37355D2C5B3234322C3131312C37365D2C5B3234332C3131332C3737';
wwv_flow_imp.g_varchar2_table(238) := '5D2C5B3234332C3131352C37385D2C5B3234332C3131362C38305D2C5B3234332C3131382C38315D2C5B3234332C3132302C38325D2C5B3234342C3132322C38345D2C5B3234342C3132342C38355D2C5B3234342C3132352C38375D2C5B3234342C3132';
wwv_flow_imp.g_varchar2_table(239) := '372C38385D2C5B3234342C3132392C39305D2C5B3234342C3133312C39315D2C5B3234342C3133322C39335D2C5B3234342C3133342C39345D2C5B3234352C3133362C39365D2C5B3234352C3133382C39375D2C5B3234352C3133392C39395D2C5B3234';
wwv_flow_imp.g_varchar2_table(240) := '352C3134312C3130305D2C5B3234352C3134332C3130325D2C5B3234352C3134342C3130335D2C5B3234352C3134362C3130355D2C5B3234352C3134382C3130375D2C5B3234352C3135302C3130385D2C5B3234352C3135312C3131305D2C5B3234352C';
wwv_flow_imp.g_varchar2_table(241) := '3135332C3131325D2C5B3234362C3135352C3131335D2C5B3234362C3135362C3131355D2C5B3234362C3135382C3131375D2C5B3234362C3136302C3131395D2C5B3234362C3136312C3132305D2C5B3234362C3136332C3132325D2C5B3234362C3136';
wwv_flow_imp.g_varchar2_table(242) := '342C3132345D2C5B3234362C3136362C3132365D2C5B3234362C3136382C3132385D2C5B3234362C3136392C3132395D2C5B3234362C3137312C3133315D2C5B3234362C3137332C3133335D2C5B3234362C3137342C3133355D2C5B3234362C3137362C';
wwv_flow_imp.g_varchar2_table(243) := '3133375D2C5B3234362C3137372C3133395D2C5B3234362C3137392C3134315D2C5B3234362C3138302C3134335D2C5B3234362C3138322C3134355D2C5B3234362C3138342C3134375D2C5B3234362C3138352C3134395D2C5B3234362C3138372C3135';
wwv_flow_imp.g_varchar2_table(244) := '315D2C5B3234362C3138382C3135335D2C5B3234362C3139302C3135355D2C5B3234362C3139312C3135375D2C5B3234362C3139332C3135395D2C5B3234372C3139342C3136325D2C5B3234372C3139362C3136345D2C5B3234372C3139382C3136365D';
wwv_flow_imp.g_varchar2_table(245) := '2C5B3234372C3139392C3136385D2C5B3234372C3230312C3137305D2C5B3234372C3230322C3137325D2C5B3234372C3230342C3137355D2C5B3234372C3230352C3137375D2C5B3234372C3230372C3137395D2C5B3234372C3230382C3138315D2C5B';
wwv_flow_imp.g_varchar2_table(246) := '3234382C3230392C3138345D2C5B3234382C3231312C3138365D2C5B3234382C3231322C3138385D2C5B3234382C3231342C3139305D2C5B3234382C3231352C3139325D2C5B3234382C3231372C3139355D2C5B3234382C3231382C3139375D2C5B3234';
wwv_flow_imp.g_varchar2_table(247) := '382C3232302C3139395D2C5B3234392C3232312C3230315D2C5B3234392C3232332C3230335D2C5B3234392C3232342C3230355D2C5B3234392C3232362C3230385D2C5B3234392C3232372C3231305D2C5B3234392C3232392C3231325D2C5B3235302C';
wwv_flow_imp.g_varchar2_table(248) := '3233302C3231345D2C5B3235302C3233322C3231365D2C5B3235302C3233332C3231385D2C5B3235302C3233352C3232315D5D2C6D616B6F3A5B5B31312C342C355D2C5B31332C342C365D2C5B31342C352C385D2C5B31352C362C395D2C5B31362C362C';
wwv_flow_imp.g_varchar2_table(249) := '31305D2C5B31372C372C31325D2C5B31382C382C31335D2C5B31392C392C31355D2C5B32302C392C31365D2C5B32312C31302C31385D2C5B32322C31312C31395D2C5B32332C31322C32315D2C5B32342C31332C32325D2C5B32352C31342C32345D2C5B';
wwv_flow_imp.g_varchar2_table(250) := '32362C31342C32355D2C5B32372C31352C32365D2C5B32382C31362C32385D2C5B32392C31372C32395D2C5B33302C31372C33315D2C5B33312C31382C33325D2C5B33322C31392C33345D2C5B33332C32302C33355D2C5B33342C32302C33375D2C5B33';
wwv_flow_imp.g_varchar2_table(251) := '352C32312C33385D2C5B33362C32322C34305D2C5B33372C32332C34315D2C5B33382C32332C34335D2C5B33392C32342C34355D2C5B34302C32352C34365D2C5B34312C32352C34385D2C5B34312C32362C34395D2C5B34322C32372C35315D2C5B3433';
wwv_flow_imp.g_varchar2_table(252) := '2C32382C35335D2C5B34342C32382C35345D2C5B34352C32392C35365D2C5B34362C33302C35375D2C5B34362C33302C35395D2C5B34372C33312C36315D2C5B34382C33322C36325D2C5B34392C33332C36345D2C5B34392C33332C36365D2C5B35302C';
wwv_flow_imp.g_varchar2_table(253) := '33342C36375D2C5B35312C33352C36395D2C5B35322C33362C37315D2C5B35322C33372C37325D2C5B35332C33372C37345D2C5B35332C33382C37365D2C5B35342C33392C37375D2C5B35352C34302C37395D2C5B35352C34302C38315D2C5B35362C34';
wwv_flow_imp.g_varchar2_table(254) := '312C38335D2C5B35362C34322C38345D2C5B35372C34332C38365D2C5B35382C34342C38385D2C5B35382C34342C38395D2C5B35392C34352C39315D2C5B35392C34362C39335D2C5B35392C34372C39355D2C5B36302C34382C39365D2C5B36302C3439';
wwv_flow_imp.g_varchar2_table(255) := '2C39385D2C5B36312C34392C3130305D2C5B36312C35302C3130325D2C5B36322C35312C3130335D2C5B36322C35322C3130355D2C5B36322C35332C3130375D2C5B36332C35342C3130395D2C5B36332C35342C3131315D2C5B36332C35352C3131325D';
wwv_flow_imp.g_varchar2_table(256) := '2C5B36342C35362C3131345D2C5B36342C35372C3131365D2C5B36342C35382C3131385D2C5B36342C35392C3132305D2C5B36342C36302C3132315D2C5B36352C36312C3132335D2C5B36352C36322C3132355D2C5B36352C36322C3132375D2C5B3635';
wwv_flow_imp.g_varchar2_table(257) := '2C36332C3132385D2C5B36352C36342C3133305D2C5B36352C36352C3133325D2C5B36352C36362C3133335D2C5B36352C36372C3133355D2C5B36352C36382C3133365D2C5B36342C37302C3133385D2C5B36342C37312C3133395D2C5B36342C37322C';
wwv_flow_imp.g_varchar2_table(258) := '3134315D2C5B36342C37332C3134325D2C5B36332C37342C3134335D2C5B36332C37352C3134345D2C5B36332C37362C3134365D2C5B36322C37372C3134375D2C5B36322C37392C3134385D2C5B36322C38302C3134395D2C5B36312C38312C3134395D';
wwv_flow_imp.g_varchar2_table(259) := '2C5B36312C38322C3135305D2C5B36302C38332C3135315D2C5B36302C38352C3135325D2C5B35392C38362C3135325D2C5B35392C38372C3135335D2C5B35392C38382C3135345D2C5B35382C38392C3135345D2C5B35382C39312C3135355D2C5B3538';
wwv_flow_imp.g_varchar2_table(260) := '2C39322C3135355D2C5B35372C39332C3135365D2C5B35372C39342C3135365D2C5B35362C39352C3135365D2C5B35362C39372C3135375D2C5B35362C39382C3135375D2C5B35362C39392C3135375D2C5B35352C3130302C3135385D2C5B35352C3130';
wwv_flow_imp.g_varchar2_table(261) := '312C3135385D2C5B35352C3130322C3135385D2C5B35352C3130342C3135395D2C5B35342C3130352C3135395D2C5B35342C3130362C3135395D2C5B35342C3130372C3135395D2C5B35342C3130382C3136305D2C5B35342C3130392C3136305D2C5B35';
wwv_flow_imp.g_varchar2_table(262) := '342C3131312C3136305D2C5B35342C3131322C3136305D2C5B35342C3131332C3136305D2C5B35332C3131342C3136315D2C5B35332C3131352C3136315D2C5B35332C3131362C3136315D2C5B35332C3131372C3136315D2C5B35332C3131382C313632';
wwv_flow_imp.g_varchar2_table(263) := '5D2C5B35332C3132302C3136325D2C5B35332C3132312C3136325D2C5B35332C3132322C3136325D2C5B35332C3132332C3136335D2C5B35332C3132342C3136335D2C5B35332C3132352C3136335D2C5B35332C3132362C3136345D2C5B35322C313237';
wwv_flow_imp.g_varchar2_table(264) := '2C3136345D2C5B35322C3132382C3136345D2C5B35322C3133302C3136345D2C5B35322C3133312C3136355D2C5B35322C3133322C3136355D2C5B35322C3133332C3136355D2C5B35322C3133342C3136355D2C5B35322C3133352C3136365D2C5B3532';
wwv_flow_imp.g_varchar2_table(265) := '2C3133362C3136365D2C5B35322C3133372C3136365D2C5B35322C3133392C3136365D2C5B35322C3134302C3136375D2C5B35322C3134312C3136375D2C5B35322C3134322C3136375D2C5B35322C3134332C3136375D2C5B35322C3134342C3136385D';
wwv_flow_imp.g_varchar2_table(266) := '2C5B35322C3134352C3136385D2C5B35322C3134362C3136385D2C5B35322C3134372C3136385D2C5B35322C3134392C3136395D2C5B35322C3135302C3136395D2C5B35322C3135312C3136395D2C5B35322C3135322C3136395D2C5B35322C3135332C';
wwv_flow_imp.g_varchar2_table(267) := '3137305D2C5B35322C3135342C3137305D2C5B35332C3135352C3137305D2C5B35332C3135362C3137305D2C5B35332C3135382C3137305D2C5B35332C3135392C3137315D2C5B35332C3136302C3137315D2C5B35332C3136312C3137315D2C5B35342C';
wwv_flow_imp.g_varchar2_table(268) := '3136322C3137315D2C5B35342C3136332C3137315D2C5B35342C3136342C3137315D2C5B35352C3136352C3137325D2C5B35352C3136362C3137325D2C5B35352C3136382C3137325D2C5B35362C3136392C3137325D2C5B35362C3137302C3137325D2C';
wwv_flow_imp.g_varchar2_table(269) := '5B35372C3137312C3137325D2C5B35372C3137322C3137325D2C5B35382C3137332C3137325D2C5B35382C3137342C3137335D2C5B35392C3137352C3137335D2C5B36302C3137372C3137335D2C5B36302C3137382C3137335D2C5B36312C3137392C31';
wwv_flow_imp.g_varchar2_table(270) := '37335D2C5B36322C3138302C3137335D2C5B36332C3138312C3137335D2C5B36332C3138322C3137335D2C5B36342C3138332C3137335D2C5B36352C3138342C3137335D2C5B36362C3138352C3137335D2C5B36372C3138362C3137335D2C5B36382C31';
wwv_flow_imp.g_varchar2_table(271) := '38382C3137335D2C5B36392C3138392C3137335D2C5B37302C3139302C3137335D2C5B37312C3139312C3137335D2C5B37322C3139322C3137335D2C5B37332C3139332C3137335D2C5B37352C3139342C3137335D2C5B37362C3139352C3137335D2C5B';
wwv_flow_imp.g_varchar2_table(272) := '37372C3139362C3137335D2C5B37392C3139372C3137335D2C5B38302C3139382C3137335D2C5B38322C3139392C3137335D2C5B38332C3230312C3137335D2C5B38352C3230322C3137335D2C5B38372C3230332C3137335D2C5B38392C3230342C3137';
wwv_flow_imp.g_varchar2_table(273) := '335D2C5B39312C3230352C3137335D2C5B39342C3230352C3137335D2C5B39362C3230362C3137325D2C5B39382C3230372C3137325D2C5B3130312C3230382C3137335D2C5B3130342C3230392C3137335D2C5B3130362C3231302C3137335D2C5B3130';
wwv_flow_imp.g_varchar2_table(274) := '392C3231312C3137335D2C5B3131322C3231322C3137335D2C5B3131352C3231322C3137335D2C5B3131382C3231332C3137345D2C5B3132312C3231342C3137345D2C5B3132342C3231342C3137355D2C5B3132372C3231352C3137355D2C5B3133302C';
wwv_flow_imp.g_varchar2_table(275) := '3231362C3137365D2C5B3133332C3231372C3137375D2C5B3133362C3231372C3137375D2C5B3133392C3231382C3137385D2C5B3134322C3231392C3137395D2C5B3134352C3231392C3138305D2C5B3134382C3232302C3138315D2C5B3135302C3232';
wwv_flow_imp.g_varchar2_table(276) := '312C3138315D2C5B3135332C3232312C3138325D2C5B3135362C3232322C3138335D2C5B3135382C3232332C3138345D2C5B3136312C3232332C3138355D2C5B3136342C3232342C3138375D2C5B3136362C3232352C3138385D2C5B3136392C3232352C';
wwv_flow_imp.g_varchar2_table(277) := '3138395D2C5B3137312C3232362C3139305D2C5B3137342C3232372C3139325D2C5B3137362C3232382C3139335D2C5B3137382C3232382C3139345D2C5B3138312C3232392C3139365D2C5B3138332C3233302C3139375D2C5B3138352C3233302C3139';
wwv_flow_imp.g_varchar2_table(278) := '395D2C5B3138372C3233312C3230305D2C5B3139302C3233322C3230325D2C5B3139322C3233332C3230345D2C5B3139342C3233332C3230355D2C5B3139362C3233342C3230375D2C5B3139382C3233352C3230395D2C5B3230302C3233362C3231305D';
wwv_flow_imp.g_varchar2_table(279) := '2C5B3230322C3233372C3231325D2C5B3230342C3233372C3231345D2C5B3230362C3233382C3231355D2C5B3230382C3233392C3231375D2C5B3231302C3234302C3231395D2C5B3231322C3234312C3232305D2C5B3231342C3234312C3232325D2C5B';
wwv_flow_imp.g_varchar2_table(280) := '3231362C3234322C3232345D2C5B3231382C3234332C3232355D2C5B3232302C3234342C3232375D2C5B3232322C3234352C3232395D5D2C747572626F3A5B5B34382C31382C35395D2C5B35302C32312C36375D2C5B35312C32342C37345D2C5B35322C';
wwv_flow_imp.g_varchar2_table(281) := '32372C38315D2C5B35332C33302C38385D2C5B35342C33332C39355D2C5B35352C33362C3130325D2C5B35362C33392C3130395D2C5B35372C34322C3131355D2C5B35382C34352C3132315D2C5B35392C34372C3132385D2C5B36302C35302C3133345D';
wwv_flow_imp.g_varchar2_table(282) := '2C5B36312C35332C3133395D2C5B36322C35362C3134355D2C5B36332C35392C3135315D2C5B36332C36322C3135365D2C5B36342C36342C3136325D2C5B36352C36372C3136375D2C5B36352C37302C3137325D2C5B36362C37332C3137375D2C5B3636';
wwv_flow_imp.g_varchar2_table(283) := '2C37352C3138315D2C5B36372C37382C3138365D2C5B36382C38312C3139315D2C5B36382C38342C3139355D2C5B36382C38362C3139395D2C5B36392C38392C3230335D2C5B36392C39322C3230375D2C5B36392C39342C3231315D2C5B37302C39372C';
wwv_flow_imp.g_varchar2_table(284) := '3231345D2C5B37302C3130302C3231385D2C5B37302C3130322C3232315D2C5B37302C3130352C3232345D2C5B37302C3130372C3232375D2C5B37312C3131302C3233305D2C5B37312C3131332C3233335D2C5B37312C3131352C3233355D2C5B37312C';
wwv_flow_imp.g_varchar2_table(285) := '3131382C3233385D2C5B37312C3132302C3234305D2C5B37312C3132332C3234325D2C5B37302C3132352C3234345D2C5B37302C3132382C3234365D2C5B37302C3133302C3234385D2C5B37302C3133332C3235305D2C5B37302C3133352C3235315D2C';
wwv_flow_imp.g_varchar2_table(286) := '5B36392C3133382C3235325D2C5B36392C3134302C3235335D2C5B36382C3134332C3235345D2C5B36372C3134352C3235345D2C5B36362C3134382C3235355D2C5B36352C3135302C3235355D2C5B36342C3135332C3235355D2C5B36322C3135352C32';
wwv_flow_imp.g_varchar2_table(287) := '35345D2C5B36312C3135382C3235345D2C5B35392C3136302C3235335D2C5B35382C3136332C3235325D2C5B35362C3136352C3235315D2C5B35352C3136382C3235305D2C5B35332C3137312C3234385D2C5B35312C3137332C3234375D2C5B34392C31';
wwv_flow_imp.g_varchar2_table(288) := '37352C3234355D2C5B34372C3137382C3234345D2C5B34362C3138302C3234325D2C5B34342C3138332C3234305D2C5B34322C3138352C3233385D2C5B34302C3138382C3233355D2C5B33392C3139302C3233335D2C5B33372C3139322C3233315D2C5B';
wwv_flow_imp.g_varchar2_table(289) := '33352C3139352C3232385D2C5B33342C3139372C3232365D2C5B33322C3139392C3232335D2C5B33312C3230312C3232315D2C5B33302C3230332C3231385D2C5B32382C3230352C3231365D2C5B32372C3230382C3231335D2C5B32362C3231302C3231';
wwv_flow_imp.g_varchar2_table(290) := '305D2C5B32362C3231322C3230385D2C5B32352C3231332C3230355D2C5B32342C3231352C3230325D2C5B32342C3231372C3230305D2C5B32342C3231392C3139375D2C5B32342C3232312C3139345D2C5B32342C3232322C3139325D2C5B32342C3232';
wwv_flow_imp.g_varchar2_table(291) := '342C3138395D2C5B32352C3232362C3138375D2C5B32352C3232372C3138355D2C5B32362C3232382C3138325D2C5B32382C3233302C3138305D2C5B32392C3233312C3137385D2C5B33312C3233332C3137355D2C5B33322C3233342C3137325D2C5B33';
wwv_flow_imp.g_varchar2_table(292) := '342C3233352C3137305D2C5B33372C3233362C3136375D2C5B33392C3233382C3136345D2C5B34322C3233392C3136315D2C5B34342C3234302C3135385D2C5B34372C3234312C3135355D2C5B35302C3234322C3135325D2C5B35332C3234332C313438';
wwv_flow_imp.g_varchar2_table(293) := '5D2C5B35362C3234342C3134355D2C5B36302C3234352C3134325D2C5B36332C3234362C3133385D2C5B36372C3234372C3133355D2C5B37302C3234382C3133325D2C5B37342C3234382C3132385D2C5B37382C3234392C3132355D2C5B38322C323530';
wwv_flow_imp.g_varchar2_table(294) := '2C3132325D2C5B38352C3235302C3131385D2C5B38392C3235312C3131355D2C5B39332C3235322C3131315D2C5B39372C3235322C3130385D2C5B3130312C3235332C3130355D2C5B3130352C3235332C3130325D2C5B3130392C3235342C39385D2C5B';
wwv_flow_imp.g_varchar2_table(295) := '3131332C3235342C39355D2C5B3131372C3235342C39325D2C5B3132312C3235342C38395D2C5B3132352C3235352C38365D2C5B3132382C3235352C38335D2C5B3133322C3235352C38315D2C5B3133362C3235352C37385D2C5B3133392C3235352C37';
wwv_flow_imp.g_varchar2_table(296) := '355D2C5B3134332C3235352C37335D2C5B3134362C3235352C37315D2C5B3135302C3235342C36385D2C5B3135332C3235342C36365D2C5B3135362C3235342C36345D2C5B3135392C3235332C36335D2C5B3136312C3235332C36315D2C5B3136342C32';
wwv_flow_imp.g_varchar2_table(297) := '35322C36305D2C5B3136372C3235322C35385D2C5B3136392C3235312C35375D2C5B3137322C3235312C35365D2C5B3137352C3235302C35355D2C5B3137372C3234392C35345D2C5B3138302C3234382C35345D2C5B3138332C3234372C35335D2C5B31';
wwv_flow_imp.g_varchar2_table(298) := '38352C3234362C35335D2C5B3138382C3234352C35325D2C5B3139302C3234342C35325D2C5B3139332C3234332C35325D2C5B3139352C3234312C35325D2C5B3139382C3234302C35325D2C5B3230302C3233392C35325D2C5B3230332C3233372C3532';
wwv_flow_imp.g_varchar2_table(299) := '5D2C5B3230352C3233362C35325D2C5B3230382C3233342C35325D2C5B3231302C3233332C35335D2C5B3231322C3233312C35335D2C5B3231352C3232392C35335D2C5B3231372C3232382C35345D2C5B3231392C3232362C35345D2C5B3232312C3232';
wwv_flow_imp.g_varchar2_table(300) := '342C35355D2C5B3232332C3232332C35355D2C5B3232352C3232312C35355D2C5B3232372C3231392C35365D2C5B3232392C3231372C35365D2C5B3233312C3231352C35375D2C5B3233332C3231332C35375D2C5B3233352C3231312C35375D2C5B3233';
wwv_flow_imp.g_varchar2_table(301) := '362C3230392C35385D2C5B3233382C3230372C35385D2C5B3233392C3230352C35385D2C5B3234312C3230332C35385D2C5B3234322C3230312C35385D2C5B3234342C3139392C35385D2C5B3234352C3139372C35385D2C5B3234362C3139352C35385D';
wwv_flow_imp.g_varchar2_table(302) := '2C5B3234372C3139332C35385D2C5B3234382C3139302C35375D2C5B3234392C3138382C35375D2C5B3235302C3138362C35375D2C5B3235312C3138342C35365D2C5B3235312C3138322C35355D2C5B3235322C3137392C35345D2C5B3235322C313737';
wwv_flow_imp.g_varchar2_table(303) := '2C35345D2C5B3235332C3137342C35335D2C5B3235332C3137322C35325D2C5B3235342C3136392C35315D2C5B3235342C3136372C35305D2C5B3235342C3136342C34395D2C5B3235342C3136312C34385D2C5B3235342C3135382C34375D2C5B323534';
wwv_flow_imp.g_varchar2_table(304) := '2C3135352C34355D2C5B3235342C3135332C34345D2C5B3235342C3135302C34335D2C5B3235342C3134372C34325D2C5B3235342C3134342C34315D2C5B3235332C3134312C33395D2C5B3235332C3133382C33385D2C5B3235322C3133352C33375D2C';
wwv_flow_imp.g_varchar2_table(305) := '5B3235322C3133322C33355D2C5B3235312C3132392C33345D2C5B3235312C3132362C33335D2C5B3235302C3132332C33315D2C5B3234392C3132302C33305D2C5B3234392C3131372C32395D2C5B3234382C3131342C32385D2C5B3234372C3131312C';
wwv_flow_imp.g_varchar2_table(306) := '32365D2C5B3234362C3130382C32355D2C5B3234352C3130352C32345D2C5B3234342C3130322C32335D2C5B3234332C39392C32315D2C5B3234322C39362C32305D2C5B3234312C39332C31395D2C5B3234302C39312C31385D2C5B3233392C38382C31';
wwv_flow_imp.g_varchar2_table(307) := '375D2C5B3233372C38352C31365D2C5B3233362C38332C31355D2C5B3233352C38302C31345D2C5B3233342C37382C31335D2C5B3233322C37352C31325D2C5B3233312C37332C31325D2C5B3232392C37312C31315D2C5B3232382C36392C31305D2C5B';
wwv_flow_imp.g_varchar2_table(308) := '3232362C36372C31305D2C5B3232352C36352C395D2C5B3232332C36332C385D2C5B3232312C36312C385D2C5B3232302C35392C375D2C5B3231382C35372C375D2C5B3231362C35352C365D2C5B3231342C35332C365D2C5B3231322C35312C355D2C5B';
wwv_flow_imp.g_varchar2_table(309) := '3231302C34392C355D2C5B3230382C34372C355D2C5B3230362C34352C345D2C5B3230342C34332C345D2C5B3230322C34322C345D2C5B3230302C34302C335D2C5B3139372C33382C335D2C5B3139352C33372C335D2C5B3139332C33352C325D2C5B31';
wwv_flow_imp.g_varchar2_table(310) := '39302C33332C325D2C5B3138382C33322C325D2C5B3138352C33302C325D2C5B3138332C32392C325D2C5B3138302C32372C315D2C5B3137382C32362C315D2C5B3137352C32342C315D2C5B3137322C32332C315D2C5B3136392C32322C315D2C5B3136';
wwv_flow_imp.g_varchar2_table(311) := '372C32302C315D2C5B3136342C31392C315D2C5B3136312C31382C315D2C5B3135382C31362C315D2C5B3135352C31352C315D2C5B3135322C31342C315D2C5B3134392C31332C315D2C5B3134362C31312C315D2C5B3134322C31302C315D2C5B313339';
wwv_flow_imp.g_varchar2_table(312) := '2C392C325D2C5B3133362C382C325D2C5B3133332C372C325D2C5B3132392C362C325D2C5B3132362C352C325D2C5B3132322C342C335D5D7D3B423D22637573746F6D223D3D683F753A655B685D2C427C7C28423D5B2223663365373962222C22236661';
wwv_flow_imp.g_varchar2_table(313) := '63343834222C2223663861303765222C2223656237663836222C2223636536363933222C2223613035396130222C2223356335336135225D292C2266756E6374696F6E223D3D747970656F662042262628423D42287B6D696E3A502E72616E67655B305D';
wwv_flow_imp.g_varchar2_table(314) := '2C6D61783A502E72616E67655B315D2C6D65616E3A502E6D65616E2C6D656469616E3A502E6D656469616E2C73746465763A502E73746465767D2C6529292C41727261792E69734172726179284229262628423D7B73746F70733A427D292C422E747970';
wwv_flow_imp.g_varchar2_table(315) := '657C7C3D2273657175656E7469616C222C41727261792E6973417272617928422E73746F70735B305D292626323D3D3D422E73746F70735B305D2E6C656E6774687C7C28422E73746F70733D422E73746F70732E6D6170282828652C74293D3E5B742F28';
wwv_flow_imp.g_varchar2_table(316) := '422E73746F70732E6C656E6774682D31292A28502E72616E67655B315D2D502E72616E67655B305D292B502E72616E67655B305D2C655D2929293B666F7228636F6E73742065206F6620422E73746F707329655B315D3D5428655B315D297D2928297D3B';
wwv_flow_imp.g_varchar2_table(317) := '6C6574204C2C572C552C7A2C512C442C4E3B6177616974207128293B6C6574206A3D5B5D2C463D5B5D3B7377697463682863297B6361736522726173746572223A553D21302C513D21303B627265616B3B636173652264656D223A702E696E636C756465';
wwv_flow_imp.g_varchar2_table(318) := '73282233642229262628573D2130292C702E696E636C756465732822636F6C6F722D72656C6965662229262628763F284C3D21302C4E3D2130293A28553D21302C513D213029292C702E696E636C75646573282268696C6C736861646522292626284C3D';
wwv_flow_imp.g_varchar2_table(319) := '21302C443D2130292C702E696E636C756465732822636F6E746F75727322292626287A3D2130293B627265616B3B64656661756C743A33323D3D502E63656C6C64657074683F284C3D21302C443D2130293A28553D21302C513D2130297D636F6E737420';
wwv_flow_imp.g_varchar2_table(320) := '4F3D2D3165342C563D2E313B636F6E737420583D6E657720636C6173737B636F6E7374727563746F7228653D323530297B746869732E5F63616368653D6E6577204D61702C746869732E5F726563656E743D5B5D2C746869732E5F73697A653D657D6861';
wwv_flow_imp.g_varchar2_table(321) := '732865297B72657475726E20746869732E5F63616368652E6861732865297D6765742865297B696628746869732E5F63616368652E686173286529297B636F6E737420743D746869732E5F726563656E742E696E6465784F662865293B72657475726E20';
wwv_flow_imp.g_varchar2_table(322) := '746869732E5F726563656E742E73706C69636528742C31292C746869732E5F726563656E742E707573682865292C746869732E5F63616368652E6765742865297D7D70757428652C74297B636F6E737420723D746869732E5F726563656E742E696E6465';
wwv_flow_imp.g_varchar2_table(323) := '784F662865293B723E3D303F746869732E5F726563656E742E73706C69636528722C31293A746869732E5F726563656E742E6C656E6774683E3D746869732E5F73697A65262628746869732E5F63616368652E64656C65746528746869732E5F72656365';
wwv_flow_imp.g_varchar2_table(324) := '6E745B305D292C746869732E5F726563656E742E73706C69636528302C3129292C746869732E5F726563656E742E707573682865292C746869732E5F63616368652E73657428652C74297D636C65617228297B746869732E5F63616368652E636C656172';
wwv_flow_imp.g_varchar2_table(325) := '28292C746869732E5F726563656E743D5B5D7D7D2C4A3D6173796E6328722C612C73293D3E7B636F6E7374206E3D60247B727D2F247B617D2F247B737D603B696628582E686173286E292972657475726E20617761697420582E676574286E293B636F6E';
wwv_flow_imp.g_varchar2_table(326) := '7374206F3D5F28612C72292C693D7928732C72292C633D5F28612B312C72292C753D7928732B312C72292C643D286173796E6328293D3E7B636F6E7374206E3D617761697420617065782E7365727665722E706C7567696E28742C7B7830313A312C7830';
wwv_flow_imp.g_varchar2_table(327) := '323A473F472E6A6F696E28222C22293A6E756C6C2C7830333A6F2C7830343A692C7830353A632C7830363A752C7830373A2227222B722B222C222B612B222C222B732B2227222C7830383A652C706167654974656D733A6C3F6C2E73706C697428222C22';
wwv_flow_imp.g_varchar2_table(328) := '293A766F696420307D293B6966286E2E63656C6C64617461297B636F6E737420653D61746F62286E2E63656C6C64617461292C743D652E6C656E6774682C723D6E65772055696E743841727261792874293B666F72286C657420613D303B613C743B612B';
wwv_flow_imp.g_varchar2_table(329) := '2B29725B615D3D652E63686172436F646541742861293B6E2E63656C6C646174613D722E6275666665727D72657475726E206E7D2928293B72657475726E20582E707574286E2C64292C617761697420647D3B636F6E737420483D6E657720636C617373';
wwv_flow_imp.g_varchar2_table(330) := '7B636F6E7374727563746F722865297B746869732E776F726B657246696C653D652C746869732E6D617853697A653D6E6176696761746F722E6861726477617265436F6E63757272656E63797C7C342C746869732E696E616374697669747954696D656F';
wwv_flow_imp.g_varchar2_table(331) := '75743D3165342C746869732E776F726B6572733D5B5D2C746869732E7461736B51756575653D5B5D2C746869732E636C65616E7570496E74657276616C3D6E756C6C2C746869732E6164644E6577576F726B657228297D72756E2865297B72657475726E';
wwv_flow_imp.g_varchar2_table(332) := '206E65772050726F6D697365282828742C72293D3E7B746869732E7461736B51756575652E70757368287B646174613A652C7265736F6C76653A742C72656A6563743A727D292C746869732E646973706174636828297D29297D64697370617463682829';
wwv_flow_imp.g_varchar2_table(333) := '7B696628303D3D3D746869732E7461736B51756575652E6C656E6774682972657475726E3B6C657420653D746869732E776F726B6572732E66696E642828653D3E21652E69734275737929293B69662821652626746869732E776F726B6572732E6C656E';
wwv_flow_imp.g_varchar2_table(334) := '6774683C746869732E6D617853697A65262628653D746869732E6164644E6577576F726B65722829292C65297B636F6E737420743D746869732E7461736B51756575652E736869667428293B69662821742972657475726E3B652E6973427573793D2130';
wwv_flow_imp.g_varchar2_table(335) := '2C652E6C617374557365643D446174652E6E6F7728293B636F6E73747B776F726B65723A727D3D652C613D28293D3E7B722E72656D6F76654576656E744C697374656E657228226D657373616765222C73292C722E72656D6F76654576656E744C697374';
wwv_flow_imp.g_varchar2_table(336) := '656E657228226572726F72222C6E292C652E6973427573793D21312C746869732E646973706174636828297D2C733D653D3E7B6128292C2273756363657373223D3D3D652E646174612E7374617475733F742E7265736F6C766528652E646174612E6461';
wwv_flow_imp.g_varchar2_table(337) := '7461293A742E72656A656374286E6577204572726F722822776F726B6572207461736B206661696C65643A20222B652E646174612E6D65737361676529297D2C6E3D653D3E7B6128292C742E72656A6563742865297D3B722E6164644576656E744C6973';
wwv_flow_imp.g_varchar2_table(338) := '74656E657228226D657373616765222C73292C722E6164644576656E744C697374656E657228226572726F72222C6E292C722E706F73744D65737361676528742E64617461297D7D6164644E6577576F726B657228297B636F6E737420653D7B776F726B';
wwv_flow_imp.g_varchar2_table(339) := '65723A6E657720576F726B657228746869732E776F726B657246696C65292C6973427573793A21312C6C617374557365643A446174652E6E6F7728297D3B72657475726E20746869732E776F726B6572732E707573682865292C6E756C6C3D3D3D746869';
wwv_flow_imp.g_varchar2_table(340) := '732E636C65616E7570496E74657276616C262628746869732E636C65616E7570496E74657276616C3D736574496E74657276616C282828293D3E746869732E7465726D696E617465496E616374697665576F726B6572732829292C31653429292C657D74';
wwv_flow_imp.g_varchar2_table(341) := '65726D696E617465496E616374697665576F726B65727328297B636F6E737420653D446174652E6E6F7728293B746869732E776F726B6572732E666F7245616368282828742C72293D3E7B21742E6973427573792626652D742E6C617374557365643E74';
wwv_flow_imp.g_varchar2_table(342) := '6869732E696E616374697669747954696D656F7574262628742E776F726B65722E7465726D696E61746528292C746869732E776F726B6572732E73706C69636528722C3129297D29292C303D3D3D746869732E776F726B6572732E6C656E677468262628';
wwv_flow_imp.g_varchar2_table(343) := '636C656172496E74657276616C28746869732E636C65616E7570496E74657276616C292C746869732E636C65616E7570496E74657276616C3D6E756C6C297D7D28672B226D6170626974735F67656F7261737465725F776F726B65722E6A7322292C4B3D';
wwv_flow_imp.g_varchar2_table(344) := '6E657720526567457870282F3A5C2F5C2F282E2B295C2F282E2B295C2F285C642B295C2F285C642B295C2F285C642B292F292C593D653D3E7B636F6E737420743D61746F622865292C723D742E6C656E6774682C613D6E65772055696E74384172726179';
wwv_flow_imp.g_varchar2_table(345) := '2872293B666F72286C657420653D303B653C723B652B2B29615B655D3D742E63686172436F646541742865293B72657475726E20617D2C5A3D592822556B6C47526951414141425852554A51566C413454426741414141762F38412F414164517779786F';
wwv_flow_imp.g_varchar2_table(346) := '2F774D416976542F50305830502F572F2F77413D22292C65653D592822556B6C47526949414141425852554A51566C413454425541414141762F38412F4541635145524541554B542F2F796D692F366E2F2F51634122293B6173796E632066756E637469';
wwv_flow_imp.g_varchar2_table(347) := '6F6E20746528742C72297B636F6E737420613D742E75726C2E6D61746368284B293B6966282161297468726F77206E6577204572726F7228224D616C666F726D65642055524C3A205B222B742E75726C2B225D22293B636F6E737420733D615B325D2C6E';
wwv_flow_imp.g_varchar2_table(348) := '3D5B7061727365496E7428615B335D292C7061727365496E7428615B345D292C7061727365496E7428615B355D295D2C6F3D227261737465722D64656D223D3D3D733F5A3A65653B696628502E6E6F5261737465722972657475726E7B646174613A6F7D';
wwv_flow_imp.g_varchar2_table(349) := '3B502E6974656D6964213D652626616C65727428502E6974656D69642B2220213D20222B65292C303D3D502E6D6178707972616D69646C6576656C2626636F6E736F6C652E7761726E28224D6170626974732047656F526173746572204C61796572205B';
wwv_flow_imp.g_varchar2_table(350) := '222B652B225D206973206D697373696E6720707972616D6964732E204275696C6420707972616D69647320746F20696D70726F766520706572666F726D616E63652E22293B636F6E737420693D6177616974204A286E5B305D2C6E5B315D2C6E5B325D29';
wwv_flow_imp.g_varchar2_table(351) := '3B72657475726E20303D3D3D692E77696474687C7C303D3D3D692E6865696768747C7C692E6E6F5261737465723F7B646174613A6F7D3A617761697420482E72756E287B646174613A692C705F7465727261696E5F66656174757265733A702C666F726D';
wwv_flow_imp.g_varchar2_table(352) := '61743A732C636F6C6F7252616D703A422C7465727261696E426173653A4F2C7465727261696E5265736F6C7574696F6E3A562C6261636B67726F756E64436F6C6F723A477D297D636F6E73742072653D28293D3E7B6E652626286E652E6D616E61676572';
wwv_flow_imp.g_varchar2_table(353) := '2E636F6E746F757243616368652E636C65617228292C6E652E6D616E616765722E70617273656443616368652E636C65617228292C6E652E6D616E616765722E74696C6543616368652E636C6561722829297D2C61653D28293D3E7B726528293B636F6E';
wwv_flow_imp.g_varchar2_table(354) := '737420743D28742C72293D3E7B636F6E737420613D652B222D222B743B492E6765744C617965722861292626492E7365744C61796F757450726F706572747928612C227669736962696C697479222C2276697369626C6522213D3D787C7C723F226E6F6E';
wwv_flow_imp.g_varchar2_table(355) := '65223A2276697369626C6522297D3B74282272656C696566222C4D292C74282268696C6C7368616465222C53292C742822636F6E746F75722D6C696E6573222C52292C742822636F6E746F75722D6C6162656C73222C52292C742822726173746572222C';
wwv_flow_imp.g_varchar2_table(356) := '4D297D3B6C65742073652C6E653D6E756C6C3B7A2626286E653D6E6577206D6C636F6E746F75722E44656D536F75726365287B69643A2267656F725F636F6E746F75725F222B652C75726C3A6067656F7261737465725F247B657D3A2F2F247B657D2F72';
wwv_flow_imp.g_varchar2_table(357) := '61737465722D64656D2F7B7A7D2F7B787D2F7B797D602C6D61787A6F6F6D3A32322C776F726B65723A21312C656E636F64696E673A226D6170626F78222C74696D656F75744D733A3165397D292C6E652E6D616E616765722E67657454696C653D617379';
wwv_flow_imp.g_varchar2_table(358) := '6E6328652C74293D3E7B636F6E737420723D6177616974207465287B75726C3A657D293B72657475726E206E756C6C3D3D3D722E646174613F722E646174613D7A65726F426C6F623A722E646174613D6E657720426C6F62285B722E646174615D292C72';
wwv_flow_imp.g_varchar2_table(359) := '7D2C6E652E73657475704D61706C69627265286D61706C69627265676C29293B636F6E7374206F653D28293D3E7B696628432B2B2C6A3D5B5D2C463D5B5D2C4C7C7C57297B636F6E737420743D7B747970653A227261737465722D64656D222C74696C65';
wwv_flow_imp.g_varchar2_table(360) := '733A5B6067656F7261737465725F247B657D3A2F2F247B657D2F7261737465722D64656D2F7B7A7D2F7B787D2F7B797D2F72656672657368247B437D605D2C74696C6553697A653A3235367D3B41262628742E656E636F64696E673D22637573746F6D22';
wwv_flow_imp.g_varchar2_table(361) := '2C742E6261736553686966743D4F2C742E726564466163746F723D363535332E362C742E677265656E466163746F723D32352E362C742E626C7565466163746F723D56292C4C262628492E616464536F75726365282267656F72617374657244454D536F';
wwv_flow_imp.g_varchar2_table(362) := '757263655F222B432B225F222B652C74292C6A2E70757368282267656F72617374657244454D536F757263655F222B432B225F222B6529292C57262628492E616464536F75726365282267656F72617374657244454D3364536F757263655F222B432B22';
wwv_flow_imp.g_varchar2_table(363) := '5F222B652C74292C6A2E70757368282267656F72617374657244454D3364536F757263655F222B432B225F222B6529297D69662855297B636F6E737420743D7B747970653A22726173746572222C74696C65733A5B6067656F7261737465725F247B657D';
wwv_flow_imp.g_varchar2_table(364) := '3A2F2F247B657D2F7261737465722F7B7A7D2F7B787D2F7B797D2F72656672657368247B437D605D2C74696C6553697A653A3235367D3B492E616464536F75726365282267656F726173746572536F757263655F222B432B225F222B652C74292C6A2E70';
wwv_flow_imp.g_varchar2_table(365) := '757368282267656F726173746572536F757263655F222B432B225F222B65297D6966287A297B636F6E737420743D7B747970653A22766563746F72222C74696C65733A5B6E652E636F6E746F757250726F746F636F6C55726C287B7468726573686F6C64';
wwv_flow_imp.g_varchar2_table(366) := '733A7B31353A5B352C32352C35305D2C31363A5B312C352C31305D7D7D295D7D3B492E616464536F75726365282267656F726173746572436F6E746F7572536F757263655F222B432B225F222B652C74292C6A2E70757368282267656F72617374657243';
wwv_flow_imp.g_varchar2_table(367) := '6F6E746F7572536F757263655F222B432B225F222B65297D636F6E737420743D653D3E7B462E7075736828652E6964293B636F6E737420743D492E6765745374796C6528292E6C61796572732E66696C746572282866756E6374696F6E2865297B726574';
wwv_flow_imp.g_varchar2_table(368) := '75726E226D6574616461746122696E20652626226C617965725F73657175656E636522696E20652E6D657461646174617D29292E6D6170282866756E6374696F6E2865297B72657475726E5B652E6D657461646174612E6C617965725F73657175656E63';
wwv_flow_imp.g_varchar2_table(369) := '652C652E69645D7D29293B6C657420723B69662830213D3D742E6C656E677468297B742E736F7274282828652C74293D3E655B305D2D745B305D29293B666F72286C657420653D303B653C742E6C656E6774683B652B2B29696628613C745B655D5B305D';
wwv_flow_imp.g_varchar2_table(370) := '297B723D745B655D5B315D3B627265616B7D7D492E6164644C6179657228652C72297D3B51262674287B69643A652B222D726173746572222C747970653A22726173746572222C736F757263653A2267656F726173746572536F757263655F222B432B22';
wwv_flow_imp.g_varchar2_table(371) := '5F222B652C6C61796F75743A7B7669736962696C6974793A226E6F6E65227D2C7061696E743A7B227261737465722D726573616D706C696E67223A226E656172657374227D2C6D657461646174613A7B6C617965725F73657175656E63653A617D7D292C';
wwv_flow_imp.g_varchar2_table(372) := '44262674287B69643A652B222D68696C6C7368616465222C747970653A2268696C6C7368616465222C736F757263653A2267656F72617374657244454D536F757263655F222B432B225F222B652C6C61796F75743A7B7669736962696C6974793A226E6F';
wwv_flow_imp.g_varchar2_table(373) := '6E65227D2C7061696E743A7B2268696C6C73686164652D657861676765726174696F6E223A2E327D2C6D657461646174613A7B6C617965725F73657175656E63653A617D7D292C4E262674287B69643A652B222D72656C696566222C747970653A22636F';
wwv_flow_imp.g_varchar2_table(374) := '6C6F722D72656C696566222C736F757263653A2267656F72617374657244454D536F757263655F222B432B225F222B652C6C61796F75743A7B7669736962696C6974793A226E6F6E65227D2C7061696E743A7B22636F6C6F722D72656C6965662D6F7061';
wwv_flow_imp.g_varchar2_table(375) := '63697479223A693F3F317D2C6D657461646174613A7B6C617965725F73657175656E63653A617D7D292C7A26262874287B69643A652B222D636F6E746F75722D6C696E6573222C747970653A226C696E65222C736F757263653A2267656F726173746572';
wwv_flow_imp.g_varchar2_table(376) := '436F6E746F7572536F757263655F222B432B225F222B652C22736F757263652D6C61796572223A22636F6E746F757273222C7061696E743A7B226C696E652D636F6C6F72223A5B226D61746368222C5B22676574222C226C6576656C225D2C322C22626C';
wwv_flow_imp.g_varchar2_table(377) := '61636B222C2223333333225D2C226C696E652D7769647468223A5B226D61746368222C5B22676574222C226C6576656C225D2C322C312C312C312C2E355D7D7D292C74287B69643A652B222D636F6E746F75722D6C6162656C73222C747970653A227379';
wwv_flow_imp.g_varchar2_table(378) := '6D626F6C222C736F757263653A2267656F726173746572436F6E746F7572536F757263655F222B432B225F222B652C22736F757263652D6C61796572223A22636F6E746F757273222C66696C7465723A5B223D3D222C5B22676574222C226C6576656C22';
wwv_flow_imp.g_varchar2_table(379) := '5D2C325D2C6C61796F75743A7B22746578742D6669656C64223A5B22636F6E636174222C5B226E756D6265722D666F726D6174222C5B22676574222C22656C65225D2C7B7D5D2C2227225D2C22746578742D666F6E74223A5B224E6F746F2053616E7320';
wwv_flow_imp.g_varchar2_table(380) := '426F6C64225D2C22746578742D73697A65223A31302C2273796D626F6C2D706C6163656D656E74223A226C696E65222C2273796D626F6C2D73706163696E67223A3230302C22746578742D6D61782D616E676C65223A3336302C22746578742D726F7461';
wwv_flow_imp.g_varchar2_table(381) := '74696F6E2D616C69676E6D656E74223A2276696577706F7274227D2C7061696E743A7B22746578742D636F6C6F72223A22626C61636B222C22746578742D68616C6F2D636F6C6F72223A227768697465222C22746578742D68616C6F2D7769647468223A';
wwv_flow_imp.g_varchar2_table(382) := '317D7D29292C702E696E636C75646573282233642229262628772835292626492E73657443656E746572436C616D706564546F47726F756E64282131292C73652626492E72656D6F7665436F6E74726F6C287365292C73653D6E6577206D61706C696272';
wwv_flow_imp.g_varchar2_table(383) := '65676C2E5465727261696E436F6E74726F6C287B736F757263653A2267656F72617374657244454D3364536F757263655F222B432B225F222B652C657861676765726174696F6E3A7061727365466C6F617428643F3F31297D292C492E616464436F6E74';
wwv_flow_imp.g_varchar2_table(384) := '726F6C28736529292C616528297D3B6F6528292C6B3F6D61706C69627265676C2E61646450726F746F636F6C282267656F7261737465725F222B652C2828652C74293D3E2874652865292E7468656E2828653D3E7B74286E756C6C2C652E646174612C6E';
wwv_flow_imp.g_varchar2_table(385) := '756C6C2C6E756C6C297D29292E63617463682828653D3E7B742865297D29292C7B63616E63656C3A28293D3E7B7D7D2929293A6D61706C69627265676C2E61646450726F746F636F6C282267656F7261737465725F222B652C286173796E6328652C7429';
wwv_flow_imp.g_varchar2_table(386) := '3D3E617761697420746528652929293B636F6E73742069653D28293D3E7B783D2276697369626C65222C616528292C617065782E73746F726167652E736574436F6F6B696528224D6170626974735F47656F5261737465724C617965725F222B652B225F';
wwv_flow_imp.g_varchar2_table(387) := '222B2476282270496E7374616E636522292C2276697369626C6522292C617065782E6576656E742E74726967676572282223222B652C227669736962696C6974795F746F67676C6564222C7B76697369626C653A21307D292C492E747269676765725265';
wwv_flow_imp.g_varchar2_table(388) := '7061696E7428297D2C6C653D28293D3E7B783D226E6F6E65222C616528292C617065782E73746F726167652E736574436F6F6B696528224D6170626974735F47656F5261737465724C617965725F222B652B225F222B2476282270496E7374616E636522';
wwv_flow_imp.g_varchar2_table(389) := '292C226E6F6E6522292C617065782E6576656E742E74726967676572282223222B652C227669736962696C6974795F746F67676C6564222C7B76697369626C653A21317D297D2C63653D24282223222B722B225F6C6567656E6422293B6966282428273C';
wwv_flow_imp.g_varchar2_table(390) := '64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E27292E617070656E64282428273C696E70757420747970653D22636865636B62';
wwv_flow_imp.g_varchar2_table(391) := '6F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22223E27292E70726F70287B69643A652B225F6C6567656E645F656E747279222C636865636B65643A22';
wwv_flow_imp.g_varchar2_table(392) := '6E6F6E6522213D3D787D292E6F6E28226368616E6765222C28653D3E7B617065782E6A517565727928652E746172676574292E697328223A636865636B656422293F696528293A6C6528297D29292E637373287B222D2D612D6D61702D6C6567656E642D';
wwv_flow_imp.g_varchar2_table(393) := '73656C6563746F722D636F6C6F72223A6E7D292C2428273C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C223E27292E70726F70287B69643A652B225F6C6567656E645F656E7472795F6C6162656C222C666F';
wwv_flow_imp.g_varchar2_table(394) := '723A652B225F6C6567656E645F656E747279227D292E617070656E6428732C2428273C7370616E20636C6173733D2266612066612D636972636C652D372D382066612D616E696D2D7370696E22207374796C653D22646973706C61793A206E6F6E653B20';
wwv_flow_imp.g_varchar2_table(395) := '6D617267696E2D6C6566743A202E35656D3B223E27292E70726F7028226964222C652B225F6C6567656E645F656E7472795F737461747573222929292E617070656E64546F286365292C617065782E6974656D2E63726561746528652C7B73686F773A28';
wwv_flow_imp.g_varchar2_table(396) := '293D3E7B696528292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C2130297D2C686964653A28293D3E7B6C6528292C617065782E6A5175657279282223222B652B225F6C';
wwv_flow_imp.g_varchar2_table(397) := '6567656E645F656E74727922292E70726F702822636865636B6564222C2131297D2C697356697369626C653A28293D3E226E6F6E6522213D3D782C726566726573683A6173796E6328293D3E7B6966286177616974207128292C582E636C65617228292C';
wwv_flow_imp.g_varchar2_table(398) := '726528292C7728352C352C302929666F7228636F6E73742065206F66206A29492E7265667265736854696C65732865293B656C73657B666F7228636F6E73742065206F66204629492E72656D6F76654C617965722865293B666F7228636F6E7374206520';
wwv_flow_imp.g_varchar2_table(399) := '6F66206A29492E72656D6F7665536F757263652865293B6F6528297D7D2C746F67676C655261737465724C617965723A653D3E7B4D3D766F696420303D3D3D653F214D3A21652C616528297D2C746F67676C6548696C6C73686164654C617965723A653D';
wwv_flow_imp.g_varchar2_table(400) := '3E7B533D766F696420303D3D3D653F21533A21652C616528297D2C746F67676C65436F6E746F75724C617965723A653D3E7B523D766F696420303D3D3D653F21523A21652C616528297D2C7175657279506978656C3A6173796E6328652C742C723D3139';
wwv_flow_imp.g_varchar2_table(401) := '293D3E7B636F6E737420613D6228722C65292C733D66756E6374696F6E28652C74297B72657475726E204D6174682E706F7728322C65292A2828742B313830292F333630297D28722C74292C6E3D6177616974204A28722C4D6174682E666C6F6F722873';
wwv_flow_imp.g_varchar2_table(402) := '292C4D6174682E666C6F6F72286129293B6966286E2E63656C6C64617461297B636F6E737420653D6E6577204461746156696577286E2E63656C6C64617461292C743D6E2E63656C6C64657074682F382C723D6E2E62616E64636F756E742A742C6F3D5B';
wwv_flow_imp.g_varchar2_table(403) := '5D2C693D4D6174682E666C6F6F72287325312A6E2E7769647468292C6C3D4D6174682E666C6F6F72286125312A6E2E686569676874292A6E2E77696474682B693B666F72286C657420613D303B613C6E2E62616E64636F756E743B612B2B29383D3D6E2E';
wwv_flow_imp.g_varchar2_table(404) := '63656C6C64657074683F6F2E7075736828652E67657455696E7438286C2A722B612A7429293A33323D3D6E2E63656C6C646570746826266F2E7075736828652E676574466C6F61743332286C2A722B612A7429293B72657475726E206F7D72657475726E';
wwv_flow_imp.g_varchar2_table(405) := '206E756C6C7D7D292C6520696E204D4150424954535F47454F5241535445525F57414954494E47297B636F6E737420743D617065782E6974656D2865293B4D4150424954535F47454F5241535445525F57414954494E475B655D2E666F72456163682828';
wwv_flow_imp.g_varchar2_table(406) := '653D3E6528742929297D4D4150424954535F47454F5241535445525F57414954494E475B655D3D6E756C6C7D';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(72356168070937850)
,p_plugin_id=>wwv_flow_imp.id(43394131106713264)
,p_file_name=>'mapbits_georaster.min.js'
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
