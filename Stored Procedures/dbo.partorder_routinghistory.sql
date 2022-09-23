SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[partorder_routinghistory]  @pohID int 
as 

/* fake group by holds together all the routing records put into history on one update */
SELECT 9999999 por_hist_identity
      ,9999999 por_group_identity
      ,por_identity
      ,poh_identity
      ,por_master_ordhdr
      ,por_ordhdr
      ,por_origin
      ,por_begindate
      ,por_destination
      ,por_enddate
      ,por_updatedby
--      ,'20491231 23:59' por_updatedon -- force to top
      ,por_updatedon -- will be at top anyway since is most recent record
    -- not in history  ,por_sequence
    -- not in history  ,por_trl_unnload
      ,por_route 
      , datediff(mi,getdate(),getdate()) fakegroupby
	  ,por_trl_unload_dt
	  ,por_sequence
      ,0 por_identity_flag -- MRH flags to indicate that the column has changed and should be highlighted
      ,0 por_master_ordhdr_flag
      ,0 por_ordhdr_flag
      ,0 por_origin_flag
      ,0 por_begindate_flag
      ,0 por_destination_flag
      ,0 por_enddate_flag
      ,0 por_route_flag
	  ,0 por_trl_unload_dt_flag
	  ,0 por_sequence_flag
  FROM dbo.partorder_routing pr
  WHERE poh_identity = @pohID
--and exists (select 1 from partorder_routing_history ph where 
--        pr.por_identity = ph.por_identity)
UNION ALL
SELECT por_hist_identity
      ,por_group_identity
      ,por_identity
      ,poh_identity
      ,por_master_ordhdr
      ,por_ordhdr
      ,por_origin
      ,por_begindate
      ,por_destination
      ,por_enddate
      ,por_updatedby
      ,por_updatedon
      ,por_route
      ,((datediff(mi,por_updatedon,getdate()) / 3) * 3 ) fakegroupby  -- group in 3 minute intervals
	  ,por_trl_unload_dt
	  ,por_sequence
      ,0 por_identity_flag -- MRH flags to indicate that the column has changed and should be highlighted
      ,0 por_master_ordhdr_flag
      ,0 por_ordhdr_flag
      ,0 por_origin_flag
      ,0 por_begindate_flag
      ,0 por_destination_flag
      ,0 por_enddate_flag
      ,0 por_route_flag
	  ,0 por_trl_unload_dt_flag
	  ,0 por_sequence_flag
  FROM dbo.partorder_routing_history
  WHERE poh_identity = @pohID
GO
GRANT EXECUTE ON  [dbo].[partorder_routinghistory] TO [public]
GO
