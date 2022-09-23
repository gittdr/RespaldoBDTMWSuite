SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.LTSL_Order_Import_Progress    Script Date: 6/1/99 11:54:36 AM ******/
create procedure [dbo].[LTSL_Order_Import_Progress] (@batch_number int)

-- vjh pts 4086 981202 
--	LTSL_Order_Import_Progress_Progress checks the interface
--	table and returns two columns:
--		Progress_Percent
--		Progress_Message

as	
	select progress_percent,progress_message from ltsl_interface where batch=@batch_number
GO
GRANT EXECUTE ON  [dbo].[LTSL_Order_Import_Progress] TO [public]
GO
