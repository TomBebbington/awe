package awe;

#if macro
import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using haxe.macro.ExprTools;
import haxe.macro.Expr;
using awe.util.MacroTools;
#end
import awe.util.Bag;
import awe.util.BitSet;
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
	/**
		Create a new `Entity` with the components given by this `Archetype`.
		@param engine The engine to create the entity in.
		@return The created entity.
	**/
	public function create(engine: Engine): Entity {
		var entity:Entity = untyped engine.entityCount++;
		for(type in types) {
			if(!type.isEmpty()) {
				var list = engine.components.get(type.getPure());
				#if debug
				if(list == null)
					throw 'Component list for $type is null!';
				#end
				list.add(entity, null);
			}
		}
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
		var types = [for(tye in types) {
			var ty = MacroTools.resolveTypeLiteral(tye);
			var cty = awe.ComponentType.get(ty);
			cid.setBit(cty.getPure());
			macro $v{cty};
		}];
		return macro new Archetype(${cid.wrapBits()}, ${{expr: ExprDef.EArrayDecl(types), pos: Context.currentPos()}});
	}
}