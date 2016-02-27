function sigma2 = pooledV( A, B )
%calculates sigma^2 from formula in pdf
% A and B = vectors of pixel values

va=sum(A.^2)-(sum(A)^2)/size(A);

vb=sum(B.^2)-(sum(B)^2)/size(B);

sigma2 = (va + vb)/2;



end

