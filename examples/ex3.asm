l000:
addi sp, sp, -4
li t1, 7
sw t1, 0(sp) #PUSH 7

l001:
lw s0, 0(sp)
addi sp, sp, 4 #SET 0

l002:
addi sp, sp, -4
li t1, 1
sw t1, 0(sp) #PUSH 1

l003:
lw t3, 0(sp)
addi sp, sp, 4
li t1, 0
beq t3, t1, l007 # JMPZ

l004:
addi sp, sp, -4
sw s0, 0(sp) #GET 0

l005:
lw a0, 0(sp)
addi sp, sp, 4
li a7, 1
ecall # PRINT

l006:
jal t3, l009 # JMP

l007:
addi t0, t0, 0 #NOP
l008:
addi t0, t0, 0 #NOP
l009:
addi t0, t0, 0 #NOP

