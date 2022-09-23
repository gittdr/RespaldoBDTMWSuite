SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[actg_appr_glreset] (@UseNonGPRules int, @HdrRevType1 int, @HdrRevType2 int, @HdrRevType3 int, @HdrRevType4 int, @HdrOverridesDtl int, @NatGLStart int, @NatGLLen int, @DynamicNatGL int, @RegenGL int, @Dtl int, @CurGL varchar(50)) returns varchar(50)
as
begin
   declare @CurID as int, @Pyt varchar(20), @NatGL varchar(50), @InExc int, @Pass int
   declare @Sys as varchar(6)
   DECLARE @TriggerItem varchar(20), @MatchValue varchar(20), @Pos int, @Len int, @Rep varchar(20), @Exc varchar(MAX), @Check varchar(20)
   IF RTRIM(ISNULL(@CurGL, ''))='' SET @CurGL = NULL
   select @CurGL = ISNULL(@CurGL, pyd_glnum), @Pyt = pyt_itemcode, @Sys = pyd_prorap from paydetail where pyd_number = @Dtl
   if @Sys = 'P'
       SET @Sys = 'PAY'
   ELSE
       SET @Sys = 'AP'
   if @RegenGL <> 0 or ((@CurGL is not null) and RTRIM(@CurGL)= '')
       SET @CurGL = NULL
   if @Sys = 'PAY'
       SELECT @CurGL = ISNULL(RTRIM(ISNULL(@CurGL, pyt_pr_glnum)), '') from paytype where pyt_itemcode = @Pyt
   else
       SELECT @CurGL = ISNULL(RTRIM(ISNULL(@CurGL, pyt_ap_glnum)), '') from paytype where pyt_itemcode = @Pyt
   if @DynamicNatGL = 0
       SELECT @NatGL = SUBSTRING(@CurGL+SPACE(@NatGLStart-1+@NatGLLen), @NatGLStart, @NatGLLen)
   select @CurID = min(gl_id) from gl_reset where gl_transferto = @Sys
   while 1=1
   begin
       if @CurID Is Null return @CurGL
       select @TriggerItem = gl_triggeritem, @MatchValue = gl_matchvalue, @Pos = gl_startposition, @Len = gl_length, 
               @Rep = gl_value, @Exc = gl_excluded_acct_codes
               from gl_reset where gl_id = @CurID
       if @DynamicNatGL <> 0 AND (RTRIM(ISNULL(@Exc, '')) <> '' OR @TriggerItem = 'NATGL')
           SELECT @NatGL = SUBSTRING(LEFT(ISNULL(@CurGL, '') + SPACE(@NatGLStart-1+@NatGLLen), 50), @NatGLStart-1, @NatGLLen)
       if RTRIM(ISNULL(@Exc, ''))<>'' SELECT @InExc=PATINDEX('%'+@NatGL+'%',@Exc) ELSE SELECT @InExc=0
       if LEFT(RTRIM(ISNULL(@Exc, '')),1)='!' 
           BEGIN
           IF @InExc = 0
               SELECT @InExc = 1
           ELSE
               SELECT @InExc = 0
           END
       IF @InExc = 0
           BEGIN
           IF @TriggerItem = 'NATGL'
               SELECT @Check = @NatGL
           ELSE IF @TriggerItem = 'CURGL'
               SELECT @Check = @CurGL
           ELSE
               SELECT @Check = dbo.actg_glreset_APPRGetActual(@UseNonGPRules, @HdrRevType1, @HdrRevType2, @HdrRevType3, @HdrRevType4, @HdrOverridesDtl, @Dtl, @TriggerItem)
           IF @TriggerItem = 'TRC' OR @TriggerItem = 'PAYTYPE'
               SELECT @CurGL = LEFT(@CurGL, @Pos - 1)+@Check+SUBSTRING(@CurGL, @Pos+@Len, 99)
           ELSE IF @Check = @MatchValue
               SELECT @CurGL = LEFT(@CurGL, @Pos - 1)+@Rep+SUBSTRING(@CurGL, @Pos+@Len, 99)
           END
       select @CurID = min(gl_id) from gl_reset where gl_id > @CurID and gl_transferto = @Sys
   end
   return CAST('Should never get here' as int)
end
GO
GRANT EXECUTE ON  [dbo].[actg_appr_glreset] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.02
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'actg_appr_glreset', NULL, NULL
GO
