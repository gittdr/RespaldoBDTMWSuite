SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* DPETE 22154 3/30/04 Allows a generic commodity to have many versions



*/
CREATE PROCEDURE [dbo].[subcommodity_sp] @cmdcode varchar(8)
AS

Select 
scm_identity
,cmd_code 
,scm_subcode
,scm_description
,scm_UpdateBy
,scm_UpdateDate
,scm_exclusive
From subcommodity
Where 
cmd_code = @cmdcode
Order By scm_subcode

GO
GRANT EXECUTE ON  [dbo].[subcommodity_sp] TO [public]
GO
