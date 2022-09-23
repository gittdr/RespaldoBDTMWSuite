SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[PbcFindSprocsForBoardType] @boardType varchar(6)

AS
/**
 *
 * NAME:
 * dbo.dbo.PbcFindSprocsForBoardType
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure interrogates stored procedures in the database that would satisfy the given
 * planning board type. A match is defined as the input parameters exactly matching the 
 * required columns of board, both in name and in count.
 *
 * RETURNS:
 * The set of names of potential stored procedure matches.
 *
 * RESULT SETS:
 * The set of names of potential stored procedure matches.
 *
 * PARAMETERS:
 * 001 - @boardType varchar(6) The type of planning board to match against.
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 * 14/4/3 | AVANE | PTS65996 | Creation of procedure
 *
 **/

declare @reqCols table(ColumnName varchar(50))
declare @fullJoinProspects table(name sysname)
declare @intersectProspects table(name sysname, paramCount int)

insert into @reqCols
(ColumnName)
select ColumnName from PlanningBoardRequired where BoardType = @boardType
order by ColumnName


insert into @intersectProspects
(name, paramCount)
select distinct p.SPECIFIC_NAME, count(p.PARAMETER_NAME)
from INFORMATION_SCHEMA.PARAMETERS p
where STUFF(p.PARAMETER_NAME, 1, 1, '') in (select ColumnName from @reqCols)
and exists(select * from sysobjects so where so.name = p.SPECIFIC_NAME and so.type = 'P')
group by p.SPECIFIC_NAME

select name from @intersectProspects where paramCount = (select count(*) from INFORMATION_SCHEMA.PARAMETERS where SPECIFIC_NAME = name) and paramCount = (select count(*) from @reqCols)

GO
GRANT EXECUTE ON  [dbo].[PbcFindSprocsForBoardType] TO [public]
GO
