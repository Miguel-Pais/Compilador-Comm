l000:
addi sp, sp, -4
li t1, 5
sw t1, 0(sp) #PUSH 5
l001:
lw s0, 0(sp)
addi sp, sp, 4 #SET 0
l002:
addi sp, sp, -4
li t1, 1
sw t1, 0(sp) #PUSH 1
l003:
lw s1, 0(sp)
addi sp, sp, 4 #SET 1
l004:
addi sp, sp, -4
li t1, 0
sw t1, 0(sp) #PUSH 0
l005:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l006:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
slt t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # LT
l007:
lw t3, 0(sp)
addi sp, sp, 4
li t1, 0
beq t3, t1, l017 # JMPZ
l008:
addi sp, sp, -4
sw s1, 0(sp) #GET 1
l009:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l010:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
mul t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # MUL
l011:
lw s1, 0(sp)
addi sp, sp, 4 #SET 1
l012:
addi sp, sp, -4
sw s0, 0(sp) #GET 0
l013:
addi sp, sp, -4
li t1, 1
sw t1, 0(sp) #PUSH 1
l014:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
sub t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # SUB
l015:
lw s0, 0(sp)
addi sp, sp, 4 #SET 0
l016:
jal t3, l004 # JMP
l017:
addi sp, sp, -4
sw s1, 0(sp) #GET 1
l018:
lw a0, 0(sp)
addi sp, sp, 4
li a7, 1
ecall # PRINT
l019:
addi t0, t0, 0 #NOP

