SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_stl_lookup_by_ordref_lgh_number_sp]
   @as_ref_numumber  VARCHAR(30)
AS

/**
 * 
 * NAME:
 * d_stl_lookup_by_ordref_lgh_number_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns lgh_numbers to be displayed in the LGH Number Selection Window in the Trip Folder
 *
 * RETURNS: NONE
 *
 * RESULT SETS: Set of lgh_numbers to be displayed
 *
 * PARAMETERS:
 * @as_ref_numumber  VARCHAR(30) Reference numbers from tables referencenumber, 
 *                               orderheader, stops and legheader
 *
 * REVISION HISTORY:
 * 9/1/2010 PTS51909 - Suprakash Nandan Created Procedure
 *
 **/
DECLARE
   @v_gi_top_rowcount      VARCHAR(10)
 , @v_gi_orderby           VARCHAR(200)
 , @v_gi_orderby_order     VARCHAR(4)
 , @v_gi_filter_reftypes   VARCHAR(200)
 , @v_sql                  NVARCHAR(4000)

--Get GI Settings
SELECT @v_gi_top_rowcount      = LTRIM(RTRIM(gi_string1))
     , @v_gi_orderby           = LTRIM(RTRIM(gi_string2))
     , @v_gi_orderby_order     = LTRIM(RTRIM(gi_string3))
     , @v_gi_filter_reftypes   = LTRIM(RTRIM(gi_string4))
  FROM generalinfo
 WHERE gi_name = 'STLRetrieveByRefNumber'

--Create TempRef Table
CREATE TABLE #tempRef
   ( ref_tablekey          INT         NOT NULL
   , ref_table             VARCHAR(18) NOT NULL
   , ref_type              VARCHAR(6)  NULL
   , ref_number            VARCHAR(30) NULL
   )

--Create Temp Table
CREATE TABLE #temp
   ( ref_type              VARCHAR(6)  NULL
   , ref_number            VARCHAR(30) NULL
   , lgh_number            INT         NULL
   , mov_number            INT         NULL
   , ord_hdrnumber         INT         NULL
   , ord_number            VARCHAR(12) NULL
   , ord_billto            VARCHAR(8)  NULL
   , ord_status            VARCHAR(6)  NULL
   , ord_startdate         DATETIME    NULL
   , ord_completiondate    DATETIME    NULL
   , ord_driver1           VARCHAR(8)  NULL
   , ord_driver2           VARCHAR(8)  NULL
   , ord_tractor           VARCHAR(8)  NULL
   , ord_trailer           VARCHAR(13) NULL
   )

--*******************************************
--* Build Queries to Populate TempRef Table *
--*******************************************
--Table:referencenumber
SET @v_sql = 'INSERT INTO #tempRef(ref_tablekey, ref_table, ref_type, ref_number) '
           + 'SELECT DISTINCT '
           + '       ref_tablekey, ref_table, ref_type, ref_number'
           + '  FROM referencenumber'
           + ' WHERE ref_table IN (''orderheader'',''legheader'',''stops'')'
           + '   AND ref_tablekey IS NOT NULL'
           + '   AND ref_tablekey > 0'
           + '   AND ref_number IS NOT NULL'
           + '   AND ref_number LIKE ''' + @as_ref_numumber + ''''
--add optional filter on reftypes
If IsNull(@v_gi_filter_reftypes, '') <> ''
   SET @v_sql = @v_sql
              + ' AND ref_type IS NOT NULL'
              + ' AND CHARINDEX(ref_type,' + '''' + ',' + @v_gi_filter_reftypes + ',' + '''' + ') > 0'
--Execute now
--print @v_sql
EXEC sp_executesql @v_sql

--Table:orderheader
SET @v_sql = 'INSERT INTO #tempRef(ref_tablekey, ref_table, ref_type, ref_number) '
           + 'SELECT DISTINCT '
           + '       ord_hdrnumber, ' + '''' + 'orderheader' + '''' + ', ord_reftype, ord_refnum'
           + '  FROM orderheader'
           + ' WHERE ord_hdrnumber IS NOT NULL'
           + '   AND ord_hdrnumber > 0'
           + '   AND ord_refnum IS NOT NULL'
           + '   AND ord_refnum LIKE ''' + @as_ref_numumber + ''''
--add optional filter on reftypes
If IsNull(@v_gi_filter_reftypes, '') <> ''
   SET @v_sql = @v_sql
              + ' AND ord_reftype IS NOT NULL'
              + ' AND CHARINDEX(ord_reftype,' + '''' + ',' + @v_gi_filter_reftypes + ',' + '''' + ') > 0'
--Execute now
--print @v_sql
EXEC sp_executesql @v_sql

--Table:legheader
SET @v_sql = 'INSERT INTO #tempRef(ref_tablekey, ref_table, ref_type, ref_number) '
           + 'SELECT DISTINCT '
           + '       lgh_number, ' + '''' + 'legheader' + '''' + ', lgh_reftype, lgh_refnum'
           + '  FROM legheader'
           + ' WHERE lgh_number IS NOT NULL'
           + '   AND lgh_number > 0'
           + '   AND lgh_refnum IS NOT NULL'
           + '   AND lgh_refnum LIKE ''' + @as_ref_numumber + ''''
--add optional filter on reftypes
If IsNull(@v_gi_filter_reftypes, '') <> ''
   SET @v_sql = @v_sql
              + ' AND lgh_reftype IS NOT NULL'
              + ' AND CHARINDEX(lgh_reftype,' + '''' + ',' + @v_gi_filter_reftypes + ',' + '''' + ') > 0'
--Execute now
--print @v_sql
EXEC sp_executesql @v_sql

--Table:stops
SET @v_sql = 'INSERT INTO #tempRef(ref_tablekey, ref_table, ref_type, ref_number) '
           + 'SELECT DISTINCT '
           + '       stp_number, ' + '''' + 'stops' + '''' + ', stp_reftype, stp_refnum'
           + '  FROM stops'
           + ' WHERE stp_number IS NOT NULL'
           + '   AND stp_number > 0'
           + '   AND stp_refnum IS NOT NULL'
           + '   AND stp_refnum LIKE ''' + @as_ref_numumber + ''''
--add optional filter on reftypes
If IsNull(@v_gi_filter_reftypes, '') <> ''
   SET @v_sql = @v_sql
              + ' AND stp_reftype IS NOT NULL'
              + ' AND CHARINDEX(stp_reftype,' + '''' + ',' + @v_gi_filter_reftypes + ',' + '''' + ') > 0'
--Execute now
--print @v_sql
EXEC sp_executesql @v_sql


--*******************************************************************************
--Now get additional information from related tables and populate in Temp table *
--*******************************************************************************
--Table:orderheader
INSERT INTO #temp
   ( ref_type
   , ref_number
   , lgh_number
   , mov_number
   , ord_hdrnumber
   , ord_number
   , ord_billto
   , ord_status
   , ord_startdate
   , ord_completiondate
   , ord_driver1
   , ord_driver2
   , ord_tractor
   , ord_trailer
   )
SELECT t.ref_type
     , t.ref_number
     , l.lgh_number
     , o.mov_number
     , o.ord_hdrnumber
     , o.ord_number
     , o.ord_billto
     , o.ord_status
     , o.ord_startdate
     , o.ord_completiondate
     , o.ord_driver1
     , o.ord_driver2
     , o.ord_tractor
     , o.ord_trailer
  FROM #tempRef t
  JOIN orderheader o ON t.ref_tablekey = o.ord_hdrnumber
  JOIN legheader l ON o.mov_number = l.mov_number
 WHERE t.ref_table = 'orderheader'

--Table:legheader
INSERT INTO #temp
   ( ref_type
   , ref_number
   , lgh_number
   , mov_number
   , ord_hdrnumber
   , ord_number
   , ord_billto
   , ord_status
   , ord_startdate
   , ord_completiondate
   , ord_driver1
   , ord_driver2
   , ord_tractor
   , ord_trailer
   )
SELECT t.ref_type
     , t.ref_number
     , l.lgh_number
     , o.mov_number
     , o.ord_hdrnumber
     , o.ord_number
     , o.ord_billto
     , o.ord_status
     , o.ord_startdate
     , o.ord_completiondate
     , o.ord_driver1
     , o.ord_driver2
     , o.ord_tractor
     , o.ord_trailer
  FROM #tempRef t
  JOIN legheader l ON t.ref_tablekey = l.lgh_number
  JOIN orderheader o ON l.mov_number = o.mov_number
 WHERE t.ref_table = 'legheader'

--Table:stops
INSERT INTO #temp
   ( ref_type
   , ref_number
   , lgh_number
   , mov_number
   , ord_hdrnumber
   , ord_number
   , ord_billto
   , ord_status
   , ord_startdate
   , ord_completiondate
   , ord_driver1
   , ord_driver2
   , ord_tractor
   , ord_trailer
   )
SELECT t.ref_type
     , t.ref_number
     , l.lgh_number
     , o.mov_number
     , o.ord_hdrnumber
     , o.ord_number
     , o.ord_billto
     , o.ord_status
     , o.ord_startdate
     , o.ord_completiondate
     , o.ord_driver1
     , o.ord_driver2
     , o.ord_tractor
     , o.ord_trailer
  FROM #tempRef t
  JOIN stops s ON t.ref_tablekey = s.stp_number
  JOIN legheader l ON s.lgh_number = l.lgh_number
  JOIN orderheader o ON l.mov_number = o.mov_number
 WHERE t.ref_table = 'stops'


--******************************************
--Delete rows where there is no lgh_number *
--******************************************
DELETE FROM #temp
 WHERE (lgh_number IS NULL OR lgh_number = 0)


--*****************************
--Drop the #tempRef table now *
--*****************************
DROP TABLE #tempRef


--**********************************************************
--Build Final Query with user options and return resultset *
--**********************************************************
SET @v_sql = 'SELECT DISTINCT'

--add optional Top # of Rows
If IsNull(@v_gi_top_rowcount, '') <> '' AND IsNull(@v_gi_top_rowcount, '') <> '0'
   SET @v_sql = @v_sql + ' TOP ' + @v_gi_top_rowcount

SET @v_sql = @v_sql + ' * FROM #temp'

--add optional Order By plus ASC/DESC
If IsNull(@v_gi_orderby, '') <> ''
BEGIN
   SET @v_sql = @v_sql + ' ORDER BY ' + @v_gi_orderby
   If IsNull(@v_gi_orderby_order, '') <> ''
      SET @v_sql = @v_sql + ' ' + @v_gi_orderby_order
END

--Execute final Query
--print @v_sql
EXEC sp_executesql @v_sql

GO
GRANT EXECUTE ON  [dbo].[d_stl_lookup_by_ordref_lgh_number_sp] TO [public]
GO
