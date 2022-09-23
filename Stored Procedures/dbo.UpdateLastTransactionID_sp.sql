SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdateLastTransactionID_sp] (@TransactionID AS BIGINT)
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM LastMATransactionID WHERE transaction_id = @TransactionID)
	BEGIN
		INSERT INTO LastMATransactionID
			(transaction_id)
		VALUES
			(@TransactionID)
	END
END
GO
GRANT EXECUTE ON  [dbo].[UpdateLastTransactionID_sp] TO [public]
GO
