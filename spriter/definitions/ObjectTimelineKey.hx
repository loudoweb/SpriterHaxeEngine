package spriter.definitions;
import haxe.xml.Fast;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author Loudo
 */
class ObjectTimelineKey extends SpatialTimelineKey
{
    public var useDefaultPivot:Bool; // true if missing pivot_x and pivot_y in object tag
    public var pivot_x:Float;
    public var pivot_y:Float;
	
	public function new(fast:Fast = null) 
	{
		super(fast);
		
		if(fast != null){
		
			fast = fast.node.object;
			
			useDefaultPivot = (!fast.has.pivot_x && !fast.has.pivot_y);
			pivot_x = fast.has.pivot_x ? Std.parseFloat(fast.att.pivot_x) : 0;
			pivot_y = fast.has.pivot_y ? Std.parseFloat(fast.att.pivot_y) : 1;
		
		}
	}
	
	override public function copy ():TimelineKey
	{
		var	copy:TimelineKey = new ObjectTimelineKey();
		return clone (copy);
	}

	override public function clone (clone:TimelineKey):TimelineKey
	{
		super.clone(clone);

		var	c:ObjectTimelineKey = cast clone;
		
		c.useDefaultPivot = useDefaultPivot;
		c.pivot_x = pivot_x;
		c.pivot_y = pivot_y;
		return c;
	}
	
	override public function paint(pivotX:Float, pivotY:Float):PivotInfo
    {
        var paintPivotX:Float;
        var paintPivotY:Float;
        if(useDefaultPivot)
        {
            paintPivotX = pivotX;
            paintPivotY = pivotY;
        }
        else
        {
            paintPivotX = pivot_x;
            paintPivotY = pivot_y;
        }
		
		return new PivotInfo(paintPivotX , paintPivotY);
    }

    override public function linearKey(keyB:TimelineKey, t:Float):Void
    // keyB must be ObjectTimelineKey
    {
		if (!Std.is(keyB, ObjectTimelineKey))
			throw "keyB must be ObjectTimelineKey";
			
        var keyBSprite:ObjectTimelineKey = cast(keyB, ObjectTimelineKey);
		
        linearSpatialInfo(info, keyBSprite.info, info.spin, t);

         if(!useDefaultPivot)
        {
            pivot_x = linear(pivot_x,keyBSprite.pivot_x,t);
            pivot_y = linear(pivot_y,keyBSprite.pivot_y,t);
        }
    }
}