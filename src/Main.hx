import awe.Component;
import awe.ComponentType;
import awe.Engine;
import awe.Entity;
import awe.Archetype;
import awe.System;
import awe.Filter;
import awe.util.BitSet;
import awe.ComponentList;

enum Direction {
	Up;
	Down;
}

class Position implements Component {
	public var x: Float;
	public var y: Float;
	public function new(x: Float, y:Float) {
		this.x = x;
		this.y = y;
	}
	public inline function set(x: Float, y: Float) {
		this.x = x;
		this.y = y;
	}
	public inline function length() {
		return Math.sqrt(x * x + y * y);
	}
	public inline function toString(): String
		return Std.string(x) + ", " + Std.string(y);
}
class Velocity implements Component {
	public var x: Float;
	public var y: Float;
	public function new(x: Float, y:Float) {
		this.x = x;
		this.y = y;
	}
	public inline function set(x: Float, y: Float) {
		this.x = x;
		this.y = y;
	}
	public inline function length() {
		return Math.sqrt(x * x + y * y);
	}
	public inline function toString(): String
		return Std.string(x) + ", " + Std.string(y);
}

class MovementSystem extends EntitySystem {
	public override function new() {
		super(Filter.build(Position & Velocity));
	}
	public override function update(delta: Float): Void
		trace(delta);
}

class Main {
	static function main() {
		var engine = Engine.build({
			components: [Position, Velocity],
			systems: [new MovementSystem()]
		});
		var entity: Entity = cast 0;
		entity.add(engine, new Position(3, 4));
		var pos = ComponentType.of(Position);
		var positions = engine.components.get(pos);
		var serial = positions.serialize();
		var pos: Position = positions.get(entity);
		pos.x = 0;
		trace(entity.get(engine, Position));
		engine.update(3);
	}
}