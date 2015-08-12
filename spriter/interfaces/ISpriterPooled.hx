package spriter.interfaces;

import spriter.interfaces.ISpriterDestroyable;

/**
 * @flixel
 */
interface ISpriterPooled extends ISpriterDestroyable
{
	public function put():Void;
	private var _inPool:Bool;
}