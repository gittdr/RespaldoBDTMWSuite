SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[add_TCHtransQHistory] 
	@ttq_id int
AS

-- This procedure queues up the transactions when Order Entry, Dispatch or TotalMail
--		update the status of the trip
--	Modified Date	By	Comment 							
--	-------------	---	-------						
--	4/27/2006	DPH	Created

insert into tchtransqhist (ttq_id, ttqh_mov_number, ttqh_userid, ttqh_issuedon, ttqh_cardnumber, ttqh_status, 
			  ttqh_tractor, ttqh_trailer, ttqh_tripnum, ttqh_msg)
	select ttq_id, ttq_mov_number, ttq_userid, ttq_issuedon, ttq_cardnumber, ttq_status, ttq_tractor,
			  ttq_trailer, ttq_tripnum, ttq_msg from tchtransqueue where ttq_id = @ttq_id
	
return
GO
GRANT EXECUTE ON  [dbo].[add_TCHtransQHistory] TO [public]
GO
