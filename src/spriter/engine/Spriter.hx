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
	public var beginTime:Int;
	
	public var info:SpatialInfo;
	
	public function new(_name:String, _scml:ScmlObject, _library:AbstractLibrary, _beginTime:Int, _info:SpatialInfo) 
	{
		scml 	= _scml;
		library = _library;
		spriterName = _name;
		beginTime = _beginTime;
		scml.name = spriterName;
		info = _info;
	}
	
	public function advanceTime(time:Int):Void
	{
		scml.setCurrentTime(time, library, info);
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
	 * @param	f function callback TODO
	 * @return  true if the animation exist, false if doesn't exist
	 */
	public function playAnim(name:String, ?f:Function):Bool
	{
		if (scml.entities.get(scml.currentEntity).animations.exists(name)) {
			scml.currentAnimation = name;//TODO reset time ?
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
			scml.currentEntity = name;//TODO reset time ?
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
	
}