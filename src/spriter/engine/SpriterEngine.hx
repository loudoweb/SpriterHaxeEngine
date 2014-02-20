package spriter.engine;
import flash.Lib;
import spriter.components.SpriterComponent;

/**
 * ...
 * @author Loudo
 */
class SpriterEngine
{

	private var _sprites:Map<String ,SpriterComponent>;
	private var _elapsed:Int = 0;
	private var _time:Int;
	private var _frameRate:Int;
	
	public function new(frameRate:Int = 30) 
	{
		_sprites = new Map<String ,SpriterComponent>();
		_frameRate = frameRate;
	}
	
	public function add(id:String, s:Spriter):Void {
		_sprites.set(id, new SpriterComponent(s, getTime(_time)));
	}
	public function remove(id:String):Void {
		_sprites.remove(id);
	}
	public function update(time:Int = -1)
	{
		++_elapsed;
		
		_time = getTime(time);
	 	for(node in _sprites)
	 	{
			node.spriter.advanceTime(_time - node.beginTime);
	 	}
	}
	public function getTime(time:Int = -1):Int {
		return time != -1 ? time  : Std.int(_elapsed * 1000 / _frameRate);
	}
	
}