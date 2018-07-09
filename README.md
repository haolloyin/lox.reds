
## How to compile

Use `red -c main.reds` to compile and run it `./main` will output:


## Compile to byte code

Output:

```shell
  ;-- grow-array:00000000, size:4, old:0, count:1024, at:00543250
  ;-- grow-array:00000000, size:4, old:0, count:8, at:005419D8
  ;-- grow-array:00000000, size:4, old:0, count:8, at:00541A00
  ;-- grow-array:00000000, size:4, old:0, count:8, at:00541A28
  ;-- grow-array:00541A00, size:4, old:8, count:16, at:00541A50
  ;-- grow-array:00541A28, size:4, old:8, count:16, at:00541A98

---------------------------- test chunk -------------------------------
offset    address     bytecode    line      name      offset   constant
-----------------------------------------------------------------------
   0      05511760         5       123   OP_CONSTANT     0      '1.2'
   2      05511768         5         |   OP_CONSTANT     1      '3.4'
   4      05511776         6         |   OP_ADD        
   5      05511780         5         |   OP_CONSTANT     2      '5.6'
   7      05511788         9         |   OP_DIVEDE     
   8      05511792         5         |   OP_CONSTANT     3      '0.7'
  10      05511800         7         |   OP_SUBTRACT   
  11      05511804         5         |   OP_CONSTANT     4      '-1'
  13      05511812         8         |   OP_MULTIPLY   
  14      05511816        10         |   OP_NEGATE     
  15      05511820        11       124   OP_RETURN     
-----------------------------------------------------------------------

stack: 
stack: [1.2] 
stack: [1.2] [3.4] 
stack: [4.6] 
stack: [4.6] [5.6] 
stack: [0.821429] 
stack: [0.821429] [0.7] 
stack: [0.121429] 
stack: [0.121429] [-1] 
stack: [-0.121429] 
stack: [0.121429] 
0.121429
stack: 
  ;-- free:00541A50
  ;-- free:005419D8
  ;-- free:00541A98
```


## Scan source code

Output:

```shell
stdin: 0
stdout: 1
stderr: 2
new-stdin: A6F42400
  ;-- grow-array:00000000, size:8, old:0, count:2048, at:00804600
file: sample.txt
file size: 14
bytes-read: 14
-------- file content --------
print 1 + 2;

------------------------------
   1   31   {print}
   |   21   {1}
   |    7   {+}
   |   21   {2}
   |    8   {;}
   2   39   {
}
```

