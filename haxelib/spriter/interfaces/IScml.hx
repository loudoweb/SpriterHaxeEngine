package spriter.interfaces;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;

/**
 * @author Loudo
 */

interface IScml 
{
	function characterInfo():SpatialInfo;
	function getPivots(folder:Int, file:Int):PivotInfo;
	function getFileName(folder:Int, file:Int):String;
	function getSpriterName():String;
}