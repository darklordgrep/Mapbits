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
--   Date and Time:   10:00 Tuesday January 27, 2026
--   Exported By:     GREP
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 292702662324612235
--   Manifest End
--   Version:         23.2.0
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/mil_army_usace_mapbits_layer_georaster
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(292702662324612235)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'MIL.ARMY.USACE.MAPBITS.LAYER.GEORASTER'
,p_display_name=>'Mapbits GeoRaster Layer'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits_georaster#MIN#.js'
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
'procedure map_georaster_info_svc(p_geor in out sdo_georaster, p_item_id in varchar2, p_layer_type in varchar2) is',
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
'    apex_json.open_object();',
'    apex_json.write(''itemid'', p_item_id);',
'    apex_json.write(''maxpyramidlevel'', l_pyramid_level);',
'    apex_json.write(''bandcount'', l_nbands);',
'    apex_json.write(''celldepth'', l_cellDepth);',
'    apex_json.write(''height'', l_dims(2));',
'    apex_json.write(''width'', l_dims(1));',
'',
'    -- if we are rendering color-relief for a DEM, we need to get a range of values, excluding ''NoData''',
'    if p_layer_type = ''color-relief'' or p_layer_type = ''hillshade_color_relief'' then',
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
'  l_bgvalues sdo_number_array;',
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
'    -- Perform the reprojection',
'    if l_celldepth = 8 then ',
'       l_bgtoks := apex_string.split(p_bg, '','');',
'       l_bgvalues := sdo_number_array(l_bgtoks(1), l_bgtoks(2), l_bgtoks(3));',
'    else',
'      l_bgvalues := sdo_number_array(-99999);',
'    end if;',
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
'  l_layer_type p_item.attribute_07%type := p_item.attribute_07;',
'begin',
'  georas(l_source_proc, l_submit_items, l_grid);',
'',
'  if l_grid is null then',
'    htp.p(''{"noRaster":true}'');',
'    return;',
'  end if;',
'',
'  if apex_application.g_x01 = 0 then -- info request',
'    map_georaster_info_svc(l_grid, p_item.name, l_layer_type);',
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
'  l_layer_type p_item.attribute_07%type := p_item.attribute_07;',
'  l_color_ramp p_item.attribute_08%type := p_item.attribute_08;',
'  l_exaggeration p_item.attribute_09%type := p_item.attribute_09;',
'  l_bgcolor p_item.attribute_10%type := p_item.attribute_10;',
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
'        || ''p_color_ramp: ('' || nvl(l_color_ramp, ''null'') || ''),''',
'      || ''});',
'    });',
'  '');',
'end;'))
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'map_georaster_render'
,p_ajax_function=>'map_georaster_ajax'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'The Mapbits GeoRaster Layer plugin adds support for Oracle GeoRasters without the need for middleware services. Add this plugin as an item under an APEX Map region. Define a single-row SQL query that returns a single column of type sdo_georaster and '
||'that raster shall be rendered in the associated Map Region. Currently, only DEM (single band, 32-bit float) and RGB (three band, 8-bit unsigned integer) rasters are supported. No compression is supported at this time. For best results, rasters should'
||' be projected to the Web Mercator coordinate reference system (EPSG:3857). Rasters referenced to other coordinate references system may have some degree of distortion.'
,p_version_identifier=>'4.9.20260127'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - GeoRaster Layer',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_georaster.sql 21363 2026-01-27 16:01:54Z b2imimcf $',
'Date     : $Date: 2026-01-27 10:01:54 -0600 (Tue, 27 Jan 2026) $',
'Revision : $Revision: 21363 $',
'Requires : Application Express >= 23.2',
'',
'Version 4.9 Updates',
'01/27/2026 Changing name from Georaster to GeoRaster ',
'01/15/2026 Implemented transparency for background pixels. Added attribute to select color value to use for background pixel values.',
'06/11/2025 Implemented show/hide and isVisible API.',
'02/11/2025 Cleared up seams between raster tiles. Added ''Page Items to Submit'' to render georasters based on page item values. Added missing icon for terrain control.',
'',
'Version 4.8 Updates',
'01/28/2025 Added warning for missing pyramids. Resized tile canvas to be square, since DEMs require square tiles. Increased buffer size for blob64 generation.',
''))
,p_files_version=>560
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(292716568406734179)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'GeoRaster Source'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'select raster from mb4_georaster where id = 1'
,p_help_text=>'SQL Query returning one row of one column containing data type sdo_georaster.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(294281610787947538)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Name of layer to be displayed in the Legend, the toggle section under the map used to turn layers on and off.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(294282092114949226)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Checkbox Color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#000000'
,p_is_translatable=>false
,p_help_text=>'Color of the checkbox to be displayed for this layer in the Legend, the toggle section under the map used to turn layers on and off.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(294282677192953193)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Initially Visible?'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'If ''Y'', then this layer will be turned on the first time a user visits this page, otherwise it will be off. After the initial page visit, the layer visibility will be persisted.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(228414615859987295)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Opacity (0-100)'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'100'
,p_is_translatable=>false
,p_help_text=>'Percent opacity of the raster layer. This is a value between 0 and 100. A value of 0 makes the raster completely transparent, while a value of 100 makes the raster completely opaque.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(48438696646561124)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>15
,p_prompt=>'Page Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(159286922804148080)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Layer Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'auto'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(159287899441149005)
,p_plugin_attribute_id=>wwv_flow_imp.id(159286922804148080)
,p_display_sequence=>10
,p_display_value=>'Automatic'
,p_return_value=>'auto'
,p_help_text=>'Display raster as using hillshade layer type if it is a DEM (has a 32 bit band). Otherwise, display as a raster layer type.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(159288200445149775)
,p_plugin_attribute_id=>wwv_flow_imp.id(159286922804148080)
,p_display_sequence=>20
,p_display_value=>'Imagery'
,p_return_value=>'raster'
,p_help_text=>'Display as a ''rasetr'' layer type.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(159288622314154527)
,p_plugin_attribute_id=>wwv_flow_imp.id(159286922804148080)
,p_display_sequence=>30
,p_display_value=>'Hillshade'
,p_return_value=>'hillsahde'
,p_help_text=>'Display as a ''hillshade'' layer type. Layer will display with shadow and ridge effects. This is only applicable if the source is a DEM.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(159289068426156232)
,p_plugin_attribute_id=>wwv_flow_imp.id(159286922804148080)
,p_display_sequence=>40
,p_display_value=>'Color Relief'
,p_return_value=>'color-relief'
,p_help_text=>'Display as a ''color-relief'' layer type. Colors reflect the values of the raster DEM. This is only applicable if the source is a DEM.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(159309195453455433)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Color Relief Map'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>false
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// stats is an associative array with raster attributes: ''min'', ',
'// ''max'', ''mean'', ''median'', and ''stdev''.',
'',
'function(stats) {',
'  return ["interpolate", ',
'    ["linear"], ["elevation"],',
'    stats.min, "black",',
'    stats.mean, "red",',
'    stats.max, "white"',
'  ];',
'}'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(159286922804148080)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'color-relief'
,p_help_text=>'Javascript function that takes a single input that is an associated array with raster properties: ''min'', ''max'', ''mean'', ''median'', and ''stdev'' and returns a maplibre array expression to use for the color-relief layer type''s ''color-relief-color'' value.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(186217491182613901)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Terrain Exaggeration'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'0.3048 (if source is in feet)'
,p_help_text=>'The factor to apply to elevation values'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(343659053627158552)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
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
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(53354102578194881)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_file_name=>'mapbits_georaster.css'
,p_mime_type=>'text/css'
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
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(53385218415340001)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_file_name=>'mapbits_georaster.min.css'
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
wwv_flow_imp.g_varchar2_table(7) := '61636974792C20705F7375626D69745F6974656D732C20705F6C617965725F747970652C20705F636F6C6F725F72616D702C20705F6267636F6C6F722C20705F657861676765726174696F6E2C0D0A7D29207B0D0A20202F2F20536F757263653A206874';
wwv_flow_imp.g_varchar2_table(8) := '7470733A2F2F77696B692E6F70656E7374726565746D61702E6F72672F77696B692F536C697070795F6D61705F74696C656E616D65730D0A20202F2F20436F6E766572742074696C6520636F6F7264696E6174657320287B5A7D7B587D7B597D2920746F';
wwv_flow_imp.g_varchar2_table(9) := '2067656F6772617068696320636F6F7264696E617465732E0D0A2020636F6E73742064656732726164203D202864656729203D3E204D6174682E5049202A20646567202F203138303B0D0A202066756E6374696F6E2074696C65326C6F6E6728782C207A';
wwv_flow_imp.g_varchar2_table(10) := '29207B0D0A2020202072657475726E202878202F204D6174682E706F7728322C207A29202A20333630202D20313830293B0D0A20207D0D0A202066756E6374696F6E2074696C65326C617428792C207A29207B0D0A20202020636F6E7374206E203D204D';
wwv_flow_imp.g_varchar2_table(11) := '6174682E5049202D2032202A204D6174682E5049202A2079202F204D6174682E706F7728322C207A293B0D0A2020202072657475726E2028313830202F204D6174682E5049202A204D6174682E6174616E28302E35202A20284D6174682E657870286E29';
wwv_flow_imp.g_varchar2_table(12) := '202D204D6174682E657870282D6E292929293B0D0A20207D0D0A202066756E6374696F6E206C61743274696C65287A2C206C617429207B0D0A20202020636F6E7374206E203D204D6174682E706F7728322C207A293B0D0A20202020636F6E7374206C61';
wwv_flow_imp.g_varchar2_table(13) := '74526164203D2064656732726164286C6174293B0D0A2020202072657475726E206E202A202831202D20284D6174682E6C6F67284D6174682E74616E286C617452616429202B202831202F204D6174682E636F73286C6174526164292929202F204D6174';
wwv_flow_imp.g_varchar2_table(14) := '682E50492929202F20323B0D0A20207D0D0A202066756E6374696F6E206C6F6E3274696C65287A2C206C6F6E29207B0D0A20202020636F6E7374206E203D204D6174682E706F7728322C207A293B0D0A2020202072657475726E206E202A2028286C6F6E';
wwv_flow_imp.g_varchar2_table(15) := '202B2031383029202F20333630293B0D0A20207D0D0A2020636F6E7374206D61706C696276657273696F6E203D20286D61706C69627265676C2E67657456657273696F6E203F206D61706C69627265676C2E67657456657273696F6E2829203A206D6170';
wwv_flow_imp.g_varchar2_table(16) := '6C69627265676C2E76657273696F6E292E73706C697428272E27292E6D61702878203D3E207061727365496E74287829293B0D0A2020636F6E73742070726F746F43616C6C6261636B203D206D61706C696276657273696F6E5B305D203C20343B0D0A20';
wwv_flow_imp.g_varchar2_table(17) := '20636F6E7374206D6C436F6C6F7252656C696566203D206D61706C696276657273696F6E203E205B352C20365D3B0D0A2020636F6E7374206D6C437573746F6D456E636F64696E67203D206D61706C696276657273696F6E203E205B332C20345D3B0D0A';
wwv_flow_imp.g_varchar2_table(18) := '0D0A20202F2F2047657420746865206D61706C69627265206D6170206F626A65637420616E642067656F72617374657220696E7374616E636520636F6F6B69652E0D0A2020636F6E7374206D6170203D20617065782E726567696F6E28705F726567696F';
wwv_flow_imp.g_varchar2_table(19) := '6E5F6964292E63616C6C28226765744D61704F626A65637422293B0D0A20202F2F6D61702E73686F7754696C65426F756E646172696573203D20747275653B0D0A20206C6574206C436F6F6B6965203D20617065782E73746F726167652E676574436F6F';
wwv_flow_imp.g_varchar2_table(20) := '6B696528274D6170626974735F47656F5261737465724C617965725F27202B20705F6974656D5F6964202B20225F22202B202476282270496E7374616E6365222929207C7C2028705F696E69745F7669736962696C697479203D3D3D20275927203F2027';
wwv_flow_imp.g_varchar2_table(21) := '76697369626C6527203A20276E6F6E6527293B0D0A20206C657420686964655261737465724C61796572203D2066616C73652C206869646548696C6C73686164654C61796572203D2066616C73653B0D0A0D0A20206C65742064656D536F757263652C20';
wwv_flow_imp.g_varchar2_table(22) := '726173746572536F757263652C207261737465724C617965722C2068696C6C73686164654C617965722C2072656C6965664C617965723B0D0A20206C657420736F757263654E616D6573203D205B5D2C206C617965724E616D6573203D205B5D3B0D0A20';
wwv_flow_imp.g_varchar2_table(23) := '207377697463682028705F6C617965725F7479706529207B0D0A20202020636173652027636F6C6F722D72656C696566273A0D0A202020202020696620286D6C436F6C6F7252656C69656629207B0D0A202020202020202064656D536F75726365203D20';
wwv_flow_imp.g_varchar2_table(24) := '747275653B0D0A202020202020202072656C6965664C61796572203D20747275653B0D0A2020202020207D20656C7365207B0D0A2020202020202020726173746572536F75726365203D20747275653B0D0A20202020202020207261737465724C617965';
wwv_flow_imp.g_varchar2_table(25) := '72203D20747275653B0D0A2020202020207D0D0A202020202020627265616B3B0D0A20202020636173652027726173746572273A0D0A202020202020726173746572536F75726365203D20747275653B0D0A2020202020207261737465724C6179657220';
wwv_flow_imp.g_varchar2_table(26) := '3D20747275653B0D0A202020202020627265616B3B0D0A2020202063617365202768696C6C7368616465273A0D0A20202020202064656D536F75726365203D20747275653B0D0A20202020202068696C6C73686164654C61796572203D20747275653B0D';
wwv_flow_imp.g_varchar2_table(27) := '0A202020202020627265616B3B0D0A2020202063617365202768696C6C73686164655F636F6C6F725F72656C696566273A0D0A20202020202064656D536F75726365203D20747275653B0D0A20202020202068696C6C73686164654C61796572203D2074';
wwv_flow_imp.g_varchar2_table(28) := '7275653B0D0A202020202020696620286D6C436F6C6F7252656C69656629207B0D0A202020202020202072656C6965664C61796572203D20747275653B0D0A2020202020207D20656C7365207B0D0A2020202020202020726173746572536F7572636520';
wwv_flow_imp.g_varchar2_table(29) := '3D20747275653B0D0A20202020202020207261737465724C61796572203D20747275653B0D0A2020202020207D0D0A202020202020627265616B3B0D0A2020202064656661756C743A0D0A20202020202069662028726173746572696E666F2E63656C6C';
wwv_flow_imp.g_varchar2_table(30) := '6465707468203D3D20333229207B0D0A202020202020202064656D536F75726365203D20747275653B0D0A202020202020202068696C6C73686164654C61796572203D20747275653B0D0A2020202020207D20656C7365207B0D0A202020202020202072';
wwv_flow_imp.g_varchar2_table(31) := '6173746572536F75726365203D20747275653B0D0A20202020202020207261737465724C61796572203D20747275653B0D0A2020202020207D0D0A202020202020627265616B3B0D0A20207D0D0A0D0A2020636F6E7374207061727365436F6C6F72203D';
wwv_flow_imp.g_varchar2_table(32) := '20286329203D3E207B0D0A202020206C6574206D617463683B0D0A202020206966202841727261792E6973417272617928632920262620632E6C656E677468203D3D3D203329207B0D0A20202020202072657475726E205B2E2E2E632C203235355D3B0D';
wwv_flow_imp.g_varchar2_table(33) := '0A202020207D20656C7365206966202841727261792E6973417272617928632920262620632E6C656E677468203D3D3D203429207B0D0A20202020202072657475726E20633B0D0A202020207D20656C73652069662028286D61746368203D20632E6D61';
wwv_flow_imp.g_varchar2_table(34) := '746368282F5E23285B412D46612D66302D395D7B367D29242F292929207B0D0A2020202020202F2F20726567756C61722068657820666F726D61740D0A20202020202072657475726E205B0D0A20202020202020207061727365496E74286D617463685B';
wwv_flow_imp.g_varchar2_table(35) := '315D2E73756273747228302C2032292C203136292C0D0A20202020202020207061727365496E74286D617463685B315D2E73756273747228322C2032292C203136292C0D0A20202020202020207061727365496E74286D617463685B315D2E7375627374';
wwv_flow_imp.g_varchar2_table(36) := '7228342C2032292C203136292C0D0A20202020202020203235352C0D0A2020202020205D3B0D0A202020207D20656C73652069662028286D61746368203D20632E6D61746368282F5E23285B412D46612D66302D395D7B337D29242F292929207B0D0A20';
wwv_flow_imp.g_varchar2_table(37) := '20202020202F2F2073686F727465722068657820666F726D61740D0A20202020202072657475726E205B0D0A20202020202020207061727365496E74286D617463685B315D5B305D2C20313629202A20307831312C0D0A20202020202020207061727365';
wwv_flow_imp.g_varchar2_table(38) := '496E74286D617463685B315D5B315D2C20313629202A20307831312C0D0A20202020202020207061727365496E74286D617463685B315D5B325D2C20313629202A20307831312C0D0A20202020202020203235352C0D0A2020202020205D3B0D0A202020';
wwv_flow_imp.g_varchar2_table(39) := '207D20656C73652069662028286D61746368203D20632E6D61746368282F5E23285B412D46612D66302D395D7B387D29242F292929207B0D0A2020202020202F2F20726567756C61722068657820666F726D6174207769746820616C7068610D0A202020';
wwv_flow_imp.g_varchar2_table(40) := '20202072657475726E205B0D0A20202020202020207061727365496E74286D617463685B315D2E73756273747228302C2032292C203136292C0D0A20202020202020207061727365496E74286D617463685B315D2E73756273747228322C2032292C2031';
wwv_flow_imp.g_varchar2_table(41) := '36292C0D0A20202020202020207061727365496E74286D617463685B315D2E73756273747228342C2032292C203136292C0D0A20202020202020207061727365496E74286D617463685B315D2E73756273747228362C2032292C203136292C0D0A202020';
wwv_flow_imp.g_varchar2_table(42) := '2020205D3B0D0A202020207D20656C73652069662028286D61746368203D20632E6D61746368282F5E23285B412D46612D66302D395D7B347D29242F292929207B0D0A2020202020202F2F2073686F727465722068657820666F726D6174207769746820';
wwv_flow_imp.g_varchar2_table(43) := '616C7068610D0A20202020202072657475726E205B0D0A20202020202020207061727365496E74286D617463685B315D5B305D2C20313629202A20307831312C0D0A20202020202020207061727365496E74286D617463685B315D5B315D2C2031362920';
wwv_flow_imp.g_varchar2_table(44) := '2A20307831312C0D0A20202020202020207061727365496E74286D617463685B315D5B325D2C20313629202A20307831312C0D0A20202020202020207061727365496E74286D617463685B315D5B325D2C20313629202A20307831312C0D0A2020202020';
wwv_flow_imp.g_varchar2_table(45) := '205D3B0D0A202020207D20656C7365207B0D0A20202020202072657475726E206E756C6C3B0D0A202020207D0D0A20207D3B0D0A0D0A20206C6574206261636B67726F756E64436F6C6F72203D207061727365436F6C6F7228705F6267636F6C6F72203F';
wwv_flow_imp.g_varchar2_table(46) := '3F20272330303030303027293B0D0A20206C657420636F6C6F7252616D703B0D0A2020636F6E73742072656672657368436F6C6F7252616D70203D202829203D3E207B0D0A2020202069662028215B27636F6C6F722D72656C696566272C202768696C6C';
wwv_flow_imp.g_varchar2_table(47) := '73686164655F636F6C6F725F72656C696566275D2E696E636C7564657328705F6C617965725F7479706529207C7C20726173746572696E666F2E6E6F52617374657229207B0D0A20202020202072657475726E3B0D0A202020207D0D0A0D0A2020202063';
wwv_flow_imp.g_varchar2_table(48) := '6F6C6F7252616D70203D20705F636F6C6F725F72616D703B0D0A0D0A202020206966202821636F6C6F7252616D7029207B0D0A202020202020636F6C6F7252616D70203D205B2723663365373962272C202723666163343834272C202723663861303765';
wwv_flow_imp.g_varchar2_table(49) := '272C202723656237663836272C202723636536363933272C202723613035396130272C202723356335336135275D3B0D0A202020207D0D0A0D0A20202020636F6E7374206275696C74696E203D207B0D0A2020202020202F2F2046726F6D203C68747470';
wwv_flow_imp.g_varchar2_table(50) := '733A2F2F676973742E6769746875622E636F6D2F6D696B6861696C6F762D776F726B2F65653732626134313931393432616365636330336665366461393466633733663E2E204170616368652D322E302E0D0A202020202020747572626F3A205B5B302E';
wwv_flow_imp.g_varchar2_table(51) := '31383939352C302E30373137362C302E32333231375D2C5B302E31393438332C302E30383333392C302E32363134395D2C5B302E31393935362C302E30393439382C302E32393032345D2C5B302E32303431352C302E31303635322C302E33313834345D';
wwv_flow_imp.g_varchar2_table(52) := '2C5B302E32303836302C302E31313830322C302E33343630375D2C5B302E32313239312C302E31323934372C302E33373331345D2C5B302E32313730382C302E31343038372C302E33393936345D2C5B302E32323131312C302E31353232332C302E3432';
wwv_flow_imp.g_varchar2_table(53) := '3535385D2C5B302E32323530302C302E31363335342C302E34353039365D2C5B302E32323837352C302E31373438312C302E34373537385D2C5B302E32333233362C302E31383630332C302E35303030345D2C5B302E32333538322C302E31393732302C';
wwv_flow_imp.g_varchar2_table(54) := '302E35323337335D2C5B302E32333931352C302E32303833332C302E35343638365D2C5B302E32343233342C302E32313934312C302E35363934325D2C5B302E32343533392C302E32333034342C302E35393134325D2C5B302E32343833302C302E3234';
wwv_flow_imp.g_varchar2_table(55) := '3134332C302E36313238365D2C5B302E32353130372C302E32353233372C302E36333337345D2C5B302E32353336392C302E32363332372C302E36353430365D2C5B302E32353631382C302E32373431322C302E36373338315D2C5B302E32353835332C';
wwv_flow_imp.g_varchar2_table(56) := '302E32383439322C302E36393330305D2C5B302E32363037342C302E32393536382C302E37313136325D2C5B302E32363238302C302E33303633392C302E37323936385D2C5B302E32363437332C302E33313730362C302E37343731385D2C5B302E3236';
wwv_flow_imp.g_varchar2_table(57) := '3635322C302E33323736382C302E37363431325D2C5B302E32363831362C302E33333832352C302E37383035305D2C5B302E32363936372C302E33343837382C302E37393633315D2C5B302E32373130332C302E33353932362C302E38313135365D2C5B';
wwv_flow_imp.g_varchar2_table(58) := '302E32373232362C302E33363937302C302E38323632345D2C5B302E32373333342C302E33383030382C302E38343033375D2C5B302E32373432392C302E33393034332C302E38353339335D2C5B302E32373530392C302E34303037322C302E38363639';
wwv_flow_imp.g_varchar2_table(59) := '325D2C5B302E32373537362C302E34313039372C302E38373933365D2C5B302E32373632382C302E34323131382C302E38393132335D2C5B302E32373636372C302E34333133342C302E39303235345D2C5B302E32373639312C302E34343134352C302E';
wwv_flow_imp.g_varchar2_table(60) := '39313332385D2C5B302E32373730312C302E34353135322C302E39323334375D2C5B302E32373639382C302E34363135332C302E39333330395D2C5B302E32373638302C302E34373135312C302E39343231345D2C5B302E32373634382C302E34383134';
wwv_flow_imp.g_varchar2_table(61) := '342C302E39353036345D2C5B302E32373630332C302E34393133322C302E39353835375D2C5B302E32373534332C302E35303131352C302E39363539345D2C5B302E32373436392C302E35313039342C302E39373237355D2C5B302E32373338312C302E';
wwv_flow_imp.g_varchar2_table(62) := '35323036392C302E39373839395D2C5B302E32373237332C302E35333034302C302E39383436315D2C5B302E32373130362C302E35343031352C302E39383933305D2C5B302E32363837382C302E35343939352C302E39393330335D2C5B302E32363539';
wwv_flow_imp.g_varchar2_table(63) := '322C302E35353937392C302E39393538335D2C5B302E32363235322C302E35363936372C302E39393737335D2C5B302E32353836322C302E35373935382C302E39393837365D2C5B302E32353432352C302E35383935302C302E39393839365D2C5B302E';
wwv_flow_imp.g_varchar2_table(64) := '32343934362C302E35393934332C302E39393833355D2C5B302E32343432372C302E36303933372C302E39393639375D2C5B302E32333837342C302E36313933312C302E39393438355D2C5B302E32333238382C302E36323932332C302E39393230325D';
wwv_flow_imp.g_varchar2_table(65) := '2C5B302E32323637362C302E36333931332C302E39383835315D2C5B302E32323033392C302E36343930312C302E39383433365D2C5B302E32313338322C302E36353838362C302E39373935395D2C5B302E32303730382C302E36363836362C302E3937';
wwv_flow_imp.g_varchar2_table(66) := '3432335D2C5B302E32303032312C302E36373834322C302E39363833335D2C5B302E31393332362C302E36383831322C302E39363139305D2C5B302E31383632352C302E36393737352C302E39353439385D2C5B302E31373932332C302E37303733322C';
wwv_flow_imp.g_varchar2_table(67) := '302E39343736315D2C5B302E31373232332C302E37313638302C302E39333938315D2C5B302E31363532392C302E37323632302C302E39333136315D2C5B302E31353834342C302E37333535312C302E39323330355D2C5B302E31353137332C302E3734';
wwv_flow_imp.g_varchar2_table(68) := '3437322C302E39313431365D2C5B302E31343531392C302E37353338312C302E39303439365D2C5B302E31333838362C302E37363237392C302E38393535305D2C5B302E31333237382C302E37373136352C302E38383538305D2C5B302E31323639382C';
wwv_flow_imp.g_varchar2_table(69) := '302E37383033372C302E38373539305D2C5B302E31323135312C302E37383839362C302E38363538315D2C5B302E31313633392C302E37393734302C302E38353535395D2C5B302E31313136372C302E38303536392C302E38343532355D2C5B302E3130';
wwv_flow_imp.g_varchar2_table(70) := '3733382C302E38313338312C302E38333438345D2C5B302E31303335372C302E38323137372C302E38323433375D2C5B302E31303032362C302E38323935352C302E38313338395D2C5B302E30393735302C302E38333731342C302E38303334325D2C5B';
wwv_flow_imp.g_varchar2_table(71) := '302E30393533322C302E38343435352C302E37393239395D2C5B302E30393337372C302E38353137352C302E37383236345D2C5B302E30393238372C302E38353837352C302E37373234305D2C5B302E30393236372C302E38363535342C302E37363233';
wwv_flow_imp.g_varchar2_table(72) := '305D2C5B302E30393332302C302E38373231312C302E37353233375D2C5B302E30393435312C302E38373834342C302E37343236355D2C5B302E30393636322C302E38383435342C302E37333331365D2C5B302E30393935382C302E38393034302C302E';
wwv_flow_imp.g_varchar2_table(73) := '37323339335D2C5B302E31303334322C302E38393630302C302E37313530305D2C5B302E31303831352C302E39303134322C302E37303539395D2C5B302E31313337342C302E39303637332C302E36393635315D2C5B302E31323031342C302E39313139';
wwv_flow_imp.g_varchar2_table(74) := '332C302E36383636305D2C5B302E31323733332C302E39313730312C302E36373632375D2C5B302E31333532362C302E39323139372C302E36363535365D2C5B302E31343339312C302E39323638302C302E36353434385D2C5B302E31353332332C302E';
wwv_flow_imp.g_varchar2_table(75) := '39333135312C302E36343330385D2C5B302E31363331392C302E39333630392C302E36333133375D2C5B302E31373337372C302E39343035332C302E36313933385D2C5B302E31383439312C302E39343438342C302E36303731335D2C5B302E31393635';
wwv_flow_imp.g_varchar2_table(76) := '392C302E39343930312C302E35393436365D2C5B302E32303837372C302E39353330342C302E35383139395D2C5B302E32323134322C302E39353639322C302E35363931345D2C5B302E32333434392C302E39363036352C302E35353631345D2C5B302E';
wwv_flow_imp.g_varchar2_table(77) := '32343739372C302E39363432332C302E35343330335D2C5B302E32363138302C302E39363736352C302E35323938315D2C5B302E32373539372C302E39373039322C302E35313635335D2C5B302E32393034322C302E39373430332C302E35303332315D';
wwv_flow_imp.g_varchar2_table(78) := '2C5B302E33303531332C302E39373639372C302E34383938375D2C5B302E33323030362C302E39373937342C302E34373635345D2C5B302E33333531372C302E39383233342C302E34363332355D2C5B302E33353034332C302E39383437372C302E3435';
wwv_flow_imp.g_varchar2_table(79) := '3030325D2C5B302E33363538312C302E39383730322C302E34333638385D2C5B302E33383132372C302E39383930392C302E34323338365D2C5B302E33393637382C302E39393039382C302E34313039385D2C5B302E34313232392C302E39393236382C';
wwv_flow_imp.g_varchar2_table(80) := '302E33393832365D2C5B302E34323737382C302E39393431392C302E33383537355D2C5B302E34343332312C302E39393535312C302E33373334355D2C5B302E34353835342C302E39393636332C302E33363134305D2C5B302E34373337352C302E3939';
wwv_flow_imp.g_varchar2_table(81) := '3735352C302E33343936335D2C5B302E34383837392C302E39393832382C302E33333831365D2C5B302E35303336322C302E39393837392C302E33323730315D2C5B302E35313832322C302E39393931302C302E33313632325D2C5B302E35333235352C';
wwv_flow_imp.g_varchar2_table(82) := '302E39393931392C302E33303538315D2C5B302E35343635382C302E39393930372C302E32393538315D2C5B302E35363032362C302E39393837332C302E32383632335D2C5B302E35373335372C302E39393831372C302E32373731325D2C5B302E3538';
wwv_flow_imp.g_varchar2_table(83) := '3634362C302E39393733392C302E32363834395D2C5B302E35393839312C302E39393633382C302E32363033385D2C5B302E36313038382C302E39393531342C302E32353238305D2C5B302E36323233332C302E39393336362C302E32343537395D2C5B';
wwv_flow_imp.g_varchar2_table(84) := '302E36333332332C302E39393139352C302E32333933375D2C5B302E36343336322C302E39383939392C302E32333335365D2C5B302E36353339342C302E39383737352C302E32323833355D2C5B302E36363432382C302E39383532342C302E32323337';
wwv_flow_imp.g_varchar2_table(85) := '305D2C5B302E36373436322C302E39383234362C302E32313936305D2C5B302E36383439342C302E39373934312C302E32313630325D2C5B302E36393532352C302E39373631302C302E32313239345D2C5B302E37303535332C302E39373235352C302E';
wwv_flow_imp.g_varchar2_table(86) := '32313033325D2C5B302E37313537372C302E39363837352C302E32303831355D2C5B302E37323539362C302E39363437302C302E32303634305D2C5B302E37333631302C302E39363034332C302E32303530345D2C5B302E37343631372C302E39353539';
wwv_flow_imp.g_varchar2_table(87) := '332C302E32303430365D2C5B302E37353631372C302E39353132312C302E32303334335D2C5B302E37363630382C302E39343632372C302E32303331315D2C5B302E37373539312C302E39343131332C302E32303331305D2C5B302E37383536332C302E';
wwv_flow_imp.g_varchar2_table(88) := '39333537392C302E32303333365D2C5B302E37393532342C302E39333032352C302E32303338365D2C5B302E38303437332C302E39323435322C302E32303435395D2C5B302E38313431302C302E39313836312C302E32303535325D2C5B302E38323333';
wwv_flow_imp.g_varchar2_table(89) := '332C302E39313235332C302E32303636335D2C5B302E38333234312C302E39303632372C302E32303738385D2C5B302E38343133332C302E38393938362C302E32303932365D2C5B302E38353031302C302E38393332382C302E32313037345D2C5B302E';
wwv_flow_imp.g_varchar2_table(90) := '38353836382C302E38383635352C302E32313233305D2C5B302E38363730392C302E38373936382C302E32313339315D2C5B302E38373533302C302E38373236372C302E32313535355D2C5B302E38383333312C302E38363535332C302E32313731395D';
wwv_flow_imp.g_varchar2_table(91) := '2C5B302E38393131322C302E38353832362C302E32313838305D2C5B302E38393837302C302E38353038372C302E32323033385D2C5B302E39303630352C302E38343333372C302E32323138385D2C5B302E39313331372C302E38333537362C302E3232';
wwv_flow_imp.g_varchar2_table(92) := '3332385D2C5B302E39323030342C302E38323830362C302E32323435365D2C5B302E39323636362C302E38323032352C302E32323537305D2C5B302E39333330312C302E38313233362C302E32323636375D2C5B302E39333930392C302E38303433392C';
wwv_flow_imp.g_varchar2_table(93) := '302E32323734345D2C5B302E39343438392C302E37393633342C302E32323830305D2C5B302E39353033392C302E37383832332C302E32323833315D2C5B302E39353536302C302E37383030352C302E32323833365D2C5B302E39363034392C302E3737';
wwv_flow_imp.g_varchar2_table(94) := '3138312C302E32323831315D2C5B302E39363530372C302E37363335322C302E32323735345D2C5B302E39363933312C302E37353531392C302E32323636335D2C5B302E39373332332C302E37343638322C302E32323533365D2C5B302E39373637392C';
wwv_flow_imp.g_varchar2_table(95) := '302E37333834322C302E32323336395D2C5B302E39383030302C302E37333030302C302E32323136315D2C5B302E39383238392C302E37323134302C302E32313931385D2C5B302E39383534392C302E37313235302C302E32313635305D2C5B302E3938';
wwv_flow_imp.g_varchar2_table(96) := '3738312C302E37303333302C302E32313335385D2C5B302E39383938362C302E36393338322C302E32313034335D2C5B302E39393136332C302E36383430382C302E32303730365D2C5B302E39393331342C302E36373430382C302E32303334385D2C5B';
wwv_flow_imp.g_varchar2_table(97) := '302E39393433382C302E36363338362C302E31393937315D2C5B302E39393533352C302E36353334312C302E31393537375D2C5B302E39393630372C302E36343237372C302E31393136355D2C5B302E39393635342C302E36333139332C302E31383733';
wwv_flow_imp.g_varchar2_table(98) := '385D2C5B302E39393637352C302E36323039332C302E31383239375D2C5B302E39393637322C302E36303937372C302E31373834325D2C5B302E39393634342C302E35393834362C302E31373337365D2C5B302E39393539332C302E35383730332C302E';
wwv_flow_imp.g_varchar2_table(99) := '31363839395D2C5B302E39393531372C302E35373534392C302E31363431325D2C5B302E39393431392C302E35363338362C302E31353931385D2C5B302E39393239372C302E35353231342C302E31353431375D2C5B302E39393135332C302E35343033';
wwv_flow_imp.g_varchar2_table(100) := '362C302E31343931305D2C5B302E39383938372C302E35323835342C302E31343339385D2C5B302E39383739392C302E35313636372C302E31333838335D2C5B302E39383539302C302E35303437392C302E31333336375D2C5B302E39383336302C302E';
wwv_flow_imp.g_varchar2_table(101) := '34393239312C302E31323834395D2C5B302E39383130382C302E34383130342C302E31323333325D2C5B302E39373833372C302E34363932302C302E31313831375D2C5B302E39373534352C302E34353734302C302E31313330355D2C5B302E39373233';
wwv_flow_imp.g_varchar2_table(102) := '342C302E34343536352C302E31303739375D2C5B302E39363930342C302E34333339392C302E31303239345D2C5B302E39363535352C302E34323234312C302E30393739385D2C5B302E39363138372C302E34313039332C302E30393331305D2C5B302E';
wwv_flow_imp.g_varchar2_table(103) := '39353830312C302E33393935382C302E30383833315D2C5B302E39353339382C302E33383833362C302E30383336325D2C5B302E39343937372C302E33373732392C302E30373930355D2C5B302E39343533382C302E33363633382C302E30373436315D';
wwv_flow_imp.g_varchar2_table(104) := '2C5B302E39343038342C302E33353536362C302E30373033315D2C5B302E39333631322C302E33343531332C302E30363631365D2C5B302E39333132352C302E33333438322C302E30363231385D2C5B302E39323632332C302E33323437332C302E3035';
wwv_flow_imp.g_varchar2_table(105) := '3833375D2C5B302E39323130352C302E33313438392C302E30353437355D2C5B302E39313537322C302E33303533302C302E30353133345D2C5B302E39313032342C302E32393539392C302E30343831345D2C5B302E39303436332C302E32383639362C';
wwv_flow_imp.g_varchar2_table(106) := '302E30343531365D2C5B302E38393838382C302E32373832342C302E30343234335D2C5B302E38393239382C302E32363938312C302E30333939335D2C5B302E38383639312C302E32363135322C302E30333735335D2C5B302E38383036362C302E3235';
wwv_flow_imp.g_varchar2_table(107) := '3333342C302E30333532315D2C5B302E38373432322C302E32343532362C302E30333239375D2C5B302E38363736302C302E32333733302C302E30333038325D2C5B302E38363037392C302E32323934352C302E30323837355D2C5B302E38353338302C';
wwv_flow_imp.g_varchar2_table(108) := '302E32323137302C302E30323637375D2C5B302E38343636322C302E32313430372C302E30323438375D2C5B302E38333932362C302E32303635342C302E30323330355D2C5B302E38333137322C302E31393931322C302E30323133315D2C5B302E3832';
wwv_flow_imp.g_varchar2_table(109) := '3339392C302E31393138322C302E30313936365D2C5B302E38313630382C302E31383436322C302E30313830395D2C5B302E38303739392C302E31373735332C302E30313636305D2C5B302E37393937312C302E31373035352C302E30313532305D2C5B';
wwv_flow_imp.g_varchar2_table(110) := '302E37393132352C302E31363336382C302E30313338375D2C5B302E37383236302C302E31353639332C302E30313236345D2C5B302E37373337372C302E31353032382C302E30313134385D2C5B302E37363437362C302E31343337342C302E30313034';
wwv_flow_imp.g_varchar2_table(111) := '315D2C5B302E37353535362C302E31333733312C302E30303934325D2C5B302E37343631372C302E31333039382C302E30303835315D2C5B302E37333636312C302E31323437372C302E30303736395D2C5B302E37323638362C302E31313836372C302E';
wwv_flow_imp.g_varchar2_table(112) := '30303639355D2C5B302E37313639322C302E31313236382C302E30303632395D2C5B302E37303638302C302E31303638302C302E30303537315D2C5B302E36393635302C302E31303130322C302E30303532325D2C5B302E36383630322C302E30393533';
wwv_flow_imp.g_varchar2_table(113) := '362C302E30303438315D2C5B302E36373533352C302E30383938302C302E30303434395D2C5B302E36363434392C302E30383433362C302E30303432345D2C5B302E36353334352C302E30373930322C302E30303430385D2C5B302E36343232332C302E';
wwv_flow_imp.g_varchar2_table(114) := '30373338302C302E30303430315D2C5B302E36333038322C302E30363836382C302E30303430315D2C5B302E36313932332C302E30363336372C302E30303431305D2C5B302E36303734362C302E30353837382C302E30303432375D2C5B302E35393535';
wwv_flow_imp.g_varchar2_table(115) := '302C302E30353339392C302E30303435335D2C5B302E35383333362C302E30343933312C302E30303438365D2C5B302E35373130332C302E30343437342C302E30303532395D2C5B302E35353835322C302E30343032382C302E30303537395D2C5B302E';
wwv_flow_imp.g_varchar2_table(116) := '35343538332C302E30333539332C302E30303633385D2C5B302E35333239352C302E30333136392C302E30303730355D2C5B302E35313938392C302E30323735362C302E30303738305D2C5B302E35303636342C302E30323335342C302E30303836335D';
wwv_flow_imp.g_varchar2_table(117) := '2C5B302E34393332312C302E30313936332C302E30303935355D2C5B302E34373936302C302E30313538332C302E30313035355D5D2E6D61702878203D3E20782E6D61702879203D3E2079202A2032353529292C0D0A202020207D3B0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(118) := '69662028747970656F6620636F6C6F7252616D70203D3D3D202766756E6374696F6E2729207B0D0A202020202020636F6C6F7252616D70203D20636F6C6F7252616D70287B0D0A20202020202020206D696E3A20726173746572696E666F2E72616E6765';
wwv_flow_imp.g_varchar2_table(119) := '5B305D2C0D0A20202020202020206D61783A20726173746572696E666F2E72616E67655B315D2C0D0A20202020202020206D65616E3A20726173746572696E666F2E6D65616E2C0D0A20202020202020206D656469616E3A20726173746572696E666F2E';
wwv_flow_imp.g_varchar2_table(120) := '6D656469616E2C0D0A202020202020202073746465763A20726173746572696E666F2E73746465760D0A2020202020207D2C206275696C74696E293B0D0A202020207D0D0A202020206966202841727261792E6973417272617928636F6C6F7252616D70';
wwv_flow_imp.g_varchar2_table(121) := '2929207B0D0A202020202020636F6C6F7252616D70203D207B2073746F70733A20636F6C6F7252616D70207D3B0D0A202020207D0D0A20202020636F6C6F7252616D702E74797065207C7C3D202773657175656E7469616C273B0D0A2020202069662028';
wwv_flow_imp.g_varchar2_table(122) := '2141727261792E6973417272617928636F6C6F7252616D702E73746F70735B305D29207C7C20636F6C6F7252616D702E73746F70735B305D2E6C656E67746820213D3D203229207B0D0A2020202020202F2A20496620746865206172726179206973206A';
wwv_flow_imp.g_varchar2_table(123) := '7573742061206C697374206F6620636F6C6F72732077697468206E6F20696E7075742076616C7565732C206D617020697420746F0D0A20202020202020207468652072616E67652E202A2F0D0A202020202020636F6C6F7252616D702E73746F7073203D';
wwv_flow_imp.g_varchar2_table(124) := '20636F6C6F7252616D702E73746F70732E6D61702828782C206929203D3E205B0D0A20202020202020202869202F2028636F6C6F7252616D702E73746F70732E6C656E677468202D20312929202A2028726173746572696E666F2E72616E67655B315D20';
wwv_flow_imp.g_varchar2_table(125) := '2D20726173746572696E666F2E72616E67655B305D29202B20726173746572696E666F2E72616E67655B305D2C0D0A2020202020202020780D0A2020202020205D293B0D0A202020207D0D0A20202020666F722028636F6E73742073746F70206F662063';
wwv_flow_imp.g_varchar2_table(126) := '6F6C6F7252616D702E73746F707329207B0D0A20202020202073746F705B315D203D207061727365436F6C6F722873746F705B315D293B0D0A202020207D0D0A20207D3B0D0A0D0A20206C657420726173746572696E666F3B0D0A20206C657420726566';
wwv_flow_imp.g_varchar2_table(127) := '72657368436F756E74203D20313B0D0A20202F2F2043616C6C2074686520706C7567696E207365727669636520746F20676574207468652067656F72617374657220696E666F726D6174696F6E2C2070757420696E207468652027726173746572696E66';
wwv_flow_imp.g_varchar2_table(128) := '6F27207661726961626C652E0D0A2020636F6E73742072656672657368526173746572496E666F203D206173796E63202829203D3E207B0D0A20202020726173746572696E666F203D20617761697420617065782E7365727665722E706C7567696E2870';
wwv_flow_imp.g_varchar2_table(129) := '5F616A61785F6964656E7469666965722C207B0D0A202020202020783031203A20302C202F2F206765742072617374657220696E666F206F70636F64650D0A202020202020706167654974656D733A20705F7375626D69745F6974656D73203F20705F73';
wwv_flow_imp.g_varchar2_table(130) := '75626D69745F6974656D732E73706C697428222C2229203A20756E646566696E65640D0A202020207D293B0D0A2020202072656672657368436F6C6F7252616D7028293B0D0A20207D3B0D0A202061776169742072656672657368526173746572496E66';
wwv_flow_imp.g_varchar2_table(131) := '6F28293B0D0A0D0A2020636F6E7374207465727261696E42617365203D202D31303030303B0D0A2020636F6E7374207465727261696E5265736F6C7574696F6E203D20302E313B0D0A0D0A2020636F6E737420636F6C6F72496E74657270203D2028612C';
wwv_flow_imp.g_varchar2_table(132) := '20622C207429203D3E207B0D0A202020202F2F20746F646F3A207573652068636C0D0A2020202072657475726E205B0D0A202020202020615B305D202A202831202D207429202B20625B305D202A20742C0D0A202020202020615B315D202A202831202D';
wwv_flow_imp.g_varchar2_table(133) := '207429202B20625B315D202A20742C0D0A202020202020615B325D202A202831202D207429202B20625B325D202A20742C0D0A202020202020615B335D202A202831202D207429202B20625B335D202A20742C0D0A202020205D3B0D0A20207D3B0D0A0D';
wwv_flow_imp.g_varchar2_table(134) := '0A2020636F6E737420636F6D7075746552616D70203D202876616C29203D3E207B0D0A202020206966202876616C203C207465727261696E4261736529207B0D0A2020202020202F2F206E6F646174610D0A20202020202072657475726E205B302C2030';
wwv_flow_imp.g_varchar2_table(135) := '2C20302C20305D3B0D0A202020207D20656C7365206966202876616C203C3D20636F6C6F7252616D702E73746F70735B305D5B305D29207B0D0A20202020202072657475726E20636F6C6F7252616D702E73746F70735B305D5B315D3B0D0A202020207D';
wwv_flow_imp.g_varchar2_table(136) := '20656C7365206966202876616C203E3D20636F6C6F7252616D702E73746F70735B636F6C6F7252616D702E73746F70732E6C656E677468202D20315D5B305D29207B0D0A20202020202072657475726E20636F6C6F7252616D702E73746F70735B636F6C';
wwv_flow_imp.g_varchar2_table(137) := '6F7252616D702E73746F70732E6C656E677468202D20315D5B315D3B0D0A202020207D0D0A20202020666F7220286C65742069203D20303B2069203C20636F6C6F7252616D702E73746F70732E6C656E6774683B2069202B2B29207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(138) := '6966202876616C203C3D20636F6C6F7252616D702E73746F70735B69202B20315D5B305D29207B0D0A202020202020202072657475726E20636F6C6F72496E74657270280D0A20202020202020202020636F6C6F7252616D702E73746F70735B695D5B31';
wwv_flow_imp.g_varchar2_table(139) := '5D2C0D0A20202020202020202020636F6C6F7252616D702E73746F70735B69202B20315D5B315D2C0D0A202020202020202020202876616C202D20636F6C6F7252616D702E73746F70735B695D5B305D29202F2028636F6C6F7252616D702E73746F7073';
wwv_flow_imp.g_varchar2_table(140) := '5B69202B20315D5B305D202D20636F6C6F7252616D702E73746F70735B695D5B305D292C0D0A2020202020202020293B0D0A2020202020207D0D0A202020207D0D0A20207D3B0D0A0D0A2020636C617373204C5255207B0D0A20202020636F6E73747275';
wwv_flow_imp.g_varchar2_table(141) := '63746F722873697A65203D2031303029207B0D0A202020202020746869732E5F6361636865203D206E6577204D617028293B0D0A202020202020746869732E5F726563656E74203D205B5D3B0D0A202020202020746869732E5F73697A65203D2073697A';
wwv_flow_imp.g_varchar2_table(142) := '653B0D0A202020207D0D0A0D0A20202020686173286B657929207B0D0A20202020202072657475726E20746869732E5F63616368652E686173286B6579293B0D0A202020207D0D0A0D0A20202020676574286B657929207B0D0A20202020202069662028';
wwv_flow_imp.g_varchar2_table(143) := '746869732E5F63616368652E686173286B65792929207B0D0A2020202020202020636F6E737420696478203D20746869732E5F726563656E742E696E6465784F66286B6579293B0D0A2020202020202020746869732E5F726563656E742E73706C696365';
wwv_flow_imp.g_varchar2_table(144) := '286964782C2031293B0D0A2020202020202020746869732E5F726563656E742E70757368286B6579293B0D0A202020202020202072657475726E20746869732E5F63616368652E676574286B6579293B0D0A2020202020207D0D0A202020207D0D0A0D0A';
wwv_flow_imp.g_varchar2_table(145) := '20202020707574286B65792C2076616C29207B0D0A202020202020636F6E737420696478203D20746869732E5F726563656E742E696E6465784F66286B6579293B0D0A20202020202069662028696478203E3D203029207B0D0A20202020202020207468';
wwv_flow_imp.g_varchar2_table(146) := '69732E5F726563656E742E73706C696365286964782C2031293B0D0A2020202020207D20656C7365207B0D0A202020202020202069662028746869732E5F726563656E742E6C656E677468203E3D20746869732E5F73697A6529207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(147) := '20202020746869732E5F63616368652E64656C65746528746869732E5F726563656E745B305D293B0D0A20202020202020202020746869732E5F726563656E742E73706C69636528302C2031293B0D0A20202020202020207D0D0A2020202020207D0D0A';
wwv_flow_imp.g_varchar2_table(148) := '202020202020746869732E5F726563656E742E70757368286B6579293B0D0A202020202020746869732E5F63616368652E736574286B65792C2076616C293B0D0A202020207D0D0A0D0A20202020636C6561722829207B0D0A202020202020746869732E';
wwv_flow_imp.g_varchar2_table(149) := '5F63616368652E636C65617228293B0D0A202020202020746869732E5F726563656E74203D205B5D3B0D0A202020207D0D0A20207D0D0A0D0A20202F2A204D6170206F6620277A2F782F792720737472696E677320746F2074696C6520726573706F6E73';
wwv_flow_imp.g_varchar2_table(150) := '6573202A2F0D0A2020636F6E73742074696C654361636865203D206E6577204C525528293B0D0A0D0A2020636F6E73742067657454696C65203D206173796E6320287A2C20782C207929203D3E207B0D0A20202020636F6E7374206B6579203D2060247B';
wwv_flow_imp.g_varchar2_table(151) := '7A7D2F247B787D2F247B797D603B0D0A202020206966202874696C6543616368652E686173286B65792929207B0D0A20202020202072657475726E2061776169742074696C6543616368652E676574286B6579293B0D0A202020207D0D0A0D0A20202020';
wwv_flow_imp.g_varchar2_table(152) := '636F6E7374207831203D2074696C65326C6F6E6728782C207A293B0D0A20202020636F6E7374207931203D2074696C65326C617428792C207A293B0D0A20202020636F6E7374207832203D2074696C65326C6F6E672878202B20312C207A293B0D0A2020';
wwv_flow_imp.g_varchar2_table(153) := '2020636F6E7374207932203D2074696C65326C61742879202B20312C207A293B0D0A0D0A20202020636F6E73742070726F6D697365203D20286173796E63202829203D3E207B0D0A202020202020636F6E737420726573706F6E7365203D206177616974';
wwv_flow_imp.g_varchar2_table(154) := '20617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B0D0A20202020202020207830313A20312C202F2F20676574207261737465722064617461206F70636F64650D0A20202020202020207830323A206261';
wwv_flow_imp.g_varchar2_table(155) := '636B67726F756E64436F6C6F722E6A6F696E28272C27292C202F2F206261636B67726F756E6420636F6C6F720D0A20202020202020207830333A2078312C207830343A2079312C207830353A2078322C207830363A2079322C0D0A202020202020202078';
wwv_flow_imp.g_varchar2_table(156) := '30373A20222722202B207A202B20222C22202B2078202B20222C22202B2079202B202227222C202F2F206E6F7420757365642C206F6E6C7920666F7220646562756767696E6720707572706F7365730D0A20202020202020207830383A20705F6974656D';
wwv_flow_imp.g_varchar2_table(157) := '5F69642C0D0A2020202020202020706167654974656D733A20705F7375626D69745F6974656D73203F20705F7375626D69745F6974656D732E73706C697428222C2229203A20756E646566696E65640D0A2020202020207D293B0D0A0D0A202020202020';
wwv_flow_imp.g_varchar2_table(158) := '69662028726573706F6E73652E63656C6C6461746129207B0D0A2020202020202020636F6E737420626C6F62203D2061746F6228726573706F6E73652E63656C6C64617461293B0D0A2020202020202020636F6E7374206C656E203D20626C6F622E6C65';
wwv_flow_imp.g_varchar2_table(159) := '6E6774683B0D0A2020202020202020636F6E7374206279746573203D206E65772055696E74384172726179286C656E293B0D0A0D0A2020202020202020666F7220286C65742069203D20303B2069203C206C656E3B20692B2B29207B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(160) := '2020202062797465735B695D203D20626C6F622E63686172436F646541742869293B0D0A20202020202020207D0D0A0D0A2020202020202020726573706F6E73652E63656C6C64617461203D2062797465732E6275666665723B0D0A2020202020207D0D';
wwv_flow_imp.g_varchar2_table(161) := '0A0D0A20202020202072657475726E20726573706F6E73653B0D0A202020207D2928293B0D0A0D0A2020202074696C6543616368652E707574286B65792C2070726F6D697365293B0D0A0D0A2020202072657475726E2061776169742070726F6D697365';
wwv_flow_imp.g_varchar2_table(162) := '3B0D0A20207D3B0D0A0D0A20206173796E632066756E6374696F6E2067656F7261737465725F70726F746F636F6C28706172616D732C2061626F7274436F6E74726F6C6C657229207B0D0A2020202069662028726173746572696E666F2E6572726F7229';
wwv_flow_imp.g_varchar2_table(163) := '207B0D0A20202020202072657475726E207B646174613A206E756C6C7D3B0D0A202020207D0D0A0D0A2020202069662028726173746572696E666F2E6974656D696420213D20705F6974656D5F696429207B0D0A202020202020616C6572742872617374';
wwv_flow_imp.g_varchar2_table(164) := '6572696E666F2E6974656D6964202B202720213D2027202B20705F6974656D5F6964293B0D0A202020207D0D0A2020202069662028726173746572696E666F2E6D6178707972616D69646C6576656C203D3D203029207B0D0A202020202020636F6E736F';
wwv_flow_imp.g_varchar2_table(165) := '6C652E7761726E28274D6170626974732047656F526173746572204C61796572205B27202B20705F6974656D5F6964202B20275D206973206D697373696E6720707972616D6964732E204275696C6420707972616D69647320746F20696D70726F766520';
wwv_flow_imp.g_varchar2_table(166) := '706572666F726D616E63652E27293B0D0A202020207D0D0A20202020636F6E7374207265203D206E657720526567457870282F3A5C2F5C2F282E2B295C2F282E2B295C2F285C642B295C2F285C642B295C2F285C642B292F293B0D0A20202020636F6E73';
wwv_flow_imp.g_varchar2_table(167) := '74207274203D20706172616D732E75726C2E6D61746368287265293B0D0A202020206966202821727429207B0D0A2020202020207468726F77206E6577204572726F7228274D616C666F726D65642055524C3A205B27202B20706172616D732E75726C20';
wwv_flow_imp.g_varchar2_table(168) := '2B20225D22293B0D0A202020207D0D0A0D0A20202020636F6E737420666F726D6174203D2072745B325D3B0D0A20202020636F6E73742074696C657A7879203D205B7061727365496E742872745B335D292C207061727365496E742872745B345D292C20';
wwv_flow_imp.g_varchar2_table(169) := '7061727365496E742872745B355D295D3B0D0A20202020636F6E7374207831203D2074696C65326C6F6E672874696C657A78795B315D2C2074696C657A78795B305D293B0D0A20202020636F6E7374207931203D2074696C65326C61742874696C657A78';
wwv_flow_imp.g_varchar2_table(170) := '795B325D2C2074696C657A78795B305D293B0D0A20202020636F6E7374207832203D2074696C65326C6F6E672874696C657A78795B315D202B20312C2074696C657A78795B305D293B0D0A20202020636F6E7374207932203D2074696C65326C61742874';
wwv_flow_imp.g_varchar2_table(171) := '696C657A78795B325D202B20312C2074696C657A78795B305D293B0D0A0D0A202020202F2F2043616C6C2074686520706C7567696E207365727669636520746F20676574207468652072617374657220646174612028656E636F64656420617320626173';
wwv_flow_imp.g_varchar2_table(172) := '653634292C2070757420696E20276461746127207661726961626C652E200D0A202020202F2F2078303720616E64207830382061726520666F7220646562756767696E672C20636F6E73696465722072656D6F76696E672074686F736520696E20746865';
wwv_flow_imp.g_varchar2_table(173) := '206675747572652E0D0A20202020636F6E73742064617461203D2061776169742067657454696C652874696C657A78795B305D2C2074696C657A78795B315D2C2074696C657A78795B325D293B0D0A0D0A202020202F2F20496620746865726520697320';
wwv_flow_imp.g_varchar2_table(174) := '6E6F20646174612C207468656E2065786974207468652063616C6C6261636B2E0D0A2020202069662028646174612E7769647468203D3D2030207C7C20646174612E686569676874203D3D2030207C7C20646174612E6E6F52617374657229207B0D0A20';
wwv_flow_imp.g_varchar2_table(175) := '202020202072657475726E207B2063616E63656C3A202829203D3E207B207D207D3B0D0A202020207D0D0A0D0A202020202F2F20437265617465207468652063616E76617320696E20776869636820746F2072656E6465722074686520696D6167652E0D';
wwv_flow_imp.g_varchar2_table(176) := '0A20202020636F6E73742063616E766173203D20646F63756D656E742E637265617465456C656D656E74282763616E76617327293B0D0A20202020636F6E73742063203D2063616E7661732E676574436F6E7465787428273264272C207B2077696C6C52';
wwv_flow_imp.g_varchar2_table(177) := '6561644672657175656E746C793A2074727565207D293B20200D0A2020202063616E7661732E7374796C652E646973706C6179203D20276E6F6E65273B0D0A0D0A202020202F2F20436F6E766572742074686520626173653634206461746120696E746F';
wwv_flow_imp.g_varchar2_table(178) := '20616E20496D61676544617461206F626A6563742E0D0A20202020636F6E737420696D61676544617461203D20632E637265617465496D6167654461746128646174612E77696474682C20646174612E686569676874293B200D0A20202020636F6E7374';
wwv_flow_imp.g_varchar2_table(179) := '206461746176696577203D206E657720446174615669657728646174612E63656C6C64617461293B0D0A20202020636F6E7374206C656E203D2064617461766965772E627974654C656E6774683B0D0A20202020636F6E737420697344454D203D206461';
wwv_flow_imp.g_varchar2_table(180) := '74612E62616E64636F756E74203D3D203120262620646174612E63656C6C6465707468203D3D2033323B0D0A0D0A2020202069662028666F726D6174203D3D3D20277261737465722729207B0D0A202020202020696620285B27636F6C6F722D72656C69';
wwv_flow_imp.g_varchar2_table(181) := '6566272C202768696C6C73686164655F636F6C6F725F72656C696566275D2E696E636C7564657328705F6C617965725F747970652929207B0D0A20202020202020202F2F205072652D72656E646572656420636F6C6F722072656C6965660D0A20202020';
wwv_flow_imp.g_varchar2_table(182) := '202020206966202821697344454D29207B0D0A202020202020202020207468726F77206E6577204572726F72286043616E6E6F7420636F6E76657274207468652070726F7669646564207261737465722028247B646174612E62616E64636F756E747D20';
wwv_flow_imp.g_varchar2_table(183) := '62616E64732C20247B646174612E63656C6C64657074687D2D62697420706978656C732920746F20612044454D206C6179657260293B0D0A20202020202020207D0D0A0D0A2020202020202020666F7220286C65742069203D20303B2069203C206C656E';
wwv_flow_imp.g_varchar2_table(184) := '3B2069202B3D203429207B0D0A20202020202020202020636F6E73742076616C203D2064617461766965772E676574466C6F6174333228692C2066616C7365293B0D0A20202020202020202020636F6E7374205B722C20672C20622C20615D203D20636F';
wwv_flow_imp.g_varchar2_table(185) := '6D7075746552616D702876616C293B0D0A20202020202020202020696D616765446174612E646174615B695D203D20723B0D0A20202020202020202020696D616765446174612E646174615B69202B20315D203D2020673B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(186) := '696D616765446174612E646174615B69202B20325D203D20623B0D0A20202020202020202020696D616765446174612E646174615B69202B20335D203D20613B0D0A20202020202020207D0D0A2020202020207D20656C7365207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(187) := '202F2F20436F6C6F722052474220496D616765202D2033206F7220342062616E642C20756E7369676E656420386269740D0A202020202020202069662028215B332C20345D2E696E636C7564657328646174612E62616E64636F756E7429207C7C206461';
wwv_flow_imp.g_varchar2_table(188) := '74612E63656C6C646570746820213D3D203829207B0D0A202020202020202020207468726F77206E6577204572726F72286043616E6E6F7420636F6E76657274207468652070726F7669646564207261737465722028247B646174612E62616E64636F75';
wwv_flow_imp.g_varchar2_table(189) := '6E747D2062616E64732C20247B646174612E63656C6C64657074687D2D62697420706978656C732920746F20616E20524742206C6179657260293B0D0A20202020202020207D0D0A0D0A202020202020202069662028646174612E62616E64636F756E74';
wwv_flow_imp.g_varchar2_table(190) := '203D3D3D203329207B0D0A20202020202020202020666F7220286C65742069203D20302C206A203D20303B2069203C206C656E3B2069202B3D203329207B0D0A202020202020202020202020696D616765446174612E646174615B6A5D203D2064617461';
wwv_flow_imp.g_varchar2_table(191) := '766965772E67657455696E74382869293B0D0A202020202020202020202020696D616765446174612E646174615B6A202B20315D203D2064617461766965772E67657455696E74382869202B2031293B0D0A202020202020202020202020696D61676544';
wwv_flow_imp.g_varchar2_table(192) := '6174612E646174615B6A202B20325D203D2064617461766965772E67657455696E74382869202B2032293B0D0A20202020202020202020202069662028696D616765446174612E646174615B6A5D203D3D206261636B67726F756E64436F6C6F725B305D';
wwv_flow_imp.g_varchar2_table(193) := '20262620696D616765446174612E646174615B6A202B20315D203D3D206261636B67726F756E64436F6C6F725B315D20262620696D616765446174612E646174615B6A202B20325D203D3D206261636B67726F756E64436F6C6F725B325D29207B0D0A20';
wwv_flow_imp.g_varchar2_table(194) := '20202020202020202020202020696D616765446174612E646174615B6A202B20335D203D20303B0D0A2020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020696D616765446174612E646174615B6A202B20335D203D';
wwv_flow_imp.g_varchar2_table(195) := '203235353B0D0A2020202020202020202020207D0D0A2020202020202020202020206A202B3D20343B0D0A202020202020202020207D0D0A20202020202020207D20656C7365207B0D0A20202020202020202020666F7220286C65742069203D20302C20';
wwv_flow_imp.g_varchar2_table(196) := '6A203D20303B2069203C206C656E3B2069202B3D203429207B0D0A202020202020202020202020696D616765446174612E646174615B6A5D203D2064617461766965772E67657455696E74382869293B0D0A202020202020202020202020696D61676544';
wwv_flow_imp.g_varchar2_table(197) := '6174612E646174615B6A202B20315D203D2064617461766965772E67657455696E74382869202B2031293B0D0A202020202020202020202020696D616765446174612E646174615B6A202B20325D203D2064617461766965772E67657455696E74382869';
wwv_flow_imp.g_varchar2_table(198) := '202B2032293B0D0A202020202020202020202020696D616765446174612E646174615B6A202B20335D203D2064617461766965772E67657455696E74382869202B2033293B0D0A2020202020202020202020206A202B3D20343B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(199) := '20207D0D0A20202020202020207D0D0A2020202020207D0D0A202020207D20656C73652069662028666F726D6174203D3D3D20277261737465722D64656D2729207B0D0A2020202020202F2F205465727261696E5247420D0A2020202020206966202821';
wwv_flow_imp.g_varchar2_table(200) := '697344454D29207B0D0A20202020202020207468726F77206E6577204572726F72286043616E6E6F7420636F6E76657274207468652070726F7669646564207261737465722028247B646174612E62616E64636F756E747D2062616E64732C20247B6461';
wwv_flow_imp.g_varchar2_table(201) := '74612E63656C6C64657074687D2D62697420706978656C732920746F20612044454D206C6179657260293B0D0A2020202020207D0D0A0D0A202020202020666F7220286C65742069203D20303B2069203C206C656E3B2069202B3D203429207B0D0A2020';
wwv_flow_imp.g_varchar2_table(202) := '202020202020636F6E73742076616C203D2064617461766965772E676574466C6F6174333228692C2066616C7365293B0D0A2020202020202020636F6E7374206532203D20282876616C203C207465727261696E42617365203F2030203A2076616C2920';
wwv_flow_imp.g_varchar2_table(203) := '2D207465727261696E4261736529202F207465727261696E5265736F6C7574696F6E3B0D0A2020202020202020636F6E73742072203D204D6174682E666C6F6F72286532202F2028323536202A2032353629293B0D0A2020202020202020636F6E737420';
wwv_flow_imp.g_varchar2_table(204) := '67203D204D6174682E666C6F6F7228286532202D2072202A203235362A32353629202F20323536293B0D0A2020202020202020636F6E73742062203D206532202D202872202A203235362A32353629202D202867202A20323536293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(205) := '2020696D616765446174612E646174615B695D203D20723B0D0A2020202020202020696D616765446174612E646174615B69202B20315D203D2020673B0D0A2020202020202020696D616765446174612E646174615B69202B20325D203D20623B0D0A20';
wwv_flow_imp.g_varchar2_table(206) := '20202020202020696D616765446174612E646174615B69202B20335D203D203235353B0D0A2020202020207D0D0A202020207D0D0A0D0A2020202069662028666F726D6174203D3D3D20277261737465722D64656D2729207B0D0A202020202020632E66';
wwv_flow_imp.g_varchar2_table(207) := '696C6C5374796C65203D206072676228312C203133342C2031363029603B0D0A202020202020632E66696C6C5265637428302C20302C2063616E7661732E77696474682C2063616E7661732E686569676874293B0D0A202020207D0D0A0D0A202020202F';
wwv_flow_imp.g_varchar2_table(208) := '2F205075742074686520696D616765206461746120696E746F207468652063616E76617320776974682074686520617070726F707269617465206F666673657420616E642064696D656E73696F6E732E0D0A202020202F2A69662028646174612E776964';
wwv_flow_imp.g_varchar2_table(209) := '746820213D3D20323536207C7C20646174612E68656967687420213D3D203235362029207B0D0A202020202020636F6E73742065203D20646174612E657874656E743B0D0A202020202020636F6E7374206470203D205B28655B325D202D20655B305D29';
wwv_flow_imp.g_varchar2_table(210) := '202F20646174612E77696474682C2028655B335D202D20655B315D29202F20646174612E6865696768745D3B0D0A2020202020206C65742063616E7661735F73697A65203D205B28287832202D20783129202F2064705B305D292C2028287931202D2079';
wwv_flow_imp.g_varchar2_table(211) := '3229202F2064705B315D295D3B0D0A20202020202063616E7661735F73697A65203D205B4D6174682E666C6F6F7228287832202D20783129202F2064705B305D292C204D6174682E666C6F6F7228287931202D20793229202F2064705B315D295D3B0D0A';
wwv_flow_imp.g_varchar2_table(212) := '202020202020636F6E7374206F6666736574203D205B4D6174682E6D6178284D6174682E666C6F6F722828655B305D202D20783129202F2064705B305D292C2030292C204D6174682E6D6178284D6174682E666C6F6F722828655B315D202D2079322920';
wwv_flow_imp.g_varchar2_table(213) := '2F2064705B315D292C2030295D0D0A202020202020636F6E73742072203D205B6F66667365745B305D2C206F66667365745B315D2C20646174612E77696474682C20646174612E6865696768745D3B0D0A0D0A20202020202063616E7661732E77696474';
wwv_flow_imp.g_varchar2_table(214) := '68203D204D6174682E6D696E2863616E7661735F73697A655B305D2C2063616E7661735F73697A655B315D293B0D0A20202020202063616E7661732E686569676874203D204D6174682E6D696E2863616E7661735F73697A655B305D2C2063616E766173';
wwv_flow_imp.g_varchar2_table(215) := '5F73697A655B315D293B0D0A202020202020632E707574496D6167654461746128696D616765446174612C20725B305D2C2063616E7661732E686569676874202D20725B335D202D20725B315D2C20302C20302C20725B325D2C20725B335D293B0D0A20';
wwv_flow_imp.g_varchar2_table(216) := '2020207D20656C7365207B2A2F0D0A2020202063616E7661732E7769647468203D203235363B0D0A2020202063616E7661732E686569676874203D203235363B0D0A20202020632E707574496D6167654461746128696D616765446174612C20302C2030';
wwv_flow_imp.g_varchar2_table(217) := '2C20302C20302C203235362C20323536293B0D0A202020202F2A7D2A2F0D0A0D0A202020202F2F205772697465207468652063616E76617320617320616E20696D61676520696E206163636F7264616E6365207769746820746865205261737465722054';
wwv_flow_imp.g_varchar2_table(218) := '696C652070726F746F636F6C2E0D0A20202020636F6E737420727450203D206177616974206E65772050726F6D69736528287265736F6C766529203D3E207B0D0A20202020202063616E7661732E746F426C6F62286173796E6320286229203D3E207B0D';
wwv_flow_imp.g_varchar2_table(219) := '0A20202020202020207265736F6C766528617761697420622E61727261794275666665722829293B0D0A2020202020207D293B0D0A202020207D293B0D0A2020202072657475726E207B20646174613A20727450207D3B0D0A20207D0D0A0D0A2020636F';
wwv_flow_imp.g_varchar2_table(220) := '6E7374207365744C617965725669736962696C69747950726F70203D202829203D3E207B0D0A20202020636F6E73742073203D20287375626C617965722C2064697361626C656429203D3E207B0D0A202020202020636F6E7374206964203D20705F6974';
wwv_flow_imp.g_varchar2_table(221) := '656D5F6964202B20272D27202B207375626C617965723B0D0A202020202020696620286D61702E6765744C617965722869642929207B0D0A20202020202020206D61702E7365744C61796F757450726F70657274792869642C20277669736962696C6974';
wwv_flow_imp.g_varchar2_table(222) := '79272C20286C436F6F6B6965203D3D3D202776697369626C6527202626202164697361626C656429203F202776697369626C6527203A20276E6F6E6527293B0D0A2020202020207D0D0A202020207D3B0D0A2020202073282772656C696566272C206869';
wwv_flow_imp.g_varchar2_table(223) := '64655261737465724C61796572293B0D0A2020202073282768696C6C7368616465272C206869646548696C6C73686164654C61796572293B0D0A20202020732827726173746572272C20686964655261737465724C61796572293B0D0A20207D3B0D0A0D';
wwv_flow_imp.g_varchar2_table(224) := '0A20202F2F20437265617465206D61706C6962726520736F7572636520616E64206C617965722E0D0A0D0A20206C6574207465727261696E436F6E74726F6C3B0D0A0D0A2020636F6E7374206164644C61796572203D202829203D3E207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(225) := '72656672657368436F756E74202B2B3B0D0A0D0A20202020736F757263654E616D6573203D205B5D3B0D0A202020206C617965724E616D6573203D205B5D3B0D0A0D0A202020206966202864656D536F7572636529207B0D0A202020202020636F6E7374';
wwv_flow_imp.g_varchar2_table(226) := '20737263203D207B0D0A2020202020202020747970653A20277261737465722D64656D272C0D0A202020202020202074696C65733A205B6067656F7261737465725F247B705F6974656D5F69647D3A2F2F247B705F6974656D5F69647D2F726173746572';
wwv_flow_imp.g_varchar2_table(227) := '2D64656D2F7B7A7D2F7B787D2F7B797D2F72656672657368247B72656672657368436F756E747D605D2C0D0A202020202020202074696C6553697A653A203235362C0D0A202020202020202020202F2F206E656564732061206E65776572207665727369';
wwv_flow_imp.g_varchar2_table(228) := '6F6E206F66206D61706C696272652C206275742049276D206E6F7420737572652077686963680D0A202020202020202020202F2F20656E636F64696E673A2027637573746F6D272C0D0A202020202020202020202F2F206261736553686966743A207465';
wwv_flow_imp.g_varchar2_table(229) := '727261696E426173652C0D0A202020202020202020202F2F20726564466163746F723A20323536202A20323536202A207465727261696E5265736F6C7574696F6E2C0D0A202020202020202020202F2F20677265656E466163746F723A20323536202A20';
wwv_flow_imp.g_varchar2_table(230) := '7465727261696E5265736F6C7574696F6E2C0D0A202020202020202020202F2F20626C7565466163746F723A207465727261696E5265736F6C7574696F6E2C0D0A2020202020207D3B0D0A0D0A2020202020206D61702E616464536F7572636528276765';
wwv_flow_imp.g_varchar2_table(231) := '6F72617374657244454D536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F69642C20737263293B0D0A202020202020736F757263654E616D65732E70757368282767656F72617374657244454D536F7572';
wwv_flow_imp.g_varchar2_table(232) := '63655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F6964293B0D0A202020207D0D0A0D0A2020202069662028726173746572536F7572636529207B0D0A202020202020636F6E737420737263203D207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(233) := '20202020747970653A2027726173746572272C0D0A202020202020202074696C65733A205B6067656F7261737465725F247B705F6974656D5F69647D3A2F2F247B705F6974656D5F69647D2F7261737465722F7B7A7D2F7B787D2F7B797D2F7265667265';
wwv_flow_imp.g_varchar2_table(234) := '7368247B72656672657368436F756E747D605D2C0D0A202020202020202074696C6553697A653A203235362C0D0A2020202020207D3B0D0A0D0A2020202020206D61702E616464536F75726365282767656F726173746572536F757263655F27202B2072';
wwv_flow_imp.g_varchar2_table(235) := '656672657368436F756E74202B20275F27202B20705F6974656D5F69642C20737263293B0D0A202020202020736F757263654E616D65732E70757368282767656F726173746572536F757263655F27202B2072656672657368436F756E74202B20275F27';
wwv_flow_imp.g_varchar2_table(236) := '202B20705F6974656D5F6964293B0D0A202020207D0D0A0D0A20202020636F6E7374206164644C61796572203D20286C797229203D3E207B0D0A2020202020206C617965724E616D65732E70757368286C79722E6964293B0D0A2020202020202F2F2041';
wwv_flow_imp.g_varchar2_table(237) := '646420746865206C6179657220746F20746865206D61702E20557365207468652073657175656E6365206E756D6265722066726F6D207468652070616765200D0A2020202020202F2F206974656D20746F206F7264657220746865206C61796572732E20';
wwv_flow_imp.g_varchar2_table(238) := '486967686572206E756D6265727320617265206C61737420616E6420646973706C61796564206F6E20746F702E0D0A202020202020636F6E7374206C6179657273203D206D61702E6765745374796C6528292E6C61796572733B0D0A202020202020636F';
wwv_flow_imp.g_varchar2_table(239) := '6E7374206D6170626974736C6179657273203D206C61796572732E66696C7465722866756E6374696F6E2876616C297B0D0A202020202020202069662028276D657461646174612720696E2076616C29207B200D0A202020202020202020207265747572';
wwv_flow_imp.g_varchar2_table(240) := '6E20276C617965725F73657175656E63652720696E2076616C2E6D657461646174613B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202072657475726E2066616C73653B0D0A20202020202020207D0D0A2020202020207D292E';
wwv_flow_imp.g_varchar2_table(241) := '6D61702866756E6374696F6E2876616C29207B72657475726E205B76616C2E6D657461646174612E6C617965725F73657175656E63652C2076616C2E69645D7D293B0D0A0D0A2020202020206C6574206265666F72654C617965723B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(242) := '696620286D6170626974736C61796572732E6C656E67746820213D3D203029207B0D0A20202020202020206D6170626974736C61796572732E736F72742828612C206229203D3E20615B305D202D20625B305D293B0D0A2020202020202020666F72286C';
wwv_flow_imp.g_varchar2_table(243) := '65742069203D20303B2069203C206D6170626974736C61796572732E6C656E6774683B20692B2B29207B0D0A2020202020202020202069662028705F73657175656E6365203C206D6170626974736C61796572735B695D5B305D29207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(244) := '202020202020206265666F72654C61796572203D206D6170626974736C61796572735B695D5B315D3B0D0A202020202020202020202020627265616B3B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(245) := '202020206D61702E6164644C61796572286C79722C206265666F72654C61796572293B0D0A202020207D3B0D0A0D0A20202020696620287261737465724C6179657229207B0D0A2020202020206164644C61796572287B0D0A202020202020202069643A';
wwv_flow_imp.g_varchar2_table(246) := '20705F6974656D5F6964202B20272D726173746572272C0D0A2020202020202020747970653A2027726173746572272C0D0A2020202020202020736F757263653A202767656F726173746572536F757263655F27202B2072656672657368436F756E7420';
wwv_flow_imp.g_varchar2_table(247) := '2B20275F27202B20705F6974656D5F69642C0D0A20202020202020206D65746164617461203A207B276C617965725F73657175656E636527203A20705F73657175656E63657D2C0D0A20202020202020206C61796F7574203A207B207669736962696C69';
wwv_flow_imp.g_varchar2_table(248) := '74793A20276E6F6E6527207D2C0D0A2020202020207D293B0D0A202020207D0D0A0D0A202020206966202868696C6C73686164654C6179657229207B0D0A2020202020206164644C61796572287B0D0A202020202020202069643A20705F6974656D5F69';
wwv_flow_imp.g_varchar2_table(249) := '64202B20272D68696C6C7368616465272C0D0A2020202020202020747970653A202768696C6C7368616465272C0D0A2020202020202020736F757263653A202767656F72617374657244454D536F757263655F27202B2072656672657368436F756E7420';
wwv_flow_imp.g_varchar2_table(250) := '2B20275F27202B20705F6974656D5F69642C0D0A20202020202020207061696E743A207B0D0A202020202020202020202F2F202768696C6C73686164652D736861646F772D636F6C6F72273A20705F636865636B626F785F636F6C6F722C0D0A20202020';
wwv_flow_imp.g_varchar2_table(251) := '202020207D2C0D0A20202020202020206D65746164617461203A207B276C617965725F73657175656E636527203A20705F73657175656E63657D2C0D0A20202020202020206C61796F7574203A207B207669736962696C6974793A20276E6F6E6527207D';
wwv_flow_imp.g_varchar2_table(252) := '2C0D0A2020202020207D293B0D0A202020207D0D0A0D0A202020206966202872656C6965664C6179657229207B0D0A2020202020206164644C61796572287B0D0A202020202020202069643A20705F6974656D5F6964202B20272D72656C696566272C0D';
wwv_flow_imp.g_varchar2_table(253) := '0A2020202020202020747970653A2027636F6C6F722D72656C696566272C0D0A2020202020202020736F757263653A202767656F72617374657244454D536F757263655F27202B2072656672657368436F756E74202B20275F27202B20705F6974656D5F';
wwv_flow_imp.g_varchar2_table(254) := '69642C0D0A20202020202020207061696E743A207B0D0A2020202020202020202027636F6C6F722D72656C6965662D6F706163697479273A20705F6F706163697479203F3F20312C0D0A20202020202020207D2C0D0A20202020202020206D6574616461';
wwv_flow_imp.g_varchar2_table(255) := '7461203A207B276C617965725F73657175656E636527203A20705F73657175656E63657D2C0D0A20202020202020206C61796F7574203A207B207669736962696C6974793A20276E6F6E6527207D2C0D0A2020202020207D293B0D0A202020207D0D0A0D';
wwv_flow_imp.g_varchar2_table(256) := '0A202020206966202864656D536F7572636529207B0D0A202020202020696620286D61706C696276657273696F6E5B305D203E3D203529207B0D0A20202020202020206D61702E73657443656E746572436C616D706564546F47726F756E642866616C73';
wwv_flow_imp.g_varchar2_table(257) := '65293B0D0A2020202020207D0D0A0D0A202020202020696620287465727261696E436F6E74726F6C29207B0D0A20202020202020206D61702E72656D6F7665436F6E74726F6C287465727261696E436F6E74726F6C293B0D0A2020202020207D0D0A0D0A';
wwv_flow_imp.g_varchar2_table(258) := '2020202020207465727261696E436F6E74726F6C203D206E6577206D61706C69627265676C2E5465727261696E436F6E74726F6C287B0D0A2020202020202020736F757263653A202767656F72617374657244454D536F757263655F27202B2072656672';
wwv_flow_imp.g_varchar2_table(259) := '657368436F756E74202B20275F27202B20705F6974656D5F69642C0D0A2020202020202020657861676765726174696F6E3A207061727365466C6F617428705F657861676765726174696F6E203F3F2031292C0D0A2020202020207D293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(260) := '20206D61702E616464436F6E74726F6C287465727261696E436F6E74726F6C293B0D0A202020207D0D0A0D0A202020207365744C617965725669736962696C69747950726F7028293B0D0A20207D3B0D0A20206164644C6179657228293B0D0A0D0A2020';
wwv_flow_imp.g_varchar2_table(261) := '2F2F20696D706C656D656E7420746865206D61706C69627265207261737465722074696C652070726F746F636F6C2E20546869732077696C6C2062652063616C6C6564206279206D61706C696272650D0A20206966202870726F746F43616C6C6261636B';
wwv_flow_imp.g_varchar2_table(262) := '29207B0D0A202020206D61706C69627265676C2E61646450726F746F636F6C282767656F7261737465725F27202B20705F6974656D5F69642C2028706172616D732C2063616C6C6261636B29203D3E207B0D0A20202020202067656F7261737465725F70';
wwv_flow_imp.g_varchar2_table(263) := '726F746F636F6C28706172616D732C206E756C6C290D0A20202020202020202E7468656E2828726573756C7429203D3E207B0D0A2020202020202020202063616C6C6261636B286E756C6C2C20726573756C742E646174612C206E756C6C2C206E756C6C';
wwv_flow_imp.g_varchar2_table(264) := '293B0D0A20202020202020207D290D0A20202020202020202E636174636828286572726F7229203D3E207B0D0A2020202020202020202063616C6C6261636B286572726F72293B0D0A20202020202020207D293B0D0A20202020202072657475726E207B';
wwv_flow_imp.g_varchar2_table(265) := '2063616E63656C3A202829203D3E207B207D207D3B0D0A202020207D293B0D0A20207D20656C7365207B0D0A202020206D61706C69627265676C2E61646450726F746F636F6C282767656F7261737465725F27202B20705F6974656D5F69642C20617379';
wwv_flow_imp.g_varchar2_table(266) := '6E632028706172616D732C2061626F7274436F6E74726F6C6C657229203D3E207B0D0A20202020202072657475726E2061776169742067656F7261737465725F70726F746F636F6C28706172616D732C2061626F7274436F6E74726F6C6C6572293B0D0A';
wwv_flow_imp.g_varchar2_table(267) := '202020207D293B0D0A20207D0D0A0D0A2020636F6E73742073686F77203D202829203D3E207B0D0A202020206C436F6F6B6965203D202776697369626C65273B0D0A202020207365744C617965725669736962696C69747950726F7028293B0D0A202020';
wwv_flow_imp.g_varchar2_table(268) := '20617065782E73746F726167652E736574436F6F6B696528274D6170626974735F47656F5261737465724C617965725F27202B20705F6974656D5F69642B20225F22202B202476282270496E7374616E636522292C202776697369626C6527293B0D0A20';
wwv_flow_imp.g_varchar2_table(269) := '202020617065782E6576656E742E7472696767657228272327202B20705F6974656D5F69642C20277669736962696C6974795F746F67676C6564272C207B0D0A20202020202076697369626C653A20747275652C0D0A202020207D293B0D0A202020206D';
wwv_flow_imp.g_varchar2_table(270) := '61702E7472696767657252657061696E7428293B0D0A20207D3B0D0A0D0A2020636F6E73742068696465203D202829203D3E207B0D0A202020206C436F6F6B6965203D20276E6F6E65273B0D0A202020207365744C617965725669736962696C69747950';
wwv_flow_imp.g_varchar2_table(271) := '726F7028293B0D0A20202020617065782E73746F726167652E736574436F6F6B696528274D6170626974735F47656F5261737465724C617965725F27202B20705F6974656D5F69642B20225F22202B202476282270496E7374616E636522292C20276E6F';
wwv_flow_imp.g_varchar2_table(272) := '6E6527293B0D0A20202020617065782E6576656E742E7472696767657228272327202B20705F6974656D5F69642C20277669736962696C6974795F746F67676C6564272C207B0D0A20202020202076697369626C653A2066616C73652C0D0A202020207D';
wwv_flow_imp.g_varchar2_table(273) := '293B0D0A20207D3B0D0A0D0A20202F2F205570646174652041504558206C6567656E6420666F72206D6170626F782E205761697420666F7220746865206C6567656E6420746F206265207265616479206669727374207573696E6720736574496E746572';
wwv_flow_imp.g_varchar2_table(274) := '76616C2E2041646420656E747269657320666F722074686520706C7567696E206C617965722E0D0A20202F2F20557365206120636F6F6B69652076616C756520746F2064657465726D696E652069662074686520636865636B626F782076616C75652073';
wwv_flow_imp.g_varchar2_table(275) := '686F756C64207374617274206F6E206F72206F66662E0D0A20206C657420696E74657276616C203D20736574496E74657276616C282829203D3E207B0D0A20202020636F6E7374206C6567656E64203D20617065782E6A517565727928272327202B2070';
wwv_flow_imp.g_varchar2_table(276) := '5F726567696F6E5F6964202B20275F6C6567656E6427293B0D0A2020202069662028216C6567656E6429207B0D0A20202020202072657475726E3B0D0A202020207D0D0A20202020696620286D61702E6765745374796C6528292E6C61796572732E6669';
wwv_flow_imp.g_varchar2_table(277) := '6C74657228286974656D29203D3E206974656D2E6964203D3D20705F6974656D5F696420292E6C656E677468203D3D203029207B0D0A20202020202072657475726E3B0D0A202020207D0D0A20202020636C656172496E74657276616C28696E74657276';
wwv_flow_imp.g_varchar2_table(278) := '616C293B0D0A202020202428273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E27202B200D0A202020202020273C696E7075';
wwv_flow_imp.g_varchar2_table(279) := '7420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069643D2227202B20705F6974656D5F6964202B20275F6C6567';
wwv_flow_imp.g_varchar2_table(280) := '656E645F656E74727927202B202722207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B20705F636865636B626F785F636F6C6F72202B2027223E27202B0D0A202020202020273C6C6162656C20636C61';
wwv_flow_imp.g_varchar2_table(281) := '73733D22612D4D6170526567696F6E2D6C6567656E644C6162656C22206C6179657269643D2227202B20705F6974656D5F6964202B2027222069643D2227202B20705F6974656D5F6964202B20275F6C6567656E645F656E7472795F6C6162656C27202B';
wwv_flow_imp.g_varchar2_table(282) := '20272220666F723D2227202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927202B2027223E27202B20705F7469746C65202B20273C2F6C6162656C3E27202B0D0A202020202020273C2F6469763E27292E617070656E64546F286C';
wwv_flow_imp.g_varchar2_table(283) := '6567656E64293B0D0A20202020696620286C436F6F6B6965203D3D202776697369626C652729207B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E70726F7028';
wwv_flow_imp.g_varchar2_table(284) := '27636865636B6564272C2074727565293B0D0A202020207D20656C736520696620286C436F6F6B6965203D3D20276E6F6E652729207B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E64';
wwv_flow_imp.g_varchar2_table(285) := '5F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A202020207D0D0A0D0A202020202F2F205768656E2061206C6567656E6420656E747279206368616E6765732C2073746F726520746865207669736962696C69747920';
wwv_flow_imp.g_varchar2_table(286) := '737461746520746F2074686520636F6F6B69652E0D0A20202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E6368616E676528286529203D3E207B0D0A202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(287) := '74206362203D20617065782E6A517565727928652E746172676574293B0D0A2020202020206966202863622E697328273A636865636B6564272929207B0D0A202020202020202073686F7728293B0D0A2020202020207D20656C7365207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(288) := '202020206869646528293B0D0A2020202020207D0D0A202020207D293B0D0A20207D2C20323530293B0D0A0D0A2020617065782E6974656D2E63726561746528705F6974656D5F69642C207B0D0A2020202073686F773A202829203D3E207B0D0A202020';
wwv_flow_imp.g_varchar2_table(289) := '20202073686F7728293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2074727565293B0D0A202020207D2C0D0A202020';
wwv_flow_imp.g_varchar2_table(290) := '20686964653A202829203D3E207B0D0A2020202020206869646528293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C20';
wwv_flow_imp.g_varchar2_table(291) := '66616C7365293B0D0A202020207D2C0D0A20202020697356697369626C653A202829203D3E206C436F6F6B696520213D3D20276E6F6E65272C0D0A0D0A20202020726566726573683A206173796E63202829203D3E207B0D0A2020202020206177616974';
wwv_flow_imp.g_varchar2_table(292) := '2072656672657368526173746572496E666F28293B0D0A20202020202074696C6543616368652E636C65617228293B0D0A202020202020696620286D61706C696276657273696F6E203E3D205B352C20352C20305D29207B0D0A2020202020202020666F';
wwv_flow_imp.g_varchar2_table(293) := '722028636F6E73742073206F6620736F757263654E616D657329207B0D0A202020202020202020206D61702E7265667265736854696C65732873293B0D0A20202020202020207D0D0A2020202020207D20656C7365207B0D0A2020202020202020666F72';
wwv_flow_imp.g_varchar2_table(294) := '2028636F6E7374206C206F66206C617965724E616D657329207B0D0A202020202020202020206D61702E72656D6F76654C61796572286C293B0D0A20202020202020207D0D0A2020202020202020666F722028636F6E73742073206F6620736F75726365';
wwv_flow_imp.g_varchar2_table(295) := '4E616D657329207B0D0A202020202020202020206D61702E72656D6F7665536F757263652873293B0D0A20202020202020207D0D0A20202020202020206164644C6179657228293B0D0A2020202020207D0D0A202020207D2C0D0A0D0A20202020746F67';
wwv_flow_imp.g_varchar2_table(296) := '676C655261737465724C617965723A2028746F67676C6529203D3E207B0D0A20202020202069662028747970656F6620746F67676C65203D3D3D2027756E646566696E65642729207B0D0A2020202020202020686964655261737465724C61796572203D';
wwv_flow_imp.g_varchar2_table(297) := '2021686964655261737465724C617965723B0D0A2020202020207D20656C7365207B0D0A2020202020202020686964655261737465724C61796572203D2021746F67676C653B0D0A2020202020207D0D0A2020202020207365744C617965725669736962';
wwv_flow_imp.g_varchar2_table(298) := '696C69747950726F7028293B0D0A202020207D2C0D0A0D0A20202020746F67676C6548696C6C73686164654C617965723A2028746F67676C6529203D3E207B0D0A20202020202069662028747970656F6620746F67676C65203D3D3D2027756E64656669';
wwv_flow_imp.g_varchar2_table(299) := '6E65642729207B0D0A20202020202020206869646548696C6C73686164654C61796572203D20216869646548696C6C73686164654C617965723B0D0A2020202020207D20656C7365207B0D0A20202020202020206869646548696C6C73686164654C6179';
wwv_flow_imp.g_varchar2_table(300) := '6572203D2021746F67676C653B0D0A2020202020207D0D0A2020202020207365744C617965725669736962696C69747950726F7028293B0D0A202020207D2C0D0A0D0A202020202F2A2A0D0A20202020202A205175657269657320746865206E65617265';
wwv_flow_imp.g_varchar2_table(301) := '737420736F7572636520706978656C206279206C6F636174696F6E2E0D0A20202020202A2F0D0A202020207175657279506978656C3A206173796E6320286C61742C206C6F6E29203D3E207B0D0A202020202020636F6E7374207A203D2031393B0D0A20';
wwv_flow_imp.g_varchar2_table(302) := '2020202020636F6E73742079203D206C61743274696C65287A2C206C6174293B0D0A202020202020636F6E73742078203D206C6F6E3274696C65287A2C206C6F6E293B0D0A202020202020636F6E73742074696C65203D2061776169742067657454696C';
wwv_flow_imp.g_varchar2_table(303) := '65287A2C204D6174682E666C6F6F722878292C204D6174682E666C6F6F72287929293B0D0A0D0A2020202020206966202874696C652E63656C6C6461746129207B0D0A2020202020202020636F6E7374206461746176696577203D206E65772044617461';
wwv_flow_imp.g_varchar2_table(304) := '566965772874696C652E63656C6C64617461293B0D0A2020202020202020636F6E73742064657074684279746573203D2074696C652E63656C6C6465707468202F20383B0D0A2020202020202020636F6E737420706978656C4C656E677468203D207469';
wwv_flow_imp.g_varchar2_table(305) := '6C652E62616E64636F756E74202A20646570746842797465733B0D0A2020202020202020636F6E737420726573756C74203D205B5D3B0D0A0D0A2020202020202020636F6E7374207078203D204D6174682E666C6F6F722828782025203129202A207469';
wwv_flow_imp.g_varchar2_table(306) := '6C652E7769647468293B0D0A2020202020202020636F6E7374207079203D204D6174682E666C6F6F722828792025203129202A2074696C652E686569676874293B0D0A2020202020202020636F6E7374207069203D20287079202A2074696C652E776964';
wwv_flow_imp.g_varchar2_table(307) := '746829202B2070783B0D0A0D0A2020202020202020666F7220286C65742062203D20303B2062203C2074696C652E62616E64636F756E743B2062202B2B29207B0D0A202020202020202020206966202874696C652E63656C6C6465707468203D3D203829';
wwv_flow_imp.g_varchar2_table(308) := '207B0D0A202020202020202020202020726573756C742E707573682864617461766965772E67657455696E7438287069202A20706978656C4C656E677468202B2062202A206465707468427974657329293B0D0A202020202020202020207D20656C7365';
wwv_flow_imp.g_varchar2_table(309) := '206966202874696C652E63656C6C6465707468203D3D20333229207B0D0A202020202020202020202020726573756C742E707573682864617461766965772E676574466C6F61743332287069202A20706978656C4C656E677468202B2062202A20646570';
wwv_flow_imp.g_varchar2_table(310) := '7468427974657329293B0D0A202020202020202020207D0D0A20202020202020207D0D0A0D0A202020202020202072657475726E20726573756C743B0D0A2020202020207D20656C7365207B0D0A202020202020202072657475726E206E756C6C3B0D0A';
wwv_flow_imp.g_varchar2_table(311) := '2020202020207D0D0A202020207D2C0D0A20207D293B0D0A0D0A202069662028705F6974656D5F696420696E204D4150424954535F47454F5241535445525F57414954494E4729207B0D0A20202020636F6E7374206974656D203D20617065782E697465';
wwv_flow_imp.g_varchar2_table(312) := '6D28705F6974656D5F6964293B0D0A202020204D4150424954535F47454F5241535445525F57414954494E475B705F6974656D5F69645D2E666F724561636828287829203D3E2078286974656D29293B0D0A20207D0D0A20204D4150424954535F47454F';
wwv_flow_imp.g_varchar2_table(313) := '5241535445525F57414954494E475B705F6974656D5F69645D203D206E756C6C3B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(292713777582709033)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_file_name=>'mapbits_georaster.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E7374204D4150424954535F47454F5241535445525F57414954494E473D7B7D3B66756E6374696F6E206D6170626974735F67656F7261737465725F776169745F666F725F696E69742865297B72657475726E206E65772050726F6D697365282828';
wwv_flow_imp.g_varchar2_table(2) := '742C61293D3E7B6520696E204D4150424954535F47454F5241535445525F57414954494E477C7C284D4150424954535F47454F5241535445525F57414954494E475B655D3D5B5D292C6E756C6C213D3D4D4150424954535F47454F5241535445525F5741';
wwv_flow_imp.g_varchar2_table(3) := '4954494E475B655D3F4D4150424954535F47454F5241535445525F57414954494E475B655D2E707573682828653D3E7B742865297D29293A7428617065782E6974656D286529297D29297D6173796E632066756E6374696F6E206D6170626974735F6765';
wwv_flow_imp.g_varchar2_table(4) := '6F726173746572287B705F6974656D5F69643A652C705F616A61785F6964656E7469666965723A742C705F726567696F6E5F69643A612C705F73657175656E63653A722C705F7469746C653A732C705F636865636B626F785F636F6C6F723A6E2C705F69';
wwv_flow_imp.g_varchar2_table(5) := '6E69745F7669736962696C6974793A692C705F6F7061636974793A6F2C705F7375626D69745F6974656D733A6C2C705F6C617965725F747970653A632C705F636F6C6F725F72616D703A702C705F6267636F6C6F723A642C705F65786167676572617469';
wwv_flow_imp.g_varchar2_table(6) := '6F6E3A687D297B66756E6374696F6E205F28652C74297B72657475726E20652F4D6174682E706F7728322C74292A3336302D3138307D66756E6374696F6E206728652C74297B636F6E737420613D4D6174682E50492D322A4D6174682E50492A652F4D61';
wwv_flow_imp.g_varchar2_table(7) := '74682E706F7728322C74293B72657475726E203138302F4D6174682E50492A4D6174682E6174616E282E352A284D6174682E6578702861292D4D6174682E657870282D612929297D66756E6374696F6E207528652C74297B636F6E737420613D4D617468';
wwv_flow_imp.g_varchar2_table(8) := '2E706F7728322C65292C723D28733D742C4D6174682E50492A732F313830293B76617220733B72657475726E20612A28312D4D6174682E6C6F67284D6174682E74616E2872292B312F4D6174682E636F73287229292F4D6174682E5049292F327D636F6E';
wwv_flow_imp.g_varchar2_table(9) := '737420663D286D61706C69627265676C2E67657456657273696F6E3F6D61706C69627265676C2E67657456657273696F6E28293A6D61706C69627265676C2E76657273696F6E292E73706C697428222E22292E6D61702828653D3E7061727365496E7428';
wwv_flow_imp.g_varchar2_table(10) := '652929292C793D665B305D3C342C623D663E5B352C365D2C6D3D617065782E726567696F6E2861292E63616C6C28226765744D61704F626A65637422293B6C657420492C762C4D2C782C772C413D617065782E73746F726167652E676574436F6F6B6965';
wwv_flow_imp.g_varchar2_table(11) := '28224D6170626974735F47656F5261737465724C617965725F222B652B225F222B2476282270496E7374616E63652229297C7C282259223D3D3D693F2276697369626C65223A226E6F6E6522292C523D21312C533D21312C453D5B5D2C543D5B5D3B7377';
wwv_flow_imp.g_varchar2_table(12) := '697463682863297B6361736522636F6C6F722D72656C696566223A623F28493D21302C773D2130293A28763D21302C4D3D2130293B627265616B3B6361736522726173746572223A763D21302C4D3D21303B627265616B3B636173652268696C6C736861';
wwv_flow_imp.g_varchar2_table(13) := '6465223A493D21302C783D21303B627265616B3B636173652268696C6C73686164655F636F6C6F725F72656C696566223A493D21302C783D21302C623F773D21303A28763D21302C4D3D2130293B627265616B3B64656661756C743A33323D3D432E6365';
wwv_flow_imp.g_varchar2_table(14) := '6C6C64657074683F28493D21302C783D2130293A28763D21302C4D3D2130297D636F6E737420473D653D3E7B6C657420743B72657475726E2041727261792E697341727261792865292626333D3D3D652E6C656E6774683F5B2E2E2E652C3235355D3A41';
wwv_flow_imp.g_varchar2_table(15) := '727261792E697341727261792865292626343D3D3D652E6C656E6774683F653A28743D652E6D61746368282F5E23285B412D46612D66302D395D7B367D29242F29293F5B7061727365496E7428745B315D2E73756273747228302C32292C3136292C7061';
wwv_flow_imp.g_varchar2_table(16) := '727365496E7428745B315D2E73756273747228322C32292C3136292C7061727365496E7428745B315D2E73756273747228342C32292C3136292C3235355D3A28743D652E6D61746368282F5E23285B412D46612D66302D395D7B337D29242F29293F5B31';
wwv_flow_imp.g_varchar2_table(17) := '372A7061727365496E7428745B315D5B305D2C3136292C31372A7061727365496E7428745B315D5B315D2C3136292C31372A7061727365496E7428745B315D5B325D2C3136292C3235355D3A28743D652E6D61746368282F5E23285B412D46612D66302D';
wwv_flow_imp.g_varchar2_table(18) := '395D7B387D29242F29293F5B7061727365496E7428745B315D2E73756273747228302C32292C3136292C7061727365496E7428745B315D2E73756273747228322C32292C3136292C7061727365496E7428745B315D2E73756273747228342C32292C3136';
wwv_flow_imp.g_varchar2_table(19) := '292C7061727365496E7428745B315D2E73756273747228362C32292C3136295D3A28743D652E6D61746368282F5E23285B412D46612D66302D395D7B347D29242F29293F5B31372A7061727365496E7428745B315D5B305D2C3136292C31372A70617273';
wwv_flow_imp.g_varchar2_table(20) := '65496E7428745B315D5B315D2C3136292C31372A7061727365496E7428745B315D5B325D2C3136292C31372A7061727365496E7428745B315D5B325D2C3136295D3A6E756C6C7D3B6C657420502C6B3D4728643F3F222330303030303022293B6C657420';
wwv_flow_imp.g_varchar2_table(21) := '432C4C3D313B636F6E737420423D6173796E6328293D3E7B433D617761697420617065782E7365727665722E706C7567696E28742C7B7830313A302C706167654974656D733A6C3F6C2E73706C697428222C22293A766F696420307D292C2828293D3E7B';
wwv_flow_imp.g_varchar2_table(22) := '696628215B22636F6C6F722D72656C696566222C2268696C6C73686164655F636F6C6F725F72656C696566225D2E696E636C756465732863297C7C432E6E6F5261737465722972657475726E3B503D702C507C7C28503D5B2223663365373962222C2223';
wwv_flow_imp.g_varchar2_table(23) := '666163343834222C2223663861303765222C2223656237663836222C2223636536363933222C2223613035396130222C2223356335336135225D293B636F6E737420653D7B747572626F3A5B5B2E31383939352C2E30373137362C2E32333231375D2C5B';
wwv_flow_imp.g_varchar2_table(24) := '2E31393438332C2E30383333392C2E32363134395D2C5B2E31393935362C2E30393439382C2E32393032345D2C5B2E32303431352C2E31303635322C2E33313834345D2C5B2E323038362C2E31313830322C2E33343630375D2C5B2E32313239312C2E31';
wwv_flow_imp.g_varchar2_table(25) := '323934372C2E33373331345D2C5B2E32313730382C2E31343038372C2E33393936345D2C5B2E32323131312C2E31353232332C2E34323535385D2C5B2E3232352C2E31363335342C2E34353039365D2C5B2E32323837352C2E31373438312C2E34373537';
wwv_flow_imp.g_varchar2_table(26) := '385D2C5B2E32333233362C2E31383630332C2E35303030345D2C5B2E32333538322C2E313937322C2E35323337335D2C5B2E32333931352C2E32303833332C2E35343638365D2C5B2E32343233342C2E32313934312C2E35363934325D2C5B2E32343533';
wwv_flow_imp.g_varchar2_table(27) := '392C2E32333034342C2E35393134325D2C5B2E323438332C2E32343134332C2E36313238365D2C5B2E32353130372C2E32353233372C2E36333337345D2C5B2E32353336392C2E32363332372C2E36353430365D2C5B2E32353631382C2E32373431322C';
wwv_flow_imp.g_varchar2_table(28) := '2E36373338315D2C5B2E32353835332C2E32383439322C2E3639335D2C5B2E32363037342C2E32393536382C2E37313136325D2C5B2E323632382C2E33303633392C2E37323936385D2C5B2E32363437332C2E33313730362C2E37343731385D2C5B2E32';
wwv_flow_imp.g_varchar2_table(29) := '363635322C2E33323736382C2E37363431325D2C5B2E32363831362C2E33333832352C2E373830355D2C5B2E32363936372C2E33343837382C2E37393633315D2C5B2E32373130332C2E33353932362C2E38313135365D2C5B2E32373232362C2E333639';
wwv_flow_imp.g_varchar2_table(30) := '372C2E38323632345D2C5B2E32373333342C2E33383030382C2E38343033375D2C5B2E32373432392C2E33393034332C2E38353339335D2C5B2E32373530392C2E34303037322C2E38363639325D2C5B2E32373537362C2E34313039372C2E3837393336';
wwv_flow_imp.g_varchar2_table(31) := '5D2C5B2E32373632382C2E34323131382C2E38393132335D2C5B2E32373636372C2E34333133342C2E39303235345D2C5B2E32373639312C2E34343134352C2E39313332385D2C5B2E32373730312C2E34353135322C2E39323334375D2C5B2E32373639';
wwv_flow_imp.g_varchar2_table(32) := '382C2E34363135332C2E39333330395D2C5B2E323736382C2E34373135312C2E39343231345D2C5B2E32373634382C2E34383134342C2E39353036345D2C5B2E32373630332C2E34393133322C2E39353835375D2C5B2E32373534332C2E35303131352C';
wwv_flow_imp.g_varchar2_table(33) := '2E39363539345D2C5B2E32373436392C2E35313039342C2E39373237355D2C5B2E32373338312C2E35323036392C2E39373839395D2C5B2E32373237332C2E353330342C2E39383436315D2C5B2E32373130362C2E35343031352C2E393839335D2C5B2E';
wwv_flow_imp.g_varchar2_table(34) := '32363837382C2E35343939352C2E39393330335D2C5B2E32363539322C2E35353937392C2E39393538335D2C5B2E32363235322C2E35363936372C2E39393737335D2C5B2E32353836322C2E35373935382C2E39393837365D2C5B2E32353432352C2E35';
wwv_flow_imp.g_varchar2_table(35) := '3839352C2E39393839365D2C5B2E32343934362C2E35393934332C2E39393833355D2C5B2E32343432372C2E36303933372C2E39393639375D2C5B2E32333837342C2E36313933312C2E39393438355D2C5B2E32333238382C2E36323932332C2E393932';
wwv_flow_imp.g_varchar2_table(36) := '30325D2C5B2E32323637362C2E36333931332C2E39383835315D2C5B2E32323033392C2E36343930312C2E39383433365D2C5B2E32313338322C2E36353838362C2E39373935395D2C5B2E32303730382C2E36363836362C2E39373432335D2C5B2E3230';
wwv_flow_imp.g_varchar2_table(37) := '3032312C2E36373834322C2E39363833335D2C5B2E31393332362C2E36383831322C2E393631395D2C5B2E31383632352C2E36393737352C2E39353439385D2C5B2E31373932332C2E37303733322C2E39343736315D2C5B2E31373232332C2E37313638';
wwv_flow_imp.g_varchar2_table(38) := '2C2E39333938315D2C5B2E31363532392C2E373236322C2E39333136315D2C5B2E31353834342C2E37333535312C2E39323330355D2C5B2E31353137332C2E37343437322C2E39313431365D2C5B2E31343531392C2E37353338312C2E39303439365D2C';
wwv_flow_imp.g_varchar2_table(39) := '5B2E31333838362C2E37363237392C2E383935355D2C5B2E31333237382C2E37373136352C2E383835385D2C5B2E31323639382C2E37383033372C2E383735395D2C5B2E31323135312C2E37383839362C2E38363538315D2C5B2E31313633392C2E3739';
wwv_flow_imp.g_varchar2_table(40) := '37342C2E38353535395D2C5B2E31313136372C2E38303536392C2E38343532355D2C5B2E31303733382C2E38313338312C2E38333438345D2C5B2E31303335372C2E38323137372C2E38323433375D2C5B2E31303032362C2E38323935352C2E38313338';
wwv_flow_imp.g_varchar2_table(41) := '395D2C5B2E303937352C2E38333731342C2E38303334325D2C5B2E30393533322C2E38343435352C2E37393239395D2C5B2E30393337372C2E38353137352C2E37383236345D2C5B2E30393238372C2E38353837352C2E373732345D2C5B2E3039323637';
wwv_flow_imp.g_varchar2_table(42) := '2C2E38363535342C2E373632335D2C5B2E303933322C2E38373231312C2E37353233375D2C5B2E30393435312C2E38373834342C2E37343236355D2C5B2E30393636322C2E38383435342C2E37333331365D2C5B2E30393935382C2E383930342C2E3732';
wwv_flow_imp.g_varchar2_table(43) := '3339335D2C5B2E31303334322C2E3839362C2E3731355D2C5B2E31303831352C2E39303134322C2E37303539395D2C5B2E31313337342C2E39303637332C2E36393635315D2C5B2E31323031342C2E39313139332C2E363836365D2C5B2E31323733332C';
wwv_flow_imp.g_varchar2_table(44) := '2E39313730312C2E36373632375D2C5B2E31333532362C2E39323139372C2E36363535365D2C5B2E31343339312C2E393236382C2E36353434385D2C5B2E31353332332C2E39333135312C2E36343330385D2C5B2E31363331392C2E39333630392C2E36';
wwv_flow_imp.g_varchar2_table(45) := '333133375D2C5B2E31373337372C2E39343035332C2E36313933385D2C5B2E31383439312C2E39343438342C2E36303731335D2C5B2E31393635392C2E39343930312C2E35393436365D2C5B2E32303837372C2E39353330342C2E35383139395D2C5B2E';
wwv_flow_imp.g_varchar2_table(46) := '32323134322C2E39353639322C2E35363931345D2C5B2E32333434392C2E39363036352C2E35353631345D2C5B2E32343739372C2E39363432332C2E35343330335D2C5B2E323631382C2E39363736352C2E35323938315D2C5B2E32373539372C2E3937';
wwv_flow_imp.g_varchar2_table(47) := '3039322C2E35313635335D2C5B2E32393034322C2E39373430332C2E35303332315D2C5B2E33303531332C2E39373639372C2E34383938375D2C5B2E33323030362C2E39373937342C2E34373635345D2C5B2E33333531372C2E39383233342C2E343633';
wwv_flow_imp.g_varchar2_table(48) := '32355D2C5B2E33353034332C2E39383437372C2E34353030325D2C5B2E33363538312C2E39383730322C2E34333638385D2C5B2E33383132372C2E39383930392C2E34323338365D2C5B2E33393637382C2E39393039382C2E34313039385D2C5B2E3431';
wwv_flow_imp.g_varchar2_table(49) := '3232392C2E39393236382C2E33393832365D2C5B2E34323737382C2E39393431392C2E33383537355D2C5B2E34343332312C2E39393535312C2E33373334355D2C5B2E34353835342C2E39393636332C2E333631345D2C5B2E34373337352C2E39393735';
wwv_flow_imp.g_varchar2_table(50) := '352C2E33343936335D2C5B2E34383837392C2E39393832382C2E33333831365D2C5B2E35303336322C2E39393837392C2E33323730315D2C5B2E35313832322C2E393939312C2E33313632325D2C5B2E35333235352C2E39393931392C2E33303538315D';
wwv_flow_imp.g_varchar2_table(51) := '2C5B2E35343635382C2E39393930372C2E32393538315D2C5B2E35363032362C2E39393837332C2E32383632335D2C5B2E35373335372C2E39393831372C2E32373731325D2C5B2E35383634362C2E39393733392C2E32363834395D2C5B2E3539383931';
wwv_flow_imp.g_varchar2_table(52) := '2C2E39393633382C2E32363033385D2C5B2E36313038382C2E39393531342C2E323532385D2C5B2E36323233332C2E39393336362C2E32343537395D2C5B2E36333332332C2E39393139352C2E32333933375D2C5B2E36343336322C2E39383939392C2E';
wwv_flow_imp.g_varchar2_table(53) := '32333335365D2C5B2E36353339342C2E39383737352C2E32323833355D2C5B2E36363432382C2E39383532342C2E323233375D2C5B2E36373436322C2E39383234362C2E323139365D2C5B2E36383439342C2E39373934312C2E32313630325D2C5B2E36';
wwv_flow_imp.g_varchar2_table(54) := '393532352C2E393736312C2E32313239345D2C5B2E37303535332C2E39373235352C2E32313033325D2C5B2E37313537372C2E39363837352C2E32303831355D2C5B2E37323539362C2E393634372C2E323036345D2C5B2E373336312C2E39363034332C';
wwv_flow_imp.g_varchar2_table(55) := '2E32303530345D2C5B2E37343631372C2E39353539332C2E32303430365D2C5B2E37353631372C2E39353132312C2E32303334335D2C5B2E37363630382C2E39343632372C2E32303331315D2C5B2E37373539312C2E39343131332C2E323033315D2C5B';
wwv_flow_imp.g_varchar2_table(56) := '2E37383536332C2E39333537392C2E32303333365D2C5B2E37393532342C2E39333032352C2E32303338365D2C5B2E38303437332C2E39323435322C2E32303435395D2C5B2E383134312C2E39313836312C2E32303535325D2C5B2E38323333332C2E39';
wwv_flow_imp.g_varchar2_table(57) := '313235332C2E32303636335D2C5B2E38333234312C2E39303632372C2E32303738385D2C5B2E38343133332C2E38393938362C2E32303932365D2C5B2E383530312C2E38393332382C2E32313037345D2C5B2E38353836382C2E38383635352C2E323132';
wwv_flow_imp.g_varchar2_table(58) := '335D2C5B2E38363730392C2E38373936382C2E32313339315D2C5B2E383735332C2E38373236372C2E32313535355D2C5B2E38383333312C2E38363535332C2E32313731395D2C5B2E38393131322C2E38353832362C2E323138385D2C5B2E383938372C';
wwv_flow_imp.g_varchar2_table(59) := '2E38353038372C2E32323033385D2C5B2E39303630352C2E38343333372C2E32323138385D2C5B2E39313331372C2E38333537362C2E32323332385D2C5B2E39323030342C2E38323830362C2E32323435365D2C5B2E39323636362C2E38323032352C2E';
wwv_flow_imp.g_varchar2_table(60) := '323235375D2C5B2E39333330312C2E38313233362C2E32323636375D2C5B2E39333930392C2E38303433392C2E32323734345D2C5B2E39343438392C2E37393633342C2E3232385D2C5B2E39353033392C2E37383832332C2E32323833315D2C5B2E3935';
wwv_flow_imp.g_varchar2_table(61) := '35362C2E37383030352C2E32323833365D2C5B2E39363034392C2E37373138312C2E32323831315D2C5B2E39363530372C2E37363335322C2E32323735345D2C5B2E39363933312C2E37353531392C2E32323636335D2C5B2E39373332332C2E37343638';
wwv_flow_imp.g_varchar2_table(62) := '322C2E32323533365D2C5B2E39373637392C2E37333834322C2E32323336395D2C5B2E39382C2E37332C2E32323136315D2C5B2E39383238392C2E373231342C2E32313931385D2C5B2E39383534392C2E373132352C2E323136355D2C5B2E3938373831';
wwv_flow_imp.g_varchar2_table(63) := '2C2E373033332C2E32313335385D2C5B2E39383938362C2E36393338322C2E32313034335D2C5B2E39393136332C2E36383430382C2E32303730365D2C5B2E39393331342C2E36373430382C2E32303334385D2C5B2E39393433382C2E36363338362C2E';
wwv_flow_imp.g_varchar2_table(64) := '31393937315D2C5B2E39393533352C2E36353334312C2E31393537375D2C5B2E39393630372C2E36343237372C2E31393136355D2C5B2E39393635342C2E36333139332C2E31383733385D2C5B2E39393637352C2E36323039332C2E31383239375D2C5B';
wwv_flow_imp.g_varchar2_table(65) := '2E39393637322C2E36303937372C2E31373834325D2C5B2E39393634342C2E35393834362C2E31373337365D2C5B2E39393539332C2E35383730332C2E31363839395D2C5B2E39393531372C2E35373534392C2E31363431325D2C5B2E39393431392C2E';
wwv_flow_imp.g_varchar2_table(66) := '35363338362C2E31353931385D2C5B2E39393239372C2E35353231342C2E31353431375D2C5B2E39393135332C2E35343033362C2E313439315D2C5B2E39383938372C2E35323835342C2E31343339385D2C5B2E39383739392C2E35313636372C2E3133';
wwv_flow_imp.g_varchar2_table(67) := '3838335D2C5B2E393835392C2E35303437392C2E31333336375D2C5B2E393833362C2E34393239312C2E31323834395D2C5B2E39383130382C2E34383130342C2E31323333325D2C5B2E39373833372C2E343639322C2E31313831375D2C5B2E39373534';
wwv_flow_imp.g_varchar2_table(68) := '352C2E343537342C2E31313330355D2C5B2E39373233342C2E34343536352C2E31303739375D2C5B2E39363930342C2E34333339392C2E31303239345D2C5B2E39363535352C2E34323234312C2E30393739385D2C5B2E39363138372C2E34313039332C';
wwv_flow_imp.g_varchar2_table(69) := '2E303933315D2C5B2E39353830312C2E33393935382C2E30383833315D2C5B2E39353339382C2E33383833362C2E30383336325D2C5B2E39343937372C2E33373732392C2E30373930355D2C5B2E39343533382C2E33363633382C2E30373436315D2C5B';
wwv_flow_imp.g_varchar2_table(70) := '2E39343038342C2E33353536362C2E30373033315D2C5B2E39333631322C2E33343531332C2E30363631365D2C5B2E39333132352C2E33333438322C2E30363231385D2C5B2E39323632332C2E33323437332C2E30353833375D2C5B2E39323130352C2E';
wwv_flow_imp.g_varchar2_table(71) := '33313438392C2E30353437355D2C5B2E39313537322C2E333035332C2E30353133345D2C5B2E39313032342C2E32393539392C2E30343831345D2C5B2E39303436332C2E32383639362C2E30343531365D2C5B2E38393838382C2E32373832342C2E3034';
wwv_flow_imp.g_varchar2_table(72) := '3234335D2C5B2E38393239382C2E32363938312C2E30333939335D2C5B2E38383639312C2E32363135322C2E30333735335D2C5B2E38383036362C2E32353333342C2E30333532315D2C5B2E38373432322C2E32343532362C2E30333239375D2C5B2E38';
wwv_flow_imp.g_varchar2_table(73) := '3637362C2E323337332C2E30333038325D2C5B2E38363037392C2E32323934352C2E30323837355D2C5B2E383533382C2E323231372C2E30323637375D2C5B2E38343636322C2E32313430372C2E30323438375D2C5B2E38333932362C2E32303635342C';
wwv_flow_imp.g_varchar2_table(74) := '2E30323330355D2C5B2E38333137322C2E31393931322C2E30323133315D2C5B2E38323339392C2E31393138322C2E30313936365D2C5B2E38313630382C2E31383436322C2E30313830395D2C5B2E38303739392C2E31373735332C2E303136365D2C5B';
wwv_flow_imp.g_varchar2_table(75) := '2E37393937312C2E31373035352C2E303135325D2C5B2E37393132352C2E31363336382C2E30313338375D2C5B2E373832362C2E31353639332C2E30313236345D2C5B2E37373337372C2E31353032382C2E30313134385D2C5B2E37363437362C2E3134';
wwv_flow_imp.g_varchar2_table(76) := '3337342C2E30313034315D2C5B2E37353535362C2E31333733312C2E30303934325D2C5B2E37343631372C2E31333039382C2E30303835315D2C5B2E37333636312C2E31323437372C2E30303736395D2C5B2E37323638362C2E31313836372C2E303036';
wwv_flow_imp.g_varchar2_table(77) := '39355D2C5B2E37313639322C2E31313236382C2E30303632395D2C5B2E373036382C2E313036382C2E30303537315D2C5B2E363936352C2E31303130322C2E30303532325D2C5B2E36383630322C2E30393533362C2E30303438315D2C5B2E3637353335';
wwv_flow_imp.g_varchar2_table(78) := '2C2E303839382C2E30303434395D2C5B2E36363434392C2E30383433362C2E30303432345D2C5B2E36353334352C2E30373930322C2E30303430385D2C5B2E36343232332C2E303733382C2E30303430315D2C5B2E36333038322C2E30363836382C2E30';
wwv_flow_imp.g_varchar2_table(79) := '303430315D2C5B2E36313932332C2E30363336372C2E303034315D2C5B2E36303734362C2E30353837382C2E30303432375D2C5B2E353935352C2E30353339392C2E30303435335D2C5B2E35383333362C2E30343933312C2E30303438365D2C5B2E3537';
wwv_flow_imp.g_varchar2_table(80) := '3130332C2E30343437342C2E30303532395D2C5B2E35353835322C2E30343032382C2E30303537395D2C5B2E35343538332C2E30333539332C2E30303633385D2C5B2E35333239352C2E30333136392C2E30303730355D2C5B2E35313938392C2E303237';
wwv_flow_imp.g_varchar2_table(81) := '35362C2E303037385D2C5B2E35303636342C2E30323335342C2E30303836335D2C5B2E34393332312C2E30313936332C2E30303935355D2C5B2E343739362C2E30313538332C2E30313035355D5D2E6D61702828653D3E652E6D61702828653D3E323535';
wwv_flow_imp.g_varchar2_table(82) := '2A65292929297D3B2266756E6374696F6E223D3D747970656F662050262628503D50287B6D696E3A432E72616E67655B305D2C6D61783A432E72616E67655B315D2C6D65616E3A432E6D65616E2C6D656469616E3A432E6D656469616E2C73746465763A';
wwv_flow_imp.g_varchar2_table(83) := '432E73746465767D2C6529292C41727261792E69734172726179285029262628503D7B73746F70733A507D292C502E747970657C7C3D2273657175656E7469616C222C41727261792E6973417272617928502E73746F70735B305D292626323D3D3D502E';
wwv_flow_imp.g_varchar2_table(84) := '73746F70735B305D2E6C656E6774687C7C28502E73746F70733D502E73746F70732E6D6170282828652C74293D3E5B742F28502E73746F70732E6C656E6774682D31292A28432E72616E67655B315D2D432E72616E67655B305D292B432E72616E67655B';
wwv_flow_imp.g_varchar2_table(85) := '305D2C655D2929293B666F7228636F6E73742065206F6620502E73746F707329655B315D3D4728655B315D297D2928297D3B6177616974204228293B636F6E737420443D2D3165342C4F3D653D3E7B696628653C442972657475726E5B302C302C302C30';
wwv_flow_imp.g_varchar2_table(86) := '5D3B696628653C3D502E73746F70735B305D5B305D2972657475726E20502E73746F70735B305D5B315D3B696628653E3D502E73746F70735B502E73746F70732E6C656E6774682D315D5B305D2972657475726E20502E73746F70735B502E73746F7073';
wwv_flow_imp.g_varchar2_table(87) := '2E6C656E6774682D315D5B315D3B666F72286C657420733D303B733C502E73746F70732E6C656E6774683B732B2B29696628653C3D502E73746F70735B732B315D5B305D2972657475726E20743D502E73746F70735B735D5B315D2C613D502E73746F70';
wwv_flow_imp.g_varchar2_table(88) := '735B732B315D5B315D2C723D28652D502E73746F70735B735D5B305D292F28502E73746F70735B732B315D5B305D2D502E73746F70735B735D5B305D292C5B745B305D2A28312D72292B615B305D2A722C745B315D2A28312D72292B615B315D2A722C74';
wwv_flow_imp.g_varchar2_table(89) := '5B325D2A28312D72292B615B325D2A722C745B335D2A28312D72292B615B335D2A725D3B76617220742C612C727D3B636F6E7374206A3D6E657720636C6173737B636F6E7374727563746F7228653D313030297B746869732E5F63616368653D6E657720';
wwv_flow_imp.g_varchar2_table(90) := '4D61702C746869732E5F726563656E743D5B5D2C746869732E5F73697A653D657D6861732865297B72657475726E20746869732E5F63616368652E6861732865297D6765742865297B696628746869732E5F63616368652E686173286529297B636F6E73';
wwv_flow_imp.g_varchar2_table(91) := '7420743D746869732E5F726563656E742E696E6465784F662865293B72657475726E20746869732E5F726563656E742E73706C69636528742C31292C746869732E5F726563656E742E707573682865292C746869732E5F63616368652E6765742865297D';
wwv_flow_imp.g_varchar2_table(92) := '7D70757428652C74297B636F6E737420613D746869732E5F726563656E742E696E6465784F662865293B613E3D303F746869732E5F726563656E742E73706C69636528612C31293A746869732E5F726563656E742E6C656E6774683E3D746869732E5F73';
wwv_flow_imp.g_varchar2_table(93) := '697A65262628746869732E5F63616368652E64656C65746528746869732E5F726563656E745B305D292C746869732E5F726563656E742E73706C69636528302C3129292C746869732E5F726563656E742E707573682865292C746869732E5F6361636865';
wwv_flow_imp.g_varchar2_table(94) := '2E73657428652C74297D636C65617228297B746869732E5F63616368652E636C65617228292C746869732E5F726563656E743D5B5D7D7D2C553D6173796E6328612C722C73293D3E7B636F6E7374206E3D60247B617D2F247B727D2F247B737D603B6966';
wwv_flow_imp.g_varchar2_table(95) := '286A2E686173286E292972657475726E206177616974206A2E676574286E293B636F6E737420693D5F28722C61292C6F3D6728732C61292C633D5F28722B312C61292C703D6728732B312C61292C643D286173796E6328293D3E7B636F6E7374206E3D61';
wwv_flow_imp.g_varchar2_table(96) := '7761697420617065782E7365727665722E706C7567696E28742C7B7830313A312C7830323A6B2E6A6F696E28222C22292C7830333A692C7830343A6F2C7830353A632C7830363A702C7830373A2227222B612B222C222B722B222C222B732B2227222C78';
wwv_flow_imp.g_varchar2_table(97) := '30383A652C706167654974656D733A6C3F6C2E73706C697428222C22293A766F696420307D293B6966286E2E63656C6C64617461297B636F6E737420653D61746F62286E2E63656C6C64617461292C743D652E6C656E6774682C613D6E65772055696E74';
wwv_flow_imp.g_varchar2_table(98) := '3841727261792874293B666F72286C657420723D303B723C743B722B2B29615B725D3D652E63686172436F646541742872293B6E2E63656C6C646174613D612E6275666665727D72657475726E206E7D2928293B72657475726E206A2E707574286E2C64';
wwv_flow_imp.g_varchar2_table(99) := '292C617761697420647D3B6173796E632066756E6374696F6E207128742C61297B696628432E6572726F722972657475726E7B646174613A6E756C6C7D3B432E6974656D6964213D652626616C65727428432E6974656D69642B2220213D20222B65292C';
wwv_flow_imp.g_varchar2_table(100) := '303D3D432E6D6178707972616D69646C6576656C2626636F6E736F6C652E7761726E28224D6170626974732047656F526173746572204C61796572205B222B652B225D206973206D697373696E6720707972616D6964732E204275696C6420707972616D';
wwv_flow_imp.g_varchar2_table(101) := '69647320746F20696D70726F766520706572666F726D616E63652E22293B636F6E737420723D6E657720526567457870282F3A5C2F5C2F282E2B295C2F282E2B295C2F285C642B295C2F285C642B295C2F285C642B292F292C733D742E75726C2E6D6174';
wwv_flow_imp.g_varchar2_table(102) := '63682872293B6966282173297468726F77206E6577204572726F7228224D616C666F726D65642055524C3A205B222B742E75726C2B225D22293B636F6E7374206E3D735B325D2C693D5B7061727365496E7428735B335D292C7061727365496E7428735B';
wwv_flow_imp.g_varchar2_table(103) := '345D292C7061727365496E7428735B355D295D2C6F3D285F28695B315D2C695B305D292C6728695B325D2C695B305D292C5F28695B315D2B312C695B305D292C6728695B325D2B312C695B305D292C6177616974205528695B305D2C695B315D2C695B32';
wwv_flow_imp.g_varchar2_table(104) := '5D29293B696628303D3D6F2E77696474687C7C303D3D6F2E6865696768747C7C6F2E6E6F5261737465722972657475726E7B63616E63656C3A28293D3E7B7D7D3B636F6E7374206C3D646F63756D656E742E637265617465456C656D656E74282263616E';
wwv_flow_imp.g_varchar2_table(105) := '76617322292C703D6C2E676574436F6E7465787428223264222C7B77696C6C526561644672657175656E746C793A21307D293B6C2E7374796C652E646973706C61793D226E6F6E65223B636F6E737420643D702E637265617465496D6167654461746128';
wwv_flow_imp.g_varchar2_table(106) := '6F2E77696474682C6F2E686569676874292C683D6E6577204461746156696577286F2E63656C6C64617461292C753D682E627974654C656E6774682C663D313D3D6F2E62616E64636F756E74262633323D3D6F2E63656C6C64657074683B696628227261';
wwv_flow_imp.g_varchar2_table(107) := '73746572223D3D3D6E296966285B22636F6C6F722D72656C696566222C2268696C6C73686164655F636F6C6F725F72656C696566225D2E696E636C75646573286329297B6966282166297468726F77206E6577204572726F72286043616E6E6F7420636F';
wwv_flow_imp.g_varchar2_table(108) := '6E76657274207468652070726F7669646564207261737465722028247B6F2E62616E64636F756E747D2062616E64732C20247B6F2E63656C6C64657074687D2D62697420706978656C732920746F20612044454D206C6179657260293B666F72286C6574';
wwv_flow_imp.g_varchar2_table(109) := '20653D303B653C753B652B3D34297B636F6E737420743D682E676574466C6F6174333228652C2131292C5B612C722C732C6E5D3D4F2874293B642E646174615B655D3D612C642E646174615B652B315D3D722C642E646174615B652B325D3D732C642E64';
wwv_flow_imp.g_varchar2_table(110) := '6174615B652B335D3D6E7D7D656C73657B696628215B332C345D2E696E636C75646573286F2E62616E64636F756E74297C7C38213D3D6F2E63656C6C6465707468297468726F77206E6577204572726F72286043616E6E6F7420636F6E76657274207468';
wwv_flow_imp.g_varchar2_table(111) := '652070726F7669646564207261737465722028247B6F2E62616E64636F756E747D2062616E64732C20247B6F2E63656C6C64657074687D2D62697420706978656C732920746F20616E20524742206C6179657260293B696628333D3D3D6F2E62616E6463';
wwv_flow_imp.g_varchar2_table(112) := '6F756E7429666F72286C657420653D302C743D303B653C753B652B3D3329642E646174615B745D3D682E67657455696E74382865292C642E646174615B742B315D3D682E67657455696E743828652B31292C642E646174615B742B325D3D682E67657455';
wwv_flow_imp.g_varchar2_table(113) := '696E743828652B32292C642E646174615B745D3D3D6B5B305D2626642E646174615B742B315D3D3D6B5B315D2626642E646174615B742B325D3D3D6B5B325D3F642E646174615B742B335D3D303A642E646174615B742B335D3D3235352C742B3D343B65';
wwv_flow_imp.g_varchar2_table(114) := '6C736520666F72286C657420653D302C743D303B653C753B652B3D3429642E646174615B745D3D682E67657455696E74382865292C642E646174615B742B315D3D682E67657455696E743828652B31292C642E646174615B742B325D3D682E6765745569';
wwv_flow_imp.g_varchar2_table(115) := '6E743828652B32292C642E646174615B742B335D3D682E67657455696E743828652B33292C742B3D347D656C736520696628227261737465722D64656D223D3D3D6E297B6966282166297468726F77206E6577204572726F72286043616E6E6F7420636F';
wwv_flow_imp.g_varchar2_table(116) := '6E76657274207468652070726F7669646564207261737465722028247B6F2E62616E64636F756E747D2062616E64732C20247B6F2E63656C6C64657074687D2D62697420706978656C732920746F20612044454D206C6179657260293B666F72286C6574';
wwv_flow_imp.g_varchar2_table(117) := '20653D303B653C753B652B3D34297B636F6E737420743D682E676574466C6F6174333228652C2131292C613D2828743C443F303A74292D44292F2E312C723D4D6174682E666C6F6F7228612F3635353336292C733D4D6174682E666C6F6F722828612D32';
wwv_flow_imp.g_varchar2_table(118) := '35362A722A323536292F323536292C6E3D612D3235362A722A3235362D3235362A733B642E646174615B655D3D722C642E646174615B652B315D3D732C642E646174615B652B325D3D6E2C642E646174615B652B335D3D3235357D7D227261737465722D';
wwv_flow_imp.g_varchar2_table(119) := '64656D223D3D3D6E262628702E66696C6C5374796C653D2272676228312C203133342C2031363029222C702E66696C6C5265637428302C302C6C2E77696474682C6C2E68656967687429292C6C2E77696474683D3235362C6C2E6865696768743D323536';
wwv_flow_imp.g_varchar2_table(120) := '2C702E707574496D6167654461746128642C302C302C302C302C3235362C323536293B72657475726E7B646174613A6177616974206E65772050726F6D6973652828653D3E7B6C2E746F426C6F6228286173796E6320743D3E7B6528617761697420742E';
wwv_flow_imp.g_varchar2_table(121) := '61727261794275666665722829297D29297D29297D7D636F6E737420463D28293D3E7B636F6E737420743D28742C61293D3E7B636F6E737420723D652B222D222B743B6D2E6765744C6179657228722926266D2E7365744C61796F757450726F70657274';
wwv_flow_imp.g_varchar2_table(122) := '7928722C227669736962696C697479222C2276697369626C6522213D3D417C7C613F226E6F6E65223A2276697369626C6522297D3B74282272656C696566222C52292C74282268696C6C7368616465222C53292C742822726173746572222C52297D3B6C';
wwv_flow_imp.g_varchar2_table(123) := '6574204E3B636F6E737420573D28293D3E7B6966284C2B2B2C453D5B5D2C543D5B5D2C49297B636F6E737420743D7B747970653A227261737465722D64656D222C74696C65733A5B6067656F7261737465725F247B657D3A2F2F247B657D2F7261737465';
wwv_flow_imp.g_varchar2_table(124) := '722D64656D2F7B7A7D2F7B787D2F7B797D2F72656672657368247B4C7D605D2C74696C6553697A653A3235367D3B6D2E616464536F75726365282267656F72617374657244454D536F757263655F222B4C2B225F222B652C74292C452E70757368282267';
wwv_flow_imp.g_varchar2_table(125) := '656F72617374657244454D536F757263655F222B4C2B225F222B65297D69662876297B636F6E737420743D7B747970653A22726173746572222C74696C65733A5B6067656F7261737465725F247B657D3A2F2F247B657D2F7261737465722F7B7A7D2F7B';
wwv_flow_imp.g_varchar2_table(126) := '787D2F7B797D2F72656672657368247B4C7D605D2C74696C6553697A653A3235367D3B6D2E616464536F75726365282267656F726173746572536F757263655F222B4C2B225F222B652C74292C452E70757368282267656F726173746572536F75726365';
wwv_flow_imp.g_varchar2_table(127) := '5F222B4C2B225F222B65297D636F6E737420743D653D3E7B542E7075736828652E6964293B636F6E737420743D6D2E6765745374796C6528292E6C61796572732E66696C746572282866756E6374696F6E2865297B72657475726E226D65746164617461';
wwv_flow_imp.g_varchar2_table(128) := '22696E20652626226C617965725F73657175656E636522696E20652E6D657461646174617D29292E6D6170282866756E6374696F6E2865297B72657475726E5B652E6D657461646174612E6C617965725F73657175656E63652C652E69645D7D29293B6C';
wwv_flow_imp.g_varchar2_table(129) := '657420613B69662830213D3D742E6C656E677468297B742E736F7274282828652C74293D3E655B305D2D745B305D29293B666F72286C657420653D303B653C742E6C656E6774683B652B2B29696628723C745B655D5B305D297B613D745B655D5B315D3B';
wwv_flow_imp.g_varchar2_table(130) := '627265616B7D7D6D2E6164644C6179657228652C61297D3B4D262674287B69643A652B222D726173746572222C747970653A22726173746572222C736F757263653A2267656F726173746572536F757263655F222B4C2B225F222B652C6D657461646174';
wwv_flow_imp.g_varchar2_table(131) := '613A7B6C617965725F73657175656E63653A727D2C6C61796F75743A7B7669736962696C6974793A226E6F6E65227D7D292C78262674287B69643A652B222D68696C6C7368616465222C747970653A2268696C6C7368616465222C736F757263653A2267';
wwv_flow_imp.g_varchar2_table(132) := '656F72617374657244454D536F757263655F222B4C2B225F222B652C7061696E743A7B7D2C6D657461646174613A7B6C617965725F73657175656E63653A727D2C6C61796F75743A7B7669736962696C6974793A226E6F6E65227D7D292C77262674287B';
wwv_flow_imp.g_varchar2_table(133) := '69643A652B222D72656C696566222C747970653A22636F6C6F722D72656C696566222C736F757263653A2267656F72617374657244454D536F757263655F222B4C2B225F222B652C7061696E743A7B22636F6C6F722D72656C6965662D6F706163697479';
wwv_flow_imp.g_varchar2_table(134) := '223A6F3F3F317D2C6D657461646174613A7B6C617965725F73657175656E63653A727D2C6C61796F75743A7B7669736962696C6974793A226E6F6E65227D7D292C49262628665B305D3E3D3526266D2E73657443656E746572436C616D706564546F4772';
wwv_flow_imp.g_varchar2_table(135) := '6F756E64282131292C4E26266D2E72656D6F7665436F6E74726F6C284E292C4E3D6E6577206D61706C69627265676C2E5465727261696E436F6E74726F6C287B736F757263653A2267656F72617374657244454D536F757263655F222B4C2B225F222B65';
wwv_flow_imp.g_varchar2_table(136) := '2C657861676765726174696F6E3A7061727365466C6F617428683F3F31297D292C6D2E616464436F6E74726F6C284E29292C4628297D3B5728292C793F6D61706C69627265676C2E61646450726F746F636F6C282267656F7261737465725F222B652C28';
wwv_flow_imp.g_varchar2_table(137) := '28652C74293D3E28712865292E7468656E2828653D3E7B74286E756C6C2C652E646174612C6E756C6C2C6E756C6C297D29292E63617463682828653D3E7B742865297D29292C7B63616E63656C3A28293D3E7B7D7D2929293A6D61706C69627265676C2E';
wwv_flow_imp.g_varchar2_table(138) := '61646450726F746F636F6C282267656F7261737465725F222B652C286173796E6328652C74293D3E6177616974207128652929293B636F6E737420513D28293D3E7B413D2276697369626C65222C4628292C617065782E73746F726167652E736574436F';
wwv_flow_imp.g_varchar2_table(139) := '6F6B696528224D6170626974735F47656F5261737465724C617965725F222B652B225F222B2476282270496E7374616E636522292C2276697369626C6522292C617065782E6576656E742E74726967676572282223222B652C227669736962696C697479';
wwv_flow_imp.g_varchar2_table(140) := '5F746F67676C6564222C7B76697369626C653A21307D292C6D2E7472696767657252657061696E7428297D2C7A3D28293D3E7B413D226E6F6E65222C4628292C617065782E73746F726167652E736574436F6F6B696528224D6170626974735F47656F52';
wwv_flow_imp.g_varchar2_table(141) := '61737465724C617965725F222B652B225F222B2476282270496E7374616E636522292C226E6F6E6522292C617065782E6576656E742E74726967676572282223222B652C227669736962696C6974795F746F67676C6564222C7B76697369626C653A2131';
wwv_flow_imp.g_varchar2_table(142) := '7D297D3B6C657420563D736574496E74657276616C282828293D3E7B636F6E737420743D617065782E6A5175657279282223222B612B225F6C6567656E6422293B74262630213D6D2E6765745374796C6528292E6C61796572732E66696C746572282874';
wwv_flow_imp.g_varchar2_table(143) := '3D3E742E69643D3D6529292E6C656E677468262628636C656172496E74657276616C2856292C2428273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D';
wwv_flow_imp.g_varchar2_table(144) := '6869646561626C65223E3C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069643D22272B652B275F';
wwv_flow_imp.g_varchar2_table(145) := '6C6567656E645F656E74727922207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B6E2B27223E3C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C22206C6179';
wwv_flow_imp.g_varchar2_table(146) := '657269643D22272B652B27222069643D22272B652B275F6C6567656E645F656E7472795F6C6162656C2220666F723D22272B652B275F6C6567656E645F656E747279223E272B732B223C2F6C6162656C3E3C2F6469763E22292E617070656E64546F2874';
wwv_flow_imp.g_varchar2_table(147) := '292C2276697369626C65223D3D413F617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C2130293A226E6F6E65223D3D412626617065782E6A5175657279282223222B652B225F';
wwv_flow_imp.g_varchar2_table(148) := '6C6567656E645F656E74727922292E70726F702822636865636B6564222C2131292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E6368616E67652828653D3E7B617065782E6A517565727928652E7461726765';
wwv_flow_imp.g_varchar2_table(149) := '74292E697328223A636865636B656422293F5128293A7A28297D2929297D292C323530293B696628617065782E6974656D2E63726561746528652C7B73686F773A28293D3E7B5128292C617065782E6A5175657279282223222B652B225F6C6567656E64';
wwv_flow_imp.g_varchar2_table(150) := '5F656E74727922292E70726F702822636865636B6564222C2130297D2C686964653A28293D3E7B7A28292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C2131297D2C6973';
wwv_flow_imp.g_varchar2_table(151) := '56697369626C653A28293D3E226E6F6E6522213D3D412C726566726573683A6173796E6328293D3E7B6966286177616974204228292C6A2E636C65617228292C663E3D5B352C352C305D29666F7228636F6E73742065206F662045296D2E726566726573';
wwv_flow_imp.g_varchar2_table(152) := '6854696C65732865293B656C73657B666F7228636F6E73742065206F662054296D2E72656D6F76654C617965722865293B666F7228636F6E73742065206F662045296D2E72656D6F7665536F757263652865293B5728297D7D2C746F67676C6552617374';
wwv_flow_imp.g_varchar2_table(153) := '65724C617965723A653D3E7B523D766F696420303D3D3D653F21523A21652C4628297D2C746F67676C6548696C6C73686164654C617965723A653D3E7B533D766F696420303D3D3D653F21533A21652C4628297D2C7175657279506978656C3A6173796E';
wwv_flow_imp.g_varchar2_table(154) := '6328652C74293D3E7B636F6E737420613D752831392C65292C723D66756E6374696F6E28652C74297B72657475726E204D6174682E706F7728322C65292A2828742B313830292F333630297D2831392C74292C733D617761697420552831392C4D617468';
wwv_flow_imp.g_varchar2_table(155) := '2E666C6F6F722872292C4D6174682E666C6F6F72286129293B696628732E63656C6C64617461297B636F6E737420653D6E657720446174615669657728732E63656C6C64617461292C743D732E63656C6C64657074682F382C6E3D732E62616E64636F75';
wwv_flow_imp.g_varchar2_table(156) := '6E742A742C693D5B5D2C6F3D4D6174682E666C6F6F72287225312A732E7769647468292C6C3D4D6174682E666C6F6F72286125312A732E686569676874292A732E77696474682B6F3B666F72286C657420613D303B613C732E62616E64636F756E743B61';
wwv_flow_imp.g_varchar2_table(157) := '2B2B29383D3D732E63656C6C64657074683F692E7075736828652E67657455696E7438286C2A6E2B612A7429293A33323D3D732E63656C6C64657074682626692E7075736828652E676574466C6F61743332286C2A6E2B612A7429293B72657475726E20';
wwv_flow_imp.g_varchar2_table(158) := '697D72657475726E206E756C6C7D7D292C6520696E204D4150424954535F47454F5241535445525F57414954494E47297B636F6E737420743D617065782E6974656D2865293B4D4150424954535F47454F5241535445525F57414954494E475B655D2E66';
wwv_flow_imp.g_varchar2_table(159) := '6F72456163682828653D3E6528742929297D4D4150424954535F47454F5241535445525F57414954494E475B655D3D6E756C6C7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(348829762353943181)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_file_name=>'mapbits_georaster.min.js'
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
