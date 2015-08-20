package spriter.definitions;

/**
 * ...
 * @author Loudo
 */
class PivotInfo
{
	public static var DEFAULT:PivotInfo = new PivotInfo();
	
	public var pivotX:Float; 
    public var pivotY:Float; 
	
	public function new(pivotX:Float = 0, pivotY:Float = 1) 
	{
		this.pivotX = pivotX;
		this.pivotY = pivotY;
	}
	
}