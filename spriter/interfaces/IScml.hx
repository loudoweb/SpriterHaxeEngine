package spriter.interfaces;
import spriter.definitions.PivotInfo;
import spriter.definitions.ScmlObject.MetaDispatch;
import spriter.definitions.SpatialInfo;
import spriter.definitions.SpriterEntity;
import spriter.library.AbstractLibrary;

/**
 * @author Loudo
 */

interface IScml 
{
	var spriterName:String;
	var metaDispatch:MetaDispatch;
	function getPivots(folder:Int, file:Int):PivotInfo;
	function getFileName(folder:Int, file:Int):String;
	function onEndAnim():Void;
	function onTag(tag:Int):Void;
	function onVar(id:Int, value:String, entity:SpriterEntity):Void;
	function setSubEntityCurrentTime(library:AbstractLibrary, t:Float, entity:Int, animation:Int, spatialInfo:SpatialInfo):Void;
}