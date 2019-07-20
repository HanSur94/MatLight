function amp = LedAmp(cd, dcycle, v, angle, num)


amp = cd * A2Sr( angle ) / 683  / v * num * dcycle;  

end

