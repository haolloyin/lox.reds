Red/System []

#enum OpCode! [
    OP_CONSTANT
    OP_RETURN
]

chunk!: alias struct! [
    count [integer!]
    capacity [integer!]
    code [byte-ptr!]            ;- 字节码，总量不会超过 256 个，用 byte! 表示
    constants [value-array!]    ;- 常量数组
    lines [int-ptr!]            ;- 记录行数
]


chunk-ctx: context [
    init: func [chunk [chunk!]][
        chunk/count: 0
        chunk/capacity: 0
        chunk/code: null
        chunk/constants: declare value-array!   ;- 先声明
        chunk/lines: null

        value-ctx/init chunk/constants
    ]

    write: func [
        chunk [chunk!] 
        byte [byte!]
        line [integer!]
        /local
            old-capacity [integer!]
            index [integer!]
    ][
        if chunk/capacity < (chunk/count + 1) [
            old-capacity: chunk/capacity
            chunk/capacity: GROW_CAPACITY(old-capacity)
            chunk/code: memory-ctx/grow-array
                chunk/code
                size? byte!
                old-capacity
                chunk/capacity

            chunk/lines: as int-ptr! memory-ctx/grow-array
                as byte-ptr! chunk/lines
                size? integer!
                old-capacity
                chunk/capacity
        ]

        index: chunk/count
        chunk/code/index: byte          ;- 写入字节码 byte
        chunk/lines/index: line
        chunk/count: chunk/count + 1    ;- 消耗空间 +1
    ]

    free: func [chunk [chunk!]][
        memory-ctx/free-array
            chunk/code
            size? byte!
            chunk/capacity

        ;- TODO 这里 free 会报错
        ;print-line ["  ;-- before free constants:" chunk/constants]
        ;value-ctx/free chunk/constants
        ;print-line ["  ;-- after free constants:" chunk/constants]

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
        chunk/constants/count - 1
    ]
]

