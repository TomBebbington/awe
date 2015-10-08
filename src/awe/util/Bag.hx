package awe.util;

import haxe.ds.Vector;

abstract Bag<T>(BagData<T>) {
	public var length(get, never): Int;
	public var capacity(get, never): Int;

	public inline function new(capacity:Int = 16)
		this = new BagData<T>(capacity);

	inline function get_capacity()
		return this.data.length;

	inline function get_length()
		return this.length;

	public inline function clear():Void
		this.clear();

	public inline function contains(value: T): Bool
		return this.contains(value);

	public inline function add(item: T):Void
		this.add(item);

	public inline function ensureCapacity(capacity:Int):Void
		this.ensureCapacity(capacity);

	@:arrayAccess public inline function get(index: Int): Null<T>
		return this.get(index);

	@:arrayAccess public inline function set(index: Int, value: T): T
		return this.set(index, value);

	public inline function iterator():BagIterator<T>
		return this.iterator();

	public inline function remove(item: T):Bool
		return this.remove(item);

	public inline function removeLast(): Null<T>
		return this.removeLast();

	/**
		Copy the elements from `srcPos` terminating at `srcPos + len` to `dest` at the offset `destPos`
	**/
	public inline function blit(srcPos: Int, dest: Bag<T>, destPos: Int, len: Int)
		this.blit(srcPos, cast dest, destPos, len);

	@:from public static inline function fromVector<T>(vector: Vector<T>) {
		var data = Type.createEmptyInstance(BagData);
		untyped data.data = vector;
		untyped data.length = vector.length;
		return cast data;
	}
	@:from public static inline function fromArray<T>(array: Array<T>)
		return fromVector(Vector.fromArrayCopy(array));

	@:to public inline function toArray(): Array<T>
		return this.data.toArray();
}

/** A Bag. */
@:generic
class BagData<T> {
	public var data(default, null):Vector<T>;
	public var length(default, null): Int;
	public function new(capacity:Int) {
		data = new Vector(capacity);
		length = 0;
	}
	public function ensureCapacity(capacity:Int):Void {
		if(data.length < capacity) {
			var newData = new Vector(capacity);
			Vector.blit(data, 0, newData, 0, length);
			data = newData;
		}
	}
	public function clear(): Void {
		for(i in 0...length)
			data.set(i, null);
		length = 0;
	}

	public inline function add(item: T): Void {
		ensureCapacity(length + 1);
		data.set(length++, item);
	}

	public inline function set(index: Int, item: T): T {
		ensureCapacity(index + 1);
		length = Std.int(Math.max(index + 1, length));
		return data.set(index, item);
	}

	public inline function get(index: Int): T
		return data.get(index);

	public function removeLast(): Null<T> {
		return if(length == 0)
			null;
		else {
			var item = data.get(length - 1);
			data.set(--length, null);
			item;
		}
	}

	public function contains(value: T): Bool {
		for(i in 0...length)
			if(data.get(i) == value)
				return true;
		return false;
	}

	public function remove(value: T): Bool {
		for(i in 0...length)
			if(data.get(i) == value) {
				Vector.blit(data, i + 1, data, i, length-- - i - 1);
				return true;
			}
		return false;
	}
	public function toString(): String {
		var buf = new StringBuf();
		buf.add("Bag: ");
		for(i in 0...length) {
			if(i > 0)
				buf.add(", ");
			buf.add(data.get(i));
		}
		return buf.toString();
	}
	/**
		Copy the elements from `srcPos` terminating at `srcPos + len` to `dest` at the offset `destPos`
	**/
	public inline function blit(srcPos: Int, dest: BagData<T>, destPos: Int, len: Int)
		Vector.blit(data, srcPos, dest.data, destPos, len);

	public inline function iterator():BagIterator<T>
		return new BagIterator(this);
}
@:generic
class BagIterator<T> {
	var bag: BagData<T>;
	var index: Int;
	public inline function new(bag: BagData<T>) {
		this.bag = bag;
		index = 0;
	}

	public inline function hasNext():Bool
		return index < bag.length;

	public inline function next():T
		return bag.get(index++);
}