TITLE Calculator
INCLUDE Irvine32.inc
.data
     num Byte 0
     enterNum byte "Enter your equation: ",13,10,0
     equals byte "=",0
.code
main PROC

MOV edx, offset enterNum
CALL WriteString
mov ebx, esp

getEquation:
     CALL ReadChar
     CMP al,13
     JE output

     CALL WriteChar

     CMP al,'+'
     JE plus

     CMP al,'-'
     JE minus

     ;CMP al,'*'
     ;JE multiply

     sub al,30h
     PUSH eax

     JMP getEquation

plus:
     POP eax
     add al, num
     mov num, al
     CMP esp, ebx
     JE save
     JMP plus

minus:
     POP eax
     sub al, num
     mov num, al
     CMP esp, ebx
     JE save
     JMP minus

save:
     mov al, num
     PUSH eax
     JMP getEquation

output:
     MOV edx, offset equals
     CALL WriteString

     POP eax
     add al,30h
     CALL WriteChar
     CMP esp, ebx
     JE done
     JMP output
     
done:
     CALL Crlf
     exit
main ENDP
END main