SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create proc [dbo].[actg_glreset_APPRGetActual_Extensions] @UseNonGPRules int, @HdrOverridesDtl int, @Dtl int, @TriggerItem varchar(20), @RetVal varchar(20) OUT
AS
BEGIN
   CREATE TABLE #actg_glresetAPPR_Dynamic (Result varchar(50))
   if @TriggerItem = 'EXP_RA_GROUP'
       BEGIN
           if exists (select * from sys.columns c inner join sys.objects o on c.object_id = o.object_id where o.name = 'actg_PayDetailView' and c.name = 'expal_prorateitem')
               BEGIN
               INSERT INTO #actg_glresetAPPR_Dynamic EXEC ('SELECT expal_prorateitem from actg_PayDetailView where pyd_number = '+@Dtl)
               SELECT @RetVal = Result FROM #actg_glresetAPPR_Dynamic 
               END
           else if exists (select * from sys.columns c inner join sys.objects o on c.object_id = o.object_id where o.name = 'actg_PayDetailView' and c.name = 'ral_id')
               BEGIN
               INSERT INTO #actg_glresetAPPR_Dynamic EXEC ('SELECT r.ral_prorateitem from revenueallocation r inner join actg_PayDetailView p on r.ral_id = p.ral_id where p.pyd_number = '+@Dtl)
               SELECT @RetVal = Result FROM #actg_glresetAPPR_Dynamic 
               END
           else 
               RAISERROR ('EXP_RA_GROUP not supported by this actg_PayDetailView', 16, 1)
       END
   else
       RAISERROR ('Unrecognized AP/PR GL Reset rule type %s', 16, 1, @TriggerItem)
END
GO
GRANT EXECUTE ON  [dbo].[actg_glreset_APPRGetActual_Extensions] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.01
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'actg_glreset_APPRGetActual_Extensions', NULL, NULL
GO
