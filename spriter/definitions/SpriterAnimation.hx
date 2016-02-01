package spriter.definitions;
import haxe.xml.Fast;
import spriter.definitions.Quadrilateral;
import spriter.definitions.SpriterAnimation.LoopType;
import spriter.definitions.SpriterTimeline.ObjectType;
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
	/*
	 * SCML definitions
	 */
	public var id:Int;
	public var name:String;
    public var length:Int;
    public var loopType:LoopType;
    public var mainlineKeys:Array<MainlineKey>;
    public var timelines:Array<SpriterTimeline>;
	public var taglines:Array<TaglineKey>;
	public var varlines:Array<Varline>;
	var _transformedBoneKeys:Array<SpatialInfo>;
	
	/*
	 * Custom definitions
	 * 
	 */
	var loop:Int = 0;
	public var points:Array<SpatialInfo>;
	public var boxes:Array<Quadrilateral>;
	
	//spatial info cached and shared between all animations to avoid allocating new ones. Used by libraries to compute final coordinates and draw the object on the screen.
	static var _cachedSpatialInfo:SpatialInfo = new SpatialInfo();
	
	public function new(fast:Fast) 
	{
		mainlineKeys = [];
		timelines = [];
		_transformedBoneKeys = [];
		points = [];
		boxes = [];
		
		
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
		if (fast.hasNode.meta)
		{
			fast = fast.node.meta;
			if (fast.hasNode.tagline)
			{
				taglines = [];
				for (tag in fast.node.tagline.nodes.key)
				{
					taglines.push(new TaglineKey(tag));
				}
			}
			if (fast.hasNode.varline)
			{
				varlines = [];
				for (currVar in fast.nodes.varline)
				{
					varlines.push(new Varline(currVar));
				}
			}
			
		}
	}
	
	public function setCurrentTime(newTime:Int, library:AbstractLibrary, root:IScml, currentEntity:SpriterEntity, parentSpatialInfo:SpatialInfo):Void
    {
		var currentTime:Int;
		var tempLoop:Int;
		switch(loopType)
        {
			case LOOPING:
				tempLoop = loop;
				loop = Std.int(newTime / length);
				currentTime = newTime % length;
				//update
				updateCharacter(mainlineKeyFromTime(currentTime), currentTime, library, root, currentEntity, parentSpatialInfo);
				if (root.metaDispatch == ONCE_PER_LOOP && tempLoop != loop) {
					resetMetaDispatch();
				}
				//callback only at the first loop and once
				if (loop == 1 && tempLoop < 1)
					root.onEndAnim();
				
			case NO_LOOPING:
				currentTime = Std.int(Math.min(newTime, length));
				//update
				updateCharacter(mainlineKeyFromTime(currentTime), currentTime, library, root, currentEntity, parentSpatialInfo);
				//callback
				if (currentTime == length)
					root.onEndAnim();
        }
    }

    public function updateCharacter(mainKey:MainlineKey, newTime:Int, library:AbstractLibrary, root:IScml, currentEntity:SpriterEntity, parentSpatialInfo:SpatialInfo):Void
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
		if (points.length > 0)
			points.splice(0, points.length);//instead of creating an array each time, clear it
		if (boxes.length > 0)
			boxes.splice(0, boxes.length);//instead of creating an array each time, clear it
			
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
				var currentKeyName:String = root.getFileName(currentSpriteKey.folder, currentSpriteKey.file);
				if (currentKeyName != null) {//hidden object test (via mapping)
					activePivots = root.getPivots(currentSpriteKey.folder, currentSpriteKey.file);
					activePivots = currentKey.paint(activePivots);
					library.addGraphic(currentKeyName, _cachedSpatialInfo, activePivots);
				}
			}else if (Std.is(currentKey, SubEntityTimelineKey)){
				var currentSubKey:SubEntityTimelineKey = cast currentKey;
				root.setSubEntityCurrentTime(library, currentSubKey.t, currentSubKey.entity, currentSubKey.animation, _cachedSpatialInfo);
			}else {
				var currentObjectKey:ObjectTimelineKey = cast currentKey;
				
				if (currentObjectKey.type == ObjectType.POINT)
				{
					activePivots = PivotInfo.DEFAULT;
					points.push(library.compute(_cachedSpatialInfo.copy(), activePivots, 0, 0));
				}else {//BOX
					activePivots = new PivotInfo();//default pivot, but need to be overrided
					activePivots = currentKey.paint(activePivots);
					var currentBox:SpriterBox = currentEntity.boxes_info.get(getTimelineName(currentRef.timeline));
					boxes.push(library.computeRectCoordinates(_cachedSpatialInfo, activePivots, currentBox.width, currentBox.height));
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
		
		if(taglines != null){
			for (tag in taglines) {
				if (tag.time == mainKey.time)
				{
					if (root.metaDispatch == ALWAYS)
					{
						root.onTag(tag.id);
					}else if (root.metaDispatch == ONCE_PER_LOOP && mainKey.time != tag.lastDispatched) {
						tag.lastDispatched = mainKey.time;
						root.onTag(tag.id);
					}else if (root.metaDispatch == ONCE && !tag.dispatched) {
						tag.lastDispatched = mainKey.time;
						root.onTag(tag.id);
					}
				}
			}
		}
		if (varlines != null)
		{
			for (_var in varlines) {
				for (keyVar in _var.keys)
				{
					if (keyVar.time == mainKey.time)
					{
						if (root.metaDispatch == ALWAYS)
						{
							root.onVar(_var.id, keyVar.value);
						}else if (root.metaDispatch == ONCE_PER_LOOP && mainKey.time != keyVar.lastDispatched) {
							keyVar.lastDispatched = mainKey.time;
							root.onVar(_var.id, keyVar.value);
						}else if (root.metaDispatch == ONCE && !keyVar.dispatched) {
							keyVar.lastDispatched = mainKey.time;
							root.onVar(_var.id, keyVar.value);
						}
					}
				}
			}
		}
		//clean up
		spatialInfo = null;
    }
	
	private inline function ensureNumOfCachedTransformedBoneKeys(num:Int):Void {
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
	
	private function resetMetaDispatch():Void
	{
		if(taglines != null){
			for (tag in taglines) {
				tag.dispatched = false;
			}
		}
	}
	
}