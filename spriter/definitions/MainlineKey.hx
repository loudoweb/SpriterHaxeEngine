package spriter.definitions;
import haxe.xml.Fast;
import spriter.engine.SpriterEngineParam;

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
		/*sort objects by z_index
		 *On Spriter, when you change the z-index of an object, it will change the xml tag position and the id
		 *so z_index wasn't even used on SpriterHaxeEngine, it was the objet order that determined the z order
		 *If you have some external tool and change only the z_index attribute, it should works now...
		 * The following sorting is used only on demand because it extends the parse time.
		 **/
		if(SpriterEngineParam.NEED_ZORDER_REORDERING)
			objectRefs.sort(zOrdering);
	}
	private function zOrdering(ref1:Ref, ref2:Ref):Int
	{
		if (ref1.z_index < ref2.z_index)
			return -1;
		return 1;
		
	}
	
}