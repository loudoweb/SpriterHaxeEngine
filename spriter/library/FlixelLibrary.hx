package spriter.library;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
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
	
	private var _atlasFrames:FlxAtlasFrames;
	
	/**
	 * Flixel lib constructor
	 * @param	group		flixel group to render spriter animation to
	 * @param	basePath	Path to folder with bitmap assets. Used only if you are not using atlases
	 * @param	atlasData	texture packer data object. Used when you are using atlases
	 * 
	 * Usage examples:
	 * 1) without atlases
	 * var spriterGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	 * var lib:FlixelLibrary = new FlixelLibrary(spriterGroup, 'assets/sprites/brawler/');
	 * engine = new SpriterEngine(Assets.getText('assets/sprites/brawler/brawler.scml'), lib, null);
	 * var len:Int = 1;
	 * for (i in 0...len) {
	 *  	engine.addSpriter('lib_' + Std.int(i+1), 100 + 50 * (i % 10), 100 + 50 * (Std.int(i / 10) % 6));
	 * }
	 * 
	 * add(spriterGroup);
	 *
	 * 2) with atlases
	 * var spriterGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	 * var atlasFrames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow("assets/ugly/ugly.png", "assets/ugly/ugly.xml");
	 * var lib:FlixelLibrary = new FlixelLibrary(spriterGroup, null, atlasFrames);
	 * engine = new SpriterEngine(Assets.getText('assets/ugly/ugly.scml'), lib, null);
	 * var len:Int = 1;
	 * for (i in 0...len) {
	 *  	engine.addSpriter('lib_' + Std.int(i+1), 100 + 50 * (i % 10), 100 + 50 * (Std.int(i / 10) % 6));
	 * }
	 * 
	 * add(spriterGroup);
	 * 
	 * 
	 * and don't forget to call engine.update(Std.int(1000 * elapsed)); at the state update() method
	 */
	public function new(group:FlxTypedGroup<FlxSprite>, basePath:String = null, atlasFrames:FlxAtlasFrames = null) 
	{
		super(basePath);
		
		_flxGroup = group;
		_sprites = new Map<String, Array<FlxSprite>>();
		_atlasFrames = atlasFrames;
	}
	
	override public function getFile(name:String):Dynamic
	{
		if (_atlasFrames != null)
		{
			var sprite:FlxSprite = null;
			
			if (_sprites.exists(_atlasFrames.parent.key) && _sprites.get(_atlasFrames.parent.key).length > 0)
			{
				sprite = _sprites.get(_atlasFrames.parent.key).shift();
			}
			else
			{
				sprite = new FlxSprite();
				sprite.frames = _atlasFrames;
			}
			
			sprite.animation.frameName = name;
			
			return sprite;
		}
		
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
			
			var key:String = sprite.graphic.key;
			
			if (!_sprites.exists(key))
			{
				_sprites.set(key, new Array<FlxSprite>());
			}
			
			_sprites.get(key).push(sprite);
		}
		
	untyped	_flxGroup.length = 0;
    }
	
	override public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		var sprite:FlxSprite = cast getFile(name);
		info = compute(info, pivots, sprite.frameWidth, sprite.frameHeight);
		
		sprite.origin.set(0, 0);
		sprite.x = info.x;
		sprite.y = info.y;
		sprite.angle = SpriterUtil.fixRotation(info.angle);
		sprite.scale.x = info.scaleX;
		sprite.scale.y = info.scaleY;
		sprite.alpha = info.a;
		
		_flxGroup.add(sprite);
		info = null;
	}
	
	override public function render():Void {  }
	
	override public function destroy():Void
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
		
		if (_atlasFrames != null)
		{
			_atlasFrames.destroy();
			_atlasFrames = null;
		}
	}	
}