SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ico_intercompany_stop_leaf_fn](@stp_number int)
RETURNS int

AS
BEGIN
	DECLARE @next_stp_number int
	
	SET	@next_stp_number = @stp_number
	WHILE	ISNULL(@next_stp_number, 0) > 0 BEGIN
		SET @next_stp_number = 0
		
		SELECT	@next_stp_number = stp.stp_ico_stp_number_child
		FROM	stops stp
		WHERE	stp.stp_number = @stp_number
		
		IF @next_stp_number > 0 BEGIN
			SET @stp_number = @next_stp_number
		END
	END
	
	RETURN @stp_number
	
END
GO
GRANT EXECUTE ON  [dbo].[ico_intercompany_stop_leaf_fn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ico_intercompany_stop_leaf_fn] TO [public]
GO
