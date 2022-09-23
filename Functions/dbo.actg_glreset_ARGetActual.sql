SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create function [dbo].[actg_glreset_ARGetActual](@UseNonGPRules int, @UseRevAlloc int, @HdrOverridesDtl int, @Dtl int, @TriggerItem varchar(20)) returns varchar(20)
as
begin
   return dbo.actg_glreset_ARGetActual2(@UseNonGPRules, @UseRevAlloc, @HdrOverridesDtl, @Dtl, @TriggerItem, NULL)
end
GO
GRANT EXECUTE ON  [dbo].[actg_glreset_ARGetActual] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.02
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'actg_glreset_ARGetActual', NULL, NULL
GO
