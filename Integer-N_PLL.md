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

What happens with that now? Now that we have the divide-by-N in the feedback? Well, the divided down version of <img src="https://render.githubusercontent.com/render/math?math=\phi_{out}">, let's call it <img src="https://render.githubusercontent.com/render/math?math=\phi_{fb}"> is very similar to <img src="https://render.githubusercontent.com/render/math?math=\phi_{ref}">. Hence the error signal, which is the output of the PD (UP and DOWN signals) toggle or update themselves at the rate of the input frequency. Hence the Loop Filter sees the same kind of input, toggling at a similar speed as before. **So the Loop Bandwidth limitation is the same as before, just 1/10 of the input frequency. Not 1/10 of the VCO output frequency, i.e. not 1/10 of N*<img src="https://render.githubusercontent.com/render/math?math=\omega_{ref}">.**



## Spurious frequencies (Spurs)

The spurs are a consequence of:



