SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[d_freight_by_compartment_sp] @mov_number int 
as 
/*

DPETE 12/16/04 PTS 25178 add fbc_refnum to return set
DPETE 4/28/05 return total tare weight of equipment assigned to first leg
   Add Selectrow a working column to filter on selected rows for auto load
EMK 7/28/07 PTS 37102 Added flag for jurisdictional limits.  Used for highlighting purposes in DW.
*/ 

Declare @TareWeight int,@evtnumber int
/* Find first loaded event */
Select @evtnumber = evt_number from stops,event where mov_number = @mov_number
And stp_type = 'PUP' 
And stp_mfh_sequence = 
    (Select min(stp_mfh_sequence) From stops s2 
     Where s2.mov_number = @mov_number and stp_type = 'PUP')
And event.stp_number = stops.stp_number
And evt_sequence = 1

/* Get total tare weight for all assets */


Select @tareWeight = IsNull(trc_axlgrp1_tarewgt,0) + IsNull(trc_axlgrp2_tarewgt,0) 
From tractorprofile,event
Where event.evt_number = @evtnumber
And tractorprofile.trc_number = evt_tractor

Select @tareWeight = @tareWeight + IsNull(trl_axlgrp1_tarewgt,0) + IsNull(trl_axlgrp2_tarewgt,0) 
From trailerprofile,event
Where event.evt_number = @evtnumber
And trailerprofile.trl_number = evt_trailer1

Select @tareWeight =  @tareWeight +IsNull(trl_axlgrp1_tarewgt,0) + IsNull(trl_axlgrp2_tarewgt,0) 
From trailerprofile,event
Where event.evt_number = @evtnumber
And trailerprofile.trl_number = evt_trailer2

SELECT 	 fbc_id,   
         stp_number,   
         freight_by_compartment.cmd_code,   
         fgt_description,   
         fbc_compartm_number,   
         fbc_volume,   
         fbc_weight,   
         fgt_number,
	freight_by_compartment.cpr_density,
	ecd_id,
	fbc_max_weight,
	99999.9999 c_max_volume,
	freight_by_compartment.mov_number,
	freight_by_compartment.ord_hdrnumber,
	fbc_adj_max_weight,
	'LBS/CUB' units,
	fbc_consignee,
	fbc_compartm_from,
	scm_subcode,
	fbc_load_location,
	stp_number_load,
	cmp_ord = (fbc_load_location + '- ord ' + ord_number),
	tank_loc,
	fbc_tank_nbr,
	fbc_compartm_capacity,
      	bc_refnum = IsNull(fbc_refnumber,''),
	fbc_net_volume
        ,@tareweight
        ,selectrow = 'Y',
	dip_before begin_dip,
	dip_after end_dip,
	0 flg_jurisdiction  
    FROM freight_by_compartment
			LEFT OUTER JOIN orderheader ON freight_by_compartment.ord_hdrnumber = orderheader.ord_hdrnumber -- 26641 allow for no order
   WHERE ( freight_by_compartment.mov_number = @mov_number)

GO
GRANT EXECUTE ON  [dbo].[d_freight_by_compartment_sp] TO [public]
GO
