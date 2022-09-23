SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*   MODIFICATION

 changed to return all columns 2/2 99

DPETE PTS12047 10/5/01 when multiple indexes apply on a secondary charge the rate pulls multiple times.  Added
   AND trk_number = (Select min(trk_number) FROM tariffkey c
      WHERE c.tar_number = t.tar_number)
  to retrieve for secondary charges
LOR   27446 add minvariance, maxvariance

PTS 26793 (recode 20297) - DJM - Add the Localization setting of Origin/Desitnation service_center and service_region to the
   tariffkey parameters.
* 11/19/2007 PTS 38811 JDS:  mod 4 cols from INT  to Dec(19,4)
* SPN NSUITE200443 01/24/2017 - MileageTable increased to CHAR(2)
*/
CREATE PROC [dbo].[d_tar_gettarkeys_taxes]
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
   @retrieveby char(1), --this argument is ignored here. Kept to keep the retrieval consistent
        @terms   varchar(6),  --this argument is ignored here. Kept to keep the retrieval consistent
        @custdoc int,
   @origin_servicecenter   varchar(6),
   @origin_serviceregion   varchar(6),
   @dest_servicecenter  varchar(6),
   @dest_serviceregion  varchar(6)
   , @trk_ratemode         varchar(6)
, @trk_servicelevel     varchar(6)
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
If @itemcode Is Null Or @itemcode = ''
   SET @itemcode = 'UNK'
If @pytitemcode Is Null Or @pytitemcode = ''
   SET @pytitemcode = 'UNK'



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
   trk_minweight  decimal(19,4) null,     -- PTS 38811
   trk_maxweight  decimal(19,4) null,     -- PTS 38811
   --trk_minweight int null,
   --trk_maxweight int null,
   trk_wgtunit varchar(6) null,
   trk_minpieces int null,
   trk_maxpieces int null,
   trk_countunit varchar(6) null,
   trk_minvolume  decimal(19,4) null,     -- PTS 38811
   trk_maxvolume  decimal(19,4) null,     -- PTS 38811
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
   trk_terms char(6) null,
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
        trk_custdoc int null,
        trk_billtoregion varchar(10) null,
   trk_minvariance money null,
   trk_maxvariance money null,
   trk_originsvccenter  varchar(6) null,
   trk_originsvcregion  varchar(6) null,
   trk_destsvccenter varchar(6) null,
   trk_destsvcregion varchar(6) null
   , trk_ratemode             varchar(6) null
, trk_servicelevel         varchar(6) null
)



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
      t.trl_type2,
      t.trl_type3,
      t.trl_type4,
      t.trk_revtype1,
      t.trk_revtype2,
      t.trk_revtype3,
      t.trk_revtype4,
      t.trk_originpoint,
      t.trk_origincity,

      t.trk_originzip,
      t.trk_origincounty,
      t.trk_originstate,
      t.trk_destpoint,
      t.trk_destcity,
      t.trk_destzip,
      t.trk_destcounty,
      t.trk_deststate,
      t.trk_duplicateseq,
      t.trk_company,
      t.trk_carrier,
      t.trk_lghtype1,
      t.trk_load,
      t.trk_team,
      t.trk_boardcarrier,
      t.trk_minmiles,
      t.trk_maxmiles,
      t.trk_distunit,
      t.trk_minweight,
      t.trk_maxweight,
      t.trk_wgtunit,
      t.trk_minpieces,
      t.trk_maxpieces,
      t.trk_countunit,
      t.trk_minvolume,
      t.trk_maxvolume,

      t.trk_volunit,
      t.trk_minodmiles,
      t.trk_maxodmiles,
      t.trk_odunit,
      mpp_type1 = ISNULL(t.mpp_type1,'UNK'),
      mpp_type2 = ISNULL(t.mpp_type2,'UNK'),
      mpp_type3 = ISNULL(t.mpp_type3,'UNK'),
      mpp_type4 = ISNULL(t.mpp_type4,'UNK'),
      trc_type1 = ISNULL(t.trc_type1,'UNK'),
      trc_type2 = ISNULL(t.trc_type2,'UNK'),
      trc_type3 = ISNULL(t.trc_type3,'UNK'),
      trc_type4 = ISNULL(t.trc_type4,'UNK'),
      cht_itemcode = ISNULL(t.cht_itemcode,'UNK'),
                t.trk_stoptype,
                t.trk_delays,
                t.trk_carryins1,
                t.trk_carryins2,
                t.trk_ooamileage,
                t.trk_ooastop,
      IsNull(t.trk_minmaxmiletype,0),
      IsNull(t.trk_terms,'UNK'),
      ISNULL(t.trk_triptype_or_region,'X'),
      ISNULL(t.trk_tt_or_oregion,''),
      ISNULL(t.trk_dregion,''),
      t.cmp_mastercompany,
      0, -- set the seq to zero taa_seq from tariffaccessorial not used here
      t.trk_mileagetable,
      t.trk_fueltableid,
      t.trk_minrevpermile,
      t.trk_maxrevpermile,
      t.trk_stp_event,
      trk_custdoc,
      trk_billtoregion ,
      trk_minvariance,
      trk_maxvariance,
      t.trk_originsvccenter,
      t.trk_originsvcregion,
      t.trk_destsvccenter,
      t.trk_destsvcregion
   , isnull(t.trk_ratemode, 'UNK')     trk_ratemode
     , isnull(t.trk_servicelevel, 'UNK') trk_servicelevel
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
   t.trk_primary = 'T' AND
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
        (IsNull(t.cht_itemcode,'UNK') = @itemcode OR @itemcode = 'UNK') AND
   (IsNull(th.cht_itemcode,'UNK') = @pytitemcode OR @pytitemcode = 'UNK')AND
   t.tar_number = th.tar_number AND
        ISNULL(t.trk_stoptype, 'UNK') in (@stoptype, 'UNK') AND
        ISNULL(t.trk_delays, 'UNK') in (@delays, 'UNK') AND
        ISNULL(t.trk_carryins1, 0) in (@tcarryins1, 0) AND
        ISNULL(t.trk_carryins2, 0) in (@tcarryins2, 0) AND
        ISNULL(t.trk_ooamileage, 0) in (@tooamileage, 0) AND
        ISNULL(t.trk_ooastop , 0) in (@tooastop, 0)
   AND t.trk_number = (Select min(trk_number) FROM tariffkey c
      WHERE c.tar_number = t.tar_number)
        AND ISNULL(t.trk_custdoc, 0) = @custdoc AND t.trk_primary = 'T'
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@origin_serviceregion, 'UNK')
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_originsvccenter, 'UNK') in (@dest_servicecenter, 'UNK')
   AND Isnull(t.trk_ratemode, 'UNK') in (@trk_ratemode, 'UNK')
   AND Isnull(t.trk_servicelevel,'UNK') in (@trk_servicelevel, 'UNK')

SELECT DISTINCT *
from #temp

GO
GRANT EXECUTE ON  [dbo].[d_tar_gettarkeys_taxes] TO [public]
GO
