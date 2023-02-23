function solve(
    problem::ParametricMCP,
    θ;
    initial_guess = zeros(get_problem_size(problem)),
    verbose = false,
    warn_on_convergence_failure = true,
    enable_presolve = true,
    jacobian_data_contiguous = true,
    options...,
)
    (; f!, jacobian_z!, lower_bounds, upper_bounds) = problem

    function F(n, z, f)
        f!(f, z, θ)
        Cint(0)
    end

    result = get_result_buffer(jacobian_z!)
    function J(n, nnz, z, col, len, row, data)
        jacobian_z!(result, z, θ)
        _coo_from_sparse!(col, len, row, data, result)
        Cint(0)
    end

    jacobian_linear_elements =
        enable_presolve ? jacobian_z!.constant_entries : empty(jacobian_z!.constant_entries)
    status, z, info = PATHSolver.solve_mcp(
        F,
        J,
        lower_bounds,
        upper_bounds,
        initial_guess;
        silent = !verbose,
        nnz = SparseArrays.nnz(jacobian_z!),
        jacobian_structure_constant = true,
        jacobian_data_contiguous = jacobian_data_contiguous,
        jacobian_linear_elements = jacobian_linear_elements,
        options...,
    )

    if warn_on_convergence_failure && status != PATHSolver.MCP_Solved
        @warn "MCP not converged: PATH solver status is $(status)."
    end

    (; z, status, info)
end
