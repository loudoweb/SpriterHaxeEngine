SpriterEngine 
=============

The point of this project is to offer a Brashmonkey's Spriter SCML renderer compatible with Haxe 3 and openfl.
Base code from http://www.brashmonkey.com/ScmlDocs/ScmlReference.html 
Inspired by https://github.com/ibilon/HaxePunk-Spriter, https://github.com/Acemobe/SpriterAS3Anim and https://bitbucket.org/ClockworkMagpie/haxe-spriter/


Configure it:

```as3
var scml:ScmlObject = new ScmlObject(Xml.parse(Assets.getText('assets/test/test.scml')));
var lib:SpriterLibrary = new SpriterLibrary('assets/test/');
var spriter:Spriter = new Spriter('spriterId',scml, lib);
addChild(spriter);
		
var engine:SpriterEngine = new SpriterEngine();
engine.add('spriterId',spriter);
```

Spriter Engine Features
--------------

**SCML API**

**Engine**
 - Can be overrided to fit your need
 - Optimized engine : draw call only when needed. So "instant" keys are not updated between keys.
 
**Spriter entity**
 - character mapping
 - change animation easily in a Spriter entity
 - you can display duplicate of spriter entity and manipulate them separatly
 - catch when animation ended to launch another
 
**Cross-platform**
 - flash
 - windows
 - android
 - html5

TODO
----
 - add interpolation support
 - add tilelayer support : https://github.com/matthewswallace/openfl-tilelayer
 - add tilesheet stage 3d support : https://github.com/as3boyan/TilesheetStage3D/
 - add ash and haxepunk support
 - parse scml once when using multiple instance of Spriter Entity
 - test performance

Known issues
------------
 - interpolation doesn't work for now