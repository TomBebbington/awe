package awe.util;

import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using Lambda;

/** Some handy macro tools. **/
class MacroTools {
	#if macro
	public static function resolveTypeLiteral(literal: Expr):Type
		return Context.getType(literal.toString());

	static inline function formatName(pack: Array<String>, name: String)
		return [name].concat(pack).join(".");

	public static function toString(ty: Type):String
		return switch(ty) {
			case Type.TInst(cl, _):
				formatName(cl.get().pack, cl.get().name);
			case Type.TAbstract(ab, _):
				formatName(ab.get().pack, ab.get().name);
			case Type.TDynamic(_): "Dynamic";
			case Type.TEnum(en, _):
				formatName(en.get().pack, en.get().name);
			case Type.TFun(args, ret):
				args.map(function(arg) return toString(arg.t)).join(" -> ") + " -> " + toString(ret);
			case Type.TAnonymous(an):
				"{ " + an.get().fields.map(function(field) return field.name + ": " + toString(field.type)) + " }";
			case Type.TType(ty, ps):
				formatName(ty.get().pack, ty.get().name);
			case Type.TMono(mo):
				toString(mo.get());
			case Type.TLazy(f):
				toString(f());
		};
	#end
}