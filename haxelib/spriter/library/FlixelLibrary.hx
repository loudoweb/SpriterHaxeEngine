package spriter.library;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.util.loaders.SparrowData;
import flixel.util.loaders.TexturePackerData;
import flixel.util.loaders.TexturePackerXMLData;
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
	
	private var _atlasData:TexturePackerData;
	
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
	 *  	engine.addEntity('lib_' + Std.int(i+1), 100 + 50 * (i % 10), 100 + 50 * (Std.int(i / 10) % 6));
	 * }
	 * 
	 * add(spriterGroup);
	 *
	 * 2) with atlases
	 * var spriterGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	 * var data:SparrowData = new SparrowData("assets/ugly/ugly.xml", "assets/ugly/ugly.png");
	 * var lib:FlixelLibrary = new FlixelLibrary(spriterGroup, null, data);
	 * engine = new SpriterEngine(Assets.getText('assets/sprites/brawler/brawler.scml'), lib, null);
	 * var len:Int = 1;
	 * for (i in 0...len) {
	 *  	engine.addEntity('lib_' + Std.int(i+1), 100 + 50 * (i % 10), 100 + 50 * (Std.int(i / 10) % 6));
	 * }
	 * 
	 * add(spriterGroup);
	 * 
	 * 
	 * and don't forget to call engine.update(); at the state update() method
	 */
	public function new(group:FlxTypedGroup<FlxSprite>, basePath:String = null, atlasData:TexturePackerData = null) 
	{
		super(basePath);
		
		_flxGroup = group;
		_sprites = new Map<String, Array<FlxSprite>>();
		_atlasData = atlasData;
	}
	
	override public function getFile(name:String):Dynamic
	{
		if (_atlasData != null)
		{
			var sprite:FlxSprite = null;
			
			if (_sprites.exists(_atlasData.assetName) && _sprites.get(_atlasData.assetName).length > 0)
			{
				sprite = _sprites.get(_atlasData.assetName).shift();
			}
			else
			{
				sprite = new FlxSprite();
				sprite.loadGraphicFromTexture(_atlasData);
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
		
		if (_atlasData != null)
		{
			_atlasData.destroy();
			_atlasData = null;
		}
	}
	
}