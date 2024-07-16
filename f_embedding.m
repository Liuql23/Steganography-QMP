function [stego,dist] = f_embedding(cover, costmat, payload,H,params,WET)
if H==0
    [stego,dist]= f_sim_embedding(cover,costmat,payload, params);
else
   [ stego,dist]= f_stc_embedding(cover, costmat, payload,WET);
end