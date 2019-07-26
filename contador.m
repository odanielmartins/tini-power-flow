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
## @deftypefn {} {@var{retval} =} contador (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: odani <odani@NOTEBOOK-DM>
## Created: 2019-05-30

v = [0,0,0,0,0,0,0,0,0,0];
fp = fopen("pi.txt","r");
txt = fread(fp);
tam = length(txt);
tam
for i = 1:tam
   car = txt(i) - 48 + 1;
  ++v(car);
endfor
i = 1:10;
bar(i-1,100*v/tam);
fclose(fp);