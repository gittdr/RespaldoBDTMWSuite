SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[tmw_register_pts] (@pts varchar(24), @pts_sql_gendate datetime, @pts_description varchar(255))
AS
BEGIN

If not exists (select pts_id from pts_log where pts_id = @pts)
	BEGIN
		insert into pts_log (pts_id, pts_sql_generated_date, pts_sql_applied_date, pts_description) values
		(@pts, @pts_sql_gendate, getdate(), @pts_description)
	END
END

GO
GRANT EXECUTE ON  [dbo].[tmw_register_pts] TO [public]
GO
