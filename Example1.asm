TITLE Calculator
INCLUDE Irvine32.inc
.data?
     num1 dword ?
     num2 dword ?
     op byte ?
.data
     enterNum byte 13,10,"Enter a number: ",0
     enterOp byte "Enter the operator: ",0
.code
main PROC
     mov edx, offset enterNum
     call WriteString
     call ReadInt
     mov num1, eax

     mov edx, offset enterOp
     call WriteString
     call ReadChar
     mov op, al
     call WriteChar

     mov edx, offset enterNum
     call WriteString
     call ReadInt
     mov num2, eax

     mov eax, num1
     add eax, num2
     call WriteInt
exit
main ENDP
END main