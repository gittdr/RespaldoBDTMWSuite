SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/** Flags **/
-- +1 Check if paydetail exists, overwrite value if it does (Summary Systems/Meijer)
--		NOTE: the Summary Systems prepends the stop number to the pyd_description, so a check 
--			per stop can be made. Without this, it will check for any matching on the order
-- 		If flag +4 is set, then TransactionDate will be part of the match, but to the date part only.
-- +2 Use Rate from Pay Type		Will Pull Rate from Pay Type and calculate the amount
-- +4 Do not use Legheader			Will insert a Pay Datail without a Legheader or trip information.  
-- 									Pay Acts like a advance.
-- +8 Check if paydetail exists.  If it does add quantity and update.  
--		Only applies if Flag +1 = 0.
-- 		If flag +4 = 1, then TransactionDate will be part of the match, but to the date part only.
-- +16 Use Rate from Pay Type (Old Functionality)     Will Pull Rate from Pay Type and calculate the amount - leave amount = 0 
--									when quantity and rate are non zero
CREATE PROCEDURE [dbo].[tmail_AddPayDetail4] (@p_sLgh varchar(20),
										  @p_sMov varchar(20),
										  @p_sOrdHdr varchar(20),
							 			  @p_sQuantity varchar(20),
										  @p_DescPrefix varchar(45),	-- Will be Prepended to the pyd_description field
										  @p_asgn_type varchar(6),
										  @p_asgn_id varchar(13),
										  @p_PayType varchar(6),
										  @p_Flags varchar(10),
										  @p_TransactionDate varchar(30),
										  @p_sPayPeriod varchar(25),
										  @p_sMsgDate varchar(25),
										  @p_PaySchedulesHeaderName varchar(25))

AS

EXEC dbo.tmail_AddPayDetail5 @p_sLgh, @p_sMov, @p_sOrdHdr, @p_sQuantity, @p_DescPrefix, @p_asgn_type, @p_asgn_id, @p_PayType, @p_Flags, @p_TransactionDate, @p_sPayPeriod, @p_sMsgDate, @p_PaySchedulesHeaderName,''

GO
GRANT EXECUTE ON  [dbo].[tmail_AddPayDetail4] TO [public]
GO
