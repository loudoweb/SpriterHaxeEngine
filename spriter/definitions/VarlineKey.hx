package spriter.definitions;
import haxe.xml.Access;

/**
 * ...
 * @author Loudo
 */
class VarlineKey extends TimelineKey
{
	public var value:String;
	public function new(xml:Access) 
	{
		if(xml != null){
			value = xml.att.val;
		}
		super(xml, VARIABLE);
	}
}