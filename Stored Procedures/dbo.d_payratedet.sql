SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/****** Object:  Stored Procedure dbo.d_payratedet    Script Date: 4/5/99 2:35:59 PM ******/
create PROC [dbo].[d_payratedet] (@payrate_hdrnumber   varchar(6))
AS

/* PTS 32575 - DJM - This proc appears to have been used for a long time as a source for datawindow
	d_payratedet - but never placed into VSS.  Removing the Timestamp column from the result set
	and registering in VSS
*/

    SELECT payratedetail.prh_number,   
         payratedetail.prd_sequence,   
         payratedetail.prd_break1,   
         payratedetail.prd_rate1,   
         payratedetail.prd_break2,   
         payratedetail.prd_rate2   
    FROM payratedetail  
   WHERE ( payratedetail.prh_number = @payrate_hdrnumber )

GO
GRANT EXECUTE ON  [dbo].[d_payratedet] TO [public]
GO
