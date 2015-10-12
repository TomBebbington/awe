import awe.util.Bag;

class Main {
	static function main() {
		var bag = new Bag();
		bag.add(32);
		trace(bag.contains(32));
		trace(bag.contains(31));
	}
}