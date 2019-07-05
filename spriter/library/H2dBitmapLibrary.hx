package spriter.library;
import haxe.io.Path;
import hxd.res.Loader;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.util.ColorUtils;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author david Blackmagic elahee
 * @author Tommy Brosman
 */
class H2dBitmapLibrary extends AbstractLibrary
{
	public var _root : h2d.Object;
	var _parent : h2d.Object;
	var _tileCache : Map<String, h2d.Tile>;

	public function new(basePath:String, parent:h2d.Object) 
	{
		super(basePath);
		_parent = parent;
		_tileCache = new Map<String, h2d.Tile>();
		_root = new h2d.Object(_parent);
	}
	
	override public function getFile(name:String):Dynamic
	{
		if ( _tileCache.exists( name ))
			return _tileCache.get(name);
		
		var loader:Loader = hxd.Res.loader;
		var tile:h2d.Tile = loader.load(name).toTile();
		_tileCache.set(name, tile);
			
		return _tileCache.get(name);
	}
	
	override public function clear():Void
	{
		_root.visible = false;
		_root.removeChildren();
  }
	
	override public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		var fullPath:String = getFullPath(name);
		var tile:h2d.Tile = cast getFile(fullPath);
		var bmp = new h2d.Bitmap(tile);
		var spatialResult:SpatialInfo = compute(info, pivots, tile.width, tile.height);
		
		bmp.scaleX = spatialResult.scaleX;
		bmp.scaleY = spatialResult.scaleY;
		bmp.rotation = SpriterUtil.toRadians(SpriterUtil.fixRotation(spatialResult.angle));
		bmp.x = spatialResult.x;
		bmp.y = spatialResult.y;
		bmp.alpha = Math.abs(spatialResult.a);
		_root.addChild( bmp );
		_root.visible = false;
	}
	
	override public function render():Void
	{	
		_root.visible = true;
	}
	
	override public function destroy():Void
	{
		clear();
		
		for ( t in _tileCache)
			t.dispose();
		_tileCache = null;
	}
}