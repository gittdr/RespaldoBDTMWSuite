SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_payrateacc    Script Date: 6/1/99 11:54:22 AM ******/
create PROC [dbo].[d_payrateacc] (@payrate_hdrnumber   varchar(6))

AS
  SELECT payrateaccessorial.prh_number,   
         payrateaccessorial.pra_sequence,   
         payrateaccessorial.cht_itemcode,   
         payrateaccessorial.pyt_itemcode,   
      payrateaccessorial.pra_rate,   
         payrateaccessorial.pra_milesplit,   
         payrateaccessorial.pra_requirestop  
   FROM payrateaccessorial  
   WHERE payrateaccessorial.prh_number = @payrate_hdrnumber



GO
GRANT EXECUTE ON  [dbo].[d_payrateacc] TO [public]
GO
