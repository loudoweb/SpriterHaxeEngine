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

//var and tag callback
engine.getEntityAt(0).scml.tagCallback = function tagCallback(tag:String):Void{}
engine.getEntityAt(0).scml.varChangeCallback function varCallback(variable:Variable<Dynamic>):Void{}

//points and boxes
var points:Array<SpatialInfo> = engine.getEntityAt(0).getPoints();
var boxes:Array<Quadrilateral> = engine.getEntityAt(0).getBoxes();

```

Spriter Haxe Engine Features
--------------

**SCML API**

**Engine**
 - Can be overrided to fit your need
 - simple z-ordering
 - Fixed tick, variable tick or use your own time
 - Pause
 - simple auto removal
 
**Spriter entity**
 - character mapping by name
 - change animation easily by name in a Spriter entity
 - callback when animation ended
 - play, stack anim, pause
 - you can display duplicate of spriter entity and manipulate them separatly
 - callback when variable changes
 - callback when tag dispatches
 - Points (usage example : to shot a bullet when gun fire)
 - Boxes (usage example : hitbox)
 - sub entities

**Libraries**
 - Simple bitmap library (bitmaps handled with addChild, dependency : openfl)
 - BitmapData library (copypixels, dependency : openfl)
 - Tilelayer library (drawTiles using only one tilesheet)(dependency : https://github.com/elsassph/openfl-tilelayer and openfl).
 - DrawTiles library (using many tilesheets)(dependency : https://github.com/elsassph/openfl-tilelayer and openfl).
 - Flixel Library (atlas support or bitmaps handled with addChild, , dependency : flixel) by Zaphod
 - override the AbstractLibrary to provide a new library

**Cross-platform**
 - flash
 - windows
 - neko
 - android
 - html5

TODO
----
 - add tilesheet stage 3d support : https://github.com/as3boyan/TilesheetStage3D/
 - add ash and haxepunk support
 - add Flambe support (waiting for pull request, see here https://github.com/quinnhoener/SpriterHaxeEngine)
 - Optimized engine : draw call only when needed. So "instant" keys are not updated between keys.
 - animation callback optimization
 - check Garbage collector
 - binary scml
 - use multiple scml in the engine
 
Examples
------------
 - Please see this repo : https://github.com/loudoweb/Spriter-Example
 
Additional information
------------
 - compatible with Spriter r3
 - With Tilelayer library, don't use openfl-bitfive for html5 target.
 
 
Known issues
------------
 - [html5] some issues on html5 depending on the backend used and the Library used.
 - Please use the best rendering method according to your target.
 
