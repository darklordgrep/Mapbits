# Developing and Debugging

This guide explores some of the internals of Mapbits and MapLibre, which may be helpful when debugging applications or developing Mapbits itself.

## Accessing the MapLibre Map object

To get a map region's Map object, call the region's `getMapObject()` function:

```js
let map = apex.region('StaticIdOfMapRegion').getMapObject();
```

You can also get it using a Lodestar Layer's `async getMap()` method.

The methods of this object are documented in the [MapLibre documentation](https://maplibre.org/maplibre-gl-js/docs/API/classes/Map/). Some of the most helpful methods are:

- `getStyle()`: Gets the current style definition. This is helpful for checking what layers and style properties have been added to the map.
- `getSource()`: Gets a data source by name. This can help debug whether the data has been added to the map correctly. The names of the sources are listed in the layer definitions.
- `addLayer()`: Adds a new layer to the map.
- `setLayoutProperty()` and `setPaintProperty()`: Changes layout or paint properties. This can help test style changes quickly.

## How Custom Icons Work

Custom icons (Font APEX icons and `#APP_FILES#` images) are added to the map using a handler on the map's `styleimagemissing` event. This event is emitted when the map style calls for an image that is not in the map's sprite sheet. Layers that support custom icons automatically add a handler that generates the icon based on the name.
