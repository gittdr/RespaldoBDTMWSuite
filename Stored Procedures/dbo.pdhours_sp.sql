SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[pdhours_sp] (@pl_lgh int,@ps_asgn_type varchar(3) , @ps_asgn_id varchar(13) ) as
/*
PTS28791 7/15/5 DPETE Return paydetail info for clarity
PTS28805 DPETE add  stp_mfh_sequence   to sequence recs on datawindow. add updated by and date
    to restore on re rate
   
*/

select 	pdh_identity ,pdhours.pyd_number  ,pdh_standardhours ,pdh_othours ,pdh_eihours ,
		pdh_weeknum ,pdh_year    ,pdh_type ,pdh_date,pdh_miles ,pdh_stp_number 
 ,pyd_description, stp_mfh_sequence = IsNull(stops.stp_mfh_sequence,999) 
,pdh_updatedby
,pdh_updateddate 
from 	paydetail
JOIN pdhours on pdhours.pyd_number = paydetail.pyd_number
LEFT OUTER JOIN stops on stops.stp_number = pdhours.pdh_stp_number and stops.lgh_number = @pl_lgh
where 	paydetail.lgh_number = @pl_lgh and asgn_type = @ps_asgn_type 
and asgn_id = @ps_asgn_id


GO
GRANT EXECUTE ON  [dbo].[pdhours_sp] TO [public]
GO
