SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[actg_glreset_APPRGetActual](@UseNonGPRules int, @HdrRevType1 int, @HdrRevType2 int, @HdrRevType3 int, @HdrRevType4 int, @HdrOverridesDtl int, @Dtl int, @TriggerItem varchar(20)) returns varchar(20)
as
begin
   DECLARE @Pyh int, @AsgnType varchar(6), @AsgnID varchar(13), @Lgh int, @Ord int, @Stp int, @RetVal varchar(50)
   SELECT @Pyh = pyh_number, @AsgnType = asgn_type, @AsgnID = asgn_id, @Lgh = ISNULL(lgh_number, 0), @Ord=ISNULL(ord_hdrnumber, 0), @Stp = ISNULL(stp_number, 0) FROM actg_PayDetailView WHERE pyd_number = @Dtl

   if @TriggerItem = 'TRC' or @TriggerItem = 'TRCCLASS1' or @TriggerItem = 'TRCCLASS2' or @TriggerItem = 'TRCCLASS3' or @TriggerItem = 'TRCCLASS4'
       BEGIN
           DECLARE @Trc varchar(8)
           SELECT @Trc = l.lgh_tractor FROM legheader l INNER JOIN actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
           IF ISNULL(@Trc, '') = '' 
               SELECT @Trc = o.ord_tractor FROM orderheader o inner join actg_PayDetailView a ON o.ord_hdrnumber = a.ord_hdrnumber WHERE a.pyd_number = @Dtl
           IF ISNULL(@Trc, '') = '' AND @AsgnType = 'TRC' 
               SELECT @Trc = @AsgnID
           IF ISNULL(@Trc, '') = '' AND @AsgnType = 'DRV'
               SELECT @Trc = mpp_tractornumber FROM manpowerprofile WHERE mpp_id = @AsgnID
           if @TriggerItem = 'TRC' 
               select @RetVal = @Trc
           else if @TriggerItem = 'TRCCLASS1' 
               Select @RetVal = trc_type1 FROM tractorprofile where trc_number = @Trc
           else if @TriggerItem = 'TRCCLASS2' 
               Select @RetVal = trc_type2 FROM tractorprofile where trc_number = @Trc
           else if @TriggerItem = 'TRCCLASS3' 
               Select @RetVal = trc_type3 FROM tractorprofile where trc_number = @Trc
           else if @TriggerItem = 'TRCCLASS4'
               Select @RetVal = trc_type4 FROM tractorprofile where trc_number = @Trc
       END
   else if @TriggerItem = 'REVCLASS1'
       BEGIN
           IF ISNULL(@Pyh, 0)<> 0 AND @HdrRevType1 <> 0
               SELECT @RetVal = MAX(l.lgh_class1) FROM legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           IF ISNULL(@RetVal, '') = ''
               SELECT @RetVal = l.lgh_class1 FROM legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'REVCLASS2'
       BEGIN
           IF ISNULL(@Pyh, 0)<> 0 AND @HdrRevType2 <> 0
               SELECT @RetVal = MAX(l.lgh_class2) FROM legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           IF ISNULL(@RetVal, '') = ''
               SELECT @RetVal = l.lgh_class2 FROM legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'REVCLASS3'
       BEGIN
           IF ISNULL(@Pyh, 0)<> 0 AND @HdrRevType3 <> 0
               SELECT @RetVal = MAX(l.lgh_class3) FROM legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           IF ISNULL(@RetVal, '') = ''
               SELECT @RetVal = l.lgh_class3 FROM legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'REVCLASS4'
       BEGIN
           IF ISNULL(@Pyh, 0)<> 0 AND @HdrRevType4 <> 0
               SELECT @RetVal = MAX(l.lgh_class4) FROM legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           IF ISNULL(@RetVal, '') = ''
               SELECT @RetVal = l.lgh_class4 FROM legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'COMCLASS'
       BEGIN
               Select @RetVal = c.cmd_class from actg_PayDetailView a inner join orderheader o on a.ord_hdrnumber = o.ord_hdrnumber inner join commodity c ON o.cmd_code=c.cmd_code WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'trl_type1' 
       BEGIN
           IF @AsgnType = 'TRL'
               SELECT @RetVal = trl_type1 from trailerprofile where trl_number = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trl_type1) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trl_type1 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'trl_type2' 
       BEGIN
           IF @AsgnType = 'TRL'
               SELECT @RetVal = trl_type2 from trailerprofile where trl_number = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trl_type2) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trl_type2 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'trl_type3' 
       BEGIN
           IF @AsgnType = 'TRL'
               SELECT @RetVal = trl_type3 from trailerprofile where trl_number = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trl_type3) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trl_type3 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'trl_type4' 
       BEGIN
           IF @AsgnType = 'TRL'
               SELECT @RetVal = trl_type4 from trailerprofile where trl_number = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trl_type4) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trl_type4 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'drv_type1' 
       BEGIN
           IF @AsgnType = 'DRV'
               SELECT @RetVal = mpp_type1 from manpowerprofile where mpp_id  = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_type1) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_type1 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'drv_type2' 
       BEGIN
           IF @AsgnType = 'DRV'
               SELECT @RetVal = mpp_type2 from manpowerprofile where mpp_id  = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_type2) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_type2 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'drv_type3'
       BEGIN
           IF @AsgnType = 'DRV'
               SELECT @RetVal = mpp_type3 from manpowerprofile where mpp_id  = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_type3) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_type3 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'drv_type4' 
       BEGIN
           IF @AsgnType = 'DRV'
               SELECT @RetVal = mpp_type4 from manpowerprofile where mpp_id  = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_type4) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_type4 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'car_type1' 
       BEGIN
           IF @AsgnType = 'CAR'
               SELECT @RetVal = car_type1 from carrier where car_id  = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(c.car_type1) from carrier c inner join legheader l ON c.car_id = l.lgh_carrier inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = c.car_type1 from carrier c inner join legheader l ON c.car_id = l.lgh_carrier inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'car_type2' 
       BEGIN
           IF @AsgnType = 'CAR'
               SELECT @RetVal = car_type2 from carrier where car_id  = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(c.car_type2) from carrier c inner join legheader l ON c.car_id = l.lgh_carrier inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = c.car_type2 from carrier c inner join legheader l ON c.car_id = l.lgh_carrier inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'car_type3' 
       BEGIN
           IF @AsgnType = 'CAR'
               SELECT @RetVal = car_type3 from carrier where car_id  = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(c.car_type3) from carrier c inner join legheader l ON c.car_id = l.lgh_carrier inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = c.car_type3 from carrier c inner join legheader l ON c.car_id = l.lgh_carrier inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'car_type4' 
       BEGIN
           IF @AsgnType = 'CAR'
               SELECT @RetVal = car_type4 from carrier where car_id  = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(c.car_type4) from carrier c inner join legheader l ON c.car_id = l.lgh_carrier inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = c.car_type4 from carrier c inner join legheader l ON c.car_id = l.lgh_carrier inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'NATGL' or @TriggerItem = 'CURGL'
       BEGIN
           RETURN CAST('NATGL and CURGL resets are handled only by the main GL Reset loop.' as int)
       END
   else if @TriggerItem = 'ASGNTYPE'
       SELECT @RetVal = @AsgnType
   else if @TriggerItem = 'trc_term' or @TriggerItem = 'TRC_TERMINAL'
       BEGIN
           IF @AsgnType = 'TRC'
               SELECT @RetVal = trc_terminal from tractorprofile where trc_number = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trc_terminal) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trc_terminal from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'TPRCLASS1'
       BEGIN
           IF @AsgnType = 'TPR'
               SELECT @RetVal = tpr_revtype1 from thirdpartyprofile where tpr_id = @AsgnID
       END
   else if @TriggerItem = 'TPRCLASS2'
       BEGIN
           IF @AsgnType = 'TPR'
               SELECT @RetVal = tpr_revtype2 from thirdpartyprofile where tpr_id = @AsgnID
       END
   else if @TriggerItem = 'TPRCLASS3'
       BEGIN
           IF @AsgnType = 'TPR'
               SELECT @RetVal = tpr_revtype3 from thirdpartyprofile where tpr_id = @AsgnID
       END
   else if @TriggerItem = 'TPRCLASS4'
       BEGIN
           IF @AsgnType = 'TPR'
               SELECT @RetVal = tpr_revtype4 from thirdpartyprofile where tpr_id = @AsgnID
       END
   else if @TriggerItem = 'TRC_COMPANY'
       BEGIN
           IF @AsgnType = 'TRC'
               SELECT @RetVal = trc_company from tractorprofile where trc_number = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trc_company) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trc_company from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'TRC_DIVISION'
       BEGIN
           IF @AsgnType = 'TRC'
               SELECT @RetVal = trc_division from tractorprofile where trc_number = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trc_division) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trc_division from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'TRC_FLEET'
       BEGIN
           IF @AsgnType = 'TRC'
               SELECT @RetVal = trc_fleet from tractorprofile where trc_number = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trc_fleet) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trc_fleet from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'LEGTYPE1'
       BEGIN
           IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.lgh_type1) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.lgh_type1 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'LEGTYPE2'
       BEGIN
           IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.lgh_type2) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.lgh_type2 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'ORDCOMPANY'
       BEGIN
           IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(o.ord_company) from orderheader o inner join legheader l ON o.ord_hdrnumber = l.ord_hdrnumber inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = o.ord_company from orderheader o inner join legheader l ON o.ord_hdrnumber = l.ord_hdrnumber inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'TRL_TERMINAL'
       BEGIN
           IF @AsgnType = 'TRL'
               SELECT @RetVal = trl_terminal from trailerprofile where trl_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trl_terminal) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trl_terminal from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'TRL_COMPANY'
       BEGIN
           IF @AsgnType = 'TRL'
               SELECT @RetVal = trl_company from trailerprofile where trl_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trl_company) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trl_company from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'TRL_DIVISION'
       BEGIN
           IF @AsgnType = 'TRL'
               SELECT @RetVal = trl_division from trailerprofile where trl_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trl_division) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trl_division from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'TRL_FLEET'
       BEGIN
           IF @AsgnType = 'TRL'
               SELECT @RetVal = trl_fleet from trailerprofile where trl_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.trl_fleet) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.trl_fleet from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'LGH_BOOKED_REVTYPE1'
       BEGIN
           IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.lgh_booked_revtype1) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.lgh_booked_revtype1 from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'MPP_FLEET'
       BEGIN
           IF @AsgnType = 'DRV'
               SELECT @RetVal = mpp_fleet from manpowerprofile where mpp_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_fleet) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_fleet from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'MPP_TERMINAL' OR @TriggerItem = 'LGHDRVTRM'
       BEGIN
           IF @AsgnType = 'DRV' AND @TriggerItem <> 'LGHDRVTRM'
               SELECT @RetVal = mpp_terminal from manpowerprofile where mpp_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_terminal) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_terminal from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'MPP_COMPANY'
       BEGIN
           IF @AsgnType = 'DRV'
               SELECT @RetVal = mpp_company from manpowerprofile where mpp_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_company) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_company from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'ORD_BOOKED_REVTYPE1'
       BEGIN
           IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(o.ORD_BOOKED_REVTYPE1) from orderheader o inner join legheader l ON o.ord_hdrnumber = l.ord_hdrnumber inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = o.ORD_BOOKED_REVTYPE1 from orderheader o inner join legheader l ON o.ord_hdrnumber = l.ord_hdrnumber inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'CURR'
       BEGIN
           DECLARE @PRorAP varchar(1), @PTO_Curr varchar(6)
           SELECT @RetVal = NULL
           IF ISNULL(@Pyh, 0) <> 0
              BEGIN
                   SELECT @RetVal = ISNULL(pyh_currency, ''), @PRorAP = ISNULL(pyh_prorap, ''), @PTO_Curr = ISNULL(pto_currency, '') FROM payheader LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id WHERE pyh_pyhnumber = @Pyh
                   IF ISNULL(@RetVal, '') = '' AND @PRorAP = 'A' SELECT @RetVal = @PTO_Curr
               END
           IF ISNULL(@RetVal, '') = '' 
               BEGIN
                   SELECT @RetVal = ISNULL(pyd_currency, ''), @PRorAP = ISNULL(pyd_prorap, ''), @PTO_Curr = ISNULL(pto_currency, '') FROM actg_PayDetailView LEFT OUTER JOIN payto ON actg_PayDetailView.pyd_payto = payto.pto_id WHERE pyd_number = @Dtl
                   IF ISNULL(@RetVal, '') = '' AND @PRorAP = 'A' SELECT @RetVal = @PTO_Curr
               END
           IF ISNULL(@RetVal, '') = '' AND @AsgnType = 'DRV' SELECT @RetVal = ISNULL(mpp_currency, '') FROM manpowerprofile WHERE mpp_id = @AsgnID
           IF ISNULL(@RetVal, '') = '' AND @AsgnType = 'TPR' SELECT @RetVal = ISNULL(tpr_currency, '') FROM thirdpartyprofile WHERE tpr_id = @AsgnID
           IF ISNULL(@RetVal, '') = '' AND @AsgnType = 'CAR' SELECT @RetVal = ISNULL(car_currency, '') FROM carrier WHERE car_id = @AsgnID
       END
   else if @TriggerItem = 'MPP_TEAMLEADER'
       BEGIN
           IF @AsgnType = 'DRV'
               SELECT @RetVal = mpp_teamleader from manpowerprofile where mpp_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_teamleader) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_teamleader from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'MPP_DIVISION'
       BEGIN
           IF @AsgnType = 'DRV'
               SELECT @RetVal = mpp_division from manpowerprofile where mpp_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_division) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_division from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'MPP_DOMICILE'
       BEGIN
           IF @AsgnType = 'DRV'
               SELECT @RetVal = mpp_domicile from manpowerprofile where mpp_id = @AsgnID
           ELSE IF ISNULL(@Pyh, 0) <> 0 AND (@Lgh = 0 OR @HdrOverridesDtl <> 0)
               SELECT @RetVal = MAX(l.mpp_domicile) from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyh_number = @Pyh
           ELSE
               SELECT @RetVal = l.mpp_domicile from legheader l inner join actg_PayDetailView a ON l.lgh_number = a.lgh_number WHERE a.pyd_number = @Dtl
       END
   else if @TriggerItem = 'PAYTYPE'
       SELECT @RetVal = pyt_itemcode FROM actg_PayDetailView WHERE pyd_number = @Dtl
   else if @TriggerItem = 'EXP_RA_GROUP'
       exec actg_glreset_APPRGetActual_Extensions @UseNonGPRules, @HdrOverridesDtl, @Dtl, @TriggerItem, @RetVal OUT
   else if @TriggerItem = 'PTOBRANCH'
       SELECT @RetVal = pyd_branch FROM actg_PayDetailView WHERE pyd_number = @Dtl
   else if @TriggerItem = 'PTOLGENT'
       SELECT  @RetVal = ISNULL(brn_legalentity, '') FROM actg_PayDetailView LEFT OUTER JOIN branch on pyd_branch = brn_id WHERE pyd_number = @Dtl
   else
       BEGIN
           RETURN CAST(('Unrecognized Invoice GL Reset Type ' + @TriggerItem) As Int)
       END
   
   RETURN @Retval
end
GO
GRANT EXECUTE ON  [dbo].[actg_glreset_APPRGetActual] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.04
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'actg_glreset_APPRGetActual', NULL, NULL
GO
