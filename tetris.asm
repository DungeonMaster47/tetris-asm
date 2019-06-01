.model small
.stack 100h
.data
messageWelcome db "Tetris",0Dh ,0Ah   
               db "Controls:",0Dh ,0Ah
               db "Left/Right arrow - move",0Dh ,0Ah
               db "Up arrow - rotate:",0Dh ,0Ah
               db "Esc - exit:",0Dh ,0Ah
               db "Enter - start:",0Dh ,0Ah,
               db "A HIDEO KOJIMA GAME",0Dh ,0Ah, '$'
playField db 276 dup(00h)
figureShape db 00h, 00h, 00h, 00h  ;L 10
            db 00h, 00h, 10h, 00h 
            db 10h, 10h, 10h, 00h           
            db 00h, 00h, 00h, 00h
           
            db 00h, 00h, 00h, 00h ;T 20
            db 00h, 20h, 00h, 00h 
            db 20h, 20h, 20h, 00h
            db 00h, 00h, 00h, 00h
            
            db 00h, 00h, 30h, 00h ;Z 30
            db 00h, 30h, 30h, 00h
            db 00h, 30h, 00h, 00h
            db 00h, 00h, 00h, 00h
            
            db 00h, 00h, 00h, 00h ;S 40
            db 00h, 00h, 40h, 40h
            db 00h, 40h, 40h, 00h
            db 00h, 00h, 00h, 00h
            
            db 00h, 00h, 00h, 00h ;O 50
            db 00h, 50h, 50h, 00h
            db 00h, 50h, 50h, 00h
            db 00h, 00h, 00h, 00h           
            
            db 00h, 0E0h, 0E0h, 00h ;J E0
            db 00h, 0E0h, 00h, 00h
            db 00h, 0E0h, 00h, 00h
            db 00h, 00h,  00h, 00h
            
            db 00h, 00h, 60h, 00h ;I 60
            db 00h, 00h, 60h, 00h
            db 00h, 00h, 60h, 00h
            db 00h, 00h, 60h, 00h  

currentFigureShape db 00h, 00h, 00h, 00h
                   db 00h, 00h, 00h, 00h
                   db 00h, 00h, 00h, 00h
                   db 00h, 00h, 00h, 00h  

currentFigure dw 0
currentFigureX dw 0
currentFigureY dw 0 
previousTime dw 0    
score dw 0
.code
jmp main
  
printScore proc near
    pusha
    xor cx, cx    
    mov ax, score
    xor dx, dx 
    mov si, 10
loadStack:   
    div si 			  		
    add dl, '0'
    push dx    
    xor dx, dx 
    inc cx        
    cmp ax, 0
    jne loadStack   
    mov bx, 202      
printStack:
    pop dx 
    push ds
    mov ax, 0b800h
    mov ds, ax
    mov [bx], dl
    inc bx
    mov [bx], 07h
    inc bx
    pop ds           
    loop printStack          
    popa 
    ret   
endp    
  
initScreen proc near
    push cx
    push ax
    push si
    push ds       
    mov ax, 0b800h
    mov ds, ax 
        
    xor bx, bx
    mov cx, 1000
    loopScreen:     
    mov [bx], ' '
    inc bx
    mov [bx], 07h
    inc bx
    loop loopScreen
    
    xor si, si
    mov ax, 40
    firstLine:
    mov [si], ' '
    inc si
    mov [si], 40h
    inc si
    dec ax
    cmp ax, 0
    je firstLineEnd
    jmp firstLine
    firstLineEnd:
    mov ax, 23
    columns:
    mov [si], ' '
    inc si
    mov [si], 40h
    inc si
    add si, 76
    mov [si], ' '
    inc si
    mov [si], 40h
    inc si
    dec ax
    cmp ax, 0
    je columnsEnd
    jmp columns
    columnsEnd:
    mov ax, 40
    secondLine:
    mov [si], ' '
    inc si
    mov [si], 40h
    inc si
    dec ax
    cmp ax, 0
    je secondLineEnd
    jmp secondLine
    secondLineEnd:
    mov cx, 2
    glass:
    mov al, 80
    mul cl
    add ax, 4
    mov si, ax
    mov [si], ' '
    inc si
    mov [si], 70h
    add si, 21
    mov [si], ' '
    inc si
    mov [si], 70h
    inc cx
    cmp cx, 23
    je glassEnd
    jmp glass
    glassEnd:
    mov cx, 2
    glassBottom:
    mov al, 2
    mul cl
    add ax, 1760
    mov si, ax
    mov [si], ' '
    inc si
    mov [si], 70h
    inc cx
    cmp cx, 14
    je glassBottomEnd
    jmp glassBottom
    glassBottomEnd:
    mov [190], 'S' 
    mov [192], 'c'
    mov [194], 'o'
    mov [196], 'r'
    mov [198], 'e'
    mov [200], ':'
    
    pop ds
    pop si
    pop ax
    pop cx
    ret
endp

initPlayField proc near
    push cx
    push bx
    push ax  
    xor ax, ax
    mov cx, 276  
    mov bx, offset playField
    loopInit:         
    mov [bx], ah
    inc bx
    loop loopInit
    mov cx, 0
    borders:
    mov al, 12
    mul cl
    mov bx, offset playField
    add bx, ax
    mov [bx], 60
    add bx, 11
    mov [bx], 60
    inc cx
    cmp cx, 23
    je bordersEnd
    jmp borders
    bordersEnd:
    mov cx, 0
    bottom:
    mov bx, offset playField
    add bx, cx
    add bx, 264
    mov [bx], 10
    inc cx
    cmp cx, 12
    je bottomEnd
    jmp bottom
    bottomEnd:
    pop ax
    pop bx
    pop cx
    ret
endp

displayPlayField proc near
    push ax
    push es
    push cx
    push di
    push si
    mov ax, 0B800h
    mov es, ax
    mov cx, 20
    mov di, 167
    mov si, offset playField
    add si, 25
    loop1:
    push cx
    mov cx, 10
    loop2:
    movsb
    inc di
    loop loop2
    add di, 60
    add si, 2
    pop cx
    loop loop1
    pop si
    pop di
    pop cx
    pop es
    pop ax
    ret
endp

newFigure proc near
    push ax
    push bx
    push cx
    push es
    push si
    push di  
                
    mov ah, 2Ch
    int 21h
    mov bh, 6
    xor ax, ax
    mov al, dl
    div bh
    mov bx, offset currentFigure
    mov [bx], ah
        
    mov currentFigureX, 5
    mov currentFigureY, 0
    mov ax, ds
    mov es, ax
    mov bx, offset currentFigure
    mov cx, [bx]
    mov al, 16
    mul cl
    mov bx, offset figureShape
    mov si, bx
    add si, ax
    mov di, offset currentFigureShape
    mov cx, 16
    loop11:
    movsb
    loop loop11
    pop di
    pop si
    pop es
    pop cx
    pop bx
    pop ax
    ret
endp

displayCurrentFigure proc near
    push ax
    push es
    push cx
    push di
    push si
    mov ax, 0B800h
    mov es, ax
    mov bx, offset currentFigureY
    mov cx, [bx]
    mov al, 80
    mul cl
    mov di, ax
    mov bx, offset currentFigureX
    mov ax, [bx]
    add ax, ax
    add ax, 5
    add di, ax
    mov si, offset currentFigureShape
    mov cx, 4
    loop21:
    push cx
    mov cx, 4
    loop22:
    cmp di, 160
    jl opaque
    cmp [si], 00h
    je opaque
    movsb
    jmp notOpaque
    opaque:
    inc si
    inc di
    notOpaque:
    inc di
    loop loop22
    add di, 72
    pop cx
    loop loop21
    pop si
    pop di
    pop cx
    pop es
    pop ax
    ret
endp

checkCollision proc near  
    push di
    push si
    push bx
    push cx  
    mov di, offset currentFigureShape
    mov si, offset playField     
    mov bx, offset currentFigureY
    mov ax, [bx]     
    mov bl, 12
    mul bl
    add si, ax
    mov bx, offset currentFigureX
    mov ax, [bx]
    cmp ax, 0FFh
    jne startCollisionCheck
        mov ax, 01h 
        pop cx
        pop bx
        pop si
        pop di
        ret
    startCollisionCheck:  
    add si, ax 
    xor bx, bx
    mov cx, 4  
    loop31:
        push cx
        mov cx, 4
    loop32:
        cmp [bx + di], 00h
        je  notCollision
        cmp [bx + si], 00h
        je  notCollision
        mov ax, 01h  
        pop cx
        pop cx
        pop bx
        pop si
        pop di
        ret 
    notCollision:    
        inc di
        inc si
        loop loop32
        pop cx     
        add si, 8 
        loop loop31
    xor ax, ax
    pop cx
    pop bx
    pop si
    pop di
    ret
endp
 
placeFigure proc near     
    push ax
    push bx
    push cx
    push es
    push si
    push di
    
    mov ax, ds
    mov es, ax
    mov si, offset currentFigureShape 
    mov di, offset playField
    mov bx, offset currentFigureY
    mov ax, [bx]
    mov bl, 12
    mul bl
    add di, ax
    mov bx, offset currentFigureX
    mov ax, [bx]
    add di, ax
   
    mov cx, 4
    loop41:
    push cx
    mov cx, 4
    loop42:
    cmp [ds + si], 00h
    je opaque1
    movsb      
    jmp notOpaque1
    opaque1:
    inc di
    inc si
    notOpaque1:
    loop loop42
    pop cx
    add di, 8
    loop loop41  
    
    pop di
    pop si
    pop es
    pop cx
    pop bx
    pop ax    
    ret 
endp 
    
rotateFigure proc near      
    push ax
    push bx
    push cx
    
    mov bx, offset currentFigureShape
    
    mov ah, [bx]  
    mov ch, ah
    mov ah, [bx + 3]
    mov [bx], ah
    mov ah, [bx + 15]
    mov [bx + 3], ah
    mov ah, [bx + 12]
    mov [bx + 15], ah
    mov [bx + 12], ch
    
    mov ah, [bx + 1]
    mov ch, ah
    mov ah, [bx + 7]
    mov [bx + 1], ah
    mov ah, [bx + 14]
    mov [bx + 7], ah
    mov ah, [bx + 8]
    mov [bx + 14], ah
    mov [bx + 8], ch
    
    mov ah, [bx + 2]
    mov ch, ah
    mov ah, [bx + 11]
    mov [bx + 2], ah
    mov ah, [bx + 13]
    mov [bx + 11], ah
    mov ah, [bx + 4]
    mov [bx + 13], ah
    mov [bx + 4], ch
    
    mov ah, [bx + 5]
    mov ch, ah
    mov ah, [bx + 6]
    mov [bx + 5], ah
    mov ah, [bx + 10]
    mov [bx + 6], ah
    mov ah, [bx + 9]
    mov [bx + 10], ah
    mov [bx + 9], ch
    
    pop cx
    pop bx
    pop ax
    
    ret    
endp        
        
checkLines proc near      
    push ax
    push bx
    push cx
    push es
    push si
    push di
    
    mov bx, offset playField
    add bx, 25
    mov cx, 20
    loop51:
    push cx 
    xor dx, dx
    mov cx, 10
    loop52:     
    cmp [bx], 00h
    je opaqueCheck
    inc dx 
    opaqueCheck: 
    inc bx
    loop loop52
    add bx, 2
    cmp dx, 10
    jl notFull
    add score, 10
    call printScore
    pop cx
    push cx
    push bx 
    mov ax, 22
    sub ax, cx
    push ax
    mov cl, 12
    mul cl
    mov bx, offset playField
    add bx, ax
    inc bx
    pop ax
    loop53:
    mov cx, 10
    loop54:     
    push ax
    mov ah, [bx - 12]
    mov [bx], ah 
    pop ax
    inc bx
    loop loop54
    sub bx, 22
    dec ax
    cmp ax, 1
    jg loop53
    
    pop bx
    notFull:
    pop cx     
    loop loop51
    pop di
    pop si
    pop es
    pop cx
    pop bx
    pop ax
    ret 
endp        

printLose proc near    
    push ds
    mov ax, 0b800h
    mov ds, ax
    mov bx, 808 
    mov [bx], 'Y'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'o'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'u'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], ' '
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'l'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'o'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 's'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'e'
    inc bx
    mov [bx], 07h
    inc bx
    mov bx, 884   
    mov [bx], 'P'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'r'
    inc bx
    mov [bx], 07h
    inc bx        
    mov [bx], 'e'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 's'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 's'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], ' '
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'E'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'n'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 't'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'e'
    inc bx
    mov [bx], 07h
    inc bx
    mov [bx], 'r'
    inc bx
    mov [bx], 07h
    inc bx 
    mov [bx], ' '
    inc bx
    mov [bx], 07h
    inc bx
    pop ds
    ret
endp

welcomeScreen proc near 
    push ax
    push bx 
    push dx
    push ds    
    mov ax, 0B800h
    mov ds, ax
    xor bx, bx
    mov cx, 1000
    loopScreenWelcome:     
    mov [bx], ' '
    inc bx
    mov [bx], 07h
    inc bx
    loop loopScreenWelcome
    pop ds
    mov ah, 9h
    mov dx, offset messageWelcome
    int 21h          
    
    waitEnterWelcome: 
    mov ah, 1
    int 16h
    jz waitEnterWelcome
    xor ah, ah
    int 16h
    cmp ah, 1Ch
    je EnterWelcome
    cmp ah, 01h
    jne waitEnterWelcome
    mov ah, 00
    mov al, 03
    int 10h
    mov ah, 4Ch
    int 21h
    EnterWelcome:
    pop dx
    pop bx
    pop ax      
    ret
endp
        
main:
    mov ax, @data
    mov ds, ax
    
    mov ah, 00
    mov al, 01
    int 10h
    call welcomeScreen   
restart:    
    mov score, 0
    mov previousTime, 0
    call initScreen
    call initPlayField
    call newFigure     
    call displayPlayField   
    call displayCurrentFigure 
    call printScore  
    mov ah, 01h
    xor cx, cx
    xor dx, dx
    int 1ah
    start:
    mov ah, 1
    int 16h
    jz noKeyPressed
    xor ah, ah
    int 16h
    cmp ah, 4Dh
    jne notD
    mov bx, offset currentFigureX
    inc [bx]
    push ax
    call checkCollision
    cmp ax, 00h
    je notColD 
    mov bx, offset currentFigureX
    dec [bx]  
    notColD: 
    pop ax
    call displayPlayField
    call displayCurrentFigure
    notD:   
    cmp ah, 4Bh
    jne notA
    mov bx, offset currentFigureX
    dec [bx]
    push ax
    call checkCollision
    cmp ax, 00h
    je notColA 
    mov bx, offset currentFigureX
    inc [bx]
    notColA: 
    pop ax
    call displayPlayField
    call displayCurrentFigure
    notA:
    cmp ah, 50h
    jne notS
    mov bx, offset currentFigureY
    inc [bx]
    push ax
    call checkCollision
    cmp ax, 00h
    je notColS 
    mov bx, offset currentFigureY
    dec [bx]
    call placeFigure
    call checkLines
    call newFigure
    call checkCollision
    cmp ax, 00h
    jne youLose
    notColS: 
    pop ax
    call displayPlayField
    call displayCurrentFigure
    notS:
    cmp ah, 48h
    jne notW
    call rotateFigure
    push ax               
    call checkCollision
    cmp ax, 00h
    je notColW       
    call rotateFigure
    call rotateFigure
    call rotateFigure
    notColW:
    pop ax
    call displayPlayField
    call displayCurrentFigure
    notW:
    cmp ah, 01h
    jne notEscape
    jmp exit
    notEscape:
    noKeyPressed: 
    mov ah, 00h
    int 1ah
    push dx
    mov ax, previousTime
    sub dx, ax
    mov ax, dx
    pop dx
    cmp ax, 9
    jl notDrop
    mov previousTime, dx
    mov bx, offset currentFigureY
    inc [bx]
    push ax
    call checkCollision
    cmp ax, 00h
    je notColDrop 
    mov bx, offset currentFigureY
    dec [bx]
    call placeFigure
    call checkLines
    call newFigure
    call checkCollision
    cmp ax, 00h
    jne youLose
    notColDrop: 
    pop ax
    call displayPlayField
    call displayCurrentFigure
    notDrop:
    notUpdate:
    jmp start
youLose:
    call printLose
waitEnter: 
    mov ah, 1
    int 16h
    jz waitEnter
    xor ah, ah
    int 16h
    cmp ah, 1Ch
    jne notEnter
    jmp restart
    notEnter:
    cmp ah, 01
    jne waitEnter:      
exit:
mov ah, 00
mov al, 03
int 10h
mov ah, 4Ch
int 21h
end main
