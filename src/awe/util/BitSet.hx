package awe.util;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.Int32Array;

typedef BitSetData =
	#if java
		java.util.BitSet;
	#else
		Bag<Int>;
	#end

/**
	Compactly stores bits.
**/
abstract BitSet(BitSetData) {
	/** How many bits this can hold **/
	public var capacity(get, never): Int;

	private static inline function wordIndex(bitIndex: Int)
		return bitIndex >> 5;

	/** 
		Create a new BitSet with the given value for its first word.
		@param value The value to use for the first word.
	**/
	public inline function new(value: Int = 0) {
		#if java
			var array = new java.NativeArray<java.StdTypes.Int64>(1);
			array[0] = value;
			this = java.util.BitSet.valueOf(array);
		#else
			this = new Bag<Int>(1);
		#end
		this.set(0, value);
	}

	/**
		Convert this to a Bag of Ints.
		@return The converted value.
	**/
	@:to public inline function toBag(): Bag<Int> {
		return this;
	}

	private function resize(capacity: Int) {
		capacity = Std.int(Math.ceil(capacity / 32));
		var newBag = new Bag<Int>(capacity);

	}
	inline function get_capacity():Int
		#if java
			return this.size();
		#else
			return this.length << 5;
		#end
	/**
		Flip the bit at `index` to its compliment.
		@param index The bit index to flip.
	**/
	public inline function flip(index: Int) {
		#if java
			this.flip(index);
		#else
			this[wordIndex(index)] ^= 1 << (index % 32);
		#end
	}
	/**
		Flip all the bits between `from` and `to` to their compliment.
		@param from The initial bit index.
		@param to The terminal bit index.
	**/
	public inline function flipRange(from: Int, to: Int) {
		#if java
			this.flip(from, to);
		#else
			for(index in from...to)
				flip(index);
		#end
	}
	/**
		Set the bit at `index` to `value`.
		@param index The bit index to set.
		@param value The new value of the bit.
		@return The new value of the bit.
	**/
	@:arrayAccess
	public inline function set(index: Int, value: Bool): Bool {
		#if java
			this.set(index, value);
		#else
			value ? setBit(index) : clearBit(index);
		#end
		return value;
	}
	/**
		Set the bit at `index` to true.
		@param index The bit index to set.
	**/
	public inline function setBit(index: Int) {
		#if java
			this.set(index);
		#else
			var word = wordIndex(index);
			var cword = this[word];
			if(cword == null)
				cword = 0;
			this[word] = cword | 1 << (index % 32);
		#end
	}
	/**
		Set all the bits `from` and `to`.
		@param from The initial bit index.
		@param to The terminal bit index.
	**/
	public inline function setRange(from: Int, to: Int) {
		#if java
			this.set(from, to);
		#else
			for(index in from...to)
				setBit(index);
		#end
	}
	/**
		Set the bit at `index` to `false`.
		@param index The bit index to clear.
	**/
	public inline function clearBit(index: Int) {
		#if java
			this.clear(index);
		#else
			this[wordIndex(index)] &= ~(1 << (index % 32));
		#end
	}
	/**
		Set all the bits `from` and `to` to `false`.
		@param from The initial bit index.
		@param to The terminal bit index.
	**/
	public inline function clearRange(from: Int, to: Int) {
		#if java
			this.clear(from, to);
		#else
			for(index in from...to)
				clearBit(index);
		#end
	}
	/**
		Check if this `BitSet` contains no true bits.
		@return If it is empty or not.
	**/
	public inline function isEmpty():Bool
		#if java
			return this.isEmpty();
		#else
			return this.capacity <= 1 && this[0] == 0;
		#end

	/**
		Completely clear this of any bits.
	**/
	public inline function clear() {
		this.clear();
		#if !java
			this.add(0);
		#end
	}

	/**
		Check if this contains `set`.
		@param set The set to check is contained inside this one.
		@return If it is contained in this or not.
	**/
	public function contains(set: BitSet): Bool {
		#if java
			var next:Int = 0;
			while((next = set.nextSetBit(next)) >= 0)
				if(!this.get(next))
					return false;
			return true;
		#else
			var other: BitSet = cast this;
			var length = Std.int(Math.min(this.capacity, set.toBag().capacity));
			for(i in 0...length) {
				if(set.toBag()[i] & ~this[i] != 0)
					return false;
			}
			return true;
		#end
	}

	/**
		Check if this intersects with `set`.
		@param set The set to check has at least one bit in common with this one.
		@return If it intersects this or not.
	**/
	public function intersects(set: BitSet): Bool {
		#if java
			return this.intersects(cast set);
		#else
			var length = Std.int(Math.min(this.capacity, set.toBag().capacity));
			for(i in 0...length)
				if(this[i] & set.toBag()[i] != 0)
					return true;
			return false;
		#end
	}

	/**
		Perform a bitwise AND on this and `set`.
		@param set The set to run AND on.
	**/
	@:op(A &= B)
	public function and(set: BitSet) {
		#if java
			this.and(set);
		#else
			var set: Array<Int> = cast set;
			var length = Std.int(Math.min(set.length, this.length));
			for(i in 0...length)
				this[i] &= set[i];
		#end
	}

	/**
		Perform a bitwise OR on this and `set`.
		@param set The set to run OR on.
	**/
	@:op(A |= B)
	public function or(set: BitSet) {
		#if java
			this.or(set);
		#else
			var set: Array<Int> = cast set;
			var length = Std.int(Math.min(set.length, this.length));
			for(i in 0...length)
				this[i] |= set[i];
		#end
	}

	/**
		Get the bit at `index`.
		@param index The index to get the bit of.
		@return The bit at `index`.
	**/
	@:arrayAccess
	public inline function get(index: Int): Bool
		#if java
			return this.get(index);
		#else
			return this[wordIndex(index)] & (1 << (index & 0xFF)) != 0;
		#end

	/**
		Convert this to `Bytes`.
		@return The converted value.
	**/
	@:to public inline function toBytes(): Bytes {
		#if java
			return new Bytes(this.toByteArray());
		#else
			var data:Bag.BagData<Int> = cast this;
			return Int32Array.fromArray(data.data.toArray()).view.buffer;
		#end
	}

	@:from public static inline function fromArray(array: Array<Int>): BitSet
		return cast Bag.fromArray(array);

	/**
		Create a string representation of this set and return it.
		@return The string representation of this set.
	**/
	public function toString(): String {
		#if java
			return this.toString();
		#else
			var buf = new StringBuf();
			buf.add("{ ");
			for(i in 0...(this.capacity << 5)) {
				if(i > 0 && i % 8 == 0)
					buf.add("_");
				buf.add(get(i) ? "1" : "0");
			}
			buf.add(" }");
			return buf.toString();
		#end
	}
}