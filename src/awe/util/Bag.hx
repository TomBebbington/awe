package awe.util;

import haxe.ds.Vector;

/**
	A fast collection type similar to `Array` in usage but does not preserve order
	of its entities. It is faster to add to than an `Array` because it is actually
	represented internally as a `haxe.ds.Vector` with automatic resizing.
**/
abstract Bag<T>(BagData<T>) {
	/** How many items are contained in this bag. **/
	public var length(get, never): Int;
	/** How many items can be stored in this bag without re-allocating. **/
	public var capacity(get, never): Int;

	/**
		Construct a new Bag with the capacity given or 16.
		@param capacity How many items can be stored in this bag without re-allocating.
	**/
	public inline function new(capacity:Int = 16)
		this = new BagData<T>(capacity);

	inline function get_capacity() {
		#if java
			return this.size();
		#else
			return this.data.length;
		#end
	}

	inline function get_length() {
		#if java
			return this.size();
		#else
			return this.length;
		#end
	}

	/** Clear this of items. **/
	public inline function clear():Void
		this.clear();

	/**
		Check if this bag contains the value given.
		@param value The value to check is contained.
		@return If this value is contained in this bag.
	**/
	public inline function contains(value: T): Bool
		return this.contains(value);

	/**
		Add the item to this bag.
		@param item The item to add.
	**/
	public inline function add(item: T):Void
		this.add(item);

	/**
		Ensure that this bag can store up to `capacity` without re-allocating.
		@param capacity The capacity to make sure is allocated.
	**/
	public inline function ensureCapacity(capacity:Int):Void
		this.ensureCapacity(capacity);

	/** Retrieve the `index`th item from this bag. **/
	@:arrayAccess public inline function get(index: Int): Null<T>
		return this.get(index);

	/** Set the `index`th item in this bag to `value`. **/
	@:arrayAccess public inline function set(index: Int, value: T): T
		return this.set(index, value);

	/**
		Iterate through this bag's contents.
		@return The iterator.
	**/
	public inline function iterator():BagIterator<T>
		return this.iterator();

	/**
		Remove `item` from this bag.
		@param item The item to try to remove.
		@return If the item could be found and removed.
	**/
	public inline function remove(item: T):Bool
		return this.remove(item);

	/**
		Remove the last item from this bag.
		@return The ex-last item.
	**/
	public inline function removeLast(): Null<T> {
		#if java
			return this.remove(length - 1);
		#else
			return this.removeLast();
		#end
	}

	/**
		Copy the elements from `srcPos` terminating at `srcPos + len` to `dest` at the offset `destPos`
	**/
	public inline function blit(srcPos: Int, dest: Bag<T>, destPos: Int, len: Int) {
		#if java
			var dest: java.util.ArrayList<T> = cast dest;
			dest.addAll(destPos, this.subList(srcPos, srcPos + len));
		#else
			this.blit(srcPos, cast dest, destPos, len);
		#end
	}

	@:from public static inline function fromVector<T>(vector: Vector<T>) {
		#if java
			var list = new java.util.ArrayList(vector.length);
			for(item in vector)
				list.add(item);
			return cast list;
		#else
			var data = Type.createEmptyInstance(BagData);
			untyped data.data = vector;
			untyped data.length = vector.length;
			return cast data;
		#end
	}
	@:from public static function fromArray<T>(array: Array<T>) {
		#if java
			var list = new java.util.ArrayList(array.length);
			for(item in array)
				list.add(item);
			return cast list;
		#else
			return fromVector(Vector.fromArrayCopy(array));
		#end
	}

	@:to public inline function toArray(): Array<T>
		#if java
			return java.Lib.array(this.toArray(new java.NativeArray(this.size())));
		#else
			return this.data.toArray();
		#end
}

#if java
typedef BagData<T> = java.util.ArrayList<T>;
typedef BagIterator<T> = java.util.Iterator<T>;
#else
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
#end