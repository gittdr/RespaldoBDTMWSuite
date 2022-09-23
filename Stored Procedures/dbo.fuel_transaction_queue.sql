SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[fuel_transaction_queue] 
	@amov_number int
AS

-- This procedure queues up the transactions when Order Entry, Dispatch or TotalMail
--		update the status of the trip
--	Modified Date	By	Comment 							
--	-------------	---	-------						
--	4/22/2005		JZ	Created

insert into cdtransqueue (ctq_mov_number, ctq_userid, ctq_issuedon, ctq_status, ctq_msg)
values (@amov_number, suser_sname(), getdate(), null, null)
	
return
GO
GRANT EXECUTE ON  [dbo].[fuel_transaction_queue] TO [public]
GO
