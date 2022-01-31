# Bogi-trip-iOS
iOS version of [Bogi Trip](https://github.com/tymwitko/Bogi-Trip).

## Description
Swift iOS app for randomizing the trip destination within selected distance. Inspired by a school trip idea by Piotr Bogucki.

### Features
- randomizing destination within a selected range
- route calculation
- turn-by-turn navigation (text only)

## Usage
Upon running (with location permissions enabled) you should see your location on the center of the screen:

![](https://media.discordapp.net/attachments/420283310833664002/937852864305463367/Zrzut_ekranu_2022-01-31_o_16.58.45.png)



After selecting the minimum and maximum range, a preview of those constraints is displayed. The red circle symbolizes the minimum range and the purple circle is the maximum range.

![](https://media.discordapp.net/attachments/420283310833664002/937852864724873326/Zrzut_ekranu_2022-01-31_o_17.02.05.png)


If the selected area suits your needs, press ![](https://media.discordapp.net/attachments/420283310833664002/937852863542079528/rand_butt.png) to generate a pseudo-random destination. The route from your location is calculated automatically.

![](https://media.discordapp.net/attachments/420283310833664002/937852864993304626/Zrzut_ekranu_2022-01-31_o_17.02.52.png)

In order to re-center your location on the map, press ![](https://media.discordapp.net/attachments/420283310833664002/937852863261073528/loc_butt.png).
If you stray from the desingated path, the app should recalculate your route automatically.
If it doesn't, press ![](https://media.discordapp.net/attachments/420283310833664002/937852863865036830/refr_butt.png) to manually force a route recalculation.

### Have a nice Bogi Trip!
