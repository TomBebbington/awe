package awe.util;

import haxe.ds.StringMap;

/**
	Allows mapping of classes to abritary values.
**/
class ClassMap<V> {
	private var _keys: Array<Class<Dynamic>>;
	private var _map: StringMap<V>;
	/**
		Creates a new `ClassMap`.
	**/
	public function new() {
		_keys = new Array();
		_map = new StringMap();
	}

	/**
		See `Map.set`
	**/
	public inline function set(key: Class<Dynamic>, value: V)
		_map.set(Type.getClassName(key), value);

	/**
		See `Map.get`
	**/
	public inline function get(key: Class<Dynamic>): Null<V>
		return _map.get(Type.getClassName(key));

	/**
		See `Map.exists`
	**/
	public inline function exists(key: Class<Dynamic>): Bool
		return _map.exists(Type.getClassName(key));

	/**
		See `Map.remove`
	**/
	public inline function remove(key: Class<Dynamic>): Bool
		return _map.remove(Type.getClassName(key));

	/**
		See `Map.keys`
	**/
	public inline function keys() : Iterator<Class<Dynamic>>
		return _keys.iterator();

	/**
		See `Map.iterator`
	**/
	public inline function iterator() : Iterator<V>
		return _map.iterator();
	/**
		See `Map.toString`
	**/
	public inline function toString() : String
		return _map.toString();
}