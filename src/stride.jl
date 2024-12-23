function get_tensor_number(tensor::AbstractVector, vals::Vector{Int})
    return tensor[sum([(1<<(i-1))*(vals[i]-1) for i in 1:length(vals)])+1]
end

bin_to_vec(x,n) = [ (x >> i) & 1 for i in 0:(n-1)]
function get_vals!(vals::Vector{Int},float_pos::Vector{Int},i::Int) 
    vals[float_pos] = bin_to_vec(i,length(float_pos)).+ 1
    return vals
end
function slice_tensor(tensor::AbstractVector, pos::Vector{Int}, pos_vals::Vector{Int},n::Int)
    vals = fill(0,n)
    vals[pos] = pos_vals
    float_pos = setdiff(1:n,pos)
    return [get_tensor_number(tensor,get_vals!(vals,float_pos,i)) for i in 0:2^(n-length(pos))-1]
end

function vec2tensor(vec::AbstractVector)
    return reshape(vec, fill(2, Int(log2(length(vec))))...)
end