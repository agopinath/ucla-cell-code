% WriteExcelOutput
function WriteExcelOutput(outputFilename, lonelyData, pairedData)

% Writes out the transit time data in an excel file
%% Sheet 1: Total Transit Time and Unconstricted Area
paired = {'Paired Cells'};
unpaired = {'Unpaired Cells'};
colHeader1 = {'Total Time (ms)', 'Unconstricted Area'};
xlswrite(outputFilename,unpaired,'Sheet1','A1');
xlswrite(outputFilename,paired,'Sheet1','E1');
xlswrite(outputFilename,colHeader1,'Sheet1','A2');
xlswrite(outputFilename,colHeader1,'Sheet1','E2');
xlswrite(outputFilename,lonelyData(:,1,1),'Sheet1','A3');
xlswrite(outputFilename,lonelyData(:,1,2),'Sheet1','B3');
xlswrite(outputFilename,pairedData(:,1,1),'Sheet1','E3');
xlswrite(outputFilename,pairedData(:,1,2),'Sheet1','F3');

%% Sheet 2: Transit Time Data (All of it!)
colHeader2 = {'Total Time (ms)', 'Unconstricted Area', 'C1 to C2', 'C2 to C3', 'C3 to C4', 'C4 to C5', 'C5 to C6', 'C6 to C7'};
xlswrite(outputFilename,unpaired,'Sheet2','A1');
xlswrite(outputFilename,paired,'Sheet2','L1');
xlswrite(outputFilename,colHeader2,'Sheet2','A2');
xlswrite(outputFilename,colHeader2,'Sheet2','L2');
xlswrite(outputFilename,lonelyData(:,1:9,1),'Sheet2','A3');
xlswrite(outputFilename,pairedData(:,1:9,1),'Sheet2','L3');

%% Sheet 3: Area Data (at each constriction)
colHeader3 = {'Unconstricted Area', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7'};
xlswrite(outputFilename,unpaired,'Sheet3','A1');
xlswrite(outputFilename,paired,'Sheet3','L1');
xlswrite(outputFilename,colHeader3,'Sheet3','A2');
xlswrite(outputFilename,colHeader3,'Sheet3','L2');
xlswrite(outputFilename,lonelyData(:,1:8,2),'Sheet3','A3');
xlswrite(outputFilename,pairedData(:,1:8,2),'Sheet3','L3');

%% Sheet 4: Diameter Data (at each constriction)
colHeader4 = {'Unconstricted D', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7'};
xlswrite(outputFilename,unpaired,'Sheet4','A1');
xlswrite(outputFilename,paired,'Sheet4','L1');
xlswrite(outputFilename,colHeader4,'Sheet4','A2');
xlswrite(outputFilename,colHeader4,'Sheet4','L2');
xlswrite(outputFilename,lonelyData(:,1:8,3),'Sheet4','A3');
xlswrite(outputFilename,pairedData(:,1:8,3),'Sheet4','L3');

%% Sheet 5: Eccentricity Data
colHeader5 = {'Unconstricted E', 'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7'};
xlswrite(outputFilename,unpaired,'Sheet5','A1');
xlswrite(outputFilename,paired,'Sheet5','L1');
xlswrite(outputFilename,colHeader5,'Sheet5','A2');
xlswrite(outputFilename,colHeader5,'Sheet5','L2');
xlswrite(outputFilename,lonelyData(:,1:8,4),'Sheet5','A3');
xlswrite(outputFilename,pairedData(:,1:8,4),'Sheet5','L3');