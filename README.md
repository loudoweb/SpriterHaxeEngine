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

//set the "run" animation of the entity at z-order 0
engine.getEntity(0).playAnim('run');

//apply the "gun" map of the entity at z-order 0
engine.getEntity(0).applyCharacterMap('gun', true);


//update on enter frame
engine.update();
```

Spriter Haxe Engine Features
--------------

**SCML API**

**Engine**
 - Can be overrided to fit your need
 - simple z-ordering
 
**Spriter entity**
 - character mapping by name
 - change animation easily by name in a Spriter entity
 - you can display duplicate of spriter entity and manipulate them separatly

**Libraries**
 - Simple bitmap library
 - BitmapData library
 - Tilelayer library (dependency : https://github.com/matthewswallace/openfl-tilelayer).
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
 - add ash, haxepunk and haxeflixel support
 - Optimized engine : draw call only when needed. So "instant" keys are not updated between keys.
 - test performance
 - retrieve entity by his name (for now, you have to use z-order)
 - catch when animation ended to launch another
 - rename Library by Rendering

Additional information
------------
 - With Tilelayer library, don't use openfl-bitfive for html5 target.
 
 
Known issues
------------
 - interpolation are not enough smooth
 
