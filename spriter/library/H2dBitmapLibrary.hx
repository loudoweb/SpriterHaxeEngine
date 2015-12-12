package spriter.library;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import openfl.Assets;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.util.ColorUtils;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author david Blackmagic elahee
 */
class H2dBitmapLibrary extends AbstractLibrary
{
	public var _root : h2d.Sprite;
	
	var _parent : h2d.Sprite;
	var _sh : h2d.Drawable.DrawableShader;
	var _tileCache : haxe.ds.UnsafeStringMap<h2d.Tile>;
	public function new(basePath:String, parent : h2d.Sprite ) 
	{
		super(basePath);
		_parent = parent;
		_tileCache = new haxe.ds.UnsafeStringMap();
		_root = new h2d.Sprite(_parent);
	}
	
	override public function getFile(name:String):Dynamic {
		if ( _tileCache.exists( name ))
			return _tileCache.get(name);
		
		_tileCache.set( name , h2d.Tile.fromAssets(_basePath + name));
			
		return _tileCache.get(name);
	}
	
	override public function clear():Void
	{
		_root.visible = false;
		_root.removeAllChildren();
    }
	
	override public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		var tile : h2d.Tile = cast getFile(name);
		var bmp = new h2d.Bitmap(tile #if !heaps , _sh #end);
		#if !heaps
		if ( _sh == null ) _sh = bmp.shader;
		#end
		
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