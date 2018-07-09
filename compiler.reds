Red/System []

#include %scanner.reds

compiler: context [
    compile: func [
        source [c-string!]
        /local
            line [integer!]
            token [token!]
            idx [integer!]
            c [byte-ptr!]
    ][
        scanner-ctx/init source

        line: -1
        forever [
            token: scanner-ctx/scan-token
 
            either token/line <> line [
                printf ["%4d   " token/line]
                line: token/line
            ][
                print ["   |   "]
            ]
            printf ["%2d   {%.*s}" token/type token/length token/start]
            print lf

            if token/type = TOKEN_EOF [break]
        ]
    ]

]

