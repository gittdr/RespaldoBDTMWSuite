SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create procedure [dbo].[d_freightdetail_invedit](
				@p_ordhdrnumber 	int,
				@p_invoiceby	varchar(3)) 
as

/*
Copy of d_frieghtdetail on 12/5/08 to allow showing all freight for all orders  when invoicing by an aggregate like move
--PTS43837 DPETE 12/5/08 created from copy of d_freightdetail
--44417 DPETE 2/13/09 add invoice by move/consignee CON
*/


DECLARE @work_quantity		float(15)
DECLARe @smallint    			smallint
DECLARE @varchar40                           varchar(40)
DECLARE @workUnit                            varchar(6)


select @work_quantity = 0.0
SELECT @smallint = 0
SELECT @varchar40 = ' '
SELECT @WorkUnit = ' '

/*		
declare @tempfgt table  (
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
fgt_volumeunit2 varchar(6) NULL
) 
*/ 
declare @ords table (ord_hdrnumber int,ord_number varchar(13))
declare @billto varchar(8),@mov int,@consignee varchar(8)

select @p_invoiceby = isnull(@p_invoiceby,'ORD')

select @billto = ord_billto,@mov = mov_number,@consignee = ord_consignee
from orderheader where ord_hdrnumber = @p_ordhdrnumber

If @p_invoiceby = 'ORD'
  insert into @ords 
  select ord_hdrnumber,ord_number from orderheader where ord_hdrnumber = @p_ordhdrnumber
If @p_invoiceby = 'MOV' 
  insert into @ords
  select  ord_hdrnumber,ord_number
  from orderheader
  where mov_number = @mov 
  and ord_billto = @billto  
If @p_invoiceby = 'CON' 
  insert into @ords
  select  ord_hdrnumber,ord_number
  from orderheader
  where mov_number = @mov 
  and ord_billto = @billto
  and ord_consignee = @consignee  

--INSERT INTO @tempfgt
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
         isnull(freightdetail.fgt_charge,0) fgt_charge,   
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
	(select ord_status from orderheader where ord_hdrnumber = @p_ordhdrnumber),
	-- PTS 38773 end
     tank_loc = IsNull(freightdetail.tank_loc, 'UNKNOWN'),
    cmp_recommordersize = isnull(compinvprofile.cmp_recommordersize,0),
	--44189
	isnull(freightdetail.fgt_volume2, 0),
	isnull(freightdetail.fgt_volumeunit2, 'UNK'),
    ords.ord_number,
    stp_arrivaldate

    FROM @ords ords
    join stops on ords.ord_hdrnumber = stops.ord_hdrnumber
    join freightdetail on stops.stp_number = freightdetail.stp_number
    join company on stops.cmp_id = company.cmp_id
    left outer join city on stops.stp_city = city.cty_code
    left outer join compinvprofile on stops.cmp_id = compinvprofile.cmp_id
    order by stp_arrivaldate,fgt_sequence


		  

return



GO
GRANT EXECUTE ON  [dbo].[d_freightdetail_invedit] TO [public]
GO
