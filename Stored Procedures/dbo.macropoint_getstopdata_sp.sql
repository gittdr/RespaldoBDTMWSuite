SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[macropoint_getstopdata_sp]
as
select  '' as Location_Update_Frequency
        ,'7592467' as MPID
        ,stops.lgh_number as Load_ID
        ,carrier.car_scac as SCAC_Code
        ,legheader_brokered.lgh_driver_phone as Driver_Cell
        ,stops.stp_number as Stop_ID
        ,Stop_Type = case stops.stp_type    
						when 'PUP' then 'Pickup'
						when 'DRP' then 'DropOff'
                     end
        ,company.cmp_name as Stop_Name
        ,company.cmp_address1 as Address1
        ,company.cmp_address2 as Address2
		,City = city.cty_name
        ,city.cty_state as State
        ,city.cty_zip as Postal_Code
        ,Country = (select stc_country_c from statecountry where cty_state = stc_state_c)
        ,Appt_Begin = 
                case    when stops.stp_status = 'OPN' and stops.stp_type = 'PUP' then stp_schdtearliest
                        when stops.stp_status = 'DNE' and stops.stp_type = 'PUP' then stp_arrivaldate
                        when stops.stp_status = 'OPN' and stops.stp_type = 'DRP' then stp_schdtearliest
                        when stops.stp_status = 'DNE' and stops.stp_type = 'DRP' then stp_arrivaldate
                END
                         
        ,Appt_End = 
                case    when stops.stp_status = 'OPN' and stops.stp_type = 'PUP' then stp_schdtlatest
                        when stops.stp_status = 'DNE' and stops.stp_type = 'PUP' then stp_departuredate
                        when stops.stp_status = 'OPN' and stops.stp_type = 'DRP' then stp_schdtlatest
                        when stops.stp_status = 'DNE' and stops.stp_type = 'DRP' then stp_departuredate
                END
        ,TimeZone = city.cty_GMTDelta
        ,Status = case  when stops.stp_status = 'OPN' and stops.stp_type = 'PUP' then 'Not Arrived'
                        when stops.stp_status = 'DNE' and stops.stp_type = 'PUP' then 'Arrived'
                        when stops.stp_status = 'OPN' and stops.stp_type = 'DRP' then 'Not Arrived'
                        when stops.stp_status = 'DNE' and stops.stp_type = 'DRP' then 'Arrived'
                  END
  from stops (nolock)
        join legheader_active (nolock) on legheader_active.lgh_number = stops.lgh_number 
                and legheader_active.lgh_carrier <> 'UNKNOWN'
        join legheader_brokered (nolock) on stops.lgh_number = legheader_brokered.lgh_number 
         and LEN(ISNULL(legheader_brokered.lgh_driver_phone,'')) >= 10
        join carrier (nolock) on carrier.car_id = legheader_active.lgh_carrier
        join company (nolock) on stops.cmp_id = company.cmp_id
        JOIN city (nolock) on stops.stp_city = city.cty_code
  where stops.stp_type in ('PUP','DRP') and lgh_enddate > dateadd(hh,-24, getdate())
    order by stops.mov_number, stp_mfh_sequence
    
GO
GRANT EXECUTE ON  [dbo].[macropoint_getstopdata_sp] TO [public]
GO
