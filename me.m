function [mvf, MSE] = me(cur, ref, blockSizeRow, blockSizeCol, radius)
%ME Motion estimationcur
%    mvf = ME(cur, ref, brow, bcol, radius);
%    Computes a motion vector field between the current and reference
%    image, using a given block size and search area's radius
%    [mvf MSE] = ME(...)
%    Returns the MSE associated to the output mvf
%

    [curRows, curCols] = size(cur);
    [refRows, refCols] = size(ref);
    totalSSD = 0;
    mvf = zeros(curRows, curCols, 2);

    % Blocks scan
    for row = 1:blockSizeRow:curRows
        for col = 1:blockSizeCol:curCols
            % Block from current image
            B = cur(row:row+blockSizeRow-1, col:col+blockSizeCol-1);
            % Initialization of the best displacement
            bestDeltaCol = 0;
            bestDeltaRow = 0;
            % Best cost initialized at the highest possible value
            SSDmin = blockSizeRow * blockSizeCol * 256 * 256;

            % loop on candidate motion vectors v = (deltaCol,deltaRow)
            % It is a full search in [-radius:radius]^2
            for deltaCol = -radius:radius
                for deltaRow = -radius:radius
                    % Calculate reference block indices
                    refRowStart = row + deltaRow;
                    refRowEnd = refRowStart + blockSizeRow - 1;
                    refColStart = col + deltaCol;
                    refColEnd = refColStart + blockSizeCol - 1;

                    % Check if reference block is within bounds
                    if (refRowStart >= 1) && (refRowEnd <= refRows) && (refColStart >= 1) && (refColEnd <= refCols)
                        % Reference block
                        R = ref(refRowStart:refRowEnd, refColStart:refColEnd);
                        differences = B - R;
                        SSD = sum(differences(:).^2); % Sum of squared differences

                        % If current candidate is better than the previous
                        % best candidate, then update the best candidate
                        if (SSD < SSDmin) 
                            SSDmin = SSD;
                            bestDeltaCol = deltaCol;
                            bestDeltaRow = deltaRow;
                        end
                    end
                end
            end

            % Store the best MV and accumulate the associated SSD
            mvf(row:row+blockSizeRow-1, col:col+blockSizeCol-1, 1) = bestDeltaRow;
            mvf(row:row+blockSizeRow-1, col:col+blockSizeCol-1, 2) = bestDeltaCol;
            totalSSD = totalSSD + SSDmin;
        end
    end

    MSE = totalSSD / (curRows * curCols);
end






