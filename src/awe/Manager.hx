package awe;

class Manager {
	/** The engine that contains this manager. **/
	public var engine(default, null): Engine;
	/**
		Initializes this manager in the `Engine`.
		@param engine The `Engine` to initialize this in.
	**/
	public function initialize(engine: Engine): Void {
		this.engine = engine;
		engine.injector.injectInto(this);
	}
	/**
		Called when an entity is added to the engine.
	**/
	public function added(entity: Entity): Void {}
	/**
		Called when an entity is deleted from the engine.
	**/
	public function removed(entity: Entity): Void {}
}