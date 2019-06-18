package spriter.definitions;
import spriter.xml.Access;

/**
 * ...
 * @author Loudo
 */
class CharacterMap
{
	public var id:Int;
	public var name:String;
    public var maps:Array<MapInstruction>;
	
	public function new(xml:Access) 
	{
		maps = new Array<MapInstruction>();
		
		id = Std.parseInt(xml.att.id);
		name = xml.att.name;
		
		for (m in xml.nodes.map)
		{
			maps.push(new MapInstruction(m));
		}
	}
	
}