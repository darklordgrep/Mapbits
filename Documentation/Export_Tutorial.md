# Export To Image Tutorial

## Overview

The Mapbits Export To Image dynamic action plug-in generates a screenshot of an APEX native Map Region.

The resulting image contains all map layers, including native APEX ones and Mapbits Lodestar, Raster, Georaster, WMS, ArcGIS Rest, and Drawing layers. It does not include markers, such as Mapbits HTML Marker layers or Set Marker DA markers.

## Configuration

To use the plugin, create a button and add a dynamic action to it. Choose **Mapbits Export To Image [Plug-In]** as the Action.

There are two ways to retrieve the image data: a collection or the user's browser.

### Collection

To use a collection to upload the image to the database, choose "Collection" as the "Export Destination" and set the "Export Image Collection Name" attribute. Then, create a second dynamic action on the Map Region. Set its Event to "Map Export Completed [Mapbits Export To Image]". Create an "Execute Server-side Code" action and use the following code to query the image data:

```sql
declare
  l_image_data blob;
  l_mime_type varchar2(100);
begin
  select blob001, c001 into l_image_data, l_mime_type from apex_collections where collection_name = 'MY_COLLECTION_NAME';

  -- do something with l_image_data ...
end;
```

### Download

If you just want the button to download the screenshot to the user's browser, choose Download as the Export Destination. You can select an item using the "Filename Item" attribute, and the value of that item will be used as the filename.

## Image Size

You can choose the size of the image. Note that if you use this attribute, there may be small differences between the displayed map and the screenshot, since in this case the plug-in creates a copy of the underlying MapLibre map.

If you leave this blank, the screenshot will be the same size as the map region.

## Zoom and Center

You can also change the zoom level and center coordinates of the exported image, rather than using the current map view that the user may have panned or zoomed. Like image size, this requires cloning the MapLibre map, so there may be small differences between the displayed map and the screenshot.

To do this, provide a function in the **Initialization JavaScript Function** attribute that returns an object with `zoom` and/or `center` properties. For example:

```javascript
function() {
  return {
    zoom: 3,
    center: [ -98.6, 39.8 ],
  };
}
```

The function is executed when the page loads, not when the dynamic action is fired.

## Events

### Map Export Completed

This event is emitted on the map region when the export is complete. You can use this event to trigger additional processing after the image is available, such as reading it from a collection in an **Execute PL/SQL Code** action.
