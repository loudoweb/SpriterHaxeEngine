package spriter.definitions;

import haxe.xml.Fast;
import spriter.interfaces.IScml;
import spriter.library.SpriterLibrary;

/**
 * ...
 * @author Loudo
 */
class ScmlObject implements IScml
{

	public var folders:Array<SpriterFolder>;
	public var entities:Array<SpriterEntity>;
	public var activeCharacterMap:Array<SpriterFolder>;

    public var currentEntity:Int = 0; 
    public var currentAnimation:Int = 0; 

    public var currentTime:Float; 
	
	public var name:String;
		
	public function new(source:Xml) 
	{
		folders = new Array<SpriterFolder>();
		entities = new Array<SpriterEntity>();
		
		var fast = new Fast(source.firstElement());
		
		if (fast.att.scml_version != "1.0")
			trace("Warning, unsupported format.");
					
		for(el in fast.elements)
        {
            if(el.name == "folder")
            {
                folders.push(new SpriterFolder(el));
            }
            else if(el.name == "entity")
            {
                entities.push(new SpriterEntity(el, this));
            }
        }
		
		activeCharacterMap = folders;
	}
	//interface IScml begin
	public function characterInfo():SpatialInfo
    {
		//SCML Ref :
	// Fill a SpatialInfo class with the 
        // x,y,angle,etc of this character in game
	
        // To avoid distortion the character keep 
        // scaleX and scaleY values equal

	// Make scaleX or scaleY negative to flip on that axis
		
	// Examples (scaleX,scaleY)
	// (1,1) Normal size
        // (-2.5,2.5) 2.5x the normal size, and flipped on the x axis
		return new SpatialInfo(0, 0, 0, 1, 1, 1, 1);//TODO ?
    }
	public function getPivots(folder:Int, file:Int):PivotInfo
	{
		var currentFile:SpriterFile = activeCharacterMap[folder].files[file];
		if(currentFile != null){
			return new PivotInfo(currentFile.pivotX, currentFile.pivotY);
		}else {
			return new PivotInfo();
		}
	}
	public function getFileName(folder:Int, file:Int):String
	{
		var currentFile:SpriterFile = activeCharacterMap[folder].files[file];
		if(currentFile != null){
			return currentFile.name;
		}else {
			return null;
		}
	}
	public function getSpriterName():String
	{
		return name;
	}
	//interface IScml end
    public function setCurrentTime(newTime:Int, library:SpriterLibrary):Void
    {
        var currentEnt:SpriterEntity 		=	entities[currentEntity];
		var currentAnim:SpriterAnimation	=	currentEnt.animations[currentAnimation];
		currentAnim.setCurrentTime(newTime, library);
    }		

    public function applyCharacterMap(charMap:CharacterMap, reset:Bool):Void
    {
		//TODO remove this
		var	entity:SpriterEntity = entities[currentEntity];
		charMap = entity.characterMaps[0];
		//end TODO
		
		if(reset)
		{
			activeCharacterMap	=	folders;
		}
		var len:Int = charMap.maps.length;
        for(m in 0...len)
		{
			var currentMap:MapInstruction = charMap.maps[m];
			if(currentMap.tarFolder > -1 && currentMap.tarFile > -1)
			{
				var targetFolder:SpriterFolder	=	activeCharacterMap[currentMap.tarFolder];
				var targetFile:SpriterFile		=	targetFolder.files[currentMap.tarFile];
				activeCharacterMap[currentMap.folder].files[currentMap.file]	=	targetFile;
			}else {
				activeCharacterMap[currentMap.folder].files[currentMap.file]	=	null;//hidden
			}
		}
    }
	/* //TODO
	public function clone():ScmlObject
	{
		return new ScmlObject()
	}*/
}