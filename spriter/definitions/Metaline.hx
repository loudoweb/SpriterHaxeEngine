package spriter.definitions;
import spriter.xml.Access;

/**
 * ...
 * @author Loudo
 */

//Internal helpers
#if (haxe_ver < 3.3)
typedef ConstructibleKey = {
  public function new(xml:Access):Void;
}
#end
 
@:generic
#if (haxe_ver >= 3.3)
class Metaline<T:haxe.Constraints.Constructible<Access->Void>> {
#else
class Metaline<T:ConstructibleKey> {
#end

	public var id:Int;
	public var name:String;
	public var keys:Array<T>;
	
	public function new(xml:Access) 
	{
		if(xml != null){
			id = xml.has.def ? Std.parseInt(xml.att.def) : xml.has.id ? Std.parseInt(xml.att.id) : -1;
			if (xml.has.name)
				name = xml.att.name;
			keys = [];
			for (key in xml.nodes.key)
			{
				keys.push(new T(key));
			}
		}
	}
}