package spriter.library;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import openfl.Assets;
import openfl.display.Tilesheet;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.definitions.TimelineKey.CurveType;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author Loudo
 */
class SpriterLibrary
{
	private var _basePath:String;
	private var _root:Sprite;
	
	/**
	 * One instance per group
	 */
	private var _assets:Map<String, Bitmap>;
	private var _groups:Map<String, Map<String, Bitmap>>;
	
	
	/**
	 * 
	 * @param	_basePath 
	 */
	public function new(basePath :String) 
	{
		_basePath = basePath;
		_groups = new Map < String, Map < String, Bitmap >> ();
	}
	
	public function setRoot(root:Sprite):Void {
		_root = root;
	}
	
	/**
	 * 
	 * @param	name of the image
	 * @return
	 */
	public function getFile(name:String):Dynamic
	{
		return Assets.getBitmapData(_basePath+name,true);
	}
	
	public function clear():Void
	{
		//TODO optimization : clear only image that can not be reuse or something
		var i:Int = _root.numChildren;
		while (--i >= 0)
		{
			_root.removeChildAt(i);
			
		}
		
	}
	
	public function addGraphic(group:String, timeline:Int, key:Int, name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		var idImage:String = timeline + ':' + key + ':' + name;
		
		var bitmap:Bitmap;
		if (_groups.exists(group)) {
			_assets = _groups.get(group);
			if(_assets.exists(idImage)){
				bitmap = _assets.get(idImage);
			}else {
				bitmap = new Bitmap (getFile(name), PixelSnapping.AUTO, true);
				_assets.set(idImage, bitmap);
				_groups.set(group, _assets);
			}
		}else {
			_assets = new Map<String, Bitmap>();
			bitmap = new Bitmap (getFile(name), PixelSnapping.AUTO, true);
			_assets.set(idImage, bitmap);
			_groups.set(group, _assets);
		}
		
		_root.addChild(bitmap);

		setting(compute(info, pivots, bitmap.bitmapData.width, bitmap.bitmapData.height), bitmap);
		
	}
	public function setting(info:SpatialInfo, display:Dynamic):Void
	{
		display.x = info.x;
		display.y = info.y;
		display.scaleX = info.scaleX;
		display.scaleY = info.scaleY;
		display.rotation = info.angle;
	}
	
	public function compute(info:SpatialInfo, pivots:PivotInfo, width:Float, height:Float):SpatialInfo
	{
		var rad = SpriterUtil.toRadians(SpriterUtil.normalizeRotation(info.angle));
		var s = Math.sin(rad);
		var c = Math.cos(rad);
		var imagex = -(pivots.pivotX + 0.0) * width * info.scaleX;
		var imagey = (pivots.pivotY  - 1.0) * height * info.scaleY;		
		return new SpatialInfo(((imagex * c) - (imagey * s) + info.x), ((imagex * s) + (imagey * c) - info.y), info.angle, info.scaleX, info.scaleY, info.a, info.spin);
	}
	
	
	public function render():Void
	{
		
	}
	
}