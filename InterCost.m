function InterCost = calculateInterCost(currentBlock, previousDC, params)
    % Calculate the cost of inter-coding for a given block
    
    % Perform block inter coding
    [~, blockPSNRInter, blockBitStreamInter] = blockInterCoding(currentBlock, previousDC, params.blockSize, params.Searchradius, params);
    
    % Calculate the block MSE
    error = currentBlock(:) - blockInterDecoding(blockBitStreamInter, previousDC);
    blockMSEInter = mean(error(:).^2);
    
    % Calculate the inter cost
    InterCost = blockMSEInter + params.lambda * length(blockBitStreamInter);
end