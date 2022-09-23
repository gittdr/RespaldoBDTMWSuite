SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[SyncAddRow_sp] @syncset varchar(50), @PSTable varchar(50), @PSPrimaryField varchar(50), @OtherDB varchar(50), @OtherTable varchar(50), @Primaryfield varchar(50), @PrimaryFieldData as varchar(50), @SourceFlag as char(1)
as
/**
 * 
 * NAME:
 * dbo.SyncAddRow_sp 
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
declare @SQL3 as varchar(256)
declare @PSfieldtype as tinyint
declare @PSfieldlength as smallint
declare @Ofieldtype as tinyint
declare @Ofieldlength as smallint
declare @ResultData as varchar(512)
set @Debug = 0


select @SQL = 'Insert into '

-- @sourceflag indicates where the record is going.. 'P' for PS and 'O' for other

if @SourceFlag = 'P'
begin
	select @SQL = @SQL + @PSTable + ' ('

end
else
begin
	select @SQL = @SQL + @otherdb + '..' + @othertable + ' ('
end

-- We need 2 loops (cursors) to build the SQL
DECLARE AddFields CURSOR FOR
Select psColumn, OtherColumn, PSOwner from SyncColumn where pstable = @pstable and syncset = @syncset

OPEN AddFields

Fetch next from AddFields
into @PSColumn, @OtherColumn, @PSOwner
select @FieldFetchStatus = @@fetch_status

While @FieldFetchStatus = 0
Begin

	if @SourceFlag = 'P'
	begin
		Select @SQL = @SQL + @PSColumn + ', '
	end
	else
	begin
		Select @SQL = @SQL + @OtherColumn + ', '
	end	

	Fetch next from AddFields
	into @PSColumn, @OtherColumn, @PSOwner
	select @FieldFetchStatus = @@fetch_status
End
Close AddFields
Deallocate AddFields

select @SQL = left(@SQL, Len(@SQL) - 1) -- Trim the , off the end
select @SQL = @SQL + ') Values ('

-- 2nd loop (cursors) to gather the data
DECLARE AddFields1 CURSOR FOR
Select psColumn, OtherColumn, PSOwner from SyncColumn where pstable = @pstable and syncset = @syncset

OPEN AddFields1

Fetch next from AddFields1
into @PSColumn, @OtherColumn, @PSOwner
select @FieldFetchStatus = @@fetch_status

While @FieldFetchStatus = 0
Begin

	if @SourceFlag = 'O'
	begin
		select @PSfieldtype = (select xtype from syscolumns where id = (select id from sysobjects where name = @PSTable) and name = @pscolumn)
		select @PSfieldlength = (select length from syscolumns where id = (select id from sysobjects where name = @PSTable) and name = @pscolumn)

		if @psfieldtype = 175 or @psfieldtype = 239 or @psfieldtype = 99 or @psfieldtype = 231 or @psfieldtype = 167
		begin
			select @SQL1 = 'select ' + @pscolumn + ' into ##QT from ' + @pstable + ' where ' + @psprimaryfield + ' = ''' + @primaryfielddata + ''''
			exec (@SQL1)
			select @SQL1 = (Select * from ##QT)
			select @SQL2 = rtrim(left(@SQL1, @ofieldlength))
			select @SQL = @SQL + '''' + @SQL2 + ''', '
			drop table ##QT
		end
		else
		begin	-- Not a char type field
			select @SQL1 = 'select ' + @pscolumn + ' into ##QT from ' + @pstable + ' where ' + @psprimaryfield + ' = ''' + @primaryfielddata + ''''
			exec (@SQL1)
			select @ResultData = cast((Select * from ##QT) as varchar)
			select @SQL = @SQL + @ResultData + ', '
			drop table ##QT
		end
	end
	else
	begin	-- Now inserting into the other table...
		select @SQL3 = @OtherDB + '..syscolumns'
		select @SQL1 = @OtherDB + '..sysobjects'
		select @SQL2 = 'select xtype into ##QT from ' + @SQL3 + ' where id = (select id from ' + @SQL1 + ' where name = ''' + @OtherTable + ''') and name = ''' + @othercolumn + ''''
		exec(@SQL2)
		select @OfieldType = (select * from ##QT)
		drop table ##QT
		select @SQL2 = 'select length into ##QT from ' + @SQL3 + ' where id = (select id from ' + @SQL1 + ' where name = ''' + @OtherTable + ''') and name = ''' + @othercolumn + ''''
		exec(@SQL2)
		select @Ofieldlength = (select * from ##QT)
		drop table ##QT

-- Column info gathered now build the insert line
		if @Ofieldtype = 175 or @Ofieldtype = 239 or @Ofieldtype = 99 or @Ofieldtype = 231 or @Ofieldtype = 167
		begin
			select @SQL1 = 'select ' + @othercolumn + ' into ##QT from ' + @otherdb + '..' + @othertable + ' where ' + @primaryfield + ' = ''' + @primaryfielddata + ''''
			exec (@SQL1)
			select @SQL1 = (Select * from ##QT)
			select @SQL2 = rtrim(left(@SQL1, @ofieldlength))
			select @SQL = @SQL + '''' + @SQL2 + ''', '
			drop table ##QT			
		end
		else
		begin
			select @SQL1 = 'select ' + @othercolumn + ' into ##QT from ' + @otherdb + '..' + @othertable + ' where ' + @primaryfield + ' = ''' + @primaryfielddata + ''''
			exec (@SQL1)
			select @ResultData = cast((Select * from ##QT) as varchar)
			select @SQL = @SQL + @ResultData + ', '
			drop table ##QT		
		end
	end	

	Fetch next from AddFields1
	into @PSColumn, @OtherColumn, @PSOwner
	select @FieldFetchStatus = @@fetch_status
End
Close AddFields1
Deallocate AddFields1

select @SQL = left(@SQL, Len(@SQL) - 1) -- Trim the , off the end
select @SQL = @SQL + ')'
-- SQL now has the string to execute
exec(@SQL)

GO
GRANT EXECUTE ON  [dbo].[SyncAddRow_sp] TO [public]
GO
