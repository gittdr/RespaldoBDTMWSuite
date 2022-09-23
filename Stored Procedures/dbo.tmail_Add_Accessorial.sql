SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[tmail_Add_Accessorial] 	@p_sOrdnumber varchar(12),	--1
						@p_sChargetype varchar(6),	--2
						@p_sQuantity varchar(12),	--3
						@p_sRate varchar(12),		--4
						@p_sCompany varchar(25),		--5
						@p_sFlags varchar(12)		--6

AS	

/**
 * 
 * NAME:
 * dbo.tmail_Add_Accessorial
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Wrapper to dbo.tmail_Add_Accessorial2
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * none
 *
 * PARAMETERS:
 * 001 - @p_sOrdnumber      VARCHAR(12), input;
 *       TMWSuite order number the the accessorial is to be attached to. Required.
 * 002 - @p_sChargetype     VARCHAR(6), input;
 *       Charge type for accessorial. Required and must exist in TMWSuite.
 * 003 - @p_sQuantity  		VARCHAR(5), input;
 *       Quantity for accessorial
 * 004 - @p_sRate 			VARCHAR(5), input;
 *       Rate for accessorial
 * 005 - @p_sCompany      	VARCHAR(5), input;
 *       Company ID for accessorial
 * 006 - @p_sFlags		  	VARCHAR(5), input;
 *	 None
 *
 * REFERENCES:
 * dbo.tmail_Add_Accessorial2
 * 
 * REVISION HISTORY:
 * 03/24/2006.01 – PTS 31262 - David Gudat – initial version
 * 06/29/2006.01 - PTS       - MIZ - Made this a wrapper to tmail_Add_Accessorial2 to add new parameters for creating misc invoices (flag +1)
 *                                    
 **/

SET NOCOUNT ON

EXEC dbo.tmail_Add_Accessorial2	@p_sOrdnumber, @p_sChargetype, @p_sQuantity, @p_sRate, @p_sCompany, @p_sFlags, '', '', '', '', '', '', '', '', '', '', ''
GO
GRANT EXECUTE ON  [dbo].[tmail_Add_Accessorial] TO [public]
GO
