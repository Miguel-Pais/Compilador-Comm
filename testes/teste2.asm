l000:
addi sp, sp, -4
li t1, 7
sw t1, 0(sp) #PUSH 7
l001:
lw s0, 0(sp)
addi sp, sp, 4 #SET 0
l002:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l003:
addi sp, sp, -4
li t1, 7
sw t1, 0(sp) #PUSH 7
l004:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
slt t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # LT
l005:
addi sp, sp, -4
li t1, 1
sw t1, 0(sp) #PUSH 1
l006:
li t1, 0
beq t2, t1, l010 # AND
l007:
lw t3, 0(sp)
addi sp, sp, 4
li t1, 0
beq t3, t1, l011 # JMPZ
l008:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l009:
lw a0, 0(sp)
addi sp, sp, 4
li a7, 1
ecall # PRINT
l010:
jal t3, l013 # JMP
l011:
addi t0, t0, 0 #NOP
l012:
addi t0, t0, 0 #NOP
l013:
addi t0, t0, 0 #NOP