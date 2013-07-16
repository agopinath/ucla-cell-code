This is a summary of the latest major changes for my code on GitHub. Last updated: 7/15/13.

Merged my code with Mike's

MainCode:
- separated all logic for prompting/selection of video files to
  process into function PromptForVideos
- improved extraction of frame rates and template sizes from video
  names by using regular expressions instead of ad-hoc parsing
- cleaned up any remaining legacy code and comments
- added better output of debugging information

CellDetection:
- using improved image filtering scheme so that cells are better detected

MakeWaypoints:
- added a line on top of the previous first line to track unconstricted cell sizes
- line 1 is for unconstricted cell size, 2 - 8 are for transit times
- modified the design a bit so that the new first line does not have to follow the same spacing
  rules as do the other template lines

CellTracking:
- added extra (fifth) column to cellInfo to store cell sizes.
- while the code currently only records unconstricted cell size, the design is flexible enough 
  to easily add in recording of unconstricted cell size as well
- changes are rather minor, just enough so that the unconstricted cell size is added in another column

ProcessTrackingData:
- the code now stores unconstricted cell sizes in a column vector and concatenates it with the
  other transit data to yield a matrix containing transit times as well as unconstricted cell sizes for each cell
- still one known bug when it crashes when processing certain videos

=== CELL VIDEO LINKS ====
- These videos show the white overlayed detected cell outlines over the original video
- They are unlisted so only those with the link can see it
https://www.youtube.com/watch?v=nylAmn5aliM
http://www.youtube.com/watch?v=1UMqrNlp1LI
http://www.youtube.com/watch?v=iRgirB5s-N0
=========================
