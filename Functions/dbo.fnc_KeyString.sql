SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[fnc_KeyString](@trk_number int)

returns varchar(2000)
as
begin

declare @KeyString as varchar(2000)
--declare @trk_number as int

--set @trk_number = 106
set @KeyString = ''

if (select trk_billto from tariffkey where trk_number = @trk_number) <> 'UNKNOWN'
 set @KeyString = @KeyString + 'Billto: '  + (select trk_billto from tariffkey where trk_number = @trk_number)

if (select cmp_othertype1 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Cmp Other Type1: ' + (select cmp_othertype1 from tariffkey where trk_number = @trk_number)

if (select cmp_othertype2 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Cmp Other Type2: ' + (select cmp_othertype2 from tariffkey where trk_number = @trk_number)

if (select cmd_code from tariffkey where trk_number = @trk_number) <> 'UNKNOWN'
 set @KeyString = @KeyString + ' Commodity Code: ' + (select cmd_code from tariffkey where trk_number = @trk_number)

if (select cmd_class from tariffkey where trk_number = @trk_number) <> 'UNKNOWN'
 set @KeyString = @KeyString + ' Commodity Class: ' + (select cmd_class from tariffkey where trk_number = @trk_number)

if (select trl_type1 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Trl Type1: ' + (select trl_type1 from tariffkey where trk_number = @trk_number)

if (select trl_type2 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Trl Type2: ' + (select trl_type2 from tariffkey where trk_number = @trk_number)

if (select trl_type3 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Trl Type3: ' + (select trl_type3 from tariffkey where trk_number = @trk_number)

if (select trl_type4 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Trl Type4: ' + (select trl_type4 from tariffkey where trk_number = @trk_number)

if (select trk_revtype1 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Rev Type1: ' + (select trk_revtype1 from tariffkey where trk_number = @trk_number)

if (select trk_revtype2 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Rev Type2: ' + (select trk_revtype2 from tariffkey where trk_number = @trk_number)

if (select trk_revtype3 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Rev Type3: ' + (select trk_revtype3 from tariffkey where trk_number = @trk_number)

if (select trk_revtype4 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Rev Type4: ' + (select trk_revtype4 from tariffkey where trk_number = @trk_number)

if (select trk_originpoint from tariffkey where trk_number = @trk_number) <> 'UNKNOWN'
 set @KeyString = @KeyString + ' Origin Point: ' + (select trk_originpoint from tariffkey where trk_number = @trk_number)

if (select trk_origincity from tariffkey where trk_number = @trk_number) <> 0
 set @KeyString = @KeyString + ' Origin City: ' + (select cty_name from city where cty_code = (
         select trk_origincity from tariffkey where trk_number = @trk_number))

if (select trk_originstate from tariffkey where trk_number = @trk_number) <> 'XX'
 set @KeyString = @KeyString + ' Origin State: ' + (select trk_originstate from tariffkey where trk_number = @trk_number)

if (select trk_originzip from tariffkey where trk_number = @trk_number) <> 'UNKNOWN'
 set @KeyString = @KeyString + ' Origin Zip: ' + (select trk_originzip from tariffkey where trk_number = @trk_number)


if (select trk_destpoint from tariffkey where trk_number = @trk_number) <> 'UNKNOWN'
 set @KeyString = @KeyString + ' Dest Point: ' + (select trk_destpoint from tariffkey where trk_number = @trk_number)

if (select trk_destcity from tariffkey where trk_number = @trk_number) <> 0
 set @KeyString = @KeyString + ' Dest City: ' + (select cty_name from city where cty_code = (
         select trk_destcity from tariffkey where trk_number = @trk_number))

if (select trk_deststate from tariffkey where trk_number = @trk_number) <> 'XX'
 set @KeyString = @KeyString + ' Dest State: ' + (select trk_deststate from tariffkey where trk_number = @trk_number)

if (select trk_destzip from tariffkey where trk_number = @trk_number) <> 'UNKNOWN'
 set @KeyString = @KeyString + ' Dest Zip: ' + (select trk_destzip from tariffkey where trk_number = @trk_number)

if (select trk_minmiles from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min Miles: ' + str((select trk_minmiles from tariffkey where trk_number = @trk_number))

if (select trk_minweight from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min Weight: ' + str((select trk_minweight from tariffkey where trk_number = @trk_number))

if (select trk_minpieces from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min Pieces: ' + str((select trk_minpieces from tariffkey where trk_number = @trk_number))

if (select trk_minvolume from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min Volume: ' + str((select trk_minvolume from tariffkey where trk_number = @trk_number))


if (select trk_Maxmiles from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max Miles: ' + str((select trk_Maxmiles from tariffkey where trk_number = @trk_number))

if (select trk_Maxweight from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max Weight: ' + str((select trk_Maxweight from tariffkey where trk_number = @trk_number))

if (select trk_Maxpieces from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max Pieces: ' + str((select trk_Maxpieces from tariffkey where trk_number = @trk_number))

if (select trk_Maxvolume from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max Volume: ' + str((select trk_Maxvolume from tariffkey where trk_number = @trk_number))

if (select trk_minstops from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min Stops: ' + str((select trk_minstops from tariffkey where trk_number = @trk_number))

if (select trk_maxstops from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max Stops: ' + str((select trk_maxstops from tariffkey where trk_number = @trk_number))


if (select trk_minodmiles from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min OD Miles: ' + str((select trk_minodmiles from tariffkey where trk_number = @trk_number))

if (select trk_maxodmiles from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max OD Miles: ' + str((select trk_maxodmiles from tariffkey where trk_number = @trk_number))

if (select trk_minVariance from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min Variance: ' + str((select trk_minVariance from tariffkey where trk_number = @trk_number))

if (select trk_maxVariance from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max Variance: ' + str((select trk_maxVariance from tariffkey where trk_number = @trk_number))

if (select trk_minLength from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min Length: ' + str((select trk_minLength from tariffkey where trk_number = @trk_number))

if (select trk_maxLength from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max Length: ' + str((select trk_maxLength from tariffkey where trk_number = @trk_number))

if (select trk_minwidth from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min width: ' + str((select trk_minwidth from tariffkey where trk_number = @trk_number))

if (select trk_maxwidth from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max width: ' + str((select trk_maxwidth from tariffkey where trk_number = @trk_number))

if (select trk_minHeight from tariffkey where trk_number = @trk_number) > 0
 set @KeyString = @KeyString + ' Min Height: ' + str((select trk_minHeight from tariffkey where trk_number = @trk_number))

if (select trk_maxHeight from tariffkey where trk_number = @trk_number) < 2147483647
 set @KeyString = @KeyString + ' Max Height: ' + str((select trk_maxHeight from tariffkey where trk_number = @trk_number))

if (select trk_origincounty from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Origin County: ' + (select trk_origincounty from tariffkey where trk_number = @trk_number)

if (select trk_Destcounty from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Dest County: ' + (select trk_destcounty from tariffkey where trk_number = @trk_number)

if (select trk_company from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Company: ' + (select trk_company from tariffkey where trk_number = @trk_number)

if (select trk_carrier from tariffkey where trk_number = @trk_number) <> 'UNKNOWN'
 set @KeyString = @KeyString + ' Carrier: ' + (select trk_Carrier from tariffkey where trk_number = @trk_number)

if (select trk_lghtype1 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' LGH Type1: ' + (select trk_lghtype1 from tariffkey where trk_number = @trk_number)

if (select trk_load from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Load: ' + (select trk_Load from tariffkey where trk_number = @trk_number)

if (select trk_team from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Team: ' + (select trk_team from tariffkey where trk_number = @trk_number)

if (select trk_boardcarrier from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Board Carrier: ' + (select trk_boardcarrier from tariffkey where trk_number = @trk_number)

--if (select trk_distunit from tariffkey where trk_number = @trk_number) <> 'UNK'
-- set @KeyString = @KeyString + ' Dist Unit: ' + (select trk_distunit from tariffkey where trk_number = @trk_number)
--if (select trk_wgtunit from tariffkey where trk_number = @trk_number) <> 'UNK'
-- set @KeyString = @KeyString + ' Weight Unit: ' + (select trk_wgtunit from tariffkey where trk_number = @trk_number)
--if (select trk_countunit from tariffkey where trk_number = @trk_number) <> 'UNK'
-- set @KeyString = @KeyString + ' Count Unit: ' + (select trk_countunit from tariffkey where trk_number = @trk_number)
--if (select trk_volunit from tariffkey where trk_number = @trk_number) <> 'UNK'
-- set @KeyString = @KeyString + ' Vol Unit: ' + (select trk_volunit from tariffkey where trk_number = @trk_number)

if (select mpp_type1 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Drv Type1: ' + (select mpp_type1 from tariffkey where trk_number = @trk_number)
if (select mpp_type2 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Drv Type2: ' + (select mpp_type2 from tariffkey where trk_number = @trk_number)
if (select mpp_type3 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Drv Type3: ' + (select mpp_type3 from tariffkey where trk_number = @trk_number)
if (select mpp_type4 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Drv Type4: ' + (select mpp_type4 from tariffkey where trk_number = @trk_number)

if (select trc_type1 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Trc Type1: ' + (select trc_type1 from tariffkey where trk_number = @trk_number)
if (select trc_type2 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Trc Type2: ' + (select trc_type2 from tariffkey where trk_number = @trk_number)
if (select trc_type3 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Trc Type3: ' + (select trc_type3 from tariffkey where trk_number = @trk_number)
if (select trc_type4 from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Trc Type4: ' + (select trc_type4 from tariffkey where trk_number = @trk_number)

if (select trk_stoptype from tariffkey where trk_number = @trk_number) <> 'UNK'
 set @KeyString = @KeyString + ' Stop Type: ' + (select trk_stoptype from tariffkey where trk_number = @trk_number)


return ltrim(@KeyString)
end


--  select dbo.fnc_KeyString(trk_number) from tariffkey


--  trk_orderedby,
----  cht_itemcode, trk_stoptype, trk_delays, trk_ooamileage, trk_ooastop, trk_carryins1, trk_carryins2, \
--trk_terms, trk_minmaxmiletype, trk_minrevpermile, trk_maxrevpermile, trk_triptype_or_region, trk_tt_or_oregion, 
--trk_dregion, cmp_mastercompany, trk_mileagetable, trk_fueltableid, trk_indexseq, trk_stp_event, trk_return_billto, 
--trk_return_revtype1, last_updateby, last_updatedate, trk_custdoc, trk_billtoregion, trk_partytobill, trk_partytobill_id,
-- tch_id, rth_id, trk_originsvccenter, trk_originsvcregion, trk_destsvccenter, trk_destsvcregion,
-- trk_lghtype2, trk_lghtype3, trk_lghtype4, trk_thirdparty, trk_thirdpartytype, trk_minsegments,
-- trk_maxsegments, billto_othertype1, billto_othertype2, masterordernumber, mpp_id, mpp_payto, trc_number, trc_owner, 
--trl_number, trl_owner, pto_id, mpp_terminal, trc_terminal, trl_terminal, trk_primary_driver, trk_index_factor, 
--stop_othertype1, stop_othertype2, trk_mintime, trk_billto_car_key


--- trk_description, tar_number, trk_startdate, trk_enddate, trk_billto, cmp_othertype1, cmp_othertype2, cmd_code, cmd_class, trl_type1, trl_type2, trl_type3, trl_type4, trk_revtype1, trk_revtype2, trk_revtype3, trk_revtype4, trk_originpoint, trk_origincity, trk_originzip, trk_originstate, trk_destpoint, trk_destcity, trk_destzip, trk_deststate, trk_minmiles, trk_minweight, trk_minpieces, trk_minvolume, trk_maxmiles, trk_maxweight, trk_maxpieces, trk_maxvolume, trk_duplicateseq, timestamp, trk_primary, trk_minstops, trk_maxstops, trk_minodmiles, trk_maxodmiles, trk_minvariance, trk_maxvariance, trk_orderedby, trk_minlength, trk_maxlength, trk_minwidth, trk_maxwidth, trk_minheight, trk_maxheight, trk_origincounty, trk_destcounty, trk_company, trk_carrier, trk_lghtype1, trk_load, trk_team, trk_boardcarrier, trk_distunit, trk_wgtunit, trk_countunit, trk_volunit, trk_odunit, mpp_type1, mpp_type2, mpp_type3, mpp_type4, trc_type1, trc_type2, trc_type3, trc_type4, cht_itemcode, trk_stoptype, trk_delays, trk_ooamileage, trk_ooastop, trk_carryins1, trk_carryins2, trk_terms, trk_minmaxmiletype, trk_minrevpermile, trk_maxrevpermile, trk_triptype_or_region, trk_tt_or_oregion, trk_dregion, cmp_mastercompany, trk_mileagetable, trk_fueltableid, trk_indexseq, trk_stp_event, trk_return_billto, trk_return_revtype1, last_updateby, last_updatedate, trk_custdoc, trk_billtoregion, trk_partytobill, trk_partytobill_id, tch_id, rth_id, trk_originsvccenter, trk_originsvcregion, trk_destsvccenter, trk_destsvcregion, trk_lghtype2, trk_lghtype3, trk_lghtype4, trk_thirdparty, trk_thirdpartytype, trk_minsegments, trk_maxsegments, billto_othertype1, billto_othertype2, masterordernumber, mpp_id, mpp_payto, trc_number, trc_owner, trl_number, trl_owner, pto_id, mpp_terminal, trc_terminal, trl_terminal, trk_primary_driver, trk_index_factor, stop_othertype1, stop_othertype2, trk_mintime, trk_billto_car_key
-- select * from tariffkey
GO
