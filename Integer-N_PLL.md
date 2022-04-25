# Integer-N frequency synthesis PLL

First of all, a couple of definitions about PLLs.

## PLL lock range

It's the range of input frequencies that the VCO will be able to lock to.

If the input reference oscillator given to the PLL is outside of that frequency range, the VCO won't be able to lock to it.

In real life, when designing a PLL you will have to center the lock range across PVT so that it will be reasonably well centered around the expected input reference frequency.

![image](https://user-images.githubusercontent.com/95447782/165133113-a5c7e713-563f-4838-9bef-7a02a2eb76f1.png)



## PLL settling time

It's worth talking a bit about settling time. This is important because:

* If the base station asks you to go to a specific frequency, you have to change to that frequency quickly, in a given amount of time. Hence the PLL has to be able to settle from whatever frequency it is at to a new frequency quick enough. So there will be a spec for settling time based on that.
* Settling time is not just getting to a target frequency, but in particular getting to that target frequency with a certain level of jitter and that means the loop is more accurately settled at the final frequency.

![image](https://user-images.githubusercontent.com/95447782/165132927-85dcfdbf-5806-4e42-98f1-0b55b61080d4.png)

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


![image](https://user-images.githubusercontent.com/95447782/164892283-cdd5929d-5afd-4d41-aa2b-6df55c2c5759.png)




The following figure shows the reasoning that LOWER Loop Bandwidth rejects spurs more (attenuates them more).

![image](https://user-images.githubusercontent.com/95447782/164892168-751e3950-b421-45c0-b157-87104659daf6.png)



A bit more reasoning about this:
* If Loop BW is 1/10 of fref,  (1/10 of fref is 1/R[CCx/(C+Cx)]). Then from that frequency onwards, the loop starts to attenuate higher frequencies at -20dB/decade, that is, a decade from that point is 10x that frequency, which is fref, so any signal or glitch at fref is attenuated by the Loop Filter by -20dB.
* If we double C+Cx, that is halfing the Loop BW, then the attenuation at fref is twice as much, which is 6dB more attenuation, so -26dB attenuation instead of -20dB.
* So, if we double the Caps, we half the Loop Bandwidth, then the size of these voltage spikes becomes half.

However, **the trade-off is** that while REDUCING the Loop BW provides better spur magnitude reduction (better spur rejection), the downside is that we know that the VCO output mimics the reference oscillator over a smaller range of frequencies, i.e. over a narrower band in the spectrum plot, and that means the high VCO phase noise is present over more frequencies at the PLL output.


![image](https://user-images.githubusercontent.com/95447782/164892301-502b3bc1-6d69-429f-acd1-9773f9d51131.png)



Overall, the trade-offs are:

**Better spur attenuation:**
* Reduce the Loop BW
* Make better matching of CP currents
* Make lower gate delay and flip flop reset delay

**Better PLL output phase noise:**
* More Loop BW

**Better settling time:**
* More Loop BW


These trade-offs happen in the Integer-N division.

Can we make our life easier with a different topology? **That's the fractional-N topology**.


## Channel raster in the Integer-N synthesizer

One last thing before moving on:

In the Integer-N frequency synthesizer, the input reference clock IS EQUAL TO THE CHANNEL SPACING or channel raster. That means that we want a system that:

* Produces an output frequency between 900MHz up to 1.1GHz in steps of 1MHz.
* When the base station asks you to go to a new frequency (channel) you change the value of N and that sets the output frequency to a new channel.
* **Channels are spaced out 1MHz apart. That's the channel raster.**
* If you set N = 900, you get 900MHz, if N=901 you get 901MHz, if N=1100 you get 1.1GHz. Output frequency changes in steps of 1MHz which is the channel separation.
* **The input reference frequency is the channel raster (1MHz).**

![image](https://user-images.githubusercontent.com/95447782/164894164-3c3abd1b-32c3-45f9-9533-f6afe40fa81f.png)


But the problem with this arrangement (integer-N) is that:
* The reference oscillator is the channel raster (1MHz) 
* Since what goes into the PD is at fref, spurs come out at multiples of fref, i.e. at the channel spacing.
* At every channel you get a spurious tone (bad).
* The loop bandwidth is limited to a fraction of the channel spacing (fref). Can't make it higher than that.


**What if N doesn't have to be an integer? If N can be fractional:**
* If N can be fractional, like instead of 900, 901, 902 we can divide by 90.0, 90.1, 90.2...
* Then the reference oscillator doesn't have to be 1MHz (the channel spacing). Because we make reference oscillator something like 10MHz, and we still get 1MHz steps at the output, thanks to the multiplication by decimals, like x90.1 gives 901MHz out, x90.2 gives 902MHz, etc.


The benefit is:
* The reference oscillator is no longer the channel separation.
* The Loop Bandwidth upper limit is 1/10 of what goes into the PD. And since now we have 10MHz going into the PD instead of 1MHz, the Loop Bandwidth upper limit is higher. Before, upper limit for Loop Bandwidth was 1/10 of 1MHz, now it's 1/10 of 10MHz. We can therefore make the Loop Bandwidth 10x larger. Thus we get the benefits of larger loop bandwidth (better phase noise at the output, better settling time) WITHOUT bigger spurs, since spurs are higher frequency than before (10x higher), they are attenuated more by the Low pass filter (10x more attenuation) so overall they are the same. The VCO will have lower requirements in terms of its free-running VCO phase noise so it will be easier to design.
* POSSIBLE BENEFIT, (but we are not sure yet, this will be analyzed in next section): Since what goes into the PD is 10MHz instead of 1MHz, the spurs come out at multiples of 10MHz, not at multiples of 1MHz. So we won't get a spur tone in every channel, but every 10 channels. This is still a QUESTION MARK, this will ONLY BE TRUE if the FEEDBACK SIGNAL (divided-down version of the output) is a signal that toggles at 10MHz, and we still don't know if this is the case, as the divide-by-fraction block is still a black box to us, we don't know the exact implementation of it. If its output is something that toggles at 10MHz, then yes this benefit will be true, otherwise not really, the spurs will come out at whatever is the periodicity of the PD output.

That will be the fractional-N synthesizer.

## Fractional-N PLL
Next:

[Fractional-N PLL loop](/Fractional-N_PLL.md)
