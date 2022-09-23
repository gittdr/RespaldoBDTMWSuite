SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[sp_reporteEjes]
	-- Add the parameters for the stored procedure here
	@mov int	
AS
BEGIN

SELECT max(tractorprofile.trc_axles), 
		    max( trl1.trl_axles) trl1_trl_axles, 
		    max( trl2.trl_axles) trl2_trl_axles, 
		    max(trl3.trl_axles) trl3_trl_axles,
			max( case when event.evt_tractor = 'UNKNOWN' then '' else event.evt_tractor end) as tractor, 	
		    max(case when event.evt_trailer1 = 'UNKNOWN' then '' else event.evt_trailer1 end )as trailer1,
		    max( case when event.evt_trailer2 = 'UNKNOWN' then '' else event.evt_trailer2 end) as trailer2,
	        max( case when event.evt_dolly = 'UNKNOWN' then '' else event.evt_dolly end) as dolly,
(select avg(fcl_mpg) from fuelticket_calcLog where mov_number =@mov and orden = (select max(orden) from fuelticket_calcLog where mov_number = @mov )) as Rendimiento,
max(stops.mov_number) as mov_number 
        FROM stops LEFT OUTER JOIN city ON stops.stp_city = city.cty_code
             left JOIN legheader ON ( stops.mov_number = legheader.mov_number and stops.lgh_number = legheader.lgh_number)
             left JOIN event on (stops.stp_number = event.stp_number) 
             left JOIN manpowerprofile ON ( legheader.lgh_driver1 = manpowerprofile.mpp_id )
             left JOIN tractorprofile  ON ( legheader.lgh_tractor = tractorprofile.trc_number )
	          left join trailerprofile trl1  on ( stops.trl_id = trl1.trl_id )
	          left join trailerprofile trl2  on ( event.evt_trailer2 = trl2.trl_id )
		     left join trailerprofile trl3  on ( event.evt_dolly = trl3.trl_id )
       WHERE stops.mov_number = @mov
	      AND event.evt_sequence = 1

END
GO
