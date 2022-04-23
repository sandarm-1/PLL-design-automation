# Fractional-N frequency synthesis PLL

What's the limitation of the Integer-N and why would we need a Fractional-N synthesizer?

## Motivation for the Fractional-N synthesizer: Channel "raster" in the Integer-N synthesizer

In the Integer-N frequency synthesizer, the input reference clock IS EQUAL TO THE CHANNEL SPACING or channel raster. That means that we have a system that:
* Produces an output frequency between 900MHz up to 1.1GHz in steps of 1MHz.
* When the base station asks you to go to a new frequency (channel) you change the value of N and that sets the output frequency to a new channel.
* **Channels are spaced out 1MHz apart. That's the channel raster.**
* If you set N = 900, you get 900MHz, if N=901 you get 901MHz, if N=1100 you get 1.1GHz. Output frequency changes in steps of 1MHz which is the channel separation.
* **The input reference frequency is the channel raster (1MHz).**


![image](https://user-images.githubusercontent.com/95447782/164894395-ddeeae6b-e63e-4560-a701-086c0054a72d.png)


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
* POSSIBLE BENEFIT, but we will have to check if this is the case: Since what goes into the PD is 10MHz instead of 1MHz, the spurs come out at multiples of 10MHz, not at multiples of 1MHz. So we won't get a spur tone in every channel, but every 10 channels. This is still a QUESTION MARK, this will ONLY BE TRUE if the FEEDBACK SIGNAL (divided-down version of the output) is a signal that toggles at 10MHz, and we still don't know if this is the case, as the divide-by-fraction block is still a black box to us, we don't know the exact implementation of it. If its output is something that toggles at 10MHz, then yes this benefit will be true, otherwise not really, the spurs will come out at whatever is the periodicity of the PD output.



That is the fractional-N synthesizer.


## Implementation of the fractional divide-by-K
This is how we can make a divide-by-K where K is fractional (like 2.5, 2.6...).

![image](https://user-images.githubusercontent.com/95447782/164894445-6dc4fea8-47e3-4022-b521-110e2aeb6890.png)

To implement a divide by 2.5 (as an example) we make a circuit that first divides by 2 during 2 cycles and then divides by 3 during 3 cycles.

![image](https://user-images.githubusercontent.com/95447782/164894535-c6efb989-5e05-4dea-bfdb-0b3348f7c96f.png)


Now what's the frequency of the spurs in this arrangement?

In the previous analysis the spurs come out at a periodicity of 5 seconds or a frequency of 1/5Hz, for a VCO output frequency of 1 Hz and a reference frequency of 1/2.5 Hz, for a K division factor of 2.5. So the spurs are not coming out not at fref but at a frequency defined by fout and K, in particular we will see later that the freq of the spurs is fout/(m+k) where in this case that's fout/(2+3)

![image](https://user-images.githubusercontent.com/95447782/164894546-c2481ef9-f471-42f0-8512-d722d8e5477a.png)


![image](https://user-images.githubusercontent.com/95447782/164894549-6a36a2cb-375f-4f7c-9c17-66f67b6ac90a.png)


In the xample with K=2.5, spurs frequency is fout/5 which in this examples happens to be 1/2 of fref. However this it's not ok to generalize that the spurs frequency will always be 1/2 of fref regardless of K value. The correct generalization is that different K values will yield different periodicity of the spurs. See generalization below, the spurs freq will be fout/(m+k) where m+k depend on K.

**"Net period"** is the period of the fractionally-divided-down version of VCO out.

**Generalized formula for how to divide by any fractional number:**

![image](https://user-images.githubusercontent.com/95447782/164894591-a08d88ee-8144-4805-a898-04cf4ec13236.png)


Here we define:
* **"net period"** (of the fractionally-divided-down version of VCO out) = STRICTLY SPEAKING, the period of the fractionally-divided-down version of VCO out, but bear in mind that this "net period" is not a "classic square wave period", as it contains MORE THAN ONE RISING EDGE AND MORE THAN ONE FALLING EDGE, because of the "k cycles where it divices by N" and "m cycles where it divides by N+1".
* **"average period"** (of the fractionally-divided-down version of VCO out) = "inverse of the AVERAGE FREQUENCY" = the equivalent frequency the signal would have if it was a classic square wave.

Here we can see the definition of "net period" and "average period":

![image](https://user-images.githubusercontent.com/95447782/164894635-0c71dee8-76d8-40fc-baae-ce7ecf165835.png)


To be clear, "fundamental for spurs" is the frequency of the spurs, and that's the INVERSE of the periodicity (PERIOD) of the PD output, i.e. the periodicity at which the PD output sequence of pulses repeats itself, and that is fout/(m+k), that PERIOD is the "Net period". So, "fundamental for spurs" = "1/Net period". So when we say "Net period" we are also saying "Spurs period".

**The period of the spurs is the "Net period" of the fractionally-divided-down-version of the VCO output.**
 
In particular for the K=2.5 example: (a=1, b=1, N=2 yields K=2.5)

![image](https://user-images.githubusercontent.com/95447782/164894664-ba9d431a-656d-4a78-9dba-ccba5a1187ce.png)

Overall, the division is by a number that is larger than N and smaller than N+1.

N is the **integer part**, b/(a+b) is the **fractional part.**

![image](https://user-images.githubusercontent.com/95447782/164894700-fcc4d585-843b-4389-9e8d-9ed257a5bef7.png)


N can be a large number, like 100 or 1000, etc.

In particular for the previous example where we wanted fout to be from 900MHz to 1.1GHz with a channel raster of 1MHz, with reference oscillator at 10MHz, we need K to be from 90.0 to 110.0.

For that example, simply make N programmable from 90 to 110, then to achieve the decimals (0.1, 0.2, 0.3 up to 0.9) you make a programable from 1 to 10 and b programmable from 10 to 1, where always you have that a+b=10.


![image](https://user-images.githubusercontent.com/95447782/164894709-27fb0aac-f958-4f27-9bff-465ae65c691c.png)


From those values we can calculate the spurs frequency, or their period, which we call "Net period".

![image](https://user-images.githubusercontent.com/95447782/164894716-ddf8102b-c027-4ad9-943b-875a62633093.png)


Swapping in the specific numbers for this case (a+b=10, N=90 to 110) we obtain that it just so happens that the spur frequency happens to be precisely fref/10, so 10MHz/10 = 1MHz, which is exactly the channel raster again, like in the integer-N example. Also it is just at the edge of the Loop Bandwidth which we had set to 1MHz so the spurs would come through the Loop Filter bandwidth if we left the Loop Bandwidth at 1MHz (10x the integer-N).

And, it's quite important to note, THIS IS NOT JUST IN THIS SPECIFIC EXAMPLE (THE FACT THAT THE SPURS HAPPEN TO COME OUT EXACTLY AT THE CHANNEL RASTER IN THIS FRACTIONAL-N DESIGN). This happens for this implementation of the fractional-N divider, regardless of the values of N, a and b.


## Recap and compare Fractional-N versus Integer-N
Let's recap and compare:

![image](https://user-images.githubusercontent.com/95447782/164894780-cf595a59-e2d8-4757-bf97-c742384627cc.png)


So the spurs is the main thing breaking the Fractional-N. **Can we fix the spurs problem?**

The spurs problem is caused by the divide-by-fraction implementation.

Let's change that.


**The spurs are happening in the current fractional-N because we are creating a signal** (fractionally-divided-down-version of the VCO out) **that has a clearly defined periodicity to it.**

It's a characteristic that comes from how we have implemented the fractional-N division. Because we have done it in a way that it's periodic. We always do the same, just divide by N during a*N cycles, and then divide by N+1 during b*(N+1) cycles, repeat again...

So, we have been just applying a "dummy" digital controller which tells it to divide by 90 during say 810 cycles, then divide by 91 during the next 91 cycles, over and over again... **ESSENTIALLY, the signal that chooses N or N+1 is a PWM modulated signal, so the average number by which we end up dividing is a fractional number.**

Repeat again, **ESSENTIALLY, the signal that chooses N or N+1 is a PWM modulated signal, so the average number by which we end up dividing is a fractional number.**

This is what we have at the moment:

![image](https://user-images.githubusercontent.com/95447782/164894855-8d43630f-26ee-4b9c-946b-4f94cd23067b.png)


That's what our current fractional-N divider is doing, **we already have that PWM modulation going on, and that is fine, but the problem is that we are doing that PWM modulation BY COUNTING CYCLES IN A CYCLICAL WAY.** That's what the fractional-N divider is doing, and that cyclical way, that repeatability, that periodicity, is what creates the periodic spurs.

So, how can we do this PWM modulation a better way without this predictable cyclical nature?


## Sigma-Delta modulation

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

