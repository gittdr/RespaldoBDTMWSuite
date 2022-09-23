SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdateLastTransactionID_sp_V2] (@TransactionID AS BIGINT, @CompanyID AS VARCHAR(8))
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM LastMATransactionID WHERE transaction_id = @TransactionID AND company_id = @CompanyID)
	BEGIN
		INSERT INTO LastMATransactionID
			(transaction_id, company_id)
		VALUES
			(@TransactionID, @CompanyID)
	END
END
GO
GRANT EXECUTE ON  [dbo].[UpdateLastTransactionID_sp_V2] TO [public]
GO
