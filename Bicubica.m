%Funzione per l'interpolazione Bicubica di un'immagine.
%In input prende la matrice dell'immagine, ed il fattore di zoom.
%In output restituisce la matrice interpolata
 
function Interpolata = Bicubica(Interpolata,ImmagineOriginale,Z)
 
[NumRighe,NumColonne]=size(Interpolata);
[NumRigheOriginali,NumColonneOriginali]=size(ImmagineOriginale);
RapportoRighe=NumRigheOriginali/NumRighe;
RapportoColonne=NumColonneOriginali/NumColonne;
H=waitbar(0,'Interpolazione in corso');
 
for y1=1:NumRighe
    i=y1*RapportoRighe;
    y=floor(i);
    if i==y
        RigaOriginale=1;
    else
        RigaOriginale=0;
    end
    dy=i-y;
    for x1=1:NumColonne
        j=x1*RapportoColonne;
        x=floor(j);
%         if RigaOriginale==1 && x==j
%             Interpolata(y1,x1)=ImmagineOriginale(y,x);
%         else
            dx=j-x;
            Interpolata(y1,x1)=0;
            for m=-1:2
                Diffx=m-dx;
                Sommax=x+m;
                for n=-1:2
                    Interpolata(y1,x1)=Interpolata(y1,x1)+f(ImmagineOriginale,NumRigheOriginali,NumColonneOriginali,Sommax,y+n)*R(Diffx)*R(dy-n);
                end
            end
%         end
    end
    waitbar(y1/NumRighe,H);
end
close(H);
 
 
% Funzione R
function R = R(x)
R = (P(x+2)^3 - 4*P(x+1)^3 + 6*P(x)^3 - 4*P(x-1)^3)/6;
 
% Funzione P
function P = P(x)
  if x > 0
     P = x;
  else
     P = 0;
  end
 
% Funzione per ottenere il valore di un pixel dell'immagine originale
function f = f(Matrice,NumRighe,NumColonne,x,y) %i-->y, j-->x
if x<=0
    x=1;
end
if y<=0
    y=1;
end
if x>NumColonne
    x=NumColonne;
end
if y>NumRighe
    y=NumRighe;
end
f=Matrice(y,x);