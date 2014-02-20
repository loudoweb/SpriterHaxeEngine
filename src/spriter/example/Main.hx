package spriter.example;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import openfl.Assets;
import spriter.definitions.ScmlObject;
import spriter.engine.Spriter;
import spriter.engine.SpriterEngine;
import spriter.library.SpriterLibrary;
import spriter.library.TilelayerLibrary;

/**
 * ...
 * @author Loudo
 */

class Main extends Sprite 
{
	var inited:Bool;

	/* ENTRY POINT */
	
	public var spriter:Spriter;
	public var spriter2:Spriter;
	public var engine:SpriterEngine;
	public var scml:ScmlObject;
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		scml = new ScmlObject(Xml.parse(Assets.getText('assets/spriter/player_map.scml')));
		var lib:SpriterLibrary = new SpriterLibrary('assets/spriter/');
		spriter = new Spriter('spriterLibrary',scml, lib);
		spriter.y = 100;
		spriter.x = 100;
		addChild(spriter);
		
		var scml2:ScmlObject = new ScmlObject(Xml.parse(Assets.getText('assets/briton/briton.scml')));
		var lib2:TilelayerLibrary = new TilelayerLibrary('assets/briton/briton.xml' , 'assets/briton/briton.png');
		spriter2 = new Spriter('tileLayerLibrary', scml2, lib2);
		spriter2.y = 250;
		spriter2.x = 250;
		
		engine = new SpriterEngine();
		engine.add('spriterLibrary',spriter);
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		addEventListener(MouseEvent.CLICK, onClick);
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}
	private function onClick(e:MouseEvent):Void
	{
		
		addChild(spriter2);
		engine.add('tileLayerLibrary',spriter2);
		scml.applyCharacterMap(null, true);
	}
	
	private function onEnterFrame(e:Event):Void
	{
		engine.update();
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
