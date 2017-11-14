@:dce
class Stiletto {
	public static macro function resolve(target, factories) {
		var factories = switch factories.expr {
			case EArrayDecl(exprs): exprs;
			case _: throw new haxe.macro.Expr.Error("Dependency factories argument must be an array declaration", factories.pos);
		}
		return stiletto.Macro.resolve(target, factories);
	}
}
