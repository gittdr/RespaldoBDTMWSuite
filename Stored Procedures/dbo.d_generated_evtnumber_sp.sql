SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_generated_evtnumber_sp    Script Date: 6/1/99 11:54:12 AM ******/
--create stored procedure 
CREATE PROC [dbo].[d_generated_evtnumber_sp](@v_stpnumber int,@v_evtnumber int out)
                                 

AS

--*********************************************************************************************
--Declaration and initialization of variables

DECLARE @evt_number  int
	
--*********************************************************************************************
--Select event number generated by the trigger it_stops()
select @v_evtnumber = evt_number
  from event
 where stp_number = @v_stpnumber and evt_sequence = 1 

GO
GRANT EXECUTE ON  [dbo].[d_generated_evtnumber_sp] TO [public]
GO
