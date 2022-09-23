SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- We have a temp table with records that need to be inserted
-- Loop through the recordset
-- Call SyncAddRow to add the individual rows

Create proc [dbo].[SyncAddRecordset_sp] @syncset varchar(50), @PSTable varchar(50), @PSPrimaryField varchar(50), @OtherDB varchar(50), @OtherTable varchar(50), @Primaryfield varchar(50)
as
Declare @Debug as binary
declare @RecordSetFetchStatus as int
declare @Cur_primaryField as varchar(50)
declare @sourceflag as char(1)


set @Debug = 0


DECLARE AddRecordSet CURSOR FOR
Select PrimaryField, SourceFlag from ##SyncAdd

OPEN AddRecordSet

Fetch next from AddRecordSet
into @Cur_PrimaryField, @sourceflag
select @RecordSetFetchStatus = @@fetch_status


While @RecordSetFetchStatus = 0
Begin
	execute SyncAddRow_sp @SyncSet, @PStable, @psprimaryfield, @OtherDB, @OtherTable, @Primaryfield, @Cur_PrimaryField, @SourceFlag
	Fetch next from AddRecordSet
	into @Cur_PrimaryField, @sourceflag
	select @RecordSetFetchStatus = @@fetch_status
End
Close AddRecordSet
Deallocate AddRecordSet
GO
GRANT EXECUTE ON  [dbo].[SyncAddRecordset_sp] TO [public]
GO
