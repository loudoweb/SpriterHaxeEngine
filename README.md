SpriterHaxeEngine 
=============

The point of this project is to offer a Brashmonkey's Spriter SCML renderer compatible with Haxe 3 and openfl.
Base code of SCML definitions from http://www.brashmonkey.com/ScmlDocs/ScmlReference.html 

Inspired by 
 - https://github.com/Acemobe/SpriterAS3Anim
 - https://bitbucket.org/ClockworkMagpie/haxe-spriter/
 - https://github.com/ibilon/HaxePunk-Spriter

Install:
``haxelib install SpriterHaxeEngine``

Choose your drawing library:

```as3
/**
* Example with the BitmapLibrary which uses BitmapData.copypixels() and BitmapData.draw()
*/
//set the root canvas where to add all the animations
var canvas:BitmapData = new BitmapData(800, 480);
var spriterRoot:Bitmap = new Bitmap(canvas, PixelSnapping.AUTO, true);
addChild(spriterRoot);
//choose a rendering method.
var lib:BitmapLibrary = new BitmapLibrary('assets/', canvas);

/**
* Example with the TilelayerLibrary which uses Tilelayer (haxelib install tilelayer)
*/
//set the root canvas where to add all the animations
var spriterRoot:Sprite = new Sprite();
addChild(spriterRoot);
//choose a rendering method.
var lib:TilelayerLibrary = new TilelayerLibrary('assets/atlas.xml' , 'assets/atlas.png', spriterRoot);

/**
* Other libraries exist to use Spriter with flixel and other rendering method!
*/
```

Instantiate the engine:

```as3
//Create the engine.
//you can specify a default scml or you can specify it later in addSpriter()
engine = new SpriterEngine(Assets.getText('assets/test.scml'), lib );
		
//Add a Spriter in the engine. A Spriter contains all data from the scml (all entities, animations, boxes, tags...)
//By default, it will play the first animation of the first entity of your scml
engine.addSpriter('uniqueId', x,  y);

//Set the "run" animation of the entity
engine.getSpriter('uniqueId').playAnim('run', myCallback);

//Apply the "gun" map of the entity
engine.getSpriter('uniqueId').applyCharacterMap('gun', true);

//Update on enter frame to draw all Spriters on screen
engine.update();

//Callback on end anim
function myCallback(s:Spriter, entity:String, anim:String):Void

//var and tag callback
engine.getSpriterAt(0).scml.tagCallback = function tagCallback(tag:String):Void{}
engine.getSpriterAt(0).scml.varChangeCallback function varCallback(variable:Variable<Dynamic>):Void{}

//points and boxes
var points:Array<SpatialInfo> = engine.getSpriterAt(0).getPoints();
var boxes:Array<Quadrilateral> = engine.getSpriterAt(0).getBoxes();

//stack anims
engine.getSpriter('uniqueId').playAnimsStackFromEntity("entityName", ["anim1","anim2"], myCallback).

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
 - default scml
 
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
 - Flixel Library (atlas support or bitmaps handled with addChild, dependency : flixel) by Zaphod
 - Heaps Library (h3d/heaps, dependency : https://github.com/ncannasse/heaps) by Delahee
 - Luxe Library (dependency : https://github.com/underscorediscovery/luxe)
 - override the AbstractLibrary to provide a new library
 
**Other features**
 - own texture packer exporter
 - macro to parse scml into binaries

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
 - add Kha support (waiting for pull request, see here https://github.com/sh-dave/SpriterHaxeEngine/tree/dev)
 - Optimized engine : draw call only when needed. So "instant" keys are not updated between keys.
 - animation callback optimization
 - check Garbage collector
 
Examples
------------
 - Please see this repo : https://github.com/loudoweb/Spriter-Example
 
Additional information
------------
 - compatible with Spriter r5
 - With Tilelayer library, don't use openfl-bitfive for html5 target.
 
 
Known issues
------------
 - [html5] some issues on html5 depending on the backend used and the Library used.
 - Please use the best rendering method according to your target.
 
