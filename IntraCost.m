function IntraCost = calculateIntraCost(currentBlock, previousDC, params)
    % Calculate the cost of intra-coding for a given block
    
    % Perform block intra coding
    [~, blockPSNRIntra, blockBitStreamIntra] = blockIntraCoding(currentBlock, previousDC, params);
    
    % Calculate the block MSE
    error = currentBlock(:) - blockIntraDecoding(blockBitStreamIntra, previousDC);
    blockMSEIntra = mean(error(:).^2);
    
    % Calculate the intra cost
    IntraCost = blockMSEIntra + params.lambda * length(blockBitStreamIntra);
end