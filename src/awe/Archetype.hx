package awe;

#if macro
import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
import haxe.macro.Expr;
#end
import awe.util.MacroTools;
/**
	Blueprints for fast `Entity` construction.

	This can be constructed by using the `Archetype.build(_)` macro.
	Using this, you can build an archetype by calling it with the
	components you want the `Entity` to have.

	### Example
	```haxe
	Archetype.build(Position, Velocity);
	```
**/
class Archetype {
	var types: Array<ComponentType>;
	var cid: Int;
	/**
		Create a new Archetype.
		@param cid The component ID.
		@param types The component types to construct and attach.
	**/
	public function new(cid: Int, types: Array<ComponentType>) {
		this.cid = cid;
		this.types = types;
	}
	public function create(engine: Engine): Entity {
		return cast 0;
	}
	/**
		Constructs an `Archetype` from some component types.
	**/
	public static macro function build(types: Array<ExprOf<Class<Component>>>): ExprOf<Archetype> {
		var newTypes = [];
		var cid = 0;
		for(ty in types) {
			var ty = MacroTools.resolveTypeLiteral(ty);
			var cty = awe.ComponentType.get(ty);
			cid |= cty.getPure();
			newTypes.push(cty);
		}
		return macro new Archetype($v{cid}, $v{newTypes});
	}
}