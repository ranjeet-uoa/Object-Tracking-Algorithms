function [X,w]= ct(m,P)

% Generate the cubature points-----
n_x= length(m);
n_q = 1; %quadrature dim

%[cq_pts, cq_wts] = cubquad_points(n_x, n_q);   % choose it for standarad and including quadrature poits
% xi = cq_pts';
% w = cq_wts;

 xi = sqrt(n_x) * [eye(n_x), -eye(n_x)]; %choose it for faster generation
 w = ones(2*n_x,1)/(2*n_x);

[U,S,V] = svd(P);
sqrtP = U * sqrt(S)*V';

% Spread these points around the prior mean 
 X = repmat(m, 1, 2*n_x) + sqrtP*xi;