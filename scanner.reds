Red/System []

#enum token-type! [
    ; Single-character tokens.
    TOKEN_LEFT_PAREN
    TOKEN_RIGHT_PAREN
    TOKEN_LEFT_BRACE
    TOKEN_RIGHT_BRACE
    TOKEN_COMMA
    TOKEN_DOT
    TOKEN_MINUS
    TOKEN_PLUS
    TOKEN_SEMICOLON
    TOKEN_SLASH
    TOKEN_STAR
    ; One or two character tokens.
    TOKEN_BANG
    TOKEN_BANG_EQUAL
    TOKEN_EQUAL
    TOKEN_EQUAL_EQUAL
    TOKEN_GREATER
    TOKEN_GREATER_EQUAL
    TOKEN_LESS
    TOKEN_LESS_EQUAL
    ; Literals.
    TOKEN_IDENTIFIER
    TOKEN_STRING
    TOKEN_NUMBER
    ; Keywords.
    TOKEN_AND
    TOKEN_CLASS
    TOKEN_ELSE
    TOKEN_FALSE
    TOKEN_FUN
    TOKEN_FOR
    TOKEN_IF
    TOKEN_NIL
    TOKEN_OR
    TOKEN_PRINT
    TOKEN_RETURN
    TOKEN_SUPER
    TOKEN_THIS
    TOKEN_TRUE
    TOKEN_VAR
    TOKEN_WHILE

    TOKEN_ERROR
    TOKEN_EOF
]

token!: alias struct! [
    type [token-type!]
    start [byte-ptr!]   ;- 起始地址
    length [integer!]   ;- 字符个数
    line [integer!]
]


scanner-ctx: context [

    scanner: declare struct! [
        start [byte-ptr!]
        current [byte-ptr!]
        line [integer!]
    ]

    init: func [
        source [c-string!]
    ][
        scanner/start: as byte-ptr! source
        scanner/current: as byte-ptr! source
        scanner/line: 1
    ]

    scan-token: func [
        return: [token!]
        /local
            c [byte!]
    ][
        skip-whitespace

        scanner/start: scanner/current

        if at-end? [return make-token TOKEN_EOF]

        c: advance
        print-line ["c: " c]

        if alpha? c [return make-identifier]
        if digit? c [return make-number]

        switch advance [
            #"(" [return make-token TOKEN_LEFT_PAREN]
            #")" [return make-token TOKEN_RIGHT_PAREN]
            #"{" [return make-token TOKEN_LEFT_BRACE]
            #"}" [return make-token TOKEN_RIGHT_BRACE]
            #";" [return make-token TOKEN_SEMICOLON]
            #"," [return make-token TOKEN_COMMA]
            #"." [return make-token TOKEN_DOT]
            #"-" [return make-token TOKEN_MINUS]
            #"+" [return make-token TOKEN_PLUS]
            #"/" [return make-token TOKEN_SLASH]
            #"*" [return make-token TOKEN_STAR]
            #"!" [return make-token either match? #"=" [TOKEN_BANG_EQUAL][TOKEN_BANG]]
            #"=" [return make-token either match? #"=" [TOKEN_EQUAL_EQUAL][TOKEN_EQUAL]]
            #"<" [return make-token either match? #"=" [TOKEN_LESS_EQUAL][TOKEN_LESS]]
            #">" [return make-token either match? #"=" [TOKEN_GREATER_EQUAL][TOKEN_GREATER]]
            ;#"\"" [return make-string]
            default [
                print-line ["default: " c]
                return error-token "Unexpected character."
            ]
        ]

        return error-token "Unexpected character."
    ]

    skip-whitespace: func [/local c [byte!]][
        forever [
            c: peek
            print-line ["skip c: " c]
            switch c [
                #" " #"^M" #"^-" [
                    advance
                    break
                ]
                #"^/" [
                    scanner/line: scanner/line + 1
                    advance
                    break
                ]
                #"/" [
                    if peek-next = #"/" [
                        while [all [peek <> cr not at-end?]][
                            advance
                        ]
                    ]
                ]
                default [
                    print-line ["skip default: " c]
                    break
                ]
            ]
        ]
    ]

    advance: func [
        return: [byte!]
        /local
            idx [integer!]
    ][
        scanner/current: scanner/current + 1
        scanner/current/value
    ]

    digit?: func [c [byte!] return: [logic!]][
        all [c >= #"0" c <= #"9"]
    ]

    alpha?: func [c [byte!] return: [logic!]][
        any [
            all [c >= #"a" c <= #"z"]
            all [c >= #"A" c <= #"Z"]
            c = #"_"
        ]
    ]

    at-end?: func [return: [logic!]][
        scanner/current/value = null-byte   ;- #"^(00)"
    ]

    match?: func [
        expected [byte!]
        return: [logic!]
    ][
        if at-end? [return false]
        unless scanner/current/value = expected [return false]

        scanner/current: scanner/current + 1
        true
    ]

    peek: func [return: [byte!]][
        scanner/current/value
    ]

    peek-next: func [return: [byte!]][
        if at-end? [return null-byte]
        scanner/current/value
    ]

    make-number: func [return: [token!]][
        while [digit? peek][advance]

        if all [peek = #"." digit? peek-next][
            advance
            while [digit? peek][advance]
        ]

        return make-token TOKEN_NUMBER
    ]

    make-identifier: func [return: [token!]][
        while [any [alpha? peek digit? peek]][advance]
        make-token identifier-type
    ]

    identifier-type: func [return: [token-type!]][
        TOKEN_IDENTIFIER
    ]

    ;make-string: func [
    ;    return: [token!]
    ;][
    ;    while all [peek != "\"" not at-end?][
    ;        if peek = cr [
    ;            scanner/line: scanner/line + 1
    ;        ]
    ;        advance
    ;    ]

    ;    if at-end? [return error-token "Unexpected character."]

    ;    advance

    ;    return make-token TOKEN_STRING
    ;]

    make-token: func [
        type [token-type!]
        return: [token!]
        /local
            token [token!]
    ][
        token: declare token!
        token/type: type
        token/start: scanner/start
        token/length: as-integer (scanner/current - scanner/start)
        token/line: scanner/line
        
        token
    ]
    
    error-token: func [
        message [c-string!]
        return: [token!]
        /local
            token [token!]
    ][
        token: declare token!
        token/type: TOKEN_ERROR
        token/start: as byte-ptr! message
        token/length: length? message
        token/line: scanner/line

        token
    ]
]

