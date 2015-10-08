package awe.util;

/** Dispatches events to listeners. */
abstract Signal<T>(Bag<SignalListener<T>>) {
	/** Create a new signal. */
	public inline function new()
		this = new Bag<SignalListener<T>>(8);

	/** Dispatch an event, notifying all listeners of the event. */
	public inline function dispatch(event: T)
		for(v in this)
			v.on(event);

	/** Add a new dispatcher. */
	public inline function add(dispatch: SignalListener<T>)
		this.add(dispatch);

	/** Remove a dispatcher. */
	public inline function remove(dispatch: SignalListener<T>)
		this.remove(dispatch);

	/** Remove all the dispatchers. */
	public inline function clear()
		this.clear();

	@:to public inline function getListeners(): Bag<SignalListener<T>>
		return this;
}