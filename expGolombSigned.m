function bits = expGolombSigned(N)
    if N > 0
        bits = [0, expGolombUnsigned(2*N - 1)];
    elseif N < 0
        bits = [1, expGolombUnsigned(-2*N)];
    else
        bits = [1, 1];  % Special case for zero
    end
end