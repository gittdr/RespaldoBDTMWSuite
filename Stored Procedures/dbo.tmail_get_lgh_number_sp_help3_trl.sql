SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_sp_help3_trl] @trailer varchar(13),
												   @lgh_outstatus varchar (6),
												   @TMStatus as varchar(500)

AS

DECLARE @SQL as varchar(2000)

/* 10/5/01 TD: Created to workaround Insert/Rowcount issue */
SET ROWCOUNT 1

SET @SQL = 	'SELECT lgh_number, lgh_OutStatus, lgh_tm_status, lgh_startdate ' +
	   		'FROM legheader (NOLOCK) ' + 
	   		'WHERE lgh_primary_trailer = ''' + @trailer + 
	   		''' AND lgh_outstatus = ''' + @lgh_outstatus + ''''

if (ISNULL(@TMStatus,'') <> '')
	SET @SQL = @SQL + ' AND lgh_tm_status in (' + @TMStatus + ')'

SET @SQL = @SQL + ' ORDER BY lgh_startdate'

IF @lgh_outstatus = 'CMP'	-- We want the latest date if CMP else we want the earliest date
	SET @SQL = @SQL + ' desc'

EXEC (@SQL)

SET ROWCOUNT 0 

GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_sp_help3_trl] TO [public]
GO
