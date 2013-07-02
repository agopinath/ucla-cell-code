Hi AJ,

I've made some changes to the code, which I'll detail a bit below to avoid confusing you.


Make_waypoints:
	- Changed the selection area to a polygon with the constriction lines built in.  This is nearly all cosmetic.


Portion_segment:
	- Recommented and increased the readability of the code. 
	- Minor edits.  This is the filtering section of the code, and I'm working on it heavily right now.  Unless you are really bored, I'd leave this alone for now, and I'll send you an updated version soon.

AnalysisCodeBAV:

First, I have been running this code as a script rather than a function.  This is so I can avoid rerunning all of the previous code for testing.  In order to allow Master_Script_New to call this code, you will need to uncomment line 6, and comment out lines 9 through 13 (but not 14).

Second, I have been working on BAV_test.  So it contains my most recent edits to AnalysisCodeBAV, so I'd look at this code.  In this code, I've eliminated the call to SecondCheckForCellValidity and integrated it into the code.  I've also modified the execution of the code from SecondCheckForCellValidity for speed, but the output is the same.




Everything else, I think you'll find it is the same as what Kendra gave you.  Any new functions are just functions I am working on for testing that are not called by any of the code.

Good luck, and you can text me or email me if you have any questions.

Mike Scott
michaelbaranscott@gmail.com
(626) 340 - 1991
