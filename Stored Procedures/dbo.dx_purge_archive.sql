SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_purge_archive] (@purgedate datetime)
as
begin
    delete from dbo.dx_Archive where dx_sourcedate <= @purgedate
    return 1
end

GO
GRANT EXECUTE ON  [dbo].[dx_purge_archive] TO [public]
GO
