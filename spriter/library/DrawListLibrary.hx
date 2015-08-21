package spriter.library;
import aze.display.TilesheetEx;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;
import spriter.util.SpriterUtil;

/**
 * This class is a modified version of Tilelayer allowing to use many Tilesheet in one single view with Spriter.
 * Automatic merge of DrawLists that use the same tilesheet.
 * It will merge only if applicable (no merge between background and foreground if there is something between using an other tilesheet).
 * Beware of not making too much drawCalls, try to organize your atlas in the best way you can...
 * Not working with flash.
 * @author loudo (Ludovic Bas)
 * It uses some code of TileLayer by @author Philippe / http://philippe.elsass.me
 * @example var tile1:SparrowTilesheet = new SparrowTilesheet(atlas1, atlasText1);
			var tile2:SparrowTilesheet = new SparrowTilesheet(atlas2, atlasText2);
			var lib:DrawListLibrary = new DrawListLibrary([tile1, tile2], this);
			var engine = new SpriterEngine(Assets.getText('assets/test.scml'), lib, null );
 */
class DrawListLibrary extends AbstractLibrary
{
	public var view:Sprite;
	public var useSmoothing:Bool;
	public var useAdditive:Bool;
	public var useAlpha:Bool;
	public var useTransforms:Bool;
	public var useTint:Bool;

	var layerDrawingList:Array<DrawList>;
	var tilesheetLibrary:Array<TilesheetEx>;
	var lastTilesheetUsed:Int = -1;
	var currentDrawListIndex:Int = 0;
	var currentDrawList:DrawList;
	#if mobile
	public var maxDrawCalls:Int = 30;
	#else
	public var maxDrawCalls:Int = 42;
	#end
	/**
	 * 
	 * @param	tilesheets Find this class in Tilelayer on haxelib (https://github.com/elsassph/openfl-tilelayer)
	 * @param	view the single canvas you want to draw into
	 * @param	smooth
	 * @param	additive
	 */
	public function new(tilesheets:Array<TilesheetEx>, view:Sprite, smooth:Bool=true, additive:Bool=false) 
	{
		super("");

		this.view = view;
		this.view.mouseEnabled = false;
		this.view.mouseChildren = false;

		useSmoothing = smooth;
		useAdditive = additive;
		useAlpha = true;
		useTransforms = true;

		layerDrawingList = [];
		tilesheetLibrary = tilesheets;
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
		#if !flash
		view.graphics.clear();
		#end
		lastTilesheetUsed = -1;
		currentDrawListIndex = 0;
		for (drawList in layerDrawingList)
		{
			drawList.destroy();
		}
		layerDrawingList.splice(0, layerDrawingList.length); // compact buffer
	}
	/**
	 * Call render() every frame to render the graphic
	 */
	override public function render():Void
	{
		#if debugDrawCalls
		trace('${layerDrawingList.length} of $maxDrawCalls drawCalls');
		#end
		#if !flash
		if (layerDrawingList.length > maxDrawCalls) {
			throw ("max DrawCalls of "+ maxDrawCalls + "reached");
		}
		
		for (drawList in layerDrawingList)
		{
			tilesheetLibrary[drawList.tilesheet].drawTiles(view.graphics, drawList.list, useSmoothing, drawList.flags);
		}
		#elseif debugDrawCalls
		trace("can't render on flash target");
		#end
	}
	
	override public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		//get file indice and size
		var imageIndices:Array<Int>;
		var size:Rectangle = new Rectangle(0, 0, 0, 0);
		/**
		 * Index of the image in the atlas
		 */
		var imageIndex:Int = -1;
		/**
		 * Index of the tilesheet in the library
		 */
		var tilesheetIndex:Int = 0;
		for (sheet in tilesheetLibrary)
		{
			imageIndices = sheet.getAnim(name);//TODO should we store from which sheets the tile comes from?
			if (imageIndices.length > 0) {
				imageIndex = imageIndices[0];
				size = sheet.getSize(imageIndex);
				break;
			}
			tilesheetIndex++;
		}
		if (imageIndex == -1)
			return;
		info = compute(info, pivots, size.width, size.height);
		//if (info.a == 0) return;
		
		if (tilesheetIndex != lastTilesheetUsed) {
			currentDrawListIndex = 0;
			currentDrawList = new DrawList();
			currentDrawList.tilesheet = tilesheetIndex;
			currentDrawList.begin(true, true, false, false);
			lastTilesheetUsed = tilesheetIndex;
			addDrawList(currentDrawList);
		}else {
			currentDrawList = layerDrawingList[layerDrawingList.length - 1];
		}
		
		
		var list = currentDrawList.list;
		var fields = currentDrawList.fields;
		var offsetTransform = currentDrawList.offsetTransform;
		var offsetRGB = currentDrawList.offsetRGB;
		var offsetAlpha = currentDrawList.offsetAlpha;

		list[currentDrawListIndex+2] = imageIndex;
		list[currentDrawListIndex] = info.x;
		list[currentDrawListIndex + 1] = info.y;
		
		if (offsetTransform > 0) {
			var rotation:Float = SpriterUtil.toRadians(SpriterUtil.fixRotation(info.angle));
			if (rotation != 0) {
				var cos = Math.cos(rotation);
				var sin = Math.sin(rotation);
				list[currentDrawListIndex+offsetTransform] = cos * info.scaleX;
				list[currentDrawListIndex+offsetTransform+1] = sin * info.scaleX;
				list[currentDrawListIndex+offsetTransform+2] = -1 * sin * info.scaleY;
				list[currentDrawListIndex + offsetTransform + 3] = cos * info.scaleY;
			}
			else {
				list[currentDrawListIndex+offsetTransform] = info.scaleX;
				list[currentDrawListIndex+offsetTransform+1] = 0;
				list[currentDrawListIndex+offsetTransform+2] = 0;
				list[currentDrawListIndex+offsetTransform+3] = info.scaleY;
			}
		}
		/*if (offsetRGB > 0) {
			list[currentDrawListIndex+offsetRGB] = sprite.r;
			list[currentDrawListIndex+offsetRGB+1] = sprite.g;
			list[currentDrawListIndex+offsetRGB+2] = sprite.b;
		}*/
		if (offsetAlpha > 0) list[currentDrawListIndex+offsetAlpha] = info.a;
		
		currentDrawListIndex += fields;
		currentDrawList.index = currentDrawListIndex;
		info = null;
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
		
		return info.init(x2, -y2, degreesUnder360, info.scaleX, info.scaleY, info.a, info.spin);
	}
	
	override public function destroy():Void 
	{
		clear();
		view = null;
		layerDrawingList = null;
		tilesheetLibrary = null;//TODO proper destroy function for tilesheet?
		if (currentDrawList != null)
		{
			currentDrawList.destroy();
			currentDrawList = null;
		}
	}
	
	public function addDrawList(list:DrawList):Void
	{
		layerDrawingList.push(list);
	}
}
/**
 * Modified DrawList from Tilelayer which allows to compare the current tilesheet used.
 * TODO pool
 * @author loudo (Ludovic Bas)
 * @author forked from TileLayer by Philippe / http://philippe.elsass.me
 */
class DrawList
{
	/**
	 * Tilesheet index
	 */
	public var tilesheet:Int;
	public var list:Array<Float>;
	public var index:Int;
	public var fields:Int;
	public var offsetTransform:Int;
	public var offsetRGB:Int;
	public var offsetAlpha:Int;
	public var flags:Int;
	public var runs:Int;

	
	public function new() 
	{
		list = new Array<Float>();
		runs = 0;
		index = 0;
	}
	
	public function begin(useTransforms:Bool, useAlpha:Bool, useTint:Bool, useAdditive:Bool) 
	{
		#if !flash
		flags = 0;
		fields = 3;
		if (useTransforms) {
			offsetTransform = fields;
			fields += 4;
			flags |= Graphics.TILE_TRANS_2x2;
		}
		else offsetTransform = 0;
		if (useTint) {
			offsetRGB = fields; 
			fields+=3; 
			flags |= Graphics.TILE_RGB;
		}
		else offsetRGB = 0;
		if (useAlpha) {
			offsetAlpha = fields; 
			fields++; 
			flags |= Graphics.TILE_ALPHA;
		}
		else offsetAlpha = 0;
		if (useAdditive) flags |= Graphics.TILE_BLEND_ADD;
		#end
	}

	public function end()
	{
		if (list.length > index) 
		{
			if (++runs > 60) 
			{
				list.splice(index, list.length - index); // compact buffer
				runs = 0;
			}
			else
			{
				while (index < list.length)
				{
					list[index + 2] = -2.0; // set invalid ID
					index += fields;
				}
			}
		}
	}
	public function destroy():Void
	{
		runs = 0;
		index = 0;
		list.splice(index, list.length); // compact buffer
	}
	
}