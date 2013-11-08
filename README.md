BBC Micro Mode 7 frame renderer
===============================

What is it?
-----------

The idea is to take raw frames intended for the "teletext mode", mode 7, 
on BBC micros, and render them into a nice-looking PNG. The eventual 
idea is to do this for many such frames, for example where they might be 
animated.

Pushing forward and never looking back
--------------------------------------

The design decisions for this code were a little different to other 
renderers. I was trying to make something that would do the job quickly 
and would allow changes to the data at any point in the frame, not just 
scanning left-to-right. This kind of rendering isn't available just yet,
but everything is in place to make it easy to implement.

The neatest way to do it normally would probably 
be to store the locations of the control characters and when rendering 
each cell, just scan backwards along that line to see what attributes to 
use. This then is cheap to edit but expensive to render.

Instead, my code, when a control character is written, will then 
propagate the attributes along the line for later rendering. This stops 
us having to then update the characters after the new control character, 
each of which have to do a full reverse scan of the line. However, we 
need to store attributes for each character cell, and need to propagate 
for each new control character found.

Whether this actually has any noticable effect is another matter. I 
suspect for long sequences of frames as we might find in an animation, 
it might help with the render time.

Input format
------------

Really simple, 25 lines of 40 characters, in the original character set. 
Everything beyond 40 characters or after 25 lines is ignored.

Dependencies
------------

You need to have the ImageMagick convert command on your path, so the
script can convert from the ppm format to png. The Debian/Ubuntu
package is "imagemagick".

Demonstrations
--------------

Have a look at the demo directory, which has some example frames, and 
the output from them. There is also a reference directory which shows 
how the testcard frame should look.

To re-render these frames, run the m7demo program, which also serves
as a usage example.

I've been playing around with using cursor control codes to make video
from streams of characters in mode 7. There's an example stream in 
demo/animation by @puppeh for CRTC's BBC teletext video player. You 
can convert it with the m7animdemo program, but make sure you've got
the avconv program, or the whole long process will fail at the last
minute!

More example frames (or character streams) are gratefully received.

Supported control characters
----------------------------

<pre>
,------------.----------.     .---------------------.
|     hex    |  decimal |     | description         |
+------------+----------+-----+---------------------+
|    0x80    |    128   | yes | black text [1]      |
| 0x81..0x87 | 129..135 | yes | text                |
|            |          |     |                     |
|    0x88    |    136   |  no | flash               |
|    0x89    |    137   |  no | steady              |
|            |          |     |                     |
| 0x8a..0x8b | 138..139 |     | not implemented [2] |
|            |          |     |                     |
|    0x8c    |    140   | yes | normal height       |
|    0x8d    |    141   | yes | double height       |
|            |          |     |                     |
| 0x8e..0x8f | 142..143 |     | not implemented [3] |
|            |          |     |                     |
|    0x90    |    144   | yes | black graphics [1]  |
| 0x91..0x97 | 145..151 | yes | graphics            |
|            |          |     |                     |
|    0x98    |    152   |  no | conceal [4]         |
|            |          |     |                     |
|    0x99    |    153   | yes | solid graphics      |
|    0x9a    |    154   | yes | separated graphics  |
|            |          |     |                     |
|    0x9b    |    155   |     | does nothing [5]    |
|            |          |     |                     | 
|    0x9c    |    156   | yes | black background    |
|    0x9d    |    157   | yes | new background      |
|            |          |     |                     |
|    0x9e    |    158   | yes | hold graphics       |
|    0x9f    |    159   | yes | release graphics    |
`------------^----------^-----^---------------------'

            [1] not supported in many adaptors
            [2] 'end box' and 'start box', which
                'punch boxes' in the picture for 
                subtitling.
            [3] sometimes 'SO' and 'SI'
                'double width' and 'double size' in
                some adaptors. Heresy.
            [4] cancelled with a text or graphics
                colour change.
            [5] ESC (0x1A+0x80=27+128), reserved for
                compatibility with other data codes.
</pre>

To do
-----

* Flashing
* Reveal
* Write it in C or something.

See also
--------

* SAA5050 datasheet, the reference hardware:
  http://www-uxsup.csx.cam.ac.uk/~bjh21/BBCdata/SAA5050.pdf

* Rob's Teletext preservation project, the source of many of the test 
  frames (thanks Rob): http://www.teletext.org.uk/
