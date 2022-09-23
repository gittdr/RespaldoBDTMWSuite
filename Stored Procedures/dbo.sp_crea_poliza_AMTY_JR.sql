SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- exec sp_crea_poliza_proveedo_JR


-- Procedimiento para generar poliza de diesel a el proveedo

--DROP PROCEDURE sp_crea_poliza_proveedo_JR 
--GO


CREATE PROCEDURE [dbo].[sp_crea_poliza_AMTY_JR]  
AS
Declare @FechaPeriodo		datetime,
		@li_numperiodo		int,
		@li_yaprocesados	int

SET NOCOUNT ON

BEGIN --1 Principal

-- Encuentra el numero del periodo minimo que esta abierto
select @li_numperiodo = min(psd_id) from paySchedulesdetail where psh_id = 103 and psd_status = 'OPN'


-- Revisar si ese periodo de pago no contiene detalle de pagos ya procesados.

select @li_yaprocesados = count(*) from paydetail where psd_id = @li_numperiodo and asgn_id = 'AMTY'

--Si existe algun paydetail procesado en el periodo abierto, se sale..
IF @li_yaprocesados > 0 Return 2

-- obtiene la fecha del periodo de pago
select @FechaPeriodo = psd_date from paySchedulesdetail where psh_id = 103 and psd_status = 'OPN' and psd_id = @li_numperiodo

-- si no hay paydetail ya en ese periodo se lee los paydetails con la fecha del periodo activo...
execute dbo.d_stlmnt_det_final_sp_JR @phnum=-1, @type = 'TPR', @id = 'AMTY', @paydate = @FechaPeriodo,@numperiodo = @li_numperiodo



-- verifica que haya al menos 1 paydetail

IF (select count(*) from paydetail where psd_id = @li_numperiodo and asgn_id = 'AMTY') <= 0 Return 2

		-- genera el encabezado del payheader
		declare @p_controlid varchar(8)
		set @p_controlid=N'PYHNUM'
		declare @p_alternateid varchar(8)
		set @p_alternateid=null
		declare @return_number integer

		--exec dbo.getsystemnumber N'PYHNUM',NULL
		EXECUTE @return_number = dbo.getsystemnumber_gateway @p_controlid, @p_alternateid, 1
		-- Crea el encabezado de la liquidación

		INSERT INTO payheader ( pyh_paystatus, pyh_prorap, pyh_payperiod, pyh_payto, pyh_pyhnumber, asgn_type, asgn_id, pyh_totalcomp, pyh_totaldeduct, 
		pyh_totalreimbrs, pyh_issuedate ) 
		VALUES ( 'REL', 'A', @FechaPeriodo, 'UNKNOWN', @return_number, 'TPR', 'AMTY', 
		1.20, 0.0000, 3.40, @FechaPeriodo )

		-- Actualiza los paydetails para

		UPDATE paydetail 
		SET pyd_status = 'REL', pyh_number = @return_number, 
		pyh_payperiod = @FechaPeriodo, pyd_workperiod = @FechaPeriodo 
		WHERE psd_id = @li_numperiodo and  asgn_type = 'TPR'and asgn_id = 'AMTY' 

		-- Saca la suma de los paydetails
		Update  payheader set pyh_totalcomp = (select sum(pyd_amount) from paydetail where  
			pyh_number = @return_number and pyd_pretax = 'Y'),
			 pyh_totaldeduct = 0 where pyh_pyhnumber = @return_number

		Update  payheader set pyh_totalreimbrs = (select IsNull(sum(isnull(pyd_amount,0)),0) from paydetail where  
			pyh_number = @return_number and pyd_pretax = 'N')
			where pyh_pyhnumber = @return_number

END --1 Principal











GO
