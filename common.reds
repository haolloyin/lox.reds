Red/System []

FILE!: alias struct! [
    unused [integer!]
]

#import [
    LIBC-file cdecl [
        fgets: "fgets" [
            str [byte-ptr!]
            count [integer!]
            ;stream [FILE!]
            ;stream [integer!]
            stream [byte-ptr!]
            return: [byte-ptr!]
        ]
        gets: "gets" [
            str [byte-ptr!]
            return: [byte-ptr!]
        ]
    ]
]


;#switch OS [
;    'Windows [
;        #import [
;            "kernel32.dll" stdcall [
;                GetStdHandle: "GetStdHandle" [
;                    type		[integer!]
;                    return:		[integer!]
;                ]
;            ]
;        ]
;
;        stdin:  GetStdHandle WIN_STD_INPUT_HANDLE
;        stdout: GetStdHandle WIN_STD_OUTPUT_HANDLE
;        stderr: GetStdHandle WIN_STD_ERROR_HANDLE 
;    ]
;]

