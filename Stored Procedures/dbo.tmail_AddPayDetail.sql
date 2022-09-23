SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 07/12/04 TA  Stole $/Total Mail 1.5/Custom - Customer Specific/Meijer/tm_InsertPayDetail by MZ; added @asgn_id parm; Quantity float.
*/

/** Flags **/
-- +1	Check if paydetail exists, overwrite value if it does (Summary Systems/Meijer)
--		NOTE: the Summary Systems prepends the stop number to the pyd_description, so a check 
--			per stop can be made. Without this, it will check for any matching on the order
-- +2 Use Rate from Pay Type		Will Pull Rate from Pay Type and calculate the amount
-- +4 Do not use Legheader			Will insert a Pay Datail without a Legheader or trip information.  
-- 									Pay Acts like a advance.

CREATE PROCEDURE [dbo].[tmail_AddPayDetail] (@sLgh varchar(20),
												@sMov varchar(20),
												@sOrdHdr varchar(20),
												@sQuantity varchar(20),
												@DescPrefix varchar(45),	-- Will be Prepended to the pyd_description field
												@asgn_type varchar(6),
												@asgn_id varchar(13),
												@PayType varchar(6),
												@Flags varchar(10))

AS


	EXEC dbo.tmail_AddPayDetail2 @sLgh ,
							@sMov ,
							@sOrdHdr ,
							@sQuantity ,
							@DescPrefix ,	-- Will be Prepended to the pyd_description field
							@asgn_type ,
							@asgn_id ,
							@PayType ,
							@Flags,
						    NULL

GO
GRANT EXECUTE ON  [dbo].[tmail_AddPayDetail] TO [public]
GO
