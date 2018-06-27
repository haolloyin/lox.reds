Red/System []

#define value!      float32!

value-array!: alias struct! [
    capacity [integer!]
    count [integer!]
    values [pointer! [value!]]
]


value-ctx: context [
    init: func [array [value-array!]][
        array/values: null
        array/capacity: 0
        array/count: 0
    ]

    write: func [
        array [value-array!]
        value [value!]
        /local
            old-capacity [integer!]
            index [integer!]
    ][
        if array/capacity < (array/count + 1) [
            old-capacity: array/capacity
            array/capacity: GROW_CAPACITY(old-capacity)
            array/values: as [pointer! [value!]] memory-ctx/grow-array 
                as byte-ptr! array/values 
                size? value! 
                old-capacity 
                array/capacity
        ]

        index: array/count
        array/values/index: value
        array/count: array/count + 1
    ]

    free: func [array [value-array!]][
        memory-ctx/free-array
            as byte-ptr! array/values
            size? value!
            array/capacity

        init array
    ]

    print: func [value [value!]][
        printf ["%g" value]
    ]
]

