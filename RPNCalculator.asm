TITLE RPNCalculator
INCLUDE Irvine32.inc

.const
     enterNum byte "Please enter your equation.",13,10,
     "Rules:",13,10,
     "- Insert spaces after each whole number",13,10,
     "- Don't insert spaces after arithmetic signs",13,10,
     "- Press enter when you are done",13,10,0
     equals byte " = ",0

.data
     count byte 0

.data?
     startPointer DWord ? ;keep track of the beginning of the stack
     spacePointer DWord ? ;keep track of the last space entered for multi-digit numbers
     num SDWord ? ;temp variable for calculations
     save DWORD ?
     saveEax SDWORD ?
     saveEbx SDWORD ?
     saveEcx SDWORD ?
     saveEdx SDWORD ?
     
.code
Main PROC
     MOV edx, offset enterNum
     CALL WriteString

     mov startPointer, esp
     mov spacePointer, esp

     getEquation:
          MOV num, 0

          CALL ReadChar

          CMP al,13 ;Enter key pressed
          JE enterKey

          CALL writeChar

          CMP al,32 ;Space bar pressed
          JE spaceBar

          CMP al,'+'
          JE plus

          CMP al,'-'
          JE minus

          MOV ah, 0
          SUB al,30h
          PUSH eax
     JMP getEquation
     
     spaceBar:
          CALL combineNum
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

     enterKey:
          MOV edx, offset equals
          CALL WriteString

          POP eax
          CALL ConvertDecToHex

          output:
               POP eax
               add eax, 30h
               CALL writeChar
               CMP esp, startPointer
               JE done
          JMP output
     JMP enterKey

     done:
          CALL CRLF
          EXIT
Main ENDP     

;------------------------------------
CombineNum PROC
;Combines multiple single digit numbers into a multi-digit number
;Recieves: stack, spacepointer
;Returns: stack
;------------------------------------
     POP edx ;save address

     mov eax, spacePointer
     sub eax, esp
     CMP eax, 4
     JE skip

     mov eax, 0
     mov ecx, -1

     popNum:
          POP ebx
          ROR eax, 4
          MOV al, bl
          INC ecx
     CMP esp, spacePointer
     JNE popNum

     format:
          ROL eax, 4
     LOOP format

     PUSH eax
     MOV spacePointer, esp
          
     skip:
     PUSH edx ;return address
     RET
CombineNum ENDP

;------------------------------------
ConvertDecToHex PROC
;Converts a decimal to hexidecimal
;Recieves EAX
;Returns: EAX
;------------------------------------
     POP save ;save address

     mov spacepointer, esp
     mov ebx, 16
     divide:
          CDQ
          IDIV ebx
          PUSH edx
          CMP eax, 0
          JE convertEnd
          JMP divide

     convertEnd:
          PUSH save ;return address
          RET
ConvertDecToHex ENDP

;------------------------------------
startCalc PROC
;Pops two numbers off the stack
;Recieves: Stack
;Returns: EAX
;------------------------------------
     POP ecx ;save address of where startCalc was called

     POP eax
     MOV num, eax
     POP eax

     PUSH ecx ;return address so startCalc can go back to where it was called from
     RET
startCalc ENDP

;------------------------------------
saveAddresses PROC
;------------------------------------
     MOV saveEax, eax
     MOV saveEbx, ebx
     MOV saveEcx, ecx
     MOV saveEdx, edx
     RET
saveAddresses ENDP

;------------------------------------
restoreAddresses PROC
;------------------------------------
     MOV eax, saveEax
     MOV ebx, saveEbx
     MOV ecx, saveEcx
     MOV edx, saveEdx
     RET
restoreAddresses ENDP

END Main