l000:
addi sp, sp, -4
li t1, 5
sw t1, 0(sp) #PUSH 5
l001:
addi sp, sp, -4
li t1, 2
sw t1, 0(sp) #PUSH 2
l002:
lw t1, 0(sp)
addi sp, sp, 4
lw t0, 0(sp)
addi sp, sp, 4
rem t2, t0, t1
addi sp, sp, -4
sw t2, 0(sp) # MOD
l003:
lw a0, 0(sp)
addi sp, sp, 4
li a7, 1
ecall # PRINT
l004:
addi t0, t0, 0 #NOP

