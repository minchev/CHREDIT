{****************************************************************************}
{*****                                                                  *****}
{*****             Copyright (C) by Momchil Hristov Minchev             *****}
{*****                                                                  *****}
{****************************************************************************}

Unit Colors;
Interface
Uses Crt;

Type TColor = Record
       Fore,Back : Byte;
     End;

Var colInputNormal, colInputSelected, colInputArrow, colDesktop,
    colStatusLine, colClock, colMenuEnable, colMenuDesable, colMenuSelected,
    colShortcut, colDialog, colNormalText, colInfoLine, colError,
    colErrorHigh, colList, colListSelected, colListDialog, colListFocused,
    colScrollBar, colButtSelected, colButtEnable : TColor;

  Procedure Color(Fore, Back : Byte);

Implementation

Procedure Color;
Begin { Color }
  TextColor(Fore); TextBackground(Back);
End; { Color }

Begin { Colors }
  colInputNormal.Fore := White;           colInputSelected.Fore := Yellow;
  colInputNormal.Back := Blue;            colInputSelected.Back := Green;

  colInputArrow.Fore := LightGreen;       colDesktop.Fore := Blue;
  colInputArrow.Back := Blue;             colDesktop.Back := LightGray;

  colNormalText.Fore := Black;            colStatusLine.Fore := Black;
  colNormalText.Back := Cyan;             colStatusLine.Back := LightCyan;

  colClock.Fore := Black;                 colMenuEnable.Fore := Black;
  colClock.Back := Cyan;                  colMenuEnable.Back := LightCyan;

  colMenuDesable.Fore := DarkGray;        colMenuSelected.Fore := White;
  colMenuDesable.Back := LightCyan;       colMenuSelected.Back := Green;

  colShortcut.Fore := Red;
  colShortcut.Back := LightCyan;

  colDialog.Fore := White;                colInfoLine.Fore := Yellow;
  colDialog.Back := Cyan;                 colInfoLine.Back := Blue;

  colError.Fore := White;                 colErrorHigh.Fore := Yellow;
  colError.Back := Red;                   colErrorHigh.Back := Red;

  colList.Fore := LightGray;              colListSelected.Fore := White;
  colList.Back := Black;                  colListSelected.Back := Green;

  colListDialog.Fore := White;            colListFocused.Fore := Yellow;
  colListDialog.Back := Cyan;             colListFocused.Back := Black;

  colScrollBar.Fore := Blue;              colButtSelected.Fore := White;
  colScrollBar.Back := LightGray;         colButtSelected.Back := Green;

  colButtEnable.Fore := Black;
  colButtEnable.Back := Green;
End. { Colors }