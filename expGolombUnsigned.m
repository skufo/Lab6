function bitstream = expGolombUnsigned(N)
    if N <= 0
        error('N must be a positive number');
    end

    % Compute the unary code
    N = max(0, N);  % Ensure N is non-negative
    N = round(N);  % Round N to the nearest integer

    unaryBits = repmat('1', 1, N);
    unaryBits = [unaryBits '0'];

    % Compute the binary representation of the remaining bits
    if N > 0
        trailBits = dec2bin(N, floor(log2(N)) + 1);
    else
        trailBits = '';
    end

    % Concatenate the unary and trail bits
    bitstream = [unaryBits trailBits];
end