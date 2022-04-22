# PLL analysis

A PLL as a frequency synthesizer is a system designed to generate an output signal that replicates the phase noise characteristics of an input reference clock.

Input reference clock - crystal oscillator
---
The input reference clock is usually an external, off-chip Crystal oscillator. This crystal oscillator is very accurate and very low phase noise.

A [crystal oscillator](https://en.wikipedia.org/wiki/Crystal_oscillator) can generate a square wave at an input frequency `Fref` and let's call its phase <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}">.

The goal of the PLL is to generate an output <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> that follows accurately the phase noise behaviour of the reference <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}">.




Input phase looks like a ramp, and we need a velocity control system
----
This is the first important point. Input phase looks like a ramp.
Since sin(2pi) = sin(4pi) = etc we could think of it as a sawtooth waveform, but it's not necessary.

![image](https://user-images.githubusercontent.com/95447782/164770558-0f53ce37-63b7-4031-982a-5a568abdce65.png)

The goal of the system is that <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> follows <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> exactly. But since the input signal is a square wave, <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> is a ramp and hence it is constantly moving, i.e. changing value, so therefore we need a "velocity control" system.

If <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> was a static value, or a value that just changes from one static value to another in steps, as in a step function, then for <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> to follow <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> we would just need a "position control" system. But this is not the case. For us, <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> is a ramp because the input signal is a square wave.

If <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> had absolutely no phase noise whatsoever, it would be a perfect linear ramp. In the real case where even <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> had some phase noise (even quite small as it's coming from the crystal oscillator) then <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> would be a ramp with slight non-linearity to it, and the point would be that we still want <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> to mimic <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> so that the phase noise of <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> would be exactly the same as that of <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}">, thus getting great phase noise performance on <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}">.



## How to make a velocity control system

First let's see things that don't work as a velocity control system.

Even before that, let's see what is a position control system and what isn't.

In a position control system, we want to track a position which is static, not changing all the time. At most, the position may just change from one static value to another in steps, but it's not like it's changing constantly. It just takes one static position value, and it stays there for a while, then eventually it may change to another position.

### System with 0 integrators:
Let's see if we can implement such position control system with a simple feedback system like this:

![image](https://user-images.githubusercontent.com/95447782/164772597-d0d38d2b-4d5c-49e1-b860-9ea30bb2d257.png)

In this system, the open loop gain (feed forward path) is A, then we have a feedback with no gain in it (feedback gain is 1) and it's a negative feedback.

The error signal after the summing block is <img src="https://render.githubusercontent.com/render/math?math=\epsilon = Input-Output">. But <img src="https://render.githubusercontent.com/render/math?math=Output = A*\epsilon"> so <img src="https://render.githubusercontent.com/render/math?math=\epsilon = Output/A"> and hence <img src="https://render.githubusercontent.com/render/math?math=\[Output/Input=\frac{A}{1+A}\]">  is the closed loop transfer function.


> 
> **Matlab script:**
> 
> [This Matlab script](matlab/calculate_closed_loop_tf.m) can be used to calculate the closed loop transfer function of the system above.
> 


```matlab
%Closed loop transfer function of the simple feedback system
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
```

Ok so we have our transfer function for the very basic system with unitary feedback, <img src="https://render.githubusercontent.com/render/math?math=\[Output/Input=\frac{A}{1+A}\]">.

Now, if our input to this system is, let's say, 1V, and we have a gain of A=5, the output is going to be 5/6 = 0.833V, so there is a fixed offset, the output doesn't match the input exactly. Even if we insert a large gain, like A=1000, the output for a 1V input will still be 1000/1001 = 0.999V which stil has a fixed offset in it. So this system is not a valid "position control" system. Note: Even if we had huge gain, like 1 million (that's 120dB in dB20 of 1V), we still would get 1uV offset. What if we wanted to get less than 1nV offset? We would need a huge gain like 1 billion (1G, which is 180dB).


### System with 1 integrator:
Now let's try a system with one integrator in the feed forward path. Can that be a "position control" system?

![image](https://user-images.githubusercontent.com/95447782/164773811-df78e54c-0abc-4028-9ecc-4f73eb882dc9.png)

So now we are integrating the error signal. The integral (over time) of a signal, if it's a fixed value, i.e. a constant, a static value, is going to tend to infinity as time goes to infinity. Given enough time, the integral will grow and grow and it will tend to infinity. Intuitively, this is like an infinitely large gain, so due to the feedback it will push (squeeze) the error signal down to zero, which is the same as saying that the output will tend to match the input exactly, as time goes to infinity.

That's an intuitive way of analyzing it. But let's analyze it in the s domain.

The integrator's Laplace transform is 1/s.


> 
> **Matlab script:**
> 
> [This Matlab script](matlab/closed_loop_tf_system_with_1_integrator.m) can be used to calculate the closed loop transfer function of the system with one integrator in the feed forward path.
> 



```matlab
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

```


The above calculations with the Symbolic Math Toolbox match the hand calculations:

![image](https://user-images.githubusercontent.com/95447782/164776487-a0574d33-94ba-49b7-aafb-e00879b9ae08.png)


Now, from the above, we can go from the frequency domain (Laplace, partial fractions expansion) to the time domain, and thus we can see what output value will be as time tends to infinity:

![image](https://user-images.githubusercontent.com/95447782/164776506-dc7ac1b6-4d03-4f71-82eb-7cdc24d241ff.png)


And we see that if the input is a step of value 1, the output will settle also at the input value 1, as time tends to infinity. So the output will match the input well.

Therefore, this system (the one with one integrator in the feed-forward) is a valid **"position control"** system.

This matches the intuitive analysis done previously, but we have also proven it with a formal analysis in the frequency (s) domain and back to the time domain.

Ok fair enough, but what we are looking for is a "velocity control" system, so we ask the question, can this system be a "velocity control" system?

For that, we put a ramp at the input and see if the output can track it accurately. Not a step input, but a ramp input. If the step input's Laplace transform was 1/s, the ramp input's Laplace transform is 1/s^2.

Let's do it:


```matlab
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

```

So we conclude that **the system with 1 single integrator** in the feed-forward path is ok as a "position control" system but **NOT OK as a "velocity control" system**.

![image](https://user-images.githubusercontent.com/95447782/164779708-00b3a284-2f61-4ad5-abd3-cf17ff1056f6.png)


Ok, so again we keep asking, how do we do a proper "velocity control" system?

Summary so far is:
* **0 integrators** (i.e. just an “A”) **can not even do position control well**. It will always leave an offset even if the target is a fixed position, i.e. a step, i.e. a u(t) (step~=1/s).
* **1 integrator can do position control** well. With enough time, output will settle at exact position u(t) accurately. **But it won’t do velocity control** well, as for a moving input (ramp~=1/s^2) it will always lag behind it with an offset.
* **2 integrators will do "velocity control", right? Well, not really**. Keep reading to find out why not.


## Why the VCO is an integrator

First of all, before continuing, let's show why the VCO is modelled as an integrator.

The VCO in principle is just a thing that takes in a Voltage and produces an output frequency which is proportional to the input voltage.

![image](https://user-images.githubusercontent.com/95447782/164779910-734dc617-4a56-476c-823b-f4ce234ad711.png)


But the PHASE is the INTEGRAL of the Frequency.

![image](https://user-images.githubusercontent.com/95447782/164779922-4337d1d8-c173-4cdd-a791-41a410604374.png)


Why is that the case? Because, by definition, the frequency (angular frequency in rad/s) is the rate of change of the phase (in radians or degrees).
Now, the same thing, said in the Laplace domain, is this, the phase in the frequency (s) domain is the frequency (omega) divided by s.

![image](https://user-images.githubusercontent.com/95447782/164780106-55889c5a-d31d-4fdc-8cf7-c94a43133f08.png)


And, in a VCO, the frequency is proportional to the input voltage. <img src="https://render.githubusercontent.com/render/math?math=\omega(t) = K*V(t)">  and <img src="https://render.githubusercontent.com/render/math?math=\omega(s) = K*V(s)">, but since <img src="https://render.githubusercontent.com/render/math?math=\phi(s) = \frac{\omega(s)}{s}"> then <img src="https://render.githubusercontent.com/render/math?math=\phi(s) = \frac{K*V(s)}{s}">.


![image](https://user-images.githubusercontent.com/95447782/164780297-931ae748-ba5e-4a6a-97a7-d80f63faaa5a.png)


Since we have that <img src="https://render.githubusercontent.com/render/math?math=\phi(s) = \frac{K*V(s)}{s}">, that's why we draw the VCO in the system diagram as a block that takes in a Voltage, outputs a Phase, and the black box "continuous time" relationship between them is K/s.

So we draw the VCO in our block diagram like this:

![image](https://user-images.githubusercontent.com/95447782/164780379-d9f431cc-8b78-4aa7-8b4b-c0a78f3e02b8.png)


And that's why our VCO is an integrator. Essentially it all comes from the fact that Phase is the Integral of Frequency, and frequency is proportional to input voltage in the VCO.

At this point, we say, ok so we have an integrator "for free" in our system, given by the VCO, can we get a proper "velocity control" system with just an extra integrator?

## System with 2 integrators:
We are going to see that to get a "velocity control" system it's not as easy as concatenating 2 integrators in the feed-forward path.

But let's prove it.

![image](https://user-images.githubusercontent.com/95447782/164780420-a8cebb12-458d-44ae-a2c4-bbb2aad9bb8e.png)


Such a system's transfer function will look like this:

<img src="https://render.githubusercontent.com/render/math?math=\[Output/Input = \frac{A/s^2}{1+A/s^2}\]">

 which is the same as <img src="https://render.githubusercontent.com/render/math?math=\[Output/Input = \frac{A}{s^2+A}\]">

or similarly <img src="https://render.githubusercontent.com/render/math?math=\[Output/Input = \frac{1}{s^2/A+1}\]">.

And such a system has 2 poles in the jw axis.
Where are the 2 poles?
<img src="https://render.githubusercontent.com/render/math?math=s^2+A=0  --> s^2=-A">

hence  <img src="https://render.githubusercontent.com/render/math?math=s=+/-j\sqrt{A}">

And we know a system with 2 poles on top of the jw axis like that will be UNSTABLE. Always unstable, or unconditionally unstable.
Remember that Barkhausen's criterion for INSTABILITY (oscillation) is that a complex pole pair must be placed on the imaginary axis of the complex frequency plane for steady state oscillations to take place, and the loop gain is unity  <img src="https://render.githubusercontent.com/render/math?math=|\beta A|=1">. In this case we see that the loop gain <img src="https://render.githubusercontent.com/render/math?math=|\beta A|=1"> because when  then s^2=-A so A/s^2  is -1 hence <img src="https://render.githubusercontent.com/render/math?math=|\beta A|=1">.

Conclusion from this is simply that we can't just concatenate 2 integrators and expect to get a "velocity control" system. This is why we need a LOOP FILTER in order to complete our PLL system.

