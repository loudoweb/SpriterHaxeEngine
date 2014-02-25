package spriter.nodes;
import spriter.components.SpriterComponent;
import spriter.engine.Spriter;
/**
 * @author Loudo
 */
class SpriterNode
{
	public var spriter:Spriter;
	public var previous:SpriterNode;
	public var next:SpriterNode;
	
	public function new(_spriter:Spriter)
	{
		spriter = _spriter;
	}
}