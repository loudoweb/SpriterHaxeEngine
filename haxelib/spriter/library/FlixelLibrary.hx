package spriter.library;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import openfl.Assets;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author Loudo
 * @author Zaphod
 */
class FlixelLibrary extends AbstractLibrary
{
	private var _flxGroup:FlxTypedGroup<FlxSprite>;
	
	private var _sprites:Map<String, Array<FlxSprite>>;
	
	public function new(basePath:String, group:FlxTypedGroup<FlxSprite>) 
	{
		super(basePath);
		
		_flxGroup = group;
		_sprites = new Map<String, Array<FlxSprite>>();
	}
	override public function getFile(name:String):Dynamic
	{
		var key:String = _basePath + name;
		
		if (_sprites.exists(key) && _sprites.get(key).length > 0)
		{
			return _sprites.get(key).shift();
		}
		
		return new FlxSprite(0, 0, key);
	}
	
	override public function clear():Void
	{
        var len:Int = _flxGroup.members.length;
		var sprite:FlxSprite;
		
		for (i in 0...len)
		{
			sprite = _flxGroup.members.shift();
			if (sprite == null) 
				continue;
			
			var key:String = sprite.cachedGraphics.key;
			
			if (!_sprites.exists(key))
			{
				_sprites.set(key, new Array<FlxSprite>());
			}
			
			_sprites.get(key).push(sprite);
		}
		
		_flxGroup.length = 0;
    }
	
	override public function addGraphic(group:String, timeline:Int, key:Int, name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		var sprite:FlxSprite = cast getFile(name);
		var spatialResult:SpatialInfo = compute(info, pivots, sprite.frameWidth, sprite.frameHeight);
		
		sprite.origin.set(0, 0);
		sprite.x = spatialResult.x;
		sprite.y = spatialResult.y;
		sprite.angle = SpriterUtil.fixRotation(spatialResult.angle);
		sprite.scale.x = spatialResult.scaleX;
		sprite.scale.y = spatialResult.scaleY;
		
		_flxGroup.add(sprite);
	}
	override public function setRoot(root:Dynamic):Void 
	{
	}
	override public function render():Void
	{		
	}
	
	public function destroy():Void
	{
		if (_flxGroup != null)
		{
			_flxGroup.clear();
		}
		
		var spritesArr:Array<FlxSprite>;
		var numSprites:Int;
		var sprite:FlxSprite;
		
		for (key in _sprites.keys())
		{
			spritesArr = _sprites.get(key);
			numSprites = spritesArr.length;
			
			for (i in 0...numSprites)
			{
				sprite = spritesArr.shift();
				sprite.destroy();
			}
		}
		
		_sprites = null;
	}
	
}