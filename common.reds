Red/System []

#import [
    LIBC-file cdecl [
        fgets: "fgets" [
            str         [byte-ptr!]
            count       [integer!]
            stream      [byte-ptr!]
            return:     [byte-ptr!]
        ]
        fopen: "fopen" [
            path        [c-string!]
            mode        [byte-ptr!]
            return:     [byte-ptr!]
        ]
        fseek: "fseek" [
            stream      [byte-ptr!]
            offset      [integer!]
            whence      [integer!]
            return:     [integer!]
        ]
        ftell: "ftell" [
            stream      [byte-ptr!]
            return:     [integer!]
        ]
        rewind: "rewind" [
            stream      [byte-ptr!]
        ]
        fread: "fread" [
            ptr         [byte-ptr!]
            unit-size   [integer!]
            units       [integer!]
            stream      [byte-ptr!]
            return:     [integer!]
        ]
        fclose: "fclose" [
            stream      [byte-ptr!]
            return:     [integer!]
        ]
		fprintf: "fprintf" [
            [variadic] 
            return: [integer!]
        ]
    ]
]

#either OS = 'Windows [
    #import [
        LIBC-file cdecl [
            fdopen: "_fdopen" [
                fd      [integer!]
                mode    [byte-ptr!]
                return: [byte-ptr!]
            ]
        ]
    ]
][
    #import [
        LIBC-file cdecl [
            fdopen: "fdopen" [
                fd      [integer!]
                mode    [byte-ptr!]
                return: [byte-ptr!]
            ]
        ]
    ]
]

print-line ["--------- common -----------"]
new-stdin: fdopen 0 as byte-ptr! "r"
new-stderr: fdopen 2 as byte-ptr! "w"
print-line ["stdin: " stdin]
print-line ["stdout: " stdout]
print-line ["stderr: " stderr]
print-line ["new-stdin: " new-stdin]
print-line ["new-stderr: " new-stderr]

#define SEEK_SET    0   ;/* set file offset to offset */
#define SEEK_CUR    1   ;/* set file offset to current plus offset */
#define SEEK_END    2   ;/* set file offset to EOF plus offset */

#define ++(var i)     [var: var + i]        ; 类似 i++ 操作符
#define --(var i)     [var: var - i]        ; 类似 i-- 操作符

MAX_INT: (1 << (8 * (size? integer!) - 1)) - 1
print-line ["MAX_INT: " MAX_INT]
print-line ["--------- end -----------" lf]


