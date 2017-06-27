/**
 * Copyright (c) 2016 NumberFour AG.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   NumberFour AG - Initial API and implementation
 */
package org.eclipse.n4js.xsemantics

import com.google.inject.Inject
import org.eclipse.n4js.N4JSInjectorProvider
import org.eclipse.n4js.n4JS.Script
import org.eclipse.n4js.n4JS.VariableStatement
import org.eclipse.n4js.ts.typeRefs.TypeRef
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.eclipse.n4js.typesystem.RuleEnvironmentExtensions.*

/*
 */
@RunWith(XtextRunner)
@InjectWith(N4JSInjectorProvider)
class N4_21_2_UseSiteStructuralTypingTest extends AbstractTypesystemTest {

	@Inject
	extension ParseHelper<Script>

	@Test
	def void testClassesOnly() {

		// class A{}
		val script = '''
			class C{
				public s: string;
				public foo(): void {}
			}
			class A{
				public s: string;
				public foo(): void {}
			}
			class B{
				public s: string;
			}
			var nominal: C;
			var structural: ~C;
			var a: A;
			var b: B;
		'''.parse()

		val G = newRuleEnvironment(script);

		val nominal = script.varDeclTypeByName("nominal")
		val structural = script.varDeclTypeByName("structural")
		val a = script.varDeclTypeByName("a")
		val b = script.varDeclTypeByName("b")

		assertSubtype(G, a, nominal, false)
		assertSubtype(G, b, nominal, false)
		assertSubtype(G, a, structural, true)
		assertSubtype(G, b, structural, false)
	}

	@Test
	def void testClassesOnlyWithWrongFunctionType() {

		// class A{}
		val script = '''
			class C{
				public s: string;
				public foo(): void {}
			}
			class A{
				public s: string;
				public foo(p: number): void {}
			}

			var structural: ~C;
			var a: A;
		'''.parse()

		val G = newRuleEnvironment(script);

		val structural = script.varDeclTypeByName("structural")
		val a = script.varDeclTypeByName("a")

		assertSubtype(G, a, structural, false)
	}

	@Test
	def void testClassesOnlyWithWrongTypes() {

		// class A{}
		val script = '''
			class C{
				public s: string;
				public foo(): void {}
			}
			class A{
				public s: string;
				public foo(p: number): void {}
			}
			class B{
				public s: string;
			}
			var nominal: C;
			var structural: ~C;
			var fields: ~~C;
			var a: A;
			var b: B;
		'''.parse()

		val G = newRuleEnvironment(script);

		val nominal = script.varDeclTypeByName("nominal")
		val structural = script.varDeclTypeByName("structural")
		val fields = script.varDeclTypeByName("fields")
		val a = script.varDeclTypeByName("a")
		val b = script.varDeclTypeByName("b")

		assertSubtype(G, a, nominal, false)
		assertSubtype(G, b, nominal, false)
		assertSubtype(G, a, structural, false)
		assertSubtype(G, b, structural, false)
		assertSubtype(G, a, fields, true)
		assertSubtype(G, b, fields, true)
	}



	private def TypeRef varDeclTypeByName(Script script, String name) {
		(script.scriptElements.findFirst [
			if (it instanceof VariableStatement) {
				it.varDecl.head.name == name
			} else {
				false
			}
		] as VariableStatement).varDecl.head.declaredTypeRef
	}

}
