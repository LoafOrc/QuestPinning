using System.Collections.Generic;
using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;

namespace QuestPinning.Patches;

public class ShopPatches : IScriptMod {
	public bool ShouldRun(string path) => path == "res://Scenes/HUD/Shop/shop.gdc";

	public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens) {
		MultiTokenWaiter waiter = new MultiTokenWaiter([
			t => t is IdentifierToken identifier && identifier.Name == "button",
			t => t.Type is TokenType.Period,
			t => t is IdentifierToken identifier && identifier.Name == "_setup",
			
			// this isn't really needed but i need to match upto the newline
			t => t.Type is TokenType.ParenthesisOpen,
			t => t.Type is TokenType.Identifier,
			t => t.Type is TokenType.Comma,
			t => t.Type is TokenType.Identifier,
			t => t.Type is TokenType.ParenthesisClose,
			t => t.Type is TokenType.Newline,
		]);
        
		foreach (Token token in tokens) {
			yield return token;

			if (waiter.Check(token)) {

				yield return new IdentifierToken("get_node");
				yield return new Token(TokenType.ParenthesisOpen);
				yield return new ConstantToken(new StringVariant("/root/meloaforcquestpinning"));
				yield return new Token(TokenType.ParenthesisClose);
				yield return new Token(TokenType.Period);
				yield return new IdentifierToken("_quest_button_patch");
				yield return new Token(TokenType.ParenthesisOpen);
				yield return new IdentifierToken("button");
				yield return new Token(TokenType.Comma);
				yield return new IdentifierToken("quest");
				yield return new Token(TokenType.ParenthesisClose);
				
				yield return token;
			}
		}
	}
}