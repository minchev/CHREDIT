{**********************************}
{*                                *}
{*    Character Editor 1.0        *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

program ChrEdit;
uses Crt, Colors, Dialogs, Errors, Windows, Keyboard, Menus, Views, ChrBin;

const Copyright : string = 'ñÖàÉéâm@ñèîìâíh@åâàÉçèm';

var sbFile, sbNew,
    sbEdit, sbExport,
    Main         : TMenu;
    E1,E2,
    I            : Byte;
    N, OrigMode  : Integer;
    SystemWin,
    Dialog       : TWindow;
    StructView   : TView;

procedure Quit; far;
begin { Quit }
  I := 0;
  if FileChanged then
    I := Error(erVrf,4);
  case I of
    1 : SaveFont;
    3 : Exit;
  end; { case }
  sbFile.DestructMenu;
  sbEdit.DestructMenu;
  sbNew.DestructMenu;
  sbExport.DestructMenu;
  Main.DestructMenu;
  StructView.Done;
  TextMode(OrigMode);
  SystemWin.LoadBar(1,1,80,25);
  SystemWin.Done; Cursor(7,8); Color(Black,LightGray);
  CheckBreak := False;
  Halt(1);
end; { Quit }

procedure About;
  Var dgAbout : TWindow;
      sbButt : TButt;
begin { About }
  dgAbout.Init;
  dgAbout.DefineWindow(23,5,56,19,' About ',Double,
                       colDialog.Fore,colDialog.Back);
  dgAbout.OpenWindow;
    Color(colNormalText.Fore,colNormalText.Back);
     Write(#13#10'  Character Editor Version 1.1'#13#10,
           #13#10'       Copyright (c) 1995'#13#10,
                 '    Revised edition (c) 1997',
           #13#10'   by ');
    for I := Length(Copyright) downto 1 do
      Write(Chr(Ord(Copyright[I])-32));
     Write(#13#10#13#10'    Bulgaria, Sevlievo 5400',
           #13#10'  bf. West, block 29, flat 21',
           #13#10'    tel: +359 (0675) 82-66');
    FullWin;
    DrawBox(dgAbout.X1^+1,dgAbout.Y1^+7,dgAbout.X2^-1,dgAbout.Y2^-3,Single);
    sbButt.Init;
      sbButt.SetItem('   ~O~K   ',dgAbout.X1^+13,dgAbout.Y2^-2);
    sbButt.InitButt; sbButt.ActiveButt;
    sbButt.Done;
  dgAbout.CloseWindow;
  dgAbout.Done;
end; { About }

procedure Define;
begin { Define }
  CheckBreak := False;
  OrigMode := LastMode;
  SetROMFont;
  SystemWin.Init;
  SystemWin.SaveBar(1,1,80,25);
  TextMode(CO80);
  StructView.Init;
  StructView.HighMode;
  StructView.InitDesktop(#176);
  StructView.InitStatusLine;
  SetClock(True);
  kbFastKey := kbAltX; FastProc := Quit;
  NewFile_Generator;

  Main.DefineMenu(Horiz,2,1);
    Main.SetItem(' ~F~ile ',' File managment programs',kbAltF);
    Main.SetItem(' ~E~dit ',' Edit a character',kbAltE);
  Main.InitMenu;

  sbFile.DefineMenu(Vert,3,2);
    sbFile.SetItem(' ~N~ew',' Create a new file',kbNull);
    sbFile.SetItem(' ~O~pen...',' Open a file',kbNull);
    sbFile.SetItem(' ~S~ave',' Save the current file',kbNull);
    sbFile.SetItem(' Save ~a~s... ',
      ' Save the current file under different name',kbNull);
    sbFile.SetItem(SEPARATOR,'',kbNull);
    sbFile.SetItem(' ~E~xport', ' Export font to a constant',kbNull);
    sbFile.SetItem(SEPARATOR,'',kbNull);
    sbFile.SetItem(' A~b~out',
      ' Show version and copyright information',kbNull);
    sbFile.SetItem(' E~x~it',' Exit Character Editor',kbNull);
  sbFile.InitMenu;
  sbFile.SetStatus(3,FileChanged);

  sbNew.DefineMenu(Vert,5,4);
    sbNew.SetItem(' ~R~ead font generator... ',
      ' Read font from font generator',kbNull);
    sbNew.SetItem(' ~E~mpty',' Create empty font',kbNull);
  sbNew.InitMenu;

  sbExport.DefineMenu(Vert,5,9);
    sbExport.SetItem(' ~P~ascal     ', ' Export to Pascal constant', kbNull);
    sbExport.SetItem(' ~C~', ' Export to C constant', kbNull);
  sbExport.InitMenu;

  sbEdit.DefineMenu(Vert,11,2);
    sbEdit.SetItem(' ~E~dit character... ',' Edit character 0..255',kbNull);
    sbEdit.SetItem(SEPARATOR,'',kbNull);
    sbEdit.SetItem(' View ~c~haracter ',' View any character',kbNull);
    sbEdit.SetItem(' ~V~iew font',' View current font',kbNull);
  sbEdit.InitMenu;
end { Define };

begin { ChrEdit }
Define;
  repeat
    E1 := Main.ActiveMenu(Fictive); E2 := E1;
    while (E2 = mvLeft) or (E2 = mvRight) or (E2 = mvDown) do
      begin
        case Main.M^ of
          1 : begin
                sbFile.SetStatus(3,FileChanged);
                E2 := sbFile.ActiveMenu(Main);
                if E2 = mvDown then
                  case sbFile.M^ of
                    1 : begin
                          E2 := sbNew.ActiveMenu(sbFile);
                          if E2 = mvDown then
                            Case sbNew.M^ of
                              1 : NewFile_Generator;
                              2 : NewFile_Empty;
                            end; { case }
                        end;
                    2 : OpenFont;
                    3 : SaveFont;
                    4 : SaveFontAs;
                    6 : begin
                          E2 := sbExport.ActiveMenu(sbFile);
                          if E2 = mvDown then
                            Case sbExport.M^ of
                              1 : ExportFontPas;
                              2 : ExportFontC;
                            end; { case }
                        end;
                    8 : About;
                    9 : Quit;
                  end; { case }
              end;
          2 : begin
                E2 := sbEdit.ActiveMenu(Main);
                if E2 = mvDown then
                  case sbEdit.M^ of
                    1 : begin
                          N := GetNChar;
                          if N <> -1 then
                            EditCharacter(N);
                        end;
                    3 : begin
                          N := GetNChar;
                          if N <> -1 then
                            ViewChar(N);
                        end;
                    4 : ViewFont;
                  end; { case }
              end;
        end; { case }
      end;

  until E1 = mvUp;
Quit;
end. { ChrEdit }
