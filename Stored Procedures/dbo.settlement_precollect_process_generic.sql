SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[settlement_precollect_process_generic](  @pl_pyhnumber int , @ps_asgn_type varchar(6),@ps_asgn_id varchar(13) ,
                                          @pdt_payperiod datetime, @psd_id int , @ps_returnmsg varchar(255) OUT)
as
/**
 *
 * NAME:
 * dbo.settlement_precollect_process_generic
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Creates custom paydetails tied to a payheader for a payperiod based on custom rules and gi setting PrecollectGenericType
 *
 * RETURNS:
 * 1 success -1 error
 *
 * RESULT SETS:
*   None *
 * PARAMETERS:
 * 001 - @pl_pyhnumber int
 * 002 - @ps_asgn_type varchar(6)
 * 003 - @ps_asgn_id varchar(13)
 * 004 - @pdt_payperiod datetime
 * 005 - @psd_id int batch id
 * 006 - @ps_returnmsg varchar(255) OUTPUT
 * REFERENCES:
 * none
 *
 * REVISION HISTORY:
 * 02/14/06 JD  Created PTS 31448 Loves Travels
 * 4/27/2009   DJM      PTS 43873   Miller Transfer.  Added option for Driver Weekly Minimum
 * 10/18/2012 SPN PTS63193 - Modified this wrapper to execute multiple procs and have one return but break out when any fail happens
 * 03/03/2014 vjh PTS73004 - added MinWage
 *
 **/

declare @ls_string1 varchar(60),@ls_string2 varchar(60),@ldec_shifthrs money,@ls_paytype varchar(8)
declare @li_ctr int , @ldt_startdate datetime,@ldec_shiftpay money , @ldec_minshiftpay money,@ldt_shiftstartdate datetime
declare @PayType varchar(6),
      @actg_type char(1),
      @ap_glnum char(32),
      @Apocalypse datetime,
      @asgn_id varchar(13),
      @asgn_number int,
      @currency varchar(6),
      @glnum char(32),
      @iFlags int,
      @Lgh int,
      @lgh_endcity int,
      @lgh_endpoint varchar(12),
      @lgh_startcity int,
      @lgh_startpoint varchar(12),
      @mov int,
      @ordhdr int,
      @payto varchar(12),
      @pr_glnum char(32),
      @pyd_number int,
      @pyd_number_test int,
      @pyd_quantity_test float,
      @pyd_sequence int,
      @pyt_description varchar(75),
      @pyt_minus int,
      @pyt_pretax char(1),
      @pyt_rateunit varchar(6),
      @pyt_unit varchar(6),
      @Quantity int,
      @spyt_minus char(1),
      @asgn_type varchar(6),
      @pyd_transdate datetime,
      @ps_payto varchar(8),
      @pdec_rate decimal(15,8),
      @pdec_amount decimal(15,8),
      @ls_revtype1 varchar(6),
      @ldt_lastpayperiod datetime

--BEGIN PTS 63193 SPN
DECLARE @RetVal INT
DECLARE @ls_msg VARCHAR(255)
--END PTS 63193 SPN

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @ls_string1 = gi_string1 from generalinfo where gi_name = 'PrecollectGenericType'
--BEGIN PTS 63193 SPN
--select @ps_returnmsg = 'Precollect processed successfully for Resource:' + @ps_asgn_id
--IF @ls_string1 = 'CustomShiftPay'
SELECT @ls_string1 = ',' + IsNull(@ls_string1,'-') + ','
IF CHARINDEX(',CustomShiftPay,', @ls_string1) > 0
--END PTS 63193 SPN
   BEGIN
      create table #tripsbyshift (lghnum int not null,lghstartdate datetime not null, shiftnum int null)
      SELECT @Apocalypse = gi_date1
      FROM generalinfo
      WHERE gi_name = 'APOCALYPSE'

      If @Apocalypse is null
         select @Apocalypse = convert(datetime,'20491231 23:59:59')

      select @ls_string2 = gi_string2 ,@ls_paytype = IsNull(gi_string3,'FLAT') from generalinfo where gi_name = 'PrecollectGenericType'
      If not isNumeric (@ls_string2) = 1
      Begin
         select @ps_returnmsg = 'Shift Interval was not defined.[PrecollectGenericType] generalinfo setting string2'
         Return -1
      End
      Else
      Begin
         select @ldec_shifthrs = Cast(@ls_string2 as money)
         If @ldec_shifthrs < 0
         Begin
            select  @ps_returnmsg 'Shift Interval cannot be negative.[PrecollectGenericType] generalinfo setting string2'
            return -1
         End
         Else
         Begin
            select @ldec_minshiftpay = IsNull(mpp_avgperiodpay,0) from manpowerprofile where mpp_id = @ps_asgn_id

            insert into #tripsbyshift
            select b.lgh_number,min(b.lgh_startdate),0
            from paydetail a inner join legheader b on a.lgh_number = b.lgh_number
            where a.pyh_number = @pl_pyhnumber and a.lgh_number > 0
            group by b.lgh_number

            select @li_ctr = 0

            While 1 = 1
            Begin
               select @ldt_startdate = min(lghstartdate) from #tripsbyshift where shiftnum = 0
               If @ldt_startdate is null
                  break
               select @li_ctr = @li_ctr + 1
               update #tripsbyshift set shiftnum = @li_ctr where shiftnum = 0 and lghstartdate between @ldt_startdate and dateadd(hh,@ldec_shifthrs,@ldt_startdate)
            End

            select @li_ctr = 0
            --select * from #tripsbyshift
            While 1 = 1
            Begin
               select @li_ctr = min(shiftnum)  from #tripsbyshift where shiftnum > @li_ctr
               If @li_ctr is null
                  break

   --          select @li_ctr
   --          select lghnum from #tripsbyshift where shiftnum = @li_ctr
               select @ldec_shiftpay = sum(pyd_amount) from paydetail where asgn_type = @ps_asgn_type and asgn_id =@ps_asgn_id and
                  lgh_number in (select lghnum from #tripsbyshift where shiftnum = @li_ctr)

               select @ldt_shiftstartdate = min(lghstartdate) from #tripsbyshift where shiftnum = @li_ctr
               select @lgh = min(lghnum) from #tripsbyshift where lghstartdate = @ldt_shiftstartdate and shiftnum = @li_ctr
               select @mov = mov_number from legheader where lgh_number = @lgh
               Select @pyd_transdate = @ldt_shiftstartdate

               If @ldec_shiftpay < @ldec_minshiftpay
               Begin

                  SELECT @quantity = 1

                  Select @asgn_type = @ps_asgn_type
                  Select @asgn_id = @ps_asgn_id
                  SELECT @asgn_number = 0
                  SELECT @payto = mpp_payto from manpowerprofile where mpp_id = @ps_asgn_id
                  SELECT @PayType = @ls_paytype


                  SELECT  @pyt_description = ISNULL(pyt_description,''),
                        @pyt_rateunit = ISNULL(pyt_rateunit,''),
                        @pyt_unit = ISNULL(pyt_unit,''),
                        @pyt_pretax = ISNULL(pyt_pretax,''),
                        @pr_glnum = ISNULL(pyt_pr_glnum,''),
                        @ap_glnum = ISNULL(pyt_ap_glnum,''),
                        @spyt_minus = ISNULL(pyt_minus,'')
                  FROM  paytype
                  WHERE    pyt_itemcode = @PayType


                  SELECT @pyt_minus = 1   -- default to 1
                  IF @spyt_minus = 'Y'
                     SELECT @pyt_minus = -1



                  -- Get the paydetail sequence number
                  SELECT @pyd_sequence = ISNULL(MAX(pyd_sequence),0) + 1
                  FROM paydetail
                  WHERE pyh_number = @pl_pyhnumber


                  select @ps_payto = mpp_payto,@actg_type = mpp_actg_type,
                  @pdec_rate=mpp_avghourlypay  from manpowerprofile where mpp_id = @asgn_id

                  select @pdec_rate = @ldec_minshiftpay - @ldec_shiftpay

                  select @pdec_amount = @Quantity * @pdec_rate * @pyt_minus

                  -- Get the appropriate ap/pr gl number
                  SELECT  @glnum = ''
                  IF @actg_type = 'A'
                     SET @glnum = @ap_glnum
                  ELSE IF @actg_type = 'P'
                     SET @glnum = @pr_glnum



                  -- Get the next pyd_number from the systemnumber table
                  EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''

                  --TODO change lgh_number , workdate

                  INSERT INTO paydetail
                        (pyd_number,
                        pyh_number,
                        lgh_number,
                        asgn_number,
                        asgn_type,     --5

                        asgn_id,
                        ivd_number,
                        pyd_prorap,
                        pyd_payto,
                        pyt_itemcode,  --10

                        mov_number,
                        pyd_description,
                        pyd_quantity,
                        pyd_rateunit,
                        pyd_unit,      --15

                        pyd_rate,
                        pyd_amount,
                        pyd_pretax,
                        pyd_glnum,
                        pyd_currency,  --20

                        pyd_status,
                        pyh_payperiod,
                        pyd_workperiod,
                        lgh_startpoint,
                        lgh_startcity, --25

                        lgh_endpoint,
                        lgh_endcity,
                        ivd_payrevenue,
                        pyd_revenueratio,
                        pyd_lessrevenue,  --30

                        pyd_payrevenue,
                        pyd_transdate,
                        pyd_minus,
                        pyd_sequence,
                        std_number,       --35

                        pyd_loadstate,
                        pyd_xrefnumber,
                        ord_hdrnumber,
                        pyt_fee1,
                        pyt_fee2,      --40

                        pyd_grossamount,
                        pyd_adj_flag,
                        pyd_updatedby,
                        pyd_updatedon,
                        pyd_ivh_hdrnumber,   --45
                        psd_id)
                  VALUES (@pyd_number,
                        @pl_pyhnumber,
                        @lgh,
                        @asgn_number,
                        @asgn_type,    --5

                        @asgn_id,
                        0,  --ivd_number
                        @actg_type,
                        @payto,
                        @PayType,      --10

                        @mov,
                        @pyt_description,
                        @Quantity,
                        @pyt_rateunit,
                        @pyt_unit,     --15

                        @pdec_rate, --pyt_rate,
                        @pdec_amount, --pyt_amount
                        @pyt_pretax,
                        @glnum,
                        @currency,     --20

                        'PND', --pyd_status
                        @pdt_payperiod, --pyh_payperiod
                        @pdt_payperiod, --pyh_workperiod
                        @lgh_startpoint,
                        @lgh_startcity,      --25

                        @lgh_endpoint,
                        @lgh_endcity,
                        0, --ivd_payrevenue
                        0, --pyd_revenueratio
                        0, --pyd_lessrevenue --30

                        0, --pyd_payrevenue
                        @pyd_transdate, --pyd_transdate
                        @pyt_minus,
                        @pyd_sequence,
                        0, --std_number         --35

                        'NA', --pyd_loadstate
                        0, --pyd_xrefnumber
                        @ordhdr,
                        0, --pyt_fee1
                        0, --pyt_fee2        --40

                        0, --pyd_grossamount
                        'N', --pyd_adj_flag
                        @tmwuser, --pyd_updatedby
                        GETDATE(), --pyd_updatedon
                        0, --pyd_ivh_hdrnumber     --45
                        @psd_id )


               End

            End

            --BEGIN PTS 63193 SPN
            --Return 1
            --END PTS 63193 SPN

   --       select * from #tripsbyshift
         End
      End
   END
--BEGIN PTS 63193 SPN
--ELSE
--   /*
--   *  PTS 43873 - DJM - Added option for Driver Weekly Minimum pay option.
--   */
--   If @ls_string1 = 'DRVEligWeeklyMinPay'
IF CHARINDEX(',DRVEligWeeklyMinPay,', @ls_string1) > 0
--END PTS 63193 SPN
      Begin
         --BEGIN PTS 63193 SPN
         --exec settlement_precollect_process_DRVMIN @pl_pyhnumber, @ps_asgn_type ,@ps_asgn_id , @pdt_payperiod , @psd_id , @ps_returnmsg OUT
         --Return 1
         exec @RetVal = settlement_precollect_process_DRVMIN @pl_pyhnumber, @ps_asgn_type ,@ps_asgn_id , @pdt_payperiod , @psd_id , @ls_msg OUT
         If IsNull(@RetVal,0) < 0
            BEGIN
               SELECT @ps_returnmsg = @ls_msg
               Return @RetVal
            END
         --END PTS 63193 SPN
      End
--BEGIN PTS 63193 SPN
--   else
--      BEGIN
--         select @ps_returnmsg = 'No Generic Precollect process has been configured.Review your [PrecollectGenericType] general info setting'
--         Return -1
--      END
--END PTS 63193 SPN
--BEGIN PTS 63193 SPN
IF CHARINDEX(',GuaranteedPay,', @ls_string1) > 0
   BEGIN
      EXEC @RetVal = guaranteedpay_final_settltment_sp @pl_pyhnumber, @ls_msg OUT
      If IsNull(@RetVal,0) < 0
         BEGIN
            SELECT @ps_returnmsg = @ls_msg
            Return @RetVal
         END
   END
--END PTS 63193 SPN
--BEGIN vjh 73004
IF CHARINDEX(',MinWage,', @ls_string1) > 0
   BEGIN
      EXEC @RetVal = MinWage_final_settlement_sp @pl_pyhnumber, @ls_msg OUT
      If IsNull(@RetVal,0) < 0
         BEGIN
            SELECT @ps_returnmsg = @ls_msg
            Return @RetVal
         END
   END
--END vjh 73004

--BEGIN PTS 75771 SPN
IF CHARINDEX(',CALREV_DriverHr_OTHrs,', @ls_string1) > 0
   BEGIN
      EXEC @RetVal = CALREV_DriverHr_OTHrs_BlackHorse_SP @pl_pyhnumber, @ps_asgn_type, @ps_asgn_id, @pdt_payperiod, @psd_id, @ls_msg OUT
      If IsNull(@RetVal,0) < 0
         BEGIN
            SELECT @ps_returnmsg = @ls_msg
            Return @RetVal
         END
   END
--END PTS 75771 SPN

--BEGIN PTS 90961 SPN
IF CHARINDEX(',StatutoryHolidayPay,', @ls_string1) > 0
   BEGIN
      EXEC @RetVal = statutoryholidaypay_final_settlement_sp @pl_pyhnumber, @ls_msg OUT
      If IsNull(@RetVal,0) < 0
         BEGIN
            SELECT @ps_returnmsg = @ls_msg
            Return @RetVal
         END
   END
--END PTS 90961 SPN

--BEGIN PTS 63193 SPN
IF @ps_returnmsg IS NULL OR @ps_returnmsg = ''
BEGIN
   SELECT @ps_returnmsg = 'Precollect processed successfully for Resource:' + @ps_asgn_id
   RETURN 1
END
--END PTS 63193 SPN

GO
GRANT EXECUTE ON  [dbo].[settlement_precollect_process_generic] TO [public]
GO
