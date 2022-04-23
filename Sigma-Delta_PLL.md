# Sigma-Delta modulation in fractional-N PLL loops

Very basic sigma-delta modulation concept:

![image](https://user-images.githubusercontent.com/95447782/164894968-4148456b-829f-4e43-98e7-905b7e5a960f.png)

Look at the bottom drawing in the above figure, the one with the integrator.

We start with the important premise that the input x(t) is a Low Pass signal (i.e. a signal that only has frequency components from DC up to some low-ish frequency relatively speaking).

Let's say x is a DC signal.

The error signal "e" is fed into the integrator. If the error signal "e" is anything but 0 (i.e. it's a small positive or negative amount) then the integrator's output will start to integrate it as time goes on, so it will start to climb up, it will start to increase voltage until it becomes huge or infinite... Since the integrator's output will be finite, it means that forcefully the error signal will have to be 0. It's like the integrator squeezes the error signal down to 0. So the output ON AVERAGE matches the input. ON AVERAGE IS THE KEY WORD HERE. The output will be a digital signal that is switching up and down at a certain high speed with a certain spectrum and blah blah blah BUT ON AVERAGE, IT'S AVERAGE VOLTAGE WILL BE THE SAME AS THE VALUE OF THE INPUT WHICH IS A DC VALUE IN THIS EXAMPLE.

Since I already know my input signal is a low pass signal, I can ignore the high freq spectrum of the output, if I just look at its spectrum I will see it has the same DC component as my DC input.

If we have a 1-bit ADC at the output, which is just like an buffer which rails all the way up to VDD or all the way down to GND, that output will be switching up and down like a PWM but it's average will be equal to the input x.

Basic idea of the Deta-Sigma is this:
* Since you have an A/D converter at the output, that adds Quantization noise to the output. We model that as q.
* You have a loop filter which can be your integrator or something like that. The point is that the transfer function of your integrator (H) or whatever block you put there, **H must have very large gain at low frequencies (if input is low frequency, output becomes very large) and near zero gain at high frequencies (if its input is high frequency, its output is zero).**
* Then you do the calculations at low and high frequency inputs, and you get that the output Y will be, at low frequencies, the input signal, and at high frequencies, just the quantization noise.
* So, overall you have put together a system that **pushes (shapes) the quantization noise up to high frequencies and keeps a copy of the input at low frequencies.**
* The Sigma-Delta name is because the integrator is like a sum (summation, Sigma <img src="https://render.githubusercontent.com/render/math?math=\Sigma">) and the comparison block at the input, the one that generates the error signal, that's a difference, so Delta <img src="https://render.githubusercontent.com/render/math?math=\Delta">.

![image](https://user-images.githubusercontent.com/95447782/164895037-4a87b8c4-1308-4dcc-9c39-5a15f0b13111.png)


Then the output spectrum, Y looks like this:

![image](https://user-images.githubusercontent.com/95447782/164895042-2d45cf4f-8fb7-4b4e-91ed-3329bd9b8c84.png)


Where N is the order of the modulator, or the order of the transfer function H.

Then you can make H as complicated as you want, 2nd order, 3rd order, multi feedback etc...

We don't care about any of that here.

Just keep the basic concept of the Sigma-Delta.


The **RESTRICTION of the Sigma-Delta converter is that the input signal is a low frequency signal**, it's a signal that is not changing very fast, it's not a signal that changes anywhere as fast as the sampling frequency.

Now, for the PLL in particular, the Sigma-Delta modulator will have the following specific characteristics:
* The input "x" is a digital number with a bunch of bits, like k bits."x" is a number like 0.1, 0.2, 0.3... And this number stays static during the operation, so it's like a DC signal, a pure static value.
* H is a digital filter, discrete time, discrete signals.
* The PLANT just selects the MSB and discards the rest. That's essentially what a "1-bit Quantizer" does.

This is what such Sigma-Delta looks like, with a generic H inside it. We will define H in a second.

![image](https://user-images.githubusercontent.com/95447782/164895078-b7b54f05-9c35-40fa-92ed-1f1e79b7541e.png)


In that block, the error block is a simple digital adder (substraction).

For H, we said we wanted something that has low gain at DC and very high gain at high frequencies.

And that is what an accumulator does.

![image](https://user-images.githubusercontent.com/95447782/164895084-2349a82b-2029-43fb-9d5a-7486573f1f2b.png)

If we pick the output after the register, we have simply a delayed version of that output, so we get the same transfer function just multiplied by z^-1.

Here we calculate that case:

![image](https://user-images.githubusercontent.com/95447782/164895106-4602a94f-31ab-407f-9fd9-cc8fa19a4a19.png)

In our case we are going to take the output AFTER the register (y) just because it suits us best and the math will work out to something nicer.

In our case we are going to take the output AFTER the register (y) just because it suits us best and the math will work out to something nicer.

Then the overall Sigma-Delta loop transfer function is:

![image](https://user-images.githubusercontent.com/95447782/164895111-90f1b380-4eb5-4bb9-8051-d33dd06cf17f.png)


So we got that overall the Sigma-Delta output transfer function is:

![image](https://user-images.githubusercontent.com/95447782/164895114-f48eeaba-3bd9-465e-9754-31d831a292c2.png)


And turning that into the time domain, the time-domain output series is:

![image](https://user-images.githubusercontent.com/95447782/164895118-23065722-a08c-4155-b409-2d85980aaa2b.png)


So the output of the Sigma-Delta is the previous input plus the difference between the current quantizer output minus the previous quantizer output.

1 - z^-1 is a high pass function, because if there is a change in quantization noise it goes through, but if there isn't then the output is zero.

BUT the above time series equation is NOT USEFUL in order to calculate the output stream coming out of the Sigma-Delta.

In order to calculate the Sigma-Delta output stream what we do is we replace the accumulator with its actual circuit model, and we calculate every sample, sample by sample, clock cycle by clock cycle. It's not very difficult once you do a clock cycle or 2 you can do them all.

![image](https://user-images.githubusercontent.com/95447782/164895148-a433f3c6-18c5-4dee-bc08-7a24c0ca5d25.png)


Overall we get that the output of the Sigma-Delta is, for an input of 0.1 (for example) the same average value 0.1, but PWM-modulated which is what we wanted.

HOWEVER we find that AGAIN **this particular Sigma-Delta STILL HAS PERIODICITY to its output. And that's because this is a FIRST order** Sigma-Delta. **If you replace it by a 2nd order (just change the H by a 2nd order one), the periodicity goes away.**

We have made this Sigma-Delta 1st order just to see how this works.

If you leave it as 1st order, you will get spurious frequencies for the same reason as before, due to the periodicity and the spectrum would look like this.

![image](https://user-images.githubusercontent.com/95447782/164895293-74ecd603-3fa7-4ad0-a9b8-835b70b613a3.png)


But as soon as you make it 2nd order then the spurious tones go away (because of no periodicity) and you also get more slope in the noise shaping (40dB/dec instead of 20).

![image](https://user-images.githubusercontent.com/95447782/164895299-51c71d23-4d10-4139-a993-01e72d5767a1.png)


So for PLLs you don't need a very fancy Sigma-Delta, you can just use a 2nd order one made with integrators, that's all.

That spectrum is the spectrum of the "CONTROL" signal that governs whether the fractional divider should divide by 90 or by 91, in order to get 90.1 division and hence achieve 901MHz out.

![image](https://user-images.githubusercontent.com/95447782/164895318-88e33906-ea39-4018-9d3e-a2c29b4a7326.png)


Now if that is the spectrum at the "CONTROL" wire, what is the spectrum at the VCO output? Since that's what we care about.

The VCO output will just look like a modulated version of that signal, which is the spectrum centered around fout and the quantization noise on the sides of it.

![image](https://user-images.githubusercontent.com/95447782/164895330-870a9635-e488-44c2-9784-563080854360.png)


Within the Loop Bandwidth (magenta arrows), the output of the VCO will mimic the phase noise of the reference oscillator.

Outside the Loop Bandwidth, the VCO phase noise will appear.

Knowing this, what should be the REQUIREMENT for our Sigma-Delta modulator spectrum shape?

The answer is we should keep the Sigma-Delta output noise as low as possible within the Loop Bandwidth, so we need to design our Sigma-Delta modulator to have a certain signal to noise ratio (a small enough noise) within that Loop Bandwidth.

![image](https://user-images.githubusercontent.com/95447782/164895341-7d92e7ee-dfcd-4e20-b94c-7c65dce33d3a.png)


In the example where Loop Bandwidth is 1MHz, it means that in the 0 to 1MHz region we need to keep the Sigma-Delta modulator to be low noise enough. Outside of that, i.e. higher than 1MHz, the Sigma-Delta noise can be high, we don't care.

So that makes the Sigma-Delta modulator a bit less simple, maybe it can't be as simple as 2nd order like we said before, maybe we need to make it 3rd order for this reason, or maybe we need to insert a zero. But this is what may make the Sigma-Delta a bit more complex. If you have to make your H 3rd order then you will need to burn more power in your H digital filter, also more area in it, the implementation will have to include more adders, multipliers, maybe you can implement it with just shift operations, you will need more bits inside it so it's precise, in summary you will have to burn area, power and man hours in the Sigma-Delta modulator for this reason.

A **rough idea of how much SNR you need in the Sigma-Delta modulator** is the following, and it's just a rough idea, the maths to prove it are quite involved, but just as a rough finger in the air estimate:

* if you need less than 100dBc/Hz @ 1MHz offset on your VCO output, then in the Sigma-Delta you need 100dB less noise (quantization noise) than signal at 1MHz. (rough estimate)

But as a result of all of this, you will have a 3rd order Sigma-Delta modulator which will not only be free of spurs (because it has no periodicity) but also it will have low enough noise within the Loop Bandwidth so your VCO output will be clean enough within the Loop Bandwidth, and your Loop Bandwidth will be larger thanks to your fractional division.

Other than that, if you just wanted to put together a PLL loop quickly and see basic functionality, 2nd order Sigma-Delta will work.

