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
	
	
	public function new(fast:Fast) 
	{
		files = new Array<SpriterFile>();
		
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