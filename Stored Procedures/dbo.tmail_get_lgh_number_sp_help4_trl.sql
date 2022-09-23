SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_sp_help4_trl] @trailer varchar(13),
												   @lgh_outstatus varchar (6),
												   @TMStatus as varchar(500),
												   @sFlags varchar(12)

AS

/* Flags understood by this routine:
	'*** +134217728 = Return all legheaders as result set

*/

DECLARE @SQL as varchar(2000),
		@iFlags as int,
		@iReturnAllLegs int

SET @iFlags = CONVERT(int, @sFlags)

SET @iReturnAllLegs = 0

IF (@iFlags & 134217728) <> 0 
	SET @iReturnAllLegs = 1 

/* 10/5/01 TD: Created to workaround Insert/Rowcount issue */
IF @iReturnAllLegs = 0
	SET ROWCOUNT 1
-- PTS 69972 - was " aa.asgn_type = ‘’TRC’’ " 
-- NOW " aa.asgn_type = ''TRL''  "

SET @SQL = 'SELECT lgh.lgh_number, aa.asgn_status, lgh.lgh_tm_status, aa.asgn_date ' +
                  'FROM assetassignment aa WITH (NOLOCK) INNER JOIN legheader lgh WITH (NOLOCK) ON aa.lgh_number = lgh.lgh_number' + 
                  ' WHERE aa.asgn_type = ''TRL'' AND aa.asgn_id = ''' + @trailer + 
                  ''' AND aa.asgn_status = ''' + @lgh_outstatus + ''''
 
if (ISNULL(@TMStatus,'') <> '')
      SET @SQL = @SQL + ' AND lgh.lgh_tm_status in (' + @TMStatus + ')'
 
SET @SQL = @SQL + ' ORDER BY aa.asgn_date'
 
IF @lgh_outstatus = 'CMP'     -- We want the latest date if CMP else we want the earliest date
      SET @SQL = @SQL + ' desc'


EXEC (@SQL)

SET ROWCOUNT 0 

GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_sp_help4_trl] TO [public]
GO
