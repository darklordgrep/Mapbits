# Mapbits
Oracle has added a native map region to Application Express (APEX) version 21.1. On its own, this new map region 
can be used to visualize spatial data from the database in a pre-rendered basemap. However, APEX exposes an interface
to the underlying map via javascript, offering possibilities beyond merely simple data visualization.

Mapbits is a family of plugins that add functionality to the APEX map region. Currently available plugins include:

- **Mapbits Drawing** adds point, line, and/or polygon drawing tools to the APEX native map region using [mapbox-gl-draw](https://github.com/mapbox/mapbox-gl-draw). Drawing geometry 
is stored in a collection in GeoJSON format. A developer can write processes to initialize the drawing geometry from the database, as well as write geometry back to the database. If geolocation is enabled and available in the browser, then a user can click a tool button to create and modify geometries based on the user's location.
For more information, review the [Mapbits Drawing Tutorial](Documentation/Drawing_Tutorial.md).
- **Mapbits Geocoder** is a dynamic action that calculates a coordinate for an address defined in page items using the [Nominatim](https://nominatim.org/) geocoding service. It then sets the point geometry of the associated Mapbits Drawing plugin.
to this coordinate. 
- **Mapbits Layer WMS** adds support for OGC Web Map Service (WMS) layers.
- **Mapbits Layer ArcGIS REST GeoJSON** adds support for ArcGIS Rest vector data layers.
- **Mapbits Layer Raster** adds support for image layers with extent coordinates
- **Mapbits Zoom To** is a dynamic action that pans and zooms the map view to the extent of a feature. 
- **Mapbits Labeler** labels a Map region native layer using the layer's tooltip or Info Window value. 
- **Mapbits Geolocation** shows a pulsing dot on a map region reflecting the user's location if that feature is enabled in the user's browser. 
- **Mapbits Set Custom Marker** is a dynamic action that creates and updates a marker on the map based on a page item value.
- **Mapbits Stationing Layer** adds stationing marks and labels to a 4d linear geometry in a map based on the visible domain values in a chart region.
- **Mapbits Legend** is a region that shows a map's layer names together and associated symbology. 
- **Mapbits Basemap** adds custom backgrounds for map regions, as well as a toggle to switch between basemaps.
- **Mapbits Lodestar Layer** provides an alternative to native map region layers that offer more of the functionality built into Maplibre such as symbology and filtering. For more information, see the [Mapbits Lodestar Layer Tutorial] (Documentation/Lodestar_Tutorial.md).
- **Mapbits Lodestar Select Features** is a dynamic action plugin that highlights LodeStar Layer features based on a SQL query. 
- **Mapbits Export To Image** is a dynamic action that exports a map region to image data, allowing to be directly downloaded or added to reports.
- **Mapbits Georaster Layer** adds support for displaying Oracle Georasters. Supported types include 8-bit RGB images and 32-bit single band floating point digital elevation models (DEM). The latter of these is rendered as Maplibre-style Terrain.

# Requirements
Demonstration application and plugins require Oracle DBMS and Application Express. The table below shows the recent Mapbits release versions and the versions of APEX on which these releases were either developed or tested. 

  _ | APEX 22.1 | APEX 22.2 | APEX 23.2 | APEX 24.1
--- | --- | --- | --- | ---
Mapbits 4.5 | X | X |  | 
Mapbits 4.6 |  | X | X |
Mapbits 4.7 |  | X | X |
Mapbits 4.8 |  | | X | X

A particular Mapbits release will install on a later version of APEX, but changes over time in APEX or maplibre may result in anomolous behavior. A Mapbits release will not install on a version on APEX prior to the version used for development and release.

# Installation
You can install individual plugins by selecting and downloadling the plugin of interest from the Downloads section below. In your application, go to the 'Plug-ins' page from the 'Shared Components'. Click 'Import' and follow the steps in the wizard. When prompted to upload an import file, use the plugin file you downloaded.

Alternatively, you can install Mapbits by installing the Mapbits Demo application and importing the plugins into your application from the Demo application through the following steps: 

1) Download the [Mapbits Demo Application](mapbits_demo_apex_application.sql).
2) In your APEX AppBuilder, click the 'Import' button and follow the steps in the wizard. When prompted to upload an import file, use the Mapbits Demo Application from step 1.
3) In your APEX application, go to the 'Plug-ins' page from the 'Shared Components'. Click 'Create' and, in the wizard, select 'As a Copy of an Existing Plug-in'. Reference the 'Mapbits Demo' Application and select the plugin you would like to use. You can choose between simplying 'Copying' the plugin to your application or 'Copy Subscribing', which will allow you to more easily push and pull plugin updates from the demo application to your application.

# Usage
After installation, the plugins will be available as a page item or dynamic action type when you create new page items or dynamic actions. For Mapbits page items and dynamic actions, make sure to add them to the map region on your page. They will not work if added to other region types. For additional plugin-specific direction, refer to the help available in the plugins themseles.

# Tutorials
* [Mapbits Drawing Tutorial](Documentation/Drawing_Tutorial.md)
* [Mapbits Lodestar Layer Tutorial](Documentation/Lodestar_Tutorial.md)
* [Mapbits Legend Tutorial](Documentation/Legend_Tutorial.md)
  
# Downloads
* [Mapbits Demo Application](mapbits_demo_apex_application.sql) *This application contains all plugins as well as sample data to show them in action.*
* [Mapbits Drawing Plugin](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_draw.sql)
* [Mapbits Layer WMS Plugin](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_layer_wms.sql)
* [Mapbits Layer ArcGIS REST GeoJSON Plugin](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_layer_rest_gjs.sql)
* [Mapbits Layer Raster](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_layer_raster.sql)
* [Mapbits Zoom To](APEX_Map_Region_Accessory_Plugins/dynamic_action_plugin_mil_army_usace_mapbits_zoom_to.sql)
* [Mapbits Labeler](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_labeler.sql)
* [Mapbits Geolocation](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_geolocation.sql)
* [Mapbits Set Custom Marker](APEX_Map_Region_Accessory_Plugins/dynamic_action_plugin_mil_army_usace_mapbits_custommarker.sql)
* [Mapbits Stationing Layer](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_layer_station.sql)
* [Mapbits Legend](APEX_Map_Region_Accessory_Plugins/region_type_plugin_mil_army_usace_mapbits_legend.sql)
* [Mapbits Legend Entry](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_legend_entry.sql)
* [Mapbits Basemap](APEX_Map_Region_Accessory_Plugins/region_type_plugin_mil_army_usace_mapbits_layer_basemap.sql)
* [Mapbits Lodestar Layer](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_layer_lodestar.sql)
* [Mapbits Lodestar Select Features](APEX_Map_Region_Accessory_Plugins/dynamic_action_plugin_mil_army_usace_mapbits_select_features.sql)
* [Mapbits Export To Image](APEX_Map_Region_Accessory_Plugins/dynamic_action_plugin_mil_army_usace_mapbits_export_to_image.sql)
* [Mapbits Georaster Layer](APEX_Map_Region_Accessory_Plugins/item_type_plugin_mil_army_usace_mapbits_layer_georaster.sql)

# Demonstration
[View Mapbits in Action](https://taw4i5xyrvvl9hk-usacedemo.adb.us-ashburn-1.oraclecloudapps.com/ords/r/grep02/mapbits-demo/home)
