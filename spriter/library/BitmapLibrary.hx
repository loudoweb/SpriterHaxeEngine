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
 * Simple OpenFL renderer using BitmapData and BitmapData.copypixels().
 * @author Loudo
 */
class BitmapLibrary extends AbstractLibrary
{
	
	var _canvas : BitmapData;
	
    var _point : Point;
    var _matrix : Matrix;
	var _alphaTransform:ColorTransform;
	var _currentBd:BitmapData;
	var _alphaBd:BitmapData;
	
	public function new(basePath:String, canvas : BitmapData) 
	{
		super(basePath);
		_canvas = canvas;
        _point = new Point();
        _matrix = new Matrix();
		_alphaTransform = new ColorTransform(1, 1, 1, 1);
	}
	override public function getFile(name:String):Dynamic
	{
		return Assets.getBitmapData(_basePath+name,true);
	}
	override public function clear():Void
	{
        _canvas.fillRect(_canvas.rect, 0x00ffffff);
		_canvas.lock();
    }
	override public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		_currentBd = cast getFile(name);
		
		info = compute(info, pivots, _currentBd.width, _currentBd.height);
		
		
		if(info.angle == 0 && info.scaleX == 1 && info.scaleY == 1)
        {
            _point.x = info.x;
            _point.y = info.y;
			_alphaBd = new BitmapData(_currentBd.width, _currentBd.height, true, ColorUtils.multiplyAlpha(Math.abs(info.a)));
            _canvas.copyPixels(_currentBd, _currentBd.rect, _point,_alphaBd, _point,true);
        }
        else
        {
            _matrix.identity();
            _matrix.scale(info.scaleX, info.scaleY);
            _matrix.rotate(SpriterUtil.toRadians(SpriterUtil.fixRotation(info.angle)));
            _matrix.translate(info.x, info.y);
			_alphaTransform.alphaMultiplier = Math.abs(info.a);
            _canvas.draw(_currentBd, _matrix, _alphaTransform, null, null, true);
        }
		info = null;
	}
	override public function render():Void
	{	
		_canvas.unlock();
	}
	override public function destroy():Void
	{
		clear();
		_alphaTransform = null;
		 _point = null;
        _matrix = null;
		_currentBd.dispose();
		_currentBd = null;
		if(_alphaBd != null)
			_alphaBd.dispose();
		_alphaBd = null;
		render();//to unlock canvas and make it available
		_canvas.dispose();
		_canvas = null;
	}
	
}