% PEQUENO SCRIPT QUE PERMITE O CÁLCULO DE UM LOADFLOW POR APROXIMAÇÃO
% Inspirado na aula "Power System Load Flow Tutorial: Part 1" que
% pode ser encontrada em https://www.youtube.com/watch?v=LeGss3hdpMs

fileN = input ("Nome do arquivo .csv que descreve o sistema elétrico: ","S");

% Alguns dados do sistema elétrico
fid = fopen(fileN,"r");
% vetor que indica o número máximo de interações e o erro que para o algorítmo
do
  aux = fgetl(fid);         % Le eventuais linhas comentários antes do velor de matrizes slack
until(aux(1) != '%')
aux = strsplit(aux,',');
vtxt = [aux{1:2}];
vals = str2num(vtxt);
niter = vals(1);
erro  = vals(2);

% vetor que indica quais as barras são do tipo slack (tensão constante)
do
  aux = fgetl(fid);         % Le eventuais linhas comentários antes do velor de matrizes slack
until(aux(1) != '%')
aux = strsplit(aux,',');
nBars = length(aux);         % Numero de barras
fprintf(' ======= Número de barramentos do sistema elétrico = %d\n',nBars);
vslackTxt = [aux{1:nBars}];
%fprintf("Barras do tipo slack ou swing ");
vslack = str2num(vslackTxt);
%vslack

%printf(' ======= Valores de partida das tensões. \n');
do
  aux = fgetl(fid);    % Le eventuais comentários antes dos valores de tensão por barra
until(aux(1) != '%')
aux = strsplit(aux,',');
vTxt = [aux{[1:nBars]}];
V = str2num(vTxt);

%printf(' ========= Potência fornecida para cada barra: \n');

do
  aux = fgetl(fid);     % Le eventuais linhas de comentário
until(aux(1) != '%')
aux = strsplit(aux,',');
Gtxt = [aux{[1:nBars]}];
G = str2num(Gtxt);

%printf(' ========= Potência absorvida em cada barra: \n');
do
  aux = fgetl(fid);     % Le comentários
until(aux(1) != '%')
aux = strsplit(aux,',');
Stxt = [aux{[1:nBars]}];
S = str2num(Stxt);

%printf(' ========= Calculo das eventuais admitâncias de shunt em cada barra. \n');
do
  aux = fgetl(fid);     % Le comentários
until(aux(1) != '%')
aux = strsplit(aux,',');
Stxt = [aux{[1:nBars]}];
yShunt = 1./str2num(Stxt);


printf(' ========== Matriz impedância fornecida: \n');
do
  aux = fgetl(fid);     % read comment
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

printf(' ==========  Matriz admitância calculada: \n');
Y = 1./Z;
%for lin = 1:nBars         % Inverte as impedâncias termo a termo
%  for col = 1:nBars
%    if(Y(lin,col) != 0)
%      Y(lin,col) = 1/Y(lin,col);
%    endif
%  endfor
%endfor
% Calcula admitâncias externas
for lin = 1:nBars
  Y(lin,lin) = yShunt(lin);
  for col = 1:nBars
    if(lin != col)
      Y(lin,lin) += Y(lin,col);
    endif
  endfor
endfor
Y

% ========================= Calcula o fluxo de potência =====================

iInter = [];
for nb=1:nBars;
  iInter(nb) = 0;  
endfor

printf('========== Tensões resultantes em cada barra ==========\n');
for nb = 1:nBars            % Para todas as barras
  
  % utilizando a lei de Kirchoff por até 'niter' iterações
  if(vslack(nb) == 1)              % tensão em barra slack não precisa calcular
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
    for bar = 1:nBars                           % componentes das barras adjacentes
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

printf('\n========== Número de iterações para cada barra ==========\n');
for bar = 1:nBars
  printf('Barra\tIterações\t');
endfor
printf('\n');
for bar = 1:nBars
  printf('%d\t\t%d\t',bar,iInter(bar)); 
endfor
printf('\n');

I = [];
P = [];
printf('========== Correntes e potências em cada linha ==========\n');
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