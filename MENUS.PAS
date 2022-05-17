{**********************************}
{*                                *}
{*    Menu unit (c) 1994          *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Menus;
interface
uses Lists,Windows;
const
  maxItems = 48;
  maxElements = 10;
  SEPARATOR : string = #7;
  mvUp    = 1;
  mvDown  = 2;
  mvLeft  = 3;
  mvRight = 4;

type
  Direction = (Vert, Horiz, Fict);
  MenuStr = string[78];
  TMenu = object
    Numb, M, Lm, X, Y : ^Byte;
    Dir : ^Direction;
    dgActive, dgCon : TWindow;
    Pos : array[1..maxItems] of ^Byte;
    ShortKeys : array[1..maxItems] of ^Char;
    Item, StatLine : array[1..maxItems] of ^MenuStr;
    IStatus : array[1..maxItems] of ^Boolean;
    constructor DefineMenu(D : Direction; Xp,Yp : Byte);
    procedure GetShortKeys; virtual;
    procedure SetItem(IStr, SStr : MenuStr; Butt : Char); virtual;
    procedure SetStatusLine; virtual;
    procedure SetStatus(N : Byte; Status : Boolean); virtual;
    procedure WriteItem(N, Xp, Yp : Byte; Status : Boolean); virtual;
    procedure WriteSeparator(N, Xp, Yp : Byte); virtual;
    procedure DrawBar; virtual;
    procedure InitMenu; virtual;
    function ActiveMenu(sbPred : TMenu) : Byte; virtual;
    destructor DestructMenu; virtual;
  end; { TMenu }

var
  Fictive : TMenu;

implementation

uses Crt,Colors,Keyboard,StrBin,Views;

function RealSize(S : string) : Byte;
var Lng,Index : Byte;
begin { RealSize }
  Lng := 0;
  for Index := 1 to Length(S) do
    begin
      if S[Index] <> '~' then Inc(Lng);
    end;
  RealSize := Lng;
end; { RealSize }

constructor TMenu.DefineMenu;
begin { TMenu.DefineMenu }
  New(Numb); Numb^ := 0;
  New(X); X^ := Xp;
  New(Y); Y^ := Yp;
  New(M); New(Lm);
  M^ := 1; Lm^ := 1;
  New(Dir); Dir^ := D;
  dgActive.Init; dgCon.Init;
end; { TMenu.DefineMenu }

procedure TMenu.GetShortKeys;
var Highlight : Boolean;
    S : string;
    I,J : Byte;
begin { TMenu.GetShortKeys }
  for I := 1 to Numb^ do
    begin
      if ShortKeys[I]^ = kbNull then
        begin { ShortKeys }
          S := Item[I]^; HighLight := False;
            for J := 1 to Length(S) do
              begin
                if S[J] = '~' then HighLight := not(HighLight);
                if HighLight and (S[J] <> '~') then
                  Inc(ShortKeys[I]^,Ord(S[J]));
             end;
        end; { ShortKeys }
    end;
end; { TMenu.GetShortKeys }

procedure TMenu.SetStatusLine;
begin { TDialog.SetStatusLine }
  Color(colStatusLine.fore,colStatusLine.Back);
  GotoXY(1,25); Write(StatLine[M^]^); ClrEol;
end; { TDialog.SetStatusLine }

procedure TMenu.SetItem;
begin { TMenu.SetItem }
  if Numb^ < maxItems then
    begin
      Inc(Numb^);
      New(Pos[Numb^]); Pos[Numb^]^ := 0;
      New(Item[Numb^]); Item[Numb^]^ := IStr;
      New(StatLine[Numb^]); StatLine[Numb^]^ := SStr;
      New(ShortKeys[Numb^]);
      if Butt <> kbNull then ShortKeys[Numb^]^ := Butt
        else ShortKeys[Numb^]^ := kbNull;
      New(IStatus[Numb^]); IStatus[Numb^]^ := True;
    end;
end; { TMenu.SetItem }

procedure TMenu.WriteItem;
var HighLight : Boolean;
    S : string;
    I : Byte;
begin { WriteItem }
  HighLight := False;
  S := Item[N]^;  GotoXY(Xp,Yp);
  for I := 1 to Length(S) do
    begin
      if S[I] = '~' then HighLight := not(HighLight);
        if HighLight then TextColor(colShortcut.Fore)
       else
        begin
          if Status then TextColor(colMenuSelected.Fore)
            else TextColor(colMenuEnable.Fore);
        end;
        if Status then TextBackground(colMenuSelected.Back)
          else TextBackground(colMenuEnable.Back);
        if not(IStatus[N]^) then TextColor(colMenuDesable.Fore);
      if S[I] <> '~' then Write(S[I]);
   end;
end; { WriteItem }

procedure TMenu.DrawBar;
begin { TMenu.DrawBar }
  FullWin;
  case Dir^ of
    Horiz : begin { Horiz }
              SetStatusLine;
              WriteItem(Lm^,X^+Pos[Lm^]^,Y^,False);
              WriteItem(M^,X^+Pos[M^]^,Y^,True);
            end; { Horiz }
     Vert : begin { Vert }
              SetStatusLine;
              WriteItem(Lm^,X^+1,Y^+Lm^,False);
              WriteItem(M^,X^+1,Y^+M^,True);
            end; { Vert }
  end; { case }
end; { TMenu.DrawBar }

procedure TMenu.InitMenu;
var S : string;
    I,J,Lng : Byte;
begin { TMenu.InitMenu }
  if Dir^ = Horiz then
    begin
      Pos[1]^ := 1;
        for I := 2 to Numb^ do
          begin
            Pos[I]^ := Pos[I-1]^;
            Inc(Pos[I]^,RealSize(Item[Pred(I)]^)+2);
           end;
        for I := 1 to Numb^ do
      WriteItem(I,X^+Pos[I]^,Y^,False);
    end;
    if Dir^ = Vert then
      begin
        Lng := RealSize(Item[1]^);
          for I := 2 to Numb^ do
            if RealSize(Item[I]^) > Lng then Lng := RealSize(Item[I]^);
          for I := 1 to Numb^ do
            begin
              if RealSize(Item[I]^) < Lng then
                for J := 1 to (Lng-RealSize(Item[I]^)) do
                  if Item[I]^ <> SEPARATOR then Item[I]^ := Item[I]^ + #32;
            end;
      end;
  GetShortKeys;
end; { TMenu.InitMenu }

procedure TMenu.WriteSeparator;
var J : Byte;
begin { TMenu.WriteSeparator }
  FullWin;
  Color(colMenuEnable.fore,colMenuEnable.Back);
  GotoXY(Xp,Yp); Write(#195);
    for J := 1 to RealSize(Item[1]^) do
      Write(#196);
  Write(#180);
end; { TMenu.WriteSeparator }

Function TMenu.ActiveMenu;
var Key : Char;
    P : Pointer;
    I,J : Byte;
begin { TMenu.ActiveMenu }
  case Dir^ of
    Horiz : begin
              While Dir^ <> Fict do
              begin { While }
                DrawBar;  Key := Get_key;
                for I := 1 to Numb^ do
                  begin
                    if (Ord(Key) = Ord(ShortKeys[I]^)) and
                       kbSpecial and IStatus[I]^ then
                      begin
                        Lm^ := M^; M^ := I; DrawBar;
                        ActiveMenu := mvDown; Exit;
                      end;
                  end;

                case Key of
                  kbLeft : begin
                             Lm^ := M^; Dec(M^);
                             if M^ < 1 then M^ := Numb^;
                           end;
                  kbRight : begin
                              Lm^ := M^; Inc(M^);
                              if M^ > Numb^ then M^ := 1;
                            end;
                  kbEsc : begin
                            ActiveMenu := mvUp; Exit;
                          end;
                  kbEnter, kbDown : begin
                                      if IStatus[M^]^ then
                                        begin
                                          ActiveMenu := mvDown; Exit;
                                        end;
                                    end;
                end; { Key }
              end; { While }
            end; { Horiz }

    Vert : begin { Vert }
             if sbPred.Dir^ = Vert then
               begin
                 FullWin;
                 dgCon.DefineWindow(sbPred.X^,sbPred.Y^,sbPred.X^+
                   RealSize(sbPred.Item[1]^)+1,sbPred.Y^+sbPred.Numb^+
                   1,'',Single,colMenuEnable.fore,colMenuEnable.Back);
                   dgCon.OpenMenuWindow; FullWin;

                  for I := 1 to sbPred.Numb^ do
                    begin
                      if sbPred.Item[I]^ <> SEPARATOR then
                        sbPred.WriteItem(I,sbPred.X^+1,sbPred.Y^+I,False)
                      else sbPred.WriteSeparator(I,sbPred.X^,sbPred.Y^+I);
                    end;
                   sbPred.DrawBar;
                end;

             dgActive.DefineWindow(X^, Y^, X^+RealSize(Item[1]^)+1,
               Y^+Numb^+1,'',Single,colMenuEnable.fore,colMenuEnable.Back);
             dgActive.OpenMenuWindow;  FullWin;

             for I := 1 to Numb^ do
               begin
                 if Item[I]^ <> SEPARATOR then
                   WriteItem(I,X^+1,Y^+I,False)
                 else WriteSeparator(I,X^,Y^+I);
               end;

             While Dir^ <> Fict do
               begin { While }
                 DrawBar;  Key := Get_key;
                   for I := 1 to Numb^ do
                     begin
                       if (Upcase(Key) = Upcase(ShortKeys[I]^)) and
                          IStatus[I]^ then
                         begin
                           DrawBar;
                           ActiveMenu := mvDown;
                           dgActive.CloseMenuWindow;
                           if sbPred.Dir^ = Vert then
                             dgCon.CloseMenuWindow;
                           Lm^ := M^; M^ := I;
                           Exit;
                         end;
                     end;
                     for I := 1 to sbPred.Numb^ do
                       begin
                         if kbSpecial then
                           if Key = sbPred.ShortKeys[I]^ then
                             begin
                               dgActive.CloseMenuWindow;
                               if sbPred.Dir^ = Vert then
                                 dgCon.CloseMenuWindow;
                               ActiveMenu := mvLeft;
                               sbPred.Lm^ := sbPred.M^; sbPred.M^ := I;
                               sbPred.DrawBar;
                               Exit;
                             end;
                       end;

             case Key Of
               kbUp : begin
                        Lm^ := M^;
                        repeat
                          Dec(M^); if M^ < 1 then M^ := Numb^;
                        Until Item[M^]^ <> SEPARATOR;
                      end;
               kbDown : begin
                          Lm^ := M^;
                          repeat
                            Inc(M^); if M^ > Numb^ then M^ := 1;
                          Until Item[M^]^ <> SEPARATOR;
                        end;
               kbLeft : begin
                          if sbPred.Dir^ = Horiz then
                            begin
                              sbPred.Lm^ := sbPred.M^;
                              Dec(sbPred.M^);
                                if sbPred.M^ < 1 then
                              sbPred.M^ := sbPred.Numb^;
                              sbPred.DrawBar;
                            end;
                            dgActive.CloseMenuWindow;
                              if sbPred.Dir^ = Vert then
                                dgCon.CloseMenuWindow;
                            ActiveMenu := mvLeft; Exit;
                        end;
               kbRight : begin
                           if sbPred.Dir^ = Horiz then
                             begin
                               sbPred.Lm^ := sbPred.M^;
                               Inc(sbPred.M^);
                               if sbPred.M^ > sbPred.Numb^ then
                                 sbPred.M^ := 1;
                               sbPred.DrawBar;
                             end;
                           dgActive.CloseMenuWindow;
                           if sbPred.Dir^ = Vert then
                             dgCon.CloseMenuWindow;
                           ActiveMenu := mvRight; Exit;
                         end;
               kbEnter : begin
                           if IStatus[M^]^ then
                             begin
                               dgActive.CloseMenuWindow;
                               if sbPred.Dir^ = Vert then
                                 dgCon.CloseMenuWindow;
                               ActiveMenu := mvDown; Exit;
                             end;
                         end;
               kbEsc : begin
                         dgActive.CloseMenuWindow;
                         if sbPred.Dir^ = Vert then
                           dgCon.CloseMenuWindow;
                         ActiveMenu := mvUp; Exit;
                       end;
                     end { case };
               end; { While }
             end; { Vert }
  end; { case }
end; { TMenu.ActiveMenu }

procedure TMenu.SetStatus;
begin { TMenu.SetStatus }
  IStatus[N]^ := Status;
end; { TMenu.SetStatus }

destructor TMenu.DestructMenu;
var I : Byte;
begin { TMenu.DestructMenu }
  for I := 1 to Numb^ do
    begin
      Dispose(Pos[I]); Dispose(Item[I]);
      Dispose(ShortKeys[I]); Dispose(StatLine[I]);
    end;
  Dispose(Numb); Dispose(X); Dispose(Y); Dispose(M); Dispose(Lm);
  dgActive.Done; dgCon.Done;
end; { TMenu.DestructMenu }

begin { Menus }
  Fictive.DefineMenu(Fict,0,0);
end. { Menus }
