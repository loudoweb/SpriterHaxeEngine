package spriter.engine;
import flash.display.Sprite;
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
	
}