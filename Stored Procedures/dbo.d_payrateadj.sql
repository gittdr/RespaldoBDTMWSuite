SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_payrateadj    Script Date: 6/1/99 11:54:22 AM ******/
create PROC [dbo].[d_payrateadj] (@payrate_hdrnumber   varchar(6))

AS
  SELECT payrateadjustment.prh_number,   
         payrateadjustment.prj_sequence,   
         payrateadjustment.pyt_itemcode,   
         payrateadjustment.prj_basis,   
         payrateadjustment.prj_rate,   
         payrateadjustment.trl_fleet  
    FROM payrateadjustment  
   WHERE payrateadjustment.prh_number = @payrate_hdrnumber 





GO
GRANT EXECUTE ON  [dbo].[d_payrateadj] TO [public]
GO
