package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class BoneTimelineKey extends SpatialTimelineKey
{
	// unimplemented in Spriter
    public var length:Int;
    public var width:Int;
	public var paintDebugBones:Bool;
	
	public function new(fast:Fast=null) 
	{
		paintDebugBones = true;
		
		if(fast != null){
			length = fast.has.length ? Std.parseInt(fast.att.length) : 200;
			width = fast.has.width ? Std.parseInt(fast.att.width) : 10;
		}
		
		super(fast);
	}
	
	override public function copy ():TimelineKey
	{
		var	copy:TimelineKey = new BoneTimelineKey();
		return clone (copy);
	}

	override public function clone (clone:TimelineKey):TimelineKey
	{
		super.clone(clone);
		
		var	c:BoneTimelineKey = cast clone;
		
		c.length = length;
		c.width = width;
		c.paintDebugBones = paintDebugBones;
		
		return c;
	}
	
	override public function paint(defaultPivots:PivotInfo):PivotInfo
    {
        if(paintDebugBones)
        {
            var drawLength:Float = length * info.scaleX;
           //var drawHeight:Float = info.height*info.scaleY;
            var drawHeight:Float = width * info.scaleY;
            // paint debug bone representation 
            // e.g. line starting at x,y,at angle, 
            // of length drawLength, and height drawHeight
			
         }
		 return defaultPivots;
    }           

    override public function linearKey(keyB:TimelineKey,t:Float):Void
    {
		if (!Std.is(keyB, BoneTimelineKey))
			throw "keyB must be BoneTimelineKeys";
			
        var keyBBone:BoneTimelineKey = cast(keyB, BoneTimelineKey);
        linearSpatialInfo(info, keyBBone.info, info.spin, t);

        if(paintDebugBones)
        {
            length	= Std.int(linear(length,keyBBone.length,t));
            width	= Std.int(linear(width, keyBBone.width, t));
        }
    }
}