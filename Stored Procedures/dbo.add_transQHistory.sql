SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[add_transQHistory] 
	@ctq_id int
AS

-- This procedure queues up the transactions when Order Entry, Dispatch or TotalMail
--		update the status of the trip
--	Modified Date	By	Comment 							
--	-------------	---	-------						
--	4/22/2005		JZ	Created

insert into cdtransqhist (ctq_id, ctqh_mov_number, ctqh_userid, ctqh_issuedon, ctqh_status, ctqh_msg)
	select ctq_id, ctq_mov_number, ctq_userid, ctq_issuedon, ctq_status, ctq_msg from cdtransqueue where ctq_id = @ctq_id
	
return
GO
GRANT EXECUTE ON  [dbo].[add_transQHistory] TO [public]
GO
