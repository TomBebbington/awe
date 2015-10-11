package awe;

import awe.Filter;
import awe.util.Bag;
/** A basic system. **/
class System {
	/** The engine that contains this system. **/
	public var engine(default, null): Engine;
	/** If this system is enabled or not. **/
	public var enabled: Bool;
	/** Create a new, empty system. **/
	public function new() {
		enabled = true;
		engine = null;
	}
	/**
		Check if this system should be processed.
		@return If this should be processed or not.
	**/
	public function shouldProcess(): Bool
		return enabled;

	/**
		Initializes this system in the `Engine`.
		@param engine The `Engine` to initialize this in.
	**/
	public function initialize(engine: Engine): Void {
		this.engine = engine;
		engine.injector.injectInto(this);
	}

	/**
		Updates this system.
		@param delta The change in time in seconds.
	**/
	public function update(delta: Float): Void {}
}

class EntitySystem extends System {
	/** The filter to check an entity against before adding to this system. **/
	public var filter(default, null): Filter;
	/** The entities that match the `filter`. **/
	public var matchers(default, null): Bag<Entity>;
	public function new(filter: Filter) {
		super();
		this.filter = filter;
		this.matchers = new Bag();
	}
	public function updateMatchers():Void {
		matchers.clear();
		for(entity in engine.entities)
			if(filter.matches(entity.getComposition(engine)))
				matchers.add(entity);
	}
	public function updateEntity(delta:Float, entity: Entity): Void {}
	public override function update(delta: Float):Void {
		if(matchers.length ==  0)
			updateMatchers();
		for(entity in matchers)
			updateEntity(delta, entity);
	}
}