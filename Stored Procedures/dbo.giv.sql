SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[giv] as
select gi_string1,* from generalinfo where gi_name like 'db%'
GO
GRANT EXECUTE ON  [dbo].[giv] TO [public]
GO
