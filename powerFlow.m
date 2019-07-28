% THIS SMALL OCTAVE/MATLAB SCRIPT ESTIMATES A POWER SYSTEM STATE DESCRIPTION
% It was inspired in "Power System Load Flow Tutorial: Part 1" class that may
% be found in https://www.youtube.com/watch?v=LeGss3hdpMs

fileN = input ("File name .csv with electric power system description ","S");

% Some of the electric power system data.
fid = fopen(fileN,"r");
% Vector indicating maximum iteration number and error.
do
  aux = fgetl(fid);         % Read eventual comment lines before vector for slack bars.
until(aux(1) != '%')
aux = strsplit(aux,',');
vtxt = [aux{1:2}];
vals = str2num(vtxt);
niter = vals(1);
erro  = vals(2);

% This vector indicates which bars are used as slack bars (those with a constant controled voltage).
do
  aux = fgetl(fid);         % Read eventual comment lines
until(aux(1) != '%')
aux = strsplit(aux,',');
nBars = length(aux);         % Number of bars
fprintf(' ======= Number of bars in electric power system = %d\n',nBars);
vslackTxt = [aux{1:nBars}];
%fprintf("Slack bars
vslack = str2num(vslackTxt);
%vslack

%printf(' ======= Voltage initial values. \n');
do
  aux = fgetl(fid);    % Read eventual comment lines.
until(aux(1) != '%')
aux = strsplit(aux,',');
vTxt = [aux{[1:nBars]}];
V = str2num(vTxt);

%printf(' ========= Powe injecte for each bar.

do
  aux = fgetl(fid);     % Eventual comment lines
until(aux(1) != '%')
aux = strsplit(aux,',');
Gtxt = [aux{[1:nBars]}];
G = str2num(Gtxt);

%printf(' ========= Load power absorbed for each bus bar: \n');
do
  aux = fgetl(fid);     % Read comments
until(aux(1) != '%')
aux = strsplit(aux,',');
Stxt = [aux{[1:nBars]}];
S = str2num(Stxt);

%printf(' ========= Eventual shunt bus bar impedances \n');
do
  aux = fgetl(fid);     % Le comentários
until(aux(1) != '%')
aux = strsplit(aux,',');
Stxt = [aux{[1:nBars]}];
yShunt = 1./str2num(Stxt);


printf(' ========== Matriz impedância fornecida: \n');
do
  aux = fgetl(fid);     % Read comments
until(aux(1) != '%')

Z = [];
for bar = 1:nBars
  aux = strsplit(aux,',');
  linTxt = [aux{[1:nBars]}];
  lin = str2num(linTxt);
  Z =  [Z ; lin];
  aux = fgetl(fid);
endfor
Z

printf(' ==========  Calculated admitance array: \n');
Y = 1./Z;
%for lin = 1:nBars         % Invert impedance term by term
%  for col = 1:nBars
%    if(Y(lin,col) != 0)
%      Y(lin,col) = 1/Y(lin,col);
%    endif
%  endfor
%endfor
% Calculate external admitances
for lin = 1:nBars
  Y(lin,lin) = yShunt(lin);
  for col = 1:nBars
    if(lin != col)
      Y(lin,lin) += Y(lin,col);
    endif
  endfor
endfor
Y

% ========================= Calculate power flow =====================

iInter = [];
for nb=1:nBars;
  iInter(nb) = 0;  
endfor

printf('========== Resulting voltage for each bar ==========\n');
for nb = 1:nBars            % For all bars
  
  % Using Kirchoff´s law for each bar for each iteration
  if(vslack(nb) == 1)              % If slack bar do not calculate
  vmodulo = abs(V(nb));  vfase = angle(V(nb))*360/(2*pi);
  if(imag(V(nb)) < 0)
     fprintf('V(%d) = %6.4f - %6.4fi Mag = %6.4f Ang = %.2fº\n',
        nb,real(V(nb)),abs(imag(V(nb))),vmodulo,vfase);
  else   
     fprintf('V(%d) = %6.4f - %6.4fi Mag = %6.4f Ang = %.2fº\n',
        nb,real(V(nb)),abs(imag(V(nb))),vmodulo,vfase);
  end
    continue;
  endif
  
  vant = 0;
  
  for it = 1:niter
    iS = 0;
    for bar = 1:nBars                           % Adjacente bar components
      if(bar != nb)
        iS += Y(nb,bar)*V(bar);
      endif
    endfor

        
    V(nb) = (1/Y(nb,nb))*( G(nb)/conj(V(nb)) -S(nb)/conj(V(nb)) + iS);
    vmodulo = abs(V(nb));
    vfase = angle(V(nb))*360/(2*pi);
    if( abs((vmodulo - vant)) < erro)
      iInter(nb) = it;
      break;
    else
      vant = vmodulo;
    endif
  endfor

  if(imag(V(nb)) < 0)
    fprintf('V(%d) = %f - %fi  Mag = %f Ang = %.2fº\n',
        nb,real(V(nb)),abs(imag(V(nb))),vmodulo,vfase);
    else
    fprintf('V(%d) = %f + %fi  Mag = %f Ang = %.2fº\n',
        nb,real(V(nb)),abs(imag(V(nb))),vmodulo,vfase);
  end  
endfor

printf('\n========== Number of iteration for each bars until error is atained ==========\n');
for bar = 1:nBars
  printf('Bar\tIterations\t');
endfor
printf('\n');
for bar = 1:nBars
  printf('%d\t\t%d\t',bar,iInter(bar)); 
endfor
printf('\n');

I = [];
P = [];
printf('========== Currents and power flow for each line ==========\n');
for lin = 1:nBars
  for col = 1:nBars
    if(lin != col)
      if(lin < col)
        if(  (Z(lin,col) != 0) && (Z(lin,col) < Inf)  ) 
          I(lin,col) = (V(col) - V(lin))*Y(lin,col);
          if(imag(I(lin,col)) < 0)
            printf('I(%d,%d) = %f - %fi Mod = %f ang = %.2fº \n', lin,col,real(I(lin,col)),abs(imag(I(lin,col))),
                 abs(I(lin,col)),angle(I(lin,col)));
          else
            printf('I(%d,%d) = %f + %fi Mod = %f ang = %.2fº \n', lin,col,real(I(lin,col)),abs(imag(I(lin,col))),
                 abs(I(lin,col)),angle(I(lin,col)));
          end                 
          P(lin,col) = (V(col) - V(lin))*I(lin,col);
          if(imag(P(lin,col)) < 0)
            printf('P(%d,%d) = %f - %fi Mod = %f ang = %.2f°\n',lin,col,real(P(lin,col)),abs(imag(P(lin,col))),
                abs(P(lin,col)), angle(P(lin,col)));
          else
            printf('P(%d,%d) = %f + %fi Mod = %f ang = %.2f°\n',lin,col,real(P(lin,col)),abs(imag(P(lin,col))),
                abs(P(lin,col)), angle(P(lin,col)));
          end                
        endif
      endif
    endif
  endfor
endfor
fclose(fid);
