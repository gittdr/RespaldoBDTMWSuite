SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getsystemnumberblock]  (@p_controlid varchar(8),
				 	@p_alternateid varchar(8),
					@p_blocksize int)

AS
DECLARE	@return_number	int

-- Requests a block of @p_blocksize size
EXECUTE @return_number = getsystemnumber_gateway @p_controlid, @p_alternateid, @p_blocksize
	
RETURN @return_number 

GO
GRANT EXECUTE ON  [dbo].[getsystemnumberblock] TO [public]
GO
