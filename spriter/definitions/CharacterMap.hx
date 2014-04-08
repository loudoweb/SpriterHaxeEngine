package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class CharacterMap
{
	public var id:Int;
	public var name:String;
    public var maps:Array<MapInstruction>;
	
	public function new(fast:Fast) 
	{
		maps = new Array<MapInstruction>();
		
		id = Std.parseInt(fast.att.id);
		name = fast.att.name;
		
		for (m in fast.nodes.map)
		{
			maps.push(new MapInstruction(m));
		}
	}
	
}