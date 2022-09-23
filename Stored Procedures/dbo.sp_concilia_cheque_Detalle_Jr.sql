SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SP que sirve para obtener el desgloce de los movimientos por cada cheque generado por tesoreria.

--DROP PROCEDURE sp_concilia_cheque_Detalle_Jr
--GO

--  exec sp_concilia_cheque_Detalle_Jr '01-01-2014 01:00', '02/02/2014 12:00'

CREATE PROCEDURE [dbo].[sp_concilia_cheque_Detalle_Jr] @fechaini		datetime,	@fechafin		datetime

AS
DECLARE	
	@paso	varchar(2)


DECLARE @TTdetallecheque TABLE(
		ch_orden		Int null,
		ch_movimiento	Int NULL,
		ch_liq			Int Null,
		ch_asignado		varchar(13) Null,
		ch_code			varchar(6) Null,
		ch_descripcion	varchar(75) Null,
		ch_monto		money Null,
		ch_glnumber		varchar(32) Null,
		ch_remarks		varchar(254) Null,
		ch_status		varchar(6) Null,
		ch_fechacrea	datetime null)
SET NOCOUNT ON

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
INSERT Into @TTdetallecheque
select ord_hdrnumber,mov_number,pyh_number, asgn_id,pyt_itemcode,
pyd_description, pyd_amount, pyd_glnum, pyd_remarks, pyd_status,pyd_createdon  from tmwsuite..paydetail where pyd_number in
(select referencia from tdrsilt.dbo.banco_cheque_detalle where id_cheque in (
select id_cheque from tdrsilt.dbo.banco_cheque where id_config = 4 and f_elaboracion between @fechaini and @fechafin))



Select ch_orden, ch_movimiento, ch_liq, ch_asignado, ch_code, ch_descripcion, ch_monto, 
ch_glnumber, ch_remarks, ch_status, ch_fechacrea
From @TTdetallecheque 
Order By ch_remarks


END --1 Principal


GO
