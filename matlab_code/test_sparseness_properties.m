function test_sparseness_properties(N)
% Test the zero pattern of L'*L. Is it the same as L'+L? I'm thinking not...
% ....And I am correct: it is not.

J = rand(N, N);
J(J<0.5) = 0;
Y = J'*J;

L = chol(Y, 'lower');
A = binary_matrix(L'+L);
B = binary_matrix(L'*L);

spy(A-B)

%
%

function A = binary_matrix(A)
A(A~=0) = 1;
