This is a summary of the latest major changes for my code on GitHub. Last updated: 7/8/13 By Ajay Gopinath.

Master_script:
- feel free to make changes that conflict with this, any of my changes were mainly experimental
- very stripped-down version of its previous self
- pretty much just a proxy for calling Portion_segment to do the edge detection
- all analysis and other functionality commented out


Portion_segment:
- can currently run by itself as a script. comment lines 24 - 34 and uncomment line 11 (function line)
to allow it to run as a function via an external call

- preferably there should be little to no other work done here (unless discussed), as this is an area of active development
- completely rewritten: large improvements in speed (~4x as fast) and better cell detection, but still some significant bugs
- almost fully commented the code
- removed all disk output to files unless debugging
- boolean flags at the top to control debugging/output
- summary of code by section (sections are separated by "%%" comment headers):
	1) ...
	2) Calculate background image(s) - calculates mutiple background images, each for a certain section
	of the video. I find that this greatly improves cell detection when images are subtracted because
	the 'background' is more localized to the current part of the video.
	3) ...
	4) Determine which bacgkround to use - selects localized bg image
	5) Do cell detection - subtracts background from image
	6) Cleanup - cleans the image and processes it
	7) ...
	8) Set up frame viewer - if debug flag is set, it shows you the processed images. if the writemovie
	flag is set, it also writes the processed images to a movie on disk

Make waypoints:
- mainly experimental changes, feel free to make any changes to this

