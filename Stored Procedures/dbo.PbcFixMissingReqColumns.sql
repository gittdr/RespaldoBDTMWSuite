SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[PbcFixMissingReqColumns] @pbcId int, @makeColsVisible char = 'N'

AS
/**
 *
 * NAME:
 * dbo.dbo.PbcFixMissingReqColumns
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure reads from PlanningBoardMissingColumns table and adds
 * the missing columns for the given PbcId to PlanningBoardConfigColumns
 *
 * RETURNS:
 * none
 *
 * RESULT SETS:
 * none
 *
 * PARAMETERS:
 * 001 - @pbcId int - The PbcId of the PlanningBoardConfig view to fix
 *       This limits how far back to look for open stops
 *
 * 002 - @makeColsVisible char - Sets the VisibleFlag column value.
 *       Default is 'N'
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 **/

--Sanity check to ensure we have latest info in PlanningBoardMissingColumns
exec PbcFindMissingColumns

declare @maxDispSeq int
declare @newPbccEntries table(PbcId int, ViewName varchar(100), ColumnName varchar(50), DisplaySequence int, VisibleFlag char(1), AdditionalColumn char(1))

--Determine starting DisplaySequence for new entries
select top 1 @maxDispSeq = DisplaySequence 
from PlanningBoardConfigColumns 
where PbcId = @pbcId
order by DisplaySequence desc

if @maxDispSeq is null
begin
	select @maxDispSeq = 1
end

insert into @newPbccEntries
select @pbcId, pbmc.ViewName, pbmc.MissingColName, 0, @makeColsVisible, 'N'
from PlanningBoardMissingColumns pbmc
where pbmc.PbcId = @pbcId
	and pbmc.IsInView = 1

--Figure out DisplaySequence for each new entry
update @newPbccEntries
set @maxDispSeq = DisplaySequence = @maxDispSeq + 1

insert into PlanningBoardConfigColumns
(PbcId, ViewName, ColumnName, OverrideName, DisplaySequence, VisibleFlag, AdditionalColumn)
select PbcId, ViewName, ColumnName, '', DisplaySequence, VisibleFlag, AdditionalColumn
from @newPbccEntries

--Remove now-outdated entries from PlanningBoardMissingColumns
delete from PlanningBoardMissingColumns
where PbcId = @pbcId
	and IsInView = 1

GO
GRANT EXECUTE ON  [dbo].[PbcFixMissingReqColumns] TO [public]
GO
