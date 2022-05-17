unit Dialogs;
interface
uses Dos,Lists;
const
  Months : array[1..12] of string[3] =
           ('Jan','Feb','Mar','Apr','May','Jun',
            'Jul','Aug','Sep','Oct','Nov','Dec');
  maxButtons = 25;

type
  ButtStr = string[20];
  TLists = object
    Numb : Integer;
    constructor Init;
    function ViewList(lsView : PList; Top : string) : string; virtual;
    function PointFile(Top, SFilter : string) : string; virtual;
    private
    function Element(N : Integer; lsView : PList) : string; virtual;
    function FElement(N : Integer; lsPoint : PFList) : string; virtual;
    procedure FDirInfo(N:Integer; lsPoint:PFList; var DI:SearchRec); virtual;
    public
    destructor Done; virtual;
  end; { TLists }

  TButt = object
    Numb, M : ^Byte;
    Item : array[1..maxButtons] of ^ButtStr;
    X,Y : array[1..maxButtons] of ^Byte;
    ShortKeys : array[1..maxButtons] of ^Byte;
    constructor Init;
    procedure SetItem(SItem : string; Xp, Yp : Byte);
    procedure WriteItem(N : Byte; Status : Boolean);
    procedure InitButt;
    function ActiveButt : Byte;
    destructor Done; virtual;
  end; { TButt }

implementation
uses Crt,Colors,Errors,Keyboard,StrBin,Strings,Views,Windows;

function CheckFilter(S : string) : Boolean;
var I : Byte;
    Filter : Boolean;
begin { CheckFilter }
  Filter := False;
  for I := 1 to Length(S) do
    case Ord(UpCase(S[I])) of
      0..32, 34, 43..45, 58..62, 91, 93..255 : Filter := True;
    end; { case }
  if (S[1] = '.') then Filter := True;
  CheckFilter := Filter;
end; { CheckFilter }

function CheckFileName(S : string) : Boolean;
var I : Byte;
    Filter : Boolean;
begin { CheckFileName }
  Filter := False;
  for I := 1 to Length(S) do
    case Ord(UpCase(S[I])) of
      0..32, 34, 42..44, 47, 58..63, 91, 93..255 : Filter := True;
    end; { case }
  CheckFileName := Filter;
end; { CheckFileName }

constructor TLists.Init;
begin { TLists.Init }
end; { TLists.Init }

function TLists.Element;
var lsV : PList;
    Counter : Integer;
begin { TLists.Element }
Counter := 0; lsV := lsView^.Next;
  while (lsV <> nil) or (Counter < Numb) do
    begin
      Inc(Counter);
      if Counter = N then
        begin
          Element := lsV^.Data;
          Exit;
        end;
      lsV := lsV^.Next;
    end;
  Element := '';
end; { TLists.Element }

function TLists.ViewList;
var dgView : TWindow;
    lsV : PList;
    C : Word;
    S : string;
    P, H : Byte;
    M,I,J : Integer;
    Key : Char;
begin { TLists.ViewList }
  dgView.Init;
  dgView.DefineWindow(11,5,70,21,Top,Double,
    colListDialog.Fore,colListDialog.Back);
  dgView.OpenWindow; FullWin;
  DrawBox(dgView.X1^+1,dgView.Y1^+1,dgView.X2^-2,dgView.Y2^-4,Single);
  Color(colScrollBar.Fore,colScrollBar.Back);
  GotoXY(dgView.X1^+1,dgView.Y2^-3); Write(#17);
  GotoXY(dgView.X2^-2,dgView.Y2^-3); Write(#16);
  GotoXY(dgView.X2^-1,dgView.Y1^+1); Write(#30);
  GotoXY(dgView.X2^-1,dgView.Y2^-4); Write(#31);
  M := 1; P := 1; H := 1;
    lsV := lsView;
  C := 0;
  while lsV^.Next <> nil do
    begin
      Inc(C);
      lsV := lsV^.Next;
    end;
  lsV := lsView;
  Numb := C;

  repeat
    Color(colScrollBar.Fore,colScrollBar.Back);
    GotoXY(dgView.X1^+2,dgView.Y2^-3);
    for I := dgView.X1^+2 to dgView.X2^-3 do
      Write(#177);
    for J := dgView.Y1^+2 to dgView.Y2^-5 do
      begin
        GotoXY(dgView.X2^-1,J); Write(#177);
      end;
    if Numb > 0 then
      I := Round(H / (255 / 54));
    J := Round((M+P-1) / (Numb / 10));
    if J = 0 then J := 1; { Exceptions }
    if Numb < 10 then
      if (M+P-1) = 1 then J := 1;
    GotoXY(dgView.X1^+I+2,dgView.Y2^-3); Write(#254);
    GotoXY(dgView.X2^-1,dgView.Y1^+J+1); Write(#254);
    Color(colList.Fore,colList.Back);
    for C := 1 to 10 do
      begin
        GotoXY(dgView.X1^+2,dgView.Y1^+C+1);
        S := Copy(Element(C+M-1,lsV),H,54);
        Write(' ',S+CharStr(#32,dgView.X2^-dgView.X1^-Length(S)-5));
      end;
    Color(colListSelected.Fore,colListSelected.Back);
      GotoXY(dgView.X1^+2,dgView.Y1^+P+1);
      S := Copy(Element(M+P-1,lsV),H,54);
      Write(' ',S+CharStr(#32,dgView.X2^-dgView.X1^-Length(S)-5));
    Key := Get_key;
    case Key of
      kbUp : begin
               if (P-1) >= 1 then Dec(P)
                 else if M+P >= 3 then Dec(M);
             end;
      kbDown : begin
                 if (P+1 <= 10) and (P+1 <= Numb) then Inc(P)
                   else if M+P <= Numb then Inc(M);
               end;
      kbRight : if H+1 <= 255 then Inc(H);
      kbLeft : if H-1 >= 1 then Dec(H);
      kbPageUp : begin
                   if M-10 >= 1 then Dec(M,10)
                     else
                       begin
                         M := 1; P := 1;
                       end;
                 end;
      kbPageDown : begin
                     if M+10 <= Numb-10 then Inc(M,10)
                       else
                         begin
                           if Numb > 10 then
                             begin
                               P := 10; M := Numb-9;
                             end
                           else
                             begin
                               P := Numb; M := 1;
                             end;
                         end;
                   end;
      kbHome : begin
                 M := 1; P := 1;
               end;
      kbEnd : begin
                if Numb < 10 then
                  begin
                    P := Numb; M := 1;
                  end
                else
                  begin
                    P := 10; M := Numb-9;
                  end;
              end;
    end; { case }
  until (Key = kbEsc) or (Key = kbEnter);
  case Key of
    kbEnter : ViewList := Element(M+P-1,lsV);
    kbEsc : ViewList := strZero;
  end; { case }
  dgView.CloseWindow;
  dgView.Done;
end; { TLists.ViewList }

function TLists.FElement;
var lsP : PFList;
    Counter : Integer;
begin { TLists.FElement }
lsP := lsPoint;
  Counter := 0; lsP := lsPoint;
  while (lsP <> nil) or (Counter < Numb) do
    begin
      Inc(Counter);
      if Counter = N then
        begin
          if lsP^.Data.Attr = Directory then
            FElement := lsP^.Data.Name + '\'
          else FElement := lsP^.Data.Name;
          Exit;
        end;
      lsP := lsP^.Next;
    end;
  FElement := strZero;
end; { TLists.FElement }

procedure TLists.FDirInfo;
var lsP : PFList;
    Counter : Integer;
begin { TLists.FDirInfo }
lsP := lsPoint;
  Counter := 0; lsP := lsPoint;
  while (lsP <> nil) or (Counter < Numb) do
    begin
      Inc(Counter);
      if Counter = N then
        begin
          DI := lsP^.Data;
          Exit;
        end;
      lsP := lsP^.Next;
    end;
end; { TLists.FDirInfo }

function TLists.PointFile;
var dgPoint : TWindow;
    C, P, M : Integer;
    DirInfo : SearchRec;
    DT : DateTime;
    lsFiles : PFList;
    Filter, S, D, L, CurrDir, LastDir : string;
    Selected, chFilter, chEx : Boolean;
    Key, E : Char;
    I : Byte;
begin { TLists.PointFile }
{$I-}
  GetDir(0,LastDir);
  NewFList(lsFiles);
  Filter := SFilter; ReadFiles(lsFiles,Filter);
    dgPoint.Init;
    dgPoint.DefineWindow(25,4,55,22,Top,Double,
      colListDialog.Fore,colListDialog.Back);
    dgPoint.OpenWindow; FullWin;
    DrawBox(dgPoint.X1^+1,dgPoint.Y1^+4,dgPoint.X2^-1,dgPoint.Y2^-3,Single);
    Color(colNormalText.Fore,colNormalText.Back);
      GotoXY(dgPoint.X1^+2,dgPoint.Y1^+2); Write('Filter');
    Color(colScrollBar.Fore,colScrollBar.Back);
      GotoXY(dgPoint.X2^-1,dgPoint.Y1^+4); Write(#30);
      GotoXY(dgPoint.X2^-1,dgPoint.Y2^-3); Write(#31);
  Numb := MaxFList(lsFiles);
    M := 1; P := 1; Key := kbNull;
    Selected := False;
  GetDir(0,CurrDir);

  repeat
    Color(colScrollBar.Fore,colScrollBar.Back);
    for I := dgPoint.Y1^+5 to dgPoint.Y2^-4 do
      begin
        GotoXY(dgPoint.X2^-1,I); Write(#177);
      end;
    if Numb > 0 then
      I := Round((M+P-1) / (Numb / 10));
    if I = 0 then I := 1; { Exceptions }
    if Numb < 10 then
      if (M+P-1) = 1 then I := 1;
    GotoXY(dgPoint.X2^-1,dgPoint.Y1^+I+4); Write(#254);

    Color(colList.Fore,colList.Back);
    for I := 1 to 10 do
      begin
        GotoXY(dgPoint.X1^+2,dgPoint.Y1^+4+I);
        S := FElement(M + I,lsFiles);
        Write(' ',S,CharStr(#32,dgPoint.X2^-dgPoint.X1^-4-Length(S)));
      end;
    Color(colListSelected.Fore,colListSelected.Back);
      GotoXY(dgPoint.X1^+2,dgPoint.Y1^+P+4);
      S := FElement(M+P,lsFiles);
      Write(' ',S,CharStr(#32,dgPoint.X2^-dgPoint.X1^-4-Length(S)));
      FDirInfo(M+P,lsFiles,DirInfo);
    Color(colInfoLine.Fore,colInfoLine.Back);
      GotoXY(dgPoint.X1^+1,dgPoint.Y2^-2);
      S := ' ' + CurrDir;
        if S[Length(S)] <> '\' then S := S + '\';
      S := S + UpStr(Filter);
      S := Copy(S,1,dgPoint.X2^-dgPoint.X1^-2);
      Write(S,CharStr(#32,dgPoint.X2^-dgPoint.X1^-1-Length(S)));
        case DirInfo.Attr of
          Directory : D := 'Directory';
          VolumeID : D := 'CHANGE TO '+DirInfo.Name[3]+':';
          else Str(DirInfo.Size,D);
       end;
       S := ' ' + D + CharStr(#32,16 - Length(D));
       if (DirInfo.Attr and VolumeID = 0) then
         begin
           UnpackTime(DirInfo.Time,DT); Str(DT.Day,D);
             if DT.Day < 10 then S := S + '0';
               S := S + D + ' '; S := S + Months[DT.Month] +' ';
           Str(DT.Year,D); S := S + D;
        end;
         GotoXY(dgPoint.X1^+1,dgPoint.Y2^-1);
      Write(S+CharStr(#32,dgPoint.X2^-dgPoint.X1^-1-Length(S)));
    if Key <> kbNull then Key := Get_key
      else Key := kbTab;
    case Key of
      kbShiftTab, kbTab :
              begin
                L := Filter;
                repeat
                  Color(colListFocused.Fore,colListFocused.Back);
                    GotoXY(dgPoint.X1^+2,dgPoint.Y1^+P+4);
                    S := FElement(M+P,lsFiles);
                    Write(' ',S,CharStr(#32,dgPoint.X2^-
                          dgPoint.X1^-4-Length(S)));
                  E := EnterStr(Filter,dgPoint.X1^+3,dgPoint.Y1^+3,
                    dgPoint.X2^-dgPoint.X1^-5,NormStr);
                  chFilter := CheckFilter(Filter);
                  chEx := CheckFileName(Filter);
                  if chFilter then Error(erMsg,1);
                until not(chFilter);
                if E = kbEnter then
                  for C := 1 to Numb do
                    begin
                      FDirInfo(C,lsFiles,DirInfo);
                      S := FElement(C,lsFiles);
                      if (UpStr(Filter) = DirInfo.Name)
                        and (DirInfo.Attr and Directory = 0)
                        and (DirInfo.Attr and VolumeID = 0)
                        and (E = kbEnter) then
                      Selected := True;
                      if Selected then
                        begin
                          M := C; P := 0;
                          Break;
                        end;
                    end;
                  if E = kbEsc then
                    begin
                      Key := E;
                      Selected := True;
                    end;
                  if not(Selected) and (L <> Filter) and chEx then
                    begin
                      GetDir(0,CurrDir);
                        DelFList(lsFiles);
                          NewFList(lsFiles);
                        ReadFiles(lsFiles,Filter);
                      Numb := MaxFList(lsFiles); M := 1; P := 1;
                    end;
                  Cursor(32,0);
              end;
      kbUp : begin
               if (P-1) >= 1 then Dec(P)
                 else if M+P >= 3 then Dec(M);
             end;
      kbDown : begin
                 if (P+1 <= 10) and (P+1 <= Numb) then Inc(P)
                   else if M+P <= Numb then Inc(M);
               end;
      kbPageUp : begin
                   if M-10 >= 1 then Dec(M,10)
                     else
                       begin
                         M := 1; P := 1;
                       end;
                 end;
      kbPageDown : begin
                     if M+10 <= Numb-10 then Inc(M,10)
                       else
                         begin
                           if Numb > 10 then
                             begin
                               P := 10; M := Numb-9;
                             end
                           else
                             begin
                               P := Numb; M := 1;
                             end;
                         end;
                   end;
      kbHome : begin
                 M := 1; P := 1;
               end;
      kbEnd : begin
                if Numb < 10 then
                  begin
                    P := Numb; M := 1;
                  end
                else
                  begin
                    P := 10; M := Numb-9;
                  end;
              end;
      kbEsc : Selected := True;
      kbEnter : begin
                  FDirInfo(M+P,lsFiles,DirInfo);
                  if (DirInfo.Attr and VolumeID <> 0) then
                    begin
                      ChDir(DirInfo.Name[3]+':');
                        GetDir(0,CurrDir);
                          DelFList(lsFiles);
                            NewFList(lsFiles);
                        ReadFiles(lsFiles,Filter);
                      Numb := MaxFList(lsFiles); M := 1; P := 1;
                    end;
                  if (DirInfo.Attr and Directory <> 0) then
                    begin
                      S := FElement(M+P,lsFiles);
                      S := Copy(S,1,Length(S)-1);
                        ChDir(S);
                          GetDir(0,CurrDir);
                          DelFList(lsFiles);
                          NewFList(lsFiles);
                          ReadFiles(lsFiles,SFilter);
                          Numb := MaxFList(lsFiles); M := 1; P := 1;
                      end;
                  if (DirInfo.Attr and Directory = 0) and
                     (DirInfo.Attr and VolumeID  = 0) then
                    Selected := True;

                end;
    end; { case }
  until Selected or (not (chEx) and (E = kbEnter));

  if CurrDir[Length(CurrDir)] <> '\' then CurrDir := CurrDir + '\';
  dgPoint.CloseWindow;
  dgPoint.Done;
  if Selected then
    case Key of
      kbEnter : PointFile := CurrDir + FElement(M+P,lsFiles);
      kbEsc : PointFile := strZero;
    end; { case }
  if E = kbEnter then
    PointFile := CurrDir + Filter;
  DelFList(lsFiles);
  ChDir(LastDir);
end; { TLists.PointFile }

destructor TLists.Done;
begin { TLists.Done }
end; { TLists.Done }

constructor TButt.Init;
begin { TButt.Init }
  New(Numb); Numb^ := 0;
  New(M); M^ := 1;
end; { TButt.Init }

procedure TButt.SetItem;
var I : Byte;
    S : string;
    HighLight : Boolean;
begin { TButt.SetItem }
  if Numb^ < maxButtons then
    begin
      Inc(Numb^);
      New(Item[Numb^]); Item[Numb^]^ := SItem;
      New(X[Numb^]); New(Y[Numb^]);
      X[Numb^]^ := Xp; Y[Numb^]^ := Yp;
      New(ShortKeys[Numb^]); ShortKeys[Numb^]^ := 0;
        S := Item[Numb^]^; HighLight := False;
          for I := 1 to Length(S) do
            begin
              if S[I] = '~' then HighLight := not(HighLight);
              if HighLight and (S[I] <> '~') then
                Inc(ShortKeys[Numb^]^,Ord(S[I]));
           end;
    end;
end; { TButt.SetItem }

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

procedure TButt.WriteItem;
var HighLight : Boolean;
    Dest : Integer;
    S : string;
    I : Byte;
begin { TButt.WriteItem }
  HighLight := False;
  S := Item[N]^; GotoXY(X[N]^,Y[N]^);
  for I := 1 to Length(S) do
    begin
      if S[I] = '~' then HighLight := not(HighLight);
        if HighLight then TextColor(colShortcut.Fore)
          else
        begin
          if Status then TextColor(colButtSelected.Fore)
            else TextColor(colButtEnable.Fore);
        end;
        if Status then TextBackground(colButtSelected.Back)
          else TextBackGround(colButtEnable.Back);
      if S[I] <> '~' then Write(S[I]);
   end;
  for I := 1 to RealSize(S) do
    begin
      Dest := VideoAddr(X[N]^+I,Y[N]^+1);
      Scr[Dest] := $DF;
      Scr[Succ(Dest)] := 16 * Hi(Scr[Succ(Dest)] * 16);
    end;
  Dest := VideoAddr(X[N]^+RealSize(S),Y[N]^);
  Scr[Dest] := $DC;
  Scr[Succ(Dest)] := 16 * Hi(Scr[Succ(Dest)] * 16);
end; { TButt.WriteItem }

procedure TButt.InitButt;
var I : Byte;
begin { TButt.InitButt }
  for I := 1 to Numb^ do
    WriteItem(I,False);
end; { TButt.InitButt }

function TButt.ActiveButt;
var Key : Char;
    I, Lm : Byte;
begin { TButt.ActiveButt }
  Lm := M^;
repeat
  WriteItem(Lm,False);  WriteItem(M^,True);
  Key := Get_key;
  for I := 1 to Numb^ do
    if UpCase(Key) = UpCase(Chr(ShortKeys[I]^)) then
      begin
        M^ := I; Key := kbEnter;
        Break;
      end;
    case Key of
      kbTab : begin
                Lm := M^;
                if M^ < Numb^ then Inc(M^)
                  else M^ := 1;
              end;
      kbShiftTab : begin
                     Lm := M^;
                     if M^ > 1 then Dec(M^)
                       else M^ := Numb^;
                   end;
    end;
until (Key = kbEsc) or (Key = kbEnter);
if Key = kbEsc then M^ := 0;
ActiveButt := M^;
end; { TButt.ActiveButt }

destructor TButt.Done;
var I : Byte;
begin { TButt.Done }
  for I := 1 to Numb^ do
    begin
      Dispose(Item[I]);
      Dispose(X[I]); Dispose(Y[I]);
      Dispose(ShortKeys[I]);
    end;
  Dispose(M); Dispose(Numb);
end; { TButt.Done }

end. { Dialogs }