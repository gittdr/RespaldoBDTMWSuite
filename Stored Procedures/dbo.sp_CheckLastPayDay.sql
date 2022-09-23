SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CheckLastPayDay]
		(	@_asgnid varchar(13),	-- mpp_id is varchar (8), ckc_asgnid is varchar(13)
			@_asgntype varchar(6)
		)

AS

SELECT     TOP (1) pyh_payperiod, pyh_paystatus, pyh_pyhnumber, asgn_type, asgn_id
FROM         payheader
WHERE     (asgn_type = @_asgntype) AND (asgn_id = @_asgnid)
ORDER BY pyh_payperiod DESC
	
GO
GRANT EXECUTE ON  [dbo].[sp_CheckLastPayDay] TO [public]
GO
