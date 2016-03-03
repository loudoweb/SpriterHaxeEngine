package spriter.definitions;

/**
 * ...
 * @author Loudo
 */
class PivotInfo
{	
	public var pivotX:Float; 
    public var pivotY:Float; 
	public var useDefaultPivot:Bool;
	
	inline public function new(pivotX:Float = 0, pivotY:Float = 1, useDefault:Bool = true) 
	{
		this.pivotX = pivotX;
		this.pivotY = pivotY;
		this.useDefaultPivot = useDefault;
	}
	inline public function setToDefault():Void
	{
		this.pivotX = 0;
		this.pivotY = 1;
		this.useDefaultPivot = true;
	}
	/**
	 * Clone this to out.
	 * @param	out
	 * @return
	 */
	inline public function clone(out:PivotInfo):PivotInfo
	{
		out.pivotX = pivotX;
		out.pivotY = pivotY;
		out.useDefaultPivot = useDefaultPivot;
		return out;
	}
	
}