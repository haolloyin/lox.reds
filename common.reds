Red/System []

#import [
    LIBC-file cdecl [
        fgets: "fgets" [
            str [byte-ptr!]
            count [integer!]
            stream [byte-ptr!]
            return: [byte-ptr!]
        ]
        gets: "gets" [
            str [byte-ptr!]
            return: [byte-ptr!]
        ]
    ]
]

#either OS = 'Windows [
    #import [
        LIBC-file cdecl [
            fdopen: "_fdopen" [
                fd [integer!]
                mode [byte-ptr!]
                return: [byte-ptr!]
            ]
        ]
    ]
][
    #import [
        LIBC-file cdecl [
            fdopen: "fdopen" [
                fd [integer!]
                mode [byte-ptr!]
                return: [byte-ptr!]
            ]
        ]
    ]
]

new-stdin: fdopen 0 as byte-ptr! "r"
print-line ["stdin: " stdin]
print-line ["stdout: " stdout]
print-line ["stderr: " stderr]
print-line ["new-stdin: " new-stdin]


