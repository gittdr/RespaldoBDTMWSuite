SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create function [dbo].[actg_ar_glreset2] (@UseNonGPRules int, @UseRevAlloc int, @HdrOverridesDtl int, @NatGLStart int, @NatGLLen int, @DynamicNatGL int, @RegenGL int, @Dtl int, @CurGL varchar(50), @NoGLResetChtItemCodes varchar(MAX), @OverrideLGH int, @OverrideCht varchar(20)) returns varchar(50)
as
begin
   declare @CurID as int, @Cht varchar(20), @NatGL varchar(50), @InExc int, @Pass int
   DECLARE @TriggerItem varchar(20), @MatchValue varchar(20), @Pos int, @Len int, @Rep varchar(20), @Exc varchar(MAX), @Check varchar(20)
   IF RTRIM(ISNULL(@CurGL, ''))='' SET @CurGL = NULL
   if @UseRevAlloc <> 0
       select @CurGL = ISNULL(@CurGL, ral_glnum), @Cht = cht_itemcode from revenueallocation where ral_id = @Dtl
   else
       select @CurGL = ISNULL(@CurGL, ivd_glnum), @Cht = cht_itemcode from invoicedetail where ivd_number = @Dtl
   if ISNULL(@OverrideCht, '') <> '' SELECT @Cht = @OverrideCht
   if @RegenGL <> 0 or ((@CurGL is not null) and RTRIM(@CurGL)= '')
       SET @CurGL = NULL
   SELECT @CurGL = ISNULL(RTRIM(ISNULL(@CurGL, cht_glnum)), '') from chargetype where cht_itemcode = @Cht
   if @DynamicNatGL = 0
       SELECT @NatGL = SUBSTRING(@CurGL + SPACE(@NatGLStart-1+@NatGLLen), @NatGLStart, @NatGLLen)
   SELECT @NoGLResetChtItemCodes = ISNULL(@NoGLResetChtItemCodes , '')
   if @NoGLResetChtItemCodes = '*' OR PATINDEX(','+@NoGLResetChtItemCodes+',', '%,'+@Cht+',%') = 0
   begin
       select @CurID = min(gl_id) from gl_reset where gl_transferto = 'AR'
       while 1=1
       begin
           if @CurID Is Null break
           select @TriggerItem = gl_triggeritem, @MatchValue = gl_matchvalue, @Pos = gl_startposition, @Len = gl_length, 
                   @Rep = gl_value, @Exc = gl_excluded_acct_codes
                   from gl_reset where gl_id = @CurID
           if @DynamicNatGL <> 0 AND (RTRIM(ISNULL(@Exc, '')) <> '' OR @TriggerItem = 'NATGL')
               SELECT @NatGL = SUBSTRING(ISNULL(@CurGL, '') + SPACE(@NatGLStart-1+@NatGLLen), @NatGLStart, @NatGLLen)
           if RTRIM(ISNULL(@Exc, ''))<>'' SELECT @InExc=PATINDEX('%'+@NatGL+'%',@Exc) ELSE SELECT @InExc = 0
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
                   SELECT @Check = dbo.actg_glreset_ARGetActual2(@UseNonGPRules, @UseRevAlloc, @HdrOverridesDtl, @Dtl, @TriggerItem, @OverrideLgh)
               IF @TriggerItem = 'TRC'
                   SELECT @CurGL = LEFT(@CurGL, @Pos - 1)+@Check+SUBSTRING(@CurGL, @Pos+@Len, 99)
               ELSE IF @Check = @MatchValue
                   BEGIN
                   SELECT @CurGL = LEFT(@CurGL, @Pos - 1)+@Rep+SUBSTRING(@CurGL, @Pos+@Len, 99)
                   IF @DynamicNatGL = 0 AND @TriggerItem = 'TARCHT'  -- See PTS 83478: by its nature, if this rule applies, the natgl should be reevaluated.
                       SELECT @NatGL = SUBSTRING(ISNULL(@CurGL, '') + SPACE(@NatGLStart-1+@NatGLLen), @NatGLStart, @NatGLLen)
                   END
               END
           select @CurID = min(gl_id) from gl_reset where gl_id > @CurID and gl_transferto = 'AR'
       end
   end
   return @CurGL
end
GO
GRANT EXECUTE ON  [dbo].[actg_ar_glreset2] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.02
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'actg_ar_glreset2', NULL, NULL
GO
