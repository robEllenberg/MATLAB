function G_tf = sym2tf (G_sym)
%SYM2TF Symbolic transfer function matrix to numerical transfer function matrix.
%
% SYM2TF (G_SYM) returns the normalized numerical transfer function matrix
% representation of the symbolic transfer function matrix G_SYM.
%
% Example:
%
% sym2tf ([s/(s+1), (s+2)/(2*s+1)])
%
% returns
%
% Transfer function from input 1 to output:
% s
% -----
% s + 1
%
% Transfer function from input 2 to output:
% 0.5 s + 1
% ---------
% s + 0.5
%
% Copyright Joerg J. Buchholz, Hochschule Bremen, buchholz@xxxxxxxxxxxx
% Determine the numbers of rows and columns of the symbolic transfer function matrix
[n_rows, n_cols] = size (G_sym);
% Disassemble every single symbolic transfer function into numerator and denominator
[num_sym, den_sym] = numden (G_sym);
% Loop over all rows
for i_row = 1 : n_rows
% Loop over all columns
for i_col = 1 : n_cols
% Transform the symbolic numerator of the current transfer function
% to numerical (coefficients of the polynomial)
num_tf{i_row, i_col} = sym2poly (num_sym(i_row, i_col));
% Transform the symbolic denominator of the current transfer function
% to numerical (coefficients of the polynomial)
den_tf{i_row, i_col} = sym2poly (den_sym(i_row, i_col));
% Normalize, so that leading denominator coefficient equals 1
num_tf{i_row, i_col} = num_tf{i_row, i_col}/den_tf{i_row,i_col}(1);
den_tf{i_row, i_col} = den_tf{i_row, i_col}/den_tf{i_row,i_col}(1);
end
end
% Assemble the numerical transfer function matrix
G_tf = tf (num_tf, den_tf)

