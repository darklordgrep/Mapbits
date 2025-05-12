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
--   Date and Time:   14:39 Monday May 12, 2025
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
,p_display_name=>'Mapbits Georaster Layer'
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
'procedure map_georaster_info_svc(p_geor in sdo_georaster, p_item_id in varchar2) is ',
'  l_geom sdo_geometry;',
'  l_csid integer;',
'  l_pyramidlevel integer;',
'  l_dims sdo_number_array;',
'  l_nbands integer;',
'  l_celldepth integer;',
'  l_p1 sdo_geometry;',
'  l_p2 sdo_geometry;',
'begin',
'  htp.init;',
'  owa_util.mime_header(''application/json'', FALSE);',
'  owa_util.http_header_close;      ',
'',
'  l_dims := sdo_geor.getSpatialDimSizes(p_geor);',
'  if l_dims is null then',
'    htp.p(''{"error" : "['' || p_item_id || ''] Invalid Raster"}'');',
'  else',
'    l_pyramidlevel := sdo_geor.getPyramidMaxLevel(p_geor);',
'    l_csid := sdo_geor.getModelSRID(p_geor);',
'    l_nbands := sdo_geor.getBandDimSize(p_geor);',
'    l_celldepth := sdo_geor.getCellDepth(p_geor);',
'    l_p1 := sdo_cs.transform(sdo_geor.getModelCoordinate(p_geor, 0, sdo_number_array(0, 0)), 4326);',
'    l_p2 := sdo_cs.transform(sdo_geor.getModelCoordinate(p_geor, 0, sdo_number_array(l_dims(1), l_dims(2))), 4326);',
'',
'    htp.p(''{'');',
'    htp.p(''"itemid": "'' || p_item_id || ''",'');',
'    htp.p(''"maxpyramidlevel": '' || l_pyramidlevel || '','');',
'    htp.p(''"bandcount": '' || l_nbands || '','');',
'    htp.p(''"celldepth": '' || l_cellDepth || '','');',
'    htp.p(''"height": '' || l_dims(2) || '','');',
'    htp.p(''"width": '' || l_dims(1) || '','');',
'    htp.p(''"extent": ['' || sdo_util.getfirstvertex(l_p1).x ||'','' ||   sdo_util.getfirstvertex(l_p1).y || '','' ||    sdo_util.getfirstvertex(l_p2).x || '',''  || sdo_util.getfirstvertex(l_p2).y || '']'' );',
'    htp.p(''}'');    ',
'  end if;',
'end;',
'',
'-- HTTP service handler to fetch the raster data encoded as base 64.',
'procedure map_georaster_data_svc(p_geor in sdo_georaster,  ',
'  p_x1 in number,',
'  p_y1 number,',
'  p_x2 number,',
'  p_y2 number',
') is ',
'  l_geom sdo_geometry;',
'  l_csid integer;',
'  l_min_tile_size constant integer := 256;',
'  l_pyramidlevel integer;',
'  l_dims sdo_number_array;',
'  l_width integer := 0;',
'  l_height integer := 0;',
'  l_outarea sdo_geometry;',
'  l_pos pls_integer;',
'  l_buffer_size constant pls_integer := 16384;',
'  l_len pls_integer;',
'  l_nbands integer;',
'  l_resample varchar2(12);',
'  l_layers varchar2(10);',
'  l_celldepth integer;',
'  rt blob;',
'  rt64 clob;',
'  l_error varchar(1000);',
'begin',
'  dbms_lob.createTemporary(rt,TRUE, dbms_lob.session);',
'  l_dims := sdo_number_array(0,0,0,0);',
'  l_csid := sdo_geor.getModelSRID(p_geor);',
'  l_nbands := sdo_geor.getBandDimSize(p_geor);',
'  l_celldepth := sdo_geor.getCellDepth(p_geor);',
'  if l_nbands >= 3 then ',
'    l_layers := ''1,2,3'';',
'  else',
'    l_layers := ''1'';',
'  end if;',
'  -- create query window geometry in lon/lat',
'  l_geom := sdo_cs.transform(sdo_geometry(2003, 4326, null, sdo_elem_info_array(1, 1003, 1), sdo_ordinate_array(p_x1, p_y1, p_x2, p_y1, p_x2, p_y2, p_x1, p_y2, p_x1, p_y1) ), l_csid);',
'',
'  -- choose the pyramid layer based on the query window and ''minimum number of pixels in return raster''',
'  begin',
'    select layer',
'      into l_pyramidlevel',
'    from(',
'    select layer, resolution, rank() over (order by width / substr(resolution, 1, instr(resolution, '','') -1)) r',
'    from (',
'      with ',
'        pyl as (select p_geor, level-1 layer from dual connect by level < sdo_geor.getpyramidmaxlevel(p_geor)+2)',
'        select pyl.layer, listagg(res.column_value, '','') within group (order by rownum) resolution, ',
'          sdo_geom.sdo_max_mbr_ordinate(l_geom, 1) - sdo_geom.sdo_min_mbr_ordinate(l_geom, 1) width,',
'          sdo_geom.sdo_max_mbr_ordinate(l_geom, 2) - sdo_geom.sdo_min_mbr_ordinate(l_geom, 2) height',
'        from pyl',
'        cross join sdo_geor.generateSpatialResolutions(p_geor, pyl.layer) res',
'        group by pyl.layer, ',
'          sdo_geom.sdo_min_mbr_ordinate(l_geom, 1),',
'          sdo_geom.sdo_min_mbr_ordinate(l_geom, 2),',
'          sdo_geom.sdo_max_mbr_ordinate(l_geom, 1),',
'          sdo_geom.sdo_max_mbr_ordinate(l_geom, 2)',
'      ) a where  least((width / substr(resolution, 1, instr(resolution, '','') -1)), height / substr(resolution, instr(resolution, '','') +1)) >= l_min_tile_size',
'    ) where r = 1;',
'  exception when NO_DATA_FOUND then',
'    l_pyramidlevel := 0;',
'  end;',
'  if l_cellDepth = 8 then',
'    l_resample := ''NN'';',
'  else',
'    l_resample := ''BILINEAR'';',
'  end if;',
'  -- query source raster, reproject it to lon/lat, clip to query window geometry,',
'  -- and convert it to base 64.',
'  begin',
'    sdo_geor.reproject(',
'       inGeoRaster     => p_geor, ',
'       pyramidLevel    => l_pyramidlevel, ',
'       cropArea        => l_geom, ',
'       layerNumbers    => l_layers, ',
'       resampleParam   => ''nodata=TRUE,resampling='' || l_resample, ',
'       storageParam    => '''',',
'       outSRID         => 4326, ',
'       rasterBlob      => rt, ',
'       outArea         => l_outArea,',
'       outWindow       => l_dims',
'    );',
'     ',
'    rt64 := apex_web_service.blob2clobbase64(rt);',
'    l_len := dbms_lob.getlength(rt64);',
'    l_height := l_dims(3) - l_dims(1) + 1;',
'    l_width := l_dims(4) - l_dims(2) + 1;',
'  exception when others then',
'    l_error := ''Failed to Reproject ['' || sqlerrm || '']'';',
'    l_len :=0;',
'  end;',
'',
'  -- output to http as json',
'  htp.init;',
'  owa_util.mime_header(''application/json'', FALSE);',
'  owa_util.http_header_close;      ',
'  htp.p(''{'');',
'  htp.p(''"pyramidlevel": '' || l_pyramidlevel || '','');',
'  htp.p(''"bandcount": '' || l_nbands || '','');',
'  htp.p(''"celldepth": '' || l_cellDepth || '','');',
'  htp.p(''"height": '' || l_height || '','');',
'  htp.p(''"width": '' || l_width || '','');',
'  htp.p(''"request_extent": ['' || p_x1 || '','' || p_y2 || '','' || p_x2 || '','' || p_y1 ||''],'');',
'   ',
'  if l_len > 0 then',
'    htp.p(''"extent": ['' || sdo_geom.sdo_min_mbr_ordinate(l_outArea, 1) ||'','' ||   sdo_geom.sdo_min_mbr_ordinate(l_outArea, 2) || '','' ||   sdo_geom.sdo_max_mbr_ordinate(l_outArea, 1) || '',''  || sdo_geom.sdo_max_mbr_ordinate(l_outArea, 2) || ''],'' );',
'  end if;',
'  if not l_error is null then htp.p(''"message": "'' || l_error || ''",''); end if;',
'  ',
'  htp.prn(''"celldata": "'');',
'  l_pos := 1;',
'  while l_pos <= l_len loop',
'    htp.prn(replace(replace(dbms_lob.substr(rt64, l_buffer_size, l_pos), chr(13), ''''), chr(10), ''''));',
'    l_pos := l_pos + l_buffer_size;',
'  end loop;',
'  htp.prn(''"'');',
'  htp.p(''}'');',
'end;',
'',
'-- Plugin Ajax Handler',
'procedure map_georaster_ajax(',
'  p_item   in            apex_plugin.t_item,',
'  p_plugin in            apex_plugin.t_plugin,',
'  p_param  in            apex_plugin.t_item_ajax_param,',
'  p_result in out nocopy apex_plugin.t_item_ajax_result',
') is ',
'  l_source_proc p_item.attribute_01%type := p_item.attribute_01;',
'  l_grid sdo_georaster;',
'  l_submit_items p_item.attribute_06%type := p_item.attribute_06;',
'begin',
'  georas(l_source_proc, l_submit_items, l_grid);',
'  if apex_application.g_x01 = 0 then -- info request  ',
'    map_georaster_info_svc(l_grid, p_item.name);',
'  elsif apex_application.g_x01 = 1 then -- data request',
'    map_georaster_data_svc(l_grid, apex_application.g_x03,apex_application.g_x04,apex_application.g_x05,apex_application.g_x06 );',
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
'begin',
'  begin',
'  -- fetch associated region, and display sequence number (for ordering layers)',
'  select nvl(r.static_id, ''R'' || r.region_id), i.display_sequence into l_region_id, l_sequence_no  ',
'    from apex_application_page_items i ',
'      inner join apex_application_page_regions r on i.region_id = r.region_id ',
'      where i.item_id = p_item.id and r.source_type = ''Map'';',
'  exception',
'    when NO_DATA_FOUND then ',
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
'        || apex_javascript.add_attribute(''p_opacity'', l_opacity)',
'        || apex_javascript.add_attribute(''p_submit_items'', l_submit_items)',
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
,p_help_text=>'The Mapbits Georaster Layer plugin adds support for Oracle Georasters without the need for middleware services. Add this plugin as an item under an APEX Map region. Define a single-row SQL query that returns a single column of type sdo_georaster and '
||'that raster shall be rendered in the associated Map Region. Currently, only DEM (single band, 32-bit float) and RGB (three band, 8-bit unsigned integer) rasters are supported. No compression is supported at this time. For best results, rasters should'
||' be projected to the Web Mercator coordinate reference system (EPSG:3857). Rasters referenced to other coordinate references system may have some degree of distortion.'
,p_version_identifier=>'4.9.20250211'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Georaster Layer',
'Location : $Id: item_type_plugin_mil_army_usace_mapbits_layer_georaster.sql 20612 2025-05-12 20:02:10Z b2imimcf $',
'Date     : $Date: 2025-05-12 15:02:10 -0500 (Mon, 12 May 2025) $',
'Revision : $Revision: 20612 $',
'Requires : Application Express >= 23.2',
'',
'Version 4.9 Updates',
'02/11/2025 Cleared up seams between raster tiles. Added ''Page Items to Submit'' to render georasters based on page item values. Added missing icon for terrain control.',
'',
'Version 4.8 Updates',
'01/28/2025 Added warning for missing pyramids. Resized tile canvas to be square, since DEMs require square tiles. Increased buffer size for blob64 generation.',
''))
,p_files_version=>422
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(292716568406734179)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Georaster Source'
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
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '6173796E632066756E6374696F6E206D6170626974735F67656F726173746572287B705F6974656D5F69643A652C705F616A61785F6964656E7469666965723A742C705F726567696F6E5F69643A612C705F73657175656E63653A722C705F7469746C65';
wwv_flow_imp.g_varchar2_table(2) := '3A692C705F636865636B626F785F636F6C6F723A6E2C705F696E69745F7669736962696C6974793A6C2C705F6F7061636974793A6F2C705F7375626D69745F6974656D733A737D297B66756E6374696F6E207028652C74297B72657475726E20652F4D61';
wwv_flow_imp.g_varchar2_table(3) := '74682E706F7728322C74292A3336302D3138307D66756E6374696F6E206428652C74297B636F6E737420613D4D6174682E50492D322A4D6174682E50492A652F4D6174682E706F7728322C74293B72657475726E203138302F4D6174682E50492A4D6174';
wwv_flow_imp.g_varchar2_table(4) := '682E6174616E282E352A284D6174682E6578702861292D4D6174682E657870282D612929297D636F6E737420633D286D61706C69627265676C2E67657456657273696F6E3F6D61706C69627265676C2E67657456657273696F6E28293A6D61706C696272';
wwv_flow_imp.g_varchar2_table(5) := '65676C2E76657273696F6E292E73706C697428222E22292E6D61702828653D3E7061727365496E7428652929292C673D635B305D3C342C793D617065782E726567696F6E2861292E63616C6C28226765744D61704F626A65637422293B6C657420683D61';
wwv_flow_imp.g_varchar2_table(6) := '7065782E73746F726167652E676574436F6F6B696528224D6170626974735F47656F5261737465724C617965725F222B652B225F222B2476282270496E7374616E63652229293B636F6E737420753D617761697420617065782E7365727665722E706C75';
wwv_flow_imp.g_varchar2_table(7) := '67696E28742C7B7830313A302C706167654974656D733A733F732E73706C697428222C22293A766F696420307D292C5F3D2D3165343B6173796E632066756E6374696F6E206D28722C692C6E297B752E6974656D6964213D652626616C65727428752E69';
wwv_flow_imp.g_varchar2_table(8) := '74656D69642B2220213D20222B65292C303D3D752E6D6178707972616D69646C6576656C2626636F6E736F6C652E7761726E28224D6170626974732047656F726173746572204C61796572205B222B652B225D206973206D697373696E6720707972616D';
wwv_flow_imp.g_varchar2_table(9) := '6964732E204275696C6420707972616D69647320746F20696D70726F766520706572666F726D616E63652E22293B636F6E7374206C3D6E657720526567457870282F3A5C2F5C2F282E2B295C2F285C642B295C2F285C642B295C2F285C642B292F292C63';
wwv_flow_imp.g_varchar2_table(10) := '3D722E75726C2E6D61746368286C293B6966282163297468726F77206E6577204572726F7228224D616C666F726D65642055524C3A205B222B722E75726C2B225D22293B636F6E737420673D635B315D2C793D5B7061727365496E7428635B325D292C70';
wwv_flow_imp.g_varchar2_table(11) := '61727365496E7428635B335D292C7061727365496E7428635B345D295D2C683D7028795B315D2C795B305D292C6D3D6428795B325D2C795B305D292C623D7028795B315D2B312C795B305D292C663D6428795B325D2B312C795B305D292C783D61776169';
wwv_flow_imp.g_varchar2_table(12) := '7420617065782E7365727665722E706C7567696E28742C7B7830313A312C7830323A302C7830333A682C7830343A6D2C7830353A622C7830363A662C7830373A2227222B795B305D2B222C222B795B315D2B222C222B795B325D2B2227222C7830383A67';
wwv_flow_imp.g_varchar2_table(13) := '2C706167654974656D733A733F732E73706C697428222C22293A766F696420307D293B696628303D3D782E77696474687C7C303D3D782E6865696768742972657475726E7B63616E63656C3A28293D3E7B7D7D3B617065782E726567696F6E2861293B63';
wwv_flow_imp.g_varchar2_table(14) := '6F6E737420763D646F63756D656E742E637265617465456C656D656E74282263616E76617322292C4D3D762E676574436F6E7465787428223264222C7B77696C6C526561644672657175656E746C793A21307D293B762E7374796C652E646973706C6179';
wwv_flow_imp.g_varchar2_table(15) := '3D226E6F6E65223B636F6E737420773D4D2E637265617465496D6167654461746128782E77696474682C782E686569676874292C493D61746F6228782E63656C6C64617461292C6B3D492E6C656E6774683B6C6574204C3D6E65772055696E7438417272';
wwv_flow_imp.g_varchar2_table(16) := '6179286B293B666F72286C657420653D303B653C6B3B652B2B294C5B655D3D492E63686172436F646541742865293B636F6E737420503D6E6577204461746156696577284C2E627566666572292C523D3235352A6F2F3130302C533D313D3D782E62616E';
wwv_flow_imp.g_varchar2_table(17) := '64636F756E74262633323D3D782E63656C6C64657074683B696628333D3D782E62616E64636F756E742626383D3D782E63656C6C646570746829666F72286C657420653D302C743D303B653C6B3B652B3D31297B636F6E737420613D502E67657455696E';
wwv_flow_imp.g_varchar2_table(18) := '74382865293B772E646174615B745D3D612C742B3D312C6525333D3D32262628772E646174615B745D3D522C742B3D31297D656C73657B6966282153297468726F77206E6577204572726F722822537570706F727420666F722072617374657220776974';
wwv_flow_imp.g_varchar2_table(19) := '6820222B782E62616E64636F756E742B222062616E647320616E6420222B782E63656C6C64657074682B2220706978656C206465707468206973206E6F7420696D706C656D656E7465642E22293B666F72286C657420653D303B653C6B3B652B3D34297B';
wwv_flow_imp.g_varchar2_table(20) := '636F6E737420743D502E676574466C6F6174333228652C2131292C613D2828743C5F3F303A74292D5F292F2E312C723D4D6174682E666C6F6F7228612F3635353336292C693D4D6174682E666C6F6F722828612D3235362A722A323536292F323536292C';
wwv_flow_imp.g_varchar2_table(21) := '6E3D612D3235362A722A3235362D3235362A693B772E646174615B655D3D722C772E646174615B652B315D3D692C772E646174615B652B325D3D6E2C772E646174615B652B335D3D527D7D636F6E7374206A3D782E657874656E742C433D5B286A5B325D';
wwv_flow_imp.g_varchar2_table(22) := '2D6A5B305D292F782E77696474682C286A5B335D2D6A5B315D292F782E6865696768745D3B6C657420513D5B28622D68292F435B305D2C286D2D66292F435B315D5D3B513D5B4D6174682E666C6F6F722828622D68292F435B305D292C4D6174682E666C';
wwv_flow_imp.g_varchar2_table(23) := '6F6F7228286D2D66292F435B315D295D3B636F6E737420713D5B4D6174682E6D6178284D6174682E666C6F6F7228286A5B305D2D68292F435B305D292C30292C4D6174682E6D6178284D6174682E666C6F6F7228286A5B315D2D66292F435B315D292C30';
wwv_flow_imp.g_varchar2_table(24) := '295D2C423D5B715B305D2C715B315D2C782E77696474682C782E6865696768745D3B696628762E77696474683D4D6174682E6D696E28515B305D2C515B315D292C762E6865696768743D4D6174682E6D696E28515B305D2C515B315D292C532626284D2E';
wwv_flow_imp.g_varchar2_table(25) := '66696C6C5374796C653D2272676228312C203133342C2031363029222C4D2E66696C6C5265637428302C302C762E77696474682C762E68656967687429292C4D2E707574496D6167654461746128772C425B305D2C762E6865696768742D425B335D2D42';
wwv_flow_imp.g_varchar2_table(26) := '5B315D2C302C302C425B325D2C425B335D292C2169297B72657475726E7B646174613A6177616974206E65772050726F6D6973652828653D3E7B762E746F426C6F6228286173796E6320743D3E7B6528617761697420742E617272617942756666657228';
wwv_flow_imp.g_varchar2_table(27) := '29297D29297D29297D7D762E746F426C6F622828653D3E7B6E756C6C213D3D652626652E617272617942756666657228292E7468656E2828653D3E7B69286E756C6C2C652C6E756C6C2C6E756C6C297D29297D29297D636F6E737420623D33323D3D752E';
wwv_flow_imp.g_varchar2_table(28) := '63656C6C64657074683F5B227261737465722D64656D222C2268696C6C7368616465225D3A5B22726173746572222C22726173746572225D3B792E616464536F75726365282267656F726173746572536F757263655F222B652C7B747970653A625B305D';
wwv_flow_imp.g_varchar2_table(29) := '2C74696C65733A5B2267656F7261737465725F222B652B223A2F2F222B652B222F7B7A7D2F7B787D2F7B797D225D2C74696C6553697A653A3235367D293B636F6E737420663D7B69643A652C747970653A625B315D2C736F757263653A2267656F726173';
wwv_flow_imp.g_varchar2_table(30) := '746572536F757263655F222B652C7061696E743A7B7D2C6D657461646174613A7B6C617965725F73657175656E63653A727D2C6C61796F75743A7B7669736962696C6974793A226E6F6E65227D7D3B227261737465722D64656D22213D625B305D7C7C79';
wwv_flow_imp.g_varchar2_table(31) := '2E6765745465727261696E28297C7C28635B305D3E3D352626792E73657443656E746572436C616D706564546F47726F756E64282131292C792E616464436F6E74726F6C286E6577206D61706C69627265676C2E5465727261696E436F6E74726F6C287B';
wwv_flow_imp.g_varchar2_table(32) := '736F757263653A2267656F726173746572536F757263655F222B652C657861676765726174696F6E3A317D2929293B636F6E737420783D792E6765745374796C6528292E6C61796572732E66696C746572282866756E6374696F6E2865297B7265747572';
wwv_flow_imp.g_varchar2_table(33) := '6E226D6574616461746122696E20652626226C617965725F73657175656E636522696E20652E6D657461646174617D29292E6D6170282866756E6374696F6E2865297B72657475726E5B652E6D657461646174612E6C617965725F73657175656E63652C';
wwv_flow_imp.g_varchar2_table(34) := '652E69645D7D29293B6C657420763B69662830213D3D782E6C656E677468297B782E736F7274282828652C74293D3E655B305D2D745B305D29293B666F72286C657420653D303B653C782E6C656E6774683B652B2B29696628723C785B655D5B305D297B';
wwv_flow_imp.g_varchar2_table(35) := '763D785B655D5B315D3B627265616B7D7D792E6164644C6179657228662C76292C673F6D61706C69627265676C2E61646450726F746F636F6C282267656F7261737465725F222B652C2828652C74293D3E286D28652C74292C7B63616E63656C3A28293D';
wwv_flow_imp.g_varchar2_table(36) := '3E7B7D7D2929293A6D61706C69627265676C2E61646450726F746F636F6C282267656F7261737465725F222B652C286173796E6328652C74293D3E6177616974206D28652C6E756C6C2929293B6C6574204D3D736574496E74657276616C282828293D3E';
wwv_flow_imp.g_varchar2_table(37) := '7B636F6E737420743D617065782E6A5175657279282223222B612B225F6C6567656E6422293B74262630213D792E6765745374796C6528292E6C61796572732E66696C7465722828743D3E742E69643D3D6529292E6C656E677468262628636C65617249';
wwv_flow_imp.g_varchar2_table(38) := '6E74657276616C284D292C2428273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E3C696E70757420747970653D2263686563';
wwv_flow_imp.g_varchar2_table(39) := '6B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069643D22272B652B275F6C6567656E645F656E74727922207374796C653D222D2D612D6D61';
wwv_flow_imp.g_varchar2_table(40) := '702D6C6567656E642D73656C6563746F722D636F6C6F723A272B6E2B27223E3C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C22206C6179657269643D22272B652B27222069643D22272B652B275F6C656765';
wwv_flow_imp.g_varchar2_table(41) := '6E645F656E7472795F6C6162656C2220666F723D22272B652B275F6C6567656E645F656E747279223E272B692B223C2F6C6162656C3E3C2F6469763E22292E617070656E64546F2874292C2276697369626C65223D3D683F28792E7365744C61796F7574';
wwv_flow_imp.g_varchar2_table(42) := '50726F706572747928652C227669736962696C697479222C2276697369626C6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213029293A226E6F6E65223D3D683F';
wwv_flow_imp.g_varchar2_table(43) := '28792E7365744C61796F757450726F706572747928652C227669736962696C697479222C226E6F6E6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564222C213129293A22';
wwv_flow_imp.g_varchar2_table(44) := '59223D3D6C3F28792E7365744C61796F757450726F706572747928652C227669736962696C697479222C2276697369626C6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B65';
wwv_flow_imp.g_varchar2_table(45) := '64222C213029293A28792E7365744C61796F757450726F706572747928652C227669736962696C697479222C226E6F6E6522292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E70726F702822636865636B6564';
wwv_flow_imp.g_varchar2_table(46) := '222C213129292C617065782E6A5175657279282223222B652B225F6C6567656E645F656E74727922292E6368616E67652828743D3E7B636F6E737420613D617065782E6A517565727928742E746172676574292C723D612E617474722822696422293B61';
wwv_flow_imp.g_varchar2_table(47) := '2E697328223A636865636B656422293F28792E7365744C61796F757450726F706572747928722E73756273747228302C722E6C656E6774682D3133292C227669736962696C697479222C2276697369626C6522292C617065782E73746F726167652E7365';
wwv_flow_imp.g_varchar2_table(48) := '74436F6F6B696528224D6170626974735F47656F5261737465724C617965725F222B652B225F222B2476282270496E7374616E636522292C2276697369626C652229293A28792E7365744C61796F757450726F706572747928722E73756273747228302C';
wwv_flow_imp.g_varchar2_table(49) := '722E6C656E6774682D3133292C227669736962696C697479222C226E6F6E6522292C617065782E73746F726167652E736574436F6F6B696528224D6170626974735F47656F5261737465724C617965725F222B652B225F222B2476282270496E7374616E';
wwv_flow_imp.g_varchar2_table(50) := '636522292C226E6F6E652229297D2929297D292C323530297D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(52042750193192281)
,p_plugin_id=>wwv_flow_imp.id(292702662324612235)
,p_file_name=>'mapbits_georaster.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
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
wwv_flow_imp.g_varchar2_table(1) := '6173796E632066756E6374696F6E206D6170626974735F67656F726173746572287B705F6974656D5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F73657175656E63652C20705F7469746C652C20705F';
wwv_flow_imp.g_varchar2_table(2) := '636865636B626F785F636F6C6F722C20705F696E69745F7669736962696C6974792C20705F6F7061636974792C20705F7375626D69745F6974656D737D29207B0D0A20202F2F20536F757263653A2068747470733A2F2F77696B692E6F70656E73747265';
wwv_flow_imp.g_varchar2_table(3) := '65746D61702E6F72672F77696B692F536C697070795F6D61705F74696C656E616D65730D0A20202F2F20436F6E766572742074696C6520636F6F7264696E6174657320287B5A7D7B587D7B597D2920746F2067656F6772617068696320636F6F7264696E';
wwv_flow_imp.g_varchar2_table(4) := '617465732E0D0A202066756E6374696F6E2074696C65326C6F6E6728782C7A29207B0D0A2020202072657475726E2028782F4D6174682E706F7728322C7A292A3336302D313830293B0D0A20207D0D0A202066756E6374696F6E2074696C65326C617428';
wwv_flow_imp.g_varchar2_table(5) := '792C7A29207B0D0A20202020636F6E7374206E3D4D6174682E50492D322A4D6174682E50492A792F4D6174682E706F7728322C7A293B0D0A2020202072657475726E20283138302F4D6174682E50492A4D6174682E6174616E28302E352A284D6174682E';
wwv_flow_imp.g_varchar2_table(6) := '657870286E292D4D6174682E657870282D6E292929293B0D0A20207D0D0A20200D0A2020636F6E7374206D61706C696276657273696F6E203D20286D61706C69627265676C2E67657456657273696F6E203F206D61706C69627265676C2E676574566572';
wwv_flow_imp.g_varchar2_table(7) := '73696F6E2829203A206D61706C69627265676C2E76657273696F6E292E73706C697428272E27292E6D61702878203D3E207061727365496E74287829293B0D0A2020636F6E73742070726F746F43616C6C6261636B203D206D61706C696276657273696F';
wwv_flow_imp.g_varchar2_table(8) := '6E5B305D203C20343B0D0A0D0A20202F2F2047657420746865206D61706C69627265206D6170206F626A65637420616E642067656F72617374657220696E7374616E636520636F6F6B69652E0D0A2020636F6E7374206D6170203D20617065782E726567';
wwv_flow_imp.g_varchar2_table(9) := '696F6E28705F726567696F6E5F6964292E63616C6C28226765744D61704F626A65637422293B0D0A20202F2F6D61702E73686F7754696C65426F756E646172696573203D20747275653B0D0A20206C6574206C436F6F6B6965203D20617065782E73746F';
wwv_flow_imp.g_varchar2_table(10) := '726167652E676574436F6F6B696528274D6170626974735F47656F5261737465724C617965725F27202B20705F6974656D5F69642B20225F22202B202476282270496E7374616E63652229293B0D0A0D0A20202F2F2043616C6C2074686520706C756769';
wwv_flow_imp.g_varchar2_table(11) := '6E207365727669636520746F20676574207468652067656F72617374657220696E666F726D6174696F6E2C2070757420696E207468652027726173746572696E666F27207661726961626C652E0D0A2020636F6E737420726173746572696E666F203D20';
wwv_flow_imp.g_varchar2_table(12) := '617761697420617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B0D0A20202020783031203A20302C202F2F206765742072617374657220696E666F206F70636F64650D0A20202020706167654974656D73';
wwv_flow_imp.g_varchar2_table(13) := '3A20705F7375626D69745F6974656D73203F20705F7375626D69745F6974656D732E73706C697428222C2229203A20756E646566696E65640D0A20207D293B0D0A0D0A2020636F6E7374207465727261696E42617365203D202D31303030303B0D0A2020';
wwv_flow_imp.g_varchar2_table(14) := '636F6E7374207465727261696E5265736F6C7574696F6E203D20302E313B0D0A0D0A20206173796E632066756E6374696F6E2067656F7261737465725F70726F746F636F6C28706172616D732C2063616C6C6261636B2C2061626F7274436F6E74726F6C';
wwv_flow_imp.g_varchar2_table(15) := '6C657229207B0D0A2020202069662028726173746572696E666F2E6974656D696420213D20705F6974656D5F696429207B0D0A202020202020616C65727428726173746572696E666F2E6974656D6964202B202720213D2027202B20705F6974656D5F69';
wwv_flow_imp.g_varchar2_table(16) := '64293B0D0A202020207D0D0A2020202069662028726173746572696E666F2E6D6178707972616D69646C6576656C203D3D203029207B0D0A202020202020636F6E736F6C652E7761726E28274D6170626974732047656F726173746572204C6179657220';
wwv_flow_imp.g_varchar2_table(17) := '5B27202B20705F6974656D5F6964202B20275D206973206D697373696E6720707972616D6964732E204275696C6420707972616D69647320746F20696D70726F766520706572666F726D616E63652E27293B0D0A202020207D0D0A20202020636F6E7374';
wwv_flow_imp.g_varchar2_table(18) := '207265203D206E657720526567457870282F3A5C2F5C2F282E2B295C2F285C642B295C2F285C642B295C2F285C642B292F293B0D0A20202020636F6E7374207274203D20706172616D732E75726C2E6D61746368287265293B0D0A202020206966202821';
wwv_flow_imp.g_varchar2_table(19) := '727429207B7468726F77206E6577204572726F7228274D616C666F726D65642055524C3A205B27202B20706172616D732E75726C202B20225D22293B7D0D0A20202020636F6E73742067656F7261737461626C65203D2072745B315D3B0D0A2020202063';
wwv_flow_imp.g_varchar2_table(20) := '6F6E73742074696C657A7879203D205B7061727365496E742872745B325D292C207061727365496E742872745B335D292C207061727365496E742872745B345D295D3B0D0A20202020636F6E7374207831203D2074696C65326C6F6E672874696C657A78';
wwv_flow_imp.g_varchar2_table(21) := '795B315D2C2074696C657A78795B305D293B0D0A20202020636F6E7374207931203D2074696C65326C61742874696C657A78795B325D2C2074696C657A78795B305D293B0D0A20202020636F6E7374207832203D2074696C65326C6F6E672874696C657A';
wwv_flow_imp.g_varchar2_table(22) := '78795B315D202B20312C2074696C657A78795B305D293B0D0A20202020636F6E7374207932203D2074696C65326C61742874696C657A78795B325D202B20312C2074696C657A78795B305D293B0D0A0D0A202020202F2F2043616C6C2074686520706C75';
wwv_flow_imp.g_varchar2_table(23) := '67696E207365727669636520746F20676574207468652072617374657220646174612028656E636F64656420617320626173653634292C2070757420696E20276461746127207661726961626C652E200D0A202020202F2F2078303720616E6420783038';
wwv_flow_imp.g_varchar2_table(24) := '2061726520666F7220646562756767696E672C20636F6E73696465722072656D6F76696E672074686F736520696E20746865206675747572652E0D0A20202020636F6E73742064617461203D20617761697420617065782E7365727665722E706C756769';
wwv_flow_imp.g_varchar2_table(25) := '6E28705F616A61785F6964656E7469666965722C207B0D0A2020202020207830313A20312C202F2F20676574207261737465722064617461206F70636F64650D0A2020202020207830323A20302C202F2F72657365727665640D0A202020202020783033';
wwv_flow_imp.g_varchar2_table(26) := '3A2078312C207830343A2079312C207830353A2078322C207830363A2079322C0D0A2020202020207830373A20222722202B2074696C657A78795B305D202B20222C22202B2074696C657A78795B315D202B20222C22202B2074696C657A78795B325D20';
wwv_flow_imp.g_varchar2_table(27) := '2B202227222C202F2F206E6F7420757365642C206F6E6C7920666F7220646562756767696E6720707572706F7365730D0A2020202020207830383A2067656F7261737461626C652C0D0A202020202020706167654974656D733A20705F7375626D69745F';
wwv_flow_imp.g_varchar2_table(28) := '6974656D73203F20705F7375626D69745F6974656D732E73706C697428222C2229203A20756E646566696E65640D0A202020207D293B0D0A0D0A202020202F2F204966207468657265206973206E6F20646174612C207468656E20657869742074686520';
wwv_flow_imp.g_varchar2_table(29) := '63616C6C6261636B2E0D0A2020202069662028646174612E7769647468203D3D2030207C7C20646174612E686569676874203D3D203029207B0D0A20202020202072657475726E207B2063616E63656C3A202829203D3E207B207D207D3B0D0A20202020';
wwv_flow_imp.g_varchar2_table(30) := '7D0D0A0D0A202020202F2F20437265617465207468652063616E76617320696E20776869636820746F2072656E6465722074686520696D6167652E0D0A20202020636F6E737420726567696F6E203D20617065782E726567696F6E28705F726567696F6E';
wwv_flow_imp.g_varchar2_table(31) := '5F6964293B0D0A20202020636F6E73742063616E766173203D20646F63756D656E742E637265617465456C656D656E74282763616E76617327293B0D0A20202020636F6E73742063203D2063616E7661732E676574436F6E7465787428273264272C207B';
wwv_flow_imp.g_varchar2_table(32) := '2077696C6C526561644672657175656E746C793A2074727565207D293B20200D0A2020202063616E7661732E7374796C652E646973706C6179203D20276E6F6E65273B0D0A0D0A202020202F2F20436F6E76657274207468652062617365363420646174';
wwv_flow_imp.g_varchar2_table(33) := '6120696E746F20616E20496D61676544617461206F626A6563742E0D0A20202020636F6E737420696D61676544617461203D20632E637265617465496D6167654461746128646174612E77696474682C20646174612E686569676874293B200D0A202020';
wwv_flow_imp.g_varchar2_table(34) := '20636F6E737420626C6F62203D2061746F6228646174612E63656C6C64617461293B0D0A20202020636F6E7374206C656E203D20626C6F622E6C656E6774683B0D0A202020206C6574206279746573203D206E65772055696E74384172726179286C656E';
wwv_flow_imp.g_varchar2_table(35) := '293B0D0A202020200D0A20202020666F7220286C65742069203D20303B2069203C206C656E3B20692B2B29207B0D0A20202020202062797465735B695D203D20626C6F622E63686172436F646541742869293B0D0A202020207D0D0A20202020636F6E73';
wwv_flow_imp.g_varchar2_table(36) := '74206461746176696577203D206E65772044617461566965772862797465732E627566666572293B0D0A20202020636F6E7374206F706163697479203D20323535202A20705F6F706163697479202F203130302E303B0D0A202020200D0A20202020636F';
wwv_flow_imp.g_varchar2_table(37) := '6E737420697344454D203D20646174612E62616E64636F756E74203D3D3120262620646174612E63656C6C6465707468203D3D2033323B0D0A0D0A202020202F2F20436F6C6F722052474220496D616765202D20332062616E642C20756E7369676E6564';
wwv_flow_imp.g_varchar2_table(38) := '2038626974200D0A2020202069662028646174612E62616E64636F756E74203D3D203320262620646174612E63656C6C6465707468203D3D203829207B0D0A202020202020666F72286C657420693D302C6A3D303B693C6C656E3B692B3D3129207B0D0A';
wwv_flow_imp.g_varchar2_table(39) := '2020202020202020636F6E73742076616C203D2064617461766965772E67657455696E74382869293B0D0A2020202020202020696D616765446174612E646174615B6A5D203D2076616C3B0D0A20202020202020206A203D206A202B20313B0D0A202020';
wwv_flow_imp.g_varchar2_table(40) := '202020202069662028206920252033203D3D203229207B0D0A20202020202020202020696D616765446174612E646174615B6A5D203D206F7061636974793B0D0A202020202020202020206A203D206A202B20313B0D0A20202020202020207D200D0A20';
wwv_flow_imp.g_varchar2_table(41) := '20202020207D0D0A202020202F2F2044454D202D20312062616E642033322C2062697420666C6F617420200D0A202020207D20656C73652069662028697344454D29207B0D0A202020202020666F72286C657420693D303B693C206C656E3B20692B3D34';
wwv_flow_imp.g_varchar2_table(42) := '29207B0D0A2020202020202020636F6E73742076616C203D2064617461766965772E676574466C6F6174333228692C2066616C7365293B0D0A2020202020202020636F6E7374206532203D20282876616C203C207465727261696E42617365203F203020';
wwv_flow_imp.g_varchar2_table(43) := '3A2076616C29202D207465727261696E4261736529202F207465727261696E5265736F6C7574696F6E3B0D0A2020202020202020636F6E73742072203D204D6174682E666C6F6F72286532202F2028323536202A2032353629293B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(44) := '20636F6E73742067203D204D6174682E666C6F6F7228286532202D2072202A203235362A32353629202F20323536293B0D0A2020202020202020636F6E73742062203D206532202D202872202A203235362A32353629202D202867202A20323536293B0D';
wwv_flow_imp.g_varchar2_table(45) := '0A2020202020202020696D616765446174612E646174615B695D203D20723B0D0A2020202020202020696D616765446174612E646174615B692B315D203D2020673B0D0A2020202020202020696D616765446174612E646174615B692B325D203D20623B';
wwv_flow_imp.g_varchar2_table(46) := '0D0A2020202020202020696D616765446174612E646174615B692B335D203D206F7061636974793B0D0A2020202020207D0D0A202020207D20656C7365207B0D0A2020202020207468726F77206E6577204572726F722827537570706F727420666F7220';
wwv_flow_imp.g_varchar2_table(47) := '72617374657220776974682027202B20646174612E62616E64636F756E74202B20272062616E647320616E642027202B20646174612E63656C6C6465707468202B202720706978656C206465707468206973206E6F7420696D706C656D656E7465642E27';
wwv_flow_imp.g_varchar2_table(48) := '293B0D0A202020207D0D0A202020202F2F205075742074686520696D616765206461746120696E746F207468652063616E76617320776974682074686520617070726F707269617465206F666673657420616E642064696D656E73696F6E732E0D0A2020';
wwv_flow_imp.g_varchar2_table(49) := '2020636F6E73742065203D20646174612E657874656E743B0D0A20202020636F6E7374206470203D205B28655B325D202D20655B305D292F646174612E77696474682C2028655B335D202D20655B315D29202F20646174612E6865696768745D3B0D0A20';
wwv_flow_imp.g_varchar2_table(50) := '2020206C65742063616E7661735F73697A65203D205B28287832202D20783129202F2064705B305D292C2028287931202D20793229202F2064705B315D295D3B0D0A2020202063616E7661735F73697A65203D205B4D6174682E666C6F6F722828783220';
wwv_flow_imp.g_varchar2_table(51) := '2D20783129202F2064705B305D292C204D6174682E666C6F6F7228287931202D20793229202F2064705B315D295D3B0D0A20202020636F6E7374206F6666736574203D205B4D6174682E6D6178284D6174682E666C6F6F722828655B305D202D20783129';
wwv_flow_imp.g_varchar2_table(52) := '202F2064705B305D292C2030292C204D6174682E6D6178284D6174682E666C6F6F722828655B315D202D20793229202F2064705B315D292C2030295D0D0A20202020636F6E73742072203D205B6F66667365745B305D202C206F66667365745B315D202C';
wwv_flow_imp.g_varchar2_table(53) := '20646174612E77696474682C20646174612E6865696768745D3B0D0A0D0A2020202063616E7661732E7769647468203D204D6174682E6D696E2863616E7661735F73697A655B305D2C2063616E7661735F73697A655B315D293B0D0A2020202063616E76';
wwv_flow_imp.g_varchar2_table(54) := '61732E686569676874203D204D6174682E6D696E2863616E7661735F73697A655B305D2C2063616E7661735F73697A655B315D293B0D0A2020202069662028697344454D29207B0D0A202020202020632E66696C6C5374796C65203D206072676228312C';
wwv_flow_imp.g_varchar2_table(55) := '203133342C2031363029603B0D0A202020202020632E66696C6C5265637428302C20302C2063616E7661732E77696474682C2063616E7661732E686569676874293B0D0A202020207D0D0A20202020632E707574496D6167654461746128696D61676544';
wwv_flow_imp.g_varchar2_table(56) := '6174612C725B305D2C63616E7661732E686569676874202D20725B335D202D20725B315D2C20302C20302C20725B325D2C20725B335D293B0D0A202020200D0A202020202F2F205772697465207468652063616E76617320617320616E20696D61676520';
wwv_flow_imp.g_varchar2_table(57) := '696E206163636F7264616E6365207769746820746865205261737465722054696C652070726F746F636F6C2E0D0A202020206966202863616C6C6261636B29207B0D0A20202020202063616E7661732E746F426C6F6228286229203D3E207B0D0A202020';
wwv_flow_imp.g_varchar2_table(58) := '2020202020696620286220213D3D206E756C6C29207B0D0A20202020202020202020622E617272617942756666657228292E7468656E2828623129203D3E207B0D0A20202020202020202020202063616C6C6261636B286E756C6C2C2062312C206E756C';
wwv_flow_imp.g_varchar2_table(59) := '6C2C206E756C6C293B0D0A202020202020202020207D293B0D0A20202020202020207D0D0A2020202020207D293B0D0A2020202020200D0A202020207D20656C7365207B0D0A202020202020636F6E737420727450203D206177616974206E6577205072';
wwv_flow_imp.g_varchar2_table(60) := '6F6D69736528287265736F6C766529203D3E207B0D0A202020202020202063616E7661732E746F426C6F62286173796E6320286229203D3E207B0D0A202020202020202020207265736F6C766528617761697420622E6172726179427566666572282929';
wwv_flow_imp.g_varchar2_table(61) := '3B0D0A20202020202020207D293B0D0A2020202020207D293B0D0A20202020202072657475726E207B646174613A207274507D3B0D0A202020207D0D0A20207D0D0A0D0A20202F2F20437265617465206D61706C6962726520736F7572636520616E6420';
wwv_flow_imp.g_varchar2_table(62) := '6C617965722E0D0A2020636F6E7374207274797065696E666F203D20726173746572696E666F2E63656C6C6465707468203D3D203332203F205B277261737465722D64656D272C202768696C6C7368616465275D203A205B27726173746572272C202772';
wwv_flow_imp.g_varchar2_table(63) := '6173746572275D3B0D0A20206D61702E616464536F75726365280D0A202020202767656F726173746572536F757263655F27202B20705F6974656D5F69642C0D0A202020207B0D0A202020202020747970653A207274797065696E666F5B305D2C200D0A';
wwv_flow_imp.g_varchar2_table(64) := '20202020202074696C65733A205B2767656F7261737465725F27202B20705F6974656D5F6964202B20273A2F2F27202B20705F6974656D5F6964202B20272F7B7A7D2F7B787D2F7B797D275D2C0D0A20202020202074696C6553697A653A203235362C0D';
wwv_flow_imp.g_varchar2_table(65) := '0A2020202020202F2F206E656564732061206E657765722076657273696F6E206F66206D61706C696272650D0A2020202020202F2F20656E636F64696E673A2027637573746F6D272C0D0A2020202020202F2F206261736553686966743A207465727261';
wwv_flow_imp.g_varchar2_table(66) := '696E426173652C0D0A2020202020202F2F20726564466163746F723A20323536202A20323536202A207465727261696E5265736F6C7574696F6E2C0D0A2020202020202F2F20677265656E466163746F723A20323536202A207465727261696E5265736F';
wwv_flow_imp.g_varchar2_table(67) := '6C7574696F6E2C0D0A2020202020202F2F20626C7565466163746F723A207465727261696E5265736F6C7574696F6E2C0D0A202020207D0D0A2020293B0D0A2020636F6E7374206C7972203D207B0D0A202020206964203A20705F6974656D5F69642C20';
wwv_flow_imp.g_varchar2_table(68) := '0D0A20202020747970653A207274797065696E666F5B315D2C200D0A20202020736F757263653A202767656F726173746572536F757263655F27202B20705F6974656D5F69642C0D0A202020207061696E74203A207B7D2C0D0A202020206D6574616461';
wwv_flow_imp.g_varchar2_table(69) := '7461203A207B276C617965725F73657175656E636527203A20705F73657175656E63657D2C0D0A202020206C61796F7574203A207B277669736962696C697479273A20276E6F6E65277D0D0A20207D3B0D0A0D0A2020696620287274797065696E666F5B';
wwv_flow_imp.g_varchar2_table(70) := '305D203D3D20277261737465722D64656D2720262620216D61702E6765745465727261696E282929207B0D0A20202020696620286D61706C696276657273696F6E5B305D203E3D203529207B0D0A2020202020206D61702E73657443656E746572436C61';
wwv_flow_imp.g_varchar2_table(71) := '6D706564546F47726F756E642866616C7365293B0D0A202020207D0D0A202020206D61702E616464436F6E74726F6C280D0A2020202020206E6577206D61706C69627265676C2E5465727261696E436F6E74726F6C287B0D0A2020202020202020736F75';
wwv_flow_imp.g_varchar2_table(72) := '7263653A202767656F726173746572536F757263655F27202B20705F6974656D5F69642C0D0A2020202020202020657861676765726174696F6E3A20312C0D0A2020202020207D290D0A20202020293B0D0A20207D0D0A0D0A20202F2F20416464207468';
wwv_flow_imp.g_varchar2_table(73) := '65206C6179657220746F20746865206D61702E20557365207468652073657175656E6365206E756D6265722066726F6D207468652070616765200D0A20202F2F206974656D20746F206F7264657220746865206C61796572732E20486967686572206E75';
wwv_flow_imp.g_varchar2_table(74) := '6D6265727320617265206C61737420616E6420646973706C61796564206F6E20746F702E0D0A2020636F6E7374206C6179657273203D206D61702E6765745374796C6528292E6C61796572733B0D0A2020636F6E7374206D6170626974736C6179657273';
wwv_flow_imp.g_varchar2_table(75) := '203D206C61796572732E66696C7465722866756E6374696F6E2876616C297B0D0A2020202069662028276D657461646174612720696E2076616C29207B200D0A20202020202072657475726E20276C617965725F73657175656E63652720696E2076616C';
wwv_flow_imp.g_varchar2_table(76) := '2E6D657461646174613B0D0A202020207D20656C7365207B0D0A20202020202072657475726E2066616C73653B0D0A202020207D0D0A20207D292E6D61702866756E6374696F6E2876616C29207B72657475726E205B76616C2E6D657461646174612E6C';
wwv_flow_imp.g_varchar2_table(77) := '617965725F73657175656E63652C2076616C2E69645D7D293B0D0A0D0A20206C6574206265666F72654C617965723B0D0A2020696620286D6170626974736C61796572732E6C656E67746820213D3D203029207B0D0A202020206D6170626974736C6179';
wwv_flow_imp.g_varchar2_table(78) := '6572732E736F72742828612C206229203D3E20615B305D202D20625B305D293B0D0A20202020666F72286C657420693D303B693C6D6170626974736C61796572732E6C656E6774683B692B2B29207B0D0A20202020202069662028705F73657175656E63';
wwv_flow_imp.g_varchar2_table(79) := '65203C206D6170626974736C61796572735B695D5B305D29207B0D0A20202020202020206265666F72654C61796572203D206D6170626974736C61796572735B695D5B315D3B0D0A2020202020202020627265616B3B0D0A2020202020207D0D0A202020';
wwv_flow_imp.g_varchar2_table(80) := '207D0D0A20207D0D0A20206D61702E6164644C61796572286C79722C206265666F72654C61796572293B0D0A0D0A20202F2F20696D706C656D656E7420746865206D61706C69627265207261737465722074696C652070726F746F636F6C2E2054686973';
wwv_flow_imp.g_varchar2_table(81) := '2077696C6C2062652063616C6C6564206279206D61706C696272650D0A20206966202870726F746F43616C6C6261636B29207B0D0A202020206D61706C69627265676C2E61646450726F746F636F6C282767656F7261737465725F27202B20705F697465';
wwv_flow_imp.g_varchar2_table(82) := '6D5F69642C2028706172616D732C2063616C6C6261636B29203D3E207B0D0A20202020202067656F7261737465725F70726F746F636F6C28706172616D732C2063616C6C6261636B2C206E756C6C293B0D0A20202020202072657475726E207B2063616E';
wwv_flow_imp.g_varchar2_table(83) := '63656C3A202829203D3E207B207D207D3B0D0A202020207D293B2020200D0A20207D20656C7365207B0D0A202020206D61706C69627265676C2E61646450726F746F636F6C282767656F7261737465725F27202B20705F6974656D5F69642C206173796E';
wwv_flow_imp.g_varchar2_table(84) := '632028706172616D732C2061626F7274436F6E74726F6C6C657229203D3E207B0D0A20202020202072657475726E2061776169742067656F7261737465725F70726F746F636F6C28706172616D732C206E756C6C2C2061626F7274436F6E74726F6C6C65';
wwv_flow_imp.g_varchar2_table(85) := '72293B0D0A202020207D293B0D0A20207D0D0A20200D0A20202F2F205570646174652041504558206C6567656E6420666F72206D6170626F782E205761697420666F7220746865206C6567656E6420746F20626520726561647920666972737420757369';
wwv_flow_imp.g_varchar2_table(86) := '6E6720736574496E74657276616C2E2041646420656E747269657320666F722074686520706C7567696E206C617965722E0D0A20202F2F20557365206120636F6F6B69652076616C756520746F2064657465726D696E652069662074686520636865636B';
wwv_flow_imp.g_varchar2_table(87) := '626F782076616C75652073686F756C64207374617274206F6E206F72206F66662E0D0A20206C657420696E74657276616C203D20736574496E74657276616C282829203D3E207B0D0A20202020636F6E7374206C6567656E64203D20617065782E6A5175';
wwv_flow_imp.g_varchar2_table(88) := '65727928272327202B20705F726567696F6E5F6964202B20275F6C6567656E6427293B0D0A2020202069662028216C6567656E6429207B0D0A20202020202072657475726E3B0D0A202020207D0D0A20202020696620286D61702E6765745374796C6528';
wwv_flow_imp.g_varchar2_table(89) := '292E6C61796572732E66696C74657228286974656D29203D3E206974656D2E6964203D3D20705F6974656D5F696420292E6C656E677468203D3D203029207B0D0A20202020202072657475726E3B0D0A202020207D0D0A20202020636C656172496E7465';
wwv_flow_imp.g_varchar2_table(90) := '7276616C28696E74657276616C293B0D0A202020202428273C64697620636C6173733D22612D4D6170526567696F6E2D6C6567656E644974656D20612D4D6170526567696F6E2D6C6567656E644974656D2D2D6869646561626C65223E27202B200D0A20';
wwv_flow_imp.g_varchar2_table(91) := '2020202020273C696E70757420747970653D22636865636B626F782220636C6173733D22612D4D6170526567696F6E2D6C6567656E6453656C6563746F722069732D636865636B65642220636865636B65643D22222069643D2227202B20705F6974656D';
wwv_flow_imp.g_varchar2_table(92) := '5F6964202B20275F6C6567656E645F656E74727927202B202722207374796C653D222D2D612D6D61702D6C6567656E642D73656C6563746F722D636F6C6F723A272B20705F636865636B626F785F636F6C6F72202B2027223E27202B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(93) := '273C6C6162656C20636C6173733D22612D4D6170526567696F6E2D6C6567656E644C6162656C22206C6179657269643D2227202B20705F6974656D5F6964202B2027222069643D2227202B20705F6974656D5F6964202B20275F6C6567656E645F656E74';
wwv_flow_imp.g_varchar2_table(94) := '72795F6C6162656C27202B20272220666F723D2227202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927202B2027223E27202B20705F7469746C65202B20273C2F6C6162656C3E27202B0D0A202020202020273C2F6469763E2729';
wwv_flow_imp.g_varchar2_table(95) := '2E617070656E64546F286C6567656E64293B0D0A20202020696620286C436F6F6B6965203D3D202776697369626C652729207B0D0A2020202020206D61702E7365744C61796F757450726F706572747928705F6974656D5F69642C20277669736962696C';
wwv_flow_imp.g_varchar2_table(96) := '697479272C202776697369626C6527293B0D0A202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2074727565293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(97) := '7D20656C736520696620286C436F6F6B6965203D3D20276E6F6E652729207B0D0A2020202020206D61702E7365744C61796F757450726F706572747928705F6974656D5F69642C20277669736962696C697479272C20276E6F6E6527293B0D0A20202020';
wwv_flow_imp.g_varchar2_table(98) := '2020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A202020207D20656C7365207B0D0A20202020202069662028705F';
wwv_flow_imp.g_varchar2_table(99) := '696E69745F7669736962696C697479203D3D2027592729207B0D0A20202020202020206D61702E7365744C61796F757450726F706572747928705F6974656D5F69642C20277669736962696C697479272C202776697369626C6527293B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(100) := '202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E70726F702827636865636B6564272C2074727565293B0D0A2020202020207D20656C7365207B0D0A20202020202020206D61';
wwv_flow_imp.g_varchar2_table(101) := '702E7365744C61796F757450726F706572747928705F6974656D5F69642C20277669736962696C697479272C20276E6F6E6527293B0D0A2020202020202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E';
wwv_flow_imp.g_varchar2_table(102) := '645F656E74727927292E70726F702827636865636B6564272C2066616C7365293B0D0A2020202020207D0D0A202020207D0D0A0D0A202020202F2F205768656E2061206C6567656E6420656E747279206368616E6765732C2073746F7265207468652076';
wwv_flow_imp.g_varchar2_table(103) := '69736962696C69747920737461746520746F2074686520636F6F6B69652E0D0A20202020617065782E6A517565727928272327202B20705F6974656D5F6964202B20275F6C6567656E645F656E74727927292E6368616E676528286529203D3E207B0D0A';
wwv_flow_imp.g_varchar2_table(104) := '202020202020636F6E7374206362203D20617065782E6A517565727928652E746172676574293B0D0A202020202020636F6E73742063626964203D2063622E617474722827696427293B0D0A2020202020206966202863622E697328273A636865636B65';
wwv_flow_imp.g_varchar2_table(105) := '64272929207B0D0A20202020202020206D61702E7365744C61796F757450726F706572747928636269642E73756273747228302C20636269642E6C656E677468202D20275F6C6567656E645F656E747279272E6C656E677468292C20277669736962696C';
wwv_flow_imp.g_varchar2_table(106) := '697479272C202776697369626C6527293B0D0A2020202020202020617065782E73746F726167652E736574436F6F6B696528274D6170626974735F47656F5261737465724C617965725F27202B20705F6974656D5F69642B20225F22202B202476282270';
wwv_flow_imp.g_varchar2_table(107) := '496E7374616E636522292C202776697369626C6527293B0920200D0A2020202020207D20656C7365207B0D0A20202020202020206D61702E7365744C61796F757450726F706572747928636269642E73756273747228302C20636269642E6C656E677468';
wwv_flow_imp.g_varchar2_table(108) := '202D20275F6C6567656E645F656E747279272E6C656E677468292C20277669736962696C697479272C20276E6F6E6527293B0D0A2020202020202020617065782E73746F726167652E736574436F6F6B696528274D6170626974735F47656F5261737465';
wwv_flow_imp.g_varchar2_table(109) := '724C617965725F27202B20705F6974656D5F69642B20225F22202B202476282270496E7374616E636522292C20276E6F6E6527293B0920200D0A2020202020207D2020202020202020200D0A202020207D293B0D0A20207D2C20323530293B0D0A7D';
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
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
