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
package org.eclipse.n4js.common.unicode.generator

import com.google.common.base.Charsets
import com.google.common.base.Strings
import com.google.common.io.Files
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter

import static extension org.eclipse.n4js.common.unicode.CharTypes.*
import java.io.IOException

class UnicodeGrammarGenerator {

	/**
	 * This generator isn't called by the GenerateUnicode.mwe2, this have to be done manually
	 */
	def static void main(String[] args) throws IOException {
//		if (args.head == '-file')
			new UnicodeGrammarGenerator
//		else
//			println(generateUnicodeRules)
	}

	/**
	 * The write-on-instantiation allows to use this generator in mwe2 as #bean
	 */
	new() throws IOException {
		Files.write(generateUnicodeRules, new File('grammar-gen/org/eclipse/n4js/common/unicode/Unicode.xtext'), Charsets.UTF_8)
	}

	def static generateUnicodeRules() '''
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

		// Important note:
		// This grammar is auto generated by the
		// org.eclipse.n4js.common.unicode.generator.UnicodeGrammarGenerator
		//
		// Rather than editing this manually, update the generator instead!

		grammar org.eclipse.n4js.common.unicode.Unicode

		import "http://www.eclipse.org/emf/2002/Ecore" as ecore

		terminal fragment HEX_DIGIT:
			(DECIMAL_DIGIT_FRAGMENT|'a'..'f'|'A'..'F')
		;
		terminal fragment DECIMAL_INTEGER_LITERAL_FRAGMENT:
			  '0'
			| '1'..'9' DECIMAL_DIGIT_FRAGMENT*
		;
		terminal fragment DECIMAL_DIGIT_FRAGMENT:
			'0'..'9'
		;
		terminal fragment ZWJ:
			'\u200D'
		;
		terminal fragment ZWNJ:
			'\u200C'
		;
		terminal fragment BOM:
			'\uFEFF'
		;
		terminal fragment WHITESPACE_FRAGMENT:
			'\u0009' | '\u000B' | '\u000C' | '\u0020' | '\u00A0' | BOM | UNICODE_SPACE_SEPARATOR_FRAGMENT
		;
		terminal fragment LINE_TERMINATOR_FRAGMENT:
			'\u000A' | '\u000D' | '\u2028' | '\u2029'
		;
		terminal fragment LINE_TERMINATOR_SEQUENCE_FRAGMENT:
			'\u000A' | '\u000D' '\u000A'? | '\u2028' | '\u2029'
		;
		terminal fragment SL_COMMENT_FRAGMENT:
			'//' (!LINE_TERMINATOR_FRAGMENT)*
		;
		terminal fragment ML_COMMENT_FRAGMENT:
			'/*' -> '*/'
		;

		terminal fragment UNICODE_COMBINING_MARK_FRAGMENT:
			// any character in the Unicode categories
			// ―Non-spacing mark (Mn)
			// ―Combining spacing mark (Mc)
			«generateUnicodeRules [ isCombiningMark ]»
		;
		terminal fragment UNICODE_DIGIT_FRAGMENT:
			// any character in the Unicode categories
			// ―Decimal number (Nd)
			«generateUnicodeRules [ isDigit ]»
		;
		terminal fragment UNICODE_CONNECTOR_PUNCTUATION_FRAGMENT:
			// any character in the Unicode categories
			// ―Connector punctuation (Pc)
			«generateUnicodeRules [ isConnectorPunctuation ]»
		;
		terminal fragment UNICODE_LETTER_FRAGMENT:
			// any character in the Unicode categories
			// ―Uppercase letter (Lu)
			// ―Lowercase letter (Ll)
			// ―Titlecase letter (Lt)
			// ―Modifier letter (Lm)
			// ―Other letter (Lo)
			// ―Letter number (Nl)
			«generateUnicodeRules [ isLetter ]»
		;
		terminal fragment UNICODE_SPACE_SEPARATOR_FRAGMENT:
			// any character in the Unicode categories
			// ―space separator (Zs)
			«generateUnicodeRules [ isSpaceSeparator ]»
		;
		terminal fragment ANY_OTHER:
			.
		;
	'''
	def static generateUnicodeRules((int)=>boolean guard) {
		var Character prev = null;
		var run = false;
		var first = true;
		var char c = Character.MIN_VALUE
		val result = new StringWriter
		val printer = new PrintWriter(result, true)
		while(true) {
			if (guard.apply(c as int)) {
				if (!run) {
					prev = c;
					run = true;
				}
			} else {
				if (run) {
					if (!first) {
						printer.print("| ");
					} else {
						printer.print("  ");
						first = false;
					}
					printer.print("'\\u" + Strings.padStart(Integer.toHexString(prev).toUpperCase(), 4, '0') + "'");
					if (prev.charValue() == c - 1) {
						printer.println();
					} else {
						printer.println("..'\\u" + Strings.padStart(Integer.toHexString(c - 1).toUpperCase(), 4, '0') + "'");
					}
					prev = null;
					run = false;
				}
			}
			c = (c + 1) as char
			if (c == Character.MAX_VALUE) {
				return result;
			}
		}

	}


}
