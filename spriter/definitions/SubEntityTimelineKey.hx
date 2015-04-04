package spriter.definitions;

import haxe.xml.Fast;
import spriter.definitions.SpriterTimeline.ObjectType;

/**
 * SubEntityTimelineKey
 * @author Loudo
 */
class SubEntityTimelineKey extends ObjectTimelineKey 
{
	public var entity:Int; // id of the sub entity
    public var animation:Int; //id of the animation
    public var t:Float; //ratio of the time within the animation.  So t*animationLength=current time in animation.
	
	public function new(fast:Fast = null) 
	{
		super(fast, ObjectType.ENTITY);
		
		if(fast != null){
		
			fast = fast.node.object;
			
			entity = fast.has.entity ? Std.parseInt(fast.att.entity) : 0;
			animation = fast.has.animation ? Std.parseInt(fast.att.animation) : 0;
			t = fast.has.t ? Std.parseFloat(fast.att.t) : 0;
		}
	}
	
	override public function copy ():TimelineKey
	{
		var	copy:TimelineKey = new SubEntityTimelineKey();
		return clone (copy);
	}

	override public function clone (clone:TimelineKey):TimelineKey
	{
		super.clone(clone);

		var	c:SubEntityTimelineKey = cast clone;
		
		c.entity = entity;
		c.animation = animation;
		c.t = t;
		c.useDefaultPivot = useDefaultPivot;
		c.pivot_x = pivot_x;
		c.pivot_y = pivot_y;
		return c;
	}
	
}