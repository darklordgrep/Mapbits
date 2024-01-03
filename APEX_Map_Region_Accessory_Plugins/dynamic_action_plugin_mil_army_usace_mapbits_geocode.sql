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
--     PLUGIN: 1908114832207108187
--   Manifest End
--   Version:         22.2.8
--   Instance ID:     61817619049184
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/mil_army_usace_mapbits_geocode
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(1908114832207108187)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MIL.ARMY.USACE.MAPBITS.GEOCODE'
,p_display_name=>'Mapbits Geocoder'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#mapbits-geocode.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function mapbits_geocode_address (',
'  p_street in varchar2 default null,',
'  p_city_name in varchar2 default null,',
'  p_state in varchar2 default null,',
'  p_postal_code in varchar2 default null,',
'  p_wallet_path in varchar2 default null,',
'  p_wallet_password in varchar2 default null',
') return clob is',
'  l_geocode_url varchar2(2000) :=  ''https://nominatim.openstreetmap.org/search'';',
'  rt clob;',
'  rt1 clob;',
'begin',
'  l_geocode_url := l_geocode_url || ''?format=xml'' || ''&addressdetails=1'';',
'  if p_street is not null then',
'    l_geocode_url := l_geocode_url || ''&'' || ''street='' || p_street;',
'  end if;',
'  if p_city_name is not null then',
'    l_geocode_url := l_geocode_url ||''&'' || ''city='' || p_city_name;',
'  end if;',
'  if p_state is not null then',
'    l_geocode_url := l_geocode_url ||''&'' || ''state='' || p_state;',
'  end if;',
'  if p_postal_code is not null then',
'    l_geocode_url := l_geocode_url ||''&'' || ''postalcode='' || p_postal_code;',
'  end if;',
'  if not apex_collection.collection_exists(p_collection_name => ''GEOCODE_CACHE'') then',
'    apex_collection.create_collection(p_collection_name => ''GEOCODE_CACHE'');',
'  end if;',
'  begin',
'    select clob001 into rt1 from apex_collections where collection_name = ''GEOCODE_CACHE'' ',
'    and c001 = lower(p_street) and c002 = lower(p_city_name)',
'    and c003 = lower(p_state) and c004 = lower(p_postal_code);',
'  exception when NO_DATA_FOUND then ',
'    apex_web_service.set_request_headers(',
'    p_name_01        => ''User-Agent'',',
'    p_value_01       => ''Mapbits Geocoder, Session : '' || APEX_CUSTOM_AUTH.GET_SESSION_ID,',
'    p_reset          => false,',
'    p_skip_if_exists => true );',
'    rt := apex_web_service.make_rest_request(p_url => utl_url.escape(l_geocode_url), p_http_method => ''GET'', p_wallet_path => p_wallet_path, p_wallet_pwd => p_wallet_password);',
'    select json_object(''type'' value ''FeatureCollection'', ''features'' value json_arrayagg(',
'    json_object(''type'' value ''Feature'', ''geometry'' value json_object(''type'' value ''Point'', ''coordinates'' value json_array(longitude, latitude)), ',
'    ''properties'' value json_object(''latitude'' value latitude, ''longitude'' value longitude,''display_name'' value display_name, ''house_number'' value house_number, ',
'    ''road'' value road, ''suburb'' value suburb, ''village'' value village, ''town'' value town, ',
'    ''city_district'' value city_district, ''city'' value city, ''county'' value county, ''state'' value state, ''postcode'' value postcode, ''country'' value country)))) into rt1 from',
'    xmltable(''/searchresults/place'' PASSING xmltype(rt) COLUMNS ',
'        longitude NUMBER(12,9) PATH ''@lon'',',
'        latitude NUMBER(12,9) PATH ''@lat'',',
'        display_name varchar2(1000) PATH ''@display_name'',  ',
'        house_number varchar2(1000) PATH ''house_number'',',
'        road varchar2(1000) PATH ''road'',  ',
'        suburb varchar2(1000) PATH ''suburb'',',
'        village varchar2(1000) PATH ''village'',',
'        town  varchar2(1000) PATH ''town'',',
'        city_district varchar2(1000) PATH ''construction'',',
'        city varchar2(1000) PATH ''city'',',
'        county varchar2(1000) PATH ''county'',',
'        state varchar2(1000) PATH ''state'',',
'        postcode varchar2(1000) PATH ''postcode'',',
'        country varchar2(1000) PATH ''country''',
'    );',
'    apex_collection.add_member(p_collection_name => ''GEOCODE_CACHE'', ',
'    p_c001 => lower(p_street),',
'    p_c002 => lower(p_city_name),',
'    p_c003 => lower(p_state),',
'    p_c004 => lower(p_postal_code),',
'    p_clob001 => rt1',
'    );',
'  end;',
'  return rt1;',
'end;',
'',
'function mapbits_geocode_ajax (',
'    p_dynamic_action in apex_plugin.t_dynamic_action,',
'    p_plugin         in apex_plugin.t_plugin )',
'    return apex_plugin.t_dynamic_action_ajax_result is',
'  l_street varchar2(800);',
'  l_city varchar2(400);',
'  l_state varchar2(200);',
'  l_zipcode varchar2(100);',
'  l_collection_name varchar2(32);',
'  l_locjson clob;',
'  l_geomjson clob;',
'  rt apex_plugin.t_dynamic_action_ajax_result;',
'  l_wallet_path p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;',
'  l_wallet_password p_dynamic_action.attribute_07%type := p_dynamic_action.attribute_07;',
'begin',
'  -- callback function to lookup the coordinates from the address.',
'  l_street := apex_application.g_x01; ',
'  l_city := apex_application.g_x02;',
'  l_state := apex_application.g_x03;',
'  l_zipcode := apex_application.g_x04;',
'  l_collection_name := apex_application.g_x05;',
'  ',
'  l_locjson := mapbits_geocode_address (',
'    p_street => l_street,',
'    p_city_name => l_city,',
'    p_state => l_state,',
'    p_postal_code => l_zipcode,',
'    p_wallet_path => l_wallet_path,',
'    p_wallet_password => l_wallet_password',
'  );',
'',
'  -- get the geometry from the first feature',
'  select geom into l_geomjson from json_table(l_locjson, ''$.features[0]'' COLUMNS(geom FORMAT JSON PATH ''$.geometry''));',
'  ',
'  -- set the apex_collection with the input collection name (this originally comes from the plugin attribute 5, Mapbits Drawing Collection Name)',
'  -- to the geojson geometry. Otherwise, don''t set anything and return an error.',
'  if not l_geomjson is null then',
'    if apex_collection.collection_exists(p_collection_name => l_collection_name) then',
'      apex_collection.update_member(p_collection_name => l_collection_name, p_seq => 1, p_clob001 => l_geomjson);',
'    else',
'      apex_collection.create_or_truncate_collection(p_collection_name => l_collection_name);',
'      apex_collection.add_member(p_collection_name => l_collection_name, p_clob001 => l_geomjson);',
'    end if;',
'    htp.prn(l_geomjson);',
'  else',
'    htp.prn(''{"error" : "Address not found."}'');',
'  end if;',
'  ',
'  return rt;',
'end;',
'',
'function mapbits_geocode (',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin )',
'  return apex_plugin.t_dynamic_action_render_result is',
'    l_region_id varchar2(400); --apex_application_page_regions.region_id%type;',
'    l_draw_item varchar2(40);',
'    l_region_type varchar2(40);',
'    l_action_name varchar2(80);',
'    rt apex_plugin.t_dynamic_action_render_result;',
'    l_street_item p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_city_item p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;   ',
'    l_state_item p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'    l_zip_item p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;',
'    l_collection_name  p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;',
'    l_active_extent varchar2(400);',
'begin',
'  -- check that the plugin is associated to a map region and that the same map region',
'  -- also has a Mapbits Drawing  plugin. Those values are to be passed to the javascript call.',
'  begin',
'   select nvl(r.static_id, ''R''||da.affected_region_id) region, i.item_name item, r.source_type, da.dynamic_action_name into l_region_id, l_draw_item, l_region_type, l_action_name',
'    from apex_application_page_da_acts da ',
'    inner join apex_application_page_regions r on da.affected_region_id = r.region_id',
'    left join apex_application_page_items i on da.application_id = i.application_id and da.page_id = i.page_id and i.region_id = da.affected_region_id and i.display_as_code = ''PLUGIN_MIL.ARMY.USACE.MAPBITS.DRAW''',
'    where',
'    da.application_id = v(''APP_ID'') and da.page_id = v(''APP_PAGE_ID'') and da.action_id = p_dynamic_action.id; -- and r.source_type = ''Map'';',
'    if not l_region_type = ''Map'' then',
'      raise_application_error(-20341, ''Configuration ERROR: Mapbits Geocoder DA for "'' || l_action_name ||  ''" ['' || p_dynamic_action.id || ''] is associated with the wrong type of region. It must be associated with a Map region.  Check the Affected E'
||'lements section of the plugin settings.'');',
'    end if;',
'    if l_draw_item is null then',
'      raise_application_error(-20341, ''Configuration ERROR: Mapbits Geocoder DA for "'' || l_action_name ||  ''" ['' || p_dynamic_action.id || ''] is associated to a Map region that does not have a Drawing plugin. Add a Mapbits Drawing plugin to that Map'
||' region.'');',
'    end if;',
'  exception',
'    when NO_DATA_FOUND then ',
'      raise_application_error(-20341, ''Configuration ERROR: Mapbits Geocoder DA ['' || p_dynamic_action.id || ''] is not associated with a region.  Check the Affected Elements section of the plugin settings.'');',
'  end;',
'  ',
'  -- set up and run the javascript to run the geocoder.',
'  rt.javascript_function := ''function () {mapbits_geocode("'' || p_dynamic_action.id || ''", "'' || apex_plugin.get_ajax_identifier || ''", "'' || l_region_id  || ''", '' ',
'    || ''$v("'' || l_street_item || ''"), '' ',
'    || ''$v("'' || l_city_item || ''"),''  ',
'    || ''$v("'' || l_state_item || ''"),'' ',
'    || ''$v("'' || l_zip_item || ''"),'' ',
'    || ''"'' || l_collection_name || ''", ''',
'    || ''"'' || l_draw_item || ''"''',
'    || '');}'';',
'  return rt;',
'end;'))
,p_api_version=>2
,p_render_function=>'mapbits_geocode'
,p_ajax_function=>'mapbits_geocode_ajax'
,p_standard_attributes=>'REGION:REQUIRED'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'Mapbits Geocoder is a dynamic action plugin that uses page items storing a location''s street address, city, state, and zip code to set the position of the point geometry in a Mapbits Drawing plugin. The Mapbits Geocoder must be associated with the sa'
||'me map region as the Mapbits Drawing plugin.'
,p_version_identifier=>'4.6.20231201'
,p_about_url=>'https://github.com/darklordgrep/Mapbits'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Module   : Mapbits 4 - Geocoder',
'Location : $Id: dynamic_action_plugin_mil_army_usace_mapbits_geocode.sql 18773 2023-12-04 18:42:11Z b2eddjw9 $',
'Date     : $Date: 2023-12-04 12:42:11 -0600 (Mon, 04 Dec 2023) $',
'Revision : $Revision: 18773 $',
'Requires : Application Express >= 21.1 and Mapbits Drawing plugin',
'',
'Version 4.6 Updates:',
'12/01/2023 Raising exceptions if the plugin is not assoicated with a map region or the map region does not have a drawing item plugin.',
'',
'Version 4.4 Updates:',
'5/10/2023 Preventing javascript execution if the parent region is hidden.',
'',
'Version 4.3 Updates:',
'8/13/2022 Test with maplibre. No changes. Bumping version.',
'12/07/2022 Break out of javascript function if the region is null to avoid javascript errors breaking the rest of page.',
'',
'Version 4.2 Updates: ',
'3/10/2022 Added attribute help text.',
'2/11/2022 Added attributes for Oracle wallet path and password.',
'2/8/2022 Consolidated the geocoding call into the plugin body from the locator package. ',
'Removed dependence on tables for caching. The plugin now uses APEX collections. Caching ',
'was reworking to be specific to the session (fitting the natural limitation of collections).',
'This does not result in a block from the server. Also using a new User-Agent on the calls',
'identifying the call as from the Mapbits Geocoder with a session id.',
''))
,p_files_version=>13
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1908116173963117176)
,p_plugin_id=>wwv_flow_imp.id(1908114832207108187)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Street Address Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'326 Grant Avenue'
,p_help_text=>'Page item with the street address component to be used in the geocoder query.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1908116473744120060)
,p_plugin_id=>wwv_flow_imp.id(1908114832207108187)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'City Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'Santa Fe'
,p_help_text=>'Page item with the city to be used in the geocoder query.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1908116706300121493)
,p_plugin_id=>wwv_flow_imp.id(1908114832207108187)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'State Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'New Mexico or NM'
,p_help_text=>'Page item with the state to be used in the geocoder query.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1908117001324122664)
,p_plugin_id=>wwv_flow_imp.id(1908114832207108187)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Zip Code Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'87501'
,p_help_text=>'Page item with the zip code to be used in the geocoder query.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1908126180348003552)
,p_plugin_id=>wwv_flow_imp.id(1908114832207108187)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Mapbits Drawing  Collection Name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Instances of the Mapbits Drawing plugin store geometries in APEX collections. Set this attribute to the name of the Mapbits Drawing collection and, when this dynamic action is executed, the output geometry will be stored in that collection, making it'
||' available in the Mapbits Drawing plugin item.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1791619436324770799)
,p_plugin_id=>wwv_flow_imp.id(1908114832207108187)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Wallet Path'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'file://orasoft/oracle/DB/wallets/wallet_SSL/'
,p_help_text=>'Queries to the geocoding service are performed from the database server, not the client. If you need a database wallet to access Nominatim, you can set the path to that wallet with this attribute.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(1791620127336772646)
,p_plugin_id=>wwv_flow_imp.id(1908114832207108187)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Wallet Password'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Queries to the geocoding service are performed from the database server, not the client. If you need a database wallet to access Nominatim, you can set the password to that wallet with this attribute.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '66756E6374696F6E206D6170626974735F67656F636F646528705F616374696F6E5F69642C20705F616A61785F6964656E7469666965722C20705F726567696F6E5F69642C20705F7374726565742C20705F636974792C20705F73746174652C20705F7A';
wwv_flow_imp.g_varchar2_table(2) := '69702C20705F636F6C6C656374696F6E5F6E616D652C20705F647261775F6974656D29207B090D0A20202F2F2072616973652061206A61766173637269707420616C65727420776974682074686520696E707574206D6573736167652C206D73672C2061';
wwv_flow_imp.g_varchar2_table(3) := '6E6420777269746520746F20636F6E736F6C652E0D0A202066756E6374696F6E20617065785F616C657274286D736729207B0D0A20202020617065782E6A51756572792866756E6374696F6E28297B617065782E6D6573736167652E616C657274286D73';
wwv_flow_imp.g_varchar2_table(4) := '67293B636F6E736F6C652E6C6F6728705F616374696F6E5F6964202B20222022202B206D7367293B7D293B0D0A20207D0D0A20202F2A0D0A2020202A20557064617465206C6174697475646520616E64206C6F6E67697475646520646567726565732C20';
wwv_flow_imp.g_varchar2_table(5) := '6D696E757465732C20616E64207365636F6E6473206669656C647320616E64206D617062697473206974656D2076616C75652066726F6D20746865206D6170626974732067656F6D657472792E0D0A2020202A2F0D0A202066756E6374696F6E2073796E';
wwv_flow_imp.g_varchar2_table(6) := '63436F6F72647346726F6D47656F6D657472792867656F6D6574727929207B0D0A202020206966202867656F6D657472792E636F6F7264696E617465732E6C656E677468203C203129207B0D0A20202020202072657475726E3B0D0A202020207D0D0A20';
wwv_flow_imp.g_varchar2_table(7) := '2020206966202867656F6D657472792E74797065203D3D2022506F696E742229207B0D0A2020202020207661722078203D2067656F6D657472792E636F6F7264696E617465735B305D3B0D0A2020202020207661722079203D2067656F6D657472792E63';
wwv_flow_imp.g_varchar2_table(8) := '6F6F7264696E617465735B315D3B0D0A202020202020617065782E6A517565727928272327202B20705F647261775F6974656D202B20225F6C6F6E6769747564655F6465677265657322292E76616C286765745F64656772656573287829293B0D0A2020';
wwv_flow_imp.g_varchar2_table(9) := '20202020617065782E6A517565727928272327202B20705F647261775F6974656D202B20225F6C6F6E6769747564655F6D696E7574657322292E76616C286765745F6D696E75746573287829293B0D0A202020202020617065782E6A5175657279282723';
wwv_flow_imp.g_varchar2_table(10) := '27202B20705F647261775F6974656D202B20225F6C6F6E6769747564655F7365636F6E647322292E76616C286765745F7365636F6E6473287829293B0D0A202020202020617065782E6A517565727928272327202B20705F647261775F6974656D202B20';
wwv_flow_imp.g_varchar2_table(11) := '225F6C617469747564655F6465677265657322292E76616C286765745F64656772656573287929293B0D0A202020202020617065782E6A517565727928272327202B20705F647261775F6974656D202B20225F6C617469747564655F6D696E7574657322';
wwv_flow_imp.g_varchar2_table(12) := '292E76616C286765745F6D696E75746573287929293B0D0A202020202020617065782E6A517565727928272327202B20705F647261775F6974656D202B20225F6C617469747564655F7365636F6E647322292E76616C286765745F7365636F6E64732879';
wwv_flow_imp.g_varchar2_table(13) := '29293B0D0A202020207D200D0A20207D0D0A20200D0A20202F2F2069662074686520726567696F6E2069732068696464656E2C207468656E20657869742E0D0A202076617220726567696F6E203D20617065782E726567696F6E28705F726567696F6E5F';
wwv_flow_imp.g_varchar2_table(14) := '6964293B0D0A202069662028726567696F6E203D3D206E756C6C29207B0D0A20202020636F6E736F6C652E6C6F6728276D6170626974735F67656F636F64652027202B20705F616374696F6E5F6964202B2027203A20526567696F6E205B27202B20705F';
wwv_flow_imp.g_varchar2_table(15) := '726567696F6E5F6964202B20275D2069732068696464656E206F72206D697373696E672E27293B0D0A2020202072657475726E3B0D0A20207D0D0A2020766172206D6170203D20726567696F6E2E63616C6C28226765744D61704F626A65637422293B0D';
wwv_flow_imp.g_varchar2_table(16) := '0A20200D0A20206D61702E67657443616E76617328292E7374796C652E637572736F72203D20276E6F742D616C6C6F776564273B0D0A20200D0A20202F2F2043616C6C206261636B20746F20746865207365727665722077697468207468652063697479';
wwv_flow_imp.g_varchar2_table(17) := '2C207374726565742C2073746174652C207A6970636F64652076616C7565732066726F6D207468652070616765206974656D732E0D0A20202F2F205768656E20746865207365727665722072657475726E732074686520726573756C74732C2072656E64';
wwv_flow_imp.g_varchar2_table(18) := '65722074686F736520746F20746865206D617020616E6420726563656E7465722E0D0A2020617065782E7365727665722E706C7567696E28705F616A61785F6964656E7469666965722C207B7830313A20705F7374726565742C207830323A20705F6369';
wwv_flow_imp.g_varchar2_table(19) := '74792C207830333A20705F73746174652C207830343A20705F7A69702C207830353A20705F636F6C6C656374696F6E5F6E616D657D2C207B0D0A20202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A202020202020696620';
wwv_flow_imp.g_varchar2_table(20) := '28226572726F722220696E20704461746129207B0D0A2020202020202020617065785F616C65727428657272293B0D0A2020202020207D20656C7365207B0D0A09092020202073657454696D656F75742866756E6374696F6E2829207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(21) := '2020202020766172206665617473203D206D61702E647261772E676574416C6C28293B0D0A20202020202020202020666F722876617220693D303B693C66656174732E66656174757265732E6C656E6774682D313B692B2B29207B0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(22) := '20202020206D61702E647261772E64656C6574652866656174732E66656174757265735B695D2E6964293B0D0A202020202020202020207D0D0A0920202020202020206665617473203D206D61702E647261772E676574416C6C28293B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(23) := '20202020207661722067656F6D203D2066656174732E66656174757265735B305D2E67656F6D657472793B0D0A2020202020202020202073796E63436F6F72647346726F6D47656F6D657472792867656F6D293B0D0A0909202020207D2C20313030293B';
wwv_flow_imp.g_varchar2_table(24) := '0D0A20202020202020206D61702E647261772E616464287044617461293B0D0A0909202020206D61702E73657443656E7465722870446174612E636F6F7264696E61746573293B0D0A20202020202020206D61702E67657443616E76617328292E737479';
wwv_flow_imp.g_varchar2_table(25) := '6C652E637572736F72203D2027706F696E746572273B0D0A2020202020207D0D0A0920207D2C0D0A202020206572726F723A2066756E6374696F6E20286A717868722C207374617475732C2065727229207B0D0A202020202020617065785F616C657274';
wwv_flow_imp.g_varchar2_table(26) := '28657272293B0D0A2020202020206D61702E67657443616E76617328292E7374796C652E637572736F72203D2027706F696E746572273B0D0A202020207D0D0A20207D293B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(1677050618433477940)
,p_plugin_id=>wwv_flow_imp.id(1908114832207108187)
,p_file_name=>'mapbits-geocode.js'
,p_mime_type=>'application/javascript'
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
