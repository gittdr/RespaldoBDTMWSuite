SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadlanes_sp] @lhcode varchar(12) , @number int AS
DECLARE @match_rows int

IF @number = 1 
   SET rowcount 1 
ELSE IF @number <= 8 
   SET rowcount 8
ELSE IF @number <= 16
   SET rowcount 16
ELSE IF @number <= 24
   SET rowcount 24
ELSE
   SET rowcount 8

IF EXISTS(SELECT lanename 
            FROM core_lane 
           WHERE lanecode LIKE @lhcode + '%')
   SELECT @match_rows = 1
ELSE
   SELECT @match_rows = 0

IF @match_rows > 0
   SELECT lanecode,
          lanename
     FROM core_lane
    WHERE lanecode LIKE @lhcode + '%'
   ORDER BY lanecode 
ELSE 
   SELECT lanecode,
          lanename
     FROM core_lane 
    WHERE lanecode = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadlanes_sp] TO [public]
GO
