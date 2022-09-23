SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[actg_ar_glreset] (@UseNonGPRules int, @UseRevAlloc int, @HdrOverridesDtl int, @NatGLStart int, @NatGLLen int, @DynamicNatGL int, @RegenGL int, @Dtl int, @CurGL varchar(50), @NoGLResetChtItemCodes varchar(MAX)) returns varchar(50)
as
begin
   return dbo.actg_ar_glreset2 (@UseNonGPRules, @UseRevAlloc, @HdrOverridesDtl, @NatGLStart, @NatGLLen, @DynamicNatGL, @RegenGL, @Dtl, @CurGL, @NoGLResetChtItemCodes, NULL, NULL)
end
GO
GRANT EXECUTE ON  [dbo].[actg_ar_glreset] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.01
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'actg_ar_glreset', NULL, NULL
GO
