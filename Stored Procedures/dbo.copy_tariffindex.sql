SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[copy_tariffindex]
      (@cmp_id    varchar(8),
      @new_cmp_id    varchar(8),
      @billto_flag   char(1),
      @parent_flag   char(1)
)
AS

/* Change Control
   LOR   PTS# 46016  created
*/

CREATE TABLE #xref (
   x_id           INTEGER IDENTITY(1,1) NOT null,
   tar_number        INTEGER  NOT null,
   trk_number        int not null,
   trk_indexseq      int null,
   new_trk_number    INTEGER null,
   new_trk_indexseq  int null)

declare @newnbr_start   int,
      @min_id        INT,
      @count         int

If @billto_flag = 'Y' and @parent_flag = 'Y'
   SELECT @count = count(*)
   FROM tariffkey
   WHERE (trk_billto = @cmp_id or cmp_mastercompany = @cmp_id) and tar_number in (select tar_number from tariffheader)
Else
Begin
   If @parent_flag = 'N'
      SELECT @count = count(*)
      FROM tariffkey
      WHERE trk_billto = @cmp_id and tar_number in (select tar_number from tariffheader)
   Else     --@billto_flag = 'N'
      SELECT @count = count(*)
      FROM tariffkey
      WHERE cmp_mastercompany = @cmp_id and tar_number in (select tar_number from tariffheader)
End

EXEC @newnbr_start = getsystemnumberblock 'TARKEY', null, @count

INSERT INTO #xref (tar_number, trk_number, trk_indexseq)
SELECT   tar_number, trk_number, IsNull(trk_indexseq, 1)
FROM tariffkey
WHERE ((trk_billto = @cmp_id and @billto_flag = 'Y') or (cmp_mastercompany = @cmp_id and @parent_flag = 'Y')) AND
         tar_number in (select tar_number from tariffheader) order by tar_number, trk_number, trk_indexseq

UPDATE   #xref
SET   new_trk_number = (@newnbr_start + (x_id - 1)),
   new_trk_indexseq = ((select max(trk_indexseq) from #xref x where #xref.tar_number = x.tar_number  group by tar_number) + trk_indexseq)

SELECT   @min_id = MIN(x_id) FROM #xref

WHILE ISnull(@min_id, 0) > 0
BEGIN
         insert into tariffkey(
               trk_number,
               trk_description,
               tar_number,
               trk_startdate,
               trk_enddate,
               trk_billto,
               cmp_othertype1,
               cmp_othertype2,
               cmd_code,
               cmd_class,
               trl_type1,
               trl_type2,
               trl_type3,
               trl_type4,
               trk_revtype1,
               trk_revtype2,
               trk_revtype3,
               trk_revtype4,
               trk_originpoint,
               trk_origincity,
               trk_originzip,
               trk_originstate,
               trk_destpoint,
               trk_destcity,
               trk_destzip,
               trk_deststate,
               trk_minmiles,
               trk_minweight,
               trk_minpieces,
               trk_minvolume,
               trk_maxmiles,
               trk_maxweight,
               trk_maxpieces,
               trk_maxvolume,
               trk_duplicateseq,
               --timestamp
               trk_primary,
               trk_minstops,
               trk_maxstops,
               trk_minodmiles,
               trk_maxodmiles,
               trk_minvariance,
               trk_maxvariance,
               trk_orderedby,
               trk_minlength,
               trk_maxlength,
               trk_minwidth,
               trk_maxwidth,
               trk_minheight,
               trk_maxheight,
               trk_origincounty,
               trk_destcounty,
               trk_company,
               trk_carrier,
               trk_lghtype1,
               trk_load,
               trk_team,
               trk_boardcarrier,
               trk_distunit,
               trk_wgtunit,
               trk_countunit,
               trk_volunit,
               trk_odunit,
               mpp_type1,
               mpp_type2,
               mpp_type3,
               mpp_type4,
               trc_type1,
               trc_type2,
               trc_type3,
               trc_type4,
               cht_itemcode,
               trk_stoptype,
               trk_delays,
               trk_ooamileage,
               trk_ooastop,
               trk_carryins1,
               trk_carryins2,
               trk_minmaxmiletype,
               trk_terms,
               trk_triptype_or_region,
               trk_tt_or_oregion,
               trk_dregion,
               cmp_mastercompany,
               trk_mileagetable,
               trk_fueltableid,
               trk_minrevpermile,
               trk_maxrevpermile,
               trk_indexseq,
               trk_stp_event,
               trk_return_billto,
               trk_return_revtype1,
               last_updateby,
               last_updatedate,
               trk_custdoc,
               trk_billtoregion,
               trk_partytobill,
               trk_partytobill_id,
               tch_id,
               rth_id,
               trk_thirdparty,
               trk_originsvccenter,
               trk_originsvcregion,
               trk_destsvccenter,
               trk_destsvcregion,
               trk_lghtype2,
               trk_lghtype3,
               trk_lghtype4,
               trk_thirdpartytype,
               trk_minsegments,
               trk_maxsegments,
               billto_othertype1,
               billto_othertype2,
               masterordernumber,
               mpp_id,
               mpp_payto,
               trc_number,
               trc_owner,
               trl_number,
               trl_owner,
               pto_id,
               mpp_terminal,
               trc_terminal,
               trl_terminal,
               trk_primary_driver,
               stop_othertype1,
               stop_othertype2,
               trk_index_factor,
               trk_mintime,
               trk_billto_car_key,
               trk_usefor_billable,
               trk_mincarriersvcdays,
               trk_maxcarriersvcdays,
               trk_route,
               trk_trl_company ,
               trk_trl_fleet,
               trk_trl_division,
               trk_trc_company,
               trk_trc_fleet,
               trk_trc_division,
               trk_mpp_company,
               trk_mpp_fleet,
               trk_mpp_division,
               trk_mpp_domicile,
               trk_mpp_teamleader,
               trk_pallet_type,
               trk_pallet_count,
               trk_ratemode,     /* 11/18/2011 NQIAO PTS 58978 */
               trk_servicelevel  /* 11/18/2011 NQIAO PTS 58978 */
             , trk_touraware
             )
         SELECT new_trk_number trk_number,
            trk_description,
            t.tar_number,
            trk_startdate,
            trk_enddate,
            Case when trk_billto = @cmp_id and @billto_flag = 'Y' then @new_cmp_id else trk_billto end trk_billto,
            cmp_othertype1,
            cmp_othertype2,
            cmd_code,
            cmd_class,
            trl_type1,
            trl_type2,
            trl_type3,
            trl_type4,
            trk_revtype1,
            trk_revtype2,
            trk_revtype3,
            trk_revtype4,
            trk_originpoint,
            trk_origincity,
            trk_originzip,
            trk_originstate,
            trk_destpoint,
            trk_destcity,
            trk_destzip,
            trk_deststate,
            trk_minmiles,
            trk_minweight,
            trk_minpieces,
            trk_minvolume,
            trk_maxmiles,
            trk_maxweight,
            trk_maxpieces,
            trk_maxvolume,
            trk_duplicateseq,
            --timestamp
            trk_primary,
            trk_minstops,
            trk_maxstops,
            trk_minodmiles,
            trk_maxodmiles,
            trk_minvariance,
            trk_maxvariance,
            trk_orderedby,
            trk_minlength,
            trk_maxlength,
            trk_minwidth,
            trk_maxwidth,
            trk_minheight,
            trk_maxheight,
            trk_origincounty,
            trk_destcounty,
            trk_company,
            trk_carrier,
            trk_lghtype1,
            trk_load,
            trk_team,
            trk_boardcarrier,
            trk_distunit,
            trk_wgtunit,
            trk_countunit,
            trk_volunit,
            trk_odunit,
            mpp_type1,
            mpp_type2,
            mpp_type3,
            mpp_type4,
            trc_type1,
            trc_type2,
            trc_type3,
            trc_type4,
            cht_itemcode,
            trk_stoptype,
            trk_delays,
            trk_ooamileage,
            trk_ooastop,
            trk_carryins1,
            trk_carryins2,
            trk_minmaxmiletype,
            trk_terms,
            trk_triptype_or_region,
            trk_tt_or_oregion,
            trk_dregion,
            Case when cmp_mastercompany = @cmp_id and @parent_flag = 'Y' then @new_cmp_id else cmp_mastercompany end cmp_mastercompany,
            trk_mileagetable,
            trk_fueltableid,
            trk_minrevpermile,
            trk_maxrevpermile,
            new_trk_indexseq trk_indexseq,
            trk_stp_event,
            trk_return_billto,
            trk_return_revtype1,
            'COPYCOMPPROC' last_updateby,
            getdate() last_updatedate,
            trk_custdoc,
            trk_billtoregion,
            trk_partytobill,
            trk_partytobill_id,
            tch_id,
            rth_id,
            trk_thirdparty,
            trk_originsvccenter,
            trk_originsvcregion,
            trk_destsvccenter,
            trk_destsvcregion,
            trk_lghtype2,
            trk_lghtype3,
            trk_lghtype4,
            trk_thirdpartytype,
            trk_minsegments,
            trk_maxsegments,
            billto_othertype1,
            billto_othertype2,
            masterordernumber,
            mpp_id,
            mpp_payto,
            trc_number,
            trc_owner,
            trl_number,
            trl_owner,
            pto_id,
            mpp_terminal,
            trc_terminal,
            trl_terminal,
            trk_primary_driver,
            stop_othertype1,
            stop_othertype2,
            trk_index_factor,
            trk_mintime,
            trk_billto_car_key,
            trk_usefor_billable,
            trk_mincarriersvcdays,
            trk_maxcarriersvcdays,
            trk_route,
            trk_trl_company ,
            trk_trl_fleet,
            trk_trl_division,
            trk_trc_company,
            trk_trc_fleet,
            trk_trc_division,
            trk_mpp_company,
            trk_mpp_fleet,
            trk_mpp_division,
            trk_mpp_domicile,
            trk_mpp_teamleader,
            trk_pallet_type,
            trk_pallet_count,
            trk_ratemode,     /* 11/18/2011 NQIAO PTS 58978 */
            trk_servicelevel  /* 11/18/2011 NQIAO PTS 58978 */
          , trk_touraware
   FROM  #xref x INNER JOIN tariffkey t ON x.trk_number = t.trk_number
   WHERE x.x_id = @min_id

   SELECT   @min_id = MIN(x_id)
   FROM  #xref
   WHERE x_id > @min_id
END

SELECT   tar_number, trk_indexseq, trk_billto, cmp_mastercompany
FROM tariffkey
WHERE trk_number in (select new_trk_number from #xref)

drop table #xref

GO
GRANT EXECUTE ON  [dbo].[copy_tariffindex] TO [public]
GO
