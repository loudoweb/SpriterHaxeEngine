package spriter.engine;
import flash.display.Sprite;
import haxe.macro.Expr.Function;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;
import spriter.library.SpriterLibrary;

/**
 * ...
 * @author Loudo
 */
class Spriter
{

	public var scml:ScmlObject;
	public var library:AbstractLibrary;
	public var spriterName:String;
	public var timeMS:Int = 0;
	
	public var info:SpatialInfo;
	
	private var _endAnimCallback:Spriter->String->Void;
	
	
	public function new(_name:String, _scml:ScmlObject, _library:AbstractLibrary, _info:SpatialInfo) 
	{
		scml 	= _scml;
		library = _library;
		spriterName = _name;
		scml.name = spriterName;
		info = _info;
	}
	
	public function advanceTime(elapsedMS:Int):Void
	{
		timeMS += elapsedMS;
		scml.setCurrentTime(timeMS, library, info);
		
	}
	/**
	 * Apply character mapping to change an element in the animation.
	 * @param	name of the character map in the xml
	 * @param	reset to apply only the new character map, if not, you can have multiple character map at the same time
	 * @return  true if the character map exist, false if doesn't exist
	 */
	public function applyCharacterMap(name:String, reset:Bool):Bool
	{
		return scml.applyCharacterMap(name, reset);
	}
	
	/**
	 * Play a specific animation
	 * @param	name of the animation
	 * @param	f function callback
	 * @return  true if the animation exist, false if doesn't exist
	 */
	public function playAnim(name:String, ?f:Spriter->String->Void):Bool
	{
		if (scml.entities.get(scml.currentEntity).animations.exists(name)) {
			resetTime();
			scml.currentAnimation = name;
			if(f != null){
				scml.endAnimCallback = handleEndAnim;
				_endAnimCallback = f;
			}
			return true;
		}else {
			return false;
		}
	}
	/**
	 * Play a specific entity.
	 * @param	name of the entity
	 * @param	name of the animation (optional)
	 * @return  true if the entity exist, false if doesn't exist
	 */
	public function playEntity(name:String, anim:String = ''):Bool
	{
		if (scml.entities.exists(name)) {
			resetTime();
			scml.currentEntity = name;
			if(anim != ''){
				if (scml.entities.get(name).animations.exists(anim)) {
					scml.currentAnimation = anim;
				}
			}
			return true;
		}else {
			return false;
		}
	}
	
	public function resetTime():Void
	{
		timeMS = 0;
	}
	
	public function destroy():Void
	{
		scml.destroy();
	}
	
	private function handleEndAnim(anim:String):Void
	{
		if (_endAnimCallback != null)
			_endAnimCallback(this, anim);
	}
	
}