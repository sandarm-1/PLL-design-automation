in_ramp = 1/(s^2);
out_ramp_response = TF*in_ramp
%That gives:
%out_ramp_response =
% A/(s^2*(s + A*beta))

%Now we do partial fraction expansion of that:
P = partfrac(out_ramp_response, s)
%That gives:
%P = 1/(beta*s^2) - 1/(A*beta^2*s) + 1/(A*beta^2*(s + A*beta))
C = children(P);
C = [C{:}];
[N,D] = numden(C)
%The above is just to get Numerators and Denominators of the partial
% fractions separated.
%The above gives:
% N = [1, -1, 1]
% D = [beta*s^2, A*beta^2*s, A*beta^2*(s + A*beta)]

%Now, let's check if our output tracks the input as t tends to infinity.
%First of all, we can check that if in_ramp = 1/(s^2), that is a ramp in
%the time domain and we see that if we do ilaplace(in_ramp) we get ans=t.
%So, can we get that out_ramp_response_at_t_inf = t??

%Ok here we go:
Frac1=C(1)
Frac2=C(2)
Frac3=C(3)
Term1_in_time_domain=ilaplace(Frac1)
Term2_in_time_domain=ilaplace(Frac2)
Term3_in_time_domain=ilaplace(Frac3)
%From that we get:
% Term1_in_time_domain = t/beta
% Term2_in_time_domain = -1/(A*beta^2)
% Term3_in_time_domain = exp(-A*beta*t)/(A*beta^2)

%And we evaluate them at t=infinity:
assignin('base','A',999)
assignin('base','beta',1)
% assignin('base','t',inf) NOTE THIS TIME WE DON'T MAKE T=inf
% Just so we can see if the overall output is "t".
Term1_at_t_inf = eval(Term1_in_time_domain)
Term2_at_t_inf = eval(Term2_in_time_domain)
Term3_at_t_inf = eval(Term3_in_time_domain)
Out_at_t_inf = Term1_at_t_inf + Term2_at_t_inf + Term3_at_t_inf
%The above gives that Term1_at_t_inf = t -- GOOD
%The above gives that Term2_at_t_inf = -0.0010 -- NOTICE THE OFFSET!
%The above gives that Term3_at_t_inf = exp(-999*t)/999 -- THIS TENDS TO 0
% And hence:
% Out_at_t_inf = t + exp(-999*t)/999 - 1/999
% Which is like saying that out = "t + an offset" which is NOT following the
% input ramp exactly at t=inf, but is leaving an OFFSET to it.

% This is exactly as expected from the hand calculations.

% Again, we could have done it in one step:
%We could also have done the thing directly in one step:
assignin('base','A',999)
assignin('base','beta',1)
out_for_input_ramp_in_time_domain = ilaplace(out_ramp_response)
out_at_t_inf = eval(out_for_input_ramp_in_time_domain)
%The above gives:
% out_at_t_inf = t + exp(-999*t)/999 - 1/999
% Which is the same as before.

% Ok, so in summary, we got the right result.
% The conclusion is that the system with one single integrator does NOT
% follow the input ramp exactly at t=inf, it leaves an offset, hence
% it is not a valid "velocity control" system.
