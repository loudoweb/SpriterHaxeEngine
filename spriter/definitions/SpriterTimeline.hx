package spriter.definitions;
import haxe.xml.Access;
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
	
	public function new(xml:Access) 
	{
		keys = new Array<TimelineKey>();
		
		id = Std.parseInt(xml.att.id);
		name = xml.has.name ? xml.att.name : "";
		objectType = xml.has.object_type ? Type.createEnum(ObjectType, xml.att.object_type.toUpperCase()) : ObjectType.SPRITE;
		
					
		for (k in xml.nodes.key)
		{
			keys.push(new TimelineKey(k, objectType));
		}
	}
	
}