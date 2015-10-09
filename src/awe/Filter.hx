package awe;
import awe.util.BitSet;
import haxe.macro.Expr;
#if macro
import awe.Component.AutoComponent;
#end
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
import haxe.macro.Context;
using awe.util.MacroTools;

/**
	A filter for matching entities' components against.

	This can be constructed by using the `Filter.build(_)` macro.
	Using this, you can build a filter from a binary operation representing
	the combination of types this will expect.

	## Supported Operations

	### All of...
	```haxe
	Filter.build(Position & Velocity);
	```
	### One of...
	```haxe
	Filter.build(Position | Velocity);
	```
	### None of...
	```haxe
	Filter.build(!Position);
	```
**/
class Filter {
	var allSet(default, null): BitSet;
	var oneSet(default, null): BitSet;
	var noneSet(default, null): BitSet;
	public function new(allSet, oneSet, noneSet) {
		this.allSet = allSet;
		this.oneSet = oneSet;
		this.noneSet = noneSet;
	}
	public static macro function build(expr: Expr): ExprOf<Filter> {
		var debug = Context.defined("debug");
		if(debug)
			Sys.println("Building filter from " + expr.toString());
		var all = new BitSet(0);
		var one = new BitSet(0);
		var none = new BitSet(0);
		function innerBuild(expr: Expr, ?set: BitSet) {
			set = set == null ? all : set;
			switch(expr.expr) {
				case EParenthesis(e):
					innerBuild(expr, set);
				case EBinop(OpAnd | OpAdd, a, b):
					innerBuild(a, all);
					innerBuild(b, all);
				case EBinop(OpOr, a, b):
					innerBuild(a, one);
					innerBuild(b, one);
				case EUnop(OpNot, _, a):
					innerBuild(a, none);
				case EField(_, _) | EConst(CIdent(_)):
					var ty = expr.resolveTypeLiteral();
					var cty = ComponentType.get(ty);
					if(debug)
						Sys.println("Adding " + ty.toString() + " / " + cty.getPure() + " to filter");
					set.setBit(ComponentType.get(ty));
				default:
					Context.error("Invalid expression for filter", Context.currentPos());
			}
		};
		innerBuild(expr);
		return macro new Filter($v{all.toBag().toArray()}, $v{one.toBag().toArray()}, $v{none.toBag().toArray()});
	}
	/**
		Returns true if the `components` set fulfills this filter.
		@param components The `BitSet` of components to check against.
		@return If the `components` set fulfills this filter.
	**/
	public inline function matches(components: BitSet): Bool
		return allSet.contains(components) && !noneSet.intersects(components) && oneSet.intersects(components);
}