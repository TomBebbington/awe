package awe.util;

#if (flash || (js && !node) || java || python)
	typedef Timer = haxe.Timer;
#elseif (neko || cpp)
	import #if neko neko #elseif cpp cpp #end .vm.Thread;

	class Timer {
		var me: Thread = null;
		public function new(time_ms: Int) {
			var time_f = time_ms * 0.001;
			me = Thread.create(function() {
				while(true) {
					this.run();
					Sys.sleep(time_f);
				}
			});
		}
		public dynamic function run(): Void {
			
		}
		public static inline function stamp(): Float
			return Sys.time();
	}
#end