clear all;
%Let's say we have 50MHz as input frequency
fref = 50e6;
LoopBW_multiplier = 10;
LoopBW = fref/LoopBW_multiplier

%From previous analysis we know that:
%poles(2)= -(C + Cx)/(C*Cx*R) ---- This is the LoopBW = 1/(R*C1) = 1/(R*C_series_with_Cx)

% LoopBW = 1/(R*C1)
R_times_C1 = 1/LoopBW
R = 1e3  % Arbitrary!
C1 = 1/(LoopBW*R)
% And C is 10*Cx
% C1 = 10*Cx*Cx/(10*Cx+Cx) = 10*Cx^2/(11*Cx) = (10/11)*Cx
Cx = (11/10)*C1
C = 10*Cx
% The above gives:
% Cx = 2.2000e-12
% C = 22.000e-12
% R = 100e3


Raux=R
Caux=C
Cxaux=Cx




% Finally let's plot again for these values
%================================================
% Same thing as before, now for Loop Filter made of parallel combination of Cx
% with a series combination of R+C:
syms R C Cx s;

assignin('base','R',Raux)
assignin('base','C',Caux)
assignin('base','Cx',Cxaux)

Zr = R;
Zc = capz(C,s);
Zcx = capz(Cx,s);
Zloop_filt = parallelz(Zcx,seriesz(Zr,Zc))
Zloop_filt = simplify(Zloop_filt)
[N,D] = numden(Zloop_filt)
%From this we can get the poles as the roots of the denominator:
poles = solve(D==0,s)
zeroes = solve(N==0,s)
%That gives us a few specific values of zeroes and poles:
% poles = 
%-5057235284857433424875349213774427543568384/2758491973558599926925485443165625
%                                                                              0
% zeroes = 
% -77371252455336267181195264/464227514732017625

%We see a pole at 0 which is good, but the numbers are too long to make
%sense.
% Therefore we plot them with zplane()
zplane(zeroes,poles)

%That was enough to plot the zeroes and poles.
%That was enough to plot the zeroes and poles.
%Now I do this extra line here, in order to plot the Bode of Zloop_filt later:
s = tf('s')
%And I recalculate Zloop_filt with that 's' as a tf object, so that Zloop_filt will 
% also be a 'tf' object, so I can use the Bode function:
Zr = R;
Zc = capz(C,s);
Zcx = capz(Cx,s);
Zloop_filt = parallelz(Zcx,seriesz(Zr,Zc))
%Then let's Bode it:
figure(1)
subplot(2,1,1)
bode(Zloop_filt)                                               
[mag,phase,wout] = bode(Zloop_filt);
subplot(2,1,2)
pzplot(Zloop_filt)

%And yes again the Bode plot looks as expected in terms of shape, the poles
%and zeroes also look the same as in the analysis.

%What can we do from here?
%Since we have some R, C, Cx values we could now do the PLL stability
%analysis with that.
%Just need to plug in some values for Io and Kvco.

syms err out in LF_tf VCO_tf beta s;
syms Kvco R C Cx Io pi;
assignin('base','beta',1)


assignin('base','R',Raux)
assignin('base','C',Caux)
assignin('base','Cx',Cxaux)
assignin('base','Io',2e-3)
assignin('base','Kvco',100e6)
assignin('base','pi',3.1416)

% Previously:
% LF_tf = (Io/(2*pi)) * (1+s*C*R)/(       s*(C+Cx)    *    ( 1 + s*R*(C*Cx/(C+Cx)) )     )
% Now, doing the simplification C=10*Cx:
LF_tf = (Io/(2*pi)) * (1+s*C*R)/(       s*C    *    ( 1 + s*R*Cx )     )
VCO_tf = Kvco/s;
Open_Loop_Gain = LF_tf * VCO_tf;
TF = Open_Loop_Gain / (1 + beta*Open_Loop_Gain)
TF = simplify(TF)
%The above gives:
%TF =
% (Io*Kvco*(C*R*s + 1))/(2*C*Cx*R*pi*s^3 + 2*C*pi*s^2 + C*Io*Kvco*R*s + Io*Kvco)
%Previously it was:
% (Io*Kvco*(Cx*R*s + 1))/(2*R*pi*Cx^2*s^3 + 4*pi*Cx*s^2 + Io*Kvco*R*Cx*s + Io*Kvco)
[N,D] = numden(TF);
poles = solve(D==0,s);
zeroes = solve(N==0,s);

%See this link to get explicit poles values:
% https://uk.mathworks.com/help/symbolic/sym.root.html#:~:text=root(%20p%20%2C%20x%20)%20returns,the%20roots%20of%20the%20polynomial.

Poles_explicit = solve(D==0,s,'MaxDegree',3)
Poles_explicit = double(Poles_explicit)
Zeroes_explicit = solve(N==0,s,'MaxDegree',3)
Zeroes_explicit = double(Zeroes_explicit)


%Here we plot those poles and zeroes:
figure(4)
zplane(Zeroes_explicit,Poles_explicit)

