import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';
import 'package:flutter/material.dart';
import 'package:tiled/tiled.dart' as tiled;

/// Loads a Tiled map with performance optimizations:
/// - Compiles static layers into single images (eliminates ghost lines)
/// - Preserves animations on animated layers (auto-detected)
/// - Automatically maintains correct layer ordering
class OptimizedTiledMapLoader {
  /// Load and optimize a Tiled map
  /// 
  /// [tmxFile] - Path to the TMX file
  /// [tileSize] - Size of each tile
  /// [images] - Optional Images cache with custom prefix
  /// [visibleLayers] - Optional list of layer names to render (default: all except invisible)
  /// [animatedLayers] - Optional manual override for animated layer names (auto-detects if not specified)
  /// 
  /// Returns a list of components to add to your game, in correct rendering order
  static Future<List<Component>> load({
    required String tmxFile,
    required Vector2 tileSize,
    Images? images,
    List<String>? visibleLayers,
    List<String>? animatedLayers,
  }) async {
    final components = <Component>[];
    
    // Load the tiled component to access the map structure
    final tiledComponent = await TiledComponent.load(
      tmxFile,
      tileSize,
      images: images,
    );
    
    // Get all layers in their original order
    final allLayers = tiledComponent.tileMap.map.layers
        .where((layer) => layer.visible || visibleLayers?.contains(layer.name) == true)
        .toList();
    
    // Filter to only requested layers if specified
    final layersToRender = visibleLayers != null
        ? allLayers.where((layer) => visibleLayers.contains(layer.name)).toList()
        : allLayers;
    
    // Auto-detect animated layers if not manually specified
    final detectedAnimatedLayers = animatedLayers ?? 
        _detectAnimatedLayers(tiledComponent.tileMap, layersToRender);
    
    // Group consecutive static layers together
    final groups = <_LayerGroup>[];
    _LayerGroup? currentGroup;
    
    for (final layer in layersToRender) {
      final isAnimated = detectedAnimatedLayers.contains(layer.name);
      
      if (isAnimated) {
        // Finish current static group if any
        if (currentGroup != null) {
          groups.add(currentGroup);
          currentGroup = null;
        }
        // Add animated layer as its own group
        groups.add(_LayerGroup(isAnimated: true, layerNames: [layer.name]));
      } else {
        // Add to current static group or create new one
        if (currentGroup == null) {
          currentGroup = _LayerGroup(isAnimated: false, layerNames: [layer.name]);
        } else {
          currentGroup.layerNames.add(layer.name);
        }
      }
    }
    
    // Add final static group if any
    if (currentGroup != null) {
      groups.add(currentGroup);
    }
    
    // Render each group with appropriate priority (higher priority = renders on top)
    // Start with low priority at bottom, increase as we go up
    int priorityBase = -1000;
    
    for (final group in groups) {
      if (group.isAnimated) {
        // Render animated layers using TiledComponent
        final animatedComponent = await TiledComponent.load(
          tmxFile,
          tileSize,
          images: images,
          layerPaintFactory: (opacity) => Paint()
            ..color = Color.fromRGBO(255, 255, 255, opacity)
            ..filterQuality = FilterQuality.none,
        );
        
        // Hide all layers except the ones in this group
        for (final layer in animatedComponent.tileMap.map.layers) {
          layer.visible = group.layerNames.contains(layer.name);
        }
        
        animatedComponent.priority = priorityBase;
        components.add(animatedComponent);
      } else {
        // Compile static layers into a single image
        final imageCompiler = ImageBatchCompiler();
        final compiledLayers = imageCompiler.compileMapLayer(
          tileMap: tiledComponent.tileMap,
          layerNames: group.layerNames,
        );
        compiledLayers.priority = priorityBase;
        components.add(compiledLayers);
      }
      
      // Increment priority for next group (renders on top)
      priorityBase++;
    }
    
    return components;
  }
  
  /// Detects which layers contain animated tiles
  static List<String> _detectAnimatedLayers(
    RenderableTiledMap tileMap,
    List<dynamic> layers,
  ) {
    final animatedLayerNames = <String>[];
    
    // Build a set of all tile GIDs that have animations defined
    final animatedTileGids = <int>{};
    for (final tileset in tileMap.map.tilesets) {
      final firstGid = tileset.firstGid;
      if (firstGid == null) continue;
      
      for (final tile in tileset.tiles) {
        if (tile.animation.isNotEmpty) {
          // GID = firstGid + localId
          final gid = firstGid + tile.localId;
          animatedTileGids.add(gid);
        }
      }
    }
    
    // Check each layer for animated tiles
    for (final layer in layers) {
      if (layer.name == null) continue;
      
      // Check if this layer contains any animated tiles
      bool hasAnimatedTiles = false;
      
      // Get the tile data for this layer
      final layerData = tileMap.map.layerByName(layer.name);
      if (layerData is tiled.TileLayer) {
        final tileData = layerData.tileData;
        if (tileData == null) continue;
        
        // Iterate through the tile data (2D array of GIDs)
        for (int y = 0; y < layerData.height; y++) {
          for (int x = 0; x < layerData.width; x++) {
            final tileGid = tileData[y][x].tile;
            if (tileGid > 0 && animatedTileGids.contains(tileGid)) {
              hasAnimatedTiles = true;
              break;
            }
          }
          if (hasAnimatedTiles) break;
        }
      }
      
      if (hasAnimatedTiles) {
        animatedLayerNames.add(layer.name);
      }
    }
    
    return animatedLayerNames;
  }
}

/// Internal class to group consecutive static or animated layers
class _LayerGroup {
  final bool isAnimated;
  final List<String> layerNames;
  
  _LayerGroup({required this.isAnimated, required this.layerNames});
}
