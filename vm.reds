Red/System []

#enum InterpretResult [
    INTERPRET_OK
    INTERPRET_COMPILE_ERROR
    INTERPRET_RUNTIME_ERROR
]

#define STACK_MAX 256


VM!: alias struct! [
    chunk [chunk!]
    ip [bcode-ptr!]  ;- 初始化会指向 chunk/code，字节码指针
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
        vm/stack-top: vm/stack-top + 1
    ]

    pop: func [
        return: [value!]
    ][
        vm/stack-top: vm/stack-top - 1
        vm/stack-top/value
    ]

    interpret: func [
        chunk [chunk!]
        return: [InterpretResult]
    ][
        vm/chunk: chunk
        vm/ip: vm/chunk/code

        ;printf ["ip:%08d, value:%d, next:%08d" vm/ip vm/ip/0 (vm/ip + 1)]
        ;print-line ""
        ;printf ["ip:%08d, value:%d, next:%08d" vm/ip vm/ip/1 (vm/ip + 1)]
        ;print-line ""
        ;printf ["ip:%08d, value:%d, next:%08d" vm/ip vm/ip/value (vm/ip + 1)]
        ;print-line ""

        run
    ]

    read-byte: func [
        return: [bcode!]
        /local
            byte [bcode!]
    ][
        byte: vm/ip/0       ;- 为什么不能用 /value，只能用 /0 ??
        ;byte: vm/ip/value   ;- why error??
        vm/ip: vm/ip + 1
        ;printf ["read byte:%d, vm/ip:%d" byte vm/ip]
        ;print-line ""
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
            instruction [bcode!]
            constant [value!]
            slot [pointer! [value!]]
    ][
        forever [
            ;print ["stack: "]
            ;slot: vm/stack
            ;while [slot < vm/stack-top][
            ;    printf ["[ "]
            ;    value-ctx/print slot/value
            ;    printf [" ]"]
            ;    slot: slot + 1
            ;]
            ;print-line ""

            ;disassemble-instruction vm/chunk as integer! (vm/ip - vm/chunk/code)
            disassemble-instruction vm/chunk (as integer! (vm/ip - vm/chunk/code)) / (size? bcode!)

            instruction: read-byte
            switch as integer! instruction [    ;- 必须是 integer!
                OP_CONSTANT [
                    constant: read-constant
                    push constant
                    value-ctx/print constant
                    print-line ""
                ]
                OP_NEGATE [
                    push as value! (0 - pop)
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

