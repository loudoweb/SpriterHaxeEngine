package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class SpriteTimelineKey extends ObjectTimelineKey
{
	public var folder:Int; // index of the folder within the ScmlObject
    public var file:Int;  
	
	public function new(fast:Fast = null) 
	{
		super(fast);
		
		if(fast != null){
		
			fast = fast.node.object;
			
			folder = fast.has.folder ? Std.parseInt(fast.att.folder) : 0;
			file = fast.has.file ? Std.parseInt(fast.att.file) : 0;
		}
	}
	
	override public function copy ():TimelineKey
	{
		var	copy:TimelineKey = new SpriteTimelineKey();
		return clone (copy);
	}

	override public function clone (clone:TimelineKey):TimelineKey
	{
		super.clone(clone);

		var	c:SpriteTimelineKey = cast clone;
		
		c.folder = folder;
		c.file = file;
		c.useDefaultPivot = useDefaultPivot;
		c.pivot_x = pivot_x;
		c.pivot_y = pivot_y;
		return c;
	}
}