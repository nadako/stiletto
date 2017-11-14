package stiletto;

@:autoBuild(stiletto.Macro.build())
class Module {
	public macro function resolve(self, target:ExprOf<haxe.Constraints.Function>) {
		return Macro.resolve(target, [self]);
	}
}
