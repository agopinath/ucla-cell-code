July 20th, 2013
Cell Tracking Code

Updated by Sam Bruce, Ajay Gopinath, Mike Scott 
Original Code by Bino Varghese, updated by David Hoelzle

Code is designed to track cells in the cell deformer device and output their transit times and areas.  It is designed to have minimal user input so reliable results are obtained.

To use this code:
	- Ensure video files are in .avi format, and named correctly.
	For a 5 micron device at 800 fps: 
		'dev5x10_800fps[anything you want].avi'
	- Run MainCode.m
	- Select videos when prompted
		- Select as many video as you want from one folder
		- GUI will pop up to select videos from other folders
	- Code should automatically detect constriction size and framerate
	- A progress bar will tell you how much longer the code will run

Output:
	- An excel sheet with five sheets of data
	- Two blocks per sheet: Unpaired Cells (left) and paired cells 				(right)
	- Sheet 1: Total transit times and unconstricted areas
	- Sheet 2: Transit time data at each constriction
	- Sheet 3: Area data for each cell at each constrictions
	- Sheet 4: "Diameter Data" (Diameter = majorAxis+minorAxis/2)
	- Sheet 5: Eccentricity Data for each cell at each constriction
		

This version of the code has many updates from the original code, many of which are listed below.
	- Constriction size and framerate are detected from the filename
	- Multiple select is enabled
	- Individual processed frames are not saved to the hard drive
	- Digital image filtering was improved
	- Multiple average backgrounds are now calculated
	- Searching algorithm was redone, and no longer searches
	- Preprocessing of 50 frames was eliminated
	- Calls to regionprops were drastically reduced for speed
	- Cell area is calculated before entry into the lane and at 				constrictions
	- Cells are separated into lanes for analysis
	- Masks are used to define the channels
	- Autocorrelation with the mask is used to define constriction 				regions
	- Videos are no longer cropped (didn't significantly alter speed)
	- 'Paired cells' (those where 2 cells are in the same lane 				concurrently) are separated from cells who pass through an 			otherwise empty lane.
	- Progressbar labels are now persistant
	- xlswrite replaced with xlswrite1 (from MATLAB file exchange, ~15 			seconds faster [50+ calls])
	- Cells that touch multiple lines are now counted at the lowest 			(highest numbered) line they touch.  Solves timing issues 			caused by the line used to calculate area.
	- Histogram output added, previous outputs slightly modified
