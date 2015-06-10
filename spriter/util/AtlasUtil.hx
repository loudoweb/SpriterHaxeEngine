package spriter.util;
import aze.display.TilesheetEx;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

typedef SpriterJSON = {
  var name:String;
  var tags:Array<String>;
}
/**
 * ...
 * TODO rotation
 * @author loudo (Ludovic Bas)
 */
class AtlasUtil
{

	public function new() 
	{
		
	}
	/**
	 * 
	 * @return
	 */
	static public function getSpriterTilesheet(img:BitmapData, json:String, textureScale:Float = 1.0):TilesheetEx
	{
		var tilesheet:TilesheetEx = new TilesheetEx(img, textureScale);
		
		var ins = new Point(0, 0);
		var matrix = new Matrix();
		
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
			var center = new Point((size.x + size.width / 2), (size.y + size.height / 2));
			tilesheet.addDefinition(name, size, rect, center);
			#end
		}
		return tilesheet;
	}
	
}