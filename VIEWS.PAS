{**********************************}
{*                                *}
{*    Views unit (c) 1994         *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

UNIT Views;
INTERFACE

Type
  TView = OBJECT
    Constructor Init;
    Procedure InitDesktop(Ch : Char);                      virtual;
    Procedure InitStatusLine;                              virtual;
    Procedure HighMode;                                    virtual;
    Procedure LowMode;                                     virtual;
    Destructor Done;
  End; { TDialog }

  Var
    Scr : Array[0..4000] of Byte Absolute $B800:0000;

  Procedure Cursor(Up,Down : Byte);
  Procedure FullWin;
  Function VideoAddr(X,Y : Byte) : Integer;


IMPLEMENTATION
  USES Crt, Dos, Colors;

Procedure FullWin;
Begin { FullWin }
  Window(1,1,80,25);
End; { FullWin }

Function VideoAddr;
Begin { VideoAddr }
  VideoAddr := 160 * (Y - 1) + 2 * (X - 1);
End; { VideoAddr }

Constructor TView.Init;
Begin { TDialog.Init }
  Cursor(32,0);
End; { TDialog.Init }

Procedure TView.InitDesktop;
  Var
    X,Y        : Byte;
    Dest       : Integer;
Begin { TDialog.InitDesktop }
  For Y := 2 to 24 do
    For X := 1 to 80 do
      Begin
        Dest := 160 * (Y-1) + 2 * (X-1);
        Scr[Dest] := Ord(Ch);
        Scr[Dest+1] := 16 * colDesktop.Back + colDesktop.Fore;
      End;
End; { TDialog.InitDesktop }

Procedure TView.InitStatusLine;
Begin { TDialog.InitStatusLine }
  Color(colStatusLine.Fore,colStatusLine.Back);
  GotoXY(1,1); ClrEol;
  GotoXY(1,25); ClrEol;
End; { TDialog.InitStatusLine }

Procedure TView.HighMode;
  Var Regs : Registers;
Begin { TDialog.HighMode }
  Regs.AX := $1003;
  Regs.BL := $00;
    Intr($10,Regs);
End { TDialog.HighMode };

Procedure TView.LowMode;
  Var Regs : Registers;
Begin { TDialog.LowMode }
  Regs.AX := $1003;
  Regs.BL := $01;
    Intr($10,Regs);
End { TDialog.LowMode };

Procedure Cursor;
  Var Regs : Registers;
Begin { Cursor }
  Regs.AH := 01;
  Regs.CH := Up;
  Regs.CL := Down;
    Intr($10,Regs);
End; { Cursor }

Destructor TView.Done;
Begin { TDialog.Done }
End; { TDialog.Done }

Begin { Desktop }
  Cursor(32,0);
End. { Desktop }