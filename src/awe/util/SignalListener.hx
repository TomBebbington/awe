package awe.util;
/** Capable of listening to a signal of type T. */
interface SignalListener<T> {

	/** Process the signal listener with the event. */
	function on(event: T): Void;
}