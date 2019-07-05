package spriter.definitions;
import spriter.xml.Access;
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
	
	public function new(xml:Access) 
	{
		boneRefs = new Array<Ref>();
		objectRefs = new Array<Ref>();
		
		id = Std.parseInt(xml.att.id);
		time = xml.has.time ? Std.parseInt(xml.att.time) : 0;
		
		for (br in xml.nodes.bone_ref)
		{
			boneRefs.push(new Ref(br));
		}
		
		for (or in xml.nodes.object_ref)
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