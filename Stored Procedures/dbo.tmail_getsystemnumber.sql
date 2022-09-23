SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[tmail_getsystemnumber](	@p_controlid  	varchar(8),
					@p_alternateid varchar(8))

AS

DECLARE		@return_number		int

EXECUTE @return_number = dbo.getsystemnumber_gateway @p_controlid, @p_alternateid,1


SELECT @return_number

GO
GRANT EXECUTE ON  [dbo].[tmail_getsystemnumber] TO [public]
GO
