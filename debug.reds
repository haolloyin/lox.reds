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
        instruction [bcode!]
        prev [integer!]
        ins [byte-ptr!]
][
    instruction: chunk/code/offset
    printf ["%4d      " offset]
    printf ["%08d      " as integer! (chunk/code + offset)]     ;- 指令地址
    printf ["%4d      " as integer! instruction]               ;- 指令的值

    ;ins: chunk/code + offset
    ;printf ["%4d      " offset]
    ;printf ["%08d      " as integer! ins]
    ;printf ["%04d      " as integer! ins/0] ;- 为什么不是 /value 或 /1 ??

    ;- 行号
    prev: offset - 1
    either all [offset > 0 chunk/lines/offset = chunk/lines/prev] [
        printf ["%4s" "|"]      ;- 行号和上一行相同用竖线表示
    ][
        printf ["%4d" chunk/lines/offset]
    ]

    switch instruction [
        OP_CONSTANT [
            constant-instruction "OP_CONSTANT" chunk offset
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
    index: offset + 1
    constant: chunk/code/index
    printf ["   %-14s  " name]
    printf ["%-4d   '" as integer! constant]

    index: as integer! constant
    value-ctx/print chunk/constants/values/index
    print-line "'"
    
    offset + 2
]

