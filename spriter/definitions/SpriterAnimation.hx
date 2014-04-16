package spriter.definitions;
import haxe.xml.Fast;
import spriter.definitions.SpriterAnimation.LoopType;
import spriter.interfaces.IScml;
import spriter.library.AbstractLibrary;
import spriter.library.SpriterLibrary;

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
	public var id:Int;
	public var name:String;
    public var length:Int;
    public var loopType:LoopType;
    public var mainlineKeys:Array<MainlineKey>;
    public var timelines:Array<SpriterTimeline>;
	
	private var _library:SpriterLibrary;
	
	/**
	 * 
	 * 
	 * @param	root SpatialInfo for the root of the Spriter Animation
	 */
	public function new(fast:Fast) 
	{
		mainlineKeys = new Array<MainlineKey>();
		timelines = new Array<SpriterTimeline>();
		
		
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
	}
	
	public function setCurrentTime(newTime:Int, library:AbstractLibrary, root:IScml):Void
    {
		var currentTime:Int;
		var loop:Int;
		switch(loopType)
        {
        case LOOPING:
            loop = Std.int(newTime / length);
			currentTime = newTime % length;
			//callback
			if (loop == 1)
				root.onEndAnim(name);
			
        case NO_LOOPING:
            currentTime = Std.int(Math.min(newTime, length));
			//callback
			if (currentTime == length)
				root.onEndAnim(name);
        }

        updateCharacter(mainlineKeyFromTime(currentTime), currentTime, library, root);
    }

    public function updateCharacter(mainKey:MainlineKey, newTime:Int, library:AbstractLibrary, root:IScml):Void
    {
        var transformedBoneKeys:Array<SpatialInfo> = new Array<SpatialInfo>();
		var currentKey:SpatialTimelineKey;
		
		var	currentRef:Ref;
		var spatialInfo:SpatialInfo;
		var len:Int = mainKey.boneRefs.length;
        for (b in 0...len)
        {
            currentRef = mainKey.boneRefs[b];
			currentKey = cast keyFromRef(currentRef, newTime);
            if (currentRef.parent >= 0)
			{
                spatialInfo = transformedBoneKeys[currentRef.parent];
            }
			else 
			{
				spatialInfo = root.characterInfo();
			}

            spatialInfo = currentKey.info.unmapFromParent(spatialInfo);
            transformedBoneKeys.push(spatialInfo);
        }

        //var objectKeys:Array<TimelineKey>;
		len = mainKey.objectRefs.length;
        for(o in 0...len)
        {
            currentRef = mainKey.objectRefs[o];
			currentKey = cast keyFromRef(currentRef,newTime);
			//trace(currentKey.info.a);
            if(currentRef.parent >= 0)
            {
                spatialInfo = transformedBoneKeys[currentRef.parent];
            }
            else
            {
                spatialInfo = root.characterInfo();
            }
			
		    //currentKey.info = currentKey.info.unmapFromParent(parentInfo);//TOFIX and remove next line ?
			spatialInfo = currentKey.info.unmapFromParent(spatialInfo);
			var activePivots:PivotInfo;
			if (Std.is(currentKey, SpriteTimelineKey)) {
				var currentSpriteKey:SpriteTimelineKey = cast(currentKey, SpriteTimelineKey);
				activePivots = root.getPivots(currentSpriteKey.folder, currentSpriteKey.file);
				activePivots = currentKey.paint(activePivots.pivotX, activePivots.pivotY);
				//render from library
				var currentKeyName:String = root.getFileName(currentSpriteKey.folder, currentSpriteKey.file);
				if (currentKeyName != null) {//hidden object test (via mapping)
					library.addGraphic(root.getSpriterName(), currentRef.timeline, currentRef.key, currentKeyName, spatialInfo, activePivots);
				}
			}else {
				activePivots = new PivotInfo();
				currentKey.paint(activePivots.pivotX, activePivots.pivotY);//TODO
			}
			

            //objectKeys.push(currentKey);
        }

        //SCML REF : <expose objectKeys to api users to retrieve AND replace objectKeys>
		
		/*len = objectKeys.length;
        for(k in 0...len)
        {            
            objectKeys[k].paint();
        }*/
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
        var keyA:TimelineKey = timeline.keys[ref.key].copy();
        
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
  
        var keyB:TimelineKey = timeline.keys[nextKeyIndex].copy();
        var keyBTime:Int = keyB.time;

        if(keyBTime < keyA.time)
        {
            keyBTime = keyBTime+length;
        }
		
        keyA.interpolate(keyB, keyBTime, newTime);
		return keyA;
    }
	/**
	 * Test if update needed between keys.
	 * TODO test if sometimes newTime never reach key.time.
	 * @param	ref
	 * @param	newTime
	 * @return  if newTime != keyTime and curveType == instant, so update doesn't needed
	 */
	public function needToUpdate(ref:Ref, newTime:Int):Bool
	{
		var timeline:SpriterTimeline = timelines[ref.timeline];
        var keyA:TimelineKey = timeline.keys[ref.key];
        
        if(timeline.keys.length == 1 || keyA.curveType == INSTANT)
        {
            if ( keyA.time != newTime) {
				return false;
			}
        }
		return true;
        
	}
	
}