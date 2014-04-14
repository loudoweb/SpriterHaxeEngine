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
	//data structure
	private var _spriters:Array<Spriter>;
	private var _spritersNamed:Map<String , Spriter>;
	//spriters
	private var _scml:ScmlObject;
	private var _lib:AbstractLibrary;
	private var _graphics:Sprite;
	
	//time
	private var _elapsed:Int = 0;
	private var _time:Int;
	private var _frameRate:Int;
	
	public function new(scml:String, library:AbstractLibrary, graphics:Sprite, frameRate:Int = 60) 
	{
		_spriters = new Array<Spriter>();
		_spritersNamed = new Map<String ,Spriter>();
		
		_scml = new ScmlObject(Xml.parse(scml));
		_lib = library;
		_graphics = graphics;
		_frameRate = frameRate;
		_lib.setRoot(_graphics);
	}
	
	public function addEntity(id:String, x:Float = 0, y:Float = 0, ?index:Null<Int>, copySCML:Bool = true):Void {

		//create spatial info for the current Spriter
		var info:SpatialInfo = new SpatialInfo(x, -y);//-y because use inverted y coordinates
		
		//select scmlObject
		var currentSCML:ScmlObject;
		if (copySCML) {
			currentSCML 	  =  _scml.copy();//TOFIX something wrong in the copy : see character map
			currentSCML.name = id;
		}else {
			currentSCML = _scml;
		}
		//create the Spriter
		var spriter:Spriter = new Spriter(id, currentSCML, _lib, getTime(_time), info);
		//store in array
		if(index == null || index > _spriters.length){
			_spriters.push(spriter);
		}else if(index <= 0){
			_spriters.unshift(spriter);
		}else {
			_spriters.insert(index, spriter);
		}
		
		//store by name/id
		_spritersNamed.set(id, spriter);
	}
	public function getIndex(spriter:Spriter):Int
	{
		return _spriters.indexOf(spriter);
	}
	
	/** Moves a Spriter to a certain index. Spriters at and after the replaced position move up.*/
	public function setIndex(spriter:Spriter, index:Int):Void
	{
		var oldIndex:Int = getIndex(spriter);
		if (oldIndex == index) return;
		if (oldIndex == -1) trace("Not in this container");
		_spriters.splice(oldIndex, 1);
		_spriters.insert(index, spriter);
	}
	
	/** Swaps the indexes of two children. */
	public function swap(spriter1:Spriter, spriter2:Spriter):Void
	{
		var index1:Int = getIndex(spriter1);
		var index2:Int = getIndex(spriter2);
		if (index1 == -1 || index2 == -1) trace("Not in this container");
		swapAt(index1, index2);
	}
	
	/** Swaps the indexes of two children. */
	public function swapAt(index1:Int, index2:Int):Void
	{
		var spriter1:Spriter = getEntityAt(index1);
		var spriter2:Spriter = getEntityAt(index2);
		_spriters[index1] = spriter2;
		_spriters[index2] = spriter1;
	}
	public function removeEntity(id:String):Void {
		if (_spritersNamed.exists(id)) {
			var current:Spriter = _spritersNamed.get(id);
			_spritersNamed.remove(id);
			var index:Int = getIndex(current);
			_spriters.splice(index, 1);
			current.destroy();
			current = null;
		}else {
			trace("id doesn't exist");
		}
	}
	public function removeEntityAt(index:Int):Void {
		if (index >= 0 && index < _spriters.length) {
			var current:Spriter = _spriters[index];
			_spriters.splice(index, 1);
			_spritersNamed.remove(current.spriterName);
			current.destroy();
			current = null;
		}else {
			trace('index outside range');
		}
	}
	public function getEntity(id:String):Spriter
	{
		if (_spritersNamed.exists(id))
			return _spritersNamed.get(id);
		return null;
	}
	public function getEntityAt(index:Int):Spriter
	{
		if (index >= 0 && index < _spriters.length)
			return _spriters[index];
		else
			trace("index outside range");
		return null;
	}
	public function update(time:Int = -1)
	{
		++_elapsed;
		_time = getTime(time);
		
		_lib.clear();//TODO handle different for other platform?
		
		var spriter:Spriter;
		for (i in 0..._spriters.length)
		{
			spriter = _spriters[i];
			spriter.advanceTime(_time - spriter.beginTime);
		}
		
		_lib.render();
	}
	public function getTime(time:Int = -1):Int {
		return time != -1 ? time  : Std.int(_elapsed * 1000 / _frameRate);
	}
	
}