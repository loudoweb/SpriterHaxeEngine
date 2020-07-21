package spriter.library;
import openfl.display.Sprite;
import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.TilesetEx;
import openfl.geom.Rectangle;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.util.SpriterUtil;

/**
 * Openfl renderer with new tilemap renderer
 * Openfl version >= 4.0.4
 * You will need openfl-atlas on haxelib which is an Tileset extension to get tiles by name and have their size (offset...)
 * @author loudo
 */
class TilemapLibrary extends AbstractLibrary
{

	public var view:Sprite;
	public var tilemap:Tilemap;
	public var tilesetsLibrary:Array<TilesetEx>;//all your Tileset

	var tilesCache:Array<Tile>;
	/**
	 * 
	 * @param	tilesetEx Find this class in openfl-atlas on haxelib (https://github.com/loudoweb/openfl-atlas)
	 * @param	view the single canvas you want to draw into
	 * @param	width size of bitmapData
	 * @param	height size of bitmapData
	 * @param	smooth
	 */
	public function new(tilesets:Array<TilesetEx>, view:Sprite, width:Int, height:Int, smoothing:Bool = true) 
	{
		super("");

		this.view = view;
		this.view.mouseEnabled = false;
		this.view.mouseChildren = false;
		
		tilesetsLibrary = tilesets;
		
		tilemap = new Tilemap(width, height, tilesetsLibrary[0], smoothing);
		
		view.addChild(tilemap);
		
		tilesCache = [];
	}
	override public function getFile(name:String):Dynamic
	{
		return 0;
	}
	/**
	 * Call clear() every frame to clear the graphic before a new rendering
	 */
	override public function clear():Void
	{
		while (tilemap.numTiles > 0)
		{
			tilesCache.push(tilemap.removeTileAt(0));
		}
	}
	override public function render():Void
	{
		//Not needed. Openfl render automatically when added to Stage
	}
	
	override public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		var lib:TilesetEx = null;
		var tileID:Int = -1;
		var size:Rectangle = null;
		
		for (i in 0...tilesetsLibrary.length)
		{
			lib = tilesetsLibrary[i];
			tileID = lib.getImageID(name);//TODO should we store from which sheets the tile comes from?
			if (tileID != -1) {
				size = lib.getSize(tileID);
				break;
			}
		}
		if (tileID == -1 || info.a == 0)
			return;
		
		info.angle = SpriterUtil.fixRotation(info.angle);//fix anti clockwise rotation
		
		//compute (note: outside compute method because of offsets needed : size.x, size.y)
		var rad = SpriterUtil.toRadians(info.angle);
		var s = Math.sin(rad);
		var c = Math.cos(rad);
		
		var posX = info.x;
		var posY = -info.y;//fix y inverted on Spriter
		
		var pivotX =  size.x + pivots.pivotX * size.width;
		var pivotY =  size.y + (1 - pivots.pivotY) * size.height;
		
		info.x = (0 - pivotX) * c - (0 - pivotY) * s + posX;
        info.y = (0 - pivotX) * s + (0 - pivotY) * c + posY;
		//end compute
		
			
		var tile:Tile;
		if (tilesCache.length > 0)
		{
			tile = tilesCache.pop();
			tile.id = tileID;
			tile.tileset = lib;
			tile.x = info.x;
			tile.y = info.y;
			tile.scaleX = info.scaleX;
			tile.scaleY = info.scaleY;
			tile.rotation = info.angle;
			tile.alpha = info.a;
		}else {
			
			tile = new Tile(tileID, info.x, info.y, info.scaleX, info.scaleY, info.angle);
			tile.tileset = lib;
		}
		
		tilemap.addTile(tile);
		
		//info.put();//back to pool
		info = null;
		pivots = null;
	}
	
	override public function destroy():Void 
	{
		destroyData();
		destroyTilemap();
		view = null;
	}
	
	inline public function destroyData():Void
	{
		tilesetsLibrary = null;
		tilesCache = null;
	}
	
	inline public function destroyTilemap():Void
	{
		if (tilemap != null && tilemap.parent != null)
			tilemap.parent.removeChild(tilemap);
		tilemap = null;
	}
	/**
	 * If you need to remove Tiles from the cache to release for GC.
	 * For example if one frame you need 1000 Tiles but after you only need few Tiles most of the times, you can clamp the cache to free some memory
	 * @usage	right after calling clear() because you won't have any data in your cache overwise
	 * @param	maxTiles
	 */
	public function clampCache(maxTiles:Int):Void
	{
		if (maxTiles < tilesCache.length) {
			tilesCache.splice(0, tilesCache.length - maxTiles);
		}
	}
	
}