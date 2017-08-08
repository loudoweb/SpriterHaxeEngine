package spriter.definitions;

import haxe.xml.Fast;

/**
 * ...
 * @author loudo
 */
class SoundlineKey extends EventlineKey
{

	public var folder:Int;
	public var file:Int;
	public function new(fast:Fast) 
	{
		super(fast);
		if(fast != null){
			folder = Std.parseInt(fast.node.object.att.folder);
			file = Std.parseInt(fast.node.object.att.file);
		}
	}
	
	override public function copy ():EventlineKey
	{
		var	copy:EventlineKey = new SoundlineKey(null);
		return clone (copy);
	}

	override public function clone (clone:EventlineKey):EventlineKey
	{
		super.clone(clone);
		var	c:SoundlineKey = cast clone;
		c.folder = folder;
		c.file = file;
		return c;
	}
	
}