%Symbolic Math analysis for the system with one integrator in the
%feed-forward path.
%
%The purpose of Symbolic Math analysis is to get an expression
% of the transfer function TF (which
%is defined as out/in) that doesn't depend on out, in nor err, just
%the parameters A and beta AND ALSO s.
%
%To start with we have symbolic variables err, out, in
%(those are signals) and A and beta (which are loop paremeters),
%plus s (which is the special variable for our frequency domain analysis).

%We are going to make it with Beta feedback (equally valid for unit feedback):
clear all
syms err out in A beta s;

%Eqns from our analysis looking at the system's diagram:
% err = in-beta*out  WHICH EQUATES TO   out=1/beta(in-err)
% Independently:
% out = A*integrated_err = (A/s)*err
% Where
% integrated_err = (1/s)*err
% And by definition:
% TF = out/in

%Symbolic math:
%eqn1 equates 2 expressions for out:
eqn_out_equals_out = [ (1/beta)*(in - err) == (A/s)*err ]
%From this we "solve" in, which essentially is a way to get
% an expression of "in" which does not contain out, just err
% and the params A and beta, AND s.
in_tmp = solve(eqn_out_equals_out, in)
in_tmp = simplify(in_tmp)
%The above gives:
%in_tmp =
% (err*(s + A*beta))/s
%One expression of out is this, again an expression that only 
% contains err and the params A and beta AND s:
out = (A/s)*err
%From here we divide out/in to get TF as a expression that
%doesn't have out, in and not even err in it, just parameters A and beta.
%Hence TF is:
TF = out/in_tmp
TF = simplify(TF)
%The above gives:
% TF =
%  A/(s + A*beta)

%That all makes sense and Symbolic Math stacks up with manual analysis.

%That was pretty decent. We got to our TF in the frequency domain thanks to
%the Symbolic Math Toolbox.

%Now, we do one extra step:
%We are going to see what kind of output we get for a specific kind of
%input.
%In this case we are going to assume the input is a STEP, i.e. u(t), and
%its Laplace transform of that is 1/s. So we make input=1/s
%And we calculate what is the output like, since we already have the TF.
in_step = 1/s;
out_step_response = TF*in_step
%That gives:
%out_step_response =
% A/(s*(s + A*beta))

%Now we do partial fraction expansion of that:
P = partfrac(out_step_response, s)
%That gives:
%P = 1/(beta*s) - 1/(beta*(s + A*beta))
C = children(P);
C = [C{:}];
[N,D] = numden(C)
%The above is just to get Numerators and Denominators of the partial
% fractions separated.
%The above gives:
% N = [-1, 1]
% D = [beta*(s + A*beta), beta*s]

%From here, all that remains to do is to go back from Laplace domain to the
%time domain.
%That's basically doing the inverse Laplace transform of the partial
%fractions.
%In Matlab, we do that with ilaplace(F).
% ilaplace(F) returns the Inverse Laplace Transform of F.
% By default, the independent variable is s and the transformation variable is t.

%Ok here we go:
Frac1=C(1)
Frac2=C(2)
Term1_in_time_domain=ilaplace(Frac1)
Term2_in_time_domain=ilaplace(Frac2)
%From that we get:
% Term1_in_time_domain = -exp(-A*beta*t)/beta
% Term2_in_time_domain = 1/beta

%And we evaluate them at t=infinity:
assignin('base','A',999)
assignin('base','beta',1)
assignin('base','t',inf)
Term1_at_t_inf = eval(Term1_in_time_domain)
Term2_at_t_inf = eval(Term2_in_time_domain)
Out_at_t_inf = Term1_at_t_inf + Term2_at_t_inf
%The above gives that Term1_at_t_inf = 0
%The above gives that Term2_at_t_inf = 1

%We could also have done the thing directly in one step:
assignin('base','A',999)
assignin('base','beta',1)
assignin('base','t',inf)
out_in_time_domain = ilaplace(out_step_response)
out_at_t_inf = eval(out_in_time_domain)
%The above gives out_at_t_inf = 1

%I think the "assignin" I did above is not quite correct way of doing it,
% because I think it should work by just assigning t=inf, and it shouldn't
% require me to assign values to A and beta, but I can't get it to evaluate
% unless I assign some value to A and beta.
% But I also think it's not too far off, as doing it this way it
% gets us the answers we are looking for.
