SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[tmw_setversionactive] (@flag char(1))
as
begin
	UPDATE 	ps_version_log
	SET		version_activated = @flag
	WHERE		IsNull(version_activated, 'N') <> 'Y' and
				enddate = (SELECT MAX(enddate)
								FROM ps_version_log)
end
GO
GRANT EXECUTE ON  [dbo].[tmw_setversionactive] TO [public]
GO
