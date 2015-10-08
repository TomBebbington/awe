package awe.util;

import haxe.ds.Vector;

typedef NativeThread =
#if neko
	neko.vm.Thread
#elseif cpp
	cpp.vm.Thread
#elseif java
	java.vm.Thread
#else
	Null<Dynamic>
#end
;

abstract Thread(NativeThread) to NativeThread {
	public static inline function current(): Thread
		return cast NativeThread.current();

	public static inline function read(block: Bool = true): Dynamic
		return NativeThread.readMessage(block);

	public inline function new(cb: Void -> Void)
		this = NativeThread.create(cb);

	public inline function send(message: Dynamic)
		this.sendMessage(message);
}