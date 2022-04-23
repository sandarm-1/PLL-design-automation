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
[Sigma-Delta modulation in fractional-N PLL loops](/Sigma-Delta_PLL.md)
