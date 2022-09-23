SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create function [dbo].[actg_glreset_ARGetActual2](@UseNonGPRules int, @UseRevAlloc int, @HdrOverridesDtl int, @Dtl int, @TriggerItem varchar(20), @OverrideLgh int) returns varchar(20)
as
begin
   DECLARE @OrdHdr int, @Ivd int, @Ivh int, @Lgh int
   declare @Trc varchar(8), @Drv varchar(8), @Trl varchar(13), @Car varchar(13)
   DECLARE @Retval varchar(20)

   IF @UseRevAlloc<>0
       SELECT @Ivd = ivd_number, @Lgh = lgh_number FROM revenueallocation WHERE ral_id = @Dtl
   else
       SELECT @Ivd = ivd_number, @Lgh = ivd_paylgh_number from invoicedetail where ivd_number = @Dtl

   IF ISNULL(@OverrideLgh, 0) > 0 SELECT @Lgh = @OverrideLgh

   SELECT @Ivh = ivh_hdrnumber, @OrdHdr = ord_hdrnumber from invoicedetail where ivd_number = @Ivd
   IF ISNULL(@Ivh, 0) =0 SELECT @HdrOverridesDtl = 0, @Ivh = -1

   IF ISNULL(@Lgh, 0) = 0 AND ISNULL(@OrdHdr, 0)<> 0 
       select @Lgh = MIN(lgh_number) from stops where ord_hdrnumber = @OrdHdr and ISNULL(lgh_number, 0)<> 0
   
   IF ISNULL(@Lgh, 0)<> 0
       SELECT @Drv = lgh_driver1, @Trc = lgh_tractor, @Car = lgh_carrier FROM Legheader where lgh_number = @Lgh
   ELSE IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
       SELECT @Drv = ivh_driver, @Trc = ivh_tractor, @Car = ivh_carrier FROM invoiceheader where ivh_hdrnumber = @Ivh
   else
       SELECT @Drv = ord_driver1, @Trc = ord_tractor, @Car = ord_carrier FROM orderheader where ord_hdrnumber = @OrdHdr

   if @TriggerItem = 'TRC'
       SELECT @Retval = @Trc
   else if @TriggerItem = 'REVCLASS1'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = ivh_revtype1 FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = ord_revtype1 FROM orderheader where ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'REVCLASS2'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = ivh_revtype2 FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = ord_revtype2 FROM orderheader where ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'REVCLASS3'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = ivh_revtype3 FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = ord_revtype3 FROM orderheader where ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'REVCLASS4'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = ivh_revtype4 FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = ord_revtype4 FROM orderheader where ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'ORDCOMPANY'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = ivh_company FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = ord_company FROM orderheader where ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'BILLTO'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = ivh_billto FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = ord_billto FROM orderheader where ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'ORD_BOOKED_REVTYPE1' or @TriggerItem = 'BRANCH'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = ivh_BOOKED_REVTYPE1 FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = ORD_BOOKED_REVTYPE1 FROM orderheader where ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'COMCLASS'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = commodity.cmd_class FROM commodity inner join invoiceheader on commodity.cmd_code = invoiceheader.ivh_order_cmd_code where invoiceheader.ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = commodity.cmd_class FROM commodity inner join orderheader on commodity.cmd_code = orderheader.cmd_code where orderheader.ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'trc_type1'
       BEGIN
           SELECT @RetVal = trc_type1 from tractorprofile where trc_number = @Trc
       END
   else if @TriggerItem = 'trc_type2'
       BEGIN
           SELECT @RetVal = trc_type2 from tractorprofile where trc_number = @Trc
       END
   else if @TriggerItem = 'trc_type3'
       BEGIN
           SELECT @RetVal = trc_type3 from tractorprofile where trc_number = @Trc
       END
   else if @TriggerItem = 'trc_type4'
       BEGIN
           SELECT @RetVal = trc_type4 from tractorprofile where trc_number = @Trc
       END
   else if @TriggerItem = 'trc_term'
       BEGIN
           SELECT @RetVal = trc_terminal from tractorprofile where trc_number = @Trc
       END
   else if @TriggerItem = 'TRC_COMPANY'
       BEGIN
           SELECT @RetVal = TRC_COMPANY from tractorprofile where trc_number = @Trc
       END
   else if @TriggerItem = 'TRC_DIVISION'
       BEGIN
           SELECT @RetVal = TRC_DIVISION from tractorprofile where trc_number = @Trc
       END
   else if @TriggerItem = 'TRC_FLEET'
       BEGIN
           SELECT @RetVal = TRC_FLEET from tractorprofile where trc_number = @Trc
       END
   else if @TriggerItem = 'trl_type1' 
           or @TriggerItem = 'trl_type2' 
           or @TriggerItem = 'trl_type3' 
           or @TriggerItem = 'trl_type4'
           or @TriggerItem = 'TRL_TERMINAL'
           or @TriggerItem = 'TRL_COMPANY'
           or @TriggerItem = 'TRL_DIVISION'
           or @TriggerItem = 'TRL_FLEET'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @Trl = ivh_trailer FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @Trl = ord_trailer FROM orderheader where ord_hdrnumber = @OrdHdr
           IF @TriggerItem = 'trl_type1'
               SELECT @Retval = trl_type1 from trailerprofile where trl_id = @Trl
           ELSE IF @TriggerItem = 'trl_type2'
               SELECT @Retval = trl_type2 from trailerprofile where trl_id = @Trl
           ELSE IF @TriggerItem = 'trl_type3'
               SELECT @Retval = trl_type3 from trailerprofile where trl_id = @Trl
           ELSE IF @TriggerItem = 'trl_type4'
               SELECT @Retval = trl_type4 from trailerprofile where trl_id = @Trl
           ELSE IF @TriggerItem = 'TRL_TERMINAL'
               SELECT @Retval = trl_terminal from trailerprofile where trl_id = @Trl
           ELSE IF @TriggerItem = 'TRL_COMPANY'
               SELECT @Retval = trl_company from trailerprofile where trl_id = @Trl
           ELSE IF @TriggerItem = 'TRL_DIVISION'
               SELECT @Retval = trl_division from trailerprofile where trl_id = @Trl
           ELSE IF @TriggerItem = 'TRL_FLEET'
               SELECT @Retval = trl_fleet from trailerprofile where trl_id = @Trl
       END
   else if @TriggerItem = 'mpp_type1'
       BEGIN
           SELECT @RetVal = mpp_type1 from manpowerprofile where mpp_id = @Drv
       END
   else if @TriggerItem = 'mpp_type2'
       BEGIN
           SELECT @RetVal = mpp_type2 from manpowerprofile where mpp_id = @Drv
       END
   else if @TriggerItem = 'mpp_type3'
       BEGIN
           SELECT @RetVal = mpp_type3 from manpowerprofile where mpp_id = @Drv
       END
   else if @TriggerItem = 'mpp_type4'
       BEGIN
           SELECT @RetVal = mpp_type4 from manpowerprofile where mpp_id = @Drv
       END
   else if @TriggerItem = 'MPP_FLEET'
       BEGIN
           SELECT @RetVal = MPP_FLEET from manpowerprofile where mpp_id = @Drv
       END
   else if @TriggerItem = 'MPP_TERMINAL'
       BEGIN
           SELECT @RetVal = MPP_TERMINAL from manpowerprofile where mpp_id = @Drv
       END
   else if @TriggerItem = 'MPP_COMPANY'
       BEGIN
           SELECT @RetVal = MPP_COMPANY from manpowerprofile where mpp_id = @Drv
       END
   else if @TriggerItem = 'MPP_DIVISION'
       BEGIN
           SELECT @RetVal = MPP_DIVISION from manpowerprofile where mpp_id = @Drv
       END
   else if @TriggerItem = 'MPP_DOMICILE'
       BEGIN
           SELECT @RetVal = MPP_DOMICILE from manpowerprofile where mpp_id = @Drv
       END
   else if @TriggerItem = 'car_type1'
       BEGIN
           SELECT @RetVal = car_type1 from carrier where car_id = @Car
       END
   else if @TriggerItem = 'car_type2'
       BEGIN
           SELECT @RetVal = car_type2 from carrier where car_id = @Car
       END
   else if @TriggerItem = 'car_type3'
       BEGIN
           SELECT @RetVal = car_type3 from carrier where car_id = @Car
       END
   else if @TriggerItem = 'car_type4'
       BEGIN
           SELECT @RetVal = car_type4 from carrier where car_id = @Car
       END
   else if @TriggerItem = 'NATGL' or @TriggerItem = 'CURGL'
       BEGIN
           RETURN CAST('NATGL and CURGL resets are handled only by the main GL Reset loop.' as int)
       END
   else if @TriggerItem = 'lgh_type1' or @TriggerItem = 'LEGTYPE1'
       BEGIN
           SELECT @RetVal = lgh_type1 from legheader where lgh_number = @Lgh
       END
   else if @TriggerItem = 'lgh_type2' or @TriggerItem = 'LEGTYPE2'
       BEGIN
           SELECT @RetVal = lgh_type2 from legheader where lgh_number = @Lgh
       END
   else if @TriggerItem = 'LGH_BOOKED_REVTYPE1'
       BEGIN
           SELECT @RetVal = lgh_booked_revtype1 from legheader where lgh_number = @Lgh
       END
   else if @TriggerItem = 'ALLOCITEM'
       BEGIN
           IF @UseRevAlloc = 0
               RETURN CAST('ALLOCITEM GL Reset rule requires revenue allocations to be active' as int)
           ELSE
               SELECT @RetVal = ral_prorateitem from revenueAllocation where ral_id = @Dtl
       END
   else if @TriggerItem = 'CURR'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = ivh_currency FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = ord_currency FROM orderheader where ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'LGHDRVTRM'
       BEGIN
           SELECT @RetVal = mpp_terminal from legheader where lgh_number = @Lgh
       END
   else if @TriggerItem = 'BLTOBKTRM'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = c.cmp_bookingterminal FROM invoiceheader i INNER JOIN company c on i.ivh_billto = c.cmp_id where i.ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = c.cmp_bookingterminal FROM orderheader o INNER JOIN company c on o.ord_billto = c.cmp_id where o.ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'BLTOLGENT'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = b.brn_legalentity FROM invoiceheader i INNER JOIN company c on i.ivh_billto = c.cmp_id LEFT OUTER JOIN branch b ON c.cmp_bookingterminal = b.brn_id where i.ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = b.brn_legalentity FROM orderheader o INNER JOIN company c on o.ord_billto = c.cmp_id LEFT OUTER JOIN branch b ON c.cmp_bookingterminal = b.brn_id where o.ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'IVDCMD'
       BEGIN
           IF @UseRevAlloc<>0
               SELECT @RetVal = invoicedetail.cmd_code FROM revenueallocation left outer join invoicedetail on revenueallocation.ivd_number = invoicedetail.ivd_number WHERE revenueallocation.ral_id = @Dtl
           else
               SELECT @RetVal = invoicedetail.cmd_code FROM invoicedetail WHERE ivd_number = @Dtl
       END
   else if @TriggerItem = 'SHIPPER'
       BEGIN
           IF ISNULL(@OrdHdr, 0) = 0 or @HdrOverridesDtl <> 0
               SELECT @RetVal = ivh_shipper FROM invoiceheader where ivh_hdrnumber = @Ivh
           else
               SELECT @RetVal = ord_shipper FROM orderheader where ord_hdrnumber = @OrdHdr
       END
   else if @TriggerItem = 'TARCHT'
       BEGIN
           SELECT @RetVal = 'UNK'
           IF @UseRevAlloc<>0
               SELECT TOP 1 @RetVal = t.cht_itemcode FROM tariffheader t inner join invoicedetail i on t.tar_number = i.tar_number inner join revenueallocation r on r.ivd_number = i.ivd_number WHERE r.ral_id = @Dtl
           Else
               SELECT TOP 1 @RetVal = t.cht_itemcode FROM tariffheader t inner join invoicedetail i on t.tar_number = i.tar_number WHERE i.ivd_number = @Dtl
       END
   else
       BEGIN
           RETURN CAST(('Unrecognized Invoice GL Reset Type ' + @TriggerItem) As Int)
       END
   
   RETURN @Retval
end
GO
GRANT EXECUTE ON  [dbo].[actg_glreset_ARGetActual2] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.01
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'actg_glreset_ARGetActual2', NULL, NULL
GO
