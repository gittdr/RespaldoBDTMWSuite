SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[PbcFindMissingColumns]

AS
/*******************************************************************************************************************  
  Object Description:
  This procedure figures out which views defined in PlanningBoardConfig
  are missing columns that are in PlanningBoardRequired and inserts the
  results into PlanningBoardMissingColumns

  RETURNS:
  none
 
  RESULT SETS:
  none

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  02/18/2016   Mark Hampton     PTS 99481   Change to use temporary tables instead of table variables. 
                                            At customer sites, there can be 40,000+ entries in the temp tables.
********************************************************************************************************************/
SET NOCOUNT ON
---DROP TABLE #reqColsByPbcId 
---DROP TABLE #selectColsByPbcId 
---DROP TABLE #viewCols 
---DROP TABLE #procCols
CREATE TABLE #reqColsByPbcId (pbcid int, reqcolumnname varchar(50), viewname varchar(100), [description] varchar(50), boardtype varchar(6))
CREATE TABLE #selectColsByPbcId (pbcid int, columnname varchar(50), viewname varchar(100), [description] varchar(50), boardtype varchar(6))
CREATE TABLE #viewCols (viewName varchar(100), colName varchar(50))
CREATE TABLE #procCols (procName varchar(100), inputColName varchar(50))

DELETE FROM PlanningBoardMissingColumns


--
-- Views
--

-- Get All Required Columns per PbcId
insert into #reqColsByPbcId
(pbcid, reqcolumnname, viewname, [description], boardtype)
select pbc.pbcid, pbr.ColumnName as reqcolumnname, pbc.viewname, pbc.[description], pbr.boardtype
from planningboardconfig pbc
join planningboardrequired pbr
	on pbc.BoardType = pbr.BoardType
where ISNULL(pbc.ViewType, 'V') = 'V'

-- Get all "select" columns per PbcId
insert into #selectColsByPbcId
(pbcid, columnname, viewname, [description], boardtype)
select pbc.pbcid, pbcc.ColumnName as reqcolumnname, pbc.viewname, pbc.[description], pbc.boardtype
from planningboardconfig pbc
join PlanningBoardConfigColumns pbcc
	on pbc.PbcId = pbcc.PbcId
where ISNULL(pbc.ViewType, 'V') = 'V'

-- Get All Columns available in each SQL view used by PBC entries
insert into #viewCols
(viewName, colName)
SELECT V2.NAME, v1.name
FROM sys.columns v1
INNER JOIN sys.views v2 on V1.OBJECT_ID = V2.OBJECT_ID
and V2.NAME in (select distinct viewname from #reqColsByPbcId union select viewname from #selectColsByPbcId)

-- Insert missing entries for Required columns that are:
-- a) Missing from PlanningBoardConfigColumn, but provided by the SQL View
-- b) Missing from PlanningBoardConfigColumn and also missing from the SQL View
insert into PlanningBoardMissingColumns
(PbcId, ViewName, Description, Boardtype, MissingColName, IsInView, ViewType, MissingType)
select t.pbcid, t.viewname, t.[description], t.boardtype, t.reqcolumnname as MissingColName, (case when exists(select top 1 * from #viewCols v where v.viewName = t.viewname and v.colName = t.reqcolumnname) then 1 else 0 end) as IsInView, 'V' as ViewType, 'R' as MissingType
from #reqColsByPbcId t
where t.reqcolumnname not in (select pbcc.columnname from planningboardconfigcolumns pbcc where pbcc.pbcid = t.pbcid)

-- Insert missing entries for Config columns that are:
-- a) Missing from the SQL View
insert into PlanningBoardMissingColumns
(PbcId, ViewName, Description, Boardtype, MissingColName, IsInView, ViewType, MissingType)
select distinct t.pbcid, t.viewname, t.[description], t.boardtype, t.columnname as MissingColName, 0 as IsInView, 'V' as ViewType, 'C' as MissingType
from #selectColsByPbcId t
left outer join #viewCols v on t.viewname = v.viewName and v.colName = t.columnname 
where v.colName is null

--
-- Stored Procedures
--

delete from #reqColsByPbcId
delete from #selectColsByPbcId

insert into #reqColsByPbcId
(pbcid, reqcolumnname, viewname, [description], boardtype)
select pbc.pbcid, pbr.ColumnName as reqcolumnname, pbc.viewname, pbc.[description], pbr.boardtype
from planningboardconfig pbc
join planningboardrequired pbr
	on pbc.BoardType = pbr.BoardType
where pbc.ViewType = 'P'

insert into #selectColsByPbcId
(pbcid, columnname, viewname, [description], boardtype)
select pbc.pbcid, pbcc.ColumnName as reqcolumnname, pbc.viewname, pbc.[description], pbc.boardtype
from planningboardconfig pbc
join PlanningBoardConfigColumns pbcc
	on pbc.PbcId = pbcc.PbcId
where pbc.ViewType = 'P'

-- Get All Columns available in each SQL proc used by PBC entries
insert into #procCols
(procName, inputColName)
select SPECIFIC_NAME, STUFF(PARAMETER_NAME, 1, 1, '') from information_schema.parameters
where specific_name IN (select distinct viewname from #reqColsByPbcId union select viewname from #selectColsByPbcId)

-- Add in columns that are required by PB as input, but not input params for proc
insert into PlanningBoardMissingColumns
(PbcId, ViewName, Description, Boardtype, MissingColName, IsInView, ViewType, MissingType)
select t.pbcid, t.viewname, t.[description], t.boardtype, t.reqcolumnname as MissingColName, 0 as IsInView, 'P' as ViewType, 'I' as MissingType
from #reqColsByPbcId t
left outer join #procCols p on t.reqcolumnname = p.inputColName and t.viewname = p.procName
where p.procName is null

-- Add in columns that are required as input params for proc, but not provided by required cols
insert into PlanningBoardMissingColumns
(PbcId, ViewName, Description, Boardtype, MissingColName, IsInView, ViewType, MissingType)
select distinct t.pbcid, t.viewname, t.[description], t.boardtype, p.inputColName as MissingColName, 1 as IsInView, 'P' as ViewType, 'P' as MissingType
from #procCols p
join #reqColsByPbcId t on p.procName = t.viewname
where not exists(select * from #reqColsByPbcId where pbcid = t.pbcid and reqcolumnname = p.inputColName)
GO
GRANT EXECUTE ON  [dbo].[PbcFindMissingColumns] TO [public]
GO
