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




