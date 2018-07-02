Red/System []

disassemble-chunk: func [
    chunk [chunk!]
    name [c-string!]
    /local
        i [integer!]
        old-i [integer!]
][
    print-line ""
    print-line ["---------------------------- " name " -------------------------------"]
    print-line ["offset    address     bytecode    line      name      offset   constant"]
    print-line ["-----------------------------------------------------------------------"]
    i: 0
    until [
        i: disassemble-instruction chunk i
        i >= chunk/count
    ]
    print-line ["-----------------------------------------------------------------------" lf]
]

disassemble-instruction: func [
    chunk [chunk!]
    offset [integer!]
    return: [integer!]
    /local
        instruction [bcode-ptr!]
        index [integer!]
][
    instruction: chunk/code + offset
    printf ["%4d      " offset]
    printf ["%08d      " as integer! instruction]       ;- 指令地址
    printf ["%4d      " as integer! instruction/value]  ;- 指令的值

    ;- 行号
    index: offset + 1
    either all [index > 0 chunk/lines/index = chunk/lines/offset] [
        printf ["%4s" "|"]      ;- 行号和上一行相同用竖线表示
    ][
        printf ["%4d" chunk/lines/index]
    ]

    switch instruction/value [
        OP_CONSTANT [
            constant-instruction "OP_CONSTANT" chunk offset
        ]
        OP_ADD [
            simple-instruction "OP_ADD" offset
        ]
        OP_SUBTRACT [
            simple-instruction "OP_SUBTRACT" offset
        ]
        OP_MULTIPLY [
            simple-instruction "OP_MULTIPLY" offset
        ]
        OP_DIVEDE [
            simple-instruction "OP_DIVEDE" offset
        ]
        OP_NEGATE [
            simple-instruction "OP_NEGATE" offset
        ]
        OP_RETURN [
            simple-instruction "OP_RETURN" offset
        ]
        default [
            ;printf ["   %-14s" "Unknown"  instruction lf]
            printf ["   %-14s  " "Unknown"]
            printf ["%-4d" as integer! instruction]
            print lf
            offset + 1
        ]
    ]
]

simple-instruction: func [
    name [c-string!]
    offset [integer!]
    return: [integer!]
][
    printf ["   %-14s" name]
    print lf
    offset + 1
]

constant-instruction: func [
    name [c-string!]
    chunk [chunk!]
    offset [integer!]
    return: [integer!]
    /local
        index [integer!]
        constant [bcode!]
][
    index: offset + 2   ;- 常量的下标紧跟在 op code 之后
    ;constant: as integer! chunk/code/index
    constant: as bcode! chunk/code/index
    printf ["   %-14s  " name]
    printf ["%-4d   '" constant]

    index: (as integer! constant) + 1
    value-ctx/print chunk/constants/values/index
    print-line "'"
    
    offset + 2
]

