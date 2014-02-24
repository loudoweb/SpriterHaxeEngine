package spriter.engine;
import flash.display.Sprite;
import flash.Lib;
import spriter.components.SpriterComponent;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;
import spriter.library.SpriterLibrary;

/**
 * ...
 * @author Loudo
 */
class SpriterEngine
{
	//spriters
	private var _spriters:Map<String , Spriter>;
	private var _scml:ScmlObject;
	private var _lib:AbstractLibrary;
	private var _graphics:Sprite;
	
	//time
	private var _elapsed:Int = 0;
	private var _time:Int;
	private var _frameRate:Int;
	
	public function new(scml:String, library:AbstractLibrary, graphics:Sprite, frameRate:Int = 60) 
	{
		_spriters = new Map<String ,Spriter>();
		
		_scml = new ScmlObject(Xml.parse(scml));
		_lib = library;
		_graphics = graphics;
		_frameRate = frameRate;
		_lib.setRoot(_graphics);
	}
	
	public function addEntity(id:String, x:Float = 0, y:Float = 0, z_order:Int = 0, copySCML:Bool = true):Void {
		//TODO zorder
		var info:SpatialInfo = new SpatialInfo(x, -y);//-y because use inverted coordinates
		if (copySCML) {
			var copy:ScmlObject 	  =  _scml.copy();
			copy.name = id;
			_spriters.set(id, new Spriter(id, copy, _lib, getTime(_time),info));
		}else {
			_spriters.set(id, new Spriter(id, _scml, _lib, getTime(_time),info));
		}
		
		
	}
	public function removeEntity(id:String):Void {
		if(_spriters.exists(id))
			_spriters.remove(id);
	}
	public function getEntity(id:String):Spriter
	{
		if (_spriters.exists(id))
			return _spriters.get(id);
		return null;
	}
	public function update(time:Int = -1)
	{
		++_elapsed;
		
		_time = getTime(time);
		_lib.clear();//TODO handle different for other platform
	 	for(node in _spriters)
	 	{
			node.advanceTime(_time - node.beginTime);
	 	}
		_lib.render();
	}
	public function getTime(time:Int = -1):Int {
		return time != -1 ? time  : Std.int(_elapsed * 1000 / _frameRate);
	}
	
}