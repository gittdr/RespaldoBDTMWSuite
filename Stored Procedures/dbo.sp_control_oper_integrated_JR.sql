SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Sp para obtener la informacion de la admon de los operadores.. vacaciones, permisos, etc etc
--  DRO sp_control_oper_integrated_JR
--GO
--  exec sp_control_oper_integrated_JR  'roberto agui'

CREATE PROCEDURE [dbo].[sp_control_oper_integrated_JR]   @lider varchar(12)
AS
DECLARE	
	@V_fechadom		DateTime, 
	@V_fechasab		DateTime,
	@V_fechaDOMI	DateTime,
	@V_fechaDOMF	DateTime,	
	@V_fechaLUNI	DateTime,
	@V_fechaLUNF	DateTime,
	@V_fechaMARI	DateTime,	
	@V_fechaMARF	DateTime,	
	@V_fechaMIEI	DateTime,
	@V_fechaMIEF	DateTime,
	@V_fechaJUEI	DateTime,
	@V_fechaJUEF	DateTime,
	@V_fechaVIEI	DateTime,
	@V_fechaVIEF	DateTime,
	@V_fechaSABI	DateTime,
	@V_fechaSABF	DateTime,
	@diasemana		Integer,
	@semana			Integer,
	@año			Integer,
	@lider_Id		varchar(6),
	@total_ope		Integer


DECLARE @TTOperadoresporflota TABLE(
		MPP_IDOPE		Varchar(8) not null,
		MPP_UNIDAD		Varchar(8) Null,
		MPP_NOMBRE		Varchar(45) null)





DECLARE @Descansos TABLE (D1 Int, D2 Int, D3 Int, D4 Int, D5 Int, D6 Int, D7 Int)
DECLARE @Sicks TABLE (S1 Int, S2 Int, S3 Int, S4 Int, S5 Int, S6 Int, S7 Int)
DECLARE @Homes TABLE (H1 Int, H2 Int, H3 Int, H4 Int, H5 Int, H6 Int, H7 Int)
DECLARE @Vacaciones TABLE (V1 Int, V2 Int, V3 Int, V4 Int, V5 Int, V6 Int, V7 Int)
DECLARE @Inhabilitados TABLE (I1 Int, I2 Int, I3 Int, I4 Int, I5 Int, I6 Int, I7 Int)

DECLARE @TTOperadores_Control TABLE(
		TotalOpe	integer null,
		Fechaini datetime null,
		Fechafin datetime null,
		Lider	 varchar(12) null,
		Codigo	Varchar(20) not null,
		Dom	Int null, Lun Int null, Mar	Int null, Mie	Int null, Jue Int null, Vie	Int null, Sab Int null)


BEGIN --1 Principal
		--busca el id del lider de flota

select @lider_Id = abbr
from labelfile where labeldefinition = 'TeamLeader' 
and retired = 'N' 
and left(name,12) = @lider

	SELECT @diasemana	= DATEPART( dw, GETDATE())
	SELECT @Semana		= DATEPART( wk, GETDATE())
	SELECT @Año			= DATEPART( year, GETDATE())

IF @diasemana = 7 and @Semana < 52
	SELECT @Semana =  @semana + 1



-- Sp que sirve para extraer las fechas de la semana de Dom a Sab
	Exec SP_ObtenerPeriodoSemana_JR @Año, @Semana, @V_fechadom out , @V_fechasab out

--select @V_fechadom = '2013-04-21 00:00:00'
--select @V_fechasab = '2013-04-27 00:00:00'
Select @V_fechaSABI = DateAdd(d,-1,@V_fechadom)
Select @V_fechaDOMI = @V_fechadom
Select @V_fechaLUNI =  DateAdd(d,1,@V_fechadom)
Select @V_fechaMARI = DateAdd(d,2,@V_fechadom)
Select @V_fechaMIEI = DateAdd(d,3,@V_fechadom)
Select @V_fechaJUEI = DateAdd(d,4,@V_fechadom)
Select @V_fechaVIEI = DateAdd(d,5,@V_fechadom)



-- Inserta en la tabla temporal la información que haya en la de mensajes
INSERT Into @TTOperadoresporflota
	select  mpp_id, mpp_tractornumber, mpp_lastfirst 
	  from  manpowerprofile 
     where  mpp_status <> 'OUT' and mpp_teamleader = @lider_Id
	order by 3

	Select @total_ope	=	count(*) From  @TTOperadoresporflota

	-- Si hay movimientos en la tabla continua
		If Exists ( Select count(*) From  @TTOperadoresporflota )
				BEGIN --2 Si hay mensajes
				-- Llena los totales de cada codigo.
					--Domingo Dia 1 Descansos
						Insert Into @Descansos (D1 )
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaDOMI >= exp_expirationdate and @V_fechaDOMI  <= exp_compldate and
							exp_code = 'DES' AND MPP_IDOPE = exp_id )
						Update @Descansos Set D2= 
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaLUNI >= exp_expirationdate and @V_fechaLUNI  <= exp_compldate and
							exp_code = 'DES' AND MPP_IDOPE = exp_id)
						Update @Descansos Set D3=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMARI >= exp_expirationdate and @V_fechaMARI  <= exp_compldate and
							exp_code = 'DES' AND MPP_IDOPE = exp_id)
						Update @Descansos Set D4=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMIEI >= exp_expirationdate and @V_fechaMIEI  <= exp_compldate and
							exp_code = 'DES' AND MPP_IDOPE = exp_id)
						Update @Descansos Set D5=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaJUEI >= exp_expirationdate and @V_fechaJUEI  <= exp_compldate and
							exp_code = 'DES' AND MPP_IDOPE = exp_id)
						Update @Descansos Set D6=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and
							exp_code = 'DES' AND MPP_IDOPE = exp_id)
						Update @Descansos Set D7=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaSABI >= exp_expirationdate and @V_fechaSABI  <= exp_compldate and
							exp_code = 'DES' AND MPP_IDOPE = exp_id)


				-- Permisos Dia 1 Sicks
						Insert Into @Sicks (S1 )
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaDOMI >= exp_expirationdate and @V_fechaDOMI  <= exp_compldate and
							exp_code = 'SIC' AND MPP_IDOPE = exp_id)
						Update @Sicks Set S2= 
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaLUNI >= exp_expirationdate and @V_fechaLUNI  <= exp_compldate and
							exp_code = 'SIC' AND MPP_IDOPE = exp_id)
						Update @Sicks Set S3=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMARI >= exp_expirationdate and @V_fechaMARI  <= exp_compldate and
							exp_code = 'SIC' AND MPP_IDOPE = exp_id)
						Update @Sicks Set S4=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMIEI >= exp_expirationdate and @V_fechaMIEI  <= exp_compldate and
							exp_code = 'SIC' AND MPP_IDOPE = exp_id)
						Update @Sicks Set S5=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaJUEI >= exp_expirationdate and @V_fechaJUEI  <= exp_compldate and
							exp_code = 'SIC' AND MPP_IDOPE = exp_id)
						Update @Sicks Set S6=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and
							exp_code = 'SIC' AND MPP_IDOPE = exp_id)
						Update @Sicks Set S7=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaSABI >= exp_expirationdate and @V_fechaSABI  <= exp_compldate and
							exp_code = 'SIC' AND MPP_IDOPE = exp_id)

				-- Permisos Dia 1 Homes
						Insert Into @Homes (H1 )
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaDOMI >= exp_expirationdate and @V_fechaDOMI  <= exp_compldate and
							exp_code = 'HOME' AND MPP_IDOPE = exp_id)
						Update @Homes Set H2= 
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaLUNI >= exp_expirationdate and @V_fechaLUNI  <= exp_compldate and
							exp_code = 'HOME' AND MPP_IDOPE = exp_id)
						Update @Homes Set H3=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMARI >= exp_expirationdate and @V_fechaMARI  <= exp_compldate and
							exp_code = 'HOME' AND MPP_IDOPE = exp_id)
						Update @Homes Set H4=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMIEI >= exp_expirationdate and @V_fechaMIEI  <= exp_compldate and
							exp_code = 'HOME' AND MPP_IDOPE = exp_id)
						Update @Homes Set H5=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaJUEI >= exp_expirationdate and @V_fechaJUEI  <= exp_compldate and
							exp_code = 'HOME' AND MPP_IDOPE = exp_id)
						Update @Homes Set H6=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and
							exp_code = 'HOME' AND MPP_IDOPE = exp_id)
						Update @Homes Set H7=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaSABI >= exp_expirationdate and @V_fechaSABI  <= exp_compldate and
							exp_code = 'HOME' AND MPP_IDOPE = exp_id)

-- Permisos Dia 1 Vacaciones
						Insert Into @Vacaciones (V1 )
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaDOMI >= exp_expirationdate and @V_fechaDOMI  <= exp_compldate and
							exp_code = 'VAC' AND MPP_IDOPE = exp_id)
						Update @Vacaciones Set V2= 
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaLUNI >= exp_expirationdate and @V_fechaLUNI  <= exp_compldate and
							exp_code = 'VAC' AND MPP_IDOPE = exp_id)
						Update @Vacaciones Set V3=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMARI >= exp_expirationdate and @V_fechaMARI  <= exp_compldate and
							exp_code = 'VAC' AND MPP_IDOPE = exp_id)
						Update @Vacaciones Set V4=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMIEI >= exp_expirationdate and @V_fechaMIEI  <= exp_compldate and
							exp_code = 'VAC' AND MPP_IDOPE = exp_id)
						Update @Vacaciones Set V5=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaJUEI >= exp_expirationdate and @V_fechaJUEI  <= exp_compldate and
							exp_code = 'VAC' AND MPP_IDOPE = exp_id)
						Update @Vacaciones Set V6=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and
							exp_code = 'VAC' AND MPP_IDOPE = exp_id)
						Update @Vacaciones Set V7=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaSABI >= exp_expirationdate and @V_fechaSABI  <= exp_compldate and
							exp_code = 'VAC' AND MPP_IDOPE = exp_id)

-- Permisos Dia 1 Inhabilitados
						Insert Into @Inhabilitados (I1 )
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaDOMI >= exp_expirationdate and @V_fechaDOMI  <= exp_compldate and
							exp_code = 'INHA' AND MPP_IDOPE = exp_id)
						Update @Inhabilitados Set I2=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaLUNI >= exp_expirationdate and @V_fechaLUNI  <= exp_compldate and
							exp_code = 'INHA' AND MPP_IDOPE = exp_id)
						Update @Inhabilitados Set I3=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMARI >= exp_expirationdate and @V_fechaMARI  <= exp_compldate and
							exp_code = 'INHA' AND MPP_IDOPE = exp_id)
						Update @Inhabilitados Set I4=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaMIEI >= exp_expirationdate and @V_fechaMIEI  <= exp_compldate and
							exp_code = 'INHA' AND MPP_IDOPE = exp_id)
						Update @Inhabilitados Set I5=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaJUEI >= exp_expirationdate and @V_fechaJUEI  <= exp_compldate and
							exp_code = 'INHA' AND MPP_IDOPE = exp_id)
						Update @Inhabilitados Set I6=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and
							exp_code = 'INHA' AND MPP_IDOPE = exp_id)
						Update @Inhabilitados Set I7=
							(Select Count(exp_id) From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaSABI >= exp_expirationdate and @V_fechaSABI  <= exp_compldate and
							exp_code = 'INHA' AND MPP_IDOPE = exp_id)



				INSERT Into @TTOperadores_Control
				select  @total_ope,@V_fechaSABI, @V_fechaVIEI, @lider,'Descansos', D1, D2, D3, D4, D5, D6, D7  from  @Descansos 
				INSERT Into @TTOperadores_Control
				select  @total_ope,@V_fechaSABI, @V_fechaVIEI, @lider,'Incapacidad', S1, S2, S3, S4, S5, S6, S7  from  @Sicks 
				INSERT Into @TTOperadores_Control
				select  @total_ope,@V_fechaSABI, @V_fechaVIEI, @lider,'Inhabilitados', H1, H2, H3, H4, H5, H6, H7  from  @Homes 
				INSERT Into @TTOperadores_Control
				select  @total_ope,@V_fechaSABI, @V_fechaVIEI, @lider,'Vacaciones', V1, V2, V3, V4, V5, V6, V7  from  @Vacaciones 
				--INSERT Into @TTOperadores_Control
				--select  @total_ope,@V_fechaSABI, @V_fechaVIEI, @lider,'Inhabilitados', I1, I2, I3, I4, I5, I6, I7  from  @Inhabilitados 


	END -- 2 si hay mensajes
select * from @TTOperadores_Control

END --1 Principal
GO
