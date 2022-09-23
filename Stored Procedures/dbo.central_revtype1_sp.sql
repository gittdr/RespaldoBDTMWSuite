SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [dbo].[central_revtype1_sp] (@revtype1 varchar(6))
as
DECLARE @ret int
If @revtype1 = 'UNK'
	select @ret = 0
else
	select @ret = 1
Return @ret
GO
GRANT EXECUTE ON  [dbo].[central_revtype1_sp] TO [public]
GO
