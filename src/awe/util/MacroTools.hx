package awe.util;
#if macro
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
#end
/** Some handy macro tools. **/
class MacroTools {
	#if macro
	public static function wrapBits(bits: BitSet):ExprOf<BitSet> {
		var bag = bits.toBag();
		var pos = Context.currentPos();
		return switch(bag.length) {
			case 0: macro new awe.util.BitSet();
			case 1: macro new awe.util.BitSet($v{bag.get(0)});
			default:
				var block = [
					{
						expr: ExprDef.EVars([
							{
								type: macro: awe.util.Bag<Int>,
								expr: macro new awe.util.Bag<Int>($v{bag.length}),
								name: "bag"
							}
						]),
						pos: pos
					}
				];
				for(item in bag)
					block.push(macro bag.add($v{item}));
				block.push(macro untyped bag);
				{
					expr: ExprDef.EBlock(block),
					pos: pos
				};
		}
	}
	public static function getArray(value: Expr): Array<Expr> {
		return switch(value.expr) {
			case EArrayDecl(values):
				values;
			default:
				Context.error("Expected array declaration", value.pos);
				null;
		}
	}
	public static function getField(value: Expr, name: String): Null<Expr> {
		switch(value.expr) {
			case EObjectDecl(fields):
				for(field in fields)
					if(field.field == name)
						return field.expr;
			default:
				Context.error("Expected object declaration", value.pos);
		};
		return null;
	}
	public static function assertField(value: Expr, name: String): Expr {
		var field = getField(value, name);
		if(field == null)
			Context.error('Needs field "$name"', value.pos);
		return field;
	}
	public static function resolveTypeLiteral(literal: Expr):Type {
		function isValid(expr: Expr):Bool
			return switch(expr.expr) {
				case EConst(CIdent(name)): name.charAt(0).toUpperCase() == name.charAt(0);
				case ExprDef.EField(o, _): isValid(o);
				default: false;
			};
		if(!isValid(literal))
			Context.error("Invalid type literal", literal.pos);
		return try {
			Context.getType(literal.toString());
		} catch(e: Dynamic) {
			Context.error(Std.string(e), literal.pos);
		}
	}

	static inline function formatName(pack: Array<String>, name: String)
		return [name].concat(pack).join(".");

	public static function sizeOf(ty: ComplexType):Int {
		var size = switch(ty) {
			case TOptional(t):
				sizeOf(t);
			case TPath({name: "StdTypes", pack: [], params: params, sub: sub}):
				sizeOf(TPath({
					name: sub,
					pack: [],
					params: params
				}));
			case TPath({name: "Bool", pack: []} | { name: "Char8" | "Int8", pack: [_] }):
				1;
			case TPath({ name: "Char16" | "Int16", pack: [_] }):
				2;
			case TPath({name: "Int" | "Single", pack: []} | { name: "Int32" | "UInt32" | "Float32", pack: [_] }):
				4;
			case TPath({name: "Int64", pack: ["haxe"]} | { name: "Float", pack: [] } | { name: "Int64" | "UInt64" | "Float64", pack: [_] }):
				8;
			case TPath(Context.follow(Context.getType(ty.toString())) => TEnum(_, [])):
				4;
			case TPath(Context.follow(Context.getType(ty.toString())) => TAbstract(aty, [])):
				sizeOf(aty.get().type.toComplexType());
			case TPath(Context.follow(Context.getType(ty.toString())) => Type.TInst(_.get() => ity, [])):
				var size = 0;
				for(field in ity.fields.get()) {
					switch(field.kind) {
						case FieldKind.FVar(_, _) if(field.name.indexOf("__") != 0):
							size += sizeOf(field.type.toComplexType());
						default:
					}
				}
				size;
			default: return null;
		};
		return size;
	}
	#end
}