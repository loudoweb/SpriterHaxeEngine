package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
typedef ConstructibleKey = {
  public function new(fast:Fast):Void;
}
 
@:generic
class Metaline<T:ConstructibleKey>
{

	public var id:Int;
	public var name:String;
	public var keys:Array<T>;
	
	public function new(fast:Fast = null) 
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