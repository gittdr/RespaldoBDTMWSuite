SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*   MODIFICATION

 2/2/99 change to return all columns

DPETE PTS12047 when multiple indexes apply on a secondary charge the rate pulls multiple times.  Added
   AND trk_number = (Select min(trk_number) FROM tariffkey c
      WHERE c.tar_number = t.tar_number)
  to retrieve for secondary charges
DPETE 16010 Third attempt at eliminating duplicate tariff keys for secondary rates. Pull
    out code int the proc and try to handle in the application (if there are multiple
    indexes on a secondary rate whihc differ only by trip type or region, candidates are
    eliminated here with Delete code below).
LOR   27446 add minvariance, maxvariance

PTS 26793 (Recode 20297) - DJM - Add the Localization setting of Origin/Desitnation service_center and service_region to the
   tariffkey parameters.
* EMK  PTS# 38973  add trk_index_factor
* 11/19/2007 PTS 38811 JDS:  mod 4 cols from INT  to Dec(19,4)
*  LOR   PTS# 33652  add trk_usefor_billable
*  LOR   PTS# 56807, 56805 lghtype2, pallettype, palletcount
* NQIAO PTS# 58978 add 2 new arguments (@trk_ratemode and @trk_servicelevel) and include them in WHERE clauses where needed
* PTS93857 SPN - PrivateRestriction SHOULD BE NULL
* SPN NSUITE200443 01/24/2017 - MileageTable increased to CHAR(2)
*/

CREATE PROC [dbo].[d_tar_gettarkeys_li]
   @tarnum int,
   @billdate datetime,
   @billto char(8),
   @ordby char(8),
   @cmptype1 char(6),
   @cmptype2 char(6),
   @trltype1 char(6),
   @trltype2 char(6),
   @trltype3 char(6),
   @trltype4 char(6),
   @revtype1 char(6),
   @revtype2 char(6),
   @revtype3 char(6),
   @revtype4 char(6),
   @cmdcode char(8),
   @cmdclass char(8),
   @originpoint char(8),
   @origincity int,
   @originzip char(10),
   @origincounty char(3),
   @originstate char(6),
   @destpoint char(8),
   @destcity int,
   @destzip char(10),
   @destcounty char(3),
   @deststate char(6),
   @miles int,
   @distunit char(6),
   @odmiles int,
   @odunit char(6),
   @stops int,
   @length money,
   @width money,
   @height money,
   @company char(8),
   @carrier char(8),
   @triptype char(6),
   @loadstat char(6),
   @team char(6),
   @cartype char(6),
   @drvtype1 char(6),
   @drvtype2 char(6),
   @drvtype3 char(6),
   @drvtype4 char(6),
   @trctype1 char(6),
   @trctype2 char(6),
   @trctype3 char(6),
   @trctype4 char(6),
   @itemcode char(6),
   @pytitemcode char(6),
        @stoptype char(6),
        @delays char(6),
        @carryins1 int,
        @carryins2 int,
        @ooamileage int,
        @ooastop int ,
   @retrieveby char(1), --This argument is ignored here. Kept for consistency of retrieval
   @terms char(6),
   @mastercompany char(8),
   @origin_servicecenter   varchar(6),
   @origin_serviceregion   varchar(6),
   @dest_servicecenter  varchar(6),
   @dest_serviceregion  varchar(6),
   @billto_othertype1   varchar(6), -- vjh 32868
   @billto_othertype2   varchar(6), -- vjh 32868
   @masterordernumber   varchar(12),
   @lghtype2 varchar(6),
   @pallet_type varchar(6),
   @pallet_count int,
   @trk_ratemode     varchar(6), -- 11/18/2011 NQIAO PTS 58978
   @trk_servicelevel varchar(6)  -- 11/18/2011 NQIAO PTS 58978
as

declare  @trknumber int,
        @tcarryins1 int,
        @tcarryins2 int,
        @tooamileage int,
        @tooastop int

IF @carryins1 > 0
   SELECT @tcarryins1 = 1
IF @carryins2 > 0
   SELECT @tcarryins2 = 1
IF @ooamileage > 0
   SELECT @tooamileage = 1
IF @ooastop > 0
   SELECT @tooastop = 1

Select @loadstat = IsNull(@loadstat,'UNK')

--PTS 26793 (recode 22600) - DJM
select @origin_servicecenter = isnull(@origin_servicecenter,'UNK')
select @origin_serviceregion = isnull(@origin_serviceregion,'UNK')
select @dest_servicecenter = isnull(@dest_servicecenter,'UNK')
select @dest_serviceregion = isnull(@dest_serviceregion,'UNK')

create table #temp (trk_number int null,
   tar_number int null,
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
   trk_maxweight decimal(19,4) null,      -- PTS 38811
   --trk_minweight int null,
   --trk_maxweight int null,
   trk_wgtunit varchar(6) null,
   trk_minpieces int null,
   trk_maxpieces int null,
   trk_countunit varchar(6) null,
   trk_minvolume decimal(19,4) null,      -- PTS 38811
   trk_maxvolume decimal(19,4) null,      -- PTS 38811
   --trk_minvolume int null,
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
   cmp_mastercompany varchar(8) null ,
   taa_seq int null,
   trk_mileagetable char(2) null,
   trk_fueltableid char(8) null,
   trk_minrevpermile money null,
   trk_maxrevpermile money null,
   trk_stp_event varchar(6) null,
   trk_minvariance money null,
   trk_maxvariance money null,
   trk_originsvccenter  varchar(6) null,
   trk_originsvcregion  varchar(6) null,
   trk_destsvccenter varchar(6) null,
   trk_destsvcregion varchar(6) null,
   billto_othertype1 varchar(6) null,  --vjh 32868
   billto_othertype2 varchar(6) null,  --vjh 32868
   masterordernumber varchar(12) null,
   trk_index_factor decimal(19,6) null,
   trk_usefor_billable  int   null,
   trk_lghtype2 varchar(6) null,
   trk_pallet_type varchar(6) null,
   trk_pallet_count int null,
   trk_ratemode      varchar(6) null,  -- 11/18/2011 NQIAO PTS 58978
   trk_servicelevel  varchar(6) null)  -- 11/18/2011 NQIAO PTS 58978

insert into #temp
select t.trk_number,
   t.tar_number,
   t.trk_billto,
   t.trk_orderedby,
   t.cmp_othertype1,
   t.cmp_othertype2,
   t.cmd_code,
   t.cmd_class,
   t.trl_type1,
   t.trl_type2,      --10
   t.trl_type3,
   t.trl_type4,
   t.trk_revtype1,
   t.trk_revtype2,
   t.trk_revtype3,
   t.trk_revtype4,
   t.trk_originpoint,
   t.trk_origincity,
   t.trk_originzip,
   t.trk_origincounty,     --20
   t.trk_originstate,
   t.trk_destpoint,
   t.trk_destcity,
   t.trk_destzip,
   t.trk_destcounty,
   t.trk_deststate,
   t.trk_duplicateseq,
   t.trk_company,
   t.trk_carrier,
   t.trk_lghtype1,      --30
   t.trk_load,
   t.trk_team,
   t.trk_boardcarrier,
   t.trk_minmiles,
   t.trk_maxmiles,
   t.trk_distunit,
   t.trk_minweight,
   t.trk_maxweight,
   t.trk_wgtunit,
   t.trk_minpieces,     --40
   t.trk_maxpieces,
   t.trk_countunit,
   t.trk_minvolume,
   t.trk_maxvolume,
   t.trk_volunit,
   t.trk_minodmiles,
   t.trk_maxodmiles,
   t.trk_odunit,
   mpp_type1 = ISNULL(t.mpp_type1,'UNK'),
   mpp_type2 = ISNULL(t.mpp_type2,'UNK'),    --50
   mpp_type3 = ISNULL(t.mpp_type3,'UNK'),
   mpp_type4 = ISNULL(t.mpp_type4,'UNK'),
   trc_type1 = ISNULL(t.trc_type1,'UNK'),
   trc_type2 = ISNULL(t.trc_type2,'UNK'),
   trc_type3 = ISNULL(t.trc_type3,'UNK'),
   trc_type4 = ISNULL(t.trc_type4,'UNK'),
   cht_itemcode = ISNULL(t.cht_itemcode,'UNK'),
        t.trk_stoptype,
        t.trk_delays,
        t.trk_carryins1,      --60
        t.trk_carryins2,
        t.trk_ooamileage,
        t.trk_ooastop ,
   IsNull(t.trk_minmaxmiletype,0),
   t.trk_terms,
   ISNULL(t.trk_triptype_or_region,'X'),
   ISNULL(t.trk_tt_or_oregion,''),
   ISNULL(t.trk_dregion,''),
   t.cmp_mastercompany,
   0, -- set the seq to zero taa_seq from tariffaccessorial not used here     --70
   t.trk_mileagetable,
   t.trk_fueltableid,
   t.trk_minrevpermile,
   t.trk_maxrevpermile ,
   t.trk_stp_event   ,
   trk_minvariance,
   trk_maxvariance,
   isNull(t.trk_originsvccenter,'UNK'),
   isNull(t.trk_originsvcregion,'UNK'),
   isNull(t.trk_destsvccenter,'UNK'),     --80
   isNull(t.trk_destsvcregion,'UNK'),
   isNull(t.billto_othertype1,'UNK'), --vjh 32868
   isNull(t.billto_othertype2,'UNK'), --vjh 32868
   isnull(t.masterordernumber,''),  --vjh 33160
   t.trk_index_factor,
   t.trk_usefor_billable,
   isnull(t.trk_lghtype2,'UNK'),
   isnull(t.trk_pallet_type,'UNK'),
   isnull(t.trk_pallet_count, 0),
   isnull(t.trk_ratemode, 'UNK'),      -- 11/18/2011 NQIAO PTS 58978
   isnull(t.trk_servicelevel, 'UNK')   -- 11/18/2011 NQIAO PTS 58978
   FROM tariffkey t, tariffheader th
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
   t.trk_primary = 'L' AND
   t.trk_company in (@company, 'UNK') AND
   t.trk_carrier in (@carrier, 'UNKNOWN') AND
   t.trk_lghtype1 in (@triptype, 'UNK') AND
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
   th.cht_itemcode = @pytitemcode AND
   t.tar_number = th.tar_number AND
        ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
        ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
        ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
        ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
        ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
        ISNULL(t.trk_ooastop , 0) in (@tooastop, 0) and
   ISNULL(t.trk_terms , 'UNK') in (@terms, 'UNK')  and
   t.cmp_mastercompany in (@mastercompany, 'UNKNOWN')
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_serviceregion, 'UNK')
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
      AND Isnull(t.billto_othertype1, 'UNK') in (@billto_othertype1, 'UNK')
      AND Isnull(t.billto_othertype2, 'UNK') in (@billto_othertype2, 'UNK')
      AND Isnull(t.masterordernumber, '') in (@masterordernumber, '')
   and Isnull(t.trk_lghtype2, 'UNK') in (@lghtype2, 'UNK')
   AND Isnull(t.trk_pallet_type, 'UNK') in (@pallet_type, 'UNK')
   AND Isnull(t.trk_pallet_count, 0) in (@pallet_count, 0)
   AND Isnull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')                      -- 11/18/2011 NQIAO PTS 58978
   AND isnull(trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')      -- 11/18/2011 NQIAO PTS 58978
   AND t.PrivateRestriction IS NULL --PTS 93857 SPN
   -- PTS 14932 - DJM - Removed the commented SQL
   --AND t.trk_number = (Select min(trk_number) FROM tariffkey c
   -- WHERE c.tar_number = t.tar_number)
/*   PTS 16010 DPETE Found this also eliminates keys with different candidate trip types
     or regions whihc may qualify only after inspection
   PTS 14932 - DJM - Added the following SQL to remove duplicate rows.  Donna
   added the above SQL for PTS 12047.  This fixed the problem of duplicate rows
   found for the same Rate if the Indexes were not specific enough,  but had the
   side affect of preventing any index other than the first from being found. Added the
   SQL below to remove any duplicates for pts 12047 and removed the limitation above so that
   all the indexes are included in the original search.
   Delete from #temp
   where exists (select b.* from #temp b
         where #temp.tar_number = b.tar_number
            and b.trk_number <> #temp.trk_number)
      and #temp.trk_number > (select min(trk_number) from #temp c where #temp.tar_number = c.tar_number)
*/

SELECT DISTINCT *
from #temp

GO
GRANT EXECUTE ON  [dbo].[d_tar_gettarkeys_li] TO [public]
GO
