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
        
        constant: chunk-ctx/add-constant chunk 1.2
        chunk-ctx/write chunk OP_CONSTANT 111
        chunk-ctx/write chunk constant 111

        constant: chunk-ctx/add-constant chunk 3.3
        chunk-ctx/write chunk OP_CONSTANT 111
        chunk-ctx/write chunk constant 111

        chunk-ctx/write chunk OP_RETURN 112

        disassemble-chunk chunk "test chunk"

        chunk-ctx/free chunk
    ]
]

rslox/main

