E_rap_avg = ELE_RAP_t(:,2:end)'/200;
E_map_avg = ELE_MAP_t(:,2:end)'/200;
B_rap_avg = PS_RAP_total(:,2:end)'/200;
B_map_avg = PS_MAP_total(:,2:end)'/200;
save('static_para_sat.mat','E_rap_avg','E_map_avg','B_rap_avg','B_map_avg');