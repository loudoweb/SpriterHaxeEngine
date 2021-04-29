package spriter.definitions;

import haxe.Unserializer;
import spriter.xml.Access;

/**
 * ...
 * @author Loudo
 */
class ScmlObject
{

	public var folders:Array<SpriterFolder>;
	public var entities:Map<String, SpriterEntity>;
	/**
	 * Get the names of all entities in the scml file
	 */
	public var entitiesName:Array<String>;
    public var defaultEntity:String 	= ""; 
    public var defaultAnimation:String  = ""; 
	
	#if !SPRITER_NO_TAG
	public var tags:Array<String>;
	#end

    public var currentTime:Float; 

	public var isShortenedPath(default, null):Bool;
		
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
	
	/**
	 * Parse the scml
	 * @param source 
	 * @param isShortenedPath = false; if true remove path and extension of the files
	 */
	public function new(source:Xml = null, isShortenedPath = false) 
	{
		this.isShortenedPath = isShortenedPath;

		if(source != null){
			folders = new Array<SpriterFolder>();
			entities = new Map<String,SpriterEntity>();
			entitiesName = [];
			
			var xml = new Access(source.firstElement());
			
			if (xml.att.scml_version != "1.0")
				trace("Warning, unsupported format.");
			
			for(el in xml.elements)
			{
				if(el.name == "folder")
				{
					folders.push(new SpriterFolder(el, isShortenedPath));
				}
				else if(el.name == "entity")
				{
					entities.set(el.att.name, new SpriterEntity(el));
					entitiesName.push(el.att.name);
					if (el.att.id == "0") {
						defaultEntity = el.att.name;
						defaultAnimation = el.node.animation.att.name;
					}
				}else if (el.name == "tag_list")
				{
					#if !SPRITER_NO_TAG
					if (tags == null)
						tags = [];
					for (t in el.elements)
					{
						tags.push(t.att.name);
					}
					#end
					
				}
			}
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
	
	public function copyFolders():Array<SpriterFolder>
	{
		var newFolders = new Array<SpriterFolder>();
		for (i in 0...folders.length)
		{
			newFolders[i] = folders[i].copy();
		}
		return newFolders;
	}
	
	public function copy():ScmlObject
	{
		var newSCML:ScmlObject = new ScmlObject();
		newSCML.folders = copyFolders();
		newSCML.entities = entities;//TODO copy ?
		newSCML.entitiesName = entitiesName;
		#if !SPRITER_NO_TAG
		newSCML.tags = tags;
		#end
		
		newSCML.defaultEntity 	= Std.string(defaultEntity); 
		newSCML.defaultAnimation  = Std.string(defaultAnimation); 
		newSCML.currentTime = 0; 
		return newSCML;
	}
	
	public function destroy():Void
	{
		folders = null;
		entities = null;
		entitiesName = null;
		#if !SPRITER_NO_TAG
		tags = null;
		#end
	}
}