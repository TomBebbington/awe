package awe;

#if macro
import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
import haxe.macro.Expr;
#end
import awe.util.Bag;
import awe.util.BitSet;
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
	var cid: BitSet;
	/**
		Create a new Archetype.
		@param cid The component ID.
		@param types The component types to construct and attach.
	**/
	public function new(cid: BitSet, types: Array<ComponentType>) {
		this.cid = cid;
		this.types = types;
	}
	public function create(engine: Engine): Entity {
		var entity:Entity = untyped engine.entityCount++;
		for(type in types)
			engine.components.get(type).add(entity, null);
		engine.entities.add(entity);
		engine.compositions.set(entity, cid);
		return entity;
	}
	public function createSome(engine: Engine, count: Int): Bag<Entity> {
		var entities = new Bag(count);
		var entity:Entity = cast -1;
		for(i in 0...count)
			entities.add(untyped engine.entityCount++);
		for(type in types) {
			var list = engine.components.get(type);
			for(entity in entities)
				list.add(entity, null);
		}
		return entities;
	}
	/**
		Constructs an `Archetype` from some component types.
	**/
	public static macro function build(types: Array<ExprOf<Class<Component>>>): ExprOf<Archetype> {
		var cid = new BitSet();
		var types = [for(ty in types) {
			var ty = MacroTools.resolveTypeLiteral(ty);
			var cty = awe.ComponentType.get(ty).getPure();
			cid.setBit(cty);
			macro $v{cty};
		}];
		return macro new Archetype(BitSet.fromArray($v{cid.toBag().toArray()}), ${{expr: ExprDef.EArrayDecl(types), pos: Context.currentPos()}});
	}
}