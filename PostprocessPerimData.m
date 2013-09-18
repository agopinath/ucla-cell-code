function fftData = PostprocessPerimData(currVideo, cellData, cellPerimsData)

fftData = cell(1, 16);

for i = 1:16
    fftData{i} = {};
    fftData{i}{1} = {};
end

for currLane = 1:16
    numCells = length(cellData{currLane});
    
    for currCellIdx = 1:numCells
        currCell = cellData{currLane}{currCellIdx};
        currCellPerim = cellPerimsData{currLane}{currCellIdx};
        figure(currCellIdx+20); hold on;
        numFrames = size(currCell, 1);
        for currFrameIdx = 1:numFrames
            frameData = currCell(currFrameIdx, :);
            framePerim = currCellPerim{currFrameIdx};
            numPoints = size(framePerim, 1);
            if(numPoints == 0)
                continue;
            end
            
            % Prepare parameters for FFT
            Fs = size(framePerim, 1);
            T = 1 / numPoints;
            L = Fs;
            t = (1:numPoints)*T;
             %plot(t, framePerim(:,2));
            
            %NFFT = 2^nextpow2(L); % Next power of 2 from length of y
            Y = fft(framePerim(:,2))/L;
            f = Fs/2*linspace(0,1,L/2);

            % Plot single-sided amplitude spectrum.
            plot(f,2*abs(Y(1:L/2))); 
            
            fftData{currLane}{currCellIdx}{currFrameIdx} = fft(framePerim);
            qq=1+1;
        end
        hold off;
    end
end
qq=1+1;