; Autohotkey Capslock Remapping
; (C) 2020 Gordon Engelke

#Persistent
SetCapsLockState, AlwaysOff

; Map Escape key to CapsLock just for convenience
Capslock::Escape

Capslock & c::MsgBox, Capslock Test

; Swap y and z keys for German keyboard compatibility
z::y
y::z

; Map special keys for German keyboard compatibility
#If, GetKeyState("CapsLock", "P")
; a::SendInput {ASC 0228}         ;Capslock + u = ä
; o::SendInput {ASC 0246}         ;Capslock + u = ö
; u::SendInput {ASC 0252}         ;Capslock + u = ü
; s::Send, {ASC 0223}             ;CapsLock + s = ß
e::Send, {ASC 0128}		;CapsLock + e = €
]::Send, {ASC 0126}             ;Capslock + ] = ~
~::Send, {ASC 0126}             ;Capslock + ~ = ~
`::Send, {ASC 0096}             ;Capslock + ` = `
=::Send, {ASC 0061}             ;Capslock + = = `
"::Send, {ASC 0032}             ;Capslock + " = "
'::Send, {ASC 0228}             ;Capslock + ' = ä
`;::Send, {ASC 0246}            ;Capslock + ; = ö
[::Send, {ASC 0252}             ;Capslock + [ = ü
s::Send, {ASC 0223}             ;CapsLock + s = ß
+'::Send, {ASC 0196}            ;Capslock + Shift + ' = Ä
+`;::Send, {ASC 0214}           ;Capslock + Shift + ; = Ö
+[::Send, {ASC 0220}            ;Capslock + Shift + [ = Ü
+s::Send, {ASC 0223}            ;Capslock + Shift + s = ß
+=::Send, {ASC 0061}            ;Capslock + Shift + = = 
#If

; Map Copy & Paste from Ctrl to Command/Win for MacOS compatibility
LWin & a::Send, ^a
LWin & c::Send, ^c
LWin & v::Send, ^v
LWin & x::Send, ^x
LWin & f::Send, ^f
LWin & s::Send, ^s

; $1::SendRaw !
; $!::SendRaw 1
; $2::SendRaw @
; $@::SendRaw 2
; $3::SendRaw #
; $#::SendRaw 3
; $4::SendRaw $
; $$::SendRaw 4
; $5::SendRaw `%
; $%::SendRaw 5
; $6::SendRaw ^
; $^::SendRaw 6
; $7::SendRaw &
; $&::SendRaw 7
; $8::SendRaw *
; $*::SendRaw 8
; $9::SendRaw (
; $(::SendRaw 9
; $0::SendRaw )
; $)::SendRaw 0
