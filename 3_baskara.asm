.data
msg_err:       .string "Erro! Não é equação do segundo grau!\n"
msg_real_1:    .string "R(1) = "
msg_real_2:    .string "R(2) = "
msg_mais_i:    .string " + "
msg_menos_i:   .string " - "
msg_i:         .string "i\n"

.text
.globl main

main:
    # Leitura de a
    li a7, 6
    ecall
    fmv.s ft0, fa0    # salva a em ft0

    # Leitura de b
    li a7, 6
    ecall
    fmv.s ft1, fa0    # salva b em ft1

    # Leitura de c
    li a7, 6
    ecall
    fmv.s ft2, fa0    # salva c em ft2

    # Move para registradores de argumento
    fmv.s fa0, ft0    # a
    fmv.s fa1, ft1    # b
    fmv.s fa2, ft2    # c

    # Chamada da função baskara(a, b, c)
    jal ra, baskara

    # Chamada da função show
    jal ra, show

    # Volta a ler novos valores
    call main
    

# ----------------------------------------------------
# Função: baskara
# Entrada: fa0 = a, fa1 = b, fa2 = c
# Saída:
# - a0 = tipo (0 = erro, 1 = reais, 2 = complexas)
# - 0(sp) = raiz1 ou parte real
# - 4(sp) = raiz2 ou parte imaginária
# ----------------------------------------------------
baskara:
    # Copia parâmetros
    fmv.s fs0, fa0   # a
    fmv.s fs1, fa1   # b
    fmv.s fs2, fa2   # c

    # Verifica se a == 0
    li t0, 0
    fcvt.s.w ft0, t0
    feq.s t1, fs0, ft0
    bnez t1, erro

    # delta = b^2 - 4ac
    fmul.s ft1, fs1, fs1       # b^2
    li t1, 4
    fcvt.s.w ft2, t1
    fmul.s ft3, fs0, fs2       # ac
    fmul.s ft3, ft3, ft2       # 4ac
    fsub.s ft4, ft1, ft3       # delta

    # Verifica delta < 0
    flt.s t1, ft4, ft0         # delta < 0 : t1 = 1; delta > 0 : t1 = 0
    bnez t1, complexas

    # Verifica delta == 0
    feq.s t1, ft4, ft0
    bnez t1, delta_zero

    # Raízes reais distintas
    fsqrt.s ft5, ft4           # sqrt(delta)
    li t1, 2
    fcvt.s.w ft6, t1
    fmul.s ft6, ft6, fs0       # 2a
    fneg.s ft7, fs1            # -b
    fadd.s ft8, ft7, ft5       # -b + sqrt(delta)
    fsub.s ft9, ft7, ft5       # -b - sqrt(delta)
    fdiv.s ft10, ft8, ft6      # x1
    fdiv.s ft11, ft9, ft6      # x2

    addi sp, sp, -8
    fsw ft10, 0(sp)
    fsw ft11, 4(sp)

    li a0, 1
    jr ra

delta_zero:
    li t1, 2
    fcvt.s.w ft6, t1           # 2
    fmul.s ft6, ft6, fs0       # 2a
    fneg.s ft7, fs1            # -b
    fdiv.s ft8, ft7, ft6       # x = -b / 2a

    addi sp, sp, -8
    fsw ft8, 0(sp)
    fsw ft8, 4(sp)

    li a0, 1
    jr ra

complexas:
    li t1, 2
    fcvt.s.w ft6, t1
    fmul.s ft6, ft6, fs0       # 2a
    fneg.s ft7, fs1            # -b
    fdiv.s ft8, ft7, ft6       # parte real

    fneg.s ft4, ft4            # -delta
    fsqrt.s ft5, ft4
    fdiv.s ft9, ft5, ft6       # parte imaginária

    addi sp, sp, -8
    fsw ft8, 0(sp)
    fsw ft9, 4(sp)

    li a0, 2
    jr ra

erro:
    li a0, 0
    addi sp, sp, -8
    li t1, 0
    fcvt.s.w ft0, t1
    fsw ft0, 0(sp)
    fsw ft0, 4(sp)
    jr ra

# ----------------------------------------------------
# Função show
# Entrada:
# - a0: tipo de raiz (0, 1 ou 2)
# - 0(sp): parte real ou raiz1
# - 4(sp): parte imaginária ou raiz2
# ----------------------------------------------------
show:
    beq a0, zero, show_erro

    li t0, 1
    beq a0, t0, show_reais

    li t0, 2
    beq a0, t0, show_complexas

    ret

show_reais:
    la a0, msg_real_1
    li a7, 4
    ecall

    flw ft0, 0(sp)
    li a7, 2
    fmv.s fa0, ft0
    ecall

    li a7, 11
    li a0, 10   # newline
    ecall

    la a0, msg_real_2
    li a7, 4
    ecall

    flw ft1, 4(sp)
    li a7, 2
    fmv.s fa0, ft1
    ecall

    li a7, 11
    li a0, 10
    ecall

    ret

show_complexas:
    # Parte real
    la a0, msg_real_1
    li a7, 4
    ecall

    flw ft0, 0(sp)       # parte real
    li a7, 2
    fmv.s fa0, ft0
    ecall

    la a0, msg_mais_i
    li a7, 4
    ecall

    flw ft1, 4(sp)       # parte imaginária
    li a7, 2
    fmv.s fa0, ft1
    ecall

    la a0, msg_i
    li a7, 4
    ecall

    # Parte real novamente para R(2)
    la a0, msg_real_2
    li a7, 4
    ecall

    flw ft0, 0(sp)
    li a7, 2
    fmv.s fa0, ft0
    ecall

    la a0, msg_menos_i
    li a7, 4
    ecall

    flw ft1, 4(sp)
    li a7, 2
    fmv.s fa0, ft1
    ecall

    la a0, msg_i
    li a7, 4
    ecall

    ret

show_erro:
    la a0, msg_err
    li a7, 4
    ecall
    ret
