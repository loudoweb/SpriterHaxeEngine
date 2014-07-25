package spriter.engine;
import flash.display.Sprite;
import flash.Lib;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;

/**
 * ...
 * @author Loudo
 */
class SpriterEngine
{
	/*
	 * #############################################
	 * Data structure
	 * #############################################
	 */
	/**
	 * Contains all the Spriter entities currently playing, ordering by index (z-ordering).
	 */
	var _spriters:Array<Spriter>;
	/**
	 * Contains all the Spriter entities currently playing, ordering by their name.
	 */
	var _spritersNamed:Map<String , Spriter>;
	/*
	 * #############################################
	 * Spriter stuff
	 * #############################################
	 */
	/**
	 * SCML object created with the Brashmonkey Spriter document (.scml).
	 */
	public var scml(default,null):ScmlObject;
	/**
	 * This is the lib used to retrieve a graphic and display the Spriter on screen.
	 */
	var _lib:AbstractLibrary;
	/**
	 * Main Graphic Sprite where all the Spriter are displayed.
	 */
	var _graphics:Sprite;
	/*
	 * #############################################
	 * Time
	 * #############################################
	 */
	/**
	 * If the engine is paused.
	 */
	public var paused(default, null):Bool = false;
	/**
	 * Time in Milliseconds when engine starts, unpauses, or updates.
	 */
	var _lastTime:Int = 0;
	/**
	 * How many ticks each second.
	 */
	public var framerate(get, set):Int;
	var _framerate:Int;
	/**
	 * Fixed Time in Milliseconds between each tick.
	 */
	var _frameDuration:Int = 0;
	/**
	 * Time in Milliseconds since last frame.
	 */
	var _elapsed:Int;
	/**
	 * Framerate locked to avoid frameskip. Used with variable tick.
	 * @default 100 (10 fps)
	 * @see fixedTick
	 */
	public var maxElapsed:Int = 100;
	/**
	 * Total number of milliseconds elapsed since game start.
	 */
	var _total:Int = 0;
	/**
	 * Total Ticks passed since game start.
	 */
	var _totalTicks:Int = 0;
	/**
	 * Fixed or variable tick.
	 */
	public var fixedTick:Bool = true;
	
	public function new(scml_str:String, library:AbstractLibrary, graphics:Sprite, frameRate:Int = 60) 
	{
		_spriters = new Array<Spriter>();
		_spritersNamed = new Map<String ,Spriter>();
		
		scml = new ScmlObject(Xml.parse(scml_str));
		_lib = library;
		_graphics = graphics;
		_lib.setRoot(_graphics);
		this.framerate = frameRate;
		_lastTime = Lib.getTimer();
	}
	/**
	 * Allow you to add a Spriter on screen.
	 * @param	id unique name of your Spriter.
	 * @param	x
	 * @param	y
	 * @param	?index if null same result as addChild, else same result as addChildAt(index). Spriters at and after the replaced index move up. You can use index out of range but negative means 0.
	 * @param	copySCML if false, you can use a same SCML for multiple Spriter entity, allow you to have 
	 * @param	autoRemoval if true, the Spriter will be removed after the animation is ended
	 * @return  the Spriter created
	 */
	public function addEntity(id:String, x:Float = 0, y:Float = 0, ?index:Null<Int>, autoRemoval:Bool = false, copySCML:Bool = true):Spriter 
	{

		//create spatial info for the current Spriter
		var info:SpatialInfo = new SpatialInfo(x, -y);//-y because use inverted y coordinates
		
		//select scmlObject
		var currentSCML:ScmlObject;
		if (copySCML) {
			currentSCML 	  		=  scml.copy();
			currentSCML.spriterName = id;
		}else {
			currentSCML = scml;
		}
		//create the Spriter
		var spriter:Spriter = new Spriter(id, currentSCML, _lib, info);
		if (autoRemoval) {
			spriter.playAnim(removeSpriterEntity, true);
		}
		
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
		//return the spriter
		return spriter;
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
	public function removeEntity(id:String):Void 
	{
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
	public function removeEntityAt(index:Int):Void 
	{
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
	public function removeAll():Void
	{
		var current:Spriter;
		for (i in 0..._spriters.length)
		{
			current = _spriters[i];
			current.destroy();
			current = null;
		}
		_spriters = new Array<Spriter>();
		_spritersNamed = new Map<String ,Spriter>();
		_lib.clear();
	}
	private function removeSpriterEntity(spriter:Spriter, entity:String, anim:String):Void
	{
		removeEntity(spriter.spriterName);
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
	/**
	 * You should call this function to have Spriter animation working.
	 * Call it from ENTER_FRAME or your own update engine.
	 * @param	?customElasped (optional) if you have your own engine handles elapsedTime. MilliSeconds!
	 */
	public function update(?customElapsed:Int):Void
	{
		if (!paused)
		{
			if (customElapsed != null) {
				_elapsed = customElapsed;
			}else {
				computeTime();
			}
			
			_lib.clear();//TODO handle different for other platform?
			
			var numSpriters:Int = _spriters.length;
			if(numSpriters > 0){
				var spriter:Spriter;
				for (i in 0...numSpriters)
				{
					spriter = _spriters[i];
					spriter.advanceTime(_elapsed);
				}
				_lib.render();
			}
		}
	}
	public function destroy():Void
	{
		removeAll();
		_spritersNamed = null;
		_spriters = null;
		_lib.destroy();
		scml.destroy();
	}
	/**
	 * Pauses animations. Use unpause() after.
	 * @see unpause();
	 */
	public function pause():Void
	{
		if(!paused){
			paused = true;
		}
	}
	/**
	 * Starts animations after a pause.
	 * @see pause();
	 */
	public function unpause():Void
	{
		if(paused){
			paused = false;
			_lastTime = Lib.getTimer();
		}
		
	}
	/**
	 * Time 
	 */
	function computeTime():Void
	{
		_totalTicks++;
		if (fixedTick)
		{
			_elapsed = _frameDuration;
		}
		else
		{
			var previous:Int = _lastTime;
			_lastTime = Lib.getTimer();
			_elapsed = _lastTime - previous;

			if (_elapsed > maxElapsed) 
				_elapsed = maxElapsed;
		}
		_total += _elapsed;
	}

	function set_framerate(framerate_:Int):Int
	{
		_frameDuration = Std.int(Math.abs(1000 / framerate_));
		_framerate = framerate_;
		return _framerate;
	}
	function get_framerate():Int
	{
		return _framerate;
	}
	
}