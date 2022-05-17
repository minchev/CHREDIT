unit Errors;
interface
type
  TError = (erMsg, erVrf, erErr);

const ErrorTop : array[erMsg..erErr] of string[8] =
        (' Message ',' Verify ',' Error ');

   Function Error(E : TError; N : Byte) : Byte;

Implementation
Uses Crt,Colors,Dialogs,Windows,Keyboard,Views,Strbin;

Function Ok : Byte;
Var sbPush : TButt;
Begin { Ok }
  sbPush.Init;
    sbPush.SetItem('   ~O~K   ', 36, 12);
    sbPush.InitButt;
  Ok := sbPush.ActiveButt;
  sbPush.Done;
End; { Ok }

Function YesNoCancel : Byte;
Var sbPush : TButt;
Begin { YesNoCancel }
  sbPush.Init;
    sbPush.SetItem('  ~Y~es  ', 27, 12);
    sbPush.SetItem('  ~N~o  ', 37, 12);
    sbPush.SetItem(' Cancel ', 46, 12);
    sbPush.InitButt;
  YesNoCancel := sbPush.ActiveButt;
  sbPush.Done;
End; { YesNoCancel }

Function RetryAbort : Byte;
Var sbPush : TButt;
Begin { RetryAbort }
  sbPush.Init;
    sbPush.SetItem(' ~R~etry ', 32, 12);
    sbPush.SetItem(' ~A~bort ', 41, 12);
    sbPush.InitButt;
  RetryAbort := sbPush.ActiveButt;
  sbPush.Done;
End; { RetryAbort }

Function Error;
Var Msg : ^String;
    dgError : TWindow;
    Key : Char;
    I : Byte;
Begin { Error }
  New(Msg);
  Msg^ := 'Unknown Error';
  dgError.Init;
  dgError.DefineWindow(23,7,57,14,ErrorTop[E],
                         Double,colError.Fore,colError.Back);
  Case N of
    1 : Msg^ := 'Invalid file name or extension';
    2 : Msg^ := 'Error creating file';
    3 : Msg^ := 'File already exist. Overwrite?';
    4 : Msg^ := 'File not saved. Save?';
    5 : Msg^ := 'Error opening file';
  End; { Case };
    dgError.OpenWindow;
      FullWin;
    Color(colErrorHigh.Fore,colErrorHigh.Back);
    GotoXY(dgError.X1^+((dgError.X2^-dgError.X1^+1)-Length(Msg^)) div 2,
           dgError.Y1^+2);
    Write(Msg^);
    FullWin;
      I := 0;
    Case E of
      erMsg : I := Ok;
      erVrf : I := YesNoCancel;
      erErr : I := RetryAbort;
    End; { Case }
  Error := I;
  Dispose(Msg);
  dgError.CloseWindow;
  dgError.Done;
End; { Error }

End. { Errors }