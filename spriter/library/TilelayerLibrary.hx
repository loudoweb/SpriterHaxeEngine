package spriter.library;
import aze.display.SparrowTilesheet;
import aze.display.TileGroup;
import aze.display.TileLayer;
import aze.display.TileSprite;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import openfl.display.Tilesheet;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author Loudo
 */
class TilelayerLibrary extends AbstractLibrary
{
	private var _root:Sprite;
	
	private var _layer:TileLayer;
	
	private var _group:TileGroup;
	
	/**
	 * Additional library for Spriter. It uses haxelib tilelayer.
	 * 
	 * @param	dataPath .json
	 * @param	atlasPath .png
	 */
	public function new(dataPath:String = '', atlasPath:String = '') 
	{
		super(dataPath);
		var sheetData = Assets.getText(dataPath);
		var tilesheet = new SparrowTilesheet(Assets.getBitmapData(atlasPath), sheetData);
		_layer = new TileLayer(tilesheet, true);
		
		/*_group = new TileGroup(_layer);
		_layer.addChild(_group);*/
	}
	
	override public function setRoot(root:Sprite):Void {
		_root = root;
		_root.addChild(_layer.view); // layer is NOT a DisplayObject
	}
	
	override public function getFile(name:String):Dynamic
	{
		var sprite:TileSprite = new TileSprite(_layer, name);
		return sprite;
	}
	
	override public function clear():Void
	{
		_layer.removeAllChildren();
	}
	
	override public function addGraphic(group:String, timeline:Int, key:Int, name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		
		var sprite:TileSprite = getFile(name);
		_layer.addChild(sprite);
		
		var spatialResult:SpatialInfo = compute(info, pivots, sprite.width, sprite.height);
		
		
		//sprite.offset = getPivotsRelativeToCenter(info, pivots, sprite.width, sprite.height);//TOFIX tilelayer seems buggy
		sprite.x =  spatialResult.x;
		sprite.y =  spatialResult.y;
		sprite.rotation = SpriterUtil.toRadians(SpriterUtil.fixRotation(spatialResult.angle));
		sprite.scaleX = spatialResult.scaleX;
		sprite.scaleY = spatialResult.scaleY;
		
		sprite.visible = true;
	}
	
	private function getPivotsRelativeToCenter(info:SpatialInfo, pivots:PivotInfo, width:Float, height:Float):Point
	{
		var x:Float = (pivots.pivotX - 0.5) * width * info.scaleX;
		var y:Float = (0.5 - pivots.pivotY) * height * info.scaleY;
		return new Point(x, y);
	}
	
	//overrided because tilelayer use the center of the sprite for the coordinates
	override public function compute(info:SpatialInfo, pivots:PivotInfo, width:Float, height:Float):SpatialInfo
	{
		var degreesUnder360 = SpriterUtil.under360(info.angle);
		var rad = SpriterUtil.toRadians(degreesUnder360);
		var s = Math.sin(rad);
		var c = Math.cos(rad);
		
		var pivotX =  info.x;
		var pivotY =  info.y;
		
		var preX = info.x - pivots.pivotX * width * info.scaleX + 0.5 * width * info.scaleX;
		var preY = info.y + (1 - pivots.pivotY) * height * info.scaleY - 0.5 * height * info.scaleY;
		
		var x2 = (preX - pivotX) * c - (preY - pivotY) * s + pivotX;
        var y2 = (preX - pivotX) * s + (preY - pivotY) * c + pivotY;
		
		return new SpatialInfo(x2, -y2, degreesUnder360, info.scaleX, info.scaleY, info.a, info.spin);
	}
	
	override public function render():Void
	{
		_layer.render();
	}
	
	
	
}