Red/System []

#enum InterpretResult [
    INTERPRET_OK
    INTERPRET_COMPILE_ERROR
    INTERPRET_RUNTIME_ERROR
]

VM!: alias struct! [
    chunk [chunk!]
    ip [byte-ptr!]  ;- 初始化会指向 chunk/code，字节码指针
]

vm: declare VM!

vm-ctx: context [
    init: func [
    ][
        
    ]
    
    free: func [
    ][
        
    ]

    interpret: func [
        chunk [chunk!]
        return: [InterpretResult]
    ][
        vm/chunk: chunk
        vm/ip: vm/chunk/code
        print-line ["ip:" vm/ip ", next:" vm/ip + 1]

        run
    ]

    read-byte: func [
        return: [byte!]
        /local
            byte [byte!]
    ][
        byte: vm/ip/value
        vm/ip: vm/ip + 1
        print-line ["ip:" byte ", next:" vm/ip]
        byte
    ]

    read-constant: func [
        return: [value!]
        /local
            index [integer!]
    ][
        index: as integer! read-byte
        vm/chunk/constants/values/index
    ]

    run: func [
        return: [InterpretResult]
        /local
            instruction [byte!]
            constant [value!]
    ][
        forever [
            switch instruction: read-byte [
                ;OP_CONSTANT [
                ;    constant: read-constant
                ;    value-ctx/print constant
                ;    print-line
                ;    return INTERPRET_OK
                ;]
                OP_RETURN [
                    return INTERPRET_OK
                ]
                default [
                    return INTERPRET_OK
                ]
            ]
        ]
        INTERPRET_COMPILE_ERROR
    ]
]

