{**********************************}
{*                                *}
{*    Windows unit (c) 1994       *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

UNIT Windows;
INTERFACE

Type
  BoxType = (NoBox, Single, Double);
  TTitle = String[80];
  TCurs = Record
           X,Y : Byte;
         End;
  TWindow = OBJECT
    Saver :       ^Pointer;
    X1,Y1,X2,Y2 : ^Byte;
    Title :       ^TTitle;
    Border :      ^BoxType;
    Fore, Back :  ^Byte;
    Curs :        ^TCurs;
    Constructor Init;
    Procedure TestSize; virtual;
    Procedure DefineWindow(_X1,_Y1,_X2,_Y2 : Byte; _Title : String;
              _Border : BoxType; _Fore, _Back : Byte); virtual;
    Procedure OpenWindow; virtual;
    Procedure CloseWindow; virtual;
    Procedure OpenMenuWindow; virtual;
    Procedure CloseMenuWindow; virtual;
    Procedure MoveSizeWindow; virtual;
    Procedure SaveBar(_X1,_Y1,_X2,_Y2 : Byte); virtual;
    Procedure LoadBar(_X1,_Y1,_X2,_Y2 : Byte); virtual;
    Procedure Shadow; virtual;
    Destructor Done; virtual;
  End; { TWindow }

  Procedure DrawBox(X1,Y1,X2,Y2 : Byte; Box : BoxType);

IMPLEMENTATION
Uses Crt, Colors, Crt_drv, Keyboard, Views;
Var
  Dest : Integer;
  Index : Byte;

Procedure DrawBox;
  Type Box_rec = Record
                   UL, UR, LL, LR, Horiz, Vert : Char;
                 End;
  Const Boxes : Array[Single..Double] of Box_rec =
          ((UL : 'Ú'; UR : '¿'; LL : 'À';
            LR : 'Ù'; Horiz : 'Ä'; Vert : '³'),
           (UL : 'É'; UR : '»'; LL : 'È';
            LR : '¼'; Horiz : 'Í'; Vert : 'º'));
Begin { DrawBox }
  Dest := VideoAddr(X1,Y1);
  Scr[Dest] := Ord(Boxes[Box].UL); Scr[Dest+1] := TextAttr;
  For Index := (X1+1) to (X2-1) do
    Begin
      Dest := VideoAddr(Index,Y1);
      Scr[Dest] := Ord(Boxes[Box].Horiz); Scr[Dest+1] := TextAttr;
    End;
  Dest := VideoAddr(X2,Y1);
  Scr[Dest] := Ord(Boxes[Box].UR); Scr[Dest+1] := TextAttr;
  For Index := (Y1+1) to (Y2-1) do
    Begin
      Dest := VideoAddr(X1,Index);
      Scr[Dest] := Ord(Boxes[Box].Vert); Scr[Dest+1] := TextAttr;
      Dest := VideoAddr(X2,Index);
      Scr[Dest] := Ord(Boxes[Box].Vert); Scr[Dest+1] := TextAttr;
    End;
  Dest := VideoAddr(X1,Y2);
  Scr[Dest] := Ord(Boxes[Box].LL); Scr[Dest+1] := TextAttr;
  For Index := (X1+1) to (X2-1) do
    Begin
      Dest := VideoAddr(Index,Y2);
      Scr[Dest] := Ord(Boxes[Box].Horiz); Scr[Dest+1] := TextAttr;
    End;
  Dest := VideoAddr(X2,Y2);
  Scr[Dest] := Ord(Boxes[Box].LR); Scr[Dest+1] := TextAttr;
End; { DrawBox }

Procedure TWindow.TestSize;
Begin { TWindow.TestSize }
  If X1^ < 1 then X1^ := 1;
    If Y1^ < 2 then Y1^ := 2;
  If X2^ > 80 then X2^ := 80;
    If Y2^ > 24 then Y2^ := 24;
  If Length(Title^) > (X2^-X1^-1) then
    Title^ := Copy(Title^,1,X2^-X1^-1);
End; { TWindow.TestSize }

Procedure TWindow.Shadow;
  Var Lng : Byte;
Begin { TWindow.Shadow }
  Lng := 0;
    For Index := (Y1^+1) to Y2^ do
      Begin
          If (X2^ < 80) and (X2^ <> 79) then begin
            Lng := 2;
            Dest := 160 * (Index-1) + 2 * (X2^+1);
            Scr[Dest+1] := $08; end;
          If X2^ <= 79 then begin
            If X2^ < 79 then Lng := 2 else Lng := 1;
            Dest := 160 * (Index-1) + 2 * X2^;
            Scr[Dest+1] := $08; end;
      End;
 If Y2^ < 24 then
    For Index := (X1^+2) to (X2^+Lng) do
      Begin
        Dest := 160 * Y2^ + 2 * (Index-1);
        Scr[Dest+1] := $08;
      End;
End; { TWindow.Shadow }

Constructor TWindow.Init;
Begin { TWindow.Init }
  New(Saver);
  New(X1); New(Y1); New(X2); New(Y2);
  New(Title); New(Border);
  New(Fore); New(Back);
  New(Curs);
End; { TWindow.Init }

Procedure TWindow.SaveBar;
Begin { TWindow.SaveBar }
  Curs^.X := WhereX; Curs^.Y := WhereY;
  Allocate_scr(_Y1,_X1,(_Y2-_Y1)+1,(_X2-_X1)+1,Saver^);
End; { TWindow.SaveBar }

Procedure TWindow.LoadBar;
Begin { TWindow.LoadBar }
  Load_scr(_Y1,_X1,(_Y2-_Y1)+1,(_X2-_X1)+1,Saver^,True);
  Release_mem((_Y2-_Y1)+1,(_X2-_X1)+1,Saver^);
  GotoXY(Curs^.X,Curs^.Y);
End; { TWindow.LoadBar }

Procedure TWindow.DefineWindow;
Begin { TWindow.DefineWindow }
  X1^ := _X1; Y1^ := _Y1; X2^ := _X2; Y2^ := _Y2;
  Title^ := _Title;
  Border^ := _Border;
  Fore^ := _Fore; Back^ := _Back;
    TestSize;
End; { TWindow.DefineWindow }

Procedure TWindow.OpenWindow;
  Var Source : Byte;
Begin { TWindow.OpenWindow }
  SaveBar(X1^,Y1^,X2^+2,Y2^+1);
    Source := (X1^+((X2^-X1^+1) - Length(Title^)) div 2);
    Case Border^ of
      NoBox : Begin
                Color(White,Blue); GotoXY(X1^,Y1^);
                  For Index := X1^ to X2^ do Write(#32);
                    GotoXY(Source,Y1^); Write(Title^);
                      If X2^-X1^ > 5 then
                        Begin
                          Color(White,Black);
                          GotoXY(X1^,Y1^); Write(#219#02);
                        End;
                 Window(X1^,Y1^+1,X2^,Y2^); Color(Black,LightGray);
              End;
      Single, Double : Begin
                Color(Fore^,Back^);
                DrawBox(X1^,Y1^,X2^,Y2^,Border^);
                  GotoXY(Source,Y1^); Write(Title^);
                Window(X1^+1,Y1^+1,X2^-1,Y2^-1);
              End;
    End; { Case }
  ClrScr; Shadow;
End; { TWindow.OpenWindow }

Procedure TWindow.CloseWindow;
Begin { TWindow.CloseWindows }
  LoadBar(X1^,Y1^,X2^+2,Y2^+1);
End; { TWindow.CloseWindows }

Procedure TWindow.OpenMenuWindow;
  Var Source : Byte;
      winShadow : TWindow;
Begin { TWindow.OpenMenuWindow }
  SaveBar(X1^-1,Y1^,X2^+3,Y2^+1);
  Source := (X1^+((X2^-X1^+1) - Length(Title^)) div 2);
      winShadow.Init;
        winShadow.DefineWindow(X1^-1,Y1^,X2^+1,Y2^,'',NoBox,0,0);
      winShadow.Shadow; winShadow.Done;
    Color(Fore^,Back^);
  For Index := Y1^ to Y2^ do
    Begin
      GotoXY(X1^-1,Index); Write(#32);
      GotoXY(X2^+1,Index); Write(#32);
    End;
  DrawBox(X1^,Y1^,X2^,Y2^,Border^);
    GotoXY(Source,Y1^); Write(Title^);
      Window(X1^+1,Y1^+1,X2^-1,Y2^-1);  ClrScr;
End; { TWindow.OpenMenuWindow }

Procedure TWindow.CloseMenuWindow;
Begin { TWindow.CloseMenuWindow }
  LoadBar(X1^-1,Y1^,X2^+3,Y2^+1);
End; { TWindow.CloseMenuWindow }

Procedure TWindow.MoveSizeWindow;
  Var _x1,_y1,_x2,_y2 : Byte;
      Key             : Char;
      winMS, Last     : TWindow;
      Source          : Byte;
Label GetKey;
Begin { TWindow.MoveSizeWindow }
  _x1 := X1^; _y1 := Y1^; _x2 := X2^; _y2 := Y2^;
  Color(Yellow,Green);
    FullWin;
    Last.Init; Last.DefineWindow(_x1,_y1,_x2,_y2,Title^,Border^,Fore^,Back^);
    Last.SaveBar(_x1,_y1,_x2,_y2);
      winMS.Init;
      winMS.DefineWindow(_x1,_y1,_x2,_y2,'',Single,0,0);
      winMS.SaveBar(_x1,_y1,_x2,_y2);
      Color(Yellow,Green);
        DrawBox(_x1,_y1,_x2,_y2,Single);

GetKey:   Case Key of
            kbEsc : Begin
                      winMS.LoadBar(winMS.X1^,winMS.Y1^,winMS.X2^,winMS.Y2^);
                      winMS.Done;
                      Last.LoadBar(Last.X1^,Last.Y1^,Last.X2^,Last.Y2^);
                      Last.Done;
                      CloseWindow;
                      OpenWindow;
                      Exit;
                    End;
            kbUp  : Begin
                        Dec(_y1); Dec(_y2);
                          If _y1 < 2 then Begin
                        _y1 := 2; Inc(_y2); End;
                      End;
            kbDown  : Begin
                        Inc(_y1); Inc(_y2);
                          If _y2 > 24 then Begin
                        Dec(_y1); _y2 := 24; End;
                      End;
            kbRight : Begin
                        Inc(_x1); Inc(_x2);
                          If _x2 > 80 then Begin
                        Dec(_x1); _x2 := 80; End;
                      End;
            kbF5    : Begin
                        _x1 := 1; _y1 := 2; _x2 := 80; _y2 := 24;
                      End;
            kbLeft  : Begin
                        Dec(_x1); Dec(_x2);
                          If _x1 < 1 then Begin
                        _x1 := 1; Inc(_x2); End;
                      End;
                '8' : Begin
                        Dec(_y2); If _y2 < _y1 + 2
                          then _y2 := _y1 + 2;
                      End;
                '2' : Begin
                        Inc(_y2); If _y2 > 24 then
                          _y2 := 24;
                      End;
                '4' : Begin
                        Dec(_x2);
                        If (_x2 < _x1 + 2) or ((_x2-_x1-1) < Length(Title^))
                          then Inc(_x2);
                      End;
                '6' : Begin
                        Inc(_x2); If _x2 > 80 then
                          _x2 := 80;
                      End;
            kbEnter : Begin
                        winMS.LoadBar(winMS.X1^,winMS.Y1^,
                                                    winMS.X2^,winMS.Y2^);
                        winMS.Done;
                          If (_x2-_x1) <= (Last.X2^-Last.X1^) then
                            Last.X2^ := _x2
                          Else Last.X2^ := _x1+Last.X2^-Last.X1^;
                          If (_y2-_y1) <= (Last.Y2^-Last.Y1^) then
                            Last.Y2^ := _y2
                          Else Last.Y2^ := _y1+Last.Y2^-Last.Y1^;
                            Last.X1^ := _x1; Last.Y1^ := _y1;

                        CloseWindow;
                        X1^ := _x1; Y1^ := _y1; X2^ := _x2; Y2^ := _y2;
                        DefineWindow(X1^,Y1^,X2^,Y2^,Title^,Border^,
                                                Fore^,Back^);

                        OpenWindow;
                        FullWin;
                        Last.Done;
                        Exit;
                      End;
          End;
        winMS.LoadBar(winMS.X1^,winMS.Y1^,winMS.X2^,winMS.Y2^);
        winMS.Done; winMS.Init;
        winMS.DefineWindow(_x1,_y1,_x2,_y2,Title^,Border^,Fore^,Back^);
        winMS.SaveBar(_x1,_y1,_x2,_y2);
        DrawBox(_x1,_y1,_x2,_y2,Single);
         Source := (_x1+((_x2-_x1+1) - Length(Title^)) div 2);
         GotoXY(Source,_y1); Write(Title^);
  Key := Get_key;
Goto GetKey;
End; { TWindow.MoveSizeWindow }

Destructor TWindow.Done;
Begin { TWindow.Done }
  Dispose(Saver);
  Dispose(X1); Dispose(Y1); Dispose(X2); Dispose(Y2);
  Dispose(Title); Dispose(Border);
  Dispose(Fore); Dispose(Back);
  Dispose(Curs);
End; { TWindow.Done }

End. { Windows }
