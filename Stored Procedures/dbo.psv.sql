SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[psv] as
select * from ps_version_log order by begindate desc
GO
GRANT EXECUTE ON  [dbo].[psv] TO [public]
GO
