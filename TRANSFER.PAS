{****************************************}
{*                                      *}
{*  Tranfer 1.0                         *}
{*  Copyright (C) by Momchil Hristov    *}
{*                                      *}
{****************************************}

UNIT Transfer;
INTERFACE

  Function Dec_Hex(DecStr : String) : String;
  Function Dec_Oct(DecStr : String) : String;
  Function Dec_Bin(DecStr : String) : String;
  Function Bin_Dec(BinStr : String) : String;

IMPLEMENTATION

   Uses Math;
    Var S     : String;
        N,C,T : Longint;
        Code  : Integer;

Function Dec_Hex;
Begin { Dec_Hex }
  Val(DecStr,N,Code); S := '';
    Repeat
      C := N mod 16;
      N := N div 16;
        Case C of
           0..9  : S := S + Chr(48 + C);
          10..15 : S := S + Chr(65 + C - 10);
        End; { Case }
    Until (N = 0) and (Length(S) = 4);
      DecStr := S; S := '';
        For N := Length(DecStr) downto 1 do
          S := S + DecStr[N];
    If Code <> 0 then S := 'Error';
  Dec_Hex := S;
End; { Dec_Hex }

Function Dec_Oct;
Begin { Dec_Oct }
  Val(DecStr,N,Code); S := '';
    Repeat
      C := N mod 8;
      N := N div 8;
        S := S + Chr(48 + C);
    Until (N = 0) and (Length(S) = 5);
      DecStr := S; S := '';
        For N := Length(DecStr) downto 1 do
          S := S + DecStr[N];
    If Code <> 0 then S := 'Error';
  Dec_Oct := S;
End; { Dec_Oct }

Function Dec_Bin;
Begin { Dec_Bin }
  Val(DecStr,N,Code); S := '';
    Repeat
      C := N mod 2;
      N := N div 2;
        If C = 0 then S := S + '0' Else S := S + '1';
    Until (N = 0) and (Length(S) = 15);
      DecStr := S; S := '';
        For N := Length(DecStr) downto 1 do
          S := S + DecStr[N];
    If Code <> 0 then S := 'Error';
  Dec_Bin := S;
End; { Dec_Bin }

Function Bin_Dec;
Begin { Bin_Dec }
  S := ''; N := 0;
  For T := Length(BinStr) downto 1 do
      If BinStr[T] = '1' Then
         Inc(N,Power(2,Length(BinStr)-T));
    Str(N,S);
 Bin_Dec := S;
End; { Bin_Dec }
End. { Transfer }