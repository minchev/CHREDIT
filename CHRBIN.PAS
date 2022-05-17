unit ChrBin;
interface
const Noname = 'NONAME.CHR';

  procedure NewFile_Generator;
  procedure NewFile_Empty;
  procedure OpenFont;
  procedure SaveFont;
  procedure SaveFontAs;
  procedure ExportFontPas;
  procedure ExportFontC;

  function GetNChar : Integer;

  procedure EditCharacter(N : Byte);
  procedure ViewChar(N : Byte);
  procedure ViewFont;

  procedure SetROMFont;

  var Font : array[0..255,1..16] of Byte;
      FileName, ExportFile : string;
      NewFile, FileChanged : Boolean;

implementation
  uses Crt, Dos, StrBin, Colors, Keyboard, Views, Transfer, Windows,
       Strings, Menus, Errors, Dialogs;
  var dgMessage : TWindow;
      Buff : array[1..1024] of Byte;
      BuffCount : Word;

procedure EditCharacter;
var I,J,K : Byte;
    Code : Integer;
    Key : Char;
    Regs : Registers;
    dgEdit : TWindow;
    VCh : array [1..8,1..16] of Boolean;
    Ch,Clip : array[1..16] of Byte;
    S : string;
begin
  dgEdit.Init;
  dgEdit.DefineWindow(29,3,51,23,' Edit Character ',
    Double,colDialog.Fore,colDialog.Back);
  dgEdit.OpenWindow;

  Color(colNormalText.Fore,colNormalText.Back);
  FullWin;
    GotoXY(dgEdit.X1^+11,dgEdit.Y2^-1);
    Write('ASCII: ');
      if N < 10 then Write('0');
      if N < 100 then Write('0');
    Write(N);

  for I := 1 to 16 do
    begin
      Ch[I] := Font[N,I]; Clip[I] := Font[N,I];
    end;

  for J := 1 to 16 do
    begin
      Str(Ch[J],S); S := Dec_Bin(S);  S := Copy(S,8,9);
        for I := 1 to Length(S) do
          VCh[I,J] := (S[I] = '1');
    end;

    I := 1; J := 1;

    repeat
      GotoXY(dgEdit.X1^+3,dgEdit.Y2^-1);
        Color(colNormalText.Fore,colNormalText.Back);
          if I < 10 then Write('0'); Write(I);
            Write(':');
          if J < 10 then Write('1'); Write(J);

      for Code := 1 to 16 do
        begin
          GotoXY(dgEdit.X1^+4,dgEdit.Y1^+1+Code);
          for K := 1 to 8 do
            if VCh[K, Code] then Write('* ') else Write('ú ');
        end;

      GotoXY(dgEdit.X1^+2+(I*2),dgEdit.Y1^+1+J);
        Color(colInfoLine.Fore,colInfoLine.Back);
        if VCh[I,J] then Write('*') else Write('ú');
      Key := Get_key;

    case Key of
      kbUp :  if J > 1 then Dec(J);
      kbDown : if J < 16 then Inc(J);
      kbLeft : if I > 1 then Dec(I);
      kbRight : if I < 8 then Inc(I);
      kbSpace : VCh[I,J] := not(VCh[I,J]);
      kbAltI : for Code := 1 to 16 do for K := 1 to 8 do
        VCh[K, Code] := not VCh[K, Code];
    end;                        

    until (Key = kbEnter) or (Key = kbEsc);

  for J := 1 to 16 do
    begin
      S := '';
      for I := 1 to 8 do
        if VCh[I,J] then
          S := S + '1'
          else S := S + '0';
         S := Bin_Dec(S);
       Val(S,Ch[J],Code);
    end;

  for I := 1 to 16 do
    begin
      if Key = kbEnter then Font[N,I] := Ch[I]
        else Font[N,I] := Clip[I];
      if (Key = kbEnter) and (Font[N,I] <> Clip[I]) then
        FileChanged := True;
    end;

  dgEdit.CloseWindow;
  dgEdit.Done;
end;

procedure SetStatusLine(S : string);
begin { SetStatusLine }
  FullWin;
  Color(colStatusLine.Fore,colStatusLine.Back);
    GotoXY(1,25); ClrEol;
    GotoXY(1,25); Write(Copy(S,1,79));
end; { SetStatusLine }

function CheckExist(S : string) : Boolean;
var F : file;
begin { CheckExist }
{$I-}
  Assign(F,S);
  Reset(F);
    if IOResult = 0 then CheckExist := True
  else CheckExist := False;
  Close(F);
    if IOResult <> 0 then S := strZero;
end; { CheckExist }

function CheckFileSyntax(S : string) : Boolean;
var I : Byte;
    Filter : Boolean;
begin { CheckFileName }
  Filter := False;
  for I := 1 to Length(S) do
    case Ord(UpCase(S[I])) of
      0..32, 34, 42..44, 47, 59..63, 91, 93..255 : Filter := True;
    end; { case }
  CheckFileSyntax := Filter;
end; { CheckFileName }

procedure NewFile_Generator;
var I,J : Byte;
    Regs : Registers;
    Key : Char;
begin { NewFile_Generator }
  if FileChanged then
    I := Error(erVrf,4);
  case I of
    1 : SaveFont;
    3 : Exit;
  end; { case }

  Regs.AX := $1130;
  Regs.BH := $06;
  Intr($10,Regs);
    for I := 0 to 255 do
      for J := 0 to 15 do
    Font[I,Succ(J)] := Mem[Regs.ES:Regs.BP+J+(16*I)];
  I := 0;
  FileName := Noname;
  FileChanged := False;
  NewFile := True;
end; { NewFile_Generator }

procedure NewFile_Empty;
var I,J : Byte;
begin { NewFile_Empty }
  if FileChanged then
    I := Error(erVrf,4);
  case I of
    1 : SaveFont;
    3 : Exit;
  end; { case }
  for I := 0 to 255 do
    for J := 1 to 16 do
      begin
        Font[I,J] := 0;
      end;
  FileName := Noname;
  FileChanged := False;
  NewFile := True;
end; { NewFile_Empty }

procedure OpenFont;
var F : file;
    I,J,Z : Byte;
    Buff : array[1..4098] of Byte;
    N, Count : Word;
    OpenFile : TLists;
    S : string;
begin { OpenFont }
  if FileChanged then
    I := Error(erVrf,4);
  case I of
    1 : SaveFont;
    3 : Exit;
  end; { case }
{$I-}
  S := FileName;
  OpenFile.Init;
  FileName := OpenFile.PointFile(' Open Font ','*.CHR');
  OpenFile.Done;

  if FileName = '' then
    begin
      FileName := S;
      Exit;
    end;

  if not CheckExist(FileName) then
    begin
      NewFile_Generator;
      Exit;
    end;

Assign(F,FileName);
  repeat
    Z := 0;
    Reset(F,1);
   if IOResult <> 0 then
     Z := Error(erErr,5);
  until Z <> 1;
  if Z = 2 then Exit;

  SetStatusLine(' Opening ' + FileName + '.');

repeat
  Z := 0;
  BlockRead(F,Buff,SizeOf(Buff),N);
    If IOResult <> 0 then
      Z := Error(erErr,5);
until Z <> 1;
if Z = 2 then Exit;

  N := 0;
  for I := 0 to 255 do
    for J := 1 to 16 do
      begin
        Inc(N); Font[I,J] := Buff[N];
      end;

  repeat
    Z := 0;
    Close(F);
      if IOResult <> 0 then
        Z := Error(erErr,5);
  until Z <> 1;
  FileChanged := False;
  NewFile := False;
end; { OpenFont }

function GetNChar;
var Dest,Code : Integer;
    I,J : Byte;
    Key : Char;
    S : string;
begin { GetNChar }
  dgMessage.Init;
  dgMessage.DefineWindow(24,7,57,18,' Choose ACSII code ',
                         Double,colDialog.Fore,colDialog.Back);
  dgMessage.OpenWindow;
  FullWin;
    GotoXY(24,16); Write(#199);
      for I := 25 to 56 do Write(#196);
    GotoXY(57,16); Write(#182);
    GotoXY(27,17); Write('Char:   Decimal:     Hex:');

  Color(colNormalText.Fore,colNormalText.Back);
    for J := 0 to 7 do
      for I := 1 to 32 do
        begin
          Dest := VideoAddr(24+I,8+J);
          Scr[Dest] := Pred((J*32)+I);
          Scr[Dest+1] := 16 * colNormalText.Back + colNormalText.Fore;
        end;
   I := 1; J := 0;
  repeat
    Dest := VideoAddr(24+I,8+J);
      Scr[Dest] := Pred((J*32)+I);
    Scr[Dest+1] := 16 * colInfoLine.Back + colInfoLine.Fore;
    Dest := VideoAddr(33,17);
        Str(Pred((J*32)+I),S);
        GotoXY(44,17); Write(CharStr(#32,3-Length(S)),S);
        GotoXY(53,17); Write(Copy(Dec_Hex(S),3,2));
      Scr[Dest] := Pred((J*32)+I);
    Scr[Dest+1] := 16 * colNormalText.Back + colNormalText.Fore;
      Key := Get_key;
    Dest := VideoAddr(24+I,8+J);
      Scr[Dest] := Pred((J*32)+I);
    Scr[Dest+1] := 16 * colNormalText.Back + colNormalText.Fore;
      case Key of
        kbUp : if J-1 >= 0 then Dec(J);
        kbDown : if J+1 <= 7 then Inc(J);
        kbLeft : if I-1 >= 1 then Dec(I);
        kbRight : if I+1 <= 32 then Inc(I);
        kbHome : begin I := 1; J := 0; end;
        kbEnd : Begin I := 1; J := 7; end;
        kbPageUp : Begin I := 32; J := 0; end;
        kbPageDown : Begin I := 32; J := 7; end;
      end; { Case }
  until (Key = kbEnter) or (Key = kbEsc);

  dgMessage.CloseWindow;
  dgMessage.Done;
  if Key = kbEsc then GetNChar := -1
    else GetNChar := Pred((J*32)+I);
end; { GetNChar }

procedure SetROMFont;
var Regs : Registers;
begin { SetROMFont }
  Regs.AX := $1130;
  Regs.BH := $06;
    Intr($10,Regs);
  Regs.AX := $1100;
  Regs.CX := 256;
  Regs.DX := 0;
  Regs.BL := 0;
  Regs.BH := $10;
    Intr($10,Regs);
end; { SetROMFont }

procedure ViewChar;
var dgView : TWindow;
    Regs : Registers;
    S : string;
    I,J : Byte;
    Dest : Integer;
    Key : Char;
begin { ViewChar }
  dgView.Init;
  dgView.SaveBar(1,1,80,25);
  Color(Blue,Blue); ClrScr;
    Regs.AX := $1100;
    Regs.CX := 256;
    Regs.BP := Ofs(Font);
    Regs.ES := Seg(Font);
    Regs.DX := 0;
    Regs.BL := 0;
    Regs.BH := $10;
      Intr($10,Regs);

    for J := 1 to 16 do
      begin
        Str(Font[N,J],S);
          S := Dec_Bin(S); S := Copy(S,7,9);
          for I := 1 to Length(S) do
            if S[I] = '0' then
            begin
              Dest := VideoAddr(31+I*2,4+J);
              Scr[Dest+1] := $00;
            end
              else
            begin
              Dest := VideoAddr(31+I*2,4+J);
              Scr[Dest] := N;
              Scr[Dest+1] := $0F;
            end;
      end;
  SetClock(False);
  Key := Get_key;
  SetClock(True);
    SetROMFont;
  dgView.LoadBar(1,1,80,25);
  dgView.Done;
end; { ViewChar }

procedure ViewFont;
var I,J,N : Byte;
    Dest : Integer;
    dgView : TWindow;
    Regs : Registers;
    Key : Char;
begin { ViewFont }
  dgView.Init;
  dgView.SaveBar(1,1,80,25);
  Color(Blue,Blue); ClrScr;
    Regs.AX := $1100;
    Regs.CX := 256;
    Regs.BP := Ofs(Font);
    Regs.ES := Seg(Font);
    Regs.DX := 0;
    Regs.BL := 0;
    Regs.BH := $10;
     Intr($10,Regs);
    N := 0;
      for J := 1 to 8 do
        for I := 1 to 32 do
          begin
            Dest := VideoAddr(24+I,8+J);
            Scr[Dest] := N; Scr[Dest+1] := $0F;
            Inc(N);
          end;
    SetClock(False);
  Key := Get_key;
    SetClock(True);
  ClrScr; SetROMFont;
  dgView.LoadBar(1,1,80,25);
  dgView.Done;
end; { ViewFont }

procedure SaveProc;
var F : file;
    I,J,Z : Byte;
    Buff : array[1..4096] of Byte;
    N, Count : Word;
    S : string;
begin { SaveProc }
  if NewFile then
    if CheckExist(FileName) then
      Z := Error(erVrf,3);
    if Z = 3 then Exit;

{$I-}
Assign(F,FileName);
  repeat
    Z := 0;
    ReWrite(F,1);
   if IOResult <> 0 then
     Z := Error(erErr,2);
  until Z <> 1;
  if Z = 2 then Exit;

  SetStatusLine(' Saving ' + FileName + '.');
  N := 0;
  for I := 0 to 255 do
    for J := 1 to 16 do
      begin
        Inc(N); Buff[N] := Font[I,J];
      end;

  Count := SizeOf(Buff);

repeat
  Z := 0;
  BlockWrite(F,Buff,Count);
    If IOResult <> 0 then
      Z := Error(erErr,2);
until Z <> 1;
if Z = 2 then Exit;

  repeat
   Close(F);
   Z := 0;
   if IOResult <> 0 then
     Z := Error(erErr,2);
  until Z <> 1;
FileChanged := False;
NewFile := False;
end; { SaveProc }

procedure SaveFont;
var Save : TLists;
    S : string;
    I : Byte;
begin { SaveFont }
  S := FileName;
  for I := Length(FileName) downto 1 do
    if FileName[I] = '\' then Break;
    if Pos('\',FileName) > 0 then Inc(I);
    if CheckFileSyntax(FileName) or
       (FileName = strZero) or
       (Copy(FileName,I,6) = 'NONAME') then
     begin
       Save.Init;
       FileName := Save.PointFile(' Save file as ','*.CHR');
       Save.Done;
     end;
 if FileName <> '' then SaveProc
   else FileName := S;
end; { SaveFont }

procedure SaveFontAs;
var SaveAs : TLists;
    S : string;
    I : Byte;
begin { SaveFontAs }
  S := FileName;
  SaveAs.Init;
    FileName := (SaveAs.PointFile(' Save file as ','*.CHR'));
  SaveAs.Done;
  if FileName = strZero then
    begin
      FileName := S;
      Exit;
    end
  else
    begin
      NewFile := True;
      SaveProc;
    end;
end; { SaveFontAs }

procedure ExportAs(Ext : string);
var ExpAs : TLists;
    I, J : Byte;
begin { ExportAs }
  ExportFile := strZero;
  for I := Length(FileName) downto 1 do
    if FileName[I] = '\' then
      begin
        Inc(I); Break;
      end;
  for J := I to Length(FileName) do
    if FileName[J] <> '.' then
      ExportFile := ExportFile + FileName[J] else Break;
    ExportFile := ExportFile + '.' + Ext;

  ExpAs.Init;
    ExportFile := (ExpAs.PointFile(' Export as ',ExportFile));
  ExpAs.Done;
end; { ExportAs }

procedure ExportFontPas;
Var F : Text;
    S : string;
    ExportFont : TLists;
    I, J, Z : Byte;
    N : Word;
begin { ExportFontPas }
{$I-}
  if FileName = '' then FileName := 'NONAME.CHR';
    ExportAs('PAS');
  if ExportFile = '' then
    Exit;

  Z := 0;
if CheckExist(ExportFile) then
  Z := Error(erVrf,3);
  case Z of
    2 : begin
          ExportAs('PAS');
            if ExportFile = strZero then
              Exit;
        end;
    3 : Exit;
  end; { case }

  Z := 0;
    Assign(F,ExportFile);
      repeat
        ReWrite(F);
          If IOResult <> 0 then
        Error(erVrf,2);
      until Z <> 1;

  SetStatusLine(' Exporting ' + ExportFile + '.');
  WriteLn(F,'const  Font : array[0..255,1..16] of Byte =');
  Write(F,'      ((');
  for I := 0 to 255 do
    begin
      if I > 0 then Write(F,'       (');
        for J := 1 to 16 do
          begin
            Str(Font[I,J],S);
            S := Copy(Dec_Hex(S),3,2);
            Write(F,'$',S);
            if J < 16 then Write(F,',');
          end;
        if I < 255 then WriteLn(F,'),');
      if J < 16 then Write(F,',');
    end;
  Write(F,'));');
Z := 0;
  repeat
    Close(F);
      if IOResult <> 0 then
    Error(erVrf,2);
  until Z <> 1;
End; { ExportFontPas }

procedure ExportFontC;
Var F : Text;
    S : string;
    ExportFont : TLists;
    I, J, Z : Byte;
    N : Word;
begin { ExportFontC }
{$I-}
  if FileName = '' then FileName := 'NONAME.CHR';
    ExportAs('C');
  if ExportFile = '' then
    Exit;

  Z := 0;
if CheckExist(ExportFile) then
  Z := Error(erVrf,3);
  case Z of
    2 : begin
          ExportAs('C');
            if ExportFile = strZero then
              Exit;
        end;
    3 : Exit;
  end; { case }

  Z := 0;
    Assign(F,ExportFile);
      repeat
        ReWrite(F);
          If IOResult <> 0 then
        Error(erVrf,2);
      until Z <> 1;

  SetStatusLine(' Exporting ' + ExportFile + '.');
  WriteLn(F,'unsigned char font[256][16] =');
  Write(F,'      {{');
  for I := 0 to 255 do
    begin
      if I > 0 then Write(F,'       {');
        for J := 1 to 16 do
          begin
            Str(Font[I,J],S);
            if Font[I,J] < 100 then
              begin
                S := ' ' + S;
                if Font[I,J] < 10 then S := ' ' + S;
              end;
            Write(F,S);
            if J < 16 then Write(F,',');
          end;
        if I < 255 then WriteLn(F,'},');
      if J < 16 then Write(F,',');
    end;
  Write(F,'}};');
Z := 0;
  repeat
    Close(F);
      if IOResult <> 0 then
    Error(erVrf,2);
  until Z <> 1;
End; { ExportFontC }

begin { ChrBin }
  FileName := 'NONAME.CHR';
end. { ChrBin }
