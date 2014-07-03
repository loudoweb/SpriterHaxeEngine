package spriter.definitions;
import haxe.xml.Fast;
import spriter.interfaces.IScml;

/**
 * ...
 * @author Loudo
 */
class SpriterEntity
{

    public var id:Int;
	public var name:String;
    public var characterMaps:Map<String,CharacterMap>;
    public var animations:Map<String,SpriterAnimation>;

	
	public function new(fast:Fast) 
	{
		characterMaps = new Map<String,CharacterMap>();
		animations = new Map<String,SpriterAnimation>();
		
		id = Std.parseInt(fast.att.id);
		name = fast.att.name;
		
		for (cm in fast.nodes.character_map)
		{
			characterMaps.set(cm.att.name, new CharacterMap(cm));
		}
		
		for (a in fast.nodes.animation)
		{
			animations.set(a.att.name,new SpriterAnimation(a));
		}
	}
}