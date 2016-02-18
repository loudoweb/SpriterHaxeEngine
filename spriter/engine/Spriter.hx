package spriter.engine;
import spriter.definitions.Quadrilateral;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.definitions.SpriterAnimation;
import spriter.library.AbstractLibrary;
import spriter.util.SpriterUtil;
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
	
	var loop:Float = 0;
	var lastLoop:Float = 0;
	var normalizedTime:Int = 0;
	var currentEntityName:String 	= ""; 
    var currentAnimationName:String  = "";
	var currentAnimation:SpriterAnimation;
	
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
		currentEntityName = scml.defaultEntity;
		currentAnimationName = scml.defaultAnimation;
		currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
		info = _info;
	}
	
	public function advanceTime(elapsedMS:Int):Void
	{
		if (!paused)
		{
			timeMS += Std.int(elapsedMS * playbackSpeed);
			lastLoop = loop;
			loop = timeMS / currentAnimation.length;
			
			if (currentAnimation.loopType == LOOPING)
			{
					
					normalizedTime = timeMS % currentAnimation.length;
					if (normalizedTime < 0)//backward
						normalizedTime += currentAnimation.length;
			
			}else{//no looping
					normalizedTime = Std.int(Math.max(0, Math.min(timeMS, currentAnimation.length)));
			}
		}
		//even if paused we need to draw it	
		currentAnimation.setCurrentTime(normalizedTime, library, scml, scml.entities[currentEntityName], info);
		//callback
		if (currentAnimation.loopType == LOOPING)
		{
			if (Std.int(loop) != Std.int(lastLoop) || (Std.int(loop) == 0 && !SpriterUtil.sameSign(lastLoop, loop))) {
				currentAnimation.resetMetaDispatch();	
				scml.onEndAnim();
			}
		}else {//no looping
			var when:Int = playbackSpeed > 0 ? currentAnimation.length : 0;
			if (normalizedTime == when)
				scml.onEndAnim();
		}
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
		scml.applyCharacterMap(name, reset, currentEntityName);
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
				scml.endAnimCallback = endAnimCallback.bind(this, currentEntityName, currentAnimationName);
				scml.endAnimRemoval = removeCallback;
			}
		}else if (scml.entities.get(currentEntityName).animations.exists(name)) {
			if (paused) 
				paused = false;
			resetTime();
			currentAnimationName = name;
			currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
			if (endAnimCallback != null) {
				scml.endAnimCallback = endAnimCallback.bind(this, currentEntityName, currentAnimationName);
				scml.endAnimRemoval = removeCallback;
			}
		}else {
			#if SPRITER_DEBUG
			trace('animation $name does not exist in entity $currentEntityName');
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
			currentEntityName = entity;
			if(anim != ''){
				if (scml.entities.get(currentEntityName).animations.exists(anim)) {
					currentAnimationName = anim;
					currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
				}else {
					#if SPRITER_DEBUG
					trace('animation $anim does not exist in entity $entity');
					#end
				}
			}
			if(endAnimCallback != null){
				scml.endAnimCallback = endAnimCallback.bind(this, currentEntityName, currentAnimationName);
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
		if (scml.entities.get(currentEntityName).animations.exists(names[0])) {
			if (paused) 
				paused = false;
			resetTime();
			currentAnimationName = names[0];
			currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
			scml.endAnimCallback = stackAnims.bind(names, 1, endAnimCallback);
			scml.endAnimRemoval = true;
		}else {
			#if SPRITER_DEBUG
			trace('animation ${names[0]} does not exist in entity $currentEntityName');
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
			currentEntityName = entity;
			if (scml.entities.get(currentEntityName).animations.exists(anims[0])) {
				currentAnimationName = anims[0];
				currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
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
			currentEntityName = entities[0];
			if (scml.entities.get(currentEntityName).animations.exists(anims[0])) {
				currentAnimationName = anims[0];
				currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
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
		if (scml.entities.get(currentEntityName).animations.exists(anims[nextAnim])) {
			if (paused) 
				paused = false;
			resetTime();
			currentAnimationName = anims[nextAnim];
			currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
		}
		#if SPRITER_DEBUG
		trace('stackAnims', currentAnimationName);
		#end
		//anim after next anim handler
		if (++nextAnim >= anims.length) {
			if(endAnimsCallback != null)
				scml.endAnimCallback = endAnimsCallback.bind(this, currentEntityName, currentAnimationName);
		}else {
				scml.endAnimCallback = stackAnims.bind(anims, nextAnim, endAnimsCallback);
		}
	}
	
	private function stackAnimsWithEntitiesChange(entities:Array<String>, anims:Array<String>, nextAnim:Int, endAnimsCallback:Spriter->String->String->Void):Void
	{
		if (scml.entities.exists(entities[nextAnim])) {
			currentEntityName = entities[nextAnim];
			if (scml.entities.get(currentEntityName).animations.exists(anims[nextAnim])) {
				if (paused) 
					paused = false;
				resetTime();
				currentAnimationName = anims[nextAnim];
				currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
			}
		}
		#if SPRITER_DEBUG
		trace('stackAnims', currentAnimationName);
		#end
		//anim after next anim handler
		if (++nextAnim >= anims.length) {
			if(endAnimsCallback != null)
				scml.endAnimCallback = endAnimsCallback.bind(this, currentEntityName, currentAnimationName);
		}else {
				scml.endAnimCallback = stackAnimsWithEntitiesChange.bind(entities, anims, nextAnim, endAnimsCallback);
		}
	}
	
	inline public function getBoxes():Array<Quadrilateral>
	{
		return currentAnimation.boxes;
	}
	inline public function getPoints():Array<SpatialInfo>
	{
		return currentAnimation.points;
	}
	public function getVariable(name:String):Variable<Dynamic>//TODO generic
	{
		for (currVar in scml.entities[currentEntityName].variables)
		{
			if (currVar.name == name)
				return currVar;
		}
		return null;
	}
	inline public function getVariableFromId(id:Int):Variable<Dynamic>//TODO generic
	{
		return scml.entities[currentEntityName].variables[id];
	}
	
	inline public function resetTime():Void
	{
		if (playbackSpeed > 0)
		{
			loop = lastLoop = normalizedTime = timeMS = 0;
		}else{
			loop = lastLoop = 1;
			normalizedTime = timeMS = currentAnimation.length;
		}
	}
	public function reverse(value:Bool = true):Spriter
	{
		if (value)
		{
			playbackSpeed = -1;
			resetTime();
		}else {
			playbackSpeed = 1;
			resetTime();
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