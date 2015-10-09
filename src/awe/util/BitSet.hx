package awe.util;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.Int32Array;

/**
	Compactly stores bits.
**/
abstract BitSet(Bag<Int>) {
	/** How many bits this can hold **/
	public var capacity(get, set): Int;

	private static inline function wordIndex(bitIndex: Int)
		return bitIndex >> 5;

	/** 
		Create a new BitSet with the given value for its first word.
		@param value The value to use for the first word.
	**/
	public inline function new(value: Int = 0) {
		this = new Bag<Int>(1);
		this.set(0, value);
	}

	/**
		Convert this to a Bag of Ints.
		@return The converted value.
	**/
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
		Flip the bit at `index` to its compliment.
		@param index The bit index to flip.
	**/
	public inline function flip(index: Int) {
		this[wordIndex(index)] ^= 1 << (index % 32);
	}
	/**
		Flip all the bits between `from` and `to` to their compliment.
		@param from The initial bit index.
		@param to The terminal bit index.
	**/
	public inline function flipRange(from: Int, to: Int) {
		for(index in from...to)
			flip(index);
	}
	/**
		Set the bit at `index` to `value`.
		@param index The bit index to set.
		@param value The new value of the bit.
		@return The new value of the bit.
	**/
	@:arrayAccess
	public inline function set(index: Int, value: Bool): Bool {
		value ? setBit(index) : clearBit(index);
		return value;
	}
	/**
		Set the bit at `index` to true.
		@param index The bit index to set.
	**/
	public inline function setBit(index: Int) {
		var word = wordIndex(index);
		var cword = this[word];
		if(cword == null)
			cword = 0;
		this[word] = cword | 1 << (index % 32);
	}
	/**
		Set all the bits `from` and `to`.
		@param from The initial bit index.
		@param to The terminal bit index.
	**/
	public inline function setRange(from: Int, to: Int) {
		for(index in from...to)
			setBit(index);
	}
	/**
		Set the bit at `index` to `false`.
		@param index The bit index to clear.
	**/
	public inline function clearBit(index: Int) {
		this[wordIndex(index)] &= ~(1 << (index % 32));
	}
	/**
		Set all the bits `from` and `to` to `false`.
		@param from The initial bit index.
		@param to The terminal bit index.
	**/
	public inline function clearRange(from: Int, to: Int) {
		for(index in from...to)
			clearBit(index);
	}
	/**
		Check if this `BitSet` is empty.
		@return If it is empty or not.
	**/
	public inline function isEmpty():Bool
		return this.capacity <= 1 && this[0] == 0;

	/**
		Completely clear this of any bits.
	**/
	public inline function clear() {
		this.clear();
		this.add(0);
	}

	/**
		Check if this contains `set`.
		@param set The set to check is contained inside this one.
		@return If it is contained in this or not.
	**/
	public function contains(set: BitSet): Bool {
		var length = Std.int(Math.min(this.capacity, set.toBag().capacity));
		for(i in 0...length)
			if(this[i] != set.toBag()[i])
				return false;
		return true;
	}

	/**
		Check if this intersects with `set`.
		@param set The set to check has at least one bit in common with this one.
		@return If it intersects this or not.
	**/
	public function intersects(set: BitSet): Bool {
		var length = Std.int(Math.min(this.capacity, set.toBag().capacity));
		for(i in 0...length)
			if(this[i] & set.toBag()[i] != 0)
				return true;
		return false;
	}

	/**
		Perform a bitwise AND on this and `set`.
		@param set The set to run AND on.
	**/
	@:op(A &= B)
	public function and(set: BitSet) {
		var set: Array<Int> = cast set;
		var length = Std.int(Math.min(set.length, this.length));
		for(i in 0...length)
			this[i] &= set[i];
	}

	/**
		Perform a bitwise OR on this and `set`.
		@param set The set to run OR on.
	**/
	@:op(A |= B)
	public function or(set: BitSet) {
		var set: Array<Int> = cast set;
		var length = Std.int(Math.min(set.length, this.length));
		for(i in 0...length)
			this[i] |= set[i];
	}

	/**
		Get the bit at `index`.
		@param index The index to get the bit of.
		@return The bit at `index`.
	**/
	@:arrayAccess
	public inline function get(index: Int): Bool
		return this[wordIndex(index)] & (1 << (index % 32)) != 0;

	/**
		Convert this to `Bytes`.
		@return The converted value.
	**/
	@:to public inline function toBytes(): Bytes {
		var data:Bag.BagData<Int> = cast this;
		return Int32Array.fromArray(data.data.toArray()).view.buffer;
	}

	@:from public static inline function fromArray(array: Array<Int>): BitSet
		return cast array;

	/**
		Create a string representation of this set and return it.
		@return The string representation of this set.
	**/
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