require "ast/match"

module Ast
  describe Match, "matched" do
    it "should locate root" do
      ast = Parser::CurrentRuby.parse("foo.bar")
      match = Match.new(ast, [])
      
      expect(match.matched).to eq(ast)
    end
    
    it "should locate nested elements" do
      ast = Parser::CurrentRuby.parse("def run\nfoo.bar\nbaz.baaz\nend")
      match = Match.new(ast, [2, 1])
      
      expect(match.matched).to eq(ast.children[2].children[1])
    end
    
    it "should error on non-existent element" do
      ast = Parser::CurrentRuby.parse("foo.bar")
      match = Match.new(ast, [2])
      
      expect { match.matched }.to raise_error
    end
  end
  
  describe Match, "child" do
    it "should return submatch" do
      ast = Parser::CurrentRuby.parse("foo.bar")
      match = Match.new(ast, [0])
      
      expect(match.child).to eq(Match.new(Parser::CurrentRuby.parse("foo"), []))
    end
    
    it "should return nil for empty location" do
      ast = Parser::CurrentRuby.parse("foo.bar")
      match = Match.new(ast, [])
      
      expect(match.child).to be_nil
    end
  end
  
  describe Match, "replace" do
    it "should replace root" do
      ast = Parser::CurrentRuby.parse("foo.bar")
      match = Match.new(ast, [])
      
      new_root = Parser::CurrentRuby.parse("a")
      match.replace { new_root }

      expect(match.matched).to eq(new_root)
      expect(match.ast).to eq(new_root)
    end
    
    it "should replace nested element" do
      ast = Parser::CurrentRuby.parse("foo.bar")
      match = Match.new(ast, [0])
      
      new_leaf = Parser::CurrentRuby.parse("a")
      match.replace { new_leaf }

      expect(match.matched).to eq(new_leaf)
      expect(match.ast).to eq(Parser::CurrentRuby.parse("a.bar"))
    end
    
    it "should replace doubly nested element" do
      ast = Parser::CurrentRuby.parse("foo.bar.baz")
      match = Match.new(ast, [0, 0])
      
      new_leaf = Parser::CurrentRuby.parse("a")
      match.replace { new_leaf }

      expect(match.matched).to eq(new_leaf)
      expect(match.ast).to eq(Parser::CurrentRuby.parse("a.bar.baz"))
    end
    
    it "should replace last child" do
      ast = Parser::CurrentRuby.parse("foo.bar.baz")
      match = Match.new(ast, [1])
      
      new_leaf = :a
      match.replace { new_leaf }

      expect(match.matched).to eq(new_leaf)
      expect(match.ast).to eq(Parser::CurrentRuby.parse("foo.bar.a"))
    end
  end
end