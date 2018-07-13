Red/System []

#enum InterpretResult! [
    INTERPRET_OK
    INTERPRET_COMPILE_ERROR
    INTERPRET_RUNTIME_ERROR
]

#define BINARY_OP(op) [
    b: pop
    a: pop
    push (a op b)
]

#define STACK_MAX 256


VM!: alias struct! [
    chunk [chunk!]
    ip [int-ptr!]  ;- 初始化会指向 chunk/code，字节码指针
    stack [pointer! [value!]]       ;- 固定个数的数组
    stack-top [pointer! [value!]]   ;- 指向栈顶
]

vm: declare VM!

vm-ctx: context [
    init: func [
    ][
        vm/stack: as [pointer! [value!]] memory-ctx/grow-array
            as byte-ptr! vm/stack
            size? value!
            0
            STACK_MAX * size? value!

        reset-stack
    ]
    
    free: func [
    ][
        
    ]

    reset-stack: func [
    ][
        vm/stack-top: vm/stack
    ]

    push: func [
        value [value!]
    ][
        vm/stack-top/value: value
        ++(vm/stack-top 1)
    ]

    pop: func [
        return: [value!]
    ][
        ++(vm/stack-top -1)
        vm/stack-top/value
    ]

    interpret: func [
        chunk [chunk!]
        return: [InterpretResult!]
    ][
        vm/chunk: chunk
        vm/ip: vm/chunk/code

        run
    ]

    read-byte: func [
        return: [integer!]
        /local
            byte [integer!]
    ][
        byte: vm/ip/value
        ++(vm/ip 1)
        byte
    ]

    read-constant: func [
        return: [value!]
        /local
            index [integer!]
    ][
        index: read-byte
        vm/chunk/constants/values/index
    ]

    run: func [
        return: [InterpretResult!]
        /local
            instruction [integer!]
            constant [value!]
            slot [pointer! [value!]]
            a [value!]
            b [value!]
    ][
        forever [
            print ["stack: "]
            slot: vm/stack
            while [slot < vm/stack-top][
                printf ["["]
                value-ctx/print slot/value
                printf ["] "]
                ++(slot 1)
            ]
            print-line ""

            ;disassemble-instruction vm/chunk as integer! (vm/ip - vm/chunk/code)
            ;disassemble-instruction vm/chunk (as integer! (vm/ip - vm/chunk/code)) / (size? integer!)    ;- 除以元素大小

            instruction: read-byte
            switch instruction [    ;- 必须是 integer!
                OP_CONSTANT [
                    constant: read-constant     ;- 常量下标需要再读取一位
                    push constant
                    ;value-ctx/print constant
                    ;print-line ""
                ]
                OP_ADD [
                    BINARY_OP(+)
                ]
                OP_SUBTRACT [
                    BINARY_OP(-)
                ]
                OP_MULTIPLY [
                    BINARY_OP(*)
                ]
                OP_DIVEDE [
                    BINARY_OP(/)
                ]
                OP_NEGATE [
                    push (0.0 - pop)
                ]
                OP_RETURN [
                    value-ctx/print pop
                    print-line ""
                ]
                default [
                    break
                ]
            ]
        ]
        INTERPRET_COMPILE_ERROR
    ]
]

