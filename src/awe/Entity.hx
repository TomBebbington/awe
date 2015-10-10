package awe;

import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.ComplexTypeTools;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
import haxe.macro.Expr;
using awe.util.MacroTools;
import awe.util.BitSet;

/** Reperesents a single glob of data. */
abstract Entity(Int) to Int from Int {
	/** The identifier of this entity. **/
	public var id(get, never): Int;
	inline function get_id(): Int
		return this;

	/**
		Finds the composition bits of this entity.
		@param engine The engine this `Entity` is contained in.
		@return The composition bits.
	**/
	public inline function getComposition(engine: Engine): BitSet
		return engine.compositions.get(this);

	#if macro

	static function wrapGet(engine: ExprOf<Entity>, ty: Type, cty: ComponentType) {
		var list = macro $engine.components.get($v{cty.getPure()});
		return Context.defined("debug") ? macro {
			var list = $list;
			if(list == null)
				throw "Component `" + $v{ty.toString()} + "` has not been registered with the Engine";
			list;
		} : list;
	}
	#end


	public macro function add<T: Component>(self: ExprOf<Entity>, engine: ExprOf<Engine>, value: ExprOf<T>): ExprOf<Void> {
		var ty = Context.typeof(value);
		var cty = ComponentType.get(ty);
		var list = wrapGet(engine, ty, cty);
		return macro $list.add($self, $value);
	}

	public macro function get<T: Component>(self: ExprOf<Entity>, engine: ExprOf<Engine>, cl: ExprOf<Class<T>>): ExprOf<Null<T>> {
		var ty = MacroTools.resolveTypeLiteral(cl);
		var cty = ComponentType.get(ty);
		var list = wrapGet(engine, ty, cty);
		return macro $list.get($self);
	}

	/** Returns the string representation of this data. */
	public inline function toString():String
		return "#" + Std.string(this);
}