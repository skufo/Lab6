function motcomp = mc(ref,mvf)
%MC Integer pixel motion compensation
%    MOTCOMP = MC(REF,mvf) computes the motion-compensated version of REF,
%    using the vector field stored in mvf. This field should be dense, i.e.
%    one vector per pixel)
%
[ROWS, COLS] = size(ref);
motcomp=zeros(ROWS,COLS);
for r=1:ROWS
    for c=1:COLS
        mc_r = r + mvf(r,c,1);
        mc_c = c + mvf(r,c,2);
        motcomp(r,c)=ref(mc_r,mc_c);
    end
end 
