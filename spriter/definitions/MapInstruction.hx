package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class MapInstruction
{
	public var folder:Int;
    public var file:Int;
    public var tarFolder:Int;
    public var tarFile:Int;
	
	public function new(fast:Fast) 
	{
		folder = Std.parseInt(fast.att.folder);
		file = Std.parseInt(fast.att.file);
		tarFolder = fast.has.target_folder ? Std.parseInt(fast.att.target_folder) : -1;
		tarFile = fast.has.target_file ? Std.parseInt(fast.att.target_file) : -1;
	}
	
}