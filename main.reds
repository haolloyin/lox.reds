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

    interpret: func [
        source [byte-ptr!]
        return: [InterpretResult!]
    ][
        return null
    ]

    read-file: func [
        path [c-string!]
        return: [byte-ptr!]
        /local
            file [byte-ptr!]
            fsize [integer!]
            buffer [byte-ptr!]
            bytes-read [integer!]
    ][
        file: fopen path as byte-ptr! "rb"
        if null? file [
            print-line ["Could not open file '" path "'."]
            quit 74
        ]

        fseek file 0 SEEK_END
        fsize: ftell file
        rewind file

        print-line ["file size: " fsize]

        buffer: allocate fsize + 1
        if null? buffer [
            print-line ["Not enough memory to read '" path "'."]
            quit 74
        ]

        bytes-read: fread buffer size? byte! fsize file
        print-line ["bytes-read: " bytes-read]
        if bytes-read < fsize [
            print-line ["Could not read file'" path "'."]
            quit 74
        ]

        fclose file

        print-line ["buffer: " as-c-string buffer]

        return buffer
    ]

    run-file: func [
        path [c-string!]
        /local
            result [InterpretResult!]
            source [byte-ptr!]
    ][
        print ["file: " path lf]

        source: read-file path
        result: interpret source

        free source

        switch result [
            INTERPRET_COMPILE_ERROR [exit 65]
            INTERPRET_RUNTIME_ERROR [exit 70]
            default [exit 0]
        ]
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
            default [print-line [lf "Usage: clox [path]"]]
        ]

        vm-ctx/free
    ]
]

;rslox/test     ;- see output.txt
rslox/main

