package spriter.library;
import aze.display.TilesheetEx;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;
import spriter.library.DrawListLibrary.DrawList;
import spriter.util.SpriterUtil;
import spriter.interfaces.ISpriterPooled;
import spriter.util.SpriterPool;

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

	var layerDrawingList:Array<DrawList>;//all your drawList (one drawCall per drawList)
	var tilesheetLibrary:Array<TilesheetEx>;//all your tilesheet
	//var tilesheetCache:Map<String, Int>;//cache all your assets to find quickly which tilesheet to use
	var lastTilesheetUsed:Int = -1;//allow to set your data in the current drawList if it uses the same tilesheet
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
	public function new(tilesheets:Array<TilesheetEx>, view:Sprite, smooth:Bool=true, tint:Bool = false, additive:Bool=false) 
	{
		super("");

		this.view = view;
		this.view.mouseEnabled = false;
		this.view.mouseChildren = false;

		useSmoothing = smooth;
		useAdditive = additive;
		useAlpha = true;
		useTransforms = true;
		useTint = tint;

		layerDrawingList = [];
		//tilesheetCache = new Map<String, Int>();
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
			drawList.put();
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
		var size:Rectangle = null;
		/**
		 * Index of the image in the atlas
		 */
		var imageIndex:Int = -1;
		/**
		 * Index of the tilesheet in the library
		 */
		var tilesheetIndex:Int = 0;
		/*if (tilesheetCache.exists(name)) 
		{
			tilesheetIndex = tilesheetCache.get(name);
			var sheet = tilesheetLibrary[tilesheetIndex];
			imageIndex = sheet.getIndex(name);
			size = sheet.getSize(imageIndex);
		}else {*/
			for (sheet in tilesheetLibrary)
			{
				imageIndex = sheet.getIndex(name);//TODO should we store from which sheets the tile comes from?
				if (imageIndex != -1) {
					size = sheet.getSize(imageIndex);
					break;
				}
				tilesheetIndex++;
			}
			/*tilesheetCache.set(name, tilesheetIndex);
		}*/
		
		
		if (imageIndex == -1 || info.a == 0)//if image not finded or not visible, exit method
			return;
			
		info = compute(info, pivots, size.width, size.height);
		
		if (tilesheetIndex != lastTilesheetUsed) {
			currentDrawListIndex = 0;
			currentDrawList = DrawList.get();
			currentDrawList.tilesheet = tilesheetIndex;
			currentDrawList.begin(true, true, useTint, useAdditive);
			lastTilesheetUsed = tilesheetIndex;
			addDrawList(currentDrawList);
		}else {
			currentDrawList = layerDrawingList[layerDrawingList.length - 1];
		}
		
		
		
		var offsetTransform = currentDrawList.offsetTransform;
		var offsetAlpha = currentDrawList.offsetAlpha;

		currentDrawList.list[currentDrawListIndex+2] = imageIndex;
		currentDrawList.list[currentDrawListIndex] = info.x;
		currentDrawList.list[currentDrawListIndex + 1] = info.y;
		
		if (offsetTransform > 0) {
			var rotation:Float = SpriterUtil.toRadians(SpriterUtil.fixRotation(info.angle));
			if (rotation != 0) {
				var cos = Math.cos(rotation);
				var sin = Math.sin(rotation);
				currentDrawList.list[currentDrawListIndex+offsetTransform] = cos * info.scaleX;
				currentDrawList.list[currentDrawListIndex+offsetTransform+1] = sin * info.scaleX;
				currentDrawList.list[currentDrawListIndex+offsetTransform+2] = -1 * sin * info.scaleY;
				currentDrawList.list[currentDrawListIndex + offsetTransform + 3] = cos * info.scaleY;
			}
			else {
				currentDrawList.list[currentDrawListIndex+offsetTransform] = info.scaleX;
				currentDrawList.list[currentDrawListIndex+offsetTransform+1] = 0;
				currentDrawList.list[currentDrawListIndex+offsetTransform+2] = 0;
				currentDrawList.list[currentDrawListIndex+offsetTransform+3] = info.scaleY;
			}
		}
		/*
		var offsetRGB = currentDrawList.offsetRGB;
		if (offsetRGB > 0) {//TODO add tint
			currentDrawList.list[currentDrawListIndex+offsetRGB] = info.r;
			currentDrawList.list[currentDrawListIndex+offsetRGB+1] = info.g;
			currentDrawList.list[currentDrawListIndex+offsetRGB+2] = info.b;
		}
		*/
		if (offsetAlpha > 0) currentDrawList.list[currentDrawListIndex+offsetAlpha] = info.a;
		
		currentDrawListIndex += currentDrawList.fields;
		currentDrawList.index = currentDrawListIndex;
		info = null;
		pivots = null;
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
		currentDrawList = null;
	}
	
	inline public function addDrawList(list:DrawList):Void
	{
		layerDrawingList.push(list);
	}
}
/**
 * Modified DrawList from Tilelayer which allows to compare the current tilesheet used.
 * @author loudo (Ludovic Bas)
 * @author forked from TileLayer by Philippe / http://philippe.elsass.me
 */
class DrawList implements ISpriterPooled 
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
	
	private static var _pool = new SpriterPool<DrawList>(DrawList);
	private var _inPool:Bool = false;

	
	public function new() 
	{
		list = new Array<Float>();
	}
	
	/**
	 * Recycle or create a new SpatialInfo. 
	 * Be sure to put() them back into the pool after you're done with them!
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @return	This point.
	 */
	public static inline function get():DrawList
	{
		var pooledInfo = _pool.get();
		pooledInfo._inPool = false;
		return pooledInfo;
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
	public function destroy():Void
	{
		index = 0;
		list.splice(index, list.length); // compact buffer
	}
	/**
	 * Add this SpatialInfo to the recycling pool.
	 */
	public function put():Void
	{
		if (!_inPool)
		{
			_inPool = true;
			_pool.putUnsafe(this);
		}
	}
	
}
