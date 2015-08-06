TITLE RPNCalculator
INCLUDE Irvine32.inc
include Windows.inc

.const
     enterNum byte "Enter your equation: ",13,10,0

     AppLoadMsgTitle BYTE "Application Loaded",0
     AppLoadMsgText  BYTE "This window displays when the WM_CREATE "
	                 BYTE "message is received",0

     PopupTitle BYTE "Popup Window",0
     PopupText  BYTE "This window was activated by a "
	            BYTE "WM_LBUTTONDOWN message",0

     GreetTitle BYTE "Main Window Active",0
     GreetText  BYTE "This window is shown immediately after "
	            BYTE "CreateWindow and UpdateWindow are called.",0

     CloseMsg   BYTE "WM_CLOSE message received",0

     ErrorTitle  BYTE "Error",0
     WindowName  BYTE "ASM Windows App",0
     className   BYTE "ASMWin",0

.data
     ; Define the Application's Window class structure.
     MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL, \
	     COLOR_WINDOW,NULL,className>

     msg	      MSGStruct <>
     winRect   RECT <>

.data?
     startPointer DWord ? ;keep track of the beginning of the stack
     spacePointer DWord ? ;keep track of the last space entered for multi-digit numbers

     CommandLine DWORD ?
     hMainWnd  DWORD ?
     hInstance DWORD ?

.code
COMMENT !
WinMain PROC
     ; Get a handle to the current process.
	     INVOKE GetModuleHandle, NULL
	     mov hInstance, eax
          ;INVOKE GetCommandLine
          ;mov CommandLine,eax
	     mov MainWin.hInstance, eax

     ; Load the program's icon and cursor.
	     INVOKE LoadIcon, NULL, IDI_APPLICATION
	     mov MainWin.hIcon, eax
	     INVOKE LoadCursor, NULL, IDC_ARROW
	     mov MainWin.hCursor, eax

     ; Register the window class.
	     INVOKE RegisterClass, ADDR MainWin
	     .IF eax == 0
	       call ErrorHandler
	       jmp Exit_Program
	     .ENDIF

     ; Create the application's main window.
     ; Returns a handle to the main window in EAX.
	     INVOKE CreateWindowEx, 0, ADDR className,
	       ADDR WindowName,MAIN_WINDOW_STYLE,
	       CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
	       CW_USEDEFAULT,NULL,NULL,hInstance,NULL
	     mov hMainWnd,eax

     ; If CreateWindowEx failed, display a message & exit.
	     .IF eax == 0
	       call ErrorHandler
	       jmp  Exit_Program
	     .ENDIF

     ; Show and draw the window.
	     INVOKE ShowWindow, hMainWnd, SW_SHOW
	     INVOKE UpdateWindow, hMainWnd

     ;Begin the program's message-handling loop.
     Message_Loop:
	     ; Get next message from the queue.
	     INVOKE GetMessage, ADDR msg, NULL,NULL,NULL

	     ; Quit if no more messages.
	     .IF eax == 0
	       jmp Exit_Program
	     .ENDIF

	     ; Relay the message to the program's WinProc.
	     INVOKE DispatchMessage, ADDR msg
         jmp Message_Loop
     
     Exit_Program:
          EXIT
WinMain ENDP
!

Main PROC
.data
     equals byte " = ",0
     count byte 0

.data?
     num SDWord ? ;temp variable for calculations

.code
     MOV edx, offset enterNum
     CALL WriteString

     mov startPointer, esp
     mov spacePointer, esp

     getEquation:
          MOV num, 0

          CALL ReadChar
          MOV ah, 0

          CMP al,13
          JE output

          CALL writeChar

          ;CMP al,32
          ;JE combine

          CMP al,'+'
          JE plus

          CMP al,'-'
          JE minus

          SUB al,30h
          PUSH eax

          JMP getEquation
     
     COMMENT !
     combine:
          POP ebx
          shl eax, 1 
          mov al, bl
          add count, 1
          CMP esp, spacePointer
          JNE combine

          PUSH eax
          MOV spacePointer, esp
          JMP getEquation
          !

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
          CMP esp, startPointer
          JE done
          JMP output

     done:
          ret
Main ENDP

;------------------------------------
startCalc PROC
;Pops two numbers off the stack
;Recieves: stack
;Returns: eax
;------------------------------------
     POP ecx ;save address of where startCalc was called

     POP eax
     MOV num, eax
     POP eax

     PUSH ecx ;return address so startCalc can go back to where it was called from
     RET
startCalc ENDP

;---------------------------------------------------
ErrorHandler PROC
; Display the appropriate system error message.
;---------------------------------------------------
.data
pErrorMsg  DWORD ?		; ptr to error message
messageID  DWORD ?
.code
	INVOKE GetLastError	; Returns message ID in EAX
	mov messageID,eax

	; Get the corresponding message string.
	INVOKE FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + \
	  FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
	  ADDR pErrorMsg,NULL,NULL

	; Display the error message.
	INVOKE MessageBox,NULL, pErrorMsg, ADDR ErrorTitle,
	  MB_ICONERROR+MB_OK

	; Free the error message string.
	INVOKE LocalFree, pErrorMsg
	ret
ErrorHandler ENDP

;-----------------------------------------------------
WinProc PROC,
	hWnd:DWORD, localMsg:DWORD, wParam:DWORD, lParam:DWORD
; The application's message handler, which handles
; application-specific messages. All other messages
; are forwarded to the default Windows message
; handler.
;-----------------------------------------------------
	mov eax, localMsg

	.IF eax == WM_CREATE		; create window?
	  ;INVOKE MessageBox, hWnd, ADDR AppLoadMsgText,
	    ;ADDR AppLoadMsgTitle, MB_OK
	  ;jmp WinProcExit
	.ELSEIF eax == WM_CLOSE		; close window?
	  INVOKE PostQuitMessage,0
	  jmp WinProcExit
	.ELSE		; other message?
	  INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
	  jmp WinProcExit
	.ENDIF

WinProcExit:
	ret
WinProc ENDP

END Main
;END WinMain