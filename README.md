# Digital Simplicity

A simple and elegant watchface for round Garmin devices. Currently only supports round watches that have a screen resolution of 240x240px.

Digital Simplicity is available on [Garmin's Connect IQ store](https://apps.garmin.com/en-US/apps/97b91745-9287-421d-aa8a-abb437e08eea).

# FAQ

## The watch-face doesn't work!

If you encounter any issues whilst using this watch-face, I definitely want hear about them - but I need a little help from you. If you can follow [these instructions from Garmin](https://developer.garmin.com/connect-iq/programmers-guide/how-to-test/#handlingcrashes) to obtain your CIQ_LOG.YAML file, and include that along with the device you have and any configuration settings you were using at the time (top and bottom bar, 12/24 hour watch style, etc.), it will help me fix any lingering bugs that might occur from time to time.

## What does the number next to the bluetooth symbol mean?

It is the number of notifications on the connected device. Hiding this in a latter update is planned.

## How performant is this watch-face?

TL;DR: to optimise battery usage, disable blink colon (which increases the power usage a little) and do not display seconds (increases power usage significantly).

The main settings that affect the usage of battery by this watchface are blink colon and show seconds. Based upon the watchface diagnostics in the Connect IQ Device Simulator, enabling blinking seconds increases the time taken to display the watchface by approximately half a percent. Displaying seconds, in comparison, will result in approximately a 34% increase in time taken. The watchface is written to be relatively performant - so these are not huge increases - but it may be worthwhile to know if your device has very poor battery life, it may be useful to know.

Based on my testing of the various top and bottom value options, none of them currently significantly affect battery usage. 

## What features are planned for this watchface?

Check the [issues on GitHub to see the current TODO](https://github.com/kelnage/digital-simplicity/issues). Contributions would be more than welcome!
