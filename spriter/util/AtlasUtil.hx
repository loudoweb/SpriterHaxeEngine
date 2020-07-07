package spriter.util;
import aze.display.TilesheetEx;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

typedef SpriterJSON = {
  var name:String;
  var tags:Array<String>;
}
/**
 * Create TilesheetEx to make Spriter atlases compatible with Tilelayer.
 * TODO rotation
 * @author loudo (Ludovic Bas)
 * @deprecated since Tilemap feature in OpenFL >= 6.0
 */
class AtlasUtil
{

	public function new() 
	{
		
	}
	/**
	 * Allow to use the json file exported from Spriter.
	 * @return TilesheetEx to use with Tilelayer
	 */
	static public function getSpriterTilesheet(img:BitmapData, json:String, textureScale:Float = 1.0, useCenterPoint:Bool = true):TilesheetEx
	{
		var tilesheet:TilesheetEx = new TilesheetEx(img, textureScale);
		
		var ins = new Point(0, 0);
		
		var x = haxe.Json.parse(json);
		for (texture in Reflect.fields(x.frames))
		{
			var name = texture;
			var data = Reflect.field(x.frames, texture);
			var rect = if(!data.rotated)
					new Rectangle(
						data.frame.x, data.frame.y,
						data.frame.w, data.frame.h);
				else//rotated
					new Rectangle(
						data.frame.x, data.frame.y,
						data.frame.h, data.frame.w);
			
			var size = if (data.trimmed) // trimmed
					new Rectangle(
						-data.spriteSourceSize.x, -data.spriteSourceSize.y,
						data.sourceSize.w, data.sourceSize.h);
				else 
					new Rectangle(0, 0, rect.width, rect.height);
			
			//trace([name, rect.x, rect.y, rect.width, rect.height, size.x, size.y, size.width, size.height]);
			
			#if flash
			var bmp = new BitmapData(cast size.width, cast size.height, true, 0);
			ins.x = -size.left;
			ins.y = -size.top;
			bmp.copyPixels(img, rect, ins);
			tilesheet.addDefinition(name, size, bmp);
			#else
			var center = useCenterPoint ? new Point((size.x + size.width / 2), (size.y + size.height / 2)) : (data.trimmed ? new Point(size.x, size.y) : null);
			tilesheet.addDefinition(name, size, rect, center);
			#end
			x = null;
		}
		return tilesheet;
	}
	/**
	 * Custom Sparrow tilesheet xml have smaller tag and attributes name and use positive value for FrameX/FrameY.
	 * In TexturePacker preferences, set texturePackerExporter folder as your custom exporter directory or copy spriterhaxeengine folder to your custom exporter directory.
	 * @example <Sub name="test.png" x="2" y="2708" w="99" h="194"  frameX="103" frameY="24" frameW="298" frameH="288"/>
	 * @return TilesheetEx to use with Tilelayer
	 */
	static public function getCustomSparrowTilesheet(img:BitmapData, xml:String, textureScale:Float = 1.0, useCenterPoint:Bool = true):TilesheetEx
	{
		var tilesheet:TilesheetEx = new TilesheetEx(img, textureScale);
		
		var ins = new Point(0, 0);
		var x = new spriter.xml.Access( Xml.parse(xml).firstElement() );

		for (texture in x.nodes.Sub)
		{
			var name = texture.att.name;
			var rect = new Rectangle(
				Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y),
				Std.parseFloat(texture.att.w), Std.parseFloat(texture.att.h));
			
			var size = if (texture.has.frameX) // trimmed
					new Rectangle(
						-Std.parseInt(texture.att.frameX), -Std.parseInt(texture.att.frameY),
						Std.parseInt(texture.att.frameW), Std.parseInt(texture.att.frameH));
				else 
					new Rectangle(0, 0, rect.width, rect.height);
			
			#if flash
			var bmp = new BitmapData(cast size.width, cast size.height, true, 0);
			ins.x = -size.left;
			ins.y = -size.top;
			bmp.copyPixels(img, rect, ins);
			tilesheet.addDefinition(name, size, bmp);
			#else
			var center = useCenterPoint ? new Point((size.x + size.width / 2), (size.y + size.height / 2)) : (texture.has.frameX ? new Point(size.x, size.y) : null);
			tilesheet.addDefinition(name, size, rect, center);
			#end
			x = null;
		}
		return tilesheet;
	}
	
}