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
	
	public var currentEntityName(default, null):String 	= ""; 
    public var currentAnimationName(default, null):String  = "";
	
	var loop:Float = 0;
	var lastLoop:Float = 0;
	var normalizedTime:Int = 0;
	var currentAnimation:SpriterAnimation;
	/**
	 * Callback called at the end of the anim
	 */
	var endAnimCallback:Void->Void;
	/**
	 * Auto Remove the callback at the end of the anim
	 */
	var endAnimRemoval:Bool = true;
	
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
				onComplete();
			}
		}else {//no looping
			var when:Int = playbackSpeed > 0 ? currentAnimation.length : 0;
			if (normalizedTime == when)
				onComplete();
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
	public function playAnim(?name:String, ?endAnimCallback:Spriter->Void, removeCallback:Bool = true):Spriter
	{
		if (name == null) {
			if (paused) 
				paused = false;
			resetTime();
			if (endAnimCallback != null) {
				this.endAnimCallback = endAnimCallback.bind(this);
				this.endAnimRemoval = removeCallback;
			}
		}else if (scml.entities.get(currentEntityName).animations.exists(name)) {
			if (paused) 
				paused = false;
			resetTime();
			currentAnimationName = name;
			currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
			if (endAnimCallback != null) {
				this.endAnimCallback = endAnimCallback.bind(this);
				this.endAnimRemoval = removeCallback;
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
	public function playAnimFromEntity(entity:String, anim:String = '', ?endAnimCallback:Spriter->Void, removeCallback:Bool = true):Spriter
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
				this.endAnimCallback = endAnimCallback.bind(this);
				this.endAnimRemoval = removeCallback;
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
	public function playAnimsStack(names:Array<String>, ?endAnimCallback:Spriter->Void):Spriter
	{
		if (scml.entities.get(currentEntityName).animations.exists(names[0])) {
			if (paused) 
				paused = false;
			resetTime();
			currentAnimationName = names[0];
			currentAnimation = scml.entities.get(currentEntityName).animations.get(currentAnimationName);
			this.endAnimCallback = stackAnims.bind(names, 1, endAnimCallback);
			this.endAnimRemoval = true;
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
	public function playAnimsStackFromEntity(entity:String, anims:Array<String>, ?endAnimCallback:Spriter->Void):Bool
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
			this.endAnimCallback = stackAnims.bind(anims, 1, endAnimCallback);
			this.endAnimRemoval = true;
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
	public function playAnimsStackFromEntities(entities:Array<String>, anims:Array<String>, ?endAnimCallback:Spriter->Void):Bool
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
			this.endAnimCallback = stackAnimsWithEntitiesChange.bind(entities , anims, 1, endAnimCallback);
			this.endAnimRemoval = true;
			return true;
		}else {
			return false;
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
	public function reflect():Spriter
	{
		endAnimCallback = reflectOnEndAnim.bind(endAnimCallback);
		endAnimRemoval = true;
		return this;
	}
	/**
	 * Set positions of the Spriter
	 * @param	x
	 * @param	y (spriter uses inverted y, so it will automatically inverted in this function)
	 */
	public function set(x:Float, y:Float):Spriter
	{
		//-y because use inverted y coordinates
		info.setPos(x, -y);
		return this;
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
	
	function onComplete():Void
	{
		if (endAnimCallback != null) {
			var tempCallback:Void->Void = endAnimCallback;
			if (endAnimRemoval)
				endAnimCallback = null;
			tempCallback();
		}
	}
	
	function stackAnims(anims:Array<String>, nextAnim:Int, endAnimsCallback:Spriter->Void):Void
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
				this.endAnimCallback = endAnimsCallback.bind(this);
		}else {
				this.endAnimCallback = stackAnims.bind(anims, nextAnim, endAnimsCallback);
		}
	}
	
	function stackAnimsWithEntitiesChange(entities:Array<String>, anims:Array<String>, nextAnim:Int, endAnimsCallback:Spriter->Void):Void
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
				this.endAnimCallback = endAnimsCallback.bind(this);
		}else {
				this.endAnimCallback = stackAnimsWithEntitiesChange.bind(entities, anims, nextAnim, endAnimsCallback);
		}
	}
	function reflectOnEndAnim(callback:Void->Void):Void
	{
		playbackSpeed = -playbackSpeed;
		endAnimCallback = callback;
		onComplete();
		reflect();
	}
}