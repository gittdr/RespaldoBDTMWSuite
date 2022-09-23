SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create procedure [dbo].[d_freightdetail](@stringparm 	varchar(12),
				@numberparm 	int,
				@retrieve_mode	varchar(8)) 
as

-- 

-- dpete 10/21/99 add ref number count to return set 
-- dpete pts6717 add work unit to allow unit conversions in order entry
-- 07/18/2001	Vern Jewett (label=vmj1)	PTS 11423: decimal counts.
--dpete pts 11536 8/17/01 add tariff info to freight detail for rate by detail orders
-- PTS 12523 dpete add fgt_rate_type to return set
/* ***********************************************************************************
  If you are adding a column and want that column to copy when copying an order in order
  entry - also add the column to the sloneorderwithoptions stored proc which does the copying
  ************************************************************ */
-- 07/25/2002	Vern Jewett (label=vmj2)	PTS 14924: expand fgt_description from
--											varchar(30) to varchar(60).
-- 04/14/2004   Greg Kanzinger modified fgt_weight column from a float to decimal (12,4) to take care of rounding issue
--22694-22154 add cpr_density and scm_subcode
--PTS 30459 11/16/05 JJF feet/inches data entry capability
--PTS 38773 Trimac changes September 2007: added 8 columns
--PTS40752 (Pauls recode 30455) DPETE
--PTS44189 pmill added fgt_volume2
--PTS44864 pmill change fgt_volume from float to decimal
-- PTS 50866 proc is being called with zero ord_hdrnumber, running long
-- PTS66204 add fgt_supplier


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
--fgt_volume float(15) NULL,  --44864 pmill change to decimal
fgt_volume decimal(12,4) NULL,
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
-- PTS 38773 added 8 cols
fgt_dispatched_quantity float null,
fgt_dispatched_unit varchar(6) null,
fgt_actual_quantity float null,
fgt_actual_unit varchar(6) null,
fgt_billable_quantity float null,
fgt_billable_unit varchar(6) null,
ord_hdrnumber int null,
ord_status varchar(6) null,
-- PTS 38773 end
--40752
tank_loc   varchar(10) null,
cmp_recommordersize int null,
--44189
fgt_volume2 float(15) NULL,
fgt_volumeunit2 varchar(6) NULL,
fgt_supplier varchar(8) NULL,
cmd_class2	VARCHAR(8) NULL  --PTS52530 MBR 06/14/13
)

If @numberparm > 0    

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
	-- PTS 38773 added next 8 cols
	freightdetail.fgt_dispatched_quantity ,
	freightdetail.fgt_dispatched_unit ,
	freightdetail.fgt_actual_quantity ,
	freightdetail.fgt_actual_unit ,
	freightdetail.fgt_billable_quantity ,
	freightdetail.fgt_billable_unit,
	stops.ord_hdrnumber,
	(select ord_status from orderheader where ord_hdrnumber = @numberparm),
	-- PTS 38773 end
     tank_loc = IsNull(freightdetail.tank_loc, 'UNKNOWN'),
    cmp_recommordersize = isnull(compinvprofile.cmp_recommordersize,0),
	--44189
	isnull(freightdetail.fgt_volume2, 0),
	isnull(freightdetail.fgt_volumeunit2, 'UNK'),
	ISNULL(freightdetail.fgt_supplier,'UNKNOWN') fgt_supplier,
	ISNULL(commodity.cmd_class2, 'UNKNOWN')


--PTS 30459 11/16/05 JJF new school join
   --FROM freightdetail,   
   --      city,   
   --      company,   
   --      stops  
   --WHERE ( company.cmp_id = stops.cmp_id ) and  
    --     ( freightdetail.stp_number = stops.stp_number ) and  
   --      ( stops.stp_city = city.cty_code ) and  
   --      ( ( stops.ord_hdrnumber = @numberparm ) )
/* 
	FROM	city INNER JOIN
		freightdetail INNER JOIN
		stops INNER JOIN
		company ON stops.cmp_id = company.cmp_id 
		ON freightdetail.stp_number = stops.stp_number 
		ON city.cty_code = stops.stp_city
*/
    FROM stops
    join freightdetail on stops.stp_number = freightdetail.stp_number
    join company on stops.cmp_id = company.cmp_id
    left outer join city on stops.stp_city = city.cty_code
    left outer join compinvprofile on stops.cmp_id = compinvprofile.cmp_id
    JOIN commodity ON freightdetail.cmd_code = commodity.cmd_code
	WHERE	(stops.ord_hdrnumber = @numberparm)
    AND stops.ord_hdrnumber > 0 

ELSE
 INSERT INTO #tempfgt
 SELECT 'UNKNOWN'cmd_code,   
         '' fgt_description,   
         0 fgt_weight,   
         0 fgt_weightunit,   
         0 fgt_count,   
         0 fgt_countunit,   
         0 fgt_volume,   
         'UNK' fgt_volumeunit,   
         'UNK' fgt_reftype,   
         '' fgt_refnum,   
         0 fgt_number,   
         0 stp_number,   
         1 fgt_sequence,
         'UNKNOWN' cmp_id,   
         '' cmp_name,   
         'UNKNOWN' cty_nmstct,
         '' stp_type,			
         1 stp_sequence,
         1 stp_mfh_sequence,
         0 fgt_quantity,   
         0.0 fgt_rate,   
         0.0 fgt_charge,   
         'UNK' fgt_rateunit,   
         'UNK' cht_itemcode,  
         'UNK' cht_basisunit,
         'UNK' fgt_unit ,
        0.0 work_quantity,
        @varchar40 rate_msg,  
        @smallint   ref_count ,
        @workUnit work_unit,
	0 fgt_width,
	'UNK' fgt_widthunit,
	0 fgt_width_feet, 
	0 fgt_width_inches, 
	0 fgt_length,
	'UNK' fgt_lengthunit,
	--PTS 30459 11/16/05 JJF feet/inches data entry capability (note: xxxunits column does not appear to be in use, so no attempt is made to convert value before translating to foot/in)
	0 fgt_length_feet, 
	0 fgt_length_inches, 
	0 fgt_height,
	'UNK' fgt_heightunit,
	--PTS 30459 11/16/05 JJF feet/inches data entry capability (note: xxxunits column does not appear to be in use, so no attempt is made to convert value before translating to foot/in)
	0 AS fgt_height_feet, 
	0 fgt_height_inches, 
	null fgt_stackable, 
	0 fgt_quantity_type,
	0 fgt_charge_type,
	0 tar_number ,
	'' tar_tariffitem ,
	'' tar_tariffnumber,
	0.0 fgt_ratingquantity,
	'UNK' fgt_ratingunit,
	0 fgt_rate_type,
	null fgt_loadingmeters,
	'UNK' fgt_loadingmetersunit,
	'' fgt_additionl_description,
	null fgt_specific_flashpoint,
	'UNK'fgt_specific_flashpoint_unit,
	0 fgt_ordered_volume,
	0 fgt_ordered_loadingmeters,
	'UNK' fgt_pallet_type,
	null fgt_pallets_out ,
	null fgt_pallets_in,
	null fgt_ordered_count,
	null fgt_ordered_weight,
	null cpr_density ,
	scm_subcode = '',   
	0 fgt_count2 ,   
	null fgt_count2unit,
	null fgt_dispatched_quantity ,
	null fgt_dispatched_unit ,
	null fgt_actual_quantity ,
	null fgt_actual_unit ,
	null fgt_billable_quantity ,
	null fgt_billable_unit,
	0 ord_hdrnumber,
	'',
     tank_loc = 'UNKNOWN',
    cmp_recommordersize = 0,
	0 fgt_volume2,
	'UNK' fgt_volumeunit2,
	'UNKNOWN' fgt_supplier,
	'UNKNOWN' cmd_class2
    WHere 0 = 1
    


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
	-- PTS 38773 added next 8 cols
	fgt_dispatched_quantity ,
	fgt_dispatched_unit ,
	fgt_actual_quantity ,
	fgt_actual_unit ,
	fgt_billable_quantity ,
	fgt_billable_unit,
	ord_hdrnumber,
	ord_status,
	-- PTS 38773 end
    tank_loc,
    cmp_recommordersize,
	--44189
	fgt_volume2,
	fgt_volumeunit2,
	fgt_supplier,
	cmd_class2

FROM #tempfgt	
		  

return



GO
GRANT EXECUTE ON  [dbo].[d_freightdetail] TO [public]
GO
