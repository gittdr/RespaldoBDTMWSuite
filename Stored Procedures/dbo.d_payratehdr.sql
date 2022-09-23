SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



create PROC [dbo].[d_payratehdr] (@payrate_hdrnumber   varchar(6))
AS
/****** Object:  Stored Procedure dbo.d_payratehdr    Script Date: 8/20/97 1:58:09 PM ******/


  SELECT payrateheader.prh_number,   
         payrateheader.prh_basis,   
         payrateheader.prh_compmethod,   
         payrateheader.prh_unitbasis,   
         payrateheader.prh_unit,   
         payrateheader.prh_rateunit,   
         payrateheader.prh_minimum,   
         payrateheader.pyt_itemcode,   
         payrateheader.prh_remark,   
         payrateheader.prh_name,   
         payrateheader.prh_distbasis,   
         payrateheader.prh_distplus,   
         payrateheader.prh_brkpt,   
         payrateheader.prh_teamsplit,   
         paytype.pyt_basis,   
         paytype.pyt_basisunit,   
         paytype.pyt_unit,   
         paytype.pyt_rateunit,   
         paytype.pyt_pretax,   
         paytype.pyt_minus,   
         payrateheader.prh_revreduction,   
         payrateheader.prh_config,
         payrateheader.prh_usedb,

		 --vmj1+	PTS 11668	11/02/2001	Supports advanced agent pay features.
		 payrateheader.prh_companyminimum
		 --vmj1-

    FROM payrateheader,   
         paytype  
   WHERE ( payrateheader.pyt_itemcode = paytype.pyt_itemcode ) and  
         ( ( payrateheader.prh_number = @payrate_hdrnumber ) )    
GO
GRANT EXECUTE ON  [dbo].[d_payratehdr] TO [public]
GO
