SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_IsInvoicePrepared] @ord_number varchar(20),
											 @sord_hdrnumber varchar(20),
											 @sstp_number varchar(20)

AS

/**************************************************************************
* 09/18/03 MZ: Created
* Will Return 1 if order invoice is PPD (prepared) and 0 otherwise
* 
* Note: This view doesn't validate the order number, but will return 0
*		if the order number is invalid (same as if invoice was not prepared)
*
* Order that parameters will be analyzed:
*	- order number
*	- order header number
*	- stop number (if no ord_hdrnumber on that stop, then use MIN(ord_hdrnumber) 
*		on the stops move.
***************************************************************************/

SET NOCOUNT ON

DECLARE @ord_hdrnumber int

SET @ord_hdrnumber = 0

-- First use the order number, if we were given one
IF LTRIM(RTRIM(@ord_number)) <> ''
  BEGIN
	SELECT @ord_hdrnumber = ord_hdrnumber 
	FROM orderheader (NOLOCK)
	WHERE ord_number = @ord_number
  END
ELSE IF LTRIM(RTRIM(@sord_hdrnumber)) <> ''		-- Next see if we have an order header number
  BEGIN
	SELECT @ord_hdrnumber = ord_hdrnumber 
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @sord_hdrnumber
  END
ELSE IF LTRIM(RTRIM(@sstp_number)) <> ''		-- Lastly, check if we have a stop number
  BEGIN
	-- Can we get the ord_hdrnumber right from this stop?
	SELECT @ord_hdrnumber = ISNULL(ord_hdrnumber,0)
	FROM stops (NOLOCK)
	WHERE stp_number = CONVERT(int, @sstp_number)

	IF (@ord_hdrnumber = 0)
		-- No order number on the stop, so use the MIN(ord_number) on that move.
		SELECT @ord_hdrnumber = MIN(ord_hdrnumber)
		FROM orderheader (NOLOCK)
		WHERE mov_number = (SELECT mov_number
							FROM stops (NOLOCK)
							WHERE stp_number = CONVERT(int, @sstp_number))
  END
ELSE
	SET @ord_hdrnumber = 0

IF EXISTS (SELECT ord_invoicestatus 
				FROM orderheader (NOLOCK)
				WHERE ord_hdrnumber = @ord_hdrnumber AND ord_invoicestatus = 'PPD')
	SELECT '1' Result
ELSE
	SELECT '0' Result
GO
GRANT EXECUTE ON  [dbo].[tmail_IsInvoicePrepared] TO [public]
GO
