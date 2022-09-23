SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[partorder_headerhistory]  @pohID int 
as  
 
SELECT  9999999 poh_hist_identity 
      , 9999999 poh_group_identity 
      , poh_identity   
      , poh_branch   
      , poh_supplier   
      , poh_plant   
      , poh_dock   
      , poh_jittime   
      , poh_sequence   
      , poh_reftype   
      , poh_refnum   
      , poh_datereceived   
      , poh_pickupdate   
      , poh_deliverdate   
      , poh_updatedby   
--      , '20491231 23:59'  poh_updatedon   
      , poh_updatedon   
      , poh_comment   
      , poh_type   
      , poh_release   
      , poh_status   
      , poh_scanned   
      , poh_timelineid   
 -- not on history     , poh_direction   
      , poh_tlmod_reason   
      , poh_supplieralias 
--  not on history   , poh_effective_basis
-- not on history    , poh_checksheetstatus
-- not on history    , poh_srf_receive
-- not on history    , poh_upotype
--  not on history   , poh_uporoute 
		, poh_xdock_event
  FROM   partorder_header   
  WHERE poh_identity = @pohID
    
UNION ALL  

SELECT  poh_hist_identity   
      , poh_group_identity   
      , poh_identity   
      , poh_branch   
      , poh_supplier   
      , poh_plant   
      , poh_dock   
      , poh_jittime   
      , poh_sequence   
      , poh_reftype   
      , poh_refnum   
      , poh_datereceived   
      , poh_pickupdate   
      , poh_deliverdate   
      , poh_updatedby   
      , poh_updatedon   
      , poh_comment   
      , poh_type   
      , poh_release   
      , poh_status   
      , poh_scanned   
      , poh_timelineid   
      , poh_tlmod_reason   
      , poh_supplieralias 
		, poh_xdock_event
     
  FROM  partorder_header_history   
  WHERE poh_identity = @pohID  
GO
GRANT EXECUTE ON  [dbo].[partorder_headerhistory] TO [public]
GO
