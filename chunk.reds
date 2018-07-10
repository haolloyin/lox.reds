Red/System []

#enum OpCode! [
    OP_CONSTANT: 1
    OP_ADD
    OP_SUBTRACT
    OP_MULTIPLY
    OP_DIVEDE
    OP_NEGATE
    OP_RETURN
]

chunk!: alias struct! [
    count [integer!]
    capacity [integer!]
    code [int-ptr!]             ;- 字节码，原本是用 byte! 表示，总量不会超过 256 个，改成 integer! 方便后续代码简洁
    constants [value-array!]    ;- 常量数组
    lines [int-ptr!]            ;- 记录行数
]


chunk-ctx: context [
    init: func [chunk [chunk!]][
        chunk/count: 0
        chunk/capacity: 0
        chunk/code: null
        chunk/constants: declare value-array!   ;- 结构体要先声明
        chunk/lines: null

        value-ctx/init chunk/constants
    ]

    write: func [
        chunk [chunk!] 
        byte [integer!]
        line [integer!]
        /local
            old-capacity [integer!]
            index [integer!]
    ][
        if chunk/capacity < (chunk/count + 1) [
            old-capacity: chunk/capacity
            chunk/capacity: GROW_CAPACITY(old-capacity)
            chunk/code: as int-ptr! memory-ctx/grow-array
                as byte-ptr! chunk/code
                size? integer!
                old-capacity
                chunk/capacity

            chunk/lines: as int-ptr! memory-ctx/grow-array
                as byte-ptr! chunk/lines
                size? integer!
                old-capacity
                chunk/capacity
        ]

        chunk/count: chunk/count + 1    ;- 消耗空间 +1
        index: chunk/count              ;- R/S 的指针是基于 /1 来指向的
        chunk/code/index: byte          ;- 写入字节码 byte
        chunk/lines/index: line
    ]

    free: func [chunk [chunk!]][
        memory-ctx/free-array
            as byte-ptr! chunk/code
            size? integer! 
            chunk/capacity

        value-ctx/free chunk/constants

        memory-ctx/free-array
            as byte-ptr! chunk/lines
            size? integer!
            chunk/capacity

        init chunk
    ]

    add-constant: func [
        chunk [chunk!]
        value [value!]
        return: [integer!]
    ][
        value-ctx/write chunk/constants value
        chunk/constants/count   ;- 因为每次 write 之后 count +1，而且 R/S 的指针是基于 1 的，所以干脆不需要 -1 更方便
    ]
]

