% Cubature-quadrature points, q_pts: 2*nx*n_quad x nx
% Cubature-quadrature weights, q_wts: 2*nx*n_quad x 1
function [cq_pts, cq_wts] = cubquad_points(nx, n_quad)
    [q_pts, q_wts] = quad_points(nx, n_quad);
    q_pts = sqrt(2 * q_pts);

    n_sigma = 2 * nx * n_quad;
    cq_pts = zeros(n_sigma, nx);
    cq_wts = zeros(n_sigma, 1);
    for j = 1:n_quad
        low = (2 * nx * (j - 1)) + 1;
        high = 2 * nx * j;
        cq_pts(low:high, :) = q_pts(j) * [diag(ones(1, nx)); -diag(ones(1, nx))];
        cq_wts(low:high, 1) = repmat(q_wts(j), [2 * nx, 1]);
    end
    
    cq_wts = cq_wts / sum(cq_wts);
end
% Quadrature points, q_pts: n_quad x 1
% Quadrature weights, q_wts: n_quad x 1
function [q_pts, q_wts] = quad_points(nx, n_quad)
    alpha = 0.5 * nx - 1;

    syms x;
    CL_poly = laguerreL(n_quad, alpha, x);
    CL_poly_d = diff(CL_poly);

    q_pts = real(double(roots(flip(coeffs(CL_poly)))));

    aa = (factorial(n_quad) * gamma(alpha + n_quad + 1)) / ...
        (2 * nx * gamma(nx / 2));
    dd = double(subs(CL_poly_d, q_pts)) .^ 2;
    q_wts = aa ./ (q_pts .* dd);
end
