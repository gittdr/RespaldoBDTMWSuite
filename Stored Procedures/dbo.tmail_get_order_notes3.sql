SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_order_notes3] @order varchar(12), @notetype varchar(6), @NoWrapFlag VARCHAR(30)

AS
	DECLARE @ordhdrnumber int,
		@ordhdrtext varchar(18)

	SELECT @ordhdrnumber = ord_hdrnumber 
	FROM orderheader (NOLOCK) 
	WHERE ord_number = @order
	
	SELECT @ordhdrtext = CONVERT(varchar(18), @ordhdrnumber)

	IF isnull(@ordhdrnumber, 0) = 0
		RAISERROR ('Unknown Order: %s', 16, 1, @order)
	ELSE
		exec dbo.tmail_get_notes2_sp 'orderheader', @ordhdrtext, @notetype 

GO
GRANT EXECUTE ON  [dbo].[tmail_get_order_notes3] TO [public]
GO
