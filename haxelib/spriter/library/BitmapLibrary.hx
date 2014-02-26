package spriter.library;
import flash.display.BitmapData;
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
	
	private var _canvas : BitmapData;
    private var _point : Point;
    private var _matrix : Matrix;
	
	public function new(basePath:String, canvas : BitmapData) 
	{
		super(basePath);
		_canvas = canvas;
        _point = new Point();
        _matrix = new Matrix();
	}
	override public function getFile(name:String):Dynamic
	{
		return Assets.getBitmapData(_basePath+name,true);
	}
	override public function clear():Void
	{
        _canvas.fillRect(_canvas.rect, 0);
    }
	override public function addGraphic(group:String, timeline:Int, key:Int, name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		var bmp : BitmapData = cast getFile(name);
		
		var spatialResult:SpatialInfo = compute(info, pivots, bmp.width, bmp.height);
		
		
		if(spatialResult.angle == 0 && spatialResult.scaleX == 1 && spatialResult.scaleY == 1)
        {
            _point.x = spatialResult.x;
            _point.y = spatialResult.y;
            _canvas.copyPixels(bmp, bmp.rect, _point,true);
        }
        else
        {
            _matrix.identity();
            _matrix.scale(spatialResult.scaleX, spatialResult.scaleY);
            _matrix.rotate(SpriterUtil.toRadians(SpriterUtil.fixRotation(spatialResult.angle)));
            _matrix.translate(spatialResult.x, spatialResult.y);
            _canvas.draw(bmp, _matrix, null, null, null, true);
        }
	}
	override public function setRoot(root:Dynamic):Void 
	{
	}
	override public function render():Void
	{	
	}
	
}