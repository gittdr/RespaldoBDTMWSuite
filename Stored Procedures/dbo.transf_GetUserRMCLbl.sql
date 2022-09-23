SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_GetUserRMCLbl]
	(
		@transf_user_id int
		, @rmf_rm_name varchar(20)
		, @rmf_name varchar(20)
		, @labeldefinition varchar (20)
	)
AS

set nocount on

	SELECT  abbr
		, name
		, rmf_value
		, @rmf_name as rmf_name
	FROM    labelfile 
		left outer join (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_rm_name=@rmf_rm_name and rmf_name = @rmf_name) r
			on r.rmf_value = abbr
	where labeldefinition = @labeldefinition
	order by abbr

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_GetUserRMCLbl] TO [public]
GO
