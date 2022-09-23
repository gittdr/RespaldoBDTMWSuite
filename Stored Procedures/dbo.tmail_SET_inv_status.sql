SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[tmail_SET_inv_status] @OrdNum varchar(12), @NewStat varchar(6) 

AS

SET NOCOUNT ON

	DECLARE @OrderCount int
	SELECT @OrderCount = COUNT(*) 
	FROM orderheader (NOLOCK)
	WHERE ord_number = @OrdNum
	
	IF @OrderCount <> 1 
		BEGIN
		RAISERROR ('Order Number %s not found', 16, 1, @OrdNum)
		RETURN
		END
	UPDATE orderheader SET ord_invoicestatus = @NewStat WHERE ord_number = @OrdNum
GO
GRANT EXECUTE ON  [dbo].[tmail_SET_inv_status] TO [public]
GO
