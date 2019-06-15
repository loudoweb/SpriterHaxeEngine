package spriter.definitions;
import haxe.xml.Access;

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
	
	public function new(xml:Access) 
	{
		folder = Std.parseInt(xml.att.folder);
		file = Std.parseInt(xml.att.file);
		tarFolder = xml.has.target_folder ? Std.parseInt(xml.att.target_folder) : -1;
		tarFile = xml.has.target_file ? Std.parseInt(xml.att.target_file) : -1;
	}
	
}