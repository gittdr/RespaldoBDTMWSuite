SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[create_orderholdfromrule_sp] (@ruleid integer, @errormsg varchar(255) out)
AS
 Declare @deconsolidateflg as char(1)

 
 Select @deconsolidateflg = 'Y'
 
	 exec create_orderholdfromrulenew_sp @ruleid, @deconsolidateflg, @errormsg output
	 
GO
GRANT EXECUTE ON  [dbo].[create_orderholdfromrule_sp] TO [public]
GO
