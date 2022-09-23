SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[PlanningBoardColumnsFindLabelfiles] (@pbcId integer = -1, @limitToUnassociatedColumns bit = 1)

AS
/**
 *
 * NAME:
 * dbo.dbo.PlanningBoardColumnsFindLabelfiles
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure attempts to find eligible PlanningBoardConfigColumn entries
 * to associate to a labeldefinition on the labelfile table
 *
 * RETURNS:
 *
 * RESULT SETS:
 * ColumnName varchar(50), 
 * PbcId int, 
 * ViewName varchar(100), 
 * labeldefinition varchar(20)
 *
 * PARAMETERS:
 * @pbcId (optional) - limits the search to a specific board ID
 * @limitToUnassociatedColumns (optional) - If set to 1, this will skip over columns with non NULL/UNKNOWN values in labeldefinition
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 * PTS83388 | 2014-10-23 | AVANE - Creation of stored procedure
 *
 **/

--LINQ statement used in LinqPad to generate this SQL...
--
--from configColumn in PlanningBoardConfigColumns
--let colName = configColumn.OverrideName != null && configColumn.OverrideName.Trim() != "" ? configColumn.OverrideName : configColumn.ColumnName
--let colName2 = colName.ToLower().Replace("mpp", "drv").Replace("_", "").Replace(" ", "").Replace("name", "")
--join config in PlanningBoardConfig on configColumn.PbcId equals config.PbcId
--join lbl in labelfile on colName2 equals lbl.labeldefinition
--where config.CreatedBy != null && config.CreatedBy.ToLower() == "system"
--where lbl.userlabelname != null && lbl.userlabelname.Trim() != "" && lbl.userlabelname != colName2
--select new { configColumn.ColumnName, configColumn.OverrideName, DecodedColumnName = colName2, configColumn.PbcId, configColumn.ViewName, lbl.labeldefinition, lbl.userlabelname }

SELECT distinct [t2].[ColumnName], [t2].[PbcId], [t2].[ViewName], [t4].[labeldefinition]
FROM (
    SELECT [t1].[PbcId], [t1].[ViewName], [t1].[ColumnName], REPLACE(REPLACE(REPLACE(REPLACE(LOWER([t1].[value]), 'mpp', 'drv'), '_', ''), ' ', ''), 'name', '') AS [value]
    FROM (
        SELECT [t0].[PbcId], [t0].[ViewName], [t0].[ColumnName], 
            (CASE 
                WHEN LTRIM(RTRIM([t0].[OverrideName])) <> '' THEN [t0].[OverrideName]
                ELSE [t0].[ColumnName]
             END) AS [value]
        FROM [PlanningBoardConfigColumns] AS [t0]
        WHERE (@limitToUnassociatedColumns = 0 OR ISNULL([t0].labeldefinition, 'UNKNOWN') = 'UNKNOWN')
            AND (@pbcId = -1 OR [t0].PbcId = @pbcId)
        ) AS [t1]
    ) AS [t2]
INNER JOIN [PlanningBoardConfig] AS [t3] ON [t2].[PbcId] = [t3].[PbcId]
INNER JOIN [labelfile] AS [t4] ON [t2].[value] = [t4].[labeldefinition]
WHERE ([t4].[userlabelname] IS NOT NULL) 
    AND (LTRIM(RTRIM([t4].[userlabelname])) <> '') 
    AND ([t4].[userlabelname] <> [t2].[value]) 
    --AND ([t3].[CreatedBy] IS NOT NULL) 
    --AND (LOWER([t3].[CreatedBy]) = 'system')

GO
GRANT EXECUTE ON  [dbo].[PlanningBoardColumnsFindLabelfiles] TO [public]
GO
