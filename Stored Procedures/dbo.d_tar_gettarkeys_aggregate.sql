SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*   MODIFICATION
   LOR   PTS# 43680  created
   NQIAO PTS# 63181 01/31/13 - add 2 more fields in table #temp
   NOKE PTS 63450 added group rating
   SPN NSUITE200443 01/24/2017 - MileageTable increased to CHAR(2)
*/

CREATE PROC [dbo].[d_tar_gettarkeys_aggregate]
   @tarnum int,
   @billdate datetime,
   @billto char(8),
   @itemcode char(6),
   @revtype1 char(6),
   @revtype2 char(6),
   @revtype3 char(6),
   @revtype4 char(6),
   @dbs_type VARCHAR(6),
   @dbs_group VARCHAR(6)      --PTS63450 NLOKE
as

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
   trk_minweight decimal(19,4) null,
   trk_maxweight decimal(19,4) null,
   trk_wgtunit varchar(6) null,
   trk_minpieces int null,
   trk_maxpieces int null,
   trk_countunit varchar(6) null,
   trk_minvolume decimal(19,4) null,
   trk_maxvolume decimal(19,4) null,
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
   billto_othertype1 varchar(6) null,
   billto_othertype2 varchar(6) null,
   masterordernumber varchar(12) null,
   trk_index_factor decimal(19,6) null,
   trk_usefor_billable  int   null,
   trk_dbs_type      VARCHAR(6) NULL,
   tar_orderstoapply int      null,    -- 08/18/2012 NQIAO PTS 63181
   tar_ordersremaining int    null,    -- 08/18/2012 NQIAO PTS 63181
   trk_dbs_group     VARCHAR(6) NULL      -- 3/4/2013 NLOKE 63450
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
   cht_itemcode = ISNULL(th.cht_itemcode,'UNK'),
        t.trk_stoptype,
        t.trk_delays,
        t.trk_carryins1,
        t.trk_carryins2,
        t.trk_ooamileage,
        t.trk_ooastop ,
   IsNull(t.trk_minmaxmiletype,0),
   t.trk_terms,
   ISNULL(t.trk_triptype_or_region,'X'),
   ISNULL(t.trk_tt_or_oregion,''),
   ISNULL(t.trk_dregion,''),
   t.cmp_mastercompany,
   0, -- set the seq to zero taa_seq from tariffaccessorial not used here
   t.trk_mileagetable,
   t.trk_fueltableid,
   t.trk_minrevpermile,
   t.trk_maxrevpermile ,
   t.trk_stp_event   ,
   trk_minvariance,
   trk_maxvariance,
   isNull(t.trk_originsvccenter,'UNK'),
   isNull(t.trk_originsvcregion,'UNK'),
   isNull(t.trk_destsvccenter,'UNK'),
   isNull(t.trk_destsvcregion,'UNK'),
   isNull(t.billto_othertype1,'UNK'),
   isNull(t.billto_othertype2,'UNK'),
   isnull(t.masterordernumber,''),
   t.trk_index_factor,
   t.trk_usefor_billable,
   ISNULL(t.trk_dbs_type, 'UNK'),
   isnull(th.tar_orderstoapply, 0),    -- 63181
   0,                            -- 63181
   ISNULL(t.trk_dbs_group, 'UNK')         -- 3/4/2013 NLOKE 63450
    FROM tariffkey t, tariffheader th
   WHERE t.tar_number = th.tar_number AND
   t.trk_startdate <= @billdate AND
   t.trk_enddate >= @billdate AND
   t.trk_billto in (@billto, 'UNKNOWN') AND
   t.trk_primary = 'A' AND
   IsNull(th.cht_itemcode,'UNK') in (@itemcode, 'UNK') AND
   t.trk_revtype1 in (@revtype1, 'UNK') AND
   t.trk_revtype2 in (@revtype2, 'UNK') AND
   t.trk_revtype3 in (@revtype3, 'UNK') AND
   t.trk_revtype4 in (@revtype4, 'UNK') AND
   ISNULL(t.trk_dbs_type, 'UNK') IN (@dbs_type, 'UNK') AND
   ISNULL(t.trk_dbs_group, 'UNK') IN (@dbs_group, 'UNK') --PTS 63450 nloke

-- 63181 <start>
UPDATE   #temp
SET      tar_ordersremaining = tar_orderstoapply - (SELECT COUNT(rol_tar_number) from rate_order_list where rol_tar_number = #temp.tar_number)
FROM  #temp

-- delete rate(s) having tar_orderstoapply > 0 and tar_ordersremaining = 0 that are no longer available to apply
DELETE   FROM #temp
WHERE tar_orderstoapply > 0
AND      tar_ordersremaining = 0
-- 63181 <end>

SELECT DISTINCT * from #temp

GO
GRANT EXECUTE ON  [dbo].[d_tar_gettarkeys_aggregate] TO [public]
GO
