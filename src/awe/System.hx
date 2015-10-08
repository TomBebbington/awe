package awe;

import awe.Filter;
import awe.util.Bag;
/** A basic system. **/
class System {
	public var engine(default, null): Engine;
	public var enabled: Bool;
	public function new() {}
	public function shouldProcess(): Bool
		return enabled;
	public function inititialize(engine: Engine): Void
		this.engine = engine;

	public function update(delta: Float): Void {}
}

class EntitySystem extends System {
	public var filter(default, null): Filter;
	public var matchers(default, null): Bag<Int>;
	public function new(filter: Filter) {
		super();
		this.filter = filter;
		this.matchers = new Bag();
	}
}