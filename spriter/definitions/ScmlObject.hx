package spriter.definitions;

import haxe.Unserializer;
import haxe.xml.Fast;
import spriter.interfaces.IScml;
import spriter.library.AbstractLibrary;
import spriter.vars.Variable;

/**
 * ...
 * @author Loudo
 */
enum MetaDispatch
{
	ONCE;
	ONCE_PER_LOOP;
	ALWAYS;
}
class ScmlObject implements IScml
{

	public var folders:Array<SpriterFolder>;
	public var activeCharacterMap:Array<SpriterFolder>;
	public var entities:Map<String, SpriterEntity>;
	/**
	 * Get the names of all entities in the scml file
	 */
	public var entitiesName:Array<String>;
	public var tags:Array<String>;

    public var currentEntity:String 	= ""; 
    public var currentAnimation:String  = ""; 

    public var currentTime:Float; 
	
	public var spriterName:String;
		
	/**
	 * Callback called at the end of the anim
	 */
	public var endAnimCallback:Void->Void;
	/**
	 * Auto Remove the callback at the end of the anim
	 */
	public var endAnimRemoval:Bool = true;
	/**
	 * Callback called when variable value changes
	 */
	public var varChangeCallback:Variable<Dynamic>->Void;
	/**
	 * Callback called when tag dispatched
	 */
	public var tagCallback:String->Void;
	public var metaDispatch:MetaDispatch = ONCE_PER_LOOP;
		
	public function new(source:Xml = null) 
	{
		if(source != null){
			folders = new Array<SpriterFolder>();
			entities = new Map<String,SpriterEntity>();
			entitiesName = [];
			
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
					entitiesName.push(el.att.name);
					if (el.att.id == "0") {
						currentEntity = el.att.name;
						currentAnimation = el.node.animation.att.name;
					}
				}else if (el.name == "tag_list")
				{
					if (tags == null)
						tags = [];
					for (t in el.elements)
					{
						tags.push(t.att.name);
					}
					
				}
			}
			
			activeCharacterMap = copyFolders();
		}
	}
	//interface IScml begin
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
	public function onEndAnim():Void
	{
		if (endAnimCallback != null) {
			var tempCallback:Void->Void = endAnimCallback;
			if (endAnimRemoval)
				endAnimCallback = null;
			tempCallback();
		}
	}
	public function onTag(tag:Int):Void
	{
		if (tagCallback != null) {
			tagCallback(tags[tag]);
		}
	}
	public function onVar(id:Int, value:String):Void
	{
		var variable:Variable<Dynamic> = entities[currentEntity].variables[id];
		//callback only if var changes
		if (variable.set(value))
		{
			if (varChangeCallback != null) {
				varChangeCallback(variable);
			}
		}
	}
	//interface IScml end
    public function setCurrentTime(newTime:Int, library:AbstractLibrary, characterInfo:SpatialInfo):Void
    {
        var currentEnt:SpriterEntity 		=	entities.get(currentEntity);
		var currentAnim:SpriterAnimation	=	currentEnt.animations.get(currentAnimation);
		currentAnim.setCurrentTime(newTime, library, this, currentEnt, characterInfo);
    }
	public function setSubEntityCurrentTime(library:AbstractLibrary, t:Float, entity:Int, animation:Int, spatialInfo:SpatialInfo):Void
	{
		var entityName:String = entitiesName[entity];
		var currentEnt:SpriterEntity 		=	entities.get(entityName);
		var animationName:String = currentEnt.animationsName[animation];
		var currentAnim:SpriterAnimation	=	currentEnt.animations.get(animationName);
		var newTime:Int = Std.int(t * currentAnim.length);
		currentAnim.setCurrentTime(newTime, library, this, currentEnt, spatialInfo);
	}

    public function applyCharacterMap(name:String, reset:Bool):Bool
    {
		if(reset)
		{
			activeCharacterMap = copyFolders();
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
	/**
	 * Get the names of all animations in the scml file
	 * @param	entity you have to speficy an entity where we can search the animations.
	 */
	public function getAnimationsName(entity:String):Array<String>
	{
		if (entities.exists(entity)) {
			var entity:SpriterEntity = entities.get(entity);
			return entity.animationsName;
		}
		return null;
	}
	/**
	 * Get the names of all character mapping in the scml file
	 * @param	entity you have to speficy an entity where we can search the character mapping.
	 */
	public function getCharMaps(entity:String):Array<String>
	{
		if (entities.exists(entity)) {
			var entity:SpriterEntity = entities.get(entity);
			var returnCharMaps:Array<String> = [];
			for (key in entity.characterMaps.keys())
			{
				returnCharMaps.push(key);
			}
			return returnCharMaps;
		}
		return null;
	}
	
	private function copyFolders():Array<SpriterFolder>
	{
		var newFolders = new Array<SpriterFolder>();
		for (i in 0...folders.length)
		{
			newFolders[i] = folders[i].copy();
		}
		return newFolders;
	}
	
	public function copy(?id:String):ScmlObject
	{
		var newSCML:ScmlObject = new ScmlObject();
		newSCML.folders = copyFolders();
		newSCML.activeCharacterMap = copyFolders();
		newSCML.entities = entities;//TODO copy ?
		newSCML.entitiesName = entitiesName;
		newSCML.tags = tags;
		
		newSCML.currentEntity 	= Std.string(currentEntity); 
		newSCML.currentAnimation  = Std.string(currentAnimation); 
		newSCML.currentTime = 0; 
		newSCML.spriterName = id;
		return newSCML;
	}
	
	public function destroy():Void
	{
		folders = null;
		activeCharacterMap = null;
		entities = null;
		entitiesName = null;
		tags = null;
		endAnimCallback = null;
		tagCallback = null;
		varChangeCallback = null;
	}
	
	public static function unserialize(bin:String):ScmlObject
	{
		var serializer:Unserializer = new Unserializer(bin);
		var scml:ScmlObject = cast serializer.unserialize();
		return scml;
	}
	public static function unserializePack(bin:String):Map<String, ScmlObject>
	{
		var serializer:Unserializer = new Unserializer(bin);
		var map:Map<String, ScmlObject> = cast serializer.unserialize();
		return map;
	}
}