package spriter.example;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import openfl.Assets;
import openfl.display.FPS;
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
		
		var len:Int = 20;
		
		var fps:FPS = new FPS();
		addChild(fps);
		
		engine = new SpriterEngine();
		
		/*
		scml = new ScmlObject(Xml.parse(Assets.getText('assets/briton/briton.scml')));

		for (i in 0...len) {
			
			var lib:SpriterLibrary = new SpriterLibrary('assets/briton/');
			spriter = new Spriter('spriterLibrary_'+i,scml, lib);
			spriter.x = 0  + 50 * (i % 10);
			spriter.y = 50 + 50 * (Std.int(i / 10) % 6);
			addChild(spriter);
			engine.add('spriterLibrary_'+i, spriter);
		}
		*/
		var scml2:ScmlObject = new ScmlObject(Xml.parse(Assets.getText('assets/briton/briton.scml')));
		for (i in 0...len) {
			
			var lib2:TilelayerLibrary = new TilelayerLibrary('assets/briton/briton.xml' , 'assets/briton/briton.png');
			spriter2 = new Spriter('tileLayerLibrary_'+i, scml2, lib2);
			spriter2.x = 50  + 50 * (i % 10);
			spriter2.y = 200 + 50 * (Std.int(i / 10) % 6);
			addChild(spriter2);
			engine.add('tileLayerLibrary_'+i, spriter2);
		}

		
		
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		addEventListener(MouseEvent.CLICK, onClick);
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}
	private function onClick(e:MouseEvent):Void
	{
		
		//addChild(spriter2);
		//engine.add('tileLayerLibrary',spriter2);
		//spriter.applyCharacterMap('lance', true);
		spriter.playAnim('run');
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
