SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create proc [dbo].[SyncSet_sp]
as
Declare @syncset as varchar(50)
Declare @otherserver as varchar(50)
Declare @otherowner as varchar(50)
Declare @otherdb as varchar(50)
Declare @otheruser as varchar(50)
Declare @otherpw as varchar(50)
Declare @SyncFetchStatus as int

DECLARE Cur_SyncSet CURSOR FOR
Select SyncSet, otherserver, otherowner, otherdb, otheruser, otherpw from SyncSet

OPEN cur_SyncSet

Fetch next from cur_SyncSet
into @SyncSet, @otherserver, @otherowner, @otherdb, @otheruser, @otherpw
select @SyncFetchStatus = @@fetch_status

While @SyncFetchStatus = 0
Begin
	execute SyncTable_sp @SyncSet, @otherserver, @otherowner, @otherdb
	Fetch next from cur_SyncSet
	into @SyncSet, @otherserver, @otherowner, @otherdb, @otheruser, @otherpw
	select @SyncFetchStatus = @@fetch_status
End
Close cur_syncset
Deallocate cur_syncset
GO
GRANT EXECUTE ON  [dbo].[SyncSet_sp] TO [public]
GO
