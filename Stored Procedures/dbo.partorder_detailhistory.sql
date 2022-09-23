SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[partorder_detailhistory]  @pohID int 
as 

SELECT  9999999 pod_hist_identity 
      , 9999999 pod_group_identity 
      , pod_identity 
      , poh_identity 
      , pod_partnumber 
      , pod_description 
      , pod_uom 
      , pod_originalcount 
      , pod_originalcontainers 
      , pod_countpercontainer 
      , pod_adjustedcount 
      , pod_adjustedcontainers 
      , pod_pu_count 
      , pod_pu_containers 
      , pod_del_count 
      , pod_del_containers 
      , pod_cur_count 
      , pod_cur_containers 
      , pod_status 
      , pod_updatedby 
--      , '20491231 23:59'  pod_updatedon 
      , pod_updatedon 
      , pod_release 
      , pod_sourcefile 
      , pod_originalweight 
      , pod_pu_weight 
      , pod_cur_weight 
      , pod_adjustedweight 
      , pod_weightunit 
  FROM  partorder_detail pd 
  WHERE poh_identity = @pohID 
  --and exists (select 1 from partorder_detail_history ph where 
   --    pd.pod_partnumber = ph.pod_partnumber and pd.poh_identity = ph.poh_identity)
UNION ALL

SELECT  pod_hist_identity 
      , pod_group_identity 
      , pod_identity 
      , poh_identity 
      , pod_partnumber 
      , pod_description 
      , pod_uom 
      , pod_originalcount 
      , pod_originalcontainers 
      , pod_countpercontainer 
      , pod_adjustedcount 
      , pod_adjustedcontainers 
      , pod_pu_count 
      , pod_pu_containers 
      , pod_del_count 
      , pod_del_containers 
      , pod_cur_count 
      , pod_cur_containers 
      , pod_status 
      , pod_updatedby 
      , pod_updatedon 
      , pod_release 
      , pod_sourcefile 
      , pod_originalweight 
      , pod_pu_weight 
      , pod_cur_weight 
      , pod_adjustedweight 
      , pod_weightunit 
  FROM  partorder_detail_history 
  WHERE poh_identity = @pohID
GO
GRANT EXECUTE ON  [dbo].[partorder_detailhistory] TO [public]
GO
