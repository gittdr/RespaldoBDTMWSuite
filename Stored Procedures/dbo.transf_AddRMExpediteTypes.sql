SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_AddRMExpediteTypes]
	(
		@transf_user_id int
		, @rmf_rm_name varchar(20)
		, @rmf_name varchar (20)
		, @labeldefinition varchar (20)
	)
AS

set nocount on

declare @ord_revtype3_list varchar(8000)

	SELECT @ord_revtype3_list = isNull(gi_string1,'')
		FROM generalinfo
		WHERE gi_name = 'TF_Rev3ListForPrimaryDelayDate'

	INSERT INTO transf_RMFilter
	  (transf_user_id, rmf_rm_name, rmf_name, rmf_value, create_dt)
	  select @transf_user_id, @rmf_rm_name, @rmf_name, abbr, GETDATE()
	  from labelfile
	  where labeldefinition = @labeldefinition
		and abbr in (select convert(varchar(20), value) from transf_parseListToTable (@ord_revtype3_list, ','))

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_AddRMExpediteTypes] TO [public]
GO
