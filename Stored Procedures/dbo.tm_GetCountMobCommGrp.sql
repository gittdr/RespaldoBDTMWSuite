SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GetCountMobCommGrp]
	@MaxGroup int

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT count(*)
     FROM tblTrucks t
     INNER JOIN tblCabUnits c ON t.DefaultCabUnit = c.sn
    WHERE t.GroupFlag = 0 AND ISNULL(t.DefaultCabUnit, 0) > 0 AND c.Type = 1
        AND (SELECT COUNT(*) 
             FROM tblCabUnitGroups g  join tblTrucks r on  r.defaultcabunit =  g.groupcabsn 
                  WHERE g.MemberCabSN = t.DefaultCabUnit  and r.groupflag=1
                 AND g.Deleted <> 1) > @MaxGroup
GO
GRANT EXECUTE ON  [dbo].[tm_GetCountMobCommGrp] TO [public]
GO
