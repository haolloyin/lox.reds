Red/System []

disassemble-chunk: func [
    chunk [chunk!]
    name [c-string!]
    /local
        i [integer!]
        old-i [integer!]
][
    print-line ["== " name " =="]
    i: 0
    until [
        old-i: i
        i: disassemble-instruction chunk i
        ;print-line ["  ;-- chunk/count:" chunk/count ", i:" old-i " -> " i]
        i >= chunk/count
    ]
]

disassemble-instruction: func [
    chunk [chunk!]
    offset [integer!]
    return: [integer!]
    /local
        instruction [integer!]
       prev [integer!]
][
    instruction: chunk/code/offset

    printf ["%04d   " instruction]

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
        OP_RETURN [
            simple-instruction "OP_RETURN" offset
        ]
        default [
            print ["Unknown opcode " instruction lf]
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
        constant [integer!]
][
    index: offset + 1
    constant: chunk/code/index
    printf ["   %-14s" name]
    printf ["%-4d '" constant]
    value-ctx/print chunk/constants/values/constant
    print-line "'"
    
    offset + 2
]
