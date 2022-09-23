SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Given a row that needs to be sync'd, sync it. */
/* transfer each field for a single row */

/* Input
Server, PSDB, DB, PSTable, Table, row(primary key, value), row (primary key, value)
*/

Create proc [dbo].[SyncFields_sp] @syncset varchar(50), @PSTable varchar(50), @PSPrimaryField varchar(50), @OtherDB varchar(50), @OtherTable varchar(50), @Primaryfield varchar(50), @PrimaryFieldData as varchar(50), @SourceFlag as char(1)
as
/**
 * 
 * NAME:
 * dbo.SyncFields_sp 
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

Declare @Debug as binary
declare @FieldFetchStatus as int
declare @PSColumn as varchar(50)
declare @OtherColumn as varchar(50)
declare @PSOwner as varchar(1)
declare @SQL as varchar(256)
declare @SQL1 as varchar(256)
declare @SQL2 as varchar(256)
declare @PSfieldtype as tinyint
declare @PSfieldlength as smallint
declare @Ofieldtype as tinyint
declare @Ofieldlength as smallint
declare @ResultData as varchar(512)

set @Debug = 0


DECLARE Cur_Fields CURSOR FOR
Select psColumn, OtherColumn, PSOwner from SyncColumn where pstable = @pstable and syncset = @syncset

OPEN Cur_Fields

Fetch next from Cur_Fields
into @PSColumn, @OtherColumn, @PSOwner
select @FieldFetchStatus = @@fetch_status


While @FieldFetchStatus = 0
Begin

	select @PSfieldtype = (select xtype from syscolumns where id = (select id from sysobjects where name = @PSTable) and name = @pscolumn)
	select @PSfieldlength = (select length from syscolumns where id = (select id from sysobjects where name = @PSTable) and name = @pscolumn)
	select @SQL = @OtherDB + '..syscolumns'
	select @SQL1 = @OtherDB + '..sysobjects'
	select @SQL2 = 'select xtype into ##QT from ' + @SQL + ' where id = (select id from ' + @SQL1 + ' where name = ''' + @OtherTable + ''') and name = ''' + @othercolumn + ''''
	exec(@SQL2)
	select @OfieldType = (select * from ##QT)
	drop table ##QT
	select @SQL2 = 'select length into ##QT from ' + @SQL + ' where id = (select id from ' + @SQL1 + ' where name = ''' + @OtherTable + ''') and name = ''' + @othercolumn + ''''
	exec(@SQL2)
	select @Ofieldlength = (select * from ##QT)
	drop table ##QT


--	Finally! The update statement

	if @PSOwner = 'Y'
	begin
		-- PowerSuite owns the field so write the data back to the other database
		-- Testing for 'char' type fields to insure that the data will fit into the field
		if @psfieldtype = 175 or @psfieldtype = 239 or @psfieldtype = 99 or @psfieldtype = 231 or @psfieldtype = 167
		begin
			select @SQL1 = 'select ' + @pscolumn + ' into ##QT from ' + @pstable + ' where ' + @psprimaryfield + ' = ''' + @primaryfielddata + ''''
			exec (@SQL1)
			select @SQL1 = (Select * from ##QT)
			--- If the record is not found ignore the sync
			if @SQL1 is not null
			begin
				select @SQL2 = rtrim(left(@SQL1, @ofieldlength))
				select @SQL = 'update ' + @otherdb + '..' + @othertable + ' set ' + @othercolumn + ' = ''' + @SQL2 + ''' where ' + @primaryfield + ' = ''' + @primaryfieldData + ''''
--				Select @SQL, 'O UPDATE STATEMENT'
				exec(@SQL)
			end
			drop table ##QT
		end
		else
		begin	-- Not a char type field
-- Will this work? STR Type Return from the select?
			select @SQL1 = 'select ' + @pscolumn + ' into ##QT from ' + @pstable + ' where ' + @psprimaryfield + ' = ''' + @primaryfielddata + ''''
			exec (@SQL1)
			select @ResultData = cast((Select * from ##QT) as varchar)
			--- If the record is not found ignore the sync
			if @ResultData is not null
			begin
				select @SQL = 'update ' + @otherdb + '..' + @othertable + ' set ' + @othercolumn + ' = ' + @ResultData + ' where ' + @primaryfield + ' = ''' + @primaryfieldData + ''''
--				Select @SQL, 'O NON CHAR UPDATE STATEMENT'
				exec(@SQL)
			end
			drop table ##QT
		end
	end
	else
	begin
		-- This data is owned by the exteral tables, update ps with the data
		if @Ofieldtype = 175 or @Ofieldtype = 239 or @Ofieldtype = 99 or @Ofieldtype = 231 or @Ofieldtype = 167
		begin
			select @SQL1 = 'select ' + @othercolumn + ' into ##QT from ' + @otherdb + '..' + @othertable + ' where ' + @primaryfield + ' = ''' + @primaryfielddata + ''''
			exec (@SQL1)
			select @SQL1 = (Select * from ##QT)
			--- If the record is not found ignore the sync
			if @SQL1 is not null
			begin
				select @SQL2 = rtrim(left(@SQL1, @ofieldlength))
				select @SQL = 'update ' + @pstable + ' set ' + @pscolumn + ' = ''' + @SQL2 + ''' where ' + @psprimaryfield + ' = ''' + @primaryfieldData + ''''
--				Select @SQL, 'PS UPDATE STATEMENT'
				exec(@SQL)
			end
			drop table ##QT			
		end
		else
		begin
			select @SQL1 = 'select ' + @othercolumn + ' into ##QT from ' + @otherdb + '..' + @othertable + ' where ' + @primaryfield + ' = ''' + @primaryfielddata + ''''
			exec (@SQL1)
			select @ResultData = cast((Select * from ##QT) as varchar)
			--- If the record is not found ignore the sync
			if @ResultData is not null
			begin
				select @SQL = 'update ' + @pstable + ' set ' + @pscolumn + ' = ' + @ResultData + ' where ' + @psprimaryfield + ' = ''' + @primaryfieldData + ''''
--				Select @SQL, 'PS UPDATE STATEMENT'
				exec(@SQL)
			end
			drop table ##QT		
		end
	end

	Fetch next from Cur_Fields
	into @PSColumn, @OtherColumn, @PSOwner
	select @FieldFetchStatus = @@fetch_status
End
Close Cur_Fields
Deallocate Cur_Fields
GO
GRANT EXECUTE ON  [dbo].[SyncFields_sp] TO [public]
GO
