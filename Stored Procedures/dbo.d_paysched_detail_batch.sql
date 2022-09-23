SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/****** Object:  Stored Procedure dbo.d_paysched_detail_batch    Script Date: 6/24/98 10:17:22 AM ******/
CREATE PROC [dbo].[d_paysched_detail_batch](@psh_id int, @supervisor char(1))
AS

DECLARE @money money,
	@char char(1)

SELECT 	payschedulesdetail.psd_date, 
	payschedulesdetail.psd_status, 
	payschedulesdetail.psh_id, 
	payschedulesdetail.psd_id,
	payschedulesdetail.psd_batch_id,
	payschedulesdetail.psd_batch_status,
	@char close_batch,
	@char reopen_batch,
	@money batch_total,
	@supervisor supervisor,
	@char just_changed,
	payschedulesdetail.psd_chkissuedate
INTO #temp_table
FROM payschedulesdetail
WHERE payschedulesdetail.psh_id = @psh_id 

UPDATE 	#temp_table
SET	batch_total = IsNull((select sum(pd.pyd_amount)
			      from paydetail pd
			      where pd.pyd_status in ('PND', 'REL', 'PRN', 'XFR', 'COL') and
				    pd.psd_id = t.psd_id and
				    pd.psd_batch_id is not null), 0)
FROM	#temp_table t

SELECT * FROM #temp_table

GO
GRANT EXECUTE ON  [dbo].[d_paysched_detail_batch] TO [public]
GO
