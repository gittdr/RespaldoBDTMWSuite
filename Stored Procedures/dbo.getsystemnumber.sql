SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getsystemnumber](@p_controlid varchar(8),
				 @p_alternateid varchar(8))

AS
DECLARE	@return_number	int

-- Requests a block of 1 number
EXECUTE @return_number = dbo.getsystemnumber_gateway @p_controlid, @p_alternateid, 1
	
RETURN @return_number 
GO
GRANT EXECUTE ON  [dbo].[getsystemnumber] TO [public]
GO
