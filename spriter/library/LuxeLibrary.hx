package spriter.library;

import luxe.Quaternion;
import luxe.Sprite;
import luxe.Vector;
import phoenix.Texture;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author loudo
 */
class LuxeLibrary extends AbstractLibrary
{
	var texture:Texture;
	var sprite:Sprite;
	var list:Array<String>;
	public function new(basePath :String) 
	{
		super(basePath);
		list = [];
	}
	override public function getFile(name:String):Dynamic
	{
		return Luxe.resources.texture(_basePath + name);
	}
	override public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		texture = getFile(name);
		info = compute(info, pivots, texture.width, texture.height);
		sprite =  new Sprite( {
            centered : false,
            pos : new Vector(info.x, info.y),
			scale : new Vector(info.scaleX, info.scaleY),
            texture : texture,
            depth : list.length
        });
		sprite.rotation_z = SpriterUtil.fixRotation(info.angle);
		sprite.color.a = Math.abs(info.a);
		list.push(sprite.name);
	}
	override public function render():Void
	{
		//handled by Luxe Engine
	}
	
	override public function clear():Void
	{
		for (i in 0...list.length)
		{
			Luxe.scene.entities.get(list[i]).destroy();
		}
		list.splice(0, list.length); // compact buffer
	}
	
	override public function destroy():Void
	{
		clear();
		list = null;
		sprite = null;
		texture = null;
	}
	
}