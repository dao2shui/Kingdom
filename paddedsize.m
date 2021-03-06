function PQ=paddedsize(AB,CD,PARAM)
%PADDEDSIZE compute padded size useful for FFT-based filtering.
%PQ = paddedsize(AB),where AB is a two-element size vector,computes the
%two-element size vector PQ=2*AB.

%PQ=paddedsize(AB,'PWAAR2') computes the vector PQ such that

%PQ(1)=PQ(2)=2^nextpow2(2*m),where m is MAX(AB).

%PQ=paddedsize(AB,CD),where AB and CD are two-element size vector,computes
%the two-element vector PQ.The elements of PQ are the smallest even
%integers greatr than or equal to AB+CD-1.

%PQ =paddedsize(AB,CD,'pwr2') computes the vector PQ such that PQ(1) =PQ(2)
%=2^nextpow2(2*m),where m is MAX([AB CD]).
if nargin ==1
    PQ =2*AB;
else if nargin ==2 &&~ischar(CD)
        PQ = AB+CD-1;
        PQ = 2*ceil(PQ/2);
    else if nargin ==2
            m=max(AB); %Maximum dimension.
            
            %Find power-of-2 at least twice m.
            P =2^nextpow2(2*m);
            PQ =[P,P];
        else if (nargin ==3) && strcmpi(PARAM,'pwr2')
                m=max([AB,CD]);
                P=2^nextpow2(2*m);
                PQ =[P,P];
            else
                error('wrong number of inputs.')
            end
        end
    end
end

        