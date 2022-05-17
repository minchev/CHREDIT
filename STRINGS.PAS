unit Strings;
interface

type
  TStrings = (NormStr, PassStr);

  function EnterStr(var S : string;
                    X,Y,Lng : Byte; Kind : TStrings) : Char;

implementation

  Uses Crt,Colors,Views,StrBin,Keyboard;

function EnterStr;
  var I,J,K,L,M,C : Byte;
      LO,RO,IS : Boolean;
      Key : Char;
begin { EnterStr }
  LO := False; RO := False;

  Cursor(7,8); Color(colInputNormal.Fore,colInputNormal.Back);
  GotoXY(X-1,Y); Write(CharStr(' ',Lng+1));

  L := Length(S);
    if L > Lng then
      begin
        I := Lng+1; K := L - Lng;
        J := L + 1;
      end
    else
      begin
        I := L+1; K := 0;
        J := I;
      end;

  IS := True;
  if IS then Cursor(7,8) else Cursor(0,8);
    M := Length(Copy(S,Succ(K+Lng),L));

repeat
  L := Length(S);
  M := Length(Copy(S,Succ(K+Lng),L));

  if K > 0 then
    LO := True else LO := False;
  if Length(Copy(S,Succ(K+Lng),L)) > 0 then
    RO := True else RO := False;

  Color(colInputNormal.Fore,colInputNormal.Back);
  GotoXY(X,Y);
    case Kind of
      NormStr : Write(Copy(S,K+1,Lng + 1));
      PassStr : Write(CharStr('*',Length(Copy(S,K+1,Lng + 1))));
    end; { case }
  if M = 0 then Write(#32);

  Color(colInputArrow.Fore,colInputArrow.Back);
  GotoXY(X-1,Y); if LO then Write(#17) else Write(#32);
  GotoXY(X+Lng,Y); if RO then Write(#16) else Write(#32);

  GotoXY(X+I-1,Y);

  Key := Get_key;
  case Key of
    kbBack : begin
               if K-1 >= 0 then Dec(K)
                 else if I-1 >= 1 then Dec(I);
               if J-1 >= 1 then
                 begin
                   Dec(J);
                   Delete(S,J,1);
                   GotoXY(X+I-1,Y); Write(#32);
                 end;
             end;
     kbDel : begin
               If J <= L then
                 Delete(S,J,1);
             end;
    kbLeft : begin
               if I-1 >= 1 then Dec(I)
                 else if K-1 >= 0 then Dec(K);
               if J-1 >= 1 then Dec(J);
             end;
   kbRight : begin
               if (I+1 <= Lng+1) and (I+1 <= Succ(L)) then Inc(I)
                 else If K+1 <= L-Lng then Inc(K);
               if J <= L then Inc(J);
             end;
     kbIns : begin
               IS := not(IS);
               if IS then Cursor(7,8) else Cursor(0,8);
             end;
    kbHome : begin
               I := 1; J := 1; K := 0;
             end;
     kbEnd : begin
               if L > Lng then
                 begin
                   I := Lng+1; K := L - Lng;
                   J := L + 1;
                 end
               else
                 begin
                   I := L+1; K := 0;
                   J := I;
                 end;
             end;
     kbEsc : S := strZero;
        #32..#191 : begin
                      if not(IS) and (J <= L) and (L <= 255) then
                        S[J] := Key;
                          if IS and (J <= 255) and (L < 255) then
                            begin
                              Insert(Key,S,J);
                                if I+1 <= Lng+1 then Inc(I)
                                  else if K+1 <= 255-Lng then Inc(K);
                            end;
                        if J+1 <= 255 then Inc(J);
                    end;
  end { case };
until (Key = kbEnter) or (Key = kbEsc) or (Key = kbTab);
EnterStr := Key;
end { EnterStr };

end. { Strings }