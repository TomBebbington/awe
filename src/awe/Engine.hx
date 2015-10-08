package awe;

import haxe.io.Bytes;
import awe.util.Timer;
import awe.util.Bag;
import awe.ComponentList;

class Engine {
	public var components(default, null): Map<ComponentType, IComponentList<Component>>;
	public var systems(default, null): Bag<System>;

	public function new(setup: EngineSetup) {
		components = new Map();
		systems = setup.systems;
		for(cl in setup.components) {
			var ty = Type.createEmptyInstance(cl).getType();
			components.set(ty, ComponentList.create(cl));
		}
	}
	public inline function update(delta: Float)
		for(system in systems)
			system.update(delta);

	public function delayLoop(delay: Float): Timer {
		var timer = new Timer(Std.int(delay * 1000));
		timer.run = update.bind(delay);
		return timer;
	}
	public function loop() {
		var last = Timer.stamp();
		var curr = last;
		while(true) {
			curr = Timer.stamp();
			update(curr - last);
			last = curr;
		}
	}
}
class EngineSetup {
	public var components(default, null): Bag<Class<Component>>;
	public var systems(default, null): Bag<System>;
	public function new() {
		components = new Bag<Class<Component>>();
		systems = new Bag<System>();
	}

	public inline function registerComponent(cl: Class<Component>): EngineSetup {
		components.add(cl);
		return this;
	}

	public inline function setSystem(system: System): EngineSetup {
		systems.add(system);
		return this;
	}
}