package awe;
#if macro
import haxe.macro.Context;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using haxe.macro.ExprTools;
using awe.util.MacroTools;
import haxe.macro.Expr;
#end
import haxe.io.Bytes;
import awe.util.Timer;
import awe.util.Bag;
import awe.util.BitSet;
import awe.util.StringTools;
import awe.ComponentList;
#if doc
	@:extern interface Injector {
		public function injectInto(v: Dynamic): Void;
	}
#else
	import minject.Injector;
#end

/**
	The central type of `Engine`.
**/
class Engine {
	/** The component lists for each type of `Component`. **/
	public var components(default, null): Map<ComponentType, IComponentList>;
	/** The systems to run. **/
	public var systems(default, null): Bag<System>;
	/** The entities that the systems run on. **/
	public var entities(default, null): Bag<Entity>;
	/** The composition of each entity. **/
	public var compositions(default, null): Map<Entity, BitSet>;
	/** How many entities have been created so far. **/
	public var entityCount(default, null): Int;
	/** This is used to inject the `IComponentList` into the `System`s. **/
	public var injector(default, null):Injector;

	/** 
		Construct a new engine.
		@param components The component lists for each type of `Component`.
		@param systems The systems to run.
		@param injector This is used to inject the `IComponentList` into the `System`s.
	**/
	public function new(components, systems, injector) {
		this.components = components;
		this.systems = systems;
		this.injector = injector;
		entities = new Bag();
		compositions = new Map();
		entityCount = 0;
		for(system in systems)
			system.initialize(this);
	}
	public static macro function build(setup: ExprOf<EngineSetup>): ExprOf<Engine> {
		var debug = Context.defined("debug");
		if(debug)
			Sys.println("Setting up Engine..");
		var expectedCount: Null<Int> = setup.getField("expectedEntityCount").getValue();
		var components = [for(component in setup.assertField("components").getArray()) {
			var cty = ComponentType.get(component.resolveTypeLiteral());
			var list = cty.isPacked() ? macro PackedComponentList.build($component) : macro new ComponentList($v{expectedCount});
			macro $v{cty.getPure()} => $list;
		}];
		var systems = setup.assertField("systems").getArray();
		var components = { expr: ExprDef.EArrayDecl(components), pos: setup.pos };
		var block = [
			(macro var components:Map<ComponentType, IComponentList> = $components),
			(macro var systems:awe.util.Bag<System> = new awe.util.Bag($v{systems.length})),
			(macro var csystem:System = null),
			macro var injector = new minject.Injector()
		];
		var i = 0;
		for(system in systems) {
			var ty = Context.typeof(system);
			block.push(macro systems.add(csystem = $system));
			block.push(macro injector.mapType($v{ty.toString()}, csystem).toValue(csystem));
		}
		for(component in setup.assertField("components").getArray()) {
			var cty = ComponentType.get(component.resolveTypeLiteral());
			var parts = component.toString().split(".");
			var name = StringTools.pluralize(parts[parts.length - 1].toLowerCase());
			block.push(macro injector.mapType('awe.IComponentList', $v{name}).toValue(components.get($v{cty.getPure()})));
		}
		block.push(macro new Engine(components, systems, injector));
		return {
			expr: ExprDef.EBlock(block),
			pos: Context.currentPos()
		};
	}
	public inline function update(delta: Float)
		for(system in systems)
			system.update(delta);

	public function delayLoop(delay: Float): Timer {
		var timer = new Timer(Std.int(delay * 1000));
		timer.run = update.bind(delay);
		return timer;
	}
	public function loop() {
		var last = Timer.stamp();
		var curr = last;
		while(true) {
			curr = Timer.stamp();
			update(curr - last);
			last = curr;
		}
	}
}
typedef EngineSetup = {
	?expectedEntityCount: Int,
	?components: Array<Class<Component>>,
	?systems: Array<System>
}