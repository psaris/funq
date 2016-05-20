/ Minimize a continuous differentialble multivariate function. Starting point is
/ given by "X" (D by 1), and the function named in the string "f", must return a
/ function value and a vector of partial derivatives. The Polack- Ribiere
/ flavour of conjugate gradients is used to compute search directions, and a
/ line search using quadratic and cubic polynomial approximations and the
/ Wolfe-Powell stopping criteria is used together with the slope ratio method
/ for guessing initial step sizes. Additionally a bunch of checks are made to
/ make sure that exploration is taking place and that extrapolation will not be
/ unboundedly large. "n" gives the length of the run: if it is positive, it
/ gives the maximum number of line searches, if negative its absolute gives the
/ maximum allowed number of function evaluations. You can (optionally) give "n"
/ a second component, which will indicate the reduction in function value to be
/ expected in the first line-search (defaults to 1.0). The function returns when
/ either its length is up, or if no further progress can be made (ie, we are at
/ a minimum, or so close that due to numerical problems, we cannot get any
/ closer). If the function terminates within a few iterations, it could be an
/ indication that the function value and derivatives are not consistent (ie,
/ there may be a bug in the implementation of your "f" function). The function
/ returns the found solution "X", a vector of function values "fX" indicating
/ the progress made and "i" the number of iterations (line searches or function
/ evaluations, depending on the sign of "n") used.

/ Usage: (X; fX; i) = .fmincg.fmincg[n; f; X]

/ See also: checkgrad

/ Copyright (C) 2001 and 2002 by Carl Edward Rasmussen. Date 2002-02-13

/ (C) Copyright 1999, 2000 & 2001, Carl Edward Rasmussen

/ Permission is granted for anyone to copy, use, or modify these programs and
/ accompanying documents for purposes of research or education, provided this
/ copyright notice is retained, and note is made of any changes that have been
/ made.

/ These programs and documents are distributed without any warranty, express or
/ implied.  As the programs were written for research purposes only, they have
/ not been tested to the degree that would be advisable in any important
/ application.  All use of these programs is entirely at the user's own risk.

/ [ml-class] Changes Made:
/ 1) Function name and argument specifications
/ 2) Output display

/ [nick psaris] changes made:
/ 1) ported to q
/  a) renamed "length" as "n"
/  b) placed within .fmincg namespace
/  c) moved constants out of function and into namespace
/  d) refactored to overcome 'locals and 'branch parse errors
/  e) pass/return variables as dictionary to overcome 8 function parameter limit
/  f) introduced BREAK variable to overcome q's lack of break statement
/ 2) max length "n" is now mandatory

\d .fmincg / function minimize nonlinear congjugate gradient

RHO:.01 / a bunch of constants for line searches
SIG:.5  / RHO and SIG are the constants in the Wolfe-Powell conditions
INT:.1 / don't reevaluate within 0.1 of the limit of the current bracket
EXT:3f / extrapolate maximum 3 times the current bracket
MAX:20 / max 20 function evaluations per line search
RATIO:100 / maximum allowed slope ratio
REALMIN:2.2251e-308

wolfepowell:{[d1;d2;f1;f2;z1]$[d2>d1*neg SIG;1b;f2>f1+d1*RHO*z1]}
polackribiere:{[df1;df2;s](s*((df2$df2)-df1$df2)%df1$df1)-df2}
quadfit:{[f2;f3;d2;d3;z3]z3-(.5*d3*z3*z3)%(f2-f3)+d3*z3}
cubicfit:{[f2;f3;d2;d3;z3]
 A:(6f*(f2-f3)%z3)+3f*d2+d3;
 B:(3f*f3-f2)-z3*d3+2f*d2;
 z2:(sqrt[(B*B)-A*d2*z3*z3]-B)%A; / numerical error possible - ok!
 z2}
cubicextrapolation:{[f2;f3;d2;d3;z3]
 A:(6f*(f2-f3)%z3)+3f*d2+d3;
 B:(3f*f3-f2)-z3*d3+2f*d2;
 z2:(z3*z3*neg d2)%(B+sqrt[(B*B)-A*d2*z3*z3]); / numerical error possible - ok!
 z2}

minimize:{[F;v]
 v[`z2]:$[v[`f2]>v[`f1];quadfit;cubicfit][v[`f2];v[`f3];v[`d2];v[`d3];v[`z3]];
 if[v[`z2] in 0n -0w 0w;v[`z2]:.5*v[`z3]]; / if we had a numerical problem then bisect
 v[`z2]:(v[`z3]*1f-INT)|v[`z2]&INT*v[`z3]; / don't accept too close to limits
 v[`z1]+:v[`z2];
 v[`X]+:v[`z2]*v[`s];
 v[`f2`df2]:F v[`X];
 v[`d2]:v[`df2]$v[`s];
 v[`z3]-:v[`z2];            / z3 is now relative to the location of z2
 v}

extrapolate:{[F;v]
 v[`z2]:cubicextrapolation[v[`f2];v[`f3];v[`d2];v[`d3];v[`z3]];
 v[`z2]:$[$[v[`z2]<0;1b;v[`z2]=0w];$[v[`limit]<=.5;v[`z1]*EXT-1f;.5*v[`limit]-v[`z1]];
  $[v[`limit]>-.5;v[`limit]<v[`z2]+v[`z1];0b];.5*v[`limit]-v[`z1]; / extraplation beyond max? -> bisect
  $[v[`limit]<-.5;(v[`z1]*EXT)<v[`z2]+v[`z1];0b];v[`z1]*EXT-1f; / extraplation beyond limit -> set to limit
  v[`z2]<v[`z3]*neg INT;v[`z3]*neg INT;
  $[v[`limit]>-.5;v[`z2]<(v[`limit]-v[`z1])*1f-INT;0b];(v[`limit]-v[`z1])*1f-INT; / too clost to limit?
  v[`z2]];
 v[`f3]:v[`f2];v[`d3]:v[`d2];v[`z3]:neg v[`z2]; / set point 3 equal to point 2
 v[`z1]+:v[`z2];v[`X]+:v[`z2]*v[`s]; / update current estimates
 v[`f2`df2]:F v[`X];
 v[`d2]:v[`df2]$v[`s];
 v}

loop:{[n;F;v]
 v[`i]+:n>0;                    / count iterations?!
 v[`X]+:v[`z1]*v[`s];           / begin line search
 v[`f2`df2]:F v[`X];
 v[`i]+:n<0;                    / count epochs?!
 v[`d2]:v[`df2]$v[`s];
 v[`f3]:v[`f1];v[`d3]:v[`d1];v[`z3]:neg v[`z1]; / initialize point 3 equal to point 1
 v[`M]:$[n>0;MAX;MAX&neg n-v[`i]];
 v[`success]:0b;v[`limit]:-1;   / initialize quantities
 BREAK:0b;
 while[not BREAK;
  while[$[v[`M]>0;wolfepowell . v`d1`d2`f1`f2`z1;0b];
   v[`limit]:v[`z1];            / tighten the bracket
   v:minimize[F;v];
   v[`M]-:1;v[`i]+:n<0;         / count epochs?!
   ];
  if[wolfepowell . v`d1`d2`f1`f2`z1;BREAK:1b];   / failure
  if[v[`d2]>SIG*v[`d1];v[`success]:1b;BREAK:1b]; / success
  if[v[`M]=0;BREAK:1b];                          / failure
  if[not BREAK;
   v:extrapolate[F;v];
   v[`M]-:1;v[`i]+:n<0;         / count epochs?!
   ];
  ];
 v}

onsuccess:{[v]
 v[`f1]:v[`f2];
 1"Iteration ",string[v[`i]]," | cost: ", string[v[`f1]], "\r";
 v:@[v;`s;polackribiere[v[`df1];v[`df2]]]; / Polack-Ribiere direction
 v[`df2`df1]:v[`df1`df2];                  / swap derivatives
 v[`d2]:v[`df1]$v[`s];
 / new slope must be negative, otherwise use steepest direction
 if[v[`d2]>0;v[`s]:neg v[`df1];v[`d2]:v[`s]$neg v[`s]];
 v[`z1]*:RATIO&v[`d1]%v[`d2]-REALMIN; / slope ratio but max RATIO
 v[`d1]:v[`d2];
 v}

fmincg:{[n;F;X]                 / n can default to 100
 v:`X`i!(X;0);                  / zero the run length counter
 ls_failed:0b;                  / no previous line search has failed
 fX:();
 v[`f1`df1]:F v[`X];            / get function value and gradient
 v[`s]:neg v[`df1];             / search direction is steepest
 v[`d1]:v[`s]$neg v[`s];        / this is the slope
 v[`z1]:(n:n,1)[1]%1f-v[`d1];   / initial step is red/(|s|+1)
 n@:0;                          / n is first element
 v[`i]+:n<0;                    / count epochs?!

 while[v[`i]<abs n;             / while not finished
  X0:v[`X`f1`df1];              / make a copy of current values
  v:loop[n;F;v];
  if[v[`success];fX,:v[`f2];v:onsuccess[v]];
  if[not v[`success];
   v[`X`f1`df1]:X0;     / restore point from before failed line search
   / line search failed twice in a row or we ran out of time, so we give up
   if[$[ls_failed;1b;v[`i]>abs n];-1"";:(v[`X];fX;v[`i])];
   v[`df2`df1]:v[`df1`df2];     / swap derivatives
   v[`z1]:1f%1f-v[`d1]:v[`s]$neg v[`s]:neg v[`df1]; / try steepest
   ];
  ls_failed:not v[`success];    / line search failure
  ];
 -1"";(v[`X];fX;v[`i])}