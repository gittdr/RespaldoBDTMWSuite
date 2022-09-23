SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[external_equipment_search_Ops] (
	@carrierFilterViewId		VARCHAR(6),
	@carid						VARCHAR(8),
	@carname					VARCHAR(64),
	@origin					INTEGER,
	@destination			INTEGER,
	@oradius					INTEGER, 	
	@dradius					INTEGER,
	@lgh_number					INTEGER,
	@equipment_type				VARCHAR(25),
	@equipment_type_value		VARCHAR(6),
	@loadType		varchar(10),
	@maxAge	int, 
	@daysback	int,
	@daysahead	int,
	@length	varchar(50),
	@weight		decimal(10,4)
	)
AS

-- Make temp table for results
CREATE TABLE #results (
  ete_id            	int not null, 
  ete_source        	varchar(20) null, 
  ete_sourcerefnumber	varchar(20) null, 
  ete_origlocation  	varchar(8) null, 
  ete_origcity      	varchar(50) null, 
  ete_origstate     	varchar(6) null, 
  ete_origzip   		varchar(10) null, 
  ete_origlatitude      decimal(8, 4) null, 
  ete_origlongitude     decimal(8,4) null, 
  ete_dhmiles_origin	int null, 
  ete_destlocation  	varchar(8) null, 
  ete_destcity      	varchar(50) null, 
  ete_destcitysearch	varchar(50) null, 
  ete_deststate			varchar(6) null, 
  ete_destzip       	varchar(10) null, 
  ete_destlatitude  	decimal(8, 4) null, 
  ete_destlongitude 	decimal(8, 4) null, 
  ete_dhmiles_dest  	int null, 
  ete_availabledate 	datetime null, 
  ete_postingdate   	datetime null, 
  ete_postingage    	varchar(20) null,
  ete_expirationdate	datetime null, 
  ete_equipmenttype 	varchar(25) null, 
  ete_loadtype      	varchar(10) null, 
  ete_equipmentlength	varchar(50) null, 
  ete_loadweight    	decimal(12, 4) null, 
  ete_carrierid	    	varchar(8) null, 
  ete_carriername   	varchar(100) null, 
  ete_carrierstate  	varchar(2) null, 
  ete_carriermcnumber	int null, 
  ete_contactname   	varchar(50) null, 
  ete_contactphone  	varchar(25) null, 
  ete_contactaltphone	varchar(25) null, 
  ete_truckcount    	smallint null, 
  ete_truckid       	varchar(50) null, 
  ete_created       	datetime null, 
  ete_createdby			varchar(128) null, 
  ete_updated       	datetime null, 
  ete_updatedby			varchar(128) null,
  ete_truck_mcnum		varchar(50) null, 
  ete_driver_name		varchar(255) null, 
  ete_driver_phone		varchar(25) null, 
  branch_t		varchar(25) null, 
  branch		varchar(12) null,
  dont_delete	    	char(1) not null default ('N'),
  ete_remarks	varchar(255) null,
  ete_status	varchar(6) null,
  cartype1_t	varchar(20) null,
  cartype2_t	varchar(20) null,
  cartype3_t	varchar(20) null,
  cartype4_t	varchar(20) null,
  car_type1		varchar(6) null,
  car_type2		varchar(6) null,
  car_type3		varchar(6) null,
  car_type4		varchar(6) null,
  ete_mc				varchar(12) null,
	ete_automatch		char(1),
	ete_originradius	int	null,
	ete_destradius		int	null,
	ete_lgh_number		INT NULL
)

create table #temp_filteredcarriers (fcr_carrier varchar(8), keepfromfilter char(1) null)

DECLARE
	@ete_originlat		decimal(10,4),
	@ete_originlong		decimal(10,4),
	@ete_destlat		decimal(10,4),
	@ete_destlong		decimal(10,4),
	@dest_miles		decimal(12,6),
	@branch_t		varchar(25),
	@stp_departure_dt	datetime, 
	@cartype1				VARCHAR(6),
	@cartype2				VARCHAR(6),
	@cartype3				VARCHAR(6),
	@cartype4				VARCHAR(6),
	@liabilitylimit				MONEY,
	@cargolimit				MONEY,
	@rateonly				CHAR(1),
	@insurance				CHAR(1),
	@w9					CHAR(1),
	@contract				CHAR(1),
	@history				CHAR(1),
	@ratesonly				CHAR(1),
	@lgh_booked_revtype1			VARCHAR(256),
	@availableFrom	datetime,
	@availableTo	datetime,
	@originCityNameState		varchar(50),
	@destCityNameState		varchar(50),
	@serviceRating varchar(6)

SET @availableFrom = DATEADD(d,-@daysback, GETDATE())
SET @availableTo = DATEADD(d, @daysahead, GETDATE())
SELECT TOP 1 @originCityNameState =cty_nmstct, @ete_originlat = cty_latitude, @ete_originlong = cty_longitude FROM city WHERE cty_code = @origin
SELECT TOP 1 @destCityNameState = cty_nmstct, @ete_destlat = cty_latitude, @ete_destlong = cty_longitude FROM city WHERE cty_code = @destination

IF @carrierFilterViewId != 'UNK'
BEGIN
SELECT
	@lgh_booked_revtype1 = caf_branch,
	@cartype1 = caf_car_type1, 
	@cartype2=caf_car_type2, 
	@cartype3=caf_car_type3, 
	@cartype4=caf_car_type4, 
	@liabilitylimit=caf_liability_limit, 
	@cargolimit=caf_cargo_limit, 
	@rateonly = caf_rate,
	@insurance = caf_ins_cert,
	@w9 = caf_w9,
	@contract = caf_contract,
	@history = caf_history_only,
	@ratesonly = caf_RateOnFile_only,
	@serviceRating = caf_service_rating 
FROM carrierfilter WHERE caf_viewid = @carrierFilterViewId
 
 END
create table #temp_values (temp_id int identity, value varchar(8))

set @stp_departure_dt = getdate()

BEGIN

IF @lgh_booked_revtype1 IS NULL OR RTRIM(@lgh_booked_revtype1) = '' or @lgh_booked_revtype1 = 'UNKNOWN'
	SELECT @lgh_booked_revtype1 = ''

IF @equipment_type IS NULL OR RTRIM(@equipment_type) = '' BEGIN
	SELECT @equipment_type_value = 'ALL'
	SELECT @equipment_type = 'ALL'
END
IF @equipment_type_value IS NULL OR RTRIM(@equipment_type_value) = '' BEGIN
	SELECT @equipment_type_value = 'ITEM'
END
IF @equipment_type = 'UNKNOWN' BEGIN
	SELECT @equipment_type_value = 'ALL'
	SELECT @equipment_type = 'ALL'
END 

IF @loadType IS NULL OR RTRIM(@loadType) = ''
	SELECT @loadType = 'ALL'

IF @length IS NULL OR RTRIM(@length) = ''
	SELECT @length = 'ALL'

IF @maxAge IS NULL
	SELECT @maxAge = 0

If @maxAge > 0 
	SELECT @maxAge = -1 * @maxAge

select @branch_t = isnull(gi_string3, 'Branch') 
  from generalinfo 
 where gi_name = 'TrackBranch'

-- search external equipment for equipment matching the origin restrictions

INSERT INTO #results (ete_id, ete_source, ete_sourcerefnumber, ete_origlocation, 
				  ete_origcity, ete_origstate, ete_origzip, ete_origlatitude, 
				  ete_origlongitude, ete_dhmiles_origin, ete_destlocation, ete_destcity, 
				  ete_destcitysearch, ete_deststate, ete_destzip, ete_destlatitude, 
				  ete_destlongitude, ete_dhmiles_dest, ete_availabledate, ete_postingdate, 
				  ete_postingage, ete_expirationdate, ete_equipmenttype, ete_loadtype, 
				  ete_equipmentlength, ete_loadweight, ete_carrierid, ete_carriername, 
				  ete_carrierstate, ete_carriermcnumber, ete_contactname, ete_contactphone, 
				  ete_contactaltphone, ete_truckcount, ete_truckid, ete_created, ete_createdby,
				  ete_updated, ete_updatedby, ete_truck_mcnum, ete_driver_name, ete_driver_phone, 
				  branch_t, branch, ete_remarks, ete_status, cartype1_t, cartype2_t, cartype3_t, 
				  cartype4_t, car_type1, car_type2, car_type3, car_type4, ete_mc,
					ete_automatch,
					ete_originradius, 
					ete_destradius,
					ete_lgh_number
			) 
		  (
		  SELECT ete_id, ete_source, ete_sourcerefnumber, ete_origlocation, 
				  ete_origcity, ete_origstate, ete_origzip, ete_origlatitude, 
				  ete_origlongitude, 0, ete_destlocation, ete_destcity, 
				  CASE WHEN RTRIM(LTRIM(ISNULL(ete_deststate, ''))) <> '' THEN ete_destcity ELSE ',' + LEFT(ete_destcity,2) + ',' + SUBSTRING(ete_destcity,3,2) + ',' + SUBSTRING(ete_destcity,5,2) + ',' + SUBSTRING(ete_destcity,7,2) + ',' + SUBSTRING(ete_destcity,9,2) + ',' + SUBSTRING(ete_destcity,11,2) + ',' + SUBSTRING(ete_destcity,13,2) + ',' END, 
				  ete_deststate, ete_destzip, ete_destlatitude, 
				  ete_destlongitude, 0, ete_availabledate, ete_postingdate, 
				  replicate('0', 5-len(CONVERT(VARCHAR, (DATEDIFF(mi, ete_postingdate, GETDATE())/60)))) + CONVERT(VARCHAR, (DATEDIFF(mi, ete_postingdate, GETDATE())/60)) + ':' + (CASE WHEN DATEDIFF(mi, ete_postingdate, GETDATE()) % 60 < 10 THEN '0' + CONVERT(VARCHAR, DATEDIFF(mi, ete_postingdate, getdate()) % 60) else convert(varchar, datediff(mi, ete_postingdate, getdate()) % 60) END), 
				  ete_expirationdate, IsNull(ete_equipmenttype, ''), ete_loadtype, 
				  ete_equipmentlength, ete_loadweight, ete_carrierid, ete_carriername, 
				  ete_carrierstate, ete_carriermcnumber, ete_contactname, ete_contactphone, 
				  ete_contactaltphone, ete_truckcount, ete_truckid, ete_created, ete_createdby, 
				  ete_updated, 	ete_updatedby, ete_truck_mcnum, ete_driver_name, ete_driver_phone, 
				  @branch_t, isnull(car_branch, 'UNKNOWN'), ete_remarks, ete_status, 
				  (select max(cartype1) from labelfile_headers) as 'cartype1_t', 
				  (select max(cartype2) from labelfile_headers) as 'cartype2_t', 
				  (select max(cartype3) from labelfile_headers) as 'cartype3_t', 
				  (select max(cartype4) from labelfile_headers) as 'cartype4_t', 
				   carrier.car_type1,
				   carrier.car_type2,
				   carrier.car_type3,
				   carrier.car_type4,
				  ete_mc,
					ete_automatch,
					ete_originradius,
					ete_destradius,
					ete_lgh_number
			 FROM external_equipment WITH (nolock) 
				  LEFT OUTER JOIN carrier ON external_equipment.ete_carrierid = carrier.car_id 

			WHERE	(	(	@equipment_type_value = 'ALL') OR
						(	ete_equipmenttype IS NULL) OR
						(	(	@equipment_type_value = 'GROUP') AND
							(	ete_equipmenttype IN	(	SELECT	abbr
															FROM	labelfile
															WHERE	(labeldefinition = 'ExtEquipmentType') AND 
																	(label_extrastring1 = @equipment_type)
														)
							)
						) OR
						(	@equipment_type_value = 'ITEM'
							AND CHARINDEX(',' + ete_equipmenttype + ',', ',' + @equipment_type + ',') > 0
						)
					)
			  AND (CHARINDEX(',' + ISNULL(ete_loadtype, 'ALL') + ',', ',' + @loadType + ',') > 0  OR
				   @loadType = 'ALL') 
			  AND (CHARINDEX(',' + ISNULL(ete_equipmentlength, 'ALL') + ',', ',' + @length + ',') > 0 OR 
				   @length = '0') 
			  AND (CHARINDEX(',' + ISNULL(carrier.car_branch, 'UNKNOWN') + ',', ',' + @lgh_booked_revtype1 + ',') > 0 OR 
				   @lgh_booked_revtype1 = '') 
			  AND ISNULL(ete_loadweight, 0) >= @weight 
			  AND (
					(ete_availabledate BETWEEN @availableFrom AND @availableTo)
					OR 
					(ete_expirationdate BETWEEN @availableFrom AND @availableTo)
					OR
					(ete_availabledate <= @availableFrom AND ete_expirationdate >= @availableTo)
				  ) 
			  AND ete_postingdate >= DATEADD(hh, @maxAge, GETDATE()) 
			  AND ete_status = 'AVL' 
			  AND ete_expirationdate >= GetDate() 
				  )

-- remove entries that do not fall with in the specified distance from the destination requested by the user
if @dradius > 0
begin
   UPDATE #results 
	  SET ete_dhmiles_dest = dbo.tmw_airdistance_fn(@ete_destlat, @ete_destlong, ete_destlatitude, ete_destlongitude)
	WHERE ISNULL(ete_deststate, '') <> ''
   
   delete #results 
	where ete_destlatitude = 0
	   or ete_destlongitude = 0	
	   or ete_dhmiles_dest > @dradius 		
end

if 	(isnull(@cartype1, '') <> '') 
	or (isnull(@cartype2, '') <> '')
	or (isnull(@cartype3, '') <> '')
	or (isnull(@cartype4, '') <> '')
	or (isnull(@liabilitylimit, 0) <> 0 )
	or (isnull(@cargolimit, 0) <> 0) 
	or (isnull(@servicerating, '') <> '') 
	or (isnull(@insurance, 'N') = 'Y')
	or (isnull(@w9, 'N') = 'Y')
	or (isnull(@contract, 'N') = 'Y')
	or (isnull(@carid, '') <> '') 
begin

	insert #temp_filteredcarriers (fcr_carrier, keepfromfilter)
		select car_id, 'Y' from carrier 
		where (isnull(@cartype1, '') = '' or @cartype1 = 'UNK' or @cartype1 = carrier.car_type1)
		and (isnull(@cartype2, '') = '' or @cartype2 = 'UNK' or @cartype2 = carrier.car_type2)
		and (isnull(@cartype3, '') = '' or @cartype3 = 'UNK' or @cartype3 = carrier.car_type3)
		and (isnull(@cartype4, '') = '' or @cartype4 = 'UNK' or @cartype4 = carrier.car_type4)
		and (isnull(@liabilitylimit, 0) = 0 or @liabilitylimit <= carrier.car_ins_liabilitylimits)
		and (isnull(@cargolimit, 0) = 0 or @cargolimit <= carrier.car_ins_cargolimits)
		and (isnull(@servicerating, '') = '' or @servicerating = 'UNK' or @servicerating = carrier.car_rating)
		and (isnull(@insurance, '') = '' or upper(@insurance) = 'N' or @insurance = carrier.car_ins_certificate)
		and (isnull(@w9, '') = '' or upper(@w9) = 'N' or @w9 = carrier.car_ins_w9)
		and (isnull(@contract, '') = '' or upper(@contract) = 'N' or @contract = carrier.car_ins_contract)
		and (isnull(@carid, '') = '' or @carid = carrier.car_id or @carid = 'UNKNOWN')

	-- Get rid of anything where the carrier does not match with the filters 
	delete #results where ete_carrierid not in (select fcr_carrier from #temp_filteredcarriers)
end


SELECT ete_id, 
	   ete_postingage, 
	   ete_postingdate, 
	   ete_availabledate, 
	   ete_equipmenttype, 
	   ete_loadtype, 
	   ete_dhmiles_origin, 
	   ete_origcity, 
	   ete_origstate, 
	   ete_destcity, 
	   ete_deststate, 
	   ete_dhmiles_dest, 
	   ete_carrierid, 
	   ete_carriername, 
	   ete_carrierstate,
	   ete_contactname, 
	   ete_contactphone, 
	   ete_equipmentlength, 
	   ete_loadweight, 
	   ete_truckcount, 
	   ete_truckid, 
	   ete_driver_name, 
	   ete_driver_phone, 
	   branch_t, 
	   branch, 
	   ete_source, 
	   ete_remarks, 
	   ete_expirationdate, 
	   ete_status, 
	   ete_created, 
	   ete_createdby, 
	   ete_updated, 
	   ete_updatedby, 
	   ete_origlatitude, 
	   ete_origlongitude, 
	   ete_destlatitude, 
	   ete_destlongitude,
	   cartype1_t,
	   cartype2_t,
	   cartype3_t,
	   cartype4_t,
	   car_type1,
	   car_type2,
	   car_type3,
	   car_type4,
	   ete_mc,
	   '...' ete_dest_statelist, 
		ete_automatch,
		ete_originradius,
		ete_destradius,
		ete_sourcerefnumber,
		ete_lgh_number
  FROM #results 
order by ete_dhmiles_origin, ete_dhmiles_dest

DROP TABLE #results
DROP TABLE #temp_values
DROP TABLE #temp_filteredcarriers

END

GO
GRANT EXECUTE ON  [dbo].[external_equipment_search_Ops] TO [public]
GO
