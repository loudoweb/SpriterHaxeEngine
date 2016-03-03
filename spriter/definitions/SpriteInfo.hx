package spriter.definitions;

/**
 * ...
 * @author Loudo
 */
class SpriteInfo
{
	public var folder:Int; // index of the folder within the ScmlObject
    public var file:Int;  
	
	inline public function new(folder:Int, file:Int) 
	{
		this.folder = folder;
		this.file = file;
	}
	/**
	 * Clone this to out.
	 * @param	out
	 * @return
	 */
	inline public function clone(out:SpriteInfo):SpriteInfo
	{
		out.folder = folder;
		out.file = file;
		return out;
	}
}