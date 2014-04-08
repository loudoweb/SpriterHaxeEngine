package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class SpriterFolder
{

	public var id:Int;
	public var name:String = '';
    public var files:Array<SpriterFile>;
	
	
	public function new(fast:Fast = null) 
	{
		files = new Array<SpriterFile>();
		
		if(fast != null){
			id = Std.parseInt(fast.att.id);
			if(fast.hasNode.name){
				name = fast.att.name;
			}
			
			for (f in fast.nodes.file)
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