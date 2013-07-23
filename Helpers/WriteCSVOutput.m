% WriteExcelOutput
function WriteCSVOutput(outputFolderName, lonelyData, pairedData)

pFolderName = fullfile(outputFolderName, '/paired/');
mkdir(pFolderName);
lFolderName = fullfile(outputFolderName, '/lonely');
mkdir(lFolderName);

pTT = fullfile(pFolderName, 'total_transit_times.txt');
pUA = fullfile(pFolderName, 'unconstricted_areas.txt');
pATT = fullfile(pFolderName, 'all_transit_times.txt');
pAD = fullfile(pFolderName, 'areas.txt');
pDD = fullfile(pFolderName, 'diameters.txt');
pED = fullfile(pFolderName, 'eccentricities.txt');

lTT = fullfile(lFolderName, 'total_transit_times.txt');
lUA = fullfile(lFolderName, 'unconstricted_areas.txt');
lATT = fullfile(lFolderName, 'all_transit_times.txt');
lAD = fullfile(lFolderName, 'areas.txt');
lDD = fullfile(lFolderName, 'diameters.txt');
lED = fullfile(lFolderName, 'eccentricities.txt');

% Writes out the transit time data in an excel file
%% Sheet 1: Total Transit Time and Unconstricted Area
dlmwrite(lTT,lonelyData(:,1,1));
dlmwrite(lUA,lonelyData(:,1,2));
dlmwrite(pTT,pairedData(:,1,1));
dlmwrite(pUA,pairedData(:,1,2));

%% Sheet 2: Transit Time Data (All of it!)
dlmwrite(lATT,lonelyData(:,1:9,1));
dlmwrite(pATT,pairedData(:,1:9,1));

%% Sheet 3: Area Data (at each constriction)
dlmwrite(lAD,lonelyData(:,1:8,2));
dlmwrite(pAD,pairedData(:,1:8,2)); 

%% Sheet 4: Diameter Data (at each constriction)
dlmwrite(lDD,lonelyData(:,1:8,3));
dlmwrite(pDD,pairedData(:,1:8,3)); 

%% Sheet 5: Eccentricity Data
dlmwrite(lED,lonelyData(:,1:8,4));
dlmwrite(pED,pairedData(:,1:8,4));
