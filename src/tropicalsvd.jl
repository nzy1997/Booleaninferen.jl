function tropical_svd(C::Matrix{TropicalAndOr},k::Int)
    # C = A * B
    # A: m x k, B: k x n
    # 1 : 2mk are the vertices of A
    # 2mk+1 : 2kn + 2mk are the vertices of B
    m, n = size(C) 
    g = SimpleDiGraph(2*(m*k+n*k));
    for i in 1:m
        for j in 1:n
            for l in 1:k
                add_edge!(g, (i, m*k+j), (m*k+j, 2*m*k+n*k+i), C[i,j].value[l])
                
            end
        end
    end
end
