package spriter.library;
import flash.display.Bitmap;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import openfl.Assets;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.util.SpriterUtil;

/**
 * Simple OpenFL renderer using Bitmap and dislayList.
 * Use for quick test purpose. Not recommended for production.
 * TODO optimization: cache Bitmap and such things
 * @author Loudo
 */
class SpriterLibrary extends AbstractLibrary
{
	/**
	 * Sprite where we add childs (Bitmap)
	 */
	var _canvas:Sprite;
	
	var _currentBitmap:Bitmap;
	var _currentSpatialResult:SpatialInfo;
	
	
	/**
	 * Simple OpenFL renderer using Bitmap and dislayList.
	 * @param	basePath path used to find the BitmapData using Assets.getBitmapData();
	 * @param	canvas Sprite where we add childs (Bitmap)
	 */
	public function new(basePath:String, canvas:Sprite) 
	{
		_canvas = canvas;
		super(basePath);
	}
	
	/**
	 * 
	 * @param	name of the image
	 * @return
	 */
	override public function getFile(name:String):Dynamic
	{
		return Assets.getBitmapData(_basePath+name,true);
	}
	
	override public function clear():Void
	{
		var i:Int = _canvas.numChildren;
		while (--i >= 0)
		{
			_canvas.removeChildAt(i);
			
		}
		
	}
	
	override public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{

		_currentBitmap = new Bitmap (getFile(name), PixelSnapping.AUTO, true);
		
		_currentSpatialResult = compute(info, pivots, _currentBitmap.bitmapData.width, _currentBitmap.bitmapData.height);
		_currentBitmap.x = _currentSpatialResult.x;
		_currentBitmap.y = _currentSpatialResult.y;
		_currentBitmap.scaleX = _currentSpatialResult.scaleX;
		_currentBitmap.scaleY = _currentSpatialResult.scaleY;
		_currentBitmap.rotation = SpriterUtil.fixRotation(_currentSpatialResult.angle);
		_currentBitmap.alpha = Math.abs(_currentSpatialResult.a);
		_canvas.addChild(_currentBitmap);
	}
	
	override public function render():Void
	{
		//we use display list so we use addChild in addGraphic()
	}
	
	override public function destroy():Void
	{
		clear();
		_currentBitmap = null;
		_currentSpatialResult = null;
	}
	
}