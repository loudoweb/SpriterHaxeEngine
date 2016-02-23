package spriter.engine;
import spriter.definitions.CharacterMap;
import spriter.definitions.MapInstruction;
import spriter.definitions.PivotInfo;
import spriter.definitions.Quadrilateral;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.definitions.SpriterAnimation;
import spriter.definitions.SpriterEntity;
import spriter.definitions.SpriterFile;
import spriter.definitions.SpriterFolder;
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
	
	//Removable features
	#if !SPRITER_NO_EVENT
	public var onEvent:String->Void;
	#end
	#if !SPRITER_NO_SOUND
	public var onSound:String->Void;
	#end
	#if !SPRITER_NO_POINT
	public var points:Array<SpatialInfo>;
	#end
	#if !SPRITER_NO_BOX
	public var boxes:Array<Quadrilateral>;
	#end
	#if !SPRITER_NO_TAG
	public var tags:Array<String>;
	#end
	#if !SPRITER_NO_VAR
	public var onVarChanged:String->Dynamic->Void;
	var variables:Array<Dynamic>;
	#end
	
	var activeCharacterMap:Array<SpriterFolder>;
	
	var loop:Float = 0;
	var lastLoop:Float = 0;
	var normalizedTime:Int = 0;
	var currentAnimation:SpriterAnimation;
	var currentEntity:SpriterEntity;
	/**
	 * Callback called at the end of the anim
	 */
	var onComplete:Void->Void;
	/**
	 * Auto Remove the callback at the end of the anim
	 */
	var onCompleteOnce:Bool = true;
	
	//Optional features
	#if SPRITER_CUSTOM_MAP
	var _customMap:Map<String, CustomCharMap>;
	#end
	
	
	public function new(_name:String, _scml:ScmlObject, _library:AbstractLibrary, _info:SpatialInfo) 
	{
		this.scml 	= _scml;
		this.library = _library;
		this.spriterName = _name;
		this.currentEntityName = scml.defaultEntity;
		this.currentAnimationName = scml.defaultAnimation;
		this.currentEntity = scml.entities.get(currentEntityName);
		this.currentAnimation = currentEntity.animations.get(currentAnimationName);
		this.info = _info;
		#if !SPRITER_NO_POINT
		this.points = [];
		#end
		#if !SPRITER_NO_BOX
		this.boxes = [];
		#end
		#if !SPRITER_NO_TAG
		this.tags = [];
		#end
		#if !SPRITER_NO_VAR
		this.variables = [];
		#end
		
		this.activeCharacterMap = this.scml.copyFolders();
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
		currentAnimation.setCurrentTime(normalizedTime, Std.int(elapsedMS * playbackSpeed), library, this, scml, scml.entities[currentEntityName], info);
		//callback
		if (currentAnimation.loopType == LOOPING)
		{
			if (Std.int(loop) != Std.int(lastLoop) || (Std.int(loop) == 0 && !SpriterUtil.sameSign(lastLoop, loop))) {
				dispatchComplete();
			}
		}else {//no looping
			var when:Int = playbackSpeed > 0 ? currentAnimation.length : 0;
			if (normalizedTime == when)
				dispatchComplete();
		}
	}
	/**
	 * Apply character mapping to change an element in the animation.
	 * @param	name of the character map in the xml
	 * @param	reset to apply only the new character map, if not, you can have multiple character map at the same time. Default is false.
	 * @return  this
	 */
	public function applyCharacterMap(name:String, reset:Bool = false):Spriter
	{
		if (reset){
			activeCharacterMap = scml.copyFolders();
		}
		#if SPRITER_CUSTOM_MAP
		if (_customMap != null && _customMap.exists(name))
		{
			var currentMap = _customMap.get(name);
			for (i in currentMap.folder...currentMap.folder + currentMap.length)
			{
				for (j in 0...activeCharacterMap[i].files.length) 
				{
					activeCharacterMap[i].files[j].name = StringTools.replace(activeCharacterMap[i].files[j].name, currentMap.sub, currentMap.by);
				}
			}
		}else{
		#end
			if (currentEntity.characterMaps.exists(name)) {
				
				var charMap:CharacterMap = currentEntity.characterMaps.get(name);
				
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
				this.onComplete = endAnimCallback.bind(this);
				this.onCompleteOnce = removeCallback;
			}
		}else if (scml.entities.get(currentEntityName).animations.exists(name)) {
			if (paused) 
				paused = false;
			resetTime();
			currentAnimationName = name;
			currentAnimation = currentEntity.animations.get(currentAnimationName);
			if (endAnimCallback != null) {
				this.onComplete = endAnimCallback.bind(this);
				this.onCompleteOnce = removeCallback;
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
			currentEntity = scml.entities.get(currentEntityName);
			if(anim != ''){
				if (currentEntity.animations.exists(anim)) {
					currentAnimationName = anim;
					currentAnimation = currentEntity.animations.get(currentAnimationName);
				}else {
					#if SPRITER_DEBUG
					trace('animation $anim does not exist in entity $entity');
					#end
				}
			}
			if(endAnimCallback != null){
				this.onComplete = endAnimCallback.bind(this);
				this.onCompleteOnce = removeCallback;
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
		if (currentEntity.animations.exists(names[0])) {
			if (paused) 
				paused = false;
			resetTime();
			currentAnimationName = names[0];
			currentAnimation = currentEntity.animations.get(currentAnimationName);
			this.onComplete = stackAnims.bind(names, 1, endAnimCallback);
			this.onCompleteOnce = true;
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
			currentEntity = scml.entities.get(currentEntityName);
			if (currentEntity.animations.exists(anims[0])) {
				currentAnimationName = anims[0];
				currentAnimation = currentEntity.animations.get(currentAnimationName);
			}
			this.onComplete = stackAnims.bind(anims, 1, endAnimCallback);
			this.onCompleteOnce = true;
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
			currentEntity = scml.entities.get(currentEntityName);
			if (currentEntity.animations.exists(anims[0])) {
				currentAnimationName = anims[0];
				currentAnimation = currentEntity.animations.get(currentAnimationName);
			}
			this.onComplete = stackAnimsWithEntitiesChange.bind(entities , anims, 1, endAnimCallback);
			this.onCompleteOnce = true;
			return true;
		}else {
			return false;
		}
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
		onComplete = reflectOnEndAnim.bind(onComplete);
		onCompleteOnce = true;
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
	
	#if !SPRITER_NO_SOUND
	@:noCompletion
	inline public function dispatchSound(folder:Int, file:Int):Void
	{
		if(onSound != null)
			onSound(scml.folders[folder].files[file].name);
	}
	#end
	
	#if !SPRITER_NO_EVENT
	@:noCompletion
	inline public function dispatchEvent(name:String):Void
	{
		if(onEvent != null)
			onEvent(name);
	}
	#end
	
	#if !SPRITER_NO_TAG
	@:noCompletion
	inline public function clearTag():Void
	{
		if (tags.length > 0)
			tags.splice(0, tags.length);//instead of creating an array each time, clear it
	}
	@:noCompletion
	inline public function addTag(t:Int):Void
	{
		tags.push(scml.tags[t]);
	}
	#end
	
	#if !SPRITER_NO_VAR
	@:noCompletion
	public function updateVar(id:Int, value:String):Void
	{
		var variable:Variable<Dynamic> = currentEntity.variables[id];
		
		var temp:Dynamic = variable.convert(value);
		var changed:Bool = false;
		
		if (variables.length > id)
		{
			if (variables[id] != temp)
			{
				variables[id] = temp;
				changed = true;
			}
		}else {
			for (i in variables.length...id)
			{
				variables[i] = i == id ? temp : null;
			}
			changed = true;
		}
		
		
		if (onVarChanged != null && changed) {
			onVarChanged(variable.name, temp);
		}
	}
	
	public function getPivots(folder:Int, file:Int):PivotInfo
	{
		var currentFile:SpriterFile = activeCharacterMap[folder].files[file];
		if(currentFile != null){
			return new PivotInfo(currentFile.pivotX, currentFile.pivotY);
		}else {
			return null;
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
	
	public function getVariable(name:String):Dynamic
	{
		for (i in 0...currentEntity.variables.length)
		{
			if (currentEntity.variables[i].name == name)
				return variables[i];
		}
		return null;
	}
	
	inline public function getVariableFromId(id:Int):Dynamic
	{
		return variables[id];
	}
	#end
	
	function dispatchComplete():Void
	{
		if (onComplete != null) {
			var tempCallback:Void->Void = onComplete;
			if (onCompleteOnce)
				onComplete = null;
			tempCallback();
		}
	}
	
	function stackAnims(anims:Array<String>, nextAnim:Int, endAnimsCallback:Spriter->Void):Void
	{
		if (currentEntity.animations.exists(anims[nextAnim])) {
			if (paused) 
				paused = false;
			resetTime();
			currentAnimationName = anims[nextAnim];
			currentAnimation = currentEntity.animations.get(currentAnimationName);
		}
		#if SPRITER_DEBUG
		trace('stackAnims', currentAnimationName);
		#end
		//anim after next anim handler
		if (++nextAnim >= anims.length) {
			if(endAnimsCallback != null)
				this.onComplete = endAnimsCallback.bind(this);
		}else {
				this.onComplete = stackAnims.bind(anims, nextAnim, endAnimsCallback);
		}
	}
	
	function stackAnimsWithEntitiesChange(entities:Array<String>, anims:Array<String>, nextAnim:Int, endAnimsCallback:Spriter->Void):Void
	{
		if (scml.entities.exists(entities[nextAnim])) {
			currentEntityName = entities[nextAnim];
			currentEntity = scml.entities.get(currentEntityName);
			if (currentEntity.animations.exists(anims[nextAnim])) {
				if (paused) 
					paused = false;
				resetTime();
				currentAnimationName = anims[nextAnim];
				currentAnimation = currentEntity.animations.get(currentAnimationName);
			}
		}
		#if SPRITER_DEBUG
		trace('stackAnims', currentAnimationName);
		#end
		//anim after next anim handler
		if (++nextAnim >= anims.length) {
			if(endAnimsCallback != null)
				this.onComplete = endAnimsCallback.bind(this);
		}else {
				this.onComplete = stackAnimsWithEntitiesChange.bind(entities, anims, nextAnim, endAnimsCallback);
		}
	}
	function reflectOnEndAnim(callback:Void->Void):Void
	{
		playbackSpeed = -playbackSpeed;
		onComplete = callback;
		onComplete();
		reflect();
	}
}