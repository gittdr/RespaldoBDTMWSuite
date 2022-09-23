SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los movimientos de entrada y salida del Recurso Confiable
-- y pasarlos a la tabla checkcall.
--    DROP PROCEDURE sp_inserta_checkcal_RC_JR
--GO
--   exec sp_inserta_checkcal_RC_JR


CREATE PROCEDURE [dbo].[sp_inserta_checkcal_RC_JR] @P_IDOPERA varchar(8), @P_fechamov datetime, @P_TIPOMOV varchar(5),
@P_ubicacion Varchar(100), @P_unidad Varchar(10)

AS

DECLARE	
	@V_latitud		float, 
	@V_longitud		float, 
	@V_CONSECCKC	bigint


SET NOCOUNT ON

BEGIN --1 Principal

IF @P_IDOPERA Is Null
	Begin
	-- Obtengo de la tablas de unidades el Id Operador..
		select @P_IDOPERA = trc_driver from tractorprofile 
		where trc_number= @P_unidad
	End 


				
		-- Lee el consecutivo de los checkcall para hacer el insert a la tabla.					
		execute @V_CONSECCKC = tmwSuite..getsystemnumber_gateway N'CKCNUM' , NULL , 1 
		-- Inserta el nuevo checkcall
		Insert tmwSuite..checkcall(
		ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_event, ckc_city, ckc_comment, 
		ckc_updatedby, ckc_updatedon, ckc_latseconds, ckc_longseconds, ckc_lghnumber, ckc_tractor, ckc_extsensoralarm, ckc_vehicleignition, 
		ckc_milesfrom, ckc_directionfrom, ckc_validity, ckc_mtavailable, ckc_minutes, ckc_mileage, ckc_home, ckc_cityname, 
		ckc_state, ckc_zip, ckc_commentlarge, ckc_minutes_to_final, ckc_miles_to_final, ckc_Odometer, TripStatus, ckc_odometer2, 
		ckc_speed, ckc_speed2, ckc_heading, ckc_gps_type, ckc_gps_miles, ckc_fuel_meter, ckc_idle_meter)
		Values (@V_CONSECCKC, 'HIST', 'DRV', 	@P_IDOPERA,	@P_fechamov, 	@P_TIPOMOV, 		0, 	@P_ubicacion, 
			'RC', 		GetDate(), 	@V_latitud,	@V_longitud, 		0, 		@P_Unidad, 	Null, 	Null, 
			1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
			Null, 		Null, 		@P_ubicacion, 		0,		0,		0,		0,	0,		
			Null, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)

END
GO
