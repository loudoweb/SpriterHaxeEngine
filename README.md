SpriterHaxeEngine 
=============

The point of this project is to offer a Brashmonkey's Spriter SCML renderer compatible with Haxe 3 and openfl.
Base code of SCML definitions from http://www.brashmonkey.com/ScmlDocs/ScmlReference.html 
Inspired by 
 - https://github.com/Acemobe/SpriterAS3Anim
 - https://bitbucket.org/ClockworkMagpie/haxe-spriter/
 - https://github.com/ibilon/HaxePunk-Spriter

Install it:
``haxelib install SpriterHaxeEngine``

Configure it:

```as3
//set the root canvas where to add all the animations
var canvas:BitmapData = new BitmapData(800, 480);
var spriterRoot:Bitmap = new Bitmap(canvas, PixelSnapping.AUTO, true);

//you can use a different library to feet your needs. This one use BitmapData.copypixels() and BitmapData.draw()
var lib:BitmapLibrary = new BitmapLibrary('assets/', canvas);

//here is the engine : it will update all your Spriter's entities
engine = new SpriterEngine(Assets.getText('assets/test.scml'), lib, null );
		
//to add and entity
engine.addEntity('entityName', x,  y);

//set the "run" animation of the entity
engine.getEntity('entityName').playAnim('run', myCallback);

//apply the "gun" map of the entity
engine.getEntity('entityName').applyCharacterMap('gun', true);


//update on enter frame
engine.update();

//callback on end anim
function myCallback(s:Spriter, entity:String, anim:String):Void
```

Spriter Haxe Engine Features
--------------

**SCML API**

**Engine**
 - Can be overrided to fit your need
 - simple z-ordering
 - Fixed tick, variable tick or use your own time
 - Pause
 
**Spriter entity**
 - character mapping by name
 - change animation easily by name in a Spriter entity
 - callback when animation ended
 - play, stack anim, pause
 - you can display duplicate of spriter entity and manipulate them separatly

**Libraries**
 - Simple bitmap library (bitmaps handled with addChild)
 - BitmapData library (copypixels)
 - Tilelayer library (drawTiles)(dependency : https://github.com/matthewswallace/openfl-tilelayer).
 - Flixel Library (atlas support or bitmaps handled with addChild)
 - override the AbstractLibrary to provide a new library

**Cross-platform**
 - flash
 - windows
 - neko
 - android
 - html5

TODO
----
 - support for Spriter b7
 - add tilesheet stage 3d support : https://github.com/as3boyan/TilesheetStage3D/
 - add ash and haxepunk support
 - Optimized engine : draw call only when needed. So "instant" keys are not updated between keys.
 - test performance
 - animation callback optimization
 - check Garbage collector
 - rename Library by Rendering
 
Examples
------------
 - Please see this repo : https://github.com/loudoweb/Spriter-Example
 
Additional information
------------
 - compatible with Spriter b6.1 (Spriter b7 is in the todolist)
 - With Tilelayer library, don't use openfl-bitfive for html5 target.
 
 
Known issues
------------
 - interpolation are not enough smooth at the end of a looping animation (need to check if the interpolation with the first frame is ok)
 - [Flash, Windows, openfl-html5] alpha on BitmapLibrary when no scale and no rotation (copypixels)
 - reset character mapping doesn't work (need to duplicate all the content of the array to make it working)
 - [html5] some issues on html5 depending on the backend used and the Library used.
 
