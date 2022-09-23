SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ReLoadExternalEquipment_sp] (@lgh_number int)
AS

DECLARE @ExternalEquipAutoReload char(1) 
DECLARE @AvailableDateOffsetMinutes int

--insert and adjust source record
SELECT	@ExternalEquipAutoReload = gi_string1, 
		@AvailableDateOffsetMinutes = gi_integer1
FROM generalinfo
WHERE gi_name = 'ExternalEquipAutoReload'


IF @ExternalEquipAutoReload = 'Y' BEGIN

	--Set location to prior trip destination.

	--Set available  delivery time + offset

	INSERT INTO [external_equipment](
				[ete_source]
			   ,[ete_sourcerefnumber]
			   ,[ete_origlocation]
			   ,[ete_origcity]
			   ,[ete_origstate]
			   ,[ete_origzip]
			   ,[ete_origlatitude]
			   ,[ete_origlongitude]
			   ,[ete_destlocation]
			   ,[ete_destcity]
			   ,[ete_deststate]
			   ,[ete_destzip]
			   ,[ete_destlatitude]
			   ,[ete_destlongitude]
			   ,[ete_availabledate]
			   ,[ete_postingdate]
			   ,[ete_expirationdate]
			   ,[ete_equipmenttype]
			   ,[ete_loadtype]
			   ,[ete_equipmentlength]
			   ,[ete_loadweight]
			   ,[ete_carrierid]
			   ,[ete_carriername]
			   ,[ete_carrierstate]
			   ,[ete_carriermcnumber]
			   ,[ete_contactname]
			   ,[ete_contactphone]
			   ,[ete_contactaltphone]
			   ,[ete_truckcount]
			   ,[ete_truckid]
			   ,[ete_created]
			   ,[ete_createdby]
			   ,[ete_updated]
			   ,[ete_updatedby]
			   ,[ete_truck_mcnum]
			   ,[ete_driver_name]
			   ,[ete_driver_phone]
			   ,[ete_original_truckcount]
			   ,[ete_status]
			   ,[ete_remarks]
			   ,[ete_mc]
			   ,[ete_originradius]
			   ,[ete_destradius]
		)
		 SELECT 
			   ete_source,
			   ete_sourcerefnumber,
			   ete_origlocation,
			   cty_dest.cty_name as ete_origcity,
			   cty_dest.cty_state as ete_origstate,
			   cty_dest.cty_zip as ete_origzip,
			   cty_dest.cty_latitude as ete_origlatitude,
			   cty_dest.cty_longitude as ete_origlongitude,
			   ete_destlocation,
			   ete_destcity,
			   ete_deststate,
			   ete_destzip,
			   ete_destlatitude,
			   ete_destlongitude,
			   DATEADD(mi, @AvailableDateOffsetMinutes, lgha.lgh_enddate) as ete_availabledate,
			   ete_postingdate,
			   ete_expirationdate,
			   --PTS 48857 JJF 20090903
			   --ete_equipmenttype,
			   ete_equipmenttype = lgha.ord_trl_type1,
			   --END PTS 48857 JJF 20090903
			   ete_loadtype,
			   ete_equipmentlength,
			   ete_loadweight,
			   ete_carrierid,
			   ete_carriername,
			   ete_carrierstate,
			   ete_carriermcnumber,
			   ete_contactname,
			   ete_contactphone,
			   ete_contactaltphone,
			   ete_truckcount,
			   ete_truckid,
			   ete_created,
			   ete_createdby,
			   ete_updated,
			   ete_updatedby,
			   ete_truck_mcnum,
			   ete_driver_name,
			   ete_driver_phone,
			   ete_original_truckcount,
			   'AVL' as ete_status,
			   ete_remarks,
			   ete_mc,
			   ete_originradius,
			   ete_destradius
		FROM	legheader_brokered lghb 
				--PTS 48857 JJF 20090903
				inner join legheader_active lgha on lghb.lgh_number = lgha.lgh_number
				--inner join legheader lgh on lghb.lgh_number = lgh.lgh_number
				--END PTS 48857 JJF 20090903
				inner join external_equipment ete on lghb.lgh_ete_id = ete.ete_id
				inner join city cty_dest on lgha.lgh_endcity = cty_dest.cty_code
		WHERE	lghb.lgh_number = @lgh_number
				AND NOT EXISTS(SELECT ete_id 
								FROM external_equipment ete_dupcheck 
								--PTS 48857 JJF 20090903 - remove equipment type since it now changes upon reload
								WHERE --ete_dupcheck.ete_equipmenttype = ete.ete_equipmenttype
										ete_dupcheck.ete_carrierid = ete.ete_carrierid
										and ete_dupcheck.ete_truckid = ete.ete_truckid
										and ete_dupcheck.ete_status = 'AVL')
										

END


GO
GRANT EXECUTE ON  [dbo].[ReLoadExternalEquipment_sp] TO [public]
GO
