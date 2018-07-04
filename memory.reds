Red/System []


;-- memory macros
#define GROW_CAPACITY(capacity) (
    either (capacity) < 8 [8][(capacity) * 2]
)

;#define GROW_ARRAY(previous type old-count count) ]
;    memory-ctx/reallocate
;        previous 
;        (size? type) * (old-count) 
;        (size? type) * (count)
;]
;
;#define FREE_ARRAY(type pointer old-count) (
;    memory-ctx/reallocate 
;        pointer
;        (size? type) * (old-count)
;        0
;)

memory-ctx: context [
    ;-- C standard memory functions
    #import [
        LIBC-file cdecl [
            realloc:    "realloc" [
                ptr         [byte-ptr!]
                size        [integer!]
                return:     [byte-ptr!]
            ]
        ]
    ]

    reallocate: func [
        previous [byte-ptr!]
        old-size [integer!]
        new-size [integer!]
        return: [byte-ptr!]     ;- 返回是 byte-ptr!，调用方负责转型
    ][
        if new-size = 0 [
            free previous
            return null
        ]

        realloc previous new-size
    ]

    grow-array: func [
        previous [byte-ptr!]
        size [integer!]
        old-count [integer!]
        count [integer!]
        return: [byte-ptr!]     ;- 返回是 byte-ptr!，调用方负责转型
        /local
            ptr [byte-ptr!]
    ][
        ptr: reallocate
            previous
            size * old-count
            size * count
        print-line ["  ;-- grow-array:" previous ", size:" size ", old:" old-count ", count:" count ", at:" ptr]
        ptr
    ]

    free-array: func [
        pointer [byte-ptr!]
        size [integer!]
        old-count [integer!]
    ][
        print-line ["  ;-- free:" pointer]
        reallocate pointer size * old-count 0
    ]
]

