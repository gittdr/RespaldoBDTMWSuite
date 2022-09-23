SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create proc [dbo].[SyncTable_sp] @syncset varchar(50), @OtherServer varchar(50), @OtherOwner varchar(50), @Otherdb varchar(50)
as
/**
 * 
 * NAME:
 * dbo.SyncTable_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/


Declare @PSTable as varchar(50)
Declare @OtherTable as varchar(50)
Declare @RuleType as varchar(20)
Declare @Rules as varchar(512)
Declare @KeyNumeric as numeric(18,0)
Declare @KeyDate as datetime
Declare @KeyOther as varchar(50)
Declare @PSKeyField as varchar(50)
Declare @KeyField as varchar(50)
Declare @PSPrimaryField as varchar(50)
Declare @PrimaryField as varchar(50)
Declare @StoredProc as varchar(128)
Declare @SyncTableFetchStatus as int
Declare @SQL as varchar(256)
declare @SQL1 as varchar(256)
Declare @Debug as binary

set @Debug = 0

DECLARE Cur_SyncTable CURSOR FOR
Select PSTable, OtherTable, RuleType, Rules, KeyNumeric, KeyDate, KeyOther, PSKeyField, KeyField, PSPrimaryField, PrimaryField, StoredProc from SyncTable where SyncSet = @SyncSet

OPEN Cur_SyncTable

Fetch next from Cur_SyncTable
into @PSTable, @OtherTable, @RuleType, @Rules, @KeyNumeric, @KeyDate, @KeyOther, @PSKeyField, @KeyField, @PSPrimaryField, @PrimaryField, @StoredProc
select @SyncTableFetchStatus = @@fetch_status

While @SyncTableFetchStatus = 0
Begin

	-- For each table
	-- Use the rules to decide what actions need to take place
	if @RuleType = 'Copy'
	begin
	-- Dump that will move fields as specified in the owner flag
		goto ExitRuleSelect
	end
	if @RuleType = 'Numeric'
	begin
		goto ExitRuleSelect
	end

--		Last modified
	if @RuleType = 'LastModified'
	begin
		--  select trc_id as primaryfield, 'p' as sourceflag into ##PSSyncTemp from tractorprofile where lastmodified > @keydate
		select @SQL = 'SELECT ' + @psprimaryfield + ' as primaryfield, ''P'' as SourceFlag INTO ##PSSyncTemp FROM ' + @PSTable  + ' WHERE ' + @PSKeyField + ' > ''' + cast (@KeyDate as varchar) + ''''
		Exec (@SQL)

		select @SQL1 = 'SELECT ' + @primaryfield + ' as primaryfield, ''O'' as SourceFlag INTO ##SyncTemp FROM [' + @OtherDB + '].[dbo].[' + @OtherTable  + '] WHERE ' + @KeyField + ' > ''' + cast(@KeyDate as varchar) + ''''
		Exec (@SQL1)

		select * into ##SyncResult from ##PSSyncTemp
		insert into ##SyncResult select Primaryfield, sourceflag from ##SyncTemp

-- Check for records in the update set that need to be added to the respective tables...
		if @Rules = 'ADDBOTH'	-- New records inserted into both tables
		begin
			select @SQL = 'SELECT primaryfield, ''P'' as SourceFlag INTO ##SyncAdd FROM ##SyncTemp WHERE primaryfield not in (select ' + @psprimaryfield + ' From ' + @pstable + ')'
			Exec (@SQL)

			select @SQL = 'SELECT primaryfield, ''O'' as SourceFlag INTO ##SyncAddO FROM ##SyncTemp WHERE primaryfield not in (select ' + @primaryfield + ' From ' + @otherdb + '..' + @othertable + ')'
			Exec (@SQL)

			insert into ##SyncAdd select Primaryfield, sourceflag from ##SyncAddO
			drop table ##SyncAddO -- All data in SyncAdd now.
		
			drop table ##PSSyncTemp
			drop table ##SyncTemp 

			if (select count(*) from ##SyncResult) > 0
				execute SyncRecordSet_sp @SyncSet, @PStable, @psprimaryfield, @OtherDB, @OtherTable, @Primaryfield

			drop table ##SyncResult

			if (select count(*) from ##SyncAdd) > 0
				execute SyncAddRecordSet_sp @SyncSet, @PStable, @psprimaryfield, @OtherDB, @OtherTable, @Primaryfield
			drop table ##SyncAdd
		end
		if @Rules = 'ADDTMW' 	-- New records only added to PowerSuite
		begin
			select @SQL = 'SELECT primaryfield, ''P'' as SourceFlag INTO ##SyncAdd FROM ##SyncTemp WHERE primaryfield not in (select ' + @psprimaryfield + ' From ' + @pstable + ')'
			Exec (@SQL)

			insert into ##SyncAdd select Primaryfield, sourceflag from ##SyncAddO
		
			drop table ##PSSyncTemp
			drop table ##SyncTemp 

			if (select count(*) from ##SyncResult) > 0
				execute SyncRecordSet_sp @SyncSet, @PStable, @psprimaryfield, @OtherDB, @OtherTable, @Primaryfield

			drop table ##SyncResult

			if (select count(*) from ##SyncAdd) > 0
				execute SyncAddRecordSet_sp @SyncSet, @PStable, @psprimaryfield, @OtherDB, @OtherTable, @Primaryfield
			drop table ##SyncAdd
		end

		if @Rules = 'ADDOTHER'  -- New records only added to other
		begin
			select @SQL = 'SELECT primaryfield, ''O'' as SourceFlag INTO ##SyncAdd FROM ##SyncTemp WHERE primaryfield not in (select ' + @primaryfield + ' From ' + @otherdb + '..' + @othertable + ')'
			Exec (@SQL)

			drop table ##PSSyncTemp
			drop table ##SyncTemp 

			if (select count(*) from ##SyncResult) > 0
				execute SyncRecordSet_sp @SyncSet, @PStable, @psprimaryfield, @OtherDB, @OtherTable, @Primaryfield

			drop table ##SyncResult

			if (select count(*) from ##SyncAdd) > 0
				execute SyncAddRecordSet_sp @SyncSet, @PStable, @psprimaryfield, @OtherDB, @OtherTable, @Primaryfield
			drop table ##SyncAdd
		end

		-- Set the last processed date to now...
		update synctable Set keydate = getdate() where current of Cur_SyncTable

		goto ExitRuleSelect
	end

-- 		Table Dump
	if @RuleType = 'TableDump'
	begin
		-- Ok for this one we just drop the table and do a select * into...
		-- Only will dump into powersuite not to other db
		IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = @PSTable)
		begin
			EXEC('DROP TABLE ' + @PSTable)
		end
		exec('select * into ' + @PSTable + ' from ' + @otherDB + '..' + @otherTable)
		goto ExitRuleSelect
	end

ExitRuleSelect:
	if @storedproc <> ''
		exec(@storedproc)

	Fetch next from Cur_SyncTable
	into @PSTable, @OtherTable, @RuleType, @Rules, @KeyNumeric, @KeyDate, @KeyOther, @PSKeyField, @KeyField, @PSPrimaryField, @PrimaryField, @StoredProc
	select @SyncTableFetchStatus = @@fetch_status
End
Close Cur_SyncTable
Deallocate Cur_SyncTable
GO
GRANT EXECUTE ON  [dbo].[SyncTable_sp] TO [public]
GO
