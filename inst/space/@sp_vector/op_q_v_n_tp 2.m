% OP_Q_V_N_TP: assemble the mass matrix M = [m(i,j)], m(i,j) = (v_j * n_j, q_i), exploiting the tensor product structure.
%
%   mat = op_q_v_n_tp (spv, spq, msh, [coeff]);
%   [rows, cols, values] = op_q_v_n_tp (spv, spq, msh, [coeff]);
%
% INPUT:
%
%  spv:   object representing the space of trial functions (see sp_vector)
%  spq:   object representing the space of test functions (see sp_scalar)
%  msh:   object defining the domain partition and the quadrature rule (see msh_cartesian)
%  coeff: function handle to compute the coefficient (optional)
%
% OUTPUT:
%
%  mat:    assembled mass matrix
%  rows:   row indices of the nonzero entries
%  cols:   column indices of the nonzero entries
%  values: values of the nonzero entries
% 
% Copyright (C) 2020 Riccardo Puppi
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

function varargout = op_q_v_n_tp (space_v, space_q, msh, coeff)

  A = spalloc (space_q.ndof, space_v.ndof, 3*space_v.ndof);

  for iel = 1:msh.nel_dir(1)
    msh_col = msh_evaluate_col (msh, iel);
    sp1_col = sp_evaluate_col (space_v, msh_col);
    sp2_col = sp_evaluate_col (space_q, msh_col);

    if (nargin == 4)
      for idim = 1:msh.rdim
        x{idim} = reshape (msh_col.geo_map(idim,:,:), msh_col.nqn, msh_col.nel);
      end
      coeffs = coeff (x{:});
    else
      coeffs = ones (msh_col.nqn, msh_col.nel);
    end

    A = A + op_q_v_n (sp1_col, sp2_col, msh_col, coeffs);
  end

  if (nargout == 1)
    varargout{1} = A;
  elseif (nargout == 3)
    [rows, cols, vals] = find (A);
    varargout{1} = rows;
    varargout{2} = cols;
    varargout{3} = vals;
  end

end
