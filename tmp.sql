
select 
    case 
        when pl_fit_date_diff > 0 then 'Delay' 
        when pl_fit_date_diff < 0 then 'Abnormal' 
        when pl_fit_date_diff = 0 then 'Normal'
    else null end as category_pl_fit_date_diff,
    case 
        when pl_weld_date_diff > 0 then 'Delay' 
        when pl_weld_date_diff < 0 then 'Abnormal' 
        when pl_weld_date_diff = 0 then 'Normal'
    else null end as category_pl_weld_date_diff,
    case 
        when lgtl_fit_date_diff > 0 then 'Delay' 
        when lgtl_fit_date_diff < 0 then 'Abnormal' 
        when lgtl_fit_date_diff = 0 then 'Normal'
    else null end as category_lgtl_fit_date_diff,
    case 
        when lgtl_weld_date_diff > 0 then 'Delay' 
        when lgtl_weld_date_diff < 0 then 'Abnormal' 
        when lgtl_weld_date_diff = 0 then 'Normal'
    else null end as category_lgtl_weld_date_diff,
    case 
        when erec_pd_date_diff > 0 then 'Delay' 
        when erec_pd_date_diff < 0 then 'Abnormal' 
        when erec_pd_date_diff = 0 then 'Normal'
    else null end as category_erec_pd_date_diff,
    case 
        when hand_erec_week_erec_date_diff > 0 then 'Delay' 
        when hand_erec_week_erec_date_diff < 0 then 'Abnormal' 
        when hand_erec_week_erec_date_diff = 0 then 'Normal'
    else null end as category_hand_erec_week_erec_date_diff,
    case 
        when hand_erec_week_exec_date_diff > 0 then 'Delay' 
        when hand_erec_week_exec_date_diff < 0 then 'Abnormal' 
        when hand_erec_week_exec_date_diff = 0 then 'Normal'
    else null end as category_hand_erec_week_exec_date_diff,
    case 
        when hand_erec_week_base_date_diff > 0 then 'Delay' 
        when hand_erec_week_base_date_diff < 0 then 'Abnormal' 
        when hand_erec_week_base_date_diff = 0 then 'Normal'
    else null end as category_hand_erec_week_base_date_diff,
    case 
        when hand_erec_week_wstg_case_diff > 0 then 'Delay' 
        when hand_erec_week_wstg_case_diff < 0 then 'Abnormal' 
        when hand_erec_week_wstg_case_diff = 0 then 'Normal'
    else null end as category_hand_erec_week_wstg_case_dif

from dap.ocean_yard.model_block_delay