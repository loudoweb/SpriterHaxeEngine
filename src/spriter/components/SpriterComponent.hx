package spriter.components;
import spriter.engine.Spriter;

/**
 * ...
 * @author Loudo
 */
class SpriterComponent
{

	public var spriter:Spriter;
	public var beginTime:Int;
	public var zOrder:Int;//TODO

	public function new(spriter:Spriter, beginTime:Int)
	{
		this.spriter = spriter;
		this.beginTime = beginTime;
	}
	
}