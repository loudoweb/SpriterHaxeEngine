package spriter.definitions;
import haxe.xml.Access;

/**
 * ...
 * @author Loudo
 */
class TaglineKey
{
	public var id:Int;
	public var time:Int = 0;
	public var t:Array<Int>;
	public function new(xml:Access = null) 
	{
		if(xml != null){
			id = xml.has.id ? Std.parseInt(xml.att.id) : 0;
			time = xml.has.time ? Std.parseInt(xml.att.time) : 0;
			t = [];
			for (tag in xml.nodes.tag)
			{
				t.push(Std.parseInt(tag.att.t));
			}
		}
	}
	public function copy ():TaglineKey
	{
		var	copy:TaglineKey = new TaglineKey();
		return clone (copy);
	}

	public function clone (clone:TaglineKey):TaglineKey
	{
		clone.id = id;
		clone.time = time;
		clone.t = t;
		return clone;
	}
}