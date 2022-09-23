SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_hddwn_stopstatus_update_sp    Script Date: 6/1/99 11:54:47 AM ******/
--create stored procedure 
CREATE PROC [dbo].[d_hddwn_stopstatus_update_sp](@v_legnumber int,@v_status char(3) out)
       
                                     
                                 

AS

DECLARE @stopcnt int,
        @dnecnt  int


BEGIN

select @stopcnt = count(*)
  from stops
 where lgh_number = @v_legnumber


select @dnecnt = count(*)
  from stops
 where lgh_number = @v_legnumber and stp_status = 'DNE'


--Update legheader information       

if @stopcnt = @dnecnt


  begin
    update legheader
       set lgh_outstatus = 'CMP'
     where lgh_number = @v_legnumber
  	
    select @v_status = 'DNE'	 

  end
else

    select @v_status = 'OPN'  

END

GO
GRANT EXECUTE ON  [dbo].[d_hddwn_stopstatus_update_sp] TO [public]
GO
