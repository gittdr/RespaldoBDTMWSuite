SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_AddPayDetailHrsMiles2] (@sLgh varchar(10),
												@sQuantity varchar(20),
												@sHours varchar(20),
												@sMiles varchar(20),
												@DescPrefix varchar(45),	-- Will be Prepended to the pyd_description field
												@asgn_type varchar(6),
												@asgn_id varchar(13),
												@PayType varchar(6),
												@Flags varchar(10),
												@TransactionDate varchar(30),
												@sPayPeriod varchar(25),
												@sMsgDate varchar(25))

AS

 /**
 * 
 * REVISION HISTORY: 
 * 10/31/2005 – PTS30432 - MIZ – Changed to call dbo.tmail_AddPayDetailHrsMiles3
 * 
 **/ 

EXEC dbo.tmail_AddPayDetailHrsMiles3 	@sLgh,
					@sQuantity,
					@sHours,
					@sMiles,
					@DescPrefix,	-- Will be Prepended to the pyd_description field
					@asgn_type,
					@asgn_id,
					@PayType,
					@Flags,
					@TransactionDate,
					@sPayPeriod,
					@sMsgDate,
					''		-- @v_PaySchedulesHeaderName
GO
GRANT EXECUTE ON  [dbo].[tmail_AddPayDetailHrsMiles2] TO [public]
GO
