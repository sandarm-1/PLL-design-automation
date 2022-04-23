%We are going to make it with unitary feedback, beta=1:
clear all
syms err out in LF_tf beta s;
syms Kvco R C Cx Io pi;
assignin('base','beta',1)

%Eqns from our analysis looking at the system's diagram:
% err = in-beta*out  WHICH EQUATES TO   out=(1/beta)*(in-err)
% Independently:
% out = filtered_err = LF_tf*VCO_tf*err
% Where
% LF_tf is the loop filter transfer function
% VCO_tf is the VCO transfer function
% And by definition:
% TF = out/in

%Symbolic math:
LF_tf = (Io/(2*pi)) * (1+s*C*R)/(       s*(C+Cx)    *    ( 1 + s*R*(C*Cx/(C+Cx)) )     )
VCO_tf = Kvco/s;
%eqn1 equates 2 expressions for out:
out_eqn1 = (1/beta)*(in - err);
out_eqn2 = LF_tf * VCO_tf * err;
%eqn_out_equals_out = [ (1/beta)*(in - err) == LF_tf*VCO_tf*err ]
eqn_out_equals_out = [ out_eqn1 == out_eqn2 ]
%From this we "solve" in, which essentially is a way to get
% an expression of "in" which does not contain out, just err
% and the params A and beta, AND s.
in_tmp = solve(eqn_out_equals_out, in)
in_tmp = simplify(in_tmp)
%The above gives:
%in_tmp =
% a long expression in terms of err, C, Cx, R, s.
%
% Now we use one of the expression of 'out', again an expression that only 
% contains err and the params of the system AND s:
out = LF_tf*VCO_tf*err
%From here we divide out/in to get TF as a expression that
%doesn't have out, in and not even err in it, just parameters A and beta.
%Hence TF is:
TF = out/in_tmp
TF = simplify(TF)
%The above gives:
% TF =
%  (Io*Kvco*(C*R*s + 1))/(Io*Kvco + 2*C*pi*s^2 + 2*Cx*pi*s^2 + 2*C*Cx*R*pi*s^3 + C*Io*Kvco*R*s)
% P = partfrac(TF, s) doesn't simplify it much, the denominator stays the same:
%  (Io*Kvco + C*Io*Kvco*R*s)/(2*C*Cx*R*pi*s^3 + (2*C*pi + 2*Cx*pi)*s^2 + C*Io*Kvco*R*s + Io*Kvco)

%Does Symbolic Math stack up with manual analysis so far?
%Yes it does!! And pretty nicely so.



% We could have arrived to the same Transfer Function calculation this way:
clear all
syms err out in LF_tf beta s;
syms Kvco R C Cx Io pi;
assignin('base','beta',1)

LF_tf = (Io/(2*pi)) * (1+s*C*R)/(       s*(C+Cx)    *    ( 1 + s*R*(C*Cx/(C+Cx)) )     )
VCO_tf = Kvco/s;
Open_Loop_Gain = LF_tf * VCO_tf;
TF = Open_Loop_Gain / (1 + beta*Open_Loop_Gain)
TF = simplify(TF)
%The above gives:
%TF =
% (Io*Kvco*(C*R*s + 1))/(Io*Kvco + 2*C*pi*s^2 + 2*Cx*pi*s^2 + 2*C*Cx*R*pi*s^3 + C*Io*Kvco*R*s)
% (Io*Kvco*(C*R*s + 1))/(Io*Kvco + 2*C*pi*s^2 + 2*Cx*pi*s^2 + 2*C*Cx*R*pi*s^3 + C*Io*Kvco*R*s)
% Which is exactly the same results.
% And in less lines of code.
% Both solutions work.
