package spriter.engine;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.definitions.Quadrilateral;
import spriter.library.AbstractLibrary;
import spriter.vars.Variable;
#if SPRITER_CUSTOM_MAP
import spriter.definitions.CustomCharMap;
#end

/**
 * ...
 * @author Loudo
 */
class Spriter
{

	public var scml:ScmlObject;
	public var library:AbstractLibrary;
	public var spriterName:String;
	public var timeMS:Int = 0;
	
	/**
	 * Manipulate positions (x,y), scale, alpha and rotation through this object.
	 */
	public var info:SpatialInfo;
	
	/**
	 * If the Spriter is paused.
	 */
	public var paused:Bool = false;
	
	/**
	 * To slow down or speed up an animation.
	 */
	public var playbackSpeed:Float = 1;
	
	//Optional features
	
	#if SPRITER_CUSTOM_MAP
	var _customMap:Map<String, CustomCharMap>;
	#end
	
	
	public function new(_name:String, _scml:ScmlObject, _library:AbstractLibrary, _info:SpatialInfo) 
	{
		scml 	= _scml;
		library = _library;
		spriterName = _name;
		scml.spriterName = spriterName;
		info = _info;
	}
	
	public function advanceTime(elapsedMS:Int):Void
	{
		if(!paused)
			timeMS += Std.int(elapsedMS * playbackSpeed);
			
		scml.setCurrentTime(timeMS, library, info);//even if paused we need to draw it
	}
	/**
	 * Apply character mapping to change an element in the animation.
	 * @param	name of the character map in the xml
	 * @param	reset to apply only the new character map, if not, you can have multiple character map at the same time. Default is false.
	 * @return  this
	 */
	inline public function applyCharacterMap(name:String, reset:Bool = false):Spriter
	{
		#if SPRITER_CUSTOM_MAP
		if (_customMap != null && _customMap.exists(name))
		{
			if (reset){
				scml.resetCharacterMap();
			}
			
			var currentMap = _customMap.get(name);
			for (i in currentMap.folder...currentMap.folder + currentMap.length)
			{
				for (j in 0...scml.activeCharacterMap[i].files.length) 
				{
					scml.activeCharacterMap[i].files[j].name = StringTools.replace(scml.activeCharacterMap[i].files[j].name, currentMap.sub, currentMap.by);
				}
			}
		}else{
		#end
		scml.applyCharacterMap(name, reset);
		#if SPRITER_CUSTOM_MAP
		}
		#end
		return this;
	}
	#if SPRITER_CUSTOM_MAP
	/**
	 * @see CustomCharMap
	 * @return	this
	 */
	public function addCustomCharacterMap(name:String, sub:String, by:String, folder:Int, folderLength:Int = 1):Spriter
	{
		if (_customMap == null)
			_customMap = new Map<String, CustomCharMap>();
		_customMap.set(name, new CustomCharMap(name, sub, by, folder, folderLength));
		return this;
	}
	#end
	
	/**
	 * Play a specific animation
	 * @param	name of the animation
	 * @param	endAnimCallback function callback, return (s:Spriter, entity:String, anim:String)
	 * @param	removeCallback remove function callback after dispatch
	 * @return  this
	 */
	public function playAnim(?name:String, ?endAnimCallback:Spriter->String->String->Void, removeCallback:Bool = true):Spriter
	{
		if (name == null) {
			if (paused) 
				paused = false;
			resetTime();
			if (endAnimCallback != null) {
				scml.endAnimCallback = endAnimCallback.bind(this, scml.currentEntity, scml.currentAnimation);
				scml.endAnimRemoval = removeCallback;
			}
		}else if (scml.entities.get(scml.currentEntity).animations.exists(name)) {
			if (paused) 
				paused = false;
			resetTime();
			scml.currentAnimation = name;
			if (endAnimCallback != null) {
				scml.endAnimCallback = endAnimCallback.bind(this, scml.currentEntity, name);
				scml.endAnimRemoval = removeCallback;
			}
		}else {
			#if SPRITER_DEBUG
			trace('animation $name does not exist in entity ${scml.currentEntity}');
			#end
		}
		return this;
	}
	/**
	 * Play a specific entity.
	 * @param	entity name of the entity
	 * @param	anim name of the animation (optional)
	 * @param	endAnimCallback function callback, return (s:Spriter, entity:String, anim:String)
	 * @param	removeCallback remove function callback after dispatch
	 * @return  this
	 */
	public function playAnimFromEntity(entity:String, anim:String = '', ?endAnimCallback:Spriter->String->String->Void, removeCallback:Bool = true):Spriter
	{
		if (scml.entities.exists(entity)) {
			if (paused) 
				paused = false;
			resetTime();
			scml.currentEntity = entity;
			if(anim != ''){
				if (scml.entities.get(entity).animations.exists(anim)) {
					scml.currentAnimation = anim;
				}else {
					#if SPRITER_DEBUG
					trace('animation $anim does not exist in entity $entity');
					#end
				}
			}
			if(endAnimCallback != null){
				scml.endAnimCallback = endAnimCallback.bind(this, entity, scml.currentAnimation);
				scml.endAnimRemoval = removeCallback;
			}
		}else {
			#if SPRITER_DEBUG
			trace('entity $entity does not exist');
			#end
		}
		return this;
	}
	/**
	 * Play a stack of animations
	 * @param	names of the animations in order
	 * @param	endAnimCallback function callback, return (s:Spriter, entity:String, anim:String)
	 * @param	removeCallback remove function callback after dispatch
	 * @return  this
	 */
	public function playAnimsStack(names:Array<String>, ?endAnimCallback:Spriter->String->String->Void):Spriter
	{
		if (scml.entities.get(scml.currentEntity).animations.exists(names[0])) {
			if (paused) 
				paused = false;
			resetTime();
			scml.currentAnimation = names[0];
			scml.endAnimCallback = stackAnims.bind(names, 1, endAnimCallback);
			scml.endAnimRemoval = true;
		}else {
			#if SPRITER_DEBUG
			trace('animation ${names[0]} does not exist in entity ${scml.currentEntity}');
			#end
		}
		return this;
	}
	/**
	 * Play a stack of animations from a specific entity.
	 * @param	entity name of the entity
	 * @param	anims names of the animations in order
	 * @param	endAnimCallback function callback, return (s:Spriter, entity:String, anim:String)
	 * @param	removeCallback remove function callback after dispatch
	 * @return  true if the entity exist, false if doesn't exist
	 */
	public function playAnimsStackFromEntity(entity:String, anims:Array<String>, ?endAnimCallback:Spriter->String->String->Void):Bool
	{
		if (scml.entities.exists(entity)) {
			if (paused) 
				paused = false;
			resetTime();
			scml.currentEntity = entity;
			if (scml.entities.get(entity).animations.exists(anims[0])) {
				scml.currentAnimation = anims[0];
			}
			scml.endAnimCallback = stackAnims.bind(anims, 1, endAnimCallback);
			scml.endAnimRemoval = true;
			return true;
		}else {
			return false;
		}
	}
	
	/**
	 * Play a stack of animations whatever the entity.
	 * @param	name of the entity
	 * @param	anims names of the animations in order
	 * @param	endAnimCallback function callback, return (s:Spriter, entity:String, anim:String)
	 * @param	removeCallback remove function callback after dispatch
	 * @return  true if the entity exist, false if doesn't exist
	 */
	public function playAnimsStackFromEntities(entities:Array<String>, anims:Array<String>, ?endAnimCallback:Spriter->String->String->Void):Bool
	{
		if (scml.entities.exists(entities[0])) {
			if (paused) 
				paused = false;
			resetTime();
			scml.currentEntity = entities[0];
			if (scml.entities.get(entities[0]).animations.exists(anims[0])) {
				scml.currentAnimation = anims[0];
			}
			scml.endAnimCallback = stackAnimsWithEntitiesChange.bind(entities , anims, 1, endAnimCallback);
			scml.endAnimRemoval = true;
			return true;
		}else {
			return false;
		}
	}
	
	private function stackAnims(anims:Array<String>, nextAnim:Int, endAnimsCallback:Spriter->String->String->Void):Void
	{
		if (scml.entities.get(scml.currentEntity).animations.exists(anims[nextAnim])) {
			if (paused) 
				paused = false;
			resetTime();
			scml.currentAnimation = anims[nextAnim];
		}
		#if SPRITER_DEBUG
		trace('stackAnims', scml.currentAnimation);
		#end
		//anim after next anim handler
		if (++nextAnim >= anims.length) {
			if(endAnimsCallback != null)
				scml.endAnimCallback = endAnimsCallback.bind(this, scml.currentEntity, scml.currentAnimation);
		}else {
				scml.endAnimCallback = stackAnims.bind(anims, nextAnim, endAnimsCallback);
		}
	}
	
	private function stackAnimsWithEntitiesChange(entities:Array<String>, anims:Array<String>, nextAnim:Int, endAnimsCallback:Spriter->String->String->Void):Void
	{
		if (scml.entities.exists(entities[nextAnim])) {
			scml.currentEntity = entities[nextAnim];
			if (scml.entities.get(scml.currentEntity).animations.exists(anims[nextAnim])) {
				if (paused) 
					paused = false;
				resetTime();
				scml.currentAnimation = anims[nextAnim];
			}
		}
		#if SPRITER_DEBUG
		trace('stackAnims', scml.currentAnimation);
		#end
		//anim after next anim handler
		if (++nextAnim >= anims.length) {
			if(endAnimsCallback != null)
				scml.endAnimCallback = endAnimsCallback.bind(this, scml.currentEntity, scml.currentAnimation);
		}else {
				scml.endAnimCallback = stackAnimsWithEntitiesChange.bind(entities, anims, nextAnim, endAnimsCallback);
		}
	}
	
	inline public function getBoxes():Array<Quadrilateral>
	{
		return scml.entities[scml.currentEntity].animations[scml.currentAnimation].boxes;
	}
	inline public function getPoints():Array<SpatialInfo>
	{
		return scml.entities[scml.currentEntity].animations[scml.currentAnimation].points;
	}
	public function getVariable(name:String):Variable<Dynamic>//TODO generic
	{
		for (currVar in scml.entities[scml.currentEntity].variables)
		{
			if (currVar.name == name)
				return currVar;
		}
		return null;
	}
	inline public function getVariableFromId(id:Int):Variable<Dynamic>//TODO generic
	{
		return scml.entities[scml.currentEntity].variables[id];
	}
	
	inline public function resetTime():Void
	{
		timeMS = 0;
	}
	public function reverse(value:Bool = true):Spriter
	{
		if (value)
		{
			playbackSpeed = -1;
			timeMS = scml.entities[scml.currentEntity].animations[scml.currentAnimation].length;
		}else {
			playbackSpeed = 1;
			timeMS = 0;
		}
		return this;
	}
	/**
	 * Set positions of the Spriter
	 * @param	x
	 * @param	y (spriter uses inverted y, so it will automatically inverted in this function)
	 */
	public function set(x:Float, y:Float):Void
	{
		//-y because use inverted y coordinates
		info.setPos(x, -y);
	}
	
	public function destroy():Void
	{
		scml.destroy();
		scml = null;
		//info.put();
		info = null;
		//don't destroy library here since library is shared between all Spriter in the engine
		library = null;
	}
	
}