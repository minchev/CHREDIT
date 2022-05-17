Unit Math;

Interface
  Function Power(N,P : Integer) : Longint;
  Function RealPower(N,P : Real) : Real;

Implementation

Function Power;
Begin { Power }
  Power := Round(Exp(P * Ln(N)));
End; { Power }

Function RealPower;
Begin { Power }
  RealPower := Exp(P * Ln(N));
End; { Power }

End. { Math }
