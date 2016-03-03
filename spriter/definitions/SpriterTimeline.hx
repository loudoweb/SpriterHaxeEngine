package spriter.definitions;
import haxe.xml.Fast;
import spriter.definitions.SpriterTimeline.ObjectType;

/**
 * ...
 * @author Loudo
 */
enum ObjectType
{
	SPRITE;
	BONE;
	BOX;
	POINT;
	SOUND;
	ENTITY;
	VARIABLE;
}
 
class SpriterTimeline
{
	public var id:Int;
	public var name:String;
    public var objectType:ObjectType; // enum : SPRITE,BONE,BOX,POINT,SOUND,ENTITY,VARIABLE
    public var keys:Array<TimelineKey>;
	
	public function new(fast:Fast) 
	{
		keys = new Array<TimelineKey>();
		
		id = Std.parseInt(fast.att.id);
		name = fast.has.name ? fast.att.name : "";
		objectType = fast.has.object_type ? Type.createEnum(ObjectType, fast.att.object_type.toUpperCase()) : ObjectType.SPRITE;
		
					
		for (k in fast.nodes.key)
		{
			keys.push(new TimelineKey(k, objectType));
		}
	}
	
}