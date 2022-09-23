SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_CreateMiscInvoiceHeader] @p_trc_number varchar(8),	--1
						@p_driver1 varchar(8),		--2
						@p_driver2 varchar(8),		--3
						@p_trailer1 varchar(8),		--4
						@p_ivh_billto varchar(25),	--5 --PTS 61189 change cmp_id fields to 25 length
						@p_qty float,			--6
						@p_vol float,			--7
						@p_wgt float,			--8
						@p_mile float,			--9
						@p_pcs float,			--10
						@p_date varchar(25),		--11
						@p_time varchar(25),		--12
						@p_flags varchar(15),		--13
						@p_TotalCharge money,		--14
						@p_ivh_hdrnumber int OUT	--15

AS

/**
 * 
 * NAME:
 * dbo.tmail_CreateMiscInvoiceHeader
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  
 *
 * RETURNS:
 *    none.
 *
 * RESULT SETS: 
 *    The ivh_hdrnumber of the new invoiceheader record.
 *
 * PARAMETERS:
 * 001 - @p_trc_number  varchar(8), input, null;
 *        The tractor the invoice is for
 * 002 - @p_driver1 varchar(8), input
 *        The driver1 the invoice is for
 * 003 - @p_driver2 varchar(8), input
 *        The driver2 the invoice is for
 * 004 - @p_trailer1, varchar(8), input
 *        The trailer1 the invoice is for
 * 005 - @p_ivh_billto, varchar(8), input
 *        The billto for the invoice
 * 006 - @p_qty, float, input
 *        This is the qty
 * 007 - @p_vol, float, input
 *        This is the volume
 * 008 - @p_wgt, float, input
 *        This is the weight
 * 009 - @p_mile, float, input
 *        This is the mileage
 * 010 - @p_pcs, float, input
 *        This is the piece count
 * 011 - @p_date, varchar(25), input
 *        The date of the invoice (can hold just date or date/time)
 * 012 - @p_time, varchar(25), input
 *        The time of the invoice (can hold just time or date/time)
 * 013 - @p_flags, varchar(15), input
 *        Not used at this time
 * 014 - @p_TotalCharge, money, input
 *        
 * 015 - @p_ivh_hdrnumber, int, output
 * 	  The ivh_hdrnumber we created
 *
 * REFERENCES:
 * dbo.tmail_CreateMiscInvoiceHeader2
 * 
 * REVISION HISTORY:
 * 06/21/2006.01 – PTS33466 - MIZ – created
 * 11/30/2006.01 - PTS31449 - MIZ - Made into wrapper for new v2 proc (added ivh_revtype parameters)
 *
 **/

SET NOCOUNT ON 

EXEC dbo.tmail_CreateMiscInvoiceHeader2 @p_trc_number, @p_driver1, @p_driver2, @p_trailer1, @p_ivh_billto, @p_qty, @p_vol, @p_wgt, @p_mile, @p_pcs, @p_date, @p_time, @p_flags, @p_TotalCharge, @p_ivh_hdrnumber OUT, '', '', '', ''
GO
GRANT EXECUTE ON  [dbo].[tmail_CreateMiscInvoiceHeader] TO [public]
GO
