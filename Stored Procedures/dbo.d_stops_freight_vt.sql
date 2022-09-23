SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [dbo].[d_stops_freight_vt](@stringparm 	varchar(12),
				@numberparm 	int,
				@retrieve_mode	varchar(8)) AS 

/**
 * 
 * NAME:
 * dbo.d_stops_freight_vt
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for dw d_stops_fgt
 * Returns new Trimac columns
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * .....
 * 001 - @stringparm varchar(12)
 * 002 - @numberparm int
 * 003 - @retrieve_mode varchar(8)
 * 
 * REVISION HISTORY:
 * Created PTS 38773 JDSwindell New Window/DW for  new "Additional Freight Detail"
 * 01/21/2008 PTS 40887 JSwindell : use fgt_weight/count/volume instead of fgt_ordered_* for computed cols
*/



DECLARE @work_quantity		float(15)
DECLARe @smallint    			smallint
DECLARE @varchar40                           varchar(40)
DECLARE @workUnit                            varchar(6)


select @work_quantity = 0.0
SELECT @smallint = 0
SELECT @varchar40 = ' '
SELECT @WorkUnit = ' '

		
create table #tempfgt (
cmd_code varchar(8) NULL, 
--vmj2+
fgt_description varchar(60) NULL,
--fgt_description varchar(30) NULL,
--vmj2-
fgt_weight decimal (12,4) NULL,
fgt_weightunit varchar(6) NULL,
--vmj1+
fgt_count	float	NULL,
--fgt_count  int NULL,
--vmj1-
fgt_countunit varchar(6) NULL,
fgt_volume float(15) NULL,
fgt_volumeunit varchar(6) NULL,
fgt_reftype varchar(6) NULL,
fgt_refnum varchar(30) NULL,
fgt_number int NULL,
stp_number int NULL,
fgt_sequence smallint NULL,
cmp_id varchar(8) NULL,
cmp_name varchar(30) NULL,
cty_nmstct varchar(25) NULL,
stp_type varchar(6) NULL,
stp_sequence int NULL,
stp_mfh_sequence int NULL,
fgt_quantity float(15) NULL,   
fgt_rate money NULL, 
fgt_charge money NULL,   
fgt_rateunit varchar(6) NULL,   
cht_itemcode varchar(6) NULL,  
cht_basisunit varchar(6) NULL,
fgt_unit varchar(6) NULL,
work_quantity float(15) NULL,
rate_msg  varchar(40),
ref_count smallint NULL,
work_unit varchar(8) NULL,
fgt_width float NULL,
fgt_widthunit VARCHAR(6) NULL,
--PTS 30459 11/16/05 JJF feet/inches data entry capability
fgt_width_feet int NULL,
fgt_width_inches int NULL,
fgt_length float NULL,
fgt_lengthunit VARCHAR(6) NULL,
--PTS 30459 11/16/05 JJF feet/inches data entry capability
fgt_length_feet int NULL,
fgt_length_inches int NULL,
fgt_height FLOAT NULL,
fgt_heightunit VARCHAR(6) NULL,
--PTS 30459 11/16/05 JJF feet/inches data entry capability
fgt_height_feet int NULL,
fgt_height_inches int NULL,
fgt_stackable VARCHAR(1) NULL,
fgt_quantity_type int NULL,
fgt_charge_type smallint NULL,
tar_number int NULL,
tar_tariffitem varchar(13) NULL,
tar_tariffnumber varchar(13) NULL,
fgt_ratingquantity float(15) NULL,
fgt_ratingunit varchar(6) NULL,
fgt_rate_type smallint NULL,
fgt_loadingmeters decimal(12,4) NULL,
fgt_loadingmetersunit varchar(6) NULL,
fgt_additionl_description varchar (25) NULL,
fgt_specific_flashpoint float null,
fgt_specific_flashpoint_unit varchar (6) null,
fgt_ordered_volume decimal null,
fgt_ordered_loadingmeters decimal null,
fgt_pallet_type varchar (6) null,
fgt_pallets_out decimal null, 
fgt_pallets_in decimal null,
fgt_ordered_count decimal null,
fgt_ordered_weight decimal null,
cpr_density decimal null,
scm_subcode varchar(8) null,
fgt_count2	float	NULL,
fgt_count2unit varchar(6) NULL,
fgt_dispatched_quantity float null,
fgt_dispatched_unit varchar(6) null,
fgt_actual_quantity float null,
fgt_actual_unit varchar(6) null,
fgt_billable_quantity float null,
fgt_billable_unit varchar(6) null,
ord_hdrnumber int null,
ord_status varchar(6) null,
c_ordered_quantity float null,
c_ordered_UOM varchar(6) null,
)   

INSERT INTO #tempfgt
 SELECT freightdetail.cmd_code,   
         freightdetail.fgt_description,   
         freightdetail.fgt_weight,   
         freightdetail.fgt_weightunit,   
         freightdetail.fgt_count,   
         freightdetail.fgt_countunit,   
         freightdetail.fgt_volume,   
         freightdetail.fgt_volumeunit,   
         freightdetail.fgt_reftype,   
         freightdetail.fgt_refnum,   
         freightdetail.fgt_number,   
         freightdetail.stp_number,   
         freightdetail.fgt_sequence,
         company.cmp_id,   
         company.cmp_name,   
         city.cty_nmstct,
         stops.stp_type,			
         stops.stp_sequence,
         stops.stp_mfh_sequence,
         freightdetail.fgt_quantity,   
         freightdetail.fgt_rate,   
	-- PTS 11696 - DJM - Modified to return zero if the charge is null  
         isnull(freightdetail.fgt_charge,0),   
         freightdetail.fgt_rateunit,   
         freightdetail.cht_itemcode,  
         freightdetail.cht_basisunit,
         freightdetail.fgt_unit ,
        @work_quantity work_quantity,
        @varchar40 rate_msg,  
        @smallint   ref_count ,
        @workUnit work_unit,
	fgt_width,
	fgt_widthunit,
	--PTS 30459 11/16/05 JJF feet/inches data entry capability (note: xxxunits column does not appear to be in use, so no attempt is made to convert value before translating to foot/in)
	CAST(ROUND(fgt_width, 0) AS int) / 12 AS fgt_width_feet, 
	CAST(ROUND(fgt_width, 0) AS int) % 12 AS fgt_width_inches, 
	fgt_length,
	fgt_lengthunit,
	--PTS 30459 11/16/05 JJF feet/inches data entry capability (note: xxxunits column does not appear to be in use, so no attempt is made to convert value before translating to foot/in)
	CAST(ROUND(fgt_length, 0) AS int) / 12 AS fgt_length_feet, 
	CAST(ROUND(fgt_length, 0) AS int) % 12 AS fgt_length_inches, 
	fgt_height,
	fgt_heightunit,
	--PTS 30459 11/16/05 JJF feet/inches data entry capability (note: xxxunits column does not appear to be in use, so no attempt is made to convert value before translating to foot/in)
	CAST(ROUND(fgt_height, 0) AS int) / 12 AS fgt_height_feet, 
	CAST(ROUND(fgt_height, 0) AS int) % 12 AS fgt_height_inches, 
	fgt_stackable,
	ISNULL(fgt_quantity_type,0) fgt_quantity_type,
	ISNULL(fgt_charge_type,0) fgt_charge_type,
	tar_number ,
	tar_tariffitem ,
	tar_tariffnumber,
	fgt_ratingquantity,
	fgt_ratingunit,
	ISNULL(fgt_rate_type,0) fgt_rate_type,
	fgt_loadingmeters,
	fgt_loadingmetersunit,
	fgt_additionl_description,
	fgt_specific_flashpoint,
	fgt_specific_flashpoint_unit,
	fgt_ordered_volume,
	fgt_ordered_loadingmeters,
	fgt_pallet_type,
	fgt_pallets_out ,
	fgt_pallets_in,
	fgt_ordered_count,
	fgt_ordered_weight,
	cpr_density = freightdetail.cpr_density,
	scm_subcode = IsNull(freightdetail.scm_subcode,''),   
	fgt_count2 = freightdetail.fgt_count2,   
	fgt_count2unit = freightdetail.fgt_count2unit,
freightdetail.fgt_dispatched_quantity ,
freightdetail.fgt_dispatched_unit ,
freightdetail.fgt_actual_quantity ,
freightdetail.fgt_actual_unit ,
freightdetail.fgt_billable_quantity ,
freightdetail.fgt_billable_unit,
stops.ord_hdrnumber,
(select ord_status from orderheader where ord_hdrnumber = @numberparm),
-- PTS 40887: new case statements.
CASE  WHEN fgt_count > 0 THEN fgt_count
	  WHEN fgt_volume > 0 THEN fgt_volume
	  WHEN fgt_weight > 0 THEN fgt_weight
	ELSE 0
END c_ordered_quantity,
CASE  WHEN fgt_count  > 0 THEN fgt_countunit
	  WHEN fgt_volume > 0 THEN fgt_volumeunit
	  WHEN fgt_weight > 0 THEN fgt_weightunit
	ELSE 'UNK'
END c_ordered_UOM
-- replace the following 2 case stmts with the above:  40887
--CASE   WHEN fgt_ordered_count > 0 THEN fgt_ordered_count
--       WHEN fgt_ordered_volume > 0 THEN fgt_ordered_volume
--	   WHEN fgt_ordered_weight > 0 THEN fgt_ordered_weight
--	   ELSE 0
--	   END c_ordered_quantity,
--CASE   WHEN fgt_ordered_count > 0 THEN fgt_countunit
--       WHEN fgt_ordered_volume > 0 THEN fgt_volumeunit
--	   WHEN fgt_ordered_weight > 0 THEN fgt_weightunit
--	   ELSE 'UNK'
--	   END c_ordered_UOM 

--PTS 30459 11/16/05 JJF new school join
   --FROM freightdetail,   
   --      city,   
   --      company,   
   --      stops  
   --WHERE ( company.cmp_id = stops.cmp_id ) and  
    --     ( freightdetail.stp_number = stops.stp_number ) and  
   --      ( stops.stp_city = city.cty_code ) and  
   --      ( ( stops.ord_hdrnumber = @numberparm ) ) 
	FROM	city INNER JOIN
		freightdetail INNER JOIN
		stops INNER JOIN
		company ON stops.cmp_id = company.cmp_id 
		ON freightdetail.stp_number = stops.stp_number 
		ON city.cty_code = stops.stp_city
	WHERE	(stops.ord_hdrnumber = @numberparm)

Update #tempfgt
SET  ref_count = isnull((SELECT COUNT(*) 
		FROM referencenumber
		WHERE ref_table = 'FREIGHTDETAIL'
		AND Ref_tablekey = fgt_Number),0)

--PTS 30459 11/16/05 JJF new school explicit return
--SELECT * from #tempfgt
SELECT	cmd_code, 
	fgt_description,
	fgt_weight,
	fgt_weightunit,
	fgt_count,
	fgt_countunit,
	fgt_volume,
	fgt_volumeunit,
	fgt_reftype,
	fgt_refnum,
	fgt_number,
	stp_number,
	fgt_sequence,
	cmp_id,
	cmp_name,
	cty_nmstct,
	stp_type,
	stp_sequence,
	stp_mfh_sequence,
	fgt_quantity,
	fgt_rate,
	fgt_charge,
	fgt_rateunit,
	cht_itemcode,
	cht_basisunit,
	fgt_unit,
	work_quantity,
	rate_msg,
	ref_count,
	work_unit,
	fgt_width,
	fgt_widthunit,
	fgt_width_feet,
	fgt_width_inches,
	fgt_length,
	fgt_lengthunit,
	fgt_length_feet,
	fgt_length_inches,
	fgt_height,
	fgt_heightunit,
	fgt_height_feet,
	fgt_height_inches,
	fgt_stackable,
	fgt_quantity_type,
	fgt_charge_type,
	tar_number,
	tar_tariffitem,
	tar_tariffnumber,
	fgt_ratingquantity,
	fgt_ratingunit,
	fgt_rate_type,
	fgt_loadingmeters,
	fgt_loadingmetersunit,
	fgt_additionl_description,
	fgt_specific_flashpoint,
	fgt_specific_flashpoint_unit,
	fgt_ordered_volume,
	fgt_ordered_loadingmeters,
	fgt_pallet_type,
	fgt_pallets_out,
	fgt_pallets_in,
	fgt_ordered_count,
	fgt_ordered_weight,
	cpr_density,
	scm_subcode,
	fgt_count2,
	fgt_count2unit,
fgt_dispatched_quantity ,
fgt_dispatched_unit ,
fgt_actual_quantity ,
fgt_actual_unit ,
fgt_billable_quantity ,
fgt_billable_unit,
ord_hdrnumber,
ord_status,
c_ordered_quantity,
c_ordered_UOM	

FROM #tempfgt	

return

GO
GRANT EXECUTE ON  [dbo].[d_stops_freight_vt] TO [public]
GO
