module ParametricMCPs

using PATHSolver: PATHSolver
using SparseArrays: SparseArrays
using Symbolics: Symbolics

include("sparse_utils.jl")

include("parametric_problem.jl")
export ParametricMCP, get_parameter_dimension, get_problem_size
include("solver.jl")
export solve

include("AutoDiff.jl")

end
