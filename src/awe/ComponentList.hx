package awe;

import haxe.ds.Vector;
import haxe.io.Bytes;

interface IComponentList<T: Component> {
	public var capacity(get, never): Int;
	/** How many components this list contains. **/
	public var length(default, null): Int;
	/** Retrieve the component corresponding associated to the ID. **/
	public function get(id: Int): T;
	/** Add the component to this list with the given ID. **/
	public function add(id: Int, value: T): Void;
	/** Remove the component corresponding to the ID given. **/
	public function remove(id: Int): Void;
	/** Iterate through the items in this list. **/
	public function iterator(): ComponentListIterator<T>;
}

class ComponentList<T: Component> implements IComponentList<T> {
	public var capacity(get, never): Int;
	public var length(default, null): Int;
	var list: Vector<T>;

	public static inline function create<T: Component>(cl: Class<T>): IComponentList<T> {
		var ty = Type.createEmptyInstance(cl).getType();
		return ty.isPacked() ? new PackedComponentList(cl) : new ComponentList();
	}

	public inline function get_capacity(): Int
		return list.length;

	public function new(capacity: Int = 32) {
		list = new Vector(capacity);
		length = 0;
	}

	@:keep
	public inline function get(id: Int): T
		return list.get(id);

	public function add(id: Int, value: T): Void {
		if(id >= list.length) {
			var vector = new Vector(capacity << 1);
			Vector.blit(list, 0, vector, 0, list.length);
			list = vector;
		}
		list.set(id, value);
		length = Std.int(Math.max(length, id + 1));
	}
	public inline function remove(id: Int): Void {
		list[id] = null;
	}
	public inline function iterator()
		return new ComponentListIterator(this);
}


@:generic
class ComponentListItem<T: Component> {
	public var index(default, null): Int;
	public var component(default, null): T;

	public function new(index: Int, component: T) {
		this.index = index;
		this.component = component;
	}
}


@:generic
class ComponentListIterator<T: Component> {
	var list: IComponentList<T>;
	var index = 0;
	public function new(list: IComponentList<T>) {
		this.list = list;
	}
	public inline function hasNext()
		return index < list.length;

	public function next():ComponentListItem<T> {
		while(list.get(index) == null)
			index++;
		return new ComponentListItem(index + 1, list.get(index++));
	}
}


class PackedComponentList<T: Component> implements IComponentList<T> {
	public var capacity(get, never): Int;
	public var length(default, null): Int;
	var buffer: T;
	var bytes: Bytes;
	var size: Int;
	public inline function get_capacity(): Int
		return bytes.length;

	public function new(capacity: Int = 32, cl: Class<T>) {
		buffer = Type.createEmptyInstance(cl);
		length = 0;
		size = untyped cl.__size;
		if(size == null)
			throw Type.getClassName(cl) + " is not packed";
		bytes = Bytes.alloc(capacity * size);
		untyped buffer.__bytes = bytes;
		untyped buffer.__offset = 0;
	}

	@:keep
	public inline function get(id: Int): T {
		untyped buffer.__offset = id * size;
		return id >= length ? null : buffer;
	}

	public function add(id: Int, value: T): Void {
		if(id * size > capacity) {
			var nbytes = Bytes.alloc(capacity << 1);
			nbytes.blit(0, bytes, 0, bytes.length);
			bytes = nbytes;
		}
		bytes.blit(id * size, untyped value.__bytes, 0, size);
		untyped value.__bytes = bytes;
		length = Std.int(Math.max(length, id + 1));
	}
	public inline function remove(id: Int): Void
		bytes.fill(id * size, size, 0);

	public inline function iterator()
		return new ComponentListIterator(this);
}
