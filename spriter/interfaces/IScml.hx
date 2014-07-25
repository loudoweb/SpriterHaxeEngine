package spriter.interfaces;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;

/**
 * @author Loudo
 */

interface IScml 
{
	var spriterSpatialInfo:SpatialInfo;
	var spriterName:String;
	function getPivots(folder:Int, file:Int):PivotInfo;
	function getFileName(folder:Int, file:Int):String;
	function onEndAnim():Void;
}