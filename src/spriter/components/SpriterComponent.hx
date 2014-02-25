package spriter.components;
import spriter.engine.Spriter;

/**
 * ...
 * @author Loudo
 */
class SpriterComponent
{

	public var spriter:Spriter;
	public var id:String;

	public function new(spriter:Spriter, id:String)
	{
		this.spriter = spriter;
		this.id = id;
	}
	
}