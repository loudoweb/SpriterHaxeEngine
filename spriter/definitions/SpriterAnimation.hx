package spriter.definitions;
import haxe.xml.Fast;
import spriter.definitions.SpriterAnimation.LoopType;
import spriter.definitions.SpriterTimeline.ObjectType;
import spriter.engine.Spriter;
import spriter.interfaces.IScml;
import spriter.library.AbstractLibrary;

/**
 * ...
 * @author Loudo
 */
enum LoopType
{
    LOOPING;
    NO_LOOPING;
}
 
class SpriterAnimation
{
	//spatial info cached and shared between all animations to avoid allocating new ones. Used by libraries to compute final coordinates and draw the object on the screen.
	static var _cachedSpatialInfo:SpatialInfo = new SpatialInfo();
	
	/*
	 * SCML definitions
	 */
	public var id:Int;
	public var name:String;
    public var length:Int;
    public var loopType:LoopType;
    public var mainlineKeys:Array<MainlineKey>;
    public var timelines:Array<SpriterTimeline>;
	
	#if !SPRITER_NO_TAG
	public var taglines:Array<TaglineKey>;
	#end
	#if !SPRITER_NO_VAR
	public var varlines:Array<Metaline<VarlineKey>>;
	#end
	#if !SPRITER_NO_EVENT
	public var eventlines:Array<Metaline<EventlineKey>>;
	#end
	#if !SPRITER_NO_SOUND
	public var soundlines:Array<Metaline<SoundlineKey>>;
	#end
	
	var _transformedBoneKeys:Array<SpatialInfo>;
	
	public function new(fast:Fast) 
	{
		mainlineKeys = [];
		timelines = [];
		_transformedBoneKeys = [];
		
		
		id = Std.parseInt(fast.att.id);
		name = fast.att.name;
		length = Std.parseInt(fast.att.length);
		//loopType = fast.has.looping ? Type.createEnum(LoopType, fast.att.looping.toUpperCase()) : LOOPING;
		if (fast.has.looping) {
			if (fast.att.looping == "true") {
				loopType = LOOPING;
			}else {
				loopType = NO_LOOPING;
			}
		}else {
			loopType = LOOPING;
		}
		
		for (mk in fast.node.mainline.nodes.key)
		{
			mainlineKeys.push(new MainlineKey(mk));
		}
		
		for (t in fast.nodes.timeline)
		{
			timelines.push(new SpriterTimeline(t));
		}
		#if !SPRITER_NO_SOUND
		if (fast.hasNode.soundline)
		{
			soundlines = [];
			for (tag in fast.nodes.soundline)
			{
				soundlines.push(new Metaline<SoundlineKey>(tag));
			}
		}
		#end
		#if !SPRITER_NO_EVENT
		if (fast.hasNode.eventline)
		{
			eventlines = [];
			for (tag in fast.nodes.eventline)
			{
				eventlines.push(new Metaline<EventlineKey>(tag));
			}
		}
		#end
		if (fast.hasNode.meta)
		{
			fast = fast.node.meta;
			#if !SPRITER_NO_TAG
			if (fast.hasNode.tagline)
			{
				taglines = [];
				for (tag in fast.node.tagline.nodes.key)
				{
					taglines.push(new TaglineKey(tag));
				}
			}
			#end
			#if !SPRITER_NO_VAR
			if (fast.hasNode.varline)
			{
				varlines = [];
				for (currVar in fast.nodes.varline)
				{
					varlines.push(new Metaline<VarlineKey>(currVar));
				}
			}
			#end
		}
	}
	/**
	 * 
	 * @param	newTime Use a time between [0,length]
	 * @param	library library to compute and draw the final graphics
	 * @param	root IScml to use some features
	 * @param	currentEntity to use some features
	 * @param	parentSpatialInfo SpatialInfo from the Spriter (positions, etc.)
	 */
	public function setCurrentTime(newTime:Int, elapsedTime:Int, library:AbstractLibrary, spriter:Spriter, root:IScml, currentEntity:SpriterEntity, parentSpatialInfo:SpatialInfo):Void
    {
		//update
		updateCharacter(mainlineKeyFromTime(newTime), newTime, elapsedTime, library, spriter, root, currentEntity, parentSpatialInfo);
    }

    public function updateCharacter(mainKey:MainlineKey, newTime:Int, elapsedTime:Int, library:AbstractLibrary, spriter:Spriter, root:IScml, currentEntity:SpriterEntity, parentSpatialInfo:SpatialInfo):Void
    {
		var currentKey:SpatialTimelineKey;
		var	currentRef:Ref;
		var spatialInfo:SpatialInfo = null;
		
		//BONES
		var len:Int = mainKey.boneRefs.length;
		ensureNumOfCachedTransformedBoneKeys(len);
		
        for (b in 0...len)
        {
            currentRef = mainKey.boneRefs[b];
			currentKey = cast keyFromRef(currentRef, newTime);
            if (currentRef.parent >= 0)
			{
                spatialInfo = _transformedBoneKeys[currentRef.parent];
            }
			else 
			{
				spatialInfo = parentSpatialInfo;
			}

            currentKey.info.unmapFromParent(spatialInfo, _transformedBoneKeys[b]);//update _transformedBoneKeys[b]
        }

        //POINTS/BOXES
		#if !SPRITER_NO_POINT
		if (spriter.points.length > 0)
			spriter.points.splice(0, spriter.points.length);//instead of creating an array each time, clear it
		#end
		#if !SPRITER_NO_BOX
		if (spriter.boxes.length > 0)
			spriter.boxes.splice(0, spriter.boxes.length);//instead of creating an array each time, clear it
		#end
			
		//TIMELINE KEYS
		len = mainKey.objectRefs.length;
        for(o in 0...len)
        {
            currentRef = mainKey.objectRefs[o];
			currentKey = cast keyFromRef(currentRef,newTime);
			//trace(currentKey.info.a);
            if(currentRef.parent >= 0)
            {
                spatialInfo = _transformedBoneKeys[currentRef.parent];
            }
            else
            {
                spatialInfo = parentSpatialInfo;
            }
			
			currentKey.info.unmapFromParent(spatialInfo, _cachedSpatialInfo);//update _cachedSpatialInfo
			
			var activePivots:PivotInfo;
			if (Std.is(currentKey, SpriteTimelineKey)) {
				var currentSpriteKey:SpriteTimelineKey = cast currentKey;
				//render from library
				var currentKeyName:String = spriter.getFileName(currentSpriteKey.folder, currentSpriteKey.file);
				if (currentKeyName != null) {//hidden object test (via mapping)
					activePivots = spriter.getPivots(currentSpriteKey.folder, currentSpriteKey.file);
					activePivots = currentKey.paint(activePivots);
					library.addGraphic(currentKeyName, _cachedSpatialInfo, activePivots);
				}
			}else if (Std.is(currentKey, SubEntityTimelineKey)){
				var currentSubKey:SubEntityTimelineKey = cast currentKey;
				root.setSubEntityCurrentTime(library, currentSubKey.t, currentSubKey.entity, currentSubKey.animation, _cachedSpatialInfo.copy(), spriter);
			}else {
				var currentObjectKey:ObjectTimelineKey = cast currentKey;
				
				if (currentObjectKey.type == ObjectType.POINT)
				{
					#if !SPRITER_NO_POINT
					activePivots = PivotInfo.DEFAULT;
					spriter.points.push(library.compute(_cachedSpatialInfo.copy(), activePivots, 0, 0));
					#end
				}else {//BOX
					#if !SPRITER_NO_BOX
					activePivots = new PivotInfo();//default pivot, but need to be overrided
					activePivots = currentKey.paint(activePivots);
					var currentBox:SpriterBox = currentEntity.boxes_info.get(getTimelineName(currentRef.timeline));
					spriter.boxes.push(library.computeRectCoordinates(_cachedSpatialInfo, activePivots, currentBox.width, currentBox.height));
					#end
				}
			}
			

            //objectKeys.push(currentKey);
        }

        //SCML REF : <expose objectKeys to api users to retrieve AND replace objectKeys>
		//(devnote :I'm not doing that, instead I add directly the element in the library (since libraries compute differently))
		
		/*len = objectKeys.length;
        for(k in 0...len)
        {            
            objectKeys[k].paint();
        }*/
		
		//following lines not in scml references yet
		#if !SPRITER_NO_TAG
		if (taglines != null)
		{
			for (tag in taglines)
			{
				if (isTriggered(tag.time, mainKey.time, newTime, elapsedTime))
				{
					spriter.clearTag();
					for (i in 0...tag.t.length)
					{
						spriter.addTag(tag.t[i]);
					}
					break;
				}
			}
		}
		#end
		#if !SPRITER_NO_VAR
		if (varlines != null)
		{
			for (_var in varlines)
			{
				for (keyVar in _var.keys)
				{
					if (isTriggered(keyVar.time, mainKey.time, newTime, elapsedTime))
					{
						spriter.updateVar(_var.id, keyVar.value);
					}
				}
			}
		}
		#end
		#if !SPRITER_NO_SOUND
		if (soundlines != null)
		{
			for (sound in soundlines)
			{
				for (soundKey in sound.keys)
				{
					if (isTriggered(soundKey.time, mainKey.time, newTime, elapsedTime))
					{
						spriter.dispatchSound(soundKey.folder, soundKey.file);
					}
				}
			}
		}
		#end
		#if !SPRITER_NO_EVENT
		if (eventlines != null)
		{
			for (event in eventlines)
			{
				for (eventKey in event.keys)
				{
					if (isTriggered(eventKey.time, mainKey.time, newTime, elapsedTime))
					{
						spriter.dispatchEvent(event.name);	
					}
				}
			}
		}
		#end
		//clean up
		spatialInfo = null;
    }
	
	inline function isTriggered(triggerTime:Int, keyTime:Int, newTime:Int, elapsedTime:Int):Bool
	{
		if (triggerTime == keyTime)
		{
			if (newTime - elapsedTime < keyTime)
			{
				return true;
			}else if (triggerTime == 0 && newTime == elapsedTime) { //allow to trigger the first frame
				return true;
			}else {
				return false;
			}
		}else {
			return false;
		}
	}
	
	inline function ensureNumOfCachedTransformedBoneKeys(num:Int):Void {
		if (num <= _transformedBoneKeys.length) return;
		for (i in _transformedBoneKeys.length...num) {
			_transformedBoneKeys.push(new SpatialInfo());
		}
	}

    public function mainlineKeyFromTime(time:Int):MainlineKey
    {
        var	currentMainKey:Int = 0;
		var len:Int = mainlineKeys.length;
		for (m in 0...len)
		{
			if(mainlineKeys[m].time <= time)
			{
				currentMainKey = m;
			}
			
			if(mainlineKeys[m].time >= time)
			{
				break;
			}
		}
		
		return mainlineKeys[currentMainKey];
    }	
   
    public function keyFromRef(ref:Ref, newTime:Int):TimelineKey
    {
        var timeline:SpriterTimeline = timelines[ref.timeline];
        var keyA:TimelineKey = timeline.keys[ref.key];
        
        if(timeline.keys.length == 1 || keyA.curveType == INSTANT)
        {
			return keyA;
        }
        
        var nextKeyIndex:Int = ref.key + 1;
        
        if(nextKeyIndex >= timeline.keys.length)
        {
            if(loopType == LOOPING)
            {
                nextKeyIndex = 0; 
            }
            else
            {
                return keyA;
            }
        }
  
        var keyB:TimelineKey = timeline.keys[nextKeyIndex];
        var keyBTime:Int = keyB.time;
		//this line is for interpolation between last key and first key when looping //TOCHECK when backward animation
        if(keyBTime < keyA.time)
        {
            keyBTime = keyBTime+length;
        }
		keyA = keyA.copy();
        keyA.interpolate(keyB, keyBTime, newTime);
		return keyA;
    }
	
	private function getTimelineName(id:Int):String
	{
		return timelines[id].name;
	}
	
}