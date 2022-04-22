%Calculate Closed loop transfer function of a simple feedback system
syms err out in A;

%Eqns from my analysis:
% err = in-out  WHICH EQUATES TO   out=in-err
% Independently:
% out = A*err
% And by definition:
% TF = out/in

%Symbolic math:
%eqn1 equates 2 expressions for out:
eqn_out_equals_out = [ in - err == A*err ]
in_tmp = solve(eqn_out_equals_out, in)
in_tmp = simplify(in_tmp)
%The above gives:
%in_tmp =
% err*(A + 1)
%One expression of out is this:
out = A*err
%Hence TF is:
TF = out/in_tmp
TF = simplify(TF)
%The above gives:
% TF =
%  A/(A + 1)

clear out TF
%The same result is obtained if I depart from the other expression of out:
out = in_tmp-err
%Hence TF is:
TF = out/in_tmp
TF = simplify(TF)
%The above ALSO gives:
% TF =
%  A/(A + 1)


%Note on the purpose of Symbolic Math analysis:
%The purpose of Symbolic Math analysis is to get an expression
% of the transfer function TF (which
%is defined as out/in) that doesn't depend on out, in nor err, just
%the parameters A and beta.
%Let's say to start with we have symbolic variables err, out, in
%(those are signals) and A and beta (which are loop paremeters).
%We want to get to an expression of the transfer function TF (which
%is defined as out/in) that doesn't depend on out, in nor err, just
%the parameters A and beta.


%Same thing with Beta feedback:
clear all
syms err out in A beta;

%Eqns from my analysis:
% err = in-beta*out  WHICH EQUATES TO   out=1/beta(in-err)
% Independently:
% out = A*err
% And by definition:
% TF = out/in

%Symbolic math:
%eqn1 equates 2 expressions for out:
eqn_out_equals_out = [ (1/beta)*(in - err) == A*err ]
%From this we "solve" in, which essentially is a way to get
% an expression of "in" which does not contain out, just err
% and the params A and beta.
in_tmp = solve(eqn_out_equals_out, in)
in_tmp = simplify(in_tmp)
%The above gives:
%in_tmp =
% err*(A*beta + 1)
%One expression of out is this, again an expression that only 
% contains err and the params A and beta:
out = A*err
%From here we divide out/in to get TF as a expression that
%doesn't have out, in and not even err in it, just parameters A and beta.
%Hence TF is:
TF = out/in_tmp
TF = simplify(TF)
%The above gives:
% TF =
%  A/(A*beta + 1)

%That all makes sense and Symbolic Math stacks up with manual analysis.
