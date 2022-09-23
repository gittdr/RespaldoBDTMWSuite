SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 07/12/04 TA  Stole $/Total Mail 1.5/Custom - Customer Specific/Meijer/tm_InsertPayDetail by MZ; added @asgn_id parm; Quantity float.
 * 10/31/05 MZ  Removed code and now calls tmail_AddPayDetail4.
*/


CREATE PROCEDURE [dbo].[tmail_AddPayDetail3] (@sLgh varchar(20),
												@sMov varchar(20),
												@sOrdHdr varchar(20),
												@sQuantity varchar(20),
												@DescPrefix varchar(45),	-- Will be Prepended to the pyd_description field
												@asgn_type varchar(6),
												@asgn_id varchar(13),
												@PayType varchar(6),
												@Flags varchar(10),
												@TransactionDate varchar(30),
												@sPayPeriod varchar(25),
												@sMsgDate varchar(25))

AS

EXEC dbo.tmail_AddPayDetail4 @sLgh, @sMov, @sOrdHdr, @sQuantity, @DescPrefix, @asgn_type, @asgn_id, @PayType, @Flags, @TransactionDate, @sPayPeriod, @sMsgDate, ''
GO
GRANT EXECUTE ON  [dbo].[tmail_AddPayDetail3] TO [public]
GO
