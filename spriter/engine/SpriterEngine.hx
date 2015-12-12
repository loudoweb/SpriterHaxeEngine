package spriter.engine;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;
#if openfl
import openfl.Lib;
#end

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
	 * SCML library created with the Brashmonkey Spriter document (.scml).
	 */
	public var default_scml:ScmlObject;
	/**
	 * Used to retrieve a graphic and add it to the custom rendering system.
	 */
	var _lib:AbstractLibrary;
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
	 * Framerate locked to avoid frameskip. Used with variable tick (= fixedTick=false).
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
	 * @default true
	 */
	public var fixedTick:Bool = true;
	
	/*
	 * If you want to clear and render the library outside of SpriterEngine, please set to false.
	 * @default true
	 */
	public var handleLibraryClearAndRender:Bool = true;
	
	/**
	 * 
	 * @param	scml_toParse	String to parse as xml to create the scmlObject
	 * @param	scml_parsed		ScmlObject already created that you can passed instead of the scml_toParse paremeter
	 * @param	library			AbstractLibrary
	 * @param	fixedTick		Bool, default true. Means that when you call update(),
	 * @param	frameRate		Int framerate used by fixedTick, default framerate 60
	 * @param	handleRender	Bool, default true. Means that this engine will handle the rendering from AbstractLibrary for you. You can handle by yourself by setting it to false.
	 */
	public function new(?scml_toParse:String, ?scml_parsed:ScmlObject, library:AbstractLibrary, fixedTick:Bool = true, frameRate:Int = 60, handleRender:Bool = true) 
	{
		_spriters = new Array<Spriter>();
		_spritersNamed = new Map<String ,Spriter>();
		
		if(scml_toParse != null && scml_toParse != "")
		{
			default_scml = new ScmlObject(Xml.parse(scml_toParse));
		}
		else if (scml_parsed != null)
		{
			default_scml = scml_parsed;
		}else {
			#if SPRITER_DEBUG
			trace('WARNING: If you don\'t add default scml with scml_ToParse or scml_parsed parameter in the constructor, you will have to specify each time the scml with addSpriter()');
			#end
		}
		_lib = library;
		this.fixedTick = fixedTick;
		this.framerate = frameRate;
		this.handleLibraryClearAndRender = handleRender;
		#if openfl
		_lastTime = Lib.getTimer();
		#end
	}
	/**
	 * Allow you to add a Spriter on screen. By default, the first animation of the first entity of the scml is played.
	 * @param	id unique name of your Spriter. This id helps you retrieve the Spriter in getSpriter(id:String) and other methods
	 * @param	x position of your Spriter
	 * @param	y position of your Spriter
	 * @param	scml scml of this Spriter if you don't want to use the default scml
	 * @param	?index if null same result as addChild, else same result as addChildAt(index). Spriters at and after the replaced index move up. You can use index out of range but negative means 0.
	 * @param	autoRemoval if true, the Spriter will be removed after the animation is ended
	 * @return  the Spriter created
	 */
	public function addSpriter(id:String, ?x:Float = 0, ?y:Float = 0, ?scml:ScmlObject, ?index:Null<Int>, ?autoRemoval:Bool = false):Spriter 
	{

		//create spatial info for the current Spriter
		var info:SpatialInfo = new SpatialInfo(x, -y);//-y because use inverted y coordinates
		
		if (scml == null)
			scml = default_scml.copy(id);
		//create the Spriter
		var spriter:Spriter = new Spriter(id, scml, _lib, info);
		if (autoRemoval) {
			spriter.playAnim(autoRemoveSpriter, true);
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
	
	/**
	 * Retrieve the index of a Spriter
	 * @param	spriter
	 * @return index
	 */
	public function getIndex(spriter:Spriter):Int
	{
		return _spriters.indexOf(spriter);
	}
	
	/**
	 * Moves a Spriter to a certain index. Spriters at and after the replaced position move up.
	 * @param	spriter
	 * @param	index
	 */
	public function setIndex(spriter:Spriter, index:Int):Void
	{
		var oldIndex:Int = getIndex(spriter);
		if (oldIndex == index) return;
		if (oldIndex == -1) trace("Not in this container");
		_spriters.splice(oldIndex, 1);
		_spriters.insert(index, spriter);
	}
	
	/**
	 * Swaps the indexes of two children.
	 * @param	spriter1
	 * @param	spriter2
	 */
	public function swap(spriter1:Spriter, spriter2:Spriter):Void
	{
		var index1:Int = getIndex(spriter1);
		var index2:Int = getIndex(spriter2);
		if (index1 == -1 || index2 == -1) trace("Not in this container");
		swapAt(index1, index2);
	}
	
	/**
	 * Swaps the indexes of two children.
	 * @param	index1
	 * @param	index2
	 */
	public function swapAt(index1:Int, index2:Int):Void
	{
		var spriter1:Spriter = getSpriterAt(index1);
		var spriter2:Spriter = getSpriterAt(index2);
		_spriters[index1] = spriter2;
		_spriters[index2] = spriter1;
	}
	/**
	 * Remove a Spriter from screen and destroy it
	 * @param	id of the Spriter you want to remove
	 */
	public function removeSpriter(id:String):Void 
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
	/**
	 * Remove a Spriter from screen and destroy it
	 * @param	index of the Spriter you want to remove
	 */
	public function removeSpriterAt(index:Int):Void 
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
	/**
	 * Remove all Spriters from screen and destroy them
	 */
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
	function autoRemoveSpriter(spriter:Spriter, entity:String, anim:String):Void
	{
		removeSpriter(spriter.spriterName);
	}
	/**
	 * Get a Spriter from its id
	 * @param	id
	 * @return
	 */
	public function getSpriter(id:String):Spriter
	{
		if (_spritersNamed.exists(id))
			return _spritersNamed.get(id);
		return null;
	}
	/**
	 * Get a Spriter from its index
	 * @param	index
	 * @return
	 */
	public function getSpriterAt(index:Int):Spriter
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
	 * @param	?customElapsed (optional) if you have your own engine handles elapsedTime. MilliSeconds!
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
			
			if(handleLibraryClearAndRender)
				_lib.clear();//TODO handle different for other platform?
			
			var numSpriters:Int = _spriters.length;
			if(numSpriters > 0){
				var spriter:Spriter;
				for (i in 0...numSpriters)
				{
					spriter = _spriters[i];
					spriter.advanceTime(_elapsed);
				}
				if(handleLibraryClearAndRender)
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
		default_scml.destroy();
		default_scml = null;
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
			#if openfl
			_lastTime = Lib.getTimer();
			#end
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
			#if openfl
			var previous:Int = _lastTime;
			_lastTime = Lib.getTimer();
			_elapsed = _lastTime - previous;

			if (_elapsed > maxElapsed) 
				_elapsed = maxElapsed;
			#elseif SPRITER_DEBUG
			trace('variable tick not supported outside openfl, please set fixedTick to true or use your own elapsedTime in update()');
			#end
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