function [mvf] = meReg(cur, ref, blockSizeRow, blockSizeCol, radius, lambda)
%MEREG Regularized Motion estimation
%    MVF = meReg(cur, ref, brow, bcol, radius, lambda);
%    Computes a motion vector field between the current and reference
%    image, using a given block size and search area's radius
%    The criterion is SSD + lambda* codingCost
%    The coding cost is computed using a ExpGolomb code on the prediction
%    error. The predictor is the median of the three nearest available
%    neighbors.
%
%(C) 2010-2023 M. Cagnazzo
%

[ROWS, COLS]=size(cur);
mvf = zeros(ROWS,COLS,2);

% Blocks scan
for indexRow=1:blockSizeRow:ROWS
    for indexCol=1:blockSizeCol:COLS        
        %% Block selection from the current image
        % B is a block with top-left pixel in position (indexRow,indexCol); 
        % the size of B is blockSizeRow x blockSizeCol
        B=cur(indexRow:indexRow+blockSizeRow-1,indexCol:indexCol+blockSizeCol-1);
        
        
        %% Motion estimation for the current block

        %% Initializations
        % Initialization of the best displacement
        bestDeltaCol=0; bestDeltaRow=0;
        % Best cost initialized at the highest possible value
        Jmin=blockSizeRow*blockSizeCol*256*256; 
        
        %% Motion vector prediction
        % For the current position, we find the predictor of the motion
        % vector. This predictor is used to encode the MV

        % 1. There is no predictor for the first block: in this case
        % we use (0,0)
        if indexCol==1 && indexRow ==1
            predictor = [0; 0];
            %Since there is no predictor in this case, we set
            %the penalization to zero
            weight = 0;
            % 2. For the first column (left), we take as predictor
            % the top neighbor. In this and all the other cases, a
            % predictor exists, so the penalization weight is lambda
        elseif indexCol==1
            predictor = squeeze(mvf(indexRow-blockSizeRow, indexCol,:));
            % The squeeze function makes sure that what we extract from the
            % 3D matrix MVF is, indeed, a column vector
            weight = lambda ;
            % 3. For the first row, we use the left neighbor
        elseif indexRow==1
            predictor = squeeze(mvf(indexRow, indexCol-blockSizeCol,:));
            weight = lambda ;
        else
            % 4. In all the other cases we take the MEDIAN of 3
            % neighbors: 1. the left neighbor, 2. the top neighbor
            V1 = squeeze(mvf(indexRow, indexCol-blockSizeCol, :));
            V2 = squeeze(mvf(indexRow-blockSizeRow, indexCol, :));
            % The third neighbor is the top-right neighbor if it is
            % available (ie., except for the last column)
            if indexCol<(COLS-blockSizeCol)
                V3 = squeeze(mvf(indexRow-blockSizeRow, indexCol+blockSizeCol, :));
            else
                % For the last column we take the top-left neighbor
                V3 = squeeze(mvf(indexRow-blockSizeRow, indexCol-blockSizeCol, :));
            end
            % 5. Computing the median: the three neighbors are put as
            % column of a matrix, and then the median is computed row-wise
            predictor = median([V1,V2,V3],2);
            weight=lambda;
        end


        
        % ME loop on candidate motion vectors v = (deltaCol,deltaRow) 
        % It is a full search in [-radius:radius]^2
        for deltaCol=-radius:radius
            for deltaRow=-radius:radius
                % Check: the candidate vector must point inside the image
                if ((indexRow+deltaRow>0)&&(indexRow+deltaRow+blockSizeRow-1<=ROWS)&& ...
                        (indexCol+deltaCol>0)&&(indexCol+deltaCol+blockSizeCol-1<=COLS))
                    % Now we are sure that the motion vector points inside
                    % the image and we can recover the reference block R
                    % Notice that R is obtained by adding the suitable
                    % diplacement to the row and col indexes
                    R=ref(indexRow+deltaRow:indexRow+deltaRow+blockSizeRow-1, ...
                        indexCol+deltaCol:indexCol+deltaCol+blockSizeCol-1);
                    differences = B-R;
                    SSD=sum(differences(:).^2);  %Literally, SSD

                    %% Regularization


                    % 2. The regularization cost is the coding cost of the
                    % prediction error

                    predErr = [deltaRow; deltaCol]-predictor;
                    cw = [expGolombSigned(predErr(1)), expGolombSigned(predErr(2))];
                    
                    bits = numel(cw);
                 
                    J= SSD + weight*bits;

                    % If current candidate is better than the previous
                    % best candidate, then update the best candidate
                    if (J<Jmin) 
                        Jmin=J;
                        bestDeltaCol=deltaCol;
                        bestDeltaRow=deltaRow;
                    end

                end % 
            end % 
        end % loop on candidate vectors
        % Store the best MV and the associated cost
        mvf(indexRow:indexRow+blockSizeRow-1,indexCol:indexCol+blockSizeCol-1,1)=bestDeltaRow;
        mvf(indexRow:indexRow+blockSizeRow-1,indexCol:indexCol+blockSizeCol-1,2)=bestDeltaCol;
        
    end  
end % loop on Blocks
