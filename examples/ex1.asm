l000:
addi sp, sp, -4
li t1, 1
sw t1, 0(sp) #PUSH 1
l001:
lw s0, 0(sp)
addi sp, sp, 4 #SET 0
l002:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l003:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l004:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
add t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # ADD
l005:
lw a0, 0(sp)
addi sp, sp, 4
li a7, 1
ecall # PRINT
l006:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l007:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l008:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
sub t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # SUB
l009:
lw a0, 0(sp)
addi sp, sp, 4
li a7, 1
ecall # PRINT
l010:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l011:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l012:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
mul t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # MUL
l013:
lw a0, 0(sp)
addi sp, sp, 4
li a7, 1
ecall # PRINT
l014:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l015:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l016:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
div t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # DIV
l017:
lw a0, 0(sp)
addi sp, sp, 4
li a7, 1
ecall # PRINT
l018:
addi t0, t0, 0 #NOP

