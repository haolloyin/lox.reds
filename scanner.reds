Red/System []

#enum token-type! [
  ; Single-character tokens.
  TOKEN_LEFT_PAREN TOKEN_RIGHT_PAREN
  TOKEN_LEFT_BRACE TOKEN_RIGHT_BRACE
  TOKEN_COMMA TOKEN_DOT TOKEN_MINUS TOKEN_PLUS
  TOKEN_SEMICOLON TOKEN_SLASH TOKEN_STAR

  ; One or two character tokens.
  TOKEN_BANG TOKEN_BANG_EQUAL
  TOKEN_EQUAL TOKEN_EQUAL_EQUAL
  TOKEN_GREATER TOKEN_GREATER_EQUAL
  TOKEN_LESS TOKEN_LESS_EQUAL

  ; Literals.
  TOKEN_IDENTIFIER TOKEN_STRING TOKEN_NUMBER

  ; Keywords.
  TOKEN_AND TOKEN_CLASS TOKEN_ELSE TOKEN_FALSE
  TOKEN_FUN TOKEN_FOR TOKEN_IF TOKEN_NIL TOKEN_OR
  TOKEN_PRINT TOKEN_RETURN TOKEN_SUPER TOKEN_THIS
  TOKEN_TRUE TOKEN_VAR TOKEN_WHILE

  TOKEN_ERROR
  TOKEN_EOF
]

token!: alias struct! [
    type [token-type!]
    start [byte!]
    length [integer!]
    line [integer!]
]


scanner-ctx: context [

    scanner: declare struct! [
        start [byte!]
        current [byte!]
        line [integer!]
        end [byte!]
    ]

    init: func [
        source [c-string!]
    ][
        scanner/start: as byte! source
        scanner/current: as byte! source
        scanner/line: 1
        scanner/end: source + length? source - 1
    ]

    scan-token: func [
        return: [token!]
    ][
        scanner/start: scanner/current

        if at-end? [return make-token TOKEN_EOF]

        return error-token "Unexpected character."
    ]

    at-end?: func [
        return: [logic!]
    ][
        scanner/current = scanner/end
    ]

    make-token: func [
        type [token-type!]
        return: [token!]
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
    ][
        token: declare token!
        token/type: TOKEN_ERROR
        token/start: as byte! message
        token/length: length? message
        token/line: scanner/line

        token
    ]
]

