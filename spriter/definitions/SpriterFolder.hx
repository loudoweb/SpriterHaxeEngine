package spriter.definitions;
import haxe.xml.Access;

/**
 * ...
 * @author Loudo
 */
class SpriterFolder
{

	public var id:Int;
	public var name:String = '';
    public var files:Array<SpriterFile>;
	
	
	public function new(xml:Access = null) 
	{
		files = new Array<SpriterFile>();
		
		if(xml != null){
			id = Std.parseInt(xml.att.id);
			if(xml.hasNode.name){
				name = xml.att.name;
			}
			
			for (f in xml.nodes.file)
			{
				files.push(new SpriterFile(f));
			}
		}
	}
	
	public function copy():SpriterFolder
	{
		var copy:SpriterFolder = new SpriterFolder();
		copy.name = name;
		copy.id = id;
		for (i in 0...files.length)
		{
			copy.files[i] = files[i].copy();
		}
		return copy;
	}
	
}