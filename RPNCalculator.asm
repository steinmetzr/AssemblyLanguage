TITLE RPNCalculator
INCLUDE Irvine32.inc
.data
     enterNum byte "Enter your equation: ",13,10,0
     equals byte " = ",0
.data?
     num SDWord ?
     address SDWord ?
.code
main PROC

MOV edx, offset enterNum
CALL WriteString
mov ebx, esp

getEquation:
     CALL ReadChar
     MOV ah, 0

     CMP al,13
     JE output

     CALL writeChar

     CMP al,'+'
     JE plus

     CMP al,'-'
     JE minus

     SUB al,30h
     PUSH eax

     JMP getEquation

plus:
     CALL startCalc
     ADD eax, num
     PUSH eax
     JMP getEquation

minus:
     CALL startCalc
     SUB eax, num
     PUSH eax
     JMP getEquation

output:
     MOV edx, offset equals
     CALL WriteString

     POP eax
     CALL writeInt
     CMP esp, ebx
     JE done
     JMP output
     
done:
     CALL Crlf
     EXIT
main ENDP

;------------------------------------
;Pops two numbers off the stack
;Recieves: stack
;Returns: eax
;------------------------------------
startCalc PROC
     POP address

     POP eax
     MOV num, eax
     POP eax

     PUSH address
     RET
startCalc ENDP

END main