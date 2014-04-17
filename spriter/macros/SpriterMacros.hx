package spriter.macros;
import haxe.macro.Expr;

/**
 * ...
 * @author Loudo
 */
class SpriterMacros
{
	/**
	 * Check texture packer atlas to add .png at the end of files.
	 * Because Spriter's SCML use file name with .png at the end and Texture Packer not.
	 * So it will correct this for you.
	 * Data format : Sparrow, Starling only
	 * @param	pathToXml
	 * @return  pathToXml
	 */
	macro public static function texturePackerChecker(pathToXml:Expr) : Expr 
	{
		var xml_loc:String = '';
		switch(pathToXml.expr){
			case EConst(c): switch(c){
				case CString(s): xml_loc = s; 
				default:{}
			}
			default:{}
		}
		trace('checking texture packer file : '+xml_loc);
		var xml_s = sys.io.File.getContent(xml_loc);
		var xml = Xml.parse(xml_s);
		var save:Bool = parseTexturePacker(xml.firstElement());
		if(save)
			sys.io.File.saveContent(xml_loc, xml.toString());
		
		return pathToXml;
	}
	static function parseTexturePacker(xml:Xml):Bool
	{
		var path:String;
		var corrected:Bool = false;
		for (el in xml.elements())
		{
			if (el.nodeName == 'SubTexture') {
				path = el.get('name');
				if (path.indexOf('.png') == -1) {
					el.set('name', path + '.png');
					corrected = true;
				}else {
					trace('texturePacker XML is ok. No change.');
					break;
				}
			}else {
				trace('texturePacker XML not supported.');
				break;
			}
		}
		if (corrected)
			trace('texturePacker XML is corrected.');
		return corrected;
	}
}