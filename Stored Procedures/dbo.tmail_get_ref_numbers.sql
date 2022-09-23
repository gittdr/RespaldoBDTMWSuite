SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_ref_numbers]
		@PSTable varchar(20),
		@PSTableKey varchar(20),
		@RefNumType varchar(6)
AS

EXEC dbo.tmail_get_ref_numbers2 @PSTable, @PSTableKey, @RefNumType, '1'

GO
GRANT EXECUTE ON  [dbo].[tmail_get_ref_numbers] TO [public]
GO
