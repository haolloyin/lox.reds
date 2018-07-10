Red/System []

#include %scanner.reds

#enum Precedence! [     ;- 优先级，数字越大优先级越高
    PREC_NONE
    PREC_ASSIGNMENT     ;- =
    PREC_OR             ;- or
    PREC_AND            ;- and
    PREC_EQUALITY       ;- == !=
    PREC_COMPARISON     ;- < > <= >=
    PREC_TERM           ;- + -
    PREC_FACTOR         ;- * /
    PREC_UNARY          ;- ! - +
    PREC_CALL           ;- . () []
    PREC_PRIMARY
]

#define ParseFn! [integer!]     ;- 函数指针

ParseRule!: alias struct! [
    prefix      [ParseFn!]
    infix       [ParseFn!]
    precedence  [Precedence!]
]

compiler: context [

    parser: declare struct! [
        curr [token!]
        prev [token!]
        had-error [logic!]
        panic-mode [logic!]
    ]
    
    rules: as int-ptr! 0

    compiling-chunk: declare chunk!

    compile: func [
        source  [c-string!]
        chunk   [chunk!]
        return: [logic!]
        /local
            line [integer!]
            token [token!]
            idx [integer!]
            c [byte-ptr!]
    ][
        scanner-ctx/init source
        init-rules

        parser/had-error: false
        parser/panic-mode: false
        compiling-chunk: chunk

        print-line "-- begin compiling source --"

        advance
        comp-expression
        consume TOKEN_EOF "Expect end of expression."
        end-compiler

        not parser/had-error
    ]

    advance: does [
        parser/prev: parser/curr
        forever [
            parser/curr: scanner-ctx/scan-token
            if parser/curr/type <> TOKEN_ERROR [break]

            error-at-current as-c-string parser/curr/start
        ]
    ]

    comp-expression: func [
    ][
        print-line "comp-expression"

        parse-precedence PREC_ASSIGNMENT
    ]

    error-at-current: func [message [c-string!]][
        error-at parser/curr message
    ]

    error: func [message [c-string!]][
        error-at parser/prev message
    ]

    error-at: func [token [token!] message [c-string!] return: [integer!]][
        if parser/panic-mode [return 0]
        parser/panic-mode: true

        fprintf [stderr "[line %d] Error" token/line]

        switch token/type [
            TOKEN_EOF [fprintf [stderr " at end"]]
            TOKEN_ERROR [
                ;- TODO
            ]
            default [
                fprintf [stderr " at '%.*s'" token/length token/start]
            ]
        ]
        fprintf [stderr ": %s" message]
        print lf

        parser/had-error: true
        return 0
    ]

    consume: func [type [token-type!] message [c-string!]][
        if parser/curr/type = type [
            advance
        ]

        error-at-current message
    ]

    emit-byte: func [byte [integer!]][
        chunk-ctx/write get-current-chunk byte parser/prev/line
    ]

    emit-bytes: func [byte1 [integer!] byte2 [integer!]][
        emit-byte byte1
        emit-byte byte2
    ]

    get-current-chunk: func [return: [chunk!]][
        compiling-chunk
    ]

    end-compiler: does [
        emit-return
    ]

    emit-return: does [
        emit-byte OP_RETURN
    ]

    comp-number: func [/local value [value!]][
        value: as value! strtod parser/prev/start null
        emit-constant value
    ]

    emit-constant: func [value [value!]][ 
        emit-bytes OP_CONSTANT make-constant value
    ]

    make-constant: func [
        value [value!]
        return: [integer!]
        /local constant [integer!]
    ][
        constant: chunk-ctx/add-constant get-current-chunk value

        if constant > MAX_INT [
            error "Too many constatns in one chunk."
            return 0
        ]

        constant
    ]

    comp-binary: func [
        /local
            op-type [token-type!]
            rule [ParseRule!]
    ][
        op-type: parser/prev/type   ;- 操作数类型

        rule: get-rule op-type

        switch op-type [
            TOKEN_PLUS  [emit-byte OP_ADD]
            TOKEN_MINUS [emit-byte OP_SUBTRACT]
            TOKEN_STAR  [emit-byte OP_MULTIPLY]
            TOKEN_SLASH [emit-byte OP_DIVEDE]
            default     []
        ]
    ]

    comp-grouping: does [
        comp-expression
        consume TOKEN_RIGHT_PAREN "Expect ')' after expression."
    ]

    comp-unary: func [
        /local
            op-type [token-type!]
    ][
        op-type: parser/prev/type

        ;- 编译操作数
        parse-precedence PREC_UNARY

        ;- 组合操作数
        switch op-type [
            TOKEN_MINUS [emit-byte OP_NEGATE]
            default []
        ]
    ]

    parse-precedence: func [
        precedence [Precedence!]
        /local
            prefix-rule [ParseFn!]
            rule [ParseRule!]
            fn [ParseFn!]
    ][
        advance

        rule: get-rule parser/prev/type
        prefix-rule: rule/prefix

        either null? prefix-rule [
            error "Expect expression."
            return
        ]

        as function! prefix-rule
    ]

    get-rule: func [
        op-type [token-type!]
        return: [ParseRule!]
    ][
        as ParseRule! rules/op-type
    ]

    init-rules: func [
    ][
        rules: as int-ptr! allocate 39 * size? ParseRule!

        ;- 注册函数指针
        register-rules [
            :comp-grouping    NULL            PREC_CALL       ;- TOKEN_LEFT_PAREN
            NULL              NULL            PREC_NONE       ;- TOKEN_RIGHT_PAREN
            NULL              NULL            PREC_NONE       ;- TOKEN_LEFT_BRACE
            NULL              NULL            PREC_NONE       ;- TOKEN_RIGHT_BRACE
            NULL              NULL            PREC_NONE       ;- TOKEN_COMMA
            NULL              NULL            PREC_CALL       ;- TOKEN_DOT
            :comp-unary       :comp-binary    PREC_TERM       ;- TOKEN_MINUS
            NULL              :comp-binary    PREC_TERM       ;- TOKEN_PLUS
            NULL              NULL            PREC_NONE       ;- TOKEN_SEMICOLON
            NULL              :comp-binary    PREC_FACTOR     ;- TOKEN_SLASH
            NULL              :comp-binary    PREC_FACTOR     ;- TOKEN_STAR
            NULL              NULL            PREC_NONE       ;- TOKEN_BANG
            NULL              NULL            PREC_EQUALITY   ;- TOKEN_BANG_EQUAL
            NULL              NULL            PREC_NONE       ;- TOKEN_EQUAL
            NULL              NULL            PREC_EQUALITY   ;- TOKEN_EQUAL_EQUAL
            NULL              NULL            PREC_COMPARISON ;- TOKEN_GREATER
            NULL              NULL            PREC_COMPARISON ;- TOKEN_GREATER_EQUAL
            NULL              NULL            PREC_COMPARISON ;- TOKEN_LESS
            NULL              NULL            PREC_COMPARISON ;- TOKEN_LESS_EQUAL
            NULL              NULL            PREC_NONE       ;- TOKEN_IDENTIFIER
            NULL              NULL            PREC_NONE       ;- TOKEN_STRING
            :comp-number      NULL            PREC_NONE       ;- TOKEN_NUMBER
            NULL              NULL            PREC_AND        ;- TOKEN_AND
            NULL              NULL            PREC_NONE       ;- TOKEN_CLASS
            NULL              NULL            PREC_NONE       ;- TOKEN_ELSE
            NULL              NULL            PREC_NONE       ;- TOKEN_FALSE
            NULL              NULL            PREC_NONE       ;- TOKEN_FUN
            NULL              NULL            PREC_NONE       ;- TOKEN_FOR
            NULL              NULL            PREC_NONE       ;- TOKEN_IF
            NULL              NULL            PREC_NONE       ;- TOKEN_NIL
            NULL              NULL            PREC_OR         ;- TOKEN_OR
            NULL              NULL            PREC_NONE       ;- TOKEN_PRINT
            NULL              NULL            PREC_NONE       ;- TOKEN_RETURN
            NULL              NULL            PREC_NONE       ;- TOKEN_SUPER
            NULL              NULL            PREC_NONE       ;- TOKEN_THIS
            NULL              NULL            PREC_NONE       ;- TOKEN_TRUE
            NULL              NULL            PREC_NONE       ;- TOKEN_VAR
            NULL              NULL            PREC_NONE       ;- TOKEN_WHILE
            NULL              NULL            PREC_NONE       ;- TOKEN_ERROR
            NULL              NULL            PREC_NONE       ;- TOKEN_EOF
        ]
    ]

	register-rules: func [
		[variadic]
		count	[integer!]
		list	[int-ptr!]
		/local
			index   [integer!]
            rule    [ParseRule!]
	][
		index:  1
		
		until [
            rule: declare ParseRule!
            rule/prefix:        as int-ptr! list/1
            rule/infix:         as int-ptr! list/2
            rule/precedence:    list/3
        
            rules/index: as integer! rule

			list: list + 3
			count: count - 3
            index: index + 1
			zero? count
		]
	]
]

