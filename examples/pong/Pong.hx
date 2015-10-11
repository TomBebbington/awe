import awe.Archetype;
import awe.Component;
import awe.ComponentList;
import awe.Engine;
import awe.Entity;
import awe.System;
import awe.Filter;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;

@Empty
class Collide implements Component {}

@Pack
class Size implements Component {
	public var w: Float;
	public var h: Float;
	public function new(w, h) {
		this.w = w;
		this.h = h;
	}
}
@Pack
class Position implements Component {
	public var x: Float;
	public var y: Float;
	public function new(x, y) {
		this.x = x;
		this.y = y;
	}
}
@Pack
class Velocity implements Component {
	public var x: Float;
	public var y: Float;
	public function new(x, y) {
		this.x = x;
		this.y = y;
	}
}
enum InputData {
	Up;
	Down;
	None;
}

class Input implements Component {
	public function new() {}
}

@Empty
class Bounce implements Component {}
enum SideData {
	Left;
	Right;
}
@Pack
class Side implements Component {
	public var side: SideData;
	public function new(side: SideData)
		this.side = side;
}

class Draw implements Component {
	public var color: String;
	public function new(color: String)
		this.color = color;
}

@Pack
class Speed implements Component {
	public var speed: Float;
	public function new(speed: Float)
		this.speed = speed;
}


class BounceSystem extends EntitySystem {
	@inject('positions') public var positions: awe.IComponentList;
	@inject('sizes') public var sizes: awe.IComponentList;
	@inject('velocities') public var velocities: awe.IComponentList;
	@inject public var draw: DrawSystem;
	public override function new() {
		super(Filter.build(Bounce & Position & Size & Velocity));
	}
	public override function updateEntity(delta: Float, entity: Entity): Void {
		var pos: Position = positions.get(entity);
		var size: Size = sizes.get(entity);
		var vel: Velocity = velocities.get(entity);
		if(pos.x + vel.x * delta < 0)
			vel.x = Math.abs(vel.x);
		if(pos.x + vel.x * delta + size.w > draw.canvas.width)
			vel.x = -Math.abs(vel.x);
		if(pos.y + vel.y * delta < 0)
			vel.y = Math.abs(vel.y);
		if(pos.y + vel.y * delta + size.h > draw.canvas.height)
			vel.y = -Math.abs(vel.y);
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

class CollisionSystem extends EntitySystem {
	@inject('positions') public var positions: awe.IComponentList;
	@inject('sizes') public var sizes: awe.IComponentList;
	@inject('velocities') public var velocities: awe.IComponentList;
	public override function new() {
		super(Filter.build(Collide & Position & Size & Velocity));
	}
	public override function updateEntity(delta: Float, entity: Entity): Void {
		var pos: Position = positions.get(entity);
		var size: Size = sizes.get(entity);
		var vel: Velocity = velocities.get(entity);
		var nextX = pos.x + vel.x * delta;
		var nextY = pos.y + vel.y * delta;
		for(other in this.matchers) {
			if(other == entity) continue;
			var opos: Position = positions.get(entity);
			var osize: Size = sizes.get(entity);
			var ovel: Velocity = velocities.get(entity);
			if (pos.x < opos.x + osize.w &&
				pos.x + size.w > opos.x &&
				pos.y < opos.y + osize.h &&
				size.h + pos.y > opos.y) {
				vel.x = -vel.x;
				vel.y = -vel.y;
			}
		}
	}
}

class DrawSystem extends EntitySystem {
	var context: CanvasRenderingContext2D;
	public var canvas: CanvasElement;
	@inject('draws') public var draws: awe.IComponentList;
	@inject('positions') public var positions: awe.IComponentList;
	@inject('sizes') public var sizes: awe.IComponentList;
	public override function new() {
		super(Filter.build(Position & Draw & Size));
		canvas = cast js.Browser.document.getElementById("pong");
		context = canvas.getContext2d();
	}
	public override function update(delta: Float) {
		context.fillStyle = 'black';
		context.fillRect(0, 0, canvas.width, canvas.height);
		super.update(delta);
	}
	public override function updateEntity(delta: Float, entity: Entity): Void {
		var pos: Position = positions.get(entity);
		var size: Size = sizes.get(entity);
		var draw: Draw = draws.get(entity);
		context.fillStyle = draw.color;
		context.fillRect(pos.x, pos.y, size.w, size.h);
	}
}

class InputSystem extends EntitySystem {
	@inject('inputs') public var inputs: awe.IComponentList;
	@inject('speeds') public var speeds: awe.IComponentList;
	@inject('velocities') public var velocities: awe.IComponentList;
	@inject public var draw: DrawSystem;

	var input: InputData;

	public override function new() {
		super(Filter.build(Input & Velocity & Speed));
		input = InputData.None;
	}

	public override function initialize(engine: Engine) {
		super.initialize(engine);
		draw.canvas.onkeydown = function(event) {
			switch(event.keyCode) {
				case 40: input = Down;
				case 38: input = Up;
			}
		};
		draw.canvas.onkeyup = function(event) {
			switch(event.keyCode) {
				case 38 | 40: input = None;
			}
		};
	}

	public override function updateEntity(delta: Float, entity: Entity): Void {
		var speed: Speed = speeds.get(entity);
		var velocity: Velocity = velocities.get(entity);
		velocity.y = speed.speed * delta * (switch input {
			case Up: -1;
			case Down: 1;
			case None: 0;
		});
	}
}

class Pong {
	static function main() {
		js.Browser.window.onload = function(_) {
			var engine = Engine.build({
				components: [Bounce, Collide, Side, Speed, Position, Velocity, Size, Input, Draw],
				systems: [
					new BounceSystem(),
					new CollisionSystem(),
					new DrawSystem(),
					new MovementSystem(),
					new InputSystem()
				],
				managers: [
					new awe.managers.GroupManager()
				],
				expectedEntityCount: 3
			});
			var playerArch = Archetype.build(Size, Collide, Speed, Input, Position, Velocity, Draw);
			var player = playerArch.create(engine);
			player.add(engine, new Draw("red"));
			player.add(engine, new Size(3, 50));
			player.add(engine, new Position(65, 55));
			player.add(engine, new Velocity(0, 0));
			player.add(engine, new Speed(7000));
			player.add(engine, new Input());
			var ballArch = Archetype.build(Size, Collide, Position, Velocity, Draw, Bounce);
			var ball = ballArch.create(engine);
			ball.add(engine, new Draw("blue"));
			ball.add(engine, new Size(30, 30));
			ball.add(engine, new Position(300, 300));
			ball.add(engine, new Velocity(1000, 1000));
			engine.delayLoop(0.04);
		};
	}
}