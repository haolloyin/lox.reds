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

        c: advance
        if at-end? [return make-token TOKEN_EOF]
        if alpha? c [return make-identifier]
        if digit? c [return make-number]

        ;print-line ["c: {" c "}"]

        switch c [
            #";" [return make-token TOKEN_SEMICOLON]
            #"," [return make-token TOKEN_COMMA]
            #"." [return make-token TOKEN_DOT]
            #"-" [return make-token TOKEN_MINUS]
            #"+" [return make-token TOKEN_PLUS]
            #"/" [return make-token TOKEN_SLASH]
            #"*" [return make-token TOKEN_STAR]
            #"(" [return make-token TOKEN_LEFT_PAREN]
            #")" [return make-token TOKEN_RIGHT_PAREN]
            #"^{" [return make-token TOKEN_LEFT_BRACE]
            #"^}" [return make-token TOKEN_RIGHT_BRACE]
            #"!" [return make-token either match? #"=" [TOKEN_BANG_EQUAL][TOKEN_BANG]]
            #"=" [return make-token either match? #"=" [TOKEN_EQUAL_EQUAL][TOKEN_EQUAL]]
            #"<" [return make-token either match? #"=" [TOKEN_LESS_EQUAL][TOKEN_LESS]]
            #">" [return make-token either match? #"=" [TOKEN_GREATER_EQUAL][TOKEN_GREATER]]
            #"^\" [return make-string]
            default [
                ;print-line ["default: " c]
                return error-token "Unexpected character."
            ]
        ]

        return error-token "Unexpected character."
    ]

    skip-whitespace: func [/local c [byte!]][
        forever [
            c: peek
            ;- See http://www.rebol.com/docs/core23/rebolcore-16.html#section-3.1
            switch c [
                #" "
                #"^M"
                #"^(tab)" [
                    advance
                    ;print-line ["skip whitespace"]
                    break
                ]
                #"^(line)"[
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
                    ;print-line ["do not skip: " c]
                    break
                ]
            ]
        ]
    ]

    advance: func [
        return: [byte!]
        /local
            idx [integer!]
            c [byte!]
    ][
        c: scanner/current/value
        scanner/current: scanner/current + 1
        c
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

    peek-next: func [return: [byte!] /local p [byte-ptr!]][
        if at-end? [return null-byte]
        p: scanner/current + 1
        p/value
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
        make-token get-identifier-type
    ]

    get-identifier-type: func [
        return: [token-type!]
        /local c [byte-ptr!]
    ][
        switch scanner/start/value [
            #"a" [return check-keyword 1 2 "nd" TOKEN_AND]
            #"c" [return check-keyword 1 4 "lass" TOKEN_CLASS]
            #"e" [return check-keyword 1 3 "lse" TOKEN_ELSE]
            #"f" [
                if (as-integer scanner/current - scanner/start) > 1 [
                    c: scanner/start + 1
                    switch c/value [
                        #"a" [return check-keyword 2 3 "lse" TOKEN_FALSE]
                        #"o" [return check-keyword 2 1 "r" TOKEN_FOR]
                        #"u" [return check-keyword 2 1 "n" TOKEN_FUN]
                    ]
                ]
                return TOKEN_IDENTIFIER
            ]
            #"i" [return check-keyword 1 1 "f" TOKEN_IF]
            #"n" [return check-keyword 1 2 "il" TOKEN_NIL]
            #"o" [return check-keyword 1 1 "r" TOKEN_OR]
            #"p" [return check-keyword 1 4 "rint" TOKEN_PRINT]
            #"r" [return check-keyword 1 5 "eturn" TOKEN_RETURN]
            #"s" [return check-keyword 1 4 "uper" TOKEN_SUPER]
            #"v" [return check-keyword 1 2 "ar" TOKEN_VAR]
            #"w" [return check-keyword 1 4 "hile" TOKEN_WHILE]
            default [TOKEN_IDENTIFIER]
        ]
    ]

    check-keyword: func [
        start [integer!]
        length [integer!]
        rest [c-string!]
        type [token-type!]
        return: [token-type!]
        /local
            c [byte-ptr!]
            c2 [byte-ptr!]
            i [integer!]
    ][
        i: 0
        until [
            c: as byte-ptr! rest + i
            c2: scanner/start + start + i

            if c/value <> c2/value [return TOKEN_IDENTIFIER]
            i: i + 1
            i < length
        ]
        return type
    ]

    make-string: func [
        return: [token!]
    ][
        while [all [peek <> #"^"" not at-end?]][
            if peek = cr [
                scanner/line: scanner/line + 1
            ]
            advance
        ]

        if at-end? [return error-token "Unexpected character."]

        advance

        return make-token TOKEN_STRING
    ]

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

