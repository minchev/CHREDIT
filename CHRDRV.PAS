{$M $400,0,2}
{$S-}
uses Dos;
const LeftShift  = $01;
      RightShift = $02;

var KbdIntVec : procedure;
    ShiftStatus : Byte absolute $0000:$0417;
    Font : array[0..255,1..16] of Byte;
    Flag, Change : Boolean;

procedure SetFont(Status : Boolean);
var Regs : Registers;
    I,J : Byte;
begin { SetFont }
  if Flag then
    begin
      Regs.AX := $1100;
      Regs.CX := 256;
      Regs.BP := Ofs(Font);
      Regs.ES := Seg(Font);
      Regs.DX := 0;
      Regs.BL := 0;
      Regs.BH := $10;
        Intr($10,Regs);
    end
  else
    begin
      Regs.AX := $1130;
      Regs.BH := $06;
        Intr($10,Regs);
      Regs.AX := $1100;
      Regs.CX := 256;
      Regs.DX := 0;
      Regs.BL := 0;
      Regs.BH := $10;
        Intr($10,Regs);
    end;
end; { SetFont }

procedure Quit;
begin { Quit }
  WriteLn(' Usage: CHRDRV font.CHR');
  Halt(1);
end; { Quit }

procedure ReadFonts;
var F : File of Byte;
    I, J : Byte;
begin { ReadFonts }
{$I-}
  Assign(F,ParamStr(1));
  Reset(F);
    if IOResult <> 0 then Quit;
  for I := 0 to 255 do
    for J := 1 to 16 do
      begin
        Read(F,Font[I,J]);
        if IOResult <> 0 then Quit;
      end;
   Close(F);
    if IOResult <> 0 then Quit;
{$I+}
end; { ReadFonts }

{$F+}
procedure ChangeFont; interrupt;
begin { ChangeFont }
  if (ShiftStatus and LeftShift <> 0) and
     (ShiftStatus and RightShift <> 0) then
    begin
      Flag := not(Flag);
      SetFont(Flag);
    end;
  inline($9C);
  KbdIntVec;
end; { CahngeFont }
{$F-}

begin { ChrDrv }
  WriteLn('Character Driver  Version 1.0  Copyright (c) 1995 Momchil Hristov');
    if ParamCount < 1 then Quit;
    ReadFonts;
  GetIntVec($09,@KbdIntVec);
  SetIntVec($09,Addr(ChangeFont));
  Keep(0);
end. { ChrDrv }
