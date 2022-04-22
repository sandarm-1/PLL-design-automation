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



