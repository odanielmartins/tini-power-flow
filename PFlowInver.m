## Copyright (C) 2019 odani
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{retval} =} PFlowInver (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: odani <odani@DESKTOP-8NC62O8>
## Created: 2019-04-25

% Impedâncias das linhas
y12 = 2 - 2j;                   % para z12 = 0.5j
y24 = 4 - 2j;                   % para z24 = 0.5j
y13 = 3 - 2j;                   % para z13 = 0.5j
y34 = 4 - 2j;                   % para z34 = 0.5j

%Gerador
S1 = 10 + 0j;
% Cargas
S2 = -1 + 0j;                   % P2 - jQ2
S3 = -1 + 0j;                   % P2 - jQ2
S4 = -1 + 0j;                   % P2 - jQ2

% Tensões iniciais nas barras
v1 = 1.02 + 0j;           % Barra swing ou barra slack
v2 = 1 + 0j;
v3 = 1 + 0j;
v4 = 1 + 0j;

% Montando a matriz impedância
Y = [-(y12 + y13)        y12           y13            0;
          y12       -(y12 + y24)       0             y24;
          y13             0      -(y13 + y34)        y34;
           0             y24          y34       -(y24 + y34)];
printf("Inverso de Y\n");
Yinv = inv(Y);

% Montando o vetor de tensões iniciais
V = [S1*conj(v1); S2*conj(v2); S2*conj(v3); S4*conj(v4)];

for it = 1:50
  % Calculando o vetor de Correntes
  I = Y*V;
  V = Yinv*I;
  V(1) = 1.02 + 0j;
  %printf('Novo V\n');
  %V
endfor
V
for n = 1:4
  printf('V(%d) = %4.6f + %4.6fj     mod = %4.6f  fase=%4.6f \n',
      n,real(V(n)),imag(V(n)),abs(V(n)),angle(V(n))*360/(2*pi));
endfor