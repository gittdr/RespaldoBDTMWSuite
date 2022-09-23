SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[ptsl] as
select * from pts_log order by pts_sql_applied_date desc

GO
GRANT EXECUTE ON  [dbo].[ptsl] TO [public]
GO
