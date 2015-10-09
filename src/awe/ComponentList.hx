package awe;

import haxe.ds.Vector;
import haxe.io.Bytes;

/** Represents a list of components. **/
interface IComponentList<T: Component> {
	/** How many components this list can hold without re-allocating. **/
	public var capacity(get, never): Int;
	/** How many components this list contains. **/
	public var length(default, null): Int;
	/**
		Retrieve the component corresponding associated to the ID.
		@param id The `Entity` to retrieve the component for.
		@return The component.
	**/
	public function get(id: Entity): T;
	/**
		Add the component to this list with the given ID.
		@param id The `Entity` to add a component to.
	**/
	public function add(id: Entity, value: T): Void;
	/**
		Remove the component corresponding to the ID given.
		@param id The `Entity` to remove from this list.
	**/
	public function remove(id: Int): Void;
	/**
		Iterate through the items in this list.
		@return The iterator for this list.
	**/
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
	public inline function get(entity: Entity): T
		return list.get(entity.id);

	public function add(entity: Entity, value: T): Void {
		if(entity.id >= list.length) {
			var vector = new Vector(capacity << 1);
			Vector.blit(list, 0, vector, 0, list.length);
			list = vector;
		}
		list.set(entity.id, value);
		length = Std.int(Math.max(length, entity.id + 1));
	}
	public inline function remove(id: Int): Void {
		list[id] = null;
	}
	public inline function iterator()
		return new ComponentListIterator(this);
}


@:generic
class ComponentListItem<T: Component> {
	public var index(default, null): Entity;
	public var component(default, null): T;

	public function new(index: Entity, component: T) {
		this.index = index;
		this.component = component;
	}
}


@:generic
class ComponentListIterator<T: Component> {
	var list: IComponentList<T>;
	var index: Int = 0;
	public function new(list: IComponentList<T>) {
		this.list = list;
	}
	public inline function hasNext()
		return index < list.length;

	public function next():ComponentListItem<T> {
		while(list.get(cast index) == null)
			index++;
		return new ComponentListItem(cast (index + 1, Entity), list.get(cast index++));
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
	public inline function get(entity: Entity): T {
		untyped buffer.__offset = entity.id * size;
		return entity.id >= length ? null : buffer;
	}

	public function add(entity: Entity, value: T): Void {
		if(entity.id * size > capacity) {
			var nbytes = Bytes.alloc(capacity << 1);
			nbytes.blit(0, bytes, 0, bytes.length);
			bytes = nbytes;
		}
		bytes.blit(entity.id * size, untyped value.__bytes, 0, size);
		untyped value.__bytes = bytes;
		length = Std.int(Math.max(length, entity.id + 1));
	}
	public inline function remove(id: Int): Void
		bytes.fill(id * size, size, 0);

	public inline function iterator()
		return new ComponentListIterator(this);
}
