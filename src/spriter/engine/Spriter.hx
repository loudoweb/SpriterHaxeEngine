package spriter.engine;
import flash.display.Sprite;
import haxe.macro.Expr.Function;
import spriter.definitions.ScmlObject;
import spriter.library.SpriterLibrary;

/**
 * ...
 * @author Loudo
 */
class Spriter extends Sprite
{

	public var scml:ScmlObject;
	public var library:SpriterLibrary;
	public var spriterName:String;
	
	public function new(_name:String, _scml:ScmlObject, _library:SpriterLibrary) 
	{
		scml 	= _scml;//TODO copy  or original ?
		library = _library;
		spriterName = _name;
		
		super();
		
		library.setRoot(this);
		scml.name = spriterName;
	}
	
	public function advanceTime(time:Int):Void
	{
		library.clear();
		scml.setCurrentTime(time, library);
		library.render();
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