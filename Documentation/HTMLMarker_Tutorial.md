# HTML Marker Tutorial

## Overview

The Mapbits HTML Marker Plug-In is a page item that adds an HTML-based marker layer to an APEX map region.

## Configuration

To add an HTML Marker layer to a map, create a Page Item in the map region and set its type to **Mapbits HTML Marker**. Configure the layer source and set the **Geometry Column** attribute. Then, write the marker HTML in the **Marker Content** attribute. You can use substitutions and template directives, as described in [Oracle's documentation](https://docs.oracle.com/en/database/oracle/apex/24.2/htmdb/using-template-directives.html).

To avoid showing too many markers at once, you may also want to configure the **Min/Max Zoom** attribute. Separate the numbers with a dash. You can omit one or the other, e.g. `3-` for a minimum zoom of 3 or `-11` for a maximum zoom of 11.

## Events

Like the Lodestar Layer plug-in, HTML Marker has four events: Feature Clicked, Visibility Toggled, Loading Started, and Loading Finished. Their functionality is the same as in the Lodestar Layer.

## JavaScript API

Javascript methods can be invoked on plugin page item instances through the **apex.item** function. For example, calling `apex.item('P1_RASTER').show()` calls the show method on a GeoRaster plugin instance named P1_RASTER.

### Standard

The HTML Marker item implements several of the standard APEX item methods:

- **`show()`**: Shows the layer.
- **`hide()`**: Hides the layer.
- **`async refresh()`**: Reloads the source data.

### Other

The HTML Marker item also has several of its own methods:

- **`isVisible()`**: Returns a boolean indicating whether the layer is currently visible.
- **`setSelectedFeatures(features, action)`**: Same as the matching function in the Lodestar Layer plug-in. To change the template when a feature is selected, use the `MAPBITS_SELECTED` substitution:

  ```html
  <div class="marker {if MAPBITS_SELECTED/}selected-marker{endif/}"></div>
  ```

  Selection will not work if the **ID Column** attribute is not set.

- **`selectAllFeatures()`**: Selects all features.
- **`clearSelection()`**: Clears the selection.
- **`getSourceData()`**: Gets the queried source data.
- **`async waitForLoad()`**: Returns a promise that resolves when the HTML marker is loaded and displayed on the map.
- **`async getMap()`**: Convenience method to get the MapLibre map object for the associated map region. The map may not have loaded yet, so this method returns a `Promise`.