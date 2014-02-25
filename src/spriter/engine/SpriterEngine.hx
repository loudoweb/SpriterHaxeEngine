package spriter.engine;
import flash.display.Sprite;
import flash.Lib;
import spriter.components.SpriterComponent;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;
import spriter.library.SpriterLibrary;
import spriter.nodes.SpriterNode;

/**
 * ...
 * @author Loudo
 */
class SpriterEngine
{
	//spriters
	private var _spriters:Map<Int , SpriterNode>;
	private var _scml:ScmlObject;
	private var _lib:AbstractLibrary;
	private var _graphics:Sprite;
	private var _lastZOrder:Int = -1;
	private var _firstZOrder:Null<Int> = null;
	
	//time
	private var _elapsed:Int = 0;
	private var _time:Int;
	private var _frameRate:Int;
	
	public function new(scml:String, library:AbstractLibrary, graphics:Sprite, frameRate:Int = 60) 
	{
		_spriters = new Map<Int ,SpriterNode>();
		
		_scml = new ScmlObject(Xml.parse(scml));
		_lib = library;
		_graphics = graphics;
		_frameRate = frameRate;
		_lib.setRoot(_graphics);
	}
	
	public function addEntity(id:String, x:Float = 0, y:Float = 0, ?layer:Null<Int>, copySCML:Bool = true):Void {
		var currentZOrder:Int;
		if (layer == null) {
			currentZOrder = ++_lastZOrder;
		}else {
			currentZOrder = layer;
			if (currentZOrder > _lastZOrder)
				_lastZOrder = layer;
			
		}
		if (currentZOrder < _firstZOrder || _firstZOrder == null)
				_firstZOrder = currentZOrder;
				
		var info:SpatialInfo = new SpatialInfo(x, -y);//-y because use inverted y coordinates
		
		var currentSCML:ScmlObject;
		if (copySCML) {
			currentSCML 	  =  _scml.copy();//TOFIX something wrong in the copy : see character map
			currentSCML.name = id;
		}else {
			currentSCML = _scml;
		}
		var node:SpriterNode = new SpriterNode(new Spriter(id, currentSCML, _lib, getTime(_time), info));
		var next:SpriterNode = _spriters.get(currentZOrder);
		if (next != null)
		{
			node.next = next;
			next.previous = node;
			var previous:SpriterNode = _spriters.get(currentZOrder - 1);
			if (previous != null) {
				previous.next = node;
			}
			_spriters.set(currentZOrder, node);
			
			insertNode(currentZOrder + 1, next);//update all next node
		}
		else
		{
			_spriters.set(currentZOrder, node);
			node.previous = _spriters.get(currentZOrder - 1);
			if(node.previous != null)
				node.previous.next = node;
			node.next = _spriters.get(currentZOrder + 1);
			if(node.next != null)
				node.next.previous = node;
		}
	}
	public function removeEntity(layer:Int):Void {
		if(_spriters.exists(layer))
			_spriters.remove(layer);
	}
	public function getEntity(layer:Int):Spriter
	{
		if (_spriters.exists(layer))
			return _spriters.get(layer).spriter;
		return null;
	}
	private function insertNode(index:Int, node:SpriterNode) 
    { 
		_spriters.set(index, node);
		if (node.next != null)
		{
			insertNode(index + 1, node.next);
		}
    }
	public function update(time:Int = -1)
	{
		++_elapsed;
		
		_time = getTime(time);
		_lib.clear();//TODO handle different for other platform?
	 	var node:SpriterNode = _spriters.get(_firstZOrder);
		while(node != null)
	 	{
			node.spriter.advanceTime(_time - node.spriter.beginTime);
			node = node.next;
	 	}
		_lib.render();
	}
	public function getTime(time:Int = -1):Int {
		return time != -1 ? time  : Std.int(_elapsed * 1000 / _frameRate);
	}
	
}