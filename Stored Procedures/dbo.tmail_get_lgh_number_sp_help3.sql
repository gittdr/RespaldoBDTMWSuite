SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_sp_help3]	@tractor varchar(12),
														@lgh_outstatus varchar (6),
														@TMStatus as varchar(500)

AS

/* 10/5/01 TD: Created to workaround Insert/Rowcount issue */
/* 09/26/11 DWG: PTS 57889  Added check to make sure the leg header is not a child */

SET NOCOUNT ON 

DECLARE @SQL as varchar(2000)

SET ROWCOUNT 1

SET @SQL = 	'SELECT lgh_number, lgh_OutStatus, lgh_tm_status, lgh_startdate ' +
	   		'FROM legheader l (NOLOCK) ' + 
	   		'WHERE lgh_tractor = ''' + @tractor + 
	   		''' AND lgh_outstatus = ''' + @lgh_outstatus + '''' +
	   		' AND NOT EXISTS (SELECT NULL FROM stops stopsinner (NOLOCK) WHERE stopsinner.lgh_number = l.lgh_number AND ISNULL(stopsinner.stp_ico_stp_number_child,0) <> 0)' -- PTS 57913 DWG

if (ISNULL(@TMStatus,'') <> '')
	SET @SQL = @SQL + ' AND lgh_tm_status in (' + @TMStatus + ')'

SET @SQL = @SQL + ' ORDER BY lgh_startdate'

IF @lgh_outstatus = 'CMP'	-- We want the latest date if CMP else we want the earliest date
	SET @SQL = @SQL + ' desc'

EXEC (@SQL)

SET ROWCOUNT 0 
GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_sp_help3] TO [public]
GO
