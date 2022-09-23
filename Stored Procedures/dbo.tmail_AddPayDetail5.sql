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
CREATE PROCEDURE [dbo].[tmail_AddPayDetail5] (@p_sLgh varchar(20),
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
										  @p_PaySchedulesHeaderName varchar(25),
										  @p_sStop varchar(20))

AS


SET NOCOUNT ON 
/** 
 * 
 * NAME: 
 * dbo.tmail_AddPayDetail4
 * 
 * TYPE: 
 * StoredProcedure
 * 
 * DESCRIPTION: 
 * This procedure will insert a paydetail.
 * 
 * RETURNS: 
 * Raises error for specific issues.
 *
 * RESULT SETS: 
 * none
 * 
 * PARAMETERS: 	
 * 001 - @p_sLgh, varchar(20), input
 *       This is the lgh_number to apply the pay detail to.  If no lgh_number is passed
 *	   in and the +4 flag isn't set, an error will be raised.
 * 002 - @p_sMov, varchar(20), input
 * 	 Will insert into paydetail.mov_number. If not populated, it will be looked
 *	   up by the lgh_number (if the lgh_number is null then an error is raised).
 * 003 - @p_sOrdHdr, varchar(20), input
 * 	 Will insert into paydetail.ord_hdrnumber. If not populated, it will be looked
 *	   up by the lgh_number (if the lgh_number is null then an error is raised).
 * 004 - @p_sQuantity, varchar(20), input
 * 	 This is the quantity to put in for the paydetail (pyd_quantity)
 * 005 - @p_DescPrefix, varchar(45), input
 * 	 If a value is passed in this parameter, it will be prepended to 
 *	   the pyd_description field.
 * 006 - @p_asgn_type, varchar(6), input
 * 	 The paydetail asgn_type for the paydetail (DRV, TRC, CAR, TRL).  If none is
 *	   specified, then it will be determined by the lgh_number, and asgn_type 
 *	   (in this order: DRV, CAR, TRC).
 * 007 - @p_asgn_id, varchar(13), input
 * 	 The paydetail asgn_id for the paydetail.  If none is specified, then it will
 *	   be determined by the lgh_number and asgn_type.
 * 008 - @p_PayType, varchar(6), input
 * 	 The paytype used for the paydetail.pyt_itemcode field.  If nothing is supplied
 *	   then it will look in the generalinfo table for the 'TotalMailDefaultPayType'
 *	   value.  If none in there an error is raised.
 * 009 - @p_Flags, varchar(10), input
 * 	 Any flags that are used in this process as defined above.
 * 010 - @p_TransactionDate, varchar(30), input
 * 	 The transaction date (pyd_transdate) for the paydetail.  If no value is supplied,
 *	   GETDATE() is used.
 * 011 - @p_sPayPeriod, varchar(25), input
 * 	 The payperiod (pyd_payperiod) for this paydetail.  
 *		- If no value is supplied, Apocalyse will be used.
 *		- If 'NEXT' will find the min(psd_date) from payschedulesdetail that is 
 *		   greater than @p_MsgDate.  If @p_MsgDate is not supplied, the system
 *		   date is used.
 *		- If @p_sPayPeriod is supplied, it will use that (in conjuction with @p_PaySchedulesHeaderName)
 * 012 - @p_sMsgDate, varchar(25), input
 * 	 Only used if the @p_sPayPeriod is set to 'NEXT'.
 * 013 - @p_PaySchedulesHeaderName, varchar(25), input
 * 	 The name (psh_name) of the payschedulesheader used to find the next
 *	   available payperiod from the payschedulesdetail table.  This parameter is only 
 *	   noticed if @p_sPayPeriod is set to a datetime.
 * 014 - @p_sStop, varchar(20), input
 *   Will insert into paydetail.stp_number_pacos. If not populated, it will be left
 *     as blank.

 * REFERENCES:
 * Calls001    – dbo.getsystemnumber
 * CalledBy002 – dbo.tmail_AddPayDetailHrsMiles3 

 * 
 * REVISION HISTORY: 
 * 07/12/2004 - PTS      - TA  - Stole $/Total Mail 1.5/Custom - Customer Specific/Meijer/tm_InsertPayDetail by MZ; added @asgn_id parm; Quantity float.
 * 10/31/2005 – PTS30432 - MIZ – Added new parameter (@p_PaySchedulesHeaderName) and brought to db standards.
 * 
 **/ 


EXEC dbo.tmail_AddPayDetail6 @p_sLgh, @p_sMov, @p_sOrdHdr, @p_sQuantity, @p_DescPrefix, @p_asgn_type, @p_asgn_id, @p_PayType, @p_Flags, @p_TransactionDate, @p_sPayPeriod, @p_sMsgDate, @p_PaySchedulesHeaderName,'',''

GO
GRANT EXECUTE ON  [dbo].[tmail_AddPayDetail5] TO [public]
GO
