
# MatLight 🚥

Matlab + Light = MatLight
This is a simple library for simulating the spectrum of LED's, Laser's and more.

### Table of contents
* [Getting Started](#getting-started)
* [Prerequisites](#prerequisites)
* [Installing](#installing)
* [Examples](#examples)
* [Built With](#built-with)
* [Authors](#authors)

## Getting Started 

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

## Prerequisites

Installation of Matlab Version R2019b.

## Installing

1. Download the MatLight.
2. Move the downloaded MatLight folder into any directory of your choice.
3. Open Matlab and choose the MatLight directory as the current directory.

## Examples

First create a light simulation:

```matlab
mySim = lightSim(1,1000,1000);
```

Create a single LED that we want to simulate with an certain certain spectral width, intensity and wavelength:

```matlab
led1 = led.led2(mySim, 'led1', 'W', 365, 20, 1e-3);
```

Create a black body radiator with a specifif optical power and color temperature:

```matlab
blackBody= blackBody(mySim, 'sun', 'W', 1, 6500);
```

Plot the spectral output of the created sources:

```matlab
led.plotAll(blackBody);
```

## Built With

* [MATLAB](https://www.mathworks.com/products/matlab.html) - Version R2019b

## Authors

* **HanSur94** - [HanSur94](https://github.com/HanSur94)
