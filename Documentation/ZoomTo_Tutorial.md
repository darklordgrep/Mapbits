# Zoom To Tutorial

## Overview

The Mapbits Zoom To plug-in is a Dynamic Action plug-in that zooms a map to a location or bounding box.

## Configuration

To use the Zoom To plug-in, create a Dynamic Action, then create an Action with the **Mapbits Zoom To [Plug-In]** type. Provide a SQL query that returns zero or one rows with a single SDO_GEOMETRY column. When the action is fired, the map will zoom to the given location. If the geometry is a point, it will be centered in the map view; if it is a line or polygon, the map will zoom to show the shape in its entirety. If no geometry is provided, nothing happens.

You must also set the **Affected Elements** / **Region** attribute to the map region you wish to zoom.

If you have multiple shapes and you want to zoom to show all of them, use the [`sdo_aggr_mbr`](https://docs.oracle.com/en/database/oracle/oracle-database/26/spatl/sdo_aggr_mbr.html) aggregate function in your query.

### Padding

For line and polygon geometries, it often looks better to add padding to the bounding box so the shape isn't too close to the edges of the map. Enter a padding amount (in pixels) in the **Padding** attribute.

### Max Zoom

For points or for very small lines and polygons, you can set the **Max Zoom** attribute. The plug-in will not zoom in past this level.

## On Page Load

It is common to center the map on a shape when a page loads. For example, on a form entry page, you might want to show the location of the record on a map. While APEX's native map region has an **Initial Position and Zoom** attribute that can center the map on the features, it only applies the first time the page loads. On subsequent page loads, it remembers the previous location rather than zooming to the new one.

You can use the Zoom To plug-in to fix this. Create a **Page Load** Dynamic Action with a Zoom To action and query the record's geometry. Alternatively, if you already have a Zoom To action elsewhere, enable its **Fire on Initialization** switch.

Enable the **Skip Animation** switch so the map jumps immediately to the feature.

Then, importantly, go to the Map Region, go to the **Attributes** tab, scroll to the **Initial Position and Zoom** section, and change **Type** to **Static Values**. Also set **Longitude** and **Latitude** to 0. This prevents the region's native behavior from interfering with the Zoom To action. You will get a server-side error from the plugin if you forget to change these settings.
