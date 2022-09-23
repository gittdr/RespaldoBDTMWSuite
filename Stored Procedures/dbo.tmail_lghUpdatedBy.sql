SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_lghUpdatedBy]	@lgh_number int
AS

DECLARE @length int

SELECT @length = syscolumns.length
FROM syscolumns
INNER JOIN sysobjects ON syscolumns.id = sysobjects.id
WHERE sysobjects.name = 'legheader'
	AND syscolumns.name = 'lgh_updatedby'

UPDATE legheader
SET     lgh_updatedby = LEFT(suser_sname(), @length),
	lgh_updatedon = GETDATE(),
	lgh_updateapp = 'TMAIL'
WHERE lgh_number = @lgh_number
GO
GRANT EXECUTE ON  [dbo].[tmail_lghUpdatedBy] TO [public]
GO
