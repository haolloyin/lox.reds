Red/System []

#include %scanner.reds

compiler: context [
    compile: func [
        source [c-string!]
        /local
            line [integer!]
            token [token!]
    ][
        scanner-ctx/init source

        line: -1
        forever [
            token: scanner-ctx/scan-token
            either token/line <> line [
                printf ["%4d " token/line]
                line: token/line
            ][
                print ["   | " lf]
            ]
            printf ["%2d  %d  '%.*s'" token/type token/length token/start]
            print lf
            break

            if token/type = TOKEN_EOF [break]
        ]
    ]

]

