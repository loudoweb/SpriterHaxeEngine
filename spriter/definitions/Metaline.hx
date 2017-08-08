package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */

//Internal helpers
#if (haxe_ver < 3.3)
typedef ConstructibleKey = {
  public function new(fast:Fast):Void;
}
#end
 
@:generic
#if (haxe_ver >= 3.3)
class Metaline<T:haxe.Constraints.Constructible<Fast->Void>> {
#else
class Metaline<T:ConstructibleKey> {
#end

	public var id:Int;
	public var name:String;
	public var keys:Array<T>;
	
	public function new(fast:Fast) 
	{
		if(fast != null){
			id = fast.has.def ? Std.parseInt(fast.att.def) : fast.has.id ? Std.parseInt(fast.att.id) : -1;
			if (fast.has.name)
				name = fast.att.name;
			keys = [];
			for (key in fast.nodes.key)
			{
				keys.push(new T(key));
			}
		}
	}
}