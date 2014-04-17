package spriter.definitions;

import haxe.xml.Fast;
import spriter.interfaces.IScml;
import spriter.library.AbstractLibrary;

/**
 * ...
 * @author Loudo
 */
class ScmlObject implements IScml
{

	public var folders:Array<SpriterFolder>;
	public var activeCharacterMap:Array<SpriterFolder>;
	public var entities:Map<String, SpriterEntity>;

    public var currentEntity:String 	= ""; 
    public var currentAnimation:String  = ""; 

    public var currentTime:Float; 
	
	public var name:String;
	
	private var _characterInfo:SpatialInfo;
	
	public var endAnimCallback:Void->Void;
	public var endAnimRemoval:Bool = true;
		
	public function new(source:Xml = null) 
	{
		if(source != null){
			folders = new Array<SpriterFolder>();
			entities = new Map<String,SpriterEntity>();
			
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
					entities.set(el.att.name, new SpriterEntity(el));
					if (el.att.id == '0') {
						currentEntity = el.att.name;
						currentAnimation = el.node.animation.att.name;
					}
				}
			}
			
			activeCharacterMap = folders;
		}
	}
	//interface IScml begin
	public function characterInfo():SpatialInfo
    {
		return _characterInfo;
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
	public function onEndAnim():Void
	{
		if (endAnimCallback != null) {
			var tempCallback:Void->Void = endAnimCallback;
			if (endAnimRemoval)
				endAnimCallback = null;
			tempCallback();
		}
		
	}
	//interface IScml end
    public function setCurrentTime(newTime:Int, library:AbstractLibrary, characterInfo:SpatialInfo):Void
    {
        var currentEnt:SpriterEntity 		=	entities.get(currentEntity);
		var currentAnim:SpriterAnimation	=	currentEnt.animations.get(currentAnimation);
		_characterInfo = characterInfo;
		currentAnim.setCurrentTime(newTime, library, this);
    }		

    public function applyCharacterMap(name:String, reset:Bool):Bool
    {
		if(reset)
		{
			activeCharacterMap	=	folders;//TOFIX copy everything ? or find other solution
		}
		
		var	entity:SpriterEntity = entities.get(currentEntity);
		
		if (entity.characterMaps.exists(name)) {
			
			var charMap:CharacterMap = entity.characterMaps.get(name);
			
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
			return true;
		}else {
			return false;
		}
    }
	public function copy():ScmlObject
	{
		var newSCML:ScmlObject = new ScmlObject();
		newSCML.folders = new Array<SpriterFolder>();
		for (i in 0...folders.length)
		{
			newSCML.folders[i] = folders[i].copy();
		}
		newSCML.activeCharacterMap = newSCML.folders;
		newSCML.entities = entities;//TODO copy ?

		newSCML.currentEntity 	= Std.string(currentEntity); 
		newSCML.currentAnimation  = Std.string(currentAnimation); 
		newSCML.currentTime = 0; 
		return newSCML;
	}
	
	public function destroy():Void
	{
		folders = null;
		activeCharacterMap = null;
		entities = null;
	}
}