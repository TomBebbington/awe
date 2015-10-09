package awe;

import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using haxe.macro.ExprTools;
using awe.util.MacroTools;
import haxe.macro.Expr;
import haxe.io.Bytes;
import awe.util.Timer;
import awe.util.Bag;
import awe.ComponentList;

class Engine {
	public var components(default, null): Map<ComponentType, IComponentList>;
	public var systems(default, null): Bag<System>;

	public function new() {
		components = new Map();
		systems = new Bag();
	}
	public static macro function build(setup: ExprOf<EngineSetup>): ExprOf<Engine> {
		var components: Array<Expr> = [];
		var systems: Expr = macro [];
		switch(setup.expr) {
			case EObjectDecl(fields):
				for(field in fields)
					switch(field.field) {
						case "systems":
							systems = field.expr;
						case "components":
							for(component in field.expr.getArray()) {
								var ty = component.resolveTypeLiteral();
								var cty = awe.ComponentType.get(ty);
								var list = cty.isPacked() ? macro new PackedComponentList($component) : macro new ComponentList();
								components.push(macro $v{cty} => $list);
							}
					}
			default:
				Context.error("`Engine.setup` requires object", Context.currentPos());
		}
		var components = { expr: ExprDef.EArrayDecl(components), pos: setup.pos };
		return macro {
			var engine:Engine = Type.createEmptyInstance(Engine);
			untyped engine.components = $components;
			untyped engine.systems = awe.util.Bag.fromArray($systems);
			engine;
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
	?components: Array<Class<Component>>,
	?systems: Array<System>
}