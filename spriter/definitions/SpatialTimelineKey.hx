package spriter.definitions;
import haxe.xml.Fast;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author Loudo
 */
class SpatialTimelineKey extends TimelineKey
{
	public var info:SpatialInfo;

	
	public function new(fast:Fast = null) 
	{
		super(fast);
		
		if(fast != null){
			var spin = fast.has.spin ? Std.parseInt(fast.att.spin) : 1;
			
			if (fast.hasNode.object){
				fast = fast.node.object;
			}else {
				fast = fast.node.bone;
			}
			
			var x = fast.has.x ? Std.parseFloat(fast.att.x) : 0;
			var y = fast.has.y ? Std.parseFloat(fast.att.y) : 0;
			var angle = fast.has.angle ? Std.parseFloat(fast.att.angle) : 0;
			var scale_x = fast.has.scale_x ? Std.parseFloat(fast.att.scale_x) : 1;
			var scale_y = fast.has.scale_y ? Std.parseFloat(fast.att.scale_y) : 1;
			var alpha = fast.has.a ? Std.parseFloat(fast.att.a) : 1;
			
			info = new SpatialInfo(x, y, angle, scale_x, scale_y, alpha, spin);//we don't get from pool here because a macro use this constructor :/
		}
	}
	
	override public function copy():TimelineKey
	{
		var	copy:TimelineKey = new SpatialTimelineKey();
		return clone (copy);
	}

	override public function clone(clone:TimelineKey):TimelineKey
	{
		super.clone(clone);//TODO instead of cloning we should only manipulate SpatialInfo from linearSpatialInfo();

		var	c:SpatialTimelineKey = cast clone;
		c.info = info.copy();
		return c;
	}
	
	/**
	 * SCML Ref : function written in SpatialInfo
	 * @param	infoA
	 * @param	infoB
	 * @param	spin
	 * @param	t
	 * @return
	 */
	public function linearSpatialInfo(infoA:SpatialInfo, infoB:SpatialInfo, spin:Int, t:Float):Void
	{
		info.x = linear (infoA.x, infoB.x, t); 
		info.y = linear (infoA.y, infoB.y, t);  
		info.angle = angleLinear (infoA.angle, infoB.angle, spin, t); 
		info.scaleX = linear (infoA.scaleX, infoB.scaleX, t); 
		info.scaleY = linear (infoA.scaleY, infoB.scaleY, t); 
		info.a = linear (infoA.a, infoB.a, t);
	}
	
	public function paint(defaultPivots:PivotInfo):PivotInfo
	{
		return defaultPivots;
	}
	public function destroy():Void
	{
		//info.put();//add too pool
		info = null;
	}
	
}