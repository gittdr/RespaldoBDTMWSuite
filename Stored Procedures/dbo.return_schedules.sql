SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.return_schedules    Script Date: 6/1/99 11:54:38 AM ******/
create procedure [dbo].[return_schedules] @hdrnumber integer

as


 SELECT schedule_table.sch_number,   
        schedule_table.sch_description,   
        schedule_table.ord_hdrnumber,   
        schedule_table.sch_dow,   
        schedule_table.sch_dispatch,   
        schedule_table.sch_specificdate,   
        schedule_table.trc_number,   
        schedule_table.mpp_id,   
        schedule_table.trl_id,   
        schedule_table.car_id,   
        schedule_table.sch_multisch,   
        schedule_table.sch_timeofday,
	Getdate()
	 FROM schedule_table  
  WHERE schedule_table.ord_hdrnumber = @hdrnumber 

return

GO
GRANT EXECUTE ON  [dbo].[return_schedules] TO [public]
GO
