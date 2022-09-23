SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_tar_gettariffkeys_sp]
   @tarnum        int,
   @billdate      datetime,
   @billto        char(8),
   @ordby         char(8),
   @cmptype1      char(6),
   @cmptype2      char(6),
   @trltype1      char(6),
   @trltype2      char(6),
   @trltype3      char(6),
   @trltype4      char(6),
   @revtype1      char(6),
   @revtype2      char(6),
   @revtype3      char(6),
   @revtype4      char(6),
   @cmdcode    char(8),
   @cmdclass      char(8),
   @originpoint   char(8),
   @origincity    int,
   @originzip     char(10),
   @origincounty  char(3),
   @originstate   char(6),
   @destpoint     char(8),
   @destcity      int,
   @destzip    char(10),
   @destcounty    char(3),
   @deststate     char(6),
   @miles         int,
   @distunit      char(6),
   @odmiles    int,
   @odunit        char(6),
   @stops         int,
   @length        money,
   @width         money,
   @height        money,
   @company    char(8),
   @carrier    char(8),
   @triptype      char(6),
   @loadstat      char(6),
   @team       char(6),
   @cartype    char(6),
   @drvtype1      char(6),
   @drvtype2      char(6),
   @drvtype3      char(6),
   @drvtype4      char(6),
   @trctype1      char(6),
   @trctype2      char(6),
   @trctype3      char(6),
   @trctype4      char(6),
   @itemcode      char(6),
   @stoptype      char(6),
   @delays        char(6),
   @carryins1     int,
   @carryins2     int,
   @ooamileage    int,
   @ooastop    int ,
   @retrieveby    char(1), --'B' billing rates only ,'S' settlement Rates only, anything else All Rates
   @terms         char(6),
   @mastercompany char(8),
   @ord_hdrnumber int, --14820 pass the order number from billing , settlements will pass in zero. --50599 NOTE Settlements now passes ord_hdrnumber
   @origin_servicecenter   varchar(6),
   @origin_serviceregion   varchar(6),
   @dest_servicecenter     varchar(6),
   @dest_serviceregion     varchar(6),
   @lghtype2            varchar(6),    --27135 JD added support for type2-4
   @lghtype3            varchar(6),    --27135 JD added support for type2-4
   @lghtype4            varchar(6),    --27135 JD added support for type2-4
   @p_lghnumber         int,        --30002
   @thirdparty          char(8),    -- MRH 31225 Third party
   @thirdpartytype         char(12),      -- MRH 31225 Third party
   @segments            int,
   @billto_othertype1      varchar(6),    -- vjh 32868
   @billto_othertype2      varchar(6),    -- vjh 32868
   @masterordernumber      varchar(12),   -- vjh 33160
   @driver              varchar(8),    -- vjh 33438
   @tractor          varchar(8),    -- vjh 33438
   @trailer          varchar(8),    -- vjh 33438
   @drv_payto           varchar(12),   -- vjh 33438
   @trc_owner           varchar(12),   -- vjh 33438
   @trl_owner           varchar(12),   -- vjh 33438
   @car_payto           varchar(12),   -- vjh 33438
   @mpp_terminal        varchar(6),
   @trc_terminal        varchar(6),
   @trl_terminal        varchar(6),
   @primary_driver         char(1),
   @svcdays          int,        --46113 pmill
   @route               varchar(15),   --50169, 47139 re-code of 38077
   @trl_company         varchar(6),
   @trl_fleet           varchar(6),
   @trl_division        varchar(6),
   @trc_company         varchar(6),
   @trc_fleet           varchar(6),
   @trc_division        varchar(6),
   @mpp_company         varchar(6),
   @mpp_fleet           varchar(6),
   @mpp_division        varchar(6),
   @mpp_domicile        varchar(6),
   @mpp_teamleader         varchar(6),
   @pallet_type         varchar(6),
   @pallet_count        int,
   @trk_ratemode        varchar(6),    -- 11/18/2011 NQIAO PTS 58978
   @trk_servicelevel    varchar(6),    -- 11/18/2011 NQIAO PTS 58978
   @mpp_grandfather_date   datetime,      -- 62954
   @trc_grandfather_date   datetime,      -- 62954
   @TourAware           CHAR(1),    -- PTS65914 SPN
   @mpp_branch          varchar(12),   -- vjh 63018
   @trc_branch          varchar(12),   -- vjh 63018
   @trl_branch          varchar(12),   -- vjh 63018
   @car_branch          varchar(12)    -- vjh 63018
   ,@TKLoadReq          CHAR(1)        -- PTS 69449
as

/**
 *
 * NAME:
 * dbo.d_tar_gettariffkeys_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure to get rates from the tarrif engine.
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * DPETE PTS12047 when multiple indexes apply on a secondary charge the rate pulls multiple times.  Added
 *    AND trk_number = (Select min(trk_number) FROM tariffkey c
 *    WHERE c.tar_number = t.tar_number)
 *  to retrieve for secondary charges
 * DPETE 16010 Third attempt at eliminating duplicate tariff keys for secondary rates. Pull
 *    out code int the proc and try to handle in the application (if there are multiple
 *    indexes on a secondary rate whihc differ only by trip type or region, candidates are
 *    eliminated here with Delete code below).
 *DPETE 16479 In order tor ate empty moves (truly empty) nned to change the match on load
 *   status so ANY means ANY
 *DPETE 27842 billing tariff for loaded miles not pulling
 *LOR 27446 add minvariance, maxvariance
 *PTS 26793 (recode 20297) - DJM - Add the Localization setting of Origin/Desitnation service_center and service_region to the
 * tariffkey parameters.
 *PTS 30002 DPETE pass lgh_number  in order to do route rating for settlements (passed by settlements only)
 *PTS 30519 DPETE Do not match route for route rating if there are more than one order on the move or leg
 *PTS 31225 MRH Third party support
 *LOR PTS# 31558  add segment
 *PTS 32868 vjh add billtotype1&2
 *PTS 33160 vjh add masterordernumber
 *PTS 33438 vjh add drv,trc,trl and paytos for drv,trc,trl and car
 * LOR   PTS# 33990  add drv, trc, trl terminal
 *12/21/06 - PTS35568 - jg - add condition to "insert into #stops
 *   select stp_mfh_sequence,cmp_id,stp_city,stp_zipcode from stops where ord_hdrnumber = @ord_hdrnumber"
 *        to avoid occasional slowdown.
 * 3/2/7 In testing 34510 (checked in with 34628 found code below for tariffs with routes causes primary key error on #stops
 *      table if the current trip is cross docked.  JD agrees that safest thing to do short term is not process
 * tariffs with routes if the current trip is cross docked.
 * 4/13/07 36979 DPETE check in of PTS turned off fix for route rating cross docked trips
 *   4/25 JGuo asks to add a small performance change
 * LOR   PTS# 37918  add primary driver
 * vjh   PTS# 37595  add stop_othertype1/2
 * emk  PTS# 38973  add trk_index_factor
 * 11/19/2007 PTS 38811 JDS:  mod 4 cols from INT  to Dec(19,4)
 * LOR   PTS# 33652  add trk_usefor_billable
 * PTS46113 pmill add carrier min/max service days
 * MRH 50169 Recode of 47139 which is a recode of 38077
 * SGB PTS 50599 Settlements passing order number need to change route logic to use @p_lghnumber = 0 in addition ord_hdrnumber >0
 * DPETE 53341 sequenced secondary charges are in the tariff accessorial table as a trk_number. Add another index to the
 *     secondary and the sequence does nto work if the second index is used to select the secondary
 * LOR   PTS# 54602  trl/trc/drv company, fleet, division; drv teamleader, domicile
 * MTC PTS# 57484 add nolocks throughout to help alleviate deadlocks at certain customers.
 * LOR   PTS# 56807  pallettype, palletcount
 * NQIAO PTS# 58978 add 2 new arguments (@trk_ratemode and @trk_servicelevel) and include them in WHERE clauses where needed
 * NQIAO PTS# 62954 add 2 new inputs (mpp_grandfather_date, trc_grandfather_date)
 * PTS65914 SPN - added @TourAware
 * NQIAO PTS# 63181
 * vjh pts63018 add branches
 *  * PTS69449:  Recognize LoadRequirement Billing Tariff Restrictions
 * PTS88910 SPN - Moving TourAware field into TariffKey from TariffHeaderStl
 * PTS93857 SPN - PrivateRestriction SHOULD BE NULL

 */
 --PTS 62251 NLOKE changes from Mindy to enhance performance

Set nocount on
set transaction isolation level read uncommitted
--end 62251
declare  @trknumber int,@matchloadstat varchar(3),
   @tcarryins1 int,
   @tcarryins2 int,
   @tooamileage int,
   @tooastop int ,
      @rth_id int, @rtd_id int, @stp_mfh int ,@ll_del int,--14820 JD
      @ll_ordstops int ,@ll_rtstops int,--14820 JD
      @cmp_id varchar(8),@city int , @zip varchar(10), --14820 JD
      @stp_cmp_id varchar(8),@stp_city int , @stp_zip varchar(10) --14820 JD
   ,@v_PayRouteTYpe varchar(30)  --30002
   ,@v_movnumber int
    ,@v_tripiscrossdocked char(1) --34510
    ,@rowcount int            -- 62954


/* 36979 DPETE moved from below and change sequence to identity */
create table #stops (stp_mfh_sequence int identity not null primary key clustered,
   cmp_id varchar(8) null,
   stp_city int null,
   stp_zipcode varchar(10) null)



IF @carryins1 > 0
   SELECT @tcarryins1 = 1
IF @carryins2 > 0
   SELECT @tcarryins2 = 1
IF @ooamileage > 0
   SELECT @tooamileage = 1
IF @ooastop > 0
   SELECT @tooastop = 1

IF ISNULL(@TKLoadReq, 'N') <> 'Y' Begin select @TKLoadReq = 'N' end      -- PTS 69449

/*
if @loadstat = 'LD'
   select @matchloadstat = 'UNK'
else
   select @matchloadstat = @loadstat
*/
Select @loadstat = IsNull(@loadstat,'UNK')
/* PTS 9554 4/30/01 - Added taa_seq to allow users to control the order Accessorial charges appear
   on an invoice.  No chages made to Settlements.        */

--PTS 26793 (recode 22600) - DJM
select @origin_servicecenter = isnull(@origin_servicecenter,'UNK')
select @origin_serviceregion = isnull(@origin_serviceregion,'UNK')
select @dest_servicecenter = isnull(@dest_servicecenter,'UNK')
select @dest_serviceregion = isnull(@dest_serviceregion,'UNK')

-- 27135 JD
   if @lghtype2 is null or @lghtype2 = ''
      select @lghtype2 = 'UNK'
   if @lghtype3 is null or @lghtype3 = ''
      select @lghtype3 = 'UNK'
   if @lghtype4 is null or @lghtype4 = ''
      select @lghtype4 = 'UNK'
-- end 27135 JD
/* 36979
create table #stops (stp_mfh_sequence int not null primary key clustered,
   cmp_id varchar(8) null,
   stp_city int null,
   stp_zipcode varchar(10) null)
*/

select @svcdays = isnull(@svcdays, 0)  --46113 pmill

-- LOR PTS# 56805
If @pallet_type is null or @pallet_type = ''
   select @pallet_type = 'UNK'
select @pallet_count = IsNull(@pallet_count, 0)
-- LOR

-- 11/18/2011 NQIAO PTS 58978 <START>
IF @trk_ratemode IS NULL OR @trk_ratemode = ''
   SELECT @trk_ratemode = 'UNK'

IF @trk_servicelevel IS NULL OR @trk_servicelevel = ''
   SELECT @trk_servicelevel = 'UNK'
-- 11/18/2011 NQIAO PTS 58978 <END>

--BEGIN PTS 65914 SPN
IF @TourAware IS NULL OR @TourAware = ''
   SELECT @TourAware = 'N'
--END PTS 65914 SPN


--create table #temp (trk_number int not null , --46413 changed to not null
create table #temp (temp_ident int identity(1,1),  -- 69449 add identity col
   trk_number int not null , --46413 changed to not null
   tar_number int not null, -- 46413 changed to not null
   trk_billto varchar(8) null,
   trk_orderedby varchar(8) null,
   cmp_othertype1 varchar(6) null,
   cmp_othertype2 varchar(6) null,
   cmd_code varchar(8) null,
   cmd_class varchar(8) null,
   trl_type1 varchar(6) null,
   trl_type2 varchar(6) null,
   trl_type3 varchar(6) null,
   trl_type4 varchar(6) null,
   trk_revtype1 varchar(6) null,
   trk_revtype2 varchar(6) null,
   trk_revtype3 varchar(6) null,
   trk_revtype4 varchar(6) null,
   trk_originpoint varchar(8) null,
   trk_origincity int null,
   trk_originzip varchar(10) null,
   trk_origincounty varchar(3) null,
   trk_originstate varchar(6) null,
   trk_destpoint varchar(8) null,
   trk_destcity int null,
   trk_destzip varchar(10) null,
   trk_destcounty varchar(3) null,
   trk_deststate varchar(6) null,
   trk_duplicateseq int null,
   trk_company varchar(8) null,
   trk_carrier varchar(8) null,
   trk_lghtype1 varchar(6) null,
   trk_load varchar(6) null,
   trk_team varchar(6) null,
   trk_boardcarrier varchar(6) null,
   trk_minmiles int null,
   trk_maxmiles int null,
   trk_distunit varchar(6) null,
   trk_minweight decimal(19,4) null,      -- PTS 38811
   --trk_minweight int null,
   trk_maxweight decimal(19,4) null,      -- PTS 38811
   --trk_maxweight int null,
   trk_wgtunit varchar(6) null,
   trk_minpieces int null,
   trk_maxpieces int null,
   trk_countunit varchar(6) null,
   trk_minvolume decimal(19,4) null,      -- PTS 38811
   --trk_minvolume int null,
   trk_maxvolume decimal(19,4) null,      -- PTS 38811
   --trk_maxvolume int null,
   trk_volunit varchar(6) null,
   trk_minodmiles int null,
   trk_maxodmiles int null,
   trk_odunit varchar(6) null,
   mpp_type1 varchar(6) null,
   mpp_type2 varchar(6) null,
   mpp_type3 varchar(6) null,
   mpp_type4 varchar(6) null,
   trc_type1 varchar(6) null,
   trc_type2 varchar(6) null,
   trc_type3 varchar(6) null,
   trc_type4 varchar(6) null,
   cht_itemcode varchar(6) null,
   trk_stoptype varchar(6) null,
   trk_delays varchar(6) null,
   trk_carryins1 int null,
   trk_carryins2 int null,
   trk_ooamileage int null,
   trk_ooastop int null,
   trk_minmaxmiletype tinyint null,
   trk_terms varchar(6) null,
   trk_triptype_or_region char(1) null,
   trk_tt_or_oregion varchar(10) null,
   trk_dregion varchar(10) null,
   cmp_mastercompany varchar(8) null,
   taa_seq int null,
-- PTS 22817 -- BL (start)
-- trk_mileagetable char(1) null,
   trk_mileagetable char(2) null,
-- PTS 22817 -- BL (end)
   trk_fueltableid char(8) null,
   trk_minrevpermile money null,
   trk_maxrevpermile money null,
   trk_stp_event varchar(6) null,
   rth_id int null,  --14820 JD
   trk_minvariance      money null,
   trk_maxvariance      money null,
   trk_originsvccenter  varchar(6) null,
   trk_originsvcregion  varchar(6) null,
   trk_destsvccenter varchar(6) null,
   trk_destsvcregion varchar(6) null,
   trk_lghtype2      varchar(6), --27135 JD
   trk_lghtype3      varchar(6), --27135 JD
   trk_lghtype4      varchar(6), --27135 JD
   trk_thirdparty    varchar(8) null,  --MRH 31225 Third party
   trk_thirdpartytype   varchar(12) null, --MRH 31225 Third party
   trk_minsegments      int null,
   trk_maxsegments      int null,
   billto_othertype1 varchar(6) null,  --vjh 32868
   billto_othertype2 varchar(6) null,  --vjh 32868
   masterordernumber varchar(12) null, --vjh 33160
   driver         varchar(8) null,  --vjh 33438
   tractor        varchar(8) null,  --vjh 33438
   trailer        varchar(8) null,  --vjh 33438
   drv_payto      varchar(12) null, --vjh 33438
   trc_owner      varchar(12) null, --vjh 33438
   trl_owner      varchar(12) null, --vjh 33438
   car_payto      varchar(12) null, --vjh 33438
   mpp_terminal   varchar(6)  null,
   trc_terminal   varchar(6)  null,
   trl_terminal   varchar(6)  null,
   trk_primary_driver   char(1) null,
   stop_othertype1   varchar(6)  null, --vjh 37595
   stop_othertype2   varchar(6)  null, --vjh 37595
   trk_index_factor decimal(19,6) null,   --emk 38973
   trk_usefor_billable  int   null,
   trk_mincarriersvcdays int null,     --46113 pmill
   trk_maxcarriersvcdays int null,     --46113 pmill
   trk_route varchar(15) null, --- PTS 50169, 47139 re-code of 38077,
   trl_company    varchar(6) null,
   trl_fleet      varchar(6) null,
   trl_division   varchar(6) null,
   trc_company    varchar(6) null,
   trc_fleet      varchar(6) null,
   trc_division   varchar(6) null,
   mpp_company    varchar(6) null,
   mpp_fleet      varchar(6) null,
   mpp_division   varchar(6) null,
   mpp_domicile   varchar(6) null,
   mpp_teamleader varchar(6) null,
   trk_pallet_type      varchar(6) null,
   trk_pallet_count  int null,
   trk_ratemode   varchar(6) null,  -- 11/18/2011 NQIAO PTS 58978
   trk_servicelevel  varchar(6) null,  -- 11/18/2011 NQIAO PTS 58978
   trk_mpp_grandfatherfromdate   datetime null, -- 62954
   trk_mpp_grandfathertodate  datetime null, -- 62954
   trk_trc_grandfatherfromdate   datetime null, -- 62954
   trk_trc_grandfathertodate  datetime null,  -- 62954)
   tar_orderstoapply int      null,    -- 02/15/2013 NQIAO PTS 63181
   tar_ordersremaining  int      null     -- 02/15/2013 NQIAO PTS 63181
   )
create clustered index dk_temp_trk_number on #temp(trk_number)

-- Get secondary key/s for billing
if @tarnum > 0
   Begin
      insert into #temp(trk_number,tar_number)
      select t.trk_number,
         t.tar_number
       from tariffkey t with (nolock)
      where
      t.trk_startdate <= @billdate AND
      t.trk_enddate >= @billdate AND
      t.trk_minstops <= @stops AND
      t.trk_maxstops >= @stops AND
      t.trk_minlength <= @length AND
      t.trk_maxlength >= @length AND
      t.trk_minwidth <= @width AND
      t.trk_maxwidth >= @width AND
      t.trk_minheight <= @height AND
      t.trk_maxheight >= @height AND
      isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
      isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
      t.trk_orderedby in (@ordby, 'UNKNOWN') AND
      t.cmp_othertype1 in (@cmptype1, 'UNK') AND
      t.cmp_othertype2 in (@cmptype2, 'UNK') AND
      t.cmd_code in (@cmdcode, 'UNKNOWN') AND
      t.cmd_class in (@cmdclass, 'UNKNOWN') AND
      t.trl_type1 in (@trltype1, 'UNK') AND
      t.trl_type2 in (@trltype2, 'UNK') AND
      t.trl_type3 in (@trltype3, 'UNK') AND
      t.trl_type4 in (@trltype4, 'UNK') AND
      t.trk_revtype1 in (@revtype1, 'UNK') AND
      t.trk_revtype2 in (@revtype2, 'UNK') AND
      t.trk_revtype3 in (@revtype3, 'UNK') AND
      t.trk_revtype4 in (@revtype4, 'UNK') AND
      t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
      t.trk_origincity in (@origincity, 0 ) AND
      t.trk_originzip in (@originzip, 'UNKNOWN') AND
      t.trk_origincounty in (@origincounty, 'UNK') AND
      t.trk_originstate in (@originstate, 'XX') AND
      t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
      t.trk_destcity in (@destcity, 0) AND
      t.trk_destzip in (@destzip, 'UNKNOWN') AND
      t.trk_destcounty in (@destcounty, 'UNK') AND
      t.trk_deststate in (@deststate, 'XX') AND
      t.trk_primary <> 'Y' AND
      t.trk_company in (@company, 'UNK') AND
      t.trk_carrier in (@carrier, 'UNKNOWN') AND
      t.trk_lghtype1 in (@triptype, 'UNK') AND
      t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
      t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
      t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
      --t.trk_load in (@loadstat, @matchloadstat) AND
      t.trk_load in (@loadstat, 'UNK') AND
      t.trk_team in (@team, 'UNK') AND
      t.trk_boardcarrier in (@cartype, 'UNK') AND
      t.tar_number in (select b.tar_number
            from  tariffkey b  with (nolock)
            where    trk_number in
               (select a.trk_number
                from    tariffaccessorial a with (nolock)
                where   a.tar_number = @tarnum)) AND
      IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
      IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
      IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
      IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
      IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
      IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
      IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
      IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
      IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
      ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
      ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
      ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
      ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
      ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
      ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
      ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK') and
      t.cmp_mastercompany = @mastercompany AND
      t.trk_billto = @billto
      AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
      AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
      AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
      AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
--    AND IsNull(t.trk_thirdparty, 'UNKNOWN') in (@thirdparty, 'UNKNOWN')
--    AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN')
      -- PTS 14932 - DJM - Removed the commented SQL
      --AND t.trk_number = (Select min(trk_number) FROM tariffkey c
      -- WHERE c.tar_number = t.tar_number)
      AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
      AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
      AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
      AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
      and IsNull(t.trk_pallet_type, 'UNK') in (@pallet_type, 'UNK')
      AND IsNull(t.trk_pallet_count, 0) in (@pallet_count, 0)
      AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
      AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
      AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
      AND PrivateRestriction IS NULL --PTS 93857 SPN
UNION
      select t.trk_number,
         t.tar_number
       from tariffkey t with (nolock)
      where
      t.trk_startdate <= @billdate AND
      t.trk_enddate >= @billdate AND
      t.trk_minstops <= @stops AND
      t.trk_maxstops >= @stops AND
      t.trk_minlength <= @length AND
      t.trk_maxlength >= @length AND
      t.trk_minwidth <= @width AND
      t.trk_maxwidth >= @width AND
      t.trk_minheight <= @height AND
      t.trk_maxheight >= @height AND
      isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
      isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
      t.trk_orderedby in (@ordby, 'UNKNOWN') AND
      t.cmp_othertype1 in (@cmptype1, 'UNK') AND
      t.cmp_othertype2 in (@cmptype2, 'UNK') AND
      t.cmd_code in (@cmdcode, 'UNKNOWN') AND
      t.cmd_class in (@cmdclass, 'UNKNOWN') AND
      t.trl_type1 in (@trltype1, 'UNK') AND
      t.trl_type2 in (@trltype2, 'UNK') AND
      t.trl_type3 in (@trltype3, 'UNK') AND
      t.trl_type4 in (@trltype4, 'UNK') AND
      t.trk_revtype1 in (@revtype1, 'UNK') AND
      t.trk_revtype2 in (@revtype2, 'UNK') AND
      t.trk_revtype3 in (@revtype3, 'UNK') AND
      t.trk_revtype4 in (@revtype4, 'UNK') AND
      t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
      t.trk_origincity in (@origincity, 0 ) AND
      t.trk_originzip in (@originzip, 'UNKNOWN') AND
      t.trk_origincounty in (@origincounty, 'UNK') AND
      t.trk_originstate in (@originstate, 'XX') AND
      t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
      t.trk_destcity in (@destcity, 0) AND
      t.trk_destzip in (@destzip, 'UNKNOWN') AND
      t.trk_destcounty in (@destcounty, 'UNK') AND
      t.trk_deststate in (@deststate, 'XX') AND
      t.trk_primary <> 'Y' AND
      t.trk_company in (@company, 'UNK') AND
      t.trk_carrier in (@carrier, 'UNKNOWN') AND
      t.trk_lghtype1 in (@triptype, 'UNK') AND
      t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
      t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
      t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
      --t.trk_load in (@loadstat, @matchloadstat) AND
      t.trk_load in (@loadstat, 'UNK') AND
      t.trk_team in (@team, 'UNK') AND
      t.trk_boardcarrier in (@cartype, 'UNK') AND
      t.tar_number in (select b.tar_number
            from  tariffkey b  with (nolock)
            where    trk_number in
               (select a.trk_number
                from    tariffaccessorial a with (nolock)
                where   a.tar_number = @tarnum)) AND
      IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
      IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
      IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
      IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
      IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
      IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
      IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
      IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
      IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
      ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
      ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
      ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
      ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
      ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
      ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
      ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK') and
      t.cmp_mastercompany = @mastercompany AND
      t.trk_billto = 'UNKNOWN'
      AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
      AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
      AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
      AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
--    AND IsNull(t.trk_thirdparty, 'UNKNOWN') in (@thirdparty, 'UNKNOWN')
--    AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN')
      AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
      AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
      AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
      and IsNull(t.trk_pallet_type, 'UNK') in (@pallet_type, 'UNK')
      AND IsNull(t.trk_pallet_count, 0) in (@pallet_count, 0)
      AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
      AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
      AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
      AND PrivateRestriction IS NULL --PTS 93857 SPN
UNION
      select t.trk_number,
         t.tar_number
       from tariffkey t with (nolock)
      where
      t.trk_startdate <= @billdate AND
      t.trk_enddate >= @billdate AND
      t.trk_minstops <= @stops AND
      t.trk_maxstops >= @stops AND
      t.trk_minlength <= @length AND
      t.trk_maxlength >= @length AND
      t.trk_minwidth <= @width AND
      t.trk_maxwidth >= @width AND
      t.trk_minheight <= @height AND
      t.trk_maxheight >= @height AND
      isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
      isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
      t.trk_orderedby in (@ordby, 'UNKNOWN') AND
      t.cmp_othertype1 in (@cmptype1, 'UNK') AND
      t.cmp_othertype2 in (@cmptype2, 'UNK') AND
      t.cmd_code in (@cmdcode, 'UNKNOWN') AND
      t.cmd_class in (@cmdclass, 'UNKNOWN') AND
      t.trl_type1 in (@trltype1, 'UNK') AND
      t.trl_type2 in (@trltype2, 'UNK') AND
      t.trl_type3 in (@trltype3, 'UNK') AND
      t.trl_type4 in (@trltype4, 'UNK') AND
      t.trk_revtype1 in (@revtype1, 'UNK') AND
      t.trk_revtype2 in (@revtype2, 'UNK') AND
      t.trk_revtype3 in (@revtype3, 'UNK') AND
      t.trk_revtype4 in (@revtype4, 'UNK') AND
      t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
      t.trk_origincity in (@origincity, 0 ) AND
      t.trk_originzip in (@originzip, 'UNKNOWN') AND
      t.trk_origincounty in (@origincounty, 'UNK') AND
      t.trk_originstate in (@originstate, 'XX') AND
      t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
      t.trk_destcity in (@destcity, 0) AND
      t.trk_destzip in (@destzip, 'UNKNOWN') AND
      t.trk_destcounty in (@destcounty, 'UNK') AND
      t.trk_deststate in (@deststate, 'XX') AND
      t.trk_primary <> 'Y' AND
      t.trk_company in (@company, 'UNK') AND
      t.trk_carrier in (@carrier, 'UNKNOWN') AND
      t.trk_lghtype1 in (@triptype, 'UNK') AND
      t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
      t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
      t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
      --t.trk_load in (@loadstat, @matchloadstat) AND
      t.trk_load in (@loadstat, 'UNK') AND
      t.trk_team in (@team, 'UNK') AND
      t.trk_boardcarrier in (@cartype, 'UNK') AND
      t.tar_number in (select b.tar_number
            from  tariffkey b  with (nolock)
            where    trk_number in
               (select a.trk_number
                from    tariffaccessorial a with (nolock)
                where   a.tar_number = @tarnum)) AND
      IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
      IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
      IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
      IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
      IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
      IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
      IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
      IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
      IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
      ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
      ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
      ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
      ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
      ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
      ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
      ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK') and
      t.cmp_mastercompany = 'UNKNOWN' AND
      t.trk_billto = @billto
      AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
      AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
      AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
      AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
--    AND IsNull(t.trk_thirdparty, 'UNKNOWN') in (@thirdparty, 'UNKNOWN')
--    AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN')
      AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
      AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
      AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
      AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
      and IsNull(t.trk_pallet_type, 'UNK') in (@pallet_type, 'UNK')
      AND IsNull(t.trk_pallet_count, 0) in (@pallet_count, 0)
      AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
      AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
      AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
      AND PrivateRestriction IS NULL --PTS 93857 SPN
UNION

      select t.trk_number,
         t.tar_number
       from tariffkey t with (nolock)
      where
      t.trk_startdate <= @billdate AND
      t.trk_enddate >= @billdate AND
      t.trk_minstops <= @stops AND
      t.trk_maxstops >= @stops AND
      t.trk_minlength <= @length AND
      t.trk_maxlength >= @length AND
      t.trk_minwidth <= @width AND
      t.trk_maxwidth >= @width AND
      t.trk_minheight <= @height AND
      t.trk_maxheight >= @height AND
      isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
      isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
      t.trk_orderedby in (@ordby, 'UNKNOWN') AND
      t.cmp_othertype1 in (@cmptype1, 'UNK') AND
      t.cmp_othertype2 in (@cmptype2, 'UNK') AND
      t.cmd_code in (@cmdcode, 'UNKNOWN') AND
      t.cmd_class in (@cmdclass, 'UNKNOWN') AND
      t.trl_type1 in (@trltype1, 'UNK') AND
      t.trl_type2 in (@trltype2, 'UNK') AND
      t.trl_type3 in (@trltype3, 'UNK') AND
      t.trl_type4 in (@trltype4, 'UNK') AND
      t.trk_revtype1 in (@revtype1, 'UNK') AND
      t.trk_revtype2 in (@revtype2, 'UNK') AND
      t.trk_revtype3 in (@revtype3, 'UNK') AND
      t.trk_revtype4 in (@revtype4, 'UNK') AND
      t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
      t.trk_origincity in (@origincity, 0 ) AND
      t.trk_originzip in (@originzip, 'UNKNOWN') AND
      t.trk_origincounty in (@origincounty, 'UNK') AND
      t.trk_originstate in (@originstate, 'XX') AND
      t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
      t.trk_destcity in (@destcity, 0) AND
      t.trk_destzip in (@destzip, 'UNKNOWN') AND
      t.trk_destcounty in (@destcounty, 'UNK') AND
      t.trk_deststate in (@deststate, 'XX') AND
      t.trk_primary <> 'Y' AND
      t.trk_company in (@company, 'UNK') AND
      t.trk_carrier in (@carrier, 'UNKNOWN') AND
      t.trk_lghtype1 in (@triptype, 'UNK') AND
      t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
      t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
      t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
      --t.trk_load in (@loadstat, @matchloadstat) AND
      t.trk_load in (@loadstat, 'UNK') AND
      t.trk_team in (@team, 'UNK') AND
      t.trk_boardcarrier in (@cartype, 'UNK') AND
      t.tar_number in (select b.tar_number
            from  tariffkey b  with (nolock)
            where    trk_number in
               (select a.trk_number
                from    tariffaccessorial a with (nolock)
                where   a.tar_number = @tarnum)) AND
      IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
      IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
      IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
      IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
      IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
      IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
      IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
      IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
      IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
      ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
      ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
      ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
      ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
      ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
      ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
      ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK') and
      t.cmp_mastercompany = 'UNKNOWN' AND
      t.trk_billto = 'UNKNOWN'
      AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
      AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
      AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
      AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
--    AND IsNull(t.trk_thirdparty, 'UNKNOWN') in (@thirdparty, 'UNKNOWN')
--    AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN')
      AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
      AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
      AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
      AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
      and IsNull(t.trk_pallet_type, 'UNK') in (@pallet_type, 'UNK')
      AND IsNull(t.trk_pallet_count, 0) in (@pallet_count, 0)
      AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
      AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
      AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
      AND PrivateRestriction IS NULL --PTS 93857 SPN
         --          /*   PTS 16010 DPETE Found this also eliminates keys with different candidate trip types
         --              or regions whihc may qualify only after inspection
         --                 PTS 14932 - DJM - Added the following SQL to remove duplicate rows.  Donna
         --                added the above SQL for PTS 12047.  This fixed the problem of duplicate rows
         --                found for the same Rate if the Indexes were not specific enough,  but had the
         --                side affect of preventing any index other than the first from being found. Added the
         --                SQL below to remove any duplicates for pts 12047 and removed the limitation above so that
         --                all the indexes are included in the original search.
         --                Delete from #temp
         --                where exists (select b.* from #temp b
         --                      where #temp.tar_number = b.tar_number
         --                         and b.trk_number <> #temp.trk_number)
         --                   and #temp.trk_number > (select min(trk_number) from #temp c where #temp.tar_number = c.tar_number)
         --             */
      --46413 JD added following update for seq.
/*
      update #temp set taa_seq = (select isNull(a.taa_seq,0)
                            from    tariffaccessorial a
                            where   a.tar_number = @tarnum AND
                              a.trk_number = #temp.trk_number)
*/
/* table with sequence info for secondaryy charge tariffaccessorial has tar_number of line haul and trk_number of secondary */
        Update #temp set taa_seq = isnull( ta.taa_seq,999)  -- if not sequence put them at the bottom
        from #temp tmp
        join tariffheader th  with (nolock) on tmp.tar_number = th.tar_number
        join tariffkey tk  with (nolock) on th.tar_number = tk.tar_number
        join tariffaccessorial ta  with (nolock) on ta.trk_number = tk.trk_number and ta.tar_number = @tarnum
        -- (maybe I dont care if the sequence table linked index is expired) where tk.trk_startdate <= @billdate AND
        --  tk.trk_enddate >= @billdate
   End

-- Get secondary key/s for settlements
else if @tarnum < 0
   begin
   select @tarnum = -@tarnum

   insert into #temp(trk_number,tar_number)
   select t.trk_number,
      t.tar_number
    FROM tariffkey t with (nolock)
    JOIN tariffheaderstl h WITH (nolock) ON t.tar_number = h.tar_number
   WHERE t.trk_startdate <= @billdate AND
   t.trk_enddate >= @billdate AND
   t.trk_minstops <= @stops AND
   t.trk_maxstops >= @stops AND
   t.trk_minlength <= @length AND
   t.trk_maxlength >= @length AND
   t.trk_minwidth <= @width AND
   t.trk_maxwidth >= @width AND
   t.trk_minheight <= @height AND
   t.trk_maxheight >= @height AND
   isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
   isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
   t.trk_billto in (@billto, 'UNKNOWN') AND
   t.trk_orderedby in (@ordby, 'UNKNOWN') AND
   t.cmp_othertype1 in (@cmptype1, 'UNK') AND
   t.cmp_othertype2 in (@cmptype2, 'UNK') AND
   t.cmd_code in (@cmdcode, 'UNKNOWN') AND
   t.cmd_class in (@cmdclass, 'UNKNOWN') AND
   t.trl_type1 in (@trltype1, 'UNK') AND
   t.trl_type2 in (@trltype2, 'UNK') AND
   t.trl_type3 in (@trltype3, 'UNK') AND
   t.trl_type4 in (@trltype4, 'UNK') AND
   t.trk_revtype1 in (@revtype1, 'UNK') AND
   t.trk_revtype2 in (@revtype2, 'UNK') AND
   t.trk_revtype3 in (@revtype3, 'UNK') AND
   t.trk_revtype4 in (@revtype4, 'UNK') AND
   t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
   t.trk_origincity in (@origincity, 0 ) AND
   t.trk_originzip in (@originzip, 'UNKNOWN') AND
   t.trk_origincounty in (@origincounty, 'UNK') AND
   t.trk_originstate in (@originstate, 'XX') AND
   t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
   t.trk_destcity in (@destcity, 0) AND
   t.trk_destzip in (@destzip, 'UNKNOWN') AND
   t.trk_destcounty in (@destcounty, 'UNK') AND
   t.trk_deststate in (@deststate, 'XX') AND
   t.trk_primary = 'N' AND
   t.trk_company in (@company, 'UNK') AND
   t.trk_carrier in (@carrier, 'UNKNOWN') AND
   t.trk_lghtype1 in (@triptype, 'UNK') AND
   t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
   t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
   t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
   --t.trk_load in (@loadstat, @matchloadstat) AND
   t.trk_load in (@loadstat,'UNK') AND
   t.trk_team in (@team, 'UNK') AND
   t.trk_boardcarrier in (@cartype, 'UNK') AND
   t.tar_number in (select b.tar_number
         from  tariffkey b  with (nolock)
         where    trk_number in
            (select a.trk_number
             from    tariffaccessorialstl a with (nolock)
             where   a.tar_number = @tarnum)) AND
   IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
   IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
   IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
   IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
   IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
   IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
   IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
   IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
   IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
   ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
   ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
   ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
   ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
   ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
   ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
   AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
   AND IsNull(t.trk_thirdparty, 'UNKNOWN') in (@thirdparty, 'UNKNOWN')
   --BEGIN PTS 64272 SPN
   --AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN')
   AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN', 'UNK')
   --END PTS 64272 SPN
   AND t.trk_minsegments <= @segments
   AND t.trk_maxsegments >= @segments
   AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
   AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
   AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')AND
   Isnull(t.mpp_id,'UNKNOWN') in (@driver, 'UNKNOWN') --vjh 33438
   AND Isnull(t.trc_number,'UNKNOWN') in (@tractor, 'UNKNOWN')
   AND Isnull(t.trl_number,'UNKNOWN') in (@trailer, 'UNKNOWN')
   AND Isnull(t.mpp_payto,'UNKNOWN') in (@drv_payto, 'UNKNOWN')
   AND Isnull(t.trc_owner,'UNKNOWN') in (@trc_owner, 'UNKNOWN')
   AND Isnull(t.trl_owner,'UNKNOWN') in (@trl_owner, 'UNKNOWN')
   AND Isnull(t.pto_id,'UNKNOWN') in (@car_payto, 'UNKNOWN') AND
   IsNull(t.mpp_terminal,'UNK') in (@mpp_terminal, 'UNK') AND
   IsNull(t.trc_terminal,'UNK') in (@trc_terminal, 'UNK') AND
   IsNull(t.trl_terminal,'UNK') in (@trl_terminal, 'UNK')
   AND   Isnull(t.cmp_mastercompany,'UNKNOWN') in (@mastercompany, 'UNKNOWN') AND
   IsNull(t.trk_primary_driver,'A') in (@primary_driver, 'A')
   AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
   and isnull(t.trk_trl_company, 'UNK') in (@trl_company, 'UNK')
   and   isnull(t.trk_trl_fleet, 'UNK') in (@trl_fleet,  'UNK')
   and   isnull(t.trk_trl_division, 'UNK') in (@trl_division, 'UNK')
   and   isnull(t.trk_trc_company, 'UNK') in (@trc_company,  'UNK')
   and   isnull(t.trk_trc_fleet, 'UNK') in (@trc_fleet,  'UNK')
   and   isnull(t.trk_trc_division, 'UNK') in (@trc_division, 'UNK')
   and   isnull(t.trk_mpp_company, 'UNK') in (@mpp_company,  'UNK')
   and   isnull(t.trk_mpp_fleet, 'UNK') in (@mpp_fleet,  'UNK')
   and   isnull(t.trk_mpp_division, 'UNK') in (@mpp_division, 'UNK')
   and   isnull(t.trk_mpp_domicile, 'UNK') in (@mpp_domicile, 'UNK')
   and   isnull(t.trk_mpp_teamleader, 'UNK') in (@mpp_teamleader, 'UNK')
   AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
      AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')
   AND IsNull((CASE WHEN t.trk_touraware = '' THEN NULL ELSE t.trk_touraware END), 'N') IN (@TourAware,'A') --PTS88910 SPN
      AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
   AND PrivateRestriction IS NULL --PTS 93857 SPN
   --46413 JD added following update for seq.
   update #temp set taa_seq = (select isNull(a.taa_seq,0)
                         from    tariffaccessorialstl a with (nolock)
                         where   a.tar_number = @tarnum AND
                           a.trk_number = #temp.trk_number)

   end

-- Get primary key
else
  if @retrieveby = 'B'
   insert into #temp(trk_number,tar_number)
   select t.trk_number,
      t.tar_number
    FROM tariffkey t with (nolock),tariffheader h with (nolock)
   WHERE t.tar_number = h.tar_number AND
   t.trk_startdate <= @billdate AND
   t.trk_enddate >= @billdate AND
   t.trk_minstops <= @stops AND
   t.trk_maxstops >= @stops AND
   t.trk_minlength <= @length AND
   t.trk_maxlength >= @length AND
   t.trk_minwidth <= @width AND
   t.trk_maxwidth >= @width AND
   t.trk_minheight <= @height AND
   t.trk_maxheight >= @height AND
   isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
   isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
   t.trk_orderedby in (@ordby, 'UNKNOWN') AND
   t.cmp_othertype1 in (@cmptype1, 'UNK') AND
   t.cmp_othertype2 in (@cmptype2, 'UNK') AND
   t.cmd_code in (@cmdcode, 'UNKNOWN') AND
   t.cmd_class in (@cmdclass, 'UNKNOWN') AND
   t.trl_type1 in (@trltype1, 'UNK') AND
   t.trl_type2 in (@trltype2, 'UNK') AND
   t.trl_type3 in (@trltype3, 'UNK') AND
   t.trl_type4 in (@trltype4, 'UNK') AND
   t.trk_revtype1 in (@revtype1, 'UNK') AND
   t.trk_revtype2 in (@revtype2, 'UNK') AND
   t.trk_revtype3 in (@revtype3, 'UNK') AND
   t.trk_revtype4 in (@revtype4, 'UNK') AND
   t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
   t.trk_origincity in (@origincity, 0) AND
   t.trk_originzip in (@originzip, 'UNKNOWN') AND
   t.trk_origincounty in (@origincounty, 'UNK') AND
   t.trk_originstate in (@originstate, 'XX') AND
   t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
   t.trk_destcity in (@destcity, 0) AND
   t.trk_destzip in (@destzip, 'UNKNOWN') AND
   t.trk_destcounty in (@destcounty, 'UNK') AND
   t.trk_deststate in (@deststate, 'XX') AND
   t.trk_primary = 'Y' AND
   t.trk_company in (@company, 'UNK') AND
   t.trk_carrier in (@carrier, 'UNKNOWN') AND
   t.trk_lghtype1 in (@triptype, 'UNK') AND
   t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
   t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
   t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
   --t.trk_load in (@loadstat, @matchloadstat) AND
   t.trk_load in (@loadstat, 'UNK') AND
   t.trk_team in (@team, 'UNK') AND
   t.trk_boardcarrier in (@cartype, 'UNK') AND
   IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
   IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
   IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
   IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
   IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
   IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
   IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
   IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
   IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
   ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
   ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
   ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
   ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
   ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
   ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
   ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK')  and
   t.cmp_mastercompany = @mastercompany AND
   t.trk_billto = @billto
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
   AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
   AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
   AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
   AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
   AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
   and IsNull(t.trk_pallet_type, 'UNK') in (@pallet_type, 'UNK')
   AND IsNull(t.trk_pallet_count, 0) in (@pallet_count, 0)
   AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
   AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
      AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
   AND PrivateRestriction IS NULL --PTS 93857 SPN
UNION
   select t.trk_number,
      t.tar_number
   FROM tariffkey t with (nolock),tariffheader h with (nolock)
   WHERE t.tar_number = h.tar_number AND
   t.trk_startdate <= @billdate AND
   t.trk_enddate >= @billdate AND
   t.trk_minstops <= @stops AND
   t.trk_maxstops >= @stops AND
   t.trk_minlength <= @length AND
   t.trk_maxlength >= @length AND
   t.trk_minwidth <= @width AND
   t.trk_maxwidth >= @width AND
   t.trk_minheight <= @height AND
   t.trk_maxheight >= @height AND
   isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
   isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
   t.trk_orderedby in (@ordby, 'UNKNOWN') AND
   t.cmp_othertype1 in (@cmptype1, 'UNK') AND
   t.cmp_othertype2 in (@cmptype2, 'UNK') AND
   t.cmd_code in (@cmdcode, 'UNKNOWN') AND
   t.cmd_class in (@cmdclass, 'UNKNOWN') AND
   t.trl_type1 in (@trltype1, 'UNK') AND
   t.trl_type2 in (@trltype2, 'UNK') AND
   t.trl_type3 in (@trltype3, 'UNK') AND
   t.trl_type4 in (@trltype4, 'UNK') AND
   t.trk_revtype1 in (@revtype1, 'UNK') AND
   t.trk_revtype2 in (@revtype2, 'UNK') AND
   t.trk_revtype3 in (@revtype3, 'UNK') AND
   t.trk_revtype4 in (@revtype4, 'UNK') AND
   t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
   t.trk_origincity in (@origincity, 0) AND
   t.trk_originzip in (@originzip, 'UNKNOWN') AND
   t.trk_origincounty in (@origincounty, 'UNK') AND
   t.trk_originstate in (@originstate, 'XX') AND
   t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
   t.trk_destcity in (@destcity, 0) AND
   t.trk_destzip in (@destzip, 'UNKNOWN') AND
   t.trk_destcounty in (@destcounty, 'UNK') AND
   t.trk_deststate in (@deststate, 'XX') AND
   t.trk_primary = 'Y' AND
   t.trk_company in (@company, 'UNK') AND
   t.trk_carrier in (@carrier, 'UNKNOWN') AND
   t.trk_lghtype1 in (@triptype, 'UNK') AND
   t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
   t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
   t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
   --t.trk_load in (@loadstat, @matchloadstat) AND
   t.trk_load in (@loadstat, 'UNK') AND
   t.trk_team in (@team, 'UNK') AND
   t.trk_boardcarrier in (@cartype, 'UNK') AND
   IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
   IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
   IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
   IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
   IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
   IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
   IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
   IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
   IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
   ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
   ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
   ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
   ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
   ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
   ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
   ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK')  and
   t.cmp_mastercompany = @mastercompany AND
   t.trk_billto = 'UNKNOWN'
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
   AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
   AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
   AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
   AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
   AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
   and IsNull(t.trk_pallet_type, 'UNK') in (@pallet_type, 'UNK')
   AND IsNull(t.trk_pallet_count, 0) in (@pallet_count, 0)
   AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
   AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
      AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
   AND PrivateRestriction IS NULL --PTS 93857 SPN
UNION
   select t.trk_number,
      t.tar_number
    FROM tariffkey t with (nolock),tariffheader h with (nolock)
   WHERE t.tar_number = h.tar_number AND
   t.trk_startdate <= @billdate AND
   t.trk_enddate >= @billdate AND
   t.trk_minstops <= @stops AND
   t.trk_maxstops >= @stops AND
   t.trk_minlength <= @length AND
   t.trk_maxlength >= @length AND
   t.trk_minwidth <= @width AND
   t.trk_maxwidth >= @width AND
   t.trk_minheight <= @height AND
   t.trk_maxheight >= @height AND
   isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
   isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
   t.trk_orderedby in (@ordby, 'UNKNOWN') AND
   t.cmp_othertype1 in (@cmptype1, 'UNK') AND
   t.cmp_othertype2 in (@cmptype2, 'UNK') AND
   t.cmd_code in (@cmdcode, 'UNKNOWN') AND
   t.cmd_class in (@cmdclass, 'UNKNOWN') AND
   t.trl_type1 in (@trltype1, 'UNK') AND
   t.trl_type2 in (@trltype2, 'UNK') AND
   t.trl_type3 in (@trltype3, 'UNK') AND
   t.trl_type4 in (@trltype4, 'UNK') AND
   t.trk_revtype1 in (@revtype1, 'UNK') AND
   t.trk_revtype2 in (@revtype2, 'UNK') AND
   t.trk_revtype3 in (@revtype3, 'UNK') AND
   t.trk_revtype4 in (@revtype4, 'UNK') AND
   t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
   t.trk_origincity in (@origincity, 0) AND
   t.trk_originzip in (@originzip, 'UNKNOWN') AND
   t.trk_origincounty in (@origincounty, 'UNK') AND
   t.trk_originstate in (@originstate, 'XX') AND
   t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
   t.trk_destcity in (@destcity, 0) AND
   t.trk_destzip in (@destzip, 'UNKNOWN') AND
   t.trk_destcounty in (@destcounty, 'UNK') AND
   t.trk_deststate in (@deststate, 'XX') AND
   t.trk_primary = 'Y' AND
   t.trk_company in (@company, 'UNK') AND
   t.trk_carrier in (@carrier, 'UNKNOWN') AND
   t.trk_lghtype1 in (@triptype, 'UNK') AND
   t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
   t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
   t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
   --t.trk_load in (@loadstat, @matchloadstat) AND
   t.trk_load in (@loadstat, 'UNK') AND
   t.trk_team in (@team, 'UNK') AND
   t.trk_boardcarrier in (@cartype, 'UNK') AND
   IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
   IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
   IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
   IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
   IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
   IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
   IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
   IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
   IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
   ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
   ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
   ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
   ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
   ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
   ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
   ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK')  and
   t.cmp_mastercompany = 'UNKNOWN' AND
   t.trk_billto = @billto
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
   AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
   AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
   AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
   AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
   AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
   and IsNull(t.trk_pallet_type, 'UNK') in (@pallet_type, 'UNK')
   AND IsNull(t.trk_pallet_count, 0) in (@pallet_count, 0)
   AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
   AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
      AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
   AND PrivateRestriction IS NULL --PTS 93857 SPN
UNION
   select t.trk_number,
      t.tar_number
    FROM tariffkey t with (nolock),tariffheader h with (nolock)
   WHERE t.tar_number = h.tar_number AND
   t.trk_startdate <= @billdate AND
   t.trk_enddate >= @billdate AND
   t.trk_minstops <= @stops AND
   t.trk_maxstops >= @stops AND
   t.trk_minlength <= @length AND
   t.trk_maxlength >= @length AND
   t.trk_minwidth <= @width AND
   t.trk_maxwidth >= @width AND
   t.trk_minheight <= @height AND
   t.trk_maxheight >= @height AND
   isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
   isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
   t.trk_orderedby in (@ordby, 'UNKNOWN') AND
   t.cmp_othertype1 in (@cmptype1, 'UNK') AND
   t.cmp_othertype2 in (@cmptype2, 'UNK') AND
   t.cmd_code in (@cmdcode, 'UNKNOWN') AND
   t.cmd_class in (@cmdclass, 'UNKNOWN') AND
   t.trl_type1 in (@trltype1, 'UNK') AND
   t.trl_type2 in (@trltype2, 'UNK') AND
   t.trl_type3 in (@trltype3, 'UNK') AND
   t.trl_type4 in (@trltype4, 'UNK') AND
   t.trk_revtype1 in (@revtype1, 'UNK') AND
   t.trk_revtype2 in (@revtype2, 'UNK') AND
   t.trk_revtype3 in (@revtype3, 'UNK') AND
   t.trk_revtype4 in (@revtype4, 'UNK') AND
   t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
   t.trk_origincity in (@origincity, 0) AND
   t.trk_originzip in (@originzip, 'UNKNOWN') AND
   t.trk_origincounty in (@origincounty, 'UNK') AND
   t.trk_originstate in (@originstate, 'XX') AND
   t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
   t.trk_destcity in (@destcity, 0) AND
   t.trk_destzip in (@destzip, 'UNKNOWN') AND
   t.trk_destcounty in (@destcounty, 'UNK') AND
   t.trk_deststate in (@deststate, 'XX') AND
   t.trk_primary = 'Y' AND
   t.trk_company in (@company, 'UNK') AND
   t.trk_carrier in (@carrier, 'UNKNOWN') AND
   t.trk_lghtype1 in (@triptype, 'UNK') AND
   t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
   t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
   t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
   --t.trk_load in (@loadstat, @matchloadstat) AND
   t.trk_load in (@loadstat, 'UNK') AND
   t.trk_team in (@team, 'UNK') AND
   t.trk_boardcarrier in (@cartype, 'UNK') AND
   IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
   IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
   IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
   IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
   IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
   IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
   IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
   IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
   IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
   ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
   ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
   ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
   ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
   ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
   ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
   ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK')  and
   t.cmp_mastercompany = 'UNKNOWN' AND
   t.trk_billto = 'UNKNOWN'
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
   AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
   AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
   AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
   AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
   AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
   and IsNull(t.trk_pallet_type, 'UNK') in (@pallet_type, 'UNK')
   AND IsNull(t.trk_pallet_count, 0) in (@pallet_count, 0)
   AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
   AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
      AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
      AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
   AND PrivateRestriction IS NULL --PTS 93857 SPN
ELSE IF @retrieveby = 'S' -- Settlements primary key.
   insert into #temp(trk_number,tar_number)
   select t.trk_number,
      t.tar_number
    FROM tariffkey t with (nolock),tariffheaderstl h with (nolock)
   WHERE t.tar_number = h.tar_number AND
   t.trk_startdate <= @billdate AND
   t.trk_enddate >= @billdate AND
   t.trk_minstops <= @stops AND
   t.trk_maxstops >= @stops AND
   t.trk_minlength <= @length AND
   t.trk_maxlength >= @length AND
   t.trk_minwidth <= @width AND
   t.trk_maxwidth >= @width AND
   t.trk_minheight <= @height AND
   t.trk_maxheight >= @height AND
   isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
   isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
   t.trk_billto in (@billto, 'UNKNOWN') AND
   t.trk_orderedby in (@ordby, 'UNKNOWN') AND
   t.cmp_othertype1 in (@cmptype1, 'UNK') AND
   t.cmp_othertype2 in (@cmptype2, 'UNK') AND
   t.cmd_code in (@cmdcode, 'UNKNOWN') AND
   t.cmd_class in (@cmdclass, 'UNKNOWN') AND
   t.trl_type1 in (@trltype1, 'UNK') AND
   t.trl_type2 in (@trltype2, 'UNK') AND
   t.trl_type3 in (@trltype3, 'UNK') AND
   t.trl_type4 in (@trltype4, 'UNK') AND
   t.trk_revtype1 in (@revtype1, 'UNK') AND
   t.trk_revtype2 in (@revtype2, 'UNK') AND
   t.trk_revtype3 in (@revtype3, 'UNK') AND
   t.trk_revtype4 in (@revtype4, 'UNK') AND
   t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
   t.trk_origincity in (@origincity, 0) AND
   t.trk_originzip in (@originzip, 'UNKNOWN') AND
   t.trk_origincounty in (@origincounty, 'UNK') AND
   t.trk_originstate in (@originstate, 'XX') AND
   t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
   t.trk_destcity in (@destcity, 0) AND
   t.trk_destzip in (@destzip, 'UNKNOWN') AND
   t.trk_destcounty in (@destcounty, 'UNK') AND
   t.trk_deststate in (@deststate, 'XX') AND
   t.trk_primary = 'Y' AND
   t.trk_company in (@company, 'UNK') AND
   t.trk_carrier in (@carrier, 'UNKNOWN') AND
   t.trk_lghtype1 in (@triptype, 'UNK') AND
   t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
   t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
   t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
   --t.trk_load in (@loadstat, @matchloadstat) AND
   t.trk_load in (@loadstat, 'UNK') AND
   t.trk_team in (@team, 'UNK') AND
   t.trk_boardcarrier in (@cartype, 'UNK') AND
   IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
   IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
   IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
   IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
   IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
   IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
   IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
   IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
   IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
   ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
   ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
   ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
   ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
   ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
   ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
   AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
   AND IsNull(t.trk_thirdparty, 'UNKNOWN') in (@thirdparty, 'UNKNOWN')
   --BEGIN PTS 64272 SPN
   --AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN')
   AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN', 'UNK')
   --END PTS 64272 SPN
   AND t.trk_minsegments <= @segments
   AND t.trk_maxsegments >= @segments
   AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
   AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
   AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
   AND Isnull(t.mpp_id,'UNKNOWN') in (@driver, 'UNKNOWN') --vjh 33438
   AND Isnull(t.trc_number,'UNKNOWN') in (@tractor, 'UNKNOWN')
   AND Isnull(t.trl_number,'UNKNOWN') in (@trailer, 'UNKNOWN')
   AND Isnull(t.mpp_payto,'UNKNOWN') in (@drv_payto, 'UNKNOWN')
   AND Isnull(t.trc_owner,'UNKNOWN') in (@trc_owner, 'UNKNOWN')
   AND Isnull(t.trl_owner,'UNKNOWN') in (@trl_owner, 'UNKNOWN')
   AND Isnull(t.pto_id,'UNKNOWN') in (@car_payto, 'UNKNOWN') AND
   IsNull(t.mpp_terminal,'UNK') in (@mpp_terminal, 'UNK') AND
   IsNull(t.trc_terminal,'UNK') in (@trc_terminal, 'UNK') AND
   IsNull(t.trl_terminal,'UNK') in (@trl_terminal, 'UNK')
   AND   Isnull(t.cmp_mastercompany,'UNKNOWN') in (@mastercompany, 'UNKNOWN') AND
   IsNull(t.trk_primary_driver,'A') in (@primary_driver, 'A')
   AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
   and isnull(t.trk_trl_company, 'UNK') in (@trl_company, 'UNK')
   and   isnull(t.trk_trl_fleet, 'UNK') in (@trl_fleet,  'UNK')
   and   isnull(t.trk_trl_division, 'UNK') in (@trl_division, 'UNK')
   and   isnull(t.trk_trc_company, 'UNK') in (@trc_company,  'UNK')
   and   isnull(t.trk_trc_fleet, 'UNK') in (@trc_fleet,  'UNK')
   and   isnull(t.trk_trc_division, 'UNK') in (@trc_division, 'UNK')
   and   isnull(t.trk_mpp_company, 'UNK') in (@mpp_company,  'UNK')
   and   isnull(t.trk_mpp_fleet, 'UNK') in (@mpp_fleet,  'UNK')
   and   isnull(t.trk_mpp_division, 'UNK') in (@mpp_division, 'UNK')
   and   isnull(t.trk_mpp_domicile, 'UNK') in (@mpp_domicile, 'UNK')
   and   isnull(t.trk_mpp_teamleader, 'UNK') in (@mpp_teamleader, 'UNK')
   AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
   AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
   AND IsNull((CASE WHEN t.trk_touraware = '' THEN NULL ELSE t.trk_touraware END), 'N') IN (@TourAware,'A') --PTS88910 SPN
   AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
   AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
   AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
   AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
   AND PrivateRestriction IS NULL --PTS 93857 SPN
  else
   insert into #temp(trk_number,tar_number)
   select t.trk_number,
      t.tar_number
    FROM tariffkey t with (nolock)
   WHERE t.trk_startdate <= @billdate AND
   t.trk_enddate >= @billdate AND
   t.trk_minstops <= @stops AND
   t.trk_maxstops >= @stops AND
   t.trk_minlength <= @length AND
   t.trk_maxlength >= @length AND
   t.trk_minwidth <= @width AND
   t.trk_maxwidth >= @width AND
   t.trk_minheight <= @height AND
   t.trk_maxheight >= @height AND
   isnull(t.trk_mincarriersvcdays, 0) <= @svcdays AND
   isnull(t.trk_maxcarriersvcdays, 2147483647) >= @svcdays AND
   t.trk_billto in (@billto, 'UNKNOWN') AND
   t.trk_orderedby in (@ordby, 'UNKNOWN') AND
   t.cmp_othertype1 in (@cmptype1, 'UNK') AND
   t.cmp_othertype2 in (@cmptype2, 'UNK') AND
   t.cmd_code in (@cmdcode, 'UNKNOWN') AND
   t.cmd_class in (@cmdclass, 'UNKNOWN') AND
   t.trl_type1 in (@trltype1, 'UNK') AND
   t.trl_type2 in (@trltype2, 'UNK') AND
   t.trl_type3 in (@trltype3, 'UNK') AND
   t.trl_type4 in (@trltype4, 'UNK') AND
   t.trk_revtype1 in (@revtype1, 'UNK') AND
   t.trk_revtype2 in (@revtype2, 'UNK') AND
   t.trk_revtype3 in (@revtype3, 'UNK') AND
   t.trk_revtype4 in (@revtype4, 'UNK') AND
   t.trk_originpoint in (@originpoint, 'UNKNOWN') AND
   t.trk_origincity in (@origincity, 0) AND
   t.trk_originzip in (@originzip, 'UNKNOWN') AND
   t.trk_origincounty in (@origincounty, 'UNK') AND
   t.trk_originstate in (@originstate, 'XX') AND
   t.trk_destpoint in (@destpoint, 'UNKNOWN') AND
   t.trk_destcity in (@destcity, 0) AND
   t.trk_destzip in (@destzip, 'UNKNOWN') AND
   t.trk_destcounty in (@destcounty, 'UNK') AND
   t.trk_deststate in (@deststate, 'XX') AND
   t.trk_primary = 'Y' AND
   t.trk_company in (@company, 'UNK') AND
   t.trk_carrier in (@carrier, 'UNKNOWN') AND
   t.trk_lghtype1 in (@triptype, 'UNK') AND
   t.trk_lghtype2 in (@lghtype2, 'UNK') AND --27135 JD
   t.trk_lghtype3 in (@lghtype3, 'UNK') AND --27135 JD
   t.trk_lghtype4 in (@lghtype4, 'UNK') AND --27135 JD
   --t.trk_load in (@loadstat, @matchloadstat) AND
   t.trk_load in (@loadstat, 'UNK') AND
   t.trk_team in (@team, 'UNK') AND
   t.trk_boardcarrier in (@cartype, 'UNK') AND
   IsNull(t.mpp_type1,'UNK') in (@drvtype1, 'UNK') AND
   IsNull(t.mpp_type2,'UNK') in (@drvtype2, 'UNK') AND
   IsNull(t.mpp_type3,'UNK') in (@drvtype3, 'UNK') AND
   IsNull(t.mpp_type4,'UNK') in (@drvtype4, 'UNK') AND
   IsNull(t.trc_type1,'UNK') in (@trctype1, 'UNK') AND
   IsNull(t.trc_type2,'UNK') in (@trctype2, 'UNK') AND
   IsNull(t.trc_type3,'UNK') in (@trctype3, 'UNK') AND
   IsNull(t.trc_type4,'UNK') in (@trctype4, 'UNK') AND
   IsNull(t.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
   ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
   ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
   ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
   ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
   ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
   ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvcregion, 'UNK') in (@origin_serviceregion, 'UNK')
   AND Isnull(t.trk_destsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_destsvcregion, 'UNK') in (@dest_serviceregion, 'UNK')
   AND IsNull(t.trk_thirdparty, 'UNKNOWN') in (@thirdparty, 'UNKNOWN')
   --BEGIN PTS 64272 SPN
   --AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN')
   AND IsNUll(t.trk_thirdpartytype, 'UNKNOWN') in (@thirdpartytype, 'UNKNOWN', 'UNK')
   --END PTS 64272 SPN
   AND t.trk_minsegments <= @segments
   AND t.trk_maxsegments >= @segments
   AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
   AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
   AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
   AND Isnull(t.mpp_id,'UNKNOWN') in (@driver, 'UNKNOWN') --vjh 33438
   AND Isnull(t.trc_number,'UNKNOWN') in (@tractor, 'UNKNOWN')
   AND Isnull(t.trl_number,'UNKNOWN') in (@trailer, 'UNKNOWN')
   AND Isnull(t.mpp_payto,'UNKNOWN') in (@drv_payto, 'UNKNOWN')
   AND Isnull(t.trc_owner,'UNKNOWN') in (@trc_owner, 'UNKNOWN')
   AND Isnull(t.trl_owner,'UNKNOWN') in (@trl_owner, 'UNKNOWN')
   AND Isnull(t.pto_id,'UNKNOWN') in (@car_payto, 'UNKNOWN') AND
   IsNull(t.mpp_terminal,'UNK') in (@mpp_terminal, 'UNK') AND
   IsNull(t.trc_terminal,'UNK') in (@trc_terminal, 'UNK') AND
   IsNull(t.trl_terminal,'UNK') in (@trl_terminal, 'UNK') AND
   IsNull(t.trk_primary_driver,'A') in (@primary_driver, 'A')
   AND IsNull(t.trk_route, 'UNKNOWN') in (@route, 'UNKNOWN')
   and isnull(t.trk_trl_company, 'UNK') in (@trl_company, 'UNK')
   and   isnull(t.trk_trl_fleet, 'UNK') in (@trl_fleet,  'UNK')
   and   isnull(t.trk_trl_division, 'UNK') in (@trl_division, 'UNK')
   and   isnull(t.trk_trc_company, 'UNK') in (@trc_company,  'UNK')
   and   isnull(t.trk_trc_fleet, 'UNK') in (@trc_fleet,  'UNK')
   and   isnull(t.trk_trc_division, 'UNK') in (@trc_division, 'UNK')
   and   isnull(t.trk_mpp_company, 'UNK') in (@mpp_company,  'UNK')
   and   isnull(t.trk_mpp_fleet, 'UNK') in (@mpp_fleet,  'UNK')
   and   isnull(t.trk_mpp_division, 'UNK') in (@mpp_division, 'UNK')
   and   isnull(t.trk_mpp_domicile, 'UNK') in (@mpp_domicile, 'UNK')
   and   isnull(t.trk_mpp_teamleader, 'UNK') in (@mpp_teamleader, 'UNK')
   AND IsNull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
   AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
   AND IsNull(t.trk_mpp_branch, 'UNKNOWN') in (@mpp_branch, 'UNKNOWN')                 -- vjh 63018
   AND IsNull(t.trk_trc_branch, 'UNKNOWN') in (@trc_branch, 'UNKNOWN')                 -- vjh 63018
   AND IsNull(t.trk_trl_branch, 'UNKNOWN') in (@trl_branch, 'UNKNOWN')                 -- vjh 63018
   AND IsNull(t.trk_car_branch, 'UNKNOWN') in (@car_branch, 'UNKNOWN')                 -- vjh 63018
   AND PrivateRestriction IS NULL --PTS 93857 SPN

Update #temp set taa_seq = 0 where taa_seq is null --46413 JD
update #temp set rth_id = t.rth_id from tariffkey t  with (nolock) where #temp.trk_number = t.trk_number --46413 JD

/* **********14820 Check for route rating matches and eliminate rates that do not match routes*********
   ***Please add additional region based stop checks for routes here***************
   JD 4/8/04
*/
If @ord_hdrnumber > 0
   BEGIN
     -- JGuo If exists(select 1 from stops where ord_hdrnumber = @ord_hdrnumber and stp_event = 'XDU')
     If exists(select 1 from stops where ord_hdrnumber = @ord_hdrnumber and ord_hdrnumber > 0 and stp_event = 'XDU')
        select @v_tripiscrossdocked = 'Y'
     else
        select @v_tripiscrossdocked = 'N'
   END
 else
    If @p_lghnumber > 0
       BEGIN
         If exists(select 1 from stops where lgh_number = @p_lghnumber and stp_event in ('XDU','XDL'))
            select @v_tripiscrossdocked = 'Y'
         else
            select @v_tripiscrossdocked = 'N'
         END

--If exists(select * from #temp where IsNull(rth_id,0) > 0) and (@ord_hdrnumber > 0 )
--36979 if  @v_tripiscrossdocked = 'Y' delete from #temp where IsNull(rth_id,0) > 0  /* of trip xdocked ignore tariffs with routes */
If exists (select 1 from #temp where IsNull(rth_id,0) > 0)


BEGIN

   --If (@ord_hdrnumber > 0)  -- billing route rating by order
   --50599 Settlements passing ord_hdrnumber need to change this to @retrieveby
   If (@ord_hdrnumber > 0 AND @p_lghnumber = 0)  -- billing route rating by order
     BEGIN
   --  insert into #stops
    -- 36979  select stp_mfh_sequence,cmp_id,stp_city,stp_zipcode from stops where ord_hdrnumber = @ord_hdrnumber
     insert into #stops (cmp_id,stp_city,stp_zipcode)
     select cmp_id,stp_city,stp_zipcode from stops  with (nolock) where ord_hdrnumber = @ord_hdrnumber
         and stp_event not in ('XDL','XDU')
         and ord_hdrnumber > 0 --pts35568
         order by stops.stp_sequence,stp_arrivaldate   -- 36979 use identity as the sequence field
    END
   If @p_lghnumber > 0  -- settlements route rating
     BEGIN

      /* PayRouteType determines what stop locations are used for route pay
     BillStopsOnMove
     AllStopsOnMove
     BillStopsOnLeg
     AllStopsOnLeg
     */
      Select @v_PayRouteType = Upper(Isnull(gi_string1,''))
      From generalinfo Where gi_name = 'PayRouteType'
      Select  @v_PayRouteType = Isnull(@v_PayRouteType,'BILLSTOPSONMOVE')

      If @v_PayRouteType <> 'BILLSTOPSONMOVE' and
    @v_PayRouteType <> 'BILLSTOPSONLEG' and
    @v_PayRouteType <> 'ALLSTOPSONMOVE' and
    @v_PayRouteType <> 'ALLSTOPSONLEG'
      Select @v_PayRouteType = 'BILLSTOPSONMOVE'  --Default
      Select @v_movnumber = Max(mov_number) from stops  with (nolock) where lgh_number = @p_lghnumber


      If @v_PayRouteType = 'BILLSTOPSONMOVE' and  (Select Count(Distinct ord_hdrnumber) From stops
          where mov_number = @v_movnumber and ord_hdrnumber > 0)  = 1
-- 36979 change mfh_seq to identity and order by to sequnce rows
-- insert into #stops
  --Select stp_mfh_sequence,cmp_id,stp_city,stp_zipcode
    insert into #stops(cmp_id,stp_city,stp_zipcode)
    Select cmp_id,stp_city,stp_zipcode
   from stops with (nolock) ,eventcodetable with (nolock)
   where ord_hdrnumber > 0
   and lgh_number in (Select distinct lgh_number from legheader  with (nolock) where mov_number = @v_movnumber)
   and stp_event = abbr and ect_billable = 'Y'
    order by stops.stp_mfh_sequence,stp_arrivaldate  --36979

      If @v_PayRouteType = 'BILLSTOPSONLEG' and  (Select Count(Distinct ord_hdrnumber) From stops
          where lgh_number =  @p_lghnumber and ord_hdrnumber > 0) = 1
-- 36979 change mfh_seq to identity and order by to sequnce rows
-- insert into #stops
  --Select stp_mfh_sequence,cmp_id,stp_city,stp_zipcode
    insert into #stops(cmp_id,stp_city,stp_zipcode)
    Select  cmp_id,stp_city,stp_zipcode
   from stops with (nolock), eventcodetable  with (nolock)
   where ord_hdrnumber > 0
   and lgh_number = @p_lghnumber
   and stp_event = abbr and ect_billable = 'Y'
    order by stops.stp_mfh_sequence,stp_arrivaldate

      If @v_PayRouteType = 'ALLSTOPSONMOVE' and  (Select Count(Distinct ord_hdrnumber) From stops  with (nolock)
          where mov_number = @v_movnumber and ord_hdrnumber > 0)  = 1
-- 36979 change mfh_seq to identity and order by to sequnce rowsd
--    insert into #stops
--Select stp_mfh_sequence,cmp_id,stp_city,stp_zipcode
   insert into #stops(cmp_id,stp_city,stp_zipcode)
    Select cmp_id,stp_city,stp_zipcode
   from stops  with (nolock)
   where lgh_number in (Select distinct lgh_number from legheader with (nolock) where mov_number = @v_movnumber)
    order by stops.stp_mfh_sequence,stp_arrivaldate

      If @v_PayRouteType = 'ALLSTOPSONLEG' and  (Select Count(Distinct ord_hdrnumber) From stops  with (nolock)
          where lgh_number =  @p_lghnumber and ord_hdrnumber > 0) = 1
 -- 36979 change mfh_seq to identity and order by to sequnce rowsd
-- insert into #stops
-- Select stp_mfh_sequence,cmp_id,stp_city,stp_zipcode
    insert into #stops(cmp_id,stp_city,stp_zipcode)
    Select cmp_id,stp_city,stp_zipcode
   from stops  with (nolock)
   where lgh_number = @p_lghnumber
    order by stops.stp_mfh_sequence,stp_arrivaldate


     END

   select @ll_ordstops  = count(*) from #stops

   select @trknumber = 0
   While 1=1
   Begin
      select @trknumber = min(trk_number) from #temp where trk_number > @trknumber and isnull(rth_id,0) > 0 -- JD 46413 added rth_id clause to avoid looping through every tariff
      If @trknumber is null
      break

      select @rth_id = rth_id from #temp where trk_number = @trknumber

      If IsNull(@rth_id,0) > 0
      begin
         select @ll_rtstops = count(*) from routedetail  with (nolock) where rth_id = @rth_id
         -- select @ll_rtstops , @ll_ordstops
         If @ll_rtstops = @ll_ordstops
         begin
            select @rtd_id = 0
            select @stp_mfh = 0
            While 2 = 2
            begin
               select @stp_mfh = min(stp_mfh_sequence) from #stops where stp_mfh_sequence > @stp_mfh
               If @stp_mfh is null
                  break

               select @rtd_id = min(rtd_id) from routedetail  with (nolock) where rth_id = @rth_id and rtd_id > @rtd_id
               If @rtd_id is null
                  break
               select @stp_cmp_id = cmp_id , @stp_city = stp_city , @stp_zip = stp_zipcode from #stops where stp_mfh_sequence =@stp_mfh
               select @cmp_id = cmp_id , @city = cty_code , @zip = rtd_zip from routedetail  with (nolock) where rth_id =@rth_id and rtd_id = @rtd_id

               -- select @stp_cmp_id ,@cmp_id,@stp_city ,@city, @stp_zip,@zip

               If NOT(@cmp_id = 'UNKNOWN' and @zip = 'UNKNOWN' and @city = 0)
               begin
                  select @ll_del = 0
                  If @cmp_id <> 'UNKNOWN'
                     If @cmp_id <> @stp_cmp_id
                        select @ll_del = 1

                  If @city > 0
                     if @city <> @stp_city
                        select @ll_del = 1

                  If @zip <> 'UNKNOWN'
                     If @zip <> @stp_zip
                        select @ll_del = 1

                  If @ll_del = 1
                     delete #temp where trk_number = @trknumber
               end

            end

         end
         Else
         begin
            delete #temp where trk_number = @trknumber
         end

      end

   End
END
IF @ord_hdrnumber = 0 and @p_lghnumber = 0 -- JD 30891
BEGIN
   Update #temp set rth_id = 0 --22893 JD set the id to zero when no order exists so tariff sort is unaffected.
END
/***************************end 14820***********************************************/

-- **************************46413 JD Set the remaining fields from the temp table before returning to the client**************************

UPDATE #temp SET
   trk_billto=                   t.trk_billto,
   trk_orderedby=                t.trk_orderedby,
   cmp_othertype1=               t.cmp_othertype1,
   cmp_othertype2=               t.cmp_othertype2,
   cmd_code=                     t.cmd_code,
   cmd_class=                    t.cmd_class,
   trl_type1=                    t.trl_type1,
   trl_type2=                    t.trl_type2,
   trl_type3=                    t.trl_type3,
   trl_type4=                    t.trl_type4,
   trk_revtype1=                 t.trk_revtype1,
   trk_revtype2=                 t.trk_revtype2,
   trk_revtype3=                 t.trk_revtype3,
   trk_revtype4=                 t.trk_revtype4,
   trk_originpoint=              t.trk_originpoint,
   trk_origincity=               t.trk_origincity,
   trk_originzip=                t.trk_originzip,
   trk_origincounty=             t.trk_origincounty,
   trk_originstate=              t.trk_originstate,
   trk_destpoint=                t.trk_destpoint,
   trk_destcity=                 t.trk_destcity,
   trk_destzip=                  t.trk_destzip,
   trk_destcounty=               t.trk_destcounty,
   trk_deststate=                t.trk_deststate,
   trk_duplicateseq=             t.trk_duplicateseq,
   trk_company=                  t.trk_company,
   trk_carrier=                  t.trk_carrier,
   trk_lghtype1=                 t.trk_lghtype1,
   trk_load=                     t.trk_load,
   trk_team=                     t.trk_team,
   trk_boardcarrier=             t.trk_boardcarrier,
   trk_minmiles=                 t.trk_minmiles,
   trk_maxmiles=                 t.trk_maxmiles,
   trk_distunit=                 t.trk_distunit,
   trk_minweight=                t.trk_minweight,
   trk_maxweight=                t.trk_maxweight,
   trk_wgtunit=                  t.trk_wgtunit,
   trk_minpieces=                t.trk_minpieces,
   trk_maxpieces=                t.trk_maxpieces,
   trk_countunit=                t.trk_countunit,
   trk_minvolume=                t.trk_minvolume,
   trk_maxvolume=                t.trk_maxvolume,
   trk_volunit=                  t.trk_volunit,
   trk_minodmiles=               t.trk_minodmiles,
   trk_maxodmiles=               t.trk_maxodmiles,
   trk_odunit=                   t.trk_odunit,
   mpp_type1=                    t.mpp_type1,
   mpp_type2=                    t.mpp_type2,
   mpp_type3=                    t.mpp_type3,
   mpp_type4=                    t.mpp_type4,
   trc_type1=                    t.trc_type1,
   trc_type2=                    t.trc_type2,
   trc_type3=                    t.trc_type3,
   trc_type4=                    t.trc_type4,
   cht_itemcode=                 t.cht_itemcode,
   trk_stoptype=                 t.trk_stoptype,
   trk_delays=                   t.trk_delays,
   trk_carryins1=                t.trk_carryins1,
   trk_carryins2=                t.trk_carryins2,
   trk_ooamileage=               t.trk_ooamileage,
   trk_ooastop=                  t.trk_ooastop,
   trk_minmaxmiletype=           t.trk_minmaxmiletype,
   trk_terms=                    t.trk_terms,
   trk_triptype_or_region=       t.trk_triptype_or_region,
   trk_tt_or_oregion=            t.trk_tt_or_oregion,
   trk_dregion=                  t.trk_dregion,
   cmp_mastercompany=            t.cmp_mastercompany,
-- taa_seq=                      0, -- 46413 JD this is set based on primary,secondary (billing  rate or settlements rate)
   trk_mileagetable=             t.trk_mileagetable,
   trk_fueltableid=              t.trk_fueltableid,
   trk_minrevpermile=            t.trk_minrevpermile,
   trk_maxrevpermile=            t.trk_maxrevpermile,
   trk_stp_event =               t.trk_stp_event ,
-- rth_id=                       t.rth_id,-- 46413 JD this has already been set before the loop checking for route rating matches.
   trk_minvariance=              t.trk_minvariance,
   trk_maxvariance=              t.trk_maxvariance,
   trk_originsvccenter=          isNull(t.trk_originsvccenter,'UNK'),
   trk_originsvcregion=          isNull(t.trk_originsvcregion,'UNK'),
   trk_destsvccenter=            isNull(t.trk_destsvccenter,'UNK'),
   trk_destsvcregion=            isNull(t.trk_destsvcregion,'UNK'),
   trk_lghtype2=                 t.trk_lghtype2, --27135 JD
   trk_lghtype3=                 t.trk_lghtype3, --27135 JD
   trk_lghtype4=                 t.trk_lghtype4,  --27135 JD
   trk_thirdparty=               isnull(t.trk_thirdparty,'UNKNOWN'), --t.trk_thirdparty,
   trk_thirdpartytype=           isnull(t.trk_thirdpartytype, 'UNKNOWN'), -- t.trk_thirdpartytype
   trk_minsegments=              t.trk_minsegments,
   trk_maxsegments=              t.trk_maxsegments,
   billto_othertype1=            isNull(t.billto_othertype1,'UNK'),  --vjh 32868
   billto_othertype2=            isNull(t.billto_othertype2,'UNK'),  --vjh 32868
   masterordernumber=            isnull(t.masterordernumber,''),     --vjh 33160
   driver=                       isNull(t.mpp_id,'UNKNOWN'),         --vjh 33438
   tractor=                      isNull(t.trc_number,'UNKNOWN'),
   trailer=                      isNull(t.trl_number,'UNKNOWN'),
   drv_payto=                    isNull(t.mpp_payto,'UNKNOWN'),
   trc_owner=                    isNull(t.trc_owner,'UNKNOWN'),
   trl_owner=                    isNull(t.trl_owner,'UNKNOWN'),
   car_payto=                    isNull(t.pto_id,'UNKNOWN'),
   mpp_terminal=                 isNull(t.mpp_terminal,'UNK'),
   trc_terminal=                 isNull(t.trc_terminal,'UNK'),
   trl_terminal=                 isNull(t.trl_terminal,'UNK'),
   trk_primary_driver=           isNull(t.trk_primary_driver,'A'),
   stop_othertype1=              isNull(t.stop_othertype1,'UNK'), --vjh 37595
   stop_othertype2=              isNull(t.stop_othertype2,'UNK'), --vjh 37595
   trk_index_factor =            t.trk_index_factor, --emk 38973,
   trk_usefor_billable=          t.trk_usefor_billable,
   trk_mincarriersvcdays=        t.trk_mincarriersvcdays,      --46113 pmill
   trk_maxcarriersvcdays=        t.trk_maxcarriersvcdays,         --46113 pmill
   trk_route=                 IsNull(t.trk_route, 'UNKNOWN'),
   trl_company =              isnull(t.trk_trl_company, 'UNK'),
   trl_fleet =                isnull(t.trk_trl_fleet, 'UNK') ,
   trl_division =                isnull(t.trk_trl_division, 'UNK') ,
   trc_company =              isnull(t.trk_trc_company, 'UNK') ,
   trc_fleet =                isnull(t.trk_trc_fleet, 'UNK') ,
   trc_division =                isnull(t.trk_trc_division, 'UNK') ,
   mpp_company =              isnull(t.trk_mpp_company, 'UNK'),
   mpp_fleet =                isnull(t.trk_mpp_fleet, 'UNK') ,
   mpp_division =             isnull(t.trk_mpp_division, 'UNK') ,
   mpp_domicile =             isnull(t.trk_mpp_domicile, 'UNK') ,
   mpp_teamleader =           isnull(t.trk_mpp_teamleader, 'UNK'),
   trk_pallet_type =          IsNull(t.trk_pallet_type, 'UNK') ,
   trk_pallet_count =            IsNull(t.trk_pallet_count, 0),
   trk_ratemode =             isnull(t.trk_ratemode, 'UNK') ,     -- 11/18/2011 NQIAO PTS 58978
   trk_servicelevel =            IsNull(t.trk_servicelevel, 'UNK'),  -- 11/18/2011 NQIAO PTS 58978
   -- trk_mpp_grandfatherfromdate   =  t.trk_mpp_grandfatherfromdate,   -- 62954
   -- trk_mpp_grandfathertodate =      t.trk_mpp_grandfathertodate,  -- 62954
   -- trk_trc_grandfatherfromdate = t.trk_trc_grandfatherfromdate,   -- 62954
   -- trk_trc_grandfathertodate =      t.trk_trc_grandfathertodate      -- 62954
   trk_mpp_grandfatherfromdate   = isnull(t.trk_mpp_grandfatherfromdate, '1950-01-01 00:00:00.000'),  -- 72434
   trk_mpp_grandfathertodate  = isnull(t.trk_mpp_grandfathertodate, '2049-12-31 23:59:00.000'),       -- 72434
   trk_trc_grandfatherfromdate   = isnull(t.trk_trc_grandfatherfromdate, '1950-01-01 00:00:00.000'),  -- 72434
   trk_trc_grandfathertodate  = isnull(t.trk_trc_grandfathertodate, '2049-12-31 23:59:00.000')        -- 72434
FROM tariffkey t  with (nolock)
WHERE #temp.trk_number = t.trk_number

-- 62954 starts
if @retrieveby = 'S' and @tarnum = 0 -- settlement primary rate, clean up invalid grandfather rates
begin
   -- for driver's grandfather rate(s)
   if isnull(@driver, '') <> '' and @mpp_grandfather_date is not null
   begin
      select   @rowcount = count(tar_number)
      from  #temp
      where @mpp_grandfather_date between trk_mpp_grandfatherfromdate and trk_mpp_grandfathertodate

      if @rowcount > 0  -- grandfather rate(s) exist, clean all other rate(s)
         delete   from #temp
         where (@mpp_grandfather_date < trk_mpp_grandfatherfromdate or @mpp_grandfather_date > trk_mpp_grandfathertodate)
         or    (trk_mpp_grandfatherfromdate is null and trk_mpp_grandfathertodate is null)
      else           -- no grandfather rate exist, remove out-range rate(s) but keep non-sepcified rate(s)
         delete   from #temp
         where (trk_mpp_grandfatherfromdate is not null or trk_mpp_grandfathertodate is not null)
         and      (@mpp_grandfather_date < trk_mpp_grandfatherfromdate or @mpp_grandfather_date > trk_mpp_grandfathertodate)
   end

   if isnull(@driver, '') <> '' and @mpp_grandfather_date is null -- remove grandfather date specific rate(s)
      delete   from #temp
      where (trk_mpp_grandfatherfromdate > '1950-01-01 00:00:00.000') or (trk_mpp_grandfathertodate < '2049-12-31 23:59:00.000') -- 72434
      -- 72434   where trk_mpp_grandfatherfromdate is not null or trk_mpp_grandfathertodate is not null

   -- for tractor's grandfather rate(s)
   if isnull(@tractor, '') <> '' and @trc_grandfather_date is not null
   begin
      select   @rowcount = count(tar_number)
      from  #temp
      where @trc_grandfather_date between trk_trc_grandfatherfromdate and trk_trc_grandfathertodate

      if @rowcount > 0  -- grandfather rate(s) exist, clean all other rate(s)
         delete   from #temp
         where (@trc_grandfather_date < trk_trc_grandfatherfromdate or @trc_grandfather_date > trk_trc_grandfathertodate)
         or    (trk_trc_grandfatherfromdate is null and trk_trc_grandfathertodate is null)
      else           -- no grandfather rate exist, remove out-range rate(s) but keep non-sepcified rate(s)
         delete   from #temp
         where (trk_trc_grandfatherfromdate is not null or trk_trc_grandfathertodate is not null)
         and      (@trc_grandfather_date < trk_trc_grandfatherfromdate or @trc_grandfather_date > trk_trc_grandfathertodate)
   end

   if isnull(@tractor, '') <> '' and @trc_grandfather_date is null   -- remove grandfather date specific rate(s)
      delete   from #temp
      where (trk_trc_grandfatherfromdate > '1950-01-01 00:00:00.000') or (trk_trc_grandfathertodate < '2049-12-31 23:59:00.000') -- 72434
      -- 72434  where trk_trc_grandfatherfromdate is not null or trk_trc_grandfathertodate is not null

end
-- 62954 ends


-- 02/15/2013 NQIAO PTS 63181 <start>
UPDATE   #temp
SET      tar_orderstoapply = ISNULL(h.tar_orderstoapply, 0),
      tar_ordersremaining = ISNULL(h.tar_orderstoapply, 0) - (SELECT COUNT(rol_tar_number) from rate_order_list where rol_tar_number = #temp.tar_number)
FROM  tariffheader h WITH (NOLOCK)
WHERE #temp.tar_number = h.tar_number

-- delete rate(s) having tar_orderstoapply > 0 and tar_ordersremaining = 0 that are no longer available to apply
DELETE   FROM #temp
WHERE tar_orderstoapply > 0
AND      tar_ordersremaining = 0
-- 02/15/2013 NQIAO PTS 63181 <end>

-- 10/11/2013 PTS 69449.start -- Do LoadReq logic Last.
 -- IF {INI setting } @TKLoadReq <> 'Y'  OR  if not from billing skip; if no ord_hdr - nothing to process so skip.
 Declare @OrderLdReqIdent int
 declare @OrderLdReqCount int
 Declare @TarLdRqRestrictionCount int
 Declare @TKLDistinctKeysCount int
 Declare @LdReq_mov_number int
 declare @tkltariffkey int
 declare @AssetCompare varchar(8)
 declare @LdReqCompare varchar(8)
 Set @LdReq_mov_number = 0
 if @ord_hdrnumber > 0
 begin
   Select @LdReq_mov_number = Min(mov_number) from orderheader where ord_hdrnumber = @ord_hdrnumber
 end

 IF @TKLoadReq = 'Y' AND @retrieveby = 'B'  AND @ord_hdrnumber > 0  AND
   exists(select 1 from loadrequirement
      where ( ( IsNull(loadrequirement.ord_hdrnumber,0) = @ord_hdrnumber and IsNull(ord_hdrnumber,0) > 0)
         OR (loadrequirement.mov_number) = @LdReq_mov_number and IsNull(ord_hdrnumber,0) = 0)  )
 Begin

   if exists(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TariffKeyLoadRequirements')
      begin
         if ( select max(tklr_id) from TariffKeyLoadRequirements ) > 0
            begin
                     Create table #TKLkeys( trk_number Int Null, tcount Int null)
                     Create table #Tt1( trk_number Int Null, tcount2 Int null)
                     Create table #keysToRemove( trk_number Int Null)

                     insert into #TKLkeys (trk_number, tcount)
                     select distinct trk_number, Count(trk_number) from  TariffKeyLoadRequirements
                     where trk_number in (select Distinct(trk_number) from #temp)   group by trk_number

                     Create table #lTarLR (
                       trk_number            INT  NULL
                     , tarkey_LR_Asset    varchar(8) null
                     , tarkey_LR_Abbr     varchar(8) null
                     )

                     Create table #lLRraw (
                       lLRraw_ident int identity(1,1),
                       ord_hdrnumber             INT  NULL
                     , lrq_equip_type_Asset     varchar(8) null
                     , lrq_type_Abbr            varchar(8) null
                     )

                     -- LoadRequirment table very often does NOT have ord_hdrnumber populated. BUT the mov_number seems to always be populated.
                        Insert into #lLRraw (ord_hdrnumber, lrq_equip_type_Asset, lrq_type_Abbr)
                        Select @ord_hdrnumber, lrq_equip_type, lrq_type
                        from loadrequirement
                        where (  ( IsNull(ord_hdrnumber, 0) = @ord_hdrnumber and IsNull(ord_hdrnumber,0) > 0 )
                              OR (loadrequirement.mov_number = @LdReq_mov_number and IsNull(ord_hdrnumber,0) = 0)  )

                  insert into #lTarLR (trk_number , tarkey_LR_Asset, tarkey_LR_Abbr )
                  Select  TKL.trk_number,  TKL.tklr_equip_type, TKL.tklr_type
                  from TariffKeyLoadRequirements TKL
                     Right Join #lLRraw on ( TKL.tklr_equip_type = #lLRraw.lrq_equip_type_Asset AND
                                       TKL.tklr_type  = #lLRraw.lrq_type_Abbr  )
                     Where TKL.trk_number in (select distinct(trk_number) from   #TKLkeys )
                     group by TKL.trk_number , TKL.tklr_equip_type, TKL.tklr_type

                  insert into #Tt1(trk_number, tcount2)
                  select trk_number, count(trk_number) from #lTarLR group by trk_number

                  insert into #keysToRemove (trk_number)
                  select #Tt1.trk_number
                  from #Tt1
                  join #TKLkeys on ( #Tt1.trk_number = #TKLkeys.trk_number  AND #Tt1.tcount2 <> #TKLkeys.tcount  )

                  DELETE   FROM #temp where trk_number in (select trk_number from #keysToRemove)
                  Delete   from #lTarLR where  trk_number in (select trk_number from #keysToRemove)
                  delete   from #TKLkeys where  trk_number in (select trk_number from #keysToRemove)

                  Set @TarLdRqRestrictionCount = 0
                  Set @OrderLdReqIdent =0
                  set @OrderLdReqCount = 0
                  select @TKLDistinctKeysCount = 0
                  Select @TKLDistinctKeysCount = count(*) from #TKLKeys
                  select @OrderLdReqCount = count(*) from #lLRraw

                  -----------------------  keep only those w/ counts the same: compare the actual loadreq values & remove mismatched.
                  While @TKLDistinctKeysCount  > 0
                  Begin
                     select @tkltariffkey = min(trk_number) from #TKLkeys
                     delete   from #TKLkeys where  trk_number = @tkltariffkey -- grab min key then delete it
                     While @OrderLdReqCount > 0
                     Begin
                        Select @OrderLdReqIdent = min(lLRraw_ident) from #lLRraw where #lLRraw.lLRraw_ident > @OrderLdReqIdent
                        select @AssetCompare = #lLRraw.lrq_equip_type_Asset from #lLRraw where #lLRraw.lLRraw_ident = @OrderLdReqIdent
                        select @LdReqCompare = #lLRraw.lrq_type_Abbr from  #lLRraw where #lLRraw.lLRraw_ident = @OrderLdReqIdent
                        if ( select count(*)
                              from #lTarLR
                              where #lTarLR.trk_number = @tkltariffkey
                              AND   #lTarLR.tarkey_LR_Asset = @AssetCompare
                              AND   #lTarLR.tarkey_LR_Abbr = @LdReqCompare ) <=0
                           begin
                              Delete   from #lTarLR where  trk_number  = @tkltariffkey
                              DELETE   FROM #temp where trk_number = @tkltariffkey
                              Select @TKLDistinctKeysCount = count(*) from #TKLKeys
                              Set @OrderLdReqIdent =0
                              select @tkltariffkey = min(trk_number) from #TKLkeys
                              Select @TKLDistinctKeysCount = count(*) from #TKLKeys
                           end
                        select @OrderLdReqCount  = @OrderLdReqCount  - 1
                     End
                     select @OrderLdReqCount  = @OrderLdReqCount  - 1
                     Select @TKLDistinctKeysCount = count(*) from #TKLKeys
                  End

               if  (select count(*) from #Tt1)  > 0
               begin
                  DELETE   FROM #temp where trk_number NOT IN (select trk_number from #Tt1 )
               end
            End
      End
      IF OBJECT_ID(N'tempdb..#keysToRemove', N'U') IS NOT NULL
                        DROP TABLE #keysToRemove
      IF OBJECT_ID(N'tempdb..#Tt1', N'U') IS NOT NULL
                        DROP TABLE #Tt1
      IF OBJECT_ID(N'tempdb..#lTarLR', N'U') IS NOT NULL
                        DROP TABLE #lTarLR
      IF OBJECT_ID(N'tempdb..#lLRraw', N'U') IS NOT NULL
                        DROP TABLE #lLRraw
      IF OBJECT_ID(N'tempdb..#TKLkeys', N'U') IS NOT NULL
                        DROP TABLE #TKLkeys
 End
-- 10/11/2013 PTS 69449.end

-- Final Result Set
SELECT  DISTINCT
   trk_number,
   tar_number,
   trk_billto,
   trk_orderedby,
   cmp_othertype1,
   cmp_othertype2,
   cmd_code,
   cmd_class,
   trl_type1,
   trl_type2,     --10
   trl_type3,
   trl_type4,
   trk_revtype1,
   trk_revtype2,
   trk_revtype3,
   trk_revtype4,
   trk_originpoint,
   trk_origincity,
   trk_originzip,
   trk_origincounty,    --20
   trk_originstate,
   trk_destpoint,
   trk_destcity,
   trk_destzip,
   trk_destcounty,
   trk_deststate,
   trk_duplicateseq,
   trk_company,
   trk_carrier,
   trk_lghtype1,     --30
   trk_load,
   trk_team,
   trk_boardcarrier,
   trk_minmiles,
   trk_maxmiles,
   trk_distunit,
   trk_minweight,
   trk_maxweight,
   trk_wgtunit,
   trk_minpieces,    --40
   trk_maxpieces,
   trk_countunit,
   trk_minvolume,
   trk_maxvolume,
   trk_volunit,
   trk_minodmiles,
   trk_maxodmiles,
   trk_odunit,
   isnull(mpp_type1, 'UNK') mpp_type1,
   isnull(mpp_type2, 'UNK') mpp_type2,    --50
   isnull(mpp_type3, 'UNK') mpp_type3,
   isnull(mpp_type4, 'UNK') mpp_type4,
   isnull(trc_type1, 'UNK') trc_type1,
   isnull(trc_type2, 'UNK') trc_type2,
   isnull(trc_type3, 'UNK') trc_type3,
   isnull(trc_type4, 'UNK') trc_type4,
   isnull(cht_itemcode, 'UNK') cht_itemcode,
   isnull(trk_stoptype, 'UNK') trk_stoptype,
   isnull(trk_delays, 'UNK') trk_delays,
   isnull(trk_carryins1, 0) trk_carryins1,      --60
   isnull(trk_carryins2, 0) trk_carryins2,
   isnull(trk_ooamileage, 0) trk_ooamileage,
   isnull(trk_ooastop, 0) trk_ooastop,
   isnull(trk_minmaxmiletype,0) trk_minmaxmiletype,
   isnull(trk_terms,'UNK') trk_terms,
   ISNULL(trk_triptype_or_region,'X') trk_triptype_or_region,
   ISNULL(trk_tt_or_oregion,'') trk_tt_or_oregion,
   ISNULL(trk_dregion,'') trk_dregion,
   cmp_mastercompany,
   taa_seq,                --70
   trk_mileagetable,
   trk_fueltableid,
   trk_minrevpermile,
   trk_maxrevpermile,
   trk_stp_event ,
   IsNull(rth_id,0) rth_id,      --14820 22729 JD
   trk_minvariance,
   trk_maxvariance,
   trk_originsvccenter,
   trk_originsvcregion,    --80
   trk_destsvccenter,
   trk_destsvcregion,
   trk_lghtype2, --27135 JD
   trk_lghtype3, --27135 JD
   trk_lghtype4,  --27135 JD
   trk_thirdparty,
   trk_thirdpartytype,
   trk_minsegments,
   trk_maxsegments,
   billto_othertype1,   --vjh 32868    --90
   billto_othertype2,   --vjh 32868
   masterordernumber,  --vjh 33160
   driver,           --vjh 33438
   tractor,
   trailer,
   drv_payto,
   trc_owner,
   trl_owner,
   car_payto,
   mpp_terminal,           --100
   trc_terminal,
   trl_terminal,
   trk_primary_driver,
   stop_othertype1,  --vjh 37595
   stop_othertype2,  --vjh 37595
   trk_index_factor ,--emk 38973,
   trk_usefor_billable,
   trk_mincarriersvcdays,  --46113 pmill
   trk_maxcarriersvcdays,  --46113 pmill
   trk_route,  --MRH 50169
   trl_company ,
   trl_fleet,
   trl_division,
   trc_company,
   trc_fleet,
   trc_division,
   mpp_company,
   mpp_fleet,
   mpp_division,
   mpp_domicile,
   mpp_teamleader,
   trk_pallet_type ,
   trk_pallet_count,
   trk_ratemode,     -- 11/18/2011 NQIAO PTS 58978
   trk_servicelevel  -- 11/18/2011 NQIAO PTS 58978
from #temp


-- PTS 69449: drop temp table
IF OBJECT_ID(N'tempdb..#temp', N'U') IS NOT NULL
DROP TABLE #temp

GO
GRANT EXECUTE ON  [dbo].[d_tar_gettariffkeys_sp] TO [public]
GO
