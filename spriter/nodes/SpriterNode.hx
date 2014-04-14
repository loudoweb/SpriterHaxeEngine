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
	public var zOrder:Int;
	
	public function new(_spriter:Spriter, _zOrder:Int)
	{
		spriter = _spriter;
		zOrder = _zOrder;
	}
	
	public function destroy():Void
	{
		spriter.destroy();
	}
}