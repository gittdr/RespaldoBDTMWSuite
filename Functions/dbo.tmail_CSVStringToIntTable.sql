SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[tmail_CSVStringToIntTable] (@List varchar(4000))
/*******************************************************************************************************************  
  Object Description:
  Break out elements of a comma-separated list into a table variable
  Modified from code written by Jeff Moden. Modifyed by Lisa bohm, and now W. Riley Wolfe
  http://www.sqlservercentral.com/articles/Tally+Table/72993/
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  06/09/2014   W. Riley Wolfe   PTS 68331    init
  05/02/2016   Lisa Bohm        PTS 23405    Rewrote using Jeff Moden's Tally Table string splitter code; removed delimiter parameter
  10/13/2016   W. Riley Wolfe   PTS 105559   Import and addapt Lisa's + jeff code.  
********************************************************************************************************************/
RETURNS TABLE WITH SCHEMABINDING AS
 RETURN
    WITH cteTally(N) AS (--==== This provides the "base" CTE and limits the number of rows right up front
                       -- for both a performance gain and prevention of accidental "overruns"
                   SELECT TOP (ISNULL(DATALENGTH(@List),0)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM dbo.ident_numbers
                  ),
  cteStart(N1) AS (--==== This returns N+1 (starting position of each "element" just once for each delimiter)
                   SELECT 1 UNION ALL
                   SELECT t.N+1 FROM cteTally t WHERE SUBSTRING(@List,t.N,1) = ','
                  ),
  cteLen(N1,L1) AS(--==== Return start and length (for use in substring)
                   SELECT s.N1,
                          ISNULL(NULLIF(CHARINDEX(',',@List,s.N1),0)-s.N1,4000)
                     FROM cteStart s
                  )
  --===== Do the actual split. The ISNULL/NULLIF combo handles the length for the final element when no delimiter is found.
   SELECT [Value]       = CAST(SUBSTRING(@List, l.N1, l.L1) AS INT)
     FROM cteLen l
  ;
GO
GRANT SELECT ON  [dbo].[tmail_CSVStringToIntTable] TO [public]
GO
