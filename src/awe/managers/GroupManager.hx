package awe.managers;

import awe.util.Bag;
import awe.Manager;

class GroupManager extends Manager {
	var groups: Map<String, Bag<Entity>>;

	public function new() {
		groups = new Map<String, Bag<Entity>>();
	}

	/**
		Set the group of the entity.
		@param entity The entity whose group is being set.
		@param group The group to set the entity to.
	**/
	public function add(entity: Entity, group: String): Void {
		if(!groups.exists(group))
			groups.set(group, new Bag(8));
		groups.get(group).add(entity);
	}
	public inline function getEntities(group: String): Bag<Entity>
		return groups.get(group);

	/**
		Get all groups the entity belongs to..
		@param entity The entity to get the groups of.
		@return The groups it belongs to.
	**/
	public function getGroups(entity: Entity): Bag<String> {
		var contained = new Bag(8);
		for(group in groups.keys()) {
			if(groups.get(group).contains(entity))
				contained.add(group);
		}
		return contained;
	}
	/**
		Check if the entity is in the group.
		@param entity The entity to check.
		@param group The group to check the ntity is contained in.
		@return If the entity is in the group.
	**/
	public inline function isInGroup(entity: Entity, group: String): Bool
		return groups.exists(group) && groups.get(group).contains(entity);

	/**
		Remove the entity from the specified group.
		@param entity The entity to remove from the group.
		@param group The group to remove the entity from.
	**/
	public inline function remove(entity: Entity, group: String):Void
		if(groups.exists(group))
			groups.get(group).remove(entity);
	/**
		Completely remove the group.
		@param group The group to remove.
	**/
	public inline function removeGroup(group: String):Void
		groups.remove(group);
}