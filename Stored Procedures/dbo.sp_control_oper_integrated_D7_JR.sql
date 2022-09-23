SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Sp para obtener la informacion de la admon de los operadores.. vacaciones, permisos, etc etc
--  DRO sp_control_oper_integrated_JR
--GO
--  exec sp_control_oper_integrated_D1_JR  'BAJ'

CREATE PROCEDURE [dbo].[sp_control_oper_integrated_D7_JR]   @lider varchar(12)
AS
DECLARE	
	@V_fechadom		DateTime, 
	@V_fechasab		DateTime,
	@V_fechaDOMI	DateTime,
	@V_fechaLUNI	DateTime,
	@V_fechaMARI	DateTime,	
	@V_fechaMIEI	DateTime,
	@V_fechaJUEI	DateTime,
	@V_fechaVIEI	DateTime,
	@V_fechaSABI	DateTime,
	@V_Operador		Varchar(8),
	@V_Unidad		Varchar(8),
	@V_Nombre		Varchar(45),
	@diasemana		Integer,
	@semana			Integer,
	@año			Integer,
	@lider_Id		varchar(6),
	@total_ope		Integer


DECLARE @TTOperadoresporflota TABLE(
		MPP_IDOPE		Varchar(8) not null,
		MPP_UNIDAD		Varchar(8) Null,
		MPP_NOMBRE		Varchar(45) null)


DECLARE @TTOperadores_Control_D7 TABLE(
		Codigo	Varchar(20) not null,
		OpeId	Varchar(10),
		Openombre	Varchar(45),
		Fechaini datetime,
		Fechafin datetime, 
		FolioExt Integer)


BEGIN --1 Principal
		--busca el id del lider de flota

select @lider_Id = abbr
from labelfile where labeldefinition = 'TeamLeader' 
and retired = 'N' 
and left(name,12) = @lider


	SELECT @diasemana = DATEPART( dw, GETDATE())
	SELECT @Semana	= DATEPART( wk, GETDATE())
	SELECT @Año		= DATEPART( year, GETDATE())


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
						Insert Into @TTOperadores_Control_D7 (codigo,OpeId,OpeNombre,Fechaini,Fechafin, FolioExt )
							(Select 'Descanso',MPP_IDOPE,MPP_NOMBRE, exp_expirationdate, exp_compldate, exp_key  From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and
							exp_code = 'DES' AND MPP_IDOPE = exp_id)

					-- Permisos Dia 1 Sicks
						Insert Into @TTOperadores_Control_D7 (codigo,OpeId,OpeNombre,Fechaini,Fechafin, FolioExt )
							(Select 'Incapacidad',MPP_IDOPE,MPP_NOMBRE, exp_expirationdate, exp_compldate, exp_key   From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and
							exp_code = 'SIC' AND MPP_IDOPE = exp_id)

					-- Permisos Dia 1 Homes
						Insert Into @TTOperadores_Control_D7 (codigo,OpeId,OpeNombre,Fechaini,Fechafin, FolioExt )
							(Select 'Inhabilitado',MPP_IDOPE,MPP_NOMBRE, exp_expirationdate, exp_compldate, exp_key   From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and						
							exp_code = 'HOME' AND MPP_IDOPE = exp_id)
					-- Permisos Dia 1 Vacaciones
						Insert Into @TTOperadores_Control_D7 (codigo,OpeId,OpeNombre,Fechaini,Fechafin, FolioExt )
							(Select 'Vacaciones',MPP_IDOPE,MPP_NOMBRE, exp_expirationdate, exp_compldate, exp_key   From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and
							exp_code = 'VAC' AND MPP_IDOPE = exp_id)
					-- Permisos Dia 1 Inhabilitados
--						Insert Into @TTOperadores_Control_D7 (codigo,OpeId,OpeNombre,Fechaini,Fechafin )
--							(Select 'Inhabilitado',MPP_IDOPE,MPP_NOMBRE, exp_expirationdate, exp_compldate   From expiration, @TTOperadoresporflota Where exp_idtype = 'DRV' and 
--							@V_fechaVIEI >= exp_expirationdate and @V_fechaVIEI  <= exp_compldate and
--							exp_code = 'INHA' AND MPP_IDOPE = exp_id)

	END -- 2 si hay mensajes
select * from @TTOperadores_Control_D7

END --1 Principal
GO
