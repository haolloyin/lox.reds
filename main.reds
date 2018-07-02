Red/System []

#include %common.reds
#include %memory.reds
#include %value.reds
#include %chunk.reds
#include %vm.reds
#include %debug.reds

rslox: context [
    
    vm-ctx/init

    chunk: declare chunk!

    main: func [
        /local
            constant [integer!]
    ][
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
]

rslox/main

;- see output.txt

