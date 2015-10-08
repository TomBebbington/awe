package awe;

import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using awe.util.MacroTools;
import haxe.macro.Expr;

/** A Unique Identifier for a class implementing Component */
abstract ComponentType(Int) from Int to Int {
	#if macro
	static var count:Int = 0;
	public static var types(default, never) = new Map<String, ComponentType>();

	public static function get(ty: Type): awe.ComponentType {
		var tys = ty.toString();
		return if(types.exists(tys)) 
			types.get(tys)
		else {
			var cty = ++count;
			if(Component.AutoComponent.canPack(ty))
				cty |= PACKED_FLAG;
			types.set(tys, cty);
			count;
		}
	}

	public static inline function getLocal(): ComponentType
		return get(Context.getLocalType());

	#end


	static inline var PACKED_FLAG = 1 << 31;
	public inline function isPacked():Bool
		return this & PACKED_FLAG != 0;

	public inline function getPure():Int
		return this & ~PACKED_FLAG;


	/** Add this to the Int given. */
	public inline function addTo(value:Int): Int
		return value | (1 << (this ^ PACKED_FLAG));
	@:op(A == B) static inline function eq(a: ComponentType, b: ComponentType): Bool
		return (a & ~PACKED_FLAG) == (b & ~PACKED_FLAG);
	@:op(A != B) static inline function neq(a: ComponentType, b: ComponentType): Bool
		return (a & ~PACKED_FLAG) != (b & ~PACKED_FLAG);
}