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
    public var characterMaps:Array<CharacterMap>;
    public var animations:Array<SpriterAnimation>;

	
	public function new(fast:Fast, spatialInfo:IScml) 
	{
		characterMaps = new Array<CharacterMap>();
		animations = new Array<SpriterAnimation>();
		
		id = Std.parseInt(fast.att.id);
		name = fast.att.name;
		
		for (cm in fast.nodes.character_map)
		{
			characterMaps.push(new CharacterMap(cm));
		}
		
		for (a in fast.nodes.animation)
		{
			animations.push(new SpriterAnimation(a,spatialInfo));
		}
	}
	
}