package stiletto;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

typedef TypeKey = String;

typedef Factory = {
	var expr:Expr;
	var dependencies:Array<TypeKey>;
}

class Macro {
	static function build() {
		var fields = Context.getBuildFields();
		var newFields = new Array<Field>();
		var ctorArgs = new Array<FunctionArg>();
		var ctorAssigns = new Array<Expr>();

		for (field in fields) {
			switch field.kind {
				case FFun(fun) if (fun.expr == null):
					if (fun.ret == null) throw new Error("Provider function return type must be specified", field.pos);

					var storageName = "valueFor" + field.name.charAt(0).toUpperCase() + field.name.substring(1);

					newFields.push({
						pos: field.pos,
						name: storageName,
						kind: FVar(fun.ret, null)
					});

					field.access = [APublic, AInline];
					field.meta.push({pos: field.pos, name: ":provider"});
					fun.expr = macro @:pos(field.pos) return this.$storageName;

					ctorArgs.push({name: storageName, type: fun.ret});
					ctorAssigns.push(macro @:pos(field.pos) this.$storageName = $i{storageName});

				case _:
					throw new Error("Module sub-classes must only have body-less methods", field.pos);
			}
		}

		newFields.push({
			pos: Context.currentPos(),
			name: "new",
			access: [APublic, AInline],
			kind: FFun({
				args: ctorArgs,
				ret: null,
				expr: macro $b{ctorAssigns},
			})
		});

		return fields.concat(newFields);
	}

	public static function resolve(target:Expr, dependencyFactories:Array<Expr>):Expr {
		var factories = new Map<TypeKey,Factory>();

		function makeTypeKey(type:Type):TypeKey {
			return type.toString();
		}

		function isModule(cl:ClassType):Bool {
			return switch cl {
				case {pack: ["stiletto"], name: "Module"}: true;
				case _ if (cl.superClass != null): isModule(cl.superClass.t.get());
				case _: false;
			}
		}

		function registerFactory(expr:Expr) {
			switch Context.typeof(expr) {
				case TFun(args, ret):
					var dependencies = [for (arg in args) makeTypeKey(arg.t)];
					var target = makeTypeKey(ret);

					var factory = factories.get(target);
					if (factory != null) {
						Context.warning("(previous factory was defined here)", factory.expr.pos);
						throw new Error("Duplicate dependency factory", expr.pos);
					}

					factory = {
						expr: expr,
						dependencies: dependencies
					};
					factories.set(target, factory);

				case TInst(_.get() => cl, _) if (isModule(cl)):
					for (field in cl.fields.get()) {
						if (field.meta.has(":provider")) {
							registerFactory({pos: field.pos, expr: EField(expr, field.name)});
						}
					}

				case _:
					throw new Error("Dependency factory must be a function or Module sub-class", expr.pos);
			}
		}

		for (expr in dependencyFactories)
			registerFactory(expr);

		function resolveFactory(factory:Factory):Expr {
			var args = [];
			for (dep in factory.dependencies) {
				var depFactory = factories.get(dep);
				if (depFactory == null)
					throw new Error("Unsatisfied dependency for type " + dep, factory.expr.pos);
				args.push(resolveFactory(depFactory));
			}
			return macro (${factory.expr})($a{args});
		}

		switch Context.typeof(target) {
			case TFun(args, ret):
				return resolveFactory({expr: target, dependencies: [for (arg in args) makeTypeKey(arg.t)]});
			case _:
				throw new Error("Target must be a function", target.pos);
		}
	}
}
#end
