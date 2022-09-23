SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_AddPayDetailHrsMiles5] (@p_sLgh varchar(10),
						@p_sQuantity varchar(20),
						@p_sHours varchar(20),
						@p_sMiles varchar(20),
						@p_DescPrefix varchar(45),	
						@p_asgn_type varchar(6),
						@p_asgn_id varchar(13),
						@p_PayType varchar(6),
						@p_Flags varchar(10),
						@p_TransactionDate varchar(30),
						@p_sPayPeriod varchar(25),
						@p_sMsgDate varchar(25),
						@p_PaySchedulesHeaderName varchar(25),
						@p_Stop varchar(20),
						@p_cht_itemcode varchar(6))

AS

/** 
 * 
 * NAME: 
 * dbo.tmail_AddPayDetailHrsMiles3
 * 
 * TYPE: 
 * StoredProcedure
 * 
 * DESCRIPTION: 
 * This procedure will call tmail_AddPayDetail3 to add a paydetail.
 * 
 * RETURNS: 
 * none 
 *
 * RESULT SETS: 
 * none
 * 
 * PARAMETERS: 	(**See dbo.tmail_AddPayDetail4 for details on parameters**)
 * 001 - @p_sLgh, varchar(10), input
 *       This is the lgh_number to apply the pay detail to.
 * 002 - @p_sQuantity, varchar(20), input
 * 	 This is the quantity to put in for the paydetail (pyd_quantity)
 * 003 - @p_sHours, varchar(20), input
 * 	 This is the number of hours that will be applied to the paydetail 
 *	   if PayType is of hours (HR) type.
 * 004 - @p_sMiles, varchar(20), input
 * 	 This is the number of miles that will be applied to the paydetail 
 *	   if PayType is of hours (MIL) type.
 * 005 - @p_DescPrefix, varchar(45), input
 * 	 If a value is passed in this parameter, it will be prepended to 
 *	   the pyd_description field,
 * 006 - @p_asgn_type, varchar(6), input
 * 	 The paydetail asgn_type for the paydetail.
 * 007 - @p_asgn_id, varchar(13), input
 * 	 The paydetail asgn_id for the paydetail.
 * 008 - @p_PayType, varchar(6), input
 * 	 The paytype used for this paydetail
 * 009 - @p_Flags, varchar(10), input
 * 	 Any flags that are used in this process.
 * 010 - @p_TransactionDate, varchar(30), input
 * 	 The transaction date for the paydetail.
 * 011 - @p_sPayPeriod, varchar(25), input
 * 	 The payperiod for this paydetail.
 * 012 - @p_sMsgDate, varchar(25), input
 * 	 Only used if the PayPeriod is set to 'NEXT'.
 * 013 - @p_PaySchedulesHeaderName, varchar(25), input
 * 	 The name (psh_name) of the payschedulesheader used to find the next
 *	   available payperiod from the payschedulesdetail table.  

 * REFERENCES:
 * Calls001    – tmail_AddPayDetail3
 * CalledBy001 – tmail_AddPayDetailHrsMiles2 
 * CalledBy002 – Directly from view handler within the Transaction agent. 

 * 
 * REVISION HISTORY: 
 * 10/31/2005 – PTS30432 - MIZ – Added new parameter (@p_PaySchedulesHeaderName)
 * 
 **/ 

DECLARE	@pyt_rateunit varchar(6)

select @pyt_rateunit = pyt_rateunit from paytype
	where pyt_itemcode = @p_PayType

IF ISNULL(@p_sQuantity, '') = ''
	BEGIN
	if @pyt_rateunit = 'HR'
		set @p_sQuantity = @p_sHours
	else if @pyt_rateunit = 'MIL'
		set @p_sQuantity = @p_sMiles
	else
		RETURN
	END
	
EXEC dbo.tmail_AddPayDetail6 @p_sLgh, '', '', @p_sQuantity, @p_DescPrefix, @p_asgn_type, @p_asgn_id, @p_PayType, @p_Flags, @p_TransactionDate, @p_sPayPeriod, @p_sMsgDate, @p_PaySchedulesHeaderName,@p_Stop,@p_cht_itemcode
GO
GRANT EXECUTE ON  [dbo].[tmail_AddPayDetailHrsMiles5] TO [public]
GO
