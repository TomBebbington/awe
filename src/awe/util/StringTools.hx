package awe.util;

class StringTools {
	/** Returns true if this char a vowel. **/
	public static function isVowel(char: String):Bool
		return switch(char) {
			case 'a' | 'e' | 'i' | 'u' | 'o':
				true;
			default: false;
		};
	/** Transform `word` into a plural. **/
	public static function pluralize(word: String):String  {
		var last = word.charAt(word.length - 1);
		if(last == "y") {
			word = word.substring(0, word.length - 1) + "i";
			last = "i";
		}
		return isVowel(last) ? word + "es" : word + "s";
	}
}