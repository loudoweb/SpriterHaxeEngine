package spriter.definitions;
import haxe.xml.Fast;
import spriter.vars.Variable;
import spriter.vars.VariableFloat;
import spriter.vars.VariableInt;
import spriter.vars.VariableString;

/**
 * ...
 * @author Loudo
 */
class SpriterEntity
{

    public var id:Int;
	public var name:String;
    public var characterMaps:Map<String,CharacterMap>;
    public var animations:Map<String,SpriterAnimation>;
	public var variables:Array<Variable<Dynamic>>;
	public var boxes_info:Map<String, SpriterBox>;

	
	public function new(fast:Fast) 
	{
		characterMaps = new Map<String,CharacterMap>();
		animations = new Map<String,SpriterAnimation>();
		variables = new Array<Variable<Dynamic>>();
		boxes_info = new Map<String, SpriterBox>();
		
		id = Std.parseInt(fast.att.id);
		name = fast.att.name;
		
		for (cm in fast.nodes.character_map)
		{
			characterMaps.set(cm.att.name, new CharacterMap(cm));
		}
		
		for (v in fast.node.var_defs.elements)
		{
			switch(v.att.type)
			{
				case "int":
					variables.push(new VariableInt(v.att.name, Std.parseInt(v.att.resolve("default"))));
				case "string":
					variables.push(new VariableString(v.att.name, Std.string(v.att.resolve("default"))));
				case "float":
					variables.push(new VariableFloat(v.att.name, Std.parseFloat(v.att.resolve("default"))));
			}
			
			
		}
		
		for (oi in fast.nodes.obj_info)
		{
			boxes_info.set(oi.att.name, new SpriterBox(oi));
		}
		
		
		for (a in fast.nodes.animation)
		{
			animations.set(a.att.name,new SpriterAnimation(a));
		}
		/*
		<obj_info name="box_000" type="box" w="65" h="53" pivot_x="0" pivot_y="0"/>
		*/
	}
}