SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Given a temp table with the records that need to be sync'd
Cursor through the list call SyncFields_sp to transfer each field
*/

Create proc [dbo].[SyncRecordSet_sp] @syncset varchar(50), @PSTable varchar(50), @PSPrimaryField varchar(50), @OtherDB varchar(50), @OtherTable varchar(50), @Primaryfield varchar(50)
as
Declare @Debug as binary
declare @RecordSetFetchStatus as int
declare @Cur_primaryField as varchar(50)
declare @sourceflag as char(1)


set @Debug = 0

DECLARE Cur_RecordSet CURSOR FOR
Select PrimaryField, SourceFlag from ##SyncResult

OPEN Cur_RecordSet

Fetch next from Cur_RecordSet
into @Cur_PrimaryField, @sourceflag
select @RecordSetFetchStatus = @@fetch_status


While @RecordSetFetchStatus = 0
Begin
	execute SyncFields_sp @SyncSet, @PStable, @psprimaryfield, @OtherDB, @OtherTable, @Primaryfield, @Cur_PrimaryField, @SourceFlag
	Fetch next from Cur_RecordSet
	into @Cur_PrimaryField, @sourceflag
	select @RecordSetFetchStatus = @@fetch_status
End
Close Cur_RecordSet
Deallocate Cur_RecordSet
GO
GRANT EXECUTE ON  [dbo].[SyncRecordSet_sp] TO [public]
GO
