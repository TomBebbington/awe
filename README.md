# Awe

Awe is a powerful, fast and simple entity component system based on Artemis. In
an entity component system, every thing in the world is represented by an int,
which is called an entity id. You can then attach data to these entities and run
system on entities with a selection of components.

## What can I do to speed up my project?

Nothing. Thanks to the power of Haxe macros, all of the optimisations that can be
done are done in the background.

## Making the `Engine`

The `Engine` is the what encapsulates all the components and systems contained in
the project. To construct it, you call `Entity.build(...)` with the entities and
systems you want it to have.

``` haxe
var engine = Engine.build({
	systems: [InputSystem, MovementSystem, RenderSystem, GravitySystem],
	components: [Input, Position, Velocity, Acceleration, Gravity, Follow]
});
```
## Making Entities

An `Entity` is an individual object in the `Engine`. To construct this, you need to
construct an `Archetype` by calling `Archetype.build(...)` with the components that
make it up.

``` haxe
var playerArchetype = Archetype.build(Input, Position, Velocity, Acceleration, Gravity);
var player = playerArchetype.build();
```