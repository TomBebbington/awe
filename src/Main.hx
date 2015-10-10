import awe.Component;
import awe.ComponentType;
import awe.PackedComponent;
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
	public function new(x: Float, y:Float)
		set(x, y);

	public inline function set(x: Float, y: Float) {
		this.x = x;
		this.y = y;
	}
}
class Velocity implements Component {
	public var x: Float;
	public var y: Float;
	public function new(x: Float, y:Float)
		set(x, y);

	public inline function set(x: Float, y: Float) {
		this.x = x;
		this.y = y;
	}
}

class MovementSystem extends EntitySystem {
	@inject('positions') public var positions: awe.IComponentList;
	@inject('velocities') public var velocities: awe.IComponentList;
	public override function new() {
		super(Filter.build(Position & Velocity));
	}
	public override function updateEntity(delta: Float, entity: Entity): Void {
		var pos: Position = positions.get(entity);
		var vel: Velocity = velocities.get(entity);
		pos.x += vel.x * delta;
		pos.y += vel.y * delta;
	}
}

class Main {
	static function main() {
		var engine = Engine.build({
			components: [Position, Velocity],
			systems: [new MovementSystem()],
			expectedEntityCount: 1
		});
		var player = Archetype.build(Position, Velocity);
		var entity = player.create(engine);
		entity.add(engine, new Position(3, 4));
		entity.add(engine, new Velocity(1, -1));
		var pos: Position = entity.get(engine, Position);
		trace(pos.x, pos.y);
		engine.update(3);
		trace(pos.x, pos.y);
	}
}