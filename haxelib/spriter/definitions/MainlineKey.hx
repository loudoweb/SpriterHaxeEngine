package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class MainlineKey
{
	public var id:Int;
	public var time:Int;
    public var boneRefs:Array<Ref>; // <bone_ref> tags
    public var objectRefs:Array<Ref>; // <object_ref> tags 
	
	public function new(fast:Fast) 
	{
		boneRefs = new Array<Ref>();
		objectRefs = new Array<Ref>();
		
		id = Std.parseInt(fast.att.id);
		time = fast.has.time ? Std.parseInt(fast.att.time) : 0;
		
		for (br in fast.nodes.bone_ref)
		{
			boneRefs.push(new Ref(br));
		}
		
		for (or in fast.nodes.object_ref)
		{
			objectRefs.push(new Ref(or));
		}
	}
	
}