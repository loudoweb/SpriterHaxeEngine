package spriter.interfaces;
import spriter.definitions.Quadrilateral;
import spriter.definitions.SpatialInfo;

/**
 * @author loudo
 */
interface ISpriter 
{
	public var spriterName:String;
	
	#if !SPRITER_NO_POINT
	public var points:Array<SpatialInfo>;
	#end
	
	#if !SPRITER_NO_BOX
	public var boxes:Array<Quadrilateral>;
	#end
	
	#if !SPRITER_NO_EVENT
	/**
	 * event callback
	 * @param	name of event
	 */
	public var onEvent:String->Void;
	#end
	
	#if !SPRITER_NO_TAG
	/**
	 * Clear all tags
	 * @param	t
	 */
	public function clearTag():Void;
	/**
	 * add a tag to the current list of tags
	 * @param	t
	 */
	public function addTag(t:Int):Void;
	#end
	
	#if !SPRITER_NO_SOUND
	/**
	 * Dispatch sound
	 * @param	folder
	 * @param	file
	 */
	public function dispatchSound(folder:Int, file:Int):Void;
	#end
	
	#if !SPRITER_NO_VAR
	/**
	 * Update variable
	 * @param	id
	 * @param	value
	 */
	public function updateVar(id:Int, value:String):Void;
	#end
}