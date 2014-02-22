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
class TilelayerLibrary extends SpriterLibrary
{
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
		super.setRoot(root);
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
		
		sprite.x =  spatialResult.x;
		sprite.y =  spatialResult.y;
		sprite.scaleX = spatialResult.scaleX;
		sprite.scaleY = spatialResult.scaleY;
		sprite.rotation = SpriterUtil.toRadians(spatialResult.angle);
		//sprite.offset = new Point(pivots.pivotX*sprite.width, pivots.pivotY*sprite.height);
		sprite.visible = true;
	}
	
	override public function render():Void
	{
		_layer.render();
	}
	
	
	
}