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
	static var count:Int = 1;
	public static var types(default, never) = new Map<String, ComponentType>();

	public static function get(ty: Type): awe.ComponentType {
		var tys = ty.toString();
		return if(types.exists(tys)) 
			types.get(tys)
		else {
			var cty = count++;
			if(Component.AutoComponent.canPack(ty))
				cty |= PACKED_FLAG;
			if(Component.AutoComponent.isEmpty(ty))
				cty |= EMPTY_FLAG;
			types.set(tys, cty);
			count;
		}
	}

	public static inline function getLocal(): ComponentType
		return get(Context.getLocalType());

	#end

	public static macro function of(ty: ExprOf<Class<Dynamic>>): ExprOf<ComponentType> {
		return macro cast($v{get(ty.resolveTypeLiteral())}, ComponentType);
	}


	public static inline var PACKED_FLAG = 1 << 31;
	public static inline var EMPTY_FLAG = 1 << 30;
	public inline function isEmpty():Bool
		return this & EMPTY_FLAG != 0;

	public inline function isPacked():Bool
		return this & PACKED_FLAG != 0;

	public inline function getPure():ComponentType
		return this & ~PACKED_FLAG & ~EMPTY_FLAG;

	@:op(A == B) static inline function eq(a: ComponentType, b: ComponentType): Bool {
		var a: Int = a.getPure();
		var b: Int = b.getPure();
		return a == b;
	}
	@:op(A != B) static inline function neq(a: ComponentType, b: ComponentType): Bool {
		var a: Int = a.getPure();
		var b: Int = b.getPure();
		return a != b;
	}
}