
//@ \section{Module STATEMENTS}

module STATEMENTS
    imports CORE-SORTS
    imports SUBTYPING
    imports CORE-EXEC     //for sl
    imports VAR-LOOKUP
    imports METHOD-INVOKE // for initParams
    imports STMT-SYNTAX

//@ \subsection{Call of main method}

//For now main class may only be placed in the default package.
rule [ExecutionPhase-Start]:
    <k>
      //K-AST for new <MainClass>().main(new String[0]);
      . =>  getClassType(packageId(String2Id("")), String2Id(MainClassS))
              .String2Id("main")

              //workaround: we have to use toExps because 'NewArray is not a native expression but a hacked one
              ( toExps(['NewArray(classString,, ['Dim(0 :: int)],, [.KList])]) );
    </k>
    <env> . </env>
    <mainClass> ListItem(MainClassS:String) </mainClass>
    <globalPhase> UnfoldingPhase => ExecutionPhase  </globalPhase>

//@ \subsection{Blocks} JLS \$14.2

rule [Block]:
    <k> 'Block(S:K) => S ~> env(Env:Map) ...</k>
//todo:    <k> {S:K} => S ~> env(Env:Map) ...</k>
    <env> Env </env>
        [structural]

//@ \texttt{env} Restore the env cell content from env(...) statement argument
syntax KItem ::= env ( Map )

rule [env]:
    <k> env(Env:Map) => . ...</k>
    <env> _ => Env </env>
        [structural]

rule [env-double-Discard]:
    (env(_) => .) ~> env(_)
        [structural]

/*@ \subsection{Local Variable Declaration Statements} JLS \$14.4
    Not only local but fields also*/

rule [LocalVarDec]:
    <k> T:Type X:Id; => . ...</k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> default(T) ...</store>
    <storeMetadata>... . => L |-> LocalLocMetadata ...</storeMetadata>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

//@ \subsection{Empty statement} JLS \$14.6

rule [Empty]:
    ; => .

//@ \subsection{Labeled statements} JLS \$14.7

rule [Labeled]:
    X:Id : S:K => S ~> labeledImpl(X)

//@ Processed version of the labeled statement
syntax KItem ::= labeledImpl ( Id )

rule [labeledImpl-Discard]:
    labeledImpl(_) => .K

//@ \subsection{Expression statements} JLS \$14.8

rule _:TypedVal; => .K

//@ \subsection{If statement}
rule if (K1) {K2} => if (K1) {K2} else {.K} 

rule [If-True]:
    if (true::bool) {S:K} else {_} => S
        [symbolic-rule]

rule [If-False]:
    if (false::bool) {_} else {S:K} => S
        [symbolic-rule]

//@ \subsection{Assert statement}
//short version:    assert exp1;
rule [AssertStm-True-OneArg]:
        assert true::bool; => .

rule [AssertStm-False-OneArg]:
        assert false::bool; => throw new class String2Id("java.lang.AssertionError") (null::classString);

//full version:    assert exp1:exp2;
rule [AssertStm-FirstTrue-SecondDiscarded]:
        assert true::bool : _ ; => .

context assert false::bool : HOLE;
rule [AssertStm-FirstFalse]:
    assert (false::bool) : (TV:TypedVal); => throw new class String2Id("java.lang.AssertionError") (toString(TV));

//@ \subsection{Switch statement}

syntax KItem ::=  switchImpl (
                TypedVal,   // TV - switch argument
                KListWrap,  // switch body - list of 'SwitchGroup labels
                K           // DefaultStm - default block, if any
              )

//@ The switchEnd in the right-hand side of => is required to properly interact with break.
rule [Switch]:
    switch(TV:TypedVal){[Ks:KList] [TrailingLabels:KList]}
    => switchImpl(TV, [Ks,, [TrailingLabels] .K], .K)
    ~> switchEnd

context switchImpl( _, [ [case HOLE : ,, _:KList] _ ,, _:KList], _)

/*@ The type associated to V and V2 is not important for match, only the value.
JLS3 \$14.11, page 377: Every case constant expression associated with
a switch statement must be assignable (�5.2) to the type of the switch Expression.*/

rule [switchImpl-CaseNotMatch]:
    switchImpl(
      V:RawVal :: _,
      [ [ (  case V2:RawVal :: _ :=> .KList ),, _:KList ] _ ,, _],
      _
    )
when
    V =/=K V2

/*@Once case of first switch group matches, the whole switch is replaced
by it's block. The execution rules for switch will discard switch-related
constructs and will execute the statements. */
rule [switchImpl-CaseMatch]:
    switchImpl(
        V:RawVal :: _,
        [[case V :: _ : ,, _:KList] S:K,, Ks:KList],
        _
    )
    => [S,,Ks]

rule [switchImpl-DefaultSave]:
    switchImpl(
        TV:TypedVal,
        [[ ( default: => .KList ),, _:KList] S:K,, Ks:KList],
        ( _:K => [S,, Ks] )
    )

rule [switchImpl-SwitchGroup-Discard]:
    switchImpl(
        TV:TypedVal,
        [( [ .KList ] _ => .KList ),, _],
        _
    )

rule [switchImpl-Default-Exec]:
    switchImpl( _, [.KList], DefaultStm:K) => DefaultStm

rule [SwitchGroup-Exec]:
    _:KListWrap S:K => S

syntax KItem ::=  "switchEnd"

rule [switchEnd-Discard]:
    switchEnd => .K

//@ \subsection{While statement} and loop infrastructure.

rule while(E:K){S:K} => whileImpl(E, S)         [structural]

syntax KItem ::=  whileImpl (
                K,  // E - test expression. In For loop, it is UpdClause ~> testExp
                K   // S - while body
              )

rule [whileImpl]:
    whileImpl(E:K, S:K) => if(E){S ~> whileImpl(E, S)}    [structural]

//@ \subsection{Do statement}
rule do{S:K}while(E:K) => S ~> whileImpl(E, S)  [structural]

//@ \subsection{For statement}

//wrapper of certain clauses of for statement
syntax KItem ::= stm ( KListWrap )

rule [stm-KListWrap-empty]:
    stm([.KList]) => .
        [structural]

rule [stm-KListWrap-exp]:
    stm([E:Exp,, Es:KList]) => E; ~> stm([Es])
when
    getKLabel(E) ==KLabel 'cast                                           [structural]

rule [stm-KListWrap-LocalVarDec]:
    stm([K:K,,Ks:KList]) => [K,,Ks]
when
    notBool ( getKLabel(K) ==KLabel 'cast )                               [structural]

rule [For-FirstArgV1Red]:
    for((
      [InitExps:KList] => stm([InitExps])
    );_:K;_:K) {_:K}
        [structural]

//Works also in elaboration phase
rule [For-FirstArgV2Red]:
    for((
      'LocalVarDec(Ks:KList) => stm(['LocalVarDec(Ks)])
    );_:K;_:K) {_:K}
        [structural]

rule [For-SecondArgRed]:
    for(_:K;(
      'None(.KList) => 'Some(true)
    );_:K) {_:K}
        [structural]

rule [For-ThirdArgRed]:
    for(_:K;_:K;(
      [UpdExps:KList] => stm([UpdExps])
    )) {_:K}
        [structural]

//this form of resulting while is required for compatibility with continue statement
rule [For]:
    for(stm(InitClause:KListWrap); 'Some(TestExp:K); stm(UpdClause:KListWrap)) {S:K}
     => 'Block(stm(InitClause)
        //~> 'If(TestExp,, 'Block(S) ~> whileImpl(stm(UpdClause) ~> TestExp, S),, .K))  [structural]
        ~> if(TestExp) {'Block(S) ~> whileImpl(stm(UpdClause) ~> TestExp, S)})  [structural]

//totest model check - the argument of 'return and 'Throw must be evaluated. Otherwise some side effects during
// evaluation might be evaluated too late
/*@ Stack consumer stm - Return, Throw, Break or Continue reaches tryFinallySL layer*/
rule [StackConsumerStmt-in-TryFinally]:
    StackCons:StackConsumerStmt ~> finallyBlock(FinallyS:K)
    => FinallyS ~> StackCons

rule [StackConsumerStmt-RestoreEnv]:
    StackCons:StackConsumerStmt ~> env(Env:Map)
    => env(Env:Map) ~> StackCons

//@ \subsection{Break statement}

rule [Break-UnlabeledPropagate]:
   // 'Break('None(_)) ~> (KL:KLabel(_) => .)
    break 'None(_); ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock
    andBool KL =/=KLabel 'whileImpl
    andBool KL =/=KLabel 'switchEnd

rule [Break-Unlabeled]:
    //'Break('None(_)) ~> KL:KLabel(_) => .
    break 'None(_); ~> KL:KLabel(_) => .
when
           KL ==KLabel 'whileImpl
    orBool KL ==KLabel 'switchEnd

rule [Break-LabeledPropagate]:
   // 'Break('Some(X:Id)) ~> (KL:KLabel(_) => .)
    break 'Some(X:Id); ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock
    andBool KL =/=KLabel 'labeledImpl

rule [BreakLabeledNotMatch]:
    //'Break('Some(X1:Id)) ~> (labeledImpl(X2:Id) => .)
    break 'Some(X1:Id); ~> (labeledImpl(X2:Id) => .)
when
    X1 =/=K X2

rule [Break-LabeledMatch]:
    //'Break('Some(X:Id)) ~> labeledImpl(X:Id) => .
    break 'Some(X:Id); ~> labeledImpl(X:Id) => .

//@ \subsection{Continue statement}

rule [Continue-Propagate]:
//    'Continue(_) ~> (KL:KLabel(_) => .)
    continue _; ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock
    andBool KL =/=KLabel 'whileImpl

rule [Continue-Unlabeled]:
//    ('Continue('None(_)) => .) ~> whileImpl(_,_)
   (continue 'None(_); => .) ~> whileImpl(_,_)

rule [Continue-LabeledMeetsWhile]:
    <k>
//      (. => getWhileLabel(Rest)) ~> 'Continue('Some(X:Id)) ~> whileImpl(_,_) ~> Rest:K
      (. => getWhileLabel(Rest)) ~> continue 'Some(X:Id); ~> whileImpl(_,_) ~> Rest:K
    </k>

rule [Continue-LabeledNotMatch]:
//    (whileLabel(LabelK:K) => .) ~> 'Continue('Some(X:Id)) ~> (whileImpl(_,_) => .)
    (whileLabel(LabelK:K) => .) ~> continue 'Some(X:Id); ~> (whileImpl(_,_) => .)
when
    LabelK =/=K X

rule [Continue-LabeledMatch]:
//    whileLabel(X) ~> 'Continue('Some(X:Id)) => .
    whileLabel(X) ~> continue 'Some(X:Id); => .

/*@ Auxiliary constructs used in the semantics of continue.
Search for the label associated with the last encountered while statement*/
syntax KItem ::= getWhileLabel ( K )
           | whileLabel ( K )

rule getWhileLabel((env(_) => .) ~> _)
rule getWhileLabel(.K) => whileLabel(.K)
rule getWhileLabel(labeledImpl(X:Id) ~> _) => whileLabel(X)

rule getWhileLabel(KL:KLabel(_) ~> _) => whileLabel(.K)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'labeledImpl

/*@\subsection{Return} At method return, we have to check that the type
of the returned
value is a subtype of the expected return type.  Moreover, if that is
the case, then we also up-cast the returned value to one of the
expected type. */

//context 'Return('Some(HOLE))
context return 'Some(HOLE);

rule [Return-None-Desugar]:
//    'Return('None(_)) => 'Return('Some(nothing :: void))
    return 'None(_); => return 'Some(nothing :: void);
        [structural]

rule [Return-Propagate]:
//    'Return('Some(TV:TypedVal)) ~> (KL:KLabel(Ks:KList) => .K)
    return 'Some(TV:TypedVal); ~> (KL:KLabel(Ks:KList) => .K)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock

rule [Return-MethodEnd]:
//    <k> 'Return('Some(TV:TypedVal)) => TV ~> K </k>
    <k> return 'Some(TV:TypedVal); => TV ~> K </k>
    <stack> ListItem( sl(K:K, MethContext:Bag) ) => . ...</stack>
    <methodContext> _:Bag => MethContext </methodContext>

/*@ \subsection{Throw statement}
Exceptions are propagated now until a catch that can bind them is
encountered. */
rule [Throw]:
    (. => checkCatch(subtype(typeOf(TV), T)))
//    ~> 'Throw(TV:TypedVal)
    ~> throw TV:TypedVal;
    ~> catchBlocks([catchImpl(T:Type X:Id,_),, _])

syntax KItem ::= checkCatch ( K )
context checkCatch(HOLE)

rule [Throw-checkCatch-True]:
    checkCatch(true::bool)
//    ~> 'Throw(TV:TypedVal)
    ~> throw TV:TypedVal;
    ~> catchBlocks([catchImpl(Param:Param, CatchS:K),, _])
    => 'Block([
          initParams(Param, TV),,
          CatchS
        ])

rule [Throw-checkCatch-False]:
    (checkCatch(false::bool) => .)
//    ~> 'Throw(TV:TypedVal)
    ~> throw TV:TypedVal;
    ~> catchBlocks([(catchImpl(_,_) => .KList),, _])

rule [Throw-catchBlocks-EmptyDiscard]:
//    'Throw(TV:TypedVal) ~> (catchBlocks([.KList]) => .)
    throw TV:TypedVal; ~> (catchBlocks([.KList]) => .)

rule [Throw-Propagate]:
//    'Throw(TV:TypedVal) ~> (KL:KLabel(_) => .)
    throw TV:TypedVal; ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock
    andBool KL =/=KLabel 'catchBlocks

rule [Throw-MethodEnd]:
    <k>
//      'Throw(TV:TypedVal) ~> (. => K)
      throw TV:TypedVal; ~> (. => K)
    </k>
    <stack> ListItem( sl(K:K, MethContext:Bag) ) => . ...</stack>
    <methodContext> _ => MethContext </methodContext>

rule [Throw-CausesThreadTermination]:
    <k>
//      'Throw(TV:TypedVal)
      throw TV:TypedVal;
      =>  'Field( class String2Id("java.lang.System"),, String2Id("out") )
            .String2Id("println")
            (cast(classObject, 'Plus( "Thread terminated with exception: ",, TV )));
    </k>
    <stack> .List </stack>

//@ \subsection{Try statement}

rule [Try-Catch-Finally-Desugar]:
    try TryS:K [K:K,, Ks:KList] finally FinallyS:K
    => try {try TryS [K,,Ks]} [.KList] finally FinallyS
        [structural]

/*@ \subsubsection{Execution of try-catch} JLS \$14.20.1
*/

//resolve the catch clauses of try statement
context try _:K [_,, HOLE,, _]

//resolve 'Param term of the catch clause

context catch(HOLE)_                                [result(ExtKResult)]

rule catch(KR:Param)S:K => catchImpl(KR,S)

/*@ Extended K Result.
  Represents KLabels that should be treated as KResult during execution phase, but not during elaboration phase.
*/
syntax ExtKResult ::= "dummy"

rule isExtKResult(KR:KResult) => true

rule isExtKResult(T:Type _:Id) => true

//@ Internal representation of a preprocessed catch clause
syntax KResult ::=  catchImpl (
                      K,  //'Param(...),
                      K   //the code block
                    )

rule [Try-Catch]:
    try TryS:K [KRs:KList] => TryS ~> catchBlocks([KRs])
when isKResult(KRs)

/*@ The auxiliary construct that holds catch clauses
after try clause has been moved to the top of computation*/
syntax KItem ::= catchBlocks ( KListWrap ) //arg - list of catchImpl

/*@ If try clause executed without raising an exception, this construct will reach the top of computation.
    In this case it should be discarded.
*/
rule [catchBlocks-Discard]:
    catchBlocks([_]) => .K

/*@ \subsubsection{Execution of try-finally} JLS \$14.20.2
*/

rule [Try-Finally]:
    try TryS:K [.KList] finally FinallyS:K => TryS ~> finallyBlock(FinallyS)

/*@ The auxiliary construct that holds finally clause
after try clause has been moved to the top of computation*/
syntax KItem ::= finallyBlock ( K )      //arg - finally block

rule [finallyBlock-NormalEnd]:
    finallyBlock(FinallyS:K) => FinallyS

endmodule