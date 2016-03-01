package spriter.definitions;

/**
 * SubEntityTimelineKey
 * @author Loudo
 */
class SubEntityInfo
{
	public var entity:Int; // id of the sub entity
    public var animation:Int; //id of the animation
    public var t:Float; //ratio of the time within the animation.  So t*animationLength=current time in animation.
	
	inline public function new(entity:Int, animation:Int, t:Float) 
	{
		this.entity = entity;
		this.animation = animation;
		this.t = t;
	}
	
	/**
	 * Clone this to out.
	 * @param	out
	 * @return
	 */
	inline public function clone(out:SubEntityInfo):SubEntityInfo
	{
		out.entity = entity;
		out.animation = animation;
		out.t = t;
		return out;
	}
}