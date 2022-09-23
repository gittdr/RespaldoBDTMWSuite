SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Juan Ramon Lopez>
-- Create date: <22- junio - 2017>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ObtieneCoordenasConvoy_JR] @StopNumber as int, @tractorLat as float out , @tractorLon as float out, @cteLat as float out, @cteLon as float out, @peso as float out, @tipoVehiculo as int out

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Declare @lghNumero integer,
	@numtractor varchar(20),
	@ejestractor integer,
	@numcaja1 varchar(20),
	@ejescaja1  integer,
	@numdolly  varchar(20),
	@ejesdolly  integer,
	@numcaja2  varchar(20),
	@ejescaja2  integer,
	@carrier  varchar(20),
	@ejes		integer

	select @tractorLat	= 0
	select @tractorLon	= 0
	select @cteLat		= 0
	select @cteLon		= 0
	select @lghNumero	= 0
	select @ejestractor = 0
	select @ejescaja1	= 0
	select @ejescaja2	= 0
	select @ejesdolly	= 0
	select @ejes		= 0
	select @peso		= 0





select 
@tractorLat = ISNull((select round(cast(trc_gps_latitude as float)/3600,6) from tractorprofile(nolock) where trc_number =  (select lgh_tractor from legheader (nolock) where stops.lgh_number = legheader.lgh_number)),0),
@tractorLon = ISNull((select round(cast(trc_gps_longitude as float)/3600,6) * -1 from tractorprofile(nolock) where trc_number =  (select lgh_tractor from legheader (nolock) where stops.lgh_number = legheader.lgh_number)),0),
@cteLat		= ISNull((select round(cast(cmp_latseconds as float)/3600 ,6) from company (nolock) where  company.cmp_id = stops.cmp_id),0) ,
@cteLon		= ISNull((select round(cast(cmp_longseconds as Float)/3600,6) * -1 from company (nolock) where  company.cmp_id = stops.cmp_id),0) ,
@lghNumero	= IsNull(lgh_number,0)
 from stops where  stp_number = @StopNumber

 
 
 select 
 @numtractor	= lgh_tractor, 
 @ejestractor	= IsNull((select trc_axles from tractorprofile where trc_number = lgh_Tractor),0),
 @numcaja1		= lgh_primary_trailer, 
 @ejescaja1		= IsNull((select trl_axles from trailerprofile where trl_number = lgh_primary_trailer),0),
 @numdolly		= lgh_dolly, 
 @ejesdolly		= IsNull((select trl_axles from trailerprofile where trl_number = lgh_dolly),0),
 @numcaja2		= lgh_primary_pup, 
 @ejescaja2		= IsNull((select trl_axles from trailerprofile where trl_number = lgh_primary_pup),0),
 @carrier		= lgh_carrier,
 @Peso			= IsNull(lgh_tot_weight ,0)
 from legheader where lgh_number = @lghNumero

   
  select @ejes = @ejestractor + @ejescaja1 + @ejesdolly + @ejescaja2


  if @ejes = 3
	select @tipoVehiculo = 6
  else if @ejes = 5
	select @tipoVehiculo = 9
  else if @ejes = 7
	select @tipoVehiculo = 22
  else if @ejes = 9
	select @tipoVehiculo = 25
  else if @ejes = 6
	select @tipoVehiculo = 20
  else
		select @tipoVehiculo = 9
	
END
GO
