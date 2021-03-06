require "core-sorts.k"
require "core-classes.k"
require "shared-syntax.k"

module EXP-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES
    imports SHARED-SYNTAX

syntax Exp ::= StmtExp
syntax Exps ::= List{Exp, ","} [seqstrict]
//todo: why does this pure syntax definition affect krun?
//PackageName, AmbName and PackageorTypeName syntax doesn't cause problems
//                    syntax PackageName ::= List{Id,"."} [seqstrict, klabel('PackageName)]
//                     syntax ExprName::= Id  [strict, klabel('ExprName)]
//                                         |AmbName "." Id [strict, klabel('ExprName)]
//breaks if any other syntax is added
//                     syntax TypeName ::= Id [strict, klabel('TypeName)]
//                                         |PackageOrTypeName "." Id [strict, klabel('TypeName)]
//                     syntax AmbName ::= Id [strict, klabel('AmbName)]
//                                         |AmbName "." Id [strict, klabel('AmbName)]
//                     syntax MethodName ::= Id [strict,klabel('MethodName)]
//                                            |AmbName "." Id [strict,klabel('MethodName)]
//                     syntax PackageOrTypeName ::= Id [strict,klabel('PackageOrTypeName)]
//                                                   |PackageOrTypeName "." Id [strict,klabel('PackageOrTypeName)]
//cannot use this either
//syntax MethodInvokeExp ::= MethodSpec "(" KListWrap ")" [klabel('Invoke)]
//syntax MethodSpec ::= MethodName [klabel('Method)]
//                    |Exp "." K Id [klabel('Method)]
//                    |"super" "." K Id [klabel('SuperMethod)]
//                    |TypeName "." "super" "." K Id [klabel('QSuperMethod)]
//                    |AmbName "." K Id [klabel('GenericMethod)]

syntax MethodName ::= Id | MethodRef
syntax MethodInvokeExp ::= K "." MethodName "(" Exps ")"       [seqstrict(1,3), klabel('MethodImpl)]


syntax ClassOrName ::= Id | ClassType
syntax ClassInstanceCreationExp ::= "new" ClassType "(" Exps ")" [klabel('NewInstance)]
                                   | Exp "." "new" ClassOrName "(" Exps ")"     [seqstrict(1,3), klabel('QNewInstance)]

syntax StmtExp ::= PrefixPostfixExp|AssignExp|MethodInvokeExp|ClassInstanceCreationExp
//@ Operators with side effects - prefix, postfix ++/--
syntax PrefixPostfixExp ::= "dummyPrefixPostfixExp"
syntax PrefixPostfixExp ::=
		  Exp "++" [klabel('PostIncr)]
		| Exp "--" [klabel('PostDecr)]
		> "++" Exp [klabel('PreIncr)]
        | "--" Exp [klabel('PreDecr)]

 //use sort K instead of Exp for the sake of Lookup, others might be changed when needed
syntax Exp ::=
          Exp "*" Exp [seqstrict, klabel('Mul)]
		| Exp "/" Exp [seqstrict, klabel('Div)]
		| Exp "%" Exp [seqstrict, klabel('Remain)]
		| "+" Exp [strict, klabel('Plus)]
		| "-" Exp [strict, klabel('Minus)]
		> Exp "+" Exp [seqstrict, klabel('Plus)]
 		| Exp "-" Exp [seqstrict, klabel('Minus)]

//todo: change to LHS?
syntax AssignExp ::= K "=" Exp [klabel('Assign)]
syntax AssignExp ::= CompoundAssignExp
syntax CompoundAssignExp ::= "dummyCompoundAssignExp"
                            | Exp "*=" Exp [klabel('AssignMul)]
                            | Exp "/=" Exp [klabel('AssignDiv)]
                            | Exp "%=" Exp [klabel('AssignRemain)]
                            | Exp "+=" Exp [klabel('AssignPlus)]
                            | Exp "-=" Exp [klabel('AssignMinus)]
                            | Exp "<<=" Exp [klabel('AssignLeftShift)]
                            | Exp ">>=" Exp [klabel('AssignRightShift)]
                            | Exp ">>>=" Exp [klabel('AssignURightShift)]
                            | Exp "&=" Exp [klabel('AssignAnd)]
                            | Exp "^=" Exp [klabel('AssignExcOr)]
                            | Exp "|=" Exp [klabel('AssignOr)]

syntax Exp ::= Exp "<<" Exp [seqstrict, klabel('LeftShift)]
              | Exp ">>" Exp [seqstrict, klabel('RightShift)]
              | Exp ">>>" Exp [seqstrict, klabel('URightShift)]

syntax Exp ::= Exp ">" Exp [seqstrict, klabel('Gt)]
syntax Exp ::= Exp "<" Exp [seqstrict, klabel('Lt)]
syntax Exp ::= Exp ">=" Exp [seqstrict, klabel('GtEq)]

syntax Exp ::= Exp "||" Exp [strict(1), klabel('LazyOr)]
             | Exp "&&" Exp [strict(1), klabel('LazyAnd)]
             | Exp "|" Exp [seqstrict, klabel('Or)]
             | Exp "^" Exp [seqstrict, klabel('ExcOr)]
             | Exp "&" Exp [seqstrict, klabel('And)]

syntax Exp ::= "~" Exp [strict, klabel('Complement)]
             | "!" Exp [strict, klabel('Not)]

syntax Exp ::= Exp "?" Exp ":" Exp [klabel('Cond)]
syntax Exp ::= Exp "instanceof" RefType [strict, klabel('InstanceOf)]
syntax Exp ::= FieldAccess
syntax FieldAccess ::= Exp "." Id [klabel('Field)]
                       |"super" "." Id [klabel('SuperField)]
//                       |TypeName "." "super" "." Id [klabel('QSuperField)]
//                        |ExprName "." Id [reject]

//TypeName cannot be properly defined, use K instead
syntax Exp ::= "this" [klabel('This)] | K "." "this" [klabel('QThis)]

endmodule
