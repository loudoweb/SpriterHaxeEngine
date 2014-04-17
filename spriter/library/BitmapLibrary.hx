package spriter.library;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import openfl.Assets;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author Loudo
 */
class BitmapLibrary extends AbstractLibrary
{
	
	var _canvas : BitmapData;
    var _point : Point;
    var _matrix : Matrix;
	var _alphaTransform:ColorTransform; 
	
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
        _canvas.fillRect(_canvas.rect, 0xffffffff);
		_canvas.lock();
    }
	override public function addGraphic(group:String, timeline:Int, key:Int, name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		var bmp : BitmapData = cast getFile(name);
		
		var spatialResult:SpatialInfo = compute(info, pivots, bmp.width, bmp.height);
		
		
		if(spatialResult.angle == 0 && spatialResult.scaleX == 1 && spatialResult.scaleY == 1)
        {
            _point.x = spatialResult.x;
            _point.y = spatialResult.y;
			_alphaTransform.alphaMultiplier = Math.abs(spatialResult.a);//TOFIX bug negative alpha
			bmp.colorTransform(bmp.rect, _alphaTransform);//TOFIX doesn't work well
            _canvas.copyPixels(bmp, bmp.rect, _point,true);
        }
        else
        {
            _matrix.identity();
            _matrix.scale(spatialResult.scaleX, spatialResult.scaleY);
            _matrix.rotate(SpriterUtil.toRadians(SpriterUtil.fixRotation(spatialResult.angle)));
            _matrix.translate(spatialResult.x, spatialResult.y);
			_alphaTransform.alphaMultiplier = Math.abs(spatialResult.a);
            _canvas.draw(bmp, _matrix, _alphaTransform, null, null, true);
        }
	}
	override public function setRoot(root:Dynamic):Void 
	{
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
		render();//to unlock canvas and make it available
	}
	
}