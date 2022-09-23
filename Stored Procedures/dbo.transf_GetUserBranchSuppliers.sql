SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_GetUserBranchSuppliers] 
	(
		@transf_user_id as int
		,@brn_id varchar(12)
	)
AS

set nocount on
	if @brn_id is null or ltrim(rtrim(@brn_id))=''
		set @brn_id='UNK'
		
	select distinct (cmp_name + '(' + cmp_altid + ')') as cmp_altid, cmp_name, cmp_revtype1 as brn_id , ca_id as cmp_id
		from company c
			join transf_userbranches on cmp_revtype1 = transf_userbranches .brn_id and transf_user_id = @transf_user_id
  			join company_alternates on ca_alt = cmp_id
 		where cmp_othertype1 = 'ACTV'
			and (cmp_revtype1 = @brn_id or @brn_id = 'UNK')

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_GetUserBranchSuppliers] TO [public]
GO
