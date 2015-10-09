package awe.util;
/** Capable of listening to a signal of type T. */
interface SignalListener<T> {

	/**
		Process the signal listener with `event`.
		@param event The event to process.
	*/
	function on(event: T): Void;
}