SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.LTSL_Order_Import_Halt    Script Date: 6/1/99 11:54:36 AM ******/
create procedure [dbo].[LTSL_Order_Import_Halt] (@batch_number int)

-- vjh pts 4086 981202 
--	LTSL_Order_Import_Progress_Halt sets the halt indicator on
--	the interface table

as	
	update ltsl_interface set halt=-1 where batch=@batch_number

GO
GRANT EXECUTE ON  [dbo].[LTSL_Order_Import_Halt] TO [public]
GO
