SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_trailer_assgn_chart_sp    Script Date: 6/1/99 11:54:29 AM ******/
/* create stored procedure */
CREATE PROC [dbo].[d_trailer_assgn_chart_sp](@v_trlnumber varchar(20),
                                     @v_ordhdrnumber int,
                                     @v_eventcode varchar(3),
                                     @v_stp_number int)

AS
/**********************************************************************************************/
/*Declaration and initialization of variables*/
Declare @char1 varchar(12),
        @char2 float,
        @char3 varchar(15),
        @full char(1)
/**********************************************************************************************/
/*Create temporary  table for chart assignment process*/
if exists(select *
           from compartment_details
          where comp_trl_id = @v_trlnumber and 
                comp_ordhdrnumber = @v_ordhdrnumber and
                comp_eventcode = @v_eventcode and
                comp_stp_number = @v_stp_number)
 begin

  SELECT 
	 trailer_detail.trl_id trailer,
         compartment_details.comp_commodity,         
         trailer_detail.trl_det_compartment compartment,
         trailer_detail.trl_det_vol volume,
         trailer_detail.trl_det_uom volume_uom,
         trailer_detail.trl_det_wet wet,
         trailer_detail.trl_det_ref_pt reference_pt,       
         compartment_details.comp_load_amt,
         compartment_details.comp_load_uom,
         compartment_details.comp_innage_outage,
	 compartment_details.comp_measure_inches,
         trailer_detail.trl_det_chart trailer_chart_num

    INTO #assgn_chart

    FROM compartment_details,
         trailer_detail

   WHERE (compartment_details.comp_trl_id =* trailer_detail.trl_id) and 			
         ((trailer_detail.trl_id = @v_trlnumber))  and
         (trailer_detail.trl_det_compartment *=  compartment_details.compartment) and
	 (compartment_details.comp_eventcode = @v_eventcode) and (compartment_details.comp_ordhdrnumber = @v_ordhdrnumber)and
         (compartment_details.comp_stp_number = @v_stp_number)

   select @full = 'Y'

 end

else

  SELECT trailer_detail.trl_id trailer,
         @char1 commodity,         
         trailer_detail.trl_det_compartment compartment,
         trailer_detail.trl_det_vol volume,
         trailer_detail.trl_det_uom volume_uom,
         trailer_detail.trl_det_wet wet,
         trailer_detail.trl_det_ref_pt reference_pt,
         @char2 load_amount,
         @char1 load_amount_uom,
         @char3 chart_type,
         @char2 measure_in_inches,
         trailer_detail.trl_det_chart trailer_chart_num
      	 
   INTO  #assgn_chart1 

   FROM  trailer_detail

  WHERE  (trailer_detail.trl_id = @v_trlnumber)

/**********************************************************************************************/

if @full = 'Y'
  begin 
     SELECT *
       FROM #assgn_chart
   ORDER BY compartment
  end
else
  begin
    update #assgn_chart1
       set commodity = 'UNKNOWN',
           load_amount_uom = 'Gallons',
           chart_type = 'INNAGE'      

     SELECT *
       FROM #assgn_chart1
   ORDER BY compartment
  end  


GO
GRANT EXECUTE ON  [dbo].[d_trailer_assgn_chart_sp] TO [public]
GO
