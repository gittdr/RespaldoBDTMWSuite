SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[ReProcessSettlement_SP]
		@ASGN 		INTEGER, 
		@LGH_NUMBER	INTEGER,
		@ORD_HDRNUMBER	INTEGER,
		@ASGN_TYPE	VARCHAR(6),
		@ASGN_ID 	VARCHAR(13),
		@ERROR 		INTEGER OUTPUT
as

-- Reset the pay status so that this settlement will be reprocessed.
update assetassignment set pyd_status = 'NPD' where
	asgn_number = @ASGN

-- Delete any existing linehaul pay.
delete from paydetail where 
	lgh_number = @LGH_NUMBER and 
	ord_hdrnumber = @ORD_HDRNUMBER and 
	asgn_type = @ASGN_TYPE and 
	asgn_id = @ASGN_ID and 
	(isnull(tar_tarriffnumber, 0) > 0
	OR pyt_itemcode = 'IVA')
GO
GRANT EXECUTE ON  [dbo].[ReProcessSettlement_SP] TO [public]
GO
