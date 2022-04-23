# Integer-N frequency synthesis PLL

First of all, a couple of definitions about PLLs.

## PLL lock range

It's the range of input frequencies that the VCO will be able to lock to.

If the input reference oscillator given to the PLL is outside of that frequency range, the VCO won't be able to lock to it.

In real life, when designing a PLL you will have to center the lock range across PVT so that it will be reasonably well centered around the expected input reference frequency.

![image](https://user-images.githubusercontent.com/95447782/164891587-b6f9058c-7ce3-4b91-a69f-41a66b1bd4de.png)



## PLL settling time

It's worth talking a bit about settling time. This is important because:

* If the base station asks you to go to a specific frequency, you have to change to that frequency quickly, in a given amount of time. Hence the PLL has to be able to settle from whatever frequency it is at to a new frequency quick enough. So there will be a spec for settling time based on that.
* Settling time is not just getting to a target frequency, but in particular getting to that target frequency with a certain level of jitter and that means the loop is more accurately settled at the final frequency.

![image](https://user-images.githubusercontent.com/95447782/164891594-c8e7ee1f-dda9-47c2-8bdc-d194644539b4.png)

* **Settling time is LESS (FASTER) if Loop Bandwith is MORE.** Because a Loop Filter with LOWER Loop Bandwidth (lower cuttoff frequency) is LESS RESPONSIVE to changes, given a step input (that's the request to go from one freq to a new one) it will be slower to adapt from one frequency to a new one. Like an RC filter with larger RC time constant.



## Integer-N frequency synthesis
Up until now we had unitary feedback.

Will the PLL loop work if we put a divide-by-N in the feedback path? Yes of course it will work.

![image](https://user-images.githubusercontent.com/95447782/164891610-fc8a2cfb-01d8-4dc7-ad5b-381f0fcee806.png)


But what's the new relationship between <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> and <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}">?

Well, the feedback loop ensure that the ERROR signal is very small. Hence <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}"> will be regulated to <img src="https://render.githubusercontent.com/render/math?math=N*\phi_{ref}">.

Since <img src="https://render.githubusercontent.com/render/math?math=\omega_{\mathrm{out}} =\frac{d}{\mathrm{dt}}\phi_{\mathrm{out}}"> then <img src="https://render.githubusercontent.com/render/math?math=\omega_{\textrm{out}} =N*\omega_{\textrm{ref}}">. So the output frequency will be N times the input frequency.

![image](https://user-images.githubusercontent.com/95447782/164891700-bb5109ee-f36b-46e7-a63c-31444f017aca.png)


**Now remember the Loop Bandwidth limitation that we imposed, we said that Loop Bandwidth of the Loop Filter had to be at most 1/10 of the input frequency.**

Whay did we say that? Because otherwise we could not make the assumption that the PD+CP block output is an APPROXIMATION of the AVERAGE value of "UP-DOWN" differential signal which is the ERROR signal. Because the PD+CP block output is actually the INTEGRAL of the error signal and not the AVERAGE of the error signal, but if the Loop Filter has a low enough bandwidth (less than 1/10 of input frequency) then it will be slow enough, it will update/correct the VCO slowly enough that the VCO output will remain still for a good amount of time, like at least 10 periods of the input signal, hence the INTEGRAL coming out of the PD+CP block is similar enough to the AVERAGE of the error signal.

What happens with that now? Now that we have the divide-by-N in the feedback? Well, the divided down version of <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}">, let's call it <img src="https://render.githubusercontent.com/render/math?math=\phi_{fb}"> is very similar to <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}">. Hence the error signal, which is the output of the PD (UP and DOWN signals) toggle or update themselves at the rate of the input frequency. Hence the Loop Filter sees the same kind of input, toggling at a similar speed as before. **So the Loop Bandwidth limitation is the same as before, just 1/10 of the input frequency. Not 1/10 of the VCO output frequency, i.e. not 1/10 of <img src="https://render.githubusercontent.com/render/math?math=N*\omega_{ref}">.**



## Spurious frequencies (Spurs)

The spurs are a consequence of:

* When the VCO is in PERFECT LOCK, the PD output UP-DOWN should be exactly 0, right? Not really.
* In an ideal world PD circuit UP and DOWN signals are never supposed to be high at the same time, because when UP and DOWN are both high then the AND gate is supposed to clear (reset) the flip flops immediately. But due to the non-zero delay of the AND gate and the clear operation, both UP and DOWN are high for a small time called <img src="https://render.githubusercontent.com/render/math?math=\delta">.
* Also, the currents in the CP are not exactly matched. Io at the top and bottom are not exactly the same. They will always be mismatched by an amount <img src="https://render.githubusercontent.com/render/math?math=\Delta I_o">. Top current is <img src="https://render.githubusercontent.com/render/math?math=I_o +\frac{\Delta I_o }{2}"> and bottom current is <img src="https://render.githubusercontent.com/render/math?math=I_o -\frac{\Delta I_o }{2}">.
* The extra current <img src="https://render.githubusercontent.com/render/math?math=\Delta I_o"> goes into the Cap during a time <img src="https://render.githubusercontent.com/render/math?math=\delta"> and causes a voltage increase on the Cap (i.e. on Vcontrol) of size <img src="https://render.githubusercontent.com/render/math?math=\Delta V=\frac{\delta {*I}_o }{C+\textrm{Cx}}">. Because from fundamentals Q=CV and I=dQ/dt=C*<img src="https://render.githubusercontent.com/render/math?math=\Delta V/\Delta t">. Therefore <img src="https://render.githubusercontent.com/render/math?math=\Delta V=\Delta t*I/C"> and in our case <img src="https://render.githubusercontent.com/render/math?math=\Delta t"> is <img src="https://render.githubusercontent.com/render/math?math=\delta">, I is Io and C is C+Cx.
* This voltage glitch on Vcontrol happens WHEN THE VCO IS IN PERFECT LOCK at a periodicity of Pref or at a frequency of fref.
* Hence ideally when the VCO is in perfect lock Vcontrol should be a perfectly static value, like a DC value, and hence its spectrum should be a pure impulse at DC. But in reality it does have these periodic glitches happening at fref, so the Vctrl spectrum shows tones at fref and all its multiples (all its harmonics).
* Hence the VCO output spectrum is not an ideal impulse at N*fref, but it has tones on its sides, separated at multiples of fref. **Those are the SPURS.**
* But the good news is that the Loop Bandwidth is 1/10 of fref and within that bandwidth the VCO output will mimic the reference oscillator hence the VCO out will be nice and clean within that band. Outside of that band, there will be the spurs. **So, what is better to maximize spur rejection, LARGE Loop Bandwidth or SMALL loop bandwidth?**. The reasoning is simple: the spurs come at fref and multiples of fref, the Loop BW is 1/10 of fref, hence by definition the spurs are always above the filter's cuttoff, i.e. the filter always attenuates the spurs (the spurs are just voltage glitches in Vctrl), the question is how much, and since it's a low pass filter, lower cuttoff frequency attenuates the spurs more (remember spurs are just voltage glitches in Vctrl), so LOWER Loop Bandwidth attenuates spurs more, i.e. it makes the voltage glitches smaller. Since the magnitude of the voltage glitches is <img src="https://render.githubusercontent.com/render/math?math=\Delta V=\frac{\delta {*I}_o }{C+Cx}"> , making C+Cx larger reduces the voltage spikes, that is REDUCING the Loop Bandwidth, since the Loop Bandwidth is equal to the 2nd pole of the Loop Filter which is 1/R*C_series_with_Cx.


![image](https://user-images.githubusercontent.com/95447782/164892180-4257d237-9c2e-44da-a318-11b7bee17f4f.png)



The following figure shows the reasoning that LOWER Loop Bandwidth rejects spurs more (attenuates them more).

![image](https://user-images.githubusercontent.com/95447782/164892168-751e3950-b421-45c0-b157-87104659daf6.png)



A bit more reasoning about this:
* If Loop BW is 1/10 of fref,  (1/10 of fref is 1/R[CCx/(C+Cx)]). Then from that frequency onwards, the loop starts to attenuate higher frequencies at -20dB/decade, that is, a decade from that point is 10x that frequency, which is fref, so any signal or glitch at fref is attenuated by the Loop Filter by -20dB.
* If we double C+Cx, that is halfing the Loop BW, then the attenuation at fref is twice as much, which is 6dB more attenuation, so -26dB attenuation instead of -20dB.
* So, if we double the Caps, we half the Loop Bandwidth, then the size of these voltage spikes becomes half.

However, **the trade-off is** that while REDUCING the Loop BW provides better spur magnitude reduction (better spur rejection), the downside is that we know that the VCO output mimics the reference oscillator over a smaller range of frequencies, i.e. over a narrower band in the spectrum plot, and that means the high VCO phase noise is present over more frequencies at the PLL output.
