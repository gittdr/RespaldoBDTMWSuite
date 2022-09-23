SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDI990InsertPending]
	@dx_orderhdrnumber VARCHAR(20),
	@dx_ordernumber VARCHAR(30),	
	@dx_docnumber VARCHAR(30),
	@dx_sourcedate DATETIME,
	@p_trp_id VARCHAR(20)
AS

	INSERT INTO  
		dx_EDI990State
			(ord_hdrnumber, 
			est_Order_Number, 
			est_DocumentNumber, 
			est_SourceDate, 
			trp_id, 
			est_990State)
	VALUES(@dx_orderhdrnumber,
			@dx_ordernumber, 
			@dx_docnumber, 
			@dx_sourcedate, 
			@p_trp_id, 
			'1')

GO
GRANT EXECUTE ON  [dbo].[dx_EDI990InsertPending] TO [public]
GO
