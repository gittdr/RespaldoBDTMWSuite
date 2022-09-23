SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[dx_EDI990CancelLastPending]
	@p_trp_id VARCHAR(20),
	@dx_docnumber VARCHAR(30),
	@dx_ordernumber VARCHAR(30),
	@dx_orderhdrnumber VARCHAR(20),
	@est_990state INT = 2
AS
	DECLARE @StateIdent as INT
	set @StateIdent = (
		Select 
			MAX(est_Ident)
		FROM
			dx_EDI990State
		WHERE 
			est_990State= 1
		AND
			trp_id = @p_trp_id
		AND
			est_DocumentNumber = @dx_docnumber
		AND 
			est_Order_Number = @dx_ordernumber
		AND
			ord_hdrnumber = @dx_orderhdrnumber)
	
	IF ISNULL(@StateIdent,0) > 0 
		BEGIN
			UPDATE 
				dx_EDI990State
			SET
				est_990State= @est_990state
			WHERE 
				trp_id = @p_trp_id
			AND
				est_DocumentNumber = @dx_docnumber
			AND 
				est_Order_Number = @dx_ordernumber
			AND
				ord_hdrnumber = @dx_orderhdrnumber
			AND
				est_Ident <= @StateIdent

			DECLARE @p_HostName VARCHAR(10), @p_Command VARCHAR(255)
			SELECT @p_HostName = LEFT(HOST_NAME(), 10), @p_Command = 'Generated a 990 reply for order # ' + @dx_orderhdrnumber
			
			IF @est_990state = 2
			BEGIN
				UPDATE
					orderheader
				SET
					ord_edistate = ord_edistate + 1, ord_ediuseraction = NULL
				WHERE
					ord_hdrnumber = @dx_orderhdrnumber
				AND
					ord_edistate in (20, 30, 36)

				IF @@ROWCOUNT = 1
					EXEC dx_History_Update @p_HostName, 'DX CREATE 990', @p_Command, 1, @dx_ordernumber
			END
		END

GO
GRANT EXECUTE ON  [dbo].[dx_EDI990CancelLastPending] TO [public]
GO
