package spriter.definitions;

/**
 * This class is not part of the scml reference.
 * It's a custom feature from SpriterHaxeEngine.
 * Allow to set dynamically character map replacing strings in the name of the file.
 * @author Loudo
 */
class CustomCharMap
{
	public var name:String;
	public var sub:String;
	public var by:String;
	public var folder:Int;
	public var length:Int;
	/**
	 * 
	 * @param	name String unique name of your character mapping
	 * @param	sub String you need to replace
	 * @param	by String will replace your sub string
	 * @param	folder Int id of the folder you need to map
	 * @param	length Int you can target following folders if needed. Default: target only the folder specified in the folder parameter.
	 */
	public function new(name:String, sub:String, by:String, folder:Int, length:Int = 1) 
	{
		this.name = name;
		this.sub = sub;
		this.by = by;
		this.folder = folder;
		this.length = length;
	}
}