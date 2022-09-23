SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[get_paydetail_defaults_sp] (@ps_branch_id varchar(12),@ps_lgh_type1 varchar(6),@ps_mpp_type1 varchar(6))
as

  SELECT paydetaildefaults.brn_id,   
         paydetaildefaults.lgh_type1,   
         paydetaildefaults.mpp_type1,   
         paydetaildefaults.pyt_itemcode,   
         paydetaildefaults.pdd_quantity,   
         paydetaildefaults.pdd_rate  
    FROM paydetaildefaults  
   WHERE paydetaildefaults.brn_id = @ps_branch_id   and
				 (paydetaildefaults.lgh_type1 = @ps_lgh_type1 or paydetaildefaults.lgh_type1 = 'UNK') and
				 (paydetaildefaults.mpp_type1 = @ps_mpp_type1 or paydetaildefaults.mpp_type1 = 'UNK') 

GO
GRANT EXECUTE ON  [dbo].[get_paydetail_defaults_sp] TO [public]
GO
