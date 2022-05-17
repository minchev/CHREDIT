unit Lists;
interface
uses Dos;
type
  RStr = String[80];
  PList = ^TList;
  TList = record
    Data : RStr;
    Next : PList;
  end; { TList }

  PFList = ^TFList;
  TFList = record
    Data : SearchRec;
    Next : PFList;
  end; { TFList }

procedure NewList(var Root : PList);
procedure ScanList(Data : string; var Root : PList);
procedure DelList(var Root : PList);

procedure NewFList(var Root : PFList);
function MaxFList(Root : PFList) : Integer;
procedure ScanFList(Data : SearchRec; var Root : PFList);
procedure ReadFiles(Root : PFList; Filter : string);
procedure DelFList(var Root : PFList);

implementation
uses Transfer;

procedure NewList;
begin { NewList }
  New(Root); Root^.Next := nil;
end; { NewList }

function MaxFList;
var C : Integer;
    lsFiles : PFList;
begin { MaxFList }
 C := 0; lsFiles := Root;
  while lsFiles^.Next <> nil do
    begin
      Inc(C);
      lsFiles := lsFiles^.Next;
    end;
  MaxFList := C;
end; { MaxFList }

procedure ScanList;
var PScan1, PScan2, PScan : PList;
begin { ScanList }
  PScan2 := Root;
  PScan1 := Root^.Next;
  while (PScan1 <> nil) and (PScan1^.Data < Data) do
    begin
      PScan2 := PScan1;
      PScan1 := PScan1^.Next;
    end;
  New(PScan);
  PScan^.Next := PScan1;
  PScan2^.Next := PScan;
  PScan^.Data := Data;
end; { ScanList }

procedure DelList;
var PDel, PNext : PList;
begin { DelList }
  PDel := Root^.Next;
  while PDel <> nil do
    begin
      PNext := PDel^.Next;
      Dispose(PDel); PDel := PNext;
    end;
  Dispose(Root); Root := nil;
end; { DelList }

procedure NewFList;
begin { NewFList }
  New(Root); Root^.Next := nil;
end; { NewFList }

procedure ScanFList;
var PScan1, PScan2, PScan : PFList;
begin { ScanFList }
  PScan2 := Root;
  PScan1 := Root^.Next;
  while (PScan1 <> nil) and (PScan1^.Data.Name < Data.Name) do
    begin
      PScan2 := PScan1;
      PScan1 := PScan1^.Next;
    end;
  New(PScan);
  PScan^.Next := PScan1;
  PScan2^.Next := PScan;
  PScan^.Data := Data;
end; { ScanFList }

procedure ReadFiles;
var DirInfo : SearchRec;
    lsFiles : PFList;
    Regs : Registers;
    FDD, HDD : Byte;
    S : string;
    I : Byte;
begin { ReadFiles }
  lsFiles := Root;
  FindFirst('*.*',Directory,DirInfo);
  while DosError = 0 do
  begin
    if (DirInfo.Name <> '.') and (DirInfo.Attr and Directory <> 0) then
      ScanFList(DirInfo,lsFiles);
    FindNext(DirInfo);
  end;
  while lsFiles^.Next <> nil do
    lsFiles := lsFiles^.Next;
  FindFirst(Filter,AnyFile,DirInfo);
  while DosError = 0 do
  begin
    if (DirInfo.Attr and Directory = 0) and (DirInfo.Attr and VolumeID = 0)
      then ScanFList(DirInfo,lsFiles);
    FindNext(DirInfo);
  end;
  Intr($11,Regs);
    Str(Regs.AX,S); S := Dec_Bin(S);
  if S[1] = '1' then
    begin
      S := Bin_Dec(Copy(S,7,2));
        Val(Bin_Dec(S),FDD,Regs.AX);
      Inc(FDD);
    end;
  DirInfo.Attr := VolumeID;
  for I := 1 to FDD do
    begin
      DirInfo.Name := '[-' + Chr(64+I) + '-]';
      ScanFList(DirInfo,lsFiles);
    end;
  for I := 3 to 26 do
    begin
      Regs.AH := $36;
      Regs.DL := I;
        Intr($21,Regs);
      if Regs.AX <> $FFFF then
        begin
          DirInfo.Name := '[-' + Chr(64+I) + '-]';
          ScanFList(DirInfo,lsFiles);
        end;
    end;
end; { ReadFiles }

procedure DelFList;
var PDel, PNext : PFList;
begin { DelList }
  PDel := Root^.Next;
  while PDel <> nil do
    begin
      PNext := PDel^.Next;
      Dispose(PDel); PDel := PNext;
    end;
  Dispose(Root); Root := nil;
end; { DelList }

end. { Lists }