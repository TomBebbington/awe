package awe;

#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
using haxe.macro.ComplexTypeTools;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using awe.util.MacroTools;
#end
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.Serializer;
import haxe.Unserializer;

/** Represents a list of components. **/
interface IComponentList {
	/** How many components this list can hold without re-allocating. **/
	public var capacity(get, never): Int;
	/** How many components this list contains. **/
	public var length(default, null): Int;
	/**
		Retrieve the component corresponding associated to the ID.
		@param id The `Entity` to retrieve the component for.
		@return The component.
	**/
	public function get<T: Component>(id: Entity): Null<T>;
	/**
		Add the component to this list with the given ID.
		@param id The `Entity` to add a component to.
	**/
	public function add<T: Component>(id: Entity, value: T): Void;
	/**
		Remove the component corresponding to the ID given.
		@param id The `Entity` to remove from this list.
	**/
	public function remove(id: Entity): Void;
	/**
		Iterate through the items in this list.
		@return The iterator for this list.
	**/
	public function iterator(): ComponentListIterator;

	/**
		Serialize this list into a `String`.
		@return The serialized form of this list.
	**/
	public function serialize(): String;
	/**
		Unserialize the serialized value into this list.
		@param serial The serialized version of this list.
	**/
	public function unserialize(value: String): Void;
}
class ComponentList implements IComponentList {
	public var capacity(get, never): Int;
	public var length(default, null): Int;
	var list: Vector<Component>;

	public inline function get_capacity(): Int
		return list.length;

	public function new(capacity: Int = 32) {
		list = new Vector(capacity);
		length = 0;
	}

	@:keep
	public inline function get<T: Component>(entity: Entity): Null<T>
		return cast list.get(entity.id);

	public function add<T: Component>(entity: Entity, value: T): Void {
		if(entity.id >= list.length) {
			var vector = new Vector(capacity << 1);
			Vector.blit(list, 0, vector, 0, list.length);
			list = vector;
		}
		list.set(entity.id, value);
		length = Std.int(Math.max(length, entity.id + 1));
	}
	public inline function remove(entity: Entity): Void
		list[entity.id] = null;

	public inline function iterator()
		return new ComponentListIterator(this);

	public function serialize() {
		var arr = this.list.toArray().slice(0, length);
		return "c" + Serializer.run(arr);
	}

	public function unserialize(value: String) {
		var array:Array<Component> = Unserializer.run(value.substr(1));
		this.length = array.length;
		this.list = Vector.fromArrayCopy(array);
	}
	public static function genericUnserialize(value: String): IComponentList {
		var list:IComponentList = Type.createEmptyInstance(switch(value.charCodeAt(0)) {
			case 'p'.code: cast PackedComponentList;
			case 'c'.code: ComponentList;
			default: null;
		});
		list.unserialize(value);
		return list;
	}
}


class ComponentListItem {
	public var index(default, null): Entity;
	public var component(default, null): Component;

	public function new(index: Entity, component: Component) {
		this.index = index;
		this.component = component;
	}
}

class ComponentListIterator {
	var list: IComponentList;
	var index: Int = 0;
	public function new(list: IComponentList) {
		this.list = list;
	}
	public inline function hasNext()
		return index < list.length;

	public function next():ComponentListItem {
		while(list.get(cast index) == null)
			index++;
		return new ComponentListItem(cast (index + 1, Entity), list.get(cast index++));
	}
}


class PackedComponentList implements IComponentList {
	public var capacity(get, never): Int;
	public var length(default, null): Int;
	var buffer: PackedComponent;
	var bytes: Bytes;
	var size: Int;
	public inline function get_capacity(): Int
		return bytes.length;

	public function new(capacity: Int = 32, size: Int) {
		buffer = cast {};
		length = 0;
		this.size = size;
		bytes = Bytes.alloc(capacity * size);
		buffer.__bytes = bytes;
		buffer.__offset = 0;
	}

	public static macro function build(of: ExprOf<Class<Component>>): ExprOf<PackedComponentList> {
		var ty = of.resolveTypeLiteral();
		var cty = ComponentType.get(ty);
		if(!cty.isPacked())
			Context.error("Component type is not packed", of.pos);
		var size = of.resolveTypeLiteral().toComplexType().sizeOf();
		return macro new PackedComponentList(null, $v{size});
	}

	@:keep
	public inline function get<T: Component>(entity: Entity): Null<T> {
		buffer.__offset = entity.id * size;
		return entity.id >= length ? null : cast buffer;
	}

	public function add<T: Component>(entity: Entity, value: T): Void {
		var value:PackedComponent = cast value;
		if((entity.id + 1) * size > capacity) {
			var nbytes = Bytes.alloc(capacity << 1);
			nbytes.blit(0, bytes, 0, bytes.length);
			bytes = nbytes;
		}
		if(value == null)
			bytes.fill(entity.id * size, size, 0);
		else {
			bytes.blit(entity.id * size, value.__bytes, 0, size);
			value.__bytes = bytes;
			value.__offset = entity.id * size;
		}
		length = Std.int(Math.max(length, entity.id + 1));
	}
	public inline function remove(entity: Entity): Void
		bytes.fill(entity.id * size, size, 0);

	public inline function serialize()
		return "p" + Serializer.run(this.bytes.sub(0, length << 4));

	public function unserialize(value: String) {
		bytes = Unserializer.run(value.substr(1));
		length = bytes.length >> 4;
	}

	public inline function iterator()
		return new ComponentListIterator(this);
}
