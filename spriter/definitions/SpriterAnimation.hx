package spriter.definitions;
import haxe.xml.Access;
import spriter.definitions.SpriterAnimation.LoopType;
import spriter.definitions.SpriterTimeline.ObjectType;
import spriter.engine.Spriter;
import spriter.library.AbstractLibrary;
import spriter.util.SpriterUtil;

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
	static var _cachedTK:TimelineKey = TimelineKey.createDefault();
	static var _cachedTransformedBoneKeys:Array<SpatialInfo> = [];
	
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
	
	
	
	public function new(xml:Access) 
	{
		mainlineKeys = [];
		timelines = [];
		
		
		id = Std.parseInt(xml.att.id);
		name = xml.att.name;
		length = Std.parseInt(xml.att.length);
		//loopType = xml.has.looping ? Type.createEnum(LoopType, xml.att.looping.toUpperCase()) : LOOPING;
		if (xml.has.looping) {
			if (xml.att.looping == "true") {
				loopType = LOOPING;
			}else {
				loopType = NO_LOOPING;
			}
		}else {
			loopType = LOOPING;
		}
		
		for (mk in xml.node.mainline.nodes.key)
		{
			mainlineKeys.push(new MainlineKey(mk));
		}
		
		for (t in xml.nodes.timeline)
		{
			timelines.push(new SpriterTimeline(t));
		}
		#if !SPRITER_NO_SOUND
		if (xml.hasNode.soundline)
		{
			soundlines = [];
			for (tag in xml.nodes.soundline)
			{
				soundlines.push(new Metaline<SoundlineKey>(tag));
			}
		}
		#end
		#if !SPRITER_NO_EVENT
		if (xml.hasNode.eventline)
		{
			eventlines = [];
			for (tag in xml.nodes.eventline)
			{
				eventlines.push(new Metaline<EventlineKey>(tag));
			}
		}
		#end
		if (xml.hasNode.meta)
		{
			xml = xml.node.meta;
			#if !SPRITER_NO_TAG
			if (xml.hasNode.tagline)
			{
				taglines = [];
				for (tag in xml.node.tagline.nodes.key)
				{
					taglines.push(new TaglineKey(tag));
				}
			}
			#end
			#if !SPRITER_NO_VAR
			if (xml.hasNode.varline)
			{
				varlines = [];
				for (currVar in xml.nodes.varline)
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
	inline public function setCurrentTime(newTime:Int, elapsedTime:Int, library:AbstractLibrary, spriter:Spriter, currentEntity:SpriterEntity, parentSpatialInfo:SpatialInfo):Void
    {
		//update
		updateCharacter(mainlineKeyFromTime(newTime), newTime, elapsedTime, library, spriter, currentEntity, parentSpatialInfo);
    }

    public function updateCharacter(mainKey:MainlineKey, newTime:Int, elapsedTime:Int, library:AbstractLibrary, spriter:Spriter, currentEntity:SpriterEntity, parentSpatialInfo:SpatialInfo):Void
    {
		var currentKey:TimelineKey;
		var	currentRef:Ref;
		var spatialInfo:SpatialInfo = null;
		
		//BONES
		var len:Int = mainKey.boneRefs.length;
		ensureNumOfCachedTransformedBoneKeys(len);
		
        for (b in 0...len)
        {
            currentRef = mainKey.boneRefs[b];
			currentKey = keyFromRef(currentRef, newTime, spriter);
            if (currentRef.parent >= 0)
			{
                spatialInfo = _cachedTransformedBoneKeys[currentRef.parent];
            }
			else 
			{
				spatialInfo = parentSpatialInfo;
			}

            currentKey.info.unmapFromParent(spatialInfo, _cachedTransformedBoneKeys[b]);//update _transformedBoneKeys[b]
        }

        //POINTS/BOXES
		#if !SPRITER_NO_POINT
		SpriterUtil.clearArray(spriter.points);//instead of creating an array each time, clear it
		#end
		#if !SPRITER_NO_BOX
		SpriterUtil.clearArray(spriter.boxes);//instead of creating an array each time, clear it
		#end
			
		//TIMELINE KEYS
		len = mainKey.objectRefs.length;
        for(o in 0...len)
        {
            currentRef = mainKey.objectRefs[o];
			currentKey = keyFromRef(currentRef, newTime, spriter);
			//trace(currentKey.info.a);
            if(currentRef.parent >= 0)
            {
                spatialInfo = _cachedTransformedBoneKeys[currentRef.parent];
            }
            else
            {
                spatialInfo = parentSpatialInfo;
            }
			
			currentKey.info.unmapFromParent(spatialInfo, _cachedSpatialInfo);//update _cachedSpatialInfo
			
			if (currentKey.objectType == SPRITE) {
				
				//render from library
				var currentKeyName:String = spriter.getFileName(currentKey.sprite.folder, currentKey.sprite.file);
				if (currentKeyName != null) {//hidden object test (via mapping)
					library.addGraphic(currentKeyName, _cachedSpatialInfo, currentKey.pivots);
				}
				
			}else if(currentKey.objectType == ENTITY) {
				
				spriter.setSubEntityCurrentTime(currentKey.subentity.t, currentKey.subentity.entity, currentKey.subentity.animation, _cachedSpatialInfo.copy());
				
			}
			#if !SPRITER_NO_POINT
			else if(currentKey.objectType == POINT){
				
					currentKey.pivots.setToDefault();
					spriter.points.push(library.compute(_cachedSpatialInfo.copy(), currentKey.pivots, 0, 0));
					
			}
			#end
			#if !SPRITER_NO_BOX
			else if(currentKey.objectType == BOX){
					
				var currentBox:SpriterBox = currentEntity.boxes_info.get(getTimelineName(currentRef.timeline));
				spriter.boxes.push(library.computeRectCoordinates(_cachedSpatialInfo, currentKey.pivots, currentBox.width, currentBox.height));
					
			}
			#end
			

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
	
	function isTriggered(triggerTime:Int, keyTime:Int, newTime:Int, elapsedTime:Int):Bool
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
		if (num <= _cachedTransformedBoneKeys.length) return;
		for (i in _cachedTransformedBoneKeys.length...num) {
			_cachedTransformedBoneKeys.push(new SpatialInfo());
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
   
    public function keyFromRef(ref:Ref, newTime:Int, spriter:Spriter):TimelineKey
    {
        var timeline:SpriterTimeline = timelines[ref.timeline];
        var keyA:TimelineKey = timeline.keys[ref.key];
		keyA.clone(_cachedTK);
        
        if(timeline.keys.length == 1 || keyA.curveType == INSTANT)
        {
			_cachedTK.writeDefaultPivots(spriter);
			return _cachedTK;
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
				_cachedTK.writeDefaultPivots(spriter);
                return _cachedTK;
            }
        }
  
        var keyB:TimelineKey = timeline.keys[nextKeyIndex];
        var keyBTime:Int = keyB.time;
		//this line is for interpolation between last key and first key when looping
        if(keyBTime < keyA.time)
        {
            keyBTime = keyBTime+length;
        }
		
		_cachedTK.interpolate(keyB, keyBTime, newTime, spriter);
		return _cachedTK;
    }
	
	inline function getTimelineName(id:Int):String
	{
		return timelines[id].name;
	}
	
}