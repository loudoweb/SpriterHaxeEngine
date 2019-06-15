package spriter.definitions;
import haxe.xml.Access;
import spriter.definitions.SpriterTimeline.ObjectType;
import spriter.definitions.TimelineKey.CurveType;
import spriter.engine.Spriter;
import spriter.util.MathUtils;

/**
 * ...
 * @author Loudo
 */
enum CurveType
{
	INSTANT;
	LINEAR;
	QUADRATIC;
	CUBIC;
	QUARTIC;
	QUINTIC;
	BEZIER;
}
 
class TimelineKey
{
	static var _cachedPivoInfo:PivotInfo = new PivotInfo();
	
	public var objectType:ObjectType; // enum : SPRITE,BONE,BOX,POINT,SOUND,ENTITY,VARIABLE
	
	public var id:Int;
	public var time:Int = 0;
    public var curveType:CurveType; // enum : INSTANT,LINEAR,QUADRATIC,CUBIC
    public var c1:Float; 
    public var c2:Float;
	public var c3:Float;
	public var c4:Float;
	
	//spatial
	public var info:SpatialInfo;
	
	//sprite
	public var sprite:SpriteInfo;
	
	//pivots
	public var pivots:PivotInfo;
	
	//sub entity
	public var subentity:SubEntityInfo;
	
	static public function createDefault():TimelineKey
	{
		var c:TimelineKey = new TimelineKey(null, SPRITE);
		c.info = new SpatialInfo();
		c.sprite = new SpriteInfo(0, 0);
		c.pivots = new PivotInfo();
		c.subentity = new SubEntityInfo(0, 0, 0);
		return c;
	}
	
	public function new(xml:Access, type:ObjectType) 
	{
		this.objectType = type;
		
		if (xml != null) {
			id = xml.has.id ? Std.parseInt(xml.att.id) : 0;
			time = xml.has.time ? Std.parseInt(xml.att.time) : 0;
			curveType = xml.has.curve_type ? Type.createEnum(CurveType, xml.att.curve_type.toUpperCase()) : CurveType.LINEAR;
			c1 = xml.has.c1 ? Std.parseFloat(xml.att.c1) : 0;
			c2 = xml.has.c2 ? Std.parseFloat(xml.att.c2) : 0;
			c3 = xml.has.c3 ? Std.parseFloat(xml.att.c3) : 0;
			c4 = xml.has.c4 ? Std.parseFloat(xml.att.c4) : 0;
			
			var child:Access;
			if (objectType != VARIABLE)
			{
				var spin = xml.has.spin ? Std.parseInt(xml.att.spin) : 1;
			
				if (xml.hasNode.object){
					child = xml.node.object;
				}else {
					child = xml.node.bone;
				}
				
				var x = child.has.x ? Std.parseFloat(child.att.x) : 0;
				var y = child.has.y ? Std.parseFloat(child.att.y) : 0;
				var angle = child.has.angle ? Std.parseFloat(child.att.angle) : 0;
				var scale_x = child.has.scale_x ? Std.parseFloat(child.att.scale_x) : 1;
				var scale_y = child.has.scale_y ? Std.parseFloat(child.att.scale_y) : 1;
				var alpha = child.has.a ? Std.parseFloat(child.att.a) : 1;
				
				info = new SpatialInfo(x, y, angle, scale_x, scale_y, alpha, spin);//we don't get from pool here because a macro use this constructor :/
			}else {
				return;
			}
			if (objectType != BONE)
			{
				pivots = new PivotInfo(
										child.has.pivot_x ? Std.parseFloat(child.att.pivot_x) : 0,
										child.has.pivot_y ? Std.parseFloat(child.att.pivot_y) : 1,
										(!child.has.pivot_x && !child.has.pivot_y)
									);
			}else {
				return;
			}
			if (objectType == SPRITE)
			{
				sprite = new SpriteInfo(Std.parseInt(child.att.folder), Std.parseInt(child.att.file));
			}
			if (objectType == ENTITY)
			{
				subentity = new SubEntityInfo(Std.parseInt(child.att.entity), Std.parseInt(child.att.animation), child.has.t ? Std.parseFloat(child.att.t) : 0);
			}
		}
	}
	/**
	 * Clone this to out.
	 * @param	clone
	 * @return
	 */
	public function clone(out:TimelineKey):Void
	{
		out.objectType = objectType;
		out.id = id;
		out.time = time;
		out.curveType = curveType;
		out.c1 = c1;
		out.c2 = c2;
		out.c3 = c3;
		out.c4 = c4;
		if (objectType != VARIABLE)
		{
			info.clone(out.info);
		}else {
			return;
		}
		if (objectType != BONE)
		{
			pivots.clone(out.pivots);
		}else {
			return;
		}
		if (objectType == SPRITE)
		{
			sprite.clone(out.sprite);
		}
		if (objectType == ENTITY)
		{
			subentity.clone(out.subentity);
		}
	}
	
	public function writeDefaultPivots(spriter:Spriter):Void
	{
		if (objectType == SPRITE)
		{
			if(pivots.useDefaultPivot)
			{
				spriter.writeDefaultPivots(pivots, sprite.folder, sprite.file);
			}
		}
	}
	
	inline public function interpolate(nextKey:TimelineKey, nextKeyTime:Int, currentTime:Float, spriter:Spriter):Void
    {
        linearKey(nextKey, getTWithNextKey(nextKeyTime, currentTime), spriter);
    }           

    function getTWithNextKey(nextKeyTime:Int, currentTime:Float):Float
    {
        if(curveType == INSTANT || time == nextKeyTime)
        {
            return 0;
        }
        
        var t:Float = (currentTime - time) / (nextKeyTime - time);

        if(curveType == LINEAR)
        {
            return t;        
        }
        else if(curveType == QUADRATIC)
        {
            return(MathUtils.quadratic(0.0,c1,1.0,t));
        }
        else if(curveType == CUBIC)
        {  
            return(MathUtils.cubic(0.0,c1,c2,1.0,t));
        }
		else if(curveType == QUARTIC)
        {  
            return(MathUtils.quartic(0.0,c1,c2,c3,1.0,t));
        }
		else if(curveType == QUINTIC)
        {  
            return(MathUtils.quintinc(0.0,c1,c2,c3,c4,1.0,t));
        }
		else if(curveType == BEZIER)
        {  
            return(MathUtils.cubicBezierAtTime(c1,c2,c3,c4,t));
        }
    
        return 0; // Runtime should never reach here        
    }	

	
	function linearKey(keyB:TimelineKey, t:Float, spriter:Spriter):Void
	{
		if (objectType != VARIABLE)
		{
			info.x = MathUtils.linear(info.x, keyB.info.x, t); 
			info.y = MathUtils.linear(info.y, keyB.info.y, t);  
			info.angle = MathUtils.angleLinear(info.angle, keyB.info.angle, info.spin, t); 
			info.scaleX = MathUtils.linear(info.scaleX, keyB.info.scaleX, t); 
			info.scaleY = MathUtils.linear(info.scaleY, keyB.info.scaleY, t); 
			info.a = MathUtils.linear(info.a, keyB.info.a, t);
		}else {
			return;
		}
		if (objectType != BONE)
		{
			if (objectType == SPRITE)
			{
				if(pivots.useDefaultPivot)
				{
					spriter.writeDefaultPivots(pivots, sprite.folder, sprite.file);
				}
				if (keyB.pivots.useDefaultPivot)
				{
					spriter.writeDefaultPivots(_cachedPivoInfo, keyB.sprite.folder, keyB.sprite.file);
					pivots.pivotX = MathUtils.linear(pivots.pivotX, _cachedPivoInfo.pivotX, t); 
					pivots.pivotY = MathUtils.linear(pivots.pivotY, _cachedPivoInfo.pivotY, t); 
				}else {
					pivots.pivotX = MathUtils.linear(pivots.pivotX, keyB.pivots.pivotX, t); 
					pivots.pivotY = MathUtils.linear(pivots.pivotY, keyB.pivots.pivotY, t); 
				}
			}else {
				pivots.pivotX = MathUtils.linear(pivots.pivotX, keyB.pivots.pivotX, t); 
				pivots.pivotY = MathUtils.linear(pivots.pivotY, keyB.pivots.pivotY, t); 
			}
		}else {
			return;
		}
		if (objectType == ENTITY)
		{
			subentity.t = MathUtils.linear(subentity.t, keyB.subentity.t, t);
		}
	}
}