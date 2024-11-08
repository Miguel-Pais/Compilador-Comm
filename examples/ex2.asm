l000:
addi sp, sp, -4
li t1, 1
sw t1, 0(sp) #PUSH 

l001:
lw s0, 0(sp)
addi sp, sp, 4 #SET 0


l002:
addi sp, sp, -4
sw s0, 0(sp) #GET 0

l003:
addi sp, sp, -4
li t1, 10
sw t1, 0(sp) #PUSH 10


l004:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
slt t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # LT


l005:
lw t3, 0(sp)
addi sp, sp, 4
li t1, 0
beq t3, t1, l011 # JMPZ

l006:
addi sp, sp, -4
sw s0, 0(sp) #GET 0


l007:
addi sp, sp, -4
li t1, 1
sw t1, 0(sp) #PUSH 1


l008:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
add t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # ADD


l009:
lw s0, 0(sp)
addi sp, sp, 4 #SET 0


l010:
jal t3, l002 # JMP


l011:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l012:
lw a0, 0(sp)
addi sp, sp, 4
li a7, 1
ecall # PRINT
l013:
addi t0, t0, 0 #NOP

