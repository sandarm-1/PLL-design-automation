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

![redone_images_1](https://user-images.githubusercontent.com/95447782/164889172-d1af919b-8b64-46d9-ae94-ce4725208386.jpg)



The goal of the system is that <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> follows <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> exactly. But since the input signal is a square wave, <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> is a ramp and hence it is constantly moving, i.e. changing value, so therefore we need a "velocity control" system.

If <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> was a static value, or a value that just changes from one static value to another in steps, as in a step function, then for <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> to follow <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> we would just need a "position control" system. But this is not the case. For us, <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> is a ramp because the input signal is a square wave.

If <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> had absolutely no phase noise whatsoever, it would be a perfect linear ramp. In the real case where even <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> had some phase noise (even quite small as it's coming from the crystal oscillator) then <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> would be a ramp with slight non-linearity to it, and the point would be that we still want <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> to mimic <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}"> so that the phase noise of <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> would be exactly the same as that of <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}">, thus getting great phase noise performance on <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}">.



## How to make a velocity control system

First let's see things that don't work as a velocity control system.

Even before that, let's see what is a position control system and what isn't.

In a position control system, we want to track a position which is static, not changing all the time. At most, the position may just change from one static value to another in steps, but it's not like it's changing constantly. It just takes one static position value, and it stays there for a while, then eventually it may change to another position.

### System with 0 integrators:
Let's see if we can implement such position control system with a simple feedback system like this:

![image](https://user-images.githubusercontent.com/95447782/164889194-1a555382-90b1-4c6e-9fda-759bf1828971.png)


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

>    **Matlab script:**
>
>    This [Matlab script](matlab/step_response_and_ramp_response.m) can be used to calculate the step response and ramp response of a system with one single integrator in the feed-forward path.
>    


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
Remember that Barkhausen's criterion for INSTABILITY (oscillation) is that a complex pole pair must be placed on the imaginary axis of the complex frequency plane for steady state oscillations to take place, and the loop gain is unity  <img src="https://render.githubusercontent.com/render/math?math=|\beta A|=1">. In this case we see that the loop gain <img src="https://render.githubusercontent.com/render/math?math=|\beta A|=1"> because when <img src="https://render.githubusercontent.com/render/math?math=s=+/-j*sqrt(A)"> then s^2=-A so A/s^2  is -1 hence <img src="https://render.githubusercontent.com/render/math?math=|\beta A|=1">.

Conclusion from this is simply that we can't just concatenate 2 integrators and expect to get a "velocity control" system. This is why we need a LOOP FILTER in order to complete our PLL system.


## The Loop Filter

We have reached the point that we know that our PLL system has to look like this. I mean, it has to look like this means that we have a VCO for sure, which is an integrator, we have a Phase Detector PD, which is the error block at the feedback point, and then we have reached the conclusion that we need an extra block, which we will call the "loop filter", which is the extra component required to finally construct the desired "velocity control" system in a way that the whole thing is stable and actually performs "velocity control" which is essentially the ability of the output to follow accurately an input that looks like a ramp.

![image](https://user-images.githubusercontent.com/95447782/164781821-8234a1cb-3904-4efd-a429-85fd2d01509f.png)


Before we talk about the loop filter, let's just say that the PD looks as follows, and the gain of the PD is <img src="https://render.githubusercontent.com/render/math?math=\frac{\mathrm{VDD}}{2\pi }">
. Why is the PD gain <img src="https://render.githubusercontent.com/render/math?math=\frac{\mathrm{VDD}}{2\pi }">
? Because if Vout is lagging behing Vref by half a period, as seen in the figure, that is equivalent to a phase difference of 90 degrees, i.e. <img src="https://render.githubusercontent.com/render/math?math=\phi_{\mathrm{ref}} -\phi_{\mathrm{out}} =\frac{\pi }{2}">
 and in that situation we see that, because of how the PD is implemented, the "UP" signal pulses up for a quarter of the time, i.e. 25% of the time, hence its average value is VDD/4. And similarly, in the opposite case, if the Vout signal happens to lead Vref by 90 degrees, then <img src="https://render.githubusercontent.com/render/math?math=\phi_{\textrm{ref}} -\phi_{\textrm{out}} =-\frac{\pi }{2}">
 and in that situation the "DOWN" signal will pulse up a quarter of the time, hence its average value will be VDD/4. Then, overall, differentially, the "UP - DOWN" signal will have an overall range of VDD/2 for an input phase difference range of <img src="https://render.githubusercontent.com/render/math?math=\frac{\pi }{2}-\left(-\frac{\pi }{2}\right)=\pi">
, so the overall gain of the PD defined as Output/Input is <img src="https://render.githubusercontent.com/render/math?math=\mathrm{PD}\_\mathrm{gain}=\frac{\left(\frac{\mathrm{VDD}}{2}\right)}{\pi }=\frac{\mathrm{VDD}}{2\pi}">


![image](https://user-images.githubusercontent.com/95447782/164889651-bcf4ccfc-ec8a-4460-8dfc-df55f97a9bff.png)


So the model of the PD is this:

![image](https://user-images.githubusercontent.com/95447782/164785672-62dfc3d6-2585-4ce2-b5e5-2487adb534f2.png)


Now, the Phase Detector output is a couple of digital signals, but what we need at the input of the VCO is an analog signal (Vctrl). So between the PD and the VCO we need some sort of D/A conversion.

How do we do fast D/A conversion? Current steering.

![image](https://user-images.githubusercontent.com/95447782/164785701-1746884b-1e81-4234-a119-8aaa42dfd5db.png)


So at the output of the Charge Pump, the VOLTAGE that we get on the CAP (let's call it Vcp) is the following:

* When UP is 1 but DOWN is 0, Cap charges up at a rate <img src="https://render.githubusercontent.com/render/math?math=\frac{I_o }{C}">. By rate we mean Volts per second, i.e. the voltage on the cap increases as a linear ramp from its initial voltage at a rate of <img src="https://render.githubusercontent.com/render/math?math=\frac{I_o }{C}"> Volts per second. So, if it was fully discharged, starting at 0V, and we push let's say 1mA into it, and the cap is 1pF then 1mA/1pF=1e9 V/s = 1V per 1 nanosecond.

* In the opporiste case, if DOWN is 1 and UP is 0, the Cap will (dis)charge at a rate <img src="https://render.githubusercontent.com/render/math?math=\frac{I_o }{C}">, again in the example before it would go from 1V down to 0V in 1 nanosecond.

So, the value of Vcp represents the value of the "ACCUMULATED AREA UNDER THE CURVE OF UP-DOWN DIFFERENTIAL SIGNAL". Ideally, what we would REALLY want is for the value of Vcp to represent the AVERAGE value of UP-DOWN differential signal. Yes, all we are trying to achieve here is to put together a mechanism that will tell us what is the AVERAGE of UP-DOWN differential signal. Why? Because we want to correct our VCO based on how much its phase differs from the reference phase ON AVERAGE. Like, not instantaneously, we don't want to wabble our VCO around every single reference clock period, no... We want to wait a few reference clock periods, get the average phase difference of our VCO's phase from the reference, and then based on that average correct our VCO a bit up or down.

So, keep in mind that throwing current into (and out of) the cap is our crude attempt at getting a voltage out of the CP that represents the Average of UP-DOWN.

Now look at the following diagram to see exactly what the CP voltage does as a response to UP-DOWN pulses:

![image](https://user-images.githubusercontent.com/95447782/164786025-2c81d294-49ad-4361-987a-d8e8e5a29d2b.png)


From the previous diagram we can see visually the behaviour of Vcp. A few moments later we will see that this Charge Pump mechanism is not exactly providing an instantaneous average of UP-DOWN, just an integral of it, but that will serve as an approximation for the average of UP-DOWN.

Writing the behaviour of Vcp mathematically, Vcp is a representation of the INTEGRAL of "UP-DOWN" differential signal. That is:

![image](https://user-images.githubusercontent.com/95447782/164786044-f42c7b00-2872-4498-a40e-d9a37a747ec5.png)


That's an "undefined" integral and represents the overall behaviour of Vcp as a function of UP-DOWN differential signal. But, to be more accurate, if we want to know the SPECIFIC value of Vcp at a particular time, we need to evaluate the integral, like this:

![image](https://user-images.githubusercontent.com/95447782/164786054-0cfef4f0-b7b3-46d0-8f28-9418cae12d4f.png)


Please note that the expression INSIDE THE INTEGRAL is NOT the average value of UP-DOWN differential signal. It's the ACTUAL TIME-CHANGING VALUE(s) taken dynamically by UP-DOWN differential signal. Why do we bring this up? As we mentioned before, ideally we want the CP to produce a voltage that is a representation of the AVERAGE value of UP-DOWN. Why? Again, because we want to correct our VCO based on the AVERAGE value of UP-DOWN, because that's the purpose of our PD system. However, in our attempt to convert UP-DOWN from digital to analog, we thought that it would be a good idea to do this by shoving current in/out of a Cap based on UP-DOWN signals (that's where the Charge Pump came from) and in doing so we built this circuit which what it actually does is to INTEGRATE UP-DOWN, not to CALCULATE THE AVERAGE OF UP-DOWN. That's us being strict here. BUT still, in real life this won't be a problem, because **if we integrate over a long enough period of time, then the integral IS the average.** That's the thing here. Yes, the integral of UP-DOWN is NOT the average of UP-DOWN but if we ZOOM OUT and we only evaluate the integral over relatively long segments of time (and I will define relatively in a second) then the integral is a good approximation of the average. In fact, if you were reset your integrator to 0V, then start feeding it with the stream of UP-DOWN pulses, then wait for a huuuuuuuuuge period of time, letting your integrator integrate during that long long period of time, and after such long long period of time you look at the integrator's output, then at that exact moment the integrator's output will be a number which is pretty much exactly the average value of UP-DOWN during the long long period of time. So, what is a "relatively long" period of time here? Simply a period of time that is much larger than the reference clock period, since that is the sampling frequency of UP-DOWN or the frequency at which UP-DOWN updates itself to a new value.

Anyway, all of this was just to justify that the integral of UP-DOWN that the Charge Pump gives us will be good enough to be used to control the VCO.

The following figure tries to give an intuition as to why the integral of UP-DOWN is a proxy for the average of UP-DOWN, when we zoom out.

![image](https://user-images.githubusercontent.com/95447782/164786148-07a70de3-2adb-4785-8060-abe81c83a3ce.png)


Anyway, whether that expression is the average of UP-DOWN differential signal or just an approximation, that´s ok as long as we are aware of that, what matters is that we have this integrative behaviour coming out of the Charge Pump, and that's ok, we recognize that and we insert that into our model.

**Hence our model of the PD+CP looks like the error block followed by a couple of gain blocks followed by an integrator which is due to the Charge Pump**. That's not bad, remember from the "1 integrator" section that we saw that an integrator right after the error signal can have this effect that it tries to force the error signal to be tiny and that is a good thing, at least in principle. But we also saw that 2 integrators with nothing else (CP+VCO) will be unstable. So that's why we need the Loop Filter.

![image](https://user-images.githubusercontent.com/95447782/164786230-96adb1a9-5397-43d1-b673-0242c514b485.png)


2 integrators with nothing else (CP+VCO) will be unstable. So that's why we need the Loop Filter.

![image](https://user-images.githubusercontent.com/95447782/164786268-d2676c21-d361-4a2d-8bca-7798f066ab9b.png)


Finally, we are going to develop the Loop Filter.

There are a few options, various ways to stabilize this system.

One way is to add a zero into the system.

This is the PD+CP we have so far, with no Loop Filter other than the Cap in the Carge Pump:

![image](https://user-images.githubusercontent.com/95447782/164786293-6234025c-0a66-479e-8bbc-864196772969.png)


The above figure comes from the previous model that we have developed for the PD+CP ensemble. That's basically a current of "average" value <img src="https://render.githubusercontent.com/render/math?math=\frac{I_o }{2\pi}"> (the "average" and the <img src="https://render.githubusercontent.com/render/math?math={2\pi}"> come from our analysis of the PD gain) and that current is squirted into the Charge Pump cap which is Cx.

Now, the way we add one zero to that is by, instead of squirting the current into a simple cap Cx, we squirt it into a parallel combination of R+C in parallel with Cx.

![image](https://user-images.githubusercontent.com/95447782/164889342-955bd400-b036-4e16-abf4-b4296b3ca220.png)

If we simply calculate the total impedance formed by the passives, here is what we get:

(R + C) || Cx

![image](https://user-images.githubusercontent.com/95447782/164889396-039c8187-8c17-4c55-ad6f-1121501bab1b.png)


This impedance has:
* a zero at -1/RC 
* a pole at 0
* another pole at -1/[R*(C in series with Cx)] -- And please note "C in series with Cx" is a smaller value than either C and Cx.

That set of poles and zeroes looks like this in the pole-zero diagram:

![image](https://user-images.githubusercontent.com/95447782/164889401-59c3efec-244f-4512-9a0c-588308b4aadf.png)


Let's do this poles & zeroes calculation in Matlab, so we can automate this for more complex networks in the future:

>    **Matlab script:**
>
>    This [Matlab script](matlab/impedance_and_poles_of_RCCx_loop_filter.m) can be used to calculate the impedance and pole locations of a 2nd order loop filter.
>   

```matlab
%======================================================================
%==== First, a simple RC-series and RC-parallel impedance calculation:
syms R C s;
%We input the individual network elements:
Zr = R;
Zc = 1/(s*C);

%We explicit how the elements are connected (in series, in parallel, or a
%combination thereof).
%In this case we do R and C are in series.
%Zrc_series = Zr+Zc
Zrc_series = seriesz(Zr,Zc)
P = partfrac(Zrc_series, s)
C = children(P);
C = [C{:}];
[N,D] = numden(C)
poles = solve(D==0,s)
zeroes = solve(N==0,s)
%The above gives:
%Zrc_series = R + 1/(C*s)
%P = R + 1/(C*s)
%N = [R, 1]
%D = [1, C*s]
% poles = empty
% zeroes = empty


%Same thing but parallel:
Zrc_parallel = parallelz(Zr,Zc)
P = partfrac(Zrc_parallel, s)
C = children(P);
C = [C{:}];
[N,D] = numden(C)
poles = solve(D==0,s)
zeroes = solve(N==0,s)
%The above gives:
%Zrc_parallel = R/(C*s*(R + 1/(C*s)))
%P = R/(C*R*s + 1)
%N = [R, 1]
%D = [1, C*R*s + 1]
% poles = empty
% zeroes = empty
%======================================================================



%=====================================================
%==========LOOP FILTER TOTAL IMPEDANCE AND POLES CALCULATION
% Same thing as before, now for Loop Filter made of parallel combination of Cx
% with a series combination of R+C:
clear all;
syms R C Cx s;
Zr = R;
Zc = capz(C,s);
Zcx = capz(Cx,s);
Zloop_filt = parallelz(Zcx,seriesz(Zr,Zc))
Zloop_filt = simplify(Zloop_filt)
%From the above we get:
%Zloop_filt = (C*R*s + 1)/(s*(C + Cx + C*Cx*R*s))
[N,D] = numden(Zloop_filt)
%From this we can get the poles as the roots of the denominator:
poles = solve(D==0,s)
zeroes = solve(N==0,s)
%That gives us:
% poles = 
%                 0
% -(C + Cx)/(C*Cx*R)
% zeroes = 
% -1/(C*R)
%The above poles & zeroes actually match the hand calculation.
%=====================================================
```

Not how Matlab calculation matches hand calculation for the total Impedance of the Loop Filter (R+C || Cx):

Impedance of Loop Filter (R+C || Cx) by Matlab:

![image](https://user-images.githubusercontent.com/95447782/164889438-ab80db19-0d6c-4495-b986-c6c44f0eb827.png)


Impedance of Loop Filter (R+C || Cx) by hand calculation:

![image](https://user-images.githubusercontent.com/95447782/164889447-2e8105d0-c9f0-4131-88ed-74a436c686c2.png)


So, they match, this is to prove that we can automate the impedance calculation for more complex networks using Matlab's symbolic math toolbox.

Note how also the Matlab analysis done above matches the hand calculation of poles and zeroes:

With Matlab we got that:
* poles = 
*         0 --> This is the pole at DC
*         -(C + Cx)/(C*Cx*R)  -->  This is the pole at -1 / (R*C_series_with_Cx)
* zeroes = 
*         -1/(C*R) --> This is the zero at -1/RC

With hand calculation we got the same thing:

![image](https://user-images.githubusercontent.com/95447782/164889931-10dcbe59-9c1d-476f-8bd5-016459c83a8c.png)


And the visual representation of those poles and zeroes in the complex frequency plane (pole/zero diagram) is:

<img src=https://user-images.githubusercontent.com/95447782/164889670-7253b8c3-b207-4d5c-a5ca-093541ea2b34.png alt="" width="400">


If we now insert this type of Loop Filter into our system's model, now we have:

![image](https://user-images.githubusercontent.com/95447782/164889748-ac8a0df8-0baa-4a4b-b98f-b9279c6d880a.png)

Let's see if this system is stable now. For that, we do the closed loop transfer function and we look at the poles & zeroes of that.

>    **Matlab script:**
>
>    This [Matlab script](matlab/tf_of_pll_with_2nd_order_loop_filter.m) can be used to derive the closed loop transfer function of the PLL with 2nd order Loop Filter
>    


```matlab
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
```

Let's stop one second at this point. Check the Matlab code above. The nice thing about the Matlab code above is that it calculates the closed loop transfer function (TF) correctly. It gives the same Transfer Function as the manual calculation.

![image](https://user-images.githubusercontent.com/95447782/164890621-d765669f-9012-440e-ac73-f9c16b830d47.png)


That's a pretty decent result, we were able to get the same thing from Matlab Symbolic Math toolbox and by hand calculation. It's useful for future automation and quick iteration.

Ok, at this point, we have a transfer function calculated.

What we still don't know for sure is if the system is stable or not.

To prove stability, we need to estimate where the poles are for this transfer function.

```matlab
%Let's try to get poles & zeroes for the whole system:
%In the previous step we got a transfer function TF.
%In particular, we got:
% TF =
%  (Io*Kvco*(C*R*s + 1))/(Io*Kvco + 2*C*pi*s^2 + 2*Cx*pi*s^2 + 2*C*Cx*R*pi*s^3 + C*Io*Kvco*R*s)
[N,D] = numden(TF);
%The above gives:
% N = Io*Kvco*(C*R*s + 1)
% D = Io*Kvco + 2*C*pi*s^2 + 2*Cx*pi*s^2 + 2*C*Cx*R*pi*s^3 + C*Io*Kvco*R*s
% Which stacks up.
poles = solve(D==0,s)
zeroes = solve(N==0,s)
%The above gives:
% poles =
% 
% root(Io*Kvco + 2*C*pi*z^2 + 2*Cx*pi*z^2 + C*Io*Kvco*R*z + 2*C*Cx*R*pi*z^3, z, 1)
% root(Io*Kvco + 2*C*pi*z^2 + 2*Cx*pi*z^2 + C*Io*Kvco*R*z + 2*C*Cx*R*pi*z^3, z, 2)
% root(Io*Kvco + 2*C*pi*z^2 + 2*Cx*pi*z^2 + C*Io*Kvco*R*z + 2*C*Cx*R*pi*z^3, z, 3)
%
% zeroes = 
% -1/(C*R)

% The above didn't really help, as the poles answer we got is useless, it
% didn't calculate the poles for us really.

%See this link to get explicit poles values:
% https://uk.mathworks.com/help/symbolic/sym.root.html#:~:text=root(%20p%20%2C%20x%20)%20returns,the%20roots%20of%20the%20polynomial.

Poles_explicit = solve(D==0,s,'MaxDegree',3)
%The above gives some explicit poles (very long expressions).

% See below, where we do the simplification that C=10*Cx which simplifies it
% a bit.

```

The above attempt (direct calculation of poles of the TF as roots of the denominator) didn't help.

Let's try to do it with this observation: `C1 = (C*Cx)/(C+Cx)`.

![image](https://user-images.githubusercontent.com/95447782/164890690-ac1c0f63-e27b-4463-ac3e-69bb6a9e5425.png)

Obeservations are:
* C1 = C in series with Cx, it's always smaller than C and Cx independently
* If Cx is much smaller than C (let's say Cx = C/10 = 0.1*C) then we can say that:
* C1~= Cx
* C= 10*Cx.
* C+Cx=1.1C~=C
* C*Cx = C*0.1C=0.1*C^2

With the simplification that C~=Cx, our TF comes out a bit simpler, as follows:

```matlab
clear all
syms err out in LF_tf VCO_tf beta s;
syms Kvco R C Cx C1 Io pi;
assignin('base','beta',1)

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
%The above gives some explicit poles values (still very long expressions): 
%Poles_explicit = 
%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))/(((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3) + (((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3) - 1/(3*Cx*R)
%- (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))/(2*(((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3)) - (3^(1/2)*((1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))/(((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3) - (((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3))*1i)/2 - (((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3)/2 - 1/(3*Cx*R)
%- (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))/(2*(((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3)) + (3^(1/2)*((1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))/(((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3) - (((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3))*1i)/2 - (((1/(27*Cx^3*R^3) - (Io*Kvco)/(12*Cx^2*R*pi) + (Io*Kvco)/(4*C*Cx*R*pi))^2 - (1/(9*Cx^2*R^2) - (Io*Kvco)/(6*Cx*pi))^3)^(1/2) - 1/(27*Cx^3*R^3) + (Io*Kvco)/(12*Cx^2*R*pi) - (Io*Kvco)/(4*C*Cx*R*pi))^(1/3)/2 - 1/(3*Cx*R)
```

At this point, what have we achieved?

Well actually we have calculated the roots of the denominator of the TF and that is the poles.

The expressions are very long but we do have some expressions for the poles.

And those expressions are in terms of a few variables or "knobs":
* Io, Kvco, R, C, Cx.
* We just need to make R, C, Cx such that the roots of this polynomial are in the LEFT half plane.

That's all.

Let's see, as an example, a few pole locations based on R, C, Cx values.

As an example, let's use some random specific values:
* R=1K
* C=6pF
* Cx=0.6pF
* Io = 2mA
* Kvco = 100MHz/V

```matlab
clear all
syms err out in LF_tf VCO_tf beta s;
syms Kvco R C Cx Io pi;
assignin('base','beta',1)

assignin('base','R',1e3)
assignin('base','C',6e-12)
assignin('base','Cx',0.6e-12)
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

%The above gives:
% Poles_explicit =
%
%   1.0e+09 *
%
%  -1.6376 + 0.0000i
%  -0.0145 - 0.0720i
%  -0.0145 + 0.0720i
%
% Zeroes_explicit =
%
%  -1.6667e+08

%Here we plot those poles and zeroes:
zplane(Zeroes_explicit,Poles_explicit)
```

And we got a few specific poles, as follows:

![image](https://user-images.githubusercontent.com/95447782/164890804-c474cc50-0943-4a61-aeea-3d6d0e820930.png)


This is just to prove that with those "handles" or "knobs" we can get specific values for the poles of the PLL system and then it's just a case of getting parameter values that ensure the poles are on the LEFT half plane.

R and C together will determine the **"LOOP BANDWIDTH"**. What do we mean when we talk about **the all-so-famous "LOOP BANDWIDTH"**?

The Loop Filter (R+C || Cx) has:

* A pole at 0. That's a pole at DC. (s=0 is jw=0 which is DC).
* A pole at -1 / (R*C_series_with_Cx)
* A zero at -1 / RC.

Let's look again at the same figure as before. To get the Poles and Zeroes of the Loop Filter we calculated the total Impedance of the Loop Filter (R+C || Cx).

![image](https://user-images.githubusercontent.com/95447782/164890831-8f34a454-90a7-42e3-b7ae-9685978fafba.png)

Before we plug in some example values, let's analyze what we expect to see, and then we will use Matlab as a confirmation tool.

The Bode plot shape that we expect to see from this particular Loop Filter (R+C || Cx) with those poles is this:

![image](https://user-images.githubusercontent.com/95447782/164890842-8006e927-8970-49a6-9787-087efc0836c2.png)


And **THIS** is called the **LOOP BANDWIDTH**:

