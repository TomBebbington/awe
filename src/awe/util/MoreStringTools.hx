package awe.util;

using StringTools;

class MoreStringTools {
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
		return if(last == "y")
			word.substring(0, word.length - 1) + "ies";
		else if(isVowel(last) || word.endsWith("tion") || last == "w" || last == "t" || last == "d")
			word + "s";
		else
			word + "es";
	}
}