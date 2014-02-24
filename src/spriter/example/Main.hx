package spriter.example;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import openfl.Assets;
import openfl.display.FPS;
import spriter.definitions.ScmlObject;
import spriter.engine.Spriter;
import spriter.engine.SpriterEngine;
import spriter.library.BitmapLibrary;
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
		
		var len:Int = 10;
		
		var fps:FPS = new FPS();
		addChild(fps);
		
		/*
		var spriterRoot:Sprite = new Sprite();
		*/
		var canvas:BitmapData = new BitmapData(800, 480);
		var spriterRoot:Bitmap = new Bitmap(canvas, PixelSnapping.AUTO, true);
		
		addChild(spriterRoot);
		
	
		/*
		var lib:SpriterLibrary = new SpriterLibrary('assets/briton/');
		
		engine = new SpriterEngine(Assets.getText('assets/briton/briton.scml'), lib, spriterRoot );

		for (i in 0...len) {
			engine.addEntity('lib_' + Std.int(i+1), 0  + 50 * (i % 10),  50 * (Std.int(i / 10) % 6));
		}
		*/
		/*
		var lib:TilelayerLibrary = new TilelayerLibrary('assets/briton/briton.xml' , 'assets/briton/briton.png');
		engine = new SpriterEngine(Assets.getText('assets/briton/briton.scml'), lib, spriterRoot );
		for (i in 0...len) {
			engine.addEntity('lib_' + Std.int(i+1), 0  + 50 * (i % 10),  50 * (Std.int(i / 10) % 6));
		}
		*/
		
		var lib:BitmapLibrary = new BitmapLibrary('assets/briton/', canvas);
		
		engine = new SpriterEngine(Assets.getText('assets/briton/briton.scml'), lib, null );

		for (i in 0...len) {
			engine.addEntity('lib_' + Std.int(i+1), 0  + 50 * (i % 10),  50 * (Std.int(i / 10) % 6));
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
		//engine.getEntity('lib_1').playAnim('run');
		//engine.addEntity('lib_00', -10,  -10);
		engine.getEntity('lib_1').applyCharacterMap('lance', true);
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
