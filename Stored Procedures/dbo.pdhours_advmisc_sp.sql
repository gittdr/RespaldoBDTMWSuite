SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  create procedure [dbo].[pdhours_advmisc_sp] (@ps_asgn_type varchar(3) , @ps_asgn_id varchar(13),@pytitem varchar(6) ) as  
/*  
PTS28791 7/15/5 DPETE 4/18/08 recode Pauls into main source 40260 DPETE   
*/  
  
select  pdh_identity ,pdhours.pyd_number  ,pdh_standardhours ,pdh_othours ,pdh_eihours ,  
  pdh_weeknum ,pdh_year    ,pdh_type ,pdh_date,pdh_miles ,pdh_stp_number   
 ,pyd_description   
from  paydetail  
JOIN pdhours on pdhours.pyd_number = paydetail.pyd_number  
where   asgn_type = @ps_asgn_type   
and asgn_id = @ps_asgn_id  
and pyt_itemcode = @pytitem  
and pyd_status in ('PND', 'HLD')  
  
  
GO
GRANT EXECUTE ON  [dbo].[pdhours_advmisc_sp] TO [public]
GO
