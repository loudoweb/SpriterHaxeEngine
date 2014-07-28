package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class Varline
{

	/**
	 * id of variable. Attribut def in scml.
	 */
	public var id:Int;
	public var keys:Array<VarlineKey>;
	
	public function new(fast:Fast = null) 
	{
		if(fast != null){
			id = Std.parseInt(fast.att.def);
			keys = [];
			for (key in fast.nodes.key)
			{
				keys.push(new VarlineKey(key));
			}
		}
	}
}