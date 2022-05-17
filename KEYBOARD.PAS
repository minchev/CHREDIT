Unit Keyboard;
Interface

Type
  Proc = Procedure;
Const
  kbNull     = #0;    kbBell      = #7;
  kbBack     = #8;    kbSpace     = #32;
  kbFormFeed = #12;   kbEnter     = #13;
  kbEsc      = #27;   kbHome      = #204;
  kbEnd      = #212;  kbTab       = #9;
  kbShiftTab = #148;
  kbUp       = #205;  kbDown      = #213;
  kbPageUp   = #206;  kbPageDown  = #214;
  kbLeft     = #208;  kbRight     = #210;
  kbIns      = #215;  kbDel       = #216;
  kbCtrlLeft = #248;  kbCtrlRight = #249;

  kbF1  = #192;  kbShF1  = #217;  kbCtrlF1  = #227;  kbAltF1  = #237;
  kbF2  = #193;  kbShF2  = #218;  kbCtrlF2  = #228;  kbAltF2  = #238;
  kbF3  = #194;  kbShF3  = #219;  kbCtrlF3  = #229;  kbAltF3  = #239;
  kbF4  = #195;  kbShF4  = #220;  kbCtrlF4  = #230;  kbAltF4  = #240;
  kbF5  = #196;  kbShF5  = #221;  kbCtrlF5  = #231;  kbAltF5  = #241;
  kbF6  = #197;  kbShF6  = #222;  kbCtrlF6  = #232;  kbAltF6  = #242;
  kbF7  = #198;  kbShF7  = #223;  kbCtrlF7  = #233;  kbAltF7  = #243;
  kbF8  = #199;  kbShF8  = #224;  kbCtrlF8  = #234;  kbAltF8  = #244;
  kbF9  = #200;  kbShF9  = #225;  kbCtrlF9  = #235;  kbAltF9  = #245;
  kbF10 = #201;  kbShF10 = #226;  kbCtrlF10 = #236;  kbAltF10 = #246;

  kbAltQ = #149;  kbAltA = #163;  kbAltZ = #177;
  kbAltW = #150;  kbAltS = #164;  kbAltX = #178;
  kbAltE = #151;  kbAltD = #165;  kbAltC = #179;
  kbAltR = #152;  kbAltF = #166;  kbAltV = #180;
  kbAltT = #153;  kbAltG = #167;  kbAltB = #181;
  kbAltY = #154;  kbAltH = #168;  kbAltN = #182;
  kbAltU = #155;  kbAltJ = #169;  kbAltM = #183;
  kbAltI = #156;  kbAltK = #170;
  kbAltO = #157;  kbAltL = #171;
  kbAltP = #158;

  Offset = 133;
  strZero = '';

  Var
    kbSpecial : Boolean;
    NumLock, CapsLock, ScrollLock, InsertStatus : Boolean;
    kbFastKey : Char;
    FastProc : Proc;

  Function Get_key : Char;
  Procedure SetClock(Status : Boolean);

Implementation
Uses Crt,Dos,Colors,Transfer;
Var
  ClockStatus : Boolean;

Function Get_Key : Char;
Var Key : Char;
    CurrentTime, Convert, strHour, strMin, strSec, KeyStatus : String;
    Hour, Min, Sec, Sec100, LastHour, LastMin, LastSec : Word;
    Scr : Array[0..4000] of Byte Absolute $B800:0000;
    ShiftStatus : Byte Absolute $0000:$0417;
    J : Integer;
    I : Byte;
Begin { Get_key }
  If ClockStatus then
    Repeat
      LastHour := Hour; LastMin := Min; LastSec := Sec;
      strHour := strZero; strMin := strZero; strSec := strZero;
      CurrentTime := strZero;
        GetTime(Hour,Min,Sec,Sec100);
          If Hour < 10 THEN strHour := '0';
          If Min  < 10 THEN strMin  := '0';
          If Sec  < 10 THEN strSec  := '0';
      Str(Hour,Convert); CurrentTime := strHour + Convert + ':' + strMin;
      Str(Min,Convert);  CurrentTime := CurrentTime + Convert + ':' + strSec;
      Str(Sec,Convert);  CurrentTime := CurrentTime + Convert;
        If (LastHour <> Hour) or (LastMin <> Min) or (LastSec <> Sec) then
          Begin
            For I := 1 to Length(CurrentTime) do
              Begin
                J := 2 * (70+I);
                Scr[J] := Ord(CurrentTime[I]);
                Scr[Succ(J)] := (colClock.Back * 16) + colClock.Fore;
              End;
          End;
    Until KeyPressed;

    Str(ShiftStatus,KeyStatus);
    KeyStatus := Dec_Bin(KeyStatus);

      If KeyStatus[8]  = '1' then InsertStatus := True
        Else InsertStatus := False;
      If KeyStatus[9]  = '1' then CapsLock := True
        Else CapsLock := False;
      If KeyStatus[10] = '1' then NumLock := True
        Else NumLock := False;
      If KeyStatus[11] = '1' then ScrollLock := True
        Else ScrollLock := False;

  Repeat Key := ReadKey;
    If Key = kbNull then
      Begin
        Key := ReadKey;
          If Key > #128 then
            Key := kbNull
          Else
        Key := Chr (Ord(Key) + Offset);
        kbSpecial := True;
      End
    Else kbSpecial := False;
  Until Key <> kbNull;
  Get_key := Key;
  If (Key = kbFastKey) and kbSpecial then
    FastProc;
End; { Get_key }

Procedure SetClock;
Begin { SetClock }
  ClockStatus := Status;
End; { SetClock }

Begin { Keyboard }
  ClockStatus := False;
End. { Keyboard }
