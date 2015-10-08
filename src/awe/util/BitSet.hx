package awe.util;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.Int32Array;

abstract BitSet(Bag<Int>) {
	public var capacity(get, set): Int;

	private static inline function wordIndex(bitIndex: Int)
		return bitIndex >> 5;

	public inline function new(value: Int = 0) {
		this = new Bag<Int>(1);
		this.set(0, value);
	}

	@:to public inline function toBag(): Bag<Int>
		return this;

	private function resize(capacity: Int) {
		capacity = Std.int(Math.ceil(capacity / 32));
		var newBag = new Bag<Int>(capacity);

	}
	inline function get_capacity():Int
		return this.length << 5;

	inline function set_capacity(capacity: Int): Int {
		if(capacity > get_capacity())
			resize(capacity);
		return capacity;
	}
	/**
	* Flip the bit at the index given to its compliment.
	**/
	public inline function flip(index: Int) {
		this[wordIndex(index)] ^= 1 << (index % 32);
	}
	public inline function flipRange(from: Int, to: Int) {
		for(index in from...to)
			flip(index);
	}
	@:arrayAccess
	public inline function set(index: Int, value: Bool): Bool {
		value ? setBit(index) : clearBit(index);
		return value;
	}
	/**
	* Set the bit at the index given to true.
	**/
	public inline function setBit(index: Int) {
		var word = wordIndex(index);
		var cword = this[word];
		if(cword == null)
			cword = 0;
		this[word] = cword | 1 << (index % 32);
	}
	public inline function setRange(from: Int, to: Int) {
		for(index in from...to)
			setBit(index);
	}
	/**
	* Set the bit at the index given to false.
	**/
	public inline function clearBit(index: Int) {
		this[wordIndex(index)] &= ~(1 << (index % 32));
	}
	public inline function clearRange(from: Int, to: Int) {
		for(index in from...to)
			clearBit(index);
	}
	public inline function isEmpty():Bool
		return this.capacity <= 1 && this[0] == 0;

	public inline function clear() {
		this.clear();
		this.add(0);
	}

	public function contains(set: BitSet): Bool {
		var length = Std.int(Math.min(this.capacity, set.toBag().capacity));
		for(i in 0...length)
			if(this[i] != set.toBag()[i])
				return false;
		return true;
	}

	public function intersects(set: BitSet): Bool {
		var length = Std.int(Math.min(this.capacity, set.toBag().capacity));
		for(i in 0...length)
			if(this[i] & set.toBag()[i] != 0)
				return true;
		return false;
	}

	@:op(A &= B)
	public function and(set: BitSet) {
		var set: Array<Int> = cast set;
		var length = Std.int(Math.min(set.length, this.length));
		for(i in 0...length)
			this[i] &= set[i];
	}

	@:op(A |= B)
	public function or(set: BitSet) {
		var set: Array<Int> = cast set;
		var length = Std.int(Math.min(set.length, this.length));
		for(i in 0...length)
			this[i] |= set[i];
	}

	/**
	* Get the bit at the index given.
	**/
	@:arrayAccess
	public inline function get(index: Int): Bool
		return this[wordIndex(index)] & (1 << (index % 32)) != 0;

	@:to public inline function toBytes(): Bytes {
		var data:Bag.BagData<Int> = cast this;
		return Int32Array.fromArray(data.data.toArray()).view.buffer;
	}

	@:from public static inline function fromArray(array: Array<Int>): BitSet
		return cast array;

	public function toString(): String {
		var buf = new StringBuf();
		buf.add("{ ");
		for(i in 0...(this.capacity << 5)) {
			if(i > 0 && i % 8 == 0)
				buf.add("_");
			buf.add(get(i) ? "1" : "0");
		}
		buf.add(" }");
		return buf.toString();
	}
}