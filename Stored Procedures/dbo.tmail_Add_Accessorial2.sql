SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[tmail_Add_Accessorial2] @p_sOrdnumber varchar(12),		--1
						@p_sChargetype varchar(6),	--2
						@p_sQuantity varchar(12),	--3
						@p_sRate varchar(12),		--4
						@p_sCompany varchar(25),	--5
						@p_sFlags varchar(12),		--6
						@p_trc_number varchar(8),	--7
						@p_driver1 varchar(8),		--8
						@p_driver2 varchar(8),		--9
						@p_trailer1 varchar(8),		--10
						@p_ivh_billto varchar(25),	--11
						@p_date varchar(25),		--12
						@p_time varchar(25),		--13
						@p_sVolume varchar(12),		--14
						@p_sWeight varchar(12),		--15
						@p_sMiles varchar(12),		--16
						@p_sPieces varchar(12)		--17

AS	

/**
 * 
 * NAME:
 * dbo.tmail_Add_Accessorial2
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  Inserts an accessorial charge in the invoicedetail table IF no invoice currently
 *  exists for the order number passed.  
 *
 * RETURNS:
 * 		1   	success
 *		-1	database error
 *		-2	invalid order number or order status (not AVL, PLN, DSP, STD or CMP) 
 *		-3	invalid charge type, or retired chargetype
 *		-4  	invoice exists, cannot add charge type
 *              -5	could not create invoiceheader number. Only fires if +1 flag is set.
 * 		-6	invalid input parameter
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
 *       Rate for accessorial (if not set, will use the rate for the selected ChargeType).
 * 005 - @p_sCompany      	VARCHAR(5), input;
 *       Company ID for accessorial
 * 006 - @p_sFlags		  	VARCHAR(5), input;
 *	 	+1 - Misc invoice (will create invoice header and attach the detail to it)
 * 007 - @p_trc_number	varchar(8), input
 * 008 - @p_driver1	varchar(8), input
 * 009 - @p_driver2	varchar(8), input
 * 010 - @p_trailer1	varchar(8), input
 * 011 - @p_ivh_billto	varchar(8), input
 *       The billto company id for this invoiceheader (only applies if +1 flag is set)
 * 012 - @p_date, varchar(25), input
 * 013 - @p_time, varchar(25), input
 * 014 - @p_sVolume	varchar(5), input
 * 015 - @p_sWeight	varchar(5), input
 * 016 - @p_sMiles	varchar(5), input
 * 017 - @p_sPieces	varchar(5), input
 *
 * REFERENCES:
 * dbo.tmail_Add_Accessorial3
 * 
 * REVISION HISTORY:
 * 03/24/2006.01 – PTS 31262 - David Gudat – initial version
 * 06/29/2006.01 - PTS       - MIZ - Created v2 to add the +1 flag as associated functionality.
 * 11/30/2006.01 - PTS 31449 - MIZ - Made into wrapper for tmail_Add_Accessorial3, which added the ivh_revtype parameters.
 *
 **/

SET NOCOUNT ON

EXEC dbo.tmail_Add_Accessorial3	@p_sOrdnumber, @p_sChargetype, @p_sQuantity, @p_sRate, @p_sCompany, @p_sFlags, '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''
GO
GRANT EXECUTE ON  [dbo].[tmail_Add_Accessorial2] TO [public]
GO
