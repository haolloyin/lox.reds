Red/System []

#include %common.reds
#include %memory.reds
#include %value.reds
#include %chunk.reds
#include %vm.reds
#include %debug.reds

rslox: context [
    test: func [
        /local
            chunk [chunk!]
            constant [integer!]
    ][
        vm-ctx/init

        chunk: declare chunk!
        chunk-ctx/init chunk
        
        constant: chunk-ctx/add-constant chunk 1.2          ;- 返回的是常量在 constants 的下标，基于 0
        chunk-ctx/write chunk as bcode! OP_CONSTANT 123     ;- 参数：chunk / byte字节码 / 行号
        chunk-ctx/write chunk as bcode! constant 123

        constant: chunk-ctx/add-constant chunk 3.4          ;- 常量 3.4
        chunk-ctx/write chunk as bcode! OP_CONSTANT 123
        chunk-ctx/write chunk as bcode! constant 123

        chunk-ctx/write chunk as bcode! OP_ADD 123          ;- 1.2 + 3.4 = 4.6

        constant: chunk-ctx/add-constant chunk 5.6          ;- 常量 5.6
        chunk-ctx/write chunk as bcode! OP_CONSTANT 123
        chunk-ctx/write chunk as bcode! constant 123

        chunk-ctx/write chunk as bcode! OP_DIVEDE 123       ;- 1.2 + 3.4 / 5.6 = 0.821429

        constant: chunk-ctx/add-constant chunk 0.7          ;- 常量 0.7
        chunk-ctx/write chunk as bcode! OP_CONSTANT 123
        chunk-ctx/write chunk as bcode! constant 123

        chunk-ctx/write chunk as bcode! OP_SUBTRACT 123     ;- 0.821429 - 0.7 = 0.121429

        constant: chunk-ctx/add-constant chunk -1.0         ;- 常量 -1
        chunk-ctx/write chunk as bcode! OP_CONSTANT 123
        chunk-ctx/write chunk as bcode! constant 123

        chunk-ctx/write chunk as bcode! OP_MULTIPLY 123     ;- 0.121429 * -1 = -0.121429

        chunk-ctx/write chunk as bcode! OP_NEGATE 123       ;- 0.121429
        chunk-ctx/write chunk as bcode! OP_RETURN 124

        disassemble-chunk chunk "test chunk"

        vm-ctx/interpret chunk
        vm-ctx/free

        chunk-ctx/free chunk
    ]

    repl: func [
        /local
            line [c-string!]
            bytes [byte-ptr!]
            count [integer!]
    ][
        bytes: as byte-ptr! system/stack/allocate 1024 / 4
        line: declare c-string!

        forever [
            print "> "
            ;if null? fgets bytes 1024 as byte-ptr! stdin [
            ;if null? fgets bytes 1024 stdin [
            ;if null? fgets bytes 1024 as int-ptr! stdin [
            ;if null? gets bytes [
            ;count: scanf ["%s" bytes]
            ;if negative? count [
            if null? fgets bytes 1024 new-stdin [
                print "fgets error"
                print lf
                break
            ]
            line: as c-string! bytes
            print line

            ;interpret line
        ]
    ]

    run-file: func [
        path [c-string!]
    ][
        print ["file: " path lf]
    ]

    main: func [
        /local
            args [str-array!]
    ][
        vm-ctx/init
        
        args: declare str-array!
        args: system/args-list
        
        switch system/args-count [
            1 [repl]
            2 [
                args: system/args-list + 1
                run-file args/item
            ]
            default [print ["Usage: clox [path]" lf]]
        ]

        vm-ctx/free
    ]
]

;rslox/test     ;- see output.txt
rslox/main

