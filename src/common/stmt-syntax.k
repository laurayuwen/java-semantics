require "core-sorts.k"
require "core-classes.k"

module STMT-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES

syntax Stmt ::= StmtWithoutTrailing|LabeledStmt|IfThenElseStmt|IfThenStmt|WhileStmt|ForStmt

syntax IfThenElseStmt ::= "if" "(" Exp ")" "{" K "}" "else" "{" K "}" [strict(1),klabel('If)]
syntax IfThenStmt ::= "if" "(" Exp ")" "{" K "}" [strict(1),klabel('If)]
syntax WhileStmt ::= "while" "(" Exp ")" "{" K "}" [strict(1),klabel('While)]
syntax ForStmt ::= "for" "(" K ";" K ";" K ")" "{" K "}" [klabel('For)]
syntax LabeledStmt ::= Id ":" K [klabel('Labeled)]


syntax StmtWithoutTrailing ::= Block
|EmptyStmt
|ExprStmt
|AssertStmt
|SwitchStmt
|DoStmt
|TryStmt
|StackConsumerStmt
|SynchronizedStmt

syntax BlockStmt ::= Stmt|LocalVarDecStmt|ClassDec
syntax LocalVarDecStmt ::= Type Id ";" [klabel('LocalVarDec)]
syntax ClassBody ::= "{" KListWrap "}" [klabel('ClassBody)]
syntax ClassDecHead ::= KListWrap "class" Id K K K [klabel('ClassDecHead)]
syntax ClassDec ::= ClassDecHead ClassBody [klabel('ClassDec)]

syntax Block ::= "{" BlockStmt "}" [klabel('Block)]
syntax EmptyStmt ::= ";" [klabel('Empty)]

syntax AssertStmt ::="assert" Exp ";" [strict, klabel('AssertStm)]
		            |"assert" Exp ":" Exp ";" [strict(1), klabel('AssertStm)]
syntax SwitchStmt ::= "switch" "(" Exp ")" SwitchBlock [strict(1),klabel('Switch)]
syntax SwitchGroup ::= KListWrap KListWrap [klabel('SwitchGroup)]
syntax SwitchLabel ::= "case" Exp ":" [strict, klabel('Case)]
		               |"default:" [klabel('Default)]
syntax SwitchBlock::= "{" KListWrap KListWrap "}" [klabel('SwitchBlock)]
syntax DoStmt ::="do" "{" K "}" "while" "(" K ")"[strict(2),klabel('DoWhile)]
syntax TryStmt ::= "try" Block KListWrap "finally" Block [klabel('Try)]
		           |"try" Block KListWrap [klabel('Try)]

syntax Param ::= Type Id
syntax CatchClause ::= "catch" "(" Param ")" Block [klabel('Catch)]
syntax CatchClauses ::= List{CatchClause,""}
syntax CatchClauses ::= toCatchClauses( KListWrap )          [function]
           | toCatchClauses( KListWrap , CatchClauses ) [function]
rule [L:KList,,C:CatchClause] => toCatchClauses([L,,C])
rule toCatchClauses([KLCatchClauses:KList]) => toCatchClauses([KLCatchClauses],.CatchClauses)
rule toCatchClauses([KLCatchClauses:KList,, C:CatchClause], CatchClauses:CatchClauses) => toCatchClauses([KLCatchClauses], (C CatchClauses))
rule toCatchClauses([.KList], CatchClauses:CatchClauses) => CatchClauses

//syntax TryStmt ::= "try" Block CatcheClauses "finally" Block [klabel('Try)]
//		           |"try" Block CatcheClauses [klabel('Try)]
//rule 'Try(B1)

syntax StackConsumerStmt ::= "dummyStackConsumerStmt"|ThrowStmt|ContinueStmt|BreakStmt|ReturnStmt
syntax ThrowStmt ::= "throw" K ";" [strict, klabel('Throw)]
syntax ContinueStmt ::= "continue" K ";" [klabel('Continue)]
syntax BreakStmt ::= "break" K ";" [klabel('Break)]
syntax ReturnStmt ::= "return" K ";" [klabel('Return)]

syntax SynchronizedStmt ::= "synchronized" "(" Exp ")" Block [strict(1),klabel('Synchronized)]
//todo: replace Exp with StmtExp when all StmtExp are defined
syntax ExprStmt ::= Exp ";"  [strict, klabel('ExprStm)]

endmodule

